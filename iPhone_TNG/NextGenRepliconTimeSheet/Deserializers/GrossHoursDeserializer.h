
#import <Foundation/Foundation.h>
@class GrossHours;

@interface GrossHoursDeserializer : NSObject

- (GrossHours *)deserializeForHoursDictionary:(NSDictionary *)grossHoursDictionary;

@end
