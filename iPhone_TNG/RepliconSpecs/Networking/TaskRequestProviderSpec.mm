#import <Cedar/Cedar.h>
#import "TaskRequestProvider.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "DateProvider.h"
#import "URLStringProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TaskRequestProviderSpec)

describe(@"TaskRequestProvider", ^{
    __block TaskRequestProvider *subject;
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

        subject = [injector getInstance:[TaskRequestProvider class]];

    });

    context(@"requestForTasksForUserWithURI:searchText:page:", ^{
        __block NSURLRequest *request;

        context(@"When search text and project uri exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetPunchTasks").and_return(@"http://expected.endpoint/name");
                request = [subject requestForTasksForUserWithURI:@"some-user-uri"
                                                          projectUri:@"some-project-uri"
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
                                             @"searchInCode": @NO,
                                             @"searchInDescription":@NO,
                                             @"searchInFullPathDisplayText":@YES,
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
                                                      @"projectUri":@"some-project-uri",
                                                      };


                httpBody should equal(expectedRequestBody);
            });

        });

        context(@"When search text and project uri does not exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetPunchTasks").and_return(@"http://expected.endpoint/name");
                request = [subject requestForTasksForUserWithURI:@"some-user-uri"
                                                          projectUri:nil
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
                                             @"searchInCode": @NO,
                                             @"searchInDescription":@NO,
                                             @"searchInFullPathDisplayText":@YES,
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
                                                      @"projectUri":[NSNull null],
                                                      };

                httpBody should equal(expectedRequestBody);
            });
            
        });
    });
    
});

SPEC_END
