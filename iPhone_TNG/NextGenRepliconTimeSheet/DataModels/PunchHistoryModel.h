//
//  PunchHistoryModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 5/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SQLiteDB.h"
#import "Util.h"
#import "Constants.h"

@interface PunchHistoryModel : NSObject


-(void)savepunchHistoryDataFromApiToDB:(NSMutableArray *)responseArray isFromWidget:(BOOL)isFromWidget approvalsModule:(NSString *)approvalsModule andTimeSheetUri:(NSString *)timesheetUri;
-(NSMutableArray *) getAllPunchesFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(void)deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule;
-(NSMutableArray *) getGroupedPunchesInfoFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(NSMutableArray *) getDistinctUsersFromDBISFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(NSMutableArray *) getDistinctActivitiesFromDBForPunchUser:(NSString *)punchUserUri isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(NSMutableArray *)getPunchesForPunchUserUriGroupedByActivity:(NSString *)punchUserUri forDateStr:(NSString *)dateStr isFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule;
-(NSMutableArray *)getAllPunchesFromDBForUser:(NSString *)punchUserUri andDate:(NSString *)dateStr isFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule;
-(NSString *)getSumOfTotalHoursForUser:(NSString *)punchUserUri isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(NSMutableArray *)getAll_In_Out_PunchesUriFromDbforDate:(NSString *)dateStr isFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule;
-(NSDictionary *) getPunchFromDBWithUri:(NSString *)punchURI forActionURI:(NSString *)actionURI isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(NSMutableDictionary *)getSumOfBreakHoursAndWorkHoursForUser:(NSString *)punchUserUri isFromWidgetTimesheet:(BOOL)isWidgetTimesheet forDate:(NSString *)date approvalsModule:(NSString *)approvalsModule;
-(NSMutableDictionary *)getSumOfTimesheetBreakHoursAndWorkHoursisFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule startDateStr:(NSString *)fromDateStr endDateStr:(NSString *)endDateStr;
-(void)updateTimesheetHoursInTimesheetTableWithTimesheetUri:(NSString *)timesheetUri approvalsModule:(NSString *)moduleName;
-(NSMutableArray *) getAllPunchesFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule;
-(void)deleteAllTeamPunchesInfoFromDBIsFromWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule andtimesheetUri:(NSString *)timesheetUri;
-(NSMutableArray *)getAllPunchesForWidgetTimesheet:(BOOL)isWidgetTimesheet approvalsModule:(NSString *)approvalsModule startDateStr:(NSString *)startDateStr endDateStr:(NSString *)endDateStr;
@end
