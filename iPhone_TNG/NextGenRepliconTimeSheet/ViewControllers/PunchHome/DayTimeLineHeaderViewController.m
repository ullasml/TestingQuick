
#import "DayTimeLineHeaderViewController.h"

@interface DayTimeLineHeaderViewController ()
@property (weak, nonatomic) IBOutlet UIView *descendingLineView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@end

@implementation DayTimeLineHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.widthConstraint.constant = self.view.bounds.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
