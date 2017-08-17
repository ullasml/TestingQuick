//
//  TimesheetService.h
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2BaseService.h"
#import "G2ServiceUtil.h"
#import "G2RequestBuilder.h"
#import "G2AppProperties.h"
#import "JsonWrapper.h"
#import "G2Util.h"
#import "G2SupportDataModel.h"
#import"G2BaseService.h"
#import"G2Constants.h"
#import "G2TimesheetModel.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeOffEntryObject.h"


@interface G2TimesheetService : G2BaseService {
	G2TimesheetModel *timesheetModel;
	G2SupportDataModel *supportDataModel;
	
	unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;

	id __weak newTimeEntryDelegate;

    BOOL isNewTimeOffPopUp; //DE6520//Juhi
}

@property(nonatomic,assign) BOOL isNewTimeOffPopUp; //DE6520//Juhi

-(void)sendRequestToFetchMostRecentTimesheetsForUser;
-(void)sendRequestToFetchNextRecentTimeSheets:(NSString *)handleIdentity 
							   withStartIndex:(NSNumber*)startingIndex 
								   countLimit:(NSNumber*)limit;
-(void)handleTimeSheetsResponse:(NSMutableArray *)entryTimesheetResponseArray;
-(void)handleGetTimesheetFromApiResponse:(id)response; 
-(void)getTimesheetFromApiAndAddTimeEntry:(G2TimeSheetEntryObject *)entryObj;
-(void)submitTimesheetWithComments: (NSString *)sheetIdentity comments:(NSString *)comments;
-(void)handleSubmitTimesheetResponse: (id)response;
-(void)getTimesheetFromApiWithIdentity:(NSString *)sheetIdentity;
-(void)handleGetTimesheetWithIdentityResponse:(id)response;
-(void) unsubmitTimesheetWithIdentity: (NSString *)sheetIdentity;
-(void)handleUnsubmitTimesheetResponse: (id)response;
-(void)handleNextRecentFetchTimeSheets:(id)response;
-(void)getApprovalHistoryFromApiForSheet: (NSString *)sheetIdentity;
-(void)handleApprovalHistoryresponseForSheet: (id)response;
-(NSMutableArray *)parseApprovalHistoryResponse:(NSArray *)valueArray;

-(void)sendRequestToFetchTasksForProject:(G2TimeSheetEntryObject *)entryObject;
-(void)sendRequestToFetchSubTasksForParentTask:(NSString *) selectedTaskIdentity :(NSString *) projectIdentity;
-(void)handleProjectTasksResponse:(id)response :(NSString *)projectIdentity;
-(void)handleProjectSubTasksResponse:(id)response :(NSString *)projectIdentity :(NSString *)parentTaskIdentity;
- (void)fetchTimeSheetData:(id)_caller;
//- (void)requestMostRecentTimeSheets :(id)_delegate;

-(void) updateTimesheetLastUpdateTime;
//- (void)showListOfTimesheets;
//-(void)receivedTimesheetData;


-(void)sendRequestToEditTheTimeEntryDetailsWithUserData:(G2TimeSheetEntryObject *)_timeEntryObject;
-(void)sendRequestToEditTheTimeEntryDetailsWithUserDataForInOutTimesheets:(G2TimeSheetEntryObject *)_timeEntryObject;
-(void)handleEditedTimeEntryResponse:(id)response;


-(void)handleBookedTimeOffResponse:(id)response;//Added on July 13th
-(void)requestToFetchBookedTimeOff;

-(void)sendRequestToAddNewTimeEntryWithObject:(G2TimeSheetEntryObject *)entryObject;
-(void)sendRequestToAddNewTimeEntryWithObjectForInOutTimesheets:(G2TimeSheetEntryObject *)entryObject;
-(void)handleSaveNewTimeEntryResponse:(id)response;
-(void)sendRequestToFetchTimesheetByIdWithEntries:(NSString *)sheetIdentity;
-(void)handleTimesheetByIdentityResponse:(id)response;
-(void)sendRequestToSyncOfflineEditedEntriesForSheet:(NSMutableArray *)entryObjects sheetId:(NSString *)sheetIdentity
											delegate: (id)_delegate;
-(void)sendRequestToSyncOfflineCreatedEntriesForSheet:(NSMutableArray *)entryObjects sheetId:(NSString *)sheetIdentity
											delegate: (id)_delegate;
