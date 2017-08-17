#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchRequestProvider.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "ImageNameConstants.h"
#import "GUIDProvider.h"
#import "URLStringProvider.h"
#import "OfflineLocalPunch.h"
#import "RemotePunch.h"
#import "PunchRequestBodyProvider.h"
#import "NSUUID+Spec.h"
#import "Constants.h"
#import "DateProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchRequestProviderSpec)

describe(@"PunchRequestProvider", ^{
    __block PunchRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block PunchRequestBodyProvider *punchRequestBodyProvider;
    __block DateProvider *dateProvider;
    __block NSDateFormatter *dateFormatter;

    beforeEach(^{
        urlStringProvider = fake_for([URLStringProvider class]);

        punchRequestBodyProvider = fake_for([PunchRequestBodyProvider class]);

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:1467801470];
        dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);

        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];
        dateFormatter.dateFormat = @"EE, dd MMM yyyy HH:mm:ss ZZZ";


        subject = [[PunchRequestProvider alloc] initWithPunchRequestBodyProvider:punchRequestBodyProvider urlStringProvider:urlStringProvider dateProvider:dateProvider dateFormatter:dateFormatter];
    });

    describe(@"mostRecentPunchRequest", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            punchRequestBodyProvider stub_method(@selector(requestBodyForMostRecentPunchForUserUri:))
                .and_return(@{@"my": @"body"});

            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"LastPunchData").and_return(@"http://expected.endpoint/name");

            request = [subject mostRecentPunchRequestForUserUri:nil];
        });

        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];

            httpBody should equal(@{@"my": @"body"});
        });
    });

    describe(@"punchRequestWithPunch:", ^{
        __block NSURLRequest *request;

        context(@"for a single punch", ^{
            beforeEach(^{
                id<Punch> punch = fake_for(@protocol(Punch));

                punchRequestBodyProvider stub_method(@selector(requestBodyForPunch:))
                .with(@[punch]).and_return(@{@"my": @"body"});

                punch stub_method(@selector(requestID)).and_return(@"ABCD1234");

                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(BulkPunchWithCreatedAtTime3).and_return(@"http://expected.endpoint/name");

                request = [subject punchRequestWithPunch:@[punch]];
            });

            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");

                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];

                httpBody should equal(@{@"my": @"body"});
                
                [request valueForHTTPHeaderField:PunchRequestIdentifierHeader] should equal(@"ABCD1234");
            });
        });

        context(@"for multiple punches", ^{
            beforeEach(^{
                id<Punch> punchA = fake_for(@protocol(Punch));
                id<Punch> punchB = fake_for(@protocol(Punch));

                punchRequestBodyProvider stub_method(@selector(requestBodyForPunch:))
                .with(@[punchA,punchB]).and_return(@{@"my": @"body"});

                punchA stub_method(@selector(requestID)).and_return(@"punch1");
                punchB stub_method(@selector(requestID)).and_return(@"punch2");

                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(BulkPunchWithCreatedAtTime3).and_return(@"http://expected.endpoint/name");

                request = [subject punchRequestWithPunch:@[punchA,punchB]];
            });

            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");

                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];

                httpBody should equal(@{@"my": @"body"});
                
                [request valueForHTTPHeaderField:PunchRequestIdentifierHeader] should equal(@"punch1|punch2");
            });
        });

    });

    describe(NSStringFromSelector(@selector(requestForPunchesWithDate:userURI:)), ^{
        __block NSURLRequest *request;

        beforeEach(^{
            NSDate *date = fake_for([NSDate class]);
            NSString *userURI = @"test user";

            punchRequestBodyProvider stub_method(@selector(requestBodyForPunchesWithDate:userURI:))
                .with(date, userURI).and_return(@{@"my": @"body"});

            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetTimePunchDetailsForUserAndDateRange").and_return(@"http://expected.endpoint/name");

            request = [subject requestForPunchesWithDate:date userURI:userURI];
        });

        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];

            httpBody should equal(@{@"my": @"body"});
        });
    });

    describe(NSStringFromSelector(@selector(requestForPunchesWithLastTwoMostRecentPunchWithDate:)), ^{
        __block NSURLRequest *request;

        beforeEach(^{
            NSDate *date = nice_fake_for([NSDate class]);

            punchRequestBodyProvider stub_method(@selector(requestBodyForPunchesWithLastTwoMostRecentPunchWithDate:))
            .with(date).and_return(@{@"my": @"body"});

            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"TimelinePunches").and_return(@"http://expected.endpoint/name");

            request = [subject requestForPunchesWithLastTwoMostRecentPunchWithDate:date];
        });

        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];

            httpBody should equal(@{@"my": @"body"});

        });

        it(@"should have correct headers", ^{

            [request valueForHTTPHeaderField:MostRecentPunchDateIdentifierHeader] should equal(@"Wed, 06 Jul 2016 16:07:50 +0530");

        });
    });

    describe(@"deletePunchRequestWithPunchUri:", ^{
        __block NSURLRequest *request;

        beforeEach(^{
            punchRequestBodyProvider stub_method(@selector(requestBodyToDeletePunchWithURI:))
                .with(@"My-Punch-Uri").and_return(@{@"my": @"body"});


            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"DeletePunch").and_return(@"http://expected.endpoint/name");

            request = [subject deletePunchRequestWithPunchUri:@"My-Punch-Uri"];
        });

        it(@"should return a correctly configured request", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"http://expected.endpoint/name");

            NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                     options:0
                                                                       error:nil];

            httpBody should equal(@{@"my": @"body"});


        });
    });

    describe(@"requestToUpdatePunch:", ^{
        __block NSURLRequest *request;

        context(@"for a single punch", ^{
            beforeEach(^{
                RemotePunch *punch = fake_for([RemotePunch class]);

                punchRequestBodyProvider stub_method(@selector(requestBodyToUpdatePunch:))
                .with(@[punch]).and_return(@{@"my": @"body"});

                punch stub_method(@selector(requestID)).and_return(@"ABCD1234");

                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"PutTimePunch2").and_return(@"http://expected.endpoint/name");

                request = [subject requestToUpdatePunch:@[punch]];
            });

            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");

                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];
                
                httpBody should equal(@{@"my": @"body"});
            });
        });

        context(@"for multiple punches", ^{
            beforeEach(^{
                RemotePunch *punchA = fake_for([RemotePunch class]);
                RemotePunch *punchB = fake_for([RemotePunch class]);

                punchRequestBodyProvider stub_method(@selector(requestBodyForPunch:))
                .with(@[punchA,punchB]).and_return(@{@"my": @"body"});

                punchA stub_method(@selector(requestID)).and_return(@"punch1");
                punchB stub_method(@selector(requestID)).and_return(@"punch2");

                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(BulkPunchWithCreatedAtTime3).and_return(@"http://expected.endpoint/name");
                request = [subject punchRequestWithPunch:@[punchA,punchB]];
            });

            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");

                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];

                httpBody should equal(@{@"my": @"body"});

                [request valueForHTTPHeaderField:PunchRequestIdentifierHeader] should equal(@"punch1|punch2");
            });
        });


    });
});

SPEC_END
