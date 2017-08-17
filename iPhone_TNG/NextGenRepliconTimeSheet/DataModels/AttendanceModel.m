//
//  AttendanceModel.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "AttendanceModel.h"

static NSString *attendancePunchTable=@"PunchesAttendance";
static NSString *attendanceLastPunchTable=@"LastPunchData";


@implementation AttendanceModel

#pragma mark - delete methods

-(void)deleteAllTimeoffsFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:attendancePunchTable inDatabase:@""];
}

-(void)deleteLastPunchFromDB
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
	[myDB deleteFromTable:attendanceLastPunchTable inDatabase:@""];
}


#pragma mark - save methods

-(void)savePuchDataFromApiToDB:(NSMutableDictionary *)responseDictionary
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB insertIntoTable:attendancePunchTable data:responseDictionary intoDatabase:@""];
}

-(void)saveLastPuchDataFromApiToDB:(NSMutableDictionary *)responseDictionary
{
    [self deleteLastPunchFromDB];
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB insertIntoTable:attendanceLastPunchTable data:responseDictionary intoDatabase:@""];
}


#pragma mark - get data methods

-(NSMutableArray *)getAllPunchesFromDB
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
	NSString *query = [NSString stringWithFormat:@" select * from %@ where userUri='%@'",attendancePunchTable,userID];
	NSMutableArray *punchDetails = [myDB executeQueryToConvertUnicodeValues:query];
	NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<[punchDetails count]; i++)
    {
        BOOL isBothPresent=[Util isBothInAndOutEntryPresent:[punchDetails objectAtIndex:i]];
        if (isBothPresent)
        {
            [array addObject:[punchDetails objectAtIndex:i]];
        }
    }
	return array;
}

-(NSMutableDictionary *)getPuncheDataFromDBForPunchId:(NSString *)uniqueId
{
    
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from %@ where ATTENDANCE_uniqueID='%@'",attendancePunchTable,uniqueId];
	NSMutableArray *punchDetails = [myDB executeQueryToConvertUnicodeValues:query];
	
    if ([punchDetails count]>0)
    {
        return [punchDetails objectAtIndex:0];
    }
    
	return nil;
}

-(NSMutableArray *)getLastPuncheFromDB
{
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from %@",attendanceLastPunchTable];
	NSMutableArray *lastPunchDetails = [myDB executeQueryToConvertUnicodeValues:query];
    
    if ([lastPunchDetails count]>0)
    {
        return lastPunchDetails;
    }
    
	return nil;
}

-(void)updatePuchDataFromApiToDB:(NSMutableDictionary *)responseDictionary condition:(NSString*)conditionString;
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB updateTable:attendancePunchTable data:responseDictionary where:conditionString intoDatabase:@""];
}



@end
