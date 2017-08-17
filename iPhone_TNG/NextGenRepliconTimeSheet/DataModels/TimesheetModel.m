//
//  TimesheetModel.m
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimesheetModel.h"
#import "LoginModel.h"
#import "AppDelegate.h"
#import "NSNumber+Double_Float.h"
#import "NSString+Double_Float.h"
#import "TimesheetApprovalHistoryObject.h"
#import "SupportDataModel.h"
#import "TimesheetEntryObject.h"
#import "DateUtil.h"

static NSString *timesheetsTable=@"Timesheets";
static NSString *timesheetsProjectsSummaryTable=@"TimesheetProjectSummary";
static NSString *timesheetsActivitiesSummaryTable=@"TimesheetActivitySummary";
static NSString *timesheetsBillingSummaryTable=@"TimesheetBillingSummary";
static NSString *timesheetsPayrollSummaryTable=@"TimesheetPayrollSummary";
static NSString *timesheetsDaySummaryTable=@"TimesheetDaySummary";
static NSString *timeoffTypesTable=@"TimeoffTypes";
static NSString *disclaimerTable=@"Disclaimer";
static NSString *clientsTable=@"Clients";
static NSString *projectsTable=@"Projects";
static NSString *programsTable=@"Programs";
static NSString *tasksTable=@"Tasks";
static NSString *billingTable=@"Billing";
static NSString *activityTable=@"Activity";
static NSString *timeEntriesTable = @"Time_entries";
static NSString *timesheetApproverHistoryTable=@"TimesheetApproverHistory";
static NSString *timesheetCustomFieldsTable=@"TimesheetCustomFields";
static NSString *breakTable=@"Break";
static NSString *bookedTimeoffTypesTable=@"BookedTimeoffTypes";
static NSString *userDeFinedFieldsTable=@"userDefinedFields";
static NSString *udfPreferencesTable=@"UDFPreferences";
static NSString *enabledWidgetsTable=@"EnabledWidgets";
static NSString *widgetDisclaimerTable=@"WidgetNotice";
static NSString *widgetTimesheetSummaryTable=@"WidgetTimesheetSummary";
static NSString *timesheetCapabilitiesTable=@"TimesheetCapabilities";
static NSString *widgetAttestationTable=@"WidgetAttestation";
static NSString *widgetPayrollSummaryTable=@"WidgetPayrollSummary";
static NSString *timesheetObjectExtensionFieldsTable=@"TimesheetObjectExtensionFields";
static NSString *timeEntriesObjectExtensionFieldsTable=@"TimeEntriesObjectExtensionFields";
static NSString *timeSheetPermittedApprovalActions = @"TimeSheetPermittedApprovalActions";
                                                       

#define Non_Billable_string @"Non-Billable"

@implementation TimesheetModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}
#pragma mark -
#pragma mark Nextgen Methods

-(void)saveTimesheetPeriodDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
    //Implementation of TimeSheetLastModified
    if (rowsArray!=nil && ![rowsArray isKindOfClass:[NSNull class]])
    {
        for (int i=0; i<[rowsArray count]; i++)
        {
            NSString *timesheetURI=@""; 
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
                    NSDictionary *endDateDict=[[responseDict objectForKey:@"dateRangeValue"] objectForKey:@"endDate"];
                    NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
                    NSDictionary *startDateDict=[[responseDict objectForKey:@"dateRangeValue"] objectForKey:@"startDate"];
                    NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
                    NSString *timesheetPeriodStr=[responseDict objectForKey:@"textValue"];
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
                else if ([refrenceHeader isEqualToString:@"Due Date"])
                {
                    NSDictionary *dueDateDict=[responseDict objectForKey:@"dateValue"];
                    NSDate *dueDate=[Util convertApiDateDictToDateFormat:dueDateDict];
                    NSString *dueDateStr=[responseDict objectForKey:@"textValue"];
                    [dataDict setObject:[NSNumber numberWithDouble:[dueDate timeIntervalSince1970]] forKey:@"dueDate"];
                    [dataDict setObject:dueDateStr       forKey:@"dueDateText"];
                    
                }
                else if ([refrenceHeader isEqualToString:@"Meal Penalties"])
                {
                    int penalties=[[responseDict objectForKey:@"textValue"] intValue];
                    [dataDict setObject:[NSNumber numberWithInt:penalties] forKey:@"mealBreakPenalties"];
                }
                
                else if ([refrenceHeader isEqualToString:@"Approval Status"])
                {
                    NSString *statusStr=[responseDict objectForKey:@"uri"];
                    if (statusStr!=nil && ![statusStr isKindOfClass:[NSNull class]])
                    {
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

                }
                else if ([refrenceHeader isEqualToString:@"Timesheet"])
                {
                    timesheetURI=[responseDict objectForKey:@"uri"];
                    [dataDict setObject:timesheetURI      forKey:@"timesheetUri"];
                    
                }
                else if ([refrenceHeader isEqualToString:@"Timesheet"])
                {
                    timesheetURI=[responseDict objectForKey:@"uri"];
                    [dataDict setObject:timesheetURI      forKey:@"timesheetUri"];
                    
                }
                else if ([refrenceHeader isEqualToString:@"Total Hours Excluding Break"])
                {
                    //MI-1916
                   /* NSDictionary *totalHoursDict=[responseDict objectForKey:@"calendarDayDurationValue"];
                    NSNumber *totalHours=[Util convertApiTimeDictToDecimal:totalHoursDict];
                    NSString *totalHoursStr=[Util convertApiTimeDictToString:totalHoursDict];
                    [dataDict setObject:totalHours      forKey:@"totalDurationDecimal"];
                    [dataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
                    */
                }
                
                
                
                
            }

            if ([self getPendingOperationsArr:timesheetURI].count==0)
            {
                NSArray *expArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
                NSString *tsFormat=[expArr[0] objectForKey:@"timesheetFormat"];
                if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:tsFormat forKey:@"timesheetFormat"];
                }
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetURI];
                    [myDB updateTable:timesheetsTable data:dataDict where:whereString intoDatabase:@""];//Implementation of TimeSheetLastModified
                }
                else
                {
                     [myDB insertIntoTable:timesheetsTable data:dataDict intoDatabase:@""];
                }

            }
            
        }
    }
    
    
    
}

- (void)saveTimesheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDictionaryObject isFromSave:(BOOL)isFromSave
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
        [self saveEnabledWidgetsDetailsIntoDB:responseDictionaryObject andTimesheetUri:timesheetUri];
        [self saveWidgetTimesheetSummaryOfHoursIntoDB:widgetTimesheetSummaryDict andTimesheetUri:timesheetUri isFromSave:isFromSave];
        if ([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            if ([[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"]!=nil && ![[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"] isKindOfClass:[NSNull class]])
            {
                 [self saveTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"history"]];
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
        int canOwnerViewPayDetails=[[capablitiesDict objectForKey:@"canOwnerViewPayDetails"] intValue];
        int canOwnerViewPayrollSummary=[[capablitiesDict objectForKey:@"canOwnerViewPayrollSummary"] intValue];
        int allowSplitMidNightCrossTime = 0;
        int allowNegativeTimeEntryForWidgetTimesheet=0;
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
                        if ([tmpPolicyKey isEqualToString:extendedInOutWidgetMidNightCrossUri])
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
                        else if ([tmpPolicyKey isEqualToString:GEN4_STANDARD_TIME_ENTRY_NEGATIVE_TIME_ENTRY_POLICY_URI])
                        {
                            if ([tmpPolicyValue isEqualToString:GEN4_STANDARD_TIME_ENTRY_NEGATIVE_TIME_ENTRY_ALLOWED])
                            {
                                tmpPolicyKey=nil;
                                allowNegativeTimeEntryForWidgetTimesheet = 1;
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
                                            NSDictionary *dayLevelObjectExtensionFieldDict = nil;
                                            if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
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
            allowTimeEntryEditForExtInOutGen4=0;
        }
        
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSMutableDictionary *timesheetPermittedApprovalActions=[NSMutableDictionary dictionary];
        if ([responseDictionaryObject objectForKey:@"permittedApprovalActions"]!=nil && ![[responseDictionaryObject objectForKey:@"permittedApprovalActions"] isKindOfClass:[NSNull class]])
        {
           timesheetPermittedApprovalActions=[NSMutableDictionary dictionaryWithDictionary:[responseDictionaryObject objectForKey:@"permittedApprovalActions"]];
        }

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
         [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowProgramsForStandardGen4]  forKey:@"allowProgramsForStandardGen4"];
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
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:canOwnerViewPayDetails] forKey:@"canOwnerViewPayDetails"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:canOwnerViewPayrollSummary] forKey:@"canOwnerViewPayrollSummary"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowSplitMidNightCrossTime] forKey:@"allowSplitTimeMidnightCrossEntry"];
        [timesheetPermittedApprovalActions setObject:[NSNumber numberWithInt:allowNegativeTimeEntryForWidgetTimesheet] forKey:@"allowNegativeTimeEntry"];
        
        if (![timesheetUri isKindOfClass:[NSNull class]] && timesheetUri!=nil )
        {
            [timesheetPermittedApprovalActions setObject:timesheetUri forKey:@"uri"];
        }
        
        
        [supportModel saveTimesheetPermittedApprovalActionsDataToDB:timesheetPermittedApprovalActions];
        [self updatecanEditTimesheetStatusForTimesheetWithUri:timesheetUri withStatus:allowTimeEntryEditForInOutGen4];
        [self updateTimesheetFormatForTimesheetWithUri:timesheetUri];
        
        NSString *timesheetApprovalStatusUri=nil;
        if ([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            if ([[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"]!=nil && ![[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] isKindOfClass:[NSNull class]])
            {
                if ([[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"]!=nil && ![[[[responseDictionaryObject objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"] isKindOfClass:[NSNull class]])
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
                
                [myDB updateTable:@"Timesheets" data:dataDict where:[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri] intoDatabase:@""];
            }
            
            
        }
        
    }
    else
    {
        NSMutableDictionary *timesheetDetailsDict=[responseDictionaryObject objectForKey:@"inOutTimesheetDetails"];
        NSMutableDictionary *standardTimesheetDetailsDict=[responseDictionaryObject objectForKey:@"standardTimesheetDetails"];
        NSString *timesheetUri=nil;
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
        if (![timesheetDetailsDict isKindOfClass:[NSNull class]] && timesheetDetailsDict!=nil)
        {
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
        
        if (([timesheetDetailsDict isKindOfClass:[NSNull class]] || timesheetDetailsDict ==nil) && ([standardTimesheetDetailsDict isKindOfClass:[NSNull class]] || standardTimesheetDetailsDict ==nil)) {
            return;
        }
        
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        
        NSArray *timeSheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetUri];
        
        NSMutableDictionary *timesheetSummaryDict=[responseDictionaryObject objectForKey:@"timesheetSummary"];


        NSMutableDictionary *timesheetApprovalDetailsDict=[responseDictionaryObject objectForKey:@"approvalDetails"];
        //Implementation for MOBI-261//JUHI
        NSString *timesheetApprovalStatusUri=nil;
        if(timesheetApprovalDetailsDict!=nil && ![timesheetApprovalDetailsDict isKindOfClass:[NSNull class]])
        {
            if([timesheetApprovalDetailsDict objectForKey:@"approvalStatus"]!=nil && ![[timesheetApprovalDetailsDict objectForKey:@"approvalStatus"] isKindOfClass:[NSNull class]])
            {
                timesheetApprovalStatusUri=[[timesheetApprovalDetailsDict objectForKey:@"approvalStatus"]objectForKey:@"uri"];
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
            
        }
        if ([timeSheetsArr count]>0)
        {
            NSMutableDictionary *timeSheetDict=[[timeSheetsArr objectAtIndex:0]mutableCopy];
            
            
            if (timesheetApprovalStatus!=nil && ![timesheetApprovalStatus isKindOfClass:[NSNull class]])
            {
                [timeSheetDict setObject:timesheetApprovalStatus forKey:@"approvalStatus" ];
            }
            //        else
            //        {
            //             [timeSheetDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus" ];
            //        }
            
            
            
            [myDB deleteFromTable:@"Timesheets" where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
            //DE20198 Ullas M L
            NSMutableDictionary *tmpDict=[NSMutableDictionary dictionaryWithDictionary:timeSheetDict];
            for (int i=0; i<[[timeSheetDict allValues] count]; i++)
            {
                id str = [[timeSheetDict allValues] objectAtIndex:i];
                NSString *key =[[timeSheetDict allKeys] objectAtIndex:i];
                if (str==nil || [str isKindOfClass:[NSNull class]])
                {
                    [tmpDict removeObjectForKey:key];
                }
            }
            [myDB insertIntoTable:@"Timesheets" data:tmpDict intoDatabase:@""];
            
        }
        
        
        
        
        [self saveEnableOnlyCustomFieldUriIntoDBWithUriArray:enableOnlySheetUdfUriArr andArray:enableOnlyRowOrCellUdfUriArr forTimesheetUri:timesheetUri];
        [myDB deleteFromTable:timesheetCustomFieldsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
        
        //Implemented as per US7859
        int availableTimeOffTypeCount=0;
        
        if ([responseDictionaryObject objectForKey:@"availableTimeOffTypeCount"]!=nil && ![[responseDictionaryObject objectForKey:@"availableTimeOffTypeCount"] isKindOfClass:[NSNull class]]) {
            availableTimeOffTypeCount=[[responseDictionaryObject objectForKey:@"availableTimeOffTypeCount"] intValue];
        }
        //Implemented For overlappingTimeEntriesPermitted Permission
        int overlappingTimeEntriesPermitted =0;
        int canEditTimesheet=0;
        if ([responseDictionaryObject objectForKey:@"capabilities"]!=nil && ![[responseDictionaryObject objectForKey:@"capabilities"] isKindOfClass:[NSNull class]])
        {
            if ([[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"overlappingTimeEntriesPermitted"]!=nil && ![[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"overlappingTimeEntriesPermitted"] isKindOfClass:[NSNull class]])
            {
                if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"overlappingTimeEntriesPermitted"] boolValue] == YES )
                {
                    overlappingTimeEntriesPermitted = 1;
                }
            }
            
            if ([[[responseDictionaryObject objectForKey:@"capabilities"] objectForKey:@"canEditTimesheet"] boolValue] == NO )
            {
                canEditTimesheet=0;
            }
            else
            {
                canEditTimesheet=1;
            }
        }
        
        
        
        
        NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
        if (timesheetSummaryDict !=nil && ![timesheetSummaryDict isKindOfClass:[NSNull class]])
        {
            if (timesheetSummaryDict[@"actualsByActivity"]) {
                NSMutableArray *timesheetActivitiesSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByActivity"];
                if (![timesheetActivitiesSummaryArray isKindOfClass:[NSNull class]] && timesheetActivitiesSummaryArray!=nil )
                {
                    [self saveTimesheetActivitiesSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetActivitiesSummaryArray];
                }
            }
            
            if (timesheetSummaryDict[@"actualsByProject"]) {
                NSMutableArray *timesheetProjectsSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByProject"];
                if (![timesheetProjectsSummaryArray isKindOfClass:[NSNull class]] && timesheetProjectsSummaryArray!=nil )
                {
                    [self saveTimesheetProjectSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetProjectsSummaryArray];
                }
            }
            
            if (timesheetSummaryDict[@"actualsByBillingRate"]) {
                NSMutableArray *timesheetBillingSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByBillingRate"];
                NSDictionary *timesheetNonBillabeSummaryDict=[timesheetSummaryDict objectForKey:@"nonBillableTimeDuration"];
                if (![timesheetBillingSummaryArray isKindOfClass:[NSNull class]] && timesheetBillingSummaryArray!=nil )
                {
                    [self saveTimesheetBillingSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetBillingSummaryArray withNonBillableDict:timesheetNonBillabeSummaryDict];
                }
            }
            
            if (timesheetSummaryDict[@"actualsByPaycode"]) {
                NSMutableArray *timesheetPayrollSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByPaycode"];
                if (![timesheetPayrollSummaryArray isKindOfClass:[NSNull class]] && timesheetPayrollSummaryArray!=nil )
                {
                    [self saveTimesheetPayrollSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetPayrollSummaryArray];
                }
            }
            
            if (timesheetSummaryDict[@"actualsByDate"]) {
                NSMutableArray *timesheetDateSummaryArray=[timesheetSummaryDict objectForKey:@"actualsByDate"];
                if (![timesheetDateSummaryArray isKindOfClass:[NSNull class]] && timesheetDateSummaryArray!=nil )
                {
                    [self saveTimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetDateSummaryArray withNoticeAcceptedFlag:isNoticeExplicitlyAccepted withAvailableTimeOffTypeCount:availableTimeOffTypeCount isTimesheetCommentsRequired:isTimesheetCommentsRequired];
                }
            }

            
            NSDictionary *timesheetTotalHoursDict = nil;
            NSDictionary *breakHoursDict = nil;
            NSNumber *breakHours = 0;
            NSNumber *totalHours = 0;
            if (timesheetSummaryDict[@"breakDuration"]) {
                breakHoursDict=[timesheetSummaryDict objectForKey:@"breakDuration"];
                if (![breakHoursDict isKindOfClass:[NSNull class]] && breakHoursDict!=nil )
                {
                    breakHours=[Util convertApiTimeDictToDecimal:breakHoursDict];
                }
            }
            
            if (timesheetSummaryDict[@"totalTimeDuration"]) {
                timesheetTotalHoursDict=[timesheetSummaryDict objectForKey:@"totalTimeDuration"];
                if (![timesheetTotalHoursDict isKindOfClass:[NSNull class]] && timesheetTotalHoursDict!=nil )
                {
                    totalHours=[Util convertApiTimeDictToDecimal:timesheetTotalHoursDict];
                }
            }
            
            if ((![timesheetTotalHoursDict isKindOfClass:[NSNull class]] && timesheetTotalHoursDict!=nil) &&  (![breakHoursDict isKindOfClass:[NSNull class]] && breakHoursDict!=nil))
            {
                
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
                [timesheetDataDict setObject:hoursIncludingBreak      forKey:@"totalDurationDecimal"];
                [timesheetDataDict setObject:hoursIncludingBreakStr   forKey:@"totalDurationHour"];
            }
            
            if (isFromSave)
            {
                if (timesheetSummaryDict[@"workingTimeDuration"]) {
                    NSDictionary *workingTimeDurationDict=[timesheetSummaryDict objectForKey:@"workingTimeDuration"];
                    NSNumber *workingTimeHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:workingTimeDurationDict];
                    NSString *workingTimeHoursInHourFormat=[Util convertApiTimeDictToString:workingTimeDurationDict];
                    [timesheetDataDict setObject:workingTimeHoursInDecimalFormat      forKey:@"regularDurationDecimal"];
                    [timesheetDataDict setObject:workingTimeHoursInHourFormat   forKey:@"regularDurationHour"];
                }
            }

        }
        
        
        NSMutableArray *timesheetApproverSummaryArray=nil;
        if ([responseDictionaryObject objectForKey:@"approvalDetails"]!=nil && ![[responseDictionaryObject objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            timesheetApproverSummaryArray=[[responseDictionaryObject objectForKey:@"approvalDetails"]objectForKey:@"history"];
        }
        


        //Implemented For overlappingTimeEntriesPermitted Permission
        [timesheetDataDict setObject:[NSNumber numberWithInt:overlappingTimeEntriesPermitted]forKey:@"overlappingTimeEntriesPermitted"];
        [timesheetDataDict setObject:[NSNumber numberWithInt:canEditTimesheet]forKey:@"canEditTimesheet"];
        
        NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
        [myDB updateTable: timesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
        
        
        if (![timesheetApproverSummaryArray isKindOfClass:[NSNull class]] && timesheetApproverSummaryArray!=nil )
        {
            [self saveTimesheetApproverSummaryDataToDBForTimesheetUri:timesheetUri dataArray:timesheetApproverSummaryArray];
        }
        if (![disclaimerDict isKindOfClass:[NSNull class]] && disclaimerDict!=nil )
        {
            [self saveTimesheetDisclaimerDataToDB:disclaimerDict];
        }
        
        if (![timesheetDetailsDict isKindOfClass:[NSNull class]] && timesheetDetailsDict!=nil )
        {
            NSArray *sheetCustomFieldsArray=[timesheetDetailsDict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_SHEET_UDF andEntryURI:nil andtimeEntryDate:nil];
            
            [self saveTimeAlloctionsAndPunchesDataToDBForTimesheetUri:timesheetUri dataDict:responseDictionaryObject];
        }
        
        if (![standardTimesheetDetailsDict isKindOfClass:[NSNull class]] && standardTimesheetDetailsDict!=nil )
        {
            NSArray *sheetCustomFieldsArray=[standardTimesheetDetailsDict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:sheetCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_SHEET_UDF andEntryURI:nil andtimeEntryDate:nil];
            NSArray *projectTaskDetailsArray ;
            NSArray *taskDetailsArray;
            
            NSDictionary *projectTaskDetails = [responseDictionaryObject objectForKey:@"projectTaskDetails"];

            if (![projectTaskDetails isKindOfClass:[NSNull class]] && projectTaskDetails!=nil )
            {
                projectTaskDetailsArray= [projectTaskDetails objectForKey:@"projects"];
                taskDetailsArray=[[responseDictionaryObject objectForKey:@"projectTaskDetails"] objectForKey:@"tasks"];
            }
            [self saveStandardTimeEntriesDataToDBForTimesheetUri:timesheetUri dataDict:standardTimesheetDetailsDict projectTaskDetails:projectTaskDetailsArray taskDetails:taskDetailsArray];
        }

        NSMutableDictionary *timesheetPermittedApprovalActions=nil;
        if ([responseDictionaryObject objectForKey:@"permittedApprovalActions"]!=nil && ![[responseDictionaryObject objectForKey:@"permittedApprovalActions"] isKindOfClass:[NSNull class]])
        {
            timesheetPermittedApprovalActions=[[responseDictionaryObject objectForKey:@"permittedApprovalActions"] mutableCopy];
        }

        if (![timesheetPermittedApprovalActions isKindOfClass:[NSNull class]] && timesheetPermittedApprovalActions!=nil )
        {
            SupportDataModel *supportModel=[[SupportDataModel alloc]init];
            if (![timesheetUri isKindOfClass:[NSNull class]] && timesheetUri!=nil )
            {
                [timesheetPermittedApprovalActions setObject:timesheetUri forKey:@"uri"];
            }
            [supportModel saveTimesheetPermittedApprovalActionsDataToDB:timesheetPermittedApprovalActions];
            
        }
        
    }
    
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
    if ([[timesheetCurrentCapabilities objectForKey:@"hasBreakAccess"] boolValue] == YES )
    {
        hasBreakAccess = 1;
    }
    NSString *hasTimesheetNoticePolicyUri =[timesheetCurrentCapabilities objectForKey:@"timesheetNoticePolicyUri"];
    
    NSMutableDictionary *capabilityDictionary=[NSMutableDictionary dictionary];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasBillingAccess] forKey:@"hasTimesheetBillingAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasProjectAccess] forKey:@"hasTimesheetProjectAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasClientAccess] forKey:@"hasTimesheetClientAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasActivityAccess] forKey:@"hasTimesheetActivityAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasBreakAccess] forKey:@"hasTimesheetBreakAccess"];
    [capabilityDictionary setObject:[NSNumber numberWithInt:hasProgramAccess] forKey:@"hasTimesheetProgramAccess"];
    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [capabilityDictionary setObject:timesheetUri forKey:@"timesheetUri"];
    }
    
    if (hasTimesheetNoticePolicyUri!=nil && ![hasTimesheetNoticePolicyUri isKindOfClass:[NSNull class]])
    {
        [capabilityDictionary setObject:hasTimesheetNoticePolicyUri  forKey:@"disclaimerTimesheetNoticePolicyUri"];
    }
     SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:timesheetCapabilitiesTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
    [myDB insertIntoTable:timesheetCapabilitiesTable data:capabilityDictionary intoDatabase:@""];
}

