//
//  AdhocTimeOffViewController.h
//  Replicon
//
//  Created by Hepciba on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2Util.h"
#import "G2ViewUtil.h"
#import "G2TimeEntryCellView.h"
#import "G2AddDescriptionViewController.h"
#import "G2CustomPickerView.h"


#import "G2TimeOffEntryObject.h"
#import "G2NavigationTitleView.h"

#import "G2CustomTableHeaderView.h"

#import "G2PermissionSet.h"
#import "G2Preferences.h"
#import "G2CustomTableSectionHeaderView.h"
#import "G2SupportDataModel.h"
#import "G2TimesheetModel.h"
#import "G2EntryCellDetails.h"
@class RepliconAppDelegate;


enum ADHOC_TIMEOFF_G2 {
	
	ADHOCTIME,
	ADHOC_PROJECT_INFO,
	ADHOC_COMMENTS
};
enum ADHOC_PREVIOUS_NEXT {	
	ADHOC_PREVIOUS,
	ADHOC_NEXT
};

@interface G2AdhocTimeOffViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DatePickerProtocol,NumericKeyPadProtocol,DataPickerProtocol,G2SegmentControlProtocol,UITextViewDelegate> {

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

    
	//Other
	NSIndexPath					        *selectedIndexPath;
	NSInteger							screenMode;
	NSString							*selectedSheetIdentity;
	G2TimeOffEntryObject				*timeOffEntryObject;
	G2PermissionSet						*permissionsObj;
	G2Preferences							*preferencesObj;
    
	G2SupportDataModel					*supportDataModel;
	G2TimesheetModel						*timesheetModel;
	id									submissionErrorDelegate;
    
	BOOL								isEntriesAvailable;
	
	UITextField							*lastUsedTextField;
    

    G2EntryCellDetails                    *rowDtls;
    
    G2AddDescriptionViewController *addDescriptionViewController;
    

    BOOL                                isFromSave;

    UIScrollView                        *mainScrollView;
    NSString                            *disabledDropDownOptionsName;
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
    NSString *selectedSheet;
    NSMutableArray *timeOffTypesArray;
    NSString *disabledTimeOffTypeName;
    int countUDF;
    RepliconAppDelegate                 *appDelegate;
}
@property(nonatomic,assign )BOOL                                isInOutFlag,isLockedTimeSheet,isNotMatching,isFromDoneClicked,isMovingToNextScreen,isComment;
@property(nonatomic,weak )id customParentDelegate;

@property(nonatomic,assign )BOOL                                isFromSave;

@property(nonatomic,strong)UIView								*footerView;
@property(nonatomic,strong)G2SupportDataModel					*supportDataModel;
@property(nonatomic,strong)G2TimesheetModel						*timesheetModel;
@property(nonatomic,strong)	G2CustomPickerView			     *customPickerView;
@property(nonatomic,strong)	G2AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,strong)	G2EntryCellDetails                *rowDtls;
@property(nonatomic,strong)	UITableView						*tnewTimeEntryTableView;
@property(nonatomic,strong)	G2CustomTableHeaderView			*tableHeader;
@property(nonatomic,strong) NSMutableArray					*firstSectionfieldsArr;
@property(nonatomic,strong) NSMutableArray					*secondSectionfieldsArray;

@property(nonatomic,strong)	NSString						*sheetStatus;
@property(nonatomic,strong) NSIndexPath						*selectedIndexPath;
@property(nonatomic,assign) NSInteger						screenMode;
@property(nonatomic,strong) G2TimeOffEntryObject			*timeOffEntryObject;
@property(nonatomic,strong) G2PermissionSet					*permissionsObj;
@property(nonatomic,strong) G2Preferences						*preferencesObj;
@property(nonatomic,strong) UITextField						*lastUsedTextField;
@property(nonatomic,strong) id								submissionErrorDelegate;
@property(nonatomic,assign) BOOL							isEntriesAvailable;
@property(nonatomic,strong) NSString						*selectedSheetIdentity;

@property(nonatomic,strong) UIScrollView                        *mainScrollView;  
@property(nonatomic,strong) NSString                         *disabledDropDownOptionsName;

@property(nonatomic,strong) NSIndexPath                         *hackIndexPathForInOut;
//US4275//Juhi
@property(nonatomic,strong)  UITextView *commentsTextView;
@property(nonatomic,strong) NSString *selectedSheet;
@property (nonatomic,strong) UIButton *deletButton;
@property (nonatomic,strong)  NSMutableArray *timeOffTypesArray;
@property (nonatomic,strong)  NSString *disabledTimeOffTypeName;

- (id)initWithEntryDetails :(G2TimeOffEntryObject *)entryObj sheetId:(NSString *)_sheetIdentity
				screenMode :(NSInteger)_screenMode permissionsObj:(id)_permissionObj preferencesObj:(id)_preferencesObj InOutFlag:(BOOL) InOutFlag LockedTimeSheet:(BOOL) LockedTimeSheet delegate:(id)delegate;

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
-(void)cancelAction:(id)sender;
-(void)saveAction:(id)sender;
-(void)handleAddTimeEntryWithSheetIdentity;
-(void)handleAddTimeOffEntryWithoutSheetIdentity;
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
-(int)getSelectedUDFDropDownRowIndex:(NSString *)selectedUDFText andUdfOptionArr:(NSMutableArray *)udfOptionsArray;
-(void)buildUDFDictionary;
-(void)timePickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender ;
-(void)buildUDFwithUDFArray:(NSArray *)udfsArray;
-(void)validateUDFDateFormat:(NSDictionary *)udfDateDict andCell:(G2EntryCellDetails *)cellDetails andUDFType:(NSString *)udfType;
-(void)moveToNextScreenFromCommentsTextViewClicked;
-(void)createUDFDict:(NSDictionary *)udfDateDict andCell:(G2EntryCellDetails *)cellDetails andUDFType:(NSString *)udfType;
-(int)getSelectedTimeOffTypeRowIndex;
-(void)setValueForDropDownNavigation;
-(void)setTimeOffTypeDataDetails:(G2EntryCellDetails *)timeoffTypeDetails ;
@end
