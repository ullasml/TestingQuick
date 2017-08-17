//
//  FreeTrialService.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 28/04/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "FreeTrialService.h"
#import "AppDelegate.h"
#import "RepliconServiceManager.h"
#import "MobileMonitorURLProvider.h"
#import <repliconkit/AppConfig.h>

@interface FreeTrialService()
@property (nonatomic, strong) MobileMonitorURLProvider *mobileMonitorURLProvider;
@property (nonatomic, strong) AppConfig *appConfig;
@end

@implementation FreeTrialService
@synthesize receivedData;
@synthesize serviceIDNumber;

- (instancetype)initWithMobileMonitorURLProvider:(MobileMonitorURLProvider *)mobileMonitorURLProvider
                                       appConfig:(AppConfig *)appConfig

{
    if (self = [super init]) {
        self.mobileMonitorURLProvider = mobileMonitorURLProvider;
        self.appConfig = appConfig;
    }
    
    return self;
}



-(void)sendRequestToValidateEmailServiceForString:(NSString *)emailAddress
{
    totalRequestsServed=0;
    totalRequestsSent=0;
    totalRequestsSent++;
    
    
    
    
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    if ([self.appConfig getNewMarketingServices]) {
        urlStr = [NSString stringWithFormat:@"%@/%@",[self.mobileMonitorURLProvider baseUrlForMobileMonitor],[[AppProperties getInstance] getServiceURLFor: @"CheckEmailExistence_NewMarketingService"]];
    } else {
        urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor: @"CheckEmailExistence"]];
    }
    
    
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
    if ([self.appConfig getNewMarketingServices]) {
        urlStr = [NSString stringWithFormat:@"%@/%@",[self.mobileMonitorURLProvider baseUrlForMobileMonitor],[[AppProperties getInstance] getServiceURLFor: @"GetCompanyKey_NewMarketingService"]];
    } else {
        urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor: @"GetCompanyKey"]];
    }
    
    

    
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
    if ([self.appConfig getNewMarketingServices]) {
        urlStr = [NSString stringWithFormat:@"%@/%@",[self.mobileMonitorURLProvider baseUrlForMobileMonitor],[[AppProperties getInstance] getServiceURLFor: @"CreateMobileInstance_NewMarketingService"]];
    } else {
        urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor: @"CreateMobileInstance"]];
    }
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:[NSString stringWithFormat:@"first_name=%@&last_name=%@&&company=%@&businessphone=%@&password=%@&businessemail=%@",[dataDict objectForKey:@"first_name"], [dataDict objectForKey:@"last_name"], [dataDict objectForKey:@"company"], [dataDict objectForKey:@"businessphone"], [dataDict objectForKey:@"password"], [dataDict objectForKey:@"businessemail"]] forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestForFreeTrialWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ExecuteCreateTrial"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}



#pragma mark - ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
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
                NSString *serviceURL = [response objectForKey:@"serviceURL"];
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:EMAIL_VALIDATION_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
            [[NSNotificationCenter defaultCenter]postNotificationName:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
            [[NSNotificationCenter defaultCenter]postNotificationName:SIGNUP_DATA_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
        }
        else
        {
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            if ([_serviceID intValue]== SignUpForFreeTrial_Service_ID_112)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SIGNUP_DATA_RECIEVED_NOTIFICATION  object:[response objectForKey:@"response"]];
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



@end
