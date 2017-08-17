
#import <Foundation/Foundation.h>
#import "UserSession.h"
#import "DoorKeeper.h"
@class SQLiteTableStore;
@class RemotePunch;
@class LocalPunch;

@protocol Punch;
@protocol UserSession;
@class PunchOEFStorage;
@class DateProvider;
@class RemoteSQLPunchSerializer;
@class LocalSQLPunchDeserializer;

@interface TimeLinePunchesStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic,readonly) DoorKeeper       *doorKeeper;
@property (nonatomic,readonly) id<UserSession>  userSession;
@property (nonatomic,readonly) PunchOEFStorage *punchOEFStorage;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic,readonly) NSDateFormatter *dateFormatter;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRemoteSQLPunchSerializer:(RemoteSQLPunchSerializer *)remoteSQLPunchSerializer
                       localSQLPunchDeserializer:(LocalSQLPunchDeserializer *)localSQLPunchDeserializer
                                     sqliteStore:(SQLiteTableStore *)sqliteStore
                                     userSession:(id <UserSession>)userSession
                                      doorKeeper:(DoorKeeper *)doorKeeper
                                 punchOEFStorage:(PunchOEFStorage *)punchOEFStorage
                                    dateProvider:(DateProvider *)dateProvider
                                   dateFormatter:(NSDateFormatter *)dateFormatter;

-(void)storeRemotePunch:(RemotePunch *)remotePunch;
- (id<Punch>) mostRecentPunch;
- (NSArray *)recentPunches;
- (NSArray *)allRemotePunchesForDay:(NSDate *)date userUri:(NSString *)userUri;
- (NSArray *)allPunchesForDay:(NSDate *)date userUri:(NSString *)userUri;
-(void)deleteAllPreviousPunches:(NSString *)userUri;
- (void)updateSyncStatusToRemoteAndSaveWithPunch:(id<Punch>)punch withRemoteUri:(NSString *)uri;
- (void)deleteOldRemotePunch:(RemotePunch *)remotePunch;
- (NSArray *)recentTwoPunches;
- (NSArray *)recentPunchesForUserUri:(NSString *)userUri;
- (id<Punch>) mostRecentPunchForUserUri:(NSString *)userUri;
-(void)deleteAllPunchesForDate:(NSDate *)date;
- (NSArray *)allPunches;
- (void)updateIsTimeEntryAvailableColumnMatchingClientUri:(NSString *)clientUri projectUri:(NSString *)projectUri taskUri:(NSString *)taskUri isTimeEntryAvailable:(BOOL)isTimeEntryAvailable;
@end