-(void)saveTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr
{
    NSMutableArray *enableWidgetsArr=[self getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    
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
            NSArray *timeSheetsInfoArr=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                           [cellOEFDataDict setObject:timesheetUri forKey:@"timesheetUri"];
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
                            NSArray *array=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        if (![format isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            [dataDict setObject:[Util getRandomGUID] forKey:@"clientPunchId"];
                        }
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        if (!isEmptyTimeEntry)
                        {
                            NSArray *expArr = [self getTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                            if ([expArr count]>0)
                            {
                                NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                                [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                            }
                            else
                            {
                                NSArray *timeEntriesArr=[self getTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                                
                                if ([timeEntriesArr count]>0)
                                {
                                    NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                                    [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                                }
                                else
                                {
                                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
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
                            NSArray *array=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                            [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTimeEntryValue"];
                            NSNumber *hours=[Util convertApiTimeDictToDecimal:hoursDict];
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
                        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                        
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
                            NSArray *expArr = [self getTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                            if ([expArr count]>0)
                            {
                                NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                                [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
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
                                [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
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
                    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                    [dataDict setObject:uniqueEntryId forKey:@"clientPunchId"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                    //   [self updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
                }
                
                
                
            }

        }
        
        
    }
    
    
    
    
}
//Implemented as per TIME-495//JUHI
-(void)saveTimesheetTimeOffSummaryDataFromApiToDBForGen4:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri
{
   
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    NSMutableArray *enableWidgetsArr=[self getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
   
    
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
                        [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
                        [dataDict setObject:timesheetFormat forKey:@"timesheetFormat"];
                        [dataDict setObject:@"" forKey:@"time_in"];
                        [dataDict setObject:@"" forKey:@"time_out"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                        [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
                        
                        
                        [dataDict setObject:rowNumber forKey:@"rowNumber"];
                        
                        NSArray *expArr = [self getTimesheetTimeOffInfoForRowUri:rowUri timesheetUri:timesheetUri andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
                        if ([expArr count]>0)
                        {
                            NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",rowUri,entryDateToStore];
                            [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                        }
                        else
                        {
                            [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                        }
                    }
                }
                
                
               
              
                
            }

        }
        
        
        
    }
    
}

-(void)saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array isFromTimeoff:(BOOL)isFromTimeOff{
    [self saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:timesheetUri dataArray:array dayOffList:nil isFromTimeoff:isFromTimeOff];
}

-(void)saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array dayOffList:(NSArray *)dayOffList isFromTimeoff:(BOOL)isFromTimeOff
{
    NSMutableArray *enableWidgetsArr=[self getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
    
    
    
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetsDaySummaryTable where:whereStr inDatabase:@""];
    
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
            NSArray *allEntries=(NSArray *)[self getAllTimeEntriesForSheetFromDB:timesheetUri forTimeSheetFormat:format];
            NSArray *timesheetInfoArray=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
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
                            outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]] && ![outTimeString isEqualToString:@""] && ![format isEqualToString:GEN4_STANDARD_TIMESHEET])
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
                    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
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
                    
                    NSArray *tsDaySummaryRowArr=[self getTimesheetinfoForEntryDate:entryDateToStore];
                    if ([tsDaySummaryRowArr count]>0)
                    {
                        [myDB updateTable:timesheetsDaySummaryTable data:dataDict where:[NSString stringWithFormat:@"timesheetEntryDate = '%@'",entryDateToStore] intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:timesheetsDaySummaryTable data:dataDict intoDatabase:@""];
                    }
                    
                    
                    
                }
                
                
            }
            
            
            
            
            
            BOOL isTimesheetEdit=[self getTimeSheetEditStatusForSheetFromDB:timesheetUri];
            isTimesheetEdit=YES;
            int isTimesheetEditStatus=0;
            if (isTimesheetEdit) {
                isTimesheetEditStatus=1;
            }
            
            NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
            [timesheetDataDict setObject:[NSNumber numberWithInt:1]forKey:@"overlappingTimeEntriesPermitted"];
            [timesheetDataDict setObject:[NSNumber numberWithInt:isTimesheetEditStatus]forKey:@"canEditTimesheet"];
            NSArray *timesheetFormatArr=[self getTimeSheetInfoSheetIdentity:timesheetUri];
            NSString *timesheetFormat = format;
            if ([timesheetFormatArr count]>0)
            {
                NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
                if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
                {
                    timesheetFormat = tsFormat;
                }
            }

            [timesheetDataDict setObject:timesheetFormat forKey:@"timesheetFormat"];
            
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
            [myDB updateTable: timesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
        }

        
    }
   
    
}

-(void)saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andFormat:(NSString *)timeSheetFormat
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
                if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                {
                      [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                }
              
                [dataDict setObject:timeSheetFormat forKey:@"timesheetFormat"];

                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];

                NSArray *expArr = [self getTimesheetTimeOffInfoForRowUri:rowUri timesheetUri:timesheetUri andEntryDate:entryDateToStore];
                SQLiteDB *myDB = [SQLiteDB getInstance];

                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",rowUri,entryDateToStore];
                    [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                }
            }
        }

    }

}


-(void)saveTimesheetActivitiesSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetsActivitiesSummaryTable where:whereStr inDatabase:@""];
    for (int i=0; i<[array count]; i++)
    {
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
        
        
        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        if (activityUri!=nil)
        {
            [dataDict setObject:activityUri                      forKey:@"activityUri"];
        }
        
        [dataDict setObject:activityName                     forKey:@"activityName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"activityDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"activityDurationHour"];
        
        NSArray *expArr = [self getTimesheetinfoForActivityIdentity:activityUri timesheetIdentity:timesheetUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"activityUri='%@'",activityUri];
            [myDB updateTable: timesheetsActivitiesSummaryTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timesheetsActivitiesSummaryTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}

-(void)saveTimesheetProjectSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetsProjectsSummaryTable where:whereStr inDatabase:@""];
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
        
        
        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        
        if (projectUri!=nil)
        {
            [dataDict setObject:projectUri                      forKey:@"projectUri"];
        }
        
        
        [dataDict setObject:projectName                     forKey:@"projectName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"projectDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"projectDurationHour"];
        
        NSArray *expArr = [self getTimesheetinfoForProjectIdentity:projectUri timesheetIdentity:timesheetUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"projectUri='%@'",projectUri];
            [myDB updateTable: timesheetsProjectsSummaryTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timesheetsProjectsSummaryTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}


-(void)saveTimesheetBillingSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array withNonBillableDict:(NSDictionary *)nonBillableDict
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetsBillingSummaryTable where:whereStr inDatabase:@""];
//    NSNumber *durationNonBillableHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:nonBillableDict];
//    NSString *durationNonBillableHoursInHourFormat=[Util convertApiTimeDictToString:nonBillableDict];
//    if ([durationNonBillableHoursInDecimalFormat intValue]!=0)
//    {
//        [dataDict setObject:timesheetUri                                forKey:@"timesheetUri"];
//        [dataDict setObject:@""                                         forKey:@"billingUri"];
//        [dataDict setObject:Non_Billable_string                         forKey:@"billingName"];
//        [dataDict setObject:durationNonBillableHoursInDecimalFormat     forKey:@"billingDurationDecimal"];
//        [dataDict setObject:durationNonBillableHoursInHourFormat        forKey:@"billingDurationHour"];
//        [myDB insertIntoTable:timesheetsBillingSummaryTable data:dataDict intoDatabase:@""];
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
        

        
        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        
        if (billingUri!=nil)
        {
            [dataDict setObject:billingUri                      forKey:@"billingUri"];
        }
      
        [dataDict setObject:billingName                     forKey:@"billingName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"billingDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"billingDurationHour"];
        
        NSArray *expArr = [self getTimesheetinfoForProjectIdentity:billingUri timesheetIdentity:timesheetUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"billingUri='%@'",billingUri];
            [myDB updateTable: timesheetsBillingSummaryTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timesheetsBillingSummaryTable data:dataDict intoDatabase:@""];
        }

        
        
    }
    
    
    
}

-(void)saveTimesheetPayrollSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetsPayrollSummaryTable where:whereStr inDatabase:@""];
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
        

        
        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        
        if (payrollUri!=nil)
        {
             [dataDict setObject:payrollUri                      forKey:@"payrollUri"];
        }
        
       
        [dataDict setObject:payrollName                     forKey:@"payrollName"];
        [dataDict setObject:durationHoursInDecimalFormat    forKey:@"payrollDurationDecimal"];
        [dataDict setObject:durationHoursInHourFormat       forKey:@"payrollDurationHour"];
        
        NSArray *expArr = [self getTimesheetinfoForPayrollIdentity:payrollUri timesheetIdentity:timesheetUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"payrollUri='%@'",payrollUri];
            [myDB updateTable: timesheetsPayrollSummaryTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timesheetsPayrollSummaryTable data:dataDict intoDatabase:@""];
        }

        
    }
    
        
}
//Implemented as per US7859
-(void)saveTimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array withNoticeAcceptedFlag:(int)noticeFlag withAvailableTimeOffTypeCount:(int)availableTimeOffTypeCount isTimesheetCommentsRequired:(BOOL)isTimesheetCommentsRequired
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetsDaySummaryTable where:whereStr inDatabase:@""];
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
        //TODO:Commenting below lines because variable is unused,uncomment when using
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
        
        [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
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
        [dataDict setObject:[NSNumber numberWithInt:availableTimeOffTypeCount] forKey:@"availableTimeOffTypeCount"]; //Implemented as per US7859
        [dataDict setObject:[NSNumber numberWithInt:isCommentsRequired]  forKey:@"isCommentsRequired"];
        
        NSArray *expArr = [self getTimesheetinfoForEntryDate:entryDateToStore];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetEntryDate='%@'",entryDate];
            [myDB updateTable: timesheetsDaySummaryTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timesheetsDaySummaryTable data:dataDict intoDatabase:@""];
        }

        
        
    }
    
        
}

-(void)saveTimesheetApproverSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array
{
  
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timesheetApproverHistoryTable where:whereStr inDatabase:@""];
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
        
        [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
        
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
        
        [myDB insertIntoTable:timesheetApproverHistoryTable data:dataDict intoDatabase:@""];
       
        
        
    }
    
    
}

