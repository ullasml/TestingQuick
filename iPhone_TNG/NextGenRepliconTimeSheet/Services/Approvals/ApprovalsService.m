//
//  ApprovalsService.m
//  Replicon
//
//  Created by Ullas ML on 28/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ApprovalsService.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ApprovalsScrollViewController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsNavigationController.h"
#import "DayOffHelper.h"
@implementation ApprovalsService
@synthesize  totalRequestsSent;
@synthesize  totalRequestsServed;
@synthesize approvalsModel;
@synthesize widgetTimesheetDelegate;

- (id) init
{
	self = [super init];
	if (self != nil)
    {
		if(approvalsModel == nil)
        {
			approvalsModel = [[ApprovalsModel alloc] init];
		}
    }
	return self;
}

#pragma mark -
#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{

    NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
    
    if (errorDict!=nil)
    {
        BOOL isErrorThrown=FALSE;
        if (widgetTimesheetDelegate!=nil && ![widgetTimesheetDelegate isKindOfClass:[NSNull class]])
        {
            int receivedServiceID=[serviceID intValue];
            if (receivedServiceID==GetGen4TimesheetValidationData_Service_ID_137)
            {
                WidgetTSViewController *ctrl=(WidgetTSViewController *)widgetTimesheetDelegate;
                [ctrl serviceFailureWithServiceID:[serviceID intValue]];
                return;
            }

        }
        
        NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
        NSString *errorMsg=@"";
        for (int i=0; i<[notificationsArr count]; i++)
        {
            
            NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
            if (![errorMsg isEqualToString:@""])
            {
                errorMsg=[NSString stringWithFormat:@"%@\n%@",errorMsg,[notificationDict objectForKey:@"displayText"]];
                isErrorThrown=TRUE;
            }
            else
            {
                errorMsg=[NSString stringWithFormat:@"%@",[notificationDict objectForKey:@"displayText"]];
                isErrorThrown=TRUE;
                
            }
        }
        
        if (!isErrorThrown)
        {
            errorMsg=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
            
        }
        
        if (errorMsg!=nil && ![errorMsg isKindOfClass:[NSNull class]])
        {
            [Util errorAlert:@"" errorMessage:errorMsg];
        }
        else
        {
            
            [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
            NSString *serviceURL = [response objectForKey:@"serviceURL"];
            [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
        }
        

        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PREVIOUS_APPROVALS_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName: APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:nil];
        
    }
    else
    {
        totalRequestsServed++;
        id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
        
        if ([_serviceID intValue]== ApprovalsCountDetails_Service_ID_6)
        {
            [self handleCountOfApprovalsForUser:response];
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_COUNT_NOTIFICATION object:nil];
            return;
            
        }
        else if ([_serviceID intValue]== PendingApprovalsTimesheetSummaryDetails_Service_ID_7)
        {
            [self handleSummaryOfPendingTimesheetApprovalsForUser:response];
            return;
            
        }
        else if ([_serviceID intValue]== PendingApprovalsExpenseSummaryDetails_Service_ID_48)
        {
            [self handleSummaryOfPendingExpenseApprovalsForUser:response];
            return;
        }
        else if ([_serviceID intValue]== PendingApprovalsTimeOffsSummaryDetails_Service_ID_58)
        {
            [self handleSummaryOfPendingTimeOffsApprovalsForUser:response];
            return;
        }
        else if ([_serviceID intValue]== PreviousApprovalsTimeSheetSummaryDetails_Service_ID_8)
        {
            [self handleSummaryOfPreviousTimeSheetApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== PreviousApprovalsExpenseSummaryDetails_Service_ID_52)
        {
            [self handleSummaryOfPreviousExpenseApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== PreviousApprovalsTimeOffsSummaryDetails_Service_ID_62)
        {
            [self handleSummaryOfPreviousTimeOffsApprovalsForUser:response];
            
        }
        
        else if ([_serviceID intValue]== BulkApproveForApprovalTimesheets_Service_ID_9)
        {
            [self handleBulkApproveOfApprovalTimesheets:response];
            return;
        }
        else if ([_serviceID intValue]== BulkApproveForApprovalExpenseSheets_Service_ID_50)
        {
            [self handleBulkApproveOfApprovalExpenseSheets:response];
            return;
        }
        
        else if ([_serviceID intValue]== BulkApproveForApprovalTimeOffs_Service_ID_60)
        {
            [self handleBulkApproveOfApprovalTimeOffs:response];
            return;
        }
        
        else if ([_serviceID intValue]== BulkRejectForApprovalTimesheets_Service_ID_10)
        {
            [self handleBulkRejectOfApprovalTimesheets:response];
            return;
        }
        else if ([_serviceID intValue]== BulkRejectForApprovalExpenseSheets_Service_ID_51)
        {
            [self handleBulkRejectOfApprovalExpenseSheets:response];
            return;
        }
        else if ([_serviceID intValue]== BulkRejectForApprovalTimeOffs_Service_ID_61)
        {
            [self handleBulkRejectOfApprovalTimeOffs:response];
            return;
        }
        else if ([_serviceID intValue]== NextRecentPendingTimesheetApprovalsSummaryDetails_Service_ID_11)
        {
            [self handleSummaryOfNextPendingTimesheetApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== NextRecentPendingExpenseApprovalsSummaryDetails_Service_ID_49)
        {
            [self handleSummaryOfNextPendingExpenseApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== NextRecentPendingTimeOffsApprovalsSummaryDetails_Service_ID_59)
        {
            [self handleSummaryOfNextPendingTimeOffsApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== NextRecentPreviousApprovalsTimeSheetSummaryDetails_Service_ID_12)
        {
            [self handleSummaryOfNextPreviousTimesheetApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== NextRecentPreviousApprovalsExpenseSummaryDetails_Service_ID_53)
        {
            [self handleSummaryOfNextPreviousExpenseApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]== NextRecentPreviousApprovalsTimeOffsSummaryDetails_Service_ID_63)
        {
            [self handleSummaryOfNextPreviousTimeOffsApprovalsForUser:response];
            
        }
        else if ([_serviceID intValue]==GetApprovalPendingTimesheetSummaryDetails_Service_ID_77)
        {
            [self handleApprovalsTimeSheetSummaryDataForTimesheet:response module:APPROVALS_PENDING_TIMESHEETS_MODULE];
            return;
        }
        else if ([_serviceID intValue]==ApproveForApprovalTimesheet_Service_ID_78)
        {
            [self handleApproveOfApprovalTimesheet:response];
            return;
        }
        else if ([_serviceID intValue]==RejectForApprovalTimesheet_Service_ID_79)
        {
            [self handleRejectOfApprovalTimesheet:response];
            return;
        }
        else if ([_serviceID intValue]==GetExpenseEntryData_Service_ID_29 )
        {
            [self handleExpenseEntryFetchData:response moduleName:APPROVALS_PENDING_EXPENSES_MODULE];
            return;
        }
        else if ([_serviceID intValue]==GetTimeoffEntryData_Service_ID_64 )
        {
            [self handleTimeoffEntryFetchData:response moduleName:APPROVALS_PENDING_TIMEOFF_MODULE];
            return;
        }
        else if ([_serviceID intValue]== GetTimeOffBalanceSummaryAfterTimeOff_Service_ID_67)
        {
            [self handleTimeOffBalanceSummaryAfterTimeOff:response];
            return;
        }

        else if ([_serviceID intValue]==ApproveForApprovalTimeOff_Service_ID_80)
        {
            [self handleApproveOfApprovalTimeOff:response];
            return;
        }
        else if ([_serviceID intValue]==RejectForApprovalTimeOff_Service_ID_81)
        {
            [self handleRejectOfApprovalTimeOff:response];
            return;
        }
        else if ([_serviceID intValue]==ApproveForApprovalExpense_Service_ID_82)
        {
            [self handleApproveOfApprovalExpense:response];
            return;
        }
        else if ([_serviceID intValue]==RejectForApprovalExpense_Service_ID_83)
        {
            [self handleRejectOfApprovalExpense:response];
            return;
        }
        else if ([_serviceID intValue]==GetApprovalPreviousTimesheetSummaryDetails_Service_ID_84)
        {
            [self handleApprovalsTimeSheetSummaryDataForTimesheet:response module:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            return;
        }
        else if ([_serviceID intValue]==GetApprovalPreviousExpenseEntryData_Service_ID_85 )
        {
            [self handleExpenseEntryFetchData:response moduleName:APPROVALS_PREVIOUS_EXPENSES_MODULE];
            return;
        }
        else if ([_serviceID intValue]==GetPreviousTimeoffEntryData_Service_ID_86 )
        {
            [self handleTimeoffEntryFetchData:response moduleName:APPROVALS_PREVIOUS_TIMEOFF_MODULE];
            return;
        }
        else if ([_serviceID intValue]== GetTimesheetFormat_Service_ID_115)
        {
            [self handlePendingTimesheetFormat:response];
            return;
            
        }
        else if ([_serviceID intValue]== GetPreviousTimesheetFormat_Service_ID_116)
        {
            [self handlePreviousTimesheetFormat:response];
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            return;
            
        }//Implementation For Mobi-92//JUHI
        else if ([_serviceID intValue]== TimesheetSummaryDetailsForGen4_Service_ID_114)
        {
            //[self handlePendingTimesheetsSummaryFetchDataForGen4:response];
            return;
        }
        else if ([_serviceID intValue]== PreviousTimesheetSummaryDetailsForGen4_Service_ID_121)
        {
            //[self handlePreviousTimesheetsSummaryFetchDataForGen4:response];
            return;
        }
        else if ([_serviceID intValue]== GetPendingTimesheetApprovalCapabilities_Service_ID_126)
        {
            [self handlePendingTimesheetApprovalCapabilitiesDataForGen4:response];
            return;
        }
        else if ([_serviceID intValue]== GetPreviousTimesheetApprovalCapabilities_Service_ID_127)
        {
            [self handlePreviousTimesheetApprovalCapabilitiesDataForGen4:response];
            return;
        }
        
        else if([_serviceID intValue]== Gen4TimesheetTimeoffSummary_Service_ID_128)
        {
            //[self handlePendingTimesheetsTimeoffSummaryFetchDataForGen4:response];
            return;
        }
        else if([_serviceID intValue]== PreviousTimesheetTimeoffSummaryDetailsForGen4_Service_ID_129)
        {
            //[self handlePreviousTimesheetsTimeoffSummaryFetchDataForGen4:response];
            return;
        }
        else if([_serviceID intValue]== GetGen4PendingTimesheetCapabilityData_Service_ID_135)
        {
            [self handleGen4TimesheetApprovalsDetailsData:response isFromPending:YES];
            return;
        }
        else if([_serviceID intValue]== GetGen4PreviousTimesheetCapabilityData_Service_ID_136)
        {
            [self handleGen4TimesheetApprovalsDetailsData:response isFromPending:NO];
            return;
        }
        else if([_serviceID intValue]== Gen4PendingGetPunchesForTimesheet_Service_ID_140)
        {
            [self handleTimeSegmentsForTimesheetData:response isFromPending:YES];
            return;
        }
        else if([_serviceID intValue]== Gen4PreviousGetPunchesForTimesheet_Service_ID_141)
        {
            [self handleTimeSegmentsForTimesheetData:response isFromPending:NO];
            return;
        }
        else if ([_serviceID intValue]== GetMyNotificationSummary_148)
        {
            [self handleCountOfGetMyNotificationSummary:response];
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_COUNT_NOTIFICATION object:nil];
            return;
            
        }
        
        
    }
    
	
    if (totalRequestsServed == totalRequestsSent )
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:PREVIOUS_APPROVALS_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
        
    }
    
}


- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    
    totalRequestsServed++;
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    if (applicationState == Foreground)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            
        }
        else
        {
            
            [Util handleNSURLErrorDomainCodes:error];
        }
    }
    
   
	

    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PREVIOUS_APPROVALS_NOTIFICATION object:nil];
    
    return;

}

#pragma mark -
#pragma mark Request Methods


