#import "SAMLWebViewController.h"
#import "Constants.h"
#import "Util.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "ACSimpleKeychain.h"
#import "RepliconAppDelegate.h"

@interface SAMLWebViewController ()

@property (nonatomic) LoginService *loginService;
@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;

@end


@implementation SAMLWebViewController
@synthesize mainWebView;
@synthesize urlAddress;
@synthesize userNameField,passwordField;
@synthesize count;
@synthesize userNameStr,passwordStr;
@synthesize indicatorView;
@synthesize overlayimageView;

- (instancetype)initWithLoginService:(LoginService *)loginService
                     spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                         appDelegate:(AppDelegate *)appDelegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.loginService = loginService;
        self.spinnerDelegate = spinnerDelegate;
        self.appDelegate = appDelegate;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [self.appDelegate deleteCookies];

    count=0;

    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieJar = [storage cookies];

    for (NSHTTPCookie *cookie in cookieJar)
    {
        [storage deleteCookie:cookie];
    }

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    [self createWebviewAndAddtoWindow];

    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [mainWebView loadRequest:urlRequest];
    [self addOverlay];


    self.appDelegate.isCountPendingSheetsRequestInQueue = NO;

}


- (void) networkActivated
{


}


-(void)createWebviewAndAddtoWindow
{
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height)];
    self.mainWebView = aWebView;

    aWebView.scalesPageToFit = YES;
    self.mainWebView.autoresizesSubviews = YES;
    self.mainWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [ self.mainWebView setDelegate:self];
    [self.view addSubview:self.mainWebView];

    UIActivityIndicatorView *tempindicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView=tempindicatorView;

    [indicatorView setFrame:CGRectMake(135, 185, 50, 50)];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    [self.mainWebView addSubview:indicatorView];

}



-(void)showAuthenticationRequiredDialog
{

    UIAlertView* dialog = [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(SUBMIT_BTN_MSG, SUBMIT_BTN_MSG)
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:@"\n\n\n\n"
                                              title:RPLocalizedString(AUTHENTICATION_REQUIRED_MESSAGE, AUTHENTICATION_REQUIRED_MESSAGE)
                                                tag:9999];


    UITextField *tempuserNameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 50.0, 245.0, 28.0)];
    self.userNameField=tempuserNameField;

    [self.userNameField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18]];
    self.userNameField.placeholder=RPLocalizedString(USERNAME_MSG, USERNAME_MSG);
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.userNameField.borderStyle=UITextBorderStyleRoundedRect;
    self.userNameField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.userNameField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials =  nil;
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]])
        {
            self.userNameField.text=[credentials valueForKey:ACKeychainUsername];
        }
    }



    [ self.userNameField setBackgroundColor:[UIColor whiteColor]];
    [dialog addSubview: self.userNameField];
    UITextField *temppasswordField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 95.0, 245.0, 28.0)];
    self.passwordField=temppasswordField;

    [self.passwordField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18]];
    self.passwordField.placeholder=RPLocalizedString(PASSWORD_MSG, PASSWORD_MSG);
    self.passwordField.secureTextEntry=TRUE;
    self.passwordField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.borderStyle=UITextBorderStyleRoundedRect;
    [ self.passwordField setBackgroundColor:[UIColor whiteColor]];
    self.passwordField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [self.passwordField becomeFirstResponder];
    [dialog addSubview: self.passwordField];



}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 9999)
    {

        if (self.userNameField.text==nil || [[self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] isEqualToString:@""] || self.passwordField.text==nil || [[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] isEqualToString:@""] )
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(InvaliDLogin,InvaliDLogin)
                                                      title:nil
                                                        tag:9998];


            return;
        }
        self.userNameStr=self.userNameField.text;
        self.passwordStr= self.passwordField.text;

        [[NSUserDefaults standardUserDefaults] setObject:self.userNameStr forKey:@"TempSSOLoginName"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[hackChallenge sender] useCredential:[NSURLCredential credentialWithUser:self.userNameStr password:self.passwordStr persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:hackChallenge];



    }

    else if (alertView.tag == 9998)
    {
        [self.mainWebView stopLoading];
        [self.mainWebView removeFromSuperview];
        self.mainWebView=nil;
        [self.view removeFromSuperview];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }

}


#pragma mark -
#pragma mark Webview Delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    DLog(@"Did start loading: %@ auth:%d", [[request URL] absoluteString], _authed);

    if (!_authed || count==1)
    {
        _authed = NO;
        /* pretty sure i'm leaking here, leave me alone... i just happen to leak sometimes */
        // [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [NSURLConnection connectionWithRequest:request delegate:self];
        if (count==1) {
            count++;
        }

        return NO;
    }

    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{

    //   DLog(@"webViewDidFinishLoad");


    DLog(@"webViewDidFinishLoad ::: %@",webView.request.URL.absoluteString);
    count++;




    if ([webView.request.URL.absoluteString hasString: [[AppProperties getInstance] getAppPropertyFor: @"SSOTargetURL"]])
    {

        [self handleCookiesResponse];
        if ([self.indicatorView isAnimating])
        {
            [self.indicatorView stopAnimating];

        }
        [self.mainWebView stopLoading];
        [self.mainWebView removeFromSuperview];
        self.mainWebView=nil;
        [self.view removeFromSuperview];
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate launchTabBarController];
        [appDelegate showTransparentLoadingOverlay];
        [[RepliconServiceManager loginService] sendrequestToFetchHomeSummaryWithDelegate:self];
        [[RepliconServiceManager loginService] sendrequestToUpdateMySessionTimeoutDuration];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //   DLog(@"didFailLoadWithError");
    if ([error code]==-1202)
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(InvaliDLogin,InvaliDLogin)
                                                  title:nil
                                                    tag:9998];


    }

}

