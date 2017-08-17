//
//  SynchExpenses.m
//  Replicon
//
//  Created by vijaysai on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SyncExpenses.h"
#import "RepliconAppDelegate.h"

@interface G2SyncExpenses()
- (NSMutableArray *) buildEntriesArray: (NSMutableArray *)editedEntries;
- (void) handleOfflineCreatedSheet: (NSDictionary *)sheet;
@end


@implementation G2SyncExpenses
@synthesize expenseModel;
//@synthesize modifiedSheetIdentities;

static int syncFinishedEntriesCount = 0;
static int totalEntriesModifiedCount = 0;

int builCreatedEntries = 0;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if(expenseModel == nil) {
			expenseModel = [[G2ExpensesModel alloc]init];
		}
		
	}
	return self;
}

- (void) syncModifiedExpenses :(id)_delegate {
	
	@autoreleasepool {
	

		NSMutableArray *modifiedSheets = [expenseModel getModifiedExpenseSheets];
		
		if(modifiedSheets != nil && [modifiedSheets count] > 0) {
			
		
			NSUInteger i, count = [modifiedSheets count];
			
			for (i = 0; i < count; i++) {
				NSDictionary *sheet = [modifiedSheets objectAtIndex:i];
				[modifiedSheetIdentities addObject:[sheet objectForKey:@"identity"]];
				
				//fetch the modified entries for the sheet from DB.
				
				if([[sheet objectForKey:@"editStatus"] isEqualToString:@"create"]) {
					totalEntriesModifiedCount += 1;
					[self handleOfflineCreatedSheet:sheet];
				}
				else {
					NSMutableArray *createdEntries = [expenseModel getOfflineCreatedEntriesForSheet: [sheet objectForKey:@"identity"]];
					NSMutableArray *editedEntries = [expenseModel getOfflineEditedEntriesForSheet: [sheet objectForKey:@"identity"]];
					NSMutableArray *deletedEntries = [expenseModel getOfflineDeletedEntriesForSheet: [sheet objectForKey:@"identity"]];
					
					if (deletedEntries != nil && [deletedEntries count] > 0) {
						totalEntriesModifiedCount += 1;

						[[G2RepliconServiceManager expensesService] sendRequestToDeleteExpenseEntriesForSheet:deletedEntries 
																									sheetId:[sheet objectForKey:@"identity"] delegate:self];
						
					}
					
					if (editedEntries != nil && [editedEntries count] > 0) {
						totalEntriesModifiedCount += 1;
						
						[[G2RepliconServiceManager expensesService] sendRequestToEditEntryForSheet:[self buildEntriesArray: editedEntries] 
																						 sheetId:[sheet objectForKey:@"identity"] delegate:self];
						
					}
					
					if (createdEntries != nil && [createdEntries count] > 0) {
						totalEntriesModifiedCount += 1;
						
						builCreatedEntries = 1; 
						[[G2RepliconServiceManager expensesService] sendRequestToSyncOfflineCreatedEntriesForSheet:[self buildEntriesArray: createdEntries] 
																										 sheetId:[sheet objectForKey:@"identity"] delegate:self];
						builCreatedEntries = 0; 
						
					}
				}
				
			}
			CFRunLoopRun(); // Avoid thread exiting		
		}
	
	}
	
}

