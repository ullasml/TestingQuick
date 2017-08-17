//
//  CBCentralManager+repStateAsString.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "CBCentralManager+repStateAsString.h"

@implementation CBCentralManager (repStateAsString)

- (NSString *)repStateAsString
{
    switch (self.state)
    {
        case CBCentralManagerStateUnknown:
            return @"unknown";
            break;
            
        case CBCentralManagerStateResetting:
            return @"resetting";
            break;
            
        case CBCentralManagerStateUnsupported:
            return @"unsupported";
            break;
            
        case CBCentralManagerStateUnauthorized:
            return @"unauthorized";
            break;
            
        case CBCentralManagerStatePoweredOff:
            return @"powered off";
            break;
            
        case CBCentralManagerStatePoweredOn:
            return @"powered on";
            break;
            
        default:
            NSLog(@"Unhandled central manager state: %d", (int)self.state);
            return @"";
            break;
    }
}

@end
