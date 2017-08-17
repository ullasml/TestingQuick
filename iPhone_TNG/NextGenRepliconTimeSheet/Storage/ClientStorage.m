
#import "ClientStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "ClientType.h"


@interface ClientStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) NSString *userUri;
@property (nonatomic) FlowType flowType;
@end

static NSString *const LastDownloadedClientPageNumber = @"LastDownloadedClientPageNumber";
static NSString *const LastDownloadedFilteredClientPageNumber = @"LastDownloadedFilteredClientPageNumber";
static NSString *const SupervisorLastDownloadedClientPageNumber = @"SupervisorLastDownloadedClientPageNumber";
static NSString *const SupervisorLastDownloadedFilteredClientPageNumber = @"SupervisorLastDownloadedFilteredClientPageNumber";



@implementation ClientStorage

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

-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSNumber *)getLastPageNumber
{
    NSNumber *lastDownlaodedPageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedClientPageNumber];
    }
    else
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedClientPageNumber];
    }

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
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedClientPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedClientPageNumber];
    }

}

-(void)resetPageNumber
{
    if (self.flowType == UserFlowContext)
    {
         [self.userDefaults removeObjectForKey:LastDownloadedClientPageNumber];
    }
    else
    {
         [self.userDefaults removeObjectForKey:SupervisorLastDownloadedClientPageNumber];
    }

}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredClientPageNumber];
    }
    else
    {
        pageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedFilteredClientPageNumber];
    }

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
    if (self.flowType == UserFlowContext)
    {
       [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredClientPageNumber];
    }
    else
    {
       [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedFilteredClientPageNumber];
    }

}

-(void)resetPageNumberForFilteredSearch
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedFilteredClientPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedFilteredClientPageNumber];
    }

}

-(void)deleteAllClients
{
    if (self.flowType == UserFlowContext)
    {
        [self.sqliteStore deleteAllRows];
    }
    else
    {
        [self.sqliteStore deleteRowWithStringArgs:[NSString stringWithFormat:@"user_uri != '%@'",self.userSession.currentUserURI]];
    }
    

}

-(void)storeClients:(NSArray *)clients
{
    for (ClientType *client in clients) {
        NSDictionary *clientTypeDictionary = [self dictionaryWithClient:client];
        NSDictionary *clientFilter = @{@"uri": client.uri,@"user_uri": self.userUri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:clientFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:clientTypeDictionary whereClause:clientFilter];
        } else {
            [self.sqliteStore insertRow:clientTypeDictionary];
        }
    }
}

-(NSArray *)getAllClients
{
    NSArray *clients = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri}];
    return [self serializeClientTypeForClients:clients];

}

-(ClientType *)getClientInfoForUri:(NSString *)clientUri
{
    NSArray *clients = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri,
                                                               @"uri":clientUri}];
    return [self serializeClientTypeForClients:clients].firstObject;

}

-(NSArray *)getClientsWithMatchingText:(NSString *)text
{
    NSArray *clients = [self.sqliteStore readAllRowsFromColumn:@"name" where:@{@"user_uri": self.userUri} pattern:text];
    return [self serializeClientTypeForClients:clients];
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    NSArray *allUserUris = [self.sqliteStore readAllDistinctRowsFromColumn:@"user_uri"];
    for (NSDictionary *user in allUserUris) {
        NSString *userUri = user[@"user_uri"];
        if (![userUri isEqualToString:self.userUri]) {
            [self.sqliteStore deleteRowWithArgs:@{@"user_uri": userUri}];
        }
    }
}

#pragma mark - Private

- (NSDictionary *)dictionaryWithClient:(ClientType *)client
{
    return @{@"name": client.name,
             @"uri": client.uri,
             @"user_uri":self.userUri
             };
}

-(NSArray *)serializeClientTypeForClients:(NSArray *)clients
{
    NSMutableArray *clientTypes = [NSMutableArray arrayWithCapacity:clients.count];
    for (NSDictionary *clientTypeDictionary in clients) {
        NSString *name = clientTypeDictionary[@"name"];
        NSString *uri = clientTypeDictionary[@"uri"];
        ClientType *clientType = [[ClientType alloc] initWithName:name uri:uri];
        [clientTypes addObject:clientType];
    }
    return [clientTypes copy];
}

-(FlowType )flowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

@end
