
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
@class SQLiteTableStore;
@class TaskType;
@class UserPermissionsStorage;

@interface ExpenseTaskStorage : NSObject <DoorKeeperLogOutObserver>
@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                       userDefaults:(NSUserDefaults *)userDefaults
                        userSession:(id<UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage NS_DESIGNATED_INITIALIZER;


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

-(TaskType *)getTaskInfoForUri:(NSString *)taskUri;



@end
