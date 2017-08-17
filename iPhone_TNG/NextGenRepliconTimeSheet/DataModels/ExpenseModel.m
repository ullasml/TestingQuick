//
//  ExpenseModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 25/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ExpenseModel.h"
#import "AppDelegate.h"
#import "LoginModel.h"
#import "SupportDataModel.h"

static NSString *expenseSheetsTable=@"ExpenseSheets";
static NSString *expenseEntriesTable = @"ExpenseEntries";
static NSString *expenseIncurredAmountTaxTable = @"ExpenseIncurredAmountTax";
static NSString *clientsTable=@"Clients";
static NSString *projectsTable=@"Projects";
static NSString *systemCurrenciesTable=@"SystemCurrencies";
static NSString *systemPaymentMethodsTable=@"SystemPaymentMethods";
static NSString *expenseCodesTable=@"ExpenseCodes";
static NSString *expenseApprovalHistoryTable=@"ExpenseSheetApprovalHistory";
static NSString *expenseTaxcodesTable=@"ExpenseTaxCodes";
static NSString *expenseCodeDetailsTable=@"ExpenseCodeDetails";
static NSString *expenseCustomFieldsTable=@"ExpenseCustomFields";
static NSString *expensePendingTaxCodesTable=@"PendingExpenseTaxCodes";
static NSString *expensePendingCodeDetailsTable=@"PendingExpenseCodeDetails";
static NSString *disclaimerTable=@"Disclaimer";
#define FLAT_TAX_URI @"urn:replicon:expense-type:flat-amount"
#define RATE_TAX_URI @"urn:replicon:expense-type:variable-rate"
@implementation ExpenseModel
#pragma mark -
#pragma mark Nextgen Methods

