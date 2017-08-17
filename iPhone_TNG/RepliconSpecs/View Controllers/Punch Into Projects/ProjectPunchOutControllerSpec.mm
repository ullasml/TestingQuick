#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "ProjectPunchOutController.h"
#import <KSDeferred/KSDeferred.h>
#import "LocalPunch.h"
#import "TimerProvider.h"
#import "DateProvider.h"
#import "Theme.h"
#import "DayTimeSummaryController.h"
#import "UIControl+Spec.h"
#import "BreakTypeRepository.h"
#import "BreakType.h"
#import "UIActionSheet+Spec.h"
#import "AddressControllerPresenter.h"
#import "AddressController.h"
#import "ButtonStylist.h"
#import "DurationStringPresenter.h"
#import "DurationCalculator.h"
#import "UserPermissionsStorage.h"
#import "LastPunchLabelTextPresenter.h"
#import "TimesheetButtonController.h"
#import "TimesheetButtonControllerPresenter.h"

#import "ChildControllerHelper.h"
#import "DayTimeSummaryControllerProvider.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "ViolationEmployee.h"
#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "UIAlertView+Spec.h"
#import "WorkHoursStorage.h"
#import "PunchPresenter.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ClientType.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "OEFTypeStorage.h"
#import "TimesheetDayTimeLineController.h"
#import "TimeLinePunchesSummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ProjectPunchOutControllerSpec)

