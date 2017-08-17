#import <Foundation/Foundation.h>
#import "WorkHours.h"

@interface TimesheetDaySummary : NSObject <WorkHours,NSCoding>

@property (nonatomic, readonly) NSDateComponents *dateComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeComponents;
@property (nonatomic, readonly) NSDateComponents *regularTimeComponents;
@property (nonatomic, readonly) NSDateComponents *timeOffComponents;
@property (nonatomic, readonly) NSDateComponents *regularTimeOffsetComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeOffsetComponents;
@property (nonatomic, readonly) NSInteger totalViolationMessageCount;
@property (nonatomic, copy, readonly) NSArray *punchesForDay;
@property (nonatomic, readonly) BOOL isScheduledDay;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRegularTimeOffsetComponents:(NSDateComponents *)regularTimeOffsetComponents
                          breakTimeOffsetComponents:(NSDateComponents *)breakTimeOffsetComponents
                              regularTimeComponents:(NSDateComponents *)regularTimeComponents
                         totalViolationMessageCount:(NSInteger )totalViolationMessageCount
                                breakTimeComponents:(NSDateComponents *)breakTimeComponents
                                  timeOffComponents:(NSDateComponents *)timeOffComponents
                                     dateComponents:(NSDateComponents *)dateComponents
                                      punchesForDay:(NSArray *)punchesForDay
                                     isScheduledDay:(BOOL)isScheduledDay NS_DESIGNATED_INITIALIZER;
@end
