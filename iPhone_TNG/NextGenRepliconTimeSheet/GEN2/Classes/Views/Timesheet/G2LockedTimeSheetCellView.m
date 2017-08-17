//
//  LockedTimeSheetCellView.m
//  Replicon
//
//  Created by Dipta Rakshit on 12/23/11.
//  Copyright (c) 2011 Replicon. All rights reserved.
//

#import "G2LockedTimeSheetCellView.h"

@implementation G2LockedTimeSheetCellView
@synthesize dateLbl;
@synthesize hoursLbl;
@synthesize timeInOutLbl;
@synthesize locationHeaderLbl;
@synthesize locationValueLbl;
@synthesize clockImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
