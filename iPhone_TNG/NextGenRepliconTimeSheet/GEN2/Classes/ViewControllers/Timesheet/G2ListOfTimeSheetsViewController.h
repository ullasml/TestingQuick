//
//  ListOfTimeSheetsViewController.h
//  Replicon
//
//  Created by Hepciba on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2TimeSheetCellView.h"
#import "G2ListOfTimeEntriesViewController.h"
#import "G2TimeEntryViewController.h"
#import "G2Util.h"
#import "G2TimeSheetObject.h"
#import "G2SupportDataModel.h"
#import "G2PermissionSet.h"
#import "G2Preferences.h"
#import "G2CustomTableViewCell.h"

@interface G2ListOfTimeSheetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
	//Buttons
	UIButton								*moreButton;
	UIBarButtonItem							*leftButton;
	
	//Labels
	
	//Views
	UITableView								*timeSheetsTableView;
	UIView									*footerView;
	UIImageView								*imageView;
	//TimeSheetCellView						*cell;
	G2CustomTableViewCell						*cell;
	
	//Arrays
	NSMutableArray							*timeSheetsArray;
	
	//Bool
	BOOL									againstProjects;
	BOOL									both;
	BOOL									notagainstProjects;
	BOOL									activitiesEnabled;
	BOOL									allowComments;
	BOOL									unsubmitAllowed;
	BOOL									billingTimesheet;
	BOOL									useBillingInfo;
	
	//Strings
	NSString								*hourFormat;
	NSString								*dateformat;
	
	//Dicitionary
	
	//Other
	G2ListOfTimeEntriesViewController			*timeEntriesViewController;
	G2TimeEntryViewController					*addNewTimeEntryViewController;
	//TimesheetModel							*timesheetModel;
	//PermissionsModel						*permissionsModel;
	//SupportDataModel						*supportDataModel;
	G2PermissionSet							*permissionsetObj;
	G2Preferences								*preferenceSet;
	NSIndexPath								*rowIndex;
	NSIndexPath								*rowTapped;
    UINavigationController                  *navcontroller;
}
-(void)goBack:(id)sender;
-(void)moreAction:(id)sender;
-(void)displayAllTimeSheets;
-(NSMutableString *)getProjectActivityList:(NSMutableArray *)_list;
-(BOOL)userPreferenceSettings:(NSString *)preference;
-(BOOL)checkForPermissionExistence:(NSString *)permission;

-(void)highlightTappedRowBackground:(NSIndexPath*)indexPath;
-(void)deSelectTappedRow;
-(G2CustomTableViewCell*)getTappedRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)highlightTheCellWhichWasSelected;
-(void)showAddNewTimeEntryPageByDefault:(G2TimeSheetObject *)timeSheetObject :(NSString *)selectedSheet;
-(void)newEntrySavedResponse;
-(void)addTimeEntryAction:(id)sender;
- (void)hideEmptySeparators;
-(void)addNewTimeEntryActionFromAlert;

@property (nonatomic,strong)G2PermissionSet							*permissionsetObj;
@property (nonatomic,strong)G2Preferences								*preferenceSet;
@property (nonatomic,strong) G2TimeEntryViewController	*addNewTimeEntryViewController;
@property (nonatomic,strong) UINavigationController                  *navcontroller;
@property (nonatomic,strong) G2ListOfTimeEntriesViewController			*timeEntriesViewController;
@property (nonatomic,strong) UITableView				*timeSheetsTableView;
@property (nonatomic,strong) UIView						*footerView;
@property (nonatomic,strong) UIImageView				*imageView;
@property (nonatomic,strong) NSMutableArray				*timeSheetsArray;

@property (nonatomic,strong) UIBarButtonItem			*leftButton;
@property (nonatomic,strong) UIButton *moreButton;
//@property (nonatomic,retain) TimesheetModel				*timesheetModel;

@property (nonatomic,assign) BOOL						againstProjects;
@property (nonatomic,assign) BOOL						both;
@property (nonatomic,assign) BOOL						notagainstProjects;
@property (nonatomic,assign) BOOL						activitiesEnabled;
@property (nonatomic,assign) BOOL						allowComments;
@property (nonatomic,assign) BOOL						unsubmitAllowed;
@property (nonatomic,assign) BOOL						billingTimesheet;
@property (nonatomic,assign) BOOL						useBillingInfo;
@property (nonatomic,strong) NSString					*hourFormat;
@property (nonatomic,strong) NSString					*dateformat;
@property (nonatomic,strong) NSIndexPath				*rowTapped,*rowIndex;

@end
