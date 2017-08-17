#import "PunchLogRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"


@interface PunchLogRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;

@end


@implementation PunchLogRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }

    return self;
}

- (NSURLRequest *)requestWithPunchURI:(NSString *)punchURI
{
    NSDictionary *requestBodyDictionary = @{@"timePunchUris": @[punchURI]};
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"MobileGetTimePunchAuditRecordDetails"];
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
