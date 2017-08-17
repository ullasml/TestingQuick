
#import <Foundation/Foundation.h>

@class KSPromise;
@class PersistedSettingsStorage;
@class ReachabilityMonitor;
@class NetworkClient;
@class RequestProvider;

@interface AppConfigRepository : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithPersistedSettingsStorage:(PersistedSettingsStorage *)persistedSettingsStorage
                         reachabilityMonitor:(ReachabilityMonitor *) reachabilityMonitor
                               networkClient:(NetworkClient *)networkClient NS_DESIGNATED_INITIALIZER;

-(KSPromise *)appConfigForRequest:(NSMutableURLRequest *)request;

@end
