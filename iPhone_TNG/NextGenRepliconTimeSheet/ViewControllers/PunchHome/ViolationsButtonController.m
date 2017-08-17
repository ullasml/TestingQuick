#import "ViolationsButtonController.h"
#import "Theme.h"
#import "ButtonStylist.h"
#import "ViolationRepository.h"
#import <KSDeferred/KSPromise.h>
#import "AllViolationSections.h"


@interface ViolationsButtonController ()

@property (nonatomic) id<Theme> theme;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) AllViolationSections *violationSections;
@property (weak, nonatomic) IBOutlet UIButton *violationsButton;
@property (weak, nonatomic) id<ViolationsButtonControllerDelegate> delegate;
@property (nonatomic,assign) BOOL showViolations;
@end


@implementation ViolationsButtonController

- (instancetype)initWithButtonStylist:(ButtonStylist *)buttonStylist
                                theme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
        self.buttonStylist = buttonStylist;
    }
    return self;
}

- (void)setupWithDelegate:(id<ViolationsButtonControllerDelegate>)delegate showViolations:(BOOL)showViolations
{
    self.delegate = delegate;
    self.showViolations = showViolations;
}

- (void)reloadData
{
    if (!self.showViolations) {
        self.violationsButton.hidden = YES;
        [[self.delegate violationsButtonHeightConstraint] setConstant:0.0f];
        return;
    }
    
    if (self.navigationController.presentedViewController == nil && self.navigationController.viewControllers.count > 0) {
        KSPromise *violationSectionsPromise = [self.delegate violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:self];
        [violationSectionsPromise then:^id(AllViolationSections *allViolationSections) {
            self.violationSections = allViolationSections;

            if (allViolationSections.totalViolationsCount > 0) {
                self.violationsButton.hidden = NO;
                [[self.delegate violationsButtonHeightConstraint] setConstant:44.0f];
            }
            else {
                self.violationsButton.hidden = YES;
                [[self.delegate violationsButtonHeightConstraint] setConstant:0.0f];
            }
            NSString *format;
            if(allViolationSections.totalViolationsCount==1)
            {
                format = [NSString stringWithFormat:@"%lu %@",(unsigned long)allViolationSections.totalViolationsCount,RPLocalizedString(@"Violation", @"supervisor-dashboard.%lu Violation")];
            }
            else
            {
                format = [NSString stringWithFormat:@"%lu %@",(unsigned long)allViolationSections.totalViolationsCount,RPLocalizedString(@"Violations", @"supervisor-dashboard.%lu Violations")];
            }
            NSString *title = [NSString localizedStringWithFormat:format, allViolationSections.totalViolationsCount];
            [self.violationsButton setTitle:title forState:UIControlStateNormal];
            return nil;
        } error:nil];
    }

}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self.buttonStylist styleButton:self.violationsButton
                              title:nil
                         titleColor:[self.theme violationsButtonTitleColor]
                    backgroundColor:[self.theme violationsButtonBackgroundColor]
                        borderColor:[self.theme violationsButtonBorderColor]];

    self.violationsButton.hidden = YES;
    [self.violationsButton setAccessibilityIdentifier:@"uia_violations_button_identifier"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadData];
}

- (IBAction)didTapViolationsButton:(id)sender
{
    [self.delegate violationsButtonController:self
       didSignalIntentToViewViolationSections:self.violationSections];
}

@end

