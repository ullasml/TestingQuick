#import <Foundation/Foundation.h>


@interface CurrencyValue : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *currencyDisplayText;
@property (nonatomic, readonly) NSNumber *amount;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCurrencyDisplayText:(NSString *)currencyDisplayText
                                     amount:(NSNumber *)amount NS_DESIGNATED_INITIALIZER;

@end
