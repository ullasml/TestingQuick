//
//  EntryCellDetails.m
//  Replicon
//
//  Created by vijaysai on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2EntryCellDetails.h"


@implementation G2EntryCellDetails
@synthesize dataSourceArray;
@synthesize fieldName;
@synthesize fieldValue;
@synthesize fieldType;
@synthesize componentSelectedIndexArray;
@synthesize defaultValue;
@synthesize maxValue;
@synthesize minValue;
@synthesize decimalPoints;
@synthesize required;
@synthesize udfIdentity;
@synthesize udfModule;


-(id)initWithDefaultValue :(id)_defaultValue {
	
	self = [super init];
	if(self != nil){
		[self setDefaultValue:_defaultValue];
	}
	
	return self;
}




-(void)checkAndRelease {
	
	
}

@end
