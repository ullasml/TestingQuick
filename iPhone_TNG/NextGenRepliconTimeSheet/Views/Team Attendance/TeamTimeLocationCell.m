//
//  TeamTimeLocationCell.m
//  TT Proto
//
//  Created by Abhi on 3/7/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import "TeamTimeLocationCell.h"

@implementation TeamTimeLocationCell
@synthesize inImageView;
@synthesize outImageView;
@synthesize inPunchLabel;
@synthesize outPunchLabel;
@synthesize inMissingPunchLabel;
@synthesize outMissingPunchLabel;
@synthesize inmanualImageView;
@synthesize outmanualImageView;

-(void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage* normalBg = [UIImage imageNamed:@"bg_locationCell"];
    [self setBackgroundView:[[UIImageView alloc] initWithImage:normalBg]];
    
}

@end
