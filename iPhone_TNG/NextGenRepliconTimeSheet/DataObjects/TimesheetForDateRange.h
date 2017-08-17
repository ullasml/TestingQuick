#import "Timesheet.h"


@interface TimesheetForDateRange : NSObject <Timesheet>

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUri:(NSString *)uri
                     period:(TimesheetPeriod *)period
             approvalStatus:(TimeSheetApprovalStatus *)approvalStatus NS_DESIGNATED_INITIALIZER;

@end
