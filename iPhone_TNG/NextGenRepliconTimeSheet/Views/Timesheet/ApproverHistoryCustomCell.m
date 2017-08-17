//
//  ApproverHistoryCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 03/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ApproverHistoryCustomCell.h"
#define hours_details_hexcolor_code @"#838383"
#define time_details_hexcolor_code @"#333333"

@implementation ApproverHistoryCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)createCellLayoutInoutWidgetTitle:(NSString *)title andPaddingY:(float)yPadding andPaddingH:(float)hPadding andTotalHeightForTitleLable:(float)height
{
    float xOffset=10.0;
    float yOffset=12.0;
    float rightPadding=40.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, SCREEN_WIDTH-rightPadding, height)];
    [titleLabel setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setText:title];
	[titleLabel setNumberOfLines:100];
	[self.contentView addSubview:titleLabel];
    
    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-disclosureImage.size.width,yOffset+height/2-5, disclosureImage.size.width,disclosureImage.size.height)];
	[disclosureImageView setImage:disclosureImage];
    [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
	[self.contentView addSubview:disclosureImageView];
    
    UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, height+(yOffset*2), SCREEN_WIDTH, hPadding)];
    [statusView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
    [self.contentView addSubview:statusView];

}
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
