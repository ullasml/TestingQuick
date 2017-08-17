
#import "OEFDropDownRepository.h"
#import <KSDeferred/KSPromise.h>
#import "RequestPromiseClient.h"
#import "UserSession.h"
#import "ActivityDeserializer.h"
#import <KSDeferred/KSDeferred.h>
#import "OEFDropdownRequestProvider.h"
#import "OEFDropdownStorage.h"

@interface OEFDropDownRepository()

@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) id <UserSession>userSession;
@property (nonatomic) OEFDropdownRequestProvider *requestProvider;
@property (nonatomic) OEFDropdownStorage *storage;
@property (nonatomic) OEFDropdownDeserializer *oefDropdownDeserializer;
@property (nonatomic) NSString *dropDownOEFUri;
@property (nonatomic) NSString *userUri;
@end


@implementation OEFDropDownRepository


- (instancetype)initWithOEFDropDownDeserializer:(OEFDropdownDeserializer *)oefDropdownDeserializer
                             requestProvider:(OEFDropdownRequestProvider *)requestProvider
                                 userSession:(id <UserSession>)userSession
                                     storage:(OEFDropdownStorage *)storage
                                      client:(id<RequestPromiseClient>)client
{
    self = [super init];
    if (self) {
        self.oefDropdownDeserializer = oefDropdownDeserializer;
        self.requestProvider = requestProvider;
        self.userSession = userSession;
        self.storage = storage;
        self.client = client;
    }
    return self;
}

-(void)setUpWithDropDownOEFUri:(NSString *)dropDownOEFUri userUri:(NSString *)userUri
{
    self.dropDownOEFUri = dropDownOEFUri;
    self.userUri = userUri;
    [self.storage setUpWithDropDownOEFUri:dropDownOEFUri userUri:userUri];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
-(KSPromise *)fetchCachedOEFDropDownOptionsMatchingText:(NSString *)text
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *dropdownValues = [self.storage getAllOEFDropDownOptions];
    if (dropdownValues.count > 0)
    {
        NSArray *filteredOEFDropDownOptions = [self.storage getOEFDropDownOptionsWithMatchingText:text];
        NSDictionary *serializedOEFDropDownOptionsData = [self oefDropDownOptionsDataForValues:filteredOEFDropDownOptions downloadCount:dropdownValues.count];
        [deferred resolveWithValue:serializedOEFDropDownOptionsData];
        return deferred.promise;
    }
    return nil;
}

-(KSPromise *)fetchOEFDropDownOptionsMatchingText:(NSString *)text
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForOEFDropDownOptionsForDropDownWithURI:self.dropDownOEFUri
                                                                          searchText:text
                                                                                page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *dropdownValues = [self.oefDropdownDeserializer deserialize:json];
        [self.storage storeOEFDropDownOptions:dropdownValues];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredOEFDropDownOptions = [self.storage getOEFDropDownOptionsWithMatchingText:text];
        NSDictionary *serializedOEFDropDownOptionsData = [self oefDropDownOptionsDataForValues:filteredOEFDropDownOptions downloadCount:dropdownValues.count];
        return serializedOEFDropDownOptionsData;
    } error:^id(NSError *error) {
        return error;
    }];

}

-(KSPromise *)fetchMoreOEFDropDownOptionsMatchingText:(NSString *)text
{
    NSNumber *page = [self pageNumberBasedOnFilteredText:text];
    NSURLRequest *request = [self.requestProvider requestForOEFDropDownOptionsForDropDownWithURI:self.dropDownOEFUri
                                                                          searchText:text
                                                                                page:page];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json) {
        NSArray *dropdownValues = [self.oefDropdownDeserializer deserialize:json];
        [self.storage storeOEFDropDownOptions:dropdownValues];
        [self updatePageNumberBasedOnFilteredText:text];
        NSArray *filteredOEFDropDownOptions = [self.storage getOEFDropDownOptionsWithMatchingText:text];
        NSDictionary *serializedOEFDropDownOptionsData = [self oefDropDownOptionsDataForValues:filteredOEFDropDownOptions downloadCount:dropdownValues.count];
        return serializedOEFDropDownOptionsData;
    } error:^id(NSError *error) {
        return error;
    }];
}


-(KSPromise *)fetchAllOEFDropDownOptions
{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    NSArray *dropdownValues = [self.storage getAllOEFDropDownOptions];
    if (dropdownValues.count > 0)
    {
        NSDictionary *serializedOEFDropDownOptionsData = [self oefDropDownOptionsDataForValues:dropdownValues downloadCount:dropdownValues.count];
        [deferred resolveWithValue:serializedOEFDropDownOptionsData];
        return deferred.promise;
    }
    else
    {
        return [self fetchFreshOEFDropDownOptions];
    }
    return nil;
}

-(KSPromise *)fetchFreshOEFDropDownOptions
{
    NSURLRequest *request = [self.requestProvider requestForOEFDropDownOptionsForDropDownWithURI:self.dropDownOEFUri
                                                                          searchText:nil
                                                                                page:@1];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSDictionary *json)
            {
                [self.storage resetPageNumber];
                [self.storage resetPageNumberForFilteredSearch];
                [self.storage deleteAllOEFDropDownOptionsForOEFUri:self.dropDownOEFUri];
                NSArray *dropdownValues = [self.oefDropdownDeserializer deserialize:json];
                [self.storage storeOEFDropDownOptions:dropdownValues];
                [self.storage updatePageNumber];
                NSDictionary *serializedOEFDropDownOptionsData = [self oefDropDownOptionsDataForValues:[self.storage getAllOEFDropDownOptions] downloadCount:dropdownValues.count];
                return serializedOEFDropDownOptionsData;
            } error:^id(NSError *error) {
                return error;
            }];
}

#pragma mark - Private

-(NSNumber *)pageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredOEFDropDownOptionsForText:text])
        return  [self.storage getLastPageNumberForFilteredSearch];
    else
        return  [self.storage getLastPageNumber];
}

-(void )updatePageNumberBasedOnFilteredText:(NSString *)text
{
    if ([self isUserDemandingFilteredOEFDropDownOptionsForText:text])
        [self.storage updatePageNumberForFilteredSearch];
    else
        [self.storage updatePageNumber];
}

-(BOOL)isUserDemandingFilteredOEFDropDownOptionsForText:(NSString *)text
{
    return  (text != nil && text != (id)[NSNull null] && text.length > 0);
}

-(NSDictionary *)oefDropDownOptionsDataForValues:(NSArray *)values downloadCount:(NSInteger)downloadCount
{
    NSArray *dropdownValues = values.count > 0 ? values : @[];
    return  @{@"downloadCount":[NSNumber numberWithInteger:downloadCount],
              @"oefDropDownOptions":dropdownValues};
}



@end
