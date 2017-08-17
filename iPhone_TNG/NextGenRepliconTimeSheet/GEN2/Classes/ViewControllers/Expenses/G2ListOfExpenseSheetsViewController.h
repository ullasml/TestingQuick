//
//  ListOfExpenseSheetsViewController.h
//  Replicon
//
//  Created by Rohini on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ExpensesModel.h"
//#import "ExpensesCellView.h"
#import "G2CustomTableViewCell.h"
#import "G2Util.h"
#import "G2ListOfExpenseEntriesViewController.h"
#import "G2Constants.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "G2NewExpenseSheetViewController.h"
#import"G2AddNewExpenseViewController.h"
@interface G2ListOfExpenseSheetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NetworkServiceProtocol,G2ServerResponseProtocol> {
	
		
	UITableView                 *expenseSheetTableView;
	NSInteger					showedExpensesCount;
	UIView						*footerViewExpenses;
	UIButton					*moreButton;
	G2ExpensesModel				*expensesModel;
	BOOL						isShow;
	UIImageView					*imageView;

	G2AddNewExpenseViewController *addNewExpenseEntryViewController;
	G2ListOfExpenseEntriesViewController *expenseEntryViewController;
	
	NSIndexPath *tappedIndexPath;
    UINavigationController *navcontroller;
}

@property NSInteger showedExpensesCount;
@property(nonatomic,strong)	 UINavigationController *navcontroller;
@property(nonatomic,strong)	NSIndexPath *tappedIndexPath;
@property(nonatomic,strong)	UITableView *expenseSheetTableView;
@property(nonatomic,strong) UIView	*footerViewExpenses;
@property(nonatomic,strong) UIImageView	*imageView;
-(void)moreAction:(id)sender;
-(void)goBack:(id)sender;
-(void)addExpenseSheetAction:(id)sender;
-(void)registerForNotification;
-(void)showHideMoreButton;
-(void)handleNextRecentExpenseSheetsResponse:(id)response;
- (void) serverDidRespondWithResponse:(id) response ;
-(void)showAndHideMoreButton;
-(void)gotoExpenseSheetFirstEntry:(NSNotification*)notif;
-(void)newEntrySavedResponse;
-(void)showAddNewExpenseEntryPageByDefault:(NSDictionary*)sheetContentsDict;
-(void)showErrorAlert:(NSError *) error;
-(G2CustomTableViewCell*)getCellForIndexPath:(NSIndexPath*)indexPath;
-(void)updateCellBackgroundWhenSelected:(NSIndexPath*)indexPath;
-(void)deSelectCellWhichWasHighLighted;
-(void)highlightTheCellWhichWasSelected;
-(void)newSheetIsAdded;
-(void)sheetDeletedFromByUser;
-(void)handleQueryHandlerException:(NSString*)exceptionMessage;
- (void)hideEmptySeparators;
-(void)viewWillAppear:(BOOL)animated;
@end
