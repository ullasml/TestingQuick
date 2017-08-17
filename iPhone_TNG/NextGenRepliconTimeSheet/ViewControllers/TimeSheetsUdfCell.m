//
//  TimeSheetsUdfCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 1/14/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeSheetsUdfCell.h"
#import "Constants.h"
#import "UIView+Additions.h"


@interface TimeSheetsUdfCell ()
@property (nonatomic,strong) UdfObject *udfObject;
@property (nonatomic,strong) UIButton *customDoneButton;
@property (nonatomic,strong) UIButton *customDotButton;
@property (nonatomic,strong) UIButton *customMinusButton;
@end
@implementation TimeSheetsUdfCell


-(void)createTimesheetUdfViewCellWithUdfObject:(UdfObject *)udfObject withTimesheetListObject:(TimesheetListObject *)timesheetListObject{
    
    [self setUdfObject:udfObject];
    UILabel *udfNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 8.0, CGRectGetWidth(self.contentView.bounds) - 167, 30.0)];
    udfNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [udfNameLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
    [udfNameLabel setText:[_udfObject udfName]];
    [self.contentView addSubview:udfNameLabel];
    id tmp=[udfObject defaultValue];
    
    BOOL isDefaultValuePresent=YES;
    if (tmp==nil || [tmp isKindOfClass:[NSNull class]]) {
        isDefaultValuePresent=NO;
    }
    else {
        if ([tmp isKindOfClass:[NSString class]]) {
            if ([tmp isEqualToString:RPLocalizedString(ADD_STRING, @"")]|[tmp isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                isDefaultValuePresent=NO;
            }
        }
    }
    
    
    if ([udfObject udfType]==UDF_TYPE_NUMERIC)
    {
        UITextField *udfValueTextField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.bounds) - 155, 8, 140, 30)];
        udfValueTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        udfValueTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [udfValueTextField setTextColor:RepliconStandardBlackColor];
        [udfValueTextField setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [udfValueTextField setTextAlignment:NSTextAlignmentRight];
        [udfValueTextField setBackgroundColor:[UIColor clearColor]];
        [udfValueTextField setBorderStyle:UITextBorderStyleNone];
        [udfValueTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [udfValueTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        [udfValueTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [udfValueTextField setDelegate:self];
        
        if (isDefaultValuePresent)
            [udfValueTextField setText:[NSString stringWithFormat:@"%@",tmp]];
        else
            [udfValueTextField setText:RPLocalizedString(ADD_STRING, @"")];
        
        udfValueTextField.keyboardType = UIKeyboardTypeNumberPad;
        udfValueTextField.keyboardAppearance=UIKeyboardAppearanceDark;
        self.numberUdfTextField=udfValueTextField;
        [self.contentView addSubview:udfValueTextField];
    }
    else
    {
        UILabel *udfValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.bounds) - 155, 8.0 ,143, 30.0)];
        udfValueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [udfValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [udfValueLabel setTextAlignment:NSTextAlignmentRight];
        if ([udfObject udfType]==UDF_TYPE_DATE) {
            if (isDefaultValuePresent)
                [udfValueLabel setText:tmp];
            else
                [udfValueLabel setText:RPLocalizedString(SELECT_STRING, @"")];
        }
        else if ([udfObject udfType]==UDF_TYPE_DROPDOWN)
        {
            if (isDefaultValuePresent)
                [udfValueLabel setText:[NSString stringWithFormat:@"%@",tmp]];
            else
                [udfValueLabel setText:RPLocalizedString(SELECT_STRING, @"")];
        }
        else if ([udfObject udfType]==UDF_TYPE_TEXT)
        {
            
            if ([tmp isKindOfClass:[NSString class]] && [tmp isEqualToString:@""])
                    isDefaultValuePresent=NO;

            if (isDefaultValuePresent)
                [udfValueLabel setText:[NSString stringWithFormat:@"%@",tmp]];
            else
                [udfValueLabel setText:RPLocalizedString(ADD_STRING, @"")];
        
        }
        self.udfValueLabel=udfValueLabel;
        [self.contentView addSubview:udfValueLabel];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configureSubViews];
}

