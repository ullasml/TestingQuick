
//
//  ApprovalsModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 28/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ApprovalsModel.h"
#import "Util.h"
#import "SQLiteDB.h"
#import "LoginModel.h"
#import "SupportDataModel.h"
#import "TimesheetPeriod.h"
#import "TimeoffModel.h"
#import "DateUtil.h"

@implementation ApprovalsModel

static NSString *approvalPendingTimesheetsTable=@"PendingApprovalTimesheets";
static NSString *approvalPreviousTimesheetsTable=@"PreviousApprovalTimesheets";
static NSString *approvalPendingExpensesheetsTable=@"PendingApprovalExpensesheets";
static NSString *approvalPreviousExpensesheetsTable=@"PreviousApprovalExpensesheets";
static NSString *approvalPendingTimeOffsTable=@"PendingApprovalTimeOffs";
static NSString *approvalPreviousTimeOffsTable=@"PreviousApprovalTimeOffs";
static NSString *approvalPendingTimesheetsDaySummaryTable=@"PendingApprovalTimesheetDaySummary";
static NSString *approvalPendingTimesheetsProjectsSummaryTable=@"PendingApprovalTimesheetProjectSummary";
static NSString *approvalPendingTimesheetsActivitiesSummaryTable=@"PendingApprovalTimesheetActivitySummary";
static NSString *approvalPendingTimesheetsBillingSummaryTable=@"PendingApprovalTimesheetBillingSummary";
static NSString *approvalPendingTimesheetsPayrollSummaryTable=@"PendingApprovalTimesheetPayrollSummary";
static NSString *approvalPendingTimesheetCustomFieldsTable=@"PendingApprovalTimesheetCustomFields";
static NSString *approvalPendingTimeEntriesTable = @"PendingApprovalTimeEntries";
static NSString *approvalPendingTimesheetApproverHistoryTable=@"PendingApprovalTimesheetApproverHistory";
static NSString *approvalPendingDisclaimerTable=@"PendingApprovalDisclaimer";
static NSString *approvalPendingExpenseEntriesTable=@"PendingApprovalExpenseEntries";
static NSString *approvalPendingExpenseCustomFieldsTable=@"PendingApprovalExpenseCustomFields";
static NSString *approvalPendingExpenseIncurredAmountTaxTable=@"PendingApprovalExpenseIncurredAmountTax";
static NSString *approvalPendingExpenseApprovalHistoryTable=@"PendingApprovalExpenseSheetApprovalHistory";
static NSString *approvalPendingTimeoffEntriesTable=@"PendingApprovalTimeoffEntries";
static NSString *approvalPendingTimeoffCustomFieldsTable=@"PendingApprovalTimeoffCustomFields";
static NSString *approvalPendingTimesheetCapabilitiesTable=@"PendingApprovalsTimesheetCapabilities";
static NSString *approvalPendingExpenseCapabilitiesTable=@"PendingApprovalsExpenseCapabilities";
static NSString *approvalExpensePendingTaxCodesTable=@"ApprovalsPendingExpenseTaxCodes";
static NSString *approvalExpensePendingCodeDetailsTable=@"ApprovalsPendingExpenseCodeDetails";

static NSString *approvalPreviousTimesheetsDaySummaryTable=@"PreviousApprovalTimesheetDaySummary";
static NSString *approvalPreviousTimesheetCustomFieldsTable=@"PreviousApprovalTimesheetCustomFields";
static NSString *approvalPreviousTimesheetsProjectsSummaryTable=@"PreviousApprovalTimesheetProjectSummary";
static NSString *approvalPreviousTimesheetsActivitiesSummaryTable=@"PreviousApprovalTimesheetActivitySummary";
static NSString *approvalPreviousTimesheetsBillingSummaryTable=@"PreviousApprovalTimesheetBillingSummary";
static NSString *approvalPreviousTimesheetsPayrollSummaryTable=@"PreviousApprovalTimesheetPayrollSummary";
static NSString *approvalPreviousTimeEntriesTable = @"PreviousApprovalTimeEntries";
static NSString *approvalPreviousTimesheetApproverHistoryTable=@"PreviousApprovalTimesheetApproverHistory";
static NSString *approvalPreviousDisclaimerTable=@"PreviousApprovalDisclaimer";
static NSString *approvalPreviousTimesheetCapabilitiesTable=@"PreviousApprovalsTimesheetCapabilities";

static NSString *approvalPreviousExpenseEntriesTable=@"PreviousApprovalExpenseEntries";
static NSString *approvalPreviousExpenseCapabilitiesTable=@"PreviousApprovalsExpenseCapabilities";
static NSString *approvalPreviousExpenseCustomFieldsTable=@"PreviousApprovalExpenseCustomFields";
static NSString *approvalPreviousExpenseIncurredAmountTaxTable=@"PreviousApprovalExpenseIncurredAmountTax";
static NSString *approvalExpensePreviousTaxCodesTable=@"ApprovalsPreviousExpenseTaxCodes";
static NSString *approvalExpensePreviousCodeDetailsTable=@"ApprovalsPreviousExpenseCodeDetails";
static NSString *approvalPreviousExpenseApprovalHistoryTable=@"PreviousApprovalExpenseSheetApprovalHistory";

static NSString *approvalPreviousTimeoffEntriesTable=@"PreviousApprovalTimeoffEntries";
static NSString *approvalPreviousTimeoffCustomFieldsTable=@"PreviousApprovalTimeoffCustomFields";
static NSString *approveTimesheetReasonForChangeTable=@"ApproveTimesheetReasonForchange";

static NSString *approvalPreviousApprovalTimeOffApprovalHistoryTable=@"PreviousApprovalTimeOffApprovalHistory";
static NSString *approvalPendingApprovalTimeOffApprovalHistoryTable=@"PendingApprovalTimeOffApprovalHistory";
//US9453 to address DE17320 Ullas M L
static NSString *userDeFinedFieldsTable=@"userDefinedFields";
static NSString *udfPendingPreferencesTable=@"UDFPendingPreferences";
static NSString *udfPreviousPreferencesTable=@"UDFPreviousPreferences";
static NSString *udfPendingTimeoffPreferencesTable=@"udfPendingTimeoffPreferences";
static NSString *udfPreviousTimeoffPreferencesTable=@"udfPreviousTimeoffPreferences";
static NSString *pendingEnabledWidgetsTable=@"PendingEnabledWidgets";
static NSString *previousEnabledWidgetsTable=@"PreviousEnabledWidgets";
static NSString *pendingWidgetDisclaimerTable=@"WidgetPendingNotice";
static NSString *previousWidgetDisclaimerTable=@"WidgetPreviousNotice";
static NSString *WidgetPreviousTimesheetSummaryTable=@"WidgetPreviousTimesheetSummary";
static NSString *WidgetPendingTimesheetSummaryTable=@"WidgetPendingTimesheetSummary";
static NSString *pendingWidgetAttestationTable=@"WidgetPendingAttestation";
static NSString *previousWidgetAttestationTable=@"WidgetPreviousAttestation";

static NSString *widgetPendingPayrollSummaryTable=@"WidgetPendingPayrollSummary";
static NSString *widgetPreviousPayrollSummaryTable=@"WidgetPreviousPayrollSummary";

static NSString *timesheetObjectExtensionFieldsTable=@"TimesheetObjectExtensionFields";
static NSString *timeEntriesObjectExtensionFieldsTable=@"TimeEntriesObjectExtensionFields";

static NSString *multiDayTimeOffEntries = @"multiday_timeoff_entries";
static NSString *timeoffBookingScheduledDuration = @"multiday_timeoff_bookingOptionByScheduledDuration";

#define CLIENT_POLICY_SELECTION @"urn:replicon:policy:timesheet:project-selection-grouping"
#define PROJECT_POLICY_SELECTION @"urn:replicon:policy:timesheet:project-and-task-selection"
#define BILLING_POLICY_SELECTION @"urn:replicon:policy:timesheet:billing-rate-selection"
#define ACTIVITY_POLICY_SELECTION @"urn:replicon:policy:timesheet:activity-selection"
#define BREAK_POLICY_SELECTION @"urn:replicon:policy:timesheet:breaks-on-timesheet"
#define DISCLAIMER_POLICY_SELECTION @"urn:replicon:policy:timesheet:explicit-notice-acceptance"
#define DO_NOT_SELECT_CLIENT_URI @"urn:replicon:policy:timesheet:project-selection-grouping:none"
#define DO_NOT_SELECT_PROJECT_URI @"urn:replicon:policy:timesheet:project-and-task-selection:do-not-select-project-and-task"
#define DO_NOT_SELECT_BILLING_URI @"urn:replicon:policy:timesheet:billing-rate-selection:do-not-select-billing-rate"
#define DO_NOT_SELECT_ACTIVITY_URI @"urn:replicon:policy:timesheet:activity-selection:do-not-select-activity"
#define ALLOW_SELECT_BREAK_URI @"urn:replicon:policy:timesheet:breaks-on-timesheet:allow-break-entry-on-timesheet"

#pragma mark -
#pragma mark Save methods

-(void)savePendingApprovalTimeSheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    BOOL displaySummaryByPayCode = [self shouldDisplaySummaryByPayCode:responseDict];
    
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timesheetURI=@"";
        NSString *userURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Timesheet Period"])
            {
                NSDictionary *startDateDict=[[responseDict objectForKey:@"dateRangeValue"]objectForKey:@"startDate"];
                NSDictionary *endDateDict=[[responseDict objectForKey:@"dateRangeValue"]objectForKey:@"endDate"];
                
                NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [df setDateFormat:@"MMMM dd, yyyy"];
                NSString *timesheetStartDateStr=[df stringFromDate:startDate];
                NSString *timesheetEndDateStr=[df stringFromDate:endDate];
                NSString *timesheetPeriodStr=[NSString stringWithFormat:@"%@ - %@",timesheetStartDateStr,timesheetEndDateStr];
                //                NSString *timesheetPeriodStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
                [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]]   forKey:@"endDate"];
                [dataDict setObject:timesheetPeriodStr forKey:@"timesheetPeriod"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Regular Hours"])
            {
                NSDictionary *regularHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *regularHours=[Util convertApiTimeDictToDecimal:regularHoursDict];
                NSString *regularHoursStr=[Util convertApiTimeDictToString:regularHoursDict];
                [dataDict setObject:regularHours      forKey:@"regularDurationDecimal"];
                [dataDict setObject:regularHoursStr   forKey:@"regularDurationHour"];
            }
            else if ([refrenceHeader isEqualToString:@"Overtime Hours"])
            {
                NSDictionary *overTimeHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *overTimeHours=[Util convertApiTimeDictToDecimal:overTimeHoursDict];
                NSString *overTimeHoursStr=[Util convertApiTimeDictToString:overTimeHoursDict];
                [dataDict setObject:overTimeHours      forKey:@"overtimeDurationDecimal"];
                [dataDict setObject:overTimeHoursStr   forKey:@"overtimeDurationHour"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Hours"])
            {
                NSDictionary *timeOffHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *timeOffHours=[Util convertApiTimeDictToDecimal:timeOffHoursDict];
                NSString *timeOffHoursStr=[Util convertApiTimeDictToString:timeOffHoursDict];
                [dataDict setObject:timeOffHours      forKey:@"timeoffDurationDecimal"];
                [dataDict setObject:timeOffHoursStr   forKey:@"timeoffDurationHour"];
            }
            else if ([refrenceHeader isEqualToString:@"Total Hours"])
            {
                //MI-1916
                NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                 NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                 NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                 [dataDict setObject:totalHours      forKey:@"totalDurationDecimal"];
                 [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Project Total Time Duration"])
            {
                if (![[responseDict objectForKey:@"dataType"] isEqualToString:@"urn:replicon:list-type:null"]) {
                    NSDictionary *projectHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                    NSNumber *projectHours=[Util convertApiTimeDictToDecimal:projectHoursDict];
                    NSString *projectHoursStr=[Util convertApiTimeDictToString:projectHoursDict];
                    [dataDict setObject:projectHours      forKey:@"projectDurationDecimal"];
                    [dataDict setObject:projectHoursStr   forKey:@"projectDurationHour"];
                }
            }
            else if ([refrenceHeader isEqualToString:@"Approval Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"approval_dueDate"];
                if (dueDateStr!=nil && ![dueDateStr isKindOfClass:[NSNull class]]) {
                    [dataDict setObject:dueDateStr       forKey:@"approval_dueDateText"];
                }
                
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Timesheet"])
            {
                timesheetURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timesheetURI      forKey:@"timesheetUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"User"])
            {
                userURI=[responseDict objectForKey:@"uri"];
                NSString *username=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:userURI       forKey:@"userUri"];
                [dataDict setObject:username      forKey:@"username"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Meal Penalties"])
            {
                int penalties=[[responseDict objectForKey:@"textValue"] intValue];
                [dataDict setObject:[NSNumber numberWithInt:penalties] forKey:@"mealBreakPenalties"];
            }
            else if ([refrenceHeader isEqualToString:@"Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"dueDate"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Total Hours Excluding Break"])
            {
                //MI-1916
                /*NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHours      forKey:@"totalDurationDecimal"];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];*/
                
            }
            
        }
        
        [dataDict setObject:[NSNumber numberWithBool:displaySummaryByPayCode] forKey:@"displaySummaryByPayCode"];
        NSArray *timeSheetsArr = [self getPendingApprovalDataForTimesheetSheetURI:timesheetURI andUserUri:userURI];
        if ([timeSheetsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' and userUri='%@' ",timesheetURI,userURI];
            [myDB updateTable:approvalPendingTimesheetsTable data:dataDict where:whereString intoDatabase:@""];
            
        }
        else
        {
            
            [myDB insertIntoTable:approvalPendingTimesheetsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}

-(void)savePendingApprovalExpenseSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *expenseSheetURI=@"";
        NSString *userURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }

            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Approval Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"approval_dueDate"];
                if (dueDateStr!=nil && ![dueDateStr isKindOfClass:[NSNull class]]) {
                    [dataDict setObject:dueDateStr       forKey:@"approval_dueDateText"];
                }
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }

            }
            else if ([refrenceHeader isEqualToString:@"Date"])
            {
                NSDictionary *dateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *date=[Util convertApiDateDictToDateFormat:dateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[date timeIntervalSince1970]] forKey:@"expenseDate"];

            }
            else if ([refrenceHeader isEqualToString:@"Description"])
            {
                NSString *descStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:descStr forKey:@"description"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Expense"])
            {
                NSString *expenseSheetURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:expenseSheetURI forKey:@"expenseSheetUri"];
            }
            else if ([refrenceHeader isEqualToString:@"Employee"])
            {
                userURI=[responseDict objectForKey:@"uri"];
                NSString *username=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:userURI       forKey:@"userUri"];
                [dataDict setObject:username      forKey:@"username"];
  
            }

            else if ([refrenceHeader isEqualToString:@"Reimbursement Amount"])
            {
                NSString *reimbursementAmt=[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"amount"];
                
                NSString *currencyName=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *currencyUri=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"uri"];
                if (reimbursementAmt!=nil && ![reimbursementAmt isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:reimbursementAmt forKey:@"reimbursementAmount"];
                }
                if (currencyName!=nil && ![currencyName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyName forKey:@"reimbursementAmountCurrencyName"];
                }
                if (currencyUri!=nil && ![currencyUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyUri forKey:@"reimbursementAmountCurrencyUri"];
                }

                
            }
            else if([refrenceHeader isEqualToString:@"Incurred Amount"]){
                NSString *reimbursementAmt=[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"amount"];
                
                NSString *currencyName=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *currencyUri=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"uri"];
                if (reimbursementAmt!=nil && ![reimbursementAmt isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:reimbursementAmt forKey:@"incurredAmount"];
                }
                if (currencyName!=nil && ![currencyName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyName forKey:@"incurredAmountCurrencyName"];
                }
                if (currencyUri!=nil && ![currencyUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyUri forKey:@"incurredAmountCurrencyUri"];
                }
                
            }
            
            else if ([refrenceHeader isEqualToString:@"Tracking Number"])
            {
                NSString*trackingNumber=[responseDict objectForKey:@"textValue"];
                if (trackingNumber!=nil && ![trackingNumber isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:trackingNumber      forKey:@"trackingNumber"];
                }
                
                
            }


            
            
        }
        
        NSArray *expenseSheetsArr = [self getPendingApprovalDataForExpenseSheetURI:expenseSheetURI andUserUri:userURI];
        if ([expenseSheetsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@' and userUri='%@' ",expenseSheetURI,userURI];
            [myDB updateTable:approvalPendingExpensesheetsTable data:dataDict where:whereString intoDatabase:@""];
            
        }
        else
        {
            
            [myDB insertIntoTable:approvalPendingExpensesheetsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
}

-(void)savePendingApprovalTimeOffsSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timeoffURI=@"";
        NSString *userURI=@"";
        NSString *timeOffTypeFormatUri=@"";

        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
           
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Approval Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"approval_dueDate"];
                if (dueDateStr!=nil && ![dueDateStr isKindOfClass:[NSNull class]]) {
                    [dataDict setObject:dueDateStr       forKey:@"approval_dueDateText"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Owner"])
            {
                userURI=[responseDict objectForKey:@"uri"];
                NSString *username=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:userURI       forKey:@"userUri"];
                [dataDict setObject:username      forKey:@"username"];
                
            }
            else if ([refrenceHeader isEqualToString:@"End Date"])
            {
                NSDictionary *endDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Start Date"])
            {
                NSDictionary *startDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
            }
            //Implemented for Last Action Time for bookedTimeoff
            else if ([refrenceHeader isEqualToString:@"Last Action Time (in UTC)"])
            {
                NSMutableDictionary *timeStamp=[NSMutableDictionary dictionary];
                if ([responseDict objectForKey:@"dateValue"]!=nil && ![[responseDict objectForKey:@"dateValue"]isKindOfClass:[NSNull class]]) {
                    [timeStamp setObject:[[responseDict objectForKey:@"dateValue"] objectForKey:@"day"] forKey:@"day"];
                    [timeStamp setObject:[[responseDict objectForKey:@"dateValue"] objectForKey:@"month"] forKey:@"month"];
                    [timeStamp setObject:[[responseDict objectForKey:@"dateValue"] objectForKey:@"year"] forKey:@"year"];
                    [timeStamp setObject:[[responseDict objectForKey:@"timeValue"] objectForKey:@"hour"] forKey:@"hour"];
                    [timeStamp setObject:[[responseDict objectForKey:@"timeValue"] objectForKey:@"minute"] forKey:@"minute"];
                    [timeStamp setObject:[[responseDict objectForKey:@"timeValue"] objectForKey:@"second"] forKey:@"second"];
                    NSDate *modifyDate=[Util convertApiDateDictToDateTimeFormat:timeStamp];
                    [dataDict setObject:[NSNumber numberWithDouble:[modifyDate timeIntervalSince1970]] forKey:@"dueDate"];
                }
               
            }
            else if ([refrenceHeader isEqualToString:@"Total Duration"])
            {
                NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
            }
            else if ([refrenceHeader isEqualToString:@"Time Off"])
            {
                timeoffURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeoffURI forKey:@"timeoffUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type"])
            {
                NSString *timeoffTypeURI=[responseDict objectForKey:@"uri"];
                NSString *timeoffTypeName=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
                [dataDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type Display Format"])
            {
                timeOffTypeFormatUri=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeOffTypeFormatUri forKey:@"timeOffDisplayFormatUri"];
            }

            else if ([refrenceHeader isEqualToString:@"Total Effective Hours"])
            {

                NSString *totalHoursTextValue = [responseDict objectForKey:@"numberValue"];
                [dataDict setObject:totalHoursTextValue   forKey:@"totalDurationDecimal"];
            }

            else if ([refrenceHeader isEqualToString:@"Total Effective Workdays"])
            {

                NSString *totalWorkingDaysTextValue = [responseDict objectForKey:@"textValue"];
                [dataDict setObject:totalWorkingDaysTextValue      forKey:@"totalTimeoffDays"];
            }
        }
        
        TimeoffModel *timeOffModel = [[TimeoffModel alloc]init];
        NSString *timeOffDisplayFormatUri = @"";
        NSArray *timeOffDisplayFormatUriArray = [timeOffModel getTimeoffTypeInfoSheetIdentity:dataDict[@"timeoffTypeUri"]];
        if (timeOffDisplayFormatUriArray!= nil && ![timeOffDisplayFormatUriArray isKindOfClass:[NSNull class]] ) {
            timeOffDisplayFormatUri = timeOffDisplayFormatUriArray[0][@"timeOffDisplayFormatUri"];
            if (timeOffDisplayFormatUri!= nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]]) {
                [dataDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
            }
        }
        else if (timeOffTypeFormatUri != nil && ![timeOffTypeFormatUri isKindOfClass:[NSNull class]] && ![timeOffTypeFormatUri isEqualToString:@""])
        {
            [dataDict setObject:timeOffTypeFormatUri   forKey:@"timeOffDisplayFormatUri"];
        }
        
        NSArray *timeOffsArr = [self getPendingApprovalDataForTimeOffsURI:timeoffURI andUserUri:userURI];
        if ([timeOffsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@' and userUri='%@' ",timeoffURI,userURI];
            [myDB updateTable:approvalPendingTimeOffsTable data:dataDict where:whereString intoDatabase:@""];
            
        }
        else
        {
            
            [myDB insertIntoTable:approvalPendingTimeOffsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
}

-(void)savePreviousApprovalTimeSheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    BOOL displaySummaryByPayCode = [self shouldDisplaySummaryByPayCode:responseDict];
    
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timesheetURI=@"";
        NSString *userURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Timesheet Period"])
            {
                
                NSDictionary *startDateDict=[[responseDict objectForKey:@"dateRangeValue"]objectForKey:@"startDate"];
                NSDictionary *endDateDict=[[responseDict objectForKey:@"dateRangeValue"]objectForKey:@"endDate"];
                
                NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [df setDateFormat:@"MMMM dd, yyyy"];
                NSString *timesheetStartDateStr=[df stringFromDate:startDate];
                NSString *timesheetEndDateStr=[df stringFromDate:endDate];
                NSString *timesheetPeriodStr=[NSString stringWithFormat:@"%@ - %@",timesheetStartDateStr,timesheetEndDateStr];
                
                //NSString *timesheetPeriodStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:timesheetPeriodStr forKey:@"timesheetPeriod"];
                [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
                
                [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Regular Hours"])
            {
                NSDictionary *regularHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *regularHours=[Util convertApiTimeDictToDecimal:regularHoursDict];
                NSString *regularHoursStr=[Util convertApiTimeDictToString:regularHoursDict];
                [dataDict setObject:regularHours      forKey:@"regularDurationDecimal"];
                [dataDict setObject:regularHoursStr   forKey:@"regularDurationHour"];
            }
            else if ([refrenceHeader isEqualToString:@"Overtime Hours"])
            {
                NSDictionary *overTimeHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *overTimeHours=[Util convertApiTimeDictToDecimal:overTimeHoursDict];
                NSString *overTimeHoursStr=[Util convertApiTimeDictToString:overTimeHoursDict];
                [dataDict setObject:overTimeHours      forKey:@"overtimeDurationDecimal"];
                [dataDict setObject:overTimeHoursStr   forKey:@"overtimeDurationHour"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Hours"])
            {
                NSDictionary *timeOffHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *timeOffHours=[Util convertApiTimeDictToDecimal:timeOffHoursDict];
                NSString *timeOffHoursStr=[Util convertApiTimeDictToString:timeOffHoursDict];
                [dataDict setObject:timeOffHours      forKey:@"timeoffDurationDecimal"];
                [dataDict setObject:timeOffHoursStr   forKey:@"timeoffDurationHour"];
            }
            else if ([refrenceHeader isEqualToString:@"Total Hours"])
            {
                //MI-1916
                NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHours      forKey:@"totalDurationDecimal"];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Project Total Time Duration"])
            {
                if (![[responseDict objectForKey:@"dataType"] isEqualToString:@"urn:replicon:list-type:null"]) {
                    NSDictionary *projectHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                    NSNumber *projectHours=[Util convertApiTimeDictToDecimal:projectHoursDict];
                    NSString *projectHoursStr=[Util convertApiTimeDictToString:projectHoursDict];
                    [dataDict setObject:projectHours      forKey:@"projectDurationDecimal"];
                    [dataDict setObject:projectHoursStr   forKey:@"projectDurationHour"];
                }
            }

            else if ([refrenceHeader isEqualToString:@"Approval Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"approval_dueDate"];
                if (dueDateStr!=nil && ![dueDateStr isKindOfClass:[NSNull class]]) {
                    [dataDict setObject:dueDateStr       forKey:@"approval_dueDateText"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Timesheet"])
            {
                timesheetURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timesheetURI      forKey:@"timesheetUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"User"])
            {
                userURI=[responseDict objectForKey:@"uri"];
                NSString *username=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:userURI       forKey:@"userUri"];
                [dataDict setObject:username      forKey:@"username"];
                
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Meal Penalties"])
            {
                int penalties=[[responseDict objectForKey:@"textValue"] intValue];
                [dataDict setObject:[NSNumber numberWithInt:penalties] forKey:@"mealBreakPenalties"];
            }
            else if ([refrenceHeader isEqualToString:@"Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"dueDate"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Total Hours Excluding Break"])
            {
                //MI-1916
                /*NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHours      forKey:@"totalDurationDecimal"];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];*/
                
            }
            
        }
        [dataDict setObject:[NSNumber numberWithBool:displaySummaryByPayCode] forKey:@"displaySummaryByPayCode"];
        NSArray *timeSheetsArr = [self getPreviousApprovalDataForTimesheetSheetURI:timesheetURI andUserUri:userURI];
        if ([timeSheetsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' and userUri='%@' ",timesheetURI,userURI];
            [myDB updateTable:approvalPreviousTimesheetsTable data:dataDict where:whereString intoDatabase:@""];
            
        }
        else
        {
            
            [myDB insertIntoTable:approvalPreviousTimesheetsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}

-(void)savePreviousApprovalExpenseSheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *expenseSheetURI=@"";
        NSString *userURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Approval Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"approval_dueDate"];
                if (dueDateStr!=nil && ![dueDateStr isKindOfClass:[NSNull class]]) {
                    [dataDict setObject:dueDateStr       forKey:@"approval_dueDateText"];
                }
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }

            }
            else if ([refrenceHeader isEqualToString:@"Date"])
            {
                NSDictionary *dateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *date=[Util convertApiDateDictToDateFormat:dateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[date timeIntervalSince1970]] forKey:@"expenseDate"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Description"])
            {
                NSString *descStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:descStr forKey:@"description"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Expense"])
            {
                expenseSheetURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:expenseSheetURI forKey:@"expenseSheetUri"];
            }
            else if ([refrenceHeader isEqualToString:@"Employee"])
            {
                userURI=[responseDict objectForKey:@"uri"];
                NSString *username=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:userURI       forKey:@"userUri"];
                [dataDict setObject:username      forKey:@"username"];
                
            }
            
            else if ([refrenceHeader isEqualToString:@"Reimbursement Amount"])
            {
                NSString *reimbursementAmt=[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"amount"];
                
                NSString *currencyName=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *currencyUri=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"uri"];
                if (reimbursementAmt!=nil && ![reimbursementAmt isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:reimbursementAmt forKey:@"reimbursementAmount"];
                }
                if (currencyName!=nil && ![currencyName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyName forKey:@"reimbursementAmountCurrencyName"];
                }
                if (currencyUri!=nil && ![currencyUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyUri forKey:@"reimbursementAmountCurrencyUri"];
                }
                
                
            }
            
            else if ([refrenceHeader isEqualToString:@"Tracking Number"])
            {
                NSString*trackingNumber=[responseDict objectForKey:@"textValue"];
                if (trackingNumber!=nil && ![trackingNumber isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:trackingNumber      forKey:@"trackingNumber"];
                }
                
                
            }

        }
        
        NSArray *expenseSheetsArr = [self getPreviousApprovalDataForExpensesheetSheetURI:expenseSheetURI andUserUri:userURI];
        if ([expenseSheetsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@' and userUri='%@' ",expenseSheetURI,userURI];
            [myDB updateTable:approvalPreviousExpensesheetsTable data:dataDict where:whereString intoDatabase:@""];
            
        }
        else
        {
            
            [myDB insertIntoTable:approvalPreviousExpensesheetsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}


-(void)savePreviousApprovalTimeOffsSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *timeoffURI=@"";
        NSString *userURI=@"";
        NSString *timeOffTypeFormatUri=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getTimeOffColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Approval Due Date"])
            {
                NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"approval_dueDate"];
                if (dueDateStr!=nil && ![dueDateStr isKindOfClass:[NSNull class]]) {
                    [dataDict setObject:dueDateStr       forKey:@"approval_dueDateText"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                
                if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                {
                    [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                {
                    [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                {
                    [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                }
                else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                {
                    [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                }
                else
                {
                    [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Owner"])
            {
                userURI=[responseDict objectForKey:@"uri"];
                NSString *username=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:userURI       forKey:@"userUri"];
                [dataDict setObject:username      forKey:@"username"];
                
            }
            else if ([refrenceHeader isEqualToString:@"End Date"])
            {
                NSDictionary *endDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Start Date"])
            {
                NSDictionary *startDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
            }
            else if ([refrenceHeader isEqualToString:@"Total Duration"])
            {
                NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
            }
            else if ([refrenceHeader isEqualToString:@"Time Off"])
            {
                timeoffURI=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeoffURI forKey:@"timeoffUri"];
                
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type"])
            {
                NSString *timeoffTypeURI=[responseDict objectForKey:@"uri"];
                NSString *timeoffTypeName=[responseDict objectForKey:@"textValue"];
                [dataDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
                [dataDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
                
            }
            //Implemented for Last Action Time for bookedTimeoff
            else if ([refrenceHeader isEqualToString:@"Last Action Time (in UTC)"])
            {
                if ([responseDict objectForKey:@"dateValue"]!=nil && ![[responseDict objectForKey:@"dateValue"]isKindOfClass:[NSNull class]]) {
                NSMutableDictionary *timeStamp=[NSMutableDictionary dictionary];
                [timeStamp setObject:[[responseDict objectForKey:@"dateValue"] objectForKey:@"day"] forKey:@"day"];
                [timeStamp setObject:[[responseDict objectForKey:@"dateValue"] objectForKey:@"month"] forKey:@"month"];
                [timeStamp setObject:[[responseDict objectForKey:@"dateValue"] objectForKey:@"year"] forKey:@"year"];
                [timeStamp setObject:[[responseDict objectForKey:@"timeValue"] objectForKey:@"hour"] forKey:@"hour"];
                [timeStamp setObject:[[responseDict objectForKey:@"timeValue"] objectForKey:@"minute"] forKey:@"minute"];
                [timeStamp setObject:[[responseDict objectForKey:@"timeValue"] objectForKey:@"second"] forKey:@"second"];
                NSDate *modifyDate=[Util convertApiDateDictToDateTimeFormat:timeStamp];
                [dataDict setObject:[NSNumber numberWithDouble:[modifyDate timeIntervalSince1970]] forKey:@"dueDate"];
                }
            }
            else if ([refrenceHeader isEqualToString:@"Time Off Type Display Format"])
            {
                timeOffTypeFormatUri=[responseDict objectForKey:@"uri"];
                [dataDict setObject:timeOffTypeFormatUri forKey:@"timeOffDisplayFormatUri"];
            }

            else if ([refrenceHeader isEqualToString:@"Total Effective Hours"])
            {

                NSString *totalHoursTextValue = [responseDict objectForKey:@"numberValue"];
                [dataDict setObject:totalHoursTextValue   forKey:@"totalDurationDecimal"];
            }

            else if ([refrenceHeader isEqualToString:@"Total Effective Workdays"])
            {

                NSString *totalWorkingDaysTextValue = [responseDict objectForKey:@"textValue"];
                [dataDict setObject:totalWorkingDaysTextValue      forKey:@"totalTimeoffDays"];
            }
        }
        
        TimeoffModel *timeOffModel = [[TimeoffModel alloc]init];
        NSString *timeOffDisplayFormatUri = @"";
        NSArray *timeOffDisplayFormatUriArray = [timeOffModel getTimeoffTypeInfoSheetIdentity:dataDict[@"timeoffTypeUri"]];
        if (timeOffDisplayFormatUriArray!= nil && ![timeOffDisplayFormatUriArray isKindOfClass:[NSNull class]] ) {
            timeOffDisplayFormatUri = timeOffDisplayFormatUriArray[0][@"timeOffDisplayFormatUri"];
            if (timeOffDisplayFormatUri!= nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]]) {
                [dataDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
            }
        }
        else if (timeOffTypeFormatUri != nil && ![timeOffTypeFormatUri isKindOfClass:[NSNull class]] && ![timeOffTypeFormatUri isEqualToString:@""])
        {
            [dataDict setObject:timeOffTypeFormatUri   forKey:@"timeOffDisplayFormatUri"];
        }

        
        NSArray *timeOffsArr = [self getPreviousApprovalDataForTimeOffURI:timeoffURI andUserUri:userURI];
        if ([timeOffsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@' and userUri='%@' ",timeoffURI,userURI];
            [myDB updateTable:approvalPreviousTimeOffsTable data:dataDict where:whereString intoDatabase:@""];
            
        }
        else
        {
            
            [myDB insertIntoTable:approvalPreviousTimeOffsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}

-(void)savePendingApprovalTimeSheetSummaryDetailsDataFromApiToDB:(NSMutableDictionary *)responseDictionaryObject
{
    NSMutableDictionary *widgetTimesheetSummaryDict=[responseDictionaryObject objectForKey:@"widgetTimesheetSummary"];
    NSString *timesheetUri = nil;
    if([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"]isKindOfClass:[NSNull class]])
    {
        timesheetUri=[[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"timesheet"] objectForKey:@"uri"];
    }
    
    [self deleteObjectExtensionFieldsFromDBForTimesheetUri:timesheetUri];

    if (widgetTimesheetSummaryDict!=nil && ![widgetTimesheetSummaryDict isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *capablitiesDict=[responseDictionaryObject objectForKey:@"capabilities"];
        NSMutableArray *widgetTimesheetCapabilitiesResponse=[capablitiesDict objectForKey:@"widgetTimesheetCapabilities"];
        [self saveEnabledWidgetsDetailsIntoDB:responseDictionaryObject andTimesheetUri:timesheetUri isPending:YES];
        [self saveWidgetTimesheetSummaryOfHoursIntoDB:widgetTimesheetSummaryDict andTimesheetUri:timesheetUri isPending:YES];
        if([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            if([[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"]!=nil && ![[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"] isKindOfClass:[NSNull class]])
            {
                [self saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"] moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
            }
        }
        
        int superPermissionForBreaks=[[capablitiesDict objectForKey:@"hasBreakAccess"] intValue];
        int superPermissionForTimesheetEdit=[[capablitiesDict objectForKey:@"canEditTimesheet"] intValue];
        int allowBreakForInOutGen4=0;
        int allowTimeEntryCommentsForInOutGen4=0;
        int allowTimeEntryEditForInOutGen4=0;
        int allowBreakForStandardGen4=0;
        int allowTimeEntryEditForStandardGen4=0;
        int allowClientsForStandardGen4=0;
        int allowProgramsForStandardGen4=0;
        int allowCommentsForStandardGen4=0;
        int allowProjectsTasksForStandardGen4=0;
        int allowActivitiesForStandardGen4=0;
        int allowBillingForStandardGen4=0;
        int allowReopenForGen4=0;
        int alowReopenAfterApprovalForGen4=0;
        int allowResubmitWithBlankCommentsForGen4=0;
        int allowTimeoffForGen4=0;
        int allowBreakForPunchInGen4=0;
        int allowBreakForExtInOutGen4=0;
        int allowTimeEntryCommentsForExtInOutGen4=0;
        int allowClientsForExtInOutGen4=0;
        int allowProgramsForExtInOutGen4=0;
        int allowProjectsTasksForExtInOutGen4=0;
        int allowActivitiesForExtInOutGen4=0;
        int allowBillingForExtInOutGen4=0;
        int allowTimeEntryEditForExtInOutGen4=1;
        int canOwnerViewPayrollSummary=[[capablitiesDict objectForKey:@"canOwnerViewPayrollSummary"] intValue];
        int canOwnerViewPayDetails=[[capablitiesDict objectForKey:@"canOwnerViewPayDetails"] intValue];
        int allowSplitMidNightCrossTime = 0;
        for (int h=0; h<[widgetTimesheetCapabilitiesResponse count]; h++)
        {
            NSMutableDictionary *responseDict=[widgetTimesheetCapabilitiesResponse objectAtIndex:h];
            if (responseDict!=nil &&![responseDict isKindOfClass:[NSNull class]])
            {
                NSString *policyKeyUri=[responseDict objectForKey:@"policyKeyUri"];
                id policyValue=[[responseDict objectForKey:@"policyValue"] objectForKey:@"uri"];
                
                
                
                
                if ([policyKeyUri isEqualToString:PUNCH_BREAK_ACCESS_KEY])
                {
                    if ([policyValue isEqualToString:NotAllowedPunchInBreakPolicyValueUri])
                    {
                        allowBreakForPunchInGen4=0;
                    }
                    else
                    {
                        allowBreakForPunchInGen4=1;
                    }
                }
                
                else if ([policyKeyUri isEqualToString:Gen4InOutTimesheetFormat])
                {
                    
                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];
                    
                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {
                        
                        NSString *tmpPolicyValue=nil;
                        if (b%2==0)
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                        }
                        else
                        {
                            tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                        }
                        if ([tmpPolicyKey isEqualToString:GEN4_INOUT_BREAK_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableBreakUriPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBreakForInOutGen4=1;
                            }
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_INOUT_TIME_ENTRY_COMMENTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableTimeEntryCommentsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowTimeEntryCommentsForInOutGen4=1;
                            }
                        }
                        if ([tmpPolicyKey isEqualToString:GEN4_INOUT_EDIT_TIME_ENTRIES_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableEditTimeEntriesPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowTimeEntryEditForInOutGen4=1;
                            }
                            
                        }
                        if ([tmpPolicyKey isEqualToString:inOutWidgetMidNightCrossUri])
                        {
                            if ([tmpPolicyValue isEqualToString:allowInOutWidgetSplitMidNightCrossUri])
                            {
                                tmpPolicyKey=nil;
                                allowSplitMidNightCrossTime=1;
                            }
                        }
                        
                    }
                }

                else if ([policyKeyUri isEqualToString:EXT_INOUT_WIDGET_URI])
                {

                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];

                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {

                        NSString *tmpPolicyValue=nil;
                        if ([[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:GEN4_EXT_INOUT_ENTRY_OEF_POLICY_URI])
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];

                        }
                        else
                        {
                            if (b%2==0)
                            {
                                tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                            }
                            else
                            {
                                tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                            }
                        }

                        if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_BREAK_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_BreakUriPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBreakForExtInOutGen4=1;
                            }

                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_TIME_ENTRY_COMMENTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_TimeEntryCommentsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowTimeEntryCommentsForExtInOutGen4=1;
                            }
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_FILTER_PROJECTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4ClientsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowClientsForExtInOutGen4=1;
                            }
                            else if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4ProgramsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProgramsForExtInOutGen4=1;
                            }


                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_PROJECTS_TASKS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4ProjectsAndTasksPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProjectsTasksForExtInOutGen4=1;
                            }

                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_ACTIVITIES_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4AllowActivitiesPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowActivitiesForExtInOutGen4=1;
                            }


                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_BILLING_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4AllowBillingPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBillingForExtInOutGen4=1;
                            }
                            
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:extendedInOutWidgetMidNightCrossUri])
                        {
                            if ([tmpPolicyValue isEqualToString:allowExtendedInOutWidgetSplitMidNightCrossUri])
                            {
                                tmpPolicyKey=nil;
                                allowSplitMidNightCrossTime=1;
                            }
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_ENTRY_OEF_POLICY_URI])
                        {


                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *entryLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"entryLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (entryLevelObjectExtensionFieldDetailsArr!=nil && ![entryLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *entryLevelObjectExtensionFieldDetailsDict in entryLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *entryLevelObjectExtensionFieldUri=entryLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:entryLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *timeSheetObjectExtenssionFieldDict=nil;
                                            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_EXT_INOUT_TIMESHEET};
                                            }
                                            else
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetFormat":GEN4_EXT_INOUT_TIMESHEET};
                                            }
                                            [self saveObjectExtensionDetailsDataToDB:timeSheetObjectExtenssionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_EXT_INOUT_TIMESHEET];
                                            break;
                                        }
                                    }
                                }


                            }
                            
                            
                        }
                        
                    }
                }


                else if ([policyKeyUri isEqualToString:STANDARD_WIDGET_URI])
                {
                    
                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];
                    
                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {
                        
                        NSString *tmpPolicyValue=nil;
                        if ([[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:GEN4_STANDARD_ROW_OEF_POLICY_URI] || [[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:GEN4_STANDARD_ENTRY_OEF_POLICY_URI])
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];

                        }
                        else
                        {
                            if (b%2==0)
                            {
                                tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                            }
                            else
                            {
                                tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                            }
                        }
                        if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_FILTER_PROJECTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4ClientsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowClientsForStandardGen4=1;
                            }
                            else if ([tmpPolicyValue isEqualToString:EnableStandardGen4ProgramsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProgramsForStandardGen4=1;
                            }
                            
                            
                        }
                        
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_PROJECTS_TASKS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4ProjectsAndTasksPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProjectsTasksForStandardGen4=1;
                            }
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_ACTIVITIES_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4AllowActivitiesPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowActivitiesForStandardGen4=1;
                            }
                            
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_BILLING_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4AllowBillingPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBillingForStandardGen4=1;
                            }
                            
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_TIME_ENTRY_COMMENTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardTimeEntryCommentsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowCommentsForStandardGen4=1;
                            }
                            
                            
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_ENTRY_OEF_POLICY_URI])
                        {


                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *entryLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"entryLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (entryLevelObjectExtensionFieldDetailsArr!=nil && ![entryLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *entryLevelObjectExtensionFieldDetailsDict in entryLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *entryLevelObjectExtensionFieldUri=entryLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:entryLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *timeSheetObjectExtenssionFieldDict=nil;
                                            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            else
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            
                                            [self saveObjectExtensionDetailsDataToDB:timeSheetObjectExtenssionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
                                            break;
                                        }
                                    }
                                }


                            }


                        }

                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_ROW_OEF_POLICY_URI])
                        {


                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *rowLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"rowLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (rowLevelObjectExtensionFieldDetailsArr!=nil && ![rowLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *entryLevelObjectExtensionFieldDetailsDict in rowLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *entryLevelObjectExtensionFieldUri=entryLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:entryLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *timeSheetObjectExtenssionFieldDict=nil;
                                            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_ROW_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            else
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_ROW_OEF,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            [self saveObjectExtensionDetailsDataToDB:timeSheetObjectExtenssionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
                                            break;
                                        }
                                    }
                                }

                                
                            }
                            
                            
                        }
                    }
                }
                else if ([policyKeyUri isEqualToString:GEN4_TIME_OFF_POLICY_URI]) {
                    if (policyValue!=nil && ![policyValue isKindOfClass:[NSNull class]])
                    {
                        allowTimeoffForGen4=1;
                    }
                    
                }
                else if ([policyKeyUri isEqualToString:GEN4_CAN_REOPEN_POLICY_URI])
                {
                    if ([policyValue isEqualToString:AllowedCanReopenPolicyValueUri])
                    {
                        allowReopenForGen4=1;
                    }
                    else if ([policyValue isEqualToString:NotAllowedCanReopenPolicyValueUri])
                    {
                        allowReopenForGen4=0;
                    }
                }
                else if ([policyKeyUri isEqualToString:GEN4_CAN_REOPEN_AFTER_APPROVALS_POLICY_URI])
                {
                    if ([policyValue isEqualToString:AllowedCanReopenAfterApprovalsPolicyValueUri])
                    {
                        alowReopenAfterApprovalForGen4=1;
                    }
                    else if ([policyValue isEqualToString:NotAllowedCanReopenAfterApprovalsPolicyValueUri])
                    {
                        alowReopenAfterApprovalForGen4=0;
                    }
                    
                }
                else if ([policyKeyUri isEqualToString:GEN4_CAN_RESUBMIT_WITH_BLANK_COMMENTS_POLICY_URI])
                {
                    if ([policyValue isEqualToString:AllowedCanResubmitWithBlanlkCommentsPolicyValueUri])
                    {
                        allowResubmitWithBlankCommentsForGen4=1;
                    }
                    else if ([policyValue isEqualToString:NotAllowedCanResubmitWithBlanlkCommentsPolicyValueUri])
                    {
                        allowResubmitWithBlankCommentsForGen4=0;
                    }
                    
                }
                else if ([policyKeyUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
                {

                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];

                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {

                        NSString *tmpPolicyValue=nil;
                        if ([[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:DAILY_WIDGET_OEF_POLICY_URI])
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];

                        }
                        else
                        {
                            if (b%2==0)
                            {
                                tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                            }
                            else
                            {
                                tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                            }
                        }


                        if ([tmpPolicyKey isEqualToString:DAILY_WIDGET_OEF_POLICY_URI])
                        {

                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *dayLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"dayLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (dayLevelObjectExtensionFieldDetailsArr!=nil && ![dayLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *dayLevelObjectExtensionFieldDetailsDict in dayLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *dayLevelObjectExtensionFieldUri=dayLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:dayLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *dayLevelObjectExtensionFieldDict=nil;
                                            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]]) {
                                                dayLevelObjectExtensionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":dayLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":dayLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":DAILY_WIDGET_DAYLEVEL_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_DAILY_WIDGET_TIMESHEET};
                                            }
                                            else
                                            {
                                                dayLevelObjectExtensionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":dayLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":dayLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":DAILY_WIDGET_DAYLEVEL_OEF,@"timesheetFormat":GEN4_DAILY_WIDGET_TIMESHEET};
                                            }
                                           
                                            [self saveObjectExtensionDetailsDataToDB:dayLevelObjectExtensionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET];
                                            break;
                                        }
                                    }

                                }

                            }
                            
                            
                        }
                        
                    }
                }
                
                
                
            }
        }
        
        //Overriding values according to the super permissions
        if (superPermissionForBreaks==0)
        {
            allowBreakForInOutGen4=0;
            
        }
        if (superPermissionForTimesheetEdit==0)
        {
            allowTimeEntryEditForInOutGen4=0;
            allowTimeEntryEditForStandardGen4=0;
            allowTimeEntryEditForExtInOutGen4=0;
        }
        
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSMutableDictionary *timesheetPermittedApprovalActions=[NSMutableDictionary dictionaryWithDictionary:[responseDictionaryObject objectForKey:@"permittedApprovalActions"]];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForInOutGen4] forKey:@"allowBreakForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForStandardGen4] forKey:@"allowBreakForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryCommentsForInOutGen4] forKey:@"allowTimeEntryCommentsForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowCommentsForStandardGen4] forKey:@"allowCommentsForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryEditForInOutGen4] forKey:@"allowTimeEntryEditForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryEditForStandardGen4] forKey:@"allowTimeEntryEditForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowReopenForGen4] forKey:@"allowReopenForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:alowReopenAfterApprovalForGen4] forKey:@"alowReopenAfterApprovalForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowResubmitWithBlankCommentsForGen4] forKey:@"allowResubmitWithBlankCommentsForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeoffForGen4] forKey:@"allowTimeoffForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForPunchInGen4] forKey:@"allowBreakForPunchInGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowClientsForStandardGen4] forKey:@"allowClientsForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProgramsForStandardGen4] forKey:@"allowProgramsForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProjectsTasksForStandardGen4] forKey:@"allowProjectsTasksForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowActivitiesForStandardGen4] forKey:@"allowActivitiesForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBillingForStandardGen4] forKey:@"allowBillingForStandardGen4"];

        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForExtInOutGen4] forKey:@"allowBreakForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryCommentsForExtInOutGen4] forKey:@"allowTimeEntryCommentsForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowClientsForExtInOutGen4] forKey:@"allowClientsForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProgramsForExtInOutGen4] forKey:@"allowProgramsForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProjectsTasksForExtInOutGen4] forKey:@"allowProjectsTasksForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowActivitiesForExtInOutGen4] forKey:@"allowActivitiesForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBillingForExtInOutGen4] forKey:@"allowBillingForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryEditForExtInOutGen4] forKey:@"allowTimeEntryEditForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:canOwnerViewPayrollSummary] forKey:@"canOwnerViewPayrollSummary"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:canOwnerViewPayDetails] forKey:@"canOwnerViewPayDetails"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowSplitMidNightCrossTime] forKey:@"allowSplitTimeMidnightCrossEntry"];
        
        
        if (![timesheetUri isKindOfClass:[NSNull class]] && timesheetUri!=nil )
        {
            [timesheetPermittedApprovalActions setObject:timesheetUri forKey:@"uri"];
        }

//        
//        
        [supportModel saveTimesheetPermittedApprovalActionsDataToDB:timesheetPermittedApprovalActions];
        [self updatecanEditTimesheetStatusForTimesheetWithUri:timesheetUri withStatus:superPermissionForTimesheetEdit andIsPending:YES];
        [self updateTimesheetFormatForTimesheetWithUri:timesheetUri andIsPending:YES];
        
        NSString *timesheetApprovalStatusUri=nil;
        if([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"]isKindOfClass:[NSNull class]])
        {
            if([[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"]!=nil && ![[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"]isKindOfClass:[NSNull class]])
            {
                if([[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"]!=nil && ![[[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"] isKindOfClass:[NSNull class]])
                {
                    timesheetApprovalStatusUri=[[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"];
                }
            }
        }
        NSString *timesheetApprovalStatus=nil;
        if (timesheetApprovalStatusUri!=nil && ![timesheetApprovalStatusUri isKindOfClass:[NSNull class]])
        {
            if ([timesheetApprovalStatusUri isEqualToString:APPROVED_STATUS_URI])
            {
                timesheetApprovalStatus=APPROVED_STATUS;
            }
            else if ([timesheetApprovalStatusUri isEqualToString:NOT_SUBMITTED_STATUS_URI])
            {
                timesheetApprovalStatus=NOT_SUBMITTED_STATUS ;
            }
            else if ([timesheetApprovalStatusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
            {
                timesheetApprovalStatus=WAITING_FOR_APRROVAL_STATUS;
            }
            else if ([timesheetApprovalStatusUri isEqualToString:REJECTED_STATUS_URI])
            {
                timesheetApprovalStatus=REJECTED_STATUS;
            }
            
            if(timesheetApprovalStatus)
            {
                
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                
                [dataDict setObject:timesheetApprovalStatus forKey:@"approvalStatus" ];
                
                [myDB updateTable:approvalPendingTimesheetsTable data:dataDict where:[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri] intoDatabase:@""];
            }
            
            
        }
        
    }
    else
    {
        NSMutableDictionary *timesheetDetailsDict=[responseDictionaryObject objectForKey:@"inOutTimesheetDetails"];

        NSMutableDictionary *standardTimesheetDetailsDict=[responseDictionaryObject objectForKey:@"standardTimesheetDetails"];
        
        int isNoticeExplicitlyAccepted=0;
        BOOL isTimesheetCommentsRequired=NO;
        //US9453 to address DE17320 Ullas M L
        NSMutableDictionary *capablitiesDict=[responseDictionaryObject objectForKey:@"capabilities"];
        NSMutableArray *enableOnlySheetUdfUriArr=[capablitiesDict objectForKey:@"enabledCustomFieldUris"];
        NSMutableArray *enableOnlyRowOrCellUdfUriArr=[capablitiesDict objectForKey:@"enabledEntryCustomFieldUris"];
        [self updateCustomFieldTableFor:TIMESHEET_SHEET_UDF enableUdfuriArray:enableOnlySheetUdfUriArr];
        [self updateCustomFieldTableFor:TIMESHEET_CELL_UDF enableUdfuriArray:enableOnlyRowOrCellUdfUriArr];
        [self updateCustomFieldTableFor:TIMESHEET_ROW_UDF enableUdfuriArray:enableOnlyRowOrCellUdfUriArr];
        NSMutableDictionary *disclaimerDict=[NSMutableDictionary dictionary];
        NSMutableArray *changeReasonArray = [NSMutableArray array];
        changeReasonArray = [responseDictionaryObject objectForKey:@"changeReasonEntries"];
        if (![timesheetDetailsDict isKindOfClass:[NSNull class]] && timesheetDetailsDict!=nil) {
            disclaimerDict=[timesheetDetailsDict objectForKey:@"timesheetNotice"];
            timesheetUri=[timesheetDetailsDict objectForKey:@"uri"];
            if ([[timesheetDetailsDict objectForKey:@"noticeExplicitlyAccepted"] boolValue] == YES )
            {
                isNoticeExplicitlyAccepted = 1;
            }
            if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"timesheetCommentsRequired"] boolValue]==YES)
            {
                isTimesheetCommentsRequired=YES;
            }
            
            
        }
        else if (![standardTimesheetDetailsDict isKindOfClass:[NSNull class]] && standardTimesheetDetailsDict!=nil)
        {
            disclaimerDict=[standardTimesheetDetailsDict objectForKey:@"timesheetNotice"];
            timesheetUri=[standardTimesheetDetailsDict objectForKey:@"uri"];
            if ([[standardTimesheetDetailsDict objectForKey:@"noticeExplicitlyAccepted"] boolValue] == YES )
            {
                isNoticeExplicitlyAccepted = 1;
            }
            if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"timesheetCommentsRequired"] boolValue]==YES)
            {
                isTimesheetCommentsRequired=YES;
            }
            
        }
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        //US9453 to address DE17320 Ullas M L
         [self saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPending:enableOnlySheetUdfUriArr andArray:enableOnlyRowOrCellUdfUriArr forTimesheetUri:timesheetUri];
        
        int hasBillingAccess            =0;
        int hasProjectAccess            =0;
        int hasClientAccess             =0;
        int hasActivityAccess           =0;
        int hasBreakAccess              =0;
        int hasProgramAccess            =0;//MOBI-746
        
        NSDictionary *timesheetCurrentCapabilities=[responseDictionaryObject objectForKey:@"capabilities"];
        if ([[timesheetCurrentCapabilities objectForKey:@"hasBillingAccess"] boolValue] == YES )
        {
            hasBillingAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES )
        {
            hasProjectAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasClientAccess"] boolValue] == YES )
        {
            hasClientAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES )
        {
            hasActivityAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasProgramAccess"] boolValue] == YES )
        {
            hasProgramAccess = 1;
        }
        NSString *hasTimesheetNoticePolicyUri =[timesheetCurrentCapabilities objectForKey:@"timesheetNoticePolicyUri"];
        
        NSMutableDictionary *capabilityDictionary=[NSMutableDictionary dictionary];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasBillingAccess] forKey:@"hasTimesheetBillingAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasProjectAccess] forKey:@"hasTimesheetProjectAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasClientAccess] forKey:@"hasTimesheetClientAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasActivityAccess] forKey:@"hasTimesheetActivityAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasBreakAccess] forKey:@"hasTimesheetBreakAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasProgramAccess] forKey:@"hasTimesheetProgramAccess"];
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [capabilityDictionary setObject:timesheetUri  forKey:@"timesheetUri"];
        }
        if (hasTimesheetNoticePolicyUri!=nil && ![hasTimesheetNoticePolicyUri isKindOfClass:[NSNull class]])
        {
            [capabilityDictionary setObject:hasTimesheetNoticePolicyUri  forKey:@"disclaimerTimesheetNoticePolicyUri"];
        }
        
        [myDB deleteFromTable:approvalPendingTimesheetCapabilitiesTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        [myDB insertIntoTable:approvalPendingTimesheetCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
        
        
        NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
        NSString *approvalStatus = nil;
        if([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"]isKindOfClass:[NSNull class]])
        {
            if([[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"approvalStatus"]!=nil && ![[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"approvalStatus"]isKindOfClass:[NSNull class]])
            {
                if([[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"approvalStatus"] objectForKey:@"uri"]!=nil && ![[[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"approvalStatus"] objectForKey:@"uri"]isKindOfClass:[NSNull class]])
                {
                    approvalStatus =[[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"approvalStatus"] objectForKey:@"uri"];
                }
                
            }
            
        }
        
        
        
        
        
        if ([approvalStatus isEqualToString:APPROVED_STATUS_URI])
        {
            [updateDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
        }
        else if ([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS_URI])
        {
            [updateDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
        }
        else if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
        {
            [updateDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
        }
        else if ([approvalStatus isEqualToString:REJECTED_STATUS_URI])
        {
            [updateDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
        }
        else
        {
            [updateDict setObject:[NSNull null] forKey:@"approvalStatus"];
        }
        
        
        
        
        if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"canEditTimesheet"] boolValue] == NO )
        {
            [updateDict setObject:[NSNumber numberWithInt:0] forKey:@"canEditTimesheet"];
        }
        else
        {
            [updateDict setObject:[NSNumber numberWithInt:1] forKey:@"canEditTimesheet"];
        }
        
        [myDB updateTable:approvalPendingTimesheetsTable data:updateDict where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] intoDatabase:@""];
        
        [myDB deleteFromTable:approvalPendingTimesheetCustomFieldsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        
        
        
        NSMutableDictionary *timesheetSummaryDict=[responseDictionaryObject objectForKey:@"timesheetSummary"];
        NSMutableArray *timesheetActivitiesSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByActivity"];
        NSMutableArray *timesheetProjectsSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByProject"];
        NSMutableArray *timesheetBillingSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByBillingRate"];
        NSMutableArray *timesheetPayrollSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByPaycode"];
        NSMutableArray *timesheetDateSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByDate"];
        NSMutableArray *timesheetApproverSummaryArray=nil;
        if ([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            timesheetApproverSummaryArray=[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"history"];
        }
        
        NSDictionary *timesheetNonBillabeSummaryDict=[timesheetSummaryDict objectForKey:@"nonBillableTimeDuration"];
        //US9278 Ullas M L
        NSDictionary *timesheetTotalHoursDict=[timesheetSummaryDict objectForKey:@"totalTimeDuration"];
        //NSDictionary *breakHoursDict=[timesheetSummaryDict objectForKey:@"breakDuration"];
        NSNumber *totalHours=[Util convertApiTimeDictToDecimal:timesheetTotalHoursDict];
        //NSNumber *breakHours=[Util convertApiTimeDictToDecimal:breakHoursDict];
        NSString *hoursIncludingBreak=[NSString stringWithFormat:@"%f",[totalHours newFloatValue]];
        NSString *hoursValue=@"";
        NSString *minsValue=@"";
        NSArray *componentsArr=[hoursIncludingBreak componentsSeparatedByString:@"."];
        if ([componentsArr count]==2)
        {
            hoursValue = [componentsArr objectAtIndex:0];
            minsValue =[componentsArr objectAtIndex:1];
        }
        NSString *hoursIncludingBreakStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];
        NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
        [timesheetDataDict setObject:hoursIncludingBreak      forKey:@"totalDurationDecimal"];
        [timesheetDataDict setObject:hoursIncludingBreakStr   forKey:@"totalDurationHour"];
        NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
        
        [myDB updateTable: approvalPendingTimesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
        
        if (![timesheetActivitiesSummaryArray isKindOfClass:[NSNull class]] && timesheetActivitiesSummaryArray!=nil )
        {
            [self saveApprovalTimesheetActivitiesSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetActivitiesSummaryArray moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        if (![timesheetProjectsSummaryArray isKindOfClass:[NSNull class]] && timesheetProjectsSummaryArray!=nil )
        {
            [self saveApprovalTimesheetProjectSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetProjectsSummaryArray moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        if (![timesheetBillingSummaryArray isKindOfClass:[NSNull class]] && timesheetBillingSummaryArray!=nil )
        {
            [self saveApprovalTimesheetBillingSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetBillingSummaryArray withNonBillableDict:timesheetNonBillabeSummaryDict moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        if (![timesheetPayrollSummaryArray isKindOfClass:[NSNull class]] && timesheetPayrollSummaryArray!=nil )
        {
            [self saveApprovalTimesheetPayrollSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetPayrollSummaryArray moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        if (![timesheetDateSummaryArray isKindOfClass:[NSNull class]] && timesheetDateSummaryArray!=nil )
        {
            [self saveApprovalTimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetDateSummaryArray withNoticeAcceptedFlag:isNoticeExplicitlyAccepted moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE isTimesheetCommentsRequired:isTimesheetCommentsRequired];
        }
        if (![timesheetApproverSummaryArray isKindOfClass:[NSNull class]] && timesheetApproverSummaryArray!=nil )
        {
            [self saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetApproverSummaryArray moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        if (![disclaimerDict isKindOfClass:[NSNull class]] && disclaimerDict!=nil )
        {
            [self saveApprovalTimesheetDisclaimerDataToDB:disclaimerDict moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        
        if (![timesheetDetailsDict isKindOfClass:[NSNull class]] && timesheetDetailsDict!=nil )
        {
            NSArray *sheetCustomFieldsArray=[timesheetDetailsDict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_SHEET_UDF andEntryURI:nil andtimeEntryDate:nil moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
            
            [self saveTimeAlloctionsAndPunchesDataToDBForTimesheetUri:timesheetUri dataDict:responseDictionaryObject moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        
        if (![standardTimesheetDetailsDict isKindOfClass:[NSNull class]] && standardTimesheetDetailsDict!=nil )
        {
            
            NSArray *sheetCustomFieldsArray=[standardTimesheetDetailsDict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_SHEET_UDF andEntryURI:nil andtimeEntryDate:nil moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];

            NSArray *projectTaskDetailsArray = nil;
            NSArray *taskDetailsArray = nil;
            if ([responseDictionaryObject objectForKey:@"projectTaskDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"projectTaskDetails"] isKindOfClass:[NSNull class]])
            {
                projectTaskDetailsArray=[[responseDictionaryObject objectForKey:@"projectTaskDetails"] objectForKey:@"projects"];
                taskDetailsArray=[[responseDictionaryObject objectForKey:@"projectTaskDetails"] objectForKey:@"tasks"];
            }

            
            [self saveStandardTimeEntriesDataToDBForTimesheetUri:timesheetUri dataDict:standardTimesheetDetailsDict projectTaskDetails:projectTaskDetailsArray taskDetails:taskDetailsArray moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
            
            
        }
        
        if (![changeReasonArray isKindOfClass:[NSNull class]] && changeReasonArray!=nil && [changeReasonArray count]>0)
        {
            [self saveApprovalTimesheetChangeReasonEntriesDataToDBForTimesheetUri:timesheetUri dataArray:changeReasonArray moduleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
        }
        
        
        
        
    }
}
-(void)savePreviousApprovalTimeSheetSummaryDetailsDataFromApiToDB:(NSMutableDictionary *)responseDictionaryObject
{
    NSMutableDictionary *widgetTimesheetSummaryDict=[responseDictionaryObject objectForKey:@"widgetTimesheetSummary"];
    NSString *timesheetUri=nil;
    if([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
    {
        timesheetUri=[[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"timesheet"] objectForKey:@"uri"];
    }
    [self deleteObjectExtensionFieldsFromDBForTimesheetUri:timesheetUri];

    if (widgetTimesheetSummaryDict!=nil && ![widgetTimesheetSummaryDict isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *capablitiesDict=[responseDictionaryObject objectForKey:@"capabilities"];
        NSMutableArray *widgetTimesheetCapabilitiesResponse=[capablitiesDict objectForKey:@"widgetTimesheetCapabilities"];
        [self saveEnabledWidgetsDetailsIntoDB:responseDictionaryObject andTimesheetUri:timesheetUri isPending:NO];
        [self saveWidgetTimesheetSummaryOfHoursIntoDB:widgetTimesheetSummaryDict andTimesheetUri:timesheetUri isPending:NO];
        [self saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"] moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        int superPermissionForBreaks=[[capablitiesDict objectForKey:@"hasBreakAccess"] intValue];
        int superPermissionForTimesheetEdit=[[capablitiesDict objectForKey:@"canEditTimesheet"] intValue];
        int allowBreakForInOutGen4=0;
        int allowTimeEntryCommentsForInOutGen4=0;
        int allowTimeEntryEditForInOutGen4=0;
        int allowBreakForStandardGen4=0;
        int allowTimeEntryEditForStandardGen4=0;
        int allowClientsForStandardGen4=0;
        int allowProgramsForStandardGen4=0;
        int allowCommentsForStandardGen4=0;
        int allowProjectsTasksForStandardGen4=0;
        int allowActivitiesForStandardGen4=0;
        int allowBillingForStandardGen4=0;
        int allowReopenForGen4=0;
        int alowReopenAfterApprovalForGen4=0;
        int allowResubmitWithBlankCommentsForGen4=0;
        int allowTimeoffForGen4=0;
        int allowBreakForPunchInGen4=0;
        int allowBreakForExtInOutGen4=0;
        int allowTimeEntryCommentsForExtInOutGen4=0;
        int allowClientsForExtInOutGen4=0;
        int allowProgramsForExtInOutGen4=0;
        int allowProjectsTasksForExtInOutGen4=0;
        int allowActivitiesForExtInOutGen4=0;
        int allowBillingForExtInOutGen4=0;
        int allowTimeEntryEditForExtInOutGen4=1;
        int canOwnerViewPayrollSummary=[[capablitiesDict objectForKey:@"canOwnerViewPayrollSummary"] intValue];
        int canOwnerViewPayDetails=[[capablitiesDict objectForKey:@"canOwnerViewPayDetails"] intValue];
        int allowSplitMidNightCrossTime = 0;
        for (int h=0; h<[widgetTimesheetCapabilitiesResponse count]; h++)
        {
            NSMutableDictionary *responseDict=[widgetTimesheetCapabilitiesResponse objectAtIndex:h];
            if (responseDict!=nil &&![responseDict isKindOfClass:[NSNull class]])
            {
                NSString *policyKeyUri=[responseDict objectForKey:@"policyKeyUri"];
                id policyValue=[[responseDict objectForKey:@"policyValue"] objectForKey:@"uri"];
                
                
                
                
                if ([policyKeyUri isEqualToString:PUNCH_BREAK_ACCESS_KEY])
                {
                    if ([policyValue isEqualToString:NotAllowedPunchInBreakPolicyValueUri])
                    {
                        allowBreakForPunchInGen4=0;
                    }
                    else
                    {
                        allowBreakForPunchInGen4=1;
                    }
                }
                
                else if ([policyKeyUri isEqualToString:Gen4InOutTimesheetFormat])
                {
                    
                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];
                    
                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {
                        
                        NSString *tmpPolicyValue=nil;
                        if (b%2==0)
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                        }
                        else
                        {
                            tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                        }
                        if ([tmpPolicyKey isEqualToString:GEN4_INOUT_BREAK_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableBreakUriPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBreakForInOutGen4=1;
                            }
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_INOUT_TIME_ENTRY_COMMENTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableTimeEntryCommentsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowTimeEntryCommentsForInOutGen4=1;
                            }
                        }
                        if ([tmpPolicyKey isEqualToString:GEN4_INOUT_EDIT_TIME_ENTRIES_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableEditTimeEntriesPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowTimeEntryEditForInOutGen4=1;
                            }
                            
                        }
                        if ([tmpPolicyKey isEqualToString:inOutWidgetMidNightCrossUri])
                        {
                            if ([tmpPolicyValue isEqualToString:allowInOutWidgetSplitMidNightCrossUri])
                            {
                                tmpPolicyKey=nil;
                                allowSplitMidNightCrossTime=1;
                            }
                        }
                    }
                }

                else if ([policyKeyUri isEqualToString:EXT_INOUT_WIDGET_URI])
                {

                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];

                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {

                        NSString *tmpPolicyValue=nil;
                        if ([[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:GEN4_EXT_INOUT_ENTRY_OEF_POLICY_URI])
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];

                        }
                        else
                        {
                            if (b%2==0)
                            {
                                tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                            }
                            else
                            {
                                tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                            }
                        }

                        if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_BREAK_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_BreakUriPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBreakForExtInOutGen4=1;
                            }

                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_TIME_ENTRY_COMMENTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_TimeEntryCommentsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowTimeEntryCommentsForExtInOutGen4=1;
                            }
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_FILTER_PROJECTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4ClientsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowClientsForExtInOutGen4=1;
                            }
                            else if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4ProgramsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProgramsForExtInOutGen4=1;
                            }


                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_PROJECTS_TASKS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4ProjectsAndTasksPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProjectsTasksForExtInOutGen4=1;
                            }

                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_ACTIVITIES_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4AllowActivitiesPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowActivitiesForExtInOutGen4=1;
                            }


                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_BILLING_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:Enable_EXT_INOUT_Gen4AllowBillingPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBillingForExtInOutGen4=1;
                            }
                        }
                        else if ([tmpPolicyKey isEqualToString:extendedInOutWidgetMidNightCrossUri])
                        {
                            if ([tmpPolicyValue isEqualToString:allowExtendedInOutWidgetSplitMidNightCrossUri])
                            {
                                tmpPolicyKey=nil;
                                allowSplitMidNightCrossTime=1;
                            }
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_EXT_INOUT_ENTRY_OEF_POLICY_URI])
                        {


                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *entryLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"entryLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (entryLevelObjectExtensionFieldDetailsArr!=nil && ![entryLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *entryLevelObjectExtensionFieldDetailsDict in entryLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *entryLevelObjectExtensionFieldUri=entryLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:entryLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *timeSheetObjectExtenssionFieldDict=nil;
                                            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_EXT_INOUT_TIMESHEET};
                                            }
                                            else
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetFormat":GEN4_EXT_INOUT_TIMESHEET};
                                            }
                                            
                                            [self saveObjectExtensionDetailsDataToDB:timeSheetObjectExtenssionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_EXT_INOUT_TIMESHEET];
                                            break;
                                        }
                                    }

                                }

                            }
                        }
                    }
                }


                else if ([policyKeyUri isEqualToString:STANDARD_WIDGET_URI])
                {
                    
                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];
                    
                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {
                        
                        NSString *tmpPolicyValue=nil;
                        if ([[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:GEN4_STANDARD_ROW_OEF_POLICY_URI] || [[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:GEN4_STANDARD_ENTRY_OEF_POLICY_URI])
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];

                        }
                        else
                        {
                            if (b%2==0)
                            {
                                tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                            }
                            else
                            {
                                tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                            }
                        }
                        if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_FILTER_PROJECTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4ClientsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowClientsForStandardGen4=1;
                            }
                            else if ([tmpPolicyValue isEqualToString:EnableStandardGen4ProgramsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProgramsForStandardGen4=1;
                            }
                            
                            
                        }
                        
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_PROJECTS_TASKS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4ProjectsAndTasksPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowProjectsTasksForStandardGen4=1;
                            }
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_ACTIVITIES_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4AllowActivitiesPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowActivitiesForStandardGen4=1;
                            }
                            
                            
                        }
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_BILLING_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardGen4AllowBillingPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowBillingForStandardGen4=1;
                            }
                            
                            
                        }
                        else if ([tmpPolicyValue isEqualToString:GEN4_STANDARD_TIME_ENTRY_COMMENTS_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:EnableStandardTimeEntryCommentsPolicyValueUri])
                            {
                                tmpPolicyKey=nil;
                                allowCommentsForStandardGen4=1;
                            }
                            
                            
                            
                        }

                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_ENTRY_OEF_POLICY_URI])
                        {


                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *entryLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"entryLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (entryLevelObjectExtensionFieldDetailsArr!=nil && ![entryLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *entryLevelObjectExtensionFieldDetailsDict in entryLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *entryLevelObjectExtensionFieldUri=entryLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:entryLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *timeSheetObjectExtenssionFieldDict=nil;
                                            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                            timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            else
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_CELL_OEF,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            [self saveObjectExtensionDetailsDataToDB:timeSheetObjectExtenssionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
                                            break;
                                        }
                                    }

                                }

                            }


                        }

                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_ROW_OEF_POLICY_URI])
                        {


                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *rowLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"rowLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (rowLevelObjectExtensionFieldDetailsArr!=nil && ![rowLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *entryLevelObjectExtensionFieldDetailsDict in rowLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *entryLevelObjectExtensionFieldUri=entryLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:entryLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *timeSheetObjectExtenssionFieldDict=nil;
                                            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_ROW_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            else
                                            {
                                                timeSheetObjectExtenssionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":entryLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":entryLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":TIMESHEET_ROW_OEF,@"timesheetFormat":GEN4_STANDARD_TIMESHEET};
                                            }
                                            
                                            [self saveObjectExtensionDetailsDataToDB:timeSheetObjectExtenssionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
                                            break;
                                        }
                                    }
                                }

                                
                            }
                            
                            
                        }
                    }
                }
                else if ([policyKeyUri isEqualToString:GEN4_TIME_OFF_POLICY_URI]) {
                    if (policyValue!=nil && ![policyValue isKindOfClass:[NSNull class]])
                    {
                        allowTimeoffForGen4=1;
                    }
                    
                }
                else if ([policyKeyUri isEqualToString:GEN4_CAN_REOPEN_POLICY_URI])
                {
                    if ([policyValue isEqualToString:AllowedCanReopenPolicyValueUri])
                    {
                        allowReopenForGen4=1;
                    }
                    else if ([policyValue isEqualToString:NotAllowedCanReopenPolicyValueUri])
                    {
                        allowReopenForGen4=0;
                    }
                }
                else if ([policyKeyUri isEqualToString:GEN4_CAN_REOPEN_AFTER_APPROVALS_POLICY_URI])
                {
                    if ([policyValue isEqualToString:AllowedCanReopenAfterApprovalsPolicyValueUri])
                    {
                        alowReopenAfterApprovalForGen4=1;
                    }
                    else if ([policyValue isEqualToString:NotAllowedCanReopenAfterApprovalsPolicyValueUri])
                    {
                        alowReopenAfterApprovalForGen4=0;
                    }
                    
                }
                else if ([policyKeyUri isEqualToString:GEN4_CAN_RESUBMIT_WITH_BLANK_COMMENTS_POLICY_URI])
                {
                    if ([policyValue isEqualToString:AllowedCanResubmitWithBlanlkCommentsPolicyValueUri])
                    {
                        allowResubmitWithBlankCommentsForGen4=1;
                    }
                    else if ([policyValue isEqualToString:NotAllowedCanResubmitWithBlanlkCommentsPolicyValueUri])
                    {
                        allowResubmitWithBlankCommentsForGen4=0;
                    }
                    
                }
                else if ([policyKeyUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
                {

                    NSArray *collectionArray=[[responseDict objectForKey:@"policyValue"] objectForKey:@"collection"];

                    NSString *tmpPolicyKey=nil;
                    for (int b=0; b<[collectionArray count]; b++) {

                        NSString *tmpPolicyValue=nil;
                        if ([[[collectionArray objectAtIndex:b] objectForKey:@"uri"] isEqualToString:DAILY_WIDGET_OEF_POLICY_URI])
                        {
                            tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];

                        }
                        else
                        {
                            if (b%2==0)
                            {
                                tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                            }
                            else
                            {
                                tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                            }
                        }


                        if ([tmpPolicyKey isEqualToString:DAILY_WIDGET_OEF_POLICY_URI])
                        {

                            NSArray *tmpcollectionArray=[[collectionArray objectAtIndex:b] objectForKey:@"collection"];
                            NSMutableDictionary *widgetTimesheetDetailsDict=responseDictionaryObject[@"widgetTimesheetDetails"];
                            NSArray *dayLevelObjectExtensionFieldDetailsArr=widgetTimesheetDetailsDict[@"dayLevelObjectExtensionFieldDetails"];
                            for (NSDictionary *tmpcollectionDict in tmpcollectionArray)
                            {
                                NSString *oefUri= tmpcollectionDict[@"uri"];
                                if (dayLevelObjectExtensionFieldDetailsArr!=nil && ![dayLevelObjectExtensionFieldDetailsArr isKindOfClass:[NSNull class]])
                                {
                                    for (NSDictionary *dayLevelObjectExtensionFieldDetailsDict in dayLevelObjectExtensionFieldDetailsArr)
                                    {
                                        NSString *dayLevelObjectExtensionFieldUri=dayLevelObjectExtensionFieldDetailsDict[@"uri"];
                                        if ([oefUri isEqualToString:dayLevelObjectExtensionFieldUri])
                                        {
                                            NSDictionary *dayLevelObjectExtensionFieldDict=nil;
                                            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                            {
                                                dayLevelObjectExtensionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":dayLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":dayLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":DAILY_WIDGET_DAYLEVEL_OEF,@"timesheetUri":timesheetUri,@"timesheetFormat":GEN4_DAILY_WIDGET_TIMESHEET};
                                            }
                                            else
                                            {
                                                dayLevelObjectExtensionFieldDict=@{@"uri":oefUri,@"definitionTypeUri":dayLevelObjectExtensionFieldDetailsDict[@"definitionTypeUri"],@"displayText":dayLevelObjectExtensionFieldDetailsDict[@"displayText"],@"oef_level":DAILY_WIDGET_DAYLEVEL_OEF,@"timesheetFormat":GEN4_DAILY_WIDGET_TIMESHEET};
                                            }
                                        
                                            
                                            [self saveObjectExtensionDetailsDataToDB:dayLevelObjectExtensionFieldDict andTimeSheetUri:timesheetUri andTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET];
                                            break;
                                        }
                                    }

                                }
                                
                            }
                            
                            
                        }
                        
                    }
                }
                
                
            }
        }
        
        //Overriding values according to the super permissions
        if (superPermissionForBreaks==0)
        {
            allowBreakForInOutGen4=0;
            
        }
        if (superPermissionForTimesheetEdit==0)
        {
            allowTimeEntryEditForInOutGen4=0;
            allowTimeEntryEditForStandardGen4=0;
            allowTimeEntryEditForStandardGen4=0;
        }
        
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSMutableDictionary *timesheetPermittedApprovalActions=[NSMutableDictionary dictionaryWithDictionary:[responseDictionaryObject objectForKey:@"permittedApprovalActions"]];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForInOutGen4] forKey:@"allowBreakForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForStandardGen4] forKey:@"allowBreakForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryCommentsForInOutGen4] forKey:@"allowTimeEntryCommentsForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowCommentsForStandardGen4] forKey:@"allowCommentsForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryEditForInOutGen4] forKey:@"allowTimeEntryEditForInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryEditForStandardGen4] forKey:@"allowTimeEntryEditForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowReopenForGen4] forKey:@"allowReopenForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:alowReopenAfterApprovalForGen4] forKey:@"alowReopenAfterApprovalForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowResubmitWithBlankCommentsForGen4] forKey:@"allowResubmitWithBlankCommentsForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeoffForGen4] forKey:@"allowTimeoffForGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForPunchInGen4] forKey:@"allowBreakForPunchInGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowClientsForStandardGen4] forKey:@"allowClientsForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProgramsForStandardGen4] forKey:@"allowProgramsForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProjectsTasksForStandardGen4] forKey:@"allowProjectsTasksForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowActivitiesForStandardGen4] forKey:@"allowActivitiesForStandardGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBillingForStandardGen4] forKey:@"allowBillingForStandardGen4"];

        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBreakForExtInOutGen4] forKey:@"allowBreakForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryCommentsForExtInOutGen4] forKey:@"allowTimeEntryCommentsForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowClientsForExtInOutGen4] forKey:@"allowClientsForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProgramsForExtInOutGen4] forKey:@"allowProgramsForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProjectsTasksForExtInOutGen4] forKey:@"allowProjectsTasksForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowActivitiesForExtInOutGen4] forKey:@"allowActivitiesForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowBillingForExtInOutGen4] forKey:@"allowBillingForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowTimeEntryEditForExtInOutGen4] forKey:@"allowTimeEntryEditForExtInOutGen4"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:canOwnerViewPayrollSummary] forKey:@"canOwnerViewPayrollSummary"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:canOwnerViewPayDetails] forKey:@"canOwnerViewPayDetails"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowSplitMidNightCrossTime] forKey:@"allowSplitTimeMidnightCrossEntry"];
        
        if (![timesheetUri isKindOfClass:[NSNull class]] && timesheetUri!=nil )
        {
            [timesheetPermittedApprovalActions setObject:timesheetUri forKey:@"uri"];
        }
//
//
        [supportModel saveTimesheetPermittedApprovalActionsDataToDB:timesheetPermittedApprovalActions];
        [self updatecanEditTimesheetStatusForTimesheetWithUri:timesheetUri withStatus:superPermissionForTimesheetEdit andIsPending:NO];
        [self updateTimesheetFormatForTimesheetWithUri:timesheetUri andIsPending:NO];
        
        
        NSString *timesheetApprovalStatusUri=[[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"];
        NSString *timesheetApprovalStatus=nil;
        if (timesheetApprovalStatusUri!=nil && ![timesheetApprovalStatusUri isKindOfClass:[NSNull class]])
        {
            if ([timesheetApprovalStatusUri isEqualToString:APPROVED_STATUS_URI])
            {
                timesheetApprovalStatus=APPROVED_STATUS;
            }
            else if ([timesheetApprovalStatusUri isEqualToString:NOT_SUBMITTED_STATUS_URI])
            {
                timesheetApprovalStatus=NOT_SUBMITTED_STATUS ;
            }
            else if ([timesheetApprovalStatusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
            {
                timesheetApprovalStatus=WAITING_FOR_APRROVAL_STATUS;
            }
            else if ([timesheetApprovalStatusUri isEqualToString:REJECTED_STATUS_URI])
            {
                timesheetApprovalStatus=REJECTED_STATUS;
            }
            
            if(timesheetApprovalStatus)
            {
                
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                
                [dataDict setObject:timesheetApprovalStatus forKey:@"approvalStatus" ];
                
                [myDB updateTable:approvalPreviousTimesheetsTable data:dataDict where:[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri] intoDatabase:@""];
            }
            
            
        }
        
    }
    else
    {
        NSMutableDictionary *timesheetDetailsDict=[responseDictionaryObject objectForKey:@"inOutTimesheetDetails"];
        NSMutableDictionary *standardTimesheetDetailsDict=[responseDictionaryObject objectForKey:@"standardTimesheetDetails"];

        int isNoticeExplicitlyAccepted=0;
        BOOL isTimesheetCommentsRequired=NO;
        //US9453 to address DE17320 Ullas M L
        NSMutableDictionary *capablitiesDict=[responseDictionaryObject objectForKey:@"capabilities"];
        NSMutableArray *enableOnlySheetUdfUriArr=[capablitiesDict objectForKey:@"enabledCustomFieldUris"];
        NSMutableArray *enableOnlyRowOrCellUdfUriArr=[capablitiesDict objectForKey:@"enabledEntryCustomFieldUris"];
        [self updateCustomFieldTableFor:TIMESHEET_SHEET_UDF enableUdfuriArray:enableOnlySheetUdfUriArr];
        [self updateCustomFieldTableFor:TIMESHEET_CELL_UDF enableUdfuriArray:enableOnlyRowOrCellUdfUriArr];
        [self updateCustomFieldTableFor:TIMESHEET_ROW_UDF enableUdfuriArray:enableOnlyRowOrCellUdfUriArr];
        NSMutableDictionary *disclaimerDict=[NSMutableDictionary dictionary];
        NSMutableArray *changeReasonArray = [NSMutableArray array];
        changeReasonArray = [responseDictionaryObject objectForKey:@"changeReasonEntries"];
        if (![timesheetDetailsDict isKindOfClass:[NSNull class]] && timesheetDetailsDict!=nil) {
            disclaimerDict=[timesheetDetailsDict objectForKey:@"timesheetNotice"];
            timesheetUri=[timesheetDetailsDict objectForKey:@"uri"];
            if ([[timesheetDetailsDict objectForKey:@"noticeExplicitlyAccepted"] boolValue] == YES )
            {
                isNoticeExplicitlyAccepted = 1;
            }
            if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"timesheetCommentsRequired"] boolValue]==YES)
            {
                isTimesheetCommentsRequired=YES;
            }
            
            
        }
        else if (![standardTimesheetDetailsDict isKindOfClass:[NSNull class]] && standardTimesheetDetailsDict!=nil)
        {
            disclaimerDict=[standardTimesheetDetailsDict objectForKey:@"timesheetNotice"];
            timesheetUri=[standardTimesheetDetailsDict objectForKey:@"uri"];
            if ([[standardTimesheetDetailsDict objectForKey:@"noticeExplicitlyAccepted"] boolValue] == YES )
            {
                isNoticeExplicitlyAccepted = 1;
            }
            if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"timesheetCommentsRequired"] boolValue]==YES)
            {
                isTimesheetCommentsRequired=YES;
            }
            
        }
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        //US9453 to address DE17320 Ullas M L
        [self saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPrevious:enableOnlySheetUdfUriArr andArray:enableOnlyRowOrCellUdfUriArr forTimesheetUri:timesheetUri];
        
        int hasBillingAccess            =0;
        int hasProjectAccess            =0;
        int hasClientAccess             =0;
        int hasActivityAccess           =0;
        int hasBreakAccess              =0;
        int hasProgramAccess            =0;//MOBI-746
        
        NSDictionary *timesheetCurrentCapabilities=[responseDictionaryObject objectForKey:@"capabilities"];
        if ([[timesheetCurrentCapabilities objectForKey:@"hasBillingAccess"] boolValue] == YES )
        {
            hasBillingAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES )
        {
            hasProjectAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasClientAccess"] boolValue] == YES )
        {
            hasClientAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES )
        {
            hasActivityAccess = 1;
        }
        if ([[timesheetCurrentCapabilities objectForKey:@"hasProgramAccess"] boolValue] == YES )
        {
            hasProgramAccess = 1;
        }
        NSString *hasTimesheetNoticePolicyUri =[timesheetCurrentCapabilities objectForKey:@"timesheetNoticePolicyUri"];
        
        NSMutableDictionary *capabilityDictionary=[NSMutableDictionary dictionary];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasBillingAccess] forKey:@"hasTimesheetBillingAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasProjectAccess] forKey:@"hasTimesheetProjectAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasClientAccess] forKey:@"hasTimesheetClientAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasActivityAccess] forKey:@"hasTimesheetActivityAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasBreakAccess] forKey:@"hasTimesheetBreakAccess"];
        [capabilityDictionary setObject:[NSNumber numberWithInt:hasProgramAccess] forKey:@"hasTimesheetProgramAccess"];
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [capabilityDictionary setObject:timesheetUri forKey:@"timesheetUri"];
        }
        if (hasTimesheetNoticePolicyUri!=nil && ![hasTimesheetNoticePolicyUri isKindOfClass:[NSNull class]])
        {
            [capabilityDictionary setObject:hasTimesheetNoticePolicyUri  forKey:@"disclaimerTimesheetNoticePolicyUri"];
        }
        [myDB deleteFromTable:approvalPreviousTimesheetCapabilitiesTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        [myDB insertIntoTable:approvalPreviousTimesheetCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
        
        
        NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
        NSString *approvalStatus=[[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"approvalStatus"] objectForKey:@"uri"];
        
        
        
        
        if ([approvalStatus isEqualToString:APPROVED_STATUS_URI])
        {
            [updateDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
        }
        else if ([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS_URI])
        {
            [updateDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
        }
        else if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
        {
            [updateDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
        }
        else if ([approvalStatus isEqualToString:REJECTED_STATUS_URI])
        {
            [updateDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
        }
        else
        {
            [updateDict setObject:[NSNull null] forKey:@"approvalStatus"];
        }
        
        
        
        
        if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"canEditTimesheet"] boolValue] == NO )
        {
            [updateDict setObject:[NSNumber numberWithInt:0] forKey:@"canEditTimesheet"];
        }
        else
        {
            [updateDict setObject:[NSNumber numberWithInt:1] forKey:@"canEditTimesheet"];
        }
        
        [myDB updateTable:approvalPreviousTimesheetsTable data:updateDict where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] intoDatabase:@""];
        
        [myDB deleteFromTable:approvalPreviousTimesheetCustomFieldsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        
        
        
        NSMutableDictionary *timesheetSummaryDict=[responseDictionaryObject objectForKey:@"timesheetSummary"];
        NSMutableArray *timesheetActivitiesSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByActivity"];
        NSMutableArray *timesheetProjectsSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByProject"];
        NSMutableArray *timesheetBillingSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByBillingRate"];
        NSMutableArray *timesheetPayrollSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByPaycode"];
        NSMutableArray *timesheetDateSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByDate"];
        NSMutableArray *timesheetApproverSummaryArray=nil;
        if ([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            timesheetApproverSummaryArray=[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"history"];
        }
        
        NSDictionary *timesheetNonBillabeSummaryDict=[timesheetSummaryDict objectForKey:@"nonBillableTimeDuration"];
        //US9278 Ullas M L
        NSDictionary *timesheetTotalHoursDict=[timesheetSummaryDict objectForKey:@"totalTimeDuration"];
        //NSDictionary *breakHoursDict=[timesheetSummaryDict objectForKey:@"breakDuration"];
        NSNumber *totalHours=[Util convertApiTimeDictToDecimal:timesheetTotalHoursDict];
       // NSNumber *breakHours=[Util convertApiTimeDictToDecimal:breakHoursDict];
        NSString *hoursIncludingBreak=[NSString stringWithFormat:@"%f",[totalHours newFloatValue]];
        NSString *hoursValue=@"";
        NSString *minsValue=@"";
        NSArray *componentsArr=[hoursIncludingBreak componentsSeparatedByString:@"."];
        if ([componentsArr count]==2)
        {
            hoursValue = [componentsArr objectAtIndex:0];
            minsValue =[componentsArr objectAtIndex:1];
        }
        NSString *hoursIncludingBreakStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];
        NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
        [timesheetDataDict setObject:hoursIncludingBreak      forKey:@"totalDurationDecimal"];
        [timesheetDataDict setObject:hoursIncludingBreakStr   forKey:@"totalDurationHour"];
        NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
        
        [myDB updateTable: approvalPreviousTimesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
        
        if (![timesheetActivitiesSummaryArray isKindOfClass:[NSNull class]] && timesheetActivitiesSummaryArray!=nil )
        {
            [self saveApprovalTimesheetActivitiesSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetActivitiesSummaryArray moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        if (![timesheetProjectsSummaryArray isKindOfClass:[NSNull class]] && timesheetProjectsSummaryArray!=nil )
        {
            [self saveApprovalTimesheetProjectSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetProjectsSummaryArray moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        if (![timesheetBillingSummaryArray isKindOfClass:[NSNull class]] && timesheetBillingSummaryArray!=nil )
        {
            [self saveApprovalTimesheetBillingSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetBillingSummaryArray withNonBillableDict:timesheetNonBillabeSummaryDict moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        if (![timesheetPayrollSummaryArray isKindOfClass:[NSNull class]] && timesheetPayrollSummaryArray!=nil )
        {
            [self saveApprovalTimesheetPayrollSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetPayrollSummaryArray moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        if (![timesheetDateSummaryArray isKindOfClass:[NSNull class]] && timesheetDateSummaryArray!=nil )
        {
            [self saveApprovalTimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetDateSummaryArray withNoticeAcceptedFlag:isNoticeExplicitlyAccepted moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE isTimesheetCommentsRequired:isTimesheetCommentsRequired];
        }
        if (![timesheetApproverSummaryArray isKindOfClass:[NSNull class]] && timesheetApproverSummaryArray!=nil )
        {
            [self saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetApproverSummaryArray moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        if (![disclaimerDict isKindOfClass:[NSNull class]] && disclaimerDict!=nil )
        {
            [self saveApprovalTimesheetDisclaimerDataToDB:disclaimerDict moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        
        if (![timesheetDetailsDict isKindOfClass:[NSNull class]] && timesheetDetailsDict!=nil )
        {
            NSArray *sheetCustomFieldsArray=[timesheetDetailsDict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_SHEET_UDF andEntryURI:nil andtimeEntryDate:nil moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            
            [self saveTimeAlloctionsAndPunchesDataToDBForTimesheetUri:timesheetUri dataDict:responseDictionaryObject moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        
        if (![standardTimesheetDetailsDict isKindOfClass:[NSNull class]] && standardTimesheetDetailsDict!=nil )
        {
            
            NSArray *sheetCustomFieldsArray=[standardTimesheetDetailsDict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_SHEET_UDF andEntryURI:nil andtimeEntryDate:nil moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];

            NSArray *projectTaskDetailsArray = nil;
            NSArray *taskDetailsArray = nil;
            if ([responseDictionaryObject objectForKey:@"projectTaskDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"projectTaskDetails"] isKindOfClass:[NSNull class]])
            {
                projectTaskDetailsArray=[[responseDictionaryObject objectForKey:@"projectTaskDetails"] objectForKey:@"projects"];
                taskDetailsArray=[[responseDictionaryObject objectForKey:@"projectTaskDetails"] objectForKey:@"tasks"];
            }

            
            [self saveStandardTimeEntriesDataToDBForTimesheetUri:timesheetUri dataDict:standardTimesheetDetailsDict projectTaskDetails:projectTaskDetailsArray taskDetails:taskDetailsArray moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            
            
        }
        
        if (![changeReasonArray isKindOfClass:[NSNull class]] && changeReasonArray!=nil && [changeReasonArray count]>0)
        {
            [self saveApprovalTimesheetChangeReasonEntriesDataToDBForTimesheetUri:timesheetUri dataArray:changeReasonArray moduleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
        }
        
        
     
        
    }
}

-(void)saveApprovalTimesheetChangeReasonEntriesDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array moduleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
        [myDB deleteFromTable:approveTimesheetReasonForChangeTable where:whereStr inDatabase:@""];
        for (int i=0; i<[array count]; i++)
        {
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSDictionary *dict=[array objectAtIndex:i];
            NSString *reasonString = [dict objectForKey:@"changeReason"];
            NSMutableArray *modificationDataArray = [NSMutableArray array];
            modificationDataArray = [dict objectForKey:@"modifications"];
            NSString *IDString = [Util getRandomGUID];
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];
            IDString = [[IDString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];

            for (int j= 0; j<[modificationDataArray count]; j++) {
                NSMutableArray *modificationSetsArray = [NSMutableArray array];
                modificationSetsArray = [[modificationDataArray objectAtIndex:j] objectForKey:@"modificationSets"];
                NSString *dateString = [[modificationDataArray objectAtIndex:j] objectForKey:@"header"];
                
                
                
                
                for (int k= 0; k<[modificationSetsArray count]; k++) {
                    NSMutableArray *modifications = [NSMutableArray array];
                    modifications = [[modificationSetsArray objectAtIndex:k] objectForKey:@"modifications"];
                    NSString *entryHeader = [[modificationSetsArray objectAtIndex:k] objectForKey:@"header"];
                    for (int index = 0; index<[modifications count]; index++) {
                        NSString *changeString = [modifications objectAtIndex:index];
                        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                        [dataDict setObject:reasonString                    forKey:@"reasonForChange"];
                        [dataDict setObject:changeString                    forKey:@"change"];
                        [dataDict setObject:IDString                        forKey:@"uniqueID"];
                        [dataDict setObject:dateString                      forKey:@"header"];
                        [dataDict setObject:entryHeader                      forKey:@"entryHeader"];
                        [myDB insertIntoTable:approveTimesheetReasonForChangeTable data:dataDict intoDatabase:@""];
                    }
                    if (![modifications isKindOfClass:[NSNull class]] && modifications!= nil && [modifications count] == 0) {
                        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                        [dataDict setObject:reasonString                    forKey:@"reasonForChange"];
                        [dataDict setObject:IDString                        forKey:@"uniqueID"];
                        [dataDict setObject:dateString                      forKey:@"header"];
                        [dataDict setObject:entryHeader                     forKey:@"entryHeader"];
                        [myDB insertIntoTable:approveTimesheetReasonForChangeTable data:dataDict intoDatabase:@""];
                    }
                }
                
                
            }
        }
}

-(void)saveApprovalTimesheetActivitiesSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array moduleName:(NSString *)moduleName
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimesheetsActivitiesSummaryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetsActivitiesSummaryTable where:whereStr inDatabase:@""];
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *durationoursDict=[dict objectForKey:@"totalTimeDuration"];
        NSNumber *durationHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:durationoursDict];
        NSString *durationHoursInHourFormat=[Util convertApiTimeDictToString:durationoursDict];
        
        NSString *activityName=RPLocalizedString(NO_ACTIVITY, NO_ACTIVITY);
        NSString *activityUri=nil;
        if ([dict objectForKey:@"activity"]!=nil && ![[dict objectForKey:@"activity"] isKindOfClass:[NSNull class]])
        {
            activityName=[[dict objectForKey:@"activity"] objectForKey:@"displayText"];
            activityUri=[[dict objectForKey:@"activity"] objectForKey:@"uri"];
        }
        
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        }
        if (activityUri!=nil)
        {
            [dataDict setObject:activityUri                      forKey:@"activityUri"];
        }
        
        [dataDict setObject:activityName                     forKey:@"activityName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"activityDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"activityDurationHour"];
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            NSArray *expArr = [self getPendingTimesheetinfoForActivityIdentity:activityUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"activityUri='%@'",activityUri];
                [myDB updateTable: approvalPendingTimesheetsActivitiesSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingTimesheetsActivitiesSummaryTable data:dataDict intoDatabase:@""];
            }

        }
        else
        {
            NSArray *expArr = [self getPreviousTimesheetinfoForActivityIdentity:activityUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"activityUri='%@'",activityUri];
                [myDB updateTable: approvalPreviousTimesheetsActivitiesSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousTimesheetsActivitiesSummaryTable data:dataDict intoDatabase:@""];
            }

            
        }
                
        
    }
    
}

-(void)saveApprovalTimesheetProjectSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array moduleName:(NSString *)moduleName
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimesheetsProjectsSummaryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetsProjectsSummaryTable where:whereStr inDatabase:@""];
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *durationoursDict=[dict objectForKey:@"totalTimeDuration"];
        NSNumber *durationHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:durationoursDict];
        NSString *durationHoursInHourFormat=[Util convertApiTimeDictToString:durationoursDict];
        
        NSString *projectName=RPLocalizedString(NO_PROJECT, NO_PROJECT);
        NSString *projectUri=nil;
        if ([dict objectForKey:@"project"]!=nil && ![[dict objectForKey:@"project"] isKindOfClass:[NSNull class]])
        {
            projectName=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
            projectUri=[[dict objectForKey:@"project"] objectForKey:@"uri"];
        }
        
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        }
        if (projectUri!=nil)
        {
            [dataDict setObject:projectUri                      forKey:@"projectUri"];
        }
        
        
        [dataDict setObject:projectName                     forKey:@"projectName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"projectDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"projectDurationHour"];
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            NSArray *expArr = [self getPendingTimesheetinfoForProjectIdentity:projectUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"projectUri='%@'",projectUri];
                [myDB updateTable: approvalPendingTimesheetsProjectsSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingTimesheetsProjectsSummaryTable data:dataDict intoDatabase:@""];
            }
        }
        else
        {
            NSArray *expArr = [self getPreviousTimesheetinfoForProjectIdentity:projectUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"projectUri='%@'",projectUri];
                [myDB updateTable: approvalPreviousTimesheetsProjectsSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousTimesheetsProjectsSummaryTable data:dataDict intoDatabase:@""];
            }
        }
        
        
        
    }
    
}


-(void)saveApprovalTimesheetBillingSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array withNonBillableDict:(NSDictionary *)nonBillableDict moduleName:(NSString *)moduleName
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimesheetsBillingSummaryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetsBillingSummaryTable where:whereStr inDatabase:@""];
    }
    
    //    NSNumber *durationNonBillableHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:nonBillableDict];
    //    NSString *durationNonBillableHoursInHourFormat=[Util convertApiTimeDictToString:nonBillableDict];
    //    if ([durationNonBillableHoursInDecimalFormat intValue]!=0)
    //    {
    //        [dataDict setObject:timesheetUri                                forKey:@"timesheetUri"];
    //        [dataDict setObject:@""                                         forKey:@"billingUri"];
    //        [dataDict setObject:Non_Billable_string                         forKey:@"billingName"];
    //        [dataDict setObject:durationNonBillableHoursInDecimalFormat     forKey:@"billingDurationDecimal"];
    //        [dataDict setObject:durationNonBillableHoursInHourFormat        forKey:@"billingDurationHour"];
    //        [myDB insertIntoTable:approvalPendingTimesheetsBillingSummaryTable data:dataDict intoDatabase:@""];
    //    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *durationoursDict=[dict objectForKey:@"totalTimeDuration"];
        NSNumber *durationHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:durationoursDict];
        NSString *durationHoursInHourFormat=[Util convertApiTimeDictToString:durationoursDict];
        
        NSString *billingName=RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE);
        NSString *billingUri=nil;
        if ([dict objectForKey:@"billingRate"]!=nil && ![[dict objectForKey:@"billingRate"] isKindOfClass:[NSNull class]])
        {
            billingName=[[dict objectForKey:@"billingRate"] objectForKey:@"displayText"];
            billingUri=[[dict objectForKey:@"billingRate"] objectForKey:@"uri"];
        }
        
        
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        }
        if (billingUri!=nil)
        {
            [dataDict setObject:billingUri                      forKey:@"billingUri"];
        }
        
        [dataDict setObject:billingName                     forKey:@"billingName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"billingDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"billingDurationHour"];
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            NSArray *expArr = [self getPendingTimesheetinfoForBillingIdentity:billingUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"billingUri='%@'",billingUri];
                [myDB updateTable: approvalPendingTimesheetsBillingSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingTimesheetsBillingSummaryTable data:dataDict intoDatabase:@""];
            }
        }
        else
        {
            NSArray *expArr = [self getPreviousTimesheetinfoForBillingIdentity:billingUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"billingUri='%@'",billingUri];
                [myDB updateTable: approvalPreviousTimesheetsBillingSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousTimesheetsBillingSummaryTable data:dataDict intoDatabase:@""];
            }
        }
        
        
        
        
    }
    
    
    
}

-(void)saveApprovalTimesheetPayrollSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array moduleName:(NSString *)moduleName
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimesheetsPayrollSummaryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetsPayrollSummaryTable where:whereStr inDatabase:@""];
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *durationoursDict=[dict objectForKey:@"totalTimeDuration"];
        NSNumber *durationHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:durationoursDict];
        NSString *durationHoursInHourFormat=[Util convertApiTimeDictToString:durationoursDict];
        
        
        NSString *payrollName=RPLocalizedString(NO_PAYCODE, NO_PAYCODE);
        NSString *payrollUri=nil;
        if ([dict objectForKey:@"payCode"]!=nil && ![[dict objectForKey:@"payCode"] isKindOfClass:[NSNull class]])
        {
            payrollName=[[dict objectForKey:@"payCode"] objectForKey:@"displayText"];
            payrollUri=[[dict objectForKey:@"payCode"] objectForKey:@"uri"];
        }
        
        
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        }
        if (payrollUri!=nil)
        {
            [dataDict setObject:payrollUri                      forKey:@"payrollUri"];
        }
        
        
        [dataDict setObject:payrollName                     forKey:@"payrollName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"payrollDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"payrollDurationHour"];
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            NSArray *expArr = [self getPendingTimesheetinfoForPayrollIdentity:payrollUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"payrollUri='%@'",payrollUri];
                [myDB updateTable: approvalPendingTimesheetsPayrollSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingTimesheetsPayrollSummaryTable data:dataDict intoDatabase:@""];
            }

        }
        else
        {
            NSArray *expArr = [self getPreviousTimesheetinfoForPayrollIdentity:payrollUri timesheetIdentity:timesheetUri];
            if ([expArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"payrollUri='%@'",payrollUri];
                [myDB updateTable: approvalPreviousTimesheetsPayrollSummaryTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousTimesheetsPayrollSummaryTable data:dataDict intoDatabase:@""];
            }

            
        }
                
        
    }
    
    
}

-(void)saveApprovalTimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array withNoticeAcceptedFlag:(int)noticeFlag moduleName:(NSString *)moduleName isTimesheetCommentsRequired:(BOOL)isTimesheetCommentsRequired
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimesheetsDaySummaryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetsDaySummaryTable where:whereStr inDatabase:@""];
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        int hasComments       =0;
        int isHolidayDayOff   =0;
        int isWeeklyDayOff    =0;
        int isCommentsRequired=0;
        
        if ([[dict objectForKey:@"hasComments"] boolValue] == YES )
        {
            hasComments = 1;
        }
        if ([[dict objectForKey:@"isHolidayDayOff"] boolValue] == YES )
        {
            isHolidayDayOff = 1;
        }
        if ([[dict objectForKey:@"isWeeklyDayOff"] boolValue] == YES )
        {
            isWeeklyDayOff = 1;
        }
        if (isTimesheetCommentsRequired)
        {
            isCommentsRequired=1;
        }
        
        
        
        
        NSDictionary *timeOffDurationDict=[dict objectForKey:@"timeOffDuration"];
        NSNumber *timeOffHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:timeOffDurationDict];
        NSString *timeOffHoursInHourFormat=[Util convertApiTimeDictToString:timeOffDurationDict];
        
        NSDictionary *totalTimeDurationDict=[dict objectForKey:@"totalTimeDuration"];
        NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
//        NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
        
        NSDictionary *workingTimeDurationDict=[dict objectForKey:@"workingTimeDuration"];
        NSNumber *workingTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:workingTimeDurationDict];
        NSString *workingTimeHoursInHourFormat=[Util convertApiTimeDictToString:workingTimeDurationDict];
        
//TODO:Commenting below line because variable is unused,uncomment when using
//        NSDictionary *breakHoursDict=[dict objectForKey:@"breakDuration"];
//        NSNumber *breakHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:breakHoursDict];
        
//        NSString *breakHoursInHourFormat=[Util convertApiTimeDictToString:breakHoursDict];
        
        
        NSString *hoursIncludingBreak=[NSString stringWithFormat:@"%f",[totalTimeHoursInDecimalFormat newFloatValue]];
        NSString *hoursValue=@"";
        NSString *minsValue=@"";
        NSArray *componentsArr=[hoursIncludingBreak componentsSeparatedByString:@"."];
        if ([componentsArr count]==2)
        {
            hoursValue = [componentsArr objectAtIndex:0];
            minsValue =[componentsArr objectAtIndex:1];
        }
        NSString *hoursIncludingBreakStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];
        
        
        NSDate *entryDate=[Util convertApiDateDictToDateFormat:[dict objectForKey:@"date"]];
        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
        }
        [dataDict setObject:@""                                      forKey:@"timesheetEntryUri"];
        [dataDict setObject:entryDateToStore                         forKey:@"timesheetEntryDate"];
        //[dataDict setObject:totalTimeHoursInDecimalFormat            forKey:@"timesheetEntryTotalDurationDecimal"];
        //[dataDict setObject:totalTimeHoursInHourFormat               forKey:@"timesheetEntryTotalDurationHour"];
        [dataDict setObject:hoursIncludingBreak                      forKey:@"timesheetEntryTotalDurationDecimal"];
        [dataDict setObject:hoursIncludingBreakStr                   forKey:@"timesheetEntryTotalDurationHour"];
        [dataDict setObject:[NSNumber numberWithInt:hasComments]     forKey:@"hasComments"];
        [dataDict setObject:[NSNumber numberWithInt:isHolidayDayOff] forKey:@"isHolidayDayOff"];
        [dataDict setObject:[NSNumber numberWithInt:isWeeklyDayOff]  forKey:@"isWeeklyDayOff"];
        [dataDict setObject:timeOffHoursInDecimalFormat              forKey:@"timeOffDurationDecimal"];
        [dataDict setObject:timeOffHoursInHourFormat                 forKey:@"timeOffDurationHour"];
        [dataDict setObject:workingTimeHoursInDecimalFormat          forKey:@"workingTimeDurationDecimal"];
        [dataDict setObject:workingTimeHoursInHourFormat             forKey:@"workingTimeDurationHour"];
        [dataDict setObject:[NSNumber numberWithInt:noticeFlag]      forKey:@"noticeExplicitlyAccepted"];
        [dataDict setObject:[NSNumber numberWithInt:isCommentsRequired]     forKey:@"isCommentsRequired"];
        
        /*NSArray *expArr = [self getTimesheetinfoForEntryDate:entryDateToStore];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetEntryDate='%@'",entryDate];
            [myDB updateTable: approvalPendingTimesheetsDaySummaryTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPendingTimesheetsDaySummaryTable data:dataDict intoDatabase:@""];
        }*/
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            [myDB insertIntoTable:approvalPendingTimesheetsDaySummaryTable data:dataDict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousTimesheetsDaySummaryTable data:dataDict intoDatabase:@""];
        }
        
        
        
        
    }
    
    
}
-(void)saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array moduleName:(NSString *)moduleName
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimesheetApproverHistoryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetApproverHistoryTable where:whereStr inDatabase:@""];
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        
        NSDictionary *dict=[array objectAtIndex:i];
        
        
        
        NSString *actionStatus=nil;
        NSString *actionURI=nil;
        //Implementation for MOBI-261//JUHI
        NSString *actingForUser=nil;
        NSString *actingUser=nil;
        NSString *comments=nil;
        
        if ([dict objectForKey:@"action"]!=nil && ![[dict objectForKey:@"action"] isKindOfClass:[NSNull class]])
        {
            actionStatus=[[dict objectForKey:@"action"] objectForKey:@"displayText"];
            actionURI=[[dict objectForKey:@"action"] objectForKey:@"uri"];
            
        }
        if ([dict objectForKey:@"timestamp"]!=nil && ![[dict objectForKey:@"timestamp"] isKindOfClass:[NSNull class]])
        {
            NSDate *entryDate=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timestamp"]];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [dataDict setObject:entryDateToStore forKey:@"actionDate"];
        }
        
        
       //Implementation for MOBI-261//JUHI
        if ([dict objectForKey:@"authority"]!=nil && ![[dict objectForKey:@"authority"] isKindOfClass:[NSNull class]])
        {
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingForUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingForUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"];
                }
                
            }
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"];
                }
                
            }
        }
        if ([dict objectForKey:@"comments"]!=nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
        {
            comments=[dict objectForKey:@"comments"];
        }
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        }
        if (actionStatus!=nil)
        {
            [dataDict setObject:actionStatus                      forKey:@"actionStatus"];
        }
        if (actionURI!=nil)
        {
            [dataDict setObject:actionURI                      forKey:@"actionUri"];
        }
        
        //Implementation for MOBI-261//JUHI
        if (actingForUser!=nil)
        {
            [dataDict setObject:actingForUser                      forKey:@"actingForUser"];
        }
        if (comments!=nil)
        {
            [dataDict setObject:comments                      forKey:@"comments"];
        }
        if (actingUser!=nil)
        {
            [dataDict setObject:actingUser                      forKey:@"actingUser"];
        }
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            [myDB insertIntoTable:approvalPendingTimesheetApproverHistoryTable data:dataDict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousTimesheetApproverHistoryTable data:dataDict intoDatabase:@""];
        }
        
        
        
    }
    
    
}

-(void)saveTimeAlloctionsAndPunchesDataToDBForTimesheetUri:(NSString*)timesheetUri dataDict:(NSMutableDictionary *)responseDict moduleName:(NSString *)moduleName
{
    NSMutableDictionary *timesheetDetailsDict=[responseDict objectForKey:@"inOutTimesheetDetails"];
//    NSMutableDictionary *timesheetCapabilities=[responseDict objectForKey:@"capabilities"];
    NSArray *projectTaskDetailsArr = nil;
    NSArray *taskDetailsArr = nil;
    if ([responseDict objectForKey:@"projectTaskDetails"]!=nil && ![[responseDict objectForKey:@"projectTaskDetails"] isKindOfClass:[NSNull class]])
    {
        projectTaskDetailsArr=[[responseDict objectForKey:@"projectTaskDetails"] objectForKey:@"projects"];
        taskDetailsArr=[[responseDict objectForKey:@"projectTaskDetails"] objectForKey:@"tasks"];
    }

    NSMutableArray *timeAllocationArray=[timesheetDetailsDict objectForKey:@"timeOff"];
    NSMutableArray *timePunchesArray=[timesheetDetailsDict objectForKey:@"entries"];
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimeEntriesTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimeEntriesTable where:whereStr inDatabase:@""];
    }
    //Implemetation for ExtendedInOut
    BOOL isExtendedInOutUserPermission=NO;
//    BOOL isLockedInOutUserPermission=NO;
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        
        BOOL isProjectAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
        BOOL isActivityAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
        NSMutableArray *arrayDict=[self getPendingApprovalDataForTimesheetSheetURI:timesheetUri];
        NSString *approvalStatus=nil;
        if ([arrayDict count]>0)
        {
            approvalStatus=[[arrayDict objectAtIndex:0] objectForKey:@"approvalStatus"];
        }

        
        if (isProjectAccess || isActivityAccess)
        {
            isExtendedInOutUserPermission=YES;
            
        }
        else if (approvalStatus!=nil &&([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[approvalStatus isEqualToString:REJECTED_STATUS]))
        {
//            if ([[timesheetCapabilities objectForKey:@"canEditTimesheet"] boolValue] == NO )
//            {
//                isLockedInOutUserPermission=YES;
//            }
            
        }
        
    }
    else
    {
        
        BOOL isProjectAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
        BOOL isActivityAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
        NSMutableArray *arrayDict=[self getPreviousApprovalDataForTimesheetSheetURI:timesheetUri];
        NSString *approvalStatus=nil;
        if ([arrayDict count]>0)
        {
           approvalStatus=[[arrayDict objectAtIndex:0] objectForKey:@"approvalStatus"];
        }
        if (isProjectAccess || isActivityAccess)
        {
            isExtendedInOutUserPermission=YES;

        }
        else if (approvalStatus!=nil &&([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[approvalStatus isEqualToString:REJECTED_STATUS]))
        {
//            if ([[timesheetCapabilities objectForKey:@"canEditTimesheet"] boolValue] == NO )
//            {
//               isLockedInOutUserPermission=YES; 
//            }
            
        }

        
    }
    NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        NSMutableArray *arrayDict=[self getPendingApprovalDataForTimesheetSheetURI:timesheetUri];
        NSMutableDictionary *updateDataDict=nil;
        if ([arrayDict count]>0)
        {
            updateDataDict=[arrayDict objectAtIndex:0];
            [updateDataDict removeObjectForKey:@"timesheetFormat"];
            if (isExtendedInOutUserPermission)
            {
                [updateDataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
            }
//            else if (isLockedInOutUserPermission)
//            {
//                [updateDataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//            }
            else
            {
                [updateDataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
                
            }
        }
        [myDB updateTable: approvalPendingTimesheetsTable data:updateDataDict where:updateWhereStr intoDatabase:@""];
    }
    else
    {
        NSMutableDictionary *updateDataDict=nil;
        NSMutableArray *arrayDict=[self getPreviousApprovalDataForTimesheetSheetURI:timesheetUri];
        if ([arrayDict count]>0)
        {
            updateDataDict=[arrayDict objectAtIndex:0];
            [updateDataDict removeObjectForKey:@"timesheetFormat"];
            if (isExtendedInOutUserPermission)
            {
                [updateDataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
            }
//            else if (isLockedInOutUserPermission)
//            {
//                [updateDataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//            }
            else
            {
                [updateDataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
                
            }
        }
        [myDB updateTable: approvalPreviousTimesheetsTable data:updateDataDict where:updateWhereStr intoDatabase:@""];
    }
    
        

    if (![timeAllocationArray isKindOfClass:[NSNull class]] && timeAllocationArray!=nil )
    {
       
        
        for (int i=0; i<[timeAllocationArray count]; i++)
        {
             NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSDictionary *dict=[timeAllocationArray objectAtIndex:i];
            
            NSString *inTimeStr=@"";
            NSString *outTimeStr=@"";
            NSString *activityName=@"";
            NSString *activityURI=@"";
            NSString *projectName=@"";
            NSString *projectURI=@"";
            NSString *taskName=@"";
            NSString *taskURI=@"";
            NSString *billingName=@"";
            NSString *billingUri=@"";
            NSString *timeOffName=@"";
            NSString *timeOffUri=@"";
            NSString *comments=@"";

            
            
            
            if ([timePunchesArray isKindOfClass:[NSNull class]] && timePunchesArray==nil )
            {
                if ([[dict objectForKey:@"project"] isKindOfClass:[NSDictionary class]])
                {
                    projectName=[[dict objectForKey:@"project"]objectForKey:@"displayText"];
                    projectURI=[[dict objectForKey:@"project"]objectForKey:@"uri"];
                }
                if ([[dict objectForKey:@"task"] isKindOfClass:[NSDictionary class]])
                {
                    taskName=[[dict objectForKey:@"task"]objectForKey:@"displayText"];
                    taskURI=[[dict objectForKey:@"task"]objectForKey:@"uri"];
                }
                if ([[dict objectForKey:@"activity"] isKindOfClass:[NSDictionary class]])
                {
                    activityName=[[dict objectForKey:@"activity"]objectForKey:@"displayText"];
                    activityURI=[[dict objectForKey:@"activity"]objectForKey:@"uri"];
                }
                if ([[dict objectForKey:@"billingRate"] isKindOfClass:[NSDictionary class]])
                {
                    billingName=[[dict objectForKey:@"billingRate"]objectForKey:@"displayText"];
                    billingUri=[[dict objectForKey:@"billingRate"]objectForKey:@"uri"];
                }
                
                
            }
            
            if ([[dict objectForKey:@"timeOffType"] isKindOfClass:[NSDictionary class]]&&![[dict objectForKey:@"timeOffType"]isKindOfClass:[NSNull class]]&&[dict objectForKey:@"timeOffType"]!=nil)
            {
                timeOffName=[[dict objectForKey:@"timeOffType"]objectForKey:@"displayText"];
                timeOffUri=[[dict objectForKey:@"timeOffType"]objectForKey:@"uri"];
                [dataDict setObject:timeOffName forKey:@"timeOffTypeName"];
                [dataDict setObject:timeOffUri forKey:@"timeOffUri"];
                if (![[dict objectForKey:@"correlatedTimeOffUri"]isKindOfClass:[NSNull class]]&&[dict objectForKey:@"correlatedTimeOffUri"]!=nil) {
                    [dataDict setObject:Time_Off_Key forKey:@"entryType"];
                    [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                    [dataDict setObject:[dict objectForKey:@"correlatedTimeOffUri"] forKey:@"rowUri"];
                }
                else
                {
                    [dataDict setObject:Adhoc_Time_OffKey forKey:@"entryType"];
                    [dataDict setObject:[NSNumber numberWithInt:Adhoc_Time_OffKey_Value] forKey:@"entryTypeOrder"];
                }
                
                
                NSString *timeAllocationUri=[dict objectForKey:@"uri"];
                [dataDict setObject:timeAllocationUri forKey:@"timeAllocationUri"];
                NSDictionary *totalTimeDurationDict=[dict objectForKey:@"duration"];
                NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                
                
                NSDate *entryDate=[Util convertApiDateDictToDateFormat:[dict objectForKey:@"date"]];
                NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                
                
                if ([dict objectForKey:@"comments"] != nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]]
                    &&[[dict objectForKey:@"comments"] isKindOfClass:[NSString class]]) {
                    comments=[dict objectForKey:@"comments"];
                }
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
                }
                [dataDict setObject:entryDateToStore                         forKey:@"timesheetEntryDate"];
                [dataDict setObject:totalTimeHoursInDecimalFormat            forKey:@"durationDecimalFormat"];
                [dataDict setObject:totalTimeHoursInHourFormat               forKey:@"durationHourFormat"];
                
                [dataDict setObject:billingName forKey:@"billingName"];
                [dataDict setObject:billingUri forKey:@"billingUri"];
                [dataDict setObject:activityName forKey:@"activityName"];
                [dataDict setObject:activityURI forKey:@"activityUri"];
                [dataDict setObject:projectURI  forKey:@"projectUri"];
                [dataDict setObject:projectName forKey:@"projectName"];
                [dataDict setObject:taskName forKey:@"taskName"];
                [dataDict setObject:taskURI forKey:@"taskUri"];
                [dataDict setObject:comments forKey:@"comments"];
                [dataDict setObject:inTimeStr forKey:@"time_in"];
                [dataDict setObject:outTimeStr forKey:@"time_out"];
                //Implemetation for ExtendedInOut
                if (isExtendedInOutUserPermission)
                {
                    [dataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                }
//                else if (isLockedInOutUserPermission)
//                {
//                    [dataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//                }
                else
                    [dataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
                
                
                NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
                [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:timeAllocationUri andtimeEntryDate:entryDateToStore moduleName:moduleName];
                if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    NSArray *expArr = [self getPendingTimesheetInfoForTimeAllocationUri:timeAllocationUri timesheetUri:timesheetUri];
                    if ([expArr count]>0)
                    {
                        NSString *whereString=[NSString stringWithFormat:@"timeAllocationUri='%@'",timeAllocationUri];
                        [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                    }

                }
                else
                {
                    NSArray *expArr = [self getPreviousTimesheetInfoForTimeAllocationUri:timeAllocationUri timesheetUri:timesheetUri];
                    if ([expArr count]>0)
                    {
                        NSString *whereString=[NSString stringWithFormat:@"timeAllocationUri='%@'",timeAllocationUri];
                        [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                    }

                }
                                
            }
            
        }
    }
    if (![timePunchesArray isKindOfClass:[NSNull class]] && timePunchesArray!=nil )
    {
       
       
        for (int i=0; i<[timePunchesArray count]; i++)
        {
             NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSString *inTimeStr=@"";
            NSString *outTimeStr=@"";
            NSString *activityName=@"";
            NSString *activityURI=@"";
            NSString *projectName=@"";
            NSString *projectURI=@"";
            NSString *taskName=@"";
            NSString *taskURI=@"";
            NSString *billingName=@"";
            NSString *billingUri=@"";
            NSString *timeOffName=@"";
            NSString *timeOffUri=@"";
            //NSString *comments=@"";
            NSString *clientName=nil;
            NSString *clientURI=nil;
            NSDate *rangeStartDate=nil;
            NSDate *rangeEndDate=nil;
            //MOBI-746
            NSString *programName=nil;
            NSString *programURI=nil;
            //Implentation for US8956//JUHI
            NSString *breakName=@"";
            NSString *breakUri=@"";
            
            NSDictionary *dict=[timePunchesArray objectAtIndex:i];
            if (isExtendedInOutUserPermission)
            {
                NSMutableArray *punchInfoDictArray=[dict objectForKey:@"associatedTimeAllocations"];
                
                if ([punchInfoDictArray count]>0)
                {
                    NSDictionary *punchInfoDict=[punchInfoDictArray objectAtIndex:0];
                    
                    NSString *timeOffType=[punchInfoDict objectForKey:@"timeOffType"];
                    
                    if (timeOffType==nil || [timeOffType isKindOfClass:[NSNull class]])
                    {
                        NSDictionary *punchProjectInfoDict=[punchInfoDict objectForKey:@"project"];
                        if (punchProjectInfoDict!=nil && ![punchProjectInfoDict isKindOfClass:[NSNull class]])
                        {
                            projectName=[punchProjectInfoDict objectForKey:@"displayText"];
                            projectURI=[punchProjectInfoDict objectForKey:@"uri"];
                            
                        }
                        NSDictionary *punchTaskInfoDict=[punchInfoDict objectForKey:@"task"];
                        if (punchTaskInfoDict!=nil && ![punchTaskInfoDict isKindOfClass:[NSNull class]])
                        {
                            taskName=[punchTaskInfoDict objectForKey:@"displayText"];
                            taskURI=[punchTaskInfoDict objectForKey:@"uri"];
                        }
                        
                        
                        
                        if (![projectURI isEqualToString:@""])
                        {
                            for (int count=0; count<[projectTaskDetailsArr count]; count++)
                            {
                                NSString *tempProjectURI=[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"project"]objectForKey:@"uri"];
                                
                                if ([tempProjectURI isEqualToString:projectURI])
                                {
                                    NSDictionary *clientDict=[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"client"];
                                    if (clientDict!=nil && ![clientDict isKindOfClass:[NSNull class]])
                                    {
                                        clientURI=[clientDict objectForKey:@"uri"];
                                        clientName=[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"client"]objectForKey:@"displayText"];
                                        
                                    }
                                    //MOBI-746
                                    NSDictionary *programDict=[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"program"];
                                    if (programDict!=nil && ![programDict isKindOfClass:[NSNull class]])
                                    {
                                        programURI=[programDict objectForKey:@"uri"];
                                        programName=[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"program"]objectForKey:@"displayText"];
                                        
                                    }

                                    
                                    rangeStartDate=[Util convertApiDateDictToDateFormat:[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"startDate"]];
                                    rangeEndDate=[Util convertApiDateDictToDateFormat:[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"endDate"]];
                                    
                                    NSLog(@"%@ %@",rangeStartDate,rangeEndDate);
                                    break;
                                    
                                    
                                    
                                }
                            }
                        }
                        
                        
                        
                        if (![taskURI isEqualToString:@""])
                        {
                            for (int count=0; count<[taskDetailsArr count]; count++)
                            {
                                NSString *temptaskURI=[[[[taskDetailsArr objectAtIndex:count] objectForKey:@"task"]objectForKey:@"task"] objectForKey:@"uri"];
                                
                                if ([temptaskURI isEqualToString:taskURI])
                                {
                                    rangeStartDate=[Util convertApiDateDictToDateFormat:[[[taskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"startDate"]];
                                    rangeEndDate=[Util convertApiDateDictToDateFormat:[[[taskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"endDate"]];
                                    
                                    NSLog(@"%@ %@",rangeStartDate,rangeEndDate);
                                    break;
                                    
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                        NSDictionary *punchActivityInfoDict=[punchInfoDict objectForKey:@"activity"];
                        if (punchActivityInfoDict!=nil && ![punchActivityInfoDict isKindOfClass:[NSNull class]])
                        {
                            activityName=[punchActivityInfoDict objectForKey:@"displayText"];
                            activityURI=[punchActivityInfoDict objectForKey:@"uri"];
                        }
                        NSDictionary *punchBillingInfoDict=[punchInfoDict objectForKey:@"billingRate"];
                        if (punchBillingInfoDict!=nil && ![punchBillingInfoDict isKindOfClass:[NSNull class]])
                        {
                            billingName=[punchBillingInfoDict objectForKey:@"displayText"];
                            billingUri=[punchBillingInfoDict objectForKey:@"uri"];
                        }
                        //Implentation for US8956//JUHI
                        NSDictionary *punchBreakInfoDict=[punchInfoDict objectForKey:@"breakType"];
                        if (punchBreakInfoDict!=nil && ![punchBreakInfoDict isKindOfClass:[NSNull class]])
                        {
                            breakName=[punchBreakInfoDict objectForKey:@"displayText"];
                            breakUri=[punchBreakInfoDict objectForKey:@"uri"];
                        }
                    }
                    
                    
                }
                
            }
            
            NSMutableDictionary *inTimeDict=[NSMutableDictionary dictionary];
            NSMutableDictionary *outTimeDict=[NSMutableDictionary dictionary];
            if ([dict objectForKey:@"actualInTime"]!=nil&&![[dict objectForKey:@"actualInTime"] isKindOfClass:[NSNull class]] )
            {
                NSDictionary *tempDict=[dict objectForKey:@"actualInTime"];
                [inTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
                [inTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
                [inTimeDict setObject:[tempDict objectForKey:@"second"] forKey:@"Second"];
                inTimeStr =  [Util convertApiTimeDictTo12HourTimeStringWithSeconds:inTimeDict];
                
            }
            
            if ([dict objectForKey:@"actualOutTime"]!=nil&&![[dict objectForKey:@"actualOutTime"] isKindOfClass:[NSNull class]])
            {
                NSDictionary *tempDict=[dict objectForKey:@"actualOutTime"];
                
                [outTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
                [outTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
                [outTimeDict setObject:[tempDict objectForKey:@"second"] forKey:@"Second"];
                outTimeStr =  [Util convertApiTimeDictTo12HourTimeStringWithSeconds:outTimeDict];
                
            }
            
            NSDictionary *totalTimeDurationDict=[[[dict objectForKey:@"associatedTimeAllocations" ]objectAtIndex:0]objectForKey:@"duration"];
            NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
            NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
            
            
            NSDate *entryDate=[Util convertApiDateDictToDateFormat:[[[dict objectForKey:@"associatedTimeAllocations" ]objectAtIndex:0]objectForKey:@"date"]];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            
            NSString *timePunchesUri=[dict objectForKey:@"uri"];
            NSString *usercomments=[[[dict objectForKey:@"associatedTimeAllocations" ] objectAtIndex:0] objectForKey:@"comments"];
            if (usercomments!=nil && ![usercomments isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:usercomments forKey:@"comments"];
            }
            else
            {
                [dataDict setObject:@"" forKey:@"comments"];
            }
            [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
            [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
            }
            [dataDict setObject:timePunchesUri forKey:@"timePunchesUri"];
            [dataDict setObject:entryDateToStore  forKey:@"timesheetEntryDate"];
            [dataDict setObject:totalTimeHoursInDecimalFormat forKey:@"durationDecimalFormat"];
            [dataDict setObject:totalTimeHoursInHourFormat forKey:@"durationHourFormat"];
            
            [dataDict setObject:billingName forKey:@"billingName"];
            [dataDict setObject:billingUri forKey:@"billingUri"];
            [dataDict setObject:activityName forKey:@"activityName"];
            [dataDict setObject:activityURI forKey:@"activityUri"];
            [dataDict setObject:projectURI  forKey:@"projectUri"];
            if (clientURI!=nil && ![clientURI isKindOfClass:[NSNull class]])
            {
                 [dataDict setObject:clientURI  forKey:@"clientUri"];
            }
            if (clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:clientName  forKey:@"clientName"];
            }
            //MOBI-746
            if (programName!=nil && ![programName isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:programName                  forKey:@"programName"];
            }
            if (programURI!=nil && ![programURI isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:programURI                  forKey:@"programUri"];
            }
            [dataDict setObject:projectName forKey:@"projectName"];
            [dataDict setObject:taskName forKey:@"taskName"];
            [dataDict setObject:taskURI forKey:@"taskUri"];
            //[dataDict setObject:comments forKey:@"comments"];
            [dataDict setObject:timeOffName forKey:@"timeOffTypeName"];
            [dataDict setObject:timeOffUri forKey:@"timeOffUri"];
            
            //Implentation for US8956//JUHI
            [dataDict setObject:breakName forKey:@"breakName"];
            [dataDict setObject:breakUri forKey:@"breakUri"];
            
            //Implemetation for ExtendedInOut
            if (isExtendedInOutUserPermission)
            {
                [dataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
            }
//            else if (isLockedInOutUserPermission)
//            {
//                [dataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//            }
            else
                [dataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
            if (inTimeStr != nil && ![inTimeStr isKindOfClass:[NSNull class]]
                &&[inTimeStr isKindOfClass:[NSString class]]) {
                [dataDict setObject:inTimeStr forKey:@"time_in"];
            }
            if (outTimeStr != nil && ![outTimeStr isKindOfClass:[NSNull class]]
                &&[outTimeStr isKindOfClass:[NSString class]]) {
                [dataDict setObject:outTimeStr forKey:@"time_out"];
            }
        
        if (isExtendedInOutUserPermission)
        {
            NSMutableArray *punchInfoDictArray=[dict objectForKey:@"associatedTimeAllocations"];
            
            if ([punchInfoDictArray count]>0)
            {
                NSDictionary *punchInfoDict=[punchInfoDictArray objectAtIndex:0];
                NSArray *cellCustomFieldsArray=[punchInfoDict objectForKey:@"customFieldValues"];
                [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_CELL_UDF andEntryURI:timePunchesUri andtimeEntryDate:entryDateToStore moduleName:moduleName];
            }
        }
            if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                NSArray *expArr = [self getPendingTimesheetInfoForTimePunchesUri:timePunchesUri timesheetUri:timesheetUri];
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri='%@'",timePunchesUri];
                    [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                }

            }
            else
            {
                NSArray *expArr = [self getPreviousTimesheetInfoForTimePunchesUri:timePunchesUri timesheetUri:timesheetUri];
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri='%@'",timePunchesUri];
                    [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                }

            }
                        
        }
    }
    
    
}
-(void)saveStandardTimeEntriesDataToDBForTimesheetUri:(NSString*)timesheetUri dataDict:(NSMutableDictionary *)standardTimesheetDetailsDict projectTaskDetails:(NSArray *)projectTaskDetailsArr taskDetails:taskDetailsArr moduleName:(NSString *)moduleName
{
    NSMutableArray *timeEntryRowsArray=[standardTimesheetDetailsDict objectForKey:@"rows"];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimeEntriesTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimeEntriesTable where:whereStr inDatabase:@""];
    }
    
    NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
    {
        NSMutableArray *arrayDict=[self getPendingApprovalDataForTimesheetSheetURI:timesheetUri];
        NSMutableDictionary *updateDataDict=nil;
        if ([arrayDict count]>0)
        {
            updateDataDict=[arrayDict objectAtIndex:0];
            [updateDataDict removeObjectForKey:@"timesheetFormat"];
            [updateDataDict setObject:STANDARD_TIMESHEET forKey:@"timesheetFormat"];
        }
        [myDB updateTable: approvalPendingTimesheetsTable data:updateDataDict where:updateWhereStr intoDatabase:@""];

    }
    else
    {
        NSMutableArray *arrayDict=[self getPreviousApprovalDataForTimesheetSheetURI:timesheetUri];
        NSMutableDictionary *updateDataDict=nil;
        if ([arrayDict count]>0)
        {
            updateDataDict=[arrayDict objectAtIndex:0];
            [updateDataDict removeObjectForKey:@"timesheetFormat"];
            [updateDataDict setObject:STANDARD_TIMESHEET forKey:@"timesheetFormat"];
        }
        
        [myDB updateTable: approvalPreviousTimesheetsTable data:updateDataDict where:updateWhereStr intoDatabase:@""];
    }
    for (int i=0; i<[timeEntryRowsArray count]; i++)
    {
        
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSDictionary *dict=[timeEntryRowsArray objectAtIndex:i];
        NSDictionary *timeOffTypeDict=[dict objectForKey:@"timeOffType"];
        if (![timeOffTypeDict isKindOfClass:[NSNull class]] && timeOffTypeDict!=nil)
        {
            NSString *commentsString=@"";
            NSString *timeOffName=[[dict objectForKey:@"timeOffType"]objectForKey:@"displayText"];
            NSString *timeOffUri=[[dict objectForKey:@"timeOffType"]objectForKey:@"uri"];
            NSString *rowUri=@"";
            NSString *correlatedTimeOffUri=[dict objectForKey:@"correlatedTimeOffUri"];
            if (![correlatedTimeOffUri isKindOfClass:[NSNull class]]&& correlatedTimeOffUri!=nil)
            {
                [dataDict setObject:Time_Off_Key forKey:@"entryType"];
                [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                [dataDict setObject:correlatedTimeOffUri forKey:@"correlatedTimeOffUri"];
            }
            else
            {
                [dataDict setObject:Adhoc_Time_OffKey forKey:@"entryType"];
                [dataDict setObject:[NSNumber numberWithInt:Adhoc_Time_OffKey_Value] forKey:@"entryTypeOrder"];
            }
            
            NSMutableArray *cellArray =[dict objectForKey:@"cells"];
            
            NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
            //            [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:[dict objectForKey:@"uri"] andtimeEntryDate:nil];
            
            
            if ([cellArray count]!=0)
            {
                rowUri=[dict objectForKey:@"uri"];
                for (int k=0; k<[cellArray count]; k++)
                {
                    NSDictionary *cellDict=[cellArray objectAtIndex:k];
                    commentsString=@"";
                    NSDictionary *totalTimeDurationDict=[cellDict objectForKey:@"duration"];
                    NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                    NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                    
                    
                    NSDate *entryDate=[Util convertApiDateDictToDateFormat:[cellDict objectForKey:@"date"]];
                    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                    NSString *commentsStringValue=[cellDict objectForKey:@"comments"];
                    
                    if (commentsStringValue != nil && ![commentsStringValue isKindOfClass:[NSNull class]]
                        &&[commentsStringValue isKindOfClass:[NSString class]]) {
                        commentsString=[cellDict objectForKey:@"comments"];
                    }
                    
                    [dataDict setObject:timeOffName                     forKey:@"timeOffTypeName"];
                    [dataDict setObject:timeOffUri                      forKey:@"timeOffUri"];
                    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                    }
                    [dataDict setObject:entryDateToStore                forKey:@"timesheetEntryDate"];
                    [dataDict setObject:totalTimeHoursInDecimalFormat   forKey:@"durationDecimalFormat"];
                    [dataDict setObject:totalTimeHoursInHourFormat      forKey:@"durationHourFormat"];
                    [dataDict setObject:commentsString                  forKey:@"comments"];
                    [dataDict setObject:rowUri                          forKey:@"rowUri"];
                    [dataDict setObject:STANDARD_TIMESHEET              forKey:@"timesheetFormat"];
                    
                    
                    //                    NSArray *cellCustomFieldsArray=[cellDict objectForKey:@"customFieldValues"];
                    [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:rowUri andtimeEntryDate:entryDateToStore moduleName:moduleName];
                    //
                    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                    }
                    
                    
                    
                }
                
            }
            else
            {
                rowUri=[dict objectForKey:@"uri"];
                NSDate *entryDate=[Util convertApiDateDictToDateFormat:[[standardTimesheetDetailsDict objectForKey:@"dateRange"] objectForKey:@"startDate"]];
                NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                int hours=0;
                int minutes=0;
                int seconds=0;
                NSMutableDictionary *totalTimeDurationDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            [NSString stringWithFormat:@"%d",hours],@"hours",
                                                            [NSString stringWithFormat:@"%d",minutes],@"minutes",
                                                            [NSString stringWithFormat:@"%d",seconds],@"seconds",
                                                            nil];
                NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                
                [dataDict setObject:timeOffName                     forKey:@"timeOffTypeName"];
                [dataDict setObject:timeOffUri                      forKey:@"timeOffUri"];
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                }
                [dataDict setObject:entryDateToStore                forKey:@"timesheetEntryDate"];
                [dataDict setObject:totalTimeHoursInDecimalFormat   forKey:@"durationDecimalFormat"];
                [dataDict setObject:totalTimeHoursInHourFormat      forKey:@"durationHourFormat"];
                [dataDict setObject:commentsString                  forKey:@"comments"];
                [dataDict setObject:rowUri                          forKey:@"rowUri"];
                [dataDict setObject:STANDARD_TIMESHEET              forKey:@"timesheetFormat"];
                
                
                NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
                [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:rowUri andtimeEntryDate:entryDateToStore moduleName:moduleName];
                
                if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                }
                
                
                
                
                
            }
            
        }
        else
        {
            NSString *activityName=@"";
            NSString *activityURI=@"";
            NSString *projectName=@"";
            NSString *projectURI=@"";
            NSString *clientName=nil;
            NSString *clientURI=nil;
            //MOBI-746
            NSString *programName=nil;
            NSString *programURI=nil;
            NSString *taskName=@"";
            NSString *taskURI=@"";
            NSString *billingName=@"";
            NSString *billingUri=@"";
            NSString *commentsString=@"";
            NSDate *rangeStartDate=nil;
            NSDate *rangeEndDate=nil;
            if ([[dict objectForKey:@"project"] isKindOfClass:[NSDictionary class]])
            {
                projectName=[[dict objectForKey:@"project"]objectForKey:@"displayText"];
                projectURI=[[dict objectForKey:@"project"]objectForKey:@"uri"];
            }
            if ([[dict objectForKey:@"task"] isKindOfClass:[NSDictionary class]])
            {
                taskName=[[dict objectForKey:@"task"]objectForKey:@"displayText"];
                taskURI=[[dict objectForKey:@"task"]objectForKey:@"uri"];
            }
            
            if (![projectURI isEqualToString:@""])
            {
                for (int count=0; count<[projectTaskDetailsArr count]; count++)
                {
                    NSString *tempProjectURI=[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"project"]objectForKey:@"uri"];
                    
                    if ([tempProjectURI isEqualToString:projectURI])
                    {
                        NSDictionary *clientDict=[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"client"];
                        if (clientDict!=nil && ![clientDict isKindOfClass:[NSNull class]])
                        {
                            clientURI=[clientDict objectForKey:@"uri"];
                            clientName=[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"client"]objectForKey:@"displayText"];
                            
                        }
                        //MOBI-746
                        NSDictionary *programDict=[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"program"];
                        if (programDict!=nil && ![programDict isKindOfClass:[NSNull class]])
                        {
                            programURI=[programDict objectForKey:@"uri"];
                            programName=[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"program"]objectForKey:@"displayText"];
                            
                        }
                        
                        rangeStartDate=[Util convertApiDateDictToDateFormat:[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"startDate"]];
                        rangeEndDate=[Util convertApiDateDictToDateFormat:[[[projectTaskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"endDate"]];
                        
                        
                        break;
                        
                        
                        
                    }
                }
            }
            
            
            if (![taskURI isEqualToString:@""])
            {
                for (int count=0; count<[taskDetailsArr count]; count++)
                {
                    NSString *temptaskURI=[[[[taskDetailsArr objectAtIndex:count] objectForKey:@"task"]objectForKey:@"task"] objectForKey:@"uri"];
                    
                    if ([temptaskURI isEqualToString:taskURI])
                    {
                        rangeStartDate=[Util convertApiDateDictToDateFormat:[[[taskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"startDate"]];
                        rangeEndDate=[Util convertApiDateDictToDateFormat:[[[taskDetailsArr objectAtIndex:count] objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"]objectForKey:@"endDate"]];
                        
                        
                        break;
                        
                        
                    }
                }
                
            }
            
            if ([[dict objectForKey:@"activity"] isKindOfClass:[NSDictionary class]])
            {
                activityName=[[dict objectForKey:@"activity"]objectForKey:@"displayText"];
                activityURI=[[dict objectForKey:@"activity"]objectForKey:@"uri"];
            }
            if ([[dict objectForKey:@"billingRate"] isKindOfClass:[NSDictionary class]])
            {
                billingName=[[dict objectForKey:@"billingRate"]objectForKey:@"displayText"];
                billingUri=[[dict objectForKey:@"billingRate"]objectForKey:@"uri"];
            }
            NSString *timeAllocationUri=[dict objectForKey:@"uri"];
            
            NSMutableArray *cellArray =[dict objectForKey:@"cells"];
            
            
            NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
            [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_ROW_UDF andEntryURI:[dict objectForKey:@"uri"] andtimeEntryDate:nil moduleName:moduleName];//Implementation for US9371//JUHI
            
            if ([cellArray count]!=0)
            {
                for (int k=0; k<[cellArray count]; k++)
                {
                    NSDictionary *cellDict=[cellArray objectAtIndex:k];
                    commentsString=@"";
                    NSDictionary *totalTimeDurationDict=[cellDict objectForKey:@"duration"];
                    NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                    NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                    
                    
                    NSDate *entryDate=[Util convertApiDateDictToDateFormat:[cellDict objectForKey:@"date"]];
                    
                    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                    
                    if (rangeStartDate!=nil && ![rangeStartDate isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:[NSNumber numberWithDouble:[rangeStartDate timeIntervalSince1970] ]forKey:@"startDateAllowedTime"];
                    }
                    if (rangeEndDate!=nil && ![rangeEndDate isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:[NSNumber numberWithDouble:[rangeEndDate timeIntervalSince1970] ]forKey:@"endDateAllowedTime"];
                    }
                    
                    NSString *commentsStringValue=[cellDict objectForKey:@"comments"];
                    
                    if (commentsStringValue != nil && ![commentsStringValue isKindOfClass:[NSNull class]]
                        &&[commentsStringValue isKindOfClass:[NSString class]])
                    {
                        commentsString=[cellDict objectForKey:@"comments"];
                    }
                    
                    [dataDict setObject:Time_Entry_Key                  forKey:@"entryType"];
                    [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                    [dataDict setObject:timeAllocationUri               forKey:@"rowUri"];
                    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                    }
                    [dataDict setObject:entryDateToStore                forKey:@"timesheetEntryDate"];
                    [dataDict setObject:totalTimeHoursInDecimalFormat   forKey:@"durationDecimalFormat"];
                    [dataDict setObject:totalTimeHoursInHourFormat      forKey:@"durationHourFormat"];
                    [dataDict setObject:billingName                     forKey:@"billingName"];
                    [dataDict setObject:billingUri                      forKey:@"billingUri"];
                    [dataDict setObject:activityName                    forKey:@"activityName"];
                    [dataDict setObject:activityURI                     forKey:@"activityUri"];
                    [dataDict setObject:projectURI                      forKey:@"projectUri"];
                    [dataDict setObject:projectName                     forKey:@"projectName"];
                    if (clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:clientName                  forKey:@"clientName"];
                    }
                    if (clientURI!=nil && ![clientURI isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:clientURI                  forKey:@"clientUri"];
                    }
                    //MOBI-746
                    if (programName!=nil && ![programName isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:programName                  forKey:@"programName"];
                    }
                    if (programURI!=nil && ![programURI isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:programURI                  forKey:@"programUri"];
                    }
                    [dataDict setObject:taskName                        forKey:@"taskName"];
                    [dataDict setObject:taskURI                         forKey:@"taskUri"];
                    [dataDict setObject:commentsString                  forKey:@"comments"];
                    [dataDict setObject:STANDARD_TIMESHEET              forKey:@"timesheetFormat"];
                    
                    
                    NSArray *cellCustomFieldsArray=[cellDict objectForKey:@"customFieldValues"];
                    [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_CELL_UDF andEntryURI:timeAllocationUri andtimeEntryDate:entryDateToStore moduleName:moduleName ];
                    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                    }
                    
                    
                    
                    
                }
                
            }
            else
            {
                NSDate *entryDate=[Util convertApiDateDictToDateFormat:[[standardTimesheetDetailsDict objectForKey:@"dateRange"] objectForKey:@"startDate"]];
                NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                
                if (rangeStartDate!=nil && ![rangeStartDate isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[NSNumber numberWithDouble:[rangeStartDate timeIntervalSince1970] ]forKey:@"startDateAllowedTime"];
                }
                if (rangeEndDate!=nil && ![rangeEndDate isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[NSNumber numberWithDouble:[rangeEndDate timeIntervalSince1970] ]forKey:@"endDateAllowedTime"];
                }
                
                int hours=0;
                int minutes=0;
                int seconds=0;
                NSMutableDictionary *totalTimeDurationDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            [NSString stringWithFormat:@"%d",hours],@"hours",
                                                            [NSString stringWithFormat:@"%d",minutes],@"minutes",
                                                            [NSString stringWithFormat:@"%d",seconds],@"seconds",
                                                            nil];
                NSNumber *totalTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                
                [dataDict setObject:Time_Entry_Key                  forKey:@"entryType"];
                [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                [dataDict setObject:timeAllocationUri               forKey:@"rowUri"];
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                }
                [dataDict setObject:entryDateToStore                forKey:@"timesheetEntryDate"];
                [dataDict setObject:totalTimeHoursInDecimalFormat   forKey:@"durationDecimalFormat"];
                [dataDict setObject:totalTimeHoursInHourFormat      forKey:@"durationHourFormat"];
                [dataDict setObject:billingName                     forKey:@"billingName"];
                [dataDict setObject:billingUri                      forKey:@"billingUri"];
                [dataDict setObject:activityName                    forKey:@"activityName"];
                [dataDict setObject:activityURI                     forKey:@"activityUri"];
                [dataDict setObject:projectURI                      forKey:@"projectUri"];
                [dataDict setObject:projectName                     forKey:@"projectName"];
                [dataDict setObject:projectName                     forKey:@"projectName"];
                if (clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:clientName                  forKey:@"clientName"];
                }
                if (clientURI!=nil && ![clientURI isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:clientURI                  forKey:@"clientUri"];
                }
                //MOBI-746
                if (programName!=nil && ![programName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:programName                  forKey:@"programName"];
                }
                if (programURI!=nil && ![programURI isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:programURI                  forKey:@"programUri"];
                }
                [dataDict setObject:taskName                        forKey:@"taskName"];
                [dataDict setObject:taskURI                         forKey:@"taskUri"];
                [dataDict setObject:commentsString                  forKey:@"comments"];
                [dataDict setObject:STANDARD_TIMESHEET              forKey:@"timesheetFormat"];
                
                
                NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
                [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_CELL_UDF andEntryURI:timeAllocationUri andtimeEntryDate:entryDateToStore moduleName:moduleName];
                if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                }
                
            }
            
        }
        
        
    }
    
}

-(void)saveApprovalTimesheetDisclaimerDataToDB:(NSMutableDictionary *)disclaimerDict moduleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disclaimerDescription=[disclaimerDict objectForKey:@"description"];
    NSString *disclaimerTitle=[disclaimerDict objectForKey:@"title"];
    
    
    NSString *disclaimerModule=nil;
    //Implementation as per US9172//JUHI
    if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE]||[moduleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE]) {
        disclaimerModule=TIMESHEET_MODULE_NAME;
    }
    else if ([moduleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE]||[moduleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE]){
        disclaimerModule=ExpenseModuleName;
    }
    NSString *whereStr=[NSString stringWithFormat:@"module='%@'",disclaimerModule];
    if ([disclaimerModule isEqualToString:TIMESHEET_MODULE_NAME]) {
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            [myDB deleteFromTable:approvalPendingDisclaimerTable where:whereStr inDatabase:@""];
        }
        else
        {
            [myDB deleteFromTable:approvalPreviousDisclaimerTable where:whereStr inDatabase:@""];
        }
    }
    else if ([disclaimerModule isEqualToString:ExpenseModuleName]){
        if ([moduleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            [myDB deleteFromTable:approvalPendingDisclaimerTable where:whereStr inDatabase:@""];
        }
        else
        {
            [myDB deleteFromTable:approvalPreviousDisclaimerTable where:whereStr inDatabase:@""];
        }
    }
    
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if (disclaimerDescription!=nil && ![disclaimerDescription isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:disclaimerDescription forKey:@"description"];
    }
    if (disclaimerTitle!=nil && ![disclaimerTitle isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:disclaimerTitle forKey:@"title"];
    }
    if (disclaimerModule!=nil && ![disclaimerModule isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:disclaimerModule forKey:@"module"];
    }
    
    
    if ([disclaimerModule isEqualToString:TIMESHEET_MODULE_NAME]) {
        if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            [myDB insertIntoTable:approvalPendingDisclaimerTable data:dataDict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousDisclaimerTable data:dataDict intoDatabase:@""];
        }
    }
    else if ([disclaimerModule isEqualToString:ExpenseModuleName]){
        if ([moduleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            [myDB insertIntoTable:approvalPendingDisclaimerTable data:dataDict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousDisclaimerTable data:dataDict intoDatabase:@""];
        }
    }
    
    
  
    
}
-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI andtimeEntryDate:(NSNumber *)entryDate moduleName:(NSString *)approvalModuleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[sheetCustomFieldsArray count]; i++)
    {
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        NSDictionary *udfDict=[sheetCustomFieldsArray objectAtIndex:i];
        NSString *name=[[udfDict objectForKey:@"customField"]objectForKey:@"displayText"];
        if (name!=nil && ![name isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:name forKey:@"udf_name"];
        }
        NSString *uri=[[udfDict objectForKey:@"customField"]objectForKey:@"uri"];
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:uri forKey:@"udf_uri"];
        }
        NSString *type=[[udfDict objectForKey:@"customFieldType"]objectForKey:@"uri"];
        if (type!=nil && ![type isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:type forKey:@"entry_type"];
            
            if ([type isEqualToString:DROPDOWN_UDF_TYPE])
            {
                NSString *dropDownOptionURI=[udfDict objectForKey:@"dropDownOption"];
                if (dropDownOptionURI!=nil && ![dropDownOptionURI isKindOfClass:[NSNull class]])
                {
                    [udfDataDict setObject:dropDownOptionURI forKey:@"dropDownOptionURI"];
                }
            }
        }
        
        
        if (entryURI!=nil && ![entryURI isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:entryURI forKey:@"entryUri"];
        }
        
        NSString *value=[udfDict objectForKey:@"text"];
        if ([type isEqualToString:DATE_UDF_TYPE])
        {
            NSString *tmpValue=[udfDict objectForKey:@"date"];
            if (tmpValue!=nil && ![tmpValue isKindOfClass:[NSNull class]])
            {
                value=[Util convertApiTimeDictToDateStringWithDesiredFormat:[udfDict objectForKey:@"date"]];//DE18243 DE18690 DE18728 Ullas M L
            }
        }
        if (value!=nil && ![value isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:value forKey:@"udfValue"];
        }
        
        if (sheetUri!=nil && ![sheetUri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:sheetUri forKey:@"timesheetUri"];
        }
        
        if (moduleName!=nil && ![moduleName isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:moduleName forKey:@"moduleName"];
        }
        
        if (entryDate!=nil && ![entryDate isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:entryDate forKey:@"timesheetEntryDate"];
        }
        if ([approvalModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            NSArray *udfsArr = [self getPendingTimesheetCustomFieldsForSheetURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri andEntryDate:[NSString stringWithFormat:@"%@",entryDate]];
            if ([udfsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
                [myDB updateTable:approvalPendingTimesheetCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingTimesheetCustomFieldsTable data:udfDataDict intoDatabase:@""];
            }

        }
        else
        {
            NSArray *udfsArr = [self getPreviousTimesheetCustomFieldsForSheetURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri andEntryDate:[NSString stringWithFormat:@"%@",entryDate]];
            if ([udfsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
                [myDB updateTable:approvalPreviousTimesheetCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousTimesheetCustomFieldsTable data:udfDataDict intoDatabase:@""];
            }
        }
                
        
    }
}
//Implementation For Mobi-92//JUHI
-(void)savePendingTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)responseArray withTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int k=0; k<[responseArray count ]; k++)
    {
        NSDictionary *breakTimeEntryDict=[[responseArray objectAtIndex:k] objectForKey:@"breakTimeEntry"];
        NSDictionary *workTimeEntryDict=[[responseArray objectAtIndex:k] objectForKey:@"workTimeEntry"];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
        {
            NSDictionary *breakType=[breakTimeEntryDict objectForKey:@"breakType"];
            NSString *comments=[breakTimeEntryDict objectForKey:@"comments"];
            NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
//            NSString *hours=[breakTimeEntryDict objectForKey:@"hours"];
            NSDictionary *timePairDict=[breakTimeEntryDict objectForKey:@"timePair"];
            NSString *uri=[breakTimeEntryDict objectForKey:@"uri"];
//            NSDictionary *user=[breakTimeEntryDict objectForKey:@"user"];
            
            
            
            if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                comments=@"";
            }
            
            NSString *inTimeString=@"";
            NSString *outTimeString=@"";
            BOOL isEmptyTimeEntry=NO;
            if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
            {
                NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                {
                    inTimeString=[Util convertApiTimeDictTo12HourTimeString:startTimeDict];
                }
                
                if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                {
                    outTimeString=[Util convertApiTimeDictTo12HourTimeString:endTimeDict];
                }
                
            }
            else
            {
                isEmptyTimeEntry=YES;
            }
            
            NSString *decimalHours=@"0.00";
            if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
            {
                decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
            }
            
            
            NSString *breakName=[breakType objectForKey:@"displayText"];
            if (breakName==nil||[breakName isKindOfClass:[NSNull class]]) {
                breakName=@"";
            }
            NSString *breakUri=[breakType objectForKey:@"uri"];
            if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]) {
                breakUri=@"";
            }
            
            NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            
            
            [dataDict setObject:uri forKey:@"rowUri"];
            [dataDict setObject:inTimeString forKey:@"time_in"];
            [dataDict setObject:outTimeString forKey:@"time_out"];
            [dataDict setObject:comments forKey:@"comments"];
            [dataDict setObject:breakName forKey:@"breakName"];
            [dataDict setObject:breakUri forKey:@"breakUri"];
            [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
            [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
            [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
            [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
            [dataDict setObject:uri forKey:@"timePunchesUri"];
            [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
            }
            //[dataDict setObject:[NSNull null] forKey:@"projectUri"];
            //[dataDict setObject:[NSNull null] forKey:@"projectName"];
            //[dataDict setObject:[NSNull null] forKey:@"taskUri"];
            //[dataDict setObject:[NSNull null] forKey:@"taskName"];
            //[dataDict setObject:[NSNull null] forKey:@"billingUri"];
            //[dataDict setObject:[NSNull null] forKey:@"billingName"];
            //[dataDict setObject:[NSNull null] forKey:@"activityUri"];
            //[dataDict setObject:[NSNull null] forKey:@"activityName"];
            //[dataDict setObject:[NSNull null] forKey:@"clientUri"];
            //[dataDict setObject:[NSNull null] forKey:@"clientName"];
            //[dataDict setObject:[NSNull null] forKey:@"timeOffUri"];
            //[dataDict setObject:[NSNull null] forKey:@"timeOffTypeName"];
            //[dataDict setObject:[NSNull null] forKey:@"correlatedTimeOffUri"];
            //[dataDict setObject:[NSNull null] forKey:@"startDateAllowedTime"];
            //[dataDict setObject:[NSNull null] forKey:@"endDateAllowedTime"];
            //[dataDict setObject:[NSNull null] forKey:@"timeAllocationUri"];
            //[dataDict setObject:[NSNull null] forKey:@"durationHourFormat"];
            
            if (!isEmptyTimeEntry)
            {
                NSArray *expArr = [self getPendingTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                    [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                }
            }
            
            
            
            
        }
        else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
        {
            NSString *comments=[workTimeEntryDict objectForKey:@"comments"];
            
            NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
//            NSString *hours=[workTimeEntryDict objectForKey:@"hours"];
//            NSString *percent=[workTimeEntryDict objectForKey:@"percent"];
            NSDictionary *timePairDict=[workTimeEntryDict objectForKey:@"timePair"];
            NSString *uri=[workTimeEntryDict objectForKey:@"uri"];
//            NSDictionary *userDict=[workTimeEntryDict objectForKey:@"user"];
//            NSString *workdays=[workTimeEntryDict objectForKey:@"workdays"];
            
            NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            
            
            if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                comments=@"";
            }
            
            NSString *inTimeString=@"";
            NSString *outTimeString=@"";
            BOOL isEmptyTimeEntry=NO;
            if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
            {
                NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                {
                    inTimeString=[Util convertApiTimeDictTo12HourTimeString:startTimeDict];
                }
                
                if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                {
                    outTimeString=[Util convertApiTimeDictTo12HourTimeString:endTimeDict];
                }
                
            }
            else
            {
                isEmptyTimeEntry=YES;
            }
            
            NSString *decimalHours=@"0.00";
            if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
            {
                decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
            }
            
            [dataDict setObject:uri forKey:@"rowUri"];
            [dataDict setObject:inTimeString forKey:@"time_in"];
            [dataDict setObject:outTimeString forKey:@"time_out"];
            [dataDict setObject:comments forKey:@"comments"];
            [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
            [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
            [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
            [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
            [dataDict setObject:uri forKey:@"timePunchesUri"];
            [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
            }
            //[dataDict setObject:[NSNull null] forKey:@"projectUri"];
            //[dataDict setObject:[NSNull null] forKey:@"projectName"];
            //[dataDict setObject:[NSNull null] forKey:@"taskUri"];
            //[dataDict setObject:[NSNull null] forKey:@"taskName"];
            //[dataDict setObject:[NSNull null] forKey:@"billingUri"];
            //[dataDict setObject:[NSNull null] forKey:@"billingName"];
            //[dataDict setObject:[NSNull null] forKey:@"activityUri"];
            //[dataDict setObject:[NSNull null] forKey:@"activityName"];
            //[dataDict setObject:[NSNull null] forKey:@"clientUri"];
            //[dataDict setObject:[NSNull null] forKey:@"clientName"];
            //[dataDict setObject:[NSNull null] forKey:@"breakName"];
            //[dataDict setObject:[NSNull null] forKey:@"breakUri"];
            //[dataDict setObject:[NSNull null] forKey:@"timeOffUri"];
            //[dataDict setObject:[NSNull null] forKey:@"timeOffTypeName"];
            //[dataDict setObject:[NSNull null] forKey:@"correlatedTimeOffUri"];
            //[dataDict setObject:[NSNull null] forKey:@"startDateAllowedTime"];
            //[dataDict setObject:[NSNull null] forKey:@"endDateAllowedTime"];
            //[dataDict setObject:[NSNull null] forKey:@"timeAllocationUri"];
            //[dataDict setObject:[NSNull null] forKey:@"durationHourFormat"];
            
            if (!isEmptyTimeEntry)
            {
                NSArray *expArr = [self getPendingTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                    [myDB updateTable:approvalPendingTimeEntriesTable  data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                }

            }

            
        }
        
    }
    
}
-(void)savePendingTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr
{
    NSMutableArray *enableWidgetsArr=[self getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    BOOL isHybridTimesheet=NO;
    BOOL hasStandardWidget=NO;
    BOOL hasInOutWidget=NO;
    BOOL hasExtInOutWidget=NO;
    BOOL hasPunchWidget=NO;
    
    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            hasStandardWidget=YES;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            hasInOutWidget=YES;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            hasExtInOutWidget=YES;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            hasPunchWidget=YES;
            
        }
    }
    
    if (hasInOutWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }

    if (hasExtInOutWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }
    
    if (hasPunchWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }

    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        NSString *format=@"";
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            format=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            format=GEN4_INOUT_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            format=GEN4_EXT_INOUT_TIMESHEET;

        }
       
        if ([format isEqualToString:GEN4_STANDARD_TIMESHEET] || [format isEqualToString:GEN4_INOUT_TIMESHEET] || [format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
        {
            SQLiteDB *myDB = [SQLiteDB getInstance];
            NSArray *timeSheetsInfoArr=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
            NSDictionary *timesheetInfoDict=[timeSheetsInfoArr objectAtIndex:0];
            NSDate *startDate = [Util convertTimestampFromDBToDate:[[timesheetInfoDict objectForKey:@"startDate"] stringValue]];
            NSDate *endDate = [Util convertTimestampFromDBToDate:[[timesheetInfoDict objectForKey:@"endDate"] stringValue]];
            
            NSMutableArray *timesheetperiodDatesArray=[NSMutableArray array];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            gregorianCalendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDateComponents *days = [[NSDateComponents alloc] init];
            [timesheetperiodDatesArray addObject:[Util convertDateToApiDateDictionary:startDate]];
            NSInteger dayCount = 0;
            while ( TRUE ) {
                [days setDay: ++dayCount];
                NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate:startDate options: 0];
                if ( [date compare: endDate] == NSOrderedDescending )
                    break;
                [timesheetperiodDatesArray addObject:[Util convertDateToApiDateDictionary:date]];
            }
            
            
            
            NSMutableArray *array=[NSMutableArray array];
            for (int j=0; j<[widgetTimeEntriesArr count]; j++) {
                NSMutableDictionary *newDict=[widgetTimeEntriesArr objectAtIndex:j];
                
                NSMutableArray *timeAllocationTypeUrisArr=[newDict objectForKey:@"timeAllocationTypeUris"];
                BOOL isContinue=YES;
                if (isHybridTimesheet && [format isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    if ([timeAllocationTypeUrisArr count]==1 && [timeAllocationTypeUrisArr containsObject:@"urn:replicon:time-allocation-type:project"])
                    {
                        isContinue=YES;
                    }
                    else
                    {
                        isContinue=NO;
                    }
                }
                if (isHybridTimesheet && [format isEqualToString:GEN4_INOUT_TIMESHEET])
                {
                    if ([timeAllocationTypeUrisArr count]==1 && [timeAllocationTypeUrisArr containsObject:@"urn:replicon:time-allocation-type:attendance"])
                    {
                        isContinue=YES;
                    }
                    else
                    {
                        isContinue=NO;
                    }
                }
                if (isHybridTimesheet && [format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    if ([timeAllocationTypeUrisArr count]==1 && [timeAllocationTypeUrisArr containsObject:@"urn:replicon:time-allocation-type:attendance"])
                    {
                        isContinue=YES;
                    }
                    else
                    {
                        isContinue=NO;
                    }
                }
                
                if (isContinue)
                {

                    SQLiteDB *myDB = [SQLiteDB getInstance];
                     [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:[NSString stringWithFormat:@"timesheetUri='%@' and timeEntryUri='%@'",timesheetUri,newDict[@"uri"]] inDatabase:@""];
                    NSArray *cellOEFDataArr=[newDict objectForKey:@"extensionFieldValues"];
                    for (NSDictionary *cellOEFDict in cellOEFDataArr)
                    {
                        NSMutableDictionary *cellOEFDataDict=[NSMutableDictionary dictionary];
                        [cellOEFDataDict setObject:newDict[@"uri"] forKey:@"timeEntryUri"];
                        [cellOEFDataDict setObject:cellOEFDict[@"definition"][@"uri"] forKey:@"uri"];
                        [cellOEFDataDict setObject:cellOEFDict[@"definition"][@"definitionTypeUri"] forKey:@"definitionTypeUri"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        }
                        if (cellOEFDict[@"numericValue"]!=nil && ![cellOEFDict[@"numericValue"] isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:cellOEFDict[@"numericValue"] forKey:@"numericValue"];
                        }
                        else if (cellOEFDict[@"textValue"]!=nil && ![cellOEFDict[@"textValue"] isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:cellOEFDict[@"textValue"] forKey:@"textValue"];
                        }
                        else if (cellOEFDict[@"tag"]!=nil && ![cellOEFDict[@"tag"] isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:cellOEFDict[@"tag"][@"displayText"] forKey:@"dropdownOptionValue"];
                            [cellOEFDataDict setObject:cellOEFDict[@"tag"][@"uri"] forKey:@"dropdownOptionUri"];
                        }


                        [myDB insertIntoTable:timeEntriesObjectExtensionFieldsTable data:cellOEFDataDict intoDatabase:@""];
                        
                        
                    }

                    NSMutableArray *customMetaDataArr=[newDict objectForKey:@"customMetadata"];
                    NSMutableDictionary *breakTimeEntryDict=nil;
                    NSMutableDictionary *workTimeEntryDict=nil;
                    NSString *comments=nil;
                    NSString *taskName=nil;
                    NSString *taskUri=nil;
                    NSString *billingName=nil;
                    NSString *billingUri=nil;
                    NSString *activityName=@"";
                    NSString *activityUri=nil;
                    NSString *projectName=nil;
                    NSString *projectUri=nil;
                    NSString *clientName=nil;
                    NSString *clientUri=nil;
                    NSString *programName=nil;
                    NSString *programUri=nil;
                    NSString *rowNumber=[Util getRandomGUID];
                    
                    for (NSDictionary *customMetaDict in customMetaDataArr)
                    {
                        NSString *keyUri=[customMetaDict objectForKey:@"keyUri"];
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:break-type"])
                        {
                            breakTimeEntryDict=[NSMutableDictionary dictionary];
                            [breakTimeEntryDict setObject:[customMetaDict objectForKey:@"value"] forKey:@"breakType"];
                            [breakTimeEntryDict setObject:[newDict objectForKey:@"entryDate"] forKey:@"entryDate"];
                            
                            NSDictionary *intervalDict=[newDict objectForKey:@"interval"];
                            if (intervalDict!=nil && ![intervalDict isKindOfClass:[NSNull class]])
                            {
                                if ([intervalDict objectForKey:@"hours"]!=nil && ![[intervalDict objectForKey:@"hours"] isKindOfClass:[NSNull class]])
                                {
                                    [breakTimeEntryDict setObject:[intervalDict objectForKey:@"hours"] forKey:@"hours"];
                                    
                                }
                                if ([intervalDict objectForKey:@"timePair"]!=nil && ![[intervalDict objectForKey:@"timePair"] isKindOfClass:[NSNull class]])
                                {
                                    [breakTimeEntryDict setObject:[intervalDict objectForKey:@"timePair"] forKey:@"timePair"];
                                }
                            }
                            
                            
                            [breakTimeEntryDict setObject:[newDict objectForKey:@"uri"] forKey:@"uri"];
                            [breakTimeEntryDict setObject:[newDict objectForKey:@"user"] forKey:@"user"];
                            break;
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:comments"])
                        {
                            comments=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:task"])
                        {
                            taskUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:billing-rate"])
                        {
                            billingUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                            billingName=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:activity"])
                        {
                            activityUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                            activityName=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:project"])
                        {
                            projectUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:widget-ui-metadata-key:row-number"])
                        {
                            rowNumber=[[customMetaDict objectForKey:@"value"]objectForKey:@"number"];
                        }
                    }
                    
                    if ((taskUri!=nil || projectUri!=nil) && [timeEntryProjectTaskAncestryDetailsArr count]>0)
                    {
                        for (NSDictionary *timeEntryProjectTaskAncestryDetailsDict in timeEntryProjectTaskAncestryDetailsArr)
                        {
                            NSString *matchUri=nil;
                            if (taskUri)
                            {
                                matchUri=taskUri;
                            }
                            else
                            {
                                matchUri=projectUri;
                            }
                            
                            if ([[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"uri"] isEqualToString:matchUri])
                            {
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"] isKindOfClass:[NSNull class]])
                                {
                                    clientUri=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"]objectForKey:@"uri"];
                                    clientName=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"]objectForKey:@"displayText"];
                                }
                                
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"] isKindOfClass:[NSNull class]])
                                {
                                    projectUri=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"]objectForKey:@"uri"];
                                    projectName=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"]objectForKey:@"displayText"];
                                }
                                
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"] isKindOfClass:[NSNull class]])
                                {
                                    if ([[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"]!=nil && ![[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"] isKindOfClass:[NSNull class]])
                                    {
                                        taskUri=[[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"]objectForKey:@"uri"];
                                        taskName=[[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"]objectForKey:@"displayText"];
                                    }
                                    
                                }
                                
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"] isKindOfClass:[NSNull class]])
                                {
                                    programUri=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"]objectForKey:@"uri"];
                                    programName=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"]objectForKey:@"displayText"];
                                }
                                
                                break;
                            }
                            
                        }
                    }
                    
                    
                    
                    
                    if (breakTimeEntryDict==nil)
                    {
                        workTimeEntryDict=[NSMutableDictionary dictionary];
                        if (comments)
                        {
                            [workTimeEntryDict setObject:comments forKey:@"comments"];
                        }
                        if (taskUri)
                        {
                            [workTimeEntryDict setObject:taskUri forKey:@"taskUri"];
                            if(taskName!=nil && ![taskName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:taskName forKey:@"taskName"];
                            }
                        }
                        if (billingUri)
                        {
                            [workTimeEntryDict setObject:billingUri forKey:@"billingUri"];
                            if(billingName!=nil && ![billingName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:billingName forKey:@"billingName"];
                            }
                        }
                        if (activityUri)
                        {
                            [workTimeEntryDict setObject:activityUri forKey:@"activityUri"];
                            if(activityName!=nil && ![activityName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:activityName forKey:@"activityName"];
                            }
                        }
                        if (projectUri)
                        {
                            [workTimeEntryDict setObject:projectUri forKey:@"projectUri"];
                            if(projectName!=nil && ![projectName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:projectName forKey:@"projectName"];
                            }
                        }
                        if (clientUri)
                        {
                            [workTimeEntryDict setObject:clientUri forKey:@"clientUri"];
                            if(clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:clientName forKey:@"clientName"];
                            }
                        }
                        if (programUri)
                        {
                            [workTimeEntryDict setObject:programUri forKey:@"programUri"];
                            if(programName!=nil && ![programName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:programName forKey:@"programName"];
                            }
                        }
                        if (rowNumber)
                        {
                            [workTimeEntryDict setObject:rowNumber forKey:@"rowNumber"];
                        }
                        
                        [workTimeEntryDict setObject:[newDict objectForKey:@"entryDate"] forKey:@"entryDate"];
                        
                        NSDictionary *intervalDict=[newDict objectForKey:@"interval"];
                        if (intervalDict!=nil && ![intervalDict isKindOfClass:[NSNull class]])
                        {
                            if ([intervalDict objectForKey:@"hours"]!=nil && ![[intervalDict objectForKey:@"hours"] isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:[intervalDict objectForKey:@"hours"] forKey:@"hours"];
                                
                            }
                            if ([intervalDict objectForKey:@"timePair"]!=nil && ![[intervalDict objectForKey:@"timePair"] isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:[intervalDict objectForKey:@"timePair"] forKey:@"timePair"];
                            }
                        }
                        
                        
                        
                        
                        [workTimeEntryDict setObject:[newDict objectForKey:@"uri"] forKey:@"uri"];
                        [workTimeEntryDict setObject:[newDict objectForKey:@"user"] forKey:@"user"];
                    }
                    
                    NSMutableDictionary *newUpdatedDict=[NSMutableDictionary dictionary];
                    if (breakTimeEntryDict)
                    {
                        [newUpdatedDict setValue:breakTimeEntryDict forKey:@"breakTimeEntry"];
                    }
                    else if (workTimeEntryDict)
                    {
                        [newUpdatedDict setValue:workTimeEntryDict forKey:@"workTimeEntry"];
                    }
                    
                    if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
                    {
                        NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
                        [newUpdatedDict setObject:entryDateDict forKey:@"entryDate"];
                    }
                    else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
                    {
                        NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
                        [newUpdatedDict setObject:entryDateDict forKey:@"entryDate"];
                    }
                    [array addObject:newUpdatedDict];
                }
                
                
                
            }
            
            for (NSDictionary *dateDict in timesheetperiodDatesArray)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", @"entryDate", dateDict];
                NSArray *filteredarray = [array filteredArrayUsingPredicate:predicate];
                BOOL isAnyEmptyRowEntryPresent=NO;
                for (NSDictionary *entryDict in filteredarray)
                {
                    NSDictionary *breakTimeEntryDict=[entryDict objectForKey:@"breakTimeEntry"];
                    NSDictionary *workTimeEntryDict=[entryDict objectForKey:@"workTimeEntry"];
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
                    {
                        NSDictionary *breakType=[breakTimeEntryDict objectForKey:@"breakType"];
                        NSString *comments=[breakTimeEntryDict objectForKey:@"comments"];
                        NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
                        NSDictionary *timePairDict=[breakTimeEntryDict objectForKey:@"timePair"];
                        NSString *uri=[breakTimeEntryDict objectForKey:@"uri"];
                        
                        if (timePairDict==nil||[timePairDict isKindOfClass:[NSNull class]]) {
                            isAnyEmptyRowEntryPresent=YES;
                        }
                        
                        if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                            comments=@"";
                        }
                        
                        NSString *inTimeString=@"";
                        NSString *outTimeString=@"";
                        BOOL isEmptyTimeEntry=NO;
                        if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
                        {
                            NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                            NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                            if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                            {
                                inTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:startTimeDict];
                            }
                            
                            if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                            {
                                outTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:endTimeDict];
                            }
                            
                        }
                        else
                        {
                            isEmptyTimeEntry=YES;
                            NSArray *array=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
                            NSString *approvalStatus=nil;
                            if ([array count]>0)
                            {
                                approvalStatus=[[array objectAtIndex:0] objectForKey:@"approvalStatus"];
                            }
                            if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
                            {
                                if ([approvalStatus isEqualToString:REJECTED_STATUS]||[approvalStatus isEqualToString:NOT_SUBMITTED_STATUS] || [format isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    isEmptyTimeEntry=NO;
                                }
                            }
                        }
                        
                        NSString *decimalHours=@"0.00";
                        if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
                        {
                            decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
                        }
                        
                        
                        NSString *breakName=[breakType objectForKey:@"text"];
                        if (breakName==nil||[breakName isKindOfClass:[NSNull class]]) {
                            breakName=@"";
                        }
                        NSString *breakUri=[breakType objectForKey:@"uri"];
                        if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]) {
                            breakUri=@"";
                        }
                        
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
                        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                        
                        
                        [dataDict setObject:uri forKey:@"rowUri"];
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:inTimeString forKey:@"time_in"];
                            [dataDict setObject:outTimeString forKey:@"time_out"];
                        }
                        [dataDict setObject:comments forKey:@"comments"];
                        [dataDict setObject:breakName forKey:@"breakName"];
                        [dataDict setObject:breakUri forKey:@"breakUri"];
                        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                        [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                        [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                        [dataDict setObject:format forKey:@"timesheetFormat"];
                        [dataDict setObject:uri forKey:@"timePunchesUri"];
                        [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        }
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:[Util getRandomGUID] forKey:@"clientPunchId"];
                        }
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        if (!isEmptyTimeEntry)
                        {
                            NSArray *expArr = [self getPendingTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                            if ([expArr count]>0)
                            {
                                NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                                [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                            }
                            else
                            {
                                NSArray *timeEntriesArr=[self getPendingTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                                
                                if ([timeEntriesArr count]>0)
                                {
                                    NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                                    [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                                }
                                else
                                {
                                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                                }
                                
                                
                            }
                        }
                        
                        
                        
                        
                    }
                    else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
                    {
                        NSString *comments=[workTimeEntryDict objectForKey:@"comments"];
                        
                        NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
                        NSDictionary *timePairDict=[workTimeEntryDict objectForKey:@"timePair"];
                        NSDictionary *hoursDict=[workTimeEntryDict objectForKey:@"hours"];
                        NSString *uri=[workTimeEntryDict objectForKey:@"uri"];
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
                        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                        
                        
                        
                        if (timePairDict==nil||[timePairDict isKindOfClass:[NSNull class]])
                        {
                            if (hoursDict==nil||[hoursDict isKindOfClass:[NSNull class]])
                            {
                                isAnyEmptyRowEntryPresent=YES;
                            }
                        }
                        if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                            comments=@"";
                        }
                        NSString *inTimeString=@"";
                        NSString *outTimeString=@"";
                        BOOL isEmptyTimeEntry=NO;
                        if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
                        {
                            NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                            NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                            if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                            {
                                inTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:startTimeDict];
                            }
                            
                            if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                            {
                                outTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:endTimeDict];
                            }
                            
                        }
                        else if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
                        {
                            // DO NOTHING HERE
                        }
                        else
                        {
                            isEmptyTimeEntry=YES;
                            NSArray *array=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
                            NSString *approvalStatus=nil;
                            if ([array count]>0)
                            {
                                approvalStatus=[[array objectAtIndex:0] objectForKey:@"approvalStatus"];
                            }
                            if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
                            {
                                if ([approvalStatus isEqualToString:REJECTED_STATUS]||[approvalStatus isEqualToString:NOT_SUBMITTED_STATUS] || [format isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    isEmptyTimeEntry=NO;
                                }
                            }
                            
                        }
                        
                        NSString *decimalHours=@"0.00";
                        if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
                        {
                            decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
                        }
                        else if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
                        {
                            NSNumber *hours=[Util convertApiTimeDictToDecimal:hoursDict];
                             [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTimeEntryValue"];
                            decimalHours=[NSString stringWithFormat:@"%f",[hours newFloatValue]];
                        }
                        
                        [dataDict setObject:uri forKey:@"rowUri"];
                        
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:inTimeString forKey:@"time_in"];
                            [dataDict setObject:outTimeString forKey:@"time_out"];
                        }
                        
                        
                        [dataDict setObject:inTimeString forKey:@"time_in"];
                        [dataDict setObject:outTimeString forKey:@"time_out"];
                        [dataDict setObject:comments forKey:@"comments"];
                        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                        [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                        [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                        [dataDict setObject:format forKey:@"timesheetFormat"];
                        [dataDict setObject:uri forKey:@"timePunchesUri"];
                        [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        }
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:[Util getRandomGUID] forKey:@"clientPunchId"];
                        }
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        
                        if ([workTimeEntryDict objectForKey:@"projectUri"] !=nil && ![[workTimeEntryDict objectForKey:@"projectUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"projectUri"] forKey:@"projectUri"];
                            if ([workTimeEntryDict objectForKey:@"projectName"] !=nil && ![[workTimeEntryDict objectForKey:@"projectName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"projectName"] forKey:@"projectName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"clientUri"] !=nil && ![[workTimeEntryDict objectForKey:@"clientUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"clientUri"] forKey:@"clientUri"];
                            if ([workTimeEntryDict objectForKey:@"clientName"] !=nil && ![[workTimeEntryDict objectForKey:@"clientName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"clientName"] forKey:@"clientName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"programUri"] !=nil && ![[workTimeEntryDict objectForKey:@"programUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"programUri"] forKey:@"programUri"];
                            if ([workTimeEntryDict objectForKey:@"programName"] !=nil && ![[workTimeEntryDict objectForKey:@"programName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"programName"] forKey:@"programName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"activityUri"] !=nil && ![[workTimeEntryDict objectForKey:@"activityUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"activityUri"] forKey:@"activityUri"];
                            if ([workTimeEntryDict objectForKey:@"activityName"] !=nil && ![[workTimeEntryDict objectForKey:@"activityName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"activityName"] forKey:@"activityName"];
                            }
                            
                        }
                        
                        if ([workTimeEntryDict objectForKey:@"taskUri"] !=nil && ![[workTimeEntryDict objectForKey:@"taskUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"taskUri"] forKey:@"taskUri"];
                            if ([workTimeEntryDict objectForKey:@"taskName"] !=nil && ![[workTimeEntryDict objectForKey:@"taskName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"taskName"] forKey:@"taskName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"billingUri"] !=nil && ![[workTimeEntryDict objectForKey:@"billingUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"billingUri"] forKey:@"billingUri"];
                            if ([workTimeEntryDict objectForKey:@"billingName"] !=nil && ![[workTimeEntryDict objectForKey:@"billingName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"billingName"] forKey:@"billingName"];
                            }
                        }
                        if ([workTimeEntryDict objectForKey:@"rowNumber"] !=nil && ![[workTimeEntryDict objectForKey:@"rowNumber"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"rowNumber"] forKey:@"rowNumber"];
                        }
                        
                        if (!isEmptyTimeEntry)
                        {
                            NSArray *expArr = [self getPendingTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                            if ([expArr count]>0)
                            {
                                NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                                [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                            }
                            else
                            {
                                // THIS IS MOVED OUT OF SCOPE FOR CURRENT REQUIREMENT
                                //                        NSArray *timeEntriesArr=[self getTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                                //
                                //                        if ([timeEntriesArr count]>0)
                                //                        {
                                //                            NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                                //                            [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                                //                        }
                                //                        else
                                //                        {
                                [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                                //                        }
                            }
                        }
                        
                        
                        
                        
                    }
                }
                if (isAnyEmptyRowEntryPresent==NO && ![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    NSDate *entryDate=[Util convertApiDateDictToDateFormat:dateDict];
                    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                    NSString *inTimeString=@"";
                    NSString *outTimeString=@"";
                    NSString *comments=@"";
                    NSString *decimalHours=@"0.00";
                    
                    NSString *uniqueEntryId=[Util getRandomGUID];
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    [dataDict setObject:uniqueEntryId forKey:@"rowUri"];
                    [dataDict setObject:inTimeString forKey:@"time_in"];
                    [dataDict setObject:outTimeString forKey:@"time_out"];
                    [dataDict setObject:comments forKey:@"comments"];
                    [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                    [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                    [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                    if ([format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        [dataDict setObject:GEN4_EXT_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                    }
                    else
                    {
                        [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                    }
                    [dataDict setObject:@"" forKey:@"timePunchesUri"];
                    [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                    }
                    [dataDict setObject:uniqueEntryId forKey:@"clientPunchId"];
                    [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                    [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                    //   [self updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
                }
                
                
                
            }

        }
        
        
        
    }
    
    
    
}

-(void)savePreviousTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr
{
    NSMutableArray *enableWidgetsArr=[self getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    BOOL isHybridTimesheet=NO;
    BOOL hasStandardWidget=NO;
    BOOL hasInOutWidget=NO;
    BOOL hasExtInOutWidget=NO;
    BOOL hasPunchWidget=NO;
    
    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            hasStandardWidget=YES;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            hasInOutWidget=YES;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            hasExtInOutWidget=YES;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            hasPunchWidget=YES;
            
        }
    }
    
    if (hasInOutWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }

    if (hasExtInOutWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }
    
    if (hasPunchWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }

    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        NSString *format=@"";
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            format=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            format=GEN4_INOUT_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            format=GEN4_EXT_INOUT_TIMESHEET;

        }
       
        if ([format isEqualToString:GEN4_STANDARD_TIMESHEET] || [format isEqualToString:GEN4_INOUT_TIMESHEET] || [format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
        {
            SQLiteDB *myDB = [SQLiteDB getInstance];
            NSArray *timeSheetsInfoArr=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
            NSDictionary *timesheetInfoDict=[timeSheetsInfoArr objectAtIndex:0];
            NSDate *startDate = [Util convertTimestampFromDBToDate:[[timesheetInfoDict objectForKey:@"startDate"] stringValue]];
            NSDate *endDate = [Util convertTimestampFromDBToDate:[[timesheetInfoDict objectForKey:@"endDate"] stringValue]];
            
            NSMutableArray *timesheetperiodDatesArray=[NSMutableArray array];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            gregorianCalendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDateComponents *days = [[NSDateComponents alloc] init];
            [timesheetperiodDatesArray addObject:[Util convertDateToApiDateDictionary:startDate]];
            NSInteger dayCount = 0;
            while ( TRUE ) {
                [days setDay: ++dayCount];
                NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate:startDate options: 0];
                if ( [date compare: endDate] == NSOrderedDescending )
                    break;
                [timesheetperiodDatesArray addObject:[Util convertDateToApiDateDictionary:date]];
            }
            
            
            
            NSMutableArray *array=[NSMutableArray array];
            for (int j=0; j<[widgetTimeEntriesArr count]; j++) {
                NSMutableDictionary *newDict=[widgetTimeEntriesArr objectAtIndex:j];
                
                NSMutableArray *timeAllocationTypeUrisArr=[newDict objectForKey:@"timeAllocationTypeUris"];
                BOOL isContinue=YES;
                if (isHybridTimesheet && [format isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    if ([timeAllocationTypeUrisArr count]==1 && [timeAllocationTypeUrisArr containsObject:@"urn:replicon:time-allocation-type:project"])
                    {
                        isContinue=YES;
                    }
                    else
                    {
                        isContinue=NO;
                    }
                }
                if (isHybridTimesheet && [format isEqualToString:GEN4_INOUT_TIMESHEET])
                {
                    if ([timeAllocationTypeUrisArr count]==1 && [timeAllocationTypeUrisArr containsObject:@"urn:replicon:time-allocation-type:attendance"])
                    {
                        isContinue=YES;
                    }
                    else
                    {
                        isContinue=NO;
                    }
                }

                if (isHybridTimesheet && [format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    if ([timeAllocationTypeUrisArr count]==1 && [timeAllocationTypeUrisArr containsObject:@"urn:replicon:time-allocation-type:attendance"])
                    {
                        isContinue=YES;
                    }
                    else
                    {
                        isContinue=NO;
                    }
                }

                if (isContinue)
                {
                    SQLiteDB *myDB = [SQLiteDB getInstance];
                    [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:[NSString stringWithFormat:@"timesheetUri='%@' and timeEntryUri='%@'",timesheetUri,newDict[@"uri"]] inDatabase:@""];
                    NSArray *cellOEFDataArr=[newDict objectForKey:@"extensionFieldValues"];
                    for (NSDictionary *cellOEFDict in cellOEFDataArr)
                    {
                        NSMutableDictionary *cellOEFDataDict=[NSMutableDictionary dictionary];
                        [cellOEFDataDict setObject:newDict[@"uri"] forKey:@"timeEntryUri"];
                        [cellOEFDataDict setObject:cellOEFDict[@"definition"][@"uri"] forKey:@"uri"];
                        [cellOEFDataDict setObject:cellOEFDict[@"definition"][@"definitionTypeUri"] forKey:@"definitionTypeUri"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        }
                        if (cellOEFDict[@"numericValue"]!=nil && ![cellOEFDict[@"numericValue"] isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:cellOEFDict[@"numericValue"] forKey:@"numericValue"];
                        }
                        else if (cellOEFDict[@"textValue"]!=nil && ![cellOEFDict[@"textValue"] isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:cellOEFDict[@"textValue"] forKey:@"textValue"];
                        }
                        else if (cellOEFDict[@"tag"]!=nil && ![cellOEFDict[@"tag"] isKindOfClass:[NSNull class]])
                        {
                            [cellOEFDataDict setObject:cellOEFDict[@"tag"][@"displayText"] forKey:@"dropdownOptionValue"];
                            [cellOEFDataDict setObject:cellOEFDict[@"tag"][@"uri"] forKey:@"dropdownOptionUri"];
                        }


                        [myDB insertIntoTable:timeEntriesObjectExtensionFieldsTable data:cellOEFDataDict intoDatabase:@""];
                        
                        
                    }

                    NSMutableArray *customMetaDataArr=[newDict objectForKey:@"customMetadata"];
                    NSMutableDictionary *breakTimeEntryDict=nil;
                    NSMutableDictionary *workTimeEntryDict=nil;
                    NSString *comments=nil;
                    NSString *taskName=nil;
                    NSString *taskUri=nil;
                    NSString *billingName=nil;
                    NSString *billingUri=nil;
                    NSString *activityName=@"";
                    NSString *activityUri=nil;
                    NSString *projectName=nil;
                    NSString *projectUri=nil;
                    NSString *clientName=nil;
                    NSString *clientUri=nil;
                    NSString *programName=nil;
                    NSString *programUri=nil;
                    NSString *rowNumber=[Util getRandomGUID];
                    
                    for (NSDictionary *customMetaDict in customMetaDataArr)
                    {
                        NSString *keyUri=[customMetaDict objectForKey:@"keyUri"];
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:break-type"])
                        {
                            breakTimeEntryDict=[NSMutableDictionary dictionary];
                            [breakTimeEntryDict setObject:[customMetaDict objectForKey:@"value"] forKey:@"breakType"];
                            [breakTimeEntryDict setObject:[newDict objectForKey:@"entryDate"] forKey:@"entryDate"];
                            
                            NSDictionary *intervalDict=[newDict objectForKey:@"interval"];
                            if (intervalDict!=nil && ![intervalDict isKindOfClass:[NSNull class]])
                            {
                                if ([intervalDict objectForKey:@"hours"]!=nil && ![[intervalDict objectForKey:@"hours"] isKindOfClass:[NSNull class]])
                                {
                                    [breakTimeEntryDict setObject:[intervalDict objectForKey:@"hours"] forKey:@"hours"];
                                    
                                }
                                if ([intervalDict objectForKey:@"timePair"]!=nil && ![[intervalDict objectForKey:@"timePair"] isKindOfClass:[NSNull class]])
                                {
                                    [breakTimeEntryDict setObject:[intervalDict objectForKey:@"timePair"] forKey:@"timePair"];
                                }
                            }
                            
                            
                            [breakTimeEntryDict setObject:[newDict objectForKey:@"uri"] forKey:@"uri"];
                            [breakTimeEntryDict setObject:[newDict objectForKey:@"user"] forKey:@"user"];
                            break;
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:comments"])
                        {
                            comments=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:task"])
                        {
                            taskUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:billing-rate"])
                        {
                            billingUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                            billingName=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:activity"])
                        {
                            activityUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                            activityName=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:project"])
                        {
                            projectUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                        }
                        if ([keyUri isEqualToString:@"urn:replicon:widget-ui-metadata-key:row-number"])
                        {
                            rowNumber=[[customMetaDict objectForKey:@"value"]objectForKey:@"number"];
                        }
                    }
                    
                    if ((taskUri!=nil || projectUri!=nil) && [timeEntryProjectTaskAncestryDetailsArr count]>0)
                    {
                        for (NSDictionary *timeEntryProjectTaskAncestryDetailsDict in timeEntryProjectTaskAncestryDetailsArr)
                        {
                            NSString *matchUri=nil;
                            if (taskUri)
                            {
                                matchUri=taskUri;
                            }
                            else
                            {
                                matchUri=projectUri;
                            }
                            
                            if ([[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"uri"] isEqualToString:matchUri])
                            {
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"] isKindOfClass:[NSNull class]])
                                {
                                    clientUri=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"]objectForKey:@"uri"];
                                    clientName=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"client"]objectForKey:@"displayText"];
                                }
                                
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"] isKindOfClass:[NSNull class]])
                                {
                                    projectUri=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"]objectForKey:@"uri"];
                                    projectName=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"project"]objectForKey:@"displayText"];
                                }
                                
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"] isKindOfClass:[NSNull class]])
                                {
                                    if ([[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"]!=nil && ![[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"] isKindOfClass:[NSNull class]])
                                    {
                                        taskUri=[[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"]objectForKey:@"uri"];
                                        taskName=[[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"taskAncestry"]objectForKey:@"task"]objectForKey:@"displayText"];
                                    }
                                    
                                }
                                
                                if ([timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"]!=nil && ![[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"] isKindOfClass:[NSNull class]])
                                {
                                    programUri=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"]objectForKey:@"uri"];
                                    programName=[[timeEntryProjectTaskAncestryDetailsDict objectForKey:@"program"]objectForKey:@"displayText"];
                                }
                                
                                break;
                            }
                            
                        }
                    }
                    
                    
                    
                    
                    if (breakTimeEntryDict==nil)
                    {
                        workTimeEntryDict=[NSMutableDictionary dictionary];
                        if (comments)
                        {
                            [workTimeEntryDict setObject:comments forKey:@"comments"];
                        }
                        if (taskUri)
                        {
                            [workTimeEntryDict setObject:taskUri forKey:@"taskUri"];
                            if(taskName!=nil && ![taskName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:taskName forKey:@"taskName"];
                            }
                        }
                        if (billingUri)
                        {
                            [workTimeEntryDict setObject:billingUri forKey:@"billingUri"];
                            if(billingName!=nil && ![billingName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:billingName forKey:@"billingName"];
                            }
                        }
                        if (activityUri)
                        {
                            [workTimeEntryDict setObject:activityUri forKey:@"activityUri"];
                            if(activityName!=nil && ![activityName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:activityName forKey:@"activityName"];
                            }
                        }
                        if (projectUri)
                        {
                            [workTimeEntryDict setObject:projectUri forKey:@"projectUri"];
                            if(projectName!=nil && ![projectName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:projectName forKey:@"projectName"];
                            }
                        }
                        if (clientUri)
                        {
                            [workTimeEntryDict setObject:clientUri forKey:@"clientUri"];
                            if(clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:clientName forKey:@"clientName"];
                            }
                        }
                        if (programUri)
                        {
                            [workTimeEntryDict setObject:programUri forKey:@"programUri"];
                            if(programName!=nil && ![programName isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:programName forKey:@"programName"];
                            }
                        }
                        if (rowNumber)
                        {
                            [workTimeEntryDict setObject:rowNumber forKey:@"rowNumber"];
                        }
                        
                        [workTimeEntryDict setObject:[newDict objectForKey:@"entryDate"] forKey:@"entryDate"];
                        
                        NSDictionary *intervalDict=[newDict objectForKey:@"interval"];
                        if (intervalDict!=nil && ![intervalDict isKindOfClass:[NSNull class]])
                        {
                            if ([intervalDict objectForKey:@"hours"]!=nil && ![[intervalDict objectForKey:@"hours"] isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:[intervalDict objectForKey:@"hours"] forKey:@"hours"];
                                
                            }
                            if ([intervalDict objectForKey:@"timePair"]!=nil && ![[intervalDict objectForKey:@"timePair"] isKindOfClass:[NSNull class]])
                            {
                                [workTimeEntryDict setObject:[intervalDict objectForKey:@"timePair"] forKey:@"timePair"];
                            }
                        }
                        
                        
                        
                        
                        [workTimeEntryDict setObject:[newDict objectForKey:@"uri"] forKey:@"uri"];
                        [workTimeEntryDict setObject:[newDict objectForKey:@"user"] forKey:@"user"];
                    }
                    
                    NSMutableDictionary *newUpdatedDict=[NSMutableDictionary dictionary];
                    if (breakTimeEntryDict)
                    {
                        [newUpdatedDict setValue:breakTimeEntryDict forKey:@"breakTimeEntry"];
                    }
                    else if (workTimeEntryDict)
                    {
                        [newUpdatedDict setValue:workTimeEntryDict forKey:@"workTimeEntry"];
                    }
                    
                    if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
                    {
                        NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
                        [newUpdatedDict setObject:entryDateDict forKey:@"entryDate"];
                    }
                    else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
                    {
                        NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
                        [newUpdatedDict setObject:entryDateDict forKey:@"entryDate"];
                    }
                    [array addObject:newUpdatedDict];
                }
                
               
                
            }
            
            for (NSDictionary *dateDict in timesheetperiodDatesArray)
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", @"entryDate", dateDict];
                NSArray *filteredarray = [array filteredArrayUsingPredicate:predicate];
                BOOL isAnyEmptyRowEntryPresent=NO;
                for (NSDictionary *entryDict in filteredarray)
                {
                    NSDictionary *breakTimeEntryDict=[entryDict objectForKey:@"breakTimeEntry"];
                    NSDictionary *workTimeEntryDict=[entryDict objectForKey:@"workTimeEntry"];
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
                    {
                        NSDictionary *breakType=[breakTimeEntryDict objectForKey:@"breakType"];
                        NSString *comments=[breakTimeEntryDict objectForKey:@"comments"];
                        NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
                        NSDictionary *timePairDict=[breakTimeEntryDict objectForKey:@"timePair"];
                        NSString *uri=[breakTimeEntryDict objectForKey:@"uri"];
                        
                        if (timePairDict==nil||[timePairDict isKindOfClass:[NSNull class]]) {
                            isAnyEmptyRowEntryPresent=YES;
                        }
                        
                        if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                            comments=@"";
                        }
                        
                        NSString *inTimeString=@"";
                        NSString *outTimeString=@"";
                        BOOL isEmptyTimeEntry=NO;
                        if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
                        {
                            NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                            NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                            if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                            {
                                inTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:startTimeDict];
                            }
                            
                            if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                            {
                                outTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:endTimeDict];
                            }
                            
                        }
                        else
                        {
                            isEmptyTimeEntry=YES;
                            NSArray *array=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
                            NSString *approvalStatus=nil;
                            if ([array count]>0)
                            {
                                approvalStatus=[[array objectAtIndex:0] objectForKey:@"approvalStatus"];
                            }
                            if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
                            {
                                if ([approvalStatus isEqualToString:REJECTED_STATUS]||[approvalStatus isEqualToString:NOT_SUBMITTED_STATUS]|| [format isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    isEmptyTimeEntry=NO;
                                }
                            }
                        }
                        
                        NSString *decimalHours=@"0.00";
                        if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
                        {
                            decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
                        }
                        
                        
                        NSString *breakName=[breakType objectForKey:@"text"];
                        if (breakName==nil||[breakName isKindOfClass:[NSNull class]]) {
                            breakName=@"";
                        }
                        NSString *breakUri=[breakType objectForKey:@"uri"];
                        if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]) {
                            breakUri=@"";
                        }
                        
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
                        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                        
                        
                        [dataDict setObject:uri forKey:@"rowUri"];
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:inTimeString forKey:@"time_in"];
                            [dataDict setObject:outTimeString forKey:@"time_out"];
                        }
                        [dataDict setObject:comments forKey:@"comments"];
                        [dataDict setObject:breakName forKey:@"breakName"];
                        [dataDict setObject:breakUri forKey:@"breakUri"];
                        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                        [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                        [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                        [dataDict setObject:format forKey:@"timesheetFormat"];
                        [dataDict setObject:uri forKey:@"timePunchesUri"];
                        [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        }
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:[Util getRandomGUID] forKey:@"clientPunchId"];
                        }
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        if (!isEmptyTimeEntry)
                        {
                            NSArray *expArr = [self getPreviousTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                            if ([expArr count]>0)
                            {
                                NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                                [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                            }
                            else
                            {
                                NSArray *timeEntriesArr=[self getPreviousTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                                
                                if ([timeEntriesArr count]>0)
                                {
                                    NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                                    [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                                }
                                else
                                {
                                    [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                                }
                                
                                
                            }
                        }
                        
                        
                        
                        
                    }
                    else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
                    {
                        NSString *comments=[workTimeEntryDict objectForKey:@"comments"];
                        
                        NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
                        NSDictionary *timePairDict=[workTimeEntryDict objectForKey:@"timePair"];
                        NSDictionary *hoursDict=[workTimeEntryDict objectForKey:@"hours"];
                        NSString *uri=[workTimeEntryDict objectForKey:@"uri"];
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
                        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                        
                        
                        
                        if (timePairDict==nil||[timePairDict isKindOfClass:[NSNull class]])
                        {
                            if (hoursDict==nil||[hoursDict isKindOfClass:[NSNull class]])
                            {
                                isAnyEmptyRowEntryPresent=YES;
                            }
                        }
                        if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                            comments=@"";
                        }
                        NSString *inTimeString=@"";
                        NSString *outTimeString=@"";
                        BOOL isEmptyTimeEntry=NO;
                        if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
                        {
                            NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                            NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                            if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                            {
                                inTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:startTimeDict];
                            }
                            
                            if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                            {
                                outTimeString=[Util convertApiTimeDictTo12HourTimeStringWithSeconds:endTimeDict];
                            }
                            
                        }
                        else if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
                        {
                            // DO NOTHING HERE
                        }
                        else
                        {
                            isEmptyTimeEntry=YES;
                            NSArray *array=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
                            NSString *approvalStatus=nil;
                            if ([array count]>0)
                            {
                                approvalStatus=[[array objectAtIndex:0] objectForKey:@"approvalStatus"];
                            }
                            if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
                            {
                                if ([approvalStatus isEqualToString:REJECTED_STATUS]||[approvalStatus isEqualToString:NOT_SUBMITTED_STATUS]|| [format isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    isEmptyTimeEntry=NO;
                                }
                            }
                            
                        }
                        
                        NSString *decimalHours=@"0.00";
                        if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
                        {
                            decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
                        }
                        else if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
                        {
                            NSNumber *hours=[Util convertApiTimeDictToDecimal:hoursDict];
                            [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTimeEntryValue"];
                            decimalHours=[NSString stringWithFormat:@"%f",[hours newFloatValue]];
                        }
                        
                        [dataDict setObject:uri forKey:@"rowUri"];
                        
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:inTimeString forKey:@"time_in"];
                            [dataDict setObject:outTimeString forKey:@"time_out"];
                        }
                        
                        
                        [dataDict setObject:inTimeString forKey:@"time_in"];
                        [dataDict setObject:outTimeString forKey:@"time_out"];
                        [dataDict setObject:comments forKey:@"comments"];
                        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                        [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                        [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                        [dataDict setObject:format forKey:@"timesheetFormat"];
                        [dataDict setObject:uri forKey:@"timePunchesUri"];
                        [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        }
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:[Util getRandomGUID] forKey:@"clientPunchId"];
                        }
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        
                        if ([workTimeEntryDict objectForKey:@"projectUri"] !=nil && ![[workTimeEntryDict objectForKey:@"projectUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"projectUri"] forKey:@"projectUri"];
                            if ([workTimeEntryDict objectForKey:@"projectName"] !=nil && ![[workTimeEntryDict objectForKey:@"projectName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"projectName"] forKey:@"projectName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"clientUri"] !=nil && ![[workTimeEntryDict objectForKey:@"clientUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"clientUri"] forKey:@"clientUri"];
                            if ([workTimeEntryDict objectForKey:@"clientName"] !=nil && ![[workTimeEntryDict objectForKey:@"clientName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"clientName"] forKey:@"clientName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"programUri"] !=nil && ![[workTimeEntryDict objectForKey:@"programUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"programUri"] forKey:@"programUri"];
                            if ([workTimeEntryDict objectForKey:@"programName"] !=nil && ![[workTimeEntryDict objectForKey:@"programName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"programName"] forKey:@"programName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"activityUri"] !=nil && ![[workTimeEntryDict objectForKey:@"activityUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"activityUri"] forKey:@"activityUri"];
                            if ([workTimeEntryDict objectForKey:@"activityName"] !=nil && ![[workTimeEntryDict objectForKey:@"activityName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"activityName"] forKey:@"activityName"];
                            }
                            
                        }
                        
                        if ([workTimeEntryDict objectForKey:@"taskUri"] !=nil && ![[workTimeEntryDict objectForKey:@"taskUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"taskUri"] forKey:@"taskUri"];
                            if ([workTimeEntryDict objectForKey:@"taskName"] !=nil && ![[workTimeEntryDict objectForKey:@"taskName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"taskName"] forKey:@"taskName"];
                            }
                            
                        }
                        if ([workTimeEntryDict objectForKey:@"billingUri"] !=nil && ![[workTimeEntryDict objectForKey:@"billingUri"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"billingUri"] forKey:@"billingUri"];
                            if ([workTimeEntryDict objectForKey:@"billingName"] !=nil && ![[workTimeEntryDict objectForKey:@"billingName"]  isKindOfClass:[NSNull class]]) {
                                [dataDict setObject:[workTimeEntryDict objectForKey:@"billingName"] forKey:@"billingName"];
                            }
                        }
                        if ([workTimeEntryDict objectForKey:@"rowNumber"] !=nil && ![[workTimeEntryDict objectForKey:@"rowNumber"]isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:[workTimeEntryDict objectForKey:@"rowNumber"] forKey:@"rowNumber"];
                        }
                        
                        if (!isEmptyTimeEntry)
                        {
                            NSArray *expArr = [self getPreviousTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                            if ([expArr count]>0)
                            {
                                NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                                [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                            }
                            else
                            {
                                // THIS IS MOVED OUT OF SCOPE FOR CURRENT REQUIREMENT
                                //                        NSArray *timeEntriesArr=[self getTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                                //
                                //                        if ([timeEntriesArr count]>0)
                                //                        {
                                //                            NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                                //                            [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                                //                        }
                                //                        else
                                //                        {
                                [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                                //                        }
                            }
                        }
                        
                        
                        
                        
                    }
                }
                if (isAnyEmptyRowEntryPresent==NO && ![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    NSDate *entryDate=[Util convertApiDateDictToDateFormat:dateDict];
                    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                    NSString *inTimeString=@"";
                    NSString *outTimeString=@"";
                    NSString *comments=@"";
                    NSString *decimalHours=@"0.00";
                    
                    NSString *uniqueEntryId=[Util getRandomGUID];
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    [dataDict setObject:uniqueEntryId forKey:@"rowUri"];
                    [dataDict setObject:inTimeString forKey:@"time_in"];
                    [dataDict setObject:outTimeString forKey:@"time_out"];
                    [dataDict setObject:comments forKey:@"comments"];
                    [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                    [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                    [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                    if ([format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        [dataDict setObject:GEN4_EXT_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                    }
                    else
                    {
                        [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                    }
                    [dataDict setObject:@"" forKey:@"timePunchesUri"];
                    [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                    }
                    [dataDict setObject:uniqueEntryId forKey:@"clientPunchId"];
                    [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                    [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                    //   [self updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
                }
                
                
                
            }

        }
        
        
    }
    
   
    
    
    
}

//Implemented as per TIME-495//JUHI
-(void)savePreviousTimesheetTimeOffSummaryDataFromApiToDBForGen4:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri
{
   
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSMutableArray *enableWidgetsArr=[self getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    
    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        NSString *timesheetFormat=@"";
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            timesheetFormat=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            timesheetFormat=GEN4_INOUT_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            timesheetFormat=GEN4_EXT_INOUT_TIMESHEET;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            timesheetFormat=GEN4_PUNCH_WIDGET_TIMESHEET;
            
        }
        
        if (![timesheetFormat isEqualToString:@""])
        {
            for (int k=0; k<[timeOffsArr count ]; k++)
            {
                NSDictionary *dict=[timeOffsArr objectAtIndex:k];

                NSString *timeOffUri=nil;
                NSString *timeOffName=nil;
                NSString *rowUri=nil;
                NSString *comments=@"";
                
                if ([dict objectForKey:@"timeOffType"]!=nil)
                {
                    timeOffUri=[[dict objectForKey:@"timeOffType"] objectForKey:@"uri"];
                    timeOffName=[[dict objectForKey:@"timeOffType"] objectForKey:@"name"];
                    
                }
                if ([dict objectForKey:@"uri"]!=nil)
                {
                    rowUri=[dict objectForKey:@"uri"];
                }
                
                if ([dict objectForKey:@"comments"] != nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]]
                    &&[[dict objectForKey:@"comments"] isKindOfClass:[NSString class]]) {
                    comments=[dict objectForKey:@"comments"];
                }
                
                if ([dict objectForKey:@"entries"] != nil && ![[dict objectForKey:@"entries"] isKindOfClass:[NSNull class]])
                {
                    NSArray *timeOffEntries=[dict objectForKey:@"entries"];
                    NSString *rowNumber=[Util getRandomGUID];
                    for (NSDictionary *timeOffEntryDict in timeOffEntries)
                    {
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:[timeOffEntryDict objectForKey:@"entryDate"]];
                        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                        
                        NSDictionary *totalTimeDurationDict=[timeOffEntryDict objectForKey:@"duration"];
                        NSNumber *totalTimeInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                        NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                        
                        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                        [dataDict setObject:totalTimeInDecimalFormat forKey:@"durationDecimalFormat"];
                        [dataDict setObject:totalTimeHoursInHourFormat forKey:@"durationHourFormat"];
                        [dataDict setObject:comments forKey:@"comments"];
                        [dataDict setObject:timeOffName forKey:@"timeOffTypeName"];
                        [dataDict setObject:timeOffUri forKey:@"timeOffUri"];
                        [dataDict setObject:Time_Off_Key forKey:@"entryType"];
                        [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                        [dataDict setObject:rowUri forKey:@"rowUri"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
                        }
                        [dataDict setObject:timesheetFormat forKey:@"timesheetFormat"];
                        [dataDict setObject:@"" forKey:@"time_in"];
                        [dataDict setObject:@"" forKey:@"time_out"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        [dataDict setObject:rowNumber forKey:@"rowNumber"];
                        
                        NSArray *expArr = [self getPreviousTimesheetTimeOffInfoForRowUri:rowUri timesheetUri:timesheetUri andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
                        if ([expArr count]>0)
                        {
                            NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",rowUri,dataDict];
                            [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                        }
                        else
                        {
                            [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                        }
                    }
                }
                
            }
        }
    }
    
    

}

-(void)savePendingTimesheetTimeOffSummaryDataFromApiToDBForGen4:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri
{
  
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSMutableArray *enableWidgetsArr=[self getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    
    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        NSString *timesheetFormat=@"";
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            timesheetFormat=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            timesheetFormat=GEN4_INOUT_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            timesheetFormat=GEN4_EXT_INOUT_TIMESHEET;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            timesheetFormat=GEN4_PUNCH_WIDGET_TIMESHEET;
            
        }
        
        if (![timesheetFormat isEqualToString:@""])
        {
            for (int k=0; k<[timeOffsArr count ]; k++)
            {
                NSDictionary *dict=[timeOffsArr objectAtIndex:k];
                
                
                
                NSString *timeOffUri=nil;
                NSString *timeOffName=nil;
                NSString *rowUri=nil;
                NSString *comments=@"";
                

                if ([dict objectForKey:@"timeOffType"]!=nil)
                {
                    timeOffUri=[[dict objectForKey:@"timeOffType"] objectForKey:@"uri"];
                    timeOffName=[[dict objectForKey:@"timeOffType"] objectForKey:@"name"];
                    
                }
                if ([dict objectForKey:@"uri"]!=nil)
                {
                    rowUri=[dict objectForKey:@"uri"];
                }
                
                if ([dict objectForKey:@"comments"] != nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]]
                    &&[[dict objectForKey:@"comments"] isKindOfClass:[NSString class]]) {
                    comments=[dict objectForKey:@"comments"];
                }
                
                if ([dict objectForKey:@"entries"] != nil && ![[dict objectForKey:@"entries"] isKindOfClass:[NSNull class]])
                {
                    NSArray *timeOffEntries=[dict objectForKey:@"entries"];
                    NSString *rowNumber=[Util getRandomGUID];
                    for (NSDictionary *timeOffEntryDict in timeOffEntries)
                    {
                        NSDate *entryDate=[Util convertApiDateDictToDateFormat:[timeOffEntryDict objectForKey:@"entryDate"]];
                        NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                        
                        NSDictionary *totalTimeDurationDict=[timeOffEntryDict objectForKey:@"duration"];
                        NSNumber *totalTimeInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                        NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];
                        
                        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                        [dataDict setObject:totalTimeInDecimalFormat forKey:@"durationDecimalFormat"];
                        [dataDict setObject:totalTimeHoursInHourFormat forKey:@"durationHourFormat"];
                        [dataDict setObject:comments forKey:@"comments"];
                        [dataDict setObject:timeOffName forKey:@"timeOffTypeName"];
                        [dataDict setObject:timeOffUri forKey:@"timeOffUri"];
                        [dataDict setObject:Time_Off_Key forKey:@"entryType"];
                        [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                        [dataDict setObject:rowUri forKey:@"rowUri"];
                        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                        {
                            [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
                        }
                        [dataDict setObject:timesheetFormat forKey:@"timesheetFormat"];
                        [dataDict setObject:@"" forKey:@"time_in"];
                        [dataDict setObject:@"" forKey:@"time_out"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        [dataDict setObject:rowNumber forKey:@"rowNumber"];
                        
                        NSArray *expArr = [self getPendingTimesheetTimeOffInfoForRowUri:rowUri timesheetUri:timesheetUri andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
                        if ([expArr count]>0)
                        {
                            NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",rowUri,entryDateToStore];
                            [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                        }
                        else
                        {
                            [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];
                        }
                    }
                }

            }
        }
    }
    

}

-(void)savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array isFromTimeoff:(BOOL)isFromTimeOff{
    [self savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:array dayOffList:nil isFromTimeoff:isFromTimeOff];
}


-(void)savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array dayOffList:(NSArray *)dayOffList isFromTimeoff:(BOOL)isFromTimeOff
{
    NSMutableArray *enableWidgetsArr=[self getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    
    
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:approvalPendingTimesheetsDaySummaryTable where:whereStr inDatabase:@""];
    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
        NSString *format=@"";
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            format=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            format=GEN4_INOUT_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            format=GEN4_EXT_INOUT_TIMESHEET;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            format=GEN4_PUNCH_WIDGET_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
        {
            format=GEN4_DAILY_WIDGET_TIMESHEET;

        }
        
        if (![format isEqualToString:@""])
        {
            NSArray *allEntries=(NSArray *)[self getAllPendingTimeEntriesForSheetFromDB:timesheetUri forTimeSheetFormat:format];
            NSArray *timesheetInfoArray=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
            float decimalTotalHours=0;
            float decimalTotalTimeoffHours=0;
            
            float regularstoreHours=0;
            
            if ([timesheetInfoArray count]>0)
            {
                NSDictionary *tsDict=[timesheetInfoArray objectAtIndex:0];
                NSString *endDateStr=[tsDict objectForKey:@"endDate"];
                NSString *startDateStr=[tsDict objectForKey:@"startDate"];
                NSDate *endDate=[Util convertTimestampFromDBToDate:endDateStr];
                NSDate *startDate=[Util convertTimestampFromDBToDate:startDateStr];
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                    fromDate:startDate
                                                                      toDate:endDate
                                                                     options:0];
                NSInteger timesheetPeriod=components.day;
                
                for (int i=0; i<=timesheetPeriod; i++)
                {
                    NSString *durationDecimal=nil;
                    NSString *durationHour=nil;
                    
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    NSDate *entryDate=[DateUtil getUtcDateByAddingDays:i toUtcDate:startDate];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timesheetEntryDate==%f)", [entryDate timeIntervalSince1970]];
                    NSArray *arr= [allEntries filteredArrayUsingPredicate:pred];
                    float decimalHours=0;
                    BOOL hasComments=NO;
                    for (int j=0; j<[arr count]; j++)
                    {
                        NSDictionary *dict=[arr objectAtIndex:j];
                        NSString *inTimeString=[dict objectForKey:@"time_in"];
                        NSString *outTimeString=[dict objectForKey:@"time_out"];
                        NSString *comments=[dict objectForKey:@"comments"];
                        NSString *breakUri=[dict objectForKey:@"breakUri"];
                        NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
                        NSString *durationDecimalFormatStr=[dict objectForKey:@"durationDecimalFormat"];
                        
                        
                        BOOL isBreak=NO;
                        if ( breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
                        {
                            isBreak=YES;
                        }
                        BOOL isTimeoff=NO;
                        if ( timeoffUri!=nil && ![timeoffUri isKindOfClass:[NSNull class]] && ![timeoffUri isEqualToString:@""])
                        {
                            isTimeoff=YES;
                        }
                        
                        if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""]  && ![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            if (!isBreak && !isTimeoff)
                            {
                                decimalHours=decimalHours+[[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString] newFloatValue];
                            }
                            
                        }
                        else
                        {
                            decimalHours=decimalHours+[durationDecimalFormatStr newFloatValue];
                        }
                        
                        if ( comments!=nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:@""])
                        {
                            hasComments=YES;
                        }
                        if ([dict objectForKey:@"timeOffTypeName"]!=nil && ![[dict objectForKey:@"timeOffTypeName"] isKindOfClass:[NSNull class]])
                        {
                            
                            durationDecimal=[dict objectForKey:@"durationDecimalFormat"];
                            durationHour=[dict objectForKey:@"durationHourFormat"];
                            decimalHours=decimalHours+[durationDecimal newFloatValue];
                            decimalTotalTimeoffHours=decimalTotalTimeoffHours+[durationDecimal newFloatValue];
                            
                            
                            
                        }
                        
                        
                    }
                    
                    regularstoreHours=regularstoreHours+decimalHours;
                    
                    NSString *storeHours=[NSString stringWithFormat:@"%.2f",decimalHours];
                    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                    }
                    //[dataDict setObject:@"" forKey:@"timesheetEntryUri"];
                    [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                    
                    //[dataDict setObject:[NSNull null] forKey:@"timesheetEntryTotalDurationHour"];
                    if (hasComments)
                    {
                        [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasComments"];
                    }
                    else
                    {
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"hasComments"];
                    }
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isHolidayDayOff"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isWeeklyDayOff"];
                    if (durationDecimal==nil)
                    {
                        [dataDict setObject:[NSNumber numberWithFloat:0.00] forKey:@"timeOffDurationDecimal"];
                    }
                    else
                    {
                        [dataDict setObject:durationDecimal forKey:@"timeOffDurationDecimal"];
                        [dataDict setObject:durationHour forKey:@"timeOffDurationHour"];
                    }
                    //[dataDict setObject:[NSNumber numberWithFloat:0.00] forKey:@"timeOffDurationDecimal"];
                    //[dataDict setObject:[NSNull null] forKey:@"timeOffDurationHour"];
                    
                    if ([format isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"timesheetEntryTotalDurationDecimal"];
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"workingTimeDurationDecimal"];
                    }
                    else if ([format isEqualToString:GEN4_INOUT_TIMESHEET] || [format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])

                    {
                        
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"totalInOutTimeDurationDecimal"];
                    }
                    else if ([format isEqualToString:GEN4_PUNCH_WIDGET_TIMESHEET])
                    {
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"totalPunchTimeDurationDecimal"];
                    }
                    
                    if(dayOffList.count > 0){
                        BOOL isDayOff = [DateHelper listOfDates:dayOffList contains:entryDate];
                        [dataDict setObject:[NSNumber numberWithBool:isDayOff] forKey:@"isDayOff"];
                    }
                    
                    //[dataDict setObject:[NSNull null] forKey:@"workingTimeDurationHour"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"noticeExplicitlyAccepted"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"availableTimeOffTypeCount"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isCommentsRequired"];
                    decimalTotalHours=decimalTotalHours+decimalHours;
                    
                    NSArray *tsDaySummaryRowArr=[self getTimesheetinfoForEntryDate:entryDateToStore andPending:TRUE andTimesheetUri:timesheetUri];
                    if ([tsDaySummaryRowArr count]>0)
                    {
                        [myDB updateTable:approvalPendingTimesheetsDaySummaryTable data:dataDict where:[NSString stringWithFormat:@"timesheetEntryDate = '%@'",entryDateToStore] intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPendingTimesheetsDaySummaryTable data:dataDict intoDatabase:@""];
                    }
                    
                    
                    
                }
                
                
            }
            
        BOOL isTimesheetEditStatus=[self getTimeSheetEditStatusForSheetFromDB:timesheetUri forTableName:approvalPendingTimesheetsTable];

            
            NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
            
            [timesheetDataDict setObject:[NSNumber numberWithInt:isTimesheetEditStatus]forKey:@"canEditTimesheet"];
            [timesheetDataDict setObject:format forKey:@"timesheetFormat"];
            if (!isFromTimeOff)
            {
                //            NSString *storeHoursTotal=[NSString stringWithFormat:@"%.2f",decimalTotalHours];
                //
                //            [timesheetDataDict setObject:[NSNumber numberWithFloat:[storeHoursTotal newFloatValue]] forKey:@"totalDurationDecimal"];
                //            NSMutableDictionary *totalDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:[NSString stringWithFormat:@"%f",decimalTotalHours]];
                //            [timesheetDataDict setObject:[NSString stringWithFormat:@"%@:%@",[totalDurationtimeDict objectForKey:@"hours"],[totalDurationtimeDict objectForKey:@"minutes"]] forKey:@"totalDurationHour"];
                //
                //            NSString *regularstoreWorksStr=[NSString stringWithFormat:@"%.2f",regularstoreHours];
                //
                //            [timesheetDataDict setObject:[NSNumber numberWithFloat:[regularstoreWorksStr newFloatValue]] forKey:@"regularDurationDecimal"];
                //
                //            NSMutableDictionary *regularDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:[NSString stringWithFormat:@"%f",regularstoreHours]];
                //            [timesheetDataDict setObject:[NSString stringWithFormat:@"%@:%@",[regularDurationtimeDict objectForKey:@"hours"],[regularDurationtimeDict objectForKey:@"minutes"]] forKey:@"regularDurationHour"];
                
                
                
            }
            else
            {
                //            NSString *storeHoursTotal=[NSString stringWithFormat:@"%.2f",decimalTotalTimeoffHours];
                //            NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
                //            [updateDict setObject:[NSString stringWithFormat:@"%.2f",[storeHoursTotal newFloatValue]] forKey:@"totalInOutTimeOffHours"];
                //            [self updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict andIsPending:TRUE];
                //            
                //            storeHoursTotal=[NSString stringWithFormat:@"%.2f",decimalTotalHours];
                //            [timesheetDataDict setObject:[NSNumber numberWithFloat:regularstoreHours] forKey:@"totalDurationDecimal"];
                //            NSMutableDictionary *totalDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:[NSString stringWithFormat:@"%f",decimalTotalHours]];
                //            [timesheetDataDict setObject:[NSString stringWithFormat:@"%@:%@",[totalDurationtimeDict objectForKey:@"hours"],[totalDurationtimeDict objectForKey:@"minutes"]] forKey:@"totalDurationHour"];
            }
            
            
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
            [myDB updateTable: approvalPendingTimesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
        }
      
        
       
    }
 
    
}

-(void)savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array isFromTimeoff:(BOOL)isFromTimeOff{
    [self savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:array dayOffList:nil isFromTimeoff:isFromTimeOff];
}

-(void)savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array dayOffList:(NSArray *)dayOffList isFromTimeoff:(BOOL)isFromTimeOff
{
    NSMutableArray *enableWidgetsArr=[self getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
   
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:approvalPreviousTimesheetsDaySummaryTable where:whereStr inDatabase:@""];
    
    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {
         NSString *format=@"";
        
        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            format=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            format=GEN4_EXT_INOUT_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            format=GEN4_EXT_INOUT_TIMESHEET;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            format=GEN4_PUNCH_WIDGET_TIMESHEET;
            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
        {
            format=GEN4_DAILY_WIDGET_TIMESHEET;

        }
        
        if (![format isEqualToString:@""])
        {
            NSArray *allEntries=(NSArray *)[self getAllPreviousTimeEntriesForSheetFromDB:timesheetUri forTimeSheetFormat:format];
            NSArray *timesheetInfoArray=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
            float decimalTotalHours=0;
            float decimalTotalTimeoffHours=0;
            
            float regularstoreHours=0;
            
            if ([timesheetInfoArray count]>0)
            {
                NSDictionary *tsDict=[timesheetInfoArray objectAtIndex:0];
                NSString *endDateStr=[tsDict objectForKey:@"endDate"];
                NSString *startDateStr=[tsDict objectForKey:@"startDate"];
                NSDate *endDate=[Util convertTimestampFromDBToDate:endDateStr];
                NSDate *startDate=[Util convertTimestampFromDBToDate:startDateStr];
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                    fromDate:startDate
                                                                      toDate:endDate
                                                                     options:0];
                NSInteger timesheetPeriod=components.day;
                
                for (int i=0; i<=timesheetPeriod; i++)
                {
                    NSString *durationDecimal=nil;
                    NSString *durationHour=nil;
                    
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    NSDate *entryDate=[DateUtil getUtcDateByAddingDays:i toUtcDate:startDate];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timesheetEntryDate==%f)", [entryDate timeIntervalSince1970]];
                    NSArray *arr= [allEntries filteredArrayUsingPredicate:pred];
                    float decimalHours=0;
                    BOOL hasComments=NO;
                    for (int j=0; j<[arr count]; j++)
                    {
                        NSDictionary *dict=[arr objectAtIndex:j];
                        NSString *inTimeString=[dict objectForKey:@"time_in"];
                        NSString *outTimeString=[dict objectForKey:@"time_out"];
                        NSString *comments=[dict objectForKey:@"comments"];
                        NSString *breakUri=[dict objectForKey:@"breakUri"];
                        NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
                        NSString *durationDecimalFormatStr=[dict objectForKey:@"durationDecimalFormat"];
                        
                        
                        BOOL isBreak=NO;
                        if ( breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
                        {
                            isBreak=YES;
                        }
                        BOOL isTimeoff=NO;
                        if ( timeoffUri!=nil && ![timeoffUri isKindOfClass:[NSNull class]] && ![timeoffUri isEqualToString:@""])
                        {
                            isTimeoff=YES;
                        }
                        
                        if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""]  && ![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            if (!isBreak && !isTimeoff)
                            {
                                decimalHours=decimalHours+[[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString] newFloatValue];
                            }
                            
                        }
                        else
                        {
                            decimalHours=decimalHours+[durationDecimalFormatStr newFloatValue];
                        }
                        
                        if ( comments!=nil && ![comments isKindOfClass:[NSNull class]] && ![comments isEqualToString:@""])
                        {
                            hasComments=YES;
                        }
                        if ([dict objectForKey:@"timeOffTypeName"]!=nil && ![[dict objectForKey:@"timeOffTypeName"] isKindOfClass:[NSNull class]])
                        {
                            
                            durationDecimal=[dict objectForKey:@"durationDecimalFormat"];
                            durationHour=[dict objectForKey:@"durationHourFormat"];
                            decimalHours=decimalHours+[durationDecimal newFloatValue];
                            decimalTotalTimeoffHours=decimalTotalTimeoffHours+[durationDecimal newFloatValue];
                            
                            
                            
                        }
                        
                        
                    }
                    
                    regularstoreHours=regularstoreHours+decimalHours;
                    
                    NSString *storeHours=[NSString stringWithFormat:@"%.2f",decimalHours];
                    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
                    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                    }
                    //[dataDict setObject:@"" forKey:@"timesheetEntryUri"];
                    [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                    
                    //[dataDict setObject:[NSNull null] forKey:@"timesheetEntryTotalDurationHour"];
                    if (hasComments)
                    {
                        [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasComments"];
                    }
                    else
                    {
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"hasComments"];
                    }
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isHolidayDayOff"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isWeeklyDayOff"];
                    if (durationDecimal==nil)
                    {
                        [dataDict setObject:[NSNumber numberWithFloat:0.00] forKey:@"timeOffDurationDecimal"];
                    }
                    else
                    {
                        [dataDict setObject:durationDecimal forKey:@"timeOffDurationDecimal"];
                        [dataDict setObject:durationHour forKey:@"timeOffDurationHour"];
                    }
                    //[dataDict setObject:[NSNumber numberWithFloat:0.00] forKey:@"timeOffDurationDecimal"];
                    //[dataDict setObject:[NSNull null] forKey:@"timeOffDurationHour"];
                    if ([format isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"timesheetEntryTotalDurationDecimal"];
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"workingTimeDurationDecimal"];
                    }
                    else if ([format isEqualToString:GEN4_INOUT_TIMESHEET] || [format isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"totalInOutTimeDurationDecimal"];
                    }
                    else if ([format isEqualToString:GEN4_PUNCH_WIDGET_TIMESHEET])
                    {
                        [dataDict setObject:[NSNumber numberWithFloat:[storeHours newFloatValue]] forKey:@"totalPunchTimeDurationDecimal"];
                    }
                    
                    if(dayOffList.count > 0){
                        BOOL isDayOff = [DateHelper listOfDates:dayOffList contains:entryDate];
                        [dataDict setObject:[NSNumber numberWithBool:isDayOff] forKey:@"isDayOff"];
                    }
                    
                    //[dataDict setObject:[NSNull null] forKey:@"workingTimeDurationHour"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"noticeExplicitlyAccepted"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"availableTimeOffTypeCount"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isCommentsRequired"];
                    decimalTotalHours=decimalTotalHours+decimalHours;
                    
                    NSArray *tsDaySummaryRowArr=[self getTimesheetinfoForEntryDate:entryDateToStore andPending:FALSE andTimesheetUri:timesheetUri];
                    if ([tsDaySummaryRowArr count]>0)
                    {
                        [myDB updateTable:approvalPreviousTimesheetsDaySummaryTable data:dataDict where:[NSString stringWithFormat:@"timesheetEntryDate = '%@'",entryDateToStore] intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPreviousTimesheetsDaySummaryTable data:dataDict intoDatabase:@""];
                    }
                    
                    
                }
                
                
            }
            
            BOOL isTimesheetEditStatus=[self getTimeSheetEditStatusForSheetFromDB:timesheetUri forTableName:approvalPreviousTimesheetsTable];


            NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
            [timesheetDataDict setObject:[NSNumber numberWithInt:1]forKey:@"overlappingTimeEntriesPermitted"];
            [timesheetDataDict setObject:[NSNumber numberWithInt:isTimesheetEditStatus]forKey:@"canEditTimesheet"];
            [timesheetDataDict setObject:format forKey:@"timesheetFormat"];
            if (!isFromTimeOff)
            {
                //            NSString *storeHoursTotal=[NSString stringWithFormat:@"%.2f",decimalTotalHours];
                //
                //            [timesheetDataDict setObject:[NSNumber numberWithFloat:[storeHoursTotal newFloatValue]] forKey:@"totalDurationDecimal"];
                //            NSMutableDictionary *totalDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:[NSString stringWithFormat:@"%f",decimalTotalHours]];
                //            [timesheetDataDict setObject:[NSString stringWithFormat:@"%@:%@",[totalDurationtimeDict objectForKey:@"hours"],[totalDurationtimeDict objectForKey:@"minutes"]] forKey:@"totalDurationHour"];
                //
                //            NSString *regularstoreWorksStr=[NSString stringWithFormat:@"%.2f",regularstoreHours];
                //
                //            [timesheetDataDict setObject:[NSNumber numberWithFloat:[regularstoreWorksStr newFloatValue]] forKey:@"regularDurationDecimal"];
                //
                //            NSMutableDictionary *regularDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:[NSString stringWithFormat:@"%f",regularstoreHours]];
                //            [timesheetDataDict setObject:[NSString stringWithFormat:@"%@:%@",[regularDurationtimeDict objectForKey:@"hours"],[regularDurationtimeDict objectForKey:@"minutes"]] forKey:@"regularDurationHour"];
                
                
                
            }
            else
            {
                //            NSString *storeHoursTotal=[NSString stringWithFormat:@"%.2f",decimalTotalTimeoffHours];
                //            NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
                //            [updateDict setObject:[NSString stringWithFormat:@"%.2f",[storeHoursTotal newFloatValue]] forKey:@"totalInOutTimeOffHours"];
                //            [self updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict andIsPending:FALSE];
                //            
                //            storeHoursTotal=[NSString stringWithFormat:@"%.2f",decimalTotalHours];
                //            [timesheetDataDict setObject:[NSNumber numberWithFloat:regularstoreHours] forKey:@"totalDurationDecimal"];
                //            NSMutableDictionary *totalDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:[NSString stringWithFormat:@"%f",decimalTotalHours]];
                //            [timesheetDataDict setObject:[NSString stringWithFormat:@"%@:%@",[totalDurationtimeDict objectForKey:@"hours"],[totalDurationtimeDict objectForKey:@"minutes"]] forKey:@"totalDurationHour"];
            }
            
            
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
            [myDB updateTable: approvalPreviousTimesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
        }
       
        
        
    }
    
    
}

-(void)saveObjectExtensionDetailsDataToDB:(NSDictionary *)oefDict andTimeSheetUri:(NSString *)timesheetUri andTimeSheetFormat:(NSString *)timesheetFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

    NSArray *oefArr = [self getObjectExtensionDetailsFromDBForOEFUri:oefDict[@"uri"] andTimesheetUri:timesheetUri andTimesheetFormat:timesheetFormat];
    if ([oefArr count]>0)
    {
        NSString *whereString=[NSString stringWithFormat:@"uri='%@'",oefDict[@"uri"]];
        [myDB updateTable:timesheetObjectExtensionFieldsTable data:oefDict where:whereString intoDatabase:@""];
    }
    else
    {
        [myDB insertIntoTable:timesheetObjectExtensionFieldsTable data:oefDict intoDatabase:@""];
    }
}

-(void)saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSArray *timeSheetsInfoArr=nil;
    if (isPending)
    {
        timeSheetsInfoArr=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
    }
    else
    {
        timeSheetsInfoArr=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
    }
    NSDictionary *timesheetInfoDict=[timeSheetsInfoArr objectAtIndex:0];
    NSDate *startDate = [Util convertTimestampFromDBToDate:[[timesheetInfoDict objectForKey:@"startDate"] stringValue]];
    NSDate *endDate = [Util convertTimestampFromDBToDate:[[timesheetInfoDict objectForKey:@"endDate"] stringValue]];

    NSMutableArray *timesheetperiodDatesArray=[NSMutableArray array];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    gregorianCalendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateComponents *days = [[NSDateComponents alloc] init];
    [timesheetperiodDatesArray addObject:[Util convertDateToApiDateDictionary:startDate]];
    NSInteger dayCount = 0;
    while ( TRUE ) {
        [days setDay: ++dayCount];
        NSDate *date = [gregorianCalendar dateByAddingComponents: days toDate:startDate options: 0];
        if ( [date compare: endDate] == NSOrderedDescending )
            break;
        [timesheetperiodDatesArray addObject:[Util convertDateToApiDateDictionary:date]];
    }

    NSMutableArray *array=[NSMutableArray array];

    if(widgetTimeEntriesArr != nil && ![widgetTimeEntriesArr isKindOfClass:[NSNull class]])
    {
        for (int j=0; j<[widgetTimeEntriesArr count]; j++)
        {
            NSMutableDictionary *newDict=[widgetTimeEntriesArr objectAtIndex:j];
            SQLiteDB *myDB = [SQLiteDB getInstance];
            [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:[NSString stringWithFormat:@"timesheetUri='%@' and timeEntryUri='%@'",timesheetUri,newDict[@"uri"]] inDatabase:@""];
            NSArray *cellOEFDataArr=[newDict objectForKey:@"extensionFieldValues"];
            for (NSDictionary *cellOEFDict in cellOEFDataArr)
            {
                NSMutableDictionary *cellOEFDataDict=[NSMutableDictionary dictionary];
                [cellOEFDataDict setObject:newDict[@"uri"] forKey:@"timeEntryUri"];
                [cellOEFDataDict setObject:cellOEFDict[@"definition"][@"uri"] forKey:@"uri"];
                [cellOEFDataDict setObject:cellOEFDict[@"definition"][@"definitionTypeUri"] forKey:@"definitionTypeUri"];
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [cellOEFDataDict setObject:timesheetUri forKey:@"timesheetUri"];
                }
                if (cellOEFDict[@"numericValue"]!=nil && ![cellOEFDict[@"numericValue"] isKindOfClass:[NSNull class]])
                {
                    [cellOEFDataDict setObject:cellOEFDict[@"numericValue"] forKey:@"numericValue"];
                }
                else if (cellOEFDict[@"textValue"]!=nil && ![cellOEFDict[@"textValue"] isKindOfClass:[NSNull class]])
                {
                    [cellOEFDataDict setObject:cellOEFDict[@"textValue"] forKey:@"textValue"];
                }
                else if (cellOEFDict[@"tag"]!=nil && ![cellOEFDict[@"tag"] isKindOfClass:[NSNull class]])
                {
                    [cellOEFDataDict setObject:cellOEFDict[@"tag"][@"displayText"] forKey:@"dropdownOptionValue"];
                    [cellOEFDataDict setObject:cellOEFDict[@"tag"][@"uri"] forKey:@"dropdownOptionUri"];
                }


                [myDB insertIntoTable:timeEntriesObjectExtensionFieldsTable data:cellOEFDataDict intoDatabase:@""];

                NSMutableArray *customMetaDataArr=[newDict objectForKey:@"customMetadata"];
                NSMutableDictionary *breakTimeEntryDict=nil;
                NSMutableDictionary *workTimeEntryDict=nil;
                NSString *comments=nil;
                NSString *taskName=nil;
                NSString *taskUri=nil;
                NSString *billingName=nil;
                NSString *billingUri=nil;
                NSString *activityName=@"";
                NSString *activityUri=nil;
                NSString *projectName=nil;
                NSString *projectUri=nil;
                NSString *clientName=nil;
                NSString *clientUri=nil;
                NSString *programName=nil;
                NSString *programUri=nil;
                NSString *rowNumber=[Util getRandomGUID];

                for (NSDictionary *customMetaDict in customMetaDataArr)
                {
                    NSString *keyUri=[customMetaDict objectForKey:@"keyUri"];
                    if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:break-type"])
                    {
                        breakTimeEntryDict=[NSMutableDictionary dictionary];
                        [breakTimeEntryDict setObject:[customMetaDict objectForKey:@"value"] forKey:@"breakType"];
                        [breakTimeEntryDict setObject:[newDict objectForKey:@"entryDate"] forKey:@"entryDate"];

                        NSDictionary *intervalDict=[newDict objectForKey:@"interval"];
                        if (intervalDict!=nil && ![intervalDict isKindOfClass:[NSNull class]])
                        {
                            if ([intervalDict objectForKey:@"hours"]!=nil && ![[intervalDict objectForKey:@"hours"] isKindOfClass:[NSNull class]])
                            {
                                [breakTimeEntryDict setObject:[intervalDict objectForKey:@"hours"] forKey:@"hours"];

                            }
                            if ([intervalDict objectForKey:@"timePair"]!=nil && ![[intervalDict objectForKey:@"timePair"] isKindOfClass:[NSNull class]])
                            {
                                [breakTimeEntryDict setObject:[intervalDict objectForKey:@"timePair"] forKey:@"timePair"];
                            }
                        }


                        [breakTimeEntryDict setObject:[newDict objectForKey:@"uri"] forKey:@"uri"];
                        [breakTimeEntryDict setObject:[newDict objectForKey:@"user"] forKey:@"user"];
                        break;
                    }
                    if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:comments"])
                    {
                        comments=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                    }
                    if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:task"])
                    {
                        taskUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                    }
                    if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:billing-rate"])
                    {
                        billingUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                        billingName=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                    }
                    if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:activity"])
                    {
                        activityUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                        activityName=[[customMetaDict objectForKey:@"value"]objectForKey:@"text"];
                    }
                    if ([keyUri isEqualToString:@"urn:replicon:time-entry-metadata-key:project"])
                    {
                        projectUri=[[customMetaDict objectForKey:@"value"]objectForKey:@"uri"];
                    }
                    if ([keyUri isEqualToString:@"urn:replicon:widget-ui-metadata-key:row-number"])
                    {
                        rowNumber=[[customMetaDict objectForKey:@"value"]objectForKey:@"number"];
                    }
                }



                if (breakTimeEntryDict==nil)
                {
                    workTimeEntryDict=[NSMutableDictionary dictionary];
                    if (comments)
                    {
                        [workTimeEntryDict setObject:comments forKey:@"comments"];
                    }
                    if (taskUri)
                    {
                        [workTimeEntryDict setObject:taskUri forKey:@"taskUri"];
                        if(taskName!=nil && ![taskName isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:taskName forKey:@"taskName"];
                        }

                    }
                    if (billingUri)
                    {
                        [workTimeEntryDict setObject:billingUri forKey:@"billingUri"];
                        if(billingName!=nil && ![billingName isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:billingName forKey:@"billingName"];
                        }
                    }
                    if (activityUri)
                    {
                        [workTimeEntryDict setObject:activityUri forKey:@"activityUri"];
                        if(activityName!=nil && ![activityName isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:activityName forKey:@"activityName"];
                        }

                    }
                    if (projectUri)
                    {
                        [workTimeEntryDict setObject:projectUri forKey:@"projectUri"];
                        if(projectName!=nil && ![projectName isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:projectName forKey:@"projectName"];
                        }
                    }
                    if (clientUri)
                    {
                        [workTimeEntryDict setObject:clientUri forKey:@"clientUri"];
                        if(clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:clientName forKey:@"clientName"];
                        }
                    }
                    if (programUri)
                    {
                        [workTimeEntryDict setObject:programUri forKey:@"programUri"];
                        if(programName!=nil && ![programName isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:programName forKey:@"programName"];
                        }
                    }
                    if (rowNumber)
                    {
                        [workTimeEntryDict setObject:rowNumber forKey:@"rowNumber"];
                    }

                    [workTimeEntryDict setObject:[newDict objectForKey:@"entryDate"] forKey:@"entryDate"];

                    NSDictionary *intervalDict=[newDict objectForKey:@"interval"];
                    if (intervalDict!=nil && ![intervalDict isKindOfClass:[NSNull class]])
                    {
                        if ([intervalDict objectForKey:@"hours"]!=nil && ![[intervalDict objectForKey:@"hours"] isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:[intervalDict objectForKey:@"hours"] forKey:@"hours"];

                        }
                        if ([intervalDict objectForKey:@"timePair"]!=nil && ![[intervalDict objectForKey:@"timePair"] isKindOfClass:[NSNull class]])
                        {
                            [workTimeEntryDict setObject:[intervalDict objectForKey:@"timePair"] forKey:@"timePair"];
                        }
                    }




                    [workTimeEntryDict setObject:[newDict objectForKey:@"uri"] forKey:@"uri"];
                    [workTimeEntryDict setObject:[newDict objectForKey:@"user"] forKey:@"user"];
                }

                NSMutableDictionary *newUpdatedDict=[NSMutableDictionary dictionary];
                if (breakTimeEntryDict)
                {
                    [newUpdatedDict setValue:breakTimeEntryDict forKey:@"breakTimeEntry"];
                }
                else if (workTimeEntryDict)
                {
                    [newUpdatedDict setValue:workTimeEntryDict forKey:@"workTimeEntry"];
                }

                if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
                {
                    NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
                    [newUpdatedDict setObject:entryDateDict forKey:@"entryDate"];
                }
                else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
                {
                    NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
                    [newUpdatedDict setObject:entryDateDict forKey:@"entryDate"];
                }
                [array addObject:newUpdatedDict];
                
            }
        }
    }
    for (NSDictionary *dateDict in timesheetperiodDatesArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", @"entryDate", dateDict];
        NSArray *filteredarray = [array filteredArrayUsingPredicate:predicate];
        BOOL isAnyEmptyRowEntryPresent=NO;
        for (NSDictionary *entryDict in filteredarray)
        {
            NSDictionary *breakTimeEntryDict=[entryDict objectForKey:@"breakTimeEntry"];
            NSDictionary *workTimeEntryDict=[entryDict objectForKey:@"workTimeEntry"];
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            if (![breakTimeEntryDict isKindOfClass:[NSNull class]] && breakTimeEntryDict!=nil)
            {
                NSDictionary *breakType=[breakTimeEntryDict objectForKey:@"breakType"];
                NSString *comments=[breakTimeEntryDict objectForKey:@"comments"];
                NSDictionary *entryDateDict=[breakTimeEntryDict objectForKey:@"entryDate"];
                NSDictionary *timePairDict=[breakTimeEntryDict objectForKey:@"timePair"];
                NSString *uri=[breakTimeEntryDict objectForKey:@"uri"];

                if (timePairDict==nil||[timePairDict isKindOfClass:[NSNull class]]) {
                    isAnyEmptyRowEntryPresent=YES;
                }

                if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                    comments=@"";
                }

                NSString *inTimeString=@"";
                NSString *outTimeString=@"";

                if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
                {
                    NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                    NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                    if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                    {
                        inTimeString=[Util convertApiTimeDictTo12HourTimeString:startTimeDict];
                    }

                    if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                    {
                        outTimeString=[Util convertApiTimeDictTo12HourTimeString:endTimeDict];
                    }

                }
                else
                {

                    NSArray *array=nil;
                    if (isPending)
                    {
                        array=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
                    }
                    else
                    {
                        array=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
                    }
                    NSString *approvalStatus=nil;
                    if ([array count]>0)
                    {
                        approvalStatus=[[array objectAtIndex:0] objectForKey:@"approvalStatus"];
                    }

                }

                NSString *decimalHours=@"0.00";
                if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                    outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
                {
                    decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
                }


                NSString *breakName=[breakType objectForKey:@"text"];
                if (breakName==nil||[breakName isKindOfClass:[NSNull class]]) {
                    breakName=@"";
                }
                NSString *breakUri=[breakType objectForKey:@"uri"];
                if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]) {
                    breakUri=@"";
                }

                NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
                NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];


                [dataDict setObject:uri forKey:@"rowUri"];

                [dataDict setObject:comments forKey:@"comments"];
                [dataDict setObject:breakName forKey:@"breakName"];
                [dataDict setObject:breakUri forKey:@"breakUri"];
                [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                [dataDict setObject:GEN4_DAILY_WIDGET_TIMESHEET forKey:@"timesheetFormat"];
                [dataDict setObject:uri forKey:@"timePunchesUri"];
                [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                }

                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];


                NSArray *expArr = nil;
                NSString *tableName = nil;
                if (isPending)
                {
                    expArr = [self getPendingTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                    tableName=approvalPendingTimeEntriesTable;

                }
                else
                {
                    expArr = [self getPreviousTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                    tableName=approvalPreviousTimeEntriesTable;
                }

                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                    [myDB updateTable: tableName data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    NSArray *timeEntriesArr=nil;
                    if (isPending)
                    {
                        [self getPendingTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                    }
                    else
                    {
                        [self getPreviousTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                    }

                    if ([timeEntriesArr count]>0)
                    {
                        NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                        [myDB updateTable: tableName data:dataDict where:whereString intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:tableName data:dataDict intoDatabase:@""];
                    }


                }
            }
            else if (![workTimeEntryDict isKindOfClass:[NSNull class]] && workTimeEntryDict!=nil)
            {
                NSString *comments=[workTimeEntryDict objectForKey:@"comments"];

                NSDictionary *entryDateDict=[workTimeEntryDict objectForKey:@"entryDate"];
                NSDictionary *timePairDict=[workTimeEntryDict objectForKey:@"timePair"];
                NSDictionary *hoursDict=[workTimeEntryDict objectForKey:@"hours"];
                NSString *uri=[workTimeEntryDict objectForKey:@"uri"];
                NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
                NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];



                if (timePairDict==nil||[timePairDict isKindOfClass:[NSNull class]])
                {
                    if (hoursDict==nil||[hoursDict isKindOfClass:[NSNull class]])
                    {
                        isAnyEmptyRowEntryPresent=YES;
                    }
                }
                if (comments==nil||[comments isKindOfClass:[NSNull class]]) {
                    comments=@"";
                }
                NSString *inTimeString=@"";
                NSString *outTimeString=@"";

                if (timePairDict!=nil && ![timePairDict isKindOfClass:[NSNull class]])
                {
                    NSDictionary *endTimeDict=[timePairDict objectForKey:@"endTime"];
                    NSDictionary *startTimeDict=[timePairDict objectForKey:@"startTime"];
                    if (![startTimeDict isKindOfClass:[NSNull class]] && startTimeDict!=nil)
                    {
                        inTimeString=[Util convertApiTimeDictTo12HourTimeString:startTimeDict];
                    }

                    if (![endTimeDict isKindOfClass:[NSNull class]] && endTimeDict!=nil)
                    {
                        outTimeString=[Util convertApiTimeDictTo12HourTimeString:endTimeDict];
                    }

                }
                else if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
                {
                    // DO NOTHING HERE
                }
                else
                {

                    NSArray *array=nil;
                    if (isPending)
                    {
                        array=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
                    }
                    else
                    {
                        array=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
                    }
                    NSString *approvalStatus=nil;
                    if ([array count]>0)
                    {
                        approvalStatus=[[array objectAtIndex:0] objectForKey:@"approvalStatus"];
                    }


                }

                NSString *decimalHours=@"0.00";
                if ( inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&
                    outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""])
                {
                    decimalHours=[Util getNumberOfHoursForInTime:inTimeString outTime:outTimeString];
                }
                else if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
                {
                    NSNumber *hours=[Util convertApiTimeDictToDecimal:hoursDict];
                     [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTimeEntryValue"];
                    decimalHours=[NSString stringWithFormat:@"%f",[hours newFloatValue]];
                }

                [dataDict setObject:uri forKey:@"rowUri"];



                [dataDict setObject:inTimeString forKey:@"time_in"];
                [dataDict setObject:outTimeString forKey:@"time_out"];
                [dataDict setObject:comments forKey:@"comments"];
                [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                [dataDict setObject:GEN4_DAILY_WIDGET_TIMESHEET forKey:@"timesheetFormat"];
                [dataDict setObject:uri forKey:@"timePunchesUri"];
                [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                }

                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];


                if ([workTimeEntryDict objectForKey:@"projectUri"] !=nil && ![[workTimeEntryDict objectForKey:@"projectUri"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"projectUri"] forKey:@"projectUri"];
                    if ([workTimeEntryDict objectForKey:@"projectName"] !=nil && ![[workTimeEntryDict objectForKey:@"projectName"]  isKindOfClass:[NSNull class]]) {
                        [dataDict setObject:[workTimeEntryDict objectForKey:@"projectName"] forKey:@"projectName"];
                    }


                }
                if ([workTimeEntryDict objectForKey:@"clientUri"] !=nil && ![[workTimeEntryDict objectForKey:@"clientUri"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"clientUri"] forKey:@"clientUri"];
                    if ([workTimeEntryDict objectForKey:@"clientName"] !=nil && ![[workTimeEntryDict objectForKey:@"clientName"]  isKindOfClass:[NSNull class]]) {
                        [dataDict setObject:[workTimeEntryDict objectForKey:@"clientName"] forKey:@"clientName"];
                    }


                }
                if ([workTimeEntryDict objectForKey:@"programUri"] !=nil && ![[workTimeEntryDict objectForKey:@"programUri"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"programUri"] forKey:@"programUri"];
                    if ([workTimeEntryDict objectForKey:@"programName"] !=nil && ![[workTimeEntryDict objectForKey:@"programName"]  isKindOfClass:[NSNull class]]) {
                        [dataDict setObject:[workTimeEntryDict objectForKey:@"programName"] forKey:@"programName"];
                    }


                }
                if ([workTimeEntryDict objectForKey:@"activityUri"] !=nil && ![[workTimeEntryDict objectForKey:@"activityUri"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"activityUri"] forKey:@"activityUri"];
                    if ([workTimeEntryDict objectForKey:@"activityName"] !=nil && ![[workTimeEntryDict objectForKey:@"activityName"]  isKindOfClass:[NSNull class]]) {
                        [dataDict setObject:[workTimeEntryDict objectForKey:@"activityName"] forKey:@"activityName"];
                    }


                }

                if ([workTimeEntryDict objectForKey:@"taskUri"] !=nil && ![[workTimeEntryDict objectForKey:@"taskUri"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"taskUri"] forKey:@"taskUri"];
                    if ([workTimeEntryDict objectForKey:@"taskName"] !=nil && ![[workTimeEntryDict objectForKey:@"taskName"]  isKindOfClass:[NSNull class]]) {
                        [dataDict setObject:[workTimeEntryDict objectForKey:@"taskName"] forKey:@"taskName"];
                    }


                }
                if ([workTimeEntryDict objectForKey:@"billingUri"] !=nil && ![[workTimeEntryDict objectForKey:@"billingUri"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"billingUri"] forKey:@"billingUri"];
                    if ([workTimeEntryDict objectForKey:@"billingName"] !=nil && ![[workTimeEntryDict objectForKey:@"billingName"]  isKindOfClass:[NSNull class]]) {
                        [dataDict setObject:[workTimeEntryDict objectForKey:@"billingName"] forKey:@"billingName"];
                    }

                }
                if ([workTimeEntryDict objectForKey:@"rowNumber"] !=nil && ![[workTimeEntryDict objectForKey:@"rowNumber"]isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:[workTimeEntryDict objectForKey:@"rowNumber"] forKey:@"rowNumber"];
                }
                

                NSArray *expArr = nil;
                NSString *tableName = nil;
                if (isPending)
                {
                    expArr = [self getPendingTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                    tableName=approvalPendingTimeEntriesTable;

                }
                else
                {
                    expArr = [self getPreviousTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                    tableName=approvalPreviousTimeEntriesTable;
                }
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                    [myDB updateTable: tableName data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {

                    [myDB insertIntoTable:tableName data:dataDict intoDatabase:@""];

                }

            }
        }

    }

}

#pragma mark -
#pragma mark Get methods
-(NSArray *)getTimeSheetInfoSheetIdentityForPending:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' ",approvalPendingTimesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return timeSheetsArr;
	}
	return nil;
    
}

-(NSArray *)getTimeSheetInfoSheetIdentityForPrevious:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' ",approvalPreviousTimesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return timeSheetsArr;
	}
	return nil;
    
}

-(NSMutableArray*)getPendingApprovalDataForTimesheetSheetURI:(id)timeSheetUri andUserUri:(NSString *)userUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' AND userUri='%@' ",timeSheetUri,userUri];
	NSMutableArray *approvalstsSheetsArr = [myDB select:@"*" from:approvalPendingTimesheetsTable where:whereString intoDatabase:@""];
	if ([approvalstsSheetsArr count]!=0)
    {
		return approvalstsSheetsArr;
	}
	return nil;
}

-(NSMutableArray*)getPendingApprovalDataForExpenseSheetURI:(id)expensUri andUserUri:(NSString *)userUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@' AND userUri='%@' ",expensUri,userUri];
	NSMutableArray *approvalsexpenseSheetsArr = [myDB select:@"*" from:approvalPendingExpensesheetsTable where:whereString intoDatabase:@""];
	if ([approvalsexpenseSheetsArr count]!=0)
    {
		return approvalsexpenseSheetsArr;
	}
	return nil;
}
-(NSMutableArray*)getPendingApprovalDataForTimesheetSheetURI:(id)timeSheetUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timeSheetUri];
	NSMutableArray *approvalstsSheetsArr = [myDB select:@"*" from:approvalPendingTimesheetsTable where:whereString intoDatabase:@""];
	if ([approvalstsSheetsArr count]!=0)
    {
		return approvalstsSheetsArr;
	}
	return nil;
}
-(NSMutableArray*)getPreviousApprovalDataForTimesheetSheetURI:(id)timeSheetUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timeSheetUri];
	NSMutableArray *approvalstsSheetsArr = [myDB select:@"*" from:approvalPreviousTimesheetsTable where:whereString intoDatabase:@""];
	if ([approvalstsSheetsArr count]!=0)
    {
		return approvalstsSheetsArr;
	}
	return nil;
}


-(NSMutableArray*)getPendingApprovalDataForTimeOffsURI:(id)timeOffUri andUserUri:(NSString *)userUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@' AND userUri='%@' ",timeOffUri,userUri];
	NSMutableArray *approvalsetimeOffsArr = [myDB select:@"*" from:approvalPendingTimeOffsTable where:whereString intoDatabase:@""];
	if ([approvalsetimeOffsArr count]!=0)
    {
		return approvalsetimeOffsArr;
	}
	return nil;
}


-(NSMutableArray*)getPreviousApprovalDataForTimesheetSheetURI:(id)timesheetUri andUserUri:(NSString *)userUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' AND userUri='%@' ",timesheetUri,userUri];
	NSMutableArray *approvalstimeSheetsArr = [myDB select:@"*" from:approvalPreviousTimesheetsTable where:whereString intoDatabase:@""];
	if ([approvalstimeSheetsArr count]!=0)
    {
		return approvalstimeSheetsArr;
	}
	return nil;
}

-(NSMutableArray*)getPreviousApprovalDataForExpensesheetSheetURI:(id)expenseSheetUri andUserUri:(NSString *)userUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@' AND userUri='%@' ",expenseSheetUri,userUri];
	NSMutableArray *approvalsexpenseSheetsArr = [myDB select:@"*" from:approvalPreviousExpensesheetsTable where:whereString intoDatabase:@""];
	if ([approvalsexpenseSheetsArr count]!=0)
    {
		return approvalsexpenseSheetsArr;
	}
	return nil;
}

-(NSMutableArray*)getPreviousApprovalDataForTimeOffURI:(id)timeOffUri andUserUri:(NSString *)userUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@' AND userUri='%@'",timeOffUri,userUri];
	NSMutableArray *approvalsTimeOffsArr = [myDB select:@"*" from:approvalPreviousTimeOffsTable where:whereString intoDatabase:@""];
	if ([approvalsTimeOffsArr count]!=0)
    {
		return approvalsTimeOffsArr;
	}
	return nil;
}


-(NSMutableArray *) getAllPendingTimesheetsOfApprovalFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where approvalStatus='Waiting for Approval'  order by approval_dueDate desc,UPPER(username) asc",approvalPendingTimesheetsTable];
	NSMutableArray *timeSheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeSheetsArray count]>0)
    {
		return timeSheetsArray;
	}
	return nil;
}
-(NSMutableArray *) getAllPendingExpenseSheetOfApprovalFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where approvalStatus='Waiting for Approval'  order by approval_dueDate desc,UPPER(username) asc,trackingNumber desc",approvalPendingExpensesheetsTable];
	NSMutableArray *expenseSheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArray count]>0)
    {
		return expenseSheetsArray;
	}
	return nil;
}

-(NSMutableArray *) getAllPendingTimeOffsOfApprovalFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where approvalStatus='Waiting for Approval' order by dueDate desc,UPPER(username) asc,timeoffUri desc",approvalPendingTimeOffsTable];
	NSMutableArray *timeOffsSheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeOffsSheetsArray count]>0)
    {
		return timeOffsSheetsArray;
	}
	return nil;
}

-(NSMutableArray *) getAllPreviousTimesheetsOfApprovalFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where isFromViewTeamTime=0 order by startDate desc,UPPER(username) asc",approvalPreviousTimesheetsTable];
	NSMutableArray *timesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timesheetsArray count]>0)
    {
		return timesheetsArray;
	}
	return nil;
}


-(NSMutableArray *) getAllPreviousExpensesheetsOfApprovalFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@  order by expenseDate desc,UPPER(username) asc,trackingNumber desc",approvalPreviousExpensesheetsTable];
	NSMutableArray *expensesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expensesheetsArray count]>0)
    {
		return expensesheetsArray;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimeOffsOfApprovalFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	//Implemented as per US7990
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by dueDate desc,UPPER(username) asc,timeoffUri desc",approvalPreviousTimeOffsTable];
	NSMutableArray *timesOffsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timesOffsArray count]>0)
    {
		return timesOffsArray;
	}
	return nil;
}
-(NSMutableArray *)getAllPendingTimeSheetsGroupedByDueDatesWithStatus:(NSString *)status
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSMutableArray *dueDatesArray = nil;
    if (status)
    {
        dueDatesArray = [myDB select:@"distinct(approval_dueDate) " from:approvalPendingTimesheetsTable where:@" approvalStatus='Waiting for Approval' order by approval_dueDate desc" intoDatabase:@""];
    }
    else
    {
        dueDatesArray = [myDB select:@"distinct(approval_dueDate)" from:approvalPendingTimesheetsTable where:@"" usingSort:@"order by approval_dueDate desc" intoDatabase:@""];

    }
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        for (int i=0; i<[dueDatesArray count]; i++)
        {
            NSMutableArray *groupedtsArray = nil;
            if (status)
            {
                groupedtsArray = [myDB select:@" * " from:approvalPendingTimesheetsTable where:[NSString stringWithFormat: @" approval_dueDate = '%@' AND approvalStatus='Waiting for Approval' order by UPPER(username) asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"approval_dueDate" ]] intoDatabase:@""];
            }
            else
            {
                groupedtsArray = [myDB select:@" * " from:approvalPendingTimesheetsTable where:[NSString stringWithFormat: @" approval_dueDate = '%@' order by UPPER(username) asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"approval_dueDate" ]] intoDatabase:@""];

            }
            
            for (int j=0; j<[groupedtsArray count]; j++)
            {
                NSMutableDictionary *groupedtsDict=[groupedtsArray objectAtIndex:j];
                [groupedtsDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"IsSelected"];
                [groupedtsArray replaceObjectAtIndex:j withObject:groupedtsDict];
            }

            [groupedTimesheetsArr addObject:groupedtsArray];
        }
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        return groupedTimesheetsArr;
    }
    return nil;
}



-(NSMutableArray *)getAllPendingExpenseSheetsGroupedByDueDates
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedExpenseSheetsArr=[NSMutableArray array];
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(approval_dueDate) " from:approvalPendingExpensesheetsTable where:@" approvalStatus='Waiting for Approval'  order by approval_dueDate desc" intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        for (int i=0; i<[dueDatesArray count]; i++)
        {
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPendingExpensesheetsTable where:[NSString stringWithFormat: @" approval_dueDate = '%@' AND approvalStatus='Waiting for Approval'  order by UPPER(username) asc,trackingNumber desc",[[dueDatesArray objectAtIndex:i] objectForKey:@"approval_dueDate" ]] intoDatabase:@""];
            
            for (int j=0; j<[groupedtsArray count]; j++)
            {
                NSMutableDictionary *groupedtsDict=[groupedtsArray objectAtIndex:j];
                [groupedtsDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"IsSelected"];
                [groupedtsArray replaceObjectAtIndex:j withObject:groupedtsDict];
            }
            
            [groupedExpenseSheetsArr addObject:groupedtsArray];
        }
    }
    
    if (groupedExpenseSheetsArr != nil && [groupedExpenseSheetsArr count]>0)
    {
        return groupedExpenseSheetsArr;
    }
    return nil;

}

-(NSMutableArray *)getAllPendingExpenseSheetsGroupedByDueDatesWithAnyApprovalStatus
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedExpenseSheetsArr=[NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select distinct(approval_dueDate) from %@  order by approval_dueDate desc",approvalPendingExpensesheetsTable];
    NSMutableArray *dueDatesArray =[myDB executeQueryToConvertUnicodeValues:sql];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        for (int i=0; i<[dueDatesArray count]; i++)
        {
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPendingExpensesheetsTable where:[NSString stringWithFormat: @" approval_dueDate = '%@' AND approvalStatus='Waiting for Approval'   order by UPPER(username) asc,trackingNumber desc",[[dueDatesArray objectAtIndex:i] objectForKey:@"approval_dueDate" ]] intoDatabase:@""];
            
            for (int j=0; j<[groupedtsArray count]; j++)
            {
                NSMutableDictionary *groupedtsDict=[groupedtsArray objectAtIndex:j];
                [groupedtsDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"IsSelected"];
                [groupedtsArray replaceObjectAtIndex:j withObject:groupedtsDict];
            }
            
            [groupedExpenseSheetsArr addObject:groupedtsArray];
        }
    }
    
    if (groupedExpenseSheetsArr != nil && [groupedExpenseSheetsArr count]>0)
    {
        return groupedExpenseSheetsArr;
    }
    return nil;
    
}


-(NSMutableArray *)getAllPendingTimeoffs
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
   NSMutableArray *pendingTimeOffsArray = [myDB select:@"*" from:approvalPendingTimeOffsTable where:@" approvalStatus='Waiting for Approval' order by dueDate desc,UPPER(username) asc,timeoffUri desc" intoDatabase:@""];

    if (pendingTimeOffsArray != nil && [pendingTimeOffsArray count]>0)
    {
        return pendingTimeOffsArray;
    }
    return nil;
    
}
-(NSMutableArray *) getAllPendingTimesheetDaySummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPendingTimesheetsDaySummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimesheetDaySummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPreviousTimesheetsDaySummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllPendingTimeoffFromDBForTimeoff:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",approvalPendingTimeoffEntriesTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimeoffFromDBForTimeoff:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",approvalPreviousTimeoffEntriesTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}


-(NSArray *)getPendingTimesheetinfoForActivityIdentity:(NSString *)activityIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where activityUri = '%@' and timesheetUri='%@' ",approvalPendingTimesheetsActivitiesSummaryTable,activityIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimesheetinfoForActivityIdentity:(NSString *)activityIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where activityUri = '%@' and timesheetUri='%@' ",approvalPreviousTimesheetsActivitiesSummaryTable,activityIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}



-(NSArray *)getPendingTimesheetinfoForProjectIdentity:(NSString *)projectIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where projectUri = '%@' and timesheetUri='%@' ",approvalPendingTimesheetsProjectsSummaryTable,projectIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimesheetinfoForProjectIdentity:(NSString *)projectIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where projectUri = '%@' and timesheetUri='%@' ",approvalPreviousTimesheetsProjectsSummaryTable,projectIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getPendingTimesheetinfoForBillingIdentity:(NSString *)billingIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where billingUri = '%@' and timesheetUri='%@'",approvalPendingTimesheetsBillingSummaryTable,billingIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getPreviousTimesheetinfoForBillingIdentity:(NSString *)billingIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where billingUri = '%@' and timesheetUri='%@'",approvalPreviousTimesheetsBillingSummaryTable,billingIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}


-(NSArray *)getPendingTimesheetinfoForPayrollIdentity:(NSString *)payrollIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where payrollUri = '%@' and timesheetUri='%@'",approvalPendingTimesheetsPayrollSummaryTable,payrollIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimesheetinfoForPayrollIdentity:(NSString *)payrollIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where payrollUri = '%@' and timesheetUri='%@'",approvalPreviousTimesheetsPayrollSummaryTable,payrollIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray*)getPendingTimesheetInfoForTimeAllocationUri:(NSString*)timeAllocationUri timesheetUri:(NSString *)timesheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeAllocationUri = '%@' and timesheetUri='%@'",approvalPendingTimeEntriesTable,timeAllocationUri,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where timeAllocationUri = '%@' and timesheetUri='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,timeAllocationUri,timesheetUri,tsFormat];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getPreviousTimesheetInfoForTimeAllocationUri:(NSString*)timeAllocationUri timesheetUri:(NSString *)timesheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeAllocationUri = '%@' and timesheetUri='%@'",approvalPreviousTimeEntriesTable,timeAllocationUri,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where timeAllocationUri = '%@' and timesheetUri='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,timeAllocationUri,timesheetUri,tsFormat];
    }

	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray*)getPendingTimesheetInfoForTimePunchesUri:(NSString*)timePunchesUri timesheetUri:(NSString *)timesheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timePunchesUri = '%@' and timesheetUri='%@'",approvalPendingTimeEntriesTable,timePunchesUri,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where timePunchesUri = '%@' and timesheetUri='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,timePunchesUri,timesheetUri,tsFormat];
    }

	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getPreviousTimesheetInfoForTimePunchesUri:(NSString*)timePunchesUri timesheetUri:(NSString *)timesheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timePunchesUri = '%@' and timesheetUri='%@'",approvalPreviousTimeEntriesTable,timePunchesUri,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where timePunchesUri = '%@' and timesheetUri='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,timePunchesUri,timesheetUri,tsFormat];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getTimesheetinfoForEntryDate:(NSNumber *)entryDate andPending:(BOOL)isPending andTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=nil;
    if (isPending)
    {
        query=[NSString stringWithFormat:@" select * from %@ where timesheetEntryDate = '%@' and timesheetUri='%@'",approvalPendingTimesheetsDaySummaryTable,entryDate,timesheetUri];
    }
	else
    {
        query=[NSString stringWithFormat:@" select * from %@ where timesheetEntryDate = '%@' and timesheetUri='%@'",approvalPreviousTimesheetsDaySummaryTable,entryDate,timesheetUri];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPendingTimesheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri andEntryDate:(NSString *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' and timesheetEntryDate='%@'",approvalPendingTimesheetCustomFieldsTable,sheetUri,moduleName,entryUri,udfUri,entryDate];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getPreviousTimesheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri andEntryDate:(NSString *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' and timesheetEntryDate='%@'",approvalPreviousTimesheetCustomFieldsTable,sheetUri,moduleName,entryUri,udfUri,entryDate];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSDictionary *)getTotalHoursInfoForPendingTimesheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select totalDurationDecimal from %@ where timesheetUri = '%@'",approvalPendingTimesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}
-(NSDictionary *)getTotalHoursInfoForPreviousTimesheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select totalDurationDecimal from %@ where timesheetUri = '%@'",approvalPreviousTimesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}
-(NSArray *)getPendingTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' ",approvalPendingTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' ",approvalPreviousTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSMutableArray *)getAllPendingDisclaimerDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where module='%@'",approvalPendingDisclaimerTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllPreviousDisclaimerDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where module='%@'",approvalPreviousDisclaimerTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllPendingTimeEntriesForSheetFromDB: (NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPendingTimeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,timesheetUri,tsFormat];
    }

	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
    
}

-(NSMutableArray *)getAllPendingTimeEntriesForSheetFromDB: (NSString *)timesheetUri forTimeSheetFormat:(NSString *)timesheetFormat
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,timesheetUri,timesheetFormat];
    
    
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
    
}

-(NSMutableArray *)getAllPreviousTimeEntriesForSheetFromDB: (NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPreviousTimeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,timesheetUri,tsFormat];
    }

	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
    
}

-(NSMutableArray *)getAllPreviousTimeEntriesForSheetFromDB: (NSString *)timesheetUri forTimeSheetFormat:(NSString *)timesheetFormat
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,timesheetUri,timesheetFormat];
    
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
    
}


-(NSMutableArray *) getPendingTimeEntriesForSheetFromDB: (NSString *)timesheetUri {
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        for (int i=0; i<[dueDatesArray count]; i++)
        {
             NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri];
            
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND timesheetFormat='%@'  order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,tsFormat];
            }
            
           
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPendingTimeEntriesTable where:whereString1 intoDatabase:@""];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeOffTypeName" ascending:TRUE];
            [groupedtsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            
            [groupedTimesheetsArr addObject:[Util sortArray:groupedtsArray inAscending:YES usingKey:@"time_in"]];
            
        }
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        
        return groupedTimesheetsArr;
    }
    return nil;
    
    
}
-(NSMutableArray *) getPreviousTimeEntriesForSheetFromDB: (NSString *)timesheetUri {
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        for (int i=0; i<[dueDatesArray count]; i++)
        {
            NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@'  order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri];
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND timesheetFormat='%@'  order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,tsFormat];
            }
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPreviousTimeEntriesTable where:whereString1 intoDatabase:@""];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeOffTypeName" ascending:TRUE];
            [groupedtsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
           
            
            [groupedTimesheetsArr addObject:[Util sortArray:groupedtsArray inAscending:YES usingKey:@"time_in"]];
            
        }
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        
        return groupedTimesheetsArr;
    }
    return nil;
    
    
}

-(NSMutableArray *) getPendingTimeEntriesForExtendedInOutSheetFromDB: (NSString *)timesheetUri {
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
   
    BOOL isGen4Timesheet=NO;
    
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]]&&([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET]))
    {
        isGen4Timesheet=YES;
    }
    
     NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by timesheetEntryDate asc",timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        
        for (int b=0; b<[dueDatesArray count]; b++)
        {
            
            NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' order by time_in asc",[[dueDatesArray objectAtIndex:b] objectForKey:@"timesheetEntryDate" ],timesheetUri];
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND timesheetFormat='%@' order by time_in asc",[[dueDatesArray objectAtIndex:b] objectForKey:@"timesheetEntryDate" ],timesheetUri,tsFormat];
            }
            
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPendingTimeEntriesTable where:whereString1 intoDatabase:@""];
            
            groupedtsArray=[Util sortArrayAccordingToTimeIn:groupedtsArray];
            
            for (int i=0; i<[groupedtsArray count]; i++)
            {
                NSString *timeOffURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"timeOffUri"];
                
                if (timeOffURI==nil || [timeOffURI isKindOfClass:[NSNull class]] || [timeOffURI isEqualToString:@""])
                {
                    NSString *projectURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectUri"];
                    NSString *activityURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityUri"];
                    NSString *breakURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"];
                    
                    
                    BOOL isProjectAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
                    BOOL isActivityAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
                    BOOL isBreakAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];

                    if (isGen4Timesheet) {
                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetUri];

                        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]]&&([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] ))
                        {
                            isProjectAccess=NO;
                            isActivityAccess=NO;
                            isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];

                        }
                        else if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]]&&([tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ))
                        {
                            isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                            isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                            isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                        }
                        
                        
                    }
                    
                    NSMutableArray *tempArr=[NSMutableArray arrayWithArray:[NSMutableArray array]];
                    [tempArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"time_in"],@"in_time",
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"time_out"],@"out_time",
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"comments"],@"comments",
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"timePunchesUri"],@"timePunchesUri",
                                        @"",@"clientPunchId",nil]];
                    
                    
                    if (isProjectAccess)
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:projectURI];
                        
                        
                    }
                    else if (isActivityAccess)
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:activityURI];
                        
                    }
                    else if (isBreakAccess && [[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"]!=nil && ![[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"] isKindOfClass:[NSNull class]] &&![[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"] isEqualToString:@""])
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:breakURI];
                        
                    }
                    else
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:projectURI];
                        
                    }
                }
                
                
                
                
            }
            [groupedTimesheetsArr addObject:groupedtsArray];
            
        }
    }
    
    
    
    if (isGen4Timesheet)
    {
        
        BOOL isProjectAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
        BOOL isActivityAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
        BOOL isBreakAccess=[self getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];
        
        for (int m=0; m<[groupedTimesheetsArr count]; m++)
        {
            NSMutableArray *groupedtsArray=[groupedTimesheetsArr objectAtIndex:m];
            NSMutableArray *nullObjectsWithoutAnyProjectsTasksOrBreaks=[NSMutableArray array];
            NSMutableArray *nullObjectsWithProjectsTasksOrBreaks=[NSMutableArray array];
            NSMutableArray *groupArray=[NSMutableArray array];
            
            
            for (int n=0; n<[groupedtsArray count]; n++)
            {
                NSString *tmpprojectUri=[[groupedtsArray objectAtIndex:n] objectForKey:@"projectUri"];
                NSString *tmpactivityUri=[[groupedtsArray objectAtIndex:n] objectForKey:@"activityUri"];
                NSString *tmpbreakUri=[[groupedtsArray objectAtIndex:n] objectForKey:@"breakUri"];
                NSString *timeOffURI=[[groupedtsArray objectAtIndex:n]objectForKey:@"timeOffUri"];
                
                if (timeOffURI==nil || [timeOffURI isKindOfClass:[NSNull class]] || [timeOffURI isEqualToString:@""])
                {
                    BOOL  isEntryMadeAgainstProjectTaskActivityOrBreak=NO;
                    if (isProjectAccess &&tmpprojectUri!=nil && ![tmpprojectUri isKindOfClass:[NSNull class]]&& ![tmpprojectUri isEqualToString:@""])
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=YES;
                    }
                    else if (isActivityAccess &&tmpactivityUri!=nil && ![tmpactivityUri isKindOfClass:[NSNull class]]&& ![tmpactivityUri isEqualToString:@""])
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=YES;
                    }
                    else if (isBreakAccess &&tmpbreakUri!=nil && ![tmpbreakUri isKindOfClass:[NSNull class]]&& ![tmpbreakUri isEqualToString:@""])
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=YES;
                    }
                    else
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=NO;
                    }
                    
                    NSString *time_in=[[groupedtsArray objectAtIndex:n]objectForKey:@"time_in"];
                    if (time_in==nil||[time_in isKindOfClass:[NSNull class]]||[time_in isEqualToString:@""]) {
                        
                        if (isEntryMadeAgainstProjectTaskActivityOrBreak)
                        {
                            
                            [nullObjectsWithProjectsTasksOrBreaks addObject:[groupedtsArray objectAtIndex:n]];
                        }
                        else
                        {
                            [nullObjectsWithoutAnyProjectsTasksOrBreaks addObject:[groupedtsArray objectAtIndex:n]];
                        }
                        
                        
                    }
                    else
                    {
                        [groupArray addObject:[groupedtsArray objectAtIndex:n]];
                    }

                }
                else
                {
                    [groupArray addObject:[groupedtsArray objectAtIndex:n]];
                }
            }
            [groupArray addObjectsFromArray:nullObjectsWithProjectsTasksOrBreaks];
            [groupArray addObjectsFromArray:nullObjectsWithoutAnyProjectsTasksOrBreaks];
            [groupedTimesheetsArr replaceObjectAtIndex:m withObject:groupArray];
        }
        
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        
        return groupedTimesheetsArr;
    }
    return nil;
    
    
}

-(NSMutableArray *) getPreviousTimeEntriesForExtendedInOutSheetFromDB: (NSString *)timesheetUri {
    
    BOOL isGen4Timesheet=NO;
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]]&&([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET]))
    {
        isGen4Timesheet=YES;
    }
   
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by timesheetEntryDate asc",timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        
        for (int b=0; b<[dueDatesArray count]; b++)
        {
            NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' order by time_in asc",[[dueDatesArray objectAtIndex:b] objectForKey:@"timesheetEntryDate" ],timesheetUri];
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND timesheetFormat='%@' order by time_in asc",[[dueDatesArray objectAtIndex:b] objectForKey:@"timesheetEntryDate" ],timesheetUri,tsFormat];
            }
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPreviousTimeEntriesTable where:whereString1 intoDatabase:@""];
            
            groupedtsArray=[Util sortArrayAccordingToTimeIn:groupedtsArray];
            
            for (int i=0; i<[groupedtsArray count]; i++)
            {
                NSString *timeOffURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"timeOffUri"];
                
                if (timeOffURI==nil || [timeOffURI isKindOfClass:[NSNull class]] || [timeOffURI isEqualToString:@""])
                {
                    NSString *projectURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectUri"];
                    NSString *activityURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityUri"];
                    NSString *breakURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"];
                    
                    
                    BOOL isProjectAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
                    BOOL isActivityAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
                    BOOL isBreakAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];

                    if (isGen4Timesheet) {
                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetUri];

                        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]]&&([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] ))
                        {
                            isProjectAccess=NO;
                            isActivityAccess=NO;
                            isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];

                        }
                        else if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]]&&([tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ))
                        {
                            isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                            isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                            isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                        }

                        
                    }
                    
                    NSMutableArray *tempArr=[NSMutableArray arrayWithArray:[NSMutableArray array]];
                    [tempArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"time_in"],@"in_time",
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"time_out"],@"out_time",
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"comments"],@"comments",
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"timePunchesUri"],@"timePunchesUri",
                                        @"",@"clientPunchId",nil]];
                    
                    
                    if (isProjectAccess)
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:projectURI];
                        
                        
                    }
                    else if (isActivityAccess)
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:activityURI];
                        
                    }
                    else if (isBreakAccess && [[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"]!=nil && ![[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"] isKindOfClass:[NSNull class]] &&![[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"] isEqualToString:@""])
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:breakURI];
                        
                    }
                    else
                    {
                        
                        [[groupedtsArray objectAtIndex:i] setObject:tempArr forKey:projectURI];
                        
                    }
                }
                
                
                
                
            }
            [groupedTimesheetsArr addObject:groupedtsArray];
            
        }
    }
    
    
    
    if (isGen4Timesheet)
    {
        
        BOOL isProjectAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
        BOOL isActivityAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
        BOOL isBreakAccess=[self getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];
        
        for (int m=0; m<[groupedTimesheetsArr count]; m++)
        {
            NSMutableArray *groupedtsArray=[groupedTimesheetsArr objectAtIndex:m];
            NSMutableArray *nullObjectsWithoutAnyProjectsTasksOrBreaks=[NSMutableArray array];
            NSMutableArray *nullObjectsWithProjectsTasksOrBreaks=[NSMutableArray array];
            NSMutableArray *groupArray=[NSMutableArray array];
            
            
            for (int n=0; n<[groupedtsArray count]; n++)
            {
                NSString *tmpprojectUri=[[groupedtsArray objectAtIndex:n] objectForKey:@"projectUri"];
                NSString *tmpactivityUri=[[groupedtsArray objectAtIndex:n] objectForKey:@"activityUri"];
                NSString *tmpbreakUri=[[groupedtsArray objectAtIndex:n] objectForKey:@"breakUri"];
                NSString *timeOffURI=[[groupedtsArray objectAtIndex:n]objectForKey:@"timeOffUri"];
                
                if (timeOffURI==nil || [timeOffURI isKindOfClass:[NSNull class]] || [timeOffURI isEqualToString:@""])
                {
                    BOOL  isEntryMadeAgainstProjectTaskActivityOrBreak=NO;
                    if (isProjectAccess &&tmpprojectUri!=nil && ![tmpprojectUri isKindOfClass:[NSNull class]]&& ![tmpprojectUri isEqualToString:@""])
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=YES;
                    }
                    else if (isActivityAccess &&tmpactivityUri!=nil && ![tmpactivityUri isKindOfClass:[NSNull class]]&& ![tmpactivityUri isEqualToString:@""])
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=YES;
                    }
                    else if (isBreakAccess &&tmpbreakUri!=nil && ![tmpbreakUri isKindOfClass:[NSNull class]]&& ![tmpbreakUri isEqualToString:@""])
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=YES;
                    }
                    else
                    {
                        isEntryMadeAgainstProjectTaskActivityOrBreak=NO;
                    }
                    
                    NSString *time_in=[[groupedtsArray objectAtIndex:n]objectForKey:@"time_in"];
                    if (time_in==nil||[time_in isKindOfClass:[NSNull class]]||[time_in isEqualToString:@""]) {
                        
                        if (isEntryMadeAgainstProjectTaskActivityOrBreak)
                        {
                            
                            [nullObjectsWithProjectsTasksOrBreaks addObject:[groupedtsArray objectAtIndex:n]];
                        }
                        else
                        {
                            [nullObjectsWithoutAnyProjectsTasksOrBreaks addObject:[groupedtsArray objectAtIndex:n]];
                        }
                        
                        
                    }
                    else
                    {
                        [groupArray addObject:[groupedtsArray objectAtIndex:n]];
                    }

                }
                else
                {
                    [groupArray addObject:[groupedtsArray objectAtIndex:n]];
                }
            }
            [groupArray addObjectsFromArray:nullObjectsWithProjectsTasksOrBreaks];
            [groupArray addObjectsFromArray:nullObjectsWithoutAnyProjectsTasksOrBreaks];
            [groupedTimesheetsArr replaceObjectAtIndex:m withObject:groupArray];
        }
        
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        
        return groupedTimesheetsArr;
    }
    return nil;

}



-(NSMutableArray *) getPendingGroupedStandardTimeEntriesForSheetFromDB: (NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *timeSheetFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by entryTypeOrder asc,timesheetEntryDate asc",timesheetUri];
    
    
    if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,timesheetEntryDate asc,rowNumber asc",timesheetUri,timeSheetFormat];
    }
    
    NSMutableArray *timesheetEntryDateArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
    
    
    NSMutableArray *distinctRowsArray = nil;

    if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
    {
        if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            distinctRowsArray = [myDB select:@"distinct(rowNumber) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
        }
        else
        {
            distinctRowsArray = [myDB select:@"distinct(rowUri) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
        }
    }


    
    
    
    for (int i=0; i<[timesheetEntryDateArray count]; i++)
    {
        NSMutableArray *groupedTimeEntryArrayForDay=[NSMutableArray array];
        NSString *dateStr=[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ];
        for (int k=0; k<[distinctRowsArray count]; k++)
        {
            NSString *whereString1=nil;
            if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 order by entryTypeOrder asc,rowNumber asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"]];
                }
                else
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 order by entryTypeOrder asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
                }
            }

            
            if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,rowNumber asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"],timeSheetFormat];
                }
                else
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],timeSheetFormat];
                }
                
            }
            
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPendingTimeEntriesTable where:whereString1 intoDatabase:@""];
            
            if ([groupedtsArray count]==0)
            {
                NSString *whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
                if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
                {
                    if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 AND timesheetFormat='%@'",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"],timeSheetFormat];
                    }
                    else
                    {
                        whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@'",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],timeSheetFormat];
                    }
                    
                    
                }
                groupedtsArray = [myDB select:@" * " from:approvalPendingTimeEntriesTable where:whereString2 intoDatabase:@""];
                
                NSMutableArray *tmpgroupedtsArray=[NSMutableArray array];
                NSMutableDictionary *dict=[groupedtsArray objectAtIndex:0];
                [dict setObject:@"objectEmpty" forKey:@"isObjectEmpty"];
                [dict setObject:dateStr forKey:@"timesheetEntryDate"];
                [dict setObject:@"0" forKey:@"durationDecimalFormat"];
                [dict setObject:@"0:0" forKey:@"durationHourFormat"];
                [tmpgroupedtsArray addObject:dict];
                [groupedTimeEntryArrayForDay addObject:tmpgroupedtsArray];
                
            }
            else
            {
                [groupedTimeEntryArrayForDay addObject:groupedtsArray];
                
            }
            
        }
        
        
        
        [groupedTimesheetsArr addObject:groupedTimeEntryArrayForDay];
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        
        return groupedTimesheetsArr;
    }
    return nil;
    
}


-(NSMutableArray *) getPreviousGroupedStandardTimeEntriesForSheetFromDB: (NSString *)timesheetUri
{
    
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *timeSheetFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by entryTypeOrder asc,timesheetEntryDate asc",timesheetUri];
    
    
    if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,timesheetEntryDate asc,rowNumber asc",timesheetUri,timeSheetFormat];
    }
    
    NSMutableArray *timesheetEntryDateArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
    
    
    NSMutableArray *distinctRowsArray = nil;

    if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
    {
        if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            distinctRowsArray = [myDB select:@"distinct(rowNumber) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
        }
        else
        {
            distinctRowsArray = [myDB select:@"distinct(rowUri) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
        }
    }


    
    
    
    for (int i=0; i<[timesheetEntryDateArray count]; i++)
    {
        NSMutableArray *groupedTimeEntryArrayForDay=[NSMutableArray array];
        NSString *dateStr=[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ];
        for (int k=0; k<[distinctRowsArray count]; k++)
        {
            NSString *whereString1=nil;

            if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 order by entryTypeOrder asc,rowNumber asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"]];
                }
                else
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 order by entryTypeOrder asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
                }
            }

            
            
            if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,rowNumber asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"],timeSheetFormat];
                }
                else
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],timeSheetFormat];
                }
                
            }
            
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPreviousTimeEntriesTable where:whereString1 intoDatabase:@""];
            
            if ([groupedtsArray count]==0)
            {
                NSString *whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
                if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
                {
                    if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 AND timesheetFormat='%@'",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"],timeSheetFormat];
                    }
                    else
                    {
                        whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@'",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],timeSheetFormat];
                    }
                    
                    
                }
                groupedtsArray = [myDB select:@" * " from:approvalPreviousTimeEntriesTable where:whereString2 intoDatabase:@""];
                
                NSMutableArray *tmpgroupedtsArray=[NSMutableArray array];
                NSMutableDictionary *dict=[groupedtsArray objectAtIndex:0];
                [dict setObject:@"objectEmpty" forKey:@"isObjectEmpty"];
                [dict setObject:dateStr forKey:@"timesheetEntryDate"];
                [dict setObject:@"0" forKey:@"durationDecimalFormat"];
                [dict setObject:@"0:0" forKey:@"durationHourFormat"];
                [tmpgroupedtsArray addObject:dict];
                [groupedTimeEntryArrayForDay addObject:tmpgroupedtsArray];
                
            }
            else
            {
                [groupedTimeEntryArrayForDay addObject:groupedtsArray];
                
            }
            
        }
        
        
        
        [groupedTimesheetsArr addObject:groupedTimeEntryArrayForDay];
    }
    
    if (groupedTimesheetsArr != nil && [groupedTimesheetsArr count]>0)
    {
        
        return groupedTimesheetsArr;
    }
    return nil;
    
}


-(NSString *)getPendingTimesheetFormatInfoFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }

    
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(timesheetFormat) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
	if ([distinctRowsArray count]>0)
    {
		return [[distinctRowsArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
	}
	return nil;
    
}
-(NSString *)getPreviousTimesheetFormatInfoFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(timesheetFormat) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
	if ([distinctRowsArray count]>0)
    {
		return [[distinctRowsArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
	}
	return nil;
    
}



-(NSMutableArray *)getAllPendingDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by entryTypeOrder asc,timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by entryTypeOrder asc,timesheetEntryDate asc,rowNumber asc",timesheetUri,tsFormat];
    }

    
    //To not show timeoff with zero values use below where string
    
    //NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND entryType= 'TimeEntry' order by timesheetEntryDate asc",timesheetUri];
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(rowUri) " from:approvalPendingTimeEntriesTable where:whereString  intoDatabase:@""];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    for (int k=0; k<[distinctRowsArray count]; k++)
    {
        NSString *whereString1=[NSString stringWithFormat: @" rowUri= '%@'",[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            whereString1=[NSString stringWithFormat: @" rowUri= '%@' AND timesheetFormat='%@'",[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],tsFormat];
        }
        NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPendingTimeEntriesTable where:whereString1 intoDatabase:@""];
        
        [groupedTimesheetsArr addObject:groupedtsArray];
        
    }
    
	if ([groupedTimesheetsArr count]>0)
    {
		return groupedTimesheetsArr;
	}
	return nil;
    
}
-(NSMutableArray *)getAllPreviousDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' order by entryTypeOrder asc,timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND timesheetFormat='%@' order by entryTypeOrder asc,timesheetEntryDate asc,rowNumber asc",timesheetUri,tsFormat];
    }

    
    //To not show timeoff with zero values use below where string
    
    //NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND entryType= 'TimeEntry' order by timesheetEntryDate asc",timesheetUri];
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(rowUri) " from:approvalPreviousTimeEntriesTable where:whereString  intoDatabase:@""];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    for (int k=0; k<[distinctRowsArray count]; k++)
    {
        NSString *whereString1=[NSString stringWithFormat: @" rowUri= '%@'",[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            whereString1=[NSString stringWithFormat: @" rowUri= '%@' AND timesheetFormat='%@'",[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],tsFormat];
        }
        NSMutableArray *groupedtsArray = [myDB select:@" * " from:approvalPreviousTimeEntriesTable where:whereString1 intoDatabase:@""];
        
        [groupedTimesheetsArr addObject:groupedtsArray];
        
    }
    
	if ([groupedTimesheetsArr count]>0)
    {
		return groupedTimesheetsArr;
	}
	return nil;
    
}

-(NSMutableArray *) getAllPendingTimesheetProjectSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by projectName asc",approvalPendingTimesheetsProjectsSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
    
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"projectName"] isEqualToString:RPLocalizedString(NO_PROJECT, NO_PROJECT)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
	
    if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimesheetProjectSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by projectName asc",approvalPreviousTimesheetsProjectsSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"projectName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
    
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"projectName"] isEqualToString:RPLocalizedString(NO_PROJECT, NO_PROJECT)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
	
    if ([array count]>0)
    {
		return array;
	}
	return nil;
}


-(NSMutableArray *) getAllPendingTimesheetActivitySummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by activityName asc",approvalPendingTimesheetsActivitiesSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"activityName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
    
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"activityName"] isEqualToString:RPLocalizedString(NO_ACTIVITY, NO_ACTIVITY)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
	
    if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllPendingTimesheetPayrollSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by payrollName asc",approvalPendingTimesheetsPayrollSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"payrollName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
    
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"payrollName"] isEqualToString:RPLocalizedString(NO_PAYCODE, NO_PAYCODE)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
	
    if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPendingTimesheetBillingSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by billingName asc",
                     approvalPendingTimesheetsBillingSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"billingName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
   
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"billingName"] isEqualToString:RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
    
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}



-(NSMutableArray *) getAllPendingTimesheetApprovalFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPendingTimesheetApproverHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimesheetActivitySummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by activityName asc",approvalPreviousTimesheetsActivitiesSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"activityName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
   
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"activityName"] isEqualToString:RPLocalizedString(NO_ACTIVITY, NO_ACTIVITY)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
	
    if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllPreviousTimesheetPayrollSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by payrollName asc",approvalPreviousTimesheetsPayrollSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"payrollName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
    
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"payrollName"] isEqualToString:RPLocalizedString(NO_PAYCODE, NO_PAYCODE)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
	
    if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimesheetBillingSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by billingName asc",
                     approvalPreviousTimesheetsBillingSummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    //Implemented as per US7972
    NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:@"billingName" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        
        
        
        static NSStringCompareOptions comparisonOptions =
        
        NSCaseInsensitiveSearch | NSNumericSearch |
        
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
        
    }];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];
   
    NSArray *sortarray = [array sortedArrayUsingDescriptors:sortDescriptors];
    array=[NSMutableArray arrayWithArray:sortarray];
    
    NSMutableArray *tempArray=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        if ([[[array objectAtIndex:i]objectForKey:@"billingName"] isEqualToString:RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE)])
        {
            [tempArray addObject:[array objectAtIndex:i]];
            [array removeObjectAtIndex:i];
        }
    }
    if ([tempArray count]>0)
    {
        [array addObject:[tempArray objectAtIndex:0]];
    }
    
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}



-(NSMutableArray *) getAllPreviousTimesheetApprovalFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPreviousTimesheetApproverHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getLastSubmittedPendingTimesheetApprovalFromDB:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and actionUri='urn:replicon:approval-action:submit' order by actionDate desc",approvalPendingTimesheetApproverHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getLastSubmittedPreviousTimesheetApprovalFromDB:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and actionUri='urn:replicon:approval-action:submit' order by actionDate desc",approvalPreviousTimesheetApproverHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getPendingLastSubmittedExpenseSheetApprovalFromDB:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseSheetUri='%@' and actionUri='urn:replicon:approval-action:submit' order by timestamp desc",approvalPendingExpenseApprovalHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getPreviousLastSubmittedExpenseSheetApprovalFromDB:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseSheetUri='%@' and actionUri='urn:replicon:approval-action:submit' order by timestamp desc",approvalPreviousExpenseApprovalHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}


-(NSString *)getPendingTotalActivitySummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(activityDurationDecimal) from %@ where timesheetUri='%@'",approvalPendingTimesheetsActivitiesSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(activityDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getPendingTotalProjectSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(projectDurationDecimal) from %@ where timesheetUri='%@'",approvalPendingTimesheetsProjectsSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(projectDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getPendingTotalPayrollSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(payrollDurationDecimal) from %@ where timesheetUri='%@'",approvalPendingTimesheetsPayrollSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(payrollDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getPendingTotalBillingSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(billingDurationDecimal) from %@ where timesheetUri='%@'",approvalPendingTimesheetsBillingSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(billingDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}
-(NSString *)getPreviousTotalActivitySummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(activityDurationDecimal) from %@ where timesheetUri='%@'",approvalPreviousTimesheetsActivitiesSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(activityDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getPreviousTotalProjectSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(projectDurationDecimal) from %@ where timesheetUri='%@'",approvalPreviousTimesheetsProjectsSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(projectDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getPreviousTotalPayrollSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(payrollDurationDecimal) from %@ where timesheetUri='%@'",approvalPreviousTimesheetsPayrollSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(payrollDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getPreviousTotalBillingSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(billingDurationDecimal) from %@ where timesheetUri='%@'",approvalPreviousTimesheetsBillingSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(billingDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSArray *)getPendingTimesheetSheetUdfInfoForSheetUri:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri  andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' and entryUri='%@' ",sheetUri,rowUri];
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPendingTimesheetCustomFieldsTable where:whereString  intoDatabase:@""];
    
    if ([distinctRowsArray count]>0)
    {
        id temp=[[distinctRowsArray objectAtIndex:0] objectForKey:@"timesheetEntryDate"];
        NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and entryUri='%@' and timesheetEntryDate='%@'",approvalPendingTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri,temp];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
        if ([array count]!=0)
        {
            return array;
        }
        return nil;
    }
	
	return nil;
}
-(NSArray *)getPreviousTimesheetSheetUdfInfoForSheetUri:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri  andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' and entryUri='%@' ",sheetUri,rowUri];
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(timesheetEntryDate) " from:approvalPreviousTimesheetCustomFieldsTable where:whereString  intoDatabase:@""];
    
    if ([distinctRowsArray count]>0)
    {
        id temp=[[distinctRowsArray objectAtIndex:0] objectForKey:@"timesheetEntryDate"];
        NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and entryUri='%@' and timesheetEntryDate='%@'",approvalPreviousTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri,temp];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
        if ([array count]!=0)
        {
            return array;
        }
        return nil;
    }
	
	return nil;
}


-(NSArray *)getPendingTimesheetSheetUdfInfoForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri entryDate:(NSString *)entryDate andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and timesheetEntryDate='%@' and entryUri='%@'",approvalPendingTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri,entryDate,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimesheetSheetUdfInfoForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri entryDate:(NSString *)entryDate andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and timesheetEntryDate='%@' and entryUri='%@'",approvalPreviousTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri,entryDate,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
//Implementation for US9371//JUHI
-(NSArray *)getPendingTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and entryUri='%@'",approvalPendingTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getPreviousTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and entryUri='%@'",approvalPreviousTimesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}



-(void)saveMultiDayTimeOffUserExplicitEntryDetails:(NSArray *)userExplicitEntryDetails timeOffUri:(NSString *)timeOffUri{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@'",timeOffUri];
    [myDB deleteFromTable:multiDayTimeOffEntries where:whereString inDatabase:@""];

    for(NSDictionary *timeOffEntry in userExplicitEntryDetails){
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        if(timeOffEntry[@"date"] != nil && timeOffEntry[@"date"] != (id)[NSNull null]){
            NSDate *entryDate=[Util convertApiDateDictToDateFormat:timeOffEntry[@"date"]];
            NSNumber *timeOffDate=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [dataDictionary setObject:timeOffDate forKey:@"date"];
        }
        if(timeOffEntry[@"relativeDurationUri"] != nil && timeOffEntry[@"relativeDurationUri"] != (id)[NSNull null]){
            [dataDictionary setObject:timeOffEntry[@"relativeDurationUri"] forKey:@"relativeDurationUri"];
        }
        if(timeOffEntry[@"specificDuration"] != nil && timeOffEntry[@"specificDuration"] != (id)[NSNull null]){
            [dataDictionary setObject:timeOffEntry[@"specificDuration"] forKey:@"specificDuration"];
        }
        if(timeOffEntry[@"scheduleDuration"] != nil && timeOffEntry[@"scheduleDuration"] != (id)[NSNull null]){
            [dataDictionary setObject:timeOffEntry[@"scheduleDuration"] forKey:@"scheduledDuration"];
        }
        if(timeOffEntry[@"timeEnded"] != nil && timeOffEntry[@"timeEnded"] != (id)[NSNull null]){
//            [dataDictionary setObject:timeOffEntry[@"timeEnded"] forKey:@"timeEnded"];
            NSString *timeEnded = [Util convertApiTimeDictTo12HourTimeString:timeOffEntry[@"timeEnded"]];
            if(timeEnded !=nil && timeEnded != (id)[NSNull null]){
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",timeEnded] forKey:@"timeEnded"];
            }
        }
        if(timeOffEntry[@"timeStarted"] != nil && timeOffEntry[@"timeStarted"] != (id)[NSNull null]){
            NSString *timeStarted = [Util convertApiTimeDictTo12HourTimeString:timeOffEntry[@"timeStarted"]];
            if(timeStarted !=nil && timeStarted != (id)[NSNull null]){
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",timeStarted] forKey:@"timeStarted"];
            }
        }
        [dataDictionary setObject:timeOffUri forKey:@"timeOffUri"];
        [myDB insertIntoTable:multiDayTimeOffEntries data:dataDictionary intoDatabase:@""];
    }
}

-(void)saveBookingOptionsByScheduleDuration:(NSArray *)bookingOptionsByScheduleDuration timeOffUri:(NSString *)timeOffUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@'",timeOffUri];
    [myDB deleteFromTable:timeoffBookingScheduledDuration where:whereString inDatabase:@""];
    
    for(NSDictionary *scheduleDuration in bookingOptionsByScheduleDuration){
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        if(scheduleDuration[@"scheduleDuration"] != nil && scheduleDuration[@"scheduleDuration"] != (id)[NSNull null]){
            [dataDictionary setObject:scheduleDuration[@"scheduleDuration"] forKey:@"scheduledDuration"];
        }
        NSArray *bookingOptionsArray = scheduleDuration[@"bookingOptions"];
        if(bookingOptionsArray != nil && bookingOptionsArray != (id)[NSNull null] && bookingOptionsArray.count > 0){
            for(NSDictionary *bookingOptionsDict in bookingOptionsArray){
                [dataDictionary setObject:timeOffUri forKey:@"timeOffUri"];
                [dataDictionary setObject:bookingOptionsDict[@"displayText"] forKey:@"displayText"];
                if(bookingOptionsDict[@"duration"])
                    [dataDictionary setObject:bookingOptionsDict[@"duration"] forKey:@"duration"];
                [dataDictionary setObject:bookingOptionsDict[@"uri"] forKey:@"uri"];
                [myDB insertIntoTable:timeoffBookingScheduledDuration data:dataDictionary intoDatabase:@""];
            }
        }
    }
}


-(void)saveTimeOffEntryDataFromApiToDB:(NSMutableDictionary *)responseDict moduleName:(NSString *)approvalsModuleName
{
    
    NSMutableDictionary *timeOffDetailsDict=[responseDict objectForKey:@"timeOffDetails"];
    NSString *timeoffUri=[timeOffDetailsDict objectForKey:@"uri"];
    NSDictionary *timeoffCapabilities=[responseDict objectForKey:@"capabilities"];
    NSMutableArray *enableOnlyUdfs=[timeoffCapabilities objectForKey:@"enabledCustomFieldUris"];
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSArray *userExplicitEntryDetails = timeOffDetailsDict[@"userExplicitEntryDetails"];
    NSArray *bookingOptionsByScheduleDuration = responseDict[@"bookingOptionsByScheduleDuration"];
    
    if(userExplicitEntryDetails != nil && userExplicitEntryDetails != (id)[NSNull null] && userExplicitEntryDetails.count > 0){
        [self saveMultiDayTimeOffUserExplicitEntryDetails:userExplicitEntryDetails timeOffUri:timeoffUri];
    }
    
    if(bookingOptionsByScheduleDuration != nil && bookingOptionsByScheduleDuration != (id)[NSNull null] && bookingOptionsByScheduleDuration.count >0 ){
        [self saveBookingOptionsByScheduleDuration:bookingOptionsByScheduleDuration timeOffUri:timeoffUri];
    }
    
    NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@'",timeoffUri];
    NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
    {
        [myDB deleteFromTable:approvalPendingTimeoffCustomFieldsTable where:whereString inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimeoffCustomFieldsTable where:whereString inDatabase:@""];
    }
    
    
    //US9453 to address DE17320 Ullas M L
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
    {
        [self saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPending:enableOnlyUdfs forTimeoffUri:timeoffUri];
    }
    else
    {
        [self saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPrevious:enableOnlyUdfs forTimeoffUri:timeoffUri];
    }
    
    TimeoffModel *timeOffModel = [[TimeoffModel alloc]init];
    NSNumber *shiftDurationDecimal=nil;
    NSString *shiftDurationHourStr=nil;
//    NSDictionary *timeoffCapabilities=[responseDict objectForKey:@"capabilities"];
    //Implemented as per US7660
    int hasTimeOffEditAcess     =0;
    int hasTimeOffDeletetAcess  =0;
    int isDeviceSupportedEntryConfiguration = 0;
    NSNumber *isMultidayTimeOff;
    
    if (timeoffCapabilities!=nil && ![timeoffCapabilities isKindOfClass:[NSNull class]]) {
        if (([timeoffCapabilities objectForKey:@"canDeleteTimeOff"]!=nil && ![[timeoffCapabilities objectForKey:@"canDeleteTimeOff"] isKindOfClass:[NSNull class]])&&[[timeoffCapabilities objectForKey:@"canDeleteTimeOff"] boolValue] == YES )
        {
            hasTimeOffDeletetAcess = 1;
        }
        if (([timeoffCapabilities objectForKey:@"canEditTimeOff"]!=nil && ![[timeoffCapabilities objectForKey:@"canEditTimeOff"] isKindOfClass:[NSNull class]])&&[[timeoffCapabilities objectForKey:@"canEditTimeOff"] boolValue] == YES )
        {
            hasTimeOffEditAcess = 1;
        }
    }
    if ([responseDict objectForKey:@"isDeviceSupportedEntryConfiguration"]!=nil && ![[responseDict objectForKey:@"isDeviceSupportedEntryConfiguration"] isKindOfClass:[NSNull class]])
    {
        if([[responseDict objectForKey:@"isDeviceSupportedEntryConfiguration"] boolValue] == YES)
        {
            isDeviceSupportedEntryConfiguration = 1;
        }
    }
    if ([responseDict objectForKey:@"timeOffBalanceSummary"]!=nil && ![[responseDict objectForKey:@"timeOffBalanceSummary"]isKindOfClass:[NSNull class]])
    {
        [timeOffModel saveTimeoffBalanceSummaryForMultiDayTimeOffBooking:[responseDict objectForKey:@"timeOffBalanceSummary"] withTimeOffUri:timeoffUri];
    }
    if ([responseDict objectForKey:@"isMultiDayTimeOff"] != nil && [responseDict objectForKey:@"isMultiDayTimeOff"] != (id)[NSNull null])
    {
        isMultidayTimeOff = [responseDict objectForKey:@"isMultiDayTimeOff"];
    }

    NSString*status=nil;
    status=[[responseDict objectForKey:@"approvalStatus"]objectForKey:@"uri"];
    
    if ([status isEqualToString:APPROVED_STATUS_URI])
    {
        [updateDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
        status=APPROVED_STATUS;
    }
    else if ([status isEqualToString:NOT_SUBMITTED_STATUS_URI])
    {
        [updateDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
         status=NOT_SUBMITTED_STATUS;
    }
    else if ([status isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
    {
        [updateDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
        status=WAITING_FOR_APRROVAL_STATUS;
    }
    else if ([status isEqualToString:REJECTED_STATUS_URI])
    {
        [updateDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
        status=REJECTED_STATUS;
    }
    
    NSMutableDictionary *timeoffDict=[NSMutableDictionary dictionary];
    
    NSString *statusUri = [[responseDict objectForKey:@"approvalStatus"]objectForKey:@"uri"];
    if (statusUri!=nil && ![statusUri isKindOfClass:[NSNull class]]) {
        [timeoffDict setObject:statusUri      forKey:@"approvalStatusUri"];
    }
    
    if (shiftDurationDecimal!=nil && ![shiftDurationDecimal isKindOfClass:[NSNull class]])
    {
        [timeoffDict setObject:shiftDurationDecimal      forKey:@"shiftDurationDecimal"];
    }
    if (shiftDurationHourStr!=nil && ![shiftDurationHourStr isKindOfClass:[NSNull class]])
    {
        [timeoffDict setObject:shiftDurationHourStr   forKey:@"shiftDurationHour"];
    }
    
    
    [timeoffDict setObject:timeoffUri forKey:@"timeoffUri"];
    
    if (status!=nil && ![status isKindOfClass:[NSNull class]]) {
        [timeoffDict setObject:status      forKey:@"approvalStatus"];
        [updateDict setObject:status forKey:@"approvalStatus"];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            [myDB updateTable:approvalPendingTimeOffsTable data:updateDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB updateTable:approvalPreviousTimeOffsTable data:updateDict where:whereString intoDatabase:@""];
        }
        
    }
    
    [timeoffDict setObject:[NSNumber numberWithInt:hasTimeOffDeletetAcess] forKey:@"hasTimeOffDeletetAcess"];
    [timeoffDict setObject:[NSNumber numberWithInt:hasTimeOffEditAcess] forKey:@"hasTimeOffEditAcess"];
    [timeoffDict setObject:[NSNumber numberWithInt:isDeviceSupportedEntryConfiguration] forKey:@"isDeviceSupportedEntryConfiguration"];
    [timeoffDict setObject:isMultidayTimeOff!=nil && isMultidayTimeOff!=(id)[NSNull null] ? isMultidayTimeOff:@0 forKey:@"isMultiDayTimeOff"];
    
    NSString *comments=[timeOffDetailsDict objectForKey:@"comments"];
    if(comments != nil && comments != (id)[NSNull null]){
        [timeoffDict setObject:comments forKey:@"comments"];
    }
    
    if ([timeOffDetailsDict objectForKey:@"endDateDetails"]!=nil && ![[timeOffDetailsDict objectForKey:@"endDateDetails"] isKindOfClass:[NSNull class]])
    {
        NSDictionary *endDateDict=[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"date"];
        NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
        [timeoffDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
        
        NSString *endEntryType=nil;
        if ([[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"]!=nil&&![[[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"] isKindOfClass:[NSNull class]])
        {
            endEntryType=[[timeOffDetailsDict objectForKey:@"endDateDetails"]objectForKey:@"relativeDurationUri"];
        }
        else
            endEntryType=PARTIAL;
        [timeoffDict setObject:endEntryType forKey:@"endEntryDurationUri"];
        
        if ([[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"]!=nil && ![[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"] isKindOfClass:[NSNull class]]) {
            NSDictionary *tempDict=[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"timeOfDay"];
            NSMutableDictionary *endDateTimeDict=[NSMutableDictionary dictionary];
            [endDateTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
            [endDateTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
            NSString *endDateTime =  [Util convertApiTimeDictTo12HourTimeString:endDateTimeDict];
            [timeoffDict setObject:endDateTime   forKey:@"endDateTime"];
        }
        
        
        if ([[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"]!=nil && ![[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]]) {
            NSDictionary *totalHoursDict=[[[timeOffDetailsDict objectForKey:@"endDateDetails"] objectForKey:@"totalDuration"]objectForKey:@"calendarDayDuration"];
            NSNumber *endDatetotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
            NSString *endDatetotalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
            [timeoffDict setObject:endDatetotalHours      forKey:@"endDateDurationDecimal"];
            [timeoffDict setObject:endDatetotalHoursStr   forKey:@"endDateDurationHour"];
            
        }
        
    }
    if ([timeOffDetailsDict objectForKey:@"startDateDetails"]!=nil && ![[timeOffDetailsDict objectForKey:@"startDateDetails"] isKindOfClass:[NSNull class]])
    {
        NSDictionary *startDateDict=[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"date"];
        NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
        [timeoffDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
        NSString *startEntryType=nil;
        if ([[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"]!=nil&&![[[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"] isKindOfClass:[NSNull class]])
        {
            startEntryType=[[timeOffDetailsDict objectForKey:@"startDateDetails"]objectForKey:@"relativeDurationUri"];
            
        }
        else
            startEntryType=PARTIAL;
        [timeoffDict setObject:startEntryType forKey:@"startEntryDurationUri"];
        
        if ([[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"]!=nil && ![[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *tempDict=[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"timeOfDay"];
            NSMutableDictionary *startDateTimeDict=[NSMutableDictionary dictionary];
            [startDateTimeDict setObject:[tempDict objectForKey:@"hour"] forKey:@"Hour"];
            [startDateTimeDict setObject:[tempDict objectForKey:@"minute"] forKey:@"Minute"];
            NSString *startDateTime =  [Util convertApiTimeDictTo12HourTimeString:startDateTimeDict];
            [timeoffDict setObject:startDateTime   forKey:@"startDateTime"];
            
        }
        
        
        if ([[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"]!=nil && ![[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]]) {
            NSDictionary *totalHoursDict=[[[timeOffDetailsDict objectForKey:@"startDateDetails"] objectForKey:@"totalDuration"]objectForKey:@"calendarDayDuration"];
            NSNumber *endDatetotalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
            NSString *endDatetotalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
            [timeoffDict setObject:endDatetotalHours      forKey:@"startDateDurationDecimal"];
            [timeoffDict setObject:endDatetotalHoursStr   forKey:@"startDateDurationHour"];
            
        }
        
        
    }
    
    if ([timeOffDetailsDict objectForKey:@"timeOffType"]!=nil && ![[timeOffDetailsDict objectForKey:@"timeOffType"] isKindOfClass:[NSNull class]])
    {
        NSString *timeoffTypeURI=[[timeOffDetailsDict objectForKey:@"timeOffType"] objectForKey:@"uri"];
        NSString *timeoffTypeName=[[timeOffDetailsDict objectForKey:@"timeOffType"] objectForKey:@"name"];
        [timeoffDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
        [timeoffDict setObject:timeoffTypeURI forKey:@"timeoffTypeUri"];
        
    }
    
    if ([timeOffDetailsDict objectForKey:@"totalDuration"]!=nil && ![[timeOffDetailsDict objectForKey:@"totalDuration"] isKindOfClass:[NSNull class]])
    {
        NSDictionary *totalHoursDict=[[timeOffDetailsDict objectForKey:@"totalDuration"] objectForKey:@"calendarDayDuration"];
        NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
        NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
        [timeoffDict setObject:totalHours      forKey:@"totalDurationDecimal"];
        [timeoffDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
        
        NSString *totalTimeoffDaysStr=[[timeOffDetailsDict objectForKey:@"totalDuration"] objectForKey:@"decimalWorkdays"];
        [timeoffDict setObject:totalTimeoffDaysStr  forKey:@"totalTimeoffDays"];
    }
    
    
    
    NSString *timeOffDisplayFormatUri = @"";
    NSArray *timeOffDisplayFormatUriArray = [timeOffModel getTimeoffTypeInfoSheetIdentity:timeoffDict[@"timeoffTypeUri"]];
    if (timeOffDisplayFormatUriArray!= nil && ![timeOffDisplayFormatUriArray isKindOfClass:[NSNull class]] ) {
        timeOffDisplayFormatUri = timeOffDisplayFormatUriArray[0][@"timeOffDisplayFormatUri"];
        if (timeOffDisplayFormatUri!= nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]]) {
            [timeoffDict setObject:timeOffDisplayFormatUri   forKey:@"timeOffDisplayFormatUri"];
        }
    }

    
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
    {
        NSArray *timeoffArr = [self getAllPendingTimeoffFromDBForTimeoff:timeoffUri];
        if ([timeoffArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@'",timeoffUri];
            [myDB updateTable: approvalPendingTimeoffEntriesTable data:timeoffDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPendingTimeoffEntriesTable data:timeoffDict intoDatabase:@""];
        }

    }
    else
    {
        NSArray *timeoffArr = [self getAllPreviousTimeoffFromDBForTimeoff:timeoffUri];
        if ([timeoffArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timeoffUri='%@'",timeoffUri];
            [myDB updateTable: approvalPreviousTimeoffEntriesTable data:timeoffDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousTimeoffEntriesTable data:timeoffDict intoDatabase:@""];
        }

    }
        
    
    if (![timeOffDetailsDict isKindOfClass:[NSNull class]] && timeOffDetailsDict!=nil )
    {
        NSArray *sheetCustomFieldsArray=[timeOffDetailsDict objectForKey:@"customFields"];
        [self saveTimeOffCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timeoffUri andModuleName:TIMEOFF_UDF andEntryURI:nil approvalsModuleName:approvalsModuleName];
    }
    //Implementation for MOBI-261//JUHI
    NSArray *approvalDetailsArray=[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"entries"];
    NSMutableArray *approvalDtlsDataArray=[NSMutableArray array];
    
    for (NSDictionary *dict in approvalDetailsArray)
    {
        
       
        NSString *actingForUser=nil;
        NSString *actingUser=nil;
        NSString *comments=nil;
        
        NSMutableDictionary *approvalDetailDataDict=[NSMutableDictionary dictionary];
        [approvalDetailDataDict setObject:timeoffUri forKey:@"timeoffUri"];
        
        NSString *action=[[dict objectForKey:@"action"]objectForKey:@"uri"];
        if ([dict objectForKey:@"timeStamp"]!=nil && ![[dict objectForKey:@"timeStamp"] isKindOfClass:[NSNull class]])
        {
            NSDate *entryDate=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timeStamp"]];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [approvalDetailDataDict setObject:entryDateToStore forKey:@"timestamp"];
            
        }
        
        [approvalDetailDataDict setObject:action forKey:@"actionUri"];
       
        if ([dict objectForKey:@"authority"]!=nil && ![[dict objectForKey:@"authority"] isKindOfClass:[NSNull class]])
        {
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingForUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingForUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"];
                }
                
            }
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"];
                }
                
            }
        }
        if ([dict objectForKey:@"comments"]!=nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
        {
            comments=[dict objectForKey:@"comments"];
        }
        if (actingForUser!=nil)
        {
            [approvalDetailDataDict setObject:actingForUser                      forKey:@"actingForUser"];
        }
        if (comments!=nil)
        {
            [approvalDetailDataDict setObject:comments                      forKey:@"comments"];
        }
        if (actingUser!=nil)
        {
            [approvalDetailDataDict setObject:actingUser                      forKey:@"actingUser"];
        }
        
        [approvalDtlsDataArray addObject:approvalDetailDataDict];
    }
    
    [self saveTimeoffApprovalDetailsDataToDatabase:approvalDtlsDataArray moduleName:approvalsModuleName];
}
-(void)saveTimeOffCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI approvalsModuleName:(NSString *)approvalsModuleName
{
    for (int i=0; i<[sheetCustomFieldsArray count]; i++)
    {
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        NSDictionary *udfDict=[sheetCustomFieldsArray objectAtIndex:i];
        NSString *name=[[udfDict objectForKey:@"customField"]objectForKey:@"displayText"];
        if (name!=nil && ![name isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:name forKey:@"udf_name"];
        }
        NSString *uri=[[udfDict objectForKey:@"customField"]objectForKey:@"uri"];
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:uri forKey:@"udf_uri"];
        }
        NSString *type=[[udfDict objectForKey:@"customFieldType"]objectForKey:@"uri"];
        if (type!=nil && ![type isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:type forKey:@"entry_type"];
            
            if ([type isEqualToString:DROPDOWN_UDF_TYPE])
            {
                NSString *dropDownOptionURI=[udfDict objectForKey:@"dropDownOption"];
                if (dropDownOptionURI!=nil && ![dropDownOptionURI isKindOfClass:[NSNull class]])
                {
                    [udfDataDict setObject:dropDownOptionURI forKey:@"dropDownOptionURI"];
                }
            }
        }
        
        if (entryURI!=nil && ![entryURI isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:entryURI forKey:@"entryUri"];
        }
        
        NSString *value=[udfDict objectForKey:@"text"];
        if ([type isEqualToString:DATE_UDF_TYPE])
        {
            NSString *tmpValue=[udfDict objectForKey:@"date"];
            if (tmpValue!=nil && ![tmpValue isKindOfClass:[NSNull class]])
            {
                value=[Util convertApiTimeDictToDateStringWithDesiredFormat:[udfDict objectForKey:@"date"]];//DE18243 DE18690 DE18728 Ullas M L
            }
        }
        if (value!=nil && ![value isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:value forKey:@"udfValue"];
        }
        
        if (sheetUri!=nil && ![sheetUri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:sheetUri forKey:@"timeoffUri"];
        }
        
        if (moduleName!=nil && ![moduleName isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:moduleName forKey:@"moduleName"];
        }
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            NSArray *udfsArr = [self getPendingTimeOffCustomFieldsForURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri];
            if ([udfsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
                [myDB updateTable:approvalPendingTimeoffCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingTimeoffCustomFieldsTable data:udfDataDict intoDatabase:@""];
            }
        }
        else
        {
            NSArray *udfsArr = [self getPreviousTimeOffCustomFieldsForURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri];
            if ([udfsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"timeoffUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
                [myDB updateTable:approvalPreviousTimeoffCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousTimeoffCustomFieldsTable data:udfDataDict intoDatabase:@""];
            }
        }
        
        
        
    }
}
-(NSArray *)getPendingTimeOffCustomFieldsForURI:(NSString *)Uri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",approvalPendingTimeoffCustomFieldsTable,Uri,moduleName,entryUri,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimeOffCustomFieldsForURI:(NSString *)Uri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",approvalPreviousTimeoffCustomFieldsTable,Uri,moduleName,entryUri,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPendingTimeOffCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' and moduleName='%@' and udf_uri='%@' ",approvalPendingTimeoffCustomFieldsTable,sheetUri,moduleName,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousTimeOffCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffUri = '%@' and moduleName='%@' and udf_uri='%@' ",approvalPreviousTimeoffCustomFieldsTable,sheetUri,moduleName,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSDictionary *)getStatusInfoForPendingTimeOffIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select approvalStatus from %@ where timeoffUri = '%@'",approvalPendingTimeoffEntriesTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}

-(NSDictionary *)getApprovalStatusInfoForPendingTimesheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select approvalStatus from %@ where timesheetUri = '%@'",approvalPendingTimesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}

-(BOOL)getPendingTimesheetCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@'",approvalPendingTimesheetCapabilitiesTable,sheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        if([[[permissionArr objectAtIndex:0] objectForKey:permissionName] intValue]==1)
        {
            return YES;
        }
    }
	
    return NO;
    
}
-(NSMutableArray *)getPendingTimesheetCapabilityStatusForSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@'",approvalPendingTimesheetCapabilitiesTable,sheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        return permissionArr;
    }
	
    return nil;
    
}
-(NSMutableArray *)getPreviousTimesheetCapabilityStatusForSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@'",approvalPreviousTimesheetCapabilitiesTable,sheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        return permissionArr;
    }
	
    return nil;
    
}

-(BOOL)getPreviousTimesheetCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@'",approvalPreviousTimesheetCapabilitiesTable,sheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        if([[[permissionArr objectAtIndex:0] objectForKey:permissionName] intValue]==1)
        {
            return YES;
        }
    }
	
    return NO;
    
}
-(NSString *)getPendingStatusForDisclaimerPermissionForColumnName:(NSString *)columnName forSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implementation as per US9172//JUHI
    NSString *query =nil;
    if ([columnName isEqualToString:@"disclaimerTimesheetNoticePolicyUri"]) {
        query=[NSString stringWithFormat:@" select %@ from %@ where timesheetUri = '%@'",columnName,approvalPendingTimesheetCapabilitiesTable,sheetUri];
    }
    else
    {
        query=[NSString stringWithFormat:@" select %@ from %@ where expenseSheetUri = '%@'",columnName,approvalPendingExpenseCapabilitiesTable,sheetUri];
        
    }
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
	if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
		return [[permissionArr objectAtIndex:0] objectForKey:columnName];
	}
    
    return nil;
    
}
-(NSString *)getPreviousStatusForDisclaimerPermissionForColumnName:(NSString *)columnName forSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implementation as per US9172//JUHI
    NSString *query =nil;
    if ([columnName isEqualToString:@"disclaimerTimesheetNoticePolicyUri"]) {
        query=[NSString stringWithFormat:@" select %@ from %@ where timesheetUri = '%@'",columnName,approvalPreviousTimesheetCapabilitiesTable,sheetUri];
    }
    else
    {
        query=[NSString stringWithFormat:@" select %@ from %@ where expenseSheetUri = '%@'",columnName,approvalPreviousExpenseCapabilitiesTable,sheetUri];
        
    }
   
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
	if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
		return [[permissionArr objectAtIndex:0] objectForKey:columnName];
	}
    
    return nil;
    
}

-(BOOL)getPendingExpenseCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@'",approvalPendingExpenseCapabilitiesTable,sheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        if([[[permissionArr objectAtIndex:0] objectForKey:permissionName] intValue]==1)
        {
            return YES;
        }
    }

    return NO;
    
}
-(BOOL)getPreviousExpenseCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri
{
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@'",approvalPreviousExpenseCapabilitiesTable,sheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:query];
    if(permissionArr!=nil && ![permissionArr isKindOfClass:[NSNull class]] && [permissionArr count]>0)
    {
        if([[[permissionArr objectAtIndex:0] objectForKey:permissionName] intValue]==1)
        {
            return YES;
        }
    }

    return NO;
    
}


-(NSDictionary *)getApprovalStatusInfoForPendingExpenseSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select approvalStatus from %@ where expenseSheetUri = '%@'",approvalPendingExpensesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}

-(NSMutableArray *) getObjectExtensionDetailsFromDBForOEFUri:(NSString *)oefUri andTimesheetUri:(NSString *)timesheetUri andTimesheetFormat:(NSString *)timesheetFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where uri='%@' and timesheetUri='%@' and timesheetFormat='%@'",timesheetObjectExtensionFieldsTable,oefUri,timesheetUri,timesheetFormat];
    NSMutableArray *oefsArray =[myDB executeQueryToConvertUnicodeValues:sql];
    if ([oefsArray count]>0)
    {
        return oefsArray;
    }
    return nil;
}

-(NSString *)getEntriesTimeOffBreaksTotalForEntryDate:(NSString *)entryDate andTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:isPending];
    NSString *tableName = isPending ? approvalPendingTimeEntriesTable : approvalPreviousTimeEntriesTable;
    
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(durationDecimalFormat) from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetEntryDate='%@' AND timeSheetFormat='%@'",tableName,timesheetUri,entryDate,tsFormat];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        if ([array count]>0)
        {
            
            return [[array objectAtIndex:0] objectForKey:@"sum(durationDecimalFormat)"];
            
            
        }
    }
    
    return nil;
    
    
}

#pragma mark -
#pragma mark Expense methods

-(NSArray *)getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:(NSString *)expenseSheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' order by UPPER(expenseCodeName) asc,incurredDate desc,incurredAmountTotal desc",approvalPendingExpenseEntriesTable,expenseSheetUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSArray *)getAllPreviousExpenseExpenseEntriesFromDBForExpenseSheetUri:(NSString *)expenseSheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' order by UPPER(expenseCodeName) asc,incurredDate desc,incurredAmountTotal desc",approvalPreviousExpenseEntriesTable,expenseSheetUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}

-(void)saveExpenseEntryDataFromApiToDB:(NSMutableDictionary *)responseDict moduleName:(NSString *)approvalsModuleName
{
    
    NSMutableDictionary *expenseEntryDetailsDict=[responseDict objectForKey:@"details"];
    NSString *expenseSheetUri=[expenseEntryDetailsDict objectForKey:@"uri"];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"expenseSheetUri= '%@' ",expenseSheetUri];
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
    {
        [myDB deleteFromTable:approvalPendingExpenseEntriesTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousExpenseEntriesTable where:whereStr inDatabase:@""];
    }
    
    
    NSDictionary *expenseCapabilities=[responseDict objectForKey:@"capabilities"];
    //Implementation as per US9172//JUHI
    int isNoticeExplicitlyAccepted=0;
    NSMutableDictionary *disclaimerDict=[NSMutableDictionary dictionary];
    if (![expenseEntryDetailsDict isKindOfClass:[NSNull class]] && expenseEntryDetailsDict!=nil) {
        disclaimerDict=[expenseEntryDetailsDict objectForKey:@"expenseSheetNotice"];
        
        if ([[expenseEntryDetailsDict objectForKey:@"noticeExplicitlyAccepted"] boolValue] == YES )
        {
            isNoticeExplicitlyAccepted = 1;
        }
        
    }
    if (![disclaimerDict isKindOfClass:[NSNull class]] && disclaimerDict!=nil )
    {
        [self saveApprovalTimesheetDisclaimerDataToDB:disclaimerDict moduleName:approvalsModuleName];
    }

    int hasBillClient               =0;
    int hasPaymentMethod            =0;
    int hasReimbursements           =0;
    int canViewReceipt              =0;
    int hasProjectsAllowed          =0;
    int hasClientsAllowed           =0;
    int hasProjectsRequired         =0;
    int canEditTask                 =0;
    if ([[expenseCapabilities objectForKey:@"canViewBillToClient"] boolValue] == YES )
    {
        hasBillClient = 1;
    }
    if ([[expenseCapabilities objectForKey:@"canViewPaymentMethod"] boolValue] == YES )
    {
        hasPaymentMethod = 1;
    }
    if ([[expenseCapabilities objectForKey:@"canViewReceipt"] boolValue] == YES )
    {
        canViewReceipt = 1;
    }
    if ([[expenseCapabilities objectForKey:@"canViewReimburse"] boolValue] == YES )
    {
        hasReimbursements = 1;
    }
    if ([[expenseCapabilities objectForKey:@"entryAgainstProjectsAllowed"] boolValue] == YES )
    {
        hasProjectsAllowed = 1;
    }
    if ([[expenseCapabilities objectForKey:@"canEditTask"] boolValue] == YES )
    {
        canEditTask = 1;
    }
    if ([[expenseCapabilities objectForKey:@"selectProjectByClient"] boolValue] == YES )
    {
        hasClientsAllowed = 1;
    }
    if ([[expenseCapabilities objectForKey:@"entryAgainstProjectsRequired"] boolValue] == YES )
    {
        hasProjectsRequired = 1;
    }
     NSString *expenseNoticePolicyUri=[expenseCapabilities objectForKey:@"expenseNoticePolicyUri"];//Implementation as per US9172//JUHI
    
    
    NSMutableDictionary *capabilityDictionary=[NSMutableDictionary dictionary];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasBillClient] forKey:@"hasExpenseBillClient"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasPaymentMethod] forKey:@"hasExpensePaymentMethod"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:canViewReceipt] forKey:@"hasExpenseReceiptView"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasReimbursements] forKey:@"hasExpenseReimbursements"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasProjectsAllowed]forKey:@"expenseEntryAgainstProjectsAllowed"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:canEditTask] forKey:@"canEditTask"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasClientsAllowed]forKey:@"hasExpensesClientAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasProjectsRequired]forKey:@"expenseEntryAgainstProjectsRequired"];
    [capabilityDictionary setObject:expenseSheetUri                                forKey:@"expenseSheetUri"];
    //Implementation as per US9172//JUHI
    if (expenseNoticePolicyUri!=nil && ![expenseNoticePolicyUri isKindOfClass:[NSNull class]])
    {
        [capabilityDictionary setObject:expenseNoticePolicyUri  forKey:@"disclaimerExpenseNoticePolicyUri"];
    }
    
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
    {
        [myDB deleteFromTable:approvalPendingExpenseCapabilitiesTable where:[NSString stringWithFormat:@"expenseSheetUri = '%@'",expenseSheetUri] inDatabase:@""];
        [myDB insertIntoTable:approvalPendingExpenseCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousExpenseCapabilitiesTable where:[NSString stringWithFormat:@"expenseSheetUri = '%@'",expenseSheetUri] inDatabase:@""];
        [myDB insertIntoTable:approvalPreviousExpenseCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
    }
    
    
     NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    
    NSString *status=[[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"];

    
    if ([status isEqualToString:APPROVED_STATUS_URI])
    {
        [updateDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
        status=APPROVED_STATUS;
    }
    else if ([status isEqualToString:NOT_SUBMITTED_STATUS_URI])
    {
        [updateDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
         status=NOT_SUBMITTED_STATUS;
    }
    else if ([status isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
    {
        [updateDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
         status=WAITING_FOR_APRROVAL_STATUS;
    }
    else if ([status isEqualToString:REJECTED_STATUS_URI])
    {
        [updateDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
        status=REJECTED_STATUS;
    }
    else
    {
        [updateDict setObject:[NSNull null] forKey:@"approvalStatus"];
        status=nil;
    }
    
    
   
   
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
    {
        [myDB updateTable:approvalPendingExpensesheetsTable data:updateDict where:[NSString stringWithFormat:@"expenseSheetUri = '%@'",expenseSheetUri] intoDatabase:@""];
    }
    else
    {
        [myDB updateTable:approvalPreviousExpensesheetsTable data:updateDict where:[NSString stringWithFormat:@"expenseSheetUri = '%@'",expenseSheetUri] intoDatabase:@""];
    }
    

    
    
    NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri = '%@'",expenseSheetUri];
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
    {
        [myDB deleteFromTable:approvalPendingExpenseCustomFieldsTable where:whereString inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousExpenseCustomFieldsTable where:whereString inDatabase:@""];
    }
    
    
    
    NSMutableArray *expenseEntryArray=[expenseEntryDetailsDict objectForKey:@"entries"];
    
    if (expenseEntryArray != nil && expenseEntryArray != (id)[NSNull null]) {
        for (int i=0;i<[expenseEntryArray count]; i++)
        {
            
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSDictionary *dict=[expenseEntryArray objectAtIndex:i];
            NSString *expenseEntryUri=[dict objectForKey:@"uri"];
            
            if (status!=nil)
            {
                [dataDict setObject:status forKey:@"approvalStatus"];
            }
            [dataDict setObject:expenseSheetUri forKey:@"expenseSheetUri"];
            
            
            NSString *desc=[dict objectForKey:@"description"];
            NSString *expenseBillingOptionUri=[dict objectForKey:@"expenseBillingOptionUri"];
            
            [dataDict setObject:desc forKey:@"expenseEntryDescription"];
            [dataDict setObject:expenseBillingOptionUri forKey:@"billingUri"];
            
            if ([dict objectForKey:@"expenseCode"]!=nil &&![[dict objectForKey:@"expenseCode"]isKindOfClass:[NSNull class]]) {
                NSString *expenseCodeName=[[dict objectForKey:@"expenseCode"] objectForKey:@"displayText"];
                NSString *expenseCodeUri=[[dict objectForKey:@"expenseCode"] objectForKey:@"uri"];
                [dataDict setObject:expenseCodeName forKey:@"expenseCodeName"];
                [dataDict setObject:expenseCodeUri forKey:@"expenseCodeUri"];
                
            }
            
            if ([dict objectForKey:@"expenseReceipt"]!=nil &&![[dict objectForKey:@"expenseReceipt"]isKindOfClass:[NSNull class]])
            {
                NSString *expenseReceiptName=[[dict objectForKey:@"expenseReceipt"]objectForKey:@"displayText"];
                NSString *expenseReceiptUri=[[dict objectForKey:@"expenseReceipt"]objectForKey:@"uri"];
                [dataDict setObject:expenseReceiptName forKey:@"expenseReceiptName"];
                [dataDict setObject:expenseReceiptUri forKey:@"expenseReceiptUri"];
                
                
            }
            NSString *expenseReimbursementOptionUri=[dict objectForKey:@"expenseReimbursementOptionUri"];
            [dataDict setObject:expenseReimbursementOptionUri forKey:@"reimbursementUri"];
            
            if ([dict objectForKey:@"incurredAmountNet"]!=nil && ![[dict objectForKey:@"incurredAmountNet"]isKindOfClass:[NSNull class]])
            {
                NSString *netAmount=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"amount"]  stringValue];
                NSString *netCurrencyName=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *netCurrencyUri=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"uri"];
                
                [dataDict setObject:netAmount forKey:@"incurredAmountNet"];
                [dataDict setObject:netCurrencyName forKey:@"incurredAmountNetCurrencyName"];
                [dataDict setObject:netCurrencyUri forKey:@"incurredAmountNetCurrencyUri"];
                
            }
            
            if ([dict objectForKey:@"incurredAmountTaxes"]!=nil&& ![[dict objectForKey:@"incurredAmountTaxes"]isKindOfClass:[NSNull class]])
            {
                
                NSMutableArray *array=[dict objectForKey:@"incurredAmountTaxes"];
                for (int i=0; i<[array count]; i++)
                {
                    NSDictionary *taxAmountDict=[[array objectAtIndex:i] objectForKey:@"amount"];
                    NSDictionary *taxCodeDict=[[array objectAtIndex:i] objectForKey:@"taxCode"];
                    NSString *taxAmount=[taxAmountDict objectForKey:@"amount"];
                    NSString *taxCurrencyName=[[taxAmountDict objectForKey:@"currency"] objectForKey:@"name"];
                    NSString *taxCurrencyUri=[[taxAmountDict objectForKey:@"currency"] objectForKey:@"uri"];
                    NSString *taxCodeUri=[taxCodeDict objectForKey:@"uri"] ;
                    
                    [dataDict setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",i+1]];
                    [dataDict setObject:taxCurrencyName forKey:[NSString stringWithFormat:@"taxCurrencyName%d",i+1]];
                    [dataDict setObject:taxCurrencyUri forKey:[NSString stringWithFormat:@"taxCurrencyUri%d",i+1]];
                    [dataDict setObject:taxCodeUri forKey:[NSString stringWithFormat:@"taxCodeUri%d",i+1]];
                }
                [self saveExpenseIncurredAmountTaxDataToDBForExpenseEntryUri:expenseEntryUri dataArray:array moduleName:approvalsModuleName];
                
            }
            if ([dict objectForKey:@"incurredAmountGross"]!=nil && ![[dict objectForKey:@"incurredAmountGross"]isKindOfClass:[NSNull class]])
            {
                NSString *totalAmount=[[dict objectForKey:@"incurredAmountGross"] objectForKey:@"amount"];
                NSString *totalCurrencyName=[[[dict objectForKey:@"incurredAmountGross"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *totalCurrencyUri=[[[dict objectForKey:@"incurredAmountGross"] objectForKey:@"currency"] objectForKey:@"uri"];
                
                [dataDict setObject:totalAmount forKey:@"incurredAmountTotal"];
                [dataDict setObject:totalCurrencyName forKey:@"incurredAmountTotalCurrencyName"];
                [dataDict setObject:totalCurrencyUri forKey:@"incurredAmountTotalCurrencyUri"];
                
            }
            NSDictionary *expenseDateDict=[dict objectForKey:@"incurredDate"];
            NSDate *expenseDate=[Util convertApiDateDictToDateFormat:expenseDateDict];
            NSNumber *expenseDateToStore=[NSNumber numberWithDouble:[expenseDate timeIntervalSince1970]];
            [dataDict setObject:expenseDateToStore forKey:@"incurredDate"];
            
            if ([dict objectForKey:@"paymentMethod"]!=nil && ![[dict objectForKey:@"paymentMethod"]isKindOfClass:[NSNull class]])
            {
                NSString *paymentMethodName=[[dict objectForKey:@"paymentMethod"] objectForKey:@"displayText"];
                NSString *paymentMethodUri=[[dict objectForKey:@"paymentMethod"] objectForKey:@"uri"];
                [dataDict setObject:paymentMethodName forKey:@"paymentMethodName"];
                [dataDict setObject:paymentMethodUri forKey:@"paymentMethodUri"];
                
            }
            if ([dict objectForKey:@"client"]!=nil && ![[dict objectForKey:@"client"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:dict[@"client"][@"uri"] forKey:@"clientUri"];
                [dataDict setObject:dict[@"client"][@"displayText"] forKey:@"clientName"];
            }
            if ([dict objectForKey:@"project"]!=nil && ![[dict objectForKey:@"project"]isKindOfClass:[NSNull class]])
            {
                NSString *projectName=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
                NSString *projectUri=[[dict objectForKey:@"project"] objectForKey:@"uri"];
                [dataDict setObject:projectName forKey:@"projectName"];
                [dataDict setObject:projectUri forKey:@"projectUri"];
                
            }
            if ([dict objectForKey:@"quantity"]!=nil && ![[dict objectForKey:@"quantity"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:[dict objectForKey:@"quantity"] forKey:@"quantity"];
            }
            if ([dict objectForKey:@"rate"]!=nil && ![[dict objectForKey:@"rate"]isKindOfClass:[NSNull class]])
            {
                NSString *rateAmount=[[dict objectForKey:@"rate"] objectForKey:@"amount"] ;
                NSString *rateCurrencyName=[[[dict objectForKey:@"rate"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *rateCurrencyUri=[[[dict objectForKey:@"rate"]objectForKey:@"currency"] objectForKey:@"uri"];
                
                [dataDict setObject:rateAmount forKey:@"rateAmount"];
                [dataDict setObject:rateCurrencyName forKey:@"rateCurrencyName"];
                [dataDict setObject:rateCurrencyUri forKey:@"rateCurrencyUri"];
                
            }
            if ([dict objectForKey:@"quantity"]!=nil && ![[dict objectForKey:@"quantity"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:[dict objectForKey:@"quantity"] forKey:@"quantity"];
            }
            if ([dict objectForKey:@"task"]!=nil && ![[dict objectForKey:@"task"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:dict[@"task"][@"uri"] forKey:@"taskUri"];
                [dataDict setObject:dict[@"task"][@"displayText"] forKey:@"taskName"];
            }
            
            [dataDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
            [dataDict setObject:[NSNumber numberWithInt:isNoticeExplicitlyAccepted] forKey:@"noticeExplicitlyAccepted"];//Implementation as per US9172//JUHI
            NSArray *customFieldsArray=[dict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:customFieldsArray forSheetURI:expenseSheetUri andModuleName:EXPENSES_UDF andEntryURI:expenseEntryUri approvalsModuleName:approvalsModuleName];
            if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
            {
                NSArray *array=[self getPendingExpenseInfoForExpenseEntryUri:expenseEntryUri expenseSheetUri:expenseSheetUri];
                if ([array count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"expenseEntryUri = '%@'",expenseEntryUri];
                    [myDB updateTable:  approvalPendingExpenseEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPendingExpenseEntriesTable data:dataDict intoDatabase:@""];
                }
                [self deletePendingExpenseTaxCodeInfoForEntryUri:expenseEntryUri];
                [self deletePendingExpenseCodeInfoForEntryUri:expenseEntryUri];
            }
            else
            {
                NSArray *array=[self getPreviousExpenseInfoForExpenseEntryUri:expenseEntryUri expenseSheetUri:expenseSheetUri];
                if ([array count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"expenseEntryUri = '%@'",expenseEntryUri];
                    [myDB updateTable:  approvalPreviousExpenseEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalPreviousExpenseEntriesTable data:dataDict intoDatabase:@""];
                }
                [self deletePreviousExpenseTaxCodeInfoForEntryUri:expenseEntryUri];
                [self deletePreviousExpenseCodeInfoForEntryUri:expenseEntryUri];
            }
            
            NSMutableArray *taxAmountArray=[NSMutableArray array];
            if ([status isEqualToString:WAITING_FOR_APRROVAL_STATUS]||[status isEqualToString:APPROVED_STATUS] ||[status isEqualToString:REJECTED_STATUS])
            {
                NSMutableDictionary *pendingTaxAmountDict=[NSMutableDictionary dictionary];
                NSMutableDictionary *pendingExpenseCodeDetailsDict=[NSMutableDictionary dictionary];
                NSMutableArray *incurredAmountTaxesArray=[dict objectForKey:@"incurredAmountTaxes"];
                for (int m=0; m<[incurredAmountTaxesArray count]; m++)
                {
                    NSDictionary *tmpDict=[incurredAmountTaxesArray objectAtIndex:m];
                    NSString *tmpTaxAmount=[[tmpDict objectForKey:@"amount"] objectForKey:@"amount"];
                    NSString *tmpTaxName=[[tmpDict objectForKey:@"taxCode"] objectForKey:@"name"];
                    NSString *tmpTaxUri=[[tmpDict objectForKey:@"taxCode"] objectForKey:@"uri"];
                    NSNumber *uniqueId=[NSNumber numberWithInt:m+1];
                    
                    [pendingTaxAmountDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
                    [pendingTaxAmountDict setObject:tmpTaxName forKey:@"name"];
                    [pendingTaxAmountDict setObject:tmpTaxUri forKey:@"uri"];
                    [pendingTaxAmountDict setObject:tmpTaxAmount forKey:@"taxAmount"];
                    [pendingTaxAmountDict setObject:uniqueId forKey:@"id"];
                    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
                    {
                        [myDB insertIntoTable:approvalExpensePendingTaxCodesTable data:pendingTaxAmountDict intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:approvalExpensePreviousTaxCodesTable data:pendingTaxAmountDict intoDatabase:@""];
                    }
                    
                    
                    [taxAmountArray addObject:tmpTaxAmount];
                    
                }
                
                
                NSString *expenseCodeName=[[dict objectForKey:@"expenseCode"] objectForKey:@"name"];
                NSString *expenseCodeUri=[[dict objectForKey:@"expenseCode"] objectForKey:@"uri"];
                NSString *expenseQuantity=[NSString stringWithFormat:@"%@",[dict objectForKey:@"quantity"]];
                NSString *expenseRate=nil;
                if ([dict objectForKey:@"rate"]!=nil && ![[dict objectForKey:@"rate"] isKindOfClass:[NSNull class]])
                {
                    expenseRate=[NSString stringWithFormat:@"%@",[[dict objectForKey:@"rate"]objectForKey:@"amount"]];
                }
                
                
                NSString *expenseCodeCurrencyName=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"symbol"];
                NSString *expenseCodeCurrencyUri=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"uri"];
                
                NSString *expenseType=nil;
                
                if (expenseQuantity!=nil && expenseRate!=nil
                    &&![expenseQuantity isKindOfClass:[NSNull class]]&& ![expenseRate isKindOfClass:[NSNull class]]
                    &&![expenseQuantity isEqualToString:@""]&&![expenseRate isEqualToString:@""]
                    &&![expenseQuantity isEqualToString:NULL_STRING]&&![expenseRate isEqualToString:NULL_STRING])
                {
                    if ([incurredAmountTaxesArray count]>0 && incurredAmountTaxesArray!=nil)
                    {
                        expenseType=Rated_With_Taxes;
                    }
                    else
                    {
                        expenseType=Rated_WithOut_Taxes;
                    }
                }
                else
                {
                    if ([incurredAmountTaxesArray count]>0 && incurredAmountTaxesArray!=nil)
                    {
                        expenseType=Flat_With_Taxes;
                    }
                    else
                    {
                        expenseType=Flat_WithOut_Taxes;
                    }
                    
                }
                id tmpExpenseRate=nil;
                if (expenseRate!=nil &&  ![expenseRate isKindOfClass:[NSNull class]]&& ![expenseRate isEqualToString:NULL_STRING])
                {
                    tmpExpenseRate=expenseRate;
                }
                else
                {
                    tmpExpenseRate=@"";
                }
                [pendingExpenseCodeDetailsDict setObject:expenseCodeName forKey:@"expenseCodeName"];
                [pendingExpenseCodeDetailsDict setObject:expenseCodeUri forKey:@"expenseCodeUri"];
                [pendingExpenseCodeDetailsDict setObject:expenseType forKey:@"expenseCodeType"];
                [pendingExpenseCodeDetailsDict setObject:@"Quantity" forKey:@"expenseCodeUnitName"];
                [pendingExpenseCodeDetailsDict setObject:tmpExpenseRate forKey:@"expenseCodeRate"];
                [pendingExpenseCodeDetailsDict setObject:expenseCodeCurrencyUri forKey:@"expenseCodeCurrencyUri"];
                [pendingExpenseCodeDetailsDict setObject:expenseCodeCurrencyName forKey:@"expenseCodeCurrencyName"];
                [pendingExpenseCodeDetailsDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
                
                for (int k=0; k<[taxAmountArray count]; k++)
                {
                    NSString *taxAmount=[taxAmountArray objectAtIndex:k];
                    [pendingExpenseCodeDetailsDict setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",k+1]];
                }
                
                if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
                {
                    [myDB insertIntoTable:approvalExpensePendingCodeDetailsTable data:pendingExpenseCodeDetailsDict intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:approvalExpensePreviousCodeDetailsTable data:pendingExpenseCodeDetailsDict intoDatabase:@""];
                }
            }
        }
    }
    
    NSArray *expArr = nil;
    if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
    {
         expArr = [self getPendingExpenseSheetInfoSheetIdentity:expenseSheetUri];
    }
    else
    {
        expArr = [self getPreviousExpenseSheetInfoSheetIdentity:expenseSheetUri];
    }
    if ([expArr count]>0)
    {
        NSMutableDictionary *expensheetDict=[NSMutableDictionary dictionaryWithDictionary:[expArr objectAtIndex:0]];
        NSMutableDictionary *incurredAmountTotalDict=[expenseEntryDetailsDict objectForKey:@"incurredAmountTotal"];
        if (incurredAmountTotalDict!=nil)
        {
            NSString *incurredAmount=[Util getRoundedValueFromDecimalPlaces:[[incurredAmountTotalDict objectForKey:@"amount"] newDoubleValue]withDecimalPlaces:2];
            NSString *incurredAmountCurrencyName=[[incurredAmountTotalDict objectForKey:@"currency"] objectForKey:@"displayText"];
            NSString *incurredAmountCurrencyUri=[[incurredAmountTotalDict objectForKey:@"currency"] objectForKey:@"uri"];
            
            [expensheetDict removeObjectForKey:@"incurredAmount"];
            [expensheetDict removeObjectForKey:@"incurredAmountCurrencyName"];
            [expensheetDict removeObjectForKey:@"incurredAmountCurrencyUri"];
            
            [expensheetDict setObject:incurredAmount forKey:@"incurredAmount"];
            [expensheetDict setObject:incurredAmountCurrencyName forKey:@"incurredAmountCurrencyName"];
            [expensheetDict setObject:incurredAmountCurrencyUri forKey:@"incurredAmountCurrencyUri"];
            
            
            
            
        }
        
        NSDictionary *reimbursementAmountTotalDict=[expenseEntryDetailsDict objectForKey:@"reimbursementAmountTotal"];
        if (reimbursementAmountTotalDict!=nil)
        {
            NSString *reimbursementAmount=[Util getRoundedValueFromDecimalPlaces:[[reimbursementAmountTotalDict objectForKey:@"amount"] newDoubleValue]withDecimalPlaces:2];;
            NSString *reimbursementAmountCurrencyName=[[reimbursementAmountTotalDict objectForKey:@"currency"] objectForKey:@"displayText"];
            NSString *reimbursementAmountCurrencyUri=[[reimbursementAmountTotalDict objectForKey:@"currency"] objectForKey:@"uri"];
            
            [expensheetDict removeObjectForKey:@"reimbursementAmount"];
            [expensheetDict removeObjectForKey:@"reimbursementAmountCurrencyName"];
            [expensheetDict removeObjectForKey:@"reimbursementAmountCurrencyUri"];
            
            [expensheetDict setObject:reimbursementAmount forKey:@"reimbursementAmount"];
            [expensheetDict setObject:reimbursementAmountCurrencyName forKey:@"reimbursementAmountCurrencyName"];
            [expensheetDict setObject:reimbursementAmountCurrencyUri forKey:@"reimbursementAmountCurrencyUri"];
            
        }
        NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@'",expenseSheetUri];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            [myDB updateTable: approvalPendingExpensesheetsTable data:expensheetDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB updateTable: approvalPreviousExpensesheetsTable data:expensheetDict where:whereString intoDatabase:@""];
        }
        
    }
    
    

    
    
    NSArray *approvalDetailsArray=[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"entries"];
    NSMutableArray *approvalDtlsDataArray=[NSMutableArray array];
    
    for (NSDictionary *dict in approvalDetailsArray)
    {
        //Implementation for MOBI-261//JUHI
        NSString *actingForUser=nil;
        NSString *actingUser=nil;
        NSString *comments=nil;
        NSMutableDictionary *approvalDetailDataDict=[NSMutableDictionary dictionary];
        [approvalDetailDataDict setObject:expenseSheetUri forKey:@"expenseSheetUri"];
        
        NSString *action=[[dict objectForKey:@"action"]objectForKey:@"uri"];
        //Fix for Approval status//JUHI
        if ([dict objectForKey:@"timestamp"]!=nil && ![[dict objectForKey:@"timestamp"] isKindOfClass:[NSNull class]])
        {
            NSDate *entryDate=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timestamp"]];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [approvalDetailDataDict setObject:entryDateToStore forKey:@"timestamp"];
            
        }
        
        [approvalDetailDataDict setObject:action forKey:@"actionUri"];
        
        //Implementation for MOBI-261//JUHI
        if ([dict objectForKey:@"authority"]!=nil && ![[dict objectForKey:@"authority"] isKindOfClass:[NSNull class]])
        {
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingForUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingForUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"];
                }
                
            }
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"];
                }
                
            }
        }
        if ([dict objectForKey:@"comments"]!=nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
        {
            comments=[dict objectForKey:@"comments"];
        }
        if (actingForUser!=nil)
        {
            [approvalDetailDataDict setObject:actingForUser                      forKey:@"actingForUser"];
        }
        if (comments!=nil)
        {
            [approvalDetailDataDict setObject:comments                      forKey:@"comments"];
        }
        if (actingUser!=nil)
        {
            [approvalDetailDataDict setObject:actingUser                      forKey:@"actingUser"];
        }
        
        [approvalDtlsDataArray addObject:approvalDetailDataDict];
    }
    
    [self saveExpenseApprovalDetailsDataToDatabase:approvalDtlsDataArray moduleName:approvalsModuleName];
    
}

-(void)saveExpenseIncurredAmountTaxDataToDBForExpenseEntryUri:(NSString *)expenseEntryUri dataArray:(NSMutableArray *)array moduleName:(NSString *)approvalsModuleName
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        NSString *taxAmount=[[dict objectForKey:@"amount"] objectForKey:@"amount"];
        NSString *taxCurrencyName=[[[dict objectForKey:@"amount"] objectForKey:@"currency"] objectForKey:@"displayText"];
        NSString *taxCurrencyUri=[[[dict objectForKey:@"amount"] objectForKey:@"currency"] objectForKey:@"uri"];
        
        NSString *taxcodeName=[[dict  objectForKey:@"taxCode"] objectForKey:@"displayText"];
        NSString *taxcodeUri=[[dict  objectForKey:@"taxCode"] objectForKey:@"uri"];
        
        [dataDict setObject:taxAmount forKey:@"amount"];
        [dataDict setObject:taxCurrencyName forKey:@"currencyName"];
        [dataDict setObject:taxCurrencyUri forKey:@"currencyUri"];
        
        [dataDict setObject:taxcodeName forKey:@"taxCodeName"];
        [dataDict setObject:taxcodeUri forKey:@"taxCodeUri"];
        [dataDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
        
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            NSArray *array=[self getPendingTaxCodeInfoForExpenseEntryUri:expenseEntryUri taxCodeUri:taxcodeUri];
            if ([array count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"expenseEntryUri = '%@'",expenseEntryUri];
                [myDB updateTable: approvalPendingExpenseIncurredAmountTaxTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingExpenseIncurredAmountTaxTable data:dataDict intoDatabase:@""];
            }

        }
        else
        {
            NSArray *array=[self getPreviousTaxCodeInfoForExpenseEntryUri:expenseEntryUri taxCodeUri:taxcodeUri];
            if ([array count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"expenseEntryUri = '%@'",expenseEntryUri];
                [myDB updateTable: approvalPreviousExpenseIncurredAmountTaxTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousExpenseIncurredAmountTaxTable data:dataDict intoDatabase:@""];
            }

        }
                
        
    }
    
}
-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI approvalsModuleName:(NSString *)approvalsModuleName
{
    for (int i=0; i<[sheetCustomFieldsArray count]; i++)
    {
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        NSDictionary *udfDict=[sheetCustomFieldsArray objectAtIndex:i];
        NSString *name=[[udfDict objectForKey:@"customField"]objectForKey:@"displayText"];
        if (name!=nil && ![name isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:name forKey:@"udf_name"];
        }
        NSString *uri=[[udfDict objectForKey:@"customField"]objectForKey:@"uri"];
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:uri forKey:@"udf_uri"];
        }
        NSString *type=[[udfDict objectForKey:@"customFieldType"]objectForKey:@"uri"];
        if (type!=nil && ![type isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:type forKey:@"entry_type"];
            
            if ([type isEqualToString:DROPDOWN_UDF_TYPE])
            {
                NSString *dropDownOptionURI=[udfDict objectForKey:@"dropDownOption"];
                if (dropDownOptionURI!=nil && ![dropDownOptionURI isKindOfClass:[NSNull class]])
                {
                    [udfDataDict setObject:dropDownOptionURI forKey:@"dropDownOptionURI"];
                }
            }
        }
        
        if (entryURI!=nil && ![entryURI isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:entryURI forKey:@"entryUri"];
        }
        
        NSString *value=[udfDict objectForKey:@"text"];
        if ([type isEqualToString:DATE_UDF_TYPE])
        {
            NSString *tmpValue=[udfDict objectForKey:@"date"];
            if (tmpValue!=nil && ![tmpValue isKindOfClass:[NSNull class]])
            {
                value=[Util convertApiTimeDictToDateStringWithDesiredFormat:[udfDict objectForKey:@"date"]];//DE18243 DE18690 DE18728 Ullas M L
            }
        }
        if (value!=nil && ![value isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:value forKey:@"udfValue"];
        }
        
        if (sheetUri!=nil && ![sheetUri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:sheetUri forKey:@"expenseSheetUri"];
        }
        
        if (moduleName!=nil && ![moduleName isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:moduleName forKey:@"moduleName"];
        }
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            NSArray *udfsArr = [self getPendingExpenseCustomFieldsForSheetURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri];
            if ([udfsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
                [myDB updateTable:approvalPendingExpenseCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPendingExpenseCustomFieldsTable data:udfDataDict intoDatabase:@""];
            }

        }
        else
        {
            NSArray *udfsArr = [self getPreviousExpenseCustomFieldsForSheetURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri];
            if ([udfsArr count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
                [myDB updateTable:approvalPreviousExpenseCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:approvalPreviousExpenseCustomFieldsTable data:udfDataDict intoDatabase:@""];
            }

        }
                
        
    }
}

-(NSArray*)getPendingExpenseInfoForExpenseEntryUri:(NSString*)expenseEntryUri expenseSheetUri:(NSString *)expenseSheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' and expenseSheetUri='%@'",approvalPendingExpenseEntriesTable,expenseEntryUri,expenseSheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getPreviousExpenseInfoForExpenseEntryUri:(NSString*)expenseEntryUri expenseSheetUri:(NSString *)expenseSheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' and expenseSheetUri='%@'",approvalPreviousExpenseEntriesTable,expenseEntryUri,expenseSheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getPendingExpenseSheetInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' ",approvalPendingExpensesheetsTable,sheetIdentity];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSArray *)getPreviousExpenseSheetInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' ",approvalPreviousExpensesheetsTable,sheetIdentity];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSArray*)getPendingTaxCodeInfoForExpenseEntryUri:(NSString*)expenseEntryUri taxCodeUri:(NSString *)taxCodeUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' and expenseSheetUri='%@'",approvalPendingExpenseIncurredAmountTaxTable,expenseEntryUri,taxCodeUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getPreviousTaxCodeInfoForExpenseEntryUri:(NSString*)expenseEntryUri taxCodeUri:(NSString *)taxCodeUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' and expenseSheetUri='%@'",approvalPreviousExpenseIncurredAmountTaxTable,expenseEntryUri,taxCodeUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}



-(void)saveExpenseApprovalDetailsDataToDatabase:(NSArray *) expenseDetailsArray moduleName:(NSString *)approvalsModuleName{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	for (int i=0; i<[expenseDetailsArray count]; i++) {
		NSDictionary *dict=[expenseDetailsArray objectAtIndex:i];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            [myDB insertIntoTable:approvalPendingExpenseApprovalHistoryTable data:dict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousExpenseApprovalHistoryTable data:dict intoDatabase:@""];
        }
		
		
	}
	
}

-(NSArray *)getPendingExpenseCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",approvalPendingExpenseCustomFieldsTable,sheetUri,moduleName,entryUri,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getPreviousExpenseCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",approvalPreviousExpenseCustomFieldsTable,sheetUri,moduleName,entryUri,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getExpenseTaxCodesFromDBForTaxCodeUri:(NSString *)taxCodeUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where uri='%@'",approvalExpensePendingTaxCodesTable,taxCodeUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSArray *)getAllTaxCodeUriEntryDetailsFromDBForExpenseEntryUri:(NSString *)expenseEntryUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select taxCodeUri1,taxCodeUri2,taxCodeUri3,taxCodeUri4,taxCodeUri5 from %@ where expenseEntryUri = '%@'",approvalPendingExpenseEntriesTable,expenseEntryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}

-(NSMutableArray *) getPendingTimesheetChangeReasonEntriesFromDB: (NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approveTimesheetReasonForChangeTable,timesheetUri];
	NSMutableArray *changeArr = [myDB executeQueryToConvertUnicodeValues:sql];
    NSMutableArray *uniqueIDArray = [NSMutableArray array];
    NSMutableArray *reasonForChangeArray = [NSMutableArray array];
//    NSMutableArray *finalArray = [NSMutableArray array];
    for (int i = 0; i<[changeArr count]; i++) {
        NSMutableDictionary  *dataDict = [NSMutableDictionary dictionary];
        dataDict = [changeArr objectAtIndex:i];
        NSString * date = [dataDict objectForKey:@"uniqueID"];
            if (![uniqueIDArray containsObject:date]) {
                [uniqueIDArray addObject:date];
            }
    }
//    if ([uniqueIDArray count]>0)
//    {
//		[reasonForChangeArray addObject:FollowingChangesWereMadeToThisTimesheet];
//	}

    
    for (int idIndex = 0; idIndex< [uniqueIDArray count]; idIndex++) {
        NSString *uriQuery = [NSString stringWithFormat:@" select * from %@ where uniqueID='%@' and TimesheetUri='%@'",approveTimesheetReasonForChangeTable, [uniqueIDArray objectAtIndex:idIndex], timesheetUri];
        changeArr = [myDB executeQueryToConvertUnicodeValues:uriQuery];
		[reasonForChangeArray addObject:changeArr];
    }
    
    NSMutableArray *headerArray = [NSMutableArray array];
    for (int i = 0; i<[reasonForChangeArray count]; i++) {
        NSMutableArray *tempArray = [reasonForChangeArray objectAtIndex:i];
        for (int i = 0; i<[tempArray count]; i++) {
            NSMutableDictionary  *dataDict = [NSMutableDictionary dictionary];
            dataDict = [tempArray objectAtIndex:i];
            NSString * header = [dataDict objectForKey:@"header"];
            if (![headerArray containsObject:header]) {
                [headerArray addObject:header];
            }
        }
    }
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int idIndex = 0; idIndex< [uniqueIDArray count]; idIndex++) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int index = 0; index< [headerArray count]; index++) {
            NSString *uriQuery = [NSString stringWithFormat:@" select * from %@ where uniqueID='%@' and header='%@' and TimesheetUri='%@'",approveTimesheetReasonForChangeTable, [uniqueIDArray objectAtIndex:idIndex], [headerArray objectAtIndex:index], timesheetUri];
            changeArr = [myDB executeQueryToConvertUnicodeValues:uriQuery];
            if ([changeArr count] == 0) {
                continue;
            }
            [tempArray addObject:changeArr];
        }
        [dataArray addObject:tempArray];
    }
    
    [dataArray insertObject:FollowingChangesWereMadeToThisTimesheet atIndex:0];
    

    if ([dataArray count]>1)
    {
		return dataArray;
	}
	return nil;
}


#pragma mark -
#pragma mark Delete methods

-(void)deleteAllApprovalPendingTimesheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:approvalPendingTimesheetsTable inDatabase:@""];
}

-(void)deleteAllApprovalPendingExpenseSheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:approvalPendingExpensesheetsTable inDatabase:@""];
}

-(void)deleteAllApprovalPendingTimeOffsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:approvalPendingTimeOffsTable inDatabase:@""];
}

-(void)deleteAllApprovalPreviousTimesheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:approvalPreviousTimesheetsTable inDatabase:@""];
}

-(void)deleteAllApprovalPreviousExpenseFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:approvalPreviousExpensesheetsTable inDatabase:@""];
}

-(void)deleteAllApprovalPreviousTimeOffsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:approvalPreviousTimeOffsTable inDatabase:@""];
}

-(void)deleteApprovalPendingTimesheetsFromDBWithTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where timesheetUri = '%@'",approvalPendingTimesheetsTable,timesheetUri];
	[myDB executeQuery:query];
	
}
-(void)deleteApprovalPendingTimeOffFromDBWithTimeoffUri:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where timeoffUri = '%@'",approvalPendingTimeOffsTable,timeoffUri];
	[myDB executeQuery:query];
	
}
-(void)deleteApprovalPendingExpenseFromDBWithTimeoffUri:(NSString *)expenseSheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseSheetUri = '%@'",approvalPendingExpensesheetsTable,expenseSheetUri];
	[myDB executeQuery:query];
	
}
-(void)deletePendingExpenseTaxCodeInfoForEntryUri:(NSString *)entryURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseEntryUri = '%@'",approvalExpensePendingTaxCodesTable,entryURI];
	[myDB executeQuery:query];
}
-(void)deletePreviousExpenseTaxCodeInfoForEntryUri:(NSString *)entryURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseEntryUri = '%@'",approvalExpensePreviousTaxCodesTable,entryURI];
	[myDB executeQuery:query];
}
-(void)deletePendingExpenseCodeInfoForEntryUri:(NSString *)entryURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseEntryUri = '%@'",approvalExpensePendingCodeDetailsTable,entryURI];
	[myDB executeQuery:query];
}
-(void)deletePreviousExpenseCodeInfoForEntryUri:(NSString *)entryURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseEntryUri = '%@'",approvalExpensePreviousCodeDetailsTable,entryURI];
	[myDB executeQuery:query];
}

-(void)deleteObjectExtensionFieldsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@"delete from %@ where timesheetUri = '%@'",timesheetObjectExtensionFieldsTable,timesheetUri];
    [myDB executeQuery:query];
}

-(NSArray *)getPendingExpenseEntryInfoForSheetIdentity:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryURI
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and expenseEntryUri = '%@'",approvalPendingExpenseEntriesTable,sheetIdentity,entryURI];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSArray *)getPreviousExpenseEntryInfoForSheetIdentity:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryURI
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and expenseEntryUri = '%@'",approvalPreviousExpenseEntriesTable,sheetIdentity,entryURI];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSArray *)getAllPendingExpenseTaxCodesFromDBForEntryUri:(NSString *)entryUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseEntryUri = '%@'",approvalExpensePendingTaxCodesTable,entryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSArray *)getAllPreviousExpenseTaxCodesFromDBForEntryUri:(NSString *)entryUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseEntryUri = '%@'",approvalExpensePreviousTaxCodesTable,entryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}

-(NSArray *)getAllDetailsForPendingExpenseCodeFromDBForEntryUri:(NSString *)entryUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseEntryUri = '%@'",approvalExpensePendingCodeDetailsTable,entryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSArray *)getAllDetailsForPreviousExpenseCodeFromDBForEntryUri:(NSString *)entryUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseEntryUri = '%@'",approvalExpensePreviousCodeDetailsTable,entryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(void)updateTimesheetFormatForPendingApprovalsTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSMutableDictionary *)timesheetFormatDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET timesheetFormat = '%@' WHERE timesheetUri='%@'",approvalPendingTimesheetsTable,GEN4_INOUT_TIMESHEET,timesheetUri];
    [myDB sqliteExecute:sql];

    
}
-(void)updateTimesheetFormatForPreviousApprovalsTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSMutableDictionary *)timesheetFormatDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
   NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET timesheetFormat = '%@' WHERE timesheetUri='%@'",approvalPreviousTimesheetsTable,GEN4_INOUT_TIMESHEET,timesheetUri];
    [myDB sqliteExecute:sql];
}

-(void)saveApprovalsCapablitiesDataIntoDBWithData:(NSMutableArray *)array isPending:(BOOL)isPending forTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    int hasClientAccess =0;
    int hasProjectAccess =0;
    int hasBillingAccess =0;
    int hasActivityAccess =0;
    int hasBreakAccess =0;
    int allowBreakForPunchInGen4=0;
    NSString *disclaimer=@"";
    NSMutableArray *enabledWidgetsUriArrays=[NSMutableArray array];
    for (int i=0; i<[array count]; i++)
    {
        NSString *policyKeyUri=[[array objectAtIndex:i] objectForKey:@"policyKeyUri"];
        NSString *policyValueUri=[[array objectAtIndex:i] objectForKey:@"policyKeyUri"];
        id policyValue=[[[array objectAtIndex:i] objectForKey:@"policyValue"] objectForKey:@"uri"];;
        NSDictionary *policyValueDict=[[array objectAtIndex:i] objectForKey:@"policyValue"];
        NSString *widgetUriPolicyFindingUri = @"urn:replicon:policy:timesheet:widget-timesheet";
        if ([policyKeyUri rangeOfString:widgetUriPolicyFindingUri].location == NSNotFound)
        {
            //Do nothing since its not a widget
        }
        else
        {
            if ([policyKeyUri isEqualToString:PUNCH_WIDGET_URI]||
                [policyKeyUri isEqualToString:INOUT_WIDGET_URI]||
                [policyKeyUri isEqualToString:APPROVAL_HISTORY_WIDGET_URI]||
                [policyKeyUri isEqualToString:NOTICE_WIDGET_URI]||
                [policyKeyUri isEqualToString:STANDARD_WIDGET_URI]||
                [policyKeyUri isEqualToString:ATTESTATION_WIDGET_URI]||
                [policyKeyUri isEqualToString:TIMEOFF_WIDGET_URI]||
                [policyKeyUri isEqualToString:EXT_INOUT_WIDGET_URI])
            {
                if (policyValueDict!=nil && ![policyValueDict isKindOfClass:[NSNull class]])
                {
                    BOOL isWidgetEnabled=[[policyValueDict objectForKey:@"bool"] boolValue];
                    if (isWidgetEnabled)
                    {
                        int orderNo=[[policyValueDict objectForKey:@"number"] intValue];
                        int enabled=1;
                        NSNumber *orderNumber=[NSNumber numberWithInt:orderNo];
                        NSString *widgetUri=policyKeyUri;
                        NSNumber *supportedInMobile=[NSNumber numberWithBool:YES];
                        if ([policyKeyUri isEqualToString:NOTICE_WIDGET_URI])
                        {
                            NSMutableDictionary *dataDisclaimerDict=[NSMutableDictionary dictionary];
                            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                            {
                                [dataDisclaimerDict setObject:timesheetUri forKey:@"timesheetUri"];
                            }
                            NSMutableArray *collectionArray=[policyValueDict objectForKey:@"collection"];
                            for (int b=0; b<[collectionArray count]; b++)
                            {
                                NSString *uri=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                                NSString *text=[[collectionArray objectAtIndex:b] objectForKey:@"text"];
                                if ([uri isEqualToString:NOTICE_WIDGET_DESCRIPTION_URI])
                                {
                                    [dataDisclaimerDict setObject:text forKey:@"description"];
                                }
                                else if ([uri isEqualToString:NOTICE_WIDGET_TITLE_URI])
                                {
                                    [dataDisclaimerDict setObject:text forKey:@"title"];
                                    
                                }
                                
                            }
                            if ([collectionArray count]>0)
                            {
                                enabled=1;
                                [self saveWidgetTimesheetDisclaimerDataToDB:dataDisclaimerDict isPending:isPending];
                            }
                            else
                            {
                                enabled=0;
                            }
                            
                        }
                        else if ([policyKeyUri isEqualToString:ATTESTATION_WIDGET_URI])
                        {
                            NSMutableDictionary *dataAttestationDict=[NSMutableDictionary dictionary];
                            if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                            {
                                [dataAttestationDict setObject:timesheetUri forKey:@"timesheetUri"];
                            }
                            NSMutableArray *collectionArray=[policyValueDict objectForKey:@"collection"];
                            for (int b=0; b<[collectionArray count]; b++)
                            {
                                NSString *uri=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                                NSString *text=[[collectionArray objectAtIndex:b] objectForKey:@"text"];
                                if ([uri isEqualToString:ATTESTATION_WIDGET_DESCRIPTION_URI])
                                {
                                    [dataAttestationDict setObject:text forKey:@"description"];
                                }
                                else if ([uri isEqualToString:ATTESTATION_WIDGET_TITLE_URI])
                                {
                                    [dataAttestationDict setObject:text forKey:@"title"];
                                    
                                }
                            }
                            if ([collectionArray count]>0)
                            {
                                enabled=1;
                                [self saveWidgetTimesheetAttestationDataToDB:dataAttestationDict isPending:isPending];
                            }
                            else
                            {
                                enabled=0;
                            }
                            
                        }
                        NSNumber *enabledNumber=[NSNumber numberWithInt:enabled];
                        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            orderNumber,@"orderNo",
                                            widgetUri,@"widgetUri",
                                            supportedInMobile,@"supportedInMobile",enabledNumber,@"enabled",nil];
                        [enabledWidgetsUriArrays addObject:dict];
                    }
                    
                }
            }
            else
            {

                if (policyValueDict!=nil && ![policyValueDict isKindOfClass:[NSNull class]])
                {
                    BOOL isWidgetEnabled=[[policyValueDict objectForKey:@"bool"] boolValue];
                    if (isWidgetEnabled)
                    {
                        int orderNo=[[policyValueDict objectForKey:@"number"] intValue];
                        int enabled=0;
                        NSNumber *orderNumber=[NSNumber numberWithInt:orderNo];
                        NSString *widgetUri=policyKeyUri;
                        NSNumber *supportedInMobile=[NSNumber numberWithBool:NO];
                        NSNumber *enabledNumber=[NSNumber numberWithInt:enabled];
                        NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            orderNumber,@"orderNo",
                                            widgetUri,@"widgetUri",
                                            supportedInMobile,@"supportedInMobile",enabledNumber,@"enabled",nil];
                        [enabledWidgetsUriArrays addObject:dict];
                    }
                }


            }
        }

        if ([policyKeyUri isEqualToString:PUNCH_BREAK_ACCESS_KEY])
        {
            if ([policyValue isEqualToString:NotAllowedPunchInBreakPolicyValueUri])
            {
                allowBreakForPunchInGen4=0;
            }
            else
            {
                allowBreakForPunchInGen4=1;
            }
        }
        
        if ([policyKeyUri isEqualToString:Gen4InOutTimesheetFormat])
        {
            
            NSArray *collectionArray=[[[array objectAtIndex:i] objectForKey:@"policyValue"] objectForKey:@"collection"];
            
            NSString *tmpPolicyKey=nil;
            for (int b=0; b<[collectionArray count]; b++) {
                
                NSString *tmpPolicyValue=nil;
                if (b%2==0)
                {
                    tmpPolicyKey=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                }
                else
                {
                    tmpPolicyValue=[[collectionArray objectAtIndex:b]objectForKey:@"uri"];
                }
                if ([tmpPolicyKey isEqualToString:GEN4_INOUT_BREAK_POLICY_URI])
                {
                    if ([tmpPolicyValue isEqualToString:EnableBreakUriPolicyValueUri])
                    {
                        tmpPolicyKey=nil;
                        hasBreakAccess=1;
                    }
                    
                }
            }
        }

        if ([policyKeyUri isEqualToString:CLIENT_POLICY_SELECTION])
        {
            if ([policyValueUri isEqualToString:DO_NOT_SELECT_CLIENT_URI])
            {
                hasClientAccess=0;
            }
        }
        if ([policyKeyUri isEqualToString:PROJECT_POLICY_SELECTION])
        {
            if ([policyValueUri isEqualToString:DO_NOT_SELECT_PROJECT_URI])
            {
                hasProjectAccess=0;
            }
        }
        else if ([policyKeyUri isEqualToString:BILLING_POLICY_SELECTION])
        {
            if ([policyValueUri isEqualToString:DO_NOT_SELECT_BILLING_URI])
            {
                hasBillingAccess=0;
            }
        }
        else if ([policyKeyUri isEqualToString:ACTIVITY_POLICY_SELECTION])
        {
            if ([policyValueUri isEqualToString:DO_NOT_SELECT_ACTIVITY_URI])
            {
                hasActivityAccess=0;
            }
        }
        /*else if ([policyKeyUri isEqualToString:BREAK_POLICY_SELECTION])
        {
            if ([policyValueUri isEqualToString:ALLOW_SELECT_BREAK_URI])
            {
                hasBreakAccess=1;
            }
        }*/
        else if ([policyKeyUri isEqualToString:DISCLAIMER_POLICY_SELECTION])
        {
            disclaimer=policyValueUri;
        }
        
    }
    
    NSMutableDictionary *capabilityDictionary=[NSMutableDictionary dictionary];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasBillingAccess] forKey:@"hasTimesheetBillingAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasProjectAccess] forKey:@"hasTimesheetProjectAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasClientAccess] forKey:@"hasTimesheetClientAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasActivityAccess] forKey:@"hasTimesheetActivityAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasBreakAccess] forKey:@"hasTimesheetBreakAccess"];
    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [capabilityDictionary setObject:timesheetUri                               forKey:@"timesheetUri"];
    }
    [capabilityDictionary setObject:disclaimer  forKey:@"disclaimerTimesheetNoticePolicyUri"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:allowBreakForPunchInGen4]  forKey:@"hasTimepunchBreakAccess"];
    
    if (isPending)
    {
        
        //[myDB deleteFromTable:approvalPendingTimesheetCapabilitiesTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        NSMutableArray *expArr = [self getPendingTimesheetCapabilityStatusForSheetUri:timesheetUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri];
            [myDB updateTable:approvalPendingTimesheetCapabilitiesTable  data:capabilityDictionary where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPendingTimesheetCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
        }
        
        
    }
    else
    {
        //[myDB deleteFromTable:approvalPreviousTimesheetsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        NSMutableArray *expArr = [self getPreviousTimesheetCapabilityStatusForSheetUri:timesheetUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri];
            [myDB updateTable:approvalPreviousTimesheetCapabilitiesTable  data:capabilityDictionary where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousTimesheetCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
        }
        
        
    }
    if (isPending)
    {
       [myDB deleteFromTable:pendingEnabledWidgetsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:previousEnabledWidgetsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
    }
    
    
    for (int k=0; k<[enabledWidgetsUriArrays count]; k++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSDictionary *dict=[enabledWidgetsUriArrays objectAtIndex:k];
        NSNumber *orderNo=[NSNumber numberWithInt:[[dict objectForKey:@"orderNo"] intValue]];
        NSString *widgetUri=[NSString stringWithFormat:@"%@",[dict objectForKey:@"widgetUri"]];
        NSNumber *supportedInMobile=[NSNumber numberWithBool:[[dict objectForKey:@"supportedInMobile"] boolValue]];
        NSNumber *enabled=[NSNumber numberWithInt:[[dict objectForKey:@"enabled"] intValue]];
        [dataDict setObject:widgetUri forKey:@"widgetUri"];
        [dataDict setObject:orderNo forKey:@"orderNo"];
        [dataDict setObject:supportedInMobile forKey:@"supportedInMobile"];
        [dataDict setObject:enabled forKey:@"enabled"];
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        }
        if (isPending)
        {
            [myDB insertIntoTable:pendingEnabledWidgetsTable data:dataDict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:previousEnabledWidgetsTable data:dataDict intoDatabase:@""];
        }
        
    }
    
    
}
-(NSArray*)getPreviousTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@'",approvalPreviousTimeEntriesTable,rowUri,timesheetUri,entryDate];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,rowUri,timesheetUri,entryDate,tsFormat];
    }

	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}


-(NSArray*)getPreviousTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate forTimesheetFormat:(NSString *)timesheetFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString * query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,rowUri,timesheetUri,entryDate,timesheetFormat];
    
    
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
    if ([array count]!=0) {
        return array;
    }
    return nil;
}

-(NSArray*)getPendingTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@'",approvalPendingTimeEntriesTable,rowUri,timesheetUri,entryDate];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,rowUri,timesheetUri,entryDate,tsFormat];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray*)getPendingTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate forTimesheetFormat:(NSString *)timesheetFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString * query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,rowUri,timesheetUri,entryDate,timesheetFormat];

    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
    if ([array count]!=0) {
        return array;
    }
    return nil;
}

//Implementation for MOBI-261//JUHI
-(NSMutableArray *) getAllPendingExpenseSheetApprovalFromDBForExpenseSheet:(NSString *)expenseSheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseSheetUri='%@'",approvalPendingExpenseApprovalHistoryTable,expenseSheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousExpenseSheetApprovalFromDBForExpenseSheet:(NSString *)expenseSheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseSheetUri='%@'",approvalPreviousExpenseApprovalHistoryTable,expenseSheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(void)saveTimeoffApprovalDetailsDataToDatabase:(NSArray *) timeoffDetailsArray moduleName:(NSString *)approvalsModuleName{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	for (int i=0; i<[timeoffDetailsArray count]; i++) {
		NSDictionary *dict=[timeoffDetailsArray objectAtIndex:i];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            [myDB insertIntoTable:approvalPendingApprovalTimeOffApprovalHistoryTable data:dict intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:approvalPreviousApprovalTimeOffApprovalHistoryTable data:dict intoDatabase:@""];
        }
		
		
	}
	
}
-(NSMutableArray *) getAllPendingTimeoffApprovalFromDBForTimeoff:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",approvalPendingApprovalTimeOffApprovalHistoryTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllPreviousTimeoffApprovalFromDBForTimeoff:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",approvalPreviousApprovalTimeOffApprovalHistoryTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
//US9453 to address DE17320 Ullas M L
-(void)updateCustomFieldTableFor:(NSString *)udfModuleName enableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",userDeFinedFieldsTable,udfModuleName];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	for (int k=0; k<[array count]; k++)
    {
        NSString *uri=[[array objectAtIndex:k] objectForKey:@"uri"];
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableDictionary *udfInfoDict=[loginModel getDataforUDFWithIdentity:uri];
        BOOL isUdfEnabled=[[udfInfoDict objectForKey:@"enabled"] boolValue];
        NSString *moduleName=[udfInfoDict objectForKey:@"moduleName"];
        if ([moduleName isEqualToString:TIMESHEET_SHEET_UDF]||
            [moduleName isEqualToString:TIMESHEET_CELL_UDF]||
            [moduleName isEqualToString:TIMESHEET_ROW_UDF])
        {
            if ([enabledOnlyUdfUriArray containsObject:uri] && isUdfEnabled)
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where moduleName='%@' and uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:1],udfModuleName,uri];
                [myDB executeQuery:sql];
            }
            else
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where moduleName='%@' and uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:0],udfModuleName,uri];
                [myDB executeQuery:sql];
                
            }
        }
      
        
        
        
        
    }
	
}

-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPending:(NSMutableArray *)array1 andArray:(NSMutableArray *)array2 forTimesheetUri:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array1 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array1 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        [myDB insertIntoTable:udfPendingPreferencesTable data:dataDict intoDatabase:@""];
    }
    for (int i=0; i<[array2 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array2 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        [myDB insertIntoTable:udfPendingPreferencesTable data:dataDict intoDatabase:@""];
    }
    
}

-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPrevious:(NSMutableArray *)array1 andArray:(NSMutableArray *)array2 forTimesheetUri:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array1 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array1 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        [myDB insertIntoTable:udfPreviousPreferencesTable data:dataDict intoDatabase:@""];
    }
    for (int i=0; i<[array2 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array2 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        [myDB insertIntoTable:udfPreviousPreferencesTable data:dataDict intoDatabase:@""];
    }
    
}
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimesheetUriForPending:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",udfPendingPreferencesTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimesheetUriForPrevious:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",udfPreviousPreferencesTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(void)updateCustomFieldTableForEnableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",userDeFinedFieldsTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	for (int k=0; k<[array count]; k++)
    {
        NSString *uri=[[array objectAtIndex:k] objectForKey:@"uri"];
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableDictionary *udfInfoDict=[loginModel getDataforUDFWithIdentity:uri];
        BOOL isUdfEnabled=[[udfInfoDict objectForKey:@"enabled"] boolValue];
        NSString *moduleName=[udfInfoDict objectForKey:@"moduleName"];
        if ([moduleName isEqualToString:TIMESHEET_SHEET_UDF]||
            [moduleName isEqualToString:TIMESHEET_CELL_UDF]||
            [moduleName isEqualToString:TIMESHEET_ROW_UDF])
        {
            if ([enabledOnlyUdfUriArray containsObject:uri] && isUdfEnabled)
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:1],uri];
                [myDB executeQuery:sql];
            }
            else
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:0],uri];
                [myDB executeQuery:sql];
                
            }
        }
        
        
    }
	
}


-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPending:(NSMutableArray *)array1 forTimeoffUri:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array1 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array1 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timeoffUri"];
        [myDB insertIntoTable:udfPendingTimeoffPreferencesTable data:dataDict intoDatabase:@""];
    }
    
    
    
}

-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArrayForPrevious:(NSMutableArray *)array1 forTimeoffUri:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array1 count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSString *udfUri=[array1 objectAtIndex:i];
        if (udfUri==nil ||[udfUri isKindOfClass:[NSNull class]])
        {
            udfUri=@"";
        }
        [dataDict setObject:udfUri forKey:@"udfUri"];
        [dataDict setObject:timesheetUri forKey:@"timeoffUri"];
        [myDB insertIntoTable:udfPreviousTimeoffPreferencesTable data:dataDict intoDatabase:@""];
    }
    
    
}

-(NSMutableArray *)getEnabledOnlyUdfArrayForTimeoffUriForPending:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",udfPendingTimeoffPreferencesTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
    
	return nil;
}
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimeoffUriForPrevious:(NSString *)timeoffUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timeoffUri='%@'",udfPreviousTimeoffPreferencesTable,timeoffUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(void)updateCustomFieldTableForEnableUdfuriArrayForTimeoffs:(NSMutableArray *)enabledOnlyUdfUriArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",userDeFinedFieldsTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	for (int k=0; k<[array count]; k++)
    {
        NSString *uri=[[array objectAtIndex:k] objectForKey:@"uri"];
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableDictionary *udfInfoDict=[loginModel getDataforUDFWithIdentity:uri];
        BOOL isUdfEnabled=[[udfInfoDict objectForKey:@"enabled"] boolValue];
        NSString *moduleName=[udfInfoDict objectForKey:@"moduleName"];
        if ([moduleName isEqualToString:TIMEOFF_UDF])
        {
            if ([enabledOnlyUdfUriArray containsObject:uri] && isUdfEnabled)
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:1],uri];
                [myDB executeQuery:sql];
            }
            else
            {
                NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET enabled='%@' where uri='%@' ",userDeFinedFieldsTable,[NSNumber numberWithInt:0],uri];
                [myDB executeQuery:sql];
                
            }
        }
        
        
    }
	
}


-(NSMutableDictionary *)getPendingSumOfDurationHoursForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPendingTimeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,timesheetUri,tsFormat];
    }

    NSMutableArray *totalHoursUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    float breakHours=0;
    float regularHours=0;
    float timeoffHours=0;
    for (int n=0; n<[totalHoursUsersFromDB count]; n++)
    {
        NSMutableDictionary *dataDict=[totalHoursUsersFromDB objectAtIndex:n];
        NSString *timeOffUri=[dataDict objectForKey:@"timeOffUri"];
        if (timeOffUri==nil||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:@""])
        {
            NSString *breakUri=[dataDict objectForKey:@"breakUri"];
            id durationDecimalFormat=[dataDict objectForKey:@"durationDecimalFormat"];
            if (durationDecimalFormat!=nil && ![durationDecimalFormat isKindOfClass:[NSNull class]])
            {
                if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
                {
                    
                    regularHours=regularHours+[[dataDict objectForKey:@"durationDecimalFormat"] newFloatValue];
                }
                else
                {
                    breakHours=breakHours+[[dataDict objectForKey:@"durationDecimalFormat"] newFloatValue];
                }
            }
            
        }
        else
        {
            id durationDecimalFormat=[dataDict objectForKey:@"durationDecimalFormat"];
            if (durationDecimalFormat!=nil && ![durationDecimalFormat isKindOfClass:[NSNull class]])
            {
                timeoffHours=timeoffHours+[[dataDict objectForKey:@"durationDecimalFormat"] newFloatValue];
            }
        }
    }
    
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[Util getRoundedValueFromDecimalPlaces:regularHours withDecimalPlaces:2],@"regularHours",[Util getRoundedValueFromDecimalPlaces:breakHours withDecimalPlaces:2],@"breakHours",[Util getRoundedValueFromDecimalPlaces:timeoffHours withDecimalPlaces:2],@"timeoffHours", nil];
    
    return dict;
}
-(NSMutableDictionary *)getPreviousSumOfDurationHoursForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",approvalPreviousTimeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,timesheetUri,tsFormat];
    }

    NSMutableArray *totalHoursUsersFromDB =[myDB executeQueryToConvertUnicodeValues:disntinctsql];
    float breakHours=0;
    float regularHours=0;
    float timeoffHours=0;
    for (int n=0; n<[totalHoursUsersFromDB count]; n++)
    {
        NSMutableDictionary *dataDict=[totalHoursUsersFromDB objectAtIndex:n];
        NSString *timeOffUri=[dataDict objectForKey:@"timeOffUri"];
        if (timeOffUri==nil||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:@""])
        {
            NSString *breakUri=[dataDict objectForKey:@"breakUri"];
            id durationDecimalFormat=[dataDict objectForKey:@"durationDecimalFormat"];
            if (durationDecimalFormat!=nil && ![durationDecimalFormat isKindOfClass:[NSNull class]])
            {
                if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
                {
                    
                    regularHours=regularHours+[[dataDict objectForKey:@"durationDecimalFormat"] newFloatValue];
                }
                else
                {
                    breakHours=breakHours+[[dataDict objectForKey:@"durationDecimalFormat"] newFloatValue];
                }
            }
            
        }
        else
        {
            id durationDecimalFormat=[dataDict objectForKey:@"durationDecimalFormat"];
            if (durationDecimalFormat!=nil && ![durationDecimalFormat isKindOfClass:[NSNull class]])
            {
                timeoffHours=timeoffHours+[[dataDict objectForKey:@"durationDecimalFormat"] newFloatValue];
            }
        }
    }
    
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[Util getRoundedValueFromDecimalPlaces:regularHours withDecimalPlaces:2],@"regularHours",[Util getRoundedValueFromDecimalPlaces:breakHours withDecimalPlaces:2],@"breakHours",[Util getRoundedValueFromDecimalPlaces:timeoffHours withDecimalPlaces:2],@"timeoffHours", nil];
    
    return dict;
}

-(NSMutableArray *)getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and supportedInMobile=1 and enabled=1 order by orderNo asc",pendingEnabledWidgetsTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    for (int i=0;i<[array count];i++)
    {
        NSDictionary *enabledWidgetDict=[array objectAtIndex:i];
        NSString *widgetUri=[enabledWidgetDict objectForKey:@"widgetUri"];
        if ([widgetUri isEqualToString:ATTESTATION_WIDGET_URI])
        {
            [array removeObjectAtIndex:i];
            [array addObject:enabledWidgetDict];
            break;
        }
    }
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and supportedInMobile=1 and enabled=1 order by orderNo asc",previousEnabledWidgetsTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    for (int i=0;i<[array count];i++)
    {
        NSDictionary *enabledWidgetDict=[array objectAtIndex:i];
        NSString *widgetUri=[enabledWidgetDict objectForKey:@"widgetUri"];
        if ([widgetUri isEqualToString:ATTESTATION_WIDGET_URI])
        {
            [array removeObjectAtIndex:i];
            [array addObject:enabledWidgetDict];
            break;
        }
    }
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}


-(NSMutableArray *)getAllSupportedAndNotSupportedPendingWidgetsForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' order by orderNo asc",pendingEnabledWidgetsTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;

}

-(NSMutableArray *)getAllSupportedAndNotSupportedPreviousWidgetsForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' order by orderNo asc",previousEnabledWidgetsTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;

}

-(NSMutableArray *)getNotSupportedPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and supportedInMobile=0 order by orderNo asc",pendingEnabledWidgetsTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    NSMutableArray *filteredArray = [@[] mutableCopy];
    for (NSDictionary *widgetDict in array)
    {
        NSString *policyKeyUri = widgetDict[@"widgetUri"];
        if ([[WidgetsManager sharedInstance] isValueAvailableWithKey:policyKeyUri])
        {
            [filteredArray addObject:widgetDict];
        }
    }
    
    if ([filteredArray count]>0)
    {
        return filteredArray;
    }
    return nil;
}
-(NSMutableArray *)getNotSupportedPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and supportedInMobile=0 order by orderNo asc",previousEnabledWidgetsTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    NSMutableArray *filteredArray = [@[] mutableCopy];
    for (NSDictionary *widgetDict in array)
    {
        NSString *policyKeyUri = widgetDict[@"widgetUri"];
        if ([[WidgetsManager sharedInstance] isValueAvailableWithKey:policyKeyUri])
        {
            [filteredArray addObject:widgetDict];
        }
    }
    
    if ([filteredArray count]>0)
    {
        return filteredArray;
    }
    return nil;
}


-(void)saveWidgetTimesheetDisclaimerDataToDB:(NSMutableDictionary *)disclaimerDict isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disclaimerDescription=[disclaimerDict objectForKey:@"description"];
    NSString *disclaimerTitle=[disclaimerDict objectForKey:@"title"];
    NSString *timesheetUri=[disclaimerDict objectForKey:@"timesheetUri"];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    if (isPending)
    {
         [myDB deleteFromTable:pendingWidgetDisclaimerTable where:whereStr inDatabase:@""];
    }
    else
    {
         [myDB deleteFromTable:previousWidgetDisclaimerTable where:whereStr inDatabase:@""];
    }
   
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if(disclaimerDescription!=nil && ![disclaimerDescription isKindOfClass:[NSNull class]])
    {
       [dataDict setObject:disclaimerDescription forKey:@"description"];
    }
    if(disclaimerTitle!=nil && ![disclaimerTitle isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:disclaimerTitle forKey:@"title"];
    }
    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    }
    if (isPending)
    {
        [myDB insertIntoTable:pendingWidgetDisclaimerTable data:dataDict intoDatabase:@""];
    }
    else
    {
        [myDB insertIntoTable:previousWidgetDisclaimerTable data:dataDict intoDatabase:@""];
    }
    
}

-(void)saveWidgetTimesheetAttestationDataToDB:(NSMutableDictionary *)attestationDict isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *attestationDescription=[attestationDict objectForKey:@"description"];
    NSString *attestationTitle=[attestationDict objectForKey:@"title"];
    NSString *timesheetUri=[attestationDict objectForKey:@"timesheetUri"];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    if (isPending)
    {
        [myDB deleteFromTable:pendingWidgetAttestationTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:previousWidgetAttestationTable where:whereStr inDatabase:@""];
    }
    
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if(attestationDescription!=nil && ![attestationDescription isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:attestationDescription forKey:@"description"];
    }
    if(attestationTitle!=nil && ![attestationTitle isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:attestationTitle forKey:@"title"];
    }
    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    }
    if (isPending)
    {
        [myDB insertIntoTable:pendingWidgetAttestationTable data:dataDict intoDatabase:@""];
    }
    else
    {
        [myDB insertIntoTable:previousWidgetAttestationTable data:dataDict intoDatabase:@""];
    }
    
}

-(void)updateAttestationStatusForTimesheetIdentity:(NSString *)timesheetUri withStatus:(BOOL)isSelected isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:[NSNumber numberWithBool:isSelected] forKey:@"attestationStatus"];
    if (isPending)
    {
         [myDB updateTable:pendingWidgetAttestationTable data:dataDict where:whereString intoDatabase:@""];
    }
    else
    {
         [myDB updateTable:previousWidgetAttestationTable data:dataDict where:whereString intoDatabase:@""];
    }
   
}


-(NSMutableDictionary *)getDisclaimerDetailsFromDBForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    if (isPending)
    {
        tableName=pendingWidgetDisclaimerTable;
    }
    else
    {
        tableName=previousWidgetDisclaimerTable;
    }
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",tableName,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return [array objectAtIndex:0];
	}
	return nil;
    
}

-(NSMutableDictionary *)getAttestationDetailsFromDBForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    if (isPending)
    {
        tableName=pendingWidgetAttestationTable;
    }
    else
    {
        tableName=previousWidgetAttestationTable;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",tableName,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return [array objectAtIndex:0];
    }
    return nil;
    
}

-(NSMutableDictionary *)getWidgetSummaryForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    if (isPending)
    {
        tableName=WidgetPendingTimesheetSummaryTable;
    }
    else
    {
        tableName=WidgetPreviousTimesheetSummaryTable;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",tableName,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return [array objectAtIndex:0];
    }
    return nil;
}
-(void)saveEnabledWidgetsDetailsIntoDB:(NSDictionary *)response andTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    NSMutableArray *widgetTimesheetResponse=[response objectForKey:@"capabilities"][@"widgetTimesheetCapabilities"];

    NSMutableArray *enabledWidgetsUriArrays=[NSMutableArray array];
    for (int h=0; h<[widgetTimesheetResponse count]; h++)
    {
        NSMutableDictionary *responseDict=[widgetTimesheetResponse objectAtIndex:h];
        if (responseDict!=nil &&![responseDict isKindOfClass:[NSNull class]])
        {
            NSString *policyKeyUri=[responseDict objectForKey:@"policyKeyUri"];
            //id policyValue=[[responseDict objectForKey:@"policyValue"] objectForKey:@"uri"];
            NSDictionary *policyValueDict=[responseDict objectForKey:@"policyValue"];
            NSString *widgetUriPolicyFindingUri = @"urn:replicon:policy:timesheet:widget-timesheet";
            if ([policyKeyUri rangeOfString:widgetUriPolicyFindingUri].location == NSNotFound)
            {
                //Do nothing since its not a widget
            }
            else
            {
                if ([policyKeyUri isEqualToString:PUNCH_WIDGET_URI]||
                    [policyKeyUri isEqualToString:INOUT_WIDGET_URI]||
                    [policyKeyUri isEqualToString:APPROVAL_HISTORY_WIDGET_URI]||
                    [policyKeyUri isEqualToString:NOTICE_WIDGET_URI]||
                    [policyKeyUri isEqualToString:STANDARD_WIDGET_URI]||
                    [policyKeyUri isEqualToString:ATTESTATION_WIDGET_URI]||
                    [policyKeyUri isEqualToString:PAYSUMMARY_WIDGET_URI]||
                    [policyKeyUri isEqualToString:TIMEOFF_WIDGET_URI]||
                    [policyKeyUri isEqualToString:EXT_INOUT_WIDGET_URI]||
                    [policyKeyUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
                {
                    if (policyValueDict!=nil && ![policyValueDict isKindOfClass:[NSNull class]])
                    {
                        BOOL isWidgetEnabled=[[policyValueDict objectForKey:@"bool"] boolValue];
                        if (isWidgetEnabled)
                        {
                            int orderNo=[[policyValueDict objectForKey:@"number"] intValue];
                            NSNumber *orderNumber=[NSNumber numberWithInt:orderNo];
                            NSString *widgetUri=policyKeyUri;
                            NSNumber *supportedInMobile=[NSNumber numberWithBool:YES];
                            int enabled=1;
                            NSString *widgetTitle=nil;
                            if ([policyKeyUri isEqualToString:NOTICE_WIDGET_URI])
                            {
                                NSMutableDictionary *dataDisclaimerDict=[NSMutableDictionary dictionary];
                                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                {
                                    [dataDisclaimerDict setObject:timesheetUri forKey:@"timesheetUri"];
                                }
                                NSMutableArray *collectionArray=[policyValueDict objectForKey:@"collection"];
                                for (int b=0; b<[collectionArray count]; b++)
                                {
                                    NSString *uri=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                                    NSString *text=[[collectionArray objectAtIndex:b] objectForKey:@"text"];
                                    if ([uri isEqualToString:NOTICE_WIDGET_DESCRIPTION_URI])
                                    {
                                        [dataDisclaimerDict setObject:text forKey:@"description"];
                                    }
                                    else if ([uri isEqualToString:NOTICE_WIDGET_TITLE_URI])
                                    {
                                        [dataDisclaimerDict setObject:text forKey:@"title"];
                                        
                                    }
                                    
                                }
                                if ([collectionArray count]>0)
                                {
                                    enabled=1;
                                    [self saveWidgetTimesheetDisclaimerDataToDB:dataDisclaimerDict isPending:isPending];
                                }
                                else
                                {
                                    enabled=0;
                                }
                                
                            }
                            else if ([policyKeyUri isEqualToString:ATTESTATION_WIDGET_URI])
                            {
                                NSMutableDictionary *dataAttestationDict=[NSMutableDictionary dictionary];
                                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                                {
                                    [dataAttestationDict setObject:timesheetUri forKey:@"timesheetUri"];
                                }
                                NSMutableArray *collectionArray=[policyValueDict objectForKey:@"collection"];
                                for (int b=0; b<[collectionArray count]; b++)
                                {
                                    NSString *uri=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
                                    NSString *text=[[collectionArray objectAtIndex:b] objectForKey:@"text"];
                                    if ([uri isEqualToString:ATTESTATION_WIDGET_DESCRIPTION_URI])
                                    {
                                        [dataAttestationDict setObject:text forKey:@"description"];
                                    }
                                    else if ([uri isEqualToString:ATTESTATION_WIDGET_TITLE_URI])
                                    {
                                        [dataAttestationDict setObject:text forKey:@"title"];
                                        
                                    }
                                }
                                if ([collectionArray count]>0)
                                {
                                    enabled=1;
                                    [self saveWidgetTimesheetAttestationDataToDB:dataAttestationDict isPending:isPending];
                                }
                                else
                                {
                                    enabled=0;
                                }
                                
                            }
                            else if ([policyKeyUri isEqualToString:PAYSUMMARY_WIDGET_URI])
                            {
                                BOOL displayAmountInPaysummary = NO;
                                NSMutableArray *collectionArray=[policyValueDict objectForKey:@"collection"];
                                for (int b=0; b<[collectionArray count]; b++)
                                {

                                    NSString *uri = collectionArray[b][@"uri"];
                                    if ([uri isEqualToString:DISPLAY_AMOUNT_IN_PAYSUMMARY_WIDGET_URI]) {
                                        displayAmountInPaysummary = YES;
                                    }
                                }
                                enabled=1;
                                [self saveWidgetTimesheetPayrollSummaryDataToDB:response isPending:isPending displayPayamount:displayAmountInPaysummary andTimesheetURI:timesheetUri];

                            }
                            else if ([policyKeyUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
                            {
                                NSMutableArray *collectionArray=[policyValueDict objectForKey:@"collection"];
                                for (int b=0; b<[collectionArray count]; b++)
                                {
                                    NSString *uri = collectionArray[b][@"uri"];
                                    if ([uri isEqualToString:DAILY_FIELDS_WIDGET_TITLE_URI]) {
                                        widgetTitle = collectionArray[b][@"text"];
                                    }
                                }

                                enabled=1;

                                
                            }


                            NSNumber *enabledNumber=[NSNumber numberWithInt:enabled];
                            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                orderNumber,@"orderNo",
                                                widgetUri,@"widgetUri",
                                                supportedInMobile,@"supportedInMobile",enabledNumber,@"enabled",nil];
                            if (widgetTitle)
                            {
                                [dict setObject:widgetTitle forKey:@"widgetTitle"];
                            }
                            [enabledWidgetsUriArrays addObject:dict];
                        }
                        
                        
                    }
                }
                else
                {

                    if (policyValueDict!=nil && ![policyValueDict isKindOfClass:[NSNull class]])
                    {
                        BOOL isWidgetEnabled=[[policyValueDict objectForKey:@"bool"] boolValue];
                        if (isWidgetEnabled)
                        {
                            int orderNo=[[policyValueDict objectForKey:@"number"] intValue];
                            int enabled=0;
                            NSNumber *orderNumber=[NSNumber numberWithInt:orderNo];
                            NSString *widgetUri=policyKeyUri;
                            NSNumber *supportedInMobile=[NSNumber numberWithBool:NO];
                            NSNumber *enabledNumber=[NSNumber numberWithInt:enabled];
                            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
                                                orderNumber,@"orderNo",
                                                widgetUri,@"widgetUri",
                                                supportedInMobile,@"supportedInMobile",enabledNumber,@"enabled",nil];
                            [enabledWidgetsUriArrays addObject:dict];
                        }
                    }



                }
            }
            
        }
        
    }
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri];
    NSString *tableName=nil;
    if (isPending)
    {
        tableName=pendingEnabledWidgetsTable;
    }
    else
    {
        tableName=previousEnabledWidgetsTable;
    }
    [myDB deleteFromTable:tableName where:whereStr inDatabase:@""];

    for (int i=0; i<[enabledWidgetsUriArrays count]; i++)
    {
        
        NSDictionary *dict=[enabledWidgetsUriArrays objectAtIndex:i];
        NSNumber *orderNo=[NSNumber numberWithInt:[[dict objectForKey:@"orderNo"] intValue]];
        NSString *widgetUri=[NSString stringWithFormat:@"%@",[dict objectForKey:@"widgetUri"]];
        NSNumber *supportedInMobile=[NSNumber numberWithBool:[[dict objectForKey:@"supportedInMobile"] boolValue]];
        NSNumber *enabled=[NSNumber numberWithInt:[[dict objectForKey:@"enabled"] intValue]];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        [dataDict setObject:widgetUri forKey:@"widgetUri"];
        [dataDict setObject:orderNo forKey:@"orderNo"];
        [dataDict setObject:supportedInMobile forKey:@"supportedInMobile"];
        [dataDict setObject:enabled forKey:@"enabled"];
        if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        }
        if (dict[@"widgetTitle"]!=nil && ![dict[@"widgetTitle"] isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:dict[@"widgetTitle"] forKey:@"widgetTitle"];
        }
        [myDB insertIntoTable:tableName data:dataDict intoDatabase:@""];
    }
    
}

-(void)saveWidgetTimesheetPayrollSummaryDataToDB:(NSDictionary *)response isPending:(BOOL)isPending displayPayamount:(BOOL)displayPayamount andTimesheetURI:(NSString *)timesheetUri
{
    NSString *tableName =widgetPreviousPayrollSummaryTable;

    if (isPending) {
        tableName = widgetPendingPayrollSummaryTable;
    }

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:tableName where:whereStr inDatabase:@""];
    NSDictionary *widgetTimesheetSummary = response[@"widgetTimesheetSummary"];
    if (widgetTimesheetSummary && widgetTimesheetSummary!= (id)[NSNull null])
    {
        NSDictionary *totalTimeDuration = widgetTimesheetSummary[@"totalTimeDuration"];
        NSNumber *totalPaycodeHours = [NSNumber numberWithFloat:0];
        if (totalTimeDuration && totalTimeDuration!=[NSNull class]) {
            totalPaycodeHours = [Util convertApiTimeDictToDecimal:totalTimeDuration];
        }

        NSDictionary *totalPayablePay = widgetTimesheetSummary[@"totalPayablePay"];
        
        NSString *totalPaycodeAmount = [self paycodeAmountForPaycode:totalPayablePay];

        NSArray *actualsByPaycode = widgetTimesheetSummary[@"actualsByPaycode"];

        NSDate *date = [NSDate date];
        NSDate *utcDate=[Util getUTCFormatDate:date];

        if (actualsByPaycode==(id)[NSNull null] ||actualsByPaycode.count ==0)
        {
            NSMutableDictionary *paycodeDBInsertData = [[NSMutableDictionary alloc]init];
            [paycodeDBInsertData setObject:[Util getRoundedValueFromDecimalPlaces:[totalPaycodeHours newDoubleValue] withDecimalPlaces:2] forKey:@"totalpayhours"];
            if (totalPaycodeAmount!=nil && ![totalPaycodeAmount isKindOfClass:[NSNull class]])
            {
                [paycodeDBInsertData setObject:totalPaycodeAmount forKey:@"totalpayamount"];
            }

            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
            {
                [paycodeDBInsertData setObject:timesheetUri forKey:@"timesheetUri"];
            }

            [paycodeDBInsertData setObject:@"" forKey:@"paycodeamount"];
            [paycodeDBInsertData setObject:@"" forKey:@"paycodename"];
            [paycodeDBInsertData setObject:@"" forKey:@"paycodehours"];
            [paycodeDBInsertData setObject:utcDate forKey:@"savedOnDate"];
            [myDB insertIntoTable:tableName data:paycodeDBInsertData intoDatabase:@""];
        }

        if (actualsByPaycode != nil && ![actualsByPaycode isKindOfClass:[NSNull class]])
        {
            float totalpayhours = 0.0;

            for (NSDictionary *paycodeDictionary in actualsByPaycode) {
                NSMutableDictionary *paycodeDBInsertData = [[NSMutableDictionary alloc]init];
                NSDictionary *paycodeDuration = paycodeDictionary[@"totalTimeDuration"];
                NSDictionary *payCode = paycodeDictionary[@"payCode"];
                

                if (totalPaycodeAmount!=nil && ![totalPaycodeAmount isKindOfClass:[NSNull class]])
                {
                    [paycodeDBInsertData setObject:totalPaycodeAmount forKey:@"totalpayamount"];
                }

                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [paycodeDBInsertData setObject:timesheetUri forKey:@"timesheetUri"];
                }
                NSDictionary *moneyValue = paycodeDictionary[@"moneyValue"];
                if (moneyValue && moneyValue!= (id)[NSNull null]) {
                    NSString *paycodeAmount = [self paycodeAmountForPaycode:moneyValue];
                    [paycodeDBInsertData setObject:paycodeAmount forKey:@"paycodeamount"];
                }
                
                
                if (payCode && payCode!= (id)[NSNull null]) {
                    NSString *paycodeName = payCode[@"displayText"];
                    [paycodeDBInsertData setObject:paycodeName forKey:@"paycodename"];
                }
                
                if (paycodeDuration && paycodeDuration!= (id)[NSNull null]) {
                    NSNumber *paycodeHours = [Util convertApiTimeDictToDecimal:paycodeDuration];
                    [paycodeDBInsertData setObject:[Util getRoundedValueFromDecimalPlaces:[paycodeHours newDoubleValue] withDecimalPlaces:2] forKey:@"paycodehours"];

                    totalpayhours = totalpayhours + [paycodeHours floatValue];

                    
                }
                else{
                    NSNumber *paycodeHours = [NSNumber numberWithFloat:0];
                    [paycodeDBInsertData setObject:[Util getRoundedValueFromDecimalPlaces:[paycodeHours newDoubleValue] withDecimalPlaces:2] forKey:@"paycodehours"];
                }
                
                
                [paycodeDBInsertData setObject:[NSNumber numberWithBool:displayPayamount] forKey:@"displayPayAmount"];
                
                [paycodeDBInsertData setObject:utcDate forKey:@"savedOnDate"];
                [myDB insertIntoTable:tableName data:paycodeDBInsertData intoDatabase:@""];
            }

            [myDB updateTable:tableName data:@{@"totalpayhours":[Util getRoundedValueFromDecimalPlaces:[@(totalpayhours) newDoubleValue] withDecimalPlaces:2]} where:[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri] intoDatabase:@""];
        }
        
        
    }
    
}

-(NSArray *)getAllPaycodesIsPending:(BOOL)isPending forTimesheetUri:(NSString *)timesheetUri
{
    NSString *tableName =widgetPreviousPayrollSummaryTable;
    if (isPending) {
        tableName = widgetPendingPayrollSummaryTable;
    }
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",tableName,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    return array;

}


-(NSString *)paycodeAmountForPaycode:(NSDictionary *)paycodeDictionary
{
    NSString *paycodeAmount;
    NSArray *currencyValues = paycodeDictionary[@"multiCurrencyValue"];
    if (currencyValues && currencyValues.count > 0) {
        double amount = [currencyValues.firstObject[@"amount"] newDoubleValue];
        NSDictionary *currencyDict = currencyValues.firstObject[@"currency"];
        if (currencyDict && currencyDict!=(id)[NSNull null]) {
            NSString *currency = currencyValues.firstObject[@"currency"][@"displayText"];
            paycodeAmount = [NSString stringWithFormat:@"%@ %@",currency,[Util getRoundedValueFromDecimalPlaces:amount withDecimalPlaces:2]];
        }
        else{
            paycodeAmount = [Util getRoundedValueFromDecimalPlaces:[@"0.00" newDoubleValue] withDecimalPlaces:2];
        }

    }
    return paycodeAmount;
}


-(void)saveWidgetTimesheetSummaryOfHoursIntoDB:(NSMutableDictionary *)summaryDict andTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    
    
    NSDictionary *totalTimeOffHours=[summaryDict objectForKey:@"totalTimeOffHours"];
    NSString *totalInOutTimeOffHours=[Util convertApiTimeDictToStringWithFormatHHMMSS:totalTimeOffHours];
    
    if (totalInOutTimeOffHours==nil||[totalInOutTimeOffHours isKindOfClass:[NSNull class]]||[totalInOutTimeOffHours isEqualToString:@""]) {
        totalInOutTimeOffHours=@"0.00";
    }
    NSString *totalStandardTimeOffHours=totalInOutTimeOffHours;
    
    NSDictionary *totalInOutBreakHours=[summaryDict objectForKey:@"totalInOutBreakHours"];
    NSString *totalInOutBreakHoursStr=[Util convertApiTimeDictToStringWithFormatHHMMSS:totalInOutBreakHours];
    if (totalInOutBreakHoursStr==nil||[totalInOutBreakHoursStr isKindOfClass:[NSNull class]]||[totalInOutBreakHoursStr isEqualToString:@""]) {
        totalInOutBreakHoursStr=@"0.00";
    }
    
    NSDictionary *totalInOutWorkHours=[summaryDict objectForKey:@"totalInOutWorkHours"];
    NSString *totalInOutWorkHoursStr=[Util convertApiTimeDictToStringWithFormatHHMMSS:totalInOutWorkHours];
    if (totalInOutWorkHoursStr==nil||[totalInOutWorkHoursStr isKindOfClass:[NSNull class]]||[totalInOutWorkHoursStr isEqualToString:@""]) {
        totalInOutWorkHoursStr=@"0.00";
    }
    
    NSDictionary *totalTimePunchBreakHours=[summaryDict objectForKey:@"totalTimePunchBreakHours"];
    NSString *totalTimePunchBreakHoursStr=[Util convertApiTimeDictToStringWithFormatHHMMSS:totalTimePunchBreakHours];
    if (totalTimePunchBreakHoursStr==nil||[totalTimePunchBreakHoursStr isKindOfClass:[NSNull class]]||[totalTimePunchBreakHoursStr isEqualToString:@""]) {
        totalTimePunchBreakHoursStr=@"0.00";
    }
    
    NSDictionary *totalTimePunchWorkHours=[summaryDict objectForKey:@"totalTimePunchWorkHours"];
    NSString *totalTimePunchWorkHoursStr=[Util convertApiTimeDictToStringWithFormatHHMMSS:totalTimePunchWorkHours];
    if (totalTimePunchWorkHoursStr==nil||[totalTimePunchWorkHoursStr isKindOfClass:[NSNull class]]||[totalTimePunchWorkHoursStr isEqualToString:@""]) {
        totalTimePunchWorkHoursStr=@"0.00";
    }
    
    NSDictionary *totalStandardWorkHours=[summaryDict objectForKey:@"totalStandardWorkHours"];
    NSString *totalStandardWorkHoursStr=[Util convertApiTimeDictToStringWithFormatHHMMSS:totalStandardWorkHours];
    if (totalStandardWorkHoursStr==nil||[totalStandardWorkHoursStr isKindOfClass:[NSNull class]]||[totalStandardWorkHoursStr isEqualToString:@""]) {
        totalStandardWorkHoursStr=@"0.00";
    }
    
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    if (isPending)
    {
        tableName=WidgetPendingTimesheetSummaryTable;
    }
    else
    {
        tableName=WidgetPreviousTimesheetSummaryTable;
    }
    [myDB deleteFromTable:tableName where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if(totalInOutBreakHours != nil && totalInOutBreakHours != (id)[NSNull null]) {
        [dataDict setObject:totalInOutBreakHoursStr forKey:@"totalInOutBreakHours"];
    }
    [dataDict setObject:totalInOutWorkHoursStr forKey:@"totalInOutWorkHours"];
    [dataDict setObject:totalTimePunchBreakHoursStr forKey:@"totalTimePunchBreakHours"];
    [dataDict setObject:totalTimePunchWorkHoursStr forKey:@"totalTimePunchWorkHours"];
    if(totalTimeOffHours != nil && totalTimeOffHours != (id)[NSNull null]) {
        [dataDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    }
    [dataDict setObject:totalInOutTimeOffHours forKey:@"totalTimePunchTimeOffHours"];
    [dataDict setObject:totalStandardWorkHoursStr forKey:@"totalStandardWorkHours"];
    [dataDict setObject:totalStandardTimeOffHours forKey:@"totalStandardTimeOffHours"];
    if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    }
    [myDB insertIntoTable:tableName data:dataDict intoDatabase:@""];
    
}

-(void)deleteAllTimeentriesForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if (isPending)
    {
        [myDB deleteFromTable:approvalPendingTimeEntriesTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimeEntriesTable where:whereStr inDatabase:@""];
    }

    [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:whereStr inDatabase:@""];
}


-(void)deleteAllTimeentriesForTimesheetUri:(NSString *)timesheetUri andWidgetEntries:widgetTimeEntriesArr isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

    if(widgetTimeEntriesArr != nil && ![widgetTimeEntriesArr isKindOfClass:[NSNull class]])
    {
        for (int j=0; j<[widgetTimeEntriesArr count]; j++) {
            NSMutableDictionary *newDict=[widgetTimeEntriesArr objectAtIndex:j];
            NSString *entryUri=newDict[@"uri"];
            NSString * whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' and timePunchesUri='%@'",timesheetUri,entryUri];
            if (isPending)
            {
                [myDB deleteFromTable:approvalPendingTimeEntriesTable where:whereStr inDatabase:@""];
            }
            else
            {
                [myDB deleteFromTable:approvalPreviousTimeEntriesTable where:whereStr inDatabase:@""];
            }
            whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' and timeEntryUri='%@'",timesheetUri,entryUri];
            [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:whereStr inDatabase:@""];
        }
    }
    
}

-(void)deleteAllTimesheetDaySummaryForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if (isPending)
    {
        [myDB deleteFromTable:approvalPendingTimesheetsDaySummaryTable where:whereStr inDatabase:@""];
    }
    else
    {
        [myDB deleteFromTable:approvalPreviousTimesheetsDaySummaryTable where:whereStr inDatabase:@""];
    }
}

-(NSArray*)getPendingTimesheetInfoForTimeIn:(NSString*)time_in andTimeOut:(NSString*)time_out timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *query=[NSString stringWithFormat:@" select * from %@ where time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",approvalPendingTimeEntriesTable,time_in,time_out,timesheetUri,entryDate];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:TRUE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@' AND timesheetFormat='%@'",approvalPendingTimeEntriesTable,time_in,time_out,timesheetUri,entryDate,tsFormat];
    }

    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
    if ([array count]!=0) {
        return array;
    }
    return nil;
}

-(NSArray*)getPreviousTimesheetInfoForTimeIn:(NSString*)time_in andTimeOut:(NSString*)time_out timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *query=[NSString stringWithFormat:@" select * from %@ where time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",approvalPreviousTimeEntriesTable,time_in,time_out,timesheetUri,entryDate];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:FALSE];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@' AND timesheetFormat='%@'",approvalPreviousTimeEntriesTable,time_in,time_out,timesheetUri,entryDate,tsFormat];
    }

    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
    if ([array count]!=0) {
        return array;
    }
    return nil;
}

-(void)updateSummaryDataForTimesheetUri:(NSString *)timesheetUri withDataDict:(NSMutableDictionary *)timesheetDataTSDict andIsPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStringTsTable=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    if (isPending)
    {
        [myDB updateTable: WidgetPendingTimesheetSummaryTable data:timesheetDataTSDict where:whereStringTsTable intoDatabase:@""];
    }
    else
    {
        [myDB updateTable: WidgetPreviousTimesheetSummaryTable data:timesheetDataTSDict where:whereStringTsTable intoDatabase:@""];
    }
    
}

-(void)saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andFormat:(NSString *)timeSheetFormat andIsPending:(BOOL)isPending
{
    for (int k=0; k<[timeOffsArr count ]; k++)
    {
        NSDictionary *dict=[timeOffsArr objectAtIndex:k];



        NSString *timeOffUri=nil;
        NSString *timeOffName=nil;
        NSString *rowUri=nil;
        NSString *comments=@"";




        if ([dict objectForKey:@"timeOffType"]!=nil)
        {
            timeOffUri=[[dict objectForKey:@"timeOffType"] objectForKey:@"uri"];
            timeOffName=[[dict objectForKey:@"timeOffType"] objectForKey:@"name"];

        }
        if ([dict objectForKey:@"uri"]!=nil)
        {
            rowUri=[dict objectForKey:@"uri"];
        }

        if ([dict objectForKey:@"comments"] != nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]]
            &&[[dict objectForKey:@"comments"] isKindOfClass:[NSString class]]) {
            comments=[dict objectForKey:@"comments"];
        }

        if ([dict objectForKey:@"entries"] != nil && ![[dict objectForKey:@"entries"] isKindOfClass:[NSNull class]])
        {
            NSArray *timeOffEntries=[dict objectForKey:@"entries"];
            for (NSDictionary *timeOffEntryDict in timeOffEntries)
            {
                NSDate *entryDate=[Util convertApiDateDictToDateFormat:[timeOffEntryDict objectForKey:@"entryDate"]];
                NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];

                NSDictionary *totalTimeDurationDict=[timeOffEntryDict objectForKey:@"duration"];
                NSNumber *totalTimeInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeDurationDict];
                NSString *totalTimeHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeDurationDict];

                NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
                [dataDict setObject:totalTimeInDecimalFormat forKey:@"durationDecimalFormat"];
                [dataDict setObject:totalTimeHoursInHourFormat forKey:@"durationHourFormat"];


                [dataDict setObject:comments forKey:@"comments"];
                [dataDict setObject:timeOffName forKey:@"timeOffTypeName"];
                [dataDict setObject:timeOffUri forKey:@"timeOffUri"];
                [dataDict setObject:Time_Off_Key forKey:@"entryType"];
                [dataDict setObject:[NSNumber numberWithInt:Time_Off_Key_Value] forKey:@"entryTypeOrder"];
                [dataDict setObject:rowUri forKey:@"rowUri"];
                if(timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                }
                [dataDict setObject:timeSheetFormat forKey:@"timesheetFormat"];

                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];

                NSArray *timeOffArr=nil;

                if (isPending)
                {
                    timeOffArr=[self getPendingTimesheetTimeOffInfoForRowUri:rowUri timesheetUri:timesheetUri andEntryDate:entryDateToStore];;
                }
                else
                {
                    timeOffArr=[self getPreviousTimesheetTimeOffInfoForRowUri:rowUri timesheetUri:timesheetUri andEntryDate:entryDateToStore];;
                }

                 SQLiteDB *myDB = [SQLiteDB getInstance];
                if ([timeOffArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",rowUri,entryDateToStore];
                     
                    if (isPending)
                    {
                        [myDB updateTable: approvalPendingTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                    }
                    else
                    {
                        [myDB updateTable: approvalPreviousTimeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                    }


                }
                else
                {
                    if (isPending)
                    {
                        [myDB insertIntoTable:approvalPendingTimeEntriesTable data:dataDict intoDatabase:@""];

                    }
                    else
                    {
                        [myDB insertIntoTable:approvalPreviousTimeEntriesTable data:dataDict intoDatabase:@""];
                    }

                }

            }
        }
        
    }
}

-(void)updatecanEditTimesheetStatusForTimesheetWithUri:(NSString *)timesheetUri withStatus:(int)allowTimeEntryEditForGen4 andIsPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=nil;
    if (isPending)
    {
        tableName=approvalPendingTimesheetsTable;
    }
    else
    {
        tableName=approvalPreviousTimesheetsTable;
    }
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET canEditTimesheet = '%@' WHERE timesheetUri='%@'",tableName,[NSNumber numberWithInt:allowTimeEntryEditForGen4],timesheetUri];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        //NSLog(@"vvv");
    }
}
-(void)updateTimesheetFormatForTimesheetWithUri:(NSString *)timesheetUri andIsPending:(BOOL)isPending
{
    NSMutableArray *enableWidgetsArr=nil;
    NSString *tableName=nil;
    if (isPending)
    {
        enableWidgetsArr=[self getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
        tableName=approvalPendingTimesheetsTable;
    }
    else
    {
        enableWidgetsArr=[self getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
         tableName=approvalPreviousTimesheetsTable;
    }
    
    
    
    NSString *format=GEN4_INOUT_TIMESHEET;
    
    if ([enableWidgetsArr count]>0)
    {
        if ([[[enableWidgetsArr objectAtIndex:0] objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            format=GEN4_STANDARD_TIMESHEET;
        }
        else if ([[[enableWidgetsArr objectAtIndex:0] objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            format=GEN4_INOUT_TIMESHEET;
            
        }
        else if ([[[enableWidgetsArr objectAtIndex:0] objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            format=GEN4_EXT_INOUT_TIMESHEET;

        }
        else if ([[[enableWidgetsArr objectAtIndex:0] objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            format=GEN4_PUNCH_WIDGET_TIMESHEET;
            
        }
    }
    
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET timesheetFormat = '%@' WHERE timesheetUri='%@'",tableName,format,timesheetUri];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        //NSLog(@"vvv");
    }
}


-(NSString *)getTimesheetFormatforTimesheetUri:(NSString *)timesheetUri andIsPending:(BOOL)isPending
{
    NSString *tsFormat=nil;
    NSArray *timesheetInfoArray=nil;
    if (isPending)
    {
        timesheetInfoArray=[self getTimeSheetInfoSheetIdentityForPending:timesheetUri];
    }
    else
    {
       timesheetInfoArray=[self getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
    }
    
    if ([timesheetInfoArray count]>0)
    {
        tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        
    }
    
    return tsFormat;
}

-(void)resetAndSaveTeamTimesheets:(NSDictionary *)timesheetDict andTimesheetForUserWithWorkHours:(TimesheetForUserWithWorkHours *)timesheet
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:approvalPreviousTimesheetsTable where:@"isFromViewTeamTime = 1" inDatabase:@""];

    NSDictionary *responseDict=timesheetDict[@"d"];
    NSDictionary *standardTimesheetDetailsDict=responseDict[@"standardTimesheetDetails"];
    NSDictionary *inOutTimesheetDetailsDict=responseDict[@"inOutTimesheetDetails"];
    NSDictionary *widgetTimesheetDetailsDict=responseDict[@"widgetTimesheetDetails"];

    NSDictionary *approvalDetailsDict=responseDict[@"approvalDetails"];
    NSString *timesheetUri=timesheet.uri;
    NSString *approvalStatusUri=approvalDetailsDict[@"approvalStatus"][@"uri"];
    NSString *approvalStatus=@"";
    if ([approvalStatusUri isEqualToString:APPROVED_STATUS_URI])
    {
        approvalStatus=APPROVED_STATUS;
    }
    else if ([approvalStatusUri isEqualToString:NOT_SUBMITTED_STATUS_URI])
    {
        approvalStatus=NOT_SUBMITTED_STATUS ;
    }
    else if ([approvalStatusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
    {
        approvalStatus=WAITING_FOR_APRROVAL_STATUS;
    }
    else if ([approvalStatusUri isEqualToString:REJECTED_STATUS_URI])
    {
        approvalStatus=REJECTED_STATUS;
    }


    NSDictionary *timesheetDetailsDict=nil;

    if (standardTimesheetDetailsDict!=nil && ![standardTimesheetDetailsDict isKindOfClass:[NSNull class]])
    {
        timesheetDetailsDict=standardTimesheetDetailsDict;
    }
    else if (inOutTimesheetDetailsDict!=nil && ![inOutTimesheetDetailsDict isKindOfClass:[NSNull class]])
    {
        timesheetDetailsDict=inOutTimesheetDetailsDict;
    }
    else if (widgetTimesheetDetailsDict!=nil && ![widgetTimesheetDetailsDict isKindOfClass:[NSNull class]])
    {
        timesheetDetailsDict=widgetTimesheetDetailsDict;
    }

    NSDictionary *dueDateDict=timesheetDetailsDict[@"dueDate"];
    NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];


    NSString *userName=timesheet.userName;
    NSString *userUri=timesheet.userURI;

    TimesheetPeriod *timesheetPeriod=timesheet.period;
    NSDate *endDate=timesheetPeriod.endDate;
    NSDate *startDate=timesheetPeriod.startDate;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"MMMM dd, yyyy"];
    NSString *timesheetStartDateStr=[df stringFromDate:startDate];
    NSString *timesheetEndDateStr=[df stringFromDate:endDate];
    NSString *timesheetPeriodStr=[NSString stringWithFormat:@"%@ - %@",timesheetStartDateStr,timesheetEndDateStr];


    NSDictionary *dataDict=@{@"approvalStatus":approvalStatus,@"username":userName,@"userUri":userUri,@"timesheetUri":timesheetUri,@"dueDate":[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]],@"startDate":[NSNumber numberWithDouble:[startDate timeIntervalSince1970]],@"endDate":[NSNumber numberWithDouble:[endDate timeIntervalSince1970]],@"timesheetPeriod":timesheetPeriodStr,@"isFromViewTeamTime":@YES};


    [myDB insertIntoTable:approvalPreviousTimesheetsTable data:dataDict intoDatabase:@""];

}

-(void)updateApprovalTimeentriesFormatForTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSString *)withFormat fromFormat:(NSString *)fromFormat andIsPending:(BOOL)isPending
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tableName=@"";
    if (isPending) {
        tableName=approvalPendingTimeEntriesTable;
    }
    else
    {
        tableName=approvalPreviousTimeEntriesTable;
    }

    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET timesheetFormat = '%@' WHERE timesheetUri='%@' AND timesheetFormat = '%@'",tableName,withFormat,timesheetUri,fromFormat];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        //NSLog(@"vvv");
    }
}

-(BOOL)getTimeSheetEditStatusForSheetFromDB: (NSString *)timesheetUri forTableName:(NSString *)table
{

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select canEditTimesheet from %@ where timesheetUri='%@' order by startDate desc",table,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        if ([[array objectAtIndex:0]objectForKey:@"canEditTimesheet"]!=nil && ![[[array objectAtIndex:0]objectForKey:@"canEditTimesheet"] isKindOfClass:[NSNull class]])
        {
            return [[[array objectAtIndex:0]objectForKey:@"canEditTimesheet"]boolValue];
        }
        else
            return TRUE;

    }
    return TRUE;
    
    
}

-(float)getTimeEntryTotalForEntryWithWhereString:(NSString *)whereString isPending:(BOOL)isPending
{

    NSString *tableName = approvalPendingTimeEntriesTable;

    if (!isPending)
    {
        tableName = approvalPreviousTimeEntriesTable;
    }

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedtsArray = [myDB select:@" * " from:tableName where:whereString intoDatabase:@""];

    float totalHours = 0.0;

    for (NSDictionary *groupedtsDict in groupedtsArray)
    {
        totalHours = totalHours + [groupedtsDict[@"durationDecimalFormat"] newFloatValue];
    }


    return totalHours;
}

-(BOOL) isMultiDayTimeOff:(NSString *)timeoffUri :(NSString *)tableName{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select isMultiDayTimeOff from %@ where timeoffUri='%@'",tableName,timeoffUri];
    NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([permissionArr count]>0)
    {
        id hasPermission =  [[permissionArr objectAtIndex:0] objectForKey:@"isMultiDayTimeOff"];
        if(hasPermission!= nil && hasPermission != (id)[NSNull null])
        {
            return [hasPermission boolValue];
        }
    }
    return NO;
}


#pragma private

-(BOOL)shouldDisplaySummaryByPayCode:(NSMutableDictionary *)responseDict {
    BOOL displaySummaryByPayCode = true;
    if(responseDict[@"displaySummaryByPayCode"] != nil && responseDict[@"displaySummaryByPayCode"] != (id)[NSNull null]) {
        displaySummaryByPayCode = [responseDict[@"displaySummaryByPayCode"] boolValue];
    }
    return displaySummaryByPayCode;
}

@end
