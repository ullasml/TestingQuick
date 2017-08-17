//
//  REPRepliconBeacon.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "REPRepliconBeacon.h"

#import "NSError+repErrorWithLocalizedDescription.h"
#import "NSString+repContainsOnly0to9.h"

@implementation REPRepliconBeacon

- (id)initWithProximityUUID: (NSUUID *)proximityUUID
                      major: (NSNumber *)major
                      minor: (NSNumber *)minor
                    message: (NSString *)message
{
    self = [super init];
    
    if (self)
    {
        _proximityUUID = proximityUUID;
        _major = major;
        _minor = minor;
        _message = message;
        
        _deviceProximity = ELDeviceProximityUnknown;
        _boundaryCrossings = 0;
    }

    return self;
}

+ (REPRepliconBeacon *)repliconBeaconWithBeaconDictionary: (NSDictionary *)beaconDictionary
                                                    error: (NSError **)error
{
    REPRepliconBeacon *repliconBeacon = nil;
    
    if ([beaconDictionary.allKeys containsObject: @"proximityUUID"] == NO ||
        [beaconDictionary.allKeys containsObject: @"major"] == NO ||
        [beaconDictionary.allKeys containsObject: @"minor"] == NO ||
        [beaconDictionary.allKeys containsObject: @"message"] == NO)
    {
        *error = [NSError repErrorWithLocalizedDescription: @"Beacon dictionary must contain keys proximityUUID, major, minor and message."];
    }
    else
    {
        NSString *proximityUUIDString = beaconDictionary[@"proximityUUID"];
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString: proximityUUIDString];
        
        if (!proximityUUID)
        {
            *error = [NSError repErrorWithLocalizedDescription: [NSString stringWithFormat: @"Invalid proximityUUID %@ in beacon JSON.", proximityUUIDString]];
        }
        else
        {
            NSString *majorString = beaconDictionary[@"major"];
            
            if ([majorString repContainsOnly0to9] == NO || [majorString integerValue] < 0 || [majorString integerValue] > 65535)
            {
                *error = [NSError repErrorWithLocalizedDescription: [NSString stringWithFormat: @"Invalid major %@ in beacon JSON. Major must be a number between 0 and 65535.", majorString]];
            }
            else
            {
                NSNumber *major = [NSNumber numberWithInteger: (CLBeaconMajorValue)[majorString integerValue]];

                NSString *minorString = beaconDictionary[@"minor"];
                
                if ([minorString repContainsOnly0to9] == NO || [minorString integerValue] < 0 || [minorString integerValue] > 65535)
                {
                    *error = [NSError repErrorWithLocalizedDescription: [NSString stringWithFormat: @"Invalid minor %@ in beacon JSON. Minor must be a number between 0 and 65535.", minorString]];
                }
                else
                {
                    NSNumber *minor = [NSNumber numberWithInteger: (CLBeaconMinorValue)[minorString integerValue]];

                    NSString *message = beaconDictionary[@"message"];
                    
                    repliconBeacon = [[REPRepliconBeacon alloc] initWithProximityUUID: proximityUUID
                                                                                major: major
                                                                                minor: minor
                                                                              message: message];
                }
            }
        }
    }
    
    return repliconBeacon;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat: @"<%@: %p; ", [self class], self];
    desc = [desc stringByAppendingFormat: @"proximityUUID = %@; ", self.proximityUUID];
    desc = [desc stringByAppendingFormat: @"major = %@; ", self.major];
    desc = [desc stringByAppendingFormat: @"minor = %@; ", self.minor];
    desc = [desc stringByAppendingFormat: @"message = %@; ", self.message];
    
    return desc;
}

@end

















