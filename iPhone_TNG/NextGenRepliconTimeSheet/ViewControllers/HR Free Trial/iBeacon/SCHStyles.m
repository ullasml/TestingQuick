//
//  SCHStyles.m
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import "SCHStyles.h"

@implementation SCHStyles

+ (SCHStyles *)styles
{
    SCHStyles *styles = [[SCHStyles alloc] init];
    return styles;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _backgroundColor = [UIColor colorWithWhite: 0.87 alpha: 1.0];
     
        _unknownDeviceProximityColor = [UIColor colorWithWhite: 0.77 alpha: 1.0];
        _deviceInsideRegionColor = [UIColor colorWithRed: 0.0 green: 1.0 blue: 0.0 alpha: 0.2];
        _deviceOutsideRegionColor = [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.2];
    }
    
    return self;
}

@end
