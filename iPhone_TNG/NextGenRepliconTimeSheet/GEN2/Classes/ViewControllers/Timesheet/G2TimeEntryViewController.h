//
//  TimeEntryViewController.h
//  Replicon
//
//  Created by vijaysai on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2Util.h"
#import "G2ViewUtil.h"
#import "G2TimeEntryCellView.h"
#import "G2AddDescriptionViewController.h"
#import "G2CustomPickerView.h"
#import "G2ClientProjectTaskViewController.h"
#import "G2TaskViewController.h"
#import "G2TimeSheetEntryObject.h"
#import "G2NavigationTitleView.h"

#import "G2CustomTableHeaderView.h"

#import "G2PermissionSet.h"
#import "G2Preferences.h"
#import "G2CustomTableSectionHeaderView.h"
#import "G2SupportDataModel.h"
#import "G2TimesheetModel.h"
#import "G2EntryCellDetails.h"
#import "G2DataListViewController.h"
@class RepliconAppDelegate;

enum  {
	TIME ,
	PROJECT_INFO,
	COMMENTS
};

@interface G2TimeEntryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DatePickerProtocol,NumericKeyPadProtocol,DataPickerProtocol,G2SegmentControlProtocol,UITextViewDelegate> {	
	
	//Strings
	NSString							*sheetStatus;
																			
	//Views
	G2NavigationTitleView					*topTitleView;
	G2CustomTableHeaderView				*tableHeader;
	G2CustomPickerView			        *customPickerView;
														
	UIView								*footerView;
	UITableView					        *tnewTimeEntryTableView;
														
	//Arrays
	NSMutableArray				        *firstSectionfieldsArr;
	NSMutableArray				        *secondSectionfieldsArray;
	NSMutableArray				        *activitiesArray;
	NSMutableArray				        *billingArray;
	NSMutableArray						*clientsArray;
														
	//Other
	NSIndexPath					        *selectedIndexPath;
	NSInteger							screenMode;
	NSString							*selectedSheetIdentity;
	G2TimeSheetEntryObject				*timeSheetEntryObject;
    G2TimeOffEntryObject				    *timeOffEntryObject;
	G2PermissionSet						*permissionsObj;
	G2Preferences							*preferencesObj;
														
	G2SupportDataModel					*supportDataModel;
	G2TimesheetModel						*timesheetModel;
	G2ClientProjectTaskViewController     *clientProjectTaskViewController;
	id									submissionErrorDelegate;
														
	BOOL								isEntriesAvailable;
	
	UITextField							*lastUsedTextField;
    
    UIActivityIndicatorView             *progressIndicator;
    G2EntryCellDetails                    *rowDtls;
    
    G2AddDescriptionViewController *addDescriptionViewController;
    G2TaskViewController *taskViewController;

