#import "ForgotPasswordViewController.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import  "QuartzCore/QuartzCore.h"
#import <KSDeferred/KSPromise.h>
#import "Theme.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "FrameworkImport.h"

@interface ForgotPasswordViewController ()


@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) id<Theme> theme;
@property (nonatomic) ForgotPasswordRepository *forgotPasswordRepository;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) EMMConfigManager *emmConfigManager;
@property (nonatomic) GATracker *tracker;
@end

@implementation ForgotPasswordViewController

- (instancetype)initWithForgotPasswordRepository:(ForgotPasswordRepository *)forgotPasswordRepository
                                 spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                                           theme:(id <Theme>)theme
                             reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                emmConfigManager:(EMMConfigManager *)emmConfigManager
                                         tracker:(GATracker *)tracker
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.forgotPasswordRepository = forgotPasswordRepository;
        self.spinnerDelegate = spinnerDelegate;
        self.theme = theme;
        self.reachabilityMonitor = reachabilityMonitor;
        self.emmConfigManager = emmConfigManager;
        self.tracker = tracker;
    }
    return self;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RPLocalizedString(ForgotPasswordTitle,ForgotPasswordTitle);
    self.forgotPasswordLabel.text = RPLocalizedString(ForgotPasswordViewTitle, ForgotPasswordViewTitle);
    self.companyNameTextField.text = self.emmConfigManager.companyName ? self.emmConfigManager.companyName : @"";
    self.companyNameTextField.placeholder = RPLocalizedString(CompanyNamePlaceholderText, CompanyNamePlaceholderText);
    self.emailTextField.placeholder = RPLocalizedString(EmailAddressPlaceholderText, EmailAddressPlaceholderText);
    [self.resetButton setTitle:RPLocalizedString(ResetPasswordButtonTitle, ResetPasswordButtonTitle) forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [self.theme resetPasswordButtonTitleFont];
    [self.resetButton setTitleColor:[self.theme resetPasswordButtonTitleColor] forState:UIControlStateNormal];
    self.containerView.layer.borderColor = [self.theme forgotPasswordContainerBorderColor];
     UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(popBackToViewController)];
    [cancelBarButtonItem setTintColor:[self.theme defaultleftBarButtonColor]];
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
    [self.tracker trackUIEvent:@"start" forTracker:TrackerProduct];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];

    [self resetButtonClick:nil];
    
    return YES;
}


-(IBAction)resetButtonClick:(id)sender
{
    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    if ([self isValidCredentials])
    {
        
        NSString *company = [self removingWhiteSpaceFromTextFieldText:self.companyNameTextField.text];
        NSString *email = [self removingWhiteSpaceFromTextFieldText:self.emailTextField.text];
        if([self isValidEmailAddress])
        {
            KSPromise *requestForPasswordReset = [self.forgotPasswordRepository passwordResetRequestWithCompanyName:company email:email];
            [self.spinnerDelegate showTransparentLoadingOverlay];
            [requestForPasswordReset then:^id(NSDictionary *data) {
                NSString *uri  = data[@"d"];
                KSPromise *requestSendPasswordResetMail = [self.forgotPasswordRepository sendRequestToResetPasswordToEmail:uri];
                [requestSendPasswordResetMail then:^id(NSDictionary *data) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self alertInvalidCredentialsToUser:InstructionsToResetPasswordMessage];
                    [self popBackToViewController];
                    return nil;
                } error:^id(NSError *error) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self alertInvalidCredentialsToUser:PasswordResetFailedMessage];
                    return nil;
                }];
                return nil;
            } error:^id(NSError *error) {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                [self alertInvalidCredentialsToUser:PasswordResetFailedMessage];
                return nil;
            }];
        }
        else
        {
           [self.spinnerDelegate hideTransparentLoadingOverlay];
            [self alertInvalidCredentialsToUser:EnterValidEmailMessage];
        }
    }
    else
    {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        [self alertInvalidCredentialsToUser:EnterValidEmailAndCompanyMessage];
    }
}

#pragma mark - Private

-(void)popBackToViewController
{
    [self.companyNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)isValidCredentials
{
    return (self.companyNameTextField.text.length!=0 && self.emailTextField.text.length!=0);
}

- (BOOL)isValidEmailAddress
{
    NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\\b";
    NSRegularExpression *validator = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
    return [validator numberOfMatchesInString:self.emailTextField.text options:0 range:NSMakeRange(0, self.emailTextField.text.length)];
}

-(void)alertInvalidCredentialsToUser:(NSString *)message
{
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                   otherButtonTitle:nil
                                           delegate:nil
                                            message:RPLocalizedString(message,message)
                                              title:nil
                                                tag:LONG_MIN];
}

-(NSString *)removingWhiteSpaceFromTextFieldText:(NSString *)text
{
    return [text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
