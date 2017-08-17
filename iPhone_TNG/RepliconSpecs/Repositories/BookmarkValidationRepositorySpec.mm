//
//  BookmarkValidationRepositorySpec.m
//  NextGenRepliconTimeSheet


#import <Foundation/Foundation.h>
#import "BookmarkValidationRepository.h"
#import "Cedar.h"
#import "InjectorProvider.h"
#import "BookmarkValidationRequestProvider.h"
#import "PunchCardStorage.h"
#import "UserSession.h"
#import "BookmarkValidationReponseDeserializer.h"
#import "JSONClient.h"
#import <Blindside/BlindSide.h>
#import "PunchCardObject.h"
#import <KSDeferred/KSDeferred.h>
#import "RepliconSpecHelper.h"
#import "BackgroundURLSessionClient.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BookmarkValidationRepositorySpec)

describe(@"BookmarkValidationRepository", ^{
    __block BookmarkValidationRepository *subject;
    __block id <UserSession> userSession;
    __block BookmarkValidationReponseDeserializer *deserializer;
    __block BookmarkValidationRequestProvider *requestProvider;
    __block PunchCardStorage *bookmarkStorage;
    __block id<BSInjector, BSBinder> injector;
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;
    __block JSONClient *client;


    beforeEach(^{

        client = nice_fake_for([JSONClient class]);
        deserializer = nice_fake_for([BookmarkValidationReponseDeserializer class]);
        requestProvider = nice_fake_for([BookmarkValidationRequestProvider class]);
        bookmarkStorage = nice_fake_for([PunchCardStorage class]);

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"My-current-user-uri");

        [injector bind:[BookmarkValidationReponseDeserializer class] toInstance:deserializer];
        [injector bind:[BookmarkValidationRequestProvider class] toInstance:requestProvider];
        [injector bind:[JSONClient class] toInstance:client];
        [injector bind:[PunchCardStorage class] toInstance:bookmarkStorage];

        subject = [[BookmarkValidationRepository alloc] initWithRequestProvider:requestProvider deserializer:deserializer bookmarkStorage:bookmarkStorage client:client userSession:userSession];


    });

    describe(@"-ValidateBookmarks", ^{
        __block NSMutableArray *actualBookmarks;
        __block id json;
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            ClientType *client1 = [[ClientType alloc] initWithName:@"my-client-1" uri:@"my-client-uri-1"];
            ClientType *client2= [[ClientType alloc] initWithName:@"my-client-2" uri:@"my-client-uri-2"];
            ClientType *client3 = [[ClientType alloc] initWithName:@"my-client-3" uri:@"my-client-uri-3"];

            ProjectType *project1 = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:client1 name:@"my-project-1" uri:@"my-project-uri-1"];

            ProjectType *project2 = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:client2 name:@"my-project-2" uri:@"my-project-uri-2"];

            ProjectType *project3 = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:client3 name:@"my-project-3" uri:@"my-project-uri-3"];


            TaskType *task1 = [[TaskType alloc] initWithProjectUri:@"my-project-uri-1" taskPeriod:nil name:@"my-task-1" uri:@"my-task-uri-1"];

            TaskType *task2 = [[TaskType alloc] initWithProjectUri:@"my-project-uri-2" taskPeriod:nil name:@"my-task-2" uri:@"my-task-uri-2"];

            TaskType *task3 = [[TaskType alloc] initWithProjectUri:@"my-project-uri-3" taskPeriod:nil name:@"my-task-3" uri:@"my-task-uri-3"];

            PunchCardObject *card1 = [[PunchCardObject alloc] initWithClientType:client1 projectType:project1 oefTypesArray:nil breakType:nil taskType:task1 activity:nil uri:@"my-uri-1"];

            PunchCardObject *card2 = [[PunchCardObject alloc] initWithClientType:client2 projectType:project2 oefTypesArray:nil breakType:nil taskType:task2 activity:nil uri:@"my-uri-2"];

            PunchCardObject *card3 = [[PunchCardObject alloc] initWithClientType:client3 projectType:project3 oefTypesArray:nil breakType:nil taskType:task3 activity:nil uri:@"my-uri-3"];
            
            NSArray *punchCards = @[card1, card2, card3];

            actualBookmarks = [[NSMutableArray alloc] initWithCapacity:1];

            NSDictionary *cptMap1 = @{
                                      @"client": @{
                                              @"uri" :@"urn:replicon-tenant:9769df3ff85644ccab649aa504c9ff21:client:4",
                                              @"name":@"Xo Xo Communications"
                                              },
                                      @"project":@{
                                              @"uri" :@"urn:replicon-tenant:9769df3ff85644ccab649aa504c9ff21:project:25",
                                              @"name":@"Dashboarding"
                                              },
                                      @"task" : @{
                                              @"uri" :@"urn:replicon-tenant:9769df3ff85644ccab649aa504c9ff21:task:143",
                                              @"name":@"Deployment"
                                              }
                                      };
            NSDictionary *cptMap2 = @{
                                      @"client": @{
                                              @"uri" :@"urn:replicon-tenant:9769df3ff85644ccab649aa504c9ff21:client:2",
                                              @"name":@"Advantage Technologies"
                                              },
                                      @"project":@{
                                              @"uri" :@"urn:replicon-tenant:9769df3ff85644ccab649aa504c9ff21:project:20",
                                              @"name":@"Customer Billing System"
                                              },
                                      @"task" : @{
                                              @"uri" :@"urn:replicon-tenant:9769df3ff85644ccab649aa504c9ff21:task:103",
                                              @"name":@"Development"
                                              }
                                      };

            [actualBookmarks addObject:cptMap1];
            [actualBookmarks addObject:cptMap2];

            requestProvider stub_method(@selector(setupUserUri:)).with(@"My-current-user-uri");
            request = nice_fake_for([NSURLRequest class]);
            requestProvider stub_method(@selector(requestForBookmarkValidation:)).with(actualBookmarks).and_return(request);
            client stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            bookmarkStorage stub_method(@selector(getPunchCards)).and_return(punchCards);

             json = [RepliconSpecHelper jsonWithFixture:@"valid_bookmarks_list"];

             promise = [subject validateBookmarks];
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                responseDictionary = nice_fake_for([NSDictionary class]);
                deserializer stub_method(@selector(deserializeValidBookmark:)).and_return(actualBookmarks);
                [clientsDeferred resolveWithValue:json];
            });

            it(@"should send the response dictionary to the client deserializer", ^{
                deserializer should have_received(@selector(deserializeValidBookmark:));
            });


            it(@"should resolve the promise with the deserialized objects", ^{
                promise.value should equal(actualBookmarks);
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

});

SPEC_END
