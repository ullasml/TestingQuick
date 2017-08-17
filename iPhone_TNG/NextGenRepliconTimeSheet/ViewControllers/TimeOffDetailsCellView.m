//
//  TimeOffDetailsCellView.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/3/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffDetailsCellView.h"
#import "Constants.h"

@interface TimeOffDetailsCellView() <UITextFieldDelegate>



@property (nonatomic,strong)UILabel *upperLefttLb;
@property (nonatomic,strong)UISlider *timeSlider;
@property (nonatomic,strong)UISlider *hoursSlider;
@property (nonatomic,strong)UILabel *weekLb;
@property (nonatomic,strong)UILabel *monthLb;
@property (nonatomic,strong)UILabel *dateLb;
@property (nonatomic,strong) UIButton *customDoneButton;
@property (nonatomic,strong) UIButton *customDotButton;
@property (nonatomic,strong) UIButton *customMinusButton;
@property (nonatomic,strong) UIImageView *hourAsterikImgView;
@property (nonatomic,strong) UIImageView *indicatorImageView;
@end

@implementation TimeOffDetailsCellView


-(instancetype) initWithFrame:(CGRect)frame  Style:(UITableViewCellStyle) style reuseIdentifier:(NSString *)identifier
{
    self =  [[TimeOffDetailsCellView alloc] initWithStyle:style reuseIdentifier:identifier];
    self.frame = frame;

    return self;
}


