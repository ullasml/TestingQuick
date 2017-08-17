#import "BookedTimeOff.h"


@interface BookedTimeOff ()

@property (nonatomic, copy) NSString *descriptionText;

@end


@implementation BookedTimeOff

- (instancetype)initWithDescriptionText:(NSString *)descriptionText
{
    self = [super init];
    if (self) {
        self.descriptionText = descriptionText;

    }
    return self;
}

#pragma mark - NSObject

- (BOOL) isEqual:(BookedTimeOff *)otherBookedTimeOff
{
    if(![otherBookedTimeOff isKindOfClass:[self class]]) {
        return NO;
    }

    BOOL descriptionTextsEqual = (!self.descriptionText && !otherBookedTimeOff.descriptionText) || [self.descriptionText isEqualToString:otherBookedTimeOff.descriptionText];

    return descriptionTextsEqual;
}

@end
