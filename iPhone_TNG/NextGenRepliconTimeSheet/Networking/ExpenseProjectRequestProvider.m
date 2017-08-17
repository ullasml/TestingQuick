
#import "ExpenseProjectRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"

@interface ExpenseProjectRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;


@end


@implementation ExpenseProjectRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}


- (NSURLRequest *)requestForProjectsForExpenseSheetURI:(NSString *)expenseSheetURI
                                             clientUri:(NSString *)clientUri
                                            searchText:(NSString *)text
                                                  page:(NSNumber *)page
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetExpenseProjects"];
    
    id searchText = [NSNull null];
    if (text !=nil && text != (id)[NSNull null]) {
        searchText = text;
    }
    
    id clientURI = [NSNull null];
    if (clientUri !=nil && clientUri != (id)[NSNull null] && clientUri.length > 0) {
        clientURI = clientUri;
    }
    
    NSDictionary *textSearch = @{
                                 @"queryText":searchText,
                                 @"searchInDisplayText":@YES,
                                 @"searchInName":@NO,
                                 @"searchInComment": @NO,
                                 @"searchInCode":@NO
                                 };
    
    NSDictionary *requestBody = @{
                                  @"page":page,
                                  @"pageSize":@10,
                                  @"expenseSheetUri": expenseSheetURI,
                                  @"textSearch":textSearch,
                                  @"clientUri":clientURI,
                                  @"clientNullFilterBehaviorUri":[NSNull null]
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