- (void)configureSubViews {
    UIButton *udfCellButton = [[UIButton alloc]initWithFrame:[self bounds]];
    [udfCellButton setBackgroundColor:[UIColor clearColor]];
    [udfCellButton addTarget:self action:@selector(udfButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:udfCellButton];
}

#pragma mark Textfield Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([[self udfObject] udfType]==UDF_TYPE_NUMERIC)
    {
        [self startObservingFirstResponder];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.numberUdfTextField) {
        [self removecustomButton];
    }
    [self.udfObject setDefaultValue:textField.text];
    if ([self.udfActionDelegate respondsToSelector:@selector(numberUdfValueUpdatedOnCell:withUdfObject:)]) {
        [self.udfActionDelegate numberUdfValueUpdatedOnCell:self withUdfObject:[self udfObject]];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark Other Methods
-(void)udfButtonAction:(id)sender
{
    if ([self.numberUdfTextField isFirstResponder] && [[self udfObject] udfType]==UDF_TYPE_NUMERIC) {
        self.numberUdfTextField.text=@"";
    }
    else{
        if ([[self udfObject] udfType]==UDF_TYPE_NUMERIC){
            [self.numberUdfTextField becomeFirstResponder];
            if ([self.numberUdfTextField.text isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                self.numberUdfTextField.text=@"";
        }
        
        if ([self.udfActionDelegate respondsToSelector:@selector(timeSheetsUdfCellSelected:withUdfObject:)]) {
            [self.udfActionDelegate timeSheetsUdfCellSelected:self  withUdfObject:[self udfObject] ];
        }
    }
    
}

-(void)resignNumberUdfTextField
{
    [self removecustomButton];
    if (self.numberUdfTextField.text != nil  && [self.numberUdfTextField.text isEqualToString:@""])
        self.numberUdfTextField.text = RPLocalizedString(ADD_STRING, @"");
    [self.numberUdfTextField resignFirstResponder];
}

#pragma mark Custom Keyboard Button methods

-(void)createCustomButton
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIButton *doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat keyBoardKeyWidth = screenRect.size.width/3;

    doneButton.adjustsImageWhenHighlighted = NO;
    doneButton.frame = CGRectMake((keyBoardKeyWidth*2)+2, screenRect.size.height-55, keyBoardKeyWidth, 55); // +2 is added for the divider line for every key
    [doneButton setTitle:RPLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor colorWithRed:89.0/255.0f green:89.0/255.0f blue:89.0/255.0f alpha:1.0]];
    [doneButton addTarget:self action:@selector(resignNumberUdfTextField) forControlEvents:UIControlEventTouchUpInside];
    self.customDoneButton=doneButton;
    
    UIButton *dotButton=[UIButton buttonWithType:UIButtonTypeCustom];
    dotButton.adjustsImageWhenHighlighted = NO;
    dotButton.frame = CGRectMake(0, screenRect.size.height-55, keyBoardKeyWidth, 55);
    [dotButton setImage:nil forState:UIControlStateHighlighted];
    [dotButton setTitle:[Util detectDecimalMark]forState:UIControlStateNormal];
    [dotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dotButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:20];
    [dotButton addTarget:self action:@selector(symbolButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.customDotButton=dotButton;
    
    UIButton *minusButton=[UIButton buttonWithType:UIButtonTypeCustom];
    minusButton.adjustsImageWhenHighlighted = NO;
    minusButton.frame = CGRectMake(53, screenRect.size.height-53, 52, 53.5);
//    [minusButton setTitle:@"-" forState:UIControlStateNormal];
    [minusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    minusButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:20];
    [minusButton addTarget:self action:@selector(minusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.customMinusButton=minusButton;
}
-(void)addDotButtonToKeyboard
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createCustomButton];
        NSArray *allWindows = [[UIApplication sharedApplication] windows];
        NSInteger topWindow = [allWindows count] - 1;
        UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
        [keyboardWindow addSubview:self.customDoneButton];
        [keyboardWindow addSubview:self.customDotButton];
        //[keyboardWindow addSubview:self.customMinusButton];
    });
    
}

-(void)observeBeginEditing:(NSNotification*)notification
{
    if ([self.numberUdfTextField isFirstResponder])
        [self addDotButtonToKeyboard];
    else
        [self removecustomButton];
}

- (void)observeEndEditing:(NSNotification*)notification
{
    if ([self.numberUdfTextField isFirstResponder])
        [self removecustomButton];
}

-(void)removecustomButton
{
    [self.customDoneButton removeFromSuperview];
    [self.customDotButton removeFromSuperview];
    [self.customMinusButton removeFromSuperview];
    [self stopObservingFirstResponder];
}


- (void)startObservingFirstResponder
{
    [self.numberUdfTextField setTextColor:RepliconStandardBlackColor];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(observeBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [center addObserver:self selector:@selector(observeEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
}

- (void)stopObservingFirstResponder {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [center removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [self.numberUdfTextField setTextColor:RepliconStandardBlackColor];
}

-(void)symbolButtonTapped:(id)sender
{
    NSString *dotString=[Util detectDecimalMark];
    NSString *string = self.numberUdfTextField.text;
    if ([string rangeOfString:dotString].location == NSNotFound)
        self.numberUdfTextField.text=[self.numberUdfTextField.text stringByAppendingString:dotString];
    
}

-(void)minusButtonTapped:(id)sender
{
    NSString *dotString=[Util detectDecimalMark];
    NSString *minusString=@"-";
    NSString *string = self.numberUdfTextField.text;
    if ([string rangeOfString:dotString].location == NSNotFound && [string rangeOfString:minusString].location == NSNotFound)
        self.numberUdfTextField.text=[self.numberUdfTextField.text stringByAppendingString:minusString];
    
}
@end
