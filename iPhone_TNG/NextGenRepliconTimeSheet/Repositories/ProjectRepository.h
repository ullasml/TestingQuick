
#import <Foundation/Foundation.h>
#import "ProjectRepositoryProtocol.h"
@class KSPromise;
@class ProjectStorage;
@class ProjectDeserializer;
@class ProjectRequestProvider;

@protocol RequestPromiseClient;
@protocol UserSession;

@interface ProjectRepository : NSObject <ProjectRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) ProjectRequestProvider *requestProvider;
@property (nonatomic,readonly) ProjectStorage *projectStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) ProjectDeserializer *projectDeserializer;
@property (nonatomic,readonly) NSString *userUri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithProjectDeserializer:(ProjectDeserializer *)clientDeserializer
                           requestProvider:(ProjectRequestProvider *)requestProvider
                               userSession:(id <UserSession>)userSession
                                    client:(id<RequestPromiseClient>)client
                                   storage:(ProjectStorage *)storage NS_DESIGNATED_INITIALIZER;

-(void)setUpWithUserUri:(NSString *)userUri;

@end
