
//  RepliconAppDelegate.m
//  Replicon
//
//  Created by Devi Malladi on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepliconAppDelegate.h"
#import "G2ReceiptsViewController.h"
#import "G2ExpensesNavigationController.h"
#import "Flurry.h"
#import "G2ApprovalsNavigationController.h"
#import "SNLog.h"
#import "FrameworkImport.h"
#define Image_Alert_tag_Add 50
//US4024//Juhi


void uncaughtExceptionHandlerGen2(NSException *exception) {
    @try {
        NSString *userID=nil;
        NSString *companyName=nil;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"]isKindOfClass:[NSNull class] ])
        {
            userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];

        }

        NSDictionary *credDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
        if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
            companyName = [credDict objectForKey:@"companyName"];
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

        if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
        {
            [Flurry logError:@"uncaught"
                     message:message
                   exception:exception];
        }


    }
    @catch (NSException *exception) {
        [Flurry logError:@"uncaught"
                 message:@"whoa!  could not handle uncaught exception!"
               exception:exception];
        DLog(@"whoa!  could not handle uncaught exception!");
    }
}

@interface RepliconAppDelegate ()

@property (nonatomic) GATracker *gaTracker;

@end

@implementation RepliconAppDelegate

@synthesize window;
@synthesize loginViewController;
@synthesize rootTabBarController;
@synthesize navController;
@synthesize currVisibleViewController;
@synthesize  errorMessageForLogging;
@synthesize isAlertOn;
@synthesize isLockedTimeSheet;
@synthesize selectedTab;
@synthesize  locationController;
@synthesize  isLocationServiceEnabled;
@synthesize isFirstTimeAppLaunchedAtPunchClock;
@synthesize  isShowPunchButton;
@synthesize isInOutTimesheet;
@synthesize isUserPressedCancel;//DE4881 Ullas M L
@synthesize  hasApprovalPermissions;
@synthesize isInApprovalsMainPage;
@synthesize isAtHomeViewController;
@synthesize punchClockIsZeroTimeEntries;
@synthesize  hasTimesheetLicenses;
@synthesize currentSelectedTabindex;
@synthesize progressView;
@synthesize isAttestationPermissionTimesheets;
@synthesize isAcceptanceOfDisclaimerRequired;
@synthesize  attestationTitleTimesheets,attestationDescTimesheets,disclaimerTitleTimesheets;
@synthesize isUpdatingDisclaimerAcceptanceDate;
@synthesize isUserPressedClosedLater;
@synthesize isMultipleTimesheetFormatsAssigned;
static long lastSyncTime;
static BOOL imageMemoryWarningShown = NO;
@synthesize isNewInOutTimesheetUser;
@synthesize isNotAppFirstTimeInstalled;
@synthesize comapnyViewController;
@synthesize webViewController;
@synthesize isPopUpForSAMLAuthentication;
@synthesize isTimeOffEnabled;
@synthesize  appDelegatePunchCtrl;
@synthesize thumbnailCache;
@synthesize userType;
@synthesize peristedLocalizableStringsDict;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandlerGen2);
    if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
        [Flurry setShowErrorInLogEnabled:YES];
        [Flurry setCrashReportingEnabled:YES];
    }
    [Flurry startSession:@"F7FD6FHXQX31X28578T6"];

     self.gaTracker = [[GATracker alloc] init];

    if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK)
    {
        NSLog(@"Can now use sqlite on multiple threads, using the same connection");
    }

        //      hasApprovalPermissions=TRUE;
    isInApprovalsMainPage=FALSE;
    isFirstTimeAppLaunchedAtPunchClock=FALSE;
    isShowPunchButton=TRUE;
	[self resetSavedTabOrder];
    // Override point for customization after application launch.
    [[G2AppInitService getInstance] initApplication];
	[NetworkMonitor sharedInstance];
