//
//  SupportDataModel.m
//  Replicon
//
//  Created by Devi Malladi on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SupportDataModel.h"
#import"G2PermissionsModel.h"
#import "G2ExpensesModel.h"
static NSString *tableName3 = @"expenseTypes";
static NSString *tableName6 = @"taxCodes";
static NSString *tableName7 = @"systemPaymentMethods";
static NSString *tableName8 = @"systemPreferences";
static NSString *tableName9 = @"systemCurrencies";
static NSString *tableName10 = @"baseCurrency";
static NSString *tableName11 = @"userDefinedFields";
static NSString *tableName12 = @"udfDropDownOptions";
static NSString *userPreferencesTable = @"userPreferences";
static NSString *projectsTable = @"projects";
static NSString *clientsTable = @"clients";

static NSString *activitiesTable = @"user_activities";
static NSString *timeOffCodesTable = @"timeOff_codes";
static NSString *billingOptionsTable = @"project_billingOptions";
static NSString *projectTasksTable = @"project_tasks";
static NSString *dataSyncTable = @"dataSyncDetails";
static NSString *disclaimersTable = @"disclaimers";
static NSString *expense_Project_Type_Table = @"expense_Project_Type";

#define Max_No_Local_Taxes_5 5
@implementation G2SupportDataModel


- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}

-(void)insertSystemCurrenciesToDatabase:(NSArray *) currencyArray{

	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if ([[self getSystemCurrenciesFromDatabase]count]>0) {
		[myDB deleteFromTable:tableName9 inDatabase:@""];
	}
	
	
	
	for (int i=0; i<[currencyArray count]; i++) {
		NSString *identity = nil;
		if ([[currencyArray objectAtIndex:i]objectForKey:@"Identity"] != nil)
			identity = [[currencyArray objectAtIndex:i]objectForKey:@"Identity"];
		NSNumber * isDisabledFlag= [NSNumber numberWithBool:[[[[currencyArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Disabled"]boolValue]];
		if ([isDisabledFlag class] !=[NSNull class] &&[ isDisabledFlag boolValue] ) {
			isDisabledFlag = [NSNumber numberWithInt:1];
		}else {
			isDisabledFlag = [NSNumber numberWithInt:0];
		}
		
		
		NSNumber *identityNum = [NSNumber numberWithInt:[identity intValue]];
		NSDictionary *currencytDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
										   identityNum,@"id",
										   identity,@"identity",
										   [[[currencyArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Symbol"],@"symbol",
										   [[[currencyArray objectAtIndex:i]objectForKey:@"Properties"]objectForKey:@"Name"],@"name",
										  isDisabledFlag,@"isDisabled",
										   nil];
		
		[myDB insertIntoTable:tableName9 data:currencytDictionary intoDatabase:@""];
		
	}
	
}

-(NSMutableArray *)getSystemCurrenciesFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"isDisabled = 0";
	NSMutableArray *currencyArr = [myDB select:@"*" from:tableName9 where:whereString intoDatabase:@""];
	if (currencyArr != nil && [currencyArr count]!=0) {
		return currencyArr;
	}
	return nil;
}

-(void)insertBaseCurrencyToDatabase:(NSDictionary *) currencyDict{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if ([[self getBaseCurrencyFromDatabase]count]>0) {
		[myDB deleteFromTable:tableName10 inDatabase:@""];
	}
	if(currencyDict!=nil && ![currencyDict isKindOfClass:[NSNull class]])
    {
		NSString *identity = [currencyDict objectForKey:@"Identity"];
		NSNumber *identityNum = [NSNumber numberWithInt:[identity intValue]];
		NSDictionary *currencytDictionary=[NSDictionary dictionaryWithObjectsAndKeys:
										   identityNum,@"id",
										   identity,@"identity",
										   [[currencyDict objectForKey:@"Properties"]objectForKey:@"Symbol"],@"symbol",
										   [[currencyDict objectForKey:@"Properties"]objectForKey:@"Name"],@"name",nil];
		
		[myDB insertIntoTable:tableName10 data:currencytDictionary intoDatabase:@""];
		
	}
	
}
-(NSMutableArray *)getBaseCurrencyFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *baseCurrencyArr = [myDB select:@"*" from:tableName10 where:@"" intoDatabase:@""];
	
	if (baseCurrencyArr != nil && [baseCurrencyArr count]>0) {
		return baseCurrencyArr;
	}
	
	return nil;
}

-(void)insertSystemPreferencesToDatabase:(NSDictionary *)preferencesDict{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if ([[self getSystemPreferencesFromDatabase]count]>0) {
		[myDB deleteFromTable:tableName8 inDatabase:@""];
	}
	
	NSArray *keys = [preferencesDict allKeys];
	NSArray *values = [preferencesDict allValues];
	
    int i=0;
	int j =0;

    if ([keys containsObject:@"ExpenseColumnVisible"])
    {


        NSArray *expenseColumnKeys = [[preferencesDict objectForKey:@"ExpenseColumnVisible"]allKeys];//[[preferencesArr objectForKey:@"ExpenseColumnVisible"]allKeys];
        NSArray *expenseColumnValues = [[preferencesDict objectForKey:@"ExpenseColumnVisible"]allValues];

        for (j =0; j<[expenseColumnKeys count]; j++) {
            //DE8142
            NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      //[NSNumber numberWithInt:j+2],@"id",
                                      [expenseColumnKeys objectAtIndex:j],@"name",
                                      [expenseColumnValues objectAtIndex:j],@"status",
                                      nil];
            
            [myDB insertIntoTable:tableName8 data:infoDict intoDatabase:@""];
        }			
        

    }

	for (i=0; i<[keys count]; i++) {
		if (![[keys objectAtIndex:i]isEqualToString:@"ExpenseColumnVisible"])
        {
            NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      //[NSNumber numberWithInt:i+j],@"id",
                                      [keys objectAtIndex:i],@"name",
                                      [values objectAtIndex:i],@"status",
                                      nil];
            //DLog(@"Saving system Preferences to DB:::SupportDataModel %@",infoDict);
            
            [myDB insertIntoTable:tableName8 data:infoDict intoDatabase:@""];
        }
	}
	
	
}
-(NSMutableArray*)getSystemPreferencesFromDatabase{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *systemPreferencesArr = [myDB select:@"*" from:tableName8 where:@"" intoDatabase:@""];
	if (systemPreferencesArr != nil && [systemPreferencesArr count]!=0) {
		return systemPreferencesArr;
	}
	return nil;
}
-(BOOL)getBillingInfoFromSystemPreferences:(NSString*)billingInfoString
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select status from systemPreferences where name='%@' ",[billingInfoString stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *billingInfoArr=[myDB executeQueryToConvertUnicodeValues:sql];
	BOOL billingInfoFlag = NO;
	if (billingInfoArr!=nil&&[billingInfoArr count]>0) {
	for (int x=0; x<[billingInfoArr count]; x++) {
		billingInfoFlag = [[[billingInfoArr objectAtIndex:x] objectForKey:@"status"] boolValue];
	}
	}
	
		return billingInfoFlag;

}
//DE4368 Ullas M L
-(BOOL)getPaymnetMethodInfoFromSystemPreferences:(NSString*)paymentMethod
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select status from systemPreferences where name='%@' ",[paymentMethod stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
    NSMutableArray *paymentMethodInfoArr=[myDB executeQueryToConvertUnicodeValues:sql];
    BOOL paymentMethodInfoFlag = NO;
    if (paymentMethodInfoArr!=nil&&[paymentMethodInfoArr count]>0) {
        for (int x=0; x<[paymentMethodInfoArr count]; x++) {
            paymentMethodInfoFlag = [[[paymentMethodInfoArr objectAtIndex:x] objectForKey:@"status"] boolValue];
            }
    }
    
    return paymentMethodInfoFlag;
    
}


-(NSMutableArray *)getIdentityForSelectedCurrency:(NSString *)selectedCurrency{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *sql = nil;
	//sql = [NSString stringWithFormat:@"select * from %@ where symbol  = '%@'",tableName9,selectedCurrency];	DE3596
    sql = [NSString stringWithFormat:@"select * from %@ where symbol  = '%@'",tableName9,[selectedCurrency stringByReplacingOccurrencesOfString:@"'"withString:@"''" ]];
	
	NSMutableArray *selectedCurrencyArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([selectedCurrencyArr count]>0) {
		
		return selectedCurrencyArr;
	}
	
	return nil;
	
}

-(NSMutableArray*)getEnabledSystemPreferences{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where = @"status ='1'";
	NSString *column = @"name";
	NSMutableArray *enabledsystemPreferencesArr = [myDB select:column from:tableName8 where:where intoDatabase:@""];
	if ([enabledsystemPreferencesArr count]!=0) {
		return enabledsystemPreferencesArr;
	}
	return nil;        
}

-(NSMutableArray*)getDisclaimerPreferencesforType:(NSString *)typeName foriSOName:(NSString *)isoName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *where = [NSString stringWithFormat: @" disclaimerTypeName ='%@' and  isoName='%@' " ,typeName,isoName];
	NSMutableArray *disclaimerPreferencesArr = [myDB select:@"*" from:disclaimersTable where:where intoDatabase:@""];
	if ([disclaimerPreferencesArr count]!=0) {
		return disclaimerPreferencesArr;
	}
	return nil;        
}

-(void)insertPaymentMethodsAll:(NSArray*)paymentArr{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	if ([[self getPaymentMethodsAllFromDatabase]count]>0) {
		[myDB deleteFromTable:tableName7 inDatabase:@""];
	}
	for (int i =0; i<[paymentArr count]; i++) {
		NSDictionary *dict = [[paymentArr objectAtIndex:i]objectForKey:@"Properties"];
		NSString *identity = [[paymentArr objectAtIndex:i]objectForKey:@"Identity"];
		NSNumber *identityNum = [NSNumber numberWithInt:[identity intValue]];
		//id description = [dict objectForKey:@"Description"];
        NSString *description = [dict objectForKey:@"Description"];
		NSString *desc;
		if ([description isKindOfClass:[NSNull class]]) {
			
			desc = @"null";
		}else {
			desc = description;
		}
		NSNumber *isDisabled =  [NSNumber numberWithInt:0];
		if ([dict objectForKey:@"Disabled"] != [NSNull null] && [[dict objectForKey:@"Disabled"] boolValue]) {
			isDisabled = [NSNumber numberWithInt:1];
		}
		
		NSDictionary *payDict=[NSDictionary dictionaryWithObjectsAndKeys:
							   identityNum ,@"id",
							   [dict objectForKey:@"Name"],@"name",
							   identity,@"identity",
							   desc,@"description",
							   isDisabled,@"isDisabled",
							   nil];
		[myDB insertIntoTable:tableName7 data:payDict intoDatabase:@""];
	}	
	
}
-(NSMutableArray *)getPaymentMethodsAllFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"isDisabled = 0";
	NSMutableArray *paymethodArr = [myDB select:@"*" from:tableName7 where:whereString intoDatabase:@""];
	if ([paymethodArr count]!=0) {
		return paymethodArr;
	}
	return nil;
}
- (void) insertTaxCodesAllInToDatabase:(NSArray *) expenseTypeArray {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *identity = nil;
	if ([[self getTaxCodesAllFromDatabase]count]>0) {
		[myDB deleteFromTable:@"taxCodes" inDatabase:@""];
	}
	
	for (int i = 0; i<[expenseTypeArray count]; i++) {
		NSMutableDictionary *typeDict =[NSMutableDictionary dictionary];
		id taxcodeDict = [expenseTypeArray objectAtIndex:i];
		if([taxcodeDict isKindOfClass:[NSDictionary class]]){
			identity = [taxcodeDict objectForKey:@"Identity"];
			NSNumber *identityNum = [NSNumber numberWithInt:[identity intValue]];
			[typeDict setObject:identityNum forKey:@"id"];
			[typeDict setObject:identity forKey:@"identity"];
			[typeDict setObject:[[taxcodeDict objectForKey:@"Properties"]objectForKey:@"Name"] forKey:@"name"];
			[typeDict setObject:[[taxcodeDict objectForKey:@"Properties"]objectForKey:@"Formula"] forKey:@"formula"];
			
		}

		[myDB insertIntoTable:@"taxCodes" data:typeDict intoDatabase:@""];
		
	}
}

-(NSMutableArray *)getTaxCodesAllFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *taxcodeArr = [myDB select:@"*" from:tableName6 where:@"" intoDatabase:@""];
	if ([taxcodeArr count]>0) {
		return taxcodeArr;
	}
	return nil;

}
-(NSMutableArray*)getAmountTaxCodesForSelectedProjectID:(NSString*)projectId withExpenseType:(NSString*)expenseType
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.name = '%@'",tableName3,expense_Project_Type_Table,tableName3,expense_Project_Type_Table,expense_Project_Type_Table,projectId ,tableName3,[expenseType stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	//NSMutableArray *expenseTypeArray = [myDB executeQuery:sql];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	NSString *typeString=nil;
	NSMutableArray *taxDetailsArray=[NSMutableArray array];
	for (int i=0; i<[expenseTypeArray count]; i++) {
		typeString=[[expenseTypeArray objectAtIndex:i] objectForKey:@"type"];
		
		if ([typeString isEqualToString:@"FlatWithTaxes"] || [typeString isEqualToString:@"RatedWithTaxes"]) {
			for (int j=1; j<=5; j++) {
				NSString *taxIdString=[[expenseTypeArray objectAtIndex:i] objectForKey:[NSString stringWithFormat:@"taxCode%d",j]];
				NSString *sql = [NSString stringWithFormat:@"select * from '%@' where identity  = '%@' ",tableName6,taxIdString];
				//NSMutableArray *taxesArray= [[myDB executeQuery:sql] retain];
				//NSMutableArray *taxesArray= [[myDB executeQueryToConvertUnicodeValues:sql]retain];
				[taxDetailsArray addObjectsFromArray: [myDB executeQueryToConvertUnicodeValues:sql]];
				
			}
		}else {
			DLog(@"NOTAXES");
		}
		
	}
	
	if (typeString!=nil)
	[taxDetailsArray addObject:typeString];
	
	return taxDetailsArray;
}


//GETTING TAXES INFO FOR ENTRY FROM ENTRIES DB

