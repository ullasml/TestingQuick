#import "PunchOverviewController.h"
#import <Blindside/Blindside.h>
#import "LocalPunch.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import "ViolationRepository.h"
#import "RemotePunch.h"
#import "UserPermissionsStorage.h"
#import "PunchRepository.h"
#import <KSDeferred/KSPromise.h>
#import "SpinnerDelegate.h"
#import <KSDeferred/KSDeferred.h>
#import "InjectorKeys.h"
#import "AuditTrailController.h"
#import "CalculatePunchTotalService.h"
#import "PunchAttributeController.h"
#import "BreakType.h"
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "Punch.h"
#import "BreakTypeRepository.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "Enum.h"
#import "TimeLinePunchesSummary.h"
#import "PunchValidator.h"


typedef NS_ENUM(NSUInteger, ActionSheetSource) {
    BreakTypeActionSheet,
    DeletePunchActionSheet,
};

@interface PunchOverviewController ()

@property (nonatomic) id<Theme> theme;
@property (nonatomic, weak) id<PunchChangeObserverDelegate> punchChangeObserverDelegate;
@property (nonatomic) RemotePunch *punch;
@property (nonatomic) FlowType flowType;
@property (nonatomic,copy) NSString *userUri;

@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) PunchRepository *punchRepository;
@property (nonatomic) PunchDetailsController *punchDetailsController;
@property (nonatomic) PunchAttributeController *punchAttributeController;
@property (nonatomic) BreakTypeRepository *breakTypeRepository;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButtonOnToolBar;
@property (nonatomic, weak) IBOutlet UIView *punchAttributeContainerView;
@property (nonatomic, weak) IBOutlet UIView *punchDetailsContainerView;
@property (nonatomic, weak) IBOutlet UIView *violationsButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *deletePunchButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *auditTrailContainerView;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchAttributeContainerViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *auditTrailContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchDetailsContainerViewHeightConstraint;

@property (nonatomic) NSHashTable *observers;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) NSArray *breakTypeList;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,assign) BOOL keyboardVisible;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@end


