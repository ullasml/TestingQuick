#import <Foundation/Foundation.h>
#import <Cedar/Cedar.h>
#import "DayController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "DayTimeSummary.h"
#import "TimesheetBreakdownController.h"
#import <KSDeferred/KSPromise.h>
#import "ChildControllerHelper.h"
#import "Theme.h"
#import "UserSession.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetDaySummary.h"
#import "DayTimeSummaryTitlePresenter.h"
#import "DayTimeSummaryController.h"
#import "WorkHoursDeferred.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(DayControllerSpec)

describe(@"DayController", ^{
    
    __block DayController *subject;
    __block ChildControllerHelper <CedarDouble>*childControllerHelper;
    __block DayTimeSummaryTitlePresenter *dayTimeSummaryTitlePresenter;
    __block id <PunchChangeObserverDelegate> punchChangeObserverDelegate;
    __block id <UserSession> userSession;
    __block NSDate *date;
    __block id<Theme> theme;
    __block TimesheetDaySummary *dayTimeSummary;
    __block id<BSBinder, BSInjector> injector;
    __block NSAttributedString *attributedStringTitle;
    __block DayTimeSummaryController *dayTimeSummaryController;
    __block WorkHoursDeferred *workHoursDeferred;
    __block TimesheetDayTimeLineController *timeLineController;
    __block DayTimeSummaryCellPresenter *dayTimeSummaryCellPresenter;
    __block UINavigationController *navigationController;
    
   
    beforeEach(^{
        injector = [InjectorProvider injector];
        dayTimeSummaryTitlePresenter = nice_fake_for([DayTimeSummaryTitlePresenter class]);
        [injector bind:[DayTimeSummaryTitlePresenter class] toInstance:dayTimeSummaryTitlePresenter];

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        dayTimeSummaryCellPresenter = nice_fake_for([DayTimeSummaryCellPresenter class]);
        [injector bind:[DayTimeSummaryCellPresenter class] toInstance:dayTimeSummaryCellPresenter];
        
        timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
        [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];

        userSession = nice_fake_for(@protocol(UserSession));
        [injector bind:@protocol(UserSession) toInstance:userSession];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        punchChangeObserverDelegate = nice_fake_for(@protocol(PunchChangeObserverDelegate));
        date = [NSDate dateWithTimeIntervalSince1970:0];
        dayTimeSummary = nice_fake_for([TimesheetDaySummary class]);
        dayTimeSummary stub_method(@selector(punchesForDay)).and_return(@[@"some-punch-A",@"some-punch-B"]);
        dayTimeSummary stub_method(@selector(isScheduledDay)).and_return(YES);
        
        subject = [injector getInstance:[DayController class]];
        
        attributedStringTitle = [[NSAttributedString alloc]initWithString:@"some-string"];
        dayTimeSummaryTitlePresenter stub_method(@selector(dateStringForDayTimeSummary:)).with(dayTimeSummary).and_return(attributedStringTitle);
        
        dayTimeSummaryController = nice_fake_for([DayTimeSummaryController class]);
        [injector bind:[DayTimeSummaryController class] toInstance:dayTimeSummaryController];
        
        workHoursDeferred = [[WorkHoursDeferred alloc]init];
        [injector bind:[WorkHoursDeferred class] toInstance:workHoursDeferred];

        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                  timesheetDaySummary:dayTimeSummary
                                       hasBreakAccess:NO
                                             delegate:nil 
                                              userURI:@"my-special-user-uri"
                                                 date:date];
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
    });

    describe(@"its navigation title", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
        });

        it(@"should be configured correctly", ^{
            subject.navigationItem.titleView should be_instance_of([UILabel class]);
        });
        
        it(@"should be configured correctly", ^{
            UILabel *label = (UILabel *)subject.navigationItem.titleView;
            label.attributedText should equal(attributedStringTitle);
        });
    });

    describe(@"its view width", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
        });

        it(@"view width should be same as screen width", ^{
            subject.widthConstraint.constant should equal((float)CGRectGetWidth([[UIScreen mainScreen] bounds]));
        });
    });
    
    describe(@"its back button title", ^{
        __block KSPromise *punchPromise;
        beforeEach(^{
            punchPromise = nice_fake_for([KSPromise class]);
            [subject view];
        });

        it(@"should be configured correctly", ^{
            navigationController.navigationBar.topItem should_not be_nil;
            navigationController.navigationBar.topItem.title should equal(RPLocalizedString(@"Back", nil));
        });
    });

    describe(@"presenting the timesheet breakdown for the current timesheet period", ^{
       
        context(@"when break access is enabled", ^{
            beforeEach(^{
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          timesheetDaySummary:dayTimeSummary
                                               hasBreakAccess:YES
                                                     delegate:nil 
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                [subject view];
            });
            
            it(@"should present the timesheet breakdown controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
            });
            
            it(@"should set up the timesheet breakdown controller correctly", ^{
                dayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:))
                .with(nil, nil,[workHoursDeferred promise], YES, YES, 0.0);
            });
        });
        
        context(@"when break access is disabled", ^{
            beforeEach(^{
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          timesheetDaySummary:dayTimeSummary
                                               hasBreakAccess:NO
                                                     delegate:nil 
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                [subject view];
            });
            
            it(@"should present the timesheet breakdown controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
            });
            
            it(@"should set up the timesheet breakdown controller correctly", ^{
                dayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:))
                .with(nil, nil,[workHoursDeferred promise], NO, YES, 0.0);
            });
        });
       
    });
    
    describe(@"presenting the time line for the current day", ^{

        
        context(@"when delegate is nil", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-user-uri");
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(punchChangeObserverDelegate,nil, subject, @"my-special-user-uri",SupervisorFlowContext,@[@"some-punch-A",@"some-punch-B"],DayControllerTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineContainerView);
            });
        });
        
        context(@"when delegate is not nil", ^{
            __block id <DayControllerDelegate> delegate;
            beforeEach(^{
                delegate = nice_fake_for(@protocol(DayControllerDelegate));
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                          timesheetDaySummary:dayTimeSummary
                                               hasBreakAccess:NO
                                                     delegate:delegate 
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-user-uri");
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(subject,nil, subject, @"my-special-user-uri",SupervisorFlowContext,@[@"some-punch-A",@"some-punch-B"],DayControllerTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineContainerView);
            });
        });

    });

    describe(@"as a <TimeLineControllerDelegate>", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        describe(@"timeLineController:didUpdateHeight:", ^{
            beforeEach(^{
                [subject timesheetDayTimeLineController:(id)[NSNull null] didUpdateHeight:123.0f];
            });

            it(@"should set the timeline container view's height constant", ^{
                subject.timeLineHeightConstraint.constant should equal((CGFloat)123.0f);
            });
        });

        describe(@"timeLineControllerDidRequestDate:", ^{
            __block NSDate *returnedDate;
            beforeEach(^{
                returnedDate = [subject timesheetDayTimeLineControllerDidRequestDate:(id)[NSNull null]];
            });

            it(@"should return the correct date", ^{
                returnedDate should be_same_instance_as(date);
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(dayControllerBackgroundColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(dayControllerBorderColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor redColor]);
            [subject view];
        });

        it(@"should style the background color", ^{
            subject.view.backgroundColor should equal([UIColor orangeColor]);
        });

        it(@"should style the top and bottom border line view background color", ^{
            subject.topBorderLineView.backgroundColor should equal([UIColor yellowColor]);
            subject.bottomBorderLineView.backgroundColor should equal([UIColor yellowColor]);
        });
        
        it(@"should style the work hours container view background color", ^{
            subject.workHoursContainerView.backgroundColor should equal([UIColor redColor]);
        });
    });
    
    describe(@"updateWithDayTimeSummaries", ^{
        
        __block TimesheetDaySummary *newTimesheetDaySummary;
        __block TimesheetDayTimeLineController *newTimeLineController;
        __block DayTimeSummaryController *newDayTimeSummaryController;
        __block WorkHoursDeferred *newWorkHoursDeferred;



        beforeEach(^{
            newWorkHoursDeferred = [[WorkHoursDeferred alloc]init];
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");

            newTimesheetDaySummary = nice_fake_for([TimesheetDaySummary class]);
            newTimesheetDaySummary stub_method(@selector(punchesForDay)).and_return(@[@"some-new-punch-A",@"some-new-punch-B"]);
            newTimesheetDaySummary stub_method(@selector(isScheduledDay)).and_return(YES);
            subject.view should_not be_nil;
            
            newDayTimeSummaryController = nice_fake_for([DayTimeSummaryController class]);
            [injector bind:[DayTimeSummaryController class] toInstance:newDayTimeSummaryController];

            newTimeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
            [injector bind:[TimesheetDayTimeLineController class] toInstance:newTimeLineController];
            
            [injector bind:[WorkHoursDeferred class] toInstance:newWorkHoursDeferred];

            
            [subject updateWithDayTimeSummaries:newTimesheetDaySummary];
        });
        
        it(@"should replace the old time line controller", ^{
            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timeLineController,newTimeLineController,subject,subject.timeLineContainerView);
        });
        
        it(@"should replace the old day Time Summary Controller", ^{
            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(dayTimeSummaryController,newDayTimeSummaryController,subject,subject.workHoursContainerView);
        });
        
        it(@"should set up the new timeline controller correctly", ^{
            newTimeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
            .with(punchChangeObserverDelegate,nil, subject, @"my-special-user-uri",UserFlowContext,@[@"some-new-punch-A",@"some-new-punch-B"],DayControllerTimeLinePunchFlowContext);
        });
        
        it(@"should set up the new day Time Summary Controller correctly", ^{
            newDayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:))
            .with(nil,nil, [newWorkHoursDeferred promise],NO, YES, 0.0);
            [newWorkHoursDeferred promise].value should equal(newTimesheetDaySummary);
        });
        
    });
    
    describe(@"As a <PunchChangeObserverDelegate>", ^{
        
        
        __block TimesheetDayTimeLineController *newTimeLineController;
        __block DayTimeSummaryController *newDayTimeSummaryController;
        __block KSPromise *expectedPromise;
        __block id <DayControllerDelegate> delegate;
        __block KSDeferred *newPunchesDeferred;
        beforeEach(^{
            newPunchesDeferred = [[KSDeferred alloc]init];
            delegate = nice_fake_for(@protocol(DayControllerDelegate));
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                      timesheetDaySummary:dayTimeSummary
                                           hasBreakAccess:NO
                                                 delegate:delegate 
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            
            delegate stub_method(@selector(needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController:)).and_return(newPunchesDeferred.promise);            
            expectedPromise = [subject punchOverviewEditControllerDidUpdatePunch];
        });
        
        context(@"when the time punches promise succeeds ", ^{
            __block TimesheetInfo *timesheetInfo;
            __block TimePeriodSummary *timePeriodSummary;
            __block TimesheetDaySummary *timesheetDaySummary;

            beforeEach(^{
                timesheetInfo = nice_fake_for([TimesheetInfo class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                timesheetDaySummary = nice_fake_for([TimesheetDaySummary class]);
                timesheetDaySummary stub_method(@selector(isScheduledDay)).and_return(YES);
                timesheetDaySummary stub_method(@selector(punchesForDay)).and_return(@[@"some-new-punch-AA",@"some-new-punch-BB"]);
                timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(@[timesheetDaySummary]);
                timesheetInfo stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
            }); 
            
            context(@"when the timesummary is same as the date for which the screen is being viewed", ^{  
                __block WorkHoursDeferred *newWorkHoursDeferred;
                beforeEach(^{
                    newWorkHoursDeferred = [[WorkHoursDeferred alloc]init];
                    dayTimeSummaryCellPresenter stub_method(@selector(dateForDayTimeSummary:)).with(timesheetDaySummary).and_return(date);
                    [injector bind:[WorkHoursDeferred class] toInstance:newWorkHoursDeferred];
                    
                    newDayTimeSummaryController = nice_fake_for([DayTimeSummaryController class]);
                    [injector bind:[DayTimeSummaryController class] toInstance:newDayTimeSummaryController];
                    
                    newTimeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                    [injector bind:[TimesheetDayTimeLineController class] toInstance:newTimeLineController];
                    
                    [newPunchesDeferred resolveWithValue:timesheetInfo];
                });
                
                it(@"should replace the old time line controller", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,newTimeLineController,subject,subject.timeLineContainerView);
                });
                
                it(@"should replace the old day Time Summary Controller", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,newDayTimeSummaryController,subject,subject.workHoursContainerView);
                });
                
                it(@"should set up the new timeline controller correctly", ^{
                    newTimeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                    .with(subject,nil, subject, @"my-special-user-uri",UserFlowContext,@[@"some-new-punch-AA",@"some-new-punch-BB"],DayControllerTimeLinePunchFlowContext);
                });
                
                it(@"should set up the new day Time Summary Controller correctly", ^{
                    newDayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:))
                    .with(nil,nil, [newWorkHoursDeferred promise],NO, YES, 0.0);
                    [newWorkHoursDeferred promise].value should equal(timesheetDaySummary);
                });

            });
            
            context(@"when the timesummary is not same as the date for which the screen is being viewed", ^{
                
                beforeEach(^{
                    dayTimeSummaryCellPresenter stub_method(@selector(dateForDayTimeSummary:)).with(timesheetDaySummary).and_return([NSDate dateWithTimeIntervalSince1970:1]);
                    [childControllerHelper reset_sent_messages];
                    [newPunchesDeferred resolveWithValue:timesheetInfo];
                    
                });
                it(@"should not replace the old time line controller", ^{
                    childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.timeLineContainerView);
                });
                
                it(@"should not replace the old day Time Summary Controller", ^{
                    childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(Arguments::anything,Arguments::anything,subject,subject.workHoursContainerView);
                });
            });
        });

    });

});

SPEC_END
