
#import <Foundation/Foundation.h>
#import "ClientRepositoryProtocol.h"
@class KSPromise;
@class ClientStorage;
@class ClientDeserializer;
@class ClientRequestProvider;

@protocol RequestPromiseClient;
@protocol UserSession;

@interface ClientRepository : NSObject <ClientRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) ClientRequestProvider *requestProvider;
@property (nonatomic,readonly) ClientStorage *clientStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) ClientDeserializer *clientDeserializer;
@property (nonatomic,readonly) NSString *userUri;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithClientDeserializer:(ClientDeserializer *)clientDeserializer
                           requestProvider:(ClientRequestProvider *)requestProvider
                               userSession:(id <UserSession>)userSession
                                    client:(id<RequestPromiseClient>)client
                                   storage:(ClientStorage *)storage NS_DESIGNATED_INITIALIZER;

-(void)setUpWithUserUri:(NSString *)userUri;

@end
