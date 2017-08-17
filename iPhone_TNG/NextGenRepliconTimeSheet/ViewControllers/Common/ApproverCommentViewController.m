//
//  ApproverCommentViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 30/06/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ApproverCommentViewController.h"
#import "Constants.h"
#import "TimesheetModel.h"
#import "TimesheetApprovalHistoryObject.h"
#import "LoginModel.h"
#import "TimeEntryViewController.h"
#import "AppDelegate.h"
#import "CurrentTimesheetViewController.h"
#import "ApprovalsScrollViewController.h"
#import "Util.h"
#import "ApproverCommentDetailCellView.h"
#import "ListOfExpenseEntriesViewController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "TimesheetMainPageController.h"
#import "TimeoffModel.h"
#import "TimeOffDetailsViewController.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import "UIView+Additions.h"


@implementation ApproverCommentViewController
@synthesize approverCommentDetailArray;
@synthesize approverCommentTableView;
@synthesize sheetIdentity;
@synthesize delegate;
@synthesize viewType;
@synthesize approvalsModuleName;

#define Each_Cell_Row_Height_44 44

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [self createApprovalList];
    [Util setToolbarLabel:self withText:RPLocalizedString(APPROVAL_DETAIL_TITLE, APPROVAL_DETAIL_TITLE)  ];

    CGRect frame;

   
    float y=15;

    frame=CGRectMake(0, y, self.view.width , self.view.bounds.size.height - y - self.tabBarController.tabBar.frame.size.height - Each_Cell_Row_Height_44);

    if (self.approverCommentTableView ==nil) {
		approverCommentTableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
	}
    self.approverCommentTableView.sectionHeaderHeight=5.0;
	[self.approverCommentTableView setDelegate:self];
	[self.approverCommentTableView setDataSource:self];
	[self.approverCommentTableView setTag:1];
	[self.approverCommentTableView setScrollEnabled:YES];
    [self.approverCommentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *bckView = [UIView new];
	[bckView setBackgroundColor:RepliconStandardBackgroundColor];
	[ self.approverCommentTableView setBackgroundView:bckView];
    [self.approverCommentTableView setAccessibilityIdentifier:@"uia_approvers_table_identifier"];
	
    [self.view addSubview:self.approverCommentTableView];
    
    self.approverCommentTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.approverCommentTableView.bounds.size.width, 0.01f)];
}

-(void)viewWillAppear:(BOOL)animated
{
    //Check For Error Banner View
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    [errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.approverCommentTableView];
}

