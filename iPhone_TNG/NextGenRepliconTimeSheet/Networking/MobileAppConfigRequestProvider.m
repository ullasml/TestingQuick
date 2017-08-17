//
//  MobileRequestProvider.m
//  repliconkit
//
//  Created by Ravikumar Duvvuri on 10/03/17.
//  Copyright © 2017 replicon. All rights reserved.
//

#import "MobileAppConfigRequestProvider.h"
#import "MobileMonitorURLProvider.h"
#import "LoginCredentialsHelper.h"
#import <repliconkit/NSString+RCategory.h>

#define TIME_OUT_INTERVAL 120

@interface MobileAppConfigRequestProvider()
@property (nonatomic) MobileMonitorURLProvider *mobileMonitorURLProvider;
@property (nonatomic) LoginCredentialsHelper *loginCredentialsHelper;
@property (nonatomic) NSBundle *bundle;
@end

@implementation MobileAppConfigRequestProvider

- (instancetype)initWithMobileMonitorURLProvider:(MobileMonitorURLProvider *)mobileMonitorURLProvider
                          loginCredentialsHelper:(LoginCredentialsHelper *)loginCredentialsHelper
                                          bundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        self.mobileMonitorURLProvider = mobileMonitorURLProvider;
        self.loginCredentialsHelper = loginCredentialsHelper;
        self.bundle = bundle;
    }
    return self;
}


- (NSMutableURLRequest *)getRequest {
    NSString *host = [self.mobileMonitorURLProvider baseUrlForMobileMonitor];
    NSString *appConfigURL = [NSString stringWithFormat:@"%@/app-config",host];
    NSString *companyName = [self.loginCredentialsHelper getLoginCredentials][@"companyName"];
    NSString *urlStr = [companyName isNotNullOrEmpty] ? [NSString stringWithFormat:@"%@?companyKey=%@",appConfigURL,companyName] : appConfigURL;
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:TIME_OUT_INTERVAL];
    [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[self.bundle infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"GET"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:@"X-Request-Timestamp"];
    
    return request;
}
@end
