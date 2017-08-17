
#import "ProjectStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "Period.h"
#import "UserPermissionsStorage.h"
#import "Constants.h"

typedef enum {
    ClientUriTypeAnyClient = 1,
    ClientUriTypeNoClient = 2,
    ClientUriTypeSpecific = 3
}ClientUriType;

@interface ProjectStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) NSString *userUri;
@property (nonatomic) FlowType flowType;
@end

static NSString *const LastDownloadedProjectPageNumber = @"LastDownloadedProjectPageNumber";
static NSString *const LastDownloadedFilteredProjectPageNumber = @"LastDownloadedFilteredProjectPageNumber";
static NSString *const SupervisorLastDownloadedProjectPageNumber = @"SupervisorLastDownloadedProjectPageNumber";
static NSString *const SupervisorLastDownloadedFilteredProjectPageNumber = @"SupervisorLastDownloadedFilteredProjectPageNumber";



@implementation ProjectStorage

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

#pragma mark - Pagination Helper Methods

-(NSNumber *)getLastPageNumber
{
    NSNumber *lastDownlaodedPageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedProjectPageNumber];
    }
    else
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedProjectPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedProjectPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedProjectPageNumber];
    }

}

-(void)resetPageNumber
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedProjectPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedProjectPageNumber];
    }

}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredProjectPageNumber];
    }
    else
    {
        pageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedFilteredProjectPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredProjectPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedFilteredProjectPageNumber];
    }

}

-(void)resetPageNumberForFilteredSearch
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedFilteredProjectPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedFilteredProjectPageNumber];
    }

}

#pragma mark - DB Delete Method

-(void)deleteAllProjectsForClientUri:(NSString *)clientUri
{
    id project = [self getValueAfterCheckForNullForValue:clientUri];

    if (self.flowType == UserFlowContext)
    {
        NSDictionary *args = [self deleteQueryArgumentDictionaryBasedOnClientUriForUser:clientUri];
        if (project != [NSNull null] && args != nil)
        {
            [self.sqliteStore deleteRowWithArgs:args];
        }
        else
        {
            [self.sqliteStore deleteAllRows];
        }
    }
    else
    {
        NSString *args = [self deleteQueryStringArgumentDictionaryBasedOnClientUriForReportee:clientUri];
        [self.sqliteStore deleteRowWithStringArgs:args];
    }


}

#pragma mark - DB Write Methods

-(void)storeProjects:(NSArray *)projects
{
    for (ProjectType *project in projects) {

        NSDictionary *projectTypeDictionary = [self dictionaryWithProject:project];
        NSDictionary *projectFilter = @{@"uri": project.uri, @"user_uri": self.userUri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:projectFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:projectTypeDictionary whereClause:projectFilter];
        } else {
            [self.sqliteStore insertRow:projectTypeDictionary];
        }
    }
}

#pragma mark - DB Retrieve Methods

-(NSArray *)getAllProjectsForClientUri:(NSString *)clientUri
{
    NSArray *projects = [self.sqliteStore readAllRowsWithArgs:[self argumentDictionaryBasedOnClientUri:clientUri]];
    return [self serializeProjectTypeForProjects:projects];

}

-(ProjectType *)getProjectInfoForUri:(NSString *)projectUri
{
    NSArray *projects = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri":self.userUri,
                                                                @"uri":projectUri}];
    return [self serializeProjectTypeForProjects:projects].firstObject;
    
}

