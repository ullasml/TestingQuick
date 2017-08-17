//
//  ExpenseModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 25/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import "Constants.h"

@interface ExpenseModel : NSObject{
    
}

-(void)saveExpenseSheetDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)saveExpenseEntryDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)saveExpenseIncurredAmountTaxDataToDBForExpenseEntryUri:(NSString *)expenseEntryUri dataArray:(NSMutableArray *)array;
-(void)saveClientDetailsDataToDB:(NSMutableArray *)array;
-(void)saveProjectDetailsDataToDB:(NSMutableArray *)array;
-(void)saveSystemCurrenciesDataToDatabase:(NSArray *) currencyArray;
-(void)saveSystemPaymentMethodsDataToDatabase:(NSArray *) paymentMethodsArray;
-(void)saveExpenseCodesDataToDatabase:(NSArray *) expenseCodesArray;
-(void)saveExpenseCodeDetailsDataFromApiToDB:(NSMutableDictionary *)responseDict;
-(void)saveExpenseCodeDetailsResponseToDB:(NSMutableDictionary *)responseDict;

-(NSArray *)getExpenseSheetInfoSheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray *) getAllExpenseSheetsFromDB;
-(NSArray*)getExpenseInfoForExpenseEntryUri:(NSString*)expenseEntryUri expenseSheetUri:(NSString *)expenseSheetUri;
-(NSArray*)getTaxCodeInfoForExpenseEntryUri:(NSString*)expenseEntryUri taxCodeUri:(NSString *)taxCodeUri;
-(NSArray *)getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:(NSString *)expenseSheetUri;
-(NSArray *)getAllTaxCodeFromDBForExpenseEntryUri:(NSString *)expenseEntryUri;
-(NSMutableArray *)getClientDetailsFromDBForClientUri:(NSString *)clientUri andModuleName:(NSString*)moduleName;
-(NSMutableArray *)getProjectDetailsFromDBForProjectUri:(NSString *)projectUri andModuleName:(NSString*)moduleName;
-(NSMutableArray *)getAllClientsDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getAllProjectsDetailsFromDBForModule:(NSString *)moduleName;
-(NSMutableArray *)getSystemCurrenciesFromDatabase;
-(NSMutableArray*)getSystemPaymentMethodFromDatabase;
-(NSMutableArray*)getExpenseCodesFromDatabase;
-(NSArray *)getAllDetailsForExpenseCodeFromDB;
-(NSMutableArray *)getAllExpenseTaxCodesFromDB;
-(NSMutableArray *)getAllExpenseEntriesFromDBExceptEntryWithUri:(NSString *)expenseEntryUri ForExpenseSheetUri:(NSString *)expenseSheetUri;
-(void)deleteAllExpenseSheetsFromDB;
-(void)deleteAllClientsInfoFromDBForModuleName:(NSString *)moduleName;
-(void)deleteAllProjectsInfoFromDBForModuleName:(NSString *)moduleName;
-(void)deleteAllExpenseCodesFromDB;
-(NSArray *)getExpensesInfoForSheetIdentity:(NSString *)sheetIdentity;
-(void)saveExpenseApprovalDetailsDataToDatabase:(NSArray *) expenseDetailsArray;
-(NSMutableArray*)getAllApprovalHistoryForExpenseSheetUri:(NSString *)expenseSheetUri;
-(void)deleteExpenseSheetFromDBForSheetUri:(NSString *)sheetURI;
-(NSString*)getSystemCurrencyUriFromDBForCurrencyName:(NSString*)currencyName;
-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI;
-(NSArray *)getExpenseCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri;
-(NSArray *)getExpenseCustomFieldsForExpenseSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri;
-(NSMutableArray *)getAllSystemCurrencyUriFromDB;
-(NSArray *)getExpenseEntryInfoForSheetIdentity:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryURI;
-(NSArray *)getAllPendingExpenseTaxCodesFromDBForEntryUri:(NSString *)entryUri;
-(NSArray *)getAllDetailsForExpenseCodeFromDBForEntryUri:(NSString *)entryUri;
-(NSArray *)getAllTaxCodeUriEntryDetailsFromDBForExpenseEntryUri:(NSString *)expenseEntryUri andExpenseCodeUri:(NSString *)expenseEntryCodeUri;//Fix for defect DE18775//JUHI
-(NSArray *)getExpenseTaxCodesFromDBForTaxCodeUri:(NSString *)taxCodeUri;
//implemented as per US8689//JUHI
-(void)deleteAllSystemCurrencyFromDB;
-(void)deleteAllSystemPaymentMethodFromDB;
-(NSMutableArray *)getAllDisclaimerDetailsFromDBForModule:(NSString *)moduleName;//Implementation as per US9172//JUHI
@end
