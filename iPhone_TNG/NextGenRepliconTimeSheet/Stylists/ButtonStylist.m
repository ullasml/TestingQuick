#import "ButtonStylist.h"
#import "Theme.h"


@interface ButtonStylist ()

@property (nonatomic) id<Theme> theme;

@end


@implementation ButtonStylist

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (void)styleButton:(UIButton *)button
              title:(NSString *)title
         titleColor:(UIColor *)titleColor
    backgroundColor:(UIColor *)backgroundColor
        borderColor:(UIColor *)borderColor
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    button.layer.cornerRadius = CGRectGetHeight(button.bounds) / 2.0f;
    button.backgroundColor = backgroundColor;
    button.titleLabel.font = [self.theme regularButtonFont];
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = borderColor.CGColor;
}

- (void)styleRegularButton:(UIButton *)button
                     title:(NSString *)title
{
    UIColor *backgroundColor = [self.theme regularButtonBackgroundColor];
    UIColor *titleColor = [self.theme regularButtonTitleColor];
    UIColor *borderColor = [self.theme regularButtonBorderColor];

    [self styleButton:button
                title:title
           titleColor:titleColor
      backgroundColor:backgroundColor
          borderColor:borderColor];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