//    isNotAppFirstTimeInstalled=TRUE;

   NSMutableDictionary *tempThumbnailCache=[[NSMutableDictionary alloc]init];
    self.thumbnailCache=tempThumbnailCache;

    UIWindow *tmpWindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window=tmpWindow;
  
    self.window.rootViewController = [[UITabBarController alloc] init];

    [self.window makeKeyAndVisible];


    [self resetLocalisedFilesForGen2];


        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {

            BOOL isLoginSuccessfull=[[NSUserDefaults standardUserDefaults] boolForKey:@"isSuccessLogin"];
            if (isLoginSuccessfull)
            {
                if(![NetworkMonitor isNetworkAvailableForListener: self])
                {

                    [G2Util showOfflineAlert];
                }
                else
                {


                    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    appdelegate.errorMessageForLogging=@"";
                    appdelegate.isAlertOn=FALSE;

                     [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
                    G2LoginService *loginService = [G2RepliconServiceManager loginService];
                    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"];
                    [[G2TransitionPageViewController getInstance] setDelegate: loginService];
                    [loginService sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:loginService forUsername:userName];

                }


            }
            else
            {
                float version=[[UIDevice currentDevice].systemVersion newFloatValue];
                if (version>=7.0)
                {
                    [self launchCompanyViewController];

                    if(![NetworkMonitor isNetworkAvailableForListener: self])
                    {

                        [G2Util showOfflineAlert];


                    }
                    else
                    {
                        [self startProgression:LoadingMessage];

                        [self performSelectorInBackground:@selector(openURLInSafari) withObject:nil];



                        //                    [[RepliconServiceManager loginService] sendrequestToFetchNewAuthRemoteAPIUrl:self];
                    }

                }
                else
                {
                    [self launchWebViewController];
                }
            }





        }
        else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"]!=nil)
        {
             isNotAppFirstTimeInstalled=TRUE;

            BOOL isLoginSuccessfull=[[NSUserDefaults standardUserDefaults] boolForKey:@"isSuccessLogin"];
            if (isLoginSuccessfull)
            {
                if(![NetworkMonitor isNetworkAvailableForListener: self])
                {

                    [G2Util showOfflineAlert];
                }
                else
                {


                    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    appdelegate.errorMessageForLogging=@"";
                    appdelegate.isAlertOn=FALSE;


                    G2LoginService *loginService = [G2RepliconServiceManager loginService];
                    [G2TransitionPageViewController startProcessForType: ProcessType_Login withData: [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] withDelegate: loginService];

                }


            }
            else
            {
                 [self launchLoginViewController];
            }



        }
        else
        {
            int isSupportSAML = [[G2SQLiteDB getIsSupportForSAML:@"version_info" :@"isSupportSAML"]intValue];

            if (isSupportSAML==1)
            {
                 [self launchCompanyViewController];
            }
            else {
                isNotAppFirstTimeInstalled=TRUE;
                 [self launchLoginViewController];

            }


        }

	[[NetworkMonitor sharedInstance] queueTheListener:self];

	if(syncExpenses == nil) {
		syncExpenses = [[G2SyncExpenses alloc] init];
	}
	if (syncTimesheets == nil) {
		syncTimesheets = [[G2SyncTimesheets alloc] init];
	}

    if (TARGET_IPHONE_SIMULATOR) {

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
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

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"applicationWillResignActive");
}

-(void)showSplashScreen
{
}

-(void)hideSplashScreen
{
	if (splashScreenView != nil) {
		[splashScreenView removeFromSuperview];

		splashScreenView = nil;
	}
	if (isLockedTimeSheet && ![[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeLogging"]) {
         NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"TabBarModulesArray"];
        [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:)
                                                           withObject:[NSNumber numberWithUnsignedInteger:[modulesArray count]-1]];
        [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:)
                                                           withObject:[NSNumber numberWithInt:0]];
    }

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	DLog(@"applicationDidEnterBackground");
	[self showSplashScreen];
    [self removeAlertViews:application.windows];
    isFirstTimeAppLaunchedAtPunchClock=FALSE;
}


