//
//  LoginViewController.h
//  Replicon
//
//  Created by HemaBindu on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "G2RepliconServiceManager.h"
#import "G2Util.h"
#import "FrameworkImport.h"
#import "G2AppProperties.h"
#import "G2Constants.h"
#import "G2ServiceUtil.h"
#import "G2LoginModel.h"
#import "G2PermissionsModel.h"
#import "G2SupportDataModel.h"
#import "G2SyncExpenses.h"
#import "G2ChangePasswordViewController.h"
#import "G2LoginDelegate.h"
#import"G2AppInitService.h"
#import "G2LoginViewCell.h"

enum {
	G2PREVIOUS,
	G2NEXT
};

@interface G2LoginViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, NetworkServiceProtocol>{
	UITableView    *loginTableView;
	UIButton	   *loginButton1;
	NSArray		   *expensesArray;
	UIView		   *headerView;
	UIView		   *footerView;
	NSString	   *companyName,*userName, *passWD,*urlPrefixesStr;
	//LoginModel	   *loginModel;
	//PermissionsModel *permissionsModel;
	G2SyncExpenses *syncExpenses;
	G2ChangePasswordViewController *changePasswordViewController;
	G2LoginDelegate *loginDelegate;
	UIView  *forgotPasswordView;
	UIView  *signUpfreetrialView;
	UILabel *forgotPasswordLabel;
	UILabel *freeTrailLabel;
	
	UIToolbar *toolbar;
	UISegmentedControl *toolbarSegmentControl;
	UITextField *currentTextField;
    NSString                *errorString;
}
@property(nonatomic,strong)  NSString                *errorString;
@property(nonatomic,strong)NSString *companyName,*userName, *passWD;
@property (nonatomic, strong) UITableView *loginTableView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong, setter = setCurrentTextField:)UITextField *currentTextField;
-(void)loginAction:(id)sender;
-(void)forgotPasswordAction:(id)sender;
-(void)signUpAction:(id)sender;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)clearPassword;
-(void)prepopulateUserDetails;
-(void)forgotPasswordURLAction;
-(void)signUpURLAction;
-(G2LoginViewCell *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath;
-(void)createToolbar;
-(void)registerForKeyBoardNotifications;
-(void)changeSegmentControlState:(NSNumber *)row;
-(void)doneClickAction;
-(void)segmentClick:(UISegmentedControl *)segmentControl;
-(void)dehighlightSignUpButton;
-(void)dehighlightForgotPwdButton;
-(void)companyChanged;
@end
