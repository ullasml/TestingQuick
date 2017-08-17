#import "UpdateWaiverRequestProvider.h"
#import "Waiver.h"
#import "WaiverOption.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"


@interface UpdateWaiverRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;

@end


@implementation UpdateWaiverRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }

    return self;
}

- (NSURLRequest *)provideRequestWithWaiver:(Waiver *)waiver waiverOption:(WaiverOption *)waiverOption
{
    NSString *waiverURI = [waiver URI];
    NSString *waiverOptionValue = [waiverOption value];

    NSDictionary *httpBodyDictionary = @{@"validationWaiverUri": waiverURI,
                                         @"validationWaiverOptionValue": waiverOptionValue};
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:httpBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"AcknowledgeValidationWaiver"];;
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr": requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
