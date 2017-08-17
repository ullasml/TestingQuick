
#import "OEFDropdownRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"
#import "DateProvider.h"

@interface OEFDropdownRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;


@end

@implementation OEFDropdownRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                             dateProvider:(DateProvider *)dateProvider
                                 calendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
        self.dateProvider = dateProvider;
        self.calendar = calendar;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSURLRequest *)requestForOEFDropDownOptionsForDropDownWithURI:(NSString *)dropDownOptionUri
                                                      searchText:(NSString *)text
                                                            page:(NSNumber *)page
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetPageOfObjectExtensionTagsFilteredBySearch"];

    BOOL searchTextPresent = [self isSearchTextNotNull:text];
    id searchText = [NSNull null];
    if (searchTextPresent) {
        searchText = text;
    }
    NSDictionary *textSearch = @{
                                 @"queryText":searchText,
                                 @"searchInDisplayText":@YES,
                                 @"searchInName":@NO,
                                 @"searchInDescription": @NO,
                                 @"searchInCode":@NO
                                 };

    NSDictionary *requestBody = @{
                                  @"page":page,
                                  @"pageSize":@10,
                                  @"objectExtensionTagDefinitionUri": dropDownOptionUri,
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



-(BOOL)isSearchTextNotNull:(NSString *)text
{
    if (text !=nil && text != (id)[NSNull null] && text.length > 0) {
        return YES;
    }
    return NO;
}

@end