-(void)saveTimeAlloctionsAndPunchesDataToDBForTimesheetUri:(NSString*)timesheetUri dataDict:(NSMutableDictionary *)responseDict
{
    NSMutableDictionary *timesheetDetailsDict=[responseDict objectForKey:@"inOutTimesheetDetails"];
    NSMutableDictionary *timesheetCapabilities=[responseDict objectForKey:@"capabilities"];

    NSArray *projectTaskDetailsArr = nil;
    NSArray *taskDetailsArr = nil;
    if ([responseDict objectForKey:@"projectTaskDetails"]!=nil && ![[responseDict objectForKey:@"projectTaskDetails"] isKindOfClass:[NSNull class]])
    {
        projectTaskDetailsArr=[[responseDict objectForKey:@"projectTaskDetails"] objectForKey:@"projects"];
        taskDetailsArr=[[responseDict objectForKey:@"projectTaskDetails"] objectForKey:@"tasks"];
    }



    NSMutableArray *timeAllocationArray=[timesheetDetailsDict objectForKey:@"timeOff"];
    NSMutableArray *timePunchesArray=[timesheetDetailsDict objectForKey:@"entries"];
    
    BOOL isExtendedInOutUserPermission=NO;
//    BOOL islockedInOutUserPermission=NO;
    NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    NSArray *arrayDict=[self getTimeSheetInfoSheetIdentity:timesheetUri];
    NSString *approvalStatus=nil;
    if ([arrayDict count]>0)
    {
        approvalStatus=[[arrayDict objectAtIndex:0] objectForKey:@"approvalStatus"];
    }
    //Implemetation for ExtendedInOut
    if ([[timesheetCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES || [[timesheetCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES  )
    {
        isExtendedInOutUserPermission=YES;
    }
    
    else if (approvalStatus!=nil && ([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[approvalStatus isEqualToString:REJECTED_STATUS]))
    {
//        if ([[timesheetCapabilities objectForKey:@"canEditTimesheet"] boolValue] == NO )
//        {
//            islockedInOutUserPermission=YES;
//        }
    }
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
    
    
    NSMutableDictionary *updateDataDict=nil;
    if ([arrayDict count]>0)
    {
        updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
        [updateDataDict removeObjectForKey:@"timesheetFormat"];
//        if (islockedInOutUserPermission)
//        {
//            [updateDataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//        }
//        else if (isExtendedInOutUserPermission)
        if (isExtendedInOutUserPermission)
        {
            [updateDataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
        }
        else
        {
            [updateDataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
        }
        
    }
    [myDB updateTable: timesheetsTable data:updateDataDict where:updateWhereStr intoDatabase:@""];
    

    
    if (![timeAllocationArray isKindOfClass:[NSNull class]] && timeAllocationArray!=nil )
    {
        
        
        
        for (int i=0; i<[timeAllocationArray count]; i++)
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
            NSString *comments=@"";
            
//            NSString *clientName=nil;
//            NSString *clientURI=nil;
//            
//            NSDate *rangeStartDate=nil;
//            NSDate *rangeEndDate=nil;
            
            
            NSDictionary *dict=[timeAllocationArray objectAtIndex:i];
            comments=@"";
            
            
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
                
                [dataDict setObject:timesheetUri                             forKey:@"timesheetUri"];
                
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
//                if (islockedInOutUserPermission)
//                {
//                    [dataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//                }//Implemetation for ExtendedInOut
//                else if (isExtendedInOutUserPermission)
                if (isExtendedInOutUserPermission)
                {
                    [dataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                }
                else
                {
                    [dataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
                }
                
                //DE18929 Ullas M L fix since a specific ts returns timepunches which is not in the timesheet period.hence added a validation to ensure we save only correct punches.It was a sample db issue from service.
                NSDate *startDateAllowed=[Util convertApiDateDictToDateFormat:[[timesheetDetailsDict objectForKey:@"dateRange"] objectForKey:@"startDate"]];
                NSDate *endDateAllowed=[Util convertApiDateDictToDateFormat:[[timesheetDetailsDict objectForKey:@"dateRange"] objectForKey:@"endDate"]];
                
                BOOL isInTimeSheetPeriodRange=[Util date:entryDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                
                if (isInTimeSheetPeriodRange)
                {
                    NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
                    [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:timeAllocationUri andtimeEntryDate:entryDateToStore];
                    
                    NSArray *expArr = [self getTimesheetInfoForTimeAllocationUri:timeAllocationUri timesheetUri:timesheetUri];
                    if ([expArr count]>0)
                    {
                        NSString *whereString=[NSString stringWithFormat:@"timeAllocationUri = '%@'",timeAllocationUri];
                        [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
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
            //MOBI-746
            NSString *programName=nil;
            NSString *programURI=nil;
            
            NSDate *rangeStartDate=nil;
            NSDate *rangeEndDate=nil;
            
            //Implentation for US8956//JUHI
            NSString *breakName=@"";
            NSString *breakUri=@"";
            inTimeStr=@"";
            outTimeStr=@"";
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
            NSMutableArray *punchInfoDictArray=[dict objectForKey:@"associatedTimeAllocations"];
            if ([punchInfoDictArray count]>0)
            {
                NSDictionary *punchInfoDict=[punchInfoDictArray objectAtIndex:0];
                NSString *timeOffType=[punchInfoDict objectForKey:@"timeOffType"];
                if (timeOffType==nil || [timeOffType isKindOfClass:[NSNull class]])
                {
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
                    NSString *comments=[punchInfoDict objectForKey:@"comments"];
                    [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
                    [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
                    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
                    [dataDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                    [dataDict setObject:entryDateToStore  forKey:@"timesheetEntryDate"];
                    [dataDict setObject:totalTimeHoursInDecimalFormat forKey:@"durationDecimalFormat"];
                    [dataDict setObject:totalTimeHoursInHourFormat forKey:@"durationHourFormat"];
                    
                    [dataDict setObject:billingName forKey:@"billingName"];
                    [dataDict setObject:billingUri forKey:@"billingUri"];
                    [dataDict setObject:activityName forKey:@"activityName"];
                    [dataDict setObject:activityURI forKey:@"activityUri"];
                    [dataDict setObject:projectURI  forKey:@"projectUri"];
                    [dataDict setObject:projectName forKey:@"projectName"];
                    if (clientURI!=nil && ![clientURI isKindOfClass:[NSNull class]])
                    {
                         [dataDict setObject:clientURI  forKey:@"clientUri"];
                    }
                    if (clientName!=nil && ![clientName isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:clientName forKey:@"clientName"];
                    }
                    //MOBI-746
                    if (programURI!=nil && ![programURI isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:programURI  forKey:@"programUri"];
                    }
                    if (programName!=nil && ![programName isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:programName forKey:@"programName"];
                    }
                    
                    [dataDict setObject:taskName forKey:@"taskName"];
                    [dataDict setObject:taskURI forKey:@"taskUri"];
                    if (comments!=nil && ![comments isKindOfClass:[NSNull class]])
                    {
                        [dataDict setObject:comments forKey:@"comments"];
                    }
                    else
                    {
                        [dataDict setObject:@"" forKey:@"comments"];
                    }
                    
                    [dataDict setObject:timeOffName forKey:@"timeOffTypeName"];
                    [dataDict setObject:timeOffUri forKey:@"timeOffUri"];
		    //Implentation for US8956//JUHI
                    [dataDict setObject:breakName forKey:@"breakName"];
                    [dataDict setObject:breakUri forKey:@"breakUri"];
//                    if (islockedInOutUserPermission)
//                    {
//                        [dataDict setObject:LOCKED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//                    }
//                    //Implemetation for ExtendedInOut
//                    else if (isExtendedInOutUserPermission)
                    if (isExtendedInOutUserPermission)
                    {
                        [dataDict setObject:EXTENDED_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                    }
                    else
                    {
                        [dataDict setObject:INOUT_TIMESHEET forKey:@"timesheetFormat"];
                    }
                    
                    if (inTimeStr != nil && ![inTimeStr isKindOfClass:[NSNull class]]
                        &&[inTimeStr isKindOfClass:[NSString class]]) {
                        [dataDict setObject:inTimeStr forKey:@"time_in"];
                    }
                    if (outTimeStr != nil && ![outTimeStr isKindOfClass:[NSNull class]]
                        &&[outTimeStr isKindOfClass:[NSString class]]) {
                        [dataDict setObject:outTimeStr forKey:@"time_out"];
                    }
                    
                    //DE18929 Ullas M L fix since a specific ts returns timepunches which is not in the timesheet period.hence added a validation to ensure we save only correct punches.It was a sample db issue from service.
                    NSDate *startDateAllowed=[Util convertApiDateDictToDateFormat:[[timesheetDetailsDict objectForKey:@"dateRange"] objectForKey:@"startDate"]];
                    NSDate *endDateAllowed=[Util convertApiDateDictToDateFormat:[[timesheetDetailsDict objectForKey:@"dateRange"] objectForKey:@"endDate"]];
                    
                    BOOL isInTimeSheetPeriodRange=[Util date:entryDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                    
                    if (isInTimeSheetPeriodRange)
                    {
                        if (isExtendedInOutUserPermission)
                        {
                            NSArray *cellCustomFieldsArray=[punchInfoDict objectForKey:@"customFieldValues"];
                            [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_CELL_UDF andEntryURI:timePunchesUri andtimeEntryDate:entryDateToStore];
                        }
                        
                        
                        NSArray *expArr = [self getTimesheetInfoForTimePunchesUri:timePunchesUri timesheetUri:timesheetUri];
                        if ([expArr count]>0)
                        {
                            NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",timePunchesUri];
                            [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                        }
                        else
                        {
                            [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                        }

                    }

                    
                    
                }
            }
                    
        }
    }
    
    
}
-(void)saveStandardTimeEntriesDataToDBForTimesheetUri:(NSString*)timesheetUri dataDict:(NSMutableDictionary *)standardTimesheetDetailsDict projectTaskDetails:(NSArray *)projectTaskDetailsArr taskDetails:taskDetailsArr
{
    NSMutableArray *timeEntryRowsArray=[standardTimesheetDetailsDict objectForKey:@"rows"];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
    
    NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    NSArray *arrayDict=[self getTimeSheetInfoSheetIdentity:timesheetUri];
    
    if ([arrayDict count]>0)
    {
        NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
        [updateDataDict removeObjectForKey:@"timesheetFormat"];
        [updateDataDict setObject:STANDARD_TIMESHEET forKey:@"timesheetFormat"];
        [myDB updateTable: timesheetsTable data:updateDataDict where:updateWhereStr intoDatabase:@""];
        
        
        
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
                    [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                    [dataDict setObject:entryDateToStore                forKey:@"timesheetEntryDate"];
                    [dataDict setObject:totalTimeHoursInDecimalFormat   forKey:@"durationDecimalFormat"];
                    [dataDict setObject:totalTimeHoursInHourFormat      forKey:@"durationHourFormat"];
                    [dataDict setObject:commentsString                  forKey:@"comments"];
                    [dataDict setObject:rowUri                          forKey:@"rowUri"];
                    [dataDict setObject:STANDARD_TIMESHEET              forKey:@"timesheetFormat"];
                    
                    
//                    NSArray *cellCustomFieldsArray=[cellDict objectForKey:@"customFieldValues"];
                    [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:rowUri andtimeEntryDate:entryDateToStore ];
//
                    
                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                    
                    
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
                [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
                [dataDict setObject:entryDateToStore                forKey:@"timesheetEntryDate"];
                [dataDict setObject:totalTimeHoursInDecimalFormat   forKey:@"durationDecimalFormat"];
                [dataDict setObject:totalTimeHoursInHourFormat      forKey:@"durationHourFormat"];
                [dataDict setObject:commentsString                  forKey:@"comments"];
                [dataDict setObject:rowUri                          forKey:@"rowUri"];
                [dataDict setObject:STANDARD_TIMESHEET              forKey:@"timesheetFormat"];
                
                
                NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
                [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMEOFF_UDF andEntryURI:rowUri andtimeEntryDate:entryDateToStore ];
                
                [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                
                

                
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
                for (int count=0; count<[(NSMutableArray *)taskDetailsArr count]; count++)
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
            [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_ROW_UDF andEntryURI:[dict objectForKey:@"uri"] andtimeEntryDate:nil];//Implementation for US9371//JUHI
            
            
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
                    [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
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
                    [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_CELL_UDF andEntryURI:timeAllocationUri andtimeEntryDate:entryDateToStore ];
                   
                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
                    
                    
                    
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
                [dataDict setObject:timesheetUri                    forKey:@"timesheetUri"];
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
                
                
                NSArray *cellCustomFieldsArray=[dict objectForKey:@"customFieldValues"];
                [self saveCustomFieldswithData:cellCustomFieldsArray forSheetURI:timesheetUri andModuleName:TIMESHEET_CELL_UDF andEntryURI:timeAllocationUri andtimeEntryDate:entryDateToStore ];
                
                [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
            }
            
        }
        
        
    }
        
}

-(void)saveTimesheetDisclaimerDataToDB:(NSMutableDictionary *)disclaimerDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disclaimerDescription=[disclaimerDict objectForKey:@"description"];
    NSString *disclaimerTitle=[disclaimerDict objectForKey:@"title"];
    NSString *disclaimerModule=TIMESHEET_MODULE_NAME;
    NSString *whereStr=[NSString stringWithFormat:@"module= '%@' ",disclaimerModule];
    [myDB deleteFromTable:disclaimerTable where:whereStr inDatabase:@""];
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:disclaimerDescription forKey:@"description"];
    [dataDict setObject:disclaimerTitle forKey:@"title"];
    [dataDict setObject:disclaimerModule forKey:@"module"];
    
    [myDB insertIntoTable:disclaimerTable data:dataDict intoDatabase:@""];
}
-(void)saveEnabledTimeoffTypesDataToDB:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];

   
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        NSString *timeoffTypeName=[dict objectForKey:@"displayText"];
        NSString *timeoffTypeUri=[dict objectForKey:@"uri"];
        
        [dataDict setObject:timeoffTypeName forKey:@"timeoffTypeName"];
        [dataDict setObject:timeoffTypeUri forKey:@"timeoffTypeUri"];
        
        [myDB insertIntoTable:timeoffTypesTable data:dataDict intoDatabase:@""];
    }
    
}
-(void)saveClientDetailsDataToDB:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSString *clientName=[dict objectForKey:@"displayText"];
        NSString *clientUri=[dict objectForKey:@"uri"];
        NSString *client_Name=[dict objectForKey:@"name"];//Implementation for US8849//JUHI
        
//        NSDictionary *endDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"endDate"];
//        NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
//        
//        NSDictionary *startDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"startDate"];
//        NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
        
        
        [dataDict setObject:clientName forKey:@"clientName"];
        [dataDict setObject:clientUri forKey:@"clientUri"];
        [dataDict setObject:client_Name forKey:@"client_Name"];//Implementation for US8849//JUHI
        
//        [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
//        [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
        [dataDict setObject:@"Timesheet" forKey:@"moduleName"];
        
        NSArray *expArr = [self getClientDetailsFromDBForClientUri:clientUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"clientUri='%@'",clientUri];
            [myDB updateTable: clientsTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:clientsTable data:dataDict intoDatabase:@""];
        }

        
    }

    

}
//MOBI-746
-(void)saveProgramDetailsDataToDB:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSString *clientName=[dict objectForKey:@"displayText"];
        NSString *clientUri=[dict objectForKey:@"uri"];
        NSString *client_Name=[dict objectForKey:@"name"];//Implementation for US8849//JUHI
        
        //        NSDictionary *endDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"endDate"];
        //        NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
        //
        //        NSDictionary *startDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"startDate"];
        //        NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
        
        
        [dataDict setObject:clientName forKey:@"programName"];
        [dataDict setObject:clientUri forKey:@"programUri"];
        [dataDict setObject:client_Name forKey:@"program_Name"];//Implementation for US8849//JUHI
        
        //        [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
        //        [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
        [dataDict setObject:@"Timesheet" forKey:@"moduleName"];
        
        NSArray *expArr = [self getProgramDetailsFromDBForProgramUri:clientUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"programUri='%@'",clientUri];
            [myDB updateTable: programsTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:programsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
    
    
}

-(void)saveProjectDetailsDataToDB:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *clientInfoDict=[dict objectForKey:@"client"];
        NSDictionary *programInfoDict=[dict objectForKey:@"program"];//MOBI-746
        NSString *clientName=@"";
        NSString *clientUri=@"";
        NSString *programName=@"";
        NSString *programUri=@"";
        if (clientInfoDict!=nil && ![clientInfoDict isKindOfClass:[NSNull class]])
        {
            clientName=[clientInfoDict objectForKey:@"displayText"];
            clientUri=[clientInfoDict objectForKey:@"uri"];
        }
        if (programInfoDict!=nil && ![programInfoDict isKindOfClass:[NSNull class]])
        {
            programName=[programInfoDict objectForKey:@"displayText"];
            programUri=[programInfoDict objectForKey:@"uri"];//MOBI-746
        }
        
        
        
        NSString *projectName=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
        NSString *projectUri=[[dict objectForKey:@"project"] objectForKey:@"uri"];
        //Implementation for US8849//JUHI
        NSString *project_Name=nil;
        if ([[[dict objectForKey:@"project"] objectForKey:@"displayText"] isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)])
        {
            project_Name=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
        }
        else
            project_Name=[[dict objectForKey:@"project"] objectForKey:@"name"];
            
        
        int isTimeAllocationAllowed  =0;
        if ([[dict objectForKey:@"isTimeAllocationAllowed"] boolValue] == YES )
        {
            isTimeAllocationAllowed = 1;
        }
        int hasTasksAvailableForTimeAllocation  =0;
        if ([[dict objectForKey:@"hasTasksAvailableForTimeAllocation"] boolValue] == YES )
        {
            hasTasksAvailableForTimeAllocation = 1;
        }

        NSDictionary *endDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"endDate"];
        NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
        
        NSDictionary *startDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"startDate"];
        NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
        
        
        [dataDict setObject:clientName forKey:@"clientName"];
        [dataDict setObject:clientUri forKey:@"clientUri"];
        [dataDict setObject:programName forKey:@"programName"];//MOBI-746
        [dataDict setObject:programUri forKey:@"programUri"];//MOBI-746
        [dataDict setObject:projectName forKey:@"projectName"];
        [dataDict setObject:projectUri forKey:@"projectUri"];
        [dataDict setObject:project_Name forKey:@"project_Name"];//Implementation for US8849//JUHI
        [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
        [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
        [dataDict setObject:[NSNumber numberWithInt:isTimeAllocationAllowed] forKey:@"isTimeAllocationAllowed"];
        [dataDict setObject:[NSNumber numberWithInt:hasTasksAvailableForTimeAllocation] forKey:@"hasTasksAvailableForTimeAllocation"];
        [dataDict setObject:@"Timesheet" forKey:@"moduleName"];
        
        NSArray *expArr = [self getProjectDetailsFromDBForProjectUri:projectUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"projectUri='%@'",projectUri];
            [myDB updateTable: projectsTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:projectsTable data:dataDict intoDatabase:@""];
        }

        
    }
    
    
    
}

-(void)saveTaskDetailsDataToDB:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *taskInfoDict=[dict objectForKey:@"task"];
        NSString *taskName=@"";
        NSString *taskUri=@"";
        if (taskInfoDict!=nil && ![taskInfoDict isKindOfClass:[NSNull class]])
        {
            taskName=[taskInfoDict objectForKey:@"displayText"];
            taskUri=[taskInfoDict objectForKey:@"uri"];
        }
        NSString *taskFullPath=[dict objectForKey:@"taskFullPath"];
        NSDictionary *endDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"endDate"];
        NSDate *endDate=[Util convertApiDateDictToDateFormat:endDateDict];
        
        NSDictionary *startDateDict=[[dict objectForKey:@"dateRangeWhereTimeAllocationIsAllowed"] objectForKey:@"startDate"];
        NSDate *startDate=[Util convertApiDateDictToDateFormat:startDateDict];
        
        [dataDict setObject:taskName forKey:@"taskName"];
        [dataDict setObject:taskUri forKey:@"taskUri"];
        if (taskFullPath==nil) {
            taskFullPath=@"";
        }
        [dataDict setObject:taskFullPath forKey:@"taskFullPath"];
        [dataDict setObject:@"Timesheet" forKey:@"moduleName"];
        [dataDict setObject:[NSNumber numberWithDouble:[endDate timeIntervalSince1970]] forKey:@"endDate"];
        [dataDict setObject:[NSNumber numberWithDouble:[startDate timeIntervalSince1970]] forKey:@"startDate"];
        
        NSArray *expArr = [self getTaskDetailsFromDBForTaskUri:taskUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"taskUri='%@'",taskUri];
            [myDB updateTable:tasksTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:tasksTable data:dataDict intoDatabase:@""];
        }

        
    }
}
-(void)saveBillingDetailsDataToDB:(NSMutableArray *)array withModuleName:(NSString*)module
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSString *billingName=@"";
        NSString *billingUri=@"";
        if (dict!=nil && ![dict isKindOfClass:[NSNull class]])
        {
            billingName=[dict objectForKey:@"displayText"];
            billingUri=[dict objectForKey:@"uri"];
        }
        [dataDict setObject:billingName forKey:@"billingName"];
        [dataDict setObject:billingUri forKey:@"billingUri"];
        [dataDict setObject:module forKey:@"moduleName"];
        
        NSArray *expArr = [self getBillingDetailsFromDBForBillingUri:billingUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"billingUri='%@'",billingUri];
            [myDB updateTable:billingTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:billingTable data:dataDict intoDatabase:@""];
        }
        
        
    }

}
-(void)saveActivityDetailsDataToDB:(NSMutableArray *)array withModuleName:(NSString*)module
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSString *activityName=@"";
        NSString *activityUri=@"";
        //Implementation for US8849//JUHI
        NSString *activity_Name=@"";
        
        
        if (dict!=nil && ![dict isKindOfClass:[NSNull class]])
        {
            activityName=[dict objectForKey:@"displayText"];
            activityUri=[dict objectForKey:@"uri"];
            //Implementation for US8849//JUHI
            if ([activityName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)])
            {
                activity_Name=[dict objectForKey:@"displayText"];
            }
            else
                activity_Name=[dict objectForKey:@"name"];
        }
        
        
        
        [dataDict setObject:activityName forKey:@"activityName"];
        [dataDict setObject:activityUri forKey:@"activityUri"];
        [dataDict setObject:activity_Name forKey:@"activity_Name"];//Implementation for US8849//JUHI
        [dataDict setObject:module forKey:@"moduleName"];
        
        NSArray *expArr = [self getActivityDetailsFromDBForActivityUri:activityUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"activityUri='%@'",activityUri];
            [myDB updateTable:activityTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:activityTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
}


-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI andtimeEntryDate:(NSNumber *)entryDate
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
        
        NSArray *udfsArr = [self getTimesheetCustomFieldsForSheetURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri andEntryDate:[NSString stringWithFormat:@"%@",entryDate]];
        if ([udfsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"timesheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
            [myDB updateTable:timesheetCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:timesheetCustomFieldsTable data:udfDataDict intoDatabase:@""];
        }

         
    }
}
//Implentation for US8956//JUHI
-(void)saveBreakDetailsDataToDB:(NSMutableArray *)array 
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSString *breakName=@"";
        NSString *breakUri=@"";
        if (dict!=nil && ![dict isKindOfClass:[NSNull class]])
        {
            breakName=[dict objectForKey:@"displayText"];
            breakUri=[dict objectForKey:@"uri"];
        }
        [dataDict setObject:breakName forKey:@"breakName"];
        [dataDict setObject:breakUri forKey:@"breakUri"];
        
        
        NSArray *expArr = [self getBreakDetailsFromDBForBreakUri:breakUri];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"breakUri='%@'",breakUri];
            [myDB updateTable:breakTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:breakTable data:dataDict intoDatabase:@""];
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


-(void)saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri
{

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSArray *timeSheetsInfoArr=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                [cellOEFDataDict setObject:timesheetUri forKey:@"timesheetUri"];
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

                    NSArray *array=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                [dataDict setObject:timesheetUri forKey:@"timesheetUri"];

                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isModified"];
                [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];

                NSArray *expArr = [self getTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                    [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {
                    NSArray *timeEntriesArr=[self getTimesheetInfoForTimeIn:inTimeString andTimeOut:outTimeString timesheetUri:timesheetUri andEntryDate:entryDateToStore];

                    if ([timeEntriesArr count]>0)
                    {
                        NSString *whereString=[NSString stringWithFormat:@"time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",inTimeString,outTimeString,timesheetUri,entryDateToStore];
                        [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                    }
                    else
                    {
                        [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
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

                    NSArray *array=[self getTimeSheetInfoSheetIdentity:timesheetUri];
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
                [dataDict setObject:timesheetUri forKey:@"timesheetUri"];

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

                NSArray *expArr = [self getTimesheetInfoForTimePunchesUri:uri timesheetUri:timesheetUri];
                if ([expArr count]>0)
                {
                    NSString *whereString=[NSString stringWithFormat:@"timePunchesUri = '%@'",uri];
                    [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
                }
                else
                {

                    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];

                }
            }
        }

    }
}

-(NSArray *)getTimesheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri andEntryDate:(NSString *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' and timesheetEntryDate='%@'",timesheetCustomFieldsTable,sheetUri,moduleName,entryUri,udfUri,entryDate];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getTimesheetinfoForActivityIdentity:(NSString *)activityIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

	NSString *query=[NSString stringWithFormat:@" select * from %@ where activityUri = '%@' and timesheetUri='%@' ",timesheetsActivitiesSummaryTable,activityIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}


-(NSArray *)getTimesheetinfoForProjectIdentity:(NSString *)projectIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

	NSString *query=[NSString stringWithFormat:@" select * from %@ where projectUri = '%@' and timesheetUri='%@' ",timesheetsProjectsSummaryTable,projectIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getTimesheetinfoForBillingIdentity:(NSString *)billingIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

	NSString *query=[NSString stringWithFormat:@" select * from %@ where billingUri = '%@' and timesheetUri='%@'",timesheetsBillingSummaryTable,billingIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray *)getTimesheetinfoForPayrollIdentity:(NSString *)payrollIdentity timesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

	NSString *query=[NSString stringWithFormat:@" select * from %@ where payrollUri = '%@' and timesheetUri='%@'",timesheetsPayrollSummaryTable,payrollIdentity,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getTimesheetInfoForTimeAllocationUri:(NSString*)timeAllocationUri timesheetUri:(NSString *)timesheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];

	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeAllocationUri = '%@' and timesheetUri='%@' AND isDeleted=0",timeEntriesTable,timeAllocationUri,timesheetUri];
    
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where timeAllocationUri = '%@' and timesheetUri='%@' AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timeAllocationUri,timesheetUri,tsFormat];
    }
    
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@'  AND isDeleted=0",timeEntriesTable,rowUri,timesheetUri,entryDate];
    
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@'  AND isDeleted=0  AND timesheetFormat='%@'",timeEntriesTable,rowUri,timesheetUri,entryDate,tsFormat];
    }
    
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}


-(NSArray*)getTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate forTimesheetFormat:(NSString *)timesheetFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *query=[NSString stringWithFormat:@" select * from %@ where rowUri = '%@' and timesheetUri='%@' and timesheetEntryDate='%@'  AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,rowUri,timesheetUri,entryDate,timesheetFormat];
    
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
    if ([array count]!=0) {
        return array;
    }
    return nil;
}

-(NSArray*)getTimesheetInfoForTimePunchesUri:(NSString*)timePunchesUri timesheetUri:(NSString *)timesheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timePunchesUri = '%@' and timesheetUri='%@'  AND isDeleted=0",timeEntriesTable,timePunchesUri,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where timePunchesUri = '%@' and timesheetUri='%@'  AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timePunchesUri,timesheetUri,tsFormat];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSArray*)getTimesheetInfoForTimeIn:(NSString*)time_in andTimeOut:(NSString*)time_out timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *query=[NSString stringWithFormat:@" select * from %@ where time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@'",timeEntriesTable,time_in,time_out,timesheetUri,entryDate];
    
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        query=[NSString stringWithFormat:@" select * from %@ where time_in = '%@' COLLATE NOCASE and time_out='%@' COLLATE NOCASE and timesheetUri='%@' and   timesheetEntryDate='%@' AND timesheetFormat='%@'",timeEntriesTable,time_in,time_out,timesheetUri,entryDate,tsFormat];
    }
    
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
    if ([array count]!=0) {
        return array;
    }
    return nil;
}


-(NSArray *)getTimesheetinfoForEntryDate:(NSNumber *)entryDate
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetEntryDate = '%@' ",timesheetsDaySummaryTable,entryDate];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}



-(NSArray *)getTimeSheetInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' order by startDate desc",timesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return timeSheetsArr;
	}
	return nil;
    
}
-(NSDictionary *)getTotalHoursInfoForTimesheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select totalDurationDecimal from %@ where timesheetUri = '%@' order by startDate desc",timesheetsTable,sheetIdentity];
	NSMutableArray *timeSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeSheetsArr count]!=0) {
		return [timeSheetsArr objectAtIndex:0];
	}
	return nil;
    
}

-(NSMutableArray *) getAllTimesheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by startDate desc",timesheetsTable];
	NSMutableArray *timesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timesheetsArray count]>0)
    {
		return timesheetsArray;
	}
	return nil;
}

-(NSMutableArray *) getAllTimesheetsUrisFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select timeSheetUri from %@ order by startDate desc",timesheetsTable];
    NSMutableArray *timesheetsArray = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([timesheetsArray count]>0)
    {
        return timesheetsArray;
    }
    return [NSMutableArray array];
}

-(NSMutableArray *) getAllTimeOffTypesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timeoffTypesTable];
	NSMutableArray *timeoffTypesArray =[myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeoffTypesArray count]>0)
    {
		return timeoffTypesArray;
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

-(void)deleteAllTimesheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:timesheetsTable inDatabase:@""];
}
-(void)deleteAllClientsInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",clientsTable,moduleName];
	[myDB executeQuery:query];
}
-(void)deleteAllProjectsInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",projectsTable,moduleName];
	[myDB executeQuery:query];
}
//MOBI-746
-(void)deleteAllProgramsInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",programsTable,moduleName];
    [myDB executeQuery:query];
}
-(void)deleteAllTasksInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",tasksTable,moduleName];
	[myDB executeQuery:query];
}
-(void)deleteAllBillingInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",billingTable,moduleName];
	[myDB executeQuery:query];
}
-(void)deleteAllActivityInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",activityTable,moduleName];
	[myDB executeQuery:query];
}

-(void)deleteObjectExtensionFieldsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query=[NSString stringWithFormat:@"delete from %@ where timesheetUri = '%@'",timesheetObjectExtensionFieldsTable,timesheetUri];
    [myDB executeQuery:query];
}

-(NSMutableArray *) getAllTimesheetProjectSummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timesheetsProjectsSummaryTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllTimesheetBillingSummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timesheetsBillingSummaryTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllTimesheetPayrollSummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timesheetsPayrollSummaryTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllTimesheetApproverSummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timesheetApproverHistoryTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *) getAllTimesheetApproverSummaryFromDBInLatestOrderForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri = '%@' order by actionDate desc",timesheetApproverHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSString *)getLatestTimesheetHistoryActionUriForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select actionUri from %@ where timesheetUri = '%@' order by actionDate desc LIMIT 1",timesheetApproverHistoryTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        NSString *statusStr =NOT_SUBMITTED_STATUS;
        if ([array[0][@"actionUri"] isEqualToString:Submit_Action_URI])
        {
            statusStr=WAITING_FOR_APRROVAL_STATUS;

        }
        else if ([array[0][@"actionUri"] isEqualToString:Reject_Action_URI])
        {
            statusStr=REJECTED_STATUS;

        }
        else if ([array[0][@"actionUri"] isEqualToString:Approved_Action_URI]||[array[0][@"actionUri"] isEqualToString:SystemApproved_Action_URI])
        {
            statusStr=APPROVED_STATUS;

        }
        else if ([array[0][@"actionUri"] isEqualToString:Reopen_Action_URI])
        {
            statusStr=NOT_SUBMITTED_STATUS;

        }

        return statusStr;
    }
    return nil;
}


-(NSMutableArray *) getAllTimesheetDaySummaryFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",timesheetsDaySummaryTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllTimesheetDaySummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",timesheetsDaySummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(NSMutableArray *) getAllTimesheetProjectSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by projectName asc",timesheetsProjectsSummaryTable,timesheetUri];
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

-(NSMutableArray *) getAllTimesheetActivitySummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by activityName asc",timesheetsActivitiesSummaryTable,timesheetUri];
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

-(NSMutableArray *) getAllTimesheetPayrollSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by payrollName asc",timesheetsPayrollSummaryTable,timesheetUri];
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
-(NSMutableArray *) getAllTimesheetBillingSummaryFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US7972
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'order by billingName asc",
                     timesheetsBillingSummaryTable,timesheetUri];
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

-(void)deleteAllSavedTimeoffTypes
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:timeoffTypesTable inDatabase:@""];
}


