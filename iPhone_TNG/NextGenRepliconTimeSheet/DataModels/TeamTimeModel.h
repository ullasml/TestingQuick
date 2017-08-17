//
//  TeamTimeModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import "Constants.h"

@interface TeamTimeModel : NSObject


-(void)saveTeamTimesheetDataFromApiToDB:(NSMutableArray *)responseArray;
-(void)saveTeamTimeUserCapabilitiesFromApiToDB:(NSMutableDictionary *)timePunchCapabilitiesDict forUserUri:(NSString *)userUri;
-(NSMutableArray *) getAllPunchesFromDB;
-(void)deleteAllTeamPunchesInfoFromDB;
-(NSMutableArray *) getGroupedPunchesInfoFromDB;
-(NSMutableArray *) getDistinctUsersFromDB;
-(NSMutableArray *) getDistinctActivitiesFromDBForPunchUser:(NSString *)punchUserUri;
-(NSMutableArray *)getPunchesForPunchUserUriGroupedByActivity:(NSString *)punchUserUri forDateStr:(NSString *)dateStr;
-(NSMutableArray *)getAllPunchesFromDBForUser:(NSString *)punchUserUri andDate:(NSString *)dateStr;
-(NSString *)getSumOfTotalHoursForUser:(NSString *)punchUserUri;
-(NSMutableArray *)getAll_In_Out_PunchesUriFromDbforDate:(NSString *)dateStr;
-(void)deleteAllteamViewUserCapabilities;
-(NSMutableDictionary *)getUserCapabilitiesForUserUri:(NSString *)userUri;
-(NSMutableArray *) getAllTeamPunchesFromDB;
-(NSDictionary *) getPunchFromDBWithUri:(NSString *)punchURI forActionURI:(NSString *)actionURI;
@end
