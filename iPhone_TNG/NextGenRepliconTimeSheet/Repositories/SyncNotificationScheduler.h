#import <Foundation/Foundation.h>


@class DateProvider;


@interface SyncNotificationScheduler : NSObject

@property (nonatomic, readonly) UIApplication *application;
@property (nonatomic, readonly) DateProvider *dateProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider application:(UIApplication *)application;

- (void)scheduleNotificationWithAlertBody:(NSString *)alertBody uid:(NSString *)uid;
- (void)cancelNotification:(NSString *)notificationName;

@end
