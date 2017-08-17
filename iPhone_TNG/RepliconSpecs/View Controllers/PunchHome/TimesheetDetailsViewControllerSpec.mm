#import "Cedar.h"
#import "TimesheetDetailsViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetDetailsViewControllerSpec)

describe(@"TimesheetDetailsViewController", ^{
    __block TimesheetDetailsViewController *subject;
    __block UINavigationController *navigationController;

    beforeEach(^{
        subject = [[TimesheetDetailsViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        navigationController.navigationBarHidden = YES;
    });

    describe(@"when the view appears", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
        });

        it(@"should show the navigation bar", ^{
            navigationController.navigationBarHidden should be_falsy;
        });

        it(@"should display navigation bar title", ^{
            navigationController.title should equal(NSLocalizedString(@"Timesheet Periods", @"Timesheet Periods"));
        });

        describe(@"when the view disappears", ^{
            beforeEach(^{
                [subject viewWillDisappear:NO];
            });

            it(@"should hide the navigation bar", ^{
                navigationController.navigationBarHidden should be_truthy;
            });
        });
    });
});

SPEC_END
