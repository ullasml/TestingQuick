//
//  TeamTimeService.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
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

#import "TeamTimeModel.h"
#import "TeamTimePunchObject.h"

@interface TeamTimeService : BaseService
{
    unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;
    TeamTimeModel *teamTimeModel;
    
}
@property(nonatomic, strong) TeamTimeModel *teamTimeModel;
-(void)fetchTeamTimeSheetDataForDate:(NSDate *)date;
-(void)sendEditOrAddPunchRequestServiceForDataDict:(TeamTimePunchObject *)obj editType:(NSString*)BtnClicked fromMode:(NSString *)fromMode andTimesheetURI:(NSString *)timesheetURI;
-(void)deletePunchRequestServiceForPunchUri:(NSString *)uri;
-(void)fetchActivityWithSearchText:(NSString *)textSearch forUser:(NSString*)userUri andDelegate:(id)delegate;
-(void)fetchNextActivityWithSearchText:(NSString *)textSearch forUser:(NSString*)userUri andDelegate:(id)delegate;
-(void)sendRequestToGetAuditTrialDataForUserUri:(NSString *)uri andDate:(NSDictionary *)dateDict;
-(void)sendRequestToGetAuditTrialDataForPunchWithUri:(NSString *)uri;
@end
