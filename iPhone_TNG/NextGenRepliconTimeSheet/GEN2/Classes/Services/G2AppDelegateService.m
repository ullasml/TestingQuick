//
//  AppDelegateService.m
//  Replicon
//
//  Created by Dipta Rakshit on 3/19/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2AppDelegateService.h"
#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"

@implementation G2AppDelegateService

-(void)sendRequestToLoadUser
{
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
   
    NSArray *array =nil;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {     
        array = [NSArray arrayWithObjects:[dict objectForKey:@"userName"],nil];
    }
    else 
    {
       
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            array = [NSArray arrayWithObjects: [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"],nil];
        }
        else
        {
             array = [NSArray arrayWithObjects: [[NSUserDefaults standardUserDefaults] objectForKey:@"TempSSOLoginName"],nil];
        }
        
    }

    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",@"UserByLoginName",@"QueryType",@"Replicon.Domain.User",@"DomainType",array,@"Args",nil];
    NSArray *arr = [NSArray arrayWithObject:dict1];
    NSError *error;
    NSString *str = [JsonWrapper writeJson:arr error:&error];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"UserByLoginName"]];
	[self setServiceDelegate: self];
	[self executeRequest];
    
}

-(void)handleUserDownloadContent:(id)response
{
    if (response!=nil && [(NSMutableArray *)response count]!=0) 
    {
        NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
        if (status!=nil && [status isEqualToString:@"OK"]) {		  
            NSMutableArray *valueArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
            if(valueArray != nil) 
            {
                NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
                [standardUserDefaults setObject:[[[valueArray objectAtIndex:0] objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsPendingApproval"] forKey:@"NumberOfTimesheetsPendingApproval"];
                [standardUserDefaults setObject:[[[valueArray objectAtIndex:0]  objectForKey:@"Properties"]objectForKey:@"NumberOfTimesheetsWithPreviousApprovalAction"] forKey:@"NumberOfTimesheetsWithPreviousApprovalAction"];
                [standardUserDefaults synchronize];
                
            }
            
            
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:APPDELEGATE_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object:nil];
}

- (void) serverDidRespondWithResponse:(id) response
{
  
    
	if (response != nil) 
    {
        
        NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) 
        {


                [self handleUserDownloadContent:response];
            
            

            
        }
        
        else 
        {
            totalRequestsServed++;
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            [G2Util errorAlert:@"" errorMessage:message];
            
        }
    }
}

- (void) serverDidFailWithError:(NSError *) error
{
	totalRequestsServed++;
    //Need to revisit
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];	
	if (totalRequestsServed == totalRequestsSent)	{
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
			[G2Util showOfflineAlert];
			return;
		}
        
        [self showErrorAlert:error];
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
    
    if (!appdelegate.isAlertOn) 
    {
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
                [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:SESSION_EXPIRED];
            }
            
        }
        else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:G2PASSWORD_EXPIRED];
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
        }
        else
        {
            [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
        }
        
    }
    
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED] ||  [appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) 
    {
        appdelegate.isAlertOn=TRUE;
    }
    else
    {
        appdelegate.isAlertOn=FALSE;
    }
    
    
}

@end
