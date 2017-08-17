#import <Cedar/Cedar.h>
#import "ActualsByPayCodeDeserializer.h"
#import "Paycode.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ActualsByPayCodeDeserializerSpec)

describe(@"ActualsByPayCodeDeserializer", ^{
    __block ActualsByPayCodeDeserializer *subject;
    __block id<BSInjector, BSBinder> injector;
    __block NSNumberFormatter *numberFormatter;
    beforeEach(^{
        subject = [[ActualsByPayCodeDeserializer alloc] init];
        numberFormatter = [[NSNumberFormatter alloc] init];
        [injector bind:InjectorKeyCalendarWithLocalTimeZone toInstance:numberFormatter];
    });
    
    it(@"should parse ActualsByPayCode", ^{
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
                                                              @"hours" : @"-7",
                                                              @"minutes" : @"5",
                                                              @"seconds" : @"30"
                                                      }
                                                      
                                                  };
        
        
        Paycode *payCode = [subject deserializeForPayCodeDictionary:payCodeDictionary];
        payCode.textValue should equal(@"$320.00");
        payCode.titleText should equal(@"Time Off");
        
    });
    
    it(@"should parse ActualsByPayCode", ^{
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
                                                                @"amount" : @"321.9999",
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
                                                    @"hours" : @"-7",
                                                    @"minutes" : @"5",
                                                    @"seconds" : @"30"
                                                    }
                                            
                                            };
        
        
        Paycode *payCode = [subject deserializeForPayCodeDictionary:payCodeDictionary];
        payCode.textValue should equal(@"$322.00");
        payCode.titleText should equal(@"Time Off");
        
    });
    
    it(@"should parse ActualsByPayCode", ^{
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
                                                                @"amount" : @"164.33689",
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
                                                    @"hours" : @"-7",
                                                    @"minutes" : @"5",
                                                    @"seconds" : @"30"
                                                    }
                                            
                                            };
        
        
        Paycode *payCode = [subject deserializeForPayCodeDictionary:payCodeDictionary];
        payCode.textValue should equal(@"$164.34");
        payCode.titleText should equal(@"Time Off");
        
    });
    
    it(@"should return nil if dictionary is nil", ^{
        [subject deserializeForPayCodeDictionary:nil] should be_nil;
    });
    
    it(@"should return nil if dictionary is NSNull", ^{
        [subject deserializeForPayCodeDictionary:(id)[NSNull null]] should be_nil;
    });
});

SPEC_END
