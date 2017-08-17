
#import "TaskStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "TaskType.h"
#import "ClientType.h"
#import "Period.h"
#import "UserPermissionsStorage.h"
#import "ProjectType.h"


@interface TaskStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSUserDefaults *userDefaults;

@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) NSString *userUri;
@property (nonatomic) FlowType flowType;
@end

static NSString *const LastDownloadedTaskPageNumber = @"LastDownloadedTaskPageNumber";
static NSString *const LastDownloadedFilteredTaskPageNumber = @"LastDownloadedFilteredTaskPageNumber";
static NSString *const SupervisorLastDownloadedTaskPageNumber = @"SupervisorLastDownloadedTaskPageNumber";
static NSString *const SupervisorLastDownloadedFilteredTaskPageNumber = @"SupervisorLastDownloadedFilteredTaskPageNumber";


@implementation TaskStorage

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
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:LastDownloadedTaskPageNumber];
    }
    else
    {
        lastDownlaodedPageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedTaskPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedTaskPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedTaskPageNumber];
    }

}

-(void)resetPageNumber
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedTaskPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedTaskPageNumber];
    }

}

-(NSNumber *)getLastPageNumberForFilteredSearch
{
    NSNumber *pageNumber = nil;
    if (self.flowType == UserFlowContext)
    {
        pageNumber = [self.userDefaults objectForKey:LastDownloadedFilteredTaskPageNumber];
    }
    else
    {
        pageNumber = [self.userDefaults objectForKey:SupervisorLastDownloadedFilteredTaskPageNumber];
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
        [self.userDefaults setObject:updatedPageNumber forKey:LastDownloadedFilteredTaskPageNumber];
    }
    else
    {
        [self.userDefaults setObject:updatedPageNumber forKey:SupervisorLastDownloadedFilteredTaskPageNumber];
    }

}

-(void)resetPageNumberForFilteredSearch
{
    if (self.flowType == UserFlowContext)
    {
        [self.userDefaults removeObjectForKey:LastDownloadedFilteredTaskPageNumber];
    }
    else
    {
        [self.userDefaults removeObjectForKey:SupervisorLastDownloadedFilteredTaskPageNumber];
    }

}

-(void)deleteAllTasksForProjectWithUri:(NSString *)projectUri
{
    id project = [self getValueAfterCheckForNullForValue:projectUri];

    if (self.flowType == UserFlowContext)
    {
        if (project != [NSNull null])
        {
            [self.sqliteStore deleteRowWithArgs:@{@"project_uri": projectUri}];
        }
        else
        {
            [self.sqliteStore deleteAllRows];
        }
    }
    else
    {
        if (project != [NSNull null])
        {
            [self.sqliteStore deleteRowWithStringArgs:[NSString stringWithFormat:@"project_uri = '%@' AND user_uri != '%@'",projectUri,self.userSession.currentUserURI]];
        }
        else
        {
             [self.sqliteStore deleteRowWithStringArgs:[NSString stringWithFormat:@"user_uri != '%@'",self.userSession.currentUserURI]];
        }
    }



}

-(void)storeTasks:(NSArray *)tasks
{
    for (TaskType *task in tasks) {

        NSDictionary *taskTypeDictionary = [self dictionaryWithTask:task];
        NSDictionary *taskFilter = @{@"uri": task.uri, @"user_uri": self.userUri};
        NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:taskFilter];
        if (resultSet) {
            [self.sqliteStore updateRow:taskTypeDictionary whereClause:taskFilter];
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
        tasks = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri,
                                                        @"project_uri":projectUri
                                                        }];
    }
    else
    {
        tasks = [self.sqliteStore readAllRowsWithArgs:@{@"user_uri": self.userUri
                                                           }];
    }

    return [self serializeTaskTypeForTasks:tasks];

}

-(NSArray *)getTasksWithMatchingText:(NSString *)text projectUri:(NSString *)projectUri
{
    NSArray *tasks;
    if (projectUri != nil && projectUri != (id)[NSNull null] && projectUri.length > 0)
    {
        tasks = [self.sqliteStore readAllRowsFromColumn:@"name"
                                                     where:@{@"project_uri": projectUri, @"user_uri": self.userUri}
                                                   pattern:text];

    }
    else
    {
        tasks = [self.sqliteStore readAllRowsFromColumn:@"name" where:@{@"user_uri": self.userUri} pattern:text];
    }

    return [self serializeTaskTypeForTasks:tasks];
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

- (NSDictionary *)dictionaryWithTask:(TaskType *)task
{
    Period *period = [task.taskPeriod copy];
    NSDate *startDate = [self getValueAfterCheckForNullForValue:period.startDate];
    NSDate *endDate = [self getValueAfterCheckForNullForValue:period.endDate];
    NSString *projectUri = [self getValueAfterCheckForNullForValue:task.projectUri];
    return @{
             @"uri":task.uri,
             @"name":task.name,
             @"project_uri":projectUri,
             @"start_date":startDate,
             @"end_date":endDate,
             @"user_uri":self.userUri
             };
}

-(NSArray *)serializeTaskTypeForTasks:(NSArray *)tasks
{
    if (tasks.count == 0) {
        return nil;
    }
    NSMutableArray *taskTypes = [NSMutableArray arrayWithCapacity:tasks.count+1];
    if (!self.userPermissionsStorage.isProjectTaskSelectionRequired) {

        NSDictionary *taskTypeDictionary = tasks.firstObject;
        NSString *projectUri = taskTypeDictionary[@"project_uri"];
        TaskType *taskType = [self noneTaskDictionaryForProjectWithUri:projectUri];
        [taskTypes addObject:taskType];
    }

    for (NSDictionary *taskTypeDictionary in tasks) {


        NSString *startDateString = taskTypeDictionary[@"start_date"];
        NSDate *startDate = [self getDateForDateInStringFormat:startDateString];
        NSString *endDateString = taskTypeDictionary[@"end_date"];
        NSDate *endDate = [self getDateForDateInStringFormat:endDateString];
        NSString *name = taskTypeDictionary[@"name"];
        NSString *uri = taskTypeDictionary[@"uri"];
        NSString *projectUri = taskTypeDictionary[@"project_uri"];
        Period *period = [[Period alloc]initWithStartDate:startDate endDate:endDate];
        TaskType *projectType = [[TaskType alloc] initWithProjectUri:projectUri
                                                          taskPeriod:period
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
    Period *period = [[Period alloc]initWithStartDate:nil endDate:nil];
    return [[TaskType alloc] initWithProjectUri:projectUri
                                     taskPeriod:period
                                           name:RPLocalizedString(@"None", nil)
                                            uri:nil];
}

-(FlowType )flowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userUri];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

@end
