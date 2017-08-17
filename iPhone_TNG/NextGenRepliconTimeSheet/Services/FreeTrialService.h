//
//  FreeTrialService.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 28/04/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import"Constants.h"

@class AppConfig;
@class MobileMonitorURLProvider;

@interface FreeTrialService : BaseService <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

{
    unsigned int                                totalRequestsSent;
    unsigned int                                totalRequestsServed;
}
@property(nonatomic, retain) NSMutableData      *receivedData;
@property                    int                serviceIDNumber;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithMobileMonitorURLProvider:(MobileMonitorURLProvider *)mobileMonitorURLProvider
                                       appConfig:(AppConfig *)appConfig;
-(void)sendRequestToValidateEmailServiceForString:(NSString *)emailAddress;
-(void)sendRequestToValidateCompanyServiceForString:(NSString *)companyName;
-(void)sendRequestTosignUpServiceForDataDict:(NSMutableDictionary *)dataDict;
@end