-(void)saveExpenseSheetDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
    NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
     //Implementation of ExpenseSheetLastModified
    if (rowsArray!=nil &&![rowsArray isKindOfClass:[NSNull class]])
    {
    for (int i=0; i<[rowsArray count]; i++)
    {
        NSString *expenseURI=@"";
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
        for (int k=0; k<[array count]; k++)
        {
            
            NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
            NSMutableArray *columnUriArray=nil;
            columnUriArray=[[AppProperties getInstance] getExpenseSheetColumnURIFromPlist];
            NSString *refrenceHeader=nil;
            for (int i=0; i<[columnUriArray count]; i++)
            {
                NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                NSString *uri=[columnDict objectForKey:@"uri"];
                
                if ([refrenceHeaderUri isEqualToString:uri])
                {
                    refrenceHeader=[columnDict objectForKey:@"name"];
                    break;
                }
            }
            NSMutableDictionary *responseDict=[array objectAtIndex:k];
            
            if ([refrenceHeader isEqualToString:@"Date"])
            {
               
                NSDictionary *expenseDateDict=[responseDict objectForKey:@"dateValue"];
                NSDate *expenseDate=[Util convertApiDateDictToDateFormat:expenseDateDict];
                NSNumber *expenseDateToStore=[NSNumber numberWithDouble:[expenseDate timeIntervalSince1970]];
                if (expenseDateToStore!=nil && ![expenseDateToStore isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:expenseDateToStore forKey:@"expenseDate"];
                }
            
                
            }
            else if ([refrenceHeader isEqualToString:@"Description"])
            {
                NSString *descriptionStr=[responseDict objectForKey:@"textValue"];
                if (descriptionStr!=nil && ![descriptionStr isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:descriptionStr forKey:@"description"];
                }
                
            }
            else if ([refrenceHeader isEqualToString:@"Reimbursement Amount"])
            {
                NSString *reimbursementAmt=[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"amount"];
               
                NSString *currencyName=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"displayText"];
                 NSString *currencyUri=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"uri"];
                if (reimbursementAmt!=nil && ![reimbursementAmt isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:reimbursementAmt forKey:@"reimbursementAmount"];
                }
                if (currencyName!=nil && ![currencyName isKindOfClass:[NSNull class]])
                {
                     [dataDict setObject:currencyName forKey:@"reimbursementAmountCurrencyName"];
                }
                if (currencyUri!=nil && ![currencyUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyUri forKey:@"reimbursementAmountCurrencyUri"];
                }
                
                
            }
            else if([refrenceHeader isEqualToString:@"Incurred Amount"]){
                NSString *reimbursementAmt=[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"amount"];
                
                NSString *currencyName=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *currencyUri=[[[[responseDict objectForKey:@"moneyValue"]objectForKey:@"baseCurrencyValue"] objectForKey:@"currency"] objectForKey:@"uri"];
                if (reimbursementAmt!=nil && ![reimbursementAmt isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:reimbursementAmt forKey:@"incurredAmount"];
                }
                if (currencyName!=nil && ![currencyName isKindOfClass:[NSNull class]])
                {
                     [dataDict setObject:currencyName forKey:@"incurredAmountCurrencyName"];
                }
                if (currencyUri!=nil && ![currencyUri isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:currencyUri forKey:@"incurredAmountCurrencyUri"];
                }
                
            }
            
            else if ([refrenceHeader isEqualToString:@"Approval Status"])
            {
                NSString *statusStr=[responseDict objectForKey:@"uri"];
                if (statusStr!=nil && ![statusStr isKindOfClass:[NSNull class]])
                {
		    if ([statusStr isEqualToString:APPROVED_STATUS_URI])
                    {
                        [dataDict setObject:APPROVED_STATUS forKey:@"approvalStatus"];
                    }
                    else if ([statusStr isEqualToString:NOT_SUBMITTED_STATUS_URI])
                    {
                        [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus"];
                    }
                    else if ([statusStr isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
                    {
                        [dataDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus"];
                    }
                    else if ([statusStr isEqualToString:REJECTED_STATUS_URI])
                    {
                        [dataDict setObject:REJECTED_STATUS forKey:@"approvalStatus"];
                    }
                    else
                    {
                        [dataDict setObject:[NSNull null] forKey:@"approvalStatus"];
                    }
                }

                
            }
            
            else if ([refrenceHeader isEqualToString:@"Expense"])
            {
                expenseURI=[responseDict objectForKey:@"uri"];
                if (expenseURI!=nil && ![expenseURI isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:expenseURI      forKey:@"expenseSheetUri"];
                }
                
                
            }
            else if ([refrenceHeader isEqualToString:@"Tracking Number"])
            {
                NSString*trackingNumber=[responseDict objectForKey:@"textValue"];
                if (trackingNumber!=nil && ![trackingNumber isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:trackingNumber      forKey:@"trackingNumber"];
                }
                
                
            }
            

        }
        NSArray *expArr = [self getExpenseSheetInfoSheetIdentity:expenseURI];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@'",expenseURI];
                [myDB deleteFromTable:expenseSheetsTable where:whereString inDatabase:@""];
        }
      
            [myDB insertIntoTable:expenseSheetsTable data:dataDict intoDatabase:@""];
        
        
    }
    
  }  
}
-(void)saveExpenseEntryDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    
    NSMutableDictionary *expenseEntryDetailsDict=[responseDict objectForKey:@"details"];
    NSString *expenseSheetUri=[expenseEntryDetailsDict objectForKey:@"uri"];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereStr=[NSString stringWithFormat:@"expenseSheetUri= '%@' ",expenseSheetUri];
    [myDB deleteFromTable:expenseEntriesTable where:whereStr inDatabase:@""];
    
    NSString*status=[[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"displayText"];
    NSString *statusUri =[[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"];
    
    //Implementation as per US9172//JUHI
     int isNoticeExplicitlyAccepted=0;
    NSMutableDictionary *disclaimerDict=[NSMutableDictionary dictionary];
    if (![expenseEntryDetailsDict isKindOfClass:[NSNull class]] && expenseEntryDetailsDict!=nil) {
        disclaimerDict=[expenseEntryDetailsDict objectForKey:@"expenseSheetNotice"];
        
        if ([[expenseEntryDetailsDict objectForKey:@"noticeExplicitlyAccepted"] boolValue] == YES )
        {
            isNoticeExplicitlyAccepted = 1;
        }
        
    }
    if (![disclaimerDict isKindOfClass:[NSNull class]] && disclaimerDict!=nil )
    {
        [self saveExpenseDisclaimerDataToDB:disclaimerDict];
    }
    NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri = '%@'",expenseSheetUri];
    [myDB deleteFromTable:expenseCustomFieldsTable where:whereString inDatabase:@""];
    
    
    NSMutableArray *expenseEntryArray=[expenseEntryDetailsDict objectForKey:@"entries"];
    
    if (expenseEntryArray != nil && expenseEntryArray != (id)[NSNull null]) {
        for (int i=0;i<[expenseEntryArray count]; i++)
        {
            
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSDictionary *dict=[expenseEntryArray objectAtIndex:i];
            NSString *expenseEntryUri=[dict objectForKey:@"uri"];
            
            NSNumber *displayBillToClient = [dict objectForKey:@"displayBillToClient"];
            NSNumber  *disableBillToClient = [dict objectForKey:@"disableBillToClient"];
            [dataDict setObject:disableBillToClient!=nil && disableBillToClient!=(id)[NSNull null] ? disableBillToClient:@0 forKey:@"disableBillToClient"];
            [dataDict setObject:displayBillToClient!=nil && displayBillToClient!=(id)[NSNull null] ? displayBillToClient:@1 forKey:@"displayBillToClient"];
            
            if (status!=nil)
            {
                [dataDict setObject:status forKey:@"approvalStatus"];
            }
            [dataDict setObject:expenseSheetUri forKey:@"expenseSheetUri"];
            
            
            NSString *desc=[dict objectForKey:@"description"];
            NSString *expenseBillingOptionUri=[dict objectForKey:@"expenseBillingOptionUri"];
            
            [dataDict setObject:desc forKey:@"expenseEntryDescription"];
            [dataDict setObject:expenseBillingOptionUri forKey:@"billingUri"];
            
            if ([dict objectForKey:@"expenseCode"]!=nil &&![[dict objectForKey:@"expenseCode"]isKindOfClass:[NSNull class]]) {
                NSString *expenseCodeName=[[dict objectForKey:@"expenseCode"] objectForKey:@"displayText"];
                NSString *expenseCodeUri=[[dict objectForKey:@"expenseCode"] objectForKey:@"uri"];
                [dataDict setObject:expenseCodeName forKey:@"expenseCodeName"];
                [dataDict setObject:expenseCodeUri forKey:@"expenseCodeUri"];
                
            }
            
            if ([dict objectForKey:@"expenseReceipt"]!=nil &&![[dict objectForKey:@"expenseReceipt"]isKindOfClass:[NSNull class]])
            {
                NSString *expenseReceiptName=[[dict objectForKey:@"expenseReceipt"]objectForKey:@"displayText"];
                NSString *expenseReceiptUri=[[dict objectForKey:@"expenseReceipt"]objectForKey:@"uri"];
                [dataDict setObject:expenseReceiptName forKey:@"expenseReceiptName"];
                [dataDict setObject:expenseReceiptUri forKey:@"expenseReceiptUri"];
                
                
            }
            NSString *expenseReimbursementOptionUri=[dict objectForKey:@"expenseReimbursementOptionUri"];
            [dataDict setObject:expenseReimbursementOptionUri forKey:@"reimbursementUri"];
            
            if ([dict objectForKey:@"incurredAmountNet"]!=nil && ![[dict objectForKey:@"incurredAmountNet"]isKindOfClass:[NSNull class]])
            {
                NSString *netAmount=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"amount"]  stringValue];
                NSString *netCurrencyName=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *netCurrencyUri=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"uri"];
                
                [dataDict setObject:netAmount forKey:@"incurredAmountNet"];
                [dataDict setObject:netCurrencyName forKey:@"incurredAmountNetCurrencyName"];
                [dataDict setObject:netCurrencyUri forKey:@"incurredAmountNetCurrencyUri"];
                
            }
            
            if ([dict objectForKey:@"incurredAmountTaxes"]!=nil&& ![[dict objectForKey:@"incurredAmountTaxes"]isKindOfClass:[NSNull class]])
            {
                
                NSMutableArray *array=[dict objectForKey:@"incurredAmountTaxes"];
                for (int i=0; i<[array count]; i++)
                {
                    NSDictionary *taxAmountDict=[[array objectAtIndex:i] objectForKey:@"amount"];
                    NSDictionary *taxCodeDict=[[array objectAtIndex:i] objectForKey:@"taxCode"];
                    NSString *taxAmount=[taxAmountDict objectForKey:@"amount"];
                    NSString *taxCurrencyName=[[taxAmountDict objectForKey:@"currency"] objectForKey:@"name"];
                    NSString *taxCurrencyUri=[[taxAmountDict objectForKey:@"currency"] objectForKey:@"uri"];
                    NSString *taxCodeUri=[taxCodeDict objectForKey:@"uri"] ;
                    
                    [dataDict setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",i+1]];
                    [dataDict setObject:taxCurrencyName forKey:[NSString stringWithFormat:@"taxCurrencyName%d",i+1]];
                    [dataDict setObject:taxCurrencyUri forKey:[NSString stringWithFormat:@"taxCurrencyUri%d",i+1]];
                    [dataDict setObject:taxCodeUri forKey:[NSString stringWithFormat:@"taxCodeUri%d",i+1]];
                }
                [self saveExpenseIncurredAmountTaxDataToDBForExpenseEntryUri:expenseEntryUri dataArray:array];
                
            }
            if ([dict objectForKey:@"incurredAmountGross"]!=nil && ![[dict objectForKey:@"incurredAmountGross"]isKindOfClass:[NSNull class]])
            {
                NSString *totalAmount=[[dict objectForKey:@"incurredAmountGross"] objectForKey:@"amount"];
                NSString *totalCurrencyName=[[[dict objectForKey:@"incurredAmountGross"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *totalCurrencyUri=[[[dict objectForKey:@"incurredAmountGross"] objectForKey:@"currency"] objectForKey:@"uri"];
                
                [dataDict setObject:totalAmount forKey:@"incurredAmountTotal"];
                [dataDict setObject:totalCurrencyName forKey:@"incurredAmountTotalCurrencyName"];
                [dataDict setObject:totalCurrencyUri forKey:@"incurredAmountTotalCurrencyUri"];
                
            }
            NSDictionary *expenseDateDict=[dict objectForKey:@"incurredDate"];
            NSDate *expenseDate=[Util convertApiDateDictToDateFormat:expenseDateDict];
            NSNumber *expenseDateToStore=[NSNumber numberWithDouble:[expenseDate timeIntervalSince1970]];
            [dataDict setObject:expenseDateToStore forKey:@"incurredDate"];
            
            if ([dict objectForKey:@"paymentMethod"]!=nil && ![[dict objectForKey:@"paymentMethod"]isKindOfClass:[NSNull class]])
            {
                NSString *paymentMethodName=[[dict objectForKey:@"paymentMethod"] objectForKey:@"displayText"];
                NSString *paymentMethodUri=[[dict objectForKey:@"paymentMethod"] objectForKey:@"uri"];
                [dataDict setObject:paymentMethodName forKey:@"paymentMethodName"];
                [dataDict setObject:paymentMethodUri forKey:@"paymentMethodUri"];
            }
            if ([dict objectForKey:@"client"]!=nil && ![[dict objectForKey:@"client"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:dict[@"client"][@"uri"] forKey:@"clientUri"];
                [dataDict setObject:dict[@"client"][@"displayText"] forKey:@"clientName"];
            }
            if ([dict objectForKey:@"project"]!=nil && ![[dict objectForKey:@"project"]isKindOfClass:[NSNull class]])
            {
                NSString *projectName=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
                NSString *projectUri=[[dict objectForKey:@"project"] objectForKey:@"uri"];
                [dataDict setObject:projectName forKey:@"projectName"];
                [dataDict setObject:projectUri forKey:@"projectUri"];
                
            }
            if ([dict objectForKey:@"quantity"]!=nil && ![[dict objectForKey:@"quantity"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:[dict objectForKey:@"quantity"] forKey:@"quantity"];
            }
            if ([dict objectForKey:@"rate"]!=nil && ![[dict objectForKey:@"rate"]isKindOfClass:[NSNull class]])
            {
                NSString *rateAmount=[[dict objectForKey:@"rate"] objectForKey:@"amount"] ;
                NSString *rateCurrencyName=[[[dict objectForKey:@"rate"] objectForKey:@"currency"] objectForKey:@"displayText"];
                NSString *rateCurrencyUri=[[[dict objectForKey:@"rate"]objectForKey:@"currency"] objectForKey:@"uri"];
                
                [dataDict setObject:rateAmount forKey:@"rateAmount"];
                [dataDict setObject:rateCurrencyName forKey:@"rateCurrencyName"];
                [dataDict setObject:rateCurrencyUri forKey:@"rateCurrencyUri"];
                
            }
            if ([dict objectForKey:@"quantity"]!=nil && ![[dict objectForKey:@"quantity"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:[dict objectForKey:@"quantity"] forKey:@"quantity"];
            }
            
            if ([dict objectForKey:@"task"]!=nil && ![[dict objectForKey:@"task"]isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:dict[@"task"][@"uri"] forKey:@"taskUri"];
                [dataDict setObject:dict[@"task"][@"displayText"] forKey:@"taskName"];
            }
            
            [dataDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
            [dataDict setObject:[NSNumber numberWithInt:isNoticeExplicitlyAccepted]forKey:@"noticeExplicitlyAccepted"];//Implementation as per US9172//JUHI
            NSArray *customFieldsArray=[dict objectForKey:@"customFields"];
            [self saveCustomFieldswithData:customFieldsArray forSheetURI:expenseSheetUri andModuleName:EXPENSES_UDF andEntryURI:expenseEntryUri];
            
            NSArray *array=[self getExpenseInfoForExpenseEntryUri:expenseEntryUri expenseSheetUri:expenseSheetUri];
            if ([array count]>0)
            {
                NSString *whereString=[NSString stringWithFormat:@"expenseEntryUri = '%@'",expenseEntryUri];
                [myDB updateTable: expenseEntriesTable data:dataDict where:whereString intoDatabase:@""];
            }
            else
            {
                [myDB insertIntoTable:expenseEntriesTable data:dataDict intoDatabase:@""];
            }
            [self deletePendingExpenseTaxCodeInfoForEntryUri:expenseEntryUri];
            [self deletePendingExpenseCodeInfoForEntryUri:expenseEntryUri];
            NSMutableArray *taxAmountArray=[NSMutableArray array];
            if ([statusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI]||[statusUri isEqualToString:APPROVED_STATUS_URI])
            {
                NSMutableDictionary *pendingTaxAmountDict=[NSMutableDictionary dictionary];
                NSMutableDictionary *pendingExpenseCodeDetailsDict=[NSMutableDictionary dictionary];
                NSMutableArray *incurredAmountTaxesArray=[dict objectForKey:@"incurredAmountTaxes"];
                for (int m=0; m<[incurredAmountTaxesArray count]; m++)
                {
                    NSDictionary *tmpDict=[incurredAmountTaxesArray objectAtIndex:m];
                    NSString *tmpTaxAmount=[[tmpDict objectForKey:@"amount"] objectForKey:@"amount"];
                    NSString *tmpTaxName=[[tmpDict objectForKey:@"taxCode"] objectForKey:@"name"];
                    NSString *tmpTaxUri=[[tmpDict objectForKey:@"taxCode"] objectForKey:@"uri"];
                    NSNumber *uniqueId=[NSNumber numberWithInt:m+1];
                    
                    [pendingTaxAmountDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
                    [pendingTaxAmountDict setObject:tmpTaxName forKey:@"name"];
                    [pendingTaxAmountDict setObject:tmpTaxUri forKey:@"uri"];
                    [pendingTaxAmountDict setObject:tmpTaxAmount forKey:@"taxAmount"];
                    [pendingTaxAmountDict setObject:uniqueId forKey:@"id"];
                    
                    [myDB insertIntoTable:expensePendingTaxCodesTable data:pendingTaxAmountDict intoDatabase:@""];
                    
                    [taxAmountArray addObject:tmpTaxAmount];
                    
                }
                
                
                NSString *expenseCodeName=[[dict objectForKey:@"expenseCode"] objectForKey:@"name"];
                NSString *expenseCodeUri=[[dict objectForKey:@"expenseCode"] objectForKey:@"uri"];
                NSString *expenseQuantity=[NSString stringWithFormat:@"%@",[dict objectForKey:@"quantity"]];
                NSString *expenseRate=nil;
                if ([dict objectForKey:@"rate"]!=nil && ![[dict objectForKey:@"rate"] isKindOfClass:[NSNull class]])
                {
                    expenseRate=[NSString stringWithFormat:@"%@",[[dict objectForKey:@"rate"]objectForKey:@"amount"]];
                }
                
                
                NSString *expenseCodeCurrencyName=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"symbol"];
                NSString *expenseCodeCurrencyUri=[[[dict objectForKey:@"incurredAmountNet"] objectForKey:@"currency"] objectForKey:@"uri"];
                
                NSString *expenseType=nil;
                
                if (expenseQuantity!=nil && expenseRate!=nil
                    &&![expenseQuantity isKindOfClass:[NSNull class]]&& ![expenseRate isKindOfClass:[NSNull class]]
                    &&![expenseQuantity isEqualToString:@""]&&![expenseRate isEqualToString:@""]
                    &&![expenseQuantity isEqualToString:NULL_STRING]&&![expenseRate isEqualToString:NULL_STRING])
                {
                    if ([incurredAmountTaxesArray count]>0 && incurredAmountTaxesArray!=nil)
                    {
                        expenseType=Rated_With_Taxes;
                    }
                    else
                    {
                        expenseType=Rated_WithOut_Taxes;
                    }
                }
                else
                {
                    if ([incurredAmountTaxesArray count]>0 && incurredAmountTaxesArray!=nil)
                    {
                        expenseType=Flat_With_Taxes;
                    }
                    else
                    {
                        expenseType=Flat_WithOut_Taxes;
                    }
                    
                }
                id tmpExpenseRate=nil;
                if (expenseRate!=nil &&  ![expenseRate isKindOfClass:[NSNull class]]&& ![expenseRate isEqualToString:NULL_STRING])
                {
                    tmpExpenseRate=expenseRate;
                }
                else
                {
                    tmpExpenseRate=@"";
                }
                [pendingExpenseCodeDetailsDict setObject:expenseCodeName forKey:@"expenseCodeName"];
                [pendingExpenseCodeDetailsDict setObject:expenseCodeUri forKey:@"expenseCodeUri"];
                [pendingExpenseCodeDetailsDict setObject:expenseType forKey:@"expenseCodeType"];
                [pendingExpenseCodeDetailsDict setObject:@"Quantity" forKey:@"expenseCodeUnitName"];
                [pendingExpenseCodeDetailsDict setObject:tmpExpenseRate forKey:@"expenseCodeRate"];
                [pendingExpenseCodeDetailsDict setObject:expenseCodeCurrencyUri forKey:@"expenseCodeCurrencyUri"];
                [pendingExpenseCodeDetailsDict setObject:expenseCodeCurrencyName forKey:@"expenseCodeCurrencyName"];
                [pendingExpenseCodeDetailsDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
                
                for (int k=0; k<[taxAmountArray count]; k++)
                {
                    NSString *taxAmount=[taxAmountArray objectAtIndex:k];
                    [pendingExpenseCodeDetailsDict setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",k+1]];
                }
                
                
                [myDB insertIntoTable:expensePendingCodeDetailsTable data:pendingExpenseCodeDetailsDict intoDatabase:@""];
                
            }
            
            
        }
    }
    
    NSArray *expArr = [self getExpenseSheetInfoSheetIdentity:expenseSheetUri];
    if ([expArr count]>0)
    {
        NSMutableDictionary *expensheetDict=[NSMutableDictionary dictionaryWithDictionary:[expArr objectAtIndex:0]];
        NSMutableDictionary *incurredAmountTotalDict=[expenseEntryDetailsDict objectForKey:@"incurredAmountTotal"];
        if (incurredAmountTotalDict!=nil)
        {
            NSString *incurredAmount=[Util getRoundedValueFromDecimalPlaces:[[incurredAmountTotalDict objectForKey:@"amount"] newDoubleValue]withDecimalPlaces:2];
            NSString *incurredAmountCurrencyName=[[incurredAmountTotalDict objectForKey:@"currency"] objectForKey:@"displayText"];
            NSString *incurredAmountCurrencyUri=[[incurredAmountTotalDict objectForKey:@"currency"] objectForKey:@"uri"];
            
            [expensheetDict removeObjectForKey:@"incurredAmount"];
            [expensheetDict removeObjectForKey:@"incurredAmountCurrencyName"];
            [expensheetDict removeObjectForKey:@"incurredAmountCurrencyUri"];
           
            [expensheetDict setObject:incurredAmount forKey:@"incurredAmount"];
            [expensheetDict setObject:incurredAmountCurrencyName forKey:@"incurredAmountCurrencyName"];
            [expensheetDict setObject:incurredAmountCurrencyUri forKey:@"incurredAmountCurrencyUri"];
            
            
            
            
        }
        
        NSDictionary *reimbursementAmountTotalDict=[expenseEntryDetailsDict objectForKey:@"reimbursementAmountTotal"];
        if (reimbursementAmountTotalDict!=nil)
        {
            NSString *reimbursementAmount=[Util getRoundedValueFromDecimalPlaces:[[reimbursementAmountTotalDict objectForKey:@"amount"] newDoubleValue]withDecimalPlaces:2];;
            NSString *reimbursementAmountCurrencyName=[[reimbursementAmountTotalDict objectForKey:@"currency"] objectForKey:@"displayText"];
            NSString *reimbursementAmountCurrencyUri=[[reimbursementAmountTotalDict objectForKey:@"currency"] objectForKey:@"uri"];
            
            [expensheetDict removeObjectForKey:@"reimbursementAmount"];
            [expensheetDict removeObjectForKey:@"reimbursementAmountCurrencyName"];
            [expensheetDict removeObjectForKey:@"reimbursementAmountCurrencyUri"];
            
            [expensheetDict setObject:reimbursementAmount forKey:@"reimbursementAmount"];
            [expensheetDict setObject:reimbursementAmountCurrencyName forKey:@"reimbursementAmountCurrencyName"];
            [expensheetDict setObject:reimbursementAmountCurrencyUri forKey:@"reimbursementAmountCurrencyUri"];
            
        }
        NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri='%@'",expenseSheetUri];
        [myDB updateTable: expenseSheetsTable data:expensheetDict where:whereString intoDatabase:@""];
    }
    
    
    NSMutableDictionary *expensesPermittedApprovalActions=[responseDict objectForKey:@"permittedApprovalActions"];
    if (![expensesPermittedApprovalActions isKindOfClass:[NSNull class]] && expensesPermittedApprovalActions!=nil )
    {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        if (![expenseSheetUri isKindOfClass:[NSNull class]] && expenseSheetUri!=nil )
        {
            [expensesPermittedApprovalActions setObject:expenseSheetUri forKey:@"uri"];
        }
        [supportModel saveExpensePermittedApprovalActionsDataToDB:expensesPermittedApprovalActions];
        
    }
    
    
    NSArray *approvalDetailsArray=[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"entries"];
    NSMutableArray *approvalDtlsDataArray=[NSMutableArray array];
    
    for (NSDictionary *dict in approvalDetailsArray)
    {
        //Implementation for MOBI-261//JUHI
        NSString *actingForUser=nil;
        NSString *actingUser=nil;
        NSString *comments=nil;
        NSMutableDictionary *approvalDetailDataDict=[NSMutableDictionary dictionary];
        [approvalDetailDataDict setObject:expenseSheetUri forKey:@"expenseSheetUri"];
        
        NSString *action=[[dict objectForKey:@"action"]objectForKey:@"uri"];
        //Implementation for MOBI-261//JUHI
        if ([dict objectForKey:@"timestamp"]!=nil && ![[dict objectForKey:@"timestamp"] isKindOfClass:[NSNull class]])
        {
            NSDate *entryDate=[Util convertApiDateDictToDateTimeFormat:[dict objectForKey:@"timestamp"]];
            NSNumber *entryDateToStore=[NSNumber numberWithDouble:[entryDate timeIntervalSince1970]];
            [approvalDetailDataDict setObject:entryDateToStore forKey:@"timestamp"];
            
        }
       
        if ([dict objectForKey:@"authority"]!=nil && ![[dict objectForKey:@"authority"] isKindOfClass:[NSNull class]])
        {
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingForUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingForUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingForUser"] objectForKey:@"displayText"];
                }
                
            }
            if ([[dict objectForKey:@"authority"] objectForKey:@"actingUser"]!=nil && ![[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] isKindOfClass:[NSNull class]])
            {
                if ([[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"]!=nil && ![[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"] isKindOfClass:[NSNull class]])
                {
                    actingUser=[[[dict objectForKey:@"authority"] objectForKey:@"actingUser"] objectForKey:@"displayText"];
                }
                
            }
        }
        if ([dict objectForKey:@"comments"]!=nil && ![[dict objectForKey:@"comments"] isKindOfClass:[NSNull class]])
        {
            comments=[dict objectForKey:@"comments"];
        }
        
        //Implementation for MOBI-261//JUHI
        if (actingForUser!=nil)
        {
            [approvalDetailDataDict setObject:actingForUser                      forKey:@"actingForUser"];
        }
        if (comments!=nil)
        {
            [approvalDetailDataDict setObject:comments                      forKey:@"comments"];
        }
        if (actingUser!=nil)
        {
            [approvalDetailDataDict setObject:actingUser                      forKey:@"actingUser"];
        }
        
       
         [approvalDetailDataDict setObject:action forKey:@"actionUri"];
         
        
        [approvalDtlsDataArray addObject:approvalDetailDataDict];
    }
    
    [self saveExpenseApprovalDetailsDataToDatabase:approvalDtlsDataArray];

}

-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI
{
    for (int i=0; i<[sheetCustomFieldsArray count]; i++)
    {
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        NSDictionary *udfDict=[sheetCustomFieldsArray objectAtIndex:i];
        NSString *name=[[udfDict objectForKey:@"customField"]objectForKey:@"displayText"];
        if (name!=nil && ![name isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:name forKey:@"udf_name"];
        }
        NSString *uri=[[udfDict objectForKey:@"customField"]objectForKey:@"uri"];
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:uri forKey:@"udf_uri"];
        }
        NSString *type=[[udfDict objectForKey:@"customFieldType"]objectForKey:@"uri"];
        if (type!=nil && ![type isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:type forKey:@"entry_type"];
            
            if ([type isEqualToString:DROPDOWN_UDF_TYPE])
            {
                NSString *dropDownOptionURI=[udfDict objectForKey:@"dropDownOption"];
                if (dropDownOptionURI!=nil && ![dropDownOptionURI isKindOfClass:[NSNull class]])
                {
                    [udfDataDict setObject:dropDownOptionURI forKey:@"dropDownOptionURI"];
                }
            }
        }
        
        if (entryURI!=nil && ![entryURI isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:entryURI forKey:@"entryUri"];
        }
        
        NSString *value=[udfDict objectForKey:@"text"];
        if ([type isEqualToString:DATE_UDF_TYPE])
        {
            NSString *tmpValue=[udfDict objectForKey:@"date"];
            if (tmpValue!=nil && ![tmpValue isKindOfClass:[NSNull class]])
            {
                value=[Util convertApiTimeDictToDateStringWithDesiredFormat:[udfDict objectForKey:@"date"]];//DE18243 DE18690 DE18728 Ullas M L
            }
        }
        if (value!=nil && ![value isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:value forKey:@"udfValue"];
        }
        
        if (sheetUri!=nil && ![sheetUri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:sheetUri forKey:@"expenseSheetUri"];
        }
        
        if (moduleName!=nil && ![moduleName isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:moduleName forKey:@"moduleName"];
        }
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSArray *udfsArr = [self getExpenseCustomFieldsForSheetURI:sheetUri moduleName:moduleName entryURI:entryURI andUdfURI:uri];
        if ([udfsArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",sheetUri,moduleName,entryURI,uri];
            [myDB updateTable:expenseCustomFieldsTable data:udfDataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:expenseCustomFieldsTable data:udfDataDict intoDatabase:@""];
        }
        
        
    }
}

-(void)saveExpenseIncurredAmountTaxDataToDBForExpenseEntryUri:(NSString *)expenseEntryUri dataArray:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
  
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        NSString *taxAmount=[[dict objectForKey:@"amount"] objectForKey:@"amount"];
        NSString *taxCurrencyName=[[[dict objectForKey:@"amount"] objectForKey:@"currency"] objectForKey:@"displayText"];
        NSString *taxCurrencyUri=[[[dict objectForKey:@"amount"] objectForKey:@"currency"] objectForKey:@"uri"];
        
        NSString *taxcodeName=[[dict  objectForKey:@"taxCode"] objectForKey:@"displayText"];
        NSString *taxcodeUri=[[dict  objectForKey:@"taxCode"] objectForKey:@"uri"];
        
        [dataDict setObject:taxAmount forKey:@"amount"];
        [dataDict setObject:taxCurrencyName forKey:@"currencyName"];
        [dataDict setObject:taxCurrencyUri forKey:@"currencyUri"];
        
        [dataDict setObject:taxcodeName forKey:@"taxCodeName"];
        [dataDict setObject:taxcodeUri forKey:@"taxCodeUri"];
        [dataDict setObject:expenseEntryUri forKey:@"expenseEntryUri"];
        
        NSArray *array=[self getTaxCodeInfoForExpenseEntryUri:expenseEntryUri taxCodeUri:taxcodeUri];
        if ([array count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"expenseEntryUri = '%@'",expenseEntryUri];
            [myDB updateTable: expenseIncurredAmountTaxTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:expenseIncurredAmountTaxTable data:dataDict intoDatabase:@""];
        }

        
    }
        
}
-(void)saveClientDetailsDataToDB:(NSMutableArray *)array
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array count]; i++)
    {
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSString *clientName=[dict objectForKey:@"displayText"];
        NSString *clientUri=[dict objectForKey:@"uri"];
        NSString *client_Name=[dict objectForKey:@"name"];//Implementation for US8849//JUHI
        
        NSString *moduleName=ExpenseModuleName;
        [dataDict setObject:clientName forKey:@"clientName"];
        [dataDict setObject:clientUri forKey:@"clientUri"];
        [dataDict setObject:moduleName forKey:@"moduleName"];
        
        [dataDict setObject:client_Name forKey:@"client_Name"];//Implementation for US8849//JUHI
        NSArray *expArr = [self getClientDetailsFromDBForClientUri:clientUri andModuleName:moduleName];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"clientUri='%@' and moduleName='%@'",clientUri,moduleName];
            [myDB updateTable: clientsTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:clientsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
    
    
}
-(void)saveProjectDetailsDataToDB:(NSMutableArray *)array
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    
    for (int i=0; i<[array count]; i++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        
        NSDictionary *dict=[array objectAtIndex:i];
        
        NSDictionary *clientInfoDict=[dict objectForKey:@"client"];
        NSString *clientName=@"";
        NSString *clientUri=@"";
        if (clientInfoDict!=nil && ![clientInfoDict isKindOfClass:[NSNull class]])
        {
            clientName=[clientInfoDict objectForKey:@"displayText"];
            clientUri=[clientInfoDict objectForKey:@"uri"];
        }
        
        NSString *projectName=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
        NSString *projectUri=[[dict objectForKey:@"project"] objectForKey:@"uri"];
        //Implementation for US8849//JUHI
        NSString *project_Name=nil;
        if ([[[dict objectForKey:@"project"] objectForKey:@"displayText"] isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)])
        {
            project_Name=[[dict objectForKey:@"project"] objectForKey:@"displayText"];
        }
        else
            project_Name=[[dict objectForKey:@"project"] objectForKey:@"name"];
        
        
        int hasTasksAvailableForExpenseEntry=0;
        
        
        NSString *moduleName=ExpenseModuleName;
        [dataDict setObject:clientName forKey:@"clientName"];
        [dataDict setObject:clientUri forKey:@"clientUri"];
        [dataDict setObject:projectName forKey:@"projectName"];
        [dataDict setObject:projectUri forKey:@"projectUri"];
        [dataDict setObject:project_Name forKey:@"project_Name"];//Implementation for US8849//JUHI
        [dataDict setObject:[NSNumber numberWithInt:hasTasksAvailableForExpenseEntry] forKey:@"hasTasksAvailableForTimeAllocation"];
        [dataDict setObject:moduleName forKey:@"moduleName"];
        
        NSArray *expArr = [self getProjectDetailsFromDBForProjectUri:projectUri andModuleName:moduleName];
        if ([expArr count]>0)
        {
            NSString *whereString=[NSString stringWithFormat:@"projectUri='%@' and moduleName='%@'",projectUri,moduleName];
            [myDB updateTable: projectsTable data:dataDict where:whereString intoDatabase:@""];
        }
        else
        {
            [myDB insertIntoTable:projectsTable data:dataDict intoDatabase:@""];
        }
        
        
    }
    
    
    
}
-(void)saveSystemCurrenciesDataToDatabase:(NSArray *) currencyArray{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *currencytDictionary=[NSMutableDictionary dictionary];
	
	
		[myDB deleteFromTable:systemCurrenciesTable inDatabase:@""];
	
	
	for (int i=0; i<[currencyArray count]; i++) {
		NSDictionary *dict=[currencyArray objectAtIndex:i];
        
        NSString *currencyName=[dict objectForKey:@"displayText"];
        NSString *currencyUri=[dict objectForKey:@"uri"];
		
        if (currencyName!=nil && ![currencyName isKindOfClass:[NSNull class]]) {
            [currencytDictionary setObject:currencyName forKey:@"currenciesName"];
        }
        if (currencyUri!=nil && ![currencyUri isKindOfClass:[NSNull class]]) {
            [currencytDictionary setObject:currencyUri forKey:@"currenciesUri"];
        }
		
		[myDB insertIntoTable:systemCurrenciesTable data:currencytDictionary intoDatabase:@""];
		
	}
	
}
-(void)saveSystemPaymentMethodsDataToDatabase:(NSArray *) paymentMethodsArray{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *paymentMethodsArrayDictionary=[NSMutableDictionary dictionary];
	
        [myDB deleteFromTable:systemPaymentMethodsTable inDatabase:@""];
	
	
	for (int i=0; i<[paymentMethodsArray count]; i++) {
		NSDictionary *dict=[paymentMethodsArray objectAtIndex:i];
        
        NSString *paymentMethodsName=[dict objectForKey:@"displayText"];
        NSString *paymentMethodsUri=[dict objectForKey:@"uri"];
		
        if (paymentMethodsName!=nil && ![paymentMethodsName isKindOfClass:[NSNull class]]) {
            [paymentMethodsArrayDictionary setObject:paymentMethodsName forKey:@"paymentMethodsName"];
        }
        if (paymentMethodsUri!=nil && ![paymentMethodsUri isKindOfClass:[NSNull class]]) {
            [paymentMethodsArrayDictionary setObject:paymentMethodsUri forKey:@"paymentMethodsUri"];
        }
		
		[myDB insertIntoTable:systemPaymentMethodsTable data:paymentMethodsArrayDictionary intoDatabase:@""];
		
	}
	
}
-(void)saveExpenseCodesDataToDatabase:(NSArray *) expenseCodesArray{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSMutableDictionary *expenseCodesArrayDictionary=[NSMutableDictionary dictionary];
	
	for (int i=0; i<[expenseCodesArray count]; i++) {
		NSDictionary *dict=[expenseCodesArray objectAtIndex:i];
        
        NSString *expenseCodesName=[dict objectForKey:@"displayText"];
        NSString *expenseCodesUri=[dict objectForKey:@"uri"];
		
        if (expenseCodesName!=nil && ![expenseCodesName isKindOfClass:[NSNull class]]) {
            [expenseCodesArrayDictionary setObject:expenseCodesName forKey:@"expenseCodeName"];
        }
        if (expenseCodesUri!=nil && ![expenseCodesUri isKindOfClass:[NSNull class]]) {
            [expenseCodesArrayDictionary setObject:expenseCodesUri forKey:@"expenseCodeUri"];
        }
		
		[myDB insertIntoTable:expenseCodesTable data:expenseCodesArrayDictionary intoDatabase:@""];
		
	}
	
}