- (void)webView:(UIWebView *)sender didFinishLoadForFrame:(CGRect *)frame
{
    //   DLog(@"didFinishLoadForFrame");

}

#pragma mark -
#pragma mark url connection delegates

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    //   DLog(@"SAML::didReceiveAuthenticationChallenge");
    NSLog(@"%@",[challenge.protectionSpace authenticationMethod]);
    if ([[challenge.protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else if ([challenge previousFailureCount] == 0)
    {
        _authed = YES;

        if (self.userNameStr==nil || self.passwordStr==nil)
        {
            hackChallenge=challenge;
            [self showAuthenticationRequiredDialog];
        }
        else
        {
            /* SET YOUR credentials, i'm just hard coding them in, tweak as necessary */
            [[challenge sender] useCredential:[NSURLCredential credentialWithUser:self.userNameStr password:self.passwordStr persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
        }


    }
    else
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(InvaliDLogin,InvaliDLogin)
                                                  title:nil
                                                    tag:9998];

        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //   DLog(@"received response via nsurlconnection");
    _authed = YES;
    /** THIS IS WHERE YOU SET MAKE THE NEW REQUEST TO UIWebView, which will use the new saved auth info **/
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
    [self.mainWebView loadRequest:urlRequest];

}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}



- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return YES;
}


#pragma mark -
#pragma mark Add/remove overlay

-(void)addOverlay
{

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIImage *overlayImage=[Util thumbnailImage:overlay_image];
    UIImage *closerImage=[Util thumbnailImage:closer_image];
    UIImageView *tempOverlayImageView= [[UIImageView alloc]initWithImage:overlayImage];
    self.overlayimageView=tempOverlayImageView;


    self.overlayimageView.frame =CGRectMake(0, screenRect.size.height-overlayImage.size.height-(overlayImage.size.height/2-3), overlayImage.size.width, overlayImage.size.height);
    overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];

    overlayButton.frame =CGRectMake(297, screenRect.size.height-60, closerImage.size.width, closerImage.size.height);

    [overlayButton setImage:closerImage forState:UIControlStateNormal];


    [overlayButton setBackgroundColor:[UIColor clearColor]];


	[overlayButton setUserInteractionEnabled:YES];


    [overlayButton addTarget:self action:@selector(removeOverlay:)  forControlEvents:UIControlEventTouchUpInside];
    [self.mainWebView addSubview:overlayButton];
    [self.mainWebView addSubview:self.overlayimageView];
    [self.mainWebView bringSubviewToFront:overlayButton];

    UILabel *msglabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 5, 240, 34)];
    msglabel.backgroundColor=[UIColor clearColor];
    msglabel.textColor=[UIColor whiteColor];
    [msglabel setFont:[UIFont fontWithName:RepliconFontFamily size:13.0]];
    msglabel.textAlignment=NSTextAlignmentCenter;
    msglabel.text=RPLocalizedString(OVERLAY_MSG, OVERLAY_MSG);
    msglabel.numberOfLines=2;
    [self.overlayimageView addSubview:msglabel];


}

-(void)removeOverlay:(id)sender
{
    [overlayButton removeFromSuperview];
    [self.overlayimageView removeFromSuperview];
}


#pragma mark -
#pragma mark memory management

- (void)viewDidUnload
{
    self.overlayimageView=nil;
}

#pragma mark - <LoginDelegate>

- (void)loginServiceDidFinishLoggingIn:(LoginService *)loginService
{
    [self.spinnerDelegate hideTransparentLoadingOverlay];
}

-(void)handleCookiesResponse
{
    NSString *serviceEndpointRootUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"serviceEndpointRootUrl"];
    NSString *domainName=nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil)
    {

        NSArray *componentsArr=[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] componentsSeparatedByString:@"."];

        if ([componentsArr count]==4)
        {
            domainName=[NSString stringWithFormat:@"https://%@/", [[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString]];
        }
        else
        {
            NSArray *domainArr=[serviceEndpointRootUrl componentsSeparatedByString:@".staging"];

            if ([domainArr count]>1)
            {

                domainName=[[domainArr objectAtIndex:0] stringByAppendingString:@".staging"];

            }
            if (domainName == nil) {
                domainName = [[AppProperties getInstance] getAppPropertyFor: @"StagingDomainName"];
            }

            if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"beta"] || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"] || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"test"]|| [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"sl"] || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"qa"])
            {
                NSArray *domainArr=[serviceEndpointRootUrl componentsSeparatedByString:@".com"];

                if ([domainArr count]>1)
                {

                    domainName=[[domainArr objectAtIndex:0] stringByAppendingString:@".com"];

                }

                if (domainName == nil) {
                    domainName = [[AppProperties getInstance] getAppPropertyFor: @"DomainName"];
                }
            }
        }


    }

    else
    {
        NSArray *domainArr=[serviceEndpointRootUrl componentsSeparatedByString:@".com"];

        if ([domainArr count]>1)
        {

            domainName=[[domainArr objectAtIndex:0] stringByAppendingString:@".com"];

        }

        if (domainName == nil) {
            domainName = [[AppProperties getInstance] getAppPropertyFor: @"DomainName"];
        }

    }


    NSArray* allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:domainName]];



    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:@"cookies" inDatabase:@""];

     [myDB insertCookieData:[NSKeyedArchiver archivedDataWithRootObject:allCookies]];

}

@end