-(void)createCellLayoutWithParamsfiledname:(NSString*)upperstr fieldbutton:(NSString*)fieldstr time:(NSString*)timeStr hours:(NSString*)hourStr rowHeight:(NSInteger)rowHt
{
    CGFloat cellWidth = SCREEN_WIDTH;

    NSString *weekStr=nil;
    NSString *monthStr=nil;
    NSString *date=nil;
    self.rightLb = [[UILabel alloc] initWithFrame:CGRectMake((cellWidth/2), 13.0, (cellWidth/2)-12, 30.0)];
    [self.rightLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [self.rightLb setTextAlignment:NSTextAlignmentRight];
    [self.rightLb setNumberOfLines:1];
    [self.contentView addSubview:self.rightLb];

    if (self.selectedTag == 0) {
        self.upperLefttLb = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 13.0, (cellWidth/2)-12, 30.0)];
        [self.upperLefttLb setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
        [self.upperLefttLb setText:upperstr];
        [self.upperLefttLb setTag:self.selectedTag];
        [self.upperLefttLb setNumberOfLines:1];
        [self.contentView addSubview:self.upperLefttLb];
        
        [self.rightLb setText:fieldstr];
        [self.rightLb setHidden:NO];
    }

    if (self.selectedTag!=0)
    {
        if (([upperstr isEqualToString:RPLocalizedString(@"START DATE", @"")]&& self.selectedTag==1)||([upperstr isEqualToString:RPLocalizedString(@"END DATE", @"")] && self.selectedTag==2) )
        {
            NSRange textRange=[upperstr rangeOfString:RPLocalizedString(@"DATE", @"") options:NSBackwardsSearch];
            NSInteger index=textRange.location;
            if (index==0)
            {
                weekStr = [upperstr substringToIndex:index+textRange.length];
                monthStr=[upperstr substringFromIndex:textRange.length];
            }
            else
            {
                weekStr = [upperstr substringToIndex:index];
                monthStr=[upperstr substringFromIndex:index];
            }
            date=nil;
        }
        
        else {
            NSArray *componentsArr=[upperstr componentsSeparatedByString:@","];
            if ([componentsArr count]==4)
            {
                weekStr = [componentsArr objectAtIndex:0];
                monthStr =[componentsArr objectAtIndex:1];
                date=[componentsArr objectAtIndex:2];
            }
        }
        if (![self.rightLb.text isEqualToString:@"-" ])
        {
            [self.rightLb setHidden:YES];
        }
        
        NSString* weekString = [weekStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        UIFont *font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17];
        CGSize weekLbSize = [Util getHeightForString:weekStr font:font forWidth:100 forHeight:100];
        
        self.weekLb=[[UILabel alloc]initWithFrame:CGRectMake(12.0, 4, weekLbSize.width, weekLbSize.height)];
        [self.weekLb setTextColor:RepliconStandardBlackColor];
        [self.weekLb setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        [self.weekLb setTextAlignment:NSTextAlignmentLeft];
        [self.weekLb setText:weekString];
        [self.weekLb setTag:self.selectedTag];
        [self.weekLb setNumberOfLines:1];
        [self.contentView addSubview:self.weekLb];
        
        NSString* monthString = [monthStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        CGSize monthLbSize = [Util getHeightForString:monthStr font:font forWidth:100 forHeight:100];
        self.monthLb =[[UILabel alloc]initWithFrame:CGRectMake(9.0, 20, 70, 20)];
        [self.monthLb setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        self.monthLb.frame=CGRectMake(12.0, 24, monthLbSize.width, monthLbSize.height);

        [self.monthLb setTextColor:RepliconStandardBlackColor];
        [self.monthLb setTextAlignment:NSTextAlignmentLeft];
        [self.monthLb setText:monthString];
        [self.monthLb setTag:self.selectedTag];
        [self.monthLb setNumberOfLines:1];
        [self.contentView addSubview:self.monthLb];
        
        self.dateLb=[[UILabel alloc]initWithFrame:CGRectMake(50.0,4, 40, 40)];
        [self.dateLb setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_23]];
        [self.dateLb setTextAlignment:NSTextAlignmentCenter];
        [self.dateLb setAccessibilityIdentifier:@"uia_timeoff_date_selection_identifier"];
        [self.dateLb setText:date];
        [self.dateLb setTag:self.selectedTag];
        [self.dateLb setNumberOfLines:1];
        [self.contentView addSubview:self.dateLb];
  

        self.setTimeLb=[[UILabel alloc]initWithFrame:CGRectMake(12, 55, 145, 20)];
        [self.setTimeLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
        
        if (self.selectedTag==1) {
            [self.setTimeLb setText: RPLocalizedString(START_TIME, START_TIME)];
        }
        else {
            [self.setTimeLb setText: RPLocalizedString(END_TIME, END_TIME)] ;
        }
        
        [self.setTimeLb setTag:self.selectedTag];
        [self.contentView addSubview:self.setTimeLb];
        

        self.timeEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.timeEntryButton.frame=CGRectMake(12, 81,139, 43);
        self.timeEntryButton.tag=self.selectedTag;
        if (timeStr!=nil && ![timeStr isKindOfClass:[NSNull class]])
        {
            [self.timeEntryButton setTitle:timeStr forState:UIControlStateNormal];
        }
        [self.timeEntryButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        self.timeEntryButton.layer.borderColor=[[UIColor grayColor]CGColor];
        self.timeEntryButton.layer.borderWidth= 0.3f;
        [self.timeEntryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.timeEntryButton];
        

        self.setHourLb=[[UILabel alloc]initWithFrame:CGRectMake(162, 55, 145, 20)];
        [self.setHourLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        if ([fieldstr isEqualToString:HOURS]||[fieldstr isEqualToString:RPLocalizedString(PARTIAL, PARTIAL)])
            [self.setHourLb setTextAlignment:NSTextAlignmentLeft];
        else
            [self.setHourLb setTextAlignment:NSTextAlignmentRight];
        
        [self.setHourLb setText:RPLocalizedString(@"Hours", @"")];
        [self.setHourLb setTag:self.selectedTag];
        [self.setHourLb setNumberOfLines:1];
        [self.contentView addSubview:self.setHourLb];
        
      
        self.HourEntryField = [[UITextField alloc] initWithFrame:CGRectMake(161, 81,139, 43)];
        self.HourEntryField.tag=self.selectedTag;
        self.HourEntryField.font=[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17];
        self.HourEntryField.placeholder=[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
        [self.HourEntryField setDelegate:self];
        self.HourEntryField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.HourEntryField setTextAlignment:NSTextAlignmentLeft];
        [self.HourEntryField setHighlighted:YES];
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        self.HourEntryField.leftView = paddingView;
        self.HourEntryField.leftViewMode = UITextFieldViewModeAlways;
        self.HourEntryField.layer.cornerRadius=0.0f;
        self.HourEntryField.layer.masksToBounds=YES;
        self.HourEntryField.layer.borderColor=[[UIColor grayColor]CGColor];
        self.HourEntryField.layer.borderWidth= 0.3f;
        self.HourEntryField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.HourEntryField.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        self.HourEntryField.keyboardType = UIKeyboardTypeNumberPad;
        self.HourEntryField.keyboardAppearance = UIKeyboardAppearanceDark;
        if (hourStr!=nil && ![hourStr isKindOfClass:[NSNull class]])
        {
            [self.HourEntryField setText:hourStr];
        }
        [self.HourEntryField setReturnKeyType:UIReturnKeyDefault];
        [self.contentView addSubview:self.HourEntryField];
        
        
    }
    if (self.selectedTag==1||self.selectedTag==2) {
        self.fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fieldButton setFrame:CGRectMake((cellWidth/2), 0, (cellWidth/2)-12, 57)];
        self.fieldButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.fieldButton setTitle:fieldstr forState:UIControlStateNormal];
        [self.fieldButton setTitleColor:[Util colorWithHex:@"#0078cc" alpha:1.0f] forState:UIControlStateNormal];
        [self.fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];

        [self.fieldButton setTag:self.selectedTag];
        
        [self.contentView addSubview:self.fieldButton];
    }
    
    if (self.selectedTag==0)
    {
        rowHt=57;
    }
    else {
        if (rowHt!=58)
        {
            rowHt-=2;
        }
        else {
            rowHt=57.7;
        }
    }
    
    if(self.selectedTag==1|| self.selectedTag==2){
        if (self.indicatorImageView == nil){
            self.indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        }

        if ([monthStr isEqualToString:@"DATE"])
        {
            [self.indicatorImageView setFrame:CGRectMake(70, 17, self.indicatorImageView.frame.size.width, self.indicatorImageView.frame.size.height)];
        }
        else {
            [self.indicatorImageView setFrame:CGRectMake(109, 17, self.indicatorImageView.frame.size.width, self.indicatorImageView.frame.size.height)];
        }

        [self.contentView addSubview:self.indicatorImageView];
    }
}


-(void)TimeOffDetailsDayTypeSelection:(NSIndexPath *)selectedIndex
{
    NSLog(@"Selected Index %ld",(long)selectedIndex.row);
}
#pragma mark Textfield Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([self.timeOffBalanceCalculationDelegate respondsToSelector:@selector(removePickerWhileEditing)])
    {
       [self.timeOffBalanceCalculationDelegate removePickerWhileEditing];
    }
    
    if([self.timeOffBalanceCalculationDelegate respondsToSelector:@selector(removeDatePickerWhileEditing)])
    {
       [self.timeOffBalanceCalculationDelegate removeDatePickerWhileEditing];
    }
    
    [self startObservingFirstResponder];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentRight) {
        [Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:2];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.HourEntryField) {
        [self removecustomButton];
    }
    if ([self.timeOffBalanceCalculationDelegate respondsToSelector:@selector(calculateBalanceAfterHoursEntered::)]) {
        [self.timeOffBalanceCalculationDelegate calculateBalanceAfterHoursEntered:textField.text :self.selectedTag];
    }
}

#pragma mark Custom Keyboard Button methods

-(void)createCustomButton
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIButton *doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.adjustsImageWhenHighlighted = NO;
    CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
    height = height > 0 ? height : 53;
    doneButton.frame = CGRectMake((ONE_THIRD_SCREEN_WIDTH*2)+2, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-1, height);
    [doneButton setBackgroundImage:[UIImage imageNamed:DONE_BUTTON_IMAGE_iOS7] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[UIImage imageNamed:DONE_BUTTON_IMAGE_iOS7] forState:UIControlStateHighlighted];
    [doneButton setTag:DONE_BUTTON_TAG];
    [doneButton addTarget:self action:@selector(resignNumberHourTextField) forControlEvents:UIControlEventTouchUpInside];
    self.customDoneButton=doneButton;
    
    UIButton *dotButton=[UIButton buttonWithType:UIButtonTypeCustom];
    dotButton.adjustsImageWhenHighlighted = NO;
    dotButton.frame = CGRectMake(0, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-2, height);
    [dotButton setImage:nil forState:UIControlStateHighlighted];
    [dotButton setTitle:[Util detectDecimalMark] forState:UIControlStateNormal];
    [dotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dotButton.titleLabel.font=[UIFont fontWithName:RepliconFontFamilyRegular size:20];
    [dotButton setTag:DOT_BUTTON_TAG];
    [dotButton addTarget:self action:@selector(symbolButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.customDotButton=dotButton;
}

-(void)resignNumberHourTextField
{
    [self removecustomButton];
    [self.HourEntryField resignFirstResponder];
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
        [keyboardWindow addSubview:self.customMinusButton];
    });
}

-(void)observeBeginEditing:(NSNotification*)notification
{
    if ([self.HourEntryField isFirstResponder])
        [self addDotButtonToKeyboard];
    else
        [self removecustomButton];
}

- (void)observeEndEditing:(NSNotification*)notification
{
    if ([self.HourEntryField isFirstResponder])
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
    [self.HourEntryField setTextColor:RepliconStandardBlackColor];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(observeBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [center addObserver:self selector:@selector(observeEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
}

- (void)stopObservingFirstResponder {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [center removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
    [self.HourEntryField setTextColor:RepliconStandardBlackColor];
}

-(void)symbolButtonTapped:(id)sender
{
    NSString *dotString=[Util detectDecimalMark];
    NSString *string = self.HourEntryField.text;
    if ([string rangeOfString:dotString].location == NSNotFound)
        self.HourEntryField.text=[self.HourEntryField.text stringByAppendingString:dotString];
    
}

-(void)minusButtonTapped:(id)sender
{
    NSString *dotString=[Util detectDecimalMark];
    NSString *minusString=@"-";
    NSString *string = self.HourEntryField.text;
    if ([string rangeOfString:dotString].location == NSNotFound && [string rangeOfString:minusString].location == NSNotFound)
        self.HourEntryField.text=[self.HourEntryField.text stringByAppendingString:minusString];
    
}

@end