@implementation PunchOverviewController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                          violationRepository:(ViolationRepository *)violationRepository
                          breakTypeRepository:(BreakTypeRepository *)breakTypeRepository
                            punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                              punchRepository:(PunchRepository *)punchRepository
                              spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                        theme:(id <Theme>)theme
                           notificationCenter:(NSNotificationCenter *)notificationCenter
                          reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
{
    self = [super init];
    if (self) {
        self.breakTypeRepository = breakTypeRepository;
        self.childControllerHelper = childControllerHelper;
        self.violationRepository = violationRepository;
        self.punchRulesStorage = punchRulesStorage;
        self.punchRepository = punchRepository;
        self.spinnerDelegate = spinnerDelegate;
        self.theme = theme;
        self.notificationCenter = notificationCenter;
        self.reachabilityMonitor = reachabilityMonitor;
        self.observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)setupWithPunchChangeObserverDelegate:(id<PunchChangeObserverDelegate>)punchChangeObserverDelegate
                                       punch:(RemotePunch *)punch
                                    flowType:(FlowType)flowType
                                     userUri:(NSString *)userUri {
    self.punchChangeObserverDelegate = punchChangeObserverDelegate;
    [self.observers addObject:punchChangeObserverDelegate];
    self.punch = punch;
    self.flowType = flowType;
    self.userUri = userUri;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = [self.theme punchDetailsContentViewBackgroundColor];

    [self hidePickerWithToolBar];
    self.datePicker.backgroundColor = [self.theme datePickerBackgroundColor];

    self.violationsButtonContainerView.backgroundColor = [self.theme punchDetailsContentViewBackgroundColor];
    self.deletePunchButtonContainerView.backgroundColor = [self.theme punchDetailsContentViewBackgroundColor];
    self.auditTrailContainerView.backgroundColor = [self.theme punchDetailsContentViewBackgroundColor];

    self.title = RPLocalizedString(@"Punch Details", nil);

    self.punchDetailsController = [self.injector getInstance:[PunchDetailsController class]];
    [self.punchDetailsController setUpWithTableViewDelegate:self];
    [self.punchDetailsController updateWithPunch:self.punch];
    [self.childControllerHelper addChildController:self.punchDetailsController
                                toParentController:self
                                   inContainerView:self.punchDetailsContainerView];

    self.punchAttributeController = [self.injector getInstance:[PunchAttributeController class]];
    [self.punchAttributeController setUpWithNeedLocationOnUI:YES
                                                    delegate:self
                                                    flowType:self.flowType
                                                     userUri:self.userUri
                                                       punch:self.punch
                                    punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
    [self.childControllerHelper addChildController:self.punchAttributeController
                                toParentController:self
                                   inContainerView:self.punchAttributeContainerView];

    ViolationsButtonController *violationsButtonController = [self.injector getInstance:[ViolationsButtonController class]];
    [violationsButtonController setupWithDelegate:self showViolations:YES];
    [self.childControllerHelper addChildController:violationsButtonController
                                toParentController:self
                                   inContainerView:self.violationsButtonContainerView];

    AuditTrailController *auditTrailController = [self.injector getInstance:[AuditTrailController class]];
    [auditTrailController setupWithPunch:self.punch delegate:self];
    [self.childControllerHelper addChildController:auditTrailController
                                toParentController:self
                                   inContainerView:self.auditTrailContainerView];

    if ([self.punchRulesStorage canEditTimePunch]|| [self.punchRulesStorage canEditNonTimeFields])
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(userDidTapSave:)];
        [self.navigationItem.rightBarButtonItem setAccessibilityLabel:@"punch_details_save_btn"];
    }
    
    if ([self.punchRulesStorage canEditTimePunch]) {
        DeletePunchButtonController *deletePunchButtonController = [self.injector getInstance:[DeletePunchButtonController class]];
        [deletePunchButtonController setupWithDelegate:self];
        [self.childControllerHelper addChildController:deletePunchButtonController
                                    toParentController:self
                                       inContainerView:self.deletePunchButtonContainerView];
    }
    else
    {
        [self.deletePunchButtonContainerView removeFromSuperview];
    }
    
    [self.datePicker  setAccessibilityIdentifier:@"punch_details_date_picker"];
    [self.doneButtonOnToolBar  setAccessibilityLabel:@"punch_details_toolbar_done_btn"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];

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

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == BreakTypeActionSheet && buttonIndex != actionSheet.cancelButtonIndex)
    {
        
        BreakType *breakType = self.breakTypeList[buttonIndex];
        self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                            nonActionedValidations:0
                                               previousPunchStatus:self.punch.previousPunchPairStatus
                                                   nextPunchStatus:self.punch.nextPunchPairStatus
                                                     sourceOfPunch:self.punch.sourceOfPunch
                                                        actionType:self.punch.actionType
                                                     oefTypesArray:self.punch.oefTypesArray
                                                      lastSyncTime:nil
                                                           project:[self.punch.project copy]
                                                       auditHstory:nil
                                                         breakType:[breakType copy]
                                                          location:[self.punch.location copy]
                                                        violations:nil
                                                         requestID:[self.punch.requestID copy]
                                                          activity:[self.punch.activity copy]
                                                          duration:nil
                                                            client:[self.punch.client copy]
                                                           address:[self.punch.address copy]
                                                           userURI:[self.punch.userURI copy]
                                                          imageURL:[self.punch.imageURL copy]
                                                              date:[self.punch.date copy]
                                                              task:[self.punch.task copy]
                                                               uri:[self.punch.uri copy]
                                              isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                                  syncedWithServer:self.punch.syncedWithServer
                                                    isMissingPunch:NO
                                           previousPunchActionType:self.punch.previousPunchActionType ];
        [self.punchDetailsController updateWithPunch:self.punch];
    }
    else if (actionSheet.tag == DeletePunchActionSheet && buttonIndex == actionSheet.destructiveButtonIndex)
    {
        if ([self.reachabilityMonitor isNetworkReachable] == NO)
        {
            [Util showOfflineAlert];
            return;
        }

        [self.spinnerDelegate showTransparentLoadingOverlay];
        KSPromise *deletePromise = [self.punchRepository deletePunchWithPunchAndFetchMostRecentPunch:self.punch];
        
        [deletePromise then:^id(id value) {
            NSDictionary *dateDict = [Util convertDateToApiDateDictionary:self.punch.date];
            [self.punchRepository recalculateScriptDataForuserUri:self.punch.userURI withDateDict:dateDict];
            KSPromise *promise = [self notifyObserversDidEditOrDeletePunch];
            if (promise==nil) {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self.navigationController popViewControllerAnimated:YES];
            }
            [promise then:^id(id value) {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self.navigationController popViewControllerAnimated:YES];
                return nil;
            } error:^id(NSError *error) {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self.navigationController popViewControllerAnimated:YES];
                return nil;
            }];
            
            return nil;
        } error:^id(NSError *error) {
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            return nil;
        }];

    }
    
}

