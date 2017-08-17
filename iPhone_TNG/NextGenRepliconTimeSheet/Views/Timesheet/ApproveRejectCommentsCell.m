//
//  ApproveRejectCommentsCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 04/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ApproveRejectCommentsCell.h"

@implementation ApproveRejectCommentsCell
@synthesize delegate;
#define hours_details_hexcolor_code @"#838383"
#define time_details_hexcolor_code @"#333333"


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
-(void)createCellLayoutWidgetTitle:(NSString *)title andComments:(NSString *)comments andVariableTextHeight:(float)height
{
    BOOL isWidgetLoaded=YES;
    height=height+15;
    if (comments==nil||[comments isKindOfClass:[NSNull class]]||[comments isEqualToString:@""]) {
        isWidgetLoaded=NO;
        height=0;
    }
    float xOffset=10.0;
    float yOffset=15.0;
    float LABEL_PADDING=15;
    float TITLE_HEIGHT=44;
    
    UIView *commentsView=[[UIView alloc]initWithFrame:CGRectMake(xOffset, yOffset, SCREEN_WIDTH-20, height+TITLE_HEIGHT)];
    commentsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    commentsView.layer.borderWidth = 1.0f;
    [commentsView setBackgroundColor:RepliconStandardBackgroundColor];
    CGRect frame=CGRectMake(0,12, 210.0, 20.0);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, LABEL_PADDING, 0)];
    [titleLabel setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[titleLabel setTextAlignment:NSTextAlignmentLeft];
	[titleLabel setText:title];
	[titleLabel setNumberOfLines:1];
    [commentsView addSubview:titleLabel];
    
    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30-disclosureImage.size.width,15, disclosureImage.size.width,disclosureImage.size.height)];
	[disclosureImageView setImage:disclosureImage];
    [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
	[commentsView addSubview:disclosureImageView];
    
    [self.contentView addSubview:commentsView];
    
    if (isWidgetLoaded)
    {
        float xSeparator=15+LABEL_PADDING;
        float ySeparator=TITLE_HEIGHT+yOffset;
        UIView *viewSeparator=[[UIView alloc]initWithFrame:CGRectMake(xSeparator, ySeparator, SCREEN_WIDTH-20, 1)];
        [viewSeparator setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:viewSeparator];
        
        CGRect commentsFrame=CGRectMake(xOffset, ySeparator+5, 265, height);
        UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectInset(commentsFrame, LABEL_PADDING, 0)];
        [commentsLabel setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
        [commentsLabel setBackgroundColor:[UIColor clearColor]];
        [commentsLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [commentsLabel setTextAlignment:NSTextAlignmentLeft];
        [commentsLabel setText:comments];
        [commentsLabel setNumberOfLines:0];
        [self.contentView addSubview:commentsLabel];
    }
    UIImage *normalImg = [Util thumbnailImage:REJECT_UNPRESSED_IMG];
    UIImage *highlightedImg = [Util thumbnailImage:REJECT_PRESSED_IMG];

    float buttonPosition = (SCREEN_WIDTH - (normalImg.size.width*2))/3;

    UIButton *rejectButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [rejectButton setBackgroundImage:normalImg forState:UIControlStateNormal];
    [rejectButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
    [rejectButton setTitle:RPLocalizedString(REJECT_TEXT, REJECT_TEXT) forState:UIControlStateNormal];
    [rejectButton setFrame:CGRectMake(buttonPosition, commentsView.frame.origin.y+commentsView.frame.size.height+20, normalImg.size.width, normalImg.size.height)];
    [rejectButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
    [rejectButton setTag:REJECT_BUTTON_TAG];
    [rejectButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
    [self.contentView addSubview:rejectButton];
    
    
    UIButton *approveButton =[UIButton buttonWithType:UIButtonTypeCustom];
    normalImg = [Util thumbnailImage:APPROVE_UNPRESSED_IMG];
    highlightedImg = [Util thumbnailImage:APPROVE_PRESSED_IMG];
    UIImage *blueImage = [Util thumbnailImage:LoginButtonImage];
    UIImage *blueImageHightLIghted  = [Util thumbnailImage:LoginButtonSelectedImage];
    [approveButton setBackgroundImage:blueImage forState:UIControlStateNormal];
    [approveButton setBackgroundImage:blueImageHightLIghted forState:UIControlStateHighlighted];
    [approveButton setTitle:RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT) forState:UIControlStateNormal];
    [approveButton setFrame:CGRectMake(((buttonPosition * 2) + rejectButton.size.width), commentsView.frame.origin.y+commentsView.frame.size.height+20, normalImg.size.width, normalImg.size.height)];
    [approveButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
    [approveButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
    [approveButton setTag:APPROVE_BUTTON_TAG];
    [self.contentView addSubview:approveButton];
    

}
-(void)handleButtonClicks:(id)sender
{
    
    UIButton *btn=(UIButton *)sender;
    
    if ([delegate respondsToSelector:@selector(handleButtonClickForFooterView:)])
    {
        if ([delegate isKindOfClass:[WidgetTSViewController class]])
        {
            [delegate handleButtonClickForFooterView:btn.tag];
        }
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
