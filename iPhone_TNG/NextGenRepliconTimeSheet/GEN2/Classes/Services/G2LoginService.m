//
//  LoginService.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2LoginService.h"
#import "G2Util.h"
#import "G2LoginModel.h"
#import "G2RepliconServiceManager.h"
#import"G2PermissionsModel.h"
#import "RepliconAppDelegate.h"
#import "FrameworkImport.h"

@interface G2LoginService()
-(void)handleSessionIdResponse:(id)response;
-(void)handleAPIURLResponse:(id)response;
-(void)handleUserByLoginNameResponse:(id)response;
@end

@implementation G2LoginService


-(void)sendrequestToFetchAPIURLWithDelegate:(id )delegate {
	
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									  [dict objectForKey:@"companyName"],@"CompanyKey",
									  [[G2AppProperties getInstance] getAppPropertyFor:@"Version"],@"Version",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil) {
        urlStr=[NSString stringWithFormat:@"https://%@.%@.%@/FetchRemoteApiUrl.ashx?companyKey=%@&version=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],[[G2AppProperties getInstance] getAppPropertyFor: @"StagingBaseURLName"],[[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"],[dict objectForKey:@"companyName"],[[G2AppProperties getInstance] getAppPropertyFor: @"APIVersion"]];
    }
    else
    {
        urlStr=[NSString stringWithFormat:@"https://%@.%@/FetchRemoteApiUrl.ashx?companyKey=%@&version=%@",[[G2AppProperties getInstance] getAppPropertyFor: @"ProductionBaseURLName"],[[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"],[dict objectForKey:@"companyName"],[[G2AppProperties getInstance] getAppPropertyFor: @"APIVersion"]];
    }
    
    DLog(@"URL:::%@",urlStr);
    
	[paramDict setObject:urlStr forKey:@"URLString"];
    //	[paramDict setObject:[ServiceUtil getServiceURLToFetchCompanyURL] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	  
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"FetchCompanyURL"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
	 	
}

-(void)sendrequestToFetchAuthRemoteAPIUrl:(id )delegate {
	
	NSDictionary *companyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
    NSDictionary *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"];

    NSString *urlStr;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil) {
        urlStr=[NSString stringWithFormat:@"http://%@.%@/FetchAuthRemoteAPIUrl.ashx?Version=%@&CompanyKey=%@&LoginName=%@&Output=json",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],@"services.dev.replicon.com",[[G2AppProperties getInstance] getAppPropertyFor: @"APIVersion"],companyName,loginName];
    }
    else
    {
        urlStr=[NSString stringWithFormat:@"http://%@.%@/FetchAuthRemoteAPIUrl.ashx?Version=%@&CompanyKey=%@&LoginName=%@&Output=json",[[G2AppProperties getInstance] getAppPropertyFor: @"ProductionBaseURLName"],[[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"],[[G2AppProperties getInstance] getAppPropertyFor: @"APIVersion"],companyName,loginName];
    }
    
    DLog(@"URL:::%@",urlStr);
    
     [self setRequest:[G2RequestBuilder buildGETRequestWithParamDict:[NSDictionary dictionaryWithObject:urlStr forKey:@"URLString"]]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"FetchAuthRemoteAPIURL"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
    
}

-(void)sendrequestToFetchNewAuthRemoteAPIUrl:(id )delegate {
	
	NSDictionary *companyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
    NSDictionary *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"];
    
    NSString *urlStr;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil) {
        urlStr=[NSString stringWithFormat:@"http://%@.%@/FetchNewAuthRemoteAPIUrl.ashx?Version=%@&CompanyKey=%@&LoginName=%@&Output=json",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],@"services.dev.replicon.com",[[G2AppProperties getInstance] getAppPropertyFor: @"APIVersion"],companyName,loginName];
    }
    else
    {
        urlStr=[NSString stringWithFormat:@"http://%@.%@/FetchNewAuthRemoteAPIUrl.ashx?Version=%@&CompanyKey=%@&LoginName=%@&Output=json",[[G2AppProperties getInstance] getAppPropertyFor: @"ProductionBaseURLName"],[[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"],[[G2AppProperties getInstance] getAppPropertyFor: @"APIVersion"],companyName,loginName];
    }
    
    DLog(@"URL:::%@",urlStr);
    
    [self setRequest:[G2RequestBuilder buildGETRequestWithParamDict:[NSDictionary dictionaryWithObject:urlStr forKey:@"URLString"]]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"FetchNewAuthRemoteAPIURL"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
    
}

-(void)sendrequestToCompleteSAMLFlow:(NSString *)guid
{
   NSString *urlStr=[[NSUserDefaults standardUserDefaults] objectForKey:@"ResponseServiceURL"];
    
    urlStr=[urlStr stringByReplacingOccurrencesOfString:@"{GUID}" withString:guid];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CompleteSAMLFlowURLWithGUID"];
    [[NSUserDefaults standardUserDefaults] setObject:urlStr forKey:@"CompleteSAMLFlowURLWithGUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    DLog(@"URL:::%@",urlStr);
    
    [self setRequest:[G2RequestBuilder buildGETRequestWithParamDict:[NSDictionary dictionaryWithObject:urlStr forKey:@"URLString"]]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"CompleteSAMLFlowAPIURL"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}

-(void)sendrequestToFetchUserIntegrationDetailsWithCompanyName:(NSString *)companyName andUsername:(NSString *)loginName {
	

	
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									  companyName,@"companyKey",
									  loginName,@"loginName",
                                      @"/mobile-sso-landing",@"targetUrl",
                                      nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil)
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"])
        {
            urlStr=[NSString stringWithFormat:@"https://%@-global.%@/%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]lowercaseString],[[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"],@"DiscoveryService1.svc/GetUserIntegrationDetails"];
            
        }
        else
        {
            urlStr=[NSString stringWithFormat:@"https://%@.%@.%@/%@",@"global",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],@"replicon.staging",@"DiscoveryService1.svc/GetUserIntegrationDetails"];
        }
        
      
    }
    else
    {
        urlStr=[NSString stringWithFormat:@"https://%@.%@/%@",@"global",@"replicon.com",@"DiscoveryService1.svc/GetUserIntegrationDetails"];
    }
    DLog(@"URL:::%@",urlStr);
    
    [paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDictForGen3:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"UserIntegrationDetails"]];
	[self setServiceDelegate:[G2TransitionPageViewController getInstance]];
	[self executeRequest];
    
    
    
}

-(void)sendMultipleRequestForLoginWithDelegate:(id )delegate
{
    NSMutableArray *requestArr=[NSMutableArray array];
    
    // CheckExistenceOfUserByLoginName
    
  
   
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        NSMutableArray *loadArray=[NSMutableArray array];
        NSDictionary *loadDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ModuleGroups",@"Relationship",nil];
        [loadArray addObject:loadDict];
        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
         NSArray *array =[NSArray arrayWithObjects:[dict objectForKey:@"userName"],nil];
        NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Language",@"Relationship",nil];
        
        [loadArray addObject:languageDict];
        
        
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",@"UserByLoginName",@"QueryType",@"Replicon.Domain.User",@"DomainType",array,@"Args",loadArray,@"Load",nil];
        //    NSArray *arr = [NSArray arrayWithObject:dict1];
        //    NSError *error0;
        //    NSString *str0 = [JsonWrapper writeJson:arr error:&error0];
        
        [requestArr addObject:dict1];
    }
   
    
   
    

    
    
    if ([G2Util shallExecuteQuery:GENERAL_SUPPORTING_DATA_SECTION]) {
        
        //GetUserPreferences
        
        NSDictionary *userPreferenceDict=[NSDictionary dictionaryWithObjectsAndKeys:@"GetUserPreferences",@"Action",nil];
//        NSError *err1 = nil;
//        NSString *str1 = [JsonWrapper writeJson:userPreferenceDict error:&err1];
        
        [requestArr addObject:userPreferenceDict];
        
        //GetDisclaimerPreferences
        
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
//        NSError *err2 = nil;
//        NSString *str2 = [JsonWrapper writeJson:queryDict error:&err2];
        [requestArr addObject:queryDict];
        
        
        //GetUserPermissions
        
        NSMutableArray *permissionsArray = [NSMutableArray arrayWithObjects:
                                            @"UseTimesheet",
                                            @"ProjectExpense",
                                            @"ClassicTimesheet",
                                            @"LockedInOutTimesheet",
                                            @"InOutTimesheet",
                                            @"NewInOutTimesheet",
                                            @"RequireDisclaimerAcceptance",
                                            @"ShowTimesheetDisclaimer",
                                            @"TimeoffTimesheet",
                                            @"UnsubmitTimesheet",
                                            @"UnsubmitExpense",
                                            @"NonProjectExpense",
                                            @"NewTimesheet",
                                            @"TimeOffBookingUser",
                                            @"EditFutureTimeOffBookingUser",
                                            @"ProjectTimesheet",
                                            @"NonProjectTimesheet",
                                            @"BillingTimesheet",
                                            @"AllowBlankTimesheetComments",
                                            @"AllowBlankResubmitComment",
                                            @"AllowBlankResubmitExpenseComment",//US2669
                                            @"ApproverAllowBlankRejectComment",
                                            @"ApprovalMenu",
                                            @"TimesheetEntryUDF1",
                                            @"TimesheetEntryUDF2",
                                            @"TimesheetEntryUDF3",
                                            @"TimesheetEntryUDF4",
                                            @"TimesheetEntryUDF5",
                                            @"ReportPeriodUDF1",
                                            @"ReportPeriodUDF2",
                                            @"ReportPeriodUDF3",
                                            @"ReportPeriodUDF4",
                                            @"ReportPeriodUDF5",
                                            @"TimeOffUDF1",
                                            @"TimeOffUDF2",
                                            @"TimeOffUDF3",
                                            @"TimeOffUDF4",
                                            @"TimeOffUDF5",
                                            @"TimesheetActivityRequired",
                                            @"TimesheetDisplayActivities",
                                            @"TaskTimesheetUDF1",
                                            @"TaskTimesheetUDF2",
                                            @"TaskTimesheetUDF3",
                                            @"TaskTimesheetUDF4",
                                            @"TaskTimesheetUDF5",
                                            @"MobileLockedInOutTimesheet",@"ReopenTimesheet",nil];//Us4660//Juhi
        NSDictionary *permissionsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CheckUserPermissions",@"Action"
                                         ,permissionsArray,@"Permissions"
                                         ,nil];
//        NSError *err3 = nil;
//        NSString *str3 = [JsonWrapper writeJson:permissionsDict error:&err3];
        [requestArr addObject:permissionsDict];
        
        //GetSystemPreferences
        
        NSDictionary *systemPrefDict=[NSDictionary dictionaryWithObjectsAndKeys:@"GetSystemPreferences",@"Action",nil];
//        NSError *err4 = nil;
//        NSString *str4 = [JsonWrapper writeJson:systemPrefDict error:&err4];
        [requestArr addObject:systemPrefDict];
        
        //GetUserTimeOffCodes
        
        NSDictionary *timeOffCodesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"TimeOffCodeAssignments",@"Relationship",nil];
        
        NSMutableArray *loadArray1  = [NSMutableArray array];
        [loadArray1 addObject:timeOffCodesDict];
        
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
        NSMutableDictionary *queryDict1 =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",
                                         @"Replicon.Domain.User",@"DomainType",
                                         userId,@"Identity",
                                         loadArray1,@"Load",nil];
        
//        NSError *err5 = nil;
//        NSString *str5 = [JsonWrapper writeJson:queryDict1 error:&err5];
        [requestArr addObject:queryDict1];
        
        
        
        //GET UDF"S WITH PERMISSION SET
                
        NSArray *sheetArgsArray = [NSArray arrayWithObject:ReportPeriod_SheetLevel];
        NSArray *rowArgsArray   = [NSArray arrayWithObject:TaskTimesheet_RowLevel];
        NSArray *cellArgsArray  = [NSArray arrayWithObject:TimesheetEntry_CellLevel];
        
        NSArray *timeOffsArgsArray  = [NSArray arrayWithObject:TimeOffs_SheetLevel];//US4591//Juhi
        
        
        NSDictionary *dropDownOptionsRelationDict  = [NSDictionary dictionaryWithObject:
                                                      @"DropDownOptions" forKey:@"Relationship"];
        NSArray *fieldsLoadArray = [NSArray arrayWithObject:dropDownOptionsRelationDict];
        NSDictionary *fieldsRelationDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            @"Fields",@"Relationship",
                                            fieldsLoadArray,@"Load",
                                            nil
                                            ];
        NSArray *loadArray2 = [NSArray arrayWithObject:fieldsRelationDict];
        NSMutableDictionary *sheetLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                              @"UdfGroupByName",@"QueryType",
                                              @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                              @"DomainType",
                                              sheetArgsArray,@"Args",
                                              loadArray2,@"Load",
                                              nil];
        NSMutableDictionary *rowLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                            @"UdfGroupByName",@"QueryType",
                                            @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                            @"DomainType",
                                            rowArgsArray,@"Args",
                                            loadArray2,@"Load",
                                            nil];
        NSMutableDictionary *cellLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                             @"UdfGroupByName",@"QueryType",
                                             @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                             @"DomainType",
                                             cellArgsArray,@"Args",
                                             loadArray2,@"Load",
                                             nil];
        
        NSMutableDictionary *timeOffsLevelDict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                                 @"UdfGroupByName",@"QueryType",
                                                 @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",
                                                 @"DomainType",
                                                 timeOffsArgsArray,@"Args",
                                                 loadArray2,@"Load",
                                                 nil];//US4591//Juhi
        
        
        
        
       
            [requestArr addObject:sheetLevelDict];
        
            [requestArr addObject:rowLevelDict];

            [requestArr addObject:timeOffsLevelDict];
        
            [requestArr addObject:cellLevelDict];
        
        
        
    }
    
    NSError *finalerr = nil;
    NSString *finalStr=[JsonWrapper writeJson:requestArr error:&finalerr];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:finalStr forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"MergedLoginAPI"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}

