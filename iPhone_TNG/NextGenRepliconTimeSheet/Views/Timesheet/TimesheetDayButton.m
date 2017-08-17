//
//  TimesheetDayButton.m
//  InOutTest
//
//  Created by Abhishek Nimbalkar on 5/13/13.
//  Copyright (c) 2013 Aby Nimbalkar. All rights reserved.
//

#import "TimesheetDayButton.h"
#import "Constants.h"
#import "Util.h"

@interface TimesheetDayButton ()

@property(nonatomic, strong) UIImageView *dayFilledImageView;
@property(nonatomic, strong) UIImageView *daySelectedImageView;

@end

@implementation TimesheetDayButton
@synthesize _dayOff;
@synthesize _dayName;
@synthesize _dayNameTxt;
@synthesize _btnTag;
@synthesize _entryDelegate;
@synthesize _dayFilled;

- (id)initWithDate:(NSInteger)date andDay:(NSString*)dayName dayOff:(BOOL)dayIsOff isTimesheetDayFilled:(BOOL)timesheetDayFilled frame:(CGRect )frame withTag:(int)tag withDelegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _date = date;
        _dayName = dayName;
        _dayOff=dayIsOff;
        _entryDelegate=delegate;
        _btnTag=tag;
        _dayFilled=timesheetDayFilled;
        [self setupButton];
        [self redraw];
    }
    return self;
}

-(void) setupButton
{
    [self setAdjustsImageWhenHighlighted:NO];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [[self titleLabel] setTextColor:[UIColor redColor]];
    [[self titleLabel] setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [[self titleLabel] setShadowOffset:CGSizeMake(0, 0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 0)];
    [self setTag:_btnTag];

    _dayNameTxt = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, CGRectGetWidth(self.bounds) - 2, 24)];
    _dayNameTxt.text = _dayName;
    [_dayNameTxt setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_14]];
    [_dayNameTxt setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_dayNameTxt];

    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds), 1.0f)];
    bottomBorder.backgroundColor = [Util colorWithHex:@"#CCCCCC" alpha:1.0f];
    [self addSubview:bottomBorder];

    UIView *leftBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1.0f, CGRectGetHeight(self.bounds))];
    leftBorder.backgroundColor = [Util colorWithHex:@"#CCCCCC" alpha:1.0f];
    [self addSubview:leftBorder];

    self.dayFilledImageView = [UIImageView imageViewWithImageNamed:@"icon_timesheet_day_filled"];
    [self addSubview:self.dayFilledImageView];

    self.daySelectedImageView = [UIImageView imageViewWithImageNamed:@"icon_timesheet_day_selected"];
    CGRect selectedImageViewFrame = self.daySelectedImageView.bounds;
    selectedImageViewFrame.origin.x = ((CGRectGetWidth(self.bounds) - CGRectGetWidth(selectedImageViewFrame))) / 2.0f;
    selectedImageViewFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(self.daySelectedImageView.bounds);
    self.daySelectedImageView.frame = selectedImageViewFrame;
    self.daySelectedImageView.hidden = YES;
    [self addSubview:self.daySelectedImageView];

    [self setBackgroundColor:[UIColor whiteColor]];

    [self addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) redraw
{
    self.dayFilledImageView.hidden = !_dayFilled;
    [self setTitle:[NSString stringWithFormat:@"%li", (long)_date] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}


-(void) setDayOff:(BOOL)dayOff
{
    _dayOff = dayOff;
    [self redraw];
}

-(void) handleTap:(id)sender
{
    
    if (_entryDelegate != nil && ![_entryDelegate isKindOfClass:[NSNull class]] &&
        [_entryDelegate conformsToProtocol:@protocol(TimesheetDayButtonClickProtocol)])
    {
        [_entryDelegate timesheetDayBtnClicked:sender isManualClick:YES];
        
    }
}

- (void)highlightButton:(BOOL)highlight forButton:(TimesheetDayButton *)btn
{
    self.daySelectedImageView.hidden = !highlight;

    if (highlight)
    {
        [_dayNameTxt setTextColor:[Util colorWithHex:@"#007AC9" alpha:1.0f]];
        [self setTitleColor:[Util colorWithHex:@"#007AC9" alpha:1.0f] forState:UIControlStateNormal];
    }
    else
    {
        [_dayNameTxt setTextColor:[UIColor blackColor]];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    [self redraw];
}


-(void)setDayName:(NSString *)dayName
{
    _dayName = dayName;
    _dayNameTxt.text = _dayName;
}


-(void)markAsDayOff:(BOOL)isDayOff{
    CGFloat alphaVal = 1;
    if(isDayOff){
        alphaVal = 0.3;
    }
    _dayNameTxt.alpha = alphaVal;
    self.titleLabel.alpha = alphaVal;
}


@end
