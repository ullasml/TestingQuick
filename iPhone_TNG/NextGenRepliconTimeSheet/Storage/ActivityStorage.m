
#import "ActivityStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "Activity.h"
#import "UserPermissionsStorage.h"


@interface ActivityStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) NSString *userUri;
@property (nonatomic) FlowType flowType;

@end


@implementation ActivityStorage

static NSString *const LastDownloadedActivityPageNumber = @"LastDownloadedActivityPageNumber";
static NSString *const LastDownloadedFilteredActivityPageNumber = @"LastDownloadedFilteredActivityPageNumber";
static NSString *const SupervisorLastDownloadedActivityPageNumber = @"SupervisorLastDownloadedActivityPageNumber";
static NSString *const SupervisorLastDownloadedFilteredActivityPageNumber = @"SupervisorLastDownloadedFilteredActivityPageNumber";

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
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedActivityPageNumber];
    }
    else
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedActivityPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedActivityPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedActivityPageNumber];
    }

}

-(void)resetPageNumber
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedActivityPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedActivityPageNumber];
    }

}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredActivityPageNumber];
    }
    else
    {
        pageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedFilteredActivityPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredActivityPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedFilteredActivityPageNumber];
    }

}

-(void)resetPageNumberForFilteredSearch
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedFilteredActivityPageNumber];
    }
    else
    {
       [self.userDefaults removeObjectForKey:SupervisorLastDownloadedFilteredActivityPageNumber];
    }

}

-(void)deleteAllActivities
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

-(void)storeActivities:(NSArray *)activities
{
    for (Activity *activity in activities) {
        NSDictionary *activityTypeDictionary = [self dictionaryWithActivity:activity];
        NSDictionary *activityFilter = @{@"uri": activity.uri, @"user_uri": self.userUri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:activityFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:activityTypeDictionary whereClause:activityFilter];
        } else {
            [self.sqliteStore insertRow:activityTypeDictionary];
        }
    }
}

-(NSArray *)getAllActivities
{
    NSArray *activities = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri}];
    return [self serializeActivityTypeForActivities:activities];

}

-(Activity *)getActivityInfoForUri:(NSString *)activityUri
{
    NSArray *activities = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri,
                                                               @"uri":activityUri}];
    return [self serializeActivityTypeForActivities:activities].firstObject;

}

-(NSArray *)getActivitiesWithMatchingText:(NSString *)text
{

    NSArray *activities = [self.sqliteStore readAllRowsFromColumn:@"name" where:@{@"user_uri": self.userUri} pattern:text];
    return [self serializeActivityTypeForActivities:activities];
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

- (NSDictionary *)dictionaryWithActivity:(Activity *)activity
{
    return @{@"name": activity.name,
             @"uri": activity.uri,
             @"user_uri":self.userUri
             };
}

-(NSArray *)serializeActivityTypeForActivities:(NSArray *)activities
{
    if (activities.count == 0) {
        return nil;
    }
    NSMutableArray *activityTypes = [NSMutableArray arrayWithCapacity:activities.count+1];
    if (!self.userPermissionsStorage.isActivitySelectionRequired)
    {
        Activity *activity = [[Activity alloc] initWithName:RPLocalizedString(@"None", nil)
                                                        uri:nil];
        [activityTypes addObject:activity];
    }
    for (NSDictionary *activityDictionary in activities) {
        NSString *name = activityDictionary[@"name"];
        NSString *uri = activityDictionary[@"uri"];
        Activity *activity = [[Activity alloc] initWithName:name uri:uri];
        [activityTypes addObject:activity];
    }
    return [activityTypes copy];

}

-(FlowType )flowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

@end