-(NSString *)getTotalActivitySummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(activityDurationDecimal) from %@ where timesheetUri='%@'",timesheetsActivitiesSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(activityDurationDecimal)"];
         return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getTotalProjectSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(projectDurationDecimal) from %@ where timesheetUri='%@'",timesheetsProjectsSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(projectDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getTotalPayrollSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(payrollDurationDecimal) from %@ where timesheetUri='%@'",timesheetsPayrollSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(payrollDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSString *)getTotalBillingSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    if ([format isEqualToString:@"DECIMAL"])
    {
        NSString *sql = [NSString stringWithFormat:@"select sum(billingDurationDecimal) from %@ where timesheetUri='%@'",timesheetsBillingSummaryTable,timesheetUri];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        NSNumber *value = [[array objectAtIndex:0]objectForKey:@"sum(billingDurationDecimal)"];
        return [Util getRoundedValueFromDecimalPlaces:[value newDoubleValue]withDecimalPlaces:2];
    }
    
    return nil;
}

-(NSMutableArray *)getAllDisclaimerDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where module='%@'",disclaimerTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllClientsDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",clientsTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
//MOBI_746
-(NSMutableArray *)getAllProgramsDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",programsTable,moduleName];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
}

-(NSMutableArray *)getAllProjectsDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",projectsTable,moduleName];
    
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllTasksDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",tasksTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllBillingDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",billingTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllActivityDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",activityTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getClientDetailsFromDBForClientUri:(NSString *)clientUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientUri='%@'",clientsTable,clientUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
//MOBI-746
-(NSMutableArray *)getProgramDetailsFromDBForProgramUri:(NSString *)programUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where programUri='%@'",programsTable,programUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
}
-(NSMutableArray *)getProjectDetailsFromDBForProjectUri:(NSString *)projectUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where projectUri='%@'",projectsTable,projectUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getProjectDetailsFromDBForProjectUri:(NSString *)projectUri andModuleName:(NSString*)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where projectUri='%@'and moduleName='%@'",projectsTable,projectUri,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}

-(NSMutableArray *)getTaskDetailsFromDBForTaskUri:(NSString *)taskUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where taskUri='%@'",tasksTable,taskUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getTaskDetailsFromDBForTaskUri:(NSString *)taskUri andModuleName:(NSString*)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where taskUri='%@'and moduleName='%@'",tasksTable,taskUri,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getActivityDetailsFromDBForActivityUri:(NSString *)activityUri andModuleName:(NSString*)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where activityUri='%@'and moduleName='%@'",activityTable,activityUri,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getBillingDetailsFromDBForBillingUri:(NSString *)billingUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where billingUri='%@'",billingTable,billingUri];
	NSMutableArray *array =[myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getActivityDetailsFromDBForActivityUri:(NSString *)activityUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where activityUri='%@'",activityTable,activityUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *) getTimeEntriesForSheetFromDB: (NSString *)timesheetUri {
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0  AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:timeEntriesTable where:whereString  intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        for (int i=0; i<[dueDatesArray count]; i++)
        {
            NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@'  AND isDeleted=0 order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri];
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@'  AND isDeleted=0 AND timesheetFormat='%@' order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,tsFormat];
            }
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString1 intoDatabase:@""];
            
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

-(NSMutableArray *) getTimeEntriesForExtendedInOutSheetFromDB: (NSString *)timesheetUri andTimeSheetFormat:(NSString *)timesheetFormat{
    
    BOOL isGen4Timesheet=NO;
    
    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
    {
        if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]]&&([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] ||  [timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET]))
        {
            isGen4Timesheet=YES;
        }
    }
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by timesheetEntryDate asc",timesheetUri];
    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,timesheetFormat];
    }
    
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:timeEntriesTable where:whereString  intoDatabase:@""];
    if (dueDatesArray != nil && [dueDatesArray count]>0)
    {
        
        
        for (int b=0; b<[dueDatesArray count]; b++)
        {
            NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND isDeleted=0 order by time_in asc",[[dueDatesArray objectAtIndex:b] objectForKey:@"timesheetEntryDate" ],timesheetUri];
            if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by time_in asc",[[dueDatesArray objectAtIndex:b] objectForKey:@"timesheetEntryDate" ],timesheetUri,timesheetFormat];
            }
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString1 intoDatabase:@""];
            
            groupedtsArray=[Util sortArrayAccordingToTimeIn:groupedtsArray];
            
            for (int i=0; i<[groupedtsArray count]; i++)
            {
                NSString *timeOffURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"timeOffUri"];
                
                if (timeOffURI==nil || [timeOffURI isKindOfClass:[NSNull class]] || [timeOffURI isEqualToString:@""])
                {
                    NSString *projectURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectUri"];
                    NSString *activityURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityUri"];
                    NSString *breakURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"];
                    
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    BOOL isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
                    BOOL isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
                    BOOL isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];
                    if (isGen4Timesheet) {
                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetUri];

                        if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]]&&([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] ))
                        {
                            isProjectAccess=NO;
                            isActivityAccess=NO;
                            isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];

                        }
                        else if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]]&&([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ))
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
                                        [[groupedtsArray objectAtIndex:i]objectForKey:@"clientPunchId"],@"clientPunchId",nil]];
                    
                    
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
            BOOL hasValue = (groupedtsArray != nil && ![groupedtsArray isKindOfClass:[NSNull class]]);
            if (hasValue) {
                [groupedTimesheetsArr addObject:groupedtsArray];
            }
        }
    }
    
    
    
    if (isGen4Timesheet)
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        BOOL isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
        BOOL isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
        BOOL isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetUri];

      if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]]&&([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] ))
      {
          isProjectAccess=NO;
          isActivityAccess=NO;
          isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];

      }
      else if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]]&&([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ))
      {
          isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
          isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
          isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
      }


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
    
    BOOL hasObject  = (groupedTimesheetsArr != nil && ![groupedTimesheetsArr isKindOfClass:[NSNull class]]  && [groupedTimesheetsArr count]>0);
    if (hasObject)
    {
        return groupedTimesheetsArr;
    }
    return nil;
}


-(NSMutableArray *) getUniqueExtendedInOutProjectsSuggestionsFromDB: (NSString *)timesheetUri ForEntryDate:(NSDate *)entryDate
{
    NSString *fetchEntryDate=[NSString stringWithFormat:@"%f", [Util convertDateToTimestamp:entryDate]];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *uniqueProjectsArray=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by timesheetEntryDate asc",timesheetUri];
    
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    
    NSMutableArray *dueDatesArray = [myDB select:@"distinct(timesheetEntryDate) " from:timeEntriesTable where:whereString  intoDatabase:@""];
    
    
    
    for (int i=0; i<[dueDatesArray count]; i++)
    {
        NSString *whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@'  AND isDeleted=0 order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@'  AND isDeleted=0 AND timesheetFormat='%@' order by time_in asc",[[dueDatesArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,tsFormat];
        }
        NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString1 intoDatabase:@""];
        
        for (int i=0; i<[groupedtsArray count]; i++)
        {
            
            NSString *timeOffURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"timeOffUri"];
            NSString *rowURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"timePunchesUri"];
            
            NSArray *udfInfoArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryType:Time_Entry_Key andRowUri:rowURI timesheetUri:timesheetUri];
            NSMutableArray *tempUdfArray=[NSMutableArray arrayWithArray:udfInfoArray];
            for (int k=0; k<[udfInfoArray count]; k++)
            {
                NSMutableDictionary *udfDictInfo=[udfInfoArray objectAtIndex:k];
                NSString *typeStr=[udfDictInfo objectForKey:@"type"];
                if ([typeStr isEqualToString:DATE_UDF_TYPE])
                {
                    id defaultValue=[udfDictInfo objectForKey:@"defaultValue"];
                    id systemDefaultValue=[udfDictInfo objectForKey:@"systemDefaultValue"];
                    
                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                    {
                        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
                        [temp setDateFormat:@"yyyy-MM-dd"];
                        
                        NSLocale *locale=[NSLocale currentLocale];
                        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                        [temp setTimeZone:timeZone];
                        [temp setLocale:locale];
                       
                        NSString *stDt = [temp stringFromDate:systemDefaultValue];
                        systemDefaultValue =  [temp dateFromString:stDt];
                       
                        
                    }
                    if ([defaultValue isKindOfClass:[NSDate class]])
                    {
                        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
                        [temp setDateFormat:@"yyyy-MM-dd"];
                        
                        NSLocale *locale=[NSLocale currentLocale];
                        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                        [temp setTimeZone:timeZone];
                        [temp setLocale:locale];
                        
                        NSString *stDt = [temp stringFromDate:defaultValue];
                        defaultValue =  [temp dateFromString:stDt];
                       
                        
                    }
                    
                    [udfDictInfo setObject:defaultValue forKey:@"defaultValue"];
                    [udfDictInfo setObject:systemDefaultValue forKey:@"systemDefaultValue"];
                    [tempUdfArray replaceObjectAtIndex:k withObject:udfDictInfo];
                    
                }
            }
            
            if (timeOffURI==nil || [timeOffURI isKindOfClass:[NSNull class]] || [timeOffURI isEqualToString:@""])
            {
                NSString *clientUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"clientUri"];
                NSString *projectURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectUri"];
                NSString *activityURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityUri"];
                NSString *taskUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"taskUri"];
                NSString *billingUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"billingUri"];
                
                NSString *clientName=[[groupedtsArray objectAtIndex:i]objectForKey:@"clientName"];
                NSString *projectName=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectName"];
                NSString *activityName=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityName"];
                NSString *taskName=[[groupedtsArray objectAtIndex:i]objectForKey:@"taskName"];
                NSString *billingName=[[groupedtsArray objectAtIndex:i]objectForKey:@"billingName"];
                NSString *timesheetEntryDate=[NSString stringWithFormat:@"%@",[[groupedtsArray objectAtIndex:i]objectForKey:@"timesheetEntryDate"]];
                //Implentation for US8956//JUHI
                NSString *breakName=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakName"];
                NSString *breakUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"];
                
                TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                BOOL isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
                BOOL isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
                BOOL isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetUri];
               
                
                if (isProjectAccess)
                {
                    //Implentation for US8956//JUHI
                    NSDictionary *entryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             clientName,@"clientName",
                                             clientUri,@"clientUri",
                                             projectName,@"projectName",
                                             projectURI,@"projectUri",
                                             taskName,@"taskName",
                                             taskUri,@"taskUri",
                                             activityName,@"activityName",
                                             activityURI,@"activityUri",
                                             billingName,@"billingName",
                                             billingUri,@"billingUri",
                                             breakName,@"breakName",
                                             breakUri,@"breakUri",
                                             nil];
                    
                    if ([timesheetEntryDate intValue] !=[fetchEntryDate intValue])
                    {
                        if (![uniqueProjectsArray containsObject:entryDict])
                        {
                            [uniqueProjectsArray addObject:entryDict];
                        }
                    }
                    
                    
                }
                else if (isActivityAccess)
                {//Implentation for US8956//JUHI
                    NSDictionary *entryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             clientName,@"clientName",
                                             clientUri,@"clientUri",
                                             projectName,@"projectName",
                                             projectURI,@"projectUri",
                                             taskName,@"taskName",
                                             taskUri,@"taskUri",
                                             activityName,@"activityName",
                                             activityURI,@"activityUri",
                                             billingName,@"billingName",
                                             billingUri,@"billingUri",
                                             breakName,@"breakName",
                                             breakUri,@"breakUri",
                                             nil];
                    
                    if ([timesheetEntryDate intValue] !=[fetchEntryDate intValue])
                    {
                        if (![uniqueProjectsArray containsObject:entryDict])
                        {
                            [uniqueProjectsArray addObject:entryDict];
                        }
                    }
                    
                }//Implentation for US8956//JUHI
                else if (isBreakAccess)
                {
                    
                    NSDictionary *entryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             clientName,@"clientName",
                                             clientUri,@"clientUri",
                                             projectName,@"projectName",
                                             projectURI,@"projectUri",
                                             taskName,@"taskName",
                                             taskUri,@"taskUri",
                                             activityName,@"activityName",
                                             activityURI,@"activityUri",
                                             billingName,@"billingName",
                                             billingUri,@"billingUri",
                                             breakName,@"breakName",
                                             breakUri,@"breakUri",
                                             nil];
                    
                    if ([timesheetEntryDate intValue] !=[fetchEntryDate intValue])
                    {
                        if (![uniqueProjectsArray containsObject:entryDict])
                        {
                            [uniqueProjectsArray addObject:entryDict];
                        }
                    }
                    
                    
                }
            }
            
        }
        
    }
    
    NSString *whereString2=[NSString stringWithFormat: @" timesheetEntryDate = '%d' AND timesheetUri = '%@' AND isDeleted=0  order by time_in asc",[fetchEntryDate intValue],timesheetUri];
    
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString2=[NSString stringWithFormat: @" timesheetEntryDate = '%d' AND timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@'  order by time_in asc",[fetchEntryDate intValue],timesheetUri,tsFormat];
    }
    
    NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString2 intoDatabase:@""];
    for (int i=0; i<[groupedtsArray count]; i++)
    {
        NSString *clientUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"clientUri"];
        NSString *projectURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectUri"];
        NSString *activityURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityUri"];
        NSString *taskUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"taskUri"];
        NSString *billingUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"billingUri"];
        
        NSString *clientName=[[groupedtsArray objectAtIndex:i]objectForKey:@"clientName"];
        NSString *projectName=[[groupedtsArray objectAtIndex:i]objectForKey:@"projectName"];
        NSString *activityName=[[groupedtsArray objectAtIndex:i]objectForKey:@"activityName"];
        NSString *taskName=[[groupedtsArray objectAtIndex:i]objectForKey:@"taskName"];
        NSString *billingName=[[groupedtsArray objectAtIndex:i]objectForKey:@"billingName"];
        NSString *rowURI=[[groupedtsArray objectAtIndex:i]objectForKey:@"timePunchesUri"];
        //Implentation for US8956//JUHI
        NSString *breakName=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakName"];
        NSString *breakUri=[[groupedtsArray objectAtIndex:i]objectForKey:@"breakUri"];
        
        NSArray *udfInfoArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryType:Time_Entry_Key andRowUri:rowURI timesheetUri:timesheetUri];
        NSMutableArray *tempUdfArray=[NSMutableArray arrayWithArray:udfInfoArray];
        for (int k=0; k<[udfInfoArray count]; k++)
        {
            NSMutableDictionary *udfDictInfo=[udfInfoArray objectAtIndex:k];
            NSString *typeStr=[udfDictInfo objectForKey:@"type"];
            if ([typeStr isEqualToString:DATE_UDF_TYPE])
            {
                id defaultValue=[udfDictInfo objectForKey:@"defaultValue"];
                id systemDefaultValue=[udfDictInfo objectForKey:@"systemDefaultValue"];
                
                if ([systemDefaultValue isKindOfClass:[NSDate class]])
                {
                    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
                    [temp setDateFormat:@"yyyy-MM-dd"];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                    [temp setTimeZone:timeZone];
                    [temp setLocale:locale];
                   
                    NSString *stDt = [temp stringFromDate:systemDefaultValue];
                    systemDefaultValue =  [temp dateFromString:stDt];
                   
                    
                }
                if ([defaultValue isKindOfClass:[NSDate class]])
                {
                    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
                    [temp setDateFormat:@"yyyy-MM-dd"];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                    [temp setTimeZone:timeZone];
                    [temp setLocale:locale];
                    
                    NSString *stDt = [temp stringFromDate:defaultValue];
                    defaultValue =  [temp dateFromString:stDt];
                  
                    
                }
                
                [udfDictInfo setObject:defaultValue forKey:@"defaultValue"];
                [udfDictInfo setObject:systemDefaultValue forKey:@"systemDefaultValue"];
                [tempUdfArray replaceObjectAtIndex:k withObject:udfDictInfo];
                
            }
        }
        //Implentation for US8956//JUHI
        NSDictionary *entryDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 clientName,@"clientName",
                                 clientUri,@"clientUri",
                                 projectName,@"projectName",
                                 projectURI,@"projectUri",
                                 taskName,@"taskName",
                                 taskUri,@"taskUri",
                                 activityName,@"activityName",
                                 activityURI,@"activityUri",
                                 billingName,@"billingName",
                                 billingUri,@"billingUri",
                                 breakName,@"breakName",
                                 breakUri,@"breakUri",
                                 nil];
        
        
        if ([uniqueProjectsArray containsObject:entryDict])
        {
            [uniqueProjectsArray removeObject:entryDict];
        }
        
    }
    
    if (uniqueProjectsArray != nil && [uniqueProjectsArray count]>0)
    {
        
        return uniqueProjectsArray;
    }
    return nil;
    
    
}


-(NSMutableArray *) getGroupedStandardTimeEntriesForSheetFromDB: (NSString *)timesheetUri andTimesheetFormat:(NSString *)timesheetFormat
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
   
    
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by entryTypeOrder asc,timesheetEntryDate asc",timesheetUri];
    
   
    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,timesheetEntryDate asc,rowNumber asc",timesheetUri,timesheetFormat];
    }
    
    NSMutableArray *timesheetEntryDateArray = [myDB select:@"distinct(timesheetEntryDate) " from:timeEntriesTable where:whereString  intoDatabase:@""];
    
    
    NSMutableArray *distinctRowsArray = nil;
    
    if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        distinctRowsArray = [myDB select:@"distinct(rowNumber) " from:timeEntriesTable where:whereString  intoDatabase:@""];
    }
    else
    {
        distinctRowsArray = [myDB select:@"distinct(rowUri) " from:timeEntriesTable where:whereString  intoDatabase:@""];
    }
    
    
    
    for (int i=0; i<[timesheetEntryDateArray count]; i++)
    {
        NSMutableArray *groupedTimeEntryArrayForDay=[NSMutableArray array];
         NSString *dateStr=[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ];
        for (int k=0; k<[distinctRowsArray count]; k++)
        {
            NSString *whereString1=nil;
            if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 order by entryTypeOrder asc,rowNumber asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"]];
            }
            else
            {
                whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 order by entryTypeOrder asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
            }
            
            
            if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,rowNumber asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"],timesheetFormat];
                }
                else
                {
                    whereString1=[NSString stringWithFormat: @" timesheetEntryDate = '%@' AND timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc",[[timesheetEntryDateArray objectAtIndex:i] objectForKey:@"timesheetEntryDate" ],timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],timesheetFormat];
                }
                
            }
            
            NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString1 intoDatabase:@""];
                  
            if ([groupedtsArray count]==0)
            {
                NSString *whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
                if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
                {
                    if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                         whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowNumber= '%@' AND isDeleted=0 AND timesheetFormat='%@'",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"],timesheetFormat];
                    }
                    else
                    {
                        whereString2=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@'",timesheetUri,[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"],timesheetFormat];
                    }
                    
                   
                }
                groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString2 intoDatabase:@""];
               
                NSMutableArray *tmpgroupedtsArray=[NSMutableArray array];
                if (groupedtsArray.count>0)
                {
                    NSMutableDictionary *dict=[groupedtsArray objectAtIndex:0];
                    [dict setObject:@"objectEmpty" forKey:@"isObjectEmpty"];
                    [dict setObject:dateStr forKey:@"timesheetEntryDate"];
                    [dict setObject:@"0" forKey:@"durationDecimalFormat"];
                    [dict setObject:@"0:0" forKey:@"durationHourFormat"];
                    [tmpgroupedtsArray addObject:dict];
                    [groupedTimeEntryArrayForDay addObject:tmpgroupedtsArray];
                }

                                
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

-(NSMutableArray *)getAllDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by entryTypeOrder asc,timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by entryTypeOrder asc,timesheetEntryDate asc,rowNumber asc",timesheetUri,tsFormat];
    }
    
    //To not show timeoff with zero values use below where string
    
    //NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND entryType= 'TimeEntry' order by timesheetEntryDate asc",timesheetUri];
    
    NSMutableArray *distinctRowsArray = nil;
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        if ([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            distinctRowsArray = [myDB select:@"distinct(rowNumber) " from:timeEntriesTable where:whereString  intoDatabase:@""];
        }
        else
        {
            distinctRowsArray = [myDB select:@"distinct(rowUri) " from:timeEntriesTable where:whereString  intoDatabase:@""];
        }
    }
    
   
    NSMutableArray *groupedTimesheetsArr=[NSMutableArray array];
    for (int k=0; k<[distinctRowsArray count]; k++)
    {
        NSString *whereString1=@"";;
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            
            if ([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                whereString1=[NSString stringWithFormat: @" rowNumber= '%@' AND isDeleted=0",[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowNumber"]];
            }
            else
            {
                whereString1=[NSString stringWithFormat: @" rowUri= '%@' AND isDeleted=0",[[distinctRowsArray objectAtIndex:k] objectForKey:@"rowUri"]];
            }
        }
        NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString1 intoDatabase:@""];
        
        [groupedTimesheetsArr addObject:groupedtsArray];
        
    }

	if ([groupedTimesheetsArr count]>0)
    {
		return groupedTimesheetsArr;
	}
	return nil;
    
}


-(NSString *)getTimesheetFormatInfoFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(timesheetFormat) " from:timeEntriesTable where:whereString  intoDatabase:@""];
	if ([distinctRowsArray count]>0)
    {
		return [[distinctRowsArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
	}
	return nil;
    
}
-(NSMutableArray *)getAllDistinctProjectUriFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 order by timesheetEntryDate asc",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=0 AND timesheetFormat='%@' order by timesheetEntryDate asc",timesheetUri,tsFormat];
    }
    
    NSMutableArray *groupedProjectUriArr=[NSMutableArray array];
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(rowUri) " from:timeEntriesTable where:whereString  intoDatabase:@""];
	for (int i=0; i<[distinctRowsArray count]; i++)
    {
        NSString *whereString1=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 ",timesheetUri,[[distinctRowsArray objectAtIndex:i] objectForKey:@"rowUri"]];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            whereString1=[NSString stringWithFormat: @" timesheetUri = '%@' AND rowUri= '%@' AND isDeleted=0 AND timesheetFormat='%@' ",timesheetUri,[[distinctRowsArray objectAtIndex:i] objectForKey:@"rowUri"],tsFormat];
        }
        NSMutableArray *projectUriArray = [myDB select:@" projectUri,projectName,taskUri,taskName,billingUri,billingName,activityUri,activityName,rowUri,timeOffUri,timeOffTypeName,correlatedTimeOffUri" from:timeEntriesTable where:whereString1 intoDatabase:@""];
        [groupedProjectUriArr addObject:[projectUriArray objectAtIndex:0]];
    }
    
    
    
    if ([groupedProjectUriArr count]>0)
    {
		return groupedProjectUriArr;
	}
	return nil;
    
}




-(NSMutableArray *) getAllTimesheetApprovalFromDBForTimesheet:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",timesheetApproverHistoryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}
-(NSMutableArray *)getAllTimeEntriesForSheetFromDB: (NSString *)timesheetUri
{

    SQLiteDB *myDB = [SQLiteDB getInstance];
    
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0",timeEntriesTable,timesheetUri];
    
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timesheetUri,tsFormat];
    }
    
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
    
}

