#import "TeamTimeNavigationController.h"
#import "Constants.h"


@interface UINavigationController (TeamTimeNavigationController)

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface TeamTimeNavigationController ()

@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;

@end

@implementation TeamTimeNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self)
    {
        self.viewControllers = @[rootViewController];
    }
    return self;
}

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
