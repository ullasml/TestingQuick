#import <Cedar/Cedar.h>
#import "OEFTypesRequestProvider.h"
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(OEFTypesRequestProviderSpec)

describe(@"OEFTypesRequestProvider", ^{
    __block OEFTypesRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    
    beforeEach(^{
        urlStringProvider = fake_for([URLStringProvider class]);
        subject = [[OEFTypesRequestProvider alloc] initWithURLStringProvider:urlStringProvider];
    });
    
    describe(@"-requestForOEFTypesForUserUri:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"BulkGetObjectExtensionFieldBindingsForUsers")
            .and_return(@"http://expected.endpoint/name");
            request = [subject requestForOEFTypesForUserUri:@"my-special-user-uri"];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];
            
            httpBody should equal(@{@"userUris": @[@"my-special-user-uri"]});
        });
    });
});

SPEC_END
