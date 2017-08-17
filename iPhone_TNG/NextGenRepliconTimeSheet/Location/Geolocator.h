#import <Foundation/Foundation.h>

@class LocationRepository;
@class AddressRepository;
@class KSPromise;


@interface Geolocator : NSObject

@property (nonatomic, readonly) LocationRepository *locationRepository;
@property (nonatomic, readonly) AddressRepository *addressRepository;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLocationRepository:(LocationRepository *)locationRepository addressRepository:(AddressRepository *)addressRepository;

- (KSPromise *) mostRecentGeolocationPromise;

@end
