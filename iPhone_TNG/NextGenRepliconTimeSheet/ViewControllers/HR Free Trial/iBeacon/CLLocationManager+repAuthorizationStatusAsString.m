//
//  CLLocationManager+repAuthorizationStatusAsString.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "CLLocationManager+repAuthorizationStatusAsString.h"

@implementation CLLocationManager (repAuthorizationStatusAsString)

+ (NSString *)repAuthorizationStatusAsString
{
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined:
            return @"not determined";
            break;
            
        case kCLAuthorizationStatusRestricted:
            return @"restricted";
            break;
            
        case kCLAuthorizationStatusDenied:
            return @"denied";
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            return @"authorized";
            break;
            
        default:
            NSLog(@"Unhandled location manager authorization status: %d", (int)[CLLocationManager authorizationStatus]);
            return @"";
            break;
    }
}

@end
