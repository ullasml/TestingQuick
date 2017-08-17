//
//  TimeEntryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 08/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntryCellDetails.h"
#import "TimesheetObject.h"
#import "SearchViewController.h"
#import "SelectProjectOrTaskViewController.h"
#import "DropDownViewController.h"
#import "PunchMapViewController.h"

@interface TimeEntryViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UpdateEntryFieldProtocol,UpdateEntryProjectAndTaskFieldProtocol,UIAlertViewDelegate,UpdateDropDownFieldProtocol>
{
    UITableView *timeEntryTableView;
    NSMutableArray *timeEntryArray;

    TimesheetObject *timesheetObject;
    NSInteger		screenMode;
    BOOL isProjectAccess,isClientAccess;
    BOOL isActivityAccess;
    BOOL activitySelectionRequired;
    BOOL isBillingAccess;
    id __weak delegate;
    UIView *footerView;
    NSIndexPath *selectedIndexPath;
    UITextField	*lastUsedTextField;
    UIDatePicker *datePicker;
    UIToolbar *toolbar;
    int billingIndex;
    BOOL isTimeAllowedPermission;
    NSString *timesheetURI;
    NSString *timesheetStatus;
    BOOL isMultiDayInOutTimesheetUser;
    NSMutableArray *timesheetDataArray;
    BOOL isDisclaimerRequired;
    NSString *approvalsModuleName;
    NSInteger screenViewMode;
    NSString *rowUriBeingEdited;
    BOOL isEntryDetailsChanged;
    BOOL isExtendedInOutTimesheet;
    NSDate *currentPageDate;
    UISegmentedControl *segmentedCtrl;//Implentation for US8956//JUHI
    NSMutableArray *breakEntryArray;
    BOOL isEditBreak;
    UITextField *__weak searchBar;
    NSTimer *searchTimer;
    NSString *selectedBreakString;
    UIImageView *searchIconImageView;
    //Implemented as per US9109//JUHI
    BOOL _hasTimesheetTimeoffAccess;
    int availableTimeOffTypeCount;
    NSMutableArray *adHocOptionList;
    NSString *selectedTimeoffString;
    
    //Implementation for US9371//JUHI
    UIBarButtonItem         *doneButton;
    UIBarButtonItem         *spaceButton;
    
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *pickerClearButton;
    NSString *previousDateUdfValue;
    NSUInteger udfIndexCount;
    NSMutableArray *editEntryRowUdfArray;
    int rowHeight;
    
    BOOL isRowUdf;//Implementation forMobi-181//JUHI
    UILabel *noPrjectActivityMsgLabel;
    UIButton *addRowButton;
    BOOL isUsingAuditImages;
    NSString *cellIdentiferstr;//Fix for defect MOBI-456//JUHI
    
}
@property(nonatomic,strong)NSDate *currentPageDate;
@property(nonatomic,assign) BOOL isProjectAccess,isProgramAccess,isClientAccess,isActivityAccess,isBillingAccess,activitySelectionRequired;
@property(nonatomic,assign) BOOL isTimeAllowedPermission;
@property(nonatomic,strong)UITableView *timeEntryTableView;
@property(nonatomic,strong)NSMutableArray *timeEntryArray;

@property(nonatomic,strong)TimesheetObject *timesheetObject;
@property(nonatomic,assign) NSInteger screenMode;
@property(nonatomic,weak)id delegate;
@property(nonatomic,strong)UIView *footerView;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) UITextField	*lastUsedTextField;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,strong)NSString *timesheetURI;
@property(nonatomic,strong)NSString *timesheetStatus;
@property(nonatomic,assign)BOOL isMultiDayInOutTimesheetUser;
@property(nonatomic,strong)NSMutableArray *timesheetDataArray;
@property(nonatomic,assign)BOOL isDisclaimerRequired;
@property(nonatomic,strong)NSString *approvalsModuleName;
@property(nonatomic,assign)NSInteger screenViewMode;
@property(nonatomic,strong)NSString *rowUriBeingEdited;
@property(nonatomic,assign)BOOL isEntryDetailsChanged;
@property(nonatomic,assign)BOOL isExtendedInOutTimesheet;
//Implentation for US8956//JUHI
@property(nonatomic,strong)UISegmentedControl *segmentedCtrl;
@property(nonatomic,strong)NSMutableArray *breakEntryArray;
@property(nonatomic,assign)BOOL isEditBreak;
@property(nonatomic,weak)UITextField *searchBar;
@property(nonatomic,strong)NSTimer *searchTimer;
@property(nonatomic,strong)NSString *selectedBreakString;
@property(nonatomic,strong)UIImageView *searchIconImageView;
@property(nonatomic,assign)NSInteger indexBeingEdited;
//Implemented as per US9109//JUHI
@property(nonatomic,assign)BOOL _hasTimesheetTimeoffAccess;
@property(nonatomic,assign)int availableTimeOffTypeCount;
@property (nonatomic,strong)NSMutableArray *adHocOptionList;
@property(nonatomic,strong)NSString *selectedTimeoffString;
@property(nonatomic,assign)id controllerDelegate;
//Implementation for US9371//JUHI
@property(nonatomic,strong) UIBarButtonItem *cancelButton;
@property(nonatomic,strong) NSString *previousDateUdfValue;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UIBarButtonItem *pickerClearButton;
@property(nonatomic,strong)NSMutableArray *editEntryRowUdfArray;
//Implementation forMobi-181//JUHI
@property(nonatomic,assign) BOOL isRowUdf;
@property(nonatomic,strong)UILabel *noPrjectActivityMsgLabel;
@property(nonatomic,strong)UIButton *addRowButton;
@property(nonatomic,assign)BOOL isFromLockedInOut,isFromAttendance,isFromPlayButton,isStartNewTask;
@property(nonatomic,assign)BOOL isUsingAuditImages;
@property(nonatomic,strong)PunchMapViewController *punchMapViewController;
@property(nonatomic,strong) NSString *isCurrentPunchID;
@property(nonatomic,strong) NSString *cellIdentiferstr;//Fix for defect MOBI-456//JUHI
@property(nonatomic,assign)BOOL isGen4UserTimesheet;
@property(nonatomic,strong)NSString  *timesheetFormat;
@property(nonatomic,assign)id navigationType;


-(void)resetTableSize:(BOOL)isResetTable;
-(void)doneClicked;
-(void)updateFieldWithClient:(NSString*)client clientUri:(NSString*)clientUri project:(NSString *)projectname projectUri:(NSString *)projectUri task:(NSString*)taskName andTaskUri:(NSString*)taskUri taskPermission:(BOOL)hasTaskPermission timeAllowedPermission:(BOOL)hasTimeAllowedPermission;
-(void)updateFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri;
-(void)updateUDFNumber:(NSString *)UdfNumberEntered forIndex:(NSInteger)index;

//Implementation for US9371//JUHI
-(void)updateTextUdf:(NSString*)udfTextValue;
-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri;
-(void)dismissCameraView;
-(void)continueAction:(id)sender;
-(void)showCustomPickerIfApplicable:(UITextField *)textField;
@end
