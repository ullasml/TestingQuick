
#import <Foundation/Foundation.h>
#import "ProjectRepositoryProtocol.h"
@class KSPromise;
@class ExpenseProjectStorage;
@class ExpenseProjectDeserializer;
@class ExpenseProjectRequestProvider;

@protocol RequestPromiseClient;
@protocol UserSession;
@class UserPermissionsStorage;

@interface ExpenseProjectRepository : NSObject <ProjectRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) ExpenseProjectRequestProvider *requestProvider;
@property (nonatomic,readonly) ExpenseProjectStorage *projectStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) ExpenseProjectDeserializer *projectDeserializer;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithExpenseProjectDeserializer:(ExpenseProjectDeserializer *)clientDeserializer
                                   requestProvider:(ExpenseProjectRequestProvider *)requestProvider
                                       userSession:(id <UserSession>)userSession
                                            client:(id<RequestPromiseClient>)client
                                           storage:(ExpenseProjectStorage *)storage
                            userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage NS_DESIGNATED_INITIALIZER;
-(void)setUpWithExpenseSheetUri:(NSString*)uri;

@end
