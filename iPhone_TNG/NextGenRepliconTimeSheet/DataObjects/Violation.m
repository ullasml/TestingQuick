#import "Violation.h"


@interface Violation ()

@property (nonatomic) NSString *title;
@property (nonatomic) ViolationSeverity severity;
@property (nonatomic) Waiver *waiver;

@end


@implementation Violation

- (instancetype)initWithSeverity:(ViolationSeverity)severity
                          waiver:(Waiver *)waiver
                           title:(NSString *)title;
{
    self = [super init];
    if (self) {
        self.title = title;
        self.severity = severity;
        self.waiver = waiver;
    }
    return self;
}

@end
