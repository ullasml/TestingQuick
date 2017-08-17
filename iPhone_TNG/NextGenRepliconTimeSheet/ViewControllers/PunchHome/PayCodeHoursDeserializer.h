
#import <Foundation/Foundation.h>
@class Paycode;

@interface PayCodeHoursDeserializer : NSObject

- (Paycode *)deserializeForHoursDictionary:(NSDictionary *)grossHoursDictionary;
@end
