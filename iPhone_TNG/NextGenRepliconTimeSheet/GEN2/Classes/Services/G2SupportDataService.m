//
//  SupportDataService.m
//  Replicon
//
//  Created by Devi Malladi on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SupportDataService.h"
#import "RepliconAppDelegate.h"

@implementation G2SupportDataService
@synthesize supportDataModel;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (supportDataModel == nil) {
			supportDataModel = [[G2SupportDataModel alloc] init];
		}
	}
	return self;
}
#pragma mark -
#pragma mark Request Methods

-(void)sendRequestToGetSystemPerferencesWithDelegate:(id)delegate{
	/*
	 { "Action": "GetSystemPreferences" }*/
	
	NSDictionary *systemPrefDict=[NSDictionary dictionaryWithObjectsAndKeys:@"GetSystemPreferences",@"Action",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:systemPrefDict error:&err];
	//DLog(@"System Preferences Query:::SupportDataService %@",str);
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetSystemPreferences"]];
	[self setServiceDelegate:self];
	[self executeRequest];
	
	
}
-(void)sendRequestToGetPaymentMethodAllWithDelegate:(id)delegate{
	
	/*[
	 {
	 "Action": "Query",
	 "QueryType": "PaymentMethodAll",
	 "DomainType": "Replicon.Expense.Domain.PaymentMethod",
	 "Args": []
	 }
	 ]*/

	NSArray *argsArray = [NSArray array];
	NSDictionary *paymentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
								 ,@"PaymentMethodAll",@"QueryType"
								 ,@"Replicon.Expense.Domain.PaymentMethod",@"DomainType"
								 ,argsArray,@"Args"
								 ,nil];
	
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:[NSArray arrayWithObject:paymentDict] error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"SystemPaymentMethods"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}

-(void)sendRequestToGetAllTaxeCodesWithDelegate:(id)delegate{
	/*
	 [
	 {
	 "Action": "Query",
	 "QueryType": "TaxCodeAll",
	 "DomainType": "Replicon.Expense.Domain.TaxCode",
	 "Args": []
	 }
	 ]
	 */
	
	NSArray *argsArray = [NSArray array];
	NSDictionary *taxDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
							 ,@"TaxCodeAll",@"QueryType"
							 ,@"Replicon.Expense.Domain.TaxCode",@"DomainType"
							 ,argsArray,@"Args"
							 ,nil];
	
	NSMutableArray *taxArray=[NSMutableArray array];
	[taxArray addObject:taxDict];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:taxArray error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TaxCodeAll"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}
-(void)sendRequestToGetSystemCurrenciesWithDelegate:(id)delegate{
	
	NSArray *argsArray = [NSArray array];
	NSDictionary *currencyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
								  ,@"CurrencyAll",@"QueryType"
								  ,@"Replicon.Domain.Currency",@"DomainType"
								  ,argsArray,@"Args"
								  ,nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:currencyDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToGetExpenseProjects %@",str);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName:@"ReimbursementCurrencies"]]; 
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}

-(void)sendRequestToGetBaseCurrencyWithDelegate:(id)delegate{
	
	NSArray *argsArray = [NSArray array];
	NSDictionary *baseCurrencyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
									  ,@"BaseCurrency",@"QueryType"
									  ,@"Replicon.Domain.Currency",@"DomainType"
									  ,argsArray,@"Args"
									  ,nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:baseCurrencyDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"BaseCurrency"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
}
-(void)sendRequestForUDFSetting:(id)delegate{
	/*
	 {
	 "Action": "Query",
	 "QueryType": "UdfGroupByName",
	 "DomainType": "Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
	 "Args": [
	 "ExpenseEntry"
	 ],
	 "Load": [
	 {
	 "Relationship": "Fields",
	 "Load": [
	 {
	 "Relationship": "DropDownOptions"
	 }
	 ]
	 }
	 ]
	 }
	 */
	
	//[self queryForsystemPreferences];
	
	//UdfGroupByName
	
	NSMutableArray *firstLoadArray;
	firstLoadArray=[NSMutableArray array];
	NSArray *insideArgumentsArray=[NSArray arrayWithObjects:@"ExpenseEntry",nil];
	
	NSMutableArray *secondLoadArray=[NSMutableArray array];
	NSMutableDictionary *udfFieldsDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DropDownOptions",@"Relationship",nil];
	[secondLoadArray addObject:udfFieldsDict];
	
	NSMutableDictionary *firstLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Fields",@"Relationship",secondLoadArray,@"Load",nil];	 
	[firstLoadArray addObject:firstLoadDict];
	NSMutableDictionary *dictUdf=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
								  @"UdfGroupByName",@"QueryType",
								  @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",@"DomainType",
								  insideArgumentsArray,@"Args",
								  firstLoadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:dictUdf error:&err];
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UDFS"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
}
/**
 *Module:TimeSheet
 *Date:May 15th
 **/
