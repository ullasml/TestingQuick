#import "AuditHistoryRepository.h"
#import "RequestBuilder.h"
#import "RequestDictionaryBuilder.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "AuditHistoryDeserializer.h"
#import "AuditHistoryStorage.h"


@interface AuditHistoryRepository ()

@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) AuditHistoryDeserializer *auditHistoryDeserializer;
@property (nonatomic) AuditHistoryStorage *auditHistoryStorage;
@property (nonatomic) id<RequestPromiseClient> client;

@end


@implementation AuditHistoryRepository

- (instancetype)initWithAuditHistoryDeserializer:(AuditHistoryDeserializer *)auditHistoryDeserializer
                        requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                             auditHistoryStorage:(AuditHistoryStorage *)auditHistoryStorage
                                          client:(id <RequestPromiseClient>)client {
    self = [super init];
    if (self) {
        self.auditHistoryDeserializer = auditHistoryDeserializer;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.auditHistoryStorage = auditHistoryStorage;
        self.client = client;
    }
    return self;
}

- (KSPromise *)fetchPunchLogs:(NSArray*)uriArray
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSArray *punchLogs = [self.auditHistoryStorage getPunchLogs:uriArray];
    
    if (punchLogs.count > 0 && [uriArray count] == [punchLogs count]) {
        [deferred resolveWithValue:punchLogs];
        return deferred.promise;
    }

    NSDictionary *bodyDictionary = @{@"timePunchUris": uriArray, @"limit" : [NSNull null]};
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"GetAuditHistoryForPunches"
                                                                                    httpBodyDictionary:bodyDictionary];
    
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];
    
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];
    
    [jsonPromise then:^id(NSArray *json) {
        NSArray  *punchLogs = [self.auditHistoryDeserializer deserialize:json];
        [self.auditHistoryStorage storePunchLogs:json];
        [deferred resolveWithValue:punchLogs];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    
    return deferred.promise;
}

@end
