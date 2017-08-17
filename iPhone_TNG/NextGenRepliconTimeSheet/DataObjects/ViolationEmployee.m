#import "ViolationEmployee.h"


@interface ViolationEmployee ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSArray *violations;

@end


@implementation ViolationEmployee

- (instancetype)initWithName:(NSString *)name
                         uri:(NSString *)uri
                  violations:(NSArray *)violations
{
    self = [super init];
    if (self) {
        self.name = name;
        self.uri = uri;
        self.violations = violations;
    }
    return self;
}

@end
