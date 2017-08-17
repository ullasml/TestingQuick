#import <Foundation/Foundation.h>


@protocol ReachabilityMonitorObserver <NSObject>

- (void)networkReachabilityChanged;

@end


@interface ReachabilityMonitor : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (void)startMonitoring;

- (void)addObserver:(id<ReachabilityMonitorObserver>)observer;

- (BOOL)isNetworkReachable;

@end
