#import <Foundation/Foundation.h>

@interface BookedTimeOff : NSObject

@property (nonatomic, copy, readonly) NSString *descriptionText;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDescriptionText:(NSString *)descriptionText NS_DESIGNATED_INITIALIZER;

@end