-(void)createApprovalList{
    
    NSMutableArray *tempApprovalArray=[[NSMutableArray alloc]init];
    self.approverCommentDetailArray=tempApprovalArray;
    
    
    NSMutableArray *arrayFromDB=nil;
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]]||[delegate isKindOfClass:[WidgetTSViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        
    }
    else if ([delegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
    {
        
        ExpenseModel *timesheetModel=[[ExpenseModel alloc]init];
        arrayFromDB=[timesheetModel getAllApprovalHistoryForExpenseSheetUri:sheetIdentity];
    }
    
    else if ([delegate isKindOfClass:[TimeOffDetailsViewController class]])
    {
        TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
        arrayFromDB=[timeoffModel getAllApprovalHistoryForTimeoffUri:sheetIdentity];
    }
    else if([delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
        
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE]){
            arrayFromDB=[apprvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPreviousExpenseSheetApprovalFromDBForExpenseSheet:sheetIdentity];
            
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingExpenseSheetApprovalFromDBForExpenseSheet:sheetIdentity];
            
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingTimeoffApprovalFromDBForTimeoff:sheetIdentity];
            
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPreviousTimeoffApprovalFromDBForTimeoff:sheetIdentity];
            
        }
    } else if([delegate isKindOfClass:[MultiDayTimeOffViewController class]]) {
        ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingTimeoffApprovalFromDBForTimeoff:sheetIdentity];
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPreviousTimeoffApprovalFromDBForTimeoff:sheetIdentity];
        } else {
            TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
            arrayFromDB=[timeoffModel getAllApprovalHistoryForTimeoffUri:sheetIdentity];
        }
    }
    
    
    if ([arrayFromDB count]>0 && arrayFromDB!=nil)
    {
        for (int i=0; i<[arrayFromDB count]; i++)
        {
            NSMutableArray *approvalArray=[[NSMutableArray alloc]init];
            NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
            TimesheetApprovalHistoryObject *timesheetObj=[[TimesheetApprovalHistoryObject alloc]init];
            if ([viewType isEqualToString:@"Timesheet"]) {
                 [timesheetObj setApprovalTimesheetURI:[dataDic objectForKey:@"timesheetUri"]];
                [timesheetObj setApprovalActionStatus:[dataDic objectForKey:@"actionStatus"]];
                NSDate *entryDate=[Util convertTimestampFromDBToDate:[[dataDic objectForKey:@"actionDate"] stringValue]];
                //NSDate *entryDateInLocalTime=[Util convertUTCToLocalDate:entryDate];
                [timesheetObj setApprovalActionDate:entryDate ];
            }
            else if ([viewType isEqualToString:@"Expense"])
            {
                [timesheetObj setApprovalTimesheetURI:[dataDic objectForKey:@"expenseSheetUri"]];
                NSDate *entryDate=[Util convertTimestampFromDBToDate:[[dataDic objectForKey:@"timestamp"] stringValue]];
               // NSDate *entryDateInLocalTime=[Util convertUTCToLocalDate:entryDate];
                [timesheetObj setApprovalActionDate:entryDate ];
            }
            else if ([viewType isEqualToString:@"BookedTimeoff"])
            {
                [timesheetObj setApprovalTimesheetURI:[dataDic objectForKey:@"timeoffUri"]];
                NSDate *entryDate=[Util convertTimestampFromDBToDate:[[dataDic objectForKey:@"timestamp"] stringValue]];
               // NSDate *entryDateInLocalTime=[Util convertUTCToLocalDate:entryDate];
                [timesheetObj setApprovalActionDate:entryDate ];
            }
            [timesheetObj setApprovalActionStatusUri:[dataDic objectForKey:@"actionUri"]];
           
            [timesheetObj setApprovalActingForUser:[dataDic objectForKey:@"actingForUser"]];
            [timesheetObj setApprovalActingUser:[dataDic objectForKey:@"actingUser"]];
            [timesheetObj setApprovalComments:[dataDic objectForKey:@"comments"]];
            [approvalArray addObject:timesheetObj];
            
            [approverCommentDetailArray addObject:approvalArray];
        }
    }

}
#pragma mark -
#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //[cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return [approverCommentDetailArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return Each_Cell_Row_Height_44;
    }
    else
    {
        NSMutableArray *array=[approverCommentDetailArray objectAtIndex:indexPath.section];
         TimesheetApprovalHistoryObject *timesheetObj=[array objectAtIndex:0];
        
        NSString *comments=[timesheetObj approvalComments];
        NSString *nameStr=nil;
         NSString *approverStr=nil;
        float height=0.0;
        if ([timesheetObj approvalActingForUser]!=nil && ![[timesheetObj approvalActingForUser]isKindOfClass:[NSNull class]] && ![[timesheetObj approvalActingForUser]isEqualToString:@""])
        {
            approverStr=[NSString stringWithFormat:@" %@ %@ %@ ",[timesheetObj approvalActingUser], RPLocalizedString(OnBehalfOf, @""),[timesheetObj approvalActingForUser]];
        }
        else
        {
            approverStr=[timesheetObj approvalActingUser];
        }
        
        
        if (comments!=nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:NULL_STRING])
        {
            nameStr=[NSString stringWithFormat:@"  %@ : %@ ",approverStr,comments];
        }
        else
            nameStr=[NSString stringWithFormat:@" %@ ",approverStr];
        
        if (nameStr)
        {
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:nameStr];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (mainSize.width==0 && mainSize.height ==0)
            {
                mainSize=CGSizeMake(11.0, 18.0);
            }
            
            height= mainSize.height+20;
            if (height<44)
            {
                height=44.0;
            }
            
            return height;
            
        }
       
    }
	return 0 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
	return 2;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier;
    CellIdentifier = @"Cell";
    ApproverCommentDetailCellView *cell = (ApproverCommentDetailCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ApproverCommentDetailCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    };
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    NSMutableArray *array=[approverCommentDetailArray objectAtIndex:indexPath.section];
    TimesheetApprovalHistoryObject *timesheetObj=[array objectAtIndex:0];
    NSString *status=nil;
    NSString *timeStr=nil;
    NSString *approverStr=nil;
    NSString *comments=nil;
    
    if (indexPath.row==0)
    {
        status=[timesheetObj approvalActionStatusUri];
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH:mm:ss"];
        [timeFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [timeFormat setLocale:locale];
//        
//        NSTimeZone *localTime = [NSTimeZone systemTimeZone];
//        NSString *localTimeZoneStr=[localTime abbreviation];
        
        timeStr=[NSString stringWithFormat:@"%@ \n%@ ",[dateFormatter stringFromDate:timesheetObj.approvalActionDate],[timeFormat stringFromDate:timesheetObj.approvalActionDate]];
    }
    else
    {
        if ([timesheetObj approvalActingForUser]!=nil && ![[timesheetObj approvalActingForUser]isKindOfClass:[NSNull class]] && ![[timesheetObj approvalActingForUser]isEqualToString:@""]&& ![[timesheetObj approvalActingForUser] isEqualToString:NULL_STRING])
        {
            if ([timesheetObj approvalActingUser]!=nil && ![[timesheetObj approvalActingUser]isKindOfClass:[NSNull class]] && ![[timesheetObj approvalActingUser]isEqualToString:@""] && ![[timesheetObj approvalActingUser] isEqualToString:NULL_STRING])
            {
                approverStr=[NSString stringWithFormat:@" %@ %@ %@ ",[timesheetObj approvalActingUser], RPLocalizedString(OnBehalfOf, @""),[timesheetObj approvalActingForUser]];
            }
            else
                
                 approverStr=[NSString stringWithFormat:@" %@ %@ %@ ",SystemApprove, RPLocalizedString(OnBehalfOf, @""),[timesheetObj approvalActingForUser]];
            
        }
        else
        {
            if ([timesheetObj approvalActingUser]!=nil && ![[timesheetObj approvalActingUser]isKindOfClass:[NSNull class]] && ![[timesheetObj approvalActingUser]isEqualToString:@""] && ![[timesheetObj approvalActingUser] isEqualToString:NULL_STRING])
            {
                approverStr=[timesheetObj approvalActingUser];
            }
            else
            {
                approverStr=[NSString stringWithFormat:@"%@",RPLocalizedString(SystemApprove,@"")];
            }
        }
        if ([timesheetObj approvalComments]!=nil && ![[timesheetObj approvalComments]isKindOfClass:[NSNull class]] && ![[timesheetObj approvalComments]isEqualToString:@""]&& ![[timesheetObj approvalComments] isEqualToString:NULL_STRING])
        {
        comments=[timesheetObj approvalComments];
        }
        else
        {
            comments =[NSString stringWithFormat:@"%@",RPLocalizedString(NoComments,@"")];
        }
    }
    
    [cell createCellLayoutWithParamsStatus:status time:timeStr comments:comments approver:approverStr WithTag:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
	
}


-(void)dealloc
{
    self.approverCommentTableView.delegate=nil;
    self.approverCommentTableView.dataSource=nil;
}
@end
