#import <Foundation/Foundation.h>


@protocol Timesheet;
@protocol Cursor;
@class DateProvider;
@class TimesheetPeriod;
@class TimeSheetApprovalStatus;

@interface TimesheetDetailsPresenter : NSObject

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) DateProvider *dateProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter
                         dateProvider:(DateProvider *)dateProvider NS_DESIGNATED_INITIALIZER;

- (NSString *)dateRangeTextWithTimesheetPeriod:(TimesheetPeriod *)timesheetPeriod;

- (NSString *)approvalStatusForTimeSheet:(TimeSheetApprovalStatus *)timeSheetApprovalStatus
                                  cursor:(id<Cursor>) cursor
                         timeSheetPeriod:(TimesheetPeriod *)timeSheetPeriod;

- (BOOL)isCurrentTimesheetForPeriod:(TimesheetPeriod *)period;

@end
