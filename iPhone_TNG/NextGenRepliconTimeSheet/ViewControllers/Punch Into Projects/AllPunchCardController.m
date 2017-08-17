#import "AllPunchCardController.h"
#import "PunchCardStorage.h"
#import "AllPunchCardCell.h"
#import "PunchCardObject.h"
#import "Constants.h"
#import "Theme.h"
#import <KSDeferred/KSPromise.h>
#import "Punch.h"
#import "PunchRepository.h"
#import "PunchClock.h"
#import "PunchImagePickerControllerProvider.h"
#import "AllowAccessAlertHelper.h"
#import <KSDeferred/KSDeferred.h>
#import "ImageNormalizer.h"
#import "ChildControllerHelper.h"
#import "PunchCardController.h"
#import <Blindside/BSInjector.h>
#import "PunchCardsListController.h"
#import "TransferPunchCardController.h"
#import "PunchCardStylist.h"
#import "OEFTypeStorage.h"

@interface AllPunchCardController ()

@property (weak, nonatomic) IBOutlet UIView *transferCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *punchCardsListContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchCardsListHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *transferPunchCardHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (nonatomic) id <AllPunchCardControllerDelegate> delegate;

@property (weak, nonatomic) id<BSInjector> injector;
@property (assign, nonatomic)PunchCardsControllerType controllerType;
@property (nonatomic) KSDeferred *imageDeferred;


@property (nonatomic) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic) TransferPunchCardController *transferPunchCardController;
@property (nonatomic) AllowAccessAlertHelper *allowAccessAlertHelper;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) PunchCardStylist *punchCardStylist;
@property (nonatomic) ImageNormalizer *imageNormalizer;
@property (nonatomic) OEFTypeStorage *oefTypeStorage;
@property (nonatomic) PunchClock *punchClock;
@property (nonatomic,assign) BOOL keyboardVisible;
@property (nonatomic) PunchCardObject *punchCardObject;
@property (nonatomic, assign) WorkFlowType flowType;

@end

static NSString *const CellIdentifier = @"!";

@implementation AllPunchCardController

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider
                               transferPunchCardController:(TransferPunchCardController *)transferPunchCardController
                                    allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                      nsNotificationCenter:(NSNotificationCenter *)nsNotificationCenter
                                          punchCardStylist:(PunchCardStylist *)punchCardStylist
                                           imageNormalizer:(ImageNormalizer *)imageNormalizer
                                            oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                                punchClock:(PunchClock *)punchClock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {

        self.punchImagePickerControllerProvider = punchImagePickerControllerProvider;
        self.transferPunchCardController = transferPunchCardController;
        self.allowAccessAlertHelper = allowAccessAlertHelper;
        self.childControllerHelper = childControllerHelper;
        self.notificationCenter = nsNotificationCenter;
        self.punchCardStylist = punchCardStylist;
        self.imageNormalizer = imageNormalizer;
        self.oefTypeStorage = oefTypeStorage;
        self.punchClock = punchClock;
    }
    return self;
}