-(NSMutableArray *)getAllTimeEntriesForSheetFromDB: (NSString *)timesheetUri forTimeSheetFormat:(NSString *)timesheetFormat
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
   NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timesheetUri,timesheetFormat];
    
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
    
}


-(float )getAllTimeEntriesTotalForSheetFromDB: (NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select sum(durationDecimalFormat) from %@ where timesheetUri='%@' AND isDeleted=0",timeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        sql = [NSString stringWithFormat:@"select sum(durationDecimalFormat) from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timesheetUri,tsFormat];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
        if ([[array objectAtIndex:0] objectForKey:@"sum(durationDecimalFormat)"] !=nil && ![[[array objectAtIndex:0] objectForKey:@"sum(durationDecimalFormat)"]  isKindOfClass:[NSNull class]])
        {
            return [[[array objectAtIndex:0] objectForKey:@"sum(durationDecimalFormat)"] newFloatValue];
        }
		
	}
	return 0;
    
    
}

-(NSString *)getEntriesTimeOffBreaksTotalForEntryDate:(NSString *)entryDate andTimesheetUri:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    
    
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
       NSString *sql = [NSString stringWithFormat:@"select sum(durationDecimalFormat) from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetEntryDate='%@' AND timeSheetFormat='%@'",timeEntriesTable,timesheetUri,entryDate,tsFormat];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
        if ([array count]>0)
        {
            
                return [[array objectAtIndex:0] objectForKey:@"sum(durationDecimalFormat)"];

            
        }
    }
    
    return nil;
    
    
}




-(NSMutableArray *)getAllExtendedTimeEntriesForSheetFromDB: (NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0",timeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timesheetUri,tsFormat];
    }
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    for (int i=0; i<[array count]; i++)
    {
        
        NSMutableDictionary *arrayDict=[NSMutableDictionary dictionaryWithDictionary:[array objectAtIndex:i]];
        NSString *timeOffTypeName=[arrayDict objectForKey:@"timeOffTypeName"];
        if (timeOffTypeName==nil ||[timeOffTypeName isKindOfClass:[NSNull class]] ||[timeOffTypeName isEqualToString:@""])
        {
            NSString *key=@"";
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            BOOL isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetUri];
            BOOL isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetUri];
            
           
            if (isProjectAccess)
            {
                key=[NSString stringWithFormat:@"%@",[arrayDict objectForKey:@"projectUri"]];
                
            }
            else if (isActivityAccess)
            {
                key=[NSString stringWithFormat:@"%@",[arrayDict objectForKey:@"activityUri"]];
                
            }
            
            NSString *inTime=nil;
            NSString *outTime=nil;
            NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
            
            NSString *time_in=[[array objectAtIndex:i] objectForKey:@"time_in"];
            NSString *time_out=[[array objectAtIndex:i] objectForKey:@"time_out"];
            NSString *comments=[[array objectAtIndex:i] objectForKey:@"comments"];
            NSString *punchUri=[[array objectAtIndex:i] objectForKey:@"timePunchesUri"];
            
            
            NSArray *timeInCompsArr=[time_in componentsSeparatedByString:@":"];
            if ([timeInCompsArr count]==3)
            {
                NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                if ([amPmCompsArr count]==2)
                {
                    time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                }
            }
            
            NSArray *timeOutCompsArr=[time_out componentsSeparatedByString:@":"];
            if ([timeOutCompsArr count]==3)
            {
                NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                if ([amPmCompsArr count]==2)
                {
                    time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                }
            }
            
            if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                inTime=[time_in lowercaseString];
            else
                inTime=@"";
            
            if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                outTime=[time_out lowercaseString];
            else
                outTime=@"";
            
            if (comments!=nil && ![comments isKindOfClass:[NSNull class]])
                [formattedTimePunchesDict setObject:comments forKey:@"comments"];
            else
                [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
            
            [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
            [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
            [formattedTimePunchesDict setObject:[NSArray array] forKey:@"udfArray"];
            [formattedTimePunchesDict setObject:punchUri forKey:@"timePunchesUri"];
            
            NSMutableArray *punchesArray=[NSMutableArray array];
            [punchesArray addObject:formattedTimePunchesDict];
            [arrayDict setObject:punchesArray forKey:key];
            [array replaceObjectAtIndex:i withObject:arrayDict];
        }
        

    }
    if ([array count]>0)
    {
		return array;
	}
	return nil;

}
-(NSArray *)getTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' ",timesheetCustomFieldsTable,sheetUri,moduleName,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getTimesheetSheetUdfInfoForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri entryDate:(NSString *)entryDate andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and timesheetEntryDate='%@' and entryUri='%@'",timesheetCustomFieldsTable,sheetUri,moduleName,udfUri,entryDate,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}//Implementation for US9371//JUHI
-(NSArray *)getTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and entryUri='%@'",timesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getTimesheetSheetUdfInfoForSheetUri:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri  andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' and entryUri='%@' ",sheetUri,rowUri];
    NSMutableArray *distinctRowsArray = [myDB select:@"distinct(timesheetEntryDate) " from:timesheetCustomFieldsTable where:whereString  intoDatabase:@""];
    
    if ([distinctRowsArray count]>0)
    {
        id temp=[[distinctRowsArray objectAtIndex:0] objectForKey:@"timesheetEntryDate"];
        NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and entryUri='%@' and timesheetEntryDate='%@'",timesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri,temp];
        NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
        if ([array count]!=0)
        {
            return array;
        }
        return nil;
    }
	
	return nil;
}
//Implemented as per US7859
-(NSDictionary *) getAvailableTimeOffTypeCountInfoForTimesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select availableTimeOffTypeCount from %@ where timesheetUri='%@'",timesheetsDaySummaryTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return [array objectAtIndex:0];
	}
	return nil;
}
 //Implemented For overlappingTimeEntriesPermitted Persmisson
-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName ForTimesheetIdentity:(NSString *)timesheetUri
{
	
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select overlappingTimeEntriesPermitted from %@ where timesheetUri='%@' order by startDate desc",timesheetsTable,timesheetUri];
	NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([permissionArr count]>0)
    {
        id hasPermission =  [[permissionArr objectAtIndex:0] objectForKey:permissionName];
		if(hasPermission!= nil && ![hasPermission isKindOfClass:[NSNull class]])
        {
            if ([hasPermission intValue]==1)
            return YES;
        }
	}
	
    return NO;
    
}

-(BOOL) readIsSplitTimeEntryForMidNightCrossOverPermission:(NSString *)permissionName forTimesheetIdentity:(NSString *)timesheetUri {
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select allowSplitTimeMidnightCrossEntry from %@ where uri='%@'",timeSheetPermittedApprovalActions,timesheetUri];
    NSMutableArray *permissionArr = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([permissionArr count]>0)
    {
        id hasPermission =  [[permissionArr objectAtIndex:0] objectForKey:permissionName];
        if(hasPermission!= nil && hasPermission != (id)[NSNull null])
        {
            if ([hasPermission intValue]==1)
                return YES;
        }
    }
    
    return NO;
}

//Implementation of TimeSheetLastModified
-(void)deleteTimesheetsFromDBForForTimesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    [myDB deleteFromTable:timesheetsTable where:whereString inDatabase:@""];
}

-(NSArray *)getTimesheetSheetUdfInfoForSheetURIForExtendedSuggestion:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and moduleName='%@' and udf_uri='%@' and  entryUri='%@'",timesheetCustomFieldsTable,sheetUri,moduleName,udfUri,rowUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri timesheetUri:(NSString *)timesheetUri
{
    NSMutableArray *customFieldArray=[NSMutableArray array];
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:moduleName];
    
    int decimalPlace=0;
    for (int i=0; i<[udfArray count]; i++)
    {
        NSDictionary *udfDict = [udfArray objectAtIndex: i];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
        [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
        [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];
        
        if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
        {
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldType"];
            [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
            
            if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])){
                decimalPlace=[[udfDict objectForKey:@"numericDecimalPlaces"] intValue];
                [dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
            }
            if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
            }
            if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
            }
            
            if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]])&&![[udfDict objectForKey:@"numericDefaultValue"] isEqualToString:@""])
            {
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"systemDefaultValue"];
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:TEXT_UDF_TYPE])
        {
            [dictInfo setObject:TEXT_UDF_TYPE forKey:@"fieldType"];
            [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
            
            if ([udfDict objectForKey:@"textDefaultValue"]!=nil && ![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]]){
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""]&& (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"])) {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];
                }
            }
            
            if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
                [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DATE_UDF_TYPE])
        {
            [dictInfo setObject: DATE_UDF_TYPE forKey: @"fieldType"];
            [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
            
            if ([udfDict objectForKey:@"dateMaxValue"]!=nil && !([[udfDict objectForKey:@"dateMaxValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMaxValue"] forKey:@"defaultMaxValue"];
            }
            if ([udfDict objectForKey:@"dateMinValue"]!=nil && !([[udfDict objectForKey:@"dateMinValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMinValue"] forKey:@"defaultMinValue"];
            }
            
            if ([udfDict objectForKey:@"isDateDefaultValueToday"]!=nil && !([[udfDict objectForKey:@"isDateDefaultValueToday"] isKindOfClass:[NSNull class]]))
            {
                if ([[udfDict objectForKey:@"isDateDefaultValueToday"]intValue]==1)
                {
                    [dictInfo setObject:[NSDate date] forKey:@"defaultValue"];
                    [dictInfo setObject:[NSDate date] forKey:@"systemDefaultValue"];
                    
                }else
                {
                    if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"systemDefaultValue"];
                        
                    }
                    else
                    {
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                    }
                }
            }
            else {
                if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormat setLocale:locale];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                    
                    NSDate *dateToBeUsed = [Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]];
                    NSString *dateStr = [dateFormat stringFromDate:dateToBeUsed];
                    dateToBeUsed=[dateFormat dateFromString:dateStr];
                    
                    if (dateToBeUsed==nil) {
                        [dateFormat setDateFormat:@"d MMMM yyyy"];
                        dateToBeUsed = [dateFormat dateFromString:dateStr];
                        
                    }
                   
                    
                    NSString *dateDefaultValueFormatted = [Util convertPickerDateToString:dateToBeUsed];
                    
                    if(dateDefaultValueFormatted != nil)
                    {
                        [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];
                        [dictInfo setObject:dateToBeUsed forKey:@"systemDefaultValue"];
                        
                    }
                    else
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"systemDefaultValue"];
                    }
                }
                else
                {
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                }
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [dictInfo setObject:DROPDOWN_UDF_TYPE forKey:@"fieldType"];
            [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
            
            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]])
            {
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""])
                {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"dropDownOptionDefaultURI"] forKey:@"dropDownOptionUri"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];
                    
                }
            }
        }
        NSArray *selectedudfArray=[self getTimesheetSheetUdfInfoForSheetURIForExtendedSuggestion:timesheetUri moduleName:TIMESHEET_CELL_UDF andUdfURI:[udfDict objectForKey:@"uri"] andRowUri:rowUri];
        
        if ([selectedudfArray count]>0)
        {
            NSMutableDictionary *selUDFDataDict=[selectedudfArray objectAtIndex:0];
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (selUDFDataDict!=nil && ![selUDFDataDict isKindOfClass:[NSNull class]]) {
                NSString *udfvaleFormDb=[selUDFDataDict objectForKey: @"udfValue"];
                if (udfvaleFormDb!=nil && ![udfvaleFormDb isKindOfClass:[NSNull class]])
                {
                    if (![udfvaleFormDb isEqualToString:@""]) {
                        if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DATE_UDF_TYPE])
                        {
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                           
                            NSLocale *locale=[NSLocale currentLocale];
                            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [dateFormat setLocale:locale];
                            [dateFormat setDateFormat:@"yyyy-MM-dd"];
                            NSDate *setDate=[dateFormat dateFromString:udfvaleFormDb];
                            if (!setDate) {
                                [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                                setDate=[dateFormat dateFromString:udfvaleFormDb];
                                
                                if (setDate==nil) {
                                    [dateFormat setDateFormat:@"d MMMM yyyy"];
                                    setDate = [dateFormat dateFromString:udfvaleFormDb];
                                    if (setDate==nil)
                                    {
                                        [dateFormat setDateFormat:@"d MMMM, yyyy"];
                                        setDate = [dateFormat dateFromString:udfvaleFormDb];
                                        
                                    }
                                }
                                
                            }
                            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                            udfvaleFormDb=[dateFormat stringFromDate:setDate];
                            NSDate *dateToBeUsed = [dateFormat dateFromString:udfvaleFormDb];
                           
                            [udfDetailDict setObject:dateToBeUsed forKey:@"defaultValue"];
                        }
                        else{
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[Util getRoundedValueFromDecimalPlaces:[udfvaleFormDb newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
                            }
                            else
                                [udfDetailDict setObject:udfvaleFormDb forKey:@"defaultValue"];
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[selUDFDataDict objectForKey: @"dropDownOptionURI" ] forKey:@"dropDownOptionUri"];
                            }
                            
                        }
                        
                    }
                    else
                    {
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
                        
                    }
                    
                }
                else
                {
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
                    
                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];
                if ([dictInfo objectForKey: @"systemDefaultValue"]!=nil && ![[dictInfo objectForKey: @"systemDefaultValue"]isKindOfClass:[NSNull class]]) {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"systemDefaultValue"] forKey:@"systemDefaultValue"];
                }
                else{
                    [udfDetailDict setObject:[NSNull null] forKey:@"systemDefaultValue"];
                }
                
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
                [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
                if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
                }
                if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMinValue" ] forKey:@"defaultMinValue"];
                }
                if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMaxValue" ] forKey:@"defaultMaxValue"];
                }
                
                [customFieldArray addObject:udfDetailDict];
               
            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];
            if ([dictInfo objectForKey: @"systemDefaultValue"]!=nil && ![[dictInfo objectForKey: @"systemDefaultValue"]isKindOfClass:[NSNull class]]) {
                [udfDetailDict setObject:[dictInfo objectForKey: @"systemDefaultValue"] forKey:@"systemDefaultValue"];
            }
            else{
                [udfDetailDict setObject:[NSNull null] forKey:@"systemDefaultValue"];
            }
            
            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
            [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
            if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
            }
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [customFieldArray addObject:udfDetailDict];
           
            
        }
        
    }
    
    return customFieldArray;
}

//Implentation for US8956//JUHI
-(NSMutableArray *)getBreakDetailsFromDBForBreakUri:(NSString *)breakUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where breakUri='%@'",breakTable,breakUri];
	NSMutableArray *array =[myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllBreakDetailsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ ",breakTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}


-(NSMutableArray *)getAllBreakDetailsFromDBWithSearchText:(NSString *)searchText
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = nil;
    if([[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        sql =[NSString stringWithFormat:@"select * from %@ ",breakTable];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select * from %@ where breakName LIKE'%%%@%%'",breakTable,searchText];
    }
    
   
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
}

-(void)deleteAllBreakInfoFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ ",breakTable];
	[myDB executeQuery:query];
}


-(BOOL)getTimeSheetEditStatusForSheetFromDB: (NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select canEditTimesheet from %@ where timesheetUri='%@' order by startDate desc",timesheetsTable,timesheetUri];
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

//Implemented as per TOFF-15//JUHI
-(void)saveTimeoffTypeDetailDataToDB:(NSMutableArray *)array{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    for (int i=0; i<[array count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *detailDict=[array objectAtIndex:i];
        id timeoffTypeName=[detailDict objectForKey:@"displayText"];
        NSString *timeoffTypeNamestr=[NSString stringWithFormat:@"%@",timeoffTypeName];
        NSString *timeoffTypeUri=[detailDict objectForKey:@"uri"];
        NSString *minTimeoffIncrementPolicyUri=[detailDict objectForKey:@"minimumTimeOffIncrementPolicyUri"];
        NSString *timeoffBalanceTrackingOptionUri=[detailDict objectForKey:@"timeOffBalanceTrackingOptionUri"];
        NSString *startEndTimeSpecRequirementUri=[detailDict objectForKey:@"startEndTimeSpecificationRequirementUri"];
        //Implemented as per US8705//JUHI
        int isEnabled  =0;
        
        if (([detailDict objectForKey:@"enabled"]!=nil&&![[detailDict objectForKey:@"enabled"] isKindOfClass:[NSNull class]])&&[[detailDict objectForKey:@"enabled"] boolValue] == YES )
        {
            isEnabled = 1;
        }
        if (timeoffTypeNamestr!=nil)
        {
            [dataDict setObject:timeoffTypeNamestr forKey:@"timeoffTypeName"];
        }
        if (timeoffTypeUri!=nil)
        {
            [dataDict setObject:timeoffTypeUri forKey:@"timeoffTypeUri"];
        }
        if (minTimeoffIncrementPolicyUri!=nil)
        {
            [dataDict setObject:minTimeoffIncrementPolicyUri forKey:@"minTimeoffIncrementPolicyUri"];
        }
        if (timeoffBalanceTrackingOptionUri!=nil)
        {
            [dataDict setObject:timeoffBalanceTrackingOptionUri forKey:@"timeoffBalanceTrackingOptionUri"];
        }
        if (startEndTimeSpecRequirementUri!=nil)
        {
            [dataDict setObject:startEndTimeSpecRequirementUri forKey:@"startEndTimeSpecRequirementUri"];
        }
        //Implemented as per US8705//JUHI
        [dataDict setObject:[NSNumber numberWithInt:isEnabled] forKey:@"enabled"];
        NSString *timeOffDisplayFormatUri = detailDict[@"timeOffDisplayFormatUri"];
        if (timeOffDisplayFormatUri!=nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]]) {
            [dataDict setObject:detailDict[@"timeOffDisplayFormatUri"] forKey:@"timeOffDisplayFormatUri"];
        }
        NSArray *expArr = [self getTimeoffTypeInfoSheetIdentity:timeoffTypeUri];
        if ([expArr count]>0)
        {
			NSString *whereString=[NSString stringWithFormat:@"timeoffTypeUri='%@'",timeoffTypeUri];
			[myDB updateTable: bookedTimeoffTypesTable data:dataDict where:whereString intoDatabase:@""];
		}
        else
        {
			[myDB insertIntoTable:bookedTimeoffTypesTable data:dataDict intoDatabase:@""];
		}
        
        
        
    }
}
-(NSArray *)getTimeoffTypeInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where timeoffTypeUri = '%@' ",bookedTimeoffTypesTable,sheetIdentity];
	NSMutableArray *timeOffsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([timeOffsArr count]!=0)
    {
		return timeOffsArr;
	}
	return nil;
    
}
-(NSMutableArray *)getAllEnabledTimeOffTypesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //Implemented as per US8705//JUHI
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where enabled=1 order by timeoffTypeName asc",bookedTimeoffTypesTable];
	NSMutableArray *timeoffArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([timeoffArray count]>0)
    {
		return timeoffArray;
	}
	return nil;
}

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

-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArray:(NSMutableArray *)array1 andArray:(NSMutableArray *)array2 forTimesheetUri:(NSString *)timesheetUri
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
        [myDB insertIntoTable:udfPreferencesTable data:dataDict intoDatabase:@""];
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
        [myDB insertIntoTable:udfPreferencesTable data:dataDict intoDatabase:@""];
    }

}
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",udfPreferencesTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
}

