#import <Cedar/Cedar.h>
#import "PunchRevitalizer.h"
#import "FailedPunchStorage.h"
#import "PunchCreator.h"
#import "LocalPunch.h"
#import "PunchNotificationScheduler.h"
#import "PunchOutboxStorage.h"
#import "RemotePunch.h"
#import "PunchRepository.h"
#import <KSDeferred/KSDeferred.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchRevitalizerSpec)

describe(@"PunchRevitalizer", ^{
    __block PunchRevitalizer *subject;
    __block FailedPunchStorage *failedPunchStorage;
    __block PunchCreator<CedarDouble> *punchCreator;
    __block PunchRepository<CedarDouble> *punchRepository;
    __block PunchNotificationScheduler *punchNotificationScheduler;
    __block PunchOutboxStorage *punchOutboxStorage;
    __block id<UserSession> userSession;

    beforeEach(^{
        userSession = fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"some:user:uri");

        failedPunchStorage = fake_for([FailedPunchStorage class]);
        punchOutboxStorage = fake_for([PunchOutboxStorage class]);
        punchCreator = fake_for([PunchCreator class]);
        punchRepository = fake_for([PunchRepository class]);
        punchNotificationScheduler = fake_for([PunchNotificationScheduler class]);

        subject = [[PunchRevitalizer alloc]
                                     initWithPunchNotificationScheduler:punchNotificationScheduler
                                                     punchOutboxStorage:punchOutboxStorage
                                                        punchRepository:punchRepository
                                                            userSession:userSession
                                                           punchCreator:punchCreator];
    });

    describe(@"-revitalizePunches", ^{
        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        __block RemotePunch *punchD;
        __block RemotePunch *punchE;

        beforeEach(^{
            punchA = fake_for([LocalPunch class]);
            punchB = fake_for([LocalPunch class]);
            punchC = fake_for([LocalPunch class]);
            punchD = fake_for([RemotePunch class]);
            punchE = fake_for([RemotePunch class]);
            
            punchD stub_method(@selector(userURI)).and_return(@"user:uri");
            punchE stub_method(@selector(userURI)).and_return(@"user:uri");

            punchOutboxStorage stub_method(@selector(unSubmittedAndPendingSyncPunches)).and_return(@[punchA, punchB, punchC, punchD, punchE]);

            punchCreator stub_method(@selector(creationPromiseForPunch:));
            punchRepository stub_method(@selector(updatePunch:));
            punchNotificationScheduler stub_method(@selector(cancelNotification));

            [subject revitalizePunches];
        });

        it(@"should cancel the failed punch notification", ^{
            punchNotificationScheduler should have_received(@selector(cancelNotification));
        });

        it(@"should fetch all unSubmitted And PendingSync Punches", ^{
            punchOutboxStorage should have_received(@selector(unSubmittedAndPendingSyncPunches));
        });

        it(@"should re-vitalize the failed punches", ^{
            [[punchCreator sent_messages] count] should equal(1);
            punchCreator should have_received(@selector(creationPromiseForPunch:)).with(@[punchA,punchB,punchC]);

            [[punchRepository sent_messages] count] should equal(1);
            punchRepository should have_received(@selector(updatePunch:)).with(@[punchD,punchE]);
        });
        
    });

    describe(@"when punches succeeded", ^{

        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        __block KSDeferred *deferred;
        beforeEach(^{

            deferred = [[KSDeferred alloc] init];

            punchA = fake_for([LocalPunch class]);
            punchB = fake_for([LocalPunch class]);
            punchC = fake_for([LocalPunch class]);

            punchOutboxStorage stub_method(@selector(unSubmittedAndPendingSyncPunches)).and_return(@[punchA, punchB, punchC]);

            punchCreator stub_method(@selector(creationPromiseForPunch:)).and_return(deferred.promise);;
            punchNotificationScheduler stub_method(@selector(cancelNotification));
            punchRepository stub_method(@selector(punchOutboxQueueCoordinatorDidSyncPunches:));

            [subject revitalizePunches];
           
            [deferred resolveWithValue:nil];
        });

        it(@"should fetch all unSubmitted And PendingSync Punches", ^{
            punchRepository should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(nil);
        });


    });

    describe(@"when punches failed due to business failure", ^{
        
        context(@"when PunchCreatorErrorDomain", ^{
            __block LocalPunch *punchA;
            __block LocalPunch *punchB;
            __block LocalPunch *punchC;
            __block KSDeferred *deferred;
            beforeEach(^{
                
                deferred = [[KSDeferred alloc] init];
                
                punchA = fake_for([LocalPunch class]);
                punchB = fake_for([LocalPunch class]);
                punchC = fake_for([LocalPunch class]);
                
                punchOutboxStorage stub_method(@selector(unSubmittedAndPendingSyncPunches)).and_return(@[punchA, punchB, punchC]);
                
                punchCreator stub_method(@selector(creationPromiseForPunch:)).and_return(deferred.promise);;
                punchNotificationScheduler stub_method(@selector(cancelNotification));
                punchRepository stub_method(@selector(punchOutboxQueueCoordinatorDidSyncPunches:));
                
                [subject revitalizePunches];
                NSError *error = [NSError errorWithDomain:@"PunchCreatorErrorDomain" code:0 userInfo:nil];
                [deferred rejectWithError:error];
            });
            
            it(@"should fetch all unSubmitted And PendingSync Punches", ^{
                punchRepository should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(nil);
            });
        });
        
        context(@"when some other error", ^{
            __block LocalPunch *punchA;
            __block LocalPunch *punchB;
            __block LocalPunch *punchC;
            __block KSDeferred *deferred;
            beforeEach(^{
                
                deferred = [[KSDeferred alloc] init];
                
                punchA = fake_for([LocalPunch class]);
                punchB = fake_for([LocalPunch class]);
                punchC = fake_for([LocalPunch class]);
                
                punchOutboxStorage stub_method(@selector(unSubmittedAndPendingSyncPunches)).and_return(@[punchA, punchB, punchC]);
                
                punchCreator stub_method(@selector(creationPromiseForPunch:)).and_return(deferred.promise);;
                punchNotificationScheduler stub_method(@selector(cancelNotification));
                punchRepository stub_method(@selector(punchOutboxQueueCoordinatorDidSyncPunches:));
                
                [subject revitalizePunches];
                NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:0 userInfo:nil];
                [deferred rejectWithError:error];
            });
            
            it(@"should fetch all unSubmitted And PendingSync Punches", ^{
                punchRepository should_not have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(nil);
            });
        });

    });

});

SPEC_END
