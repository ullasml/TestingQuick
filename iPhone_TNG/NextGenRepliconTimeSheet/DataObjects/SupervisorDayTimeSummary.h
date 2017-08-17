
#import <Foundation/Foundation.h>
#import "WorkHours.h"

@interface SupervisorDayTimeSummary : NSObject <WorkHours>

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateComponents:(NSDateComponents *)dateComponents
                 regularTimeComponents:(NSDateComponents *)regularTimeComponents
                   breakTimeComponents:(NSDateComponents *)breakTimeComponents
                    overTimeComponents:(NSDateComponents *)overTimeComponents
                     regularTimeOffset:(NSDateComponents *)regularTimeOffset
                       breakTimeOffset:(NSDateComponents *)breakTimeOffset NS_DESIGNATED_INITIALIZER;

@end
