#import <Cedar/Cedar.h>
#import "ExpenseProjectRequestProvider.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseProjectRequestProviderSpec)

describe(@"ExpenseProjectRequestProvider", ^{
    __block ExpenseProjectRequestProvider *subject;

    __block URLStringProvider *urlStringProvider;
    __block id<BSInjector, BSBinder> injector;
    beforeEach(^{
        injector = [InjectorProvider injector];
        urlStringProvider = nice_fake_for([URLStringProvider class]);
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];
        
        subject = [injector getInstance:[ExpenseProjectRequestProvider class]];
        
    });
    
    context(@"requestForProjectsForExpenseSheetURI:searchText:page:", ^{
        __block NSURLRequest *request;
        
        context(@"When search text and client uri exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetExpenseProjects").and_return(@"http://expected.endpoint/name");
                request = [subject requestForProjectsForExpenseSheetURI:@"some-user-uri"
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
                                             @"searchInComment": @NO,
                                             @"searchInCode":@NO
                                             };
                
                
                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"expenseSheetUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"clientUri":@"some-client-uri",
                                                      @"clientNullFilterBehaviorUri":[NSNull null]
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
        
        context(@"When search text and client uri does not exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetExpenseProjects").and_return(@"http://expected.endpoint/name");
                request = [subject requestForProjectsForExpenseSheetURI:@"some-user-uri"
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
                                             @"searchInComment": @NO,
                                             @"searchInCode":@NO
                                             };
                
                
                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"expenseSheetUri": @"some-user-uri",
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
