//
//  TimesheetContainerController+RightBarButtonAction.m
//  NextGenRepliconTimeSheet
//

#import "TimesheetContainerController+RightBarButtonAction.h"
#import "TimePeriodSummary.h"
#import "Constants.h"
#import "Util.h"
#import "TimeSummaryRepository.h"
#import <KSDeferred/KSPromise.h>
#import "TimeSheetPermittedActions.h"
#import "CommentViewController.h"
#import "InjectorKeys.h"
#import "TimesheetPeriod.h"
#import "ApprovalActionsViewController.h"
#import "TimesheetForUserWithWorkHours.h"

#define RIGHT_BAR_BUTTON_TAG    5000

@implementation TimesheetContainerController (RightBarButtonAction)

- (void)displayUserActionsButtons:(TimePeriodSummary *)timesheetPeriod {
    
    BOOL shouldDisplayRightBarButton = [self shouldShowRightBarButtonItem:timesheetPeriod];
    if (shouldDisplayRightBarButton) {
        
        [self showActionButton:timesheetPeriod];
    }
    
    else{
        [self removePreviousBarButtonView];
    }
}

- (void)showActionButton:(TimePeriodSummary *)timesheetPeriod {
    [self removePreviousBarButtonView];
    NSString *buttonTitle = [self getButtonTitle:timesheetPeriod];
    
    UIBarButtonItem *submitApprovalAction = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                                             style: UIBarButtonItemStylePlain
                                                                            target: self
                                                                            action: @selector(timeSheetRightBarButtonButtonAction:)];
    
    submitApprovalAction.tag = [self actionType:timesheetPeriod];
    
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItem = submitApprovalAction;
}

- (void)removePreviousBarButtonView {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showSpinnerView:(UIView *)spinnerView {
    [self removePreviousBarButtonView];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinnerView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)showRightBarActionSpinnerView:(UIView *)spinnerView {
    [self removePreviousBarButtonView];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinnerView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    spinnerView.hidden = NO;
}

#pragma mark - ActionType

- (RightBarButtonActionType)actionType:(TimePeriodSummary *)timePeriodSummary {
    
    TimeSheetPermittedActions *permittedAction = timePeriodSummary.timesheetPermittedActions;
    
    RightBarButtonActionType actionType = RightBarButtonActionTypeNone;
    
    if(permittedAction.canAutoSubmitOnDueDate) {
        actionType = RightBarButtonActionTypeSubmit;
    } else if(permittedAction.canReSubmitTimeSheet) {
        actionType = RightBarButtonActionTypeReSubmit;
    } else if(permittedAction.canReOpenSubmittedTimeSheet) {
        actionType = RightBarButtonActionTypeReOpen;
    }
    return actionType;
}

#pragma mark - RightBarButton Action Methods

- (void)timeSheetRightBarButtonButtonAction:(id)sender {
    
    UIBarButtonItem *item = sender;
    NSInteger senderTag = item.tag;
    
    switch (senderTag) {
        case RightBarButtonActionTypeSubmit:
            [self approvalsTimesheetSubmitAction:sender];
            break;
            
        case RightBarButtonActionTypeReOpen:
            [self approvalsTimesheetReopenAction];
            break;
            
        case RightBarButtonActionTypeReSubmit:
            [self approvalsTimesheetSubmitAction:sender];
            break;
            
        default:
            break;
    }
}

#pragma mark - Button Helper Methods

- (NSString *)getButtonTitle:(TimePeriodSummary *)timePeriodSummary {
    
    NSString *title = @"";
    RightBarButtonActionType actionType = [self actionType:timePeriodSummary];
    switch(actionType) {
        case RightBarButtonActionTypeSubmit:
            title = RPLocalizedString(Submit_Button_title, @"");
            break;
        case RightBarButtonActionTypeReSubmit:
            title = RPLocalizedString(Resubmit_Button_title, @"");
            break;
        case RightBarButtonActionTypeReOpen:
            title = RPLocalizedString(Reopen_Button_title, @"");
            break;
        default:
            break;
    }
    return title;
}

- (BOOL)shouldShowRightBarButtonItem:(TimePeriodSummary *)timePeriodSummary {
    
    BOOL shouldDisplayRightBarButton = NO;
    RightBarButtonActionType actionType = [self actionType:timePeriodSummary];
    switch(actionType) {
        case RightBarButtonActionTypeSubmit:
        case RightBarButtonActionTypeReSubmit:
        case RightBarButtonActionTypeReOpen:
            shouldDisplayRightBarButton = YES;
            break;
        default:
            break;
    }
    return shouldDisplayRightBarButton;
}

#pragma mark - Approver action methods

-(void)approvalsTimesheetReopenAction
{
    ApprovalActionsViewController *approvalActionsViewController = (ApprovalActionsViewController *)[self setupLegacyApprovalActionsViewControllerWithAction:@"Reopen"];
    [self.navigationController pushViewController:approvalActionsViewController animated:YES];
}

-(void)approvalsTimesheetSubmitAction:(id)sender
{
    NSString *buttonAction = @"Submit";
    UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
    if ([barButton.title isEqualToString:RPLocalizedString(Resubmit_Button_title, @"")])
    {
        buttonAction = @"Re-Submit_Astro";
    }
    ApprovalActionsViewController *approvalActionsViewController = (ApprovalActionsViewController *)[self setupLegacyApprovalActionsViewControllerWithAction:buttonAction];
    
    [self.navigationController pushViewController:approvalActionsViewController animated:YES];
}

- (UIViewController *)setupLegacyApprovalActionsViewControllerWithAction:(NSString *)actionType
{
    ApprovalActionsViewController *approvalActionsViewController = [self.injector getInstance:[ApprovalActionsViewController class]];
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"MMM dd";
    NSString *sheet=[NSString stringWithFormat:@" %@ - %@",[myDateFormatter stringFromDate:self.timesheet.period.startDate],[myDateFormatter stringFromDate:self.timesheet.period.endDate]];
    [approvalActionsViewController setUpWithSheetUri:self.timesheet.uri selectedSheet:sheet allowBlankComments:YES actionType:actionType delegate:self];
    return approvalActionsViewController;
}


@end