- (void)removeAlertViews:(NSArray *)subviews {
       for (UIView * subview in subviews){
        if ([subview isKindOfClass:[UIAlertView class]])
        {

             if (!isPopUpForSAMLAuthentication)
             {
                    [(UIAlertView *)subview dismissWithClickedButtonIndex:[(UIAlertView *)subview cancelButtonIndex] animated:NO];
             }

           //THIS IS TO HANDLE THE SESSION TIMEOUT ALERT FOR SAML USERS
             if (subview.tag==SAML_SESSION_TIMEOUT_TAG)
             {
                   [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
            }


        }

        else if ([subview isKindOfClass:[UIActionSheet class]]){
            [(UIActionSheet *)subview dismissWithClickedButtonIndex:[(UIAlertView *)subview cancelButtonIndex] animated:NO];
        }
        else {
            [self removeAlertViews:subview.subviews];
        }

    }



}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	DLog(@"applicationWillEnterForeground");

    [self stopProgression];
	//[self showSplashScreen];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */


	DLog(@"applicationDidBecomeActive");

    // gaTracker
    // Set any previously stored login credentials in Google tracker
     NSDictionary *loginCredentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    NSString *userUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
    if (userUri != nil) {
        NSString *companyName = [loginCredentials objectForKey:@"companyName"];
        NSString *username = [loginCredentials objectForKey:@"userName"];
        [self.gaTracker setUserUri:userUri companyName:companyName username:username platform:@"gen2"];
    }
   [self.gaTracker trackScreenView:@"application" forTracker:TrackerProduct];
    

    if (!isFirstTimeAppLaunchedAtPunchClock) {
        if (isLockedTimeSheet) {
            [self startProgression:LoadingMessage];

            punchClockIsZeroTimeEntries=TRUE;
            selectedTab=0;
            NSArray *navViewCtrlsArr=[self.navController viewControllers];
            for (int i=0;i<[navViewCtrlsArr count]; i++) {
                if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2HomeViewController class]]) {
                    [[NSNotificationCenter defaultCenter] removeObserver: [navViewCtrlsArr objectAtIndex:i] name: @"allTimesheetRequestsServed" object: nil];
                    [[NSNotificationCenter defaultCenter] addObserver: [navViewCtrlsArr objectAtIndex:i]
                                                             selector: @selector(handleProcessCompleteActions)
                                                                 name: @"allTimesheetRequestsServed"
                                                               object: nil];

                    break;

                }
            }

            for (int i=0;i<[navViewCtrlsArr count]; i++) {
                if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) {

                    NSArray *rootViewCtrlsArr=[[navViewCtrlsArr objectAtIndex:i] viewControllers];

                    for (int j=0; j<[rootViewCtrlsArr count]; j++) {
                        if ([[rootViewCtrlsArr objectAtIndex:j] isKindOfClass:[G2ExpensesNavigationController class]])
                        {
                           NSArray *expensesViewCtrlsArr=[[rootViewCtrlsArr objectAtIndex:j] viewControllers];

                            for (int k=0; k<[expensesViewCtrlsArr count]; k++) {
                                if ([[expensesViewCtrlsArr objectAtIndex:k] isKindOfClass:[G2ListOfExpenseSheetsViewController class]])
                                {
                                    [[expensesViewCtrlsArr objectAtIndex:k] dismissViewControllerAnimated:NO completion:nil];
                                }

                            }

                        }
                        else  if ([[rootViewCtrlsArr objectAtIndex:j] isKindOfClass:[G2TimesheetNavigationController class]])
                        {
                            NSArray *timeSheetsViewCtrlsArr=[[rootViewCtrlsArr objectAtIndex:j] viewControllers];

                            for (int k=0; k<[timeSheetsViewCtrlsArr count]; k++) {
                                if ([[timeSheetsViewCtrlsArr objectAtIndex:k] isKindOfClass:[G2ListOfTimeSheetsViewController class]])
                                {
                                    G2ListOfTimeSheetsViewController *listTsViewCtrl=[timeSheetsViewCtrlsArr objectAtIndex:k];
                                    if (listTsViewCtrl.navcontroller!=nil)
                                    {
                                        [listTsViewCtrl.navcontroller dismissViewControllerAnimated:NO completion:nil];
                                    }


                                }
                                else if ([[timeSheetsViewCtrlsArr objectAtIndex:k] isKindOfClass:[G2ListOfTimeEntriesViewController class]])
                                {
                                    G2ListOfTimeEntriesViewController *listTsEntriesViewCtrl=[timeSheetsViewCtrlsArr objectAtIndex:k];
                                    if (listTsEntriesViewCtrl.navcontroller!=nil)
                                    {
                                        [listTsEntriesViewCtrl.navcontroller dismissViewControllerAnimated:NO completion:nil];
                                    }


                                }
                            }

                        }
                    }
                }
            }

        }

       else
        {
            if (hasApprovalPermissions)
            {
                if (isAtHomeViewController)
                {
                    NSArray *navViewCtrlsArr=[self.navController viewControllers];
                    for (int i=0;i<[navViewCtrlsArr count]; i++) {
                        if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2HomeViewController class]])
                        {
                            G2HomeViewController *homeCtrl=[navViewCtrlsArr objectAtIndex:i];

                            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
                            [[NSNotificationCenter defaultCenter] removeObserver: homeCtrl name: APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object: nil];
                            [[NSNotificationCenter defaultCenter] addObserver: homeCtrl
                                                                     selector: @selector(handleDownloadingApprovalsCount)
                                                                         name: APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION
                                                                       object: nil];
                            [[G2RepliconServiceManager approvalsService] sendRequestToLoadUser];
                        }

                    }

                }

            }
        }
        [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.5];
    }

   if (hasApprovalPermissions && !isFirstTimeAppLaunchedAtPunchClock)
    {
        [  [NSNotificationCenter defaultCenter] removeObserver: self name: APPDELEGATE_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDownloadingApprovalsCount)
                                                     name: APPDELEGATE_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION
                                                   object: nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
        [[G2RepliconServiceManager appDelegateService] sendRequestToLoadUser];
    }




}

