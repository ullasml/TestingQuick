//
//  AttendanceService.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import "SupportDataModel.h"
#import"BaseService.h"
#import"Constants.h"
#import "AttendanceModel.h"
#import "TimesheetModel.h"

@interface AttendanceService : BaseService
{
    unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;
    AttendanceModel *attendanceModel;
}

@property(nonatomic, strong) AttendanceModel *attendanceModel;
@property(nonatomic, strong) TimesheetModel *timesheetModel;


-(void)fetchProjectsBasedOnclientsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchTasksBasedOnProjectsWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate;
-(void)fetchNextTasksBasedOnProjectsWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri andDelegate:(id)delegate;
-(void)fetchBreakWithSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextBreakWithSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchFirstClientsAndProjectsWithClientSearchText:(NSString *)clientText withProjectSearchText:(NSString *)projectText andDelegate:(id)delegate;
-(void)fetchNextClientsWithSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextProjectsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchFirstProjectsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchFirstClientsWithSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextProjectsBasedOnclientsWithSearchText:(NSString *)textSearch withClientUri:(NSString *)clientUri andDelegate:(id)delegate;
-(void)fetchBillingRateBasedOnProjectWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate;
-(void)fetchNextBillingRateBasedOnProjectWithSearchText:(NSString *)textSearch withProjectUri:(NSString *)projectUri taskUri:(NSString*)taskUri andDelegate:(id)delegate;
-(void)fetchActivityWithSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)fetchNextActivityWithSearchText:(NSString *)textSearch andDelegate:(id)delegate;
-(void)sendRequestPunchDataToServiceForDataDict:(NSMutableDictionary *)dataDict actionType:(NSString *)punchType locationDict:(NSMutableDictionary *)locationDict withDelegate:(id)delegate;


-(void)sendRequestToGetLastPunchDataToServiceForuserUri:(NSString *)userUri ;

-(void)handleClientsAndProjectsDownload:(id)response;
-(void)handleFirstClientsDownload:(id)response;
-(void)handleFirstProjectsDownload:(id)response;
-(void)handleNextClientsDownload:(id)response;
-(void)handleNextProjectsDownload:(id)response;
-(void)handleProjectsBasedOnClientsResponse:(id)response;
-(void)handleTasksBasedOnProjectsResponse:(id)response;
-(void)handleNextTasksBasedOnProjectsResponse:(id)response;
-(void)handleNextProjectsBasedOnClientDownload:(id)response;
-(void)handleBillingRateBasedOnProjectDownload:(id)response;
-(void)handleNextBillingRateBasedOnProjectDownload:(id)response;
-(void)handleActivityBasedOnTimesheetDownload:(id)response;
-(void)handleNextActivityBasedOnTimesheetDownload:(id)response;
-(void)handleLastPunchData:(id)response;

@end
