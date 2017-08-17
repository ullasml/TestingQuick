//
//  TimeOffView.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/27/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimeOffView;
@class TimeOffObject;
@class ErrorBannerViewParentPresenterHelper;

@protocol TimeOffBookingsViewDelegate <NSObject>
@optional
- (void)listOfTimeOffBookView:(TimeOffView *)listOfTimeOffBookingsView refreshAction:(id)sender;
- (void)listOfTimeOffBookView:(TimeOffView *)listOfTimeOffBookingsView moreAction:(id)sender;
- (void)listofTimeOFfBookView:(TimeOffView *)listOfTimeOffBookingsView selectedIndexPath:(NSIndexPath *)indexPath withTimeOffObject:(TimeOffObject *)timeOffObj withContentOffset:(CGPoint)tableOffset;

@end

@interface TimeOffView : UIView

@property (nonatomic,assign) BOOL isDataUpdate;
@property (nonatomic,assign) CGPoint currentContentOffset;
@property (nonatomic,assign) id<TimeOffBookingsViewDelegate> timeOffBookingViewDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper NS_DESIGNATED_INITIALIZER;

- (void)refreshTableViewWithContentOffsetReset:(BOOL)isContentOffsetReset;
- (void)setUpTimeOffObjectsArray:(NSMutableArray *)timeOffArray;
- (void)refreshTableViewAfterPulltoRefresh;
- (void)refreshTableViewAfterMoreAction:(BOOL)isErrorOccured;
- (void)stopAnimatingIndicator;
@end
