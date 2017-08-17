#import <Foundation/Foundation.h>


@interface ChildControllerHelper : NSObject

- (void)addChildController:(UIViewController *)childController
        toParentController:(UIViewController *)parentController
           inContainerView:(UIView *)containerView;

- (void)replaceOldChildController:(UIViewController *)oldChildController
           withNewChildController:(UIViewController *)newChildController
               onParentController:(UIViewController *)parentController;

- (void)replaceOldChildController:(UIViewController *)oldChildController
           withNewChildController:(UIViewController *)newChildController
               onParentController:(UIViewController *)parentController
                  onContainerView:(UIView *)containerView;
@end
