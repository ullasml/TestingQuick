//
//  OverlayViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 7/6/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "OverlayViewController.h"
#import "SelectClientOrProjectViewController.h"
#import "SelectProjectOrTaskViewController.h"

@interface OverlayViewController ()

@end

@implementation OverlayViewController
@synthesize parentDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (parentDelegate != nil && ![parentDelegate isKindOfClass:[NSNull class]] &&
		([parentDelegate isKindOfClass:[SelectClientOrProjectViewController class]]||[parentDelegate isKindOfClass:[SelectProjectOrTaskViewController class]]))
    {
        [parentDelegate doneSearching_Clicked:nil];
    }
	
}


@end
