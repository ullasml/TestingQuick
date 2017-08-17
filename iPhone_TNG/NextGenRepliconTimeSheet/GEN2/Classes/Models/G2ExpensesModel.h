//
//  ExpensesModel.h
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2SQLiteDB.h"
#import "G2Util.h"
#import"G2Constants.h"

@interface G2ExpensesModel : NSObject {
	double offlineIdentity;
	
}
-(void)insertExpenseSheetsInToDataBase:(NSArray *) expensesArray;
-(void)insertExpenseEntriesInToDataBase:(NSArray *) expensesArray;
-(void)insertExpenseClientsInToDatabase:(NSArray *) clientsArray;
-(void)insertExpenseProjectsByClient:(NSArray*)projectsToClientArray clientID:(NSString*)clientId;
-(NSMutableArray *)getExpenseSheetsFromDataBase;
-(NSMutableArray *)getExpenseEntriesFromDatabase;
-(NSMutableArray *)getExpenseClientsFromDatabase;
-(NSMutableArray *)getExpenseProjectsFromDatabase;
-(NSMutableArray *)getExpenseTypesWithTaxCodesFromDatabase;
-(NSMutableArray *) getExpenseTypesWithTaxCodesForSelectedProjectId:(NSString *) identity ;
-(void)insertExpenseProjectsInToDatabase:(NSMutableArray *) projectsArray withBoolValue:(BOOL)forRecent;
-(NSMutableArray*)getEntriesforSelected:(NSInteger)selectedIndex  WithExpenseSheetArr:(NSArray *)expArray;
-(NSMutableArray *)getCurrenciesInfoForExpenseSheetID:(NSString *)_expenseSheetID;
-(NSMutableArray *)getExpenseProjectsForSelectedClientID:(NSString*)_clientIdentity;
-(void)insertExpenseNonProjectSpecificTypesWithTaxCodesInToDatabase:(NSArray *) expenseTypeArray;
-(void)insertExpenseProjectSpecificTypesWithTaxCodesInToDatabase:(NSArray *) response;
-(void)updateExpenseSheetsById:(NSString*)_expenseSheetID response:(NSArray *) expensesArray;
-(NSMutableArray *)getExpenseClientsForProjectSpecificFromDatabase;
-(void)deleteExpenseSheetFromDB:(NSString*)sheetId;
-(void)saveExpenseSheetToDataBaseWithDictionary:(NSDictionary *)expenseSheetDict;
-(double)getHourlyRateFromDBWithProjectId:(NSString*)projectId withTypeName:(NSString*)typeName;
-(NSMutableArray *)getExpenseSheetInfoForSheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray*)getExpenseEntryInfoForIdentity:(NSString *)identity;
-(BOOL)isApprovedExpenseSheetsAvailable;
-(NSMutableArray*)insertApprovalsDetailsIntoDbForUnsubmittedSheet:(NSArray*)responseArray;
- (void)saveNewExpenseEntryToDataBase:(NSDictionary *)expenseEntryDict;
-(NSMutableArray *)getModifiedExpenseSheets;
-(NSMutableArray *)getEntriesForExpenseSheet:(NSString *)sheetId;
-(NSMutableArray *) getOfflineCreatedEntriesForSheet: (NSString *) sheetId ;
-(NSMutableArray *) getOfflineEditedEntriesForSheet: (NSString *) sheetId;
-(NSMutableArray *) getOfflineDeletedEntriesForSheet: (NSString *) sheetId;
- (NSString *) getCurrencyIdentityForSymbol: (NSString *) symbol;
- (void) resetSheetsModifyStatus: (NSString *)sheetId;
- (void) removeOfflineCreatedEntries: (NSString *)sheetId;
- (void) removeOfflineDeletedEntries: (NSString *)sheetId;
- (void) saveUdfsForExpenseEntry : (NSMutableArray *)udfsArray :(NSString *)entryIdentity :(NSString *)entryType;
- (void) updateUdfsForExpenseEntry : (NSMutableArray *)udfsArray :(NSString *)entryIdentity :(NSString *)entryType;
-(NSMutableArray *)getUDFsForSelectedEntry:(id)entryId;
-(void) saveExpenseEntryInToDataBase:(NSDictionary *)expenseEntryDict;
-(void) insertUdfsforEntryIntoDatabase:(NSMutableArray *)expensesArray;
-(NSMutableArray *)getReceiptInfoForSelectedExpense:(id)responseArr;
- (NSMutableArray *) getExpenseTypesToSaveWithEntryForSelectedProjectId:(NSString*) identity withType:(NSString*)typeName;
-(NSMutableArray *)getExpensePaymentMethodId:(NSString *)paymentName;
-(NSMutableArray *)getPaymentMethodIdFromDefaultPayments:(NSString *)paymentName;
-(void)updateExpenseById:(NSMutableDictionary *)expenseDictionary;
-(NSMutableArray *)getClientIdentityForClientName:(NSString *)clientName;
-(NSMutableArray *)getProjectIdentityForProjectName:(NSString *)projectName;

