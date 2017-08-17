//
//  WidgetAttestationCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 6/23/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "WidgetAttestationCell.h"

@interface WidgetAttestationCell ()

@property(nonatomic)UILabel *radioButtonText;

@end

@implementation WidgetAttestationCell

#define hours_details_hexcolor_code @"#838383"
#define time_details_hexcolor_code @"#333333"

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)createCellLayoutWidgetAttestation:(NSString *)title andDescription:(NSString *)description andTitleTextHeight:(float)titleHeight anddescriptionTextHeight:(float)descriptionHeight showPadding:(BOOL)showPadding andAttestationStatus:(BOOL)isSelected andTimeSheetStatus:(NSString *)timeSheetStatus
{
    float xOffset=10.0;
    float yOffset=15.0;
    float xSeparator=0.0;
    float ySeparator=yOffset;
    float rightPadding=40.0;
    int yPadding=10.0;
    
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
        [descriptionLabel setNumberOfLines:0];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentJustified;
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:description
                                                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                 paragraphStyle, NSParagraphStyleAttributeName ,
                                                                                 [NSNumber numberWithFloat:0],NSBaselineOffsetAttributeName,
                                                                                 nil]];

        [descriptionLabel setAttributedText:string];
        [self.contentView addSubview:descriptionLabel];
        
        yPadding= ydescriptionLabel+descriptionHeight+10;
    }

    
    
    
    UIImage *radioDeselectedImage=nil;
    NSString *disclaimerAccepted=nil;
    if (!isSelected)
    {
        radioDeselectedImage = [Util thumbnailImage:CheckBoxDeselectedImage];
        disclaimerAccepted=RPLocalizedString(@"Accept", @"");
    }
    else
    {
        radioDeselectedImage = [Util thumbnailImage:CheckBoxSelectedImage];
        disclaimerAccepted=RPLocalizedString(@"Accepted", @"");
    }
    UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    [radioButton setFrame:CGRectMake(4.0,
                                          ydescriptionLabel+descriptionHeight+5,
                                          radioDeselectedImage.size.width+20.0,
                                          radioDeselectedImage.size.height+19.0)];
    
    
    
    [radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
    //[self.radioButton setImage:radioSelected forState:UIControlStateHighlighted];
    [radioButton setBackgroundColor:[UIColor clearColor]];
    
    [radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    if ([timeSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ] || [timeSheetStatus isEqualToString:APPROVED_STATUS])
    {
        [radioButton setUserInteractionEnabled:NO];
    }
    else
    {
        [radioButton setUserInteractionEnabled:YES];
    }
    
    
    [radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -6, 0.0)];
    
    
    [radioButton addTarget:self action:@selector(selectRadioButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:radioButton];
    
    self.radioButtonText=[[UILabel alloc]initWithFrame:CGRectMake(radioDeselectedImage.size.width+20.0,
                                                                      ydescriptionLabel+25.0+descriptionHeight,
                                                                      ((SCREEN_WIDTH-20)-(radioDeselectedImage.size.width+10.0)),20.0)];
                              
    self.radioButtonText.text=disclaimerAccepted ;
    self.radioButtonText.textColor=RepliconStandardBlackColor;
    [self.radioButtonText setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [self.radioButtonText setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.radioButtonText];
    
    
    
    if (showPadding)
    {
        UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, radioButton.frame.origin.y+radioButton.frame.size.width+10, SCREEN_WIDTH, 20)];
        [statusView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
        [self.contentView addSubview:statusView];
    }
    
}

-(void)selectRadioButton:(id)sender {
    
    UIImage *currentRadioButtonImage= [sender imageForState:UIControlStateNormal];
    BOOL isAttestationAccepted=NO;
    if (currentRadioButtonImage == [Util thumbnailImage:CheckBoxSelectedImage]) {
        UIImage *deselectedRadioImage = [Util thumbnailImage:CheckBoxDeselectedImage];
        if (sender != nil) {
            [sender setImage:deselectedRadioImage forState:UIControlStateNormal];
            [sender setImage:deselectedRadioImage forState:UIControlStateHighlighted];
            [self.radioButtonText setText:RPLocalizedString(@"Accept", @"") ];
            isAttestationAccepted=NO;
        }
    }
    else
    {
        UIImage *selectedRadioImage = [Util thumbnailImage:CheckBoxSelectedImage];
        if (sender != nil) {
            [sender setImage:selectedRadioImage forState:UIControlStateNormal];
            [sender setImage:selectedRadioImage forState:UIControlStateHighlighted];
            [self.radioButtonText setText:RPLocalizedString(@"Accepted", @"") ];
            isAttestationAccepted=YES;
        }
    }
    
    if ([self.widgetAttestationCellDelegate respondsToSelector:@selector(widgetAttestationCell:isAttestationAccepted:)]) {
        [self.widgetAttestationCellDelegate widgetAttestationCell:self isAttestationAccepted:isAttestationAccepted];
    }
    
}

@end