-(NSMutableArray*)getTaxCodesForSavedEntry:(NSString*)projectId withExpenseType:(NSString*)expenseType andId:(NSString*)entryId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from expense_entries where identity  = '%@' ",entryId];
	NSMutableArray *expenseEntryArray = [myDB executeQueryToConvertUnicodeValues:sql];
	NSString *typeString=nil;
	NSMutableArray *taxDetailsArray=[NSMutableArray array];
	NSString *sqlForType = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.name = '%@'",tableName3,expense_Project_Type_Table,tableName3,expense_Project_Type_Table,expense_Project_Type_Table,projectId ,tableName3,[expenseType stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sqlForType];
	if (expenseTypeArray != nil && [expenseTypeArray count] > 0) {
		typeString=[[expenseTypeArray objectAtIndex:0] objectForKey:@"type"];
	}else {
		if (expenseEntryArray != nil && [expenseEntryArray count] > 0) {
			typeString=[[expenseEntryArray objectAtIndex:0] objectForKey:@"type"];
		}
	}

	
	if (typeString != nil && ([typeString isEqualToString:@"FlatWithTaxes"] || [typeString isEqualToString:@"RatedWithTaxes"])) {
		for (int j=1; j<=5; j++) {
			NSString *taxIdString=[[expenseEntryArray objectAtIndex:0] objectForKey:[NSString stringWithFormat:@"taxCode%d",j]];
			NSString *sqlTax = [NSString stringWithFormat:@"select * from '%@' where identity  = '%@' ",tableName6,taxIdString];
		[taxDetailsArray addObjectsFromArray: [myDB executeQueryToConvertUnicodeValues:sqlTax]];
		}
	}else {
			DLog(@"NOTAXES");
	}
		
	if (typeString!=nil)
		[taxDetailsArray addObject:typeString];
	
	return taxDetailsArray;
}

/**
 * @params dropDownOptionsArray: UserDefinedFields Array ie., the RESPONSE Array.
 * @params module:differentiate's USDF's among different modules
 * @return type : void	   
 * Method Description: Used to INSERT into DB, the USERDEFINED FIELDS.
 */



-(void)insertUserDefinedFieldsToDatabase:(NSArray *)userDefinedFieldArr moduleName:(NSString *)module{
	
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    //	if ([[self getUserDefineFieldsFromDatabase]count]>0) {
    //		[myDB deleteFromTable:tableName11 inDatabase:@""];
    //	}
    
    NSString *deleteWhereString = [NSString stringWithFormat:@"moduleName = 'Expense'"];
	[myDB deleteFromTable:tableName11 where:deleteWhereString inDatabase:@""];
	
	NSString *name = @"null";
	NSString *textDefaultVal= @"null";
	NSString *dateDefaultVal = @"null";
	NSString *dateMinVal = @"null";
	NSString *dateMaxVal = @"null";
	NSNumber *dateDefaultValIsToday= nil; //[NSNumber numberWithInt:0];	//fixed memory leak
	NSNumber *textMaxVal;
	NSNumber *numericDefaultVal;
	NSNumber *numericMinVal;
	NSNumber *numericMaxVal;
	NSNumber *numericDecimalPlaces=0;
	NSString *identity;
	NSString *udfType;
	NSString *moduleName = @"Expense";
    ////	TextMaximumLength
	
    //DE4055//Juhi
	//NSMutableDictionary *infoDict=[NSMutableDictionary dictionary];
	
	for (int i=0; i<[userDefinedFieldArr count]; i++) {
        
        NSArray *fieldsArray = [[[userDefinedFieldArr objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Fields"];
		
		for (int j=0 ; j<[fieldsArray count]; j++) {
			NSMutableDictionary *infoDict=[NSMutableDictionary dictionary];//DE4055//Juhi
			
            int enabled=0,required=0,hidden=0;
			
			identity = [[fieldsArray objectAtIndex:j] objectForKey:@"Identity"];
			
			
			udfType = [[[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"]
						objectForKey:@"Type"]objectForKey:@"Identity" ];
			
			[infoDict setObject:udfType forKey:@"udfType"];
			[infoDict setObject:moduleName forKey:@"moduleName"];
			NSDictionary *propertiesDict = [[fieldsArray objectAtIndex:j]objectForKey:@"Properties"];
			
			if ([[propertiesDict objectForKey:@"Enabled"] boolValue] == YES){
				enabled = 1;
			}
			
			if ([[propertiesDict objectForKey:@"Required"] boolValue]== YES){
				required = 1;
			}
			if ([[propertiesDict objectForKey:@"Hidden"] boolValue]== YES){
				hidden = 1;
			}
			if ([propertiesDict objectForKey:@"Name"]!= nil) {
				name = [propertiesDict objectForKey:@"Name"];
			}
			
			if ([[propertiesDict objectForKey:@"TextDefaultValue"]isKindOfClass:[NSNull class]]) {
				textDefaultVal = @"null";
			}else {
				textDefaultVal=[propertiesDict objectForKey:@"TextDefaultValue"];
			}
			
            
            if ([propertiesDict objectForKey:@"FieldIndex"]!= nil) {
                [infoDict setObject:[propertiesDict objectForKey:@"FieldIndex"] forKey:@"fieldIndex"];
			}
			
			[infoDict setObject:textDefaultVal forKey:@"textDefaultValue"];
			
			if ([[propertiesDict objectForKey:@"TextMaximumLength"]isKindOfClass:[NSNull class]]) {
				//textMaxVal = [NSNumber numberWithInt:0];
			}else{
				textMaxVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"TextMaximumLength"]intValue]];
				[infoDict setObject:textMaxVal forKey:@"textMaxValue"];
			}
			
			
			if ([[propertiesDict objectForKey:@"NumericDefaultValue"]isKindOfClass:[NSNull class]]) {
				//numericDefaultVal = [NSNumber numberWithInt:0];
			}else{
                //DE4012//Juhi
//				numericDefaultVal =[NSNumber numberWithDouble:[[propertiesDict objectForKey:@"NumericDefaultValue"]doubleValue]];
                numericDefaultVal =[propertiesDict objectForKey:@"NumericDefaultValue"];
				[infoDict setObject:numericDefaultVal forKey:@"numericDefaultValue"];
			}
			
			if ([[propertiesDict objectForKey:@"NumericMinimumValue"]isKindOfClass:[NSNull class]]) {
				//numericMinVal = [NSNumber numberWithInt:0];
			}else{
				numericMinVal =[NSNumber numberWithDouble:[[propertiesDict objectForKey:@"NumericMinimumValue"]doubleValue]];
				[infoDict setObject:numericMinVal forKey:@"numericMinValue"];
			}
			
			if ([[propertiesDict objectForKey:@"NumericMaximumValue"]isKindOfClass:[NSNull class]]) {
				//numericMaxVal = [NSNumber numberWithInt:0];
			}else{
				numericMaxVal =[NSNumber numberWithDouble:[[propertiesDict objectForKey:@"NumericMaximumValue"]doubleValue]];
				[infoDict setObject:numericMaxVal forKey:@"numericMaxvalue"];
			}
			if ([[propertiesDict objectForKey:@"NumericDecimalPlaces"]isKindOfClass:[NSNull class]]) {
				//numericDecimalPlaces = [NSNumber numberWithInt:0];
			}else{
				numericDecimalPlaces =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericDecimalPlaces"]intValue]];
				[infoDict setObject:numericDecimalPlaces forKey:@"numericDecimalPlaces"];
			}
			
			if([propertiesDict objectForKey:@"DateDefaultValue"]!= nil  && ![[propertiesDict objectForKey:@"DateDefaultValue"] isKindOfClass:[NSNull class]] ){
				id  dateDefaultDict = [propertiesDict objectForKey:@"DateDefaultValue"];
				
				if ([dateDefaultDict isKindOfClass:[NSDictionary class]]) {	
					int month = [[dateDefaultDict objectForKey:@"Month"]intValue];
					dateDefaultVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
									 [dateDefaultDict objectForKey:@"Day"],[dateDefaultDict objectForKey:@"Year"]];					 
				}
                [infoDict setObject:dateDefaultVal forKey:@"dateDefaultValue"];
			}
			
			if ([[propertiesDict objectForKey:@"DateDefaultValueIsToday"] isKindOfClass:[NSNull class]]) {
				//dateDefaultValIsToday = [NSNumber numberWithInt:0];
				
			}else {
				if ([[propertiesDict objectForKey:@"DateDefaultValueIsToday"] boolValue] == YES){
                    dateDefaultValIsToday = [NSNumber numberWithInt:1];
					[infoDict setObject:dateDefaultValIsToday forKey:@"isDateDefaultValueToday"];
				}
			}
			
			if ([propertiesDict objectForKey:@"DateMinimumValue"] != nil && ![[propertiesDict objectForKey:@"DateMinimumValue"] isKindOfClass:[NSNull class]]) {
				
				id  dateMinValDict = [propertiesDict objectForKey:@"DateMinimumValue"];
				if ([dateMinValDict isKindOfClass:[NSDictionary class]]) {
					
					int month = [[dateMinValDict objectForKey:@"Month"]intValue];
					dateMinVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
								 [dateMinValDict objectForKey:@"Day"],[dateMinValDict objectForKey:@"Year"]];
					
				}
				[infoDict setObject:dateMinVal forKey:@"dateMinValue"];
			}
			
			if ([propertiesDict objectForKey:@"DateMaximumValue"] != nil && ![[propertiesDict objectForKey:@"DateMaximumValue"] isKindOfClass:[NSNull class]]) {
				id dateMaxValDict = [propertiesDict objectForKey:@"DateMaximumValue"];
				if ([dateMaxValDict isKindOfClass:[NSDictionary class]]) {
					int month = [[dateMaxValDict objectForKey:@"Month"]intValue];
					dateMaxVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
								 [dateMaxValDict objectForKey:@"Day"],[dateMaxValDict objectForKey:@"Year"]];
				}
				[infoDict setObject:dateMaxVal forKey:@"dateMaxValue"];
			}
            
            //			[infoDict setObject:[NSNumber numberWithInt:j+1] forKey:@"id"];
			[infoDict setObject:identity forKey:@"identity"];
            [infoDict setObject:[NSNumber numberWithInt:enabled] forKey:@"enabled"];
            [infoDict setObject:[NSNumber numberWithInt:required] forKey:@"required"];
			[infoDict setObject:[NSNumber numberWithInt:hidden] forKey:@"hidden"];
			[infoDict setObject:name forKey:@"name"];
			
			
			
			[myDB insertIntoTable:tableName11 data:infoDict intoDatabase:@""];						 
		}	
	}
}



-(NSMutableArray *)getUserDefineFieldsFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"enabled = 1 and hidden = 0";
	NSMutableArray *udfArr = [myDB select:@"*" from:tableName11 where:whereString intoDatabase:@""];
	//NSMutableArray *udfArr = [myDB select:@"*" from:tableName11 where:@"" intoDatabase:@""];
	if ([udfArr count]!=0) {
		return udfArr;
	}
	return nil;
}

-(NSMutableArray *)getEnabledUserDefineFieldsFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"enabled = 1 and hidden = 0";
	NSMutableArray *udfArr = [myDB select:@"*" from:tableName11 where:whereString intoDatabase:@""];
	if ([udfArr count]!=0) {
		for (int j = 0; j <[udfArr count] ; j++) {
			if ([self checkExpensePermissionWithPermissionName: [[udfArr objectAtIndex:j] objectForKey:@"name"]]){
			}else {
				[udfArr removeObjectAtIndex:j];
				j--;
		}
		}

		return udfArr;
	}
	return nil;
}

-(NSMutableArray *)getUserDefineFieldsExpensesFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"enabled = 1 and hidden = 0 and moduleName='Expense' order by fieldIndex";
	NSMutableArray *udfArr = [myDB select:@"*" from:tableName11 where:whereString intoDatabase:@""];
	//NSMutableArray *udfArr = [myDB select:@"*" from:tableName11 where:@"" intoDatabase:@""];
	if ([udfArr count]!=0) {
		return udfArr;
	}
	return nil;
}

-(NSMutableArray *)getEnabledUserDefineFieldsExpensesFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"enabled = 1 and hidden = 0 and moduleName='Expense' order by fieldIndex";
	NSMutableArray *udfArr = [myDB select:@"*" from:tableName11 where:whereString intoDatabase:@""];
	if ([udfArr count]!=0) {
		for (int j = 0; j <[udfArr count] ; j++) {
			if ([self checkExpensePermissionWithPermissionName: [[udfArr objectAtIndex:j] objectForKey:@"name"]]){
			}else {
				[udfArr removeObjectAtIndex:j];
				j--;
            }
		}
        
		return udfArr;
	}
	return nil;
}

/**
 * @params dropDownOptionsArray: UserDefinedFields Array ie., the RESPONSE Array. 
 * @return type : void	   
 * Method Description: Used to INSERT into DB, the USERDEFINED DropDown Options.
 */

