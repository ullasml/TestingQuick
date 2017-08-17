#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "GoldenAndNonGoldenTimesheetsController.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetForUserWithWorkHours.h"
#import "GoldenTimesheetUsersCell.h"
#import "TeamTimesheetsForTimePeriod.h"
#import "Theme.h"
#import "TimesheetUserCellPresenter.h"
#import "UITableViewCell+Spec.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "TimesheetUsersSectionHeaderViewPresenter.h"
#import "TimesheetUsersSectionHeaderView.h"
#import "SpinnerOperationsCounter.h"
#import "TimesheetTablePresenter.h"
#import "TimesheetContainerController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(GoldenAndNonGoldenTimesheetsControllerSpec)

describe(@"GoldenAndNonGoldenTimesheetsController", ^{
    __block id<Theme> theme;
    __block GoldenAndNonGoldenTimesheetsController *subject;
    __block KSDeferred *timesheetUsersDeferred;
    __block TimesheetUserCellPresenter *cellPresenter;
    __block id<TimesheetUserControllerDelegate, CedarDouble> delegate;
    __block TimesheetContainerController *timesheetContainerController;
    __block TimesheetTablePresenter *timesheetTablePresenter;
    __block TimesheetUsersSectionHeaderViewPresenter *sectionHeaderViewPresenter;
    __block WidgetTimesheetSummaryRepository *widgetTimesheetSummaryRepository;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];
    });

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        widgetTimesheetSummaryRepository =  nice_fake_for([WidgetTimesheetSummaryRepository class]);
        [injector bind:[WidgetTimesheetSummaryRepository class] toInstance:widgetTimesheetSummaryRepository];

        sectionHeaderViewPresenter = nice_fake_for([TimesheetUsersSectionHeaderViewPresenter class]);
        [injector bind:[TimesheetUsersSectionHeaderViewPresenter class] toInstance:sectionHeaderViewPresenter];

        cellPresenter = nice_fake_for([TimesheetUserCellPresenter class]);
        [injector bind:[TimesheetUserCellPresenter class] toInstance:cellPresenter];

        timesheetTablePresenter = nice_fake_for([TimesheetTablePresenter class]);
        [injector bind:[TimesheetTablePresenter class] toInstance:timesheetTablePresenter];

        subject = [injector getInstance:InjectorKeyGoldenTimesheetUserController];

        timesheetContainerController = [[TimesheetContainerController alloc] initWithChildControllerHelper:nil
                                                                                 widgetTimesheetRepository:nil
                                                                                       timesheetRepository:nil
                                                                                        notificationCenter:nil
                                                                                        oefTypesRepository:nil
                                                                                          approvalsService:nil
                                                                                           spinnerDelegate:nil
                                                                                            approvalsModel:nil
                                                                                                 appConfig:nil];
        spy_on(timesheetContainerController);

        [injector bind:[TimesheetContainerController class] toInstance:timesheetContainerController];

        timesheetUsersDeferred = [[KSDeferred alloc] init];
        delegate = nice_fake_for(@protocol(TimesheetUserControllerDelegate));
        [subject setupWithTimesheetUsersPromise:timesheetUsersDeferred.promise delegate:delegate];
    });
    
    describe(@"-viewWillAppear", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });
        
        it(@"should remove all observers from WidgetTimesheetSummaryRepository", ^{
            widgetTimesheetSummaryRepository should have_received(@selector(removeAllListeners));
        });
    });

    describe(@"presenting the the timesheets for a period", ^{
        context(@"when fetching the team's timesheet succeeds and returns a single timesheet period", ^{
            __block TimesheetForUserWithWorkHours *timesheetUser1;
            __block TimesheetForUserWithWorkHours *timesheetUser2;
            __block NSArray *timesheetPeriods;

            beforeEach(^{
                theme stub_method(@selector(timesheetUsersTableViewHeaderColor))
                    .and_return([UIColor greenColor]);
                theme stub_method(@selector(timesheetUsersTableViewHeaderFont))
                    .and_return([UIFont systemFontOfSize:6]);

                NSDate *startDate = nice_fake_for([NSDate class]);
                NSDate *endDate = nice_fake_for([NSDate class]);
                timesheetUser1 = nice_fake_for([TimesheetForUserWithWorkHours class]);
                timesheetUser2 = nice_fake_for([TimesheetForUserWithWorkHours class]);
                TeamTimesheetsForTimePeriod *timesheetsForTimePeriod = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:startDate
                                                                                                                      endDate:endDate
                                                                                                                   timesheets:@[timesheetUser1, timesheetUser2]];

                subject.view should_not be_nil;

                timesheetPeriods = @[timesheetsForTimePeriod];

                timesheetTablePresenter stub_method(@selector(heightForTableView:timesheetPeriods:))
                    .with(subject.timesheetTableview, timesheetPeriods)
                    .and_return((CGFloat)13.0f);

                [timesheetUsersDeferred resolveWithValue:timesheetPeriods];
            });

            it(@"should display a section for each group of timesheets", ^{
                subject.timesheetTableview.numberOfSections should equal(1);
            });

            it(@"should display a cell for each user's timesheet", ^{
                [subject.timesheetTableview numberOfRowsInSection:0] should equal(2);
            });

            it(@"should use the timesheetTablePresenter to get the height of the table and send it to its delegate", ^{
                delegate should have_received(@selector(timesheetUserController:didUpdateHeight:)).with(subject, (CGFloat)13.0f);
            });

            describe(@"the tableview header", ^{
                __block UITableViewHeaderFooterView *headerView;

                beforeEach(^{
                    [subject.timesheetTableview layoutIfNeeded];
                    headerView = (id)subject.timesheetTableview.tableHeaderView;
                });

                it(@"should be the correct class", ^{
                    headerView should be_instance_of([UITableViewHeaderFooterView class]);
                });

                it(@"should have the correct label", ^{
                    headerView.textLabel.text should contain(RPLocalizedString(@"Without Violations or Overtime", nil));
                });

                it(@"should style it appropriately", ^{
                    headerView.contentView.backgroundColor should equal([UIColor greenColor]);
                    headerView.textLabel.font should equal([UIFont systemFontOfSize:6]);
                });
            });

            describe(@"the section headers", ^{
                beforeEach(^{
                    [subject.timesheetTableview layoutIfNeeded];
                });

                it(@"should not be visible", ^{
                    [subject.timesheetTableview.delegate tableView:subject.timesheetTableview heightForHeaderInSection:0] should equal(0);
                });
            });

            describe(@"the cells", ^{
                __block GoldenTimesheetUsersCell *cell;

                beforeEach(^{
                    theme stub_method(@selector(timesheetUserNameFont)).and_return([UIFont systemFontOfSize:10]);
                    theme stub_method(@selector(timesheetUserWorkHoursFont)).and_return([UIFont systemFontOfSize:11]);
                    theme stub_method(@selector(timesheetUserBreakHoursFont)).and_return([UIFont systemFontOfSize:12]);
                    theme stub_method(@selector(timesheetUserBreakHoursColor)).and_return([UIColor magentaColor]);

                    cellPresenter stub_method(@selector(userNameLabelTextWithTimesheetUser:))
                    .with(timesheetUser1)
                    .and_return(@"My special username");

                    cellPresenter stub_method(@selector(workHoursLabelTextWithTimesheetUser:))
                    .with(timesheetUser1)
                    .and_return(@"My Regular Hours");

                    cellPresenter stub_method(@selector(regularHoursLabelTextWithTimesheetUser:))
                    .with(timesheetUser1)
                    .and_return([[NSAttributedString alloc] initWithString:@"My Break Hours"]);


                    cell = (id)[subject.timesheetTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should be the correct instance", ^{
                    cell should be_instance_of([GoldenTimesheetUsersCell class]);
                });

                it(@"should collaborate with its cell presenter to present the cells", ^{
                    cell.userNameLabel.text should equal(@"My special username");
                    cell.workHoursLabel.text should equal(@"My Regular Hours");
                    [cell.breakHoursLabel.attributedText string] should equal(@"My Break Hours");
                });

                it(@"should style the cell correctly", ^{
                    cell.userNameLabel.font should equal([UIFont systemFontOfSize:10]);
                    cell.workHoursLabel.font should equal([UIFont systemFontOfSize:11]);
                    cell.breakHoursLabel.font should equal([UIFont systemFontOfSize:12]);
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                    cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                });
            });
        });

        context(@"when the request is successful and we get back several timesheet periods", ^{
            __block TeamTimesheetsForTimePeriod *firstPeriodTimesheets;

            beforeEach(^{
                theme stub_method(@selector(timesheetUsersTableViewHeaderColor))
                .and_return([UIColor greenColor]);
                theme stub_method(@selector(timesheetUsersTableViewHeaderFont))
                .and_return([UIFont systemFontOfSize:6]);

                NSDate *startDate = nice_fake_for([NSDate class]);
                NSDate *endDate = nice_fake_for([NSDate class]);
                TimesheetForUserWithWorkHours *firstTimesheet = nice_fake_for([TimesheetForUserWithWorkHours class]);
                TimesheetForUserWithWorkHours *secondTimesheet = nice_fake_for([TimesheetForUserWithWorkHours class]);

                firstPeriodTimesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:startDate
                                                                                       endDate:endDate
                                                                                    timesheets:@[firstTimesheet]];
                TeamTimesheetsForTimePeriod *secondPeriodTimesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:startDate
                                                                                                                     endDate:endDate
                                                                                                                  timesheets:@[secondTimesheet]];

                subject.view should_not be_nil;
                [timesheetUsersDeferred resolveWithValue:@[firstPeriodTimesheets, secondPeriodTimesheets]];
            });

            it(@"should have a section for each timesheet period", ^{
                subject.timesheetTableview.numberOfSections should equal(2);
            });

            describe(@"the header view for each section", ^{
                __block TimesheetUsersSectionHeaderView *sectionHeader;

                beforeEach(^{
                    theme stub_method(@selector(defaultTableViewSeparatorColor)).and_return([UIColor redColor]);

                    sectionHeaderViewPresenter stub_method(@selector(labelForSectionHeaderWithTimesheet:))
                    .with(firstPeriodTimesheets)
                    .and_return(@"Date range goes here");

                    sectionHeaderViewPresenter stub_method(@selector(fontForSectionHeader))
                    .and_return([UIFont systemFontOfSize:7]);
                    sectionHeaderViewPresenter stub_method(@selector(fontColorForSectionHeader))
                    .and_return([UIColor greenColor]);

                    [subject.timesheetTableview layoutIfNeeded];
                    sectionHeader = (id)[subject.timesheetTableview headerViewForSection:0];
                    [subject.timesheetTableview layoutIfNeeded];
                });

                it(@"should be the correct class", ^{
                    sectionHeader should be_instance_of([TimesheetUsersSectionHeaderView class]);
                });

                it(@"should collaborate with its section header view presenter", ^{
                    sectionHeader.sectionTitleLabel.text should equal(@"Date range goes here");
                    sectionHeader.sectionTitleLabel.font should equal([UIFont systemFontOfSize:7]);
                    sectionHeader.sectionTitleLabel.textColor should equal([UIColor greenColor]);
                });

                it(@"should be visible", ^{
                    [subject.timesheetTableview.delegate tableView:subject.timesheetTableview heightForHeaderInSection:0] should be_greater_than(0);
                });

                it(@"should have the correct separator color", ^{
                    sectionHeader.topSeparatorView.backgroundColor should equal([UIColor redColor]);
                    sectionHeader.bottomSeparatorView.backgroundColor should equal([UIColor redColor]);
                });
            });
        });
    });

    describe(@"presenting non-golden timesheets", ^{
        __block TimesheetForUserWithWorkHours *timesheetUser;

        beforeEach(^{
            subject = [injector getInstance:InjectorKeyNongoldenTimesheetUserController];
            [subject setupWithTimesheetUsersPromise:timesheetUsersDeferred.promise delegate:delegate];

            subject.view should_not be_nil;

            timesheetUser = nice_fake_for([TimesheetForUserWithWorkHours class]);
            TeamTimesheetsForTimePeriod *timesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:nil
                                                                                                     endDate:nil
                                                                                                  timesheets:@[timesheetUser]];

            [timesheetUsersDeferred resolveWithValue:@[timesheets]];
        });

        describe(@"the header", ^{
            __block UITableViewHeaderFooterView *headerView;

            beforeEach(^{
                [subject.timesheetTableview layoutIfNeeded];
                headerView = (id)subject.timesheetTableview.tableHeaderView;
            });

            it(@"should have the correct label", ^{
                headerView.textLabel.text should contain(RPLocalizedString(@"With Violations or Overtime", nil));
            });
        });

        describe(@"the cells", ^{
            __block GoldenTimesheetUsersCell *cell;

            beforeEach(^{
                theme stub_method(@selector(timesheetUserNameFont)).and_return([UIFont systemFontOfSize:10]);
                theme stub_method(@selector(timesheetUserWorkHoursFont)).and_return([UIFont systemFontOfSize:11]);
                theme stub_method(@selector(timesheetUserBreakHoursFont)).and_return([UIFont systemFontOfSize:12]);
                theme stub_method(@selector(timesheetUserBreakHoursColor)).and_return([UIColor magentaColor]);

                cellPresenter stub_method(@selector(userNameLabelTextWithTimesheetUser:))
                .with(timesheetUser)
                .and_return(@"My special username");

                cellPresenter stub_method(@selector(workHoursLabelTextWithTimesheetUser:))
                .with(timesheetUser)
                .and_return(@"My Work Hours");

                cellPresenter stub_method(@selector(regularHoursLabelTextWithTimesheetUser:))
                .with(timesheetUser)
                .and_return([[NSAttributedString alloc] initWithString:@"My Regular Hours"]);


                cell = (id)[subject.timesheetTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            });

            it(@"should be the correct instance", ^{
                cell should be_instance_of([GoldenTimesheetUsersCell class]);
            });

            it(@"should collaborate with its cell presenter to present the cells", ^{
                cell.userNameLabel.text should equal(@"My special username");
                cell.workHoursLabel.text should equal(@"My Work Hours");
                [cell.breakHoursLabel.attributedText string] should equal(@"My Regular Hours");
            });

            it(@"should display a warning icon", ^{
                cell.warningImageView.image should equal([UIImage imageNamed:@"icon_timesheet_has_violations"]);
                cell.warningImageContainerViewWidthConstraint.constant should be_greater_than(0);
            });

            it(@"should style the cell correctly", ^{
                cell.userNameLabel.font should equal([UIFont systemFontOfSize:10]);
                cell.workHoursLabel.font should equal([UIFont systemFontOfSize:11]);
                cell.breakHoursLabel.font should equal([UIFont systemFontOfSize:12]);
                cell.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
            });
        });
    });

    describe(@"tapping on an employee's timesheets", ^{
        __block UINavigationController *navigationController;
        __block TimesheetForUserWithWorkHours *timesheetForUser;

        beforeEach(^{
            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];

            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];

            NSDate *startDate = nice_fake_for([NSDate class]);
            NSDate *endDate = nice_fake_for([NSDate class]);
            timesheetForUser = nice_fake_for([TimesheetForUserWithWorkHours class]);
            timesheetForUser stub_method(@selector(userName)).and_return(@"Gomes, Harry");
            timesheetForUser stub_method(@selector(userURI)).and_return(@"user-uri");
            timesheetForUser stub_method(@selector(uri)).and_return(@"timesheet-uri");

            TeamTimesheetsForTimePeriod *timesheets = [[TeamTimesheetsForTimePeriod alloc] initWithStartDate:startDate
                                                                                                     endDate:endDate
                                                                                                  timesheets:@[timesheetForUser]];

            [timesheetUsersDeferred resolveWithValue:@[timesheets]];
            [subject.timesheetTableview layoutIfNeeded];

            UITableViewCell *cell = [subject.timesheetTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell tap];
        });

        it(@"should be unselected", ^{
            UITableViewCell *cell = [subject.timesheetTableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.selected should be_falsy;
        });

        it(@"should present a TimesheetContainerController for the user's timesheet", ^{
            navigationController.topViewController should be_same_instance_as(timesheetContainerController);
        });

        it(@"should configure the TimesheetContainerController appropriately", ^{
            timesheetContainerController should have_received(@selector(setupWithTimesheet:));
            timesheetContainerController.timesheet should be_same_instance_as(timesheetForUser);
        });

        it(@"should send the timesheetusertype and selected indexpath to its delegate", ^{
            delegate should have_received(@selector(timesheetUserController:timesheetUserType:selectedIndex:)).with(subject, TimesheetUserTypeGolden,[NSIndexPath indexPathForRow:0 inSection:0]);
        });
    });

    describe(@"its tableview", ^{
        __block UITableView *tableview;

        beforeEach(^{
            subject.view should_not be_nil;
            tableview = subject.timesheetTableview;
        });

        it(@"should be the datasource", ^{
            tableview.dataSource should be_same_instance_as(subject);
        });

        it(@"should be the delegate", ^{
            tableview.delegate should be_same_instance_as(subject);
        });

        it(@"should not be scrollable", ^{
            tableview.scrollEnabled should_not be_truthy;
        });
    });

    describe(@"-dealloc", ^{
        __block UITableView *tableview;

        beforeEach(^{
            @autoreleasepool {
                GoldenAndNonGoldenTimesheetsController *deallocedSubject = [[GoldenAndNonGoldenTimesheetsController alloc] initWithTimesheetUserTypeSectionHeaderPresenter:nil
                                                                                                                                                   timesheetTablePresenter:nil
                                                                                                                                                         typesheetUserType:TimesheetUserTypeGolden
                                                                                                                                                             cellPresenter:nil
                                                                                                                                                                     theme:theme];
                deallocedSubject.view should_not be_nil;
                tableview = deallocedSubject.timesheetTableview;
                
                deallocedSubject = nil;
            }
        });
        
        it(@"should no longer be the delegate or datasource of its tableview", ^{
            tableview.delegate should be_nil;
            tableview.dataSource should be_nil;
        });
    });
});

SPEC_END
