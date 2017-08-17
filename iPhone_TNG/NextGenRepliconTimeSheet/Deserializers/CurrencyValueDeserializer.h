#import <Foundation/Foundation.h>


@class CurrencyValue;


@interface CurrencyValueDeserializer : NSObject

- (CurrencyValue *)deserializeForCurrencyValue:(NSDictionary *)totalPayDictionary;

@end
