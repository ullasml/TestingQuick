#import <Cedar/Cedar.h>
#import "SupervisorTimesheetDetailsController.h"
#import "Theme.h"
#import <KSDeferred/KSDeferred.h>
#import "ChildControllerHelper.h"
#import "TeamTimesheetSummary.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "CurrencyValue.h"
#import "GrossPayController.h"
#import "TimesheetForUserWithWorkHours.h"
#import "GoldenAndNonGoldenTimesheetsController.h"
#import "AllViolationSections.h"
#import "ViolationRepository.h"
#import "SupervisorTimesheetSummaryController.h"
#import "TimesheetPeriod.h"
#import "TimesheetPeriodCursor.h"
#import "UserPermissionsStorage.h"
#import "GrossPayTimeHomeViewController.h"
#import "CurrencyValue.h"
#import "DayTimeSummaryController.h"
#import "WorkHoursDeferred.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorTimesheetDetailsControllerSpec)

describe(@"SupervisorTimesheetDetailsController", ^{
    __block SupervisorTimesheetDetailsController *subject;
    __block KSDeferred *teamTimesheetSummaryDeferred;
    __block KSDeferred *goldenTimesheetsDeferred;
    __block KSDeferred *workHoursDeferred;
    __block KSDeferred *nonGoldenTimesheetsDeferred;
    __block ChildControllerHelper *childControllerHelper;
    __block NSDateFormatter *dateFormatter;
    __block id<Theme> theme;
    __block id<SupervisorTimesheetDetailsControllerDelegate> delegate;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<BSInjector, BSBinder> injector;
    __block GrossPayTimeHomeViewController *grossPayTimeHomeViewController;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
    });

    __block GrossPayController *grossPayController;
    beforeEach(^{
        grossPayController = [[GrossPayController alloc] initWithChildControllerHelper:childControllerHelper theme:theme];
        spy_on(grossPayController);
        [injector bind:[GrossPayController class] toInstance:grossPayController];
    });

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        dateFormatter = nice_fake_for([NSDateFormatter class]);
        [injector bind:InjectorKeyDayMonthInUTCTimeZoneFormatter toInstance:dateFormatter];

        teamTimesheetSummaryDeferred = [[KSDeferred alloc] init];
        
        goldenTimesheetsDeferred = [[KSDeferred alloc] init];
        [injector bind:InjectorKeyGoldenTimesheetDeferred toInstance:goldenTimesheetsDeferred];

        nonGoldenTimesheetsDeferred = [[KSDeferred alloc] init];
        [injector bind:InjectorKeyNonGoldenTimesheetDeferred toInstance:nonGoldenTimesheetsDeferred];
        
        workHoursDeferred = [[KSDeferred alloc] init];
        [injector bind:[WorkHoursDeferred class] toInstance:workHoursDeferred];
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        delegate = fake_for(@protocol(SupervisorTimesheetDetailsControllerDelegate));

        subject = [injector getInstance:[SupervisorTimesheetDetailsController class]];
        [subject setupWithTeamTimesheetSummaryPromise:teamTimesheetSummaryDeferred.promise delegate:delegate];
    });

    describe(@"presenting the Supervisor Timesheet SummaryController", ^{
        __block SupervisorTimesheetSummaryController<CedarDouble> *timesheetSummaryController;

        beforeEach(^{
            timesheetSummaryController = (id)[[SupervisorTimesheetSummaryController alloc] initWithTimesheetDetailsPresenter:nil theme:nil];
            spy_on(timesheetSummaryController);
            [injector bind:[SupervisorTimesheetSummaryController class] toInstance:timesheetSummaryController];
            subject.view should_not be_nil;
        });

        it(@"should add the timesheet summary controller as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timesheetSummaryController, subject, subject.timesheetSummaryContainerView);
        });
        
        it(@"should not add the gross pay summary controller as a child controller", ^{
            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
        });

        it(@"should set itself as the delegate of the timesheet summary controller", ^{
            timesheetSummaryController should have_received(@selector(setupWithDelegate:timeSummaryPromise:)).with(subject,teamTimesheetSummaryDeferred.promise);
        });

        context(@"when the team timesheet summary promise is resolved", ^{
            __block TimesheetPeriod *previousPeriod;
            __block TimesheetPeriod *currentPeriod;
            __block TimesheetPeriod *nextPeriod;

            beforeEach(^{
                previousPeriod = nice_fake_for([TimesheetPeriod class]);
                currentPeriod = nice_fake_for([TimesheetPeriod class]);
                nextPeriod = nice_fake_for([TimesheetPeriod class]);

                TeamTimesheetSummary *teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                teamTimesheetSummary stub_method(@selector(previousPeriod)).and_return(previousPeriod);
                teamTimesheetSummary stub_method(@selector(currentPeriod)).and_return(currentPeriod);
                teamTimesheetSummary stub_method(@selector(nextPeriod)).and_return(nextPeriod);
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });

            it(@"should update the cursor reference", ^{
                subject.cursor.previousPeriod should equal(previousPeriod);
                subject.cursor.nextPeriod should equal(nextPeriod);
            });
        });
    });

    describe(@"Styling the Subviews", ^{
        beforeEach(^{
            theme stub_method(@selector(supervisorTimesheetDetailsControllerBackGroundColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(supervisorTimesheetDetailsControllerSummaryCardBackGroundColor)).and_return([UIColor yellowColor]);

            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
            [subject.view layoutIfNeeded];
        });

        it(@"should set the correct width for the scrollview's content", ^{
            CGRectGetWidth(subject.scrollableContentView.bounds) should equal(CGRectGetWidth(subject.view.bounds));
        });

        it(@"should apply the theme to the views", ^{
            subject.view.backgroundColor should equal([UIColor redColor]);
            subject.summaryCardContainerView.layer.cornerRadius should be_greater_than(1.0f);
            subject.scrollableContentView.backgroundColor should equal([UIColor redColor]);
            subject.summaryCardContainerView.backgroundColor should equal([UIColor yellowColor]);
            subject.workHoursContainerView.backgroundColor should equal([UIColor yellowColor]);
        });
    });
    
    describe(@"Presenting the Day Time Summary Controller", ^{
        
        __block DayTimeSummaryController<CedarDouble> *dayTimeSummaryController;

        beforeEach(^{
            dayTimeSummaryController = (id)[[DayTimeSummaryController alloc] initWithWorkHoursPresenterProvider:nil theme:nil todaysDateControllerProvider:nil childControllerHelper:nil];
            spy_on(dayTimeSummaryController);
            [injector bind:[DayTimeSummaryController class] toInstance:dayTimeSummaryController];
            
            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];
        });
        
        afterEach(^{
            stop_spying_on(dayTimeSummaryController);
        });
        
        it(@"should present the Day Time Summary Controller in its containing view", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
        });
        
        it(@"should correctly configure Day Time Summary Controller", ^{
            dayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:)).with(nil,nil,workHoursDeferred.promise,YES,YES,CGFloat(0.0f));
        });
        
        it(@"should set itself as it's child controller's delegate", ^{
            dayTimeSummaryController.delegate should be_nil;
        });
        
        it(@"should set itself as it's child controller's delegate", ^{
            dayTimeSummaryController.workHoursPromise should be_same_instance_as(workHoursDeferred.promise);
        });
        
        context(@"when the request for the team's timesheet details completes", ^{
            __block TeamTimesheetSummary *teamTimesheetSummary;
            __block TeamWorkHoursSummary *teamWorkHoursSummary;
            
            beforeEach(^{
                teamWorkHoursSummary = nice_fake_for([TeamWorkHoursSummary class]);
                teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                teamTimesheetSummary stub_method(@selector(teamWorkHoursSummary)).and_return(teamWorkHoursSummary) ;
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"should pass it along to the golden timesheet controller", ^{
                dayTimeSummaryController.workHoursPromise.value should be_same_instance_as(teamWorkHoursSummary);
            });
        });
        
        context(@"when the timesheet summary for the team cannot be fetched", ^{
            __block NSError *error;
            
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [teamTimesheetSummaryDeferred rejectWithError:error];
            });
            
            it(@"should reject the golden timesheet controller's deferred", ^{
                dayTimeSummaryController.workHoursPromise.rejected should be_truthy;
                dayTimeSummaryController.workHoursPromise.error should be_same_instance_as(error);
            });
        });
    });

    describe(@"Presenting the Golden Timesheet details", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];
        });

        it(@"should present the golden timesheet controller in its containing view", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(subject.goldenTimesheetUserController, subject, subject.goldenTimesheetContainerView);
        });

        it(@"should initially hide the golden timesheets", ^{
            CGRectGetHeight(subject.goldenTimesheetContainerView.bounds) should equal(0.0f);
        });

        it(@"should set itself as it's child controller's delegate", ^{
            subject.goldenTimesheetUserController.delegate should be_same_instance_as(subject);
        });
        
        it(@"should set itself as it's child controller's delegate", ^{
            subject.goldenTimesheetUserController.timesheetUsersPromise should be_same_instance_as(goldenTimesheetsDeferred.promise);
        });

        context(@"when the request for the team's timesheet details completes", ^{
            __block TeamTimesheetSummary *teamTimesheetSummary;
            __block NSArray *goldenTimesheetUsers;

            beforeEach(^{
                goldenTimesheetUsers = @[];
                teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                teamTimesheetSummary stub_method(@selector(goldenTimesheets)).and_return(goldenTimesheetUsers) ;
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });

            it(@"should pass it along to the golden timesheet controller", ^{
                subject.goldenTimesheetUserController.timesheetUsersPromise.value should be_same_instance_as(goldenTimesheetUsers);
            });
        });

        context(@"when the timesheet summary for the team cannot be fetched", ^{
            __block NSError *error;

            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [teamTimesheetSummaryDeferred rejectWithError:error];
            });

            it(@"should reject the golden timesheet controller's deferred", ^{
                subject.goldenTimesheetUserController.timesheetUsersPromise.rejected should be_truthy;
                subject.goldenTimesheetUserController.timesheetUsersPromise.error should be_same_instance_as(error);
            });
        });
    });

    describe(@"Presenting the Non Golden timesheet details", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];
            spy_on(subject.nongoldenTimesheetUserController);
        });
        
        afterEach(^{
            stop_spying_on(subject.nongoldenTimesheetUserController);
        });

        it(@"should present the golden timesheet controller in its containing view", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(subject.nongoldenTimesheetUserController, subject, subject.nongoldenTimesheetContainerView);
        });

        it(@"should initially hide the golden timesheets", ^{
            CGRectGetHeight(subject.nongoldenTimesheetContainerView.bounds) should equal(0.0f);
        });

        it(@"should set itself as it's child controller's delegate", ^{
            subject.nongoldenTimesheetUserController.delegate should be_same_instance_as(subject);
        });
        
        it(@"should set itself as it's child controller's delegate", ^{
            subject.nongoldenTimesheetUserController.timesheetUsersPromise should be_same_instance_as(nonGoldenTimesheetsDeferred.promise);
        });

        context(@"when the request for the team's timesheet details completes", ^{
            __block TeamTimesheetSummary *teamTimesheetSummary;
            __block NSArray *nongoldenTimesheetUsers;

            beforeEach(^{
                nongoldenTimesheetUsers = @[];
                teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                teamTimesheetSummary stub_method(@selector(nongoldenTimesheets)).and_return(nongoldenTimesheetUsers) ;
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });

            it(@"should pass it along to the non golden timesheet controller", ^{
                subject.nongoldenTimesheetUserController.timesheetUsersPromise.value should equal(nongoldenTimesheetUsers);
            });
        });

        context(@"when the timesheet summary for the team cannot be fetched", ^{
            __block NSError *error;

            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [teamTimesheetSummaryDeferred rejectWithError:error];
            });

            it(@"should reject the nongolden timesheet controller's promise", ^{
                subject.nongoldenTimesheetUserController.timesheetUsersPromise.rejected should be_truthy;
                subject.nongoldenTimesheetUserController.timesheetUsersPromise.error should be_same_instance_as(error);
            });
        });
    });

    describe(@"as a TimesheetUserControllerDelegate", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];
        });

        describe(@"when the golden GoldenAndNonGoldenTimesheetsController wants to resize itself", ^{
            beforeEach(^{
                [subject timesheetUserController:subject.goldenTimesheetUserController didUpdateHeight:123];
            });

            it(@"should resize the golden timesheet container view", ^{
                subject.goldenTimesheetContainerHeightConstraint.constant should equal(123);
            });
        });

        describe(@"when the non-golden GoldenAndNonGoldenTimesheetsController wants to resize itself", ^{
            beforeEach(^{
                [subject timesheetUserController:subject.nongoldenTimesheetUserController didUpdateHeight:456];
                [subject.view layoutIfNeeded];
            });

            it(@"should resize the golden timesheet container view", ^{
                subject.nongoldenTimesheetContainerHeightConstraint.constant should equal(456);
            });
        });

        describe(@"when the  GoldenAndNonGoldenTimesheetsController timesheets are tapped", ^{
            beforeEach(^{
                [subject timesheetUserController:subject.goldenTimesheetUserController timesheetUserType:TimesheetUserTypeGolden selectedIndex:[NSIndexPath indexPathForRow:0 inSection:0]];
            });

            it(@"should resize the golden timesheet container view", ^{
                subject.selectedIndexPath should equal([NSIndexPath indexPathForRow:0 inSection:0]);
                subject.selectedTimesheetUserType should equal(TimesheetUserTypeGolden);
            });
        });
    });

    describe(@"as a <TimesheetSummaryControllerDelegate>", ^{
        __block SupervisorTimesheetDetailsController *receivedSupervisorTimesheetDetailsController;
        __block TimesheetPeriodCursor *receivedCursor;
        __block TimesheetPeriod *previousPeriod;
        __block TimesheetPeriod *nextPeriod;

        describe(@"-timesheetSummaryControllerDidTapNextButton:", ^{
            beforeEach(^{
                receivedSupervisorTimesheetDetailsController = nil;
                receivedCursor = nil;

                delegate stub_method(@selector(supervisorTimesheetDetailsController:requestsNextTimesheetWithCursor:)).and_do_block(^(SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController, TimesheetPeriodCursor *cursor){
                    receivedSupervisorTimesheetDetailsController = supervisorTimesheetDetailsController;
                    receivedCursor = cursor;
                });

                subject.view should_not be_nil;

                previousPeriod = fake_for([TimesheetPeriod class]);
                nextPeriod = fake_for([TimesheetPeriod class]);

                TeamTimesheetSummary *teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                teamTimesheetSummary stub_method(@selector(previousPeriod)).and_return(previousPeriod);
                teamTimesheetSummary stub_method(@selector(nextPeriod)).and_return(nextPeriod);

                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });

            it(@"should notify its delegate with its cursor", ^{
                [subject timesheetSummaryControllerDidTapNextButton:(id)[NSNull null]];

                receivedSupervisorTimesheetDetailsController should be_same_instance_as(subject);
                receivedCursor.previousPeriod should be_same_instance_as(previousPeriod);
                receivedCursor.nextPeriod should be_same_instance_as(nextPeriod);
            });
        });

        describe(@"-timesheetSummaryControllerDidTapPreviousButton:", ^{
            beforeEach(^{
                receivedSupervisorTimesheetDetailsController = nil;
                receivedCursor = nil;

                delegate stub_method(@selector(supervisorTimesheetDetailsController:requestsPreviousTimesheetWithCursor:)).and_do_block(^(SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController, TimesheetPeriodCursor *cursor){
                    receivedSupervisorTimesheetDetailsController = supervisorTimesheetDetailsController;
                    receivedCursor = cursor;
                });

                subject.view should_not be_nil;

                previousPeriod = fake_for([TimesheetPeriod class]);
                nextPeriod = fake_for([TimesheetPeriod class]);

                TeamTimesheetSummary *teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                teamTimesheetSummary stub_method(@selector(previousPeriod)).and_return(previousPeriod);
                teamTimesheetSummary stub_method(@selector(nextPeriod)).and_return(nextPeriod);

                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });

            it(@"should notify its delegate with its cursor", ^{
                [subject timesheetSummaryControllerDidTapPreviousButton:(id)[NSNull null]];

                receivedSupervisorTimesheetDetailsController should be_same_instance_as(subject);
                receivedCursor.previousPeriod should be_same_instance_as(previousPeriod);
                receivedCursor.nextPeriod should be_same_instance_as(nextPeriod);
            });
        });
    
    });
    
    describe(@"presenting the gross pay controller", ^{
        
        __block CurrencyValue *totalPay;
        __block TeamTimesheetSummary *teamTimesheetSummary;
        
        beforeEach(^{
            totalPay = fake_for([CurrencyValue class]);
            grossPayTimeHomeViewController = [[GrossPayTimeHomeViewController alloc] initWithTheme:nil];
            spy_on(grossPayTimeHomeViewController);
            [injector bind:[GrossPayTimeHomeViewController class] toInstance:grossPayTimeHomeViewController];
            
            userPermissionsStorage stub_method(@selector(canViewPayDetails)).and_return(YES);
            teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
            teamTimesheetSummary stub_method(@selector(actualsByPayCode)).and_return(@[@1]);
            teamTimesheetSummary stub_method(@selector(payAmountDetailsPermission)).and_return(YES);
            teamTimesheetSummary stub_method(@selector(totalPay)).and_return(totalPay);
            teamTimesheetSummary stub_method(@selector(payHoursDetailsPermission)).and_return(YES);
            [subject view];
        });
        
        describe(@"should not display GrossHours View when canViewPayDetails is false and other permissions are true", ^{

            beforeEach(^{
                userPermissionsStorage stub_method(@selector(canViewPayDetails)).again().and_return(NO);
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"GrossPayTimeHomeController should not have received setUp method", ^{
                grossPayTimeHomeViewController should_not have_received(@selector(setupWithGrossSummary:delegate:));
            });
            
            it(@"should not add the gross pay summary controller as a child controller", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
            });
            
            it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                subject.grossPayContainerHeightConstraint.constant should equal(0);
            });
        });
        
        describe(@"should not display GrossHours View when actualsByPaycode count is 0 and other permissions are true", ^{
            beforeEach(^{
                teamTimesheetSummary stub_method(@selector(actualsByPayCode)).again().and_return(nil);
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"GrossPayTimeHomeController should not have received setUp method", ^{
                grossPayTimeHomeViewController should_not have_received(@selector(setupWithGrossSummary:delegate:));
            });
            
            it(@"should not add the gross pay summary controller as a child controller", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
            });
            
            it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                subject.grossPayContainerHeightConstraint.constant should equal(0);
            });
        });
        
        describe(@"should not display GrossHours View when payAmountDetailsPermission is false and other permissions are true", ^{
            beforeEach(^{
                teamTimesheetSummary stub_method(@selector(payAmountDetailsPermission)).again().and_return(NO);
                teamTimesheetSummary stub_method(@selector(payHoursDetailsPermission)).again().and_return(NO);

                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"GrossPayTimeHomeController should not have received setUp method", ^{
                grossPayTimeHomeViewController should_not have_received(@selector(setupWithGrossSummary:delegate:));
            });
            
            it(@"should not add the gross pay summary controller as a child controller", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
            });
            
            it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                subject.grossPayContainerHeightConstraint.constant should equal(0);
            });
        });
        
        describe(@"should not display GrossHours View when payHoursDetailsPermission is false and other permissions are true", ^{
            beforeEach(^{
                teamTimesheetSummary stub_method(@selector(payAmountDetailsPermission)).again().and_return(NO);
                teamTimesheetSummary stub_method(@selector(payHoursDetailsPermission)).again().and_return(NO);                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"GrossPayTimeHomeController should not have received setUp method", ^{
                grossPayTimeHomeViewController should_not have_received(@selector(setupWithGrossSummary:delegate:));
            });
            
            it(@"should not add the gross pay summary controller as a child controller", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
            });
            
            it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                subject.grossPayContainerHeightConstraint.constant should equal(0);
            });
        });
        
        describe(@"should not display GrossHours View when totalPay is false and other permissions are true", ^{
            beforeEach(^{
                teamTimesheetSummary stub_method(@selector(totalPay)).again().and_return(nil);
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"GrossPayTimeHomeController should not have received setUp method", ^{
                grossPayTimeHomeViewController should_not have_received(@selector(setupWithGrossSummary:delegate:));
            });
            
            it(@"should not add the gross pay summary controller as a child controller", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
            });
            
            it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                subject.grossPayContainerHeightConstraint.constant should equal(0);
            });
        });
        
        describe(@"should display GrossHours View when permissions are true", ^{
            beforeEach(^{
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });
            
            it(@"GrossPayTimeHomeController should not have received setUp method", ^{
                grossPayTimeHomeViewController should have_received(@selector(setupWithGrossSummary:delegate:)).with(teamTimesheetSummary,subject);
            });
            
            it(@"should not add the gross pay summary controller as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayTimeHomeViewController,subject,subject.grossPayContainerView);
            });
            
            it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                subject.grossPayContainerHeightConstraint.constant should be_greater_than(0);
            });
        });
        
        
    });
});

SPEC_END
