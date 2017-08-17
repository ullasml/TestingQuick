//
//  ChangePasswordViewController.h
//  RepliUI
//
//  Created by Swapna P on 4/5/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ChangePasswordCell.h"
#import "G2Constants.h"
#import "G2Util.h"
#import "G2RepliconServiceManager.h"
#import "G2LoginDelegate.h"

enum CHANGEPASSWORD_ATTRIBUTES {
	PASSWORD,
	VERIFY
};

@interface G2ChangePasswordViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,G2ServerResponseProtocol> {

	UITableView *changePasswordTableView;
	UIView		*sectionHeader;
	UILabel		*enterNewPasswordLabel;
	UIButton	*changePasswordButton;
	UIButton	*rightButton;
	NSString    *passwordStr;
	NSString    *verifyStr;
	G2LoginDelegate *loginDelegate;

}
-(void)changePasswordAction;
-(void)changePasswordCancelAction;
-(void)validateFields;
-(void)confirmationAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message;
-(void)submitAction;
-(void)handleChangePasswordResponse:(id)response;
-(void)showErrorAlert:(NSError *) error;

@property (nonatomic , strong) UITableView *changePasswordTableView;
@property (nonatomic , strong) UIButton	*changePasswordButton;
@property (nonatomic , strong) NSString    *passwordStr;
@property (nonatomic , strong) NSString    *verifyStr;
@property (nonatomic , strong)	G2LoginDelegate *loginDelegate;

@end
