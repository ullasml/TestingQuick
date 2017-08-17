//
//  PendingTimesheetsViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsCheckBoxCustomCell.h"
#import "G2ApprovalsScrollViewController.h"
#import "G2ApprovalTablesFooterView.h"
#import "G2AddDescriptionViewController.h"

@interface G2PendingTimesheetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,approvalSelectedUserDelegate,approvalTablesFooterViewDelegate>
{
    UITableView *approvalpendingTSTableView;
    G2ApprovalsCheckBoxCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSMutableArray *listOfUsersArr;
    NSIndexPath *selectedIndexPath;
    G2ApprovalsScrollViewController *scrollViewController;
    G2AddDescriptionViewController *addDescriptionViewController;
    NSMutableArray *timeSheetsArray;
    G2PermissionSet *permissionsetObj;
    G2Preferences *preferenceSet;
    UIBarButtonItem	*leftButton;
    NSMutableArray *selectedSheetsIDsArr;
    BOOL isnotFirstTimeLoad;
    UILabel *msgLabel;
    BOOL isApproveRejectBtnClicked;
    BOOL isFromCommentsScreen;
    UILabel *topToolbarLabel;
    UIButton *checkOrClearAllBtn;
}
@property(nonatomic,strong) UILabel *topToolbarLabel;
@property(nonatomic,assign) BOOL isFromCommentsScreen;
@property(nonatomic,assign) NSUInteger totalRowsCount;
@property(nonatomic,strong)UILabel *msgLabel;
@property(nonatomic,assign) BOOL isnotFirstTimeLoad;
@property(nonatomic,strong) NSMutableArray *selectedSheetsIDsArr;
@property(nonatomic,strong) UIBarButtonItem	*leftButton;
@property(nonatomic,strong)  NSMutableArray *timeSheetsArray;
@property(nonatomic,strong)  UITableView *approvalpendingTSTableView;
@property(nonatomic,strong)  UILabel *sectionHeaderlabel;
@property(nonatomic,strong)  UIImageView *sectionHeader;
@property(nonatomic,strong)  NSMutableArray *listOfUsersArr;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) G2ApprovalsScrollViewController *scrollViewController;
@property(nonatomic,strong)	G2AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,assign) BOOL isApproveRejectBtnClicked;
-(void)goBack:(id)sender;
-(NSString *)getFormattedEntryDateString:(NSString *)_stringdate;
-(BOOL)checkForPermissionExistence:(NSString *)_permission :(NSString *)userID;
-(BOOL)userPreferenceSettings:(NSString *)_preference andUID:(NSString *)userID;
-(void)displayAllTimeSheetsBySheetID:(NSDictionary *)sheetDict;
-(void)viewAllTimeEntriesScreen;
-(void)refreshTableView;
-(void)updateTabBarItemBadge;
- (void)setDescription:(NSString *)description;
-(void)showMessageLabel;
-(void)intialiseTableViewWithFooter;
-(void)clearORSelectAll:(id)sender;
- (void)moreButtonClickForFooterView:(NSInteger)senderTag;
-(void)showOrHideMoreButton;

@end
