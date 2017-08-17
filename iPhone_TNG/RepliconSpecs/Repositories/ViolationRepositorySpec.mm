#import <Cedar/Cedar.h>
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>

#import "ViolationRepository.h"
#import "InjectorProvider.h"
#import "RequestPromiseClient.h"
#import "ViolationRequestProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "ViolationsDeserializer.h"
#import "DateProvider.h"
#import "RepliconClient.h"
#import "ViolationsForTimesheetPeriodDeserializer.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "ViolationsForPunchDeserializer.h"
#import "InjectorKeys.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationRepositorySpec)

describe(@"ViolationRepository", ^{
    __block ViolationRepository *subject;
    __block id<RequestPromiseClient> client;
    __block ViolationsDeserializer *deserializer;
    __block ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;
    __block ViolationsForPunchDeserializer *violationsForPunchDeserializer;
    __block ViolationRequestProvider *requestProvider;
    __block DateProvider *dateProvider;

    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        dateProvider = nice_fake_for([DateProvider class]);
        [injector bind:[DateProvider class] toInstance:dateProvider];

        requestProvider = nice_fake_for([ViolationRequestProvider class]);
        [injector bind:[ViolationRequestProvider class] toInstance:requestProvider];

        deserializer = nice_fake_for([ViolationsDeserializer class]);
        [injector bind:[ViolationsDeserializer class] toInstance:deserializer];

        violationsForTimesheetPeriodDeserializer = nice_fake_for([ViolationsForTimesheetPeriodDeserializer class]);
        [injector bind:[ViolationsForTimesheetPeriodDeserializer class] toInstance:violationsForTimesheetPeriodDeserializer];

        violationsForPunchDeserializer = nice_fake_for([ViolationsForPunchDeserializer class]);
        [injector bind:[ViolationsForPunchDeserializer class] toInstance:violationsForPunchDeserializer];

        client = nice_fake_for(@protocol(RequestPromiseClient));
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];

        subject  = [injector getInstance:[ViolationRepository class]];
    });

    describe(@"fetching AllViolationSections for today", ^{
        __block KSPromise *promise;
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block NSDate *expectedDate;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];

            expectedDate = nice_fake_for([NSDate class]);
            dateProvider stub_method(@selector(date)).and_return(expectedDate);
            request = nice_fake_for([NSURLRequest class]);
            requestProvider stub_method(@selector(provideRequestWithDate:)).and_return(request);
            client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);

            promise = [subject fetchAllViolationSectionsForToday];
        });

        it(@"should get the request from the request provider with the expected date", ^{
            requestProvider should have_received(@selector(provideRequestWithDate:)).with(expectedDate);
        });

        context(@"when the request is successful", ^{
            __block NSArray *expectedViolations;
            beforeEach(^{
                expectedViolations = @[@1, @2];
                NSDictionary *responseDictionary = @{};
                deserializer stub_method(@selector(deserialize:)).with(responseDictionary).and_return(expectedViolations);
                [deferred resolveWithValue:responseDictionary];
            });

            it(@"should resolve the promise with the deserialized value", ^{
                AllViolationSections *allViolationSections = promise.value;

                allViolationSections should be_instance_of([AllViolationSections class]);

                allViolationSections.totalViolationsCount should equal(2);
                allViolationSections.sections.count should equal(1);

                ViolationSection *section = [allViolationSections.sections firstObject];
                section.titleObject should be_same_instance_as(expectedDate);
                section.violations should be_same_instance_as(expectedViolations);
                section.type should equal(ViolationSectionTypeDate);
            });
        });

        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });

            it(@"should reject the promise with the error", ^{
                promise.error should be_same_instance_as(error);
            });
        });
    });

    describe(@"fetching violations for a punch", ^{
        __block KSPromise *promise;
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block NSString *expectedPunchURI;

        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            expectedPunchURI = @"my-punch-uri";

            request = nice_fake_for([NSURLRequest class]);
            requestProvider stub_method(@selector(provideRequestWithPunchURI:))
                .with(expectedPunchURI)
                .and_return(request);

            client stub_method(@selector(promiseWithRequest:))
                .with(request)
                .and_return(deferred.promise);
            promise = [subject fetchValidationsForPunchURI:expectedPunchURI];
        });

        context(@"when the request is successful", ^{
            beforeEach(^{
                NSDictionary *responseDictionary = @{};
                violationsForPunchDeserializer stub_method(@selector(deserialize:))
                    .with(responseDictionary)
                    .and_return(@123);
                [deferred resolveWithValue:responseDictionary];
            });

            it(@"should resolve the promise with the deserialized value", ^{
                promise.value should equal(@123);
            });
        });

        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });

            it(@"should reject the promise with the error", ^{
                promise.error should be_same_instance_as(error);
            });
        });
    });
});

SPEC_END