-(void)sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:(id )delegate {
	
	//[{"Action":"Query","Args":["admin"],"QueryType":"UserByLoginName","DomainType":"Replicon.Domain.User"}]

           NSMutableArray *loadArray=[NSMutableArray array];
	NSDictionary *loadDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ModuleGroups",@"Relationship",nil];
	[loadArray addObject:loadDict];

       NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
		NSArray *array = [NSArray arrayWithObjects:[dict objectForKey:@"userName"],nil];
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Language",@"Relationship",nil];
    
	[loadArray addObject:languageDict];
    
    
		NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",@"UserByLoginName",@"QueryType",@"Replicon.Domain.User",@"DomainType",array,@"Args",loadArray,@"Load",nil];
		NSArray *arr = [NSArray arrayWithObject:dict1];
		NSError *error;
		NSString *str = [JsonWrapper writeJson:arr error:&error];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserByLoginName"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}

-(void)sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:(id )delegate forUsername:(NSString *)username 
{
	
	//[{"Action":"Query","Args":["admin"],"QueryType":"UserByLoginName","DomainType":"Replicon.Domain.User"}]
    
    NSMutableArray *loadArray=[NSMutableArray array];
	NSDictionary *loadDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ModuleGroups",@"Relationship",nil];
	[loadArray addObject:loadDict];
    
    
    NSArray *array = [NSArray arrayWithObjects:username,nil];
    
    NSDictionary *languageDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"Language",@"Relationship",nil];
    
	[loadArray addObject:languageDict];
    
    
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",@"UserByLoginName",@"QueryType",@"Replicon.Domain.User",@"DomainType",array,@"Args",loadArray,@"Load",nil];
    NSArray *arr = [NSArray arrayWithObject:dict1];
    NSError *error;
    NSString *str = [JsonWrapper writeJson:arr error:&error];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserByLoginName"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}

-(void)sendRequestToCheckUserChangePasswordRequired:(id)delegate{
	
	/**{
		"Action": "BeginSession"
	}**/
	
	NSDictionary *changePasswordDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BeginSession",@"Action",
									  nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:changePasswordDict error:&err];
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ChangePassword"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}
-(void)sendRequestToSubmitChangePassword:(id)delegate{
	/*{
	 "Action": "Edit",
		"Type": "Replicon.Domain.User",
		"Identity": "zzz", 
		"Operations": 
		[
		 {"__operation": "SetProperties", 
			 "Password": "newpassword"}
		 ]
	}*/
	
	NSDictionary *operationsDict = [NSDictionary dictionaryWithObjectsAndKeys:
									@"SetProperties",@"__operation",
									[NSNumber numberWithInt:0],@"ForcePasswordChange",
									[[NSUserDefaults standardUserDefaults] objectForKey:@"PASSWORD_CHANGED"],@"Password",
									nil];
	NSArray *operationsArr = [NSArray arrayWithObject:operationsDict];
	NSDictionary *submitPasswordDict = [NSDictionary dictionaryWithObjectsAndKeys:
										@"Edit",@"Action",
										@"Replicon.Domain.User",@"Type",
										[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",
										operationsArr,@"Operations",
										nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:submitPasswordDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SubmitChangePassword"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];

}


-(void)sendRequestToGetSessionBasedApi:(id)delegate
{
	NSDictionary *sessionDict=[NSDictionary dictionaryWithObjectsAndKeys:@"BeginSession",@"Action",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:sessionDict error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	//[self setRequest:[RequestBuilder buildPOSTRequestWithParamDictToHandleCookies:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetSessionId"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}

#pragma mark session  LogOut
-(void)sendRequestForSessionLogout:(id)delegate
{
	/*
	 { "Action": "EndSession" }
	 */
	NSDictionary *sessionDict=[NSDictionary dictionaryWithObjectsAndKeys:@"EndSession",@"Action",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:sessionDict error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"EndSession"]];
	[self setServiceDelegate: [G2TransitionPageViewController getInstance]];
	[self executeRequest];
}

-(void)sendRequestForFreeTrialSignUp{
	
}

-(void)sendRequestToResetPassword{

}

#pragma mark -
#pragma mark Response Handlers

- (void) processResponse:(id) response {
	
	if (response!=nil)
    {
        
        id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
        
        if ([_serviceID intValue]== UserIntegrationDetails_Service_ID_103)
        {
            
            NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
            
            if (errorDict!=nil)
            {
            
                [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"hasError"] ];
                
            }
            else
            {
                
                [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"hasError"] ];
                
            }
            
            return;
        }

        else if ([serviceID intValue]== CompleteSAMLFlowRemoteAPIURL_Service_Id_105) {
            [self handleCompleteSAMLFlowAPIURLResponse:response];
            return;
            
        }

        
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		
		
        DLog(@"%@",serviceID);
		if ([_serviceID intValue]== [[G2ServiceUtil getServiceIDForServiceName: @"FetchCompanyURL"] intValue]) {
			[self handleAPIURLResponse:[[response objectForKey:@"response"]objectForKey:@"Value"]];				
			
		}
        
		if ([status isEqualToString:@"OK"]) {		  
			if ([_serviceID intValue] == UserByLoginName_ServiceID_1) {
				[self handleUserByLoginNameResponse:[[response objectForKey:@"response"]objectForKey:@"Value"]];
				
			}else if ([_serviceID intValue] == CheckUserPermissions_ServiceID_2) {
				//[self handleUserPermissonsResponse:[[response objectForKey:@"response"]objectForKey:@"Value"]];
				
			} else if ([_serviceID intValue] == GetSessionId_36) {
                         [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"firstTimeLogging"] ;
                [[NSUserDefaults standardUserDefaults] synchronize];
				[self handleSessionIdResponse:[[response objectForKey:@"response"]objectForKey:@"Value"]];
			} else if ([serviceID intValue] == EndSession_39) {
				[self handleEndSessionResponse];
			}else if ([serviceID intValue] == FreeTrial_ServiceID_66) {
				[self handleFreeTrialResponse:response];
			}else if ([serviceID intValue] == ResetPassword_Service_Id_67) {
				[self handleResetPasswordResponse:response];
			}
            else if ([serviceID intValue]== FetchAuthRemoteAPIUrl_Service_Id_91) {
                [self handleSAMLAPIURLResponse:response];
                
                
            }
            else if ([serviceID intValue]== FetchNewAuthRemoteAPIURL_Service_Id_104) {
                [self handleNewSAMLAPIURLResponse:response];
                
                
            }
            
            else if ([serviceID intValue]== CompleteSAMLFlowRemoteAPIURL_Service_Id_105) {
                [self handleCompleteSAMLFlowAPIURLResponse:response];
                
                
            }
            
            else if ([serviceID intValue]== MergedLogin_Service_Id_93) {
                [self handleMergedLoginResponse:response];				
                
                
            }
			
		}else {
			
			//if (![status isEqualToString:@"OK"]) {
			//	[self clearPassword];
			//}
			NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			if (value!=nil) {
				[G2Util errorAlert:ErrorTitle errorMessage:value];
			}else {
				[G2Util errorAlert:ErrorTitle errorMessage:message];
			}
			
		}
	}
}


#pragma mark AlertViewMethods Implementation
-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message {
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle: nil message: message
															  delegate: self cancelButtonTitle: RPLocalizedString(CLOSE_BTN_TITLE, CLOSE_BTN_TITLE)
													 otherButtonTitles: RPLocalizedString(_buttonTitle,@""),nil];
	[confirmAlertView setDelegate:self];
	[confirmAlertView setTag:0];
	
	if ([_buttonTitle isEqualToString: RPLocalizedString(GoToWebTitle, GoToWebTitle)]) {
		confirmAlertView.tag=1;
		[confirmAlertView show];
		
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSDictionary *credDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
	NSString *compName =nil;
	if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
		compName = [credDict objectForKey:@"companyName"];
	}
	if (alertView.tag==1) {	
		if (buttonIndex==1) {
			if (compName==nil) {
                compName=@"";
            }
			NSURL *myURL = [NSURL URLWithString:[G2ServiceUtil getServiceURLFor:@"TrialProductErrorMessage_Url" replaceString:@"<companykey>" WithCompanyName:compName]]; 
			[[UIApplication sharedApplication] openURL:myURL];
		}
	}
	[self removeUserInformationWithCookies];
	
	
}


-(void)handleEndSessionResponse {
	
	[self removeUserInformationWithCookies];
	
	[G2Util flushDBInfoForOldUser:NO];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AuthMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
         [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloadCompanyView)];
    }
    
    else
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    
	
    
}

