#import <UIKit/UIKit.h>

@protocol Theme;

@interface NavigationBarStylist : NSObject

@property (nonatomic, readonly) UIBarButtonItem *barButtonItemAppearance;
@property (nonatomic, readonly) UINavigationBar *navigationBarAppearance;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithBarButtonItemAppearance:(UIBarButtonItem *)barButtonItemAppearance
                        navigationBarAppearance:(UINavigationBar *)navigationBarAppearance
                                          theme:(id<Theme>)theme;
- (void)styleNavigationBar;

@end
