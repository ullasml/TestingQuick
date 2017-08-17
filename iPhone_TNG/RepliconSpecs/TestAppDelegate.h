#import <UIKit/UIKit.h>


@class PunchRules;
@class CLLocationManager;
@protocol BSInjector;

@interface TestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (nonatomic) NSMutableDictionary *peristedLocalizableStringsDict;
@property (nonatomic) id<BSInjector> injector;

// Needed to maintain compatibility with application's AppDelegate
@property (nonatomic) BOOL isShowTimeSheetPlaceHolder;
@property (nonatomic) BOOL showCompanyView;
@property (nonatomic) BOOL isShowTimeOffSheetPlaceHolder;
@property (nonatomic) BOOL isShowExpenseSheetPlaceHolder;
@property (nonatomic) BOOL isCountPendingSheetsRequestInQueue;
@property (nonatomic) BOOL isNotFirstTimeLaunch;
@property (nonatomic) BOOL beaconsCtrl;
@property (nonatomic, copy) NSString  *selectedModuleName;
@property (nonatomic) CLLocationManager *locationManagerTemp;
@property (nonatomic) UITabBarController *rootTabBarController;
@property (nonatomic) BOOL isWaitingForDeepLinkToErrorDetails;
-(void)showTransparentLoadingOverlay;
-(void)hideTransparentLoadingOverlay;
- (void)launchTabBarController;
-(void)updateBadgeValue:(NSNotification*)notification;
@end
