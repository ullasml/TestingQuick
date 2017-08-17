//
//  ProjectObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ProjectObject.h"

@implementation ProjectObject
@synthesize projectName;
@synthesize projectUri;
@synthesize projectCode;
@synthesize clientName;
@synthesize clientUri;
@synthesize isTimeAllocationAllowed;
@synthesize hasTasksAvailableForTimeAllocation;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		
    }
	return self;
}





@end
