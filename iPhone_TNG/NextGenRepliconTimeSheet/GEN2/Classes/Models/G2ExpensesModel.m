//
//  ExpensesModel.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ExpensesModel.h"
#import "G2PermissionsModel.h"

@interface G2ExpensesModel()
-(NSDictionary *) calculateTaxesForEntry: (NSDictionary*)_entry withExpenseTypes: (NSDictionary *)expenseTypeDict; // addToDictionary: (NSMutableDictionary *) infoDict;
@end

//static NSString *table_expenseEntries = @"expense_entries";
static NSString *tableName3 = @"expenseTypes";
static NSString *tableName4 = @"clients";
static NSString *tableName5 = @"projects";
static NSString *tableName6 = @"systemCurrencies";
//static NSString *tableName6 = @"taxCodes";
static NSString *tableName7 = @"entry_udfs";
static NSString *tableName9 = @"systemPaymentMethods";
static NSString *tableName8 = @"userDefinedFields";
static NSString *tableName10 = @"expense_Project_Type";

#define Max_No_Taxes_5 5

@implementation G2ExpensesModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		offlineIdentity= 999999999;
		
	}
	return self;
}

#pragma mark INSERT
- (void) insertExpenseSheetsInToDataBase:(NSArray *) expensesArray{
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	
	for (int i = 0; i<[expensesArray count]; i++) {
		
		NSString *status=nil;
		NSDictionary *_expense = [expensesArray objectAtIndex:i];
		NSDictionary *_approvalProps = [[[_expense objectForKey:@"Relationships"]objectForKey:@"ApproveStatus"]objectForKey:@"Properties"];
		if ([[_approvalProps objectForKey:@"Name"] isEqualToString:@"Open"]) {
			status = @"Not Submitted";
		} else if ([[_approvalProps objectForKey:@"Name"] isEqualToString:@"Waiting"]) {
			status = @"Waiting For Approval";
		}else if ([[_approvalProps objectForKey:@"Name"] isEqualToString:@"Rejected"]) {
			status = @"Rejected";
		}else if ([[_approvalProps objectForKey:@"Name"] isEqualToString:@"Approved"]) {
			status = @"Approved";
		}else {
			status = @"Not Submitted";
		}
		
		int month;
		NSString *expenseDate=nil,*submittedOn=nil,*savedOn=nil,*savedOnUtc=nil;
		NSDictionary *_expenseProps = [_expense objectForKey: @"Properties"];
		id expenseDateDict=[_expenseProps objectForKey:@"ExpenseDate"];
		id submittedOnDict=[_expenseProps objectForKey:@"SubmittedOn"];
		id savedOnDict=[_expenseProps objectForKey:@"SavedOn"];
		id savedOnUtcDict=[_expenseProps objectForKey:@"SavedOnUtc"];
		
		if([expenseDateDict isKindOfClass:[NSDictionary class]]){
			month = [[expenseDateDict objectForKey:@"Month"]intValue];
			expenseDate =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[expenseDateDict objectForKey:@"Day"]
						  
						  ,[expenseDateDict objectForKey:@"Year"]];
		}else if([expenseDateDict isKindOfClass:[NSNull class]]){
			expenseDate = @"null";
		}
		
		if([submittedOnDict isKindOfClass:[NSDictionary class]]){
			month = [[submittedOnDict objectForKey:@"Month"]intValue];
			submittedOn =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[submittedOnDict objectForKey:@"Day"]
						  
						  ,[submittedOnDict objectForKey:@"Year"]];
			
		}else if([submittedOnDict isKindOfClass:[NSNull class]]){
			
			submittedOn = @"null";
		}
		
		if([savedOnDict isKindOfClass:[NSDictionary class]]){
			month = [[savedOnDict objectForKey:@"Month"]intValue];
			savedOn =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[savedOnDict objectForKey:@"Day"]
					  
					  ,[savedOnDict objectForKey:@"Year"]];
		}else if([savedOnDict isKindOfClass:[NSNull class]]){
			savedOn = @"null";
		}
		
		if([savedOnUtcDict isKindOfClass:[NSDictionary class]]){
			month = [[savedOnUtcDict objectForKey:@"Month"]intValue];
			savedOnUtc =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[savedOnUtcDict objectForKey:@"Day"]
						 
						 ,[savedOnUtcDict objectForKey:@"Year"]];
			
		}else if([savedOnUtcDict isKindOfClass:[NSNull class]]) {
			savedOnUtc = @"null";
		}
		/**Handling Leaks
		 
		 identity = [[expensesArray objectAtIndex:i] objectForKey:@"Identity"];
		 
		 identityNum = [NSNumber numberWithInt:[identity intValue]];
		 **/
		
		NSString *trackingNumber=[_expenseProps objectForKey:@"TrackingNumber"];
		NSString *totalReimbursement=[_expenseProps objectForKey:@"TotalReimbursement"];
		
		NSDictionary *reimbursmentCurrencyDict = [[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]
												  objectForKey:@"ReimbursementCurrency"];
		NSString *reimbursmentCurrency = @"";
		if (reimbursmentCurrencyDict != nil) {
			reimbursmentCurrency = [[reimbursmentCurrencyDict objectForKey:@"Properties"] objectForKey:@"Symbol"];
		}
		
		NSArray *remainingApproversArray = [[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]
											objectForKey:@"RemainingApprovers"];
		NSArray *filteredHistoryArray = [[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]
                                         objectForKey:@"FilteredHistory"]; 
		
		NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         //identityNum,@"id",
                                         [NSNumber numberWithInt:0],@"isModified",
                                         @"",@"editStatus",
                                         [[expensesArray objectAtIndex:i] objectForKey:@"Identity"],@"identity",
                                         status,@"status",
                                         trackingNumber,@"trackingNumber",
                                         submittedOn,@"submittedOn",
                                         savedOn,@"savedOn",
                                         savedOnUtc,@"savedOnUtc",
                                         [_expenseProps objectForKey:@"Description"],@"description",
                                         expenseDate,@"expenseDate",
                                         reimbursmentCurrency,@"reimburseCurrency",
                                         totalReimbursement ,@"totalReimbursement",
                                         nil]; 
		
		BOOL approversRemaining = [G2Util showUnsubmitButtonForSheet:filteredHistoryArray sheetStatus:status remainingApprovers:remainingApproversArray];
		
		[infoDict setObject:[NSNumber numberWithBool:approversRemaining] forKey:@"approversRemaining"];
		
		NSString *sheetIdentity =[NSString stringWithFormat:@"%@",
								  [[expensesArray objectAtIndex:i]objectForKey:@"Identity"]];
		
		[G2Util addToUnsubmittedSheets:filteredHistoryArray sheetStatus:status sheetId:sheetIdentity 
							  module:UNSUBMITTED_EXPENSE_SHEETS];
        
		
		NSArray *expArr = [self getExpenseSheetInfoForSheetIdentity:[[expensesArray objectAtIndex:i] objectForKey:@"Identity"]];
		
		if ([expArr count]>0) {
			NSString *whereString=[NSString stringWithFormat:@"identity='%@'",[[expensesArray objectAtIndex:i] objectForKey:@"Identity"]];
			[myDB updateTable: table_ExpenseSheets data:infoDict where:whereString intoDatabase:@""];
		}else {
			[myDB insertIntoTable: table_ExpenseSheets data:infoDict intoDatabase:@""];
		}
		
		//delete Expense entries for sheet if exists.
		NSString *entriesDeleteString = [NSString stringWithFormat:@"expense_sheet_identity = '%@'",
										 [[expensesArray objectAtIndex:i] objectForKey:@"Identity"]];
		[myDB deleteFromTable:table_expenseEntries where:entriesDeleteString inDatabase:@""];
	}
}

- (void) insertExpenseEntriesInToDataBase:(NSArray *) expensesArray{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSNumber *identityNum = 0;
	
	for (int i=0; i<[expensesArray count]; i++) {
		NSDictionary *_expense = [expensesArray objectAtIndex:i];
		NSArray *_expEntries = [[_expense objectForKey:@"Relationships"]objectForKey:@"Entries"];
		for (int j=0; j<[_expEntries count]; j++) {
			
			NSDictionary *_entry = [_expEntries objectAtIndex: j];
			NSString *paymentMethodName = @"";
			NSString *paymentMethodId = @"";
			NSNumber *modified=[NSNumber numberWithInt:0];
			NSString *clientName= @"";
			NSString *clientID = @"";
			NSString *expenseReceiptStr = @"";
			
			
			id entryDateDict = [[_entry objectForKey:@"Properties"]objectForKey:@"EntryDate"];
			NSString *entryDate=nil,*currencyType=nil,*projectIdentity=nil,*projectName=nil;
			NSNumber *requestReimbursement,*billClient;
			id identity; 
			id description;
			id netAmount; 
			
			if([entryDateDict isKindOfClass:[NSDictionary class]]){
				int month = [[entryDateDict objectForKey:@"Month"]intValue];
				entryDate =[NSString stringWithFormat:@"%@ %@, %@", [G2Util getMonthNameForMonthId:month],[entryDateDict objectForKey:@"Day"]
							,[entryDateDict objectForKey:@"Year"]];
				
			}else if([entryDateDict isKindOfClass:[NSNull class]]){
				entryDate =@"";
			}
			
			if ([[[_entry objectForKey:@"Properties"]objectForKey:@"BillToClient"] boolValue]==0) {
				billClient = [NSNumber numberWithInt:0];
			}else {
				billClient=[NSNumber numberWithInt:1];
			}
			
			if ([[[_entry objectForKey:@"Properties"]objectForKey:@"RequestReimbursement"] boolValue]==0) {
				requestReimbursement = [NSNumber numberWithInt:0];
			}else {
				requestReimbursement=[NSNumber numberWithInt:1];
			}
			
			currencyType =[[[[_entry objectForKey:@"Relationships"]objectForKey:@"Currency"]objectForKey:@"Properties"]
						   objectForKey:@"Symbol"];
			
			id expenseReceipt = [[_entry objectForKey:@"RelationshipCount"]objectForKey:@"ExpenseReceipt"];
			
			if([expenseReceipt isKindOfClass:[NSNumber class]]){
				if ([expenseReceipt isEqualToNumber:[NSNumber numberWithInt:1]]) {
					expenseReceiptStr = @"Yes";
				}else {
					expenseReceiptStr = @"No";
				}
				
			}else if([expenseReceipt isKindOfClass:[NSNull class]]){		
			    expenseReceiptStr = @"No";
			}	
			
			
			/*id clientDict = [[[[[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Entries"] 
			 objectAtIndex:j] objectForKey:@"Relationships"]objectForKey:@"Client"];*/
			
			
			id projectsDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"Project"];
			
			
			
			/*if (clientDict!=nil &&  [clientDict isKindOfClass:[NSDictionary class]]  && [clientDict count]>0) {
			 if ([clientDict objectForKey:@"Identity"]!=nil) 
			 clientID =[clientDict objectForKey:@"Identity"];
			 
			 if ([[clientDict objectForKey:@"Properties"] objectForKey:@"Name"]!=nil) 
			 clientName = [[clientDict objectForKey:@"Properties"] objectForKey:@"Name"];
			 }else {*/
			id clientArr = nil;
			if([projectsDict isKindOfClass:[NSDictionary class]]){
				projectIdentity=[projectsDict objectForKey:@"Identity"];
				projectName = [[projectsDict objectForKey:@"Properties"]objectForKey:@"Name"];
				
				clientArr = [[projectsDict objectForKey:@"Relationships"]objectForKey:@"ProjectClients"];
				if ([clientArr isKindOfClass:[NSArray class]]) {
					if (clientArr!=nil && [clientArr count]>0) {
						for (int m=0; m<[clientArr count]; m++) {
							clientName = [[[[[clientArr objectAtIndex:m]objectForKey:@"Relationships"] 
											objectForKey:@"Client"] objectForKey:@"Properties"]objectForKey:@"Name"];
							clientID = [[[[[clientArr objectAtIndex:m]objectForKey:@"Relationships"] 
										  objectForKey:@"Client"] objectForKey:@"Properties"]objectForKey:@"Id"];
							
							
						}
					}else {
						clientName=@"";
						clientID=@"";
					}
					
				}else  if([clientArr isKindOfClass:[NSNull class]]){
					clientName=@"";
					clientID=@"";
				}			
			}else if([projectsDict isKindOfClass:[NSNull class]]){
				projectIdentity = @"";
				projectName = @"";
				clientName=@"";
				clientID=@"";
			}
			id expenseTypeDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"ExpenseType"];
			
			identity = [_entry objectForKey:@"Identity"];
			if ([identity isKindOfClass:[NSNull class]]) {
				identity = @"";
			}
			
			description = [[_entry objectForKey:@"Properties"]objectForKey:@"Description"];
			if ([description isKindOfClass:[NSNull class]]) {
				description = @"";
			}
			netAmount = [[_entry objectForKey:@"Properties"]objectForKey:@"NetAmount"];
			
            //Fix for DE3434//Juhi
            NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
            NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[netAmount doubleValue]];
            NSDecimalNumber *roundedNetAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
            
			
			id expenseTypeName = [[expenseTypeDict objectForKey:@"Properties"]objectForKey:@"Name"];
			
			if ([expenseTypeName isKindOfClass:[NSNull class]]) {
				expenseTypeName = @"";
			}
			
			id expenseTypeIdentity =[expenseTypeDict objectForKey:@"Identity"];
			if ([expenseTypeIdentity isKindOfClass:[NSNull class]]) {
				expenseTypeIdentity = @"";
			}
			id paymentMethodDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"PaymentMethod"];
			if ([paymentMethodDict isKindOfClass:[NSDictionary class]]){
				NSDictionary *propertyDict = [paymentMethodDict objectForKey:@"Properties"];
				
				
				paymentMethodName = [propertyDict objectForKey:@"Name"];
				paymentMethodId = [propertyDict objectForKey:@"Id"];
				
				
			}else if([[[_entry objectForKey:@"Relationships"]objectForKey:@"PaymentMethod"]isKindOfClass:[NSNull class]]){
				
			}
			
			
			identityNum = [NSNumber numberWithInt:[identity intValue]];
			
			NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 [[expensesArray objectAtIndex:i] objectForKey:@"Identity"],@"expense_sheet_identity",
											 identityNum,@"id",
											 identity,@"identity",
											 billClient,@"billClient",
											 requestReimbursement,@"requestReimbursement",
											 entryDate,@"entryDate",
											 description,@"description",
											 currencyType,@"currencyType",
											 roundedNetAmount,@"netAmount",
											 projectIdentity ,@"projectIdentity",
											 projectName,@"projectName",
											 clientID,@"clientIdentity",
											 clientName,@"clientName",
											 expenseReceiptStr,@"expenseReceipt",
											 expenseTypeIdentity,@"expenseTypeIdentity",
											 expenseTypeName,@"expenseTypeName",
											 modified,@"isModified",
											 paymentMethodName,@"paymentMethodName",
											 paymentMethodId,@"paymentMethodId",
											 nil]; 
			
			//Tring to fix Bucket project
			NSMutableDictionary *projectBillingTypeDict = nil;
			NSString *allocationId = @"";
			if (projectsDict != nil && ![projectsDict isKindOfClass:[NSNull class]]) {
                projectBillingTypeDict= [[projectsDict objectForKey:@"Relationships"]objectForKey:@"ClientBillingAllocationMethod"];
                //NSDictionary *allocationMethodDict=nil;
                if (projectBillingTypeDict != nil && [projectBillingTypeDict isKindOfClass:[NSDictionary class]]) {
                    allocationId=[projectBillingTypeDict objectForKey:@"Identity"];
                    //allocationMethodDict=[projectBillingTypeDict objectForKey:@"Properties"];
                }
			}
			if (allocationId!=nil) {
				[infoDict setObject:allocationId forKey:@"allocationMethodId"];
			}
            
			
			//Calculate the amount and taxes for the entry
			[infoDict addEntriesFromDictionary: [self calculateTaxesForEntry: _entry withExpenseTypes: expenseTypeDict]];
			//adding default values till implementation added for following columns
			
			NSString *noOfUnits=[[_entry objectForKey:@"Properties"]objectForKey:@"NumberOfUnits"];
			if ([noOfUnits isKindOfClass:[NSNull class]]) {
				noOfUnits=@"";
			}
			
			[infoDict setObject:[NSNumber numberWithDouble:[noOfUnits doubleValue]] forKey:@"noOfUnits"];
			[infoDict setObject:@"" forKey:@"editStatus"];
			
			NSArray *expArr = [self getExpenseEntryInfoForIdentity:identity];
			if ([expArr count]>0) {
				NSString *whereString=[NSString stringWithFormat:@"identity='%@'",identity];
				[myDB updateTable: table_expenseEntries data:infoDict where:whereString intoDatabase:@""];
				
			}else {
				[myDB insertIntoTable: table_expenseEntries data:infoDict intoDatabase:@""];
			}
            
            if (projectIdentity!=nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:@""]) {
                 [myDB updateColumnFromTable:@"isExpensesRecent" fromTable:tableName5 withString:[NSString stringWithFormat:@"1 where expensesAllowed = 1 and identity='%@'",projectIdentity] inDatabase:@""];
            }
        
		}
	}
}


