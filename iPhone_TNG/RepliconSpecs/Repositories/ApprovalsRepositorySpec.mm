#import <Cedar/Cedar.h>
#import "ApprovalsRepository.h"
#import "ApprovalsService.h"
#import "ApprovalsModelProvider.h"
#import "RepliconServiceProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApprovalsRepositorySpec)

describe(@"ApprovalsRepository", ^{
    __block ApprovalsRepository *subject;
    __block RepliconServiceProvider *repliconServiceProvider;
    __block ApprovalsService *approvalsService;
    __block ApprovalsModelProvider *approvalsModelProvider;
    __block NSNotificationCenter *notificationCenter;
    __block ApprovalsModel *approvalsModel;

    beforeEach(^{
        approvalsModelProvider = nice_fake_for([ApprovalsModelProvider class]);
        approvalsModel = nice_fake_for([ApprovalsModel class]);
        approvalsModelProvider stub_method(@selector(provideInstance)).and_return(approvalsModel);

        repliconServiceProvider = nice_fake_for([RepliconServiceProvider class]);
        approvalsService = nice_fake_for([ApprovalsService class]);
        repliconServiceProvider stub_method(@selector(provideApprovalsService)).and_return(approvalsService);

        notificationCenter = [[NSNotificationCenter alloc] init];

        subject = [[ApprovalsRepository alloc] initWithRepliconServiceProvider:repliconServiceProvider approvalsModelProvider:approvalsModelProvider notificationCenter:notificationCenter];
    });

    describe(NSStringFromSelector(@selector(fetchTimeOffApprovalsAndPostNotification)), ^{
        context(@"when the approvals model has zero persisted time off approvals", ^{
            beforeEach(^{
                approvalsModel stub_method(@selector(getAllPendingTimeOffsOfApprovalFromDB)).and_return(@[]);
                [subject fetchTimeOffApprovalsAndPostNotification];
            });

            it(@"should fetch new approvals", ^{
                approvalsService should have_received(@selector(fetchSummaryOfTimeOffPendingApprovalsForUser:)).with(nil);
            });
        });

        context(@"when the approvals model has more than zero persisted time off approvals", ^{
            beforeEach(^{
                spy_on(notificationCenter);
                approvalsModel stub_method(@selector(getAllPendingTimeOffsOfApprovalFromDB)).and_return(@[@1]);
                [subject fetchTimeOffApprovalsAndPostNotification];
            });

            afterEach(^{
                stop_spying_on(notificationCenter);
            });

            it(@"should post a notification", ^{
                notificationCenter should have_received(@selector(postNotificationName:object:)).with(PENDING_APPROVALS_TIMEOFF_NOTIFICATION, nil);
            });
        });
    });

    describe(@"fetchTimesheetApprovalsAndPostNotification", ^{
        context(@"when the approvals model has zero persisted timesheet approvals", ^{
            beforeEach(^{
                approvalsModel stub_method(@selector(getAllPendingTimesheetsOfApprovalFromDB)).and_return(@[]);
                [subject fetchTimesheetApprovalsAndPostNotification];
            });

            it(@"should fetch new approvals", ^{
                approvalsService should have_received(@selector(fetchSummaryOfTimeSheetPendingApprovalsForUser:)).with(nil);
            });
        });

        context(@"when the approvals model has more than zero persisted timesheet approvals", ^{
            beforeEach(^{
                spy_on(notificationCenter);
                approvalsModel stub_method(@selector(getAllPendingTimesheetsOfApprovalFromDB)).and_return(@[@1]);
                [subject fetchTimesheetApprovalsAndPostNotification];
            });

            afterEach(^{
                stop_spying_on(notificationCenter);
            });

            it(@"should post a notification", ^{
                notificationCenter should have_received(@selector(postNotificationName:object:)).with(PENDING_APPROVALS_TIMESHEET_NOTIFICATION, nil);
            });
        });
    });

    describe(NSStringFromSelector(@selector(fetchExpenseApprovalsAndPostNotification)), ^{
        context(@"when the approvals model has zero persisted expense approvals", ^{
            beforeEach(^{
                approvalsModel stub_method(@selector(getAllPendingExpenseSheetOfApprovalFromDB)).and_return(@[]);
                [subject fetchExpenseApprovalsAndPostNotification];
            });

            it(@"should fetch new approvals", ^{
                approvalsService should have_received(@selector(fetchSummaryOfExpenseSheetPendingApprovalsForUser:)).with(nil);
            });
        });

        context(@"when the approvals model has more than zero persisted approvals", ^{
            beforeEach(^{
                spy_on(notificationCenter);
                approvalsModel stub_method(@selector(getAllPendingExpenseSheetOfApprovalFromDB)).and_return(@[@1]);
                [subject fetchExpenseApprovalsAndPostNotification];
            });

            afterEach(^{
                stop_spying_on(notificationCenter);
            });

            it(@"should post a notification", ^{
                notificationCenter should have_received(@selector(postNotificationName:object:)).with(PENDING_APPROVALS_EXPENSE_NOTIFICATION, nil);
            });
        });
    });
    
});

SPEC_END
