//
//  ApprovalsService.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/23/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2BaseService.h"
#import "G2ApprovalsModel.h"

@interface G2ApprovalsService : G2BaseService
{
    G2ApprovalsModel *approvalsModel;
	
    int totalRequestsSent;
	int totalRequestsServed;
    NSMutableArray *userIDArray;
    NSMutableArray *filterUsersForPermissions;
    NSMutableArray *filterUsersForPreferences;
}
@property(nonatomic,strong) NSMutableArray *userIDArray;
@property(nonatomic,strong)    NSMutableArray *filterUsersForPermissions;
@property(nonatomic,strong)     NSMutableArray *filterUsersForPreferences;
@property(nonatomic,assign) int totalRequestsSent;
@property(nonatomic,assign) int totalRequestsServed;

-(void)handleTimeSheetsResponse:(id)response;
-(void)handleTimeSheetsEntriesResponse:(id)response;
-(void)sendRequestToFetchAllPendingTimesheetsForApprovals;
-(void)sendRequestToGetModifiedPendingApprovalsTimeSheetsFromLastUpdatedDate:(NSDate *)lastUpdatedDate;
-(void) fetchPendingApprovalsTimeSheetData:(id)_delegate;
- (void) serverDidRespondWithResponse:(id) response;
- (void) serverDidFailWithError:(NSError *) error;
-(void)showErrorAlert:(NSError *) error;
-(void) updateApprovalsLastUpdateTime;
-(void)handleModifiedTimesheetsResponse:(id)response ;
-(void)sendRequestToFetchSheetsExistanceInfo;
-(void)sendRequestToFetchBookedTimeOffForUserForSheetId:(NSString *)_sheetIdentity 
										  withStartDate:(NSDictionary *)_startDateDict 
											withEndDate:(NSDictionary *)_endDateDict;
-(void)sendRequestToFetchBookedTimeOffForUser;
-(void)handleBookedTimeOffResponse:(id)response forSheetId:(NSString *)_sheetId;
-(void)handleExistedTimesheetsResponse:(id)response;
-(void)sendRequestToGetProjectsAndClientsforUserID:(NSArray *)userIdArr;
-(void)sendRequestToGetUserActivitiesforUserID:(NSArray *)userIdArr;
-(void)sendTimeSheetRequestToFetchSheetLevelUDFsWithPermissionSet;
-(void)sendRequestToFetchAllPendingTimesheetsEntriesForApprovals;
-(void) fetchPendingApprovalsTimeSheetEntriesData:(id)_delegate;
-(void) approveTimesheetWithComments: (NSArray *)sheetIdentityArr comments:(NSString *)comments;
-(void) rejectTimesheetWithComments: (NSArray *)sheetIdentityArr comments:(NSString *)comments;
-(void)handleRejectedTimesheetResponse: (id)response;
-(void)handleApprovedTimesheetResponse: (id)response;
-(void)sendRequestToLoadUser;
-(void) fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentity:(NSString *)sheeetIdentity andDelegate:(id)_delegate;
-(void)sendRequestToFetchAllPendingTimesheetsEntriesForApprovalsBySheetIdentity:(NSString *)sheetIdentity;
-(void)handleUserDownloadContent:(id)response;
-(void)handlePermissionBasedTimesheetUDFsResponse:(id)response;
-(void)sendRequestToFetchNextRecentPendingTimesheetsWithStartIndex:(NSNumber*)_startIndex withLimitCount:(NSNumber*)limitedCount withQueryHandler:(NSString *)handleIdentity withDelegate:(id)delegate;
-(void) fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentityWithUserpermissionsAndPreferencesAndUdf:(NSString *)sheeetIdentity andUserIdentity:(NSString *)userIdentity withDelegate:(id)_delegate;
-(void)handleMergedApprovalsAPIResponse:(id)response;
-(void)handleNextRecentApprovalTimesheets:(id)response;
-(void)updateApprovalsSupportDataLastUpdateTime;
@end