-(NSDictionary *) calculateTaxesForEntry: (NSDictionary*)_entry withExpenseTypes: (NSDictionary *)expenseTypeDict 
{
	NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
	double netAmountTotal=0;
	
	id netAmount = [[_entry objectForKey:@"Properties"]objectForKey:@"NetAmount"];
    
    //DE7026
    //    //Fix for DE3434//Juhi
    //    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
    //    NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[netAmount doubleValue]];
    //    NSDecimalNumber *roundedNetAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
	netAmountTotal=[netAmount doubleValue];
    
	id taxCodesDict =nil;
	
	NSString *taxCodeIdEntry = nil;
	
	for (int x=1; x<=Max_No_Taxes_5; x++) {
		NSString *taxAmount=[[_entry objectForKey:@"Properties"]objectForKey:[NSString stringWithFormat:@"TaxAmount%d",x]];
		if ([taxAmount isKindOfClass:[NSNull class]]) {
			taxAmount=@"";
			[infoDict setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
		}else {
			[infoDict setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
			netAmountTotal=netAmountTotal+[taxAmount doubleValue];
			[infoDict setObject:[NSString stringWithFormat:@"%0.02lf",netAmountTotal] forKey:@"netAmount"];
		}
		
		id formulaValue  = [[expenseTypeDict objectForKey:@"Properties"]objectForKey:[NSString stringWithFormat:@"Formula%d",x]];
		if (formulaValue!=nil &&  ![formulaValue isKindOfClass:[NSNull class]]) {
			[infoDict setObject:formulaValue forKey:[NSString stringWithFormat:@"formula%d",x]];	
		}else {
			[infoDict setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",x]];	
		}
		
		taxCodesDict = [[_entry objectForKey:@"Relationships"]objectForKey:[NSString stringWithFormat:@"TaxCode%d",x]];
		if ([taxCodesDict isKindOfClass:[NSDictionary class]]){
			taxCodeIdEntry=[taxCodesDict objectForKey:@"Identity"];
			if ([taxCodeIdEntry isKindOfClass:[NSNull class]]) {
				taxCodeIdEntry=@"";
				[infoDict setObject:taxCodeIdEntry forKey:[NSString stringWithFormat:@"taxCode%d",x]];
			}else {
				[infoDict setObject:taxCodeIdEntry forKey:[NSString stringWithFormat:@"taxCode%d",x]];
			}
		}else {
			taxCodeIdEntry=@"";
			[infoDict setObject:taxCodeIdEntry forKey:[NSString stringWithFormat:@"taxCode%d",x]];
		}
	}	
	
	id expenseUnitLable = [[expenseTypeDict objectForKey:@"Properties"]objectForKey:@"ExpenseUnitLabel"];
	
	if (expenseUnitLable != nil && ![expenseUnitLable isKindOfClass:[NSNull class]]) {
		[infoDict setObject:expenseUnitLable forKey:@"expenseUnitLable"];
	}else {
		[infoDict setObject:@"" forKey:@"expenseUnitLable"];
	}
    
	
	NSString *type=nil;
	
	NSString *expenseRate=[[_entry objectForKey:@"Properties"]objectForKey:@"ExpenseRate"];
	
	if ([expenseRate isKindOfClass:[NSNull class]]) {
		expenseRate=@"";
		[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"isRated"];
	}else {
		[infoDict setObject:[NSNumber numberWithInt:1] forKey:@"isRated"];
	}
	
	
	
	id firstTaxCodeDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"TaxCode1"];
	if ((firstTaxCodeDict == nil || [firstTaxCodeDict isKindOfClass:[NSNull class]]) &&[expenseRate isKindOfClass:[NSString class]]) {
		type = Flat_WithOut_Taxes;
	}else if (firstTaxCodeDict != nil && ![firstTaxCodeDict isKindOfClass:[NSNull class]] && [expenseRate isKindOfClass:[NSString class]]) {
		type = Flat_With_Taxes;
	}else if (firstTaxCodeDict != nil && ![firstTaxCodeDict isKindOfClass:[NSNull class]] &&[expenseRate isKindOfClass:[NSNumber class]]) {
		type = Rated_With_Taxes;
	}else if ((firstTaxCodeDict == nil || [firstTaxCodeDict isKindOfClass:[NSNull class]]) && [expenseRate isKindOfClass:[NSNumber class]]){
		type = Rated_WithOut_Taxes;
	}
	
	if (type!=nil && ![type isKindOfClass:[NSNull class]]) {
		[infoDict setObject:type forKey:@"type"];
	}
    //Fix for DE3434//Juhi
    //    NSDecimalNumber *expenseRateDecimal = [[NSDecimalNumber alloc] initWithDouble:[expenseRate doubleValue]];
    //    NSDecimalNumber *roundedExpenseRate = [expenseRateDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
	//[infoDict setObject:expenseRate forKey:@"expenseRate"];	
	[infoDict setObject:[NSNumber numberWithDouble:[expenseRate doubleValue]] forKey:@"expenseRate"];	
	
	return infoDict;
}

-(NSDictionary *)fetchQueryHandlerAndStartIndexForClientID:(NSString *)clientId
{
     G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSMutableArray *returnArr=[myDB select:@"expenses_queryHandler,expenses_StartIndex" from:tableName4 where:[NSString stringWithFormat: @"identity='%@'",clientId] intoDatabase:@""];
   if ([returnArr count]>0) {
       return [returnArr objectAtIndex:0];
    }
    return nil;
}

- (void) updateQueryHandleByClientId:(NSString*)clientId andQueryHandle:(NSString *)queryHandle  andStartIndex:(NSString *)startIndex
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    [myDB updateTable:tableName4 data:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",queryHandle],@"expenses_queryHandler",startIndex,@"expenses_StartIndex", nil] where:[NSString stringWithFormat: @"identity='%@'",clientId] intoDatabase:@""];
}

- (void) updateExpenseSheetsById:(NSString*)_expenseSheetID response:(NSArray *) expensesArray{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	int i = 0; 
	
	NSString *status=nil;
	
	if ([[[[[[expensesArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"ApproveStatus"]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"Open"]) {
		status = @"Not Submitted";
	} else if ([[[[[[expensesArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"ApproveStatus"]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"Waiting"]) {
		status = @"Waiting For Approval";
	}else if ([[[[[[expensesArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"ApproveStatus"]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"Rejected"]) {
		status = @"Rejected";
	}else {
		status = @"Approved";
	}
	int month;
	NSString *expenseDate=nil,*submittedOn=nil,*savedOn=nil,*savedOnUtc=nil;
	
	id expenseDateDict=[[[expensesArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ExpenseDate"];
	id submittedOnDict=[[[expensesArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"SubmittedOn"];
	id savedOnDict=[[[expensesArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"SavedOn"];
	id savedOnUtcDict=[[[expensesArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"SavedOnUtc"];
	
	if([expenseDateDict isKindOfClass:[NSDictionary class]]){
		month = [[expenseDateDict objectForKey:@"Month"]intValue];
		expenseDate =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[expenseDateDict objectForKey:@"Day"]
					  
					  ,[expenseDateDict objectForKey:@"Year"]];
	}else if([expenseDateDict isKindOfClass:[NSNull class]]){
		expenseDate = @"null";
	}
	
	if([submittedOnDict isKindOfClass:[NSDictionary class]]){
		month = [[submittedOnDict objectForKey:@"Month"]intValue];
		submittedOn =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[submittedOnDict objectForKey:@"Day"]
					  
					  ,[submittedOnDict objectForKey:@"Year"]];
		
	}else if([submittedOnDict isKindOfClass:[NSNull class]]){
		
		submittedOn = @"null";
	}
	
	if([savedOnDict isKindOfClass:[NSDictionary class]]){
		month = [[savedOnDict objectForKey:@"Month"]intValue];
		savedOn =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[savedOnDict objectForKey:@"Day"]
				  
				  ,[savedOnDict objectForKey:@"Year"]];
	}else if([savedOnDict isKindOfClass:[NSNull class]]){
		savedOn = @"null";
	}
	
	if([savedOnUtcDict isKindOfClass:[NSDictionary class]]){
		month = [[savedOnUtcDict objectForKey:@"Month"]intValue];
		savedOnUtc =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],[savedOnUtcDict objectForKey:@"Day"]
					 
					 ,[savedOnUtcDict objectForKey:@"Year"]];
		
	}else if([savedOnUtcDict isKindOfClass:[NSNull class]]) {
		savedOnUtc = @"null";
	}
	/**
	 Handling Leaks
	 identity = [[expensesArray objectAtIndex:i] objectForKey:@"Identity"];
	 identityNum = [NSNumber numberWithInt:[identity intValue]];
	 */
	
	NSString *trackingNumber=[[[expensesArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"TrackingNumber"];
	NSString *totalReimbursement=[[[expensesArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"TotalReimbursement"];
	NSString *reimburseCurrency=[[[[[expensesArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"ReimbursementCurrency"]
								  objectForKey:@"Properties"]objectForKey:@"Symbol"];
	NSArray *remainingApprovers = [[[expensesArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"RemainingApprovers"];
	NSArray *filteredHistoryArray = [[[expensesArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"FilteredHistory"];
	
	NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 //identityNum,@"id",	  
									 [[expensesArray objectAtIndex:i] objectForKey:@"Identity"],@"identity",
									 status,@"status",
									 trackingNumber,@"trackingNumber",
									 submittedOn,@"submittedOn",
									 savedOn,@"savedOn",
									 savedOnUtc,@"savedOnUtc",
									 [[[expensesArray objectAtIndex:i] objectForKey:@"Properties"]objectForKey:@"Description"],@"description",
									 expenseDate,@"expenseDate",
									 totalReimbursement ,@"totalReimbursement",
									 nil]; 
	if (reimburseCurrency!=nil && [reimburseCurrency isKindOfClass:[NSNull class]]) {
		[infoDict setObject:reimburseCurrency forKey:@"reimburseCurrency"];
	}
	
	BOOL approversRemaining = [G2Util showUnsubmitButtonForSheet:filteredHistoryArray sheetStatus:status remainingApprovers:remainingApprovers];
	
	[infoDict setObject:[NSNumber numberWithBool:approversRemaining] forKey:@"approversRemaining"];
	
	NSString *sheetIdentity =[NSString stringWithFormat:@"%@",
							  [[expensesArray objectAtIndex:i]objectForKey:@"Identity"]];
	
	[G2Util addToUnsubmittedSheets:filteredHistoryArray sheetStatus:status sheetId:sheetIdentity 
						  module:UNSUBMITTED_EXPENSE_SHEETS];
	
	NSString *placeString=[NSString stringWithFormat:@"identity='%@'",_expenseSheetID];
	[myDB updateTable: table_ExpenseSheets data:infoDict where:placeString intoDatabase:@""];
	
}

- (void) insertExpenseProjectSpecificTypesWithTaxCodesInToDatabase:(NSArray *) response {
	//NSNumber *identityNum = 0;
	NSString *identity = @"null";
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	/*ProjectPermissionType permType = [PermissionsModel getProjectPermissionType];
     if (permType == PermType_Both) {
     if ([[self getExpenseTypesWithTaxCodesFromDatabase]count]>0) {
     //[myDB deleteFromTable:tableName3 inDatabase:@""];
     [myDB deleteFromTable:tableName3 where:[NSString stringWithFormat:@"projectIdentity !='%@'",@"null"] inDatabase:@""];
     }else {
     }
     }else {
     [myDB deleteFromTable:tableName3 inDatabase:@""];
     }*/
	
	
	for (int i = 0; i<[response count]; i++) {
		//NSMutableDictionary *typeDict = [NSMutableDictionary dictionary];
		
		//[typeDict setObject:[[response objectAtIndex:i] objectForKey:@"Identity"] forKey:@"projectIdentity"];
		NSArray *expenseTypeArray = [NSArray arrayWithArray:[[[response objectAtIndex:i] objectForKey:@"Relationships"] objectForKey:@"ExpenseTypes"]];
		for (int j = 0; j<[expenseTypeArray count]; j++) {
			identity = [[expenseTypeArray objectAtIndex:j] objectForKey:@"Identity"];
			 NSString *placeString=[NSString stringWithFormat:@"expenseTypeIdentity='%@' and projectIdentity = '%@'",identity, [[response objectAtIndex:i] objectForKey:@"Identity"]];
             NSMutableArray *expenseArr = [myDB select:@"*" from: tableName10 where:placeString intoDatabase:@""];
            NSDictionary *expense_project_type_dict=[NSDictionary dictionaryWithObjectsAndKeys:[[response objectAtIndex:i] objectForKey:@"Identity"],@"projectIdentity",identity,@"expenseTypeIdentity", nil];
            if ([expenseArr count]>0) {
                [myDB updateTable: tableName10 data:expense_project_type_dict where:placeString intoDatabase:@""];
            }else {
                [myDB insertIntoTable:tableName10 data:expense_project_type_dict intoDatabase:@""];
            }
		}
		
	}
}

- (void)insertExpenseTypesWithTaxCodesInToDatabase:(NSArray *) expenseTypeArray
{
    NSString *identity = @"null";
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    for (int j = 0; j<[expenseTypeArray count]; j++) {
        NSMutableDictionary *typeDict = [NSMutableDictionary dictionary];
        identity = [[expenseTypeArray objectAtIndex:j] objectForKey:@"Identity"];
        NSDictionary *_expenseTypeProps = [[expenseTypeArray objectAtIndex:j] objectForKey:@"Properties"];
        NSNumber *disabledFlag=[_expenseTypeProps objectForKey:@"Disabled"];
        
        if (disabledFlag !=nil && ![disabledFlag isKindOfClass:[NSNull class]]) {
            [typeDict setObject:disabledFlag forKey:@"isDisabled"];
        }
        
        
        //[typeDict setObject:identityNum forKey:@"id"];
        [typeDict setObject:identity forKey:@"identity"];
        [typeDict setObject:[_expenseTypeProps objectForKey:@"Name"] forKey:@"name"];
        
        NSString *expenseUnitLable=[_expenseTypeProps objectForKey:@"ExpenseUnitLabel"];
        if ([expenseUnitLable isKindOfClass:[NSNull class]]) {
            expenseUnitLable=@"";
        }else {
            
        }
        [typeDict setObject:expenseUnitLable forKey:@"expenseUnitLabel"];
        
        //Formulas for ExpenseTypes................
        for (int x=1; x<= Max_No_Taxes_5 ; x++) {
            id formulaValue = [_expenseTypeProps objectForKey:[NSString stringWithFormat:@"Formula%d",x]] ;
            if (formulaValue!=nil &&  ![formulaValue isKindOfClass:[NSNull class]]) {
                [typeDict setObject:formulaValue forKey:[NSString stringWithFormat:@"formula%d",x]];
            }else {
                [typeDict setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",x]];
            }
            
        }
        
        
        NSDictionary *_expTypeRelationship = [[expenseTypeArray objectAtIndex:j] objectForKey:@"Relationships"];
        id taxcode1Dict = [_expTypeRelationship objectForKey:@"TaxCode1"];
        if([taxcode1Dict isKindOfClass:[NSDictionary class]]){
            [typeDict setObject:[taxcode1Dict objectForKey:@"Identity"] forKey:@"taxCode1"];
        }else if([taxcode1Dict isKindOfClass:[NSNull class]]){
            [typeDict setObject:@"null" forKey:@"taxCode1"];
        }
        
        id taxcode2Dict = [_expTypeRelationship objectForKey:@"TaxCode2"];
        if([taxcode2Dict isKindOfClass:[NSDictionary class]]){
            [typeDict setObject:[taxcode2Dict objectForKey:@"Identity"] forKey:@"taxCode2"];
        }else if([taxcode2Dict isKindOfClass:[NSNull class]]){
            [typeDict setObject:@"null" forKey:@"taxCode2"];
        }
        
        id taxcode3Dict = [_expTypeRelationship objectForKey:@"TaxCode3"];
        if([taxcode3Dict isKindOfClass:[NSDictionary class]]){
            [typeDict setObject:[taxcode3Dict objectForKey:@"Identity"] forKey:@"taxCode3"];
        }else if([taxcode3Dict isKindOfClass:[NSNull class]]){
            [typeDict setObject:@"null" forKey:@"taxCode3"];
        }
        
        id taxcode4Dict = [_expTypeRelationship objectForKey:@"TaxCode4"];
        if([taxcode4Dict isKindOfClass:[NSDictionary class]]){
            [typeDict setObject:[taxcode4Dict objectForKey:@"Identity"] forKey:@"taxCode4"];
        }else if([taxcode4Dict isKindOfClass:[NSNull class]]){
            [typeDict setObject:@"null" forKey:@"taxCode4"];
        }
        
        id taxcode5Dict = [_expTypeRelationship objectForKey:@"TaxCode5"];
        if([taxcode5Dict isKindOfClass:[NSDictionary class]]){
            [typeDict setObject:[taxcode5Dict objectForKey:@"Identity"] forKey:@"taxCode5"];
        }else if([taxcode5Dict isKindOfClass:[NSNull class]]){
            [typeDict setObject:@"null" forKey:@"taxCode5"];
        }
        NSString *type=nil;
        id tskRateDict = [_expTypeRelationship objectForKey:@"TskRate"];
        if([tskRateDict isKindOfClass:[NSDictionary class]]){
            type = @"Rated";
            
            NSNumber *hourlyRate=[[[[[tskRateDict objectForKey:@"Relationships"] objectForKey:@"Entries"] objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"HourlyRate"];
            [typeDict setObject:hourlyRate forKey:@"hourlyRate"];
            
            NSString *ratedCurrency = [[[[[[[tskRateDict objectForKey:@"Relationships"] objectForKey:@"Entries"] objectAtIndex:0]
                                          objectForKey:@"Relationships"]objectForKey:@"Currency"] objectForKey:@"Properties"] objectForKey:@"Symbol"];
            NSString *ratedCurrencyId = [[[[[[tskRateDict objectForKey:@"Relationships"] objectForKey:@"Entries"] objectAtIndex:0]
                                           objectForKey:@"Relationships"]objectForKey:@"Currency"] objectForKey:@"Identity"];
            if (ratedCurrency != nil)
                [typeDict setObject:ratedCurrency forKey:@"ratedCurrency"];
            
            if (ratedCurrencyId != nil)
                [typeDict setObject:ratedCurrencyId forKey:@"ratedCurrencyId"];
            
        }else if([tskRateDict isKindOfClass:[NSNull class]]){
            
            type = @"Flat";
            [typeDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"hourlyRate"];
            
            [typeDict setObject:@"" forKey:@"ratedCurrency"];
            [typeDict setObject:@"" forKey:@"ratedCurrencyId"];
        }
        
        if ([[typeDict objectForKey:@"taxCode1"]isEqualToString:@"null"]&&[[typeDict objectForKey:@"taxCode2"]isEqualToString:@"null"]&&
            [[typeDict objectForKey:@"taxCode3"]isEqualToString:@"null"]&&[[typeDict objectForKey:@"taxCode4"]isEqualToString:@"null"]&&
            [[typeDict objectForKey:@"taxCode5"]isEqualToString:@"null"]) {
            type = [type stringByAppendingFormat:@"WithOutTaxes"];
            
        }else {
            type = [type stringByAppendingFormat:@"WithTaxes"];
        }
        [typeDict setObject:type forKey:@"type"];
        //[myDB insertIntoTable:tableName3 data:typeDict intoDatabase:@""];//DE3455
        NSString *placeString=[NSString stringWithFormat:@"identity='%@' ",identity]; //DE3455
        
        NSMutableArray *expenseArr = [myDB select:@"*" from: tableName3 where:placeString intoDatabase:@""];
        if ([expenseArr count]>0) {
            [myDB updateTable: tableName3 data:typeDict where:placeString intoDatabase:@""];
        }else {
            [myDB insertIntoTable:tableName3 data:typeDict intoDatabase:@""];
        }
    }

}

- (void)insertExpenseNonProjectSpecificTypesWithTaxCodesInToDatabase:(NSArray *) expenseTypeArray {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *identity = @"null";
	
	/*ProjectPermissionType permType = [PermissionsModel getProjectPermissionType];
     if (permType == PermType_Both)	{
     if ([[self getExpenseTypesWithTaxCodesFromDatabase]count]>0) {
     //[myDB deleteFromTable:tableName3 inDatabase:@""];
     [myDB deleteFromTable:tableName3 where:[NSString stringWithFormat:@"projectIdentity ='%@'",@"null"] inDatabase:@""];
     }else {
     }
     }else {
     [myDB deleteFromTable:tableName3 inDatabase:@""];
     }*/
	
	//[myDB deleteFromTable:tableName3 inDatabase:@""];
	
	
	NSMutableDictionary *typeDict = [NSMutableDictionary dictionary];
	
	for (int i=0; i<[expenseTypeArray count]; i++) {
		NSDictionary *_expenseType = [expenseTypeArray objectAtIndex: i];
//		[typeDict setObject:@"null" forKey:@"projectIdentity"];
		identity = [_expenseType objectForKey:@"Identity"];
		[typeDict setObject:identity forKey:@"identity"];
		[typeDict setObject:[[_expenseType objectForKey:@"Properties"] objectForKey:@"Name"] forKey:@"name"];
		
		NSString *expenseUnitLable=[[_expenseType objectForKey:@"Properties"] objectForKey:@"ExpenseUnitLabel"];
		if ([expenseUnitLable isKindOfClass:[NSNull class]]) {
			expenseUnitLable=@"";
		}else {
			
		}
		[typeDict setObject:expenseUnitLable forKey:@"expenseUnitLabel"];
		
		NSNumber *disabledFlag=[[_expenseType objectForKey:@"Properties"] objectForKey:@"Disabled"];
		
		if (disabledFlag !=nil && ![disabledFlag isKindOfClass:[NSNull class]]) {
			[typeDict setObject:disabledFlag forKey:@"isDisabled"]; 
		}
		//[typeDict setObject:[[_expenseType objectForKey:@"Properties"] objectForKey:@"ExpenseUnitLabel"] forKey:@"expenseUnitLabel"];
		
		//Formulas for ExpenseTypes................
		for (int x=1; x<= Max_No_Taxes_5 ; x++) {
			id formulaValue = [[_expenseType objectForKey:@"Properties"] objectForKey:[NSString stringWithFormat:@"Formula%d",x]] ;
			if (formulaValue!=nil &&  ![formulaValue isKindOfClass:[NSNull class]]) {
				[typeDict setObject:formulaValue forKey:[NSString stringWithFormat:@"formula%d",x]];	
			}else {
				[typeDict setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",x]];	
			}
			
		}
		
		NSString *type=nil;
		id tskRateDict = [[_expenseType objectForKey:@"Relationships"] objectForKey:@"TskRate"];
		if([tskRateDict isKindOfClass:[NSDictionary class]]){
			type = @"Rated";
			NSNumber *hourlyRate=[[[[[tskRateDict objectForKey:@"Relationships"] objectForKey:@"Entries"] objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"HourlyRate"];
			[typeDict setObject:hourlyRate forKey:@"hourlyRate"]; 
			
			NSString *ratedCurrency = [[[[[[[tskRateDict objectForKey:@"Relationships"] objectForKey:@"Entries"] objectAtIndex:0]
                                          objectForKey:@"Relationships"]objectForKey:@"Currency"] objectForKey:@"Properties"] objectForKey:@"Symbol"];
			NSString *ratedCurrencyId = [[[[[[tskRateDict objectForKey:@"Relationships"] objectForKey:@"Entries"] objectAtIndex:0]
                                           objectForKey:@"Relationships"]objectForKey:@"Currency"] objectForKey:@"Identity"];
			if (ratedCurrency != nil)
				[typeDict setObject:ratedCurrency forKey:@"ratedCurrency"];
			
			if (ratedCurrencyId != nil)
				[typeDict setObject:ratedCurrencyId forKey:@"ratedCurrencyId"];
			
		}else if([tskRateDict isKindOfClass:[NSNull class]]){
			
			type = @"Flat";
			[typeDict setObject:[NSNumber numberWithFloat:0.0] forKey:@"hourlyRate"]; 
			
			[typeDict setObject:@"" forKey:@"ratedCurrency"];
			[typeDict setObject:@"" forKey:@"ratedCurrencyId"];
		}
		
		id taxcode1Dict = [[_expenseType objectForKey:@"Relationships"] objectForKey:@"TaxCode1"];
		if([taxcode1Dict isKindOfClass:[NSDictionary class]]){
			[typeDict setObject:[taxcode1Dict objectForKey:@"Identity"] forKey:@"taxCode1"];
		}else if([taxcode1Dict isKindOfClass:[NSNull class]]){
			[typeDict setObject:@"null" forKey:@"taxCode1"];
		}
		
		id taxcode2Dict = [[_expenseType objectForKey:@"Relationships"] objectForKey:@"TaxCode2"];
		if([taxcode2Dict isKindOfClass:[NSDictionary class]]){
			[typeDict setObject:[taxcode2Dict objectForKey:@"Identity"] forKey:@"taxCode2"];
		}else if([taxcode2Dict isKindOfClass:[NSNull class]]){
			[typeDict setObject:@"null" forKey:@"taxCode2"];
		}
		
		id taxcode3Dict = [[_expenseType objectForKey:@"Relationships"] objectForKey:@"TaxCode3"];
		if([taxcode3Dict isKindOfClass:[NSDictionary class]]){
			[typeDict setObject:[taxcode3Dict objectForKey:@"Identity"] forKey:@"taxCode3"];
		}else if([taxcode3Dict isKindOfClass:[NSNull class]]){
			[typeDict setObject:@"null" forKey:@"taxCode3"];
		}
		
		id taxcode4Dict = [[_expenseType objectForKey:@"Relationships"] objectForKey:@"TaxCode4"];
		if([taxcode4Dict isKindOfClass:[NSDictionary class]]){
			[typeDict setObject:[taxcode4Dict objectForKey:@"Identity"] forKey:@"taxCode4"];
		}else if([taxcode4Dict isKindOfClass:[NSNull class]]){
			[typeDict setObject:@"null" forKey:@"taxCode4"];
		}
		
		id taxcode5Dict = [[_expenseType objectForKey:@"Relationships"] objectForKey:@"TaxCode5"];
		if([taxcode5Dict isKindOfClass:[NSDictionary class]]){
			[typeDict setObject:[taxcode5Dict objectForKey:@"Identity"] forKey:@"taxCode5"];
		}else if([taxcode5Dict isKindOfClass:[NSNull class]]){
			[typeDict setObject:@"null" forKey:@"taxCode5"];
		}
		
		if ([[typeDict objectForKey:@"taxCode1"]isEqualToString:@"null"]&&[[typeDict objectForKey:@"taxCode2"]isEqualToString:@"null"]&&
			[[typeDict objectForKey:@"taxCode3"]isEqualToString:@"null"]&&[[typeDict objectForKey:@"taxCode4"]isEqualToString:@"null"]&&
			[[typeDict objectForKey:@"taxCode5"]isEqualToString:@"null"]) {
			type = [type stringByAppendingFormat:@"WithOutTaxes"];
			
		}else {
			type = [type stringByAppendingFormat:@"WithTaxes"];
		}
		[typeDict setObject:type forKey:@"type"];
		//[myDB insertIntoTable:tableName3 data:typeDict intoDatabase:@""];//DE3455
//        NSString *placeString=[NSString stringWithFormat:@"identity='%@' and projectIdentity = '%@'",identity, @"null"];//DE3455
        NSString *placeString=[NSString stringWithFormat:@"identity='%@'",identity];
        NSMutableArray *expenseArr = [myDB select:@"*" from: tableName3 where:placeString intoDatabase:@""];
         NSDictionary *expense_project_type_dict=[NSDictionary dictionaryWithObjectsAndKeys:@"null",@"projectIdentity",identity,@"expenseTypeIdentity", nil];
        if ([expenseArr count]>0) {
            [myDB updateTable: tableName3 data:typeDict where:placeString intoDatabase:@""];
              NSString *placeString=[NSString stringWithFormat:@"expenseTypeIdentity='%@' and projectIdentity = '%@'",identity, @"null"];
            [myDB updateTable: tableName10 data:expense_project_type_dict where:placeString intoDatabase:@""];
        }else {
            [myDB insertIntoTable:tableName3 data:typeDict intoDatabase:@""];
             [myDB insertIntoTable:tableName10 data:expense_project_type_dict intoDatabase:@""];
        }
		
	}
	
}


-(void)insertExpenseClientsInToDatabase:(NSMutableArray *) clientsArray{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *identity = @"null";
	
	if ([[self getExpenseClientsFromDatabase]count]>0) {
		//[myDB deleteFromTable:tableName4 inDatabase:@""];//not to delete its updated on login..
	}
	
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	if (permType == PermType_NonProjectSpecific)	{
		NSMutableArray *projectsArray=[self getExpenseProjectsFromDatabase];
		NSString *clientId=nil;
		for (int x=0; x<[projectsArray count]; x++) {
			clientId=[[projectsArray objectAtIndex:x] objectForKey:@"clientIdentity"];
			if ([clientsArray count]==0 || [clientId isEqualToString:@"null"]) {
				NSDictionary *propertyDict = [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING,@""),@"Name",nil];
				NSDictionary *clientNoneDict=[NSDictionary dictionaryWithObjectsAndKeys:@"null",@"Identity",propertyDict,@"Properties",nil];
				[clientsArray insertObject:clientNoneDict atIndex:0];
				break;
			}
		}
		
		
	}
	
	if (permType == PermType_Both)	{
		NSDictionary *propertyDict = [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING,@""),@"Name",nil];
		NSDictionary *clientNoneDict=[NSDictionary dictionaryWithObjectsAndKeys:@"null",@"Identity",propertyDict,@"Properties",nil];
		[clientsArray insertObject:clientNoneDict atIndex:0];
	}
	NSString *name = nil;
	for (int i=0; i<[clientsArray count]; i++) {
		if([[[[clientsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"] isKindOfClass:[NSNull class]]){
			name = @"null";
		}else {
			name = [[[clientsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"];
		}
		
		identity = [[clientsArray objectAtIndex:i]objectForKey:@"Identity"];
		
		NSMutableDictionary *clientDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:
											   //identityNum,@"id",
											   identity,@"identity",
											   name,@"name",nil];
		//updated code for support client/projects in login...........
		[clientDictionary setObject:[NSNumber numberWithInt:1] forKey:@"expensesAllowed"];
		
		NSMutableArray *clientsExistArray=nil;
		if (identity!=nil && ![identity isKindOfClass:[NSNull class]] ) {
			NSString *querStr=[NSString stringWithFormat:@"select * from clients where identity = '%@' ",identity];
			clientsExistArray=[myDB executeQueryToConvertUnicodeValues:querStr];
		}
		
		if(clientsExistArray!=nil && [clientsExistArray count]>0){
			NSString *placeString=[NSString stringWithFormat:@"identity='%@'",identity];
			[myDB updateTable:tableName4 data:clientDictionary where:placeString intoDatabase:@""];
			
			[clientsExistArray removeAllObjects];
		}else {
			if ([identity isEqualToString:@"null"])
				[clientDictionary setObject:[NSNumber  numberWithInt:0] forKey:@"id"];
			
			[myDB insertIntoTable:tableName4 data:clientDictionary intoDatabase:@""];
		}
		
		//[myDB insertIntoTable:tableName4 data:clientDictionary intoDatabase:@""];
	}
	
}
-(void)insertExpenseProjectsByClient:(NSArray*)projectsToClientArray clientID:(NSString*)clientId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *identity = @"null";
	//NSNumber *identityNum = 0;
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	if (permType == PermType_Both)	{
		if ([[self getExpenseProjectsFromDatabase]count]>0) {
			[myDB deleteFromTable:tableName5 inDatabase:@""];
		}
	}
	NSString *expenseEntryStartDate,*expenseEntryEndDate;
	for (int i=0; i<[projectsToClientArray count]; i++) {
		identity = [[projectsToClientArray objectAtIndex:i]objectForKey:@"Identity"];
		
		id expenseEntryStartDateDict =  [[[projectsToClientArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ExpenseEntryStartDate"];
		id expenseEntryEndDateDict =  [[[projectsToClientArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ExpenseEntryEndDate"];
		
		if([expenseEntryStartDateDict objectForKey:@"Future"]!=nil || [expenseEntryStartDateDict objectForKey:@"Past"]!=nil){
			expenseEntryStartDate = @"null";
			
		}else {
			int month = [[expenseEntryStartDateDict objectForKey:@"Month"]intValue];
			expenseEntryStartDate =[NSString stringWithFormat:@"%@ %@,%@", [G2Util getMonthNameForMonthId:month],[expenseEntryStartDateDict objectForKey:@"Day"]
									,[expenseEntryStartDateDict objectForKey:@"Year"]];
		}
		
		if([expenseEntryEndDateDict objectForKey:@"Future"]!=nil || [expenseEntryEndDateDict objectForKey:@"Past"]!=nil){
			expenseEntryEndDate = @"null";
		}else {
			int month = [[expenseEntryEndDateDict objectForKey:@"Month"]intValue];
			expenseEntryEndDate =[NSString stringWithFormat:@"%@ %@,%@", [G2Util getMonthNameForMonthId:month],[expenseEntryEndDateDict objectForKey:@"Day"]
								  ,[expenseEntryEndDateDict objectForKey:@"Year"]];
		}
		NSString *closedStatus = [[[[projectsToClientArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ClosedStatus"] stringValue];
		NSDictionary *projectByClientsDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
												  //identityNum ,@"id",
												  identity,@"identity",
												  [[[projectsToClientArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"],@"Name",
												  clientId,@"clientIdentity",
												  closedStatus,@"closedStatus",
												  expenseEntryStartDate ,@"expenseEntryStartDate",
												  expenseEntryEndDate,@"expenseEntryEndDate",
												  [[[projectsToClientArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ProjectCode"] ,@"code",
												  nil];
		[myDB insertIntoTable:tableName5 data:projectByClientsDictionary intoDatabase:@""];
		
	}
}

-(void)insertExpenseProjectsInToDatabase:(NSMutableArray *) projectsArray withBoolValue:(BOOL)forRecent
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if ([[self getExpenseProjectsFromDatabase]count]>0) {
		//[myDB deleteFromTable:tableName5 inDatabase:@""];//not to do here its already done at login...
	}
	
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	if (permType == PermType_Both)	{
		NSDictionary *propertyDict = [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING,@""),@"Name",@"0",@"ClosedStatus",
									  @"null",@"ProjectCode",@"null",@"ExpenseEntryStartDate",
									  @"null",@"ExpenseEntryEndDate",nil];
		NSDictionary *projectNoneDict=[NSDictionary dictionaryWithObjectsAndKeys:@"null",@"Identity",propertyDict,@"Properties",nil];
		[projectsArray insertObject:projectNoneDict atIndex:0];
	}
	
	
	NSString *expenseEntryStartDate=nil,*expenseEntryEndDate=nil;
	
	for (int i=0; i<[projectsArray count]; i++) {
		NSString *identity = [[projectsArray objectAtIndex:i]objectForKey:@"Identity"];
		
		id expenseEntryStartDateDict =  [[[projectsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ExpenseEntryStartDate"];
		id expenseEntryEndDateDict =  [[[projectsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ExpenseEntryEndDate"];
		
		if([expenseEntryStartDateDict isKindOfClass:[NSDictionary class]]){
			if([expenseEntryStartDateDict objectForKey:@"Future"]!=nil || [expenseEntryStartDateDict objectForKey:@"Past"]!=nil){
				expenseEntryStartDate = @"null";
				
			}else {
				int month = [[expenseEntryStartDateDict objectForKey:@"Month"]intValue];
				expenseEntryStartDate =[NSString stringWithFormat:@"%@ %@,%@", [G2Util getMonthNameForMonthId:month],[expenseEntryStartDateDict objectForKey:@"Day"]
										,[expenseEntryStartDateDict objectForKey:@"Year"]];
			}
		}else {
			expenseEntryStartDate = @"null";
		}
		
		if([expenseEntryStartDateDict isKindOfClass:[NSDictionary class]]){
			
			if([expenseEntryEndDateDict objectForKey:@"Future"]!=nil || [expenseEntryEndDateDict objectForKey:@"Past"]!=nil){
				expenseEntryEndDate = @"null";
			}else {
				int month = [[expenseEntryEndDateDict objectForKey:@"Month"]intValue];
				expenseEntryEndDate =[NSString stringWithFormat:@"%@ %@,%@", [G2Util getMonthNameForMonthId:month],[expenseEntryEndDateDict objectForKey:@"Day"]
									  ,[expenseEntryEndDateDict objectForKey:@"Year"]];
			}
		}else {
			expenseEntryEndDate = @"null";
		}
		
		NSMutableDictionary *projectsDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:
												 //identityNum ,@"id",
												 identity,@"identity",
												 [[[projectsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"],@"Name",
												 //@"null",@"clientIdentity",
												 // clientId,@"clientIdentity",	
												 [[[projectsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ClosedStatus"],@"closedStatus",
												 expenseEntryStartDate ,@"expenseEntryStartDate",
												 expenseEntryEndDate,@"expenseEntryEndDate",
												 [[[projectsArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"ProjectCode"] ,@"code",[NSNumber numberWithBool:forRecent],@"isExpensesRecent",
												 nil];
		
		
		[projectsDictionary setObject:[NSNumber numberWithInt:1] forKey:@"expensesAllowed"];
		
		
		NSMutableDictionary *projectBillingTypeDict=nil;	//fixed memory leak
		NSString*allocationId=nil;
		
		ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
		
		if (permType == PermType_Both) {
			if ( i ==0) {
				
			}else {
				
				projectBillingTypeDict=[[[projectsArray objectAtIndex:i]objectForKey:@"Relationships"]
										objectForKey:@"ClientBillingAllocationMethod"];
				NSDictionary *allocationMethodDict=nil;
				
                //	NSString *allocationTypeName=nil;		//fixed memory leak
				if (projectBillingTypeDict!=nil && [projectBillingTypeDict isKindOfClass:[NSDictionary class]]) {
					allocationId=[projectBillingTypeDict objectForKey:@"Identity"];
					if (allocationId!=nil) {
						[projectsDictionary setObject:allocationId forKey:@"allocationMethodId"];
					}
					allocationMethodDict=[projectBillingTypeDict objectForKey:@"Properties"];
					if (allocationMethodDict!=nil && [allocationMethodDict isKindOfClass:[NSNull class]]) {
                        //	allocationTypeName=[projectBillingTypeDict objectForKey:@"Name"];	//fixed memory leak
					}
				}
				
			}
		}else if (permType == PermType_ProjectSpecific)	{
			projectBillingTypeDict=[[[projectsArray objectAtIndex:i]objectForKey:@"Relationships"]
									objectForKey:@"ClientBillingAllocationMethod"];
			NSDictionary *allocationMethodDict=nil;
			
            //	NSString *allocationTypeName=nil;			//fixed memory leak
			if (projectBillingTypeDict!=nil && [projectBillingTypeDict isKindOfClass:[NSDictionary class]]) {
				allocationId=[projectBillingTypeDict objectForKey:@"Identity"];
				if (allocationId!=nil) {
					[projectsDictionary setObject:allocationId forKey:@"allocationMethodId"];
				}
				allocationMethodDict=[projectBillingTypeDict objectForKey:@"Properties"];
				if (allocationMethodDict!=nil && [allocationMethodDict isKindOfClass:[NSNull class]]) {
                    //	allocationTypeName=[projectBillingTypeDict objectForKey:@"Name"];	//fixed memory leak
				}
			}
			
		}
		
		NSDictionary *billableDict = [[[projectsArray objectAtIndex:i]objectForKey:@"Relationships"] 
									  objectForKey:@"Billable"];
		
		if (billableDict != nil && [billableDict isKindOfClass:[NSDictionary class]]) {
			NSString *billingType = [billableDict objectForKey:@"Identity"];
			[projectsDictionary setObject:billingType forKey:@"billingStatus"];
		}
		
		NSDictionary *rootTaskDict = [[[projectsArray objectAtIndex:i]objectForKey:@"Relationships"] 
									  objectForKey:@"RootTask"];
		
		if (rootTaskDict != nil && [rootTaskDict isKindOfClass:[NSDictionary class]]) {
			NSString *rootTask = [rootTaskDict objectForKey:@"Identity"];
			[projectsDictionary setObject:rootTask forKey:@"rootTaskIdentity"];
		}
		
		NSString *clientId=nil;
		id projectClientsArray =  [[[projectsArray objectAtIndex:i]objectForKey:@"Relationships"] 
								   objectForKey:@"ProjectClients"];
		
		if (projectClientsArray!=nil && [projectClientsArray count]>0) {
			for (int x=0; x<[projectClientsArray count]; x++) {
				id clientsDict=[[[projectClientsArray objectAtIndex:x]objectForKey:@"Relationships" ] objectForKey:@"Client"];
				clientId=[clientsDict objectForKey:@"Identity"];
				[projectsDictionary setObject:clientId forKey:@"clientIdentity"];
				//updated code for support client/projects in login...........
				
				NSMutableArray *projArray=nil;
				if (identity!=nil && ![identity isKindOfClass:[NSNull class]] ) {
					NSString *querStr=[NSString stringWithFormat:@"select * from projects where identity = '%@' and clientIdentity = '%@' ",identity,clientId];
					//projArray=[myDB executeQuery:querStr];
					projArray=[myDB executeQueryToConvertUnicodeValues:querStr];
				}
				if(projArray!=nil && [projArray count]>0){
					NSString *placeString=[NSString stringWithFormat:@"identity = '%@' and clientIdentity = '%@' ",identity,clientId];
					[projectsDictionary removeObjectForKey:@"isExpensesRecent"];
					[myDB updateTable:tableName5 data:projectsDictionary where:placeString intoDatabase:@""];
					[projArray removeAllObjects];
				}else {
					[projectsDictionary setObject:[NSNumber numberWithInt:0] forKey:@"timeEntryAllowed"];
					[projectsDictionary setObject:[NSNumber numberWithInt:0] forKey:@"hasTasks"];
					[myDB insertIntoTable:tableName5 data:projectsDictionary intoDatabase:@""];
				}
				
			}
		}
        else {
			clientId=@"null";
			[projectsDictionary setObject:clientId forKey:@"clientIdentity"];
			//updated code for support client/projects in login...........
			NSMutableArray *projArray=nil;
			if (identity!=nil && ![identity isKindOfClass:[NSNull class]] ) {
				NSString *querStr=[NSString stringWithFormat:@"select * from projects where identity = '%@' and clientIdentity = '%@' ",identity,clientId];
				//projArray=[myDB executeQuery:querStr];
				projArray=[myDB executeQueryToConvertUnicodeValues:querStr];
			}
			if(projArray!=nil && [projArray count]>0){
                [projectsDictionary removeObjectForKey:@"isExpensesRecent"];
				[myDB updateTable:tableName5 data:projectsDictionary where:[NSString stringWithFormat:@"identity = '%@' and clientIdentity = '%@' ",identity,clientId] intoDatabase:@""];
				[projArray removeAllObjects];
			}else {
				if ([identity isEqualToString:@"null"])
					[projectsDictionary setObject:[NSNumber  numberWithInt:0] forKey:@"id"];//inserted deliberately for /None Project 
				[myDB insertIntoTable:tableName5 data:projectsDictionary intoDatabase:@""];
			}
			
			//[myDB insertIntoTable:tableName5 data:projectsDictionary intoDatabase:@""];
		}
		
	}
	
}

-(void) insertUdfsforEntryIntoDatabase:(NSMutableArray *)expensesArray {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	for (int i=0; i<[expensesArray count]; i++) {
		
		for (int j=0; j<[[[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Entries"] count]; j++) {
			
			NSString *entryId = [[[[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Entries"] 
								  objectAtIndex:j] objectForKey:@"Identity"];
			NSDictionary *udfsDict = [[[[[expensesArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Entries"] 
									   objectAtIndex:j] objectForKey:@"UserDefinedFields"];
			
			if (udfsDict != nil) {
				NSArray *udfNameArray = [udfsDict allKeys];
				for (NSString *udfName in udfNameArray) {
					
					id udfValue = nil;
					if ([[udfsDict objectForKey:udfName] isKindOfClass:[NSDictionary class]]) {
						NSDictionary *udfDateDict = [udfsDict objectForKey:udfName];
						udfValue = [NSString stringWithFormat:@"%@ %@, %@",
									[G2Util getMonthNameForMonthId: [[udfDateDict objectForKey:@"Month"] intValue] ],
									[udfDateDict objectForKey:@"Day"],
									[udfDateDict objectForKey:@"Year"]];
					}else if (![[udfsDict objectForKey:udfName] isKindOfClass:[NSNull class]]) {
						if([[udfsDict objectForKey:@"udfValue"] isKindOfClass:[NSNumber class]]) {
							udfValue = [NSString stringWithFormat:@"%lf",[[udfsDict objectForKey:@"udfValue"] doubleValue]];
						}else {
							udfValue = [udfsDict objectForKey:udfName];
						}
                        
						
					}
					
					NSString *udfIdentity = [self getUDFIdForName:udfName];
					NSDictionary *entryUdfDict = [NSDictionary dictionaryWithObjectsAndKeys:
												  udfName,@"udf_name",
												  udfIdentity,@"udf_id",
												  udfValue, @"udfValue",
												  @"Expense",@"entry_type",
												  entryId, @"entry_id",
												  nil];
                    //Fix for DE3380//Juhi
                    NSString *whereString = [NSString stringWithFormat:@"udf_id = '%@' and entry_id = '%@'",
                                             udfIdentity,entryId];
                    [myDB deleteFromTable:tableName7 where:whereString inDatabase:@""];
					BOOL udfexists = [self checkUDFExistsForEntry: udfIdentity : entryId];
					if (udfexists) {
                        //Fix for DE3380//Juhi
                        //						NSString *whereString = [NSString stringWithFormat:@"udf_id = '%@' and entry_id = '%@'",
                        //												 udfIdentity,entryId];
						[myDB updateTable:tableName7 data:entryUdfDict where:whereString intoDatabase:@""];
					}else {
						[myDB insertIntoTable:tableName7 data:entryUdfDict intoDatabase:@""];
					}
					
					
					
				}
			}
		}
	}
}

#pragma mark SELECT

-(NSMutableArray *)getExpenseSheetsFromDataBase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSMutableArray *expenseSheetsArr = [myDB select:@"*" from:tableName1 where:@"" intoDatabase:@""];
	NSString *query=[NSString stringWithFormat:@"select * from %@ order by trackingNumber  desc ", table_ExpenseSheets];
	//NSMutableArray *expenseSheetsArr = [myDB executeQuery:query];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	
    for (int i=0; i<[expenseSheetsArr count]; i++)
    {
        NSMutableDictionary *expenseDict=[NSMutableDictionary dictionaryWithDictionary:[expenseSheetsArr objectAtIndex:i]];
        if ([expenseDict objectForKey:@"expenseDate"]!=nil && ![[expenseDict objectForKey:@"expenseDate"] isKindOfClass:[NSNull class]]) {
            NSString *expenseDate=[G2Util getDeviceRegionalDateString:[expenseDict objectForKey:@"expenseDate"] ];
            [expenseDict setObject:expenseDate forKey:@"expenseDate"];
        }
       
        [expenseSheetsArr replaceObjectAtIndex:i withObject:expenseDict];
    }
    
	//[myDB select:@"*" from:tableName1 where:@"" intoDatabase:@""];
	if ([expenseSheetsArr count]>0) {
		return expenseSheetsArr;
	}
	return nil;
}

-(BOOL)isApprovedExpenseSheetsAvailable{
	@try {
		G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
		NSMutableArray *expenseSheetsArr = [myDB select:@"*" from: table_ExpenseSheets where:@"status= 'Approved' " intoDatabase:@""];
		if ([expenseSheetsArr count]!=0) {
			return YES;
		}
		return NO;
	}
	@catch (NSException * e) {
		DLog(@"Exception: isApproved ExpenseSheets: %@", e);
		return NO;
	}
	@finally {
	}
	
}


-(NSMutableArray *)getSelectedExpenseSheetInfoFromDb:(NSString*)sheetIdentity
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *queryStr=[NSString stringWithFormat:@"select * from %@ where identity= '%@' and editStatus <> 'delete' ", table_ExpenseSheets, sheetIdentity];
	//NSMutableArray *expenseEntriesArr = [myDB executeQuery:queryStr];
	NSMutableArray *expenseEntriesArr = [myDB executeQueryToConvertUnicodeValues:queryStr];
	if ([expenseEntriesArr count]!=0) {
		return expenseEntriesArr;
	}
	return nil;
}

-(NSMutableArray *)getExpenseEntriesFromDatabase{
	/*SQLiteDB *myDB = [SQLiteDB getInstance];
	 NSMutableArray *expenseEntriesArr = [myDB select:@"*" from:tableName2 where:@"" intoDatabase:@""];
	 if ([expenseEntriesArr count]!=0) {
	 return expenseEntriesArr;
	 }
	 return nil;*/
	
	//done for offline delete support
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *whereStr=@"isModified=0 and editStatus <> 'delete'";
	NSString *queryStr=[NSString stringWithFormat:@"select * from %@ where editStatus <> 'delete' ", table_expenseEntries];
	NSMutableArray *expenseEntriesArr = [myDB executeQueryToConvertUnicodeValues:queryStr];
    
    for (int i=0; i<[expenseEntriesArr count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[expenseEntriesArr objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [expenseEntriesArr replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
    
    
	if ([expenseEntriesArr count]!=0) {
		return expenseEntriesArr;
	}
	return nil;
	
	
	
}

-(NSMutableArray *)getExpenseClientsForProjectSpecificFromDatabase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select c.identity,c.name from clients c,projects p where c.identity=p.clientIdentity"];
	//NSMutableArray *clientsArr = [myDB executeQuery:sql];
	NSMutableArray *clientsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	
	if ([clientsArr count]!=0) {
		return clientsArr;
	}
	return nil;
	
}

-(NSMutableArray *)getExpenseClientsFromDatabase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *sqlQuer = [NSString stringWithFormat:@"select * from clients where  expensesAllowed =  %@",[NSNumber numberWithInt:1]];
	//NSString *selectString = @"select distinct(c.name) from clients c,projects p where c.identity = p.clientIdentity and p.timeEntryAllowed = 1 order by c.name";
	//NSString *sqlQuer = @"select  c.* from clients c,projects p where c.identity = p.clientIdentity and p.expensesAllowed = 1 group by c.identity order by c.id";
	NSString *sqlQuer = @"select  c.* from clients c,projects p where c.identity = p.clientIdentity and p.expensesAllowed = 1 group by c.identity order by c.name";
	//NSMutableArray *clientsArr = [myDB select:@"*" from:tableName4 where:@"" intoDatabase:@""];
	//NSString *sql = [NSString stringWithFormat:@"select * from projects where  group by clientIdentity",@""];
	//NSMutableArray *clientsArr = [myDB executeQuery:sqlQuer];
	NSMutableArray *clientsArr = [myDB executeQueryToConvertUnicodeValues:sqlQuer];
	
	if ([clientsArr count]!=0) {
		int index = [G2Util getObjectIndex:clientsArr withKey:@"name" forValue:RPLocalizedString(NONE_STRING,@"")];
		if (index != -1) {
			NSMutableDictionary *noneClientDict = [[NSMutableDictionary alloc]initWithDictionary:[clientsArr objectAtIndex:index]];
			[clientsArr removeObjectAtIndex:index];
			[clientsArr insertObject:noneClientDict atIndex:0];
			
		}
		return clientsArr;
	}
	return nil;
	
}

-(NSMutableArray*)getClientsForBucketProjects:(NSString*)projectId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from projects where identity='%@' and expensesAllowed = 1",projectId];
	//NSMutableArray *clientsArr = [myDB executeQuery:sql];
	NSMutableArray *clientsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([clientsArr count]>0) {
		return clientsArr;
	}
	return nil;
	
}

-(NSMutableArray *)getExpenseProjectIdentitiesFromDatabase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *projSql=[NSString stringWithFormat:@" select identity from %@ where expensesAllowed = 1",tableName5];
	NSMutableArray *projectIdsArr=[myDB executeQueryToConvertUnicodeValues:projSql];
	if ([projectIdsArr count]!=0) {
		return projectIdsArr;
	}
	
    
	return nil;
	
}

-(NSMutableArray *)getExpenseProjectsFromDatabase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSMutableArray *projectsArr = [myDB select:@"*" from:tableName5 where:@"" intoDatabase:@""];
	NSString *projSql=[NSString stringWithFormat:@" select * from %@ where expensesAllowed = 1",tableName5];
	NSMutableArray *projectsArr=[myDB executeQueryToConvertUnicodeValues:projSql];
	if ([projectsArr count]!=0) {
		return projectsArr;
	}
	return nil;
	
}
-(NSMutableArray *)getExpenseProjectsForSelectedClientID:(NSString*)_clientIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *placeString=[NSString stringWithFormat:@"clientIdentity='%@'",_clientIdentity];
	// NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientIdentity  = '%@' and expensesAllowed = %@",tableName5,_clientIdentity,[NSNumber numberWithInt:1]];	
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientIdentity  = '%@' and expensesAllowed = %@  and closedStatus = %@ order by name",tableName5,_clientIdentity,[NSNumber numberWithInt:1],[NSNumber numberWithInt:0]];
	//NSMutableArray *projectsArr = [myDB executeQuery:sql];
	NSMutableArray *projectsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([projectsArr count]!=0) {
		int index = [G2Util getObjectIndex:projectsArr withKey:@"name" forValue:RPLocalizedString(NONE_STRING,@"")];
		if (index != -1) {
			NSMutableDictionary *noneProjDict = [[NSMutableDictionary alloc]initWithDictionary:[projectsArr objectAtIndex:index]];
			[projectsArr removeObjectAtIndex:index];
			[projectsArr insertObject:noneProjDict atIndex:0];
			
		}
		
		return projectsArr;
	}
	return nil;
	
}

-(NSMutableArray *)getRecentExpenseProjectsForSelectedClientID:(NSString*)_clientIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *placeString=[NSString stringWithFormat:@"clientIdentity='%@'",_clientIdentity];
	// NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientIdentity  = '%@' and expensesAllowed = %@",tableName5,_clientIdentity,[NSNumber numberWithInt:1]];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientIdentity  = '%@' and expensesAllowed = %@ and isExpensesRecent=%@ and closedStatus = %@ order by name",tableName5,_clientIdentity,[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:0]];
	//NSMutableArray *projectsArr = [myDB executeQuery:sql];
	NSMutableArray *projectsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([projectsArr count]!=0) {
		int index = [G2Util getObjectIndex:projectsArr withKey:@"name" forValue:RPLocalizedString(NONE_STRING,@"")];
		if (index != -1) {
			NSMutableDictionary *noneProjDict = [[NSMutableDictionary alloc]initWithDictionary:[projectsArr objectAtIndex:index]];
			[projectsArr removeObjectAtIndex:index];
			[projectsArr insertObject:noneProjDict atIndex:0];
			
		}
		
		return projectsArr;
	}
	return nil;
	
}

-(NSMutableArray*)getEntriesforSelected:(NSInteger)selectedIndex  WithExpenseSheetArr:(NSArray *)expArray
{
	
	/*NSString *placeString=[NSString stringWithFormat:@"expense_sheet_identity='%@'",[[expArray objectAtIndex:selectedIndex] objectForKey:@"identity"]];
	 SQLiteDB *myDB  = [SQLiteDB getInstance];
	 NSMutableArray *subExpenseArray = [myDB select:@"*" from:tableName2 where:placeString intoDatabase:@""];
	 return subExpenseArray;*/
	
	//done for offline delete support
	NSString *placeString=[NSString stringWithFormat:@"expense_sheet_identity='%@'  and editStatus <> 'delete'",[[expArray objectAtIndex:selectedIndex] objectForKey:@"identity"]];
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *subExpenseArray = [NSMutableArray arrayWithArray:[myDB select:@"*" from: table_expenseEntries where:placeString intoDatabase:@""]];
    for (int i=0; i<[subExpenseArray count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[subExpenseArray objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [subExpenseArray replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
    
	return subExpenseArray;
	
	
}
-(NSMutableArray *)getCurrenciesInfoForExpenseSheetID:(NSString *)_expenseSheetID{
	//NSString *placeString=[NSString stringWithFormat:@"expense_sheet_identity=%@",_expenseSheetID];
	NSString *placeString=[NSString stringWithFormat:@"expense_sheet_identity=%@  and editStatus <> 'delete' ",_expenseSheetID];//done for offline delete support
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *currenciesArray = [myDB select:@"currencyType,netAmount" from: table_expenseEntries where:placeString intoDatabase:@""];
	return currenciesArray;
}
-(NSMutableArray *)getExpenseTypesWithTaxCodesFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	//NSMutableArray *expenseArr = [myDB select:@"*" from:tableName3 where:@"" intoDatabase:@""];
	NSString *query=[NSString stringWithFormat:@" select * from expenseTypes "];
	NSMutableArray *expenseArr = [myDB executeQueryToConvertUnicodeValues:query];
	//[myDB select:@"*" from:tableName3 where:@"" intoDatabase:@""];
	
	return expenseArr;
}		 
//De4433//Juhi
- (NSMutableArray *) getExpenseTypesWithTaxCodesForNonProject {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *sql = [NSString stringWithFormat:@"select * from '%@' where projectIdentity  = '%@' and isDisabled = 0 order by name ",tableName3,identity ];// DE3455
    NSString *sql = [NSString stringWithFormat:@"select * from '%@' where isDisabled = 0 group by name order by name ",tableName3 ];
	//NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	return expenseTypeArray;
}
+(NSString*)getTotalReimbursementForExpenseSheet:(NSString*)sheetId
{
	
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *expenseArray = [myDB select:@"*" from: table_ExpenseSheets where:[NSString stringWithFormat:@"identity=%@",sheetId] intoDatabase:@""];
	NSString *totalReimburseCurrency=[[expenseArray objectAtIndex:0] objectForKey:@"totalReimbursement"];
	return totalReimburseCurrency;
	
}
- (NSMutableArray *) getExpenseTypesWithTaxCodesForSelectedProjectId:(NSString*) identity {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *sql = [NSString stringWithFormat:@"select * from '%@' where projectIdentity  = '%@' and isDisabled = 0 order by name ",tableName3,identity ];// DE3455
//    NSString *sql = [NSString stringWithFormat:@"select * from '%@' where projectIdentity  = '%@' and isDisabled = 0 group by name order by name ",tableName3,identity ];
     NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.projectIdentity  = '%@'  and %@.identity=%@.expenseTypeIdentity and %@.isDisabled = 0 group by name order by name ",tableName3,tableName10,tableName10,identity,tableName3,tableName10 ,tableName3];
//    @"select * from expenseTypes,expense_Project_Type where expense_Project_Type.projectIdentity='41' AND expenseTypes.identity=expense_Project_Type.expenseTypeIdentity"
	//NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	return expenseTypeArray;
}


- (NSMutableArray *) getExpenseTypesToSaveWithEntryForSelectedProjectId:(NSString*) identity withType:(NSString*)typeIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
//	NSString *sql = [NSString stringWithFormat:@"select * from '%@' where projectIdentity  = '%@' and identity = '%@' and isDisabled = 0 order by name ",tableName3,identity ,typeIdentity];
    NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.identity = '%@' and %@.isDisabled = 0 order by name ",tableName3,tableName10,tableName3,tableName10,tableName10,identity ,tableName3,typeIdentity,tableName3];
	//NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	return expenseTypeArray;
}

- (NSMutableArray *) getExpenseTypesWithEntryForSelectedProjectId:(NSString*)identity forTypeIdentity:(NSString*)typeIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    //	NSString *sql = [NSString stringWithFormat:@"select * from '%@' where projectIdentity  = '%@' and identity = '%@' and isDisabled = 0 order by name ",tableName3,identity ,typeIdentity];
    NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.identity = '%@'  order by name ",tableName3,tableName10,tableName3,tableName10,tableName10,identity ,tableName3,typeIdentity];
	//NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	return expenseTypeArray;
}


-(NSMutableArray *)getExpenseEntryStartDateAndEndDateforSelectedProjectId:(NSString*)_identity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select expenseEntryStartDate,expenseEntryEndDate from '%@' where identity  = '%@'",tableName5,_identity ];
	NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	return expenseTypeArray;
}

-(void)deleteExpenseSheetFromDB:(NSString*)sheetId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	[myDB deleteFromTable: table_ExpenseSheets where:[NSString stringWithFormat:@"identity=%@",sheetId] inDatabase:@""];
	[myDB deleteFromTable: table_expenseEntries where:[NSString stringWithFormat:@"expense_sheet_identity=%@",sheetId] inDatabase:@""];
}
-(void)deleteAllExpenseSheetsFromDatabase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if ([[self getExpenseSheetsFromDataBase]count]>0) {
		[myDB deleteFromTable: table_ExpenseSheets inDatabase:@""];
	}
	if ([[self getExpenseEntriesFromDatabase]count]>0) {
		[myDB deleteFromTable: table_expenseEntries inDatabase:@""];
	}
}

-(void)saveExpenseSheetToDataBaseWithDictionary:(NSDictionary *)expenseSheetDict{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *totReimbursement = @"0.00";
	NSString *identity = [NSString stringWithFormat:@"%d",(int)[NSDate timeIntervalSinceReferenceDate]];
	//offlineIdentity=offlineIdentity+1;
	offlineIdentity=offlineIdentity-1;
	//NSString *identity = [NSString stringWithFormat:@"%d",(int)offlineIdentity];
	NSString *status = @"Not Submitted";
	//NSString *trackingno = [NSString stringWithFormat:@"%d",[NSDate timeIntervalSinceReferenceDate]];
	NSString *trackingno = [NSString stringWithFormat:@"%d",(int)offlineIdentity ];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd, yyyy"];
	NSDate *currentDate = [NSDate date];
	NSString *submittedon = [dateFormat stringFromDate:currentDate];
	
	NSString *savedon = submittedon;
	NSString *savedUTC = [NSString stringWithFormat:@"%d", 
						  (int)[[NSDate date] timeIntervalSince1970]];
	
	NSString *expenseSheetDate =[NSString stringWithFormat:@"%@ %@, %@",[expenseSheetDict objectForKey:@"MONTH"],[expenseSheetDict objectForKey:@"DAY"]
								 
								 ,[expenseSheetDict objectForKey:@"YEAR"]];
	
	NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							  identity,@"identity",
							  status,@"status",
							  trackingno,@"trackingNumber",
							  submittedon,@"submittedOn",
							  savedon,@"savedOn",
							  savedUTC,@"savedOnUtc",
							  [expenseSheetDict objectForKey:@"description"],@"description",
							  expenseSheetDate,@"expenseDate",
							  [expenseSheetDict objectForKey:@"reimburseCurrency"],@"reimburseCurrency",
							  totReimbursement,@"totalReimbursement",
							  [NSNumber numberWithInt:1],@"isModified",
							  @"create",@"editStatus",
							  nil]; 
	
	[myDB insertIntoTable: table_ExpenseSheets data:infoDict intoDatabase:@""];
	//Handling Leaks
	
}

-(double)getHourlyRateFromDBWithProjectId:(NSString*)projectId withTypeName:(NSString*)typeName
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
//	NSString *sql = [NSString stringWithFormat:@"select * from '%@' where projectIdentity  = '%@' and name = '%@'",tableName3,projectId ,[typeName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.name = '%@'",tableName3,tableName10,tableName3,tableName10,tableName10,projectId,tableName3,[typeName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
    
    
	NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	double hourlyRate = 0;
	if (expenseTypeArray != nil && ![expenseTypeArray isKindOfClass:[NSNull class]] && [expenseTypeArray count] > 0) 
		hourlyRate=[[[expenseTypeArray objectAtIndex:0] objectForKey:@"hourlyRate"] doubleValue];
	DLog(@"hourlyRate %0.04lf",hourlyRate);
	return hourlyRate;
}


-(double)getRateForEntryWhereEntryId:(NSString*)entryId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from expense_entries where identity = '%@' ",entryId];
	NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	double hourlyRate = 0;
	if (expenseTypeArray != nil && ![expenseTypeArray isKindOfClass:[NSNull class]] && [expenseTypeArray count] > 0) 
		hourlyRate=[[[expenseTypeArray objectAtIndex:0] objectForKey:@"expenseRate"] doubleValue];
	DLog(@"hourlyRate %0.04lf",hourlyRate);
	return hourlyRate;
}

-(NSMutableArray*)getExpenseSheetInfoForSheetIdentity:(NSString *)sheetIdentity{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *placeString=[NSString stringWithFormat:@"identity='%@' ",sheetIdentity];
	//NSMutableArray *expenseSheetsArr = [myDB select:@"*" from:tableName1 where:placeString intoDatabase:@""];
	NSString *query=[NSString stringWithFormat:@" select * from expense_sheets where identity = '%@' ",sheetIdentity];
	NSMutableArray *expenseSheetsArr = [myDB executeQueryToConvertUnicodeValues:query];
	//[myDB select:@"*" from:tableName1 where:placeString intoDatabase:@""];
	if ([expenseSheetsArr count]!=0) {
		return expenseSheetsArr;
	}
	return nil;
}
-(NSMutableArray*)getExpenseEntryInfoForIdentity:(NSString *)identity{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *placeString=[NSString stringWithFormat:@"identity='%@'",identity];
	NSMutableArray *expenseArr = [myDB select:@"*" from: table_expenseEntries where:placeString intoDatabase:@""];
    for (int i=0; i<[expenseArr count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[expenseArr objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [expenseArr replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
    
	if ([expenseArr count]> 0) {
		return expenseArr;
	}
	return nil;
}

-(NSMutableArray*)getExpenseEntryInfoForSheetIdentityIdentity:(NSString *)sheetDdentity{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *placeString=[NSString stringWithFormat:@"expense_sheet_identity='%@'",sheetDdentity];
	NSMutableArray *expenseArr = [myDB select:@"*" from: table_expenseEntries where:placeString intoDatabase:@""];
    
	if ([expenseArr count]> 0) {
		return expenseArr;
	}
	return nil;
}

- (NSMutableArray *) getModifiedExpenseSheets {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = @"isModified = 1";
	NSMutableArray *expenseArr = [myDB select:@"*" from: table_ExpenseSheets where:whereString intoDatabase:@""];
	if ([expenseArr count]!=0) {
		return expenseArr;
	}
	return nil;
}

- (NSMutableArray *) getEntriesForExpenseSheet:(NSString *)sheetId {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"expense_sheet_identity='%@'  and editStatus <> 'delete' ",sheetId];
	NSMutableArray *entriesArr = [myDB select:@"*" from: table_expenseEntries where:whereString intoDatabase:@""];
    for (int i=0; i<[entriesArr count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[entriesArr objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [entriesArr replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
	if ([entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}

- (NSMutableArray *) getOfflineCreatedEntriesForSheet: (NSString *) sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"editStatus = 'create' and expense_sheet_identity = '%@'",sheetId];
	NSMutableArray *entriesArr = [myDB select:@"*" from: table_expenseEntries where:whereString intoDatabase:@""];
    for (int i=0; i<[entriesArr count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[entriesArr objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [entriesArr replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
	if ([entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}

- (NSMutableArray *) getOfflineEditedEntriesForSheet: (NSString *) sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"editStatus = 'edit' and expense_sheet_identity = '%@'",sheetId];
	NSMutableArray *entriesArr = [myDB select:@"*" from: table_expenseEntries where:whereString intoDatabase:@""];
    for (int i=0; i<[entriesArr count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[entriesArr objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [entriesArr replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
	if ([entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}

- (NSMutableArray *) getOfflineDeletedEntriesForSheet: (NSString *) sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"editStatus = 'delete' and expense_sheet_identity = '%@'",sheetId];
	NSMutableArray *entriesArr = [myDB select:@"identity" from: table_expenseEntries where:whereString intoDatabase:@""];
    for (int i=0; i<[entriesArr count]; i++)
    {
        NSMutableDictionary *expenseEntryDict=[NSMutableDictionary dictionaryWithDictionary:[entriesArr objectAtIndex:i]];
        NSString *expenseEntryDate=[G2Util getDeviceRegionalDateString:[expenseEntryDict objectForKey:@"entryDate"] ];
        [expenseEntryDict setObject:expenseEntryDate forKey:@"entryDate"   ];
        [entriesArr replaceObjectAtIndex:i withObject:expenseEntryDict];
    }
	if ([entriesArr count]!=0) {
		return entriesArr;
	}
	return nil;
}

- (NSString *) getCurrencyIdentityForSymbol: (NSString *) symbol {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"symbol = '%@'",symbol];
	NSMutableArray *currencyArray = [myDB select:@"identity" from:tableName6 where:whereString intoDatabase:@""];
	if ([currencyArray count]!=0) {
		
		return [[currencyArray objectAtIndex:0] objectForKey:@"identity"];
	}
	return nil;
}

- (void) resetSheetsModifyStatus: (NSString *)sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSDictionary *sheetModifiedDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"isModified",nil];
	NSDictionary *entriesModifiedDict = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"editStatus",[NSNumber numberWithInt:0],@"isModified",nil];
	NSString *sheetWhereString = [NSString stringWithFormat:@"identity = '%@'",sheetId];
	NSString *entryWhereString = [NSString stringWithFormat:@"expense_sheet_identity = '%@'",sheetId];
	[myDB updateTable: table_ExpenseSheets data:sheetModifiedDict where:sheetWhereString intoDatabase:@""];
	[myDB updateTable: table_expenseEntries data:entriesModifiedDict where:entryWhereString intoDatabase:@""];
}

- (void) removeOfflineCreatedEntries: (NSString *)sheetId {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"editStatus = 'create' and expense_sheet_identity = '%@'",sheetId];
	[myDB deleteFromTable: table_expenseEntries where:whereString inDatabase:@""];
}

- (void) removeOfflineDeletedEntries: (NSString *)sheetId {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"editStatus = 'delete' and expense_sheet_identity = '%@'",sheetId];
	[myDB deleteFromTable: table_expenseEntries where:whereString inDatabase:@""];
}

- (void) saveUdfsForExpenseEntry : (NSMutableArray *)udfsArray :(NSString *)entryIdentity :(NSString *)entryType{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if (udfsArray != nil &&[udfsArray count] > 0) {
		
		for (NSDictionary *udfDict in udfsArray) {
			
			NSDictionary *udfInfo = nil;
			if([[udfDict objectForKey:@"udf_type"] isEqualToString:@"Date"]) {
				
				NSString *dateString = nil;
				if (![[udfDict objectForKey:@"udfValue"] isEqualToString:@"Select"]) {
					NSDate *udfDate = [G2Util convertStringToDate1:[udfDict objectForKey:@"udfValue"]];
					
					unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
					NSCalendar *calendar = [NSCalendar currentCalendar];
					NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
					dateString = [NSString stringWithFormat:@"%@ %ld, %ld",[G2Util getMonthNameForMonthId:[comps month]], (long)[comps day], (long)[comps year]];
				}else {
					dateString = @"null";
				}
				
				
				udfInfo =  [NSDictionary dictionaryWithObjectsAndKeys:
							[udfDict objectForKey:@"udf_id"],@"udf_id",
							[udfDict objectForKey:@"udf_name"],@"udf_name",
							dateString,@"udfValue",
							entryIdentity,@"entry_id",
							entryType, @"entry_type",
							nil];
			}else {
				udfInfo =  [NSDictionary dictionaryWithObjectsAndKeys:
							[udfDict objectForKey:@"udf_id"],@"udf_id",
							[udfDict objectForKey:@"udf_name"],@"udf_name",
							[udfDict objectForKey:@"udfValue"],@"udfValue",
							entryIdentity,@"entry_id",
							entryType, @"entry_type",
							nil];
			}
			
			
			
			
			[myDB insertIntoTable:tableName7 data:udfInfo intoDatabase:@""];
			
		}
	}
	
}

- (void) updateUdfsForExpenseEntry : (NSMutableArray *)udfsArray :(NSString *)entryIdentity :(NSString *)entryType{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"entry_id = '%@' and entry_type= '%@'",entryIdentity, entryType];
	if (udfsArray != nil &&[udfsArray count] > 0) {
		
		for (NSDictionary *udfDict in udfsArray) {
			
			NSDictionary *udfInfo = nil;
			if([[udfDict objectForKey:@"udf_type"] isEqualToString:@"Date"]) {
				
				NSDate *udfDate = [G2Util convertStringToDate1:[udfDict objectForKey:@"udfValue"]];
				
				unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
				NSCalendar *calendar = [NSCalendar currentCalendar];
				NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
				NSString *dateString = [NSString stringWithFormat:@"%@ %ld, %ld",[G2Util getMonthNameForMonthId:[comps month]], (long)[comps day], (long)[comps year]];
				udfInfo =  [NSDictionary dictionaryWithObjectsAndKeys:
							[udfDict objectForKey:@"udf_id"],@"udf_id",
							[udfDict objectForKey:@"udf_name"],@"udf_name",
							dateString,@"udfValue",
							nil];
			}else {
				udfInfo =  [NSDictionary dictionaryWithObjectsAndKeys:
							[udfDict objectForKey:@"udf_id"],@"udf_id",
							[udfDict objectForKey:@"udf_name"],@"udf_name",
							[udfDict objectForKey:@"udfValue"],@"udfValue",
							nil];
			}
			
			
			
			[myDB updateTable:tableName7 data:udfInfo where:whereString intoDatabase:@""];
			
		}
	}
	
}

#pragma mark ApprovalsDetails
-(NSMutableArray*)insertApprovalsDetailsIntoDbForUnsubmittedSheet:(NSArray*)responseArray
{
	NSMutableArray *approvalArray=[NSMutableArray array];
	NSString *status=nil;
	for (int i=0; i<[responseArray count]; i++) {
		
		NSMutableDictionary *sheetInfoDict=[NSMutableDictionary dictionary];
		if ([[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"ApproveStatus"]objectForKey:@"Properties"]objectForKey:@"Name"] isEqualToString:@"Open"]){
			status=@"Not Submitted";
			
			[sheetInfoDict setObject:status forKey:@"status"];
			
		}else {
			status=[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"ApproveStatus"]objectForKey:@"Properties"]objectForKey:@"Name"];
			
			[sheetInfoDict setObject:status forKey:@"status"];
		}
		
		NSString *submittedOn=nil;int monthSub=0;
		id submittedOnDict=[[[responseArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"SubmittedOn"];
		if([submittedOnDict isKindOfClass:[NSDictionary class]]){
			monthSub = [[submittedOnDict objectForKey:@"Month"]intValue];
			if ([[submittedOnDict objectForKey:@"Hour"] intValue]>12) {
				submittedOn =[NSString stringWithFormat:@"%@ %@, %@      %@:%@:%@  %@",[G2Util getMonthNameForMonthId:monthSub],[submittedOnDict objectForKey:@"Day"]
							  ,[submittedOnDict objectForKey:@"Year"],[submittedOnDict objectForKey:@"Hour"],[submittedOnDict objectForKey:@"Minute"],
							  [submittedOnDict objectForKey:@"Second"],@"PM"];
			}else {
				submittedOn =[NSString stringWithFormat:@"%@ %@, %@      %@:%@:%@  %@",[G2Util getMonthNameForMonthId:monthSub],[submittedOnDict objectForKey:@"Day"]
							  ,[submittedOnDict objectForKey:@"Year"],[submittedOnDict objectForKey:@"Hour"],[submittedOnDict objectForKey:@"Minute"],
							  [submittedOnDict objectForKey:@"Second"],@"AM"];
			}
			
		}else if([submittedOnDict isKindOfClass:[NSNull class]]){
			
			submittedOn = @"";
		}
		
		//[approvalArray addObject:submittedOn];
		[sheetInfoDict setObject:submittedOn forKey:@"submittedOn"];
		[approvalArray addObject:sheetInfoDict];
		
		NSString *approverIdentity=nil;
		for (int j=0; j<[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] count]; j++) {
			
			NSMutableDictionary *approvalsDictionary=[NSMutableDictionary dictionary];
			NSString *effectiveDate=nil;
			int month=0;
			
			
			id effectiveDateDict=[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j] 
								   objectForKey:@"Properties"] objectForKey:@"EffectiveDate"];
			if([effectiveDateDict isKindOfClass:[NSDictionary class]]){
				month = [[effectiveDateDict objectForKey:@"Month"]intValue];
				if ([[effectiveDateDict objectForKey:@"Hour"] intValue]>12) {
					
					effectiveDate =[NSString stringWithFormat:@"%@ %@, %@      %@:%@:%@  %@",[G2Util getMonthNameForMonthId:month],[effectiveDateDict objectForKey:@"Day"]
									,[effectiveDateDict objectForKey:@"Year"],[effectiveDateDict objectForKey:@"Hour"],[effectiveDateDict objectForKey:@"Minute"],
									[effectiveDateDict objectForKey:@"Second"],@"PM"];
				}else {
					effectiveDate =[NSString stringWithFormat:@"%@ %@, %@      %@:%@:%@  %@",[G2Util getMonthNameForMonthId:month],[effectiveDateDict objectForKey:@"Day"]
									,[effectiveDateDict objectForKey:@"Year"],[effectiveDateDict objectForKey:@"Hour"],[effectiveDateDict objectForKey:@"Minute"],
									[effectiveDateDict objectForKey:@"Second"],@"AM"];
				}
				
				[approvalsDictionary setObject:effectiveDate forKey:@"effectiveDate"];
			}else if([effectiveDateDict isKindOfClass:[NSNull class]]){
				[approvalsDictionary setObject:@"" forKey:@"effectiveDate"];
			}
			
			
			/*for (int i=0; i<[responseArray count]; i++) {
			 for (int j=0; j<[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] count]; j++) {
			 if([[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j]objectForKey:@"RemainingApprovers"] count]>0 || 
			 [[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j]objectForKey:@"WaitingOnApprovers"] count]>0)*/
			
			
			NSString* comments=nil;
			comments=[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j] 
					   objectForKey:@"Properties"] objectForKey:@"ApprovalComments"];
			
			if([comments isKindOfClass:[NSString class]]){
				[approvalsDictionary setObject:comments forKey:@"comments"];
			}else if([comments isKindOfClass:[NSNull class]]) {
				comments=@"";
				[approvalsDictionary setObject:comments forKey:@"comments"];
			}
			
			NSString *approverLoginName=nil;
			NSString *firstName=nil;
			NSString *lastName=nil;
			if([[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Approver"]  isKindOfClass:[NSDictionary class]]){
				
				approverIdentity=[[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Approver"] objectForKey:@"Identity"];
				
				[approvalsDictionary setObject:approverIdentity forKey:@"identity"];
				
				approverLoginName=[[[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"]objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Approver"]
									objectForKey:@"Properties"] objectForKey:@"LoginName"];	
				[approvalsDictionary setObject:approverLoginName forKey:@"loginName"];
				
				firstName=[[[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"]objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Approver"]
							objectForKey:@"Properties"] objectForKey:@"FirstName"];
				[approvalsDictionary setObject:firstName forKey:@"firstName"];
				
				lastName=[[[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"]objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Approver"]
						   objectForKey:@"Properties"] objectForKey:@"LastName"];
				[approvalsDictionary setObject:lastName forKey:@"lastName"];
			}else if([[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"] objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Approver"]  isKindOfClass:[NSNull class]]) {
				approverIdentity=@"";
				approverLoginName=@"";
				firstName=@"";
				lastName=@"";
				[approvalsDictionary setObject:approverIdentity forKey:@"identity"];
				[approvalsDictionary setObject:approverLoginName forKey:@"loginName"];
				[approvalsDictionary setObject:firstName forKey:@"firstName"];
				[approvalsDictionary setObject:lastName forKey:@"lastName"];
			}
			
			NSString *approverAction=nil;
			if([[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"]objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Type"] isKindOfClass:[NSDictionary class]]){
				approverAction=[[[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"]objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Type"]objectForKey:@"Properties"]objectForKey:@"Name"];
				[approvalsDictionary setObject:approverAction forKey:@"approverAction"];
			}else if([[[[[[[responseArray objectAtIndex:i] objectForKey:@"Relationships"]objectForKey:@"History"]objectAtIndex:j]objectForKey:@"Relationships"]objectForKey:@"Type"] isKindOfClass:[NSNull class]]){
				approverAction=@"";
				[approvalsDictionary setObject:approverAction forKey:@"approverAction"];
			}
			
			
			[approvalArray addObject:approvalsDictionary];
		}
	}
	//DLog(@"insertApprovalsDetailsIntoDbForUnsubmittedSheet %@",approvalArray);
	return approvalArray;
}
#pragma mark Entry Saving

-(void)saveExpenseEntryInToDataBase:(NSDictionary *)expenseEntryDict{
	
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *expenseTypeName = [expenseEntryDict objectForKey:@"expenseTypeName"];
	NSString *projectName = @"";
	NSString *clientName =  @"";
	
	if ([expenseEntryDict objectForKey:@"Client/Project"]!= nil) {
		NSArray *name = [[expenseEntryDict objectForKey:@"Client/Project"] componentsSeparatedByString:@"/"];
		projectName = [name objectAtIndex:0];
		clientName =  [name objectAtIndex:0];
	}
	
	
	NSString *expenseReceipt = nil;
    if (![[expenseEntryDict objectForKey:@"Base64ImageString"] isKindOfClass:[NSNull class] ]) 
    {
        if([expenseEntryDict objectForKey:@"Base64ImageString"] != nil && [[expenseEntryDict objectForKey:@"Base64ImageString"] length] > 0) {
            expenseReceipt =@"Yes";
        }else {
            expenseReceipt =@"No";		
        }
    }
	
	NSString *sheetId = [expenseEntryDict objectForKey:@"ExpenseSheetID"];
	//NSString *expenseIdentity = [expenseEntryDict objectForKey:@"identity"];
	NSString *projectIdentity = [expenseEntryDict objectForKey:@"projectIdentity"];
	NSString *clientIdentity = [expenseEntryDict objectForKey:@"clientIdentity"];
	NSString *expenseTypeIdentity = [expenseEntryDict objectForKey:@"expenseTypeIdentity"];
	NSString *description = [expenseEntryDict objectForKey:@"Description"];
	NSNumber *billClient =[expenseEntryDict objectForKey:@"BillClient"];
	NSNumber *reimbursement = [expenseEntryDict objectForKey:@"Reimburse"];
	NSString *currencyType = [expenseEntryDict objectForKey:@"currencyType"];
	NSString *netAmount = [expenseEntryDict objectForKey:@"NetAmount"];
	NSString *paymentMethodId = [expenseEntryDict objectForKey:@"paymentMethodId"];
	NSString *paymentMethodName = [expenseEntryDict objectForKey:@"Payment Method"];
	NSString *entryIdentity = [expenseEntryDict objectForKey:@"identity"];
	NSNumber *isRated = [expenseEntryDict objectForKey:@"isRated"];
	
	NSDate *entryDate = [G2Util convertStringToDate1:[expenseEntryDict objectForKey:@"Date"]];
	
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [calendar components:reqFields fromDate:entryDate];
	NSString *dateString = [NSString stringWithFormat:@"%@ %ld, %ld",[G2Util getMonthNameForMonthId:[comps month]], (long)[comps day], (long)[comps year]];
	
	NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 sheetId,@"expense_sheet_identity",
									 billClient,@"billClient",
									 reimbursement,@"requestReimbursement",
									 dateString,@"entryDate",
									 description,@"description",
									 currencyType,@"currencyType",
									 netAmount,@"netAmount",
									 projectIdentity ,@"projectIdentity",
									 projectName,@"projectName",
									 clientIdentity, @"clientIdentity",
									 clientName,@"clientName",
									 expenseReceipt,@"expenseReceipt",
									 expenseTypeIdentity,@"expenseTypeIdentity",
									 expenseTypeName,@"expenseTypeName",
									 paymentMethodId,@"paymentMethodId",
									 paymentMethodName,@"paymentMethodName",
									 entryIdentity,@"identity",
									 nil];
	if ([isRated intValue] == 1) {
		[infoDict setObject:isRated forKey:@"isRated"];
		[infoDict setObject:[expenseEntryDict objectForKey:@"ExpenseRate"] forKey:@"expenseRate"];
		[infoDict setObject:[expenseEntryDict objectForKey:@"NumberOfUnits"] forKey:@"noOfUnits"];
	}else {
		[infoDict setObject:isRated forKey:@"isRated"];
		[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"expenseRate"];
		[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"noOfUnits"];
	}
	
	
	if ([expenseEntryDict objectForKey:@"isModified"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"isModified"] forKey:@"isModified"];
	}
	if ([expenseEntryDict objectForKey:@"editStatus"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"editStatus"] forKey:@"editStatus"];
	}
	
	
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",entryIdentity];
	[myDB updateTable: table_expenseEntries data:infoDict where:whereString intoDatabase:@""];
	
}

#pragma mark UDF for a selected Expense



- (void)saveNewExpenseEntryToDataBase:(NSDictionary *)expenseEntryDict{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *expenseTypeName=nil;
	if([expenseEntryDict objectForKey:@"typeName"]!=nil){
		expenseTypeName = [expenseEntryDict objectForKey:@"typeName"];
	}
	NSString *projectName=nil;
	if([expenseEntryDict objectForKey:@"projectName"]!=nil){
		projectName = [expenseEntryDict objectForKey:@"projectName"];
	}
	NSString *clientName = nil;
	if ([expenseEntryDict objectForKey:@"clientName"]!=nil){
		clientName=[expenseEntryDict objectForKey:@"clientName"];
	}
	
	NSString *expenseReceipt = nil;
    if (![[expenseEntryDict objectForKey:@"base64ImageString"] isKindOfClass:[NSNull class] ]) 
    {
        if([expenseEntryDict objectForKey:@"base64ImageString"] != nil && [[expenseEntryDict objectForKey:@"base64ImageString"] length] > 0) {
            //expenseReceipt =@"Yes";//changed to No because we r not showing image........
            expenseReceipt =@"Yes";
        }else {
            expenseReceipt =@"No";		
        }
    }
	
	
	NSString *sheetId =nil;
	if([expenseEntryDict objectForKey:@"ExpenseSheetID"] !=nil){
		sheetId=[expenseEntryDict objectForKey:@"ExpenseSheetID"];
	}
	NSString *projectIdentity = @"";
	NSString *clientIdentity =  @"";
	if ([expenseEntryDict objectForKey:@"projectIdentity"] != nil) {
		projectIdentity = [expenseEntryDict objectForKey:@"projectIdentity"];
	}
	if ([expenseEntryDict objectForKey:@"clientIdentity"] != nil) {
		clientIdentity = [expenseEntryDict objectForKey:@"clientIdentity"];
	}
	
	NSString *expenseTypeIdentity =nil;
	if([expenseEntryDict objectForKey:@"typeIdentity"]!=nil)
	{
		expenseTypeIdentity=[expenseEntryDict objectForKey:@"typeIdentity"];
	}
	
	NSString *description=nil;
	if([expenseEntryDict objectForKey:@"Description"] !=nil){
		description= [expenseEntryDict objectForKey:@"Description"];
	}
	
	NSNumber *billClient = [NSNumber numberWithInt:0];
	NSNumber *reimbursement = [NSNumber numberWithInt:0];
	if ([expenseEntryDict objectForKey:@"BillClient"] != nil) {
		billClient = [expenseEntryDict objectForKey:@"BillClient"];
	}
	if ([expenseEntryDict objectForKey:@"Reimburse"] != nil) {
		reimbursement = [expenseEntryDict objectForKey:@"Reimburse"];
	}
	
	NSString *currencyType = nil;
	if([expenseEntryDict objectForKey:@"currencyType"]!=nil)
	{
		currencyType=[expenseEntryDict objectForKey:@"currencyType"];
	}
	NSString *netAmount = nil;
	if([expenseEntryDict objectForKey:@"NetAmount"]!=nil){
		netAmount=[expenseEntryDict objectForKey:@"NetAmount"];
	}
	NSString *paymentMethodId =nil;
	if([expenseEntryDict objectForKey:@"paymentMethodId"]!=nil){
		paymentMethodId= [expenseEntryDict objectForKey:@"paymentMethodId"];
	}
	
	NSString *paymentMethodName =nil;
	if([expenseEntryDict objectForKey:@"Payment Method"]!=nil){
		paymentMethodName=[expenseEntryDict objectForKey:@"Payment Method"];
	}
	
	NSString *identity=nil;
	if([expenseEntryDict objectForKey:@"identity"]!=nil){
		identity= [expenseEntryDict objectForKey:@"identity"];
	}
	
	NSDate *entryDate=nil;
	if([expenseEntryDict objectForKey:@"Date"]!=nil)
		entryDate = [G2Util convertStringToDate1:[expenseEntryDict objectForKey:@"Date"]];
	
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	NSDateComponents *comps=nil;
	NSString *dateString=nil;
	if (entryDate!=nil) {
		comps = [calendar components:reqFields fromDate:entryDate];
		dateString = [NSString stringWithFormat:@"%@ %ld, %ld",[G2Util getMonthNameForMonthId:[comps month]], (long)[comps day], (long)[comps year]];
	}
	
	NSMutableDictionary *infoDict=[NSMutableDictionary dictionary];
	if(sheetId!=nil)
	{
		[infoDict setObject:sheetId forKey:@"expense_sheet_identity"];
	}
	
	if(identity!=nil)
	{
		[infoDict setObject:identity forKey:@"identity"];
	}
	
	if(billClient!=nil)
	{
		[infoDict setObject:billClient forKey:@"billClient"];
	}
	
	if(reimbursement!=nil)
	{
		[infoDict setObject:reimbursement forKey:@"requestReimbursement"];
	}
	if(dateString!=nil)
	{
		[infoDict setObject:dateString forKey:@"entryDate"];
	}
	if(description!=nil)
	{
		[infoDict setObject:description forKey:@"description"];
	}
	if(currencyType!=nil)
	{
		[infoDict setObject:currencyType forKey:@"currencyType"];
	}
	
	if(netAmount!=nil)
	{
		[infoDict setObject:netAmount forKey:@"netAmount"];
	}
	if(projectIdentity!=nil)
	{
		[infoDict setObject:projectIdentity forKey:@"projectIdentity"];
	}
	
	if(projectName!=nil)
	{
		[infoDict setObject:projectName forKey:@"projectName"];
	}
	if(clientIdentity!=nil)
	{
		[infoDict setObject:clientIdentity forKey:@"clientIdentity"];
	}
	
	if(clientName!=nil)
	{
		[infoDict setObject:clientName forKey:@"clientName"];
	}
	
	if(expenseReceipt!=nil)
	{
		[infoDict setObject:expenseReceipt forKey:@"expenseReceipt"];
	}
	if(expenseTypeIdentity!=nil)
	{
		[infoDict setObject:expenseTypeIdentity forKey:@"expenseTypeIdentity"];
	}
	if(expenseTypeName!=nil)
	{
		[infoDict setObject:expenseTypeName forKey:@"expenseTypeName"];
	}
	if(paymentMethodId!=nil)
	{
		[infoDict setObject:paymentMethodId forKey:@"paymentMethodId"];
	}else {
		[infoDict setObject:@"" forKey:@"paymentMethodId"];
	}
	
	if(paymentMethodName!=nil)
	{
		if ([paymentMethodName isEqualToString:@"Select"]) {
			[infoDict setObject:@"" forKey:@"paymentMethodName"];
		}
		else {
			[infoDict setObject:paymentMethodName forKey:@"paymentMethodName"];
		}
	}else {
		[infoDict setObject:@"" forKey:@"paymentMethodName"];
	}
	
	
	//add default values 
	if([expenseEntryDict objectForKey:@"NumberOfUnits"]!=nil)
	{
		if ([expenseEntryDict objectForKey:@"ExpenseRate"]!=nil){
			[infoDict setObject:[expenseEntryDict objectForKey:@"ExpenseRate"] forKey:@"expenseRate"];
		}else {
			[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"expenseRate"];
		}
		
		if ([expenseEntryDict objectForKey:@"NumberOfUnits"]!=nil) {
			[infoDict setObject:[expenseEntryDict objectForKey:@"NumberOfUnits"] forKey:@"noOfUnits"];
		}else {
			[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"noOfUnits"];
		}
		
	}else {
		[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"noOfUnits"];
		[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"expenseRate"];
		if ([expenseEntryDict objectForKey:@"NetAmount"]!=nil) 
			[infoDict setObject:[expenseEntryDict objectForKey:@"NetAmount"] forKey:@"netAmount"];
	}
	
	if ([expenseEntryDict objectForKey:@"isRated"]!=nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"isRated"] forKey:@"isRated"];
	}else {
		[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"isRated"];
	}
	
	
	//[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"expenseRate"];
	///[infoDict setObject:[NSNumber numberWithInt:0] forKey:@"noOfUnits"];
	
	if ([expenseEntryDict objectForKey:@"isModified"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"isModified"] forKey:@"isModified"];
	}
	if ([expenseEntryDict objectForKey:@"isModified"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"editStatus"] forKey:@"editStatus"];
	}
	if ([expenseEntryDict objectForKey:@"taxAmount1"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"taxAmount1"] forKey:@"taxAmount1"];
	}else {
		[infoDict setObject:@"" forKey:@"taxAmount1"];
	}
	
	if ([expenseEntryDict objectForKey:@"taxAmount2"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"taxAmount2"] forKey:@"taxAmount2"];
	}else {
		[infoDict setObject:@"" forKey:@"taxAmount2"];
	}
	if ([expenseEntryDict objectForKey:@"taxAmount3"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"taxAmount3"] forKey:@"taxAmount3"];
	}else {
		[infoDict setObject:@"" forKey:@"taxAmount3"];
	}
	if ([expenseEntryDict objectForKey:@"taxAmount4"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"taxAmount4"] forKey:@"taxAmount4"];
	}else {
		[infoDict setObject:@"" forKey:@"taxAmount4"];
	}
	if ([expenseEntryDict objectForKey:@"taxAmount5"] != nil) {
		[infoDict setObject:[expenseEntryDict objectForKey:@"taxAmount5"] forKey:@"taxAmount5"];
	}else {
		[infoDict setObject:@"" forKey:@"taxAmount5"];
	}
	
	[myDB insertIntoTable: table_expenseEntries data:infoDict intoDatabase:@""];
	
}

-(void) updateExpenseSheetModifyStatus:(NSNumber *)sheetStatus :(NSString *)sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"identity='%@'",sheetId];
	NSDictionary *infoDict = [NSDictionary dictionaryWithObject:sheetStatus forKey:@"isModified"];
	[myDB updateTable: table_ExpenseSheets data:infoDict where:where intoDatabase:@""];
}


//Used to change status using Approvers response
-(void) updateExpenseSheetStatus:(NSString *)sheetStatus :(NSString *)sheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"identity='%@'",sheetId];
	NSDictionary *infoDict = [NSDictionary dictionaryWithObject:sheetStatus forKey:@"status"];
	[myDB updateTable: table_ExpenseSheets data:infoDict where:where intoDatabase:@""];
}


-(NSMutableArray *)getUDFsForSelectedEntry:(id)entryId{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"entry_id='%@'",entryId];
	NSMutableArray *udfArray = [myDB select:@"*" from:tableName7 where:where intoDatabase:@""];
	if ([udfArray count] > 0) {
		return udfArray;
	}
	return nil;
}
#pragma mark Insert Receipt for an Expense

-(NSMutableArray *)getReceiptInfoForSelectedExpense:(id)expenseReceiptArray{
	
	NSMutableArray *receiptInfoArray = [NSMutableArray array];
	NSString *base64Str = @"";
	NSString *contentType = @"";
	NSString *fileName = @"";
	NSString *type= @"";
	for (int i=0; i<[expenseReceiptArray count]; i++) {
		id receiptArr =[[[expenseReceiptArray objectAtIndex:i] objectForKey:@"Relationships"] 
						objectForKey:@"ExpenseReceipt"];
		if ([receiptArr isKindOfClass:[NSArray class]]) {
			if ([receiptArr count] > 0) {
				for (int k=0; k<[receiptArr count]; k++) {
					if ([[[[receiptArr objectAtIndex:k] objectForKey:@"Properties"] objectForKey:@"Image"]objectForKey:@"Value" ]!= nil) {
						base64Str = [[[[receiptArr objectAtIndex:k] objectForKey:@"Properties"] objectForKey:@"Image"]objectForKey:@"Value" ];
					} 
					if ([[[[receiptArr objectAtIndex:k] objectForKey:@"Properties"] objectForKey:@"Image"]objectForKey:@"Type" ]!= nil) {
						type = [[[[receiptArr objectAtIndex:k] objectForKey:@"Properties"] objectForKey:@"Image"]objectForKey:@"Type" ];
					}
					if ([[[receiptArr objectAtIndex:k] objectForKey:@"Properties"]objectForKey:@"ContentType" ]!= nil) {
						contentType = [[[receiptArr objectAtIndex:k] objectForKey:@"Properties"]objectForKey:@"ContentType" ];
					}
					if ([[[receiptArr objectAtIndex:k] objectForKey:@"Properties"]objectForKey:@"FileName" ]!= nil) {
						fileName = [[[receiptArr objectAtIndex:k] objectForKey:@"Properties"]objectForKey:@"FileName" ];
					}
					NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
											  base64Str,@"BASE64_STRING",
											  type,@"TYPE",
											  contentType,@"CONTENT_TYPE",
											  fileName,@"FILE_NAME",nil];
					[receiptInfoArray addObject:infoDict];
				}
			}
		}
	}
	if ([receiptInfoArray count]>0) {
		return receiptInfoArray;
	}
	return nil;		
}
-(NSMutableArray *)getExpensePaymentMethodId:(NSString *)paymentName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"name='%@'",paymentName];
	NSMutableArray *paymentArray = [myDB select:@"identity" from:tableName9 where:where intoDatabase:@""];
	if ([paymentArray count] > 0) {
		return paymentArray;
	}
	return nil;
	
}

-(void)updateExpenseById:(NSMutableDictionary *)expenseDictionary{
	//DLog(@"\n*****While saving the edited expense::::updateExpenseById:ExpensesModel %@\n",expenseDictionary);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *projectName = @"";
	NSString *clientName = @"";
	if ([expenseDictionary count]>0) {
		clientName = [expenseDictionary objectForKey:@"clientName"];
		projectName = [expenseDictionary objectForKey:@"projectName"];
		
		NSNumber *isModified = [NSNumber numberWithInt:0];
		NSString *receiptString =nil;
		//if([expenseDictionary objectForKey:@"Base64ImageString"] ){
		if([expenseDictionary objectForKey:@"Base64ImageString"] != nil)
		{
			if ([[expenseDictionary objectForKey:@"Base64ImageString"] isEqualToString:@""] || [expenseDictionary objectForKey:@"Base64ImageString"]){
				receiptString = @"Yes";//changed to No because not fetching image currently............
			}else {
				receiptString=@"No";
			}
		}else {
			receiptString=@"No";
		}
		
		
		
		
		NSNumber *billClient = [NSNumber numberWithInt:0];
		NSNumber *reimbursment = [NSNumber numberWithInt:0];
		if ([expenseDictionary objectForKey:@"BillClient"] != nil) {
			billClient = [expenseDictionary objectForKey:@"BillClient"];
		}
		if ([expenseDictionary objectForKey:@"Reimburse"] != nil) {
			reimbursment = [expenseDictionary objectForKey:@"Reimburse"];
		}
		NSDate *entryDate=nil;
		if ([expenseDictionary objectForKey:RPLocalizedString(@"Date", @"Date") ]!=nil) 
			entryDate = [G2Util convertStringToDate1:[expenseDictionary objectForKey:RPLocalizedString(@"Date", @"Date")]];
		
		unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
		//NSCalendar *calendar = [NSCalendar currentCalendar];//DE3171
        
		NSDateComponents *comps=nil;
		if (entryDate!=nil) 
        {
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171
			comps = [calendar components:reqFields fromDate:entryDate];
           
        }
        
		NSString *dateString=nil;
		if(comps!=nil)
			dateString = [NSString stringWithFormat:@"%@ %ld, %ld",[G2Util getMonthNameForMonthId:[comps month]], (long)[comps day], (long)[comps year]];
		NSString *_expSheetId = [expenseDictionary objectForKey:@"ExpenseSheetID"];
		NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										 _expSheetId, @"expense_sheet_identity",
										 billClient,@"billClient",
										 reimbursment,@"requestReimbursement",
										 isModified,@"isModified",
										 nil];
		
		if ([expenseDictionary objectForKey:@"expenseUnitLable"] != nil) {
			[infoDict setObject:[expenseDictionary objectForKey:@"expenseUnitLable"] forKey:@"expenseUnitLable"];
		}
		
		if ([expenseDictionary objectForKey:@"isModified"] != nil) {
			[infoDict setObject:[expenseDictionary objectForKey:@"isModified"] forKey:@"isModified"];
		}
		if ([expenseDictionary objectForKey:@"isModified"] != nil) {
			[infoDict setObject:[expenseDictionary objectForKey:@"editStatus"] forKey:@"editStatus"];
		}
		
		if([expenseDictionary objectForKey:RPLocalizedString(@"Payment Method", @"")]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:RPLocalizedString(@"Payment Method", @"")] forKey:@"paymentMethodName"];
		
		if([expenseDictionary objectForKey:@"paymentMethodId"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"paymentMethodId"] forKey:@"paymentMethodId"];
		
		if([expenseDictionary objectForKey:RPLocalizedString(@"Description",@"")]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:RPLocalizedString(@"Description",@"")] forKey:@"description"];
		
		if([expenseDictionary objectForKey:@"currencyType"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"currencyType"] forKey:@"currencyType"];
		
		if([expenseDictionary objectForKey:@"NetAmount"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"NetAmount"] forKey:@"netAmount"];
		
		if([expenseDictionary objectForKey:@"projectIdentity"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
		
		if(projectName!=nil)
			[infoDict setObject:projectName forKey:@"projectName"];
		
		if([expenseDictionary objectForKey:@"clientIdentity"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"clientIdentity"] forKey:@"clientIdentity"];
		
		if (clientName!=nil) {
			[infoDict setObject:clientName forKey:@"clientName"];
		}
		if (receiptString!=nil) 
			[infoDict setObject:receiptString forKey:@"expenseReceipt"];
		
		if([expenseDictionary objectForKey:@"expenseTypeIdentity"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"expenseTypeIdentity"] forKey:@"expenseTypeIdentity"];
		
		if([expenseDictionary objectForKey:@"typeName"]!=nil)
			[infoDict setObject:[expenseDictionary objectForKey:@"typeName"] forKey:@"expenseTypeName"];
		
		if(dateString!=nil)
			[infoDict setObject:dateString forKey:@"entryDate"];
		NSString *allocationId = [expenseDictionary objectForKey:@"allocationMethodId"];
		if (allocationId == nil) {
			allocationId = @"";
		}
		[infoDict setObject:allocationId forKey:@"allocationMethodId"];
		double netAmountTotal=0;
		
		if ([expenseDictionary objectForKey:@"NetAmount"]!=nil) 
			netAmountTotal= [[expenseDictionary objectForKey:@"NetAmount"] doubleValue];
		for (int x=1; x<6; x++) {
			if([expenseDictionary objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]!=nil){
				NSNumber *taxAmountInNumFormat=	[NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:[expenseDictionary objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]]];
				//[infoDict setObject:[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[taxAmountInNumFormat doubleValue]]]forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
				//NSString *taxAmountAsString=[Util removeCommasFromNsnumberFormaters:taxAmountInNumFormat];
				NSString *taxAmountAsString=[NSString stringWithFormat:@"%@",taxAmountInNumFormat];
				if (taxAmountAsString!=nil) {
					[infoDict setObject:taxAmountAsString forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
				}
				//NSString *taxAmount = [expenseDictionary objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]];
				
				if ([taxAmountAsString isKindOfClass:[NSNull class]]) {
					taxAmountAsString=@"";
					[infoDict setObject:taxAmountAsString forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
				}else {
					[infoDict setObject:taxAmountAsString forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
					//netAmountTotal=netAmountTotal+[taxAmount floatValue];
					[infoDict setObject:[NSString stringWithFormat:@"%0.02f",netAmountTotal] forKey:@"netAmount"];
				}
			}else {
				[infoDict setObject:@"" forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
			}
			
			
		}
		
		
		//Formulas for ExpenseTypes................
		for (int y=1; y<= Max_No_Taxes_5 ; y++) {
			id formulaValue =[expenseDictionary objectForKey:[NSString stringWithFormat:@"formula%d",y]];
			if (formulaValue!=nil &&  ![formulaValue isKindOfClass:[NSNull class]]) {
				[infoDict setObject:formulaValue forKey:[NSString stringWithFormat:@"formula%d",y]];	
			}else {
				[infoDict setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",y]];	
			}
		}
		//TAX CODES ADDED FOR ENTRY INSERTION
		for (int f=1; f<=Max_No_Taxes_5; f++) {
			id taxCodeValue =[expenseDictionary objectForKey:[NSString stringWithFormat:@"taxCode%d",f]];
			if (taxCodeValue!=nil &&  ![taxCodeValue isKindOfClass:[NSNull class]]) {
				[infoDict setObject:taxCodeValue forKey:[NSString stringWithFormat:@"taxCode%d",f]];	
			}else {
				[infoDict setObject:@"" forKey:[NSString stringWithFormat:@"taxCode%d",f]];	
				
			}
		}
		
		
		
		if([expenseDictionary objectForKey:@"isRated"]!=nil){
			if ([[expenseDictionary objectForKey:@"isRated"] intValue] == 1) {
				if([expenseDictionary objectForKey:@"ExpenseRate"]!=nil)
					[infoDict setObject:[expenseDictionary objectForKey:@"ExpenseRate"] forKey:@"expenseRate"];
				if([expenseDictionary objectForKey:@"NumberOfUnits"]!=nil)
					[infoDict setObject:[expenseDictionary objectForKey:@"NumberOfUnits"] forKey:@"noOfUnits"];
				if([expenseDictionary objectForKey:@"isRated"]!=nil)
					[infoDict setObject:[expenseDictionary objectForKey:@"isRated"] forKey:@"isRated"];
			}
		}
		//DLog(@"infodict afteredit %@",infoDict);
		{
			NSString *whereString=[NSString stringWithFormat:@"identity='%@'",[expenseDictionary objectForKey:@"identity"]];
			[myDB updateTable: table_expenseEntries data:infoDict where:whereString intoDatabase:@""];
			[self updateUDFsForEditedExpense:[expenseDictionary objectForKey:@"UserDefinedFields"]
									 entryID:[expenseDictionary objectForKey:@"identity"] entryType:@"Expense"];
		}
		{
			//Update the corresponding fields(totalReimbursement, reimbursecurrency, ...) in the expense_sheets table 
			NSString *totalReimburseAmt = [expenseDictionary objectForKey: @"TotalReimbursement"];
			DLog(@"Recalculated reimburse amount: %@", totalReimburseAmt);
			if (totalReimburseAmt != nil){
				NSMutableDictionary *expenseSheetInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														 totalReimburseAmt, @"totalReimbursement",
														 nil];
				NSString *whereString = [NSString stringWithFormat:@"identity='%@'", _expSheetId];
				[myDB updateTable: table_ExpenseSheets data:expenseSheetInfo where:whereString intoDatabase:@""];
			}
		}
	}

}

-(void)updateUDFsForEditedExpense:(NSMutableArray *)userDefinedFields entryID:(NSString *)entryId entryType:(NSString *)entrytype{
	if (userDefinedFields != nil &&[userDefinedFields count]>0) {
		G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
		NSString *whereStr = nil;
		for (NSDictionary *udfDict in userDefinedFields) {
			whereStr =[NSString stringWithFormat:@"udf_id = '%@' and entry_id = '%@' and entry_type = '%@'",
					   [udfDict objectForKey:@"udf_id"],entryId,entrytype];
			
			NSMutableDictionary *formatedDict = nil;
			
			if([[udfDict objectForKey:@"udf_type"] isEqualToString:@"Date"]) {
				
				NSString *dateString = nil;
				if (![[udfDict objectForKey:@"udfValue"] isEqualToString:@"Select"]) {
					NSDate *udfDate = [G2Util convertStringToDate1:[udfDict objectForKey:@"udfValue"]];
					
					unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
					//NSCalendar *calendar = [NSCalendar currentCalendar];//DE3171
                    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171
					NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
					dateString = [NSString stringWithFormat:@"%@ %ld, %ld",[G2Util getMonthNameForMonthId:[comps month]], (long)[comps day], (long)[comps year]];
                    
				}else {
					dateString = @"null";
				}
				
				formatedDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"%@",dateString],@"udfValue",
								nil];
			}else {
				if ([[udfDict objectForKey:@"udfValue"] isKindOfClass:[NSString class]] && !([[udfDict objectForKey:@"udfValue"] isEqualToString:@"Select"])) {
					formatedDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%@",[udfDict objectForKey:@"udfValue"]],@"udfValue",
									nil];
				}else if([[udfDict objectForKey:@"udfValue"] isKindOfClass:[NSNumber class]]) {
					formatedDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%lf",[[udfDict objectForKey:@"udfValue"] doubleValue]],@"udfValue",
									nil];
				}
				
			}
			
			NSMutableArray *existingUDFData = [myDB select: @"*" from: tableName7 where: whereStr intoDatabase: @""];
			if(existingUDFData != nil && [existingUDFData count] > 0) {
				[myDB updateTable:tableName7 data:formatedDict where:whereStr intoDatabase:@""];
			} else  {
				[formatedDict setObject:[udfDict objectForKey:@"udf_id"] forKey:@"udf_id"];
				[formatedDict setObject:entryId forKey:@"entry_id"];
				[formatedDict setObject:entrytype forKey:@"entry_type"];
				[formatedDict setObject:[udfDict objectForKey:@"udf_name"] forKey:@"udf_name"];
				
				[myDB insertIntoTable: tableName7 data: formatedDict intoDatabase: @""];
			}
		}
	}
}
-(NSMutableArray *)getClientIdentityForClientName:(NSString *)clientName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString=[NSString stringWithFormat:@"name='%@'",clientName];
	NSMutableArray *clientsArr = [myDB select:@"identity" from:tableName4 where:whereString intoDatabase:@""];
	if ([clientsArr count]>0) {
		return clientsArr;
	}
	return nil;
}
-(NSMutableArray *)getPaymentMethodIdFromDefaultPayments:(NSString *)paymentName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"name='%@'",paymentName];
	NSMutableArray *paymentArray = [myDB select:@"identity" from:tableName9 where:where intoDatabase:@""];
	if ([paymentArray count] > 0) {
		return paymentArray;
	}
	return nil;
	
}

-(NSMutableArray *)getProjectIdentityForProjectName:(NSString *)projectName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString=[NSString stringWithFormat:@"name='%@'",projectName];
	NSMutableArray *projectArr = [myDB select:@"identity" from:tableName4 where:whereString intoDatabase:@""];
	if ([projectArr count]>0) {
		return projectArr;
	}
	return nil;
	
}

-(NSString *) getUDFIdForName:(NSString *)udfName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *moduleName=@"Expense";
	NSString *where =[NSString stringWithFormat:@"name ='%@' and moduleName='%@'",[udfName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],moduleName];//DE8588 Ullas
	NSMutableArray *udfArray = [myDB select:@"identity" from:tableName8 where:where intoDatabase:@""];
	if ([udfArray count] > 0) {
		return [[udfArray objectAtIndex:0] objectForKey:@"identity"] ;
	}
	return nil;
}

-(NSString *) getUDFTypeForId:(NSString *)udfId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"identity ='%@'",udfId];
	NSMutableArray *udfArray = [myDB select:@"udfType" from:tableName8 where:where intoDatabase:@""];
	if ([udfArray count] > 0) {
		return [[udfArray objectAtIndex:0] objectForKey:@"udfType"] ;
	}
	return nil;
}

-(NSMutableArray *) getUDFDetailsForId:(NSString *)udfId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"identity ='%@'",udfId];
	NSMutableArray *udfArray = [myDB select:@"*" from:tableName8 where:where intoDatabase:@""];
	if ([udfArray count] > 0) {
		return udfArray;
	}
	return nil;
}

-(NSMutableDictionary*) getSelectedUdfsForEntry:(NSString *)entryId andType:(NSString*)entryType {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where =[NSString stringWithFormat:@"entry_id ='%@' and entry_type='%@'",entryId,entryType];
	NSMutableArray *udfArray = [myDB select:@"*" from:tableName7 where:where intoDatabase:@""];
	if ([udfArray count] > 0) {
		NSMutableDictionary *selectedUdfDict=[NSMutableDictionary dictionary];
		for (NSDictionary *udf  in udfArray) {
			NSDictionary *udfDict=[NSDictionary dictionaryWithObjectsAndKeys:[udf objectForKey:@"udf_name"],@"udf_name",
								   [udf objectForKey:@"udf_id"],@"udf_id",
								   [udf objectForKey:@"udfValue"],@"udfValue",
								   nil];
			[selectedUdfDict setObject: udfDict forKey: [udf objectForKey:@"udf_id"]];
		}
		return  selectedUdfDict;
	}
	return nil;
}
-(NSMutableArray *)getExpenseTypeIdentityForExpenseName:(NSString *)expenseName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereStr = [NSString stringWithFormat:@"name= '%@'",expenseName];
	NSMutableArray *typeArr = [myDB select:@"*" from:tableName3 where:whereStr intoDatabase:@""];
	if ([typeArr count]>0) {
		return typeArr;
	}
	return nil;
}

-(void)deleteExpenseEntryFromDatabase:(NSString*)expenseIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereStr = [NSString stringWithFormat:@"identity= '%@'",expenseIdentity];
	[myDB deleteFromTable: table_expenseEntries where:whereStr inDatabase:@""];
}
-(void)deleteExpenseEntryInOffline:(NSString *)expenseIdentity sheetId:(NSString *)expenseSheetIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//TODO Update Entries Table with the entry delete status
	NSNumber *modified=[NSNumber numberWithInt:1];
	NSString *whereStr = [NSString stringWithFormat:@"identity = '%@'",expenseIdentity];
	NSDictionary *expenseDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"delete",@"editStatus",
								 modified,@"isModified",
								 nil];
	
	[myDB updateTable: table_expenseEntries data:expenseDict where:whereStr intoDatabase:@""];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",expenseSheetIdentity];
	NSDictionary *expenseSheetDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  modified,@"isModified",
									  nil];
	
	[myDB updateTable: table_ExpenseSheets data:expenseSheetDict where:whereString intoDatabase:@""];
}

-(NSMutableArray*)fetchSumOfAmountsForEachCurrencyTypeWithSheetId:(NSString*)sheetId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *sql = [NSString stringWithFormat:@"select sum(netAmount), currencyType from expense_entries where expense_sheet_identity = '%@' group by currencyType",sheetId];
	//changes done for delete offline support
	NSString *sql = [NSString stringWithFormat:@"select sum(netAmount), currencyType from expense_entries where expense_sheet_identity = '%@'  and editStatus <> 'delete' group by currencyType order by 1 desc",sheetId];
	
	NSMutableArray *amountArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([amountArray count]>0) {
		return amountArray;
	}
	
	return nil;
}

-(NSMutableArray*)getEntryAmountsForExpenseSheet:(NSString*)sheetId forDescOrder:(BOOL)descendingOrder
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *orderType=nil;
	if (descendingOrder) {
		orderType=@"desc";
	}else {
		orderType=@"asc";
	}
	//changes done for delete entry in offline mode.........
	//	select sum(netAmount), currencyType from expense_entries where expense_sheet_identity = '%@'  and editStatus <> 'delete' group by currencyType
	//NSString *sql = [NSString stringWithFormat:@"select currencyType, cast(netAmount as Real ) as sortedAmounts   from %@ where expense_sheet_identity='%@' order by sortedAmounts %@",tableName2,sheetId,orderType];
	//NSString *sql = [NSString stringWithFormat:@"select currencyType, cast(netAmount as Real ) as sortedAmounts   from %@ where expense_sheet_identity='%@'  order by sortedAmounts %@",tableName2,sheetId,orderType];
	NSString *sql = [NSString stringWithFormat:@"select sum(netAmount), currencyType from %@ where expense_sheet_identity = '%@' and editStatus <> 'delete' group by currencyType order by 1 %@", table_expenseEntries,sheetId,orderType];
	
	NSMutableArray *entryAmountArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([entryAmountArray count]>0) {
		return entryAmountArray;
	}
	
	return nil;
	
}

-(void) updateReimbursmentCurrencyForExpenseSheet:(NSString *)currencySymbol :(NSString *)sheetId {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity='%@'",sheetId];
	NSDictionary *infoDict = [NSDictionary dictionaryWithObject:currencySymbol forKey:@"reimburseCurrency"];
	[myDB updateTable: table_ExpenseSheets data:infoDict where:whereString intoDatabase:@""];
} 

-(BOOL)checkUDFExistsForEntry:(NSString *)udfIdentity : (NSString *)entryId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
 	NSString *whereString = [NSString stringWithFormat:@"udf_id='%@' and entry_id = '%@'",udfIdentity,entryId];
	NSMutableArray *udfArray = [myDB select:@"*" from:tableName7 where:whereString intoDatabase:@""];
	if (udfArray != nil && [udfArray count] > 0) {
		return YES;
	}
	
	return NO;
}

-(void)updateExpenseSheetTotalReimbursementAmount:(NSString *)totalAmount sheetId:(NSString *)_sheetIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity='%@'",_sheetIdentity];
	NSDictionary *infoDict = [NSDictionary dictionaryWithObject:totalAmount forKey:@"totalReimbursement"];
	[myDB updateTable: table_ExpenseSheets data:infoDict where:whereString intoDatabase:@""];
}

-(NSMutableArray *)getLastEntryAddedForSheet:(NSString *)_expenseSheetId {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select e1.* from expense_entries e1 where e1.identity =(select max(identity) from expense_entries where expense_sheet_identity = '%@')",_expenseSheetId];
    //DE5664//Juhi
    //	NSMutableArray *entryArray = [myDB executeQuery:sql];
    NSMutableArray *entryArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if (entryArray != nil && [entryArray count]>0) {
		//NSString *projIdentity = [[entryArray objectAtIndex: 0] objectForKey: @""];
		NSString *projIdentity = [[entryArray objectAtIndex: 0] objectForKey: @"projectIdentity"];
		if ([projIdentity isEqualToString:@""]) {
			projIdentity = @"null";
		}
		NSString *proSql = [NSString stringWithFormat:@"select * from projects where identity = '%@'",projIdentity];
		NSMutableArray *projTempArray = [myDB executeQueryToConvertUnicodeValues:proSql];
		//NSMutableArray *allProjects = [self getExpenseProjectsFromDatabase];
		
		if (projTempArray == nil) {
            //projIdentity = [[allProjects objectAtIndex:0] objectForKey:@"identity"];//user has that project anymore...
            return nil;
		}
		
		sql = [NSString stringWithFormat: @"select p.* from projects p where p.identity='%@'", projIdentity];
		NSArray *projInfo = [myDB executeQueryToConvertUnicodeValues: sql];
		if (projInfo != nil && [projInfo count] > 0) {
			return entryArray;
		}
	}
	
	return nil;
}


-(NSMutableArray*)getAllSheetIdentitiesFromDB
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sqlQuery = @"select identity from expense_sheets";
	NSMutableArray *identitiesArray = [myDB executeQueryToConvertUnicodeValues:sqlQuery];
	NSMutableArray *idsArry = [NSMutableArray array];
	if (identitiesArray != nil && [identitiesArray count] > 0) {
		for (NSDictionary *idDict in identitiesArray) {
			[idsArry addObject:[idDict objectForKey:@"identity"]];
		}
	}
	
	if (idsArry != nil && [idsArry count] > 0) {
		return idsArry;
	}
	return nil;
}

-(void)removeWtsDeletedSheetsFromDB:(id)responseArray
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if (responseArray != nil && [responseArray count] > 0) {
		NSDictionary *respDict = [responseArray objectAtIndex:0];
		NSArray *keysArray = [respDict allKeys];
		if (keysArray != nil && [keysArray count] > 0) {
			for (int i=0; i < [keysArray count]; i++) {
				if ([[respDict objectForKey:[keysArray objectAtIndex:i]]intValue] == 0) {
					NSString *sqlQuer = [NSString stringWithFormat:@"delete from expense_sheets where identity = '%@'",[keysArray objectAtIndex:i]];
					[myDB executeQuery:sqlQuer];
				}
			}
			
		}
	}
}

-(NSMutableArray *)getAllProjectsforDownloadedExpenseEntries
{
    
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select DISTINCT(projectIdentity) from %@ ",table_expenseEntries];
	//NSMutableArray *clientsArr = [myDB executeQuery:sql];
	NSMutableArray *projectIdsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([projectIdsArr count]>0) {
		return projectIdsArr;
	}
	return nil;

}

-(NSMutableArray *)getAllClientsforDownloadedExpenseEntries
{
    
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where expensesAllowed=%@ and identity!='null' order by name asc",tableName4,[NSNumber numberWithInt:1]];
	
	NSMutableArray *clientsArr = [myDB executeQueryToConvertUnicodeValues:sql];
    
    NSString *sql1 = [NSString stringWithFormat:@"select * from %@ where expensesAllowed=%@ and identity='null'",tableName4,[NSNumber numberWithInt:1]];
	
	NSMutableArray *noneClientsArr = [myDB executeQueryToConvertUnicodeValues:sql1];
    
    if ([clientsArr count]>0)
    {
        if ([noneClientsArr count]>0)
        {
            [clientsArr insertObject:[noneClientsArr objectAtIndex:0] atIndex:0];
        }
        return clientsArr;
          
	}
    else
    {
        if ([noneClientsArr count]>0)
        {
            return noneClientsArr;
        }
    }
    
	return nil;
    
}

-(void)updateRecentProjectsColumnForIdentity:(NSString *)projectIdentity
{
     G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    [myDB updateTable:tableName5 data:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"isExpensesRecent" , nil] where:[NSString stringWithFormat:@"identity='%@'",projectIdentity] intoDatabase:@""];
}

/*
 #pragma mark DB Deletion for Refreshing
 
 -(void)deleteExpenseSheetsForRefreshing
 {
 SQLiteDB *myDB =[SQLiteDB getInstance];
 NSString *queryEntry=@" delete from expense_entries where expense_sheet_identity in (select identity from expense_sheets where isModified=0 ) ";
 [myDB executeQuery:queryEntry];
 //[myDB deleteFromTable:@"expense_entries" where:@" expense_sheet_identity in (select identity from expense_sheets where isModified=0 )" inDatabase:@""];
 }*/



@end


//..............................

/*{
 "Status": "OK",
 "Value": [
 {
 "Type": "Replicon.Project.Domain.Project",
 "Identity": "1",
 "Properties": {
 "Id": 1,
 "Name": "Our Intranet",
 "ProjectCode": "WWW",
 "Description": "Our internal intranet",
 "EstimatedHours": {
 "Type": "Timespan",
 "Hours": 0,
 "Minutes": 0,
 "Seconds": 0,
 "Milliseconds": 0
 },
 "EstimatedCost": 0,
 "EstimatedExpenses": 0,
 "ApprovalRequired": true,
 "TimeEntryAllowed": false,
 "EntryStartDate": {
 "Type": "Date",
 "Past": true
 },
 "EntryEndDate": {
 "Type": "Date",
 "Future": true
 },
 "ExpenseEntryStartDate": {
 "Type": "Date",
 "Past": true
 },
 "ExpenseEntryEndDate": {
 "Type": "Date",
 "Future": true
 },
 "ClosedStatus": false,
 "AllAssignments": false
 },
 "UserDefinedFields": {
 "Phase": "Implementation"
 },
 "Relationships": {
 "ProjectClients": [
 {
 "Type": "Replicon.Project.Domain.Project+ProjectClient",
 "Identity": "1_3",
 "Properties": {
 "BillingPercentage": 1
 },
 "Relationships": {
 "Client": {
 "Type": "Replicon.Project.Domain.Client",
 "Identity": "3",
 "Properties": {
 "DefaultBillingRateAmount": 0,
 "DefaultBillingRateDescription": null,
 "Name": "Big Game Inc",
 "Code": "BGI",
 "Comments": "A sub contract to create a specialized graphics engine for their next project.  Big Game Inc creates a complete line of hunting arcade style games.",
 "Address1": "321 Profit Lane",
 "Address2": null,
 "City": "Calgary",
 "StateProvince": "AB",
 "ZipPostalCode": "T1A 9R4",
 "Country": "Canada",
 "Telephone": "1-403-555-1111",
 "Fax": "1-403-555-1112",
 "Website": "www.biggames.com",
 "Disabled": false,
 "Id": 3
 }
 }
 }
 }
 ],
 "Billable": {
 "Type": "Replicon.Project.Domain.TaskAllowBilling",
 "Identity": "AllowNonBillable",
 "Properties": {
 "Name": null
 }
 },
 "ClientBillingAllocationMethod": {
 "Type": "Replicon.Project.Domain.ClientBillingAllocationMethod",
 "Identity": "Single",
 "Properties": {
 "Name": "Single"
 }
 }
 }
 },
 */




