
#import "PreviousApprovalsButtonViewController.h"
#import "ButtonStylist.h"
#import "DefaultTheme.h"


@interface PreviousApprovalsButtonViewController ()

@property (nonatomic, weak) id <PreviousApprovalsButtonControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *viewPreviousApprovalsButton;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) id<Theme> theme;
@property (weak, nonatomic) IBOutlet UIView *topLineView;

@end

@implementation PreviousApprovalsButtonViewController

- (instancetype)initWithDelegate:(id <PreviousApprovalsButtonControllerDelegate>)delegate
                   buttonStylist:(ButtonStylist *)buttonStylist
                           theme:(id <Theme>)theme {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.theme = theme;
        self.buttonStylist = buttonStylist;
        self.title = RPLocalizedString(@"View Previous Approvals", nil);
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *titleColor = [self.theme viewPreviousApprovalsButtonTitleColor];
    UIColor *backgroundColor = [self.theme viewPreviousApprovalsButtonBackgroundColor];
    UIColor *borderColor = [self.theme viewPreviousApprovalsButtonBorderColor];
    self.topLineView.backgroundColor = borderColor;
    [self.buttonStylist styleButton:self.viewPreviousApprovalsButton
                              title:self.title
                         titleColor:titleColor
                    backgroundColor:backgroundColor
                        borderColor:borderColor];
}


#pragma mark - Private

- (IBAction)didTapViewTimesheetPeriod:(id)sender {
    [self.delegate approvalsButtonControllerWillNavigateToPreviousApprovalsScreen:self];
}

@end
