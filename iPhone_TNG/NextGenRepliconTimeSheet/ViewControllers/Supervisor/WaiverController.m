#import "WaiverController.h"
#import "Violation.h"
#import "Waiver.h"
#import "ViolationSeverityPresenter.h"
#import "Theme.h"
#import "WaiverOption.h"
#import "WaiverRepository.h"
#import <KSDeferred/KSPromise.h>
#import "ButtonStylist.h"
#import "SpinnerDelegate.h"
#import "SelectedWaiverOptionPresenter.h"


@interface WaiverController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UILabel *waiverDisplayTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *severityImageView;
@property (nonatomic, weak) IBOutlet UILabel *violationTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *bottomSeparatorView;
@property (nonatomic, weak) IBOutlet UILabel *sectionTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *topSeparatorView;
@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) IBOutlet UIButton *responseButton;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) id<WaiverControllerDelegate> delegate;

@property (nonatomic) WaiverRepository *waiverRepository;

@property (nonatomic) ViolationSeverityPresenter *violationSeverityPresenter;
@property (nonatomic) SelectedWaiverOptionPresenter *selectedWaiverOptionPresenter;
@property (nonatomic) id <Theme> theme;

@property (nonatomic) Violation *violation;
@property (nonatomic, copy) NSString *sectionTitle;


@end


@implementation WaiverController

- (instancetype)initWithSelectedWaiverOptionPresenter:(SelectedWaiverOptionPresenter *)selectedWaiverOptionPresenter
                           violationSeverityPresenter:(ViolationSeverityPresenter *)violationSeverityPresenter
                                     waiverRepository:(WaiverRepository *)waiverRepository
                                      spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                                theme:(id <Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.violationSeverityPresenter = violationSeverityPresenter;
        self.waiverRepository = waiverRepository;
        self.spinnerDelegate = spinnerDelegate;
        self.theme = theme;
        self.selectedWaiverOptionPresenter = selectedWaiverOptionPresenter;
    }
    return self;
}

- (void)setupWithSectionTitle:(NSString *)sectionTitle
                    violation:(Violation *)violation
                     delegate:(id<WaiverControllerDelegate>)delegate
{
    self.sectionTitle = sectionTitle;
    self.violation = violation;
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.view.backgroundColor = [self.theme waiverBackgroundColor];

    self.bottomSeparatorView.backgroundColor = [self.theme waiverSeparatorColor];
    self.topSeparatorView.backgroundColor = [self.theme waiverSeparatorColor];
    self.separatorView.backgroundColor = [self.theme waiverSeparatorColor];

    self.severityImageView.image = [self.violationSeverityPresenter severityImageWithViolationSeverity:self.violation.severity];

    self.sectionTitleLabel.font = [self.theme waiverSectionTitleFont];
    self.sectionTitleLabel.textColor = [self.theme waiverSectionTitleTextColor];

    self.violationTitleLabel.font = [self.theme waiverViolationTitleFont];
    self.violationTitleLabel.textColor = [self.theme waiverViolationTitleTextColor];

    self.waiverDisplayTextLabel.font = [self.theme waiverDisplayTextFont];
    self.waiverDisplayTextLabel.textColor = [self.theme waiverDisplayTextColor];

    self.sectionTitleLabel.text = self.sectionTitle;
    self.violationTitleLabel.text = self.violation.title;
    self.waiverDisplayTextLabel.text = self.violation.waiver.displayText;

    ButtonStylist *buttonStylist = [[ButtonStylist alloc] initWithTheme:self.theme];

    NSString *responseButtonTitle = [self.selectedWaiverOptionPresenter displayTextFromSelectedWaiverOption:self.violation.waiver.selectedOption];
    [self.responseButton setTitle:responseButtonTitle forState:UIControlStateNormal];
    [self.responseButton setAccessibilityIdentifier:@"uia_violation_waiver_response_button_identifier"];

    UIColor *titleColor = [self.theme waiverResponseButtonTextColor];
    UIColor *backgroundColor = [self.theme waiverResponseButtonBackgroundColor];
    UIColor *borderColor = [self.theme waiverResponseButtonBorderColor];

    [buttonStylist styleButton:self.responseButton title:responseButtonTitle titleColor:titleColor backgroundColor:backgroundColor borderColor:borderColor];
    self.responseButton.titleLabel.font =  [self.theme waiverResponseButtonTitleFont];    
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex]) {

        [self.spinnerDelegate showTransparentLoadingOverlay];

        NSUInteger index = buttonIndex - 1;
        Waiver *waiver = self.violation.waiver;
        WaiverOption *waiverOption = self.violation.waiver.options[index];

        KSPromise *promise = [self.waiverRepository updateWaiver:waiver withWaiverOption:waiverOption];

        [promise then:^id(id value) {
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            [self.delegate waiverController:self didSelectWaiverOption:waiverOption forWaiver:waiver];
            return value;
        } error:^id(NSError *error) {
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            
            return error;
        }];
    }
}

#pragma mark - Private

- (IBAction)didTapResponseButton:(id)sender
{
    NSString *title = RPLocalizedString(@"Change Waiver Response", @"Change Waiver Response");
    NSString *cancelTitle = RPLocalizedString(@"Cancel", @"Cancel");

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:nil];

    for (WaiverOption *waiverOption in self.violation.waiver.options)
    {
        [actionSheet addButtonWithTitle:waiverOption.displayText];
    }


    [actionSheet showInView:sender];
}

@end
