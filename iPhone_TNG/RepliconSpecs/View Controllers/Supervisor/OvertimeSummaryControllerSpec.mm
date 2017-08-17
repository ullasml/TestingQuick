#import <Cedar/Cedar.h>
#import "OvertimeSummaryController.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchUser.h"
#import "OvertimeSummaryTablePresenter.h"
#import "UserSummaryCell.h"
#import "SupervisorDashboardSummary.h"
#import "UserSummaryPlaceholderCell.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(OvertimeSummaryControllerSpec)

describe(@"OvertimeSummaryController", ^{
    __block OvertimeSummaryController *subject;
    __block KSDeferred *supervisorDashboardSummaryDeferred;
    __block UINavigationController *navigationController;
    __block OvertimeSummaryTablePresenter *overtimeSummaryTablePresenter;
    __block TeamTableStylist *teamTableStylist;

    beforeEach(^{
        supervisorDashboardSummaryDeferred = [[KSDeferred alloc]init];
        overtimeSummaryTablePresenter = nice_fake_for([OvertimeSummaryTablePresenter class]);
        teamTableStylist = nice_fake_for([TeamTableStylist class]);
        subject = [[OvertimeSummaryController alloc] initWithOvertimeSummaryPromise:supervisorDashboardSummaryDeferred.promise
                                                      overtimeSummaryTablePresenter:overtimeSummaryTablePresenter
                                                                   teamTableStylist:teamTableStylist];

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
    });

    it(@"should set the navigation controller's title correctly", ^{
        [subject view];
        [subject viewWillAppear:NO];
        subject.navigationItem.title should equal([NSString stringWithFormat:@"%@", RPLocalizedString(@"Overtime", @"Overtime")]);
    });

    describe(@"presenting the overtime table view", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should set up the overtime table view to support dequeuing of placeholder cells", ^{
            [subject.overtimeTableView dequeueReusableCellWithIdentifier:@"UserSummaryPlaceholderCell"] should be_instance_of([UserSummaryPlaceholderCell class]);
        });

        it(@"should ask the stylist to style the table", ^{
            teamTableStylist should have_received(@selector(applyThemeToTeamTableView:)).with(subject.overtimeTableView);
        });

        it(@"should set up the section headers with the values from the presenter", ^{
            subject.overtimeTableView.numberOfSections should equal(1);

            TeamSectionHeaderView *header = nice_fake_for([TeamSectionHeaderView class]);
            overtimeSummaryTablePresenter stub_method(@selector(sectionHeaderForSection:)).with(1).and_return(header);

            [subject tableView:subject.overtimeTableView viewForHeaderInSection:1] should equal(header);
        });

        context(@"BEFORE the supervisor dashboard summary promise has been resolved", ^{
            __block UserSummaryPlaceholderCell *placeholderCell;

            beforeEach(^{
                placeholderCell = [[UserSummaryPlaceholderCell alloc] init];
                overtimeSummaryTablePresenter stub_method(@selector(placeholderTableViewCellForTableView:)).with(subject.overtimeTableView).and_return(placeholderCell);
            });

            it(@"should initially show a placeholder cell", ^{
                [subject.overtimeTableView reloadData];
                subject.overtimeTableView.visibleCells.count should equal(1);
                subject.overtimeTableView.visibleCells.firstObject should be_same_instance_as(placeholderCell);
            });
        });

        context(@"when the supervisor dashboard summary promise has been resolved", ^{
            __block SupervisorDashboardSummary *supervisorDashboardSummary;
            __block NSArray *usersWithOvertimeArray;
            __block NSIndexPath *firstIndexPath;
            __block UITableViewCell *firstPlaceholderCell;
            __block NSIndexPath *secondIndexPath;
            __block UITableViewCell *secondPlaceholderCell;
            __block NSIndexPath *thirdIndexPath;
            __block UITableViewCell *thirdPlaceholderCell;


            beforeEach(^{
                firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                firstPlaceholderCell = [[UserSummaryCell alloc] init];
                secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                secondPlaceholderCell = [[UserSummaryCell alloc] init];
                thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                thirdPlaceholderCell = [[UserSummaryCell alloc] init];

                PunchUser *punchUserA = [[PunchUser alloc] initWithNameString:@"userA"
                                                                     imageURL:nil
                                                                addressString:nil
                                                        regularDateComponents:nil
                                                       overtimeDateComponents:nil
                                                                bookedTimeOff:nil];
                PunchUser *punchUserB = [[PunchUser alloc] initWithNameString:@"userA"
                                                                     imageURL:nil
                                                                addressString:nil
                                                        regularDateComponents:nil
                                                       overtimeDateComponents:nil
                                                                bookedTimeOff:nil];
                PunchUser *punchUserC = [[PunchUser alloc] initWithNameString:@"userA"
                                                                     imageURL:nil
                                                                addressString:nil
                                                        regularDateComponents:nil
                                                       overtimeDateComponents:nil
                                                                bookedTimeOff:nil];

                usersWithOvertimeArray = [NSArray arrayWithObjects:punchUserA, punchUserB, punchUserC, nil];

                supervisorDashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                supervisorDashboardSummary stub_method(@selector(overtimeUsersArray)).and_return(usersWithOvertimeArray);

                overtimeSummaryTablePresenter stub_method(@selector(tableViewCellForPunchUser:tableView:indexPath:)).with(punchUserA).with(subject.overtimeTableView).with(firstIndexPath).and_return(firstPlaceholderCell);

                overtimeSummaryTablePresenter stub_method(@selector(tableViewCellForPunchUser:tableView:indexPath:)).with(punchUserB).with(subject.overtimeTableView).and_with(secondIndexPath).and_return(secondPlaceholderCell);
                overtimeSummaryTablePresenter stub_method(@selector(tableViewCellForPunchUser:tableView:indexPath:)).with(punchUserC).with(subject.overtimeTableView).and_with(thirdIndexPath).and_return(thirdPlaceholderCell);

                [supervisorDashboardSummaryDeferred resolveWithValue:supervisorDashboardSummary];
            });

            it(@"should show those users in the table", ^{
                subject.overtimeTableView.visibleCells.count should equal(3);
            });

            it(@"should display the cells from the presenter for each section", ^{
                id<UITableViewDataSource> dataSource = [subject.overtimeTableView dataSource];

                UserSummaryCell *cell;
                cell = (id)[dataSource tableView:subject.overtimeTableView cellForRowAtIndexPath:firstIndexPath];
                cell should be_same_instance_as(firstPlaceholderCell);

                cell = (id)[dataSource tableView:subject.overtimeTableView cellForRowAtIndexPath:secondIndexPath];
                cell should be_same_instance_as(secondPlaceholderCell);

                cell = (id)[dataSource tableView:subject.overtimeTableView cellForRowAtIndexPath:thirdIndexPath];
                cell should be_same_instance_as(thirdPlaceholderCell);
            });
        });

        context(@"When the supervisor dashboard summary fetch fails", ^{
            __block NSError *error;
            beforeEach(^{
                spy_on(subject.overtimeTableView);
                error = nice_fake_for([NSError class]);
                [supervisorDashboardSummaryDeferred rejectWithError:error];
            });
            
            it(@"should not reload the table", ^{
                subject.overtimeTableView should_not have_received(@selector(reloadData));
            });
        });
    });
});

SPEC_END
