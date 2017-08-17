//
//  PendingExpensesViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsCheckBoxCustomCell.h"
#import "G2ApprovalsExpensesScrollViewController.h"
#import "G2ApprovalTablesFooterView.h"
#import "G2AddDescriptionViewController.h"

@interface G2PendingExpensesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,approvalSelectedUserDelegate,approvalTablesFooterViewDelegate>
{
    UITableView *approvalpendingTSTableView;
    G2ApprovalsCheckBoxCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSMutableArray *listOfUsersArr;
    NSIndexPath *selectedIndexPath;
    G2ApprovalsExpensesScrollViewController *scrollViewController;
    G2AddDescriptionViewController *addDescriptionViewController;
}

@property(nonatomic,strong)  UITableView *approvalpendingTSTableView;
@property(nonatomic,strong)  UILabel *sectionHeaderlabel;
@property(nonatomic,strong)  UIImageView *sectionHeader;
@property(nonatomic,strong)  NSMutableArray *listOfUsersArr;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) G2ApprovalsExpensesScrollViewController *scrollViewController;
@property(nonatomic,strong)	G2AddDescriptionViewController *addDescriptionViewController;

@end
