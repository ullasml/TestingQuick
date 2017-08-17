//
//  BookedTimeOffCalendarViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 6/28/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>

@class TKCalendarMonthView;
@protocol TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource;
@protocol BookedTimeOffCalendarViewDelegate;
@interface BookedTimeOffCalendarViewController : UIViewController<TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource> 
{
    NSDate *selectedStartDate;
    NSDate *selectedEndDate;
    NSDate *tempSelectedStartDate;
    NSDate *tempSelectedEndDate;
    UILabel *timeoffTypeLbl;
    UILabel *timeoffTypeValueLbl;
    UIScrollView *mainScrollView;
    UIButton   *collapseBtn;
    BOOL isCollapse;
    id <BookedTimeOffCalendarViewDelegate> __weak delegate;
    BOOL isFirstTime;
    UIView *progressView;
}

@property(nonatomic,strong)UIView *progressView;
@property(nonatomic,strong)NSDate *selectedStartDate;
@property(nonatomic,strong)NSDate *selectedEndDate;
@property(nonatomic,strong)NSDate *tempSelectedStartDate;
@property(nonatomic,strong)NSDate *tempSelectedEndDate;
@property(nonatomic,strong)UILabel *timeoffTypeLbl,*timeoffTypeValueLbl;
@property(nonatomic,strong)UIScrollView *mainScrollView;
@property(nonatomic,assign) BOOL isCollapse;
@property(nonatomic,strong) UIButton   *collapseBtn;
@property(nonatomic,weak) id <BookedTimeOffCalendarViewDelegate> delegate;
@property(nonatomic,assign) BOOL isFirstTime;

@property (nonatomic,strong) TKCalendarMonthView *calendarView;

- (void)viewDidAppear:(BOOL)animated;
-(void)paintCalendarFromAPICall;
-(void)showCollapseButton;

@end


@protocol BookedTimeOffCalendarViewDelegate <NSObject>

@optional
- (void)didSelectDateForCalendarViewStartDate:(NSDate *)_startDate forEndDate:(NSDate *)_endDate;
@end
