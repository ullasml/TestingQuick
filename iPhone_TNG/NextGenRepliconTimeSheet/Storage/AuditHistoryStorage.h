#import <Foundation/Foundation.h>
#import "DoorKeeper.h"

@class SQLiteTableStore;

@interface AuditHistoryStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                         doorKeeper:(DoorKeeper *)doorKeeper NS_DESIGNATED_INITIALIZER;

-(void)setUpWithUserUri:(NSString *)userUri;

-(void)storePunchLogs:(NSArray*)punchLogs;
-(NSArray*)getPunchLogs:(NSArray*)uriArray;
-(void)deleteAllRows;

@end
