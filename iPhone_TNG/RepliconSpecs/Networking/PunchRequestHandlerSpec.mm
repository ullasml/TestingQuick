#import <Cedar/Cedar.h>
#import "PunchRequestHandler.h"
#import "PunchCreator.h"
#import "Constants.h"
#import "PunchOutboxStorage.h"
#import "Punch.h"
#import "URLSessionListener.h"
#import "FailedPunchStorage.h"
#import "PunchNotificationScheduler.h"
#import "RepliconSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MyNSURLSessionDownloadTask : NSURLSessionDownloadTask
@property (nullable, copy) NSURLRequest  *originalRequest;  /* Temporarily overidden */
@end

@implementation MyNSURLSessionDownloadTask
@synthesize originalRequest;
@end


SPEC_BEGIN(PunchRequestHandlerSpec)

describe(@"PunchRequestHandler", ^{
    __block PunchRequestHandler *subject;
    __block PunchOutboxStorage *punchOutboxStorage;
    __block FailedPunchStorage *failedPunchesStorage;
    __block URLSessionListener *urlSessionListener;
    __block PunchNotificationScheduler *punchNotificationScheduler;

    beforeEach(^{

        punchOutboxStorage = fake_for([PunchOutboxStorage class]);

        failedPunchesStorage = nice_fake_for([FailedPunchStorage class]);

        urlSessionListener = [[URLSessionListener alloc]  init];
        spy_on(urlSessionListener);

        punchNotificationScheduler = fake_for([PunchNotificationScheduler class]);
        punchNotificationScheduler stub_method(@selector(scheduleNotificationWithAlertBody:));

        subject = [[PunchRequestHandler alloc] initWithPunchNotificationScheduler:punchNotificationScheduler
                                                               failedPunchStorage:failedPunchesStorage
                                                               punchOutboxStorage:punchOutboxStorage
                                                               urlSessionListener:urlSessionListener];
    });

    it(@"should add itself as an observer on the url session listener", ^{
        urlSessionListener should have_received(@selector(addObserver:)).with(subject);
    });

    describe(@"handling task completion", ^{
        __block  MyNSURLSessionDownloadTask *task;
        __block id<Punch> punch;

        beforeEach(^{
            NSMutableURLRequest *request = nice_fake_for([NSMutableURLRequest class]);
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"http://example.com"]);
            request stub_method(@selector(valueForHTTPHeaderField:)).with(PunchRequestIdentifierHeader).and_return(@"My Special Request ID");
            task = nice_fake_for([MyNSURLSessionDownloadTask class]);
            task stub_method(@selector(originalRequest)).and_return(request);

            punch = fake_for(@protocol(Punch));

            punchOutboxStorage stub_method(@selector(getAndDeletePunchForRequestId:))
            .with(@"My Special Request ID")
            .and_return(punch);
        });

        context(@"when the task fails", ^{
            beforeEach(^{
                NSError *error = fake_for([NSError class]);
                [subject urlSessionListener:urlSessionListener task:task didCompleteWithError:error];
            });

            it(@"should remove the punch from the outbox", ^{
                punchOutboxStorage should have_received(@selector(getAndDeletePunchForRequestId:)).with(@"My Special Request ID");
            });

            it(@"should add the punch to the failed punches storage", ^{
                failedPunchesStorage should have_received(@selector(storePunch:)).with(punch);
            });

            it(@"should schedule a local notification", ^{
                NSString *expectedAlertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
                punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
            });
        });

        context(@"when the task succeeds", ^{

            context(@"without errors in the body", ^{
                beforeEach(^{
                    NSData *data = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
                    [subject urlSessionListener:nil downloadTask:task didFinishDownloadingData:data];
                    [subject urlSessionListener:nil task:task didCompleteWithError:nil];
                });

                it(@"should remove the punch from the outbox", ^{
                    punchOutboxStorage should have_received(@selector(getAndDeletePunchForRequestId:)).with(@"My Special Request ID");
                });

                it(@"should not schedule a local notification", ^{
                    punchNotificationScheduler should_not have_received(@selector(scheduleNotificationWithAlertBody:));
                });
            });

            context(@"and there is an error in the body", ^{
                beforeEach(^{
                    NSDictionary *errorJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"generic_error"];
                    NSData *errorResponseData = [NSJSONSerialization dataWithJSONObject:errorJSONDictionary options:0 error:nil];
                    [subject urlSessionListener:nil downloadTask:task didFinishDownloadingData:errorResponseData];
                    [subject urlSessionListener:nil task:task didCompleteWithError:nil];
                });

                it(@"should schedule a failed punch notification", ^{
                    NSString *expectedAlertBody = @"Punches were not saved to Replicon server due to following reason: The server was unable to process the request due to an internal error. Tap to retry. If that does not resolve the issue, please contact your Admin.";

                    punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
                });

                it(@"should remove the punch from the outbox", ^{
                    punchOutboxStorage should have_received(@selector(getAndDeletePunchForRequestId:)).with(@"My Special Request ID");
                });

                it(@"should add the punch to the failed punches storage", ^{
                    failedPunchesStorage should have_received(@selector(storePunch:)).with(punch);
                });
            });

            context(@"and there are bulk punch errors in the body", ^{
                beforeEach(^{
                    NSDictionary *errorJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"batch_punch_request_with_error"];
                    NSData *errorResponseData = [NSJSONSerialization dataWithJSONObject:errorJSONDictionary options:0 error:nil];
                    [subject urlSessionListener:nil downloadTask:task didFinishDownloadingData:errorResponseData];
                    [subject urlSessionListener:nil task:task didCompleteWithError:nil];
                });

                it(@"should schedule a failed punch notification", ^{
                    NSString *expectedAlertBody = @"Punches were not saved to Replicon server due to following reason: The specified time punch already exists. Tap to retry. If that does not resolve the issue, please contact your Admin.";

                    punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
                });

                it(@"should remove the punch from the outbox", ^{
                    punchOutboxStorage should have_received(@selector(getAndDeletePunchForRequestId:)).with(@"My Special Request ID");
                });

                it(@"should add the punch to the failed punches storage", ^{
                    failedPunchesStorage should have_received(@selector(storePunch:)).with(punch);
                });
            });

            context(@"and there are bulk punch errors in the body", ^{
                beforeEach(^{
                    NSDictionary *errorJSONDictionary = [RepliconSpecHelper jsonWithFixture:@"batch_punch_request_with_no_error_notifications"];
                    NSData *errorResponseData = [NSJSONSerialization dataWithJSONObject:errorJSONDictionary options:0 error:nil];
                    [subject urlSessionListener:nil downloadTask:task didFinishDownloadingData:errorResponseData];
                    [subject urlSessionListener:nil task:task didCompleteWithError:nil];
                });

                it(@"should schedule a failed punch notification", ^{
                    NSString *expectedAlertBody = @"Punches were not saved to Replicon server due to unknown reason. Tap to retry. If that does not resolve the issue, please contact your Admin.";

                    punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
                });

                it(@"should remove the punch from the outbox", ^{
                    punchOutboxStorage should have_received(@selector(getAndDeletePunchForRequestId:)).with(@"My Special Request ID");
                });
                
                it(@"should add the punch to the failed punches storage", ^{
                    failedPunchesStorage should have_received(@selector(storePunch:)).with(punch);
                });
            });
            
            
        });
    });
});

SPEC_END
