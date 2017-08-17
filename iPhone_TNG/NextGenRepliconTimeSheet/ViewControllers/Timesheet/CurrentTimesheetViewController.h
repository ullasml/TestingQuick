//
//  CurrentTimesheetViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 18/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetObject.h"
#import "CustomPickerView.h"
#import "TimesheetSummaryViewController.h"
#import "TimesheetUdfView.h"
#import "SearchViewController.h"
#import "TimesheetMainPageController.h"
#import "DropDownViewController.h"
#import "ApprovalTablesHeaderView.h"
#import "ApprovalTablesFooterView.h"
#import "AppDelegate.h"

@class ButtonStylist;
@protocol Theme;
@class ApprovalStatusPresenter;


@interface CurrentTimesheetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,SegmentControlProtocol,UpdateDropDownFieldProtocol,approvalTablesHeaderViewDelegate,approvalTablesFooterViewDelegate>{

    UITableView *currentTimesheetTableView;
    NSString    *selectedSheet;
	NSString    *totalHours;
	NSString    *sheetApprovalStatus;
	NSString    *sheetIdentity;
    UIView      *footerView;
    UIView      *totallabelView;
    NSString   *dueDate;
    TimesheetMainPageController *timesheetMainPageController;
    NSMutableArray *currentTimesheetArray;
    NSMutableArray *customFieldArray;
    UIBarButtonItem	*rightBarButton;
    TimesheetObject *timeSheetObj;
    UIDatePicker *datePicker;
    NSInteger selectedUdfCell;
    UIToolbar *toolbar;
    UINavigationController       *navcontroller;
    UITextField							*lastUsedTextField;



    CustomPickerView *customPickerView;
    TimesheetSummaryViewController *timesheetSummaryViewController;
    UIView *overlayView;
    TimesheetUdfView *timesheetUdfView;

    UIButton* radioButton;
    UILabel *disclaimerTitleLabel;
    BOOL disclaimerSelected;
    BOOL isCurrentTimesheetPeriod;
    BOOL isMultiDayInOutTimesheetUser;
    id __weak parentDelegate;

    NSString *actionType;
    BOOL isSaveClicked;//Fix for DE15534
    NSString *userName;
    NSString *sheetPeriod;
    NSString *approverComments;
    float heightofDisclaimerText;
//    BOOL isLockedInOutState;
    NSString *approvalsModuleName;
    BOOL isExtendedInOut;
    BOOL isFirstTimeLoad;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem         *doneButton;
    UIBarButtonItem         *spaceButton;

    UIBarButtonItem *cancelButton;
    UIBarButtonItem *pickerClearButton;
    NSString *previousDateUdfValue;

    NSString *sheetStatus;//Fix for Approval status//JUHI
}

@property(nonatomic,strong)NSString *actionType;
@property(nonatomic,weak)id parentDelegate;
@property(nonatomic,strong)UITableView *currentTimesheetTableView;
@property(nonatomic,strong)NSString    *selectedSheet;
@property(nonatomic,strong)NSString    *totalHours;
@property(nonatomic,strong)NSString    *sheetApprovalStatus;
@property(nonatomic,strong)NSString    *sheetIdentity;
@property(nonatomic,strong)UIView      *footerView;
@property(nonatomic,strong)UIView      *totallabelView;
@property(nonatomic,strong)NSMutableArray *currentTimesheetArray;
@property(nonatomic,strong)NSMutableArray *customFieldArray;
@property(nonatomic,strong)UIBarButtonItem *rightBarButton;
@property(nonatomic,strong)TimesheetObject *timeSheetObj;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,strong)UINavigationController *navcontroller;
@property(nonatomic,strong)UITextField						*lastUsedTextField;
@property(nonatomic,strong)NSString    *dueDate;
@property(nonatomic,strong)CustomPickerView *customPickerView;
@property(nonatomic,strong)UIView *overlayView;
@property(nonatomic,strong)TimesheetUdfView *timesheetUdfView;
@property(nonatomic,assign)NSInteger selectedUdfCell;
@property(nonatomic,strong)TimesheetMainPageController *timesheetMainPageController;
@property(nonatomic,strong)TimesheetSummaryViewController *timesheetSummaryViewController;
@property(nonatomic,assign)BOOL isMultiDayInOutTimesheetUser;
@property(nonatomic,assign)BOOL disclaimerSelected;
@property(nonatomic,strong)UILabel *disclaimerTitleLabel;
@property(nonatomic,strong)UIButton* radioButton;
@property(nonatomic,assign)BOOL isCurrentTimesheetPeriod;
@property(nonatomic,assign)BOOL isSaveClicked;//Fix for DE15534
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *sheetPeriod;
@property(nonatomic,assign)NSInteger currentViewTag;
@property(nonatomic,assign)NSInteger currentNumberOfView;
@property(nonatomic,assign)NSUInteger totalNumberOfView;
@property(nonatomic,strong)NSString *approverComments;
@property(nonatomic,strong)NSString *approvalsModuleName;
//@property(nonatomic,assign)BOOL isLockedInOutState;
@property(nonatomic,assign)BOOL isExtendedInOut;
@property(nonatomic,assign)BOOL isFirstTimeLoad;
@property(nonatomic,strong)NSString *userUri;

//Implementation for US8771 HandleDateUDFEmptyValue//JUHI
@property(nonatomic,strong) UIBarButtonItem *cancelButton;
@property(nonatomic,strong) NSString *previousDateUdfValue;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UIBarButtonItem *pickerClearButton;

@property(nonatomic,strong) NSString *sheetStatus;//Fix for Approval status//JUHI
@property(nonatomic, weak, readonly) UIButton *submitButton;
@property(nonatomic, weak, readonly) AppDelegate *appDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithApprovalStatusPresenter:(ApprovalStatusPresenter *)approvalStatusPresenter
                                          theme:(id <Theme>)theme
                               supportDataModel:(SupportDataModel *)supportDataModel
                                 timesheetModel:(TimesheetModel *)timesheetModel
                                  buttonStylist:(ButtonStylist *)buttonStylist
                                    appDelegate:(AppDelegate *)appDelegate;

-(void)handleButtonClicks:(NSInteger)selectedButtonTag withType:(NSString*)typeStr;
-(void)createFooter;
-(void)resetTableSize:(BOOL)isResetTable;
-(void)RecievedData;
-(void)doneClicked;
-(void)navigationTitle;
-(BOOL)canResubmitTimeSheetForURI:(NSString *)sheetUri;
-(void)updateTextUdf:(NSString*)udfTextValue;
-(void)updateTimesheetFormat;
-(void)createCurrentTimesheetEntryList;
-(void)createUdfs;
-(void)createTableHeader;
-(void)resetViewForApprovalsCommentsAction:(BOOL)isReset andComments:(NSString *)approverComments;
-(void)showMessageLabel;
-(void)reasonForChangeButtonAction;
-(void)submitTimeSheetReceivedData:(NSNotification *) notification;
-(void)showTimesheetFormatNotSupported;
-(void)timesheetSummaryAction:(id)sender;
-(void)enableDeeplinkForTimesheetWithStartDate:(NSDate *)startDate;
@end
