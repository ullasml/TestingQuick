
#import <Foundation/Foundation.h>
#import "WelcomeViewController.h"
#import "WelcomeContentViewController.h"

@interface WelcomeFlowControllerProvider : NSObject

-(WelcomeViewController*)provideWelcomeViewControllerInstance;
-(WelcomeContentViewController*)provideWelcomeContentViewControllerInstance;
-(UIPageViewController*)providePageViewControllerInstance;
@end
