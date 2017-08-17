//
//  TimesheetContainerController+RightBarButtonAction.h
//  NextGenRepliconTimeSheet
//

#import "TimesheetContainerController.h"
@class TimePeriodSummary;

@interface TimesheetContainerController (RightBarButtonAction)

- (void)displayUserActionsButtons:(TimePeriodSummary *)timesheetPeriod;
- (void)showSpinnerView:(UIView *)spinnerView;
- (void)approvalsTimesheetReopenAction;
- (void)approvalsTimesheetSubmitAction:(id)sender;
@end
