
#import "ExpenseClientStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "ClientType.h"

@interface ExpenseClientStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;


@end

static NSString *const LastDownloadedExpenseClientPageNumber = @"LastDownloadedExpenseClientPageNumber";
static NSString *const LastDownloadedFilteredExpenseClientPageNumber = @"LastDownloadedFilteredExpenseClientPageNumber";


@implementation ExpenseClientStorage

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                       userDefaults:(NSUserDefaults *)userDefaults
                        userSession:(id<UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper

{
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        self.userDefaults = userDefaults;
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

-(NSNumber *)getLastPageNumber
{
    NSNumber *lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedExpenseClientPageNumber];
    if (lastDownlaodedPageNumber == nil || lastDownlaodedPageNumber == (id)[NSNull null]) {
        return @1;
    }
    return lastDownlaodedPageNumber;
}

-(void)updatePageNumber
{
    NSNumber *lastDownlaodedPageNumber = [self getLastPageNumber];
    NSInteger newPage = [lastDownlaodedPageNumber integerValue]+1;
    NSNumber *updatedPageNumber = [NSNumber numberWithInteger:newPage];
    [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedExpenseClientPageNumber];
}

-(void)resetPageNumber
{
    [self.userDefaults removeObjectForKey:LastDownloadedExpenseClientPageNumber];
}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredExpenseClientPageNumber];
    if (pageNumber == nil || pageNumber == (id)[NSNull null]) {
        return @1;
    }
    return pageNumber;
}

-(void)updatePageNumberForFilteredSearch
{
    NSNumber *lastPageNumber = [self getLastPageNumberForFilteredSearch];
    NSInteger newPage = [lastPageNumber integerValue]+1;
    NSNumber *updatedPageNumber = [NSNumber numberWithInteger:newPage];
    [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredExpenseClientPageNumber];
}

-(void)resetPageNumberForFilteredSearch
{
    [self.userDefaults removeObjectForKey:LastDownloadedFilteredExpenseClientPageNumber];
}

-(void)deleteAllClients
{
    [self.sqliteStore deleteAllRows];
}

-(void)storeClients:(NSArray *)clients
{
    for (ClientType *client in clients) {
        NSDictionary *clientTypeDictionary = [self dictionaryWithClient:client];
        NSDictionary *clientFilter = @{@"uri": client.uri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:clientFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:clientTypeDictionary whereClause:nil];
        } else {
            [self.sqliteStore insertRow:clientTypeDictionary];
        }
    }
}

-(NSArray *)getAllClients
{
    NSArray *clients = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": [self.userSession currentUserURI]}];
    return [self serializeClientTypeForClients:clients];
    
}

-(ClientType *)getClientInfoForUri:(NSString *)clientUri
{
    NSArray *clients = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": [self.userSession currentUserURI],
                                                               @"uri":clientUri}];
    return [self serializeClientTypeForClients:clients].lastObject;
    
}

-(NSArray *)getClientsWithMatchingText:(NSString *)text
{
    NSArray *clients = [self.sqliteStore readAllRowsFromColumn:@"name" pattern:text];
    return [self serializeClientTypeForClients:clients];
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    NSArray *allUserUris = [self.sqliteStore readAllDistinctRowsFromColumn:@"user_uri"];
    for (NSDictionary *user in allUserUris) {
        NSString *userUri = user[@"user_uri"];
        if (![userUri isEqualToString:[self.userSession currentUserURI]]) {
            [self.sqliteStore deleteRowWithArgs:@{@"user_uri": userUri}];
        }
    }
}

#pragma mark - Private

- (NSDictionary *)dictionaryWithClient:(ClientType *)client
{
    return @{@"name": client.name,
             @"uri": client.uri,
             @"user_uri":[self.userSession currentUserURI]
             };
}

-(NSArray *)serializeClientTypeForClients:(NSArray *)clients
{
    NSMutableArray *clientTypes = [NSMutableArray arrayWithCapacity:clients.count];
    ClientType *clientType = [self addNoneClientDictionary];
    [clientTypes addObject:clientType];
    for (NSDictionary *clientTypeDictionary in clients) {
        NSString *name = clientTypeDictionary[@"name"];
        NSString *uri = clientTypeDictionary[@"uri"];
        ClientType *clientType = [[ClientType alloc] initWithName:name uri:uri];
        [clientTypes addObject:clientType];
    }
    return [clientTypes copy];
}

-(ClientType *)addNoneClientDictionary
{
    return [[ClientType alloc] initWithName:RPLocalizedString(@"None", @"") uri:nil];
}

@end
