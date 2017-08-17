//
//  REPRepliconBeacon.h
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, REPDeviceProximity)
{
    ELDeviceProximityUnknown,
    ELDeviceProximityInsideRegion,
    ELDeviceProximityOutsideRegion
};

@interface REPRepliconBeacon : NSObject

@property (readonly, strong, nonatomic) NSUUID *proximityUUID;
@property (readonly, strong, nonatomic) NSNumber *major;
@property (readonly, strong, nonatomic) NSNumber *minor;
@property (readonly, strong, nonatomic) NSString *message;

@property (readwrite, assign, nonatomic) REPDeviceProximity deviceProximity;
@property (readwrite, assign, nonatomic) NSUInteger boundaryCrossings;

- (id)initWithProximityUUID: (NSUUID *)proximityUUID
                      major: (NSNumber *)major
                      minor: (NSNumber *)minor
                    message: (NSString *)message;

+ (REPRepliconBeacon *)repliconBeaconWithBeaconDictionary: (NSDictionary *)beaconDictionary
                                                    error: (NSError **)error;

@end
