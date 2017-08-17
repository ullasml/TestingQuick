//
//  REPBeaconManager.h
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class REPRepliconBeacon;

@protocol REPBeaconManagerDelegate;

@interface REPBeaconManager : NSObject

@property (readonly, strong, nonatomic) NSArray *repliconBeacons;

+ (REPBeaconManager *)beaconManagerWithDelegate: (id<REPBeaconManagerDelegate>)delegate;

- (id)initWithDelegate: (id<REPBeaconManagerDelegate>)delegate;

- (void)clearRepliconBeacons;

- (void)createRepliconBeaconsWithBeaconsJSON: (id)beaconsJSON
                                       error: (NSError **)error;

- (void)startMonitoringAllRepliconBeacons;

- (void)stopMonitoringAllRepliconBeacons;

- (void)displayLocalNotificationWithMessage: (REPRepliconBeacon *)repliconBeacon;

- (REPRepliconBeacon *)repliconBeaconWithBeaconRegion: (CLBeaconRegion *)beaconRegion;

@end
