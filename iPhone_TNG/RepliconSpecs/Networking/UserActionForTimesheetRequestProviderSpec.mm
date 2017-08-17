#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UserActionForTimesheetRequestProviderSpec)

describe(@"UserActionForTimesheetRequestProvider", ^{
    __block UserActionForTimesheetRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block NSURLRequest *request;
    
    beforeEach(^{
        urlStringProvider = nice_fake_for([URLStringProvider class]);
        subject = [[UserActionForTimesheetRequestProvider alloc]initWithUrlStringProvider:urlStringProvider];
    });


    describe(@"when the action is RightBarButtonActionTypeSubmit", ^{
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"WidgetTimesheetSubmit")
            .and_return(@"http://expected.endpoint.widgets/submit");
            request = [subject requestForUserTimesheetAction:RightBarButtonActionTypeSubmit timesheetUri:@"a-timesheet-uri" comments:nil];
        });
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/submit");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];
            httpBody should equal(@{});
        });
    });
    
    describe(@"when the action is RightBarButtonActionTypeReOpen", ^{
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"WidgetTimesheetReopen")
            .and_return(@"http://expected.endpoint.widgets/reopen");
            request = [subject requestForUserTimesheetAction:RightBarButtonActionTypeReOpen timesheetUri:@"a-timesheet-uri" comments:@"comments"];
        });
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/reopen");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];
            
            httpBody should equal(@{@"comments": @"comments"});
        });
    });
    
    describe(@"when the action is RightBarButtonActionTypeReSubmit", ^{
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"WidgetTimesheetSubmit")
            .and_return(@"http://expected.endpoint.widgets/resubmit");
            request = [subject requestForUserTimesheetAction:RightBarButtonActionTypeReSubmit timesheetUri:@"a-timesheet-uri" comments:@"comments"];
        });
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/resubmit");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];  
            httpBody should equal(@{@"comments": @"comments"});

        });
    });
});

SPEC_END
