#import "CurrencyValue.h"


@interface CurrencyValue ()

@property (nonatomic, copy) NSString *currencyDisplayText;
@property (nonatomic) NSNumber *amount;

@end


@implementation CurrencyValue

- (instancetype)initWithCurrencyDisplayText:(NSString *)currencyDisplayText
                                     amount:(NSNumber *)amount
{
    self = [super init];
    if (self)
    {
        self.currencyDisplayText = currencyDisplayText;
        self.amount = amount;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r currencyDisplayText: %@ \r amount: %@", NSStringFromClass([self class]),
            self.currencyDisplayText,
            self.amount];
}

-(BOOL)isEqual:(CurrencyValue *)otherPunchUser
{
    if(![otherPunchUser isKindOfClass:[self class]]) {
        return NO;
    }
    BOOL currencyDisplayTextEqual = (!self.currencyDisplayText && !otherPunchUser.currencyDisplayText) || [self.currencyDisplayText isEqualToString:otherPunchUser.currencyDisplayText];
    BOOL amountEqual = (!self.amount && !otherPunchUser.amount) || [self.amount isEqual:otherPunchUser.amount];
    return ( currencyDisplayTextEqual && amountEqual);
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[CurrencyValue alloc] initWithCurrencyDisplayText:[self.currencyDisplayText copy]
                                                       amount:[self.amount copy]];
    
}


@end
