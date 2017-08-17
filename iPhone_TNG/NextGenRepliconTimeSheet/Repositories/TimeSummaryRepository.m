#import "TimeSummaryRepository.h"
#import "TimeSummaryDeserializer.h"
#import <KSDeferred/KSPromise.h>
#import "TimesheetForDateRange.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestDictionaryBuilder.h"
#import "RequestBuilder.h"
#import "TimePeriodSummary.h"
#import "DateProvider.h"
#import "RequestPromiseClient.h"
#import "WorkHoursDeferred.h"
#import "DayTimeSummary.h"
#import "Timesheet.h"


@interface TimeSummaryRepository ()

@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) TimeSummaryDeserializer *timeSummaryDeserializer;
@property (nonatomic) TimesheetRepository *timesheetRepository;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) id<RequestPromiseClient> client;
@property (nonatomic) AstroClientPermissionStorage *astroClientPermissionStorage;
@property (nonatomic) NSString *userUri;
@property (nonatomic) NSDateFormatter *dateFormatter;
@end


@implementation TimeSummaryRepository

- (instancetype)initWithRequestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                    astroClientPermissionStorage:(AstroClientPermissionStorage *)astroClientPermissionStorage
                         timeSummaryDeserializer:(TimeSummaryDeserializer *)timeSummaryDeserializer
                             timesheetRepository:(TimesheetRepository *)timesheetRepository
                                    dateProvider:(DateProvider *)dateProvider
                                    userDefaults:(NSUserDefaults *)userDefaults
                                          client:(id <RequestPromiseClient>)client
                                   dateFormatter:(NSDateFormatter *)dateFormatter
{
    if (self = [super init]) {
        self.client = client;
        self.userDefaults = userDefaults;
        self.timeSummaryDeserializer = timeSummaryDeserializer;
        self.timesheetRepository = timesheetRepository;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.dateProvider = dateProvider;
        self.astroClientPermissionStorage = astroClientPermissionStorage;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

-(void)setUpWithUserUri:(NSString*)userUri
{
    self.userUri = userUri;
}

#pragma mark - <TimeSummaryFetcher>

- (WorkHoursPromise *)timeSummaryForToday
{
    WorkHoursDeferred *workHoursDeferred = [[WorkHoursDeferred alloc] init];
    KSPromise *timesheetPromise = [self.timesheetRepository fetchMostRecentTimesheet];

    [timesheetPromise then:^id(TimesheetForDateRange *timesheet) {
        NSDictionary *parameterDictionary = @{@"timesheetUri":timesheet.uri};
        NSDictionary *requestDictionary = [self.requestDictionaryBuilder
                                           requestDictionaryWithEndpointName:@"GetTimesheetSummary"
                                           httpBodyDictionary:parameterDictionary];

        NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

        NSString *serverTimestamp = [self.dateFormatter stringFromDate:self.dateProvider.date];
        [request setValue:serverTimestamp forHTTPHeaderField:GetTimesheetSummaryDateIdentifierHeader];

        KSPromise *jsonPromise = [self.client promiseWithRequest:request];

        [jsonPromise then:^id(NSDictionary *jsonDictionary) {
            NSDate *date = [self.dateProvider date];
            DayTimeSummary *dayTimeSummary = [self.timeSummaryDeserializer deserialize:jsonDictionary
                                                                               forDate:date];
            NSDictionary *dataDictionary = jsonDictionary[@"d"];
            NSNumber *hasClientsAvailableForTimeAllocation =dataDictionary[@"hasClientsAvailableForTimeAllocation"];
            [self.astroClientPermissionStorage setUpWithUserUri:self.userUri];
            [self.astroClientPermissionStorage persistUserHasClientPermission:hasClientsAvailableForTimeAllocation];
            [workHoursDeferred resolveWithValue:dayTimeSummary];
            return nil;

        } error:^id(NSError *error) {
            [workHoursDeferred rejectWithError:error];
           return nil;
        }];

        return nil;
    } error:^id(NSError *error) {
        [workHoursDeferred rejectWithError:error];
        return nil;
    }];

    return [workHoursDeferred promise];
}

- (TimePeriodSummaryPromise *)timeSummaryForTimesheet:(id<Timesheet>)timesheet
{
    NSDictionary *parameterDictionary = @{@"timesheetUri":timesheet.uri};
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder
                                       requestDictionaryWithEndpointName:@"GetTimesheetSummary"
                                       httpBodyDictionary:parameterDictionary];

    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    return (id)[jsonPromise then:^id(NSDictionary *jsonDictionary) {
        NSDictionary *dataDictionary = jsonDictionary[@"d"];
        NSNumber *hasClientsAvailableForTimeAllocation =dataDictionary[@"hasClientsAvailableForTimeAllocation"];
        [self.astroClientPermissionStorage setUpWithUserUri:self.userUri];
        [self.astroClientPermissionStorage persistUserHasClientPermission:hasClientsAvailableForTimeAllocation];
        return [self.timeSummaryDeserializer deserializeForTimesheet:jsonDictionary];
    } error:nil];
}

- (KSPromise *)submitTimeSheetData:(NSDictionary *)timeSheetPostDataMap {
    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder
                                       requestDictionaryWithEndpointName:@"SubmitTimeSheet"
                                       httpBodyDictionary:timeSheetPostDataMap];

    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    return (id)[jsonPromise then:^id(NSDictionary *jsonDictionary) {
        TimePeriodSummary *timePeriodSummary = [self.timeSummaryDeserializer deserializeForTimesheet:jsonDictionary];
        [deferred resolveWithValue:timePeriodSummary];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    return deferred.promise;
}

- (KSPromise *)reopenTimeSheet:(NSDictionary *)timeSheetPostDataMap {
    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder
                                       requestDictionaryWithEndpointName:@"ReopenTimeSheet"
                                       httpBodyDictionary:timeSheetPostDataMap];

    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    return (id)[jsonPromise then:^id(NSDictionary *jsonDictionary) {
        TimePeriodSummary *timePeriodSummary = [self.timeSummaryDeserializer deserializeForTimesheet:jsonDictionary];
        [deferred resolveWithValue:timePeriodSummary];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    return deferred.promise;
}

@end
