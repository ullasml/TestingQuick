//
//  InOutEntryDetailsCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 28/11/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "InOutEntryDetailsCustomCell.h"
#import "Util.h"
#import "Constants.h"
#import "ExtendedInOutEntryViewController.h"

#import "AppDelegate.h"
#import "EntryCellDetails.h"
#import "EditEntryViewController.h"
#import "OEFObject.h"
#import "UIView+Additions.h"


#define PADDING 10
#define LABEL_WIDTH ((SCREEN_WIDTH/2) - (2*PADDING))

@implementation InOutEntryDetailsCustomCell
@synthesize fieldValue;
@synthesize fieldName;
@synthesize fieldButton;
@synthesize udfType;
@synthesize delegate;
@synthesize numberKeyPad;
@synthesize decimalPoints;
@synthesize totalCount;
@synthesize isNonEditable;

-(void)createCellLayoutWithParamsWithFieldName:(NSString *)fieldNameStr withFieldValue:(NSString *)fieldValueStr isEditState:(BOOL)isEditState
{
    if (fieldName==nil)
    {
        UILabel *tempfieldName = [[UILabel alloc]init];
        self.fieldName=tempfieldName;
        
    }
    
    [self.fieldName setFrame:CGRectMake(PADDING, 8, LABEL_WIDTH, 30)];
    [self.fieldName setTextColor:RepliconStandardBlackColor];
    [self.fieldName setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
    [self.fieldName setUserInteractionEnabled:NO];
    [self.fieldName setBackgroundColor:[UIColor clearColor]];

    [self addSubview:fieldName];
    
    if (fieldValue==nil)
    {
        UITextField *tempfieldValue = [[UITextField alloc]init];
        self.fieldValue=tempfieldValue;
        
    }
    self.fieldValue.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.fieldValue setFrame:CGRectMake(self.fieldName.right+PADDING, 8, LABEL_WIDTH, 30)];
    [self.fieldValue setTextColor:RepliconStandardBlackColor];
    [self.fieldValue setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
    [self.fieldValue setTextAlignment:NSTextAlignmentRight];
    [self.fieldValue setBackgroundColor:[UIColor clearColor]];
    self.fieldValue.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.fieldValue.returnKeyType = UIReturnKeyDone;
    self.fieldValue.borderStyle = UITextBorderStyleNone;
    [self.fieldValue setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.fieldValue setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [self.fieldValue setDelegate:self];
    [self.fieldValue setHidden:YES];
    [self addSubview:self.fieldValue];
    
    if (fieldButton == nil) {
        
        UILabel *tempfieldButton = [[UILabel alloc]init];
        self.fieldButton=tempfieldButton;
        
        
    }
    [fieldButton setFrame:CGRectMake(self.fieldName.right+PADDING,
                                     8.0,
                                     LABEL_WIDTH,
                                     30.0)];
    [fieldButton setBackgroundColor:[UIColor clearColor]];
    [self.fieldButton setTextAlignment:NSTextAlignmentRight];
    [fieldButton setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
    [fieldButton setTextColor:RepliconStandardBlackColor];
    [fieldButton setHidden:YES];
    [self addSubview:fieldButton];
    
    [self.fieldName setText:fieldNameStr];
    [self.fieldValue setText:fieldValueStr];
    
    [self.fieldName setAccessibilityIdentifier: @"uia_cell_level_udf_title_identifier"];
    [self.fieldButton setAccessibilityIdentifier: @"uia_cell_level_udf_value_identifier"];

    if (!isEditState)
    {
        [self.fieldName setUserInteractionEnabled:NO];
        [self.fieldValue setUserInteractionEnabled:NO];
        [self.contentView setUserInteractionEnabled:NO];
        [self.fieldButton setUserInteractionEnabled:NO];
    }
    
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isNonEditable==NO)
    {
        UITouch *touch = [touches anyObject];
        for (int i=0; i<totalCount; i++)
        {
            if (touch.view.tag==i)
            {
                if ([delegate isKindOfClass:[ExtendedInOutEntryViewController class]])
                {
                    ExtendedInOutEntryViewController *extendedInOutEntryViewController=(ExtendedInOutEntryViewController *)delegate;
                    if (extendedInOutEntryViewController.isEditState)
                    {
                        [extendedInOutEntryViewController doneClicked];
                        [[extendedInOutEntryViewController lastUsedTextField]resignFirstResponder];
                        
                        if ([udfType isEqualToString:UDFType_NUMERIC] || [udfType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                        {
                            if ([extendedInOutEntryViewController lastUsedTextField])
                            {
                                [extendedInOutEntryViewController setLastUsedTextField:nil];
                            }

                            if ([fieldValue.text isEqualToString:NULL_OBJECT_STRING])
                            {
                                fieldValue.text=@"";
                            }

                            [extendedInOutEntryViewController setLastUsedTextField:fieldValue];
                            
                        }
                        
                        [extendedInOutEntryViewController handleUdfCellClick:self.contentView.tag withType:udfType];
                    }
                    
                }
                else if ([delegate isKindOfClass:[EditEntryViewController class]])
                {
                    EditEntryViewController *dayTimeEntryEditViewController=(EditEntryViewController *)delegate;
                    if (dayTimeEntryEditViewController.isEditState)
                    {
                        [dayTimeEntryEditViewController doneClicked];
                        [[dayTimeEntryEditViewController lastUsedTextField]resignFirstResponder];
                        
                        if ([udfType isEqualToString:UDFType_NUMERIC]  || [udfType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                        {
                            if ([dayTimeEntryEditViewController lastUsedTextField])
                            {
                                [dayTimeEntryEditViewController setLastUsedTextField:nil];
                            }
                            [dayTimeEntryEditViewController setLastUsedTextField:fieldValue];
                            
                        }
                        
                        [dayTimeEntryEditViewController handleUdfCellClick:self.contentView.tag withType:udfType];
                    }
                    
                }
            }
            
        }
    }
    
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.hidden=NO;
    if ([textField.text isEqualToString:RPLocalizedString(ADD, @"") ])
    {
        textField.text=@"";
    }
    
    if ([delegate isKindOfClass:[ExtendedInOutEntryViewController class]])
    {
        
        
        if (!self.numberKeyPad)
        {
            self.numberKeyPad.isDonePressed=NO;
            self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:delegate withMinus:NO andisDoneShown:YES withResignButton:NO];
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
        
        ExtendedInOutEntryViewController *extendedInOutEntryViewController=(ExtendedInOutEntryViewController *)delegate;
        
        if ([extendedInOutEntryViewController lastUsedTextField])
        {
            [extendedInOutEntryViewController setLastUsedTextField:nil];
        }
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[extendedInOutEntryViewController. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:extendedInOutEntryViewController.selectedUdfCell inSection:0]];
        [cell setSelected:NO animated:NO];
        
        InOutEntryDetailsCustomCell *currentcell = (InOutEntryDetailsCustomCell *)[extendedInOutEntryViewController. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.contentView.tag inSection:0]];
        [currentcell setSelected:YES animated:NO];
        [extendedInOutEntryViewController resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        extendedInOutEntryViewController.datePicker.hidden=YES;
        extendedInOutEntryViewController.toolbar.hidden=YES;
        [extendedInOutEntryViewController.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.contentView.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [extendedInOutEntryViewController resetTableSize:YES isFromUdf:YES isDateUdf:NO];
        
        extendedInOutEntryViewController.selectedUdfCell=self.contentView.tag;
        if ([fieldValue.text isEqualToString:NULL_OBJECT_STRING])
        {
            fieldValue.text=@"";
        }
        [extendedInOutEntryViewController setLastUsedTextField:fieldValue];
        
    }
    else if ([delegate isKindOfClass:[EditEntryViewController class]])
    {
        
        
        if (!self.numberKeyPad)
        {
            self.numberKeyPad.isDonePressed=NO;
            self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:delegate withMinus:NO andisDoneShown:YES withResignButton:NO];
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
        
        EditEntryViewController *extendedInOutEntryViewController=(EditEntryViewController *)delegate;
        
        if ([extendedInOutEntryViewController lastUsedTextField])
        {
            [extendedInOutEntryViewController setLastUsedTextField:nil];
        }
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[extendedInOutEntryViewController. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:extendedInOutEntryViewController.selectedUdfCell inSection:0]];
        [cell setSelected:NO animated:NO];
        
        InOutEntryDetailsCustomCell *currentcell = (InOutEntryDetailsCustomCell *)[extendedInOutEntryViewController. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.contentView.tag inSection:0]];
        [currentcell setSelected:YES animated:NO];
        [extendedInOutEntryViewController resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        extendedInOutEntryViewController.datePicker.hidden=YES;
        extendedInOutEntryViewController.toolbar.hidden=YES;
        [extendedInOutEntryViewController.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.contentView.tag inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [extendedInOutEntryViewController resetTableSize:YES isFromUdf:YES isDateUdf:NO];
        
        extendedInOutEntryViewController.selectedUdfCell=self.contentView.tag;
        if ([fieldValue.text isEqualToString:NULL_OBJECT_STRING])
        {
            fieldValue.text=@"";
        }
        [extendedInOutEntryViewController setLastUsedTextField:fieldValue];
        
    }
    
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentRight)
    {
		[Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:decimalPoints];
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
            if ([delegate isKindOfClass:[ExtendedInOutEntryViewController class]])
            {
                if([textField.text length] > 0)
                {
                    [self updateUDFNumber:textField.text];
                }
                if ([textField.text length] == 0 ){
                    textField.text=RPLocalizedString(ADD, @"");
                    [self updateUDFNumber:textField.text];
                    
                }
            }
            if ([delegate isKindOfClass:[EditEntryViewController class]])
            {
                if([textField.text length] > 0)
                {
                    [self updateUDFNumber:textField.text];
                }
                if ([textField.text length] == 0 ){
                    textField.text=RPLocalizedString(ADD, @"");
                    [self updateUDFNumber:textField.text];
                    
                }
            }
            numberKeyPad.isDonePressed=NO;
            
        }
        else
        {
            if([textField.text length] > 0)
            {
                textField.text=[Util getRoundedValueFromDecimalPlaces:[textField.text newDoubleValue] withDecimalPlaces:decimalPoints];
                [self updateUDFNumber:textField.text];
            }
        }
        
		self.numberKeyPad = nil;
        
	}
    if ([delegate isKindOfClass:[ExtendedInOutEntryViewController class]])
    {
        ExtendedInOutEntryViewController *extendedInOutEntryViewController=(ExtendedInOutEntryViewController *)delegate;
        if ([extendedInOutEntryViewController lastUsedTextField])
        {
            [extendedInOutEntryViewController resetTableSize:NO isFromUdf:NO isDateUdf:NO];
            [self setSelected:NO animated:NO];
        }
        
    }
    else if ([delegate isKindOfClass:[EditEntryViewController class]])
    {
        EditEntryViewController *extendedInOutEntryViewController=(EditEntryViewController *)delegate;
        if ([extendedInOutEntryViewController lastUsedTextField])
        {
            [extendedInOutEntryViewController resetTableSize:NO isFromUdf:NO isDateUdf:NO];
            [self setSelected:NO animated:NO];
        }
        
    }
    
    if ([textField.text length] == 0 )
    {
        textField.text=RPLocalizedString(ADD, @"");
        [self updateUDFNumber:textField.text];
        
    }
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
-(void)updateUDFNumber:(NSString *)UdfNumberEntered
{
    
    NSInteger decimals = decimalPoints;
    NSString *tempValue =nil;
	if ([UdfNumberEntered isEqualToString:RPLocalizedString(ADD, @"")])
    {
        tempValue=UdfNumberEntered;
    }
    else
        tempValue=[Util getRoundedValueFromDecimalPlaces:[[fieldValue text] newDoubleValue] withDecimalPlaces:decimals];
    tempValue = [Util removeCommasFromNsnumberFormaters:tempValue];
    
    if (tempValue == nil)
    {
        tempValue = [fieldValue text];
        
    }
    else
    {
        [fieldValue setText: tempValue];
    }
    
    if ([delegate isKindOfClass:[ExtendedInOutEntryViewController class]])
    {
        ExtendedInOutEntryViewController *currentTimesheetCtrl=(ExtendedInOutEntryViewController *)delegate;
        [self.fieldValue setHidden:YES];
        [self.fieldButton setHidden:NO];
        [self.fieldButton setText:[fieldValue text]];

        if (currentTimesheetCtrl.isGen4UserTimesheet)
        {
            OEFObject *oefObject=[currentTimesheetCtrl.oefFieldArray objectAtIndex:self.contentView.tag];
            [oefObject setOefNumericValue:[fieldValue text]];
        }
        else
        {
            EntryCellDetails *udfDetails=[currentTimesheetCtrl.userFieldArray objectAtIndex:self.contentView.tag];
            NSString *udfTypee=[udfDetails fieldType];
            NSString *udfName=[udfDetails fieldName];
            NSString *udfUri=[udfDetails udfIdentity];
            NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
            NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
            NSString *udfDefaultValue=[udfDetails defaultValue];
            NSString *udfIdentity=[udfDetails udfIdentity];
            NSString *udfModule=[udfDetails udfModule];

            EntryCellDetails *newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
            [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
            [newCellDetails setFieldName:udfName];
            [newCellDetails setUdfIdentity:udfUri];
            [newCellDetails setDropdownOptionUri:dropdownOptionUri];
            [newCellDetails setUdfIdentity:udfIdentity];
            [newCellDetails setUdfModule:udfModule];
            [newCellDetails setFieldType:udfTypee];
            [newCellDetails setFieldValue:[fieldValue text]];
            [newCellDetails setDefaultValue:[fieldValue text]];
            [currentTimesheetCtrl.userFieldArray  replaceObjectAtIndex:self.contentView.tag withObject:newCellDetails];
        }


    }
    if ([delegate isKindOfClass:[EditEntryViewController class]])
    {
        EditEntryViewController *currentTimesheetCtrl=(EditEntryViewController *)delegate;
        [self.fieldValue setHidden:YES];
        [self.fieldButton setHidden:NO];
        [self.fieldButton setText:[fieldValue text]];
        if ([currentTimesheetCtrl.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            OEFObject *oefObject=[currentTimesheetCtrl.oefFieldArray objectAtIndex:self.contentView.tag];
            [oefObject setOefNumericValue:[fieldValue text]];
        }
        else
        {
            EntryCellDetails *udfDetails=[currentTimesheetCtrl.userFieldArray objectAtIndex:self.contentView.tag];
            NSString *udfTypee=[udfDetails fieldType];
            NSString *udfName=[udfDetails fieldName];
            NSString *udfUri=[udfDetails udfIdentity];
            NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
            NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
            NSString *udfDefaultValue=[udfDetails defaultValue];
            NSString *udfIdentity=[udfDetails udfIdentity];
            NSString *udfModule=[udfDetails udfModule];

            EntryCellDetails *newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
            [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
            [newCellDetails setFieldName:udfName];
            [newCellDetails setUdfIdentity:udfUri];
            [newCellDetails setDropdownOptionUri:dropdownOptionUri];
            [newCellDetails setUdfIdentity:udfIdentity];
            [newCellDetails setUdfModule:udfModule];
            [newCellDetails setFieldType:udfTypee];
            [newCellDetails setFieldValue:[fieldValue text]];
            [newCellDetails setDefaultValue:[fieldValue text]];
            [currentTimesheetCtrl.userFieldArray  replaceObjectAtIndex:self.contentView.tag withObject:newCellDetails];
        }


    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected)
    {
        self.fieldValue.textColor = RepliconStandardBlackColor;
    }
    
    else
    {
        self.fieldValue.textColor = RepliconStandardBlackColor;
    }

    [super setSelected:selected animated:animated];
}

@end