-(void)sendRequestToGetUserPreferences {
	
	NSDictionary *userPreferenceDict=[NSDictionary dictionaryWithObjectsAndKeys:@"GetUserPreferences",@"Action",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:userPreferenceDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetUserPreferences"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

-(void)sendRequestToGetDisclaimerPreferences
{
    

	NSArray *argsArray = [NSArray arrayWithObject:@"Timesheet"];
    
    
    NSDictionary *languageLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Language",@"Relationship",
                              nil];
    
    
    NSArray *languageLoadArray = [NSArray arrayWithObject:languageLoadDict];
    
    
    NSDictionary *loadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"ContentOptions",@"Relationship",languageLoadArray,@"Load",
									 nil];

    
    NSArray *loadArray = [NSArray arrayWithObject:loadDict];
    
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Query",@"Action",@"Replicon.Domain.Disclaimer",@"DomainType",
							 @"DisclaimerByTypeName",@"QueryType",
							 argsArray,@"Args",loadArray,@"Load",
							 nil];
	
	//Send  request
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"TIME SHEET CHECK QUERY	%@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetDisclaimerPreferences"]];
	[self setServiceDelegate:self];
	[self executeRequest];

    
}
-(void)sendRequestToGetProjectsAndClients {
	/*
	 {
	 "Action": "Query",
	 "Args": [
	 [
	 "2"
	 ]
	 ],
	 "Load": [
	 {
	 "Relationship": "Projects",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 },
	 {
	 "Relationship": "UserBillingOptions"
	 }
	 ]
	 }
	 ],
	 "QueryType": "UserById",
	 "DomainType": "Replicon.Domain.User"
	 }
	 */
	
	//DLog(@"in sendRequestToGetProjectsAndClients method ");
	
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSArray *innerArgsArray = [NSArray arrayWithObject: userId];
	NSArray *argsArray = [NSArray arrayWithObject:innerArgsArray];
	
	NSDictionary *clientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"Client",@"Relationship",
									 nil];
	NSArray *clientsLoadArray = [NSArray arrayWithObject:clientsLoadDict];
	
	NSDictionary *projectClientsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
											@"ProjectClients",@"Relationship",
											clientsLoadArray,@"Load",
											nil];
	NSDictionary *billingOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"UserBillingOptions",@"Relationship",nil];
	NSArray *projectClientsLoadArray = [NSArray arrayWithObjects:projectClientsLoadDict,
										billingOptionsDict,nil];
	
	NSDictionary *projectsLoadDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"Projects",@"Relationship",
									  projectClientsLoadArray,@"Load",
									  nil];
	
	NSArray *loadArray = [NSArray arrayWithObject:projectsLoadDict];
	
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									 @"UserById",@"QueryType",
									 @"Replicon.Domain.User",@"DomainType",
									 argsArray,@"Args",
									 loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	DLog(@"Json String for projects %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserProjectsAndClients"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}
/**
 *Module:TimeSheet
 *Date:May 25th
 **/
-(void)sendRequestToGetUserActivities :(id)_delegate{
	/*
	 {
	 "Action": "LoadIdentity",
	 "DomainType": "Replicon.Domain.User",
	 "Identity": "2",
	 "Load": [
	 {
	 "Relationship": "Activities"
	 },
	 {
	 "Relationship": "TimeOffCodeAssignments"
	 }
	 ]
	 }*/
	
	NSDictionary *activityDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Activities",@"Relationship",nil];
	NSDictionary *timeOffCodesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"TimeOffCodeAssignments",@"Relationship",nil];
	
	NSMutableArray *loadArray  = [NSMutableArray array];
	[loadArray addObject:activityDict];
	[loadArray addObject:timeOffCodesDict];
	
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",
									 @"Replicon.Domain.User",@"DomainType",
									 userId,@"Identity",
									 loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	//DLog(@"sendRequestToGetUserActivities::Json Str %@",str);
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	//TODO: Need to provide service ID:DONE
	
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserActivities"]]; // ID: 47
	[self setServiceDelegate:_delegate];
	[self executeRequest];
	
}

