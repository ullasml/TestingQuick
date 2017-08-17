#import <Cedar/Cedar.h>
#import "SupervisorDashboardSummaryRepository.h"
#import "RequestDictionaryBuilder.h"
#import <KSDeferred/KSDeferred.h>
#import "JSONClient.h"
#import "RepliconSpecHelper.h"
#import "SupervisorDashboardSummaryDeserializer.h"
#import "SupervisorDashboardSummary.h"
#import "DateProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "RepliconClient.h"
#import "EmployeeClockInTrendSummary.h"
#import "EmployeeClockInTrendSummaryDeserializer.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorDashboardSummaryRepositorySpec)

describe(@"SupervisorDashboardSummaryRepository", ^{
    __block SupervisorDashboardSummaryRepository *subject;
    __block RequestDictionaryBuilder *requestDictionaryBuilder;
    __block KSDeferred *jsonClientDeferred;
    __block JSONClient *jsonClient;
    __block NSURLRequest *jsonClientRequest;
    __block SupervisorDashboardSummaryDeserializer *dashboardSummaryDeserializer;
    __block EmployeeClockInTrendSummaryDeserializer *employeeClockInTrendSummaryDeserializer;
    __block DateProvider *dateProvider;
    __block NSDate *providedDate;

    beforeEach(^{
        jsonClientDeferred = [[KSDeferred alloc] init];

        jsonClient = nice_fake_for([JSONClient class]);

        jsonClientRequest = nil;

        jsonClient stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            jsonClientRequest = receivedRequest;
            return jsonClientDeferred.promise;
        });

        requestDictionaryBuilder = fake_for([RequestDictionaryBuilder class]);
        dashboardSummaryDeserializer = nice_fake_for([SupervisorDashboardSummaryDeserializer class]);
        employeeClockInTrendSummaryDeserializer = nice_fake_for([EmployeeClockInTrendSummaryDeserializer class]);

        NSCalendar *calendar;
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

        dateProvider = nice_fake_for([DateProvider class]);
        NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
        [dateComponents setHour:23];
        [dateComponents setMinute:0];
        [dateComponents setSecond:24];
        [dateComponents setYear:2015];
        [dateComponents setMonth:8];
        [dateComponents setDay:2];
        providedDate = [calendar dateFromComponents:dateComponents];
        dateProvider stub_method(@selector(date)).and_return(providedDate);
    });

    __block id<BSBinder, BSInjector> injector;
    beforeEach(^{
        injector = [InjectorProvider injector];

        [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonClient];
        [injector bind:[RequestDictionaryBuilder class] toInstance:requestDictionaryBuilder];
        [injector bind:[SupervisorDashboardSummaryDeserializer class] toInstance:dashboardSummaryDeserializer];
        [injector bind:[EmployeeClockInTrendSummaryDeserializer class] toInstance:employeeClockInTrendSummaryDeserializer];
        [injector bind:[DateProvider class] toInstance:dateProvider];

        subject = [injector getInstance:[SupervisorDashboardSummaryRepository class]];
    });

    describe(@"-fetchMostRecentDashboardSummary", ^{
        describe(@"fetching the most recent dashboard summary", ^{
            __block KSPromise *mostRecentSummaryPromise;

            beforeEach(^{
                requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_return(@{ @"URLString": @"https://example.com/stubbed/endpoint",
                                                                                                                                     @"PayLoadStr": @"fake-json"
                                                                                                                                     });
                mostRecentSummaryPromise = [subject fetchMostRecentDashboardSummary];
            });

            it(@"should ask the request dictionary for a request dictionary with the correct endpoint and parameter dictionary", ^{
                [(id<CedarDouble>)requestDictionaryBuilder sent_messages].count should equal(1);
                NSDictionary *expectedHTTPBodyDictionary = @{@"before":@{@"year": @2015, @"month": @8, @"day": @3, @"hour": @3, @"minute": @0, @"second": @24}};
                requestDictionaryBuilder should have_received(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).with(@"GetTeamTimePunchOverviewSummary", expectedHTTPBodyDictionary);
            });

            it(@"should send the request from the request builder to the client", ^{
                jsonClientRequest.HTTPMethod should equal(@"POST");
                jsonClientRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
                NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
                jsonClientRequest.HTTPBody should equal (expectedBody);
            });

            describe(@"when the request completes succesfully", ^{
                __block NSDictionary *dashboardSummaryDictionary;
                __block SupervisorDashboardSummary *expectedDashboardSummary;

                beforeEach(^{
                    dashboardSummaryDictionary = [RepliconSpecHelper jsonWithFixture:@"team_time_punch_overview_summary_response"];

                    expectedDashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);
                    dashboardSummaryDeserializer stub_method(@selector(deserialize:)).and_return(expectedDashboardSummary);
                    [jsonClientDeferred resolveWithValue:dashboardSummaryDictionary];
                });

                it(@"should deserialize the JSON into a SupervisorDashboardSummary value object and resolve the promise with it", ^{
                    [(id<CedarDouble>)dashboardSummaryDeserializer sent_messages].count should equal(1);
                    dashboardSummaryDeserializer should have_received(@selector(deserialize:)).with(dashboardSummaryDictionary);

                    mostRecentSummaryPromise.fulfilled should be_truthy;
                    mostRecentSummaryPromise.value should be_same_instance_as(expectedDashboardSummary);
                });
            });

            describe(@"when the request fails", ^{
                __block NSError *expectedError;

                beforeEach(^{
                    expectedError = nice_fake_for([NSError class]);
                    [jsonClientDeferred rejectWithError:expectedError];
                });

                it(@"should reject the promise, forward on the error", ^{
                    mostRecentSummaryPromise.rejected should be_truthy;
                    mostRecentSummaryPromise.error should be_same_instance_as(expectedError);
                });
            });
        });
    });
});

SPEC_END
