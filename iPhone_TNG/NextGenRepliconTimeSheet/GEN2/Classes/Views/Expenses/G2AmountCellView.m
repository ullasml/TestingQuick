//
//  AmountCellView.m
//  Replicon
//
//  Created by Manoj  on 25/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2AmountCellView.h"
#import "G2AmountViewController.h"

@implementation G2AmountCellView
@synthesize fieldLable,amountDelegate,fieldText,
fieldButton;
@synthesize numberKeyPad;
@synthesize clientProjectlabel;
@synthesize clientProjectButton;
@synthesize clientProjectTaskDelegate;
@synthesize taskViewControllerDelegate;
@synthesize folderImageView;

static int Max_Kilometers_Text_Lenght = 10;

-(void)addFieldLabelAndButton:(NSInteger)tagValue
{
//	DLog(@"TAG_VALUE=%d",tagValue);
	if (fieldLable==nil) {
		UILabel *tempfieldLable = [[UILabel alloc]initWithFrame:CGRectMake(10,6.0 ,130 ,30 )];//US4065//Juhi//20 6 130 30
        self.fieldLable=tempfieldLable;
        
	}
	[fieldLable setBackgroundColor:[UIColor clearColor]];
	[fieldLable setTextColor:RepliconStandardBlackColor];
	[fieldLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	[self.contentView addSubview:fieldLable];
	if (tagValue==0) {
		if (fieldButton == nil) {
			//DLog(@"--------WAS NILL-------");
			fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
                
            }
            else{
                frame=CGRectMake(140.0,
                                 6.0,
                                 150.0,
                                 30.0);
            }
			[fieldButton setFrame:frame];//130 6 150 30
			
		}
        else
        {
            //DLog(@"--------WAS NOT NILL-------");
        }
		[fieldButton addTarget:self action:@selector(buttonAction:withEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		[fieldButton setBackgroundColor:[UIColor clearColor]];
		[fieldButton setTag:tagValue];
		[fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		
		[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[self.contentView addSubview:fieldButton];
	}else {
		if (fieldText==nil) {
            
            //130 6 150 30
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
                
            }
            else{
                frame=CGRectMake(140.0,
                                 6.0,
                                 150.0,
                                 30.0);
            }
			UITextField *tempfieldText=[[UITextField alloc]initWithFrame:frame];
            self.fieldText=tempfieldText;
            
		//fieldText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-40, self.frame.size.height)];
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
		fieldText.tag=tagValue;
		[fieldText setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
		[fieldText setDelegate:self];
		[self.contentView addSubview:fieldText];
	}

}

-(void)addFieldsForClientProjectTaskcell{
	
	if (fieldLable==nil) {
		UILabel *tempfieldLable = [[UILabel alloc]initWithFrame:CGRectMake(20,6.0 ,130 ,30 )];
        self.fieldLable=tempfieldLable;
        
	}
	[fieldLable setBackgroundColor:[UIColor clearColor]];
	[fieldLable setTextColor:RepliconStandardBlackColor];
	[fieldLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];//DE5654 Ullas
	[self.contentView addSubview:fieldLable];
	
	if (fieldButton == nil) {
		fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[fieldButton setFrame:CGRectMake(130.0,
											 6.0,
											 150.0,
											 30.0)];
		//[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
		[fieldButton setBackgroundColor:[UIColor clearColor]];
		//[fieldButton setTag:tagValue];
		[fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[fieldButton setHidden:YES];
		[self.contentView addSubview:fieldButton];
		}
		
	//else {
		if (fieldText==nil) {
			UITextField *tempfieldText=[[UITextField alloc]initWithFrame:CGRectMake(130.0,
																   6.0,
																   150.0,
																   30.0)];
            self.fieldText=tempfieldText;
            
		}
		fieldText.keyboardAppearance = UIKeyboardAppearanceDefault;
		[fieldText setBackgroundColor:[UIColor clearColor]];
		fieldText.returnKeyType = UIReturnKeyDefault;
		fieldText.keyboardType = UIKeyboardTypeNumberPad;
		fieldText.borderStyle = UITextBorderStyleNone;
		//fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
		fieldText.textAlignment = NSTextAlignmentRight;
		fieldText.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
		[fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		[fieldText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		fieldText.tag=7001;
		[fieldText setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
		[fieldText setDelegate:self];
		[fieldText setHidden:YES];
		[self.contentView addSubview:fieldText];
	//}
}
-(void)addFieldsForTaskViewController:(int)tagValue{
	if (tagValue==2) {
		UILabel *tempfieldLable = [[UILabel alloc]initWithFrame:CGRectMake(20,6.0 ,180 ,30)];
        self.fieldLable=tempfieldLable;
        
	}
	else {
		
			UILabel *tempfieldLable = [[UILabel alloc]initWithFrame:CGRectMake(50,6.0 ,180 ,30)];
            self.fieldLable=tempfieldLable;
        
	}

	
	[fieldLable setBackgroundColor:[UIColor clearColor]];
	[fieldLable setTextColor:RepliconStandardBlackColor];
	[fieldLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];//DE5654 Ullas
	[self.contentView addSubview:fieldLable];
	
	
	UIImage *folderImg=[G2Util thumbnailImage:FolderImage];
	if (folderImageView==nil) {
		UIImageView *tempfolderImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10.0, 
																	 6.0,
																	 folderImg.size.width,
																	 folderImg.size.height)];
        self.folderImageView=tempfolderImageView;
        
	}
	
	
	[folderImageView setImage:folderImg];	
	[self.contentView addSubview:folderImageView];
}
#pragma mark TextFieldDelegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
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
		//textField.textAlignment = NSTextAlignmentCenter;
	if ([textField textAlignment] == NSTextAlignmentRight) {
        if (![textField.text isKindOfClass:[NSNull class] ]) 
        {
            if ([textField.text length] > 1)
                if ([textField.text characterAtIndex:[textField.text length]-1] != ' ') {
                    [textField setText:[NSString stringWithFormat:@"%@ ",[textField text]]];
                }
        }
		
	}
    
    //AmountViewController *amtCtrl=(AmountViewController *)amountDelegate;
   // CGRect frame=amtCtrl.amountTableView.frame;
    //frame.size.height=157.0;
    //amtCtrl.amountTableView.frame=frame;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if ([textField textAlignment] == NSTextAlignmentRight) {
        if (![textField.text isKindOfClass:[NSNull class] ]) 
        {
            if ([textField.text length] > 1) {
               // [textField setText:[textField.text substringToIndex:[textField.text length]-1]];//DE5223//Juhi
            }
        }
		
	}
	
	if( textField.tag==1) {
		[amountDelegate performSelector:@selector(setEnteredAmountValue:) withObject:textField.text];
		//[amountDelegate performSelector:@selector(pickerDone:) withObject:nil];
        [amountDelegate performSelector:@selector(updateValues:) withObject:textField];//DE5265 Ullas M L
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
		//textField.textAlignment = NSTextAlignmentRight;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	textField.text = [G2Util removeCommasFromNsnumberFormaters:textField.text];

	if ([textField.text isEqualToString:RPLocalizedString(@"Select", @"Select") ] || [textField.text isEqualToString:@"0.00"]) {
		textField.text=@"";
	}
//	[textField setText:@""];
	
	
	
	if( textField.tag!=100 && textField.tag!=200) {
		[amountDelegate performSelector:@selector(userSelectedTextField:) withObject:textField];
	}else {
		[amountDelegate performSelector:@selector(showKilometersOverLay:) withObject:textField];
	}
	
	if (numberKeyPad) {
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
            if ([textField.text length]>= Max_Kilometers_Text_Lenght) {
                if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=10 ) {
                    return NO;
                }
            }
        }
		
	}
		
	/*	NSString *oldText = textField.text;
		NSString *text = [ oldText stringByReplacingCharactersInRange:range withString:@"" ];
		NSArray *parts = [text componentsSeparatedByString:@"."];
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
		}	
	*/
	
	if (textField.tag==200 || textField.tag==100) {
        if (![textField.text isKindOfClass:[NSNull class] ]) 
        {
            if ([textField.text length]>= Max_Kilometers_Text_Lenght) {
                if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=10 ) {
                    return NO;
                }
            }
        }
		
	}
	if ([textField textAlignment] == NSTextAlignmentRight) {
		[G2Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:2];
		return NO;
	}
	return YES;
}

-(void)buttonAction:(UIButton*)sender withEvent:(UIEvent*)event
{
    //AmountViewController *amtCtrl=(AmountViewController *)amountDelegate;
    //CGRect frame=amtCtrl.amountTableView.frame;
    //frame.size.height=157.0;
    //amtCtrl.amountTableView.frame=frame;
	[amountDelegate performSelector:@selector(buttonActionsHandling::) withObject:sender withObject:event];
}

-(void) setCellViewState: (BOOL)isSelected	{
	if (isSelected) {
		[self.fieldLable setTextColor: iosStandaredWhiteColor];
		[self.fieldButton setTitleColor: iosStandaredWhiteColor forState: UIControlStateNormal];
		if (self.fieldText !=nil) {
			[self.fieldText setTextColor:iosStandaredWhiteColor];
		}
	} else {
		[self.fieldLable setTextColor: FieldButtonColor];
		[self.fieldButton setTitleColor: RepliconStandardBlackColor forState: UIControlStateNormal];
		if (self.fieldText !=nil) {
			[self.fieldText setTextColor:FieldButtonColor];
		}
	}
	
}



@end
