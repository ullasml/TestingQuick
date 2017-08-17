
#import <Foundation/Foundation.h>

@interface GrossHours : NSObject<NSCopying>
@property (nonatomic, readonly) NSString *hours;
@property (nonatomic, readonly) NSString *minutes;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithHours:(NSString *)hours
                      minutes:(NSString *)minutes NS_DESIGNATED_INITIALIZER;

@end
