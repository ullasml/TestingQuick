#import <Cedar/Cedar.h>
#import "ChildControllerHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ChildControllerHelperSpec)

describe(@"ChildControllerHelper", ^{
    __block ChildControllerHelper *subject;
    beforeEach(^{
        subject = [[ChildControllerHelper alloc] init];
    });

    describe(@"addChildController:toParentController:inContainerView", ^{
        __block UIViewController *parentViewController;
        __block UIViewController *childViewController;
        __block UIView *containerView;

        beforeEach(^{
            parentViewController = [[UIViewController alloc] init];
            childViewController = [[UIViewController alloc] init];
            containerView = [[UIView alloc] initWithFrame:CGRectMake(42, 56, 200, 300)];

            spy_on(childViewController);
        });

        afterEach(^{
            stop_spying_on(childViewController);
        });

        beforeEach(^{
            [subject addChildController:childViewController
                     toParentController:parentViewController
                        inContainerView:containerView];
        });

        it(@"should add the child view controller's view as a subview of container view", ^{
            childViewController.view.superview should be_same_instance_as(containerView);
        });

        it(@"should set the child view controller's view's frame", ^{
            childViewController.view.frame should equal(CGRectMake(0, 0, 200, 300));
        });

        it(@"should add the child view controller as a child view controller of parent view controller", ^{
            childViewController.parentViewController should be_same_instance_as(parentViewController);
        });

        it(@"should tell the child view controller it has moved to a new parent view controller", ^{
            childViewController should have_received(@selector(didMoveToParentViewController:)).with(parentViewController);
        });
    });

    describe(@"replaceOldController:withNewController:onParentController:", ^{
        __block UIViewController *parentViewController;
        __block UIViewController *oldChildViewController;
        __block UIViewController *newChildViewController;

        beforeEach(^{
            parentViewController = [[UIViewController alloc] init];
            parentViewController.view.bounds = CGRectMake(42, 56, 200, 300);
            oldChildViewController = [[UIViewController alloc] init];
            newChildViewController = [[UIViewController alloc] init];

            spy_on(oldChildViewController);
            spy_on(newChildViewController);
        });

        afterEach(^{
            stop_spying_on(oldChildViewController);
            stop_spying_on(newChildViewController);
        });

        beforeEach(^{
            [subject replaceOldChildController:oldChildViewController withNewChildController:newChildViewController onParentController:parentViewController];
        });

        it(@"should display the new child view controller", ^{
            parentViewController.childViewControllers.firstObject should be_same_instance_as(newChildViewController);
        });

        it(@"should have a single child controller", ^{
            parentViewController.childViewControllers.count should equal(1);
        });
        
        it(@"should tell the new child controller that it has moved to parent controller", ^{
            newChildViewController should have_received(@selector(didMoveToParentViewController:)).with(parentViewController);
        });

        it(@"should tell the old child controller to remove itself from the parent controller", ^{
            oldChildViewController should have_received(@selector(willMoveToParentViewController:)).with(nil);
            oldChildViewController should have_received(@selector(removeFromParentViewController));
        });
    });
});


SPEC_END
