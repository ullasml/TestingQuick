//
//  TimeEntryCellView.m
//  Replicon
//
//  Created by Swapna P on 4/29/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2TimeEntryCellView.h"
#import "G2EntryCellDetails.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeEntryViewController.h"

#define TIME_TAG 9999
#define HOUR_TAG 8888

@implementation G2TimeEntryCellView
@synthesize fieldName;
@synthesize fieldButton;
@synthesize textField;
@synthesize folderImageView;
@synthesize numberKeyPad;
@synthesize textFieldDelegate;
@synthesize detailsObj;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}
-(void)newTimeEntryFields:(NSInteger)tagValue{
	if (fieldName==nil) {
		UILabel *tempfieldName = [[UILabel alloc]initWithFrame:CGRectMake(10,8.0 ,130 ,30 )];//US4065//Juhi
        self.fieldName=tempfieldName;
       
	}
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];//DE5654 Ullas
	[fieldName setTextColor:RepliconStandardBlackColor];
	[self.contentView addSubview:fieldName];
	
	//if (tagValue == 0) {
		if (fieldButton == nil) {
			
			fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
                
            }
            else{
                frame=CGRectMake(136.0,
                                 8.0,
                                 140.0,
                                 30.0);
            }
			[fieldButton setFrame:frame];//US4065//Juhi
		}
		[fieldButton setBackgroundColor:[UIColor clearColor]];
		[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[fieldButton setEnabled:YES];
		[fieldButton setUserInteractionEnabled:YES];
		[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		[fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[fieldButton setHidden:YES];
		[self.contentView addSubview:fieldButton];
	//}else {
		if (textField==nil) {
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
                
            }
            else{
                frame=CGRectMake(136.0,
                                 8.0,
                                 140.0,
                                 30.0);
            }
			UITextField *temptextField=[[UITextField alloc]initWithFrame:frame];//US4065//Juhi
            self.textField=temptextField;
           
		}
		textField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[textField setBackgroundColor:[UIColor clearColor]];
		textField.returnKeyType = UIReturnKeyDefault;
		textField.keyboardType = UIKeyboardTypeNumberPad;
		textField.borderStyle = UITextBorderStyleNone;
		//fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.textAlignment = NSTextAlignmentRight;
		textField.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
		[textField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		textField.tag=tagValue;
		[textField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
		[textField setDelegate:self];
		[textField setHidden:YES];
		[self.contentView addSubview:textField];
	//}
}
-(void)clientProjectCellLayout:(NSString *)_fieldName fieldVal:(NSString *)_fieldValue withTag:(int)_tagVal{
	DLog(@"clientProjectCellLayout::TimeENtryCellView");
	DLog(@"FiledName = %@, FieldValue = %@, Tag = %d",_fieldName,_fieldValue,_tagVal);
	if (fieldName==nil) {
		UILabel *tempfieldName = [[UILabel alloc]initWithFrame:CGRectMake(10,8.0 ,130 ,30 )];//US4065//Juhi
        self.fieldName=tempfieldName;
        
	}
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];//DE5654 Ullas
	[fieldName setTextColor:RepliconStandardBlackColor];
	[fieldName setText:_fieldName];
	[self.contentView addSubview:fieldName];
	
	if (fieldButton == nil) {
		
		UIButton *tempfieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
        self.fieldButton=tempfieldButton;
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(136.0,
                             8.0,
                             140.0,
                             30.0);
        }
       [self.fieldButton setFrame:frame];//US4065//Juhi
	
        }
	[fieldButton setBackgroundColor:[UIColor clearColor]];
	[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[fieldButton setEnabled:YES];
	[fieldButton setUserInteractionEnabled:YES];
	[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	[fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
	[fieldButton setHidden:NO];
	[fieldButton setTitle:_fieldValue forState:UIControlStateNormal];
	[fieldButton setTag:_tagVal];
	[self.contentView addSubview:fieldButton];
}


-(void) layoutCell: (NSInteger)tagValue withType: (NSString *) fieldType withfieldName:(NSString *) labelName
		 withFieldValue: (id) fieldValue withTextColor:(UIColor *)_color{
	NSString *valueString = @"";
	if ([fieldValue isKindOfClass:[NSDate class]] ) {
		valueString = [G2Util convertPickerDateToString:(NSDate *)fieldValue];
	}else if ([fieldValue isKindOfClass:[NSNumber class]]) {
        valueString = [NSString stringWithFormat:@"%@",(NSNumber *)fieldValue];
	}else if([fieldValue isKindOfClass:[NSString class]]){
		valueString = (NSString *)fieldValue;
	}

	
	if (fieldName==nil) {
		//fieldName = [[UILabel alloc]initWithFrame: TimeEntryCellFieldNameFrame];
		UILabel *tempfieldName = [[UILabel alloc]initWithFrame:CGRectMake(10,8.0 ,130 ,30 )];//US4065//Juhi
        self.fieldName=tempfieldName;
        
	}
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[fieldName setFont: [UIFont fontWithName: RepliconFontFamily size: RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	[fieldName setTextColor: RepliconStandardBlackColor];
	[fieldName setText: RPLocalizedString(labelName, labelName) ];
	[fieldName setTag: tagValue];
	[self.contentView addSubview: fieldName];
	
	if ([fieldType isEqualToString:DATE_PICKER] || [fieldType isEqualToString:DATA_PICKER] || [fieldType isEqualToString:MOVE_TO_NEXT_SCREEN] || [fieldType isEqualToString:TIME_PICKER]) {
		//DLog(@"Date Picker OR Data Picker");
		if (fieldButton == nil) {
			
			self.fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
			//[fieldButton setFrame: TimeEntryCellFieldValueFrame];
            //US4065//Juhi
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
                
            }
            else{
                frame=TimeEntryCellButtonTextFieldFrame;
            }
            [self.fieldButton setFrame:frame];
		}
		
		[fieldButton setBackgroundColor:[UIColor clearColor]];
		[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		[fieldButton setEnabled:YES];
		[fieldButton setUserInteractionEnabled:YES];
		[fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		//[fieldButton setTitleColor:FieldButtonColor forState:UIControlStateNormal];
		[fieldButton setTitleColor:_color forState:UIControlStateNormal];
		[fieldButton setHidden:NO];
		[fieldButton setTitle:RPLocalizedString(valueString, valueString)  forState:UIControlStateNormal];
        if ([valueString isEqualToString:@"None"]) {//US4335
            [fieldButton setTitle:valueString  forState:UIControlStateNormal];
        }
		[fieldButton setTag: tagValue];
		[self.contentView addSubview:fieldButton];
	}
	else 
	{
		if(textField == nil)
		{
			//textField = [[UITextField alloc] initWithFrame: TimeEntryCellFieldValueFrame];
            //US4065//Juhi
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
                
            }
            else{
               frame=TimeEntryCellButtonTextFieldFrame;
            }
            
			UITextField *temptextField=[[UITextField alloc]initWithFrame:frame];
            self.textField=temptextField;
            
		}
		textField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[textField setBackgroundColor: [UIColor clearColor]];
		textField.returnKeyType = UIReturnKeyDefault;
		textField.keyboardType = [fieldType isEqualToString: NUMERIC_KEY_PAD] ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
		textField.borderStyle = UITextBorderStyleNone;
		//fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.textAlignment = NSTextAlignmentRight;
		//textField.textColor = FieldButtonColor;
		textField.textColor = _color;
		[textField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
		[textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		textField.tag=tagValue;
		[textField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
		[textField setDelegate:self];
		[textField setHidden:NO];
		[textField setText: @"........."];
		[self.contentView addSubview:textField];
		
		[self.textField setText: RPLocalizedString(valueString, valueString) ];
	}		
}

-(void)addFieldsForTaskViewController:(int)tagValue{
	DLog(@"addFieldsForTaskViewController:");
	if (tagValue==2) {
		UILabel *tempfieldName = [[UILabel alloc]initWithFrame:CGRectMake(20,8.0 ,180 ,30)];//US4065//Juhi
        self.fieldName=tempfieldName;
       
	}
	else {
		
		UILabel *tempfieldName = [[UILabel alloc]initWithFrame:CGRectMake(50,8.0 ,180 ,30)];//US4065//Juhi
		self.fieldName=tempfieldName;
       
	}
	
	
	[fieldName setBackgroundColor:[UIColor clearColor]];
	[fieldName setTextColor:RepliconStandardBlackColor];
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];//DE5654 Ullas
	[self.contentView addSubview:fieldName];
	
	
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
#pragma mark TextFieldDelegates
- (BOOL)textFieldShouldReturn:(UITextField *)textFieldObj{
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textFieldObj{
	
	if ([textFieldObj isEqual:textField]) {
		
		//also show custompickerview if applicable
        if ([textFieldDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
        {
            G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
            
            if (textFieldObj.tag != TIME_TAG && textFieldObj.tag != HOUR_TAG)
            {
                
                if (timeEntryCtrl.lastUsedTextField.tag==TIME_TAG ||timeEntryCtrl.lastUsedTextField.tag==HOUR_TAG)
                {
                    [timeEntryCtrl validateTimeEntryFieldValueInCell];
                    if (timeEntryCtrl.isTimeFieldValueBreak) 
                    {
                        timeEntryCtrl.isTimeFieldValueBreak=NO;
                       
                        return ;
                    } 
                }
                    
                
            }
            
        }
		if ([textFieldDelegate respondsToSelector:@selector(showCustomPickerIfApplicable:)]) {
			
			[textFieldDelegate performSelector:@selector(showCustomPickerIfApplicable:) withObject:textFieldObj];
		}
		/*
		 Show the numberKeyPad 
		 */
		if (!self.numberKeyPad) 
        {
            BOOL isMinusBtn=NO;
            if ([textFieldDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
            {
                G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
                                
                if (timeEntryCtrl.screenMode==ADD_ADHOC_TIMEOFF ||timeEntryCtrl.screenMode==EDIT_ADHOC_TIMEOFF) 
                {
                    //For any timeoff user minus button is allowed
                    if(textFieldObj.tag == TIME_TAG || textFieldObj.tag == HOUR_TAG )
                    {
                        isMinusBtn=YES;
                    } 

                }
                else if (timeEntryCtrl.screenMode==ADD_TIME_ENTRY ||timeEntryCtrl.screenMode==EDIT_TIME_ENTRY) 
                {
                    //for only standard timesheet user minus button is allowed
                    if(!timeEntryCtrl.isInOutFlag && !timeEntryCtrl.isLockedTimeSheet )
                    {
                        if(textFieldObj.tag == TIME_TAG || textFieldObj.tag == HOUR_TAG )
                        {
                            isMinusBtn=YES;
                        } 
                    }

                }
                                
            }

            
            
            self.numberKeyPad = [G2NumberKeypadDecimalPoint keypadForTextField:textFieldObj isMinusButton:isMinusBtn];
			
			if ([textFieldObj textAlignment] == NSTextAlignmentRight) {
				[self.numberKeyPad.decimalPointButton setTag:333];
			}
		}else {
			//if we go from one field to another - just change the textfield, don't reanimate the decimal point button
			self.numberKeyPad.currentTextField = textFieldObj;
		}
		
		if ([textFieldObj.text isEqualToString:@"0.00"] && (textFieldObj.tag == TIME_TAG  || textFieldObj.tag == HOUR_TAG) ) {
			[textFieldObj setText:@""];
		}
		if ([textFieldObj textAlignment] == NSTextAlignmentRight) {
            if (![[textFieldObj text] isKindOfClass:[NSNull class] ])
            {
                if ([[textFieldObj text] length]) {
                    [textFieldObj setText:[NSString stringWithFormat:@"%@ ",[textFieldObj text]]];
                }
            }
			
		}
				
	}	
    
}

- (void)textFieldDidEndEditing:(UITextField *)textFieldObj
{
    //US5053 Ullas M L
    if ([textFieldDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
    {
        G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
        if (!timeEntryCtrl.isFromCancel) {
            
            if (textFieldObj.tag != TIME_TAG && textFieldObj.tag != HOUR_TAG)
            {
                
                if (timeEntryCtrl.lastUsedTextField.tag==TIME_TAG ||timeEntryCtrl.lastUsedTextField.tag==HOUR_TAG)
                {
                    [timeEntryCtrl validateTimeEntryFieldValueInCell];
                    if (timeEntryCtrl.isTimeFieldValueBreak) 
                    {
                        timeEntryCtrl.isTimeFieldValueBreak=NO;
                        return ;
                    } 
                }

                         
                
            }
            
        }
        
    }

	if ([textFieldObj textAlignment] == NSTextAlignmentRight) {
        if (![[textFieldObj text] isKindOfClass:[NSNull class] ])
        {
            if ([textFieldObj.text length] > 1) {
                [textFieldObj setText:[textFieldObj.text substringToIndex:[textFieldObj.text length]-1]];
            }
        }

	}
	
	if (textFieldObj == numberKeyPad.currentTextField) {
		/*
		 Hide the number keypad
		 */
		[self.numberKeyPad removeButtonFromKeyboard];
		self.numberKeyPad = nil;
	}
	
    if (![[textFieldObj text] isKindOfClass:[NSNull class] ])
    {
        if ([textFieldObj.text length] == 0 && (textFieldObj.tag == TIME_TAG  || textFieldObj.tag == HOUR_TAG)) {
            [textFieldObj setText:@"0.00"];
        }
        if ([textFieldObj.text length] > 0 &&  textFieldObj.tag == HOUR_TAG) {
            G2TimeSheetEntryObject *entryObj=(G2TimeSheetEntryObject *)[(G2TimeEntryViewController *)textFieldDelegate timeSheetEntryObject];
            [entryObj setNumberOfHours:textFieldObj.text];
            
        }
        //DE8514
        if ([textFieldObj.text length] > 0 &&  textFieldObj.tag == TIME_TAG) {
            G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
            if(timeEntryCtrl.timeSheetEntryObject!=nil)
            {
                G2TimeSheetEntryObject *entryObj=(G2TimeSheetEntryObject *)[(G2TimeEntryViewController *)textFieldDelegate timeSheetEntryObject];
                [entryObj setNumberOfHours:textFieldObj.text];
                
            }
            else {
                G2TimeOffEntryObject *entryObj=(G2TimeOffEntryObject*)[(G2TimeEntryViewController *)textFieldDelegate timeOffEntryObject];
                [entryObj setNumberOfHours:textFieldObj.text];
            }
            
        }
        else
        {
            if ([textFieldObj.text isEqualToString:@"" ]|| textFieldObj.text==nil || [textFieldObj.text isKindOfClass:[NSNull class] ] ) {
                textFieldObj.text=RPLocalizedString(@"Add", @"Add") ;
            }
            //DE8906//JUHI
            else if([textFieldObj.text length] > 0 &&  textFieldObj.tag != TIME_TAG && textFieldObj.tag!=HOUR_TAG)
            {
                G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
                [timeEntryCtrl updateUDFNumber:textFieldObj.text];
            }
        }
    }
	
   
		//	textField.textAlignment = NSTextAlignmentRight;
    
    
    // FOR TIMESHEET UDF's

else
    {
        if ([textFieldObj.text isEqualToString:@"" ]|| textFieldObj.text==nil || [textFieldObj.text isKindOfClass:[NSNull class] ] ) {
            textFieldObj.text=RPLocalizedString(@"Add", @"Add") ;
        }
    }

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textFieldObj {
	//[textFieldObj setText:@""];
    //US5053 Ullas M L
    if ([textFieldDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
    {
        G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
        
        if (textFieldObj.tag != TIME_TAG && textFieldObj.tag != HOUR_TAG)
        {
            if (timeEntryCtrl.lastUsedTextField.tag==TIME_TAG ||timeEntryCtrl.lastUsedTextField.tag==HOUR_TAG)
            {
                [timeEntryCtrl validateTimeEntryFieldValueInCell];
                if (timeEntryCtrl.isTimeFieldValueBreak) 
                {
                    timeEntryCtrl.isTimeFieldValueBreak=NO;
                    return NO;
                } 
            }
            

        }
        
    }
	if (numberKeyPad) {
		numberKeyPad.currentTextField = textFieldObj;
	}
	
		//textField.textAlignment = NSTextAlignmentCenter;
	
	if (textFieldObj.tag == TIME_TAG) {
               
        if ([textFieldDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
        {
            G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
             if(timeEntryCtrl.isTimeOffEnabledForTimeEntry)
             {
                 [textFieldDelegate performSelector:@selector(changeOfSegmentControlState:) withObject:[NSIndexPath indexPathForRow:2 inSection:0]];
             }
             else
             {
                 [textFieldDelegate performSelector:@selector(changeOfSegmentControlState:) withObject:[NSIndexPath indexPathForRow:1 inSection:0]];
             }
        }
        else
        {
            [textFieldDelegate performSelector:@selector(changeOfSegmentControlState:) withObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        }
       
		
	}
    else if (textFieldObj.tag == HOUR_TAG) {
        
        if ([textFieldDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
        {
            G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)textFieldDelegate;
            if(timeEntryCtrl.isTimeOffEnabledForTimeEntry)
            {
                [textFieldDelegate performSelector:@selector(changeOfSegmentControlState:) withObject:[NSIndexPath indexPathForRow:4 inSection:0]];
            }
            else
            {
               [textFieldDelegate performSelector:@selector(changeOfSegmentControlState:) withObject:[NSIndexPath indexPathForRow:3 inSection:0]];
            }
        }
        else
        {
           [textFieldDelegate performSelector:@selector(changeOfSegmentControlState:) withObject:[NSIndexPath indexPathForRow:3 inSection:0]];
        }

        
		
	}
    // FOR TIMESHEET UDF's
    else
    {
        if ([textFieldObj.text isEqualToString:RPLocalizedString(@"Add", @"Add") ]|| textFieldObj.text==nil || [textFieldObj.text isKindOfClass:[NSNull class] ] ) {
           textFieldObj.text=@"";
        }
    }
	
	return YES;
}


- (BOOL)textField:(UITextField *)textFieldObj shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    
     
	if ([textFieldObj textAlignment] == NSTextAlignmentRight) {
        if(textFieldObj.tag == TIME_TAG || textFieldObj.tag == HOUR_TAG )
        {
            [G2Util updateRightAlignedTextField:textFieldObj withString:string withRange:range withDecimalPlaces:2];

        }
        else
        {
            if ([(G2EntryCellDetails *)detailsObj decimalPoints] >=0) {
                [G2Util updateRightAlignedTextField:textFieldObj withString:string withRange:range withDecimalPlaces:[(G2EntryCellDetails *)detailsObj decimalPoints]];
            }
              
        }
         
        return NO;
	}
     
	return YES;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}




@end
