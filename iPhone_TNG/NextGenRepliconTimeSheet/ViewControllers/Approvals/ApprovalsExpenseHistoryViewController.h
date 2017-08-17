//
//  ApprovalsExpenseHistoryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 4/8/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApprovalsScrollViewController.h"
#import "ApprovalsPendingCustomCell.h"
@interface ApprovalsExpenseHistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,approvalSelectedUserDelegate>
{
    UITableView *approvalHistoryTableView;
    ApprovalsPendingCustomCell *cell;
    NSMutableArray *historyArr;
    UILabel *msgLabel;
    NSIndexPath *selectedIndexPath;
    ApprovalsScrollViewController *scrollViewController;
}
@property(nonatomic,strong)UITableView *approvalHistoryTableView;
@property(nonatomic,strong)ApprovalsPendingCustomCell *cell;
@property(nonatomic,strong) NSMutableArray *historyArr;
@property(nonatomic,strong) UILabel *msgLabel;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) ApprovalsScrollViewController *scrollViewController;

@property (nonatomic, readonly) LoginModel *loginModel;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) ApprovalsService *approvalsService;
@property (nonatomic, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) ApprovalsModel *approvalsModel;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
                           spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          approvalsService:(ApprovalsService *)approvalsService
                            approvalsModel:(ApprovalsModel *)approvalsModel
                                loginModel:(LoginModel *)loginModel;

-(void)showMessageLabel;
-(void)refreshAction;
-(void)refreshActionForUriNotFoundError;
-(void)handlePreviousApprovalsDataReceivedAction;

@end