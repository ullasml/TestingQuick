//
//  ExpenseEntryCellView.m
//  Replicon
//
//  Created by Devi Malladi on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ExpenseEntryCellView.h"
#import "G2EditExpenseEntryViewController.h"


@implementation G2ExpenseEntryCellView
@synthesize fieldName,numberKeyPad,
expenseEntryCellDelegate,
fieldText, 
switchMark,
amountTextField;
@synthesize fieldButton;


@synthesize tagIndex;
@synthesize decimalPlaces;
@synthesize indexPath;
@synthesize dataObj;
#define SECONDSECTION_TAG_INDEX 4050

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setAccessoryType: UITableViewCellAccessoryNone];
		[self setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    return self;
}

//-(void)addFieldAtIndex:(int)ind atSection:(int)sec{
-(void) addFieldAtIndex: (NSIndexPath *) _indexPath withTagIndex: (NSInteger)_tagIndex withObj : (NSMutableDictionary *) _dataObj{
	//[self indexPath: _indexPath];
	//[self tagIndex: _tagIndex];
	
	[self setIndexPath: _indexPath];
	[self setTagIndex: _tagIndex];
	[self setDataObj: _dataObj];
	
	if (fieldName==nil) {
			//fieldName = [[UILabel alloc]initWithFrame:CGRectMake(20,6.0 ,130 ,30 )];
		UILabel *tempfieldName = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 130, 30)];//US4065//Juhi
        self.fieldName=tempfieldName;
        
	}
	[fieldName setText:[dataObj objectForKey: @"fieldName"]];
	
	if (fieldButton == nil) {
        self.fieldButton=[UIButton buttonWithType:UIButtonTypeCustom];
		
			//[fieldButton setFrame:CGRectMake(130.0, 6.0, 150.0,	30.0)];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(140, 8, 150, 30);
        }
		[fieldButton setFrame:frame];//US4065//Juhi
	}
	
	
	
	
	if ([[dataObj objectForKey:@"fieldType"] isEqualToString:NUMERIC_KEY_PAD ]){
		[self addTextFieldsForTextUdfsAtIndexRow:tagIndex];
		if ([[dataObj objectForKey:@"defaultValue"] isKindOfClass:[NSNumber class]]) {
			[fieldText setText:[NSString stringWithFormat:@"%@",[dataObj objectForKey:@"defaultValue"]]];
		}else {
			[fieldText setText:[dataObj objectForKey:@"defaultValue"]];
		}
		
		decimalPlaces=0;
		if ([dataObj objectForKey:@"defaultDecimalValue"]!=nil && !([[dataObj objectForKey:@"defaultDecimalValue"] isKindOfClass:[NSNull class]])) {
			decimalPlaces=[[dataObj objectForKey:@"defaultDecimalValue"]intValue];
		}
		
		[fieldButton setHidden:YES];
		[fieldText setHidden:NO];
		if (switchMark !=nil) {
			[switchMark setHidden:YES];
		}
		
	}
    else {
		[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[fieldButton setEnabled:YES];
		[fieldButton setTag: tagIndex];
		[fieldButton setUserInteractionEnabled:YES];
		[fieldButton setHidden:NO];
		[fieldText setHidden:YES];
		if (switchMark != nil) {
			[switchMark setHidden:YES];
		}
	}
	
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	if (indexPath.section == 1) {
		[fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[fieldName setTextColor:RepliconStandardBlackColor];
	}
	
	
	//Added below condition to remove image name for checkmark field.
	if ([[dataObj objectForKey:@"fieldType"]isEqualToString: CHECK_MARK ]){
		
		[fieldButton setHidden:YES];
		[fieldText setHidden:YES];
		
			//		switchMark = [[UISwitch alloc] initWithFrame:CGRectMake(190, 6.0, 130.0,30.0)];
        float x=198.0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            x=214.0;
        }
        //Fix for ios7//JUHI
        CGRect frame;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
        {
            frame=CGRectMake(x+42, 8.0, 130.0,30.0);
            
        }
        else{
            frame=CGRectMake(x, 8.0, 130.0, 30.0);
        }
        UISwitch *tempswitchMark = [[UISwitch alloc] initWithFrame:frame];
        self.switchMark=tempswitchMark;
        
		[switchMark addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		if ([[dataObj objectForKey: @"defaultValue"] isEqualToString:G2Check_ON_Image]) {
			[switchMark setOn:YES];
		}else {
			[switchMark setOn:NO];
		}

        //Fix for ios7//JUHI
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)
        {
            [self.switchMark setOnTintColor: RepliconStandardNavBarTintColor];
        }

		[switchMark setTag:tagIndex];
		[self.contentView addSubview:switchMark];
		
	}
	
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[fieldButton setBackgroundColor:[UIColor clearColor]];
	[fieldText setBackgroundColor:[UIColor clearColor]];
	//[self setCellViewState: NO];
	[switchMark setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:fieldName];
	[self.contentView addSubview:fieldButton];
	
}

