#import <Cedar/Cedar.h>
#import "SingleViolationDeserializer.h"
#import "Violation.h"
#import "WaiverDeserializer.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SingleViolationDeserializerSpec)

describe(@"SingleViolationDeserializer", ^{
    __block SingleViolationDeserializer *subject;
    __block WaiverDeserializer *waiverDeserializer;

    beforeEach(^{
        waiverDeserializer = [[WaiverDeserializer alloc] init];
        subject = [[SingleViolationDeserializer alloc] initWithWaiverDeserializer:waiverDeserializer];
    });

    describe(@"deserialize:", ^{
        __block Violation *violation;

        beforeEach(^{
            NSDictionary *singleViolationDictionary =  @{@"displayText": @"Please enter at least 8 hours.",
                                                         @"keyValues": @[
                                                                 @{
                                                                     @"keyUri": @"urn:replicon:groupby-date",
                                                                     @"value": @{
                                                                             @"date": @{
                                                                                     @"day": @1,
                                                                                     @"month": @6,
                                                                                     @"year": @2015
                                                                                     }
                                                                             }
                                                                     }
                                                                 ],
                                                         @"objectUris": @[
                                                                 @"urn:replicon-tenant:vin-test:timesheet:4f77a97a-168d-4ca0-837d-0cabd64c40fd"
                                                                 ],
                                                         @"severity": @"urn:replicon:severity:error",
                                                         @"uri": @"urn:replicon-tenant:vin-test:validation-message:037ef113-ca05-4a28-a2ee-3cc832b4ffc2",
                                                         @"waiver": [NSNull null]
                                                         };
            
            violation = [subject deserialize:singleViolationDictionary];
        });

        it(@"should create a violation from the dictionary", ^{
            violation.title should equal(@"Please enter at least 8 hours.");
            violation.severity should equal(ViolationSeverityError);
            violation.waiver should be_nil;
        });
    });
});

SPEC_END
