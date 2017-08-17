#import <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "ReachabilityMonitor.h"


@interface ReachabilityMonitor ()

@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic) NSHashTable *observers;

- (void)notifyObservers;

@end


static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    ReachabilityMonitor *reachabilityMonitor = (__bridge ReachabilityMonitor *)info;
    [reachabilityMonitor notifyObservers];
}


@implementation ReachabilityMonitor

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;

        self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
        self.observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
    CFRelease(self.reachabilityRef);
}

- (void)startMonitoring
{
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context))
    {
        SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)stopMonitoring
{
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}

- (void)addObserver:(id<ReachabilityMonitorObserver>)observer
{
    [self.observers addObject:observer];
}

- (void)notifyObservers
{
    for (id<ReachabilityMonitorObserver> observer in self.observers)
    {
        [observer networkReachabilityChanged];
    }
}

- (BOOL)isNetworkReachable
{
    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        BOOL reachable = (flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable;
        BOOL connectionRequired = (flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired;

        return reachable && !connectionRequired;
    }

    return NO;
}

@end
