//
//  ApprovalsModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 28/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimesheetForUserWithWorkHours.h"

@interface ApprovalsModel : NSObject

-(void)savePendingApprovalTimeSheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)savePreviousApprovalTimeSheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)savePendingApprovalTimeSheetSummaryDetailsDataFromApiToDB:(NSMutableDictionary *)responseDictionaryObject;
-(void)savePendingApprovalExpenseSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)savePendingApprovalTimeOffsSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)savePreviousApprovalTimeSheetSummaryDetailsDataFromApiToDB:(NSMutableDictionary *)responseDictionaryObject;
-(void)savePreviousApprovalExpenseSheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)savePreviousApprovalTimeOffsSummaryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(NSMutableArray*)getPendingApprovalDataForTimesheetSheetURI:(id)timesheetUri andUserUri:(NSString *)userUri;
-(NSMutableArray*)getPendingApprovalDataForExpenseSheetURI:(id)expenseSheetUri andUserUri:(NSString *)userUri;
-(NSMutableArray*)getPendingApprovalDataForTimeOffsURI:(id)timeOffUri andUserUri:(NSString *)userUri;
-(NSMutableArray*)getPreviousApprovalDataForTimesheetSheetURI:(id)timesheetUri andUserUri:(NSString *)userUri;
-(NSMutableArray*)getPreviousApprovalDataForExpensesheetSheetURI:(id)timesheetUri andUserUri:(NSString *)userUri;
-(NSMutableArray *) getAllPendingTimesheetsOfApprovalFromDB;
-(NSMutableArray *) getAllPendingExpenseSheetOfApprovalFromDB;
-(NSMutableArray *) getAllPreviousTimesheetsOfApprovalFromDB;
-(NSMutableArray *) getAllPreviousExpensesheetsOfApprovalFromDB;
-(NSMutableArray *)getAllPendingTimeSheetsGroupedByDueDatesWithStatus:(NSString *)status;
-(NSMutableArray *)getAllPendingExpenseSheetsGroupedByDueDates;
-(NSMutableArray *)getAllPendingTimeoffs;
-(void)deleteAllApprovalPendingTimesheetsFromDB;
-(void)deleteAllApprovalPendingExpenseSheetsFromDB;
-(void)deleteAllApprovalPendingTimeOffsFromDB;
-(void)deleteAllApprovalPreviousTimesheetsFromDB;
-(void)deleteAllApprovalPreviousExpenseFromDB;
-(NSMutableArray *) getAllPendingTimeOffsOfApprovalFromDB;
-(NSMutableArray *) getAllPreviousTimeOffsOfApprovalFromDB;
-(void)deleteAllApprovalPreviousTimeOffsFromDB;
-(NSMutableArray*)getPreviousApprovalDataForTimeOffURI:(id)timeOffUri andUserUri:(NSString *)userUri;
-(NSMutableArray *) getAllPendingTimesheetDaySummaryFromDBForTimesheet:(NSString *)timesheetUri;

