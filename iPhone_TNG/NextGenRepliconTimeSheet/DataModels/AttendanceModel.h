//
//  AttendanceModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import"AppProperties.h"

@interface AttendanceModel : NSObject

//delete methods
-(void)deleteAllTimeoffsFromDB;
-(void)deleteLastPunchFromDB;



//save methods
-(void)savePuchDataFromApiToDB:(NSMutableDictionary *)responseDictionary;
-(void)saveLastPuchDataFromApiToDB:(NSMutableDictionary *)responseDictionary;

//get methods
-(NSMutableArray *)getAllPunchesFromDB;
-(NSMutableDictionary *)getPuncheDataFromDBForPunchId:(NSString *)uniqueId;

-(NSMutableArray *)getLastPuncheFromDB;

//update methods
-(void)updatePuchDataFromApiToDB:(NSMutableDictionary *)responseDictionary condition:(NSString*)conditionString;

@end