-(NSString *) getUDFIdForName:(NSString *)udfName;
-(NSMutableArray *) getUDFDetailsForId:(NSString *)udfId;
-(NSString *) getUDFTypeForId:(NSString *)udfId;
-(NSMutableDictionary *) getSelectedUdfsForEntry:(NSString *)entryId andType:(NSString*)entryType;
-(NSMutableArray *)getExpenseTypeIdentityForExpenseName:(NSString *)expenseName;
-(void)updateUDFsForEditedExpense:(NSMutableArray *)userDefinedFields entryID:(NSString *)entryId entryType:(NSString *)entrytype;
-(void) updateExpenseSheetModifyStatus:(NSNumber *)sheetStatus : (NSString *)sheetId;
-(void)deleteExpenseEntryFromDatabase:(NSString*)expenseIdentity;
-(void)deleteExpenseEntryInOffline:(NSString *)expenseIdentity sheetId:(NSString *)expenseSheetIdentity;
-(NSMutableArray*)fetchSumOfAmountsForEachCurrencyTypeWithSheetId:(NSString*)sheetId;
-(NSMutableArray*)getEntryAmountsForExpenseSheet:(NSString*)sheetId forDescOrder:(BOOL)descendingOrder;
-(void) updateExpenseSheetStatus:(NSString *)sheetStatus :(NSString *)sheetId;
-(NSMutableArray*)getClientsForBucketProjects:(NSString*)projectId;
-(void) updateReimbursmentCurrencyForExpenseSheet:(NSString *)currencySymbol : (NSString *)sheetId;
-(BOOL)checkUDFExistsForEntry:(NSString *)udfIdentity : (NSString *)entryId;

-(NSMutableArray *)getSelectedExpenseSheetInfoFromDb:(NSString*)sheetIdentity;
-(double)getRateForEntryWhereEntryId:(NSString*)entryId;
-(void)updateExpenseSheetTotalReimbursementAmount:(NSString *)totalAmount sheetId:(NSString *)_sheetIdentity;
-(NSMutableArray *)getLastEntryAddedForSheet:(NSString *)_expenseSheetId;
-(NSMutableArray *)getExpenseProjectIdentitiesFromDatabase;
-(NSMutableArray*)getAllSheetIdentitiesFromDB;
-(void)removeWtsDeletedSheetsFromDB:(id)responseArray;
//De4433//Juhi
- (NSMutableArray *) getExpenseTypesWithTaxCodesForNonProject;
-(NSMutableArray *)getAllProjectsforDownloadedExpenseEntries;
-(NSMutableArray *)getAllClientsforDownloadedExpenseEntries;
- (void)insertExpenseTypesWithTaxCodesInToDatabase:(NSArray *) expenseTypeArray;
- (void) updateQueryHandleByClientId:(NSString*)clientId andQueryHandle:(NSString *)queryHandle  andStartIndex:(NSString *)startIndex;
-(NSDictionary *)fetchQueryHandlerAndStartIndexForClientID:(NSString *)clientId;
- (NSMutableArray *) getExpenseTypesWithEntryForSelectedProjectId:(NSString*)identity forTypeIdentity:(NSString*)typeIdentity;
-(void)updateRecentProjectsColumnForIdentity:(NSString *)projectIdentity;
-(NSMutableArray *)getRecentExpenseProjectsForSelectedClientID:(NSString*)_clientIdentity;

-(NSMutableArray*)getExpenseEntryInfoForSheetIdentityIdentity:(NSString *)sheetDdentity;
@end
