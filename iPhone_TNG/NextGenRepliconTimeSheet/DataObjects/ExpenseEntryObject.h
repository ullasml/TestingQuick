//
//  ExpenseEntryObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExpenseEntryObject : NSObject

{
    NSString    *expenseEntryDescription;
    NSString    *expenseEntryApprovalStatus;
    NSString    *expenseEntryBillingUri;
    NSString    *expenseEntryExpenseCodeName;
    NSString    *expenseEntryExpenseCodeUri;
    NSString    *expenseEntryExpenseEntryUri;
    NSString    *expenseEntryExpenseReceiptName;
    NSString    *expenseEntryExpenseReceiptUri;
    NSString    *expenseEntryExpenseSheetUri;
    NSString    *expenseEntryIncurredAmountNet;
    NSString    *expenseEntryIncurredAmountNetCurrencyName;
    NSString    *expenseEntryIncurredAmountNetCurrencyUri;
    NSString    *expenseEntryIncurredAmountTotal;
    NSString    *expenseEntryIncurredAmountTotalCurrencyName;
    NSString    *expenseEntryIncurredAmountTotalCurrencyUri;
    NSDate      *expenseEntryIncurredDate;
    NSString    *expenseEntryPaymentMethodName;
    NSString    *expenseEntryPaymentMethodUri;
    NSString    *expenseEntryProjectName;
    NSString    *expenseEntryProjectUri;
    NSString    *expenseEntryQuantity;
    NSString    *expenseEntryRateAmount;
    NSString    *expenseEntryRateCurrencyName;
    NSString    *expenseEntryRateCurrencyUri;
    NSString    *expenseEntryReimbursementUri;
    NSString    *expenseEntryTaskName;
    NSString    *expenseEntryTaskUri;
    NSString    *expenseEntryBaseCurrency;
    NSString    *receiptImageData;
    NSMutableArray     *expenseEntryIncurredTaxesArray;
    NSMutableArray     *expenseEntryUdfArray;

}

@property (nonatomic,strong) NSString *expenseEntryDescription;
@property (nonatomic,strong) NSString *expenseEntryApprovalStatus;
@property (nonatomic,strong) NSString *expenseEntryBillingUri;
@property (nonatomic,strong) NSString *expenseEntryExpenseCodeName;
@property (nonatomic,strong) NSString *expenseEntryExpenseCodeUri;
@property (nonatomic,strong) NSString *expenseEntryExpenseEntryUri;
@property (nonatomic,strong) NSString *expenseEntryExpenseReceiptName;
@property (nonatomic,strong) NSString *expenseEntryExpenseReceiptUri;
@property (nonatomic,strong) NSString *expenseEntryExpenseSheetUri;
@property (nonatomic,strong) NSString *expenseEntryIncurredAmountNet;
@property (nonatomic,strong) NSString *expenseEntryIncurredAmountNetCurrencyName;
@property (nonatomic,strong) NSString *expenseEntryIncurredAmountNetCurrencyUri;
@property (nonatomic,strong) NSString *expenseEntryIncurredAmountTotal;
@property (nonatomic,strong) NSString *expenseEntryIncurredAmountTotalCurrencyName;
@property (nonatomic,strong) NSString *expenseEntryIncurredAmountTotalCurrencyUri;
@property (nonatomic,strong) NSDate   *expenseEntryIncurredDate;
@property (nonatomic,strong) NSString *expenseEntryPaymentMethodName;
@property (nonatomic,strong) NSString *expenseEntryPaymentMethodUri;
@property (nonatomic,strong) NSString *expenseEntryProjectName;
@property (nonatomic,strong) NSString *expenseEntryProjectUri;
@property (nonatomic,strong) NSString *expenseEntryQuantity;
@property (nonatomic,strong) NSString *expenseEntryRateAmount;
@property (nonatomic,strong) NSString *expenseEntryRateCurrencyName;
@property (nonatomic,strong) NSString *expenseEntryRateCurrencyUri;
@property (nonatomic,strong) NSString *expenseEntryReimbursementUri;
@property (nonatomic,strong) NSString *expenseEntryTaskName;
@property (nonatomic,strong) NSString *expenseEntryTaskUri;
@property (nonatomic,strong) NSString *expenseEntryClientName;
@property (nonatomic,strong) NSString *expenseEntryClientUri;
@property (nonatomic,strong) NSString *expenseEntryBaseCurrency;
@property (nonatomic,strong) NSString *receiptImageData;
@property (nonatomic,strong) NSMutableArray  *expenseEntryIncurredTaxesArray;
@property (nonatomic,strong) NSMutableArray  *expenseEntryUdfArray;
@property (nonatomic, assign) BOOL displayBillToClient;
@property (nonatomic, assign) BOOL disableBillToClient;

@end
