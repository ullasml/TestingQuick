#import <Cedar/Cedar.h>
#import "MoreViewController.h"
#import "DoorKeeper.h"
#import "UIControl+Spec.h"
#import "LaunchLoginDelegate.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "PunchOutboxStorage.h"
#import "UIAlertView+Spec.h"

#import "UIGestureRecognizer+Spec.h"
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSPromise.h>
#import <KSDeferred/KSDeferred.h>
#import <repliconkit/repliconkit.h>
#import "AppDelegate.h"
#import "UISwitch+Spec.h"
#import "MobileAppConfigRequestProvider.h"
#import "LoginModel.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(MoreViewControllerSpec)

describe(@"MoreViewController", ^{
    __block MoreViewController *subject;
    __block DoorKeeper *doorKeeper;
    __block NSUserDefaults *userDefaults;
    __block id<LaunchLoginDelegate> launchLoginDelegate;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block PunchOutboxStorage *punchStorage;
    __block MobileAppConfigRequestProvider *mobileAppConfigRequestProvider;
    __block id<BSBinder, BSInjector> injector;
    __block KSDeferred *configDeferred;
    __block AppConfigRepository *appConfigRepository;
    __block AppConfig *appConfig;
    __block AppDelegate *appDelegate;
    __block LoginModel *loginModel;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
    });

    beforeEach(^{
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        launchLoginDelegate = nice_fake_for(@protocol(LaunchLoginDelegate));
        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        punchStorage = nice_fake_for([PunchOutboxStorage class]);
        punchStorage stub_method(@selector(allPunches));
        mobileAppConfigRequestProvider = nice_fake_for([MobileAppConfigRequestProvider class]);
        appConfigRepository = nice_fake_for([AppConfigRepository class]);
        appConfig = nice_fake_for([AppConfig class]);
        appDelegate = nice_fake_for([AppDelegate class]);
        configDeferred =  [[KSDeferred alloc] init];
        loginModel = nice_fake_for([LoginModel class]);
        [injector bind:[LoginModel class] toInstance:loginModel];

        subject = [[MoreViewController alloc] initWithAppConfigRequestProvider:mobileAppConfigRequestProvider
                                                           launchLoginDelegate:launchLoginDelegate
                                                           appConfigRepository:appConfigRepository
                                                                     appConfig:appConfig
                                                           reachabilityMonitor:reachabilityMonitor
                                                                  userDefaults:userDefaults
                                                                   appDelegate:appDelegate
                                                                    doorKeeper:doorKeeper
                                                                        outbox:punchStorage
                                                                    loginModel:loginModel];

    });

    describe(@"clicking on the logout button", ^{

        beforeEach(^{
            subject.view should_not be_nil;
        });
        context(@"Showing alert to user that punches are still not synced ", ^{

            context(@"Should not show alertview", ^{
                beforeEach(^{
                     punchStorage stub_method(@selector(allPunches)).again().and_return(nil);
                    [subject.logOutButton tap];

                });
                it(@"should ask the punchstorage for all punches", ^{
                    punchStorage should have_received(@selector(allPunches));
                });

                it(@"should not show the alert", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView should be_nil;
                });
            });

            context(@"Should not show alertview", ^{
                beforeEach(^{
                    punchStorage stub_method(@selector(allPunches)).again().and_return(@[@"My-PunchObject"]);
                    [subject.logOutButton tap];
                });

                it(@"should ask the punchstorage for all punches", ^{
                    punchStorage should have_received(@selector(allPunches));
                });

                it(@"should show the alert", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView should_not be_nil;
                    alertView.message should equal(RPLocalizedString(@"Some of your punch data has not been saved on the Replicon server.  Please ensure your device has an Internet connection to sync the data.", nil));
                });
            });
        });
        context(@"when the auth mode is SAML", ^{
            beforeEach(^{

                userDefaults stub_method(@selector(objectForKey:))
                    .with(@"AuthMode")
                    .and_return(@"SAML");
                [subject.logOutButton tap];
            });

            it(@"should not notify the launch login delegate to launch the login view controller", ^{
                launchLoginDelegate should_not have_received(@selector(launchLoginViewController:));
            });
        });

        context(@"when the auth mode is not SAML", ^{
            beforeEach(^{

                userDefaults stub_method(@selector(objectForKey:))
                    .with(@"AuthMode")
                    .and_return(@"NotSAML");

                [subject.logOutButton tap];
            });

            it(@"should notify the door keeper that the user wishes to logout", ^{
                doorKeeper should have_received(@selector(logOut));
            });

            it(@"should notify the launch login delegate to launch the login view controller", ^{
                launchLoginDelegate should have_received(@selector(launchLoginViewController:));
            });
        });
    });
    
    describe(@"node switch button action", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
            spy_on(subject.nodeSwitch);
            spy_on(subject.appConfig);
            subject.nodeSwitch.hidden =  NO;
        });
        
        context(@"when user switch on toggle button", ^{
            beforeEach(^{
                [subject.nodeSwitch toggle];
            });

            it(@"should not notify the launch login delegate to launch the login view controller", ^{
                subject.appConfig  should have_received(@selector(setNodeBackend:)).with(YES);
            });
        });
        
        context(@"when user switch off toggle button", ^{
            beforeEach(^{
                [subject.nodeSwitch setOn:YES];
                [subject.nodeSwitch toggle];
            });

            it(@"should not notify the launch login delegate to launch the login view controller", ^{
                subject.appConfig  should have_received(@selector(setNodeBackend:)).with(NO);
            });
        });
    });
    
    describe(@"enable node switch button", ^{
        context(@"when network available", ^{
            __block UIGestureRecognizer *gestureRecognizer;
            beforeEach(^{
                appConfigRepository stub_method(@selector(appConfigForRequest:)).and_return(configDeferred.promise);
                //gestureRecognizer = nice_fake_for([UIGestureRecognizer class]);
                //[injector bind:[UIGestureRecognizer class] toInstance:gestureRecognizer];
                subject.view should_not be_nil;
                //spy_on(subject.nodeSwitch);
                //[gestureRecognizer recognize];
                [subject doSevenTaps];
            });
            
            context(@"when the request is successful", ^{
                beforeEach(^{
                    [configDeferred resolveWithValue:nil];
                });
                
                it(@"should enable switch button", ^{
                    subject.nodeSwitch.hidden should equal(NO);
                    subject.nodeLabel.hidden should equal(NO);
                });
                
                it(@"should remove overlay from view", ^{
                    appDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
            });
            
            context(@"when the request is failed", ^{
                beforeEach(^{
                    [configDeferred rejectWithError:nil];
                });
                
                it(@"should enable switch button", ^{
                    subject.nodeSwitch.hidden should equal(NO);
                    subject.nodeLabel.hidden should equal(NO);
                });
                
                it(@"should remove overlay from view", ^{
                    appDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
            });
        });
        
        context(@"when network not available", ^{
            __block UIGestureRecognizer *gestureRecognizer;
            beforeEach(^{
                appConfigRepository stub_method(@selector(appConfigForRequest:)).and_return(nil);
                //gestureRecognizer = nice_fake_for([UIGestureRecognizer class]);
                //[injector bind:[UIGestureRecognizer class] toInstance:gestureRecognizer];
                subject.view should_not be_nil;
                //spy_on(subject.nodeSwitch);
                //[gestureRecognizer recognize];
                [subject doSevenTaps];
            });
            
            it(@"should enable switch button", ^{
                subject.nodeSwitch.hidden should equal(NO);
                subject.nodeLabel.hidden should equal(NO);
            });
            
            it(@"should remove overlay from view", ^{
                appDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
            });
        });
    });
    
    describe(@"view will appear", ^{
        context(@"should hide node switch buttons", ^{
            beforeEach(^{
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                
            });
            
            it(@"should hide switch button", ^{
                subject.nodeSwitch.hidden should equal(YES);
                subject.nodeLabel.hidden should equal(YES);
            });
            
        });
    });
    
    describe(@"display logged in user info", ^{
        
        context(@"when user details are not empty", ^{
            beforeEach(^{
                loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(@[@{@"displayText":@"Reddy, Anil"}]);
                [subject view];
            });
            
            it(@"should display logged in username", ^{
                subject.versionLabel.text should equal(@"Logged in as: Reddy, Anil");
            });
        });
        
        
        context(@"when user details are empty", ^{
            beforeEach(^{
                loginModel stub_method(@selector(getAllUserDetailsInfoFromDb)).and_return(nil);
                [subject view];
            });
            
            it(@"should display logged in username", ^{
                subject.versionLabel should be_nil;
            });
        });
        
        
        
    });
    
});

SPEC_END
