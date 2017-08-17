//
//  StartFreeTrialViewController.m
//  Replicon
//
//  Created by Abhishek Nimbalkar on 5/5/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import "StartFreeTrialViewController.h"
#import "InputFormCell.h"
#import "Util.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import "SettingUpViewController.h"
#import "AppDelegate.h"
#import "EventTracker.h"

@interface StartFreeTrialViewController () {
    BOOL _isCompanyValid;
    BOOL _isEmailValid;
    UIImage* _validIcon;
    UIImage* _invalidIcon;
    
    // password validation
    NSString* _minCharsString;
    NSString* _alphaString;
    NSString* _numericString;
}

@property (weak, nonatomic) IBOutlet UIView *formView;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCompany;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhone;
@property (weak, nonatomic) IBOutlet UILabel *passwordValidationDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyValidationDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailValidationDetailsLabel;


@property (weak, nonatomic) IBOutlet UIImageView *validationImageCompany;
@property (weak, nonatomic) IBOutlet UIImageView *validationImageEmail;
@property (weak, nonatomic) IBOutlet UIImageView *validationImagePassword;
@property (weak, nonatomic) IBOutlet UIImageView *validationImagePhone;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorCompany;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorEmail;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


- (IBAction)textfieldValueChanged:(id)sender;

@end

@implementation StartFreeTrialViewController
@synthesize signUpButton;
@synthesize termsButton;
@synthesize scrollViewFrame;
@synthesize numberKeyPad;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollViewFrame=self.scrollView.frame;
    //self.scrollView.backgroundColor=[UIColor redColor];
    [Util setToolbarLabel:self withText: RPLocalizedString(FreeTrialTabbarTitle, @"") ];

    
    // add border on formView
    CALayer *layer = self.formView.layer;
    layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.3].CGColor;
    layer.borderWidth = 0.5f;
    
    // hide validation images and activity indicators
    [self hideAllValidations];
    
    self.signupButton.enabled = false;
    
    _validIcon = [UIImage imageNamed:@"icon_formValid"];
    _invalidIcon = [UIImage imageNamed:@"icon_formInvalid"];
    
    
    _minCharsString = RPLocalizedString(PASSWORD_VALIDATION_FIRST_LINE, @"");
    _alphaString = RPLocalizedString(PASSWORD_VALIDATION_SECOND_LINE, @"");
    _numericString = RPLocalizedString(PASSWORD_VALIDATION_THIRD_LINE, @"");;
    
    [self validatePassword:self.textFieldPassword.text];
    
    /*
    UIImage *signUpOriginalImage = [UIImage imageNamed:@"bg_signupBtn"];
    UIEdgeInsets signUpInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    UIImage *signUpStretchableImage = [signUpOriginalImage resizableImageWithCapInsets:signUpInsets];
    [signUpButton setBackgroundImage:signUpStretchableImage forState:UIControlStateNormal];
    */
    
    if (!isiPhone5)
    {
        // this is iphone 4 inch
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+150);
    }
    [self.signupButton setTitle:RPLocalizedString(SIGN_UP_TEXT, @"") forState:UIControlStateNormal];
    
    float firstLineLabelHeight = [self getHeightForString: RPLocalizedString(TERMS_OF_SERVICE_TEXT1, @"") fontSize:14 forWidth:280];
    UILabel  *firstLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, firstLineLabelHeight)];
    firstLineLabel.text = RPLocalizedString(TERMS_OF_SERVICE_TEXT1, @"");
    firstLineLabel.textColor = [UIColor blackColor];
    firstLineLabel.backgroundColor = [UIColor clearColor];
    firstLineLabel.numberOfLines=2;
    [firstLineLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    firstLineLabel.textAlignment = NSTextAlignmentCenter;
    
    float secondLineLabelHeight = [self getHeightForString:RPLocalizedString(TERMS_OF_SERVICE_TEXT2, @"") fontSize:14 forWidth:280];
    UILabel  *secondLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, firstLineLabelHeight+5, 280, secondLineLabelHeight)];
    secondLineLabel.text = RPLocalizedString(TERMS_OF_SERVICE_TEXT2, @"");
    secondLineLabel.textColor = RepliconStandardNavBarTintColor;
    secondLineLabel.backgroundColor = [UIColor clearColor];
    [secondLineLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    secondLineLabel.textAlignment = NSTextAlignmentCenter;

    
    [self.termsButton addSubview:firstLineLabel];
    [self.termsButton addSubview:secondLineLabel];

    self.textFieldCompany.placeholder = RPLocalizedString(COMPANY_NAME_TEXT, @"");
    self.textFieldEmail.placeholder = RPLocalizedString(EMAIL_ADDRESS_TEXT, @"");
    self.textFieldName.placeholder = RPLocalizedString(YOUR_NAME_TEXT, @"");
    self.textFieldPassword.placeholder = RPLocalizedString(PASSWORD_TEXT, @"");
    self.textFieldPhone.placeholder = RPLocalizedString(BUSINESS_NUMBER_TEXT, @"");
    
    [EventTracker.sharedInstance log:@"Free trial landing page"];
}

