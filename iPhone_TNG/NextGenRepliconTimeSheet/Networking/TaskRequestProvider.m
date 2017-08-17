
#import "TaskRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"
#import "DateProvider.h"

@interface TaskRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;


@end

@implementation TaskRequestProvider

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

- (NSURLRequest *)requestForTasksForUserWithURI:(NSString *)userUri
                                     projectUri:(NSString *)projectUri
                                     searchText:(NSString *)text
                                           page:(NSNumber *)page;
{
    NSDate *currentDate = [self.dateProvider date];
    NSCalendarUnit unit = (NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *dateComponents = [self.calendar components:unit fromDate:currentDate];
    NSDictionary *todayDateDictionary=@{@"day": [NSNumber numberWithInteger:dateComponents.day],
                                        @"month": [NSNumber numberWithInteger:dateComponents.month],
                                        @"year": [NSNumber numberWithInteger:dateComponents.year],
                                        };
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetPunchTasks"];

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
                                 @"searchInCode":@NO,
                                 @"searchInDescription":@NO,
                                 @"searchInFullPathDisplayText":@YES,
                                 };

    NSDictionary *requestBody = @{
                                  @"page":page,
                                  @"pageSize":@10,
                                  @"date":todayDateDictionary,
                                  @"userUri": userUri,
                                  @"textSearch":textSearch,
                                  @"projectUri":projectID,
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