-(void)handleSessionIdResponse:(id)response
{
	//DLog(@"handleSessionIdResponse");
	if (response != nil && [(NSMutableArray *)response count]>0) {
		//[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		for (int i=0; i<[(NSMutableArray *)response count]; i++) {
			[[NSUserDefaults standardUserDefaults] setObject:[[response objectAtIndex:i] objectForKey:@"PasswordChangeRequired"] forKey:@"PasswordChangeRequired"];
			[[NSUserDefaults standardUserDefaults] setObject:[[[response objectAtIndex:i]objectForKey:@"UserId"]objectForKey:@"Identity"] forKey:@"UserID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
		}
		//US5230 : Remove check to see if user's account status is trial expired
//		id eulaReqFlag = [[response objectAtIndex:0] objectForKey:@"EulaRequired"];
//		if (eulaReqFlag != nil && ![eulaReqFlag isKindOfClass:[NSNull class]]) {
//			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
//			[self confirmAlert:RPLocalizedString(GoToWebTitle, GoToWebTitle)  confirmMessage:RPLocalizedString(TrialProductErrorMessage, "") ];
//			return;
//			
//		}
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"PasswordChangeRequired"] intValue]== 1) {
			DLog(@"CHANGE PASSWORD IS REQUIRED");
#ifdef _DROP_RELEASE_1_US1719
			loginDelegate = [[LoginDelegate alloc] init];
			[loginDelegate setParentController:self];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(launchChangePasswordViewController:) withObject:loginDelegate];
