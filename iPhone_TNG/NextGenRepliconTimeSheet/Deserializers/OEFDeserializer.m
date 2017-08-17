#import "OEFDeserializer.h"
#import "OEFType.h"
#import "Constants.h"

@implementation OEFDeserializer

-(NSMutableArray *)deserializeHomeFlowService:(NSDictionary *)jsonDictionary
{
    NSMutableArray *allOEFsArray = [NSMutableArray array];
    if (jsonDictionary!=nil && ![jsonDictionary isKindOfClass:[NSNull class]])
    {
        NSArray *punchInFieldBindings = jsonDictionary[@"punchInFieldBindings"];
        NSArray *punchOutFieldBindings = jsonDictionary[@"punchOutFieldBindings"];
        NSArray *punchStartBreakFieldBindings = jsonDictionary[@"punchStartBreakFieldBindings"];
        NSArray *punchTransferFieldBindings = jsonDictionary[@"punchTransferFieldBindings"];
        NSMutableArray *punchInOefsArray = [self setUpOEFObjects:punchInFieldBindings punchActionType:@"PunchIn" collectAtTimeOfPunchFieldBindings:jsonDictionary[@"collectAtTimeOfPunchFieldBindings"]];
        NSMutableArray *punchOutOefsArray = [self setUpOEFObjects:punchOutFieldBindings punchActionType:@"PunchOut" collectAtTimeOfPunchFieldBindings:jsonDictionary[@"collectAtTimeOfPunchFieldBindings"]];
        NSMutableArray *punchStartBreakOefsArray = [self setUpOEFObjects:punchStartBreakFieldBindings punchActionType:@"StartBreak" collectAtTimeOfPunchFieldBindings:jsonDictionary[@"collectAtTimeOfPunchFieldBindings"]];
        NSMutableArray *punchTransferBreakOefsArray = [self setUpOEFObjects:punchTransferFieldBindings punchActionType:@"Transfer" collectAtTimeOfPunchFieldBindings:jsonDictionary[@"collectAtTimeOfPunchFieldBindings"]];


        [allOEFsArray addObjectsFromArray:punchInOefsArray];
        [allOEFsArray addObjectsFromArray:punchOutOefsArray];
        [allOEFsArray addObjectsFromArray:punchStartBreakOefsArray];
        [allOEFsArray addObjectsFromArray:punchTransferBreakOefsArray];
    }


    return allOEFsArray;
}


-(NSMutableArray *)deserializeGetObjectExtensionFieldBindingsForUsersServiceWithJson:(NSDictionary *)jsonDictionary {
    
    NSMutableArray *objectExtensionFiledDetailsArray = jsonDictionary[@"objectExtensionDefinitionDetails"];
    NSMutableArray *userFieldBindingArray = jsonDictionary[@"userTimePunchObjectExtensionFields"];
    
    NSMutableArray *allOEFsArray = [NSMutableArray array];
    if ([self isObjectNotEmpty:objectExtensionFiledDetailsArray] && [self isObjectNotEmpty:userFieldBindingArray])
    {
        
        for (NSDictionary *userDict in userFieldBindingArray) {
           
            NSMutableArray *punchInFieldBindings = userDict[@"punchInFieldUris"];
            punchInFieldBindings = [self updateUserFieldBindings:punchInFieldBindings objectExtensionDetailsArray:objectExtensionFiledDetailsArray];
            
            NSMutableArray *punchOutFieldBindings = userDict[@"punchOutFieldUris"];
            punchOutFieldBindings = [self updateUserFieldBindings:punchOutFieldBindings objectExtensionDetailsArray:objectExtensionFiledDetailsArray];
            
            NSMutableArray *punchStartBreakFieldBindings = userDict[@"punchStartBreakFieldUris"];
            punchStartBreakFieldBindings = [self updateUserFieldBindings:punchStartBreakFieldBindings objectExtensionDetailsArray:objectExtensionFiledDetailsArray];
            
            NSMutableArray *punchTransferFieldBindings = userDict[@"punchTransferFieldUris"];
            punchTransferFieldBindings = [self updateUserFieldBindings:punchTransferFieldBindings objectExtensionDetailsArray:objectExtensionFiledDetailsArray];
            
            
            NSMutableArray *punchInOefsArray = [self setUpOEFObjects:punchInFieldBindings punchActionType:@"PunchIn" collectAtTimeOfPunchFieldBindings:userDict[@"collectAtTimeOfPunchFieldUris"]];
            
            NSMutableArray *punchOutOefsArray = [self setUpOEFObjects:punchOutFieldBindings punchActionType:@"PunchOut" collectAtTimeOfPunchFieldBindings:userDict[@"collectAtTimeOfPunchFieldUris"]];
            
            NSMutableArray *punchStartBreakOefsArray = [self setUpOEFObjects:punchStartBreakFieldBindings punchActionType:@"StartBreak" collectAtTimeOfPunchFieldBindings:userDict[@"collectAtTimeOfPunchFieldUris"]];
            
            NSMutableArray *punchTransferBreakOefsArray = [self setUpOEFObjects:punchTransferFieldBindings punchActionType:@"Transfer" collectAtTimeOfPunchFieldBindings:userDict[@"collectAtTimeOfPunchFieldUris"]];
            
            
            [allOEFsArray addObjectsFromArray:punchInOefsArray];
            [allOEFsArray addObjectsFromArray:punchOutOefsArray];
            [allOEFsArray addObjectsFromArray:punchStartBreakOefsArray];
            [allOEFsArray addObjectsFromArray:punchTransferBreakOefsArray];
        }
    }

    return allOEFsArray;
}

