#import <Foundation/Foundation.h>
#import "BaseNavigationController.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBannerPresenter.h"
#import "ServerMostRecentPunchProtocol.h"

@class OfflineBanner;
@protocol Theme;
@class TimerProvider;
@class UserPermissionsStorage;


@interface TimesheetNavigationController : BaseNavigationController<ReachabilityMonitorObserver, OfflineBannerPresenter>

@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) OfflineBanner *offlineBanner;
@property (nonatomic, readonly) id <Theme> theme;
@property (nonatomic, readonly) TimerProvider *timerProvider;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                    userPermissionsStorage:(UserPermissionsStorage*)userPermissionsStorage
                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                             timerProvider:(TimerProvider *)timerProvider
                                     theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)showOfflineInstructions;


@end
