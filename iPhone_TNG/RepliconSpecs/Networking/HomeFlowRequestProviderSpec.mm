#import <Cedar/Cedar.h>
#import "URLStringProvider.h"
#import "HomeFlowRequestProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HomeFlowRequestProviderSpec)

describe(@"HomeFlowRequestProvider", ^{
    __block HomeFlowRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    
    beforeEach(^{
        urlStringProvider = fake_for([URLStringProvider class]);
        subject = [[HomeFlowRequestProvider alloc] initWithURLStringProvider:urlStringProvider];
    });
    
    describe(@"-homeFlowService:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"GetHomeSummary")
            .and_return(@"http://expected.endpoint/name");
            request = [subject requestForHomeFlowService];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
        });
    });
});

SPEC_END
