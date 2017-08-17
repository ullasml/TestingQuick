

#import <Foundation/Foundation.h>
#import "LocalPunch.h"

@interface ManualPunch : LocalPunch

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLocalPunch:(LocalPunch * )localPunch;

@end
