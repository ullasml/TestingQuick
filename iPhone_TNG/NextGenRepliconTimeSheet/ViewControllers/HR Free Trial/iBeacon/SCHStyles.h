//
//  SCHStyles.h
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHStyles : NSObject

@property (readonly, strong, nonatomic) UIColor *backgroundColor;

@property (readonly, strong, nonatomic) UIColor *unknownDeviceProximityColor;
@property (readonly, strong, nonatomic) UIColor *deviceInsideRegionColor;
@property (readonly, strong, nonatomic) UIColor *deviceOutsideRegionColor;

+ (SCHStyles *)styles;

@end
