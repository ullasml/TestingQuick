#import "RequestDictionaryBuilder.h"
#import "AppProperties.h"


@interface RequestDictionaryBuilder ()

@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) AppProperties *appProperties;

@end


@implementation RequestDictionaryBuilder

-(instancetype)initWithAppProperties:(AppProperties *)appProperties userDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self) {
        self.userDefaults = userDefaults;
        self.appProperties = appProperties;    
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (NSDictionary *)requestDictionaryWithEndpointName:(NSString *)endpointName httpBodyDictionary:(NSDictionary *)httpBodyDictionary {
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:[self.userDefaults objectForKey:@"serviceEndpointRootUrl"]];
    NSString *endpointPath = [self.appProperties getServiceURLFor:endpointName];

    NSData *requestPayloadData = [NSJSONSerialization dataWithJSONObject:httpBodyDictionary options:0 error:nil];
    NSString *requestPayloadString = [[NSString alloc] initWithData:requestPayloadData encoding:NSUTF8StringEncoding];
    urlComponents.path = [urlComponents.path stringByAppendingPathComponent:endpointPath];

    return @{
            @"URLString": [[urlComponents URL] absoluteString],
            @"PayLoadStr": requestPayloadString
    };
}

@end
