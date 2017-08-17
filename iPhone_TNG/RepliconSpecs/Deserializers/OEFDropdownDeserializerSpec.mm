
#import <Cedar/Cedar.h>
#import "OEFDropdownDeserializer.h"
#import "RepliconSpecHelper.h"
#import "OEFDropDownType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFDropdownDeserializerSpec)

describe(@"OEFDropdownDeserializer", ^{
    __block OEFDropdownDeserializer *subject;
    __block NSArray *dropDownTypesArray;

    beforeEach(^{
        subject = [[OEFDropdownDeserializer alloc]init];
        NSDictionary *jsonDictionary= @{
                                        @"d" :     @[
                                                 @{
                                                     @"definition" :             @{
                                                             @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                             @"displayText" : @"clock in prompt",
                                                             @"slug" : @"clock-in-prompt",
                                                             @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                     },
                                                     @"displayText" : @"1",
                                                     @"slug" : @"1-3",
                                                     @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:ca065a61-c521-4c0d-afaf-1ac6867a7d06"
                                                 },
                                                 @{
                                                     @"definition" :             @{
                                                             @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                             @"displayText" : @"clock in prompt",
                                                             @"slug" : @"clock-in-prompt",
                                                             @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                     },
                                                     @"displayText" : @"10",
                                                     @"slug" : @"10-3",
                                                     @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:9d25c853-d8f0-49cd-ade8-9ef11b7dfebc"
                                                 },
                                                 @{
                                                     @"definition" :             @{
                                                             @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                             @"displayText" : @"clock in prompt",
                                                             @"slug" : @"clock-in-prompt",
                                                             @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                     },
                                                     @"displayText" : @"11",
                                                     @"slug" : @"11-2",
                                                     @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:fc398524-1bf6-456e-8d9f-fb154bd5ff99"
                                                 }
                                                 ]
                                        };
        dropDownTypesArray = [subject deserialize:jsonDictionary];
    });

    it(@"should deserialize dropDownTypes correctly", ^{

        OEFDropDownType *oefDropDownTypeA = [[OEFDropDownType alloc]initWithName:@"1"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag:ca065a61-c521-4c0d-afaf-1ac6867a7d06"];
        OEFDropDownType *oefDropDownTypeB = [[OEFDropDownType alloc]initWithName:@"10"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag:9d25c853-d8f0-49cd-ade8-9ef11b7dfebc"];
        OEFDropDownType *oefDropDownTypeC = [[OEFDropDownType alloc]initWithName:@"11"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag:fc398524-1bf6-456e-8d9f-fb154bd5ff99"];

        NSArray *expectedDropDownTypesArray = @[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC];

        dropDownTypesArray should equal(expectedDropDownTypesArray);
    });
});

SPEC_END
