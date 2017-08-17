#import <Cedar/Cedar.h>
#import "ExpenseTaskRequestProvider.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "DateProvider.h"
#import "URLStringProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseTaskRequestProviderSpec)

describe(@"ExpenseTaskRequestProvider", ^{
    __block ExpenseTaskRequestProvider *subject;
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
        
        subject = [injector getInstance:[ExpenseTaskRequestProvider class]];
        
    });
    
    context(@"requestForTasksForExpenseSheetURI:searchText:page:", ^{
        __block NSURLRequest *request;
        
        context(@"When search text and project uri exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetExpenseTasks").and_return(@"http://expected.endpoint/name");
                request = [subject requestForTasksForExpenseSheetURI:@"some-user-uri"
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
                                             @"searchInComment": @NO,
                                             @"searchInCode":@NO,
                                             @"searchInDescription":@NO,
                                             @"searchInFullPathDisplayText":@YES,
                                             };
                
                
                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"expenseSheetUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"projectUri":@"some-project-uri",
                                                      };
                
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
        
        context(@"When search text and project uri does not exists", ^{
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"GetExpenseTasks").and_return(@"http://expected.endpoint/name");
                request = [subject requestForTasksForExpenseSheetURI:@"some-user-uri"
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
                                             @"searchInComment": @NO,
                                             @"searchInCode":@NO,
                                             @"searchInDescription":@NO,
                                             @"searchInFullPathDisplayText":@YES,
                                             };
                
                
                NSDictionary *expectedRequestBody = @{
                                                      @"page":@2,
                                                      @"pageSize":@10,
                                                      @"expenseSheetUri": @"some-user-uri",
                                                      @"textSearch":textSearch,
                                                      @"projectUri":[NSNull null],
                                                      };
                
                httpBody should equal(expectedRequestBody);
            });
            
        });
    });
});

SPEC_END