-(void)handleDownloadingApprovalsCount
{
    [  [NSNotificationCenter defaultCenter] removeObserver: self name: APPDELEGATE_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object: nil];

    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];

    DLog(@"%@",[self.navController viewControllers]);
    if (hasApprovalPermissions)
    {

        NSArray *navViewCtrlsArr=[self.navController viewControllers];
        if (isAtHomeViewController)
        {

            for (int i=0;i<[navViewCtrlsArr count]; i++) {
                if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2HomeViewController class]])
                {
                    G2HomeViewController *homeCtrl=[navViewCtrlsArr objectAtIndex:i];
                    int badgeValue=[[standardUserDefaults objectForKey:@"NumberOfTimesheetsPendingApproval" ] intValue];
                    if (badgeValue>0)
                    {
                        [homeCtrl.badgeButton setTitle:[NSString stringWithFormat:@"%d",badgeValue] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [homeCtrl.badgeButton removeFromSuperview];
                    }

                    break;
                }

            }

        }

        for (int i=0;i<[navViewCtrlsArr count]; i++)
        {
            if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]])
            {
                G2RootTabBarController *rootTabCtrl=[navViewCtrlsArr objectAtIndex:i];
                NSArray *rootCtrlsArray=rootTabCtrl.viewControllers;
                for (int j=0;j<[rootCtrlsArray count]; j++)
                {
                    if ([[rootCtrlsArray objectAtIndex:j ] isKindOfClass:[G2ApprovalsNavigationController class] ])
                    {
                        G2ApprovalsNavigationController *approvalNavCtrl=[rootCtrlsArray objectAtIndex:j];
                        int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];

                        int previousBadgeValue=[approvalNavCtrl.tabBarItem.badgeValue intValue];
                        if (badgeValue>0)
                        {
                            approvalNavCtrl.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d", badgeValue];
                        }
                        else
                        {
                            approvalNavCtrl.tabBarItem.badgeValue=nil;
                        }


                        if ([rootTabCtrl.selectedViewController isKindOfClass:[G2ApprovalsNavigationController class]] && !isLockedTimeSheet)
                        {
                            if (previousBadgeValue!=badgeValue)
                            {
                                 [approvalNavCtrl popToRootViewControllerAnimated:FALSE];
                            }


                        }

                        break;
                    }
                }



            }
        }


    }


    if (!isLockedTimeSheet)
    {
        [self performSelector:@selector(stopProgression)];
    }

}