-(NSDictionary *)getTotalHoursInfoForPendingTimesheetIdentity:(NSString *)sheetIdentity;
-(NSArray *)getPendingTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri;
-(NSArray *)getPreviousTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri;
-(NSMutableArray *)getAllPreviousDisclaimerDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getAllPendingDisclaimerDetailsFromDBForModule:(NSString *)moduleName;
-(void)deleteApprovalPendingTimesheetsFromDBWithTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllPendingTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *)getAllPreviousTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *) getPendingTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *) getPreviousTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *) getPendingGroupedStandardTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *) getPreviousGroupedStandardTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSString *)getPendingTimesheetFormatInfoFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSString *)getPreviousTimesheetFormatInfoFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllPendingDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllPreviousDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSArray *)getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:(NSString *)expenseSheetUri;
-(NSArray *)getAllPreviousExpenseExpenseEntriesFromDBForExpenseSheetUri:(NSString *)expenseSheetUri;
-(void)saveExpenseEntryDataFromApiToDB:(NSMutableDictionary *)responseDict moduleName:(NSString *)approvalsModuleName;
-(NSMutableArray *) getAllPendingTimesheetProjectSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPreviousTimesheetProjectSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPendingTimesheetActivitySummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPendingTimesheetPayrollSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPendingTimesheetBillingSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPendingTimesheetApprovalFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPreviousTimesheetActivitySummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPreviousTimesheetPayrollSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPreviousTimesheetBillingSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPreviousTimesheetApprovalFromDBForTimesheet:(NSString *)timesheetUri;
-(NSString *)getPendingTotalActivitySummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPendingTotalProjectSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPendingTotalPayrollSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPendingTotalBillingSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPreviousTotalActivitySummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPreviousTotalProjectSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPreviousTotalPayrollSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getPreviousTotalBillingSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSArray *)getPendingTimesheetSheetUdfInfoForSheetUri:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri  andRowUri:(NSString *)rowUri;
-(NSArray *)getPreviousTimesheetSheetUdfInfoForSheetUri:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri  andRowUri:(NSString *)rowUri;
-(NSArray *)getPendingTimesheetSheetUdfInfoForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri entryDate:(NSString *)entryDate andRowUri:(NSString *)rowUri;
-(NSArray *)getPreviousTimesheetSheetUdfInfoForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri entryDate:(NSString *)entryDate andRowUri:(NSString *)rowUri;
-(NSMutableArray *) getAllPendingTimeoffFromDBForTimeoff:(NSString *)timeoffUri;
-(void)saveTimeOffEntryDataFromApiToDB:(NSMutableDictionary *)responseDict moduleName:(NSString *)approvalsModuleName;
-(NSDictionary *)getStatusInfoForPendingTimeOffIdentity:(NSString *)sheetIdentity;
-(NSArray *)getPendingExpenseCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri;
-(NSArray *)getPreviousExpenseCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri;
-(NSDictionary *)getApprovalStatusInfoForPendingTimesheetIdentity:(NSString *)sheetIdentity;
-(NSArray *)getPendingExpenseSheetInfoSheetIdentity:(NSString *)sheetIdentity;
-(NSArray *)getPreviousExpenseSheetInfoSheetIdentity:(NSString *)sheetIdentity;
-(NSArray *)getPendingTimeOffCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri;
-(NSArray *)getPreviousTimeOffCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri;
-(void)deleteApprovalPendingTimeOffFromDBWithTimeoffUri:(NSString *)timeoffUri;
-(NSMutableArray *) getLastSubmittedPreviousTimesheetApprovalFromDB:(NSString *)timesheetUri;
-(NSMutableArray *) getLastSubmittedPendingTimesheetApprovalFromDB:(NSString *)timesheetUri;
-(BOOL)getPendingTimesheetCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri;
-(BOOL)getPreviousTimesheetCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri;
-(NSString *)getPendingStatusForDisclaimerPermissionForColumnName:(NSString *)columnName forSheetUri:(NSString *)sheetUri;
-(NSString *)getPreviousStatusForDisclaimerPermissionForColumnName:(NSString *)columnName forSheetUri:(NSString *)sheetUri;
-(void)deleteApprovalPendingExpenseFromDBWithTimeoffUri:(NSString *)expenseSheetUri;
-(NSDictionary *)getApprovalStatusInfoForPendingExpenseSheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray *)getAllPendingExpenseSheetsGroupedByDueDatesWithAnyApprovalStatus;
-(NSMutableArray *) getPendingLastSubmittedExpenseSheetApprovalFromDB:(NSString *)timesheetUri;
-(NSMutableArray *) getPreviousLastSubmittedExpenseSheetApprovalFromDB:(NSString *)timesheetUri;
-(BOOL)getPendingExpenseCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri;
-(BOOL)getPreviousExpenseCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri;
-(NSArray *)getPendingExpenseEntryInfoForSheetIdentity:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryURI;
-(NSArray *)getPreviousExpenseEntryInfoForSheetIdentity:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryURI;
-(NSArray *)getAllPendingExpenseTaxCodesFromDBForEntryUri:(NSString *)entryUri;
-(NSArray *)getAllPreviousExpenseTaxCodesFromDBForEntryUri:(NSString *)entryUri;
-(NSArray *)getAllDetailsForPreviousExpenseCodeFromDBForEntryUri:(NSString *)entryUri;
-(NSArray *)getAllDetailsForPendingExpenseCodeFromDBForEntryUri:(NSString *)entryUri;
-(NSArray *)getExpenseTaxCodesFromDBForTaxCodeUri:(NSString *)taxCodeUri;
-(NSArray *)getAllTaxCodeUriEntryDetailsFromDBForExpenseEntryUri:(NSString *)expenseEntryUri;
-(NSDictionary *)getTotalHoursInfoForPreviousTimesheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray *) getAllPreviousTimesheetDaySummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPreviousTimeoffFromDBForTimeoff:(NSString *)timeoffUri;
-(NSMutableArray*)getPendingApprovalDataForTimesheetSheetURI:(id)timeSheetUri;
-(NSMutableArray*)getPreviousApprovalDataForTimesheetSheetURI:(id)timeSheetUri;
-(NSMutableArray *) getPendingTimeEntriesForExtendedInOutSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *) getPreviousTimeEntriesForExtendedInOutSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *) getPendingTimesheetChangeReasonEntriesFromDB: (NSString *)timesheetUri;
//Implementation for US9371//JUHI
-(NSArray *)getPendingTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri;
-(NSArray *)getPreviousTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri;
//Implementation for MOBI-261//JUHI
-(NSMutableArray *) getAllPendingExpenseSheetApprovalFromDBForExpenseSheet:(NSString *)expenseSheetUri;
-(NSMutableArray *) getAllPreviousExpenseSheetApprovalFromDBForExpenseSheet:(NSString *)expenseSheetUri;
-(NSMutableArray *) getAllPendingTimeoffApprovalFromDBForTimeoff:(NSString *)timeoffUri;
-(NSMutableArray *) getAllPreviousTimeoffApprovalFromDBForTimeoff:(NSString *)timeoffUri;

