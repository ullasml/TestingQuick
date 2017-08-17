#import "ViolationSection.h"


@interface ViolationSection ()

@property (nonatomic) id titleObject;
@property (nonatomic) NSArray *violations;
@property(nonatomic) ViolationSectionType type;

@end


@implementation ViolationSection

- (instancetype)initWithTitleObject:(id)titleObject violations:(NSArray *)violations type:(ViolationSectionType)type
{
    self = [super init];
    if (self) {
        self.titleObject = titleObject;
        self.violations = violations;
        self.type = type;
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
