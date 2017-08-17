//
//  HRFreeTrialNavigationViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "HRFreeTrialNavigationViewController.h"
#import "Constants.h"

@implementation HRFreeTrialNavigationViewController
-(id) initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController: rootViewController];
	if (self != nil) {
		
	}
	//Fix for ios7//JUHI
	float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version>=7.0)
    {
        [self.navigationBar setTranslucent:NO];
        self.navigationBar.tintColor=[UIColor whiteColor];
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    else
    {
        self.navigationBar.tintColor=RepliconStandardNavBarTintColor;
    }
    
	return self;
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
	if ([super visibleViewController] != nil && [[self visibleViewController] isKindOfClass: [NSNull class]])
    {
		
	}
    
	[super pushViewController: viewController animated: animated];
    
}


-(UIViewController *) popViewControllerAnimated:(BOOL)animated
{
	if ([super visibleViewController] != nil && [[self visibleViewController] isKindOfClass: [NSNull class]])
    {
		
	}
	return [super popViewControllerAnimated: animated];
}

@end