- (NSMutableArray *) buildEntriesArray: (NSMutableArray *) editedEntries {
	
	NSMutableArray *entriesArray = [NSMutableArray array];
	for (NSDictionary *editedEntry in editedEntries) {
		
		NSMutableDictionary *entryDict = [NSMutableDictionary dictionary];
		[entryDict setObject:[editedEntry objectForKey:@"identity"] forKey:@"identity"];
		[entryDict setObject:[editedEntry objectForKey:@"description"] forKey:@"Description"];
		[entryDict setObject:[G2Util getDeviceRegionalDateString:[editedEntry objectForKey:@"entryDate"]] forKey:@"Date"];
		[entryDict setObject:[editedEntry objectForKey:@"billClient"] forKey:@"BillClient"];
		[entryDict setObject:[editedEntry objectForKey:@"requestReimbursement"] forKey:@"Reimburse"];
		[entryDict setObject:[editedEntry objectForKey:@"isRated"] forKey:@"isRated"];
		[entryDict setObject:[editedEntry objectForKey:@"expenseTypeIdentity"] forKey:@"expenseTypeIdentity"];
		[entryDict setObject:[editedEntry objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
		[entryDict setObject:[editedEntry objectForKey:@"clientIdentity"] forKey:@"clientIdentity"];
		
		if([editedEntry objectForKey:@"paymentMethodId"] != nil) {
			[entryDict setObject:[editedEntry objectForKey:@"paymentMethodId"] forKey:@"paymentMethodId"];
		}
		if([[editedEntry objectForKey:@"isRated"] intValue] == 1 )  {
			[entryDict setObject:[editedEntry objectForKey:@"expenseRate"] forKey:@"ExpenseRate"];
			[entryDict setObject:[editedEntry objectForKey:@"noOfUnits"] forKey:@"NumberOfUnits"];
			
		}else {
			[entryDict setObject:[editedEntry objectForKey:@"netAmount"] forKey:@"NetAmount"];
		}
		
		NSString *currencyIdentity = [expenseModel getCurrencyIdentityForSymbol:[editedEntry objectForKey:@"currencyType"]];
		[entryDict setObject:currencyIdentity forKey:@"currencyIdentity"];
		
		
		NSMutableArray *entryUdfs = [expenseModel getUDFsForSelectedEntry:[editedEntry objectForKey:@"identity"]];
		NSMutableArray *udfsArray = [NSMutableArray array];
		if(entryUdfs != nil && [entryUdfs count] > 0) {
			for (NSDictionary *udf in entryUdfs) {
				//NSString *udfType  = [expenseModel getUDFTypeForId:[udf objectForKey:@"udf_id"]];
				NSMutableArray *udfDetails = [expenseModel getUDFDetailsForId:[udf objectForKey:@"udf_id"]];
				NSString *udfType = [[udfDetails objectAtIndex:0] objectForKey:@"udfType"];
				NSNumber *udfRequired = [[udfDetails objectAtIndex:0] objectForKey:@"required"];
				NSDictionary *udfDict = [NSDictionary dictionaryWithObjectsAndKeys:[udf objectForKey:@"udfValue"] ,@"udfValue",[udf objectForKey:@"udf_name"],@"udf_name",
										 [udf objectForKey:@"udf_id"],@"udf_id",
										 udfType,@"udf_type",
										 udfRequired,@"required",
										 nil];
				[udfsArray addObject:udfDict];
			}
			[entryDict setObject:udfsArray forKey:@"UserDefinedFields"];
		}
		/*
		 if([[editedEntry objectForKey:@"expenseReceipt"] isEqualToString:@"Yes"]) {
		 NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		 NSString *filePath = [documentsPath stringByAppendingPathComponent:@"expenseReceipt"]];
		 [entryDict setObject:[Util getContentOfFileAtPath:(NSString *)path]forKey:<#(id)aKey#>
		 }
		 */
		[entriesArray addObject:entryDict];
	}
	
	return entriesArray;
}

#pragma mark ServerResponseHandling -

-(void) hanldeSheetsByIdResponse:(id) response {
	
	
}

-(void) handleOfflineCreatedSheet : (NSDictionary *)sheet {
	
	NSMutableDictionary *sheetInfodict = [NSMutableDictionary dictionary];
	NSMutableArray *entries = [expenseModel getOfflineCreatedEntriesForSheet: [sheet objectForKey:@"identity"]];
	
	[sheetInfodict setObject:[sheet objectForKey:@"identity"] forKey:@"identity"];
	[sheetInfodict setObject:[sheet objectForKey:@"description"] forKey:@"Description"];
	[sheetInfodict setObject:[sheet objectForKey:@"expenseDate"] forKey:@"ExpenseDate"];
	
	NSString *currencyIdentity = [expenseModel getCurrencyIdentityForSymbol:[sheet objectForKey:@"reimburseCurrency"]];
	[sheetInfodict setObject:currencyIdentity forKey:@"ReimbursementCurrency"];
	if(entries != nil) {
		[sheetInfodict setObject:[self buildEntriesArray:entries]forKey:@"sheetEntries"];
	}
	
	
	[[G2RepliconServiceManager expensesService] sendRequestToSyncOfflineCreatedSheet:sheetInfodict delegate:self];
	
} 

#pragma mark ServerResponseProtocol Methods

- (void) serverDidRespondWithResponse:(id) response {

	
	if (response!=nil) {
	
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) {
			
			NSMutableArray *expenseArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
			if (expenseArray!=nil && [expenseArray count]>0) {
				NSString *sheetId = [[expenseArray objectAtIndex:0] objectForKey:@"Identity"];
				
				if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == SyncOfflineCreatedEntries_ServiceId_34) {
					[expenseModel removeOfflineCreatedEntries:sheetId];
					[[G2RepliconServiceManager expensesService] sendRequestToGetExpenseById:sheetId withDelegate:self];
				}
				else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == DeleteExpenseEntry_ServiceID_25) {
					[expenseModel removeOfflineDeletedEntries:sheetId];
					[[G2RepliconServiceManager expensesService] sendRequestToGetExpenseById:sheetId withDelegate:self];
				}
				else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == EditExpenseEntries_Service_Id) {
					[expenseModel resetSheetsModifyStatus:sheetId];
					syncFinishedEntriesCount += 1;
				}
				else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == SyncOfflineCreatedSheet_Service_Id) {
					NSString *offlineSheetId = [[response objectForKey:@"refDict"]objectForKey:@"params"];
					[expenseModel deleteExpenseSheetFromDB:offlineSheetId];
					[[G2RepliconServiceManager expensesService] sendRequestToGetExpenseById:sheetId withDelegate:self];
				}
				
				if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ExpenseById_ServiceID_12) {
					[expenseModel insertExpenseSheetsInToDataBase:expenseArray];
					[expenseModel insertExpenseEntriesInToDataBase:expenseArray];
					[expenseModel insertUdfsforEntryIntoDatabase:expenseArray];
					syncFinishedEntriesCount += 1;
				}
				
				
			}
			
		}
	}else {
		
	}
	
	if (syncFinishedEntriesCount == totalEntriesModifiedCount) {
		CFRunLoopStop(CFRunLoopGetCurrent()); // Exit Thread
	}
}

- (void) serverDidFailWithError:(NSError *) error {
	
    [self showErrorAlert:error];    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
            [confirmAlertView show];
            
        }
        else 
        {
           [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    
}



@end
