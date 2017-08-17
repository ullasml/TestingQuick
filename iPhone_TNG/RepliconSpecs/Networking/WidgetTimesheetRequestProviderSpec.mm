#import <Cedar/Cedar.h>
#import "NextGenRepliconTimeSheet-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetRequestProviderSpec)

describe(@"WidgetTimesheetRequestProvider", ^{
    __block WidgetTimesheetRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;

    beforeEach(^{
        urlStringProvider = fake_for([URLStringProvider class]);
        subject = [[WidgetTimesheetRequestProvider alloc] initWithUrlStringProvider:urlStringProvider 
                                                                       userDefaults:(id)[NSNull null] 
                                                                       guidProvider:(id)[NSNull null]];
    });
    
    describe(@"-requestForFetchingTimesheetWidgetsForTimesheetUri:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"WidgetTimesheetSummary")
            .and_return(@"http://expected.endpoint.widgets/name");
            request = [subject requestForTimesheetSummary:@"a-timesheet-uri"];
        });
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/name");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            request.HTTPBody should be_nil;
        });
    });
    
    describe(@"-requestForPunchWidgetSummary:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"PunchWidget")
            .and_return(@"http://expected.endpoint.widgets/name");
            request = [subject requestForPunchWidgetSummary:@"a-timesheet-uri"];
        });
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/name");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            request.HTTPBody should be_nil;
        });
    });
});

SPEC_END
