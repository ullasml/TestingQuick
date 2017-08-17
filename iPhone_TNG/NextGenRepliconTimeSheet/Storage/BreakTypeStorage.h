#import <Foundation/Foundation.h>
#import "DoorKeeper.h"


@class SQLiteTableStore;
@protocol UserSession;


@interface BreakTypeStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic, readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic, readonly) DoorKeeper *doorKeeper;
@property (nonatomic, readonly) id<UserSession> userSession;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                         doorKeeper:(DoorKeeper *)doorKeeper
                        userSession:(id<UserSession>)userSession;

- (void)removeAllBreakTypes;
- (NSArray *)allBreakTypesForUser:(NSString *)useruri;

- (void)storeBreakTypes:(NSArray *)breakTypes forUser:(NSString *)useruri;

@end
