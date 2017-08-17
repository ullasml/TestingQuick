#import <Cedar/Cedar.h>
#import "SupervisorTimesheetSummaryController.h"
#import "TimesheetDetailsPresenter.h"
#import "Theme.h"
#import "Cursor.h"
#import "UIControl+Spec.h"
#import "TeamTimesheetSummary.h"
#import "TimesheetPeriod.h"
#import "Timesheet.h"
#import <KSDeferred/KSDeferred.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupervisorTimesheetSummaryControllerSpec)

describe(@"SupervisorTimesheetSummaryController", ^{
    __block SupervisorTimesheetSummaryController *subject;
    __block TimesheetDetailsPresenter *timesheetDetailsPresenter;
    __block id<Theme> theme;
    __block id<SupervisorTimesheetSummaryControllerDelegate> delegate;
    __block KSDeferred *deferred;

    
    beforeEach(^{
        deferred = [[KSDeferred alloc]init];
        timesheetDetailsPresenter = nice_fake_for([TimesheetDetailsPresenter class]);
        delegate = nice_fake_for(@protocol(SupervisorTimesheetSummaryControllerDelegate));
        theme = nice_fake_for(@protocol(Theme));
        subject = [[SupervisorTimesheetSummaryController alloc] initWithTimesheetDetailsPresenter:timesheetDetailsPresenter
                                                                                            theme:theme];
        
        [subject setupWithDelegate:delegate timeSummaryPromise:deferred.promise];
    });
    
    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(timesheetDetailDateRangeFont)).and_return([UIFont italicSystemFontOfSize:15.0f]);
            subject.view should_not be_nil;
        });
        
        it(@"should style the labels", ^{
            subject.dateRangeLabel.font should equal([UIFont italicSystemFontOfSize:15.0f]);
        });
    });
    
    describe(@"presenting the date range of the current team timesheet summary", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should remove the initial placeholder text of the date range label", ^{
            subject.dateRangeLabel.text should be_nil;
        });
        
        it(@"should hide the next and previous buttons by default", ^{
            subject.view should_not be_nil;
            subject.nextTimesheetButton.hidden should be_truthy;
            subject.previousTimesheetButton.hidden should be_truthy;
        });
        
        
        
        context(@"when promise is resolved with a team timesheet summary", ^{
            __block TeamTimesheetSummary *teamTimesheetSummary;
            __block TimesheetPeriod *nextPeriod;
            __block TimesheetPeriod *previousPeriod;
            beforeEach(^{
                
                teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                
                previousPeriod = fake_for([TimesheetPeriod class]);
                nextPeriod = fake_for([TimesheetPeriod class]);
                TimesheetPeriod *currentPeriod = fake_for([TimesheetPeriod class]);

                teamTimesheetSummary stub_method(@selector(previousPeriod)).and_return(previousPeriod);
                teamTimesheetSummary stub_method(@selector(nextPeriod)).and_return(nextPeriod);
                teamTimesheetSummary stub_method(@selector(currentPeriod)).and_return(currentPeriod);
                
                timesheetDetailsPresenter stub_method(@selector(dateRangeTextWithTimesheetPeriod:))
                .with(currentPeriod)
                .and_return(@"A date range text");
                
            });
            
            it(@"should display the timesheet period", ^{
                [deferred resolveWithValue:teamTimesheetSummary];
                subject.dateRangeLabel.text should equal(@"A date range text");
            });
            
            describe(@"the timesheet period pagination control", ^{

                describe(@"when the cursor can move forwards and backwards", ^{
                    beforeEach(^{
                        subject.view should_not be_nil;
                        [deferred resolveWithValue:teamTimesheetSummary];
                    });
                    
                    it(@"should not disable the next button", ^{
                        subject.nextTimesheetButton.enabled should be_truthy;
                    });
                    
                    it(@"should disable the previous button", ^{
                        subject.previousTimesheetButton.enabled should be_truthy;
                    });
                });
                
                describe(@"when the cursor cannot move forwards", ^{
                    beforeEach(^{
                        teamTimesheetSummary stub_method(@selector(nextPeriod)).again().and_return(nil);
                        subject.view should_not be_nil;
                        [deferred resolveWithValue:teamTimesheetSummary];
                        
                    });
                    
                    it(@"should disable the next button", ^{
                        subject.nextTimesheetButton.enabled should be_falsy;
                    });
                });
                
                describe(@"when the cursor cannot move backwards", ^{
                    beforeEach(^{
                        teamTimesheetSummary stub_method(@selector(previousPeriod)).again().and_return(nil);
                        [deferred resolveWithValue:teamTimesheetSummary];
                        subject.view should_not be_nil;
                        
                    });
                    
                    it(@"should disable the previous button", ^{
                        subject.previousTimesheetButton.enabled should be_falsy;
                    });
                });
            });
            
        });
    });
    
    describe(@"the previous/next timesheet buttons", ^{
        __block TeamTimesheetSummary *teamTimesheetSummary;
        beforeEach(^{
            teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
            
            TimesheetPeriod *previousPeriod = fake_for([TimesheetPeriod class]);
            TimesheetPeriod *nextPeriod = fake_for([TimesheetPeriod class]);
            TimesheetPeriod *currentPeriod = fake_for([TimesheetPeriod class]);
            
            teamTimesheetSummary stub_method(@selector(previousPeriod)).and_return(previousPeriod);
            teamTimesheetSummary stub_method(@selector(nextPeriod)).and_return(nextPeriod);
            teamTimesheetSummary stub_method(@selector(currentPeriod)).and_return(currentPeriod);
            
            timesheetDetailsPresenter stub_method(@selector(dateRangeTextWithTimesheetPeriod:))
            .with(currentPeriod)
            .and_return(@"A date range text");
            
            subject.view should_not be_nil;
            
            [deferred resolveWithValue:teamTimesheetSummary];
        });
        
        describe(@"tapping on the previous timesheet button", ^{
            beforeEach(^{
                [subject.previousTimesheetButton tap];
            });
            
            it(@"should notify its delegate to show the previous timesheet", ^{
                delegate should have_received(@selector(timesheetSummaryControllerDidTapPreviousButton:)).with(subject);
            });
        });
        
        describe(@"tapping on the previous timesheet button", ^{
            beforeEach(^{
                [subject.nextTimesheetButton tap];
            });
            
            it(@"should notify its delegate to show the previous timesheet", ^{
                delegate should have_received(@selector(timesheetSummaryControllerDidTapNextButton:)).with(subject);
            });
        });
    });
});

SPEC_END
