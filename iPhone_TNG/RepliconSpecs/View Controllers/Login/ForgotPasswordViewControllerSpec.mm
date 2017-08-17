#import <Cedar/Cedar.h>
#import "ForgotPasswordViewController.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "UIControl+spec.h"
#import <KSDeferred/KSDeferred.h>
#import "UIAlertView+spec.h"
#import "NSString+PivotalCore.h"
#import "SpinnerDelegate.h"
#import "UIBarButtonItem+Spec.h"
#import "Constants.h"
#import "Theme.h"
#import "FrameworkImport.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ForgotPasswordViewControllerSpec)

describe(@"ForgotPasswordViewController", ^{
    __block ForgotPasswordViewController <CedarDouble> *subject;
    __block UINavigationController *navigationController;
    __block id<BSBinder, BSInjector> injector;
    __block ForgotPasswordRepository *forgotPasswordRepository;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<Theme> theme;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block GATracker *tracker;
    __block EMMConfigManager *emmConfigManager;
    
    beforeEach(^{
        
        injector = [InjectorProvider injector];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        forgotPasswordRepository = nice_fake_for([ForgotPasswordRepository class]);
        [injector bind:[ForgotPasswordRepository class] toInstance:forgotPasswordRepository];

        tracker = nice_fake_for([GATracker class]);
        [injector bind:[GATracker class] toInstance:tracker];

        emmConfigManager = nice_fake_for([EMMConfigManager class]);
        [injector bind:[EMMConfigManager class] toInstance:emmConfigManager];
        
        subject = [injector getInstance:[ForgotPasswordViewController class]];
        
        spy_on(subject);

        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
    });
    

    context(@"When the view loads", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should correctly set the title", ^{
            subject.forgotPasswordLabel.text should equal(RPLocalizedString(ForgotPasswordViewTitle, nil));
            subject.title should equal(RPLocalizedString(ForgotPasswordTitle, nil));
        });

        it(@"should correctly set the text placeholders", ^{
            subject.companyNameTextField.placeholder should equal(RPLocalizedString(CompanyNamePlaceholderText,nil));
            subject.emailTextField.placeholder should equal(RPLocalizedString(EmailAddressPlaceholderText, nil));

        });

        it(@"should correctly set the reset password button title", ^{
            subject.resetButton.titleLabel.text should equal(RPLocalizedString(ResetPasswordButtonTitle, nil));
        });

        it(@"should received event for GA Tracker", ^{
            tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"start", TrackerProduct);
        });
    });
    
    context(@"should set text for company text field", ^{
        beforeEach(^{
            emmConfigManager stub_method(@selector(companyName)).and_return(@"some-company");
            subject.view should_not be_nil;
        });
        
        it(@"should set text to company textfield", ^{
            subject.companyNameTextField.text should equal(@"some-company");
        });
    });
    
    context(@"should set not set text for company text field", ^{
        beforeEach(^{
            emmConfigManager stub_method(@selector(companyName)).and_return(@"");
            subject.view should_not be_nil;
        });
        
        it(@"should set text to company textfield", ^{
            subject.companyNameTextField.text should equal(@"");
        });
    });

    context(@"Styling the container view", ^{
        
        beforeEach(^{
            theme stub_method(@selector(resetPasswordButtonTitleFont)).and_return([UIFont systemFontOfSize:16]);
            theme stub_method(@selector(resetPasswordButtonTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(forgotPasswordContainerBorderColor)).and_return([UIColor yellowColor].CGColor);
            subject.view should_not be_nil ;
        });
        
        it(@"should set border color for container view", ^{
            subject.resetButton.titleLabel.font should equal([UIFont systemFontOfSize:16]);
            subject.resetButton.titleLabel.textColor should equal([UIColor redColor]);
            subject.containerView.layer.borderColor should equal([UIColor yellowColor].CGColor);
        });
    });

    context(@"when reset button is tapped", ^{
        __block UITextField  *company;
        __block UITextField  *email;
        __block KSDeferred *uriRequestDeferred;

        context(@"When network is not reachable", ^{
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                subject.view should_not be_nil ;
                [subject.resetButton tap];
            });

            it(@"should show offline status alert for user ", ^{
                UIAlertView *alertView = [UIAlertView currentAlertView];
                alertView.message should equal(RPLocalizedString(@"Your device is offline.  Please try again when your device is online.",nil));
                alertView.delegate should be_nil;
                alertView.numberOfButtons should equal(1);
                [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
        });

        context(@"When user enters valid credentials", ^{
            beforeEach(^{
                uriRequestDeferred = [[KSDeferred alloc] init];
                subject.view should_not be_nil ;
                company = nice_fake_for([UITextField class]);
                email = nice_fake_for([UITextField class]);
                company stub_method (@selector(text)).and_return(@"my - special - company - name");
                email stub_method (@selector(text)).and_return(@"user@example.com");
                subject stub_method(@selector(companyNameTextField)).and_return(company);
                subject stub_method(@selector(emailTextField)).and_return(email);
                spy_on(subject);
                
                forgotPasswordRepository stub_method(@selector(passwordResetRequestWithCompanyName:email:)).with(@"my-special-company-name",@"user@example.com").and_return(uriRequestDeferred.promise);
                
                [subject.resetButton tap];
            });
            
            it(@"should should have started spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            it(@"should initiate reset service request method", ^{
                forgotPasswordRepository should have_received(@selector(passwordResetRequestWithCompanyName:email:)).with(@"my-special-company-name",@"user@example.com");
            });
            
            context(@"when the reset password request is success", ^{
                __block KSDeferred *passwordResetEmailDeferred;
                beforeEach(^{
                    passwordResetEmailDeferred = [[KSDeferred alloc]init];
                    NSDictionary *response = @{@"d":@"request uri"};
                    forgotPasswordRepository stub_method(@selector(sendRequestToResetPasswordToEmail:)).with(@"request uri").and_return(passwordResetEmailDeferred.promise);
                    [uriRequestDeferred resolveWithValue:response];
                });
                
                it(@"should send password reset request email", ^{
                    forgotPasswordRepository should have_received(@selector(sendRequestToResetPasswordToEmail:)).with(@"request uri");
                });
                
                context(@"when the reset password email request is success", ^{
                    beforeEach(^{
                        [passwordResetEmailDeferred resolveWithValue:nil];
                    });
                    it(@"should should have stopped spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    it(@"should show alert for user to check email", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(InstructionsToResetPasswordMessage,nil));
                        alertView.delegate should be_nil;
                        alertView.title should be_nil;
                        alertView.numberOfButtons should equal(1);
                        [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });

                    it(@"should pop the view controller", ^{
                        navigationController should have_received(@selector(popViewControllerAnimated:)).with(YES);
                    });

                });
                
                context(@"when the reset password request to send email is failure", ^{
                    beforeEach(^{
                        [passwordResetEmailDeferred rejectWithError:nil];
                    });
                    
                    it(@"should should have stopped spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    it(@"should show an wrong credentials alert", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(PasswordResetFailedMessage,nil));
                        alertView.delegate should be_nil;
                        alertView.title should be_nil;
                        alertView.numberOfButtons should equal(1);
                        [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });
                });
                
            });
            
            context(@"when the reset password request is failure", ^{
                beforeEach(^{
                    [uriRequestDeferred rejectWithError:nil];
                });
                
                it(@"should should have stopped spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should show an wrong credentials alert", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(PasswordResetFailedMessage,nil));
                    alertView.delegate should be_nil;
                    alertView.title should be_nil;
                    alertView.numberOfButtons should equal(1);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
            });

        });
        
        context(@"When user enters invalid credentials", ^{
            
            context(@"when user enters empty credentials", ^{
                beforeEach(^{
                    subject.view should_not be_nil ;
                    company = nice_fake_for([UITextField class]);
                    email = nice_fake_for([UITextField class]);
                    company stub_method (@selector(text)).and_return(nil);
                    email stub_method (@selector(text)).and_return(nil);
                    subject stub_method(@selector(companyNameTextField)).and_return(company);
                    subject stub_method(@selector(emailTextField)).and_return(email);
                    spy_on(subject);
                    
                    [subject.resetButton tap];
                });
                
                it(@"should should have stopped spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should not initiate reset service request method", ^{
                    forgotPasswordRepository should_not have_received(@selector(passwordResetRequestWithCompanyName:email:));
                });

                it(@"should show an wrong credentials alert", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(EnterValidEmailAndCompanyMessage,nil));
                    alertView.delegate should be_nil;
                    alertView.title should be_nil;
                    alertView.numberOfButtons should equal(1);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });

            });
            
            context(@"when user enters invalid email", ^{
                beforeEach(^{
                    subject.view should_not be_nil ;
                    company = nice_fake_for([UITextField class]);
                    email = nice_fake_for([UITextField class]);
                    company stub_method (@selector(text)).and_return(@"my-company");
                    email stub_method (@selector(text)).and_return(@"www.example.com");
                    subject stub_method(@selector(companyNameTextField)).and_return(company);
                    subject stub_method(@selector(emailTextField)).and_return(email);
                    spy_on(subject);
                    
                    [subject.resetButton tap];
                });
                
                it(@"should not initiate reset service request method", ^{
                    forgotPasswordRepository should_not have_received(@selector(passwordResetRequestWithCompanyName:email:));
                });
                
                it(@"should should have stopped spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should show an wrong credentials alert", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(EnterValidEmailMessage,nil));
                    alertView.delegate should be_nil;
                    alertView.title should be_nil;
                    alertView.numberOfButtons should equal(1);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                
            });
        });
        
    });
    
    context(@"as a <UITextField> delegate", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should resign Company textfield when user resigns keyboard", ^{
            [subject textFieldShouldReturn:subject.companyNameTextField];
            subject.companyNameTextField.isFirstResponder should be_falsy;
            subject should have_received(@selector(resetButtonClick:)).with(nil);
        });
        
        it(@"should resign Email textfield when user resigns keyboard", ^{
            [subject textFieldShouldReturn:subject.emailTextField];
            subject.emailTextField.isFirstResponder should be_falsy;
            subject should have_received(@selector(resetButtonClick:)).with(nil);
        });
    });
    
    context(@"When canceling", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject.navigationItem.leftBarButtonItem tap];
            
        });
        
        it(@"should pop back to view controller", ^{
            [subject textFieldShouldReturn:subject.companyNameTextField];
            subject.companyNameTextField.isFirstResponder should be_falsy;
            
            [subject textFieldShouldReturn:subject.emailTextField];
            subject.emailTextField.isFirstResponder should be_falsy;
            
            navigationController should have_received(@selector(popViewControllerAnimated:)).with(YES);
        });
        
        
    });
    
    describe(@"left navigation bar button should have correct style", ^{
        beforeEach(^{
            theme stub_method(@selector(defaultleftBarButtonColor)).and_return([UIColor magentaColor]);
            [subject view];
        });
        
        it(@"should have correct color", ^{
            subject.navigationItem.leftBarButtonItem.tintColor should equal([UIColor magentaColor]);
        });
    });
    
});

SPEC_END
