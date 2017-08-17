
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
@class SQLiteTableStore;

@interface DefaultActivityStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore     *sqliteStore;
@property (nonatomic,readonly) DoorKeeper           *doorKeeper;
@property (nonatomic,readonly) id<UserSession>      userSession;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                        userSession:(id<UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper NS_DESIGNATED_INITIALIZER;

-(void)setUpWithUserUri:(NSString*)userUri;
-(void)persistDefaultActivityName:(NSString *)defaultActivityName defaultActivityUri:(NSString*)defaultActivityUri;

- (NSDictionary*)defaultActivityDetails;

@end
