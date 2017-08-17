#import <Foundation/Foundation.h>
#import "WorkHours.h"

@interface DayTimeSummary : NSObject <WorkHours,NSCoding>

@property (nonatomic, readonly) NSDateComponents *dateComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeComponents;
@property (nonatomic, readonly) NSDateComponents *regularTimeComponents;
@property (nonatomic, readonly) NSDateComponents *regularTimeOffsetComponents;
@property (nonatomic, readonly) NSDateComponents *breakTimeOffsetComponents;
@property (nonatomic, readonly) NSDateComponents *timeOffComponents;
@property (nonatomic, readonly) BOOL isScheduledDay;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRegularTimeOffsetComponents:(NSDateComponents *)regularTimeOffsetComponents
                          breakTimeOffsetComponents:(NSDateComponents *)breakTimeOffsetComponents
                              regularTimeComponents:(NSDateComponents *)regularTimeComponents
                                breakTimeComponents:(NSDateComponents *)breakTimeComponents
                                  timeOffComponents:(NSDateComponents *)timeOffComponents
                                     dateComponents:(NSDateComponents *)dateComponents
                                     isScheduledDay:(BOOL)isScheduledDay;

@end
