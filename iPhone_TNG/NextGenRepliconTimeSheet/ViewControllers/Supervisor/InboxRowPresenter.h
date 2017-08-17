#import <Foundation/Foundation.h>

@interface InboxRowPresenter : NSObject

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) UIViewController *controller;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithText:(NSString *)text controller:(UIViewController *)controller NS_DESIGNATED_INITIALIZER;

@end
