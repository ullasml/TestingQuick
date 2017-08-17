#import "TimesheetRequestProvider.h"
#import "RequestBuilder.h"
#import "URLStringProvider.h"


@interface TimesheetRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation TimesheetRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                            dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (NSURLRequest *)requestForTimesheetWithURI:(NSString *)timesheetUri
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetTimesheetSummaryData"];

    NSDictionary *requestBody = @{@"timesheetUri": timesheetUri};
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

- (NSURLRequest *)requestForFetchingTimesheetWidgetsForTimesheetUri:(NSString *)timesheetUri
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"TimesheetWidgets"];
    NSDictionary *parameterDictionary = @{@"URLString": urlString};
    NSMutableURLRequest *urlRequest = [RequestBuilder buildGETRequestWithParamDictToHandleCookies:parameterDictionary];
    [urlRequest setValue:timesheetUri forHTTPHeaderField:@"X-Timesheet-Uri"];
    return urlRequest;
}

- (NSURLRequest *)requestForFetchingTimesheetWidgetsForDate:(NSDate *)date
{
    NSString *formattedDateString = [self.dateFormatter stringFromDate:date];
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"TimesheetWidgets"];
    NSDictionary *parameterDictionary = @{@"URLString": urlString};
    NSMutableURLRequest *urlRequest = [RequestBuilder buildGETRequestWithParamDictToHandleCookies:parameterDictionary];
    [urlRequest setValue:formattedDateString forHTTPHeaderField:@"X-Param-AsOf-Date"];
    return urlRequest;
}
- (NSURLRequest *)requestForTimesheetPoliciesWithURI:(NSString *)timesheetUri
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"WidgetPolicies"];
    
    NSDictionary *parameterDictionary = @{@"URLString": urlString};
    
    NSMutableURLRequest *request = [RequestBuilder buildGETRequestWithParamDictToHandleCookies:parameterDictionary];
    [request setValue:timesheetUri forHTTPHeaderField:@"X-Timesheet-Uri"];
    
    return request;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
