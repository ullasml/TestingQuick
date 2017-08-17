//
//  BaseService.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2BaseService.h"
#import "SNLog.h"

@implementation G2BaseService
//@synthesize refDict;
@synthesize request ;
@synthesize serviceDelegate;
@synthesize serviceID;

-(void)terminateAsyncronousService
{
	if (urlReader!=nil) 
		[urlReader cancelRequest];
}
-(void)executeRequest{
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									  serviceID,@"refID",nil];
	
	DLog(@"URLReader REQUEST %@",request);
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
       // [SNLog Log:2 :[NSString stringWithFormat:@"Request Send for SID :: %@",serviceID]];
        [SNLog Log:2 withFormat:[NSString stringWithFormat:@"Request Send for SID :: %@",serviceID]];
    }
    

	urlReader = [[G2URLReader alloc]initWithRequest:request delegate:serviceDelegate];
	[urlReader setRefDict: _refDict];
	[urlReader start];
	
	urlReader = nil;
}

-(void)executeRequest:(id)params{
	DLog(@"2. Execute Request: ");
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",
			   params,@"params",
			   nil];
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
 //       [SNLog Log:2 :[NSString stringWithFormat:@"Request Send for SID :: %@",serviceID]];
        [SNLog Log:2 withFormat:[NSString stringWithFormat:@"Request Send for SID :: %@",serviceID]];
    }
	DLog(@"2.1. Execute Request: ");
	urlReader = [[G2URLReader alloc]initWithRequest:request delegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader start];
		DLog(@"2.2. Execute Request:");
	urlReader = nil;
}

-(void)executeSynchronusRequest {
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",nil];
	
	//DLog(@"URLReader REQUEST %@",request);
	urlReader = [[G2URLReader alloc]init];
	[urlReader setDelegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader startSynchronusRequest:request];
	
	urlReader = nil;
}

-(void)executeSynchronusRequest:(id)params {
		DLog(@"3. Execute Request:");
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",
			   params,@"params",
			   nil];
	
		DLog(@"3.1. Execute Request:");
	urlReader = [[G2URLReader alloc]init];
	[urlReader setDelegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader startSynchronusRequest:request];
	
		DLog(@"3.2. Execute Request:");
	
	urlReader = nil;
}


-(void)removeUserInformationWithCookies {
	
	NSString *domainName = [[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"];
	NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	if (domainName == nil) {
		return;
	}
	NSArray * cookies = [sharedCookieStorage cookiesForURL:[NSURL URLWithString: domainName]];
	
	for (NSHTTPCookie * cookie in cookies){
		//NSString *domainName = [[AppProperties getInstance] getAppPropertyFor: @"DomainName"];
		
		//ravi - domainName should be defined in the property list. If not found (to be safe) hardcoding it with "replicon.com"
		if (domainName == nil) {
			DLog(@"Critical error: domainName cannot be null");
		}
		domainName = domainName == nil ? @"replicon.com" : domainName;
		//if ([cookie.domain rangeOfString: domainName].location != NSNotFound){
			DLog(@"COOKIES IN DOMAIN DELETION  %@",cookie.domain);
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookies"];
			[sharedCookieStorage deleteCookie:cookie];
		//}
	}
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookies"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"credentials"];
}


-(void)executeRequestWithTimeOut:(int)timeOutVal
{
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",nil];
	
	DLog(@"URLReader REQUEST %@",request);
	urlReader = [[G2URLReader alloc]initWithRequest:request delegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader startRequestWithTimeOutVal:timeOutVal];
	
	urlReader = nil;
}


@end
