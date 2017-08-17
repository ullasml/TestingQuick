#import "PunchLogRepository.h"
#import "PunchLog.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchLogRequestProvider.h"
#import "PunchLogDeserializer.h"
#import "RequestPromiseClient.h"


@interface PunchLogRepository ()

@property (nonatomic) PunchLogRequestProvider *requestProvider;
@property (nonatomic) PunchLogDeserializer *deserializer;
@property (nonatomic) id<RequestPromiseClient> client;

@end


@implementation PunchLogRepository

- (instancetype)initWithPunchLogRequestProvider:(PunchLogRequestProvider *)requestProvider
                           punchLogDeserializer:(PunchLogDeserializer *)deserializer
                           requestPromiseClient:(id<RequestPromiseClient>)client
{
    self = [super init];
    if (self)
    {
        self.requestProvider = requestProvider;
        self.deserializer = deserializer;
        self.client = client;
    }
    return self;
}

- (KSPromise *)fetchPunchLogsForPunchURI:(NSString *)punchURI
{
    NSURLRequest *request = [self.requestProvider requestWithPunchURI:punchURI];
    KSPromise *promise = [self.client promiseWithRequest:request];

    return [promise then:^id(NSArray *json) {
        return [self.deserializer deserialize:json];
    } error:nil];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
