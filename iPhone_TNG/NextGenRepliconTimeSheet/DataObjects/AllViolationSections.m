#import "AllViolationSections.h"


@interface AllViolationSections ()

@property (nonatomic) NSUInteger totalViolationsCount;
@property (nonatomic) NSArray *sections;

@end


@implementation AllViolationSections

- (instancetype)initWithTotalViolationsCount:(NSUInteger)totalViolationsCount sections:(NSArray *)sections
{
    self = [super init];
    if (self)
    {
        self.totalViolationsCount = totalViolationsCount;
        self.sections = sections;
    }
    return self;
}

@end
