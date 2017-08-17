#import <Cedar/Cedar.h>
#import "PunchLogRepository.h"
#import "PunchLogRequestProvider.h"
#import "PunchLogDeserializer.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSDeferred.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchLogRepositorySpec)

describe(@"PunchLogRepository", ^{
    __block PunchLogRepository *subject;
    __block PunchLogRequestProvider *requestProvider;
    __block PunchLogDeserializer *deserializer;
    __block id<RequestPromiseClient> client;

    beforeEach(^{
        requestProvider = nice_fake_for([PunchLogRequestProvider class]);
        deserializer = nice_fake_for([PunchLogDeserializer class]);
        client = nice_fake_for(@protocol(RequestPromiseClient));

        subject = [[PunchLogRepository alloc] initWithPunchLogRequestProvider:requestProvider
                                                         punchLogDeserializer:deserializer
                                                         requestPromiseClient:client];
    });

    describe(@"-fetchPunchLogsForPunch:", ^{
        __block KSPromise *promise;
        __block KSDeferred *deferred;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];

            NSURLRequest *request = fake_for([NSURLRequest class]);
            requestProvider stub_method(@selector(requestWithPunchURI:))
                .with(@"my-special-punch-uri")
                .and_return(request);

            client stub_method(@selector(promiseWithRequest:))
                .with(request)
                .and_return(deferred.promise);

            promise = [subject fetchPunchLogsForPunchURI:@"my-special-punch-uri"];
        });

        context(@"when the request succeeds", ^{
            beforeEach(^{
                deserializer stub_method(@selector(deserialize:)).with(@123).and_return(@456);
                [deferred resolveWithValue:@123];
            });

            it(@"should pass the returning json into the deserializer and resolve the promise with the deserialized response", ^{
                promise.value should equal(@456);
            });
        });

        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });

            it(@"should resolve the promise with the error", ^{
                promise.error should be_same_instance_as(error);
            });
        });
    });
});

SPEC_END
