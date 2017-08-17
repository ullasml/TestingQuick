//
//  ApprovalsUsersListOfTimeEntriesViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2Constants.h"
#import "G2CustomTableViewCell.h"
#import "FrameworkImport.h"
#import "G2Util.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeEntryViewController.h"
#import "G2ClientProjectTaskViewController.h"
#import "G2NavigationTitleView.h"
#import "G2EntriesTableFooterView.h"
#import "G2TimeSheetObject.h"
#import "G2TimeOffEntryObject.h"
#import "G2Preferences.h"
#import "G2PermissionSet.h"
#import "G2BookedTimeOffEntry.h"
#import "G2ViewUtil.h"
#import "G2ApprovalTablesFooterView.h"
#import "G2ApprovalTablesHeaderView.h"


@protocol approvalUsersListOfTimeEntriesViewControllerDelegate;
@interface G2ApprovalsUsersListOfTimeEntriesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,approvalTablesFooterViewDelegate,approvalTablesHeaderViewDelegate>
{
	//Labels
	UILabel								*innerTopToolbarLabel;
	UILabel								*topToolbarlabel;
    //	UILabel								*deleteUnderlineLabel;
	UILabel								*sectionHeaderlabel;
	UILabel								*sectionHeadertotalhourslabel;
	UILabel								*descriptionLabel;
	
	
	//Strings
	NSString							*selectedSheet;
	NSString							*totalHours;
	NSString							*sheetApprovalStatus;
	NSString							*sheetIdentity;
    
	//Views
	UITableView					*timeEntriesTableView;
	//TimeSheetCellView			*cell;
	G2CustomTableViewCell			*cell;
	//UIView					*sectionHeader;
	UIImageView					*sectionHeader;
	UIView						*footerView;
	UIView                      *footerButtonsView;
	UIView                      *totallabelView;
	
	UIView		*customFooterView;
															
	
	G2NavigationTitleView			*topTitleView;
	
	

	
	//Arrays
	NSMutableArray				*projectsArr;
	NSMutableArray				*clientsArr;
	NSMutableArray				*keyArray;
	
	//Dictionaries
	NSMutableDictionary			*timeEntryObjectsDictionary;
	NSMutableDictionary			*missingRequiredFields;
	NSMutableDictionary         *countRowsDict;															
	
	//Boolean
    BOOL                      isEntriesAvailable;
    BOOL						againstProjects;
    BOOL						notAgainstProjects;
    BOOL						Both;
    BOOL						activitiesEnabled;
    BOOL						allowBlankComments;
    BOOL						unsubmitAllowed;
	
	//Others
	G2ApprovalsModel				*approvalsModel;
	
	G2TimeSheetObject				*timeSheetObj;
	G2Preferences					*preferencesObj;
	G2PermissionSet				*permissionsObj;
	NSIndexPath					*rowTapped;
    NSString                    *selectedEntriesIdentity;  
    G2TimeEntryViewController         *timeEntryViewController;                                                             
    UINavigationController       *navcontroller;
    BOOL         isInOutFlag,isLockedTimeSheet;

    
    id <approvalUsersListOfTimeEntriesViewControllerDelegate> __weak delegate;
    
    UILabel                             *mealHeaderLabel;
    UIView *customView;
    BOOL                        showMealCustomView;
    
    //US4637//Juhi
    
    BOOL                        isShortenRows;
}
-(void)createTimeEntryFooterView:(NSString *)sheetStatus;


-(NSString *)checkMealFlag:(NSInteger)value;
-(void)addTotalHourslable;
/*-(void)createTimeEntryObject:(TimeSheetObject*)timesheetobject 
 permissions:(NSMutableDictionary *)permissionDict;*/

-(void)createTimeEntryObject:(G2TimeSheetObject*)timesheetobject 
				 permissions:(G2PermissionSet *)permissionsObject
				 preferences:(G2Preferences *)preferenceSetObject;


-(NSString *)getFormattedEntryDateString:(NSString *)_stringdate;




