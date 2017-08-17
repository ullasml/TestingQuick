//
//  ErrorDetailsTableViewCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/1/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetailsTableViewCell.h"

@interface ErrorDetailsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *value;

@end

@implementation ErrorDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
