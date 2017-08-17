//
//  TeamTimeLocationCell.h
//  TT Proto
//
//  Created by Abhi on 3/7/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTimeLocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *inTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *outTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *inAMPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *outAMPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *inLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *outLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *missingInTag;
@property (weak, nonatomic) IBOutlet UIImageView *missingOutTag;
@property (weak, nonatomic) IBOutlet UIImageView *transferredTag;
@property (weak, nonatomic) IBOutlet UIImageView *inImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outImageView;
@property (weak, nonatomic) IBOutlet UIImageView *transferredTag2;
@property (weak, nonatomic) IBOutlet UILabel *inPunchLabel;
@property (weak, nonatomic) IBOutlet UILabel *outPunchLabel;
@property (weak, nonatomic) IBOutlet UILabel *inMissingPunchLabel;
@property (weak, nonatomic) IBOutlet UILabel *outMissingPunchLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inmanualImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outmanualImageView;

@end
