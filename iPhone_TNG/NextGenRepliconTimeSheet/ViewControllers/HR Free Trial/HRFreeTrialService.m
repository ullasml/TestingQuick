//
//  HRFreeTrialService.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "HRFreeTrialService.h"
#import "AppDelegate.h"
#import "ACSimpleKeychain.h"
#import "RepliconServiceManager.h"

@implementation HRFreeTrialService
@synthesize receivedData;
@synthesize serviceIDNumber;


/*
-(void)sendRequestToValidateEmailServiceForString:(NSString *)emailAddress
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor: @"CheckEmailExistence"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:[NSString stringWithFormat:@"email=%@",emailAddress] forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestForFreeTrialWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetTrialSignupInfoByEmail"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}


-(void)sendRequestToValidateCompanyServiceForString:(NSString *)companyName
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor: @"GetCompanyKey"]];
    
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:[NSString stringWithFormat:@"companyName=%@",companyName] forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestForFreeTrialWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetCompanyNameUniquenessDetails"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

-(void)sendRequestTosignUpServiceForDataDict:(NSMutableDictionary *)dataDict
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor: @"CreateMobileInstance"]];
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:[NSString stringWithFormat:@"first_name=%@&last_name=%@&&company=%@&businessphone=%@&password=%@&businessemail=%@",[dataDict objectForKey:@"first_name"], [dataDict objectForKey:@"last_name"], [dataDict objectForKey:@"company"], [dataDict objectForKey:@"businessphone"], [dataDict objectForKey:@"password"], [dataDict objectForKey:@"businessemail"]] forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestForFreeTrialWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ExecuteCreateTrial"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}
*/
-(void)sendRequestToGetDetails:(NSString *)userName andloginURL:(NSString *)loginUrl
{
    
    NSDictionary *userDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"uri",userName,@"loginName",[NSNull null],@"parameterCorrelationId", nil];
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObject:userDict forKey:@"user" ]];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",loginUrl,[[AppProperties getInstance] getServiceURLFor: @"GetUserByUserName"]];
    
    DLog(@"URL:::%@",urlStr);
    
	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
   
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDictAndBasicAuth:paramDict]];
   	
	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"GetUserByUserName"]];
	[self setServiceDelegate:self];
	[self executeRequest:loginUrl];
}

-(void)sendRequestToGetPolicyUriFromSlug:(NSString *)slug andUserURI:(NSString *)userUri andloginURL:(NSString *)loginUrl
{
    
    NSDictionary *queryDict = [NSDictionary dictionaryWithObject:slug forKey:@"policySetSlug"];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",loginUrl,[[AppProperties getInstance] getServiceURLFor: @"GetPolicyUriFromSlug"]];
    
    DLog(@"URL:::%@",urlStr);
    
	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
    
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDictAndBasicAuth:paramDict]];
   	
	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"GetPolicyUriFromSlug"]];
	[self setServiceDelegate:self];
	[self executeRequest:[NSDictionary dictionaryWithObjectsAndKeys:userUri,@"userUri",loginUrl,@"loginUrl", nil]];
}

-(void)sendRequestToAssignPolicySetToUser:(NSString *)userUri andPolicyUri:(NSString *)policyUri andloginURL:(NSString *)loginUrl
{
    
    NSDictionary *queryDict = [NSDictionary dictionaryWithObjectsAndKeys:userUri,@"userUri",policyUri,@"policySetUri", nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",loginUrl,[[AppProperties getInstance] getServiceURLFor: @"AssignPolicySetToUser"]];
    
    DLog(@"URL:::%@",urlStr);
    
	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
    
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDictAndBasicAuth:paramDict]];
   	
	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"AssignPolicySetToUser"]];
	[self setServiceDelegate:self];
	[self executeRequest];
}