-(void)insertDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
//	if ([self  getDropDownOptionsFromDatabase]!=nil && [[self  getDropDownOptionsFromDatabase]count]>0) {
//		[myDB deleteFromTable:tableName12 inDatabase:@""];
//	}
    


	
	NSMutableDictionary *dropDownOptionsDict ;
	NSString *identity = @"null";
	int enabled =0;
	int defaultOption =0;
	NSString *value = @"null";
	NSString *name = @"null";
	NSString *udfIdentity;
	
	int index=500;
	
	for (int i =0; i<[dropDownOptionsArray count]; i++) {
		NSArray *fieldsArray = [[[dropDownOptionsArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Fields"];
		for (int j=0; j<[fieldsArray count]; j++) {
			NSDictionary *relationShipsDict = [[fieldsArray objectAtIndex:j]objectForKey:@"Relationships"];
			NSArray *dropDownOptionsArray = [relationShipsDict objectForKey:@"DropDownOptions"];
			name = [[[relationShipsDict objectForKey:@"Type"] objectForKey:@"Properties"] objectForKey:@"Name"];
			udfIdentity = [[fieldsArray objectAtIndex:j]objectForKey:@"Identity"];
            NSString *deleteWhereString = [NSString stringWithFormat:@"udfIdentity = '%@'",udfIdentity];
            [myDB deleteFromTable:tableName12 where:deleteWhereString inDatabase:@""];
			if (dropDownOptionsArray != nil && [dropDownOptionsArray count] > 0) {
				for (int k=0; k<[dropDownOptionsArray count]; k++) {
					
					index=index+1;
					if ([[dropDownOptionsArray objectAtIndex:k]objectForKey:@"Properties"]) {
						if ([[[dropDownOptionsArray objectAtIndex:k]objectForKey:@"Properties"]objectForKey:@"Value"] != nil) {
							value = [[[dropDownOptionsArray objectAtIndex:k]objectForKey:@"Properties"]objectForKey:@"Value"];
						}
						if ([[[[dropDownOptionsArray objectAtIndex:k]objectForKey:@"Properties"]
							  objectForKey:@"Enabled"]boolValue] == YES) {
							enabled =1;
						}else {
							enabled =0;
						}
						
						if ([[[[dropDownOptionsArray objectAtIndex:k]objectForKey:@"Properties"]
							  objectForKey:@"DefaultOption"]boolValue ] == YES) {
							defaultOption =1;
						}else {
							defaultOption =0;
						}
						
						identity= ([[dropDownOptionsArray objectAtIndex:k]objectForKey:@"Identity"]);
					}
					dropDownOptionsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithInt:index],@"id",
										   identity,@"identity",
										   udfIdentity,@"udfIdentity",
										   value,@"value",
										   [NSNumber numberWithInt:enabled],@"enabled",
										   name,@"name",
										   [NSNumber numberWithInt:defaultOption],@"defaultOption",nil];
					[myDB insertIntoTable:tableName12 data:dropDownOptionsDict intoDatabase:@""];	
					
				}
			}
		}
	}
}
-(NSMutableArray *)getDropDownOptionsFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *whereString = @"enabled = 1";
	NSMutableArray *udfDropDownArr = [myDB select:@"*" from:tableName12 where:whereString intoDatabase:@""];
	
	if ([udfDropDownArr count]!=0) {
		return udfDropDownArr;
	}
	return nil;
}

-(NSMutableArray *)getDropDownOptionsForSelectedUDFIdentity:(NSString *)udfIdentity{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *where = [NSString stringWithFormat:@"udfIdentity='%@' and enabled = 1",udfIdentity];
	NSMutableArray *udfDropDownArr = [myDB select:@"*" from:tableName12 where:where intoDatabase:@""];
	
	if ([udfDropDownArr count]!=0) {
		return udfDropDownArr;
	}
	return nil;
}


-(NSMutableArray *)getUserDefineFieldOFType:(NSString *)type{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *sql = nil;
	if ([type isEqualToString:@"Numeric"]) {
		sql = [NSString stringWithFormat:@"select identity,name,udfType,numericDefaultValue,numericMaxValue,numericMinValue,numericDecimalPlaces,enabled,required,hidden from '%@' where udfType  = '%@'",tableName11,type ];	
		
    }else if ([type isEqualToString:@"Text"]){
		sql = [NSString stringWithFormat:@"select identity,name,udfType,textDefaultValue,textMaxValue,enabled,required,hidden from '%@' where udfType  = '%@'",tableName11,type ];	
		
	}else if ([type isEqualToString:@"Date"]){
		sql = [NSString stringWithFormat:@"select identity,name,udfType,dateDefaultValue,isDateDefaultValueToday,dateMaxValue,dateMinValue,enabled,required,hidden from '%@' where udfType  = '%@'",tableName11,type ];	
	}
	else if ([type isEqualToString:@"DropDown"]){
		sql = [NSString stringWithFormat:@"select identity,name,udfType,enabled,required,hidden from '%@' where udfType  = '%@'",tableName11,type ];	
	}
	NSMutableArray *udfArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([udfArr count]!=0) {
		return udfArr;
	}
	return nil;

}

-(NSMutableArray *)getDropDownOptionsForUDFIdentity:(NSString *)udfIdentity{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSString *sql = nil;
	sql = [NSString stringWithFormat:@"select * from '%@' where udfIdentity  = '%@' and enabled = 1 order by value asc",tableName12,udfIdentity];	
	
	NSMutableArray *dropDownOptionsArr = [myDB executeQueryToConvertUnicodeValues:sql];
	if ([dropDownOptionsArr count]!=0) {
		return dropDownOptionsArr;
	}
	return nil;

}



-(BOOL)checkExpensePermissionWithPermissionName:(NSString*)permissionName{
	NSMutableArray *permissionsArray = [self getEnabledSystemPreferences];
	
	for (int i=0; i<[permissionsArray count]; i++) {
		NSDictionary *dict = [permissionsArray objectAtIndex:i];
		if ([[dict objectForKey:@"name"]isEqualToString:permissionName] ) {
			return YES;
		}
	}
	return NO;
}
-(void)deleteSupportDataFromDatabase{
	
}

-(NSString*)getSystemCurrencyIdFromDBUsingCurrencySymbol:(NSString*)currencySymbol
{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	//NSMutableArray *currencyArray = [myDB select:@"*" from:tableName9 where:[NSString stringWithFormat:@"symbol='%@'",currencySymbol] intoDatabase:@""];DE3596
    NSMutableArray *currencyArray = [myDB select:@"*" from:tableName9 where:[NSString stringWithFormat:@"symbol='%@'",[currencySymbol stringByReplacingOccurrencesOfString:@"'"withString:@"''" ]] intoDatabase:@""];
	NSString *currencyId=nil;
	if ([currencyArray count]!=0) {
		currencyId= [[currencyArray objectAtIndex:0]objectForKey:@"identity"];
	}
	return currencyId;
}

-(NSMutableArray*)getExpenseUnitLabelsFromDB:(NSString*)projectId withExpenseType:(NSString*)expenseType
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.name = '%@'",tableName3,expense_Project_Type_Table,tableName3,expense_Project_Type_Table,expense_Project_Type_Table,projectId ,tableName3,[expenseType stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];

	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	NSMutableArray *expenseUnitLableArray=[NSMutableArray array];
	for (int i=0; i<[expenseTypeArray count]; i++) {
		[expenseUnitLableArray addObject:[[expenseTypeArray objectAtIndex:i] objectForKey:@"expenseUnitLabel"]];
	}
	
	if (expenseUnitLableArray!=nil && [expenseUnitLableArray count]>0) {
		return expenseUnitLableArray;
	}
	
	return nil;
	
}

-(NSString*)getExpenseModeOfTypeForTaxesFromDB:(NSString*)projectId withType:(NSString*)expType andColumnName:(NSString*)colomnName
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.name = '%@'",tableName3,expense_Project_Type_Table,tableName3,expense_Project_Type_Table,expense_Project_Type_Table,projectId ,tableName3,[expType stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if (expenseTypeArray != nil && [expenseTypeArray count] == 0) {
		return nil;
	}
	NSString *colomnValue = [[expenseTypeArray objectAtIndex:0] objectForKey:colomnName];
	return colomnValue;
}
-(NSString*)getExpenseModeOfTypeForTaxesFromDBwithType:(NSString*)expType andColumnName:(NSString*)colomnName
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.name = '%@'",tableName3 ,expense_Project_Type_Table,tableName3,expense_Project_Type_Table,tableName3,[expType stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if (expenseTypeArray != nil && [expenseTypeArray count] == 0) {
		return nil;
	}
	NSString *colomnValue = [[expenseTypeArray objectAtIndex:0] objectForKey:colomnName];
	return colomnValue;
}


//Added to calucate taxes for each entry
-(NSMutableArray*)getExpenseLocalTaxcodesFromDB:(NSString*)projectId withExpenseType:(NSString*)expenseType
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@,%@ where %@.identity=%@.expenseTypeIdentity and %@.projectIdentity  = '%@' and %@.name = '%@'",tableName3,expense_Project_Type_Table,tableName3,expense_Project_Type_Table,expense_Project_Type_Table,projectId ,tableName3,[expenseType stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	NSMutableArray *expenseLocalTaxesArray=[NSMutableArray array];
	for (int i=0; i<[expenseTypeArray count]; i++) {
		for (int x=1; x<=Max_No_Local_Taxes_5; x++) {
		[expenseLocalTaxesArray addObject:[[expenseTypeArray objectAtIndex:i] objectForKey:[NSString stringWithFormat:@"formula%d",x]]];	
		}
		
	}
	
	if (expenseLocalTaxesArray!=nil && [expenseLocalTaxesArray count]>0) {
		return expenseLocalTaxesArray;
	}
	
	return nil;
}



//Added to calucate taxes for each entry
-(NSMutableArray*)getExpenseLocalTaxcodesForEntryFromDB:(NSString*)entryId
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from expense_entries where identity = '%@' ",entryId];
	NSMutableArray *expenseTypeArray = [myDB executeQueryToConvertUnicodeValues:sql];
	NSMutableArray *expenseLocalTaxesArray=[NSMutableArray array];
	for (int i=0; i<[expenseTypeArray count]; i++) {
		for (int x=1; x<=Max_No_Local_Taxes_5; x++) {
			[expenseLocalTaxesArray addObject:[[expenseTypeArray objectAtIndex:i] objectForKey:[NSString stringWithFormat:@"formula%d",x]]];	
		}
		
	}
	
	if (expenseLocalTaxesArray!=nil && [expenseLocalTaxesArray count]>0) {
		return expenseLocalTaxesArray;
	}
	
	return nil;
}

/* This method saves User Preferences from Api to DB.
 * Currently only Timesheet.HourFormat is saved. Need to save all
 * preferences in future.
 */
-(void)saveUserPreferencesFromApiToDB: (NSDictionary *)preferencesDict {
//	DLog(@"User Preferences response %@",preferencesArray);
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    [myDB deleteFromTable:userPreferencesTable inDatabase:@""];
    
	NSString *timesheetFormat = nil;
	NSString *hourFormat      = nil;
   
	NSString *dateFormat      = nil;
	NSDictionary *hourformatDict = [preferencesDict objectForKey:@"Timesheet.HourFormat"];
		if (hourformatDict != nil && ![hourformatDict isKindOfClass:[NSNull class]]) {
			hourFormat = [hourformatDict objectForKey:@"Identity"];
		}
    
    

    
    NSDictionary *timeSheetformatDict = [preferencesDict objectForKey:@"Timesheet.Format"];
		if (timeSheetformatDict != nil && ![timeSheetformatDict isKindOfClass:[NSNull class]]) {
			timesheetFormat = [timeSheetformatDict objectForKey:@"Identity"];
		}
	NSDictionary *hourformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
													   hourFormat,@"preferenceValue",
													   @"Timesheet.HourFormat",@"preferenceName",
													   nil];
    NSDictionary *timeformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [preferencesDict objectForKey:@"Timesheet.TimeFormat"],@"preferenceValue",
                                          @"Timesheet.TimeFormat",@"preferenceName",
                                          nil];
    if ([ [preferencesDict objectForKey:@"Timesheet.TimeFormat"]  isEqualToString:@"%#H:%M"]) {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"AM_PM" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if ([ [preferencesDict objectForKey:@"Timesheet.TimeFormat"]  isEqualToString:@"%#I:%M %P"]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AM_PM" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
	NSDictionary *timesheetformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
							  timesheetFormat,@"preferenceValue",
							  @"Timesheet.Format",@"preferenceName",
							  nil];
	NSDictionary *dateFormatDict   = [preferencesDict objectForKey:@"Timesheet.DateFormat"];
	if (dateFormatDict != nil && ![dateFormatDict isKindOfClass:[NSNull class]]) {
		dateFormat = [preferencesDict objectForKey:@"Timesheet.DateFormat"];
	}
	NSDictionary *dateformatDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
										  dateFormat,@"preferenceValue",
										  @"Timesheet.DateFormat",@"preferenceName",
										  nil];
	NSArray *detailsArray = [NSArray arrayWithObjects:hourformatDictionary,timeformatDictionary,
							timesheetformatDictionary,dateformatDictionary,nil];
	for (int i =0; i<[detailsArray count]; i++) {
		[myDB insertIntoTable:userPreferencesTable data:[detailsArray objectAtIndex:i] intoDatabase:@""];
	}
	
}

-(void)saveUserDisclaimersFromApiToDB: (NSDictionary *)preferencesDict {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    [myDB deleteFromTable:disclaimersTable inDatabase:@""];
    

       
       
        NSString *disclaimerTypeName=[[preferencesDict objectForKey:@"Properties"] objectForKey:@"DisclaimerTypeName"];
        NSArray *contentOptionsArray=[[preferencesDict objectForKey:@"Relationships"]objectForKey:@"ContentOptions"];
        for (int j=0; j<[contentOptionsArray count]; j++) 
        {
            NSDictionary *contentDict=[contentOptionsArray objectAtIndex:j];
             NSString *identity=[contentDict objectForKey:@"Identity"];
            NSString *disclaimerTitle=[[contentDict objectForKey:@"Properties"] objectForKey:@"Title"];
            NSString *disclaimerDescription=[[contentDict objectForKey:@"Properties"] objectForKey:@"Description"];
            NSDictionary *languageDict=[[[contentDict objectForKey:@"Relationships"] objectForKey:@"Language"]objectForKey:@"Properties"];
            NSString *iSOName=[languageDict  objectForKey:@"ISOName"];
            NSString *languageName=[languageDict  objectForKey:@"Name"];
            NSDictionary *disclaimerDict=[NSDictionary dictionaryWithObjectsAndKeys:identity,@"identity",disclaimerTypeName,@"disclaimerTypeName",disclaimerTitle,@"disclaimerTitle",disclaimerDescription,@"disclaimerDescription",iSOName,@"isoName",languageName,@"languageName", nil];
            [myDB insertIntoTable:disclaimersTable data:disclaimerDict intoDatabase:@""];
        }
    
    
    
  	
	
	
}

/*
 * This method extracts User projects and clients from api response and save to DB.
 */

