#import <Cedar/Cedar.h>
#import "OEFDeserializer.h"
#import "RepliconSpecHelper.h"
#import "OEFType.h"
#import "RepliconSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFDeserializerSpec)

describe(@"OEFDeserializer", ^{
    __block OEFDeserializer *subject;
    __block NSArray *oefTypesArray;

    beforeEach(^{
        subject = [[OEFDeserializer alloc]init];
    });

    describe(@"deserializeHomeFlowService:", ^{
        beforeEach(^{

            NSDictionary *timePunchExtensionFieldsDict = @{
                                                           @"collectAtTimeOfPunchFieldBindings": @[
                                                                   @{
                                                                       @"code": [NSNull null],
                                                                       @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                       @"description": [NSNull null],
                                                                       @"name": @"dipta number",
                                                                       @"slug": @"dipta-number",
                                                                       @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f"
                                                                       },
                                                                   @{
                                                                       @"code" : [NSNull null],
                                                                       @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                       @"description" : [NSNull null],
                                                                       @"name" : @"clock in prompt",
                                                                       @"slug" : @"clock-in-prompt",
                                                                       @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                                   }
                                                                   ],
                                                           @"punchInFieldBindings": @[
                                                                   @{
                                                                       @"code": [NSNull null],
                                                                       @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                       @"description": [NSNull null],
                                                                       @"name": @"dipta number",
                                                                       @"slug": @"dipta-number",
                                                                       @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f"
                                                                       },
                                                                   @{
                                                                       @"code": [NSNull null],
                                                                       @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                       @"description": [NSNull null],
                                                                       @"name": @"dipta text",
                                                                       @"slug": @"dipta-text",
                                                                       @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af"
                                                                       },
                                                                   @{
                                                                       @"code" : [NSNull null],
                                                                       @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                       @"description" : [NSNull null],
                                                                       @"name" : @"clock in",
                                                                       @"slug" : @"clock-in",
                                                                       @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:3ebb7ba4-2343-4d07-81cb-ca2610d8dba9"
                                                                   },
                                                                   @{
                                                                       @"code" : [NSNull null],
                                                                       @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                       @"description" : [NSNull null],
                                                                       @"name" : @"clock in prompt",
                                                                       @"slug" : @"clock-in-prompt",
                                                                       @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                                       }
                                                                   
                                                                   ],
                                                           @"punchOutFieldBindings": @[
                                                                   @{
                                                                       @"code": [NSNull null],
                                                                       @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                       @"description": [NSNull null],
                                                                       @"name": @"generic oef - prompt",
                                                                       @"slug": @"generic-oef-prompt",
                                                                       @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"
                                                                       }
                                                                   ],
                                                           @"punchStartBreakFieldBindings": @[

                                                                   ],
                                                           @"punchTransferFieldBindings": @[

                                                                   ]
                                                           };

            oefTypesArray = [subject deserializeHomeFlowService:timePunchExtensionFieldsDict];

        });

        it(@"should deserialize oefTypes correctly", ^{
            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];


            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:3ebb7ba4-2343-4d07-81cb-ca2610d8dba9" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"clock in" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            OEFType *oefType4 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"clock in prompt" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];


            OEFType *oefType5 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"generic oef - prompt" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            
            oefTypesArray should equal(@[oefType1,oefType2,oefType3,oefType4,oefType5]);
        });

    });

    describe(@"deserializeMostRecentPunch:punchActionType:", ^{


        context(@"When oef is added later", ^{
            __block NSDictionary *extensionFieldsDictionary;
            beforeEach(^{
                extensionFieldsDictionary = @{
                                              @"extensionFields": @{
                                                      @"bindings": @[
                                                              @{
                                                                  @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f",
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                  @"slug": @"dipta-number",
                                                                  @"displayText": @"dipta number"
                                                                  },
                                                              @{
                                                                  @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af",
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                  @"slug": @"dipta-text",
                                                                  @"displayText": @"dipta text"
                                                                  },
                                                              @{
                                                                  @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79",
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                  @"slug": @"number-not-prompt",
                                                                  @"displayText": @"number not prompt"
                                                                  },
                                                              @{
                                                                  @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997",
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                  @"slug": @"text-not-prompt",
                                                                  @"displayText": @"text- not prompt"
                                                                  },
                                                              @{
                                                                  @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                  @"displayText" : @"clock in prompt",
                                                                  @"slug" : @"clock-in-prompt",
                                                                  @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                              }

                                                              ],
                                                      @"values": @[
                                                              @{
                                                                  @"definition": @{
                                                                          @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997",
                                                                          @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                          @"slug": @"text-not-prompt",
                                                                          @"displayText": @"text- not prompt"
                                                                          },
                                                                  @"numericValue": [NSNull null],
                                                                  @"textValue": [NSNull null],
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                  @"tag": [NSNull null]
                                                                  },
                                                              @{
                                                                  @"definition": @{
                                                                          @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af",
                                                                          @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                          @"slug": @"dipta-text",
                                                                          @"displayText": @"dipta text"
                                                                          },
                                                                  @"numericValue": [NSNull null],
                                                                  @"textValue": [NSNull null],
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                  @"tag": [NSNull null]
                                                                  },
                                                              @{
                                                                  @"definition": @{
                                                                          @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f",
                                                                          @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                          @"slug": @"dipta-number",
                                                                          @"displayText": @"dipta number"
                                                                          },
                                                                  @"numericValue": [NSNumber numberWithDouble:123],
                                                                  @"textValue": [NSNull null],
                                                                  @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                  @"tag": [NSNull null]
                                                                  },
                                                              @{
                                                                  @"definition" :             @{
                                                                          @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                          @"displayText" : @"clock in prompt",
                                                                          @"slug" : @"clock-in-prompt",
                                                                          @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d",
                                                                  },
                                                                  @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                  @"numericValue" : [NSNull null],
                                                                  @"tag" :             @{
                                                                      @"definition" :      @{
                                                                                            @"definitionTypeUri" :                    @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                                                            @"displayText" : @"clock in prompt",
                                                                                            @"slug" : @"clock-in-prompt",
                                                                                            @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                                      },
                                                                      @"displayText" : @"5",
                                                                      @"slug" : @"5-5",
                                                                      @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:626ceb92-010a-43ee-9609-9983c5e8de42"
                                                                  },
                                                                  @"textValue" : [NSNull null]
                                                              }
                                                            ]
                                                      }
                                              };
                oefTypesArray = [subject deserializeMostRecentPunch:extensionFieldsDictionary[@"extensionFields"] punchActionType:@"PunchIn"];
            });

            it(@"should deserialize oefTypes correctly", ^{


                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType5 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"clock in prompt" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag:626ceb92-010a-43ee-9609-9983c5e8de42" dropdownOptionValue:@"5" collectAtTimeOfPunch:NO disabled:NO];



                oefTypesArray should equal(@[oefType1 , oefType2, oefType3, oefType4, oefType5]);
            });
        });

        context(@"when oef is deleted later", ^{
            __block NSDictionary *extensionFieldsDictionary;
            beforeEach(^{
                extensionFieldsDictionary = @{@"extensionFields": @{
                    @"values": @[
                               @{
                                   @"textValue": @"12323",
                                   @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                   @"definition": @{
                                       @"slug": @"cloclout-text-oef-prompt",
                                       @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                       @"displayText": @"cloclout-text-oef-prompt",
                                       @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:51ebc657-32f6-4d76-8c39-5e5dc0067e2f"
                                   },
                                   @"numericValue": [NSNull null],
                                   @"tag": [NSNull null]
                               },
                               @{
                                   @"textValue": @"23123123123",
                                   @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                   @"definition": @{
                                       @"slug": @"text-clock-out",
                                       @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                       @"displayText": @"text- clock out",
                                       @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:b36ea242-a0d5-43aa-8eb4-e81c0e823dd8"
                                   },
                                   @"numericValue": [NSNull null],
                                   @"tag": [NSNull null]
                               },
                               @{
                                   @"definition" :             @{
                                           @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                           @"displayText" : @"clock in prompt",
                                           @"slug" : @"clock-in-prompt",
                                           @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d",
                                           },
                                   @"definitionTypeUri" : @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                   @"numericValue" : [NSNull null],
                                   @"tag" :             @{
                                           @"definition" :      @{
                                                   @"definitionTypeUri" :                    @"urn:replicon:object-extension-definition-type:object-extension-type-tag",
                                                   @"displayText" : @"clock in prompt",
                                                   @"slug" : @"clock-in-prompt",
                                                   @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d"
                                                   },
                                           @"displayText" : @"5",
                                           @"slug" : @"5-5",
                                           @"uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:626ceb92-010a-43ee-9609-9983c5e8de42"
                                           },
                                   @"textValue" : [NSNull null]
                                   }
                               ],
                    @"bindings": @[
                                 @{
                                     @"slug": @"text-clock-out",
                                     @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                     @"displayText": @"text- clock out",
                                     @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:b36ea242-a0d5-43aa-8eb4-e81c0e823dd8"
                                 }
                                 ]
                }};
                oefTypesArray = [subject deserializeMostRecentPunch:extensionFieldsDictionary[@"extensionFields"] punchActionType:@"PunchIn"];
            });

            it(@"should deserialize oefTypes correctly", ^{

                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:b36ea242-a0d5-43aa-8eb4-e81c0e823dd8" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- clock out"                                                                                            punchActionType:@"PunchIn" numericValue:nil textValue:@"23123123123" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                 OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:51ebc657-32f6-4d76-8c39-5e5dc0067e2f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"cloclout-text-oef-prompt" punchActionType:@"PunchIn" numericValue:nil textValue:@"12323" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:59270193-fbd6-4b8e-ab3d-966c485f4b5d" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"clock in prompt" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag:626ceb92-010a-43ee-9609-9983c5e8de42" dropdownOptionValue:@"5" collectAtTimeOfPunch:NO disabled:YES];



                oefTypesArray should equal(@[oefType1 , oefType2 ,oefType3]);
            });
        });

    });
    
    describe(@"deserializeGetObjectExtensionFieldBindingsForUsersServiceWithJson:", ^{
        __block NSDictionary *OEFTypesDictionary;
        __block NSMutableArray *objectExtensionFieldBindingsForUsersArray;
        
        beforeEach(^{
             OEFTypesDictionary = [RepliconSpecHelper jsonWithFixture:@"bulk_get_objectExtensionField_bindings_for_users"];
            objectExtensionFieldBindingsForUsersArray = [subject deserializeGetObjectExtensionFieldBindingsForUsersServiceWithJson:[OEFTypesDictionary objectForKey:@"d"]];
        });
        
        it(@"Should deserialize OEF for User correctly", ^{
            
            OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                 "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:faeef124-a3d8-4598-a7f6-c12df6e89706" definitionTypeUri:@
                                 "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                 "supedit-eof-number-noprompt-clockout-field"                                                                                            punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4b41396d-4783-4c31-95bf-1dc55643f626" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"supedit-eof-number-noprompt-field" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            
            OEFType *oefType3 = [[OEFType alloc]                                                                                      initWithUri:@
                                 "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0ff40d5f-bd4a-4a16-b0e6-f4326fef6a13" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"supedit-eof-number-prompt-field" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            
            OEFType *oefType4 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:b20fcfdf-b4b8-4093-ad74-dc6b4c7a3362" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@
                                 "supedit-eof-text-noprompt-break-field"      punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            
            OEFType *oefType5 = [[OEFType alloc]                                                                                      initWithUri:@
                                 "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:291705aa-fb3f-4ae8-8ed5-3b11b45fea46" definitionTypeUri:@
                                 "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                 "supedit-eof-text-noprompt-field"                                                                                            punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            
            OEFType *oefType6 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a1b80375-2385-4f11-b90d-75d84927ef37" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"supedit-eof-text-noprompt-transfer-field" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            
            OEFType *oefType7 = [[OEFType alloc]                                                                                      initWithUri:@
                                 "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:12702ab2-1aa6-4e6c-b2c5-4853ecc65be6" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"supedit-eof-text-prompt-field" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            OEFType *oefType8 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:b08219cf-94c0-40ea-a91c-bec89b066890" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                 "supedit-eof-number-prompt-clockout-field"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            OEFType *oefType9 = [[OEFType alloc]                                                                                      initWithUri:@
                                 "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:3e297141-fb98-4402-a3b6-7959b8da4bdd" definitionTypeUri:@
                                 "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                 "supedit-eof-text-prompt-clockout-field"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            OEFType *oefType10 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:711a1919-f081-4231-bdd7-fd5ff64c78d2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"supedit-eof-number-noprompt-break-field" punchActionType:@"StartBreak" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            
            OEFType *oefType11 = [[OEFType alloc]                                                                                      initWithUri:@
                                 "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:b0885128-a7e9-4efb-85e3-b3c4c7b16f2e" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"supedit-eof-number-prompt-break-field" punchActionType:@"StartBreak" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            
            OEFType *oefType12 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:5d0b5c77-dab1-45f5-a8ba-078aa2eb5a17" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@
                                 "supedit-eof-text-prompt-break-field"      punchActionType:@"StartBreak" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            OEFType *oefType13 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:aaeb2834-2dea-4af4-b11c-f3f9ad5fdf27" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@
                                  "supedit-eof-text-prompt-transfer-field"      punchActionType:@"Transfer" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            
            
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:0] should equal(oefType1);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:1] should equal(oefType2);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:2] should equal(oefType3);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:3] should equal(oefType4);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:4] should equal(oefType5);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:5] should equal(oefType6);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:6] should equal(oefType7);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:7] should equal(oefType8);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:8] should equal(oefType9);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:9] should equal(oefType10);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:10] should equal(oefType11);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:11] should equal(oefType12);
            [objectExtensionFieldBindingsForUsersArray objectAtIndex:12] should equal(oefType13);
            
            
            objectExtensionFieldBindingsForUsersArray should equal(@[oefType1, oefType2,oefType3, oefType4, oefType5, oefType6, oefType7, oefType8, oefType9, oefType10, oefType11, oefType12, oefType13]);
            
        });
        
    });

});

SPEC_END
