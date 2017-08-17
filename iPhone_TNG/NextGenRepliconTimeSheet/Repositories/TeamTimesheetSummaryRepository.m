#import "TeamTimesheetSummaryRepository.h"
#import "TeamTimesheetSummaryDeserializer.h"
#import "RequestDictionaryBuilder.h"
#import "RepliconClient.h"
#import "RequestBuilder.h"
#import <KSDeferred/KSDeferred.h>
#import "TeamTimesheetSummary.h"
#import "TimesheetPeriod.h"


@interface TeamTimesheetSummaryRepository ()

@property (nonatomic) TeamTimesheetSummaryDeserializer *teamTimesheetSummaryDeserializer;
@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) RepliconClient *client;
@property (nonatomic) NSCalendar *calendar;

@end


@implementation TeamTimesheetSummaryRepository

- (instancetype)initWithTeamTimesheetSummaryDeserializer:(TeamTimesheetSummaryDeserializer *)teamTimesheetSummaryDeserializer
                                requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                                                  client:(RepliconClient *)client
                                                calendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self)
    {
        self.teamTimesheetSummaryDeserializer = teamTimesheetSummaryDeserializer;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.client = client;
        self.calendar = calendar;
    }

    return self;
}

- (KSPromise *)fetchTeamTimesheetSummaryWithTimesheetPeriod:(TimesheetPeriod *)timesheetPeriod
{
    KSDeferred *deferred = [[KSDeferred alloc] init];

    NSDictionary *startDateDictionary = [self dictionaryForDate:timesheetPeriod.startDate];
    NSDictionary *endDateDictionary = [self dictionaryForDate:timesheetPeriod.endDate];

    NSDictionary *requestBodyDictionary = @{
                                            @"range": @{
                                                @"startDate": startDateDictionary,
                                                @"endDate": endDateDictionary,
                                                @"relativeDateRangeUri": [NSNull null],
                                                @"relativeDateRangeAsOfDate": [NSNull null],
                                            }
                                        };

    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"GetTeamTimesheetOverviewSummary"
                                                                                    httpBodyDictionary:requestBodyDictionary];
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    [jsonPromise then:^id(NSDictionary *jsonResponse) {
        TeamTimesheetSummary *teamTimesheetSummary = [self.teamTimesheetSummaryDeserializer deserialize:jsonResponse];

        [deferred resolveWithValue:teamTimesheetSummary];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    return deferred.promise;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSDictionary *)dictionaryForDate:(NSDate *)date
{
    if (date == nil)
    {
        return (id)[NSNull null];
    }

    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];

    return @{
             @"year":@(dateComponents.year),
             @"month":@(dateComponents.month),
             @"day":@(dateComponents.day)
             };
}

@end
