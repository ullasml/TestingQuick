#import <Foundation/Foundation.h>


@class TimesheetForDateRange;


@interface TimesheetDeserializer : NSObject

- (NSArray *)deserialize:(NSDictionary *)timesheetDictionary;

@end
