//
//  DecimalPointButton.m
//  Replicon
//
//  Created by Siddhartha on 14/04/2011.
//  Copyright 2011 EnLume Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	The UIButton that will have the decimal point on it
 */
@interface G2DecimalPointButton : UIButton {
	
    BOOL isMinusButton;
}

+ (G2DecimalPointButton *) decimalPointButton;

@end

/**
 *	The UIButton that will have the minus sign on it
 */
@interface G2MinusButton : UIButton {
	
}

+ (G2MinusButton *) minusButton;

@end

/**
 *	The Separator that will have the button separated
 */
@interface G2SeparatorView : UIView {
	
}

+ (G2SeparatorView *) separatorView;

@end




/**
 *	The class used to create the keypad
 */
@interface G2NumberKeypadDecimalPoint : NSObject {
	
	UITextField *__weak currentTextField;
	
	G2DecimalPointButton *decimalPointButton;
	
	NSTimer *showDecimalPointTimer;
    
    G2MinusButton *minusButton;
    
    NSTimer *showMinusButtonTimer;
    
    G2SeparatorView *separatorView;
    
    NSTimer *showSeparatorTimer;
    
    UITextPosition *olderCursorPosition;
}

@property (nonatomic, strong) NSTimer *showDecimalPointTimer;
@property (nonatomic, strong) G2DecimalPointButton *decimalPointButton;
@property (nonatomic, strong) G2MinusButton *minusButton;
@property (weak) UITextField *currentTextField;
@property (nonatomic, strong) NSTimer *showMinusButtonTimer;
@property (nonatomic, strong) G2SeparatorView *separatorView;
@property (nonatomic, strong) NSTimer *showSeparatorTimer;
@property (nonatomic, strong)UITextPosition *olderCursorPosition;
#pragma mark -
#pragma mark Show the keypad

+ (G2NumberKeypadDecimalPoint *) keypadForTextField:(UITextField *)textField isMinusButton:(BOOL)isMinusBtn; 

- (void) removeButtonFromKeyboard;

@end



