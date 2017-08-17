#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "TeamTimesheetSummaryRepository.h"
#import "RequestDictionaryBuilder.h"
#import <KSDeferred/KSDeferred.h>
#import "JSONClient.h"
#import "RepliconSpecHelper.h"
#import "TeamTimesheetSummaryDeserializer.h"
#import "TeamTimesheetSummary.h"
#import "TimesheetPeriod.h"
#import "RepliconClient.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TeamTimesheetSummaryRepositorySpec)

describe(@"TeamTimesheetSummaryRepository", ^{
    __block TeamTimesheetSummaryRepository *subject;
    __block RequestDictionaryBuilder *requestDictionaryBuilder;
    __block RepliconClient *jsonClient;
    __block TeamTimesheetSummaryDeserializer *teamTimesheetSummaryDeserializer;

    __block KSDeferred *jsonClientDeferred;
    __block NSURLRequest *jsonClientRequest;

    beforeEach(^{
        jsonClientDeferred = [[KSDeferred alloc] init];
        jsonClient = nice_fake_for([RepliconClient class]);

        jsonClient stub_method(@selector(promiseWithRequest:)).and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            jsonClientRequest = receivedRequest;
            return jsonClientDeferred.promise;
        });

        requestDictionaryBuilder = nice_fake_for([RequestDictionaryBuilder class]);
        teamTimesheetSummaryDeserializer = fake_for([TeamTimesheetSummaryDeserializer class]);

        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

        subject = [[TeamTimesheetSummaryRepository alloc] initWithTeamTimesheetSummaryDeserializer:teamTimesheetSummaryDeserializer
                                                                          requestDictionaryBuilder:requestDictionaryBuilder
                                                                                        client:jsonClient
                                                                                          calendar:calendar];
    });

    describe(@"-fetchTeamTimesheetSummaryWithTimesheetPeriod:", ^{
        __block KSPromise *teamTimesheetSummaryPromise;

        beforeEach(^{
            jsonClient stub_method(@selector(promiseWithRequest:)).with(jsonClientRequest).and_return(jsonClientDeferred.promise);
            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_return(@{ @"URLString": @"https://example.com/stubbed/endpoint",
                                                                                                                                 @"PayLoadStr": @"fake-json"});
        });

        context(@"when called with a specific timesheet period", ^{
            beforeEach(^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
                NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:86400];

                TimesheetPeriod *timesheetPeriod = [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];
                teamTimesheetSummaryPromise = [subject fetchTeamTimesheetSummaryWithTimesheetPeriod:timesheetPeriod];
            });

            it(@"should ask the request dictionary for a request dictionary with the correct endpoint and parameter dictionary", ^{
                [(id<CedarDouble>)requestDictionaryBuilder sent_messages].count should equal(1);
                NSDictionary *expectedHTTPBodyDictionary = @{
                                                             @"range": @{
                                                                     @"startDate": @{
                                                                             @"year": @2001,
                                                                             @"month": @1,
                                                                             @"day": @1
                                                                             },
                                                                     @"endDate": @{
                                                                             @"year": @2001,
                                                                             @"month": @1,
                                                                             @"day": @2
                                                                             },
                                                                     @"relativeDateRangeUri": [NSNull null],
                                                                     @"relativeDateRangeAsOfDate": [NSNull null]
                                                                     }
                                                             };

                requestDictionaryBuilder should have_received(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:))
                .with(@"GetTeamTimesheetOverviewSummary", expectedHTTPBodyDictionary);
            });

            it(@"should send the request from the request builder to the client", ^{
                jsonClientRequest.HTTPMethod should equal(@"POST");
                jsonClientRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
                NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
                jsonClientRequest.HTTPBody should equal (expectedBody);
            });

            describe(@"when the request completes succesfully", ^{
                __block TeamTimesheetSummary *expectedTeamTimesheetSummary;
                __block NSDictionary *jsonResponseDictionary;
                __block TeamTimesheetSummary *actualTeamTimesheetSummary;

                beforeEach(^{
                    jsonResponseDictionary = [RepliconSpecHelper jsonWithFixture:@"team_timesheet_summary"];
                    expectedTeamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);

                    teamTimesheetSummaryDeserializer stub_method(@selector(deserialize:))
                    .with(jsonResponseDictionary)
                    .and_return(expectedTeamTimesheetSummary);
                    [jsonClientDeferred resolveWithValue:jsonResponseDictionary];
                });

                it(@"should deserialize the JSON into a TeamTimesheetSummary value object and resolve the promise with it", ^{
                    teamTimesheetSummaryPromise.fulfilled should be_truthy;
                    actualTeamTimesheetSummary = teamTimesheetSummaryPromise.value;
                    actualTeamTimesheetSummary should equal(expectedTeamTimesheetSummary);
                });
            });

            describe(@"when the request fails", ^{
                __block NSError *expectedError;

                beforeEach(^{
                    expectedError = nice_fake_for([NSError class]);
                    [jsonClientDeferred rejectWithError:expectedError];
                });

                it(@"should reject the promise, forward on the error", ^{
                    teamTimesheetSummaryPromise.rejected should be_truthy;
                    teamTimesheetSummaryPromise.error should be_same_instance_as(expectedError);
                });
            });
        });

        context(@"when called with nil", ^{
            beforeEach(^{
                teamTimesheetSummaryPromise = [subject fetchTeamTimesheetSummaryWithTimesheetPeriod:nil];
            });

            it(@"should ask the request dictionary for a request dictionary with the correct endpoint and parameter dictionary", ^{
                [(id<CedarDouble>)requestDictionaryBuilder sent_messages].count should equal(1);
                NSDictionary *expectedHTTPBodyDictionary = @{
                                                             @"range": @{
                                                                     @"startDate": [NSNull null],
                                                                     @"endDate": [NSNull null],
                                                                     @"relativeDateRangeUri": [NSNull null],
                                                                     @"relativeDateRangeAsOfDate": [NSNull null]
                                                                     }
                                                             };

                requestDictionaryBuilder should have_received(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:))
                .with(@"GetTeamTimesheetOverviewSummary", expectedHTTPBodyDictionary);
            });

            it(@"should send the request from the request builder to the client", ^{
                jsonClientRequest.HTTPMethod should equal(@"POST");
                jsonClientRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
                NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
                jsonClientRequest.HTTPBody should equal (expectedBody);
            });

            describe(@"when the request completes succesfully", ^{
                __block TeamTimesheetSummary *expectedTeamTimesheetSummary;
                __block NSDictionary *jsonResponseDictionary;
                __block TeamTimesheetSummary *actualTeamTimesheetSummary;

                beforeEach(^{
                    jsonResponseDictionary = [RepliconSpecHelper jsonWithFixture:@"team_timesheet_summary"];
                    expectedTeamTimesheetSummary = nice_fake_for([TeamTimesheetSummary class]);

                    teamTimesheetSummaryDeserializer stub_method(@selector(deserialize:))
                    .with(jsonResponseDictionary)
                    .and_return(expectedTeamTimesheetSummary);
                    [jsonClientDeferred resolveWithValue:jsonResponseDictionary];
                });

                it(@"should deserialize the JSON into a TeamTimesheetSummary value object and resolve the promise with it", ^{
                    teamTimesheetSummaryPromise.fulfilled should be_truthy;
                    actualTeamTimesheetSummary = teamTimesheetSummaryPromise.value;
                    actualTeamTimesheetSummary should equal(expectedTeamTimesheetSummary);
                });
            });
            
            describe(@"when the request fails", ^{
                __block NSError *expectedError;
                
                beforeEach(^{
                    expectedError = nice_fake_for([NSError class]);
                    [jsonClientDeferred rejectWithError:expectedError];
                });
                
                it(@"should reject the promise, forward on the error", ^{
                    teamTimesheetSummaryPromise.rejected should be_truthy;
                    teamTimesheetSummaryPromise.error should be_same_instance_as(expectedError);
                });
            });
        });
    });
});

SPEC_END