/************************************************************************************************************
 @Function Name   : fetchSummaryOfPendingApprovalsForUser
 @Purpose         : Called to get the user’s approvals summary data of timesheets,expenses and timeoff
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchSummaryOfTimeSheetPendingApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
     
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            [NSNull null],@"value",
                                            @"urn:replicon:timesheet-list-filter:currently-waiting-on-approver",@"filterDefinitionUri",
                                            nil];

    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"leftExpression",
                                             [NSNull null],@"operatorUri",
                                             [NSNull null],@"rightExpression",
                                             rightExpressionsValueDict,@"value",
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];

    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    /// modifying filter expression to get Project hours
    NSDictionary *secondRightleftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:timesheet-list-filter:project-duration-project-leader",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *secondRightRightExpressionDictValue=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *secondRightRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            secondRightRightExpressionDictValue,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *RightDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                              secondRightleftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              secondRightRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    NSDictionary *finalFilterExpressionDict = [NSDictionary dictionaryWithObjectsAndKeys:filterDict,@"leftExpression",@"urn:replicon:filter-operator:and",@"operatorUri",RightDictionary,@"rightExpression", nil];
    ///modifying filter expression to get Project hours - end
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"User"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"] ||
            [columnName isEqualToString:@"Project Total Time Duration"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextApprovalsPendingTimesheetsPageNo"];
        [defaults synchronize];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:timesheet-list-column:approval-due-date",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:timesheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",finalFilterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeSheetApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPendingApprovalsTimesheetSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }


}

-(void)fetchSummaryOfExpenseSheetPendingApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:expense-sheet-list-filter:currently-waiting-on-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"Employee"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||
            [columnName isEqualToString:@"Expense"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Incurred Amount"]||
            [columnName isEqualToString:@"Tracking Number"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextApprovalsPendingExpensesPageNo"];
        [defaults synchronize];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:approval-due-date",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:expense-sheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPendingApprovalsExpenseSheetSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}

-(void)fetchSummaryOfTimeOffPendingApprovalsForUser:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    

    
    
    NSDictionary *leftExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNull null],@"leftExpression",
                                                    [NSNull null],@"operatorUri",
                                                    [NSNull null],@"rightExpression",
                                                    [NSNull null],@"value",
                                                    @"urn:replicon:time-off-list-filter:currently-waiting-on-approver",@"filterDefinitionUri",
                                                    nil];
    
    
    
    
    NSDictionary *leftExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          strUserURI   ,@"uri",
                                                          [NSNull null],@"uris",
                                                          [NSNull null],@"bool",
                                                          [NSNull null],@"date",
                                                          [NSNull null],@"money",
                                                          [NSNull null],@"number",
                                                          [NSNull null],@"text",
                                                          [NSNull null],@"time",
                                                          [NSNull null],@"calendarDayDurationValue",
                                                          [NSNull null],@"workdayDurationValue",
                                                          [NSNull null],@"dateRange", nil];
    
    NSDictionary *leftExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     leftExpressionRightExpressionValueDict,@"value",
                                                     [NSNull null],@"filterDefinitionUri",
                                                     nil];
    
    
    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      leftExpressionLeftExpressionDict,@"leftExpression",
                                      @"urn:replicon:filter-operator:equal",@"operatorUri",
                                      leftExpressionRightExpressionDict,@"rightExpression",
                                      [NSNull null],@"value",
                                      [NSNull null],@"filterDefinitionUri",
                                      nil];
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     [NSNull null],@"value",
                                                     @"urn:replicon:time-off-list-filter:has-associated-timesheet",@"filterDefinitionUri",
                                                     nil];
    
    
    
    
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"uri",
                                                           [NSNull null],@"uris",
                                                           @"false",@"bool",
                                                           [NSNull null],@"date",
                                                           [NSNull null],@"money",
                                                           [NSNull null],@"number",
                                                           [NSNull null],@"text",
                                                           [NSNull null],@"time",
                                                           [NSNull null],@"calendarDayDurationValue",
                                                           [NSNull null],@"workdayDurationValue",
                                                           [NSNull null],@"dateRange", nil];
    
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNull null],@"leftExpression",
                                                      [NSNull null],@"operatorUri",
                                                      [NSNull null],@"rightExpression",
                                                      rightExpressionRightExpressionValueDict,@"value",
                                                      [NSNull null],@"filterDefinitionUri",
                                                      nil];
    
    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:equal",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];
    
    
    
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:and",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];

    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        //if ([columnName isEqualToString:@"Approval Due Date"]||
            if ([columnName isEqualToString:@"Time Off Owner"]||
            [columnName isEqualToString:@"Start Date"]||
            [columnName isEqualToString:@"End Date"]||
            [columnName isEqualToString:@"Total Duration"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"]||
            [columnName isEqualToString:@"Last Action Time (in UTC)"] ||
            [columnName isEqualToString:@"Total Effective Workdays"] ||
            [columnName isEqualToString:@"Total Effective Hours"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextApprovalsPendingTimeOffsPageNo"];
        [defaults synchronize];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:last-modified-date-time",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          //pageNum ,@"page",
                                          pageSize,@"timeOffPagesize",
                                          requestColumnUriArray,@"timeOffColumnUris",
                                          sortArray,@"timeOffSort",filterExpressionDict,@"timeOffFilterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTeamTimeOffSummary"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPendingApprovalsTimeOffsSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    

}

/************************************************************************************************************
 @Function Name   : fetchSummaryOfPreviousApprovalsForUser
 @Purpose         : Called to get the user’s approvals summary data of timesheets,expenses and timeoff
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchSummaryOfPreviousTimeSheetApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:timesheet-list-filter:historical-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    ///MI-1093
    NSDictionary *secondRightleftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNull null],@"leftExpression",
                                                 [NSNull null],@"operatorUri",
                                                 [NSNull null],@"rightExpression",
                                                 [NSNull null],@"value",
                                                 @"urn:replicon:timesheet-list-filter:project-duration-project-leader",@"filterDefinitionUri",
                                                 nil];
    
    NSDictionary *secondRightRightExpressionDictValue=[NSDictionary dictionaryWithObjectsAndKeys:
                                                       strUserURI   ,@"uri",
                                                       [NSNull null],@"uris",
                                                       [NSNull null],@"bool",
                                                       [NSNull null],@"date",
                                                       [NSNull null],@"money",
                                                       [NSNull null],@"number",
                                                       [NSNull null],@"text",
                                                       [NSNull null],@"time",
                                                       [NSNull null],@"calendarDayDurationValue",
                                                       [NSNull null],@"workdayDurationValue",
                                                       [NSNull null],@"dateRange", nil];
    
    NSDictionary *secondRightRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNull null],@"leftExpression",
                                                  [NSNull null],@"operatorUri",
                                                  [NSNull null],@"rightExpression",
                                                  secondRightRightExpressionDictValue,@"value",
                                                  [NSNull null],@"filterDefinitionUri",
                                                  nil];
    
    NSDictionary *RightDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                                   secondRightleftExpressionDict,@"leftExpression",
                                   @"urn:replicon:filter-operator:equal",@"operatorUri",
                                   secondRightRightExpressionDict,@"rightExpression",
                                   [NSNull null],@"value",
                                   [NSNull null],@"filterDefinitionUri",
                                   nil];
    
    //NSDictionary *finalRightDictionary = [NSDictionary dictionaryWithObjectsAndKeys:RightDictionary,@"leftExpression", nil];
    
    
    NSDictionary *finalFilterExpressionDict = [NSDictionary dictionaryWithObjectsAndKeys:filterDict,@"leftExpression",@"urn:replicon:filter-operator:and",@"operatorUri",RightDictionary,@"rightExpression", nil];
    
    ///

    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"User"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"] ||
            [columnName isEqualToString:@"Project Total Time Duration"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextApprovalsPreviousTimesheetsPageNo"];
        [defaults synchronize];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:timesheet-period",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:timesheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",finalFilterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeSheetApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPreviousApprovalsTimesheetSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
}

-(void)fetchSummaryOfPreviousExpenseApprovalsForUser:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:expense-sheet-list-filter:historical-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"Employee"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||
            [columnName isEqualToString:@"Expense"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Tracking Number"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextApprovalsPreviousExpensesheetsPageNo"];
        [defaults synchronize];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:date",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:expense-sheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPreviousApprovalsExpenseSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
 
}

-(void)fetchSummaryOfPreviousTimeOffsApprovalsForUser:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    

    
    NSDictionary *leftExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNull null],@"leftExpression",
                                                    [NSNull null],@"operatorUri",
                                                    [NSNull null],@"rightExpression",
                                                    [NSNull null],@"value",
                                                    @"urn:replicon:time-off-list-filter:historical-approver",@"filterDefinitionUri",
                                                    nil];
    
    
    
    
    NSDictionary *leftExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          strUserURI   ,@"uri",
                                                          [NSNull null],@"uris",
                                                          [NSNull null],@"bool",
                                                          [NSNull null],@"date",
                                                          [NSNull null],@"money",
                                                          [NSNull null],@"number",
                                                          [NSNull null],@"text",
                                                          [NSNull null],@"time",
                                                          [NSNull null],@"calendarDayDurationValue",
                                                          [NSNull null],@"workdayDurationValue",
                                                          [NSNull null],@"dateRange", nil];
    
    NSDictionary *leftExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     leftExpressionRightExpressionValueDict,@"value",
                                                     [NSNull null],@"filterDefinitionUri",
                                                     nil];
    
    
    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      leftExpressionLeftExpressionDict,@"leftExpression",
                                      @"urn:replicon:filter-operator:equal",@"operatorUri",
                                      leftExpressionRightExpressionDict,@"rightExpression",
                                      [NSNull null],@"value",
                                      [NSNull null],@"filterDefinitionUri",
                                      nil];
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     [NSNull null],@"value",
                                                     @"urn:replicon:time-off-list-filter:has-associated-timesheet",@"filterDefinitionUri",
                                                     nil];
    
    
    
    
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"uri",
                                                           [NSNull null],@"uris",
                                                           @"false",@"bool",
                                                           [NSNull null],@"date",
                                                           [NSNull null],@"money",
                                                           [NSNull null],@"number",
                                                           [NSNull null],@"text",
                                                           [NSNull null],@"time",
                                                           [NSNull null],@"calendarDayDurationValue",
                                                           [NSNull null],@"workdayDurationValue",
                                                           [NSNull null],@"dateRange", nil];
    
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNull null],@"leftExpression",
                                                      [NSNull null],@"operatorUri",
                                                      [NSNull null],@"rightExpression",
                                                      rightExpressionRightExpressionValueDict,@"value",
                                                      [NSNull null],@"filterDefinitionUri",
                                                      nil];
    
    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:equal",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];
    
    
    
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:and",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Time Off Owner"]||
            [columnName isEqualToString:@"Start Date"]||
            [columnName isEqualToString:@"End Date"]||
            [columnName isEqualToString:@"Total Duration"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"]||
            [columnName isEqualToString:@"Last Action Time (in UTC)"] ||
            [columnName isEqualToString:@"Total Effective Workdays"] ||
            [columnName isEqualToString:@"Total Effective Hours"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSNumber *pageNum=[NSNumber numberWithInt:1];
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:pageNum forKey:@"NextApprovalsPreviousTimeOffsPageNo"];
        [defaults synchronize];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:last-modified-date-time",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
       
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          //pageNum ,@"page",
                                          pageSize,@"timeOffPagesize",
                                          requestColumnUriArray,@"timeOffColumnUris",
                                          sortArray,@"timeOffSort",filterExpressionDict,@"timeOffFilterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTeamTimeOffSummary"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPreviousApprovalsTimeOffsSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
    
    
}

/************************************************************************************************************
 @Function Name   : fetchSummaryOfNextPendingApprovalsForUser
 @Purpose         : Called to get the user’s approvals summary data of next recent timesheets,expenses and timeoff
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchSummaryOfNextPendingTimesheetApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:timesheet-list-filter:currently-waiting-on-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    /// Modified filter expression to get project hours
    NSDictionary *secondRightleftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNull null],@"leftExpression",
                                                 [NSNull null],@"operatorUri",
                                                 [NSNull null],@"rightExpression",
                                                 [NSNull null],@"value",
                                                 @"urn:replicon:timesheet-list-filter:project-duration-project-leader",@"filterDefinitionUri",
                                                 nil];
    
    NSDictionary *secondRightRightExpressionDictValue=[NSDictionary dictionaryWithObjectsAndKeys:
                                                       strUserURI   ,@"uri",
                                                       [NSNull null],@"uris",
                                                       [NSNull null],@"bool",
                                                       [NSNull null],@"date",
                                                       [NSNull null],@"money",
                                                       [NSNull null],@"number",
                                                       [NSNull null],@"text",
                                                       [NSNull null],@"time",
                                                       [NSNull null],@"calendarDayDurationValue",
                                                       [NSNull null],@"workdayDurationValue",
                                                       [NSNull null],@"dateRange", nil];
    
    NSDictionary *secondRightRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNull null],@"leftExpression",
                                                  [NSNull null],@"operatorUri",
                                                  [NSNull null],@"rightExpression",
                                                  secondRightRightExpressionDictValue,@"value",
                                                  [NSNull null],@"filterDefinitionUri",
                                                  nil];
    
    NSDictionary *RightDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                                   secondRightleftExpressionDict,@"leftExpression",
                                   @"urn:replicon:filter-operator:equal",@"operatorUri",
                                   secondRightRightExpressionDict,@"rightExpression",
                                   [NSNull null],@"value",
                                   [NSNull null],@"filterDefinitionUri",
                                   nil];
    
    NSDictionary *finalFilterExpressionDict = [NSDictionary dictionaryWithObjectsAndKeys:filterDict,@"leftExpression",@"urn:replicon:filter-operator:and",@"operatorUri",RightDictionary,@"rightExpression", nil];

    /// Modified filter expression to get project hours - End
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"User"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"] ||
            [columnName isEqualToString:@"Project Total Time Duration"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
       NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextApprovalsPendingTimesheetsPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextApprovalsPendingTimesheetsPageNo"];
        [defaults synchronize];
        
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:approval-due-date",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:timesheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",finalFilterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeSheetApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPendingApprovalsTimesheetSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }

}

-(void)fetchSummaryOfNextPendingExpenseApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:expense-sheet-list-filter:currently-waiting-on-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"Employee"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||
            [columnName isEqualToString:@"Expense"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Incurred Amount"]||
            [columnName isEqualToString:@"Tracking Number"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextApprovalsPendingExpensesPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextApprovalsPendingExpensesPageNo"];
        [defaults synchronize];
        
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:approval-due-date",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:expense-sheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPendingApprovalsExpenseSheetSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
}

-(void)fetchSummaryOfNextPendingTimeOffsApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *leftExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNull null],@"leftExpression",
                                                    [NSNull null],@"operatorUri",
                                                    [NSNull null],@"rightExpression",
                                                    [NSNull null],@"value",
                                                    @"urn:replicon:time-off-list-filter:currently-waiting-on-approver",@"filterDefinitionUri",
                                                    nil];
    
    
    
    
    NSDictionary *leftExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          strUserURI   ,@"uri",
                                                          [NSNull null],@"uris",
                                                          [NSNull null],@"bool",
                                                          [NSNull null],@"date",
                                                          [NSNull null],@"money",
                                                          [NSNull null],@"number",
                                                          [NSNull null],@"text",
                                                          [NSNull null],@"time",
                                                          [NSNull null],@"calendarDayDurationValue",
                                                          [NSNull null],@"workdayDurationValue",
                                                          [NSNull null],@"dateRange", nil];
    
    NSDictionary *leftExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     leftExpressionRightExpressionValueDict,@"value",
                                                     [NSNull null],@"filterDefinitionUri",
                                                     nil];
    
    
    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      leftExpressionLeftExpressionDict,@"leftExpression",
                                      @"urn:replicon:filter-operator:equal",@"operatorUri",
                                      leftExpressionRightExpressionDict,@"rightExpression",
                                      [NSNull null],@"value",
                                      [NSNull null],@"filterDefinitionUri",
                                      nil];
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     [NSNull null],@"value",
                                                     @"urn:replicon:time-off-list-filter:has-associated-timesheet",@"filterDefinitionUri",
                                                     nil];
    
    
    
    
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"uri",
                                                           [NSNull null],@"uris",
                                                           @"false",@"bool",
                                                           [NSNull null],@"date",
                                                           [NSNull null],@"money",
                                                           [NSNull null],@"number",
                                                           [NSNull null],@"text",
                                                           [NSNull null],@"time",
                                                           [NSNull null],@"calendarDayDurationValue",
                                                           [NSNull null],@"workdayDurationValue",
                                                           [NSNull null],@"dateRange", nil];
    
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNull null],@"leftExpression",
                                                      [NSNull null],@"operatorUri",
                                                      [NSNull null],@"rightExpression",
                                                      rightExpressionRightExpressionValueDict,@"value",
                                                      [NSNull null],@"filterDefinitionUri",
                                                      nil];
    
    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:equal",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];
    
    
    
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:and",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        //if ([columnName isEqualToString:@"Approval Due Date"]||
             if ([columnName isEqualToString:@"Time Off Owner"]||
            [columnName isEqualToString:@"Start Date"]||
            [columnName isEqualToString:@"End Date"]||
            [columnName isEqualToString:@"Total Duration"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"]||
            [columnName isEqualToString:@"Last Action Time (in UTC)"] ||
            [columnName isEqualToString:@"Total Effective Workdays"] ||
            [columnName isEqualToString:@"Total Effective Hours"]
            )
        {

            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextApprovalsPendingTimeOffsPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextApprovalsPendingTimeOffsPageNo"];
        [defaults synchronize];
        
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:last-modified-date-time",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        [requestColumnUriArray addObject:@"urn:replicon:time-off-list-column:time-off-display-format"];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextTimeoffData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPendingApprovalsTimeOffsSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
}

/************************************************************************************************************
 @Function Name   : fetchSummaryOfNextPreviousApprovalsForUser
 @Purpose         : Called to get the user’s approvals summary data of next recent timesheets,expenses and timeoff
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchSummaryOfNextPreviousTimeSheetApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:timesheet-list-filter:historical-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    /// Modified filter expression to get project hours
    NSDictionary *secondRightleftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNull null],@"leftExpression",
                                                 [NSNull null],@"operatorUri",
                                                 [NSNull null],@"rightExpression",
                                                 [NSNull null],@"value",
                                                 @"urn:replicon:timesheet-list-filter:project-duration-project-leader",@"filterDefinitionUri",
                                                 nil];
    
    NSDictionary *secondRightRightExpressionDictValue=[NSDictionary dictionaryWithObjectsAndKeys:
                                                       strUserURI   ,@"uri",
                                                       [NSNull null],@"uris",
                                                       [NSNull null],@"bool",
                                                       [NSNull null],@"date",
                                                       [NSNull null],@"money",
                                                       [NSNull null],@"number",
                                                       [NSNull null],@"text",
                                                       [NSNull null],@"time",
                                                       [NSNull null],@"calendarDayDurationValue",
                                                       [NSNull null],@"workdayDurationValue",
                                                       [NSNull null],@"dateRange", nil];
    
    NSDictionary *secondRightRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNull null],@"leftExpression",
                                                  [NSNull null],@"operatorUri",
                                                  [NSNull null],@"rightExpression",
                                                  secondRightRightExpressionDictValue,@"value",
                                                  [NSNull null],@"filterDefinitionUri",
                                                  nil];
    
    NSDictionary *RightDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
                                   secondRightleftExpressionDict,@"leftExpression",
                                   @"urn:replicon:filter-operator:equal",@"operatorUri",
                                   secondRightRightExpressionDict,@"rightExpression",
                                   [NSNull null],@"value",
                                   [NSNull null],@"filterDefinitionUri",
                                   nil];
    
    NSDictionary *finalFilterExpressionDict = [NSDictionary dictionaryWithObjectsAndKeys:filterDict,@"leftExpression",@"urn:replicon:filter-operator:and",@"operatorUri",RightDictionary,@"rightExpression", nil];
    
    /// Modified filter expression to get project hours - End

    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"User"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"] ||
            [columnName isEqualToString:@"Project Total Time Duration"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextApprovalsPreviousTimesheetsPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextApprovalsPreviousTimesheetsPageNo"];
        [defaults synchronize];
        
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:timesheet-period",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:timesheet-list-column:timesheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",finalFilterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeSheetApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPreviousApprovalsTimesheetSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }

}

-(void)fetchSummaryOfNextPreviousExpenseApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null],@"leftExpression",
                                           [NSNull null],@"operatorUri",
                                           [NSNull null],@"rightExpression",
                                           [NSNull null],@"value",
                                           @"urn:replicon:expense-sheet-list-filter:historical-approver",@"filterDefinitionUri",
                                           nil];
    
    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             strUserURI   ,@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"bool",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"workdayDurationValue",
                                             [NSNull null],@"dateRange", nil];
    
    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            rightExpressionsValueDict,@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];
    
    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:equal",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Approval Due Date"]||
            [columnName isEqualToString:@"Employee"]||
            [columnName isEqualToString:@"Reimbursement Amount"]||
            [columnName isEqualToString:@"Expense"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Description"]||
            [columnName isEqualToString:@"Date"]||
            [columnName isEqualToString:@"Tracking Number"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextApprovalsPreviousExpensesheetsPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextApprovalsPreviousExpensesheetsPageNo"];
        [defaults synchronize];
        
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:date",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:expense-sheet-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:expense-sheet-list-column:tracking-number",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseApprovalSummaryData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPreviousApprovalsExpenseSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
}

-(void)fetchSummaryOfNextPreviousTimeOffsApprovalsForUser:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    
    
    
    NSDictionary *leftExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNull null],@"leftExpression",
                                                    [NSNull null],@"operatorUri",
                                                    [NSNull null],@"rightExpression",
                                                    [NSNull null],@"value",
                                                    @"urn:replicon:time-off-list-filter:historical-approver",@"filterDefinitionUri",
                                                    nil];
    
    
    
    
    NSDictionary *leftExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                          strUserURI   ,@"uri",
                                                          [NSNull null],@"uris",
                                                          [NSNull null],@"bool",
                                                          [NSNull null],@"date",
                                                          [NSNull null],@"money",
                                                          [NSNull null],@"number",
                                                          [NSNull null],@"text",
                                                          [NSNull null],@"time",
                                                          [NSNull null],@"calendarDayDurationValue",
                                                          [NSNull null],@"workdayDurationValue",
                                                          [NSNull null],@"dateRange", nil];
    
    NSDictionary *leftExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     leftExpressionRightExpressionValueDict,@"value",
                                                     [NSNull null],@"filterDefinitionUri",
                                                     nil];
    
    
    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      leftExpressionLeftExpressionDict,@"leftExpression",
                                      @"urn:replicon:filter-operator:equal",@"operatorUri",
                                      leftExpressionRightExpressionDict,@"rightExpression",
                                      [NSNull null],@"value",
                                      [NSNull null],@"filterDefinitionUri",
                                      nil];
    
    
    NSDictionary *rightExpressionLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNull null],@"leftExpression",
                                                     [NSNull null],@"operatorUri",
                                                     [NSNull null],@"rightExpression",
                                                     [NSNull null],@"value",
                                                     @"urn:replicon:time-off-list-filter:has-associated-timesheet",@"filterDefinitionUri",
                                                     nil];
    
    
    
    
    NSDictionary *rightExpressionRightExpressionValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNull null],@"uri",
                                                           [NSNull null],@"uris",
                                                           @"false",@"bool",
                                                           [NSNull null],@"date",
                                                           [NSNull null],@"money",
                                                           [NSNull null],@"number",
                                                           [NSNull null],@"text",
                                                           [NSNull null],@"time",
                                                           [NSNull null],@"calendarDayDurationValue",
                                                           [NSNull null],@"workdayDurationValue",
                                                           [NSNull null],@"dateRange", nil];
    
    NSDictionary *rightExpressionRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNull null],@"leftExpression",
                                                      [NSNull null],@"operatorUri",
                                                      [NSNull null],@"rightExpression",
                                                      rightExpressionRightExpressionValueDict,@"value",
                                                      [NSNull null],@"filterDefinitionUri",
                                                      nil];
    
    
    
    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       rightExpressionLeftExpressionDict,@"leftExpression",
                                       @"urn:replicon:filter-operator:equal",@"operatorUri",
                                       rightExpressionRightExpressionDict,@"rightExpression",
                                       [NSNull null],@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];
    
    
    
    
    NSDictionary *filterExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                        leftExpressionDict,@"leftExpression",
                                        @"urn:replicon:filter-operator:and",@"operatorUri",
                                        rightExpressionDict,@"rightExpression",
                                        [NSNull null],@"value",
                                        [NSNull null],@"filterDefinitionUri",
                                        nil];
    
    
    
    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];
        
        if ([columnName isEqualToString:@"Time Off Owner"]||
            [columnName isEqualToString:@"Start Date"]||
            [columnName isEqualToString:@"End Date"]||
            [columnName isEqualToString:@"Total Duration"]||
            [columnName isEqualToString:@"Time Off Approval Status"]||
            [columnName isEqualToString:@"Time Off"]||
            [columnName isEqualToString:@"Time Off Type"]||
            [columnName isEqualToString:@"Last Action Time (in UTC)"] ||
            [columnName isEqualToString:@"Total Effective Workdays"] ||
            [columnName isEqualToString:@"Total Effective Hours"]
            )
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }
    
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int nextFetchPageNo=[[defaults objectForKey:@"NextApprovalsPreviousTimeOffsPageNo"] intValue];
        NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
        [defaults setObject:nextFetchPageNumber forKey:@"NextApprovalsPreviousTimeOffsPageNo"];
        [defaults synchronize];
        
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];
        NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
        
        
        //Creation of Sort
        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict1=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:last-modified-date-time",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict2=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off-owner",@"columnUri",
                                           @"true",@"isAscending",
                                           nil];
        NSDictionary *sortExpressionDict3=[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"urn:replicon:time-off-list-column:time-off",@"columnUri",
                                           @"false",@"isAscending",
                                           nil];

        [sortArray addObject:sortExpressionDict1];
        [sortArray addObject:sortExpressionDict2];
        [sortArray addObject:sortExpressionDict3];
        
        [requestColumnUriArray addObject:@"urn:replicon:time-off-list-column:time-off-display-format"];
        
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          pageNum ,@"page",
                                          pageSize,@"pagesize",
                                          requestColumnUriArray,@"columnUris",
                                          sortArray,@"sort",filterExpressionDict,@"filterExpression",nil];
        NSError *err = nil;
        NSString *str = [JsonWrapper writeJson:queryDict error:&err];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetNextTimeoffData"]];
        
        
        
        DLog(@"URL:::%@",urlStr);
        [paramDict setObject:urlStr forKey:@"URLString"];
        [paramDict setObject:str forKey:@"PayLoadStr"];
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPreviousApprovalsTimeOffsSummaryData"]];
        [self setServiceDelegate:self];
        [self executeRequest];
        
    }
    
}



/************************************************************************************************************
 @Function Name   : sendRequestToApproveTimesheetsWithURI
 @Purpose         : Called to send request to approve a array of timesheets
 @param           : (NSMutableArray *)timesheetUriArray andDelegate:(id)_delegate
 @return          : nil
 *************************************************************************************************************/

