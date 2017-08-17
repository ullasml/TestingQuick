#import "SyncNotificationScheduler.h"
#import "DateProvider.h"


@interface SyncNotificationScheduler ()

@property (nonatomic) UIApplication *application;
@property (nonatomic) DateProvider *dateProvider;

@end


@implementation SyncNotificationScheduler

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

- (void)scheduleNotificationWithAlertBody:(NSString *)alertBody uid:(NSString *)uid
{
    NSDate *now = [self.dateProvider date];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if ([uid isEqualToString:@"SyncQueueStatus"])
    {
        notification.fireDate = [NSDate dateWithTimeInterval:4*60*60 sinceDate:now];
    }
    else if ([uid isEqualToString:@"ErrorBackgroundStatus"])
    {
        notification.fireDate = now;
    }

    notification.timeZone = [NSTimeZone localTimeZone];
    notification.alertBody = alertBody;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid",nil];
    notification.userInfo = userInfo;
    [self.application scheduleLocalNotification:notification];
}

- (void)cancelNotification:(NSString *)notificationName
{
    NSArray *eventArray = [self.application scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        if (oneEvent.userInfo)
        {
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
            if ([uid isEqualToString:notificationName])
            {
                //Cancelling local notification
                [self.application cancelLocalNotification:oneEvent];
                break;
            }
        }

    }
}
#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
