#import <Foundation/Foundation.h>
@protocol Theme;

@interface ApprovalStatusPresenter : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>) theme NS_DESIGNATED_INITIALIZER;

- (UIColor *)colorForStatus:(NSString *)status;

@end
