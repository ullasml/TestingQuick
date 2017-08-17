//
//  NetworkReachabilityTest.h
//  Demo
//
//  Created by Sasikant on 06/11/09.
//  Copyright 2009 Enlume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol NetworkServiceProtocol

@optional

- (void) networkActivated;
- (void) networkActivatedWithDict:(NSDictionary *) dataDict;

@end


@interface NetworkMonitor : NSObject {
    
    
    Reachability* hostReach;
    NSMutableArray *__weak delegatesArray;
    BOOL networkAvailable;
}


@property (nonatomic) BOOL networkAvailable;
@property (weak, nonatomic, readonly, getter=delegatesArray) NSMutableArray *delegatesArray;

+ (NetworkMonitor *) sharedInstance;
+ (BOOL) isNetworkAvailableForListener:(id) obj;
- (void) notifyAllListeners;
- (void) queueTheListener:(id) obj;
- (void) mountNetworkReachabilityMonitor;
- (void) updateReachabilityStatus: (Reachability*) curReach;


@end
