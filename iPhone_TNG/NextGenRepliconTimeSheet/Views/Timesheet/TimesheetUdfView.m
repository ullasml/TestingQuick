//
//  TimesheetUdfView.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 19/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "TimesheetUdfView.h"
#import "Constants.h"
#import "CurrentTimesheetViewController.h"
#import "Util.h"


@implementation TimesheetUdfView

@synthesize fieldName;
@synthesize fieldValue;
@synthesize udfType;
@synthesize delegate;
@synthesize totalCount;
@synthesize fieldButton;
@synthesize numberKeyPad;
@synthesize decimalPoints;
@synthesize isSelected;
#define textMovementDistanceFor4 166.66
#define numericMovementDistanceFor4 253.33
#define textMovementDistanceFor5 94.11
#define numericMovementDistanceFor5 170.58
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self drawLayout];
    }
    return self;
}
-(void)drawLayout
{
    if (fieldName==nil)
    {
        UILabel *tempfieldName = [[UILabel alloc]init];
        self.fieldName=tempfieldName;
        
    }
    
     [self setBackgroundColor:[UIColor whiteColor]];
    
    [self.fieldName setFrame:CGRectMake(12, 8, SCREEN_WIDTH-183, 30)];
    [self.fieldName setTextColor:[UIColor blackColor]];
    [self.fieldName setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
    [self.fieldName setUserInteractionEnabled:NO];
    [self.fieldName setBackgroundColor:[UIColor clearColor]];
    [self.fieldName setHighlightedTextColor:RepliconStandardWhiteColor];
    [self addSubview:fieldName];


    if (fieldValue==nil)
    {
        UITextField *tempfieldValue = [[UITextField alloc]init];
        self.fieldValue=tempfieldValue;
       
    }
    self.fieldValue.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.fieldValue setFrame:CGRectMake(SCREEN_WIDTH-140-5, 8, 140, 30)];
    [self.fieldValue setTextColor:[UIColor blackColor]];
    [self.fieldValue setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [self.fieldValue setTextAlignment:NSTextAlignmentRight];
    [self.fieldValue setBackgroundColor:[UIColor clearColor]];
    self.fieldValue.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.fieldValue.returnKeyType = UIReturnKeyDone;
    self.fieldValue.borderStyle = UITextBorderStyleNone;
    [self.fieldValue setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.fieldValue setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [self.fieldValue setDelegate:self];
    [self.fieldValue setHidden:YES];
    [self addSubview:fieldValue];

    
    [self.fieldName setAccessibilityIdentifier: @"uia_timesheet_level_udf_title_identifier"];
    [self.fieldValue setAccessibilityIdentifier: @"uia_timesheet_level_numeric_udf_value_identifier"];
    
    if (fieldButton == nil) {
        
        UILabel *tempfieldButton = [[UILabel alloc]init];
        self.fieldButton=tempfieldButton;
       
       
    }
    [fieldButton setFrame:CGRectMake(SCREEN_WIDTH-160-5,
                                     8.0,
                                     160.0,
                                     30.0)];
    [fieldButton setBackgroundColor:[UIColor clearColor]];
    [self.fieldButton setTextAlignment:NSTextAlignmentRight];
    [fieldButton setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [fieldButton setTextColor:[UIColor blackColor]];
    [fieldButton setHidden:YES];
    [self.fieldButton setHighlightedTextColor:RepliconStandardWhiteColor];
    [self.fieldButton setAccessibilityIdentifier: @"uia_timesheet_level_udf_value_identifier"];
    [self addSubview:fieldButton];

    [self setAccessibilityIdentifier:@"uia_udf_view_identifier"];
    
   
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (int i=0; i<totalCount; i++)
    {
        if (touch.view.tag==i+1)
        {
            if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
            {
                if (touch.tapCount==1)
                {
                    CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
                    [currentTimesheetCtrl doneClicked];
                    
                    [[currentTimesheetCtrl lastUsedTextField]resignFirstResponder];
                   
                    if ([udfType isEqualToString:NUMERIC_UDF_TYPE])
                    {
                        if ([currentTimesheetCtrl lastUsedTextField])
                        {
                            [currentTimesheetCtrl setLastUsedTextField:nil];
                        }
                        [currentTimesheetCtrl setLastUsedTextField:fieldValue];
                  
                    }
                    [currentTimesheetCtrl handleButtonClicks:self.tag withType:udfType];
                }
                
            }
            
            
        }
        
    }
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:RPLocalizedString(ADD, @"") ])
    {
        textField.text=@"";
    }
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        CGRect screenRect =[[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        float movementDistance=0.0;

        if (aspectRatio<1.7)
        {
            movementDistance=aspectRatio*textMovementDistanceFor4;
        }
        else
            movementDistance=aspectRatio*textMovementDistanceFor5;  //change this around
        if ([udfType isEqualToString:NUMERIC_UDF_TYPE])
        {
            if (aspectRatio<1.7)
            {
                movementDistance=aspectRatio*numericMovementDistanceFor4;
            }
            else
                movementDistance=aspectRatio*numericMovementDistanceFor5;
            if (!self.numberKeyPad) {
                self.numberKeyPad.isDonePressed=NO;
               self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:delegate withMinus:YES andisDoneShown:YES withResignButton:NO];
                if ([textField textAlignment] == NSTextAlignmentRight) {
                    [self.numberKeyPad.decimalPointButton setTag:333];
                }
            }else {
                //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
                self.numberKeyPad.currentTextField = textField;
            }
        }
        CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
        isSelected=YES;
        [self setSelectedColor:isSelected];
       // [currentTimesheetCtrl doneClicked];
        
        [[currentTimesheetCtrl currentTimesheetTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
       
            
        [currentTimesheetCtrl doneClicked];
        [currentTimesheetCtrl currentTimesheetTableView].contentOffset=CGPointMake(0.0,movementDistance);
        if ([currentTimesheetCtrl lastUsedTextField])
        {
            [currentTimesheetCtrl setLastUsedTextField:nil];
        }
        currentTimesheetCtrl.selectedUdfCell=self.tag;
        [currentTimesheetCtrl setLastUsedTextField:fieldValue];
        CGRect frame= [currentTimesheetCtrl currentTimesheetTableView].frame;
        frame.size.height=frame.size.height-190;
        [[currentTimesheetCtrl currentTimesheetTableView] setFrame:frame];
        
        NSInteger tag=self.tag;
        CGRect frameSize=currentTimesheetCtrl.footerView.frame;
        frameSize.origin.y=frameSize.origin.y+ (tag *46.0) - 60.0;
        
        [[currentTimesheetCtrl currentTimesheetTableView] setContentOffset:CGPointMake(0, frameSize.origin.y)];
       

    
    }
    
    
    // change size of UITableView
    
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentRight) {
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
    
        
        if ([numberKeyPad isDonePressed] )
        {
            if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
            {
                
                CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
                [[currentTimesheetCtrl currentTimesheetTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                [currentTimesheetCtrl currentTimesheetTableView].frame = CGRectMake(0,0,SCREEN_WIDTH,[currentTimesheetCtrl view].frame.size.height);
                //Fix for DE15561
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
            
        }//Fix for DE15561
        else{
            if([textField.text length] > 0)
            {
                textField.text=[Util getRoundedValueFromDecimalPlaces:[textField.text newDoubleValue] withDecimalPlaces:decimalPoints];
                [self updateUDFNumber:textField.text];
                //Fix for DE15534
                if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                {
                    
                    CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
                    if (currentTimesheetCtrl.isSaveClicked){
                        [[currentTimesheetCtrl currentTimesheetTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                        [currentTimesheetCtrl currentTimesheetTableView].frame = CGRectMake(0,0,SCREEN_WIDTH,[currentTimesheetCtrl view].frame.size.height);
                    }
                    
                    
                }
                
                
            }
        }
		self.numberKeyPad = nil;
        
	}

    
    if ([textField.text length] == 0 ){
        textField.text=RPLocalizedString(ADD, @"");
        [self updateUDFNumber:textField.text];
        
        //Fix for DE15534
        if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            
            CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
            if (currentTimesheetCtrl.isSaveClicked){
                [[currentTimesheetCtrl currentTimesheetTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                [currentTimesheetCtrl currentTimesheetTableView].frame = CGRectMake(0,0,SCREEN_WIDTH,[currentTimesheetCtrl view].frame.size.height);
            }
            
            
        }
        /*if ([delegate isKindOfClass:[BookedTimeOffEntryViewController class]])
        {
            
            BookedTimeOffEntryViewController *currentTimesheetCtrl=(BookedTimeOffEntryViewController *)delegate;
            if (currentTimesheetCtrl.isSaveClicked)
            {
                [[currentTimesheetCtrl tnewTimeEntryTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                [currentTimesheetCtrl tnewTimeEntryTableView].frame = CGRectMake(0,0,320,[currentTimesheetCtrl view].frame.size.height);
                
                [currentTimesheetCtrl setIsComment:TRUE];
                NSInteger tag=self.tag;
                CGRect frameSize=currentTimesheetCtrl.footerView.frame;
                frameSize.origin.y=frameSize.origin.y+currentTimesheetCtrl.commentsTextView.frame.size.height+(tag *46.0) -150.0;
                [currentTimesheetCtrl updateComments:[currentTimesheetCtrl commentsTextView].text ];
                [[currentTimesheetCtrl tnewTimeEntryTableView] setContentOffset:CGPointMake(0, frameSize.origin.y)];
            }
            
        }*/
    }
    
    if (isSelected)
    {
        isSelected=NO;
        [self setSelectedColor:isSelected];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        if (isSelected)
        {
            isSelected=NO;
            [self setSelectedColor:isSelected];
        }
        CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
        [[currentTimesheetCtrl currentTimesheetTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        [currentTimesheetCtrl currentTimesheetTableView].frame = CGRectMake(0,0,SCREEN_WIDTH,[currentTimesheetCtrl view].frame.size.height);
        
    }
    /*if ([delegate isKindOfClass:[BookedTimeOffEntryViewController class]])
    {
        if (isSelected)
        {
            isSelected=NO;
            [self setSelectedColor:isSelected];
        }
        BookedTimeOffEntryViewController *currentTimesheetCtrl=(BookedTimeOffEntryViewController *)delegate;
        [[currentTimesheetCtrl tnewTimeEntryTableView]scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        [currentTimesheetCtrl tnewTimeEntryTableView].frame = CGRectMake(0,0,320,[currentTimesheetCtrl view].frame.size.height);
        [currentTimesheetCtrl setIsComment:TRUE];
        NSInteger tag=self.tag;
        CGRect frameSize=currentTimesheetCtrl.footerView.frame;
        frameSize.origin.y=frameSize.origin.y+currentTimesheetCtrl.commentsTextView.frame.size.height+(tag *46.0) -150.0;
        [currentTimesheetCtrl updateComments:[currentTimesheetCtrl commentsTextView].text ];
        [[currentTimesheetCtrl tnewTimeEntryTableView] setContentOffset:CGPointMake(0, frameSize.origin.y)];
        
    }*/
    [textField resignFirstResponder];
    
    return YES; 
}
-(void)setSelectedColor:(BOOL)selected{
    
    if (selected)
    {
        self.backgroundColor=RepliconStandardBlueColor;
        [self.fieldValue setTextColor:[UIColor whiteColor]];
        [self.fieldName setTextColor:[UIColor whiteColor]];
        [self.fieldButton setTextColor:[UIColor whiteColor]];
    } else {
        self.backgroundColor=RepliconStandardBackgroundColor;
        [self.fieldValue setTextColor:RepliconStandardBlackColor];
        [self.fieldName setTextColor:RepliconStandardBlackColor];
        [self.fieldButton setTextColor:RepliconStandardBlackColor];
    }
}
-(void)updateUDFNumber:(NSString *)UdfNumberEntered{
   
    NSInteger decimals = decimalPoints;
    NSString *tempValue =nil;
	if ([UdfNumberEntered isEqualToString:RPLocalizedString(ADD, @"")]) {
        tempValue=UdfNumberEntered;
    }
    else
        tempValue=[Util getRoundedValueFromDecimalPlaces:[[fieldValue text] newDoubleValue] withDecimalPlaces:decimals];
    tempValue = [Util removeCommasFromNsnumberFormaters:tempValue];
    
    if (tempValue == nil) {
        tempValue = [fieldValue text];
        
    }else {
        [fieldValue setText: tempValue];
    }
    if (tempValue!=nil) {
        //do nothing here
    }
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        CurrentTimesheetViewController *currentTimesheetCtrl=(CurrentTimesheetViewController *)delegate;
        NSMutableDictionary *udfDetailDict=[currentTimesheetCtrl.customFieldArray objectAtIndex:self.tag-1];
         //MAX AND MIN VALUE FOR NUMERIC UDFs
//        if ([udfDetailDict objectForKey:@"defaultMinValue"]!=nil && ![[udfDetailDict objectForKey:@"defaultMinValue"]isKindOfClass:[NSNull class]])
//        {
//            if ([tempValue newDoubleValue]<[[udfDetailDict objectForKey:@"defaultMinValue"]newDoubleValue])
//            {
//                tempValue=[Util getRoundedValueFromDecimalPlaces:[[udfDetailDict objectForKey:@"defaultMinValue"] newDoubleValue] withDecimalPlaces:decimals];
//                [fieldValue setText: tempValue];
//            }
//        }
//        if ([udfDetailDict objectForKey:@"defaultMaxValue"]!=nil && ![[udfDetailDict objectForKey:@"defaultMaxValue"]isKindOfClass:[NSNull class]]) {
//            if ([tempValue newDoubleValue]>[[udfDetailDict objectForKey:@"defaultMaxValue"]newDoubleValue]){
//                tempValue=[Util getRoundedValueFromDecimalPlaces:[[udfDetailDict objectForKey:@"defaultMaxValue"] newDoubleValue] withDecimalPlaces:decimals];
//                [fieldValue setText: tempValue];
//            }
//
//        }
        [udfDetailDict removeObjectForKey:@"defaultValue"];
        [udfDetailDict setObject:[fieldValue text] forKey:@"defaultValue"];
        
        [currentTimesheetCtrl.customFieldArray replaceObjectAtIndex:self.tag-1 withObject:udfDetailDict];
        
    }
   /* if ([delegate isKindOfClass:[BookedTimeOffEntryViewController class]])
    {
        BookedTimeOffEntryViewController *currentTimesheetCtrl=(BookedTimeOffEntryViewController *)delegate;
       NSMutableDictionary *udfDetailDict=[currentTimesheetCtrl.customFieldArray objectAtIndex:self.tag-1];
        //MAX AND MIN VALUE FOR NUMERIC UDFs
//        if ([udfDetailDict objectForKey:@"defaultMinValue"]!=nil && ![[udfDetailDict objectForKey:@"defaultMinValue"]isKindOfClass:[NSNull class]])
//        {
//            if ([tempValue newDoubleValue]<[[udfDetailDict objectForKey:@"defaultMinValue"]newDoubleValue])
//            {
//                tempValue=[Util getRoundedValueFromDecimalPlaces:[[udfDetailDict objectForKey:@"defaultMinValue"] newDoubleValue] withDecimalPlaces:decimals];
//                [fieldValue setText: tempValue];
//            }
//        }
//        if ([udfDetailDict objectForKey:@"defaultMaxValue"]!=nil && ![[udfDetailDict objectForKey:@"defaultMaxValue"]isKindOfClass:[NSNull class]]) {
//            if ([tempValue newDoubleValue]>[[udfDetailDict objectForKey:@"defaultMaxValue"]newDoubleValue]){
//                tempValue=[Util getRoundedValueFromDecimalPlaces:[[udfDetailDict objectForKey:@"defaultMaxValue"] newDoubleValue] withDecimalPlaces:decimals];
//                [fieldValue setText: tempValue];
//            }
//            
//        }
        [udfDetailDict removeObjectForKey:@"defaultValue"];
        [udfDetailDict setObject:[fieldValue text] forKey:@"defaultValue"];
        
        [currentTimesheetCtrl.customFieldArray replaceObjectAtIndex:self.tag-1 withObject:udfDetailDict];
    }
   */
}

@end
