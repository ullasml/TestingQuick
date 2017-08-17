#import <Cedar/Cedar.h>
#import "WaiverDeserializer.h"
#import "Waiver.h"
#import "WaiverOption.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(WaiverDeserializerSpec)

describe(@"WaiverDeserializer", ^{
    __block WaiverDeserializer *subject;

    beforeEach(^{
        subject = [[WaiverDeserializer alloc] init];
    });

    describe(@"deserialize:", ^{
        __block Waiver *waiver;
        beforeEach(^{
            NSDictionary *waiverDictionary = @{
                                               @"displayText": @"To waive this violation, click the button below. Employees waives violation pay for this day.",
                                               @"options": @[@{
                                                                 @"displayText": @"Waive Meal Penalty",
                                                                 @"value": @"accept"
                                                                 }, @{
                                                                 @"displayText": @"Do not Waive",
                                                                 @"value": @"reject"
                                                                 }],
                                               @"primaryOptionValue": @"accept",
                                               @"selectedOption": @{
                                                       @"optionValue": @"reject",
                                                       },
                                               @"uri": @"urn:replicon-tenant:astro:validation-waiver:5ed3c6b0-b454-4bfc-92ae-523577a96a47"
                                               };
            waiver = [subject deserialize:waiverDictionary];
        });

        it(@"should create a correctly configured waiver", ^{
            waiver.URI should equal(@"urn:replicon-tenant:astro:validation-waiver:5ed3c6b0-b454-4bfc-92ae-523577a96a47");
            waiver.displayText should equal(@"To waive this violation, click the button below. Employees waives violation pay for this day.");

            WaiverOption *selectedOption =  waiver.selectedOption;
            selectedOption.displayText should equal(@"Do not Waive");
            selectedOption.value should equal(@"reject");

            WaiverOption *waiverOption1 = waiver.options[0];
            waiverOption1.displayText should equal(@"Waive Meal Penalty");
            waiverOption1.value should equal(@"accept");

            WaiverOption *waiverOption2 = waiver.options[1];
            waiverOption2.displayText should equal(@"Do not Waive");
            waiverOption2.value should equal(@"reject");
        });
    });
});

SPEC_END