-(void)switchChanged:(UISwitch*)sender
{
	if ([sender isOn]) {
		[[self dataObj] setObject:G2Check_ON_Image forKey:@"defaultValue"];
        //DE4067//Juhi
        [self enableRequiredCell];
	}else {
		[[self dataObj] setObject:G2Check_OFF_Image forKey:@"defaultValue"];
	}


	//[expenseEntryCellDelegate performSelector:@selector(switchButtonHandlings:) withObject:self];
}


-(void)addTextFieldsForTextUdfsAtIndexRow:(NSInteger)tagIndexText
{
	if (fieldText==nil) {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(140.0,   //130.0,
                             8.0,
                             150.0,
                             30.0);
        }
		UITextField *tempfieldText=[[UITextField alloc]initWithFrame:frame];//US4065//Juhi
        self.fieldText=tempfieldText;
        
	}
	fieldText.keyboardAppearance = UIKeyboardAppearanceDefault;
	[fieldText setBackgroundColor:[UIColor clearColor]];
	fieldText.returnKeyType = UIReturnKeyDefault;
	fieldText.keyboardType = UIKeyboardTypeNumberPad;
	fieldText.borderStyle = UITextBorderStyleNone;
	fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
	fieldText.textAlignment = NSTextAlignmentRight;
	fieldText.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
	[fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	[fieldText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	fieldText.tag=tagIndexText;
	[fieldText setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
	[fieldText setDelegate:self];
	[self.contentView addSubview:fieldText];
	
}

-(void)addTextFieldsForAmountAtIndexRow:(int)tagIndexText {
	if (amountTextField==nil) {
		UITextField *tempamountTextField=[[UITextField alloc]initWithFrame:CGRectMake(140.0,   //130.0,
															   8.0,
															   150.0,
															   30.0)];//US4065//Juhi
        self.amountTextField=tempamountTextField;
        
	}
	amountTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[amountTextField setBackgroundColor:[UIColor clearColor]];
	amountTextField.returnKeyType = UIReturnKeyDefault;
	amountTextField.keyboardType = UIKeyboardTypeNumberPad;
	amountTextField.borderStyle = UITextBorderStyleNone;
	amountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	amountTextField.textAlignment = NSTextAlignmentRight;
	amountTextField.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
	[amountTextField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	[amountTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	amountTextField.tag=tagIndexText;
	[amountTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
	[amountTextField setDelegate:self];
	[self.contentView addSubview:amountTextField];
}

-(void)addFieldsForNewExpenseSheet:(float)width height:(float)_height{
	if (fieldName == nil) {
		UILabel *tempfieldName = [[UILabel alloc] initWithFrame:CGRectMake(11.0,5.0,
															  width, _height)];
        self.fieldName=tempfieldName;
        
	}
	
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	[fieldName setTextColor:RepliconStandardBlackColor];
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:fieldName];
	
	if (fieldButton == nil) {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(width+4.0,5.0,
                             width+05.0, _height);
        }
		UIButton *tempfieldButton = [[UIButton alloc] initWithFrame:frame];
        self.fieldButton=tempfieldButton;
      
	}
	
	[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	//[fieldButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	[fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	[fieldButton setBackgroundColor:[UIColor clearColor]];
	[self.contentView addSubview:fieldButton];
	
	
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        CGRect frame=[expenseEntryCellDelegate toolbarSegmentControl].frame;
        frame.origin.y=10;
        [expenseEntryCellDelegate toolbarSegmentControl].frame=frame;
    }

	if ([textField textAlignment] == NSTextAlignmentRight) {
        if (![textField.text isKindOfClass:[NSNull class] ]) 
        {
            if ([textField.text length] > 1) {
                [textField setText:[textField.text substringToIndex:[textField.text length]-1]];
            }
        }
		
	}
	
	[expenseEntryCellDelegate performSelector:@selector(addValuesToNumericUdfs:) withObject:textField];
	
	
	
	
	//To remove . button from key board................
	if (textField == numberKeyPad.currentTextField) {
		[self.numberKeyPad removeButtonFromKeyboard];
		self.numberKeyPad = nil;
	}
		//	textField.textAlignment = NSTextAlignmentRight;
	
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	textField.text = [G2Util removeCommasFromNsnumberFormaters:textField.text];

	[expenseEntryCellDelegate  performSelector:@selector(hidePickersForKeyBoard:) withObject:textField];
	if ([textField.text isEqualToString:RPLocalizedString(@"Select", @"") ] || [textField.text isEqualToString:RPLocalizedString(@"Add", @"") ]) {
		textField.text=@"";
	}
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        CGRect frame=[expenseEntryCellDelegate toolbarSegmentControl].frame;
        frame.origin.y=5;
        [expenseEntryCellDelegate toolbarSegmentControl].frame=frame;
    }
	//textField.text=@"";
	//[expenseEntryCellDelegate performSelector:@selector(numericKeyPadAction:withEvent:) withObject:nil withObject:nil];
	[expenseEntryCellDelegate performSelector:@selector(updateNumberOfDecimalPlaces:) withObject:[NSNumber numberWithInt:decimalPlaces]];
	if (numberKeyPad) {
		numberKeyPad.currentTextField = textField;
        
	}
		//textField.textAlignment = NSTextAlignmentCenter;
    BOOL validAmount=YES;
    if ([expenseEntryCellDelegate isKindOfClass:[G2EditExpenseEntryViewController class]]) {
        validAmount=[expenseEntryCellDelegate validAmount];
        if (!validAmount)
        {
            return NO;
        }
        
    }
	
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
	
	if ([textField isEqual:fieldText]) {
		/*
		 Show the numberKeyPad 
		 */
		if (!self.numberKeyPad) {
			self.numberKeyPad = [G2NumberKeypadDecimalPoint keypadForTextField:textField isMinusButton:NO];
			if ([textField textAlignment] == NSTextAlignmentRight) {
				[self.numberKeyPad.decimalPointButton setTag:333];
			}			
		}else {
			//if we go from one field to another - just change the textfield, don't reanimate the decimal point button
			self.numberKeyPad.currentTextField = textField;
		}
	}
	if ([textField textAlignment] == NSTextAlignmentRight) {
        if (![textField.text isKindOfClass:[NSNull class] ]) 
        {
            if ([[textField text] length]) {
                [textField setText:[NSString stringWithFormat:@"%@ ",[textField text]]];
            }
        }
		
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![textField.text isKindOfClass:[NSNull class] ]) 
    {
        if ([[[self dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"") ] && 
			(!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=10)) {
			return NO;
		}
        
    }

/*		NSString *oldText = textField.text;
		DLog(@"old text - %@",oldText);
		NSString *text = [ oldText stringByReplacingCharactersInRange:range withString:@"" ];
		DLog(@"text - %@",text);
		NSArray *parts = [text componentsSeparatedByString:@"."];
		DLog(@"Parts - %@///// %d",parts,decimalPlaces);
		if (parts.count > 1) {
			if (parts.count <= 2) { 
				textField.text = text;
				NSString *after = (NSString*)[parts objectAtIndex:1];
				if (after.length >= 2) {
					if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=2 ) {
						return NO;
					}
				}else if (after.length <= 1 &&([string isEqualToString:@""] && range.length == 1) ) {
					return NO;
				}
			}
		}*/
	if ([textField textAlignment] == NSTextAlignmentRight) {
        if ([[[self dataObj] objectForKey:@"defaultDecimalValue"] intValue] >=0) {
            [G2Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:[[[self dataObj] objectForKey:@"defaultDecimalValue"] intValue]];
        }		return NO;
	}
	return YES;
}

-(void) setCellViewState: (BOOL)isSelected	{
	if (isSelected) {
        [self setBackgroundColor:RepliconStandardBlueColor];
		[self.fieldName setTextColor: iosStandaredWhiteColor];
		[self.fieldButton setTitleColor: iosStandaredWhiteColor forState: UIControlStateNormal];
		if (fieldText != nil) {
			[self.fieldText setTextColor:iosStandaredWhiteColor];
		}
	} else {
        [self setBackgroundColor:iosStandaredWhiteColor];
		[self.fieldName setTextColor: RepliconStandardBlackColor];
		[self.fieldButton setTitleColor: NewRepliconStandardBlueColor forState: UIControlStateNormal];//US4065//Juhi
		if (fieldText != nil) {
			[self.fieldText setTextColor:FieldButtonColor];
		}
	}

}

-(void)grayedOutRequiredCell
{
	[self.fieldName setTextColor: RepliconStandardGrayColor];
	[self.fieldButton setTitleColor: RepliconStandardGrayColor forState: UIControlStateNormal];
	if (fieldText != nil) {
		[self.fieldText setTextColor:RepliconStandardGrayColor];
	}
	[self setUserInteractionEnabled:NO];	
}

-(void)enableRequiredCell
{
	[self.fieldName setTextColor: RepliconStandardBlackColor];
	[self.fieldButton setTitleColor: NewRepliconStandardBlueColor forState: UIControlStateNormal];//US4065//Juhi
	if (fieldText != nil) {
		[self.fieldText setTextColor:FieldButtonColor];
	}
	[self setUserInteractionEnabled:YES];	
}




@end
