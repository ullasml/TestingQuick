//
//  TimesheetModel.h
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import "Constants.h"
@class TimesheetEntryObject;

@interface TimesheetModel : NSObject
{
    
}



-(void)saveTimesheetPeriodDataFromApiToDB:(NSMutableDictionary *)responseDict;

- (void)saveTimesheetSummaryDataFromApiToDB:(NSMutableDictionary *)responseDictionaryObject isFromSave:(BOOL)isFromSave;
-(void)saveEnabledTimeoffTypesDataToDB:(NSMutableArray *)array;
-(void)saveClientDetailsDataToDB:(NSMutableArray *)array;
-(void)saveProjectDetailsDataToDB:(NSMutableArray *)array;
-(void)saveTaskDetailsDataToDB:(NSMutableArray *)array;
-(void)saveBillingDetailsDataToDB:(NSMutableArray *)array withModuleName:(NSString*)module;
-(void)saveActivityDetailsDataToDB:(NSMutableArray *)array withModuleName:(NSString*)module;
-(NSArray *)getTimeSheetInfoSheetIdentity:(NSString *)sheetIdentity;
-(NSArray *)getTimesheetinfoForActivityIdentity:(NSString *)activityIdentity timesheetIdentity:(NSString *)timesheetUri;
-(NSArray *)getTimesheetinfoForProjectIdentity:(NSString *)projectIdentity timesheetIdentity:(NSString *)timesheetUri;
-(NSArray *)getTimesheetinfoForBillingIdentity:(NSString *)billingIdentity timesheetIdentity:(NSString *)timesheetUri;
-(NSArray *)getTimesheetinfoForPayrollIdentity:(NSString *)payrollIdentity timesheetIdentity:(NSString *)timesheetUri;
-(NSMutableArray *) getAllTimesheetsFromDB;
-(NSMutableArray *) getAllTimesheetProjectSummaryFromDB;
-(NSMutableArray *) getAllTimesheetBillingSummaryFromDB;
-(NSMutableArray *) getAllTimesheetPayrollSummaryFromDB;
-(NSMutableArray *) getAllTimesheetApproverSummaryFromDB;
-(NSMutableArray *) getAllTimesheetDaySummaryFromDB;
-(NSMutableArray *) getAllTimesheetDaySummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllTimesheetProjectSummaryFromDBForTimesheet:(NSString *)timesheetUri ;
-(NSMutableArray *) getAllTimesheetActivitySummaryFromDBForTimesheet:(NSString *)timesheetUri ;
-(NSMutableArray *) getAllTimesheetPayrollSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllTimesheetBillingSummaryFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getAllTimeOffTypesFromDB;
-(NSMutableArray *)getAllDisclaimerDetailsFromDBForModule:(NSString *)moduleName;
-(void)deleteAllTimesheetsFromDB;
-(void)deleteAllSavedTimeoffTypes;
-(NSString *)getTotalActivitySummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getTotalProjectSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getTotalPayrollSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSString *)getTotalBillingSummaryHours:(NSString *)timesheetUri withFormat:(NSString *)format;
-(NSMutableArray *)getAllClientsDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getAllProjectsDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getAllTasksDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getAllBillingDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getAllActivityDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getClientDetailsFromDBForClientUri:(NSString *)clientUri;
-(NSMutableArray *)getProjectDetailsFromDBForProjectUri:(NSString *)projectUri;
-(NSMutableArray *)getTaskDetailsFromDBForTaskUri:(NSString *)taskUri;
-(NSMutableArray *)getBillingDetailsFromDBForBillingUri:(NSString *)billingUri;
-(NSMutableArray *)getActivityDetailsFromDBForActivityUri:(NSString *)activityUri;
-(void)deleteAllClientsInfoFromDBForModuleName:(NSString *)moduleName;
-(void)deleteAllProjectsInfoFromDBForModuleName:(NSString *)moduleName;
-(void)deleteAllTasksInfoFromDBForModuleName:(NSString *)moduleName;
-(void)deleteAllBillingInfoFromDBForModuleName:(NSString *)moduleName;
-(void)deleteAllActivityInfoFromDBForModuleName:(NSString *)moduleName;

