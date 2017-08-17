//
//  SCHBeaconTableViewCell.h
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class REPRepliconBeacon;

@interface SCHBeaconTableViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;

- (void)updateWithRepliconBeacon: (REPRepliconBeacon *)repliconBeacon;

@end
