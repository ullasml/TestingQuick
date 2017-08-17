#import <Foundation/Foundation.h>
#import <repliconkit/ReachabilityMonitor.h>


@class PunchRequestProvider;
@class ReachabilityMonitor;
@class PunchCreator;
@class LocalPunch;
@class KSPromise;
@protocol RequestPromiseClient;
@protocol PunchOutboxQueueCoordinatorDelegate;
@protocol Punch;



@interface PunchOutboxQueueCoordinator : NSObject

@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) PunchCreator *punchCreator;

@property (nonatomic, weak) id<PunchOutboxQueueCoordinatorDelegate> delegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithReachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                               punchCreator:(PunchCreator *)punchCreator;

- (KSPromise *)sendPunch:(LocalPunch *)punch;

@end


@protocol PunchOutboxQueueCoordinatorDelegate <NSObject>

- (void)punchOutboxQueueCoordinatorDidSyncPunches:(PunchOutboxQueueCoordinator *)punchOutboxQueueCoordinator;

- (void)punchOutboxQueueCoordinatorDidThrowInvalidPunchError:(PunchOutboxQueueCoordinator *)punchOutboxQueueCoordinator withPunch:(id<Punch>)punch;

@end
