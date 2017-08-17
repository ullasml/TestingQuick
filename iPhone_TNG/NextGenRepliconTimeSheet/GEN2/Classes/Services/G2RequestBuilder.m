//
//  RequestBuilder.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2RequestBuilder.h"
#import "SNLog.h"

@implementation G2RequestBuilder


+ (NSMutableURLRequest *)buildPOSTRequestWithParamDict:(NSDictionary *)_paramdict{
	//NSDictionary *paramDict = [[NSDictionary dictionaryWithDictionary:_paramdict] ];
	NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];
    
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
        [SNLog Log:2 withFormat:postStr];
    }
    
	NSData *postData = [postStr dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														 timeoutInterval:Request_TimeoutInterval];	
    
     
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]!=nil) {
            DLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]);
            [request setAllHTTPHeaderFields:[[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]];	
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"cookies" ]!=nil) {
            [request setAllHTTPHeaderFields:[[NSUserDefaults standardUserDefaults]objectForKey:@"cookies" ]];	
        }
    }
    
	
	[request setHTTPShouldHandleCookies:YES];
	//[request setHTTPShouldHandleCookies:NO];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setValue:@"User" forHTTPHeaderField:@"X-Replicon-Security-Context"];
	[request setValue:@"8699472d-5f1b-4e24-837d-194664730958" forHTTPHeaderField:@"X-Replicon-Mobile"];
	[request setHTTPBody:postData];
	return request ;
}


+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictForApprovals:(NSDictionary *)_paramdict{
	//NSDictionary *paramDict = [[NSDictionary dictionaryWithDictionary:_paramdict] ];
	NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];
    
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
        [SNLog Log:3 withFormat:postStr];
    }
    
	NSData *postData = [postStr dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];	
	
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]!=nil) {
            [request setAllHTTPHeaderFields:[[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]];	
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"cookies" ]!=nil) {
            [request setAllHTTPHeaderFields:[[NSUserDefaults standardUserDefaults]objectForKey:@"cookies" ]];	
        }
    }

    
	[request setHTTPShouldHandleCookies:YES];
	//[request setHTTPShouldHandleCookies:NO];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setValue:@"Approver" forHTTPHeaderField:@"X-Replicon-Security-Context"];
	[request setValue:@"8699472d-5f1b-4e24-837d-194664730958" forHTTPHeaderField:@"X-Replicon-Mobile"];
	[request setHTTPBody:postData];
	return request ;
}


+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictWithNoSecurityContext:(NSDictionary *)_paramdict
{
	//NSDictionary *paramDict = [[NSDictionary dictionaryWithDictionary:_paramdict] ];
	NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];
    
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
        [SNLog Log:4 withFormat:postStr];
    }
    
	NSData *postData = [postStr dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];	
	
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]!=nil) {
            [request setAllHTTPHeaderFields:[[NSUserDefaults standardUserDefaults]objectForKey:@"SSOCookies" ]];	
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"cookies" ]!=nil) {
            [request setAllHTTPHeaderFields:[[NSUserDefaults standardUserDefaults]objectForKey:@"cookies" ]];	
        }
    }

    
    
	[request setHTTPShouldHandleCookies:YES];
	//[request setHTTPShouldHandleCookies:NO];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	[request setValue:@"8699472d-5f1b-4e24-837d-194664730958" forHTTPHeaderField:@"X-Replicon-Mobile"];
	[request setHTTPBody:postData];
	return request ;
}


+ (NSMutableURLRequest *)buildGETRequestWithParamDict:(NSDictionary *)_paramdict{
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_paramdict objectForKey:@"URLString"]]
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:Request_TimeoutInterval];	
	[request setHTTPShouldHandleCookies:NO];
	[request setHTTPMethod:@"GET"];
	
	return request;
}

+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictToHandleCookies:(NSDictionary *)_paramdict{
	
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];
	NSData *postData = [postStr dataUsingEncoding: NSUnicodeStringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_paramdict objectForKey:@"URLString"]]
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															timeoutInterval:Request_TimeoutInterval];	
	
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	
	
	
	return request ;
}

+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictForGen3:(NSDictionary *)_paramdict{
    NSMutableURLRequest *request = nil;
	NSURL *url = [NSURL URLWithString:[_paramdict objectForKey:@"URLString"]];
	NSString *postStr = [_paramdict objectForKey:@"PayLoadStr"];
    
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
        [SNLog Log:2 withFormat:postStr];
    }
    
	NSData *postData = [postStr dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:Request_TimeoutInterval];
    
    
    
    
	
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"8699472d-5f1b-4e24-837d-194664730958" forHTTPHeaderField:@"X-Replicon-Mobile"];
    
    
    [request setHTTPBody:postData];
	return request ;}


@end
