#import "WorkHoursPresenter.h"


@interface WorkHoursPresenter ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
@property (nonatomic) UIColor *textColor;
@property (nonatomic, copy) NSString *image;


@end


@implementation WorkHoursPresenter

- (instancetype)initWithTitle:(NSString *)title
                    textColor:(UIColor *)textColor
                        image:(NSString *)image
                        value:(NSString *)value {
    self = [super init];
    if (self) {
        self.title = title;
        self.value = value;
        self.image = image;
        self.textColor = textColor;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(WorkHoursPresenter *)otherTimeSummaryPresenter
{
    if(![otherTimeSummaryPresenter isKindOfClass:[self class]]) {
        return NO;
    }

    BOOL sameTitleEqual = (!otherTimeSummaryPresenter.title && !self.title) || [otherTimeSummaryPresenter.title isEqualToString:self.title];
    BOOL sameValueEqual = (!otherTimeSummaryPresenter.value && !self.value) || [otherTimeSummaryPresenter.value isEqualToString:self.value];
    BOOL sameColorEqual = (!otherTimeSummaryPresenter.textColor && !self.textColor) || [otherTimeSummaryPresenter.textColor isEqual:self.textColor];
    BOOL sameImageEqual = (!otherTimeSummaryPresenter.image && !self.image) || [otherTimeSummaryPresenter.image isEqualToString:self.image];

    return sameTitleEqual && sameValueEqual && sameColorEqual && sameImageEqual;
}

- (NSUInteger)hash
{
    NSUInteger result = 1;
    NSUInteger prime = 31;

    result = prime * result + [self.title hash];
    result = prime * result + [self.value hash];
    result = prime * result + [self.textColor hash];

    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<%@>: "
            @"title: %@, "
            @"value: %@"
            @"textColor: %@",
            NSStringFromClass([self class]),
            self.title,
            self.value,
            self.textColor];
}

@end
