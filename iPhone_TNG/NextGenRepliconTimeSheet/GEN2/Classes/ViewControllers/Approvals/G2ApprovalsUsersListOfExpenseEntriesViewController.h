//
//  ApprovalsUsersListOfExpenseEntriesViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
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
#import "G2ApprovalsEditExpenseEntryViewController.h"
#import "G2ApprovalTablesHeaderView.h"
#import "G2ApprovalTablesFooterView.h"

@protocol approvalUsersListOfExpensesViewControllerDelegate;

@interface G2ApprovalsUsersListOfExpenseEntriesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,NetworkServiceProtocol,approvalTablesFooterViewDelegate,approvalTablesHeaderViewDelegate>{
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
	G2ApprovalsEditExpenseEntryViewController *editExpenseEntryViewController;
    NSMutableArray *backUpArr;

    id <approvalUsersListOfExpensesViewControllerDelegate> __weak delegate;
    BOOL						allowBlankComments;
    
     int currentViewTag;
    
}
@property(nonatomic,assign) int currentViewTag;
@property(nonatomic,strong)	G2ExpensesModel *expensesModel;
@property(nonatomic,strong)	G2PermissionsModel *permissionsModel;
@property(nonatomic,strong)	G2SupportDataModel *supportDataModel;
@property(nonatomic,strong)	NSMutableArray *backUpArr;
@property(nonatomic,strong)	NSArray *currencyDetailsArray;
@property(nonatomic,strong)	 NSMutableArray *totalAmountsArray;
@property(nonatomic,strong)	 G2ApprovalsEditExpenseEntryViewController *editExpenseEntryViewController;
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

@property(nonatomic,weak) id <approvalUsersListOfExpensesViewControllerDelegate> delegate;
@property(nonatomic,assign)  BOOL				  allowBlankComments;


- (void)createFooterView;

- (void)addTotalLable:(int)x;
- (void)addReimburseLable;


- (void)sendRequestToGetApproversStatus;
- (UIImage *)newImageFromResource:(NSString *)filename;


-(G2CustomTableViewCell*)getCellForIndexPath:(NSIndexPath*)indexPath;
-(void)updateCellBackgroundWhenSelected:(NSIndexPath*)indexPath;
-(void)deSelectCellWhichWasHighLighted;
-(void)newEntryIsAddedToSheet;

-(void)showErrorAlert:(NSError *) error;

-(void)highlightTheCellWhichWasSelected;

@end


@protocol approvalUsersListOfExpensesViewControllerDelegate <NSObject>

@optional
- (void)handleApproverCommentsForSelectedUser:(G2ApprovalsUsersListOfExpenseEntriesViewController *)approvalsUsersListOfTimeEntriesViewController;
- (void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag;
- (void)pushToEditExpenseEntryViewController:(id)editExpenseEntryViewController;

@end
