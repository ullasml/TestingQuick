//
//  TeamTimeImagesCell.h
//  TT Proto
//
//  Created by Abhi on 3/7/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTimeImagesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *inImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outImageView;
@property (weak, nonatomic) IBOutlet UILabel *inTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *outTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *inAMPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *outAMPMLabel;
@property (weak, nonatomic) IBOutlet UIImageView *missingInAlert;
@property (weak, nonatomic) IBOutlet UIImageView *missingOutAlert;
@property (weak, nonatomic) IBOutlet UIImageView *transferredTag;
@property (weak, nonatomic) IBOutlet UIImageView *inPunchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outPunchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *transferredTag2;
@property (weak, nonatomic) IBOutlet UILabel *inPunchLabel;
@property (weak, nonatomic) IBOutlet UILabel *outPunchLabel;
@property (weak, nonatomic) IBOutlet UILabel *inMissingPunchLabel;
@property (weak, nonatomic) IBOutlet UILabel *outMissingPunchLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inmanualImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outmanualImageView;
@end
