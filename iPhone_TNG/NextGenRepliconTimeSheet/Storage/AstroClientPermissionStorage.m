
#import "AstroClientPermissionStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"

@interface AstroClientPermissionStorage ()

@property (nonatomic) SQLiteTableStore  *sqliteStore;
@property (nonatomic) DoorKeeper        *doorKeeper;
@property (nonatomic) id<UserSession>   userSession;
@property (nonatomic) NSString          *userUri;

@end

static NSString *const UserHasClientPermission               = @"has_client_permission";

@implementation AstroClientPermissionStorage

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

- (void)persistUserHasClientPermission:(NSNumber *)userHasClientPermission{
    NSMutableDictionary *permissionsDictionary = [@{
                                                        UserHasClientPermission: userHasClientPermission
                                                        } mutableCopy];
    NSDictionary *currentUserFilter = [self currentUserFilter];
    [permissionsDictionary addEntriesFromDictionary:currentUserFilter];
    
    NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    if (resultSet) {
        [self.sqliteStore updateRow:permissionsDictionary whereClause:nil];
    } else {
        [self.sqliteStore insertRow:permissionsDictionary];
    }
}


- (BOOL)userHasClientPermission
{
    return [self readPermission:UserHasClientPermission];
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (BOOL)readPermission:(NSString *)permissionName
{
    NSDictionary *currentUserFilter = [self currentUserFilter];
    NSDictionary *resultsDictionary = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    return [resultsDictionary[permissionName] boolValue];
}

- (NSDictionary *)currentUserFilter
{
    NSString *currentUserUri = nil;
    if (self.userUri == nil|| [self.userUri isKindOfClass:[NSNull class]])
        currentUserUri = [self.userSession currentUserURI];
    else
        currentUserUri = self.userUri;

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
