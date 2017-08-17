#import "ForgotPasswordRequestProvider.h"
#import "G2RepliconServiceManager.h"
#import "AppProperties.h"
#import "RequestBuilder.h"
#import "Constants.h"

typedef NS_ENUM(NSInteger,ServerType)
{
    Swimlane,
    Production,
    Demo,
};

@interface ForgotPasswordRequestProvider ()
@property (nonatomic, readwrite) NSUserDefaults *defaults;
@property (nonatomic) URLStringProvider *urlStringProvider;

@end

@implementation ForgotPasswordRequestProvider

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults
{
    self = [super init];
    if (self) {
        self.defaults = defaults;
    }
    return self;
}

- (NSURLRequest *)provideRequestWithCompanyName:(NSString *)company andemail:(NSString *)email
{
    NSDictionary *requestBodyDictionary = @{
                                            @"emailAddress":email,
                                            @"tenant":@{
                                                    @"slug":[NSNull null],
                                                    @"companyKey":company,
                                                    @"uri":[NSNull null]
                                                    }
                                            };
    NSString *urlString=[self getURLForServiceWithName:@"createPasswordResetRequest"];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    [request setValue:RequestMadeWhileInvalidUserSessionHeaderValue forHTTPHeaderField:RequestMadeWhileInvalidUserSessionHeaderKey];
    
    return request;
    
}

- (NSURLRequest *)provideRequestWithPasswordResetRequestUri:(NSString *)passwordResetRequestUri
{
    NSDictionary *requestBodyDictionary =@{
                                           @"passwordResetRequestUri":passwordResetRequestUri
                                           };
    NSString *urlString=[self getURLForServiceWithName:@"SendPasswordResetRequestEmail"];
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDictionary options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
    
    [request setValue:RequestMadeWhileInvalidUserSessionHeaderValue forHTTPHeaderField:RequestMadeWhileInvalidUserSessionHeaderKey];
    
    return request;
    
}

#pragma mark - Private

-(ServerType)getServerType
{
    NSString *serverType = [self.defaults objectForKey:@"urlPrefixesStr"];
    if (serverType)
    {
        if ([serverType isEqualToString:@"demo"])
        {
            return Demo;
        }
        else
        {
            return Swimlane;
        }
        
    }
    return Production;
}

-(NSString *)getURLForServiceWithName:(NSString *)service
{
//    ServerType serverType = [self getServerType];
    NSString *serviceLink = [[AppProperties getInstance] getServiceURLFor:service];
    NSString *domainName = [[AppProperties getInstance] getAppPropertyFor:@"DomainName"];
    
//    if (serverType == Demo)
//    {
//        return [NSString stringWithFormat:@"https://demo-global.%@/%@",domainName,serviceLink];
//    }
//    else if (serverType == Swimlane)
//    {
//        return [NSString stringWithFormat:@"https://replicon.staging-global.%@/%@",domainName,serviceLink];
//    }
//    else
//    {
        return [NSString stringWithFormat:@"https://global.%@/%@",domainName,serviceLink];
//    }
}

@end
