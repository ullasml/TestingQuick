#import "MoreViewController.h"
#import "Constants.h"
#import "Util.h"
#import "AppDelegate.h"
#import "FrameworkImport.h"
#import "ACSimpleKeychain.h"
#import "DoorKeeper.h"
#import "LaunchLoginDelegate.h"
#import "RepliconServiceManager.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "PunchOutboxStorage.h"
#import "Theme.h"
#import "DefaultTheme.h"
#import "ButtonStylist.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ErrorBannerViewController.h"
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import <repliconkit/repliconkit.h>
#import "SSZipArchive.h"
#import <repliconkit/AppConfigRepository.h>
#import <KSDeferred/KSDeferred.h>
#import <repliconkit/AppConfig.h>
#import "MobileAppConfigRequestProvider.h"
#import "LoginModel.h"

@interface MoreViewController ()

@property (nonatomic) UIButton *logOutButton;

@property (nonatomic) id<LaunchLoginDelegate> launchLoginDelegate;
@property (nonatomic) PersistedSettingsStorage *persistedSettingsStorage;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) AppConfigRepository *appConfigRepository;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) PunchOutboxStorage *outbox;
@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) UISwitch *nodeSwitch;
@property (nonatomic) UILabel *nodeLabel;
@property (nonatomic) AppConfig *appConfig;
@property (nonatomic) MobileAppConfigRequestProvider *mobileAppConfigRequestProvider;
@property (nonatomic) LoginModel *loginModel;
@end


@implementation MoreViewController

@synthesize leftButton;
@synthesize mailBtn;
@synthesize debugDescLabel;
@synthesize debugModeLabel;
@synthesize versionLabel;
@synthesize versionLabelValue;
@synthesize scrollView;
@synthesize DebugLineImageView;

