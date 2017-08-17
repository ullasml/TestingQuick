    //
//  CalculatorViewController.m
//  Replicon
//
//  Created by Manoj  on 26/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2CalculatorViewController.h"
#import "G2AmountViewController.h"

@implementation G2CalculatorViewController
@synthesize calView,resultLabel;
@synthesize refCalDelegate,refAmountDelegate;
@synthesize finalResult;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


- (id) init
{
	score = 10;
	DLog(@"init ZcacluEaterController");
	self = [super init];
	if (self != nil) {
		
		calView = [[UIView alloc]init];
		resultLabel = [[UILabel alloc]init];
		
		myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[myButton setTitle:RPLocalizedString( @"Calulator",@"")forState:UIControlStateNormal];
		[myButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		myButton.frame = CGRectMake(60, 180, 200, 40);
	}
	return self;
}

#pragma mark -
#pragma mark viewDidLoad

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
#pragma mark --
#pragma mark myButton(Calulator button)
	
	self.view.frame = CGRectMake(0, 0, 320, 480);
	
#pragma mark  ---
#pragma mark buttons 7,8,9.
	//button #7
	sevenButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[sevenButton setTitle:@"7" forState:UIControlStateNormal];
	[sevenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	sevenButton.frame = CGRectMake(5, 50-2, 65, 40);
	sevenButton.tag = 7;
	[sevenButton addTarget:self action:@selector(buttonDigitPressed:)
		  forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:sevenButton];
	
	//button #8
	eightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[eightButton setTitle:@"8" forState:UIControlStateNormal];
	[eightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	eightButton.frame = CGRectMake(85,50-2, 65, 40);
	eightButton.tag = 8;
	[eightButton addTarget:self action:@selector(buttonDigitPressed:)
		  forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:eightButton];
	
	//button #9
	nineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[nineButton setTitle:@"9" forState:UIControlStateNormal];
	[nineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	nineButton.frame = CGRectMake(165,50, 65, 40);
	nineButton.tag = 9;
	[nineButton addTarget:self action:@selector(buttonDigitPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:nineButton];
	
#pragma mark  ---
#pragma mark button +.
	
	//button fro +
	plusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[plusButton setTitle:@"+" forState:UIControlStateNormal];
	[plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	plusButton.frame = CGRectMake(245,50-2, 65, 40);
	plusButton.tag = 1;
	[plusButton addTarget:self action:@selector(buttonOperationPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:plusButton];
	
#pragma mark  ---
#pragma mark buttons 4,5,6.
	
	//button # 4
	fourButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[fourButton setTitle:@"4" forState:UIControlStateNormal];
	[fourButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	fourButton.frame = CGRectMake(5,100-2, 65, 40);
	fourButton.tag = 4;
	[fourButton addTarget:self action:@selector(buttonDigitPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:fourButton];
	
	//button # 5
	fiveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[fiveButton setTitle:@"5" forState:UIControlStateNormal];
	[fiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	fiveButton.frame = CGRectMake(85,100-2, 65, 40);
	fiveButton.tag = 5;
	[fiveButton addTarget:self action:@selector(buttonDigitPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:fiveButton];
	
	//button # 6
	sixButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[sixButton setTitle:@"6" forState:UIControlStateNormal];
	[sixButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	sixButton.frame = CGRectMake(165,100-2, 65, 40);
	sixButton.tag = 6;
	[sixButton addTarget:self action:@selector(buttonDigitPressed:)
		forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:sixButton];
	
#pragma mark  ---
#pragma mark button - (minusButton).
	
	//button fro -
	minusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[minusButton setTitle:@"-" forState:UIControlStateNormal];
	[minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	minusButton.frame = CGRectMake(245,100-2, 65, 40);
	minusButton.tag =2;
	[minusButton addTarget:self action:@selector(buttonOperationPressed:)
		  forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:minusButton];
	
#pragma mark  ---
#pragma mark buttons 1,2,3.
	
	//button # 1
	oneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[oneButton setTitle:@"1" forState:UIControlStateNormal];
	[oneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	oneButton.frame = CGRectMake(5,150, 65, 40);
	oneButton.tag =1;
	[oneButton addTarget:self action:@selector(buttonDigitPressed:)
		forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:oneButton];
	
	//button # 2
	twoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[twoButton setTitle:@"2" forState:UIControlStateNormal];
	[twoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	twoButton.frame = CGRectMake(85,150-2, 65, 40);
	twoButton.tag = 2;
	[twoButton addTarget:self action:@selector(buttonDigitPressed:)
		forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:twoButton];
	
	//button # 3
	threeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[threeButton setTitle:@"3" forState:UIControlStateNormal];
	[threeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	threeButton.frame = CGRectMake(165,150-2, 65, 40);
	threeButton.tag = 3;
	[threeButton addTarget:self action:@selector(buttonDigitPressed:)
		  forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:threeButton];
	
#pragma mark  ---
#pragma mark button Equalto.
	
	//button Equalto 
	equaltoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[equaltoButton setTitle:@"=" forState:UIControlStateNormal];
	[equaltoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	equaltoButton.frame = CGRectMake(245,150-2, 65, 40);
	[equaltoButton addTarget:self action:@selector(buttonOperationPressed:)
			forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:equaltoButton];
	
#pragma mark  ---
#pragma mark button cancelInput.
	
	//button # C
	dotButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[dotButton setTitle:@"C" forState:UIControlStateNormal];
	[dotButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	dotButton.frame = CGRectMake(5,200-2, 65, 40);
	dotButton.tag = 5;
	[dotButton addTarget:self action:@selector(cancelInput)
		forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:dotButton];
	
#pragma mark  ---
#pragma mark button 0.
	
	//button # 0
	ZeroButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[ZeroButton setTitle:@"0" forState:UIControlStateNormal];
	[ZeroButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	ZeroButton.frame = CGRectMake(85,200-2, 65, 40);
	[ZeroButton addTarget:self action:@selector(buttonDigitPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:ZeroButton];
	
#pragma mark ---
#pragma mark button multiplyButton.
	
	//button # *
	multiplyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[multiplyButton setTitle:@"*" forState:UIControlStateNormal];
	[multiplyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	multiplyButton.frame = CGRectMake(165,200-2, 65, 40);
	multiplyButton.tag = 3;
	[multiplyButton addTarget:self action:@selector(buttonOperationPressed:)
			 forControlEvents:UIControlEventTouchUpInside];
	[calView addSubview:multiplyButton];
}

#pragma mark -
#pragma mark calViewClicked

-(void)calViewClicked{
	
	calView.frame = CGRectMake(0, 480,320,240);
	calView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:calView];
	
	DLog(@"calViewClicked");
	
	
	
#pragma mark ---
#pragma mark  resultLabel
	//result label
	resultLabel.frame = CGRectMake(calView.bounds.origin.x+5, calView.bounds.origin.y+5 , calView.bounds.size.width-10, calView.bounds.size.height-200);
	resultLabel.backgroundColor = [UIColor whiteColor];
	resultLabel.text = @"$0.00";
	resultLabel.textAlignment = NSTextAlignmentRight;	
	resultLabel.textColor = [UIColor blackColor];
	resultLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
	[self.calView addSubview:resultLabel];
	
	//buttonPressed = YES;
	
#pragma mark ---
#pragma mark (okbutton).
	
	//button # okbutton
	okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[okButton setTitle:RPLocalizedString(@"ok", @"ok")  forState:UIControlStateNormal];
	[okButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	okButton.frame = CGRectMake(245,200-2, 65, 40);
	[okButton addTarget:self action:@selector(slideOut)
	   forControlEvents:UIControlEventTouchUpInside];
	[self cancelInput];
	[calView addSubview:okButton];
	
	CGRect frame = self.calView.frame;
	[UIView beginAnimations:@"presentWithView" context:nil];
	frame.origin = CGPointMake(0.0, self.view.bounds.size.height - self.calView.bounds.size.height);
	[UIView setAnimationDuration:0.25];
	self.calView.frame = frame;
	[UIView commitAnimations];
}

- (void) slideOut {
	//[refCalDelegate performSelector:@selector(tableMoveToTop:) withObject:[NSNumber numberWithInt:0]];
	//[refCalDelegate tableMoveToTop:0];
	DLog(@"customUIActionSheetViewController  slideout ");
	[UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	// Move this view to bottom of superview
	CGRect frame = self.calView .frame;
	frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
	self.calView.frame = frame;
	[UIView commitAnimations]; 
	//[refCalDelegate getStringFromZCal:resultLabel.text];
	[refCalDelegate performSelector:@selector(getStringFromZCal:) withObject:resultLabel.text];
	
	[refAmountDelegate performSelector:@selector(getValueFromZCal:) withObject:resultLabel.text];
}

#pragma mark -
#pragma mark Calculations

-(void)buttonDigitPressed :(id)sender {
	
	DLog(@"buttonDigitPressed:%f",currentNumber);
	currentNumber = currentNumber*10 + (float)[sender tag];
	resultLabel.text = [NSString stringWithFormat:@"$%0.02f",currentNumber];
	
	NSString * temp = [NSString stringWithFormat:@"%@",resultLabel.text];
	temp1 = [temp length];
	
	if (temp1 >=13 ) {
		[oneButton setEnabled:NO];
		[twoButton setEnabled:NO];
		[threeButton setEnabled:NO];
		[fourButton setEnabled:NO];
		[fiveButton setEnabled:NO];
		[sixButton setEnabled:NO];
		[sevenButton setEnabled:NO];
		[eightButton setEnabled:NO];
		[nineButton setEnabled:NO];
		[ZeroButton setEnabled:NO];
	}
}

-(void)buttonOperationPressed:(id)sender {
	
	[oneButton setEnabled:YES];
	[twoButton setEnabled:YES];
	[threeButton setEnabled:YES];
	[fourButton setEnabled:YES];
	[fiveButton setEnabled:YES];
	[sixButton setEnabled:YES];
	[sevenButton setEnabled:YES];
	[eightButton setEnabled:YES];
	[nineButton setEnabled:YES];
	[ZeroButton setEnabled:YES];
	
	if (currentOperation == 0) 
		result = currentNumber;
	else {
		switch (currentOperation) {
			case 1:
				result = result + currentNumber;
				break;
			case 2:
				result = result - currentNumber;
				break;
			case 3:
				result = result * currentNumber;
				break;
			case 4:
				result = result / currentNumber;
				break;
			case 5:
				currentOperation = 0;
				break;
		}
	}
	currentNumber = 0;
	resultLabel.text = [NSString stringWithFormat:@"$%0.02f",result];	
	if ([sender tag] == 0) 
		result = 0;
	currentOperation = [sender tag];
}

-(void)cancelInput {
	
	
	[oneButton setEnabled:YES];
	[twoButton setEnabled:YES];
	[threeButton setEnabled:YES];
	[fourButton setEnabled:YES];
	[fiveButton setEnabled:YES];
	[sixButton setEnabled:YES];
	[sevenButton setEnabled:YES];
	[eightButton setEnabled:YES];
	[nineButton setEnabled:YES];
	[ZeroButton setEnabled:YES];
	
	currentNumber = 0;
	resultLabel.text = @"$0.00";
	currentOperation = 0;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
	if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {
		[self.view removeFromSuperview];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}




/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/




@end
