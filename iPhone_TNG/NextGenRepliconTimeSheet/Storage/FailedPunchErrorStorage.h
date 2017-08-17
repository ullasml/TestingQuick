
#import <Foundation/Foundation.h>
#import "DoorKeeper.h"
#import "UserSession.h"

@class SQLiteTableStore;
@protocol Punch;

@interface FailedPunchErrorStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserSqliteStore:(SQLiteTableStore *)sqliteStore
                            userSession:(id<UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper;

- (void)storeFailedPunchError:(NSDictionary*)errorDictionary punch:(id<Punch>)punch;
- (NSArray*)getFailedPunchErrors;
-(void) deletePunchErrors:(NSArray*)punchErrors;
@end
