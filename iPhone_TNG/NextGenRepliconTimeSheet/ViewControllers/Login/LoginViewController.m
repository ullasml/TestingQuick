
#import "LoginViewController.h"
#import "Constants.h"
#import "Util.h"

#import "AppDelegate.h"
#import "ACSimpleKeychain.h"

#import "WelcomeViewController.h"
#import "FreeTrialNavigationViewController.h"
#import "ForgotPasswordViewController.h"
#import "LoginWithGoogleViewController.h"
#import "SpinnerDelegate.h"
#import "CookiesDelegate.h"
#import "Router.h"
#import "RepliconServiceManager.h"
#import "LoginView.h"
#import <Blindside/Blindside.h>
#import "LoginCredentialsHelper.h"
#import "FrameworkImport.h"
#import "DefaultTheme.h"
#import "Theme.h"


#define INCOMPATIBLE_ALERT_VIEW_TAG 1

@interface LoginViewController ()

@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) id<CookiesDelegate> cookiesDelegate;
@property (nonatomic, weak) id<Router> router;
@property (nonatomic) LoginView *loginView;
@property (nonatomic) NSString *errorString;
@property (nonatomic) UIActionSheet *actionSheet;
@property (nonatomic) GATracker *tracker;
@property (nonatomic) LoginCredentialsHelper *loginCredentialsHelper;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) EMMConfigManager *emmConfigManager;
@property (nonatomic) id <BSInjector> injector;
@property (nonatomic) NSUserDefaults *userDefaults;
@end


////
@implementation LoginViewController

- (instancetype)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                        cookiesDelegate:(id <CookiesDelegate>)cookiesDelegate
                                 router:(id <Router>)router
                                tracker:(GATracker *)tracker
                 loginCredentialsHelper:(LoginCredentialsHelper *)loginCredentialsHelper
                                  theme:(id<Theme>)theme
                       emmConfigManager:(EMMConfigManager *)emmConfigManager
                           userDefaults:(NSUserDefaults *)userDefaults
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.spinnerDelegate = spinnerDelegate;
        self.cookiesDelegate = cookiesDelegate;
        self.router = router;
        self.tracker = tracker;
        self.loginCredentialsHelper = loginCredentialsHelper;
        self.emmConfigManager = emmConfigManager;
        self.theme = theme;
        self.userDefaults = userDefaults;
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle methods

- (void)viewDidUnload {
    self.loginView = nil;
}

- (void)loadView {
    self.loginView = [[LoginView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.loginView setLoginViewDelegate:self];
    [self.loginView setShouldShowPasswordField:self.showPasswordField];
    [self.loginView setShouldShowGoogleSignIn:!self.showPasswordField];

    self.view = self.loginView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.cookiesDelegate deleteCookies];

    [self.userDefaults removeObjectForKey:@"AuthMode"];
    [self.userDefaults synchronize];

    [self _setupSignInView];

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    // TODO: Refactor away the reference to the AppDelegate and replace with a Controller or Model
    delegate.showCompanyView = TRUE;
    // end TODO
    
    [Util setToolbarLabel:self withText:RPLocalizedString(SignIn, @"")];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_welcomeButtonAction:)];
    [cancelBarButtonItem setTintColor:[self.theme defaultleftBarButtonColor]];
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipeFrom:)];
    [recognizer setDirection:( UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp)];
    [[self view] addGestureRecognizer:recognizer];

    [self.tracker trackUIEvent:@"start" forTracker:TrackerProduct];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedForCurrentGen:)
                                                 name:CURRENTGEN_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedForNextGen:)
                                                 name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION
                                               object:nil];
    
    
    // TODO: the following does not belong in this file. Move to Controller logic
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.isShowTimeSheetPlaceHolder=FALSE;
    appDelegate.isShowExpenseSheetPlaceHolder=FALSE;
    appDelegate.isShowTimeOffSheetPlaceHolder=FALSE;
    appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
    appDelegate.isNotFirstTimeLaunch=FALSE;
    appDelegate.selectedModuleName=nil;
    appDelegate.isWaitingForDeepLinkToErrorDetails = NO;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (appDelegate.beaconsCtrl) {
        SCHBeaconsViewController *beaconCtrl=appDelegate.beaconsCtrl;
        [beaconCtrl stopBeacons];
        
        appDelegate.beaconsCtrl=nil;
    }


    //[self.tracker trackScreenView:@"loginview" forTracker:TrackerProduct];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Remove all notification observers for this instance
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setters

