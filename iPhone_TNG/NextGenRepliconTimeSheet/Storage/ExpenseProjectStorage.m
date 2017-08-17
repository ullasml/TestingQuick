
#import "ExpenseProjectStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "UserPermissionsStorage.h"
#import "ProjectBillingType.h"
#import "ProjectTimeAndExpenseEntryType.h"

@interface ExpenseProjectStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end

static NSString *const LastDownloadedExpenseProjectPageNumber = @"LastDownloadedExpenseProjectPageNumber";
static NSString *const LastDownloadedFilteredExpenseProjectPageNumber = @"LastDownloadedFilteredExpenseProjectPageNumber";


@implementation ExpenseProjectStorage

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore
                       userDefaults:(NSUserDefaults *)userDefaults
                        userSession:(id<UserSession>)userSession
                         doorKeeper:(DoorKeeper *)doorKeeper userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage

{
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
        self.doorKeeper = doorKeeper;
        self.userSession = userSession;
        self.userDefaults = userDefaults;
        [self.doorKeeper addLogOutObserver:self];
        self.userPermissionsStorage = userPermissionsStorage;
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
    NSNumber *lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedExpenseProjectPageNumber];
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
    [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedExpenseProjectPageNumber];
}

-(void)resetPageNumber
{
    [self.userDefaults removeObjectForKey:LastDownloadedExpenseProjectPageNumber];
}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredExpenseProjectPageNumber];
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
    [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredExpenseProjectPageNumber];
}

-(void)resetPageNumberForFilteredSearch
{
    [self.userDefaults removeObjectForKey:LastDownloadedFilteredExpenseProjectPageNumber];
}

-(void)deleteAllProjectsForClientUri:(NSString *)clientUri
{
    id project = [self getValueAfterCheckForNullForValue:clientUri];
    
    if (project != [NSNull null])
    {
        [self.sqliteStore deleteRowWithArgs:@{@"client_uri": clientUri}];
    }
    else
    {
        [self.sqliteStore deleteAllRows];
    }
}

-(void)storeProjects:(NSArray *)projects
{
    for (ProjectType *project in projects) {
        
        NSDictionary *projectTypeDictionary = [self dictionaryWithProject:project];
        NSDictionary *projectFilter = @{@"uri": project.uri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:projectFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:projectTypeDictionary whereClause:nil];
        } else {
            [self.sqliteStore insertRow:projectTypeDictionary];
        }
    }
}

-(NSArray *)getAllProjectsForClientUri:(NSString *)clientUri
{
    NSArray *projects;
    if (clientUri !=nil && clientUri != (id) [NSNull null])
    {
        projects = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": [self.userSession currentUserURI],
                                                           @"client_uri":clientUri}];
    }
    else
    {
        projects = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": [self.userSession currentUserURI]
                                                           }];
    }
    
    return [self serializeProjectTypeForProjects:projects];
    
}

-(ProjectType *)getProjectInfoForUri:(NSString *)projectUri
{
    NSArray *projects = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri":[self.userSession currentUserURI],
                                                                @"uri":projectUri}];
    return [self serializeProjectTypeForProjects:projects].lastObject;
    
}

