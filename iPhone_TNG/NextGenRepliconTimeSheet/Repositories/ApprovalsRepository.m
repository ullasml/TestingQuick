#import "ApprovalsRepository.h"
#import "RepliconServiceProvider.h"
#import "ApprovalsModelProvider.h"
#import "Constants.h"
#import "ApprovalsModel.h"
#import "ApprovalsService.h"
#import <KSDeferred/KSPromise.h>

@interface ApprovalsRepository ()
@property(nonatomic) RepliconServiceProvider *repliconServiceProvider;
@property(nonatomic) ApprovalsModelProvider *approvalsModelProvider;
@property(nonatomic) NSNotificationCenter *notificationCenter;
@end

@implementation ApprovalsRepository

- (instancetype)initWithRepliconServiceProvider:(RepliconServiceProvider *)repliconServiceProvider
               approvalsModelProvider:(ApprovalsModelProvider *)approvalsModelProvider
                   notificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = [super init];

    if(self) {
        self.repliconServiceProvider = repliconServiceProvider;
        self.approvalsModelProvider = approvalsModelProvider;
        self.notificationCenter     = notificationCenter;
    }

    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)fetchTimeOffApprovalsAndPostNotification
{
    ApprovalsModel *approvalsModel = [self.approvalsModelProvider provideInstance];
    NSArray *pendingTimeOffApprovals = [approvalsModel getAllPendingTimeOffsOfApprovalFromDB];
    if (pendingTimeOffApprovals.count) {
        [self.notificationCenter postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
    }
    else {
        ApprovalsService *approvalsService = [self.repliconServiceProvider provideApprovalsService];
        [approvalsService fetchSummaryOfTimeOffPendingApprovalsForUser:nil];
    }
}

- (void)fetchTimesheetApprovalsAndPostNotification
{
    ApprovalsModel *approvalsModel = [self.approvalsModelProvider provideInstance];
    NSArray *pendingTimesheetApprovals = [approvalsModel getAllPendingTimesheetsOfApprovalFromDB];

    if(pendingTimesheetApprovals.count) {
        [self.notificationCenter postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    } else {
        ApprovalsService *approvalsService = [self.repliconServiceProvider provideApprovalsService];
        [approvalsService fetchSummaryOfTimeSheetPendingApprovalsForUser:nil];
    }
}

- (void)fetchExpenseApprovalsAndPostNotification
{

    ApprovalsModel *approvalsModel = [self.approvalsModelProvider provideInstance];
    NSArray *pendingExpenseApprovals = [approvalsModel getAllPendingExpenseSheetOfApprovalFromDB];
    if (pendingExpenseApprovals.count) {
        [self.notificationCenter postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    }
    else {
        ApprovalsService *approvalsService = [self.repliconServiceProvider provideApprovalsService];
        [approvalsService fetchSummaryOfExpenseSheetPendingApprovalsForUser:nil];
    }
}

- (KSPromise *)approveAllExpenseSheetWithUriFromCollection:(NSArray *)allExpenseSheetUri
{
    return [[KSPromise alloc]init];
}

- (KSPromise *)rejectAllExpenseSheetWithUriFromCollection:(NSArray *)allExpenseSheetUri
{
    return [[KSPromise alloc]init];
}


@end
