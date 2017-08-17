#import <Cedar/Cedar.h>
#import "UpdateWaiverRequestProvider.h"
#import "WaiverOption.h"
#import "Waiver.h"
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(UpdateWaiverRequestProviderSpec)

describe(@"UpdateWaiverRequestProvider", ^{
    __block UpdateWaiverRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;

    beforeEach(^{
        urlStringProvider = nice_fake_for([URLStringProvider class]);

        subject = [[UpdateWaiverRequestProvider alloc] initWithURLStringProvider:urlStringProvider];
    });

    describe(@"provideRequestWithWaiver:waiverOption:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:)).and_return(@"http://expected.endpoint/name");

            WaiverOption *waiverOption = [[WaiverOption alloc] initWithDisplayText:@"asdf" value:@"yay"];
            Waiver *waiver = [[Waiver alloc] initWithURI:@"my special uri"
                                             displayText:@"ds"
                                                 options:@[waiverOption]
                                          selectedOption:nil];

            request = [subject provideRequestWithWaiver:waiver waiverOption:waiverOption];
        });

        it(@"should get the url from the provider", ^{
            urlStringProvider should have_received(@selector(urlStringWithEndpointName:)).with(@"AcknowledgeValidationWaiver");
        });

        it(@"should create a POST request", ^{
            request.HTTPMethod should equal(@"POST");
        });

        it(@"should create a request with the correct URL", ^{
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
        });

        it(@"should create a request with the correct HTTP body", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];

            NSDictionary *expectedRequestBodyDictionary = @{
                @"validationWaiverUri": @"my special uri",
                @"validationWaiverOptionValue": @"yay"
                };

            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });
    });
});

SPEC_END
