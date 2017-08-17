//
//  ApprovalsService.h
//  Replicon
//
//  Created by Ullas ML on 28/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseService.h"
#import "ApprovalsModel.h"

@interface ApprovalsService : BaseService
{
    ApprovalsModel *approvalsModel;
	
    int totalRequestsSent;
	int totalRequestsServed;
    
}

@property(nonatomic,assign) int totalRequestsSent;
@property(nonatomic,assign) int totalRequestsServed;
@property(nonatomic, strong) ApprovalsModel *approvalsModel;
@property(nonatomic,weak)id widgetTimesheetDelegate;

-(void)fetchSummaryOfTimeSheetPendingApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfExpenseSheetPendingApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfPreviousTimeSheetApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfPreviousExpenseApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfPreviousTimeOffsApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfNextPendingTimesheetApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfNextPendingExpenseApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfNextPendingTimeOffsApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfNextPreviousTimeSheetApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfNextPreviousExpenseApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfNextPreviousTimeOffsApprovalsForUser:(id)_delegate;
-(void)fetchSummaryOfTimeOffPendingApprovalsForUser:(id)_delegate;

-(void)sendRequestToApproveTimesheetsWithURI:(NSMutableArray *)timesheetUriArray withComments:(id)commentStr  andDelegate:(id)_delegate;
-(void)sendRequestToRejectTimesheetsWithURI:(NSMutableArray *)timesheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate;
-(void)sendRequestToRejectExpenseSheetsWithURI:(NSMutableArray *)expenseSheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate;
-(void)sendRequestToRejectTimeOffsWithURI:(NSMutableArray *)timeOffUriArray withComments:(id)commentStr andDelegate:(id)_delegate;
-(void)sendRequestToApproveExpenseSheetsWithURI:(NSMutableArray *)expenseSheetUriArray withComments:(id)commentStr andDelegate:(id)_delegate;
-(void)sendRequestToApproveTimeOffsWithURI:(NSMutableArray *)timeOffUriArray withComments:(id)commentStr andDelegate:(id)_delegate;
-(void)fetchPendingTimeSheetSummaryDataForTimesheet:(NSString *)timesheetUri withDelegate:(id)_delegate;
-(void)fetchApprovalPendingExpenseEntryDataForExpenseSheet:(NSString *)expenseSheetUri withDelegate:(id)_delegate;
-(void)fetchApprovalPendingTimeoffEntryDataForBookedTimeoff:(NSString *)timeoffUri withDelegate:(id)_delegate;
-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timeoffURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withUserUri:(NSString *)userURI;
-(void)handleCountOfApprovalsForUser:(id)response;
-(void)handleSummaryOfPendingTimesheetApprovalsForUser:(id)response;
-(void)handleSummaryOfPendingExpenseApprovalsForUser:(id)response;
-(void)handleSummaryOfPendingTimeOffsApprovalsForUser:(id)response;
-(void)handleSummaryOfPreviousTimeSheetApprovalsForUser:(id)response;
-(void)handleBulkApproveOfApprovalTimesheets:(id)response;
-(void)handleBulkRejectOfApprovalTimesheets:(id)response;
-(void)handleBulkApproveOfApprovalExpenseSheets:(id)response;
-(void)handleBulkRejectOfApprovalExpenseSheets:(id)response;
-(void)handleBulkApproveOfApprovalTimeOffs:(id)response;
-(void)handleBulkRejectOfApprovalTimeOffs:(id)response;
-(void)handleSummaryOfPreviousTimeOffsApprovalsForUser:(id)response;
-(void)handleSummaryOfNextPreviousTimeOffsApprovalsForUser:(id)response;
-(void)handleApprovalsTimeSheetSummaryDataForTimesheet:(id)response module:(NSString *)moduleName;
//Implementation For Mobi-92//JUHI
//-(void)fetchApprovalsTimeSheetEffectivePolicyDataGen4ForTimesheetURI:(NSString *)timesheetURI isFromPending:(BOOL)isPending;
-(void)fetchApprovalsTimeSheetTimeoffSummaryDataForGen4TimesheetWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate withDelegate:(id)_delegate withTimesheetUri:(NSString *)timesheetURI withUserUri:(NSString *)userUri isPending:(BOOL)isPending;//Implementation For TIME-495//JUHI
-(void)sendRequestToGetPunchHistoryForTimesheetWithTimesheetUri:(NSString *)timesheetUri delegate:(id)delegate isPending:(BOOL)isPending;
-(void)handleCountOfGetMyNotificationSummary:(id)response;
-(void)handleTimeSegmentsForTimesheetDataForGen4:(NSDictionary *)timePunchTimeSegmentDetailsDict isFromPending:(BOOL)isFromPending forTimeSheetUri:(NSString *)timesheetUri;;
-(void)handleDailyWidgetSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andModuleName:(NSString *)moduleName andDayOffList:(NSArray *)dayOffList;
@end
