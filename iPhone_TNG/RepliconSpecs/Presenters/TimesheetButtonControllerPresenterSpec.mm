#import <Cedar/Cedar.h>
#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetButtonControllerProvider.h"
#import "FakeParentController.h"
#import "TimesheetButtonController.h"
#import "PreviousApprovalsButtonViewController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetButtonControllerPresenterSpec)

describe(@"TimesheetButtonControllerPresenter", ^{
    __block TimesheetButtonControllerPresenter *subject;
    __block TimesheetButtonControllerProvider *timesheetButtonControllerProvider;

    beforeEach(^{
        timesheetButtonControllerProvider = nice_fake_for([TimesheetButtonControllerProvider class]);
        subject = [[TimesheetButtonControllerPresenter alloc] initWithTimesheetButtonControllerProvider:timesheetButtonControllerProvider];
    });

    describe(NSStringFromSelector(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:title:)), ^{
        describe(@"presenting a timesheet button controller in a parent controller", ^{
            __block FakeParentController *parentController;
            __block id<TimesheetButtonControllerDelegate> delegate;
            __block TimesheetButtonController *expectedChildController;

            beforeEach(^{
                expectedChildController = [[TimesheetButtonController alloc] initWithUserPermissionStorage:nil
                                                                                             buttonStylist:nil
                                                                                                  delegate:nil
                                                                                                     theme:nil];
                spy_on(expectedChildController);

                delegate = nice_fake_for(@protocol(TimesheetButtonControllerDelegate));
                timesheetButtonControllerProvider stub_method(@selector(provideInstanceWithDelegate:))
                    .and_return(expectedChildController);
                parentController = [[FakeParentController alloc] init];
                [parentController view];
                [subject presentTimesheetButtonControllerInContainer:parentController.containerView
                                                  onParentController:parentController
                                                            delegate:delegate
                                                               title:@"title goes here"];
            });

            it(@"should pass the delegate to the timesheetButtonControllerProvider", ^{
                timesheetButtonControllerProvider should have_received(@selector(provideInstanceWithDelegate:)).with(delegate);
            });

            it(@"should set the title on the button controller", ^{
                expectedChildController.title should equal(RPLocalizedString(@"title goes here", nil));
            });

            it(@"should be added as a child controller", ^{
                parentController.childViewControllers.count should equal(1);
                parentController.childViewControllers.firstObject should be_same_instance_as(expectedChildController);
            });

            it(@"should add the workHoursController's view as a subview of the workHoursContainerView", ^{
                parentController.containerView.subviews.count should equal(1);
                parentController.containerView.subviews.firstObject should be_same_instance_as(expectedChildController.view);
            });

            it(@"should call didMoveToParentViewController: on the child view controller];", ^{
                expectedChildController should have_received(@selector(didMoveToParentViewController:)).with(parentController);
            });
        });
    });
    
    describe(NSStringFromSelector(@selector(presentPreviousApprovalsButtonControllerInContainer:onParentController:delegate:)), ^{
        describe(@"presenting a previous approvals controller in a parent controller", ^{
            __block FakeParentController *parentController;
            __block id<PreviousApprovalsButtonControllerDelegate> delegate;
            __block PreviousApprovalsButtonViewController *expectedChildController;
            
            beforeEach(^{
                expectedChildController = [[PreviousApprovalsButtonViewController alloc] initWithDelegate:nil buttonStylist:nil theme:nil];
                spy_on(expectedChildController);
                
                delegate = nice_fake_for(@protocol(PreviousApprovalsButtonControllerDelegate));
                timesheetButtonControllerProvider stub_method(@selector(provideInstanceForApprovalsButtonWithDelegate:))
                .and_return(expectedChildController);
                parentController = [[FakeParentController alloc] init];
                [parentController view];
                [subject presentPreviousApprovalsButtonControllerInContainer:parentController.containerView
                                                  onParentController:parentController
                                                                    delegate:delegate];
            });
            
            it(@"should pass the delegate to the timesheetButtonControllerProvider", ^{
                timesheetButtonControllerProvider should have_received(@selector(provideInstanceForApprovalsButtonWithDelegate:)).with(delegate);
            });
            
            it(@"should be added as a child controller", ^{
                parentController.childViewControllers.count should equal(1);
                parentController.childViewControllers.firstObject should be_same_instance_as(expectedChildController);
            });
                        
            it(@"should call didMoveToParentViewController: on the child view controller];", ^{
                expectedChildController should have_received(@selector(didMoveToParentViewController:)).with(parentController);
            });
        });
    });
});

SPEC_END
