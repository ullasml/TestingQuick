#import "PunchLog.h"


@interface PunchLog ()

@property (nonatomic, copy) NSString *text;

@end


@implementation PunchLog

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        self.text = text;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: text: %@>", NSStringFromClass([self class]), self.text];
}

@end
