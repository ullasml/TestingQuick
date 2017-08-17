
#import "OEFDropdownStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "UserPermissionsStorage.h"
#import "OEFDropDownType.h"


@interface OEFDropdownStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) NSString *dropDownOEFUri;
@property (nonatomic) FlowType flowType;
@property (nonatomic) NSString *userUri;
@end


@implementation OEFDropdownStorage

static NSString *const LastDownloadedOEFDropDownOptionsPageNumber = @"LastDownloadedOEFDropDownOptionsPageNumber";
static NSString *const LastDownloadedFilteredOEFDropDownOptionsPageNumber = @"LastDownloadedFilteredOEFDropDownOptionsPageNumber";
static NSString *const SupervisorLastDownloadedOEFDropDownOptionsPageNumber = @"SupervisorLastDownloadedOEFDropDownOptionsPageNumber";
static NSString *const SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber = @"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber";

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                   sqliteStore:(SQLiteTableStore *)sqliteStore
                                  userDefaults:(NSUserDefaults *)userDefaults
                                   userSession:(id <UserSession>)userSession
                                    doorKeeper:(DoorKeeper *)doorKeeper {
    self = [super init];
    if (self)
    {
        self.userPermissionsStorage = userPermissionsStorage;
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        self.userDefaults = userDefaults;
        [self.doorKeeper addLogOutObserver:self];
    }

    return self;
}

-(void)setUpWithDropDownOEFUri:(NSString *)dropDownOEFUri userUri:(NSString *)userUri
{
    self.dropDownOEFUri = dropDownOEFUri;
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
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedOEFDropDownOptionsPageNumber];
    }
    else
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedOEFDropDownOptionsPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedOEFDropDownOptionsPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedOEFDropDownOptionsPageNumber];
    }

}

-(void)resetPageNumber
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedOEFDropDownOptionsPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedOEFDropDownOptionsPageNumber];
    }

}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredOEFDropDownOptionsPageNumber];
    }
    else
    {
        pageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredOEFDropDownOptionsPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber];
    }

}

-(void)resetPageNumberForFilteredSearch
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedFilteredOEFDropDownOptionsPageNumber];
    }
    else
    {
       [self.userDefaults removeObjectForKey:SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber];
    }

}

-(void)deleteAllOEFDropDownOptions
{
    [self.sqliteStore deleteAllRows];

}

-(void)deleteAllOEFDropDownOptionsForOEFUri:(NSString *)oefUri
{
    [self.sqliteStore deleteRowWithArgs:@{@"oef_uri":oefUri}];

}

-(void)storeOEFDropDownOptions:(NSArray *)dropDownOptionValues
{
    for (OEFDropDownType *oefDropDownType in dropDownOptionValues) {
        NSDictionary *oefDropDownTypeTypeDictionary = [self dictionaryWithOEFDropDownType:oefDropDownType];
        NSDictionary *oefDropDownTypeFilter = @{@"uri": oefDropDownType.uri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:oefDropDownTypeFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:oefDropDownTypeTypeDictionary whereClause:oefDropDownTypeFilter];
        } else {
            [self.sqliteStore insertRow:oefDropDownTypeTypeDictionary];
        }
    }
}

-(NSArray *)getAllOEFDropDownOptions
{
    NSArray *oefDropDownOptions = [self.sqliteStore readAllRowsWithArgs:@{@"oef_uri": self.dropDownOEFUri}];
    return [self serializeOEFDropDownTypeForOEFDropDownOptions:oefDropDownOptions];

}

-(OEFDropDownType *)getOEFDropDownOptionsInfoForUri:(NSString *)oefDropDownOptionsUri
{
    NSArray *oefDropDownOptions = [self.sqliteStore readAllRowsWithArgs:@{
                                                               @"uri":oefDropDownOptionsUri,@"oef_uri": self.dropDownOEFUri}];
    return [self serializeOEFDropDownTypeForOEFDropDownOptions:oefDropDownOptions][1];

}

-(NSArray *)getOEFDropDownOptionsWithMatchingText:(NSString *)text
{

    NSArray *oefDropDownOptions = [self.sqliteStore readAllRowsFromColumn:@"name" where:@{@"oef_uri": self.dropDownOEFUri} pattern:text];
    return [self serializeOEFDropDownTypeForOEFDropDownOptions:oefDropDownOptions];
}

#pragma mark - <DoorKeeperObserver>




- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    NSArray *allUserUris = [self.sqliteStore readAllDistinctRowsFromColumn:@"user_uri"];
    for (NSDictionary *user in allUserUris) {
        NSString *userUri = user[@"user_uri"];
        if (![userUri isEqualToString:self.userUri]) {
            [self.sqliteStore deleteAllRows];
        }
    }
}

#pragma mark - Private

- (NSDictionary *)dictionaryWithOEFDropDownType:(OEFDropDownType *)oefDropDownType
{
    return @{@"name": oefDropDownType.name,
             @"uri": oefDropDownType.uri,
             @"oef_uri": self.dropDownOEFUri
             };
}

-(NSArray *)serializeOEFDropDownTypeForOEFDropDownOptions:(NSArray *)OEFDropDowns
{
    if (OEFDropDowns.count == 0) {
        return nil;
    }
    NSMutableArray *oefDropDownTypes = [NSMutableArray arrayWithCapacity:OEFDropDowns.count+1];

    OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil)
                                                    uri:nil];
    [oefDropDownTypes addObject:oefDropDownType];


    for (NSDictionary *oefDropDownTypeDictionary in OEFDropDowns) {
        NSString *name = oefDropDownTypeDictionary[@"name"];
        NSString *uri = oefDropDownTypeDictionary[@"uri"];
        OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc] initWithName:name uri:uri];
        [oefDropDownTypes addObject:oefDropDownType];
    }
    return [oefDropDownTypes copy];

}

-(FlowType )flowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}


@end

