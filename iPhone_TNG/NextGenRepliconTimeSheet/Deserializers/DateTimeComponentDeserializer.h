#import <Foundation/Foundation.h>

@interface DateTimeComponentDeserializer : NSObject


- (NSDateComponents *)deserializeDateTime:(NSDictionary *)dateTimeComponentsDictionary;
@end
