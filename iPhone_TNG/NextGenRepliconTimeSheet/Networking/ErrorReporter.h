
#import <Foundation/Foundation.h>

@class LoginService;

@interface ErrorReporter : NSObject

@property (nonatomic,readonly) LoginService *loginService;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLoginService:(LoginService *)loginService NS_DESIGNATED_INITIALIZER;

-(void)reportToCustomerSupportWithError:(NSError *)error;

- (void)checkForServerMaintenanaceWithError:(NSError *)error;

@end
