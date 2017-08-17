#import "PayCodeDuration.h"

@interface PayCodeDuration()
@property (nonatomic) NSString *textValue;
@property (nonatomic) NSString *titleText;
@end

@implementation PayCodeDuration

- (instancetype)initWithAmount:(NSString *)textValue
title:(NSString *)titleText
{
    self = [super init];
    if (self)
    {
        self.textValue = textValue;
        self.titleText = titleText;
    }
    return self;
    
}
@end
