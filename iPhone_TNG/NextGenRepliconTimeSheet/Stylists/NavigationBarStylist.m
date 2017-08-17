#import "NavigationBarStylist.h"
#import "Theme.h"


@interface NavigationBarStylist ()

@property (nonatomic) UIBarButtonItem *barButtonItemAppearance;
@property (nonatomic) UINavigationBar *navigationBarAppearance;
@property (nonatomic) id<Theme> theme;

@end


@implementation NavigationBarStylist

- (instancetype)initWithBarButtonItemAppearance:(UIBarButtonItem *)barButtonItemAppearance
                        navigationBarAppearance:(UINavigationBar *)navigationBarAppearance
                                          theme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.barButtonItemAppearance = barButtonItemAppearance;
        self.navigationBarAppearance = navigationBarAppearance;
        self.theme = theme;
    }
    return self;
}

- (void)styleNavigationBar
{
    NSDictionary *attributeDict = @{NSFontAttributeName:self.theme.navigationBarTitleFont};
    [self.barButtonItemAppearance setTitleTextAttributes:attributeDict
                                                forState:UIControlStateNormal];
    [self.navigationBarAppearance setTintColor:self.theme.navigationBarTintColor];
}

@end