-(void)sendrequestToFetchUserIntegrationDetailsWithDelegate:(NSDictionary * )userDetailsDict {
	

    
    
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									  [userDetailsDict objectForKey: @"company"],@"companyKey",
									  [userDetailsDict objectForKey: @"username"],@"loginName",
                                      [[AppProperties getInstance] getAppPropertyFor: @"SSOTargetURL"],@"targetUrl",
                                      nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString * urlStr=[NSString stringWithFormat:@"%@/%@",[Util getServerBaseUrl],[[AppProperties getInstance] getServiceURLFor: @"GetUserIntegrationDetails"]];

    DLog(@"URL:::%@",urlStr);
    
    [paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
    
	[self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    
    

        [self setServiceID: [NSNumber numberWithInt:999]];
 
	
	[self setServiceDelegate:self];
	[self executeRequest:userDetailsDict];
    
    
    
}


#pragma mark - ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {

        NSString *serviceURL = [response objectForKey:@"serviceURL"];

        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        if (errorDict!=nil)
        {
            BOOL isErrorThrown=FALSE;
            
            
            NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
            NSString *errorMsg=@"";
            if (notificationsArr!=nil && ![notificationsArr isKindOfClass:[NSNull class]])
            {
                for (int i=0; i<[notificationsArr count]; i++)
                {
                    
                    NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
                    
                    NSString *errorURI=[notificationDict objectForKey:@"failureUri"];
                    
                    if (![errorMsg isEqualToString:@""])
                    {
                        errorMsg=[NSString stringWithFormat:@"%@\n%@",errorMsg,[notificationDict objectForKey:@"displayText"]];
                        isErrorThrown=TRUE;
                    }
                    else
                    {
                        errorMsg=[NSString stringWithFormat:@"%@",[notificationDict objectForKey:@"displayText"]];
                        isErrorThrown=TRUE;
                        
                    }
                    
                    
                    
                    if ([errorURI isEqualToString:COMPANY_NOT_EXISTS_ERROR])
                    {
                        isErrorThrown=RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, COMPANY_NOT_EXISTS_ERROR_MESSAGE);
                        //[appDelegate launchCompanyViewController];
                        isErrorThrown=YES;
                        
                    }
                    else if ([errorURI isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR] || [errorURI isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_1])
                    {
                        errorMsg=RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE);
                        
                        
                        isErrorThrown= YES;
                    }
                    else if ([errorURI isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR] || [errorURI isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR_1])
                    {
                        errorMsg=RPLocalizedString(USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE, USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE);
                        
                        isErrorThrown= YES;
                    }
                    else if ([errorURI isEqualToString:COMPANY_DISABLED_ERROR] || [errorURI isEqualToString:COMPANY_DISABLED_ERROR_1])
                    {
                        errorMsg=RPLocalizedString(COMPANY_DISABLED_ERROR_MESSAGE, COMPANY_DISABLED_ERROR_MESSAGE);
                       
                        isErrorThrown= YES;
                    }
                    else if ([errorURI isEqualToString:USER_DISABLED_ERROR] || [errorURI isEqualToString:USER_DISABLED_ERROR_1])
                    {
                        errorMsg=RPLocalizedString(USER_DISABLED_ERROR_MESSAGE,@"");
                        
                        isErrorThrown= YES;
                    }
                    
                    else if ([errorURI isEqualToString:UNKNOWN_ERROR] || [errorURI isEqualToString:UNKNOWN_ERROR_1])
                    {
                        errorMsg=RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE);
                        isErrorThrown= YES;

                        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
                    }
                    
                    else if ([errorURI isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR] || [errorURI isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR_1])
                    {
                        errorMsg=RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE);
                        
                        isErrorThrown= YES;
                        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE) serviceURL:serviceURL];
                    }
                    
                    else if ([errorURI isEqualToString:PASSWORD_EXPIRED] || [errorURI isEqualToString:PASSWORD_EXPIRED])
                    {
                        errorMsg=RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE);
                        
                        
                        isErrorThrown= YES;
                    }
                    //implemented as per US7521
                    else if ([errorURI isEqualToString:PASSWORD_EXPIRED1] || [errorURI isEqualToString:PASSWORD_EXPIRED1])
                    {
                        errorMsg=RPLocalizedString(PASSWORD_EXPIRED_MESSAGE, PASSWORD_EXPIRED_MESSAGE);
                        
                        
                        isErrorThrown= YES;
                    }
                }
                
            }
            
            
           else
           {
               NSString *errorURI=[[errorDict objectForKey:@"details"] objectForKey:@"failureUri"];
               
               if ([errorURI isEqualToString:COMPANY_NOT_EXISTS_ERROR])
               {
                   errorMsg=RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, COMPANY_NOT_EXISTS_ERROR_MESSAGE);
                   //[appDelegate launchCompanyViewController];
                   isErrorThrown=YES;
                   
               }
               else if ([errorURI isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR] || [errorURI isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_1])
               {
                   errorMsg=RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE);
                   
                   
                   isErrorThrown= YES;
               }
               else if ([errorURI isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR] || [errorURI isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR_1])
               {
                   errorMsg=RPLocalizedString(USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE, USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE);
                   
                   isErrorThrown= YES;
               }
               else if ([errorURI isEqualToString:COMPANY_DISABLED_ERROR] || [errorURI isEqualToString:COMPANY_DISABLED_ERROR_1])
               {
                   errorMsg=RPLocalizedString(COMPANY_DISABLED_ERROR_MESSAGE, COMPANY_DISABLED_ERROR_MESSAGE);
                   
                   isErrorThrown= YES;
               }
               else if ([errorURI isEqualToString:USER_DISABLED_ERROR] || [errorURI isEqualToString:USER_DISABLED_ERROR_1])
               {
                   errorMsg=RPLocalizedString(USER_DISABLED_ERROR_MESSAGE,@"");
                   
                   isErrorThrown= YES;
               }
               
               else if ([errorURI isEqualToString:UNKNOWN_ERROR] || [errorURI isEqualToString:UNKNOWN_ERROR_1])
               {
                   errorMsg=RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE);
                   isErrorThrown= YES;
                   [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
               }
               
               else if ([errorURI isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR] || [errorURI isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR_1])
               {
                   errorMsg=RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE);
                   
                   isErrorThrown= YES;
                   [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE) serviceURL:serviceURL];
               }
               
               else if ([errorURI isEqualToString:PASSWORD_EXPIRED] || [errorURI isEqualToString:PASSWORD_EXPIRED])
               {
                   errorMsg=RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE);
                   
                   
                   isErrorThrown= YES;
               }
               //implemented as per US7521
               else if ([errorURI isEqualToString:PASSWORD_EXPIRED1] || [errorURI isEqualToString:PASSWORD_EXPIRED1])
               {
                   errorMsg=RPLocalizedString(PASSWORD_EXPIRED_MESSAGE, PASSWORD_EXPIRED_MESSAGE);
                   
                   
                   isErrorThrown= YES;
               }
               
               
           }
            
            
            if (!isErrorThrown)
            {
                errorMsg=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
                
            }
            if (errorMsg!=nil && ![errorMsg isKindOfClass:[NSNull class]])
            {
                [Util errorAlert:@"" errorMessage:errorMsg];
            }
            else
            {
                
                [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
            }
            
//            [[NSNotificationCenter defaultCenter]postNotificationName:EMAIL_VALIDATION_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
//            [[NSNotificationCenter defaultCenter]postNotificationName:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
            [[NSNotificationCenter defaultCenter]postNotificationName:SIGNUP_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
        }
        else
        {
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            if ([_serviceID intValue]== SignUpForFreeTrial_Service_ID_112)
            {
                [self handleSignUpDataReceived:response];
                
                
                return;
            }
            
            else if ([_serviceID intValue]== GetUserByUserName_145)
            {
                [self handleUserDetails:response];
                
                
                return;
            }
            
            else if ([_serviceID intValue]== GetPolicyUriFromSlug_146)
            {
                [self handlePolicyUriFromSlug:response];
                
                
                return;
            }
            
            else if ([_serviceID intValue]== AssignPolicySetToUser_147)
            {
                [self handleAssignPolicySetToUser:response];
                
                
                return;
            }

            else if ([_serviceID intValue]== 999)
            {
               [self handleUserIntegrationDetailsURLForFreeTrialResponse:response];
                
                
                return;
            }
        }
    }
    
}