-(NSArray *)getProjectsWithMatchingText:(NSString *)text clientUri:(NSString *)clientUri
{
    NSArray *projects;
    if (clientUri != nil && clientUri != (id)[NSNull null] && clientUri.length > 0)
    {
        projects = [self.sqliteStore readAllRowsFromColumn:@"name"
                                                     where:@{@"client_uri": clientUri}
                                                   pattern:text];
        
    }
    else
    {
        projects = [self.sqliteStore readAllRowsFromColumn:@"name" pattern:text];
    }
    
    return [self serializeProjectTypeForProjects:projects];
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

- (NSDictionary *)dictionaryWithProject:(ProjectType *)project
{
    ClientType *client = [project.client copy];
    ProjectBillingType *billingType = [project.projectBillingType copy];
    ProjectTimeAndExpenseEntryType *projectTimeAndEntryType = [project.projectTimeAndExpenseEntryType copy];
    
    NSString *billingTypeDisplayText = [self getValueAfterCheckForNullForValue:billingType.displayText];
    NSString *billingTypeUri = [self getValueAfterCheckForNullForValue:billingType.projectBillingTypeUri];
    NSString *projectTimeAndEntryTypeDisplayText = [self getValueAfterCheckForNullForValue:projectTimeAndEntryType.displayText];
    NSString *projectTimeAndEntryTypeUri = [self getValueAfterCheckForNullForValue:projectTimeAndEntryType.projectTimeAndExpenseEntryTypeUri];
    NSString *clientName = [self getValueAfterCheckForNullForValue:client.name];
    NSString *clientUri = [self getValueAfterCheckForNullForValue:client.uri];
    return @{
             @"uri":project.uri,
             @"name":project.name,
             @"client_uri":clientUri,
             @"client_name":clientName,
             @"hasTasksAvailableForExpenseEntry":@(project.hasTasksAvailableForTimeAllocation),
             @"user_uri":[self.userSession currentUserURI],
             @"billing_type_display_text":billingTypeDisplayText,
             @"billing_type_uri":billingTypeUri,
             @"time_expense_entry_display_text":projectTimeAndEntryTypeDisplayText,
             @"time_expense_entry_uri":projectTimeAndEntryTypeUri
             };
}

-(NSArray *)serializeProjectTypeForProjects:(NSArray *)projects
{
    if (projects.count == 0) {
        return nil;
    }
    NSMutableArray *projectTypes = [NSMutableArray arrayWithCapacity:projects.count];

    if (!self.userPermissionsStorage.isExpensesProjectMandatory) {
        NSDictionary *projectTypeDictionary = projects.firstObject;
        NSString *clientUri = projectTypeDictionary[@"client_uri"];
        if (clientUri==nil  || [clientUri isKindOfClass:[NSNull class]] || [clientUri isEqualToString:@""] ||[clientUri isEqualToString:@"<null>"])
        {
            ProjectType *projectType = [self noneProjectDictionaryForClientWithUri:clientUri];
            
            projectType = [self getUpdatedProjectTypeWithBillingTypeInfo:projectType projectDictionary:projectTypeDictionary];
            
            [projectTypes addObject:projectType];
        }
    }

    for (NSDictionary *projectTypeDictionary in projects) {
        
        NSString *name = projectTypeDictionary[@"name"];
        NSString *uri = projectTypeDictionary[@"uri"];
        NSString *clientName = projectTypeDictionary[@"client_name"];
        NSString *clientUri = projectTypeDictionary[@"client_uri"];
        ClientType *client = nil;
        if (clientUri!=nil  && ![clientUri isKindOfClass:[NSNull class]] && ![clientUri isEqualToString:@""] &&![clientUri isEqualToString:@"<null>"])
        {
            client = [[ClientType alloc]initWithName:clientName uri:clientUri];
        }

        ProjectType *projectType = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:[projectTypeDictionary[@"hasTasksAvailableForExpenseEntry"] boolValue]
                                                                       isTimeAllocationAllowed:NO
                                                                                 projectPeriod:nil
                                                                                    clientType:client
                                                                                          name:name
                                                                                           uri:uri];
        
        projectType = [self getUpdatedProjectTypeWithBillingTypeInfo:projectType projectDictionary:projectTypeDictionary];

        
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

-(ProjectType *)noneProjectDictionaryForClientWithUri:(NSString *)clientUri
{
    return [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:RPLocalizedString(@"None", @"") uri:nil];
}

#pragma mark - Billing Type Methods

- (ProjectBillingType *)projectBillingTypeFromJson:(NSDictionary *)projectDictionary {
    
    NSString *projectBillingTypeDisplayText = projectDictionary[@"billing_type_display_text"];
    NSString *projectBillingTypeUri = projectDictionary[@"billing_type_uri"];
    
    if(![self isValidString:projectBillingTypeDisplayText] || ![self isValidString:projectBillingTypeUri]) {
        return nil;
    }

    
    ProjectBillingType *projectBillingTypeObj = [[ProjectBillingType alloc] initWithUri:projectBillingTypeUri
                                                                            displayText:projectBillingTypeDisplayText];
    
    return projectBillingTypeObj;
    
}

- (ProjectTimeAndExpenseEntryType *)projectTimeAndExpenseEntryTypeFromJson:(NSDictionary *)projectDictionary {
    
    NSString *displayText = projectDictionary[@"time_expense_entry_display_text"];
    NSString *uri = projectDictionary[@"time_expense_entry_uri"];
    
    if(![self isValidString:displayText] || ![self isValidString:uri]) {
        return nil;
    }
    
    ProjectTimeAndExpenseEntryType *projectTimeAndExpenseEntryTypeObj = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:uri
                                                                                                                displayText:displayText];
    
    return projectTimeAndExpenseEntryTypeObj;
    
}

- (ProjectType *)getUpdatedProjectTypeWithBillingTypeInfo:(ProjectType *)project projectDictionary:(NSDictionary *)projectTypeDictionary{
    ProjectType *project_ = project;

    ProjectTimeAndExpenseEntryType *projectTimeAndExpenseEntryType = [self projectTimeAndExpenseEntryTypeFromJson:projectTypeDictionary];
    ProjectBillingType *projectBillingType = [self projectBillingTypeFromJson:projectTypeDictionary];
    
    project_.projectBillingType = projectBillingType;
    project_.projectTimeAndExpenseEntryType = projectTimeAndExpenseEntryType;
    
    return project_;
}


#pragma mark - String Helper Methods
- (BOOL)isValidString:(NSString *)string {
    return (string != nil && string != (id)[NSNull null] && string.length > 0 && ![string isEqualToString:@"<null>"]);
}

@end
