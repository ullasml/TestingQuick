

#import "PunchCardStylist.h"
#import "Theme.h"

@interface PunchCardStylist ()

@property (nonatomic) id <Theme> theme;

@end

@implementation PunchCardStylist

- (instancetype)initWithTheme:(id <Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)styleBorderForView:(UIView *)view
{
    view.layer.cornerRadius = [self.theme carouselPunchCardCornerRadius];
    view.layer.borderColor = [self.theme carouselPunchCardContainerBorderColor];
    view.layer.borderWidth = [self.theme carouselPunchCardContainerBorderWidth];
}

-(void)styleBorderForOEFView:(UIView *)view
{
    view.layer.cornerRadius = [self.theme oefPunchCardCornerRadius];
    view.layer.borderColor = [self.theme oefPunchCardContainerBorderColor];
    view.layer.borderWidth = [self.theme oefPunchCardContainerBorderWidth];
}

@end
