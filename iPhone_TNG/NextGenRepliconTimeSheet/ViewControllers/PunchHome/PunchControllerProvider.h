#import <Foundation/Foundation.h>


@class KSPromise;
@class LocalPunch;
@class AddressControllerPresenterProvider;
@class TimeLineControllerPresenterProvider;
@protocol OnBreakControllerDelegate;
@protocol PunchInControllerDelegate;
@protocol PunchOutControllerDelegate;


@interface PunchControllerProvider : NSObject

@property (nonatomic, readonly) AddressControllerPresenterProvider *addressControllerPresenterProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAddressControllerPresenterProvider:(AddressControllerPresenterProvider *)addressControllerPresenterProvider;

- (UIViewController *)punchControllerWithDelegate:(id<PunchInControllerDelegate, PunchOutControllerDelegate, OnBreakControllerDelegate>)delegate
                      serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                            assembledPunchPromise:(KSPromise *)assembledPunchPromise
                                            punch:(LocalPunch *)punch
                                   punchesPromise:(KSPromise *)punchesPromise;

@end
