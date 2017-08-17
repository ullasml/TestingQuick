//
//  ShiftsService.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 20/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "BaseService.h"
#import "ShiftsModel.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import"Constants.h"

@interface ShiftsService : BaseService
{
    unsigned int                                totalRequestsSent;
	unsigned int                                totalRequestsServed;
   
}


-(void)sendRequestShiftToServiceForDataDict:(NSMutableDictionary *)dataDict;
-(void)fetchTimeoffDataForStartDate:(NSDate*)startDate andEndDate:(NSDate *)endDate andShiftId:(NSString *)shiftId;
-(void)fetchOnlyBulkGetUserHolidaySeriesForStartDate:(NSDate*)startDate andEndDate:(NSDate *)endDate andShiftId:(NSString *)shiftId;
@end
