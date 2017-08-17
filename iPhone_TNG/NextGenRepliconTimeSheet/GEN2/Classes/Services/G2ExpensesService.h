//
//  ExpensesService.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2BaseService.h"
#import "G2ServiceUtil.h"
#import "G2RequestBuilder.h"
#import "G2AppProperties.h"
#import "JsonWrapper.h"
#import "G2Util.h"
#import"G2SupportDataModel.h"
#import "G2ExpensesModel.h"
@interface G2ExpensesService : G2BaseService {
	
	G2ExpensesModel		*expensesModel;
	G2SupportDataModel *supportDataModel;
}

-(void)sendRequestToGetExpensesByUserWithDelegate:(id)delegate;
-(void)sendRequestToGetExpenseTypesByProjects:(id)delegate;
-(void)sendRequestToGetExpenseClients:(id)delegate;
-(void)sendRequestToGetExpenseProjects:(id)delegate;
-(void)sendRequestToGetExpenseProjectsByClient:(id)client_ID withDelegate:(id)delegate;
-(void)sendRequestToGetExpenseTypeAll:(id)delegate;
-(void)sendRequestToUnsubmitExpenseSheetWithID:(NSString *)sheet_ID withDelegate:(id)delegate;
//US2669//Juhi
//-(void)sendRequestToSubmitExpenseSheetWithID:(NSString *)sheet_ID withDelegate:(id)delegate;
-(void)sendRequestToSubmitExpenseSheetWithID:(NSString *)sheet_ID  comments:(NSString *)comments withDelegate:(id)delegate;

-(void)sendRequestToGetExpenseById:(NSString *)sheet_ID withDelegate:(id)delegate;
-(void)sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:(NSString *)queryType WithDomain:(NSString *)domainType withProjectIDs:(NSMutableArray *)projectIds WithDelegate:(id)delegate;
-(void)sendRequestToGetRecieptImages:(NSString*)idSheet _delegate:(id)delegate;
-(void)sendRequestToUploadReceiptImage:(NSDictionary *)_dict withDelegate:(id)delegate;
-(void)sendRequestToSaveNewExpenseWithReciept:(NSDictionary *)dict withDelegate:(id)delegate;
-(void)sendRequestToDeleteExpenseSheetWithIdentity:(NSString *)sheetID WithDelegate:(id)delegate;
//-(void)sendRequestToGetMostRecentExpenseSheets:(NSNumber *)limitedCount WithDelegate:(id)delegate;
-(void)sendRequestToGetMostRecentExpenseSheets:(NSNumber*)limitedCount :(NSNumber*)startIndex WithDelegate:(id)delegate;
-(void)sendRequestToFetchNextRecentExpenseSheets:(NSString *)handleIdentity withStartIndex:(NSNumber*)_startIndex withLimitCount:(NSNumber*)limitedCount withDelegate:(id)delegate;
-(void)sendRequestToDeleteExpenseReceiptForExpenseSheetID:(NSString*)sheetId forEntryId:(NSString*)entryId;
-(void)sendRequestToCreateNewExpenseSheet:(NSDictionary *)expenseDict delegate:(id)_delegate;
-(void)sendRequestToCreateNewExpenseEntry:(NSDictionary *)expenseDict delegate:(id)_delegate;
-(void)sendRequestToEditEntryForSheet: (NSMutableArray *)entries sheetId: (NSString *)_sheetId delegate: (id)_delegate;
-(void)sendRequestToSyncOfflineCreatedEntriesForSheet: (NSMutableArray *)entries sheetId: (NSString *)_sheetId delegate: (id)_delegate;
-(void) sendRequestToDeleteExpenseEntriesForSheet: (NSMutableArray *)entries sheetId: (NSString *)_sheetId delegate: (id)_delegate;
-(void)sendRequestToGetApproversForUnsubmittedExpenseSheet:(NSString*)sheetIdentity delegate:(id)_delegate;
-(void)sendRequestToGetRemainingApproversForSubmittedExpenseSheetWithId:(NSString*)sheetIdentity delegate:(id)_delegate;
-(void)sendRequestToAddNewExpenseWithUserEnteredData:(NSDictionary*)entryDict withDelegate:(id)_delegate;//exppe
-(void)sendRequestToGetRecieptForSelectedExpense:(id)expenseIdentity delegate:(id)_delegate;
-(void)sendRequestToSyncOfflineCreatedSheet:(NSMutableDictionary *)sheetInfoDict delegate:(id)_delegate; 
-(void)sendRequestTogetExpenseProjectsWithProjectRelatedClients:(id)delegate withProjectIds:(NSMutableArray *)projectIdsArr;
-(void)sendRequestTogetExpenseSheetInfo:(NSString *)sheetIdentity :(id)delegate;

-(void) fetchExpenseSheetData;
-(void) processExpenseByUserResponse: (NSMutableArray *)response;
-(void)handlesExpenseProjectTypesWithTaxsResponse:(id)response;
-(void)handleExpenseByUserResponse:(id) response;
-(void)handlesExpenseAllTypesWithTaxsResponse:(id)response;
-(void)handleExpenseClientsResponse:(id)response;
-(void)handleExpenseProjectsResponse:(id)response;
-(void)handleExpenseProjectsResponseForRecent:(id)response;
-(void)handleExpenseProjectsByClientID:(NSString*)clientID  withResponse:(id)response;
-(void)handleTaxCodeAllResponse:(id)response;
-(void)handleSystemPayMethodsResponse:(id) response;
-(void)handleSystemCurrenciesResponse:(id) response;
-(void)handleBaseCurrenciesResponse:(id) response;
-(void)handleNextRecentExpenseSheetsResponse:(id)response;
-(void)handleUDFSettingsResponse:(id)response;
-(void)showListOfExpenseSheets;
-(void)handleModifiedSheetsResponse:(id)response;
-(void)handleExistedSheetsResponse:(id)responseArray;
//...........
-(void)terminateService;
-(void)sendRequestToFetchExpensesSupportData;
-(void)addObserverForExpensesAction;
-(void)removeObserverForExpensesAction;
-(void)sendRequestToGetModifiedExpenseSheetsFromDate:(NSDate*)lastUpdatedDate withDelegate:(id)delegate;
-(void)requestModifiedSheetsFromLastSuccessfulDownloadDate:(NSDate*)lastUpdatedDate;
-(void)sendRequsetWithTimeOutValue:(int)timeOutVal;
-(void)sendRequestForExistedSheets:(id)delegate;
-(void)showErrorAlert:(NSError *) error;
-(void)sendRequestToGetExpenseTypesByIds:(NSArray *)expenseIdsArr WithDelegate:(id)delegate;
-(void)handlesExpenseTypesIDResponse:(id)response;
-(void)downloadExpenseTypesByProjectSelectionwithId:(NSString *)projectIdentity;
-(void)sendRequestForMergedExpenseAPIWithDelegate:(id)delegate;
-(void)handleExpenseMergedResponseWithObject:(NSArray *)responseArray;

@end
