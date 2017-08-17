//
//  MoreViewController.h
//  Replicon
//
//  Created by Manoj  on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
 #import <MessageUI/MessageUI.h>
#import"G2MoreCellView.h"
#import"G2LoginPreferencesViewController.h"
#import"G2TransitionPageViewController.h"
#import"G2LoginViewController.h"
#import"G2ViewUtil.h"

/*typedef enum rememberPasswordTypes	{
 remPwd_Never = 1,
 remPwd_1day,
 remPwd_1week,
 remPwd_2weeks,
 remPwd_1month
 } RememberPasswordTypes;
 
 #define rememberPwdTypesArray @"Never",@"1 day",@"1 week",@"2 weeks",@"1 month",nil*/

@interface G2MoreViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NetworkServiceProtocol,MFMailComposeViewControllerDelegate>{
	
	UITableView *preferencesTable;
	UIButton    *logOutButton;
	NSIndexPath *currentIndexPath;
	NSMutableDictionary *loginPreferencesDict;
	G2LoginPreferencesViewController *loginPreferencesViewController;
         BOOL isRememberPasswordClicked;
}
-(void)logoutClicked;
-(void)networkActivated;
//-(void)tableViewCellUntapped:(NSIndexPath *)indexPath;
-(void)animateCellWhichIsSelected;
-(void)getLoginPreferencesFromLoginTable;
-(void)updateRememberPwdInLoginTable:(NSNumber*)number;
-(void)updateSwitchMark:(id)sender;
-(void)updateLoginTable:(NSMutableDictionary*)data;
-(void)updateSelectedRow:(NSIndexPath*)indexPath withNewSwitchValue:(int)value;
-(void)updateRememberPwdCell:(G2MoreCellView*)cell :(BOOL)disable;
-(BOOL)disableRememberPwdField;
-(void)reviewClicked;//US4800
//-(void)rememberPasswordSelected:(NSIndexPath *)indexPath;
@property  BOOL isRememberPasswordClicked,isInToggleUpdateProcess;
@property(nonatomic,strong)	UITableView *preferencesTable;
@property(nonatomic,strong) UIButton    *logOutButton;
@property(nonatomic,strong) NSIndexPath *currentIndexPath;
@property(nonatomic,strong)	NSMutableDictionary *loginPreferencesDict;
@property(nonatomic,strong) G2LoginPreferencesViewController *loginPreferencesViewController;
@end
