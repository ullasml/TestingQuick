#import <Cedar/Cedar.h>
#import "TimesheetRequestProvider.h"
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetRequestProviderSpec)

describe(@"TimesheetRequestProvider", ^{
    __block TimesheetRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block NSDateFormatter *dateFormatter;
    
    beforeEach(^{
        urlStringProvider = fake_for([URLStringProvider class]);
        dateFormatter = nice_fake_for([NSDateFormatter class]);
        subject = [[TimesheetRequestProvider alloc] initWithURLStringProvider:urlStringProvider dateFormatter:dateFormatter];
    });
    
    describe(@"-fetchTimesheetWithURI:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"GetTimesheetSummaryData")
            .and_return(@"http://expected.endpoint/name");
            request = [subject requestForTimesheetWithURI:@"a-timesheet-uri"];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
            
            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];
            
            httpBody should equal(@{@"timesheetUri": @"a-timesheet-uri"});
        });
    });
    
    describe(@"-requestForFetchingTimesheetWidgetsForTimesheetUri:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"TimesheetWidgets")
            .and_return(@"http://expected.endpoint.widgets/name");
            request = [subject requestForFetchingTimesheetWidgetsForTimesheetUri:@"a-timesheet-uri"];
        });
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/name");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            request.HTTPBody should be_nil;
        });
    });
    
    describe(@"-requestForFetchingTimesheetWidgetsForDate:", ^{
        __block NSURLRequest *request;
        __block NSDate *date;
        beforeEach(^{
            date = [NSDate dateWithTimeIntervalSince1970:1];
            dateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"some-date-string");
            
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"TimesheetWidgets")
            .and_return(@"http://expected.endpoint.widgets/name");
            request = [subject requestForFetchingTimesheetWidgetsForDate:date];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.URL.absoluteString should equal(@"http://expected.endpoint.widgets/name");
            request.allHTTPHeaderFields[@"X-Param-AsOf-Date"] should equal(@"some-date-string");
            request.HTTPBody should be_nil;
        });
    });
    
    
    describe(@"-requestForTimesheetPoliciesWithURI:", ^{
        __block NSURLRequest *request;
        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"WidgetPolicies")
            .and_return(@"http://expected.endpoint/name");
            request = [subject requestForTimesheetPoliciesWithURI:@"a-timesheet-uri"];
        });
        
        
        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"GET");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
            request.allHTTPHeaderFields[@"X-Timesheet-Uri"] should equal(@"a-timesheet-uri");
            request.HTTPBody should be_nil;
        });
    });
});

SPEC_END
