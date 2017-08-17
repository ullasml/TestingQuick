#import "ApprovalStatusPresenter.h"
#import "Constants.h"
#import "Theme.h"

@interface ApprovalStatusPresenter()

@property(nonatomic) id<Theme> theme;

@end

@implementation ApprovalStatusPresenter

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithTheme:(id<Theme>) theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (UIColor *)colorForStatus:(NSString *)approvalStatus
{

    if ([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS])
    {
        return [self.theme approvalStatusNotSubmittedColor];
    }
    else if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
    {
        return [self.theme approvalStatusWaitingForApprovalColor];
    }
    else if ([approvalStatus isEqualToString:REJECTED_STATUS])
    {
        return [self.theme approvalStatusRejectedColor];
    }
    else if ([approvalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
             [approvalStatus isEqualToString: TIMESHEET_SUBMITTED] ||
             [approvalStatus isEqualToString:TIMESHEET_CONFLICTED])
    {
        return [self.theme approvalStatusTimesheetNotApprovedColor];
    }
    else {
        return [self.theme approvalStatusDefaultColor];
    }
}




@end