#endif
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(Force_Password_Alert_Message,Force_Password_Alert_Message) ];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PasswordChangeRequired"];
			[self removeUserInformationWithCookies];
            [G2Util flushDBInfoForOldUser:NO];
            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"isSuccessLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
               [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloadCompanyView)];
            }
            else
            {
                 [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
            }
			return;
		}
		else {
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, LoadingMessage)];
			//[[RepliconServiceManager loginService]sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:self];
            
            [[G2RepliconServiceManager loginService]sendMultipleRequestForLoginWithDelegate:self];
		}



        NSMutableDictionary *loginCredentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];


        NSString *companyName = [loginCredentials objectForKey:@"companyName"];
        if (companyName == nil || companyName.length <= 0) {
            companyName = @"na";
        }
        NSString *userUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
        if (userUri == nil || userUri.length <= 0) {
            userUri = @"na";
        }
        NSString *username = [loginCredentials objectForKey:@"userName"];
        if (username == nil || username.length == 0) {
            username = @"na";
        }
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate.gaTracker setUserUri:userUri companyName:companyName username:username platform:@"gen2"];
        
	}
}


-(void)handleAPIURLResponse:(id)response
{
	
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    if (![response isKindOfClass:[NSNull class] ]) 
    {
        if ([response length]!=0 && [NSURL URLWithString:response] != nil) {
            [[NSUserDefaults standardUserDefaults]setObject:response forKey:@"ServiceURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //	[[RepliconServiceManager loginService]sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:self];
            [[G2RepliconServiceManager loginService]sendRequestToGetSessionBasedApi:self];
            
        }else {
            [[NSUserDefaults standardUserDefaults]setObject:[G2ServiceUtil getServiceURLWithCompanyName:[dict objectForKey:@"companyName"]] forKey:@"ServiceURL"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
	
}


-(void)handleSAMLAPIURLResponse:(id)response
{
	
        NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) 
        {
            DLog(@"%@",[[response objectForKey:@"response"]objectForKey:@"Value"]);
            [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"]objectForKey:@"Value"] forKey:@"ServiceURL"];
              DLog(@"%@",[[response objectForKey:@"response"]objectForKey:@"RequestUrl"]);
            [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"RequestUrl"] forKey:@"RequestServiceURL"];
              DLog(@"%@",[[response objectForKey:@"response"]objectForKey:@"AuthMode"]);
            
            if ([[[response objectForKey:@"response"] objectForKey:@"AuthMode"] isEqualToString:@"Mixed"]) 
            {
                //DLog(@"%@",[[response objectForKey:@"response"] objectForKey:@"UserAuthMode"]);
                if (![[[response objectForKey:@"response"] objectForKey:@"UserAuthMode"] isKindOfClass:[NSNull class] ] ) 
                {
                        [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"UserAuthMode"] forKey:@"AuthMode"];
                }
                
            }
            else
            {
                [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"AuthMode"] forKey:@"AuthMode"];
            }
             
            [[NSUserDefaults standardUserDefaults] synchronize];
            //	[[RepliconServiceManager loginService]sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:self];
            
            RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"]) 
            {
                [delegate launchWebViewController];
            }
            else 
            {
                [delegate launchLoginViewController];
            }
            
    }
	    else
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            NSString *message = [response objectForKey:@"Message"];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            [G2Util errorAlert:@"" errorMessage:message];
        }
}