-(void)sendRequestToFetchSheetsExistanceInfo;
-(void)showErrorAlert:(NSError *) error;
-(void)handleSyncOfflineCreatedEntriesResponse :(id)response;
-(void)handleSyncOfflineEditedEntriesResponse :(id)response;
-(void)handleTimesheetUDFSettingsResponse : (id)response;
-(void)handleUserActivitiesResponse:(NSMutableArray *)activitiesArray;
-(void)sendRequestToGetProjectsAndClients;
-(void)handleProjectsAndClientsResponse: (id)response;
-(void)sendRequestToDeleteTimeEntry:(NSString *)identity sheetIdentity:(NSString *)_sheetIdentity;
-(void)handleDeleteTimeEntryResponse:(id)response :(id)otherParams;
-(void)sendRequestToGetModifiedTimeSheetsFromLastUpdatedDate :(NSDate *)lastUpdatedDate;
-(void)handleModifiedTimesheetsResponse:(NSMutableArray *)modifiedEntryTimesheetResponseArr;
-(void)handleExistedTimesheetsResponse:(id)response;
-(void)sendTimeSheetRequestToFetchSheetLevelUDFsWithPermissionSet:(NSMutableArray *)_permissionSet;
-(void) fetchClientsAndProject;
-(void)sendRequestToFetchTimeSheetByDate:(NSDate *)date;

@property(nonatomic, strong) G2TimesheetModel *timesheetModel;
-(void)handlePunchClockGetTimesheetFromApiResponse:(id)response;

-(void)handleUpdateDisclaimerAcceptanceTimesheetResponse: (id)response ;
-(void) sendRequestToUpdateDisclaimerAcceptanceDate: (NSString *)sheetIdentity disclaimerAcceptanceDate:(NSDate *)disclaimerAcceptanceDate;
-(void)handleTimesheetByIdentityResponseForUpdatedAcceptanceDisclaimer:(id)response;
-(BOOL)checkForPermissionExistence:(NSString *)_permission;
-(void)sendRequestToAddNewTimeEntryWithObjectForNewInOutTimesheets:(NSMutableArray *)entryObjectArray ;
-(void)sendRequestToEditTheTimeEntryDetailsWithUserDataForNewInOutTimesheets:(NSMutableArray *)_timeEntryObjectArray;
-(void)handleNewInOutTimesheetResponse:(id)response ;
-(void) getTimeOffFromApiAndAddTimeEntry:(G2TimeOffEntryObject *)entryObj;
-(void)handleGetTimeOffFromApiResponse:(id)response;
-(void)sendRequestToAddNewTimeOffWithObject:(G2TimeOffEntryObject *)entryObject ;
-(void)handleSaveNewTimeOffEntryResponse:(id)response;
-(void)sendRequestToEditTheTimeOffEntryDetailsWithUserData:(G2TimeOffEntryObject *)_timeOffEntryObject;
-(void)handleEditedTimeOffEntryResponse:(id)response;
-(void)sendRequestToDeleteTimeOffEntry:(NSString *)identity sheetIdentity:(NSString *)_sheetIdentity;
-(void)handleDeleteTimeOffEntryResponse:(id)response :(id)otherParamsDict;
//US4591//Juhi
-(void)fetchTimeOffUDFs;
//US4591//Juhi
-(void)sendTimeSheetRequestToFetchTimeOffLevelUDFs;
-(void) fetchTimeSheetUSerDataForDate:(id)_delegate andDate:(NSDate *)date;
//US4754
//US4660//Juhi
-(void) reopenTimesheetWithIdentity:(NSString *)sheetIdentity comments:(NSString *)comments;
-(void)handleReopenTimesheetResponse: (id)response;
-(void)sendRequestToGetAllClients;
-(void)handleClientsResponse: (id)response;
-(void)sendRequestToGetAllProjectsByClientID:(NSString *)clientID;
-(void)handleProjectsResponse: (id)response;
-(void)sendRequestToGetAllBillingOptionsByClientID:(NSString *)clientID;
-(void)handleTimeSheetsUserBillingResponse: (id)response;
-(void)sendRequestTogetTimesheetProjectswithProjectIds:(NSMutableArray *)projectIdsArr;
-(void)handleRecentTimeSheetsProjectsResponse: (id)response;
-(void)sendRequestToFetchBookedTimeOffForUserwithStartDate:(NSDictionary *)_startDateDict
                                               withEndDate:(NSDictionary *)_endDateDict;
-(void)sendRequestForMergedTimesheetAPIWithDelegate:(id)delegate;
-(void)handleTimesheetMergedResponseWithObject:(NSArray *)responseArray;
-(void)handlePermissionBasedTimesheetUDFsResponse:(NSMutableArray *)udfsResponseArray;
-(void)sendRequestToFetchBookedTimeOffForUserForNextRecentTimesheets:(NSMutableArray *)valueArray;
@end
