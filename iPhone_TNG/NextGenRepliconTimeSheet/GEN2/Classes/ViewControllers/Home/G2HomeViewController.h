//
//  RepliconExpensesSheet.h
//  RepliconHomee
//
//  Created by Hemabindu  on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "G2RepliconServiceManager.h"

#import "G2Util.h"
#import "FrameworkImport.h"
#import "G2ExpensesModel.h"
#import "G2SupportDataModel.h"
#import "G2TimesheetModel.h"
#import "G2MoreViewController.h"
#import "G2Constants.h"
#import "G2AppProperties.h" 
#import "G2PermissionsModel.h"

#import "G2TimeEntryViewController.h"
#import "G2PunchClockViewController.h"

@interface G2HomeViewController : UIViewController <NetworkServiceProtocol>{

	UIButton			*timeSheetButton;
	UIButton			*timeOffButton;
	UIButton			*expensesButton;
	UIButton			*moreButton;
	UIButton			*tnewTimeEntryButton;
    UIButton			*badgeButton;
	//PermissionsModel    *permissionsModel;
	NSString			*expenseEnter;
	NSMutableString			*timeSheetType;
	G2PermissionSet		*permissionsetObj;
	G2Preferences			*preferenceSet;
	
	ProjectPermissionType projPermissionType;
	
	UINavigationController *tnewTimeEntryNavController;
	
	ActionType actionType;
	
	G2TimesheetModel    *timesheetModel;
	//BOOL				  newTimeEntry;
	BOOL udfexists,allUdfExistsFlag;
    G2PunchClockViewController *punchClockViewCtrl;
	BOOL isLockedTimeSheet;
    BOOL isFromTabBar;
    BOOL isNotFirstTimeLoad;
    float xORIGIN,yORIGIN;

}
-(void)customButtonWithModuleName:(NSString *)_name imageName:(NSString *)_imgName xdimension:(int)x ydimension:(int)y tag:(int)_tag;
-(void)newTimeEntryAction;
-(void)timeOffAction;
-(void)expensesAction: (int)tabIndex;			
-(void)moreAction;
-(void)timeSheetAction;
-(void)showNewTimeEntry;
-(BOOL)checkForPermissionExistence:(NSString *)_permission;
-(BOOL)userPreferenceSettings:(NSString *)_preference;
-(void)showListOfExpensesheets;
-(void)checkforenabledSheetLeveludfs;
-(void)checkforenabledudfs;
- (void)customButtonAction:(id)sender;
- (void)timeEntryActionForPunchDetails;
- (void)approvalsAction;
-(void)addBadgeButtonWithNumbers:(int)numberOfPendingTS xorigin:(float)xorigin yorigin:(float)yorigin;
-(void)refreshViewFromViewWillAppear:(BOOL)animated;
//US4591//Juhi
-(void)addNewAdHocTimeOffFromAlert;
-(void)addNewTimeEntryActionFromAlert;
@property(nonatomic,assign) BOOL isNotFirstTimeLoad;
@property(nonatomic,strong)UIButton *tnewTimeEntryButton;
@property(nonatomic,strong)UIButton *timeSheetButton;
@property(nonatomic,strong)UIButton *timeOffButton;
@property(nonatomic,strong)UIButton *expensesButton;
@property(nonatomic,strong)UIButton *moreButton;
@property(nonatomic,strong)UIButton *badgeButton;
@property(nonatomic,strong) NSString *expenseEnter;
@property(nonatomic,strong)UINavigationController *tnewTimeEntryNavController;
@property (nonatomic,assign) BOOL				udfexists,allUdfExistsFlag;
@property(nonatomic,strong)G2PunchClockViewController *punchClockViewCtrl;
@property (nonatomic,assign)	BOOL isLockedTimeSheet;
//-(void)rearrangeModuleIconsUsingPermissionset;
-(void)showProgression;

@end
