#import <Foundation/Foundation.h>


@class LocalPunch;
@class RemotePunch;
@class SQLiteTableStore;
@class LocalSQLPunchSerializer;
@protocol UserSession;
@class PunchOEFStorage;


@interface FailedPunchStorage : NSObject

@property (nonatomic, readonly) LocalSQLPunchSerializer *localSQLPunchSerializer;
@property (nonatomic, readonly) SQLiteTableStore *sqliteTableStore;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic,readonly) PunchOEFStorage *punchOEFStorage;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithLocalSQLPunchSerializer:(LocalSQLPunchSerializer *)localSQLPunchSerializer
                               sqliteTableStore:(SQLiteTableStore *)sqliteStore
                                    userSession:(id <UserSession>)userSession
                                punchOEFStorage:(PunchOEFStorage *)punchOEFStorage NS_DESIGNATED_INITIALIZER;

- (void)storePunch:(LocalPunch *)punch;

- (void)updateSyncStatusToUnsubmittedAndSaveWithPunch:(LocalPunch *)localPunch;
- (void)updateStatusOfRemotePunchToUnsubmitted:(RemotePunch *)remotePunch;
@end
