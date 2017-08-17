
#import <Cedar/Cedar.h>
#import <KSDeferred/KSPromise.h>
#import <KSDeferred/KSDeferred.h>
#import "OEFTypesRequestProvider.h"
#import "OEFTypeStorage.h"
#import "OEFDeserializer.h"
#import "OEFTypesRepository.h"
#import "RequestPromiseClient.h"
#import "RepliconSpecHelper.h"
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSInjector.h>
#import "OEFType.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFTypesRepositorySpec)

describe(@"Fetch OEF Types", ^{
   
    __block KSPromise *promise;
    __block NSURLRequest *expectedRequest;
    __block KSDeferred *deferred;
    __block OEFTypesRepository *subject;
    __block id<RequestPromiseClient> client;
    __block KSDeferred *jsonClientDeferred;
    __block NSUserDefaults *userDefaults;
    __block NSURLRequest *request;
    __block OEFTypesRequestProvider *oefTypesRequestProvider;
    __block OEFDeserializer *oefDeserializer;
    __block id<BSBinder, BSInjector> injector;
    __block OEFTypeStorage *oefTypeStorage;
    __block NSMutableArray *expectedOEFTypesArray;
    __block UserPermissionsStorage *userPermissionsStorage;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
    });
    
    
    beforeEach(^{
        client = nice_fake_for(@protocol(RequestPromiseClient));
        oefDeserializer = nice_fake_for([OEFDeserializer class]);
        oefTypesRequestProvider = fake_for([OEFTypesRequestProvider class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        oefTypeStorage = nice_fake_for([OEFTypeStorage class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        
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
        
        
        OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        expectedOEFTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2, nil];
        
        
    });
    
    beforeEach(^{
        [injector bind:[OEFDeserializer class] toInstance:oefDeserializer];
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        [injector bind:[OEFTypesRequestProvider class] toInstance:oefTypesRequestProvider];
        [injector bind:[OEFTypeStorage class] toInstance:oefTypeStorage];
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
    });
    
    beforeEach(^{
        subject = [injector getInstance:[OEFTypesRepository class]];
    });
    
    it(@"should correctly set the dependancies", ^{
        subject.oefDeserializer should be_same_instance_as(oefDeserializer);
        subject.oefTypesRequestProvider should be_same_instance_as(oefTypesRequestProvider);
        subject.client should be_same_instance_as(client);
        subject.oefTypesStorage should be_same_instance_as(oefTypeStorage);
    });
    
    beforeEach(^{
        deferred = [[KSDeferred alloc] init];
        expectedRequest = [[NSURLRequest alloc] init];
        
        oefTypesRequestProvider stub_method(@selector(requestForOEFTypesForUserUri:))
        .with(@"my-special-user-uri")
        .and_return(expectedRequest);
        
        client stub_method(@selector(promiseWithRequest:))
        .with(expectedRequest)
        .and_return(deferred.promise);
        
    });


    describe(@"When supervisor does have viewteamtimepunch permission", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(canViewTeamPunch)).and_return(YES);
            
        });

        context(@"when the request suceeds", ^{
            __block NSDictionary *OEFTypesDictionary;
            __block NSMutableArray *actualOEFTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                actualOEFTypesArr = [NSMutableArray arrayWithObjects:oefType1,oefType2, nil];

                OEFTypesDictionary = [RepliconSpecHelper jsonWithFixture:@"bulk_get_objectExtensionField_bindings_for_users"];

                oefDeserializer stub_method(@selector(deserializeGetObjectExtensionFieldBindingsForUsersServiceWithJson:))
                .with(OEFTypesDictionary[@"d"])
                .and_return(expectedOEFTypesArray);

                [deferred resolveWithValue:OEFTypesDictionary];

                promise = [subject fetchOEFTypesWithUserURI:@"my-special-user-uri"];
            });

            it(@"should deserialize the response", ^{
                promise.value should equal(actualOEFTypesArr);
            });

            it(@"Should call the OEFstorages storeOEF", ^{
                oefTypeStorage should have_received(@selector(storeOEFTypes:));
            });
        });

        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
                promise = [subject fetchOEFTypesWithUserURI:@"my-special-user-uri"];
            });

            it(@"should return an error", ^{
                promise.rejected should be_truthy;
                promise.error should be_same_instance_as(error);
            });
        });

    });

    describe(@"When supervisor does not have viewteamtimepunch permission", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(canViewTeamPunch)).and_return(NO);
            promise = [subject fetchOEFTypesWithUserURI:@"my-special-user-uri"];

        });

        it(@"should retuen nil response", ^{
            promise.value should be_nil;
        });

       

    });



    
    
});



SPEC_END
