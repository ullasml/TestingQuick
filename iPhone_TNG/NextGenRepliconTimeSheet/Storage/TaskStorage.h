
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
#import "Enum.h"

@class SQLiteTableStore;
@class TaskType;
@class UserPermissionsStorage;

@interface TaskStorage : NSObject <DoorKeeperLogOutObserver>
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


-(void)storeTasks:(NSArray *)array;

-(void)deleteAllTasksForProjectWithUri:(NSString *)projectUri;

-(NSArray *)getAllTasksForProjectUri:(NSString *)projectUri;

-(NSArray *)getTasksWithMatchingText:(NSString *)text projectUri:(NSString *)projectUri;

-(NSNumber *)getLastPageNumber;

-(void)updatePageNumber;

-(void)resetPageNumber;

-(NSNumber *)getLastPageNumberForFilteredSearch;

-(void)updatePageNumberForFilteredSearch;

-(void)resetPageNumberForFilteredSearch;

-(void)setUpWithUserUri:(NSString *)userUri;

@end
