
#import <Foundation/Foundation.h>
#import "TaskRepositoryProtocol.h"
@class KSPromise;
@class TaskStorage;
@class TaskDeserializer;
@class TaskRequestProvider;

@protocol RequestPromiseClient;
@protocol UserSession;

@interface TaskRepository : NSObject<TaskRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) TaskRequestProvider *requestProvider;
@property (nonatomic,readonly) TaskStorage *taskStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) TaskDeserializer *taskDeserializer;
@property (nonatomic,readonly) NSString *userUri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTaskDeserializer:(TaskDeserializer *)taskDeserializer
                         requestProvider:(TaskRequestProvider *)requestProvider
                             userSession:(id <UserSession>)userSession
                                  client:(id<RequestPromiseClient>)client
                                 storage:(TaskStorage *)storage NS_DESIGNATED_INITIALIZER;

-(void)setUpWithUserUri:(NSString *)userUri;

@end
