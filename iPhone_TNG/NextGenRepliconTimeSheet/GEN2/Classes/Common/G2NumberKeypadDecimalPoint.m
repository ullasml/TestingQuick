//
//  DecimalPointButton.m
//  Replicon
//
//  Created by Siddhartha on 14/04/2011.
//  Copyright 2011 EnLume Inc. All rights reserved.
//

#import "G2NumberKeypadDecimalPoint.h"
#import "G2Util.h"
#import <QuartzCore/QuartzCore.h>

static UIImage *backgroundImageDepressed;

/**
 *
 */
@implementation G2DecimalPointButton

+ (void) initialize {
	backgroundImageDepressed = [G2Util thumbnailImage:@"G2decimalKey.png"];
}

- (id) initWithBool:(BOOL)isMinusBtn {
     //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
	if(self = [super init]) { //Initially hidden	
		//[super adjustsImageWhenDisabled:NO];
        isMinusButton=isMinusBtn;
        if (isMinusButton) {
            self.frame = CGRectMake(0, screenRect.size.height-53, 52, 53);
        }
        else {
            self.frame = CGRectMake(0, screenRect.size.height-53, 105, 53);
        }

		self.titleLabel.font = [UIFont systemFontOfSize:35];
		[self setTitleColor:[UIColor colorWithRed:77.0f/255.0f green:84.0f/255.0f blue:98.0f/255.0f alpha:1.0] forState:UIControlStateNormal];	
		[self setBackgroundImage:backgroundImageDepressed forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[self setTitle:@"." forState:UIControlStateNormal];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
     //JUHI
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	//Bring in the button at same speed as keyboard
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1]; //we lose 0.1 seconds when we display it with timer
    if (isMinusButton) {
        self.frame = CGRectMake(0,  screenRect.size.height-53, 52, 53);
    }
    else {
        self.frame = CGRectMake(0,  screenRect.size.height-53, 105, 53);
    }
	
	[UIView commitAnimations];
}

+ (G2DecimalPointButton *) decimalPointButton {
	G2DecimalPointButton *button = [[G2DecimalPointButton alloc] init];
	return button;
}

@end
/**
 *
 */
@implementation G2MinusButton

+ (void) initialize {
	backgroundImageDepressed = [G2Util thumbnailImage:@"G2decimalKey.png"];
}

- (id) init {
     //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	if(self = [super initWithFrame:CGRectMake(53, screenRect.size.height-53, 52, 53)]) { //Initially hidden	
		//[super adjustsImageWhenDisabled:NO];
		self.titleLabel.font = [UIFont systemFontOfSize:35];
		[self setTitleColor:[UIColor colorWithRed:77.0f/255.0f green:84.0f/255.0f blue:98.0f/255.0f alpha:1.0] forState:UIControlStateNormal];	
		[self setBackgroundImage:backgroundImageDepressed forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[self setTitle:@"-" forState:UIControlStateNormal];
        //[self setBackgroundColor:[UIColor whiteColor]];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
     //JUHI
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	//Bring in the button at same speed as keyboard
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1]; //we lose 0.1 seconds when we display it with timer
	self.frame = CGRectMake(53, screenRect.size.height-53, 52, 53);
    [UIView commitAnimations];
}

+ (G2MinusButton *) minusButton {
	G2MinusButton *button = [[G2MinusButton alloc] init];
	return button;
}

@end

@implementation G2SeparatorView

+ (void) initialize {
	backgroundImageDepressed = [G2Util thumbnailImage:@"G2decimalKey.png"];
}

- (id) init {
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	if(self = [super initWithFrame:CGRectMake(52.0, screenRect.size.height-53,1, 53)]) 
    { 	
		self.backgroundColor=[UIColor colorWithRed:77.0f/255.0f green:84.0f/255.0f blue:98.0f/255.0f alpha:1.0];
        
	}
	return self;
}

+ (G2SeparatorView *) separatorView {
	G2SeparatorView *view = [[G2SeparatorView alloc] init];
	return view ;
}


@end


/**
 *
 */
@implementation G2NumberKeypadDecimalPoint

static G2NumberKeypadDecimalPoint *decimalPointKeyPad;
static BOOL isMinusButtonPresent;

//Retain
@synthesize decimalPointButton;
@synthesize showDecimalPointTimer;
@synthesize minusButton;
//Assign
@synthesize currentTextField;
@synthesize showMinusButtonTimer;
@synthesize separatorView;
@synthesize showSeparatorTimer;
@synthesize olderCursorPosition;

#pragma mark -
#pragma mark Release



//Private Method
- (void) addButtonToKeyboard:(G2DecimalPointButton *)button {	
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:button];	
}

- (void) addMinusButtonToKeyboard:(G2MinusButton *)button {	
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:button];	
}

