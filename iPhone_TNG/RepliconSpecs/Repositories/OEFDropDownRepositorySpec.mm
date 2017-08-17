
#import <Cedar/Cedar.h>
#import "OEFDropDownRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "OEFDropDownType.h"
#import "OEFDropdownStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFDropDownRepositorySpec)

sharedExamplesFor(@"sharedContextForFetchFreshOEFDropDownOptions", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;
    __block OEFDropDownRepository *subject;
    __block id <RequestPromiseClient> jsonCient;
    __block OEFDropdownRequestProvider *oefDropdownRequestProvider;
    __block OEFDropdownStorage *oefDropdownStorage;
    __block id <UserSession> userSession;
    __block OEFDropdownDeserializer *oefDropdownDeserializer;

    beforeEach(^{

        subject = sharedContext[@"subject"];
        jsonCient = sharedContext[@"jsonClient"];
        oefDropdownRequestProvider = sharedContext[@"oefDropdownRequestProvider"];
        oefDropdownStorage = sharedContext[@"oefDropdownStorage"];
        userSession = sharedContext[@"userSession"];
        oefDropdownDeserializer = sharedContext[@"oefDropdownDeserializer"];

    });

    beforeEach(^{
        clientsDeferred = [[KSDeferred alloc]init];
        request = nice_fake_for([NSURLRequest class]);
        oefDropdownRequestProvider stub_method(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",nil,@1).and_return(request);
        jsonCient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
        oefDropdownStorage stub_method(@selector(getAllOEFDropDownOptions)).and_return(@[@1, @2, @3]);

        promise = [subject fetchFreshOEFDropDownOptions];

    });

    it(@"should send the correctly configured request to server", ^{
        oefDropdownRequestProvider should have_received(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",nil,@1);
        jsonCient should have_received(@selector(promiseWithRequest:)).with(request);
    });

    context(@"when the request is successful", ^{
        __block NSDictionary *responseDictionary;
        beforeEach(^{
            responseDictionary = nice_fake_for([NSDictionary class]);
            oefDropdownDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
            [clientsDeferred resolveWithValue:responseDictionary];
        });

        it(@"should reset the page number", ^{
            oefDropdownStorage should have_received(@selector(resetPageNumber));
            oefDropdownStorage should have_received(@selector(resetPageNumberForFilteredSearch));
        });

        it(@"should delete all the cached data for oefURI", ^{
            oefDropdownStorage should have_received(@selector(deleteAllOEFDropDownOptionsForOEFUri:)).with(@"dropdown-oef-Uri");
        });

        it(@"should send the response dictionary to the oefdropdown deserializer", ^{
            oefDropdownDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
        });
        it(@"should persist the oef dropdown types in the oefdropdown storage cache", ^{
            oefDropdownStorage should have_received(@selector(storeOEFDropDownOptions:)).with(@[@1, @2, @3]);
        });
        it(@"should persist the oefdropdown types in the oefdropdown storage cache", ^{
            oefDropdownStorage should have_received(@selector(updatePageNumber));
        });
        it(@"should resolve the promise with the deserialized objects", ^{
            promise.value should equal(@{@"oefDropDownOptions":@[@1, @2, @3],@"downloadCount":@3});
        });
    });


    context(@"when the request is failed", ^{
        __block NSError *error;
        beforeEach(^{
            error = nice_fake_for([NSError class]);
            [clientsDeferred rejectWithError:error];
        });

        it(@"should resolve the promise with the deserialized objects", ^{
            promise.error should equal(error);
        });
    });
});

describe(@"OEFDropDownRepository", ^{
    __block OEFDropDownRepository *subject;
    __block id <BSInjector,BSBinder> injector;
    __block id <RequestPromiseClient> client;
    __block OEFDropdownRequestProvider *oefDropdownRequestProvider;
    __block OEFDropdownStorage *oefDropdownStorage;
    __block id <UserSession> userSession;
    __block OEFDropdownDeserializer *oefDropdownDeserializer;


    beforeEach(^{
        injector = [InjectorProvider injector];
        oefDropdownDeserializer = nice_fake_for([OEFDropdownDeserializer class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");

        client = nice_fake_for(@protocol(RequestPromiseClient));


        oefDropdownStorage = nice_fake_for([OEFDropdownStorage class]);
        oefDropdownRequestProvider = nice_fake_for([OEFDropdownRequestProvider class]);

        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        [injector bind:[OEFDropdownRequestProvider class] toInstance:oefDropdownRequestProvider];
        [injector bind:[OEFDropdownStorage class] toInstance:oefDropdownStorage];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[OEFDropdownDeserializer class] toInstance:oefDropdownDeserializer];


        subject = [injector getInstance:[OEFDropDownRepository class]];

        [subject setUpWithDropDownOEFUri:@"dropdown-oef-Uri" userUri:@"User-Uri"];

    });

    it(@"storage should have correctly set up the user uri", ^{
        oefDropdownStorage should have_received(@selector(setUpWithDropDownOEFUri:userUri:)).with(@"dropdown-oef-Uri",@"User-Uri");
    });

    describe(@"fetchAllOEFDropDownOptions", ^{

        __block KSPromise *promise;
        __block NSArray *expectedOEFDropDownOptionsArray;
        context(@"When cached clients are present", ^{
            beforeEach(^{
                OEFDropDownType *oefDropDownTypeA = nice_fake_for([OEFDropDownType class]);
                OEFDropDownType *oefDropDownTypeB = nice_fake_for([OEFDropDownType class]);
                OEFDropDownType *oefDropDownTypeC = nice_fake_for([OEFDropDownType class]);

                expectedOEFDropDownOptionsArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];
                oefDropdownStorage stub_method(@selector(getAllOEFDropDownOptions)).and_return(expectedOEFDropDownOptionsArray);
                promise = [subject fetchAllOEFDropDownOptions];
            });

            it(@"should resolve the promise correctly", ^{
                promise.value should equal(@{@"oefDropDownOptions":expectedOEFDropDownOptionsArray,@"downloadCount":@3});
            });
        });

        context(@"When cached OEFDropDownOptions are absent", ^{

            beforeEach(^{
                [subject fetchAllOEFDropDownOptions];
            });

            itShouldBehaveLike(@"sharedContextForFetchFreshOEFDropDownOptions",  ^(NSMutableDictionary *sharedContext) {
                sharedContext[@"oefDropdownRequestProvider"] = oefDropdownRequestProvider;
                sharedContext[@"oefDropdownStorage"] = oefDropdownStorage;
                sharedContext[@"oefDropdownDeserializer"] = oefDropdownDeserializer;
                sharedContext[@"userSession"] = userSession;
                sharedContext[@"jsonClient"] = client;
                sharedContext[@"subject"] = subject;

            });

        });
    });

    describe(@"fetchCachedOEFDropDownOptionsMatchingText:", ^{

        __block KSPromise *promise;
        __block NSArray *expectedOEFDropDownOptionsArray;

        beforeEach(^{
            OEFDropDownType *oefDropDownTypeA = nice_fake_for([OEFDropDownType class]);
            OEFDropDownType *oefDropDownTypeB = nice_fake_for([OEFDropDownType class]);
            OEFDropDownType *oefDropDownTypeC = nice_fake_for([OEFDropDownType class]);

            expectedOEFDropDownOptionsArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];;
            oefDropdownStorage stub_method(@selector(getAllOEFDropDownOptions)).and_return(@[@"some-oef-dropdown-option"]);
            oefDropdownStorage stub_method(@selector(getOEFDropDownOptionsWithMatchingText:)).with(@"some-matching-text").and_return(expectedOEFDropDownOptionsArray);
            promise = [subject fetchCachedOEFDropDownOptionsMatchingText:@"some-matching-text"];


        });

        it(@"should resolve the promise correctly", ^{
            promise.value should equal(@{@"oefDropDownOptions":expectedOEFDropDownOptionsArray,@"downloadCount":@1});
        });

    });


    describe(@"fetchOEFDropDownOptionsMatchingText:", ^{

        context(@"When searching OEFDropDownOptions with empty text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                oefDropdownStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                oefDropdownRequestProvider stub_method(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",nil,@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchOEFDropDownOptionsMatchingText:nil];
            });

            it(@"should ask for the page number", ^{
                oefDropdownStorage should have_received(@selector(getLastPageNumber));
            });

            it(@"should get the request from oefdropdown request provider", ^{
                oefDropdownRequestProvider should have_received(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",nil,@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedOEFDropDownOptionsArray;
                __block NSArray *filteredOEFDropDownOptions;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    OEFDropDownType *oefDropDownTypeA = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeB = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeC = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeD = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeE = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeF = nice_fake_for([OEFDropDownType class]);

                    filteredOEFDropDownOptions = @[oefDropDownTypeD,oefDropDownTypeE,oefDropDownTypeF];

                    oefDropdownStorage stub_method(@selector(getOEFDropDownOptionsWithMatchingText:)).with(nil).and_return(filteredOEFDropDownOptions);
                    expectedOEFDropDownOptionsArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];
                    oefDropdownDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedOEFDropDownOptionsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the oefdropdown deserializer to deserialize the clients", ^{
                    oefDropdownDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    oefDropdownStorage should have_received(@selector(storeOEFDropDownOptions:)).with(expectedOEFDropDownOptionsArray);
                });

                it(@"should update the last stored page number", ^{
                    oefDropdownStorage should have_received(@selector(updatePageNumber));
                });

                it(@"should ask the oefdropdown storage to get clients with matching text", ^{
                    oefDropdownStorage should have_received(@selector(getOEFDropDownOptionsWithMatchingText:)).with(nil);
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"oefDropDownOptions":filteredOEFDropDownOptions,@"downloadCount":@3});
                });
            });

            context(@"When request fails", ^{

                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });

                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should equal(error);
                    });
                });
            });
        });

        context(@"When searching OEFDropDownOptions with text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                oefDropdownStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                oefDropdownRequestProvider stub_method(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",@"some-search-text",@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchOEFDropDownOptionsMatchingText:@"some-search-text"];
            });

            it(@"should ask for the page number", ^{
                oefDropdownStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
            });

            it(@"should get the request from oefdropdown request provider", ^{
                oefDropdownRequestProvider should have_received(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",@"some-search-text",@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedOEFDropDownOptionsArray;
                __block NSArray *filteredOEFDropDownOptions;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    OEFDropDownType *oefDropDownTypeA = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeB = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeC = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeD = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeE = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeF = nice_fake_for([OEFDropDownType class]);

                    filteredOEFDropDownOptions = @[oefDropDownTypeD,oefDropDownTypeE,oefDropDownTypeF];

                    oefDropdownStorage stub_method(@selector(getOEFDropDownOptionsWithMatchingText:)).with(@"some-search-text").and_return(filteredOEFDropDownOptions);
                    expectedOEFDropDownOptionsArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];
                    oefDropdownDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedOEFDropDownOptionsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the oefdropdown deserializer to deserialize the clients", ^{
                    oefDropdownDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    oefDropdownStorage should have_received(@selector(storeOEFDropDownOptions:)).with(expectedOEFDropDownOptionsArray);
                });

                it(@"should update the last stored page number", ^{
                    oefDropdownStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                });

                it(@"should ask the oefdropdown storage to get clients with matching text", ^{
                    oefDropdownStorage should have_received(@selector(getOEFDropDownOptionsWithMatchingText:)).with(@"some-search-text");
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"oefDropDownOptions":filteredOEFDropDownOptions,@"downloadCount":@3});
                });
            });

            context(@"When request fails", ^{

                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });

                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should equal(error);
                    });
                });
            });
        });

    });

    describe(@"fetchMoreOEFDropDownOptionsMatchingText:", ^{

        context(@"When searching more OEFDropDownOptions with empty text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                oefDropdownStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                oefDropdownRequestProvider stub_method(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",nil,@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchMoreOEFDropDownOptionsMatchingText:nil];
            });

            it(@"should ask for the page number", ^{
                oefDropdownStorage should have_received(@selector(getLastPageNumber));
            });

            it(@"should get the request from oefdropdown request provider", ^{
                oefDropdownRequestProvider should have_received(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",nil,@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedOEFDropDownOptionsArray;
                __block NSArray *filteredOEFDropDownOptions;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    OEFDropDownType *oefDropDownTypeA = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeB = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeC = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeD = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeE = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeF = nice_fake_for([OEFDropDownType class]);

                    filteredOEFDropDownOptions = @[oefDropDownTypeD,oefDropDownTypeE,oefDropDownTypeF];

                    oefDropdownStorage stub_method(@selector(getOEFDropDownOptionsWithMatchingText:)).with(nil).and_return(filteredOEFDropDownOptions);
                    expectedOEFDropDownOptionsArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];
                    oefDropdownDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedOEFDropDownOptionsArray);

                    oefDropdownStorage stub_method(@selector(getAllOEFDropDownOptions)).and_return(expectedOEFDropDownOptionsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the oefdropdown deserializer to deserialize the clients", ^{
                    oefDropdownDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    oefDropdownStorage should have_received(@selector(storeOEFDropDownOptions:)).with(expectedOEFDropDownOptionsArray);
                });

                it(@"should update the last stored page number", ^{
                    oefDropdownStorage should have_received(@selector(updatePageNumber));
                });

                it(@"should ask the oefdropdown storage to get clients with matching text", ^{
                    oefDropdownStorage should have_received(@selector(getOEFDropDownOptionsWithMatchingText:)).with(nil);
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"oefDropDownOptions":filteredOEFDropDownOptions,@"downloadCount":@3});
                });
            });

            context(@"When request fails", ^{

                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });

                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should equal(error);
                    });
                });
            });
        });

        context(@"When searching more oefDropDownOptions with text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                oefDropdownStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                oefDropdownRequestProvider stub_method(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",@"some-search-text",@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchMoreOEFDropDownOptionsMatchingText:@"some-search-text"];
            });

            it(@"should ask for the page number", ^{
                oefDropdownStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
            });

            it(@"should get the request from oefdropdown request provider", ^{
                oefDropdownRequestProvider should have_received(@selector(requestForOEFDropDownOptionsForDropDownWithURI:searchText:page:)).with(@"dropdown-oef-Uri",@"some-search-text",@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedOEFDropDownOptionsArray;
                __block NSArray *filteredOEFDropDownOptions;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    OEFDropDownType *oefDropDownTypeA = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeB = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeC = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeD = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeE = nice_fake_for([OEFDropDownType class]);
                    OEFDropDownType *oefDropDownTypeF = nice_fake_for([OEFDropDownType class]);

                    filteredOEFDropDownOptions = @[oefDropDownTypeD,oefDropDownTypeE,oefDropDownTypeF];

                    oefDropdownStorage stub_method(@selector(getOEFDropDownOptionsWithMatchingText:)).with(@"some-search-text").and_return(filteredOEFDropDownOptions);
                   expectedOEFDropDownOptionsArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];
                    oefDropdownDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedOEFDropDownOptionsArray);
                    oefDropdownStorage stub_method(@selector(getAllOEFDropDownOptions)).and_return(expectedOEFDropDownOptionsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the oefdropdown deserializer to deserialize the clients", ^{
                    oefDropdownDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    oefDropdownStorage should have_received(@selector(storeOEFDropDownOptions:)).with(expectedOEFDropDownOptionsArray);
                });

                it(@"should update the last stored page number", ^{
                    oefDropdownStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                });
                
                it(@"should ask the oefdropdown storage to get clients with matching text", ^{
                    oefDropdownStorage should have_received(@selector(getOEFDropDownOptionsWithMatchingText:)).with(@"some-search-text");
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"oefDropDownOptions":filteredOEFDropDownOptions,@"downloadCount":@3});
                });
            });
            
            context(@"When request fails", ^{
                
                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });
                    
                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should equal(error);
                    });
                });
            });
        });
    });
    
    
    
});

SPEC_END

