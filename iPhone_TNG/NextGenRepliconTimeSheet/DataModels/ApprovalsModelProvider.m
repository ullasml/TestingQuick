#import "ApprovalsModelProvider.h"
#import "ApprovalsModel.h"

@implementation ApprovalsModelProvider

- (ApprovalsModel *)provideInstance
{
    return [[ApprovalsModel alloc] init];
}

@end
