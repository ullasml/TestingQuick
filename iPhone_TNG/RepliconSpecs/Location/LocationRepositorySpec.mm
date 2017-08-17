#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationRepository.h"
#import <KSDeferred/KSDeferred.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(LocationRepositorySpec)

describe(@"LocationRepository", ^{
    __block LocationRepository *subject;
    __block CLLocationManager *locationManager;

    beforeEach(^{
        locationManager = nice_fake_for([CLLocationManager class]);

        subject = [[LocationRepository alloc] initWithLocationManager:locationManager];
    });

    it(@"should set itself as the location manager's delegate", ^{
        locationManager should have_received(@selector(setDelegate:)).with(subject);
    });

    it(@"should request the user's permission to use location data", ^{
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            locationManager should have_received(@selector(requestWhenInUseAuthorization));
            locationManager should have_received(@selector(requestAlwaysAuthorization));
        }
    });

    it(@"should tell the location manager to start getting location data", ^{
        locationManager should have_received(@selector(startUpdatingLocation));
    });

    describe(NSStringFromSelector(@selector(mostRecentLocationPromise)), ^{
        describe(@"getting a promise for the most recent location", ^{
            __block KSPromise *mostRecentLocationPromise;

            context(@"when the location hasn't been updated yet", ^{
                beforeEach(^{
                    mostRecentLocationPromise = [subject mostRecentLocationPromise];
                });

                context(@"when the location is not yet available", ^{
                    it(@"should not resolve the promise", ^{
                        mostRecentLocationPromise.fulfilled should_not be_truthy;
                        mostRecentLocationPromise.rejected should_not be_truthy;
                        mostRecentLocationPromise.cancelled should_not be_truthy;
                    });
                });

                context(@"when the location is available", ^{
                    __block CLLocation *firstLocation;
                    __block CLLocation *mostRecentLocation;

                    beforeEach(^{
                        firstLocation = fake_for([CLLocation class]);
                        mostRecentLocation = fake_for([CLLocation class]);
                        [subject locationManager:locationManager didUpdateLocations:@[firstLocation, mostRecentLocation]];
                    });

                    it(@"should resolve the promise with the most recent location ", ^{
                        mostRecentLocationPromise.value should be_same_instance_as(mostRecentLocation);
                    });
                });

                context(@"when the location is not available", ^{
                    __block NSError *error;

                    beforeEach(^{
                        error = fake_for([NSError class]);
                        [subject locationManager:locationManager didFailWithError:error];
                    });

                    it(@"should reject the promise with the error ", ^{
                        mostRecentLocationPromise.error should be_same_instance_as(error);
                    });
                });
            });

            context(@"when the location has already been updated", ^{
                __block CLLocation *location;

                beforeEach(^{
                    location = fake_for([CLLocation class]);

                    [subject locationManager:locationManager didUpdateLocations:@[location]];

                    mostRecentLocationPromise = [subject mostRecentLocationPromise];
                });

                it(@"should resolve the mostRecentLocationPromise immediately", ^{
                    mostRecentLocationPromise.value should be_same_instance_as(location);
                });
            });

            context(@"when the location manager has an old location", ^{
                __block CLLocation *location;

                beforeEach(^{
                    location = fake_for([CLLocation class]);
                    locationManager stub_method(@selector(location)).and_return(location);

                    mostRecentLocationPromise = [subject mostRecentLocationPromise];
                });

                it(@"should resolve the mostRecentLocationPromise immediately", ^{
                    mostRecentLocationPromise.value should be_same_instance_as(location);
                });
            });
        });
    });
});

SPEC_END
