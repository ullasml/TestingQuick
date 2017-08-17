#import <Cedar/Cedar.h>
#import "SyncNotificationScheduler.h"
#import "DateProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SyncNotificationSchedulerSpec)

describe(@"SyncNotificationScheduler", ^{
    __block SyncNotificationScheduler *subject;
    __block UIApplication<CedarDouble> *application;
    __block DateProvider *dateProvider;

    beforeEach(^{
        application = nice_fake_for([UIApplication class]);
        dateProvider = fake_for([DateProvider class]);

        subject = [[SyncNotificationScheduler alloc] initWithDateProvider:dateProvider
                                                               application:application];
    });

    describe(@"scheduling a notification", ^{

        __block NSDate *date;
        beforeEach(^{
            date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(date);
        });

        context(@"SyncQueueStatus notification", ^{
            beforeEach(^{
                [subject scheduleNotificationWithAlertBody:@"My Special Alert Body" uid:@"SyncQueueStatus"];
            });
            it(@"should schedule a local notification", ^{
                [[application sent_messages] count] should equal(1);

                application should have_received(@selector(scheduleLocalNotification:));

                __autoreleasing UILocalNotification *notification;
                NSInvocation *inv = [[application sent_messages] firstObject];
                [inv getArgument:&notification atIndex:2];

                notification.fireDate should equal([NSDate dateWithTimeIntervalSinceReferenceDate:(4 * 60 * 60)]);
                notification.timeZone should equal([NSTimeZone localTimeZone]);
                notification.repeatInterval should equal(0);
                notification.alertBody should equal(@"My Special Alert Body");
                notification.userInfo should equal(@{@"uid" : @"SyncQueueStatus"});
            });
        });

        context(@"ErrorBackgroundStatus notification", ^{
            beforeEach(^{
                [subject scheduleNotificationWithAlertBody:@"My Special Alert Body" uid:@"ErrorBackgroundStatus"];
            });
            it(@"should schedule a local notification", ^{
                [[application sent_messages] count] should equal(1);

                application should have_received(@selector(scheduleLocalNotification:));

                __autoreleasing UILocalNotification *notification;
                NSInvocation *inv = [[application sent_messages] firstObject];
                [inv getArgument:&notification atIndex:2];

                notification.fireDate should equal(date);
                notification.timeZone should equal([NSTimeZone localTimeZone]);
                notification.repeatInterval should equal(0);
                notification.alertBody should equal(@"My Special Alert Body");
                notification.userInfo should equal(@{@"uid" : @"ErrorBackgroundStatus"});
            });
        });


    });

    describe(@"canceling a scheduled notification", ^{

        context(@"if notification exist", ^{
            __block UILocalNotification *notification;
            beforeEach(^{
                notification = [[UILocalNotification alloc] init];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"SyncQueueStatus",@"uid",nil];
                notification.userInfo = userInfo;
               application stub_method(@selector(scheduledLocalNotifications)).and_return(@[notification]);
                [subject cancelNotification:@"SyncQueueStatus"];
            });
            it(@"should clear all scheduled local notifications", ^{

                application should have_received(@selector(cancelLocalNotification:)).with(notification);
            });
        });

        context(@"if notification doesn't exist", ^{
            beforeEach(^{

                [subject cancelNotification:@"SyncQueueStatus"];
            });
            it(@"should clear all scheduled local notifications", ^{

                application should_not have_received(@selector(cancelLocalNotification:));
            });
        });

    });
});

SPEC_END
