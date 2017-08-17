#import <Cedar/Cedar.h>
#import "MobileAppConfigRequestProvider.h"
#import "LoginCredentialsHelper.h"
#import "MobileMonitorURLProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MobileAppConfigRequestProviderSpec)

describe(@"MobileAppConfigRequestProvider", ^{
    __block MobileAppConfigRequestProvider *subject;
    __block LoginCredentialsHelper *loginCredentialsHelper;
    __block MobileMonitorURLProvider *mobileMonitorURLProvider;
    __block NSBundle *bundle;
    beforeEach(^{
        mobileMonitorURLProvider = nice_fake_for([MobileMonitorURLProvider class]);
        loginCredentialsHelper = nice_fake_for([LoginCredentialsHelper class]);
        bundle = nice_fake_for([NSBundle class]);
        subject = [[MobileAppConfigRequestProvider alloc] initWithMobileMonitorURLProvider:mobileMonitorURLProvider
                                                                    loginCredentialsHelper:loginCredentialsHelper
                                                                                    bundle:bundle];
    });
    
    describe(@"When no Company key", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            mobileMonitorURLProvider stub_method(@selector(baseUrlForMobileMonitor)).and_return(@"http://example.com");
            loginCredentialsHelper stub_method(@selector(getLoginCredentials)).and_return(nil);
            bundle stub_method(@selector(infoDictionary)).and_return(@{@"CFBundleVersion":@"123"});
            request = [subject getRequest];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.HTTPShouldHandleCookies should be_falsy;
            request.URL.absoluteString should equal(@"http://example.com/app-config");
            NSDictionary *headerFields = request.allHTTPHeaderFields;
            headerFields[@"X-Replicon-Application"] should equal(@"ios-mobile; v=123");
            headerFields.count should equal(2);
        });
    });
    
    describe(@"When Company key is available", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            mobileMonitorURLProvider stub_method(@selector(baseUrlForMobileMonitor)).and_return(@"http://example.com");
            loginCredentialsHelper stub_method(@selector(getLoginCredentials)).and_return(@{@"companyName":@"testcompany"});
            bundle stub_method(@selector(infoDictionary)).and_return(@{@"CFBundleVersion":@"123"});
            request = [subject getRequest];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.HTTPShouldHandleCookies should be_falsy;
            request.URL.absoluteString should equal(@"http://example.com/app-config?companyKey=testcompany");
            NSDictionary *headerFields = request.allHTTPHeaderFields;
            headerFields[@"X-Replicon-Application"] should equal(@"ios-mobile; v=123");
            headerFields.count should equal(2);
        });
    });
    
});

SPEC_END
