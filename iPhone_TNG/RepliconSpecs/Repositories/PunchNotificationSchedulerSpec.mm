#import <Cedar/Cedar.h>
#import "PunchNotificationScheduler.h"
#import "DateProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchNotificationSchedulerSpec)

describe(@"PunchNotificationScheduler", ^{
    __block PunchNotificationScheduler *subject;
    __block UIApplication<CedarDouble> *application;
    __block DateProvider *dateProvider;

    beforeEach(^{
        application = nice_fake_for([UIApplication class]);
        dateProvider = fake_for([DateProvider class]);

        subject = [[PunchNotificationScheduler alloc] initWithDateProvider:dateProvider
                                                               application:application];
    });

    describe(@"scheduling a notification", ^{
        beforeEach(^{
            NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(date);

            [subject scheduleNotificationWithAlertBody:@"My Special Alert Body"];
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
        });
    });

    describe(@"canceling a scheduled notification", ^{
        it(@"should clear all scheduled local notifications", ^{
            [subject cancelNotification];

            application should have_received(@selector(cancelAllLocalNotifications));
        });
    });

    describe(@"scheduling a current fire date notification", ^{
        __block NSDate *date;
        beforeEach(^{
            date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(date);

            [subject scheduleCurrentFireDateNotificationWithAlertBody:@"My Special Alert Body"];
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
        });
    });
});

SPEC_END
