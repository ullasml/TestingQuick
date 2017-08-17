#import <Foundation/Foundation.h>
#import "WorkHours.h"

@interface TeamWorkHoursSummary : NSObject <WorkHours>

@property (nonatomic, readonly) NSDateComponents *regularTimeComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeComponents;
@property (nonatomic, readonly) NSDateComponents *overtimeComponents;
@property (nonatomic, readonly) NSDateComponents *timeOffComponents;
@property (nonatomic, readonly) BOOL isScheduledDay;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithOvertimeComponents:(NSDateComponents *)overtimeComponents
                     regularTimeComponents:(NSDateComponents *)regularTimeComponents
                       breakTimeComponents:(NSDateComponents *)breakTimeComponents
                         timeOffComponents:(NSDateComponents *)timeOffComponents
                            isScheduledDay:(BOOL)isScheduledDay;

@end
