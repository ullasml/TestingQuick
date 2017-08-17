#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import <KSDeferred/KSPromise.h>
#import "PunchInController.h"
#import "Theme.h"
#import "DayTimeSummaryController.h"
#import "TimesheetButtonController.h"
#import "TimesheetButtonControllerPresenter.h"
#import "InjectorProvider.h"
#import "ChildControllerHelper.h"
#import "DayTimeSummaryControllerProvider.h"
#import "TodaysDateControllerProvider.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "InjectorKeys.h"
#import "ViolationEmployee.h"
#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "UIControl+Spec.h"
#import "DateProvider.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "WorkHoursStorage.h"
#import "TimesheetDayTimeLineController.h"
#import "TimeLinePunchesSummary.h"
#import <KSDeferred/KSDeferred.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchInControllerSpec)

describe(@"PunchInController", ^{
    __block PunchInController *subject;
    __block id<PunchInControllerDelegate> delegate;
    __block DayTimeSummaryController *dayTimeSummaryController;
    __block TodaysDateControllerProvider *todaysDateControllerProvider;
    __block DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
    __block DateProvider *dateProvider;
    __block ChildControllerHelper *childControllerHelper;
    __block ViolationRepository *violationRepository;
    __block KSPromise *serverDidFinishPunchPromise;
    __block KSPromise *punchesWithServerDidFinishPunchPromise;
    __block KSDeferred *punchesWithServerDidFinishPunchDeferred;
    __block id<Theme> theme;
    __block id<UserSession> userSession;
    __block id<BSBinder, BSInjector> injector;
    __block NSUserDefaults *userDefaults;
    __block TimesheetButtonController *timesheetButtonController;
    __block TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
    __block TimesheetDetailsSeriesController *timesheetDetailsSeriesController;
    __block WorkHoursStorage *workHoursStorage;
    __block id <WorkHours> placeHolderWorkHours;
    __block WidgetTimesheetDetailsSeriesController *newTimesheetDetailsSeriesController;

    beforeEach(^{
        placeHolderWorkHours = nice_fake_for(@protocol(WorkHours));
        workHoursStorage = nice_fake_for([WorkHoursStorage class]);
        workHoursStorage stub_method(@selector(getCombinedWorkHoursSummary)).and_return(placeHolderWorkHours);
        timesheetButtonController = nice_fake_for([TimesheetButtonController class]);
        timesheetButtonControllerPresenter = nice_fake_for([TimesheetButtonControllerPresenter class]);
        timesheetButtonControllerPresenter stub_method(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:));

        timesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
    });

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        userDefaults stub_method(@selector(objectForKey:))
        .with(@"totalViolationMessagesCount")
        .and_return(@1);

        dayTimeSummaryController = (id)[[UIViewController alloc] init];

        todaysDateControllerProvider = nice_fake_for([TodaysDateControllerProvider class]);

        dateProvider = nice_fake_for([DateProvider class]);
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        violationRepository = nice_fake_for([ViolationRepository class]);
        dayTimeSummaryControllerProvider = nice_fake_for([DayTimeSummaryControllerProvider class]);
        serverDidFinishPunchPromise = nice_fake_for([KSPromise class]);
        
        punchesWithServerDidFinishPunchDeferred =  [KSDeferred defer];
        punchesWithServerDidFinishPunchPromise = punchesWithServerDidFinishPunchDeferred.promise;
        
        delegate = nice_fake_for(@protocol(PunchInControllerDelegate));
        theme = nice_fake_for(@protocol(Theme));
        newTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];


        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        [injector bind:[WidgetTimesheetDetailsSeriesController class] toInstance:newTimesheetDetailsSeriesController];
        [injector bind:[TimesheetButtonControllerPresenter class] toInstance:timesheetButtonControllerPresenter];
        [injector bind:[TimesheetDetailsSeriesController class] toInstance:timesheetDetailsSeriesController];
        [injector bind:[TodaysDateControllerProvider class] toInstance:todaysDateControllerProvider];
        [injector bind:[DayTimeSummaryControllerProvider class] toInstance:dayTimeSummaryControllerProvider];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:[ViolationRepository class] toInstance:violationRepository];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[WorkHoursStorage class] toInstance:workHoursStorage];


        subject = [injector getInstance:[PunchInController class]];
        [subject setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                             delegate:delegate
                                       punchesPromise:punchesWithServerDidFinishPunchPromise];
    });

    describe(@"should call viewWillAppear", ^{
        beforeEach(^{
            [subject viewWillAppear:YES];
        });
        
        it(@"should style the button", ^{
            subject.punchInButton.cornerRadius should equal((subject.punchInButton.frame.size.width)/2);
        });
    });
    
    describe(@"punching in", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject.punchInButton tap];
        });

        it(@"should tell its delegate that the user punched in", ^{
            delegate should have_received(@selector(punchInControllerDidPunchIn:)).with(subject);
        });
    });

    describe(@"presenting today's date", ^{
        __block UIViewController *todaysDateController;
        beforeEach(^{
            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor magentaColor]);
            todaysDateController = [[UIViewController alloc] init];
            todaysDateControllerProvider stub_method(@selector(provideInstance)).and_return(todaysDateController);
            [subject view];
        });

        it(@"should present today's date controller", ^{
//            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
//                .with(todaysDateController, subject, subject.todaysDateContainerView);
        });

        it(@"should style the background appropriately", ^{
//            subject.todaysDateContainerView.backgroundColor should equal([UIColor magentaColor]);
        });
    });

    describe(@"presenting violations button controller", ^{
        __block ViolationsButtonController *violationsButtonController;

        beforeEach(^{
            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor magentaColor]);
            violationsButtonController = [[ViolationsButtonController alloc] initWithButtonStylist:nil
                                                                                             theme:nil];
            spy_on(violationsButtonController);
            [injector bind:[ViolationsButtonController class] toInstance:violationsButtonController];
            [subject view];
        });

        it(@"should present violations button controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(violationsButtonController, subject, subject.violationsButtonContainerView);
        });

        it(@"should setup controller", ^{
            violationsButtonController should have_received(@selector(setupWithDelegate:showViolations:))
            .with(subject, true);
        });

        it(@"should style the background appropriately", ^{
            subject.violationsButtonContainerView.backgroundColor should equal([UIColor magentaColor]);
        });

        it(@"should make itself the ViolationsButtonController's delegate", ^{
            violationsButtonController.delegate should be_same_instance_as(subject);
        });
    });

    describe(@"presenting the work hours summary for the current day", ^{
        __block UIViewController *dayTimeSummaryController;
        beforeEach(^{
            dayTimeSummaryController = [[UIViewController alloc] init];
            dayTimeSummaryControllerProvider stub_method(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:)).with(serverDidFinishPunchPromise,placeHolderWorkHours,subject).and_return(dayTimeSummaryController);
            [subject view];

        });

        it(@"should get the placeholder work hours intially when the view loads", ^{
            workHoursStorage should have_received(@selector(getCombinedWorkHoursSummary));
        });

        it(@"should present a work hours summary controller", ^{
            dayTimeSummaryControllerProvider should have_received(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:))
            .with(serverDidFinishPunchPromise,placeHolderWorkHours,subject);

        });

        it(@"should present a work hours summary controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
        });
    });

    describe(@"presenting the time line for the current day", ^{
        
        context(@"When punchPromise is succeed", ^{
            __block TimesheetDayTimeLineController *timeLineController;
            __block RemotePunch *remotePunchA;
            __block RemotePunch *remotePunchB;
            __block NSDate *expectedDate;
            beforeEach(^{
                remotePunchA = nice_fake_for([RemotePunch class]);
                remotePunchB = nice_fake_for([RemotePunch class]);
                
                TimeLinePunchesSummary * timelTimeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:nil timeLinePunches:@[remotePunchA, remotePunchB] allPunches:nil];
                
                [punchesWithServerDidFinishPunchDeferred resolveWithValue:timelTimeLinePunchesSummary];
                
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];
                
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(nil,serverDidFinishPunchPromise, subject, @"user-uri",UserFlowContext,@[remotePunchA, remotePunchB],CardTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineCardContainerView);
            });
        });
        
        context(@"When punchPromise rejected", ^{
            __block TimesheetDayTimeLineController *timeLineController;
            __block NSDate *expectedDate;
            beforeEach(^{
                
                [punchesWithServerDidFinishPunchDeferred rejectWithError:nil];
                
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];
                
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(nil,serverDidFinishPunchPromise, subject, @"user-uri",UserFlowContext,nil,CardTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineCardContainerView);
            });
        });
        
        context(@"When punchPromise is nil", ^{
            __block TimesheetDayTimeLineController *timeLineController;
            __block NSDate *expectedDate;
            beforeEach(^{
                
                [punchesWithServerDidFinishPunchDeferred rejectWithError:nil];
                
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];
                
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(nil,serverDidFinishPunchPromise, subject, @"user-uri",UserFlowContext,nil,CardTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineCardContainerView);
            });
        });
    });

    describe(@"presenting the current timesheet period button controller", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should present the current timesheet period button controller", ^{
            timesheetButtonControllerPresenter should have_received(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:))
                .with(subject.timesheetButtonContainerView, subject, subject);
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
            __block NSDate *expectedDate;
            beforeEach(^{
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                returnedDate = [subject timesheetDayTimeLineControllerDidRequestDate:(id)[NSNull null]];
            });

            it(@"should return the correct date", ^{
                returnedDate should be_same_instance_as(expectedDate);
            });
        });
    });

    describe(@"as a <ViolationsButtonControllerDelegate>", ^{
        describe(@"violationsButtonHeightConstraint", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });

            it(@"should have a container with the violationsButtonHeightConstraint", ^{
                subject.violationsButtonContainerView.constraints should contain(subject.violationsButtonHeightConstraint);
            });
        });

        describe(@"violationsButtonController:didSignalIntentToViewViolationSections:", ^{
            __block UINavigationController *navigationController;
            __block AllViolationSections *expectedAllViolationSections;
            __block ViolationsSummaryController *violationsSummaryController;
            __block ViolationsSummaryController *expectedViolationsSummaryController;

            beforeEach(^{
                [subject view];

                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];

                expectedViolationsSummaryController = [[ViolationsSummaryController alloc] initWithSupervisorDashboardSummaryRepository:nil
                                                                                                        violationSectionHeaderPresenter:nil
                                                                                                          selectedWaiverOptionPresenter:nil
                                                                                                             violationSeverityPresenter:nil
                                                                                                                       teamTableStylist:nil
                                                                                                                        spinnerDelegate:nil
                                                                                                                                  theme:nil];

                [injector bind:[ViolationsSummaryController class] toInstance:expectedViolationsSummaryController];

                expectedAllViolationSections = fake_for([AllViolationSections class]);

                [subject violationsButtonController:nil didSignalIntentToViewViolationSections:expectedAllViolationSections];

                violationsSummaryController = (id)navigationController.topViewController;
            });

            it(@"should push a violations summary controller onto the navigation stack", ^{
                violationsSummaryController should be_same_instance_as(expectedViolationsSummaryController);
            });

            it(@"should set the violations controller up correctly", ^{
                violationsSummaryController.violationSectionsPromise.value should be_same_instance_as(expectedAllViolationSections);
            });

            it(@"should set the violations controller up correctly", ^{
                violationsSummaryController.delegate should be_same_instance_as(subject);
            });
        });

        describe(@"violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSPromise *expectedViolationsPromise;
            beforeEach(^{
                [subject view];

                expectedViolationsPromise = nice_fake_for([KSPromise class]);
                violationRepository stub_method(@selector(fetchAllViolationSectionsForToday))
                    .and_return(expectedViolationsPromise);

                violationsPromise = [subject violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:nil];
            });

            it(@"should make a request for todays violations", ^{
                violationsPromise should be_same_instance_as(expectedViolationsPromise);
            });
        });
    });

    describe(@"as a <ViolationsSummaryControllerDelegate>", ^{
        describe(@"violationsSummaryControllerDidRequestViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSPromise *expectedViolationSectionsPromise;
            beforeEach(^{
                [subject view];

                expectedViolationSectionsPromise = nice_fake_for([KSPromise class]);
                violationRepository stub_method(@selector(fetchAllViolationSectionsForToday))
                    .and_return(expectedViolationSectionsPromise);

                violationsPromise = [subject violationsSummaryControllerDidRequestViolationSectionsPromise:nil];
            });

            it(@"should make a request for todays violations", ^{
                violationsPromise should be_same_instance_as(expectedViolationSectionsPromise);
            });
        });
    });

    describe(@"as a <TimesheetButtonControllerDelegate>", ^{
        describe(@"timesheetButtonControllerWillNavigateToTimesheetDetailScreen:", ^{
            __block UINavigationController *navigationController;

            beforeEach(^{
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);

                [subject view];
                [subject timesheetButtonControllerWillNavigateToTimesheetDetailScreen:nil];
            });

            it(@"should show a TimesheetDetailsSeriesController", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(timesheetDetailsSeriesController, YES);
            });
        });
        
        describe(@"timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:", ^{
            __block UINavigationController *navigationController;
            
            beforeEach(^{
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);
                
                [subject view];
                [subject timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:nil];
            });
            
            it(@"should show a TimesheetDetailsSeriesController", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(newTimesheetDetailsSeriesController, YES);
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(punchInColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(punchInButtonBorderColor)).and_return([[UIColor redColor] CGColor]);
            theme stub_method(@selector(punchInButtonBorderWidth)).and_return((CGFloat)13.0f);
            theme stub_method(@selector(punchInButtonTitleFont)).and_return([UIFont systemFontOfSize:14.0f]);
            theme stub_method(@selector(punchInButtonTitleColor)).and_return([UIColor blueColor]);
            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor magentaColor]);

            [subject view];
        });

        it(@"should style the views", ^{
            subject.punchInButton.backgroundColor should equal([UIColor orangeColor]);
            subject.punchInButton.layer.borderColor should equal([[UIColor redColor] CGColor]);
            subject.punchInButton.layer.borderWidth should equal(13.0f);
            subject.punchInButton.titleLabel.font should equal([UIFont systemFontOfSize:14.0f]);
            subject.punchInButton.titleLabel.textColor should equal([UIColor blueColor]);
            subject.workHoursContainerView.backgroundColor should equal([UIColor magentaColor]);
        });
    });

    describe(@"the view hierarchy", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should add scroll view as the subview of the view", ^{
            [[subject.view subviews] count] should equal(1);
            [[subject.view subviews] firstObject] should be_same_instance_as(subject.scrollView);
        });

        describe(@"the scrollview's container view", ^{
            __block UIView *containerView;
            beforeEach(^{
                containerView = subject.containerView;
            });

            it(@"should live inside the scroll view", ^{
                subject.scrollView.subviews should contain(containerView);
            });

            it(@"should contain the punch in button", ^{
                containerView.subviews should contain(subject.punchInButton);
            });

            it(@"should contain the timeline container card", ^{
                containerView.subviews should contain(subject.timeLineCardContainerView);
            });

            it(@"should contain the timesheet button", ^{
                containerView.subviews should contain(subject.timesheetButtonContainerView);
            });
        });
    });

    describe(@"as a <WorkHoursUpdateDelegate>", ^{
        __block id <WorkHours> workHours;
        beforeEach(^{
            workHours = nice_fake_for(@protocol(WorkHours));
            subject.view should_not be_nil;
            [subject dayTimeSummaryController:nil didUpdateWorkHours:workHours];
        });

        it(@"should store the workHours in the WorkHoursStorage", ^{
            workHoursStorage should have_received(@selector(saveWorkHoursSummary:)).with(workHours);
        });

    });
});

SPEC_END
