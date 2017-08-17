#import <Cedar/Cedar.h>
#import "TimesheetInfoAndPermissionsRepository.h"
#import "InjectorKeys.h"
#import "InjectorProvider.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetInfoAndExtrasDeserializer.h"
#import "RequestDictionaryBuilder.h"
#import "AstroClientPermissionStorage.h"
#import "TimesheetAdditionalInfo.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetInfoAndPermissionsRepositorySpec)

describe(@"TimesheetInfoAndPermissionsRepository", ^{
    __block TimesheetInfoAndPermissionsRepository *subject;
    __block TimesheetInfoAndExtrasDeserializer *timesheetInfoAndExtrasDeserializer;
    __block AstroClientPermissionStorage *astroClientPermissionStorage;
    __block id<RequestPromiseClient> client;
    __block NSUserDefaults *userDefaults;
    __block id<BSBinder, BSInjector> injector;
    __block NSURLRequest *request;
    __block KSDeferred *deferred;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        deferred = [[KSDeferred alloc]init];
        
        client = nice_fake_for(@protocol(RequestPromiseClient));
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        timesheetInfoAndExtrasDeserializer = nice_fake_for([TimesheetInfoAndExtrasDeserializer class]);
        [injector bind:[TimesheetInfoAndExtrasDeserializer class] toInstance:timesheetInfoAndExtrasDeserializer];
        
        astroClientPermissionStorage = nice_fake_for([AstroClientPermissionStorage class]);
        [injector bind:[AstroClientPermissionStorage class] toInstance:astroClientPermissionStorage];
        
        userDefaults stub_method(@selector(objectForKey:))
        .with(@"serviceEndpointRootUrl")
        .and_return(@"https://na2.replicon.com/repliconmobile/services/");
        
        client stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            request = receivedRequest;
            return deferred.promise;
        });
        
    });
    
    context(@"when there are no punch logs", ^{
        __block KSPromise *recievedPromise;
        beforeEach(^{
            subject = [injector getInstance:[TimesheetInfoAndPermissionsRepository class]];
            recievedPromise = [subject fetchTimesheetInfoForTimsheetUri:@"timesheet-uri" userUri:@"user-uri"];
        });
        
        it(@"should configure the outgoing request url correctly", ^{
            request.URL.absoluteString should equal(@"https://na2.replicon.com/repliconmobile/services/mobile-backend/timesheet/widget/timeline/extras");
        });
        
        it(@"should configure the outgoing request http method correctly", ^{
            request.HTTPMethod should equal(@"POST");
        });
        
        it(@"should configure the outgoing request http body correctly", ^{
            NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                           options:0
                                                                             error:nil];
            bodyDictionary should equal(@{@"timesheetUri": @"timesheet-uri"});
        });
        
        context(@"when the request succeeds", ^{
            __block NSDictionary *jsonDictionary;
            __block TimesheetAdditionalInfo *timesheetAdditionalInfo;
            beforeEach(^{
                timesheetAdditionalInfo = nice_fake_for([TimesheetAdditionalInfo class]);
                jsonDictionary = @{@"permittedActions":@{@"hasClientsAvailableForTimeAllocation":@1}};
                timesheetInfoAndExtrasDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(timesheetAdditionalInfo);
                [deferred resolveWithValue:jsonDictionary];
            });
            
            it(@"should request timesheetInfoAndExtrasDeserializer to deserialize and return the TimesheetAdditionalInfo", ^{
                timesheetInfoAndExtrasDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
            });
            
            it(@"should request the astroClientPermissionStorage to store the user uri", ^{
                astroClientPermissionStorage should have_received(@selector(setUpWithUserUri:)).with(@"user-uri");
            });
            
            it(@"should request the astroClientPermissionStorage to store the persistUserHasClientPermission", ^{
                astroClientPermissionStorage should have_received(@selector(persistUserHasClientPermission:)).with(@1);
            });
    
            it(@"should resolve the promise with an correct value", ^{
                recievedPromise.value should equal(timesheetAdditionalInfo);
            });
        });
        
        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });
            
            it(@"should reject the promise with an correct error", ^{
                recievedPromise.error should equal(error);
            });
        });
        
    });
});

SPEC_END
