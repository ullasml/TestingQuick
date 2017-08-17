//
//  PunchDetailsCell.h
//  NextGenRepliconTimeSheet
//
//  Created by pairing02 on 11/18/15.
//  Copyright © 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PunchDetailsCell : UITableViewCell
@property (weak, nonatomic, readonly) UILabel *timeLabel;
@property (weak, nonatomic, readonly) UILabel *punchTypeLabel;
@property (weak, nonatomic, readonly) UIImageView *punchActionIconImageView;
@end
