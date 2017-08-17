#import "OEFCollectionPopUpViewController.h"
#import "OEFType.h"
#import "OEFTypeStorage.h"
#import "UserSession.h"
#import "Theme.h"
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import <Blindside/BSInjector.h>
#import "ChildControllerHelper.h"
#import "AppDelegate.h"


@interface OEFCollectionPopUpViewController ()

@property (weak, nonatomic) id<OEFCollectionPopUpViewControllerDelegate> delegate;

@property (weak, nonatomic)  IBOutlet UIView                    *backgroundView;
@property (weak, nonatomic)  IBOutlet UIView                    *cardContainerView;
@property (weak, nonatomic)  IBOutlet UIView                    *containerView;
@property (weak, nonatomic)  IBOutlet UIScrollView              *scrollView;

@property (weak, nonatomic)  IBOutlet NSLayoutConstraint        *oefCardHeightConstraint;
@property (weak, nonatomic)  IBOutlet NSLayoutConstraint        *widthConstraint;

@property (nonatomic) ChildControllerHelper                     *childControllerHelper;
@property (nonatomic) NSNotificationCenter                      *notificationCenter;
@property (nonatomic) UIApplication                             *sharedApplication;
@property (nonatomic) OEFTypeStorage                            *oefTypeStorage;
@property (nonatomic) PunchActionType                           punchActionType;
@property (nonatomic,assign) BOOL                               keyboardVisible;
@property (nonatomic) BOOL                                      isResumeWork;
@property (nonatomic) id<UserSession>                           userSession;
@property (weak, nonatomic) id<BSInjector>                      injector;
@property (nonatomic) id<Theme>                                 theme ;

@end

@implementation OEFCollectionPopUpViewController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                         nsNotificationCenter:(NSNotificationCenter *)nsNotificationCenter
                               oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                uiApplication:(UIApplication *)uiApplication
                                  userSession:(id <UserSession>)userSession
                                        theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.childControllerHelper = childControllerHelper;
        self.notificationCenter = nsNotificationCenter;
        self.oefTypeStorage = oefTypeStorage;
        self.sharedApplication = uiApplication;
        self.userSession = userSession;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithOEFCollectionPopUpViewControllerDelegate:(id<OEFCollectionPopUpViewControllerDelegate>)delegate punchActionType:(PunchActionType)punchActionType
{
    self.delegate = delegate;
    self.punchActionType = punchActionType;
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
    self.view.backgroundColor = [self.theme oefCardParentViewBackgroundColor];
    self.containerView.backgroundColor = [self.theme oefCardContainerViewBackgroundColor];
    self.scrollView.backgroundColor = [self.theme oefCardScrollViewBackgroundColor];
    self.backgroundView.backgroundColor = [self.theme oefCardBackGroundViewColor];

    self.isResumeWork = NO;
    if (self.punchActionType == PunchActionTypeResumeWork)
    {
        self.isResumeWork = YES;
        self.punchActionType = PunchActionTypeTransfer;
    }
    
    OEFCardViewController *oefCardViewController = [self.injector getInstance:[OEFCardViewController class]];
    NSArray *oefTypesArray = [self.oefTypeStorage getAllOEFSForCollectAtTimeOfPunch:self.punchActionType];
    
    if (self.isResumeWork)
        self.punchActionType = PunchActionTypeResumeWork;
    
    [oefCardViewController setUpWithDelegate:self punchActionType:self.punchActionType oefTypesArray:oefTypesArray];
    [self.childControllerHelper addChildController:oefCardViewController
                                toParentController:self
                                   inContainerView:self.cardContainerView];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.tabBarController.tabBar setHidden:NO];
    [self.sharedApplication setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self.notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.extendedLayoutIncludesOpaqueBars = true;

    [self.navigationController.tabBarController.tabBar setHidden:YES];
    [self.sharedApplication setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];

    // Register for the events
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Initially the keyboard is hidden
    self.keyboardVisible = NO;

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.widthConstraint.constant = width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <OEFCardViewControllerDelegate>

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController didIntendToSave:(PunchCardObject *)punchCardObject
{
    [self.delegate oefCollectionPopUpViewController:self didIntendToUpdate:punchCardObject punchActionType:self.punchActionType];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController didUpdateHeight:(CGFloat)height;
{
    self.oefCardHeightConstraint.constant = height;
    
}

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController didScrolltoSubview:(id)subview
{
    UITextView *textView = (UITextView *)subview;
    CGRect rc = [subview bounds];
    rc = [subview convertRect:rc toView:self.scrollView];
    float yPosition = (rc.origin.y - 200) + textView.contentSize.height;
    if (yPosition<0.0)
    {
        yPosition = 0.0;
    }
    [self.scrollView setContentOffset:CGPointMake(0, yPosition) animated:NO];
}

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController cancelButton:(id)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <keyboard helper>


-(void) keyboardWillShow: (NSNotification *)notif {
    
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

@end
