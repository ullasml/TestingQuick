#import <Cedar/Cedar.h>
#import "TeamStatusSummaryController.h"
#import <KSDeferred/KSDeferred.h>
#import "UserSummaryPlaceholderCell.h"
#import "TeamStatusSummaryNoUsersCell.h"
#import "TeamStatusSummary.h"
#import "PunchUser.h"
#import "UserSummaryCell.h"
#import "TeamStatusTablePresenter.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"
#import "ErrorBannerViewParentPresenterHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamStatusSummaryControllerSpec)

describe(@"TeamStatusSummaryController", ^{
    __block TeamStatusSummaryController *subject;
    __block KSDeferred *teamStatusSummaryDeferred;
    __block TeamStatusTablePresenter *teamStatusSummaryTablePresenter;
    __block TeamTableStylist *teamTableStylist;
    __block UINavigationController *navigationController;
    __block ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
    beforeEach(^{
        teamStatusSummaryDeferred = [[KSDeferred alloc] init];
        teamStatusSummaryTablePresenter = nice_fake_for([TeamStatusTablePresenter class]);
        teamTableStylist = nice_fake_for([TeamTableStylist class]);
        errorBannerViewParentPresenterHelper = nice_fake_for([ErrorBannerViewParentPresenterHelper class]);

        subject = [[TeamStatusSummaryController alloc] initWithErrorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper
                                                                     teamStatusSummaryCellPresenter:teamStatusSummaryTablePresenter initiallyDisplayedSection:TeamStatusTableSectionClockedIn teamStatusSummaryPromise:teamStatusSummaryDeferred.promise teamTableStylist:teamTableStylist];
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
    });

    describe(@"when the view appears", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
        });


        it(@"should set the navigation controller's title to the correct string", ^{
            subject.navigationItem.title should equal([NSString stringWithFormat:@"%@", RPLocalizedString(@"Punch Team Status", @"Punch Team Status")]);
        });
    });

    describe(@"The team table", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should ask the stylist to style the table", ^{
            teamTableStylist should have_received(@selector(applyThemeToTeamTableView:)).with(subject.teamTableView);
        });

        it(@"should set up the section headers with the values from the presenter", ^{
            subject.teamTableView.numberOfSections should equal(3);

            TeamSectionHeaderView *header = nice_fake_for([TeamSectionHeaderView class]);
            teamStatusSummaryTablePresenter stub_method(@selector(sectionHeaderForSection:)).with(1).and_return(header);

            [subject tableView:subject.teamTableView viewForHeaderInSection:1] should equal(header);
        });

        describe(@"BEFORE the promise has been resolved", ^{
            __block UserSummaryPlaceholderCell *placeholderCell;
            beforeEach(^{
                placeholderCell = nice_fake_for([UserSummaryPlaceholderCell class]);
                teamStatusSummaryTablePresenter stub_method(@selector(placeholderTableViewCellForTableView:)).with(subject.teamTableView).and_return(placeholderCell);
            });

            it(@"should display a placeholder cell from the presenter in each section", ^{
                id<UITableViewDataSource> dataSource = [subject.teamTableView dataSource];

                [dataSource tableView:subject.teamTableView numberOfRowsInSection:0] should equal(1);

                UITableViewCell *cell;
                NSIndexPath *indexPathOfCell;

                indexPathOfCell = [NSIndexPath indexPathForRow:0 inSection:0];
                cell = [dataSource tableView:subject.teamTableView cellForRowAtIndexPath:indexPathOfCell];
                cell should be_same_instance_as(placeholderCell);

                [dataSource tableView:subject.teamTableView numberOfRowsInSection:1] should equal(1);

                indexPathOfCell = [NSIndexPath indexPathForRow:0 inSection:1];
                cell = [dataSource tableView:subject.teamTableView cellForRowAtIndexPath:indexPathOfCell];
                cell should be_same_instance_as(placeholderCell);

                [dataSource tableView:subject.teamTableView numberOfRowsInSection:2] should equal(1);

                indexPathOfCell = [NSIndexPath indexPathForRow:0 inSection:2];
                cell = [dataSource tableView:subject.teamTableView cellForRowAtIndexPath:indexPathOfCell];
                cell should be_same_instance_as(placeholderCell);
            });
        });

        describe(@"when the promise has been resolved", ^{
            __block TeamStatusSummary *teamStatusSummary;
            __block NSArray *usersInArray;
            __block NSArray *usersOnBreakArray;
            __block NSArray *usersNotInArray;

            describe(@"rendering the table", ^{
                beforeEach(^{
                    usersInArray = @[];
                    usersOnBreakArray = @[];
                    usersNotInArray = @[];
                    teamStatusSummary = nice_fake_for([TeamStatusSummary class]);
                    teamStatusSummary stub_method(@selector(usersInArray)).and_return(usersInArray);
                    teamStatusSummary stub_method(@selector(usersOnBreakArray)).and_return(usersOnBreakArray);
                    teamStatusSummary stub_method(@selector(usersNotInArray)).and_return(usersNotInArray);
                });

                __block NSIndexPath *firstSectionIndexPath;
                __block UITableViewCell *firstPlaceholderCell;
                __block NSIndexPath *secondSectionIndexPath;
                __block UITableViewCell *secondPlaceholderCell;
                __block NSIndexPath *thirdSectionIndexPath;
                __block UITableViewCell *thirdPlaceholderCell;

                beforeEach(^{
                    firstSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    firstPlaceholderCell = nice_fake_for([UITableViewCell class]);
                    secondSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    secondPlaceholderCell = nice_fake_for([UITableViewCell class]);
                    thirdSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                    thirdPlaceholderCell = nice_fake_for([UITableViewCell class]);

                    teamStatusSummaryTablePresenter stub_method(@selector(tableViewCellForUsersArray:noUsersString:tableView:indexPath:isShowHoursField:)).with(usersInArray, RPLocalizedString(@"No one is clocked in", @"No one is clocked in"), subject.teamTableView, firstSectionIndexPath,YES).and_return(firstPlaceholderCell);

                    teamStatusSummaryTablePresenter stub_method(@selector(tableViewCellForUsersArray:noUsersString:tableView:indexPath:isShowHoursField:)).with(usersOnBreakArray, RPLocalizedString(@"No one is on break", @"No one is on break"), subject.teamTableView, secondSectionIndexPath,NO).and_return(secondPlaceholderCell);

                    teamStatusSummaryTablePresenter stub_method(@selector(tableViewCellForUsersArray:noUsersString:tableView:indexPath:isShowHoursField:)).with(usersNotInArray, RPLocalizedString(@"Everyone is occupied", @"Everyone is occupied"), subject.teamTableView, thirdSectionIndexPath,NO).and_return(thirdPlaceholderCell);
                });

                beforeEach(^{
                    spy_on(subject.teamTableView);
                    [teamStatusSummaryDeferred resolveWithValue:teamStatusSummary];
                });

                afterEach(^{
                    stop_spying_on(subject.teamTableView);
                });

                it(@"should reload the table", ^{
                    subject.teamTableView should have_received(@selector(reloadData));
                });


                it(@"should display the cells from the presenter for each section", ^{
                    id<UITableViewDataSource> dataSource = [subject.teamTableView dataSource];

                    TeamStatusSummaryNoUsersCell *cell;

                    cell = (id)[dataSource tableView:subject.teamTableView cellForRowAtIndexPath:firstSectionIndexPath];
                    cell should be_same_instance_as(firstPlaceholderCell);

                    cell = (id)[dataSource tableView:subject.teamTableView cellForRowAtIndexPath:secondSectionIndexPath];
                    cell should be_same_instance_as(secondPlaceholderCell);

                    cell = (id)[dataSource tableView:subject.teamTableView cellForRowAtIndexPath:thirdSectionIndexPath];
                    cell should be_same_instance_as(thirdPlaceholderCell);
                });

                it(@"should not be selectable", ^{
                    id<UITableViewDataSource> dataSource = [subject.teamTableView dataSource];

                    TeamStatusSummaryNoUsersCell *cell;

                    cell = (id)[dataSource tableView:subject.teamTableView cellForRowAtIndexPath:firstSectionIndexPath];
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);

                });



            });

            context(@"when there are no users in any of the sections ", ^{
                beforeEach(^{
                    usersInArray = @[];
                    usersOnBreakArray = @[];
                    usersNotInArray = @[];
                    teamStatusSummary = nice_fake_for([TeamStatusSummary class]);
                    teamStatusSummary stub_method(@selector(usersInArray)).and_return(usersInArray);
                    teamStatusSummary stub_method(@selector(usersOnBreakArray)).and_return(usersOnBreakArray);
                    teamStatusSummary stub_method(@selector(usersNotInArray)).and_return(usersNotInArray);
                });

                beforeEach(^{
                    [teamStatusSummaryDeferred resolveWithValue:teamStatusSummary];
                });

                it(@"should have the correct number of users in each section", ^{
                    [subject.teamTableView numberOfRowsInSection:0] should equal(1);
                    [subject.teamTableView numberOfRowsInSection:1] should equal(1);
                    [subject.teamTableView numberOfRowsInSection:2] should equal(1);
                });
            });

            context(@"when there are users in the sections", ^{
                __block TeamStatusSummary *teamStatusSummary;
                __block PunchUser *inUserA;
                __block PunchUser *inUserB;
                __block PunchUser *notInUserA;
                __block PunchUser *notInUserB;
                __block PunchUser *onBreakUserA;
                __block PunchUser *onBreakUserB;

                beforeEach(^{
                    teamStatusSummary = nice_fake_for([TeamStatusSummary class]);

                    inUserA = nice_fake_for([PunchUser class]);
                    inUserA stub_method(@selector(nameString)).and_return(@"Botham, Ian");
                    inUserB = nice_fake_for([PunchUser class]);
                    inUserB stub_method(@selector(nameString)).and_return(@"Gooch, Graham");

                    onBreakUserA = nice_fake_for([PunchUser class]);
                    onBreakUserA stub_method(@selector(nameString)).and_return(@"Tendulkar, Sachin");
                    onBreakUserB = nice_fake_for([PunchUser class]);
                    onBreakUserB stub_method(@selector(nameString)).and_return(@"Kumble, Anil");

                    notInUserA = nice_fake_for([PunchUser class]);
                    notInUserA stub_method(@selector(nameString)).and_return(@"Stewart, Alec");
                    notInUserB = nice_fake_for([PunchUser class]);
                    notInUserB stub_method(@selector(nameString)).and_return(@"Sehwag, Virender");

                    usersInArray = @[inUserA, inUserB];
                    teamStatusSummary stub_method(@selector(usersInArray)).and_return(usersInArray);
                    usersOnBreakArray = @[onBreakUserA, onBreakUserB];
                    teamStatusSummary stub_method(@selector(usersOnBreakArray)).and_return(usersOnBreakArray);
                    usersNotInArray = @[notInUserA, notInUserB];
                    teamStatusSummary stub_method(@selector(usersNotInArray)).and_return(usersNotInArray);
                });

                beforeEach(^{
                    [teamStatusSummaryDeferred resolveWithValue:teamStatusSummary];
                });

                it(@"should have the correct number of users in each section", ^{
                    [subject.teamTableView numberOfRowsInSection:0] should equal(2);
                    [subject.teamTableView numberOfRowsInSection:1] should equal(2);
                    [subject.teamTableView numberOfRowsInSection:2] should equal(2);
                });
            });
        });
    });

    describe(@"The initial scroll position", ^{
        __block TeamStatusSummary *teamStatusSummary;

        beforeEach(^{
            NSArray *usersInArray = @[];
            NSArray *usersOnBreakArray = @[];
            NSArray *usersNotInArray = @[];
            teamStatusSummary = nice_fake_for([TeamStatusSummary class]);
            teamStatusSummary stub_method(@selector(usersInArray)).and_return(usersInArray);
            teamStatusSummary stub_method(@selector(usersOnBreakArray)).and_return(usersOnBreakArray);
            teamStatusSummary stub_method(@selector(usersNotInArray)).and_return(usersNotInArray);
        });

        context(@"when the controller is initially configured to scroll to the clocked in section", ^{
            describe(@"when the team status summary promise is resolved", ^{
                beforeEach(^{
                    [subject view];
                    spy_on(subject.teamTableView);
                    [teamStatusSummaryDeferred resolveWithValue:teamStatusSummary];
                });

                afterEach(^{
                    stop_spying_on(subject.teamTableView);
                });

                it(@"should scroll to the clocked in section", ^{
                    NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionClockedIn];
                    subject.teamTableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with(expectedIndexPath,UITableViewScrollPositionTop,YES);
                });
            });
        });

        context(@"when the controller is initially configured to scroll to the not in section", ^{
            describe(@"when the team status summary promise is resolved", ^{
                beforeEach(^{
                    subject = [[TeamStatusSummaryController alloc] initWithErrorBannerViewParentPresenterHelper:NULL teamStatusSummaryCellPresenter:teamStatusSummaryTablePresenter initiallyDisplayedSection:TeamStatusTableSectionNotIn teamStatusSummaryPromise:teamStatusSummaryDeferred.promise teamTableStylist:NULL];

                    [subject view];
                    spy_on(subject.teamTableView);
                    [teamStatusSummaryDeferred resolveWithValue:teamStatusSummary];
                });

                afterEach(^{
                    stop_spying_on(subject.teamTableView);
                });

                it(@"should scroll to the clocked in section", ^{
                    NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionNotIn];
                    subject.teamTableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with(expectedIndexPath,UITableViewScrollPositionTop,YES);
                });
            });
        });


        context(@"when the controller is initially configured to scroll to the clocked in section", ^{
            describe(@"when the team status summary promise is resolved", ^{
                beforeEach(^{
                    subject = [[TeamStatusSummaryController alloc] initWithErrorBannerViewParentPresenterHelper:NULL teamStatusSummaryCellPresenter:teamStatusSummaryTablePresenter initiallyDisplayedSection:TeamStatusTableSectionOnBreak teamStatusSummaryPromise:teamStatusSummaryDeferred.promise teamTableStylist:NULL];

                    [subject view];
                    spy_on(subject.teamTableView);
                    [teamStatusSummaryDeferred resolveWithValue:teamStatusSummary];
                });

                afterEach(^{
                    stop_spying_on(subject.teamTableView);
                });

                it(@"should scroll to the clocked in section", ^{
                    NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionOnBreak];
                    subject.teamTableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with(expectedIndexPath,UITableViewScrollPositionTop,YES);
                });
            });
        });
    });
    describe(@"the error banner view", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should check for error banner view", ^{
            [subject viewWillAppear:NO];
            
            errorBannerViewParentPresenterHelper should have_received(@selector(setTableViewInsetWithErrorBannerPresentation:))
            .with(subject.teamTableView);
        });
    });

});

SPEC_END