-(void) viewDidLayoutSubviews
{
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version<7.0)
    {
        CGRect tmpFram = self.navigationController.navigationBar.frame;
        tmpFram.origin.y += 20;
        self.navigationController.navigationBar.frame = tmpFram;
    }
}


-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    
    // show navbar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
    
    self.navigationItem.backBarButtonItem   = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hideAllValidations {
    self.validationImageCompany.hidden =
    self.validationImageEmail.hidden =
    self.validationImagePassword.hidden =
    self.validationImagePhone.hidden = YES;
    
    [self.activityIndicatorCompany stopAnimating];
    [self.activityIndicatorEmail stopAnimating];
}

-(void) validateForm {
    BOOL isValid = (self.textFieldName.text.length != 0 &&
                     self.textFieldCompany.text.length != 0 &&
                     self.textFieldEmail.text.length != 0 &&
                     self.textFieldPassword.text.length != 0 &&
                     self.textFieldPhone.text.length != 0 &&
                     [Util validateEmailAddress:self.textFieldEmail.text] &&
                     [self validatePassword:self.textFieldPassword.text] &&
                     _isCompanyValid && _isEmailValid
                    );
    
    self.signupButton.enabled = isValid;
    
    self.textFieldCompany.returnKeyType =
    self.textFieldEmail.returnKeyType =
    self.textFieldName.returnKeyType =
    self.textFieldPassword.returnKeyType =
    self.textFieldPhone.returnKeyType = isValid ? UIReturnKeyGo : UIReturnKeyNext;
    
}

-(void) validateCompany {
    self.validationImageCompany.hidden = (self.textFieldCompany.text.length == 0);
    [self.activityIndicatorCompany stopAnimating];
    _isCompanyValid = YES;
    self.textFieldCompany.textColor = UIColorFromRGB(0x417505);
    [self validateForm];
}

-(void) validateEmail {
    self.validationImageEmail.hidden = (self.textFieldEmail.text.length == 0);
    [self.activityIndicatorEmail stopAnimating];
    _isEmailValid = YES;
    self.textFieldEmail.textColor = UIColorFromRGB(0x417505);
    [self validateForm];
}

