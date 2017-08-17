//
//  TimeOffHolidayView.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/29/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimeOffHolidayView;
@class ErrorBannerViewParentPresenterHelper;

@protocol TimeOffHolidayViewDelegate <NSObject>
@optional
- (void)listOfTimeOffHolidayView:(TimeOffHolidayView *)listOfTimeOffHolidayView refreshAction:(id)sender;

@end

@interface TimeOffHolidayView : UIView
@property(nonatomic,assign) id<TimeOffHolidayViewDelegate> timeOffHolidayDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper NS_DESIGNATED_INITIALIZER;

- (void)setUpCompanyHolidays:(NSMutableDictionary *)companyHolidaysDict;
- (void)refreshTableViewAfterPulltoRefresh;
- (void)refreshTableViewWithContentOffsetReset;
- (void)stopAnimatingIndicator;

@end
