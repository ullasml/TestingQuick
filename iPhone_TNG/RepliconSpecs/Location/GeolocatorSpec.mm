#import <Cedar/Cedar.h>
#import "Geolocator.h"
#import "LocationRepository.h"
#import "AddressRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "Geolocation.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GeolocatorSpec)

describe(@"Geolocator", ^{
    __block Geolocator *subject;
    __block AddressRepository *addressRepository;
    __block LocationRepository *locationRepository;

    beforeEach(^{
        locationRepository = nice_fake_for([LocationRepository class]);
        addressRepository = nice_fake_for([AddressRepository class]);
        subject = [[Geolocator alloc] initWithLocationRepository:locationRepository addressRepository:addressRepository];
    });

    describe(NSStringFromSelector(@selector(mostRecentGeolocationPromise)), ^{
        describe(@"Fetching a geolocation", ^{
            __block KSDeferred *locationDeferred;
            __block KSPromise *geolocationPromise;
            __block Geolocation *receivedGeolocation;
            __block NSError *receivedError;


            beforeEach(^{
                locationDeferred = [[KSDeferred alloc] init];

                locationRepository stub_method(@selector(mostRecentLocationPromise)).and_return(locationDeferred.promise);

                geolocationPromise = [subject mostRecentGeolocationPromise];
                [geolocationPromise then:^id(Geolocation *geolocation) {
                    receivedGeolocation = geolocation;
                    return nil;
                } error:^id(NSError *error) {
                    receivedError = error;
                    return nil;
                }];
            });

            it(@"should ask the location repository for its most recent location", ^{
                locationRepository should have_received(@selector(mostRecentLocationPromise));
            });

            it(@"should not have resolved or rejected the geolocation promise", ^{
                geolocationPromise.fulfilled should be_falsy;
                geolocationPromise.rejected should be_falsy;
            });

            context(@"when the location is sucessfully returned by the location repository", ^{
                __block KSDeferred *addressDeferred;
                __block CLLocation *resolvedLocation;
                __block CLLocationCoordinate2D receivedCoordinates;

                beforeEach(^{
                    addressDeferred = [[KSDeferred alloc] init];

                    resolvedLocation = [[CLLocation alloc] initWithLatitude:1.0 longitude:2.0];

                    addressRepository stub_method(@selector(addressPromiseWithCoordinates:)).and_do_block(^KSPromise *(CLLocationCoordinate2D incomingCoordinates){
                        receivedCoordinates = incomingCoordinates;

                        return addressDeferred.promise;
                    });

                    [locationDeferred resolveWithValue:resolvedLocation];
                });

                it(@"should ask the address repository for an address", ^{
                    addressRepository should have_received(@selector(addressPromiseWithCoordinates:));
                    receivedCoordinates.latitude should equal(1.0);
                    receivedCoordinates.longitude should equal(2.0);
                });

                it(@"should not have resolved or rejected the geolocation promise", ^{
                    geolocationPromise.fulfilled should be_falsy;
                    geolocationPromise.rejected should be_falsy;
                });

                context(@"when the address is succesfully returned by the address repository", ^{
                    beforeEach(^{
                        [addressDeferred resolveWithValue:@"Some Magic Street"];
                    });

                    it(@"should resolve the geolocation promise with a valid geolocation", ^{
                        geolocationPromise.fulfilled should be_truthy;

                        receivedGeolocation.address should equal(@"Some Magic Street");
                        receivedGeolocation.location should equal(resolvedLocation);
                    });
                });

                context(@"when the address repository fails to find an address succesfully", ^{
                    beforeEach(^{
                        [addressDeferred rejectWithError:nil];
                    });

                    it(@"should resolve the geolocation promise with a valid geolocation", ^{
                        geolocationPromise.fulfilled should be_truthy;

                        receivedGeolocation.address should be_nil;
                        receivedGeolocation.location should equal(resolvedLocation);
                    });
                });
            });

            context(@"when the location repository fails to fetch a location succesfully", ^{
                __block NSError *locationError;

                beforeEach(^{
                    locationError = [NSError errorWithDomain:@"location problems" code:0 userInfo:nil];
                    [locationDeferred rejectWithError:locationError];
                });

                it(@"should reject the geolocation promise", ^{
                    geolocationPromise.rejected should be_truthy;
                });

                it(@"should forward the error from the location repository", ^{
                    receivedError should be_same_instance_as(locationError);
                });
            });
        });
    });
});

SPEC_END