-(NSArray *)getProjectsWithMatchingText:(NSString *)text clientUri:(NSString *)clientUri
{
    NSArray *projects = [self.sqliteStore readAllRowsFromColumn:@"name" where:[self argumentDictionaryBasedOnClientUri:clientUri] pattern:text];
    return [self serializeProjectTypeForProjects:projects];
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

- (NSDictionary *)dictionaryWithProject:(ProjectType *)project
{
    ClientType *client = [project.client copy];
    Period *period = [project.projectPeriod copy];
    NSDate *startDate = [self getValueAfterCheckForNullForValue:period.startDate];
    NSDate *endDate = [self getValueAfterCheckForNullForValue:period.endDate];
    NSString *clientName = [self getValueAfterCheckForNullForValue:client.name];
    NSString *clientUri = [self getValueAfterCheckForNullForValue:client.uri];
    return @{
             @"uri":project.uri,
             @"name":project.name,
             @"client_uri":clientUri,
             @"client_name":clientName,
             @"start_date":startDate,
             @"end_date":endDate,
             @"hasTasksAvailableForTimeAllocation":@(project.hasTasksAvailableForTimeAllocation),
             @"isTimeAllocationAllowed":@(project.isTimeAllocationAllowed),
             @"user_uri":self.userUri
             };
}

-(NSArray *)serializeProjectTypeForProjects:(NSArray *)projects
{
    if (projects.count == 0) {
        return nil;
    }
    NSMutableArray *projectTypes = [NSMutableArray arrayWithCapacity:projects.count];
    for (NSDictionary *projectTypeDictionary in projects) {

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss +z";

        NSString *startDateString = projectTypeDictionary[@"start_date"];
        NSString *endDateString = projectTypeDictionary[@"end_date"];
        NSDate *startDate = [dateFormatter dateFromString:startDateString];
        NSDate *endDate = [dateFormatter dateFromString:endDateString];
        NSString *name = projectTypeDictionary[@"name"];
        NSString *uri = projectTypeDictionary[@"uri"];
        NSString *clientName = projectTypeDictionary[@"client_name"];
        NSString *clientUri = projectTypeDictionary[@"client_uri"];
        BOOL isTasksAvailable = [projectTypeDictionary[@"hasTasksAvailableForTimeAllocation"] boolValue];
        BOOL isTimeAllocationAllowed = [projectTypeDictionary[@"isTimeAllocationAllowed"] boolValue];

        Period *period = [[Period alloc]initWithStartDate:startDate endDate:endDate];
        ClientType *client = [[ClientType alloc]initWithName:clientName uri:clientUri];
        ProjectType *projectType = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:isTasksAvailable
                                                                       isTimeAllocationAllowed:isTimeAllocationAllowed
                                                                                 projectPeriod:period
                                                                                    clientType:client
                                                                                          name:name
                                                                                           uri:uri];
        [projectTypes addObject:projectType];
    }
    return [projectTypes copy];
}

-(id)getValueAfterCheckForNullForValue:(id)value
{
    if (value == nil || value == [NSNull null] ) {
        return [NSNull null];
    }
    return value;
}

-(FlowType )flowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

#pragma mark - Helper Methods

- (ClientUriType) getClientUriTypeFromUri:(NSString *)clientUri {
    ClientUriType clientUriType = ClientUriTypeSpecific;
    
    if ([clientUri isEqualToString:ClientTypeNoClientUri]) {
        clientUriType = ClientUriTypeNoClient;
    }
    else if ([clientUri isEqualToString:ClientTypeAnyClientUri] || !IsNotEmptyString(clientUri)) {
        clientUriType = ClientUriTypeAnyClient;
    }
    return clientUriType;
}

- (NSDictionary *)argumentDictionaryBasedOnClientUri:(NSString *)clientUri {
    NSDictionary *args = @{};
    ClientUriType clientUriType = [self getClientUriTypeFromUri:clientUri];
    switch (clientUriType) {
        case ClientUriTypeAnyClient:
            args = @{@"user_uri": self.userUri};
            break;
        case ClientUriTypeNoClient:
            args = @{@"user_uri": self.userUri,
                     @"client_uri":@"<null>"};
            break;
        case ClientUriTypeSpecific:
            args = @{@"user_uri": self.userUri,
                     @"client_uri":clientUri};
            break;
    }
    return args;
}

- (NSDictionary *)deleteQueryArgumentDictionaryBasedOnClientUriForUser:(NSString *)clientUri {
    NSDictionary *args = @{};
    ClientUriType clientUriType = [self getClientUriTypeFromUri:clientUri];
    switch (clientUriType) {
        case ClientUriTypeAnyClient:
            args = nil;
            break;
        case ClientUriTypeNoClient:
            args = @{@"client_uri":@"<null>"};
            break;
        case ClientUriTypeSpecific:
            args = @{@"client_uri": clientUri};
            break;
    }
    return args;
}

- (NSString *)deleteQueryStringArgumentDictionaryBasedOnClientUriForReportee:(NSString *)clientUri {
    NSString *args = nil;
    ClientUriType clientUriType = [self getClientUriTypeFromUri:clientUri];
    switch (clientUriType) {
        case ClientUriTypeAnyClient:
            args = [NSString stringWithFormat:@"user_uri != '%@'",self.userSession.currentUserURI];
            break;
        case ClientUriTypeNoClient:
            args = [NSString stringWithFormat:@"client_uri = '%@' AND user_uri != '%@'", @"<null>", self.userSession.currentUserURI];
            break;
        case ClientUriTypeSpecific:
            args = [NSString stringWithFormat:@"client_uri = '%@' AND user_uri != '%@'", clientUri, self.userSession.currentUserURI];
            break;
    }
    return args;
}

@end
