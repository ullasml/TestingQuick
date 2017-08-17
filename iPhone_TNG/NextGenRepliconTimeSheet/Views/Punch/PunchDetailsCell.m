//
//  PunchDetailsCell.m
//  NextGenRepliconTimeSheet
//
//  Created by pairing02 on 11/18/15.
//  Copyright © 2015 Replicon. All rights reserved.
//

#import "PunchDetailsCell.h"

@interface PunchDetailsCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *punchTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *punchActionIconImageView;
@end

@implementation PunchDetailsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
