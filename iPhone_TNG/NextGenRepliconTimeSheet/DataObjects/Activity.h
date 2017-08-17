
#import <Foundation/Foundation.h>

@interface Activity : NSObject <NSCoding, NSCopying>

@property (nonatomic,readonly,copy)NSString *name;
@property (nonatomic,readonly,copy)NSString *uri;
@property (nonatomic, assign) BOOL isActivityRequired;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithName:(NSString *)name
                         uri:(NSString *)uri NS_DESIGNATED_INITIALIZER;

@end
