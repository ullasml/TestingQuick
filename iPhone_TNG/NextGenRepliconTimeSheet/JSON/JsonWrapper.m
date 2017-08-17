//
//  JsonWrapper.m
//  Pictage
//
//  Created by HemaBindu  on 4/20/10.
//  Copyright 2010 EnLume. All rights reserved.
//

#import "JsonWrapper.h"


@implementation JsonWrapper

+ (id) parseJson:(id)receivedData error:(NSError **)error{
	DLog(@"In JsonWrapper:: parseJson");
	 
	 SBJsonParser *json = [[SBJsonParser alloc] init];
	
	id response = [json objectWithData:receivedData];

	
	return response;
		
}


+ (id) writeJson:(id)jsonObj error:(NSError **)error{
	DLog(@"In JsonWrapper:: writeJson");
	
	SBJsonWriter *json = [SBJsonWriter new];
	
	id request = [json stringWithObject:jsonObj];
	if (error) {
		*error = [NSError errorWithDomain:@"Not valid type for JSON" code:10 userInfo:nil];
	}
	
	
	
	return request;
	
}

@end
