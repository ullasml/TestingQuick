
#import "ExpenseProjectRepository.h"
#import "RequestPromiseClient.h"
#import "ExpenseProjectRequestProvider.h"
#import "ExpenseProjectStorage.h"
#import <KSDeferred/KSPromise.h>
#import "ExpenseProjectDeserializer.h"
#import <KSDeferred/KSDeferred.h>
#import "UserPermissionsStorage.h"

@interface ExpenseProjectRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) ExpenseProjectRequestProvider *requestProvider;
@property (nonatomic) ExpenseProjectStorage *projectStorage;
@property (nonatomic) ExpenseProjectDeserializer *projectDeserializer;
@property (nonatomic) NSString *expenseSheetUri;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end


@implementation ExpenseProjectRepository

- (instancetype)initWithExpenseProjectDeserializer:(ExpenseProjectDeserializer *)projectDeserializer
                                   requestProvider:(ExpenseProjectRequestProvider *)requestProvider
                                       userSession:(id <UserSession>)userSession
                                            client:(id<RequestPromiseClient>)client
                                           storage:(ExpenseProjectStorage *)storage
                            userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
{
    self = [super init];
    if (self) {
        self.client = client;
        self.requestProvider = requestProvider;
        self.projectStorage = storage;
        self.userSession = userSession;
        self.projectDeserializer = projectDeserializer;
        self.userPermissionsStorage = userPermissionsStorage;
    }
    return self;
}

-(void)setUpWithExpenseSheetUri:(NSString*)uri
{
    self.expenseSheetUri = uri;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(KSPromise *)fetchCachedProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *projects = [self.projectStorage getAllProjectsForClientUri:clientUri];
    int count = 0;
    if (!self.userPermissionsStorage.isExpensesProjectMandatory)
    {
        count = 1;
    }
    if (projects.count > count)
    {
        NSArray *filteredProjects = [self.projectStorage getProjectsWithMatchingText:text
                                                                           clientUri:clientUri];
        NSDictionary *serializedProjectData = [self projectsDataForValues:filteredProjects
                                                            downloadCount:projects.count];
        [deferred resolveWithValue:serializedProjectData];
        return deferred.promise;
    }
    return nil;
}

-(KSPromise *)fetchProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri
{
    [self.projectStorage resetPageNumberForFilteredSearch];
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForProjectsForExpenseSheetURI:self.expenseSheetUri
                                                                             clientUri:clientUri
                                                                            searchText:text
                                                                                  page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *projects = [self.projectDeserializer deserialize:json];
        [self.projectStorage storeProjects:projects];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredProjects = [self.projectStorage getProjectsWithMatchingText:text
                                                                           clientUri:clientUri];
        NSDictionary *serializedProjectData = [self projectsDataForValues:filteredProjects downloadCount:projects.count];
        return serializedProjectData;
    } error:^id(NSError *error) {
        return error;
    }];
    
}

-(KSPromise *)fetchMoreProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForProjectsForExpenseSheetURI:self.expenseSheetUri
                                                                             clientUri:clientUri
                                                                            searchText:text
                                                                                  page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *projects = [self.projectDeserializer deserialize:json];
        [self.projectStorage storeProjects:projects];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredProjects = [self.projectStorage getProjectsWithMatchingText:text
                                                                           clientUri:clientUri];
        NSDictionary *serializedProjectData = [self projectsDataForValues:filteredProjects downloadCount:projects.count];
        return serializedProjectData;
    } error:^id(NSError *error) {
        return error;
    }];
}


-(KSPromise *)fetchAllProjectsForClientUri:(NSString *)clientUri
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *projects = [self.projectStorage getAllProjectsForClientUri:clientUri];
    int count = 0;
    if (!self.userPermissionsStorage.isExpensesProjectMandatory)
    {
        count = 1;
    }
    if (projects.count > count)
    {
        NSDictionary *serializedProjectData = [self projectsDataForValues:projects downloadCount:projects.count];
        [deferred resolveWithValue:serializedProjectData];
        return deferred.promise;
    }
    else
    {
        return [self fetchFreshProjectsForClientUri:clientUri];
    }
    return nil;
}

-(KSPromise *)fetchFreshProjectsForClientUri:(NSString *)clientUri
{
    NSURLRequest *request = [self.requestProvider requestForProjectsForExpenseSheetURI:self.expenseSheetUri
                                                                             clientUri:clientUri
                                                                            searchText:nil
                                                                                  page:@1];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        [self.projectStorage resetPageNumber];
        [self.projectStorage resetPageNumberForFilteredSearch];
        [self.projectStorage deleteAllProjectsForClientUri:clientUri];
        NSArray *projects = [self.projectDeserializer deserialize:json];
        [self.projectStorage storeProjects:projects];
        [self.projectStorage updatePageNumber];
        NSDictionary *serializedProjectData = [self projectsDataForValues:[self.projectStorage getAllProjectsForClientUri:clientUri] downloadCount:projects.count];
        return serializedProjectData;
    } error:^id(NSError *error) {
        return error;
    }];
}

#pragma mark - Private

-(NSNumber *)pageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredProjectsForText:text])
        return  [self.projectStorage getLastPageNumberForFilteredSearch];
    else
        return  [self.projectStorage getLastPageNumber];
}

-(void )updatePageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredProjectsForText:text])
        [self.projectStorage updatePageNumberForFilteredSearch];
    else
        [self.projectStorage updatePageNumber];
}

-(BOOL)isUserDemandingFilteredProjectsForText:(NSString *)text
{
    return  (text != nil && text != (id)[NSNull null] && text.length > 0);
}

-(NSDictionary *)projectsDataForValues:(NSArray *)values downloadCount:(NSInteger)downloadCount
{
    id projects = [[NSArray alloc]init];
    if (values.count > 0) {
        projects = values;
    }
    return  @{@"downloadCount":[NSNumber numberWithInteger:downloadCount],
              @"projects":projects};
}



@end
