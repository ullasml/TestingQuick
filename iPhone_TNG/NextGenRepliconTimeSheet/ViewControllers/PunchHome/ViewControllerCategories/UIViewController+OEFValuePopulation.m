//
//  UIViewController+OEFValuePopulation.m
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 07/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "UIViewController+OEFValuePopulation.h"
#import "OEFType.h"
#import "Constants.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSInitializer.h>
#import "OEFValidator.h"

typedef enum {
    TextOEFTypeOnAddScreen = 1,
    NumericOEFTypeOnAddScreen = 2,
    DropDownOEFTypeOnAddScreen = 3,
    TextOEFTypeDefault = 4,
    NumericOEFTypeDefault = 5,
    DropDownOEFTypeDefault = 6,
    OEFCategoryDefault = 7
}OEFCategoryBasedOnScreenType;

@implementation UIViewController (OEFValuePopulation)

#pragma mark - OEFType category classification

- (OEFCategoryBasedOnScreenType)getOEFCategoryBasedOnScreenTypeFromOEFType:(OEFType *)oefType
                                                  punchAttributeScreenType:(PunchAttributeScreentype)punchAttributeScreenType {
    
    OEFCategoryBasedOnScreenType oefCategory = OEFCategoryDefault;
    NSString *uri = oefType.oefDefinitionTypeUri;
    
    if([uri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI] && punchAttributeScreenType == PunchAttributeScreenTypeADD) {
        oefCategory = TextOEFTypeOnAddScreen;
    }
    else if([uri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI] && punchAttributeScreenType == PunchAttributeScreenTypeADD) {
        oefCategory = NumericOEFTypeOnAddScreen;
    }
    else if([uri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI] && punchAttributeScreenType == PunchAttributeScreenTypeADD) {
        oefCategory = DropDownOEFTypeOnAddScreen;
    }
    else if(punchAttributeScreenType == PunchAttributeScreenTypeNONE) {
        
        if([uri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]) {
            oefCategory = TextOEFTypeDefault;
        }
        else if([uri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI] ) {
            oefCategory = NumericOEFTypeDefault;
        }
        else if([uri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI]) {
            oefCategory = DropDownOEFTypeDefault;
        }
    }
    return oefCategory;
}

- (ObjectExtensionFieldType)getObjectExtensionFieldTypeFromOEFTypeObject:(OEFType *)oefType {
    
    ObjectExtensionFieldType objectExtensionFieldType = ObjectExtensionFieldTypeNone;
    NSString *uri = oefType.oefDefinitionTypeUri;
    if([uri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]) {
        objectExtensionFieldType = TextOEFType;
    }
    else if([uri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
        objectExtensionFieldType = NumberOEFType;
    }
    else if([uri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI]) {
        objectExtensionFieldType = DropDownOEFType;
    }
    return objectExtensionFieldType;
}

#pragma mark -

- (NSString *)getPlaceholderTextByOEFType:(OEFType *)oefType screenType:(PunchAttributeScreentype)screenType {
    
    OEFCategoryBasedOnScreenType oefCategorybasedOnScreenType = [self getOEFCategoryBasedOnScreenTypeFromOEFType:oefType
                                                                                        punchAttributeScreenType:screenType];
    
    NSString *oefTextViewPlaceHolderText = @"";
    
    switch (oefCategorybasedOnScreenType) {
        case NumericOEFTypeOnAddScreen:
        case NumericOEFTypeDefault :
            oefTextViewPlaceHolderText = RPLocalizedString(NumericOEFPlaceholder, @"");
            break;
            
        case TextOEFTypeOnAddScreen:
        case TextOEFTypeDefault:
            oefTextViewPlaceHolderText = RPLocalizedString(TextOEFPlaceholder, @"");
            break;
            
        case DropDownOEFTypeOnAddScreen:
        case DropDownOEFTypeDefault:
            oefTextViewPlaceHolderText = RPLocalizedString(DropDownOEFPlaceholder, @"");
            break;
            
        default:
            oefTextViewPlaceHolderText = RPLocalizedString(@"None", @"");
            break;
    }
    return oefTextViewPlaceHolderText;
}


- (OEFType *)getUpdatedOEFTypeFromOEFTypeObject:(OEFType *)oefType textView:(UITextView *)textView {
    NSString *numericValue = nil;
    NSString *textValue = nil;
    ObjectExtensionFieldType oefType_ = [self getObjectExtensionFieldTypeFromOEFTypeObject:oefType];
    switch (oefType_) {
        case TextOEFType:
            textValue = textView.text;
            break;
        case NumberOEFType:
            numericValue = textView.text;
            break;
        case DropDownOEFType:
            // Do Nothing
            break;
        default:
            break;
    }
    
    OEFType *newOEFType = [[OEFType alloc] initWithUri:oefType.oefUri definitionTypeUri:oefType.oefDefinitionTypeUri name:oefType.oefName punchActionType:oefType.oefPunchActionType numericValue:numericValue textValue:textValue dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:oefType.collectAtTimeOfPunch disabled:oefType.disabled];
    
    return newOEFType;
}

#pragma mark - OEFValidation

- (NSError *)validateOEFType:(OEFType *)oefType injector:(id <BSInjector>)injector {
    
    OEFValidator *oefValidator = [injector getInstance:[OEFValidator class]];
    NSError *validationError = [oefValidator validateOEF:oefType];
    return validationError;
}


@end
