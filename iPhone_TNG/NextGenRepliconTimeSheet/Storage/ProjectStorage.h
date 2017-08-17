
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
#import "Enum.h"

@class SQLiteTableStore;
@class ProjectType;
@class UserPermissionsStorage;

@interface ProjectStorage : NSObject <DoorKeeperLogOutObserver>
@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic,readonly) NSString *userUri;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                  userDefaults:(NSUserDefaults *)userDefaults
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper NS_DESIGNATED_INITIALIZER;


-(void)storeProjects:(NSArray *)array;

-(void)deleteAllProjectsForClientUri:(NSString *)clientUri;

-(NSArray *)getAllProjectsForClientUri:(NSString *)clientUri;

-(NSArray *)getProjectsWithMatchingText:(NSString *)text clientUri:(NSString *)clientUri;

-(NSNumber *)getLastPageNumber;

-(void)updatePageNumber;

-(void)resetPageNumber;

-(NSNumber *)getLastPageNumberForFilteredSearch;

-(void)updatePageNumberForFilteredSearch;

-(void)resetPageNumberForFilteredSearch;

-(ProjectType *)getProjectInfoForUri:(NSString *)projectUri;

-(void)setUpWithUserUri:(NSString *)userUri;

@end
