//
//  CalculatePunchTotalService.m
//  CloudClock
//
//  Created by Harish Subramani on 17/12/14.
//  Copyright (c) 2014 Mamatha Nalla. All rights reserved.
//

#import "CalculatePunchTotalService.h"

@implementation CalculatePunchTotalService


#pragma mark -
#pragma mark ServiceURL Response Handling


-(void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
        
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        if (errorDict!=nil)
        {
            
        }
        
        else
        {
            
        }
        
    }
}

#pragma mark -
#pragma mark ServiceURL Error Handling
- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
    if (applicationState == Foreground)
    {
         [Util handleNSURLErrorDomainCodes:error];
    }

   
}


/************************************************************************************************************
 @Function Name   : RecalculateScriptData
 @Purpose         : Called to Recalculate Script Data.
 @return          : nil
 *************************************************************************************************************/

-(void)sendRequestToRecalculateScriptDataForuserUri:(NSString *)userUri WithDate:(NSDictionary *)date
{
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     userUri,@"uri",
                                     [NSNull null],@"loginName",
                                     [NSNull null],@"parameterCorrelationId",nil];

   
    
    NSMutableDictionary *containerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNull null],@"uri",
                                          userDict,@"user",
                                          date,@"date",nil];
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      containerDict,@"timesheet",nil];
    
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"RecalculateScriptData"]];
    
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];

    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"RecalculateScriptData"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}



@end
