#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class KSPromise;


@interface LocationRepository : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly) CLLocationManager *locationManager;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager;

- (KSPromise *)mostRecentLocationPromise;

@end
