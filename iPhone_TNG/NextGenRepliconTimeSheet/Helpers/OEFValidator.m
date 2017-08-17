//
//  OEFValidator.m
//  NextGenRepliconTimeSheet


#import "OEFValidator.h"
#import "OEFType.h"
#import "Constants.h"

#define RANGE_VALUE_TO_APPEND                   @"9"
#define DEFAULT_OEF_MAX_PRECESION               14
#define DEFAULT_OEF_MAX_SCALE                   4
#define DEFAULT_OEF_MAX_TEXT_FIELD_CHAR_LIMIT   255

@interface OEFValidator()

@property (nonatomic) NSUserDefaults *userDefaults;

@end

@implementation OEFValidator

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults {
    
    self = [super init];
    if(self) {
        self.userDefaults = userDefaults;
    }
    return self;
}

- (NSError *)validateOEF:(OEFType *)oefType {
    NSError *error = nil;
    ObjectExtensionFieldType oefFieldType = [self getObjectExtensionFieldType:oefType];
    switch (oefFieldType) {
        case TextOEFType:
            error = [self validateTextOEFField:oefType];
            break;
        case NumberOEFType:
            error = [self validateNumberOEFField:oefType];
            break;
        default:
            break;
    }
    return error;
}

#pragma mark - Private

- (NSError *)validateNumberOEFField:(OEFType *)oefType {
    NSError *error = nil;
    NSNumber *oefTypeNumberMaxPrecision = [self getMaxPrecision];
    NSNumber *oefTypeNumberMaxScale = [self getMaxScale];
    
    BOOL isNumberValueWithinRange = [self isNumberWithRange:oefType.oefNumericValue
                                               maxPrecision:oefTypeNumberMaxPrecision
                                                   maxScale:oefTypeNumberMaxScale];
    
    if(!isNumberValueWithinRange) {
        
        NSString *finalRange = [self getFinalOEFTypeNumberValueRangeWithMaxPrecision:oefTypeNumberMaxPrecision maxScale:oefTypeNumberMaxScale];
        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), finalRange, finalRange];
        NSString *message = [NSString stringWithFormat:@"%@", localizedString];
        error = [Util errorWithDomain:@"" message:message];
    }
    
    return error;
}

- (NSError *)validateTextOEFField:(OEFType *)oefType {
    NSError *error = nil;
    NSNumber *textFieldMaxCharLimit = [self getMaxTextFieldCharLimit];
    
    NSString *regex = [NSString stringWithFormat:@"^.{0,%d}$", [textFieldMaxCharLimit intValue]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    BOOL isCharCountWithinRange = [predicate evaluateWithObject:oefType.oefTextValue];
    
    if(!isCharCountWithinRange) {
        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFTextFieldValueLimitExceededError, nil), [textFieldMaxCharLimit stringValue]];
        NSString *message = [NSString stringWithFormat:@"%@", localizedString];
        error = [Util errorWithDomain:@"" message:message];
    }
    
    return error;
}

#pragma mark - ENUM Classification Method

- (ObjectExtensionFieldType)getObjectExtensionFieldType:(OEFType *)oefType {
    
    ObjectExtensionFieldType objectExtensionFieldType = ObjectExtensionFieldTypeNone;
    NSString *oefTypeDefinitionUri = oefType.oefDefinitionTypeUri;
    
    if([oefTypeDefinitionUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]) {
        objectExtensionFieldType = TextOEFType;
    }
    else if([oefTypeDefinitionUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
        objectExtensionFieldType = NumberOEFType;
    }
    return objectExtensionFieldType;
}

#pragma mark - Helper Methods

- (NSString *)getWholeNumberPrecisionRangeWithMaxPrecision:(NSNumber *)maxPrecesion maxScale:(NSNumber *)maxScale {
    int precesionRange = [maxPrecesion intValue] - [maxScale intValue];
    NSString *wholeNumberPrecisionValue = @"";
    int i=0;
    
    while(i < precesionRange) {
        wholeNumberPrecisionValue = [wholeNumberPrecisionValue stringByAppendingString:RANGE_VALUE_TO_APPEND];
        i++;
    }
    return wholeNumberPrecisionValue;
}

- (NSString *)getdecimalNumberPrecisionRangeWithMaxScale:(NSNumber *)maxScale {
    NSString *decimalNumberPrecisionValue = @"";
    int decimalPrecesionRange = [maxScale intValue];
    int i=0;
    
    while(i < decimalPrecesionRange) {
        decimalNumberPrecisionValue = [decimalNumberPrecisionValue stringByAppendingString:RANGE_VALUE_TO_APPEND];
        i++;
    }
    return decimalNumberPrecisionValue;
}

- (NSString *)getFinalOEFTypeNumberValueRangeWithMaxPrecision:(NSNumber *)maxPrecision maxScale:(NSNumber *)maxScale {
    NSString *wholeNumberPrecisionRange = [self getWholeNumberPrecisionRangeWithMaxPrecision:maxPrecision maxScale:maxScale];
    NSString *decimalNumberPrecisionRange = [self getdecimalNumberPrecisionRangeWithMaxScale:maxScale];
    NSString *finalOEFTypeNumberValueRange = [wholeNumberPrecisionRange stringByAppendingString:[NSString stringWithFormat:@".%@", decimalNumberPrecisionRange]];
    return finalOEFTypeNumberValueRange;
}

- (BOOL)isNumberWithRange:(NSString *)oefNumericValue maxPrecision:(NSNumber *)maxPrecision maxScale:(NSNumber *)maxScale {
    BOOL isNumberWithinRange = FALSE;
    NSString *range = [self getFinalOEFTypeNumberValueRangeWithMaxPrecision:maxPrecision maxScale:maxScale];
    double initialRange = [[NSString stringWithFormat:@"-%@", range] doubleValue];
    double finalRange = [range doubleValue];
    double oefNumericValue_ = [oefNumericValue doubleValue];
    
    if(oefNumericValue_ >= initialRange && oefNumericValue_ <= 0.0) {
        isNumberWithinRange = TRUE;
    }
    else if(oefNumericValue_ >= 0.0 && oefNumericValue_ <= finalRange) {
        isNumberWithinRange = TRUE;
    }
    
    return isNumberWithinRange;
    
}

- (NSNumber *)getMaxPrecision {
    NSNumber *maxPrecision = [self.userDefaults objectForKey:OEFMaxPrecisionKey];
    if(!maxPrecision) {
        maxPrecision = [NSNumber numberWithInt:DEFAULT_OEF_MAX_PRECESION];
    }
    return maxPrecision;
}

- (NSNumber *)getMaxScale {
    NSNumber *maxScale = [self.userDefaults objectForKey:OEFMaxScaleKey];
    if(!maxScale) {
        maxScale = [NSNumber numberWithInt:DEFAULT_OEF_MAX_SCALE];
    }
    return maxScale;
}

- (NSNumber *)getMaxTextFieldCharLimit {
    NSNumber *maxTextCharLimit = [self.userDefaults objectForKey:OEFMaxTextCharLimitKey];
    if(!maxTextCharLimit) {
        maxTextCharLimit = [NSNumber numberWithInt:DEFAULT_OEF_MAX_TEXT_FIELD_CHAR_LIMIT];
    }
    return maxTextCharLimit;
}

@end
