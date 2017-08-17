#import <Foundation/Foundation.h>


@interface PunchLog : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, copy, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end
