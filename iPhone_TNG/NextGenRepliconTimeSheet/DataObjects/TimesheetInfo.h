
#import <Foundation/Foundation.h>
#import "Enum.h"
#import "Timesheet.h"

@class CurrencyValue;
@class GrossHours;
@class TimeSheetApprovalStatus;
@class TimePeriodSummary;
@class TimesheetPeriod;

@interface TimesheetInfo : NSObject <Timesheet,NSCopying>


@property (nonatomic, readonly) TimePeriodSummary *timePeriodSummary;
@property (nonatomic, readonly) TimesheetPeriod *period;
@property (nonatomic, readonly) NSString *uri;
@property (nonatomic, readonly) NSInteger issuesCount;
@property (nonatomic, readonly) NSInteger nonActionedValidationsCount;
@property (nonatomic, readonly) TimeSheetApprovalStatus *approvalStatus;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimeSheetApprovalStatus:(TimeSheetApprovalStatus *)timeSheetApprovalStatus
                    nonActionedValidationsCount:(NSInteger)nonActionedValidationsCount
                              timePeriodSummary:(TimePeriodSummary *)timePeriodSummary
                                    issuesCount:(NSInteger)issuesCount
                                         period:(TimesheetPeriod *)period
                                            uri:(NSString *)uri NS_DESIGNATED_INITIALIZER;

@end