    NSString                            *disabledActivityName;
    BOOL                                isFromSave;
    NSString                            *disabledBillingOptionsName;
    UIScrollView                        *mainScrollView;
    NSString                            *disabledDropDownOptionsName;
    BOOL hasClient;
    BOOL                                isInOutFlag,isLockedTimeSheet;
     NSIndexPath                         *hackIndexPathForInOut;
    int                                 countFrame;
    BOOL isNotMatching;
    BOOL isFromDoneClicked,isMovingToNextScreen;
   id __weak customParentDelegate;
//US4275//Juhi
    UITextView *commentsTextView;
    UIButton *deletButton;
    BOOL isComment;
    NSMutableArray *mutilpleJsonRequestArrayForNewInOut;
    NSString *selectedSheet;
    NSMutableArray *timeTypesArray;
    BOOL isTimeOffEntry;
    NSString *disabledTimeOffTypeName;
    BOOL isTimeOffEnabledForTimeEntry;
    BOOL isTimeFieldValueBreak;
    BOOL isFromCancel;
    NSInteger udfsStartIndexNo;//DE8142
    BOOL isCommentsTextFieldClicked;
    G2DataListViewController *dataListViewCtrl;
    int countUDF;
    RepliconAppDelegate                 *appDelegate;
}
@property(nonatomic,assign ) BOOL isCommentsTextFieldClicked;
@property(nonatomic,assign ) BOOL isTimeOffEnabledForTimeEntry,isFromCancel;
@property(nonatomic,strong)  NSString *disabledTimeOffTypeName;
@property(nonatomic,assign )BOOL isTimeOffEntry;
@property(nonatomic,strong) NSMutableArray *timeTypesArray;
@property(nonatomic,assign )BOOL                                isInOutFlag,isLockedTimeSheet,isNotMatching,isFromDoneClicked,isMovingToNextScreen,isComment,isTimeFieldValueBreak;
@property(nonatomic,weak )id customParentDelegate;
@property(nonatomic,strong) NSString                        *disabledBillingOptionsName;
@property(nonatomic,assign )BOOL                                isFromSave;
@property(nonatomic,strong) NSString                        *disabledActivityName;
@property(nonatomic,strong)UIView								*footerView;
@property(nonatomic,strong)G2SupportDataModel					*supportDataModel;
@property(nonatomic,strong)G2TimesheetModel						*timesheetModel;
@property(nonatomic,strong)	G2CustomPickerView			     *customPickerView;
@property(nonatomic,strong)	G2TaskViewController *taskViewController;
@property(nonatomic,strong)	G2AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,strong)	G2EntryCellDetails                *rowDtls;
@property(nonatomic,strong)	UITableView						*tnewTimeEntryTableView;
@property(nonatomic,strong)	G2CustomTableHeaderView			*tableHeader;
@property(nonatomic,strong) NSMutableArray					*firstSectionfieldsArr;
@property(nonatomic,strong) NSMutableArray					*secondSectionfieldsArray;
@property(nonatomic,strong) NSMutableArray					*activitiesArray;
@property(nonatomic,strong)	NSMutableArray					*billingArray;
@property(nonatomic,strong)	NSMutableArray					*clientsArray;
@property(nonatomic,strong)	NSString						*sheetStatus;
@property(nonatomic,strong) NSIndexPath						*selectedIndexPath;
@property(nonatomic,assign) NSInteger						screenMode;
@property(nonatomic,strong) G2TimeSheetEntryObject			*timeSheetEntryObject;
@property(nonatomic,strong) G2TimeOffEntryObject			     *timeOffEntryObject;
@property(nonatomic,strong) G2PermissionSet					*permissionsObj;
@property(nonatomic,strong) G2Preferences						*preferencesObj;
@property(nonatomic,strong) UITextField						*lastUsedTextField;
@property(nonatomic,strong) id								submissionErrorDelegate;
@property(nonatomic,assign) BOOL							isEntriesAvailable;
@property(nonatomic,strong) NSString						*selectedSheetIdentity;
@property(nonatomic,strong) UIActivityIndicatorView         *progressIndicator;
@property(nonatomic,strong) UIScrollView                        *mainScrollView;  
@property(nonatomic,strong) NSString                         *disabledDropDownOptionsName;
@property (nonatomic, assign) BOOL hasClient;
@property(nonatomic,strong) NSIndexPath                         *hackIndexPathForInOut;
//US4275//Juhi
@property(nonatomic,strong)  UITextView *commentsTextView;
@property (nonatomic,strong) UIButton *deletButton;
@property (nonatomic,strong)NSMutableArray *mutilpleJsonRequestArrayForNewInOut;
@property(nonatomic,strong) NSString *selectedSheet;
@property(nonatomic,strong) G2DataListViewController *dataListViewCtrl;
    
- (id)initWithEntryDetails :(id)entryObj sheetId:(NSString *)_sheetIdentity 
				screenMode :(NSInteger)_screenMode permissionsObj :(id)_permissionObj preferencesObj:(id)_preferencesObj :(BOOL) isInOutFlag :(BOOL) isLockedTimeSheet :(id)delegate;