-(void)splashScreenTimer
{
		[splashScreenView removeFromSuperview];
		splashScreenView=nil;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	DLog(@"applicationWillTerminate");

	NSMutableArray *tabsSavedOrder = [NSMutableArray array];
	NSArray *tabsOrderToSave=nil;
	//if (rootTabBarController!=nil)
	tabsOrderToSave = rootTabBarController.viewControllers;

	for (UIViewController *allViewController in tabsOrderToSave) {
		[tabsSavedOrder addObject:allViewController.tabBarItem.title];
	}
	if (tabsSavedOrder!=nil)
		[[NSUserDefaults standardUserDefaults] setObject:tabsSavedOrder forKey:@"savedTabOrder"];

    //MOBI-1148 FIX comment the below lines

//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCookies"])
//    {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SSOCookies"];
//    }




    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetSavedTabOrder {
	if (splashScreenView!=nil){
		[ splashScreenView removeFromSuperview];
		splashScreenView=nil;
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedOrder = [defaults arrayForKey:@"savedTabOrder"];
	NSMutableArray *orderedTabs = [NSMutableArray array];
	if (savedOrder!=nil && [savedOrder count] > 0 ) {
		for (int i = 0; i < [savedOrder count]; i++){
			for (UIViewController *selectedController in rootTabBarController.viewControllers) {
				if ([selectedController.tabBarItem.title isEqualToString:[savedOrder objectAtIndex:i]]) {
					[orderedTabs addObject:selectedController];

				}
			}
		}
		rootTabBarController.viewControllers = orderedTabs;
	}
	if (rootTabBarController!=nil)
		[self.window addSubview:rootTabBarController.view];
}




-(void)reloaDLogin
{
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	//[self.navController setViewControllers:nil];
	[navController.view removeFromSuperview];
	//[self.window removeFromSuperview];
	[self removeTabBarAfetrLogout];
	[self launchLoginViewController];

}

-(void)reloadSAMLWebView
{

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];

	[navController.view removeFromSuperview];

	[self removeTabBarAfetrLogout];
	[self launchWebViewController];
}

-(void)reloadCompanyView
{

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];

	[navController.view removeFromSuperview];

	[self removeTabBarAfetrLogout];
	[self launchCompanyViewController];
}

-(void)removeTabBarAfetrLogout
{
	if (rootTabBarController!=nil) {

        NSArray *navViewCtrlsArr=[self.navController viewControllers];
        for (int i=0;i<[navViewCtrlsArr count]; i++) {
            if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) {

                NSArray *rootViewCtrlsArr=[[navViewCtrlsArr objectAtIndex:i] viewControllers];

                for (int j=0; j<[rootViewCtrlsArr count]; j++) {
                    if ([[rootViewCtrlsArr objectAtIndex:j] isKindOfClass:[G2ExpensesNavigationController class]])
                    {
                        NSArray *expensesViewCtrlsArr=[[rootViewCtrlsArr objectAtIndex:j] viewControllers];

                        for (int k=0; k<[expensesViewCtrlsArr count]; k++) {
                            if ([[expensesViewCtrlsArr objectAtIndex:k] isKindOfClass:[G2ListOfExpenseSheetsViewController class]])
                            {

                                G2ListOfExpenseSheetsViewController *listOfExpenseSheetsViewController=(G2ListOfExpenseSheetsViewController *) [expensesViewCtrlsArr objectAtIndex:k];
//                                if (listOfExpenseSheetsViewController.tappedIndexPath) {
//
//                                }

                                listOfExpenseSheetsViewController.tappedIndexPath =nil;
                                break;
                            }

                        }
                        break;
                    }
                }
                break;
            }
        }


		rootTabBarController = nil;
		[rootTabBarController.view removeFromSuperview];
	}
   //	[window addSubview:progressView];
}

