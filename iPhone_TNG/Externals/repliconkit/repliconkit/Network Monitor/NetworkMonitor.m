//
//  NetworkReachabilityTest.m
//  Demo
//
//  Created by Sasikant on 06/11/09.
//  Copyright 2009 Enlume. All rights reserved.
//

#import "NetworkMonitor.h"


@implementation NetworkMonitor

static NetworkMonitor *networkMonitor = nil;

@synthesize networkAvailable;
@synthesize delegatesArray;

#pragma mark Shared instance method
+ (NetworkMonitor *) sharedInstance {
	
	if (networkMonitor == nil) {
		networkMonitor = [[NetworkMonitor alloc] init];
	}
	return networkMonitor;
}

- (id) init {
	
	self = [super init];
	
	if (self != nil) {
		[self mountNetworkReachabilityMonitor];
	}
	return self;
}

+ (BOOL) isNetworkAvailableForListener:(id) obj {
	
	if([Reachability isNetworkAvailable] == YES) {
		return YES;
	} else {
		[networkMonitor queueTheListener:obj];
	}
	return NO;
}


- (NSMutableArray *) delegatesArray {
	
	if (delegatesArray == nil) {
		delegatesArray = [NSMutableArray array];
	}
	return delegatesArray;
}

- (void) queueTheListener:(id) obj {
	
	[self.delegatesArray addObject:obj];
	
}


- (void) mountNetworkReachabilityMonitor {
	
    [[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(reachabilityChanged:)
												 name: kReachabilityChangedNotification
											   object: nil];
	
	hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
	
	[hostReach startNotifer];
}

#pragma mark Notification method

//This method is called after every network notification is pushed.
- (void) reachabilityChanged: (NSNotification* )note
{
	
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateReachabilityStatus:curReach];
}

//By the end this method is called to show display the reachability.
- (void) updateReachabilityStatus: (Reachability*) curReach {
	
    if(curReach == hostReach) {
		
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		if((netStatus == ReachableViaWWAN) || (netStatus == ReachableViaWiFi)) {
			[self setNetworkAvailable:YES];
			[self notifyAllListeners];
		} else {
			[self setNetworkAvailable:NO];
            [self notifyAllListeners];
		}
	}
}

- (void) notifyAllListeners
{
    id obj = nil;
    NSUInteger count = [delegatesArray count];
    
    if (count > 0)
    {
        
        obj = [self.delegatesArray objectAtIndex:(count -1)];
        
        if ([obj conformsToProtocol:@protocol(NetworkServiceProtocol)] == YES)
        {
            
            [obj networkActivated];
        }
        
        
    }
    /*[[[UIApplication sharedApplication]delegate] performSelector:@selector(networkActivated)];*/
}

@end
