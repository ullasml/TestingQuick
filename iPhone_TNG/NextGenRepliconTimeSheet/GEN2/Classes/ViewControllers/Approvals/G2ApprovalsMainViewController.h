//
//  ApprovalsMainViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsCustomCell.h"

@class G2PendingTimesheetsViewController;
@class G2OverDueTimesheetsViewController;
@class G2PreviousApprovalsTimesheetsViewController;
@class G2PendingExpensesViewController;
@class G2PreviousApprovalsExpensesViewController;

@interface G2ApprovalsMainViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *approvalsMainTableView;
    UIBarButtonItem	*leftButton;
    G2ApprovalsCustomCell *cell;
    NSMutableArray *timeSheetlistOfItemsArr,*expensesSheetlistOfItemsArr;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    G2PendingTimesheetsViewController *pendingTimesheetsViewController;
    G2OverDueTimesheetsViewController *overdueTimesheetsViewController;
    G2PreviousApprovalsTimesheetsViewController *previousApprovalsTimesheetsViewController;
    G2PendingExpensesViewController *pendingExpensesViewController;
    G2PreviousApprovalsExpensesViewController *previousApprovalsExpensesViewController;
    NSIndexPath *selectedIndexPath;
    BOOL isNotFirstTimeFlag;
}

@property(nonatomic,assign) BOOL isNotFirstTimeFlag;
@property(nonatomic,strong) UITableView *approvalsMainTableView;
@property(nonatomic,strong) UIBarButtonItem	*leftButton;
@property(nonatomic,strong)  NSMutableArray *timeSheetlistOfItemsArr,*expensesSheetlistOfItemsArr;
@property(nonatomic,strong)  UILabel *sectionHeaderlabel;
@property(nonatomic,strong)  UIImageView *sectionHeader;
@property(nonatomic,strong) G2PendingTimesheetsViewController *pendingTimesheetsViewController;
@property(nonatomic,strong) G2OverDueTimesheetsViewController *overdueTimesheetsViewController;
@property(nonatomic,strong) G2PreviousApprovalsTimesheetsViewController *previousApprovalsTimesheetsViewController;
@property(nonatomic,strong) G2PendingExpensesViewController *pendingExpensesViewController;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) G2PreviousApprovalsExpensesViewController *previousApprovalsExpensesViewController;


-(void)moveToPendingTimesheetsViewController;
- (void)viewWillAppear:(BOOL)animated;
@end
