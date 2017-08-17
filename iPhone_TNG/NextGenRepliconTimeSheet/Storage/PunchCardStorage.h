
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"

@class SQLiteTableStore;
@class PunchCardObject;
@class DateProvider;
@protocol Punch;

@interface PunchCardStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) id<UserSession> userSession;
@property (nonatomic,readonly) DateProvider *dateProvider;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                       dateProvider:(DateProvider *)dateProvider
                        userSession:(id <UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper NS_DESIGNATED_INITIALIZER;


-(void)storePunchCard:(PunchCardObject *)punchCardObject;

-(void)deletePunchCard:(PunchCardObject *)punchCardObject;

-(NSArray *)getPunchCardsExcludingPunch:(id <Punch>)punch;

-(NSArray *)getPunchCards;

- (NSArray *)getCPTMap;

- (PunchCardObject *)getPunchCardObjectWithClientUri:(NSString *)clientUri
                                          projectUri:(NSString *)projectUri
                                             taskUri:(NSString *)taskUri;

@end
