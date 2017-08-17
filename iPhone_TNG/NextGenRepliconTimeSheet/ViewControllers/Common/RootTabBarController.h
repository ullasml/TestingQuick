#import <UIKit/UIKit.h>


@class ListOfExpenseSheetsViewControllerProvider;
@class ListOfTimeSheetsViewControllerProvider;
@class PunchHomeControllerProvider;
@class NavigationBarStylist;
@class ReachabilityMonitor;
@class DoorKeeper;

@protocol LaunchLoginDelegate;
@protocol Theme;
@protocol BSInjector;


@interface RootTabBarController : UITabBarController

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithInjector:(id<BSInjector>)injector
                             modulesArray:(NSArray *)modulesArray
listOfExpenseSheetsViewControllerProvider:(ListOfExpenseSheetsViewControllerProvider *)listOfExpenseSheetsViewControllerProvider
   listOfTimeSheetsViewControllerProvider:(ListOfTimeSheetsViewControllerProvider *)listOfTimeSheetsViewControllerProvider
              punchHomeControllerProvider:(PunchHomeControllerProvider *)punchHomeControllerProvider
                     navigationBarStylist:(NavigationBarStylist *)navigationBarStylist
                      launchLoginDelegate:(id<LaunchLoginDelegate>)launchLoginDelegate
                      reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                               doorKeeper:(DoorKeeper *)doorKeeper
                                    theme:(id<Theme>)theme;
-(void)updateBadgeCountForEachModule;

@end
