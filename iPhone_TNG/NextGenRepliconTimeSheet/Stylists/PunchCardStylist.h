
#import <Foundation/Foundation.h>

@protocol Theme;

@interface PunchCardStylist : NSObject

@property (nonatomic,readonly) id <Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)styleBorderForView:(UIView *)view;
-(void)styleBorderForOEFView:(UIView *)view;
@end