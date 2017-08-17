
#import <Foundation/Foundation.h>

@class KSPromise;
@class LocalPunch;
@class PunchCardObject;
@class AddressControllerPresenterProvider;



@interface PunchIntoProjectControllerProvider : NSObject

@property (nonatomic, readonly) AddressControllerPresenterProvider *addressControllerPresenterProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithAddressControllerPresenterProvider:(AddressControllerPresenterProvider *)addressControllerPresenterProvider;

- (UIViewController *)punchControllerWithDelegate:(id)delegate
                      serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                            assembledPunchPromise:(KSPromise *)assembledPunchPromise
                                  punchCardObject:(PunchCardObject *)punchCardObject
                                            punch:(LocalPunch *)punch
                                   punchesPromise:(KSPromise *)punchesPromise;

@end

