#import <Cedar/Cedar.h>
#import "TeamStatusSummaryRepository.h"
#import "RequestDictionaryBuilder.h"
#import <KSDeferred/KSDeferred.h>
#import "JSONClient.h"
#import "DateProvider.h"
#import "TeamStatusSummaryDeserializer.h"
#import "TeamStatusSummary.h"
#import "RepliconSpecHelper.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "RepliconClient.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamStatusSummaryRepositorySpec)

describe(@"TeamStatusSummaryRepository", ^{
    __block TeamStatusSummaryRepository *subject;
    __block RequestDictionaryBuilder *requestDictionaryBuilder;
    __block DateProvider *dateProvider;
    __block TeamStatusSummaryDeserializer *teamStatusSummaryDeserializer;

    __block KSDeferred *jsonClientDeferred;
    __block id <RequestPromiseClient> jsonClient;
    __block NSURLRequest *jsonClientRequest;
    __block id<BSBinder, BSInjector> injector;
    __block NSCalendar *calendar;

    beforeEach(^{
        injector = [InjectorProvider injector];

        jsonClientDeferred = [[KSDeferred alloc]init];
        jsonClient = nice_fake_for(@protocol(RequestPromiseClient));

        jsonClient stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            jsonClientRequest = receivedRequest;
            return jsonClientDeferred.promise;
        });

        requestDictionaryBuilder = nice_fake_for([RequestDictionaryBuilder class]);
        dateProvider = nice_fake_for([DateProvider class]);
        teamStatusSummaryDeserializer = nice_fake_for([TeamStatusSummaryDeserializer class]);


        [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonClient];
        [injector bind:[RequestDictionaryBuilder class] toInstance:requestDictionaryBuilder];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:[TeamStatusSummaryDeserializer class] toInstance:teamStatusSummaryDeserializer];

        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:calendar];


        NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
        longDateFormatter.timeZone = [NSTimeZone localTimeZone];
        longDateFormatter.dateFormat = @"MMM d, YYYY";
        [injector bind:InjectorKeyShortDateWithYearInLocalTimeZoneDateFormatter toInstance:longDateFormatter];


        subject = [injector getInstance:[TeamStatusSummaryRepository class]];
    });

    it(@"should correctly set the values from the intialisers", ^{
        subject.client should be_same_instance_as(jsonClient);
        subject.requestDictionaryBuilder should be_same_instance_as(requestDictionaryBuilder);
        subject.teamStatusSummaryDeserializer should be_same_instance_as(teamStatusSummaryDeserializer);
        subject.dateProvider should be_same_instance_as(dateProvider);
    });

    describe(@"-fetchTeamStatusSummary", ^{
        describe(@"Fetching the team status summary from the API", ^{
            __block KSPromise *fetchTeamStatusSummaryPromise;

            beforeEach(^{
                NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
                [dateComponents setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
                [dateComponents setHour:23];
                [dateComponents setMinute:0];
                [dateComponents setSecond:24];
                [dateComponents setYear:2015];
                [dateComponents setMonth:8];
                [dateComponents setDay:2];
                NSDate *expectedDate = [calendar dateFromComponents:dateComponents];
                dateProvider stub_method(@selector(date)).and_return(expectedDate);

                jsonClient stub_method(@selector(promiseWithRequest:)).with(jsonClientRequest).and_return(jsonClientDeferred.promise);
                requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_return(@{ @"URLString": @"https://example.com/stubbed/endpoint",
                                            @"PayLoadStr": @"fake-json"});

                fetchTeamStatusSummaryPromise = [subject fetchTeamStatusSummary];
            });

            it(@"should ask the request dictionary for a request dictionary with the correct endpoint and parameter dictionary", ^{
                [(id<CedarDouble>)requestDictionaryBuilder sent_messages].count should equal(1);
                NSDictionary *expectedHTTPBodyDictionary = @{@"before":@{@"year": @2015, @"month": @8, @"day": @3, @"hour": @3, @"minute": @0, @"second": @24}};
                requestDictionaryBuilder should have_received(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).with(@"GetAllUserTimeSegmentTimeOffDetailsForDate", expectedHTTPBodyDictionary);
            });

            it(@"should send the request from the request builder to the client", ^{
                jsonClientRequest.HTTPMethod should equal(@"POST");
                jsonClientRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
                NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
                jsonClientRequest.HTTPBody should equal (expectedBody);
            });

            describe(@"when the request completes succesfully", ^{
                __block TeamStatusSummary *expectedTeamStatusSummary;
                __block NSDictionary *teamStatusSummaryDictionary;
                __block TeamStatusSummary *returnedTeamStatusSummary;

                beforeEach(^{
                    teamStatusSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"teamstatus_summary"];
                    expectedTeamStatusSummary = nice_fake_for([TeamStatusSummary class]);

                    teamStatusSummaryDeserializer stub_method(@selector(deserialize:)).and_return(expectedTeamStatusSummary);
                    [jsonClientDeferred resolveWithValue:teamStatusSummaryDictionary];
                });

                it(@"should deserialize the JSON into a TeamStatusSummary value object and resolve the promise with it", ^{
                    [(id<CedarDouble>)teamStatusSummaryDeserializer sent_messages].count should equal(1);
                    teamStatusSummaryDeserializer should have_received(@selector(deserialize:)).with(teamStatusSummaryDictionary);

                    fetchTeamStatusSummaryPromise.fulfilled should be_truthy;
                    returnedTeamStatusSummary = fetchTeamStatusSummaryPromise.value;
                    returnedTeamStatusSummary should equal(expectedTeamStatusSummary);
                });
            });

            describe(@"when the request fails", ^{
                __block NSError *expectedError;

                beforeEach(^{
                    expectedError = nice_fake_for([NSError class]);
                    [jsonClientDeferred rejectWithError:expectedError];
                });

                it(@"should reject the promise, forward on the error", ^{
                    fetchTeamStatusSummaryPromise.rejected should be_truthy;
                    fetchTeamStatusSummaryPromise.error should be_same_instance_as(expectedError);
                });
            });

        });
    });
});

SPEC_END
