//
//  TutorialViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 8/3/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController
@synthesize tutorialImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithImage: (UIImage *)image
{
	self = [super init];
	if (self != nil) {
               
        UIImageView *temptutorialImageView=[[UIImageView alloc]init];
        self.tutorialImageView=temptutorialImageView;
        [temptutorialImageView release];
        self.tutorialImageView.image=image;
        self.tutorialImageView.frame=CGRectMake(0, 0, image.size.width, image.size.height);
        
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.view addSubview:tutorialImageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tutorialImageView=nil;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    
	[tutorialImageView		  release];
	
    [super dealloc];
}


@end