-(NSMutableArray *)deserializeMostRecentPunch:(NSDictionary *)extensionFieldsDictionary punchActionType:(NSString *)punchActionType
{

    NSMutableArray *allOEFsArray = nil;
    if (extensionFieldsDictionary!=nil && ![extensionFieldsDictionary isKindOfClass:[NSNull class]])
    {
        NSArray *extensionFieldsBindingsDictionary = extensionFieldsDictionary[@"bindings"];
        NSArray *extensionFieldsValuesDictionary = extensionFieldsDictionary[@"values"];

        NSMutableArray *punchOefsArray = [self setUpOEFObjects:extensionFieldsBindingsDictionary punchActionType:punchActionType values:extensionFieldsValuesDictionary];

        if (punchOefsArray.count>0)
        {
            allOEFsArray = [NSMutableArray array];
            [allOEFsArray addObjectsFromArray:punchOefsArray];
        }


    }


    return allOEFsArray;
}

#pragma maek - <Private>

- (NSMutableArray *)updateUserFieldBindings:(NSMutableArray *)fieldBindingsArr objectExtensionDetailsArray:(NSMutableArray *)objectExtensionDetailsArray
{
    NSMutableArray *updatedFieldArray = [[NSMutableArray alloc] initWithCapacity:1];
    for(int i=0; i<[fieldBindingsArr count]; i++) {
        for( int j=0; j<[objectExtensionDetailsArray count]; j++) {
            NSDictionary *obj = [objectExtensionDetailsArray objectAtIndex:j];
            NSString *uri = [obj objectForKey:@"uri"];
            NSString *userFieldBindingUri = [fieldBindingsArr objectAtIndex:i];
            if([uri isEqualToString:userFieldBindingUri]) {
                [updatedFieldArray addObject:obj];
                break;
            }
        }
    }
    return updatedFieldArray;
}

-(NSMutableArray *)setUpOEFObjects:(NSArray *)punchOEFArray punchActionType:(NSString *)punchActionType collectAtTimeOfPunchFieldBindings:(NSArray *)collectAtTimeOfPunchFieldBindings
{
    NSMutableArray *allOEFsArray = [NSMutableArray array];
    for (NSDictionary *oefDict in punchOEFArray)
    {

        NSString *oefURI = oefDict[@"uri"];
        BOOL collectAtTimeOfPunch = NO;
        
        for (id collectPunchFieldBindingsObj in collectAtTimeOfPunchFieldBindings) {
            
            if([collectPunchFieldBindingsObj respondsToSelector:@selector(objectForKey:)]) {
                NSString *collectOEFURI = collectPunchFieldBindingsObj[@"uri"];
                if ([collectOEFURI isEqualToString:oefURI])
                {
                    collectAtTimeOfPunch = YES;
                    break;
                }
            } else if([collectPunchFieldBindingsObj isKindOfClass:[NSString class]]) {
                
                NSString *collectOEFURI = collectPunchFieldBindingsObj;
                if ([collectOEFURI isEqualToString:oefURI])
                {
                    collectAtTimeOfPunch = YES;
                    break;
                }
            }
        }

        OEFType *oefType = [[OEFType alloc] initWithUri:oefDict[@"uri"] definitionTypeUri:oefDict[@"definitionTypeUri"] name:oefDict[@"name"] punchActionType:punchActionType numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:collectAtTimeOfPunch disabled:NO];

        [allOEFsArray addObject:oefType];
    }

    return allOEFsArray;
}

