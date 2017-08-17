#import <Cedar/Cedar.h>
#import "ApplicationFlowControl.h"
#import "AppDelegate.h"
#import "LoginService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ApplicationFlowControlSpec)

describe(@"ApplicationFlowControl", ^{
    __block ApplicationFlowControl *subject;
    __block AppDelegate *appDelegate;
    __block LoginService *loginService;
    __block NSError *error;
    __block NSUserDefaults *userDefaults;

    beforeEach(^{
        error = nice_fake_for([NSError class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        appDelegate = nice_fake_for([AppDelegate class]);
        loginService = nice_fake_for([LoginService class]);
        subject = [[ApplicationFlowControl alloc] initWithUserDefaults:userDefaults delegate:appDelegate];
    });

    describe(@"-performFlowControlForError", ^{

        context(@"When error is <PasswordAuthenticationErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(PasswordAuthenticationErrorDomain);

            });

            it(@"should navigate to loginViewController with password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SAML");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });

            it(@"should navigate to loginViewController without password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SSO");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(YES);
            });
        });

        context(@"When error is <UserAuthChangeErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(UserAuthChangeErrorDomain);
            });
            it(@"should navigate to loginViewController without password field", ^{
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });
        });

        context(@"When error is <CompanyDisabledErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(CompanyDisabledErrorDomain);
            });
            it(@"should navigate to loginViewController without password field", ^{
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });
        });

        context(@"When error is <UserDisabledErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(UserDisabledErrorDomain);

            });

            it(@"should navigate to loginViewController with password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SAML");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });

            it(@"should navigate to loginViewController without password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SSO");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(YES);
            });
        });

        context(@"When error is <PasswordExpiredErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(PasswordExpiredErrorDomain);

            });

            it(@"should navigate to loginViewController with password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SAML");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });

            it(@"should navigate to loginViewController without password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SSO");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(YES);
            });
        });

        context(@"When error is <NoAuthErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(NoAuthErrorDomain);

            });

            it(@"should navigate to loginViewController with password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SAML");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });

            it(@"should navigate to loginViewController without password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SSO");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(YES);
            });
        });

        context(@"When error is <UnknownErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(UnknownErrorDomain);

            });

            it(@"should navigate to loginViewController with password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SAML");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(NO);
            });

            it(@"should navigate to loginViewController without password field", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"AuthMode").and_return(@"SSO");
                [subject performFlowControlForError:error];
                appDelegate should have_received(@selector(launchLoginViewController:)).with(YES);
            });
        });


    });
});

SPEC_END
