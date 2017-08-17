//
//  BookedTimeOffCellView.m
//  Replicon
//
//  Created by Dipta Rakshit on 6/27/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "BookedTimeOffCellView.h"
#import "Constants.h"
#import "Util.h"

@implementation BookedTimeOffCellView
@synthesize timeOffTypelabel;
@synthesize statusImgView;
@synthesize datelabel;
@synthesize numberOfHourslabel;
#define timeOff_details_hexcolor_code @"#333333"
#define date_details_hexcolor_code @"#666666"
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)bookedTimeOffCelllayout:(NSString *)timeOfftype totalHrs:(NSString *)timestr date:(NSString *)dateStr status:(UIImage *)lowerleftImage approvalStatus:(NSString *)approvalStatus{
	if (self.timeOffTypelabel == nil) {
		UILabel *temptimeOffTypelabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 4.0, 180.0, 20.0)];
        self.timeOffTypelabel=temptimeOffTypelabel;
        
	}
	[self.timeOffTypelabel setTextColor:[Util colorWithHex:timeOff_details_hexcolor_code alpha:1]];
	[self.timeOffTypelabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[self.timeOffTypelabel setTextAlignment:NSTextAlignmentLeft];
	[self.timeOffTypelabel setBackgroundColor:[UIColor clearColor]];
    [self.timeOffTypelabel setHighlightedTextColor:[UIColor whiteColor]];
	[self.timeOffTypelabel setText:timeOfftype];
	[self.contentView addSubview:self.timeOffTypelabel];
	
	
	
	if (self.statusImgView==nil) {
        UIImageView *lowerLeftImageView = [[UIImageView alloc] init];
        self.statusImgView=lowerLeftImageView;
        
	}
    else
    {
        for (UIView *subviews in self.statusImgView.subviews)
        {
            [subviews removeFromSuperview];
        }
    }
    
   
    
	self.statusImgView.frame=CGRectMake(10, 28.0, lowerleftImage.size.width,lowerleftImage.size.height);
    [self.statusImgView setImage:lowerleftImage];
    
    UILabel *statusLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, statusImgView.frame.size.width, statusImgView.frame.size.height)];
    [statusLbl setTextAlignment:NSTextAlignmentCenter];
    [statusLbl setFont:[UIFont fontWithName:RepliconFontFamily size:11.0]];
    [statusLbl setBackgroundColor:[UIColor clearColor]];
//    if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
//    {
//        statusLbl.text=RPLocalizedString(@"Waiting", @"");
//    }
//    else
//    {
        statusLbl.text=RPLocalizedString(approvalStatus, @"");
//    }
    [statusImgView addSubview:statusLbl];
    [self.contentView addSubview:self.statusImgView];
	
	if (self.datelabel==nil) {
		UILabel *tempdatelabel = [[UILabel alloc] initWithFrame:CGRectMake(143, 28, 160, 16)]; //60//Implemented As Per US7524
        self.datelabel=tempdatelabel;
        
	}
	
	[self.datelabel setBackgroundColor:[UIColor clearColor]];
    [self.datelabel setHighlightedTextColor:[UIColor whiteColor]];
	[self.datelabel setTextColor:[Util colorWithHex:date_details_hexcolor_code alpha:1]];
	[self.datelabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[self.datelabel setTextAlignment:NSTextAlignmentRight];
	[self.datelabel setText:dateStr];
	[self.contentView addSubview:self.datelabel];
	
	if (self.numberOfHourslabel==nil) {
		UILabel *tempnumberOfHourslabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 6, 103, 16)];
        self.numberOfHourslabel=tempnumberOfHourslabel;
        
	}
	
	[self.numberOfHourslabel setTextColor:[Util colorWithHex:timeOff_details_hexcolor_code alpha:1]];
	[self.numberOfHourslabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[self.numberOfHourslabel setTextAlignment:NSTextAlignmentRight];
	[self.numberOfHourslabel setBackgroundColor:[UIColor clearColor]];
    [self.numberOfHourslabel setHighlightedTextColor:[UIColor whiteColor]];
	[self.numberOfHourslabel setText:timestr];
	[self.contentView addSubview:self.numberOfHourslabel];
    
    
    //DISCLOSURE IMAGE VIEW
    
    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(307, 22, disclosureImage.size.width,disclosureImage.size.height)];
	[disclosureImageView setImage:disclosureImage];
    [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
	[self.contentView addSubview:disclosureImageView];
    
	
    //LOWER IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 56, 320.0,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [self.contentView bringSubviewToFront:lineImageView];
	[self.contentView addSubview:lineImageView];
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
