#import <UIKit/UIKit.h>


@protocol Theme;
@protocol Cursor;
@protocol Timesheet;
@protocol SupervisorTimesheetSummaryControllerDelegate;
@class TimesheetDetailsPresenter;
@class TimesheetPeriod;
@class TimeSheetApprovalStatus;
@class KSPromise;

@interface SupervisorTimesheetSummaryController : UIViewController

@property (weak, nonatomic, readonly) UILabel *dateRangeLabel;
@property (weak, nonatomic, readonly) UIButton *previousTimesheetButton;
@property (weak, nonatomic, readonly) UIButton *nextTimesheetButton;

@property (nonatomic, readonly) TimesheetDetailsPresenter *timesheetDetailsPresenter;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithTimesheetDetailsPresenter:(TimesheetDetailsPresenter *)timesheetDetailsPresenter
                                            theme:(id<Theme>)theme;

- (void)setupWithDelegate:(id<SupervisorTimesheetSummaryControllerDelegate>)delegate timeSummaryPromise:(KSPromise *)timeSummaryPromise;

@end


@protocol SupervisorTimesheetSummaryControllerDelegate <NSObject>

- (void)timesheetSummaryControllerDidTapPreviousButton:(SupervisorTimesheetSummaryController *)supervisorTimesheetSummaryController;
- (void)timesheetSummaryControllerDidTapNextButton:(SupervisorTimesheetSummaryController *)simesheetSummaryController;
@end
