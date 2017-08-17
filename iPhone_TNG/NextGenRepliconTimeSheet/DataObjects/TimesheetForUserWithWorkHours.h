#import <Foundation/Foundation.h>
#import "Timesheet.h"
#import "TimeSheetApprovalStatus.h"

@interface TimesheetForUserWithWorkHours : NSObject<Timesheet>

@property (nonatomic, readonly) NSDateComponents *totalOvertimeHours;
@property (nonatomic, readonly) NSDateComponents *totalRegularHours;
@property (nonatomic, readonly) NSDateComponents *totalBreakHours;
@property (nonatomic, readonly) NSDateComponents *totalWorkHours;
@property (nonatomic, readonly) NSNumber *violationsCount;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *userURI;
@property (nonatomic, readonly) TimesheetPeriod *period;
@property (nonatomic, readonly) TimeSheetApprovalStatus *approvalStatus;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTotalOvertimeHours:(NSDateComponents *)totalOvertimeHours
                         totalRegularHours:(NSDateComponents *)totalRegularHours
                           totalBreakHours:(NSDateComponents *)totalBreakHours
                            totalWorkHours:(NSDateComponents *)totalWorkHours
                           violationsCount:(NSNumber *)violationsCount
                                  userName:(NSString *)userName
                                   userURI:(NSString *)userURI
                                    period:(TimesheetPeriod *)period
                                       uri:(NSString *)uri
                   timeSheetApprovalStatus:(TimeSheetApprovalStatus *)timeSheetApprovalStatus NS_DESIGNATED_INITIALIZER;

@end
