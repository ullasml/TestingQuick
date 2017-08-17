#import <Cedar/Cedar.h>
#import "PayCodeHoursDeserializer.h"
#import "Paycode.h"
#import <KSDeferred/KSDeferred.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PayCodeHoursDeserializerSpec)

describe(@"PayCodeHoursDeserializer", ^{
    __block PayCodeHoursDeserializer *subject;
    beforeEach(^{
        subject = [[PayCodeHoursDeserializer alloc] init];
    });
    
    it(@"should deserialize the dictionary", ^{
        NSDictionary *payCodeDictionary = @{
                                            @"moneyValue" :             @{
                                                    @"baseCurrencyValue" :                 @{
                                                            @"amount" : @"427.8368",
                                                            @"currency" :                     @{
                                                                    @"displayText" : @"CAD$",
                                                                    @"name" : @"Canadian Dollar",
                                                                    @"symbol" : @"CAD$",
                                                                    @"uri" : @"urn:replicon-tenant:repliconiphone-2:currency:2"
                                                                    }
                                                            },
                                                    @"baseCurrencyValueAsOfDate" :
                                                        @{
                                                            @"day" : @29,
                                                            @"month" : @8,
                                                            @"year" : @2016,
                                                            },
                                                    @"multiCurrencyValue" :                @[
                                                            @{
                                                                @"amount" : @"320",
                                                                @"currency" :
                                                                    @{
                                                                        @"displayText" : @"$",
                                                                        @"name" : @"US Dollar",
                                                                        @"symbol" : @"$",
                                                                        @"uri" : @"urn:replicon-tenant:repliconiphone-2:currency:1"
                                                                        }
                                                                }
                                                            ]
                                                    },
                                            @"payCode" :             @{
                                                    @"displayText" : @"Time Off",
                                                    @"name" : @"Time Off",
                                                    @"uri" : @"urn:replicon-tenant:repliconiphone-2:pay-code:3"
                                                    },
                                            @"totalTimeDuration" :             @{
                                                    @"hours" : @"7",
                                                    @"minutes" : @"5",
                                                    @"seconds" : @"30"
                                                    }
                                            
                                            };
        
        Paycode *payCodeDuration = [subject deserializeForHoursDictionary:payCodeDictionary];
        payCodeDuration.textValue should equal(@"7h:5m");
        payCodeDuration.titleText should equal(@"Time Off");
        payCodeDuration.titleValueWithSeconds should equal(@"7h:5m:30s");
    });
    
    it(@"should return nil if dictionary is nil", ^{
        [subject deserializeForHoursDictionary:nil] should be_nil;
    });
    
});

SPEC_END
