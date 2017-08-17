
#import <Foundation/Foundation.h>
#import "TaskRepositoryProtocol.h"
@class KSPromise;
@class ExpenseTaskStorage;
@class ExpenseTaskDeserializer;
@class ExpenseTaskRequestProvider;

@protocol RequestPromiseClient;
@protocol UserSession;


@interface ExpenseTaskRepository : NSObject <TaskRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) ExpenseTaskRequestProvider *requestProvider;
@property (nonatomic,readonly) ExpenseTaskStorage *taskStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) ExpenseTaskDeserializer *taskDeserializer;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithExpenseTaskDeserializer:(ExpenseTaskDeserializer *)taskDeserializer
                                requestProvider:(ExpenseTaskRequestProvider *)requestProvider
                                    userSession:(id <UserSession>)userSession
                                         client:(id<RequestPromiseClient>)client
                                        storage:(ExpenseTaskStorage *)storage NS_DESIGNATED_INITIALIZER;
-(void)setUpWithExpenseSheetUri:(NSString*)uri;
@end
