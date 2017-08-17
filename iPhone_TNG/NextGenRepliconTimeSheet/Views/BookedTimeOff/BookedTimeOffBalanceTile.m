//
//  BookedTimeOffBalanceTile.m
//  Replicon
//
//  Created by Dipta Rakshit on 6/26/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "BookedTimeOffBalanceTile.h"
#import "Constants.h"
#import "Util.h"

@interface BookedTimeOffBalanceTile ()
- (void)handleSingleTap;

@end

@implementation BookedTimeOffBalanceTile
@synthesize balanceLbl;
@synthesize typeLbl;
@synthesize delegate;
@synthesize backgroundImageView;
@synthesize statusLbl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self createView:frame];
    }
    return self;
}


-(void)createView:(CGRect)frame
{
    UIImageView *tempbackgroundImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.backgroundImageView=tempbackgroundImageView;
    
    [self addSubview:self.backgroundImageView];
    
    UILabel *tempbalanceLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 2, self.frame.size.width, 30.0)];
    self.balanceLbl=tempbalanceLbl;
    
    self.balanceLbl.font = [UIFont fontWithName:RepliconFontFamily size:27.0];
    self.balanceLbl.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    self.balanceLbl.adjustsFontSizeToFitWidth = NO;
    self.balanceLbl.textAlignment=NSTextAlignmentCenter;
    self.balanceLbl.backgroundColor=[UIColor clearColor];    [self addSubview:self.balanceLbl];
    
    self.balanceLbl.text=@"88.88";
    
    
    UILabel *temptypeLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 33, self.frame.size.width, 15.0)];
    self.typeLbl=temptypeLbl;
    
    self.typeLbl.font = [UIFont fontWithName:RepliconFontFamily size:12.0];
    self.typeLbl.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    self.typeLbl.textAlignment=NSTextAlignmentCenter;
    self.typeLbl.backgroundColor=[UIColor clearColor];
    [self addSubview:self.typeLbl];
    
    self.typeLbl.text=@"Vacation";
    
    
    UILabel *tempstatusLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 47, self.frame.size.width, 15.0)];
    self.statusLbl=tempstatusLbl;
    
    self.statusLbl.font = [UIFont fontWithName:RepliconFontFamily size:12.0];
    self.statusLbl.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    self.statusLbl.textAlignment=NSTextAlignmentCenter;
    self.statusLbl.backgroundColor=[UIColor clearColor];
    [self addSubview:self.statusLbl];

    self.statusLbl.text=@"Available";
    

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    // cancel any pending handleSingleTap messages 
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleSingleTap) object:nil];
    self.backgroundImageView.image=[Util thumbnailImage:BALANCE_BUTTON_BLUE];
    self.balanceLbl.textColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.typeLbl.textColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.statusLbl.textColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
     self.backgroundImageView.image=[Util thumbnailImage:BALANCE_BUTTON_BLUE];
    self.balanceLbl.textColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.typeLbl.textColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.statusLbl.textColor=[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
	[self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:0.35];
}    




#pragma mark Private

- (void)handleSingleTap {
    if ([delegate respondsToSelector:@selector(gotSingleTapForBookedTimeOffTileWithTag:)])
        [delegate gotSingleTapForBookedTimeOffTileWithTag:self.tag];
}





@end