-(void)saveExpenseApprovalDetailsDataToDatabase:(NSArray *) expenseDetailsArray{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	for (int i=0; i<[expenseDetailsArray count]; i++) {
		NSDictionary *dict=[expenseDetailsArray objectAtIndex:i];
		[myDB insertIntoTable:expenseApprovalHistoryTable data:dict intoDatabase:@""];
		
	}
	
}
-(void)saveExpenseCodeDetailsResponseToDB:(NSMutableDictionary *)responseDict
{
    [self deleteAllExpenseCodeDetailsFromDB];
    [self deleteAllExpenseCodeTaxCodesFromDB];
    NSMutableArray *expenseCodesArray=[responseDict objectForKey:@"applicableTaxes"];
    [self saveExpenseCodeTaxcodesDataFromApiToDB:expenseCodesArray];
    [self saveExpenseCodeDetailsDataFromApiToDB:responseDict];
    
}

-(void)saveExpenseCodeDetailsDataFromApiToDB:(NSMutableDictionary *)responseDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    NSMutableDictionary *expenseCodeDetailsDict=[NSMutableDictionary dictionary];
    NSDictionary *ratedExpenseTypeDict=[responseDict objectForKey:@"variableRateConfiguration"];
    NSString *expenseCodeRate=@"";
    NSString *expenseCodeCurrencyName=@"";
    NSString *expenseCodeCurrencyUri=@"";
    NSString *expenseCodeUnitName=@"";
    if (ratedExpenseTypeDict!=nil && ![ratedExpenseTypeDict isKindOfClass:[NSNull class]])
    {
        NSDictionary *rateDict=[responseDict objectForKey:@"variableRateConfiguration"];
        NSDictionary *currencyDict=[[rateDict objectForKey:@"amount"] objectForKey:@"currency"];
        expenseCodeRate= [[rateDict objectForKey:@"amount"] objectForKey:@"amount"];
        expenseCodeUnitName=[rateDict objectForKey:@"unitName"];
        expenseCodeCurrencyName=[currencyDict objectForKey:@"symbol"];
        expenseCodeCurrencyUri=[currencyDict objectForKey:@"uri"];
        
    }
    
    
    NSString *expenseCodeName=[responseDict objectForKey:@"name"];
    NSString *expenseCodeUri=[responseDict objectForKey:@"uri"];
    int isEnabled=[[responseDict objectForKey:@"isEnabled"] intValue];
    NSString *expenseCodeType=[responseDict objectForKey:@"expenseTypeUri"];
    
    
    
    if (expenseCodeName!=nil && ![expenseCodeName isKindOfClass:[NSNull class]])
    {
        [expenseCodeDetailsDict setObject:expenseCodeName forKey:@"expenseCodeName"];
    }
    else
    {
        [expenseCodeDetailsDict setObject:@"" forKey:@"expenseCodeName"];
    }
    if (expenseCodeUri!=nil && ![expenseCodeUri isKindOfClass:[NSNull class]])
    {
        [expenseCodeDetailsDict setObject:expenseCodeUri forKey:@"expenseCodeUri"];
    }
    else
    {
        [expenseCodeDetailsDict setObject:@"" forKey:@"expenseCodeUri"];
    }
    
    [expenseCodeDetailsDict setObject:[NSNumber numberWithInt:isEnabled] forKey:@"isEnabled"];
    
    if (expenseCodeUnitName!=nil && ![expenseCodeUnitName isKindOfClass:[NSNull class]])
    {
        [expenseCodeDetailsDict setObject:expenseCodeUnitName forKey:@"expenseCodeUnitName"];
    }
    else
    {
        [expenseCodeDetailsDict setObject:@"" forKey:@"expenseCodeUnitName"];
    }
    
    if (expenseCodeRate!=nil && ![expenseCodeRate isKindOfClass:[NSNull class]])
    {
        [expenseCodeDetailsDict setObject:expenseCodeRate forKey:@"expenseCodeRate"];
    }
    else
    {
        [expenseCodeDetailsDict setObject:@"" forKey:@"expenseCodeRate"];
    }
    
    if (expenseCodeCurrencyName!=nil && ![expenseCodeCurrencyName isKindOfClass:[NSNull class]])
    {
        [expenseCodeDetailsDict setObject:expenseCodeCurrencyName forKey:@"expenseCodeCurrencyName"];
    }
    else
    {
        [expenseCodeDetailsDict setObject:@"" forKey:@"expenseCodeCurrencyName"];
    }
    
    if (expenseCodeCurrencyUri!=nil && ![expenseCodeCurrencyUri isKindOfClass:[NSNull class]])
    {
        [expenseCodeDetailsDict setObject:expenseCodeCurrencyUri forKey:@"expenseCodeCurrencyUri"];
    }
    else
    {
        [expenseCodeDetailsDict setObject:@"" forKey:@"expenseCodeCurrencyUri"];
    }
    int maxTaxCodesAllowed=5;
    NSArray *taxcodesArray=[self getAllExpenseTaxCodesFromDB];
    for (int i=0; i<[taxcodesArray count]; i++)
    {
        NSString *idValue=[[[taxcodesArray objectAtIndex:i] objectForKey:@"id"] stringValue];
        NSString *keyValue=[NSString stringWithFormat:@"taxcode%d",[idValue intValue]];
        [expenseCodeDetailsDict setObject:idValue forKey:keyValue];
    }
    if ([taxcodesArray count]!=maxTaxCodesAllowed)
    {
        for (NSUInteger i=[taxcodesArray count]; i<maxTaxCodesAllowed; i++)
        {
            NSUInteger index = i+1;
            NSString *keyValue=[NSString stringWithFormat:@"taxcode%d",(int)index];
            [expenseCodeDetailsDict setObject:@"" forKey:keyValue];
        }
    }
    
    if (expenseCodeType!=nil && ![expenseCodeType isKindOfClass:[NSNull class]])
    {
        if ([expenseCodeType isEqualToString:FLAT_TAX_URI])
        {
            if ([taxcodesArray count]!=0)
            {
                expenseCodeType=Flat_With_Taxes;
            }
            else
            {
                expenseCodeType=Flat_WithOut_Taxes;
            }
        }
        else if ([expenseCodeType isEqualToString:RATE_TAX_URI])
        {
            if ([taxcodesArray count]!=0)
            {
                expenseCodeType=Rated_With_Taxes;
            }
            else
            {
                expenseCodeType=Rated_WithOut_Taxes;
            }

        }
        [expenseCodeDetailsDict setObject:expenseCodeType forKey:@"expenseCodeType"];
    }

    
    [myDB insertIntoTable:expenseCodeDetailsTable data:expenseCodeDetailsDict intoDatabase:@""];
}
-(void)saveExpenseCodeTaxcodesDataFromApiToDB:(NSArray *)expenseCodesArray
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	for (int i=0; i<[expenseCodesArray count]; i++)
    {
        NSMutableDictionary *taxCodeDict=[NSMutableDictionary dictionary];
		NSDictionary *dict=[expenseCodesArray objectAtIndex:i];
        NSString *formula=[[dict objectForKey:@"formula"] objectForKey:@"displayText"];
        NSString *taxcodeName=[[dict objectForKey:@"taxCode"] objectForKey:@"name"];
        NSString *taxcodeUri=[[dict objectForKey:@"taxCode"] objectForKey:@"uri"];
        NSNumber *uniqueId=[NSNumber numberWithInt:i+1];
		if (formula!=nil && ![formula isKindOfClass:[NSNull class]]) {
            [taxCodeDict setObject:formula forKey:@"formula"];
        }
        if (taxcodeName!=nil && ![taxcodeName isKindOfClass:[NSNull class]]) {
            [taxCodeDict setObject:taxcodeName forKey:@"name"];
        }
        if (taxcodeUri!=nil && ![taxcodeUri isKindOfClass:[NSNull class]]) {
            [taxCodeDict setObject:taxcodeUri forKey:@"uri"];
        }
        [taxCodeDict setObject:uniqueId forKey:@"id"];
        

		[myDB insertIntoTable:expenseTaxcodesTable data:taxCodeDict intoDatabase:@""];
		
	}
}
-(NSArray *)getAllDetailsForExpenseCodeFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",expenseCodeDetailsTable];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSMutableArray *)getAllExpenseTaxCodesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",expenseTaxcodesTable];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSArray *)getExpenseTaxCodesFromDBForTaxCodeUri:(NSString *)taxCodeUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where uri='%@'",expenseTaxcodesTable,taxCodeUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}


