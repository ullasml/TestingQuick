#import <Foundation/Foundation.h>
#import "JSONClient.h"
#import "BreakTypeDeserializer.h"

@class BreakTypeStorage;
@class ReachabilityMonitor;

@interface BreakTypeRepository : NSObject

@property (nonatomic,readonly) JSONClient *jsonClient;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) BreakTypeDeserializer *breakTypeDeserializer;
@property (nonatomic,readonly) BreakTypeStorage *breakTypeStorage;
@property (nonatomic,readonly) ReachabilityMonitor *reachabilityMonitor;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithJSONClientBreakTypeDeserializer:(BreakTypeDeserializer *)breakTypeDeserializer
                                       breakTypeStorage:(BreakTypeStorage *)breakTypeStorage
                                    reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                           userDefaults:(NSUserDefaults *)userDefaults
                                             jsonClient:(JSONClient *)jsonClient NS_DESIGNATED_INITIALIZER;

- (KSPromise *) fetchBreakTypesForUser:(NSString *)userUri;

@end
