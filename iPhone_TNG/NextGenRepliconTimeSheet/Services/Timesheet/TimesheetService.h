//
//  TimesheetService.h
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import "SupportDataModel.h"
#import"BaseService.h"
#import"Constants.h"
#import "TimesheetModel.h"
#import "SpinnerDelegate.h"
#import "TimeoffModel.h"

@interface TimesheetService : BaseService
{
	unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;
    id __weak newTimeEntryDelegate;
    TimesheetModel *timesheetModel;
    TimeoffModel *timeoffModel;
    
}
@property(nonatomic, strong) TimesheetModel *timesheetModel;
@property(nonatomic,weak)id widgetTimesheetDelegate;
@property(nonatomic,assign) BOOL didSuccessfullyFetchTimesheets;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithSpinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate;

-(void)fetchTimeSheetData:(id)_delegate;
-(void)fetchTimeSheetDataOnlyWhenUpdateFetchDataFails:(id)_delegate;

-(void)fetchTimeSheetSummaryDataForTimesheet:(NSString *)timesheetUri withDelegate:(id)_delegate;
//-(void)fetchEnabledTimeoffTypesDataForTimesheetWithDelegate:(id)_delegate;
-(void)fetchFirstClientsAndProjectsForTimesheetUri:(NSString *)timesheetUri withClientSearchText:(NSString *)clientText withProjectSearchText:(NSString *)projectText andDelegate:(id)delegate;
-(void)fetchNextClientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchProjectsBasedOnclientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchTasksBasedOnProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate;
-(void)fetchNextTasksBasedOnProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate;
-(void)fetchNextProjectsBasedOnclientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchFirstClientsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchFirstProjectsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchBillingRateBasedOnProjectForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate;
-(void)fetchNextBillingRateBasedOnProjectForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate;
-(void)fetchActivityBasedOnTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextActivityBasedOnTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)sendRequestToSaveTimesheetDataForTimesheetURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeEntryObjectArray withDelegate:(id)delegate isMultiInOutTimeSheetUser:(BOOL)isMultiInOutTimeSheetUser isNewAdhocEntryDict:(NSMutableDictionary *)adhocEntryDict isTimesheetSubmit:(BOOL)isTimesheetSubmit sheetLevelUdfArray:(NSMutableArray *)sheetLevelUdfArray submitComments:(NSString *)submitComments isAutoSave:(NSString*)isAutoSaveStr isDisclaimerAccepted:(BOOL)isDisclaimerAccepted rowUri:(NSString *)rowUri actionMode:(NSInteger)actionMode isExtendedInOutUser:(BOOL)isExtendedInOutUser reasonForChange:(NSString*)reasonForChange ;//Implementation for JM-35734_DCAA compliance support//JUHI
-(void)handleTimesheetsFetchData:(id)response;
-(void)handleNextRecentTimesheetsFetchData:(id)response;

- (void)handleTimesheetsSummaryFetchData:(id)response isFromSave:(BOOL)isFromSave;
-(void)handleEnabledTimeoffTypes:(id)response;
-(void)handleClientsAndProjectsDownload:(id)response;
-(void)handleNextClientsDownload:(id)response;
-(void)handleNextProjectsDownload:(id)response;
-(void)handleBillingRateBasedOnProjectDownload:(id)response;
-(void)handleNextBillingRateBasedOnProjectDownload:(id)response;
-(void)handleActivityBasedOnTimesheetDownload:(id)response;
-(void)handleNextActivityBasedOnTimesheetDownload:(id)response;
-(void)handleNextTasksBasedOnProjectsResponse:(id)response;
-(void)handleTasksBasedOnProjectsResponse:(id)response;
-(void)handleTimesheetsSaveData:(id)response;
-(void)sendRequestToSubmitTimesheetDataForTimesheetURI:(NSString *)timesheetURI withComments:(NSString *)comments withDelegate:(id)delegate;
-(void)sendRequestToUnsubmitTimesheetDataForTimesheetURI:(NSString *)timesheetURI withComments:(NSString *)comments withDelegate:(id)delegate;
-(void)handleTimesheetsSubmitData:(id)response;
-(void)handleTimesheetsUnsubmitData:(id)response;
-(void)handleTimesheetsDataOnlyWhenUpdateFetchDataFails:(id)response;
-(void)fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)searchText andDelegate:(id)delegate;
-(void)handleGetPageOfTimeOffTypesAvailableForTimeAllocation:(id)response;