-(void)handleNewSAMLAPIURLResponse:(id)response
{
	
    NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
    if ([status isEqualToString:@"OK"])
    {
        DLog(@"%@",[[response objectForKey:@"response"]objectForKey:@"Value"]);
        [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"]objectForKey:@"Value"] forKey:@"ServiceURL"];
        DLog(@"%@",[[response objectForKey:@"response"]objectForKey:@"RequestUrl"]);
        [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"RequestUrl"] forKey:@"RequestServiceURL"];
         [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"ResponseUrl"] forKey:@"ResponseServiceURL"];
        DLog(@"%@",[[response objectForKey:@"response"]objectForKey:@"AuthMode"]);
        
        if ([[[response objectForKey:@"response"] objectForKey:@"AuthMode"] isEqualToString:@"Mixed"])
        {
            //DLog(@"%@",[[response objectForKey:@"response"] objectForKey:@"UserAuthMode"]);
            if (![[[response objectForKey:@"response"] objectForKey:@"UserAuthMode"] isKindOfClass:[NSNull class] ] )
            {
                [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"UserAuthMode"] forKey:@"AuthMode"];
            }
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:[[response objectForKey:@"response"] objectForKey:@"AuthMode"] forKey:@"AuthMode"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        //	[[RepliconServiceManager loginService]sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:self];
        
        RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            NSString *openUrl=[[response objectForKey:@"response"] objectForKey:@"RequestUrl"];
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
        }
        else
        {
            [delegate launchLoginViewController];
        }
        
    }
    else
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        NSString *message = [response objectForKey:@"Message"];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        [G2Util errorAlert:@"" errorMessage:message];
    }
}


