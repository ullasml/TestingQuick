//
//  TeamTimePairCell.m
//  TT Proto
//
//  Created by Abhi on 3/7/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import "TeamTimePairCell.h"
#import "TimeViewController.h"

@implementation TeamTimePairCell
@synthesize inImageView;
@synthesize outImageView;
@synthesize indexPath;
@synthesize delegate;
@synthesize inPunchLabel;
@synthesize outPunchLabel;
@synthesize inMissingPunchLabel;
@synthesize outMissingPunchLabel;
@synthesize inmanualImageView;
@synthesize outmanualImageView;

-(void)setBackgroundImageName:(NSString *)backgroundImageName {
    
    [self setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImageName]]];
    [self setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:[backgroundImageName stringByAppendingString:@"_Highlighted"] ]]];
}

-(void)setShowAsCollapsed:(BOOL)showAsCollapsed {
    _showAsCollapsed = showAsCollapsed;
    
    if(_showAsCollapsed) {
        self.inTimeLabel.font = [UIFont boldSystemFontOfSize:14.f];
        self.outTimeLabel.font = [UIFont boldSystemFontOfSize:14.f];
    } else {
        self.inTimeLabel.font = [UIFont boldSystemFontOfSize:16.f];
        self.outTimeLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }
}


-(IBAction)inBtnClicked:(id)sender
{
    NSLog(@"--INBTN CLICKED---");
    if ([delegate isKindOfClass:[TimeViewController class]] )
    {
        [delegate setBtnClicked:@"In"];
        [delegate didSelectRowWithIndexPath:self.indexPath];
    }
}

-(IBAction)outBtnClicked:(id)sender
{
    NSLog(@"--OUTBTN CLICKED---");
    if ([delegate isKindOfClass:[TimeViewController class]] )
    {
        [delegate setBtnClicked:@"Out"];
        [delegate didSelectRowWithIndexPath:self.indexPath];
    }
}

//
//-(void)layoutSubviews {
//    
//    CGRect newCellSubViewsFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    CGRect newCellViewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//    
//    self.contentView.frame = self.contentView.bounds = self.backgroundView.frame = self.accessoryView.frame = newCellSubViewsFrame;
//    self.frame = newCellViewFrame;
//    
//    [super layoutSubviews];
////    
////    [super layoutSubviews];
////    
////    // Adjust container position for collapsed mode
////    CGRect frame = self.containerView.frame;
////    frame.origin.y = _showAsCollapsed ? -5 : 0;
////    self.containerView.frame = frame;
//}

@end
