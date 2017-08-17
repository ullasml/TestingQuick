//
//  SupportDataModel.m
//  Replicon
//
//  Created by Devi Malladi on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SupportDataModel.h"


static NSString *userDetailsTable = @"userDetails";
static NSString *newuserDetailsTable = @"newuserDetails";
static NSString *timesheetPermittedApprovalActionsTable = @"TimesheetPermittedApprovalActions";
static NSString *expensePermittedApprovalActionsTable = @"ExpensePermittedApprovalActions";

@implementation SupportDataModel


-(NSMutableArray *)getUserDetailsFromDatabase
{
	SQLiteDB *myDB  = [SQLiteDB getInstance];
    NSMutableArray *userDetailsArr = [myDB select:@"*" from:userDetailsTable where:@"" intoDatabase:@""];
	
	if (userDetailsArr != nil && [userDetailsArr count]!=0)
    {
		return userDetailsArr;
	}
	return nil;
}

-(NSMutableArray *)getUserDetailsFromLightWeightHomeFlowDatabase
{
    SQLiteDB *myDB  = [SQLiteDB getInstance];
    NSMutableArray *userDetailsArr = [myDB select:@"*" from:newuserDetailsTable where:@"" intoDatabase:@""];
    
    if (userDetailsArr != nil && [userDetailsArr count]!=0)
    {
        return userDetailsArr;
    }
    return nil;
}

-(void)saveTimesheetPermittedApprovalActionsDataToDB:(NSDictionary *)dataDict
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"uri = '%@'",[dataDict objectForKey:@"uri"]];;
    [myDB deleteFromTable:timesheetPermittedApprovalActionsTable where:whereString inDatabase:@""];
    [myDB insertIntoTable:timesheetPermittedApprovalActionsTable data:dataDict intoDatabase:@""];
    
    
}

-(NSDictionary *)getTimesheetPermittedApprovalActionsDataToDBWithUri:(NSString *)uri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"uri = '%@'",uri];
    NSMutableArray *dataArray = [myDB select:@"*" from:timesheetPermittedApprovalActionsTable where:whereString intoDatabase:@""];
    if (dataArray != nil && [dataArray count] > 0)
    {
		return [dataArray objectAtIndex:0];
	}
	
	return nil;
    
    
}

-(void)saveExpensePermittedApprovalActionsDataToDB:(NSDictionary *)dataDict
{
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    [myDB insertIntoTable:expensePermittedApprovalActionsTable data:dataDict intoDatabase:@""];
    
    
}

-(NSDictionary *)getExpensePermittedApprovalActionsDataToDBWithUri:(NSString *)uri
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *whereString = [NSString stringWithFormat:@"uri = '%@'",uri];
    NSMutableArray *dataArray = [myDB select:@"*" from:expensePermittedApprovalActionsTable where:whereString intoDatabase:@""];
    if (dataArray != nil && [dataArray count] > 0)
    {
		return [dataArray objectAtIndex:0];
	}
	
	return nil;
}

-(void)updateTimesheetPermission:(int)hasTimesheetAccess
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET hasTimesheetAccess='%@'",userDetailsTable,[NSNumber numberWithInt:hasTimesheetAccess]];
    [myDB executeQuery:sql];
}

@end
