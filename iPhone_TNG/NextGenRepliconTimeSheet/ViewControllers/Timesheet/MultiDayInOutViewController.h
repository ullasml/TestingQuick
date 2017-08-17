//
//  MultiDayInOutViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Util.h"
#import "AppDelegate.h"
#import "CustomKeyboardViewController.h"
#import "DropDownViewController.h"
#import "ExtendedInOutCell.h"
#import "InOutTimesheetEntry.h"
#import "ExtendedInOutEntryViewController.h"

@interface MultiDayInOutViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CustomKeyboardProtocol,UpdateDropDownFieldProtocol,UIAlertViewDelegate,InOutTimesheetEntryCellDelegate,InOutEntryCellClickDelegate>

{
    UITableView *multiDayTimeEntryTableView;
    NSMutableArray *timesheetEntryObjectArray;
    id __weak	lastUsedTextField;
    id __weak  lastUsedTextView;
    NSIndexPath *currentIndexpath;
    BOOL isTableRowSelected;
    NSMutableArray *sickRowIndexPathArray;
    BOOL isTextFieldClicked;
    BOOL isUDFieldClicked;
    UIToolbar *toolbar;
    NSIndexPath *selectedIndexPath;
    int numberOfInOutRows;
    int numberOfSickRows;
    CustomKeyboardViewController *customKeyboardVC;
    NSString *formatString;
    NSString *hourString;
    NSString *minsString;
    NSString *timeString;
    int lastButtonTag;
    int firstButtonTag;
    NSString *inTimeTotalString;
    NSString *outTimeTotalString;
    NSString *previousCrossOutTime;
    NSMutableArray *nextCrossIntime;
    BOOL isOverlap;
    NSString *multiDayTimesheetStatus;
    BOOL isInOutBtnClicked;
    id __weak controllerDelegate;
    id __weak approvalsDelegate;
    id __weak parentDelegate;
    int selectedDropdownUdfIndex;
    int selectedTextUdfIndex;
    BOOL isOverlapEntryAllowed;//Implemented For overlappingTimeEntriesPermitted Persmisson
    NSMutableArray *timesheetDataArray;
    int multiInOutTimesheetType;
    UIView *extendedHeaderView;
    int numberofExtendedInOutRows;
    UITapGestureRecognizer *gesture;
    NSString *timesheetURI;
    NSDate *currentPageDate;
    NSMutableArray *suggestionDetailsDBArray;
    BOOL isFromSuggestionViewClickedReload;
    NSMutableArray *inoutTsObjectsArray;
    InOutTimesheetEntry *inOutTimesheetEntry;
}
@property(nonatomic,weak)id __weak approvalsDelegate;
@property(nonatomic,weak) id __weak parentDelegate;
@property(nonatomic,strong)UITableView *multiDayTimeEntryTableView;
@property(nonatomic,strong)NSMutableArray *timesheetEntryObjectArray;
@property(nonatomic,weak)id lastUsedTextField;
@property(nonatomic,weak)id  lastUsedTextView;
@property(nonatomic,strong)NSIndexPath *currentIndexpath;
@property(nonatomic,assign)BOOL isTableRowSelected;
@property(nonatomic,strong)NSMutableArray *sickRowIndexPathArray;
@property(nonatomic,assign)BOOL isTextFieldClicked;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,assign)int numberOfInOutRows;
@property(nonatomic,assign)int numberOfSickRows;
@property(nonatomic,strong)CustomKeyboardViewController *customKeyboardVC;
@property(nonatomic,strong)NSString *formatString;
@property(nonatomic,strong)NSString *hourString;
@property(nonatomic,strong)NSString *minsString;
@property(nonatomic,strong)NSString *timeString;
@property(nonatomic,assign)NSInteger selectedButtonTag;
@property(nonatomic,assign)NSInteger currentSelectedButtonRow;
@property(nonatomic,assign)int lastButtonTag;
@property(nonatomic,assign)int firstButtonTag;
@property(nonatomic,strong)NSString *inTimeTotalString;
@property(nonatomic,strong)NSString *outTimeTotalString;
@property(nonatomic,assign)BOOL isUDFieldClicked;
@property(nonatomic,strong)NSString *previousCrossOutTime;
@property(nonatomic,strong)NSMutableArray *nextCrossIntime;
@property(nonatomic,strong)NSString *multiDayTimesheetStatus;
@property(nonatomic,assign)BOOL isInOutBtnClicked;
@property(nonatomic,assign)BOOL isOverlap;
@property(nonatomic,weak)id controllerDelegate;
@property(nonatomic,assign)int selectedDropdownUdfIndex;
@property(nonatomic,assign)int selectedTextUdfIndex;
//Implemented For overlappingTimeEntriesPermitted Persmisson
@property(nonatomic,assign)BOOL isOverlapEntryAllowed;
@property(nonatomic,strong)NSMutableArray *timesheetDataArray;
@property(nonatomic,assign)int multiInOutTimesheetType;
@property(nonatomic,strong)UIView *extendedHeaderView;
@property(nonatomic,strong)UITapGestureRecognizer *gesture;
@property(nonatomic,strong)NSString *timesheetURI;
@property(nonatomic,strong)NSDate *currentPageDate;
@property(nonatomic,strong)NSMutableArray *suggestionDetailsDBArray;
@property(nonatomic,assign)BOOL isFromSuggestionViewClickedReload;
@property(nonatomic,strong)NSMutableArray *inoutTsObjectsArray;
@property(nonatomic,strong)InOutTimesheetEntry *inOutTimesheetEntry;
@property(nonatomic,assign)BOOL isSuggestionTapped;
@property(nonatomic,assign)int overlapRow;
@property(nonatomic,assign)int overlapSection;
@property(nonatomic,assign)BOOL overlapFromInTime;
@property(nonatomic,assign)BOOL overlapFromOutTime;
@property(nonatomic,assign)int sectionBeingEdited;
@property(nonatomic,assign)int rowBeingEdited;
@property(nonatomic,strong)UILabel *totalLabelHoursLbl;
@property(nonatomic,strong)UIView *totallabelView;
@property(nonatomic,assign)int editTextFieldTag;
@property(nonatomic,assign)BOOL isOverlapOnReverseLogic;
@property(nonatomic,assign)BOOL isGen4UserTimesheet,isGen4RequestInQueue,isNavigation;
@property(nonatomic,strong)NSIndexPath *currentlyBeingEditedCellIndexpath;

