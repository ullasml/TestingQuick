
#import "ExpenseTaskRepository.h"
#import "RequestPromiseClient.h"
#import "ExpenseTaskRequestProvider.h"
#import "ExpenseTaskStorage.h"
#import <KSDeferred/KSPromise.h>
#import "ExpenseTaskDeserializer.h"
#import <KSDeferred/KSDeferred.h>


@interface ExpenseTaskRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) ExpenseTaskRequestProvider *requestProvider;
@property (nonatomic) ExpenseTaskStorage *taskStorage;
@property (nonatomic) ExpenseTaskDeserializer *taskDeserializer;
@property (nonatomic) NSString *expenseSheetUri;

@end


@implementation ExpenseTaskRepository

- (instancetype)initWithExpenseTaskDeserializer:(ExpenseTaskDeserializer *)taskDeserializer
                                requestProvider:(ExpenseTaskRequestProvider *)requestProvider
                                    userSession:(id <UserSession>)userSession
                                         client:(id<RequestPromiseClient>)client
                                        storage:(ExpenseTaskStorage *)storage
{
    self = [super init];
    if (self) {
        self.client = client;
        self.requestProvider = requestProvider;
        self.taskStorage = storage;
        self.userSession = userSession;
        self.taskDeserializer = taskDeserializer;
    }
    return self;
}

-(void)setUpWithExpenseSheetUri:(NSString*)uri
{
    self.expenseSheetUri = uri;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(KSPromise *)fetchCachedTasksMatchingText:(NSString *)text projectUri:(NSString *)projectUri
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *tasks = [self.taskStorage getAllTasksForProjectUri:projectUri];
    if (tasks.count > 1)
    {
        NSArray *filteredTasks = [self.taskStorage getTasksWithMatchingText:text
                                                                 projectUri:projectUri];
        NSDictionary *serializedTaskData = [self tasksDataForValues:filteredTasks
                                                      downloadCount:tasks.count];
        [deferred resolveWithValue:serializedTaskData];
        return deferred.promise;
    }
    return nil;
}

-(KSPromise *)fetchTasksMatchingText:(NSString *)text projectUri:(NSString *)projectUri
{
    [self.taskStorage resetPageNumberForFilteredSearch];
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForTasksForExpenseSheetURI:self.expenseSheetUri
                                                                         projectUri:projectUri
                                                                         searchText:text
                                                                               page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *tasks = [self.taskDeserializer deserialize:json forProjectWithUri:projectUri];
        [self.taskStorage storeTasks:tasks];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredTasks = [self.taskStorage getTasksWithMatchingText:text
                                                                 projectUri:projectUri];
        NSDictionary *serializedTaskData = [self tasksDataForValues:filteredTasks downloadCount:tasks.count];
        return serializedTaskData;
    } error:^id(NSError *error) {
        return error;
    }];
    
}

-(KSPromise *)fetchMoreTasksMatchingText:(NSString *)text projectUri:(NSString *)projectUri
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForTasksForExpenseSheetURI:self.expenseSheetUri
                                                                         projectUri:projectUri
                                                                         searchText:text
                                                                               page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *tasks = [self.taskDeserializer deserialize:json forProjectWithUri:projectUri];
        [self.taskStorage storeTasks:tasks];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredTasks = [self.taskStorage getTasksWithMatchingText:text
                                                                 projectUri:projectUri];
        NSDictionary *serializedTaskData = [self tasksDataForValues:filteredTasks downloadCount:tasks.count];
        return serializedTaskData;
    } error:^id(NSError *error) {
        return error;
    }];
}


-(KSPromise *)fetchAllTasksForProjectUri:(NSString *)projectUri
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *tasks = [self.taskStorage getAllTasksForProjectUri:projectUri];
    if (tasks.count > 1)
    {
        NSDictionary *serializedTaskData = [self tasksDataForValues:tasks downloadCount:tasks.count];
        [deferred resolveWithValue:serializedTaskData];
        return deferred.promise;
    }
    else
    {
        return [self fetchFreshTasksForProjectUri:projectUri];
    }
    return nil;
}

-(KSPromise *)fetchFreshTasksForProjectUri:(NSString *)projectUri
{
    NSURLRequest *request = [self.requestProvider requestForTasksForExpenseSheetURI:self.expenseSheetUri
                                                                         projectUri:projectUri
                                                                         searchText:nil
                                                                               page:@1];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        [self.taskStorage resetPageNumber];
        [self.taskStorage resetPageNumberForFilteredSearch];
        [self.taskStorage deleteAllTasksForProjectWithUri:projectUri];
        NSArray *tasks = [self.taskDeserializer deserialize:json forProjectWithUri:projectUri];
        [self.taskStorage storeTasks:tasks];
        [self.taskStorage updatePageNumber];
        NSDictionary *serializedTaskData = [self tasksDataForValues:[self.taskStorage getAllTasksForProjectUri:projectUri] downloadCount:tasks.count];
        return serializedTaskData;
    } error:^id(NSError *error) {
        return error;
    }];
}

#pragma mark - Private

-(NSNumber *)pageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredTasksForText:text])
        return  [self.taskStorage getLastPageNumberForFilteredSearch];
    else
        return  [self.taskStorage getLastPageNumber];
}

-(void )updatePageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredTasksForText:text])
        [self.taskStorage updatePageNumberForFilteredSearch];
    else
        [self.taskStorage updatePageNumber];
}

-(BOOL)isUserDemandingFilteredTasksForText:(NSString *)text
{
    return  (text != nil && text != (id)[NSNull null] && text.length > 0);
}

-(NSDictionary *)tasksDataForValues:(NSArray *)values downloadCount:(NSInteger)downloadCount
{
    id tasks = [[NSArray alloc]init];
    if (values.count > 0) {
        tasks = values;
    }
    return  @{@"downloadCount":[NSNumber numberWithInteger:downloadCount],
              @"tasks":tasks};
}

@end
