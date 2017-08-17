#import <UIKit/UIKit.h>
#import "G2AppInitService.h"
#import "FrameworkImport.h"
#import "G2LoginViewController.h"
#import "G2HomeViewController.h"
#import "G2RootTabBarController.h"
#import "G2ChangePasswordViewController.h"
#import "G2SyncExpenses.h"
#import "G2SyncTimesheets.h"
#import "G2FreeTrialViewController.h"
#import "G2ResetPasswordViewController.h"
#import "G2MyCLController.h"
#import "G2CompanyViewController.h"
#import "G2SAMLWebViewController.h"
#import "FrameworkImport.h"

@interface RepliconAppDelegate : NSObject <UIApplicationDelegate, NetworkServiceProtocol, MyCLControllerDelegate> {
    UIWindow *window;
	G2LoginViewController *loginViewController;
    G2CompanyViewController *comapnyViewController;
    G2SAMLWebViewController *webViewController;
	G2ChangePasswordViewController *changePasswordViewController;
	UINavigationController *navController;

	G2RootTabBarController *rootTabBarController;

	G2SyncExpenses *syncExpenses;
	G2SyncTimesheets *syncTimesheets;

	UIImageView *splashScreenView;

	UIViewController *__weak currVisibleViewController;
	G2FreeTrialViewController *freeTrialViewController;
	G2ResetPasswordViewController *resetPasswordViewController;

    NSString *errorMessageForLogging;
    BOOL isAlertOn;
    BOOL isLockedTimeSheet;
    BOOL isLocationServiceEnabled;
    G2MyCLController *locationController;

    BOOL isFirstTimeAppLaunchedAtPunchClock;

    BOOL isShowPunchButton;
    BOOL isInOutTimesheet;
    BOOL hasApprovalPermissions;
    BOOL isInApprovalsMainPage;
    BOOL isAtHomeViewController;
    BOOL punchClockIsZeroTimeEntries;
    BOOL hasTimesheetLicenses;
    BOOL isMultipleTimesheetFormatsAssigned;

    //READ THIS FOR SELECTED TAB INDEX
    BOOL isUserPressedClosedLater;
    int currentSelectedTabindex;


    BOOL isNewInOutTimesheetUser;
    BOOL isAttestationPermissionTimesheets;
    BOOL isAcceptanceOfDisclaimerRequired;
    NSString *attestationTitleTimesheets, *attestationDescTimesheets, *disclaimerTitleTimesheets;
    BOOL isUpdatingDisclaimerAcceptanceDate;
    BOOL isTimeOffEnabled;
    BOOL isNotAppFirstTimeInstalled;
    BOOL isPopUpForSAMLAuthentication;
    G2PunchClockViewController *appDelegatePunchCtrl;
    NSMutableDictionary *thumbnailCache;
    NSString *userType;
    UIView *progressView;
    NSMutableDictionary *peristedLocalizableStringsDict;
}

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) NSMutableDictionary *thumbnailCache;
@property (nonatomic, strong) G2PunchClockViewController *appDelegatePunchCtrl;
@property (nonatomic, assign) BOOL isTimeOffEnabled;
@property (nonatomic, assign) BOOL isPopUpForSAMLAuthentication;
@property (nonatomic, assign) BOOL isNotAppFirstTimeInstalled;
@property (nonatomic, strong) NSString *attestationTitleTimesheets, *attestationDescTimesheets, *disclaimerTitleTimesheets;
@property (nonatomic, assign) BOOL isAttestationPermissionTimesheets;
@property (nonatomic, assign) BOOL isAcceptanceOfDisclaimerRequired;
@property (nonatomic, assign) int currentSelectedTabindex;
@property (nonatomic, assign) BOOL hasTimesheetLicenses;
@property (nonatomic, assign) BOOL punchClockIsZeroTimeEntries;
@property (nonatomic, assign) BOOL isAtHomeViewController;
@property (nonatomic, assign) BOOL isInApprovalsMainPage;
@property (nonatomic, assign) BOOL hasApprovalPermissions;
@property (nonatomic, assign) BOOL isShowPunchButton;
@property (nonatomic, assign) BOOL isFirstTimeAppLaunchedAtPunchClock;
@property (nonatomic, assign) BOOL isLocationServiceEnabled;
@property (nonatomic, strong) G2MyCLController *locationController;
@property (nonatomic, assign) NSUInteger selectedTab;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) G2LoginViewController *loginViewController;
@property (nonatomic, strong) G2CompanyViewController *comapnyViewController;
@property (nonatomic, strong) G2SAMLWebViewController *webViewController;
@property (nonatomic, strong) G2RootTabBarController *rootTabBarController;
@property (nonatomic, weak) UIViewController *currVisibleViewController;
@property (nonatomic, strong) NSString *errorMessageForLogging;
@property (nonatomic, assign) BOOL isAlertOn;
@property (nonatomic, assign) BOOL isLockedTimeSheet;
@property (nonatomic, assign) BOOL isInOutTimesheet;
@property (nonatomic, assign) BOOL isUserPressedCancel;
//DE4881 Ullas M L
@property (nonatomic, assign) BOOL isUpdatingDisclaimerAcceptanceDate;
@property (nonatomic, assign) BOOL isUserPressedClosedLater;
@property (nonatomic, assign) BOOL isNewInOutTimesheetUser;
@property (nonatomic, assign) BOOL isMultipleTimesheetFormatsAssigned;
@property (nonatomic, strong) NSString *userType;
@property (nonatomic, strong) NSMutableDictionary *peristedLocalizableStringsDict;
@property (nonatomic, readonly) GATracker *gaTracker;

- (void)startProgression:(NSString *)message;
- (void)stopProgression;
- (void)reloaDLogin;
- (void)launchLoginViewController;
- (void)launchHomeViewController;
- (void)flipToHomeViewController;
- (void)flipToTabbarController:(NSNumber *)tabIndex;
- (void)launchChangePasswordViewController:(id)delegate;
- (void)removeTabBarAfetrLogout;
- (void)networkActivated;
- (void)splashScreenTimer;

- (void)resetSavedTabOrder;
- (void)showTransitionPage:(UIViewController *)viewController;
- (void)hideTransitionPage:(UIViewController *)viewController;
//Image memory warning. This is a hack to show the memory warning only once
- (BOOL)expenseEntryMemoryWarning;
- (void)showSplashScreen;
- (void)hideSplashScreen;
- (void)launchFreeTrialSignUpController:(id)_delegate;
- (void)flipToLoginViewController;
- (void)launchResetPasswordViewController:(id)_delegate;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
- (void)removeAlertViews:(NSArray *)subviews;
- (void)launchCompanyViewController;
- (void)launchWebViewController;
- (void)reloadSAMLWebView;
- (void)showTransparentLoadingOverlay;
- (void)hideTransparentLoadingOverlay;
- (void)reloadCompanyView;
- (void)resetLocalisedFilesForGen2;

@end

