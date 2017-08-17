#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "UIBarButtonItem+Spec.h"
#import "ApproveTimesheetContainerController.h"
#import "InjectorProvider.h"
#import "TimesheetRepository.h"
#import "ChildControllerHelper.h"
#import <KSDeferred/KSDeferred.h>
#import "Timesheet.h"
#import "TimesheetDetailsController.h"
#import "ApprovalsScrollViewController.h"
#import "SpinnerDelegate.h"
#import "ApprovalsModel.h"
#import "ApprovalsService.h"
#import "LegacyTimesheetApprovalInfo.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "AstroAwareTimesheet.h"
#import "RepliconSpecHelper.h"
#import "WrongConfigurationMessageViewController.h"
#import "UIBarButtonItem+Spec.h"
#import "ApprovalActionsViewController.h"
#import "OEFTypesRepository.h"
#import "OEFType.h"
#import "TimesheetInfo.h"
#import <repliconkit/AppConfig.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApproveTimesheetContainerControllerSpec)

describe(@"ApproveTimesheetContainerController", ^{
    __block ApproveTimesheetContainerController *subject;
    __block TimesheetRepository *timesheetRepository;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block ApprovalsModel *approvalsModel;
    __block ApprovalsService *approvalsService;
    __block ChildControllerHelper *childControllerHelper;
    __block id<Timesheet> userlessTimesheet;
    __block id<ApproveTimesheetContainerControllerDelegate> delegate;
    __block id<BSInjector, BSBinder> injector;
    __block LegacyTimesheetApprovalInfo *legacyTimesheetApprovalInfo;
    __block id approvalPendingTimesheetDelegate;
    __block UINavigationController *navigationController;
    __block OEFTypesRepository *oefTypesRepository;
    __block  AppConfig *appConfig;
    __block ApprovalActionsViewController *approvalActionsViewController;
    __block WidgetTimesheetRepository *widgetTimesheetRepository;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        widgetTimesheetRepository = nice_fake_for([WidgetTimesheetRepository class]);
        [injector bind:[WidgetTimesheetRepository class] toInstance:widgetTimesheetRepository];

        approvalPendingTimesheetDelegate = nice_fake_for([ApprovalsPendingTimesheetViewController class]);

        legacyTimesheetApprovalInfo = nice_fake_for([LegacyTimesheetApprovalInfo class]);
        legacyTimesheetApprovalInfo stub_method(@selector(delegate)).and_return(approvalPendingTimesheetDelegate);

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        timesheetRepository = nice_fake_for([TimesheetRepository class]);
        [injector bind:[TimesheetRepository class] toInstance:timesheetRepository];
        
        oefTypesRepository = nice_fake_for([OEFTypesRepository class]);
        [injector bind:[OEFTypesRepository class] toInstance:oefTypesRepository];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        approvalsModel = nice_fake_for([ApprovalsModel class]);
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];

        approvalsService = nice_fake_for([ApprovalsService class]);
        [injector bind:[ApprovalsService class] toInstance:approvalsService];
        spy_on(approvalsService);

        approvalActionsViewController = [injector getInstance:[ApprovalActionsViewController class]];
        [approvalActionsViewController setUpWithSheetUri:@"my-uri" selectedSheet:@"sample sheet" allowBlankComments:YES actionType:@"Reopen" delegate:subject];
        [injector bind:[ApprovalActionsViewController class] toInstance:approvalActionsViewController];
        
        appConfig = nice_fake_for([AppConfig class]);
        [injector bind:[AppConfig class] toInstance:appConfig];

        subject = [injector getInstance:[ApproveTimesheetContainerController class]];
        spy_on(subject);

        userlessTimesheet = nice_fake_for(@protocol(Timesheet));
        delegate = nice_fake_for(@protocol(ApproveTimesheetContainerControllerDelegate));
        [subject setupWithLegacyTimesheetApprovalInfo:legacyTimesheetApprovalInfo
                                            timesheet:userlessTimesheet
                                             delegate:delegate
                                                title:@"The Expected Title"
                                           andUserUri:@"my-special-user-uri"];

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
    });
    
    
    describe(@"isWidgetPlatformSupported Check", ^{
        
        context(@"when isWidgetPlatformSupported", ^{
            
            describe(@"when called from pending approvals", ^{
                
                beforeEach(^{
                    legacyTimesheetApprovalInfo stub_method(@selector(isFromPendingApprovals)).and_return(YES);
                    [subject setupWithLegacyTimesheetApprovalInfo:legacyTimesheetApprovalInfo
                                                        timesheet:userlessTimesheet
                                                         delegate:delegate
                                                            title:@"The Expected Title"
                                                       andUserUri:@"my-special-user-uri"];
                });
                
                __block KSDeferred *deferred;
                __block AstroAwareTimesheet *userTimesheet;
                __block KSDeferred *widgetTimesheetsDeferred;
                __block WidgetTimesheetDetailsController *widgetTimesheetDetailsController;
                
                
                beforeEach(^{
                    widgetTimesheetDetailsController = nice_fake_for([WidgetTimesheetDetailsController class]);
                    [injector bind:[WidgetTimesheetDetailsController class] toInstance:widgetTimesheetDetailsController];
                    
                    userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                    deferred = [[KSDeferred alloc] init];
                    widgetTimesheetsDeferred = [[KSDeferred alloc] init];
                    
                    widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"the-expected-uri").and_return(widgetTimesheetsDeferred.promise);
                    
                    userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
                    timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                    .with(@"the-expected-uri")
                    .and_return(deferred.promise);
                    appConfig stub_method(@selector(getTimesheetWidgetPlatform))
                    .and_return(true);
                    subject.view should_not be_nil;
                    [deferred resolveWithValue:@1];
                });
                
                it(@"should correctly display the widget Timesheet Details Controller", ^{
                    widgetTimesheetRepository should have_received(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"the-expected-uri");
                    
                });
                
                context(@"when the widget timesheet promise is success", ^{
                    __block WidgetTimesheet *widgetTimesheet;
                    __block TimesheetApprovalTimePunchCapabilities *timesheetApprovalTimePunchCapabilities;
                   
                    beforeEach(^{
                        widgetTimesheet = nice_fake_for([WidgetTimesheet class]);
                        timesheetApprovalTimePunchCapabilities = nice_fake_for([TimesheetApprovalTimePunchCapabilities class]);
                        timesheetApprovalTimePunchCapabilities stub_method(@selector(hasBreakAccess)).and_return(YES);
                        widgetTimesheet stub_method(@selector(approvalTimePunchCapabilities)).and_return(timesheetApprovalTimePunchCapabilities);
                        [widgetTimesheetsDeferred resolveWithValue:widgetTimesheet];
                    });
                    
                    it(@"should correctly set the title", ^{
                        subject.title should equal(@"The Expected Title");
                    });
                    it(@"should show the approve bar button with correct title", ^{
                        subject.navigationItem.rightBarButtonItem should_not be_nil;
                        subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Approve", nil));
                    });
                    
                    it(@"should set up WidgetTimesheetDetailsController correctly", ^{
                        widgetTimesheetDetailsController should have_received(@selector(setupWithWidgetTimesheet:delegate:hasBreakAccess:isSupervisorContext:userUri:)).with(widgetTimesheet,nil,YES,YES,@"my-special-user-uri");
                    });
                    
                    it(@"should hide a spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    it(@"should present a WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                        .with(widgetTimesheetDetailsController, subject, subject.view);
                    });
                });
                
                context(@"when the widget timesheet promise fails", ^{
                    beforeEach(^{
                        [widgetTimesheetsDeferred rejectWithError:nil];
                    });
                    
                    it(@"should hide a spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    it(@"should not present a TimesheetDetailsController", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:));
                    });
                });
                
                
            });
            
            describe(@"when called from previous approvals", ^{
                beforeEach(^{
                    legacyTimesheetApprovalInfo stub_method(@selector(isFromPreviousApprovals)).and_return(YES);
                    [subject setupWithLegacyTimesheetApprovalInfo:legacyTimesheetApprovalInfo
                                                        timesheet:userlessTimesheet
                                                         delegate:delegate
                                                            title:@"The Expected Title"
                                                       andUserUri:@"my-special-user-uri"];
                });
                
                __block KSDeferred *deferred;
                __block AstroAwareTimesheet *userTimesheet;
                __block KSDeferred *widgetTimesheetsDeferred;
                __block WidgetTimesheetDetailsController *widgetTimesheetDetailsController;
                
                
                beforeEach(^{
                    widgetTimesheetDetailsController = nice_fake_for([WidgetTimesheetDetailsController class]);
                    [injector bind:[WidgetTimesheetDetailsController class] toInstance:widgetTimesheetDetailsController];
                    
                    userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                    deferred = [[KSDeferred alloc] init];
                    widgetTimesheetsDeferred = [[KSDeferred alloc] init];
                    
                    widgetTimesheetRepository stub_method(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"the-expected-uri").and_return(widgetTimesheetsDeferred.promise);
                    
                    userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
                    timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                    .with(@"the-expected-uri")
                    .and_return(deferred.promise);
                    appConfig stub_method(@selector(getTimesheetWidgetPlatform))
                    .and_return(true);
                    subject.view should_not be_nil;
                    [deferred resolveWithValue:@1];
                });
                
                
                it(@"should correctly display the widget Timesheet Details Controller", ^{
                    widgetTimesheetRepository should have_received(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"the-expected-uri");
                    
                });
                
                context(@"when the widget timesheet promise is success", ^{
                    __block WidgetTimesheet *widgetTimesheet;
                    __block TimesheetApprovalTimePunchCapabilities *timesheetApprovalTimePunchCapabilities;
                    beforeEach(^{
                        widgetTimesheet = nice_fake_for([WidgetTimesheet class]);
                        timesheetApprovalTimePunchCapabilities = nice_fake_for([TimesheetApprovalTimePunchCapabilities class]);
                        timesheetApprovalTimePunchCapabilities stub_method(@selector(hasBreakAccess)).and_return(YES);
                        widgetTimesheet stub_method(@selector(approvalTimePunchCapabilities)).and_return(timesheetApprovalTimePunchCapabilities);
                        [widgetTimesheetsDeferred resolveWithValue:widgetTimesheet];
                    });
                    
                    it(@"should show the approve bar button with correct title", ^{
                        subject.navigationItem.rightBarButtonItem should be_nil;
                    });
                    
                    it(@"should correctly set the title", ^{
                        subject.title should equal(@"The Expected Title");
                    });
                    
                    it(@"should set up WidgetTimesheetDetailsController correctly", ^{
                        widgetTimesheetDetailsController should have_received(@selector(setupWithWidgetTimesheet:delegate:hasBreakAccess:isSupervisorContext:userUri:)).with(widgetTimesheet,nil,YES,YES,@"my-special-user-uri");
                    });
                    
                    it(@"should hide a spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    it(@"should present a WidgetTimesheetDetailsController", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                        .with(widgetTimesheetDetailsController, subject, subject.view);
                    });
                });
                
                context(@"when the widget timesheet promise fails", ^{
                    beforeEach(^{
                        [widgetTimesheetsDeferred rejectWithError:nil];
                    });
                    
                    it(@"should hide a spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    it(@"should not present a TimesheetDetailsController", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:));
                    });
                });
                
                
            });
            
        });
        
        context(@"when not supported", ^{
            __block KSDeferred *widgetSupportDeferred;
            
            beforeEach(^{
                widgetSupportDeferred = [[KSDeferred alloc] init];
                timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                .with(@"my-special-timesheet-uri")
                .and_return(widgetSupportDeferred.promise);
                appConfig stub_method(@selector(getTimesheetWidgetPlatform))
                .and_return(true);
            });
            
            context(@"presenting the correct child controller", ^{
                __block KSDeferred *deferred;
                __block AstroAwareTimesheet *userTimesheet;
                __block UIViewController *expectedViewController;
                
                beforeEach(^{
                    userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                    deferred = [[KSDeferred alloc] init];
                    
                    userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
                    
                    timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
                    .with(@"the-expected-uri")
                    .and_return(deferred.promise);
                });
                
                describe(@"ApproveTimesheetContainerController on ViewDidLoad", ^{
                    __block  NSMutableArray *oefTypesArray;
                    
                    beforeEach(^{
                        
                        OEFType *oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                        
                        OEFType *oeftype2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                        
                        oefTypesArray = [NSMutableArray arrayWithArray:@[oeftype1, oeftype2]];
                        
                        subject.view should_not be_nil;
                        
                        [subject viewDidLoad];
                        
                        [widgetSupportDeferred resolveWithValue:@0];
                    });
                    
                    it(@"Should have called fetchOEFTypesWithUserURI:", ^{
                        
                        subject.oefTypesRepository should have_received(@selector(fetchOEFTypesWithUserURI:)).with(@"my-special-user-uri");
                    });
                    
                });
                
                describe(@"when called from pending approvals", ^{
                    
                    beforeEach(^{
                        widgetSupportDeferred = [[KSDeferred alloc] init];
                        timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                        .with(@"the-expected-uri")
                        .and_return(widgetSupportDeferred.promise);
                        legacyTimesheetApprovalInfo stub_method(@selector(isFromPendingApprovals)).and_return(YES);
                        subject.view should_not be_nil;
                        [widgetSupportDeferred resolveWithValue:@0];
                    });
                    
                    it(@"should have set edgesForExtendedLayout correctly", ^{
                        subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
                    });
                    
                    it(@"should add the transparent loading overlay", ^{
                        spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    });
                    
                    context(@"when the timesheet is an astro timesheet", ^{
                        __block KSDeferred *timesheetInfoDeferred;
                        beforeEach(^{
                            expectedViewController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                                 childControllerHelper:nil
                                                                                                                 timeSummaryRepository:nil
                                                                                                                   violationRepository:nil
                                                                                                                   auditHistoryStorage:NULL
                                                                                                                     punchRulesStorage:nil
                                                                                                                                 theme:nil];
                            
                            [injector bind:[TimesheetDetailsController class] toInstance:expectedViewController];
                            
                            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            
                            timesheetInfoDeferred = [[KSDeferred alloc] init];
                            
                            
                            timesheetRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:))
                            .with(@"the-expected-uri")
                            .and_return(timesheetInfoDeferred.promise);
                            
                            
                            [deferred resolveWithValue:userTimesheet];
                        });
                        
                        context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                            beforeEach(^{
                                [timesheetInfoDeferred resolveWithValue:userlessTimesheet];
                            });
                            
                            it(@"should hide transparent loading overlay", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should present the expected view controller", ^{
                                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                                .with(expectedViewController, subject, subject.view);
                            });
                            
                            it(@"should setup the TimesheetDetailsController with its dynamic dependencies", ^{
                                TimesheetDetailsController *timesheetDetailsController = (id)expectedViewController;
                                //[[timesheetDetailsController timesheetPromise] value] should be_same_instance_as(userlessTimesheet);//FIXME
                            });
                            
                            it(@"should set the title correctly for the astro case", ^{
                                subject.title should equal(@"The Expected Title");
                            });
                            
                            it(@"should show the approve bar button with correct title", ^{
                                subject.navigationItem.rightBarButtonItem should_not be_nil;
                                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Approve", nil));
                            });
                        });
                        
                        
                        
                        describe(@"approving the selected timesheet", ^{
                            beforeEach(^{
                                [timesheetInfoDeferred resolveWithValue:userlessTimesheet];
                                [subject.navigationItem.rightBarButtonItem tap];
                            });
                            
                            it(@"should tell its delegate", ^{
                                delegate should have_received(@selector(approveTimesheetContainerController:didApproveTimesheet:)).with(subject, userlessTimesheet);
                            });
                        });
                        
                        
                    });
                    
                    context(@"when the timesheet is an astro timesheet with client, project and activity access", ^{
                        beforeEach(^{
                            expectedViewController = [[WrongConfigurationMessageViewController alloc] initWithTheme:nil];
                            
                            [injector bind:[WrongConfigurationMessageViewController class] toInstance:expectedViewController];
                            
                            NSDictionary *timesheetDictionary = @{
                                                                  @"d": @{
                                                                          @"capabilities":@{
                                                                                  @"timePunchCapabilities": @{
                                                                                          @"hasProjectAccess":@1 ,
                                                                                          @"hasClientAccess":@1 ,
                                                                                          @"hasActivityAccess":@1 ,
                                                                                          }
                                                                                  }
                                                                          }
                                                                  
                                                                  };
                            
                            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                            
                            [deferred resolveWithValue:userTimesheet];
                        });
                        
                        it(@"should hide transparent loading overlay", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        it(@"should present the expected view controller", ^{
                            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                            .with(expectedViewController, subject, subject.view);
                        });
                        
                    });
                    
                    context(@"when the timesheet is a non-astro timesheet", ^{
                        __block UIViewController *expectedViewController;
                        beforeEach(^{
                            expectedViewController = [[ApprovalsScrollViewController alloc] init];
                            
                            [injector bind:[ApprovalsScrollViewController class] toInstance:expectedViewController];
                            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                            NSDictionary *nonAstroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"];
                            userTimesheet stub_method(@selector(timesheetDictionary)).and_return(nonAstroDictionary);
                            
                        });
                        
                        
                        context(@"When we have data cached in the database", ^{
                            beforeEach(^{
                                legacyTimesheetApprovalInfo stub_method(@selector(dbTimesheetArray)).and_return(@[@"1",@"2",@"3"]);
                                [deferred resolveWithValue:userTimesheet];
                            });
                            
                            
                            it(@"should not request data for the no astro screen from the service when legacyTimesheetApprovalInfo dbTimesheetArray is not empty", ^{
                                
                                approvalsService should_not have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:));
                            });
                        });
                        
                        context(@"When we do not have data cached in the database", ^{
                            beforeEach(^{
                                [deferred resolveWithValue:userTimesheet];
                            });
                            
                            
                            it(@"approvals service should have saved the selected timesheet", ^{
                                approvalsService should have_received(@selector(handleApprovalsTimeSheetSummaryDataForTimesheet:module:)).with(@{@"response":userTimesheet.timesheetDictionary},APPROVALS_PENDING_TIMESHEETS_MODULE);
                            });
                            
                            it(@"should show the non astro child controller", ^{
                                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                                .with(expectedViewController, subject, subject.view);
                            });
                            
                            it(@"should have the correct title on the navigation controller", ^{
                                subject.title should equal( RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                            });
                            
                            it(@"should request data for the no astro screen from the service", ^{
                                approvalsService should have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:)).with(@"the-expected-uri",subject.legacyTimesheetApprovalInfo.delegate);
                            });
                        });
                        
                    });
                    
                    describe(@"its view", ^{
                        it(@"should have a white background so animating this controller in looks nice", ^{
                            subject.view.backgroundColor should equal([UIColor whiteColor]);
                        });
                    });
                    
                });
                
                describe(@"when called from previous approvals", ^{
                    beforeEach(^{
                        widgetSupportDeferred = [[KSDeferred alloc] init];
                        timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                        .with(@"the-expected-uri")
                        .and_return(widgetSupportDeferred.promise);

                        legacyTimesheetApprovalInfo stub_method(@selector(isFromPreviousApprovals)).and_return(YES);
                        subject.view should_not be_nil;
                        [widgetSupportDeferred resolveWithValue:@0];
                    });
                    
                    it(@"should add the transparent loading overlay", ^{
                        spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                    });
                    
                    it(@"should have set edgesForExtendedLayout correctly", ^{
                        subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
                    });
                    
                    context(@"when the timesheet is an astro timesheet", ^{
                        __block KSDeferred *timesheetInfoDeferred;
                        beforeEach(^{
                            expectedViewController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                                 childControllerHelper:nil
                                                                                                                 timeSummaryRepository:nil
                                                                                                                   violationRepository:nil
                                                                                                                   auditHistoryStorage:NULL
                                                                                                                     punchRulesStorage:nil
                                                                                                                                 theme:nil];
                            
                            [injector bind:[TimesheetDetailsController class] toInstance:expectedViewController];
                            
                            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            
                            timesheetInfoDeferred = [[KSDeferred alloc] init];
                            
                            
                            timesheetRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:))
                            .with(@"the-expected-uri")
                            .and_return(timesheetInfoDeferred.promise);
                            
                            [deferred resolveWithValue:userTimesheet];
                        });
                        
                        context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                            beforeEach(^{
                                [timesheetInfoDeferred resolveWithValue:userlessTimesheet];
                            });
                            it(@"should hide transparent loading overlay", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should present the expected view controller", ^{
                                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                                .with(expectedViewController, subject, subject.view);
                            });
                            
                            it(@"should setup the TimesheetDetailsController with its dynamic dependencies", ^{
                                TimesheetDetailsController *timesheetDetailsController = (id)expectedViewController;
                                //[[timesheetDetailsController timesheetPromise] value] should be_same_instance_as(userlessTimesheet);//FIXME
                            });
                            
                            it(@"should set the title correctly for the astro case", ^{
                                subject.title should equal(@"The Expected Title");
                            });
                            
                            it(@"should hide the right bar button", ^{
                                subject.navigationItem.rightBarButtonItem should be_nil;
                                
                            });
                        });
                        
                        
                        
                        
                    });
                    
                    context(@"when the timesheet is an astro timesheet with client, project and activity access", ^{
                        beforeEach(^{
                            expectedViewController = [[WrongConfigurationMessageViewController alloc] initWithTheme:nil];
                            
                            [injector bind:[WrongConfigurationMessageViewController class] toInstance:expectedViewController];
                            
                            NSDictionary *timesheetDictionary = @{
                                                                  @"d": @{
                                                                          @"capabilities":@{
                                                                                  @"timePunchCapabilities": @{
                                                                                          @"hasProjectAccess":@1 ,
                                                                                          @"hasClientAccess":@1 ,
                                                                                          @"hasActivityAccess":@1 ,
                                                                                          }
                                                                                  }
                                                                          }
                                                                  
                                                                  };
                            
                            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                            
                            [deferred resolveWithValue:userTimesheet];
                        });
                        
                        it(@"should hide transparent loading overlay", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        it(@"should present the expected view controller", ^{
                            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                            .with(expectedViewController, subject, subject.view);
                        });
                        
                    });
                    
                    context(@"when the timesheet is a non-astro timesheet", ^{
                        __block UIViewController *expectedViewController;
                        beforeEach(^{
                            expectedViewController = [[ApprovalsScrollViewController alloc] init];
                            
                            [injector bind:[ApprovalsScrollViewController class] toInstance:expectedViewController];
                            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                            NSDictionary *nonAstroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"];
                            userTimesheet stub_method(@selector(timesheetDictionary)).and_return(nonAstroDictionary);
                            
                        });
                        
                        
                        context(@"When we have data cached in the database", ^{
                            beforeEach(^{
                                legacyTimesheetApprovalInfo stub_method(@selector(dbTimesheetArray)).and_return(@[@"1",@"2",@"3"]);
                                [deferred resolveWithValue:userTimesheet];
                            });
                            
                            
                            it(@"should not request data for the no astro screen from the service when legacyTimesheetApprovalInfo dbTimesheetArray is not empty", ^{
                                
                                approvalsService should_not have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:));
                            });
                        });
                        
                        context(@"When we do not have data cached in the database", ^{
                            beforeEach(^{
                                [deferred resolveWithValue:userTimesheet];
                            });
                            
                            
                            it(@"approvals service should have saved the selected timesheet", ^{
                                approvalsService should have_received(@selector(handleApprovalsTimeSheetSummaryDataForTimesheet:module:)).with(@{@"response":userTimesheet.timesheetDictionary},APPROVALS_PREVIOUS_TIMESHEETS_MODULE);
                            });
                            
                            it(@"should show the non astro child controller", ^{
                                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                                .with(expectedViewController, subject, subject.view);
                            });
                            
                            it(@"should have the correct title on the navigation controller", ^{
                                subject.title should equal( RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                            });
                            
                            it(@"should request data for the no astro screen from the service", ^{
                                approvalsService should have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:)).with(@"the-expected-uri",subject.legacyTimesheetApprovalInfo.delegate);
                            });
                        });
                        
                    });
                    
                    describe(@"its view", ^{
                        it(@"should have a white background so animating this controller in looks nice", ^{
                            subject.view.backgroundColor should equal([UIColor whiteColor]);
                        });
                    });
                });
                
            });
            
        });
    });

    describe(@"presenting the correct child controller", ^{
        __block KSDeferred *deferred;
        __block AstroAwareTimesheet *userTimesheet;
        __block UIViewController *expectedViewController;

        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
            
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"the-expected-uri")
            .and_return(deferred.promise);


        });
        
        describe(@"ApproveTimesheetContainerController on ViewDidLoad", ^{
            __block  NSMutableArray *oefTypesArray;
            
            beforeEach(^{
           
                OEFType *oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
                OEFType *oeftype2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithArray:@[oeftype1, oeftype2]];
                
                subject.view should_not be_nil;
                
                [subject viewDidLoad];

            });
            
            it(@"Should have called fetchOEFTypesWithUserURI:", ^{
               
                subject.oefTypesRepository should have_received(@selector(fetchOEFTypesWithUserURI:)).with(@"my-special-user-uri");
            });
            
        });


        describe(@"when called from pending approvals", ^{

            beforeEach(^{
                legacyTimesheetApprovalInfo stub_method(@selector(isFromPendingApprovals)).and_return(YES);
                subject.view should_not be_nil;
            });

            it(@"should have set edgesForExtendedLayout correctly", ^{
                subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
            });

            it(@"should add the transparent loading overlay", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });

            context(@"when the timesheet is an astro timesheet", ^{
                __block KSDeferred *timesheetInfoDeferred;
                beforeEach(^{
                    expectedViewController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                         childControllerHelper:nil
                                                                                                         timeSummaryRepository:nil
                                                                                                           violationRepository:nil
                                                                                                           auditHistoryStorage:NULL
                                                                                                             punchRulesStorage:nil
                                                                                                                         theme:nil];

                    [injector bind:[TimesheetDetailsController class] toInstance:expectedViewController];

                    userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                    
                    timesheetInfoDeferred = [[KSDeferred alloc] init];
                    
                    
                    timesheetRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:))
                    .with(@"the-expected-uri")
                    .and_return(timesheetInfoDeferred.promise);


                    [deferred resolveWithValue:userTimesheet];
                });
                
                context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                    beforeEach(^{
                          [timesheetInfoDeferred resolveWithValue:userlessTimesheet];
                        });
                    
                    it(@"should hide transparent loading overlay", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    it(@"should present the expected view controller", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                        .with(expectedViewController, subject, subject.view);
                    });
                    
                    it(@"should setup the TimesheetDetailsController with its dynamic dependencies", ^{
                        TimesheetDetailsController *timesheetDetailsController = (id)expectedViewController;
                        //[[timesheetDetailsController timesheetPromise] value] should be_same_instance_as(userlessTimesheet);//FIXME
                    });
                    
                    it(@"should set the title correctly for the astro case", ^{
                        subject.title should equal(@"The Expected Title");
                    });
                    
                    it(@"should show the approve bar button with correct title", ^{
                        subject.navigationItem.rightBarButtonItem should_not be_nil;
                        subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Approve", nil));
                    });
                });

                

                describe(@"approving the selected timesheet", ^{
                    beforeEach(^{
                        [timesheetInfoDeferred resolveWithValue:userlessTimesheet];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should tell its delegate", ^{
                        delegate should have_received(@selector(approveTimesheetContainerController:didApproveTimesheet:)).with(subject, userlessTimesheet);
                    });
                });


            });
            
            context(@"when the timesheet is an astro timesheet with client, project and activity access", ^{
                beforeEach(^{
                    expectedViewController = [[WrongConfigurationMessageViewController alloc] initWithTheme:nil];
                    
                    [injector bind:[WrongConfigurationMessageViewController class] toInstance:expectedViewController];
                    
                    NSDictionary *timesheetDictionary = @{
                                                            @"d": @{
                                                                                            @"capabilities":@{
                                                                                                    @"timePunchCapabilities": @{
                                                                                                            @"hasProjectAccess":@1 ,
                                                                                                            @"hasClientAccess":@1 ,
                                                                                                            @"hasActivityAccess":@1 ,
                                                                                                            }
                                                                                            }
                                                                                            }
                                                                            
                                                        };

                    userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                    userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                    
                    [deferred resolveWithValue:userTimesheet];
                });
                
                it(@"should hide transparent loading overlay", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should present the expected view controller", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                    .with(expectedViewController, subject, subject.view);
                });
                
            });

            context(@"when the timesheet is a non-astro timesheet", ^{
                __block UIViewController *expectedViewController;
                beforeEach(^{
                    expectedViewController = [[ApprovalsScrollViewController alloc] init];

                    [injector bind:[ApprovalsScrollViewController class] toInstance:expectedViewController];
                    userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                    NSDictionary *nonAstroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"];
                    userTimesheet stub_method(@selector(timesheetDictionary)).and_return(nonAstroDictionary);

                });


                context(@"When we have data cached in the database", ^{
                    beforeEach(^{
                        legacyTimesheetApprovalInfo stub_method(@selector(dbTimesheetArray)).and_return(@[@"1",@"2",@"3"]);
                        [deferred resolveWithValue:userTimesheet];
                    });


                    it(@"should not request data for the no astro screen from the service when legacyTimesheetApprovalInfo dbTimesheetArray is not empty", ^{

                        approvalsService should_not have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:));
                    });
                });

                context(@"When we do not have data cached in the database", ^{
                    beforeEach(^{
                        [deferred resolveWithValue:userTimesheet];
                    });


                    it(@"approvals service should have saved the selected timesheet", ^{
                        approvalsService should have_received(@selector(handleApprovalsTimeSheetSummaryDataForTimesheet:module:)).with(@{@"response":userTimesheet.timesheetDictionary},APPROVALS_PENDING_TIMESHEETS_MODULE);
                    });

                    it(@"should show the non astro child controller", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                        .with(expectedViewController, subject, subject.view);
                    });
                    
                    it(@"should have the correct title on the navigation controller", ^{
                        subject.title should equal( RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    });
                    
                    it(@"should request data for the no astro screen from the service", ^{
                        approvalsService should have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:)).with(@"the-expected-uri",subject.legacyTimesheetApprovalInfo.delegate);
                    });
                });
                
            });

            describe(@"its view", ^{
                it(@"should have a white background so animating this controller in looks nice", ^{
                    subject.view.backgroundColor should equal([UIColor whiteColor]);
                });
            });

        });

        describe(@"when called from previous approvals", ^{
            beforeEach(^{
                legacyTimesheetApprovalInfo stub_method(@selector(isFromPreviousApprovals)).and_return(YES);
                subject.view should_not be_nil;
            });

            it(@"should add the transparent loading overlay", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });

            it(@"should have set edgesForExtendedLayout correctly", ^{
                subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
            });

            context(@"when the timesheet is an astro timesheet", ^{
                __block KSDeferred *timesheetInfoDeferred;
                beforeEach(^{
                    expectedViewController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                         childControllerHelper:nil
                                                                                                         timeSummaryRepository:nil
                                                                                                           violationRepository:nil
                                                                                                           auditHistoryStorage:NULL
                                                                                                             punchRulesStorage:nil
                                                                                                                         theme:nil];

                    [injector bind:[TimesheetDetailsController class] toInstance:expectedViewController];

                    userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                    
                    timesheetInfoDeferred = [[KSDeferred alloc] init];
                    
                    
                    timesheetRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:))
                    .with(@"the-expected-uri")
                    .and_return(timesheetInfoDeferred.promise);

                    [deferred resolveWithValue:userTimesheet];
                });
                
                 context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                     beforeEach(^{
                         [timesheetInfoDeferred resolveWithValue:userlessTimesheet];
                     });
                     it(@"should hide transparent loading overlay", ^{
                         spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                     });
                     
                     it(@"should present the expected view controller", ^{
                         childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                         .with(expectedViewController, subject, subject.view);
                     });
                     
                     it(@"should setup the TimesheetDetailsController with its dynamic dependencies", ^{
                         TimesheetDetailsController *timesheetDetailsController = (id)expectedViewController;
                         //[[timesheetDetailsController timesheetPromise] value] should be_same_instance_as(userlessTimesheet);//FIXME
                     });
                     
                     it(@"should set the title correctly for the astro case", ^{
                         subject.title should equal(@"The Expected Title");
                     });
                     
                     it(@"should hide the right bar button", ^{
                         subject.navigationItem.rightBarButtonItem should be_nil;
                         
                     });
                  });

                


            });
            
            context(@"when the timesheet is an astro timesheet with client, project and activity access", ^{
                beforeEach(^{
                    expectedViewController = [[WrongConfigurationMessageViewController alloc] initWithTheme:nil];
                    
                    [injector bind:[WrongConfigurationMessageViewController class] toInstance:expectedViewController];
                    
                    NSDictionary *timesheetDictionary = @{
                                                          @"d": @{
                                                                  @"capabilities":@{
                                                                          @"timePunchCapabilities": @{
                                                                                  @"hasProjectAccess":@1 ,
                                                                                  @"hasClientAccess":@1 ,
                                                                                  @"hasActivityAccess":@1 ,
                                                                                  }
                                                                          }
                                                                  }
                                                          
                                                          };
                    
                    userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                    userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                    
                    [deferred resolveWithValue:userTimesheet];
                });
                
                it(@"should hide transparent loading overlay", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should present the expected view controller", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                    .with(expectedViewController, subject, subject.view);
                });
                
            });

            context(@"when the timesheet is a non-astro timesheet", ^{
                __block UIViewController *expectedViewController;
                beforeEach(^{
                    expectedViewController = [[ApprovalsScrollViewController alloc] init];

                    [injector bind:[ApprovalsScrollViewController class] toInstance:expectedViewController];
                    userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                    NSDictionary *nonAstroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"];
                    userTimesheet stub_method(@selector(timesheetDictionary)).and_return(nonAstroDictionary);

                });


                context(@"When we have data cached in the database", ^{
                    beforeEach(^{
                        legacyTimesheetApprovalInfo stub_method(@selector(dbTimesheetArray)).and_return(@[@"1",@"2",@"3"]);
                        [deferred resolveWithValue:userTimesheet];
                    });


                    it(@"should not request data for the no astro screen from the service when legacyTimesheetApprovalInfo dbTimesheetArray is not empty", ^{

                        approvalsService should_not have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:));
                    });
                });

                context(@"When we do not have data cached in the database", ^{
                    beforeEach(^{
                        [deferred resolveWithValue:userTimesheet];
                    });


                    it(@"approvals service should have saved the selected timesheet", ^{
                        approvalsService should have_received(@selector(handleApprovalsTimeSheetSummaryDataForTimesheet:module:)).with(@{@"response":userTimesheet.timesheetDictionary},APPROVALS_PREVIOUS_TIMESHEETS_MODULE);
                    });

                    it(@"should show the non astro child controller", ^{
                        childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                        .with(expectedViewController, subject, subject.view);
                    });

                    it(@"should have the correct title on the navigation controller", ^{
                        subject.title should equal( RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                    });
                    
                    it(@"should request data for the no astro screen from the service", ^{
                        approvalsService should have_received(@selector(fetchPendingTimeSheetSummaryDataForTimesheet:withDelegate:)).with(@"the-expected-uri",subject.legacyTimesheetApprovalInfo.delegate);
                    });
                });
                
            });

            describe(@"its view", ^{
                it(@"should have a white background so animating this controller in looks nice", ^{
                    subject.view.backgroundColor should equal([UIColor whiteColor]);
                });
            });
        });

    });

    describe(@"presenting the reopen bar button", ^{
        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"the-expected-uri")
            .and_return(deferred.promise);

            });

        context(@"when punch widget is enabled and Reopen is true", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                                  @"policyValue":@{
                                                                                          @"bool" : @YES,
                                                                                          @"number" : @5,
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @YES,
                                                                      @"canSubmit" : @NO,
                                                                      @"canUnsubmit" :@YES
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should_not be_nil;
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Reopen", @""));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });


        });

        context(@"when punch widget is enabled and Reopen is false", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                                  @"policyValue":@{
                                                                                          @"bool" : @YES,
                                                                                          @"number" : @5,
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @NO,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
            
            
        });

        context(@"when punch widget is not available", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:can-owner-view-pay-details" ,
                                                                                  @"policyValue":@{
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:can-owner-view-pay-details:allowed"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @YES,
                                                                      @"canSubmit" : @NO,
                                                                      @"canUnsubmit" :@YES
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
            
            
        });

        context(@"when widgetTimesheetCapabilities is null", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": [NSNull null]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @YES,
                                                                      @"canSubmit" : @NO,
                                                                      @"canUnsubmit" :@YES
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
            
            
        });


    });

    describe(@"presenting the submit bar button", ^{
        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"the-expected-uri")
            .and_return(deferred.promise);

        });

        context(@"when punch widget is enabled and Submit is true", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                                  @"policyValue":@{
                                                                                          @"bool" : @YES,
                                                                                          @"number" : @5,
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @YES,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should_not be_nil;
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Submit", @""));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });


        });

        context(@"when punch widget is enabled and Submit is false", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                                  @"policyValue":@{
                                                                                          @"bool" : @YES,
                                                                                          @"number" : @5,
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @NO,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });


        });

        context(@"when punch widget is not available", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:can-owner-view-pay-details" ,
                                                                                  @"policyValue":@{
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:can-owner-view-pay-details:allowed"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @YES,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });


        });

        context(@"when widgetTimesheetCapabilities is null", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": [NSNull null]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @YES,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                
                subject.view should_not be_nil;
                
                [deferred resolveWithValue:userTimesheet];
            });
            
            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
            
            
        });

        context(@"when punch widget is enabled and Submit is true and approvalDetails available with no history", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"approvalDetails" :         @{
                                                                      @"approvalStatus" :             @{
                                                                              @"displayText" : @"Not Submitted",
                                                                              @"uri" : @"urn:replicon:approval-status:open"
                                                                              },
                                                                      @"asOfDateTime" : [NSNull null],
                                                                      @"history" :             @[],
                                                                      @"timesheet" :             @{
                                                                              @"displayText" : @".nastro11/2017-1-15",
                                                                              @"slug" : @".nastro11/2017-1-15",
                                                                              @"uri" : @"urn:replicon-tenant:repliconiphone-2:timesheet:e94fb067-89a9-46d6-a1c2-13d88ecab6b9"
                                                                              },
                                                                      },
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                                  @"policyValue":@{
                                                                                          @"bool" : @YES,
                                                                                          @"number" : @5,
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @YES,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should_not be_nil;
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Submit", @""));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });


        });

        context(@"when punch widget is enabled and Submit is true and approvalDetails available with history", ^{
            beforeEach(^{
                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"approvalDetails" :         @{
                                                                      @"approvalStatus" :             @{
                                                                              @"displayText" : @"Not Submitted",
                                                                              @"uri" : @"urn:replicon:approval-status:open"
                                                                              },
                                                                      @"asOfDateTime" : [NSNull null],
                                                                      @"history" :@[
                                                                              @{
                                                                                  @"action" :
                                                                                      @{
                                                                                          @"displayText" : @"Submit",
                                                                                          @"uri" : @"urn:replicon:approval-action:submit"
                                                                                          },
                                                                                  @"approvalAgent" :
                                                                                      @{
                                                                                          @"approvalAgentType" : @"urn:replicon:approval-agent-type:user",
                                                                                          @"systemApprovalProcessUri" : [NSNull null],
                                                                                          @"user" :
                                                                                              @{
                                                                                                  @"displayText" : @"1, suppay",
                                                                                                  @"loginName" : @"suppay",
                                                                                                  @"slug" : @"suppay",
                                                                                                  @"uri" : @"urn:replicon-tenant:repliconiphone-2:user:874"
                                                                                                  },
                                                                                          },
                                                                                  @"authority" :
                                                                                      @{
                                                                                          @"actingForUser" : [NSNull null],
                                                                                          @"actingUser" :                         @{
                                                                                                  @"displayText" : @"1, suppay",
                                                                                                  @"loginName" : @"suppay",
                                                                                                  @"slug" : @"suppay",
                                                                                                  @"uri" : @"urn:replicon-tenant:repliconiphone-2:user:874"
                                                                                                  },
                                                                                          @"authorityType" :                         @{
                                                                                                  @"displayText" : @"A user acting on their own",
                                                                                                  @"uri" : @"urn:replicon:authority-type:user"
                                                                                                  },
                                                                                          @"displayText" : @"1, suppay"
                                                                                          },
                                                                                  @"comments" : @"Test 123",
                                                                                  @"timestamp" :                     @{
                                                                                          @"day" : @16,
                                                                                          @"hour" : @0,
                                                                                          @"minute" : @8,
                                                                                          @"month" : @1,
                                                                                          @"second" : @7,
                                                                                          @"timeZone" :                         @{
                                                                                                  @"displayText" : @"(UTC-5:00) Eastern Standard Time",
                                                                                                  @"uri" : @"urn:replicon:time-zone:america-new-york"
                                                                                                  },
                                                                                          @"valueInUtc" :                         @{
                                                                                                  @"day" : @16,
                                                                                                  @"hour" : @5,
                                                                                                  @"millisecond" : @421,
                                                                                                  @"minute" : @8,
                                                                                                  @"month" : @1,
                                                                                                  @"second" : @7,
                                                                                                  @"year" : @2017,
                                                                                                  },
                                                                                          @"year" : @2017
                                                                                          }
                                                                                  },

                                                                              @{
                                                                                  @"action" :                     @{
                                                                                          @"displayText" : @"Reopen",
                                                                                          @"uri" : @"urn:replicon:approval-action:reopen"
                                                                                          },
                                                                                  @"approvalAgent" :                     @{
                                                                                          @"approvalAgentType" : @"urn:replicon:approval-agent-type:user",
                                                                                          @"systemApprovalProcessUri" : [NSNull null],
                                                                                          @"user" :                         @{
                                                                                                  @"displayText" : @"1, suppay",
                                                                                                  @"loginName" : @"suppay",
                                                                                                  @"slug" : @"suppay",
                                                                                                  @"uri" : @"urn:replicon-tenant:repliconiphone-2:user:874",
                                                                                                  },
                                                                                          },
                                                                                  @"authority" :                     @{
                                                                                          @"actingForUser" : [NSNull null],
                                                                                          @"actingUser" :                         @{
                                                                                                  @"displayText" : @"1, suppay",
                                                                                                  @"loginName" : @"suppay",
                                                                                                  @"slug" : @"suppay",
                                                                                                  @"uri" : @"urn:replicon-tenant:repliconiphone-2:user:874"
                                                                                                  },
                                                                                          @"authorityType" :                         @{
                                                                                                  @"displayText" : @"A user acting on their own",
                                                                                                  @"uri" : @"urn:replicon:authority-type:user"
                                                                                                  },
                                                                                          @"displayText" : @"1, suppay"
                                                                                          },
                                                                                  @"comments" : @"Asdasd",
                                                                                  @"timestamp" :                     @{
                                                                                          @"day" : @16,
                                                                                          @"hour" : @0,
                                                                                          @"minute" : @8,
                                                                                          @"month" : @1,
                                                                                          @"second" : @25,
                                                                                          @"timeZone" :                         @{
                                                                                                  @"displayText" : @"(UTC-5:00) Eastern Standard Time",
                                                                                                  @"uri" : @"urn:replicon:time-zone:america-new-york"
                                                                                                  },
                                                                                          @"valueInUtc" :                         @{
                                                                                                  @"day" : @16,
                                                                                                  @"hour" : @5,
                                                                                                  @"millisecond" : @209,
                                                                                                  @"minute" : @8,
                                                                                                  @"month" : @1,
                                                                                                  @"second" : @25,
                                                                                                  @"year" : @2017
                                                                                                  },
                                                                                          @"year" : @2017
                                                                                          },
                                                                                  }
                                                                              ],
                                                                      @"timesheet" :             @{
                                                                              @"displayText" : @".nastro11/2017-1-15",
                                                                              @"slug" : @".nastro11/2017-1-15",
                                                                              @"uri" : @"urn:replicon-tenant:repliconiphone-2:timesheet:e94fb067-89a9-46d6-a1c2-13d88ecab6b9"
                                                                              }
                                                                      },
                                                              @"capabilities":@{
                                                                      @"widgetTimesheetCapabilities": @[
                                                                              @{
                                                                                  @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                                  @"policyValue":@{
                                                                                          @"bool" : @YES,
                                                                                          @"number" : @5,
                                                                                          @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                          }
                                                                                  }
                                                                              ]
                                                                      },
                                                              @"permittedApprovalActions":@{
                                                                      @"canApproveReject" : @YES,
                                                                      @"canForceApproveReject" : @NO,
                                                                      @"canReopen" : @NO,
                                                                      @"canSubmit" : @YES,
                                                                      @"canUnsubmit" :@NO
                                                                      }
                                                              }

                                                      };

                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

                subject.view should_not be_nil;

                [deferred resolveWithValue:userTimesheet];
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should_not be_nil;
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(Resubmit_Button_title, @""));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });
            
            
        });
        
    });


    describe(@"tapping the reopen bar button should push to ApprovalActionsViewController", ^{

        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"the-expected-uri")
            .and_return(deferred.promise);

        });

        beforeEach(^{
            NSDictionary *timesheetDictionary = @{
                                                  @"d": @{
                                                          @"capabilities":@{
                                                                  @"widgetTimesheetCapabilities": @[
                                                                          @{
                                                                              @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                              @"policyValue":@{
                                                                                      @"bool" : @YES,
                                                                                      @"number" : @5,
                                                                                      @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                      }
                                                                              }
                                                                          ]
                                                                  },
                                                          @"permittedApprovalActions":@{
                                                                  @"canApproveReject" : @YES,
                                                                  @"canForceApproveReject" : @NO,
                                                                  @"canReopen" : @YES,
                                                                  @"canSubmit" : @NO,
                                                                  @"canUnsubmit" :@YES
                                                                  }
                                                          }

                                                  };

            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
            userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

            subject.view should_not be_nil;


            [deferred resolveWithValue:userTimesheet];

            (id<CedarDouble>)subject stub_method(@selector(setupLegacyApprovalActionsViewControllerWithAction:)).and_return(approvalActionsViewController);

            [subject.navigationItem.rightBarButtonItem tap];
        });

        it(@"should naviagte to expected view controller", ^{
            navigationController should have_received(@selector(pushViewController:animated:)).with(approvalActionsViewController,YES);
        });
        
        
    });

    describe(@"tapping the submit bar button should push to ApprovalActionsViewController", ^{

        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"the-expected-uri")
            .and_return(deferred.promise);

        });

        beforeEach(^{
            NSDictionary *timesheetDictionary = @{
                                                  @"d": @{
                                                          @"capabilities":@{
                                                                  @"widgetTimesheetCapabilities": @[
                                                                          @{
                                                                              @"policyKeyUri":@"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry" ,
                                                                              @"policyValue":@{
                                                                                      @"bool" : @YES,
                                                                                      @"number" : @5,
                                                                                      @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                                      }
                                                                              }
                                                                          ]
                                                                  },
                                                          @"permittedApprovalActions":@{
                                                                  @"canApproveReject" : @YES,
                                                                  @"canForceApproveReject" : @NO,
                                                                  @"canReopen" : @NO,
                                                                  @"canSubmit" : @YES,
                                                                  @"canUnsubmit" :@NO
                                                                  }
                                                          }

                                                  };

            userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
            userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);

            subject.view should_not be_nil;


            [deferred resolveWithValue:userTimesheet];

            (id<CedarDouble>)subject stub_method(@selector(setupLegacyApprovalActionsViewControllerWithAction:)).and_return(approvalActionsViewController);

            [subject.navigationItem.rightBarButtonItem tap];
        });

        it(@"should naviagte to expected view controller", ^{
            navigationController should have_received(@selector(pushViewController:animated:)).with(approvalActionsViewController,YES);
        });
        
        
    });

    describe(@"as a <TimesheetDetailsControllerDelegate>", ^{
        describe(@"timesheetDetailsControllerRequestsLatestPunches", ^{
            __block KSDeferred *timesheetInfoDeferred;
            __block KSPromise *expectedPromise;
            beforeEach(^{
                timesheetInfoDeferred = [[KSDeferred alloc] init];
                
                userlessTimesheet stub_method(@selector(uri)).and_return(@"the-expected-uri");
                timesheetRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:))
                .with(@"the-expected-uri")
                .and_return(timesheetInfoDeferred.promise);
                expectedPromise =[subject timesheetDetailsControllerRequestsLatestPunches:nil];
            });
            
            it(@"should call fetchTimesheetInfoForTimsheetUri", ^{
                timesheetRepository should have_received(@selector(fetchTimesheetInfoForTimsheetUri:)).with(@"the-expected-uri");;
            });
            
            context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                __block TimesheetInfo *timesheetInfo;
                beforeEach(^{
                    timesheetInfo = nice_fake_for([TimesheetInfo class]);
                    [timesheetInfoDeferred resolveWithValue:timesheetInfo];
                });
                
                it(@"should fetch the new timesheet info for the correct timesheet uri",^{
                    expectedPromise.value should equal(timesheetInfo);
                });
            });
            
            context(@"when fetchTimesheetInfoForTimsheetUri reject with error", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [timesheetInfoDeferred rejectWithError:error];
                });
                
                it(@"should fetch the new timesheet info for the correct timesheet uri",^{
                    expectedPromise.error should equal(error);
                });
            });
        });
        
    });
});

SPEC_END
