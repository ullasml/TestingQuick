
#import <Foundation/Foundation.h>
@class Paycode;

@interface ActualsByPayCodeDeserializer : NSObject

- (Paycode *)deserializeForPayCodeDictionary:(NSDictionary *)actualsByPayCodeDictionary;
@end