+(void)addNoneClientToDB:(BOOL)_expensesPermission withBool:(BOOL)_timentryPermission{
    //DE10732//Juhi
    G2ExpensesModel *expensesModel=[[G2ExpensesModel alloc]init];
    NSArray *clientsArray=[expensesModel getExpenseClientsFromDatabase];
    NSString *clientId=[[clientsArray objectAtIndex:0] objectForKey:@"identity"];
   
    
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
	[dataDictionary setObject:NO_CLIENT_ID forKey:@"identity"];
	[dataDictionary setObject:RPLocalizedString(NONE_STRING, NONE_STRING)  forKey:@"name"];
    NSNumber *expensesAllowed =nil;
     NSNumber *timeentryAllowed =nil;
	if (_expensesPermission) {
		expensesAllowed = [NSNumber numberWithInt:1];
	}else {
		expensesAllowed = [NSNumber numberWithInt:0];
	}
    if (_timentryPermission) {
		timeentryAllowed = [NSNumber numberWithInt:1];
	}else {
		timeentryAllowed = [NSNumber numberWithInt:0];
	}
	[dataDictionary setObject:expensesAllowed forKey:@"expensesAllowed"];
    [dataDictionary setObject:timeentryAllowed forKey:@"timeEntryAllowed"];
    
	//DE10732//Juhi
    if ([clientId isEqualToString:NO_CLIENT_ID]) {
        NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",clientId];
        [myDB updateTable:clientsTable data:dataDictionary where:whereString intoDatabase:@""];
	}
	else{
        G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
        NSString *whereString=[NSString stringWithFormat:@"identity = '%@' and name = 'None' ",NO_CLIENT_ID];
        NSArray *noneClientsArr=[myDB select:@"*" from:clientsTable where:whereString intoDatabase:@""];
        if (noneClientsArr==nil || [noneClientsArr count]==0) {
             [myDB insertIntoTable:clientsTable data:dataDictionary intoDatabase:@""];
        }
       
    }
}

+(void)addNoneProjectToDB:(BOOL)_expensesPermission timeEntryAllowed:(BOOL)_timeAllowed{
    //DE10732//Juhi
    G2ExpensesModel *expensesModel=[[G2ExpensesModel alloc]init];
    NSMutableArray *projectsArray=[expensesModel getExpenseProjectsFromDatabase];
    NSString *projectId=[[projectsArray objectAtIndex:0] objectForKey:@"identity"];
    NSString *clientId=[[projectsArray objectAtIndex:0] objectForKey:@"clientIdentity"];
    
    
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
	[dataDictionary setObject:NO_CLIENT_ID forKey:@"identity"];
	[dataDictionary setObject:RPLocalizedString(NONE_STRING, NONE_STRING) forKey:@"name"];
	if (_timeAllowed) {
		[dataDictionary setObject:[NSNumber numberWithInt:1] forKey:@"timeEntryAllowed"];
	}
	else {
		[dataDictionary setObject:[NSNumber numberWithInt:0] forKey:@"timeEntryAllowed"];
	}

	[dataDictionary setObject:NO_CLIENT_ID forKey:@"clientIdentity"];
	NSNumber *expensesAllowed =nil;
	if (_expensesPermission) {
		expensesAllowed = [NSNumber numberWithInt:1];
	}else {
		expensesAllowed = [NSNumber numberWithInt:0];
	}
	[dataDictionary setObject:[NSNumber numberWithInt:0] forKey:@"hasTasks"];
	[dataDictionary setObject:TASK_NON_BILLABLE forKey:@"billingStatus"];
	[dataDictionary setObject:NONE_STRING forKey:@"allocationMethodId"];
	[dataDictionary setObject:expensesAllowed forKey:@"expensesAllowed"];
    [dataDictionary setObject:[NSNumber numberWithInt:0] forKey:@"closedStatus"];
    
	//DE10732//Juhi
    if ([projectId isEqualToString:NO_CLIENT_ID]) {
        NSString *whereString=[NSString stringWithFormat:@"identity = '%@' and clientIdentity = '%@' ",projectId,clientId];
        
        [myDB updateTable:projectsTable data:dataDictionary where:whereString intoDatabase:@""];
	}
	else{
        
        NSString *whereString=[NSString stringWithFormat:@"identity = '%@' and name = 'None' ",NO_CLIENT_ID];
        NSArray *noneProjectsArr=[myDB select:@"*" from:projectsTable where:whereString intoDatabase:@""];
        if (noneProjectsArr==nil || [noneProjectsArr count]==0) {
             [myDB insertIntoTable:projectsTable data:dataDictionary intoDatabase:@""];
        }
    
    }
}

+(void)deleteAddNoneProjectAndClient {
    //DE10732//Juhi
//	SQLiteDB *myDB = [SQLiteDB getInstance];
//	
//	//delete all projects before updating with new values.
//	[myDB deleteFromTable:projectsTable inDatabase:@""];
//	[myDB deleteFromTable:clientsTable inDatabase:@""];
	
	
	NSString *expensePermissionType   =   [[NSUserDefaults standardUserDefaults] objectForKey:@"expensePermissionFlag"];
	NSString *timeSheetPermissionType =   [[NSUserDefaults standardUserDefaults] objectForKey:@"TimeSheetProjectPermissionType"];
	
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *whereString=[NSString stringWithFormat:@"identity = '%@' and name = 'None' ",NO_CLIENT_ID];
    NSArray *noneClientsArr=[myDB select:@"*" from:clientsTable where:whereString intoDatabase:@""];
    if (noneClientsArr==nil || [noneClientsArr count]==0) {
        [self addNoneClientToDB:YES withBool:YES];
    }
    
	
	
	if ([expensePermissionType isEqualToString:BOTH] || [timeSheetPermissionType isEqualToString:BOTH]) {
		BOOL bothType = NO;
		BOOL _timeAllowed = YES;
		if (![timeSheetPermissionType isEqualToString:BOTH]) {
			_timeAllowed = NO;
		}
		if ([expensePermissionType isEqualToString:BOTH]) {
			bothType = YES;
		}
		[self addNoneProjectToDB:bothType timeEntryAllowed:_timeAllowed];
	}
}

