
#import <Foundation/Foundation.h>

@interface Paycode : NSObject
@property (nonatomic, readonly) NSString *textValue;
@property (nonatomic, readonly) NSString *titleText;
@property (nonatomic, readonly) NSString *titleValueWithSeconds;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithValue:(NSString *)textValue
                        title:(NSString *)titleText
                  timeSeconds:(NSString *)valueWithSeconds NS_DESIGNATED_INITIALIZER;

@end
