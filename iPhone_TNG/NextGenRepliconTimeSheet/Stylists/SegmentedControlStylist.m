#import "SegmentedControlStylist.h"
#import "Theme.h"


@interface SegmentedControlStylist ()

@property (nonatomic) id <Theme> theme;

@end


@implementation SegmentedControlStylist

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

- (void)styleSegmentedControl:(UISegmentedControl *)segmentedControl{
    segmentedControl.tintColor = [self.theme segmentedControlTintColor];

    NSDictionary *attributes = @{
                                 NSFontAttributeName : [self.theme segmentedControlFont],
                                 NSForegroundColorAttributeName : [self.theme segmentedControlTextColor],
                                 };
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

@end
