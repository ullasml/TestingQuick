//
//  PermissionsModel.h
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2SQLiteDB.h"
#import "G2Util.h"

@interface G2PermissionsModel : NSObject {

}
- (void) insertUserPermissionsInToDataBase:(NSArray *) permissionsArr;
-(NSMutableArray *)getEnabledUserPermissions;
-(NSMutableArray *)getAllEnabledUserPermissions;
-(BOOL)checkUserPermissionWithPermissionName:(NSString*)permissionName;
-(NSMutableArray *)getUserPermissions;
-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName;
-(NSMutableArray *)getEnabledUserPermissionsForUserID:(NSString *)userID;
+ (ProjectPermissionType) getProjectPermissionType;
-(NSMutableArray*)getAllLicencesInfoFromDb;
@end
