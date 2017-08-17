#import <Cedar/Cedar.h>
#import "LoginService.h"
#import "TabModuleNameProvider.h"
#import "AppDelegate.h"
#import "RepliconSpecHelper.h"
#import "BreakTypeRepository.h"
#import "HomeSummaryDelegate.h"
#import "MobileMonitorURLProvider.h"
#import <repliconkit/AppConfig.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(LoginServiceSpec)

describe(@"LoginService", ^{
    __block LoginService *subject;
    __block TabModuleNameProvider *tabModuleNameProvider;
    __block NSUserDefaults *userDefaults;
    __block AppDelegate *appDelegate;
    __block BreakTypeRepository *breakTypeRepository;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<HomeSummaryDelegate> homeSummaryDelegate;
    __block MobileMonitorURLProvider *mobileMonitorURLProvider;
    __block AppConfig *appConfig;

    beforeEach(^{
        appDelegate = nice_fake_for([AppDelegate class]);
        homeSummaryDelegate = nice_fake_for(@protocol(HomeSummaryDelegate));
        breakTypeRepository = nice_fake_for([BreakTypeRepository class]);
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        tabModuleNameProvider = nice_fake_for([TabModuleNameProvider class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        mobileMonitorURLProvider = nice_fake_for([MobileMonitorURLProvider class]);
        appConfig = nice_fake_for([AppConfig class]);
        subject = [[LoginService alloc] initWithTabModuleNameProvider:tabModuleNameProvider
                                                         userDefaults:userDefaults
                                                      spinnerDelegate:spinnerDelegate
                                                  homeSummaryDelegate:homeSummaryDelegate
                                                          appDelegate:appDelegate
                                             mobileMonitorURLProvider:mobileMonitorURLProvider
                                                            appConfig:appConfig];
        subject.breakTypeRepository = breakTypeRepository;
    });

    describe(@"handleHomeSummaryResponse:", ^{
        __block id<LoginDelegate> loginDelegate;
        __block NSDictionary *homeSummaryDataResponse;
        __block NSDictionary *unpackedHomeSummaryResponse;
        __block NSUInteger callOrderTracker;

        beforeEach(^{
            callOrderTracker = 0;

            loginDelegate = fake_for(@protocol(LoginDelegate));

            homeSummaryDelegate stub_method(@selector(homeSummaryFetcher:didReceiveHomeSummaryResponse:)).and_do_block(^(id a, NSDictionary *b){
                callOrderTracker should equal(0);
                callOrderTracker += 1;
            });

            loginDelegate stub_method(@selector(loginServiceDidFinishLoggingIn:)).and_do_block(^(LoginService *a){
                callOrderTracker should equal(1);
                callOrderTracker += 1;
            });

            [subject sendrequestToFetchHomeSummaryWithDelegate:loginDelegate];

            homeSummaryDataResponse = [RepliconSpecHelper jsonWithFixture:@"home_summary_response"];
            unpackedHomeSummaryResponse = homeSummaryDataResponse[@"d"];
            NSDictionary *responseDictionary = @{
                                                 @"refDict": @{@"refID": @1},
                                                 @"response": homeSummaryDataResponse
                                                 };
            [subject serverDidRespondWithResponse:responseDictionary];
        });

        it(@"should notify the app delegate that it is not the first time launch", ^{
            appDelegate should have_received(@selector(setIsNotFirstTimeLaunch:)).with(YES);
        });

        it(@"should notify the home summary delegate that the request completed", ^{
            homeSummaryDelegate should have_received(@selector(homeSummaryFetcher:didReceiveHomeSummaryResponse:)).with(subject, unpackedHomeSummaryResponse);
        });

        it(@"should notify the login delegate that the request completed", ^{
            loginDelegate should have_received(@selector(loginServiceDidFinishLoggingIn:)).with(subject);
        });
    });

    describe(@"as a <LoginDelegate>", ^{
        describe(NSStringFromSelector(@selector(loginServiceDidFinishLoggingIn:)), ^{
            beforeEach(^{
                [subject loginServiceDidFinishLoggingIn:nil];
            });

            it(@"should tell the spinner delegate to stop spinning", ^{
                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
            });
        });
    });
});

SPEC_END
