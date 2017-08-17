#import "WaiverOption.h"


@interface WaiverOption ()

@property (nonatomic, copy) NSString *displayText;
@property (nonatomic, copy) NSString *value;

@end


@implementation WaiverOption

- (instancetype)initWithDisplayText:(NSString *)displayText
                              value:(NSString *)value
{
    self = [super init];
    if (self) {
        self.displayText = displayText;
        self.value = value;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
