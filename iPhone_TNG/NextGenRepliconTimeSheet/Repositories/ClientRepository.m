
#import "ClientRepository.h"
#import "RequestPromiseClient.h"
#import "ClientRequestProvider.h"
#import "ClientStorage.h"
#import <KSDeferred/KSPromise.h>
#import "ClientDeserializer.h"
#import <KSDeferred/KSDeferred.h>

@interface ClientRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) ClientRequestProvider *requestProvider;
@property (nonatomic) ClientStorage *clientStorage;
@property (nonatomic) ClientDeserializer *clientDeserializer;
@property (nonatomic) NSString *userUri;

@end

@implementation ClientRepository

- (instancetype)initWithClientDeserializer:(ClientDeserializer *)clientDeserializer
                           requestProvider:(ClientRequestProvider *)requestProvider
                               userSession:(id <UserSession>)userSession
                                    client:(id<RequestPromiseClient>)client
                                   storage:(ClientStorage *)storage
{
    self = [super init];
    if (self) {
        self.client = client;
        self.requestProvider = requestProvider;
        self.clientStorage = storage;
        self.userSession = userSession;
        self.clientDeserializer = clientDeserializer;
    }
    return self;
}

-(void)setUpWithUserUri:(NSString *)userUri
{
    self.userUri = userUri;
    [self.clientStorage setUpWithUserUri:userUri];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(KSPromise *)fetchCachedClientsMatchingText:(NSString *)text
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *clients = [self.clientStorage getAllClients];
    if (clients.count > 0)
    {
        NSArray *filteredClients = [self.clientStorage getClientsWithMatchingText:text];
        NSDictionary *serializedClientData = [self clientsDataForValues:filteredClients downloadCount:clients.count];
        [deferred resolveWithValue:serializedClientData];
        return deferred.promise;
    }
    return nil;
}

-(KSPromise *)fetchClientsMatchingText:(NSString *)text
{
    [self.clientStorage resetPageNumberForFilteredSearch];
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForClientsForUserWithURI:self.userUri
                                                                       searchText:text
                                                                             page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *clients = [self.clientDeserializer deserialize:json];
        [self.clientStorage storeClients:clients];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredClients = [self.clientStorage getClientsWithMatchingText:text];
        NSDictionary *serializedClientData = [self clientsDataForValues:filteredClients downloadCount:clients.count];
        return serializedClientData;
    } error:^id(NSError *error) {
        return error;
    }];

}

-(KSPromise *)fetchMoreClientsMatchingText:(NSString *)text
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForClientsForUserWithURI:self.userUri
                                                                       searchText:text
                                                                             page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *clients = [self.clientDeserializer deserialize:json];
        [self.clientStorage storeClients:clients];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredClients = [self.clientStorage getClientsWithMatchingText:text];
        NSDictionary *serializedClientData = [self clientsDataForValues:filteredClients downloadCount:clients.count];
        return serializedClientData;
    } error:^id(NSError *error) {
        return error;
    }];
}


-(KSPromise *)fetchAllClients
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *clients = [self.clientStorage getAllClients];
    if (clients.count > 0)
    {
        NSDictionary *serializedClientData = [self clientsDataForValues:clients downloadCount:clients.count];
        [deferred resolveWithValue:serializedClientData];
        return deferred.promise;
    }
    else
    {
        return [self fetchFreshClients];
    }
    return nil;
}

-(KSPromise *)fetchFreshClients
{
    NSURLRequest *request = [self.requestProvider requestForClientsForUserWithURI:self.userUri
                                                                       searchText:nil
                                                                             page:@1];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        [self.clientStorage resetPageNumber];
        [self.clientStorage resetPageNumberForFilteredSearch];
        [self.clientStorage deleteAllClients];
        NSArray *clients = [self.clientDeserializer deserialize:json];
        [self.clientStorage storeClients:clients];
        [self.clientStorage updatePageNumber];
        NSDictionary *serializedClientData = [self clientsDataForValues:[self.clientStorage getAllClients] downloadCount:clients.count];
        return serializedClientData;
    } error:^id(NSError *error) {
        return error;
    }];
}

#pragma mark - Private

-(NSNumber *)pageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredClientsForText:text])
        return  [self.clientStorage getLastPageNumberForFilteredSearch];
    else
        return  [self.clientStorage getLastPageNumber];
}

-(void )updatePageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredClientsForText:text])
        [self.clientStorage updatePageNumberForFilteredSearch];
    else
        [self.clientStorage updatePageNumber];
}

-(BOOL)isUserDemandingFilteredClientsForText:(NSString *)text
{
    return  (text != nil && text != (id)[NSNull null] && text.length > 0);
}

-(NSDictionary *)clientsDataForValues:(NSArray *)values downloadCount:(NSInteger)downloadCount
{
    id clients = [[NSArray alloc]init];
    if (values.count > 0) {
        clients = values;
    }
    return  @{@"downloadCount":[NSNumber numberWithInteger:downloadCount],
              @"clients":clients};
}

@end