-(void)sendRequestToApproveTimesheetsWithURI:(NSMutableArray *)timesheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetUriArray,@"timesheetUris",
                                      commentStr,@"comments",
                                      [Util getRandomGUID],@"unitOfWorkId",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkApproveTimesheets"]];
    
   
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ApproveTimesheet"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkApproveTimesheets"]];  
    }
    
    [self setServiceDelegate:self];
    [self executeRequest];

    
}

-(void)sendRequestToApproveExpenseSheetsWithURI:(NSMutableArray *)expenseSheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expenseSheetUriArray,@"expenseSheetUris",
                                      commentStr,@"comments",
                                      [Util getRandomGUID],@"unitOfWorkId",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkApproveExpenseSheets"]];
    
    
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    
    if ([_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ApproveExpensesheet"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkApproveExpenseSheets"]];
    }
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}

-(void)sendRequestToApproveTimeOffsWithURI:(NSMutableArray *)timeOffUriArray withComments:(id)commentStr andDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timeOffUriArray,@"timeOffUris",
                                      commentStr,@"comments",
                                      [Util getRandomGUID],@"unitOfWorkId",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkApproveTimeOffs"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ApprovalTimeOff"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkApproveTimeOffs"]];
    }
    //[self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkApproveTimeOffs"]];
    [self setServiceDelegate:self];
    [self executeRequest];
    
    
}

