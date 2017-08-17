#import "BreakTypeStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"


@interface BreakTypeStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;

@end


@implementation BreakTypeStorage

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                         doorKeeper:(DoorKeeper *)doorKeeper
                        userSession:(id<UserSession>)userSession
{
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        [self.doorKeeper addLogOutObserver:self];
    }

    return self;
}

- (NSArray *)allBreakTypesForUser:(NSString *)useruri
{
    NSArray *breakTypeDictionaries = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": useruri}];
    NSMutableArray *breakTypes = [NSMutableArray arrayWithCapacity:breakTypeDictionaries.count];
    for (NSDictionary *breakTypeDictionary in breakTypeDictionaries) {
        NSString *name = breakTypeDictionary[@"name"];
        NSString *uri = breakTypeDictionary[@"uri"];
        BreakType *breakType = [[BreakType alloc] initWithName:name uri:uri];
        [breakTypes addObject:breakType];
    }

    return [breakTypes copy];
}

- (void)storeBreakTypes:(NSArray *)breakTypes forUser:(NSString *)useruri
{
    for (BreakType *breakType in breakTypes) {
        NSDictionary *breakTypeDictionary = [self dictionaryWithBreakType:breakType forUser:useruri];
        [self.sqliteStore insertRow:breakTypeDictionary];
    }
}

- (void)removeAllBreakTypes
{
    [self.sqliteStore deleteAllRows];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self removeAllBreakTypes];
}

#pragma mark - Private

- (NSDictionary *)dictionaryWithBreakType:(BreakType *)breakType forUser:(NSString *)userUri
{
    return @{@"name": breakType.name,
             @"uri": breakType.uri,
             @"user_uri": userUri};
}

@end
