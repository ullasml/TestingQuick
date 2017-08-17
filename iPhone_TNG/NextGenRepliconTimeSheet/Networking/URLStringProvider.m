#import "URLStringProvider.h"
#import "AppProperties.h"


@interface URLStringProvider ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end


@implementation URLStringProvider

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self)
    {
        self.userDefaults = userDefaults;
    }
    return self;
}

- (NSString *)urlStringWithEndpointName:(NSString *)endpointName
{
    NSString *serviceEndpoint = [self.userDefaults objectForKey:@"serviceEndpointRootUrl"];
    AppProperties *appProperties = [AppProperties getInstance];
    NSString *endpointPath = [appProperties getServiceURLFor: endpointName];

    return [NSString stringWithFormat:@"%@%@", serviceEndpoint, endpointPath];
}

@end
