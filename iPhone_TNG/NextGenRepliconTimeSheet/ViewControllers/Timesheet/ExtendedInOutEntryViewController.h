//
//  ExtendedInOutEntryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 19/11/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetEntryObject.h"
#import "TimesheetUdfView.h"
#import "DropDownViewController.h"
#import "InOutEntryDetailsCustomCell.h"

@interface ExtendedInOutEntryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UpdateDropDownFieldProtocol,UITextViewDelegate>


@property (nonatomic,strong)NSDate *currentPageDate;
@property (nonatomic,strong)TimesheetEntryObject *tsEntryObject;
@property (nonatomic,assign)BOOL isProjectAccess;
@property (nonatomic,assign)BOOL isActivityAccess;
@property (nonatomic,assign)BOOL isBillingAccess;
@property (nonatomic,assign)NSInteger row;
@property (nonatomic,assign)NSInteger section;
@property (nonatomic,strong)NSString *hours;
@property (nonatomic,strong)UITableView *inoutEntryTableView;
@property (nonatomic,strong)NSString *sheetApprovalStatus;
@property (nonatomic,weak)id commentsControlDelegate;
@property (nonatomic,strong)UITextField *lastUsedTextField;
@property (nonatomic,assign)NSInteger selectedUdfCell;
@property (nonatomic,strong)UIDatePicker *datePicker;
@property (nonatomic,strong)UIBarButtonItem *cancelButton;
@property (nonatomic,strong)NSString *previousDateUdfValue;
@property (nonatomic,strong)UIBarButtonItem *doneButton;
@property (nonatomic,strong)UIBarButtonItem *spaceButton;
@property (nonatomic,strong)UIBarButtonItem *pickerClearButton;
@property (nonatomic,strong)UIToolbar *toolbar;
@property (nonatomic,strong)UITextView *commentsTextView;
@property (nonatomic,strong)UIView *tableFooterView;
@property (nonatomic,strong)UIView *tableHeaderView;
@property (nonatomic,assign)BOOL isEditState;
@property (nonatomic,assign)BOOL isTextViewBecomeFirstResponder;
@property (nonatomic,strong)NSMutableArray *userFieldArray;
@property (nonatomic,assign)BOOL isBreakAccess;//ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
@property (nonatomic,strong)NSMutableAttributedString *attributedString;
@property (nonatomic,assign)BOOL isGen4UserTimesheet;
@property (nonatomic,strong)NSString *timesheetFormat;
@property (nonatomic,strong)NSMutableArray *oefFieldArray;

-(void)handleUdfCellClick:(NSInteger)selectedButtonTag withType:(NSString*)typeStr;
-(void)doneClicked;
-(void)resetTableSize:(BOOL)isResetTable isFromUdf:(BOOL)isFromUdf isDateUdf:(BOOL)isDateUdf;
@end
