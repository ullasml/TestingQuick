#import <Cedar/Cedar.h>
#import "TimeSummaryRepository.h"
#import "JSONClient.h"
#import "TimeSummaryDeserializer.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetRepository.h"
#import "TimesheetForDateRange.h"
#import "TimePeriodSummary.h"
#import "RepliconSpecHelper.h"
#import "DateProvider.h"
#import "WorkHoursDeferred.h"
#import "TimePeriodSummaryDeferred.h"
#import "AstroClientPermissionStorage.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimeSummaryRepositorySpec)

describe(@"TimeSummaryRepository", ^{
    __block TimeSummaryRepository *subject;
    __block JSONClient *jsonClient;
    __block DateProvider *dateProvider;
    __block NSUserDefaults *userDefaults;
    __block TimeSummaryDeserializer *timeSummaryDeserializer;
    __block TimesheetRepository *timesheetRepository;
    __block RequestDictionaryBuilder *requestDictionaryBuilder;
    __block NSURLRequest *jsonRequest;
    __block KSDeferred *jsonClientDeferred;
    __block NSDate *date;
    __block AstroClientPermissionStorage *astroClientPermissionStorage;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        timeSummaryDeserializer = nice_fake_for([TimeSummaryDeserializer class]);
        timesheetRepository = nice_fake_for([TimesheetRepository class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);

        jsonRequest = nil;

        jsonClient = nice_fake_for([JSONClient class]);
        jsonClientDeferred = [[KSDeferred alloc] init];

        jsonClient stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            jsonRequest = receivedRequest;
            return jsonClientDeferred.promise;
        });

        date = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider = nice_fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);

        requestDictionaryBuilder = nice_fake_for([RequestDictionaryBuilder class]);

        astroClientPermissionStorage = nice_fake_for([AstroClientPermissionStorage class]);

        subject = [[TimeSummaryRepository alloc] initWithRequestDictionaryBuilder:requestDictionaryBuilder astroClientPermissionStorage:astroClientPermissionStorage timeSummaryDeserializer:timeSummaryDeserializer timesheetRepository:timesheetRepository dateProvider:dateProvider userDefaults:userDefaults client:jsonClient dateFormatter:nil];
    });

    describe(@"timeSummaryForToday", ^{
        describe(@"fetching the time summary for today", ^{
            __block KSDeferred *timesheetDeferred;
            __block WorkHoursPromise *workHoursPromise;
            __block NSDictionary *timeSummaryResponseDict;

            beforeEach(^{
                timesheetDeferred = [[KSDeferred alloc] init];

                timesheetRepository stub_method(@selector(fetchMostRecentTimesheet)).and_return(timesheetDeferred.promise);
                userDefaults stub_method(@selector(objectForKey:)).with(@"UserUri").and_return(@"some-fake-user-uri");

                workHoursPromise = [subject timeSummaryForToday];
            });

            it(@"should ask the timesheet repository for the most recent timesheet", ^{
                timesheetRepository should have_received(@selector(fetchMostRecentTimesheet));
            });

            context(@"when the timesheet repository succesfully fetches a timesheet", ^{
                beforeEach(^{
                    TimesheetForDateRange *timesheet = [[TimesheetForDateRange alloc] initWithUri:@"some-fake-timesheet-uri" period:nil approvalStatus:nil];

                    requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_return(@{ @"URLString": @"https://example.com/stubbed/endpoint",
                                                                                                                                         @"PayLoadStr": @"fake-json"
                                                                                                                                         });

                    [timesheetDeferred resolveWithValue:timesheet];
                });

                it(@"should ask the request dictionary builder for a request to the correct endpoint, passing in the correct data", ^{

                    requestDictionaryBuilder should have_received(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).with(@"GetTimesheetSummary", @{@"timesheetUri": @"some-fake-timesheet-uri"});
                });

                it(@"should use the values from the request dictionary builder to make the request for json", ^{
                    jsonRequest should_not be_nil;
                    jsonRequest.HTTPMethod should equal(@"POST");
                    jsonRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
                    NSData *expectedBodyData = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
                    jsonRequest.HTTPBody should equal(expectedBodyData);
                });

                context(@"when the JSON client succesfully returns data", ^{


                    NSDateComponents *regularDateComponents = [[NSDateComponents alloc] init];
                    regularDateComponents.hour = 0;
                    regularDateComponents.minute = 0;
                    regularDateComponents.second = 0;
                    
                    TimePeriodSummary *expectedTimeSummary = [[TimePeriodSummary alloc]
                                                                                 initWithRegularTimeComponents:regularDateComponents
                                                                                           breakTimeComponents:nil
                                                                                     timesheetPermittedActions:nil
                                                                                            overtimeComponents:nil
                                                                                          payDetailsPermission:NO
                                                                                              dayTimeSummaries:nil
                                                                                                      totalPay:nil
                                                                                                    totalHours:nil
                                                                                              actualsByPayCode:nil
                                                                                          actualsByPayDuration:nil
                                                                                           payAmountPermission:NO
                                                                                         scriptCalculationDate:nil
                                                                                             timeOffComponents:nil
                                                                                                isScheduledDay:YES];
                    
                    beforeEach(^{
                        timeSummaryResponseDict = [RepliconSpecHelper jsonWithFixture:@"time_summary"];

                        timeSummaryDeserializer stub_method(@selector(deserialize:forDate:)).and_return(expectedTimeSummary);

                        [jsonClientDeferred resolveWithValue:timeSummaryResponseDict];

                    });
                    
                    it(@"should store the correct capabilities", ^{
                        astroClientPermissionStorage should have_received(@selector(persistUserHasClientPermission:)).with(@YES);
                    });


                    it(@"should build a time summary object and resolve the time summary promise", ^{
                        timeSummaryDeserializer should have_received(@selector(deserialize:forDate:)).with(timeSummaryResponseDict, date);

                        workHoursPromise.value should equal(expectedTimeSummary);
                    });
                });

                context(@"when the JSON client fails to return data", ^{

                    __block NSError *jsonClientError;
                    beforeEach(^{
                        jsonClientError = nice_fake_for([NSError class]);
                        [jsonClientDeferred rejectWithError:jsonClientError];
                    });

                    it(@"should reject the time summary promise, forwarding the error", ^{
                        workHoursPromise.rejected should be_truthy;
                        workHoursPromise.error should be_same_instance_as(jsonClientError);
                    });
                });
            });

            context(@"when the timesheet repository fails to return a timesheet", ^{
                __block NSError *timesheetRepositoryError;

                beforeEach(^{
                    timesheetRepositoryError = nice_fake_for([NSError class]);
                    [timesheetDeferred rejectWithError:timesheetRepositoryError];
                });

                it(@"should reject the time summary promise, forward the timesheet repository error", ^{
                    workHoursPromise.rejected should be_truthy;
                    workHoursPromise.error should be_same_instance_as(timesheetRepositoryError);
                });
            });
        });
    });

    describe(@"timeSummaryForTimesheet:", ^{
        __block TimesheetForDateRange *timesheet;
        __block TimePeriodSummaryPromise *promise;

        beforeEach(^{
            timesheet = fake_for([TimesheetForDateRange class]);
            timesheet stub_method(@selector(uri)).and_return(@"My Special Timesheet URI");

            NSDictionary *expectedBodyDictionary = @{@"timesheetUri": @"My Special Timesheet URI"};

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:))
                .with(@"GetTimesheetSummary", expectedBodyDictionary)
                .and_return(@{@"URLString": @"https://example.com/stubbed/endpoint", @"PayLoadStr": @"fake-json"});

            promise = [subject timeSummaryForTimesheet:timesheet];
        });

        it(@"should make a request", ^{
            jsonRequest.HTTPMethod should equal(@"POST");
            jsonRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");

            NSData *expectedBodyData = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
            jsonRequest.HTTPBody should equal(expectedBodyData);
        });

        it(@"should resolve the promise with a TimePeriodSummary the JSON request succeeds", ^{
            NSDictionary *jsonResponse = @{@"My Special": @"Timesheet Summary"};

            TimePeriodSummary *timeSummary = fake_for([TimePeriodSummary class]);

            timeSummaryDeserializer stub_method(@selector(deserializeForTimesheet:))
                .with(jsonResponse)
                .and_return(timeSummary);

            [jsonClientDeferred resolveWithValue:jsonResponse];

            promise.value should be_same_instance_as(timeSummary);
        });

        it(@"should reject the promise when the JSON request fails", ^{
            NSError *error = fake_for([NSError class]);

            [jsonClientDeferred rejectWithError:error];

            promise.error should be_same_instance_as(error);
        });
    });

    describe(@"submitTimeSheetData:", ^{
        __block NSDictionary *postMap;
        __block KSDeferred *deferred;

        beforeEach(^{
            postMap = @{@"timesheetUri":@"My Special Timesheet URI",
                        @"unitOfWorkId":@"fakeunitofworkid1",
                        @"comments" :[NSNull null],
                        @"changeReason":[NSNull null],
                        @"attestationStatus":[NSNull null]};
            
            deferred = [[KSDeferred alloc] init];
            
            jsonClient stub_method(@selector(promiseWithRequest:)).again()
            .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                jsonRequest = receivedRequest;
                return deferred.promise;
            });

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:))
            .with(@"SubmitTimeSheet", postMap)
            .and_return(@{@"URLString": @"https://example.com/stubbed/endpoint", @"PayLoadStr": @"fake-json"});

            deferred.promise = [subject submitTimeSheetData:postMap];
        });

        it(@"should make a request", ^{
            jsonRequest.HTTPMethod should equal(@"POST");
            jsonRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");

            NSData *expectedBodyData = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
            jsonRequest.HTTPBody should equal(expectedBodyData);
        });

        it(@"should resolve the promise with a TimesheetSummary when the JSON request succeeds", ^{
            NSDictionary *jsonResponse = @{@"My Special": @"Timesheet Summary"};

            TimePeriodSummary *timeSummary = fake_for([TimePeriodSummary class]);

            timeSummaryDeserializer stub_method(@selector(deserializeForTimesheet:))
            .with(jsonResponse)
            .and_return(timeSummary);

            [deferred resolveWithValue:timeSummary];

            deferred.promise.value should be_same_instance_as(timeSummary);
        });

        it(@"should reject the promise when the JSON request fails", ^{
            NSError *error = fake_for([NSError class]);

            [deferred rejectWithError:error];
            
            deferred.promise.error should be_same_instance_as(error);
        });
    });

    describe(@"reopenTimeSheetData:", ^{
        __block NSDictionary *postMap;
        __block KSDeferred *deferred;
        beforeEach(^{
            postMap = @{@"timesheetUri":@"My Special Timesheet URI",
                        @"unitOfWorkId":[Util getRandomGUID],
                        @"comments" :@"comments",
                        @"changeReason":[NSNull null],
                        @"attestationStatus":[NSNull null]};

            deferred = [[KSDeferred alloc] init];
            
            jsonClient stub_method(@selector(promiseWithRequest:)).again()
            .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                jsonRequest = receivedRequest;
                return deferred.promise;
            });

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:))
            .with(@"ReopenTimeSheet", postMap)
            .and_return(@{@"URLString": @"https://example.com/stubbed/endpoint", @"PayLoadStr": @"fake-json"});

            deferred.promise = [subject reopenTimeSheet:postMap];
        });

        it(@"should make a request", ^{
            jsonRequest.HTTPMethod should equal(@"POST");
            jsonRequest.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");

            NSData *expectedBodyData = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
            jsonRequest.HTTPBody should equal(expectedBodyData);
        });

        it(@"should resolve the promise with a TimesheetSummary when the JSON request succeeds", ^{
            NSDictionary *jsonResponse = @{@"My Special": @"Timesheet Summary"};

            TimePeriodSummary *timeSummary = fake_for([TimePeriodSummary class]);

            timeSummaryDeserializer stub_method(@selector(deserializeForTimesheet:))
            .with(jsonResponse)
            .and_return(timeSummary);

            [deferred resolveWithValue:timeSummary];
            
            deferred.promise.value should be_same_instance_as(timeSummary);
        });

        it(@"should reject the promise when the JSON request fails", ^{
            NSError *error = fake_for([NSError class]);

            [deferred rejectWithError:error];
            
            deferred.promise.error should be_same_instance_as(error);
        });
    });


});

SPEC_END
