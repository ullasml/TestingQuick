//
//  BookmarkValidationRequestProviderSpec.m
//  NextGenRepliconTimeSheet


#import <Foundation/Foundation.h>
#import "Cedar.h"
#import "BookmarkValidationRequestProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BlindSide.h>
#import "URLStringProvider.h"
#import "InjectorProvider.h"
#import "PunchCardObject.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BookmarkValidationRequestProviderSpec)


describe(@"BookmarkValidationRequestProvider", ^{

    __block BookmarkValidationRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{

       injector = [InjectorProvider injector];

        urlStringProvider = nice_fake_for([URLStringProvider class]);
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];

        subject = [injector getInstance:[BookmarkValidationRequestProvider class]];
        [subject setupUserUri:@"My-Current-user-uri"];
        
    });

    describe(@"-requestForBookmarkValidation", ^{

        __block NSURLRequest *request;

        beforeEach(^{
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:)).with(@"BookmarkValidation").and_return(@"https://some-end-point/name");

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

            NSArray *bookmarks = @[card1, card2, card3];

            request = [subject requestForBookmarkValidation:bookmarks];
        });

        it(@"should create a POST request", ^{
            request.HTTPMethod should equal(@"POST");
        });

        it(@"should create a request with the correct URL", ^{
            request.URL.absoluteString should equal(@"https://some-end-point/name");
        });

        it(@"should create a request with the correct HTTP body", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];

            NSDictionary *expectedRequestBodyDictionary = @{
                                                            @"userUri":@"My-Current-user-uri",
                                                            @"clientsProjectsTasks" : @[
                                                                    @{
                                                                        @"client" : @{
                                                                                        @"uri":@"my-client-uri-1",
                                                                                        @"displayText":@"my-client-1"
                                                                                    },
                                                                        @"project" :@{
                                                                                        @"uri":@"my-project-uri-1",
                                                                                        @"displayText":@"my-project-1"
                                                                                    },
                                                                        @"task":@{
                                                                                        @"uri":@"my-task-uri-1",
                                                                                        @"displayText":@"my-task-1"
                                                                                }
                                                                        },
                                                                    @{
                                                                        @"client" : @{
                                                                                @"uri":@"my-client-uri-2",
                                                                                @"displayText":@"my-client-2"
                                                                                },
                                                                        @"project" :@{
                                                                                @"uri":@"my-project-uri-2",
                                                                                @"displayText":@"my-project-2"
                                                                                },
                                                                        @"task":@{
                                                                                @"uri":@"my-task-uri-2",
                                                                                @"displayText":@"my-task-2"
                                                                                }
                                                                        },
                                                                    @{
                                                                        @"client" : @{
                                                                                @"uri":@"my-client-uri-3",
                                                                                @"displayText":@"my-client-3"
                                                                                },
                                                                        @"project" :@{
                                                                                @"uri":@"my-project-uri-3",
                                                                                @"displayText":@"my-project-3"
                                                                                },
                                                                        @"task":@{
                                                                                @"uri":@"my-task-uri-3",
                                                                                @"displayText":@"my-task-3"
                                                                                }
                                                                        }
                                                                    ]
                                                          };


            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });

    });

});

SPEC_END
