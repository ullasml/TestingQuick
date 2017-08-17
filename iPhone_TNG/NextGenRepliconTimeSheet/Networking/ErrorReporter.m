
#import "ErrorReporter.h"
#import "LoginService.h"

@interface ErrorReporter ()

@property (nonatomic) LoginService *loginService;

@end

@implementation ErrorReporter

- (instancetype)initWithLoginService:(LoginService *)loginService
{
    self = [super init];
    if (self) {
        self.loginService = loginService;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)reportToCustomerSupportWithError:(NSError *)error
{
    id errorUserInfoDict=[error userInfo];
    NSString *failedUrl=@"";

    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {
        failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
        if (!failedUrl)
        {
            if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
            {
                failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
            }

            if (!failedUrl)
            {
                failedUrl=@"";
            }

        }
    }

    [self.loginService sendrequestToLogtoCustomerSupportWithMsg:error.localizedDescription serviceURL:failedUrl];
}

- (void)checkForServerMaintenanaceWithError:(NSError *)error
{
    id errorUserInfoDict=[error userInfo];
    NSString *failedUrl=@"";

    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {
        failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
        if (!failedUrl)
        {
            if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
            {
                failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
            }

            if (!failedUrl)
            {
                failedUrl=@"";
            }

        }
    }
    [self.loginService sendRequestToCheckServerDownStatusWithServiceURL:failedUrl];
}

@end