-(BOOL) validatePassword:(NSString*) passwordString {
    
    NSCharacterSet * characterSet;
    NSRange range;
    
    // basic attributes
    NSString* basicString = [NSString stringWithFormat:@"%@ %@ %@", _minCharsString, _alphaString, _numericString];
    NSDictionary* basicAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:12.f], NSForegroundColorAttributeName:UIColorFromRGB(0x666666)};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:basicString attributes:basicAttributes];
    
    if(passwordString.length == 0) {
        [self.passwordValidationDetailsLabel setAttributedText:attributedText];
          self.passwordValidationDetailsLabel.adjustsFontSizeToFitWidth=TRUE;
        return NO;
    }
    
    BOOL isValid = YES;
    
    // check length
    if(passwordString.length < 8) {
        isValid = NO;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xD0021B)} range:[basicString rangeOfString:_minCharsString]];
    }
    
    // check alpha
    characterSet = [NSCharacterSet letterCharacterSet];
    range = [passwordString rangeOfCharacterFromSet:characterSet];
    if (range.location == NSNotFound) {
        isValid = NO;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xD0021B)} range:[basicString rangeOfString:_alphaString]];
    }

    // check numeric
    characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    range = [passwordString rangeOfCharacterFromSet:characterSet];
    if (range.location == NSNotFound) {
        isValid = NO;
        [attributedText setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xD0021B)} range:[basicString rangeOfString:_numericString]];
    }
   
    [self.passwordValidationDetailsLabel setAttributedText:attributedText];
    
     self.passwordValidationDetailsLabel.font=[UIFont fontWithName:@"Helvetica Neue" size:12.0f];
    
    self.passwordValidationDetailsLabel.adjustsFontSizeToFitWidth=TRUE;
    
    return isValid;
}

#pragma mark - TextField delegate protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag && textField.tag==5)
    {
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y-88.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    }
    
    else if(textField.tag && textField.tag==4)
    {
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y-88.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag && textField.tag==5)
    {
        if (!self.numberKeyPad) {
            self.numberKeyPad.isDonePressed=NO;
            self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:self withMinus:NO andisDoneShown:NO withResignButton:YES];
            numberKeyPad.delegate=self;
        }else {
            //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
            self.numberKeyPad.currentTextField = textField;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag && textField.tag <= 5) {
        [[self.view viewWithTag:textField.tag + 1] becomeFirstResponder];
    }
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.tag == 2) {
        // Company
        if(textField.text.length != 0) {
            
            if (![NetworkMonitor isNetworkAvailableForListener:self])
            {
                [Util showOfflineAlert];
                return;
            }
            else
            {
                [self.activityIndicatorCompany startAnimating];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companyNameValidation:) name:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION object:nil];
                
                
 //               AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
 //               [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                
                
                // ******************************* IF USING REQUEST BUILDER *******************************
                [[RepliconServiceManager freeTrialService] sendRequestToValidateCompanyServiceForString:self.textFieldCompany.text];
            }
            
            
            
        }
    }
    else if(textField.tag == 3) {
        // Email
        if([Util validateEmailAddress:self.textFieldEmail.text]) {

            if (![NetworkMonitor isNetworkAvailableForListener:self])
            {
                [Util showOfflineAlert];
                return;
            }
            else
            {
                self.validationImageEmail.image = _validIcon;
                [self.activityIndicatorEmail startAnimating];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:EMAIL_VALIDATION_DATA_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailValidation:) name:EMAIL_VALIDATION_DATA_NOTIFICATION object:nil];
                
   //             AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  //              [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                
                
                // ******************************* IF USING REQUEST BUILDER *******************************
                [[RepliconServiceManager freeTrialService] sendRequestToValidateEmailServiceForString:self.textFieldEmail.text];
            }
            
            

        } else {
            if(textField.text.length != 0) self.validationImageEmail.hidden = NO;
            self.validationImageEmail.image = _invalidIcon;
        }
    }
    else if(textField.tag == 4) {
        // Password
        self.validationImagePassword.image = [self validatePassword:self.textFieldPassword.text] ? _validIcon : _invalidIcon;
        if(textField.text.length != 0) self.validationImagePassword.hidden = NO;
    }
    

    if(textField.tag && textField.tag==5)
    {
        
        if (textField == numberKeyPad.currentTextField)
        {
            [self.numberKeyPad removeButtonFromKeyboard];
            self.numberKeyPad = nil;
            
        }
        
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y+88.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    }
    
    else if(textField.tag && textField.tag==4)
    {
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y+88.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    }
    
}


