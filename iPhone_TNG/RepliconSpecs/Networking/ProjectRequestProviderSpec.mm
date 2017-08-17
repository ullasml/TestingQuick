#import <Cedar/Cedar.h>
#import "ProjectRequestProvider.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "DateProvider.h"
#import "URLStringProvider.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ProjectRequestProviderSpec)

describe(@"ProjectRequestProvider", ^{
    __block ProjectRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block id<BSInjector, BSBinder> injector;
    beforeEach(^{
        injector = [InjectorProvider injector];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        DateProvider *dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);
        [injector bind:[DateProvider class] toInstance:dateProvider];

        urlStringProvider = nice_fake_for([URLStringProvider class]);
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];

        subject = [injector getInstance:[ProjectRequestProvider class]];

    });

    context(@"requestForProjectsForUserWithURI:searchText:page:", ^{
        __block NSURLRequest *request;

        context(@"When search text and client uri exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetPunchProjects").and_return(@"http://expected.endpoint/name");
                request = [subject requestForProjectsForUserWithURI:@"some-user-uri"
                                                          clientUri:@"some-client-uri"
                                                         searchText:@"special-search-text"
                                                               page:@2];
            });

            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");

                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];

                NSDictionary *textSearch = @{
                                             @"queryText":@"special-search-text",
                                             @"searchInDisplayText":@YES,
                                             @"searchInName":@NO,
                                             @"searchInDescription": @NO,
                                             @"searchInCode":@NO
                                             };

                NSDictionary *todaysDateDictionary = @{@"day": @1,
                                                       @"month": @1,
                                                       @"year": @1970};

                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"date":todaysDateDictionary,
                                                      @"userUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"clientUri":@"some-client-uri",
                                                      @"clientNullFilterBehaviorUri":[NSNull null]
                                                      };


                httpBody should equal(expectedRequestBody);
            });

        });
        
        context(@"When search text and clientNullBehaviour uri exists and type is Any Client", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetPunchProjects").and_return(@"http://expected.endpoint/name");
                request = [subject requestForProjectsForUserWithURI:@"some-user-uri"
                                                          clientUri:ClientTypeAnyClientUri
                                                         searchText:@"special-search-text"
                                                               page:@2];
            });
            
            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");
                
                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];
                
                NSDictionary *textSearch = @{
                                             @"queryText":@"special-search-text",
                                             @"searchInDisplayText":@YES,
                                             @"searchInName":@NO,
                                             @"searchInDescription": @NO,
                                             @"searchInCode":@NO
                                             };
                
                NSDictionary *todaysDateDictionary = @{@"day": @1,
                                                       @"month": @1,
                                                       @"year": @1970};
                
                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"date":todaysDateDictionary,
                                                      @"userUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"clientUri":[NSNull null],
                                                      @"clientNullFilterBehaviorUri":ClientTypeAnyClientUri
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
        
        context(@"When search text and clientNullBehaviour uri exists and type is No Client", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetPunchProjects").and_return(@"http://expected.endpoint/name");
                request = [subject requestForProjectsForUserWithURI:@"some-user-uri"
                                                          clientUri:ClientTypeNoClientUri
                                                         searchText:@"special-search-text"
                                                               page:@2];
            });
            
            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");
                
                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];
                
                NSDictionary *textSearch = @{
                                             @"queryText":@"special-search-text",
                                             @"searchInDisplayText":@YES,
                                             @"searchInName":@NO,
                                             @"searchInDescription": @NO,
                                             @"searchInCode":@NO
                                             };
                
                NSDictionary *todaysDateDictionary = @{@"day": @1,
                                                       @"month": @1,
                                                       @"year": @1970};
                
                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"date":todaysDateDictionary,
                                                      @"userUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"clientUri":[NSNull null],
                                                      @"clientNullFilterBehaviorUri":ClientTypeNoClientUri
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });

        context(@"When search text and client uri does not exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetPunchProjects").and_return(@"http://expected.endpoint/name");
                request = [subject requestForProjectsForUserWithURI:@"some-user-uri"
                                                          clientUri:nil
                                                         searchText:nil
                                                               page:@2];
            });

            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");

                NSDictionary *httpBody = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                         options:0
                                                                           error:nil];

                NSDictionary *textSearch = @{
                                             @"queryText":[NSNull null],
                                             @"searchInDisplayText":@YES,
                                             @"searchInName":@NO,
                                             @"searchInDescription": @NO,
                                             @"searchInCode":@NO
                                             };

                NSDictionary *todaysDateDictionary = @{@"day": @1,
                                                       @"month": @1,
                                                       @"year": @1970};

                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"date":todaysDateDictionary,
                                                      @"userUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"clientUri":[NSNull null],
                                                      @"clientNullFilterBehaviorUri":[NSNull null]
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
    });
    
});

SPEC_END
