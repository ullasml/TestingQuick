#import <Cedar/Cedar.h>
#import "PunchLogRequestProvider.h"
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchLogRequestProviderSpec)

describe(@"PunchLogRequestProvider", ^{
    __block PunchLogRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;

    beforeEach(^{
        urlStringProvider = fake_for([URLStringProvider class]);
        subject = [[PunchLogRequestProvider alloc] initWithURLStringProvider:urlStringProvider];
    });

    describe(@"-requestWithPunchURI:", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"MobileGetTimePunchAuditRecordDetails")
                .and_return(@"http://expected.endpoint/name");

            request = [subject requestWithPunchURI:@"my-special-uri"];
        });

        it(@"should create a POST request", ^{
            request.HTTPMethod should equal(@"POST");
        });

        it(@"should create a request with the correct URL", ^{
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
        });

        it(@"should create a request with the correct HTTP body", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
            NSDictionary *expectedRequestBodyDictionary = @{@"timePunchUris": @[@"my-special-uri"]};

            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });
    });
});

SPEC_END