- (void) addSeparatorBetweenButtons:(G2SeparatorView *)separator {	
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:separator];	
}



//Private Method //This is executed after a delay from showKeypadForTextField
- (void) addTheDecimalPointToKeyboard {	
	[decimalPointKeyPad addButtonToKeyboard:decimalPointKeyPad.decimalPointButton];
    
    
}

-(void)addTheMinusButtonToKeyboard{
    
    if (isMinusButtonPresent) {
        [decimalPointKeyPad addMinusButtonToKeyboard:decimalPointKeyPad.minusButton];
    }
    
}
-(void)addSeparatorBetweenButtonsInKeyboard{
    
    if (isMinusButtonPresent) {
        [decimalPointKeyPad addSeparatorBetweenButtons:decimalPointKeyPad.separatorView];
    }
    
}

//Private Method
/*- (void) decimalPointPressed {
	//Check to see if there is a . already
	NSString *currentText = currentTextField.text;
	if ([currentText rangeOfString:@"." options:NSBackwardsSearch].length == 0) {
		currentTextField.text = [currentTextField.text stringByAppendingString:@"."];
	}else {
		//alreay has a decimal point
	}
}*/

//Private Method
- (void) decimalPointPressed {
    
    //Check to see if there is a . already
	NSString *currentText = currentTextField.text;
	if ([currentText rangeOfString:@"." options:NSBackwardsSearch].length == 0) {
		currentTextField.text = [currentTextField.text stringByAppendingString:@"."];
	}else {
			//alreay has a decimal point
		return ;
	}
	
	if ([decimalPointButton tag] == 333) {
		
		NSString *oldText = [currentTextField text];
        if (![currentTextField.text isKindOfClass:[NSNull class] ])
        {
            if ([[currentTextField text] length] > 1) {
                NSUInteger spaceindex = [[currentTextField text] length] - 2;
                NSString *text = [oldText substringToIndex:spaceindex];
                [currentTextField setText:[NSString stringWithFormat:@"%@. ",text]];
            }
            else {
                [currentTextField setText:@". "];
            }
        }
		
	}
}

- (void)minusPressed 
{
   

    UITextRange *range = [self.currentTextField selectedTextRange];
    UITextPosition *start=range.start;
    NSInteger pos = [self.currentTextField offsetFromPosition:currentTextField.beginningOfDocument toPosition:start];
    
    if (pos<[self.currentTextField.text length]) 
    {
        [self.currentTextField replaceRange:range withText:@"-"];
    }
    else
    {
        self.currentTextField.text=[self.currentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.currentTextField replaceRange:range withText:@"- "];
    }
    
    
    
}

/*
 Show the keyboard
 */
+ (G2NumberKeypadDecimalPoint *) keypadForTextField:(UITextField *)textField isMinusButton:(BOOL)isMinusBtn{
	
   
    isMinusButtonPresent=isMinusBtn;
    
    if (!decimalPointKeyPad)
    {
        decimalPointKeyPad = [[G2NumberKeypadDecimalPoint alloc] init];
    }
    G2DecimalPointButton *tempButton= [[G2DecimalPointButton alloc] initWithBool:isMinusBtn];
    decimalPointKeyPad.decimalPointButton =tempButton;
    
    
    [decimalPointKeyPad.decimalPointButton addTarget:decimalPointKeyPad action:@selector(decimalPointPressed) forControlEvents:UIControlEventTouchUpInside];
    
    decimalPointKeyPad.minusButton = [G2MinusButton minusButton];
    [decimalPointKeyPad.minusButton addTarget:decimalPointKeyPad action:@selector(minusPressed) forControlEvents:UIControlEventTouchUpInside];
    
    decimalPointKeyPad.separatorView=[G2SeparatorView separatorView];
    decimalPointKeyPad.currentTextField = textField;
	decimalPointKeyPad.showDecimalPointTimer = [NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addTheDecimalPointToKeyboard) userInfo:nil repeats:NO];
    decimalPointKeyPad.showMinusButtonTimer=[NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addTheMinusButtonToKeyboard) userInfo:nil repeats:NO];
    decimalPointKeyPad.showSeparatorTimer=[NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addSeparatorBetweenButtonsInKeyboard) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showDecimalPointTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showMinusButtonTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showSeparatorTimer forMode:NSDefaultRunLoopMode];
	return decimalPointKeyPad;
}

/*
 Hide the keyboard
 */
- (void) removeButtonFromKeyboard {
	[self.showDecimalPointTimer invalidate]; //stop any timers still wanting to show the button
    [self.showMinusButtonTimer invalidate];
    [self.showSeparatorTimer invalidate];
	[self.decimalPointButton removeFromSuperview];
    [self.minusButton removeFromSuperview];
    [self.separatorView removeFromSuperview];
}


@end

