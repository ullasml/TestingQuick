//
//  ChangePasswordCell.h
//  RepliUI
//
//  Created by Swapna P on 4/5/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface G2ChangePasswordCell : UITableViewCell{
	UITextField *passwordField;
	UITextField *verifyField;

}
-(void)createTextFieldToChangePasswordCell:(NSInteger)row;
@property (nonatomic , strong) 	UITextField *passwordField;
@property (nonatomic , strong) 	UITextField *verifyField;
@end
