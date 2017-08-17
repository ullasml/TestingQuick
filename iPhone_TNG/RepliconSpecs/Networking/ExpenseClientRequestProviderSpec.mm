#import <Cedar/Cedar.h>
#import "ExpenseClientRequestProvider.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseClientRequestProviderSpec)

describe(@"ExpenseClientRequestProvider", ^{
    __block ExpenseClientRequestProvider *subject;
    __block URLStringProvider *urlStringProvider;
    __block id<BSInjector, BSBinder> injector;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        urlStringProvider = nice_fake_for([URLStringProvider class]);
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];
        
        subject = [injector getInstance:[ExpenseClientRequestProvider class]];
        
    });
    
    context(@"requestForClientsForUserWithURI:searchText:page:", ^{
        __block NSURLRequest *request;
        
        context(@"When search text exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetExpenseClients").and_return(@"http://expected.endpoint/name");
                request = [subject requestForClientsForExpenseSheetURI:@"some-user-uri" searchText:@"special-search-text" page:@2];
            });
            
            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");
                request.allHTTPHeaderFields[@"RequestMadeForSearchWithHeaderKey"] should equal(@"special-search-text");
                
                
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
                                                      @"textSearch":textSearch
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
        
        context(@"When search text not exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetExpenseClients").and_return(@"http://expected.endpoint/name");
                request = [subject requestForClientsForExpenseSheetURI:@"some-user-uri" searchText:nil page:@2];
            });
            
            it(@"should return a correctly configured request", ^{
                request.HTTPMethod should equal(@"POST");
                request.URL.absoluteString should equal(@"http://expected.endpoint/name");
                request.allHTTPHeaderFields[@"RequestMadeForSearchWithHeaderKey"] should be_nil;
                
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
                                                      @"textSearch":textSearch
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
    });
});

SPEC_END
