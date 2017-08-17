#import "ViolationsStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "Violation.h"
#import "RemotePunch.h"
#import "Enum.h"


@interface ViolationsStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;

@end

@implementation ViolationsStorage


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


-(void)storePunchViolations:(NSArray*)punches
{
    if (punches.count) {
        for (RemotePunch *remotePunch in punches) {
            NSArray *violations = remotePunch.violations;
            NSUInteger violationsCount = violations.count;
            if (violationsCount> 0 ) {
                for (int index = 0 ; index < violationsCount; index++) {
                    Violation *violation = violations[index];
                    NSString *message = violation.title;
                    NSDictionary *recordToInsert =  [self dictionaryWithViolations:message uri:remotePunch.uri];
                    [self.sqliteStore insertRow:recordToInsert];
                }
            }
        }
    }
}

-(NSArray*)getPunchViolations:(NSString*)uri
{
    return [self punchViolations:uri];
}

-(void)deleteAllRows
{
    [self.sqliteStore deleteAllRows];
}

#pragma mark - Private

-(NSDictionary*)dictionaryWithViolations:(NSString*)log uri:(NSString*)uri
{
    NSDictionary *dictionary = @{@"uri" : uri,  @"displayText" : log};
    return dictionary;
}

-(NSArray*)punchViolations:(NSString*)uri
{
    NSMutableArray *violations =  [NSMutableArray array];
    NSArray *allPunchViolations = [self.sqliteStore readAllRowsWithArgs:@{@"uri": uri}];
    if (allPunchViolations.count) {
        for (NSDictionary *violationDictionary in allPunchViolations) {
            Violation *violation = [self punchViolationsFromDictionaries:violationDictionary];
            [violations addObject:violation];
        }
    }
    return violations;
}

-(Violation*)punchViolationsFromDictionaries:(NSDictionary*)violationDictionary
{
    Violation *violation;
    NSString *title = violationDictionary[@"displayText"];
    violation =  [[Violation alloc]initWithSeverity:ViolationSeverityWarning waiver:nil title:title];
    return violation;
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.sqliteStore deleteAllRows];
}

@end
