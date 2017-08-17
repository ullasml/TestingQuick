//
//  TeamTimeUserCell.m
//  TT Proto
//
//  Created by Abhi on 3/7/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import "TeamTimeUserCell.h"
#import "TimeViewController.h"

@implementation TeamTimeUserCell
@synthesize delegate;
@synthesize indexPath;
@synthesize showsAddButton;
@synthesize breakHoursLabel;
@synthesize breakHoursValueLabel;
@synthesize regularHoursLabel;
@synthesize regularHoursValueLabel;
-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundImage = [UIImage imageNamed:@"bg_teamTimeUserCell"];
    
}

-(void)setBackgroundImage:(UIImage *)backgroundImage {
    
    [self setBackgroundView:[[UIImageView alloc] initWithImage:backgroundImage]];
    
}

-(void)setShowsAddButtonBOOL:(BOOL)showsAddButtonTmp
{
    self.showsAddButton = showsAddButtonTmp;
    self.addButtonWidth.constant = showsAddButtonTmp ? 33.f : 0;
    
    if (showsAddButton)
    {
        
    }
    else
    {
        [self.addButton setHidden:YES];
    }
}
-(IBAction)addBtnClicked:(id)sender{
    if ([delegate isKindOfClass:[TimeViewController class]] )
    {
        [delegate addPunch:self.indexPath];
    }
}
@end