#pragma mark - <PunchDetailsControllerDelegate>

- (void)punchDetailsController:(PunchDetailsController *)punchDetailsController
  didUpdateTableViewWithHeight:(CGFloat)height
{
    self.punchDetailsContainerViewHeightConstraint.constant = height;
}

- (void)punchDetailsController:(PunchDetailsController *)punchDetailsController
didIntendToChangeDateOrTimeOfPunch:(id <Punch>)punch
{
    [self showPickerWithToolBar];
    self.datePicker.date = punch.date;
    [self updateRecentlySelectedPunchDate];
}

- (void)punchDetailsControllerWantsToChangeBreakType:(PunchDetailsController *)punchDetailsController
{
    self.view.userInteractionEnabled = NO;
    KSPromise *breakTypesPromise  = [self.breakTypeRepository fetchBreakTypesForUser:self.userUri];
    [breakTypesPromise then:^id(NSArray *breakTypeList) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:RPLocalizedString(@"Select Break Type", @"Select Break Type")
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        actionSheet.tag = BreakTypeActionSheet;
        self.breakTypeList = breakTypeList;
        for (BreakType *breakType in self.breakTypeList)
        {
            [actionSheet addButtonWithTitle:breakType.name];
        }

        [actionSheet addButtonWithTitle:RPLocalizedString(@"Cancel", @"Cancel")];
        actionSheet.cancelButtonIndex = self.breakTypeList.count;

        [actionSheet showInView:self.view];

        self.view.userInteractionEnabled = YES;

        return nil;
    } error:^id(NSError *error) {
         self.view.userInteractionEnabled = YES;
        return nil;
    }];
}

#pragma mark - <PunchAttributeControllerDelegate>

- (void)punchAttributeController:(PunchAttributeController *)punchDetailsController
    didUpdateTableViewWithHeight:(CGFloat)height;
{
    self.punchAttributeContainerViewHeightConstraint.constant = height;
}
-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
        didIntendToUpdateClient:(ClientType *)client
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[self.punch.oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:nil
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[self.punch.activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:[client copy]
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:nil
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO
                                       previousPunchActionType:self.punch.previousPunchActionType ];

    [self reloadWithNewPunchAttributes:self.punch];
}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
       didIntendToUpdateProject:(ProjectType *)project
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[self.punch.oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:[project copy]
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[self.punch.activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:[self.punch.client copy]
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:nil
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];

    [self reloadWithNewPunchAttributes:self.punch];


}
-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
          didIntendToUpdateTask:(TaskType *)task
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[self.punch.oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:[self.punch.project copy]
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[self.punch.activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:[self.punch.client copy]
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:[task copy]
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];

    [self reloadWithNewPunchAttributes:self.punch];

}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
        didIntendToUpdateActivity:(Activity *)activity
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[self.punch.oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:nil
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:nil
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:nil
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];

    [self reloadWithNewPunchAttributes:self.punch];
}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateDefaultActivity:(Activity *)activity

{

    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[self.punch.oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:nil
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:nil
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:nil
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];

    [self reloadWithNewPunchAttributes:self.punch];

}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
      didIntendToUpdateDropDownOEFTypes:(NSArray *)oefTypesArray
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:[self.punch.project copy]
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[self.punch.activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:[self.punch.client copy]
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:[self.punch.task copy]
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];

    
}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateTextOrNumericOEFTypes:(NSArray *)oefTypesArray
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:[self.punch.project copy]
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[self.punch.activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:[self.punch.client copy]
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:[self.punch.date copy]
                                                          task:[self.punch.task copy]
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];


}