- (instancetype)initWithAppConfigRequestProvider:(MobileAppConfigRequestProvider *)mobileAppConfigRequestProvider
                             launchLoginDelegate:(id <LaunchLoginDelegate>)launchLoginDelegate
                             appConfigRepository:(AppConfigRepository *)appConfigRepository
                                       appConfig:(AppConfig *)appConfig
                             reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                    userDefaults:(NSUserDefaults *)userDefaults
                                     appDelegate:(AppDelegate *)appDelegate
                                      doorKeeper:(DoorKeeper *)doorKeeper
                                          outbox:(PunchOutboxStorage *)outbox
                                      loginModel:(LoginModel *)loginModel{
    self = [super init];
    if (self)
    {
        self.outbox = outbox;
        self.doorKeeper = doorKeeper;
        self.appDelegate = appDelegate;
        self.userDefaults = userDefaults;
        self.launchLoginDelegate = launchLoginDelegate;
        self.reachabilityMonitor = reachabilityMonitor;
        self.appConfigRepository = appConfigRepository;
        self.mobileAppConfigRequestProvider = mobileAppConfigRequestProvider;
        self.appConfig = appConfig;
        self.loginModel = loginModel;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    [Util setToolbarLabel: self withText: RPLocalizedString(MoreTabbarTitle, MoreTabbarTitle)];
    
    UIScrollView *tempScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView=tempScrollView;
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator=YES;
    scrollView.backgroundColor = [UIColor clearColor];
    
    float y_Offset=0.0;
    float height=(screenRect.size.height/screenRect.size.width)*17.64;
    
    y_Offset=(screenRect.size.height/screenRect.size.width)*22.29;
    
    id<Theme> theme = [[DefaultTheme alloc] init];
    ButtonStylist *buttonStylist = [[ButtonStylist alloc] initWithTheme:theme];
    CGFloat standardButtonHeight = 44;
    CGFloat standardButtonWidth = 240;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat standardButtonXOffset = (screenWidth  - standardButtonWidth)/2;
    
    self.logOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.logOutButton.frame = CGRectMake(standardButtonXOffset, y_Offset, standardButtonWidth, standardButtonHeight);
    [self.logOutButton setAccessibilityLabel:@"logout_button"];
    
    [buttonStylist styleButton:self.logOutButton
                         title:RPLocalizedString(@"Logout", @"Logout")
                    titleColor:[theme logoutButtonTitleColor]
               backgroundColor:nil
                   borderColor:[theme standardButtonBorderColor]];
    
    
    [self.logOutButton addTarget:self action:@selector(logoutClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:self.logOutButton];
    
    y_Offset = self.logOutButton.frame.size.height+self.logOutButton.frame.origin.y+(screenRect.size.height/screenRect.size.width)*17.64;
    
    //LOWER IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,y_Offset, SCREEN_WIDTH,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [scrollView addSubview:lineImageView];
    
    y_Offset=y_Offset+(screenRect.size.height/screenRect.size.width)*19.29;
    
    UIButton *feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    feedbackButton.frame = CGRectMake(standardButtonXOffset, y_Offset, standardButtonWidth, standardButtonHeight);
    [buttonStylist styleButton:feedbackButton
                         title:RPLocalizedString(@"Send Feedback", @"Send Feedback")
                    titleColor:[theme sendFeedbackButtonTitleColor]
               backgroundColor:nil
                   borderColor:[theme standardButtonBorderColor]];
    
    
    [feedbackButton addTarget:self action:@selector(sendFeedbackClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:feedbackButton];
    
    y_Offset=standardButtonHeight+feedbackButton.frame.origin.y+(screenRect.size.height/screenRect.size.width)*17.64;
    
    UIImageView *lineLowerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,y_Offset, SCREEN_WIDTH,lowerImage.size.height)];
    [lineLowerImageView setImage:lowerImage];
    [scrollView addSubview:lineLowerImageView];
    
    
    y_Offset=y_Offset+(screenRect.size.height/screenRect.size.width)*19.29;
    
    self.mailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.mailBtn.frame = CGRectMake(standardButtonXOffset, y_Offset , standardButtonWidth, standardButtonHeight);
    [buttonStylist styleButton:self.mailBtn
                         title:RPLocalizedString(SEND_LOG_FILE_TEXT, SEND_LOG_FILE_TEXT)
                    titleColor:[theme sendFeedbackButtonTitleColor]
               backgroundColor:nil
                   borderColor:[theme standardButtonBorderColor]];
    
    
    [self.mailBtn addTarget:self action:@selector(mailLogFile:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:self.mailBtn];
    
    y_Offset=y_Offset+standardButtonHeight+(screenRect.size.height/screenRect.size.width)*19.29;
    
    
    DebugLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,y_Offset, SCREEN_WIDTH,lowerImage.size.height)];
    [DebugLineImageView setImage:lowerImage];
    [scrollView addSubview:DebugLineImageView];
    
    
    self.nodeLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, y_Offset + 10.0, screenRect.size.width - 170.0, height)];
    self.nodeLabel.text=[NSString stringWithFormat:@"NodeJS"];
    self.nodeLabel.textAlignment=NSTextAlignmentLeft;
    self.nodeLabel.textColor=[theme nodeJSTitleColor];
    self.nodeLabel.font=[UIFont systemFontOfSize:16.0];
    self.nodeLabel.backgroundColor=[UIColor clearColor];
   
    [scrollView addSubview:self.nodeLabel];
    
    self.nodeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenRect.size.width - 100.0, y_Offset + 10.0, 70.0, 70.0)];
    self.nodeSwitch.backgroundColor = [UIColor clearColor];
    [self.nodeSwitch addTarget:self
                        action:@selector(switchChanged:)
              forControlEvents:UIControlEventValueChanged];
   
    [self.scrollView addSubview:self.nodeSwitch];
    
    y_Offset=(screenRect.size.height/screenRect.size.width)*226.66;
    
    
    NSArray *userArray = [self.loginModel getAllUserDetailsInfoFromDb];
    if (userArray.count>0)
    {
        NSString *loggedInString = @"Logged in as: ";
        NSString *userDisplayText = userArray[0][@"displayText"];
        NSString *labelText = [NSString stringWithFormat:@"%@%@",loggedInString,userDisplayText];
        
        NSRange range1 = [labelText rangeOfString:loggedInString];
        NSRange range2 = [labelText rangeOfString:userDisplayText];
        
        NSMutableAttributedString *attributedLabelText = [[NSMutableAttributedString alloc] initWithString:labelText];
        [attributedLabelText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} range:range1];
        [attributedLabelText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]} range:range2];
        
        
        versionLabel=[[UILabel alloc]init];
        versionLabel.attributedText=attributedLabelText;
        versionLabel.frame=CGRectMake(10, y_Offset, self.view.frame.size.width-20, height);
        versionLabel.textAlignment=NSTextAlignmentCenter;
        versionLabel.textColor=[UIColor darkGrayColor];
        versionLabel.backgroundColor=[UIColor clearColor];
        [scrollView addSubview:versionLabel];
    }
    
    
    versionLabelValue=[[UILabel alloc]init];
    versionLabelValue.text=[NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    versionLabelValue.frame=CGRectMake(0, y_Offset+20.0, self.view.frame.size.width, height);
    versionLabelValue.textAlignment=NSTextAlignmentCenter;
    versionLabelValue.textColor=[UIColor darkGrayColor];
    versionLabelValue.font=[UIFont systemFontOfSize:12.0];
    versionLabelValue.backgroundColor=[UIColor clearColor];
    [scrollView addSubview:versionLabelValue];
    
    
    
    if (LogUtil.debugMode == TRUE)
    {
        versionLabel.frame=CGRectMake(0, DebugLineImageView.frame.size.height+DebugLineImageView.frame.origin.y+25, self.view.frame.size.width, versionLabel.frame.size.height);
        versionLabelValue.frame=CGRectMake(0, DebugLineImageView.frame.size.height+DebugLineImageView.frame.origin.y+25+20.0, self.view.frame.size.width, versionLabelValue.frame.size.height);
        
    }
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width,versionLabelValue.frame.origin.y+versionLabelValue.frame.size.height+120);
    
    
    UITapGestureRecognizer *sevenTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSevenTaps)];
    sevenTap.numberOfTapsRequired = 7;
    [self.view addGestureRecognizer:sevenTap];
    
    [self.view addSubview:scrollView];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.nodeSwitch.hidden = YES;
    self.nodeLabel.hidden =  YES;
    [self.nodeSwitch setOn:[self.appConfig getNodeBackend]];
    
    ErrorBannerViewParentPresenterHelper * errorBannerViewParentPresenterHelper = [self.appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    [errorBannerViewParentPresenterHelper setScrollViewInsetWithErrorBannerPresentation:self.scrollView];
}


