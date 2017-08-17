#import <Cedar/Cedar.h>
#import "TimesheetSummaryController.h"
#import "TimesheetDetailsPresenter.h"
#import "Theme.h"
#import "Cursor.h"
#import "UIControl+Spec.h"
#import "TeamTimesheetSummary.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"
#import "Timesheet.h"
#import "IndexCursor.h"
#import "TimePeriodSummary.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"



using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetSummaryControllerSpec)

describe(@"TimesheetSummaryController", ^{
    __block TimesheetSummaryController *subject;
    __block TimesheetDetailsPresenter *timesheetDetailsPresenter;
    __block ChildControllerHelper *childControllerHelper;
    __block id<Theme> theme;
    __block id <TimesheetSummaryControllerDelegate> delegate;
    __block IndexCursor *cursor;
    __block id <Timesheet> timesheet;
    __block TimesheetPeriod *period;
    __block id <BSInjector,BSBinder> injector;
    __block HeaderButtonViewController *headerButtonViewController;
    __block TimeSheetApprovalStatus *approvalStatus;

    beforeEach(^{
        injector = [InjectorProvider injector];
        approvalStatus = nice_fake_for([TimeSheetApprovalStatus class]);

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        timesheetDetailsPresenter = nice_fake_for([TimesheetDetailsPresenter class]);
        [injector bind:[TimesheetDetailsPresenter class] toInstance:timesheetDetailsPresenter];
        
        headerButtonViewController = nice_fake_for([HeaderButtonViewController class]);
        [injector bind:[HeaderButtonViewController class] toInstance:headerButtonViewController];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        period = nice_fake_for([TimesheetPeriod class]);
        cursor = nice_fake_for([IndexCursor class]);
        
        timesheetDetailsPresenter stub_method(@selector(dateRangeTextWithTimesheetPeriod:)).with(period).and_return(@"A date range text");
        delegate = nice_fake_for(@protocol(TimesheetSummaryControllerDelegate));
        timesheet = nice_fake_for(@protocol(Timesheet));
        timesheet stub_method(@selector(period)).and_return(period);
        timesheet  stub_method(@selector(approvalStatus)).and_return(approvalStatus);

        subject = [injector getInstance:[TimesheetSummaryController class]];
        [subject setupWithDelegate:delegate cursor:cursor timesheet:timesheet];
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(timesheetDetailDateRangeFont)).and_return([UIFont italicSystemFontOfSize:15.0f]);
            theme stub_method(@selector(timesheetDetailCurrentPeriodFont)).and_return([UIFont boldSystemFontOfSize:14.0f]);
            theme stub_method(@selector(timesheetDetailCurrentPeriodTextColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(timesheetDetailDateRangeTextColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor magentaColor]);
            subject.view should_not be_nil;
        });

        it(@"should style the labels", ^{
            subject.dateRangeLabel.font should equal([UIFont italicSystemFontOfSize:15.0f]);
            subject.currentPeriodLabel.font should equal([UIFont boldSystemFontOfSize:14.0f]);
            subject.currentPeriodLabel.textColor should equal([UIColor redColor]);
            subject.dateRangeLabel.textColor should equal([UIColor greenColor]);

            subject.dateRangeLabel.backgroundColor should equal([UIColor clearColor]);
            subject.currentPeriodLabel.backgroundColor should equal([UIColor clearColor]);
            subject.nextTimesheetButton.backgroundColor should equal([UIColor clearColor]);
            subject.previousTimesheetButton.backgroundColor should equal([UIColor clearColor]);
            subject.violationsAndStatusButtonContainerView.backgroundColor should equal([UIColor magentaColor]);

        });
    });

    describe(@"presenting the date range of the current team timesheet summary", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        it(@"should display the timesheet period", ^{
            subject.dateRangeLabel.text should equal(@"A date range text");
        });
    });


    describe(@"the current period label", ^{
        __block TimePeriodSummary *timePeriodSummary;
        beforeEach(^{
            
            timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
            timesheet stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
        });
        
        context(@"when the timesheet is the current period", ^{
            beforeEach(^{
                timesheetDetailsPresenter stub_method(@selector(approvalStatusForTimeSheet:cursor:timeSheetPeriod:)).with(approvalStatus,nil,period).and_return(@"my-current-period-label-text");
                [subject setupWithDelegate:delegate cursor:cursor timesheet:timesheet];
                subject.view should_not be_nil;
                spy_on(subject.currentPeriodLabel);

            });
            
            afterEach(^{
                stop_spying_on(subject.currentPeriodLabel);
            });
            
            it(@"should display the approval status", ^{
                subject.currentPeriodLabel should_not have_received(@selector(removeFromSuperview));
            });
            
            it(@"should display the approval status", ^{
                subject.currentPeriodLabel.text should equal(@"my-current-period-label-text");
            });
        });
        
        context(@"when the timesheet is not the current period", ^{
            beforeEach(^{
                timesheetDetailsPresenter stub_method(@selector(approvalStatusForTimeSheet:cursor:timeSheetPeriod:)).with(approvalStatus,nil,period).and_return(nil);
                [subject setupWithDelegate:delegate cursor:cursor timesheet:timesheet];
                subject.view should_not be_nil;
                
                spy_on(subject.currentPeriodLabel);
            });
            
            afterEach(^{
                stop_spying_on(subject.currentPeriodLabel);
            });
            
            it(@"should display the approval status", ^{
                subject.view should_not contain(subject.currentPeriodLabel);
            });
        });

    });

    describe(@"the timesheet period pagination controls", ^{
        
        it(@"when the cursor cannot move backwards", ^{
            
            cursor stub_method(@selector(canMoveBackwards)).and_return(NO);
            cursor stub_method(@selector(canMoveForwards)).and_return(YES);
            [subject setupWithDelegate:delegate cursor:cursor timesheet:timesheet];
            subject.view should_not be_nil;

            subject.nextTimesheetButton.hidden should be_falsy;
            subject.previousTimesheetButton.hidden should be_truthy;
        });
        
        it(@"when the cursor cannot move forwards", ^{
            
            cursor stub_method(@selector(canMoveBackwards)).and_return(YES);
            cursor stub_method(@selector(canMoveForwards)).and_return(NO);
            [subject setupWithDelegate:delegate cursor:cursor timesheet:timesheet];
            subject.view should_not be_nil;
            
            subject.nextTimesheetButton.hidden should be_truthy;
            subject.previousTimesheetButton.hidden should be_falsy;
        });
        
        it(@"when the cursor can move forwards and backwards", ^{
            
            cursor stub_method(@selector(canMoveBackwards)).and_return(YES);
            cursor stub_method(@selector(canMoveForwards)).and_return(YES);
            [subject setupWithDelegate:delegate cursor:cursor timesheet:timesheet];
            subject.view should_not be_nil;
            
            subject.nextTimesheetButton.hidden should be_falsy;
            subject.previousTimesheetButton.hidden should be_falsy;
        });

        describe(@"when there is no cursor", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });

            it(@"should hide the next and previous buttons", ^{
                subject.nextTimesheetButton.hidden should be_truthy;
                subject.previousTimesheetButton.hidden should be_truthy;
            });
        });

    });
    
    describe(@"presenting the HeaderButtonViewController", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should add the header button controller as its child", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(headerButtonViewController,subject,subject.violationsAndStatusButtonContainerView);
        });
        
        it(@"should configure the header button controller correctly", ^{
            headerButtonViewController should have_received(@selector(setupWithDelegate:timesheet:)).with(subject,timesheet);
        });
        
    });
    
    describe(@"As a <HeaderButtonControllerDelegate>", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject userDidIntendToViewViolationsWidget];
        });
        
        it(@"should inform its delegate that user intends to view issues", ^{
            delegate should have_received(@selector(timesheetSummaryControllerDidTapissuesButton:)).with(subject);
        });
    });
    
    describe(@"updates its height when view layouts", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should update its width constraint", ^{
            delegate should have_received(@selector(timesheetSummaryControllerUpdateViewHeight:height:)).with(subject,Arguments::anything);

        });
    });
});

SPEC_END
