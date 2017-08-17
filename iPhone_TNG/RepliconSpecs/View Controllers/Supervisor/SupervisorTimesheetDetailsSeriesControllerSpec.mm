#import <Cedar/Cedar.h>
#import "SupervisorTimesheetDetailsSeriesController.h"
#import "InjectorProvider.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "SupervisorTimesheetDetailsController.h"
#import "TeamTimesheetSummaryRepository.h"
#import <KSDeferred/KSPromise.h>
#import "TimesheetPeriodCursor.h"
#import "TimesheetPeriod.h"
#import <KSDeferred/KSDeferred.h>
#import "TeamTimesheetSummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SupervisorTimesheetDetailsSeriesControllerSpec)

describe(@"SupervisorTimesheetDetailsSeriesController", ^{
    __block SupervisorTimesheetDetailsSeriesController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block ChildControllerHelper *childControllerHelper;
    __block SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController;
    __block TeamTimesheetSummaryRepository *teamTimesheetSummaryRepository;
    __block KSDeferred *teamTimesheetSummaryDeferred;
    __block UIActivityIndicatorView *spinner;

    beforeEach(^{
        injector = [InjectorProvider injector];

        childControllerHelper = [[ChildControllerHelper alloc] init];
        spy_on(childControllerHelper);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        teamTimesheetSummaryRepository = fake_for([TeamTimesheetSummaryRepository class]);
        [injector bind:[TeamTimesheetSummaryRepository class] toInstance:teamTimesheetSummaryRepository];

        teamTimesheetSummaryDeferred = [[KSDeferred alloc] init];
        teamTimesheetSummaryRepository stub_method(@selector(fetchTeamTimesheetSummaryWithTimesheetPeriod:))
            .with(nil)
            .and_return(teamTimesheetSummaryDeferred.promise);

        supervisorTimesheetDetailsController = [[SupervisorTimesheetDetailsController alloc] initWithChildControllerHelper:nil
                                                                                                                     theme:nil
                                                                                                         punchRulesStorage:nil];
        spy_on(supervisorTimesheetDetailsController);
        [injector bind:[SupervisorTimesheetDetailsController class] toInstance:supervisorTimesheetDetailsController];

        subject = [injector getInstance:[SupervisorTimesheetDetailsSeriesController class]];
    });


    __block UIEdgeInsets expectedContentInset;
    __block UINavigationController *navigationController;

    void (^simulateViewLoad)(void) = ^void{

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        subject.view should_not be_nil;

        spy_on(subject.topLayoutGuide);
        subject.topLayoutGuide stub_method(@selector(length)).and_return((CGFloat)42.0f);

        expectedContentInset = UIEdgeInsetsMake(42, 0, 0, 0);
        [subject viewDidLayoutSubviews];
    };


    describe(@"When the view loads", ^{
        beforeEach(^{
            simulateViewLoad();
            [subject viewWillAppear:NO];
            spinner = (id)subject.navigationItem.rightBarButtonItem.customView;
        });
        afterEach(^{
            stop_spying_on(subject.topLayoutGuide);
        });
        
        it(@"should have a title for the navigation bar", ^{
            subject.title should equal(RPLocalizedString(@"Team Timesheets", @"Team Timesheets"));
        });
        
        it(@"should have back button with title as Back", ^{
            subject.navigationController.navigationBar.topItem.backBarButtonItem.title should equal(RPLocalizedString(@"Back", @"Back"));
        });

        it(@"should not show the spinner when the view first loads", ^{
            spinner should be_instance_of([UIActivityIndicatorView class]);
            spinner.isAnimating should be_truthy;
            spinner.hidden should be_truthy;
        });

        context(@"When the teamTimesheetSummary fetch is successfull", ^{
            beforeEach(^{
                TeamTimesheetSummary *teamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);
                [teamTimesheetSummaryDeferred resolveWithValue:teamTimesheetSummary];
            });

            it(@"should hide the spinner when the teamTimesheetSummary fetch is done", ^{
                spinner.isAnimating should be_falsy;
            });
        });

        context(@"When the teamTimesheetSummary fetch is fails", ^{
            beforeEach(^{
                NSError *error = nice_fake_for([NSError class]);
                [teamTimesheetSummaryDeferred rejectWithError:error];
            });

            it(@"should hide the spinner when the teamTimesheetSummary fetch is done", ^{
                spinner.isAnimating should be_truthy;
            });
        });

        it(@"should have requested the current team timesheet summary", ^{
            teamTimesheetSummaryRepository should have_received(@selector(fetchTeamTimesheetSummaryWithTimesheetPeriod:)).with(nil);
        });

        it(@"should present a supervisor timesheet details controller as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(supervisorTimesheetDetailsController, subject, subject.view);
        });

        it(@"should configure the supervisor timesheet details controller with a team timesheet summary promise", ^{
            supervisorTimesheetDetailsController should have_received(@selector(setupWithTeamTimesheetSummaryPromise:delegate:)).with(teamTimesheetSummaryDeferred.promise, subject);
        });

        it(@"should configure the supervisor timesheet details controller's content inset", ^{
            supervisorTimesheetDetailsController.scrollView.contentInset should equal(expectedContentInset);
        });
    });

    describe(@"as a <SupervisorTimesheetDetailsControllerDelegate>", ^{
        
        describe(@"-supervisorTimesheetDetailsController:requestsPreviousTimesheetWithCursor:", ^{
            __block SupervisorTimesheetDetailsController *newSupervisorTimesheetDetailsController;
            __block KSDeferred *newTeamTimesheetSummaryDeferred;
            __block TimesheetPeriod *previousPeriod;
            __block TimesheetPeriodCursor *cursor;
            
            beforeEach(^{
                previousPeriod = fake_for([TimesheetPeriod class]);
                cursor = nice_fake_for([TimesheetPeriodCursor class]);
                cursor stub_method(@selector(previousPeriod)).and_do_block(^TimesheetPeriod *(){
                    return previousPeriod;
                });
            });
            
            beforeEach(^{
                simulateViewLoad();
                [teamTimesheetSummaryDeferred resolveWithValue:nice_fake_for([TeamTimesheetSummary class])];
                spinner = (id)subject.navigationItem.rightBarButtonItem.customView;
                newTeamTimesheetSummaryDeferred = [[KSDeferred alloc] init];
                teamTimesheetSummaryRepository stub_method(@selector(fetchTeamTimesheetSummaryWithTimesheetPeriod:))
                .with(previousPeriod)
                .and_return(newTeamTimesheetSummaryDeferred.promise);
                
                newSupervisorTimesheetDetailsController = [[SupervisorTimesheetDetailsController alloc] initWithChildControllerHelper:nil
                                                                                                                                theme:nil
                                                                                                                    punchRulesStorage:nil];
                
                spy_on(newSupervisorTimesheetDetailsController);
                [injector bind:[SupervisorTimesheetDetailsController class] toInstance:newSupervisorTimesheetDetailsController];
                [subject supervisorTimesheetDetailsController:supervisorTimesheetDetailsController requestsPreviousTimesheetWithCursor:cursor];
                
            });
            
            afterEach(^{
                stop_spying_on(subject.topLayoutGuide);
                stop_spying_on(newSupervisorTimesheetDetailsController);
            });
            
            it(@"should show the spinner", ^{
                spinner.isAnimating should be_truthy;
            });
            
            it(@"should request a new timesheet summary with the timesheet period from the new cursor position", ^{
                teamTimesheetSummaryRepository should have_received(@selector(fetchTeamTimesheetSummaryWithTimesheetPeriod:)).with(previousPeriod);
            });
            
            it(@"should replace the current view controller with a new supervisor timesheet details controller as a child controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:))
                .with(supervisorTimesheetDetailsController, newSupervisorTimesheetDetailsController, subject);
            });
            
            it(@"should configure the supervisor timesheet details controller with a team timesheet summary promise", ^{
                newSupervisorTimesheetDetailsController should have_received(@selector(setupWithTeamTimesheetSummaryPromise:delegate:))
                .with(newTeamTimesheetSummaryDeferred.promise, subject);
            });
            
            it(@"should configure the supervisor timesheet details controller's content inset", ^{
                newSupervisorTimesheetDetailsController.scrollView.contentInset should equal(expectedContentInset);
            });
            
            context(@"when the promise is resolved", ^{
                beforeEach(^{
                    [newTeamTimesheetSummaryDeferred resolveWithValue:nice_fake_for([TeamTimesheetSummary class])];
                });
                
                it(@"should stop animating the spinner", ^{
                    spinner.isAnimating should be_falsy;
                });
            });
        });
        
        describe(@"-supervisorTimesheetDetailsController:requestsNextTimesheetWithCursor:", ^{
            __block SupervisorTimesheetDetailsController *newSupervisorTimesheetDetailsController;
            __block KSDeferred *newTeamTimesheetSummaryDeferred;
            __block TimesheetPeriod *nextPeriod;
            __block TimesheetPeriodCursor *cursor;
            
            beforeEach(^{
                nextPeriod = fake_for([TimesheetPeriod class]);
                cursor = nice_fake_for([TimesheetPeriodCursor class]);
                cursor stub_method(@selector(nextPeriod)).and_do_block(^TimesheetPeriod *(){
                    return nextPeriod;
                });
            });
            
            beforeEach(^{
                simulateViewLoad();
                [teamTimesheetSummaryDeferred resolveWithValue:nice_fake_for([TeamTimesheetSummary class])];
                spinner = (id)subject.navigationItem.rightBarButtonItem.customView;
                newTeamTimesheetSummaryDeferred = [[KSDeferred alloc] init];
                
                teamTimesheetSummaryRepository stub_method(@selector(fetchTeamTimesheetSummaryWithTimesheetPeriod:))
                .with(nextPeriod)
                .and_return(newTeamTimesheetSummaryDeferred.promise);
                
                newSupervisorTimesheetDetailsController = [[SupervisorTimesheetDetailsController alloc] initWithChildControllerHelper:nil
                                                                                                                                theme:nil
                                                                                                                    punchRulesStorage:nil];
                spy_on(newSupervisorTimesheetDetailsController);
                [injector bind:[SupervisorTimesheetDetailsController class] toInstance:newSupervisorTimesheetDetailsController];
                [subject supervisorTimesheetDetailsController:supervisorTimesheetDetailsController requestsNextTimesheetWithCursor:cursor];
                
            });
            
            afterEach(^{
                stop_spying_on(subject.topLayoutGuide);
                stop_spying_on(newSupervisorTimesheetDetailsController);
            });
            
            it(@"should show the spinner", ^{
                spinner.isAnimating should be_truthy;
            });
            
            it(@"should request a new timesheet summary with the timesheet period from the new cursor position", ^{
                teamTimesheetSummaryRepository should have_received(@selector(fetchTeamTimesheetSummaryWithTimesheetPeriod:)).with(nextPeriod);
            });
            
            it(@"should replace the current view controller with a new supervisor timesheet details controller as a child controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:))
                .with(supervisorTimesheetDetailsController, newSupervisorTimesheetDetailsController, subject);
            });
            
            it(@"should configure the supervisor timesheet details controller with a team timesheet summary promise", ^{
                newSupervisorTimesheetDetailsController should have_received(@selector(setupWithTeamTimesheetSummaryPromise:delegate:))
                .with(newTeamTimesheetSummaryDeferred.promise, subject);
            });
            
            it(@"should configure the supervisor timesheet details controller's content inset", ^{
                newSupervisorTimesheetDetailsController.scrollView.contentInset should equal(expectedContentInset);
            });
            
            context(@"when the promise is resolved", ^{
                
                beforeEach(^{
                    [newTeamTimesheetSummaryDeferred resolveWithValue:nice_fake_for([TeamTimesheetSummary class])];
                });
                
                it(@"should stop animating the spinner", ^{
                    spinner.isAnimating should be_falsy;
                    
                });
                
            });
            
        });
        
        
    });
});

SPEC_END
