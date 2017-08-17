#import "EmployeeClockInTrendSummaryRepository.h"
#import "RequestBuilder.h"
#import <KSDeferred/KSDeferred.h>
#import "EmployeeClockInTrendSummary.h"
#import "RequestPromiseClient.h"
#import "RequestDictionaryBuilder.h"
#import "EmployeeClockInTrendSummaryDeserializer.h"
#import "DateProvider.h"


@interface EmployeeClockInTrendSummaryRepository ()

@property (nonatomic) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) EmployeeClockInTrendSummaryDeserializer *employeeClockInTrendSummaryDeserializer;

@property(nonatomic) NSCalendar *calendar;
@property(nonatomic) DateProvider *dateProvider;
@end


@implementation EmployeeClockInTrendSummaryRepository

NSUInteger const samplingIntervalMinutes = 12;

- (instancetype)initWithEmployeeClockInTrendSummaryDeserializer:(EmployeeClockInTrendSummaryDeserializer *)employeeClockInTrendSummaryDeserializer
                                           requestPromiseClient:(id <RequestPromiseClient>)requestPromiseClient
                                       requestDictionaryBuilder:(RequestDictionaryBuilder *)
requestDictionaryBuilder
                                                   dateProvider:(DateProvider *)dateProvider
                                                       calendar:(NSCalendar *)calendar {
    self = [super init];
    if (self) {

        self.employeeClockInTrendSummaryDeserializer = employeeClockInTrendSummaryDeserializer;
        self.requestPromiseClient = requestPromiseClient;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.calendar = calendar;
        self.dateProvider = dateProvider;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (KSPromise *)fetchEmployeeClockInTrendSummary
{

    NSDate *date = [self.dateProvider date];
    NSDate *utcDate=[Util getUTCFormatDate:date];
    NSCalendarUnit flags=NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [self.calendar components:flags fromDate:utcDate];
    NSDictionary *beforeDictionary = @{@"year":@(dateComponents.year),@"month":@(dateComponents.month),@"day":@(dateComponents.day),@"hour":@(dateComponents.hour),@"minute":@(dateComponents.minute),@"second":@(dateComponents.second)};

    KSDeferred *employeeClockInTrendSummaryDeferred = [[KSDeferred alloc] init];

    NSString *samplingIntervalMinutesString = [NSString stringWithFormat:@"%lu", (unsigned long)samplingIntervalMinutes];
    NSDictionary *requestBodyDictionary = @{
                                            @"samplingInterval": @{
                                                    @"hours": @"0",
                                                    @"minutes": samplingIntervalMinutesString,
                                                    @"seconds": @"0"
                                                    },
                                            @"workInterval": @{
                                                    @"hours": @"0",
                                                    @"minutes": @"8",
                                                    @"seconds": @"0"
                                                    },
                                            @"before":beforeDictionary
                                            };

    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"GetTeamChartSummary" httpBodyDictionary:requestBodyDictionary];
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *trendRequestPromise = [self.requestPromiseClient promiseWithRequest:request];

    [trendRequestPromise then:^id(NSDictionary *jsonDictionary)
     {
         NSUInteger totalSamplingIntervalSeconds = samplingIntervalMinutes * 60;
         EmployeeClockInTrendSummary *employeeClockInTrendSummary = [self.employeeClockInTrendSummaryDeserializer deserialize:jsonDictionary samplingIntervalSeconds:totalSamplingIntervalSeconds];
         [employeeClockInTrendSummaryDeferred resolveWithValue:employeeClockInTrendSummary];
         return nil;
     } error:^id(NSError *error)
     {
         [employeeClockInTrendSummaryDeferred rejectWithError:error];
         return nil;
     }];
    
    return employeeClockInTrendSummaryDeferred.promise;
}


@end
