#import <Cedar/Cedar.h>
#import "ViolationRequestProvider.h"
#import "URLStringProvider.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationRequestProviderSpec)

describe(@"ViolationRequestProvider", ^{
    __block ViolationRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        urlStringProvider = nice_fake_for([URLStringProvider class]);
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];

        subject = [injector getInstance:[ViolationRequestProvider class]];
    });

    describe(@"provideRequestWithDate:", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:)).and_return(@"http://expected.endpoint/name");

            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1430331456]; // 2014-04-29
            request = [subject provideRequestWithDate:date];
        });

        it(@"should get the url from the provider", ^{
            urlStringProvider should have_received(@selector(urlStringWithEndpointName:)).with(@"GetCurrentDateViolations");
        });

        it(@"should create a POST request", ^{
            request.HTTPMethod should equal(@"POST");
        });

        it(@"should create a request with the correct URL", ^{
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
        });

        it(@"should create a request with the correct HTTP body", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];


            NSDictionary *expectedRequestBodyDictionary = @{
                                                            @"date": @{
                                                                    @"year": @2015,
                                                                    @"month": @4,
                                                                    @"day": @29
                                                                    }
                                                            };

            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });
    });

    describe(@"provideRequestWithPunchURI:", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetMostRecentValidationResult")
                .and_return(@"http://expected.endpoint/name");


            request = [subject provideRequestWithPunchURI:@"my-special-punch-uri"];
        });

        it(@"should create a POST request", ^{
            request.HTTPMethod should equal(@"POST");
        });

        it(@"should create a request with the correct URL", ^{
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");
        });

        it(@"should create a request with the correct HTTP body", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];

            NSDictionary *expectedRequestBodyDictionary = @{@"timePunchUri": @"my-special-punch-uri"};

            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });
    });
});

SPEC_END
