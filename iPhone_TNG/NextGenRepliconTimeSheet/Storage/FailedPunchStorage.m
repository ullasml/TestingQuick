#import "FailedPunchStorage.h"
#import "SQLiteTableStore.h"
#import "LocalSQLPunchSerializer.h"
#import "UserSession.h"
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "Enum.h"
#import "PunchOEFStorage.h"
#import "PunchOEFStorage.h"

@interface FailedPunchStorage ()

@property (nonatomic) LocalSQLPunchSerializer *localSQLPunchSerializer;
@property (nonatomic) SQLiteTableStore *sqliteTableStore;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) PunchOEFStorage *punchOEFStorage;
@end


@implementation FailedPunchStorage

- (instancetype)initWithLocalSQLPunchSerializer:(LocalSQLPunchSerializer *)localSQLPunchSerializer
                                 sqliteTableStore:(SQLiteTableStore *)sqliteTableStore
                                      userSession:(id <UserSession>)userSession
                                  punchOEFStorage:(PunchOEFStorage *)punchOEFStorage
{
    self = [super init];
    if (self)
    {
        self.localSQLPunchSerializer = localSQLPunchSerializer;
        self.sqliteTableStore = sqliteTableStore;
        self.userSession = userSession;
        self.punchOEFStorage = punchOEFStorage;
    }
    return self;
}

- (void)storePunch:(LocalPunch *)punch
{
    LocalPunch *updatedPunch = [[LocalPunch alloc]
                                            initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                         actionType:punch.actionType
                                                       lastSyncTime:nil
                                                          breakType:punch.breakType
                                                           location:punch.location
                                                            project:punch.project
                                                          requestID:NULL
                                                           activity:punch.activity
                                                             client:punch.client
                                                           oefTypes:punch.oefTypesArray
                                                            address:punch.address
                                                            userURI:punch.userURI
                                                              image:punch.image
                                                               task:punch.task
                                                               date:punch.date];
    NSDictionary *rowDictionary = [self.localSQLPunchSerializer serializePunchForStorage:updatedPunch];
    [self.sqliteTableStore insertRow:rowDictionary];

    if (punch.oefTypesArray) {
        [self.punchOEFStorage storePunchOEFArray:punch.oefTypesArray forPunch:punch];
    }
}

- (void)updateSyncStatusToUnsubmittedAndSaveWithPunch:(LocalPunch *)localPunch
{
    NSDictionary *whereArgsWithDate = @{@"user_uri": [self.userSession currentUserURI], @"request_id":localPunch.requestID};
    NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(UnsubmittedSyncStatus), @"lastSyncTime":[NSNull null], @"offline":@1};
    [self.sqliteTableStore updateRow:updatedRowDictionary whereClause:whereArgsWithDate];
}

- (void)updateStatusOfRemotePunchToUnsubmitted:(RemotePunch *)remotePunch
{
    NSDictionary *whereArgsWithDate = @{@"user_uri": [self.userSession currentUserURI], @"request_id":remotePunch.requestID};
    NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(UnsubmittedSyncStatus), @"offline":@1};
    [self.sqliteTableStore updateRow:updatedRowDictionary whereClause:whereArgsWithDate];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
