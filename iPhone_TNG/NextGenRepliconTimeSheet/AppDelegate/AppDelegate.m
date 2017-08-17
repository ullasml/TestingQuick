#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "SupervisorDashboardNavigationController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "BookedTimeOffNavigationController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "PunchHistoryNavigationController.h"
#import "AttendanceNavigationController.h"
#import "ListOfTimeSheetsViewController.h"
#import "ApprovalsNavigationController.h"
#import "LoginNavigationViewController.h"
#import "PunchHomeNavigationController.h"
#import "SupervisorDashboardController.h"
#import "TimesheetNavigationController.h"
#import "ApprovalsCountViewController.h"
#import "ExpensesNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "TimesheetMainPageController.h"
#import "ShiftsNavigationController.h"
#import "AttendanceViewController.h"
#import "LoginCredentialsHelper.h"
#import "ReceiptsViewController.h"
#import "UserPermissionsStorage.h"
#import "PunchUserDeserializer.h"
#import "TabModuleNameProvider.h"
#import "WelcomeViewController.h"
#import "NavigationBarStylist.h"
#import "BreakTypeRepository.h"
#import "PunchHomeController.h"
#import "PunchRequestHandler.h"
#import "URLSessionListener.h"
#import "AstroUserDetector.h"
#import "ACSimpleKeychain.h"
#import "InjectorProvider.h"
#import "KeychainProvider.h"
#import "PunchRevitalizer.h"
#import "SupportDataModel.h"
#import "PunchRepository.h"
#import "RepliconClient.h"
#import "ModuleStorage.h"
#import "DefaultTheme.h"
#import "InjectorKeys.h"
#import "LoginService.h"
#import "AppDelegate.h"
#import "PunchClock.h"
#import "FrameworkImport.h"
#import <Blindside/Blindside.h>
#import "SNLog.h"
#import "EventTracker.h"
#import "Util.h"
#import "ServerMostRecentPunchProtocol.h"
#import "BaseSyncOperationManager.h"
#import "WelcomeFlowControllerProvider.h"
#import "DefaultActivityStorage.h"
#import "OEFDeserializer.h"
#import "FrameworkImport.h"
#import "TimesheetStorage.h"
#import "SyncNotificationScheduler.h"
#import "ErrorBannerViewController.h"
#import "ErrorDetailsViewController.h"
#import <repliconkit/repliconkit.h>
#import "MobileLoggerWrapperUtil.h"
#import "PunchNotificationScheduler.h"
#import "UIAlertView+Dismiss.h"
#import "OEFTypeStorage.h"
#import "PunchErrorPresenter.h"
#import "ObjectExtensionFieldLimitDeserializer.h"
#import "AppPersistentStorage.h"
#import <repliconkit/AppConfigRepository.h>
#import "MobileAppConfigRequestProvider.h"


void trackCrashInGA(NSException *exception) {
    id<BSInjector, BSBinder> injector = [InjectorProvider injector];
    GATracker *gaTracker = [injector getInstance:[GATracker class]];
    [gaTracker trackCrash:exception];
}

void uncaughtExceptionHandler(NSException *exception) {
    @try {
        NSString *userID=nil;
        NSString *companyName=nil;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"]isKindOfClass:[NSNull class] ])
        {
            userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
        }

        // MOBI-471
        ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
        if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
            NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
            if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                companyName = [credentials valueForKey:ACKeychainCompanyName];
            }
        }

        NSString *platform = [[UIDevice currentDevice] model];
        NSString *version = [[UIDevice currentDevice] systemVersion];


        NSArray *backtraceArray = [exception callStackSymbols];

        NSMutableString *backtrace = [NSMutableString stringWithUTF8String:""];


        for (id entry in backtraceArray) {

            NSRange testRange = [entry rangeOfString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];

            if (testRange.length) {


                [backtrace appendString:entry];

            }
        }
        [backtrace componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];

        NSString *message = [NSString stringWithFormat:@"CName:%@,UId:%@,%@,D:%@,O:%@. " ,companyName,userID,backtrace ? backtrace : @"no matching backtrace",platform,version];

        [EventTracker.sharedInstance logError:@"uncaught"
                                      message:message
                                    exception:exception];

        trackCrashInGA(exception);

        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"CRASH CAUGHT :: MESSAGE--- %@ ::: EXCEPTION--- %@",message,exception] forLogLevel:LoggerCocoaLumberjack];


        [SNLog Log:201 withFormat:[NSString stringWithFormat:@"CRASH CAUGHT :: MESSAGE--- %@ ::: EXCEPTION--- %@",message,exception]];

        [Util logCacheDefaults];

    }
    @catch (NSException *exception) {
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"CRASH CAUGHT :: EXCEPTION--- %@",exception] forLogLevel:LoggerCocoaLumberjack];


        [EventTracker.sharedInstance logError:@"uncaught"
                                      message:@"whoa!  could not handle uncaught exception!"
                                    exception:exception];

        trackCrashInGA(exception);

        DLog(@"whoa!  could not handle uncaught exception!");
    }
}



@interface AppDelegate () <NSURLSessionDelegate>

@property (nonatomic) PunchOutboxQueueCoordinator *punchOutboxQueueCoordinator;
@property (nonatomic) ModuleStorage *moduleStorage;
@property (nonatomic) TabProvider *tabProvider;
@property (nonatomic) BreakTypeRepository *breakTypeRepository;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) URLSessionListener *backgroundURLSessionObserver;
@property (nonatomic) PunchRequestHandler *punchRequestHandler;
@property (nonatomic) PunchRevitalizer *punchRevitalizer;
@property (nonatomic) UITabBarController *rootTabBarController;
@property (nonatomic) ModulesGATracker *modulesGATracker;
@property (nonatomic) TimesheetStorage *timesheetStorage;
@property (nonatomic) id<UserSession>userSession;
@property (nonatomic) PunchErrorPresenter *punchErrorPresenter;
@property (nonatomic) MobileAppConfigRequestProvider *mobileAppConfigRequestProvider;
@property (nonatomic) EMMConfigManager *emmConfigManager;
@property (nonatomic) id<BSInjector> injector;
@end


@implementation AppDelegate
@synthesize thumbnailCache;
@synthesize loginViewController;
@synthesize progressView;
@synthesize isNotFirstTimeLaunch;
@synthesize navController;
@synthesize indicatorView;
@synthesize syncTimer;
@synthesize isShowTimeSheetPlaceHolder,isShowExpenseSheetPlaceHolder,isShowTimeOffSheetPlaceHolder;
@synthesize  isCountPendingSheetsRequestInQueue;
@synthesize currVisibleViewController;
@synthesize peristedLocalizableStringsDict;
@synthesize deepLinkingLaunchModule;
@synthesize deepLinkingTimer;
@synthesize resetPasswordViewController;
@synthesize appRatingViewController;
@synthesize deviceID;
static BOOL imageMemoryWarningShown = NO;
@synthesize trackTimeIconImgView;
@synthesize locationManagerTemp;
@synthesize beaconsCtrl;
@synthesize isAppInForeground;
@synthesize selectedModuleName;

#define Image_Alert_tag_Add 50

#define dataSyncTable @"DataSyncDetails"

#pragma mark -
#pragma mark Application lifecycle delegates

- (instancetype)init {
    if(self = [super init])
    {
        self.injector = [InjectorProvider injector];

        self.standardUserDefaults = [self.injector getInstance:InjectorKeyStandardUserDefaults];
        self.userPermissionsStorage = [self.injector getInstance:[UserPermissionsStorage class]];
        self.defaultActivityStorage = [self.injector getInstance:[DefaultActivityStorage class]];
        self.keychainProvider = [self.injector getInstance:[KeychainProvider class]];
        self.syncNotificationScheduler = [self.injector getInstance:[SyncNotificationScheduler class]];
        self.punchNotificationScheduler = [self.injector getInstance:[PunchNotificationScheduler class]];
        self.userSession = [self.injector getInstance:@protocol(UserSession)];
    }

    return self;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.breakTypeRepository = [self.injector getInstance:[BreakTypeRepository class]];
    self.loginService = [RepliconServiceManager loginService];
    self.loginService.breakTypeRepository = self.breakTypeRepository;
    self.timesheetStorage = [self.injector getInstance:[TimesheetStorage class]];
    self.punchOutboxQueueCoordinator = [self.injector getInstance:[PunchOutboxQueueCoordinator class]];
    self.reachabilityMonitor = [self.injector getInstance:[ReachabilityMonitor class]];
    __weak id this = self;
    [self.reachabilityMonitor addObserver:this];
    self.moduleStorage = [self.injector getInstance:[ModuleStorage class]];
    self.tabProvider = [self.injector getInstance:[TabProvider class]];
    self.backgroundURLSessionObserver = [self.injector getInstance:[URLSessionListener class]];
    self.punchRequestHandler = [self.injector getInstance:[PunchRequestHandler class]];
    self.punchRevitalizer = [self.injector getInstance:[PunchRevitalizer class]];
    self.modulesGATracker = [self.injector getInstance:[ModulesGATracker class]];
    self.punchErrorPresenter = [self.injector getInstance:[PunchErrorPresenter class]];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupPersistentDataStoreForApp];

    CLS_LOG(@"-----application didFinishLaunchingWithOptions -----");

     [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"oldMostRecentPunchData"];

    //START LOG CAPTURE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MOBILE_APP"];
    [LogUtil setup];
    ///SHould be set to no always to avoid DB logging
    [LogUtil setDebugMode:NO];
    [LogUtilAbstractWrapper setDelegate:[MobileLoggerWrapperUtil class]];

    // Configure Event tracker
    [EventTracker.sharedInstance start];

    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor whiteColor];//[Util colorWithHex:@"#f9f9f9" alpha:1.0];
    }
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];

    if (notification)
    {
        NSDictionary *userInfo=notification.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"uid"]];
        if ([uid isEqualToString:@"ErrorBackgroundStatus"])
        {
            self.isWaitingForDeepLinkToErrorDetails = YES;
            //Cancelling local notification
            [self.syncNotificationScheduler cancelNotification:uid];

        }
    }

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];

    
    // Initialize GoogleAnalytics
    self.tracker = [self.injector getInstance:[GATracker class]];
    self.loginCredentialsHelper = [self.injector getInstance:[LoginCredentialsHelper class]];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    [self.standardUserDefaults removeObjectForKey:@"iBeaconActivated"];

    NSDictionary *credDict = [self.standardUserDefaults objectForKey:@"credentials"];
    if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
        // MOBI-471
        ACSimpleKeychain *keychain = [self.keychainProvider provideInstance];
        NSString *companyName = [[credDict objectForKey:@"companyName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        companyName=[companyName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *userName = [credDict objectForKey:@"userName"];
        NSString *password = [credDict objectForKey:@"password"];
        if ([keychain storeUsername:userName password:password companyName:companyName forService:@"repliconUserCredentials"]) {
            NSLog(@"**SAVED**");
            [self.standardUserDefaults removeObjectForKey:@"credentials"];
        }
    }



    [Crashlytics startWithAPIKey:@"9a20a18b13ce00e6dba30b046bc1244ccdc8a78b"];

    if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK)
    {
        NSLog(@"Can now use sqlite on multiple threads, using the same connection");
    }


    NSMutableDictionary *tempThumbnailCache=[[NSMutableDictionary alloc]init];
    self.thumbnailCache=tempThumbnailCache;


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValue:)
                                                 name:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION
                                               object:nil];


    // Set up network monitoring
    [NetworkMonitor sharedInstance];

    [self loadCookie];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    // TODO: Use Utils for getting documents directory?
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    SNFileLogger *logger = [[SNFileLogger alloc] initWithPathAndSize:[documentsDirectory stringByAppendingFormat:@"/currentlog.txt"] forSize:10000000000000];
    [[SNLog logManager] addLogStrategy:logger];

    [self resetLocalisedFilesAtStart:NO];

    NSLog(@"localeIdentifier: %@", [[NSLocale currentLocale] localeIdentifier]);

    NSArray *previouscustomTermsSummary= [self.standardUserDefaults objectForKey:@"customTermsSummary"];

    [self resetLocalisedFilesAtStart:NO];
    if ([previouscustomTermsSummary count] > 0) {
        [self AddCapabilityToDisplayRenamedLabelsInMobileApps:previouscustomTermsSummary];
    }

    NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [applicationDocumentsDir stringByAppendingPathComponent:@"Localizable.strings"];

    self.peristedLocalizableStringsDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];

    [self launchViewForFirstTimeLoad];

    application.statusBarStyle = UIStatusBarStyleDefault;

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:userNotificationSettings];
    } else {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
        [application registerForRemoteNotifications];
    }


    if (TARGET_IPHONE_SIMULATOR) {

        NSArray* filePathArr =
        [documentsDirectory componentsSeparatedByString:@"/Library"];
        if ([filePathArr count] > 1) {
            NSString* toFile = [NSString
                                stringWithFormat:@"%@/XCodePaths/lastBuild.txt", filePathArr[0]];

            NSError* error;

            NSString* filePathAndDirectory =
            [NSString stringWithFormat:@"%@/XCodePaths", filePathArr[0]];

            if (![[NSFileManager defaultManager]
                  createDirectoryAtPath:filePathAndDirectory
                  withIntermediateDirectories:NO
                  attributes:nil
                  error:&error]) {
                NSLog(@"Create directory error: %@", error);
            }

            NSError* err = nil;

            [documentsDirectory writeToFile:toFile
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:&err];

            if (err)
                NSLog(@"%@", [err localizedDescription]);

            NSString* appName =
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

            NSString* aliasPath = [NSString
                                   stringWithFormat:@"%@/XCodePaths/%@", filePathArr[0], appName];

            remove([aliasPath UTF8String]);

            [[NSFileManager defaultManager]
             createSymbolicLinkAtPath:aliasPath
             withDestinationPath:documentsDirectory
             error:nil];
        }
    }

    // test snippets for debugging push notifications deep link in simulator
    /*
     [NSTimer scheduledTimerWithTimeInterval: 10.0
     target: self
     selector:@selector(simulatePush)
     userInfo: nil repeats:YES];


     */

    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    // Refresh all inflight saves which might have stopped on last app termination to sync back again
    TimesheetModel *timesheetModel = [[TimesheetModel alloc] init];
    [timesheetModel refreshAllInFlightSaveOperationsforAllTimesheets];


    [[self.injector getInstance:[BaseSyncOperationManager class]] startSync];

    self.mobileAppConfigRequestProvider = [self.injector getInstance:[MobileAppConfigRequestProvider class]];
    [self getAppConfiguration];
    
    return YES;
}