-(void)saveTimeAlloctionsAndPunchesDataToDBForTimesheetUri:(NSString*)timesheetUri dataDict:(NSMutableDictionary *)timesheetDetailsDict;
-(NSArray*)getTimesheetInfoForTimeAllocationUri:(NSString*)timeAllocationUri timesheetUri:(NSString *)timesheetUri;
-(NSArray*)getTimesheetInfoForTimePunchesUri:(NSString*)timePunchesUri timesheetUri:(NSString *)timesheetUri;
-(NSArray*)getTimesheetInfoForTimeIn:(NSString*)time_in andTimeOut:(NSString*)time_out timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate;
-(NSMutableArray *) getTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSDictionary *)getTotalHoursInfoForTimesheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray *) getAllTimesheetApprovalFromDBForTimesheet:(NSString *)timesheetUri;
-(NSMutableArray *) getGroupedStandardTimeEntriesForSheetFromDB: (NSString *)timesheetUri andTimesheetFormat:(NSString *)timesheetFormat;
-(NSMutableArray *)getAllDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSString *)getTimesheetFormatInfoFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllDistinctProjectUriFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllTimeEntriesForSheetFromDB: (NSString *)timesheetUri;
-(NSMutableArray *)getAllTimeEntriesForSheetFromDB: (NSString *)timesheetUri forTimeSheetFormat:(NSString *)timesheetFormat;
-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI andtimeEntryDate:(NSNumber *)entryDate;
-(NSMutableArray *)getAllExtendedTimeEntriesForSheetFromDB: (NSString *)timesheetUri;

-(NSArray *)getTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri;
-(NSArray *)getTimesheetSheetUdfInfoForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri entryDate:(NSString *)entryDate andRowUri:(NSString *)rowUri;
-(NSArray *)getTimesheetSheetUdfInfoForSheetUri:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri  andRowUri:(NSString *)rowUri;
//Implemented as per US7859
-(void)saveTimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array withNoticeAcceptedFlag:(int)noticeFlag withAvailableTimeOffTypeCount:(int)availableTimeOffTypeCount isTimesheetCommentsRequired:(BOOL)isTimesheetCommentsRequired;
-(NSDictionary *) getAvailableTimeOffTypeCountInfoForTimesheetIdentity:(NSString *)timesheetUri;
//Implemented For overlappingTimeEntriesPermitted Persmisson
-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName ForTimesheetIdentity:(NSString *)timesheetUri;
-(BOOL)readIsSplitTimeEntryForMidNightCrossOverPermission:(NSString *)permissionName forTimesheetIdentity:(NSString *)timesheetUri;
-(void)deleteTimesheetsFromDBForForTimesheetIdentity:(NSString *)timesheetUri;//Implementation of TimeSheetLastModified
-(NSMutableArray *) getTimeEntriesForExtendedInOutSheetFromDB: (NSString *)timesheetUri andTimeSheetFormat:(NSString *)timesheetFormat;
-(NSMutableArray *) getUniqueExtendedInOutProjectsSuggestionsFromDB: (NSString *)timesheetUri ForEntryDate:(NSDate *)entryDate;
-(NSArray *)getTimesheetSheetUdfInfoForSheetURIForExtendedSuggestion:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri;

//Implentation for US8956//JUHI
-(void)saveBreakDetailsDataToDB:(NSMutableArray *)array;
-(NSMutableArray *)getBreakDetailsFromDBForBreakUri:(NSString *)breakUri;
-(NSMutableArray *)getAllBreakDetailsFromDB;
-(void)deleteAllBreakInfoFromDB;
-(NSMutableArray *)getProjectDetailsFromDBForProjectUri:(NSString *)projectUri andModuleName:(NSString*)moduleName;
-(NSMutableArray *)getTaskDetailsFromDBForTaskUri:(NSString *)taskUri andModuleName:(NSString*)moduleName;
-(NSMutableArray *)getActivityDetailsFromDBForActivityUri:(NSString *)activityUri andModuleName:(NSString*)moduleName;
-(NSArray *)getTimesheetSheetCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUri andRowUri:(NSString *)rowUri;//Implementation for US9371//JUHI
-(BOOL)getTimeSheetEditStatusForSheetFromDB: (NSString *)timesheetUri;
//Implemented as per TOFF-115//JUHI

