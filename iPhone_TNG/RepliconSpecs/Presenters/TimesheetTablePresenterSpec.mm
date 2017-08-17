#import <Cedar/Cedar.h>
#import "TimesheetTablePresenter.h"
#import "TeamTimesheetsForTimePeriod.h"
#import "TimesheetForUserWithWorkHours.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


@interface FakeDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>
@end


SPEC_BEGIN(TimesheetTablePresenterSpec)

describe(@"TimesheetTablePresenter", ^{
    __block TimesheetTablePresenter *subject;

    beforeEach(^{
        subject = [[TimesheetTablePresenter alloc] init];
    });

    describe(@"-heightForTableView:timesheetPeriods:", ^{
        __block UITableView *tableView;
        __block CGFloat height;
        __block FakeDataSource *dataSource;
        beforeEach(^{

            dataSource = [[FakeDataSource alloc] init];

            tableView = [[UITableView alloc] init];
            tableView.dataSource = dataSource;
            tableView.delegate = dataSource;
            tableView.tableHeaderView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 100.0f)];
        });

        context(@"when presenting height for empty timesheet periods", ^{
            beforeEach(^{
                height = [subject heightForTableView:tableView timesheetPeriods:@[]];
            });

            it(@"it should have a height of 0", ^{
                height should equal((CGFloat)0.0f);
            });
        });

        context(@"when presenting height for a timesheet period with no timesheets", ^{
            beforeEach(^{
                TeamTimesheetsForTimePeriod *periodWithNoTimesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:nil
                                                                                                                     endDate:nil
                                                                                                                  timesheets:@[]];
                height = [subject heightForTableView:tableView timesheetPeriods:@[periodWithNoTimesheets]];
            });

            it(@"it should have a height of 0", ^{
                height should equal((CGFloat)0.0f);
            });
        });

        context(@"when presenting height for many periods that have at least one timesheet", ^{
            beforeEach(^{
                TeamTimesheetsForTimePeriod *periodWithNoTimesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:nil
                                                                                                                     endDate:nil
                                                                                                                  timesheets:@[]];
                TimesheetForUserWithWorkHours *timesheet = nice_fake_for([TimesheetForUserWithWorkHours class]);
                TeamTimesheetsForTimePeriod *periodWithOneTimesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:nil
                                                                                                                      endDate:nil
                                                                                                                   timesheets:@[timesheet]];
                height = [subject heightForTableView:tableView timesheetPeriods:@[periodWithNoTimesheets, periodWithOneTimesheets]];
            });

            it(@"it return the calculated height of the tableview", ^{
                height should equal((CGFloat)300.0f);
            });
        });
    });
});

SPEC_END


@implementation FakeDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"!"];
}

@end
