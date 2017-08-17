//
//  LoginDelegate.m
//  Replicon
//
//  Created by Swapna P on 4/17/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2LoginDelegate.h"
#import "RepliconAppDelegate.h"

@implementation G2LoginDelegate
@synthesize parentController;
- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

-(void)sendrequestToCheckExistenceOfUserByLoginName{
	//DLog(@"PARENT DELEGATE :Login Delegate %@",parentController);
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	[[G2RepliconServiceManager loginService] sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:parentController];
}
@end
