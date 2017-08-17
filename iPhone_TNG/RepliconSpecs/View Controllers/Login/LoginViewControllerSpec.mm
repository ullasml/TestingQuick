#import <Cedar/Cedar.h>
#import "LoginViewController.h"
#import "SpinnerDelegate.h"
#import "Router.h"
#import "CookiesDelegate.h"
#import "LoginDelegate.h"
#import "UIActionSheet+Spec.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "ForgotPasswordViewController.h"
#import <MessageUI/MessageUI.h>
#import "FrameworkImport.h"
#import "LoginCredentialsHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(LoginViewControllerSpec)

describe(@"LoginViewController", ^{
    __block LoginViewController *subject;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<CookiesDelegate> cookiesDelegate;
    __block id<Router> router;
    __block UINavigationController *navigationController;
    __block id<BSBinder, BSInjector> injector;
    __block ForgotPasswordViewController *forgotPasswordViewController;
    __block GATracker *tracker;
    __block LoginCredentialsHelper *loginCredentialsHelper;
    __block EMMConfigManager *emmConfigManager;
    __block NSUserDefaults *userDefaults;
    
    beforeEach(^{
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        cookiesDelegate = nice_fake_for(@protocol(CookiesDelegate));
        router = nice_fake_for(@protocol(Router));
        tracker = nice_fake_for([GATracker class]);
        loginCredentialsHelper = nice_fake_for([LoginCredentialsHelper class]);
        emmConfigManager = nice_fake_for([EMMConfigManager class]);
        injector = [InjectorProvider injector];
        forgotPasswordViewController = [injector getInstance:[ForgotPasswordViewController class]];
        userDefaults = nice_fake_for([NSUserDefaults class]);

        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];
        [injector bind:@protocol(CookiesDelegate) toInstance:cookiesDelegate];
        [injector bind:@protocol(Router) toInstance:router];
        [injector bind:[GATracker class] toInstance:tracker];
        [injector bind:[EMMConfigManager class] toInstance:emmConfigManager];
        [injector bind:[LoginCredentialsHelper class] toInstance:loginCredentialsHelper];
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        subject = [injector getInstance:[LoginViewController class]];
        spy_on(subject);
        
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        
        
        spy_on(forgotPasswordViewController);
        
        
    });

    describe(@"When the view loads", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should delete the cookies", ^{
            cookiesDelegate should have_received(@selector(deleteCookies));
        });

        it(@"should received event for GA Tracker", ^{
            tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"start", TrackerProduct);
        });
    });



    describe(@"the sign in button action", ^{
        describe(@"when tapping the sign in button", ^{
            beforeEach(^{
                [subject view];
                [(id<CedarDouble>)cookiesDelegate reset_sent_messages];
                [subject loginView:nil signInButtonAction:nil];
            });

            it(@"should delete the cookies", ^{
                cookiesDelegate should have_received(@selector(deleteCookies));
            });
        });
    });

    describe(NSStringFromProtocol(@protocol(LoginDelegate)), ^{
        describe(NSStringFromSelector(@selector(loginServiceDidFinishLoggingIn:)), ^{
            describe(@"when the login service did complete fetching the home summary", ^{
                
                context(@"when no credentials are available", ^{
                    beforeEach(^{
                        [subject loginServiceDidFinishLoggingIn:nil];
                    });
                    it(@"correct selector method is called", ^{
                        subject.tracker should have_received(@selector(setUserUri:companyName:username:platform:)).with(@"na",@"na",@"na",@"gen3");
                    });

                    it(@"should route to the tab bar controller", ^{
                        router should have_received(@selector(launchTabBarController));
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should received event for GA Tracker", ^{
                        subject.tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"login", TrackerProduct);
                    });

                });

                context(@"when credentials are available", ^{
                    beforeEach(^{
                        loginCredentialsHelper stub_method (@selector(getLoginCredentials)).and_return(@{@"userName":@"User Name",@"userUri":@"user-uri",@"companyName":@"Company Name"});
                        subject stub_method(@selector(loginCredentialsHelper)).and_return(loginCredentialsHelper);
                        [subject loginServiceDidFinishLoggingIn:nil];

                    });
                    it(@"correct selector method is called", ^{
                        subject.tracker should have_received(@selector(setUserUri:companyName:username:platform:)).with(@"user-uri",@"Company Name",@"User Name",@"gen3");
                    });

                    it(@"should route to the tab bar controller", ^{
                        router should have_received(@selector(launchTabBarController));
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should received event for GA Tracker", ^{
                        subject.tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"login", TrackerProduct);
                    });
                });


            });
        });
    });
    
    describe(@"when EMM values are present", ^{
        beforeEach(^{
            emmConfigManager stub_method(@selector(companyName)).and_return(@"some-company");
            emmConfigManager stub_method(@selector(userName)).and_return(@"some-user");
            subject.view should_not be_nil;
        });
        
        it(@"should have set company name and user name from EMM values", ^{
            subject.loginView.companyTextField.text = @"some-company";
            subject.loginView.usernameTextField.text = @"some-user";
        });
    });
    
    describe(@"when EMM values are not present", ^{
        
        beforeEach(^{
            NSDictionary *credentials = @{@"companyName":@"some-company",
                                          @"userName":@"some-user"};
            emmConfigManager stub_method(@selector(isEMMValuesStored)).and_return(false);
            loginCredentialsHelper stub_method(@selector(getLoginCredentials)).and_return(credentials);
            userDefaults stub_method(@selector(boolForKey:)).with(@"RememberMe").and_return(YES);
        });
        
        describe(@"when login in with production instance", ^{
            beforeEach(^{
                userDefaults stub_method(@selector(boolForKey:)).with(@"isConnectStagingServer").and_return(NO);
                subject.view should_not be_nil;
            });
            it(@"should have set company name and user name from Keychain values", ^{
                subject.loginView.companyTextField.text should equal(@"some-company");
                subject.loginView.usernameTextField.text should equal(@"some-user");
            });
        });
        
        describe(@"when login in with swimlane instance", ^{
            beforeEach(^{
                userDefaults stub_method(@selector(boolForKey:)).with(@"isConnectStagingServer").and_return(YES);
                userDefaults stub_method(@selector(objectForKey:)).with(@"urlPrefixesStr").and_return(@"swimlane");
                subject.view should_not be_nil;
            });
            
            it(@"should have set company name and user name from Keychain values", ^{
                subject.loginView.companyTextField.text should equal(@"swimlane/some-company");
                subject.loginView.usernameTextField.text should equal(@"some-user");
            });
        });
    });
    
    describe(@"when both EMM and Keychain values are  present", ^{
        beforeEach(^{
            NSDictionary *credentials = @{@"companyName":@"some-company",
                                          @"userName":@"some-user"};
            emmConfigManager stub_method(@selector(companyName)).and_return(@"some-company");
            emmConfigManager stub_method(@selector(userName)).and_return(@"some-user");
            emmConfigManager stub_method(@selector(isEMMValuesStored)).and_return(true);
            loginCredentialsHelper stub_method(@selector(getLoginCredentials)).and_return(credentials);
            subject.view should_not be_nil;
        });
        
        it(@"should have set company name and user name from EMM values", ^{
            subject.loginView.companyTextField.text = @"some-company";
            subject.loginView.usernameTextField.text = @"some-user";
        });
    });
    
    describe(@"when the user selects the trouble signingin", ^{
        __block UIActionSheet *actionSheet;
        
        beforeEach(^{
            [subject loginView:nil troubleSigningInAction:nil];
            actionSheet = [UIActionSheet currentActionSheet];
        });
        
        it(@"should show the Trouble signing in action sheet", ^{
            
            [actionSheet buttonTitles] should equal(@[RPLocalizedString(@"Forgot Password?",nil),
                                                      RPLocalizedString(@"Contact Support", nil),
                                                      RPLocalizedString(@"Cancel", nil)
                                                      ]);
            
            
        });
        
        
        context(@"when the user taps the forgot password button", ^{
            
            beforeEach(^{
                
                [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
            });
            
            it(@"should have loaded the forgot password viewcontroller", ^{
                
                navigationController.topViewController should be_instance_of([ForgotPasswordViewController class]);
            });
        });
        
        context(@"when the user taps the contact support button", ^{
            
            beforeEach(^{
                
                [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
            });
            
            it(@"should have the loaded the mail picker to send the details to support", ^{
                
                subject should have_received(@selector(loginView:feedbackButtonAction:));
                /*Not Supported in Xcode 8*/
                //subject.presentedViewController should be_instance_of([MFMailComposeViewController class]);
            });

            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"start", TrackerProduct);
            });
        });
        
        context(@"when the user taps the cancel button", ^{
            
            beforeEach(^{
                
                [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
            });
            
            it(@"should dismiss the action sheet", ^{
                
                [UIActionSheet currentActionSheet] should be_nil;
                navigationController.topViewController should be_same_instance_as(subject);
            });
        });
    });
    
});

SPEC_END
