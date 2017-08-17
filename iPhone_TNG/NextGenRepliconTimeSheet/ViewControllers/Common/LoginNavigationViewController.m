#import "LoginNavigationViewController.h"


@interface UINavigationController (LoginNavigationViewController)

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface LoginNavigationViewController ()

@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;

@end

@implementation LoginNavigationViewController

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{

    [self.navigationBar setTranslucent:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    if (!self.shouldIgnorePushingViewControllers)
    {
        [super pushViewController: viewController animated: animated];
    }

    self.shouldIgnorePushingViewControllers = YES;
}


- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    self.shouldIgnorePushingViewControllers = NO;
}


@end
