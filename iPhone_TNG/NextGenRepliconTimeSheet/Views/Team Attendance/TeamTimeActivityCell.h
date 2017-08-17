//
//  TeamTimeActivityCell.h
//  TT Proto
//
//  Created by Abhi on 3/8/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTimeActivityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indentation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelLeading;

@end
