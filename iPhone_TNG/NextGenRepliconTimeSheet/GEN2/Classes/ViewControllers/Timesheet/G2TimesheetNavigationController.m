//
//  TimesheetNavigationController.m
//  Replicon
//
//  Created by Ravi Shankar on 7/28/11.
//  Copyright 2011 enl. All rights reserved.
//

#import "G2TimesheetNavigationController.h"
#import "G2Constants.h"
#import "G2Util.h"

@implementation G2TimesheetNavigationController
-(id) initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController: rootViewController];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        self.navigationBar.translucent = FALSE;
        self.navigationBar.barTintColor=[G2Util getNavbarTintColor];
        self.navigationBar.tintColor=RepliconStandardWhiteColor;
        
    }
    else
        self.navigationBar.tintColor=RepliconStandardNavBarTintColor;
	if (self != nil) {
		
	}
	
	return self;
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{

	if ([super visibleViewController] != nil && [[self visibleViewController] isKindOfClass: [NSNull class]]) {
		
	}
	[super pushViewController: viewController animated: animated];
}


-(UIViewController *) popViewControllerAnimated:(BOOL)animated
{
	if ([super visibleViewController] != nil && [[self visibleViewController] isKindOfClass: [NSNull class]]) {
		
	}
	return [super popViewControllerAnimated: animated];
}

@end