- (void) launchLoginViewController {

	loginViewController = [[G2LoginViewController alloc]init];
    if (self.comapnyViewController)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        [self.comapnyViewController.view removeFromSuperview];
    }

    for (UIView *view in self.window.subviews)
    {
        if (view)
        {
          [view removeFromSuperview];
        }
    }
	//self.window.rootViewController = self.tabBarController
	[self.window addSubview:loginViewController.view];
    [self.window bringSubviewToFront:loginViewController.view];
   //	[window addSubview:progressView];


}

- (void) launchCompanyViewController {
	G2CompanyViewController *tempcomapnyViewController = [[G2CompanyViewController alloc]init];
	self.comapnyViewController = tempcomapnyViewController;


	[self.window addSubview:self.comapnyViewController.view];
    //	[window addSubview:progressView];

}

- (void) launchWebViewController {
    if (self.webViewController)
    {
        [self.webViewController.view removeFromSuperview];
    }

    for (UIView *view in self.window.subviews)
    {
        if (view)
        {
            [view removeFromSuperview];
        }


    }

	G2SAMLWebViewController *tempwebViewController = [[G2SAMLWebViewController alloc]init];
	self.webViewController = tempwebViewController;

	self.webViewController.urlAddress= [[NSUserDefaults standardUserDefaults] objectForKey:@"RequestServiceURL"];
    [self.comapnyViewController.view removeFromSuperview];
	[self.window addSubview:self.webViewController.view];

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    //	[window addSubview:progressView];


}

-(void)launchResetPasswordViewController:(id)_delegate {
	if (loginViewController != nil) {
		[loginViewController.view removeFromSuperview];
	}
	resetPasswordViewController = [[G2ResetPasswordViewController alloc] init];
	[resetPasswordViewController setDelegate:_delegate];
	if (navController != nil) {
		navController = nil;
		[navController.view removeFromSuperview];
	}
	navController = [[UINavigationController alloc] initWithRootViewController:resetPasswordViewController];
	[self.window addSubview:navController.view];
}

-(void)launchFreeTrialSignUpController:(id)_delegate{
	//DLog(@"launchFreeTrialSignUpController");
	if (loginViewController != nil) {
		[loginViewController.view removeFromSuperview];
	}
	freeTrialViewController = [[G2FreeTrialViewController alloc] init];
	[freeTrialViewController setDelegate:_delegate];
	if (navController != nil) {
		navController=nil;
		[navController.view removeFromSuperview];
		navController=[[UINavigationController alloc]initWithRootViewController:freeTrialViewController];
	}else {
		navController=[[UINavigationController alloc]initWithRootViewController:freeTrialViewController];
	}
	[self.window addSubview:navController.view];
}
-(void)flipToLoginViewController{
	//DLog(@"Flip To Login View Controller");
	if (freeTrialViewController!=nil) {
		//rootTabBarController = nil;
		[freeTrialViewController.view removeFromSuperview];
	}
	if (resetPasswordViewController != nil) {
		[resetPasswordViewController.view removeFromSuperview];
	}
	if (loginViewController == nil) {
		loginViewController = [[G2LoginViewController alloc]init];
	}
	[self.window addSubview:loginViewController.view];


}
- (void) launchChangePasswordViewController:(id)delegate {


	[loginViewController.view removeFromSuperview];

	if (changePasswordViewController != nil) {
		changePasswordViewController=nil;
		[changePasswordViewController.view removeFromSuperview];
		changePasswordViewController=[[G2ChangePasswordViewController alloc]init];
	}else {
		changePasswordViewController=[[G2ChangePasswordViewController alloc]init];
	}
	//DLog(@"DELEGTE :APP DELEGATE %@",delegate);
	[changePasswordViewController setLoginDelegate:delegate];
	if (navController != nil) {
		[navController.view removeFromSuperview];
		navController=nil;
		navController=[[UINavigationController alloc]initWithRootViewController:changePasswordViewController];
	}else {
		navController=[[UINavigationController alloc]initWithRootViewController:changePasswordViewController];
	}

	[self.window addSubview:navController.view];
//	[window addSubview:progressView];
}
- (void)launchHomeViewController {




	if (changePasswordViewController != nil) {
		[changePasswordViewController.view removeFromSuperview];
	}else {

		[loginViewController.view removeFromSuperview];
	}

	G2HomeViewController *homeViewController = [[G2HomeViewController alloc] init];

	if (navController != nil) {
		navController=nil;
		[navController.view removeFromSuperview];
		navController=[[UINavigationController alloc]initWithRootViewController:homeViewController];
	}else {
		navController=[[UINavigationController alloc]initWithRootViewController:homeViewController];
	}

    if (rootTabBarController!=nil) {


		rootTabBarController = nil;
        [rootTabBarController.view removeFromSuperview];

	}

    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
         self.navController.interactivePopGestureRecognizer.enabled = NO;
    }


	[navController popToRootViewControllerAnimated:YES];

	[self.window addSubview:navController.view];
    //	[window addSubview:progressView];
	[self performSelector:@selector(stopProgression)];
}

