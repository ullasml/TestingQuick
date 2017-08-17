//
//  PunchHistoryService.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 5/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "BaseService.h"
#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import "SupportDataModel.h"
#import"BaseService.h"
#import"Constants.h"
#import "PunchHistoryModel.h"
#import "TeamTimePunchObject.h"

@interface PunchHistoryService : BaseService
{
    unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;
    PunchHistoryModel *punchHistoryModel;
    
}
@property(nonatomic, strong) PunchHistoryModel *punchHistoryModel;
-(void)fetchPunchHistoryDataForDate:(NSDate *)date;
-(void)sendEditOrAddPunchRequestServiceForDataDict:(TeamTimePunchObject *)obj editType:(NSString*)BtnClicked fromMode:(NSString *)fromMode andTimesheetURI:(NSString *)timesheetURI;
-(void)deletePunchRequestServiceForPunchUri:(NSString *)uri;
-(void)fetchNextActivityWithSearchText:(NSString *)textSearch forUser:(NSString*)userUri andDelegate:(id)delegate;
-(void)sendRequestToGetAllTimeSegmentsForTimesheet:(NSString *)timesheetUri WithStartDate:(NSDate *)startDate withDelegate:(id)_delegate andApprovalsModelName:(NSString *)approvalsModuleName;
@end
