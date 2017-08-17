//
//  WidgetNoticeCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 24/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "WidgetNoticeCell.h"
#define hours_details_hexcolor_code @"#838383"
#define time_details_hexcolor_code @"#333333"
@implementation WidgetNoticeCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}
-(void)createCellLayoutWidgetTitle:(NSString *)title andDescription:(NSString *)description andTitleTextHeight:(float)titleHeight anddescriptionTextHeight:(float)descriptionHeight showPadding:(BOOL)showPadding
{
    float xOffset=10.0;
    float yOffset=15.0;
    
    float xSeparator=0.0;
    float ySeparator=yOffset;
    
    int yPadding=10.0;
    float rightPadding=40.0;
    
    float ydescriptionLabel=yOffset;
    
    if(title!=nil && ![title isKindOfClass:[NSNull class]])
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, SCREEN_WIDTH-rightPadding, titleHeight)];
        [titleLabel setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setText:title];
        [titleLabel setNumberOfLines:100];
        [self.contentView addSubview:titleLabel];
        
       
        
         yPadding=yOffset+titleHeight+10;
        
        if(description!=nil && ![description isKindOfClass:[NSNull class]])
        {
            xSeparator=20;
            ySeparator=titleLabel.frame.origin.y+titleLabel.frame.size.height+yOffset;
            UIView *viewSeparator=[[UIView alloc]initWithFrame:CGRectMake(xSeparator, ySeparator, SCREEN_WIDTH-xSeparator, 1)];
            [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
            [self.contentView addSubview:viewSeparator];
            
             yPadding=ySeparator+yOffset+titleHeight+10;
             ydescriptionLabel=ySeparator+yOffset;
        }
        
       
    }
    
    
    if(description!=nil && ![description isKindOfClass:[NSNull class]])
    {
        float xdescriptionLabel=20;
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(xdescriptionLabel, ydescriptionLabel, SCREEN_WIDTH-(2*xdescriptionLabel), descriptionHeight)];
        [descriptionLabel setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [descriptionLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [descriptionLabel setTextAlignment:NSTextAlignmentLeft];
        [descriptionLabel setText:description];
        [descriptionLabel setNumberOfLines:100];
        [self.contentView addSubview:descriptionLabel];
        
         yPadding= ydescriptionLabel+descriptionHeight+10;
    }
    

    
    if (showPadding)
    {
        UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, yPadding, SCREEN_WIDTH, 20)];
        [statusView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
        [self.contentView addSubview:statusView];
    }
    

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