-(NSMutableArray *)getEnabledOnlyUdfArrayForTimesheetUriForPending:(NSString *)timesheetUri;
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimesheetUriForPrevious:(NSString *)timesheetUri;
-(void)updateCustomFieldTableForEnableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray;
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimeoffUriForPending:(NSString *)timeoffUri;
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimeoffUriForPrevious:(NSString *)timeoffUri;
-(void)updateCustomFieldTableForEnableUdfuriArrayForTimeoffs:(NSMutableArray *)enabledOnlyUdfUriArray;
//Implementation For Mobi-92//JUHI
-(void)savePendingTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr;
-(void)savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array isFromTimeoff:(BOOL)isFromTimeOff;
-(void)savePendingGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array dayOffList:(NSArray *)dayOffList isFromTimeoff:(BOOL)isFromTimeOff;
-(void)savePreviousTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr;
-(void)savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array isFromTimeoff:(BOOL)isFromTimeOff;
-(void)savePreviousGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array dayOffList:(NSArray *)dayOffList isFromTimeoff:(BOOL)isFromTimeOff;
-(NSArray *)getTimeSheetInfoSheetIdentityForPending:(NSString *)sheetIdentity;
-(NSArray *)getTimeSheetInfoSheetIdentityForPrevious:(NSString *)sheetIdentity;
-(void)updateTimesheetFormatForPendingApprovalsTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSMutableDictionary *)timesheetFormatDict;
-(void)updateTimesheetFormatForPreviousApprovalsTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSMutableDictionary *)timesheetFormatDict;
-(void)saveApprovalsCapablitiesDataIntoDBWithData:(NSMutableArray *)array isPending:(BOOL)isPending forTimesheetUri:(NSString *)timesheetUri;
//Implemented as per TIME-495//JUHI
-(void)savePendingTimesheetTimeOffSummaryDataFromApiToDBForGen4:(NSMutableArray *)responseArray withTimesheetUri:(NSString *)timesheetUri;
-(void)savePreviousTimesheetTimeOffSummaryDataFromApiToDBForGen4:(NSMutableArray *)responseArray withTimesheetUri:(NSString *)timesheetUri;
-(void)saveApprovalTimesheetApproverSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array moduleName:(NSString *)moduleName;
-(NSMutableDictionary *)getPendingSumOfDurationHoursForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableDictionary *)getPreviousSumOfDurationHoursForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableDictionary *)getDisclaimerDetailsFromDBForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;
-(NSMutableDictionary *)getWidgetSummaryForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;
-(void)deleteAllTimeentriesForTimesheetUri:(NSString *)timesheetUri andWidgetEntries:widgetTimeEntriesArr isPending:(BOOL)isPending;
-(void)deleteAllTimeentriesForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;
-(void)deleteAllTimesheetDaySummaryForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;
-(void)saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andFormat:(NSString *)timeSheetFormat andIsPending:(BOOL)isPending;
-(NSString *)getTimesheetFormatforTimesheetUri:(NSString *)timesheetUri andIsPending:(BOOL)isPending;
-(NSArray*)getPendingTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate forTimesheetFormat:(NSString *)timesheetFormat;
-(NSArray*)getPreviousTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate forTimesheetFormat:(NSString *)timesheetFormat;
-(void)updateAttestationStatusForTimesheetIdentity:(NSString *)timesheetUri withStatus:(BOOL)isSelected isPending:(BOOL)isPending;
-(NSMutableDictionary *)getAttestationDetailsFromDBForTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;
-(NSArray *)getAllPaycodesIsPending:(BOOL)isPending forTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllSupportedAndNotSupportedPendingWidgetsForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllSupportedAndNotSupportedPreviousWidgetsForTimesheetUri:(NSString *)timesheetUri;

-(void)resetAndSaveTeamTimesheets:(NSDictionary *)timesheetDict andTimesheetForUserWithWorkHours:(TimesheetForUserWithWorkHours *)timesheet;

-(void)updateApprovalTimeentriesFormatForTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSString *)withFormat fromFormat:(NSString *)fromFormat andIsPending:(BOOL)isPending;
-(void)saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;
-(BOOL)getTimeSheetEditStatusForSheetFromDB: (NSString *)timesheetUri forTableName:(NSString *)table;

-(float)getTimeEntryTotalForEntryWithWhereString:(NSString *)whereString isPending:(BOOL)isPending;
-(void)updateSummaryDataForTimesheetUri:(NSString *)timesheetUri withDataDict:(NSMutableDictionary *)timesheetDataTSDict andIsPending:(BOOL)isPending;

-(NSMutableArray *)getNotSupportedPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getNotSupportedPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(BOOL) isMultiDayTimeOff:(NSString *)timeoffUri :(NSString *)tableName;

-(NSString *)getEntriesTimeOffBreaksTotalForEntryDate:(NSString *)entryDate andTimesheetUri:(NSString *)timesheetUri isPending:(BOOL)isPending;

@end
