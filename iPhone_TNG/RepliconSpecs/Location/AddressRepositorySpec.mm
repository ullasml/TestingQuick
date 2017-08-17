#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "AddressRepository.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "RepliconSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AddressRepositorySpec)

describe(@"AddressRepository", ^{
    __block AddressRepository *subject;
    __block JSONClient *client;
    __block NSURLRequest *request;
    __block KSDeferred *deferred;

    beforeEach(^{
        deferred = [[KSDeferred alloc] init];
        client = nice_fake_for([JSONClient class]);

        client stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *incomingRequest) {
            request = incomingRequest;

            return deferred.promise;
        });

        subject = [[AddressRepository alloc] initWithClient:client];
    });

    describe(NSStringFromSelector(@selector(addressPromiseWithCoordinates:)), ^{
        describe(@"getting the address for a lat / long pair", ^{
            __block KSPromise *addressPromise;

            beforeEach(^{
                CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(10.1, 20.2);
                addressPromise = [subject addressPromiseWithCoordinates:coordinates];
            });

            it(@"should make a request to the json client", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            it(@"should format the request correctly", ^{
                request.URL.absoluteString should equal(@"https://maps.googleapis.com/maps/api/geocode/json?latlng=10.1,20.2");
                request.HTTPMethod should equal(@"GET");
            });

            context(@"when the request succeeds", ^{
                beforeEach(^{
                    NSDictionary *jsonResponse = [RepliconSpecHelper jsonWithFixture:@"golden_gate_bridge"];
                    [deferred resolveWithValue:jsonResponse];
                });

                it(@"should resolve the promise with the address", ^{
                    addressPromise.value should equal(@"1415 Golden Gate Bridge, San Francisco, CA, USA");
                });
            });

            context(@"when the request fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                });

                it(@"should reject the promise", ^{
                    addressPromise.error should be_same_instance_as(error);
                });
            });
        });
    });
});

SPEC_END

