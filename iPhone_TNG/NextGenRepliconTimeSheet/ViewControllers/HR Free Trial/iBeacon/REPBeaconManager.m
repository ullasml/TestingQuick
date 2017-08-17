//
//  REPBeaconManager.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "REPBeaconManager.h"

#import "NSError+repErrorWithLocalizedDescription.h"
#import "REPBeaconManagerDelegate.h"
#import "REPConstants.h"
#import "REPRepliconBeacon.h"
#import "Constants.h"

@interface REPBeaconManager () <CLLocationManagerDelegate>

@property (readonly, weak, nonatomic) id<REPBeaconManagerDelegate> delegate;

@property (readonly, strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation REPBeaconManager

+ (REPBeaconManager *)beaconManagerWithDelegate: (id<REPBeaconManagerDelegate>)delegate
{
    REPBeaconManager *beaconManager = [[REPBeaconManager alloc] initWithDelegate: delegate];
    return beaconManager;
}

- (id)initWithDelegate: (id<REPBeaconManagerDelegate>)delegate
{
    self = [super init];
    
    if (self)
    {
        _delegate = delegate;
        
        _repliconBeacons = [NSArray array];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (void)clearRepliconBeacons
{
    _repliconBeacons = [NSArray array];
}

- (void)createRepliconBeaconsWithBeaconsJSON: (id)beaconsJSON
                                       error: (NSError **)error
{
    _repliconBeacons = [self beaconsFromBeaconsJSON: beaconsJSON
                                              error: error];
}

- (NSArray *)beaconsFromBeaconsJSON: (id)beaconsJSON
                              error: (NSError **)error
{
    NSMutableArray *beacons = [NSMutableArray array];
    
    if ([beaconsJSON isKindOfClass: [NSArray class]] == NO)
    {
        *error = [NSError repErrorWithLocalizedDescription: @"Root structure of beacons JSON must be an array."];
    }
    else
    {
        NSArray *beaconsArray = beaconsJSON;
        
        if (beaconsArray.count == 0)
        {
            *error = [NSError repErrorWithLocalizedDescription: @"Root array in beacons JSON is empty."];
        }
        else
        {
            for (NSObject *beaconObject in beaconsArray)
            {
                if ([beaconObject isKindOfClass: [NSDictionary class]] == NO)
                {
                    *error = [NSError repErrorWithLocalizedDescription: @"Elements of root array must be dictionaries."];
                }
                else
                {
                    NSDictionary *beaconDictionary = (NSDictionary *)beaconObject;
                    
                    REPRepliconBeacon *repliconBeacon = [REPRepliconBeacon repliconBeaconWithBeaconDictionary: beaconDictionary
                                                                                                        error: error];
                    
                    if (!*error)
                    {
                        [beacons addObject: repliconBeacon];
                    }
                    else
                    {
                        [beacons removeAllObjects];
                        break;
                    }
                }
            }
        }
    }
    
    return [NSArray arrayWithArray: beacons];
}

- (void)startMonitoringAllRepliconBeacons
{
    for (REPRepliconBeacon *repliconBeacon in self.repliconBeacons)
    {
        NSString *beaconAddressAsString = [NSString stringWithFormat: @"%p", repliconBeacon];
        
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: repliconBeacon.proximityUUID
                                                                               major: (CLBeaconMajorValue)[repliconBeacon.major integerValue]
                                                                               minor: (CLBeaconMinorValue)[repliconBeacon.minor integerValue]
                                                                          identifier: beaconAddressAsString];
        
        [self.locationManager startMonitoringForRegion: beaconRegion];
    }
}

- (void)stopMonitoringAllRepliconBeacons
{
    for (CLBeaconRegion *beaconRegion in self.locationManager.monitoredRegions)
    {
        [self.locationManager stopMonitoringForRegion: beaconRegion];
    }
}

- (void)locationManager: (CLLocationManager *)locationManager
         didEnterRegion: (CLRegion *)region
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    REPRepliconBeacon *repliconBeacon = [self repliconBeaconWithBeaconRegion: beaconRegion];
 
    if (repliconBeacon != nil)
    {
        repliconBeacon.deviceProximity = ELDeviceProximityInsideRegion;
        
 //       repliconBeacon.boundaryCrossings = repliconBeacon.boundaryCrossings + 1;
        
        [self.delegate beaconManager: self
     didEnterRegionForRepliconBeacon: repliconBeacon];
        
        
     //   [self displayLocalNotificationWithMessage: repliconBeacon.message];
    }
}

- (void)displayLocalNotificationWithMessage: (REPRepliconBeacon *)repliconBeacon
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = repliconBeacon.message;
    notification.soundName = UILocalNotificationDefaultSoundName;
   
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:DEEPLINKING_ATTENDENCE,@"notif",[repliconBeacon.proximityUUID UUIDString],@"proximityUUID",repliconBeacon.major,@"major",repliconBeacon.minor,@"minor",nil];
    notification.userInfo = infoDict;
    
   
    
    [[UIApplication sharedApplication] presentLocalNotificationNow: notification];
}

- (void)locationManager: (CLLocationManager *)locationManager
          didExitRegion: (CLRegion *)region
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    REPRepliconBeacon *repliconBeacon = [self repliconBeaconWithBeaconRegion: beaconRegion];
    
    if (repliconBeacon != nil)
    {
        repliconBeacon.deviceProximity = ELDeviceProximityOutsideRegion;

 //       repliconBeacon.boundaryCrossings = repliconBeacon.boundaryCrossings + 1;
        
        [self.delegate beaconManager: self
      didExitRegionForRepliconBeacon: repliconBeacon];
    }
}

- (REPRepliconBeacon *)repliconBeaconWithBeaconRegion: (CLBeaconRegion *)beaconRegion
{
    NSUInteger index = [self.repliconBeacons indexOfObjectPassingTest: ^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        REPRepliconBeacon *someRepliconBeacon = obj;
        
        if ([someRepliconBeacon.proximityUUID isEqual: beaconRegion.proximityUUID] &&
            [someRepliconBeacon.major isEqual: beaconRegion.major] &&
            [someRepliconBeacon.minor isEqual: beaconRegion.minor])
        {
            *stop = YES;
            return YES;
        }
        else
        {
            return NO;
        }
    }];
    
    REPRepliconBeacon *repliconBeacon = nil;
    
    if (index != NSNotFound)
    {
        repliconBeacon = [self.repliconBeacons objectAtIndex: index];
    }
    else
    {
        NSString *localizedErrorDescription = [NSString stringWithFormat: @"Physical beacon region found that is not in the list of Replicon beacons. Beacon region: %@", beaconRegion];
        NSError *error = [NSError repErrorWithLocalizedDescription: localizedErrorDescription];
        
        [self.delegate beaconManager: self didEncounterError: error];
    }
    
    return repliconBeacon;
}

-      (void)locationManager: (CLLocationManager *)locationManager
  monitoringDidFailForRegion: (CLRegion *)region
                   withError: (NSError *)error
{
    [self.delegate beaconManager: self didEncounterError: error];
}

@end




















