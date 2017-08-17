
#import "ExpenseTaskRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"

@interface ExpenseTaskRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@end


@implementation ExpenseTaskRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}

- (NSURLRequest *)requestForTasksForExpenseSheetURI:(NSString *)expenseSheetURI
                                         projectUri:(NSString *)projectUri
                                         searchText:(NSString *)text
                                               page:(NSNumber *)page;
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetExpenseTasks"];
    
    id searchText = [NSNull null];
    if (text !=nil && text != (id)[NSNull null]) {
        searchText = text;
    }
    
    id projectID = [NSNull null];
    if (projectUri !=nil && projectUri != (id)[NSNull null]) {
        projectID = projectUri;
    }
    
    NSDictionary *textSearch = @{
                                 @"queryText":searchText,
                                 @"searchInDisplayText":@YES,
                                 @"searchInName":@NO,
                                 @"searchInComment": @NO,
                                 @"searchInCode":@NO,
                                 @"searchInDescription":@NO,
                                 @"searchInFullPathDisplayText":@YES,
                                 };
    
    NSDictionary *requestBody = @{
                                  @"page":page,
                                  @"pageSize":@10,
                                  @"expenseSheetUri": expenseSheetURI,
                                  @"projectUri":projectID,
                                  @"textSearch":textSearch,
                                  };
    
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};
    
    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