- (IBAction)textfieldValueChanged:(id)sender {
    UITextField *textField = (UITextField*)sender;
    
    if(textField.tag == 2) {
        // Company
        self.validationImageCompany.hidden = YES;
        _isCompanyValid = NO;
        self.textFieldCompany.textColor = [UIColor blackColor];
        self.companyValidationDetailsLabel.text = @"";
    } else if(textField.tag == 3) {
        // Email
        self.validationImageEmail.hidden = YES;
        _isEmailValid = NO;
        self.textFieldEmail.textColor = [UIColor blackColor];
        self.emailValidationDetailsLabel.text = @"";

    } else if(textField.tag == 4) {
        // Password
        self.validationImagePassword.hidden = YES;
    }
    
    [self validateForm];
    
}

-(void)resignKeyBoard:(UITextField *)textField;
{
    if(textField.tag && textField.tag==5)
    {
        if (textField == numberKeyPad.currentTextField)
        {
            [self.numberKeyPad removeButtonFromKeyboard];
            self.numberKeyPad = nil;
            
        }
    }
}


-(void)emailValidation :(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EMAIL_VALIDATION_DATA_NOTIFICATION object:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        
        if ((![notification.object  isKindOfClass:[NSNull class]] && notification.object  != nil)) {
            BOOL IsExist = [notification.object boolValue];
            if (IsExist) {
                self.emailValidationDetailsLabel.text = RPLocalizedString(EMAIL_ALREADY_EXIST_TEXT, @"");
                if(self.textFieldEmail.text.length != 0) self.validationImageEmail.hidden = NO;
                self.validationImageEmail.image = _invalidIcon;
                [self.activityIndicatorEmail stopAnimating];
                
            }
            else
            {
                self.emailValidationDetailsLabel.text = @"";
                [self validateEmail];
            }
        }
    }
    else{
        if(self.textFieldEmail.text.length != 0) self.validationImageEmail.hidden = NO;
        self.validationImageEmail.image = _invalidIcon;
        [self.activityIndicatorEmail stopAnimating];
    }

}

-(void)companyNameValidation :(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION object:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        if (![notification.object  isKindOfClass:[NSNull class]] && notification.object  != nil) {
            NSString *companyName = notification.object;
            companyName = [companyName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if (![companyName isEqualToString:self.textFieldCompany.text]) {
                self.companyValidationDetailsLabel.text = [NSString stringWithFormat:@"Your Company ID: %@", companyName];
                self.textFieldCompany.text = companyName;
                [self validateCompany];
            }
            else{
                [self validateCompany];
            }
        }
        else{
            [self validateCompany];
        }
    }
    else{
        if(self.textFieldCompany.text.length != 0) self.textFieldCompany.hidden = NO;
        self.validationImageCompany.image = _invalidIcon;
        [self.activityIndicatorCompany stopAnimating];
    }
}

-(void)showAlert :(NSString*)msg
{
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:nil
                                            message:RPLocalizedString(msg, @"")
                                              title:RPLocalizedString(SIGN_UP_TEXT, @"")
                                                tag:LONG_MIN];
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
   if ([identifier isEqualToString:@"goToDestination"])
   {
       if (![NetworkMonitor isNetworkAvailableForListener:self])
       {
           [Util showOfflineAlert];
           return NO;
       }
   }
    return YES;
}

-(IBAction)signUPButtonAction:(id)sender
{
    
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        
    }
    else
    {
       
        
        NSArray* stringArray = [self.textFieldName.text componentsSeparatedByString: @" "];
        NSString* firstName = [stringArray objectAtIndex: 0];
        NSString* lastName = @"";
        if ([stringArray count]>1) {
            lastName = [stringArray objectAtIndex: 1];
        }
        else{
            //lastName = firstName;
            lastName = @"-";
        }
        
        // ******************************* IF USING REQUEST BUILDER *******************************
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         firstName,@"first_name",
                                         lastName,@"last_name",
                                         self.textFieldCompany.text,@"company",
                                         self.textFieldPhone.text,@"businessphone",
                                         self.textFieldPassword.text,@"password",
                                         self.textFieldEmail.text,@"businessemail",
                                         nil];
        
        [[RepliconServiceManager freeTrialService] sendRequestTosignUpServiceForDataDict:dataDict];
    }
    
  
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version<7.0)
    {
    [self.view endEditing:YES];
    }
}

-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
}


@end
