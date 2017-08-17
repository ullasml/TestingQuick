

#import "ClientRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"
#import "DateProvider.h"

@interface ClientRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;


@end

@implementation ClientRequestProvider

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


- (NSURLRequest *)requestForClientsForUserWithURI:(NSString *)userUri
                                       searchText:(NSString *)text
                                             page:(NSNumber *)page
{
    NSDate *currentDate = [self.dateProvider date];
    NSCalendarUnit unit = (NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *dateComponents = [self.calendar components:unit fromDate:currentDate];
    NSDictionary *todayDateDictionary=@{@"day": [NSNumber numberWithInteger:dateComponents.day],
                                        @"month": [NSNumber numberWithInteger:dateComponents.month],
                                        @"year": [NSNumber numberWithInteger:dateComponents.year],
                                        };
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetPunchClients"];

    BOOL searchTextPresent = [self isSearchTextNotNull:text];
    id searchText = [NSNull null];
    if (searchTextPresent) {
        searchText = text;
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
                                  @"date":todayDateDictionary,
                                  @"userUri": userUri,
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