- (void)setShowPasswordField:(BOOL)showPasswordField {
    _showPasswordField = showPasswordField;
    
    if ([self isViewLoaded]) {
        [self.loginView setShouldShowPasswordField:showPasswordField];
        [self.loginView setShouldShowGoogleSignIn:!showPasswordField];
    }
}

#pragma mark - View setup

- (void)_welcomeButtonAction:(id)type {
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate launchWelcomeViewController];

}

- (void)_setupSignInView {
    BOOL shouldRememberMe = [self _shouldRememberMe];
    
    [self.loginView setShouldRememberMe:shouldRememberMe];
    
    UITextField *companyTxtField = [self.loginView companyTextField];
    UITextField *usernameTxtField = [self.loginView usernameTextField];
    
    NSDictionary *credentials = [self _credentialsDict]; //User credentials stored in keychain
    
    //EMM credentials takes priority
    
    if (shouldRememberMe) {
        if (credentials != nil) {
            [companyTxtField setText:[credentials valueForKey:ACKeychainCompanyName]];
            [usernameTxtField setText:[credentials valueForKey:ACKeychainUsername]];
        }
        
        if ([self.userDefaults boolForKey:@"isConnectStagingServer"] )
        {
            [self.userDefaults setObject: [self.userDefaults objectForKey:@"tempurlPrefixesStr" ] forKey:@"urlPrefixesStr"];
            [self.userDefaults synchronize];
            [companyTxtField setText:[NSString stringWithFormat:@"%@/%@",[self.userDefaults objectForKey:@"urlPrefixesStr"],[credentials valueForKey:ACKeychainCompanyName]]];
        }
        else
        {
            [companyTxtField setText:[credentials valueForKey:ACKeychainCompanyName]];
        }
        [usernameTxtField setText:[credentials valueForKey:ACKeychainUsername]];
    }
    else
    {
        ///Commenting for MI-1554, this is deleting the keyChain values, which is required for Force Create New Password services.
        //The response overides the values with the new entered password by the user.
        
        //ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
        //[keychain deleteAllCredentialsForService:@"repliconUserCredentials"];
        
        [companyTxtField setText:@""];
        [usernameTxtField setText:@""];
    }
    
    if(self.emmConfigManager.isEMMValuesStored){
        if(self.emmConfigManager.companyName != nil && self.emmConfigManager.companyName != (id)[NSNull null]) {
            companyTxtField.text = self.emmConfigManager.companyName;
        }
        if(self.emmConfigManager.userName != nil && self.emmConfigManager.userName != (id)[NSNull null]) {
            usernameTxtField.text = self.emmConfigManager.userName;
        }
    }
    [self.userDefaults setBool:TRUE forKey:@"firstTimeLogging"];
    [self.userDefaults synchronize];
}

#pragma mark - <LoginDelegate>

- (void)loginServiceDidFinishLoggingIn:(LoginService *)loginService
{
    [self.router launchTabBarController];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate sendRequestForGettingUpdatedBadgeValue];
    [self.spinnerDelegate hideTransparentLoadingOverlay];


    NSDictionary *loginCredentials = [self.loginCredentialsHelper getLoginCredentials];
    NSString *companyName = [loginCredentials objectForKey:@"companyName"];
    if (companyName == nil || companyName.length <= 0) {
        companyName = @"na";
    }
    NSString *userUri = [loginCredentials objectForKey:@"userUri"];
    if (userUri == nil || userUri.length <= 0) {
        userUri = @"na";
    }
    NSString *username = [loginCredentials objectForKey:@"userName"];
    if (username == nil || username.length == 0) {
        username = @"na";
    }
    NSString *platform = [self.userDefaults boolForKey:@"IS_GEN2_INSTANCE"] ? @"gen2" : @"gen3";
    [self.tracker setUserUri:userUri companyName:companyName username:username platform:platform];

    [self.tracker trackUIEvent:@"login" forTracker:TrackerProduct];
}

#pragma mark - LoginViewDelegate methods

// Handle state change of the "Remember Company and User Name" switch
- (void)loginView:(LoginView *)loginView rememberSwitchChanged:(BOOL)shouldRememberMe {
    [self.userDefaults setBool:shouldRememberMe forKey:@"RememberMe"];
    [self.userDefaults synchronize];
}

// Clicked toolbar "Done"
- (void)loginView:(LoginView *)loginView doneButtonAction:(id)sender {
    [loginView endEditing:YES];
}