-(void)handleCompleteSAMLFlowAPIURLResponse:(id)response
{
    NSString *urlAddress= [[NSUserDefaults standardUserDefaults] objectForKey:@"CompleteSAMLFlowURLWithGUID"];
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:urlAddress]];
    
    
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
	[[NSUserDefaults standardUserDefaults] setObject:headers forKey:@"SSOCookies"];
    DLog(@"%@",headers);
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
    G2LoginService *loginService=[G2RepliconServiceManager loginService];
    [[G2TransitionPageViewController getInstance] setDelegate: loginService];
    
    
    NSEnumerator *enumerator = [cookies objectEnumerator];
    
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"];
    NSHTTPCookie *cookie;
    
    while (cookie = [enumerator nextObject]) {
        if ([[cookie name] isEqualToString:@"CURRENTUSER"])
        {
            
            userName=[cookie value];
        }
        
    }
    
    
    [loginService sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:loginService forUsername:userName];
}

-(void)handleUserByLoginNameResponse:(id)response
{
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
	if (response!=nil && [(NSMutableArray *)response count]!=0) {
		
		NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
        NSDictionary *dctlanguage=[[[[response objectAtIndex:0] objectForKey:@"Relationships"] objectForKey:@"Language"]objectForKey:@"Properties"];
        [standardUserDefaults setObject:[dctlanguage objectForKey:@"Name"] forKey:@"LanguageName"]; //US3518 Ullas M L
        [standardUserDefaults setObject:[dctlanguage objectForKey:@"ISOName"] forKey:@"ISOName"]; //US3518 Ullas M L
        DLog(@"%@",[[[response objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsPendingApproval"]);
        [standardUserDefaults setObject:[[[response objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsPendingApproval"] forKey:@"NumberOfTimesheetsPendingApproval"];
        [standardUserDefaults setObject:[[[response objectAtIndex:0]objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsWithPreviousApprovalAction"] forKey:@"NumberOfTimesheetsWithPreviousApprovalAction"];
        
         
		[standardUserDefaults setObject:[[response objectAtIndex:0]objectForKey:@"Identity"] forKey:@"UserID"];
		[standardUserDefaults synchronize];
			//To clear the DB when user relogins..................
		G2LoginModel *loginModel = [[G2LoginModel alloc]init]; 		
		NSMutableArray *userDBDetailsArry=[loginModel getAllUserInfoFromDb];
		
		if (userDBDetailsArry!=nil && [userDBDetailsArry count]>0) {
			NSDictionary *userDetails = [userDBDetailsArry objectAtIndex:0];
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                if ([[[response objectAtIndex: 0]objectForKey: @"Identity"] isEqualToString: [userDetails objectForKey:@"identity"]])
                {
                    DLog(@"if same identity and same company");
                    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
                    [myDB deleteFromTable:@"login" inDatabase:@""];
                    NSMutableDictionary *loginPreferencesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[userDetails objectForKey:@"rememberCompany"],@"rememberCompany",
                                                                 [userDetails objectForKey:@"rememberUser"],@"rememberUser",
                                                                 [userDetails objectForKey:@"rememberPassword"],@"rememberPassword",
                                                                 [userDetails objectForKey:@"rememberPwdStartDate"],@"rememberPwdStartDate",
                                                                 nil];
                    [loginModel insertUserInfoToDataBase:response WithLoginPreferences:loginPreferencesDict];
                }else {
                    [G2Util flushDBInfoForOldUser:YES];
                    [loginModel insertUserInfoToDataBase: response];
                }
            }
            else
            {
                if ([[[response objectAtIndex: 0]objectForKey: @"Identity"] isEqualToString: [userDetails objectForKey:@"identity"]]
                    && [[userDetails objectForKey:@"company"] isEqualToString: [dict objectForKey:@"companyName"]])
                {
                    DLog(@"if same identity and same company");
                    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
                    [myDB deleteFromTable:@"login" inDatabase:@""];
                    NSMutableDictionary *loginPreferencesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[userDetails objectForKey:@"rememberCompany"],@"rememberCompany",
                                                                 [userDetails objectForKey:@"rememberUser"],@"rememberUser",
                                                                 [userDetails objectForKey:@"rememberPassword"],@"rememberPassword",
                                                                 [userDetails objectForKey:@"rememberPwdStartDate"],@"rememberPwdStartDate",
                                                                 nil];
                    [loginModel insertUserInfoToDataBase:response WithLoginPreferences:loginPreferencesDict];
                }else {
                    [G2Util flushDBInfoForOldUser:YES];
                    [loginModel insertUserInfoToDataBase: response];
                }
            }
            
			
		}
		else {
			[loginModel insertUserInfoToDataBase:response];
		}
		
		[userDBDetailsArry removeAllObjects];

		//ravi - to handle the session timeout. Once the user is logged in remove the credentials from the userdefaults. 
		//If authentication challenge is called and there are no credentials info in userdefaults then the login page is shown.
		//[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"credentials"];
		
		
			//added following condition to implement Sync adjustments
//		if ([Util shallExecuteQuery:GENERAL_SUPPORTING_DATA_SECTION]) {
//            [[NSNotificationCenter defaultCenter] addObserver:self 
//                                                     selector:@selector(requestUserPermissions) name:USER_PREFERENCES_RECEIVED_NOTIFICATION object:nil];
//			[[RepliconServiceManager supportDataService] sendRequestToGetUserPreferences];
//            [[RepliconServiceManager supportDataService] sendRequestToGetDisclaimerPreferences];
//		}
//		else {
//            
//            [self requestSystemPreferences:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"value"] ];
//            
////			[[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
//		}
		
			
        if ([G2Util shallExecuteQuery:GENERAL_SUPPORTING_DATA_SECTION] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            [self sendMultipleRequestForLoginWithDelegate:self];
        }
        else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
             [self requestSystemPreferences:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"value"] ];
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
        }
		
	}else {
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	}
}


-(void)handleMergedLoginResponse:(id)response
{
    NSString *responseStatus = [[response objectForKey: @"response"] objectForKey:@"Status"];
	if([responseStatus isEqualToString:@"OK"]) 
    {
        NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
        
        
        
        if (response!=nil && [(NSMutableArray *)response count]!=0) 
        {
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isSuccessLogin"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                //Handle response for login by user name
                [self handleUserByLoginNameResponse:[NSArray arrayWithObject:[responseArray objectAtIndex:0]]];
            }
           
            
            if ([G2Util shallExecuteQuery:GENERAL_SUPPORTING_DATA_SECTION] && [responseArray count]>1) 
            {
                //Handle user preferences
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                    [[G2RepliconServiceManager supportDataService] handleUserPreferencesResponse: [responseArray objectAtIndex:1]];
                }
                else
                {
                    [[G2RepliconServiceManager supportDataService] handleUserPreferencesResponse: [responseArray objectAtIndex:0]];
                }
                
                //Handle Disclaimer preference
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                     [[G2RepliconServiceManager supportDataService] handleDisclaimerPreferencesResponse: [responseArray objectAtIndex:2]];
                }
                else
                {
                     [[G2RepliconServiceManager supportDataService] handleDisclaimerPreferencesResponse: [responseArray objectAtIndex:1]];
                }
               
                
                //Handle user permissions
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                      [[G2RepliconServiceManager permissionsService] handleUserPermissonsResponse:[responseArray objectAtIndex:3] ];
                }
                else
                {
                      [[G2RepliconServiceManager permissionsService] handleUserPermissonsResponse:[responseArray objectAtIndex:2] ];
                }

              
                
                if(![self requestSystemPreferences:nil])
                {
                    return;
                }
                
                //Handle system preferences
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                     [[G2RepliconServiceManager supportDataService] handleSystemPreferencesResponse:[responseArray objectAtIndex:4]];
                }
                else
                {
                    [[G2RepliconServiceManager supportDataService] handleSystemPreferencesResponse:[responseArray objectAtIndex:3]];
                }
               
                
                //Handle time off codes
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                     [[G2RepliconServiceManager supportDataService] handleTimeOffResponse:[responseArray objectAtIndex:5]];
                }
                else
                {
                     [[G2RepliconServiceManager supportDataService] handleTimeOffResponse:[responseArray objectAtIndex:4]];
                }
               
                
                //Handle udf's
                if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                    [[G2RepliconServiceManager timesheetService] handlePermissionBasedTimesheetUDFsResponse:[NSMutableArray arrayWithObjects:[responseArray objectAtIndex:6],[responseArray objectAtIndex:7],[responseArray objectAtIndex:8],[responseArray objectAtIndex:9], nil]];
                }
                else
                {
                     [[G2RepliconServiceManager timesheetService] handlePermissionBasedTimesheetUDFsResponse:[NSMutableArray arrayWithObjects:[responseArray objectAtIndex:5],[responseArray objectAtIndex:6],[responseArray objectAtIndex:7],[responseArray objectAtIndex:8], nil]];
                }
               
            }
            
            else
            {
                if(![self requestSystemPreferences:nil])
                {
                    return;
                }
            }
            
            
            
        }
    
    }
    

    
    else 
    {
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) 
        {
            [G2Util errorAlert:@"" errorMessage:value];
		}
        else 
        {
            
            [G2Util errorAlert:@"" errorMessage:message];
		}

	}

    
    [G2SupportDataModel updateLastSyncDateForServiceId:GENERAL_SUPPORTING_DATA_SECTION];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
    
}

