
#import "ExpenseTaskStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "TaskType.h"
#import "ClientType.h"
#import "Period.h"
#import "UserPermissionsStorage.h"

@interface ExpenseTaskStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end

static NSString *const LastDownloadedExpenseTaskPageNumber = @"LastDownloadedExpenseTaskPageNumber";
static NSString *const LastDownloadedFilteredExpenseTaskPageNumber = @"LastDownloadedFilteredExpenseTaskPageNumber";


@implementation ExpenseTaskStorage
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
    NSNumber *lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedExpenseTaskPageNumber];
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
    [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedExpenseTaskPageNumber];
}

-(void)resetPageNumber
{
    [self.userDefaults removeObjectForKey:LastDownloadedExpenseTaskPageNumber];
}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredExpenseTaskPageNumber];
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
    [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredExpenseTaskPageNumber];
}

-(void)resetPageNumberForFilteredSearch
{
    [self.userDefaults removeObjectForKey:LastDownloadedFilteredExpenseTaskPageNumber];
}

-(void)deleteAllTasksForProjectWithUri:(NSString *)projectUri
{
    id project = [self getValueAfterCheckForNullForValue:projectUri];
    if (project != [NSNull null])
    {
        [self.sqliteStore deleteRowWithArgs:@{@"project_uri": projectUri}];
    }
    else
    {
        [self.sqliteStore deleteAllRows];
    }
}

-(void)storeTasks:(NSArray *)tasks
{
    for (TaskType *task in tasks) {
        
        NSDictionary *taskTypeDictionary = [self dictionaryWithTask:task];
        NSDictionary *taskFilter = @{@"uri": task.uri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:taskFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:taskTypeDictionary whereClause:nil];
        } else {
            [self.sqliteStore insertRow:taskTypeDictionary];
        }
    }
}

-(NSArray *)getAllTasksForProjectUri:(NSString *)projectUri
{
    NSArray *tasks;
    if (projectUri !=nil && projectUri != (id) [NSNull null])
    {
        tasks = [self.sqliteStore readAllRowsInAscendingWithArgs:@{@"user_uri": [self.userSession currentUserURI],
                                                                   @"project_uri":projectUri
                                                                   } orderedBy:@"name"];
    }
    else
    {
        tasks = [self.sqliteStore readAllRowsInAscendingWithArgs:@{@"user_uri": [self.userSession currentUserURI]
                                                        }orderedBy:@"name"];
    }
    
    return [self serializeTaskTypeForTasks:tasks];
    
}

-(NSArray *)getTasksWithMatchingText:(NSString *)text projectUri:(NSString *)projectUri
{
    NSArray *tasks;
    if (projectUri != nil && projectUri != (id)[NSNull null] && projectUri.length > 0)
    {
        tasks = [self.sqliteStore readAllRowsFromColumnInAscending:@"name"
                                                  where:@{@"project_uri": projectUri}
                                                pattern:text
                                              orderedBy:@"name"];
        
    }
    else
    {
        tasks = [self.sqliteStore readAllRowsFromColumnInAscending:@"name"
                                                           pattern:text
                                                         orderedBy:@"name"];
    }
    
    return [self serializeTaskTypeForTasks:tasks];
}

-(TaskType *)getTaskInfoForUri:(NSString *)taskUri
{
    NSArray *tasks = [self.sqliteStore readAllRowsInAscendingWithArgs:@{@"user_uri":[self.userSession currentUserURI],
                                                             @"uri":taskUri} orderedBy:@"name"];
    return [self serializeTaskTypeForTasks:tasks].lastObject;
    
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

- (NSDictionary *)dictionaryWithTask:(TaskType *)task
{
    NSString *projectUri = [self getValueAfterCheckForNullForValue:task.projectUri];
    return @{
             @"uri":task.uri,
             @"name":task.name,
             @"project_uri":projectUri,
             @"user_uri":[self.userSession currentUserURI]
             };
}

-(NSArray *)serializeTaskTypeForTasks:(NSArray *)tasks
{
    if (tasks.count == 0) {
        return nil;
    }
    NSMutableArray *taskTypes = [NSMutableArray arrayWithCapacity:tasks.count];

    NSDictionary *taskTypeDictionary = tasks.firstObject;
    NSString *projectUri = taskTypeDictionary[@"project_uri"];
    TaskType *taskType = [self noneTaskDictionaryForProjectWithUri:projectUri];
    [taskTypes addObject:taskType];

    for (NSDictionary *taskTypeDictionary in tasks) {
        
        
        NSString *name = taskTypeDictionary[@"name"];
        NSString *uri = taskTypeDictionary[@"uri"];
        NSString *projectUri = taskTypeDictionary[@"project_uri"];
        TaskType *projectType = [[TaskType alloc] initWithProjectUri:projectUri
                                                          taskPeriod:nil
                                                                name:name
                                                                 uri:uri];
        [taskTypes addObject:projectType];
    }
    return [taskTypes copy];
}

-(id)getValueAfterCheckForNullForValue:(id)value
{
    if (value == nil || value == [NSNull null] ) {
        return [NSNull null];
    }
    return value;
}

-(NSDate *)getDateForDateInStringFormat:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

-(TaskType *)noneTaskDictionaryForProjectWithUri:(NSString *)projectUri
{
    return [[TaskType alloc] initWithProjectUri:projectUri
                                     taskPeriod:nil
                                           name:RPLocalizedString(@"None", @"")
                                            uri:nil];
}


@end