-(void)flipToHomeViewController{

	if (rootTabBarController!=nil) {


		rootTabBarController = nil;
        [rootTabBarController.view removeFromSuperview];

	}
	[navController popToRootViewControllerAnimated:YES];
//	[window addSubview:progressView];

}

-(void)flipToTabbarController: (NSNumber *)tabIndex{
;
	if (rootTabBarController == nil) {
		rootTabBarController = [[G2RootTabBarController alloc] init];
//		[rootTabBarController retain];



        [self.navController pushViewController:rootTabBarController animated:NO];
        //[[NSNotificationCenter defaultCenter]postNotificationName: @"SelectedTab" object: tabIndex];

//        rootTabBarController = nil;
        [self.window addSubview: [self.navController view]];
	}

    self.currentSelectedTabindex=[tabIndex intValue];
    [[NSNotificationCenter defaultCenter]postNotificationName: @"SelectedTab" object: tabIndex];

}

-(void) showTransitionPage: (UIViewController *) viewController	{
	[self.window addSubview: viewController.view];
}

-(void) hideTransitionPage: (UIViewController *) viewController	{
	[viewController.view removeFromSuperview];
}
#pragma mark NetworkMonitor

-(void) networkActivated {

	//[syncExpenses syncModifiedExpenses:nil];
	DLog(@"network activated in appdelegate");
	NSNumber *syncTimeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSyncTime"];
	if (syncTimeNumber == nil) {
		lastSyncTime = 0;
	}
	else {
		lastSyncTime = [syncTimeNumber longValue];
	}

	if ([[NetworkMonitor sharedInstance] networkAvailable] &&
		(lastSyncTime + [[[G2AppProperties getInstance] getAppPropertyFor:@"OfflineDataSyncIntervalSeconds"] longValue] <=
		 [[NSDate date] timeIntervalSince1970]))
	{
		DLog(@"network activated to sync");
		lastSyncTime = [[NSDate date] timeIntervalSince1970];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:lastSyncTime] forKey:@"lastSyncTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		[syncExpenses performSelectorInBackground:@selector(syncModifiedExpenses:) withObject:nil];
		[syncTimesheets performSelectorInBackground:@selector(syncModifiedTimesheets:) withObject:nil];
	}
}



#pragma mark -
#pragma mark UIActivityIndicatorView

