
#import "ExpenseClientRequestProvider.h"
#import "ClientRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"


@interface ExpenseClientRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;


@end


@implementation ExpenseClientRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}


- (NSURLRequest *)requestForClientsForExpenseSheetURI:(NSString *)expenseSheetURI
                                           searchText:(NSString *)text
                                                 page:(NSNumber *)page
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetExpenseClients"];
    
    BOOL searchTextPresent = [self isSearchTextNotNull:text];
    id searchText = [NSNull null];
    if (searchTextPresent) {
        searchText = text;
    }
    NSDictionary *textSearch = @{
                                 @"queryText":searchText,
                                 @"searchInDisplayText":@true,
                                 @"searchInName":@false,
                                 @"searchInComment": @false,
                                 @"searchInCode":@false
                                 };
    
    NSDictionary *requestBody = @{
                                  @"page":page,
                                  @"pageSize":@10,
                                  @"expenseSheetUri": expenseSheetURI,
                                  @"textSearch":textSearch
                                  };
    
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};
    
    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
    if (searchTextPresent) {
        [request setValue:searchText forHTTPHeaderField:RequestMadeForSearchWithHeaderKey];
    }
    return request;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(BOOL)isSearchTextNotNull:(NSString *)text
{
    if (text !=nil && text != (id)[NSNull null] && text.length > 0) {
        return YES;
    }
    return NO;
}


@end