-(void)sendRequestToGetUserTimeOffs :(id)_delegate{

	NSDictionary *timeOffCodesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"TimeOffCodeAssignments",@"Relationship",nil];
	
	NSMutableArray *loadArray  = [NSMutableArray array];
	[loadArray addObject:timeOffCodesDict];
	
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",
									 @"Replicon.Domain.User",@"DomainType",
									 userId,@"Identity",
									 loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	//DLog(@"sendRequestToGetUserActivities::Json Str %@",str);
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	//TODO: Need to provide service ID:DONE
	
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetUserTimeOffs"]]; // ID: 89
	[self setServiceDelegate:_delegate];
	[self executeRequest];
	
}

-(void)sendRequestToGetProjectBillingOptions{
	/*{
	 "Action": "LoadIdentity",
	 "DomainType": "Replicon.Project.Domain.Project",
	 "Identity": "22",
	 "Load": [
	 {"Relationship": "UserBillingOptions"}
	 ]
	 }
	 */
	
	NSDictionary *billingOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"UserBillingOptions",@"Relationship",nil];
	NSMutableArray *loadArray = [NSMutableArray array];
	[loadArray addObject:billingOptionsDict];
	
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",
									 @"Replicon.Project.Domain.Project",@"DomainType",
									 userId,@"Identity",
									 loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	//DLog(@"sendRequestToGetProjectBillingOptions:::Json Str %@",str);
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	//TODO: Need to provide service ID:DONE
	
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"BillingOptions"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}

/*
 * This method fetches sheetLevel userDefinedFields for timesheets.
 * TODO: reformat method to support all types of UDFS.
 */
-(void)sendRequestToGetTimesheetsUDFSettings :(id)_delegate {
	/*
	 {
	 "Action": "Query",
	 "QueryType": "UdfGroupByName",
	 "DomainType": "Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
	 "Args": [
	 "TimeOffs"
	 ],
	 "Load": [
	 {
	 "Relationship": "Fields",
	 "Load": [
	 {
	 "Relationship": "DropDownOptions"
	 }
	 ]
	 }
	 ]
	 }
	 */
	NSArray *argsArray = [NSArray arrayWithObject:@"ReportPeriod"];
	
	NSDictionary *dropDownOptionsRelationDict  = [NSDictionary dictionaryWithObject:
												  @"DropDownOptions" forKey:@"Relationship"];
	NSArray *fieldsLoadArray = [NSArray arrayWithObject:dropDownOptionsRelationDict];
	NSDictionary *fieldsRelationDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"Fields",@"Relationship",
										fieldsLoadArray,@"Load",
										nil
										];
	NSArray *loadArray = [NSArray arrayWithObject:fieldsRelationDict];
	NSMutableDictionary *queryDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									 @"UdfGroupByName",@"QueryType",
									 @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
									 @"DomainType",
									 argsArray,@"Args",
									 loadArray,@"Load",
									 nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	//DLog(@"UDF SETTINGS QUERY::: %@",str);
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	//TODO: Need to provide service ID:DONE
	
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"TimesheetUDFs"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
}

#pragma mark -
#pragma mark Response Handler's
-(void)handleUserPreferencesResponse: (id)response {
	

		[supportDataModel saveUserPreferencesFromApiToDB: response];
}

-(void)handleDisclaimerPreferencesResponse: (id)response 
{

		[supportDataModel saveUserDisclaimersFromApiToDB: response];
}
/**
 *Module:TimeSheet
 *Date:May 16th
 **/
