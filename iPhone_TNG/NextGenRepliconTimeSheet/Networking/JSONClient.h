#import <Foundation/Foundation.h>
#import "RequestPromiseClient.h"
#import "UserSession.h"


@class URLSessionClient;
@class KSPromise;


@interface JSONClient : NSObject <RequestPromiseClient,UserSession>

@property(nonatomic, readonly) id<RequestPromiseClient> client;
@property(nonatomic, readonly) NSOperationQueue *queue;
@property(nonatomic, readonly) id <UserSession> userSession;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLSessionClient:(id<RequestPromiseClient>)client
                             userSession:(id<UserSession>)userSession
                                   queue:(NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

@end
