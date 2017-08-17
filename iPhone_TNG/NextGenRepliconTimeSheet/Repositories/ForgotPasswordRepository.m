
#import "ForgotPasswordRepository.h"
#import "RequestPromiseClient.h"
#include "ForgotPasswordRequestProvider.h"

@interface ForgotPasswordRepository ()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) ForgotPasswordRequestProvider *requestProvider;

@end

@implementation ForgotPasswordRepository

- (instancetype)initWithClient:(id<RequestPromiseClient>)client
               requestProvider:(ForgotPasswordRequestProvider *)requestProvider
{
    self = [super init];
    if (self) {
        self.client = client;
        self.requestProvider = requestProvider;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (KSPromise *)passwordResetRequestWithCompanyName:(NSString *)company email:(NSString *)email
{
    NSURLRequest *request = [self.requestProvider provideRequestWithCompanyName:company andemail:email];
    return [self.client promiseWithRequest:request];
    
}

- (KSPromise *)sendRequestToResetPasswordToEmail:(NSString *)requestUri
{
    NSURLRequest *request = [self.requestProvider provideRequestWithPasswordResetRequestUri:requestUri];
    return [self.client promiseWithRequest:request];
}


@end
