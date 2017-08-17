//
//  DecimalPointButton.m
//  Replicon
//
//  Created by Siddhartha on 14/04/2011.
//  Copyright 2011 EnLume Inc. All rights reserved.
//

#import "NumberKeypadDecimalPoint.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "CurrentTimesheetViewController.h"
#import "StartFreeTrialViewController.h"
#import "Constants.h"
#import "ExpenseEntryViewController.h"
#import "AmountViewController.h"
static UIImage *backgroundImageUnpressed;
static UIImage *backgroundImageDepressed;
static UIImage *decimalBackgroundImageDepressed;

/**
 *
 */
@implementation DoneButton

+ (void) initialize {
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version>=7.0)
    {
        backgroundImageDepressed = [Util thumbnailImage:DONE_BUTTON_IMAGE_iOS7];
    }
    else{
        backgroundImageDepressed = [Util thumbnailImage:@"DoneDown.png"];
        backgroundImageUnpressed = [Util thumbnailImage:@"DoneUp.png"];
    }
	
}

- (id) initWithDelegate:(id)delegate andisDoneShown:(BOOL)isDone {
	if(self = [super init]) { //Initially hidden	
		//[super adjustsImageWhenDisabled:NO];
        if (isDone)
        {
            CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
            height = height > 0 ? height : 53;
            
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            self.frame = CGRectMake((ONE_THIRD_SCREEN_WIDTH*2)+2, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-1, height);
            doneDelegate=delegate;
            self.titleLabel.font = [UIFont systemFontOfSize:35];
            [self setTitleColor:[UIColor colorWithRed:77.0f/255.0f green:84.0f/255.0f blue:98.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
            //Fix for ios7//JUHI
            float version= [[UIDevice currentDevice].systemVersion newFloatValue];
            
            if (version>=7.0)
            {
                [self setBackgroundImage:backgroundImageDepressed forState:UIControlStateNormal];
            }
            else{
                [self setBackgroundImage:backgroundImageUnpressed forState:UIControlStateNormal];
                [self setBackgroundImage:backgroundImageDepressed forState:UIControlStateHighlighted];
            }
            
            [self.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18] ];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
        
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
    height = height > 0 ? height : 53;

	CGRect screenRect = [[UIScreen mainScreen] bounds];
	//Bring in the button at same speed as keyboard
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1]; //we lose 0.1 seconds when we display it with timer
    self.frame = CGRectMake((ONE_THIRD_SCREEN_WIDTH*2)+2, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-1,height);
   
	
	[UIView commitAnimations];
}

+ (DoneButton *) doneButton {
	DoneButton *button = [[DoneButton alloc] init];
    [button setAccessibilityIdentifier:@"uia_number_keypad_done_btn_identifier"];
	return button;
}

@end

@implementation ResignButton

- (id) init{
	if(self = [super init]) {
        CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
        height = height > 0 ? height : 53;
        UIImage *resignButtonImage = [Util thumbnailImage:RESIGN_BUTTON_IMAGE_ios7];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.frame = CGRectMake(0, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-2, height);
        self.titleLabel.font = [UIFont systemFontOfSize:35];
        [self setTitleColor:[UIColor colorWithRed:77.0f/255.0f green:84.0f/255.0f blue:98.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
        [self setBackgroundImage:resignButtonImage forState:UIControlStateNormal];
        [self setBackgroundImage:resignButtonImage forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18] ];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
    height = height > 0 ? height : 53;

	CGRect screenRect = [[UIScreen mainScreen] bounds];
	//Bring in the button at same speed as keyboard
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1]; //we lose 0.1 seconds when we display it with timer
    self.frame = CGRectMake(0, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-2,height);
    
	
	[UIView commitAnimations];
}

+ (ResignButton *) resignButton {
	ResignButton *button = [[ResignButton alloc] init];
	return button;
}

@end
@implementation DecimalPointButton

- (id) initWithBool:(BOOL)isMinusBtn andDelegate:(id)delegate {
	if(self = [super init]) {
        CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
        height = height > 0 ? height : 53;

        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        isMinusButton = isMinusBtn;
        if (isMinusButton) {
            self.frame = CGRectMake(0, screenRect.size.height-height, ((ONE_THIRD_SCREEN_WIDTH)-1)/2, height);
        }
        else {
            self.frame = CGRectMake(0, screenRect.size.height-height, ONE_THIRD_SCREEN_WIDTH-2, height);
        }
        
		self.titleLabel.font = [UIFont systemFontOfSize:35];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIImage *normalBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundNormal"];
        UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundHighlighted"];
        
        if(([delegate isKindOfClass:[ExpenseEntryViewController class]]) || ([delegate isKindOfClass:[CurrentTimesheetViewController class]]))
        {
            normalBackgroundImage = [Util thumbnailImage:DECIMAL_IMAGE_iOS7];
            highlightedBackgroundImage = nil;
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
        
        [self setTitle:[Util detectDecimalMark] forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsMake(10.0, 0.0, 25.0, 0.0);

	}

	return self;
}

+ (DecimalPointButton *) decimalPointButton {
	DecimalPointButton *button = [[DecimalPointButton alloc] init];
	return button;
}

@end
/**
 *
 */
@implementation MinusButton

+ (void) initialize {
    decimalBackgroundImageDepressed = [Util thumbnailImage:DECIMAL_IMAGE_iOS7];
}

- (id) init {
    CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
    height = height > 0 ? height : 53;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	if(self = [super initWithFrame:CGRectMake((((ONE_THIRD_SCREEN_WIDTH)-1)/2)-1,  screenRect.size.height-height, ((ONE_THIRD_SCREEN_WIDTH)-1)/2, height)]) {
		self.titleLabel.font = [UIFont systemFontOfSize:35];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[self setTitle:@"-" forState:UIControlStateNormal];
        
        UIImage *normalBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundNormal"];
        UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundHighlighted"];
        
        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];

	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
    height = height > 0 ? height : 53;

	 CGRect screenRect = [[UIScreen mainScreen] bounds];
	//Bring in the button at same speed as keyboard
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1]; //we lose 0.1 seconds when we display it with timer
	self.frame = CGRectMake((((ONE_THIRD_SCREEN_WIDTH)-1)/2)-1, screenRect.size.height-height, ((ONE_THIRD_SCREEN_WIDTH)-1)/2, height);
    [UIView commitAnimations];
}

+ (MinusButton *) minusButton {
	MinusButton *button = [[MinusButton alloc] init];
	return button;
}

@end

@implementation SeparatorView

+ (void) initialize {
    decimalBackgroundImageDepressed = [Util thumbnailImage:DECIMAL_IMAGE_iOS7];
}

- (id) init {
    CGFloat height = ([[NSUserDefaults standardUserDefaults] floatForKey:@"KeyBoardHeight"] / 4);
    height = height > 0 ? height : 53;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	if(self = [super initWithFrame:CGRectMake((((ONE_THIRD_SCREEN_WIDTH)-1)/2)-1, screenRect.size.height-height,1, height)])
    {
		self.backgroundColor=[UIColor colorWithRed:175.0f/255.0f green:176.0f/255.0f blue:179.0f/255.0f alpha:1.0];
        
	}
	return self;
}

+ (SeparatorView *) separatorView {
	SeparatorView *view = [[SeparatorView alloc] init];
	return view;
}

@end

@implementation NumberKeypadDecimalPoint

static NumberKeypadDecimalPoint *decimalPointKeyPad;
static BOOL isMinusButtonPresent;
BOOL isResignButtonPresent;
//Retain
@synthesize doneButton;
@synthesize showDonePointTimer;
@synthesize delegate;
@synthesize showDecimalPointTimer;
@synthesize decimalPointButton;
@synthesize minusButton;
//Assign
@synthesize currentTextField;
@synthesize olderCursorPosition;
@synthesize isDonePressed;
@synthesize showMinusButtonTimer;
@synthesize separatorView;
@synthesize showSeparatorTimer;
@synthesize resignButton;
@synthesize showResignPointTimer;
#pragma mark -
#pragma mark Release



//Private Method
- (void) addButtonToKeyboard:(DoneButton *)button {
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:button];	
}


- (void) addDecimalButtonToKeyboard:(DecimalPointButton *)button {
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:button];
}
- (void) addMinusButtonToKeyboard:(MinusButton *)button {
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:button];
}

- (void) addSeparatorBetweenButtons:(SeparatorView *)separator {
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	NSUInteger topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:separator];
}
- (void) addResignButtonToKeyboard:(ResignButton *)button {
	//Add a button to the top, above all windows
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    
    for (int k=0; k<[allWindows count]; k++)
    {
        id layer=[allWindows objectAtIndex:k];
        if ([layer isKindOfClass:[UIWindow class]])
            
        {
            UIWindow *keyboardWindow = (UIWindow *)layer;
            for (UIView *possibleKeyboard in [keyboardWindow subviews])
            {
                // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
                if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]||
                    [[possibleKeyboard description] hasPrefix:@"<UIKeyboard"] ||
                    [[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"])
                {
                    [keyboardWindow addSubview:button];
                }
            }
            
        }
    }
}

//Private Method //This is executed after a delay from showKeypadForTextField
- (void) addTheDoneToKeyboard {
	[decimalPointKeyPad addButtonToKeyboard:decimalPointKeyPad.doneButton];
}

- (void) addTheDecimalPointToKeyboard {
    if (!isResignButtonPresent)
    {
        [decimalPointKeyPad addDecimalButtonToKeyboard:decimalPointKeyPad.decimalPointButton];
    }
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

- (void) addTheResignButtonToKeyboard
{
	[decimalPointKeyPad addResignButtonToKeyboard:decimalPointKeyPad.resignButton];
}

//Private Method
- (void) done {
    isDonePressed=YES;
    //Check to see if there is a . already
	[currentTextField resignFirstResponder];
}

- (void) decimalPointPressed {
    
    //Check to see if there is a . already
	NSString *currentText = currentTextField.text;
    
    if ([decimalPointButton tag] == 333)
    {
        if ([currentText rangeOfString:[Util detectDecimalMark] options:NSBackwardsSearch].length == 0) {
            currentTextField.text = [currentTextField.text stringByAppendingString:[Util detectDecimalMark]];
        }else {
            //alreay has a decimal point
            return ;
        }
    }
    else
    {
        if ([currentText rangeOfString:[Util detectDecimalMark] options:NSBackwardsSearch].length == 0)
        {
            UITextRange *selectedRange = [currentTextField selectedTextRange];
            NSInteger beginningOffset=[currentTextField offsetFromPosition:currentTextField.beginningOfDocument toPosition:selectedRange.end];
            NSInteger offset = [currentTextField offsetFromPosition:currentTextField.endOfDocument toPosition:selectedRange.end];
            
            NSString *beginText=[currentText substringToIndex:beginningOffset];
            NSString *endText=[currentText substringFromIndex:beginningOffset];
            currentTextField.text = [NSString stringWithFormat:@"%@%@%@",beginText,[Util detectDecimalMark],endText];
            UITextPosition *newPos = [currentTextField positionFromPosition:currentTextField.endOfDocument offset:offset];
            currentTextField.selectedTextRange = [currentTextField textRangeFromPosition:newPos toPosition:newPos];
        }else {
            //alreay has a decimal point
            return ;
        }

        
    }
	
	
	if ([decimalPointButton tag] == 333) {
		
		NSString *oldText = [currentTextField text];
        if (![currentTextField.text isKindOfClass:[NSNull class] ])
        {
            if ([[currentTextField text] length] > 1) {
                NSUInteger spaceindex = [[currentTextField text] length] - 2;
                NSString *text = [oldText substringToIndex:spaceindex];
                [currentTextField setText:[NSString stringWithFormat:@"%@%@ ",text,[Util detectDecimalMark]]];
            }
            else {
                [currentTextField setText:[NSString stringWithFormat:@"%@ ",[Util detectDecimalMark]]];
            }
        }
		
	}
}
- (void)minusPressed
{
    UITextRange *range = [self.currentTextField selectedTextRange];
    UITextPosition *start=range.start;
    NSInteger pos = [self.currentTextField offsetFromPosition:currentTextField.beginningOfDocument toPosition:start];
    if (pos==0) {
            self.currentTextField.text=[self.currentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.currentTextField replaceRange:range withText:@"-"];
       }

}

- (void)resignKeyBoard
{
    if (delegate!=nil && ([delegate isKindOfClass:[ExtendedInOutCell class]] || [delegate isKindOfClass:[StartFreeTrialViewController class]] ))
    {
        //[delegate resignKeyBoard:currentTextField];
        if ([delegate isKindOfClass:[ExtendedInOutCell class]])
        {
            [delegate resizeKeyBoardForResigning:currentTextField];
        }
        [currentTextField resignFirstResponder];
    }
    
}
/*
 Show the keyboard
 */
+ (NumberKeypadDecimalPoint *) keypadForTextField:(UITextField *)textField withDelegate:(id)dlegate withMinus:(BOOL)isMinusShown andisDoneShown:(BOOL)isDoneShown withResignButton:(BOOL)isResignButton{
	
    isMinusButtonPresent=isMinusShown;
    isResignButtonPresent=isResignButton;
    if (decimalPointKeyPad)
    {
        decimalPointKeyPad=nil;
    }
    decimalPointKeyPad = [[NumberKeypadDecimalPoint alloc] init];
  
    DoneButton *tempButton= [[DoneButton alloc] initWithDelegate:dlegate andisDoneShown:isDoneShown];
    decimalPointKeyPad.doneButton =tempButton;
    [decimalPointKeyPad.doneButton setAccessibilityIdentifier:@"uia_number_keypad_done_btn_identifier"];
    [decimalPointKeyPad.doneButton addTarget:decimalPointKeyPad action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    
    DecimalPointButton *tempDecimalButton= [[DecimalPointButton alloc] initWithBool:isMinusShown andDelegate:dlegate];
    decimalPointKeyPad.decimalPointButton =tempDecimalButton;
   
   
    [decimalPointKeyPad.decimalPointButton addTarget:decimalPointKeyPad action:@selector(decimalPointPressed) forControlEvents:UIControlEventTouchUpInside];
    decimalPointKeyPad.minusButton = [MinusButton minusButton];
    [decimalPointKeyPad.minusButton addTarget:decimalPointKeyPad action:@selector(minusPressed) forControlEvents:UIControlEventTouchUpInside];
    if (isResignButtonPresent)
    {
        ResignButton *tempResignButton= [[ResignButton alloc] init];
        [tempResignButton setAccessibilityIdentifier:@"uia_keyboard_resign_button_identifier"];
        decimalPointKeyPad.resignButton=tempResignButton;
       
        [decimalPointKeyPad.resignButton addTarget:decimalPointKeyPad action:@selector(resignKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    decimalPointKeyPad.separatorView=[SeparatorView separatorView];
    decimalPointKeyPad.currentTextField = textField;
	decimalPointKeyPad.showDonePointTimer = [NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addTheDoneToKeyboard) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showDonePointTimer forMode:NSDefaultRunLoopMode];
    decimalPointKeyPad.showDecimalPointTimer = [NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addTheDecimalPointToKeyboard) userInfo:nil repeats:NO];
    decimalPointKeyPad.showMinusButtonTimer=[NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addTheMinusButtonToKeyboard) userInfo:nil repeats:NO];
    decimalPointKeyPad.showSeparatorTimer=[NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addSeparatorBetweenButtonsInKeyboard) userInfo:nil repeats:NO];
    decimalPointKeyPad.showResignPointTimer = [NSTimer timerWithTimeInterval:0.1 target:decimalPointKeyPad selector:@selector(addTheResignButtonToKeyboard) userInfo:nil repeats:NO];

    [[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showDecimalPointTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showMinusButtonTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showSeparatorTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:decimalPointKeyPad.showResignPointTimer forMode:NSDefaultRunLoopMode];
	return decimalPointKeyPad;
}

/*
 Hide the keyboard
 */
- (void) removeButtonFromKeyboard {
	[self.showDonePointTimer invalidate]; //stop any timers still wanting to show the button
    [self.showMinusButtonTimer invalidate];
    [self.showSeparatorTimer invalidate];
    [self.showResignPointTimer invalidate];
    [self.doneButton removeFromSuperview];
    [self.showDecimalPointTimer invalidate];
    [self.decimalPointButton removeFromSuperview];
    [self.resignButton removeFromSuperview];
    [self.minusButton removeFromSuperview];
    [self.separatorView removeFromSuperview];
}


@end

