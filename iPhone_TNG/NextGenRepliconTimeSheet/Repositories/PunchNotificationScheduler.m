#import "PunchNotificationScheduler.h"
#import "DateProvider.h"


@interface PunchNotificationScheduler ()

@property (nonatomic) UIApplication *application;
@property (nonatomic) DateProvider *dateProvider;

@end


@implementation PunchNotificationScheduler

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider application:(UIApplication *)application
{
    self = [super init];
    if (self)
    {
        self.dateProvider = dateProvider;
        self.application = application;
    }
    return self;
}

- (void)scheduleNotificationWithAlertBody:(NSString *)alertBody
{
    NSDate *now = [self.dateProvider date];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeInterval:4*60*60 sinceDate:now];
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.alertBody = alertBody;

    [self.application scheduleLocalNotification:notification];
}

- (void)scheduleCurrentFireDateNotificationWithAlertBody:(NSString *)alertBody
{
    NSDate *now = [self.dateProvider date];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = now;
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.alertBody = alertBody;

    [self.application scheduleLocalNotification:notification];
}

- (void)cancelNotification
{
    [self.application cancelAllLocalNotifications];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