-(void)handleButtonClick:(NSIndexPath*)selectedIndex;
-(void)resetTableSize:(BOOL)isResetTable isTextFieldOrTextViewClicked:(BOOL)isTextViewClicked isUdfClicked:(BOOL)isUdfClicked;
-(void)doneAction:(BOOL)shouldTextColorChangeToWhite sender:(id)sender;
-(void)updateTimeEntryHoursForIndex:(NSInteger)index withValue:(NSString *)value withoutRoundOffValue:(NSString *)withoutRoundOffValue isDoneClicked:(BOOL)isDoneClicked;
-(void)updateTimeEntryCommentsForIndex:(NSInteger)index withValue:(NSString *)value;

-(void)addTimeEntryRowAction;
-(BOOL)launchMultiInOutTimeEntryKeyBoard:(id)sender withRowClicked:(NSUInteger)row;
-(void)removeMultiInOutTimeEntryKeyBoard;

-(void)checkOverlapForCurrentInTime;
-(void)checkOverlapForPage;
-(void)calculateNumberOfRowsAndTotalHoursForFooter;

-(void)updateMultiDayTimeEntryForIndex:(NSInteger)index withValue:(NSMutableDictionary *)multiInoutEntry;
-(void)changeParentViewLeftBarbutton;
-(void)updateExtendedInOutTimeEntryForIndex:(NSInteger)rowIndex forSection:(NSInteger)sectionIndex withValue:(NSMutableDictionary *)multiInoutEntry sendRequest:(BOOL)isSendRequest;
-(void)projectEditButtonIconClickedForSection:(NSInteger)index;
-(void)resetTableSizeForExtendedInOut:(BOOL)isResetTable;
-(void)addInOutButtonIconClickedForSection:(NSInteger)index;
-(void)calculateAndUpdateTotalHoursValueForFooter;
-(void)handleTapAndResetDayScroll;
-(void)createExtendedInOutArray;
-(void)createFooterView;
-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row forSection:(NSInteger)section;
-(void)deleteMutiInOutEntryforRow:(NSInteger)row forSection:(NSInteger)section withDelegate:(id)delegate;
-(void)calculateNumberOfRows;
-(BOOL)checkOverlapForPageForExtendedInOut;
-(void)checkOverlapForPageForExtendedInOutOnLoadForPage:(NSString *)currentPageString;

-(void)updateExtendedInOutTimeEntryForSplitOnIndex:(NSInteger)rowIndex forSection:(NSInteger)sectionIndex withValue:(NSMutableDictionary *)multiInoutEntry;
-(void)changeViewToNextDayView:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex withValue:(NSMutableDictionary *)dictForNextDay controllerIndex:(NSInteger)controllerIndex;
-(void) deleteEntryforRow:(NSInteger)row withDelegate:(id)delegate;
-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row;
-(void)checkGen4ServerPunchIdForAllTimeEntries;
-(void)gen4TimeEntryDeleteResponseReceived:(NSDictionary *)notification;
-(void)sendRequestToEditBreakEntryForTimeEntryObj:(TimesheetEntryObject *)tsEntryObj;
-(void)updateUserChangedFlag;
@end
