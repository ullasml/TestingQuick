//
//  BookmarkValidationReponseDeserializerSpec.m
//  NextGenRepliconTimeSheet


#import <Foundation/Foundation.h>
#import "BookmarkValidationReponseDeserializer.h"
#import "Cedar.h"
#import "URLStringProvider.h"
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"
#import "RepliconSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BookmarkValidationReponseDeserializerSpec)

describe(@"BookmarkValidationReponseDeserializer", ^{
    __block BookmarkValidationReponseDeserializer *subject;
    __block id<BSInjector, BSBinder> injector;
    beforeEach(^{

        injector = [InjectorProvider injector];
        subject = [injector getInstance:[BookmarkValidationReponseDeserializer class]];
    });


    describe(@"deserialize valid CPT", ^{
        __block NSArray *validBookmark;
        __block NSMutableArray *actualBookmarks;
        beforeEach(^{

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

            id json = [RepliconSpecHelper jsonWithFixture:@"valid_bookmarks_list"];
            validBookmark = [subject deserializeValidBookmark:json];
        });

        it(@"Should have valid json array", ^{
            [validBookmark objectAtIndex:0] should equal([actualBookmarks objectAtIndex:0]);
            [validBookmark objectAtIndex:1] should equal([actualBookmarks objectAtIndex:1]);
        });

        it(@"Should have client/project/task with uri and name", ^{
            [[[validBookmark objectAtIndex:0] objectForKey:@"client"] objectForKey:@"displayText"] should be_nil;
            [[[validBookmark objectAtIndex:0] objectForKey:@"client"] objectForKey:@"slug"] should be_nil;
            [[[validBookmark objectAtIndex:1] objectForKey:@"client"] objectForKey:@"displayText"] should be_nil;
            [[[validBookmark objectAtIndex:1] objectForKey:@"client"] objectForKey:@"slug"] should be_nil;
        });

    });

    describe(@"deserialize with null CPT", ^{
        __block NSArray *validBookmark;
        __block NSMutableArray *actualBookmarks;
        beforeEach(^{

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
                                              @"uri" :[NSNull null],
                                              @"name":[NSNull null]
                                              },
                                      @"project":@{
                                              @"uri" :[NSNull null],
                                              @"name":[NSNull null]
                                              },
                                      @"task" : @{
                                              @"uri" :[NSNull null],
                                              @"name":[NSNull null]
                                              }
                                      };

            [actualBookmarks addObject:cptMap1];
            [actualBookmarks addObject:cptMap2];

            id json = [RepliconSpecHelper jsonWithFixture:@"valid_bookmarks_list_with_cpt_null"];
            validBookmark = [subject deserializeValidBookmark:json];
        });

        it(@"Should have valid json array", ^{
            [validBookmark objectAtIndex:0] should equal([actualBookmarks objectAtIndex:0]);
            [validBookmark objectAtIndex:1] should equal([actualBookmarks objectAtIndex:1]);
        });

        it(@"Should have client/project/task with uri and name", ^{
            [[[validBookmark objectAtIndex:0] objectForKey:@"client"] objectForKey:@"displayText"] should be_nil;
            [[[validBookmark objectAtIndex:0] objectForKey:@"client"] objectForKey:@"slug"] should be_nil;
            [[[validBookmark objectAtIndex:1] objectForKey:@"client"] objectForKey:@"displayText"] should be_nil;
            [[[validBookmark objectAtIndex:1] objectForKey:@"client"] objectForKey:@"slug"] should be_nil;
        });
        
    });

});

SPEC_END





