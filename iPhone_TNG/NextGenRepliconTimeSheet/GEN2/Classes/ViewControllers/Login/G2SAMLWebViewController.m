

#import "G2SAMLWebViewController.h"
#import "G2Constants.h"
#import "G2Util.h"
#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"

@implementation G2SAMLWebViewController

@synthesize webView;
@synthesize urlAddress;
@synthesize userNameField,passwordField;
@synthesize count;
@synthesize userNameStr,passwordStr;
@synthesize indicatorView;
@synthesize overlayimageView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView {
 }
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad. */
- (void)viewDidLoad {
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isInOutTimesheet=FALSE;
    appDelegate.isLockedTimeSheet=FALSE;
//    appDelegate.isAlertOn=FALSE;
    appDelegate.selectedTab=0;
    appDelegate.isShowPunchButton=TRUE;
    appDelegate.isInApprovalsMainPage=FALSE;
    appDelegate.hasApprovalPermissions=FALSE;
    appDelegate.isAtHomeViewController=FALSE;
   
    appDelegate.punchClockIsZeroTimeEntries=TRUE;
    appDelegate.hasTimesheetLicenses=FALSE;
    if (appDelegate.locationController) {
        [appDelegate.locationController.locationManager stopUpdatingLocation];
        appDelegate.isLocationServiceEnabled=FALSE;
    }
    appDelegate.isAttestationPermissionTimesheets=FALSE;
    appDelegate.isAcceptanceOfDisclaimerRequired=FALSE;
    appDelegate.attestationTitleTimesheets=nil;
    appDelegate.attestationDescTimesheets=nil;
    appDelegate.disclaimerTitleTimesheets=nil;
    appDelegate.isUpdatingDisclaimerAcceptanceDate=FALSE;
    appDelegate.isNewInOutTimesheetUser=FALSE;
    appDelegate.isTimeOffEnabled=FALSE;
	
    count=0;
    
	//Create a URL object.
	
	
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieJar = [storage cookies];
    
    for (NSHTTPCookie *cookie in cookieJar)
    {
        [storage deleteCookie:cookie];
    }
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    UIWebView *aWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.webView = aWebView;
   
    aWebView.scalesPageToFit = YES;
     self.webView.autoresizesSubviews = YES;
     self.webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    //set the web view and acceleration delagates for the web view to be itself
    [ self.webView setDelegate:self];
    
    
    [self.view addSubview:self.webView];
    
    UIActivityIndicatorView *tempindicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView=tempindicatorView;
    
    [indicatorView setFrame:CGRectMake(135, 185, 50, 50)];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    [self.webView addSubview:indicatorView];
   
    NSURL *url = [NSURL URLWithString:urlAddress];
   
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    
    
    [webView loadRequest:urlRequest];
    
     [self addOverlay];
	
}

- (void) networkActivated {

    
}

-(void)showAuthenticationRequiredDialog
{    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:RPLocalizedString(AUTHENTICATION_REQUIRED_MESSAGE, AUTHENTICATION_REQUIRED_MESSAGE)];
    [dialog setMessage:@"\n\n\n\n"];
    //[dialog addButtonWithTitle:@"Cancel"];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        [dialog setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    }
    
    [dialog addButtonWithTitle:RPLocalizedString(SUBMIT_BTN_MSG, SUBMIT_BTN_MSG)];
    [dialog setTag:9999];
    //Fix for ios7//JUHI
    if (version>=7.0)
    {
        UITextField *tempuserNameField =[dialog textFieldAtIndex:0];
        self.userNameField=tempuserNameField;
        
	}
    else{
        UITextField *tempuserNameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 50.0, 245.0, 28.0)];
        self.userNameField=tempuserNameField;
       
    }
    
    [self.userNameField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18]];
    self.userNameField.placeholder=RPLocalizedString(USERNAME_MSG, USERNAME_MSG);
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //Fix for ios7//JUHI
    if (version<7.0)
    {
        self.userNameField.borderStyle=UITextBorderStyleRoundedRect;
    }
    self.userNameField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.userNameField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [self.userNameField becomeFirstResponder];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"])
