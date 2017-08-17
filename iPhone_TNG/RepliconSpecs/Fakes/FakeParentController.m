#import "FakeParentController.h"


@implementation FakeParentController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.containerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.containerView];
}

@end
