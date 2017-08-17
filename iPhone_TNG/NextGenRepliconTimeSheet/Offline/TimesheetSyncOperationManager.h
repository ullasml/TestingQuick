//
//  TimesheetSyncOperationManager.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 2/24/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSyncOperationManager.h"
#import "TimesheetService.h"
#import "RequestPromiseClient.h"

@class ReachabilityMonitor;
@class TimesheetModel;


@interface TimesheetSyncOperationManager : NSObject <BaseSyncOperationManagerDelegate>


typedef NS_ENUM(NSInteger,ServiceName)
{
    WIDGET_TIMESHEET_SAVE_SERVICE,
    WIDGET_TIMESHEET_SUMMARY_FETCH_SERVICE,
    WIDGET_TIMESHEET_SUBMIT_SERVICE,
    WIDGET_TIMESHEET_RESUBMIT_SERVICE,
    WIDGET_TIMESHEET_REOPEN_SERVICE,

};

@property (nonatomic,assign) BOOL isTimesheetSyncInProcess;
@property(nonatomic,readonly) ReachabilityMonitor* reachabilityMonitor;
@property(nonatomic,readonly) TimesheetService* timesheetService;
@property(nonatomic,readonly) TimesheetModel *timesheetModel;
@property (nonatomic, readonly) id <RequestPromiseClient> client;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;

-(void)callServiceWithName:(ServiceName)_serviceName andTimeSheetURI:(NSString *)timeSheetURI;
-(void)executeRemainingActionsOnTimeSheetURI:(NSString *)timesheetURI;
-(NSMutableArray *)createTimesheetDataArray:(NSString *)timesheetURI forTimeSheetFormat:(NSString *)timeSheetFormat;
-(NSMutableArray *)createCurrentTimesheetEntryList:(NSString *)timesheetURI forTimeSheetFormat:(NSString *)timeSheetFormat;
-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryDate:(NSDate *)entryDate andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri isRowEditable:(BOOL)isRowEditable andTimeSheetUri:(NSString*)timesheetUri;

- (instancetype)initWithReachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor timeSheetModel:(TimesheetModel *)timeSheetModel timesheetService:(TimesheetService *)timesheetService client:(id <RequestPromiseClient>)client notificationCenter:(NSNotificationCenter *)notificationCenter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
@end
