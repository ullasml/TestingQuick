#import <Cedar/Cedar.h>
#import "EmployeeClockInTrendSummaryRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "JSONClient.h"
#import "RequestDictionaryBuilder.h"
#import "EmployeeClockInTrendSummaryDeserializer.h"
#import "DateProvider.h"
#import "InjectorProvider.h"
#import "RepliconClient.h"
#import <Blindside/Blindside.h>
#import "EmployeeClockInTrendSummary.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(EmployeeClockInTrendSummaryRepositorySpec)

describe(@"EmployeeClockInTrendSummaryRepository", ^{
    __block EmployeeClockInTrendSummaryRepository *subject;
    __block RequestDictionaryBuilder *requestDictionaryBuilder;
    __block KSDeferred *jsonClientDeferred;
    __block JSONClient *jsonClient;
    __block NSURLRequest *jsonClientRequest;
    __block EmployeeClockInTrendSummaryDeserializer *employeeClockInTrendSummaryDeserializer;
    __block DateProvider *dateProvider;
    __block NSDate *providedDate;
    __block NSCalendar *calendar;

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
        employeeClockInTrendSummaryDeserializer = nice_fake_for([EmployeeClockInTrendSummaryDeserializer class]);


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
        [injector bind:[EmployeeClockInTrendSummaryDeserializer class] toInstance:employeeClockInTrendSummaryDeserializer];
        [injector bind:[DateProvider class] toInstance:dateProvider];

        subject = [injector getInstance:[EmployeeClockInTrendSummaryRepository class]];
    });


    describe(@"-fetchEmployeeClockInTrendSummary", ^{
        beforeEach(^{
            NSDictionary *requestDictionary = @{
                                                @"URLString": @"https://example.com/stubbed/endpoint",
                                                @"PayLoadStr": @"fake-data"
                                                };

            NSDictionary *expectedBody = @{
                                           @"samplingInterval": @{
                                                   @"hours": @"0",
                                                   @"minutes": @"12",
                                                   @"seconds": @"0"
                                                   },
                                           @"workInterval": @{
                                                   @"hours": @"0",
                                                   @"minutes": @"8",
                                                   @"seconds": @"0"
                                                   },
                                           @"before":@{
                                                   @"day":@3,
                                                   @"month":@8,
                                                   @"year":@2015,
                                                   @"hour": @3,
                                                   @"minute": @0,
                                                   @"second": @24
                                                   }
                                           };

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:))
            .with(@"GetTeamChartSummary", expectedBody).and_return(requestDictionary);
        });

        __block KSPromise *fetchTrendChartPromise;
        beforeEach(^{
            fetchTrendChartPromise = [subject fetchEmployeeClockInTrendSummary];
        });

        it(@"should ask the requestDictionaryBuilder for the team chart summary", ^{
            requestDictionaryBuilder should have_received(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:));
        });

        it(@"should make the correct request", ^{
            NSData* expectedBody = [@"fake-data" dataUsingEncoding:NSUTF8StringEncoding];

            jsonClientRequest.HTTPMethod should equal(@"POST");
            jsonClientRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
            jsonClientRequest.HTTPBody should equal (expectedBody);
        });

        describe(@"when the request succeeds", ^{
            __block EmployeeClockInTrendSummary *employeeClockInTrendSummary;
            __block NSDictionary *trendSummaryDictionary;

            beforeEach(^{
                trendSummaryDictionary = @{};
                employeeClockInTrendSummary = fake_for([EmployeeClockInTrendSummary class]);
                employeeClockInTrendSummaryDeserializer stub_method(@selector(deserialize:samplingIntervalSeconds:)).with(trendSummaryDictionary, 12 * 60).and_return(employeeClockInTrendSummary);

                [jsonClientDeferred resolveWithValue:trendSummaryDictionary];
            });

            it(@"should deserialize the response and sampling interval into a EmployeeClockInTrendSummary", ^{
                employeeClockInTrendSummaryDeserializer should have_received(@selector(deserialize:samplingIntervalSeconds:)).with(trendSummaryDictionary, 12 * 60);

                fetchTrendChartPromise.fulfilled should be_truthy;
                fetchTrendChartPromise.value should be_same_instance_as(employeeClockInTrendSummary);
            });
        });

        describe(@"when the request fails", ^{
            __block NSError *expectedError;

            beforeEach(^{
                expectedError = nice_fake_for([NSError class]);
                [jsonClientDeferred rejectWithError:expectedError];
            });

            it(@"should reject the promise, forward on the error", ^{
                fetchTrendChartPromise.rejected should be_truthy;
                fetchTrendChartPromise.error should be_same_instance_as(expectedError);
            });
        });
    });
});

SPEC_END
