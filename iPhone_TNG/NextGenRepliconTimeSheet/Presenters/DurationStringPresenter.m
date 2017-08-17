#import "DurationStringPresenter.h"
#import "Theme.h"


@interface DurationStringPresenter ()

@property (nonatomic) id<Theme> theme;

@end


@implementation DurationStringPresenter

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (NSAttributedString *)durationStringWithHours:(NSUInteger)hours
                                        minutes:(NSUInteger)minutes
                                        seconds:(NSUInteger)seconds
{
    NSString *punchDurationText = [NSString stringWithFormat:RPLocalizedString(@"%dh : %02dm : %02ds", @"{hours}h : {minutes}m : {seconds}s"),
                                   hours,
                                   minutes,
                                   seconds];
    NSMutableAttributedString *punchDurationLabelAttributedString = [[NSMutableAttributedString alloc] initWithString:punchDurationText];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+)(h) (:) (\\d+)(m) (:) (\\d+)(s)" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:punchDurationText options:0 range: NSMakeRange(0, [punchDurationText length])];

    UIColor *textColor = [self.theme durationLabelTextColor];
    UIFont *bigNumberFont = [self.theme durationLabelBigNumberFont];
    UIFont *bigTimeUnitFont = [self.theme durationLabelBigTimeUnitFont];

    UIFont *littleNumberFont = [self.theme durationLabelLittleNumberFont];
    UIFont *littleTimeUnitFont = [self.theme durationLabelLittleTimeUnitFont];
    
    [punchDurationLabelAttributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [punchDurationLabelAttributedString length])];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:bigNumberFont range:[match rangeAtIndex:1]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:bigTimeUnitFont range:[match rangeAtIndex:2]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:bigNumberFont range:[match rangeAtIndex:3]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:bigNumberFont range:[match rangeAtIndex:4]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:bigTimeUnitFont range:[match rangeAtIndex:5]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:littleNumberFont range:[match rangeAtIndex:6]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:littleNumberFont range:[match rangeAtIndex:7]];
    [punchDurationLabelAttributedString addAttribute:NSFontAttributeName value:littleTimeUnitFont range:[match rangeAtIndex:8]];

    return [punchDurationLabelAttributedString copy];
}

- (NSString *)durationStringWithHours:(NSUInteger)hours minutes:(NSUInteger)minutes
{
    NSString *punchDurationText = [NSString stringWithFormat:RPLocalizedString(@"%dh:%02dm", @"{hours}h : {minutes}m"),
                                   hours,
                                   minutes];
    return [punchDurationText copy];
}



#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
