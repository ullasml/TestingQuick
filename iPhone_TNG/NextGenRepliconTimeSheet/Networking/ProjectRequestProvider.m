

#import "ProjectRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"
#import "DateProvider.h"

@interface ProjectRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;


@end

@implementation ProjectRequestProvider

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


- (NSURLRequest *)requestForProjectsForUserWithURI:(NSString *)userUri
                                         clientUri:(NSString *)clientUri
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
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetPunchProjects"];

    id searchText = [NSNull null];
    if (text !=nil && text != (id)[NSNull null]) {
        searchText = text;
    }

    id clientURI = [self getClientURI:clientUri];
    id clientNullFilterBehaviorUri = [self getClientNullFilterBehaviorUri:clientUri];

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
                                  @"date":todayDateDictionary,
                                  @"userUri": userUri,
                                  @"textSearch":textSearch,
                                  @"clientUri":clientURI,
                                  @"clientNullFilterBehaviorUri":clientNullFilterBehaviorUri
                                  };
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}

#pragma mark - Helper Method

- (id)getClientURI:(NSString *)clientUri {
    
    if(!IsNotEmptyString(clientUri)) {
        return [NSNull null];
    }
    else if([self isClientNullFilterBehaviorUri:clientUri]) {
        return [NSNull null];
    }
    else {
        return clientUri;
    }
}

- (id)getClientNullFilterBehaviorUri:(NSString *)clientUri {
    
    if(!IsNotEmptyString(clientUri)) {
        return [NSNull null];
    }
    else if(![self isClientNullFilterBehaviorUri:clientUri]) {
        return [NSNull null];
    }
    else {
        return clientUri;
    }
}

- (BOOL)isClientNullFilterBehaviorUri:(NSString *)clientUri {
    
    if([clientUri isEqualToString:ClientTypeAnyClientUri] || [clientUri isEqualToString:ClientTypeNoClientUri]) {
        return TRUE;
    }
    return FALSE;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end
