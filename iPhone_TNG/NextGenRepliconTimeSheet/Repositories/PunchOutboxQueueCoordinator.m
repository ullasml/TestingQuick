#import "PunchOutboxQueueCoordinator.h"
#import <KSDeferred/KSDeferred.h>
#import "OfflineLocalPunch.h"
#import "PunchNotificationScheduler.h"
#import "PunchCreator.h"
#import "TimeLinePunchesStorage.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "RemotePunch.h"


@interface PunchOutboxQueueCoordinator ()

@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) PunchCreator *punchCreator;

@end


@implementation PunchOutboxQueueCoordinator

- (instancetype)initWithReachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                               punchCreator:(PunchCreator *)punchCreator
{
    self = [super init];
    if (self)
    {
        self.reachabilityMonitor = reachabilityMonitor;
        self.punchCreator = punchCreator;
    }
    return self;
}

- (KSPromise *)sendPunch:(LocalPunch *)punch
{
    if ([self.reachabilityMonitor isNetworkReachable])
    {
        
        return [self createPunch:punch];
    }
    else
    {
        OfflineLocalPunch *offlinePunch = [[OfflineLocalPunch alloc] initWithLocalPunch:punch];
        [self createPunch:offlinePunch];

        KSDeferred *offlinePunchDeferred = [[KSDeferred alloc] init];
        [offlinePunchDeferred resolveWithValue:nil];
        return offlinePunchDeferred.promise;
    }
}

#pragma mark - Private

- (KSPromise *)createPunch:(id<Punch>)punch
{
    KSPromise *mailmanPromise = [self.punchCreator creationPromiseForPunch:@[punch]];

    [mailmanPromise then:^id(id value) {
        [self.delegate punchOutboxQueueCoordinatorDidSyncPunches:self];
        return nil;
    } error:^id(NSError *error) {
        [self.delegate punchOutboxQueueCoordinatorDidSyncPunches:self];
        return nil;
    }];

    return mailmanPromise;
}

@end