/************************************************************************************************************
 @Function Name   : sendRequestToRejectTimesheetsWithURI
 @Purpose         : Called to send request to reject a array of timesheets
 @param           : (NSMutableArray *)timesheetUriArray andDelegate:(id)_delegate
 @return          : nil
 *************************************************************************************************************/

-(void)sendRequestToRejectTimesheetsWithURI:(NSMutableArray *)timesheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetUriArray,@"timesheetUris",
                                      commentStr,@"comments",
                                      [Util getRandomGUID],@"unitOfWorkId",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkRejectTimesheets"]];
    
    
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
       [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"RejectTimesheet"]];
    }
    else
    {
       [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkRejectTimesheets"]]; 
    }
    
    [self setServiceDelegate:self];
    [self executeRequest];

}

-(void)sendRequestToRejectExpenseSheetsWithURI:(NSMutableArray *)expenseSheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expenseSheetUriArray,@"expenseSheetUris",
                                      commentStr,@"comments",
                                      [Util getRandomGUID],@"unitOfWorkId",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkRejectExpenseSheets"]];
    
    
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"RejectExpensesheet"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkRejectExpenseSheets"]];
    }
    [self setServiceDelegate:self];
    [self executeRequest];
    
}

-(void)sendRequestToRejectTimeOffsWithURI:(NSMutableArray *)timeOffUriArray withComments:(id)commentStr andDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timeOffUriArray,@"timeOffUris",
                                      commentStr,@"comments",
                                      [Util getRandomGUID],@"unitOfWorkId",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"BulkRejectTimeOffs"]];
    
    
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"RejectTimeOff"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"BulkRejectTimeOffs"]];
    }
    [self setServiceDelegate:self];
    [self executeRequest];
    
}
/************************************************************************************************************
 @Function Name   : fetchPendingTimeSheetSummaryDataForTimesheet
 @Purpose         : Called to get the timesheet summary data for timesheetUri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchPendingTimeSheetSummaryDataForTimesheet:(NSString *)timesheetUri withDelegate:(id)_delegate
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timesheetUri ,@"timesheetUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimesheetSummaryData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]]||
        [_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetApprovalPendingTimesheetSummaryData"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetApprovalPreviousTimesheetSummaryData"]];
    }
    
    [self setServiceDelegate:self];
    [self executeRequest];
    
}

/************************************************************************************************************
 @Function Name   : fetchApprovalPendingExpenseEntryDataForExpenseSheet
 @Purpose         : Called to get the expense entry data for expenseSheetUri
 @param           : expenseSheetUri,delegate
 @return          : nil
 *************************************************************************************************************/

-(void)fetchApprovalPendingExpenseEntryDataForExpenseSheet:(NSString *)expenseSheetUri withDelegate:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      expenseSheetUri ,@"expenseSheetUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetExpenseEntryData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]]||
        [_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetExpenseEntryData"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPreviousExpenseEntryData"]];
    }
    [self setServiceDelegate:self];
    [self executeRequest];
    
}

/************************************************************************************************************
 @Function Name   : fetchApprovalPendingTimeoffEntryDataForBookedTimeoff
 @Purpose         : Called to get the timeoff entry data for timeoffUri
 @param           : timeoffUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchApprovalPendingTimeoffEntryDataForBookedTimeoff:(NSString *)timeoffUri withDelegate:(id)_delegate
{
    
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      timeoffUri ,@"timeOffUri",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeoffEntryData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]]||
        [_delegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimeoffEntryData"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPreviousTimeoffEntryData"]];
    }
    
    [self setServiceDelegate:self];
    [self executeRequest];
    
}
/************************************************************************************************************
 @Function Name   : sendRequestToGetTimeOffBalanceSummaryForBookedTimeoff
 @Purpose         : Called to get TimeOff Balance Summary data for timeoffUri
 @param           : timeoffUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timeoffURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withUserUri:(NSString *)userURI{

    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;

    NSMutableDictionary *owner=[NSMutableDictionary dictionaryWithObjectsAndKeys:userURI,@"uri",[NSNull null],@"loginName",nil];
    id comments=@"";
    NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];
    for (int i=0;i<[timeoffEntryObjectArray count]; i++)
    {
        TimeOffDetailsObject *timeOffEntryObject=(TimeOffDetailsObject *)[timeoffEntryObjectArray objectAtIndex:i];

        comments=[timeOffEntryObject comments];
        if (comments==nil||[comments isKindOfClass:[NSNull class]])
        {
            comments=@"";
        }
        NSString *timeoffTypeUri=nil;
        NSString *timeoffTypeName=nil;

        if ([timeOffEntryObject typeIdentity]!=nil && ![[timeOffEntryObject typeIdentity] isKindOfClass:[NSNull class]])
        {
            timeoffTypeUri=[timeOffEntryObject typeIdentity];
            timeoffTypeName=[timeOffEntryObject typeName];
        }

        NSMutableDictionary *timeoffTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffTypeUri,@"uri",timeoffTypeName,@"name",nil];

        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
        [temp setDateFormat:@"yyyy-MM-dd"];

        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [temp setTimeZone:timeZone];
        [temp setLocale:locale];

        NSDate *stDt = [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedStartDate]]];
        NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[timeOffEntryObject bookedEndDate]]];



        if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
        {
            int year = 2001;
            int month =1;
            int day = 1;

            if ([timeOffEntryObject bookedStartDate] != nil && ![[timeOffEntryObject bookedStartDate]  isKindOfClass:[NSNull class]]) {
                NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
                year=[[dict objectForKey:@"year"] intValue];
                month=[[dict objectForKey:@"month"]intValue];
                day=[[dict objectForKey:@"day"]intValue];;
            }

            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];



            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil &&![startTime isKindOfClass:[NSNull class]] && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }

                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;

            }

            else
                startTimeOfDay=[NSNull null];

            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];

            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }
            id specfdict;
            id timedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                specfdict=[NSNull null];
                timedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    specfdict=[NSNull null];
                else
                    specfdict=startSpecficDuration;

                timedict=startTimeOfDay;
            }
            NSMutableDictionary *timeoffAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:specfdict,@"specificDuration",dateDict,@"date",timedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                             nil];


            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObject:timeoffAllocationEntryDict forKey:@"timeOff"];

            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];

            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         timeOff,@"singleDay",
                         [NSNull null],@"multiDay",
                         [NSNull null],@"customFieldValues",
                         [NSNull null],@"comments",
                         nil];

        }
        else {
            int year = 2001;
            int month =1;
            int day = 1;

            if ([timeOffEntryObject bookedStartDate] != nil && ![[timeOffEntryObject bookedStartDate]  isKindOfClass:[NSNull class]]) {
                NSDictionary *dict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedStartDate]];
                year=[[dict objectForKey:@"year"] intValue];
                month=[[dict objectForKey:@"month"]intValue];
                day=[[dict objectForKey:@"day"]intValue];;
            }


            NSMutableDictionary *dateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%d",year],@"year",
                                           [NSString stringWithFormat:@"%d",month],@"month",
                                           [NSString stringWithFormat:@"%d",day],@"day",
                                           nil];



            NSString *startTime=[timeOffEntryObject startTime];
            id startTimeOfDay;
            if (startTime!=nil &&![startTime isKindOfClass:[NSNull class]] && ![startTime isEqualToString:RPLocalizedString(START_AT, START_AT)])
            {
                startTime = [Util convert12HourTimeStringTo24HourTimeString:[startTime lowercaseString]];
                NSArray *inTimeComponentsArray=[startTime componentsSeparatedByString:@":"];
                int inHours=0;
                int inMinutes=0;
                int inSeconds=0;
                if ([inTimeComponentsArray count]>1)
                {
                    inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
                    inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
                }

                NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                      [NSString stringWithFormat:@"%d",inHours],@"hour",
                                                      [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                                      [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                                      nil];
                startTimeOfDay=startTimeDict;

            }

            else
                startTimeOfDay=[NSNull null];


            NSString *entryHours=[timeOffEntryObject startNumberOfHours];
            id startSpecficDuration;
            if (entryHours!=nil) {
                NSMutableDictionary *durationDict = [Util convertDecimalHoursToApiTimeDict:entryHours];
                startSpecficDuration=durationDict;
            }
            else
                startSpecficDuration=[NSNull null];
            id relativeDuration=[timeOffEntryObject startDurationEntryType];
            //Fix for defect DE15385
            if ([relativeDuration isEqualToString:PARTIAL])
            {
                relativeDuration=[NSNull null];
            }

            id startspecfdict;
            id starttimedict;
            if ([[timeOffEntryObject startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                startspecfdict=[NSNull null];
                starttimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject startDurationEntryType] isEqualToString:PARTIAL])
                    startspecfdict=[NSNull null];
                else
                    startspecfdict=startSpecficDuration;

                starttimedict=startTimeOfDay;
            }
            NSMutableDictionary *timeOffStartAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:startspecfdict,@"specificDuration",dateDict,@"date",starttimedict,@"timeOfDay",relativeDuration,@"relativeDuration",
                                                                  nil];

            int endyear = 2001;
            int endmonth =1;
            int endday = 1;

            if ([timeOffEntryObject bookedEndDate] != nil && ![[timeOffEntryObject bookedEndDate]  isKindOfClass:[NSNull class]]) {
                NSDictionary *endDict=[Util convertDateToApiDateDictionary:[timeOffEntryObject bookedEndDate]];
                endyear=[[endDict objectForKey:@"year"] intValue];
                endmonth=[[endDict objectForKey:@"month"]intValue];
                endday=[[endDict objectForKey:@"day"]intValue];;
            }



            NSMutableDictionary *enddateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%d",endyear],@"year",
                                              [NSString stringWithFormat:@"%d",endmonth],@"month",
                                              [NSString stringWithFormat:@"%d",endday],@"day",
                                              nil];



            NSString *endTime=[timeOffEntryObject endTime];
            id endTimeOfDay;
            if (endTime!=nil &&![endTime isKindOfClass:[NSNull class]]&& ![endTime isEqualToString:RPLocalizedString(END_AT, END_AT)])
            {

                endTime = [Util convert12HourTimeStringTo24HourTimeString:[endTime lowercaseString]];
                NSArray *endTimeComponentsArray=[endTime componentsSeparatedByString:@":"];
                int endHours=0;
                int endMinutes=0;
                int endSeconds=0;
                if ([endTimeComponentsArray count]>1)
                {
                    endHours=[[endTimeComponentsArray objectAtIndex:0] intValue];
                    endMinutes=[[endTimeComponentsArray objectAtIndex:1] intValue];
                }

                NSMutableDictionary *endTimeDict= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSString stringWithFormat:@"%d",endHours],@"hour",
                                                   [NSString stringWithFormat:@"%d",endMinutes],@"minute",
                                                   [NSString stringWithFormat:@"%d",endSeconds],@"second",
                                                   nil];
                endTimeOfDay=endTimeDict;

            }
            else
                endTimeOfDay=[NSNull null];
            NSString *endentryHours=[timeOffEntryObject endNumberOfHours];
            id endSpecficDuration=nil;
            if (endentryHours!=nil)
            {

                NSMutableDictionary *enddurationDict = [Util convertDecimalHoursToApiTimeDict:endentryHours];
                endSpecficDuration=enddurationDict;
            }
            else
                endSpecficDuration=[NSNull null];
            id endrelativeDuration=[timeOffEntryObject endDurationEntryType];
            //Fix for defect DE15385
            if ([endrelativeDuration isEqualToString:PARTIAL])
            {
                endrelativeDuration=[NSNull null];
            }
            id endspecfdict;
            id endtimedict;
            if ([[timeOffEntryObject endDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY]) {
                endspecfdict=[NSNull null];
                endtimedict=[NSNull null];
            }
            else
            {
                //Fix for defect DE15385
                if (![[timeOffEntryObject endDurationEntryType] isEqualToString:PARTIAL])
                    endspecfdict=[NSNull null];
                else
                    endspecfdict=endSpecficDuration;

                endtimedict=endTimeOfDay;
            }

            NSMutableDictionary *timeOffEndAllocationEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:endspecfdict,@"specificDuration",enddateDict,@"date",endtimedict,@"timeOfDay",endrelativeDuration,@"relativeDuration",
                                                                nil];



            NSMutableDictionary *timeOff=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeOffStartAllocationEntryDict,@"timeOffStart",timeOffEndAllocationEntryDict,@"timeOffEnd",nil];

            id timeoffUri;
            if ([timeOffEntryObject sheetId]!=nil && ![[timeOffEntryObject sheetId] isKindOfClass:[NSNull class]]) {
                timeoffUri=[timeOffEntryObject sheetId];
            }
            else
                timeoffUri=[NSNull null];
            NSMutableDictionary *target=[NSMutableDictionary dictionaryWithObjectsAndKeys:timeoffUri,@"uri",nil];

            entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         target,@"target",
                         owner,@"owner",
                         timeoffTypeDict,@"timeOffType",
                         [NSNull null],@"singleDay",
                         timeOff,@"multiDay",
                         [NSNull null],@"customFieldValues",
                         comments,@"comments",
                         nil];

        }

    }

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      entryDict,@"timeOff",
                                      nil];

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetTimeOffBalanceSummaryAfterTimeOff"]];

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTimeOffBalanceSummaryAfterTimeOff"]];
    [self setServiceDelegate:self];
    [self executeRequest:timeoffURI];
    
    
}

/************************************************************************************************************
 @Function Name   : fetchApprovalsTimeSheetTimeoffSummaryDataForGen4TimesheetWithStartDate
 @Purpose         : Called to get the timesheet summary data for timesheetUri
 @param           : timesheetUri,delegate
 @return          : nil
 *************************************************************************************************************/