-(G2CustomTableViewCell*)getTappedRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)highlightTappedRowBackground:(NSIndexPath*)indexPath;
-(void)deSelectTappedRow;

@property(nonatomic,strong) UILabel                             *mealHeaderLabel;
@property(nonatomic,strong) UIView *customView;
@property(nonatomic,assign) BOOL                        showMealCustomView;
@property(nonatomic,strong) UIView		*customFooterView;
@property(nonatomic,strong) UIImageView					*sectionHeader;
@property(nonatomic,strong) UIView						*footerView;
@property(nonatomic,assign) NSInteger currentViewTag;
@property(nonatomic,strong) NSMutableArray				*projectsArr;
@property(nonatomic,strong) NSMutableArray				*clientsArr;
@property(nonatomic,strong) UINavigationController       *navcontroller;
@property(nonatomic,strong) G2TimeSheetObject				*timeSheetObj;
@property(nonatomic,strong) G2ApprovalsModel				*approvalsModel;
@property(nonatomic,strong) G2Preferences					*preferencesObj;
@property(nonatomic,strong) G2PermissionSet				*permissionsObj;
@property(nonatomic,strong)  G2TimeEntryViewController      *timeEntryViewController;
@property(nonatomic,strong)  UITableView          *timeEntriesTableView;
@property(nonatomic,strong) NSString              *selectedEntriesIdentity; 
@property(nonatomic,strong)  UILabel              *innerTopToolbarLabel;
@property(nonatomic,strong)  UILabel              *topToolbarlabel;
@property(nonatomic,strong)  UILabel		       *descriptionLabel;
@property(nonatomic,strong)  UILabel              *sectionHeaderlabel;
@property(nonatomic,strong)  UILabel			   *sectionHeadertotalhourslabel;

@property(nonatomic,strong)	 NSMutableDictionary  *timeEntryObjectsDictionary;
@property(nonatomic,strong)  NSMutableDictionary  *missingRequiredFields;
@property(nonatomic,strong)  NSMutableArray		  *keyArray;
@property(nonatomic,strong)  NSMutableDictionary		  *countRowsDict;
//@property(nonatomic,retain)  NSMutableDictionary  *setOfPermissions;

@property(nonatomic,strong) NSIndexPath			  *rowTapped;

@property(nonatomic,strong)  NSString             *selectedSheet;
@property(nonatomic,strong)  NSString			  *totalHours;
@property(nonatomic,strong)  NSString			  *sheetIdentity;
@property(nonatomic,strong)  NSString			  *sheetApprovalStatus;

@property(nonatomic,assign)  BOOL                 isEntriesAvailable;
@property(nonatomic,assign)  BOOL				  againstProjects;
@property(nonatomic,assign)  BOOL				  notAgainstProjects;
@property(nonatomic,assign)  BOOL				  Both;
@property(nonatomic,assign)  BOOL				  activitiesEnabled;
@property(nonatomic,assign)  BOOL				  allowBlankComments;
@property(nonatomic,assign)  BOOL                 isInOutFlag,isLockedTimeSheet;

@property(nonatomic,assign)  BOOL                        isShortenRows;

@property(nonatomic,weak)id <approvalUsersListOfTimeEntriesViewControllerDelegate> delegate;
//US4637//Juhi
@property (nonatomic,assign)NSUInteger                         totalNumberOfView;
@property (nonatomic,assign)NSInteger                         currentNumberOfView;

-(void)viewWillAppearFromApprovalsTimeEntry;
- (void)setDescription:(NSString *)description;
-(void)readjustScrollView;



@end


@protocol approvalUsersListOfTimeEntriesViewControllerDelegate <NSObject>

@optional
- (void)handleApproverCommentsForSelectedUser:(G2ApprovalsUsersListOfTimeEntriesViewController *)approvalsUsersListOfTimeEntriesViewController;
- (void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag;
- (void)pushToTomeEntryViewController:(id)timeEntryViewController;
-(void)readjustScrollViewWithIndex:(NSInteger)index;

@end
