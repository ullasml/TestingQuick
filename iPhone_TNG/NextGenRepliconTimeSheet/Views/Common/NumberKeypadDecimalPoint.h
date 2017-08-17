//
//  DecimalPointButton.m
//  Replicon
//
//  Created by Siddhartha on 14/04/2011.
//  Copyright 2011 EnLume Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	The UIButton that will have the Done Button on it
 */
@interface DoneButton : UIButton {
	
    id __weak doneDelegate;
}

+ (DoneButton *) doneButton;

@end

/**
 *	The class used to create the keypad
 */

/**
 *	The UIButton that will have the decimal point on it
 */
@interface DecimalPointButton : UIButton {
	
    BOOL isMinusButton;
}

+ (DecimalPointButton *) decimalPointButton;

@end

/**
 *	The UIButton that will have the minus sign on it
 */
@interface MinusButton : UIButton {
	
}

+ (MinusButton *) minusButton;

@end
/**
 *	The UIButton that will have the minus sign on it
 */
@interface ResignButton : UIButton {
	
}

+ (ResignButton *) resignButton;

@end

/**
 *	The Separator that will have the button separated
 */
@interface SeparatorView : UIView {
	
}

+ (SeparatorView *) separatorView;

@end

@interface NumberKeypadDecimalPoint : NSObject {
	
	UITextField *__weak currentTextField;
	
	DoneButton *doneButton;
	
	NSTimer *showDonePointTimer;
    
    UITextPosition *olderCursorPosition;
    //id delegate;
   
    DecimalPointButton *decimalPointButton;
     MinusButton *minusButton;
    
    NSTimer *showDecimalPointTimer;
    NSTimer *showMinusButtonTimer;
    NSTimer *showResignPointTimer;
    SeparatorView *separatorView;
    
    NSTimer *showSeparatorTimer;
    
    BOOL isDonePressed;
    ResignButton *resignButton;

}
@property(nonatomic,assign ) BOOL isDonePressed;
@property (nonatomic, strong) NSTimer *showDonePointTimer;
@property (nonatomic, strong) DoneButton *doneButton;
@property (nonatomic, weak) id delegate;

@property (weak) UITextField *currentTextField;
@property (nonatomic, strong)UITextPosition *olderCursorPosition;
@property (nonatomic, strong) DecimalPointButton *decimalPointButton;
@property (nonatomic, strong) NSTimer *showDecimalPointTimer;

@property (nonatomic, strong) MinusButton *minusButton;
@property (nonatomic, strong) NSTimer *showMinusButtonTimer;
@property (nonatomic, strong) SeparatorView *separatorView;
@property (nonatomic, strong) NSTimer *showSeparatorTimer;
@property (nonatomic, strong) ResignButton *resignButton;
@property (nonatomic, strong) NSTimer *showResignPointTimer;
#pragma mark -
#pragma mark Show the keypad

+ (NumberKeypadDecimalPoint *) keypadForTextField:(UITextField *)textField withDelegate:(id)dlegate withMinus:(BOOL)isMinusShown andisDoneShown:(BOOL)isDoneShown withResignButton:(BOOL)isResignButton;

- (void) removeButtonFromKeyboard;

@end



