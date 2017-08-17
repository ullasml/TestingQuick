//
//  DailyWidgetDayLevelViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 1/7/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetEntryObject.h"
#import "DropDownViewController.h"
#import "AddDescriptionViewController.h"
@interface DailyWidgetDayLevelViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UpdateDropDownFieldProtocol>

{
    UITableView *timeEntryTableView;
    NSMutableArray *timesheetDataArray;
    NSIndexPath *currentIndexpath;
    NSIndexPath *previousIndexpath;
    UIDatePicker *datePicker;
    UIToolbar *toolbar;
    id __weak	lastUsedTextField;
    id __weak  lastUsedTextView;
    NSIndexPath *selectedIndexPath;
    BOOL isTextFieldClicked;
    NSMutableArray *timesheetEntryObjectArray;
    NSString *timesheetStatus;
    BOOL isUDFieldClicked;
    id __weak controllerDelegate;
    BOOL isProjectAccess,isClientAccess;
    BOOL isActivityAccess;
    int selectedDropdownUdfIndex;
    int selectedTextUdfIndex;
    id __weak approvalsDelegate;
}
@property(nonatomic,strong)UITableView *timeEntryTableView;
@property(nonatomic,strong)NSMutableArray *timesheetDataArray;
@property(nonatomic,strong)NSIndexPath *currentIndexpath;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,weak)id lastUsedTextField;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,assign)BOOL isTextFieldClicked;
@property(nonatomic,weak)id  lastUsedTextView;
@property(nonatomic,strong)NSMutableArray *timesheetEntryObjectArray;
@property(nonatomic,strong)NSString *timesheetStatus;
@property(nonatomic,assign)BOOL isUDFieldClicked;
@property(nonatomic,weak)id controllerDelegate;
@property(nonatomic,assign)BOOL isProjectAccess,isClientAccess;
@property(nonatomic,assign)BOOL isActivityAccess;
@property(nonatomic,assign)BOOL isBillingAccess;
@property(nonatomic,assign)int selectedDropdownUdfIndex;
@property(nonatomic,assign)int selectedTextUdfIndex;
@property(nonatomic,strong)UIImageView *totallabelView;
@property(nonatomic,strong)UILabel *totalLabelHoursLbl;
@property(nonatomic,strong)NSDate *currentPageDate;
@property(nonatomic,strong)NSMutableArray *cellHeightsArray;
@property(nonatomic,assign)BOOL isProgramAccess;
@property(nonatomic,strong)NSString *sheetIdentity;
@property(nonatomic,strong)NSString *timesheetFormat;
@property(nonatomic,weak)id __weak approvalsDelegate;

- (void)resetTableSize:(BOOL)isResetTable;
-(void)handleButtonClick:(NSIndexPath*)selectedIndex;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)updateTimeEntryHoursForIndex:(NSInteger)index withValue:(NSString *)value isDoneClicked:(BOOL)isDoneClicked;
-(void)updateProjectName:(NSString *)projectName withProjectUri:(NSString *)projectUri withTaskName:(NSString *)taskName
             withTaskUri:(NSString *)taskUri withActivityName:(NSString *)activityName withActivityUri:(NSString *)activityUri withBillingName:(NSString *)billingName withBillingUri:(NSString *)billingUri;
-(void)changeParentViewLeftBarbutton;
-(void)calculateAndUpdateTotalHoursValueForFooter;
-(void)handleTapAndResetDayScroll;
-(void) deleteEntryforRow:(NSInteger)row withDelegate:(id)delegate;
-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row;
-(void)updateSelectedOEFObject:(int)row;
-(void)updateOEFNumber:(UITextField *)oefNumericTextField;
@end
