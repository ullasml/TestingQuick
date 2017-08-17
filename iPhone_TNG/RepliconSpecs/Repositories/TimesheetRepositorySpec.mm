#import <Cedar/Cedar.h>
#import "TimesheetRepository.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "DateProvider.h"
#import "RequestDictionaryBuilder.h"
#import "TimesheetDeserializer.h"
#import "TimesheetForDateRange.h"
#import "RequestPromiseClient.h"
#import "TimesheetRequestBodyProvider.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "RepliconClient.h"
#import "TimesheetRequestProvider.h"
#import "SingleTimesheetDeserializer.h"
#import "InjectorKeys.h"
#import "IndexCursor.h"
#import "TimesheetInfoDeserializer.h"
#import "RepliconSpecHelper.h"
#import "ReporteePermissionsStorage.h"
#import "UserUriDetector.h"
#import "AstroAwareTimesheet.h"
#import "TimesheetInfo.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetRepositorySpec)

describe(@"TimesheetRepository", ^{
    __block TimesheetRepository *subject;
    __block id<RequestPromiseClient> client;
    __block KSDeferred *jsonClientDeferred;
    __block NSUserDefaults *userDefaults;
    __block NSURLRequest *request;
    __block RequestDictionaryBuilder *requestDictionaryBuilder;
    __block TimesheetDeserializer *timesheetDeserializer;
    __block SingleTimesheetDeserializer *singleTimesheetDeserializer;
    __block TimesheetRequestBodyProvider *timesheetRequestBodyProvider;
    __block TimesheetInfoDeserializer *timesheetInfoDeserializer;
    __block TimesheetRequestProvider *timesheetRequestProvider;
    __block ReporteePermissionsStorage *reporteePermissionsStorage;
    __block UserUriDetector *userUriDetector;
    __block id<BSBinder, BSInjector> injector;
    __block WidgetPlatformDetector *widgetPlatformDetector;
    __block WidgetTimesheetCapabilitiesDeserializer *capabilitiesDeserializer;

    beforeEach(^{
        injector = [InjectorProvider injector];
    });


    beforeEach(^{
        userUriDetector = nice_fake_for([UserUriDetector class]);
        client = nice_fake_for(@protocol(RequestPromiseClient));
        reporteePermissionsStorage = nice_fake_for([ReporteePermissionsStorage class]);
        singleTimesheetDeserializer = nice_fake_for([SingleTimesheetDeserializer class]);
        timesheetRequestBodyProvider = fake_for([TimesheetRequestBodyProvider class]);
        timesheetInfoDeserializer = fake_for([TimesheetInfoDeserializer class]);
        requestDictionaryBuilder = nice_fake_for([RequestDictionaryBuilder class]);
        timesheetDeserializer = nice_fake_for([TimesheetDeserializer class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        timesheetRequestProvider = nice_fake_for([TimesheetRequestProvider class]);
        widgetPlatformDetector = nice_fake_for([WidgetPlatformDetector class]);
        capabilitiesDeserializer = nice_fake_for([WidgetTimesheetCapabilitiesDeserializer class]);
    });

    beforeEach(^{
        jsonClientDeferred = [[KSDeferred alloc] init];

        client stub_method(@selector(promiseWithRequest:))
            .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
                request = receivedRequest;
                return jsonClientDeferred.promise;
            });


        userDefaults stub_method(@selector(objectForKey:))
            .with(@"serviceEndpointRootUrl")
            .and_return(@"https://na2.replicon.com/repliconmobile/services/");
        userDefaults stub_method(@selector(stringForKey:)).with(@"UserUri").and_return(@"some:user:uri");

            });

    beforeEach(^{
        [injector bind:[UserUriDetector class] toInstance:userUriDetector];
        [injector bind:[ReporteePermissionsStorage class] toInstance:reporteePermissionsStorage];
        [injector bind:[SingleTimesheetDeserializer class] toInstance:singleTimesheetDeserializer];
        [injector bind:[RequestDictionaryBuilder class] toInstance:requestDictionaryBuilder];
        [injector bind:[TimesheetDeserializer class] toInstance:timesheetDeserializer];
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        [injector bind:[TimesheetRequestBodyProvider class] toInstance:timesheetRequestBodyProvider];
        [injector bind:[TimesheetInfoDeserializer class] toInstance:timesheetInfoDeserializer];
        [injector bind:[TimesheetRequestProvider class] toInstance:timesheetRequestProvider];
        [injector bind:InjectorKeyWidgetPlatformDetector toInstance:widgetPlatformDetector];
        [injector bind:[WidgetTimesheetCapabilitiesDeserializer class] toInstance:capabilitiesDeserializer];
    });

    beforeEach(^{
        subject = [injector getInstance:[TimesheetRepository class]];
    });

    it(@"should correctly set the dependancies", ^{
        subject.timesheetInfoDeserializer should be_same_instance_as(timesheetInfoDeserializer);
        subject.requestDictionaryBuilder should be_same_instance_as(requestDictionaryBuilder);
        subject.timesheetRequestProvider should be_same_instance_as(timesheetRequestProvider);
        subject.timesheetDeserializer should be_same_instance_as(timesheetDeserializer);
        subject.userDefaults should be_same_instance_as(userDefaults);
        subject.client should be_same_instance_as(client);
        subject.timesheetRequestBodyProvider should be_same_instance_as(timesheetRequestBodyProvider);
        subject.singleTimesheetDeserializer should be_same_instance_as(singleTimesheetDeserializer);
        subject.reporteePermissionsStorage should be_same_instance_as(reporteePermissionsStorage);
        subject.userUriDetector should be_same_instance_as(userUriDetector);
    });

    describe(@"-fetchMostRecentTimesheet", ^{
        __block NSString *requestedEndpoint;
        __block NSDictionary *requestedHTTPBodyDictionary;
        __block KSPromise *promise;
        __block NSDictionary *timesheetRequestBodyDictionary;

        beforeEach(^{
            timesheetRequestBodyDictionary = @{};
            timesheetRequestBodyProvider stub_method(@selector(requestBodyDictionaryForMostRecentTimesheetWithUserURI:)).with(@"some:user:uri").and_return(timesheetRequestBodyDictionary);

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_do_block(^NSDictionary *(NSString *endpointName,NSDictionary *httpBodyDictionary)  {
                requestedEndpoint = endpointName;
                requestedHTTPBodyDictionary = httpBodyDictionary;

                return @{
                         @"URLString": @"https://example.com/stubbed/endpoint",
                         @"PayLoadStr": @"fake-json"
                         };
            });
            promise = [subject fetchMostRecentTimesheet];
        });

        it(@"should ask the request dictionary for the correct endpoint, passing in the correct dictionary", ^{
            requestedEndpoint should equal(@"GetFirstTimesheets");
            requestedHTTPBodyDictionary should be_same_instance_as(timesheetRequestBodyDictionary);
        });

        it(@"should send the request from the request builder to the client", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
            NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody should equal (expectedBody);
        });

        context(@"when the request succeeds", ^{
            __block TimesheetForDateRange *expectedTimesheet;
            beforeEach(^{
                NSDictionary *timesheetJSONDictionary = @{};
                expectedTimesheet = nice_fake_for([TimesheetForDateRange class]);
                timesheetDeserializer stub_method(@selector(deserialize:)).with(timesheetJSONDictionary).and_return(@[expectedTimesheet, nice_fake_for([TimesheetForDateRange class])]);

                [jsonClientDeferred resolveWithValue:timesheetJSONDictionary];
            });

            it(@"should pass the JSON Dictionary to the deserializer, and resolve the promise with the deserialized Timesheet", ^{
                __block TimesheetForDateRange *receivedTimesheet;
                [promise then:^id(TimesheetForDateRange *timesheet) {
                    receivedTimesheet = timesheet;
                    return nil;
                } error:^id(NSError *error) {
                    throw @"Promise should not have been rejected";
                }];

                receivedTimesheet should be_same_instance_as(expectedTimesheet);
            });
        });

    });

    describe(@"-fetchTimesheetWithOffset:", ^{
        __block NSString *requestedEndpoint;
        __block NSDictionary *requestedHTTPBodyDictionary;
        __block KSPromise *promise;
        __block NSDictionary *timesheetRequestBodyDictionary;

        beforeEach(^{
            timesheetRequestBodyDictionary = @{};
            timesheetRequestBodyProvider stub_method(@selector(requestBodyDictionaryForMostRecentTimesheetWithUserURI:)).with(@"some:user:uri").and_return(timesheetRequestBodyDictionary);

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_do_block(^NSDictionary *(NSString *endpointName,NSDictionary *httpBodyDictionary)  {
                requestedEndpoint = endpointName;
                requestedHTTPBodyDictionary = httpBodyDictionary;

                return @{
                         @"URLString": @"https://example.com/stubbed/endpoint",
                         @"PayLoadStr": @"fake-json"
                         };
            });
            promise = [subject fetchTimesheetWithOffset:1];
        });

        it(@"should ask the request dictionary for the correct endpoint, passing in the correct dictionary", ^{
            requestedEndpoint should equal(@"GetFirstTimesheets");
            requestedHTTPBodyDictionary should be_same_instance_as(timesheetRequestBodyDictionary);
        });

        it(@"should send the request from the request builder to the client", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
            NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody should equal (expectedBody);
        });

        context(@"when the request succeeds", ^{
            __block TimesheetForDateRange *expectedTimesheet;
            beforeEach(^{
                NSDictionary *timesheetJSONDictionary = @{};
                expectedTimesheet = nice_fake_for([TimesheetForDateRange class]);
                timesheetDeserializer stub_method(@selector(deserialize:)).with(timesheetJSONDictionary).and_return(@[nice_fake_for([TimesheetForDateRange class]), expectedTimesheet]);

                [jsonClientDeferred resolveWithValue:timesheetJSONDictionary];
            });

            it(@"should pass the JSON Dictionary to the deserializer, and resolve the promise with the deserialized Timesheet", ^{
                __block TimesheetForDateRange *receivedTimesheet;
                [promise then:^id(TimesheetForDateRange *timesheet) {
                    receivedTimesheet = timesheet;
                    return nil;
                } error:^id(NSError *error) {
                    throw @"Promise should not have been rejected";
                }];

                receivedTimesheet should be_same_instance_as(expectedTimesheet);
            });
        });
    });

    describe(@"-fetchTimesheetWithURI:", ^{
        
        context(@"Punch into Project User", ^{
            __block KSPromise *promise;
            __block NSURLRequest *expectedRequest;
            __block KSDeferred *deferred;
            
            beforeEach(^{
                deferred = [[KSDeferred alloc] init];
                expectedRequest = [[NSURLRequest alloc] init];
                timesheetRequestProvider stub_method(@selector(requestForTimesheetWithURI:))
                .with(@"a-timesheet-uri")
                .and_return(expectedRequest);
                client stub_method(@selector(promiseWithRequest:))
                .with(expectedRequest)
                .and_return(deferred.promise);
                promise = [subject fetchTimesheetWithURI:@"a-timesheet-uri"];
            });
            
            
            context(@"when the request suceeds", ^{
                __block AstroAwareTimesheet *astroAwareTimesheet;
                __block NSDictionary *timesheetDictionary;
                beforeEach(^{
                    astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                    astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                    timesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_load_punch_into_project_user"];
                    
                    userUriDetector stub_method(@selector(userUriFromTimesheetLoad:)).with(timesheetDictionary).and_return(@"a-user-uri-from-timesheet");
                    singleTimesheetDeserializer stub_method(@selector(deserialize:))
                    .with(timesheetDictionary)
                    .and_return(astroAwareTimesheet);
                    
                    [deferred resolveWithValue:timesheetDictionary];
                });
                
                it(@"should store the correct capabilities", ^{
                    reporteePermissionsStorage should have_received(@selector(persistCanAccessProject:canAccessClient:canAccessActivity:projectTaskSelectionRequired:activitySelectionRequired:isPunchIntoProjectUser:userUri:canAccessBreak:)).with(@YES,@YES,@NO,@NO, @NO,@YES,@"a-user-uri-from-timesheet",@YES);
                });
                
                it(@"should deserialize the response", ^{
                    promise.value should equal(astroAwareTimesheet);
                });
            });
            
            context(@"when the request fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                });
                
                it(@"should return an error", ^{
                    promise.rejected should be_truthy;
                    promise.error should be_same_instance_as(error);
                });
            });
            
        });
        
        context(@"Punch into Activity User", ^{
            __block KSPromise *promise;
            __block NSURLRequest *expectedRequest;
            __block KSDeferred *deferred;
            
            beforeEach(^{
                deferred = [[KSDeferred alloc] init];
                expectedRequest = [[NSURLRequest alloc] init];
                timesheetRequestProvider stub_method(@selector(requestForTimesheetWithURI:))
                .with(@"a-timesheet-uri")
                .and_return(expectedRequest);
                client stub_method(@selector(promiseWithRequest:))
                .with(expectedRequest)
                .and_return(deferred.promise);
                promise = [subject fetchTimesheetWithURI:@"a-timesheet-uri"];
            });
            
            
            context(@"when the request suceeds", ^{
                __block AstroAwareTimesheet *astroAwareTimesheet;
                __block NSDictionary *timesheetDictionary;
                beforeEach(^{
                    astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                    astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                    timesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_load_punch_into_activity_user"];
                    
                    userUriDetector stub_method(@selector(userUriFromTimesheetLoad:)).with(timesheetDictionary).and_return(@"a-user-uri-from-timesheet");
                    singleTimesheetDeserializer stub_method(@selector(deserialize:))
                    .with(timesheetDictionary)
                    .and_return(astroAwareTimesheet);
                    [deferred resolveWithValue:timesheetDictionary];
                });
                
                it(@"should store the correct capabilities", ^{
                    reporteePermissionsStorage should have_received(@selector(persistCanAccessProject:canAccessClient:canAccessActivity:projectTaskSelectionRequired:activitySelectionRequired:isPunchIntoProjectUser:userUri:canAccessBreak:)).with(@NO,@NO,@YES,@NO,@YES,@NO,@"a-user-uri-from-timesheet",@YES);
                });
                
                it(@"should deserialize the response", ^{
                    promise.value should equal(astroAwareTimesheet);
                });
            });
            
            context(@"when the request fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                });
                
                it(@"should return an error", ^{
                    promise.rejected should be_truthy;
                    promise.error should be_same_instance_as(error);
                });
            });
            
        });

    });

    describe(@"-fetchTimesheetInfoForDate", ^{
        __block NSString *requestedEndpoint;
        __block NSDictionary *requestedHTTPBodyDictionary;
        __block KSPromise *promise;
        __block NSDictionary *timesheetRequestBodyDictionary;
        __block NSDate *date;

        beforeEach(^{
            date = [NSDate dateWithTimeIntervalSince1970:0];
            timesheetRequestBodyDictionary = @{};
            timesheetRequestBodyProvider stub_method(@selector(requestBodyDictionaryTimesheetWithDate:)).with(date).and_return(timesheetRequestBodyDictionary);

            requestDictionaryBuilder stub_method(@selector(requestDictionaryWithEndpointName:httpBodyDictionary:)).and_do_block(^NSDictionary *(NSString *endpointName,NSDictionary *httpBodyDictionary)  {
                requestedEndpoint = endpointName;
                requestedHTTPBodyDictionary = httpBodyDictionary;

                return @{
                         @"URLString": @"https://example.com/stubbed/endpoint",
                         @"PayLoadStr": @"fake-json"
                         };
            });
            promise = [subject fetchTimesheetInfoForDate:date];
        });

        it(@"should ask the request dictionary for the correct endpoint, passing in the correct dictionary", ^{
            requestedEndpoint should equal(@"NewTimeLineSummary");
            requestedHTTPBodyDictionary should be_same_instance_as(timesheetRequestBodyDictionary);
        });

        it(@"should send the request from the request builder to the client", ^{
            request.HTTPMethod should equal(@"POST");
            request.URL.absoluteString should equal(@"https://example.com/stubbed/endpoint");
            NSData* expectedBody = [@"fake-json" dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody should equal (expectedBody);
        });

        context(@"when the request succeeds", ^{
            __block NSDictionary *timesheetJSONDictionary;
            __block TimesheetInfo *timesheetInfo;
            beforeEach(^{
                timesheetJSONDictionary = nice_fake_for([NSDictionary class]);
                timesheetInfo = nice_fake_for([TimesheetInfo class]);
                timesheetInfoDeserializer stub_method(@selector(deserializeTimesheetInfo:)).with(timesheetJSONDictionary).and_return(timesheetInfo);
                [jsonClientDeferred resolveWithValue:timesheetJSONDictionary];
            });

            it(@"should deserialize the timesheet json into Cursor Index", ^{
                timesheetInfoDeserializer should have_received(@selector(deserializeTimesheetInfo:)).with(timesheetJSONDictionary);
            });
            it(@"should resolve the promise with the number of returned timesheets", ^{
                promise.value should equal(timesheetInfo);
            });
        });

        context(@"when the request fails", ^{
            __block NSError *error;

            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [jsonClientDeferred rejectWithError:error];
            });

            it(@"should resolve the promise with the number of returned timesheets", ^{
                promise.rejected should be_truthy;
                promise.error should be_same_instance_as(error);
            });
        });
    });
    
    describe(@"-fetchTimesheetCapabilitiesWithURI:", ^{
        
        context(@"Punch into Project User", ^{
            __block KSPromise *promise;
            __block NSURLRequest *expectedRequest;
            __block KSDeferred *deferred;
            
            beforeEach(^{
                deferred = [[KSDeferred alloc] init];
                expectedRequest = [[NSURLRequest alloc] init];
                timesheetRequestProvider stub_method(@selector(requestForTimesheetPoliciesWithURI:))
                .with(@"a-timesheet-uri")
                .and_return(expectedRequest);
                client stub_method(@selector(promiseWithRequest:))
                .with(expectedRequest)
                .and_return(deferred.promise);
                
                promise = [subject fetchTimesheetCapabilitiesWithURI:@"a-timesheet-uri"];
            });
            
            context(@"when the request suceeds", ^{
                __block NSDictionary *timesheetDictionary;
                beforeEach(^{
                    timesheetDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_capabilities"];
                    
                    widgetPlatformDetector stub_method(@selector(isWidgetPlatformSupported))
                    .and_return(true);

                    [deferred resolveWithValue:timesheetDictionary];
                });
                
                it(@"should check for widgetplatform support", ^{
                    widgetPlatformDetector should have_received(@selector(setupWithUserConfiguredWidgetUris:)).with(@[@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry", @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"]);
                });
                
                it(@"should deserialize the response", ^{
                    promise.value should equal(@1);
                });
            });
            
            context(@"when the request fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                });
                
                it(@"should return an error", ^{
                    promise.rejected should be_truthy;
                    promise.error should be_same_instance_as(error);
                });
            });
            
        });
    });
});

SPEC_END
