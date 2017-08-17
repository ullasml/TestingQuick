#import <UIKit/UIKit.h>
#import "FrameworkImport.h"
#import "LoginViewController.h"
#import "ResetPasswordViewController.h"
#import "AppRatingViewController.h"
#import "RateView.h"
#import <CoreLocation/CoreLocation.h>
#import "SpinnerDelegate.h"
#import "TabProvider.h"
#import "SCHBeaconsViewController.h"
#import "LaunchLoginDelegate.h"
#import "LoginDelegate.h"
#import "Router.h"
#import "HomeSummaryDelegate.h"
#import "CookiesDelegate.h"
#import "PunchRequestHandler.h"
#import "EventTracker.h"
#import "BadgesDelegate.h"
#import "ModulesGATracker.h"

@class ModuleStorage;
@class LoginCredentialsHelper;
@class GATracker;
@class UserPermissionsStorage;
@class BreakTypeRepository;
@class KeychainProvider;
@class DefaultActivityStorage;
@class SyncNotificationScheduler;
@class PunchNotificationScheduler;
@protocol BSInjector;
@protocol UserSession;



@interface AppDelegate : UIResponder <UIApplicationDelegate, RateViewDelegate, MFMailComposeViewControllerDelegate, SpinnerDelegate, LaunchLoginDelegate, LoginDelegate, Router, UITabBarControllerDelegate, HomeSummaryDelegate, CookiesDelegate,NetworkServiceProtocol,BadgesDelegate, UINavigationControllerDelegate,NSURLSessionDelegate>
{
    UIView *progressView;


    NSMutableDictionary *thumbnailCache;
    UINavigationController *navController;
    UIActivityIndicatorView *indicatorView;

    LoginViewController *loginViewController;


    NSTimer *syncTimer;
    UIViewController *__weak currVisibleViewController;
    BOOL isShowTimeSheetPlaceHolder,isShowExpenseSheetPlaceHolder,isShowTimeOffSheetPlaceHolder;
    BOOL isCountPendingSheetsRequestInQueue;
    BOOL isNotFirstTimeLaunch;
    NSString *deepLinkingLaunchModule;
    NSTimer *deepLinkingTimer;
    UIImageView *trackTimeIconImgView;
    SCHBeaconsViewController *beaconsCtrl;

    NSString *selectedModuleName;
}

@property (nonatomic, weak) UIViewController *currVisibleViewController;
@property (nonatomic) BOOL isNotFirstTimeLaunch;
@property (nonatomic) BOOL isCountPendingSheetsRequestInQueue;
@property (nonatomic) UIWindow *window;
@property (nonatomic) UIView *progressView;

@property (nonatomic) BOOL isLockedTimeSheet;
@property (nonatomic) NSMutableDictionary *thumbnailCache;
@property (nonatomic) LoginViewController *loginViewController;
@property (nonatomic,readonly) UITabBarController *rootTabBarController;
@property (nonatomic) UINavigationController *navController;
@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic) NSTimer *syncTimer;
@property (nonatomic) NSMutableDictionary *peristedLocalizableStringsDict;
@property (nonatomic) NSString *deepLinkingLaunchModule;
@property (nonatomic) NSTimer *deepLinkingTimer;
@property (nonatomic) ResetPasswordViewController *resetPasswordViewController;
@property (nonatomic) UIImageView *trackTimeIconImgView;
@property (nonatomic) CLLocationManager *locationManagerTemp;
@property (nonatomic) AppRatingViewController *appRatingViewController;
@property (nonatomic) NSData *deviceID;
@property (nonatomic) SCHBeaconsViewController *beaconsCtrl;

@property (nonatomic, assign) BOOL isShowTimeSheetPlaceHolder, isShowExpenseSheetPlaceHolder, isShowTimeOffSheetPlaceHolder;
@property (nonatomic, assign) BOOL showCompanyView;

@property (nonatomic) NSUserDefaults *standardUserDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) DefaultActivityStorage *defaultActivityStorage;
@property (nonatomic) KeychainProvider *keychainProvider;
@property (nonatomic) LoginService *loginService;
@property (nonatomic) GATracker *tracker;
@property (nonatomic) LoginCredentialsHelper *loginCredentialsHelper;
@property (nonatomic, assign) BOOL isAppInForeground;

@property (nonatomic) BOOL isReceivedOldHomeFlowServiceData;
@property (nonatomic, strong) NSString *selectedModuleName;

@property (nonatomic, readonly) PunchRequestHandler *punchRequestHandler;

@property (nonatomic, readonly) id<BSInjector> injector;
@property (nonatomic) SyncNotificationScheduler *syncNotificationScheduler;
@property (nonatomic) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic, assign) BOOL isWaitingForDeepLinkToErrorDetails;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) ModuleStorage *moduleStorage;

- (void)launchViewForFirstTimeLoad;
- (void)updateLoginViewController:(NSString *)urlString;
- (void)launchLoginViewController:(BOOL)showPasswordField;
- (void)launchLoginViewController;

- (void)sendRequestForGetHomeSummary;
- (void)showTransparentLoadingOverlay;
- (void)hideTransparentLoadingOverlay;
- (void)flipToHomeViewController;
- (void)loadCookie;
- (void)deleteCookies;
- (void)networkActivated;
- (void)startSyncTimer;
- (void)stopSyncTimer;
- (id)getLastSyncDateForServiceName:(NSString *)serviceName;
- (void)updateLastSyncDateForServiceName:(NSString *)serviceName;
- (void)flushLastSyncDate;
- (void)dismissUIKeyBoard:(NSArray *)subviews;
- (void)removeAlertViews:(NSArray *)subviews;
- (void)AddCapabilityToDisplayRenamedLabelsInMobileApps:(NSArray *)customTermsArr;
- (void)resetLocalisedFilesAtStart:(BOOL)isStart;
- (void)startDeepLinkingTimer;
- (void)stopDeepLinkingTimer;
- (void)approvalsDeepLinking;
- (void)dismissModalViews;
- (void)launchResetPasswordViewController;
- (void)stopTrackTimeClockAnimation;
- (void)startTrackTimeClockAnimation;
- (void)renderRatingApplicationView;
- (void)getDeepLinkingWorkingForValue:(NSString *)deepLinkValue;
- (void)compareDataUpdateForLighWeightHomeFlowServiceWithNewDate:(NSMutableDictionary *)newDataDict;
- (void)sendRequestForGettingUpdatedBadgeValue;
- (void)updateBadgeCountForEachModule;
- (void) launchWelcomeViewController;
-(void)updateBadgeValue:(NSNotification*)notification;
-(void)launchErrorDetailsViewController;
-(void)didCompanyLoginSuccess;
- (void)commonButtonAction:(UIButton*)sender;
- (void)resetValuesForWrongPassword;
@end
