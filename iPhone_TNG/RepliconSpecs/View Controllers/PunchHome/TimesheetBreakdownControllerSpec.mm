#import <Cedar/Cedar.h>
#import "TimesheetBreakdownController.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "TimePeriodSummary.h"
#import "TimesheetDaySummary.h"
#import "DayTimeSummaryCell.h"
#import "DayTimeSummaryCellPresenter.h"
#import "UITableViewCell+Spec.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetBreakdownControllerSpec)

describe(@"TimesheetBreakdownController", ^{
    __block TimesheetBreakdownController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block DayTimeSummaryCellPresenter *dayTimeSummaryCellPresenter;
    __block id <TimesheetBreakdownControllerDelegate> delegate;
    __block TimesheetDaySummary *dayTimeSummaryA;
    __block TimesheetDaySummary *dayTimeSummaryB;
    __block NSArray *dayTimeSummaries;
    __block NSAttributedString *dateString1;
    __block NSAttributedString *dateString2;
    __block id <Theme> theme;


    beforeEach(^{
        injector = (id)[InjectorProvider injector];
        
        theme = nice_fake_for(@protocol(Theme));
        theme stub_method(@selector(timesheetBreakdownViolationCountColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(timesheetBreakdownViolationCountFont)).and_return([UIFont systemFontOfSize:10]);
        dayTimeSummaryCellPresenter = fake_for([DayTimeSummaryCellPresenter class]);
        [injector bind:[DayTimeSummaryCellPresenter class] toInstance:dayTimeSummaryCellPresenter];
        
        [injector bind:@protocol(Theme) toInstance:theme];

        subject = [injector getInstance:[TimesheetBreakdownController class]];

        delegate = nice_fake_for(@protocol(TimesheetBreakdownControllerDelegate));

        dayTimeSummaryA = nice_fake_for([TimesheetDaySummary class]);
        dayTimeSummaryB = nice_fake_for([TimesheetDaySummary class]);

        dateString1 = [[NSAttributedString alloc] initWithString:@"Date String 1"];
        dateString2 = [[NSAttributedString alloc] initWithString:@"Date String 2"];

        NSAttributedString *regularTimeString1 = [[NSAttributedString alloc] initWithString:@"Regular String 1"];
        NSAttributedString *regularTimeString2 = [[NSAttributedString alloc] initWithString:@"Regular String 2"];

        NSAttributedString *breakTimeString1 = [[NSAttributedString alloc] initWithString:@"Break String 1"];
        NSAttributedString *breakTimeString2 = [[NSAttributedString alloc] initWithString:@"Break String 2"];

        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(dateString1);
        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(dateString2);

        dayTimeSummaryCellPresenter stub_method(@selector(regularTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(regularTimeString1);
        dayTimeSummaryCellPresenter stub_method(@selector(regularTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(regularTimeString2);

        dayTimeSummaryCellPresenter stub_method(@selector(breakTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(breakTimeString1);
        dayTimeSummaryCellPresenter stub_method(@selector(breakTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(breakTimeString2);

        dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
    });

    describe(@"presenting a table of days with hours worked summary", ^{
        
        context(@"when there is a delegate", ^{
            beforeEach(^{
                [subject setupWithDayTimeSummaries:dayTimeSummaries
                                          delegate:delegate];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
            });

            it(@"should show the cell separators", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleSingleLine);
            });

            it(@"should have a row for every day time summary", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(2);

                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");


                DayTimeSummaryCell *cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
            });

            it(@"should allow the rows to be selected", ^{
                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell1.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                cell1.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
            });

            describe(@"presenting daily punches for each day in a timesheet", ^{

                context(@"when the user taps on a particular day's row", ^{
                    __block NSDate *expectedDate;
                    __block NSIndexPath *indexPath;

                    beforeEach(^{
                        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        expectedDate = [NSDate dateWithTimeIntervalSince1970:1427305050];

                        dayTimeSummaryCellPresenter stub_method(@selector(dateForDayTimeSummary:)).with(dayTimeSummaryA).and_return(expectedDate);

                        DayTimeSummaryCell *cell = (id)[subject.tableView cellForRowAtIndexPath:indexPath];
                        [cell tap];
                    });

                    it(@"tells its delegate the date that was tapped", ^{
                        delegate should have_received(@selector(timeSheetBreakdownController:didSelectDayWithDate:dayTimeSummaries:indexPath:)).with(subject, expectedDate, dayTimeSummaries, indexPath);
                    });

                    it(@"should deselect the tapped row immediately", ^{
                        subject.tableView.indexPathsForSelectedRows should be_nil;
                    });
                });
            });
        });

        context(@"when there is no delegate", ^{
            beforeEach(^{
                [subject setupWithDayTimeSummaries:dayTimeSummaries
                                          delegate:nil];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
            });

            it(@"should hide the cell separators", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
            });

            it(@"should have a row for every day time summary", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(2);

                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");

                DayTimeSummaryCell *cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
            });

            it(@"should not allow the rows to be selected", ^{
                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell1.accessoryType should equal(UITableViewCellAccessoryNone);
            });
        });
    });
    
    describe(@"presenting a table of days with issues count and violation image", ^{
        __block NSDateComponents *componentsA;
        __block NSDateComponents *componentsB;
        __block DayTimeSummaryCell *cell1;
        __block DayTimeSummaryCell *cell2;
        beforeEach(^{
            componentsA = nice_fake_for([NSDateComponents class]);
            componentsB = nice_fake_for([NSDateComponents class]);
            
            NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
            NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
            
            NSInteger countA = 0;
            NSInteger countB = 1;

            dayTimeSummaryA stub_method(@selector(totalViolationMessageCount)).and_return(countA);
            dayTimeSummaryB stub_method(@selector(totalViolationMessageCount)).and_return(countB);
            dayTimeSummaryA stub_method(@selector(timeOffComponents)).and_return(componentsA);
            dayTimeSummaryB stub_method(@selector(timeOffComponents)).and_return(componentsB);
            
            dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(timeoffTimeString1);
            dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(timeoffTimeString2);
            
            dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
            
        });

        context(@"when there is a totalViolationMessageCount", ^{
            beforeEach(^{
                [subject setupWithDayTimeSummaries:dayTimeSummaries
                                          delegate:delegate];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                spy_on(cell2.issueCount);
                spy_on(cell2.violationImage);
            });
            
            it(@"should show the cell separators", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleSingleLine);
            });
            
            it(@"should have a row for every day time summary", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(2);
                
                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                cell1.contentView.subviews should_not contain(cell1.violationImage);
                cell1.contentView.subviews should_not contain(cell1.issueCount);
                
                
                DayTimeSummaryCell *cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
                cell2.issueCount.text should equal(@"1");
                cell2.violationImage.image should equal([UIImage imageNamed:@"violation-active-day"]);
                cell2.violationImage.highlightedImage should equal([UIImage imageNamed:@"violation-active-day"]);
                cell2.issueCount.textColor should equal( [UIColor orangeColor]);
                cell2.issueCount.highlightedTextColor should equal( [UIColor orangeColor]);
                cell2.issueCount.font should equal( [UIFont systemFontOfSize:10]);
                

            });
            
            it(@"should allow the rows to be selected", ^{
                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell1.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                cell1.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
            });
            
            describe(@"presenting daily punches for each day in a timesheet", ^{
                
                context(@"when the user taps on a particular day's row", ^{
                    __block NSDate *expectedDate;
                    __block NSIndexPath *indexPath;
                    
                    beforeEach(^{
                        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        expectedDate = [NSDate dateWithTimeIntervalSince1970:1427305050];
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(dateForDayTimeSummary:)).with(dayTimeSummaryA).and_return(expectedDate);
                        
                        DayTimeSummaryCell *cell = (id)[subject.tableView cellForRowAtIndexPath:indexPath];
                        [cell tap];
                    });
                    
                    it(@"tells its delegate the date that was tapped", ^{
                        delegate should have_received(@selector(timeSheetBreakdownController:didSelectDayWithDate:dayTimeSummaries:indexPath:)).with(subject, expectedDate, dayTimeSummaries, indexPath);
                    });
                    
                    it(@"should deselect the tapped row immediately", ^{
                        subject.tableView.indexPathsForSelectedRows should be_nil;
                    });
                });
            });
        });
    });
    
    describe(@"presenting a table of days with timeoff hours summary", ^{
        __block NSDateComponents *componentsA;
        __block NSDateComponents *componentsB;
        __block DayTimeSummaryCell *cell1;
        __block DayTimeSummaryCell *cell2;
        context(@"when there are no components", ^{
            beforeEach(^{
                componentsA = nice_fake_for([NSDateComponents class]);
                componentsB = nice_fake_for([NSDateComponents class]);

                NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                
                dayTimeSummaryA stub_method(@selector(timeOffComponents)).and_return(componentsA);
                dayTimeSummaryB stub_method(@selector(timeOffComponents)).and_return(componentsB);
                
                dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(timeoffTimeString1);
                dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(timeoffTimeString2);
                
                dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                
            });
            
            beforeEach(^{
                [subject setupWithDayTimeSummaries:dayTimeSummaries
                                          delegate:nil];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                spy_on(cell1.timeOffTimeLabel);
                spy_on(cell1.separator);

                spy_on(cell2.timeOffTimeLabel);
                spy_on(cell2.separator);


            });
            
            afterEach(^{
                stop_spying_on(cell1.timeOffTimeLabel);
                stop_spying_on(cell2.timeOffTimeLabel);
                stop_spying_on(cell1.separator);
                stop_spying_on(cell2.separator);

            });
            
            it(@"should hide the cell separators", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
            });
            
            it(@"should have a row for every day time summary", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(2);
                
                [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                [cell1.timeOffTimeLabel.attributedText string] should_not equal(@"Timeoff String 1");
                cell1.timeOffTimeLabel.hidden should be_truthy;
                cell1.separator.hidden should be_truthy;

                [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
                [cell2.timeOffTimeLabel.attributedText string] should_not equal(@"Timeoff String 2");
                cell2.timeOffTimeLabel.hidden should be_truthy;
                cell2.separator.hidden should be_truthy;
            });
            
            it(@"should not allow the rows to be selected", ^{
                cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell1.accessoryType should equal(UITableViewCellAccessoryNone);
            });
        });
        
        context(@"when there are atleast one value in the components", ^{
            
            context(@"when only hour is present", ^{
                beforeEach(^{
                    componentsA = [[NSDateComponents alloc]init];;
                    componentsA.hour = 1;
                    
                    componentsB = [[NSDateComponents alloc]init];;
                    componentsB.hour = 4;
                    
                    NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                    NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                    
                    dayTimeSummaryA stub_method(@selector(timeOffComponents)).and_return(componentsA);
                    dayTimeSummaryB stub_method(@selector(timeOffComponents)).and_return(componentsB);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(timeoffTimeString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(timeoffTimeString2);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryA).and_return(dateString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryB).and_return(dateString2);
                    
                    dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                    
                });
                
                beforeEach(^{
                    [subject setupWithDayTimeSummaries:dayTimeSummaries
                                              delegate:nil];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];
                    cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });
                
                it(@"should hide the cell separators", ^{
                    subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
                });
                
                it(@"should have a row for every day time summary", ^{
                    [subject.tableView numberOfSections] should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(2);
                    
                    [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                    [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                    [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                    [cell1.timeOffTimeLabel.attributedText string] should equal(@"Timeoff String 1");
                    
                    [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                    [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                    [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
                    [cell2.timeOffTimeLabel.attributedText string] should equal(@"Timeoff String 2");
                });
                
                it(@"should not allow the rows to be selected", ^{
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell1.accessoryType should equal(UITableViewCellAccessoryNone);
                });
            });
            
            context(@"when only minute is present", ^{
                beforeEach(^{
                    componentsA = [[NSDateComponents alloc]init];;
                    componentsA.minute = 2;
                    
                    componentsB = [[NSDateComponents alloc]init];;
                    componentsB.minute = 5;
                    
                    NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                    NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                    
                    dayTimeSummaryA stub_method(@selector(timeOffComponents)).and_return(componentsA);
                    dayTimeSummaryB stub_method(@selector(timeOffComponents)).and_return(componentsB);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(timeoffTimeString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(timeoffTimeString2);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryA).and_return(dateString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryB).and_return(dateString2);
                    
                    dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                    
                });
                
                beforeEach(^{
                    [subject setupWithDayTimeSummaries:dayTimeSummaries
                                              delegate:nil];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];
                    cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });
                
                it(@"should hide the cell separators", ^{
                    subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
                });
                
                it(@"should have a row for every day time summary", ^{
                    [subject.tableView numberOfSections] should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(2);
                    
                    [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                    [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                    [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                    [cell1.timeOffTimeLabel.attributedText string] should equal(@"Timeoff String 1");
                    
                    [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                    [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                    [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
                    [cell2.timeOffTimeLabel.attributedText string] should equal(@"Timeoff String 2");
                });
                
                it(@"should not allow the rows to be selected", ^{
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell1.accessoryType should equal(UITableViewCellAccessoryNone);
                });
            });
            
            context(@"when only second is present", ^{
                beforeEach(^{
                    componentsA = [[NSDateComponents alloc]init];;
                    componentsA.second = 3;
                    
                    componentsB = [[NSDateComponents alloc]init];;
                    componentsB.second = 6;
                    
                    NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                    NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                    
                    dayTimeSummaryA stub_method(@selector(timeOffComponents)).and_return(componentsA);
                    dayTimeSummaryB stub_method(@selector(timeOffComponents)).and_return(componentsB);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(timeoffTimeString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(timeoffTimeString2);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryA).and_return(dateString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryB).and_return(dateString2);
                    
                    dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                    
                });
                
                beforeEach(^{
                    [subject setupWithDayTimeSummaries:dayTimeSummaries
                                              delegate:nil];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];
                    cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });
                
                it(@"should hide the cell separators", ^{
                    subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
                });
                
                it(@"should have a row for every day time summary", ^{
                    [subject.tableView numberOfSections] should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(2);
                    
                    [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                    [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                    [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                    [cell1.timeOffTimeLabel.attributedText string] should equal(@"Timeoff String 1");
                    
                    [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                    [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                    [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
                    [cell2.timeOffTimeLabel.attributedText string] should equal(@"Timeoff String 2");
                });
                
                it(@"should not allow the rows to be selected", ^{
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell1.accessoryType should equal(UITableViewCellAccessoryNone);
                });
            });
        });
    });
    
    describe(@"presenting a table with separtor line and accessory type", ^{
        
        context(@"when there is a delegate", ^{
            beforeEach(^{
                [subject setupWithDayTimeSummaries:dayTimeSummaries
                                          delegate:delegate];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
            });
            
            it(@"should show the cell separators", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleSingleLine);
            });
            
            it(@"should allow the rows to be selected", ^{
                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell1.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                cell1.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
            });
            
        });
        
        context(@"when there is no delegate", ^{
            beforeEach(^{
                [subject setupWithDayTimeSummaries:dayTimeSummaries
                                          delegate:nil];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
            });
            
            it(@"should hide the cell separators", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
            });
            
            it(@"should not allow the rows to be selected", ^{
                DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell1.accessoryType should equal(UITableViewCellAccessoryNone);
            });
        });
    
    });

    describe(@"updateWithDayTimeSummaries:", ^{

        beforeEach(^{
            [subject setupWithDayTimeSummaries:dayTimeSummaries
                                      delegate:delegate];
            subject.view should_not be_nil;
            subject.tableView should_not be_nil;
            spy_on(subject.tableView);
            [subject updateWithDayTimeSummaries:dayTimeSummaries];
        });

        it(@"should assign the passed in  daytimeSummaries", ^{
            subject.dayTimeSummaries should be_same_instance_as(dayTimeSummaries);
        });

        it(@"should call reloadTable", ^{
            subject.tableView should have_received(@selector(reloadData));
        });
    });

    describe(@"When the view loads", ^{
        beforeEach(^{
            [subject setupWithDayTimeSummaries:dayTimeSummaries
                                      delegate:delegate];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
            [subject.tableView layoutIfNeeded];
        });

        it(@"should inform its delegate to update its height", ^{
            delegate should have_received(@selector(timeSheetBreakdownController:didUpdateHeight:)).with(subject,(CGFloat)140);
        });
    });
    
    describe(@"cell styling based on ScheduledDay", ^{
        
        beforeEach(^{
            dayTimeSummaryA stub_method(@selector(isScheduledDay)).and_return(YES);
            dayTimeSummaryB stub_method(@selector(isScheduledDay)).and_return(NO);
            [subject setupWithDayTimeSummaries:@[dayTimeSummaryA,dayTimeSummaryB]
                                      delegate:delegate];
            subject.view should_not be_nil;
            [subject.tableView layoutIfNeeded];
        });
        
        
        it(@"should correctly style cells labels alpha ", ^{
            DayTimeSummaryCell *cell1 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell1.dateLabel.alpha should equal(CGFloat(1.0f));
            cell1.regularTimeLabel.alpha should equal(CGFloat(1.0f));
            cell1.breakTimeLabel.alpha should equal(CGFloat(1.0f));
            cell1.timeOffTimeLabel.alpha should equal(CGFloat(1.0f));
            
            
            DayTimeSummaryCell *cell2 = (id)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            cell2.dateLabel.alpha should equal(CGFloat(0.55f));
            cell2.regularTimeLabel.alpha should equal(CGFloat(0.55f));
            cell2.breakTimeLabel.alpha should equal(CGFloat(0.55f));
            cell2.timeOffTimeLabel.alpha should equal(CGFloat(0.55f));
        });
        
        
    });
});

SPEC_END
