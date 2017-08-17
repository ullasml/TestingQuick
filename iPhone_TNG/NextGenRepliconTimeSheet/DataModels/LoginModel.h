//
//  LoginModel.h
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import"AppProperties.h"

@interface LoginModel : NSObject
{
	AppProperties	*appProperties;
}

-(NSMutableArray*)getAllUserDetailsInfoFromDb;
-(NSString *)getUserUriInfoFromDb;
-(void)flushDBInfoForOldUser :(BOOL)deleteLogin;
-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName;
-(NSString *)getStatusForDisclaimerPermissionForColumnName:(NSString *)columnName;
-(NSMutableArray *)getUserDefinedFieldsForURI:(NSString *)uri;
-(void)saveUserDefinedFieldsDataToDB:(NSDictionary *)udfDict;
-(void)flushUserDefinedFields;
-(NSMutableArray *)getEnabledOnlyUDFsforModuleName:(NSString *)moduleName;
-(void)saveUfdDropDownOptionDataToDB:(NSMutableArray*)responseArray;
-(NSMutableArray *)getDropDownOptionsFromDatabase;
-(void)deleteAllDropDownOptionsInfoFromDB;
-(void)deleteAllOEFDropDownTagOptionsInfoFromDB;
-(NSMutableArray *)getRequiredOnlyUDFsforModuleName:(NSString *)moduleName;
-(BOOL )getMandatoryStatusforUDFWithIdentity:(NSString *)udfIdentity forModuleName:(NSString *)moduleName;
-(NSMutableDictionary *)getDataforUDFWithIdentity:(NSString *)udfIdentity;
-(void)saveUserDefinedFieldsCloneDataToDB:(NSDictionary *)udfDict;
-(NSMutableArray*)getAllNewUserDetailsInfoFromDb;
-(void)saveOEFDropDownTagOptionDataToDB:(NSMutableArray*)responseArray;
-(NSMutableArray *)getOEFDropDownTagOptionsFromDatabase;
@end