//Implentation for US8956//JUHI
-(void)fetchBreakForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextBreakForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchTimeoffEntryDataForBookedTimeoff:(NSString *)timeoffUri withTimeSheetUri:(NSString *)timesheetUri;//Implemented as per TOFF-115//JUHI
-(void)fetchTimeoffData:(id)_delegate;
-(void)sendRequestToSaveBookedTimeOffDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray andUdfArray:(NSMutableArray *)udfArray withDelegate:(id)delegate;
-(void)sendRequestToDeleteTimeoffDataForURI:(NSString *)timeoffUri;
-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withDelegate:(id)delegate;
-(void)sendRequestToResubmitBookedTimeOffDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray andUdfArray:(NSMutableArray *)udfArray withDelegate:(id)delegate;
-(void)sendRequestToSaveWorkTimeEntryForGen4:(id)delegate withClientID:(NSString *)clientId isBlankTimeEntrySave:(BOOL)isBlankTimeEntrySave withTimeEntryUri:(NSString *)timeEntryUri withStartDate:(NSDate *)startDate forTimeSheetUri:(NSString *)timesheetUri withTimeDict:(NSDictionary *)timeDict timesheetFormat:(NSString *)timesheetFormat andColumnNameForEntryUri:(NSString *)columnName;
-(void)sendRequestToSaveBreakTimeEntryForGen4:(id)delegate withBreakUri:(NSString *)clientId isBlankTimeEntrySave:(BOOL)isBlankTimeEntrySave withTimeEntryUri:(NSString *)timeEntryUri withStartDate:(NSDate *)startDate forTimeSheetUri:(NSString *)timesheetUri withTimeDict:(NSDictionary *)timeDict withClientID:(NSString *)clientId withBreakName:(NSString *)breakName timesheetFormat:(NSString *)timesheetFormat andColumnNameForEntryUri:(NSString *)columnName;
-(void)sendRequestToDeleteTimeEntryForGen4WithClientUri:(NSString *)timeEntryUri withDelegate:(id)delegate isWork:(BOOL)isWork withTimesheetUri:(NSString *)timesheetUri withRow:(NSInteger)row withSection:(NSInteger)section withEntryDate:(float)entryDate timesheetFormat:(NSString *)timesheetFormat andColumnNameForEntryUri:(NSString *)columnName;
-(void)sendRequestToGetTimesheetApprovalSummaryForTimesheetUri:(NSString *)timesheetUri delegate:(id)delegate;
-(void)fetchTimeSheetTimeOffSummaryDataForGen4TimesheetWithStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate withDelegate:(id)_delegate withTimesheetUri:(NSString *)timesheetURI;

//Implementation for PUNCH-492//JUHI
-(void)sendRequestToGetAllTimeSegmentsForTimesheet:(NSString *)timesheetUri WithStartDate:(NSDate *)startDate withDelegate:(id)_delegate;
-(void)sendRequestToGetValidationDataForTimesheet:(NSString *)timesheetUri;
-(void)sendRequestToGetPunchHistoryForTimesheetWithTimesheetUri:(NSString *)timesheetUri delegate:(id)delegate;

//MOBI-746
-(void)fetchFirstProgramsAndProjectsForTimesheetUri:(NSString *)timesheetUri withProgramSearchText:(NSString *)programText withProjectSearchText:(NSString *)projectText  andDelegate:(id)delegate;
-(void)fetchProjectsBasedOnProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProgramUri:(NSString *)programUri andDelegate:(id)delegate;
-(void)fetchNextProjectsBasedOnProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProgramUri:(NSString *)programUri andDelegate:(id)delegate;
-(void)fetchFirstProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextProgramsForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;

-(void)fetchDefaultBillingRateBasedOnProjectForTimesheetUri:(NSString *)timesheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate;

-(void)handleTimesheetsSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri timeEntryProjectTaskAncestryDetails:(NSMutableArray *)timeEntryProjectTaskAncestryDetailsArr andDayOffList:(NSArray *)dayOffList;
-(void)handleTimesheetsTimeoffSummaryFetchDataForGen4:(NSMutableArray *)timeOffsArr withTimesheetUri:(NSString *)timesheetUri andDayOffList:(NSArray *)dayOffList;
-(void)handleBreakDownload:(id)response;

- (void) serverDidRespondWithResponse:(id) response;

-(void)sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:(NSString *)timesheetURI forAttestationStatusUri:(NSString *)attestationStatusUri;

-(void)handleTimesheetsUpdateFetchData:(id)response;
-(void)handleDailyWidgetSummaryFetchDataForGen4:(NSMutableArray *)widgetTimeEntriesArr withTimesheetUri:(NSString *)timesheetUri andDayOffList:(NSArray *)dayOffList;

@end
