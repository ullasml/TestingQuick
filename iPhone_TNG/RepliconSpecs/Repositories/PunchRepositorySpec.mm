#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "Util.h"
#import "GUIDProvider.h"
#import "PunchOutboxStorage.h"
#import "LocalPunch.h"
#import "RemotePunchDeserializer.h"
#import "RepliconSpecHelper.h"
#import "Constants.h"
#import "BreakType.h"
#import "PunchRequestProvider.h"
#import "RequestPromiseClient.h"
#import "RemotePunchListDeserializer.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "PSHKFakeOperationQueue.h"
#import "PunchOutboxQueueCoordinator.h"
#import "RemotePunch.h"
#import "TimeLinePunchesStorage.h"
#import "PunchCardStorage.h"
#import "PunchCardObject.h"
#import "OEFType.h"
#import "PunchOutboxStorage.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "FailedPunchStorage.h"
#import "PunchNotificationScheduler.h"
#import "DateProvider.h"
#import "TimeLinePunchesSummary.h"
#import "OfflineLocalPunch.h"
#import "ViolationsStorage.h"
#import "AuditHistoryStorage.h"
#import "DayTimeSummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchRepositorySpec)

describe(@"PunchRepository", ^{
    __block PunchRepository *subject;
    __block id<RequestPromiseClient> client;
    __block RemotePunchDeserializer *punchDeserializer;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block PunchRequestProvider *punchRequestProvider;
    __block NSURLRequest *mostRecentPunchRequest;
    __block NSURLRequest *mostRecentPunchAlongWithPunchesForDateRequest;
    __block NSURLRequest *punchesForDateRequest;
    __block RemotePunchListDeserializer *punchListDeserializer;
    __block PunchOutboxQueueCoordinator *punchOutboxQueueCoordinator;
    __block PunchCardStorage *punchCardStorage;
    __block GUIDProvider *guidProvider;
    __block PunchOutboxStorage *punchOutboxStorage;
    __block FailedPunchStorage *failedPunchStorage;
    __block PunchNotificationScheduler *punchNotificationScheduler;
    __block DateProvider *dateProvider;
    __block id <UserSession> userSession;
    __block ViolationsStorage *violationsStorage;
    __block AuditHistoryStorage *auditHistoryStorage;
    __block NSUserDefaults *defaults;

    beforeEach(^{
        client = nice_fake_for(@protocol(RequestPromiseClient));

        guidProvider = nice_fake_for([GUIDProvider class]);

        guidProvider stub_method(@selector(guid)).and_return(@"guid-A");

        punchListDeserializer = nice_fake_for([RemotePunchListDeserializer class]);

        punchCardStorage = nice_fake_for([PunchCardStorage class]);
        
        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);

        punchDeserializer = nice_fake_for([RemotePunchDeserializer class]);

        punchRequestProvider = nice_fake_for([PunchRequestProvider class]);

        mostRecentPunchRequest = nice_fake_for([NSURLRequest class]);
        punchRequestProvider stub_method(@selector(mostRecentPunchRequestForUserUri:)).and_return(mostRecentPunchRequest);

        mostRecentPunchAlongWithPunchesForDateRequest = nice_fake_for([NSURLRequest class]);
        punchRequestProvider stub_method(@selector(requestForPunchesWithLastTwoMostRecentPunchWithDate:)).and_return(mostRecentPunchAlongWithPunchesForDateRequest);

        punchesForDateRequest = nice_fake_for([NSURLRequest class]);
        punchRequestProvider stub_method(@selector(requestForPunchesWithDate:userURI:)).and_return(punchesForDateRequest);

        punchOutboxQueueCoordinator = nice_fake_for([PunchOutboxQueueCoordinator class]);
        
        punchOutboxStorage = nice_fake_for([PunchOutboxStorage class]);
        
        failedPunchStorage = nice_fake_for([FailedPunchStorage class]);
        
        punchNotificationScheduler = fake_for([PunchNotificationScheduler class]);
        punchNotificationScheduler stub_method(@selector(scheduleNotificationWithAlertBody:));
        punchNotificationScheduler stub_method(@selector(scheduleCurrentFireDateNotificationWithAlertBody:));

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider = nice_fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);


        NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
        longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
        longDateFormatter.dateFormat = @"MMM d, YYYY";

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");
        

        violationsStorage = nice_fake_for([ViolationsStorage class]);
        auditHistoryStorage = nice_fake_for([AuditHistoryStorage class]);

        defaults = nice_fake_for([NSUserDefaults class]);

        subject = [[PunchRepository alloc] initWithPunchOutboxQueueCoordinator:punchOutboxQueueCoordinator
                                                    punchNotificationScheduler:punchNotificationScheduler
                                                         punchListDeserializer:punchListDeserializer
                                                        timeLinePunchesStorage:timeLinePunchesStorage
                                                          punchRequestProvider:punchRequestProvider
                                                           auditHistoryStorage:auditHistoryStorage
                                                             punchDeserializer:punchDeserializer
                                                            punchOutboxStorage:punchOutboxStorage
                                                            failedPunchStorage:failedPunchStorage
                                                             violationsStorage:violationsStorage
                                                              punchCardStorage:punchCardStorage
                                                                        client:client
                                                                  guidProvider:guidProvider
                                                                   userSession:userSession
                                                                      defaults:defaults
                                                                  dateProvider:dateProvider
                                                                 dateFormatter:longDateFormatter];


    });

    describe(@"-fetchMostRecentPunch", ^{
        __block KSDeferred *deferred;
        __block NSURLRequest *request;
        __block id<PunchRepositoryObserver> observer1;

        beforeEach(^{
            deferred = [[KSDeferred alloc] init];

            observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));

            [subject addObserver:observer1];
        });

        context(@"for user context", ^{
            context(@"when no local punch exists", ^{
                beforeEach(^{
                    client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                        request = receivedRequest;
                        return deferred.promise;
                    });

                    [subject fetchMostRecentPunchForUserUri:@"Some:User-Uri"];
                });

                it(@"should send the punch from the request provider to the client", ^{
                    client should have_received(@selector(promiseWithRequest:)).with(mostRecentPunchAlongWithPunchesForDateRequest);
                });

                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });


                context(@"when the request succeeds and deserialized punch is PunchActionTypePunchIn", ^{

                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                    });

                    beforeEach(^{

                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];
                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });

                });

                context(@"when the request succeeds and deserialized punch is PunchActionTypePunchOut", ^{
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                    });

                    beforeEach(^{

                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];
                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });


                });

                context(@"when the request succeeds and deserialized punch is PunchActionTypeTransfer", ^{
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;

                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                    });

                    beforeEach(^{
                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];

                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });

                });

                context(@"when the request succeeds and deserialized punch is PunchActionTypeStartBreak", ^{
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;

                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                    });

                    beforeEach(^{
                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];

                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });

                });
            });

            context(@"when a local punch exists", ^{
                __block LocalPunch *localRecentPunch;

                beforeEach(^{
                    localRecentPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:[NSDate date]];


                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(localRecentPunch);

                    client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                        request = receivedRequest;
                        return deferred.promise;
                    });

                    [subject fetchMostRecentPunchForUserUri:@"Some:User-Uri"];
                });

                it(@"should send the punch from the request provider to the client", ^{
                    client should have_received(@selector(promiseWithRequest:)).with(mostRecentPunchAlongWithPunchesForDateRequest);
                });

                it(@"should notify the observers with the previously stored punch", ^{
                    observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject, localRecentPunch);
                });

                context(@"when the request succeeds", ^{
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;


                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                    });

                    beforeEach(^{
                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];
                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);
                        
                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });
                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));
                        
                    });
                    
                });
            });
            
            context(@"when the user has no most recent punches (they are using the app for the very first time)", ^{
                beforeEach(^{
                    client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
                    
                    punchListDeserializer stub_method(@selector(deserialize:)).and_return(nil);
                    
                    [subject fetchMostRecentPunchForUserUri:@"Some:User-Uri"];
                    [deferred resolveWithValue:@{}];
                });
                
                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));
                    
                });
                
                
            });
        });

        context(@"for supervisor context", ^{
            context(@"when no local punch exists", ^{
                beforeEach(^{
                    client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                        request = receivedRequest;
                        return deferred.promise;
                    });

                    [subject fetchMostRecentPunchForUserUri:@"Some:Reportee-Uri"];
                });

                it(@"should send the punch from the request provider to the client", ^{
                    client should have_received(@selector(promiseWithRequest:)).with(punchesForDateRequest);
                });

                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });


                context(@"when the request succeeds and deserialized punch is PunchActionTypePunchIn", ^{

                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                    });

                    beforeEach(^{

                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];
                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });

                });

                context(@"when the request succeeds and deserialized punch is PunchActionTypePunchOut", ^{
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                    });

                    beforeEach(^{

                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];
                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });


                });

                context(@"when the request succeeds and deserialized punch is PunchActionTypeTransfer", ^{
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;

                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                    });

                    beforeEach(^{
                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];

                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });

                });

                context(@"when the request succeeds and deserialized punch is PunchActionTypeStartBreak", ^{
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;

                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                    });

                    beforeEach(^{
                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];

                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });

                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));

                    });

                });
            });

            context(@"when a local punch exists", ^{
                __block LocalPunch *localRecentPunch;

                beforeEach(^{
                    localRecentPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:[NSDate date]];


                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:Reportee-Uri").and_return(localRecentPunch);

                    client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                        request = receivedRequest;
                        return deferred.promise;
                    });

                    [subject fetchMostRecentPunchForUserUri:@"Some:Reportee-Uri"];
                });

                it(@"should send the punch from the request provider to the client", ^{
                    client should have_received(@selector(promiseWithRequest:)).with(punchesForDateRequest);
                });

                it(@"should notify the observers with the previously stored punch", ^{
                    observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject, localRecentPunch);
                });

                context(@"when the request succeeds", ^{
                    __block LocalPunch *deserializedPunch1;
                    __block LocalPunch *deserializedPunch2;
                    __block LocalPunch *deserializedPunch3;
                    __block NSDictionary *mostRecentPunchDictionary;
                    __block PunchCardObject *expectedPunchCard;


                    beforeEach(^{
                        mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                    });

                    beforeEach(^{
                        deserializedPunch1 = nice_fake_for(@protocol(Punch));
                        deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        deserializedPunch2 = nice_fake_for(@protocol(Punch));
                        deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                        deserializedPunch3 = nice_fake_for(@protocol(Punch));
                        deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                        ClientType *client = nice_fake_for([ClientType class]);
                        ProjectType *project = nice_fake_for([ProjectType class]);
                        TaskType *task = nice_fake_for([TaskType class]);

                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        OEFType *oefType3 = nice_fake_for([OEFType class]);
                        NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                        deserializedPunch1 stub_method(@selector(client)).and_return(client);
                        deserializedPunch1 stub_method(@selector(project)).and_return(project);
                        deserializedPunch1 stub_method(@selector(task)).and_return(task);


                        deserializedPunch2 stub_method(@selector(client)).and_return(client);
                        deserializedPunch2 stub_method(@selector(project)).and_return(project);
                        deserializedPunch2 stub_method(@selector(task)).and_return(task);
                        deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                        deserializedPunch3 stub_method(@selector(client)).and_return(client);
                        deserializedPunch3 stub_method(@selector(project)).and_return(project);
                        deserializedPunch3 stub_method(@selector(task)).and_return(task);
                        deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                        expectedPunchCard = [[PunchCardObject alloc]
                                             initWithClientType:client
                                             projectType:project
                                             oefTypesArray:oefTypesArray
                                             breakType:NULL
                                             taskType:task
                                             activity:NULL
                                             uri:@"guid-A"];
                        punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);
                        
                        [deferred resolveWithValue:mostRecentPunchDictionary];
                    });
                    it(@"should store the punch card made from punch in to punch card storage", ^{
                        punchCardStorage should_not have_received(@selector(storePunchCard:));
                        
                    });
                    
                });
            });
            
            context(@"when the user has no most recent punches (they are using the app for the very first time)", ^{
                beforeEach(^{
                    client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
                    
                    punchListDeserializer stub_method(@selector(deserialize:)).and_return(nil);
                    
                    [subject fetchMostRecentPunchForUserUri:@"Some:Reportee-Uri"];
                    [deferred resolveWithValue:@{}];
                });
                
                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));
                    
                });
                
                
            });
        });

        


    });

    describe(@"-fetchMostRecentPunchFromServer", ^{
        __block KSDeferred *deferred;
        __block NSURLRequest *request;
        __block id<PunchRepositoryObserver> observer1;
        __block id<PunchRepositoryObserver> observer2;

        beforeEach(^{
            deferred = [[KSDeferred alloc] init];

            observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
            observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));

            [subject addObserver:observer1];
            [subject addObserver:observer2];
        });

        context(@"for user context", ^{
            beforeEach(^{
                client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                    request = receivedRequest;
                    return deferred.promise;
                });

                [subject fetchMostRecentPunchFromServerForUserUri:@"Some:User-Uri"];
            });

            it(@"should send the punch from the request provider to the client", ^{
                client should have_received(@selector(promiseWithRequest:)).with(mostRecentPunchAlongWithPunchesForDateRequest);
            });

            it(@"should not notify the observers with the previously stored punch", ^{
                observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                observer2 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypePunchIn", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });

                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));

                });


            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypePunchOut", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });

                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));

                });



            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypeTransfer", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });

                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));

                });

            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypeStartBreak", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"punchesForDateAndMostRecentLastTwoPunch"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);
                    
                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });
                
                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));
                    
                });
                
                
            });
        });

        context(@"for supervisor context", ^{
            beforeEach(^{
                client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                    request = receivedRequest;
                    return deferred.promise;
                });

                [subject fetchMostRecentPunchFromServerForUserUri:@"Some:Reportee-Uri"];
            });

            it(@"should send the punch from the request provider to the client", ^{
                client should have_received(@selector(promiseWithRequest:)).with(punchesForDateRequest);
            });

            it(@"should not notify the observers with the previously stored punch", ^{
                observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                observer2 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypePunchIn", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });

                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));

                });


            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypePunchOut", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });

                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));

                });



            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypeTransfer", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);

                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });

                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));

                });

            });

            context(@"when the request succeeds with most recent punch with action PunchActionTypeStartBreak", ^{
                __block LocalPunch *deserializedPunch1;
                __block LocalPunch *deserializedPunch2;
                __block LocalPunch *deserializedPunch3;
                __block NSDictionary *mostRecentPunchDictionary;
                __block PunchCardObject *expectedPunchCard;


                beforeEach(^{
                    mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
                });

                beforeEach(^{
                    deserializedPunch1 = nice_fake_for(@protocol(Punch));
                    deserializedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    deserializedPunch2 = nice_fake_for(@protocol(Punch));
                    deserializedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    deserializedPunch3 = nice_fake_for(@protocol(Punch));
                    deserializedPunch3 stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    OEFType *oefType3 = nice_fake_for([OEFType class]);
                    NSArray *oefTypesArray = @[oefType1,oefType2,oefType3];

                    deserializedPunch1 stub_method(@selector(client)).and_return(client);
                    deserializedPunch1 stub_method(@selector(project)).and_return(project);
                    deserializedPunch1 stub_method(@selector(task)).and_return(task);


                    deserializedPunch2 stub_method(@selector(client)).and_return(client);
                    deserializedPunch2 stub_method(@selector(project)).and_return(project);
                    deserializedPunch2 stub_method(@selector(task)).and_return(task);
                    deserializedPunch2 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    deserializedPunch3 stub_method(@selector(client)).and_return(client);
                    deserializedPunch3 stub_method(@selector(project)).and_return(project);
                    deserializedPunch3 stub_method(@selector(task)).and_return(task);
                    deserializedPunch3 stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                    expectedPunchCard = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:oefTypesArray
                                         breakType:NULL
                                         taskType:task
                                         activity:NULL
                                         uri:@"guid-A"];
                    punchListDeserializer stub_method(@selector(deserialize:)).with(mostRecentPunchDictionary).and_return(@[deserializedPunch1,deserializedPunch2,deserializedPunch3]);
                    
                    [deferred resolveWithValue:mostRecentPunchDictionary];
                });
                
                it(@"should store the punch card made from punch in to punch card storage", ^{
                    punchCardStorage should_not have_received(@selector(storePunchCard:));
                    
                });
                
                
            });
        });

    });


    describe(@"-persistPunch:", ^{
        __block LocalPunch *punch;
        __block KSPromise *punchOutboxQueueCoordinatorPromise;
        __block KSPromise *promise;
        __block PunchCardObject *expectedPunchCard;
        __block NSArray *oefTypesArray;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;

        beforeEach(^{

            client = nice_fake_for([ClientType class]);
            project = nice_fake_for([ProjectType class]);
            task = nice_fake_for([TaskType class]);
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            OEFType *oefType3 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2,oefType3];

            punch = fake_for([LocalPunch class]);
            punch stub_method(@selector(client)).and_return(client);
            punch stub_method(@selector(project)).and_return(project);
            punch stub_method(@selector(task)).and_return(task);
            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

            expectedPunchCard = [[PunchCardObject alloc]
                                                  initWithClientType:client
                                                         projectType:project
                                                       oefTypesArray:oefTypesArray
                                                           breakType:NULL
                                                            taskType:task
                                                            activity:NULL
                                                                 uri:@"guid-A"];
            expectedPunchCard.userUri = @"";
            punchOutboxQueueCoordinatorPromise = fake_for([KSPromise class]);
        });
        
        context(@"When persisting punch for User in Supervisor flow when punch has user uri", ^{
            __block PunchCardObject *punchCardObj;
            
            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:nil activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:nil];
                
                punchCardObj = [[PunchCardObject alloc]
                                        initWithClientType:punch.client
                                        projectType:punch.project
                                        oefTypesArray:punch.oefTypesArray
                                        breakType:punch.breakType
                                        taskType:punch.task
                                        activity:punch.activity
                                        uri:@"guid-A"];
                
                punchCardObj.userUri = @"my-special-user-uri";
                
                promise = [subject persistPunch:punch];
                
            });
            
            it(@"Should set the useruri to punchcard object", ^{
                punchCardObj.userUri should equal(@"my-special-user-uri");
            });
            
            it(@"Should call the storePunchcard: method with appropriate punchcard", ^{
                subject.punchCardStorage should have_received(@selector(storePunchCard:)).with(punchCardObj);
            });
        });
        
        context(@"When persisting punch for User in Supervisor flow when punch has no user uri", ^{
            __block PunchCardObject *punchCardObj;
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-current-session-user-uri");
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:nil activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                
                punchCardObj = [[PunchCardObject alloc]
                                initWithClientType:punch.client
                                projectType:punch.project
                                oefTypesArray:punch.oefTypesArray
                                breakType:punch.breakType
                                taskType:punch.task
                                activity:punch.activity
                                uri:@"guid-A"];
                
                punchCardObj.userUri = @"";
                promise = [subject persistPunch:punch];
                
            });
            
            it(@"Should set the empty useruri to punchcard Object", ^{
                punchCardObj.userUri should equal(@"");
            });
            
            it(@"Should call the storePunchcard: method with appropriate punchcard", ^{
                subject.punchCardStorage should have_received(@selector(storePunchCard:)).with(punchCardObj);
            });
            
        });

        context(@"When persisting punch with action type PunchActionTypePunchIn when punch has no user uri", ^{
            beforeEach(^{
                
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:nil image:nil task:task date:nil];
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                    .with(punch)
                    .and_return(punchOutboxQueueCoordinatorPromise);
                
                promise = [subject persistPunch:punch];

            });

            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should have_received(@selector(storePunchCard:)).with(expectedPunchCard);

            });


            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });

            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });

            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypePunchIn when punch has user uri", ^{
            beforeEach(^{
                
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-user-uri" image:nil task:task date:nil];
                
                expectedPunchCard.userUri = punch.userURI;
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                
                promise = [subject persistPunch:punch];
                
            });
            
            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should have_received(@selector(storePunchCard:)).with(expectedPunchCard);
                
            });
            
            
            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });
            
            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });
            
            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypePunchOut when punch has no user uri", ^{

            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:nil image:nil task:task date:nil];
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                
                promise = [subject persistPunch:punch];

            });

            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should_not have_received(@selector(storePunchCard:));

            });


            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });

            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });

            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypePunchOut when punch has user uri", ^{
            
            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-user-uri" image:nil task:task date:nil];
                
                expectedPunchCard.userUri = punch.userURI;
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                
                promise = [subject persistPunch:punch];
                
            });
            
            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should_not have_received(@selector(storePunchCard:));
                
            });
            
            
            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });
            
            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });
            
            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypeTransfer when punch has no user uri", ^{

            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:nil image:nil task:task date:nil];
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                promise = [subject persistPunch:punch];

            });

            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should have_received(@selector(storePunchCard:)).with(expectedPunchCard);

            });


            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });

            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });

            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypeTransfer when punch has user uri", ^{
            
            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-user-uri" image:nil task:task date:nil];
                
                expectedPunchCard.userUri = punch.userURI;
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                promise = [subject persistPunch:punch];
                
            });
            
            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should have_received(@selector(storePunchCard:)).with(expectedPunchCard);
                
            });
            
            
            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });
            
            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });
            
            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypeStartBreak when punch has no user uri", ^{

            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:[[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"] location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:nil image:nil task:task date:nil];
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                promise = [subject persistPunch:punch];

            });

            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should_not have_received(@selector(storePunchCard:));

            });


            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });

            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });

            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });
        
        context(@"When persisting punch with action type PunchActionTypeStartBreak when punch has user uri", ^{
            
            beforeEach(^{
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:[[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"] location:nil project:project requestID:nil activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-user-uri" image:nil task:task date:nil];
                
                expectedPunchCard.userUri = punch.userURI;
                
                punchOutboxQueueCoordinator stub_method(@selector(sendPunch:))
                .with(punch)
                .and_return(punchOutboxQueueCoordinatorPromise);
                promise = [subject persistPunch:punch];
                
            });
            
            it(@"should store the punch card made from punch in to punch card storage", ^{
                punchCardStorage should_not have_received(@selector(storePunchCard:));
                
            });
            
            
            
            it(@"should store the punch in outbox", ^{
                punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(punch);
            });
            
            it(@"should tell the punch outbox queue coordinator to send the punch", ^{
                punchOutboxQueueCoordinator should have_received(@selector(sendPunch:)).with(punch);
            });
            
            it(@"should return a promise", ^{
                promise should be_same_instance_as(punchOutboxQueueCoordinatorPromise);
            });
        });

    });

    describe(@"-punchesForDate:userURI:", ^{
        __block NSURLRequest *request;
        __block KSDeferred *punchesDeferred;
        __block KSPromise *punchesPromise;
        __block NSDate *expectedDate;
        __block NSString *expectedUserURI;

        beforeEach(^{

            expectedDate = [NSDate date];
            expectedUserURI = @"Some:User-Uri";
            punchesDeferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);
            punchRequestProvider stub_method(@selector(requestForPunchesWithDate:userURI:)).again().and_return(request);

            client stub_method(@selector(promiseWithRequest:)).and_return(punchesDeferred.promise);

            punchesPromise = [subject punchesForDate:expectedDate userURI:expectedUserURI];
        });

        it(@"should get the request from the punch request provider", ^{
            punchRequestProvider should have_received(@selector(requestForPunchesWithDate:userURI:)).with(expectedDate, expectedUserURI);
        });

        it(@"should fetch the all todays punches from the server", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the fetch succeeds", ^{
            __block LocalPunch *goodPunch;
            __block LocalPunch *unknownPunch;
            __block RemotePunch *remotePunch;
            __block id<Punch> recentPunch1;
            __block id<Punch> recentPunch2;
            __block id<Punch> recentPunch3;
            beforeEach(^{
                goodPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];
                unknownPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeUnknown lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];

               remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                   nonActionedValidations:0
                                                      previousPunchStatus:Ticking
                                                          nextPunchStatus:Ticking
                                                            sourceOfPunch:UnknownSourceOfPunch
                                                               actionType:PunchActionTypePunchOut
                                                            oefTypesArray:nil
                                                             lastSyncTime:NULL
                                                                  project:nil
                                                              auditHstory:nil
                                                                breakType:nil
                                                                 location:nil
                                                               violations:nil
                                                                requestID:NULL
                                                                 activity:nil
                                                                 duration:nil
                                                                   client:nil
                                                                  address:nil
                                                                  userURI:nil
                                                                 imageURL:nil
                                                                     date:nil
                                                                     task:nil
                                                                      uri:@"some-uri"
                                                     isTimeEntryAvailable:NO
                                                         syncedWithServer:NO
                                                           isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                
                punchListDeserializer stub_method(@selector(deserialize:)).and_return(@[goodPunch, unknownPunch, remotePunch]);


                recentPunch1 = nice_fake_for(@protocol(Punch));
                recentPunch2 = nice_fake_for(@protocol(Punch));
                recentPunch3 = nice_fake_for(@protocol(Punch));
                timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);


                [punchesDeferred resolveWithValue:@{@"timepunches":@{@"punchescount":@1}}];
            });
            
            it(@"should delete all violations for punches", ^{
                violationsStorage should have_received(@selector(deleteAllRows));
            });
            
            it(@"should delete audit history for punches", ^{
                auditHistoryStorage should have_received(@selector(deleteAllRows));
            });
            
            it(@"should desereailize daysummary", ^{
                violationsStorage should have_received(@selector(storePunchViolations:)).with(@[goodPunch, unknownPunch, remotePunch]);
            });

            it(@"should call the deserializer with the return value of the client", ^{
                punchListDeserializer should have_received(@selector(deserialize:)).with(@{@"timepunches":@{@"punchescount":@1}});
            });
            it(@"should delete all the timeline punches", ^{
                [(id<CedarDouble>)timeLinePunchesStorage sent_messages].count should equal(4);
                timeLinePunchesStorage should have_received(@selector(deleteAllPunchesForDate:)).with(expectedDate);
            });
            it(@"should resolve the returned promise with the deserialized value", ^{

                TimeLinePunchesSummary *timeLinePunchesSummary = punchesPromise.value;
                timeLinePunchesSummary.timeLinePunches should equal(@[goodPunch]);
                timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
            });

        });

        context(@"when the fetch fails", ^{
            __block NSError *error;
            __block id<Punch> fakePunch1;
            __block id<Punch> fakePunch2;
            beforeEach(^{
                fakePunch1 = nice_fake_for(@protocol(Punch));
                fakePunch2 = nice_fake_for(@protocol(Punch));
                fakePunch2 stub_method(@selector(date)).and_return(expectedDate);
                timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[fakePunch1,fakePunch2]);

                timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"Some:User-Uri").and_return(@[fakePunch1,fakePunch2]);
                error = nice_fake_for([NSError class]);
                [punchesDeferred rejectWithError:error];
            });

            it(@"should reject the returned promise", ^{
                TimeLinePunchesSummary *timeLinePunchesSummary = punchesPromise.value;

                timeLinePunchesSummary.timeLinePunches should equal(@[fakePunch1,fakePunch2]);
                timeLinePunchesSummary.allPunches should equal(@[fakePunch1,fakePunch2]);
            });
        });
    });

    describe(@"-punchesForDateAndMostRecentLastTwoPunch:", ^{
        __block KSDeferred *punchesDeferred;
        __block KSPromise *punchesPromise;
        __block NSDate *expectedDate;
        __block NSDictionary *violationDictionary;
        beforeEach(^{
            violationDictionary = @{@"violations":@{@"totalViolationMessagesCount":@1}};
            expectedDate = [NSDate dateWithTimeIntervalSince1970:1436951580];
            dateProvider stub_method(@selector(date)).again().and_return(expectedDate);
            punchesDeferred = [[KSDeferred alloc] init];

            DayTimeSummary *dayTimesummary = [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                               breakTimeOffsetComponents:nil
                                                                                   regularTimeComponents:nil
                                                                                     breakTimeComponents:nil
                                                                                       timeOffComponents:nil
                                                                                          dateComponents:nil
                                                                                          isScheduledDay:YES];
            
            client stub_method(@selector(promiseWithRequest:)).and_return(punchesDeferred.promise);

            punchesPromise = [subject punchesForDateAndMostRecentLastTwoPunch:expectedDate];
        });

        it(@"should get the request from the punch request provider", ^{
            punchRequestProvider should have_received(@selector(requestForPunchesWithLastTwoMostRecentPunchWithDate:)).with(expectedDate);
        });

        it(@"should fetch the all todays punches from the server", ^{
            client should have_received(@selector(promiseWithRequest:)).with(mostRecentPunchAlongWithPunchesForDateRequest);
        });

        context(@"when the fetch succeeds", ^{
            __block LocalPunch *goodPunch;
            __block LocalPunch *unknownPunch;
            __block RemotePunch *remotePunch;
            __block id<PunchRepositoryObserver> observer1;
            __block id<PunchRepositoryObserver> observer2;
            __block id <Punch> recentPunch1;
            __block id <Punch> recentPunch2;
            __block id <Punch> recentPunch3;

            context(@"when most recent punch is an offline punch", ^{
                beforeEach(^{
                    goodPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];
                    unknownPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeUnknown lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];

                    remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                        nonActionedValidations:0
                                                           previousPunchStatus:Ticking
                                                               nextPunchStatus:Ticking
                                                                 sourceOfPunch:UnknownSourceOfPunch
                                                                    actionType:PunchActionTypePunchOut
                                                                 oefTypesArray:nil
                                                                  lastSyncTime:NULL
                                                                       project:nil
                                                                   auditHstory:nil
                                                                     breakType:nil
                                                                      location:nil
                                                                    violations:nil
                                                                     requestID:NULL
                                                                      activity:nil
                                                                      duration:nil
                                                                        client:nil
                                                                       address:nil
                                                                       userURI:nil
                                                                      imageURL:nil
                                                                          date:nil
                                                                          task:nil
                                                                           uri:@"some-uri"
                                                          isTimeEntryAvailable:NO
                                                              syncedWithServer:NO
                                                                isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));

                    [subject addObserver:observer1];
                    [subject addObserver:observer2];


                    punchListDeserializer stub_method(@selector(deserializeWithArray:)).and_return(@[goodPunch, unknownPunch, remotePunch]);

                    recentPunch1 = nice_fake_for(@protocol(Punch));
                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for([OfflineLocalPunch class]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(recentPunch3);

                    [punchesDeferred resolveWithValue:@[violationDictionary, @2, @1]];
                });
                
                it(@"should set value for totalViolationMessagesCount in userdefaults", ^{
                    defaults should have_received(@selector(setObject:forKey:)).with( @1, @"totalViolationMessagesCount");
                });
                
                it(@"should delete all violations for punches", ^{
                    violationsStorage should have_received(@selector(deleteAllRows));
                });

                it(@"should delete audit history for punches", ^{
                    auditHistoryStorage should have_received(@selector(deleteAllRows));
                });

                it(@"should desereailize daysummary", ^{
                    violationsStorage should have_received(@selector(storePunchViolations:)).with(@[goodPunch, unknownPunch, remotePunch]);
                });
                
                it(@"should store the most recent offline local punch agail", ^{
                    [(id<CedarDouble>)punchOutboxStorage sent_messages].count should equal(1);
                    punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(recentPunch3);
                });

                it(@"should delete all the timeline punches", ^{
                    [(id<CedarDouble>)timeLinePunchesStorage sent_messages].count should equal(5);
                    timeLinePunchesStorage should have_received(@selector(deleteAllPreviousPunches:));
                });

                it(@"should resolve the returned promise with the deserialized value", ^{

                    TimeLinePunchesSummary *timeLinePunchesSummary = punchesPromise.value;

                    timeLinePunchesSummary.timeLinePunches should equal(@[goodPunch]);
                    timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                });

                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                    observer2 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });
            });

            context(@"when most recent punch is an local punch", ^{
                beforeEach(^{
                    goodPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];
                    unknownPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeUnknown lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];

                    remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                        nonActionedValidations:0
                                                           previousPunchStatus:Ticking
                                                               nextPunchStatus:Ticking
                                                                 sourceOfPunch:UnknownSourceOfPunch
                                                                    actionType:PunchActionTypePunchOut
                                                                 oefTypesArray:nil
                                                                  lastSyncTime:NULL
                                                                       project:nil
                                                                   auditHstory:nil
                                                                     breakType:nil
                                                                      location:nil
                                                                    violations:nil
                                                                     requestID:NULL
                                                                      activity:nil
                                                                      duration:nil
                                                                        client:nil
                                                                       address:nil
                                                                       userURI:nil
                                                                      imageURL:nil
                                                                          date:nil
                                                                          task:nil
                                                                           uri:@"some-uri"
                                                          isTimeEntryAvailable:NO
                                                              syncedWithServer:NO
                                                                isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));

                    [subject addObserver:observer1];
                    [subject addObserver:observer2];


                    punchListDeserializer stub_method(@selector(deserializeWithArray:)).and_return(@[goodPunch, unknownPunch, remotePunch]);

                    recentPunch1 = nice_fake_for(@protocol(Punch));
                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for([LocalPunch class]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(recentPunch3);

                    [punchesDeferred resolveWithValue:@[violationDictionary, violationDictionary, violationDictionary]];
                });
                
                it(@"should set value for totalViolationMessagesCount in userdefaults", ^{
                    defaults should have_received(@selector(setObject:forKey:)).with(@1, @"totalViolationMessagesCount");
                });
                
                it(@"should delete all violations for punches", ^{
                    violationsStorage should have_received(@selector(deleteAllRows));
                });
                
                it(@"should delete audit history for punches", ^{
                    auditHistoryStorage should have_received(@selector(deleteAllRows));
                });

                it(@"should desereailize daysummary", ^{
                    violationsStorage should have_received(@selector(storePunchViolations:)).with(@[goodPunch, unknownPunch, remotePunch]);
                });


                it(@"should store the most recent offline local punch agail", ^{
                    [(id<CedarDouble>)punchOutboxStorage sent_messages].count should equal(1);
                    punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(recentPunch3);
                });

                it(@"should delete all the timeline punches", ^{
                    [(id<CedarDouble>)timeLinePunchesStorage sent_messages].count should equal(5);
                    timeLinePunchesStorage should have_received(@selector(deleteAllPreviousPunches:));
                });

                it(@"should resolve the returned promise with the deserialized value", ^{

                    TimeLinePunchesSummary *timeLinePunchesSummary = punchesPromise.value;

                    timeLinePunchesSummary.timeLinePunches should equal(@[goodPunch]);
                    timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                });

                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                    observer2 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });
            });

            context(@"when most recent punch is an remote punch", ^{
                beforeEach(^{
                    goodPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];
                    unknownPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeUnknown lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];

                    remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                        nonActionedValidations:0
                                                           previousPunchStatus:Ticking
                                                               nextPunchStatus:Ticking
                                                                 sourceOfPunch:UnknownSourceOfPunch
                                                                    actionType:PunchActionTypePunchOut
                                                                 oefTypesArray:nil
                                                                  lastSyncTime:NULL
                                                                       project:nil
                                                                   auditHstory:nil
                                                                     breakType:nil
                                                                      location:nil
                                                                    violations:nil
                                                                     requestID:NULL
                                                                      activity:nil
                                                                      duration:nil
                                                                        client:nil
                                                                       address:nil
                                                                       userURI:nil
                                                                      imageURL:nil
                                                                          date:nil
                                                                          task:nil
                                                                           uri:@"some-uri"
                                                          isTimeEntryAvailable:NO
                                                              syncedWithServer:NO
                                                                isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));

                    [subject addObserver:observer1];
                    [subject addObserver:observer2];


                    punchListDeserializer stub_method(@selector(deserializeWithArray:)).and_return(@[goodPunch, unknownPunch, remotePunch]);

                    recentPunch1 = nice_fake_for(@protocol(Punch));
                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for([RemotePunch class]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(recentPunch3);

                    [punchesDeferred resolveWithValue:@[violationDictionary, violationDictionary, violationDictionary]];
                });

                it(@"should set value for totalViolationMessagesCount in userdefaults", ^{
                    defaults should have_received(@selector(setObject:forKey:)).with(@1, @"totalViolationMessagesCount");
                });
                
                it(@"should delete all violations for punches", ^{
                    violationsStorage should have_received(@selector(deleteAllRows));
                });
                
                it(@"should delete audit history for punches", ^{
                    auditHistoryStorage should have_received(@selector(deleteAllRows));
                });

                it(@"should not store  most recent remote punch again", ^{
                    timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(recentPunch3);
                });
                
                it(@"should desereailize daysummary", ^{
                    violationsStorage should have_received(@selector(storePunchViolations:)).with(@[goodPunch, unknownPunch, remotePunch]);
                });

                it(@"should delete all the timeline punches", ^{
                    [(id<CedarDouble>)timeLinePunchesStorage sent_messages].count should equal(6);
                    timeLinePunchesStorage should have_received(@selector(deleteAllPreviousPunches:));
                });

                it(@"should resolve the returned promise with the deserialized value", ^{

                    TimeLinePunchesSummary *timeLinePunchesSummary = punchesPromise.value;

                    timeLinePunchesSummary.timeLinePunches should equal(@[goodPunch]);
                    timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                });

                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                    observer2 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });
            });

        });

        context(@"when the fetch succeeds", ^{
            __block RemotePunch *remotePunch;
            __block id <Punch> recentPunch2;
            __block id <Punch> recentPunch3;

            context(@"When the last two punches received contains invalid punch", ^{
                beforeEach(^{
                    remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                        nonActionedValidations:0
                                                           previousPunchStatus:Unknown
                                                               nextPunchStatus:Unknown
                                                                 sourceOfPunch:UnknownSourceOfPunch
                                                                    actionType:PunchActionTypePunchOut
                                                                 oefTypesArray:nil
                                                                  lastSyncTime:NULL
                                                                       project:nil
                                                                   auditHstory:nil
                                                                     breakType:nil
                                                                      location:nil
                                                                    violations:nil
                                                                     requestID:NULL
                                                                      activity:nil
                                                                      duration:nil
                                                                        client:nil
                                                                       address:nil
                                                                       userURI:nil
                                                                      imageURL:nil
                                                                          date:nil
                                                                          task:nil
                                                                           uri:@"some-uri"
                                                          isTimeEntryAvailable:NO
                                                              syncedWithServer:NO
                                                                isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    punchListDeserializer stub_method(@selector(deserializeWithArray:)).and_return(@[remotePunch]);

                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for([RemotePunch class]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch2,recentPunch3]);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(recentPunch3);

                    [punchesDeferred resolveWithValue:@[violationDictionary, violationDictionary, violationDictionary]];
                });
                
                it(@"should set value for totalViolationMessagesCount in userdefaults", ^{
                    defaults should have_received(@selector(setObject:forKey:)).with(@1, @"totalViolationMessagesCount");
                });
                
                it(@"should delete all violations for punches", ^{
                    violationsStorage should have_received(@selector(deleteAllRows));
                });
                
                it(@"should delete audit history for punches", ^{
                    auditHistoryStorage should have_received(@selector(deleteAllRows));
                });

                it(@"should desereailize daysummary", ^{
                    violationsStorage should have_received(@selector(storePunchViolations:)).with(@[remotePunch]);
                });

                it(@"should have called getPunchcard matching client-uri, project-uri and task-uri", ^{
                    punchCardStorage should have_received(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:));
                });
            });

            context(@"When the last two punches received contains invalid punch, should update isvalidpunch to NO ", ^{
                __block PunchCardObject *cardObject;
                beforeEach(^{
                    remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                        nonActionedValidations:0
                                                           previousPunchStatus:Unknown
                                                               nextPunchStatus:Unknown
                                                                 sourceOfPunch:UnknownSourceOfPunch
                                                                    actionType:PunchActionTypePunchOut
                                                                 oefTypesArray:nil
                                                                  lastSyncTime:NULL
                                                                       project:nil
                                                                   auditHstory:nil
                                                                     breakType:nil
                                                                      location:nil
                                                                    violations:nil
                                                                     requestID:NULL
                                                                      activity:nil
                                                                      duration:nil
                                                                        client:nil
                                                                       address:nil
                                                                       userURI:nil
                                                                      imageURL:nil
                                                                          date:nil
                                                                          task:nil
                                                                           uri:@"some-uri"
                                                          isTimeEntryAvailable:NO
                                                              syncedWithServer:NO
                                                                isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    punchListDeserializer stub_method(@selector(deserializeWithArray:)).and_return(@[remotePunch]);

                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for([RemotePunch class]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch2,recentPunch3]);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(recentPunch3);

                    ClientType *client = nice_fake_for([ClientType class]);
                    ProjectType *project = nice_fake_for([ProjectType class]);
                    TaskType *task = nice_fake_for([TaskType class]);

                    cardObject = [[PunchCardObject alloc] initWithClientType:client projectType:project oefTypesArray:nil breakType:nil taskType:task activity:nil uri:nil];

                    punchCardStorage stub_method(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).and_return(cardObject);

                    [punchesDeferred resolveWithValue:@[violationDictionary, @2, @1]];

                });
                
                it(@"should set value for totalViolationMessagesCount in userdefaults", ^{
                    defaults should have_received(@selector(setObject:forKey:)).with(@1, @"totalViolationMessagesCount");
                });
                
                it(@"should delete all violations for punches", ^{
                    violationsStorage should have_received(@selector(deleteAllRows));
                });
                
                it(@"should delete audit history for punches", ^{
                    auditHistoryStorage should have_received(@selector(deleteAllRows));
                });
                
                it(@"should desereailize daysummary", ^{
                    violationsStorage should have_received(@selector(storePunchViolations:)).with(@[remotePunch]);
                });
                
                it(@"should have called storepunchcard", ^{
                    punchCardStorage should have_received(@selector(storePunchCard:)).with(cardObject);
                });
            });
            
        });

        context(@"when the fetch fails", ^{
            __block id<Punch> fakePunch1;
            __block id<Punch> fakePunch2;
            beforeEach(^{
                fakePunch1 = nice_fake_for(@protocol(Punch));
                fakePunch2 = nice_fake_for(@protocol(Punch));
                fakePunch2 stub_method(@selector(date)).and_return(expectedDate);
                timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[fakePunch1,fakePunch2]);
              
                timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"Some:User-Uri").and_return(@[fakePunch1,fakePunch2]);
                [punchesDeferred rejectWithError:nice_fake_for([NSError class])];
            });

            it(@"should reject the returned promise", ^{
                TimeLinePunchesSummary *timeLinePunchesSummary = punchesPromise.value;

                timeLinePunchesSummary.timeLinePunches should equal(@[fakePunch1,fakePunch2]);
                timeLinePunchesSummary.allPunches should equal(@[fakePunch1,fakePunch2]);
            });
        });
    });

    describe(@"-deletePunchWithPunchUri:", ^{
        __block NSURLRequest *request;
        __block KSPromise *promise;
        __block KSDeferred *deleteDeferred;
        __block RemotePunch *remotePunch;
        beforeEach(^{
            request = nice_fake_for([NSURLRequest class]);
            deleteDeferred = [[KSDeferred alloc] init];
            remotePunch = nice_fake_for([RemotePunch class]);
            punchRequestProvider stub_method(@selector(deletePunchRequestWithPunchUri:))
                .with(@"my-special-uri")
                .and_return(request);

            client stub_method(@selector(promiseWithRequest:))
                .with(request)
                .and_return(deleteDeferred.promise);
            remotePunch stub_method(@selector(uri)).and_return(@"my-special-uri");
            remotePunch stub_method(@selector(userURI)).and_return(@"Some:User-Uri");
            promise = [subject deletePunchWithPunchAndFetchMostRecentPunch:remotePunch];
        });

        context(@"when the request resolves successfully", ^{
            __block NSURLRequest *fetchRequest;
            __block KSDeferred *fetchDeferred;
            __block id <Punch> expectedPunch1;
            __block id <Punch> expectedPunch2;
            __block id <Punch> recentPunch1;
            __block id <Punch> recentPunch2;
            __block id <Punch> recentPunch3;
            __block id<PunchRepositoryObserver> observer1;
            __block id<PunchRepositoryObserver> observer2;

            beforeEach(^{
                fetchDeferred = [[KSDeferred alloc] init];

                observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));

                [subject addObserver:observer1];
                [subject addObserver:observer2];

                fetchRequest = nice_fake_for([NSURLRequest class]);
                punchRequestProvider stub_method(@selector(requestForPunchesWithLastTwoMostRecentPunchWithDate:)).again().and_return(fetchRequest);

                NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1436951580];
                dateProvider stub_method(@selector(date)).again().and_return(expectedDate);

                expectedPunch1 = nice_fake_for(@protocol(Punch));
                expectedPunch1 stub_method(@selector(date)).and_return(expectedDate);
                expectedPunch1 stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                expectedPunch2 = nice_fake_for(@protocol(Punch));
                expectedPunch2 stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                
                punchListDeserializer stub_method(@selector(deserializeWithArray:)).and_return(@[expectedPunch1,expectedPunch2]);

                client stub_method(@selector(promiseWithRequest:)).with(fetchRequest).and_return(fetchDeferred.promise);

                recentPunch1 = nice_fake_for(@protocol(Punch));
                recentPunch2 = nice_fake_for(@protocol(Punch));
                recentPunch3 = nice_fake_for(@protocol(Punch));
                timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);

                [deleteDeferred resolveWithValue:[NSNull null]];
            });

            context(@"when the most recent punch is fetched successfully", ^{
                beforeEach(^{
                    NSDictionary* violationDictionary = @{@"violations":@{@"totalViolationMessagesCount":@1}};
                    [fetchDeferred resolveWithValue:@[violationDictionary]];
                });

                it(@"should resolve the promise with whatever was fetched", ^{
                    TimeLinePunchesSummary *timeLinePunchesSummary = promise.value;

                    timeLinePunchesSummary.timeLinePunches should equal(@[expectedPunch1]);
                    timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                });

            });

            context(@"when the most recent punch can't be fetched successfully", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(dateProvider.date,@"Some:User-Uri").and_return(@[expectedPunch1]);
                    [fetchDeferred rejectWithError:error];
                });

                it(@"should reject the promise with the error", ^{
                    TimeLinePunchesSummary *timeLinePunchesSummary = promise.value;

                    timeLinePunchesSummary.timeLinePunches should equal(@[expectedPunch1]);
                    timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                });


            });
        });

        context(@"when the request resolves with an error", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deleteDeferred rejectWithError:error];
            });

            it(@"should reject the promise with the error", ^{
                promise.error should equal(error);
            });
        });
    });

    describe(@"-updatePunch:", ^{
        __block KSDeferred *clientDeferred;
        __block RemotePunch *punchA;
        __block RemotePunch *punchB;
        __block KSPromise *updatePromise;

        context(@"for user context", ^{
            beforeEach(^{
                punchA = fake_for([RemotePunch class]);
                punchA stub_method(@selector(requestID)).and_return(@"Request1");

                punchB = fake_for([RemotePunch class]);
                punchB stub_method(@selector(requestID)).and_return(@"Request2");

                punchA stub_method(@selector(userURI)).and_return(@"Some:User-Uri");
                punchB stub_method(@selector(userURI)).and_return(@"Some:User-Uri");

                clientDeferred = [KSDeferred defer];

                NSURLRequest *request = fake_for([NSURLRequest class]);

                punchRequestProvider stub_method(@selector(requestToUpdatePunch:))
                .with(@[punchA,punchB]).and_return(request);

                client stub_method(@selector(promiseWithRequest:))
                .with(request).and_return(clientDeferred.promise);

                updatePromise = [subject updatePunch:@[punchA,punchB]];
            });

            context(@"should delete the old remote punch and add updated remote punch to DB", ^{

                it(@"should delete old remote punch from request id ", ^{
                    timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchA);
                    timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchB);
                });

                it(@"should save updated remote punch", ^{
                    timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(punchA);
                    timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(punchB);
                });

                it(@"should update remote punch sync status to pending before sending request", ^{
                    punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchA);
                    punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchB);
                });


            });

            context(@"when the request resolves successfully", ^{
                __block KSDeferred *fetchDeferred;
                __block id <Punch> expectedPunch1;
                __block id <Punch> expectedPunch2;
                __block id<PunchRepositoryObserver> observer1;
                __block id<Punch> recentPunch1;
                __block id<Punch> recentPunch2;
                __block id<Punch> recentPunch3;

                beforeEach(^{
                    fetchDeferred = [[KSDeferred alloc] init];

                    expectedPunch1 = nice_fake_for(@protocol(Punch));
                    expectedPunch2 = nice_fake_for(@protocol(Punch));

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    [subject addObserver:observer1];

                    punchListDeserializer stub_method(@selector(deserialize:)).and_return(@[expectedPunch1,expectedPunch2]);

                    client stub_method(@selector(promiseWithRequest:))
                    .with(mostRecentPunchAlongWithPunchesForDateRequest).and_return(fetchDeferred.promise);

                    recentPunch1 = nice_fake_for(@protocol(Punch));
                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for(@protocol(Punch));
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:User-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);
                });

                context(@"when the most recent punch is fetched successfully", ^{
                    beforeEach(^{
                        [clientDeferred resolveWithValue:@{}];
                        [fetchDeferred resolveWithValue:@{}];
                    });

                    it(@"should resolve the promise with whatever was fetched", ^{

                        TimeLinePunchesSummary *timeLinePunchesSummary = updatePromise.value;

                        timeLinePunchesSummary.timeLinePunches should equal(@[]);
                        timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                    });

                    it(@"should update punch to remote punch status", ^{
                        timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchA,nil);
                        timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                    });


                });

                context(@"when the most recent punch can't be fetched successfully", ^{
                    __block NSError *error;

                    __block id<Punch> fakePunch1;
                    __block id<Punch> fakePunch2;

                    beforeEach(^{
                        fakePunch1 = nice_fake_for(@protocol(Punch));
                        fakePunch2 = nice_fake_for(@protocol(Punch));
                        fakePunch2 stub_method(@selector(date)).and_return(dateProvider.date);
                        timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).again().with(@"Some:User-Uri").and_return(@[fakePunch1,fakePunch2]);
                        timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:User-Uri").and_return(fakePunch2);
                        timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(dateProvider.date,@"Some:User-Uri").and_return(@[fakePunch1,fakePunch2]);
                    });

                    context(@"when the internal error json is NSDictionary ", ^{
                        beforeEach(^{
                            NSDictionary *errorDictionary = @{@"displayText": @"My Special Display Text"};
                            NSDictionary *jsonResponseDictionary = @{@"d": @{@"errors": @[errorDictionary],@"erroredPunches": @[@{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"}]}};
                            error = [NSError errorWithDomain:@"PunchCreatorErrorDomain" code:0 userInfo:errorDictionary];
                            [clientDeferred resolveWithValue:jsonResponseDictionary];
                            [fetchDeferred rejectWithError:error];
                        });

                        it(@"should reject the promise with the error", ^{
                            TimeLinePunchesSummary *timeLinePunchesSummary = updatePromise.value;

                            timeLinePunchesSummary.timeLinePunches should equal(@[fakePunch1,fakePunch2]);
                            timeLinePunchesSummary.allPunches should equal(@[fakePunch1,fakePunch2]);
                        });

                        it(@"should delete old remote punch from request id ", ^{
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchA);
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchB);
                        });

                        it(@"should schedule a local notification", ^{
                            NSString *expectedAlertBody = @"My Special Display Text";
                            punchNotificationScheduler should have_received(@selector(scheduleCurrentFireDateNotificationWithAlertBody:)).with(expectedAlertBody);
                        });

                        it(@"should delete the punchA", ^{
                            punchOutboxStorage should have_received(@selector(deletePunch:)).with(punchA);
                        });

                        it(@"should update the punchremoteB status to ", ^{
                            timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                        });

                        it(@"should  notify the observers with the previously stored punch", ^{
                            observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject,fakePunch2);
                        });
                    });

                    context(@"when the internal error json is NSArray ", ^{
                        beforeEach(^{

                            NSDictionary *errorDictionary = @{@"displayText": @"My Special Display Text"};
                            NSDictionary *jsonResponseDictionary = @{@"d": @[
                                                                             @{
                                                                                 @"error" : @"<null>",
                                                                                 @"punchReference" : @{
                                                                                         @"displayText" : @"ba080447-63c6-4dfd-919a-6c479068a70e",
                                                                                         @"slug" : @"ba080447-63c6-4dfd-919a-6c479068a70e",
                                                                                         @"uri" : @"urn:replicon-tenant:astro-paktrial:time-punch:ba080447-63c6-4dfd-919a-6c479068a70e"
                                                                                         },
                                                                                 }
                                                                             ]};
                            error = [NSError errorWithDomain:RepliconNoAlertErrorDomain code:0 userInfo:errorDictionary];
                            [clientDeferred resolveWithValue:jsonResponseDictionary];
                            [fetchDeferred rejectWithError:error];
                        });

                        it(@"should reject the promise with the error", ^{
                            TimeLinePunchesSummary *timeLinePunchesSummary = updatePromise.value;

                            timeLinePunchesSummary.timeLinePunches should equal(@[fakePunch1,fakePunch2]);
                            timeLinePunchesSummary.allPunches should equal(@[fakePunch1,fakePunch2]);

                        });

                        it(@"should delete old remote punch from request id ", ^{
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchA);
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchB);
                        });


                        it(@"should update remote punch sync status to pending before sending request", ^{
                            punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchA);
                            punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchB);
                        });

                        it(@"should update the punchremoteB status to ", ^{
                            timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                        });

                        it(@"should not notify the observers with the previously stored punch", ^{
                            observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject,fakePunch2);
                        });

                    });
                });
            });

            context(@"when the request resolves with an error", ^{
                __block NSError *error;
                __block id<PunchRepositoryObserver> observer1;
                __block id<PunchRepositoryObserver> observer2;
                beforeEach(^{
                    error = fake_for([NSError class]);

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    [subject addObserver:observer1];
                    [subject addObserver:observer2];
                    
                    [clientDeferred rejectWithError:error];
                });
                
                it(@"should send the punch from the request provider to the client", ^{
                    client should have_received(@selector(promiseWithRequest:)).with(mostRecentPunchAlongWithPunchesForDateRequest);
                });
                
                it(@"should reject the promise with the error", ^{
                    updatePromise.error should be_same_instance_as(error);
                });
                
                it(@"should delete old remote punch from request id ", ^{
                    failedPunchStorage should have_received(@selector(updateStatusOfRemotePunchToUnsubmitted:)).with(punchA);
                    failedPunchStorage should have_received(@selector(updateStatusOfRemotePunchToUnsubmitted:)).with(punchB);
                });
                
                it(@"should schedule a local notification", ^{
                    NSString *expectedAlertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
                    punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
                });
                
                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                    observer2 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });
            });
        });

        context(@"for supervisor context", ^{
            beforeEach(^{
                punchA = fake_for([RemotePunch class]);
                punchA stub_method(@selector(requestID)).and_return(@"Request1");

                punchB = fake_for([RemotePunch class]);
                punchB stub_method(@selector(requestID)).and_return(@"Request2");

                punchA stub_method(@selector(userURI)).and_return(@"Some:Reportee-Uri");
                punchB stub_method(@selector(userURI)).and_return(@"Some:Reportee-Uri");

                clientDeferred = [KSDeferred defer];

                NSURLRequest *request = fake_for([NSURLRequest class]);

                punchRequestProvider stub_method(@selector(requestToUpdatePunch:))
                .with(@[punchA,punchB]).and_return(request);

                client stub_method(@selector(promiseWithRequest:))
                .with(request).and_return(clientDeferred.promise);

                updatePromise = [subject updatePunch:@[punchA,punchB]];
            });

            context(@"should delete the old remote punch and add updated remote punch to DB", ^{

                it(@"should delete old remote punch from request id ", ^{
                    timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchA);
                    timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchB);
                });

                it(@"should save updated remote punch", ^{
                    timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(punchA);
                    timeLinePunchesStorage should have_received(@selector(storeRemotePunch:)).with(punchB);
                });

                it(@"should update remote punch sync status to pending before sending request", ^{
                    punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchA);
                    punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchB);
                });


            });

            context(@"when the request resolves successfully", ^{
                __block KSDeferred *fetchDeferred;
                __block id <Punch> expectedPunch1;
                __block id <Punch> expectedPunch2;
                __block id<PunchRepositoryObserver> observer1;
                __block id<Punch> recentPunch1;
                __block id<Punch> recentPunch2;
                __block id<Punch> recentPunch3;

                beforeEach(^{
                    fetchDeferred = [[KSDeferred alloc] init];

                    expectedPunch1 = nice_fake_for(@protocol(Punch));
                    expectedPunch2 = nice_fake_for(@protocol(Punch));

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    [subject addObserver:observer1];

                    punchListDeserializer stub_method(@selector(deserialize:)).and_return(@[expectedPunch1,expectedPunch2]);

                    client stub_method(@selector(promiseWithRequest:))
                    .with(punchesForDateRequest).and_return(fetchDeferred.promise);

                    recentPunch1 = nice_fake_for(@protocol(Punch));
                    recentPunch2 = nice_fake_for(@protocol(Punch));
                    recentPunch3 = nice_fake_for(@protocol(Punch));
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"Some:Reportee-Uri").and_return(@[recentPunch1,recentPunch2,recentPunch3]);
                });

                context(@"when the most recent punch is fetched successfully", ^{
                    beforeEach(^{
                        [clientDeferred resolveWithValue:@{}];
                        [fetchDeferred resolveWithValue:@{}];
                    });

                    it(@"should resolve the promise with whatever was fetched", ^{

                        TimeLinePunchesSummary *timeLinePunchesSummary = updatePromise.value;

                        timeLinePunchesSummary.timeLinePunches should equal(@[]);
                        timeLinePunchesSummary.allPunches should equal(@[recentPunch1,recentPunch2,recentPunch3]);
                    });

                    it(@"should update punch to remote punch status", ^{
                        timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchA,nil);
                        timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                    });


                });

                context(@"when the most recent punch can't be fetched successfully", ^{
                    __block NSError *error;

                    __block id<Punch> fakePunch1;
                    __block id<Punch> fakePunch2;

                    beforeEach(^{
                        fakePunch1 = nice_fake_for(@protocol(Punch));
                        fakePunch2 = nice_fake_for(@protocol(Punch));
                        fakePunch2 stub_method(@selector(date)).and_return(dateProvider.date);
                        timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).again().with(@"Some:Reportee-Uri").and_return(@[fakePunch1,fakePunch2]);
                        timeLinePunchesStorage stub_method(@selector(mostRecentPunchForUserUri:)).with(@"Some:Reportee-Uri").and_return(fakePunch2);
                        timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(dateProvider.date,@"Some:Reportee-Uri").and_return(@[fakePunch1,fakePunch2]);
                    });

                    context(@"when the internal error json is NSDictionary ", ^{
                        beforeEach(^{
                            NSDictionary *errorDictionary = @{@"displayText": @"My Special Display Text"};
                            NSDictionary *jsonResponseDictionary = @{@"d": @{@"errors": @[errorDictionary],@"erroredPunches": @[@{@"displayText": @"My Special Display Text",@"parameterCorrelationId": @"Request1"}]}};
                            error = [NSError errorWithDomain:@"PunchCreatorErrorDomain" code:0 userInfo:errorDictionary];
                            [clientDeferred resolveWithValue:jsonResponseDictionary];
                            [fetchDeferred rejectWithError:error];
                        });

                        it(@"should reject the promise with the error", ^{
                            TimeLinePunchesSummary *timeLinePunchesSummary = updatePromise.value;

                            timeLinePunchesSummary.timeLinePunches should equal(@[fakePunch1,fakePunch2]);
                            timeLinePunchesSummary.allPunches should equal(@[fakePunch1,fakePunch2]);
                        });

                        it(@"should delete old remote punch from request id ", ^{
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchA);
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchB);
                        });

                        it(@"should schedule a local notification", ^{
                            NSString *expectedAlertBody = @"My Special Display Text";
                            punchNotificationScheduler should have_received(@selector(scheduleCurrentFireDateNotificationWithAlertBody:)).with(expectedAlertBody);
                        });

                        it(@"should delete the punchA", ^{
                            punchOutboxStorage should have_received(@selector(deletePunch:)).with(punchA);
                        });

                        it(@"should update the punchremoteB status to ", ^{
                            timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                        });

                        it(@"should  notify the observers with the previously stored punch", ^{
                            observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject,fakePunch2);
                        });
                    });

                    context(@"when the internal error json is NSArray ", ^{
                        beforeEach(^{

                            NSDictionary *errorDictionary = @{@"displayText": @"My Special Display Text"};
                            NSDictionary *jsonResponseDictionary = @{@"d": @[
                                                                             @{
                                                                                 @"error" : @"<null>",
                                                                                 @"punchReference" : @{
                                                                                         @"displayText" : @"ba080447-63c6-4dfd-919a-6c479068a70e",
                                                                                         @"slug" : @"ba080447-63c6-4dfd-919a-6c479068a70e",
                                                                                         @"uri" : @"urn:replicon-tenant:astro-paktrial:time-punch:ba080447-63c6-4dfd-919a-6c479068a70e"
                                                                                         },
                                                                                 }
                                                                             ]};
                            error = [NSError errorWithDomain:RepliconNoAlertErrorDomain code:0 userInfo:errorDictionary];
                            [clientDeferred resolveWithValue:jsonResponseDictionary];
                            [fetchDeferred rejectWithError:error];
                        });

                        it(@"should reject the promise with the error", ^{
                            TimeLinePunchesSummary *timeLinePunchesSummary = updatePromise.value;

                            timeLinePunchesSummary.timeLinePunches should equal(@[fakePunch1,fakePunch2]);
                            timeLinePunchesSummary.allPunches should equal(@[fakePunch1,fakePunch2]);

                        });

                        it(@"should delete old remote punch from request id ", ^{
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchA);
                            timeLinePunchesStorage should have_received(@selector(deleteOldRemotePunch:)).with(punchB);
                        });


                        it(@"should update remote punch sync status to pending before sending request", ^{
                            punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchA);
                            punchOutboxStorage should have_received(@selector(updateSyncStatusToPendingAndSave:)).with(punchB);
                        });

                        it(@"should update the punchremoteB status to ", ^{
                            timeLinePunchesStorage should have_received(@selector(updateSyncStatusToRemoteAndSaveWithPunch:withRemoteUri:)).with(punchB,nil);
                        });

                        it(@"should not notify the observers with the previously stored punch", ^{
                            observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject,fakePunch2);
                        });

                    });
                });
            });

            context(@"when the request resolves with an error", ^{
                __block NSError *error;
                __block id<PunchRepositoryObserver> observer1;
                __block id<PunchRepositoryObserver> observer2;
                beforeEach(^{
                    error = fake_for([NSError class]);

                    observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    observer2 = nice_fake_for(@protocol(PunchRepositoryObserver));
                    [subject addObserver:observer1];
                    [subject addObserver:observer2];
                    
                    [clientDeferred rejectWithError:error];
                });
                
                it(@"should send the punch from the request provider to the client", ^{
                    client should have_received(@selector(promiseWithRequest:)).with(punchesForDateRequest);
                });
                
                it(@"should reject the promise with the error", ^{
                    updatePromise.error should be_same_instance_as(error);
                });
                
                it(@"should delete old remote punch from request id ", ^{
                    failedPunchStorage should have_received(@selector(updateStatusOfRemotePunchToUnsubmitted:)).with(punchA);
                    failedPunchStorage should have_received(@selector(updateStatusOfRemotePunchToUnsubmitted:)).with(punchB);
                });
                
                it(@"should schedule a local notification", ^{
                    NSString *expectedAlertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
                    punchNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:)).with(expectedAlertBody);
                });
                
                it(@"should not notify the observers with the previously stored punch", ^{
                    observer1 should_not have_received(@selector(punchRepository:didUpdateMostRecentPunch:));
                });
            });
        });
    });

    describe(@"-recalculateScriptDataForuserUri:WithDateDict", ^{

        __block NSString *userURI = @"my-user-URI";
        __block NSDictionary *dateDict = @{@"date": @"my-special-date"};
        __block KSPromise *scriptServicePromise;
        __block KSDeferred *fetchDeferred;

        beforeEach(^{

            fetchDeferred = [[KSDeferred alloc] init];

            NSURLRequest *fetchRequest = fake_for([NSURLRequest class]);

            punchRequestProvider stub_method(@selector(requestToRecalculateScriptDataForuser:withDateDict:)).with(userURI,dateDict).and_return(fetchRequest);

            client stub_method(@selector(promiseWithRequest:))
            .with(fetchRequest).and_return(fetchDeferred.promise);

            scriptServicePromise = [subject recalculateScriptDataForuserUri:userURI withDateDict:dateDict];

        });

        it(@"should call requestToRecalculateScriptDataForuser:withDateDict:", ^{
            punchRequestProvider should have_received(@selector(requestToRecalculateScriptDataForuser:withDateDict:)).with(userURI, dateDict);
        });

        context(@"When the request is successfull", ^{
            __block NSDictionary *expectedValue;
            beforeEach(^{
                expectedValue = @{@"d": [NSNull null]};
                [fetchDeferred resolveWithValue:expectedValue];
            });

            it(@"should resolve the scriptServicePromise with correct value", ^{
                scriptServicePromise.value should equal(expectedValue);
            });
        });

        context(@"When the request is failure", ^{
            __block NSError *expectedError;
            beforeEach(^{
                expectedError = nice_fake_for([NSError class]);
                [fetchDeferred rejectWithError:expectedError];
            });

            it(@"should resolve the scriptServicePromise with correct value", ^{
                scriptServicePromise.error should equal(expectedError);
            });
        });
    });

    describe(@"as a punch queue coordinator delegate", ^{

        it(@"should set itself as the queue coordinator's delegate", ^{
            punchOutboxQueueCoordinator should have_received(@selector(setDelegate:)).with(subject);
        });

        it(@"should inform its observers when punches are synced", ^{
            id<PunchRepositoryObserver> observer1 = nice_fake_for(@protocol(PunchRepositoryObserver));

            [subject addObserver:observer1];

            LocalPunch *localRecentPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:[NSDate date]];
            
            
            timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).and_return(localRecentPunch);

            [subject punchOutboxQueueCoordinatorDidSyncPunches:nil];


            observer1 should have_received(@selector(punchRepositoryDidSyncPunches:)).with(subject);

            observer1 should have_received(@selector(punchRepository:didUpdateMostRecentPunch:)).with(subject,localRecentPunch);
        });

        it(@"should get the punch card from the punch card storage", ^{

            LocalPunch *invalidPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:[NSDate date]];

            invalidPunch.isTimeEntryAvailable = NO;

            timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).and_return(invalidPunch);

            [subject punchOutboxQueueCoordinatorDidThrowInvalidPunchError:nil withPunch:invalidPunch];

            punchCardStorage should have_received(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).with(invalidPunch.client, invalidPunch.project, invalidPunch.task);


        });

        it(@"should store punch card with invalid punch set to NO", ^{

            LocalPunch *invalidPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:[NSDate date]];

            invalidPunch.isTimeEntryAvailable = NO;

            ClientType *client = nice_fake_for([ClientType class]);
            ProjectType *project = nice_fake_for([ProjectType class]);
            TaskType *task = nice_fake_for([TaskType class]);

            PunchCardObject *cardObject = [[PunchCardObject alloc] initWithClientType:client projectType:project oefTypesArray:nil breakType:nil taskType:task activity:nil uri:nil];

            timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).and_return(invalidPunch);

            punchCardStorage stub_method(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).and_return(cardObject);

            [subject punchOutboxQueueCoordinatorDidThrowInvalidPunchError:nil withPunch:invalidPunch];

            punchCardStorage should have_received(@selector(storePunchCard:)).with(cardObject);

        });
    });
});

SPEC_END
