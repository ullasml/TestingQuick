#import "TimesheetButtonController.h"
#import "ButtonStylist.h"
#import "DefaultTheme.h"
#import "UserPermissionsStorage.h"


@interface TimesheetButtonController ()

@property (nonatomic, weak) id <TimesheetButtonControllerDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *viewTimeSheetPeriodButton;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) id<Theme> theme;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end


@implementation TimesheetButtonController

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                                buttonStylist:(ButtonStylist *)buttonStylist
                                     delegate:(id <TimesheetButtonControllerDelegate>)delegate
                                        theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.theme = theme;
        self.buttonStylist = buttonStylist;
        self.userPermissionsStorage = userPermissionStorage;
        self.title = RPLocalizedString(@"View My Timesheets", nil);
    }
    
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *titleColor = [self.theme viewTimesheetButtonTitleColor];
    UIColor *backgroundColor = [self.theme viewTimesheetButtonBackgroundColor];
    UIColor *borderColor = [self.theme viewTimesheetButtonBorderColor];
    self.topLineView.backgroundColor = [self.theme transparentColor];
    [self.buttonStylist styleButton:self.viewTimeSheetPeriodButton
                              title:self.title
                         titleColor:titleColor
                    backgroundColor:backgroundColor
                        borderColor:borderColor];

    [self.viewTimeSheetPeriodButton  setAccessibilityIdentifier:@"uia_view_my_timesheets_button_identifier"];
}


#pragma mark - Private

- (IBAction)didTapViewTimesheetPeriod:(id)sender {
    if (self.userPermissionsStorage.isWidgetPlatformSupported)
    {
        [self.delegate timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:self];
    }
    else
    {
        [self.delegate timesheetButtonControllerWillNavigateToTimesheetDetailScreen:self];
    }
}

@end
