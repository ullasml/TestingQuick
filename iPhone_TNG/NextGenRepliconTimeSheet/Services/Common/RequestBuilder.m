//
//  RequestBuilder.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestBuilder.h"
#import "SNLog.h"
#import "Util.h"
#import <Crashlytics/Crashlytics.h>
#import "ACSimpleKeychain.h"
#import "JsonWrapper.h"
#import <repliconkit/repliconkit.h>
#import "ImageStripper.h"
#import "Enum.h"

@implementation RequestBuilder

#define Request_TimeoutInterval 120

+ (NSMutableURLRequest *)buildPOSTRequestWithParamDict:(NSDictionary *)_paramdict
{
	
	NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];


    NSString *datetoLogStr = [ImageStripper removeImageDataFromString:postStr];
   
     [LogUtil logLoggingInfo:[NSString stringWithFormat:@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],datetoLogStr] forLogLevel:LoggerCocoaLumberjack];

    CLS_LOG(@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],datetoLogStr);

	NSData *postData = [postStr dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];
   
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"8699472d-5f1b-4e24-837d-194664730958" forHTTPHeaderField:@"X-Replicon-Mobile"];
    [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];

    [request setHTTPBody:postData];
    [self addTimezone:request];
    
    return request;
}


+ (NSMutableURLRequest *)buildGETRequestWithParamDict:(NSDictionary *)_paramdict
{
	
    NSURL *url=[NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:Request_TimeoutInterval];
    [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
	[request setHTTPShouldHandleCookies:NO];
	[request setHTTPMethod:@"GET"];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];
	
    [self addTimezone:request];
    
    return request;
}

+ (NSMutableURLRequest *)buildGETRequestWithParamDictToHandleCookies:(NSDictionary *)_paramdict
{
    
    NSURL *url=[NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:Request_TimeoutInterval];
    [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
    [request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"GET"];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];
    
    [self addTimezone:request];
    
    return request;
}


+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictToHandleCookies:(NSDictionary *)_paramdict
{
	
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];

    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr] forLogLevel:LoggerCocoaLumberjack];

    CLS_LOG(@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr);

    NSData *postData = [postStr dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_paramdict objectForKey:@"URLString"]]
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:Request_TimeoutInterval];	
	
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
	[request setHTTPBody:postData];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];
    
    [self addTimezone:request];
    
    return request;
}


+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictAndBasicAuth:(NSDictionary *)_paramdict
{
	
	NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];

    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr] forLogLevel:LoggerCocoaLumberjack];


    
    CLS_LOG(@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr);
	NSData *postData = [postStr dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];


	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"true; idle-timeout=never" forHTTPHeaderField:@"X-Create-Session"];
    
    [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];

	[request setValue:@"8699472d-5f1b-4e24-837d-194664730958" forHTTPHeaderField:@"X-Replicon-Mobile"];
    
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials =  nil;
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
    }
    NSString *authStr = [NSString stringWithFormat:@"%@\\%@:%@",[credentials objectForKey:ACKeychainCompanyName] ,[credentials objectForKey:ACKeychainUsername], [credentials objectForKey:ACKeychainPassword]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [Util encodeBase64WithData:authData]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
	[request setHTTPBody:postData];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];
    
    [self addTimezone:request];
    
    return request;
}

+ (NSMutableURLRequest *)buildPOSTRequestForFreeTrialWithParamDict:(NSDictionary *)_paramdict
{
	
	NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];

    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr] forLogLevel:LoggerCocoaLumberjack];

    
    CLS_LOG(@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr);
	NSData *postData = [postStr dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];
    
	 [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [request setHTTPBody:postData];

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];
    
    [self addTimezone:request];
    
    return request;
}

+ (NSMutableURLRequest *)buildPOSTRequestForContactingSupportWithParamDict:(NSDictionary *)_paramdict
{
    NSMutableURLRequest *request = nil;
    NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
    NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isDebugMode"] == TRUE)
    {
        [SNLog Log:2 withFormat:[NSString stringWithFormat:@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr]];
    }



    CLS_LOG(@"REQUEST:::::\n%@\n%@", [_paramdict objectForKey:@"URLString"],postStr);
    NSData *postData = [postStr dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];

    [request setValue:[NSString stringWithFormat:@"ios-mobile; v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField:@"X-Replicon-Application"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];


    [request setHTTPBody:postData];

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Background] forHTTPHeaderField:ApplicationStateHeaders];    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [request setValue:[NSString stringWithFormat:@"%ld",(long)Foreground] forHTTPHeaderField:ApplicationStateHeaders];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [request setValue:[dateFormatter stringFromDate:[NSDate date]] forHTTPHeaderField:RequestTimestamp];
    ;
    
    [self addTimezone:request];

    return request;
}

+(void)addTimezone:(NSMutableURLRequest*)request
{
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSDateFormatter *localTimeZoneFormatter = [NSDateFormatter new];
    localTimeZoneFormatter.timeZone = timeZone;
    localTimeZoneFormatter.dateFormat = @"ZZZZZ";
    NSString *localTimeZoneOffset = [localTimeZoneFormatter stringFromDate:[NSDate date]];
    [request setValue:[NSString stringWithFormat:@"%@; %@",timeZone.name,localTimeZoneOffset] forHTTPHeaderField:@"X-Timezone"];
}

@end
