//
//  ApprovalsTimesheetHistoryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 21/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApprovalsPendingCustomCell.h"
#import "ApprovalsScrollViewController.h"
#import "MinimalTimesheetDeserializer.h"
#import "UserPermissionsStorage.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "ApproveTimesheetContainerController.h"


@class ErrorBannerViewParentPresenterHelper;


@interface ApprovalsTimesheetHistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,approvalSelectedUserDelegate>
{
    UITableView *approvalHistoryTableView;
    ApprovalsPendingCustomCell *cell;
    NSMutableArray *historyArr;
    UILabel *msgLabel;
    ApprovalsScrollViewController *scrollViewController;
    NSIndexPath *selectedIndexPath;

}
@property(nonatomic,strong)UITableView *approvalHistoryTableView;
@property(nonatomic,strong)ApprovalsPendingCustomCell *cell;
@property(nonatomic,strong) NSMutableArray *historyArr;
@property(nonatomic,strong) UILabel *msgLabel;
@property(nonatomic,strong) ApprovalsScrollViewController *scrollViewController;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, readonly) MinimalTimesheetDeserializer *minimalTimesheetDeserializer;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) ApprovalsService *approvalsService;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) ApprovalsModel *approvalsModel;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) LoginModel *loginModel;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                minimalTimesheetDeserializer:(MinimalTimesheetDeserializer *)minimalTimesheetDeserializer
                                      userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                         reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                            approvalsService:(ApprovalsService *)approvalsService
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                 userSession:(id <UserSession>)userSession
                                                  loginModel:(LoginModel *)loginModel;

-(void)showMessageLabel;
-(void)refreshAction;
-(void)refreshActionForUriNotFoundError;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
