#import <Cedar/Cedar.h>
#import "MobileMonitorURLProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MobileMonitorURLProviderSpec)

describe(@"MobileMonitorURLProvider", ^{
    __block MobileMonitorURLProvider *subject;
    __block NSUserDefaults *userDefaults;
    
    beforeEach(^{
        userDefaults = [[NSUserDefaults alloc]init];
        spy_on(userDefaults);
        
        subject = [[MobileMonitorURLProvider alloc] initWithUserDefaults:userDefaults];
    });
    
    describe(@"baseUrlForMobileMonitor", ^{
        __block NSString *expectedBaseUrl = nil;
        context(@"when serviceEndpointRootUrl is sb1", ^{
            beforeEach(^{
                expectedBaseUrl =  @"https://mm-sb1.replicon.com";
                userDefaults stub_method(@selector(objectForKey:))
                .with(@"serviceEndpointRootUrl").and_return(@"https://sb1.replicon.com/services/");
            });

            it(@"should return expected url", ^{
                [subject baseUrlForMobileMonitor] should equal(expectedBaseUrl);
            });
        });
        
        context(@"when serviceEndpointRootUrl is qa", ^{
            beforeEach(^{
                expectedBaseUrl =  @"https://mm-qa.replicon.com";
                userDefaults stub_method(@selector(objectForKey:))
                .with(@"serviceEndpointRootUrl").and_return(@"https://qa.replicon.com/services/");
            });
            
            it(@"should return expected url", ^{
                [subject baseUrlForMobileMonitor] should equal(expectedBaseUrl);
            });
        });

        context(@"when serviceEndpointRootUrl is dev", ^{
            beforeEach(^{
                expectedBaseUrl =  @"https://mm-dev.replicon.com";
                userDefaults stub_method(@selector(objectForKey:))
                .with(@"serviceEndpointRootUrl").and_return(@"https://123456.replicon.com/services/");
            });
            
            it(@"should return expected url", ^{
                [subject baseUrlForMobileMonitor] should equal(expectedBaseUrl);
            });
        });
        
        context(@"when serviceEndpointRootUrl is dev", ^{
            beforeEach(^{
                expectedBaseUrl =  @"https://mm-dev.replicon.com";
                userDefaults stub_method(@selector(objectForKey:))
                .with(@"serviceEndpointRootUrl").and_return(nil);
            });
            
            it(@"should return expected url", ^{
                [subject baseUrlForMobileMonitor] should equal(expectedBaseUrl);
            });
        });
    });
});

SPEC_END
