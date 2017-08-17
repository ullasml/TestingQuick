
#import <Foundation/Foundation.h>
@class KSPromise;

@protocol ClientRepositoryProtocol

- (KSPromise *)fetchAllClients;

- (KSPromise *)fetchFreshClients;

- (KSPromise *)fetchMoreClientsMatchingText:(NSString *)text;

- (KSPromise *)fetchClientsMatchingText:(NSString *)text;

- (KSPromise *)fetchCachedClientsMatchingText:(NSString *)text;

@end