- (void)punchAttributeController:(PunchAttributeController *)punchAttributeController didScrolltoSubview:(id)subview
{
    UITextView *textView = (UITextView *)subview;
    [textView setEditable:YES];
    
    CGRect rc = [subview bounds];
    rc = [subview convertRect:rc toView:self.scrollView];
    float yPosition = (rc.origin.y - 200) + textView.contentSize.height;
    [self.scrollView setContentOffset:CGPointMake(0, yPosition) animated:NO];

}


#pragma mark - <DeletePunchButtonControllerDelegate>

- (void)deletePunchButtonControllerDidSignalIntentToDeletePunch:(DeletePunchButtonController *)deletePunchButtonController
{
    NSString *title =  RPLocalizedString(@"Are you sure you want to delete this punch?", nil);
    NSString *cancelButtonTitle = RPLocalizedString(@"Cancel", nil);
    NSString *deleteButtonTitle = RPLocalizedString(@"Delete", nil);
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc]initWithTitle:title
                                                                  delegate:self
                                                         cancelButtonTitle:cancelButtonTitle
                                                    destructiveButtonTitle:deleteButtonTitle
                                                         otherButtonTitles:nil];
    deleteActionSheet.tag = DeletePunchActionSheet;
    [deleteActionSheet showInView:self.view];
}

#pragma mark - <ViolationsButtonControllerDelegate>

- (KSPromise *)violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:(ViolationsButtonController *)violationsButtonController
{
    return [self.violationRepository fetchValidationsForPunchURI:[self.punch uri]];
}

- (void) violationsButtonController:(ViolationsButtonController *)violationsButtonController
didSignalIntentToViewViolationSections:(AllViolationSections *)allViolationSections
{
    ViolationsSummaryController *violationsSummaryController = [self.injector getInstance:[ViolationsSummaryController class]];
    KSDeferred *deferred = [[KSDeferred alloc] init];
    [violationsSummaryController setupWithViolationSectionsPromise:deferred.promise delegate:self];
    [deferred resolveWithValue:allViolationSections];
    [self.navigationController pushViewController:violationsSummaryController animated:YES];
}

#pragma mark - <ViolationsSummaryControllerDelegate>

- (KSPromise *)violationsSummaryControllerDidRequestViolationSectionsPromise:(ViolationsSummaryController *)violationsSummaryController
{
    return [self.violationRepository fetchValidationsForPunchURI:[self.punch uri]];
}

- (void)violationsSummaryControllerDidRequestToUpdateUI:(ViolationsSummaryController *)violationsSummaryController
{
    [self notifyObserversDidEditOrDeletePunch];
}

#pragma mark - <AuditControllerDelegate>

- (void) auditTrailController:(AuditTrailController *)auditTrailController didUpdateHeight:(CGFloat)height
{
    self.auditTrailContainerViewHeightConstraint.constant = height;

}

#pragma mark - UIDatePickerChangeAction

- (IBAction)datePickerChanged:(UIDatePicker *)datePicker
{
    [self updateRecentlySelectedPunchDate];
}


#pragma mark - Private

- (KSPromise *)notifyObserversDidEditOrDeletePunch
{
    for (id<PunchChangeObserverDelegate> observer in self.observers) {
        return [observer punchOverviewEditControllerDidUpdatePunch];
    }

    return nil;
}

