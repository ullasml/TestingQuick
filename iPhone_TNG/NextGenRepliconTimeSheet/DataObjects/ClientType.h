
#import <Foundation/Foundation.h>

@interface ClientType : NSObject<NSCoding, NSCopying>

@property (nonatomic,readonly,copy) NSString *name;
@property (nonatomic,readonly,copy) NSString *uri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(NSString *)name
                         uri:(NSString *)uri NS_DESIGNATED_INITIALIZER;

@end