- (void) startProgression:(NSString*)message{

/*	if (![progressView isAnimating]) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[progressView startAnimating];
		[window addSubview: progressView];
	}
*/
	G2TransitionPageViewController *transObj = [G2TransitionPageViewController getInstance];
	[self showTransitionPage:transObj];
	[[transObj lable] setText:RPLocalizedString(message, message) ];

	[self.window setUserInteractionEnabled:NO];
}

- (void) stopProgression{

/*	if ([progressView isAnimating]) {
		[progressView stopAnimating];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
*/

		[self hideTransitionPage:[G2TransitionPageViewController getInstance]];


	[self.window setUserInteractionEnabled:YES];

}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
	 */
}

#pragma mark -
#pragma mark Image Memory Warning


//ravi - This is a hack
-(BOOL) expenseEntryMemoryWarning
{
	//if (currVisibleViewController != nil && currVisibleViewController != NULL &&
	//	([currVisibleViewController isKindOfClass: [EditExpenseEntryViewController class]] ||
	//	 [currVisibleViewController isKindOfClass: [AddNewExpenseViewController class]]))
	if(currVisibleViewController != nil && ![currVisibleViewController isKindOfClass: [NSNull class]] &&
	   [currVisibleViewController isKindOfClass: [G2ReceiptsViewController class]])
	{
		if (!imageMemoryWarningShown) {
			imageMemoryWarningShown = YES;
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(OK_BTN_TITLE, OK_BTN_TITLE)
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

- (void)locationUpdate:(CLLocation *)location {
//	DLog(@"UPDATE LOCATION:: %@", [location description] );
     isLocationServiceEnabled=TRUE;
}

- (void)locationError:(NSError *)error {
//	DLog(@"ERROR LOCATION:: %@", [error description] );
    isLocationServiceEnabled=FALSE;
}

-(void)showTransparentLoadingOverlay
{
    if (progressView == nil) {
		UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setFrame:CGRectMake(135, 220, 50, 50)];
        [indicatorView setHidesWhenStopped:YES];
        [indicatorView startAnimating];
        [tempView addSubview:indicatorView];
        if ([[[UIDevice currentDevice] systemVersion] newFloatValue] >= 5.0f) {
            indicatorView.color=[UIColor blackColor];
        }

        tempView.backgroundColor=[UIColor whiteColor];
        tempView.alpha=0.5;
        self.progressView=tempView;


	}

    [[[UIApplication sharedApplication] keyWindow] addSubview:self.progressView];
}

-(void)hideTransparentLoadingOverlay
{
    [self.progressView removeFromSuperview];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Display text

    NSString *guid = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        [self startProgression:LoadingMessage];
        [[G2RepliconServiceManager loginService] sendrequestToCompleteSAMLFlow:guid];
    }

    return YES;
}

-(void)openURLInSafari
{
    NSString *openUrl=[[NSUserDefaults standardUserDefaults] objectForKey:@"RequestServiceURL"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
}

-(void)resetLocalisedFilesForGen2
{
    BOOL success;
    NSError *error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory1 stringByAppendingPathComponent:@"Localizable.strings"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
    {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    NSString *defaultDBPath1 = [[NSBundle mainBundle] pathForResource:@"G2Localizable" ofType:@"strings"];
    success = [fileManager copyItemAtPath:defaultDBPath1 toPath:writableDBPath error:&error];
    if (!success)
    {
        [SNLog Log:2 withFormat:[NSString stringWithFormat:@"FAILED TO COPY LOCALISED FILE !!!!"]];

    }

    NSString *defaultDBPath2 = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];
    success = [fileManager fileExistsAtPath:defaultDBPath2];
    if (success)
    {
        [fileManager removeItemAtPath:defaultDBPath2 error:&error];
    }
    success = [fileManager copyItemAtPath:defaultDBPath1 toPath:defaultDBPath2 error:&error];
    if (!success)
    {
        [SNLog Log:2 withFormat:[NSString stringWithFormat:@"FAILED TO COPY LOCALISED FILE !!!!"]];

    }



    self.peristedLocalizableStringsDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:defaultDBPath2]];
}


@end
