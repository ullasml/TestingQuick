#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchClock.h"
#import "DateProvider.h"
#import "LocationRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchRepository.h"
#import "LocalPunch.h"
#import "Constants.h"
#import "AddressRepository.h"
#import "PunchAssemblyWorkflow.h"
#import "BreakType.h"
#import "OfflineLocalPunch.h"
#import "UserSession.h"
#import <KSDeferred/KSPromise.h>
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ManualPunch.h"
#import "Activity.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "GUIDProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchClockSpec)

describe(@"PunchClock", ^{
    __block PunchClock *subject;
    __block PunchRepository *punchRepository;
    __block PunchAssemblyWorkflow<CedarDouble> *punchAssemblyWorkflow;
    __block id<PunchAssemblyWorkflowDelegate>punchAssemblyWorkflowDelegate;
    __block NSDate *expectedDate;
    __block DateProvider *dateProvider;
    __block LocalPunch *incompletePunch;
    __block KSDeferred *persistPunchDeferred;
    __block id<UserSession> userSession;
    __block GUIDProvider *guidProvider;
    __block NSArray *oefTypesArray;
    beforeEach(^{
        
        guidProvider = nice_fake_for([GUIDProvider class]);
        
        guidProvider stub_method(@selector(guid)).and_return(@"guid-A");

        persistPunchDeferred = [[KSDeferred alloc] init];
        punchRepository = nice_fake_for([PunchRepository class]);

        punchRepository stub_method(@selector(persistPunch:)).and_return(persistPunchDeferred.promise);
        punchAssemblyWorkflow = nice_fake_for([PunchAssemblyWorkflow class]);
        punchAssemblyWorkflowDelegate = nice_fake_for(@protocol(PunchAssemblyWorkflowDelegate));

        expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider = nice_fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(expectedDate);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");

        OEFType *oefType1 = nice_fake_for([OEFType class]);
        OEFType *oefType2 = nice_fake_for([OEFType class]);
        oefTypesArray = @[oefType1,oefType2];

        subject = [[PunchClock alloc]
                               initWithPunchRepository:punchRepository
                                 punchAssemblyWorkflow:punchAssemblyWorkflow
                                           userSession:userSession
                                          dateProvider:dateProvider
                                          guidProvider:guidProvider];
    });

    describe(@"-punchInWithPunchAssemblyWorkflowDelegate:", ^{

        __block KSDeferred *punchAssemblyWorkflowDeferred;

        beforeEach(^{
            punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
            punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).and_return(punchAssemblyWorkflowDeferred.promise);

            incompletePunch = [[LocalPunch alloc]
                                           initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                        actionType:PunchActionTypePunchIn
                                                      lastSyncTime:NULL
                                                         breakType:nil
                                                          location:nil
                                                           project:nil
                                                         requestID:@"guid-A"
                                                          activity:nil
                                                            client:nil
                                                          oefTypes:nil
                                                           address:nil
                                                           userURI:@"user-uri"
                                                             image:nil
                                                              task:nil
                                                              date:expectedDate];

            [subject punchInWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate oefData:nil];
        });

        it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
        });

        context(@"when the punch assembly workflow finishes", ^ {
            __block LocalPunch *finishedPunch;

            beforeEach(^{
                finishedPunch = nice_fake_for([LocalPunch class]);
                [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
            });

            it(@"should persist the punch", ^{
                punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
            });
        });
    });
    
    describe(@"-punchInWithPunchAssemblyWorkflowDelegate: with oef", ^{
        
        __block KSDeferred *punchAssemblyWorkflowDeferred;
        beforeEach(^{
            punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
            punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).and_return(punchAssemblyWorkflowDeferred.promise);
            
            incompletePunch = [[LocalPunch alloc]
                               initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                               actionType:PunchActionTypePunchIn
                               lastSyncTime:NULL
                               breakType:nil
                               location:nil
                               project:nil
                               requestID:@"guid-A"
                               activity:nil
                               client:nil
                               oefTypes:oefTypesArray
                               address:nil
                               userURI:@"user-uri"
                               image:nil
                               task:nil
                               date:expectedDate];
            
            [subject punchInWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate oefData:oefTypesArray];
        });
        
        it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
        });
        
        context(@"when the punch assembly workflow finishes", ^ {
            __block LocalPunch *finishedPunch;
            
            beforeEach(^{
                finishedPunch = nice_fake_for([LocalPunch class]);
                [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
            });
            
            it(@"should persist the punch", ^{
                punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
            });
        });
    });

    describe(@"-punchOutWithPunchAssemblyWorkflowDelegate:", ^{
        describe(@"punching out", ^{
            __block KSDeferred *punchAssemblyWorkflowDeferred;

            beforeEach(^{
                punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).and_return(punchAssemblyWorkflowDeferred.promise);

                incompletePunch = [[LocalPunch alloc]
                                               initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                            actionType:PunchActionTypePunchOut
                                                          lastSyncTime:NULL
                                                             breakType:nil
                                                              location:nil
                                                               project:nil
                                                             requestID:@"guid-A"
                                                              activity:nil
                                                                client:nil
                                                              oefTypes:nil
                                                               address:nil
                                                               userURI:nil
                                                                 image:nil
                                                                  task:nil
                                                                  date:expectedDate];

                [subject punchOutWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate oefData:nil];
            });

            it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
                LocalPunch *incompletePunch = [[LocalPunch alloc]
                                                           initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                        actionType:PunchActionTypePunchOut
                                                                      lastSyncTime:NULL
                                                                         breakType:nil
                                                                          location:nil
                                                                           project:nil
                                                                         requestID:@"guid-A"
                                                                          activity:nil
                                                                            client:nil
                                                                          oefTypes:nil
                                                                           address:nil
                                                                           userURI:@"user-uri"
                                                                             image:nil
                                                                              task:nil
                                                                              date:expectedDate];
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
            });

            context(@"when the punch assembly workflow finishes", ^{
                __block LocalPunch *finishedPunch;

                beforeEach(^{
                    finishedPunch = nice_fake_for([LocalPunch class]);
                    [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
                });

                it(@"should persist the punch", ^{
                    punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
                });
            });
        });
    });
    
    describe(@"-punchOutWithPunchAssemblyWorkflowDelegate: with oef", ^{
        describe(@"punching out", ^{
            __block KSDeferred *punchAssemblyWorkflowDeferred;
            
            beforeEach(^{
                punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).and_return(punchAssemblyWorkflowDeferred.promise);
                
                incompletePunch = [[LocalPunch alloc]
                                   initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                   actionType:PunchActionTypePunchOut
                                   lastSyncTime:NULL
                                   breakType:nil
                                   location:nil
                                   project:nil
                                   requestID:@"guid-A"
                                   activity:nil
                                   client:nil
                                   oefTypes:oefTypesArray
                                   address:nil
                                   userURI:nil
                                   image:nil
                                   task:nil
                                   date:expectedDate];
                
                [subject punchOutWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate oefData:oefTypesArray];
            });
            
            it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
                LocalPunch *incompletePunch = [[LocalPunch alloc]
                                               initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                               actionType:PunchActionTypePunchOut
                                               lastSyncTime:NULL
                                               breakType:nil
                                               location:nil
                                               project:nil
                                               requestID:@"guid-A"
                                               activity:nil
                                               client:nil
                                               oefTypes:oefTypesArray
                                               address:nil
                                               userURI:@"user-uri"
                                               image:nil
                                               task:nil
                                               date:expectedDate];
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
            });
            
            context(@"when the punch assembly workflow finishes", ^{
                __block LocalPunch *finishedPunch;
                
                beforeEach(^{
                    finishedPunch = nice_fake_for([LocalPunch class]);
                    [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
                });
                
                it(@"should persist the punch", ^{
                    punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
                });
            });
        });
    });

    describe(@"-takeBreakWithBreakDate:breakType:punchAssemblyWorkflowDelegate:", ^{
        describe(@"taking a break", ^{
            __block NSDate *breakDate;
            __block KSDeferred *punchAssemblyWorkflowDeferred;
            __block KSPromise *serverDidFinishPunchPromise;

            beforeEach(^{
                punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:))
                .and_do_block(^KSPromise *(LocalPunch *receivedPunch, KSPromise *receivedPromise, id<PunchAssemblyWorkflowDelegate>receivedDelegate){
                    serverDidFinishPunchPromise = receivedPromise;
                    return punchAssemblyWorkflowDeferred.promise;
                });

                breakDate = [NSDate dateWithTimeIntervalSinceNow:123];

                BreakType *breakType = [[BreakType alloc] initWithName:@"meal" uri:@"meal-uri"];

                [subject takeBreakWithBreakDate:breakDate
                                      breakType:breakType
                  punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate];
            });

            it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:));
                BreakType *breakType = [[BreakType alloc] initWithName:@"meal" uri:@"meal-uri"];
                LocalPunch *incompletePunch = [[LocalPunch alloc]
                                                           initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                        actionType:PunchActionTypeStartBreak
                                                                      lastSyncTime:NULL
                                                                         breakType:breakType
                                                                          location:nil
                                                                           project:nil
                                                                         requestID:@"guid-A"
                                                                          activity:nil
                                                                            client:nil
                                                                          oefTypes:nil
                                                                           address:nil
                                                                           userURI:@"user-uri"
                                                                             image:nil
                                                                              task:nil
                                                                              date:breakDate];

                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
            });

            context(@"when the punch assembly workflow finishes", ^{
                __block LocalPunch *finishedPunch;

                beforeEach(^{
                    finishedPunch = nice_fake_for([LocalPunch class]);
                    [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
                });

                it(@"should persist the punch", ^{
                    punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
                });

                context(@"when the punch repository request succeeds", ^{
                    beforeEach(^{
                        [persistPunchDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should resolve the serverDidFinishPunchDeferred", ^{
                        serverDidFinishPunchPromise.value should be_same_instance_as(finishedPunch);
                    });
                });
            });
        });
    });
    
    describe(@"-takeBreakWithBreakDateAndOef:breakType:punchAssemblyWorkflowDelegate:", ^{
        describe(@"taking a break", ^{
            __block NSDate *breakDate;
            __block KSDeferred *punchAssemblyWorkflowDeferred;
            __block KSPromise *serverDidFinishPunchPromise;
            __block NSArray * oefTypesArray;
            beforeEach(^{
                punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:))
                .and_do_block(^KSPromise *(LocalPunch *receivedPunch, KSPromise *receivedPromise, id<PunchAssemblyWorkflowDelegate>receivedDelegate){
                    serverDidFinishPunchPromise = receivedPromise;
                    return punchAssemblyWorkflowDeferred.promise;
                });
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                breakDate = [NSDate dateWithTimeIntervalSinceNow:123];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"meal" uri:@"meal-uri"];
                
                [subject takeBreakWithBreakDateAndOEF:breakDate
                                      breakType:breakType
                                              oefData:oefTypesArray
                  punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate];
            });
            
            it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:));
                BreakType *breakType = [[BreakType alloc] initWithName:@"meal" uri:@"meal-uri"];
                LocalPunch *incompletePunch = [[LocalPunch alloc]
                                               initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                               actionType:PunchActionTypeStartBreak
                                               lastSyncTime:NULL
                                               breakType:breakType
                                               location:nil
                                               project:nil
                                               requestID:@"guid-A"
                                               activity:nil
                                               client:nil
                                               oefTypes:oefTypesArray
                                               address:nil
                                               userURI:@"user-uri"
                                               image:nil
                                               task:nil
                                               date:breakDate];
                
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
            });
            
            context(@"when the punch assembly workflow finishes", ^{
                __block LocalPunch *finishedPunch;
                
                beforeEach(^{
                    finishedPunch = nice_fake_for([LocalPunch class]);
                    [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
                });
                
                it(@"should persist the punch", ^{
                    punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
                });
                
                context(@"when the punch repository request succeeds", ^{
                    beforeEach(^{
                        [persistPunchDeferred resolveWithValue:(id)[NSNull null]];
                    });
                    
                    it(@"should resolve the serverDidFinishPunchDeferred", ^{
                        serverDidFinishPunchPromise.value should be_same_instance_as(finishedPunch);
                    });
                });
            });
        });
    });

    describe(@"-punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:", ^{
        __block LocalPunch *punch;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;
        __block Activity *activity;
        __block NSArray *oefTypesArray;
        beforeEach(^{
            client = nice_fake_for([ClientType class]);
            project = nice_fake_for([ProjectType class]);
            task = nice_fake_for([TaskType class]);
            activity = nice_fake_for([Activity class]);
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:123];
            BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal:break:uri"];
            punch = [[LocalPunch alloc]
                                 initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                              actionType:PunchActionTypeStartBreak
                                            lastSyncTime:NULL
                                               breakType:breakType
                                                location:nil
                                                 project:project
                                               requestID:@"guid-A"
                                                activity:activity
                                                  client:client
                                                oefTypes:oefTypesArray
                                                 address:nil
                                                 userURI:@"user:uri"
                                                   image:nil
                                                    task:task
                                                    date:date];
        });

        context(@"when the punch has been assembled succesfully", ^{
            __block KSDeferred *assembleDeferred;
            __block LocalPunch *assembledPunch;
            beforeEach(^{
                assembledPunch = nice_fake_for([LocalPunch class]);
                assembleDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleManualIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(Arguments::anything, Arguments::any([KSPromise class]), punchAssemblyWorkflowDelegate).and_return(assembleDeferred.promise);
                
                [assembleDeferred resolveWithValue:assembledPunch];
            });

            context(@"when the punch has been saved on the server", ^{
                __block KSDeferred *serverResponseDeferred;
                __block KSPromise *punchFinishPromise;
                beforeEach(^{
                    serverResponseDeferred = [[KSDeferred alloc] init];
                    punchRepository stub_method(@selector(persistPunch:))
                    .with(assembledPunch)
                    .and_return(serverResponseDeferred.promise);
                    [serverResponseDeferred resolveWithValue:nil];
                    punchFinishPromise = [subject punchWithManualLocalPunch:punch punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate];
                });

                it(@"should return the correct promise to observer", ^{
                    punchFinishPromise.fulfilled should be_truthy;
                });

                it(@"should send a offline punch to the punch assembly workflow ", ^{
                    NSInvocation *invocation = [[punchAssemblyWorkflow sent_messages] firstObject];
                    __autoreleasing LocalPunch *receivedIncompletePunch;
                    [invocation getArgument:&receivedIncompletePunch atIndex:2];
                    receivedIncompletePunch.actionType should equal(punch.actionType);
                    receivedIncompletePunch.date should equal(punch.date);
                    receivedIncompletePunch.userURI should equal(punch.userURI);
                    receivedIncompletePunch.breakType should equal(punch.breakType);
                    receivedIncompletePunch.project should equal(punch.project);
                    receivedIncompletePunch.client should equal(punch.client);
                    receivedIncompletePunch.task should equal(punch.task);
                    receivedIncompletePunch.activity should equal(punch.activity);
                    receivedIncompletePunch.oefTypesArray should equal(punch.oefTypesArray);
                    receivedIncompletePunch should be_instance_of([ManualPunch class]);
                    receivedIncompletePunch.requestID should equal(punch.requestID);
                });
            });

            context(@"when the punch has failed to save on the server and Punch has User uri", ^{
                __block KSDeferred *serverResponseDeferred;
                __block KSPromise *punchFinishPromise;
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    serverResponseDeferred = [[KSDeferred alloc] init];
                    
                    punchRepository stub_method(@selector(persistPunch:))
                    .with(assembledPunch)
                    .and_return(serverResponseDeferred.promise);
                    
                    [serverResponseDeferred rejectWithError:error];
                    
                    punchFinishPromise = [subject punchWithManualLocalPunch:punch punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate];
                });

                it(@"should return the correct promise to observer", ^{
                    punchFinishPromise.fulfilled should be_falsy;
                    punchFinishPromise.error should equal(error);
                });
                
                it(@"should fetch the most recent punch from the punch clock", ^{
                    subject.punchRepository should have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"user:uri");
                });
            });
            
            context(@"when the punch has failed to save on the server and Punch has no User uri", ^{
                __block KSDeferred *serverResponseDeferred;
                __block KSPromise *punchFinishPromise;
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    serverResponseDeferred = [[KSDeferred alloc] init];
                    
                    LocalPunch *punch_ = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:nil activity:nil client:nil oefTypes:nil address:nil userURI:@"" image:nil task:nil date:nil];
                    
                    punchRepository stub_method(@selector(persistPunch:))
                    .with(assembledPunch)
                    .and_return(serverResponseDeferred.promise);
                    
                    [serverResponseDeferred rejectWithError:error];
                    
                    punchFinishPromise = [subject punchWithManualLocalPunch:punch_ punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate];
                });
                
                it(@"should return the correct promise to observer", ^{
                    punchFinishPromise.fulfilled should be_falsy;
                    punchFinishPromise.error should equal(error);
                });
                it(@"should fetch the most recent punch from the punch clock", ^{
                    subject.punchRepository should have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"user-uri");
                });
            });
        });
        

        context(@"When the punch has been not assembled", ^{
            __block KSDeferred *assembleDeferred;
            __block NSError *error;
            __block KSPromise *punchFinishPromise;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                assembleDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:))

                .with(Arguments::anything, Arguments::any([KSPromise class]), punchAssemblyWorkflowDelegate)
                .and_return(assembleDeferred.promise);
                [assembleDeferred rejectWithError:error];

                punchFinishPromise = [subject punchWithManualLocalPunch:punch punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate];
            });

            it(@"should reject the promise correctly", ^{
                punchFinishPromise.fulfilled should be_falsy;
            });

        });
    });

    describe(@"-resumeWorkWithPunchAssemblyWorkflowDelegate:", ^{
        describe(@"resuming work after a break", ^{
            __block KSDeferred *punchAssemblyWorkflowDeferred;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).and_return(punchAssemblyWorkflowDeferred.promise);

                incompletePunch = [[LocalPunch alloc]
                                               initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                            actionType:PunchActionTypeTransfer
                                                          lastSyncTime:NULL
                                                             breakType:nil
                                                              location:nil
                                                               project:nil
                                                             requestID:@"guid-A"
                                                              activity:nil
                                                                client:nil
                                                              oefTypes:oefTypesArray
                                                               address:nil
                                                               userURI:@"user-uri"
                                                                 image:nil
                                                                  task:nil
                                                                  date:expectedDate];

                [subject resumeWorkWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate oefData:oefTypesArray];
            });

            it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
            });

            context(@"when the punch assembly workflow finishes", ^ {
                __block LocalPunch *finishedPunch;

                beforeEach(^{
                    finishedPunch = nice_fake_for([LocalPunch class]);
                    [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
                });

                it(@"should persist the punch", ^{
                    punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
                });
            });
        });
        
        describe(@"resuming work after a break with out oef", ^{
            __block KSDeferred *punchAssemblyWorkflowDeferred;
            beforeEach(^{
                punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
                punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).and_return(punchAssemblyWorkflowDeferred.promise);
                
                incompletePunch = [[LocalPunch alloc]
                                   initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                   actionType:PunchActionTypeTransfer
                                   lastSyncTime:NULL
                                   breakType:nil
                                   location:nil
                                   project:nil
                                   requestID:@"guid-A"
                                   activity:nil
                                   client:nil
                                   oefTypes:nil
                                   address:nil
                                   userURI:@"user-uri"
                                   image:nil
                                   task:nil
                                   date:expectedDate];
                
                [subject resumeWorkWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate oefData:nil];
            });
            
            it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
                punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
            });
            
            context(@"when the punch assembly workflow finishes", ^ {
                __block LocalPunch *finishedPunch;
                
                beforeEach(^{
                    finishedPunch = nice_fake_for([LocalPunch class]);
                    [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
                });
                
                it(@"should persist the punch", ^{
                    punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
                });
            });
        });
    });

    describe(@"-punchInWithPunchAssemblyWorkflowDelegate:clientType:projectType:taskType:activity:oefTypesArray:", ^{

        __block KSDeferred *punchAssemblyWorkflowDeferred;
        __block KSPromise *serverDidFinishPunchPromise;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;
        __block Activity *activity;
        __block NSArray *oefTypesArray;

        beforeEach(^{
            punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
            punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:))
            .and_do_block(^KSPromise *(LocalPunch *receivedPunch, KSPromise *receivedPromise, id<PunchAssemblyWorkflowDelegate>receivedDelegate){
                serverDidFinishPunchPromise = receivedPromise;
                return punchAssemblyWorkflowDeferred.promise;
            });

            client = nice_fake_for([ClientType class]);
            project = nice_fake_for([ProjectType class]);
            task = nice_fake_for([TaskType class]);
            activity = nice_fake_for([Activity class]);
            OEFType *oefType1 =  nice_fake_for([OEFType class]);
            OEFType *oefType2 =  nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];

            [subject punchInWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate clientType:client projectType:project taskType:task activity:activity oefTypesArray:oefTypesArray];
        });

        it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:));
            LocalPunch *incompletePunch = [[LocalPunch alloc]
                                                       initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                    actionType:PunchActionTypePunchIn
                                                                  lastSyncTime:NULL
                                                                     breakType:nil
                                                                      location:nil
                                                                       project:project
                                                                     requestID:@"guid-A"
                                                                      activity:activity
                                                                        client:client
                                                                      oefTypes:oefTypesArray
                                                                       address:nil
                                                                       userURI:@"user-uri"
                                                                         image:nil
                                                                          task:task
                                                                          date:expectedDate];

            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
        });

        context(@"when the punch assembly workflow finishes", ^{
            __block LocalPunch *finishedPunch;

            beforeEach(^{
                finishedPunch = nice_fake_for([LocalPunch class]);
                [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
            });

            it(@"should persist the punch", ^{
                punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
            });

            context(@"when the punch repository request succeeds", ^{
                beforeEach(^{
                    [persistPunchDeferred resolveWithValue:(id)[NSNull null]];
                });

                it(@"should resolve the serverDidFinishPunchDeferred", ^{
                    serverDidFinishPunchPromise.value should be_same_instance_as(finishedPunch);
                });
            });
        });
    });

    describe(@"-resumeWorkWithPunchProjectAssemblyWorkflowDelegate:clientType:projectType:taskType:oefTypesArray:", ^{
        __block KSDeferred *punchAssemblyWorkflowDeferred;
        __block KSPromise *serverDidFinishPunchPromise;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;
        __block NSArray *oefTypesArray;

        beforeEach(^{
            punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
            punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:))
            .and_do_block(^KSPromise *(LocalPunch *receivedPunch, KSPromise *receivedPromise, id<PunchAssemblyWorkflowDelegate>receivedDelegate){
                serverDidFinishPunchPromise = receivedPromise;
                return punchAssemblyWorkflowDeferred.promise;
            });

            client = nice_fake_for([ClientType class]);
            project = nice_fake_for([ProjectType class]);
            task = nice_fake_for([TaskType class]);
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];

            [subject resumeWorkWithPunchProjectAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate clientType:client projectType:project taskType:task oefTypesArray:oefTypesArray];
        });

        it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:));
            LocalPunch *incompletePunch = [[LocalPunch alloc]
                                                       initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                    actionType:PunchActionTypeTransfer
                                                                  lastSyncTime:NULL
                                                                     breakType:nil
                                                                      location:nil
                                                                       project:project
                                                                     requestID:@"guid-A"
                                                                      activity:nil
                                                                        client:client
                                                                      oefTypes:oefTypesArray
                                                                       address:nil
                                                                       userURI:@"user-uri"
                                                                         image:nil
                                                                          task:task
                                                                          date:expectedDate];

            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
        });

        context(@"when the punch assembly workflow finishes", ^{
            __block LocalPunch *finishedPunch;

            beforeEach(^{
                finishedPunch = nice_fake_for([LocalPunch class]);
                [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
            });

            it(@"should persist the punch", ^{
                punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
            });

            context(@"when the punch repository request succeeds", ^{
                beforeEach(^{
                    [persistPunchDeferred resolveWithValue:(id)[NSNull null]];
                });

                it(@"should resolve the serverDidFinishPunchDeferred", ^{
                    serverDidFinishPunchPromise.value should be_same_instance_as(finishedPunch);
                });
            });
        });

    });
    
    describe(@"-resumeWorkWithActivityAssemblyWorkflowDelegate:activity:oefTypesArray:", ^{
        __block KSDeferred *punchAssemblyWorkflowDeferred;
        __block KSPromise *serverDidFinishPunchPromise;
        __block Activity *activity;
        __block NSArray *oefTypesArray;
        
        beforeEach(^{
            punchAssemblyWorkflowDeferred = [[KSDeferred alloc] init];
            punchAssemblyWorkflow stub_method(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:))
            .and_do_block(^KSPromise *(LocalPunch *receivedPunch, KSPromise *receivedPromise, id<PunchAssemblyWorkflowDelegate>receivedDelegate){
                serverDidFinishPunchPromise = receivedPromise;
                return punchAssemblyWorkflowDeferred.promise;
            });
            
            activity = nice_fake_for([Activity class]);
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];
            
            [subject resumeWorkWithActivityAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate activity:activity oefTypesArray:oefTypesArray];
        });
        
        it(@"should ask the punch assembly workflow to assemble a new incomplete punch", ^{
            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:));
            LocalPunch *incompletePunch = [[LocalPunch alloc]
                                                       initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                    actionType:PunchActionTypeTransfer
                                                                  lastSyncTime:NULL
                                                                     breakType:nil
                                                                      location:nil
                                                                       project:nil
                                                                     requestID:@"guid-A"
                                                                      activity:activity
                                                                        client:nil
                                                                      oefTypes:oefTypesArray
                                                                       address:nil
                                                                       userURI:@"user-uri"
                                                                         image:nil
                                                                          task:nil
                                                                          date:expectedDate];
            
            punchAssemblyWorkflow should have_received(@selector(assembleIncompletePunch:serverDidFinishPunchPromise:delegate:)).with(incompletePunch, Arguments::anything, punchAssemblyWorkflowDelegate);
        });
        
        context(@"when the punch assembly workflow finishes", ^{
            __block LocalPunch *finishedPunch;
            
            beforeEach(^{
                finishedPunch = nice_fake_for([LocalPunch class]);
                [punchAssemblyWorkflowDeferred resolveWithValue:finishedPunch];
            });
            
            it(@"should persist the punch", ^{
                punchRepository should have_received(@selector(persistPunch:)).with(finishedPunch);
            });
            
            context(@"when the punch repository request succeeds", ^{
                beforeEach(^{
                    [persistPunchDeferred resolveWithValue:(id)[NSNull null]];
                });
                
                it(@"should resolve the serverDidFinishPunchDeferred", ^{
                    serverDidFinishPunchPromise.value should be_same_instance_as(finishedPunch);
                });
            });
        });
        
    });
});

SPEC_END