- (void) processingError:(NSError *) error {
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showConnectionError];
		return;
	}
	//[Util errorAlert:@"Connection failed" errorMessage:[error localizedDescription]];
	
	/*UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle: nil 
										message: RPLocalizedString(InvaliDLogin, InvaliDLogin)
										delegate: self 
										cancelButtonTitle: RPLocalizedString( @"Support", @"Support") 
										otherButtonTitles: NSLocalizedString (@"OK", @"OK"), nil];*/
	UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(InvaliDLogin,InvaliDLogin) delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];

	[loginAlertView show];
	
	
	
}


-(void)requestUserPermissions{
	[[G2RepliconServiceManager permissionsService]sendRequestToGetAllUserPermissionsWithDelegate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:USER_PREFERENCES_RECEIVED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(requestSystemPreferences:) name:USER_PERMISSIONS_RECEIVED_NOTIFICATION object:nil];
}

-(BOOL )requestSystemPreferences:(id )note
{
//    BOOL isDownloadingSupportData=FALSE;
//    if ([note isKindOfClass:[NSNotification class]])
//    {
//        
//        NSDictionary *theData = [note userInfo];
//        isDownloadingSupportData=[[theData objectForKey:@"value"] boolValue];
//    }
//    else
//    {
//        isDownloadingSupportData=[[note objectForKey:@"value"] boolValue];
//    }
	
   
//    if (isDownloadingSupportData) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_PERMISSIONS_RECEIVED_NOTIFICATION object:nil];
//    }
	
	G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
           NSArray *allLicencesArray=[permissionsModel getAllLicencesInfoFromDb];
    
    if ([allLicencesArray count]==0) 
    {
        [G2Util errorAlert:ErrorTitle errorMessage:UserHaveNoRelevantPermissions];
		[self removeUserInformationWithCookies];
        [G2Util flushDBInfoForOldUser:NO];
		[[[UIApplication sharedApplication] delegate] performSelector: @selector(stopProgression)];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloadCompanyView)];
        }
        else
        {
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
        }
		return FALSE;

    }
      RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appdelegate.hasTimesheetLicenses=FALSE;
    //FOR APPROVAL TIMESHEETS
    for (int i=0; i<[allLicencesArray count]; i++) 
    {
        NSDictionary *licenceDict=[allLicencesArray objectAtIndex:i];
        NSString *licenceName=[licenceDict objectForKey:@"licenceName"];
        if ([licenceName isEqualToString:@"Time Bill"]) 
        {
            appdelegate.hasTimesheetLicenses=TRUE;
            break;
        }   
        else if ([licenceName isEqualToString:@"Time Attend"]) 
        {
            appdelegate.hasTimesheetLicenses=TRUE;
            break;
        }  
        else if ([licenceName isEqualToString:@"Time Cost"]) 
        {
            appdelegate.hasTimesheetLicenses=TRUE;
            break;
        }  
    }

	BOOL _useTimeSheet = [permissionsModel checkUserPermissionWithPermissionName:@"UseTimesheet"];
	BOOL _projectExpense = [permissionsModel checkUserPermissionWithPermissionName:@"ProjectExpense"];
	BOOL _nonProjectExpense = [permissionsModel checkUserPermissionWithPermissionName:@"NonProjectExpense"];
	
       BOOL _approver = FALSE;
    if (appdelegate.hasTimesheetLicenses) 
    {
        _approver = [permissionsModel checkUserPermissionWithPermissionName:@"ApprovalMenu"];
        int countApprovalAction=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsWithPreviousApprovalAction" ]intValue] ;
        int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
        
        if (_approver)
        {
            if ((countApprovalAction>0  ||  badgeValue>0) )
            {
                _approver=TRUE;
            }
            else 
            {
                _approver=FALSE;
            }

        }
        
    }
	
	
	if (!_useTimeSheet && !( _projectExpense || _nonProjectExpense)  && !_approver) {
		[G2Util errorAlert:ErrorTitle errorMessage:RPLocalizedString(UserHaveNoRelevantPermissions, "") ];
		[self removeUserInformationWithCookies];
        [G2Util flushDBInfoForOldUser:NO];
		[[[UIApplication sharedApplication] delegate] performSelector: @selector(stopProgression)];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloadCompanyView)];
        }
        else
        {
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
        }
		return FALSE;
	}else {
	}
	
	
