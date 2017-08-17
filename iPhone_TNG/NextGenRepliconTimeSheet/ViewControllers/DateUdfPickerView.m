//
//  DateUdfPickerView.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 1/16/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "DateUdfPickerView.h"
#import "Constants.h"
#import "UdfObject.h"


@interface DateUdfPickerView ()
@property (nonatomic,strong) UdfObject *udfObject;
@property (nonatomic,strong) UIDatePicker *datePickerView;
@end

@implementation DateUdfPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:RepliconStandardWhiteColor];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Done", @"") style: UIBarButtonItemStylePlain target: self action: @selector(donePickerAction:)];
        [doneButton setTag:1];
        doneButton.tintColor=RepliconStandardWhiteColor;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Cancel", @"") style: UIBarButtonItemStylePlain target: self action: @selector(cancelPickerAction:)];
        [cancelButton setTag:1];
        cancelButton.tintColor=RepliconStandardWhiteColor;
        
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Clear", @"") style: UIBarButtonItemStylePlain target: self action: @selector(clearPickerAction:)];
        [clearButton setTag:1];
        clearButton.tintColor=RepliconStandardWhiteColor;
        
        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil];
        
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, TOOL_BAR_HEIGHT)];
        toolbar.barStyle = UIBarStyleBlackOpaque;
        NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,clearButton,spaceButton,doneButton,nil];
        [toolbar setItems:toolArray];
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [toolbar setBarStyle:UIBarStyleBlackOpaque];
        UIDatePicker *datePickerView = [[UIDatePicker alloc]initWithFrame:CGRectMake(0 ,TOOL_BAR_HEIGHT, self.frame.size.width, PICKER_HEIGHT)];
        datePickerView.datePickerMode = UIDatePickerModeDate;
        datePickerView.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
        
        [datePickerView addTarget:self action:@selector(changePickerAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:datePickerView];
        [self addSubview:toolbar];
        self.datePickerView=datePickerView;

    }
    return self;
}


-(void)setUpDateUdfPickerViewWithUDFObject:(UdfObject *)udfObject
{
    [self setUdfObject:udfObject];
    id defaultValue=[udfObject defaultValue];
    if (defaultValue!=nil && ([defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] || [defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
    {
        self.datePickerView.date = [NSDate date];
        [self changePickerAction:nil];
    }
    else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [df setLocale:locale];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [df setDateFormat:@"MMMM d, yyyy"];
        NSDate *date =  [df dateFromString:defaultValue];
        self.datePickerView.date = date;

    }
}

-(void)changePickerAction:(id)sender
{
    [self updateDateUdfObjectWithDate:self.datePickerView.date];
    if ([self.dateUdfActionDelegate respondsToSelector:@selector(dateUdfPickerChanged:withUdfObject:)]) {
        [self.dateUdfActionDelegate dateUdfPickerChanged:self  withUdfObject:[self udfObject]];
    }
}
-(void)cancelPickerAction:(id)sender
{
    [self updateDateUdfObjectWithDate:nil];
    if ([self.dateUdfActionDelegate respondsToSelector:@selector(dateUdfPickerCancel:withUdfObject:)]) {
        [self.dateUdfActionDelegate dateUdfPickerCancel:self  withUdfObject:[self udfObject]];
    }
}
-(void)clearPickerAction:(id)sender
{
    [self updateDateUdfObjectWithDate:nil];
    if ([self.dateUdfActionDelegate respondsToSelector:@selector(dateUdfPickerClear:withUdfObject:)]) {
        [self.dateUdfActionDelegate dateUdfPickerClear:self  withUdfObject:[self udfObject]];
    }
}
-(void)donePickerAction:(id)sender
{
    id defaultValue=[self.udfObject defaultValue];
    if (defaultValue!=nil && [defaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        [self updateDateUdfObjectWithDate:nil];
    else
        [self updateDateUdfObjectWithDate:self.datePickerView.date];
    
    if ([self.dateUdfActionDelegate respondsToSelector:@selector(dateUdfPickerDone:withUdfObject:)]) {
        [self.dateUdfActionDelegate dateUdfPickerDone:self  withUdfObject:[self udfObject]];
    }
}

-(void)updateDateUdfObjectWithDate:(NSDate *)date
{
    if (date==nil)
    {
        [self.udfObject setDefaultValue:RPLocalizedString(SELECT_STRING, @"")];
    }
    else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [df setLocale:locale];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [df setDateFormat:@"MMMM d, yyyy"];
        NSString *dateInString =  [df stringFromDate:date];
        [self.udfObject setDefaultValue:dateInString];
    }
    
}

@end
