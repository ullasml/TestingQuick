//
//  OverDueTimesheetsViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/9/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsCheckBoxCustomCell.h"
 #import <MessageUI/MessageUI.h>

@interface G2OverDueTimesheetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,approvalSelectedUserDelegate,MFMailComposeViewControllerDelegate>
{
    UITableView *approvalOverdueTSTableView;
    G2ApprovalsCheckBoxCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSMutableArray *listOfUsersArr;
    NSIndexPath *selectedIndexPath;
    UIView *customFooterView;
}

@property(nonatomic,strong)  UITableView *approvalOverdueTSTableView;
@property(nonatomic,strong)  UILabel *sectionHeaderlabel;
@property(nonatomic,strong)  UIImageView *sectionHeader;
@property(nonatomic,strong)  NSMutableArray *listOfUsersArr;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) UIView *customFooterView;
@end
