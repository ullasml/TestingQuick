#import "ResetPasswordViewController.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "LoginModel.h"
#import <Crashlytics/Crashlytics.h>
#import "Util.h"
#import "Router.h"
#import "FrameworkImport.h"
#import "DefaultTheme.h"
#import "Theme.h"


@interface ResetPasswordViewController ()

@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) id<Router> router;
@property (nonatomic) ResetPasswordView *resetPasswordView;
@property (nonatomic) GATracker *tracker;
@property (nonatomic) id<Theme> theme;

@end


@implementation ResetPasswordViewController

@synthesize loginButton;
@synthesize loginTableView;
@synthesize activityIndicator;

#define LOGIN_NUMBER_OF_ROWS 3

- (instancetype)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                 router:(id <Router>)router
                                tracker:(GATracker *)tracker
                                  theme:(id)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.spinnerDelegate = spinnerDelegate;
        self.router = router;
        self.tracker = tracker;
        self.theme = theme;
    }

    return self;
}

#pragma mark - UIViewControlller

- (void)loadView
{
    [super loadView];

    self.resetPasswordView = [[ResetPasswordView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.resetPasswordView setResetPasswordViewDelegate:self];
    [self.view addSubview:self.resetPasswordView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:RepliconStandardBackgroundColor];

    [Util setToolbarLabel:self withText: RPLocalizedString(ResetPasswordTabbarTitle, @"") ];


    UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Cancel_Button_Title, @"")
                                                                    style: UIBarButtonItemStylePlain
                                                                   target: self
                                                                   action: @selector(cancelAction:)];
    [leftButton1 setTintColor:[self.theme defaultleftBarButtonColor]];
    [self.navigationItem setLeftBarButtonItem:leftButton1 animated:NO];
}

#pragma mark - <LoginDelegate>

- (void)loginServiceDidFinishLoggingIn:(LoginService *)loginService
{
    [self.router launchTabBarController];
    [self.spinnerDelegate hideTransparentLoadingOverlay];

    [self.tracker trackUIEvent:@"login" forTracker:TrackerProduct];
}

#pragma mark - Private

-(void)_resetPassword
{

    NSString *oldPasswordString=[[self.resetPasswordView oldPasswordTextField] text];
    NSString *newPasswordString=[[self.resetPasswordView newPasswordTextField] text];
    NSString *confirmPasswordString=[[self.resetPasswordView confirmPasswordTextField] text];

    if (![oldPasswordString isEqualToString:@""])
    {
        if ((newPasswordString!=nil &&![newPasswordString isEqualToString:@""]) && (confirmPasswordString!=nil &&![confirmPasswordString isEqualToString:@""] ))
        {
            if (![newPasswordString isEqualToString:oldPasswordString]) {
                if ([newPasswordString isEqualToString:confirmPasswordString])
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEPASSWORD_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedData:) name:UPDATEPASSWORD_NOTIFICATION object:nil];
                    [self.resetPasswordView startButtonLoading];
                    [[RepliconServiceManager loginService] sendRequestToUpdatePasswordWithOldPassword:oldPasswordString newPassword:newPasswordString andDelegate:self];

                }
                else
                {
                    [Util errorAlert:@"" errorMessage:RPLocalizedString(PsswordMissMatch_Msg, @"") ];
                }
            }
            else{
                [Util errorAlert:@"" errorMessage:RPLocalizedString(OldPasswordMatch_ErrorMsg, @"") ];
            }
        }
        else {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(LoginValidationErrorMessage, @"")];
        }
    }
    else {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(LoginValidationErrorMessage, @"")];
    }

}

#pragma mark Button Action

-(void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ResetPasswordViewDelegate methods

- (void)resetPasswordViewAction:(ResetPasswordView *)resetPasswordView
{
    [self _resetPassword];
}

#pragma mark Data Received Methods

-(void)receivedData:(NSNotification *)notificationObject{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEPASSWORD_NOTIFICATION object:nil];
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];

    BOOL isErrorOccured = [n boolValue];

    if (isErrorOccured)
    {
        [self.resetPasswordView stopButtonLoading];
    }
    else
    {

        [[RepliconServiceManager loginService] sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:[NSNumber numberWithBool:YES]];
        [[RepliconServiceManager loginService] sendrequestToFetchHomeSummaryWithDelegate:self];
    }
}

@end
