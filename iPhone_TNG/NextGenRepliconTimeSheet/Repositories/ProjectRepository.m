
#import "ProjectRepository.h"
#import "RequestPromiseClient.h"
#import "ProjectRequestProvider.h"
#import "ProjectStorage.h"
#import <KSDeferred/KSPromise.h>
#import "ProjectDeserializer.h"
#import <KSDeferred/KSDeferred.h>

@interface ProjectRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) ProjectRequestProvider *requestProvider;
@property (nonatomic) ProjectStorage *projectStorage;
@property (nonatomic) ProjectDeserializer *projectDeserializer;
@property (nonatomic) NSString *userUri;

@end

@implementation ProjectRepository

- (instancetype)initWithProjectDeserializer:(ProjectDeserializer *)projectDeserializer
                            requestProvider:(ProjectRequestProvider *)requestProvider
                                userSession:(id <UserSession>)userSession
                                     client:(id<RequestPromiseClient>)client
                                    storage:(ProjectStorage *)storage
{
    self = [super init];
    if (self) {
        self.client = client;
        self.requestProvider = requestProvider;
        self.projectStorage = storage;
        self.userSession = userSession;
        self.projectDeserializer = projectDeserializer;
    }
    return self;
}

-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
    [self.projectStorage setUpWithUserUri:userUri];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(KSPromise *)fetchCachedProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *projects = [self.projectStorage getAllProjectsForClientUri:clientUri];
    if (projects.count > 0)
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
    NSURLRequest *request = [self.requestProvider requestForProjectsForUserWithURI:self.userUri
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
    NSURLRequest *request = [self.requestProvider requestForProjectsForUserWithURI:self.userUri
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
    return [self fetchFreshProjectsForClientUri:clientUri];
}

-(KSPromise *)fetchFreshProjectsForClientUri:(NSString *)clientUri
{
    NSURLRequest *request = [self.requestProvider requestForProjectsForUserWithURI:self.userUri
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
