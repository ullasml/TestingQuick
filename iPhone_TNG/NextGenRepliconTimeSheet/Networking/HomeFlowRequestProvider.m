
#import "HomeFlowRequestProvider.h"
#import "RequestBuilder.h"
#import "URLStringProvider.h"

@interface HomeFlowRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;

@end

@implementation HomeFlowRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}

- (NSURLRequest *)requestForHomeFlowService
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetHomeSummary"];
    
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
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
