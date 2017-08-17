#import "FailedPunchErrorStorage.h"
#import "SQLiteTableStore.h"
#import "Punch.h"
#import "BreakType.h"
#import "DoorKeeper.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"

@interface FailedPunchErrorStorage ()

@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@end

@implementation FailedPunchErrorStorage

- (instancetype)initWithUserSqliteStore:(SQLiteTableStore *)sqliteStore
                            userSession:(id<UserSession>)userSession
                             doorKeeper:(DoorKeeper *)doorKeeper {
    self = [super init];
    if (self) {
        self.userSession = userSession;
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        [self.doorKeeper addLogOutObserver:self];
    }
    return self;
}
#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)storeFailedPunchError:(NSDictionary*)errorDictionary punch:(id<Punch>)punch{
    NSDictionary *errorDetailsDictionary = [self dictionaryWithPunch:punch errorDictionary:errorDictionary];
    [self.sqliteStore insertRow:errorDetailsDictionary];
}

- (NSArray*)getFailedPunchErrors
{
    NSArray *punchErrors = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": [self.userSession currentUserURI]}];
    return punchErrors;
}

-(void) deletePunchErrors:(NSArray*)punchErrors
{
    for (NSDictionary *errorInfo in punchErrors) {
        NSDictionary *argsDictionary = @{@"request_id": errorInfo[@"request_id"]};
        [self.sqliteStore deleteRowWithArgs:argsDictionary];
    }
}

#pragma mark - <DoorKeeperLogOutObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.sqliteStore deleteAllRows];
}

#pragma nark - Private

-(NSDictionary*)dictionaryWithPunch:(id<Punch>)punch errorDictionary:(NSDictionary*)errorDictionary
{
    NSDictionary *descriptionsMap = @{@(PunchActionTypePunchIn): RPLocalizedString(@"Clocked In", nil),
                                      @(PunchActionTypeTransfer): RPLocalizedString(@"Transferred", nil),
                                      @(PunchActionTypeStartBreak): [NSString stringWithFormat:@"%@ %@", punch.breakType.name, RPLocalizedString(@"Break", nil)] ?: RPLocalizedString(@"Break", nil),
                                      @(PunchActionTypePunchOut): RPLocalizedString(@"Clocked Out", nil),};
    
    NSMutableDictionary *punchDictionary = [NSMutableDictionary dictionary];
    
    NSDate *punchDate = [punch date];
    
    if (punchDate) {
        NSDictionary *punchDateDictionary = @{@"date": punchDate};
        [punchDictionary addEntriesFromDictionary:punchDateDictionary];
    }
    
    NSDictionary *punchActionTypeDictionary = @{@"action_type": descriptionsMap[@(punch.actionType)]};
    [punchDictionary addEntriesFromDictionary:punchActionTypeDictionary];
    
    
    if ([punch breakType]) {
        NSDictionary *breakTypeDictionary = @{@"break_name": [[punch breakType] name],};
        [punchDictionary addEntriesFromDictionary:breakTypeDictionary];
    }
    
    BOOL isClientValueAvailable = ([punch client] && (punch.client.uri != nil && ![punch.client.uri isKindOfClass:[NSNull class]]));
    if (isClientValueAvailable) {
        NSDictionary *clientTypeDictionary = @{@"client_name": punch.client.name,};
        [punchDictionary addEntriesFromDictionary:clientTypeDictionary];
    }
    BOOL isProjectValueAvailable = ([punch project] && (punch.project.uri != nil && ![punch.project.uri isKindOfClass:[NSNull class]]));
    if (isProjectValueAvailable) {
        NSDictionary *projectTypeDictionary = @{@"project_name": punch.project.name,};
        [punchDictionary addEntriesFromDictionary:projectTypeDictionary];
    }
    BOOL isTaskValueAvailable = ([punch task] && (punch.task.uri != nil && ![punch.task.uri isKindOfClass:[NSNull class]]));
    if (isTaskValueAvailable) {
        NSDictionary *taskTypeDictionary = @{@"task_name": punch.task.name,};
        [punchDictionary addEntriesFromDictionary:taskTypeDictionary];
    }
    BOOL isActivityValueAvailable = ([punch activity] && (punch.activity.uri != nil && ![punch.activity.uri isKindOfClass:[NSNull class]]));
    if (isActivityValueAvailable) {
        NSDictionary *activityTypeDictionary = @{@"activity_name": punch.activity.name,};
        [punchDictionary addEntriesFromDictionary:activityTypeDictionary];
    }
    
    NSString *requestID = [[punch requestID] mutableCopy];
    
    if (requestID) {
        NSDictionary *requestIDDictionary = @{@"request_id": requestID};
        [punchDictionary addEntriesFromDictionary:requestIDDictionary];
    }
    
    [punchDictionary addEntriesFromDictionary:@{@"error_msg": errorDictionary[@"displayText"]}];
    [punchDictionary addEntriesFromDictionary:@{@"user_uri": [self.userSession currentUserURI]}];

    return punchDictionary;
}

@end
