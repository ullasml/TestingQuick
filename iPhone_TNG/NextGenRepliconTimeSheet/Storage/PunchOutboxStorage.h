#import <Foundation/Foundation.h>
#import "Enum.h"

@class LocalPunch;
@class SQLiteTableStore;
@protocol UserSession;
@class DateProvider;
@protocol Punch;
@class PunchOEFStorage;
@class LocalSQLPunchDeserializer;


@interface PunchOutboxStorage : NSObject

@property (nonatomic, readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic,readonly) PunchOEFStorage *punchOEFStorage;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLocalSQLPunchDeserializer:(LocalSQLPunchDeserializer*)localSQLPunchDeserializer
                                      sqliteStore:(SQLiteTableStore *)sqliteStore
                                      userSession:(id <UserSession>)userSession
                                     dateProvider:(DateProvider *)dateProvider
                                  punchOEFStorage:(PunchOEFStorage *)punchOEFStorage NS_DESIGNATED_INITIALIZER;


- (LocalPunch *)getAndDeletePunchForRequestId:(NSString *)requestId;

- (NSArray *)allPunches;

- (void)updateSyncStatusToPendingAndSave:(id<Punch>)punch;
- (void)deletePunch:(LocalPunch *)localPunch;
- (NSArray *)unSubmittedAndPendingSyncPunches;
-(void)storeLocalPunch:(LocalPunch *)localPunch;
@end
