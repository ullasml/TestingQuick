#import <Cedar/Cedar.h>
#import "OnBreakController.h"
#import "Theme.h"
#import "UIControl+Spec.h"
#import "ButtonStylist.h"
#import "LastPunchLabelTextPresenter.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "DateProvider.h"
#import "TimerProvider.h"
#import "AddressControllerPresenter.h"
#import "DurationStringPresenter.h"
#import "DurationCalculator.h"
#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetButtonController.h"
#import "TimesheetDetailsController.h"
#import "ChildControllerHelper.h"
#import <KSDeferred/KSDeferred.h>
#import "ChildControllerHelper.h"
#import "DayTimeSummaryControllerProvider.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "ViolationEmployee.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "UserPermissionsStorage.h"
#import "BreakTypeRepository.h"
#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "WorkHoursStorage.h"
#import "TimesheetDayTimeLineController.h"
#import "TimeLinePunchesSummary.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(OnBreakControllerSpec)

describe(@"OnBreakController", ^{
    __block OnBreakController <CedarDouble> *subject;
    __block id<Theme> theme;
    __block ButtonStylist *buttonStylist;
    __block LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
    __block id<OnBreakControllerDelegate> delegate;
    __block LocalPunch *punch;
    __block BreakType *breakType;
    __block NSDate *punchDate;
    __block DateProvider *dateProvider;
    __block TimerProvider *timerProvider;
    __block AddressControllerPresenter *addressControllerPresenter;

    __block ChildControllerHelper *childControllerHelper;
    __block DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
    __block KSDeferred *serverDidFinishPunchDeferred;
    __block KSDeferred *punchesWithServerDidFinishPunchDeferred;
    __block id<UserSession> userSession;
    __block WorkHoursStorage *workHoursStorage;
    __block id <WorkHours> placeHolderWorkHours;
    __block NSUserDefaults *userDefaults;

    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];

        userDefaults stub_method(@selector(objectForKey:))
        .with(@"totalViolationMessagesCount")
        .and_return(@1);

        placeHolderWorkHours = nice_fake_for(@protocol(WorkHours));
        workHoursStorage = nice_fake_for([WorkHoursStorage class]);
        workHoursStorage stub_method(@selector(getWorkHoursSummary)).and_return(placeHolderWorkHours);

        punchDate = nice_fake_for([NSDate class]);
        breakType = [[BreakType alloc] initWithName:@"Meal" uri:@"meal"];
        dateProvider = nice_fake_for([DateProvider class]);
        timerProvider = nice_fake_for([TimerProvider class]);

        punch = nice_fake_for([LocalPunch class]);
        punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
        punch stub_method(@selector(breakType)).and_return(breakType);

        addressControllerPresenter = nice_fake_for([AddressControllerPresenter class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");

        theme = nice_fake_for(@protocol(Theme));
        buttonStylist = nice_fake_for([ButtonStylist class]);
        lastPunchLabelTextPresenter = nice_fake_for([LastPunchLabelTextPresenter class]);
        delegate = nice_fake_for(@protocol(OnBreakControllerDelegate));
    });

    __block TimesheetButtonController *timesheetButtonController;
    __block TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
    __block TimesheetDetailsSeriesController *timesheetDetailsSeriesController;
    beforeEach(^{
        timesheetButtonController = nice_fake_for([TimesheetButtonController class]);
        timesheetButtonControllerPresenter = nice_fake_for([TimesheetButtonControllerPresenter class]);
        timesheetButtonControllerPresenter stub_method(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:));

        timesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
    });

    __block ViolationRepository *violationRepository;
    beforeEach(^{
        violationRepository = nice_fake_for([ViolationRepository class]);

        [injector bind:[ViolationRepository class] toInstance:violationRepository];
    });

    __block UIViewController *dayTimeSummaryController;
    beforeEach(^{

        serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
        punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        dayTimeSummaryControllerProvider = nice_fake_for([DayTimeSummaryControllerProvider class]);

        dayTimeSummaryController = [[DayTimeSummaryController alloc] initWithWorkHoursPresenterProvider:nil theme:nil todaysDateControllerProvider:nil childControllerHelper:nil];
        spy_on(dayTimeSummaryController);


    });

    __block DurationCalculator *durationCalculator;
    __block DurationStringPresenter *durationStringPresenter;
    __block WidgetTimesheetDetailsSeriesController *newTimesheetDetailsSeriesController;

    beforeEach(^{
        durationStringPresenter = nice_fake_for([DurationStringPresenter class]);
        durationCalculator = nice_fake_for([DurationCalculator class]);
        newTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
    });

    beforeEach(^{

        [injector bind:[TimesheetButtonControllerPresenter class] toInstance:timesheetButtonControllerPresenter];
        [injector bind:[TimesheetDetailsSeriesController class] toInstance:timesheetDetailsSeriesController];
        [injector bind:[WidgetTimesheetDetailsSeriesController class] toInstance:newTimesheetDetailsSeriesController];
        [injector bind:[TimesheetDetailsSeriesController class] toInstance:timesheetDetailsSeriesController];
        [injector bind:[LastPunchLabelTextPresenter class] toInstance:lastPunchLabelTextPresenter];
        [injector bind:[DayTimeSummaryControllerProvider class] toInstance:dayTimeSummaryControllerProvider];
        [injector bind:[DurationStringPresenter class] toInstance:durationStringPresenter];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:[DurationCalculator class] toInstance:durationCalculator];
        [injector bind:[ButtonStylist class] toInstance:buttonStylist];
        [injector bind:[TimerProvider class] toInstance:timerProvider];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[WorkHoursStorage class] toInstance:workHoursStorage];

        subject = [injector getInstance:[OnBreakController class]];

        dayTimeSummaryControllerProvider stub_method(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:))
        .with(serverDidFinishPunchDeferred.promise,placeHolderWorkHours,subject)
        .and_return(dayTimeSummaryController);

        [subject setupWithAddressControllerPresenter:addressControllerPresenter
                         serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                            delegate:delegate
                                               punch:punch
                                      punchesPromise:punchesWithServerDidFinishPunchDeferred.promise];

        spy_on(subject);

    });

    describe(@"punching out", ^{
        beforeEach(^{
            [subject view];
            [subject.punchOutButton tap];
        });

        it(@"should notify its delegate", ^{
            delegate should have_received(@selector(controllerDidPunchOut:)).with(subject);
        });
    });

    describe(@"resuming work", ^{
        beforeEach(^{
            [subject view];
            [subject.resumeWorkButton tap];
        });

        it(@"should notify its delegate", ^{
            delegate should have_received(@selector(onBreakControllerDidResumeWork:)).with(subject);
        });
    });


    describe(@"presenting punchDurationTimerLabel", ^{
        beforeEach(^{
            theme stub_method(@selector(timesheetBreakHoursNewBigFontColor)).and_return([UIColor yellowColor]);
            [subject view];
        });

        it(@"should style the background appropriately", ^{
            subject.punchDurationTimerLabel.backgroundColor should equal([UIColor yellowColor]);
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

                expectedAllViolationSections = nice_fake_for([AllViolationSections class]);
                [subject violationsButtonController:nil
             didSignalIntentToViewViolationSections:expectedAllViolationSections];

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

    describe(@"presenting the work hours summary for the current day", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should get the placeholder work hours intially when the view loads", ^{
            workHoursStorage should have_received(@selector(getWorkHoursSummary));
        });

        it(@"should present a work hours summary controller", ^{
            dayTimeSummaryControllerProvider should have_received(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:))
            .with(serverDidFinishPunchDeferred.promise,placeHolderWorkHours,subject);
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
                .with(nil,serverDidFinishPunchDeferred.promise, subject, @"user-uri",UserFlowContext,@[remotePunchA, remotePunchB],CardTimeLinePunchFlowContext);
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
                .with(nil,serverDidFinishPunchDeferred.promise, subject, @"user-uri",UserFlowContext,nil,CardTimeLinePunchFlowContext);
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
                .with(nil,serverDidFinishPunchDeferred.promise, subject, @"user-uri",UserFlowContext,nil,CardTimeLinePunchFlowContext);
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

    describe(@"present the address that the break started at", ^{
        __block UIColor *backgroundColor;
        beforeEach(^{
            backgroundColor = [UIColor greenColor];
            theme stub_method(@selector(onBreakClockOutButtonBackgroundColor)).and_return([UIColor greenColor]);
            punch stub_method(@selector(address)).and_return(@"my address");
            [subject view];
        });

        it(@"should present an address controller", ^{
            addressControllerPresenter should have_received(@selector(presentAddress:ifNeededInAddressLabelContainer:onParentController:backgroundColor:))
                .with(@"my address", subject.addressLabelContainer, subject, nil);
        });
    });

    describe(@"showing when the break started", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should show the initial punch date", ^{
            subject.breakStartedLabel.text should equal(@"Meal");
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

    describe(@"updating the punch duration timer label periodically", ^{

        describe(@"the punch duration timer", ^{
            
            context(@"when navigationcontroller associated with current Controller", ^{
                __block NSDate *punchDate;
                beforeEach(^{
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    subject stub_method(@selector(navigationController)).and_return(navigationController);
                    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                    dateComponents.hour = 1;
                    dateComponents.minute = 2;
                    dateComponents.second = 3;
                    punchDate = [NSDate dateWithTimeIntervalSince1970:1427305050];
                    punch stub_method(@selector(date)).and_return(punchDate);
                    
                    durationCalculator stub_method(@selector(timeSinceStartDate:))
                    .with(punchDate)
                    .and_return(dateComponents);
                    
                    durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:seconds:))
                    .with(1, 2, 3)
                    .and_return([[NSAttributedString alloc] initWithString:@"A very special duration"]);
                    
                    [subject view];
                    [subject viewWillAppear:NO];
                });
                
                it(@"should initially set the punch duration timer label as the duration since the most recent punch time", ^{
                    subject.punchDurationTimerLabel.text should equal(@"A very special duration");
                });
                
                it(@"should set up a timer that runs every second", ^{
                    [(id<CedarDouble>)timerProvider sent_messages].count should equal(1);
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(1.0, subject, @selector(updatePunchDurationLabel), @{}, YES);
                });
                
                
                describe(@"when the timer fires", ^{
                    __block NSDate *updatedDate;
                    __block NSDateComponents *dateComponents;
                    beforeEach(^{
                        updatedDate = [NSDate dateWithTimeIntervalSince1970:1427305057];
                        punch stub_method(@selector(date)).again().and_return(updatedDate);
                        
                        dateComponents = [[NSDateComponents alloc] init];
                        dateComponents.hour = 4;
                        dateComponents.minute = 5;
                        dateComponents.second = 6;
                        
                        durationCalculator stub_method(@selector(timeSinceStartDate:))
                        .with(updatedDate)
                        .and_return(dateComponents);
                        
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:seconds:))
                        .with(4, 5, 6)
                        .and_return([[NSAttributedString alloc] initWithString:@"An updated special duration"]);
                        
                        [subject updatePunchDurationLabel];
                    });
                    
                    it(@"should update the time displayed in the label", ^{
                        subject.punchDurationTimerLabel.text should equal(@"An updated special duration");
                    });
                    
                    it(@"should update the total break hours", ^{
                        dayTimeSummaryController should have_received(@selector(updateBreakHoursLabelWithOffset:)).with(dateComponents);
                    });
                });
            });
            
            context(@"when navigationcontroller is not associated with current Controller", ^{
                context(@"the punch duration timer", ^{
                    beforeEach(^{
                        subject stub_method(@selector(navigationController)).and_return(nil);
                    });
                    
                    describe(@"when the timer fires", ^{
                        __block NSDateComponents *updatedDateComponents;
                        
                        beforeEach(^{
                            [subject updatePunchDurationLabel];
                        });
                        
                        it(@"should not update the work and break hours", ^{
                            dayTimeSummaryController should_not have_received(@selector(updateRegularHoursLabelWithOffset:))
                            .with(updatedDateComponents);
                        });
                        
                        it(@"should set timer to nil", ^{
                            subject.timer  should be_nil;
                        });
                    });
                });
                
            });
        });
    });

    describe(@"styling the view", ^{
        beforeEach(^{
            theme stub_method(@selector(resumeWorkButtonTitleColor)).and_return([UIColor whiteColor]);
            theme stub_method(@selector(resumeWorkButtonBackgroundColor)).and_return([UIColor orangeColor]);

            theme stub_method(@selector(transparentColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(onBreakBackgroundColor)).and_return([UIColor purpleColor]);
            theme stub_method(@selector(onBreakClockOutButtonTitleColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(onBreakClockOutButtonBackgroundColor)).and_return([UIColor yellowColor]);

            theme stub_method(@selector(breakLabelColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(breakLabelFont)).and_return([UIFont systemFontOfSize:19.0f]);

            theme stub_method(@selector(punchedSinceLabelTextColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(punchedSinceLabelFont)).and_return([UIFont systemFontOfSize:10.0f]);

            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor blackColor]);

            [subject view];
        });

        it(@"should style the views", ^{
            subject.containerView.backgroundColor should equal([UIColor purpleColor]);
            subject.breakStartedLabel.textColor should equal([UIColor yellowColor]);
            subject.breakStartedLabel.font should equal([UIFont systemFontOfSize:19.0f]);
        });

        it(@"should style the punch out button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.punchOutButton, @"Clock Out", [UIColor greenColor], [UIColor yellowColor], nil);
        });

        it(@"should style the resume work button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.resumeWorkButton, @"Resume Work", [UIColor whiteColor], [UIColor orangeColor], nil);
        });

        it(@"should style the work hours container", ^{
            subject.workHoursContainerView.backgroundColor should equal([UIColor blackColor]);
        });
        
        it(@"should have correct height work hours container", ^{
            subject.workHoursContainerHeight.constant should equal(CGFloat(109.0f));
        });
    });

    describe(@"Invalidating the timer", ^{
        __block NSTimer *timer;
        beforeEach(^{
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:subject
                                                   selector:@selector(updatePunchDurationLabel)
                                                   userInfo:@{}
                                                    repeats:YES];
            timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                :repeats:)).and_return(timer);
            [subject view];
            [subject viewWillAppear:YES];

        });

        it(@"should invalidate the timer when the view disappears", ^{
            [subject viewDidDisappear:YES];
            subject.timer.isValid should be_falsy;
            subject.timer should be_nil;
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

        it(@"should add the button to the scrollview's container view", ^{
            subject.scrollView.subviews should contain(subject.containerView);
            subject.containerView.subviews should contain(subject.resumeWorkButton);
            subject.containerView.subviews should contain(subject.punchOutButton);
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
