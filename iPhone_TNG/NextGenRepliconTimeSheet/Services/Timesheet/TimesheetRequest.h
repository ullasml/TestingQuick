//
//  TimesheetRequest.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 03/02/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


@interface TimesheetRequest : NSObject
- (AFHTTPRequestOperation *)fetchTimeSheetSummaryDataForTimesheet:(NSString *)timesheetUri isFreshDataDownload:(BOOL)isFreshDataDownload;


-(AFHTTPRequestOperation *)sendRequestToSubmitWidgetTimesheetWithTimesheetURI:(NSString *)timesheetURI comments:(NSString*)comment hasAttestationPermission:(BOOL)hasAttestationPermission andAttestationStatus:(BOOL)isAttestationStatus;
-(AFHTTPRequestOperation *)sendRequestToReopenWidgetTimesheetWithTimesheetURI:(NSString *)timesheetURI comments:(NSString *)comments
;

-(AFHTTPRequestOperation *)saveWidgetTimeSheetData:(NSMutableDictionary *)queryDict;

-(AFHTTPRequestOperation *)sendRequestToFetchBreaksWithTimesheetURI:(NSString *)timesheetURI;

-(NSURLRequest *)constructOperationForURLRequest:(NSDictionary *)queryDict withServiceName:(NSString *)serviceName;
-(NSMutableDictionary *)widgetTimesheetSaveRequestProvider:(NSMutableArray *)timesheetDataArray andHybridWidgetTimeSheetData:(NSMutableArray *)hybridTimesheetDataArray andTimesheetUri:(NSString *)timesheetUri andTimesheetFormat:(NSString *)timesheetFormat;

-(AFHTTPRequestOperation *)fetchTimeSheetUpdateData;
-(AFHTTPRequestOperation *)fetchNextRecentTimeSheetData;

-(AFHTTPRequestOperation *)GetOrCreateFirstTimesheets;

-(NSMutableArray *)constructTimeEntriesArrForSavingWidgetTimesheet:(NSMutableArray *)timesheetDataArray andTimeSheetFormat:(NSString *)timesheetFormat andIsHybridTimesheet:(BOOL)isHybridTimesheet;

-(NSMutableDictionary *)constructWidgetTimeSheetTimeEntries:(NSMutableArray *)timesheetDataArray andHybridWidgetTimeSheetData:(NSMutableArray *)hybridTimesheetDataArray andTimesheetUri:(NSString *)timesheetUri andTimeSheetFormat:(NSString *)timesheetFormat;

@end
