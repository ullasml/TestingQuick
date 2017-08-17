

#import "TimesheetDetailsSeriesController+RightBarButtonAction.h"
#import "TimePeriodSummary.h"
#import "Constants.h"
#import "Util.h"
#import "TimeSummaryRepository.h"
#import <KSDeferred/KSPromise.h>
#import "TimeSheetPermittedActions.h"
#import "CommentViewController.h"
#import "InjectorKeys.h"
#import "TimesheetPeriod.h"
#import "TimesheetInfo.h"
#import "TimesheetActionRequestBodyProvider.h"

@implementation TimesheetDetailsSeriesController (RightBarButtonAction)

- (void)displayUserActionsButtons:(TimePeriodSummary *)timesheetPeriod
{
    BOOL shouldDisplayRightBarButton = [self shouldShowRightBarButtonItem:timesheetPeriod];
    if (shouldDisplayRightBarButton)
    {
        [self showActionButton:timesheetPeriod];
    }
    else
    {
        [self removePreviousBarButtonView];
    }
    [self.spinnerDelegate hideTransparentLoadingOverlay];
}

- (void)showActionButton:(TimePeriodSummary *)timesheetPeriod
{
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

- (void)removePreviousBarButtonView
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showSpinnerView:(UIView *)spinnerView
{
    [self removePreviousBarButtonView];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinnerView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - ActionType

- (RightBarButtonActionType)actionType:(TimePeriodSummary *)timePeriodSummary
{
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

- (void)timeSheetRightBarButtonButtonAction:(id)sender
{
    UIBarButtonItem *item = sender;
    NSInteger senderTag = item.tag;
    
    switch (senderTag) {
        case RightBarButtonActionTypeSubmit:
            [self timesheetActionWithType:RightBarButtonActionTypeSubmit comments:nil];
            break;

        case RightBarButtonActionTypeReOpen:
            [self pushCommentsViewWithAction:@"Reopen"];
            break;

        case RightBarButtonActionTypeReSubmit:
            [self pushCommentsViewWithAction:@"Resubmit"];
            break;

        default:
            break;
    }
}

#pragma mark - Post Request Methods

- (void)timesheetActionWithType:(RightBarButtonActionType)actionType comments:(NSString *)comments
{
    [self showSpinnerView:self.spinnerView];
    [self.spinnerDelegate showTransparentLoadingOverlay];
    NSDictionary *requestBody = [self.timesheetActionRequestBodyProvider requestBodyDictionaryWithComment:comments timesheet:self.timesheetInfo];
    KSPromise *timeSheetActionPromise = nil;
    if (actionType == RightBarButtonActionTypeSubmit||actionType == RightBarButtonActionTypeReSubmit) {
        timeSheetActionPromise = [self.timeSummaryRepository submitTimeSheetData:requestBody];
    }
    else if (actionType == RightBarButtonActionTypeReOpen) {
        timeSheetActionPromise = [self.timeSummaryRepository reopenTimeSheet:requestBody];
    }
    [timeSheetActionPromise then:^id(TimePeriodSummary *timePeriodSummary) {
        [self displayNewTimesheetDetailsController];
        return nil;
    } error:^id(NSError *error) {
        [self displayUserActionsButtons:self.timesheetInfo.timePeriodSummary];
        return error;
    }];
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

#pragma mark - NavigationController Helper Method

- (void)pushCommentsViewWithAction:(NSString *)action
{
    CommentViewController *commentVC = [self.injector getInstance:[CommentViewController class]];
    [commentVC setupAction:action delegate:self];
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark - <CommentViewControllerDelegate>

- (void)commentsViewController:(CommentViewController *)commentViewController
        didPressOnActionButton:(id)sender
        withCommentsText:(NSString *)commentsText {

    UIButton *button_ = (UIButton *)sender;
    switch(button_.tag) {
        case RightBarButtonActionTypeReOpen:
            [self timesheetActionWithType:RightBarButtonActionTypeReOpen comments:commentsText];
            break;
        case RightBarButtonActionTypeReSubmit:
            [self timesheetActionWithType:RightBarButtonActionTypeReSubmit comments:commentsText];
            break;
        default:
            break;
    }
}


@end
