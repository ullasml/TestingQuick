#import <Cedar/Cedar.h>
#import "ErrorPresenter.h"
#import "LoginService.h"
#import "AppDelegate.h"
#import "UIAlertView+Spec.h"
#import <repliconkit/ReachabilityMonitor.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorPresenterSpec)

describe(@"ErrorPresenter", ^{
    __block ErrorPresenter *subject;
    __block LoginService *loginService;
    __block AppDelegate *delegate;
    __block NSError *error;
    __block ReachabilityMonitor *reachabilityMonitor;
    
    beforeEach(^{
        error = nice_fake_for([NSError class]);
        loginService = nice_fake_for([LoginService class]);
        delegate = nice_fake_for([AppDelegate class]);
        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        
        subject = [[ErrorPresenter alloc] initWithReachabilityMonitor:reachabilityMonitor
                                                         loginService:loginService
                                                             delegate:delegate];

    });

    describe(@"-presentAlertViewForError", ^{

        context(@"When error is <RepliconNoAlertErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(RepliconNoAlertErrorDomain);
                [subject presentAlertViewForError:error];
            });

            it(@"should not present any alert", ^{
                [UIAlertView currentAlertView] should be_nil;
            });
        });

        context(@"When error is <RepliconHTTPNonJsonResponseErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(RepliconHTTPNonJsonResponseErrorDomain);
                [subject presentAlertViewForError:error];
            });

            it(@"should not present any alert", ^{
                [UIAlertView currentAlertView] should be_nil;
            });
        });
        context(@"When error is from online <RepliconHTTPRequestErrorDomain>", ^{
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"http error"};
                error stub_method(@selector(domain)).and_return(RepliconHTTPRequestErrorDomain);
                error stub_method(@selector(userInfo)).and_return(userInfo);
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                [subject presentAlertViewForError:error];
            });
            
            it(@"should present alert", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                alert.message should equal(@"http error");
                alert.delegate should be_nil;
                alert.title should be_nil;
                alert.tag should equal(100002);
                alert.numberOfButtons should equal(1);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                
            });
        });

        describe(@"When error is from offline <RepliconHTTPRequestErrorDomain>", ^{
            beforeEach(^{
                error stub_method(@selector(domain)).and_return(RepliconHTTPRequestErrorDomain);
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                [subject presentAlertViewForError:error];
            });
            
            it(@"should not present any alert", ^{
                [UIAlertView currentAlertView] should be_nil;
            });
        });
        
        context(@"When error is not <RepliconNoAlertErrorDomain>", ^{
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                error stub_method(@selector(domain)).and_return(UnknownErrorDomain);
                error stub_method(@selector(userInfo)).and_return(userInfo);
                [subject presentAlertViewForError:error];
            });

            it(@"should present alert", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                alert.message should equal(@"some fake error");
                alert.delegate should be_nil;
                alert.title should be_nil;
                alert.numberOfButtons should equal(1);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
        });

        context(@"When error is  <RepliconFailureStatusCodeDomain>", ^{
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                error stub_method(@selector(domain)).and_return(RepliconFailureStatusCodeDomain);
                error stub_method(@selector(userInfo)).and_return(userInfo);
                [subject presentAlertViewForError:error];
            });

            it(@"should present alert", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                alert.message should equal(@"some fake error");
                alert.delegate should be_same_instance_as(delegate);
                alert.title should be_nil;
                alert.tag should equal(555);
                alert.numberOfButtons should equal(1);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(APP_REFRESH_DATA_TITLE, @""));
            });
        });

        context(@"When error is  <PasswordExpiredErrorDomain>", ^{
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                error stub_method(@selector(domain)).and_return(PasswordExpiredErrorDomain);
                error stub_method(@selector(userInfo)).and_return(userInfo);
                [subject presentAlertViewForError:error];
            });

            it(@"should present alert", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                alert.message should equal(@"some fake error");
                alert.delegate should be_same_instance_as(loginService);
                alert.title should be_nil;
                alert.tag should equal(9123);
                alert.numberOfButtons should equal(1);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
        });

        context(@"When error is  <UriErrorDomain>", ^{
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                error stub_method(@selector(domain)).and_return(UriErrorDomain);
                error stub_method(@selector(userInfo)).and_return(userInfo);
                [subject presentAlertViewForError:error];
            });

            it(@"should present alert", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                alert.message should equal(@"some fake error");
                alert.delegate should be_same_instance_as(delegate);
                alert.title should be_nil;
                alert.tag should equal(1001);
                alert.numberOfButtons should equal(1);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
        });

        context(@"When error is <AuthorizationErrorDomain>", ^{
            beforeEach(^{
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error"};
                error stub_method(@selector(domain)).and_return(AuthorizationErrorDomain);
                error stub_method(@selector(userInfo)).and_return(userInfo);
                [subject presentAlertViewForError:error];
            });

            it(@"should present alert", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                alert.message should equal(@"some fake error");
                alert.delegate should be_same_instance_as(delegate);
                alert.title should be_nil;
                alert.tag should equal(555);
                alert.numberOfButtons should equal(1);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(APP_REFRESH_DATA_TITLE, @""));
            });
        });

    });
});

SPEC_END
