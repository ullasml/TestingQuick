#import <Cedar/Cedar.h>
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

SPEC_BEGIN(PunchWidgetTimesheetBreakdownControllerSpec)


describe(@"PunchWidgetTimesheetBreakdownController", ^{
    __block PunchWidgetTimesheetBreakdownController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block DayTimeSummaryCellPresenter *dayTimeSummaryCellPresenter;
    __block ChildControllerHelper *childControllerHelper;
    __block id <PunchWidgetTimesheetBreakdownControllerDelegate> delegate;
    __block TimesheetDaySummary *dayTimeSummaryA;
    __block TimesheetDaySummary *dayTimeSummaryB;
    __block NSArray *dayTimeSummaries;
    __block TimesheetDuration *timesheetDuration;
    __block PunchWidgetData *punchWidgetData;
    __block NSAttributedString *dateString1;
    __block NSAttributedString *dateString2;
    __block id <Theme> theme;
    __block UITableView *tableView;
    __block DurationSummaryWithoutOffsetController *durationsController;
    __block ViewMoreOrLessButtonController *viewMoreOrLessButtonController;
    

    beforeEach(^{
        injector = (id)[InjectorProvider injector];
        
        durationsController = nice_fake_for([DurationSummaryWithoutOffsetController class]);
        [injector bind:[DurationSummaryWithoutOffsetController class] toInstance:durationsController];
        
        viewMoreOrLessButtonController = nice_fake_for([ViewMoreOrLessButtonController class]);
        [injector bind:[ViewMoreOrLessButtonController class] toInstance:viewMoreOrLessButtonController];
        
        timesheetDuration = nice_fake_for([TimesheetDuration class]);
                
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        dayTimeSummaryCellPresenter = fake_for([DayTimeSummaryCellPresenter class]);
        [injector bind:[DayTimeSummaryCellPresenter class] toInstance:dayTimeSummaryCellPresenter];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        theme stub_method(@selector(timesheetBreakdownViolationCountColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(timesheetBreakdownViolationCountFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(timesheetWidgetTitleTextColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(timesheetWidgetTitleFont)).and_return([UIFont systemFontOfSize:12]);
        theme stub_method(@selector(timesheetBreakdownSeparatorColor)).and_return([UIColor redColor]);
        
        subject = [injector getInstance:[PunchWidgetTimesheetBreakdownController class]];
        delegate = nice_fake_for(@protocol(PunchWidgetTimesheetBreakdownControllerDelegate));
        
        dayTimeSummaryA = nice_fake_for([TimesheetDaySummary class]);
        dayTimeSummaryB = nice_fake_for([TimesheetDaySummary class]);
        
        NSDateComponents *timeoffComponentsA = [[NSDateComponents alloc]init];
        NSDateComponents *timeoffComponentsB = [[NSDateComponents alloc]init];
        
        NSInteger countA = 0;
        NSInteger countB = 1;
        
        dayTimeSummaryA stub_method(@selector(totalViolationMessageCount)).and_return(countA);
        dayTimeSummaryB stub_method(@selector(totalViolationMessageCount)).and_return(countB);
        dayTimeSummaryA stub_method(@selector(timeOffComponents)).and_return(timeoffComponentsA);
        dayTimeSummaryB stub_method(@selector(timeOffComponents)).and_return(timeoffComponentsB);
        dayTimeSummaryA stub_method(@selector(isScheduledDay)).and_return(YES);
        dayTimeSummaryB stub_method(@selector(isScheduledDay)).and_return(NO);
        
        dateString1 = [[NSAttributedString alloc] initWithString:@"Date String 1"];
        dateString2 = [[NSAttributedString alloc] initWithString:@"Date String 2"];
        
        NSAttributedString *regularTimeString1 = [[NSAttributedString alloc] initWithString:@"Regular String 1"];
        NSAttributedString *regularTimeString2 = [[NSAttributedString alloc] initWithString:@"Regular String 2"];
        
        NSAttributedString *breakTimeString1 = [[NSAttributedString alloc] initWithString:@"Break String 1"];
        NSAttributedString *breakTimeString2 = [[NSAttributedString alloc] initWithString:@"Break String 2"];
        
        NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
        NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
        
        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(dateString1);
        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(dateString2);
        
        dayTimeSummaryCellPresenter stub_method(@selector(regularTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(regularTimeString1);
        dayTimeSummaryCellPresenter stub_method(@selector(regularTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(regularTimeString2);
        
        dayTimeSummaryCellPresenter stub_method(@selector(breakTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(breakTimeString1);
        dayTimeSummaryCellPresenter stub_method(@selector(breakTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(breakTimeString2);
        
        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).and_return(timeoffTimeString1);
        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).and_return(timeoffTimeString2);
        
        dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
        punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
        [subject setupWithPunchWidgetData:punchWidgetData
                                 delegate:delegate 
                           hasBreakAccess:true];
    });
    
    
    describe(@"presenting the breakdown table view", ^{
        
        context(@"presenting tableview with disclosure, cell and table selection style", ^{
            

            context(@"its table view datasource and delagate", ^{
                beforeEach(^{
                    subject.view should_not be_nil;
                    tableView = subject.tableView;
                });
                
                it(@"should be the datasource", ^{
                    tableView.dataSource should be_same_instance_as(subject);
                });
                
                it(@"should be the delegate", ^{
                    tableView.delegate should be_same_instance_as(subject);
                });
                
                it(@"should not be scrollable", ^{
                    tableView.scrollEnabled should be_falsy;
                });
            });
            context(@"when there is a delegate", ^{
                beforeEach(^{
                    [subject setupWithPunchWidgetData:punchWidgetData
                                             delegate:delegate
                                       hasBreakAccess:true];
                    subject.view should_not be_nil;
                    tableView = subject.tableView;
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should show the cell separators", ^{
                    subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleSingleLine);
                });
                
                it(@"should allow the rows to be selected", ^{
                    DayTimeSummaryCell *cell1 = (id)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                    cell1.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                });
            });
            
            context(@"when there is no delegate", ^{
                
                beforeEach(^{
                    [subject setupWithPunchWidgetData:punchWidgetData
                                             delegate:nil
                                       hasBreakAccess:true];
                    subject.view should_not be_nil;
                    tableView = subject.tableView;
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should hide the cell separators", ^{
                    subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
                });
                
                it(@"should not allow the rows to be selected", ^{
                    DayTimeSummaryCell *cell1 = (id)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell1.accessoryType should equal(UITableViewCellAccessoryNone);
                });
            });
        });
        
        context(@"presenting a table of days with hours worked summary", ^{
            
            __block DayTimeSummaryCell *cell1;
            __block  DayTimeSummaryCell *cell2;
            __block UITableView *tableView;
            beforeEach(^{
                [subject setupWithPunchWidgetData:punchWidgetData
                                         delegate:delegate
                                   hasBreakAccess:true];
                subject.view should_not be_nil;
                tableView = subject.tableView;
                [tableView layoutIfNeeded];
                cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            });
            
            it(@"should have a row for every day time summary", ^{
                [tableView numberOfSections] should equal(1);
                [tableView numberOfRowsInSection:0] should equal(2);

                [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                
                [cell2.dateLabel.attributedText string] should equal(@"Date String 2");
                [cell2.regularTimeLabel.attributedText string] should equal(@"Regular String 2");
                [cell2.breakTimeLabel.attributedText string] should equal(@"Break String 2");
            });
            
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
                    delegate should have_received(@selector(punchWidgetTimesheetBreakdownController:didSelectDayWithTimesheetDaySummary:)).with(subject, dayTimeSummaryA);
                });
                
                it(@"should deselect the tapped row immediately", ^{
                    subject.tableView.indexPathsForSelectedRows should be_nil;
                });
            });
        });
        
        describe(@"presenting a table with separator line and accessory type", ^{
            
            context(@"when there is a delegate", ^{
                beforeEach(^{
                    [subject setupWithPunchWidgetData:punchWidgetData
                                             delegate:delegate
                                       hasBreakAccess:true];
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
                    [subject setupWithPunchWidgetData:punchWidgetData
                                             delegate:nil
                                       hasBreakAccess:true];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should hide the cell separators", ^{
                    subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
                });
                
                it(@"should not allow the rows to be selected", ^{
                    DayTimeSummaryCell *cell1 = (DayTimeSummaryCell *)[subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell1.accessoryType should equal(UITableViewCellAccessoryNone);
                });
            });
            
        });
        
        context(@"cell styling based on ScheduledDay", ^{
            
            __block DayTimeSummaryCell *cell1;
            __block  DayTimeSummaryCell *cell2;
            __block UITableView *tableView;
            beforeEach(^{
                [subject setupWithPunchWidgetData:punchWidgetData
                                         delegate:delegate
                                   hasBreakAccess:true];
                subject.view should_not be_nil;
                tableView = subject.tableView;
                [tableView layoutIfNeeded];
                cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            });
            
            it(@"should correctly style cells labels alpha ", ^{
                cell1.dateLabel.alpha should equal(CGFloat(1.0f));
                cell1.regularTimeLabel.alpha should equal(CGFloat(1.0f));
                cell1.breakTimeLabel.alpha should equal(CGFloat(1.0f));
                cell1.timeOffTimeLabel.alpha should equal(CGFloat(1.0f));
            
                cell2.dateLabel.alpha should equal(CGFloat(0.55f));
                cell2.regularTimeLabel.alpha should equal(CGFloat(0.55f));
                cell2.breakTimeLabel.alpha should equal(CGFloat(0.55f));
                cell2.timeOffTimeLabel.alpha should equal(CGFloat(0.55f));
            });
        });
        
        describe(@"presenting a table of days with issues count and violation image", ^{
            
            __block DayTimeSummaryCell *cell1;
            __block DayTimeSummaryCell *cell2;
            
            beforeEach(^{
                [subject setupWithPunchWidgetData:punchWidgetData
                                         delegate:delegate
                                   hasBreakAccess:true];
                subject.view should_not be_nil;
                tableView = subject.tableView;
                [subject.tableView layoutIfNeeded];
                
                cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];;
                
                spy_on(cell2.issueCount);
                spy_on(cell2.violationImage);
            });
            
            it(@"should have a row for every day time summary", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(2);
                
                [cell1.dateLabel.attributedText string] should equal(@"Date String 1");
                [cell1.regularTimeLabel.attributedText string] should equal(@"Regular String 1");
                [cell1.breakTimeLabel.attributedText string] should equal(@"Break String 1");
                cell1.contentView.subviews should_not contain(cell1.violationImage);
                cell1.contentView.subviews should_not contain(cell1.issueCount);
                
                
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
            
        });
        
        describe(@"presenting a table of days with timeoff hours summary", ^{
            __block NSDateComponents *componentsA;
            __block NSDateComponents *componentsB;
            __block DayTimeSummaryCell *cell1;
            __block DayTimeSummaryCell *cell2;
            context(@"when there are no components", ^{
                beforeEach(^{
                    componentsA = [[NSDateComponents alloc]init];
                    componentsA.hour = 0;
                    componentsA.minute = 0;
                    componentsA.second = 0;

                    componentsB = [[NSDateComponents alloc]init];
                    componentsB.hour = 0;
                    componentsB.minute = 0;
                    componentsB.second = 0;
                    
                    NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                    NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                    
                    dayTimeSummaryA stub_method(@selector(timeOffComponents)).again().and_return(componentsA);
                    dayTimeSummaryB stub_method(@selector(timeOffComponents)).again().and_return(componentsB);
                    
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).again().and_return(timeoffTimeString1);
                    dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).again().and_return(timeoffTimeString2);
                    
                    NSInteger countA = 0;
                    NSInteger countB = 1;
                    
                    dayTimeSummaryA stub_method(@selector(totalViolationMessageCount)).again().and_return(countA);
                    dayTimeSummaryB stub_method(@selector(totalViolationMessageCount)).again().and_return(countB);
                    
                    dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                    punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
                    
                    
                });
                
                beforeEach(^{
                    [subject setupWithPunchWidgetData:punchWidgetData
                                             delegate:delegate
                                       hasBreakAccess:true];
                    subject.view should_not be_nil;
                    tableView = subject.tableView;
                    [subject.tableView layoutIfNeeded];
                    
                    cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                    cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];;
                    
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
                        
                        dayTimeSummaryA stub_method(@selector(timeOffComponents)).again().and_return(componentsA);
                        dayTimeSummaryB stub_method(@selector(timeOffComponents)).again().and_return(componentsB);
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).again().and_return(timeoffTimeString1);
                        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).again().and_return(timeoffTimeString2);
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryA).and_return(dateString1);
                        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryB).and_return(dateString2);
                        
                        dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                        punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
                        
                        
                    });
                    
                    beforeEach(^{
                        [subject setupWithPunchWidgetData:punchWidgetData
                                                 delegate:delegate
                                           hasBreakAccess:true];
                        subject.view should_not be_nil;
                        tableView = subject.tableView;
                        [subject.tableView layoutIfNeeded];
                        cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                        cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];;
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
                });
                
                context(@"when only minute is present", ^{
                    beforeEach(^{
                        componentsA = [[NSDateComponents alloc]init];;
                        componentsA.minute = 2;
                        
                        componentsB = [[NSDateComponents alloc]init];;
                        componentsB.minute = 5;
                        
                        NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                        NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                        
                        dayTimeSummaryA stub_method(@selector(timeOffComponents)).again().and_return(componentsA);
                        dayTimeSummaryB stub_method(@selector(timeOffComponents)).again().and_return(componentsB);
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).again().and_return(timeoffTimeString1);
                        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).again().and_return(timeoffTimeString2);
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryA).and_return(dateString1);
                        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryB).and_return(dateString2);
                        
                        dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                        punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
                        
                        
                    });
                    
                    beforeEach(^{
                        [subject setupWithPunchWidgetData:punchWidgetData
                                                 delegate:delegate
                                           hasBreakAccess:true];
                        subject.view should_not be_nil;
                        tableView = subject.tableView;
                        [subject.tableView layoutIfNeeded];
                        cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
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
                });
                
                context(@"when only second is present", ^{
                    beforeEach(^{
                        componentsA = [[NSDateComponents alloc]init];;
                        componentsA.second = 3;
                        
                        componentsB = [[NSDateComponents alloc]init];;
                        componentsB.second = 6;
                        
                        NSAttributedString *timeoffTimeString1 = [[NSAttributedString alloc] initWithString:@"Timeoff String 1"];
                        NSAttributedString *timeoffTimeString2 = [[NSAttributedString alloc] initWithString:@"Timeoff String 2"];
                        
                        dayTimeSummaryA stub_method(@selector(timeOffComponents)).again().and_return(componentsA);
                        dayTimeSummaryB stub_method(@selector(timeOffComponents)).again().and_return(componentsB);
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryA).again().and_return(timeoffTimeString1);
                        dayTimeSummaryCellPresenter stub_method(@selector(timeOffTimeStringForDayTimeSummary:)).with(dayTimeSummaryB).again().and_return(timeoffTimeString2);
                        
                        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryA).and_return(dateString1);
                        dayTimeSummaryCellPresenter stub_method(@selector(dateStringForDayTimeSummary:)).again().with(dayTimeSummaryB).and_return(dateString2);
                        
                        dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB];
                        punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
                        
                        
                    });
                    
                    beforeEach(^{
                        [subject setupWithPunchWidgetData:punchWidgetData
                                                 delegate:delegate
                                           hasBreakAccess:true];
                        subject.view should_not be_nil;
                        tableView = subject.tableView;
                        [subject.tableView layoutIfNeeded];
                        cell1 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
                        cell2 = (DayTimeSummaryCell *)[subject tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];;
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
                });
            });
        });
    });
    
    describe(@"When the view loads", ^{
        beforeEach(^{
            [subject setupWithPunchWidgetData:punchWidgetData
                                     delegate:delegate
                               hasBreakAccess:true];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should inform its delegate to update its height", ^{
            delegate should have_received(@selector(punchWidgetTimesheetBreakdownController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
        });
    });
    
    describe(@"Presenting the DurationSummaryWithoutOffsetController", ^{
        beforeEach(^{
            [subject setupWithPunchWidgetData:punchWidgetData
                                     delegate:delegate
                               hasBreakAccess:true];
            subject.view should_not be_nil;
        });
        
        it(@"should add DurationSummaryWithoutOffsetController as a child controller to PunchWidgetTimesheetBreakdownController", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(durationsController,subject,subject.widgetDurationContainerView);
        });
        
        it(@"should correctly set up DurationSummaryWithoutOffsetController", ^{
            durationsController should have_received(@selector(setupWithTimesheetDuration:delegate:hasBreakAccess:)).with(timesheetDuration,subject,YES);
        });
    });
    
    describe(@"Presenting the viewMoreOrLessButtonController", ^{
        
        context(@"when day summaries count is greater than 7", ^{
            beforeEach(^{
                dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB,dayTimeSummaryA, dayTimeSummaryB,dayTimeSummaryA, dayTimeSummaryB,dayTimeSummaryA, dayTimeSummaryB];
                punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
                [subject setupWithPunchWidgetData:punchWidgetData
                                         delegate:delegate
                                   hasBreakAccess:true];
                subject.view should_not be_nil;
            });
            
            it(@"should add viewMoreOrLessButtonController as a child controller to PunchWidgetTimesheetBreakdownController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(viewMoreOrLessButtonController,subject,subject.viewMoreOrLessContainerView);
            });
            
            it(@"should correctly set up viewMoreOrLessButtonController", ^{
                viewMoreOrLessButtonController should have_received(@selector(setupWithViewItemsAction:delegate:)).with(More,subject);
            });
        });
        
        context(@"when day summaries count is less than 7", ^{
            beforeEach(^{
                [subject setupWithPunchWidgetData:punchWidgetData
                                         delegate:delegate
                                   hasBreakAccess:true];
                subject.view should_not be_nil;
                spy_on(subject.viewMoreOrLessContainerView);
            });
            
            afterEach(^{
                stop_spying_on(subject.viewMoreOrLessContainerView);
            });
            
            it(@"should not add viewMoreOrLessButtonController as a child controller to PunchWidgetTimesheetBreakdownController", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.viewMoreOrLessContainerView);
            });
            
            it(@"should remove viewMoreOrLessContainerView", ^{
                subject.view.subviews should_not contain(subject.viewMoreOrLessContainerView);
            });
        });
        
    });
    
    describe(@"As a <DurationSummaryWithoutOffsetControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithPunchWidgetData:punchWidgetData
                                     delegate:delegate
                               hasBreakAccess:true];
            subject.view should_not be_nil;
            [subject durationSummaryWithoutOffsetControllerIntendsToUpdateItsContainerWithHeight:100];
        });
        
        it(@"should correctly update the container height", ^{
            subject.widgetDurationContainerHeightConstraint.constant should equal(100);
        });
    });
    
    describe(@"As a <ViewMoreOrLessButtonControllerDelegate>", ^{
        
        beforeEach(^{
            dayTimeSummaries = @[dayTimeSummaryA, dayTimeSummaryB,dayTimeSummaryA, dayTimeSummaryB,dayTimeSummaryA, dayTimeSummaryB,dayTimeSummaryA, dayTimeSummaryB];
            punchWidgetData = [[PunchWidgetData alloc]initWithDaySummaries:dayTimeSummaries widgetLevelDuration:timesheetDuration];
            [subject setupWithPunchWidgetData:punchWidgetData
                                     delegate:delegate
                               hasBreakAccess:true];
            subject.view should_not be_nil;
        });
        
        
        describe(@"viewMoreOrLessButtonController:intendsToUpdateItsContainerWithHeight", ^{
            beforeEach(^{
                [subject viewMoreOrLessButtonController:(id)[NSNull null] intendsToUpdateItsContainerWithHeight:100];

            });
            it(@"should correctly update the container height", ^{
                subject.viewMoreOrLessContainerHeightConstraint.constant should equal(100);
            });
        });
        
        describe(@"viewMoreOrLessButtonControllerIntendsToViewMoreItems:", ^{
            beforeEach(^{
                [subject viewMoreOrLessButtonControllerIntendsToViewMoreItems:(id)[NSNull null]];
                
            });
            
            it(@"should correctly show the cells", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(8);
            });

            it(@"should inform its delegate to update its height", ^{
                delegate should have_received(@selector(punchWidgetTimesheetBreakdownController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
            });
        });
      
        describe(@"viewMoreOrLessButtonControllerIntendsToViewLessItems:", ^{
            beforeEach(^{
                [subject viewMoreOrLessButtonControllerIntendsToViewLessItems:(id)[NSNull null]];
            });
            
            it(@"should correctly show the cells", ^{
                [subject.tableView numberOfSections] should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(7);
            });
            
            it(@"should inform its delegate to update its height", ^{
                delegate should have_received(@selector(punchWidgetTimesheetBreakdownController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
            });

        });
    });
    
});

SPEC_END
