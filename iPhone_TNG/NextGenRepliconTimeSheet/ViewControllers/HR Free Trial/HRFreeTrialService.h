//
//  HRFreeTrialService.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "BaseService.h"
#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import"Constants.h"

@interface HRFreeTrialService : BaseService<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

{
    unsigned int                                totalRequestsSent;
    unsigned int                                totalRequestsServed;
}
@property(nonatomic, retain) NSMutableData      *receivedData;
@property                    int                serviceIDNumber;

-(void)sendRequestToGetDetails:(NSString *)userName andloginURL:(NSString *)loginUrl;
-(void)sendRequestToGetPolicyUriFromSlug:(NSString *)slug andUserURI:(NSString *)userUri andloginURL:(NSString *)loginUrl;
-(void)sendRequestToAssignPolicySetToUser:(NSString *)userUri andPolicyUri:(NSString *)policyUri andloginURL:(NSString *)loginUrl;
-(void)sendrequestToFetchUserIntegrationDetailsWithDelegate:(NSDictionary * )userDetailsDict;
@end