-(NSArray *)getExpenseSheetInfoSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' ",expenseSheetsTable,sheetIdentity];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSMutableArray *) getAllExpenseSheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by trackingNumber DESC",expenseSheetsTable];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}


-(NSArray *)getExpensesInfoForSheetIdentity:(NSString *)sheetIdentity
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' ",expenseSheetsTable,sheetIdentity];
	NSMutableArray *expensesArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expensesArr count]!=0) {
		return expensesArr;
	}
	return nil;
    
}

-(NSArray*)getExpenseInfoForExpenseEntryUri:(NSString*)expenseEntryUri expenseSheetUri:(NSString *)expenseSheetUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' and expenseSheetUri='%@'",expenseEntriesTable,expenseEntryUri,expenseSheetUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray*)getTaxCodeInfoForExpenseEntryUri:(NSString*)expenseEntryUri taxCodeUri:(NSString *)taxCodeUri{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' and expenseSheetUri='%@'",expenseIncurredAmountTaxTable,expenseEntryUri,taxCodeUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:(NSString *)expenseSheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' order by UPPER(expenseCodeName) asc,incurredDate desc,incurredAmountTotal desc",expenseEntriesTable,expenseSheetUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}//Fix for defect DE18775//JUHI
-(NSArray *)getAllTaxCodeUriEntryDetailsFromDBForExpenseEntryUri:(NSString *)expenseEntryUri andExpenseCodeUri:(NSString *)expenseEntryCodeUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select taxCodeUri1,taxCodeUri2,taxCodeUri3,taxCodeUri4,taxCodeUri5 from %@ where expenseEntryUri = '%@' and expenseCodeUri = '%@'",expenseEntriesTable,expenseEntryUri,expenseEntryCodeUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}

