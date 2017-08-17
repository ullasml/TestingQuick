#import <Cedar/Cedar.h>
#import <repliconkit/ReachabilityMonitor.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface ReachabilityMonitor ()

- (void)notifyObservers;

@end


SPEC_BEGIN(ReachabilityMonitorSpec)

describe(@"ReachabilityMonitor", ^{
    __block ReachabilityMonitor *subject;

    beforeEach(^{
        subject = [[ReachabilityMonitor alloc] init];
    });

    it(@"should inform its observers when network reachability changes", ^{
        id<ReachabilityMonitorObserver> observer1 = nice_fake_for(@protocol(ReachabilityMonitorObserver));
        id<ReachabilityMonitorObserver> observer2 = nice_fake_for(@protocol(ReachabilityMonitorObserver));

        [subject addObserver:observer1];
        [subject addObserver:observer2];

        [subject notifyObservers];

        observer1 should have_received(@selector(networkReachabilityChanged));
        observer2 should have_received(@selector(networkReachabilityChanged));
    });
});

SPEC_END
