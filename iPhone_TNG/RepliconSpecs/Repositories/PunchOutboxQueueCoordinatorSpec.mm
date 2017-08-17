#import <Cedar/Cedar.h>
#import "PunchOutboxQueueCoordinator.h"
#import "LocalPunch.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchOutboxStorage.h"
#import "RequestPromiseClient.h"
#import "PunchRequestProvider.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "BreakType.h"
#import "PunchNotificationScheduler.h"
#import "PunchCreator.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "RemotePunch.h"
#import "TimeLinePunchesStorage.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchOutboxQueueCoordinatorSpec)


describe(@"PunchOutboxQueueCoordinator", ^{
    __block PunchOutboxQueueCoordinator *subject;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block PunchCreator<CedarDouble> *punchCreator;
    __block id<PunchOutboxQueueCoordinatorDelegate> delegate;

    beforeEach(^{
        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        punchCreator = nice_fake_for([PunchCreator class]);
        delegate = nice_fake_for(@protocol(PunchOutboxQueueCoordinatorDelegate));

        subject = [[PunchOutboxQueueCoordinator alloc] initWithReachabilityMonitor:reachabilityMonitor
                                                                      punchCreator:punchCreator];

        subject.delegate = delegate;
    });

    describe(@"sending a punch", ^{
        __block LocalPunch *punchToPersist;
        __block KSPromise *punchPromise;
        __block KSDeferred *punchCreatorDeferred;

        beforeEach(^{
            punchCreatorDeferred = [KSDeferred defer];
            punchCreator stub_method(@selector(creationPromiseForPunch:)).and_return(punchCreatorDeferred.promise);

            UIImage *image = [UIImage imageNamed:@"icon_comments_blue"];

            BreakType *breakType = [[BreakType alloc] initWithName:@"My Special Name" uri:@"My Special URI"];

            CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];

            ClientType *clientType = nice_fake_for([ClientType class]);

            ProjectType *projectType = nice_fake_for([ProjectType class]);

            TaskType *taskType = nice_fake_for([TaskType class]);

            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);


            punchToPersist= [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakType location:location project:projectType requestID:NULL activity:nil client:clientType oefTypes:@[oefType1, oefType2] address:@"My Special Address" userURI:@"My:Special:User" image:image task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
        });

        context(@"when the network is reachable", ^{
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                punchPromise = [subject sendPunch:punchToPersist];
            });

            it(@"should create the punch using the creator", ^{
                punchCreator should have_received(@selector(creationPromiseForPunch:)).with(@[punchToPersist]);
            });

            it(@"should return the creator's promise", ^{
                punchPromise should be_same_instance_as(punchCreatorDeferred.promise);
            });

            it(@"should inform its delegate when the punch is created", ^{
                [punchCreatorDeferred resolveWithValue:nil];

                delegate should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(subject);
            });

            it(@"should inform its delegate when the punch creation failed", ^{
                [punchCreatorDeferred rejectWithError:nil];

                delegate should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(subject);
            });
        });

        context(@"when the network is not reachable", ^{
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);

                punchPromise = [subject sendPunch:punchToPersist];
            });

            it(@"should create an offline copy of the punch using the creator", ^{
                __autoreleasing NSArray *storedPunchArray;
                NSInvocation *invocation = [punchCreator sent_messages][0];
                [invocation getArgument:&storedPunchArray atIndex:2];

                storedPunchArray.count should equal(1);

                id<Punch> storedPunch = storedPunchArray[0];
                storedPunch.date should equal(punchToPersist.date);
                storedPunch.actionType should equal(punchToPersist.actionType);
                storedPunch.address should equal(punchToPersist.address);
                storedPunch.image should equal(punchToPersist.image);
                storedPunch.location should equal(punchToPersist.location);
                storedPunch.userURI should equal(punchToPersist.userURI);
                storedPunch.client should equal(punchToPersist.client);
                storedPunch.project should equal(punchToPersist.project);
                storedPunch.task should equal(punchToPersist.task);
                storedPunch.oefTypesArray should equal(punchToPersist.oefTypesArray);
                storedPunch.offline should be_truthy;
            });

            it(@"should return an already-resolved promise", ^{
                punchPromise.fulfilled should be_truthy;
                punchPromise.value should be_nil;
            });

            it(@"should inform its delegate when the punch is created", ^{
                [punchCreatorDeferred resolveWithValue:nil];

                delegate should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(subject);
            });

            it(@"should inform its delegate when the punch creation failed", ^{
                [punchCreatorDeferred rejectWithError:nil];

                delegate should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(subject);
            });
        });

        context(@"when the punch is inavlid", ^{
            beforeEach(^{

                NSError *error = nice_fake_for([NSError class]);

                punchPromise = [subject sendPunch:punchToPersist];
                [punchCreatorDeferred rejectWithError:error];
            });

            it(@"should inform its delegate when the punch is created", ^{
                delegate should have_received(@selector(punchOutboxQueueCoordinatorDidSyncPunches:)).with(subject);
            });
        });
    });

    
});


SPEC_END
