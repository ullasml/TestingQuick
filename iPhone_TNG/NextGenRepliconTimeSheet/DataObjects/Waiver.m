#import "Waiver.h"
#import "WaiverOption.h"


@interface Waiver ()

@property (nonatomic, copy) NSString *URI;
@property (nonatomic, copy) NSString *displayText;
@property (nonatomic, copy) NSArray *options;
@property (nonatomic) WaiverOption *selectedOption;

@end


@implementation Waiver

- (instancetype)initWithURI:(NSString *)URI
                displayText:(NSString *)displayText
                    options:(NSArray *)options
             selectedOption:(WaiverOption *)selectedOption
{
    self = [super init];
    if (self)
    {
        self.URI = URI;
        self.displayText = displayText;
        self.options = options;
        self.selectedOption = selectedOption;
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
    return [NSString stringWithFormat:@"<%@: URI: %@>", NSStringFromClass([self class]), self.URI];
}

@end
