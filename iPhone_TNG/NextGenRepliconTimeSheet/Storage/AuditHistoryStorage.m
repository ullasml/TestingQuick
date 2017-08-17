#import "AuditHistoryStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "AuditHistory.h"



@interface AuditHistoryStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) NSString *userUri;

@end

@implementation AuditHistoryStorage

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                         doorKeeper:(DoorKeeper *)doorKeeper
{
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        [self.doorKeeper addLogOutObserver:self];
    }
    
    return self;
}

-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
}

-(void)storePunchLogs:(NSArray*)punchLogs
{
    if (punchLogs.count) {
        for (NSDictionary *auditHistory in punchLogs) {
            NSArray *history = auditHistory[@"records"];
            NSUInteger historyCount = history.count;
            if (historyCount> 0 ) {
                for (int index = 0 ; index < historyCount; index++) {
                    NSString *log = history[index][@"displayText"];
                    NSDictionary *recordToInsert =  [self dictionaryWithPunchLog:log uri:auditHistory[@"uri"]];
                    [self.sqliteStore insertRow:recordToInsert];
                }
            }
        }
    }
}

-(NSArray*)getPunchLogs:(NSArray*)uriArray
{
    return [self allPunchLogs:uriArray];
}

-(void)deleteAllRows
{
    [self.sqliteStore deleteAllRows];
}

#pragma mark - Private

-(NSDictionary*)dictionaryWithPunchLog:(NSString*)log uri:(NSString*)uri
{
    NSDictionary *dictionary = @{@"uri" : uri,  @"displayText" : log};
    return dictionary;
}

-(NSArray*)allPunchLogs:(NSArray*)uriArray
{
    NSMutableArray *logs =  [NSMutableArray array];
    for (NSString* uri in uriArray) {
        NSArray *allPunchLogs = [self.sqliteStore readAllRowsWithArgs:@{@"uri": uri}];
        if (allPunchLogs.count) {
            AuditHistory *auditHistory = [self punchLogsFromDictionaries:allPunchLogs];
            [logs addObject:auditHistory];
        }
    }
    return logs.count > 0 ? logs : nil;
}

-(AuditHistory*)punchLogsFromDictionaries:(NSArray*)punchLogs
{
    AuditHistory *auditHistory;
    NSString *uri = punchLogs[0][@"uri"];
    NSMutableArray *historyArray = [NSMutableArray array];
    for (NSDictionary*logDictionary in punchLogs) {
        [historyArray addObject:logDictionary[@"displayText"]];
    }
    auditHistory =  [[AuditHistory alloc] initWithHistory:historyArray uri:uri];
    return auditHistory;
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.sqliteStore deleteAllRows];
}

@end
