
#import "TimesheetDetailsSeriesController.h"
@class TimePeriodSummary;



@interface TimesheetDetailsSeriesController (RightBarButtonAction)

- (void)displayUserActionsButtons:(TimePeriodSummary *)timesheetPeriod;

- (void)showSpinnerView:(UIView *)spinnerView;

@end
