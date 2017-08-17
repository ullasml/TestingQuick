
#import "DefaultActivityStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"

@interface DefaultActivityStorage ()

@property (nonatomic) SQLiteTableStore  *sqliteStore;
@property (nonatomic) DoorKeeper        *doorKeeper;
@property (nonatomic) id<UserSession>   userSession;
@property (nonatomic) NSString          *userUri;

@end

static NSString *const DefaultActivityName               = @"default_activity_name";
static NSString *const DefaultActivityUri                = @"default_activity_uri";

@implementation DefaultActivityStorage


- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                        userSession:(id<UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper

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


-(void)setUpWithUserUri:(NSString*)userUri
{
    self.userUri = userUri;
}

-(void)persistDefaultActivityName:(NSString *)defaultActivityName defaultActivityUri:(NSString*)defaultActivityUri{
    NSMutableDictionary *detailsDictionary = [@{
                                                    DefaultActivityName: defaultActivityName,
                                                    DefaultActivityUri: defaultActivityUri
                                                    } mutableCopy];
    NSDictionary *currentUserFilter = [self currentUserFilter];
    [detailsDictionary addEntriesFromDictionary:currentUserFilter];
    
    NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    if (resultSet) {
        [self.sqliteStore updateRow:detailsDictionary whereClause:nil];
    } else {
        [self.sqliteStore insertRow:detailsDictionary];
    }
}


-  (NSDictionary*)defaultActivityDetails
{
    return [self readDefaultActivity];
}

#pragma mark - Private

- (NSDictionary*)readDefaultActivity
{
    NSDictionary *currentUserFilter = [self currentUserFilter];
    NSDictionary *resultsDictionary = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    return resultsDictionary;
}

- (NSDictionary *)currentUserFilter
{
    NSString *currentUserUri = nil;
    if (self.userUri == nil|| [self.userUri isKindOfClass:[NSNull class]])
        currentUserUri = [self.userSession currentUserURI];
    else
        currentUserUri = self.userUri;

    if (currentUserUri==nil)
    {
        currentUserUri = @"";
    }

    return @{@"user_uri": currentUserUri};
}


#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    NSArray *allUserUris = [self.sqliteStore readAllDistinctRowsFromColumn:@"user_uri"];
    for (NSDictionary *user in allUserUris) {
        NSString *userUri = user[@"user_uri"];
        [self.sqliteStore deleteRowWithArgs:@{@"user_uri": userUri}];
    }
}

@end
