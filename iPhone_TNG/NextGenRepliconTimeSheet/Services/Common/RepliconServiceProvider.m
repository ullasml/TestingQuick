#import "RepliconServiceProvider.h"
#import "RepliconServiceManager.h"
#import "ExpenseService.h"

@implementation RepliconServiceProvider

- (ApprovalsService *)provideApprovalsService
{
    return [RepliconServiceManager approvalsService];
}

- (ExpenseService *)provideExpenseService
{
    return [RepliconServiceManager expenseService];
}

@end
