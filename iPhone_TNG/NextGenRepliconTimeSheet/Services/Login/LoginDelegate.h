#import <Foundation/Foundation.h>


@class LoginService;


@protocol LoginDelegate <NSObject>

- (void)loginServiceDidFinishLoggingIn:(LoginService *)loginService;

@end
