#import <Cedar/Cedar.h>
#import "CurrencyValueDeserializer.h"
#import "CurrencyValue.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CurrencyValueDeserializerSpec)

describe(@"CurrencyValueDeserializer", ^{
    __block CurrencyValueDeserializer *subject;

    beforeEach(^{
        subject = [[CurrencyValueDeserializer alloc] init];
    });

    it(@"should parse the currency value", ^{
        NSDictionary *currencyValueDictionary = @{
            @"multiCurrencyValue": @[
                @{
                    @"amount": @120,
                    @"currency": @{
                        @"symbol": @"£",
                        @"displayText": @"£",
                        @"name": @"British Pound",
                        @"uri": @"urn:replicon-tenant:astro:currency:3"
                    }
                }
            ]
        };
        CurrencyValue *currencyValue = [subject deserializeForCurrencyValue:currencyValueDictionary];

        currencyValue.currencyDisplayText should equal(@"£");
        currencyValue.amount should equal(@120);
    });


    it(@"should return valid currency as long as amount has some value and everything else is null", ^{
        NSDictionary *currencyDictionaryWithNullValues = @{
                                                           @"baseCurrencyValue" : [NSNull null],
                                                           @"baseCurrencyValueAsOfDate" : [NSNull null],
                                                           @"multiCurrencyValue" :@[
                                                                   @{
                                                                       @"amount" : @0,
                                                                       @"currency" : [NSNull null]
                                                                       }
                                                                   ]
                                                           };
        CurrencyValue *currencyValue = [subject deserializeForCurrencyValue:currencyDictionaryWithNullValues];

        currencyValue.currencyDisplayText should equal(@"");
        currencyValue.amount should equal(@0);
    });

    it(@"should return nil if dictionary is nil", ^{
        [subject deserializeForCurrencyValue:nil] should be_nil;
    });

    it(@"should return nil if dictionary is NSNull", ^{
        [subject deserializeForCurrencyValue:(id)[NSNull null]] should be_nil;
    });
});

SPEC_END
