#import <Cedar/Cedar.h>
#import "ErrorDetailsRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "ErrorDetailsRequestProvider.h"
#import "ErrorDetailsStorage.h"
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetails.h"
#import "JsonClient.h"
#import "RepliconSpecHelper.h"
#import "TimesheetService.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorDetailsRepositorySpec)


describe(@"ErrorDetailsRepository", ^{
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *errorDetailsDeferred;
    __block ErrorDetailsRepository *subject;
    __block id <RequestPromiseClient> jsonClient;
    __block ErrorDetailsRequestProvider *errorDetailsRequestProvider;
    __block ErrorDetailsStorage *errorDetailsStorage;
    __block ErrorDetailsDeserializer *errorDetailsDeserializer;
    __block id<UserSession> userSession;
     __block TimesheetService *timesheetService;

    beforeEach(^{


        errorDetailsDeserializer = nice_fake_for([ErrorDetailsDeserializer class]);

        errorDetailsStorage = nice_fake_for([ErrorDetailsStorage class]);

        errorDetailsRequestProvider = nice_fake_for([ErrorDetailsRequestProvider class]);


        jsonClient = nice_fake_for([JSONClient class]);

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

        errorDetailsDeferred = [[KSDeferred alloc]init];
        request = nice_fake_for([NSURLRequest class]);

        jsonClient stub_method(@selector(promiseWithRequest:)).and_return(errorDetailsDeferred.promise);
        errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).and_return(@[@1, @2, @3]);

        timesheetService = nice_fake_for([TimesheetService class]);

        subject = [[ErrorDetailsRepository alloc] initWithErrorDetailsDeserializer:errorDetailsDeserializer requestProvider:errorDetailsRequestProvider userSession:userSession client:jsonClient storage:errorDetailsStorage timesheetService:timesheetService];


        
    });

    describe(@"fetchFreshValidationErrors:", ^{
        beforeEach(^{
            errorDetailsRequestProvider stub_method(@selector(requestForValidationErrorsWithURI:)).with(@[@"user-uri-1",@"user-uri-2"]).and_return(request);
            promise = [subject fetchFreshValidationErrors:@[@"user-uri-1",@"user-uri-2"]];
        });
        it(@"should send the correctly configured request to server", ^{
            errorDetailsRequestProvider should have_received(@selector(requestForValidationErrorsWithURI:)).with(@[@"user-uri-1",@"user-uri-2"]);
            jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                responseDictionary = nice_fake_for([NSDictionary class]);
                errorDetailsDeserializer stub_method(@selector(deserializeValidationServiceResponse:)).and_return(@[@1, @2, @3]);
                [errorDetailsDeferred resolveWithValue:responseDictionary];
            });

            it(@"should delete all the cached data", ^{
                errorDetailsStorage should have_received(@selector(deleteAllErrorDetails));
            });

            it(@"should send the response dictionary to the client deserializer", ^{
                errorDetailsDeserializer should have_received(@selector(deserializeValidationServiceResponse:)).with(responseDictionary);
            });
            it(@"should persist the client types in the client storage cache", ^{
                errorDetailsStorage should have_received(@selector(storeErrorDetails:)).with(@[@1, @2, @3]);
            });

            it(@"should resolve the promise with the deserialized objects", ^{
                promise.value should equal(@[@1, @2, @3]);
            });
        });


        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [errorDetailsDeferred rejectWithError:error];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });

    describe(@"fetchTimeSheetUpdateData", ^{
        beforeEach(^{
            errorDetailsRequestProvider stub_method(@selector(requestForTimeSheetUpdateDataForUserUri:)).with(@"user:uri").and_return(request);
            promise = [subject fetchTimeSheetUpdateData];
        });
        it(@"should send the correctly configured request to server", ^{
            errorDetailsRequestProvider should have_received(@selector(requestForTimeSheetUpdateDataForUserUri:)).with(@"user:uri");
            jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).again().and_return(@[@"uri-5", @"uri-6"]);
                errorDetailsDeserializer stub_method(@selector(deserializeTimeSheetUpdateData:)).and_return(@[@"uri-1", @"uri-2"]);
                 responseDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_delta"];
                [errorDetailsDeferred resolveWithValue:responseDictionary];
            });

            it(@"should resolve the promise with the json", ^{
                promise.value should equal(@[@"uri-5", @"uri-6"]);
            });

            it(@"should correctly delete the error details for timesheets", ^{
                errorDetailsStorage should have_received(@selector(deleteErrorDetails:)).with(@"uri-1");
                errorDetailsStorage should have_received(@selector(deleteErrorDetails:)).with(@"uri-2");
                
            });

            it(@"should correctly get all stored error details ", ^{
                errorDetailsStorage should have_received(@selector(getAllErrorDetailsForModuleName:)).with(@"Timesheets_Module");

            });

            it(@"should correctly call timesheet service legacy handle method", ^{
                timesheetService should have_received(@selector(handleTimesheetsUpdateFetchData:)).with(@{@"response": responseDictionary});

            });
        });


        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [errorDetailsDeferred rejectWithError:error];
            });

            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });


});

SPEC_END