-(void)fetchApprovalsTimeSheetTimeoffSummaryDataForGen4TimesheetWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate withDelegate:(id)_delegate withTimesheetUri:(NSString *)timesheetURI withUserUri:(NSString *)userUri isPending:(BOOL)isPending
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    NSDictionary *startDateApiDict=[Util convertDateToApiDateDictionary:startDate];
    NSDictionary *endDateApiDict=[Util convertDateToApiDateDictionary:endDate];
    //NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *dateRangeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          startDateApiDict ,@"startDate",
                                          endDateApiDict ,@"endDate",
                                          nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      userUri ,@"userUri",
                                      dateRangeDict ,@"dateRange",
                                      [NSNull null] ,@"relativeDateRangeUri",
                                      [NSNull null] ,@"relativeDateRangeAsOfDate",nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Gen4TimesheetTimeoffSummary"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if ([_delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]]||
        [_delegate isKindOfClass:[ApprovalsScrollViewController class]]||isPending)
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4TimesheetTimeoffSummary"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPreviousGen4TimesheetTimeoffSummaryData"]];
    }

    [self setServiceDelegate:self];
    [self executeRequest:timesheetURI];
    
    
}

-(void)sendRequestToGetPunchHistoryForTimesheetWithTimesheetUri:(NSString *)timesheetUri delegate:(id)delegate isPending:(BOOL)isPending
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *strUserURI=[defaults objectForKey:@"UserUri"];
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     strUserURI ,@"uri",
                                     [NSNull null],@"loginName",
                                     [NSNull null],@"parameterCorrelationId",
                                     nil];
    NSMutableDictionary *targetDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       timesheetUri ,@"uri",
                                       userDict,@"user",
                                       [NSNull null],@"date",
                                       nil];
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      targetDict ,@"target",
                                      nil];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"Gen4GetPunchesForTimesheet"]];;
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    if (isPending)
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4PendingGetPunchesForTimesheet"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"Gen4PreviousGetPunchesForTimesheet"]];
    }
    
    [self setServiceDelegate:self];
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       timesheetUri ,@"timesheetUri",
                                       nil];
    [self executeRequest:paramsDict];
}


#pragma mark -
#pragma mark Response Methods

/************************************************************************************************************
 @Function Name   : handleCountOfApprovalsForUser
 @Purpose         : To save approvals data into the NSUserdefault
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleCountOfApprovalsForUser:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    
    int pendingExpenseCount=[[responseDict objectForKey:@"pendingExpenseSheetApprovalCount"] intValue];
    int pendingTimeoffCount=[[responseDict objectForKey:@"pendingTimeOffApprovalCount"] intValue];
    int pendingTimesheetCount=[[responseDict objectForKey:@"pendingTimesheetApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:pendingExpenseCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    [defaults setObject:[NSNumber numberWithInt:pendingTimeoffCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [defaults setObject:[NSNumber numberWithInt:pendingTimesheetCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

    
}

-(void)handleCountOfGetMyNotificationSummary:(id)response
{
    NSDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil)
    {
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        
        NSDictionary *userApprovalNotificationSummaryDict=[responseDict objectForKey:@"userApprovalNotificationSummary"];
        
        if (userApprovalNotificationSummaryDict!=nil)
        {
            int pendingExpenseCount=[[userApprovalNotificationSummaryDict objectForKey:@"pendingExpenseSheetApprovalCount"] intValue];
            int pendingTimeoffCount=[[userApprovalNotificationSummaryDict objectForKey:@"pendingTimeOffApprovalCount"] intValue];
            int pendingTimesheetCount=[[userApprovalNotificationSummaryDict objectForKey:@"pendingTimesheetApprovalCount"] intValue];
            
            [defaults setObject:[NSNumber numberWithInt:pendingExpenseCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
            [defaults setObject:[NSNumber numberWithInt:pendingTimeoffCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
            [defaults setObject:[NSNumber numberWithInt:pendingTimesheetCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];

        }
        
        NSDictionary *userExpenseNotificationSummaryDict=[responseDict objectForKey:@"userExpenseNotificationSummary"];
        
        if (userExpenseNotificationSummaryDict!=nil)
        {
            int rejectedExpenseSheetCount=[[userExpenseNotificationSummaryDict objectForKey:@"rejectedExpenseSheetCount"] intValue];
            
            
            [defaults setObject:[NSNumber numberWithInt:rejectedExpenseSheetCount] forKey:REJECTED_EXPENSE_SHEETS_COUNT_KEY];

        }
        
        NSDictionary *userTimeOffNotificationSummaryDict=[responseDict objectForKey:@"userTimeOffNotificationSummary"];
        
        if (userTimeOffNotificationSummaryDict!=nil)
        {
            int rejectedTimeOffBookingCount=[[userTimeOffNotificationSummaryDict objectForKey:@"rejectedTimeOffBookingCount"] intValue];
            
            
            [defaults setObject:[NSNumber numberWithInt:rejectedTimeOffBookingCount] forKey:REJECTED_TIMEOFF_BOOKING_COUNT_KEY];
            

        }
        
        NSDictionary *userTimesheetNotificationSummaryDict=[responseDict objectForKey:@"userTimesheetNotificationSummary"];
        
        if (userTimesheetNotificationSummaryDict!=nil)
        {
            int rejectedTimesheetCount=[[userTimesheetNotificationSummaryDict objectForKey:@"rejectedTimesheetCount"] intValue];
            
            int timesheetPastDueCount=[[userTimesheetNotificationSummaryDict objectForKey:@"timesheetPastDueCount"] intValue];
            
            
            [defaults setObject:[NSNumber numberWithInt:timesheetPastDueCount] forKey:TIMESHEET_PAST_DUE_COUNT_KEY];
            [defaults setObject:[NSNumber numberWithInt:rejectedTimesheetCount] forKey:REJECTED_TIMESHEET_COUNT_KEY];
            

        }
        
        [defaults synchronize];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
        
    }
}

/************************************************************************************************************
 @Function Name   : handleSummaryOfPendingApprovalsForUser
 @Purpose         : To save approvals summary data into the db
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleSummaryOfPendingTimesheetApprovalsForUser:(id)response
{
    [approvalsModel deleteAllApprovalPendingTimesheetsFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"pendingApprovalsTSDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePendingApprovalTimeSheetSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
}

-(void)handleSummaryOfPendingExpenseApprovalsForUser:(id)response
{
    [approvalsModel deleteAllApprovalPendingExpenseSheetsFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"pendingApprovalsExpDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePendingApprovalExpenseSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
}

-(void)handleSummaryOfPendingTimeOffsApprovalsForUser:(id)response
{
    [approvalsModel deleteAllApprovalPendingTimeOffsFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=responseDict[@"timeOff"][@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"pendingApprovalsTODownloadCount"];
        [defaults synchronize];
        
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        [timesheetModel saveTimeoffTypeDetailDataToDB:responseDict[@"timeOffTypeDetails"]];
        
        [approvalsModel savePendingApprovalTimeOffsSummaryDataFromApiToDB:responseDict[@"timeOff"]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
}

/************************************************************************************************************
 @Function Name   : handleSummaryOfPreviousApprovalsForUser
 @Purpose         : To save approvals summary data into the db
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleSummaryOfPreviousTimeSheetApprovalsForUser:(id)response
{
    [approvalsModel deleteAllApprovalPreviousTimesheetsFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"PreviousApprovalsTSDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePreviousApprovalTimeSheetSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
}

-(void)handleSummaryOfPreviousExpenseApprovalsForUser:(id)response
{
    [approvalsModel deleteAllApprovalPreviousExpenseFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *expenseSheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:expenseSheetsCount forKey:@"PreviousApprovalsExpDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePreviousApprovalExpenseSheetSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
}

-(void)handleSummaryOfPreviousTimeOffsApprovalsForUser:(id)response
{
    [approvalsModel deleteAllApprovalPreviousTimeOffsFromDB];
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=responseDict[@"timeOff"][@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timeOffsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timeOffsCount forKey:@"PreviousApprovalsTODownloadCount"];
        [defaults synchronize];
        
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        [timesheetModel saveTimeoffTypeDetailDataToDB:responseDict[@"timeOffTypeDetails"]];

        
        [approvalsModel savePreviousApprovalTimeOffsSummaryDataFromApiToDB:responseDict[@"timeOff"]];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
}

/************************************************************************************************************
 @Function Name   : handleSummaryOfNextPendingApprovalsForUser
 @Purpose         : To save approvals summary data into the db
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleSummaryOfNextPendingTimesheetApprovalsForUser:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"pendingApprovalsTSDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePendingApprovalTimeSheetSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
}

-(void)handleSummaryOfNextPendingExpenseApprovalsForUser:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *expensesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:expensesheetsCount forKey:@"pendingApprovalsExpDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePendingApprovalExpenseSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
}

-(void)handleSummaryOfNextPendingTimeOffsApprovalsForUser:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timeOffsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timeOffsCount forKey:@"pendingApprovalsTODownloadCount"];
        [defaults synchronize];
        

        
        [approvalsModel savePendingApprovalTimeOffsSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
}

/************************************************************************************************************
 @Function Name   : handleSummaryOfPreviousApprovalsForUser
 @Purpose         : To save approvals summary data into the db
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleSummaryOfNextPreviousTimesheetApprovalsForUser:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"PreviousApprovalsTSDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePreviousApprovalTimeSheetSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
}

-(void)handleSummaryOfNextPreviousExpenseApprovalsForUser:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timesheetsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timesheetsCount forKey:@"PreviousApprovalsExpDownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePreviousApprovalExpenseSheetSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
}

-(void)handleSummaryOfNextPreviousTimeOffsApprovalsForUser:(id)response
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *timeOffsCount=[NSNumber numberWithUnsignedInteger:[rowsArray count]];
        [defaults setObject:timeOffsCount forKey:@"PreviousApprovalsTODownloadCount"];
        [defaults synchronize];
        
        [approvalsModel savePreviousApprovalTimeOffsSummaryDataFromApiToDB:responseDict];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
}


/************************************************************************************************************
 @Function Name   : handleBulkApproveOfApprovalTimesheets
 @Purpose         : To handle response of bulk approved timesheets by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleBulkApproveOfApprovalTimesheets:(id)response
{
   [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];

    NSMutableDictionary *responseDict=response[@"response"][@"d"][@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];

    int timesheetsNeedingApprovalCount=[response[@"response"][@"d"][@"timesheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timesheetsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

//    [approvalsModel deleteAllApprovalPendingTimesheetsFromDB];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
     AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
    NSArray *approvalsControllers = approvalsNavController.viewControllers;
    if(approvalsControllers.count==2)
    {
        UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
        if ([viewCtrl isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
        {
            ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController = (ApprovalsPendingTimesheetViewController *)viewCtrl;
            [approvalsPendingTimesheetViewController.selectedSheetsIDsArr removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] removeObserver: approvalsPendingTimesheetViewController name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: approvalsPendingTimesheetViewController
                                                     selector: @selector(handlePendingApprovalsDataReceivedAction)
                                                         name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                                       object: nil];
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }
    
    
    [self fetchSummaryOfTimeSheetPendingApprovalsForUser:nil];
    if ([errorArray count]!=0)
    {
        
        /*NSString *result=@"";
        for (int i=0; i<[errorArray count]; i++)
        {
            NSDictionary *dict=[errorArray objectAtIndex:i];
            NSDictionary *notificationDict=[[dict objectForKey:@"notifications"] objectAtIndex:0];
            NSString *errorUriStr=[[notificationDict objectForKey:@"context"] objectForKey:@"displayText"];
            result = [result stringByAppendingString:[NSString stringWithFormat: @"%@\n", errorUriStr]];

        }*/
        [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Approve_Timesheet_Error, Approve_Timesheet_Error)]];
    }
    
    
    
    
}

