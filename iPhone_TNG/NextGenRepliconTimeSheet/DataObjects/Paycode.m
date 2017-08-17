
#import "Paycode.h"

@interface Paycode()
@property (nonatomic) NSString *textValue;
@property (nonatomic) NSString *titleText;
@property (nonatomic) NSString *titleValueWithSeconds;

@end

@implementation Paycode

- (instancetype)initWithValue:(NSString *)textValue
                        title:(NSString *)titleText
                  timeSeconds:(NSString *)valueWithSeconds {
    self = [super init];
    if (self)
    {
        self.textValue = textValue;
        self.titleText = titleText;
        self.titleValueWithSeconds = valueWithSeconds;
    }
    return self;
    
}

#pragma mark - NSObject

- (BOOL)isEqual:(Paycode *)otherPayCode
{
    BOOL typesAreEqual = [self isKindOfClass:[Paycode class]];
    if (!typesAreEqual) {
        return NO;
    }
    
    BOOL textValueEqualOrBothNil = (!self.textValue && !otherPayCode.textValue) || ([self.textValue isEqual:otherPayCode.textValue]);
    BOOL titlesEqualOrBothNil = (!self.titleText && !otherPayCode.titleText) || ([self.titleText isEqual:otherPayCode.titleText]);
    BOOL titleValueWithSecondsEqualOrBothNil = (!self.titleValueWithSeconds && !otherPayCode.titleValueWithSeconds) || ([self.titleValueWithSeconds isEqual:otherPayCode.titleValueWithSeconds]);

    return textValueEqualOrBothNil && titlesEqualOrBothNil && titleValueWithSecondsEqualOrBothNil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>: textValue: %@, titleText: %@, titleValueWithSeconds: %@", NSStringFromClass([self class]),
            self.textValue,
            self.titleText,
            self.titleValueWithSeconds];
}


@end
