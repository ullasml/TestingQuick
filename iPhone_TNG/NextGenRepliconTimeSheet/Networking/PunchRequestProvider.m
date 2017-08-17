#import "BreakType.h"
#import <CoreLocation/CoreLocation.h>
#import "GUIDProvider.h"
#import "AppProperties.h"
#import "RequestBuilder.h"
#import "PunchRequestProvider.h"
#import "URLStringProvider.h"
#import "Punch.h"
#import "PunchRequestBodyProvider.h"
#import "RemotePunch.h"
#import "DateProvider.h"


@interface PunchRequestProvider ()

@property (nonatomic) PunchRequestBodyProvider *punchRequestBodyProvider;
@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@end


@implementation PunchRequestProvider

- (instancetype)initWithPunchRequestBodyProvider:(PunchRequestBodyProvider *)punchRequestBodyProvider
                               urlStringProvider:(URLStringProvider *)urlStringProvider
                                    dateProvider:(DateProvider *)dateProvider
                                   dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self)
    {
        self.punchRequestBodyProvider = punchRequestBodyProvider;
        self.urlStringProvider = urlStringProvider;
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (NSURLRequest *)mostRecentPunchRequestForUserUri:(NSString *)userUri
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"LastPunchData"];

    NSDictionary *requestBody = [self.punchRequestBodyProvider requestBodyForMostRecentPunchForUserUri:userUri];

    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

- (NSURLRequest *)punchRequestWithPunch:(NSArray *)punchesArray
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:BulkPunchWithCreatedAtTime3];

    NSDictionary *requestBodyDictionary = [self.punchRequestBodyProvider requestBodyForPunch:punchesArray];

    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSDictionary *parameterDictionary = @{
        @"URLString": urlString,
        @"PayLoadStr":  requestBodyString
    };

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    NSString *uuidString = nil;
    for (id<Punch>punch in punchesArray)
    {
        if (!uuidString)
        {
            uuidString = punch.requestID;
        }
        else
        {
            uuidString = [NSString stringWithFormat:@"%@|%@",uuidString,punch.requestID];
        }

    }

    [request setValue:uuidString forHTTPHeaderField:PunchRequestIdentifierHeader];

    return request;
}

- (NSURLRequest *)requestForPunchesWithDate:(NSDate *)date userURI:(NSString *)userURI
{
    NSDictionary *requestBodyDictionary = [self.punchRequestBodyProvider requestBodyForPunchesWithDate:date userURI:userURI];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetTimePunchDetailsForUserAndDateRange"];

    NSDictionary *parameterDictionary = @{
        @"URLString": urlString,
        @"PayLoadStr":  requestBodyString
    };

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

- (NSURLRequest *)requestForPunchesWithLastTwoMostRecentPunchWithDate:(NSDate *)date
{
    NSDictionary *requestBodyDictionary = [self.punchRequestBodyProvider requestBodyForPunchesWithLastTwoMostRecentPunchWithDate:date];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"TimelinePunches"];

    NSDictionary *parameterDictionary = @{
                                          @"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString
                                          };

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
    NSString *serverTimestamp = [self.dateFormatter stringFromDate:self.dateProvider.date];
    [request setValue:serverTimestamp forHTTPHeaderField:MostRecentPunchDateIdentifierHeader];
    
    return request;
}

- (NSURLRequest *)deletePunchRequestWithPunchUri:(NSString *)punchUri
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"DeletePunch"];

    NSDictionary *requestBodyDictionary = [self.punchRequestBodyProvider requestBodyToDeletePunchWithURI:punchUri];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

- (NSURLRequest *)requestToUpdatePunch:(NSArray *)remotePunchesArray
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"PutTimePunch2"];

    NSDictionary *requestBodyDictionary = [self.punchRequestBodyProvider requestBodyToUpdatePunch:remotePunchesArray];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    NSString *uuidString = nil;
    for (id<Punch>punch in remotePunchesArray)
    {
        if (!uuidString)
        {
            uuidString = punch.requestID;
        }
        else
        {
            uuidString = [NSString stringWithFormat:@"%@|%@",uuidString,punch.requestID];
        }

    }

    [request setValue:uuidString forHTTPHeaderField:PunchRequestIdentifierHeader];

    return request;
}


- (NSURLRequest *)requestToRecalculateScriptDataForuser:(NSString *)userURI withDateDict:(NSDictionary *)dateDict
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"RecalculateScriptData"];

    NSDictionary *requestBodyDictionary = [self.punchRequestBodyProvider requestBodyToRecalculateScriptDataForUserURI:userURI withDateDict:dateDict];

    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];


}

@end
