//
//  ListOfExpenseEntriesViewController.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AddNewExpenseEntryViewController.h"
#import "G2SubmittedDetailsView.h"
#import "FrameworkImport.h"
#import "G2Util.h"
#import "G2ExpensesModel.h"
#import "G2PermissionsModel.h"
#import "G2ExpensesCellView.h"
#import "G2CustomTableViewCell.h"
#import "G2Constants.h"
#import "G2SupportDataModel.h"
#import "G2AddNewExpenseViewController.h"
#import "G2EditExpenseEntryViewController.h"
#import "G2ResubmitTimesheetViewController.h"//US2669//Juhi
@interface G2ListOfExpenseEntriesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NetworkServiceProtocol>{
	UITableView *expenseEntriesTableView;
	NSMutableArray *expenseEntriesArray;
	G2SubmittedDetailsView *submittedDetailsView;
	G2ExpensesModel *expensesModel;
	G2PermissionsModel *permissionsModel;
	G2SupportDataModel *supportDataModel;
	id __weak delegateObj;
	UIAlertView *submitAlertView;
	
//	UILabel *topToolbarLabel;
//	UILabel *innerTopToolbarLabel;
	NSString *expenseSheetStatus;
	NSString *expenseSheetTrackingNo;
	NSString *expenseSheetTitle;
	NSString *selectedSheetId;
	
	UILabel *amountLable;
	NSString *result;
	UILabel *totalFooterLable;
	
	UIView *footerView;
	UIView *footerButtonsView;
	
	BOOL afterDeletingLineItem;
	BOOL editedLineItemLoading;
	BOOL newEntryAddedToSheet;
	BOOL approversRemaining;
	
	BOOL isEntriesAvailable;
	UIView *totalAmountView;
	NSArray *currencyDetailsArray;
	BOOL alertFlag;
	
	NSString *totalReimbursement;
	NSNumber *selectedExpenseSheetIndex;
	
	NSMutableArray *unsubmittedApproveArray;
	UIButton *deleteButton;
	UILabel *deleteUnderlineLabel;
	
	
	NSMutableDictionary *currenciesDict;
	float totalCurrencyPerType;
	
	NSMutableArray *totalAmountsArray;
	UIButton *submitButton;

	NSIndexPath *tappedIndex;
	UILabel *messageLabel;

    NSMutableArray *backUpArr;
    //US2669//Juhi
    G2ResubmitTimesheetViewController *resubmitViewController;
    BOOL						allowBlankComments;
    NSMutableDictionary * ret;

}
@property(nonatomic,strong)G2SubmittedDetailsView *submittedDetailsView;
@property(nonatomic,strong)	 NSMutableDictionary * ret;
@property(nonatomic,strong)	G2ExpensesModel *expensesModel;
@property(nonatomic,strong)	G2PermissionsModel *permissionsModel;
@property(nonatomic,strong)	G2SupportDataModel *supportDataModel;
@property(nonatomic,strong)	NSMutableArray *backUpArr;
@property(nonatomic,strong)	NSArray *currencyDetailsArray;
@property(nonatomic,strong)	 NSMutableArray *totalAmountsArray;

@property(nonatomic,strong) UILabel *amountLable,*totalFooterLable;
@property(nonatomic,strong) UIView *footerView,*footerButtonsView,*totalAmountView;
@property(nonatomic,strong) UIButton *submitButton;
@property(nonatomic,strong)UILabel *messageLabel;
@property(nonatomic,strong) UILabel *deleteUnderlineLabel;
@property(nonatomic,strong) UIButton *deleteButton;
@property(nonatomic,strong) 	NSIndexPath *tappedIndex;
@property(nonatomic,strong)	NSMutableArray *unsubmittedApproveArray;
@property	BOOL newEntryAddedToSheet;
@property(nonatomic,strong) NSMutableArray *expenseEntriesArray;
@property(nonatomic,strong)UITableView *expenseEntriesTableView;
@property(nonatomic,weak) id delegateObj;
@property(nonatomic,strong) NSString *expenseSheetStatus;
@property(nonatomic,strong) NSString *expenseSheetTrackingNo;
@property(nonatomic,strong) NSString *expenseSheetTitle;
@property(nonatomic,strong) NSString *selectedSheetId;
@property(nonatomic,strong) NSString *totalReimbursement;
@property(nonatomic,assign)	BOOL editedLineItemLoading;
@property (nonatomic,assign) BOOL afterDeletingLineItem;
@property (nonatomic,assign) BOOL isEntriesAvailable;
@property (nonatomic,assign) BOOL approversRemaining;
@property (nonatomic,strong) NSNumber *selectedExpenseSheetIndex;
@property(nonatomic,strong)	 NSArray  *expenseEntriesArr;
//@property(nonatomic,retain)	 UIButton *submitButton;
//US2669//Juhi
@property(nonatomic,strong) G2ResubmitTimesheetViewController *resubmitViewController;
@property(nonatomic,assign)  BOOL				  allowBlankComments;


- (void)createFooterView;
- (void)addLineItemToTable;
- (void)addTotalLable:(int)x;
- (void)addReimburseLable;
- (void)deleteAction:(id)sender;
- (void)submitAction:(id)sender;
- (void)registerForNotification;
- (void)sendRequestToGetApproversStatus;
- (UIImage *)newImageFromResource:(NSString *)filename;
-(void)goBackToSheets;
-(void)addDeleteButtonToView:(float)position view:(UIView*)viewToAdd;
-(G2CustomTableViewCell*)getCellForIndexPath:(NSIndexPath*)indexPath;
-(void)updateCellBackgroundWhenSelected:(NSIndexPath*)indexPath;
-(void)deSelectCellWhichWasHighLighted;
-(void)newEntryIsAddedToSheet;
-(void)addDeleteButtonWithMessage;
-(void)showErrorAlert:(NSError *) error;
//DE3395//Juhi
-(void)highlightTheCellWhichWasSelected;
-(void)handleScreenBlank;
//added for Removing approvers
//-(void)addUnsubmitButtonForWaitingSheets;
@end
