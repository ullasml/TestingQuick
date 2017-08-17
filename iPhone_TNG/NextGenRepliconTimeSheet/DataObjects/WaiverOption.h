#import <Foundation/Foundation.h>


@interface WaiverOption : NSObject

@property (nonatomic, copy, readonly) NSString *displayText;
@property (nonatomic, copy, readonly) NSString *value;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDisplayText:(NSString *)displayText
                              value:(NSString *)value NS_DESIGNATED_INITIALIZER;

@end
