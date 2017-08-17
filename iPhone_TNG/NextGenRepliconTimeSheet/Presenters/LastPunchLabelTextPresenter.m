#import "LastPunchLabelTextPresenter.h"


@interface LastPunchLabelTextPresenter()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation LastPunchLabelTextPresenter

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.dateFormatter = dateFormatter;
    }

    return self;
}

- (NSString *)lastPunchLabelTextWithDate:(NSDate *)date
                            formatString:(NSString *)formatString
{
    NSString *localTimeString = [self.dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:formatString, localTimeString];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