-(void)saveTimeEntryDataForEmptyTimeValue:(TimesheetEntryObject *)tsEntryObj :(NSString *)timesheetFormat
{
    NSMutableDictionary *dataDict =[self constructDictionaryForEmptyTimeEntry:tsEntryObj andTimesheetformat:timesheetFormat];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[tsEntryObj.timeEntryDate timeIntervalSince1970]];
    NSArray *expArr = [self getTimesheetTimeOffInfoForRowUri:[dataDict objectForKey:@"rowUri"] timesheetUri:[dataDict objectForKey:@"timesheetUri"] andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
    if ([expArr count]>0)
    {
        NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",tsEntryObj.rowUri,entryDateToStore];
        //[myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
        [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
    }
//    else
//    {
//        [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
//    }
    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
}

- (void)updateEmptyTimeEntryValueWithEnteredTime:(TimesheetEntryObject *)tsEntryObj timesheetFormat:(NSString *)timesheetFormat
{
    NSMutableDictionary *dataDict =[self constructDictionaryForEmptyTimeEntry:tsEntryObj andTimesheetformat:timesheetFormat];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[tsEntryObj.timeEntryDate timeIntervalSince1970]];
    //NSArray *expArr = [self getTimesheetTimeOffInfoForRowUri:tsEntryObj.rowUri timesheetUri:tsEntryObj.timesheetUri andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
    NSArray *expArr = [self getTimesheetTimeOffInfoForRowUri:[dataDict objectForKey:@"rowUri"] timesheetUri:[dataDict objectForKey:@"timesheetUri"] andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
    if ([expArr count]>0)
    {
        NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",tsEntryObj.rowUri,entryDateToStore];
        [myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
    
    }
}

-(void)deleteEmptyTimeEntryValue:(TimesheetEntryObject *)tsEntryObj withTimesheetFormat:(NSString *)timesheetFormat
{
    //NSMutableDictionary *dataDict =[self constructDictionaryForEmptyTimeEntry:tsEntryObj andTimesheetformat:timesheetFormat];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[tsEntryObj.timeEntryDate timeIntervalSince1970]];
    NSArray *expArr = [self getTimesheetTimeOffInfoForRowUri:tsEntryObj.rowUri timesheetUri:tsEntryObj.timesheetUri andEntryDate:entryDateToStore forTimesheetFormat:timesheetFormat];
    if ([expArr count]>0)
    {
        NSString *whereString=[NSString stringWithFormat:@"rowUri = '%@' and timesheetEntryDate='%@'",tsEntryObj.rowUri,entryDateToStore];
        //[myDB updateTable: timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
        [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
    }
}


-(NSMutableDictionary *)constructDictionaryForEmptyTimeEntry:(TimesheetEntryObject *)timesheetObj andTimesheetformat:(NSString *)timesheetFormat
{
    NSString *entryType=@"";
    NSString *billingName=@"";
    NSString *billingUri=@"";
    NSString *comments=@"";
    NSString *durationDecimalFormat=@"";
    NSString *projectName=@"";
    NSString *projectUri=@"";
    NSString *rowNumber=@"";
    NSString *rowUri=@"";
    NSString *timePunchesUri=@"";
    NSString *timesheetUri=@"";
    if(timesheetObj.timeEntryBillingName!=nil && timesheetObj.timeEntryBillingName!=(id)[NSNull null])
    {
        billingName = timesheetObj.timeEntryBillingName;
    }
    if(timesheetObj.timeEntryBillingUri!=nil && timesheetObj.timeEntryBillingUri!=(id)[NSNull null])
    {
        billingUri =timesheetObj.timeEntryBillingUri;
    }
    if(timesheetObj.timeEntryComments!=nil && timesheetObj.timeEntryComments!=(id)[NSNull null])
    {
        comments =timesheetObj.timeEntryComments;
    }
    if(timesheetObj.timeEntryHoursInDecimalFormat!=nil && timesheetObj.timeEntryHoursInDecimalFormat!=(id)[NSNull null])
    {
        durationDecimalFormat =timesheetObj.timeEntryHoursInDecimalFormat;
    }
    if(timesheetObj.entryType!=nil && timesheetObj.entryType!=(id)[NSNull null])
    {
        entryType = timesheetObj.entryType;
    }
    BOOL hasTimeEntryValue =timesheetObj.hasTimeEntryValue;
    if(timesheetObj.timeEntryProjectName!=nil && timesheetObj.timeEntryProjectName!=(id)[NSNull null])
    {
        projectName =timesheetObj.timeEntryProjectName;
    }
    if(timesheetObj.timeEntryProjectUri!=nil && timesheetObj.timeEntryProjectUri!=(id)[NSNull null])
    {
        projectUri = timesheetObj.timeEntryProjectUri;
    }
    if(timesheetObj.rownumber!=nil && timesheetObj.rownumber!=(id)[NSNull null])
    {
        rowNumber =timesheetObj.rownumber;
    }
    if(timesheetObj.rowUri!=nil && timesheetObj.rowUri!=(id)[NSNull null])
    {
        rowUri =timesheetObj.rowUri;
    }
    if(timesheetObj.timePunchUri!=nil && timesheetObj.timePunchUri!=(id)[NSNull null])
    {
        timePunchesUri =timesheetObj.timePunchUri;
    }
    if(timesheetObj.timesheetUri!=nil && timesheetObj.timesheetUri!=(id)[NSNull null])
    {
        timesheetUri =timesheetObj.timesheetUri;
    }
    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[timesheetObj.timeEntryDate timeIntervalSince1970]];
    
    NSMutableDictionary *timeEntryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        timesheetObj.timeEntryBillingName,@"billingName",
                                        timesheetObj.timeEntryBillingUri,@"billingUri",
                                        timesheetObj.timeEntryComments,@"comments",
                                        timesheetObj.timeEntryHoursInDecimalFormat,@"durationDecimalFormat",
                                        entryType,@"entryType",
                                        [NSNumber numberWithBool:timesheetObj.hasTimeEntryValue],@"hasTimeEntryValue",
                                        timesheetObj.timeEntryProjectName,@"projectName",
                                        timesheetObj.timeEntryProjectUri,@"projectUri",
                                        timesheetObj.timeEntryClientName,@"clientName",
                                        timesheetObj.timeEntryClientUri,@"clientUri",
                                        timesheetObj.timeEntryTaskName,@"taskName",
                                        timesheetObj.timeEntryTaskUri,@"taskUri",
                                        timesheetObj.timeEntryActivityName,@"activityName",
                                        timesheetObj.timeEntryActivityUri,@"activityUri",
                                        timesheetObj.rownumber,@"rowNumber",
                                        timesheetObj.rowUri,@"rowUri",
                                        timesheetObj.timePunchUri,@"timePunchesUri",
                                        @"",@"time_in",
                                        @"",@"time_out",
                                        Time_Entry_Key,@"entryType",
                                        [NSNumber numberWithInt:Time_Off_Key_Value],@"entryTypeOrder",
                                        entryDateToStore,@"timesheetEntryDate",
                                        timesheetFormat,@"timesheetFormat",
                                        timesheetObj.timesheetUri,@"timesheetUri",
                                        [NSNumber numberWithBool:hasTimeEntryValue],@"hasTimeEntryValue",nil];
    return timeEntryDict;
}



-(void)saveTimeEntryDataForGen4TimesheetIntoDB:(id)response
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSMutableDictionary *timeEntryDict=[[dataDict objectForKey:@"query"] objectForKey:@"timeEntry"];
    NSString *receivedPunchID=[[[response objectForKey:@"response"] objectForKey:@"d"] objectForKey:@"uri"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    NSString *recievedClientPunchID=[dataDict objectForKey:@"clientID"];
    NSString *comments=[timeEntryDict objectForKey:@"comments"];
    if (comments==nil||[comments isKindOfClass:[NSNull class]])
    {
        comments=@"";
    }
    NSDictionary *entryDateDict=[timeEntryDict objectForKey:@"entryDate"];
    NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
    
    NSString *uri=[[timeEntryDict objectForKey:@"target"] objectForKey:@"uri"];
    if (uri==nil||[uri isKindOfClass:[NSNull class]])
    {
        //empty entry save
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        [dataDict setObject:receivedPunchID forKey:@"rowUri"];
        [dataDict setObject:comments forKey:@"comments"];
        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
        [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
        [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
         [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
        [dataDict setObject:receivedPunchID forKey:@"timePunchesUri"];
        [dataDict setObject:@"0.00" forKey:@"durationDecimalFormat"];
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        [dataDict setObject:@"" forKey:@"time_in"];
        [dataDict setObject:@"" forKey:@"time_out"];
        [dataDict setObject:recievedClientPunchID forKey:@"clientPunchId"];
        [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
    }
    else
    {
        //entry with time save
        NSString *inString=@"";
        NSDictionary *startTimeDict=[[timeEntryDict objectForKey:@"timePair"] objectForKey:@"startTime"];
        if (startTimeDict!=nil&&![startTimeDict isKindOfClass:[NSNull class]])
        {
            inString=[Util convertApiTimeDictTo12HourTimeString:startTimeDict];
        }
        NSString *outString=@"";
        NSDictionary *endTimeDict=[[timeEntryDict objectForKey:@"timePair"] objectForKey:@"endTime"];
        if (endTimeDict!=nil&&![endTimeDict isKindOfClass:[NSNull class]])
        {
            outString=[Util convertApiTimeDictTo12HourTimeString:endTimeDict];
        }
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        [dataDict setObject:inString forKey:@"time_in"];
        [dataDict setObject:outString forKey:@"time_out"];
        [dataDict setObject:comments forKey:@"comments"];
        NSString *decimalHoursTmp=@"0.00";
        if ( inString!=nil && ![inString isKindOfClass:[NSNull class]] && ![inString isEqualToString:@""] &&
            outString!=nil && ![outString isKindOfClass:[NSNull class]] && ![outString isEqualToString:@""])
        {
            decimalHoursTmp=[Util getNumberOfHoursForInTime:inString outTime:outString];
            [dataDict setObject:decimalHoursTmp forKey:@"durationDecimalFormat"];
        }
        NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' and clientPunchId='%@'",timesheetUri,recievedClientPunchID];
        [dataDict setObject:receivedPunchID forKey:@"timePunchesUri"];
        [myDB updateTable:timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
        
        NSArray *array=[self getAllTimeEntriesForSheetFromDB:timesheetUri];
        float totalHoursTimeSheet=0;
        float totalHoursForDay=0;
        for (int h=0; h<[array count]; h++)
        {
            NSString *breakUri=[[array objectAtIndex:h] objectForKey:@"breakUri"];
             NSString *timeOffUri=[[array objectAtIndex:h] objectForKey:@"timeOffUri"];
            BOOL isNotBreak=NO;
            if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""]) {
                isNotBreak=YES;
            }
            BOOL isNotTimeoff=NO;
            if (timeOffUri==nil||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:@""]) {
                isNotTimeoff=YES;
            }
            
            if (isNotTimeoff && isNotBreak)
            {
                float entryHours=[[[array objectAtIndex:h] objectForKey:@"durationDecimalFormat"] newFloatValue];
                totalHoursTimeSheet=totalHoursTimeSheet+entryHours;
                if ([[[array objectAtIndex:h] objectForKey:@"timesheetEntryDate"] newFloatValue]==[entryDate timeIntervalSince1970])
                {
                    totalHoursForDay=totalHoursForDay+entryHours;
                }
            }
            
        }
        
        NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
        [timesheetDataDict setObject:[NSNumber numberWithFloat:totalHoursForDay] forKey:@"timesheetEntryTotalDurationDecimal"];
        NSString *whereStringTsDayTable=[NSString stringWithFormat:@"timesheetUri='%@' and timesheetEntryDate='%@'",timesheetUri,entryDateToStore];
        [myDB updateTable: timesheetsDaySummaryTable data:timesheetDataDict where:whereStringTsDayTable intoDatabase:@""];
        
        
        
        NSString *whereStringTsTable=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
        NSMutableDictionary *timesheetDataTSDict=[NSMutableDictionary dictionary];
        [timesheetDataTSDict setObject:[NSNumber numberWithFloat:totalHoursTimeSheet] forKey:@"totalDurationDecimal"];
        [myDB updateTable: timesheetsTable data:timesheetDataTSDict where:whereStringTsTable intoDatabase:@""];
        
        
    
    }
    NSDictionary *dict=[self getSumOfDurationHoursForTimesheetUri:timesheetUri];
    NSString *totalInOutBreakHours=[dict objectForKey:@"breakHours"];
    NSString *totalInOutWorkHours=[dict objectForKey:@"regularHours"];
    NSString *totalInOutTimeOffHours=[dict objectForKey:@"timeoffHours"];
    NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    [updateDict setObject:totalInOutBreakHours forKey:@"totalInOutBreakHours"];
    [updateDict setObject:totalInOutWorkHours forKey:@"totalInOutWorkHours"];
    [updateDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    [self updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict];

}

-(void)saveBreakEntryDataForGen4TimesheetIntoDB:(id)response
{
    NSMutableDictionary *dataDict=[[response objectForKey:@"refDict"] objectForKey:@"params"];
    NSMutableDictionary *timeEntryDict=[[dataDict objectForKey:@"query"] objectForKey:@"timeEntry"];
    NSString *receivedPunchID=[[[response objectForKey:@"response"] objectForKey:@"d"] objectForKey:@"uri"];
    NSString *timesheetUri=[dataDict objectForKey:@"timesheetUri"];
    NSString *recievedClientPunchID=[dataDict objectForKey:@"clientID"];
    NSString *comments=[timeEntryDict objectForKey:@"comments"];
    if (comments==nil||[comments isKindOfClass:[NSNull class]])
    {
        comments=@"";
    }
    NSDictionary *entryDateDict=[timeEntryDict objectForKey:@"entryDate"];
    NSDate *entryDate=[Util convertApiDateDictToDateFormat:entryDateDict];
    NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
    NSString *uri=[[timeEntryDict objectForKey:@"target"] objectForKey:@"uri"];
    if (uri==nil||[uri isKindOfClass:[NSNull class]])
    {
        //empty entry save
        NSString *breakName=[dataDict objectForKey:@"breakName"];
        NSString *breakUri=[dataDict objectForKey:@"breakUri"];
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        [dataDict setObject:receivedPunchID forKey:@"rowUri"];
        [dataDict setObject:comments forKey:@"comments"];
        [dataDict setObject:entryDateToStore forKey:@"timesheetEntryDate"];
        [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
        [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
        [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
        [dataDict setObject:receivedPunchID forKey:@"timePunchesUri"];
        [dataDict setObject:@"0.00" forKey:@"durationDecimalFormat"];
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        [dataDict setObject:@"" forKey:@"time_in"];
        [dataDict setObject:@"" forKey:@"time_out"];
        [dataDict setObject:breakName forKey:@"breakName"];
        [dataDict setObject:breakUri forKey:@"breakUri"];
        [dataDict setObject:recievedClientPunchID forKey:@"clientPunchId"];
        [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
    }
    else
    {
        //entry with time save
        NSString *inString=@"";
        NSDictionary *startTimeDict=[[timeEntryDict objectForKey:@"timePair"] objectForKey:@"startTime"];
        if (startTimeDict!=nil&&![startTimeDict isKindOfClass:[NSNull class]])
        {
            inString=[Util convertApiTimeDictTo12HourTimeString:startTimeDict];
        }
        NSString *outString=@"";
        NSDictionary *endTimeDict=[[timeEntryDict objectForKey:@"timePair"] objectForKey:@"endTime"];
        if (endTimeDict!=nil&&![endTimeDict isKindOfClass:[NSNull class]])
        {
            outString=[Util convertApiTimeDictTo12HourTimeString:endTimeDict];
        }
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        [dataDict setObject:inString forKey:@"time_in"];
        [dataDict setObject:outString forKey:@"time_out"];
        NSString *decimalHours=@"0.00";
        if (inString!=nil&&![inString isKindOfClass:[NSNull class]]&&![inString isEqualToString:@""]&&outString!=nil&&![outString isKindOfClass:[NSNull class]]&&![outString isEqualToString:@""])
        {
            decimalHours=[Util getNumberOfHoursForInTime:inString outTime:outString];
            
        }
        [dataDict setObject:decimalHours forKey:@"durationDecimalFormat"];
        
        NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' and clientPunchId='%@'",timesheetUri,recievedClientPunchID];
        [dataDict setObject:receivedPunchID forKey:@"timePunchesUri"];
        [myDB updateTable:timeEntriesTable data:dataDict where:whereString intoDatabase:@""];
        
    }
    NSDictionary *dict=[self getSumOfDurationHoursForTimesheetUri:timesheetUri];
    NSString *totalInOutBreakHours=[dict objectForKey:@"breakHours"];
    NSString *totalInOutWorkHours=[dict objectForKey:@"regularHours"];
    NSString *totalInOutTimeOffHours=[dict objectForKey:@"timeoffHours"];
    NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    [updateDict setObject:totalInOutBreakHours forKey:@"totalInOutBreakHours"];
    [updateDict setObject:totalInOutWorkHours forKey:@"totalInOutWorkHours"];
    [updateDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    [self updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict];
}

-(void)deleteTimeEntriesFromDBForForTimesheetIdentity:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    [myDB deleteFromTable:timesheetsDaySummaryTable where:whereString inDatabase:@""];
    [myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
}

-(void)deleteInfoFromDBForEntryUri:(NSString *)entryUri withTimesheetUri:(NSString *)timesheetUri andEntryDate:(NSString *)entryDate isWorkEntry:(BOOL)isWorkEntry
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' and timePunchesUri='%@' AND isDeleted=0",timesheetUri,entryUri];
    float newEntryTotal=[self getTimeEntryTotalForEntryWithWhereString:whereString];
    whereString=[NSString stringWithFormat:@"timesheetUri='%@' and timePunchesUri='%@'",timesheetUri,entryUri];
	[myDB deleteFromTable:timeEntriesTable where:whereString inDatabase:@""];
    
    if (isWorkEntry)
    {
        NSMutableArray *allEntries=[self getAllTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timesheetEntryDate==%f)", [entryDate newFloatValue]];
        NSArray *arr= [allEntries filteredArrayUsingPredicate:pred];
        if ([arr count]>0)
        {
            NSArray *entries=[self getTimeSheetInfoSheetIdentity:timesheetUri];
            float prevTotal=[[[arr objectAtIndex:0] objectForKey:@"timesheetEntryTotalDurationDecimal"] newFloatValue];
            float prevTotalTS=[[[entries objectAtIndex:0] objectForKey:@"totalDurationDecimal"] newFloatValue];
            
            NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];
            [timesheetDataDict setObject:[NSNumber numberWithFloat:prevTotal-newEntryTotal] forKey:@"timesheetEntryTotalDurationDecimal"];
            NSString *whereStringTsDayTable=[NSString stringWithFormat:@"timesheetUri='%@' and timesheetEntryDate='%@'",timesheetUri,entryDate];
            [myDB updateTable: timesheetsDaySummaryTable data:timesheetDataDict where:whereStringTsDayTable intoDatabase:@""];
            
            NSString *whereStringTsTable=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
            NSMutableDictionary *timesheetDataTSDict=[NSMutableDictionary dictionary];
            [timesheetDataTSDict setObject:[NSNumber numberWithFloat:prevTotalTS-newEntryTotal] forKey:@"totalDurationDecimal"];
            [myDB updateTable: timesheetsTable data:timesheetDataTSDict where:whereStringTsTable intoDatabase:@""];
            
        }
    }
    

}

-(float)getTimeEntryTotalForEntryWithWhereString:(NSString *)whereString
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *groupedtsArray = [myDB select:@" * " from:timeEntriesTable where:whereString intoDatabase:@""];

    float totalHours = 0.0;

    for (NSDictionary *groupedtsDict in groupedtsArray)
    {
        totalHours = totalHours + [groupedtsDict[@"durationDecimalFormat"] newFloatValue];
    }


    return totalHours;
}

-(void)updateApprovalStatusForTimesheetIdentity:(NSString *)timesheetUri withStatus:(NSString *)status
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:status forKey:@"approvalStatus"];
    [myDB updateTable:timesheetsTable data:dataDict where:whereString intoDatabase:@""];
}


-(NSMutableArray *)sortArrayAccordingToInTimeInsidePunchesArray:(NSMutableArray *)arrayToBeSorted
{
    for (int b=0; b<[arrayToBeSorted count]; b++) {
        NSMutableDictionary *changDict=[NSMutableDictionary dictionaryWithDictionary:[arrayToBeSorted objectAtIndex:b]];
        NSString *stringDate=[changDict objectForKey:@"in_time"];
        NSDateFormatter *dateFormatter=[NSDateFormatter new];
       NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"hh:mm a"];
        
        if (stringDate!=nil && ![stringDate isKindOfClass:[NSNull class]]&&![stringDate isEqualToString:@""])
        {
            NSDate *date=[dateFormatter dateFromString:stringDate];
            [changDict setObject:date forKey:@"in_time"];
        }
        else
        {
            [changDict setObject:[NSNull null] forKey:@"in_time"];
        }
        [arrayToBeSorted replaceObjectAtIndex:b withObject:changDict];
        
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"in_time" ascending:TRUE];
    [arrayToBeSorted sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    for (int b=0; b<[arrayToBeSorted count]; b++) {
        NSMutableDictionary *changDict=[NSMutableDictionary dictionaryWithDictionary:[arrayToBeSorted objectAtIndex:b]];
        NSDate *stringDate=[changDict objectForKey:@"in_time"];
        NSDateFormatter *dateFormatter=[NSDateFormatter new];
       NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"hh:mm a"];
        if (stringDate!=nil && ![stringDate isKindOfClass:[NSNull class]])
        {
            NSString *date=[dateFormatter stringFromDate:stringDate];
            [changDict setObject:date forKey:@"in_time"];
        }
        else
        {
            [changDict setObject:@"" forKey:@"in_time"];
        }
        [arrayToBeSorted replaceObjectAtIndex:b withObject:changDict];
        
    }

    return arrayToBeSorted;
}

-(BOOL)getTimeSheetForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate
{
    
    NSDictionary *startDateDict=[Util convertDateToApiDateDictionaryOnLocalTimeZone:startDate];
   
    NSDate *sDate=[Util convertApiDateDictToDateFormat:startDateDict];

    
    
    
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by startDate desc",timesheetsTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    
    if ([array count]>0)
    {
        NSDictionary *timeshetDict=[array objectAtIndex:0];
        
        NSDate *dbStartDate=[Util convertTimestampFromDBToDate:[timeshetDict objectForKey:@"startDate"] ];
        NSDate *dbEndDate=[Util convertTimestampFromDBToDate:[timeshetDict objectForKey:@"endDate"] ];
        
        BOOL isContain=TRUE;
        
        if ([sDate compare:dbStartDate] == NSOrderedAscending)
        {
            isContain=FALSE;
        }
        
        
        if ([sDate compare:dbEndDate] == NSOrderedDescending)
        {
            isContain=FALSE;
        }
        
        
        return isContain;
        
    }
    
    
	return FALSE;
    
    
}


-(void)deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    //    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' AND isModified=0 AND isDeleted=0",timesheetUri];
    //    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
    //
    //    whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' AND time_in='' AND time_out=''",timesheetUri];
    //    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
    //
    //    [myDB updateTable:timeEntriesTable data:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:0],@"isModified",[NSNumber numberWithBool:0],@"isDeleted", nil] where:@"" intoDatabase:@""];
    NSString * whereStr=@"";
    whereStr=[NSString stringWithFormat:@"timesheetUri= '%@'",timesheetUri];

    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
    [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:whereStr inDatabase:@""];
}

-(void)deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:(NSString *)timesheetUri andWidgetEntries:(NSMutableArray *)widgetTimeEntriesArr
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
//    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' AND isModified=0 AND isDeleted=0",timesheetUri];
//    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
//    
//    whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' AND time_in='' AND time_out=''",timesheetUri];
//    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
//    
//    [myDB updateTable:timeEntriesTable data:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:0],@"isModified",[NSNumber numberWithBool:0],@"isDeleted", nil] where:@"" intoDatabase:@""];

    if(widgetTimeEntriesArr != nil && ![widgetTimeEntriesArr isKindOfClass:[NSNull class]])
    {
        for (int j=0; j<[widgetTimeEntriesArr count]; j++) {
            NSMutableDictionary *newDict=[widgetTimeEntriesArr objectAtIndex:j];
            NSString *entryUri=newDict[@"uri"];
            NSString * whereStr=@"";
            whereStr =[NSString stringWithFormat:@"timesheetUri= '%@' and timePunchesUri='%@'",timesheetUri,entryUri];

            [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
            
            whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' and timeEntryUri='%@'",timesheetUri,entryUri];
            [myDB deleteFromTable:timeEntriesObjectExtensionFieldsTable where:whereStr inDatabase:@""];
        }
    }


}

-(void)deleteAllTimesheetSummaryDataFromDBForGen4withTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:timeEntriesTable where:whereStr inDatabase:@""];
}