-(void)setProjectDataDetails:(G2EntryCellDetails *)projectDetails;
-(void)buildSecondSectionFieldsArray;
-(void)buildFirstSectionFieldsArray;
-(void)initializeCustomPickerView;
-(void)handleButtonClicks:(NSIndexPath *)selectedButtonIndex :(id)sender;
-(void)selectDataPickerRowBasedOnValues;
-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue;
-(void)updateFieldValueForCell:(G2TimeEntryCellView *)entryCell withSelectedValue:(id)value;
-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex;
-(void)datePickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender;
-(void)dataPickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender;
-(void)numericKeyPadAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender;
-(void)moveToNextScreenAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender;
-(void)updatePickedDateAtIndexPath:(NSIndexPath *)dateIndexPath : (NSDate *) selectedDate;
- (void)nextClickAction:(id )button :(NSIndexPath *)currentIndexPath;
- (void)previousClickAction:(id )button :(NSIndexPath *)currentIndexPath;
- (void)doneClickAction:(id)button :(NSIndexPath *)currentIndexPath;
-(void)changeOfSegmentControlState:(NSIndexPath *)indexpath;
-(void)handleUpdatesForToolbarActions :(NSIndexPath *)currentIndexPath;
//-(void)handleProjectDetailsWhenProjectRemoved :(EntryCellDetails *)projectDetails;
-(void)handleProjectSelection:(NSMutableArray *)projectsArr indexPath :(NSIndexPath *) otherPickerIndexPath row:(int)_row;
-(void)updateBillingFieldForSelectedProjectTask;
-(NSMutableArray *)getBillingOptionsDataSourceArray:(BOOL)isDownloadDataFromAPI;
-(NSNumber *)getBillingRoleIdentity:(NSString *)billingIdentity;
-(NSString *)getBillingIdentityFromSelectedBillingName:(NSString *)selectedValue;
-(NSMutableArray *)getBillingArrayForBillingStatus :(NSString *)billingStatus :(NSString *)projectIdentity;
-(NSString *)getSelectedBillingName:(NSString *)_selectedBillingName;
-(int)getSelectedBillingRowIndex;
-(void)setTaskDetails:(G2EntryCellDetails *)taskDetails;
-(void)resetTaskSelection;
-(void)fetchTasksForSelectedProject;
-(void)updateSelectedTask : (NSString *)taskName : (NSMutableDictionary *)taskDict;
-(void)showTasksForProject;
-(void)enableTaskSelection;
-(void)disableTaskSelection;
-(void)cancelAction:(id)sender;
-(void)saveAction:(id)sender;
-(void)handleAddTimeEntryWithSheetIdentity;
-(void)handleAddTimeEntryWithoutSheetIdentity;
-(void)sendOnlineRequestToEditTimeEntry;
-(void)popToTimeEntriesContentsPage;
-(void)saveEntryForFetchedSheet:(id)notificationObject;
-(void)saveTimeEntryForSheet;
-(void)showListOfTimeEntries;
-(void)fetchTimeSheetAfterSave;
-(void)backButtonAction:(id)sender;
-(void)updateComments:(NSString *)commentsEntered;
-(void)updateUDFText:(NSString *)udfTextEntered;
-(NSIndexPath *)getNextEnabledIndexPath :(NSIndexPath *)currentIndexPath;
-(NSIndexPath *)getPreviousEnabledIndexPath :(NSIndexPath *)currentIndexPath;
-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)animateCellWhichIsSelected;
-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath;
-(void)tableViewCellUntapped:(NSIndexPath*)indexPath animated:(BOOL)_animated;
-(void)hideCustomPickerView;
-(void)createFooterView;
-(void)setNavigationButtonsForScreenMode:(NSInteger )mode;
-(void)deleteAction:(id)sender;
-(void)handleDeleteAction;
-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message title :(NSString *)header;
-(void)setActivityDataDetails:(G2EntryCellDetails *)activityDetails;
-(int)getSelectedActivityRowIndex; 
-(void)setValueForActivitiesonNavigation;
-(int)getSelectedUDFDropDownRowIndex:(NSString *)selectedUDFText andUdfOptionArr:(NSMutableArray *)udfOptionsArray;
-(void)buildUDFDictionary;
-(void)buildInOutTimeSheetsFieldsArray ;
-(void)timePickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender ;
-(void)buildUDFwithUDFArray:(NSArray *)udfsArray;
-(void)validateUDFDateFormat:(NSDictionary *)udfDateDict andCell:(G2EntryCellDetails *)cellDetails andUDFType:(NSString *)udfType;
-(void)moveToNextScreenFromCommentsTextViewClicked;
-(void)createUDFDict:(NSDictionary *)udfDateDict andCell:(G2EntryCellDetails *)cellDetails andUDFType:(NSString *)udfType;
-(NSDate *) convertStringToDesiredDateTimeFormat: (NSString *)dateStr;//US4513 Ullas
-(BOOL)checkIsMidNightCrossOver:(G2TimeSheetEntryObject *)timeSheetEntryObject;//US4513 Ullas
-(void)buildFirstSectionFieldsArrayForTimeOffForAnimation:(BOOL)isAnimation;
-(void)buildSecondSectionFieldsArrayForAnimation:(BOOL)isAnimation;
-(void)buildFirstSectionFieldsArrayForAnimation:(BOOL)isAnimation;
-(void)buildSecondSectionFieldsArrayForTimeOff;

-(void)recalculateScrollViewContentSize;
-(void)setTitleForScreenMode:(NSInteger)mode;
-(void)buildFirstSectionFieldsArrayForTimeOff;
-(int)getSelectedTimeOffTypeRowIndex;
-(void)sendOnlineRequestToEditTimeOffEntry;
-(void)handleAddTimeOffEntryWithoutSheetIdentity;
-(void)handleAddTimeOffEntryWithSheetIdentity;
-(void)saveTimeOffEntryForSheet;
-(void)validateTimeEntryFieldValueInCell;
-(void)setClientDataDetails:(G2EntryCellDetails *)clientDetails;
-(void)showAllProjectswithMoreButton:(id)object;
-(void)showAllClients;
-(void)fetchAllClientsFormDatabaseOrAPI;
-(void)fetchAllProjectsFormDatabaseOrAPI;
- (void)userBillingOptionsFinishedDownloadingForEditing;
//DE8906//JUHI
-(void)updateUDFNumber:(NSString *)UdfNumberEntered;
-(void)showCustomPickerIfApplicable:(UITextField *)textField;
@end