-(void)handleBulkApproveOfApprovalExpenseSheets:(id)response
{
    NSMutableDictionary *responseDict=response[@"response"][@"d"][@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];

    int expensesNeedingApprovalCount=[response[@"response"][@"d"][@"expenseSheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:expensesNeedingApprovalCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

    [approvalsModel deleteAllApprovalPendingExpenseSheetsFromDB];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
    NSArray *approvalsControllers = approvalsNavController.viewControllers;
    if(approvalsControllers.count==2)
    {
        UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
        if ([viewCtrl isKindOfClass:[ApprovalsPendingExpenseViewController class]])
        {
            ApprovalsPendingExpenseViewController *approvalsPendingExpenseViewController = (ApprovalsPendingExpenseViewController *)viewCtrl;
            [approvalsPendingExpenseViewController.selectedSheetsIDsArr removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] removeObserver: approvalsPendingExpenseViewController name: PENDING_APPROVALS_EXPENSE_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: approvalsPendingExpenseViewController
                                                     selector: @selector(handlePendingApprovalsDataReceivedAction)
                                                         name: PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                                       object: nil];
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }

    [self fetchSummaryOfExpenseSheetPendingApprovalsForUser:nil];
    if ([errorArray count]!=0)
    {
        
        /*NSString *result=@"";
         for (int i=0; i<[errorArray count]; i++)
         {
         NSDictionary *dict=[errorArray objectAtIndex:i];
         NSDictionary *notificationDict=[[dict objectForKey:@"notifications"] objectAtIndex:0];
         NSString *errorUriStr=[[notificationDict objectForKey:@"context"] objectForKey:@"displayText"];
         result = [result stringByAppendingString:[NSString stringWithFormat: @"%@\n", errorUriStr]];
         
         }*/
        [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Approve_Expense_Error, Approve_Expense_Error)]];
    }
    
}

-(void)handleBulkApproveOfApprovalTimeOffs:(id)response
{
    NSMutableDictionary *responseDict=response[@"response"][@"d"][@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];

    int timeoffsNeedingApprovalCount=[response[@"response"][@"d"][@"timeOffsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timeoffsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

    [approvalsModel deleteAllApprovalPendingTimeOffsFromDB];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
    NSArray *approvalsControllers = approvalsNavController.viewControllers;
    if(approvalsControllers.count==2)
    {
        UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
        if ([viewCtrl isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
        {
            ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffViewController = (ApprovalsPendingTimeOffViewController *)viewCtrl;
            [approvalsPendingTimeOffViewController.selectedSheetsIDsArr removeAllObjects];
            [[NSNotificationCenter defaultCenter] removeObserver: approvalsPendingTimeOffViewController name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: approvalsPendingTimeOffViewController
                                                     selector: @selector(handlePendingApprovalsDataReceivedAction)
                                                         name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                                       object: nil];
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }

    [self fetchSummaryOfTimeOffPendingApprovalsForUser:nil];
    if ([errorArray count]!=0)
    {
        
        /*NSString *result=@"";
         for (int i=0; i<[errorArray count]; i++)
         {
         NSDictionary *dict=[errorArray objectAtIndex:i];
         NSDictionary *notificationDict=[[dict objectForKey:@"notifications"] objectAtIndex:0];
         NSString *errorUriStr=[[notificationDict objectForKey:@"context"] objectForKey:@"displayText"];
         result = [result stringByAppendingString:[NSString stringWithFormat: @"%@\n", errorUriStr]];
         
         }*/
        [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Approve_TimeOff_Error, Approve_TimeOff_Error)]];
    }
    
    
    
    
}

/************************************************************************************************************
 @Function Name   : handleBulkRejectOfApprovalTimesheets
 @Purpose         : To handle response of bulk reject timesheets by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleBulkRejectOfApprovalTimesheets:(id)response
{
   [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];

    NSMutableDictionary *responseDict=response[@"response"][@"d"][@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];

    int timesheetsNeedingApprovalCount=[response[@"response"][@"d"][@"timesheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timesheetsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

//    [approvalsModel deleteAllApprovalPendingTimesheetsFromDB];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
    NSArray *approvalsControllers = approvalsNavController.viewControllers;
    if (approvalsControllers.count==2) {
        UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
        if ([viewCtrl isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
        {
            ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController = (ApprovalsPendingTimesheetViewController *)viewCtrl;
            [approvalsPendingTimesheetViewController.selectedSheetsIDsArr removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] removeObserver: approvalsPendingTimesheetViewController name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: approvalsPendingTimesheetViewController
                                                     selector: @selector(handlePendingApprovalsDataReceivedAction)
                                                         name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                                       object: nil];
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }

    [self fetchSummaryOfTimeSheetPendingApprovalsForUser:nil];
    if ([errorArray count]!=0)
    {
        /*NSString *result=@"";
        for (int i=0; i<[errorArray count]; i++)
        {
            NSDictionary *dict=[errorArray objectAtIndex:i];
            NSDictionary *notificationDict=[[dict objectForKey:@"notifications"] objectAtIndex:0];
            NSString *errorUriStr=[[notificationDict objectForKey:@"context"] objectForKey:@"displayText"];
            result = [result stringByAppendingString:[NSString stringWithFormat: @"%@\n", errorUriStr]];
            
        }*/
         [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Reject_Timesheet_Error, Reject_Timesheet_Error)]];
    }

}

-(void)handleBulkRejectOfApprovalExpenseSheets:(id)response
{
    NSMutableDictionary *responseDict=response[@"response"][@"d"][@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];

    int expensesNeedingApprovalCount=[response[@"response"][@"d"][@"expenseSheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:expensesNeedingApprovalCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

    [approvalsModel deleteAllApprovalPendingExpenseSheetsFromDB];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
    NSArray *approvalsControllers = approvalsNavController.viewControllers;
    if(approvalsControllers.count==2)
    {
        UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
        if ([viewCtrl isKindOfClass:[ApprovalsPendingExpenseViewController class]])
        {
            ApprovalsPendingExpenseViewController *approvalsPendingExpenseViewController = (ApprovalsPendingExpenseViewController *)viewCtrl;
            [approvalsPendingExpenseViewController.selectedSheetsIDsArr removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] removeObserver: approvalsPendingExpenseViewController name: PENDING_APPROVALS_EXPENSE_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: approvalsPendingExpenseViewController
                                                     selector: @selector(handlePendingApprovalsDataReceivedAction)
                                                         name: PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                                       object: nil];
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }

    [self fetchSummaryOfExpenseSheetPendingApprovalsForUser:nil];
    if ([errorArray count]!=0)
    {
        /*NSString *result=@"";
         for (int i=0; i<[errorArray count]; i++)
         {
         NSDictionary *dict=[errorArray objectAtIndex:i];
         NSDictionary *notificationDict=[[dict objectForKey:@"notifications"] objectAtIndex:0];
         NSString *errorUriStr=[[notificationDict objectForKey:@"context"] objectForKey:@"displayText"];
         result = [result stringByAppendingString:[NSString stringWithFormat: @"%@\n", errorUriStr]];
         
         }*/
         [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Reject_Expense_Error, Reject_Expense_Error)]];
    }
    
}

-(void)handleBulkRejectOfApprovalTimeOffs:(id)response

