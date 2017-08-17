#import "ChildControllerHelper.h"

@implementation ChildControllerHelper

- (void)addChildController:(UIViewController *)childController
        toParentController:(UIViewController *)parentController
           inContainerView:(UIView *)containerView

{
    [parentController addChildViewController:childController];
    childController.view.frame = containerView.bounds;
    [containerView addSubview:childController.view];
    [childController didMoveToParentViewController:parentController];
}

- (void)replaceOldChildController:(UIViewController *)oldChildController
           withNewChildController:(UIViewController *)newChildController
               onParentController:(UIViewController *)parentController
{
    [parentController addChildViewController:newChildController];
    newChildController.view.frame = parentController.view.frame;
    [oldChildController willMoveToParentViewController:nil];

    [parentController transitionFromViewController:oldChildController
                                  toViewController:newChildController
                                          duration:0.25
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{}
                                        completion:^(BOOL finished) {
                                            [oldChildController removeFromParentViewController];
                                            [newChildController didMoveToParentViewController:parentController];
                                        }];
}

- (void)replaceOldChildController:(UIViewController *)oldChildController
           withNewChildController:(UIViewController *)newChildController
               onParentController:(UIViewController *)parentController
                  onContainerView:(UIView *)containerView
{
    [parentController addChildViewController:newChildController];
    newChildController.view.frame = containerView.bounds;
    [oldChildController willMoveToParentViewController:nil];

    [parentController transitionFromViewController:oldChildController
                                  toViewController:newChildController
                                          duration:0.25
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{}
                                        completion:^(BOOL finished) {
                                            [oldChildController removeFromParentViewController];
                                            [newChildController didMoveToParentViewController:parentController];
                                        }];
}




@end
