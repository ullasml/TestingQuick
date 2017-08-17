//
//  SCHBeaconTableViewCell.m
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import "SCHBeaconTableViewCell.h"

#import "REPRepliconBeacon.h"
#import "SCHStyles.h"

@interface SCHBeaconTableViewCell ()

@property (readwrite, weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (readwrite, weak, nonatomic) IBOutlet UILabel *boundaryCrossingsLabel;
@property (readwrite, weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (readonly, strong, nonatomic) SCHStyles *styles;

@end

@implementation SCHBeaconTableViewCell

- (id)initWithCoder: (NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        _styles = [SCHStyles styles];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.minorLabel.backgroundColor = [UIColor clearColor];
    self.boundaryCrossingsLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.backgroundColor = [UIColor clearColor];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)updateWithRepliconBeacon: (REPRepliconBeacon *)repliconBeacon
{
    switch (repliconBeacon.deviceProximity)
    {
        case ELDeviceProximityUnknown:
            self.backgroundColor = self.styles.unknownDeviceProximityColor;
            break;
            
        case ELDeviceProximityInsideRegion:
            self.backgroundColor = self.styles.deviceInsideRegionColor;
            
            
            break;

        case ELDeviceProximityOutsideRegion:
            self.backgroundColor = self.styles.deviceOutsideRegionColor;
            break;

        default:
            NSLog(@"deviceProximity set to an illegal value: %ld", (long)repliconBeacon.deviceProximity);
            break;
    }
    
    self.minorLabel.text = [NSString stringWithFormat: @"%ld", (long)[repliconBeacon.minor integerValue]];
    self.boundaryCrossingsLabel.text = [NSString stringWithFormat: @"%ld", (long)repliconBeacon.boundaryCrossings];
    self.messageLabel.text = repliconBeacon.message;
}

@end













