//
//  WidgetTSViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 24/08/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Constants.h"
#import "InoutWidgetCustomCell.h"
#import "TimesheetModel.h"
#import "SupportDataModel.h"
#import "FrameworkImport.h"
#import "RepliconServiceManager.h"
#import "ApprovalTablesHeaderView.h"
#import "ApprovalTablesFooterView.h"
#import "ApproverHistoryCustomCell.h"
#import "ApproverCommentViewController.h"
#import "ApprovalActionsViewController.h"
#import "LoginModel.h"
#import "TimesheetSubmitReasonViewController.h"
#import "ApproveRejectCommentsCell.h"
#import "AddDescriptionViewController.h"
#import "TeamTimeViewController.h"
#import "WidgetAttestationCell.h"
@class TimesheetMainPageController;


typedef NS_ENUM(NSInteger,ServiceName1)
{
   
    TIMESHEET_SUMMARY_BACKGROUND_FETCH_SERVICE,
    
    
};

@interface WidgetTSViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,approvalTablesHeaderViewDelegate,approvalTablesFooterViewDelegate,WidgetAttestationCellDelegate>
{
    float heightofDisclaimerText;
}

@property(nonatomic,strong)TimesheetMainPageController *timesheetMainPageController;
@property(nonatomic,strong)UITableView *widgetTableView;
@property(nonatomic,strong)NSMutableArray *userWidgetsArray;
@property(nonatomic,strong)NSString *selectedSheet;
@property(nonatomic,strong)NSString *sheetApprovalStatus;
@property(nonatomic,strong)NSString *sheetIdentity;
@property(nonatomic,strong)NSString *dueDate;
@property(nonatomic,strong)TimesheetModel *timesheetModel;
@property(nonatomic,strong)ApprovalsModel *approvalsModel;
@property(nonatomic,strong)NSDate *timesheetStartDate;
@property(nonatomic,strong)NSDate *timesheetEndDate;
@property(nonatomic,strong)NSString *approvalsModuleName;
@property(nonatomic,weak) id parentDelegate;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;
@property(nonatomic,strong)UIView* footerView;
@property(nonatomic,strong)NSString *actionType;
@property(nonatomic,assign)BOOL isCurrentTimesheetPeriod;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *userUri;
@property(nonatomic,strong)NSString *sheetPeriod;
@property(nonatomic,assign)NSInteger currentNumberOfView;
@property(nonatomic,assign)NSUInteger totalNumberOfView;
@property(nonatomic,assign)NSInteger currentViewTag;
@property(nonatomic,strong)NSMutableArray *errorAndWarningsArray;
@property(nonatomic,strong)NSString *approverComments;
@property(nonatomic,strong)NSMutableArray *customFieldArray;
@property(nonatomic,assign)BOOL isBreakPermissionEnabled,hasBreakAccessForPunch;
@property(nonatomic,assign)BOOL isTimeoffPermissionEnabled;
@property(nonatomic,assign)BOOL isFromDeepLink;

-(void)createTableHeader;
-(void)createTableFooter;
-(void)showMessageLabel;
-(void)resetViewForApprovalsCommentsAction:(BOOL)isReset andComments:(NSString *)approverCommentsStr;
-(void)serviceFailureWithServiceID:(int)serviceID;
-(void)sendValidationCheckRequestOnlyOnChange;
-(void)setTableViewInset;
-(void)validationDataReceived:(NSNotification *)notification;
@end
