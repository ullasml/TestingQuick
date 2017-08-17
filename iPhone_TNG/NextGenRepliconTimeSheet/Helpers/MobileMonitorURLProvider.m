

#import "MobileMonitorURLProvider.h"

@interface MobileMonitorURLProvider ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end
@implementation MobileMonitorURLProvider

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self) {
        self.userDefaults = userDefaults;
    }
    return self;
}
-(NSString *)baseUrlForMobileMonitor{

    NSString *baseUrl = @"https://mm.replicon.com";

    NSString *serviceEndpointRootUrl = [self.userDefaults objectForKey:@"serviceEndpointRootUrl"];
    if ([serviceEndpointRootUrl containsString:@"sb1.replicon.com"]) {
        baseUrl = @"https://mm-sb1.replicon.com";
    }
    else if ([serviceEndpointRootUrl containsString:@"qa.replicon.com"]) {
        baseUrl = @"https://mm-qa.replicon.com";
    }
    else if ([Util isRelease]){
        baseUrl = @"https://mm.replicon.com";
    }
    else{
        baseUrl = @"https://mm-dev.replicon.com";
    }
    return baseUrl;
}

@end
