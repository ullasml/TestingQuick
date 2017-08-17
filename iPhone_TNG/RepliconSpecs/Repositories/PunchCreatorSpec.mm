#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "PunchCreator.h"
#import "PunchRequestProvider.h"
#import "LocalPunch.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"
#import "PunchOutboxStorage.h"
#import "PunchNotificationScheduler.h"
#import "FailedPunchStorage.h"
#import "TimeLinePunchesStorage.h"
#import "FailedPunchErrorStorage.h"
#import "PunchErrorPresenter.h"
#import "DateProvider.h"
#import "InvalidProjectAndTakDetector.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchCreatorSpec)

describe(@"PunchCreator", ^{
    __block PunchCreator *subject;
    __block PunchRequestProvider *punchRequestProvider;
    __block PunchOutboxStorage *punchOutboxStorage;
    __block FailedPunchStorage *failedPunchStorage;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block id<RequestPromiseClient> client;
    __block PunchNotificationScheduler *punchNotificationScheduler;
    __block FailedPunchErrorStorage *failedPunchErrorStorage;
    __block UIApplication<CedarDouble> *application;
    __block PunchErrorPresenter *punchErrorPresenter;
    __block NSUserDefaults *userDefaults;
    __block DateProvider *dateProvider;
    __block NSDateFormatter *dateFormatter;
    __block InvalidProjectAndTakDetector *invalidProjectAndTakDetector;

    beforeEach(^{
        punchRequestProvider = nice_fake_for([PunchRequestProvider class]);
        application = nice_fake_for([UIApplication class]);
        punchOutboxStorage = nice_fake_for([PunchOutboxStorage class]);
        failedPunchStorage = nice_fake_for([FailedPunchStorage class]);
        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);
        failedPunchErrorStorage = nice_fake_for([FailedPunchErrorStorage class]);
        punchErrorPresenter = nice_fake_for([PunchErrorPresenter class]);
        client = nice_fake_for(@protocol(RequestPromiseClient));
        invalidProjectAndTakDetector = nice_fake_for([InvalidProjectAndTakDetector class]);

        punchNotificationScheduler = fake_for([PunchNotificationScheduler class]);
        punchNotificationScheduler stub_method(@selector(scheduleNotificationWithAlertBody:));
        punchNotificationScheduler stub_method(@selector(scheduleCurrentFireDateNotificationWithAlertBody:));

         NSDate *date = [NSDate dateWithTimeIntervalSince1970:1467801470];
        dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);

        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];
        dateFormatter.dateFormat = @"EE, dd MMM yyyy HH:mm:ss ZZZ";

        userDefaults = nice_fake_for([NSUserDefaults class]);

        subject = [[PunchCreator alloc] initWithInvalidProjectAndTakDetector:invalidProjectAndTakDetector
                                                  punchNotificationScheduler:punchNotificationScheduler
                                                     failedPunchErrorStorage:failedPunchErrorStorage
                                                      timeLinePunchesStorage:timeLinePunchesStorage
                                                        punchRequestProvider:punchRequestProvider
                                                         punchErrorPresenter:punchErrorPresenter
                                                          punchOutboxStorage:punchOutboxStorage
                                                          failedPunchStorage:failedPunchStorage
                                                                 application:application
                                                                      client:client
                                                                    defaults:userDefaults
                                                                dateProvider:dateProvider
                                                               dateFormatter:dateFormatter];
    });

    describe(@"creationPromiseForPunch:", ^{
        __block KSPromise *promise;
        __block KSDeferred *deferred;
        __block id<Punch> punchA;
        __block id<Punch> punchB;

        beforeEach(^{
            punchA = fake_for(@protocol(Punch));
            punchB = fake_for(@protocol(Punch));

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com"]];
            [request setValue:@"Request1|Request2" forHTTPHeaderField:PunchRequestIdentifierHeader];

            punchA stub_method(@selector(requestID)).and_return(@"Request1");
            punchB stub_method(@selector(requestID)).and_return(@"Request2");

            punchRequestProvider stub_method(@selector(punchRequestWithPunch:))
                .with(@[punchA,punchB])
                .and_return(request);

            deferred = [[KSDeferred alloc] init];
            client stub_method(@selector(promiseWithRequest:))
                .with(request)
                .and_return(deferred.promise);

            
            promise = [subject creationPromiseForPunch:@[punchA,punchB]];
        });
        
        it(@"should update the sync status to Pending for punch", ^{
            punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchA);
            punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchB);
        });


        context(@"when the request succeeds", ^{

            context(@"when the json", ^{

                beforeEach(^{
                    NSDictionary *jsonDict =  @{
                                               @"d" :@{
                                                       @"errors" :@[],
                                                       @"punchReferences" :@[
                                                              @{
                                                                 @"displayText" : @"bb11b523-4aac-4cca-b002-d2be0e0ac7ce",
                                                                 @"parameterCorrelationId" : @"Request1",
                                                                 @"slug" : @"bb11b523-4aac-4cca-b002-d2be0e0ac7ce",
                                                                 @"uri" : @"urn:replicon-tenant:repliconiphone-2:time-punch:bb11b523-4aac-4cca-b002-d2be0e0ac7ce"
                                                               }
                                                        ]
                                                       }
                                               };
                    [deferred resolveWithValue:jsonDict];
                });

                it(@"should resolve the promise", ^{
                    promise.value should equal(@[punchA,punchB]);
                });

                it(@"should update the sync status to Remote for punch", ^{
                    timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchA,@"urn:replicon-tenant:repliconiphone-2:time-punch:bb11b523-4aac-4cca-b002-d2be0e0ac7ce");
                    timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                });

                it(@"should update user defaults with PunchRecordedLastModifiedTime", ^{
                    userDefaults should have_received(@selector(removeObjectForKey:)).with(@"PunchRecordedLastModifiedTime");
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"Wed, 06 Jul 2016 16:07:50 +0530",@"PunchRecordedLastModifiedTime");
                });

            });

            context(@"when the response dictionary is empty", ^{
                beforeEach(^{
                    [deferred resolveWithValue:@{}];
                });

                it(@"should resolve the promise", ^{
                    promise.value should equal(@[punchA,punchB]);
                });

                it(@"should update the sync status to Remote for punch", ^{
                    timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchA,nil);
                    timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                });

                it(@"should update user defaults with PunchRecordedLastModifiedTime", ^{
                    userDefaults should have_received(@selector(removeObjectForKey:)).with(@"PunchRecordedLastModifiedTime");
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"Wed, 06 Jul 2016 16:07:50 +0530",@"PunchRecordedLastModifiedTime");
                });
            });


        });

        
        context(@"when application is in background", ^{
            context(@"when the client's request suceeds with an error dictionary and one punches was successfull", ^{
                __block NSDictionary *errorDictionary;
                beforeEach(^{
                    application stub_method(@selector(applicationState)).and_return(UIApplicationStateBackground);
                    errorDictionary = @{@"displayText": @"My Special Display Text"};
                    NSDictionary *jsonResponseDictionary = @{@"d": @{@"errors": @[errorDictionary],@"erroredPunches": @[@{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"}]}};
                    [deferred resolveWithValue:jsonResponseDictionary];
                });
                
                it(@"should reject the promise", ^{
                    promise.error.localizedDescription should equal(@[errorDictionary]);
                });
                
                it(@"should delete the punchA", ^{
                    punchOutboxStorage should have_received(@selector(deletePunch:)).with(punchA);
                });
                
                it(@"should update the punchremoteB status to ", ^{
                    timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                });
                
                it(@"should schedule a local notification", ^{
                    NSString *expectedAlertBody = @"My Special Display Text";
                    punchNotificationScheduler should have_received(@selector(scheduleCurrentFireDateNotificationWithAlertBody:)).with(expectedAlertBody);
                });
                
                it(@"should store punch failure reason", ^{
                    failedPunchErrorStorage should have_received(@selector(storeFailedPunchError:punch:)).with(@{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"}, punchA);
                });
                
                it(@"should check for invalid project and task", ^{
                    invalidProjectAndTakDetector should have_received(@selector(validatePunchAndUpdate:withError:)).with(punchA , @{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"});
                });
                
                it(@"should show failed punch error", ^{
                    punchErrorPresenter should_not have_received(@selector(presentFailedPunchesErrors));
                });

                it(@"should update user defaults with PunchRecordedLastModifiedTime", ^{
                    userDefaults should have_received(@selector(removeObjectForKey:)).with(@"PunchRecordedLastModifiedTime");
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"Wed, 06 Jul 2016 16:07:50 +0530",@"PunchRecordedLastModifiedTime");
                });
            });
        });
        
        context(@"when application is in foreground", ^{
            context(@"when the client's request suceeds with an error dictionary and one punches was successfull", ^{
                __block NSDictionary *errorDictionary;
                beforeEach(^{
                    application stub_method(@selector(applicationState)).and_return(UIApplicationStateActive);
                    errorDictionary = @{@"displayText": @"My Special Display Text"};
                    NSDictionary *jsonResponseDictionary = @{@"d": @{@"errors": @[errorDictionary],@"erroredPunches": @[@{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"}]}};
                    [deferred resolveWithValue:jsonResponseDictionary];
                });
                
                it(@"should reject the promise", ^{
                    promise.error.localizedDescription should equal(@[errorDictionary]);
                });
                
                it(@"should delete the punchA", ^{
                    punchOutboxStorage should have_received(@selector(deletePunch:)).with(punchA);
                });
                
                it(@"should update the punchremoteB status to ", ^{
                    timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                });
                
                it(@"should schedule a local notification", ^{
                    NSString *expectedAlertBody = @"My Special Display Text";
                    punchNotificationScheduler should have_received(@selector(scheduleCurrentFireDateNotificationWithAlertBody:)).with(expectedAlertBody);
                });
                
                it(@"should store punch failure reason", ^{
                    failedPunchErrorStorage should have_received(@selector(storeFailedPunchError:punch:)).with(@{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"}, punchA);
                });
                
                it(@"should show failed punch error", ^{
                    punchErrorPresenter should have_received(@selector(presentFailedPunchesErrors));
                });

                it(@"should update user defaults with PunchRecordedLastModifiedTime", ^{
                    userDefaults should have_received(@selector(removeObjectForKey:)).with(@"PunchRecordedLastModifiedTime");
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"Wed, 06 Jul 2016 16:07:50 +0530",@"PunchRecordedLastModifiedTime");
                });
            });
            

        });

        context(@"when the client's request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });

            it(@"should reject the promise", ^{
                promise.error should be_same_instance_as(error);
            });
            
            it(@"should update the sync status to UnsubmittedSyncStatus for punch", ^{
                failedPunchStorage should have_received(@selector(updateSyncStatusToUnsubmittedAndSaveWithPunch:)).with(punchA);
                failedPunchStorage should have_received(@selector(updateSyncStatusToUnsubmittedAndSaveWithPunch:)).with(punchB);
            });

            it(@"should schedule a local notification", ^{
                NSString *expectedAlertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
                punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
            });
            
            it(@"should not store punch failure reason", ^{
                failedPunchErrorStorage should_not have_received(@selector(storeFailedPunchError:punch:));
            });

            it(@"should not update user defaults with PunchRecordedLastModifiedTime", ^{
                userDefaults should_not have_received(@selector(removeObjectForKey:));
                userDefaults should_not have_received(@selector(setObject:forKey:));
            });
        });
    });
});

SPEC_END