#pragma mark - ServiceURL Error Handling
- (void)serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    
    totalRequestsServed++;
    
    
    if ([error code]==404)
    {
        if (applicationState == Foreground)
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
        }
        
        id errorUserInfoDict=[error userInfo];
        NSString *failedUrl=@"";

        if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
        {
            failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
            if (!failedUrl)
            {
                if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
                {
                    failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
                }

                if (!failedUrl)
                {
                    failedUrl=@"";
                }

            }
        }
        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:failedUrl];
    }
    
    else
    {
        if (applicationState == Foreground)
        {
          [Util handleNSURLErrorDomainCodes:error];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:EMAIL_VALIDATION_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    [[NSNotificationCenter defaultCenter]postNotificationName:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    [[NSNotificationCenter defaultCenter]postNotificationName:SIGNUP_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
}

-(void)handleSignUpDataReceived:(id)response
{
    NSString *loginUrl=[[response objectForKey:@"response"]objectForKey:@"loginUrl"];
   NSString  *loginName=[[response objectForKey:@"response"]objectForKey:@"loginName"];
    
    NSArray *componentsArr=[loginUrl componentsSeparatedByString:@"/"];
    
    
    NSString *finalURL=[NSString stringWithFormat:@"https://%@/services/",[componentsArr objectAtIndex:2]];
    
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain storeUsername:[[response objectForKey:@"response"] objectForKey:@"loginName"] password:[[response objectForKey:@"response"] objectForKey:@"password"] companyName:[[response objectForKey:@"response"] objectForKey:@"companyKey"] forService:@"repliconUserCredentials"]) {
        NSLog(@"**SAVED**");
    }
    
    [self sendRequestToGetDetails:loginName andloginURL:finalURL];
    
   
}

-(void)handleUserDetails:(id)response
{
//     NSDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
//     NSString *userUri=[responseDict objectForKey:@"uri"];
//    
//    NSString *url=[[response objectForKey:@"refDict"]objectForKey:@"params"];
//    
//    [self sendRequestToGetPolicyUriFromSlug:@"all-devices-access" andUserURI:userUri andloginURL:url];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:SIGNUP_DATA_RECIEVED_NOTIFICATION  object:[response objectForKey:@"response"]];
}

-(void)handlePolicyUriFromSlug:(id)response
{
    NSString *policyUri=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSString *userUri=[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"userUri"];
    NSString *loginUrl=[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"loginUrl"];
    
    [self sendRequestToAssignPolicySetToUser:userUri andPolicyUri:policyUri andloginURL:loginUrl];
    
}

-(void)handleAssignPolicySetToUser:(id)response
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SIGNUP_DATA_RECIEVED_NOTIFICATION  object:[response objectForKey:@"response"]];
}

-(void)handleUserIntegrationDetailsURLForFreeTrialResponse:(id)response
{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

    NSString *url=[[[response objectForKey:@"response"]objectForKey:@"d"]objectForKey:@"serviceEndpointRootUrl"];
    
    [defaults setObject:[[[response objectForKey:@"response"]objectForKey:@"d"] objectForKey:@"serviceEndpointRootUrl"] forKey:@"serviceEndpointRootUrl"];
    

    
    [defaults synchronize];
    
    
    NSDictionary *paramDict=[[response objectForKey:@"refDict"]objectForKey:@"params"];
   
    
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain storeUsername:[paramDict objectForKey:@"username"] password:[paramDict objectForKey:@"password"] companyName:[paramDict objectForKey:@"company"] forService:@"repliconUserCredentials"]) {
        NSLog(@"**SAVED**");
    }
    
    [self sendRequestToGetDetails:[paramDict objectForKey:@"username"] andloginURL:url];

   
 
    
    
}

@end