-(NSArray *)getAllTaxCodeFromDBForExpenseEntryUri:(NSString *)expenseEntryUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri = '%@' ",expenseIncurredAmountTaxTable,expenseEntryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSMutableArray *)getClientDetailsFromDBForClientUri:(NSString *)clientUri andModuleName:(NSString*)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientUri='%@' and moduleName='%@'",clientsTable,clientUri,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getProjectDetailsFromDBForProjectUri:(NSString *)projectUri andModuleName:(NSString*)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where projectUri='%@'and moduleName='%@'",projectsTable,projectUri,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllClientsDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",clientsTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getAllProjectsDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where moduleName='%@'",projectsTable,moduleName];
    
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
-(NSMutableArray *)getSystemCurrenciesFromDatabase{
	SQLiteDB *myDB  = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ ",systemCurrenciesTable];
	NSMutableArray *currencyArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if (currencyArr != nil && [currencyArr count]!=0) {
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"currenciesName" ascending:TRUE];
        [currencyArr sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
       
		
        return currencyArr;
	}
	return nil;
}
-(NSMutableArray*)getSystemPaymentMethodFromDatabase{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ ",systemPaymentMethodsTable];
	NSMutableArray *systemPreferencesArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if (systemPreferencesArr != nil && [systemPreferencesArr count]!=0) {
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"paymentMethodsName" ascending:TRUE];
        [systemPreferencesArr sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
		
        return systemPreferencesArr;
	}
	return nil;
}
-(NSMutableArray*)getExpenseCodesFromDatabase{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ ",expenseCodesTable];
	NSMutableArray *expenseCodesArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if (expenseCodesArr != nil && [expenseCodesArr count]!=0) {
       
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"expenseCodeName" ascending:TRUE];
        [expenseCodesArr sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
		
        return expenseCodesArr;
	}
	return nil;
}

