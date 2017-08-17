#import <Cedar/Cedar.h>
#import "ForgotPasswordRequestProvider.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ForgotPasswordRequestProviderSpec)

describe(@"ForgotPasswordRequestProvider", ^{
    __block ForgotPasswordRequestProvider *subject;
    __block NSUserDefaults *userdefaults;
    beforeEach(^{
        userdefaults = nice_fake_for([NSUserDefaults class]);
        subject = [[ForgotPasswordRequestProvider alloc]initWithDefaults:userdefaults];
    });
    
    
    describe(@"-provideRequestWithCompanyName", ^{
        __block NSURLRequest *urlRequest;

        context(@"When url request is made against a production server", ^{
            beforeEach(^{
                userdefaults stub_method(@selector(objectForKey:)).with(@"urlPrefixesStr").and_return(nil);
                urlRequest = [subject provideRequestWithCompanyName:@"company" andemail:@"email"];
            });
            
            it(@"should correctly return the URL request", ^{
                urlRequest.URL.absoluteString should equal(@"https://global.replicon.com/SecurityService1.svc/CreatePasswordResetRequest");
                NSDictionary *headerFields = urlRequest.allHTTPHeaderFields;
                NSString *headerValue = headerFields[RequestMadeWhileInvalidUserSessionHeaderKey];
                headerValue should equal(RequestMadeWhileInvalidUserSessionHeaderValue);
            });
        });
        
        
        
    });
    
    describe(@"-provideRequestWithPasswordResetRequestUri", ^{
        __block NSURLRequest *urlRequest;
        context(@"When url request is made against a production server", ^{
            beforeEach(^{
                userdefaults stub_method(@selector(objectForKey:)).with(@"urlPrefixesStr").and_return(nil);
                urlRequest = [subject provideRequestWithCompanyName:@"company" andemail:@"email"];
            });
            
            it(@"should correctly return the URL request", ^{
                urlRequest.URL.absoluteString should equal(@"https://global.replicon.com/SecurityService1.svc/CreatePasswordResetRequest");
                NSDictionary *headerFields = urlRequest.allHTTPHeaderFields;
                NSString *headerValue = headerFields[RequestMadeWhileInvalidUserSessionHeaderKey];
                headerValue should equal(RequestMadeWhileInvalidUserSessionHeaderValue);
            });
        });

    });
});

SPEC_END