-(void)updatecanEditTimesheetStatusForTimesheetWithUri:(NSString *)timesheetUri withStatus:(int)allowTimeEntryEditForGen4
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET canEditTimesheet = '%@' WHERE timesheetUri='%@'",timesheetsTable,[NSNumber numberWithInt:allowTimeEntryEditForGen4],timesheetUri];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        //NSLog(@"vvv");
    }
}
-(void)updateTimesheetFormatForTimesheetWithUri:(NSString *)timesheetUri
{
    NSString *format=@"";

    NSArray *timesheetInfoArray=[self getTimeSheetInfoSheetIdentity:timesheetUri];
    if ([timesheetInfoArray count]>0)
    {
        format=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];

    }

    if (format==nil || [format isKindOfClass:[NSNull class]])
    {
        NSMutableArray *enableWidgetsArr=[self getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timesheetUri];
        for (NSDictionary *enableWidgetDict in enableWidgetsArr)
        {
            NSString *widgetUri = enableWidgetDict[@"widgetUri"];
            if ([widgetUri isEqualToString:INOUT_WIDGET_URI])
            {
                format=GEN4_INOUT_TIMESHEET;
                break;

            }
        }

    }

    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET timesheetFormat = '%@' WHERE timesheetUri='%@'",timesheetsTable,format,timesheetUri];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        //NSLog(@"vvv");
    }
}
-(void)updateEditedValueForGen4BreakWithEntryUri:(NSString *)entryUri sheetUri:(NSString *)timesheetUri withBreakName:(NSString *)breakName withBreakUri:(NSString *)breakUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sqlUri = [NSString stringWithFormat:@"UPDATE %@ SET breakUri = '%@' WHERE timesheetUri='%@' and timePunchesUri='%@'",timeEntriesTable,breakUri,timesheetUri,entryUri];
    NSString *sqlName = [NSString stringWithFormat:@"UPDATE %@ SET breakName = '%@' WHERE timesheetUri='%@' and timePunchesUri='%@'",timeEntriesTable,breakName,timesheetUri,entryUri];
    
    BOOL isSuccess=[myDB sqliteExecute:sqlUri];
    if (isSuccess) {
       isSuccess=[myDB sqliteExecute:sqlName];
    }

}

-(NSMutableDictionary *)getSumOfDurationHoursForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSString *disntinctsql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0",timeEntriesTable,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        disntinctsql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' AND isDeleted=0 AND timesheetFormat='%@'",timeEntriesTable,timesheetUri,tsFormat];
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



-(NSMutableArray *)getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and supportedInMobile=1 and enabled=1 order by orderNo asc",enabledWidgetsTable,timesheetUri];
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

-(NSMutableArray *)getNotSupportedWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' and supportedInMobile=0 order by orderNo asc",enabledWidgetsTable,timesheetUri];
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


-(NSMutableArray *)getAllSupportedAndNotSupportedWidgetsForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@' order by orderNo asc",enabledWidgetsTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return array;
    }
    return nil;
    
}

-(void)saveWidgetTimesheetDisclaimerDataToDB:(NSMutableDictionary *)disclaimerDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disclaimerDescription=[disclaimerDict objectForKey:@"description"];
    NSString *disclaimerTitle=[disclaimerDict objectForKey:@"title"];
    NSString *timesheetUri=[disclaimerDict objectForKey:@"timesheetUri"];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:widgetDisclaimerTable where:whereStr inDatabase:@""];
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if (disclaimerDescription!=nil && ![disclaimerDescription isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:disclaimerDescription forKey:@"description"];
    }
    if (disclaimerTitle!=nil && ![disclaimerTitle isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:disclaimerTitle forKey:@"title"];
    }
    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    }
    
    
    [myDB insertIntoTable:widgetDisclaimerTable data:dataDict intoDatabase:@""];
}

-(void)saveWidgetTimesheetAttestationDataToDB:(NSMutableDictionary *)attestationDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *attestationDescription=[attestationDict objectForKey:@"description"];
    NSString *attestationTitle=[attestationDict objectForKey:@"title"];
    NSString *timesheetUri=[attestationDict objectForKey:@"timesheetUri"];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:widgetAttestationTable where:whereStr inDatabase:@""];
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    if (attestationDescription!=nil && ![attestationDescription isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:attestationDescription forKey:@"description"];
    }
    if (attestationTitle!=nil && ![attestationTitle isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:attestationTitle forKey:@"title"];
    }
    
    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    }
    
    
    [myDB insertIntoTable:widgetAttestationTable data:dataDict intoDatabase:@""];
}

-(void)saveWidgetTimesheetPayrollSummaryDataToDB:(NSDictionary *)response displayAmount:(BOOL)displayAmount andTimesheetURI:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"timesheetUri= '%@' ",timesheetUri];
    [myDB deleteFromTable:widgetPayrollSummaryTable where:whereStr inDatabase:@""];
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

        NSArray *actualsByPaycode = widgetTimesheetSummary[@"actualsByPaycode"] ;

        NSDate *date = [NSDate date];
        NSDate *utcDate=[Util getUTCFormatDate:date];
        NSString *utcDateString = [Util getUTCStringFromDate:utcDate];
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
            [paycodeDBInsertData setObject:utcDateString forKey:@"savedOnDate"];
            [myDB insertIntoTable:widgetPayrollSummaryTable data:paycodeDBInsertData intoDatabase:@""];
        }
        
        if (actualsByPaycode != nil && ![actualsByPaycode isKindOfClass:[NSNull class]]) {

            float totalpayhours = 0.0;
            
            for (NSDictionary *paycodeDictionary in actualsByPaycode) {
                NSMutableDictionary *paycodeDBInsertData = [[NSMutableDictionary alloc]init];
                NSDictionary *paycodeDuration = paycodeDictionary[@"totalTimeDuration"];
                NSDictionary *payCode = paycodeDictionary[@"payCode"];

                if (totalPaycodeAmount!=nil && ![totalPaycodeAmount isKindOfClass:[NSNull class]])
                {
                    [paycodeDBInsertData setObject:totalPaycodeAmount forKey:@"totalpayamount"];
                }

                if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
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
                [paycodeDBInsertData setObject:[NSNumber numberWithBool:displayAmount] forKey:@"displayPayAmount"];
                [paycodeDBInsertData setObject:utcDateString forKey:@"savedOnDate"];
                [myDB insertIntoTable:widgetPayrollSummaryTable data:paycodeDBInsertData intoDatabase:@""];
            }

            [myDB updateTable:widgetPayrollSummaryTable data:@{@"totalpayhours":[Util getRoundedValueFromDecimalPlaces:[@(totalpayhours) newDoubleValue] withDecimalPlaces:2]} where:[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri] intoDatabase:@""];
        }

    }

}

-(void)saveTimesheetDataToDB:(NSMutableDictionary *)timesheetDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB insertIntoTable:timesheetsTable data:timesheetDict intoDatabase:@""];
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

-(NSArray *)getAllPaycodesforTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",widgetPayrollSummaryTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    return array;
    
}


-(void)updateAttestationStatusForTimesheetIdentity:(NSString *)timesheetUri withStatus:(BOOL)isSelected
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:[NSNumber numberWithBool:isSelected] forKey:@"attestationStatus"];
    [myDB updateTable:widgetAttestationTable data:dataDict where:whereString intoDatabase:@""];
}


-(NSMutableDictionary *)getDisclaimerDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",widgetDisclaimerTable,timesheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return [array objectAtIndex:0];
	}
	return nil;
    
}

-(NSMutableDictionary *)getAttestationDetailsFromDBForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",widgetAttestationTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return [array objectAtIndex:0];
    }
    return nil;
    
}

-(WidgetType)getWidgetTypeForPolicy:(NSString *)policyKeyUri
{
    if ([policyKeyUri isEqualToString:NOTICE_WIDGET_URI]){
        return NoticeWidgetType;
    }
    else if ([policyKeyUri isEqualToString:ATTESTATION_WIDGET_URI]){
        return AttestationWidgetType;
    }
    else if ([policyKeyUri isEqualToString:PAYSUMMARY_WIDGET_URI]){
        return PaysummaryWidgetType;
    }
    else if ([policyKeyUri isEqualToString:DAILY_FIELDS_WIDGET_URI]){
        return DailyFieldsWidgetType;
    }
    return DefaultWidgetType;
}

-(void)saveEnabledWidgetsDetailsIntoDB:(NSDictionary *)response andTimesheetUri:(NSString *)timesheetUri
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
                if ([[WidgetsManager sharedInstance] isValueAvailableWithKey:policyKeyUri])
                {
                    if (policyValueDict!=nil && ![policyValueDict isKindOfClass:[NSNull class]])
                    {
                        BOOL isWidgetEnabled=[[policyValueDict objectForKey:@"bool"] boolValue];
                        if (isWidgetEnabled)
                        {
                            NSMutableDictionary *widgetDictitonary = [self getSupportedWidgetsMap:policyValueDict policyUri:policyKeyUri timesheetUri:timesheetUri response:response];
                            [enabledWidgetsUriArrays addObject:widgetDictitonary];
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
    [myDB deleteFromTable:enabledWidgetsTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
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
        if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
        }
        
        if (dict[@"widgetTitle"]!=nil && ![dict[@"widgetTitle"] isKindOfClass:[NSNull class]])
        {
            [dataDict setObject:dict[@"widgetTitle"] forKey:@"widgetTitle"];
        }

        [myDB insertIntoTable:enabledWidgetsTable data:dataDict intoDatabase:@""];
    }

}

-(NSMutableDictionary *)contructDataDictionary:(NSDictionary *)dataDictionary policyKey:(NSString *)policyKeyUri timesheetUri:(NSString *)timesheetUri
{
    NSMutableDictionary *dataValueDictionary=[NSMutableDictionary dictionary];
    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataValueDictionary setObject:timesheetUri forKey:@"timesheetUri"];
    }
    NSMutableArray *collectionArray=[dataDictionary objectForKey:@"collection"];
    if(collectionArray.count == 0){
        return nil;
    }
        for (int b=0; b<[collectionArray count]; b++)
        {
            NSString *uri=[[collectionArray objectAtIndex:b] objectForKey:@"uri"];
            NSString *text=[[collectionArray objectAtIndex:b] objectForKey:@"text"];
            if([policyKeyUri isEqualToString:NOTICE_WIDGET_URI]){
                if ([uri isEqualToString:NOTICE_WIDGET_DESCRIPTION_URI])
                {
                    [dataValueDictionary setObject:text forKey:@"description"];
                }
                else if ([uri isEqualToString:NOTICE_WIDGET_TITLE_URI])
                {
                    [dataValueDictionary setObject:text forKey:@"title"];
                }
            }
            
            else if([policyKeyUri isEqualToString:ATTESTATION_WIDGET_URI]){
                if ([uri isEqualToString:ATTESTATION_WIDGET_DESCRIPTION_URI])
                {
                    [dataValueDictionary setObject:text forKey:@"description"];
                }
                else if ([uri isEqualToString:ATTESTATION_WIDGET_TITLE_URI])
                {
                    [dataValueDictionary setObject:text forKey:@"title"];
                }
            }
        }
        
        return dataValueDictionary;
}

-(NSMutableDictionary *)getSupportedWidgetsMap:(NSDictionary *)policyDictionary policyUri:(NSString *)policyKeyUri timesheetUri:(NSString *)timesheetUri response:(NSDictionary *)response {
    
        int orderNo=[[policyDictionary objectForKey:@"number"] intValue];
        NSNumber *orderNumber=[NSNumber numberWithInt:orderNo];
        NSString *widgetUri=policyKeyUri;
        NSNumber *supportedInMobile=[NSNumber numberWithBool:YES];
        int enabled=1;
        NSString *widgetTitle=nil;
        WidgetType widgetType = [self getWidgetTypeForPolicy:policyKeyUri];
        switch (widgetType) {
            case NoticeWidgetType:{
                NSMutableDictionary *dataDisclaimerDict = [self contructDataDictionary:policyDictionary policyKey:policyKeyUri timesheetUri:timesheetUri];
                if(dataDisclaimerDict!=nil && dataDisclaimerDict!=(id)[NSNull null]){
                    enabled=1;
                    [self saveWidgetTimesheetDisclaimerDataToDB:dataDisclaimerDict];
                }
                else{
                    enabled=0;
                }
                break;
            }
            case AttestationWidgetType:{
                NSMutableDictionary *dataAttestationDict = [self contructDataDictionary:policyDictionary policyKey:policyKeyUri timesheetUri:timesheetUri];
                if(dataAttestationDict!=nil && dataAttestationDict!=(id)[NSNull null]){
                    enabled=1;
                    [self saveWidgetTimesheetAttestationDataToDB:dataAttestationDict];
                }
                else{
                    enabled=0;
                }
                break;
            }
            case PaysummaryWidgetType:{
                NSMutableArray *collectionArray=[policyDictionary objectForKey:@"collection"];
                BOOL displayAmountInPaysummary = NO;
                for (int b=0; b<[collectionArray count]; b++)
                {
                    NSString *uri = collectionArray[b][@"uri"];
                    if ([uri isEqualToString:DISPLAY_AMOUNT_IN_PAYSUMMARY_WIDGET_URI]) {
                        displayAmountInPaysummary = YES;
                    }
                }
                [self saveWidgetTimesheetPayrollSummaryDataToDB:response displayAmount:displayAmountInPaysummary andTimesheetURI:timesheetUri];
                enabled=1;
                
                break;
            }
            case DailyFieldsWidgetType:{
                NSMutableArray *collectionArray=[policyDictionary objectForKey:@"collection"];
                for (int b=0; b<[collectionArray count]; b++)
                {
                    NSString *uri = collectionArray[b][@"uri"];
                    if ([uri isEqualToString:DAILY_FIELDS_WIDGET_TITLE_URI]) {
                        widgetTitle = collectionArray[b][@"text"];
                    }
                }
                enabled=1;
                break;
            }
            default:
                break;
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
    return dict;
}

- (void)saveWidgetTimesheetSummaryOfHoursIntoDB:(NSMutableDictionary *)summaryDict andTimesheetUri:(NSString *)timesheetUri isFromSave:(BOOL)isFromSave
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
    [myDB deleteFromTable:widgetTimesheetSummaryTable where:[NSString stringWithFormat:@"timesheetUri = '%@'",timesheetUri] inDatabase:@""];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:totalInOutBreakHoursStr forKey:@"totalInOutBreakHours"];
    [dataDict setObject:totalInOutWorkHoursStr forKey:@"totalInOutWorkHours"];
    [dataDict setObject:totalTimePunchBreakHoursStr forKey:@"totalTimePunchBreakHours"];
    [dataDict setObject:totalTimePunchWorkHoursStr forKey:@"totalTimePunchWorkHours"];
    [dataDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    [dataDict setObject:totalInOutTimeOffHours forKey:@"totalTimePunchTimeOffHours"];
    [dataDict setObject:totalStandardWorkHoursStr forKey:@"totalStandardWorkHours"];
    [dataDict setObject:totalStandardTimeOffHours forKey:@"totalStandardTimeOffHours"];
    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    }
    
    [myDB insertIntoTable:widgetTimesheetSummaryTable data:dataDict intoDatabase:@""];

    if (isFromSave)
    {
        NSNumber *totalInOutWorkHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalInOutWorkHours];
        NSNumber *totalTimePunchWorkHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimePunchWorkHours];
        NSNumber *totalStandardWorkHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalStandardWorkHours];
        NSNumber *totalTimeOffHoursInDecimalFormat=[Util convertApiTimeDictToDecimal:totalTimeOffHours];
        NSString *totalTimeOffHoursInHourFormat=[Util convertApiTimeDictToString:totalTimeOffHours];
        NSNumber *maxNumber = [NSNumber numberWithDouble:MAX(MAX([totalInOutWorkHoursInDecimalFormat doubleValue],[totalTimePunchWorkHoursInDecimalFormat doubleValue]), [totalStandardWorkHoursInDecimalFormat doubleValue])];

        NSMutableDictionary *timesheetDataDict=[NSMutableDictionary dictionary];

        NSString *totalHoursInDecimalFormat=[NSString stringWithFormat:@"%f",[maxNumber newFloatValue]+[totalTimeOffHoursInDecimalFormat newFloatValue]];
        NSString *hoursValue=@"";
        NSString *minsValue=@"";
        NSArray *componentsArr=[totalHoursInDecimalFormat componentsSeparatedByString:@"."];
        if ([componentsArr count]==2)
        {
            hoursValue = [componentsArr objectAtIndex:0];
            minsValue =[componentsArr objectAtIndex:1];
        }
        NSString *totalHoursStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];


        [timesheetDataDict setObject:totalHoursInDecimalFormat      forKey:@"totalDurationDecimal"];
        [timesheetDataDict setObject:totalHoursStr   forKey:@"totalDurationHour"];
        [timesheetDataDict setObject:maxNumber      forKey:@"regularDurationDecimal"];
        hoursValue=@"";
        minsValue=@"";
        componentsArr=[[NSString stringWithFormat:@"%@",maxNumber] componentsSeparatedByString:@"."];
        if ([componentsArr count]==2)
        {
            hoursValue = [componentsArr objectAtIndex:0];
            minsValue =[componentsArr objectAtIndex:1];
        }
        NSString *workingTimeHoursStr=[NSString stringWithFormat:@"%d:%d",[hoursValue intValue],[minsValue intValue]];
        [timesheetDataDict setObject:workingTimeHoursStr   forKey:@"regularDurationHour"];

        [timesheetDataDict setObject:totalTimeOffHoursInDecimalFormat   forKey:@"timeoffDurationDecimal"];
        [timesheetDataDict setObject:totalTimeOffHoursInHourFormat   forKey:@"timeoffDurationHour"];

        NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
        [myDB updateTable: timesheetsTable data:timesheetDataDict where:whereString intoDatabase:@""];
    }

}

-(NSMutableDictionary *)getWidgetSummaryForTimesheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where timesheetUri='%@'",widgetTimesheetSummaryTable,timesheetUri];
    NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([array count]>0)
    {
        return [array objectAtIndex:0];
    }
    return nil;
}

-(void)updateSummaryDataForTimesheetUri:(NSString *)timesheetUri withDataDict:(NSMutableDictionary *)timesheetDataTSDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStringTsTable=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    [myDB updateTable: widgetTimesheetSummaryTable data:timesheetDataTSDict where:whereStringTsTable intoDatabase:@""];
}

-(void)updateTimesheetDataForTimesheetUri:(NSString *)timesheetUri withDataDict:(NSMutableDictionary *)timesheetDataTSDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStringTsTable=[NSString stringWithFormat:@"timesheetUri='%@'",timesheetUri];
    [myDB updateTable: timesheetsTable data:timesheetDataTSDict where:whereStringTsTable intoDatabase:@""];
}

-(void)updateTimesheetWithOperationName:(NSString *)operationName andTimesheetURI:(NSString *)timesheetURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {
         NSString *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];
        NSMutableArray *operationArr=nil;
        
        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
        {
            operationArr=[NSMutableArray array];
        }
        else
        {
            operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
        }
        
        if ([operationName isEqualToString:TIMESHEET_SAVE_OPERATION])
        {
            if ([operationArr containsObject:TIMESHEET_SAVE_INFLIGHT] )
            {
                // reverting inflight-save to save (mostly in case of failures)
                NSInteger index=[operationArr indexOfObject:TIMESHEET_SAVE_INFLIGHT];
                [operationArr replaceObjectAtIndex:index withObject:TIMESHEET_SAVE_OPERATION];
                NSString *operationDBText=@"";
                for (NSString * operationStr in operationArr)
                {
                    operationDBText = [NSString stringWithFormat:@"%@|%@",operationDBText,operationStr];
                }
                [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"'%@' where timesheetUri='%@'",operationDBText,timesheetURI] inDatabase:@""];
            }
            else if (![operationArr containsObject:operationName] )
            {
                 NSDictionary *timeSheetDict=[timesheetsArr objectAtIndex:0];
                NSString *approvalStatus=[timeSheetDict objectForKey:@"approvalStatus"];
                if([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS] || [approvalStatus isEqualToString:REJECTED_STATUS] )
                {
                   
                    [operationArr addObject:operationName];
                    NSString *operationDBText=@"";
                    for (NSString * operationStr in operationArr)
                    {
                        operationDBText = [NSString stringWithFormat:@"%@|%@",operationDBText,operationStr];
                    }
                    [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"'%@' where timesheetUri='%@'",operationDBText,timesheetURI] inDatabase:@""];
                }
                
               
            }
        }
        else if ([operationName isEqualToString:TIMESHEET_SAVE_INFLIGHT])
        {
            if ([operationArr containsObject:TIMESHEET_SAVE_OPERATION] )
            {
                 NSInteger index=[operationArr indexOfObject:TIMESHEET_SAVE_OPERATION];
                [operationArr replaceObjectAtIndex:index withObject:TIMESHEET_SAVE_INFLIGHT];
                NSString *operationDBText=@"";
                for (NSString * operationStr in operationArr)
                {
                    operationDBText = [NSString stringWithFormat:@"%@|%@",operationDBText,operationStr];
                }
                [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"'%@' where timesheetUri='%@'",operationDBText,timesheetURI] inDatabase:@""];
            }
        }
        else if ([operationName isEqualToString:TIMESHEET_SUBMIT_OPERATION] || [operationName isEqualToString:TIMESHEET_RESUBMIT_OPERATION])
        {
            if (![operationArr containsObject:operationName] )
            {
                [operationArr addObject:operationName];
                NSString *operationDBText=@"";
                for (NSString * operationStr in operationArr)
                {
                    operationDBText = [NSString stringWithFormat:@"%@|%@",operationDBText,operationStr];
                }
                [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"'%@' where timesheetUri='%@'",operationDBText,timesheetURI] inDatabase:@""];
            }
        }
        
        else if ([operationName isEqualToString:TIMESHEET_REOPEN_OPERATION])
        {
            if (![operationArr containsObject:operationName] )
            {
                if ([operationArr containsObject:TIMESHEET_SUBMIT_OPERATION] )
                {
                    [operationArr removeObject:TIMESHEET_SUBMIT_OPERATION];
                }
                else if ([operationArr containsObject:TIMESHEET_SAVE_OPERATION] )
                {
                    NSInteger index=[operationArr indexOfObject:TIMESHEET_SAVE_OPERATION];
                    [operationArr replaceObjectAtIndex:index withObject:TIMESHEET_REOPEN_OPERATION];
                    [operationArr insertObject:TIMESHEET_SAVE_OPERATION atIndex:index+1];
                }
                
                else
                {
                     [operationArr addObject:operationName];
                }
                NSString *operationDBText=@"";
                for (NSString * operationStr in operationArr)
                {
                    operationDBText = [NSString stringWithFormat:@"%@|%@",operationDBText,operationStr];
                }
                [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"'%@' where timesheetUri='%@'",operationDBText,timesheetURI] inDatabase:@""];
            }
        }

        
        
    }
    
    
}