- (void)setUpWithDelegate:(id <AllPunchCardControllerDelegate>)delegate
           controllerType:(PunchCardsControllerType)controllerType
          punchCardObject:(PunchCardObject *)punchCardObject
                 flowType:(WorkFlowType)flowType {
    self.punchCardObject = punchCardObject;
    self.controllerType = controllerType;
    self.delegate = delegate;
    self.flowType = flowType;
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [self getTitleBasedOnFlowType:self.flowType];
    
    NSArray *oefTypesArray = [self.oefTypeStorage getAllOEFSForCollectAtTimeOfPunch:PunchActionTypeTransfer];
    
    [self.transferPunchCardController setUpWithDelegate:self
                           punchCardObject:self.punchCardObject
                                  oefTypes:oefTypesArray
                                    flowType:self.flowType];
    
    [self.childControllerHelper addChildController:self.transferPunchCardController
                                toParentController:self
                                   inContainerView:self.transferCardContainerView];
    
    PunchCardsListController *punchCardsListController = [self.injector getInstance:[PunchCardsListController class]];
    [punchCardsListController setUpWithDelegate:self];
    [self.childControllerHelper addChildController:punchCardsListController
                                toParentController:self
                                   inContainerView:self.punchCardsListContainerView];
    self.punchCardsListContainerView.backgroundColor = [self.theme transferCardListContainerButtonColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.widthConstraint.constant = width;

    // Register for the events
    
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Initially the keyboard is hidden
    self.keyboardVisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma  mark - <PunchAssemblyWorkflowDelegate>

- (KSPromise *)punchAssemblyWorkflowNeedsImage
{
    self.imageDeferred = [[KSDeferred alloc] init];
    UIImagePickerController *punchImagePickerController = [self.punchImagePickerControllerProvider provideInstanceWithDelegate:self];
    [self presentViewController:punchImagePickerController animated:YES completion:NULL];
    return self.imageDeferred.promise;
}

- (void)      punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
              assembledPunchPromise:(KSPromise *)assembledPunchPromise
        serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{
    [self.delegate allPunchCardController:self
      willEventuallyFinishIncompletePunch:incompletePunch
                    assembledPunchPromise:assembledPunchPromise
              serverDidFinishPunchPromise:serverDidFinishPunchPromise];
    [self.navigationController popToRootViewControllerAnimated:NO];

}

- (void) punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow didFailToAssembleIncompletePunch:(LocalPunch *)incompletePunch errors:(NSArray *)errors
{
    NSError *locationError;
    NSError *cameraError;

    for(NSError *error in errors)
    {
        if([error.domain isEqualToString:CameraAssemblyGuardErrorDomain])
        {
            cameraError = error;
        } else if([error.domain isEqualToString:LocationAssemblyGuardErrorDomain])
        {
            locationError = error;
        }
    }

    [self.allowAccessAlertHelper handleLocationError:locationError cameraError:cameraError];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        UIImage *normalizedImage = [self.imageNormalizer normalizeImage:originalImage];
        [self.imageDeferred resolveWithValue:normalizedImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePickerController
{
    [self.imageDeferred rejectWithError:nil];
    [imagePickerController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - <PunchCardsListControllerDelegate>

- (void)punchCardsListController:(PunchCardsListController *)punchCardsListController didUpdateHeight:(CGFloat)height
{
    self.punchCardsListHeightConstraint.constant = height;
}

-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController didIntendToTransferUsingPunchCard:(PunchCardObject *)punchCard
{
    [self.punchClock resumeWorkWithPunchProjectAssemblyWorkflowDelegate:self clientType:punchCard.clientType projectType:punchCard.projectType taskType:punchCard.taskType oefTypesArray:punchCard.oefTypesArray];


}

-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController didIntendToPunchInUsingPunchCard:(PunchCardObject *)punchCard
{
    [self.punchClock punchInWithPunchAssemblyWorkflowDelegate:self clientType:punchCard.clientType projectType:punchCard.projectType taskType:punchCard.taskType activity:nil oefTypesArray:nil];

}

-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController
     didIntendToUpdatePunchCard:(PunchCardObject *)punchCardObject
{
    [self.transferPunchCardController updatePunchCardObject:punchCardObject];
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame)+10;
    [self.scrollView setContentOffset:CGPointMake(0, -navigationBarHeight) animated:YES];
}

- (void)punchCardsListController:(PunchCardsListController *)punchCardsListController
didFindPunchCardAsInvalidPunchCard:(PunchCardObject *)punchCardObject {

    PunchCardObject *emptyPunchCard = [[PunchCardObject alloc] initWithClientType:nil projectType:nil oefTypesArray:punchCardObject.oefTypesArray breakType:punchCardObject.breakType taskType:nil activity:nil uri:punchCardObject.uri];

    [self.transferPunchCardController updatePunchCardObject:emptyPunchCard];
}

#pragma mark - <TransferPunchCardControllerDelegate>

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didIntendToTransferPunchWithObject:(PunchCardObject *)punchCard
{
    BOOL isValidTask = (punchCard.taskType != nil &&
                        punchCard.taskType.uri != nil &&
                        punchCard.taskType.uri.length > 0);
    TaskType *taskType = isValidTask ? punchCard.taskType : nil;
    [self.punchClock resumeWorkWithPunchProjectAssemblyWorkflowDelegate:self clientType:punchCard.clientType projectType:punchCard.projectType taskType:taskType oefTypesArray:punchCard.oefTypesArray];


}

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didIntendToResumeWorkForProjectPunchWithObject:(PunchCardObject *)punchCardObject {

    [self.punchClock resumeWorkWithPunchProjectAssemblyWorkflowDelegate:self
                                                             clientType:punchCardObject.clientType
                                                            projectType:punchCardObject.projectType
                                                               taskType:punchCardObject.taskType
                                                          oefTypesArray:punchCardObject.oefTypesArray];
}

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didIntendToResumeWorkForActivityPunchWithObject:(PunchCardObject *)punchCardObject {

    [self.punchClock resumeWorkWithActivityAssemblyWorkflowDelegate:self
                                                           activity:punchCardObject.activity
                                                      oefTypesArray:punchCardObject.oefTypesArray];
}

- (void)transferPunchCardController:(TransferPunchCardController *)punchCardController didUpdateHeight:(CGFloat)height
{
    self.transferPunchCardHeightConstraint.constant = height;
}

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didScrolltoSubview:(id)subview
{
    UITextView *textView = (UITextView *)subview;
    CGRect rc = [subview bounds];
    rc = [subview convertRect:rc toView:self.scrollView];
    float yPosition = (rc.origin.y - 200) + textView.contentSize.height;
    [self.scrollView setContentOffset:CGPointMake(0, yPosition) animated:NO];
}


#pragma mark - <keyboard helper>


-(void) keyboardWillShow: (NSNotification *)notif {
    
    // If keyboard is visible, returnp
    if (self.keyboardVisible) {
        //Keyboard is already visible. Ignore notification
        return;
    }
    
    // Get the size of the keyboard.
    NSDictionary* info = [notif userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // Resize the scroll view to make room for the keyboard
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height = (viewFrame.size.height - keyboardSize.height) + 48.0;
    self.scrollView.frame = viewFrame;
    
    
    // Keyboard is now visible
    self.keyboardVisible = YES;
}

-(void) keyboardWillHide: (NSNotification *)notif {
    // Is the keyboard already shown
    if (!self.keyboardVisible) {
        //Keyboard is already hidden. Ignore notification
        return;
    }
    
    // Reset the frame scroll view to its original value
    self.scrollView.frame = self.view.frame;
    
    
    // Keyboard is no longer visible
    self.keyboardVisible = NO;
    
}

#pragma mark - Helper Methods

- (NSString *)getTitleBasedOnFlowType:(WorkFlowType)flowType {
    NSString *title = @"";
    switch (flowType) {
        case TransferWorkFlowType:
            title = RPLocalizedString(@"Transfer", nil);
            break;
        case ResumeWorkFlowType:
            title = RPLocalizedString(@"Resume Work", nil);
            break;

        default:
            break;
    }
    return title;
}

@end