-(void)saveUserProjectsAndClientsFromApiToDB :(NSArray *)userProjectsArray {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	
	if ([[self getProjectBillingOptionsFromDatabase]count]>0) {
		[myDB deleteFromTable:billingOptionsTable inDatabase:@""];
	}
	
	if (userProjectsArray != nil && [userProjectsArray count] > 0) {
		
		for (NSDictionary *projectDict in userProjectsArray) {
						
			NSString *projectIdentity        = [projectDict objectForKey:@"Identity"];
			NSDictionary *propertiesDict     = [projectDict objectForKey:@"Properties"];
			NSDictionary *relationCountDict  = [projectDict objectForKey:@"RelationshipCount"]; 
			NSString *projectName            = [propertiesDict objectForKey:@"Name"];
			NSString *projectCode            = [propertiesDict objectForKey:@"ProjectCode"];
			NSNumber *closedStatus           = [propertiesDict objectForKey:@"ClosedStatus"];
			//NSNumber *timeEntryAllowed       = [propertiesDict objectForKey:@"TimeEntryAllowed"];
			NSNumber *timeEntryAllowed       = [NSNumber numberWithBool:YES];
			NSString *clientIdentity         =  nil;
			NSDictionary *projectClientArray = [[projectDict objectForKey:@"Relationships"] objectForKey:@"ProjectClients"];
			NSDictionary *billableDict		 = [[projectDict objectForKey:@"Relationships"] objectForKey:@"Billable"];
			NSDictionary *rootTaskDict		 = [[projectDict objectForKey:@"Relationships"] objectForKey:@"RootTask"];
			NSDictionary *clientAllocationDict = [[projectDict objectForKey:@"Relationships"] 
												  objectForKey:@"ClientBillingAllocationMethod"];
			
			if (projectClientArray != nil && [projectClientArray count] > 0) {
				
				for (NSDictionary *projectclientDict in projectClientArray) {
					NSMutableDictionary *projectDataDict = [NSMutableDictionary dictionary];
					NSDictionary *clientDict = [[projectclientDict objectForKey:@"Relationships"] objectForKey:@"Client"];
					
					[projectDataDict setObject: projectIdentity forKey:@"identity"];
					[projectDataDict setObject:projectName forKey:@"name"];
					[projectDataDict setObject:closedStatus forKey:@"closedStatus"];
					[projectDataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
					
					clientIdentity = [clientDict objectForKey:@"Identity"];
					if (clientIdentity != nil && ![clientIdentity isKindOfClass:[NSNull class]]) {
						[projectDataDict setObject:clientIdentity forKey:@"clientIdentity"];
					}

					if (projectCode != nil && ![projectCode isKindOfClass:[NSNull class]]
						 && ![projectCode isEqualToString:NULL_STRING]) {
						[projectDataDict setObject:projectCode forKey:@"code"];
					}
					
					if (relationCountDict != nil && ![relationCountDict isKindOfClass:[NSNull class]]) {
						NSNumber *tasksCount = [relationCountDict objectForKey:@"Tasks"];
						if (tasksCount != nil && [tasksCount isKindOfClass:[NSNumber class]]
							&&[tasksCount intValue] > 0) {
							[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
						}
						else {
							[projectDataDict setObject:[NSNumber numberWithInt:0] forKey:@"hasTasks"];
						}

					}
					else {
						[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
					}

					
					if (billableDict != nil && [billableDict isKindOfClass:[NSDictionary class]]) {
						NSString *billingType = [billableDict objectForKey:@"Identity"];
						[projectDataDict setObject:billingType forKey:@"billingStatus"];
					}
					
					if (rootTaskDict != nil && [rootTaskDict isKindOfClass:[NSDictionary class]]) {
						NSString *rootTask = [rootTaskDict objectForKey:@"Identity"];
						[projectDataDict setObject:rootTask forKey:@"rootTaskIdentity"];
					}
					
					if (clientAllocationDict != nil && [clientAllocationDict isKindOfClass:[NSDictionary class]]) {
						NSString *allocationIdentity = [clientAllocationDict objectForKey:@"Identity"];
						[projectDataDict setObject:allocationIdentity forKey:@"allocationMethodId"];
					}
					NSString *querStr=[NSString stringWithFormat:@"select * from projects where identity = '%@' and clientIdentity = '%@' ",
									   projectIdentity,clientIdentity];
					//projArray=[myDB executeQuery:querStr];
					NSMutableArray *projArray=[myDB executeQueryToConvertUnicodeValues:querStr];
					if (projArray != nil && [projArray count] > 0) {
						NSString *whereString = [NSString stringWithFormat:@"identity = '%@' and clientIdentity ='%@'",
												 projectIdentity,clientIdentity];
						[myDB updateTable:projectsTable data:projectDataDict where:whereString intoDatabase:@""];
					}
					else {
						[myDB insertIntoTable:projectsTable data:projectDataDict intoDatabase:@""];
					}					
					
					[self insertClientFromApiToDB:clientDict];		   
				}
			}

			else {
				NSMutableDictionary *projectDataDict = [NSMutableDictionary dictionary];
				
				[projectDataDict setObject:projectIdentity forKey:@"identity"];
				[projectDataDict setObject:projectName forKey:@"name"];
				[projectDataDict setObject:closedStatus forKey:@"closedStatus"];
				[projectDataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
				
				if (projectCode != nil && ![projectCode isKindOfClass:[NSNull class]]
					&& ![projectCode isEqualToString:NULL_STRING]) {
					[projectDataDict setObject:projectCode forKey:@"code"];
				}
				clientIdentity=@"null";
				[projectDataDict setObject:clientIdentity forKey:@"clientIdentity"];
				
				
				if (relationCountDict != nil && ![relationCountDict isKindOfClass:[NSNull class]]) {
					NSNumber *tasksCount = [relationCountDict objectForKey:@"Tasks"];
					if (tasksCount != nil && [tasksCount isKindOfClass:[NSNumber class]]
						&&[tasksCount intValue] > 0) {
						[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
					}
					else {
						[projectDataDict setObject:[NSNumber numberWithInt:0] forKey:@"hasTasks"];
					}
					
				}
				else {
					[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
				}
				
				if (billableDict != nil && [billableDict isKindOfClass:[NSDictionary class]]) {
					NSString *billingType = [billableDict objectForKey:@"Identity"];
					[projectDataDict setObject:billingType forKey:@"billingStatus"];
				}
				
				if (rootTaskDict != nil && [rootTaskDict isKindOfClass:[NSDictionary class]]) {
					NSString *rootTask = [rootTaskDict objectForKey:@"Identity"];
					[projectDataDict setObject:rootTask forKey:@"rootTaskIdentity"];
				}
				
				if (clientAllocationDict != nil && [clientAllocationDict isKindOfClass:[NSDictionary class]]) {
					NSString *allocationIdentity = [clientAllocationDict objectForKey:@"Identity"];
					[projectDataDict setObject:allocationIdentity forKey:@"allocationMethodId"];
				}
				
				NSString *querStr=[NSString stringWithFormat:@"select * from projects where identity = '%@' and clientIdentity = '%@' ",
								   projectIdentity,clientIdentity];
				//projArray=[myDB executeQuery:querStr];
				NSMutableArray *projArray=[myDB executeQueryToConvertUnicodeValues:querStr];
				if (projArray != nil && [projArray count] > 0) {
					NSString *whereString = [NSString stringWithFormat:@"identity = '%@' and clientIdentity ='%@'",
											 projectIdentity,clientIdentity];
					[myDB updateTable:projectsTable data:projectDataDict where:whereString intoDatabase:@""];
				}
				else {
					[myDB insertIntoTable:projectsTable data:projectDataDict intoDatabase:@""];
				}
			}

		}
	}
}

-(void)insertProjectsFromApiToDB:(NSArray *)userProjectsArray forRecent:(BOOL)isRecent
{
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    if (userProjectsArray != nil && [userProjectsArray count] > 0) {
		
		for (NSDictionary *projectDict in userProjectsArray) {
            
			NSString *projectIdentity        = [projectDict objectForKey:@"Identity"];
			NSDictionary *propertiesDict     = [projectDict objectForKey:@"Properties"];
			NSDictionary *relationCountDict  = [projectDict objectForKey:@"RelationshipCount"];
			NSString *projectName            = [propertiesDict objectForKey:@"Name"];
			NSString *projectCode            = [propertiesDict objectForKey:@"ProjectCode"];
			NSNumber *closedStatus           = [propertiesDict objectForKey:@"ClosedStatus"];
			//NSNumber *timeEntryAllowed       = [propertiesDict objectForKey:@"TimeEntryAllowed"];
			NSNumber *timeEntryAllowed       = [NSNumber numberWithBool:YES];
			NSString *clientIdentity         =  nil;
			NSDictionary *projectClientArray = [[projectDict objectForKey:@"Relationships"] objectForKey:@"ProjectClients"];
			NSDictionary *billableDict		 = [[projectDict objectForKey:@"Relationships"] objectForKey:@"Billable"];
			NSDictionary *rootTaskDict		 = [[projectDict objectForKey:@"Relationships"] objectForKey:@"RootTask"];
			NSDictionary *clientAllocationDict = [[projectDict objectForKey:@"Relationships"]
												  objectForKey:@"ClientBillingAllocationMethod"];
			
			if (projectClientArray != nil && [projectClientArray count] > 0) {
				
				for (NSDictionary *projectclientDict in projectClientArray) {
					NSMutableDictionary *projectDataDict = [NSMutableDictionary dictionary];
					NSDictionary *clientDict = [[projectclientDict objectForKey:@"Relationships"] objectForKey:@"Client"];
					
					[projectDataDict setObject: projectIdentity forKey:@"identity"];
					[projectDataDict setObject:projectName forKey:@"name"];
					[projectDataDict setObject:closedStatus forKey:@"closedStatus"];
					[projectDataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
					
					clientIdentity = [clientDict objectForKey:@"Identity"];
					if (clientIdentity != nil && ![clientIdentity isKindOfClass:[NSNull class]]) {
						[projectDataDict setObject:clientIdentity forKey:@"clientIdentity"];
					}
                    
					if (projectCode != nil && ![projectCode isKindOfClass:[NSNull class]]
                        && ![projectCode isEqualToString:NULL_STRING]) {
						[projectDataDict setObject:projectCode forKey:@"code"];
					}
					
					if (relationCountDict != nil && ![relationCountDict isKindOfClass:[NSNull class]]) {
						NSNumber *tasksCount = [relationCountDict objectForKey:@"Tasks"];
						if (tasksCount != nil && [tasksCount isKindOfClass:[NSNumber class]]
							&&[tasksCount intValue] > 0) {
							[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
						}
						else {
							[projectDataDict setObject:[NSNumber numberWithInt:0] forKey:@"hasTasks"];
						}
                        
					}
					else {
						[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
					}
                    
					
					if (billableDict != nil && [billableDict isKindOfClass:[NSDictionary class]]) {
						NSString *billingType = [billableDict objectForKey:@"Identity"];
						[projectDataDict setObject:billingType forKey:@"billingStatus"];
					}
					
					if (rootTaskDict != nil && [rootTaskDict isKindOfClass:[NSDictionary class]]) {
						NSString *rootTask = [rootTaskDict objectForKey:@"Identity"];
						[projectDataDict setObject:rootTask forKey:@"rootTaskIdentity"];
					}
					
					if (clientAllocationDict != nil && [clientAllocationDict isKindOfClass:[NSDictionary class]]) {
						NSString *allocationIdentity = [clientAllocationDict objectForKey:@"Identity"];
						[projectDataDict setObject:allocationIdentity forKey:@"allocationMethodId"];
					}
                    
                    if (isRecent)
                    {
                        [projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"isTimesheetsRecent"];
                    }
                    
                    
					NSString *querStr=[NSString stringWithFormat:@"select * from projects where identity = '%@' and clientIdentity = '%@' ",
									   projectIdentity,clientIdentity];
					//projArray=[myDB executeQuery:querStr];
					NSMutableArray *projArray=[myDB executeQueryToConvertUnicodeValues:querStr];
					if (projArray != nil && [projArray count] > 0) {
						NSString *whereString = [NSString stringWithFormat:@"identity = '%@' and clientIdentity ='%@'",
												 projectIdentity,clientIdentity];
						[myDB updateTable:projectsTable data:projectDataDict where:whereString intoDatabase:@""];
					}
					else {
						[myDB insertIntoTable:projectsTable data:projectDataDict intoDatabase:@""];
					}
					
					
				}
			}
            
			else {
				NSMutableDictionary *projectDataDict = [NSMutableDictionary dictionary];
				
				[projectDataDict setObject:projectIdentity forKey:@"identity"];
				[projectDataDict setObject:projectName forKey:@"name"];
				[projectDataDict setObject:closedStatus forKey:@"closedStatus"];
				[projectDataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
				
				if (projectCode != nil && ![projectCode isKindOfClass:[NSNull class]]
					&& ![projectCode isEqualToString:NULL_STRING]) {
					[projectDataDict setObject:projectCode forKey:@"code"];
				}
				clientIdentity=@"null";
				[projectDataDict setObject:clientIdentity forKey:@"clientIdentity"];
				
				
				if (relationCountDict != nil && ![relationCountDict isKindOfClass:[NSNull class]]) {
					NSNumber *tasksCount = [relationCountDict objectForKey:@"Tasks"];
					if (tasksCount != nil && [tasksCount isKindOfClass:[NSNumber class]]
						&&[tasksCount intValue] > 0) {
						[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
					}
					else {
						[projectDataDict setObject:[NSNumber numberWithInt:0] forKey:@"hasTasks"];
					}
					
				}
				else {
					[projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"hasTasks"];
				}
				
				if (billableDict != nil && [billableDict isKindOfClass:[NSDictionary class]]) {
					NSString *billingType = [billableDict objectForKey:@"Identity"];
					[projectDataDict setObject:billingType forKey:@"billingStatus"];
				}
				
				if (rootTaskDict != nil && [rootTaskDict isKindOfClass:[NSDictionary class]]) {
					NSString *rootTask = [rootTaskDict objectForKey:@"Identity"];
					[projectDataDict setObject:rootTask forKey:@"rootTaskIdentity"];
				}
				
				if (clientAllocationDict != nil && [clientAllocationDict isKindOfClass:[NSDictionary class]]) {
					NSString *allocationIdentity = [clientAllocationDict objectForKey:@"Identity"];
					[projectDataDict setObject:allocationIdentity forKey:@"allocationMethodId"];
				}
                
                
                if (isRecent)
                {
                    [projectDataDict setObject:[NSNumber numberWithInt:1] forKey:@"isTimesheetsRecent"];
                }

				
				NSString *querStr=[NSString stringWithFormat:@"select * from projects where identity = '%@' and clientIdentity = '%@' ",
								   projectIdentity,clientIdentity];
				//projArray=[myDB executeQuery:querStr];
				NSMutableArray *projArray=[myDB executeQueryToConvertUnicodeValues:querStr];
				if (projArray != nil && [projArray count] > 0) {
					NSString *whereString = [NSString stringWithFormat:@"identity = '%@' and clientIdentity ='%@'",
											 projectIdentity,clientIdentity];
					[myDB updateTable:projectsTable data:projectDataDict where:whereString intoDatabase:@""];
				}
				else {
					[myDB insertIntoTable:projectsTable data:projectDataDict intoDatabase:@""];
				}
			}
            
		}
	}
}

-(void)insertClientFromApiToDB:(NSDictionary *)clientDict {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
	
	NSString *identity = [clientDict objectForKey:@"Identity"];
	NSString *name = [[clientDict objectForKey:@"Properties"] objectForKey:@"Name"];
	
	[dataDict setObject:identity forKey:@"identity"];
	[dataDict setObject:name forKey:@"name"];
    [dataDict setObject:[NSNumber numberWithInt:1] forKey:@"timeEntryAllowed"];
	
	BOOL clientExists = [self checkClientExistsInDBWithIdentity: identity];
	if (clientExists) {
		NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",identity];
		[myDB updateTable:clientsTable data:dataDict where:whereString intoDatabase:@""];
	}
	else {
		[myDB insertIntoTable:clientsTable data:dataDict intoDatabase:@""];
	}

}

-(BOOL)checkClientExistsInDBWithIdentity: identity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",identity];
	NSMutableArray *clientArray = [myDB select:@"*" from:clientsTable where:whereString intoDatabase:@""];
	if (clientArray != nil && [clientArray count] > 0)  {
		return YES;
	}
	
	return NO;
}
										
/**
 *Module:TimeSheet
 *Date:May 15th
 **/
-(BOOL)checkforUserPreferenceWithPreferenceName:(NSString*)preferenceName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *preferenceArr = [myDB select:@"*" from:tableName8 where:[NSString stringWithFormat:@"name='%@'",preferenceName] intoDatabase:@""];
	
	if ([preferenceArr count]!=0) {
		if([[[preferenceArr objectAtIndex:0] objectForKey:@"status"] isEqualToString:@"1"]){
			return YES;
		}
	}
	return NO;
}//method : not required

-(NSMutableArray *)getAllUserPreferences{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *selectString = @"name";
	NSMutableArray *preferencesArr = [myDB select:selectString from:tableName8 where:@"status=1" intoDatabase:@""];
	if (preferencesArr != nil && [preferencesArr count]>0) {
		NSMutableArray *preferenceList = [NSMutableArray array];
		for (NSDictionary *preferenceDict in preferencesArr ) {
			[preferenceList addObject:[preferenceDict objectForKey:selectString]];
		}
		return preferenceList;
	}
	
	return nil;
}

-(NSString *)getUserTimeFormat{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *timeformat = [myDB select:@"preferenceValue" from:userPreferencesTable where:@" preferenceName='Timesheet.TimeFormat'" intoDatabase:@""];
	if ([timeformat count] != 0) {
		return [[timeformat objectAtIndex:0] objectForKey:@"preferenceValue"];
	}
	return nil;
}
-(NSString *)getUserHourFormat{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *timeformat = [myDB select:@"preferenceValue" from:userPreferencesTable where:@" preferenceName='Timesheet.HourFormat'" intoDatabase:@""];
	if ([timeformat count] != 0) {
		return [[timeformat objectAtIndex:0] objectForKey:@"preferenceValue"];
	}
	return nil;
}
-(NSMutableArray *)getUserTimeSheetFormats{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *formatsArray = [myDB select:@"*" from:userPreferencesTable where:@"" intoDatabase:@""];
	if (formatsArray != nil && [formatsArray count]> 0) {
		return formatsArray;
	}
	return nil;
}
/**
 *Module:TimeSheet
 *Date:May 25th
 **/
-(void)saveProjectBillingOptionsFromApiToDB:(NSDictionary *)userBillingOptionsDict :(NSString *)projectIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSDictionary *propertiesDict;
	NSString *billingType = @"";
	NSString *projectId = nil;
	NSString *projectRoleName = @"";
	NSNumber *projectRoleId = nil;
	NSNumber *departmentId = nil;
	if (userBillingOptionsDict != nil) {
			propertiesDict			= [userBillingOptionsDict objectForKey:@"Properties"];
			billingType				= [propertiesDict objectForKey:@"BillingType"];
		//	projectId				= [propertiesDict objectForKey:@"ProjectId"];		//fixed memory leak
			projectRoleName			= [propertiesDict objectForKey:@"ProjectRoleName"];
			projectRoleId			= [propertiesDict objectForKey:@"ProjectRoleId"];
			departmentId			= [propertiesDict objectForKey:@"DepartmentId"];
			if ([projectIdentity isKindOfClass:[NSNull class]]) {
				projectId = @"";
			}
			else {
				projectId = projectIdentity;
			}

		if ([billingType isEqualToString: @"NonBillable"]) {
			return;
		} else if([billingType isEqualToString: @"ProjectRate"]) {
			projectRoleName = @"Project Rate";
		} else if([billingType isEqualToString: @"UserOverrideRate"])	{
			projectRoleName = @"User Rate";
		} else if ([billingType isEqualToString: @"RoleRate"] && [projectRoleName isKindOfClass:[NSNull class]]) {
			projectRoleName = billingType;
		} else if ([billingType isEqualToString: @"DepartmentOverrideRate"]) {
			projectRoleName = [propertiesDict objectForKey: @"DepartmentName"];
		}
		
			NSMutableDictionary *billingOptionsDict = [NSMutableDictionary dictionary];
				
				[billingOptionsDict setObject:billingType			forKey:@"billingType"];
				[billingOptionsDict setObject:projectId				forKey:@"projectId"];
				[billingOptionsDict setObject:projectRoleName		forKey:@"projectRoleName"];
			
			if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]]
					&& [projectRoleId isKindOfClass:[NSNumber class]]) {
					[billingOptionsDict setObject:projectRoleId forKey:@"projectRoleId"];
			}
			if (departmentId != nil && ![departmentId isKindOfClass:[NSNull class]]
				&& [departmentId isKindOfClass:[NSNumber class]]) {
				[billingOptionsDict setObject:departmentId forKey:@"projectRoleId"];
			}
			
        NSString *whereString=@"";
        
            whereString = [NSString stringWithFormat: @"projectRoleName='%@' and billingType='%@' and projectId='%@'", [billingOptionsDict objectForKey:@"projectRoleName"],[billingOptionsDict objectForKey:@"billingType"],[billingOptionsDict objectForKey:@"projectId"]];
        
        
        NSMutableArray *billingOptionsArr = [myDB select:@"*" from:billingOptionsTable where: whereString intoDatabase:@""];
        
        if (billingOptionsArr==nil || [billingOptionsArr count]==0)
        {
            [myDB insertIntoTable:billingOptionsTable data:billingOptionsDict intoDatabase:@""];
        }
        
				
		}
}

+(NSString *) getBillingTypeByProjRoleName: (NSString *)projRoleName
{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	
	NSString *whereString=@"";
	if (projRoleName != nil) {
		whereString = [NSString stringWithFormat: @"projectRoleName='%@'", [projRoleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"   ]];
	}

	NSMutableArray *billingOptionsArr = [myDB select:@"*" from:billingOptionsTable where: whereString intoDatabase:@""];
    

    
	if (billingOptionsArr != nil && [billingOptionsArr count]!=0) {
		//ravi - Looking into the db, there are multiple entries for the same name (why?). All the values are same, so returning the first value in the list.
		return [[billingOptionsArr objectAtIndex: 0] objectForKey: @"billingType"];
	}
	return nil;	
}

-(void)saveUserActivitiesFromApiToDB:(NSArray *)activityArray{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if ([[self getUserActivitiesFromDatabase]count]>0) {
		[myDB deleteFromTable:activitiesTable inDatabase:@""];
	}
    G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
	BOOL isTimesheetActivityRequired = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
    if (!isTimesheetActivityRequired) {
        NSDictionary *defaultNoneDict=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"identity",RPLocalizedString(NONE_STRING, @""),@"name",[NSNumber numberWithBool:TRUE],@"enabled",@"",@"code", nil];
        [myDB insertIntoTable:activitiesTable data:defaultNoneDict intoDatabase:@""];
    }
   
	NSString *activityIdentity = @"";
	NSDictionary *propertiesDict;
	NSString *activityName = @"";
	NSNumber *enabled = nil;	//[NSNumber numberWithInt:0];	//fixed memory leak
	NSString *code = @"";
	
	if (activityArray != nil && [activityArray count]>0) {
		for (NSDictionary *activityDict in activityArray) {
			
			activityIdentity	= [activityDict objectForKey:@"Identity"];
			propertiesDict		= [activityDict objectForKey:@"Properties"];
			activityName		= [propertiesDict objectForKey:@"Name"];
			enabled				= [propertiesDict objectForKey:@"Enabled"];
			code				= [propertiesDict objectForKey:@"Code"];
			
			NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
			
			[activityDict setObject:activityIdentity	forKey:@"identity"];
			[activityDict setObject:activityName		forKey:@"name"];
			[activityDict setObject:enabled				forKey:@"enabled"];
			[activityDict setObject:code				forKey:@"code"];
			
			[myDB insertIntoTable:activitiesTable data:activityDict intoDatabase:@""];
		}
	}
}
-(void)saveTimeOffCodesFromApiToDB:(NSArray *)timeOffCodesArray{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	 
	 if ([[self getTimeOffCodesFromDatabase]count]>0) {
	 [myDB deleteFromTable:timeOffCodesTable inDatabase:@""];
	 }
	NSString		*timeOffIdentity = @"";
	NSString		*timeOffname = @"";
	NSNumber		*disabled			= nil;	//[NSNumber numberWithInt:0];	//fixed memory leak
	NSNumber		*systemRequired		= nil;	//[NSNumber numberWithInt:0];	//fixed memory leak
	NSNumber		*bankingOptional	= nil;	//[NSNumber numberWithInt:0];	//fixed memory leak	
	NSNumber		*displayOnCalendar	= nil;	//[NSNumber numberWithInt:0];	//fixed memory leak
	
	NSDictionary	*propertiesDict;
	
	if (timeOffCodesArray != nil && [timeOffCodesArray count]>0) {
		for (NSDictionary *timeOffDict in timeOffCodesArray) {
			
			timeOffIdentity		= [timeOffDict objectForKey:@"Identity"];
			propertiesDict		= [timeOffDict objectForKey:@"Properties"];
			timeOffname			= [propertiesDict objectForKey:@"Name"];
			disabled			= [propertiesDict objectForKey:@"Disabled"];
			systemRequired		= [propertiesDict objectForKey:@"SystemRequired"];
			bankingOptional		= [propertiesDict objectForKey:@"BookingOptional"];
			displayOnCalendar	= [propertiesDict objectForKey:@"DisplayOnCalendar"];
			
			NSMutableDictionary *timeOffCodesDict = [NSMutableDictionary dictionary];
			
			[timeOffCodesDict setObject:timeOffIdentity		forKey:@"identity"];
			[timeOffCodesDict setObject:timeOffname			forKey:@"name"];
			[timeOffCodesDict setObject:systemRequired		forKey:@"systemRequired"];
			[timeOffCodesDict setObject:disabled			forKey:@"disabled"];
			[timeOffCodesDict setObject:bankingOptional		forKey:@"bookingOptional"];
			[timeOffCodesDict setObject:displayOnCalendar	forKey:@"displayOnCalendar"];
			
			[myDB insertIntoTable:timeOffCodesTable data:timeOffCodesDict intoDatabase:@""];
		}
	}
}
-(NSMutableArray *)getUserActivitiesFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *activitiesArr = [myDB select:@"*" from:activitiesTable where:@"enabled=1" usingSort:@"order by name"  intoDatabase:@""];
	
	if (activitiesArr != nil && [activitiesArr count]!=0) {
        for (int i=0; i<[activitiesArr count]; i++) {
            NSDictionary *activityDict=[activitiesArr objectAtIndex:i];
            if ([[activityDict objectForKey:@"name"] isEqualToString:RPLocalizedString(@"None", @"")] && [[activityDict objectForKey:@"identity"]isEqualToString:@""] && [[activityDict objectForKey:@"id"]intValue]==1  ) {
                [activitiesArr removeObjectAtIndex:i];
                NSDictionary *defaultNoneDict=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"identity",RPLocalizedString(@"None", @""),@"name",[NSNumber numberWithBool:TRUE],@"enabled",@"",@"code", nil];
                [activitiesArr insertObject:defaultNoneDict  atIndex:0];
                break;
            }
        }
		return activitiesArr;
	}
	return nil;
}
-(NSMutableArray *)getProjectBillingOptionsFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *billingOptionsArr = [myDB select:@"*" from:billingOptionsTable where:@"" intoDatabase:@""];
	
	if (billingOptionsArr != nil && [billingOptionsArr count]!=0) {
		return billingOptionsArr;
	}
	return nil;
}
-(NSMutableArray *)getTimeOffCodesFromDatabase{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	NSMutableArray *timeOffCodesArr = [myDB select:@"*" from:timeOffCodesTable where:@"" intoDatabase:@""];
	
	if (timeOffCodesArr != nil && [timeOffCodesArr count]!=0) {
		return timeOffCodesArr;
	}
	return nil;
}

-(NSMutableArray *)getValidTimeOffCodesFromDatabaseForTimeOff
{
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
    NSString *whereStr=@" disabled=0 and bookingOptional=1 order by name asc";
	NSMutableArray *timeOffCodesArr = [myDB select:@"*" from:timeOffCodesTable where:whereStr intoDatabase:@""];
	
	if (timeOffCodesArr != nil && [timeOffCodesArr count]!=0) {
		return timeOffCodesArr;
	}
	return nil;
}

-(void)saveTimesheetUDFSettingsFromApiToDB:(NSArray *)responseArray {
	G2SQLiteDB *myDB  = [G2SQLiteDB getInstance];
	
	//delete user defined fields for Timesheets
	NSString *deleteWhereString = [NSString stringWithFormat:@"moduleName = '%@' or moduleName = '%@' or moduleName = '%@'"
								   ,TIMESHEET_SHEET_LEVEL_UDF_KEY,
								   TIMESHEET_ROW_LEVEL_UDF_KEY,
								   TIMESHEET_CELL_LEVEL_UDF_KEY
								   ];
	[myDB deleteFromTable:tableName11 where:deleteWhereString inDatabase:@""];
	
	NSString *name = @"";
	NSString *textDefaultVal= @"";
	NSString *dateDefaultVal = @"";
	NSString *dateMinVal = @"";
	NSString *dateMaxVal = @"";
	NSNumber *dateDefaultValIsToday= nil;	//[NSNumber numberWithInt:0];	//fixed memory leak
	NSNumber *textMaxVal;
	NSNumber *numericDefaultVal;
	NSNumber *numericMinVal;
	NSNumber *numericMaxVal;
	NSNumber *numericDecimalPlaces=0;
	NSString *identity;
	NSString *udfType;
	NSString *moduleName = TIMESHEET_SHEET_LEVEL_UDF_KEY;
	////	TextMaximumLength
	
	NSMutableDictionary *infoDict=[NSMutableDictionary dictionary];
	
	for (int i=0; i<[responseArray count]; i++) {
		
		
		NSArray *fieldsArray = [[[responseArray objectAtIndex:i]objectForKey:@"Relationships"]objectForKey:@"Fields"];
		
		for (int j=0 ; j<[fieldsArray count]; j++) {
			
			int enabled=0,required=0,hidden=0;
			
			identity = [[fieldsArray objectAtIndex:j] objectForKey:@"Identity"];
			
			
			udfType = [[[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"]
						objectForKey:@"Type"]objectForKey:@"Identity" ];
			
			[infoDict setObject:udfType forKey:@"udfType"];
			[infoDict setObject:moduleName forKey:@"moduleName"];
			NSDictionary *propertiesDict = [[fieldsArray objectAtIndex:j]objectForKey:@"Properties"];
			
			if ([[propertiesDict objectForKey:@"Enabled"] boolValue] == YES){
				enabled = 1;
			}
			
			if ([[propertiesDict objectForKey:@"Required"] boolValue]== YES){
				required = 1;
			}
			if ([[propertiesDict objectForKey:@"Hidden"] boolValue]== YES){
				hidden = 1;
			}
			if ([propertiesDict objectForKey:@"Name"]!= nil) {
				name = [propertiesDict objectForKey:@"Name"];
			}
			
			if ([[propertiesDict objectForKey:@"TextDefaultValue"]isKindOfClass:[NSNull class]]) {
				//textDefaultVal = @"null";
			}else {
				textDefaultVal=[propertiesDict objectForKey:@"TextDefaultValue"];
			}
			
			
			[infoDict setObject:textDefaultVal forKey:@"textDefaultValue"];
			
			if ([[propertiesDict objectForKey:@"TextMaximumLength"]isKindOfClass:[NSNull class]]) {
				//textMaxVal = [NSNumber numberWithInt:0];
			}else{
				textMaxVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"TextMaximumLength"]intValue]];
				[infoDict setObject:textMaxVal forKey:@"textMaxValue"];
			}
			
			
			if ([[propertiesDict objectForKey:@"NumericDefaultValue"]isKindOfClass:[NSNull class]]) {
				//numericDefaultVal = [NSNumber numberWithInt:0];
			}else{
				numericDefaultVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericDefaultValue"]intValue]];
				[infoDict setObject:numericDefaultVal forKey:@"numericDefaultValue"];
			}
			
			if ([[propertiesDict objectForKey:@"NumericMinimumValue"]isKindOfClass:[NSNull class]]) {
				//numericMinVal = [NSNumber numberWithInt:0];
			}else{
				numericMinVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericMinimumValue"]intValue]];
				[infoDict setObject:numericMinVal forKey:@"numericMinValue"];
			}
			
			if ([[propertiesDict objectForKey:@"NumericMaximumValue"]isKindOfClass:[NSNull class]]) {
				//numericMaxVal = [NSNumber numberWithInt:0];
			}else{
				numericMaxVal =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericMaximumValue"]intValue]];
				[infoDict setObject:numericMaxVal forKey:@"numericMaxvalue"];
			}
			if ([[propertiesDict objectForKey:@"NumericDecimalPlaces"]isKindOfClass:[NSNull class]]) {
				//numericDecimalPlaces = [NSNumber numberWithInt:0];
			}else{
				numericDecimalPlaces =[NSNumber numberWithInt:[[propertiesDict objectForKey:@"NumericDecimalPlaces"]intValue]];
				[infoDict setObject:numericDecimalPlaces forKey:@"numericDecimalPlaces"];
			}
			
			if([propertiesDict objectForKey:@"DateDefaultValue"]!= nil  && ![[propertiesDict objectForKey:@"DateDefaultValue"] isKindOfClass:[NSNull class]] ){
				id  dateDefaultDict = [propertiesDict objectForKey:@"DateDefaultValue"];
				
				if ([dateDefaultDict isKindOfClass:[NSDictionary class]]) {	
					int month = [[dateDefaultDict objectForKey:@"Month"]intValue];
					dateDefaultVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
									 [dateDefaultDict objectForKey:@"Day"],[dateDefaultDict objectForKey:@"Year"]];					 
				}
				[infoDict setObject:dateDefaultVal forKey:@"dateDefaultValue"];
			}
			
			if ([[propertiesDict objectForKey:@"DateDefaultValueIsToday"] isKindOfClass:[NSNull class]]) {
				//dateDefaultValIsToday = [NSNumber numberWithInt:0];
				
			}else {
				if ([[propertiesDict objectForKey:@"DateDefaultValueIsToday"] boolValue] == YES){
					dateDefaultValIsToday = [NSNumber numberWithInt:1];
					[infoDict setObject:dateDefaultValIsToday forKey:@"isDateDefaultValueToday"];
				}
			}
			
			if ([propertiesDict objectForKey:@"DateMinimumValue"] != nil && ![[propertiesDict objectForKey:@"DateMinimumValue"] isKindOfClass:[NSNull class]]) {
				
				id  dateMinValDict = [propertiesDict objectForKey:@"DateMinimumValue"];
				if ([dateMinValDict isKindOfClass:[NSDictionary class]]) {
					
					int month = [[dateMinValDict objectForKey:@"Month"]intValue];
					dateMinVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
								 [dateMinValDict objectForKey:@"Day"],[dateMinValDict objectForKey:@"Year"]];
					
				}
				[infoDict setObject:dateMinVal forKey:@"dateMinValue"];
			}
			
			if ([propertiesDict objectForKey:@"DateMaximumValue"] != nil && ![[propertiesDict objectForKey:@"DateMaximumValue"] isKindOfClass:[NSNull class]]) {
				id dateMaxValDict = [propertiesDict objectForKey:@"DateMaximumValue"];
				if ([dateMaxValDict isKindOfClass:[NSDictionary class]]) {
					int month = [[dateMaxValDict objectForKey:@"Month"]intValue];
					dateMaxVal =[NSString stringWithFormat:@"%@ %@, %@",[G2Util getMonthNameForMonthId:month],
								 [dateMaxValDict objectForKey:@"Day"],[dateMaxValDict objectForKey:@"Year"]];
				}
				[infoDict setObject:dateMaxVal forKey:@"dateMaxValue"];
			}
			
			[infoDict setObject:[NSNumber numberWithInt:j+1] forKey:@"id"];
			[infoDict setObject:identity forKey:@"identity"];
			[infoDict setObject:[NSNumber numberWithInt:enabled] forKey:@"enabled"];
			[infoDict setObject:[NSNumber numberWithInt:required] forKey:@"required"];
			[infoDict setObject:[NSNumber numberWithInt:hidden] forKey:@"hidden"];
			[infoDict setObject:name forKey:@"name"];
						
			[myDB insertIntoTable:tableName11 data:infoDict intoDatabase:@""];			
			
			NSArray *dropDownOptionsArray = [[[fieldsArray objectAtIndex:j] objectForKey:@"Relationships"] 
											 objectForKey:@"DropDownOptions"];
			
			if (dropDownOptionsArray != nil && [dropDownOptionsArray count] > 0) {
				[self insertTimesheetDropDownOptionsToDatabase:dropDownOptionsArray : identity];
			}
		}	
	}
}

