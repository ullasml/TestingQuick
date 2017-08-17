#import <Foundation/Foundation.h>
#import "DoorKeeper.h"

@class SQLiteTableStore;

@interface ViolationsStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                         doorKeeper:(DoorKeeper *)doorKeeper;
-(void)storePunchViolations:(NSArray*)punches;
-(NSArray*)getPunchViolations:(NSString*)uri;
-(void)deleteAllRows;


@end
