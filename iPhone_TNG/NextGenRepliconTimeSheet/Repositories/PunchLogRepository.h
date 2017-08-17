#import <Foundation/Foundation.h>


@class KSPromise;
@class PunchLogDeserializer;
@class PunchLogRequestProvider;
@protocol Punch;
@protocol RequestPromiseClient;


@interface PunchLogRepository : NSObject

@property (nonatomic, readonly) PunchLogRequestProvider *requestProvider;
@property (nonatomic, readonly) PunchLogDeserializer *deserializer;
@property (nonatomic, readonly) id<RequestPromiseClient> client;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchLogRequestProvider:(PunchLogRequestProvider *)requestProvider
                           punchLogDeserializer:(PunchLogDeserializer *)deserializer
                           requestPromiseClient:(id<RequestPromiseClient>)client;

- (KSPromise *)fetchPunchLogsForPunchURI:(NSString *)punchURI;

@end
