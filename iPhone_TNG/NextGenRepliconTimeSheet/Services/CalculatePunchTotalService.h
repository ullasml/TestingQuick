//
//  CalculatePunchTotalService.h
//  CloudClock
//
//  Created by Harish Subramani on 17/12/14.
//  Copyright (c) 2014 Mamatha Nalla. All rights reserved.
//

#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"

@interface CalculatePunchTotalService : BaseService

-(void)sendRequestToRecalculateScriptDataForuserUri:(NSString *)userUri WithDate:(NSDictionary *)date;

@end
