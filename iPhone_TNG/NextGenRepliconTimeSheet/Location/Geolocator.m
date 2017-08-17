#import "Geolocator.h"
#import <KSDeferred/KSDeferred.h>
#import "LocationRepository.h"
#import "AddressRepository.h"
#import "Geolocation.h"

@interface Geolocator()
@property (nonatomic) LocationRepository *locationRepository;
@property (nonatomic) AddressRepository *addressRepository;

@end
@implementation Geolocator

- (instancetype)initWithLocationRepository:(LocationRepository *)locationRepository addressRepository:(AddressRepository *)addressRepository;
{
    self = [super init];
    if (self) {
        self.locationRepository = locationRepository;
        self.addressRepository = addressRepository;
    }
    return self;
}


- (KSPromise *) mostRecentGeolocationPromise
{
    KSDeferred *geolocationDeferred = [[KSDeferred  alloc] init];

    KSPromise *locationPromise = [self.locationRepository mostRecentLocationPromise];

    [locationPromise then:^id(CLLocation *location) {
        KSPromise *addressPromise = [self.addressRepository addressPromiseWithCoordinates:location.coordinate];

        [addressPromise then:^id(NSString *address) {
            Geolocation *geolocation = [[Geolocation alloc] initWithLocation:location address:address];
            [geolocationDeferred resolveWithValue:geolocation];
            return nil;
        } error:^id(NSError *error) {
            Geolocation *geolocation = [[Geolocation alloc] initWithLocation:location address:nil];
            [geolocationDeferred resolveWithValue:geolocation];
            return nil;
        }];
        return nil;
    } error:^id(NSError *error) {
        [geolocationDeferred rejectWithError:error];
        return nil;
    }];

    return geolocationDeferred.promise;
}
@end
