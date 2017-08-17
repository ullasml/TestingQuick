
#import <Foundation/Foundation.h>

@class ForgotPasswordRequestProvider;
@class KSPromise;
@protocol RequestPromiseClient;

@interface ForgotPasswordRepository : NSObject

@property (nonatomic, readonly) id <RequestPromiseClient> client;
@property (nonatomic, readonly) ForgotPasswordRequestProvider *requestProvider;

- (instancetype)initWithClient:(id<RequestPromiseClient>)client
               requestProvider:(ForgotPasswordRequestProvider *)requestProvider NS_DESIGNATED_INITIALIZER;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (KSPromise *)passwordResetRequestWithCompanyName:(NSString *)company email:(NSString *)email;

- (KSPromise *)sendRequestToResetPasswordToEmail:(NSString *)requestUri;



@end