-(void)insertTimesheetDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray : (NSString *)udfIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *deleteWhereString = [NSString stringWithFormat:@"udfIdentity = '%@'",udfIdentity];
	[myDB deleteFromTable:tableName12 where:deleteWhereString inDatabase:@""];
	
	
	for (NSDictionary *dropDownUdfDict in dropDownOptionsArray) {
	
		NSMutableDictionary *dropDownOptionsDict  = [NSMutableDictionary dictionary];
		[dropDownOptionsDict setObject:udfIdentity forKey:@"udfIdentity"];
		
		NSString *identity = [dropDownUdfDict objectForKey:@"Identity"];
		NSDictionary *propertiesDict = [dropDownUdfDict objectForKey:@"Properties"];
		NSString *udfValue = [propertiesDict objectForKey:@"Value"];
		NSNumber *enabled = [propertiesDict objectForKey:@"Enabled"];
		NSNumber *defaultOption = [propertiesDict objectForKey:@"DefaultOption"];
		
		if (udfValue != nil && ![udfValue isKindOfClass:[NSNull class]]) {
			[dropDownOptionsDict setObject:udfValue forKey:@"value"];
		}
		if (enabled != nil && [enabled isKindOfClass:[NSNull class]]) {
			[dropDownOptionsDict setObject:enabled forKey:@"enabled"];
		}else {
			[dropDownOptionsDict setObject:[NSNumber numberWithInt:0] forKey:@"enabled"];
		}
		
		if (defaultOption != nil && [defaultOption isKindOfClass:[NSNull class]]) {
			[dropDownOptionsDict setObject:defaultOption forKey:@"enabled"];
		}else {
			[dropDownOptionsDict setObject:[NSNumber numberWithInt:0] forKey:@"DefaultOption"];
		}
		[dropDownOptionsDict setObject:identity forKey:@"identity"];
		
		[myDB insertIntoTable:tableName12 data:dropDownOptionsDict intoDatabase:@""];
	}
}
/*-(NSMutableArray *) getAllUserProjects{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSMutableArray *projectslist = [myDB select:@"*" from:projectsTable where:@"" intoDatabase:@""];
	if (projectslist != nil && [projectslist count]>0) {
		return projectslist;
	}
	return nil;
}*/
-(NSUInteger)getUserProjectsCount{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *projectslist = [myDB select:@"*" from:projectsTable where:@"timeEntryAllowed = 1" intoDatabase:@""];
	if (projectslist != nil && [projectslist count]>0) {
		return [projectslist count];
	}
	return 0;
}
-(NSMutableArray *)getProjectsForClientWithClientId:(NSString *)clientIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientIdentity  = '%@'and timeEntryAllowed = 1 and closedStatus=0 order by name collate nocase",
					 projectsTable,clientIdentity];
	NSMutableArray *projectsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if (projectsArray != nil && [projectsArray count]>0) {
		
            int index = [G2Util getObjectIndex:projectsArray withKey:@"name" forValue:RPLocalizedString(NONE_STRING,@"")];
            if (index != -1) {
                NSMutableDictionary *noneProjDict = [[NSMutableDictionary alloc]initWithDictionary:[projectsArray objectAtIndex:index]];
                [projectsArray removeObjectAtIndex:index];
                [projectsArray insertObject:noneProjDict atIndex:0];
               
            }
            
            return projectsArray;
        

	}
	return nil;
}

