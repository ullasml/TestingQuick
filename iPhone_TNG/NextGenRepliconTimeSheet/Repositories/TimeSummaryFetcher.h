#import <Foundation/Foundation.h>


@class KSPromise;
@class WorkHoursPromise;
@class TimePeriodSummaryPromise;
@protocol Timesheet;

@protocol TimeSummaryFetcher <NSObject>

- (WorkHoursPromise *)timeSummaryForToday;
- (TimePeriodSummaryPromise *)timeSummaryForTimesheet:(id<Timesheet>)timesheet;
- (KSPromise *)submitTimeSheetData:(NSDictionary *)timeSheetPostDataMap;
- (KSPromise *)reopenTimeSheet:(NSDictionary *)timeSheetPostDataMap;

@end