-(NSMutableArray *)setUpOEFObjects:(NSArray *)punchOEFArray punchActionType:(NSString *)punchActionType values:(NSArray *)valuesArray
{
    NSMutableArray *bindingURIArray = [NSMutableArray array];
    NSMutableArray *allOEFsArray = [NSMutableArray array];

    for (NSDictionary *oefDict in punchOEFArray)
    {

        NSString *oefURI = oefDict[@"uri"];

        BOOL collectAtTimeOfPunch = NO;
        BOOL disabled = NO;
        NSString *textValue = nil;
        NSString *numericValue = nil;
        NSString *dropdownOptionUri = nil;
        NSString *dropdownOptionValue = nil;

        for (NSDictionary *valuesDict in valuesArray)
        {
            NSDictionary *valuesOEFDict = valuesDict[@"definition"];
            NSString *valuesOEFURI = valuesOEFDict[@"uri"];

            if ([valuesOEFURI isEqualToString:oefURI])
            {

                NSString *definitionTypeUri = valuesDict[@"definitionTypeUri"];

                if ([definitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    if (valuesDict[@"textValue"]!=nil && ![valuesDict[@"textValue"] isKindOfClass:[NSNull class]])
                    {
                        textValue = valuesDict[@"textValue"];
                    }


                }
                else if ([definitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    if (valuesDict[@"numericValue"]!=nil && ![valuesDict[@"numericValue"] isKindOfClass:[NSNull class]])
                    {
                        numericValue = [valuesDict[@"numericValue"] stringValue];
                    }


                }

                else if ([definitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    if (valuesDict[@"tag"]!=nil && ![valuesDict[@"tag"] isKindOfClass:[NSNull class]])
                    {
                        dropdownOptionUri = valuesDict[@"tag"][@"uri"];
                        dropdownOptionValue = valuesDict[@"tag"][@"displayText"];
                    }


                }


                break;
            }

        }


        OEFType *oefType = [[OEFType alloc] initWithUri:oefDict[@"uri"] definitionTypeUri:oefDict[@"definitionTypeUri"] name:oefDict[@"displayText"] punchActionType:punchActionType numericValue:numericValue textValue:textValue dropdownOptionUri:dropdownOptionUri dropdownOptionValue:dropdownOptionValue collectAtTimeOfPunch:collectAtTimeOfPunch disabled:disabled];

        [bindingURIArray addObject:oefURI];
        [allOEFsArray addObject:oefType];

    }

    for (NSDictionary *disableOEFDict in valuesArray)
    {
        NSDictionary *valuesOEFDict = disableOEFDict[@"definition"];
        NSString *valuesOEFURI = valuesOEFDict[@"uri"];

        NSString *textValue = nil;
        NSString *numericValue = nil;
        NSString *dropdownOptionUri = nil;
        NSString *dropdownOptionValue = nil;

        if (![bindingURIArray containsObject:valuesOEFURI])
        {

            NSString *definitionTypeUri = disableOEFDict[@"definitionTypeUri"];

            if ([definitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
            {
                if (disableOEFDict[@"textValue"]!=nil && ![disableOEFDict[@"textValue"] isKindOfClass:[NSNull class]])
                {
                    textValue = disableOEFDict[@"textValue"];
                }


            }
            else if ([definitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
            {
                if (disableOEFDict[@"numericValue"]!=nil && ![disableOEFDict[@"numericValue"] isKindOfClass:[NSNull class]])
                {
                    numericValue = [disableOEFDict[@"numericValue"] stringValue];
                }


            }

            else if ([definitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
            {
                if (disableOEFDict[@"tag"]!=nil && ![disableOEFDict[@"tag"] isKindOfClass:[NSNull class]])
                {
                    dropdownOptionUri = disableOEFDict[@"tag"][@"uri"];
                    dropdownOptionValue = disableOEFDict[@"tag"][@"displayText"];
                }


            }

            OEFType *oefType = [[OEFType alloc] initWithUri:valuesOEFURI definitionTypeUri:valuesOEFDict[@"definitionTypeUri"] name:valuesOEFDict[@"displayText"] punchActionType:punchActionType numericValue:numericValue textValue:textValue dropdownOptionUri:dropdownOptionUri dropdownOptionValue:dropdownOptionValue collectAtTimeOfPunch:NO disabled:YES];
            
            
            [allOEFsArray addObject:oefType];
            
        }
        
    }
    
    return allOEFsArray;

}

#pragma mark - Helper Method

- (BOOL)isObjectNotEmpty:(id)object {
    return (object != nil && ![object isKindOfClass:[NSNull class]] && [object count] > 0);
}

@end
