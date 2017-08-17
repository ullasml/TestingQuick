#import <UIKit/UIKit.h>
#import "HeaderButtonViewController.h"

@protocol Theme;
@protocol Cursor;
@protocol Timesheet;
@protocol TimesheetSummaryControllerDelegate;
@class TimesheetDetailsPresenter;
@class TimesheetPeriod;
@class TimeSheetApprovalStatus;
@class TimesheetInfo;
@class DateProvider;
@class IndexCursor;
@class ChildControllerHelper;

@interface TimesheetSummaryController : UIViewController <HeaderButtonControllerDelegate>

@property (weak, nonatomic, readonly) UILabel *dateRangeLabel;
@property (weak, nonatomic, readonly) UILabel *currentPeriodLabel;
@property (weak, nonatomic, readonly) UIButton *previousTimesheetButton;
@property (weak, nonatomic, readonly) UIButton *nextTimesheetButton;
@property (weak, nonatomic, readonly) id<Theme> theme;
@property (weak, nonatomic, readonly) UIView *violationsAndStatusButtonContainerView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *widthConstraint;


@property (nonatomic, readonly) TimesheetDetailsPresenter *timesheetDetailsPresenter;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithTimesheetDetailsPresenter:(TimesheetDetailsPresenter *)timesheetDetailsPresenter
                            childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                            theme:(id <Theme>)theme;

- (void)setupWithDelegate:(id <TimesheetSummaryControllerDelegate>)delegate
                   cursor:(IndexCursor *)cursor
                timesheet:(id <Timesheet>)timesheet;

@end


@protocol TimesheetSummaryControllerDelegate <NSObject>

- (void)timesheetSummaryControllerDidTapPreviousButton:(TimesheetSummaryController *)timesheetSummaryController;
- (void)timesheetSummaryControllerDidTapNextButton:(TimesheetSummaryController *)timesheetSummaryController;
- (void)timesheetSummaryControllerDidTapissuesButton:(TimesheetSummaryController *)timesheetSummaryController;
- (void)timesheetSummaryControllerUpdateViewHeight:(TimesheetSummaryController *)timesheetSummaryController height:(CGFloat)height;


@end
