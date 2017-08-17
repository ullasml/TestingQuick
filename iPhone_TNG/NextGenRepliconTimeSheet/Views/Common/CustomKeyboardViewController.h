//
//  CustomKeyboardViewController.h
//  CustomKeyBoard
//
//  Created by Juhi Gautam on 08/03/13.
//  Copyright (c) 2013 Juhi Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol  CustomKeyboardProtocol;
@interface CustomKeyboardViewController : UIViewController{
    id <CustomKeyboardProtocol> __weak entryDelegate;
    IBOutlet UIButton *previousBtn;
    IBOutlet UIButton *nextBtn;
    IBOutlet UIButton *doneBtn;
    IBOutlet UIButton *clearBtn;
}
@property(nonatomic,weak) id <CustomKeyboardProtocol>entryDelegate;
@property(nonatomic,strong) IBOutlet UIButton *previousBtn;
@property(nonatomic,strong) IBOutlet UIButton *nextBtn;
@property(nonatomic,strong) IBOutlet UIButton *doneBtn;
@property(nonatomic,strong) IBOutlet UIButton *clearBtn;

-(IBAction)minsButtonAction:(id)sender;
-(IBAction)amButtonAction:(id)sender;
-(IBAction)pmButtonAction:(id)sender;
-(IBAction)doneButtonAction:(id)sender;
-(IBAction)clearButtonAction:(id)sender;
-(IBAction)nextButtonAction:(id)sender;
-(IBAction)previousButtonAction:(id)sender;
-(void)enableAndDisablePreviousButton:(BOOL)isPrevious andNextButton:(BOOL)isNext;

@end
@protocol CustomKeyboardProtocol <NSObject>

-(void)hoursFieldUpdatedWithText:(NSString*)hoursText andFormat:(NSString*)format;
-(void)minsFieldUpdatedWithText:(NSString*)minText;
-(void)clearButtonPressed;
-(void)doneButtonPressed;
-(void)nextButtonPressed;
-(void)previousButtonPressed;
@end