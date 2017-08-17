#import "ApprovalsNavigationController.h"

@implementation ApprovalsNavigationController

-(id) initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController: rootViewController];
	if (self != nil) {
		
	}

    [self.navigationBar setTranslucent:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

	return self;
}


@end
