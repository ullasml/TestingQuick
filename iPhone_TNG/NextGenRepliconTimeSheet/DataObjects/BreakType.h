#import <Foundation/Foundation.h>


@interface BreakType : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *uri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithName:(NSString *)name
                         uri:(NSString *)uri NS_DESIGNATED_INITIALIZER;
@end
