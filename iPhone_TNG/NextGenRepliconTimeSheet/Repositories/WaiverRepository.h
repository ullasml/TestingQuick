#import <Foundation/Foundation.h>


@class UpdateWaiverRequestProvider;
@class KSPromise;
@class Waiver;
@class WaiverOption;
@protocol RequestPromiseClient;


@interface WaiverRepository : NSObject

@property (nonatomic, readonly) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic, readonly) UpdateWaiverRequestProvider *updateWaiverRequestProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRequestPromiseClient:(id<RequestPromiseClient>)requestPromiseClient
                 updateWaiverRequestProvider:(UpdateWaiverRequestProvider *)updateWaiverRequestProvider NS_DESIGNATED_INITIALIZER;

- (KSPromise *)updateWaiver:(Waiver *)waiver withWaiverOption:(WaiverOption *)waiverOption;

@end
