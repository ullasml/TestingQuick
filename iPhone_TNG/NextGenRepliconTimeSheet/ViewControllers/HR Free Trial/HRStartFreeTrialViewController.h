//
//  HRStartFreeTrialViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface HRStartFreeTrialViewController : UIViewController<UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) IBOutlet UIButton        *signUpButton;
@property (nonatomic, weak) IBOutlet UIButton        *termsButton;
@property (nonatomic, assign)CGRect scrollViewFrame;
@property (nonatomic,strong) NumberKeypadDecimalPoint *numberKeyPad;
-(IBAction)signUPButtonAction:(id)sender;

@end
