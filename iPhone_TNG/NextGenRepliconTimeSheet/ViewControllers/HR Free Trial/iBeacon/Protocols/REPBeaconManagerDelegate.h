//
//  REPBeaconManagerDelegate.h
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

@class REPBeaconManager;
@class REPRepliconBeacon;

@protocol REPBeaconManagerDelegate <NSObject>

@required

- (void)            beaconManager: (REPBeaconManager *)beaconManager
  didEnterRegionForRepliconBeacon: (REPRepliconBeacon *)repliconBeacon;

- (void)            beaconManager: (REPBeaconManager *)beaconManager
   didExitRegionForRepliconBeacon: (REPRepliconBeacon *)repliconBeacon;

- (void)beaconManager: (REPBeaconManager *)beaconManager
    didEncounterError: (NSError *)error;

@end

