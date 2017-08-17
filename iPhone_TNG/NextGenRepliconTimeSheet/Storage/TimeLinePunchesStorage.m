
#import "TimeLinePunchesStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "LocalSQLPunchSerializer.h"
#import "LocalSQLPunchDeserializer.h"
#import "RemoteSQLPunchSerializer.h"
#import "GUIDProvider.h"
#import "Punch.h"
#import "PunchOEFStorage.h"
#import "DateProvider.h"

@interface TimeLinePunchesStorage ()

@property (nonatomic) SQLiteTableStore          *sqliteStore;
@property (nonatomic) DoorKeeper                *doorKeeper;
@property (nonatomic) id<UserSession>           userSession;
@property (nonatomic) LocalSQLPunchSerializer   *localPunchSerializer;
@property (nonatomic) RemoteSQLPunchSerializer  *remoteSQLPunchSerializer;
@property (nonatomic) LocalSQLPunchDeserializer *localSQLPunchDeserializer;
@property (nonatomic) PunchOEFStorage *punchOEFStorage;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@end


@implementation TimeLinePunchesStorage

- (instancetype)initWithRemoteSQLPunchSerializer:(RemoteSQLPunchSerializer *)remoteSQLPunchSerializer
                       localSQLPunchDeserializer:(LocalSQLPunchDeserializer *)localSQLPunchDeserializer
                                     sqliteStore:(SQLiteTableStore *)sqliteStore
                                     userSession:(id <UserSession>)userSession
                                      doorKeeper:(DoorKeeper *)doorKeeper
                                 punchOEFStorage:(PunchOEFStorage *)punchOEFStorage
                                    dateProvider:(DateProvider *)dateProvider
                                   dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        [self.doorKeeper addLogOutObserver:self];
        self.localPunchSerializer = [[LocalSQLPunchSerializer alloc] init];
        self.remoteSQLPunchSerializer = remoteSQLPunchSerializer;
        self.localSQLPunchDeserializer = localSQLPunchDeserializer;
        self.punchOEFStorage = punchOEFStorage;
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
    }
    
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)storeRemotePunch:(RemotePunch *)remotePunch
{

    NSMutableDictionary *punchSQLDictionary = [self.remoteSQLPunchSerializer serializePunchForStorage:remotePunch];
    [punchSQLDictionary removeObjectForKey:@"lastSyncTime"];


    NSString *uri = punchSQLDictionary[@"uri"]!=nil && punchSQLDictionary[@"uri"]!=[NSNull null] ? punchSQLDictionary[@"uri"] : nil;

    NSString *requestID = punchSQLDictionary[@"request_id"]!=nil && punchSQLDictionary[@"request_id"]!=[NSNull null] ? punchSQLDictionary[@"request_id"]: nil;

    NSDictionary *resultSet = nil;

    if (uri)
    {
        resultSet = [self.sqliteStore readLastRowWithArgs:@{@"user_uri": punchSQLDictionary[@"user_uri"],@"uri": uri}];
    }
    else
    {
        resultSet = [self.sqliteStore readLastRowWithArgs:@{@"user_uri": punchSQLDictionary[@"user_uri"],@"request_id": requestID}];
    }

    if (resultSet)
    {
       [self.sqliteStore deleteRowWithArgs:@{@"request_id": resultSet[@"request_id"]}];
       [self.sqliteStore insertRow:punchSQLDictionary];
    }
    else
    {
        [self.sqliteStore insertRow:punchSQLDictionary];
    }



    if (remotePunch.oefTypesArray) {
        [self.punchOEFStorage storePunchOEFArray:remotePunch.oefTypesArray forPunch:remotePunch];
    }
    
}

- (id<Punch>) mostRecentPunch
{
    NSDictionary *userSessionFilter = @{@"user_uri": [self.userSession currentUserURI]};
    NSDictionary *mostRecentPunchDictionary = [self.sqliteStore readRowWhere:userSessionFilter withMaxValueFor:@"date"];
    id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:mostRecentPunchDictionary punchOEFStorage:self.punchOEFStorage];

    return punch;
}

- (id<Punch>) mostRecentPunchForUserUri:(NSString *)userUri
{
    NSDictionary *userSessionFilter = @{@"user_uri": userUri};
    NSDictionary *mostRecentPunchDictionary = [self.sqliteStore readRowWhere:userSessionFilter withMaxValueFor:@"date"];
    id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:mostRecentPunchDictionary punchOEFStorage:self.punchOEFStorage];

    return punch;
}

- (NSArray *)recentPunches
{
    NSDictionary *userSessionFilter = @{@"user_uri": [self.userSession currentUserURI]};
    NSArray *mostRecentPunches = [self.sqliteStore readAllRowsWithArgs:userSessionFilter];
    NSMutableArray *punchArray = [NSMutableArray array];
    
    for (NSDictionary *sqlPunchDictionary in mostRecentPunches) {
        id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:sqlPunchDictionary punchOEFStorage:self.punchOEFStorage];
        [punchArray addObject:punch];
    }
    return punchArray;
}

- (NSArray *)recentPunchesForUserUri:(NSString *)userUri
{
    NSDictionary *userSessionFilter = @{@"user_uri": userUri};
    NSArray *mostRecentPunches = [self.sqliteStore readAllRowsWithArgs:userSessionFilter];
    NSMutableArray *punchArray = [NSMutableArray array];

    for (NSDictionary *sqlPunchDictionary in mostRecentPunches) {
        id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:sqlPunchDictionary punchOEFStorage:self.punchOEFStorage];
        [punchArray addObject:punch];
    }
    return punchArray;
}