-(void)reloadWithNewPunchAttributes:(id<Punch>)punch
{
    PunchAttributeController *punchAttributeController = [self.injector getInstance:[PunchAttributeController class]];
    [punchAttributeController setUpWithNeedLocationOnUI:YES
                                               delegate:self
                                               flowType:self.flowType
                                                userUri:self.userUri
                                                  punch:punch
                               punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
    [self.childControllerHelper replaceOldChildController:self.punchAttributeController
                                   withNewChildController:punchAttributeController
                                       onParentController:self
                                          onContainerView:self.punchAttributeContainerView];
    self.punchAttributeController = punchAttributeController;
}

- (void)userDidTapSave:(id)sender
{

    [self.view endEditing:YES];
    
    if ([self.reachabilityMonitor isNetworkReachable])
    {
        NSError *validationError = nil;
        if(self.punch.actionType ==PunchActionTypePunchIn || self.punch.actionType == PunchActionTypeTransfer)
        {
            validationError = [self validatePunch];
        }
        
        if(validationError == nil) {
            
            [self.spinnerDelegate showTransparentLoadingOverlay];
            
            KSPromise *promise = [self.punchRepository updatePunch:@[self.punch]];
            [promise then:^id(TimeLinePunchesSummary *timeLinePunchesSummary) {
                id <Punch> updatedPunch = timeLinePunchesSummary.allPunches.lastObject;
                self.punch = updatedPunch;
                //This is not needed now as we are always poping back.
                //[self.punchDetailsController updateWithPunch:self.punch];
                NSDictionary *dateDict = [Util convertDateToApiDateDictionary:self.punch.date];
                [self.punchRepository recalculateScriptDataForuserUri:self.punch.userURI withDateDict:dateDict];
                KSPromise *promise = [self notifyObserversDidEditOrDeletePunch];
                if (promise==nil) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [promise then:^id(id value) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self.navigationController popViewControllerAnimated:YES];
                    return nil;
                } error:^id(NSError *error) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self.navigationController popViewControllerAnimated:YES];
                    return nil;
                }];
                return nil;
                
            } error:^id(NSError *error) {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                if ([self.reachabilityMonitor isNetworkReachable] == NO)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                return nil;
            }];
        }
        else {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"")];
        }
    }
    else
    {
        [Util showOfflineAlert];
        return;
    }
}

- (IBAction)doneActionFromToolBar:(id)sender
{
    [self hidePickerWithToolBar];
    [self updateRecentlySelectedPunchDate];
}

-(void)showPickerWithToolBar
{
    [self.view endEditing:YES];
    self.toolBar.hidden = NO;
    self.datePicker.hidden = NO;
}

-(void)hidePickerWithToolBar
{
    self.toolBar.hidden = YES;
    self.datePicker.hidden = YES;
}

-(void)updateRecentlySelectedPunchDate
{
    self.punch  = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                        nonActionedValidations:self.punch.nonActionedValidationsCount
                                           previousPunchStatus:self.punch.previousPunchPairStatus
                                               nextPunchStatus:self.punch.nextPunchPairStatus
                                                 sourceOfPunch:self.punch.sourceOfPunch
                                                    actionType:self.punch.actionType
                                                 oefTypesArray:[self.punch.oefTypesArray copy]
                                                  lastSyncTime:nil
                                                       project:[self.punch.project copy]
                                                   auditHstory:nil
                                                     breakType:[self.punch.breakType copy]
                                                      location:[self.punch.location copy]
                                                    violations:[self.punch.violations copy]
                                                     requestID:[self.punch.requestID copy]
                                                      activity:[self.punch.activity copy]
                                                      duration:[self.punch.duration copy]
                                                        client:[self.punch.client copy]
                                                       address:[self.punch.address copy]
                                                       userURI:[self.punch.userURI copy]
                                                      imageURL:[self.punch.imageURL copy]
                                                          date:self.datePicker.date
                                                          task:[self.punch.task copy]
                                                           uri:[self.punch.uri copy]
                                          isTimeEntryAvailable:self.punch.isTimeEntryAvailable
                                              syncedWithServer:self.punch.syncedWithServer
                                                isMissingPunch:NO                                           
                                       previousPunchActionType:self.punch.previousPunchActionType ];
    [self.punchDetailsController updateWithPunch:self.punch];
}

#pragma mark - <keyboard helper>


-(void) keyboardWillShow: (NSNotification *)notif {

    [self hidePickerWithToolBar];

    // If keyboard is visible, return
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

#pragma mark - Punch Validation Methods

- (FlowType )getUserFlowType
{
    BOOL isSameUser = [self.punchRulesStorage.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

- (NSError *)validatePunch {
    
    PunchValidator *punchValidator = [self.injector getInstance:[PunchValidator class]];
    if([self getUserFlowType]==UserFlowContext)
    {
        return [punchValidator validatePunchWithClientType:self.punch.client
                                               projectType:self.punch.project
                                                  taskType:self.punch.task
                                              activityType:self.punch.activity
                                                   userUri:nil];
    }
    else
    {
        return [punchValidator validatePunchWithClientType:self.punch.client
                                               projectType:self.punch.project
                                                  taskType:self.punch.task
                                              activityType:self.punch.activity
                                                   userUri:self.userUri];
    }
}



@end
