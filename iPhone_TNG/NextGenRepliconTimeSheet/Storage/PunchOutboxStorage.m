#import "PunchOutboxStorage.h"
#import "PunchActionTypes.h"
#import "SQLiteTableStore.h"
#import "BreakType.h"
#import "RemotePunch.h"
#import "PunchActionTypeDeserializer.h"
#import "LocalPunch.h"
#import "Constants.h"
#import "LocalSQLPunchDeserializer.h"
#import "LocalSQLPunchSerializer.h"
#import "UserSession.h"
#import "Enum.h"
#import "DateProvider.h"
#import "PunchOEFStorage.h"


@interface PunchOutboxStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) LocalSQLPunchDeserializer *deserializer;
@property (nonatomic) LocalSQLPunchSerializer *serializer;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) PunchOEFStorage *punchOEFStorage;

@end


@implementation PunchOutboxStorage

- (instancetype)initWithLocalSQLPunchDeserializer:(LocalSQLPunchDeserializer*)localSQLPunchDeserializer
                                      sqliteStore:(SQLiteTableStore *)sqliteStore
                                      userSession:(id <UserSession>)userSession
                                     dateProvider:(DateProvider *)dateProvider
                                  punchOEFStorage:(PunchOEFStorage *)punchOEFStorage {
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
        self.userSession = userSession;
        self.dateProvider = dateProvider;
        self.deserializer = localSQLPunchDeserializer;
        self.serializer = [[LocalSQLPunchSerializer alloc] init];
        self.punchOEFStorage = punchOEFStorage;
    }
    return self;
}

-(void)storeLocalPunch:(LocalPunch *)localPunch
{
    if (localPunch.requestID)
    {
        [self.sqliteStore deleteRowWithArgs:@{@"request_id": localPunch.requestID}];
    }

    NSMutableDictionary *punchSQLDictionary = [[self.serializer serializePunchForStorage:localPunch] mutableCopy];
    [self.sqliteStore insertRow:punchSQLDictionary];

    if (localPunch.oefTypesArray) {
        [self.punchOEFStorage storePunchOEFArray:localPunch.oefTypesArray forPunch:localPunch];
    }
}

- (LocalPunch *)getAndDeletePunchForRequestId:(NSString *)requestId
{
    NSDictionary *whereArgs = @{
                                /*This is wrong in case where supervisor views a user timesheet.*/
                                //@"user_uri": [self.userSession currentUserURI],
                                @"request_id": requestId
                                };

    NSArray *allLocalSQLPunchDictionaries = [self.sqliteStore readAllRowsWithArgs:whereArgs];

    if (allLocalSQLPunchDictionaries.count > 0)
    {
        [self.sqliteStore deleteRowWithArgs:whereArgs];
        [self.punchOEFStorage deletePunchOEFWithRequestID:requestId];

        NSDictionary *punchDictionary = allLocalSQLPunchDictionaries.firstObject;
        return [self.deserializer deserializeSingleLocalSQLPunch:punchDictionary punchOEFStorage:self.punchOEFStorage];
    }

    return nil;
}

- (void)updateSyncStatusToPendingAndSave:(id<Punch>)punch
{
    NSDictionary *whereArgsWithDate = @{@"user_uri": punch.userURI, @"request_id":punch.requestID};
    NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(PendingSyncStatus), @"lastSyncTime":self.dateProvider.date, @"offline":@1};
    [self.sqliteStore updateRow:updatedRowDictionary whereClause:whereArgsWithDate];
}


- (void)updateSyncStatusToUnsubmittedAndSaveWithPunch:(id<Punch>)punch
{
    NSDictionary *whereArgsWithDate = @{@"user_uri": punch.userURI, @"request_id":punch.requestID};
    NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(UnsubmittedSyncStatus), @"lastSyncTime":[NSNull null]};
    [self.sqliteStore updateRow:updatedRowDictionary whereClause:whereArgsWithDate];
}


- (void)deletePunch:(LocalPunch *)localPunch
{
    NSDictionary *whereArgs = @{@"user_uri": localPunch.userURI, @"request_id":localPunch.requestID};
    [self.sqliteStore deleteRowWithArgs:whereArgs];
}


- (NSArray *)allPunches
{
    NSDictionary *whereArgsUri = @{@"user_uri": [self.userSession currentUserURI]};
    NSDictionary *whereArgsUnsubmittedStatus = @{@"punchSyncStatus": @(UnsubmittedSyncStatus)};
    NSDictionary *whereArgsPendingStatus = @{@"punchSyncStatus": @(PendingSyncStatus)};
    NSArray *allLocalSQLPunchDictionaries = [self.sqliteStore readAllRowsWithWhere:whereArgsUri
                                                                          andWhere:whereArgsUnsubmittedStatus
                                                                           orWhere:whereArgsPendingStatus];
    return [self.deserializer deserializeLocalSQLPunches:allLocalSQLPunchDictionaries punchOEFStorage:self.punchOEFStorage];
}

- (NSArray *)unSubmittedAndPendingSyncPunches
{
    NSDate *dateWhichIsPastFiveMinutes =  [self.dateProvider.date dateByAddingTimeInterval:-300];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateToBeCompared = [dateFormatter stringFromDate:dateWhichIsPastFiveMinutes];
    NSString *argsString = [NSString stringWithFormat:@"(lastSyncTime < '%@'  OR lastSyncTime ISNULL) AND punchSyncStatus = %@", dateToBeCompared, @(PendingSyncStatus)];
    NSArray *allLocalPendingPunchDictionaries = [self.sqliteStore readAllRowsWithArgsString:argsString];
    
    NSMutableArray *pendingPunches = [NSMutableArray arrayWithCapacity:allLocalPendingPunchDictionaries.count];
    
    for (NSDictionary *dictionary in allLocalPendingPunchDictionaries) {
        [pendingPunches addObject:[self.deserializer deserializeSingleSQLPunch:dictionary punchOEFStorage:self.punchOEFStorage]];
    }
    
    for (id<Punch>punch in pendingPunches) {
        [self updateSyncStatusToUnsubmittedAndSaveWithPunch:punch];
    }

    NSDictionary *whereArgsWithUnsubmittedSyncStatus = @{@"user_uri": [self.userSession currentUserURI], @"punchSyncStatus":@(UnsubmittedSyncStatus)};
    
    NSArray *allLocalUnsubmittedPunchDictionaries = [self.sqliteStore readAllRowsWithArgs:whereArgsWithUnsubmittedSyncStatus];
    
    NSMutableArray *unsubmittedPunches = [NSMutableArray arrayWithCapacity:allLocalPendingPunchDictionaries.count];
    for (NSDictionary *dictionary in allLocalUnsubmittedPunchDictionaries) {
        [unsubmittedPunches addObject:[self.deserializer deserializeSingleSQLPunch:dictionary punchOEFStorage:self.punchOEFStorage]];
    }
    
    return unsubmittedPunches;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
