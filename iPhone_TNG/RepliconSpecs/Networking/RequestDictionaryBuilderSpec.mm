#import <Cedar/Cedar.h>
#import "RequestDictionaryBuilder.h"
#import "AppProperties.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RequestDictionaryBuilderSpec)

describe(@"RequestDictionaryBuilder", ^{
    __block RequestDictionaryBuilder *subject;
    __block AppProperties *appProperties;
    __block NSUserDefaults *userDefaults;

    beforeEach(^{
        appProperties = nice_fake_for([AppProperties class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);

        subject = [[RequestDictionaryBuilder alloc] initWithAppProperties:appProperties userDefaults:userDefaults];
    });

    describe(NSStringFromSelector(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)), ^{
        beforeEach(^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"serviceEndpointRootUrl").and_return(@"https://example.com/foo/bar/");

            appProperties stub_method(@selector(getServiceURLFor:)).with(@"some-fake-service").and_return(@"/some/fake/service");
        });

        describe(@"getting a request dictionary for a given endpoint name and dictionary of JSON to be sent", ^{
            it(@"should return the correct URL using the endpoint path and the service endpoint", ^{
                NSDictionary *httpBodyDictionary = @{@"some" : @"values", @"should" : @{@"be" : @"sent"}};
                NSString *expectedPayloadString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:httpBodyDictionary options:0 error:nil] encoding:NSUTF8StringEncoding];

                NSDictionary *requestDictionary = [subject requestDictionaryWithEndpointName:@"some-fake-service" httpBodyDictionary:httpBodyDictionary];

                requestDictionary should equal(@{
                        @"URLString" : @"https://example.com/foo/bar/some/fake/service",
                        @"PayLoadStr" : expectedPayloadString
                });
            });
        });
    });
});

SPEC_END