-(NSMutableArray*)getAllApprovalHistoryForExpenseSheetUri:(NSString *)expenseSheetUri
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseSheetUri='%@'",expenseApprovalHistoryTable,expenseSheetUri];
	NSMutableArray *expenseHistoryDetailsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if (expenseHistoryDetailsArr != nil && [expenseHistoryDetailsArr count]!=0) {
        return expenseHistoryDetailsArr;
	}
	return nil;
}
-(NSMutableArray *)getAllExpenseEntriesFromDBExceptEntryWithUri:(NSString *)expenseEntryUri ForExpenseSheetUri:(NSString *)expenseSheetUri
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseEntryUri != '%@' and expenseSheetUri='%@'",expenseEntriesTable,expenseEntryUri,expenseSheetUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}

-(NSArray *)getExpenseCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@' and udf_uri='%@' ",expenseCustomFieldsTable,sheetUri,moduleName,entryUri,udfUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}
-(NSArray *)getExpenseCustomFieldsForExpenseSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri 
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and moduleName='%@' and entryUri='%@'",expenseCustomFieldsTable,sheetUri,moduleName,entryUri];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0) {
		return array;
	}
	return nil;
}

-(void)deleteAllExpenseSheetsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:expenseSheetsTable inDatabase:@""];
}
-(void)deleteAllClientsInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",clientsTable,moduleName];
	[myDB executeQuery:query];
}
-(void)deleteAllProjectsInfoFromDBForModuleName:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where moduleName = '%@'",projectsTable,moduleName];
	[myDB executeQuery:query];
}
-(void)deleteExpenseSheetFromDBForSheetUri:(NSString *)sheetURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseSheetUri = '%@'",expenseSheetsTable,sheetURI];
	[myDB executeQuery:query];
}