// Clicked "Sign In"
- (void)loginView:(LoginView *)loginView signInButtonAction:(id)sender {
    [self.cookiesDelegate deleteCookies];
    if ([loginView shouldShowPasswordField]) {
        [self.loginView showSignInButtonLoadingWithMessage:RPLocalizedString(SIGNING_TEXT,SIGNING_TEXT)];
        [self _signInWithPassword:sender];
    } else {
        [self.loginView showSignInButtonLoadingWithMessage:RPLocalizedString(AUTHENTICATING_TEXT, AUTHENTICATING_TEXT)];
        [self _signInWithoutPassword:sender];
    }
}

// Clicked "Sign In with Google"
- (void)loginView:(LoginView *)loginView googleButtonAction:(id)sender {
    [self.loginView showGoogleButtonLoadingWithMessage:RPLocalizedString(AUTHENTICATING_TEXT, AUTHENTICATING_TEXT)];
    [self _signInWithoutPassword:sender];
}

// Clicked "Contact Support"
- (void)loginView:(LoginView *)loginView feedbackButtonAction:(id)sender {
    if ([MFMailComposeViewController canSendMail] == NO) {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Close", @"Close")
                                       otherButtonTitle:nil
                                               delegate:nil
                                                message:RPLocalizedString(@"This device is not configured for sending mail", @"This device is not configured for sending mail")
                                                  title:nil
                                                    tag:LONG_MIN];
        return;
    }
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    [mailPicker.navigationBar setTintColor:[self.theme defaultleftBarButtonColor]];
    mailPicker.mailComposeDelegate = self;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *emailSubject=nil;
    NSString *mailCompanyName=nil;
    NSString *mailCompanyDetails=nil;
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials =  nil;
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]])
        {
            mailCompanyName = [credentials valueForKey:ACKeychainCompanyName];
        }
    }
    
    emailSubject=[RPLocalizedString(TROUBLE_SIGNING_EMAIL_SUBJECT, "")  stringByAppendingString:version];
    
    if (mailCompanyName!=nil)
    {
        mailCompanyDetails=[RPLocalizedString(COMPANY_NAME, "") stringByAppendingFormat:@": %@",mailCompanyName];
        emailSubject=[NSString stringWithFormat:@"%@, %@",emailSubject,mailCompanyDetails];
    }
    
    else
    {
        emailSubject=[NSString stringWithFormat:@"%@",emailSubject];
    }
    
    [mailPicker setSubject:emailSubject];
    [mailPicker setToRecipients:[NSArray arrayWithObject:RECIPENT_ADDRESS]];
    
    //MOBI-811 Ullas M l
    NSString *messageBody=[Util getEmailBodyWithDetails];
    [mailPicker setMessageBody:messageBody isHTML:NO];
    
    [self presentViewController:mailPicker animated:YES completion:nil];

    [self.tracker trackUIEvent:@"start" forTracker:TrackerProduct];
}


- (void)loginView:(LoginView *)loginView troubleSigningInAction:(id)sender
{
    [self launchActionSheet];
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(@"Sending Failed - Unknown Error :-(", @"Sending Failed - Unknown Error :-(")
                                                      title:RPLocalizedString(@"Email",@"Email")
                                                        tag:LONG_MIN];
            break;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Launch Google SSO

