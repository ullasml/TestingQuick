//
//  DailyWidgetCutomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 1/7/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "DailyWidgetCutomCell.h"
#import "DailyWidgetDayLevelViewController.h"

#define Right_Padding 40
@implementation DailyWidgetCutomCell

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
-(void)createCellLayoutWidgetTitle:(NSString *)title andDescription:(NSString *)description andTitleTextHeight:(float)titleHeight anddescriptionTextHeight:(float)descriptionHeight isNumericFieldType:(BOOL)isNumeric andSelectedRow:(NSInteger)row
{
    float xOffset=12.0;
    float yOffset=15.0;
    float paddingOffset=10.0;

    if(title!=nil && ![title isKindOfClass:[NSNull class]])
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, SCREEN_WIDTH-xOffset-Right_Padding, titleHeight)];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setText:title];
        [titleLabel setNumberOfLines:100];
        [self.contentView addSubview:titleLabel];

    }


    if(description!=nil && ![description isKindOfClass:[NSNull class]])
    {
        if (!isNumeric)
        {
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset+titleHeight+paddingOffset, SCREEN_WIDTH-xOffset-Right_Padding, descriptionHeight)];
            [descriptionLabel setTextColor:[UIColor blackColor]];
            [descriptionLabel setBackgroundColor:[UIColor clearColor]];
            [descriptionLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_13]];
            [descriptionLabel setTextAlignment:NSTextAlignmentLeft];
            [descriptionLabel setText:description];
            [descriptionLabel setNumberOfLines:100];
            [descriptionLabel setAccessibilityLabel:@"desc_lbl"];
            [descriptionLabel setAccessibilityValue:description];
            [self.contentView addSubview:descriptionLabel];
        }
        else
        {
            UITextField *fieldValue = [[UITextField alloc] initWithFrame:CGRectMake(xOffset, yOffset+titleHeight+paddingOffset, SCREEN_WIDTH-xOffset-Right_Padding, descriptionHeight)];
            fieldValue.clearButtonMode = UITextFieldViewModeWhileEditing;
            [fieldValue setTextColor:RepliconStandardBlackColor];
            [fieldValue setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_13]];
            [fieldValue setTextAlignment:NSTextAlignmentLeft];
            [fieldValue setBackgroundColor:[UIColor clearColor]];
            fieldValue.keyboardAppearance = UIKeyboardAppearanceDefault;
            fieldValue.returnKeyType = UIReturnKeyDone;
            fieldValue.borderStyle = UITextBorderStyleNone;
            [fieldValue setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [fieldValue setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
            [fieldValue setKeyboardType:UIKeyboardTypeDecimalPad];
            [fieldValue setTag:row];
            [fieldValue setDelegate:self];
            fieldValue.text=description;
            [fieldValue setAccessibilityLabel:@"daily_widget_numeric_fld"];
            [fieldValue setAccessibilityValue:description];
            [self.contentView addSubview:fieldValue];
        }

    }


    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];
    self.disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-disclosureImage.size.width,(yOffset+titleHeight+yOffset+descriptionHeight+yOffset)/2-5, disclosureImage.size.width,disclosureImage.size.height)];
    [self.disclosureImageView setImage:disclosureImage];
    [self.disclosureImageView setHighlightedImage:disclosureHighlightedImage];
    [self.contentView addSubview:self.disclosureImageView];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - UITEXTFIELD CALLBACKS

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate isKindOfClass:[DailyWidgetDayLevelViewController class]])
    {
        DailyWidgetDayLevelViewController *dailyWidgetDayLevelViewController = (DailyWidgetDayLevelViewController *)self.delegate;
        [dailyWidgetDayLevelViewController updateSelectedOEFObject:(int)textField.tag];
    }
    textField.hidden=NO;
    if ([textField.text isEqualToString:RPLocalizedString(DAILY_WIDGET_PLACEHOLDER_NUMERIC_OEF, @"") ])
    {
        textField.text=@"";
    }


    if (!self.numberKeyPad)
    {
        self.numberKeyPad.isDonePressed=NO;
        self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:self.delegate withMinus:NO andisDoneShown:YES withResignButton:NO];
        if ([textField textAlignment] == NSTextAlignmentLeft)
        {
            [self.numberKeyPad.decimalPointButton setTag:333];
        }
    }
    else
    {
        //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
        self.numberKeyPad.currentTextField = textField;
    }

    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentLeft)
    {
        [Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:2.0];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.numberKeyPad.currentTextField) {
        /*
         Hide the number keypad
         */
        [self.numberKeyPad removeButtonFromKeyboard];


        if ([self.numberKeyPad isDonePressed])
        {
            if([textField.text length] > 0)
            {
                [self updateOEFNumber:textField];
            }
            if ([textField.text length] == 0 ){

                [self updateOEFNumber:textField];

            }
            self.numberKeyPad.isDonePressed=NO;

        }
        else
        {
            if([textField.text length] > 0)
            {
                textField.text=[Util getRoundedValueFromDecimalPlaces:[textField.text newDoubleValue] withDecimalPlaces:2.0];
                [self updateOEFNumber:textField];
            }
        }

        self.numberKeyPad = nil;

    }


    if ([textField.text length] == 0 )
    {
        [self updateOEFNumber:textField];

    }

}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}
-(void)updateOEFNumber:(UITextField *)oefNumericTextField
{
    if ([self.delegate isKindOfClass:[DailyWidgetDayLevelViewController class]])
    {
        DailyWidgetDayLevelViewController *dailyWidgetDayLevelViewController = (DailyWidgetDayLevelViewController *)self.delegate;
        [dailyWidgetDayLevelViewController updateOEFNumber:oefNumericTextField];
    }

    
}

@end