{
    NSMutableDictionary *responseDict=response[@"response"][@"d"][@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];

    int timeoffsNeedingApprovalCount=[response[@"response"][@"d"][@"timeOffsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timeoffsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

    [approvalsModel deleteAllApprovalPendingTimeOffsFromDB];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
    NSArray *approvalsControllers = approvalsNavController.viewControllers;
    if (approvalsControllers.count==2) {
        UIViewController *viewCtrl=(UIViewController*)[approvalsControllers objectAtIndex:1];
        if ([viewCtrl isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
        {
            ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffViewController = (ApprovalsPendingTimeOffViewController *)viewCtrl;
            [approvalsPendingTimeOffViewController.selectedSheetsIDsArr removeAllObjects];
            
            [[NSNotificationCenter defaultCenter] removeObserver: approvalsPendingTimeOffViewController name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: approvalsPendingTimeOffViewController
                                                     selector: @selector(handlePendingApprovalsDataReceivedAction)
                                                         name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                                       object: nil];
        }
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }

    [self fetchSummaryOfTimeOffPendingApprovalsForUser:nil];
    if ([errorArray count]!=0)
    {
        /*NSString *result=@"";
         for (int i=0; i<[errorArray count]; i++)
         {
         NSDictionary *dict=[errorArray objectAtIndex:i];
         NSDictionary *notificationDict=[[dict objectForKey:@"notifications"] objectAtIndex:0];
         NSString *errorUriStr=[[notificationDict objectForKey:@"context"] objectForKey:@"displayText"];
         result = [result stringByAppendingString:[NSString stringWithFormat: @"%@\n", errorUriStr]];
         
         }*/
        [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Reject_TimeOff_Error, Reject_TimeOff_Error)]];    }
}
/************************************************************************************************************
 @Function Name   : handleApprovalsPendingTimeSheetSummaryDataForTimesheet
 @Purpose         : To handle response of approvals pending timesheets by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handleApprovalsTimeSheetSummaryDataForTimesheet:(id)response module:(NSString *)moduleName
{

    BOOL isFromTimeSheetServiceFetchTimeSheetSummaryDataForTimesheet=NO;
    NSMutableDictionary *refDict=[response objectForKey:@"refDict"];
    if (refDict!=nil)
    {
        if ([refDict objectForKey:@"params"]!=nil && ![refDict isKindOfClass:[NSNull class]]) {
            isFromTimeSheetServiceFetchTimeSheetSummaryDataForTimesheet=[[refDict objectForKey:@"params"]boolValue];
        }
        
    }
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"] objectForKey:@"d"];
    NSString *timesheetUri=nil;
    if ([responseDict objectForKey:@"approvalDetails"]!=nil && ![[responseDict objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
    {
        timesheetUri=[[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"timesheet"] objectForKey:@"uri"];
    }
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetUri isPending:TRUE];

    }
    else
    {
        [approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetUri isPending:FALSE];
    }

    
    if ([responseDict count]>0 && responseDict!=nil)
    {
        BOOL isPending=FALSE;
        
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
             [approvalsModel savePendingApprovalTimeSheetSummaryDetailsDataFromApiToDB:responseDict];
            isPending=TRUE;
        }
        else
        {
            [approvalsModel savePreviousApprovalTimeSheetSummaryDetailsDataFromApiToDB:responseDict];
            isPending=FALSE;
        }
       
        NSDictionary *timesheetdaysoff = responseDict[@"timesheetDaysOff"];
        NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoff];

        NSDictionary *widgetTimesheetDetailsDict=[responseDict objectForKey:@"widgetTimesheetDetails"];
        if (widgetTimesheetDetailsDict!=nil && ![widgetTimesheetDetailsDict isKindOfClass:[NSNull class]])
        {
            if ([widgetTimesheetDetailsDict objectForKey:@"attestationStatus"]!=nil && ![[widgetTimesheetDetailsDict objectForKey:@"attestationStatus"] isKindOfClass:[NSNull class]])
            {
                BOOL attestationStatus=[[widgetTimesheetDetailsDict objectForKey:@"attestationStatus"]boolValue];
                [self.approvalsModel updateAttestationStatusForTimesheetIdentity:timesheetUri withStatus:attestationStatus isPending:isPending];
            }
           
            
            NSMutableArray *widgetTimeEntries=[widgetTimesheetDetailsDict objectForKey:@"timeEntries"];
            NSMutableArray *timeEntryProjectTaskAncestryDetailsArr=[widgetTimesheetDetailsDict objectForKey:@"timeEntryProjectTaskAncestryDetails"];
           NSDictionary *timePunchTimeSegmentDetailsDict=[widgetTimesheetDetailsDict objectForKey:@"timePunchTimeSegmentDetails"];
            
            NSMutableArray *enableWidgetsArr=nil;
            
            if (isPending)
            {
                enableWidgetsArr=[approvalsModel getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
            }
            else
            {
                  enableWidgetsArr=[approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
            }
           
        
            
            
            
            
            for(NSDictionary *widgetUriDict in enableWidgetsArr)
            {
                NSString *format=@"";
                
                if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
                {
                    format=GEN4_STANDARD_TIMESHEET;
                     [self handleTimesheetsSummaryFetchDataForGen4:widgetTimeEntries withTimesheetUri:timesheetUri andTimeEntryProjectTaskAncestryDetails:timeEntryProjectTaskAncestryDetailsArr andModuleName:moduleName andDayOffList:dayOffList];
                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
                {
                    format=GEN4_INOUT_TIMESHEET;
                     [self handleTimesheetsSummaryFetchDataForGen4:widgetTimeEntries withTimesheetUri:timesheetUri andTimeEntryProjectTaskAncestryDetails:timeEntryProjectTaskAncestryDetailsArr andModuleName:moduleName andDayOffList:dayOffList];
                    
                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
                {
                    format=GEN4_EXT_INOUT_TIMESHEET;
                    [self handleTimesheetsSummaryFetchDataForGen4:widgetTimeEntries withTimesheetUri:timesheetUri andTimeEntryProjectTaskAncestryDetails:timeEntryProjectTaskAncestryDetailsArr andModuleName:moduleName andDayOffList:dayOffList];

                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
                {
                    format=GEN4_PUNCH_WIDGET_TIMESHEET;
                    [self handleTimeSegmentsForTimesheetDataForGen4:timePunchTimeSegmentDetailsDict isFromPending:isPending forTimeSheetUri:timesheetUri];
                    
                }
                else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
                {
                    format=GEN4_DAILY_WIDGET_TIMESHEET;
                    [self handleDailyWidgetSummaryFetchDataForGen4:widgetTimesheetDetailsDict[@"dailyWidgetTimeEntries"] withTimesheetUri:timesheetUri andModuleName:moduleName andDayOffList:dayOffList];

                }
            }
           
            
            NSMutableArray *timeOffsArr=[responseDict objectForKey:@"overlappingTimeoff"];
            if ([timeOffsArr count]>0)
            {
                [self handleTimesheetsTimeoffSummaryFetchDataForGen4:timeOffsArr withTimesheetUri:timesheetUri andModuleName:moduleName andDayOffList:dayOffList];
                
            }
            
        }
        
        NSDictionary *standardTimesheetDetailsDict=[responseDict objectForKey:@"standardTimesheetDetails"];
        if (standardTimesheetDetailsDict!=nil && ![standardTimesheetDetailsDict isKindOfClass:[NSNull class]])
        {
            NSMutableArray *timeOffsArr=[responseDict objectForKey:@"overlappingTimeoff"];
            if ([timeOffsArr count]>0)
            {
                [approvalsModel saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:timeOffsArr withTimesheetUri:timesheetUri andFormat:STANDARD_TIMESHEET andIsPending:isPending];
            }
        }
        
        NSDictionary *inOutTimesheetDetailsDict=[responseDict objectForKey:@"inOutTimesheetDetails"];
        if (inOutTimesheetDetailsDict!=nil && ![inOutTimesheetDetailsDict isKindOfClass:[NSNull class]])
        {
            NSMutableArray *timeOffsArr=[responseDict objectForKey:@"overlappingTimeoff"];
            if ([timeOffsArr count]>0)
            {
                BOOL isExtendedInOutUserPermission=NO;
                NSDictionary *timesheetCapabilities=[responseDict objectForKey:@"capabilities"];
                if ([[timesheetCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES || [[timesheetCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES  )
                {
                    isExtendedInOutUserPermission=YES;
                }
                if (isExtendedInOutUserPermission)
                {
                    [approvalsModel saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:timeOffsArr withTimesheetUri:timesheetUri andFormat:EXTENDED_INOUT_TIMESHEET andIsPending:isPending];
                }
                else
                {
                    [approvalsModel saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:timeOffsArr withTimesheetUri:timesheetUri andFormat:INOUT_TIMESHEET andIsPending:isPending];
                }
                
                
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:responseDict];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil];

}
/************************************************************************************************************
 @Function Name   : handleApproveOfApprovalTimesheet
 @Purpose         : To handle response of bulk approved timesheets by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleApproveOfApprovalTimesheet:(id)response
{
    NSMutableDictionary *responseData=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *responseDict=[responseData objectForKey:@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];
    NSMutableArray *successRejectUriArray=[responseDict objectForKey:@"completedUris"];
    if ([successRejectUriArray count]!=0)
    {
        NSString *timesheetUri=[successRejectUriArray objectAtIndex:0];
        [approvalsModel deleteApprovalPendingTimesheetsFromDBWithTimesheetUri:timesheetUri];
    }
    if ([errorArray count]!=0)
    {
         [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Approve_Timesheet_Error, Approve_Timesheet_Error)]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_NOTIFICATION object:nil];

    int timesheetsNeedingApprovalCount=[response[@"response"][@"d"][@"timesheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timesheetsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
    
    
}
/************************************************************************************************************
 @Function Name   : handleRejectOfApprovalTimesheet
 @Purpose         : To handle response of bulk reject timesheets by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleRejectOfApprovalTimesheet:(id)response
{
    NSMutableDictionary *responseData=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *responseDict=[responseData objectForKey:@"approvalBatchResults"];
    NSMutableArray *successRejectUriArray=[responseDict objectForKey:@"completedUris"];
    if ([successRejectUriArray count]!=0)
    {
        NSString *timesheetUri=[successRejectUriArray objectAtIndex:0];
        [approvalsModel deleteApprovalPendingTimesheetsFromDBWithTimesheetUri:timesheetUri];
    }
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];
    if ([errorArray count]!=0)
    {
         [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Reject_Timesheet_Error, Reject_Timesheet_Error)]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_NOTIFICATION object:nil];

    int timesheetsNeedingApprovalCount=[response[@"response"][@"d"][@"timesheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timesheetsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
    
}

/************************************************************************************************************
 @Function Name   : handleExpenseEntryFetchData
 @Purpose         : To save expense entry data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleExpenseEntryFetchData:(id)response moduleName:(NSString *)approvalsModuleName
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        
        [approvalsModel saveExpenseEntryDataFromApiToDB:responseDict moduleName:approvalsModuleName];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
    
    
    
}
/************************************************************************************************************
 @Function Name   : handleTimeoffEntryFetchData
 @Purpose         : To save timeoff entry data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleTimeoffEntryFetchData:(id)response moduleName:(NSString *)approvalsModuleName
{
    
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        [approvalsModel saveTimeOffEntryDataFromApiToDB:responseDict moduleName:approvalsModuleName];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
-(void)handleTimeOffBalanceSummaryAfterTimeOff:(id)response
{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSString *timeOffUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableDictionary *balanceResponseDict=[NSMutableDictionary dictionary];
        NSString *balanceTotalDays=nil;
        NSString *requestedTotalDays=nil;
        NSString *balanceTotalHour=nil;
        NSString *requestedTotalHour=nil;
        //Fix for DE15147
        if ([responseDict objectForKey:@"balanceSummaryAfterTimeOff"]!=nil && ![[responseDict objectForKey:@"balanceSummaryAfterTimeOff"]isKindOfClass:[NSNull class]])
        {

            NSString *timeOffDisplayFormatUri=responseDict[@"balanceSummaryAfterTimeOff"][@"timeOffDisplayFormatUri"];

            [balanceResponseDict setObject:timeOffDisplayFormatUri forKey:@"timeOffDisplayFormatUri"];

            if ([[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]!=nil &&![[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]isKindOfClass:[NSNull class]])
            {
                balanceTotalDays=[[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"decimalWorkdays"];
                NSDictionary *hoursDict=[[[responseDict objectForKey:@"balanceSummaryAfterTimeOff"] objectForKey:@"timeRemaining"]objectForKey:@"calendarDayDuration"];
                balanceTotalHour=[Util getRoundedValueFromDecimalPlaces:[[Util convertApiTimeDictToDecimal:hoursDict] newDoubleValue]withDecimalPlaces:2];
            }
        }
        if ([responseDict objectForKey:@"totalDurationOfTimeOff"]!=nil && ![[responseDict objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]])
        {
            if ([responseDict objectForKey:@"totalDurationOfTimeOff"]!=nil &&![[responseDict objectForKey:@"totalDurationOfTimeOff"]isKindOfClass:[NSNull class]]) {
                requestedTotalDays=[[responseDict objectForKey:@"totalDurationOfTimeOff"] objectForKey:@"decimalWorkdays"];
                NSDictionary *hoursDict=[[responseDict objectForKey:@"totalDurationOfTimeOff"]objectForKey:@"calendarDayDuration"];
                requestedTotalHour=[Util getRoundedValueFromDecimalPlaces:[[Util convertApiTimeDictToDecimal:hoursDict] newDoubleValue]withDecimalPlaces:2];
            }
        }

        if (balanceTotalDays!=nil &&![balanceTotalDays isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:balanceTotalDays forKey:@"balanceRemainingDays"];
        }
        if (requestedTotalDays!=nil &&![requestedTotalDays isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:requestedTotalDays forKey:@"requestedDays"];
        }
        if (balanceTotalHour!=nil &&![balanceTotalHour isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:balanceTotalHour forKey:@"balanceRemainingHours"];
        }
        if (requestedTotalHour!=nil &&![requestedTotalHour isKindOfClass:[NSNull class]]) {
            [balanceResponseDict setObject:requestedTotalHour forKey:@"requestedHours"];
        }

        [balanceResponseDict setObject:timeOffUri forKey:@"timeOffUri"];

        [[NSNotificationCenter defaultCenter] postNotificationName: APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:balanceResponseDict];
        
        
        
    }
    
}
/************************************************************************************************************
 @Function Name   : handleApproveOfApprovalTimeOff
 @Purpose         : To handle response of bulk approved TimeOff by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleApproveOfApprovalTimeOff:(id)response
{
    NSMutableDictionary *responseData=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *responseDict=[responseData objectForKey:@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];
    NSMutableArray *successRejectUriArray=[responseDict objectForKey:@"completedUris"];
    if ([successRejectUriArray count]!=0)
    {
        NSString *timeoffUri=[successRejectUriArray objectAtIndex:0];
        [approvalsModel deleteApprovalPendingTimeOffFromDBWithTimeoffUri:timeoffUri];
    }
    if ([errorArray count]!=0)
    {
        [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Approve_TimeOff_Error, Approve_TimeOff_Error)]];    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_NOTIFICATION object:nil];
    
    int timeoffsNeedingApprovalCount=[response[@"response"][@"d"][@"timeOffsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timeoffsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
    
}
/************************************************************************************************************
 @Function Name   : handleRejectOfApprovalTimeOff
 @Purpose         : To handle response of bulk reject TimeOff by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleRejectOfApprovalTimeOff:(id)response
{
    NSMutableDictionary *responseData=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *responseDict=[responseData objectForKey:@"approvalBatchResults"];
    NSMutableArray *successRejectUriArray=[responseDict objectForKey:@"completedUris"];
    if ([successRejectUriArray count]!=0)
    {
        NSString *timeoffUri=[successRejectUriArray objectAtIndex:0];
        [approvalsModel deleteApprovalPendingTimeOffFromDBWithTimeoffUri:timeoffUri];
    }
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];
    if ([errorArray count]!=0)
    {
         [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Reject_TimeOff_Error, Reject_TimeOff_Error)]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_NOTIFICATION object:nil];

    int timeoffsNeedingApprovalCount=[response[@"response"][@"d"][@"timeOffsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:timeoffsNeedingApprovalCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
}

/************************************************************************************************************
 @Function Name   : handleApproveOfApprovalExpense
 @Purpose         : To handle response of  approve Expense by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleApproveOfApprovalExpense:(id)response
{
    NSMutableDictionary *responseData=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *responseDict=[responseData objectForKey:@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];
    NSMutableArray *successApproveUriArray=[responseDict objectForKey:@"completedUris"];
    
    if ([successApproveUriArray count]!=0)
    {
        NSString *expenseSheetUri=[successApproveUriArray objectAtIndex:0];
        [approvalsModel deleteApprovalPendingExpenseFromDBWithTimeoffUri:expenseSheetUri];
    }
    
    if ([errorArray count]!=0)
    {
         [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Approve_Expense_Error, Approve_Expense_Error)]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_NOTIFICATION object:nil];

    int expensesNeedingApprovalCount=[response[@"response"][@"d"][@"expenseSheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:expensesNeedingApprovalCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

}

/************************************************************************************************************
 @Function Name   : handleRejectOfApprovalExpense
 @Purpose         : To handle response of  reject Expense by approver
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handleRejectOfApprovalExpense:(id)response
{
    NSMutableDictionary *responseData=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSMutableDictionary *responseDict=[responseData objectForKey:@"approvalBatchResults"];
    NSMutableArray *errorArray=[responseDict objectForKey:@"errors"];
    NSMutableArray *successRejectUriArray=[responseDict objectForKey:@"completedUris"];
    
    if ([successRejectUriArray count]!=0)
    {
        NSString *expenseSheetUri=[successRejectUriArray objectAtIndex:0];
        [approvalsModel deleteApprovalPendingExpenseFromDBWithTimeoffUri:expenseSheetUri];
    }

    if ([errorArray count]!=0)
    {
        [Util errorAlert:@"" errorMessage:[NSString stringWithFormat: @"%lu %@", (unsigned long)[errorArray count],RPLocalizedString(Reject_Expense_Error, Reject_Expense_Error)]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVAL_REJECT_NOTIFICATION object:nil];

    int expensesNeedingApprovalCount=[response[@"response"][@"d"][@"expenseSheetsForApprovalCount"] intValue];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:expensesNeedingApprovalCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
    [defaults synchronize];


    [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
    
}
//Implementation For Mobi-92//JUHI
-(void)handlePendingTimesheetFormat:(id)response{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil && ![responseDict isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *timesheetFormatDict=[NSMutableDictionary dictionary];
        NSString *timesheetUri=[[responseDict objectForKey:@"timesheet"] objectForKey:@"uri"];
        NSString *timesheetFormat=nil;
        if ([responseDict objectForKey:@"timesheetFormat"]!=nil && ![[responseDict objectForKey:@"timesheetFormat"]isKindOfClass:[NSNull class]])
        {
            timesheetFormat=[responseDict objectForKey:@"timesheetFormat"];
        }
        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]]) {
            [timesheetFormatDict setObject:timesheetFormat forKey:@"timesheetFormat"];
        }
        if ([timesheetFormat isEqualToString:Gen4TimeSheetFormat])
        {
             NSMutableDictionary *updateDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:GEN4_INOUT_TIMESHEET,@"timesheetFormat", nil];
           [approvalsModel updateTimesheetFormatForPendingApprovalsTimesheetWithUri:timesheetUri withFormat:updateDict];
        }
        
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName: APPROVAL_TIMESHEETFORMAT_RECEIVED_NOTIFICATION object:nil userInfo:timesheetFormatDict];
    }
}

-(void)handlePreviousTimesheetFormat:(id)response{
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil && ![responseDict isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *timesheetFormatDict=[NSMutableDictionary dictionary];
        NSString *timesheetUri=[[responseDict objectForKey:@"timesheet"] objectForKey:@"uri"];
        NSString *timesheetFormat=nil;
        if ([responseDict objectForKey:@"timesheetFormat"]!=nil && ![[responseDict objectForKey:@"timesheetFormat"]isKindOfClass:[NSNull class]])
        {
            timesheetFormat=[responseDict objectForKey:@"timesheetFormat"];
        }
        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]]) {
            [timesheetFormatDict setObject:timesheetFormat forKey:@"timesheetFormat"];
        }
        [approvalsModel updateTimesheetFormatForPreviousApprovalsTimesheetWithUri:timesheetUri withFormat:timesheetFormatDict];
        [[NSNotificationCenter defaultCenter] postNotificationName: APPROVAL_TIMESHEETFORMAT_RECEIVED_NOTIFICATION object:nil userInfo:timesheetFormatDict];
    }
}
/************************************************************************************************************
 @Function Name   : handlePendingTimesheetsSummaryFetchDataForGen4
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handlePendingTimesheetsSummaryFetchDataForGen4:(id)response
{
//    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
//    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
//    if ([responseArray count]>0 && responseArray!=nil)
//    {
//        [approvalsModel savePendingTimesheetSummaryDataFromApiToDBForGen4:responseArray withTimesheetUri:timesheetUri];
//        
//        
//    }
//    [approvalsModel savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:responseArray];
//    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
}
/************************************************************************************************************
 @Function Name   : handlePreviousTimesheetsSummaryFetchDataForGen4
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handlePreviousTimesheetsSummaryFetchDataForGen4:(id)response
{
//    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
//    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
//    if ([responseArray count]>0 && responseArray!=nil)
//    {
//        [approvalsModel savePreviousTimesheetSummaryDataFromApiToDBForGen4:responseArray withTimesheetUri:timesheetUri];
//        
//        
//    }
//    [approvalsModel savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:responseArray];
//    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
}
/************************************************************************************************************
 @Function Name   : handlePreviousTimesheetsTimeoffSummaryFetchDataForGen4
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handlePreviousTimesheetsTimeoffSummaryFetchDataForGen4:(id)response
{
//    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
//    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
//    if ([responseArray count]>0 && responseArray!=nil)
//    {
//        [approvalsModel savePreviousTimesheetTimeOffSummaryDataFromApiToDBForGen4:responseArray withTimesheetUri:timesheetUri];
//        
//        
//    }
//    [approvalsModel savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:responseArray];
//    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
/************************************************************************************************************
 @Function Name   : handlePreviousTimesheetsTimeoffSummaryFetchDataForGen4
 @Purpose         : To save timesheet summary data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/

-(void)handlePendingTimesheetsTimeoffSummaryFetchDataForGen4:(id)response
{
//    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
//    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
//    if ([responseArray count]>0 && responseArray!=nil)
//    {
//        [approvalsModel savePendingTimesheetTimeOffSummaryDataFromApiToDBForGen4:responseArray withTimesheetUri:timesheetUri];
//        
//        
//    }
//    [approvalsModel savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:responseArray];
//    [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
}
/************************************************************************************************************
 @Function Name   : handlePendingTimesheetApprovalCapabilitiesDataForGen4
 @Purpose         : To save timesheet approval capabilities data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handlePendingTimesheetApprovalCapabilitiesDataForGen4:(id)response
{
    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseArray count]>0 && responseArray!=nil)
    {
        [approvalsModel saveApprovalsCapablitiesDataIntoDBWithData:responseArray isPending:YES forTimesheetUri:timesheetUri];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:TIMESHEET_APPROVAL_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION object:nil];
}
/************************************************************************************************************
 @Function Name   : handlePreviousTimesheetsSummaryFetchDataForGen4
 @Purpose         : To save timesheet approval capabilities data into the DB
 @param           : response
 @return          : nil
 *************************************************************************************************************/
-(void)handlePreviousTimesheetApprovalCapabilitiesDataForGen4:(id)response
{
    NSString *timesheetUri=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseArray count]>0 && responseArray!=nil)
    {
        [approvalsModel saveApprovalsCapablitiesDataIntoDBWithData:responseArray isPending:NO forTimesheetUri:timesheetUri];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:TIMESHEET_APPROVAL_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION object:nil];
}

