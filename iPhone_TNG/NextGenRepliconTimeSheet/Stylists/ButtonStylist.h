#import <UIKit/UIKit.h>


@protocol Theme;


@interface ButtonStylist : NSObject

@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme;

- (void)styleButton:(UIButton *)button
              title:(NSString *)title
         titleColor:(UIColor *)titleColor
    backgroundColor:(UIColor *)backgroundColor
        borderColor:(UIColor *)borderColor;

- (void)styleRegularButton:(UIButton *)button
                     title:(NSString *)title;

@end
