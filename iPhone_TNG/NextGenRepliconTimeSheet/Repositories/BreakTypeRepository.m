#import "BreakTypeRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "BreakTypeStorage.h"
#import <repliconkit/ReachabilityMonitor.h>


@interface BreakTypeRepository ()

@property (nonatomic) JSONClient *jsonClient;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) BreakTypeDeserializer *breakTypeDeserializer;
@property (nonatomic) NSArray *breakTypes;
@property (nonatomic) BreakTypeStorage *breakTypeStorage;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;


@end


@implementation BreakTypeRepository

- (instancetype)initWithJSONClientBreakTypeDeserializer:(BreakTypeDeserializer *)breakTypeDeserializer
                                       breakTypeStorage:(BreakTypeStorage *)breakTypeStorage
                                    reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                           userDefaults:(NSUserDefaults *)userDefaults
                                             jsonClient:(JSONClient *)jsonClient
{
    self = [super init];
    if (self) {
        self.jsonClient = jsonClient;
        self.userDefaults = userDefaults;
        self.breakTypeStorage = breakTypeStorage;
        self.reachabilityMonitor = reachabilityMonitor;
        self.breakTypeDeserializer = breakTypeDeserializer;
    }
    return self;
}

- (KSPromise *) fetchBreakTypesForUser:(NSString *)userUri
{
    if ([self.reachabilityMonitor isNetworkReachable])
    {
        return [self fetchBreakTypesAndCacheForUser:userUri];
    }
    else
    {
        KSDeferred *deferred = [[KSDeferred alloc] init];
        self.breakTypes = [self.breakTypeStorage allBreakTypesForUser:userUri];
        if ([self.breakTypes count] > 0) {
            [deferred resolveWithValue:self.breakTypes];
            return deferred.promise;
        }
        return [self fetchBreakTypesAndCacheForUser:userUri];
    }
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSString *)urlStringWithEndpointName:(NSString *)endpointName
{
    NSString *serviceEndpoint = [self.userDefaults objectForKey:@"serviceEndpointRootUrl"];
    AppProperties *appProperties = [AppProperties getInstance];
    NSString *endpointPath = [appProperties getServiceURLFor: endpointName];

    return [NSString stringWithFormat:@"%@%@", serviceEndpoint, endpointPath];
}

- (KSPromise *)fetchBreakTypesAndCacheForUser:(NSString *)userUri
{
    NSString *urlString = [self urlStringWithEndpointName:@"GetBreakTypeListForUser"];

    NSDictionary *bodyDictionary = @{
                                     @"page": @"1",
                                     @"pageSize": @"100",
                                     @"userUri": userUri,
                                     @"textSearch": [NSNull null]
                                     };
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr": requestBodyString};

    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    KSPromise *promise = [self.jsonClient promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *breakTypes = [self.breakTypeDeserializer deserialize:json];
        [self.breakTypeStorage storeBreakTypes:breakTypes forUser:userUri];
        self.breakTypes = breakTypes;
        return breakTypes;
    } error:^id(NSError *error) {
        return error;
    }];

}

@end
