//
//  LockedInOutTimesheetService.h
//  Replicon
//
//  Created by Dipta Rakshit on 5/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2BaseService.h"
#import "G2ServiceUtil.h"
#import "G2RequestBuilder.h"
#import "G2AppProperties.h"
#import "JsonWrapper.h"
#import "G2Util.h"
#import "G2SupportDataModel.h"
#import"G2BaseService.h"
#import"G2Constants.h"
#import "G2TimesheetModel.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeOffEntryObject.h"


@interface G2LockedInOutTimesheetService : G2BaseService {
	G2TimesheetModel *timesheetModel;
	G2SupportDataModel *supportDataModel;
	
	int totalRequestsSent;
	int totalRequestsServed;
    
    
    //BOOL isFromNewPopUpForTimeOff;
}
@property(nonatomic,assign) int totalRequestsSent;
@property(nonatomic,assign) int totalRequestsServed;
//@property(nonatomic,assign) BOOL isFromNewPopUpForTimeOff;



-(void)handleGetTimesheetFromApiResponse:(id)response; 
-(void)getTimesheetFromApiAndAddTimeEntry:(G2TimeSheetEntryObject *)entryObj;





-(void)handleEditedTimeEntryResponse:(id)response;




-(void)handleSaveNewTimeEntryResponse:(id)response;

-(void)sendRequestToFetchTimeSheetByDate:(NSDate *)date;
-(void) fetchTimeSheetUSerDataForDate:(id)_delegate andDate:(NSDate *)date;

@property(nonatomic, strong) G2TimesheetModel *timesheetModel;

-(void)handlePunchClockGetTimesheetFromApiResponse:(id)response;
-(void)sendRequestToAddNewTimeEntryWithObjectForLockedInOutTimesheets:(G2TimeSheetEntryObject *)entryObject;
-(void)sendRequestToEditTheTimeEntryDetailsWithUserDataForLockedInOutTimesheets:(G2TimeSheetEntryObject *)_timeEntryObject;
-(void)showErrorAlert:(NSError *) error;
@end
