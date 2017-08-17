//
//  ErrorBannerViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/5/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Theme;
@class ErrorDetailsDeserializer;
@class ErrorDetailsStorage;
@class SyncNotificationScheduler;

@protocol ErrorBannerMonitorObserver <NSObject>

- (void)errorBannerViewChanged;

@end


@interface ErrorBannerViewController : UIViewController

@property (nonatomic, weak, readonly) UILabel *errorLabel;
@property (nonatomic, weak, readonly) UILabel *dateLabel;
@property (nonatomic, readonly)  id<Theme> theme;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic, readonly) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic, readonly) NSDateFormatter *dbDateLocalTimeZoneDateFormatter;
@property (nonatomic,assign , readonly) UINavigationController  *parentController;
@property (nonatomic, readonly) SyncNotificationScheduler  *syncNotificationScheduler;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id <Theme>)theme notificationCenter:(NSNotificationCenter *)notificationCenter errorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer errorDetailsStorage:(ErrorDetailsStorage *)errorDetailsStorage dateFormatter:(NSDateFormatter *)dateFormatter syncNotificationScheduler:(SyncNotificationScheduler *)syncNotificationScheduler;
- (void)presentErrorDetailsControllerOnParentController:(UINavigationController *)parentController withTabBarcontroller:(UITabBarController *)tabBarController;

-(void)errorDataReceivedAction:(NSNotification *)notification;
-(void)successDataReceivedAction:(NSNotification *)notification;
-(void)updateErrorBannerData;
-(void)setLocalDateFormatter:(NSDateFormatter *)dateFormatter;

-(void)hideErrorBanner;
-(void)showErrorBanner;

-(void)presentErrorDetailsViewController;
-(void)addObserver:(id<ErrorBannerMonitorObserver>)observer;
-(void)removeObserver;
-(void)notifyObservers;
@end