- (NSArray *)allRemotePunchesForDay:(NSDate *)date userUri:(NSString *)userUri
{
    NSString *presentDate = [self.dateFormatter stringFromDate:date];
    NSArray *punchesArray =[self.sqliteStore readAllRowsWithArgs: @{@"user_uri": userUri, @"punchSyncStatus":@(RemotePunchStatus)}];
    NSMutableArray *todayPunchesArray = [NSMutableArray array];
    for (NSDictionary *sqlPunchDictionary in punchesArray) {
        id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:sqlPunchDictionary punchOEFStorage:self.punchOEFStorage];
        
        if(![punch respondsToSelector:@selector(syncedWithServer)]){
            return todayPunchesArray;
        }
        
        if (punch.syncedWithServer)
        {
            NSString *punchDate = [self.dateFormatter stringFromDate:punch.date];
            if ([punchDate isEqualToString:presentDate])
            {
                [todayPunchesArray addObject:punch];
            }
        }
    }
    return todayPunchesArray;
}

- (NSArray *)allPunches {
    NSArray *allTimePunches = [self.sqliteStore readAllRows];
    return allTimePunches;
}

- (NSArray *)allPunchesForDay:(NSDate *)date userUri:(NSString *)userUri
{
    NSString *presentDate = [self.dateFormatter stringFromDate:date];
    NSArray *punchesArray =[self.sqliteStore readAllRowsWithArgs: @{@"user_uri": userUri}];
    NSMutableArray *todayPunchesArray = [NSMutableArray array];
    for (NSDictionary *sqlPunchDictionary in punchesArray) {
        id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:sqlPunchDictionary punchOEFStorage:self.punchOEFStorage];
        NSString *punchDate = [self.dateFormatter stringFromDate:punch.date];
        if ([punchDate isEqualToString:presentDate]) {
            [todayPunchesArray addObject:punch];
        }

    }
    return todayPunchesArray;
}

- (NSArray *)recentTwoPunches
{
    NSDictionary *userSessionFilter = @{@"user_uri": [self.userSession currentUserURI]};
    NSArray *mostRecentPunches = [self.sqliteStore readRowWhere:userSessionFilter
                                                       rowLimit:2
                                                withMaxValueFor:@"date"];
    NSMutableArray *punchArray = [NSMutableArray array];
    
    for (NSDictionary *sqlPunchDictionary in mostRecentPunches) {
        id<Punch> punch = [self.localSQLPunchDeserializer deserializeSingleSQLPunch:sqlPunchDictionary punchOEFStorage:self.punchOEFStorage];
        [punchArray addObject:punch];
    }
    return punchArray;
}


- (void)updateSyncStatusToRemoteAndSaveWithPunch:(id<Punch>)punch withRemoteUri:(NSString *)uri
{
    NSDictionary *whereArgsWithDate = @{@"user_uri": punch.userURI, @"request_id":punch.requestID};
    NSDictionary *updatedRowDictionary = nil;
    if (uri)
    {
        updatedRowDictionary = @{@"punchSyncStatus":@(RemotePunchStatus), @"lastSyncTime":[NSNull null], @"offline":@0, @"uri":uri};
    }
    else
    {
        updatedRowDictionary = @{@"punchSyncStatus":@(RemotePunchStatus), @"lastSyncTime":[NSNull null], @"offline":@0,};
    }

    [self.sqliteStore updateRow:updatedRowDictionary whereClause:whereArgsWithDate];
}

- (void)deleteOldRemotePunch:(RemotePunch *)remotePunch
{
    NSDictionary *whereArgs = @{@"user_uri": remotePunch.userURI, @"request_id":remotePunch.requestID};
    [self.sqliteStore deleteRowWithArgs:whereArgs];
}

- (void)deleteAllPreviousPunches:(NSString *)userUri
{
    [self deletePreviousPunchesForNonCurrentUser:userUri];
}

-(void)deleteAllPunchesForDate:(NSDate *)date
{

    NSDateComponents *currentDateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];

    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:currentDateComps];

    NSDateComponents *components = [[NSDateComponents alloc] init];

    [components setDay:1];

    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:startDate options:0];


    [self.sqliteStore deleteRowWithStringArgs:[NSString stringWithFormat:@"punchSyncStatus='%lu' AND DATE between '%@' AND '%@'",(long)RemotePunchStatus,startDate,endDate]];
}

- (void)updateIsTimeEntryAvailableColumnMatchingClientUri:(NSString *)clientUri projectUri:(NSString *)projectUri taskUri:(NSString *)taskUri isTimeEntryAvailable:(BOOL)isTimeEntryAvailable {

    NSDictionary *updateRowDictionary = @{@"is_time_entry_available":[NSNumber numberWithBool:isTimeEntryAvailable]};
    NSDictionary *whereArgs = @{@"client_uri": clientUri, @"project_uri":projectUri, @"task_uri":taskUri};
    [self.sqliteStore updateRow:updateRowDictionary whereClause:whereArgs];
}

#pragma mark - Private

- (void)deletePreviousPunchesForNonCurrentUser:(NSString *)currentUserUri {
    NSArray *nonCurrentUserUrifilteredPunches = [[self allPunches] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(user_uri != %@)", currentUserUri]];

    if([nonCurrentUserUrifilteredPunches count] == 0) {
        return;
    }
    
    NSString *stringArgs = [NSString stringWithFormat:@"user_uri != '%@'", currentUserUri];
    [self.sqliteStore deleteRowWithStringArgs:stringArgs];
}


#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.sqliteStore deleteAllRows];
    [self.punchOEFStorage deleteAllPunchOEF];
}


@end
