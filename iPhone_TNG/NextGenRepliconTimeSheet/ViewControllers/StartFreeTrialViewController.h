//
//  StartFreeTrialViewController.h
//  Replicon
//
//  Created by Abhishek Nimbalkar on 5/5/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface StartFreeTrialViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) IBOutlet UIButton        *signUpButton;
@property (nonatomic, weak) IBOutlet UIButton        *termsButton;
@property (nonatomic, assign)CGRect scrollViewFrame;
@property (nonatomic,strong) NumberKeypadDecimalPoint *numberKeyPad;
-(IBAction)signUPButtonAction:(id)sender;

@end
