
#import "OEFType.h"
#import "PunchActionTypes.h"


@interface OEFType ()

@property (nonatomic,copy) NSString *oefUri;
@property (nonatomic,copy) NSString *oefDefinitionTypeUri;
@property (nonatomic,copy) NSString *oefName;
@property (nonatomic,copy) NSString *oefPunchActionType;
@property (nonatomic,copy) NSString *oefNumericValue;
@property (nonatomic,copy) NSString *oefTextValue;
@property (nonatomic,copy) NSString *oefDropdownOptionUri;
@property (nonatomic,copy) NSString *oefDropdownOptionValue;
@property (nonatomic,assign) BOOL collectAtTimeOfPunch;
@property (nonatomic,assign) BOOL disabled;
@end

@implementation OEFType

- (instancetype)initWithUri:(NSString *)oefUri
          definitionTypeUri:(NSString *)oefDefinitionTypeUri
                       name:(NSString *)oefName
            punchActionType:(NSString *)oefPunchActionType
               numericValue:(NSString *)oefNumericValue
                  textValue:(NSString *)oefTextValue
          dropdownOptionUri:(NSString *)oefDropdownOptionUri
        dropdownOptionValue:(NSString *)oefDropdownOptionValue
       collectAtTimeOfPunch:(BOOL)collectAtTimeOfPunch
                   disabled:(BOOL)disabled {
    self = [super init];
    if (self) {
        self.oefUri = oefUri;
        self.oefDefinitionTypeUri = oefDefinitionTypeUri;
        self.oefName = oefName;
        self.oefPunchActionType = oefPunchActionType;
        self.oefNumericValue = [self getValueAfterCheckForNullForValue:oefNumericValue];
        self.oefTextValue = [self getValueAfterCheckForNullForValue:oefTextValue];
        self.oefDropdownOptionUri = [self getValueAfterCheckForNullForValue:oefDropdownOptionUri];
        self.oefDropdownOptionValue = [self getValueAfterCheckForNullForValue:oefDropdownOptionValue];
        self.collectAtTimeOfPunch = collectAtTimeOfPunch;
        self.disabled = disabled;


    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(OEFType *)otherOEFType
{
    BOOL typesAreEqual = [self isKindOfClass:[otherOEFType class]];
    if (!typesAreEqual) {
        return NO;
    }


    BOOL urisEqualOrBothNil = (!self.oefUri && !otherOEFType.oefUri) || ([self.oefUri isEqual:otherOEFType.oefUri]);
    BOOL definitionTypeUrisEqualOrBothNil = (!self.oefDefinitionTypeUri && !otherOEFType.oefDefinitionTypeUri) || ([self.oefDefinitionTypeUri isEqual:otherOEFType.oefDefinitionTypeUri]);
    BOOL namesEqualOrBothNil = (!self.oefName && !otherOEFType.oefName) || ([self.oefName isEqual:otherOEFType.oefName]);
    BOOL punchActionTypesEqualOrBothNil = (!self.oefPunchActionType && !otherOEFType.oefPunchActionType) || ([self.oefPunchActionType isEqual:otherOEFType.oefPunchActionType]);
    BOOL numericValuesEqualOrBothNil = (!self.oefNumericValue && !otherOEFType.oefNumericValue) || ([self.oefNumericValue isEqual:otherOEFType.oefNumericValue]);
    BOOL textValuesEqualOrBothNil = (!self.oefTextValue && !otherOEFType.oefTextValue) || ([self.oefTextValue isEqual:otherOEFType.oefTextValue]);
    BOOL dropdownOptionUrisEqualOrBothNil = (!self.oefDropdownOptionUri && !otherOEFType.oefDropdownOptionUri) || ([self.oefDropdownOptionUri isEqual:otherOEFType.oefDropdownOptionUri]);
    BOOL dropdownOptionValuesEqualOrBothNil = (!self.oefDropdownOptionValue && !otherOEFType.oefDropdownOptionValue) || ([self.oefDropdownOptionValue isEqual:otherOEFType.oefDropdownOptionValue]);
    BOOL collectAtTimeOfPunchEqual = (self.collectAtTimeOfPunch == otherOEFType.collectAtTimeOfPunch);
    BOOL disabledEqual = (self.disabled == otherOEFType.disabled);

    return urisEqualOrBothNil && definitionTypeUrisEqualOrBothNil && namesEqualOrBothNil && punchActionTypesEqualOrBothNil && numericValuesEqualOrBothNil && textValuesEqualOrBothNil && dropdownOptionUrisEqualOrBothNil && dropdownOptionValuesEqualOrBothNil && collectAtTimeOfPunchEqual && disabledEqual;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r oefUri: %@ \r oefDefinitionTypeUri: %@ \r oefName: %@ \r oefPunchActionType: %@ \r oefNumericValue: %@ \r oefTextValue: %@ \r oefDropdownOptionUri: %@ \r oefDropdownOptionValue: %@ \r collectAtTimeOfPunch: %d \r disabled: %d", NSStringFromClass([self class]),
                                      self.oefUri,
                                      self.oefDefinitionTypeUri,
                                      self.oefName,
                                      self.oefPunchActionType,
                                      self.oefNumericValue,
                                      self.oefTextValue,
                                      self.oefDropdownOptionUri,
                                      self.oefDropdownOptionValue,
                                      self.collectAtTimeOfPunch,
                                      self.disabled];
}

#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{

    NSString *oefUri = [decoder decodeObjectForKey:@"oefUri"];
    NSString *oefDefinitionTypeUri = [decoder decodeObjectForKey:@"oefDefinitionTypeUri"];
    NSString *oefName = [decoder decodeObjectForKey:@"oefName"];
    NSString *oefPunchActionType = [decoder decodeObjectForKey:@"oefPunchActionType"];
    NSString *oefNumericValue = [decoder decodeObjectForKey:@"oefNumericValue"];
    NSString *oefTextValue = [decoder decodeObjectForKey:@"oefTextValue"];
    NSString *oefDropdownOptionUri = [decoder decodeObjectForKey:@"oefDropdownOptionUri"];
    NSString *oefDropdownOptionValue = [decoder decodeObjectForKey:@"oefDropdownOptionValue"];
    BOOL collectAtTimeOfPunch = [decoder decodeBoolForKey:@"collectAtTimeOfPunch"];
    BOOL disabled = [decoder decodeBoolForKey:@"disabled"];

    return [self initWithUri:oefUri definitionTypeUri:oefDefinitionTypeUri name:oefName punchActionType:oefPunchActionType numericValue:oefNumericValue textValue:oefTextValue dropdownOptionUri:oefDropdownOptionUri dropdownOptionValue:oefDropdownOptionValue collectAtTimeOfPunch:collectAtTimeOfPunch disabled:disabled];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.oefUri forKey:@"oefUri"];
    [coder encodeObject:self.oefDefinitionTypeUri forKey:@"oefDefinitionTypeUri"];
    [coder encodeObject:self.oefName forKey:@"oefName"];
    [coder encodeObject:self.oefPunchActionType forKey:@"oefPunchActionType"];
    [coder encodeObject:self.oefNumericValue forKey:@"oefNumericValue"];
    [coder encodeObject:self.oefTextValue forKey:@"oefTextValue"];
    [coder encodeObject:self.oefDropdownOptionUri forKey:@"oefDropdownOptionUri"];
    [coder encodeObject:self.oefDropdownOptionValue forKey:@"oefDropdownOptionValue"];
    [coder encodeBool:self.collectAtTimeOfPunch forKey:@"collectAtTimeOfPunch"];
    [coder encodeBool:self.disabled forKey:@"disabled"];

}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSString *oefUriCopy = [self.oefUri copy];
    NSString *oefDefinitionTypeUriCopy = [self.oefDefinitionTypeUri copy];
    NSString *oefNameCopy = [self.oefName copy];
    NSString *oefPunchActionTypeCopy = [self.oefPunchActionType copy];
    NSString *oefNumericValueCopy = [self.oefNumericValue copy];
    NSString *oefTextValueCopy = [self.oefTextValue copy];
    NSString *oefDropdownOptionUriCopy = [self.oefDropdownOptionUri copy];
    NSString *oefDropdownOptionValueCopy = [self.oefDropdownOptionValue copy];
    BOOL collectAtTimeOfPunch = self.collectAtTimeOfPunch;
    BOOL disabled = self.disabled;
    return [[OEFType alloc] initWithUri:oefUriCopy definitionTypeUri:oefDefinitionTypeUriCopy name:oefNameCopy punchActionType:oefPunchActionTypeCopy numericValue:oefNumericValueCopy textValue:oefTextValueCopy dropdownOptionUri:oefDropdownOptionUriCopy dropdownOptionValue:oefDropdownOptionValueCopy collectAtTimeOfPunch:collectAtTimeOfPunch disabled:disabled];
    
}


#pragma mark - <Private>

-(id)getValueAfterCheckForNullForValue:(id)value
{
    if (value == nil || value == [NSNull null] || [value isEqualToString:@"<null>"] ) {
        return [NSNull null];
    }
    return value;
}


@end
