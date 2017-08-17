//
//  TimeoffService.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 15/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"
#import "ServiceUtil.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "JsonWrapper.h"
#import "Util.h"
#import "SupportDataModel.h"
#import"BaseService.h"
#import"Constants.h"
#import "TimeoffModel.h"
#import "SpinnerDelegate.h"

@interface TimeoffService : BaseService

{
    unsigned int totalRequestsSent;
	unsigned int totalRequestsServed;
    TimeoffModel *timeoffModel;
    id __weak newTimeoffDelegate;
 
}
@property(nonatomic, strong) TimeoffModel *timeoffModel;
@property(nonatomic, assign) BOOL didSuccessfullyFetchTimeoff;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (id)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate;

-(void)fetchTimeoffData:(id)_delegate isPullToRefresh:(BOOL)isPullToRefresh;

-(void)fetchNextRecentTimeoffData:(id)_delegate;
-(void)fetchTimeoffCompanyHolidaysData:(id)_delegate;
-(void)fetchTimeoffEntryDataForBookedTimeoff:(NSString *)timeoffUri withTimeSheetUri:(NSString *)timesheetUri;
-(void)sendRequestToSaveBookedTimeOffDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray andUdfArray:(NSMutableArray *)udfArray withDelegate:(id)delegate;
-(void)sendRequestToDeleteTimeoffDataForURI:(NSString *)timeoffUri;
//-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withDelegate:(id)delegate;
-(void)sendRequestToBookedTimeOffBalancesDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray withDelegate:(NavigationFlow)delegate;
-(void)sendRequestToResubmitBookedTimeOffDataForTimeoffURI:(NSString *)timesheetURI withEntryArray:(NSMutableArray *)timeoffEntryObjectArray andUdfArray:(NSMutableArray *)udfArray withDelegate:(id)delegate;

- (void) serverDidRespondWithResponse:(id) response;
@end
