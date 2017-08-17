//
//  PermissionsModel.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2PermissionsModel.h"

static NSString *tableName = @"userPermissions";
static NSString *approvalsTableName = @"approvals_userPermissions";
@implementation G2PermissionsModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
	}
	return self;
}

- (void) insertUserPermissionsInToDataBase:(NSDictionary *) permissionsDict{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	if ([[self getUserPermissions]count]>0) {
		[myDB deleteFromTable:tableName inDatabase:@""];
	}
	NSArray *keys = [permissionsDict allKeys];
	NSArray *values = [permissionsDict allValues];

	for (int i=0; i<[keys count]; i++) {
		
		NSDictionary *infoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:i+1],@"id",
								  [keys objectAtIndex:i],@"permissionName",
								  [[values objectAtIndex:i]stringValue],@"status",
								  nil];
		[myDB insertIntoTable:tableName data:infoDict intoDatabase:@""];
	}

}

-(NSMutableArray *)getUserPermissions{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:tableName where:@"" intoDatabase:@""];
	if ([permissionArr count]!=0) {
		return permissionArr;
	}
	return nil;
}//To delete all permissions

-(NSMutableArray *)getEnabledUserPermissions{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:tableName where:@"status=1" intoDatabase:@""];
	if ([permissionArr count]!=0) {
		return permissionArr;
	}
	return nil;
}

-(NSMutableArray *)getEnabledUserPermissionsForUserID:(NSString *)userID{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:approvalsTableName where:[NSString stringWithFormat: @"status=1 and user_identity='%@'",userID] intoDatabase:@""];
	if ([permissionArr count]!=0) {
		return permissionArr;
	}
	return nil;
}



-(BOOL)checkUserPermissionWithPermissionName:(NSString*)permissionName{

	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:tableName where:[NSString stringWithFormat:@"permissionName = '%@' ",permissionName] intoDatabase:@""];
	//DLog(@"PERMISSIONS ARRAY FOR EXPENSES %@",permissionArr);
	if ([permissionArr count] != 0) {
		if([[[permissionArr objectAtIndex: 0] objectForKey: @"status"] isEqualToString: @"1"]) {
			return YES;
		}
	}
	return NO;
}


-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSMutableArray *permissionArr = [myDB select:@"*" from:tableName where:[NSString stringWithFormat:@"permissionName='%@'",permissionName] intoDatabase:@""];
	if([[[permissionArr objectAtIndex:0] objectForKey:@"status"] isEqualToString:@"1"]){
		return YES;
	}
return NO;

}

-(NSMutableArray*)getAllLicencesInfoFromDb
{
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *query = [NSString stringWithFormat:@" select * from user_licences"];
	NSMutableArray *licensesUserData = [myDB executeQueryToConvertUnicodeValues:query];
	
	if( [licensesUserData count] > 0)
		return licensesUserData;
	
	return nil;
}

/**
 *Module:TimeSheet
 *Date:June 2nd
 **/
-(NSMutableArray *)getAllEnabledUserPermissions{
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *selectString = @"permissionName";
	NSMutableArray *permissionArr = [myDB select:selectString from:tableName where:@"status=1" intoDatabase:@""];
	if (permissionArr != nil && [permissionArr count]>0) {
		NSMutableArray *permissionList = [NSMutableArray array];
		for (NSDictionary *permissionDict in permissionArr ) {
			[permissionList addObject:[permissionDict objectForKey:selectString]];
		}
		return permissionList;
	}
	return nil;
}//TimeSheet

/**
 A static method that returns the permission type for the logged in user
 */
+ (ProjectPermissionType) getProjectPermissionType
{
	ProjectPermissionType projPermissionType = PermType_Invalid;
	
	G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
	BOOL projectExpense = [permissionsModel checkUserPermissionWithPermissionName: @"ProjectExpense"];
	BOOL nonProjectExpense = [permissionsModel checkUserPermissionWithPermissionName: @"NonProjectExpense"];
	
	if (projectExpense == YES && nonProjectExpense == YES) {
		projPermissionType = PermType_Both;
	}else if (projectExpense == NO && nonProjectExpense == YES) {		
		projPermissionType = PermType_NonProjectSpecific;
	}else if (projectExpense == YES && nonProjectExpense == NO) {
		projPermissionType = PermType_ProjectSpecific;
	}
	
	
	return projPermissionType;
}

@end
