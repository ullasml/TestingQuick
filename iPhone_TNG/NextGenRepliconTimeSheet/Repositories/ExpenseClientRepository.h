
#import <Foundation/Foundation.h>
#import "ClientRepositoryProtocol.h"
#import "ClientRepositoryProtocol.h"
@class KSPromise;
@class ExpenseClientStorage;
@class ClientDeserializer;
@class ExpenseClientRequestProvider;

@protocol RequestPromiseClient;
@protocol UserSession;


@interface ExpenseClientRepository : NSObject <ClientRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) ExpenseClientRequestProvider *requestProvider;
@property (nonatomic,readonly) ExpenseClientStorage *clientStorage;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic,readonly) ClientDeserializer *clientDeserializer;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithExpenseClientDeserializer:(ClientDeserializer *)clientDeserializer
                                  requestProvider:(ExpenseClientRequestProvider *)requestProvider
                                      userSession:(id <UserSession>)userSession
                                           client:(id<RequestPromiseClient>)client
                                          storage:(ExpenseClientStorage *)storage NS_DESIGNATED_INITIALIZER;
-(void)setUpWithExpenseSheetUri:(NSString*)uri;

@end