-(void)saveTimeoffTypeDetailDataToDB:(NSMutableArray *)array;
-(NSMutableArray *)getAllEnabledTimeOffTypesFromDB;
-(void)updateCustomFieldTableFor:(NSString *)udfModuleName enableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray;
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimesheetUri:(NSString *)timesheetUri;
-(void)updateCustomFieldTableForEnableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray;
-(BOOL)getTimeSheetForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
-(void)saveTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)responseDict withTimesheetUri:(NSString *)timesheetUri andTimeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr;
-(void)saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array isFromTimeoff:(BOOL)isFromTimeOff;
-(void)saveGen4TimesheetDaySummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array dayOffList:(NSArray *)dayOffList isFromTimeoff:(BOOL)isFromTimeOff;
-(void)saveTimeEntryDataForGen4TimesheetIntoDB:(id)response;
-(void)deleteTimeEntriesFromDBForForTimesheetIdentity:(NSString *)timesheetUri;
-(void)deleteInfoFromDBForEntryUri:(NSString *)entryUri withTimesheetUri:(NSString *)timesheetUri andEntryDate:(NSString *)entryDate isWorkEntry:(BOOL)isWorkEntry;
-(void)saveBreakEntryDataForGen4TimesheetIntoDB:(id)response;
-(float )getAllTimeEntriesTotalForSheetFromDB: (NSString *)timesheetUri;
-(NSString *)getEntriesTimeOffBreaksTotalForEntryDate:(NSString *)entryDate andTimesheetUri:(NSString *)timesheetUri;
-(void)updateApprovalStatusForTimesheetIdentity:(NSString *)timesheetUri withStatus:(NSString *)status;
-(void)saveTimesheetApproverSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array;
//Implemented as per TIME-495//JUHI
-(void)saveTimesheetTimeOffSummaryDataFromApiToDBForGen4:(NSMutableArray *)responseArray withTimesheetUri:(NSString *)timesheetUri;
-(void)deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:(NSString *)timesheetUri andWidgetEntries:(NSMutableArray *)widgetTimeEntriesArr;
-(void)deleteTimesheetSummaryDataFromApiToDBForGen4withTimesheetUri:(NSString *)timesheetUri;
//-(void)saveTimesheetEffectivePolicyToDBForGen4WithTimesheetUri:(NSString *)timesheetUri andResponseArray:(NSMutableArray *)response;
-(void)updateEditedValueForGen4BreakWithEntryUri:(NSString *)entryUri sheetUri:(NSString *)timesheetUri withBreakName:(NSString *)breakName withBreakUri:(NSString *)breakUri;
-(NSMutableDictionary *)getSumOfDurationHoursForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *) getAllTimesheetApproverSummaryFromDBInLatestOrderForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(void)updateTimesheetFormatForTimesheetWithUri:(NSString *)timesheetUri;
-(NSMutableDictionary *)getDisclaimerDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSMutableDictionary *)getWidgetSummaryForTimesheetUri:(NSString *)timesheetUri;
-(void)updateSummaryDataForTimesheetUri:(NSString *)timesheetUri withDataDict:(NSMutableDictionary *)timesheetDataTSDict;
-(void)updateTimesheetDataForTimesheetUri:(NSString *)timesheetUri withDataDict:(NSMutableDictionary *)timesheetDataTSDict;
//MOBI-746
-(void)deleteAllProgramsInfoFromDBForModuleName:(NSString *)moduleName;
-(void)saveProgramDetailsDataToDB:(NSMutableArray *)array;
-(NSMutableArray *)getAllProgramsDetailsFromDBForModule:(NSString *)moduleName;
-(void)saveTimesheetTimeOffSummaryDataFromApiToDBForStandardAndInOutUsers:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andFormat:(NSString *)timeSheetFormat;
-(void)updateTimesheetWithOperationName:(NSString *)operationName andTimesheetURI:(NSString *)timesheetURI;
-(void)deleteOperationName:(NSString *)operationName andTimesheetURI:(NSString *)timesheetURI;
-(void)deleteAllOperationNamesForTimesheetURI:(NSString *)timesheetURI;
-(void)rollbackLastOperationNameforTimesheetURI:(NSString *)timesheetURI forCurrentOperationName:(NSString *)operationName;
-(void)updateTimeEntryTableForTimesheetUri:(NSString *)timesheetUri andClientID:(NSString *)clientID withDataDict:(NSDictionary *)dataDict andStartDate:(NSDate *)startDate andIsBreak:(BOOL)isBreak andbreakName:(NSString *)breakName andbreakUri:(NSString *)breakUri andEntryURIColumnName:(NSString *)entryURIColumnName;
-(void)updateTimeEntryTableForTimesheetUri:(NSString *)timesheetUri andTimeEntryUri:(NSString *)timeEntryUri withDataDict:(NSDictionary *)dataDict;
-(void)insertBlankTimeEntryObjectForGen4:(NSString *)clientPunchId andEntryDate:(NSDate *)timeEntryDate andTimeSheetURI:(NSString *)timesheetUri;
-(void)insertBlankBreakEntryObjectForGen4:(NSString *)clientPunchId andEntryDate:(NSDate *)timeEntryDate andTimeSheetURI:(NSString *)timesheetUri andBreakName:(NSString *)breakName andBreakUri:(NSString *)breakUri;
-(void)updateTotalTimeOnWidgetSummaryTableForTimeSheetUri:(NSString *)timesheetUri;
-(NSString *)getTimesheetApprovalStatusForTimesheetIdentity:(NSString *)timesheetUri;
-(NSMutableArray *)getDeletedTimeEntriesForTimeSheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllBreakDetailsFromDBWithSearchText:(NSString *)searchText;
-(void)deleteAllTimesheetSummaryDataFromDBForGen4withTimesheetUri:(NSString *)timesheetUri;

