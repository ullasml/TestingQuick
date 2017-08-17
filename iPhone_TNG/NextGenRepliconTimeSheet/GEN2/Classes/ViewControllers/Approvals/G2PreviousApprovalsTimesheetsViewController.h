//
//  PreviousApprovalsTimesheetsViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/13/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsCustomCell.h"

@class G2ApprovalsScrollViewController;
@interface G2PreviousApprovalsTimesheetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

{
    UITableView *prevApprovalsTimesheetsTableView;
    G2ApprovalsCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSMutableDictionary *pendingApprovalsListOfItemsDict;
    NSIndexPath *selectedIndexPath;
    UIView *footerView;
    UIButton *moreButton;
    UIImageView *imageView;
    G2ApprovalsScrollViewController *scrollViewController;
    NSMutableArray *listOfUsersArr;
}

@property(nonatomic,strong)  NSMutableDictionary *pendingApprovalsListOfItemsDict;
@property(nonatomic,strong) UITableView *prevApprovalsTimesheetsTableView;
@property(nonatomic,strong)  UILabel *sectionHeaderlabel;
@property(nonatomic,strong)  UIImageView *sectionHeader;
@property(nonatomic,strong)  NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)  UIView *footerView;
@property(nonatomic,strong)  UIButton *moreButton;
@property(nonatomic,strong)  UIImageView *imageView;
@property(nonatomic,strong)  G2ApprovalsScrollViewController *scrollViewController;
@property(nonatomic,strong)  NSMutableArray *listOfUsersArr;

@end
