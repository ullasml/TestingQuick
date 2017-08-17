#import "SupervisorDashboardSummaryRepository.h"
#import "RequestDictionaryBuilder.h"
#import "JSONClient.h"
#import "RequestBuilder.h"
#import <KSDeferred/KSPromise.h>
#import "SupervisorDashboardSummaryDeserializer.h"
#import <KSDeferred/KSDeferred.h>
#import "DateProvider.h"
#import "RequestPromiseClient.h"
#import "EmployeeClockInTrendSummaryDeserializer.h"


@interface SupervisorDashboardSummaryRepository ()

@property (nonatomic) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) SupervisorDashboardSummaryDeserializer *dashboardSummaryDeserializer;
@property (nonatomic) DateProvider *dateProvider;

@end


@implementation SupervisorDashboardSummaryRepository

- (instancetype)initWithRequestPromiseClient:(id<RequestPromiseClient>)requestPromiseClient
                    requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                dashboardSummaryDeserializer:(SupervisorDashboardSummaryDeserializer *)deserializer
                                dateProvider:(DateProvider *)dateProvider
{
    self = [super init];
    if (self) {
        self.requestPromiseClient = requestPromiseClient;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.dashboardSummaryDeserializer = deserializer;
        self.dateProvider = dateProvider;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (KSPromise *)fetchMostRecentDashboardSummary
{
    KSDeferred *dashboardSummaryDeferred = [[KSDeferred alloc] init];

    NSDate *date = [self.dateProvider date];
    NSDate *utcDate=[Util getUTCFormatDate:date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSCalendarUnit flags=NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:flags fromDate:utcDate];

    NSDictionary *httpBodyDictionary = @{@"before":@{@"year":@(dateComponents.year),@"month":@(dateComponents.month),@"day":@(dateComponents.day),@"hour":@(dateComponents.hour),@"minute":@(dateComponents.minute),@"second":@(dateComponents.second)}};
    NSDictionary *requestDictionary=[self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"GetTeamTimePunchOverviewSummary" httpBodyDictionary:httpBodyDictionary];
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *jsonPromise = [self.requestPromiseClient promiseWithRequest:request];

    [jsonPromise then:^id(NSDictionary *jsonDictionary) {
        SupervisorDashboardSummary *dashboardSummary = [self.dashboardSummaryDeserializer deserialize:jsonDictionary];
        [dashboardSummaryDeferred resolveWithValue:dashboardSummary];
        return nil;
    } error:^id(NSError *error) {
        [dashboardSummaryDeferred rejectWithError:error];
        return nil;
    }];

    return dashboardSummaryDeferred.promise;
}


@end
