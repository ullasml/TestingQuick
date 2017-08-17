#import "DelayedTimeSummaryFetcher.h"
#import <KSDeferred/KSPromise.h>
#import <KSDeferred/KSDeferred.h>
#import "WorkHoursDeferred.h"


@interface DelayedTimeSummaryFetcher ()

@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) TimeSummaryRepository *timeSummaryRepository;

@end


@implementation DelayedTimeSummaryFetcher

- (instancetype)initWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                              timeSummaryRepository:(TimeSummaryRepository *)timeSummaryRepository
{
    self = [super init];
    if (self) {
        self.serverDidFinishPunchPromise = serverDidFinishPunchPromise;
        self.timeSummaryRepository = timeSummaryRepository;
    }
    return self;
}

#pragma mark - <TimeSummaryFetcher>

- (WorkHoursPromise *)timeSummaryForToday
{
    return (id)[self.serverDidFinishPunchPromise then:^id(id value) {
        return [self.timeSummaryRepository timeSummaryForToday];
    } error:nil];
}

- (TimePeriodSummaryPromise *)timeSummaryForTimesheet:(id<Timesheet>)timesheet
{
    return (id)[self.serverDidFinishPunchPromise then:^id(id value) {
        return [self.timeSummaryRepository timeSummaryForTimesheet:timesheet];
    } error:nil];
}

- (KSPromise *)submitTimeSheetData:(NSDictionary *)timeSheetPostDataMap {
    return (id)[self.serverDidFinishPunchPromise then:^id(id value) {
        return [self.timeSummaryRepository submitTimeSheetData:timeSheetPostDataMap];
    } error:nil];
}

- (KSPromise *)reopenTimeSheet:(NSDictionary *)timeSheetPostDataMap {
    return (id)[self.serverDidFinishPunchPromise then:^id(id value) {
        return [self.timeSummaryRepository reopenTimeSheet:timeSheetPostDataMap];
    } error:nil];
}

@end
