#import "TeamStatusSummaryRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "JSONClient.h"
#import "RequestDictionaryBuilder.h"
#import "DateProvider.h"
#import "RequestBuilder.h"
#import "TeamStatusSummary.h"
#import "TeamStatusSummaryDeserializer.h"
#import "Util.h"
#import "RepliconClient.h"

@interface TeamStatusSummaryRepository()

@property (nonatomic) TeamStatusSummaryDeserializer *teamStatusSummaryDeserializer;
@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) RepliconClient *client;
@property (nonatomic) NSCalendar *calendar;


@end

@implementation TeamStatusSummaryRepository


- (instancetype)initWithJSONClientTeamStatusSummaryDeserializer:(TeamStatusSummaryDeserializer *)teamStatusSummaryDeserializer
                                       requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                                                   dateProvider:(DateProvider *)dateProvider
                                                         client:(RepliconClient *)client
                                                       calendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {

        self.teamStatusSummaryDeserializer = teamStatusSummaryDeserializer;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.dateProvider = dateProvider;
        self.client = client;
        self.calendar = calendar;
    }
    return self;
}

-(KSPromise *)fetchTeamStatusSummary
{

    KSDeferred *teamStatusDeferred = [[KSDeferred alloc] init];

    NSDate *date = [self.dateProvider date];
    NSDate *utcDate=[Util getUTCFormatDate:date];
    NSCalendarUnit flags=NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [self.calendar components:flags fromDate:utcDate];
    
    NSDictionary *httpBodyDictionary = @{@"before":@{@"year":@(dateComponents.year),@"month":@(dateComponents.month),@"day":@(dateComponents.day),@"hour":@(dateComponents.hour),@"minute":@(dateComponents.minute),@"second":@(dateComponents.second)}};
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"GetAllUserTimeSegmentTimeOffDetailsForDate" httpBodyDictionary:httpBodyDictionary];
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    [jsonPromise then:^id(NSDictionary *dataDictionary) {
        TeamStatusSummary *teamStatusSummary = [self.teamStatusSummaryDeserializer deserialize:dataDictionary];
        [teamStatusDeferred resolveWithValue:teamStatusSummary];
        return nil;
    } error:^id(NSError *error) {
        [teamStatusDeferred rejectWithError:error];
        return nil;
    }];
    return teamStatusDeferred.promise;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
