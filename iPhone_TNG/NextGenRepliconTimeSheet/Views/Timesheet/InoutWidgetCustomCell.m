//
//  InoutWidgetCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/08/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "InoutWidgetCustomCell.h"
#define hours_details_hexcolor_code @"#838383"
#define time_details_hexcolor_code @"#333333"
@implementation InoutWidgetCustomCell

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

-(void)createCellLayoutInoutWidgetTitle:(NSString *)title
                           regularHours:(NSString *)_regularHours
                             breakHours:(NSString *)_breakHours
                             timeoffHours:(NSString *)_timeoffHours
                         isLoadedWidget:(BOOL)isWidgetLoaded
                             andPaddingY:(float)yPadding
                            andPaddingH:(float)hPadding
                         shouldBreakBeShown:(BOOL)shouldBreakBeShown
                      shouldTimeoffBeShown:(BOOL)shouldTimeoffBeShown
                   isPunchWidget:(BOOL)isPunchWidget
{
    float xOffset=10.0;
    float yOffset=15.0;
    float rightPadding = 20.0;
    float titleRightPadding = 100.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, SCREEN_WIDTH-(2*rightPadding), 20.0)];
    [titleLabel setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setText:title];
	[titleLabel setNumberOfLines:1];
    [titleLabel setAccessibilityIdentifier:@"widget_title_label"];

	[self.contentView addSubview:titleLabel];
    
    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-disclosureImage.size.width,20, disclosureImage.size.width,disclosureImage.size.height)];
	[disclosureImageView setImage:disclosureImage];
    [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
	[self.contentView addSubview:disclosureImageView];
    
    float ySeparatorTimeoff=0;
    if (isWidgetLoaded)
    {
        float xRegularLabel=20;
        float yRegularLabel=titleLabel.frame.origin.y+titleLabel.frame.size.height+15;
        UILabel *regularLabel = [[UILabel alloc] initWithFrame:CGRectMake(xRegularLabel, yRegularLabel, SCREEN_WIDTH-(titleRightPadding), 20.0)];
        [regularLabel setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
        [regularLabel setBackgroundColor:[UIColor clearColor]];
        [regularLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [regularLabel setTextAlignment:NSTextAlignmentLeft];
        [regularLabel setText:RPLocalizedString(WORK_HOURS_TITLE, @"")];
        [regularLabel setNumberOfLines:1];
        [self.contentView addSubview:regularLabel];
        
        
        UILabel *regularHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50-rightPadding, yRegularLabel, 50.0, 20.0)];
        [regularHoursLabel setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
        [regularHoursLabel setBackgroundColor:[UIColor clearColor]];
        [regularHoursLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [regularHoursLabel setTextAlignment:NSTextAlignmentRight];
        [regularHoursLabel setAccessibilityIdentifier:@"widget_work_hours_label"];


        NSArray *arr=[_regularHours componentsSeparatedByString:[Util detectDecimalMark]];
        
        
        if ([[arr objectAtIndex:1]length]==1)
        {
            [regularHoursLabel setText:[NSString stringWithFormat:@"%@%@",_regularHours,@"0"]];
        }
        else
        {
            [regularHoursLabel setText:[NSString stringWithFormat:@"%@",_regularHours]];
        }
        
        [regularHoursLabel setNumberOfLines:1];
        [self.contentView addSubview:regularHoursLabel];
        
        ySeparatorTimeoff=regularLabel.frame.origin.y+regularLabel.frame.size.height+5;
        if (shouldBreakBeShown)
        {
            float xSeparator=20;
            float ySeparator=regularLabel.frame.origin.y+regularLabel.frame.size.height+5;
            UIView *viewSeparator=[[UIView alloc]initWithFrame:CGRectMake(xSeparator, ySeparator, SCREEN_WIDTH-xSeparator, 1)];
            [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
            [self.contentView addSubview:viewSeparator];
            
            
            float xBreakLabel=20;
            float yreakLabel=viewSeparator.frame.origin.y+viewSeparator.frame.size.height+7;
            
            UILabel *breakLabel = [[UILabel alloc] initWithFrame:CGRectMake(xBreakLabel, yreakLabel, SCREEN_WIDTH-(titleRightPadding), 20.0)];
            [breakLabel setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
            [breakLabel setBackgroundColor:[UIColor clearColor]];
            [breakLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [breakLabel setTextAlignment:NSTextAlignmentLeft];
            [breakLabel setText:RPLocalizedString(BREAK_HOURS_TITLE, @"")];
            [breakLabel setNumberOfLines:1];
            [self.contentView addSubview:breakLabel];
            
            
            UILabel *breakHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50-rightPadding, yreakLabel, 50.0, 20.0)];
            [breakHoursLabel setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
            [breakHoursLabel setBackgroundColor:[UIColor clearColor]];
            [breakHoursLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [breakHoursLabel setTextAlignment:NSTextAlignmentRight];
            
            NSArray *arr=[_breakHours componentsSeparatedByString:[Util detectDecimalMark]];
            
            
            if ([[arr objectAtIndex:1]length]==1)
            {
                [breakHoursLabel setText:[NSString stringWithFormat:@"%@%@",_breakHours,@"0"]];
            }
            else
            {
                [breakHoursLabel setText:[NSString stringWithFormat:@"%@",_breakHours]];
            }
           
            [breakHoursLabel setNumberOfLines:1];
            [self.contentView addSubview:breakHoursLabel];
            
            ySeparatorTimeoff=breakHoursLabel.frame.origin.y+breakHoursLabel.frame.size.height+5;
        }
        
        if (shouldTimeoffBeShown)
        {
            float xSeparator=20;
            UIView *viewSeparator=[[UIView alloc]initWithFrame:CGRectMake(xSeparator, ySeparatorTimeoff, SCREEN_WIDTH-xSeparator, 1)];
            [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
            [self.contentView addSubview:viewSeparator];
            
            
            float xBreakLabel=20;
            float yreakLabel=viewSeparator.frame.origin.y+viewSeparator.frame.size.height+7;
            
            UILabel *timeoffLabel = [[UILabel alloc] initWithFrame:CGRectMake(xBreakLabel, yreakLabel, SCREEN_WIDTH-(titleRightPadding), 20.0)];
            [timeoffLabel setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
            [timeoffLabel setBackgroundColor:[UIColor clearColor]];
            [timeoffLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [timeoffLabel setTextAlignment:NSTextAlignmentLeft];
            [timeoffLabel setText:RPLocalizedString(TIMEOFF_HOURS_TITLE, @"")];
            [timeoffLabel setNumberOfLines:1];
            [self.contentView addSubview:timeoffLabel];
            
            
            UILabel *timeoffHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50-rightPadding, yreakLabel, 50.0, 20.0)];
            [timeoffHoursLabel setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
            [timeoffHoursLabel setBackgroundColor:[UIColor clearColor]];
            [timeoffHoursLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [timeoffHoursLabel setTextAlignment:NSTextAlignmentRight];
            
            NSArray *arr=[_timeoffHours componentsSeparatedByString:[Util detectDecimalMark]];
            
            
            if ([[arr objectAtIndex:1]length]==1)
            {
                [timeoffHoursLabel setText:[NSString stringWithFormat:@"%@%@",_timeoffHours,@"0"]];
            }
            else
            {
                [timeoffHoursLabel setText:[NSString stringWithFormat:@"%@",_timeoffHours]];
            }
           
            [timeoffHoursLabel setNumberOfLines:1];
            [timeoffHoursLabel setAccessibilityIdentifier:@"widget_timeoff_hours_label"];
            [self.contentView addSubview:timeoffHoursLabel];
        }

        
    }
    UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, yPadding, SCREEN_WIDTH, hPadding)];
    [statusView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
    [self.contentView addSubview:statusView];
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
