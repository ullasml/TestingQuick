#import "AmountCellView.h"
#import "AmountViewController.h"

@implementation AmountCellView
@synthesize fieldLable;
@synthesize amountDelegate;
@synthesize fieldText;
@synthesize fieldButton;
@synthesize numberKeyPad;


static int Max_Kilometers_Text_Length = 10;

- (void)addFieldLabelAndButton:(NSInteger)tagValue
                         width:(CGFloat)width
{

    if (fieldLable == nil)
    {
        self.fieldLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 6.0, 130, 30)];

    }
    fieldLable.backgroundColor = [UIColor clearColor];
    fieldLable.textColor = RepliconStandardBlackColor;
    fieldLable.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
    [self.contentView addSubview:fieldLable];

    if (tagValue == 0)
    {
        if (fieldButton == nil)
        {

            fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [fieldButton setFrame:CGRectMake(width - 170.0, 6.0, 160.0, 30.0)];

        }
        [fieldButton addTarget:self
                        action:@selector(buttonAction:withEvent:)
              forControlEvents:UIControlEventTouchUpInside];
        [fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight
                                                        size:RepliconFontSize_16]];
        [fieldButton setBackgroundColor:[UIColor clearColor]];
        [fieldButton setTag:tagValue];
        [fieldButton setTitleColor:RepliconStandardBlackColor
                          forState:UIControlStateNormal];
        [fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.contentView addSubview:fieldButton];
    }
    else
    {
        if (fieldText == nil)
        {


            UITextField *tempfieldText = [[UITextField alloc] initWithFrame:CGRectMake(width - 170.0, 6.0, 160.0, 30.0)];
            self.fieldText = tempfieldText;


        }
        fieldText.backgroundColor = [UIColor clearColor];
        fieldText.keyboardType = UIKeyboardTypeNumberPad;
        fieldText.borderStyle = UITextBorderStyleNone;
        fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
        fieldText.textAlignment = NSTextAlignmentRight;
        fieldText.textColor = RepliconStandardBlackColor;
        fieldText.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16];
        fieldText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        fieldText.tag = tagValue;
		fieldText.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		fieldText.delegate = self;
		[self.contentView addSubview:fieldText];
	}
}


#pragma mark TextFieldDelegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

	if ([textField isEqual:fieldText]) {
		/*
		 Show the numberKeyPad
		 */
		if (!self.numberKeyPad)
        {
			self.numberKeyPad = [NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:amountDelegate withMinus:NO andisDoneShown:NO withResignButton:NO];
			if ([textField textAlignment] == NSTextAlignmentRight)
            {
				[self.numberKeyPad.decimalPointButton setTag:333];
			}
		}
        else
        {
			//if we go from one field to another - just change the textfield, don't reanimate the decimal point button
			self.numberKeyPad.currentTextField = textField;
		}
	}
		//textField.textAlignment = NSTextAlignmentCenter;
	if ([textField textAlignment] == NSTextAlignmentRight)
    {
        if (![textField.text isKindOfClass:[NSNull class] ])
        {
            if ([textField.text length] > 1)
                if ([textField.text characterAtIndex:[textField.text length]-1] != ' ')
                {
                    [textField setText:[NSString stringWithFormat:@"%@ ",[textField text]]];
                }
        }

	}

    [amountDelegate performSelector:@selector(dehighLightCurrencyTappedRow) withObject:nil];
    [amountDelegate performSelector:@selector(dehighLightRateTappedRow) withObject:nil];
 //   [amountDelegate performSelector:@selector(pickerDone:) withObject:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if ([textField textAlignment] == NSTextAlignmentRight) {
        if (![textField.text isKindOfClass:[NSNull class] ])
        {
            if ([textField.text length] > 1) {

            }
        }

	}

	if( textField.tag==1)
    {
		[amountDelegate performSelector:@selector(setEnteredAmountValue:) withObject:textField.text];
        [amountDelegate performSelector:@selector(updateValues:) withObject:textField];
	}

	if (textField.tag==200 || textField.tag==100) {
		[amountDelegate performSelector:@selector(updateRatedExpenseData:) withObject:textField];
	}

	if (textField.tag>=1000) {
		[amountDelegate performSelector:@selector(taxAmountEditedByUser:) withObject:textField];
	}

	if (textField == numberKeyPad.currentTextField) {
		/*
		 Hide the number keypad
		 */
		[self.numberKeyPad removeButtonFromKeyboard];
		self.numberKeyPad = nil;
	}

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {


	textField.text = [Util removeCommasFromNsnumberFormaters:textField.text];

	if ([textField.text isEqualToString:RPLocalizedString(SELECT, @"") ] || [textField.text isEqualToString:@"0.00"])
    {
		textField.text=@"";
	}

	if( textField.tag!=100 && textField.tag!=200)
    {
		[amountDelegate performSelector:@selector(userSelectedTextField:) withObject:textField];
	}
    else
    {
		[amountDelegate performSelector:@selector(showKilometersOverLay:) withObject:textField];
	}

	if (numberKeyPad)
    {
		numberKeyPad.currentTextField = textField;
	}
	[amountDelegate performSelector:@selector(getTagFromTextFiled:) withObject:textField];

	return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

	if(textField.tag == 1|| textField.tag >= 1000){
        if (![textField.text isKindOfClass:[NSNull class] ])
        {
            if ([textField.text length]>= Max_Kilometers_Text_Length)
            {
                if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=10 )
                {
                    return NO;
                }
            }
        }

	}


	if (textField.tag==200 || textField.tag==100)
    {
        if (![textField.text isKindOfClass:[NSNull class] ])
        {
            if ([textField.text length]>= Max_Kilometers_Text_Length)
            {
                if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=10 )
                {
                    return NO;
                }
            }
        }

	}
	if ([textField textAlignment] == NSTextAlignmentRight) {
		[Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:2];
		return NO;
	}
	return YES;
}

-(void)buttonAction:(UIButton*)sender withEvent:(UIEvent*)event
{
	[amountDelegate performSelector:@selector(buttonActionsHandling::) withObject:sender withObject:event];
}
-(void)grayedOutRequiredCell
{
	[self.fieldLable setTextColor:RepliconStandardGrayColor];
	[self.fieldButton setTitleColor:RepliconStandardGrayColor forState:UIControlStateNormal];
	if (fieldText != nil) {
		[self.fieldText setTextColor:RepliconStandardGrayColor];
	}
	[self setUserInteractionEnabled:NO];
}





@end
