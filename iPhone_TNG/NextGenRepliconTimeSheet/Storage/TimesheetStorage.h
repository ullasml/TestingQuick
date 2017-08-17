
#import <Foundation/Foundation.h>
#import "DoorKeeper.h"


@class SQLiteTableStore;

@interface TimesheetStorage : NSObject

@property (nonatomic, readonly) SQLiteTableStore *sqliteStore;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSQLiteStore:(SQLiteTableStore *)sqliteStore NS_DESIGNATED_INITIALIZER;

@end