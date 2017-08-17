//
//  OverlayViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 7/6/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2OverlayViewController.h"
#import "G2DataListViewController.h"

@interface G2OverlayViewController ()

@end

@implementation G2OverlayViewController
//@synthesize rvController;

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
	
	//[rvController doneSearching_Clicked:nil];
}


@end
