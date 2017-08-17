 #import <Cedar/Cedar.h>
#import "InjectorProvider.h"
#import "UserSession.h"
#import <Blindside/BlindSide.h>
#import <KSDeferred/KSDeferred.h>
#import "RepliconSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeOffRepositorySpec)

describe(@"TimeOffRepository", ^{
    __block TimeOffRepository *subject;
    __block id <UserSession> userSession;
    __block TimeOffDeserializer *timeOffDeserializer;
    __block id<BSInjector, BSBinder> injector;
    __block KSDeferred *timeOffDefered;
    __block id<RequestPromiseClient>requestPromiseClient;
    __block TimeOffRequestProvider *requestProvider;
    __block TimeoffModel *timeOffModel;
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        timeOffDeserializer = [[TimeOffDeserializer alloc] initWithTimeoffModel:[[TimeoffModel alloc] init] loginModel:[[LoginModel alloc] init] approvalsModel:[[ApprovalsModel alloc] init]];
        requestProvider = nice_fake_for([TimeOffRequestProvider class]);
        timeOffModel = nice_fake_for([TimeoffModel class]);
        requestPromiseClient = nice_fake_for(@protocol(RequestPromiseClient));
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"My-current-user-uri");
        
        [injector bind:InjectorKeyRepliconClientForeground toInstance:requestPromiseClient];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:InjectorKeyTimeOffDeserializer toInstance:timeOffDeserializer];
        [injector bind:InjectorKeyTimeOffRequestProvider toInstance:requestProvider];
        [injector bind:[TimeoffModel class] toInstance:timeOffModel];
        
        subject = [injector getInstance:InjectorKeyTimeOffRepository];
    });
    
    describe(@"", ^{
        __block id json;
        beforeEach(^{
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1492041600];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1492128000];
            
            requestProvider stub_method(@selector(setUpWithUserUriWithUserUri:)).with(@"My-current-user-uri");
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(timeOffDefered.promise);
            
            json = [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Booking_Params"];
            [subject getUserEntriesAndDurationOptionsWithTimeOffTypeUri:@"timeOff-type-uri" startDate:startDate endDate:endDate];
        });
        
        it(@"should call requestForBookingParamsWithTimeOffTypeUri:startDate:endDate:", ^{
            requestProvider should have_received(@selector(requestForBookingParamsWithTimeOffTypeUri:startDate:endDate:));
        });
    });
    
    describe(@"Get User Entries And DurationOptions", ^{
        __block KSPromise *promise;
        __block KSDeferred *clientsDeferred;
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1492041600];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1492387200];
            promise = [subject getUserEntriesAndDurationOptionsWithTimeOffTypeUri:@"urn:replicon-tenant:fb76e6f6e48a45f4bbd4145c6e36eb29:time-off-type:12" startDate:startDate endDate:endDate];
        });
        
        context(@"when the request is successful", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Booking_Params"];
                [clientsDeferred resolveWithValue:jsonDictionary];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                NSDictionary *result = promise.value;
                result.count should equal(2);
            });
        });
        
        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"Error Domain" code:0 userInfo:nil];
                [clientsDeferred rejectWithError:error];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });
    
    
    describe(@"Submit TimeOff", ^{
        __block KSPromise *promise;
        __block KSDeferred *clientsDeferred;
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            TimeOff *timeOff = nice_fake_for([TimeOff class]);
            promise = [subject submitTimeOffWithTimeOffObject:timeOff isNewBooking:true];
        });
        
        context(@"when the request is successful", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Submit"];
                [clientsDeferred resolveWithValue:jsonDictionary];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                NSDictionary *result = promise.value;
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Submit"][@"d"];
                result should equal(jsonDictionary);
            });
        });
        
        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"Error Domain" code:0 userInfo:nil];
                [clientsDeferred rejectWithError:error];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });
    
    describe(@"Balance", ^{
        __block KSPromise *promise;
        __block KSDeferred *clientsDeferred;
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            TimeOff *timeOff = nice_fake_for([TimeOff class]);
            promise = [subject getBalanceForTimeOffWithTimeOffObject:timeOff];
        });
        
        context(@"when the request is successful", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Booking_Balance"];
                [clientsDeferred resolveWithValue:jsonDictionary];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                TimeOffBalance *balanceActual = promise.value;
                TimeOffBalance *balanceExpected = [[TimeOffBalance alloc] initWithTimeRemaining:@"-1.23" timeTaken:@"1.23"];
                balanceActual.description should equal(balanceExpected.description);
            });
        });
        
        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"Error Domain" code:0 userInfo:nil];
                [clientsDeferred rejectWithError:error];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });
    
    describe(@"Delete TimeOff", ^{
        __block KSPromise *promise;
        __block KSDeferred *clientsDeferred;
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            TimeOff *timeOff = [[TimeOff alloc] initWithStartDayEntry:nil endDayEntry:nil middleDayEntries:@[] allDurationOptions:@[] allUDFs:@[] approvalStatus:nil balanceInfo:nil type:nil details:[[TimeOffDetails alloc] initWithUri:@"User_URI" comments:@"" resubmitComments:@"" edit:YES delete:YES]];
            promise = [subject deleteTimeOffWithTimeOffObject:timeOff];
        });
        
        context(@"when the request is successful", ^{
            beforeEach(^{
                NSDictionary *response= @{@"d":[NSNull null]};
                [clientsDeferred resolveWithValue:response];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                NSDictionary *result = promise.value;
                NSDictionary *dictionary= @{@"d":[NSNull null]};
                result should equal(dictionary);
            });
        });
        
        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = [NSError errorWithDomain:@"Error Domain" code:0 userInfo:nil];
                [clientsDeferred rejectWithError:error];
            });
            
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });


});

SPEC_END
