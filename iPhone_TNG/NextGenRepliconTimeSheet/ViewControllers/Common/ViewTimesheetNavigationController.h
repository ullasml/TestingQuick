//
//  ViewTimesheetNavigationController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 17/07/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavigationController.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "OfflineBannerPresenter.h"

@class OfflineBanner;
@protocol Theme;
@class TimerProvider;
@class UserPermissionsStorage;

@interface ViewTimesheetNavigationController : BaseNavigationController<ReachabilityMonitorObserver, OfflineBannerPresenter>
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