//    {
//        self.userNameField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SSOLoginName"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    [ self.userNameField setBackgroundColor:[UIColor whiteColor]];
    [dialog addSubview: self.userNameField];
    
    
    
    //Fix for ios7//JUHI
    if (version>=7.0)
    {
        UITextField *temppasswordField =[dialog textFieldAtIndex:1];
        self.passwordField=temppasswordField;
        
	}
    else{
        UITextField *temppasswordField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 95.0, 245.0, 28.0)];
        self.passwordField=temppasswordField;
       
    }
    
    
    [self.passwordField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18]];
    self.passwordField.placeholder=RPLocalizedString(PASSWORD_MSG, PASSWORD_MSG);
    self.passwordField.secureTextEntry=TRUE;
    self.passwordField.autocorrectionType=UITextAutocorrectionTypeNo;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //Fix for ios7//JUHI
    if (version<7.0)
    {
        self.passwordField.borderStyle=UITextBorderStyleRoundedRect;
    }
    
    [ self.passwordField setBackgroundColor:[UIColor whiteColor]];
    self.passwordField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [dialog addSubview: self.passwordField];
    //CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 100.0);
    //[dialog setTransform: moveUp];
    [dialog show];
   
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isPopUpForSAMLAuthentication=TRUE;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 9999)
    {
        
        if (self.userNameField.text==nil || [[self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] isEqualToString:@""] || self.passwordField.text==nil || [[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] isEqualToString:@""] ) 
        {
            UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(InvaliDLogin,InvaliDLogin) delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
            loginAlertView.tag=9998;
            [loginAlertView show];
            
            return;
        }
        self.userNameStr=self.userNameField.text;
        self.passwordStr= self.passwordField.text;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameStr forKey:@"TempSSOLoginName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[hackChallenge sender] useCredential:[NSURLCredential credentialWithUser:self.userNameStr password:self.passwordStr persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:hackChallenge];
        
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        appDelegate.isPopUpForSAMLAuthentication=FALSE;
        
    }
    
    else if (alertView.tag == 9998)
    {
        [self.webView stopLoading];
        [self.webView removeFromSuperview];
        self.webView=nil;
        [self.view removeFromSuperview];
         [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
//    self.webView=nil;
   
    self.overlayimageView=nil;
    
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    DLog(@"Did start loading: %@ auth:%d", [[request URL] absoluteString], _authed);
    
    if (!_authed || count==1) {
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

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    DLog(@"got auth challange");
    
    
    if ([[challenge.protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    } 
   else if ([challenge previousFailureCount] == 0) {
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
        
        
    } else {
        UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(InvaliDLogin,InvaliDLogin) delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
        loginAlertView.tag=9998;
        [loginAlertView show];
        
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    DLog(@"received response via nsurlconnection");
    

//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//    int status = [httpResponse statusCode];
    
//    DLog(@"HTTP STATUS :: %d",status);
    
    _authed = YES;
    /** THIS IS WHERE YOU SET MAKE THE NEW REQUEST TO UIWebView, which will use the new saved auth info **/
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
    
    [self.webView loadRequest:urlRequest];
    
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
    return NO;
}



- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {	
	return YES;
}  


- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isAlertOn=FALSE;
    
    DLog(@"webViewDidFinishLoad");
    NSLog(@"%@",_webView.request.URL);
//    NSString* theStatus = [[WebView request] valueForHTTPHeaderField:@"Status"];
//    DLog(@"HTTP STATUS CODE ::: %@",theStatus);
    
    if ([self.indicatorView isAnimating])
    {
        [self.indicatorView stopAnimating];
       
    }
   
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:urlAddress]];
    NSEnumerator *enumerator = [cookies objectEnumerator];
   
    
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
	[[NSUserDefaults standardUserDefaults] setObject:headers forKey:@"SSOCookies"];
    DLog(@"%@",headers);
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    count++;
    BOOL isReachedCookiesExtractPoint=FALSE;
    NSHTTPCookie *cookie;
    NSString *userName=nil;
    while (cookie = [enumerator nextObject]) {
        DLog(@"COOKIE{name: %@, value: %@}", [cookie name], [cookie value]);
        if ([[cookie name] isEqualToString:@"CURRENTUSER"]) 
        {
            isReachedCookiesExtractPoint=TRUE;
            userName=[cookie value];
        }
        
    }
    
    
    if (isReachedCookiesExtractPoint && userName!=nil) {
        [self.webView stopLoading];
        [self.webView removeFromSuperview];
        self.webView=nil;
        [self.view removeFromSuperview];
       
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
        G2LoginService *loginService=[G2RepliconServiceManager loginService];
        [[G2TransitionPageViewController getInstance] setDelegate: loginService];
        [loginService sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:loginService forUsername:userName];
        
    }
    
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
     DLog(@"didFailLoadWithError");
    if ([error code]==-1202) {
        UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(InvaliDLogin,InvaliDLogin) delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
        loginAlertView.tag=9998;
        [loginAlertView show];
      
    }

}

//- (void)webView:(UIWebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
//    DLog(@"didFinishLoadForFrame");
//}

-(void)addOverlay
{
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIImage *overlayImage=[G2Util thumbnailImage:G2overlay_image];
    UIImage *closerImage=[G2Util thumbnailImage:G2closer_image];
    UIImageView *tempOverlayImageView= [[UIImageView alloc]initWithImage:overlayImage];
    self.overlayimageView=tempOverlayImageView;
   
    //JUHI
   //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    CGRect overlayimageViewFrame;
    if (version>=7.0)
    {
        overlayimageViewFrame=CGRectMake(0, screenRect.size.height-44, overlayImage.size.width, overlayImage.size.height);
	}
    else{
        overlayimageViewFrame=CGRectMake(0, screenRect.size.height-overlayImage.size.height-(overlayImage.size.height/2-3), overlayImage.size.width, overlayImage.size.height);
	}
    self.overlayimageView.frame =overlayimageViewFrame;
    overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //JUHI
   //Fix for ios7//JUHI
    CGRect overlayButtonFrame;
    if (version>=7.0)
    {
        overlayButtonFrame=CGRectMake(297, screenRect.size.height-34, closerImage.size.width, closerImage.size.height);
    }
    else{
        overlayButtonFrame=CGRectMake(297, screenRect.size.height-60, closerImage.size.width, closerImage.size.height);
    }
    overlayButton.frame =overlayButtonFrame;
    
    [overlayButton setImage:closerImage forState:UIControlStateNormal];
    
    
    [overlayButton setBackgroundColor:[UIColor clearColor]];
    
	
	[overlayButton setUserInteractionEnabled:YES];
    
    
    [overlayButton addTarget:self action:@selector(removeOverlay:)  forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:overlayButton];
    [self.webView addSubview:self.overlayimageView];
    [self.webView bringSubviewToFront:overlayButton];
    
    UILabel *msglabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 5, 240, 34)];
    msglabel.backgroundColor=[UIColor clearColor];
    msglabel.textColor=[UIColor whiteColor];
    [msglabel setFont:[UIFont fontWithName:RepliconFontFamily size:13.0]];
    msglabel.textAlignment=NSTextAlignmentCenter;
    msglabel.text=RPLocalizedString(OVERLAY_MSG, OVERLAY_MSG);
    msglabel.numberOfLines=2;
    [self.overlayimageView addSubview:msglabel];
   
    
}
-(void)removeOverlay:(id)sender{
    [overlayButton removeFromSuperview];
    [self.overlayimageView removeFromSuperview];
}





@end