describe(@"ProjectPunchOutController", ^{
    __block ProjectPunchOutController <CedarDouble> *subject;
    __block id<ProjectPunchOutControllerDelegate> delegate;
    __block LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
    __block KSDeferred *punchInDeferred;
    __block LocalPunch *updatedPunchIn;
    __block TimerProvider *timerProvider;
    __block DateProvider *dateProvider;
    __block UserPermissionsStorage *punchRulesStorage;
    __block ButtonStylist *buttonStylist;
    __block LocalPunch *punch;
    __block BreakTypeRepository *breakTypeRepository;
    __block KSDeferred *serverDidFinishPunchDeferred;
    __block KSDeferred *punchesWithServerDidFinishPunchDeferred;
    __block KSDeferred *breakTypeDeferred;
    __block id<Theme> theme;
    __block AddressControllerPresenter *addressControllerPresenter;
    __block DurationStringPresenter *durationStringPresenter;
    __block DurationCalculator *durationCalculator;
    __block WidgetTimesheetDetailsSeriesController *newTimesheetDetailsSeriesController;
    __block ChildControllerHelper *childControllerHelper;
    __block DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
    __block id<UserSession> userSession;
    __block WorkHoursStorage *workHoursStorage;
    __block id <WorkHours> placeHolderWorkHours;
    __block PunchPresenter *punchPresenter;
    __block OEFTypeStorage *oefTypeStorage;
    __block NSUserDefaults *userDefaults;
    
    NSDate *updatedPunchInTime = [NSDate dateWithTimeIntervalSince1970:1427305050];


    __block UIViewController *dayTimeSummaryController;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        userDefaults stub_method(@selector(objectForKey:))
        .with(@"totalViolationMessagesCount")
        .and_return(@1);

        punchPresenter = nice_fake_for([PunchPresenter class]);
        placeHolderWorkHours = nice_fake_for(@protocol(WorkHours));
        workHoursStorage = nice_fake_for([WorkHoursStorage class]);
        workHoursStorage stub_method(@selector(getCombinedWorkHoursSummary)).and_return(placeHolderWorkHours);

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        dayTimeSummaryControllerProvider = nice_fake_for([DayTimeSummaryControllerProvider class]);

        dayTimeSummaryController = [[DayTimeSummaryController alloc] initWithWorkHoursPresenterProvider:nil theme:nil todaysDateControllerProvider:nil childControllerHelper:nil];
        spy_on(dayTimeSummaryController);
    });

    __block ViolationRepository *violationRepository;
    beforeEach(^{
        violationRepository = nice_fake_for([ViolationRepository class]);

        [injector bind:[ViolationRepository class] toInstance:violationRepository];
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

    beforeEach(^{
        buttonStylist = nice_fake_for([ButtonStylist class]);
        addressControllerPresenter = nice_fake_for([AddressControllerPresenter class]);
        breakTypeDeferred = [[KSDeferred alloc] init];
        punch = nice_fake_for([LocalPunch class]);
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        updatedPunchIn = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:@"Updated address" userURI:nil image:nil task:nil date:updatedPunchInTime];

        breakTypeRepository = nice_fake_for([BreakTypeRepository class]);
        breakTypeRepository stub_method(@selector(fetchBreakTypesForUser:)).and_return(breakTypeDeferred.promise);

        punchInDeferred = [[KSDeferred alloc] init];
        lastPunchLabelTextPresenter = nice_fake_for([LastPunchLabelTextPresenter class]);

        timerProvider = nice_fake_for([TimerProvider class]);
        dateProvider = nice_fake_for([DateProvider class]);
        theme = nice_fake_for(@protocol(Theme));

        durationStringPresenter = nice_fake_for([DurationStringPresenter class]);
        durationCalculator = nice_fake_for([DurationCalculator class]);

        delegate = nice_fake_for(@protocol(ProjectPunchOutControllerDelegate));
        serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
        punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");

        oefTypeStorage = nice_fake_for([OEFTypeStorage class]);
        newTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];


        [injector bind:[PunchPresenter class] toInstance:punchPresenter];
        [injector bind:[TimesheetButtonControllerPresenter class] toInstance:timesheetButtonControllerPresenter];
        [injector bind:[TimesheetDetailsSeriesController class] toInstance:timesheetDetailsSeriesController];
        [injector bind:[WidgetTimesheetDetailsSeriesController class] toInstance:newTimesheetDetailsSeriesController];
        [injector bind:[DayTimeSummaryControllerProvider class] toInstance:dayTimeSummaryControllerProvider];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[LastPunchLabelTextPresenter class] toInstance:lastPunchLabelTextPresenter];
        [injector bind:[DurationStringPresenter class] toInstance:durationStringPresenter];
        [injector bind:[BreakTypeRepository class] toInstance:breakTypeRepository];
        [injector bind:[DurationCalculator class] toInstance:durationCalculator];
        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];
        [injector bind:[ButtonStylist class] toInstance:buttonStylist];
        [injector bind:[TimerProvider class] toInstance:timerProvider];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[WorkHoursStorage class] toInstance:workHoursStorage];
        [injector bind:[OEFTypeStorage class] toInstance:oefTypeStorage];

        subject = [injector getInstance:[ProjectPunchOutController class]];

        dayTimeSummaryControllerProvider stub_method(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:)).with(serverDidFinishPunchDeferred.promise,placeHolderWorkHours,subject).and_return(dayTimeSummaryController);

        [subject setupWithAddressControllerPresenter:addressControllerPresenter
                         serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                            delegate:delegate
                                               punch:punch
                                      punchesPromise:punchesWithServerDidFinishPunchDeferred.promise];


        spy_on(subject);
    });

    describe(@"should show the punch attributes properly", ^{
        __block NSAttributedString *expectedAttributedString ;
        beforeEach(^{
            theme stub_method(@selector(punchAttributeRegularFont)).and_return([UIFont systemFontOfSize:2]);
            theme stub_method(@selector(punchAttributeLightFont)).and_return([UIFont systemFontOfSize:1]);
            theme stub_method(@selector(punchAttributeLabelColor)).and_return([UIColor magentaColor]);

            expectedAttributedString = [[NSAttributedString alloc]initWithString:@"Description Label text 2"];

            [subject setupWithAddressControllerPresenter:addressControllerPresenter
                             serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                delegate:delegate
                                                   punch:punch
                                          punchesPromise:nil];

            punchPresenter stub_method(@selector(descriptionLabelForTimelineCellTextWithPunch:regularFont:lightFont:textColor:forWidth:)).with(punch,[UIFont systemFontOfSize:2],[UIFont systemFontOfSize:1],[UIColor magentaColor],Arguments::anything).and_return(expectedAttributedString);

            [subject view];

        });

        it(@"should present correct text in the punch attributes label", ^{
            [subject.punchAttributesLabel.attributedText isEqualToAttributedString:expectedAttributedString] should be_truthy;
        });
    });

    describe(@"punching out", ^{
        beforeEach(^{
            [subject view];
            [subject.punchOutButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should tell its delegate that the user punched out", ^{
            delegate should have_received(@selector(controllerDidPunchOut:)).with(subject);
        });
    });
    
    describe(@"transfer", ^{
        beforeEach(^{
            [subject view];
            [subject.transferButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });
        
        it(@"should tell its delegate that the user punched out", ^{
            delegate should have_received(@selector(projectPunchOutControllerDidTransfer:)).with(subject);
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
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should get the placeholder work hours intially when the view loads", ^{
            workHoursStorage should have_received(@selector(getCombinedWorkHoursSummary));
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
            __block KSPromise *expectedViolationSectionsPromise;
            beforeEach(^{
                [subject view];

                expectedViolationSectionsPromise = nice_fake_for([KSPromise class]);
                violationRepository stub_method(@selector(fetchAllViolationSectionsForToday))
                .and_return(expectedViolationSectionsPromise);

                violationsPromise = [subject violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:nil];
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

    describe(@"when the view loads", ^{
        context(@"when location is not required", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                subject.view should_not be_nil;
            });

            it(@"should have the correct subviews wired", ^{
                UIView *scrollView = subject.view.subviews.firstObject;
                UIView *scrollViewContentView = scrollView.subviews.firstObject;

                scrollViewContentView.subviews should contain(subject.cardContainerView);
                subject.cardContainerView.subviews should contain(subject.punchOutButton);
                subject.cardContainerView.subviews should contain(subject.punchDurationTimerLabel);
                subject.cardContainerView.subviews should contain(subject.transferButton);
            });
        });

        context(@"when an address controller is present", ^{
            __block AddressController *addressController;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                addressController = [[AddressController alloc] initWithLocalPunchPromise:nil
                                                                         backgroundColor:nil
                                                                                 address:@"initial address"
                                                                                   theme:nil];
                addressControllerPresenter stub_method(@selector(presentAddress:ifNeededInAddressLabelContainer:onParentController:backgroundColor:))
                .and_return(addressController);
                punch stub_method(@selector(address)).and_return(@"initial address");

                subject.view should_not be_nil;
            });

            it(@"should have the correct subviews wired", ^{
                UIView *scrollView = subject.view.subviews.firstObject;
                UIView *scrollViewContentView = scrollView.subviews.firstObject;

                scrollViewContentView.subviews should contain(subject.cardContainerView);
                subject.cardContainerView.subviews should contain(subject.punchOutButton);
                subject.cardContainerView.subviews should contain(subject.punchDurationTimerLabel);
                subject.cardContainerView.subviews should contain(subject.addressLabelContainer);
                subject.cardContainerView.subviews should contain(subject.transferButton);
            });
        });
    });

    describe(@"taking a break", ^{
        context(@"when the user is required to log their breaks", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                [subject view];
            });

            it(@"should show the break button", ^{
                subject.breakButton.superview should_not be_nil;
            });
            
            context(@"when the user taps the take a break button without OEF enabled", ^{
                __block NSDate *tapDate;
                beforeEach(^{
                    tapDate = nice_fake_for([NSDate class]);
                    dateProvider stub_method(@selector(date)).and_return(tapDate);
                    [subject.breakButton tap];
                });

                it(@"should disable the take break button", ^{
                    subject.breakButton.enabled should be_falsy;
                });

                it(@"should get a list of break types from the break type repository", ^{
                    breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(@"user-uri");
                });

                context(@"when fetching the break type list succeeds", ^{
                    __block UIActionSheet *actionSheet;

                    beforeEach(^{
                        BreakType *feelingsBreak = [[BreakType alloc] initWithName:@"Talk About Feelings Break" uri:@"feelings"];
                        BreakType *smokeBreak = [[BreakType alloc] initWithName:@"Smoke Break" uri:@"smoke"];

                        [breakTypeDeferred resolveWithValue:@[feelingsBreak, smokeBreak]];

                        actionSheet = [UIActionSheet currentActionSheet];
                    });

                    it(@"should re-enable the break button", ^{
                        subject.breakButton.enabled should be_truthy;
                    });

                    it(@"should show the break list action sheet", ^{
                        [actionSheet buttonTitles] should equal(@[@"Cancel", @"Talk About Feelings Break", @"Smoke Break"]);
                    });

                    context(@"when the user taps on a break type", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingButtonWithTitle:@"Talk About Feelings Break"];
                        });

                        it(@"should tell its delegate that the user wants to take a break", ^{
                            BreakType *feelingsBreak = [[BreakType alloc] initWithName:@"Talk About Feelings Break" uri:@"feelings"];
                            delegate should have_received(@selector(projectPunchOutControllerDidTakeBreakWithDate:breakType:)).with(tapDate, feelingsBreak);
                        });
                    });

                    context(@"when the user cancels", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingCancelButton];
                        });

                        it(@"should re-enable the break button", ^{
                            subject.breakButton.enabled should be_truthy;
                        });
                    });
                });

                context(@"when fetching the break type list fails", ^{
                    __block NSError *error;
                    __block UIAlertView *alertView;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [breakTypeDeferred rejectWithError:error];
                        alertView = [UIAlertView currentAlertView];
                    });

                    it(@"should re-enable the break button", ^{
                        subject.breakButton.enabled should be_truthy;
                    });

                    it(@"should have the alertview for no breaks ", ^{
                        alertView should_not be_nil;
                        alertView.message should equal(RPLocalizedString(@"Replicon app was unable to retrieve the break type list.  Please try again later.", nil));
                    });
                });
            });
                
            context(@"when the user taps the take a break button with OEF enabled", ^{
                __block NSArray *oefTypesArray;
                beforeEach(^{
                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    oefTypesArray = @[oefType1,oefType2];
                    
                    oefTypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).with(PunchActionTypeStartBreak).and_return(oefTypesArray);
                    
                    [subject.breakButton tap];
                });
                
                it(@"should tell its delegate that the user wants to take a break", ^{
                    delegate should have_received(@selector(projectPunchOutControllerDidTakeBreak));
                });
            });
            
        });

        context(@"when the user is not required to log their breaks", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);
                [subject view];
            });

            it(@"should hide the break button", ^{
                subject.breakButton.superview should be_nil;
            });
        });
    });

    describe(@"present the address that the break started at", ^{
        beforeEach(^{
            theme stub_method(@selector(punchOutAddressLabelContainerBackgroundColor)).and_return([UIColor grayColor]);
            punch stub_method(@selector(address)).and_return(@"my address");
            [subject view];
        });

        it(@"should present an address controller", ^{
            addressControllerPresenter should have_received(@selector(presentAddress:ifNeededInAddressLabelContainer:onParentController:backgroundColor:))
            .with(@"my address", subject.addressLabelContainer, subject, [UIColor clearColor]);
        });
    });

    describe(@"updating the UI periodically", ^{
        
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
            
            describe(@"the punch duration timer", ^{
                
                describe(@"when the timer fires", ^{
                    __block NSDate *updatedDate;
                    __block NSDateComponents *updatedDateComponents;
                    
                    beforeEach(^{
                        updatedDate = [NSDate dateWithTimeIntervalSince1970:1427305057];
                        punch stub_method(@selector(date)).again().and_return(updatedDate);
                        
                        updatedDateComponents = [[NSDateComponents alloc] init];
                        updatedDateComponents.hour = 4;
                        updatedDateComponents.minute = 5;
                        updatedDateComponents.second = 6;
                        
                        durationCalculator stub_method(@selector(timeSinceStartDate:))
                        .with(updatedDate)
                        .and_return(updatedDateComponents);
                        durationStringPresenter stub_method(@selector(durationStringWithHours:minutes:seconds:))
                        .with(4, 5, 6)
                        .and_return([[NSAttributedString alloc] initWithString:@"An updated special duration"]);
                        
                        [subject updatePunchDurationLabel];
                    });
                    
                    it(@"should update the time displayed in the label", ^{
                        subject.punchDurationTimerLabel.text should equal(@"An updated special duration");
                    });
                    
                    it(@"should update the work and break hours", ^{
                        dayTimeSummaryController should have_received(@selector(updateRegularHoursLabelWithOffset:))
                        .with(updatedDateComponents);
                    });
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

    describe(@"Invalidating the timer", ^{
        __block NSTimer *timer;
        beforeEach(^{
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
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

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(regularButtonFont)).and_return([UIFont systemFontOfSize:15.0f]);
            theme stub_method(@selector(destructiveButtonTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(punchOutButtonBackgroundColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(punchOutButtonBorderColor)).and_return([UIColor brownColor]);
            theme stub_method(@selector(takeBreakButtonTitleColor)).and_return([UIColor purpleColor]);
            theme stub_method(@selector(takeBreakButtonBackgroundColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(takeBreakButtonBorderColor)).and_return([UIColor magentaColor]);
            theme stub_method(@selector(punchedSinceLabelFont)).and_return([UIFont systemFontOfSize:10.0f]);
            theme stub_method(@selector(punchedSinceLabelTextColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor blackColor]);
            theme stub_method(@selector(transferButtonTitleColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(transferButtonBackgroundColor)).and_return([UIColor blackColor]);
            
            [subject view];
        });

        it(@"should style the punch out button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
            .with(subject.punchOutButton, @"Clock Out", [UIColor redColor], [UIColor greenColor], [UIColor brownColor]);
        });
        
        it(@"should style the take break button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
            .with(subject.breakButton, @"Take a Break", [UIColor purpleColor], [UIColor orangeColor], [UIColor magentaColor]);
        });
        
        it(@"should style the transfer button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
            .with(subject.transferButton, @"Transfer", [UIColor yellowColor], [UIColor blackColor], nil);
        });
        
        it(@"should style the work hours container", ^{
            subject.workHoursContainerView.backgroundColor should equal([UIColor blackColor]);
        });
        
        it(@"should have correct height work hours container", ^{
            subject.workHoursContainerHeight.constant should equal(CGFloat(109.0f));
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
    
    describe(@"as simple punch with oef flow", ^{
        beforeEach(^{
            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
            [subject view];
        });
        
        it(@"should not show transfer button", ^{
            subject.cardContainerView.subviews should_not contain(subject.transferButton);
        });
        
    });

});

SPEC_END

