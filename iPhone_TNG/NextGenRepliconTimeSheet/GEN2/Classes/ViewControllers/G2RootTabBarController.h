//
//  RootTabBarController.h
//  Replicon
//
//  Created by Hemabindu on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "G2ListOfExpenseSheetsViewController.h"
#import "G2MoreViewController.h"
#import "G2Constants.h"
#import "G2ListOfTimeSheetsViewController.h"
#import "G2ExpensesNavigationController.h"
#import "G2TimesheetNavigationController.h"
#import "G2ApprovalsNavigationController.h"
#import "G2SettingsNavigationController.h"
#import "G2ApprovalsMainViewController.h"
#import "G2PunchClockViewController.h"

@interface G2RootTabBarController :  UITabBarController<UITabBarControllerDelegate,UIAlertViewDelegate>  {

	//UINavigationController *listOfExpenseSheetsNavController;
	//UINavigationController *listOfTimeSheetsNavController;
	G2SettingsNavigationController *moreNavController;
    G2MoreViewController *moreViewController;
    G2ListOfExpenseSheetsViewController *listOfExpenseSheetsViewController;
    G2ExpensesNavigationController *listOfExpenseSheetsNavController;
    G2ApprovalsNavigationController *approvalsNavController;
    G2ApprovalsMainViewController *approvalsMainViewController;
    G2ListOfTimeSheetsViewController *listOfTimeSheetsViewController;
    G2TimesheetNavigationController *listOfTimeSheetsNavController;
    G2PunchClockViewController *punchClockViewCtrl;
}

@property(nonatomic,strong) G2PunchClockViewController *punchClockViewCtrl;
@property(nonatomic,strong)G2MoreViewController *moreViewController;
@property(nonatomic,strong)G2SettingsNavigationController *moreNavController;
@property(nonatomic,strong) G2ListOfExpenseSheetsViewController *listOfExpenseSheetsViewController;
@property(nonatomic,strong) G2ExpensesNavigationController *listOfExpenseSheetsNavController;
@property(nonatomic,strong) G2ApprovalsNavigationController *approvalsNavController;
@property(nonatomic,strong) G2ApprovalsMainViewController *approvalsMainViewController;
@property(nonatomic,strong)G2ListOfTimeSheetsViewController *listOfTimeSheetsViewController;
@property(nonatomic,strong)G2TimesheetNavigationController *listOfTimeSheetsNavController;
-(BOOL)checkforenabledandrequiredudfs;
-(void)showProgression;
//-(BOOL)userPreferenceSettings:(NSString *)_preference;
@end
