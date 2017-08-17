
#import "AppConfigRepository.h"
#import "ReachabilityMonitor.h"
#import "PersistedSettingsStorage.h"
#import "NetworkClient.h"

@import KSDeferred;

@interface AppConfigRepository()
@property (nonatomic, strong) PersistedSettingsStorage *persistedSettingsStorage;
@property (nonatomic, strong) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, strong) NetworkClient *networkClient;
@end

@implementation AppConfigRepository


- (instancetype)initWithPersistedSettingsStorage:(PersistedSettingsStorage *)persistedSettingsStorage
                             reachabilityMonitor:(ReachabilityMonitor *) reachabilityMonitor
                                   networkClient:(NetworkClient *)networkClient
{
    self = [super init];
    if (self) {
        self.persistedSettingsStorage = persistedSettingsStorage;
        self.reachabilityMonitor = reachabilityMonitor;
        self.networkClient = networkClient;
    }
    return self;
}


#pragma mark -- properties

-(KSPromise *)appConfigForRequest:(NSMutableURLRequest *)request {

    KSDeferred *deferred = [[KSDeferred alloc] init];
    if ([self.reachabilityMonitor isNetworkReachable]) {
        KSPromise *voidPromise = [self.networkClient promiseWithRequest:request];
        [voidPromise then:^id(NSDictionary *appConfigDictionary) {
            if(appConfigDictionary!=nil && appConfigDictionary!=(id)[NSNull null]){
                [self.persistedSettingsStorage storeAppConfigDictionary:appConfigDictionary];
                [deferred resolveWithValue:nil];
            }
            return nil;
        } error:^id(NSError *error) {
            [deferred rejectWithError:nil];
            return nil;
        }];
        return deferred.promise;
    }
    return nil;
}


@end