-(void)handleSystemPreferencesResponse:(id) response {

		[supportDataModel insertSystemPreferencesToDatabase:response];
		//Get Enabled Fields
		[[NSUserDefaults standardUserDefaults] setObject:[supportDataModel getEnabledSystemPreferences] forKey:@"EnabledSystemPreferences"];
        [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)handleTimeOffResponse:(id)response{

		NSArray *timeOffCodesArray = [[response objectForKey:@"Relationships"] objectForKey:@"TimeOffCodeAssignments"];
		[supportDataModel saveTimeOffCodesFromApiToDB:timeOffCodesArray];

}


-(void)handleProjectsAndClientsResponse: (id)response {
	//DLog(@"handleProjectsAndClientsResponse::: SupportDataService %@",response);
	
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"]) {
		NSArray *valueArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
		NSDictionary *userDict = [valueArray objectAtIndex:0];
		NSArray *projectsArray = [[userDict objectForKey:@"Relationships"] objectForKey:@"Projects"];
		[supportDataModel saveUserProjectsAndClientsFromApiToDB:projectsArray];
		//TODO: Save Billing Options for the project:DONE
		NSArray *billingOptionsArray;
		for (int i=0; i<[projectsArray count]; i++) {
			billingOptionsArray=[[[projectsArray objectAtIndex:i] objectForKey:@"Relationships"] 
								 objectForKey:@"UserBillingOptions"];
			NSString *projectIdentity = [[projectsArray objectAtIndex:i] objectForKey:@"Identity"]; 
			for (int j=0; j<[billingOptionsArray count]; j++) {
				[supportDataModel saveProjectBillingOptionsFromApiToDB:
				 [billingOptionsArray objectAtIndex:j] :projectIdentity];
			}
		}
		[[NSNotificationCenter defaultCenter]postNotificationName:USER_PROJECTS_RECEIVED_NOTIFICATION object:nil];
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {

            [G2Util errorAlert:@"" errorMessage:value];
		}else {

            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
}

-(void)handleUserActivitiesResponse:(id)response{
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	
	if([responseStatus isEqualToString:@"OK"]) {
		NSArray *valueArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
		NSDictionary *userDict = [valueArray objectAtIndex:0];
		NSArray *activityArray = [[userDict objectForKey:@"Relationships"] objectForKey:@"Activities"];
		[supportDataModel saveUserActivitiesFromApiToDB:activityArray];
		[[NSNotificationCenter defaultCenter] postNotificationName:USER_ACTIVITIES_RECEIVED_NOTIFICATION object:nil];
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {

            [G2Util errorAlert:@"" errorMessage:value];
		}else {

            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
}



-(void)handleProjectBillingOptionsResponse:(id)response{
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	
	if([responseStatus isEqualToString:@"OK"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:PROJECTS_BILLINGOPTIONS_RECEIVED_NOTIFICATION object:nil];
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {

            [G2Util errorAlert:@"" errorMessage:value];
		}else {

            [G2Util errorAlert:@"" errorMessage:message];
		}
	}
	
}

-(void)handleTimesheetUDFSettingsResponse : (id)response {
	
	NSString *responseStatus = [[response objectForKey:@"response"] objectForKey:@"Status"];
	
	if(responseStatus != nil && [responseStatus isEqualToString:@"OK"]) {
		NSArray *valueArray = [[response objectForKey:@"response"] objectForKey:@"Value"];
		if (valueArray != nil) {
			//[supportDataModel saveTimesheetUDFSettingsFromApiToDB:valueArray];//US1736
		}
	}else {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
//			[Util errorAlert:responseStatus errorMessage:value];
            [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
		}else {
//			[Util errorAlert:responseStatus errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
	
}

#pragma mark ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
	if (response!=nil) {
		NSNumber *serviceId=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
		if ([serviceId intValue] == GetUserPreferences_40) {
			[self handleUserPreferencesResponse: response];
		}
		else if ([serviceId intValue] == UserProjectsAndClients_42) {
			[self handleProjectsAndClientsResponse:response];
		} 
		else if ([serviceId intValue] == GetSystemPreferences_ServiceID_9) {
			[self handleSystemPreferencesResponse:response];
		}
		else if ([serviceId intValue] == UserActivities_Service_Id_47) {//Request Name: UserActivities  Notification: USER_ACTIVITIES_TIME_OFF_CODES_RECEIVED_NOTIFICATION
			[self handleUserActivitiesResponse:response];
		}
		else if ([serviceId intValue] == BillingOptions_Serice_Id_48) {
			[self handleProjectBillingOptionsResponse:response];
		}
		else if ([serviceId intValue] == TimesheetUDFs_Service_id_51) {
			//[self handleTimesheetUDFSettingsResponse:response];//Request Name: TimeSheetUDFs Notification: N/A//US1736
		}
        else if ([serviceId intValue] == GetDisclaimerPreferences_83) {
			[self handleDisclaimerPreferencesResponse: response];
		}
        else if ([serviceId intValue] == GetTimeOffCodess_ServiceID_89) {
			[self handleTimeOffResponse: response];
		}
        
	}
	
}
- (void) serverDidFailWithError:(NSError *) error
{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showOfflineAlert];
		return;
	}
	[self showErrorAlert:error];

	return;
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
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED ]) {
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
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, "")];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, "")];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    else
    {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    }
}




@end
