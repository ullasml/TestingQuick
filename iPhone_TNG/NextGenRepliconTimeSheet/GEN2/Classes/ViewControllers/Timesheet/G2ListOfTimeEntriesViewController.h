//
//  ListOfTimeEntriesViewController.h
//  Replicon
//
//  Created by Hepciba on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2Constants.h"
//#import "TimeSheetCellView.h"
#import "G2CustomTableViewCell.h"
#import "FrameworkImport.h"
#import "G2Util.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeEntryViewController.h"
#import "G2SubmittedDetailsView.h"
#import "G2ClientProjectTaskViewController.h"
#import "G2NavigationTitleView.h"
#import "G2SubmissionErrorViewController.h"
#import "G2EntriesTableFooterView.h"
#import "G2TimeSheetObject.h"
#import "G2TimeOffEntryObject.h"
#import "G2ResubmitTimesheetViewController.h"
#import "G2Preferences.h"
#import "G2PermissionSet.h"
#import "G2BookedTimeOffEntry.h"
#import "G2ViewUtil.h"


@interface G2ListOfTimeEntriesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,
															EntriesFooterButtonsProtocol> {
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
	//TimeSheetCellView			*cell;
	G2CustomTableViewCell			*cell;
	//UIView					*sectionHeader;
	UIImageView					*sectionHeader;
	UIView						*footerView;
	UIView                      *footerButtonsView;
	UIView                      *totallabelView;
	G2SubmittedDetailsView        *submittedDetailsView;
	G2EntriesTableFooterView		*customFooterView;
	G2ResubmitTimesheetViewController *resubmitViewController;															
	
	G2NavigationTitleView			*topTitleView;
	
	
//	//Buttons
//	UIButton					*submitButton;
//	UIButton					*deleteButton;
	
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
	G2TimesheetModel				*timesheetModel;
	
	G2TimeSheetObject				*timeSheetObj;
	G2Preferences					*preferencesObj;
	G2PermissionSet				*permissionsObj;
	NSIndexPath					*rowTapped;
    NSString                    *selectedEntriesIdentity;  
    G2TimeEntryViewController      *timeEntryViewController;                                                             
    UINavigationController       *navcontroller;
    BOOL         isInOutFlag,isLockedTimeSheet;
    UIActivityIndicatorView *progressView;
   
                                                                
   UILabel                             *mealHeaderLabel;
   UIView *customView;
   BOOL                        showMealCustomView;
                                                                
  BOOL  isShortenRows;

  BOOL isUnsubmitClicked;

}


-(void)createTimeEntryFooterView;
-(void)addTimeEntryAction:(id)sender;
-(void)goToTimeSheets:(id)sender;
-(void)confirmAlert:(NSString *)_buttonTitle confirmMessage:(NSString*) message;
-(void)addTotalHourslable;
/*-(void)createTimeEntryObject:(TimeSheetObject*)timesheetobject 
				 permissions:(NSMutableDictionary *)permissionDict;*/

-(void)createTimeEntryObject:(G2TimeSheetObject*)timesheetobject 
				 permissions:(G2PermissionSet *)permissionsObject
				 preferences:(G2Preferences *)preferenceSetObject;


-(NSString *)getFormattedEntryDateString:(NSString *)_stringdate;
-(void)validateRequiredFields;
-(BOOL)validateSheetLevelUDFs;
-(void) getApprovalHistoryForSheetAndShowFooterView;
-(void)showRequiredSheetUDFAlert:(NSString *)udfName;
-(G2CustomTableViewCell*)getTappedRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)highlightTappedRowBackground:(NSIndexPath*)indexPath;
-(void)deSelectTappedRow;
-(void)disclaimerRequestServer;
-(void)revertRadioButton;
-(void)addNewTimeEntryActionFromAlert;
-(NSString *)checkMealFlag:(NSInteger)value;
@property(nonatomic,weak)IBOutlet UITableView *timeEntriesTableView;
@property(nonatomic,strong) G2EntriesTableFooterView		*customFooterView;
@property(nonatomic,strong) UIImageView					*sectionHeader;
@property(nonatomic,strong) UIView						*footerView;
@property(nonatomic,strong) G2ResubmitTimesheetViewController *resubmitViewController;	
@property(nonatomic,strong) NSMutableArray				*projectsArr;
@property(nonatomic,strong) NSMutableArray				*clientsArr;
@property(nonatomic,strong) UINavigationController       *navcontroller;
@property(nonatomic,strong) G2TimeSheetObject				*timeSheetObj;
@property(nonatomic,strong) G2TimesheetModel				*timesheetModel;
@property(nonatomic,strong) G2Preferences					*preferencesObj;
@property(nonatomic,strong) G2PermissionSet				*permissionsObj;
@property(nonatomic,strong)  G2TimeEntryViewController      *timeEntryViewController;
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
@property(nonatomic,strong)  UIView  *progressView;


@property(nonatomic,strong) UILabel                             *mealHeaderLabel;
@property(nonatomic,strong) UIView *customView;
@property(nonatomic,assign) BOOL                        showMealCustomView;
@property(nonatomic,assign) BOOL  isShortenRows;
@property(nonatomic,assign) BOOL  isUnsubmitClicked;//US4805



@end
