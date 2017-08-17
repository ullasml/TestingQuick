#import <Cedar/Cedar.h>
#import "WaiverRepository.h"
#import "RequestPromiseClient.h"
#import "UpdateWaiverRequestProvider.h"
#import "Waiver.h"
#import "WaiverOption.h"
#import <KSDeferred/KSDeferred.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(WaiverRepositorySpec)

describe(@"WaiverRepository", ^{
    __block WaiverRepository *subject;
    __block id<RequestPromiseClient>requestPromiseClient;
    __block UpdateWaiverRequestProvider *updateWaiverRequestProvider;

    beforeEach(^{
        requestPromiseClient = nice_fake_for(@protocol(RequestPromiseClient));
        updateWaiverRequestProvider = nice_fake_for([UpdateWaiverRequestProvider class]);

        subject = [[WaiverRepository alloc] initWithRequestPromiseClient:requestPromiseClient updateWaiverRequestProvider:updateWaiverRequestProvider];
    });

    describe(@"updating a waiver with a selected waiver option", ^{
        __block Waiver *waiver;
        __block WaiverOption *waiverOption;
        __block NSURLRequest *waiverRequest;
        __block KSPromise *promise;
        __block KSDeferred *deferred;

        beforeEach(^{
            waiver = nice_fake_for([Waiver class]);
            waiverOption = nice_fake_for([WaiverOption class]);
            waiverRequest = nice_fake_for([NSURLRequest class]);
            deferred = [[KSDeferred alloc] init];
            updateWaiverRequestProvider stub_method(@selector(provideRequestWithWaiver:waiverOption:)).and_return(waiverRequest);

            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);

            promise = [subject updateWaiver:waiver withWaiverOption:waiverOption];
        });

        it(@"should create the request with the waiver and waiver option", ^{
            updateWaiverRequestProvider should have_received(@selector(provideRequestWithWaiver:waiverOption:)).with(waiver, waiverOption);
        });

        it(@"should create a request with the provider and send it to the request promise client ", ^{
            requestPromiseClient should have_received(@selector(promiseWithRequest:)).with(waiverRequest);
        });

        it(@"should return the deferred's promise", ^{
            promise should be_same_instance_as(deferred.promise);
        });
    });
});

SPEC_END