-(void)deleteOperationName:(NSString *)operationName andTimesheetURI:(NSString *)timesheetURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {
        NSString *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];
        NSMutableArray *operationArr=nil;
        
        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
        {
            operationArr=[NSMutableArray array];
        }
        else
        {
            operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
        }
        
        
        if ([operationArr containsObject:operationName] )
        {
            [operationArr removeObject:operationName];
            if ([operationArr count]==0)
            {
                [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"null where timesheetUri='%@'",timesheetURI] inDatabase:@""];

            }
            else
            {
                id operationDBText=@"";
                for (NSString * operationStr in operationArr)
                {
                    if(![[operationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && ![[operationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:NULL_STRING])
                    {
                        operationDBText = [NSString stringWithFormat:@"%@|%@",operationDBText,operationStr];
                    }

                }
                if([[operationDBText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
                {
                    operationDBText = [NSNull null];
                }
                [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"'%@' where timesheetUri='%@'",operationDBText,timesheetURI] inDatabase:@""];
            }

        }
        
    }
    
    
}

-(void)rollbackLastOperationNameforTimesheetURI:(NSString *)timesheetURI forCurrentOperationName:(NSString *)operationName
{
    
    
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {
        NSData *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];
        NSMutableArray *operationArr=nil;
        
        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
        {
            operationArr=[NSMutableArray array];
        }
        else
        {
            operationArr= [NSKeyedUnarchiver unarchiveObjectWithData:operationData];
        }
        
        
        if ([operationArr count]>0)
        {
            NSString *lastOperationName=[operationArr lastObject];
            
            if ([lastOperationName isEqualToString:TIMESHEET_SUBMIT_OPERATION])
            {
                [self deleteOperationName:lastOperationName andTimesheetURI:timesheetURI];
                
                
                NSMutableArray *arrayFromDB=[self getAllTimesheetApprovalFromDBForTimesheet:timesheetURI];
                
                if ([arrayFromDB count]>0 && arrayFromDB!=nil)
                {
                    TimesheetApprovalHistoryObject *timesheetApprovalHistoryObject=[arrayFromDB lastObject];
                    
                    NSString *status=timesheetApprovalHistoryObject.approvalActionStatusUri;
                    NSString *statusStr=nil;
                    if ([status isEqualToString:Submit_Action_URI])
                    {
                        statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
                        
                    }
                    else if ([status isEqualToString:Reject_Action_URI])
                    {
                        statusStr=RPLocalizedString(REJECTED_STATUS, @"");
                        
                    }
                    else if ([status isEqualToString:Approved_Action_URI]||[status isEqualToString:SystemApproved_Action_URI])
                    {
                        statusStr=RPLocalizedString(APPROVED_STATUS, @"");
                        
                    }
                    else if ([status isEqualToString:Reopen_Action_URI])
                    {
                        statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
                        
                    }
                    else
                    {
                        statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
                        
                    }
                    
                    SQLiteDB *myDB = [SQLiteDB getInstance];
                    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                    
                    [dataDict setObject:statusStr forKey:@"approvalStatus" ];
                    
                    [myDB updateTable:@"Timesheets" data:dataDict where:[NSString stringWithFormat:@"timesheetUri='%@'",timesheetURI] intoDatabase:@""];
                    
                }
                
                
                
            }
            
        }
        
    }
    
    
    
}

-(void)deleteAllOperationNamesForTimesheetURI:(NSString *)timesheetURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {
        
        [myDB updateColumnFromTable:@"operations" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"null where timesheetUri='%@'",timesheetURI] inDatabase:@""];
    }
}

-(void)refreshAllInFlightSaveOperationsforAllTimesheets
{
    NSArray *timesheetUris = [self getAllTimesheetsUrisFromDB];
    for (NSDictionary *timesheetDict in timesheetUris)
    {
        NSString *timesheetUri = timesheetDict[@"timesheetUri"];
        if ([self isTimesheetContainsInflightSaveOperation:timesheetUri])
        {
            // if save fails revert the inflight mode to save operation
            [self updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timesheetUri];
        }
    }
}

-(BOOL)isTimesheetContainsInflightSaveOperation:(NSString *)timesheetUri
{

    NSArray *timesheetsArr=[self getTimeSheetInfoSheetIdentity:timesheetUri];
    if (timesheetsArr.count>0)
    {

        NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetUri];
        NSMutableArray *operationArr=nil;
        if ([timesheetsArr count]>0)
        {
            NSString *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];


            if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
            {
                operationArr=[NSMutableArray array];
            }
            else
            {
                operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
            }


        }

        if (operationArr!=nil && ![operationArr isKindOfClass:[NSNull class]])
        {
            if ([operationArr count]==1)
            {
                if ([operationArr[0] isEqualToString:NULL_STRING])
                {
                    operationArr = nil;
                }
            }
        }

        if (operationArr.count!=0)
        {
            if([operationArr containsObject:TIMESHEET_SAVE_INFLIGHT])
            {
                return YES;
            }


        }


    }

    return NO;

}

-(void)deleteLastKnownApprovalStatusForTimesheetURI:(NSString *)timesheetURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {

        [myDB updateColumnFromTable:@"lastKnownApprovalStatus" fromTable:@"timesheets" withString:[NSString stringWithFormat:@"null where timesheetUri='%@'",timesheetURI] inDatabase:@""];
    }
}



-(void)updateTimeEntryTableForTimesheetUri:(NSString *)timesheetUri andClientID:(NSString *)clientID withDataDict:(NSDictionary *)dataDict andStartDate:(NSDate *)startDate andIsBreak:(BOOL)isBreak andbreakName:(NSString *)breakName andbreakUri:(NSString *)breakUri andEntryURIColumnName:(NSString *)entryURIColumnName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString=nil;
    

   whereString=[NSString stringWithFormat:@"%@ = '%@' AND timesheetUri='%@'",entryURIColumnName,clientID,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString=[NSString stringWithFormat:@"%@ = '%@' AND timesheetUri='%@' AND timesheetFormat='%@'",entryURIColumnName,clientID,timesheetUri,tsFormat];
    }
    NSString *query=[NSString stringWithFormat:@" select * from %@ where %@",timeEntriesTable,whereString];
    NSMutableArray *updatedata = [myDB executeQueryToConvertUnicodeValues:query];
    if ([updatedata count]>0) {
        NSMutableDictionary *updateDictionary=[NSMutableDictionary dictionaryWithDictionary:[updatedata objectAtIndex:0]];
        for (NSString *key in [dataDict allKeys]) {
            id value=[dataDict objectForKey:key];
            if (value!=nil && ![value isKindOfClass:[NSNull class]]) {
                [updateDictionary setObject:value forKey:key];
            }
        }
        BOOL isUpdateSuccess=[myDB updateTable: timeEntriesTable data:updateDictionary where:whereString intoDatabase:@""];
        if (!isUpdateSuccess) {
            NSLog(@"Update Not Successfull");
        }
    }
    else
    {
        
        if (startDate!=nil)
        {
            if (isBreak)
            {
                [self insertBlankBreakEntryObjectForGen4:clientID andEntryDate:startDate andTimeSheetURI:timesheetUri andBreakName:breakName andBreakUri:breakUri];
            }
            else
            {
                [self insertBlankTimeEntryObjectForGen4:clientID andEntryDate:startDate andTimeSheetURI:timesheetUri];
            }
            
            NSMutableArray *updatedata = [myDB executeQueryToConvertUnicodeValues:query];
            if ([updatedata count]>0) {
                NSMutableDictionary *updateDictionary=[NSMutableDictionary dictionaryWithDictionary:[updatedata objectAtIndex:0]];
                for (NSString *key in [dataDict allKeys]) {
                    id value=[dataDict objectForKey:key];
                    if (value!=nil && ![value isKindOfClass:[NSNull class]]) {
                        [updateDictionary setObject:value forKey:key];
                    }
                }
                BOOL isUpdateSuccess=[myDB updateTable: timeEntriesTable data:updateDictionary where:whereString intoDatabase:@""];
                if (!isUpdateSuccess) {
                    NSLog(@"Update Not Successfull");
                }
            }

        }
        
    }
    
}

-(void)updateTimeEntryTableForTimesheetUri:(NSString *)timesheetUri andTimeEntryUri:(NSString *)timeEntryUri withDataDict:(NSDictionary *)dataDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString=nil;
   whereString=[NSString stringWithFormat:@"timePunchUri = '%@' AND timesheetUri='%@'",timeEntryUri,timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
         whereString=[NSString stringWithFormat:@"timePunchUri = '%@' AND timesheetUri='%@' AND timesheetFormat='%@'",timeEntryUri,timesheetUri,tsFormat];
    }
    NSString *query=[NSString stringWithFormat:@" select * from %@ where %@",timeEntriesTable,whereString];
    NSMutableArray *updatedata = [myDB executeQueryToConvertUnicodeValues:query];
    if ([updatedata count]>0) {
        NSMutableDictionary *updateDictionary=[NSMutableDictionary dictionaryWithDictionary:[updatedata objectAtIndex:0]];
        for (NSString *key in [dataDict allKeys]) {
            id value=[dataDict objectForKey:key];
            if (value!=nil && ![value isKindOfClass:[NSNull class]]) {
                [updateDictionary setObject:value forKey:key];
            }
        }
        BOOL isUpdateSuccess=[myDB updateTable: timeEntriesTable data:updateDictionary where:whereString intoDatabase:@""];
        if (!isUpdateSuccess) {
            NSLog(@"Update Not Successfull");
        }
    }
    
}

-(void)insertBlankTimeEntryObjectForGen4:(NSString *)clientPunchId andEntryDate:(NSDate *)timeEntryDate andTimeSheetURI:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
//    [dataDict setObject:receivedPunchID forKey:@"rowUri"];
    [dataDict setObject:@"" forKey:@"comments"];
    [dataDict setObject:[NSNumber numberWithDouble:[timeEntryDate timeIntervalSince1970]] forKey:@"timesheetEntryDate"];
    [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
    [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
     [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
//    [dataDict setObject:receivedPunchID forKey:@"timePunchesUri"];
    [dataDict setObject:@"0.00" forKey:@"durationDecimalFormat"];
    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    [dataDict setObject:@"" forKey:@"time_in"];
    [dataDict setObject:@"" forKey:@"time_out"];
//    [dataDict setObject:breakName forKey:@"breakName"];
//    [dataDict setObject:breakUri forKey:@"breakUri"];
    [dataDict setObject:clientPunchId forKey:@"clientPunchId"];
    [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
    
    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
}

-(void)insertBlankBreakEntryObjectForGen4:(NSString *)clientPunchId andEntryDate:(NSDate *)timeEntryDate andTimeSheetURI:(NSString *)timesheetUri andBreakName:(NSString *)breakName andBreakUri:(NSString *)breakUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    //    [dataDict setObject:receivedPunchID forKey:@"rowUri"];
    [dataDict setObject:@"" forKey:@"comments"];
    [dataDict setObject:[NSNumber numberWithDouble:[timeEntryDate timeIntervalSince1970]] forKey:@"timesheetEntryDate"];
    [dataDict setObject:Time_Entry_Key forKey:@"entryType"];
    [dataDict setObject:[NSNumber numberWithInt:Time_Entry_Key_Value] forKey:@"entryTypeOrder"];
    [dataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
    //    [dataDict setObject:receivedPunchID forKey:@"timePunchesUri"];
    [dataDict setObject:@"0.00" forKey:@"durationDecimalFormat"];
    [dataDict setObject:timesheetUri forKey:@"timesheetUri"];
    [dataDict setObject:@"" forKey:@"time_in"];
    [dataDict setObject:@"" forKey:@"time_out"];
    [dataDict setObject:breakName forKey:@"breakName"];
    [dataDict setObject:breakUri forKey:@"breakUri"];
    [dataDict setObject:clientPunchId forKey:@"clientPunchId"];
    [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
    [dataDict setObject:[NSNumber numberWithInt:0] forKey:@"isDeleted"];
    
    [myDB insertIntoTable:timeEntriesTable data:dataDict intoDatabase:@""];
}

-(void)updateTotalTimeOnWidgetSummaryTableForTimeSheetUri:(NSString *)timesheetUri
{
    NSDictionary *dict=[self getSumOfDurationHoursForTimesheetUri:timesheetUri];
    NSString *totalInOutBreakHours=[dict objectForKey:@"breakHours"];
    NSString *totalInOutWorkHours=[dict objectForKey:@"regularHours"];
    NSString *totalInOutTimeOffHours=[dict objectForKey:@"timeoffHours"];
    NSMutableDictionary *updateDict=[NSMutableDictionary dictionary];
    [updateDict setObject:totalInOutBreakHours forKey:@"totalInOutBreakHours"];
    [updateDict setObject:totalInOutWorkHours forKey:@"totalInOutWorkHours"];
    [updateDict setObject:totalInOutTimeOffHours forKey:@"totalInOutTimeOffHours"];
    [self updateSummaryDataForTimesheetUri:timesheetUri withDataDict:updateDict];
    
    NSDictionary *widgetTimesheetSummaryDict=[self getWidgetSummaryForTimesheetUri:timesheetUri];

    float totalInOutWorkHoursFloatValue=[widgetTimesheetSummaryDict[@"totalInOutWorkHours"] floatValue];
    float totalTimePunchWorkHoursFloatValue=[widgetTimesheetSummaryDict[@"totalTimePunchWorkHours"] floatValue];
    float totalStandardWorkHoursFloatValue=[widgetTimesheetSummaryDict[@"totalStandardWorkHours"] floatValue];
    float totalTimeOffHoursFloatValue=[totalInOutTimeOffHours floatValue];
    float totalInOutBreakHoursFloatValue=[totalInOutBreakHours floatValue];
    float totalTimePunchBreakHoursFloatValue=[widgetTimesheetSummaryDict[@"totalTimePunchBreakHours"] floatValue];


    float maxNumber = MAX(MAX((totalInOutWorkHoursFloatValue + totalInOutBreakHoursFloatValue) , (totalTimePunchWorkHoursFloatValue + totalTimePunchBreakHoursFloatValue)), totalStandardWorkHoursFloatValue) ;

    NSString *totalTimesheetWorkHours=[NSString stringWithFormat:@"%.2f",totalInOutWorkHoursFloatValue];
    NSString *totalTimesheetHours=[NSString stringWithFormat:@"%.2f",maxNumber+totalTimeOffHoursFloatValue];


    NSMutableDictionary *timesheetUpdateDict=[NSMutableDictionary dictionary];
    [timesheetUpdateDict setObject:totalTimesheetHours forKey:@"totalDurationDecimal"];
    [timesheetUpdateDict setObject:totalTimesheetWorkHours forKey:@"regularDurationDecimal"];
    
    NSMutableDictionary *regularDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:totalTimesheetWorkHours];
    [timesheetUpdateDict setObject:[NSString stringWithFormat:@"%@:%@",[regularDurationtimeDict objectForKey:@"hours"],[regularDurationtimeDict objectForKey:@"minutes"]] forKey:@"regularDurationHour"];
    
    NSMutableDictionary *totalDurationtimeDict=[Util convertDecimalHoursToApiTimeDict:totalTimesheetHours];
    [timesheetUpdateDict setObject:[NSString stringWithFormat:@"%@:%@",[totalDurationtimeDict objectForKey:@"hours"],[totalDurationtimeDict objectForKey:@"minutes"]] forKey:@"totalDurationHour"];
    
    [self updateTimesheetDataForTimesheetUri:timesheetUri withDataDict:timesheetUpdateDict];
    
}

-(NSString *)getTimesheetApprovalStatusForTimesheetIdentity:(NSString *)timesheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select approvalStatus from %@ where timesheetUri='%@'",timesheetsTable,timesheetUri];
    NSMutableArray *tsArr = [myDB executeQueryToConvertUnicodeValues:sql];
    if ([tsArr count]>0)
    {
        NSDictionary *tsDict=[tsArr objectAtIndex:0];
        return [tsDict objectForKey:@"approvalStatus"];
    }
    
    return nil;
    
}

-(NSMutableArray *)getDeletedTimeEntriesForTimeSheetUri:(NSString *)timesheetUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=1",timesheetUri];
    NSString *tsFormat=[self getTimesheetFormatforTimesheetUri:timesheetUri];
    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
    {
        whereString = [NSString stringWithFormat:@"timesheetUri = '%@' AND isDeleted=1 AND timesheetFormat='%@'",timesheetUri,tsFormat];
    }

    NSMutableArray *deletedTSArr=[myDB select:@"*" from:timeEntriesTable where:whereString intoDatabase:@""];
   
    if ([deletedTSArr count]>0)
    {
        return deletedTSArr;
    }
    return nil;
}

-(NSString *)getTimesheetFormatforTimesheetUri:(NSString *)timesheetUri
{
    NSString *tsFormat=nil;
    
    NSArray *timesheetInfoArray=[self getTimeSheetInfoSheetIdentity:timesheetUri];
    if ([timesheetInfoArray count]>0)
    {
       tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
       
    }
    
    return tsFormat;
}

-(NSDictionary *)getMaxandMinRowNumberFromTimeEntries:(NSMutableArray *)timesheetDataArray andTimesheetFormat:(NSString *)tsFormat
{
    
    int maxValue=0;
    int minValue=0;
    
    if ([timesheetDataArray count]>0)
    {
        NSArray *timesheetRowArr=[timesheetDataArray objectAtIndex:0];
        
        for (TimesheetEntryObject *timesheetEntryObject in timesheetRowArr)
        {
            NSString *rowNumber=timesheetEntryObject.rownumber;
            if ([rowNumber intValue]+1>0)// to check if its a numeric value
            {
                int rowNumberValue=[rowNumber intValue];
                if (rowNumberValue>maxValue)
                {
                    maxValue=rowNumberValue;
                }
                if (minValue>rowNumberValue)
                {
                    minValue=rowNumberValue;
                }
            }
        }
    }
    

    
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:maxValue],@"maxValue",[NSNumber numberWithInt:minValue],@"minValue", nil];
    
}

-(BOOL)getTimesheetCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@'",timesheetCapabilitiesTable,sheetUri];
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

-(void)updateTimeentriesFormatForTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSString *)withFormat fromFormat:(NSString *)fromFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET timesheetFormat = '%@' WHERE timesheetUri='%@' AND timesheetFormat = '%@'",timeEntriesTable,withFormat,timesheetUri,fromFormat];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        //NSLog(@"vvv");
    }
}


-(NSMutableArray *)getTimesheetObjectExtensionFieldsForTimeSheetUri:(NSString*)timesheetUri andtimesheetFormat:(NSString *)timesheetFormat andOEFLevel:(NSString *)oefLevel
{

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and timesheetFormat='%@' and oef_level='%@' ",timesheetObjectExtensionFieldsTable,timesheetUri,timesheetFormat,oefLevel];
    NSMutableArray *oefArr = [myDB executeQueryToConvertUnicodeValues:query];
    if([oefArr count]>0)
    {
        return oefArr;
    }

    return nil;

}

-(NSArray *)getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:(NSString*)timesheetUri andtimesheetEntryUri:(NSString *)timeEntryUri
{

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and timeEntryUri='%@'",timeEntriesObjectExtensionFieldsTable,timesheetUri,timeEntryUri];
    NSMutableArray *oefArr = [myDB executeQueryToConvertUnicodeValues:query];
    if([oefArr count]>0)
    {
        return oefArr;
    }

    return nil;
    
}

-(BOOL)checkIfTimeEntriesModifiedOrDeleted:(NSString *)timesheetUri timesheetFormat:(NSString *)timesheetFormat
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *query = [NSString stringWithFormat:@" select * from %@ where timesheetUri = '%@' and timesheetFormat='%@'",timeEntriesTable,timesheetUri,timesheetFormat];
    NSMutableArray *timeEntriesArr = [myDB executeQueryToConvertUnicodeValues:query];
    if([timeEntriesArr count]>0)
    {
        for (NSDictionary *timeEntryDict in timeEntriesArr)
        {
            BOOL isModified = [timeEntryDict[@"isModified"]boolValue];
            BOOL isDeleted = [timeEntryDict[@"isDeleted"]boolValue];
            if (isModified || isDeleted)
            {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)updateTimeEntriesModifiedOrDeleted:(NSString *)timesheetUri timesheetFormat:(NSString *)timesheetFormat
{

    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE timesheetUri='%@' AND timesheetFormat = '%@' AND isDeleted = 1",timeEntriesTable,timesheetUri,timesheetFormat];
    BOOL isSuccess=[myDB sqliteExecute:sql];
    if (isSuccess) {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET isModified = 0 , isDeleted = 0 WHERE timesheetUri='%@' AND timesheetFormat = '%@'",timeEntriesTable,timesheetUri,timesheetFormat];
        isSuccess=[myDB sqliteExecute:sql];
        if (isSuccess) {
            //NSLog(@"vvv");
        }
    }

    return isSuccess;
}

-(NSMutableArray *)getPendingOperationsArr:(NSString *)timesheetURI
{
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    NSMutableArray *operationArr=nil;
    if ([timesheetsArr count]>0)
    {
        NSString *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];


        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
        {
            operationArr=[NSMutableArray array];
        }
        else
        {
            operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
        }


    }


    if (operationArr!=nil && ![operationArr isKindOfClass:[NSNull class]])
    {
        if ([operationArr count]==1)
        {
            if ([operationArr[0] isEqualToString:NULL_STRING])
            {
                operationArr = nil;
            }
        }
    }

    return operationArr;
}


-(BOOL)isTimesheetPending
{
    NSMutableArray *dbTimesheetsArray = [self getAllTimesheetsFromDB];

    for (NSDictionary *timeSheetDict in dbTimesheetsArray)
    {
        NSString *timesheetURI = [timeSheetDict objectForKey:@"timesheetUri"];
        NSString *operationData=[timeSheetDict objectForKey:@"operations"];

        NSMutableArray *operationArr=nil;


        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
        {
            operationArr=[NSMutableArray array];
        }
        else
        {
            operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
        }


        for (NSString *operationName in operationArr)
        {
            NSLog(@"operationArr=%@ fot timesheeturi=%@",operationArr,timesheetURI);
            if ([operationName isEqualToString:TIMESHEET_SAVE_OPERATION])
            {
                return YES;
            }
            else if ([operationName isEqualToString:TIMESHEET_SUBMIT_OPERATION])
            {
                return YES;
            }
            else if ([operationName isEqualToString:TIMESHEET_REOPEN_OPERATION])
            {
                return YES;
            }
            else if ([operationName isEqualToString:TIMESHEET_RESUBMIT_OPERATION])
            {
                return YES;
            }

        }

    }

    return NO;
}

-(NSString *)getCurrentApprovalStatus:(NSString *)timesheetURI
{
    NSArray *timesheetsArr = [self getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {
        NSString *approvalStatus=[[timesheetsArr objectAtIndex:0]objectForKey:@"approvalStatus"];

        if (approvalStatus !=nil && ![approvalStatus isKindOfClass:[NSNull class]])
        {
            return approvalStatus;
        }

    }

    return nil;
}

@end
