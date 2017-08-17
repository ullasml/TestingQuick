#import "SearchTextFieldStylist.h"
#import "Theme.h"


@interface SearchTextFieldStylist ()

@property(nonatomic) id<Theme> theme;

@end


@implementation SearchTextFieldStylist

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (void)applyThemeToTextField:(UITextField *)textField
{
    textField.font = [self.theme searchTextFieldFont];
    textField.backgroundColor = [self.theme searchTextFieldBackgroundColor];
}


@end
