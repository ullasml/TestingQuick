#import <UIKit/UIKit.h>
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBannerPresenter.h"
#import "ServerMostRecentPunchProtocol.h"
#import "BaseNavigationController.h"

@class OfflineBanner;
@protocol Theme;
@class TimerProvider;

@interface PunchHomeNavigationController : BaseNavigationController <ReachabilityMonitorObserver, OfflineBannerPresenter,ServerMostRecentPunchProtocol>

@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) OfflineBanner *offlineBanner;
@property (nonatomic, readonly) id <Theme> theme;
@property (nonatomic, readonly) TimerProvider *timerProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                             timerProvider:(TimerProvider *)timerProvider
                                     theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)showOfflineInstructions;

@end