-(void)deleteAllExpenseCodesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:expenseCodesTable inDatabase:@""];
}
-(void)deleteAllExpenseCodeTaxCodesFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:expenseTaxcodesTable inDatabase:@""];
}
-(void)deleteAllExpenseCodeDetailsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:expenseCodeDetailsTable inDatabase:@""];
}
-(NSString*)getSystemCurrencyUriFromDBForCurrencyName:(NSString*)currencyName
{
	SQLiteDB *myDB  = [SQLiteDB getInstance];
	
    NSMutableArray *currencyArray = [myDB select:@"*" from:systemCurrenciesTable where:[NSString stringWithFormat:@"currenciesName='%@'",[currencyName stringByReplacingOccurrencesOfString:@"'"withString:@"''" ]] intoDatabase:@""];
	NSString *currencyId=nil;
	if ([currencyArray count]!=0) {
		currencyId= [[currencyArray objectAtIndex:0]objectForKey:@"currenciesUri"];
	}
    return currencyId;
}
-(NSMutableArray *)getAllSystemCurrencyUriFromDB
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ ",systemCurrenciesTable];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:query];
	if ([array count]!=0)
    {
		return array;
	}
	return nil;
	
}
-(void)deletePendingExpenseTaxCodeInfoForEntryUri:(NSString *)entryURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseEntryUri = '%@'",expensePendingTaxCodesTable,entryURI];
	[myDB executeQuery:query];
}
-(void)deletePendingExpenseCodeInfoForEntryUri:(NSString *)entryURI
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query=[NSString stringWithFormat:@"delete from %@ where expenseEntryUri = '%@'",expensePendingCodeDetailsTable,entryURI];
	[myDB executeQuery:query];
}
-(NSArray *)getExpenseEntryInfoForSheetIdentity:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryURI
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
	
	NSString *query=[NSString stringWithFormat:@" select * from %@ where expenseSheetUri = '%@' and expenseEntryUri = '%@'",expenseEntriesTable,sheetIdentity,entryURI];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
    
}
-(NSArray *)getAllPendingExpenseTaxCodesFromDBForEntryUri:(NSString *)entryUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseEntryUri = '%@'",expensePendingTaxCodesTable,entryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSArray *)getAllDetailsForExpenseCodeFromDBForEntryUri:(NSString *)entryUri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expenseEntryUri = '%@'",expensePendingCodeDetailsTable,entryUri];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([expenseSheetsArr count]>0)
    {
		return expenseSheetsArr;
	}
	return nil;
}
//implemented as per US8689//JUHI
-(void)deleteAllSystemCurrencyFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:systemCurrenciesTable inDatabase:@""];
}

-(void)deleteAllSystemPaymentMethodFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:systemPaymentMethodsTable inDatabase:@""];
}
-(void)saveExpenseDisclaimerDataToDB:(NSMutableDictionary *)disclaimerDict
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *disclaimerDescription=[disclaimerDict objectForKey:@"description"];
    NSString *disclaimerTitle=[disclaimerDict objectForKey:@"title"];
    NSString *disclaimerModule=ExpenseModuleName;
    NSString *whereStr=[NSString stringWithFormat:@"module= '%@' ",disclaimerModule];
    [myDB deleteFromTable:disclaimerTable where:whereStr inDatabase:@""];
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:disclaimerDescription forKey:@"description"];
    [dataDict setObject:disclaimerTitle forKey:@"title"];
    [dataDict setObject:disclaimerModule forKey:@"module"];
    
    [myDB insertIntoTable:disclaimerTable data:dataDict intoDatabase:@""];
}
-(NSMutableArray *)getAllDisclaimerDetailsFromDBForModule:(NSString *)moduleName
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where module='%@'",disclaimerTable,moduleName];
	NSMutableArray *array = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([array count]>0)
    {
		return array;
	}
	return nil;
    
}
@end