-(void)logoutClicked:(id)sender
{
    NSArray *unSyncedPunches = [self.outbox allPunches];
    if ([unSyncedPunches count]>0) {
        
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(@"Some of your punch data has not been saved on the Replicon server.  Please ensure your device has an Internet connection to sync the data.", @"")
                                                  title:nil
                                                    tag:LONG_MIN];
    }
    else
    {
        CLS_LOG(@"-----Logout action on MoreViewController -----");
        if ([[self.userDefaults objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGOUT_RESPONSE_NOTIFICATION object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutResponse:)
                                                         name:LOGOUT_RESPONSE_NOTIFICATION
                                                       object:nil];
        }
        else
        {
            BOOL isRememberMe = [self.userDefaults boolForKey:@"RememberMe"];
            if (isRememberMe)
            {
                [self.launchLoginDelegate launchLoginViewController:YES];
            }
            else{
                [self.launchLoginDelegate launchLoginViewController:NO];
            }
        }
        if ([self.reachabilityMonitor isNetworkReachable] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        
        [self.doorKeeper logOut];
        
        [[RepliconServiceManager loginService]sendrequestToLogOut];
        if (self.appDelegate.locationManagerTemp!=nil)
        {
            [self.appDelegate.locationManagerTemp stopUpdatingLocation];
            self.appDelegate.locationManagerTemp.delegate=nil;
        }
    }
}

-(void)reviewAppClicked{
    
    if ( [NetworkMonitor isNetworkAvailableForListener:self] == YES)  {
        
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(REVIEW_APP_NO_OPTION, REVIEW_APP_NO_OPTION)
                                       otherButtonTitle:RPLocalizedString(REVIEW_APP_YES_OPTION, REVIEW_APP_YES_OPTION)
                                               delegate:self
                                                message:RPLocalizedString(REVIEW_APP_MSG, REVIEW_APP_MSG)
                                                  title:nil
                                                    tag:1000];
        
        
    }
    else {
        
        [Util showOfflineAlert];
        return;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==1000)
    {
        if (buttonIndex==1)
        {
            CLS_LOG(@"-----Review App action on MoreViewController -----");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[AppProperties getInstance] getAppPropertyFor: @"itunesAppUrl"]]];
        }
        
    }
    
}
-(void)sendFeedbackClicked:(id)sender
{
    if ([MFMailComposeViewController canSendMail] == NO) {
        
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Close", @"Close")
                                       otherButtonTitle:nil
                                               delegate:nil
                                                message:RPLocalizedString(@"This device is not configured for sending mail", @"This device is not configured for sending mail")
                                                  title:nil
                                                    tag:LONG_MIN];
        
        
        return;
    }
    CLS_LOG(@"-----Send feedback for App action on MoreViewController -----");
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *emailSubject=nil;
    NSString *companyName=nil;
    NSString *companyDetails=nil;
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials =  nil;
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]])
        {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
        }
    }
    emailSubject=[RPLocalizedString(EMAIL_SUBJECT, "")  stringByAppendingString:version];
    
    if (companyName!=nil)
    {
        companyDetails=[RPLocalizedString(COMPANY_NAME, "") stringByAppendingFormat:@": %@",companyName];
        emailSubject=[NSString stringWithFormat:@"%@, %@",emailSubject,companyDetails];
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
    
    
    
}

