#import "ExpenseEntryCustomCell.h"
#import "Util.h"
#import "Constants.h"
#import "ExpenseEntryViewController.h"
#import "AppDelegate.h"
#import "UIView+Additions.h"

@implementation ExpenseEntryCustomCell
@synthesize fieldName;
@synthesize expenseSwitch;
@synthesize expenseEntryCellDelegate;
@synthesize fieldText;
@synthesize amountTextField;
@synthesize fieldButton;
@synthesize numberKeyPad;
@synthesize tagIndex;
@synthesize decimalPlaces;
@synthesize indexPath;
@synthesize dataObj;
@synthesize canNotEdit;

#define Each_Cell_Row_Height_44 44.0
#define OffSetFor4 -90
#define OffSetFor5 0

- (id)initWithStyle:(enum UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              width:(CGFloat)width {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame = self.frame;
        frame.size.width = width;
        self.frame = frame;
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }

        self.clipsToBounds = YES;
    }

    return self;
}

-(void)addFieldAtIndex:(NSIndexPath *)_indexPath withTagIndex:(NSInteger)_tagIndex withObj:(NSMutableDictionary *)_dataObj
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);

    [self setIndexPath: _indexPath];
	[self setTagIndex: _tagIndex];
	[self setDataObj: _dataObj];

    CGSize valueSize;
    CGSize nameSize;
    NSString *defaultName= dataObj[@"fieldName"];
    if (defaultName)
    {

        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:defaultName];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        nameSize = [attributedString boundingRectWithSize:CGSizeMake(150, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (nameSize.width==0 && nameSize.height ==0)
        {
            nameSize=CGSizeMake(11.0, 18.0);
        }
    }

    NSString *defaultValue=[dataObj objectForKey:@"defaultValue"];
    if (defaultValue)
    {

        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:defaultValue];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        valueSize = [attributedString boundingRectWithSize:CGSizeMake(150, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (valueSize.width==0 && valueSize.height ==0)
        {
            valueSize=CGSizeMake(11.0, 18.0);
        }

    }

    float heightNam=Each_Cell_Row_Height_44;
	if (fieldName==nil)
    {

        if (nameSize.height>Each_Cell_Row_Height_44)
        {
            heightNam=nameSize.height+38;
        }
		UILabel *tempfieldName = [[UILabel alloc] initWithFrame:CGRectMake(12,0, width - 200, heightNam)];
        self.fieldName=tempfieldName;

	}
    [fieldName setFrame:CGRectMake(12,0, 148, heightNam)];
	[fieldName setText:[dataObj objectForKey: @"fieldName"]];
    [fieldName setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
    [fieldName setTextColor:RepliconStandardBlackColor];
    [fieldName setNumberOfLines:100];

	if (fieldButton == nil)
    {
        float height=Each_Cell_Row_Height_44;
        if (valueSize.height>Each_Cell_Row_Height_44)
        {
            height=valueSize.height+38;
        }
        UILabel *tempfieldName = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 0, width - 175, height)];
        self.fieldButton=tempfieldName;
        [fieldButton setNumberOfLines:100];

	}

	float heightOfText=0.0;
    float heightValue=valueSize.height+38;
    float heightName=nameSize.height+38;
    if (heightValue> Each_Cell_Row_Height_44 || heightName>Each_Cell_Row_Height_44)
    {
        if (heightValue>heightName)
        {
            CGRect frame=self.fieldName.frame; // setting frame for the left side
            frame.origin.y=0;
            if (heightValue>=92)
            {
                frame.size.height=heightValue-10;
            }
            else
            {
                frame.size.height=heightValue-28;
            }

            heightOfText=heightValue;
            self.fieldName.frame=frame;
            
            CGRect frame1=self.fieldButton.frame; // setting frame for the right side
            frame1.origin.y=0;
            if (heightValue>=92)
            {
                frame1.size.height=heightValue-10;
            }
            else
            {
                frame1.size.height=heightValue-28;
            }
             self.fieldButton.frame=frame1;
            
        }
        else
        {
            CGRect frame=self.fieldName.frame; // setting frame for the left side
            frame.origin.y=0;
            frame.size.height=heightName-16;
             self.fieldName.frame=frame;
            
            CGRect frame1=self.fieldButton.frame;
            frame1.origin.y=0;
            frame1.size.height=heightName-16;
            heightOfText=heightName;
            self.fieldButton.frame=frame1;
            self.fieldText.frame=frame1;
        }
    }
    else
    {
        CGRect frameValue=self.fieldButton.frame;
        frameValue.origin.y=0;
        frameValue.size.height=Each_Cell_Row_Height_44;
        self.fieldButton.frame=frameValue;

        CGRect frameName=self.fieldName.frame;
        frameName.origin.y=0;
        frameName.size.height=Each_Cell_Row_Height_44;
        self.fieldName.frame=frameName;
        heightOfText=Each_Cell_Row_Height_44;

    }


	if ([[dataObj objectForKey:@"fieldType"]isEqualToString: NUMERIC_KEY_PAD])
    {
		[self addTextFieldsForTextUdfsAtIndexRow:tagIndex withHeight:heightOfText];
        CGRect frameText=self.fieldText.frame;
        frameText.origin.y=0;
        frameText.size.height=heightName-16;
        self.fieldText.frame=frameText;
		if ([[dataObj objectForKey:@"defaultValue"] isKindOfClass:[NSNumber class]])
        {
			[fieldText setText:[NSString stringWithFormat:@"%@",[dataObj objectForKey:@"defaultValue"]]];
		}
        else
        {
			[fieldText setText:[dataObj objectForKey:@"defaultValue"]];
		}

		decimalPlaces=0;
		if ([dataObj objectForKey:@"defaultDecimalValue"]!=nil && !([[dataObj objectForKey:@"defaultDecimalValue"] isKindOfClass:[NSNull class]])) {
			decimalPlaces=[[dataObj objectForKey:@"defaultDecimalValue"]intValue];
		}

		[fieldButton setHidden:YES];
		[fieldText setHidden:NO];
		if (expenseSwitch !=nil)
        {
			[expenseSwitch setHidden:YES];
		}

	}
    else
    {
        [fieldButton setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
        [fieldButton setTextColor:RepliconStandardBlackColor];
		[fieldButton setTextAlignment:NSTextAlignmentRight];
		[fieldButton setEnabled:YES];
		[fieldButton setTag: tagIndex];
		[fieldButton setUserInteractionEnabled:YES];
		[fieldButton setHidden:NO];
		[fieldText setHidden:YES];
		if (expenseSwitch != nil) {
			[expenseSwitch setHidden:YES];
		}
	}




	//Added below condition to remove image name for checkmark field.
	if ([[dataObj objectForKey:@"fieldType"]isEqualToString: CHECK_MARK])
    {

		[fieldButton setHidden:YES];
		[fieldText setHidden:YES];

        self.expenseSwitch = [[UISwitch alloc] init];
        self.expenseSwitch.onTintColor = [Util colorWithHex:@"#007AC9" alpha:1.0f];

        CGRect f = self.expenseSwitch.frame;
        f.origin.x = width - 10.0f - CGRectGetWidth(f);
        f.origin.y = (height - CGRectGetHeight(f))  / 2.0f;
        self.expenseSwitch.frame = f;

        [self.expenseSwitch setTag:_indexPath.row];
		[self.expenseSwitch addTarget:self
                          action:@selector(switchChanged:)
                forControlEvents:UIControlEventValueChanged];
		if ([[dataObj objectForKey: @"defaultValue"] isEqualToString:Check_ON_Image])
        {
			[self.expenseSwitch setOn:YES];
		}
        else
        {
			[self.expenseSwitch setOn:NO];
		}

        [self.contentView addSubview:self.expenseSwitch];

	}

	[fieldName setBackgroundColor:[UIColor clearColor]];
	[fieldButton setBackgroundColor:[UIColor clearColor]];
	[fieldText setBackgroundColor:[UIColor clearColor]];
	[expenseSwitch setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:fieldName];
	[self.contentView addSubview:fieldButton];
}
-(void)switchChanged:(UISwitch*)sender
{
    int i=0;
	if ([sender isOn])
    {
        i=1;
		[[self dataObj] setObject:Check_ON_Image forKey:@"defaultValue"];
        //[self enableRequiredCell];  //Commented as per DE16320
	}
    else
    {
        i=0;
		[[self dataObj] setObject:Check_OFF_Image forKey:@"defaultValue"];
	}

    [expenseEntryCellDelegate performSelector:@selector(switchButtonHandlings: onIndexpathRow:) withObject:[NSNumber numberWithInt:i] withObject:[NSNumber numberWithInteger:[sender tag]]];
}


-(void)addTextFieldsForTextUdfsAtIndexRow:(NSInteger)tagIndexText withHeight:(float)height
{
    CGFloat width = self.frame.size.width;

	if (fieldText==nil) {
		UITextField *tempfieldText=[[UITextField alloc]initWithFrame:CGRectMake(160.0, 8.0, width - 170.0, height)];
        self.fieldText=tempfieldText;

	}
	fieldText.keyboardAppearance = UIKeyboardAppearanceDefault;
	[fieldText setBackgroundColor:[UIColor clearColor]];
	fieldText.returnKeyType = UIReturnKeyDefault;
	if ([[dataObj objectForKey:@"fieldType"]isEqualToString: NUMERIC_KEY_PAD])
    {
        self.fieldText.keyboardType = UIKeyboardTypeNumberPad;
        //Fix for ios7//JUHI
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];

        if (version>=7.0)
        {
            self.fieldText.keyboardAppearance=UIKeyboardAppearanceDark;
        }
    }
    else{
        self.fieldText.keyboardType = UIKeyboardTypeAlphabet;
        self.fieldText.returnKeyType = UIReturnKeyDone;
    }
	fieldText.borderStyle = UITextBorderStyleNone;
	fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
	fieldText.textAlignment = NSTextAlignmentRight;
	fieldText.textColor = RepliconStandardBlackColor;
	[fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[fieldText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	fieldText.tag=tagIndexText;
	[fieldText setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
	[fieldText setDelegate:self];
	[self.contentView addSubview:fieldText];

}

-(void)addTextFieldsForAmountAtIndexRow:(int)tagIndexText {
    CGFloat width = self.frame.size.width;

	if (amountTextField==nil) {
		UITextField *tempamountTextField=[[UITextField alloc]initWithFrame:CGRectMake(140.0, 8.0, width - 170, 30.0)];
        self.amountTextField=tempamountTextField;

	}
	amountTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[amountTextField setBackgroundColor:[UIColor clearColor]];
	amountTextField.returnKeyType = UIReturnKeyDefault;
	amountTextField.keyboardType = UIKeyboardTypeNumberPad;
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];

    if (version>=7.0)
    {
        amountTextField.keyboardAppearance=UIKeyboardAppearanceDark;
    }
	amountTextField.borderStyle = UITextBorderStyleNone;
	amountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	amountTextField.textAlignment = NSTextAlignmentRight;
	amountTextField.textColor = RepliconStandardBlackColor;
	[amountTextField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[amountTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	amountTextField.tag=tagIndexText;
	[amountTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
	[amountTextField setDelegate:self];
	[self.contentView addSubview:amountTextField];
}

-(void)addFieldsForNewExpenseSheet:(float)_width height:(float)_height
{
	if (fieldName == nil) {
		UILabel *tempfieldName = [[UILabel alloc] initWithFrame:CGRectMake(11.0,3.0,_width, _height)];
        self.fieldName=tempfieldName;

	}
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
	[fieldName setTextColor:RepliconStandardBlackColor];
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:fieldName];

	if (fieldButton == nil) {
		UILabel *tempfieldButton = [[UILabel alloc] initWithFrame:CGRectMake(_width+14.0,3.0,_width+13.0, _height)];
        self.fieldButton=tempfieldButton;

	}

	[fieldButton setTextAlignment:NSTextAlignmentRight];
	[fieldButton setTextColor:RepliconStandardBlackColor];
	[fieldButton setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
	[fieldButton setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:fieldButton];


}

-(void)grayedOutRequiredCell
{
	[self.fieldName setTextColor: RepliconStandardGrayColor];
	[self.fieldButton setTextColor: RepliconStandardGrayColor];
	if (fieldText != nil) {
		[self.fieldText setTextColor:RepliconStandardGrayColor];
	}
	[self setUserInteractionEnabled:NO];
}

-(void)enableRequiredCell
{
	[self.fieldName setTextColor: RepliconStandardBlackColor];
	[self.fieldButton setTextColor: RepliconStandardBlackColor];
	if (fieldText != nil) {
		[self.fieldText setTextColor:FieldButtonColor];
	}
	[self setUserInteractionEnabled:YES];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([expenseEntryCellDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        ExpenseEntryViewController *expenseEntryViewCtrl=(ExpenseEntryViewController *)expenseEntryCellDelegate;

        [expenseEntryViewCtrl pickerDone:nil];
        if ([expenseEntryViewCtrl lastUsedTextField])
        {
            if ([expenseEntryViewCtrl currentIndexPath]!=nil)
            {
                NSDictionary *dict=[expenseEntryViewCtrl.secondSectionfieldsArray objectAtIndex:expenseEntryViewCtrl.currentIndexPath.row];

                if ([[dict objectForKey:@"fieldType"] isEqualToString:NUMERIC_KEY_PAD])
                {
                    [self updateUDFNumber:[expenseEntryViewCtrl lastUsedTextField].text];
                }
            }

            [expenseEntryViewCtrl setLastUsedTextField:nil];
        }
        [expenseEntryViewCtrl setLastUsedTextField:fieldText];


        [expenseEntryViewCtrl performSelector:@selector(showCustomPickerIfApplicable:) withObject:textField];

        NSInteger height=270;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        NSInteger row=[expenseEntryViewCtrl currentIndexPath ].row;
        height=height+(row*44);
        float movementDistance =screenRect.size.height-height;
        float offset=0.0;
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        if (aspectRatio<1.7)
        {
            offset=OffSetFor4;
        }
        else
            offset=OffSetFor5;

        UITableViewCell *aCell = [[expenseEntryViewCtrl expenseEntryTableView] cellForRowAtIndexPath:[expenseEntryViewCtrl currentIndexPath ]];
        CGSize cellSize = aCell.frame.size;
        [[expenseEntryViewCtrl expenseEntryTableView] setContentOffset:CGPointMake(0, cellSize.height*[expenseEntryViewCtrl currentIndexPath ].row-offset) animated:NO];


        if ([textField.text isEqualToString:ADD_STRING ])
        {
            textField.text=@"";
        }

        if ([[dataObj objectForKey:@"fieldType"]isEqualToString: NUMERIC_KEY_PAD])
        {
            if (!self.numberKeyPad) {
                self.numberKeyPad.isDonePressed=NO;
                self.numberKeyPad = [NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:expenseEntryCellDelegate withMinus:YES andisDoneShown:YES withResignButton:NO];
                if ([textField textAlignment] == NSTextAlignmentRight) {
                    [self.numberKeyPad.decimalPointButton setTag:333];
                }
            }else {
                //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
                self.numberKeyPad.currentTextField = textField;
            }
            
            [[expenseEntryViewCtrl expenseEntryTableView] scrollToRowAtIndexPath:[expenseEntryViewCtrl currentIndexPath] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [expenseEntryViewCtrl resetTableSize:YES];
            return YES;
        }
       
        CGRect frame= [expenseEntryViewCtrl expenseEntryTableView].frame;
        frame.size.height= cellSize.height* [expenseEntryViewCtrl currentIndexPath ].row+movementDistance;
        [[expenseEntryViewCtrl expenseEntryTableView] setFrame:frame];
    }


    // change size of UITableView


    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentRight) {

        [Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:decimalPlaces];
		return NO;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == numberKeyPad.currentTextField) {
		/*
		 Hide the number keypad
		 */
		[self.numberKeyPad removeButtonFromKeyboard];
        if ([numberKeyPad isDonePressed])
        {


            if ([expenseEntryCellDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                ExpenseEntryViewController *expenseEntryViewCtrl=(ExpenseEntryViewController *)expenseEntryCellDelegate;

                [expenseEntryViewCtrl expenseEntryTableView].frame = CGRectMake(0,0,expenseEntryViewCtrl.view.width,[expenseEntryViewCtrl view].frame.size.height);

                [[expenseEntryViewCtrl expenseEntryTableView] deselectRowAtIndexPath:[expenseEntryViewCtrl currentIndexPath ] animated:YES];
            }
            numberKeyPad.isDonePressed=NO;
            if([textField.text length] == 0)
            {
                textField.text = [Util getRoundedValueFromDecimalPlaces:[[NSNumber numberWithInt:0] newDoubleValue] withDecimalPlaces:2];
                ;
            }
        }

		self.numberKeyPad = nil;
        if([textField.text length] > 0)
        {
            textField.text=[Util getRoundedValueFromDecimalPlaces:[textField.text newDoubleValue] withDecimalPlaces:decimalPlaces];

            [self updateUDFNumber:textField.text];
            //Fix for DE15534
            if ([expenseEntryCellDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                ExpenseEntryViewController *expenseEntryViewCtrl=(ExpenseEntryViewController *)expenseEntryCellDelegate;
                if (expenseEntryViewCtrl.isSaveClicked)
                {
                    [expenseEntryViewCtrl expenseEntryTableView].frame = CGRectMake(0,0,expenseEntryViewCtrl.view.width,[expenseEntryViewCtrl view].frame.size.height);

                    [[expenseEntryViewCtrl expenseEntryTableView] deselectRowAtIndexPath:[expenseEntryViewCtrl currentIndexPath ] animated:YES];
                }
            }

        }
	}

    if ([textField.text length] == 0 ){
        textField.text=ADD_STRING;
        //Fix for DE15534
        if ([expenseEntryCellDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            
            ExpenseEntryViewController *expenseEntryViewCtrl=(ExpenseEntryViewController *)expenseEntryCellDelegate;
            if (expenseEntryViewCtrl.isSaveClicked)
            {
                [expenseEntryViewCtrl expenseEntryTableView].frame = CGRectMake(0,0,expenseEntryViewCtrl.view.width,[expenseEntryViewCtrl view].frame.size.height);

                [[expenseEntryViewCtrl expenseEntryTableView] deselectRowAtIndexPath:[expenseEntryViewCtrl currentIndexPath ] animated:YES];
            }
        }

    }
[self setHighlighted:NO animated:NO];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([expenseEntryCellDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        ExpenseEntryViewController *expenseEntryViewCtrl=(ExpenseEntryViewController *)expenseEntryCellDelegate;

        [expenseEntryViewCtrl expenseEntryTableView].frame = CGRectMake(0,0,expenseEntryViewCtrl.view.width,[expenseEntryViewCtrl view].frame.size.height);
        [[expenseEntryViewCtrl expenseEntryTableView] deselectRowAtIndexPath:[expenseEntryViewCtrl currentIndexPath ] animated:YES];
    }

    [textField resignFirstResponder];

    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)updateUDFNumber:(NSString *)UdfNumberEntered{

    int decimals = decimalPlaces;
    NSString *tempValue =	[Util getRoundedValueFromDecimalPlaces:[UdfNumberEntered newDoubleValue] withDecimalPlaces:decimals];
    tempValue = [Util removeCommasFromNsnumberFormaters:tempValue];
    if (tempValue!=nil) {
        //do nothing here
    }
    if ([expenseEntryCellDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        ExpenseEntryViewController *expenseEntryViewCtrl=(ExpenseEntryViewController *)expenseEntryCellDelegate;
        NSMutableDictionary *udfDetailDict=[expenseEntryViewCtrl.secondSectionfieldsArray objectAtIndex:expenseEntryViewCtrl.currentIndexPath.row];
        if (![tempValue isEqualToString:[udfDetailDict objectForKey:@"defaultValue"]])
        {

            expenseEntryViewCtrl.navigationItem.rightBarButtonItem.enabled=YES;
        }
        [udfDetailDict removeObjectForKey:@"defaultValue"];
        [udfDetailDict setObject:tempValue forKey:@"defaultValue"];
        [expenseEntryViewCtrl.secondSectionfieldsArray replaceObjectAtIndex:expenseEntryViewCtrl.currentIndexPath.row withObject:udfDetailDict];
    }

}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    if (highlighted) {
        [self.fieldText setTextColor:[UIColor whiteColor]];
    } else {

        if (canNotEdit)
        {
            [self.fieldText setTextColor:RepliconStandardGrayColor];


        }
        else
        {
            [self.fieldText setTextColor:RepliconStandardBlackColor];
        }

    }

}

@end