-(NSMutableArray *)getRecentProjectsForClientWithClientId:(NSString *)clientIdentity{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where clientIdentity  = '%@'and timeEntryAllowed = 1 and closedStatus=0 and isTimesheetsRecent=1 order by name collate nocase",
					 projectsTable,clientIdentity];
	NSMutableArray *projectsArray = [myDB executeQueryToConvertUnicodeValues:sql];
	if (projectsArray != nil && [projectsArray count]>0) {
		
        int index = [G2Util getObjectIndex:projectsArray withKey:@"name" forValue:RPLocalizedString(NONE_STRING,@"")];
        if (index != -1) {
            NSMutableDictionary *noneProjDict = [[NSMutableDictionary alloc]initWithDictionary:[projectsArray objectAtIndex:index]];
            [projectsArray removeObjectAtIndex:index];
            [projectsArray insertObject:noneProjDict atIndex:0];
            
        }
        
        return projectsArray;
        
        
	}
	return nil;
}

-(NSString *)getClientIdentityForClientName:(NSString *)clientName{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	/*
	if (clientName != nil) {
		NSString *_client = [NSString stringWithUTF8String:[clientName cStringUsingEncoding:[NSString defaultCStringEncoding]]];
		clientName = _client;
	}*/
	
	NSString *whereString  = [NSString stringWithFormat:@"name = '%@'",[clientName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSString *selectString = @"identity";
	NSMutableArray *clientsArray = [myDB select:selectString from:clientsTable where:whereString intoDatabase:@""];
	if (clientsArray != nil && [clientsArray count]>0) {
		return [[clientsArray objectAtIndex:0] objectForKey:selectString];
	}
	return nil;
}
-(NSMutableArray *)getAllClientNames{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	//NSString *selectString = @"select distinct(c.name) from clients c,projects p where c.identity = p.clientIdentity and p.timeEntryAllowed = 1 order by c.id";
	NSString *selectString = @"select distinct(c.name) from clients c,projects p where c.identity = p.clientIdentity and p.timeEntryAllowed = 1 order by c.name";
	NSMutableArray *clientArr = [myDB executeQueryToConvertUnicodeValues:selectString];
	if (clientArr != nil && [clientArr count]>0) {
		NSMutableArray *clientList = [NSMutableArray array];
		for (NSDictionary *clientDict in clientArr ) {
			[clientList addObject:[clientDict objectForKey:@"name"]];
		}
		if ([clientList  containsObject:RPLocalizedString(NONE_STRING, NONE_STRING)]) {
			[clientList removeObject:RPLocalizedString(NONE_STRING, NONE_STRING)];
			[clientList insertObject:RPLocalizedString(NONE_STRING, NONE_STRING) atIndex:0];
		}
		return clientList;
	}
	return nil;
}

-(NSMutableArray *)getAllClientsForTimesheets{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *selectString = @"select * from clients  where timeEntryAllowed = 1 order by name";
	NSMutableArray *clientArr = [myDB executeQueryToConvertUnicodeValues:selectString];
	if (clientArr != nil && [clientArr count]>0) {
		
        int index = [G2Util getObjectIndex:clientArr withKey:@"name" forValue:RPLocalizedString(NONE_STRING,@"")];
        if (index != -1) {
            NSMutableDictionary *noneProjDict = [[NSMutableDictionary alloc]initWithDictionary:[clientArr objectAtIndex:index]];
            [clientArr removeObjectAtIndex:index];
            [clientArr insertObject:noneProjDict atIndex:0];
           
        }
        
        return clientArr;
        
        
	}
	return nil;
}

-(BOOL)checkProjectHasTasksForSelection:(NSString *)projectIdentity client:(NSString *)_clientIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString  = [NSString stringWithFormat:@"identity = '%@' and clientIdentity = '%@'",
							  projectIdentity, _clientIdentity];
	NSString *selectString = @"hasTasks";
	NSMutableArray *projectsArray = [myDB select:selectString from:projectsTable where:whereString intoDatabase:@""];
	if (projectsArray != nil && [projectsArray count]>0) {
        if ([[[projectsArray objectAtIndex:0] objectForKey:@"hasTasks"] isKindOfClass:[NSNull class]]) {
            return NO;
        }
		return [[[projectsArray objectAtIndex:0] objectForKey:@"hasTasks"] boolValue];
	}
	return NO;
}

-(NSString *)getProjectIdentityWithProjectName:(NSString *)selectedProjectName {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSString *whereString  = [NSString stringWithFormat:@"name = '%@'",[selectedProjectName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	NSString *selectString = @"distinct(identity)";
	NSMutableArray *projectsArray = [myDB select:selectString from:projectsTable where:whereString intoDatabase:@""];
	if (projectsArray != nil && [projectsArray count]>0) {
		return [[projectsArray objectAtIndex:0] objectForKey:@"identity"];
	}
	return nil;
}

-(void)saveTasksForProjectWithProjectIdentity: (NSString *)projectIdentity :(NSArray *)valueArray {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
//	NSString *rootTaskIdentity = nil;			//fixed memory leak
	if (valueArray !=nil && [valueArray count] > 0) {
		
		NSDictionary *rootTaskDict = [valueArray objectAtIndex:0];
		
		if (rootTaskDict != nil && ![rootTaskDict isKindOfClass:[NSNull class]]) {
			
			NSString *identity = [rootTaskDict objectForKey:@"Identity"];
			if (identity != nil && ![identity isKindOfClass:[NSNull class]]) {
				//rootTaskIdentity = identity;	//fixed memory leak
			}
		}
		
		//int count = 0;//DE3082
        NSString *parentProjectName = @"";//DE3082
         NSString *temptaskHierarchyName = nil;
		for (NSDictionary *taskDict in valueArray) {
			NSString *identity = [taskDict objectForKey:@"Identity"];
			NSDictionary *propertiesDict = [taskDict objectForKey:@"Properties"];
			NSDictionary *relationshipsDict = [taskDict objectForKey:@"Relationships"];
			NSDictionary *relationshipCountDict = [taskDict objectForKey:@"RelationshipCount"];
			NSString *description = nil;
			NSNumber *timeEntryAllowed = nil;
			NSNumber *assignedTouser = nil;
			NSNumber *childTasksExists = nil;
			NSNumber *closedStatus = nil;
			NSString *billingStatus = nil;
			NSString *parentTaskIdentity = nil;
			NSString *name = nil;
			NSString *taskHierarchyName = nil;
           

			if (propertiesDict != nil && [propertiesDict isKindOfClass:[NSDictionary class]]) {
				
				description = [propertiesDict objectForKey:@"Description"];
				timeEntryAllowed = [propertiesDict objectForKey:@"TimeEntryAllowed"];
				assignedTouser = [propertiesDict objectForKey:@"AssignedToCurrentUser"];
				closedStatus = [propertiesDict objectForKey:@"ClosedStatus"];
				name = [propertiesDict objectForKey:@"Name"];
				taskHierarchyName = [propertiesDict objectForKey:@"HierarchyTaskName"];
                if (temptaskHierarchyName==nil) {
                    temptaskHierarchyName=[taskHierarchyName stringByReplacingOccurrencesOfString:@"/" withString:@""];
                }
				else
                {
                    temptaskHierarchyName=taskHierarchyName;
                }
			}
			
			//do not save if task is project
			//ravi - DE3082: Project Name shows up as Task for certain Projects during Project/Task Selection
            //count = count + 1;//DE3082
			if ([[G2Util splitStringSeperatedByToken:TaskHierarchySeparator originalString:temptaskHierarchyName] count] == 1) {
            //if ([taskHierarchyName isEqualToString:name]) {//DE3082
                parentProjectName = name;//DE3082
			    continue;
			}
			
			if (relationshipsDict != nil && [relationshipsDict isKindOfClass:[NSDictionary class]]) {
				NSDictionary *billingDict = [relationshipsDict objectForKey:@"Billable"];
				if (billingDict != nil && [billingDict isKindOfClass:[NSDictionary class]]) {
					billingStatus = [billingDict objectForKey:@"Identity"];
				}
				NSDictionary *parentTaskDict = [relationshipsDict objectForKey:@"ParentTask"];
				if (parentTaskDict != nil && [parentTaskDict isKindOfClass:[NSDictionary class]]) {
					parentTaskIdentity = [parentTaskDict objectForKey:@"Identity"];
					
					NSString *parentHierarchyName = [[parentTaskDict objectForKey:@"Properties"] objectForKey:@"HierarchyTaskName"];	//	DE3082		 
					
					//ravi - DE3082: Project Name shows up as Task for certain Projects during Project/Task Selection
					if([parentProjectName isEqualToString:parentHierarchyName] && ([parentProjectName rangeOfString:@"/"].location != NSNotFound)){
                        parentTaskIdentity = nil;
                    }else if ([[G2Util splitStringSeperatedByToken:TaskHierarchySeparator originalString:parentHierarchyName] count] == 1) {
                        parentTaskIdentity = nil;
                    }
						
					
				}
			}
			
			if (relationshipCountDict != nil && [relationshipCountDict isKindOfClass:[NSDictionary class]]) {
				 childTasksExists = [relationshipCountDict objectForKey:@"ChildTasks"];
				if (childTasksExists != nil && ![childTasksExists isKindOfClass:[NSNull class]]
					&& [childTasksExists isKindOfClass:[NSNumber class]]) {
					
					if ([childTasksExists intValue] > 0) {
						childTasksExists = [NSNumber numberWithInt:1];
					}
					else {
						childTasksExists = [NSNumber numberWithInt:0];
					}
				}
			}
			
			NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
			
			if (identity != nil && ![identity isKindOfClass:[NSNull class]] 
				&& ![identity isEqualToString:NULL_STRING]) {
				[dataDict setObject:identity forKey:@"identity"];
			}
			if (description != nil && ![description isKindOfClass:[NSNull class]] 
				&& ![description isEqualToString:NULL_STRING]) {
				[dataDict setObject:description forKey:@"description"];
			}
			if (timeEntryAllowed != nil && ![timeEntryAllowed isKindOfClass:[NSNull class]] 
				&& [timeEntryAllowed isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
			}
			if (assignedTouser != nil && ![assignedTouser isKindOfClass:[NSNull class]] 
				&& [assignedTouser isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:assignedTouser forKey:@"assignedToUser"];
			}
			if (childTasksExists != nil && ![childTasksExists isKindOfClass:[NSNull class]] 
				&& [childTasksExists isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:childTasksExists forKey:@"childTasksExists"];
			}
			if (closedStatus != nil && ![closedStatus isKindOfClass:[NSNull class]] 
				&& [closedStatus isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:closedStatus forKey:@"closedStatus"];
			}
			if (billingStatus != nil && ![billingStatus isKindOfClass:[NSNull class]] 
				&& ![billingStatus isEqualToString:NULL_STRING]) {
				[dataDict setObject:billingStatus forKey:@"billingStatus"];
			}
			if (name != nil && ![name isKindOfClass:[NSNull class]] 
				&& ![name isEqualToString:NULL_STRING]) {
				[dataDict setObject:name forKey:@"name"];
			}
			if (parentTaskIdentity != nil && ![parentTaskIdentity isKindOfClass:[NSNull class]] 
				&& ![parentTaskIdentity isEqualToString:NULL_STRING]) {
				[dataDict setObject:parentTaskIdentity forKey:@"parentTaskIdentity"];
			}
			if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] 
				&& ![projectIdentity isEqualToString:NULL_STRING]) {
				[dataDict setObject:projectIdentity forKey:@"projectIdentity"];
			}
			
			if ([self checkTaskExistsForProjectAndParent:identity : projectIdentity :parentTaskIdentity]) {
				NSString *whereString = @"";
				if (parentTaskIdentity == nil) {
					whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity is null",
											 identity, projectIdentity];
				}
				else {
					 whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity = '%@'",
											 identity, projectIdentity,parentTaskIdentity];
				}

				[myDB updateTable:projectTasksTable data:dataDict where:whereString intoDatabase:@""];
			}
			else {
				[myDB insertIntoTable:projectTasksTable data:dataDict intoDatabase:@""];
			}
		}
	}
}


