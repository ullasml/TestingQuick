//
//  PreviousApprovalsExpensesViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/15/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsCustomCell.h"

@class G2ApprovalsExpensesScrollViewController;
@interface G2PreviousApprovalsExpensesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    UITableView *prevApprovalsExpensesTableView;
    G2ApprovalsCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSMutableDictionary *pendingApprovalsListOfItemsDict;
    NSIndexPath *selectedIndexPath;
    UIView *footerView;
    UIButton *moreButton;
    UIImageView *imageView;
    G2ApprovalsExpensesScrollViewController *scrollViewController;
    NSMutableArray *listOfUsersArr;
}

@property(nonatomic,strong)  NSMutableDictionary *pendingApprovalsListOfItemsDict;
@property(nonatomic,strong) UITableView *prevApprovalsExpensesTableView;
@property(nonatomic,strong)  UILabel *sectionHeaderlabel;
@property(nonatomic,strong)  UIImageView *sectionHeader;
@property(nonatomic,strong)  NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)  UIView *footerView;
@property(nonatomic,strong)  UIButton *moreButton;
@property(nonatomic,strong)  UIImageView *imageView;
@property(nonatomic,strong)  G2ApprovalsExpensesScrollViewController *scrollViewController;
@property(nonatomic,strong)  NSMutableArray *listOfUsersArr;

@end
