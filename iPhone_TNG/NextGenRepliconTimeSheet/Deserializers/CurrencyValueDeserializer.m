#import "CurrencyValue.h"
#import "CurrencyValueDeserializer.h"


@implementation CurrencyValueDeserializer

- (CurrencyValue *)deserializeForCurrencyValue:(NSDictionary *)totalPayDictionary
{
    if (!totalPayDictionary || totalPayDictionary == (id)[NSNull null])
    {
        return nil;
    }

    NSArray *currencyValues = totalPayDictionary[@"multiCurrencyValue"];
    NSDictionary *currencyValueDictionary = currencyValues.firstObject;
    NSDictionary *currencyDictionary = currencyValueDictionary[@"currency"];

    NSString *currencyText =  currencyDictionary == (id)[NSNull null] ? @"" : currencyDictionary[@"displayText"] ;
    NSNumber *amount = currencyValueDictionary == (id)[NSNull null] ? @0 : currencyValueDictionary[@"amount"];

    return [[CurrencyValue alloc] initWithCurrencyDisplayText:currencyText amount:amount];
}

@end
