//
//  LoginModel.h
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2SQLiteDB.h"
#import "G2Util.h"
#import"G2AppProperties.h"
@interface G2LoginModel : NSObject {
	G2AppProperties	*appProperties;
}
- (void) insertUserInfoToDataBase:(NSArray *) userDetailsArray;
- (void) insertUserInfoToDataBase:(NSArray *) userDetailsArray WithLoginPreferences:(NSMutableDictionary*)loginPreferencesDict;
- (void)deleteUserInfoFromDatabase;
-(NSMutableArray *) fetchLoginDetails: (NSString *)uName pwd: (NSString *) pwd companyName:(NSString*)cmpName;
-(void)updateChangePasswordFlagManually;
-(NSMutableArray*)getAllUserInfoFromDb;
-(void)getDBPathForDeletion;
-(void)flushDBInfoForOldUser :(BOOL)deleteLogin;
@end
