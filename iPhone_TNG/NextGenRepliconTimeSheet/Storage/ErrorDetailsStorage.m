//
//  ErrorDetailsStorage.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetailsStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "ErrorDetails.h"
#import "UserPermissionsStorage.h"


@interface ErrorDetailsStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end


@implementation ErrorDetailsStorage


- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                  userDefaults:(NSUserDefaults *)userDefaults
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper {
    self = [super init];
    if (self)
    {
        self.userPermissionsStorage = userPermissionsStorage;
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        self.userDefaults = userDefaults;
        [self.doorKeeper addLogOutObserver:self];
    }

    return self;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


-(void)deleteAllErrorDetails
{
    [self.sqliteStore deleteAllRows];

}

-(void)deleteErrorDetails:(NSString *)uri
{
    [self.sqliteStore deleteRowWithArgs:@{@"uri": uri}];
}

-(void)storeErrorDetails:(NSArray *)errorDetailsArr
{
    for (ErrorDetails *errorDetails in errorDetailsArr) {
        NSDictionary *errorDetailsTypeDictionary = [self dictionaryWithErrorDetails:errorDetails];
        NSDictionary *errorDetailsFilter = @{@"uri": errorDetails.uri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:errorDetailsFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:errorDetailsTypeDictionary whereClause:errorDetailsFilter];
        } else {
            [self.sqliteStore insertRow:errorDetailsTypeDictionary];
        }
    }
}

-(NSArray *)getAllErrorDetailsForModuleName:(NSString *)modulename
{
    NSArray *errorDetails = [self.sqliteStore readAllRowsWithArgs:@{@"module": modulename} orderedBy:@"date"];
    return [self serializeErrorDetails:errorDetails];

}




#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.sqliteStore deleteAllRows];
}

#pragma mark - Private

- (NSDictionary *)dictionaryWithErrorDetails:(ErrorDetails *)errorDetails
{
    return @{@"uri": errorDetails.uri,
             @"error_msg": errorDetails.errorMessage,
             @"date": errorDetails.errorDate,
             @"module": errorDetails.moduleName
             };
}

-(NSArray *)serializeErrorDetails:(NSArray *)errorDetailsArr
{
    if (errorDetailsArr.count == 0) {
        return nil;
    }
    NSMutableArray *errorDetailsTypes = [NSMutableArray arrayWithCapacity:errorDetailsArr.count+1];

    for (NSDictionary *errorDetailsDictionary in errorDetailsArr) {
        NSString *uri = errorDetailsDictionary[@"uri"];
        NSString *errorMessage = errorDetailsDictionary[@"error_msg"];
        NSString *errorDate = errorDetailsDictionary[@"date"];
        NSString *module = errorDetailsDictionary[@"module"];
        ErrorDetails *errorDetails = [[ErrorDetails alloc] initWithUri:uri errorMessage:errorMessage errorDate:errorDate moduleName:module];
        [errorDetailsTypes addObject:errorDetails];
    }
    return [errorDetailsTypes copy];

}


@end
