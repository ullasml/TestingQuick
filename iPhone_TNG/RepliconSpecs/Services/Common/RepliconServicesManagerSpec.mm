#import <Cedar/Cedar.h>
#import "RepliconServiceManager.h"
#import "TimesheetService.h"
#import "ExpenseService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RepliconServicesManagerSpec)

describe(@"RepliconServicesManager", ^{
    describe(@"the timesheet service", ^{
        it(@"should return the same timesheet service until the timesheet service is reset", ^{
            TimesheetService *timesheetServiceA = [RepliconServiceManager timesheetService];
            timesheetServiceA should be_instance_of([TimesheetService class]);
            TimesheetService *timesheetServiceB = [RepliconServiceManager timesheetService];

            timesheetServiceA should be_same_instance_as(timesheetServiceB);

            [RepliconServiceManager resetTimesheetService];

            timesheetServiceB = [RepliconServiceManager timesheetService];
            timesheetServiceA should be_instance_of([TimesheetService class]);

            timesheetServiceB should_not be_same_instance_as(timesheetServiceA);
        });
    });

    describe(@"the expenses service", ^{
        it(@"should return the same expenses service until the expenses service is reset", ^{
            ExpenseService *expenseServiceA = [RepliconServiceManager expenseService];
            expenseServiceA should be_instance_of([ExpenseService class]);
            ExpenseService *expenseServiceB = [RepliconServiceManager expenseService];

            expenseServiceA should be_same_instance_as(expenseServiceB);

            [RepliconServiceManager resetExpenseService];

            expenseServiceB = [RepliconServiceManager expenseService];
            expenseServiceA should be_instance_of([ExpenseService class]);

            expenseServiceB should_not be_same_instance_as(expenseServiceA);
        });
    });

    describe(@"the timeoff service", ^{
        it(@"should return the same timeoff service until the timeoff service is reset", ^{
            TimeoffService *timeoffServiceA = [RepliconServiceManager timeoffService];
            timeoffServiceA should be_instance_of([TimeoffService class]);
            TimeoffService *timeoffServiceB = [RepliconServiceManager timeoffService];

            timeoffServiceA should be_same_instance_as(timeoffServiceB);

            [RepliconServiceManager resetTimeoffService];

            timeoffServiceB = [RepliconServiceManager timeoffService];
            timeoffServiceA should be_instance_of([TimeoffService class]);

            timeoffServiceB should_not be_same_instance_as(timeoffServiceA);
        });
    });
});

SPEC_END
