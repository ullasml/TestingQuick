//
//  BaseService.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseService.h"
#import "SNLog.h"
#import <Crashlytics/Crashlytics.h>
#import <repliconkit/repliconkit.h>

@implementation BaseService
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
    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Request Send for SID :: %@",serviceID] forLogLevel:LoggerCocoaLumberjack];

	urlReader = [[URLReader alloc]initWithRequest:request delegate:serviceDelegate];
	[urlReader setRefDict: _refDict];
	[urlReader start];
	
	urlReader = nil;
}

-(void)executeRequest:(id)params{
	DLog(@"2. Execute Request:");
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",
			   params,@"params",
			   nil];

    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Request Send for SID :: %@",serviceID] forLogLevel:LoggerCocoaLumberjack];


     CLS_LOG(@"Request Send for SID :: %@",serviceID);
	DLog(@"2.1. Execute Request:");
	urlReader = [[URLReader alloc]initWithRequest:request delegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader start];
	
	DLog(@"2.2. Execute Request: %d");
	urlReader = nil;
}

-(void)executeSynchronusRequest {
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",nil];
	
	
	urlReader = [[URLReader alloc]init];
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
	urlReader = [[URLReader alloc]init];
	[urlReader setDelegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader startSynchronusRequest:request];
	
		DLog(@"3.2. Execute Request:");
	
	urlReader = nil;
}





-(void)executeRequestWithTimeOut:(int)timeOutVal
{
	NSMutableDictionary *_refDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
			   serviceID,@"refID",nil];
	
	DLog(@"URLReader REQUEST %@",request);
	urlReader = [[URLReader alloc]initWithRequest:request delegate:serviceDelegate];
	[urlReader setRefDict:_refDict];
	[urlReader startRequestWithTimeOutVal:timeOutVal];
	
	urlReader = nil;
}


@end
