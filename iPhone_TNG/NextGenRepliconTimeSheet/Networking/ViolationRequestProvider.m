#import "ViolationRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"


@interface ViolationRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;

@end


@implementation ViolationRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}

- (NSURLRequest *)provideRequestWithDate:(NSDate *)date
{
    NSDictionary *dateDict = [Util convertDateToApiDateDictionaryOnLocalTimeZone:date];

    NSDictionary *requestBodyDictionary = @{
                                            @"date": dateDict,
                                            };
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetCurrentDateViolations"];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

- (NSURLRequest *)provideRequestWithPunchURI:(NSString *)punchURI
{
    NSDictionary *requestBodyDictionary = @{@"timePunchUri": punchURI};
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetMostRecentValidationResult"];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
