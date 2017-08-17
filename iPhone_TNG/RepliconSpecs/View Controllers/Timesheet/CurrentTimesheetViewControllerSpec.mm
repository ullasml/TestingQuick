#import <Cedar/Cedar.h>
#import "CurrentTimesheetViewController.h"
#import "Theme.h"
#import "ButtonStylist.h"
#import "TimesheetModel.h"
#import "SupportDataModel.h"
#import "ApprovalStatusPresenter.h"
#import "TimesheetObject.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(CurrentTimesheetViewControllerSpec)

describe(@"CurrentTimesheetViewController", ^{
    __block CurrentTimesheetViewController *subject;
    __block id<Theme> theme;
    __block ButtonStylist *buttonStylist;
    __block AppDelegate *appDelegate;
    __block TimesheetModel *timesheetModel;
    __block SupportDataModel *supportDataModel;
    __block ApprovalStatusPresenter *approvalStatusPresenter;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        timesheetModel = nice_fake_for([TimesheetModel class]);
        supportDataModel = nice_fake_for([SupportDataModel class]);
        buttonStylist = nice_fake_for([ButtonStylist class]);
        appDelegate = nice_fake_for([AppDelegate class]);
        approvalStatusPresenter = fake_for([ApprovalStatusPresenter class]);

        subject = [[CurrentTimesheetViewController alloc] initWithApprovalStatusPresenter:approvalStatusPresenter
                                                                                    theme:theme
                                                                         supportDataModel:supportDataModel
                                                                           timesheetModel:timesheetModel
                                                                            buttonStylist:buttonStylist
                                                                              appDelegate:appDelegate];
        spy_on(subject);

    });

    describe(NSStringFromProtocol(@protocol(UITableViewDataSource)), ^{
        describe(NSStringFromSelector(@selector(tableView:cellForRowAtIndexPath:)), ^{
            __block UITableViewCell *returnedCell;

            beforeEach(^{
                subject.sheetApprovalStatus = WAITING_FOR_APRROVAL_STATUS;
                approvalStatusPresenter stub_method(@selector(colorForStatus:)).and_return([UIColor purpleColor]);
                UITableView *tableView = [[UITableView alloc] init];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

                returnedCell = [subject tableView:tableView cellForRowAtIndexPath:indexPath];
            });

            it(@"should use the approval status presenter to get the color of the approvals label", ^{
                UILabel *approvalLabel = returnedCell.contentView.subviews.lastObject;

                approvalStatusPresenter should have_received(@selector(colorForStatus:)).with(WAITING_FOR_APRROVAL_STATUS);
                approvalLabel.textColor should equal([UIColor purpleColor]);
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            [subject view];
        });

        context(@"when data has been received and have data", ^{
            beforeEach(^{
                TimesheetObject *timeobj=[[TimesheetObject alloc]init];
                subject stub_method(@selector(currentTimesheetArray)).and_return(@[timeobj]);
                
                supportDataModel stub_method(@selector(getTimesheetPermittedApprovalActionsDataToDBWithUri:)).and_return(@{@"canSubmit": @YES});
                [subject RecievedData];
            });

            it(@"should style the submit button", ^{
                buttonStylist should have_received(@selector(styleRegularButton:title:))
                    .with(subject.submitButton, @"Submit");
            });
        });
        context(@"when data has been received and have no data", ^{
            beforeEach(^{
                supportDataModel stub_method(@selector(getTimesheetPermittedApprovalActionsDataToDBWithUri:)).and_return(@{@"canSubmit": @YES});
                [subject RecievedData];
            });
            
            it(@"should show Timesheet Format Not Supported Message", ^{
                subject should have_received(@selector(showTimesheetFormatNotSupported));
            });
        });
    });
});

SPEC_END
