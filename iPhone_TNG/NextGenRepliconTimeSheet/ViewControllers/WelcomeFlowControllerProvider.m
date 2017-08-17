
#import "WelcomeFlowControllerProvider.h"

@implementation WelcomeFlowControllerProvider


-(WelcomeViewController*)provideWelcomeViewControllerInstance
{
   WelcomeViewController *welcomeViewController = [[Util iPhoneStoryboard] instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    return welcomeViewController;
}

-(WelcomeContentViewController*)provideWelcomeContentViewControllerInstance
{
    WelcomeContentViewController *pageContentViewController = [[Util iPhoneStoryboard] instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    return pageContentViewController;
}

-(UIPageViewController*)providePageViewControllerInstance
{
      UIPageViewController *pageViewController = [[Util iPhoneStoryboard] instantiateViewControllerWithIdentifier:@"WelcomePageViewController"];
    return pageViewController;
}


@end
