//
//  ExpenseService.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 22/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
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
#import "ExpenseModel.h"
#import "SpinnerDelegate.h"

@interface ExpenseService : BaseService
{
	unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;
    id __weak newTimeEntryDelegate;
    ExpenseModel *expenseModel;
}

@property(nonatomic, strong) ExpenseModel *expenseModel;
@property(nonatomic, assign) BOOL didSuccessfullyFetchExpenses;

-(void)fetchExpenseSheetData:(id)_delegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (id)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate;

-(void)fetchNextExpenseSheetData:(id)_delegate;
-(void)fetchExpenseEntryDataForExpenseSheet:(NSString *)expenseSheetUri withDelegate:(id)_delegate;
-(void)fetchExpenseCurrencyAndPaymentMethodDatawithDelegate:(id)_delegate;
-(void)fetchFirstClientsAndProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withClientSearchText:(NSString *)clientText withProjectSearchText:(NSString *)projectText andDelegate:(id)delegate;
-(void)fetchFirstClientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextClientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchProjectsBasedOnclientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchNextProjectsBasedOnclientsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchExpenseCodesBasedOnProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate;
-(void)fetchExpenseCodesDetailsForExpenseCodeURI:(NSString *)expenseCodeURI andSheetUri:(NSString *)sheetUri andProjectUri:(NSString *)projectUri;

-(void)handleExpenseSheetsFetchData:(id)response;
-(void)handleNextRecentExpenseSheetsFetchData:(id)response;
-(void)handleExpenseEntryFetchData:(id)response;
-(void)handleExpenseCurrencyAndPaymentMethodFetchData:(id)response;
-(void)handleClientsAndProjectsDownload:(id)response;
-(void)handleNextClientsDownload:(id)response;
-(void)handleNextProjectsDownload:(id)response;
-(void)handleProjectsBasedOnClientsResponse:(id)response;
-(void)handleNextProjectsBasedOnClientDownload:(id)response;
-(void)handleExpenseCodesFetchData:(id)response;
-(void)sendRequestToUnsubmitExpensesDataForExpenseURI:(NSString *)expensesURI withComments:(NSString *)comments withDelegate:(id)delegate;
-(void)handleExpensesSubmitData:(id)response;
-(void)handleExpensesUnsubmitData:(id)response;
-(void)sendRequestToGetRecieptForSelectedExpense:(id)expenseIdentity delegate:(id)_delegate;
-(void)sendRequestToDeleteExpensesSheetForExpenseURI:(NSString *)expensesURI;
-(void)handleExpensesDeleteData:(id)response;
-(void)handleExpenseCodesDetailsFetchData:(id)response;
-(void)sendRequestToCreateNewExpensesDataForExpenseURIForExpenseSheetDict:(NSDictionary *)newExpenseSheetDetailsDict withDelegate:(id)delegate;
-(void)sendRequestToSaveExpenseSheetForExpenseSheetDict:(NSMutableDictionary *)expenseSheetDetailsDict withExpenseEntriesArray:(NSMutableArray *)expenseEntriesArray withDelegate:(id)delegate isProjectAllowed:(BOOL)isProjectAllowed isProjectRequired:(BOOL)isProjectRequired isDisclaimerAccepted:(BOOL)isDisclaimerAccepted isExpenseSubmit:(BOOL)isExpenseSubmit withComments:(NSString *)comments;//Implementation as per US9172//JUHI
-(void)fetchExpenseSheetUpdateData:(id)_delegate;
-(void)fetchNextExpenseCodesBasedOnProjectsForExpenseSheetUri:(NSString *)expenseSheetUri withSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate;

- (void) serverDidRespondWithResponse:(id) response;
@end
