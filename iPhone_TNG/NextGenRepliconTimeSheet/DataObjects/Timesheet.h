#import <Foundation/Foundation.h>


@class TimesheetPeriod;
@class TimeSheetApprovalStatus;
@class TimePeriodSummary;


typedef NS_ENUM(NSUInteger, TimesheetAstroUserType) {
    TimesheetAstroUserTypeUnknown,
    TimesheetAstroUserTypeAstro,
    TimesheetAstroUserTypeNonAstro,
    TimesheetAstroUserTypeWidgetPlatform
};


@protocol Timesheet <NSObject,NSCopying>

- (NSString *)uri;
- (TimesheetPeriod *)period;
- (TimesheetAstroUserType)astroUserType;
- (TimeSheetApprovalStatus *)approvalStatus;
- (TimePeriodSummary *)timePeriodSummary;

@optional
-(NSInteger) issuesCount;
-(NSInteger) nonActionedValidationsCount;
@end