- (void)launchGoogleSignInViewController:(NSString *)url {
    if (url != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


#pragma mark - Login methods

- (void)_signInWithoutPassword:(id)sender {
    CLS_LOG(@"-----Login Action on LoginviewController-----");
    
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        [Util showOfflineAlert];
        return;
    }
    
    
    NSString *buttonType = nil;
    if (sender == nil || [sender tag] == 1) {
        buttonType = @"Sign In";
    } else {
        buttonType = @"Sign In with Google";
    }
    
    
    NSString *companyNameString = [[[self.loginView companyTextField] text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    companyNameString=[companyNameString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *userNameString = [[self.loginView usernameTextField] text];
    
    BOOL validCredential = [self _validateUserCredentialsWithCompanyName:companyNameString userName:userNameString buttonTag:[sender tag]];
    if (validCredential) {
        
        [[RepliconServiceManager loginService] sendrequestToFetchUserIntegrationDetailsForiOS7WithDelegate:self buttonType:buttonType];
        
    } else {
        [self.loginView stopButtonLoading];
        // TODO: Do something, credential validation failed!
    }
}

- (void)_signInWithPassword:(id)sender {
    CLS_LOG(@"-----SignIN Action on LoginviewController-----");
    
    // Check network availability
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        [Util showOfflineAlert];
        return;
    }

    NSString *companyString = [[[self.loginView companyTextField] text]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    companyString=[companyString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *usernameString = [[self.loginView usernameTextField] text];
    NSString *passwordString = [[self.loginView passwordTextField] text];
    
    
    if (companyString != nil) {
        NSArray *companyNameArray = [companyString componentsSeparatedByString:@"/"];
        if ([companyNameArray count] > 1) {
            NSString *urlPrefixesStr = [companyNameArray objectAtIndex:0];
            companyString = [companyNameArray objectAtIndex:1];
            [self.userDefaults setObject:urlPrefixesStr forKey:@"urlPrefixesStr"];
            [self.userDefaults setObject:urlPrefixesStr forKey:@"tempurlPrefixesStr"];
            [self.userDefaults synchronize];
        } else {
            [self.userDefaults removeObjectForKey:@"urlPrefixesStr"];
            [self.userDefaults synchronize];
        }
    }
    
    if ([companyString length] != 0 && [usernameString length] != 0 && [passwordString length] != 0) {
        ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
        NSDictionary *credentials = [self _credentialsDict];
        
        // MOBI-471
        if (credentials != nil) {
            if (![[credentials valueForKey:ACKeychainCompanyName] isEqualToString:companyString]) {
                [Util flushDBInfoForOldUser:NO];
            } else if (![[credentials valueForKey:ACKeychainUsername] isEqualToString:usernameString]) {
                [Util flushDBInfoForOldUser:NO];
            }
        }
        
        if ([keychain storeUsername:usernameString password:passwordString companyName:[companyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forService:@"repliconUserCredentials"]) {
            NSLog(@"**SAVED**");
        } else {
            // store credentials failed! we should probably log an error message here...
        }
        
        
        
        [[RepliconServiceManager loginService] sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:[NSNumber numberWithBool:YES]];
        
        [[RepliconServiceManager loginService] sendrequestToFetchHomeSummaryWithDelegate:self];
    }
    else
    {
        [self.loginView stopButtonLoading];
        
        if ([usernameString length] == 0 && [passwordString length] == 0) {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(INVALID_USER_NAME_PASSWORD_TEXT,@"")];
        } else if ([usernameString length] == 0) {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(InvaliDLoginName,@"")];
        } else {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(INVALID_PASSWORD_TEXT,@"")];
        }
    }
}

- (void)dataReceivedForCurrentGen:(NSNotification *)notification {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (hasError) {
        if (self.errorString != nil) {
            [Util errorAlert:@"" errorMessage:self.errorString];
        }
    }
    else
    {
        // TODO: why is an error alert shown if hasError == NO?
        
        //SHOW THE CUSTOMIZED ERROR
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(Incompatible_App_Later, Incompatible_App_Later)
                                       otherButtonTitle:RPLocalizedString(@"OK", @"OK")
                                               delegate:self
                                                message:RPLocalizedString(GEN2_LAUNCH_APP_MSG, GEN2_LAUNCH_APP_MSG)
                                                  title:@""
                                                    tag:INCOMPATIBLE_ALERT_VIEW_TAG];
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    [self.loginView stopButtonLoading];
    
}

- (void)dataReceivedForNextGen:(NSNotification *)notification {
    //     [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    
    NSDictionary *dict = notification.userInfo;
    BOOL hasError = [[dict objectForKey:@"isError"] boolValue];
    NSString *errorMsg = [dict objectForKey:@"errorMsg"];
    
    if (hasError) {
        self.errorString = errorMsg;
        
        // TODO: show an error message here?
        if([errorMsg isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR])
        {
            [[self.loginView passwordTextField] setText:@""];
        }
        else {
        [self setShowPasswordField:NO];
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        
        //HERE CURRENT GEN AUTH API IS BEING CALLED TO CHECK FOR THE RIGHT APP
        [[RepliconServiceManager loginService] sendrequestToFetchAuthRemoteAPIUrl:self];
        }
    } else {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate didCompanyLoginSuccess];
    }
    [self.loginView stopButtonLoading];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag==INCOMPATIBLE_ALERT_VIEW_TAG)
    {
        [self.userDefaults setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
        [self.userDefaults setBool:TRUE forKey:@"IS_GEN2_INSTANCE"];
        [self.userDefaults synchronize];
        
        CLSLog(@"---CREATE DUMMY CRASH TO SWITCH TO GEN 2---");
        
        // TODO: check if exit() is allowed by App Store reviewers
        exit(1);
    }
}


#pragma mark - Helper methods

- (BOOL)_shouldRememberMe {
    return [self.userDefaults boolForKey:@"RememberMe"];
}

- (NSDictionary *)_credentialsDict {
    NSDictionary *loginCredentials = [self.loginCredentialsHelper getLoginCredentials];
    return loginCredentials;
}

- (void)_handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

- (BOOL)_validateUserCredentialsWithCompanyName:(NSString *)companyNameString userName:(NSString *)userNameString buttonTag:(NSInteger)tag
{
    // TODO: This can be generalized and moved to a Util class
    
    NSArray *companyNameArray=[companyNameString componentsSeparatedByString:@"/"];
    BOOL isSaml = false;
    
    if ([companyNameArray count]>1)
    {
        //Staging area
        NSString  *urlPrefixesStr=[companyNameArray objectAtIndex:0];
        companyNameString=[companyNameArray objectAtIndex:1];
        [self.userDefaults setObject:urlPrefixesStr forKey:@"urlPrefixesStr"];
        [self.userDefaults setObject: urlPrefixesStr forKey:@"tempurlPrefixesStr"];
        [self.userDefaults setBool:TRUE forKey:@"isConnectStagingServer"];
        [self.userDefaults synchronize];
    }
    else
    {
        //Production area
        [self.userDefaults setObject:nil forKey:@"urlPrefixesStr"];
        [self.userDefaults setBool:FALSE forKey:@"isConnectStagingServer"];
        [self.userDefaults synchronize];
        isSaml = true;
        
    }
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    
    if ([keychain storeUsername:userNameString password:@"" companyName:[companyNameString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forService:@"repliconUserCredentials"]) {
        NSLog(@"**SAVED**");
    }
    
    BOOL isCompanyNameValid=FALSE;
    BOOL isUserNameValid=FALSE;
    
    NSString *usernameValidationMsg = RPLocalizedString(InvaliDLoginName,@"");
    NSString *userNameAndCompanyNameValidation = RPLocalizedString(USER_NAME_COMPANY_NAME_VALIDATION,@"");
    if (tag == 2)
    {
        usernameValidationMsg = RPLocalizedString(INVALID_EMAIL_ADDRESS_TEXT,@"");
        userNameAndCompanyNameValidation = RPLocalizedString(EMAIL_COMPANY_NAME_VALIDATION,@"");
    }
    
    
    if (userNameString.length ==0 && companyNameString.length ==0 ) {
        [Util errorAlert:@"" errorMessage:userNameAndCompanyNameValidation];
    }
    else
    {
        if (companyNameString!=nil )
        {
            
            if (companyNameString.length !=0)
            {
                isCompanyNameValid=TRUE;
            }
            else
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(UserNameValidationMessage,@"")];
            }
        }
        else
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(UserNameValidationMessage,@"")];
        }
        
        if (userNameString!=nil )
        {
            
            if (userNameString.length !=0)
            {
                isUserNameValid=TRUE;
            }
            else
            {
                //DON"T SHOW THIS WHEN COMPANY VALIDATION ALERT IS SHOWN
                if (isCompanyNameValid)
                {
                    [Util errorAlert:@"" errorMessage:usernameValidationMsg];
                }
                
            }
        }
        else
        {
            //DON"T SHOW THIS WHEN COMPANY VALIDATION ALERT IS SHOWN
            if (isCompanyNameValid)
            {
                [Util errorAlert:@"" errorMessage:usernameValidationMsg];
            }
            
        }
    }
    
    
    
    if (isCompanyNameValid && isUserNameValid )
    {
        return YES;
    }
    
    return NO;
    
}

-(void) launchActionSheet {
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:RPLocalizedString(CANCEL_STRING, CANCEL_STRING)
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:RPLocalizedString(FORGOT_PASSWORD, FORGOT_PASSWORD),
                                                            RPLocalizedString(CONTACT_SUPPORT, CONTACT_SUPPORT),
                                                            nil];
    [self.actionSheet showInView:self.view];
}

-(void)goToForgotPasswordView
{
    ForgotPasswordViewController *forgotPasswordViewController =  [self.injector getInstance:[ForgotPasswordViewController class]];
        
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0)
    {
        [self goToForgotPasswordView];
    }
    else if (buttonIndex == 1)
    {
        [self loginView:nil feedbackButtonAction:nil];
    }
}




@end

