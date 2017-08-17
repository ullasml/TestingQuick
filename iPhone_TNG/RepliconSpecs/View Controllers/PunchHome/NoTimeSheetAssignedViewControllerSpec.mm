#import <Cedar/Cedar.h>
#import "Theme.h"
#import <KSDeferred/KSDeferred.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "NoTimeSheetAssignedViewController.h"
#import "ButtonStylist.h"
#import "UIControl+Spec.h"
#import "Constants.h"
#import "SpinnerDelegate.h"
#import "AppDelegate.h"
#import "HomeSummaryRepository.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "HomeSummaryDelegate.h"
#import "SupportDataModel.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NoTimeSheetAssignedViewControllerSpec)

describe(@"NoTimeSheetAssignedViewController", ^{
    __block NoTimeSheetAssignedViewController *subject;
    __block id<Theme> theme;
    __block id<BSInjector, BSBinder> injector;
    __block ButtonStylist *buttonStylist;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block KSDeferred *homeSummaryDeferred;
    __block AppDelegate *appDelegate;
    __block id<HomeSummaryDelegate> homeSummaryDelegate;
    __block HomeSummaryRepository *homeFlowRepository;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block SupportDataModel *supportDataModel;
    beforeEach(^{
        injector = [InjectorProvider injector];
    });
    
    
    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        
        
        homeSummaryDelegate = nice_fake_for(@protocol(HomeSummaryDelegate));

        homeSummaryDeferred = [[KSDeferred alloc] init];
        appDelegate = nice_fake_for([AppDelegate class]);;

        supportDataModel = nice_fake_for([SupportDataModel class]);;
        
        homeFlowRepository = nice_fake_for([HomeSummaryRepository class]);
        [injector bind:[HomeSummaryRepository class] toInstance:homeFlowRepository];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        
        buttonStylist =  nice_fake_for([ButtonStylist class]);
        
        subject = [[NoTimeSheetAssignedViewController alloc] initWithHomeSummaryRepository:homeFlowRepository
                                                                       homeSummaryDelegate:homeSummaryDelegate
                                                                       reachabilityMonitor:reachabilityMonitor
                                                                          supportDataModel:supportDataModel
                                                                           spinnerDelegate:spinnerDelegate
                                                                                buttonStylist:buttonStylist
                                                                                  appDelegate:appDelegate
                                                                                        theme:theme];
        
        spy_on(subject);
        subject.refreshButton.titleLabel.text = RPLocalizedString(RefreshButtonTitle, RefreshButtonTitle);
        subject.msgLabel.text = RPLocalizedString(NoTimeSheetAssignedMsg, NoTimeSheetAssignedMsg);

    });
    
    
    describe(@"styling", ^{
        beforeEach(^{
            theme stub_method(@selector(supervisorDashboardBackgroundColor)).and_return([UIColor orangeColor]);
            subject.view should_not be_nil;
        });
        
        it(@"should style the background", ^{
            subject.view.backgroundColor should equal([UIColor orangeColor]);
        });
    });

    
    
    describe(@"after the view loads", ^{
        beforeEach(^{
            theme stub_method(@selector(teamStatusValueFont)).and_return([UIFont italicSystemFontOfSize:17.0f]);
            theme stub_method(@selector(viewTimesheetButtonTitleColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(viewTimesheetButtonBackgroundColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(viewTimesheetButtonBorderColor)).and_return([UIColor redColor]);
            [subject view];
        });
        
        it(@"should have a 'Refresh' button", ^{
            subject.view should contain(subject.refreshButton);
        });
        
        it(@"should have a Message Label button", ^{
            subject.view should contain(subject.msgLabel);
        });
        
        it(@"should have a Message", ^{
            subject.msgLabel.text should equal(RPLocalizedString(NoTimeSheetAssignedMsg, NoTimeSheetAssignedMsg));
        });
        
        it(@"use its stylist to style the button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
            .with(subject.refreshButton, RPLocalizedString(RefreshButtonTitle, RefreshButtonTitle), [UIColor orangeColor], [UIColor yellowColor], [UIColor redColor]);
        });
        
        it(@"use theme to set message font and textcolor", ^{
            subject.msgLabel.font should equal([UIFont italicSystemFontOfSize:17.0f]);
        });

    });
    
    describe(@"when the user taps the 'Refresh' button", ^{
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            subject.view should_not be_nil;
            [subject.refreshButton tap];
        });
        
        it(@"should display the spinner", ^{
            spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
        });
        
        it(@"should send request to get home flow service", ^{
            homeFlowRepository should have_received(@selector(getHomeSummary));
        });

    });
    
    describe(@"when the request for the homeSummary details completes", ^{
        __block NSDictionary *homeSummaryResponse;
        
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            homeSummaryResponse =  @{@"d":
                                    @{
                                    @"userSummary": @{
                                            @"approvalCapabilities":@{
                                                    @"expenseApprovalCapabilities":@{
                                                            @"areRejectCommentsRequired":@YES,
                                                            @"isExpenseApprover":@YES
                                                            },
                                                    @"timeoffApprovalCapabilities":@{
                                                            @"areRejectCommentsRequired":@YES,
                                                            @"isTimeOffApprover":@NO
                                                            },
                                                    @"timesheetApprovalCapabilities":@{
                                                            @"areRejectCommentsRequired":@YES,
                                                            @"isTimesheetApprover":@YES
                                                            }
                                                    },
                                            @"timePunchCapabilities": @{
                                                    @"geolocationRequired": @YES,
                                                    @"hasBreakAccess": @NO,
                                                    @"auditImageRequired": @YES,
                                                    @"canEditTimePunch": @YES,
                                                    @"canViewTeamTimePunch":@YES,
                                                    }
                                            ,
                                            @"payDetailCapabilities":@{
                                                    @"canViewTeamPayDetails":@YES,
                                                    }
                                            ,
                                            @"timesheetCapabilities":@{
                                                    @"hasTimesheetAccess":@YES,
                                                    }
                                            }
                                    }
                                     
                        };

            homeFlowRepository stub_method(@selector(getHomeSummary)).and_return(homeSummaryDeferred.promise);
            [homeSummaryDeferred resolveWithValue:homeSummaryResponse];
            
            subject.view should_not be_nil;
            [subject.refreshButton tap];

        });
        
        it(@"should update supportmodel", ^{
            supportDataModel should have_received(@selector(updateTimesheetPermission:)).with(YES);
        });
        
        it(@"should restore all modules based on home summary permissions", ^{
            NSDictionary *responseDataDictionary = homeSummaryResponse[@"d"];
            homeSummaryDelegate should have_received(@selector(homeSummaryFetcher:didReceiveHomeSummaryResponse:)).with(subject, responseDataDictionary);
        });
        
        it(@"should reset the tab", ^{
            appDelegate should have_received(@selector(launchTabBarController));
        });
        
        it(@"should hide the spinner", ^{
            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
        });
        
    });
    
    describe(@"when the homeSummary details cannot be fetched", ^{
        __block NSError *error;
        
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            homeFlowRepository stub_method(@selector(getHomeSummary)).and_return(homeSummaryDeferred.promise);
            [homeSummaryDeferred rejectWithError:error];
            
            subject.view should_not be_nil;
            [subject.refreshButton tap];

        });
        
        it(@"should hide the spinner", ^{
            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
        });
    });



});

SPEC_END
