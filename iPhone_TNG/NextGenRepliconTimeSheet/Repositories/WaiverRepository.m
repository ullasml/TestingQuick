#import "WaiverRepository.h"
#import "RequestPromiseClient.h"
#import "UpdateWaiverRequestProvider.h"


@interface WaiverRepository ()

@property (nonatomic) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic) UpdateWaiverRequestProvider *updateWaiverRequestProvider;

@end


@implementation WaiverRepository

- (instancetype)initWithRequestPromiseClient:(id<RequestPromiseClient>)requestPromiseClient
                 updateWaiverRequestProvider:(UpdateWaiverRequestProvider *)updateWaiverRequestProvider
{
    self = [super init];
    if (self) {
        self.requestPromiseClient = requestPromiseClient;
        self.updateWaiverRequestProvider = updateWaiverRequestProvider;
    }
    return self;
}

- (KSPromise *)updateWaiver:(Waiver *)waiver withWaiverOption:(WaiverOption *)waiverOption
{
    NSURLRequest *request = [self.updateWaiverRequestProvider provideRequestWithWaiver:waiver waiverOption:waiverOption];

    return [self.requestPromiseClient promiseWithRequest:request];
}

@end