-(void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application{
    [NSUserDefaults resetStandardUserDefaults];
    CLS_LOG(@"------applicationProtectedDataDidBecomeAvailable-----");
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{
      CLS_LOG(@"------applicationProtectedDataWillBecomeUnavailable-----");
}



-(void)simulatePush
{
    // test snippets for debugging push notifications deep link in simulator

    /*
     NSString *jsonString=@"\{\"aps\":{\"alert\":\"Hello from APNs Tester from server.\",\"badge\":1},\"t\":\"timesheets_approvals/sdfsdf\"}";
     NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
     id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
     self.isAppInForeground=NO;
     [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:json];
     */
}

-(void)startSyncTimer
{
    if ([self.syncTimer isValid])
    {
        [self.syncTimer invalidate];
    }
    self.syncTimer= [NSTimer scheduledTimerWithTimeInterval: 20.0
                                                     target: self
                                                   selector:@selector(stopSyncTimer)
                                                   userInfo: nil repeats:NO];
}

-(void)stopSyncTimer
{
    if ([self.syncTimer isValid])
    {
        [self.syncTimer invalidate];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName: START_AUTOSAVE object: nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    CLS_LOG(@"-----applicationWillResignActive -----");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    CLS_LOG(@"-----applicationDidEnterBackground -----");

    isAppInForeground=FALSE;
    [[ShortcutParser shared] syncShortcut];
    [self removeAlertViews:application.windows];

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    /*

     How not to allow the iOS from taking a screen capture of your app before going into background

     UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.window.bounds];

     imageView.tag = 611;    // Give some decent tagvalue or keep a reference of imageView in self
     //    imageView.backgroundColor = [UIColor redColor];
     [imageView setImage:[UIImage imageNamed:@"Default.png"]];   // assuming Default.png is your splash image's name

     [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:imageView];
     */
    [AppPersistentStorage syncInMemoryMapToPlist];
    [self flushLastSyncDate];

    UIViewController *allViewController = self.rootTabBarController.selectedViewController;


    if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
    {
        if (![self.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            [self updateLastSyncDateForServiceName:@"Timesheets"];
        }
        TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
        NSArray *timesheetControllers = timeSheetNavController.viewControllers;
        for (UIViewController *viewController in timesheetControllers)
        {
            if ([viewController isKindOfClass:[TimesheetMainPageController class]])
            {
                [[NSNotificationCenter defaultCenter] removeObserver: viewController name: START_AUTOSAVE object: nil];
            }
        }


    }
    else if ([allViewController isKindOfClass:[ExpensesNavigationController class]])
    {
        if (![self.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            [self updateLastSyncDateForServiceName:@"Expenses"];
        }



    }
    else if ([allViewController isKindOfClass:[ApprovalsNavigationController class]] || [allViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        if (![self.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            [self updateLastSyncDateForServiceName:@"Approvals"];
        }



    }
    else if ([allViewController isKindOfClass:[BookedTimeOffNavigationController class]])
    {
        if (![self.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            [self updateLastSyncDateForServiceName:@"TimeOff"];
        }


    }

    else if ([allViewController isKindOfClass:[AttendanceNavigationController class]])
    {
        if (![self.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            [self updateLastSyncDateForServiceName:@"Attendance"];
        }



    }


    else if ([allViewController isKindOfClass:[ShiftsNavigationController class]])
    {
        if (![self.window.rootViewController isKindOfClass:[LoginViewController class]])
        {
            [self updateLastSyncDateForServiceName:@"Shifts"];
        }
    }
    [self stopSyncTimer];
    if (appRatingViewController) {
        [appRatingViewController.view removeFromSuperview];
        appRatingViewController = nil;
    }

    TimesheetModel *timesheetModel = [[TimesheetModel alloc] init];
    if ([timesheetModel isTimesheetPending])
    {
        [self.syncNotificationScheduler cancelNotification:@"SyncQueueStatus"];
        [self.syncNotificationScheduler scheduleNotificationWithAlertBody:RPLocalizedString(syncTimesheetLocalNotificationMsg, @"") uid:@"SyncQueueStatus"];
    }
    else
    {
        [self.syncNotificationScheduler cancelNotification:@"SyncQueueStatus"];
    }

}

- (void)dismissUIKeyBoard:(NSArray *)subviews {
    for (UIView * subview in subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            [subview resignFirstResponder];

        }
        else if ([subview isKindOfClass:[UITextView class]])
        {
            [subview resignFirstResponder];

        }
        else {
            [self dismissUIKeyBoard:subview.subviews];
        }
    }

}

- (void)removeAlertViews:(NSArray *)subviews {

    for (UIView * subview in subviews){
        if ([subview isKindOfClass:[UIAlertView class]])
        {
            [(UIAlertView *)subview dismissWithClickedButtonIndex:[(UIAlertView *)subview cancelButtonIndex] animated:NO];
        }

        else if ([subview isKindOfClass:[UIActionSheet class]]){
            [(UIActionSheet *)subview dismissWithClickedButtonIndex:[(UIAlertView *)subview cancelButtonIndex] animated:NO];
        }
        else {
            [self removeAlertViews:subview.subviews];
            return;
        }

    }

    [UIAlertView dismissAllVisibleAlertViews];

}

-(void)dismissModalViews
{
    if (self.window.rootViewController.presentedViewController) {
        [self.window.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self performSelector:@selector(dismissModalViews) withObject:nil afterDelay:0.5];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    CLS_LOG(@"-----applicationWillEnterForeground -----");

    [self removeAlertViews:application.windows];
    if([self.userSession validUserSession])
    {
        [self.punchRevitalizer revitalizePunches];
        [self.punchErrorPresenter  presentFailedPunchesErrors];
    }

    [self getAppConfiguration];

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UIImageView *imageView = (UIImageView *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject viewWithTag:611];   // search by the same tag value
    [imageView removeFromSuperview];

    BOOL isLoginSuccessfull=[self.standardUserDefaults boolForKey:@"isSuccessLogin"];
    if (isLoginSuccessfull) {
        [self performSelector:@selector(renderRatingApplicationView) withObject:nil afterDelay:0.5];
        [self sendRequestForGettingUpdatedBadgeValue];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    CLS_LOG(@"-----applicationDidBecomeActive -----");

    isAppInForeground=TRUE;
    [[DeepLinkManager shared] checkDeepLink];
    NSString *tzName = [ReportTechnicalErrors fetchTimeZone];
    NSString *deviceLanguageStr = [ReportTechnicalErrors fetchDeviceLanguage];
    NSString *localeString= [ReportTechnicalErrors fetchDeviceLocale];
    NSString *networkType= [ReportTechnicalErrors fetchNetworkType];

    if (tzName)
    {
        [[Crashlytics sharedInstance] setObjectValue:tzName forKey:@"Device Time Zone"];
    }
    if (deviceLanguageStr) {
        [[Crashlytics sharedInstance] setObjectValue:deviceLanguageStr forKey:@"Device Language"];
    }
    if (localeString) {
        [[Crashlytics sharedInstance] setObjectValue:localeString forKey:@"Region Format"];
    }
    if (localeString) {
        [[Crashlytics sharedInstance] setObjectValue:networkType forKey:@"Data Connection"];
    }


    // gaTracker
    // Set any previously stored login credentials in Google tracker
    NSDictionary *loginCredentials = [self.loginCredentialsHelper getLoginCredentials];
    NSString *userUri = [loginCredentials objectForKey:@"userUri"];
    if (userUri != nil) {
        NSString *companyName = [loginCredentials objectForKey:@"companyName"];
        NSString *username = [loginCredentials objectForKey:@"userName"];
        NSString *platform = [[NSUserDefaults standardUserDefaults]boolForKey:@"IS_GEN2_INSTANCE"] ? @"gen2" : @"gen3";
        [self.tracker setUserUri:userUri companyName:companyName username:username platform:platform];
    }
    [self.tracker trackScreenView:@"application" forTracker:TrackerProduct];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"])
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
        {
            [self.loginService sendrequestToGetVersionUpdateDetails];
        }


    }

    UIViewController *allViewController = self.rootTabBarController.selectedViewController;

    BOOL isLoginSuccessfull=[self.standardUserDefaults boolForKey:@"isSuccessLogin"];
    if (isLoginSuccessfull) {
        if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
        {
            TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;


            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"Timesheets"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {
                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];
                }
                else
                {

                    NSArray *timesheetControllers = timeSheetNavController.viewControllers;
                    for (UIViewController *viewController in timesheetControllers)
                    {
                        if ([viewController isKindOfClass:[TimesheetMainPageController class]])
                        {
                            [[NSNotificationCenter defaultCenter] addObserver: viewController
                                                                     selector: @selector(backAndSaveAction:)
                                                                         name: START_AUTOSAVE
                                                                       object: nil];
                            [self startSyncTimer];
                        }
                    }
                }

            }


        }
        else if ([allViewController isKindOfClass:[ExpensesNavigationController class]])
        {
            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"Expenses"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {
                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];

                }

            }


        }
        else if ([allViewController isKindOfClass:[ApprovalsNavigationController class]] || [allViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"Approvals"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {
                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];
                }

            }


        }
        else if ([allViewController isKindOfClass:[BookedTimeOffNavigationController class]])
        {
            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"TimeOff"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;




                if (min>15.0)
                {
                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];
                }

            }
            BookedTimeOffNavigationController *navCtrl=(BookedTimeOffNavigationController *)allViewController;
            if ([navCtrl.visibleViewController isKindOfClass:[ListOfBookedTimeOffViewController class]])
            {
                ListOfBookedTimeOffViewController *listCtrl=(ListOfBookedTimeOffViewController *)navCtrl.visibleViewController;
                [listCtrl viewWillAppear:TRUE];
            }



        }

        else if ([allViewController isKindOfClass:[AttendanceNavigationController class]])
        {
            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"Attendance"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {
                    AttendanceNavigationController *navCtrl=(AttendanceNavigationController *)allViewController;
                    if ([navCtrl.visibleViewController isKindOfClass:[AttendanceViewController class]])
                    {
                        AttendanceViewController *listCtrl=(AttendanceViewController *)navCtrl.visibleViewController;
                        [listCtrl.locationManager stopUpdatingLocation];
                        listCtrl.locationManager.delegate=nil;
                    }

                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];
                }

            }
            AttendanceNavigationController *navCtrl=(AttendanceNavigationController *)allViewController;
            if ([navCtrl.visibleViewController isKindOfClass:[AttendanceViewController class]])
            {
                AttendanceViewController *listCtrl=(AttendanceViewController *)navCtrl.visibleViewController;
                [listCtrl viewWillAppear:TRUE];
            }



        }


        else if ([allViewController isKindOfClass:[ShiftsNavigationController class]])
        {
            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"Shifts"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {

                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];
                }

            }

        }

        else if ([allViewController isKindOfClass:[TeamTimeNavigationController class]])
        {
            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"TeamTime"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {
                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];

                }

            }


        }

        else if ([allViewController isKindOfClass:[PunchHistoryNavigationController class]])
        {

            id lastUpdatedDateStr =[self getLastSyncDateForServiceName:@"PunchHistory"];

            if (lastUpdatedDateStr!=nil && ![lastUpdatedDateStr isKindOfClass:[NSNull class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                NSDate *lastUpdatedDate    =[dateFormatter dateFromString:(NSString *)lastUpdatedDateStr];





                NSDate *currentDate=[NSDate date];
                NSTimeInterval interval = [currentDate timeIntervalSinceDate:lastUpdatedDate];
                float min = interval/60;





                if (min>15.0)
                {
                    [self flipToHomeViewController];
                    [self dismissUIKeyBoard:application.windows];
                    [self removeAlertViews:application.windows];
                    [self dismissModalViews];

                }

            }
        }
    }

    else
    {
        UIViewController *visibleViewController=self.window.rootViewController;
        if ([visibleViewController isKindOfClass:[LoginNavigationViewController class]]) {
            //nothing to do
        }
        else if ([visibleViewController isKindOfClass:[UINavigationController class]])
        {

            if (isNotFirstTimeLaunch)
            {
                [self flipToHomeViewController];

            }
            else
            {
                self.isNotFirstTimeLaunch=TRUE;
            }


        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [self.standardUserDefaults setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:ApplicationLastActiveForegroundTimestamp];

    if ([self.standardUserDefaults objectForKey:@"appUpdateVersionTriggerCount"] == nil || [[self.standardUserDefaults objectForKey:@"appUpdateVersionTriggerCount"] isKindOfClass:[NSNull class]]) {
        [self.standardUserDefaults setInteger:0 forKey:@"appUpdateVersionTriggerCount"];
        [self.standardUserDefaults synchronize];
    }
    else{
        NSUInteger triggerCount = [self.standardUserDefaults integerForKey:@"appUpdateVersionTriggerCount"];
        [self.standardUserDefaults setInteger:triggerCount+1 forKey:@"appUpdateVersionTriggerCount"];
        [self.standardUserDefaults synchronize];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CLS_LOG(@"-----applicationWillTerminate -----");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [AppPersistentStorage syncInMemoryMapToPlist];

    [self.locationManagerTemp stopUpdatingLocation];
    if (appRatingViewController) {
        [appRatingViewController.view removeFromSuperview];
        appRatingViewController = nil;
    }

}

-(void)loadCookie
{
    NSString *serviceEndpointRootUrl = [self.standardUserDefaults objectForKey:@"serviceEndpointRootUrl"];
    NSString *domainName=nil;
    if ([self.standardUserDefaults objectForKey:@"urlPrefixesStr"]!=nil)
    {

        NSArray *componentsArr=[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] componentsSeparatedByString:@"."];

        if ([componentsArr count]==4)
        {
            domainName=[NSString stringWithFormat:@"https://%@/", [[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString]];
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
            if ([[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"beta"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"test"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"sl"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"qa"])
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


    SQLiteDB *myDB = [SQLiteDB getInstance];

    NSArray * cookieArr=[myDB executeQueryToConvertUnicodeValues:[NSString stringWithFormat:@"SELECT cookie from cookies"]];
    if ([cookieArr count]>0)
    {
        NSDictionary *cookieDict=[cookieArr objectAtIndex:0];
        id value=[cookieDict objectForKey:@"cookie"];
        NSArray* allCookies = [NSKeyedUnarchiver unarchiveObjectWithData:value];

        NSLog(@"%@",allCookies);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:allCookies forURL:[NSURL URLWithString:domainName] mainDocumentURL:nil];
    }




}

-(void)deleteCookies
{

    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieJar = [storage cookies];

    for (NSHTTPCookie *cookie in cookieJar)
    {
        [storage deleteCookie:cookie];
    }


    NSString *serviceEndpointRootUrl = [self.standardUserDefaults objectForKey:@"serviceEndpointRootUrl"];
    NSString *domainName=nil;
    if ([self.standardUserDefaults objectForKey:@"urlPrefixesStr"]!=nil)
    {

        NSArray *componentsArr=[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] componentsSeparatedByString:@"."];

        if ([componentsArr count]==4)
        {
            domainName=[NSString stringWithFormat:@"https://%@/", [[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString]];
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

            if ([[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"beta"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"] ||
                [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"test"]|| [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"sl"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"qa"])
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


-(id)getLastSyncDateForServiceName:(NSString *)serviceName {

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"moduleName = '%@'",serviceName];

    NSMutableArray *dataArray = [myDB select:@"*" from:dataSyncTable where:whereString intoDatabase:@""];
    if (dataArray != nil && [dataArray count] > 0) {
        return [[dataArray objectAtIndex:0] objectForKey:@"lastSyncDate"];
    }

    return nil;
}


-(void)updateLastSyncDateForServiceName:(NSString *)serviceName {
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"moduleName = '%@'",serviceName];
    NSDate *currentDate = [NSDate date];
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:currentDate
                                                         forKey:@"lastSyncDate"];
    [myDB updateTable:dataSyncTable data:dataDict where:whereString intoDatabase:@""];
}

-(void)flushLastSyncDate{

    SQLiteDB *myDB = [SQLiteDB getInstance];

    NSString *dataSyncDetailsDeleteSql = [NSString stringWithFormat:@"DELETE FROM DataSyncDetails;"];
    [myDB sqliteExecute:dataSyncDetailsDeleteSql];

    NSString *dataSyncDetailsInsertSql1 = [NSString stringWithFormat:@"INSERT INTO \"DataSyncDetails\" VALUES ( 'Timesheets', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql1];
    NSString *dataSyncDetailsInsertSql2 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'Expenses', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql2];
    NSString *dataSyncDetailsInsertSql3 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'TimeOff', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql3];
    NSString *dataSyncDetailsInsertSql4 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'Approvals', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql4];
    NSString *dataSyncDetailsInsertSql5 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'Attendance', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql5];
    NSString *dataSyncDetailsInsertSql6 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'Shifts', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql6];

    NSString *dataSyncDetailsInsertSql7 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'TeamTime', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql7];

    NSString *dataSyncDetailsInsertSql8 = [NSString stringWithFormat:@"INSERT INTO \"dataSyncDetails\" VALUES ( 'PunchHistory', null);"];
    [myDB sqliteExecute:dataSyncDetailsInsertSql8];
}


#pragma mark -
#pragma mark Launch View Methods

/************************************************************************************************************
 @Function Name   : launchViewForFirstTimeLoad
 @Purpose         : Called to launch view for user for the first time application launch.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)launchViewForFirstTimeLoad
{
    NSUserDefaults *defaults=self.standardUserDefaults;
    SupportDataModel *supportModel = [[SupportDataModel alloc]init];
    NSMutableArray *userDetailsArr=[supportModel getUserDetailsFromDatabase];
    BOOL isAlreadyLoggedIn = [self.standardUserDefaults boolForKey:@"isSuccessLogin"];
    
    if ([userDetailsArr count]==0 && [defaults objectForKey:@"AuthMode"]==nil)
    {
        if (isAlreadyLoggedIn)
        {
            [self sendRequestForGetHomeSummary];
        }
        else
        {
            [self launchLoginOrWelcomeViewController];
        }
    }
    else
    {
        if (isAlreadyLoggedIn)
        {
            [self sendRequestForGetHomeSummary];
            //[self sendRequestForGettingUpdatedBadgeValue];
        }
        else
        {
            if ([[defaults objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                [self launchLoginOrWelcomeViewController];
            }
            else
            {
                NSString *companyName = nil;
                // MOBI-471
                ACSimpleKeychain *keychain = [self.keychainProvider provideInstance];
                if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                    NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
                    if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                        companyName = [credentials valueForKey:ACKeychainCompanyName];
                    }
                }
                
                NSUserDefaults *defaults=self.standardUserDefaults;
                BOOL isRememberMe=[defaults boolForKey:@"RememberMe"];
                if (companyName!=nil && ![companyName isKindOfClass:[NSNull class]] && isRememberMe)
                {
                    [self launchLoginViewController:YES];
                }
                else
                {
                    [self launchLoginOrWelcomeViewController];
                }
            }
        }
    }
}
/************************************************************************************************************
 @Function Name   : launchLoginOrWelcomeViewController
 @Purpose         : Called to launch loginViewController or WelcomeViewcontroller based on EMM values
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)launchLoginOrWelcomeViewController {
    self.emmConfigManager = [self.injector getInstance:[EMMConfigManager class]];
    if([self.emmConfigManager isEMMValuesStored]){
        [self launchLoginViewController:NO];
    }
    else {
        [self launchWelcomeViewController];
    }
}


/************************************************************************************************************
 @Function Name   : updateLoginViewController
 @Purpose         : Called to update loginViewController to authenticate user credentials.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

- (void) updateLoginViewController :(NSString*)urlString
{
    if (urlString == nil) {
        [self.loginViewController setShowPasswordField:YES];
    }
    else{
        [self.loginViewController launchGoogleSignInViewController:urlString];
    }
}
/************************************************************************************************************
 @Function Name   : loginViewController
 @Purpose         : Called to launch LoginViewController to authenticate company of the user.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

- (void)launchLoginViewController:(BOOL)showPasswordField
{
    [self resetValuesForWrongPassword];
    if (self.loginViewController)
    {
        [self.loginViewController.view removeFromSuperview];
    }
    
    LoginViewController *localLoginViewController = [self.injector getInstance:[LoginViewController class]];
    [localLoginViewController setShowPasswordField:showPasswordField];
    self.loginViewController = localLoginViewController;
    
    [navController popToRootViewControllerAnimated:YES];
    
    LoginNavigationViewController *navigationController = [[LoginNavigationViewController alloc] initWithRootViewController:localLoginViewController];
    self.window.rootViewController = navigationController;
}

- (void)resetValuesForWrongPassword {
    [RepliconServiceManager resetExpenseService];
    [RepliconServiceManager resetTimesheetService];
    [RepliconServiceManager resetTimeoffService];
    [Util flushDBInfoForOldUser:NO];
}

- (void) launchWelcomeViewController
{
    WelcomeViewController *welcomeViewController = [self.injector getInstance:[WelcomeViewController class]];
    self.window.rootViewController = welcomeViewController;
}

- (void) launchLoginViewController
{
    [self launchLoginViewController:YES];
}

//Implementation For Mobi-190//Reset Password//JUHI
/************************************************************************************************************
 @Function Name   : launchResetPasswordViewController
 @Purpose         : Called to launch CompanyViewController to authenticate company of the user.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

- (void) launchResetPasswordViewController
{
    if (self.resetPasswordViewController)
    {
        [self.resetPasswordViewController.view removeFromSuperview];
    }

    ResetPasswordViewController *tempCompanyViewController = [[ResetPasswordViewController alloc] initWithSpinnerDelegate:self router:self tracker:self.tracker theme:[self.injector getInstance:@protocol(Theme)]];
    self.resetPasswordViewController = tempCompanyViewController;

    UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:resetPasswordViewController];

    [tempnavcontroller.navigationBar setTranslucent:NO];
    tempnavcontroller.navigationBar.tintColor=[UIColor whiteColor];
    if ([tempnavcontroller respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        tempnavcontroller.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self.window.rootViewController presentViewController:tempnavcontroller animated:YES completion:nil];
}

-(void)launchErrorDetailsViewController
{
    UINavigationController *currentNavCtrl = self.rootTabBarController.selectedViewController;
    ErrorBannerViewController *errorBannerViewController = [self.injector getInstance:InjectorKeyErrorBannerViewController];
    if([currentNavCtrl.visibleViewController isKindOfClass:[ErrorDetailsViewController class]])
    {
        [currentNavCtrl popViewControllerAnimated:NO];
    }
    [errorBannerViewController presentErrorDetailsViewController];
}

#pragma mark -- After CompanyLogin success

- (void)didCompanyLoginSuccess {
    [self getAppConfiguration];
}

#pragma mark - <Router>

- (void)launchTabBarController
{
    [self getAppConfiguration];
    [self dismissModalViews];

    NavigationBarStylist *navigationBarStylist = [self.injector getInstance:[NavigationBarStylist class]];
    [navigationBarStylist styleNavigationBar];

    id<Theme> theme = [self.injector getInstance:@protocol(Theme)];

    NSArray *modules = [self.moduleStorage modules];

    self.rootTabBarController = [[UITabBarController alloc] init];
    self.rootTabBarController.viewControllers = [self.tabProvider viewControllersForModules:modules];
    self.rootTabBarController.delegate = self;
    self.rootTabBarController.tabBar.translucent = NO;
    self.rootTabBarController.tabBar.tintColor = [theme tabBarTintColor];

    self.window.rootViewController = self.rootTabBarController;

    [self.modulesGATracker sendGAEventForModule:(int)self.rootTabBarController.selectedViewController.view.tag];
    [[DeepLinkManager shared] checkDeepLink];
}

-(void)getAppConfiguration
{
    AppConfigRepository *appConfigRepository = [self.injector getInstance:[AppConfigRepository class]];
    [appConfigRepository appConfigForRequest:[self.mobileAppConfigRequestProvider getRequest]];
}

#pragma mark - <UITabBarControllerDelegate>

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if([viewController conformsToProtocol:@protocol(ServerMostRecentPunchProtocol)])
    {
//        id<ServerMostRecentPunchProtocol> controller = (id<ServerMostRecentPunchProtocol>)viewController;
//        [controller fetchAndDisplayChildControllerForMostRecentPunch];
    }

    if (viewController == tabBarController.moreNavigationController)
    {
        tabBarController.moreNavigationController.delegate = self;
    }
    else
    {
        [self.modulesGATracker sendGAEventForModule:(int)viewController.view.tag];
    }


}
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    if (changed)
    {
        NSArray *modules = [self.tabProvider modulesForViewControllers:viewControllers];
        [self.moduleStorage storeModules:modules];
    }
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController == self.rootTabBarController.moreNavigationController)
    {
        if(self.rootTabBarController.selectedViewController)
        {

            ErrorBannerViewController *errorBannerViewController = [self.injector getInstance:InjectorKeyErrorBannerViewController];
            [errorBannerViewController presentErrorDetailsControllerOnParentController:navigationController withTabBarcontroller:navigationController.tabBarController];



            [self.modulesGATracker sendGAEventForModule:(int)self.rootTabBarController.selectedViewController.view.tag];
        }

    }
}

#pragma mark -
#pragma mark Custom Activity View Methods

/************************************************************************************************************
 @Function Name   : flipToHomeViewController
 @Purpose         : Called to navigate to home ViewController .
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)flipToHomeViewController
{
    self.isNotFirstTimeLaunch = YES;
    [self launchTabBarController];
}

/************************************************************************************************************
 @Function Name   : showTransparentLoadingOverlay
 @Purpose         : Called to add transparent loading view while downloading data .
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)showTransparentLoadingOverlay
{
    if (progressView==nil)
    {
        UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
        tempView.backgroundColor=[UIColor whiteColor];
        tempView.alpha=0.4;
        self.progressView=tempView;


        UIActivityIndicatorView *tmpIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicatorView=tmpIndicatorView;

        CGFloat spinnerX = (tempView.bounds.size.width - 50)/2;
        CGFloat spinnerY = (tempView.bounds.size.height - 100)/2;
        UILabel *labelForUITesting = [[UILabel alloc]initWithFrame:CGRectMake(spinnerX, spinnerY, 50, 50)];
        labelForUITesting.backgroundColor = [UIColor clearColor];
        labelForUITesting.accessibilityLabel = @"uia_global_indicator_view_label_identifier";
        [self.progressView addSubview:labelForUITesting];
        [indicatorView setFrame:CGRectMake(spinnerX, spinnerY, 50, 50)];
        [indicatorView setHidesWhenStopped:YES];
        [self.progressView addSubview:indicatorView];

        if ([[[UIDevice currentDevice] systemVersion] newFloatValue] >= 5.0f) {
            indicatorView.color=[UIColor blackColor];
        }

    }
    [self performSelector:@selector(addIndicatorAndStartAnimating) withObject:nil afterDelay:0];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.progressView];
}

-(void)startTrackTimeClockAnimation
{

    [self.trackTimeIconImgView removeFromSuperview];

    NSArray *imageNames=[NSArray arrayWithObjects:@"timer1.png", @"timer2.png", @"timer3.png", @"timer4.png",
                         @"timer5.png", @"timer6.png", @"timer7.png", @"timer8.png", nil];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++)
    {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    UIImage *iconImage = [Util thumbnailImage:SlideIconTrackTime];
    self.trackTimeIconImgView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 98, iconImage.size.width, iconImage.size.height)];
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];

    if (version>=7.0)
    {
        self.trackTimeIconImgView.frame=CGRectMake(8, 78, iconImage.size.width, iconImage.size.height);
    }
    self.trackTimeIconImgView.animationImages = images;
    self.trackTimeIconImgView.highlightedAnimationImages = images;
    self.trackTimeIconImgView.animationDuration = 1.0;
    if (self.trackTimeIconImgView.isAnimating)
    {
        [self.trackTimeIconImgView stopAnimating];
    }
    [self.trackTimeIconImgView startAnimating];
    [self.window addSubview:self.trackTimeIconImgView];

    self.trackTimeIconImgView.hidden=FALSE;

}

-(void)stopTrackTimeClockAnimation
{
    self.trackTimeIconImgView.hidden=TRUE;
}

/************************************************************************************************************
 @Function Name   : addIndicatorAndStartAnimating
 @Purpose         : Called to add loading view with spinner after downloading 2 sec delay .
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)addIndicatorAndStartAnimating
{
    [self.indicatorView startAnimating];
}
/************************************************************************************************************
 @Function Name   : hideTransparentLoadingOverlay
 @Purpose         : Called to remove transparent loading view after downloading data .
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)hideTransparentLoadingOverlay
{
    [self.indicatorView stopAnimating];
    [self.progressView removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addIndicatorAndStartAnimating) object:nil];
}

#pragma mark -
#pragma mark Home summary request
/************************************************************************************************************
 @Function Name   : sendRequestForGetHomeSummary
 @Purpose         : Called to get home summary at app launch .
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

- (void) sendRequestForGetHomeSummary
{



    if(!self.reachabilityMonitor.isNetworkReachable)
    {
        [self loginServiceDidFinishLoggingIn:self.loginService];
        //[Util showOfflineAlert];
        return;
    }

    [self showTransparentLoadingOverlay];

    NSArray *modulesOrderArray=(NSArray *)[self.standardUserDefaults objectForKey:TAB_BAR_MODULES_KEY];
    BOOL launchHomeView=TRUE;
    if ([modulesOrderArray count]>0)
    {
        launchHomeView=FALSE;
    }

    //THIS CODE IS TO SIMULATE A RESPONSE DELAY (DIPTA)

    //    [self performSelector:@selector(delayingLWHS:) withObject:[NSNumber numberWithBool:launchHomeView] afterDelay:15.0];

    [self.loginService sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:[NSNumber numberWithBool:
                                                                                                    launchHomeView]];
    //THIS CODE IS TO SIMULATE A RESPONSE DELAY (DIPTA)

    //    [[RepliconServiceManager loginService] performSelector:@selector(sendrequestToFetchHomeSummaryWithDelegate:) withObject:self afterDelay:5.0];

    [self.loginService sendrequestToFetchHomeSummaryWithDelegate:self];
    self.rootTabBarController = [[UITabBarController alloc] init];
    self.window.rootViewController = self.rootTabBarController;

}

-(void)delayingLWHS:(NSNumber *)launchHomeViewNum
{
    [self.loginService sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:launchHomeViewNum];
}

#pragma mark NetworkMonitor

-(void) networkActivated
{

    [[self.injector getInstance:[BaseSyncOperationManager class]] startSync];
}

- (void)networkReachabilityChanged
{
    if(self.reachabilityMonitor.isNetworkReachable)
    {
        if([self.userSession validUserSession])
        {
            [[self.injector getInstance:[BaseSyncOperationManager class]] startSync];
            [self.punchRevitalizer revitalizePunches];
        }

    }

}

#pragma mark - <HomeSummaryDelegate>

- (void)parseAndStoreOEFLimitsToUserDefaults:(NSDictionary *)homeSummaryResponse {
    NSDictionary *oefLimits = homeSummaryResponse[@"objectExtensionFieldLimits"];
    ObjectExtensionFieldLimitDeserializer *oefLimitDeserializer = [self.injector getInstance:[ObjectExtensionFieldLimitDeserializer class]];
    [oefLimitDeserializer deserializeObjectExtensionFieldLimitFromHomeFlowService:oefLimits];
}

- (void)homeSummaryFetcher:(id)homeSummaryFetcher didReceiveHomeSummaryResponse:(NSDictionary *)homeSummaryResponse
{
    
    NSDictionary *userSummary = homeSummaryResponse[@"userSummary"];
    NSDictionary *approverCapabilities = userSummary[@"approvalCapabilities"];
    NSNumber *canApproveTimesheets;
    NSNumber *canApproveExpenses;
    NSNumber *canApproveTimeoffs;
    if (approverCapabilities != nil && approverCapabilities != (id)[NSNull null]) {
        NSDictionary *expenseApprovalCapabilities = approverCapabilities[@"expenseApprovalCapabilities"];
        if (expenseApprovalCapabilities !=nil && expenseApprovalCapabilities != (id) [NSNull null]) {
            canApproveExpenses = expenseApprovalCapabilities[@"isExpenseApprover"];
        }
        NSDictionary *timeoffApprovalCapabilities = approverCapabilities[@"timeoffApprovalCapabilities"];
        if (timeoffApprovalCapabilities !=nil && timeoffApprovalCapabilities != (id) [NSNull null]) {
            canApproveTimeoffs = timeoffApprovalCapabilities[@"isTimeOffApprover"];
        }
        NSDictionary *timesheetApprovalCapabilities = approverCapabilities[@"timesheetApprovalCapabilities"];
        if (timesheetApprovalCapabilities !=nil && timesheetApprovalCapabilities != (id) [NSNull null]) {
            canApproveTimesheets = timesheetApprovalCapabilities[@"isTimesheetApprover"];
        }
    }
    NSDictionary *timePunchCapabilities = userSummary[@"timePunchCapabilities"];
    NSDictionary *timesheetCapabilities=[userSummary objectForKey:@"timesheetCapabilities"];
    NSNumber *geolocationReqiured = timePunchCapabilities[@"geolocationRequired"];
    NSNumber *hasTimePunchAccess = timePunchCapabilities[@"hasTimePunchAccess"];
    NSNumber *breaksRequired = timePunchCapabilities[@"hasBreakAccess"];
    NSNumber *selfieRequired = timePunchCapabilities[@"auditImageRequired"];
    NSNumber *canEditNonTimePunchFileds = timePunchCapabilities[@"canEditOwnTimePunchNonTimeFields"];
    NSNumber *canEditPunch = timePunchCapabilities[@"canEditTimePunch"];
    NSNumber *canViewTeamPunch = timePunchCapabilities[@"canViewTeamTimePunch"];
    NSNumber *canAccessActivity = timePunchCapabilities[@"hasActivityAccess"];
    NSNumber *canAccessProject = timePunchCapabilities[@"hasProjectAccess"];
    NSNumber *canEditTeamTimePunch = timePunchCapabilities[@"canEditTeamTimePunch"];
    NSNumber *canAccessClient = timesheetCapabilities[@"hasClientsAvailableForTimeAllocation"];
    NSNumber *isProjectMandatory = timePunchCapabilities[@"projectTaskSelectionRequired"];
    NSNumber *isActivityMandatory = timePunchCapabilities[@"activitySelectionRequired"];
    NSNumber *canViewTeamTimesheet = timesheetCapabilities[@"canViewTeamTimesheet"];
    NSNumber *canEditTimesheet = @0;
    NSNumber *hasManualTimePunchAccess = timePunchCapabilities[@"hasManualTimePunchAccess"];
    
    NSDictionary * capabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];
    if (capabilities!=nil && capabilities != (id)[NSNull null]) {
        canEditTimesheet = capabilities[@"canEditTimesheet"];
    }

    int hasTimesheetAccess = 0;

    if ([[timesheetCapabilities objectForKey:@"hasTimesheetAccess"] boolValue] == YES )
    {
        hasTimesheetAccess = 1;
    }

    NSNumber *isWidgetEnabled = @0;
    
    NSMutableArray *widgetTimesheetResponse=capabilities[@"widgetTimesheetCapabilities"];
    if (widgetTimesheetResponse!=nil &&![widgetTimesheetResponse isKindOfClass:[NSNull class]])
    {
        for (int index=0; index<[widgetTimesheetResponse count]; index++)
        {
            NSMutableDictionary *responseDict=[widgetTimesheetResponse objectAtIndex:index];
            if (responseDict!=nil &&![responseDict isKindOfClass:[NSNull class]])
            {
                NSString *policyKeyUri=[responseDict objectForKey:@"policyKeyUri"];
                NSDictionary *policyValueDict=[responseDict objectForKey:@"policyValue"];
                if ([policyKeyUri isEqualToString:INOUT_WIDGET_URI])
                {
                    if (policyValueDict!=nil && ![policyValueDict isKindOfClass:[NSNull class]])
                    {
                        if ([policyValueDict objectForKey:@"bool"]) {
                            isWidgetEnabled= [policyValueDict objectForKey:@"bool"];
                        }
                    }
                }
            }
        }
    }
    
    BOOL isWidgetPlatformSupported = NO;
    
    if (widgetTimesheetResponse!=nil &&![widgetTimesheetResponse isKindOfClass:[NSNull class]])
    {
        WidgetTimesheetCapabilitiesDeserializer *widgetTimesheetCapabilitiesDeserializer = [self.injector getInstance:[WidgetTimesheetCapabilitiesDeserializer class]];
        
        NSArray *userConfiguredWidgetUris = [widgetTimesheetCapabilitiesDeserializer getUserConfiguredSupportedWidgetUris:widgetTimesheetResponse];
        
        WidgetPlatformDetector *widgetPlatformDetector = [self.injector getInstance:InjectorKeyWidgetPlatformDetector];
        [widgetPlatformDetector setupWithUserConfiguredWidgetUris:userConfiguredWidgetUris];
        isWidgetPlatformSupported = [widgetPlatformDetector isWidgetPlatformSupported];

    }

    NSDictionary *payDetailCapabilities = userSummary[@"payDetailCapabilities"];
    NSNumber *canViewPayDetails = [NSNumber numberWithInt:0];
    if (payDetailCapabilities!=nil && payDetailCapabilities != (id)[NSNull null]) {
        canViewPayDetails = payDetailCapabilities[@"canViewTeamPayDetails"];
    }

    NSString *userUri = userSummary[@"user"][@"uri"];

    if ([breaksRequired boolValue]) {
        [self.breakTypeRepository fetchBreakTypesForUser:userUri];
    }

    AstroUserDetector *astroUserDetector = [self.injector getInstance:[AstroUserDetector class]];
    BOOL isAstroUser = [astroUserDetector isAstroUserWithCapabilities:capabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:isWidgetPlatformSupported];

    NSDictionary *expenseCapabilities = userSummary[@"expenseCapabilities"][@"currentCapabilities"];
    NSNumber *isExpensesProjectMandatory = expenseCapabilities[@"entryAgainstProjectsRequired"];

    [self.userPermissionsStorage persistIsExpensesProjectMandatory:isExpensesProjectMandatory
                                         isWidgetPlatformSupported:@(isWidgetPlatformSupported)
                                              canApproveTimesheets:canApproveTimesheets
                                              canEditNonTimeFields:canEditNonTimePunchFileds
                                               geolocationRequired:geolocationReqiured
                                                canApproveExpenses:canApproveExpenses
                                                canApproveTimeoffs:canApproveTimeoffs
                                               isActivityMandatory:isActivityMandatory
                                                isProjectMandatory:isProjectMandatory
                                                hasTimesheetAccess:@(hasTimesheetAccess)
                                                 hasActivityAccess:canAccessActivity
                                                  hasProjectAccess:canAccessProject
                                                   hasClientAccess:canAccessClient
                                                  canEditTimePunch:canEditPunch
                                                  isAstroPunchUser:@(isAstroUser)
                                                 canViewPayDetails:canViewPayDetails
                                                  canViewTeamPunch:canViewTeamPunch
                                                    breaksRequired:breaksRequired
                                                    selfieRequired:selfieRequired
                                                hasTimePunchAccess:hasTimePunchAccess
                                              canViewTeamTimesheet:canViewTeamTimesheet
                                                  canEditTimesheet:canEditTimesheet
                                              canEditTeamTimePunch:canEditTeamTimePunch
                                               isSimpleInOutWidget:isWidgetEnabled
                                          hasManualTimePunchAccess:hasManualTimePunchAccess];

    NSDictionary *defaultActivity = timePunchCapabilities[@"defaultActivity"];
    [self.defaultActivityStorage setUpWithUserUri:userUri];
    if (defaultActivity != nil && ![defaultActivity isKindOfClass:[NSNull class]])
        [self.defaultActivityStorage persistDefaultActivityName:defaultActivity[@"displayText"] defaultActivityUri:defaultActivity[@"uri"]];
    else
        [self.defaultActivityStorage persistDefaultActivityName:@"" defaultActivityUri:@""];
    
    [self parseAndStoreOEFLimitsToUserDefaults:homeSummaryResponse];

    OEFDeserializer *oefDeserializer = [self.injector getInstance:[OEFDeserializer class]];
    NSMutableArray *oefArray = [oefDeserializer deserializeHomeFlowService:timePunchCapabilities[@"timePunchExtensionFields"]];
    OEFTypeStorage *oefTypeStorage = [self.injector getInstance:[OEFTypeStorage class]];
    [oefTypeStorage setUpWithUserUri:userUri];
    [oefTypeStorage storeOEFTypes:oefArray];


    SupportDataModel *supportDataModel = [self.injector getInstance:[SupportDataModel class]];
    NSArray *userDetails = [supportDataModel getUserDetailsFromDatabase];

    TabModuleNameProvider *tabModuleNameProvider = [self.injector getInstance:[TabModuleNameProvider class]];
    NSArray *modules = [tabModuleNameProvider tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:isWidgetPlatformSupported];

    [self.moduleStorage storeModulesWhenDifferent:modules];

    if([self.userSession validUserSession])
    {

        [self.punchRevitalizer revitalizePunches];
    }


}

#pragma mark - <LoginDelegate>

- (void)loginServiceDidFinishLoggingIn:(LoginService *)loginService
{
    [self launchTabBarController];
    [self hideTransparentLoadingOverlay];
    //    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"]))
    [self sendRequestForGettingUpdatedBadgeValue];

    [self.tracker trackUIEvent:@"login" forTracker:TrackerProduct];

}


#pragma mark - Image Memory Warning


//ravi - This is a hack
-(BOOL) expenseEntryMemoryWarning
{

    if(currVisibleViewController != nil && ![currVisibleViewController isKindOfClass: [NSNull class]] &&
       [currVisibleViewController isKindOfClass: [ReceiptsViewController class]])
    {
        if (!imageMemoryWarningShown) {
            imageMemoryWarningShown = YES;

            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:currVisibleViewController
                                                    message:RPLocalizedString(LARGE_RECEIPT_IMAGE_MEMORY_WARNING, @" ")
                                                      title:nil
                                                        tag:Image_Alert_tag_Add];



            return YES;
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Display text
    NSString *cookies = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.standardUserDefaults setObject:cookies forKey:@"deepLinking"];
    [self.standardUserDefaults synchronize];
    [self getDeepLinkingWorkingForValue:cookies];
    return YES;
}

-(void)AddCapabilityToDisplayRenamedLabelsInMobileApps:(NSArray *)customTermsArr
{


    for (int count=0; count<[customTermsArr count]; count++)
    {
        NSDictionary *customTermsDict=[customTermsArr objectAtIndex:count];
        NSString *originalTerm=[customTermsDict objectForKey:@"originalTerm"];
        NSString *customTerm=[customTermsDict objectForKey:@"customTerm"];

        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [applicationDocumentsDir stringByAppendingPathComponent:@"Localizable.strings"];

        //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];

        self.peristedLocalizableStringsDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
        if (self.peristedLocalizableStringsDict!=nil && ![self.peristedLocalizableStringsDict isKindOfClass:[NSNull class]])
        {



            NSArray *valuearray=[self.peristedLocalizableStringsDict allValues];
            NSArray *keyarray=[self.peristedLocalizableStringsDict allKeys];
            for (int k=0; k<[valuearray count]; k++)
            {

                NSString *string=[NSString stringWithFormat:@"%@",[self.peristedLocalizableStringsDict objectForKey:[valuearray objectAtIndex:k]]];
                NSString *capitalisedSentence=originalTerm;
                NSString *lowerCasedSentence=originalTerm;
                if (originalTerm && [originalTerm length]>0) {
                    //Yes. It is

                    capitalisedSentence = [originalTerm stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                withString:[[originalTerm substringToIndex:1] capitalizedString]];
                    lowerCasedSentence = [originalTerm lowercaseString];
                }
                if ([string rangeOfString:capitalisedSentence options:NSCaseInsensitiveSearch].location == NSNotFound)
                {
                    continue;
                }
                else
                {
                    if ([string rangeOfString:lowerCasedSentence].location != NSNotFound)
                    {
                        string=[string stringByReplacingOccurrencesOfString:lowerCasedSentence withString:[customTerm lowercaseString]];
                    }
                    else
                    {
                        if (customTerm && [customTerm length]>0) {
                            //Yes. It is

                            NSString *customTermCapitalisedSentence = [customTerm stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                                          withString:[[customTerm substringToIndex:1] capitalizedString]];
                            string=[string stringByReplacingOccurrencesOfString:capitalisedSentence withString:customTermCapitalisedSentence];
                        }


                    }
                    [self.peristedLocalizableStringsDict setObject:string forKey:[keyarray objectAtIndex:k]];

                }


            }
        }
        BOOL success= [self.peristedLocalizableStringsDict writeToFile:filePath atomically:YES];
        if (!success) {
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"FAILED TO SAVE LOCALISED FILE"] forLogLevel:LoggerCocoaLumberjack];
        }

    }

    if ([customTermsArr count]==0)
    {
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [applicationDocumentsDir stringByAppendingPathComponent:@"Localizable.strings"];
        self.peristedLocalizableStringsDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
    }


}


-(void)resetLocalisedFilesAtStart:(BOOL)isStart
{
    BOOL success;
    NSError *error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory1 stringByAppendingPathComponent:@"Localizable.strings"];
    success = [fileManager fileExistsAtPath:writableDBPath];

    if (success && isStart)
    {
        return;
    }

    if (success)
    {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    NSString *defaultDBPath1 = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];;
    success = [fileManager copyItemAtPath:defaultDBPath1 toPath:writableDBPath error:&error];
    if (!success)
    {
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"FAILED TO COPY LOCALISED FILE"] forLogLevel:LoggerCocoaLumberjack];
    }

}

- (void)approvalsDeepLinking {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DEEPLINKING_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION object:nil];
    [self.standardUserDefaults removeObjectForKey:@"deepLinking"];
    [self.standardUserDefaults synchronize];
}


- (void)startDeepLinkingTimer {
    if ([self.deepLinkingTimer isValid]) {
        [self.deepLinkingTimer invalidate];
    }
    self.deepLinkingTimer= [NSTimer scheduledTimerWithTimeInterval: 3600.0
                                                            target: self
                                                          selector:@selector(stopDeepLinkingTimer)
                                                          userInfo: nil repeats:NO];
}

- (void)stopDeepLinkingTimer {
    if ([self.deepLinkingTimer isValid]) {
        [self.deepLinkingTimer invalidate];
    }
    self.deepLinkingLaunchModule=nil;
}

-(void)getDeepLinkingWorkingForValue:(NSString *)deepLinkValue
{

    UIApplication *application = [UIApplication sharedApplication];

    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
    NSArray *modulesArray = [self.moduleStorage modules];

    if ([deepLinkValue isEqualToString:DEEPLINKING_TIMESHEETS])
    {
        if ([userDetailsArray count]!=0)
        {
            if ([modulesArray containsObject:TIMESHEETS_TAB_MODULE_NAME])
            {
                NSUInteger index=[modulesArray indexOfObject:TIMESHEETS_TAB_MODULE_NAME];
                [self flipToTabbarController:[NSNumber numberWithUnsignedInteger:index]];
            }
            else
            {
                [self flipToHomeViewController];
            }

            [self dismissUIKeyBoard:application.windows];
            [self removeAlertViews:application.windows];
            [self dismissModalViews];
        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    else if ([deepLinkValue isEqualToString:DEEPLINKING_EXPENSES])
    {
        if ([userDetailsArray count]!=0)
        {

            if ([modulesArray containsObject:EXPENSES_TAB_MODULE_NAME])
            {
                NSUInteger index=[modulesArray indexOfObject:EXPENSES_TAB_MODULE_NAME];
                [self flipToTabbarController:[NSNumber numberWithUnsignedInteger:index]];
            }
            else
            {
                [self flipToHomeViewController];
            }

            [self dismissUIKeyBoard:application.windows];
            [self removeAlertViews:application.windows];
            [self dismissModalViews];
        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    else if ([deepLinkValue isEqualToString:DEEPLINKING_TIMEOFFS])
    {
        if ([userDetailsArray count]!=0)
        {

            if ([modulesArray containsObject:TIME_OFF_TAB_MODULE_NAME])
            {
                NSUInteger index=[modulesArray indexOfObject:TIME_OFF_TAB_MODULE_NAME];
                [self flipToTabbarController:[NSNumber numberWithUnsignedInteger:index]];
            }
            else
            {
                [self flipToHomeViewController];
            }

            [self dismissUIKeyBoard:application.windows];
            [self removeAlertViews:application.windows];
            [self dismissModalViews];
        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    else if ([deepLinkValue isEqualToString:DEEPLINKING_TIMESHEETS_APPROVALS] || [deepLinkValue isEqualToString:DEEPLINKING_EXPENSES_APPROVALS] || [deepLinkValue isEqualToString:DEEPLINKING_TIMEOFFS_APPROVALS])
    {
        if ([userDetailsArray count]!=0)
        {
            BOOL isProceed=NO;

            if ([userDetailsArray count]!=0)
            {
                NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                BOOL isTimeOffApprover=[[userDict objectForKey:@"isTimeOffApprover"] boolValue];
                BOOL isTimesheetApprover=[[userDict objectForKey:@"isTimesheetApprover"] boolValue];
                BOOL isExpenseApprover=[[userDict objectForKey:@"isExpenseApprover"] boolValue];



                if ([deepLinkValue isEqualToString:DEEPLINKING_TIMESHEETS_APPROVALS] && isTimesheetApprover)
                {
                    isProceed=YES;
                }
                if ([deepLinkValue isEqualToString:DEEPLINKING_EXPENSES_APPROVALS] && isExpenseApprover)
                {
                    isProceed=YES;
                }
                if ([deepLinkValue isEqualToString:DEEPLINKING_TIMEOFFS_APPROVALS] && isTimeOffApprover)
                {
                    isProceed=YES;
                }
            }

            if (isProceed)
            {


                if ([modulesArray containsObject:APPROVAL_TAB_MODULE_NAME])
                {
                    UIViewController *allViewController = self.rootTabBarController.selectedViewController;
                    if ([allViewController isKindOfClass:[ApprovalsNavigationController class]])
                    {
                        ApprovalsNavigationController *approvalNavCtrl=(ApprovalsNavigationController *)allViewController;
                        UIViewController *currentCtrl=approvalNavCtrl.visibleViewController;
                        if ([currentCtrl isKindOfClass:[ApprovalsCountViewController class]])
                        {
                            [self approvalsDeepLinking];
                        }
                        else
                        {
                            [approvalNavCtrl popToRootViewControllerAnimated:NO];
                        }
                    }
                    else if ([allViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        SupervisorDashboardNavigationController *approvalNavCtrl=(SupervisorDashboardNavigationController *)allViewController;
                        UIViewController *currentCtrl=approvalNavCtrl.visibleViewController;
                        if ([currentCtrl isKindOfClass:[SupervisorDashboardController class]])
                        {
                            [self approvalsDeepLinking];
                        }
                        else
                        {
                            [approvalNavCtrl popToRootViewControllerAnimated:NO];
                        }
                    }
                    else
                    {
                        NSUInteger index=[modulesArray indexOfObject:APPROVAL_TAB_MODULE_NAME];
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:DEEPLINKING_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION object:nil];

                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(approvalsDeepLinking)
                                                                     name:DEEPLINKING_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION
                                                                   object:nil];
                        [self flipToTabbarController:[NSNumber numberWithUnsignedInteger:index]];
                    }
                }
                else
                {
                    [self flipToHomeViewController];
                }


                [self dismissUIKeyBoard:application.windows];
                [self removeAlertViews:application.windows];
                [self dismissModalViews];
            }
            else
            {
                [self flipToHomeViewController];
            }

        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    else if ([deepLinkValue isEqualToString:DEEPLINKING_LAUNCH])
    {
        if ([userDetailsArray count]!=0)
        {
            //[self flipToHomeViewController];
            [self dismissUIKeyBoard:application.windows];
            [self removeAlertViews:application.windows];
            [self dismissModalViews];
        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    //Implentation for Mobi-205//JUHI
    else if ([deepLinkValue isEqualToString:DEEPLINKING_ATTENDENCE])
    {
        if ([userDetailsArray count]!=0)
        {

            if ([modulesArray containsObject:CLOCK_IN_OUT_TAB_MODULE_NAME])
            {
                NSUInteger index=[modulesArray indexOfObject:CLOCK_IN_OUT_TAB_MODULE_NAME];
                [self flipToTabbarController:[NSNumber numberWithUnsignedInteger:index]];
            }

            else
            {
                [self flipToHomeViewController];
            }

            [self dismissUIKeyBoard:application.windows];
            [self removeAlertViews:application.windows];
            [self dismissModalViews];
        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    else if ([deepLinkValue isEqualToString:DEEPLINKING_SHIFT])
    {
        if ([userDetailsArray count]!=0)
        {

            if ([modulesArray containsObject:SCHEDULE_TAB_MODULE_NAME])
            {
                NSUInteger index=[modulesArray indexOfObject:SCHEDULE_TAB_MODULE_NAME];
                [self flipToTabbarController:[NSNumber numberWithUnsignedInteger:index]];
            }
            else
            {
                [self flipToHomeViewController];
            }

            [self dismissUIKeyBoard:application.windows];
            [self removeAlertViews:application.windows];
            [self dismissModalViews];
        }
        else
        {
            self.deepLinkingLaunchModule=deepLinkValue;
            [self performSelector:@selector(startDeepLinkingTimer) withObject:nil];
        }

    }
    else
    {
        float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        if (version>=7.0)
        {
            NSData *data = [Base64 decode:deepLinkValue];
            NSString *convertedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *serviceEndpointRootUrl = [self.standardUserDefaults objectForKey:@"serviceEndpointRootUrl"];
            NSString *domainName=nil;
            if ([self.standardUserDefaults objectForKey:@"urlPrefixesStr"]!=nil)
            {

                NSArray *componentsArr=[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] componentsSeparatedByString:@"."];

                if ([componentsArr count]==4)
                {
                    domainName=[NSString stringWithFormat:@"https://%@/", [[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString]];
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

                    if ([[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"beta"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"test"]|| [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"sl"] || [[[self.standardUserDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"qa"])
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


            NSData* receivedData=[convertedString dataUsingEncoding:NSUTF8StringEncoding];
            id parsedData = [JsonWrapper parseJson: receivedData error: nil];
            @try
            {
                if (parsedData != nil && [parsedData isKindOfClass: [NSArray class]] && [(NSMutableArray *)parsedData count] > 0)
                {
                    NSMutableArray *mergedCookies = [NSMutableArray array];

                    for (int i=0; i<[(NSMutableArray *)parsedData count]; i++)
                    {
                        NSMutableDictionary *parsedDict=[parsedData objectAtIndex:i];
                        if ([[parsedDict allKeys]containsObject:@"domain"])
                        {
                            [parsedDict setObject:[parsedDict objectForKey:@"domain"] forKey:NSHTTPCookieDomain];
                            [parsedDict removeObjectForKey:@"domain"];
                        }
                        if ([[parsedDict allKeys]containsObject:@"expires"])
                        {
                            [parsedDict setObject:[parsedDict objectForKey:@"expires"] forKey:NSHTTPCookieExpires];
                            [parsedDict removeObjectForKey:@"expires"];
                        }
                        if ([[parsedDict allKeys]containsObject:@"name"])
                        {
                            [parsedDict setObject:[parsedDict objectForKey:@"name"] forKey:NSHTTPCookieName];
                            [parsedDict removeObjectForKey:@"name"];
                        }
                        if ([[parsedDict allKeys]containsObject:@"secure"])
                        {
                            [parsedDict setObject:[NSNumber numberWithBool:[[parsedDict objectForKey:@"secure"]boolValue]] forKey:NSHTTPCookieSecure];
                            [parsedDict removeObjectForKey:@"secure"];
                        }
                        if ([[parsedDict allKeys]containsObject:@"value"])
                        {
                            [parsedDict setObject:[parsedDict objectForKey:@"value"] forKey:NSHTTPCookieValue];
                            [parsedDict removeObjectForKey:@"value"];
                        }
                        if ([[parsedDict allKeys]containsObject:@"path"])
                        {
                            [parsedDict setObject:[parsedDict objectForKey:@"path"] forKey:NSHTTPCookiePath];
                            [parsedDict removeObjectForKey:@"path"];
                        }

                        NSDictionary *cookieProperties = [parsedData objectAtIndex:i];
                        NSHTTPCookie *cookieObj = [NSHTTPCookie cookieWithProperties:cookieProperties];
                        [mergedCookies addObject:cookieObj];
                    }
                    SQLiteDB *myDB = [SQLiteDB getInstance];
                    [myDB deleteFromTable:@"cookies" inDatabase:@""];

                    [myDB insertCookieData:[NSKeyedArchiver archivedDataWithRootObject:mergedCookies]];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:mergedCookies forURL:[NSURL URLWithString:domainName] mainDocumentURL:nil];
                    //[self launchTabBarController];
                    [self.loginService sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:[NSNumber numberWithBool:YES]];
                    [self.loginService sendrequestToFetchHomeSummaryWithDelegate:self];
                    [self.loginService sendrequestToUpdateMySessionTimeoutDuration];
                    [self performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                }
            }

            @finally
            {

            }
        }
    }
}


#pragma mark -
#pragma mark App Rating View

-(void)renderRatingApplicationView
{

    BOOL isShowingAppRatingView = ![self.standardUserDefaults boolForKey:@"notShowingAppRatingPopup"];
    if (isShowingAppRatingView) {
        if ([self.standardUserDefaults objectForKey:@"appTriggerCount"] == nil || [[self.standardUserDefaults objectForKey:@"appTriggerCount"] isKindOfClass:[NSNull class]]) {
            NSDate *now = [NSDate date];
            [self.standardUserDefaults setObject:now forKey:@"startDate"];
            [self.standardUserDefaults setInteger:1 forKey:@"appTriggerCount"];
            [self.standardUserDefaults synchronize];
        }
        else{
            NSUInteger triggerCount = [self.standardUserDefaults integerForKey:@"appTriggerCount"];
            [self.standardUserDefaults setInteger:triggerCount+1 forKey:@"appTriggerCount"];
            [self.standardUserDefaults synchronize];
        }
    }

    NSDate *startDate = [self.standardUserDefaults objectForKey:@"startDate"];
    NSUInteger triggerCount = 0;
    int dayDiffrence = 0;
    if (startDate !=nil && ![startDate isKindOfClass:[NSNull class]]) {
        dayDiffrence = [Util getDayDifferenceFromDate:startDate];
    }

    if ([self.standardUserDefaults objectForKey:@"appTriggerCount"] !=nil && ![[self.standardUserDefaults objectForKey:@"appTriggerCount"] isKindOfClass:[NSNull class]]) {
        triggerCount = [self.standardUserDefaults integerForKey:@"appTriggerCount"];
    }


    if (![self.standardUserDefaults boolForKey:@"notShowingAppRatingPopup"])
    {
        if (dayDiffrence >= 5 &&  triggerCount >= 5 ) {
            [self performSelector:@selector(showAppRatingView) withObject:nil afterDelay:2.0];
        }
    }
    else{
        [self.standardUserDefaults removeObjectForKey:@"appTriggerCount"];
        [self.standardUserDefaults removeObjectForKey:@"startDate"];
    }


}


- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
    appRatingViewController.appRatingValue = rating;
}


- (void)showAppRatingView {
    appRatingViewController = [[AppRatingViewController alloc]init];
    self.appRatingViewController.delegate = self;
    [self.window addSubview:appRatingViewController.view];
}

- (void)commonButtonAction:(UIButton*)sender {
    float appRatingValue= appRatingViewController.appRatingValue;
    if (sender.tag == 0) {
        if (appRatingValue>3) {
            [appRatingViewController.view removeFromSuperview];
            appRatingViewController = nil;

            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(CANCEL_STRING, @"")
                                           otherButtonTitle:RPLocalizedString(APP_STORE_TEXT, @"")
                                                   delegate:self
                                                    message:RPLocalizedString(THANKS_MSG_TEXT,@"")
                                                      title:RPLocalizedString(THANKS_TITLE_TEXT, @"")
                                                        tag:2];

        }
        else if (appRatingValue<=3 && appRatingValue>0)
        {
            [appRatingViewController.view removeFromSuperview];


            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(CANCEL_STRING, @"")
                                           otherButtonTitle:RPLocalizedString(FEEDBACK_TEXT, @"")
                                                   delegate:self
                                                    message:RPLocalizedString(SORRY_MSG_TEXT,@"")
                                                      title:RPLocalizedString(SORRY_TITLE_TEXT, @"")
                                                        tag:3];

        }
        else if(appRatingValue == 0)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Ok", @"Ok")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(NOT_SELECTED_RATING_TEXT,@"")
                                                      title:nil
                                                        tag:4];

        }

        if (appRatingValue>0)
        {
            NSString *event = [NSString stringWithFormat:@"Star rating selected %f",appRatingValue];
            [EventTracker.sharedInstance log:event];
        }
    }
    else if (sender.tag == 1)
    {
        [appRatingViewController.view removeFromSuperview];
        appRatingViewController = nil;
        [self.standardUserDefaults setBool:true forKey:@"notShowingAppRatingPopup"];

        [EventTracker.sharedInstance log:@"Never Button Tap"];
    }
    else
    {
        [appRatingViewController.view removeFromSuperview];
        appRatingViewController = nil;
        NSDate *now = [NSDate date];
        [self.standardUserDefaults setObject:now forKey:@"startDate"];
        [self.standardUserDefaults setInteger:0 forKey:@"appTriggerCount"];
        [self.standardUserDefaults synchronize];

        [EventTracker.sharedInstance log:@"Remind Button Tap"];
    }

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
    UIViewController *allViewController = self.rootTabBarController.selectedViewController;
    if(allViewController == nil)
    {
        [self.navController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [allViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2)
    {
        [appRatingViewController.view removeFromSuperview];
        appRatingViewController = nil;
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[AppProperties getInstance] getAppPropertyFor: @"itunesAppUrl"]]];
            [self.standardUserDefaults setBool:true forKey:@"notShowingAppRatingPopup"];

            [EventTracker.sharedInstance log:@"Thanks Primary Button Tap"];
        }
        else
        {

            [self.standardUserDefaults setBool:true forKey:@"notShowingAppRatingPopup"];

            [EventTracker.sharedInstance log:@"Thanks Cancel Button Taps"];
        }
    }
    else if (alertView.tag == 3)
    {
        if (buttonIndex == 1) {
            if ([MFMailComposeViewController canSendMail] == NO) {


                [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                               otherButtonTitle:nil
                                                       delegate:nil
                                                        message:RPLocalizedString(@"Sending Failed - Unknown Error :-(", @"Sending Failed - Unknown Error :-(")
                                                          title:RPLocalizedString(@"Email",@"Email")
                                                            tag:LONG_MIN];

                return;
            }

            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            mailPicker.mailComposeDelegate = self;
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *emailSubject=nil;
            NSString *companyName=nil;
            NSString *companyDetails=nil;

            ACSimpleKeychain *keychain = [self.keychainProvider provideInstance];
            NSDictionary *credentials =  nil;
            if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
            }
            if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                companyName = [credentials valueForKey:ACKeychainCompanyName];
            }

            emailSubject= [NSString stringWithFormat:@"%.f %@",appRatingViewController.appRatingValue, [RPLocalizedString(STAR_RATING_TEXT, "")  stringByAppendingString:version]];

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

            [appRatingViewController.view removeFromSuperview];
            appRatingViewController = nil;
            UIViewController *allViewController = self.rootTabBarController.selectedViewController;
            if(allViewController == nil)
            {
                [self.navController presentViewController:mailPicker animated:YES completion:nil];
            }
            else{
                [allViewController presentViewController:mailPicker animated:YES completion:nil];
            }
            [self.standardUserDefaults setBool:true forKey:@"notShowingAppRatingPopup"];

            [EventTracker.sharedInstance log:@"Sorry Primary Button Tap"];
        }
        else
        {
            [appRatingViewController.view removeFromSuperview];
            appRatingViewController = nil;
            [self.standardUserDefaults setBool:true forKey:@"notShowingAppRatingPopup"];

            [EventTracker.sharedInstance log:@"Sorry Cancel Button Tap"];
        }

    }
    else if (alertView.tag == 5)
    {
        if (buttonIndex == 0) {
            [LogUtil setDebugMode:NO];
            NSArray *filepaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filedocumentsDirectory = [filepaths objectAtIndex:0];

            NSFileManager *fileManagerforlogs = [NSFileManager defaultManager];
            [fileManagerforlogs removeItemAtPath:[filedocumentsDirectory stringByAppendingFormat:@"/currentlog.txt"] error:NULL];
            [fileManagerforlogs removeItemAtPath:[filedocumentsDirectory stringByAppendingFormat:@"/backkuplog.txt"] error:NULL];
        }
    }
    else if (alertView.tag == 555)
    {
        [Util flushDBInfoForOldUser:YES];
        NSArray *modulesOrderArray=(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:TAB_BAR_MODULES_KEY];
        BOOL launchHomeView=TRUE;
        if ([modulesOrderArray count]>0)
        {
            [self launchTabBarController];
            launchHomeView=FALSE;
        }



        [[RepliconServiceManager loginService] sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:[NSNumber numberWithBool:launchHomeView]];
        [[RepliconServiceManager loginService] sendrequestToFetchHomeSummaryWithDelegate :self];
        [self performSelector:@selector(showTransparentLoadingOverlay) withObject:nil afterDelay:0.5];
    }
    //MOBI-839//JUHI
    else if (alertView.tag==1001)
    {
        UIViewController *allViewController = self.rootTabBarController.selectedViewController;
        if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
        {
            TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
            NSArray *timesheetControllers = timeSheetNavController.viewControllers;
            for (UIViewController *viewController in timesheetControllers)
            {
                if ([viewController isKindOfClass:[ListOfTimeSheetsViewController class]])
                {
                    ListOfTimeSheetsViewController *tempviewctrl=(ListOfTimeSheetsViewController*)viewController;
                    [self dismissModalViews];
                    [tempviewctrl refreshActionForUriNotFoundError];
                }
            }
            [timeSheetNavController popToRootViewControllerAnimated:YES];
        }
        else if ([allViewController isKindOfClass:[ExpensesNavigationController class]]){
            ExpensesNavigationController *expensesNavController=(ExpensesNavigationController *)allViewController;
            NSArray *expenseSheetControllers = expensesNavController.viewControllers;
            for (UIViewController *viewController in expenseSheetControllers)
            {
                if ([viewController isKindOfClass:[ListOfExpenseSheetsViewController class]])
                {
                    ListOfExpenseSheetsViewController *tempviewctrl=(ListOfExpenseSheetsViewController*)viewController;

                    [self dismissModalViews];

                    [tempviewctrl refreshActionForUriNotFoundError];
                }
            }
            [expensesNavController popToRootViewControllerAnimated:YES];
        }
        else if ([allViewController isKindOfClass:[BookedTimeOffNavigationController class]]){
            BookedTimeOffNavigationController *bookedTimeoffNavController=(BookedTimeOffNavigationController *)allViewController;
            NSArray *bookedTimeoffControllers = bookedTimeoffNavController.viewControllers;
            for (UIViewController *viewController in bookedTimeoffControllers)
            {
                if ([viewController isKindOfClass:[ListOfBookedTimeOffViewController class]])
                {
                    //                    ListOfBookedTimeOffViewController *tempviewctrl=(ListOfBookedTimeOffViewController*)viewController;
                    [self dismissModalViews];
                    //                    [[tempviewctrl bookedTimeOffSummaryViewController] refreshActionForUriNotFoundError];
                }
            }
            [bookedTimeoffNavController popToRootViewControllerAnimated:YES];
        }
        else if ([allViewController isKindOfClass:[SupervisorDashboardNavigationController class]]){
            SupervisorDashboardNavigationController *supervisorDashboardNavigationController=(SupervisorDashboardNavigationController *)allViewController;
            [supervisorDashboardNavigationController popToRootViewControllerAnimated:YES];

        }
        if ([allViewController isKindOfClass:[PunchHomeNavigationController class]])
        {
            PunchHomeNavigationController *navigationController=(PunchHomeNavigationController *)allViewController;
            [navigationController popToRootViewControllerAnimated:YES];
        }


        else if ([allViewController isKindOfClass:[ApprovalsNavigationController class]]){
            ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
            NSArray *approvalsControllers = approvalsNavController.viewControllers;
            UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
            if ([viewCtrl isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
            {
                ApprovalsPendingTimesheetViewController *tempviewctrl=(ApprovalsPendingTimesheetViewController*)viewCtrl;
                [self dismissModalViews];
                [tempviewctrl refreshActionForUriNotFoundError];

            }
            else if ([viewCtrl isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
            {
                ApprovalsTimesheetHistoryViewController *tempviewctrl=(ApprovalsTimesheetHistoryViewController*)viewCtrl;
                [self dismissModalViews];
                [tempviewctrl refreshActionForUriNotFoundError];
            }
            else if ([viewCtrl isKindOfClass:[ApprovalsPendingExpenseViewController class]])
            {
                ApprovalsPendingExpenseViewController *tempviewctrl=(ApprovalsPendingExpenseViewController*)viewCtrl;
                [self dismissModalViews];
                [tempviewctrl refreshActionForUriNotFoundError];
            }
            else if ([viewCtrl isKindOfClass:[ApprovalsExpenseHistoryViewController class]])
            {
                ApprovalsExpenseHistoryViewController *tempviewctrl=(ApprovalsExpenseHistoryViewController*)viewCtrl;
                [self dismissModalViews];
                [tempviewctrl refreshActionForUriNotFoundError];
            }
            else if ([viewCtrl isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
            {
                ApprovalsPendingTimeOffViewController *tempviewctrl=(ApprovalsPendingTimeOffViewController*)viewCtrl;
                [self dismissModalViews];
                [tempviewctrl refreshActionForUriNotFoundError];
            }
            else if ([viewCtrl isKindOfClass:[ApprovalsTimeOffHistoryViewController class]])
            {
                ApprovalsTimeOffHistoryViewController *tempviewctrl=(ApprovalsTimeOffHistoryViewController*)viewCtrl;
                [self dismissModalViews];
                [tempviewctrl refreshActionForUriNotFoundError];
            }
            for (UIViewController *viewController in approvalsControllers)
            {
                if ([viewController isKindOfClass:[ApprovalsCountViewController class]]||[viewController isKindOfClass:[ApprovalsScrollViewController class]])
                {
                    [approvalsNavController.navigationController popToViewController:viewCtrl animated:YES];
                    return;
                }

            }

        }


    }
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    CLS_LOG(@"-----applicationDidReceiveMemoryWarning -----");
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark -
#pragma mark PUSH NOTIFICTAIONs
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);


    //        [Util errorAlert:@"" errorMessage:[Util stringWithDeviceToken:deviceToken]];

    self.deviceID=deviceToken;


}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);

    //        [Util errorAlert:@"" errorMessage:error.localizedDescription];
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }

    //    [Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"t"]]];

    if ([userInfo objectForKey:@"t"]!=nil && ![[userInfo objectForKey:@"t"] isKindOfClass:[NSNull class]])
    {
        if (!self.isAppInForeground)
        {
            NSArray *valueArr=[[userInfo objectForKey:@"t"] componentsSeparatedByString:@"/"];
            if ([valueArr count]>0)
            {
                [self getDeepLinkingWorkingForValue:[valueArr objectAtIndex:0]];
            }
            else
            {
                [self getDeepLinkingWorkingForValue:[userInfo objectForKey:@"t"]];
            }
        }

    }

    //    if ([userInfo objectForKey:@"b"]!=nil && ![[userInfo objectForKey:@"b"] isKindOfClass:[NSNull class]])
    //    {
    //        UIViewController *viewController = self.navController.visibleViewController;
    //
    //        MenuViewController *leftControllerClass=nil;
    //
    //
    //        if ([viewController isKindOfClass:[MenuViewController class]])
    //        {
    //            leftControllerClass=(MenuViewController *)viewController;
    //
    //        }
    //
    //
    //        if (leftControllerClass!=nil)
    //        {
    //            [leftControllerClass pushNotificationDataReceived:[userInfo objectForKey:@"b"]];
    //        }
    //    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo=notification.userInfo;

    NSString *uid=[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"uid"]];
    if ([uid isEqualToString:@"SyncQueueStatus"])
    {
        //Cancelling local notification
        [self.syncNotificationScheduler cancelNotification:uid];
        [[self.injector getInstance:[BaseSyncOperationManager class]] startSync];

    }
    else if ([uid isEqualToString:@"ErrorBackgroundStatus"])
    {
        //Cancelling local notification
        [self.syncNotificationScheduler cancelNotification:uid];
        BOOL isAlreadyLoggedIn=[self.standardUserDefaults boolForKey:@"isSuccessLogin"];

        if (!self.isAppInForeground && isAlreadyLoggedIn)
        {
            [self launchErrorDetailsViewController];
        }

    }

    NSDictionary *valueDict= [NSDictionary dictionaryWithObjectsAndKeys:[[userInfo objectForKey:@"proximityUUID"]copy],@"proximityUUID",[[userInfo objectForKey:@"major"]copy],@"major",[[userInfo objectForKey:@"minor"]copy],@"minor",nil];
    [self getDeepLinkingWorkingForValue:[userInfo objectForKey:@"notif"]];
    [self.beaconsCtrl performSelector:@selector(repliconBeaconWithBeaconRegionFromBeaconManager:) withObject: valueDict];

}

-(void)compareDataUpdateForLighWeightHomeFlowServiceWithNewDate:(NSMutableDictionary *)newDataDict
{
    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromLightWeightHomeFlowDatabase];
    NSMutableDictionary *oldDataDict=[userDetailsArr objectAtIndex:0];
    NSMutableArray *changedKs = [NSMutableArray array];
    for(id k in newDataDict) {
        if(![[newDataDict objectForKey:k] isEqual:[oldDataDict objectForKey:k]])
            [changedKs addObject:[NSDictionary dictionaryWithObject:[newDataDict objectForKey:k] forKey:k]];
    }

    if ([changedKs count]>0)
    {


    }


}

-(void)checkForAuthenticationAndRememberCredentials
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL isRememberMe=[defaults boolForKey:@"RememberMe"];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"]|| !isRememberMe)
    {
        [self launchLoginViewController:NO];

    }
    else
    {
        [self launchLoginViewController:YES];
    }
}




- (void)flipToTabbarController:(NSNumber *)tabIndex
{

    if (self.rootTabBarController.viewControllers != nil && [self.rootTabBarController.viewControllers count]>0)
    {
        UINavigationController *navigationType = [self.rootTabBarController.viewControllers objectAtIndex:[tabIndex intValue]];
        self.rootTabBarController.selectedViewController=navigationType;
        [navigationType popToRootViewControllerAnimated:NO];

    }
}

#pragma mark -
#pragma mark UPDATE BADGE

-(void)sendRequestForGettingUpdatedBadgeValue
{
    [self.loginService fetchGetMyNotificationSummary];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValue:)
    //                                                 name:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION
    //                                               object:nil];
}

-(void)updateBadgeValue:(NSNotification*)notification
{
    //    [[NSNotificationCenter defaultCenter] removeObserver: self name: GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object: nil];
    NSDictionary *dataDict=notification.userInfo;
    BOOL isError= TRUE;
    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    if (!isError) {
        [self updateBadgeCountForEachModule];
    }
}

- (void)updateBadgeCountForEachModule
{
    int appIconBadgeValue = 0;
    if (self.rootTabBarController.viewControllers != nil && [self.rootTabBarController.viewControllers count]>0) {
        for (NSUInteger index = 0; index<[self.rootTabBarController.viewControllers count]; index++) {
            UINavigationController *navigationType = [self.rootTabBarController.viewControllers objectAtIndex:index];
            if ([navigationType isKindOfClass:[TimesheetNavigationController class]] || [navigationType isKindOfClass:[PunchHomeNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:REJECTED_TIMESHEET_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:TIMESHEET_PAST_DUE_COUNT_KEY] intValue];
                if (badgeValue > 0)
                {
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
                    appIconBadgeValue = appIconBadgeValue +badgeValue;
                }
                else
                {
                    navigationType.tabBarItem.badgeValue = nil;
                }
            }
            else if ([navigationType isKindOfClass:[BookedTimeOffNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:REJECTED_TIMEOFF_BOOKING_COUNT_KEY] intValue];
                if (badgeValue > 0)
                {
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
                    appIconBadgeValue = appIconBadgeValue +badgeValue;
                }
                else
                {
                    navigationType.tabBarItem.badgeValue = nil;
                }
            }
            else if ([navigationType isKindOfClass:[ExpensesNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:REJECTED_EXPENSE_SHEETS_COUNT_KEY] intValue];
                if (badgeValue > 0)
                {
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
                    appIconBadgeValue = appIconBadgeValue +badgeValue;
                }
                else
                {
                    navigationType.tabBarItem.badgeValue = nil;
                }
            }
            else if ([navigationType isKindOfClass:[ApprovalsNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY] intValue];
                if (badgeValue > 0)
                {
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
                    appIconBadgeValue = appIconBadgeValue +badgeValue;
                }
                else
                {
                    navigationType.tabBarItem.badgeValue = nil;
                }
            }
            else if ([navigationType isKindOfClass:[SupervisorDashboardNavigationController class]]) {
                int badgeValue =[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY] intValue]+[[[NSUserDefaults standardUserDefaults] objectForKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY] intValue];
                
                
                if (badgeValue > 0)
                {
                    navigationType.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeValue];
                    appIconBadgeValue = appIconBadgeValue +badgeValue;
                }
                else
                {
                    navigationType.tabBarItem.badgeValue = nil;
                }
            }
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:appIconBadgeValue];
}

#pragma mark - <Callback for BackgroundURLSession>

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundURLSessionObserver.completionHandler = completionHandler;
}

#pragma mark - <Callback for Background Fetch>

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self.punchNotificationScheduler cancelNotification];
    
    if([self.userSession validUserSession])
    {
        
        [self.punchRevitalizer revitalizePunches];
        
        [self.injector getInstance:InjectorKeyErrorBannerViewController];
        [[self.injector getInstance:[BaseSyncOperationManager class]] startSync];
        TimesheetModel *timesheetModel = [[TimesheetModel alloc] init];
        if ([timesheetModel isTimesheetPending])
        {
            [self.syncNotificationScheduler cancelNotification:@"SyncQueueStatus"];
            [self.syncNotificationScheduler scheduleNotificationWithAlertBody:RPLocalizedString(syncTimesheetLocalNotificationMsg, @"") uid:@"SyncQueueStatus"];
        }
        else
        {
            [self.syncNotificationScheduler cancelNotification:@"SyncQueueStatus"];
        }
    }
    
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - <NSURLSession Callbacks: NSURLSessionDelegate>

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}


// urlsession is no more invalidated in URLSessionClient with the help of DoorKeeper.
// We defer the reset until either all the tasks are completed or cancelled.
// When NSURLSession either completes/invalidates all its tasks , it calls URLSession:didBecomeInvalidWithError:
// Hence at this point we can safely handle urlsession invalidate and call reset on it.

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    [session resetWithCompletionHandler:^{
    }];
}


#pragma mark - Helper Methods

- (void)setupPersistentDataStoreForApp {
    [AppPersistentStorage sharedInstance];
}

#pragma mark - AppShortCuts

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    BOOL handled = [[DeepLinkManager shared] handleShortcutWithItem:shortcutItem];
    completionHandler(handled);
}
@end