-(void)mailLogFile:(id)sender
{
    if ([MFMailComposeViewController canSendMail] == NO) {
        
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Close", @"Close")
                                       otherButtonTitle:nil
                                               delegate:nil
                                                message:RPLocalizedString(@"This device is not configured for sending mail", @"This device is not configured for sending mail")
                                                  title:nil
                                                    tag:LONG_MIN];
        
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/logs"];
    BOOL isSuccess = [self zipDirectoryforPath:filePath];
    NSString *zipFilePath = [documentsDirectory stringByAppendingString:@"/logs.zip"];
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [picker setSubject:[RPLocalizedString(@"Log for v", "")   stringByAppendingString:version]];
    [picker setToRecipients:[NSArray arrayWithObject:RECIPENT_ADDRESS]];
    if (isSuccess)
    {
        NSData *myData = [NSData dataWithContentsOfFile:zipFilePath];
        
        if (myData)
        {
            [picker addAttachmentData:myData mimeType:@"application/zip" fileName:@"logs.zip"];
        }
    }
    
    //MOBI-811 Ullas M l
    NSString *messageBody=[Util getEmailBodyWithDetails];
    [picker setMessageBody:messageBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:zipFilePath error:&error];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
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
            
            
        }
            
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)goBack:(id)sender
{
    
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)];
}

-(void)doneAction:(id)sender
{
    CLS_LOG(@"-----Done action on MoreViewController -----");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logOutResponse : (NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGOUT_RESPONSE_NOTIFICATION object:nil];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL isRememberMe=[defaults boolForKey:@"RememberMe"];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"] || !isRememberMe)
    {
        [self.appDelegate launchLoginViewController:NO];
        
    }
    else
    {
        [self.appDelegate launchLoginViewController:YES];
    }
}

-(void)switchChanged:(UISwitch*)sender
{
    [self.appConfig setNodeBackend:[sender isOn]];
}


-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
}

- (BOOL)zipDirectoryforPath:(NSString *)docDirectory
{
    BOOL isDir=NO;
    BOOL successCompressing = NO;
    NSString *exportPath = docDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir)
    {
        NSString *archivePath = [docDirectory stringByAppendingString:@".zip"];
        successCompressing = [SSZipArchive createZipFileAtPath:archivePath withContentsOfDirectory:exportPath withPassword:@"replico^666"];
    }
    
    
    
    
    return successCompressing;
}

-(void)doSevenTaps
{
    KSPromise *promise = [self.appConfigRepository appConfigForRequest:[self.mobileAppConfigRequestProvider getRequest]];
    if (promise != nil) {
        [self.appDelegate showTransparentLoadingOverlay];
        [promise then:^id(NSDictionary *appConfigDictionary) {
            [self.appDelegate hideTransparentLoadingOverlay];
            [self enableNodeSwitch];
            return nil;
        } error:^id(NSError *error) {
            [self.appDelegate hideTransparentLoadingOverlay];
            [self enableNodeSwitch];
            return nil;
        }];
    }
    else{
        [self enableNodeSwitch];
    }
}

-(void)enableNodeSwitch
{
    self.nodeSwitch.hidden = NO;
    self.nodeLabel.hidden = NO;
    [self.nodeSwitch setOn:[self.appConfig getNodeBackend]];
}

#pragma mark -
#pragma mark NetworkMonitor related

- (void) networkActivated
{
}


@end
