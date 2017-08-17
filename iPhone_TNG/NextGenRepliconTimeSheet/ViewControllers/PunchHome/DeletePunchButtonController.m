#import "DeletePunchButtonController.h"
#import "ButtonStylist.h"
#import "Theme.h"


@interface DeletePunchButtonController ()

@property (nonatomic, weak) id <DeletePunchButtonControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *deletePunchButton;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) id<Theme> theme;

@end

@implementation DeletePunchButtonController

- (instancetype)initWithButtonStylist:(ButtonStylist *)buttonStylist
                                theme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.buttonStylist = buttonStylist;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithDelegate:(id <DeletePunchButtonControllerDelegate>) delegate
{
    self.delegate = delegate;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.buttonStylist styleButton:self.deletePunchButton
                              title:RPLocalizedString(@"Delete Punch", nil)
                         titleColor:[self.theme deletePunchButtonTitleColor]
                    backgroundColor:[self.theme deletePunchButtonBackgroundColor]
                        borderColor:[self.theme deletePunchButtonBorderColor]];
    [self.deletePunchButton setAccessibilityLabel:@"punch_delete_btn"];
}

#pragma mark - Private

- (IBAction)didTapDeleteButton:(id)sender
{
    [self.delegate deletePunchButtonControllerDidSignalIntentToDeletePunch:self];
}

@end
