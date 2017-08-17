//
//  SCHBeaconsViewController.h
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "REPRepliconBeacon.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>

extern const id MyConstantKey;

@interface SCHBeaconsViewController : UIViewController
{
    
}

-(void)stopBeacons;
//- (REPRepliconBeacon *)repliconBeaconWithBeaconRegionFromBeaconManager:(NSUUID *)uuid andMajor:(NSNumber *)major andMinor:(NSNumber *)minor;
- (void)repliconBeaconWithBeaconRegionFromBeaconManager:(NSDictionary *)userInfo;
@end
