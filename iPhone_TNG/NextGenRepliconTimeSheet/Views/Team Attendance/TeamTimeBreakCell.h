//
//  TeamTimeBreakCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTimeBreakCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indentation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelLeading;
@end
