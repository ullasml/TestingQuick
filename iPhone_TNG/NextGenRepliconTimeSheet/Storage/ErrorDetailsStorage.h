//
//  ErrorDetailsStorage.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "UserSession.h"
#import "DoorKeeper.h"
#import "Enum.h"

@class SQLiteTableStore;
@class ErrorDetails;
@class UserPermissionsStorage;

@interface ErrorDetailsStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                  userDefaults:(NSUserDefaults *)userDefaults
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper;


-(void)storeErrorDetails:(NSArray *)array;
-(NSArray *)getAllErrorDetailsForModuleName:(NSString *)modulename;
-(void)deleteAllErrorDetails;
-(void)deleteErrorDetails:(NSString *)uri;
@end