-(void)handleGen4TimesheetApprovalsDetailsData:(id)response isFromPending:(BOOL)isPending
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    NSMutableArray *dataArray=[[[response objectForKey:@"response"] objectForKey:@"d"] objectForKey:@"history"];
    NSString *moduleName=nil;
    if (isPending) {
        moduleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
    }
    else
    {
        moduleName=APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
    }
    [approvalsModel saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:dataArray moduleName:moduleName];
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil];
}


-(void)handleTimeSegmentsForTimesheetData:(id)response isFromPending:(BOOL)isFromPending
{
    NSString *moduleName=nil;
    if (isFromPending)
    {
        moduleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
    }
    else
    {
        moduleName=APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
    }
    NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if ([responseDict count]>0 && responseDict!=nil)
    {
        NSMutableDictionary *paramsDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];

        NSString *timesheetUri=nil;
        if ([paramsDict objectForKey:@"timesheetUri"]!=nil && ![[paramsDict objectForKey:@"timesheetUri"] isKindOfClass:[NSNull class]])
        {
            timesheetUri=[paramsDict objectForKey:@"timesheetUri"];
        }
        
        PunchHistoryModel *punchModel=[[PunchHistoryModel alloc]init];
        [punchModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:YES approvalsModule:moduleName andtimesheetUri:timesheetUri];
        [punchModel savepunchHistoryDataFromApiToDB:[responseDict objectForKey:@"timeSegments"] isFromWidget:YES approvalsModule:moduleName andTimeSheetUri:timesheetUri];
        if (paramsDict!=nil && ![paramsDict isKindOfClass:[NSNull class]])
        {
            NSString *timesheetUri=[paramsDict objectForKey:@"timesheetUri"];
            [punchModel updateTimesheetHoursInTimesheetTableWithTimesheetUri:timesheetUri approvalsModule:moduleName];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
    
}

-(void)handleTimeSegmentsForTimesheetDataForGen4:(NSDictionary *)timePunchTimeSegmentDetailsDict isFromPending:(BOOL)isFromPending forTimeSheetUri:(NSString *)timesheetUri
{
    NSString *moduleName=nil;
    if (isFromPending)
    {
        moduleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
    }
    else
    {
        moduleName=APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
    }
    if (timePunchTimeSegmentDetailsDict!=nil && ![timePunchTimeSegmentDetailsDict isKindOfClass:[NSNull class]])
    {
        PunchHistoryModel *punchModel=[[PunchHistoryModel alloc]init];
        [punchModel deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:YES approvalsModule:moduleName andtimesheetUri:timesheetUri];
        [punchModel savepunchHistoryDataFromApiToDB:[timePunchTimeSegmentDetailsDict objectForKey:@"timeSegments"] isFromWidget:YES approvalsModule:moduleName andTimeSheetUri:timesheetUri];
        
        BOOL isOnlyPunchWidget=YES;
        NSMutableArray *enableWidgetsArr=nil;
        
        if (isFromPending)
        {
            enableWidgetsArr=[approvalsModel getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
        }
        else
        {
            enableWidgetsArr=[approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
        }
        for(NSDictionary *widgetUriDict in enableWidgetsArr)
        {
            if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
            {
                isOnlyPunchWidget=FALSE;
            }
            else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
            {
                isOnlyPunchWidget=FALSE;
                
            }
        }
        if (isOnlyPunchWidget)
        {
            if (isFromPending)
            {
                [approvalsModel savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:[NSMutableArray array]  isFromTimeoff:NO];
            }
            else
            {
                 [approvalsModel savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:[NSMutableArray array]   isFromTimeoff:NO];
            }
            
        }
        
       // [punchModel updateTimesheetHoursInTimesheetTableWithTimesheetUri:timesheetUri approvalsModule:moduleName];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
    
}

-(void)handleTimesheetsSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr andModuleName:(NSString *)moduleName andDayOffList:(NSArray *)dayOffList
{
    
    
    
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetUri andWidgetEntries:widgetTimeEntriesArr isPending:TRUE];
        [approvalsModel savePendingTimesheetSummaryDataFromApiToDBForGen4:widgetTimeEntriesArr withTimesheetUri:timesheetUri andTimeEntryProjectTaskAncestryDetails:timeEntryProjectTaskAncestryDetailsArr];
        [approvalsModel savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:widgetTimeEntriesArr dayOffList:dayOffList isFromTimeoff:NO];
    }
    else
    {
        [approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetUri andWidgetEntries:widgetTimeEntriesArr isPending:FALSE];
        [approvalsModel savePreviousTimesheetSummaryDataFromApiToDBForGen4:widgetTimeEntriesArr withTimesheetUri:timesheetUri andTimeEntryProjectTaskAncestryDetails:timeEntryProjectTaskAncestryDetailsArr];
        [approvalsModel savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:widgetTimeEntriesArr dayOffList:dayOffList isFromTimeoff:NO];
    }
   
}

-(void)handleTimesheetsTimeoffSummaryFetchDataForGen4:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andModuleName:(NSString *)moduleName  andDayOffList:(NSArray *)dayOffList
{
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [approvalsModel savePendingTimesheetTimeOffSummaryDataFromApiToDBForGen4:timeOffsArr withTimesheetUri:timesheetUri];
        [approvalsModel savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:timeOffsArr dayOffList:dayOffList isFromTimeoff:YES];
    }
    else
    {
        [approvalsModel savePreviousTimesheetTimeOffSummaryDataFromApiToDBForGen4:timeOffsArr withTimesheetUri:timesheetUri];
        [approvalsModel savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:timeOffsArr dayOffList:dayOffList isFromTimeoff:YES];
    }
    
   
}

-(void)handleDailyWidgetSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andModuleName:(NSString *)moduleName andDayOffList:(NSArray *)dayOffList
{
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetUri andWidgetEntries:widgetTimeEntriesArr isPending:TRUE];
        [approvalsModel saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:widgetTimeEntriesArr withTimesheetUri:timesheetUri isPending:TRUE];
        [approvalsModel savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:widgetTimeEntriesArr dayOffList:dayOffList isFromTimeoff:NO];
    }
    else
    {
        [approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetUri andWidgetEntries:widgetTimeEntriesArr isPending:FALSE];
         [approvalsModel saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:widgetTimeEntriesArr withTimesheetUri:timesheetUri isPending:FALSE];
        [approvalsModel savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:widgetTimeEntriesArr dayOffList:dayOffList isFromTimeoff:NO];
    }


}

@end
