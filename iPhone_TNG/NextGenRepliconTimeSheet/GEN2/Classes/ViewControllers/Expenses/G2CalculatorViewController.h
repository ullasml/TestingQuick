//
//  CalculatorViewController.h
//  Replicon
//
//  Created by Manoj  on 26/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface G2CalculatorViewController : UIViewController {
	UIView *calView;
	UILabel * resultLabel;
	int score;
	//calculator button
	UIButton *myButton;
	
	//number buttons
	UIButton * oneButton;
	UIButton * twoButton;
	UIButton * threeButton;
	UIButton* fourButton;
	UIButton* fiveButton;
	UIButton* sixButton;
	UIButton* sevenButton;
	UIButton* eightButton;
	UIButton* nineButton;
	UIButton* ZeroButton;
	
	//Operands...
	UIButton* plusButton;
	UIButton* minusButton;
	UIButton* equaltoButton;
	UIButton* multiplyButton;
	UIButton* okButton;
	UIButton* dotButton;
	
	NSUInteger temp1;
	
	
	double result;
	NSInteger currentOperation;
	double currentNumber;
	//flagForButton 
	BOOL buttonPressed;
	id __weak refCalDelegate;
	NSString * finalResult;
	
	id __weak refAmountDelegate;
}

@property(nonatomic, weak)id refAmountDelegate;
@property(nonatomic, weak) id refCalDelegate;
@property(nonatomic, strong)  UIView *calView;
@property(nonatomic, strong) UILabel * resultLabel;
@property(nonatomic, strong)NSString * finalResult;

-(void)buttonOperationPressed:(id)sender;
-(void)cancelInput;
-(void)calViewClicked;
@end
