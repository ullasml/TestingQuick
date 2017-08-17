
#import "ActivityRepository.h"
#import <KSDeferred/KSPromise.h>
#import "RequestPromiseClient.h"
#import "UserSession.h"
#import "ActivityRequestProvider.h"
#import "ActivityStorage.h"
#import "ActivityDeserializer.h"
#import <KSDeferred/KSDeferred.h>

@interface ActivityRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) ActivityRequestProvider *requestProvider;
@property (nonatomic) ActivityStorage *storage;
@property (nonatomic) ActivityDeserializer *activityDeserializer;
@property (nonatomic) NSString *userUri;
@end


@implementation ActivityRepository


- (instancetype)initWithActivityDeserializer:(ActivityDeserializer *)activityDeserializer
                             requestProvider:(ActivityRequestProvider *)requestProvider
                                 userSession:(id <UserSession>)userSession
                                     storage:(ActivityStorage *)storage
                                      client:(id<RequestPromiseClient>)client
{
    self = [super init];
    if (self) {
        self.activityDeserializer = activityDeserializer;
        self.requestProvider = requestProvider;
        self.userSession = userSession;
        self.storage = storage;
        self.client = client;
    }
    return self;
}

-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
    [self.storage setUpWithUserUri:userUri];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-(KSPromise *)fetchCachedActivitiesMatchingText:(NSString *)text
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *clients = [self.storage getAllActivities];
    if (clients.count > 0)
    {
        NSArray *filteredClients = [self.storage getActivitiesWithMatchingText:text];
        NSDictionary *serializedClientData = [self activitiesDataForValues:filteredClients downloadCount:clients.count];
        [deferred resolveWithValue:serializedClientData];
        return deferred.promise;
    }
    return nil;
}

-(KSPromise *)fetchActivitiesMatchingText:(NSString *)text
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForActivitiesForUserWithURI:self.userUri
                                                                       searchText:text
                                                                             page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *clients = [self.activityDeserializer deserialize:json];
        [self.storage storeActivities:clients];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredClients = [self.storage getActivitiesWithMatchingText:text];
        NSDictionary *serializedactivityData = [self activitiesDataForValues:filteredClients downloadCount:clients.count];
        return serializedactivityData;
    } error:^id(NSError *error) {
        return error;
    }];

}

-(KSPromise *)fetchMoreActivitiesMatchingText:(NSString *)text
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForActivitiesForUserWithURI:self.userUri
                                                                       searchText:text
                                                                             page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *activities = [self.activityDeserializer deserialize:json];
        [self.storage storeActivities:activities];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredActivities = [self.storage getActivitiesWithMatchingText:text];
        NSDictionary *serializedactivityData = [self activitiesDataForValues:filteredActivities downloadCount:activities.count];
        return serializedactivityData;
    } error:^id(NSError *error) {
        return error;
    }];
}


-(KSPromise *)fetchAllActivities
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *clients = [self.storage getAllActivities];
    if (clients.count > 0)
    {
        NSDictionary *serializedClientData = [self activitiesDataForValues:clients downloadCount:clients.count];
        [deferred resolveWithValue:serializedClientData];
        return deferred.promise;
    }
    else
    {
        return [self fetchFreshActivities];
    }
    return nil;
}

-(KSPromise *)fetchFreshActivities
{
    NSURLRequest *request = [self.requestProvider requestForActivitiesForUserWithURI:self.userUri
                                                                       searchText:nil
                                                                             page:@1];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json)
    {
        [self.storage resetPageNumber];
        [self.storage resetPageNumberForFilteredSearch];
        [self.storage deleteAllActivities];
        NSArray *clients = [self.activityDeserializer deserialize:json];
        [self.storage storeActivities:clients];
        [self.storage updatePageNumber];
        NSDictionary *serializedactivityData = [self activitiesDataForValues:[self.storage getAllActivities] downloadCount:clients.count];
        return serializedactivityData;
    } error:^id(NSError *error) {
        return error;
    }];
}

#pragma mark - Private

-(NSNumber *)pageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredClientsForText:text])
        return  [self.storage getLastPageNumberForFilteredSearch];
    else
        return  [self.storage getLastPageNumber];
}

-(void )updatePageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredClientsForText:text])
        [self.storage updatePageNumberForFilteredSearch];
    else
        [self.storage updatePageNumber];
}

-(BOOL)isUserDemandingFilteredClientsForText:(NSString *)text
{
    return  (text != nil && text != (id)[NSNull null] && text.length > 0);
}

-(NSDictionary *)activitiesDataForValues:(NSArray *)values downloadCount:(NSInteger)downloadCount
{
    NSArray *activities = values.count > 0 ? values : @[];
    return  @{@"downloadCount":[NSNumber numberWithInteger:downloadCount],
              @"activities":activities};
}



@end