-(BOOL)checkTaskExistsForProjectAndParent:(NSString *)identity :
		(NSString *) projectIdentity :(NSString *)parentTaskIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = @"";
	if (parentTaskIdentity == nil) {
		whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity is null",
					   identity, projectIdentity];
	}
	else {
		whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity = '%@'",
					   identity, projectIdentity,parentTaskIdentity];
	}
	NSMutableArray *taskArray = [myDB select:@"Identity" from:projectTasksTable where:whereString intoDatabase:@""];
	if (taskArray != nil && [taskArray count] > 0) {
		return YES;
	}
	
	return NO;
}

-(NSMutableArray *)getTasksForProjectWithParentTask :(NSString *) projectId : (NSString *)parentTaskIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = @"";
	if (parentTaskIdentity == nil) {
		whereString = [NSString stringWithFormat:@"projectIdentity = '%@' and parentTaskIdentity is null",
					   projectId];
	}
	else {
		whereString = [NSString stringWithFormat:@"projectIdentity = '%@' and parentTaskIdentity = '%@'",
					   projectId,parentTaskIdentity];
	}
	
	NSMutableArray *taskArray = [myDB select:@"*" from:projectTasksTable where:whereString intoDatabase:@""];
	if (taskArray != nil && [taskArray count] > 0) {
		return taskArray;
	}
	
	return nil;
}

-(void)saveSubTasksForProjectWithParentTask: (NSString *)projectIdentity :
	(NSString *)parentTaskIdentity :(NSArray *)valueArray {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    
    //DE11732//JUHI
    NSString *whereString = @"";
    if (parentTaskIdentity == nil) {
        whereString = [NSString stringWithFormat: @"parentTaskIdentity is null"];
    }
    else {
        whereString = [NSString stringWithFormat:@" parentTaskIdentity = '%@'",parentTaskIdentity];
    }
    
    
    [myDB deleteFromTable:projectTasksTable where:whereString inDatabase:@""];
    
    
	if (valueArray !=nil && [valueArray count] > 0) {
		for (NSDictionary *taskDict in valueArray) {
			
			NSString *identity = [taskDict objectForKey:@"Identity"];
			NSDictionary *propertiesDict = [taskDict objectForKey:@"Properties"];
			NSDictionary *relationshipsDict = [taskDict objectForKey:@"Relationships"];
			NSDictionary *relationshipCountDict = [taskDict objectForKey:@"RelationshipCount"];
			NSString *description = nil;
			NSNumber *timeEntryAllowed = nil;
			NSNumber *assignedToUser = nil;
			NSNumber *childTasksExists = [NSNumber numberWithInt:0];
			NSNumber *closedStatus = nil;
			NSString *billingStatus = nil;
			NSString *name = nil;
			
			if (propertiesDict != nil && [propertiesDict isKindOfClass:[NSDictionary class]]) {
				
				description = [propertiesDict objectForKey:@"Description"];
				timeEntryAllowed = [propertiesDict objectForKey:@"TimeEntryAllowed"];
				assignedToUser = [propertiesDict objectForKey:@"AssignedToCurrentUser"];
				closedStatus = [propertiesDict objectForKey:@"ClosedStatus"];
				name = [propertiesDict objectForKey:@"Name"];
			}
			
			if (relationshipsDict != nil && [relationshipsDict isKindOfClass:[NSDictionary class]]) {
				NSDictionary *billingDict = [relationshipsDict objectForKey:@"Billable"];
				if (billingDict != nil && [billingDict isKindOfClass:[NSDictionary class]]) {
					billingStatus = [billingDict objectForKey:@"Identity"];
				}
			}
			
			if (relationshipCountDict != nil && [relationshipCountDict isKindOfClass:[NSDictionary class]]) {
				childTasksExists = [relationshipCountDict objectForKey:@"ChildTasks"];
				if (childTasksExists != nil && ![childTasksExists isKindOfClass:[NSNull class]]
					&& [childTasksExists isKindOfClass:[NSNumber class]]) {
					
					if ([childTasksExists intValue] > 0) {
						childTasksExists = [NSNumber numberWithInt:1];
					}
					else {
						childTasksExists = [NSNumber numberWithInt:0];
					}
					
				}
			}
			
			NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
			
			if (identity != nil && ![identity isKindOfClass:[NSNull class]] 
				&& ![identity isEqualToString:NULL_STRING]) {
				[dataDict setObject:identity forKey:@"identity"];
			}
			if (description != nil && ![description isKindOfClass:[NSNull class]] 
				&& ![description isEqualToString:NULL_STRING]) {
				[dataDict setObject:description forKey:@"description"];
			}
			if (timeEntryAllowed != nil && ![timeEntryAllowed isKindOfClass:[NSNull class]] 
				&& [timeEntryAllowed isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:timeEntryAllowed forKey:@"timeEntryAllowed"];
			}
			if (assignedToUser != nil && ![assignedToUser isKindOfClass:[NSNull class]] 
				&& [assignedToUser isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:assignedToUser forKey:@"assignedToUser"];
			}
			if (childTasksExists != nil && ![childTasksExists isKindOfClass:[NSNull class]] 
				&& [childTasksExists isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:childTasksExists forKey:@"childTasksExists"];
			}
			if (closedStatus != nil && ![closedStatus isKindOfClass:[NSNull class]] 
				&& [closedStatus isKindOfClass:[NSNumber class]]) {
				[dataDict setObject:closedStatus forKey:@"closedStatus"];
			}
			if (billingStatus != nil && ![billingStatus isKindOfClass:[NSNull class]] 
				&& ![billingStatus isEqualToString:NULL_STRING]) {
				[dataDict setObject:billingStatus forKey:@"billingStatus"];
			}
			if (name != nil && ![name isKindOfClass:[NSNull class]] 
				&& ![name isEqualToString:NULL_STRING]) {
				[dataDict setObject:name forKey:@"name"];
			}
			if (parentTaskIdentity != nil && ![parentTaskIdentity isKindOfClass:[NSNull class]] 
				&& ![parentTaskIdentity isEqualToString:NULL_STRING]) {
				[dataDict setObject:parentTaskIdentity forKey:@"parentTaskIdentity"];
			}
			if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]] 
				&& ![projectIdentity isEqualToString:NULL_STRING]) {
				[dataDict setObject:projectIdentity forKey:@"projectIdentity"];
			}
			
			if ([self checkTaskExistsForProjectAndParent:identity : projectIdentity :parentTaskIdentity]) {
				NSString *whereString = @"";
				if (parentTaskIdentity == nil) {
					whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity is null",
								   identity, projectIdentity];
				}
				else {
					whereString = [NSString stringWithFormat:@"identity = '%@' and projectIdentity = '%@' and parentTaskIdentity = '%@'",
								   identity, projectIdentity,parentTaskIdentity];
				}
				
				[myDB updateTable:projectTasksTable data:dataDict where:whereString intoDatabase:@""];
			}
			else {
				[myDB insertIntoTable:projectTasksTable data:dataDict intoDatabase:@""];
			}
		}
	}
}


-(NSString *)getTaskBillableStatus:(NSString *)taskIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",taskIdentity];
	
	NSMutableArray *billingStatusArray = [myDB select:@"billingStatus" from:projectTasksTable where:whereString intoDatabase:@""];
	if (billingStatusArray != nil && [billingStatusArray count] > 0) {
		return [[billingStatusArray objectAtIndex:0] objectForKey:@"billingStatus"];
	}
	
	return nil;	
}

-(NSString *)getProjectBillableStatus:(NSString *)projectIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",projectIdentity];
	
	NSMutableArray *billingStatusArray = [myDB select:@"billingStatus" from:projectsTable where:whereString intoDatabase:@""];
	if (billingStatusArray != nil && [billingStatusArray count] > 0) {
		return [[billingStatusArray objectAtIndex:0] objectForKey:@"billingStatus"];
	}
	
	return nil;	
}

-(NSString *)getProjectTaskBillableStatus:(NSString *)taskIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",taskIdentity];
	
	NSMutableArray *billingStatusArray = [myDB select:@"billingStatus" from:projectTasksTable where:whereString intoDatabase:@""];
	if (billingStatusArray != nil && [billingStatusArray count] > 0) {
		return [[billingStatusArray objectAtIndex:0] objectForKey:@"billingStatus"];
	}
	
	return nil;
}


-(NSString *)getProjectRootTaskIdentity :(NSString *)projectIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"identity = '%@'",projectIdentity];
	
	NSMutableArray *rootTasksArray = [myDB select:@"rootTaskIdentity" from:projectsTable where:whereString intoDatabase:@""];
	if (rootTasksArray != nil && [rootTasksArray count] > 0) {
		return [[rootTasksArray objectAtIndex:0] objectForKey:@"rootTaskIdentity"];
	}
	
	return nil;
}

-(NSMutableArray *)getBillingRatesForProject:(NSString *)selectedProjectIdentity {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"projectId = '%@'",selectedProjectIdentity];
	
	NSMutableArray *billingOptionsArray = [myDB select:@"*" from:billingOptionsTable where:whereString intoDatabase:@""];
	if (billingOptionsArray != nil && [billingOptionsArray count] > 0) {
		return billingOptionsArray;
	}
	
	return nil;
}

-(NSNumber *)getProjectRoleIdForBilling: (NSString *)billingIdentity : (NSString *) selectedProjectIdentity {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"projectRoleName = '%@' and projectId = '%@'",
							 [billingIdentity stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],selectedProjectIdentity];
	
	NSMutableArray *billingOptionsArray = [myDB select:@"*" from:billingOptionsTable where:whereString intoDatabase:@""];
	if (billingOptionsArray != nil && [billingOptionsArray count] > 0) {
		return [[billingOptionsArray objectAtIndex:0] objectForKey:@"projectRoleId"];
	}
	
	return nil;
}

-(NSNumber *)get_role_billing_identity: (NSString *)billingIdentity  {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"billingIdentity = '%@'",
							 [billingIdentity stringByReplacingOccurrencesOfString:@"'" withString:@"''" ]];
	
	NSMutableArray *role_billing_identity_Array = [myDB select:@"*" from:@"time_entries" where:whereString intoDatabase:@""];
	if (role_billing_identity_Array != nil && [role_billing_identity_Array count] > 0) {
        NSDictionary *dict= [role_billing_identity_Array objectAtIndex:0];
		return [dict objectForKey:@"role_billing_Identity"];
	}
	
	return nil;
}

-(NSNumber *)get_role_billing_identityForBillingName: (NSString *)billingName forProjectIdentity:(NSString *)projectIdentity {
    
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"billingName = '%@' AND projectIdentity = '%@' ",
							 [billingName stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],projectIdentity];
	
	NSMutableArray *role_billing_identity_Array = [myDB select:@"*" from:@"time_entries" where:whereString intoDatabase:@""];
	if (role_billing_identity_Array != nil && [role_billing_identity_Array count] > 0) {
        NSDictionary *dict= [role_billing_identity_Array objectAtIndex:0];
		return [dict objectForKey:@"role_billing_Identity"];
	}
	
	return nil;
}


-(NSNumber *)getDepartmentIdForBilling: (NSString *)billingIdentity : (NSString *)selectedProjectIdentity {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"projectRoleName = '%@' and projectId = '%@'",
							  [billingIdentity stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],selectedProjectIdentity];
	
	NSMutableArray *billingOptionsArray = [myDB select:@"*" from:billingOptionsTable where:whereString intoDatabase:@""];
	if (billingOptionsArray != nil && [billingOptionsArray count] > 0) {
		return [[billingOptionsArray objectAtIndex:0] objectForKey:@"projectRoleId"];
	}
	
	return nil;
}

+(id)getLastSyncDateForServiceId:(NSString *)serviceName {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"serviceName = '%@'",serviceName];
	
	NSMutableArray *dataArray = [myDB select:@"*" from:dataSyncTable where:whereString intoDatabase:@""];
	if (dataArray != nil && [dataArray count] > 0) {
		return [[dataArray objectAtIndex:0] objectForKey:@"lastSyncDate"];
	}
	
	return nil;
}


+(void)updateLastSyncDateForServiceId:(NSString *)serviceName {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"serviceName = '%@'",serviceName];
	NSNumber *totalSeconds = [NSNumber numberWithLong:[[NSDate date]timeIntervalSince1970]];
	NSDictionary *dataDict = [NSDictionary dictionaryWithObject:totalSeconds
														 forKey:@"lastSyncDate"];
	[myDB updateTable:dataSyncTable data:dataDict where:whereString intoDatabase:@""];
}

-(NSString *)getClientAllocationId :(NSString *)clientId projectIdentity:(NSString *)projectId {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *whereString = [NSString stringWithFormat:@"clientIdentity = '%@' and identity = '%@'",clientId, projectId];
	
	NSMutableArray *dataArray = [myDB select:@"allocationMethodId" from:projectsTable where:whereString intoDatabase:@""];
	if (dataArray != nil && [dataArray count] > 0) {
		return [[dataArray objectAtIndex:0] objectForKey:@"allocationMethodId"];
	}
	
	return nil;
}

@end