/*	if (isDownloadingSupportData) 
    {
        
        [self userTimeOffNotification];
        return;
    }
	
    [[RepliconServiceManager supportDataService]sendRequestToGetSystemPerferencesWithDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemPreferencesNotification) name:SYSTEM_PREFERENCES_RECEIVED_NOTIFICATION object:nil]; */
    
    //DE10627//JUHI
    //delete projects and clients and add none projects based on permissions.
	[G2SupportDataModel deleteAddNoneProjectAndClient];
	
	return TRUE;
}
-(void)systemPreferencesNotification{
	DLog(@"systemPreferencesNotification:::LoginViewController");
    
    
   
    
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:SYSTEM_PREFERENCES_RECEIVED_NOTIFICATION object:nil];
    
    
    [[G2RepliconServiceManager supportDataService] sendRequestToGetUserTimeOffs:[G2RepliconServiceManager supportDataService]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(userTimeOffNotification) name:USER_TIME_OFF_CODES_RECEIVED_NOTIFICATION object:nil];
    
	
	
	//delete projects and clients and add none projects based on permissions.
	[G2SupportDataModel deleteAddNoneProjectAndClient];
	
}




-(void)userTimeOffNotification
{
    //Update lastSynctime for general supporting data.
    [G2SupportDataModel updateLastSyncDateForServiceId:GENERAL_SUPPORTING_DATA_SECTION];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_TIME_OFF_CODES_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
}


-(void)handleFreeTrialResponse:(id)response{
	if (response != nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:FREE_TRIAL_SIGN_UP_NOTIFICATION object:nil];
	}
	
}
-(void)handleResetPasswordResponse:(id)response{
	if (response != nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:RESET_PASSWORD_NOTIFICATION object:nil];
	}
}

@end
