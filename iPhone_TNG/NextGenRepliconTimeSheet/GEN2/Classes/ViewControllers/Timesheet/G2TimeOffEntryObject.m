//
//  TimeOffEntryObject.m
//  Replicon
//
//  Created by Swapna P on 5/19/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2TimeOffEntryObject.h"


@implementation G2TimeOffEntryObject
@synthesize timeOffCodeType;
@synthesize timeOffDate;
@synthesize comments;
@synthesize identity;
@synthesize sheetId;
@synthesize numberOfHours;
@synthesize entryType;
@synthesize typeIdentity;
@synthesize userID;
@synthesize isModified;
@synthesize udfArray;
@synthesize numberOfAlternativeHours;

+(G2TimeOffEntryObject *)createObjectWithDefaultValues{
    
    
	G2TimeOffEntryObject *timeOffEntryObject = [[G2TimeOffEntryObject alloc] init]; 
	
	[timeOffEntryObject setTimeOffDate:[NSDate date]];
	return timeOffEntryObject;
}



@end