-(void)saveEnabledWidgetsDetailsIntoDB:(NSDictionary *)widgetTimesheetResponse andTimesheetUri:(NSString *)timesheetUri;

- (void)saveWidgetTimesheetSummaryOfHoursIntoDB:(NSMutableDictionary *)summaryDict andTimesheetUri:(NSString *)timesheetUri isFromSave:(BOOL)isFromSave;
-(void)updatecanEditTimesheetStatusForTimesheetWithUri:(NSString *)timesheetUri withStatus:(int)allowTimeEntryEditForGen4;
-(void)saveTimesheetActivitiesSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array;
-(void)saveTimesheetProjectSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array;
-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArray:(NSMutableArray *)array1 andArray:(NSMutableArray *)array2 forTimesheetUri:(NSString *)timesheetUri;
-(void)saveTimesheetBillingSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array withNonBillableDict:(NSDictionary *)nonBillableDict;
-(void)saveTimesheetPayrollSummaryDataToDBForTimesheetUri:(NSString *)timesheetUri dataArray:(NSMutableArray *)array;
-(void)saveTimesheetDisclaimerDataToDB:(NSMutableDictionary *)disclaimerDict;
-(void)saveStandardTimeEntriesDataToDBForTimesheetUri:(NSString*)timesheetUri dataDict:(NSMutableDictionary *)standardTimesheetDetailsDict projectTaskDetails:(NSArray *)projectTaskDetailsArr taskDetails:taskDetailsArr;
-(NSString *)getTimesheetFormatforTimesheetUri:(NSString *)timesheetUri;
-(NSArray*)getTimesheetTimeOffInfoForRowUri:(NSString*)rowUri timesheetUri:(NSString *)timesheetUri andEntryDate:(NSNumber *)entryDate forTimesheetFormat:(NSString *)timesheetFormat;
-(NSDictionary *)getMaxandMinRowNumberFromTimeEntries:(NSMutableArray *)timesheetDataArray andTimesheetFormat:(NSString *)tsFormat;
-(BOOL)getTimesheetCapabilityStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)sheetUri;
-(void)updateAttestationStatusForTimesheetIdentity:(NSString *)timesheetUri withStatus:(BOOL)isSelected;
-(NSMutableDictionary *)getAttestationDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
-(NSArray *)getAllPaycodesforTimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllSupportedAndNotSupportedWidgetsForTimesheetUri:(NSString *)timesheetUri;
-(void)updateTimeentriesFormatForTimesheetWithUri:(NSString *)timesheetUri withFormat:(NSString *)withFormat fromFormat:(NSString *)fromFormat;
-(NSMutableArray *)getTimesheetObjectExtensionFieldsForTimeSheetUri:(NSString*)timesheetUri andtimesheetFormat:(NSString *)timesheetFormat andOEFLevel:(NSString *)oefLevel;
-(NSArray *)getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:(NSString*)timesheetUri andtimesheetEntryUri:(NSString *)timeEntryUri;
-(BOOL)checkIfTimeEntriesModifiedOrDeleted:(NSString *)timesheetUri timesheetFormat:(NSString *)timesheetFormat;
-(void)saveTimesheetDataToDB:(NSMutableDictionary *)timesheetDict;
-(void)saveDailyWidgetTimesheetSummaryDataFromApiToDBForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri;
-(BOOL)isTimesheetPending;
-(NSMutableArray *)getPendingOperationsArr:(NSString *)timesheetURI;
-(NSString *)getLatestTimesheetHistoryActionUriForTimesheetUri:(NSString *)timesheetUri;
-(void)deleteLastKnownApprovalStatusForTimesheetURI:(NSString *)timesheetURI;
-(NSString *)getCurrentApprovalStatus:(NSString *)timesheetURI;
-(NSMutableArray *) getAllTimesheetsUrisFromDB;
-(BOOL)updateTimeEntriesModifiedOrDeleted:(NSString *)timesheetUri timesheetFormat:(NSString *)timesheetFormat;
-(float)getTimeEntryTotalForEntryWithWhereString:(NSString *)whereString;
-(void)saveTimeEntryDataForEmptyTimeValue:(TimesheetEntryObject *)tsEntryObj :(NSString *)timesheetFormat;
-(void)deleteEmptyTimeEntryValue:(TimesheetEntryObject *)tsEntryObj withTimesheetFormat:(NSString *)timesheetFormat;
- (void)updateEmptyTimeEntryValueWithEnteredTime:(TimesheetEntryObject *)tsEntryObj timesheetFormat:(NSString *)timesheetFormat;
-(void)refreshAllInFlightSaveOperationsforAllTimesheets;
-(BOOL)isTimesheetContainsInflightSaveOperation:(NSString *)timesheetUri;
-(NSMutableArray *)getNotSupportedWidgetsUriDetailsFromDBForTimesheetUri:(NSString *)timesheetUri;
@end
