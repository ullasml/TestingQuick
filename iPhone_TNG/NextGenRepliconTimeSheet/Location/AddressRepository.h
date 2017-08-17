#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class KSPromise;
@class JSONClient;


@interface AddressRepository : NSObject

@property (nonatomic, readonly) JSONClient *client;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithClient:(JSONClient *)client;

- (KSPromise *)addressPromiseWithCoordinates:(CLLocationCoordinate2D)coordinates;

@end
