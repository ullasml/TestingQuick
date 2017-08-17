#import <Blindside/Blindside.h>
#import <Cedar/Cedar.h>
#import "TimesheetContainerController.h"
#import "InjectorProvider.h"
#import "TimesheetRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "SpinnerDelegate.h"
#import "AstroAwareTimesheet.h"
#import "TimesheetDetailsController.h"
#import "ChildControllerHelper.h"
#import "UnavailableFormatTimesheetController.h"
#import "TimesheetForUserWithWorkHours.h"
#import "RepliconSpecHelper.h"
#import "ApprovalsScrollViewController.h"
#import "InjectorKeys.h"
#import "WrongConfigurationMessageViewController.h"
#import "UIBarButtonItem+Spec.h"
#import "ApprovalActionsViewController.h"
#import "OEFType.h"
#import "OEFTypesRepository.h"
#import "TimeSheetPermittedActions.h"
#import "TimesheetPeriod.h"
#import "TimePeriodSummary.h"
#import "TimesheetContainerController+RightBarButtonAction.h"
#import "TimesheetDetailsController.h"
#import "TimesheetInfo.h"
#import "UserPermissionsStorage.h"
#import <repliconkit/AppConfig.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetContainerControllerSpec)

describe(@"TimesheetContainerController", ^{
    __block TimesheetContainerController<CedarDouble> *subject;
    __block TimesheetRepository *timesheetRepository;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block ChildControllerHelper *childControllerHelper;
    __block TimesheetForUserWithWorkHours *timesheet;
    __block OEFTypesRepository *oefTypesRepository;
    __block id<BSBinder, BSInjector> injector;
    __block ApprovalsModel *approvalsModel;
    __block ApprovalsService *approvalsService;
    __block NSNotificationCenter *notificationCenter;
    __block ApprovalActionsViewController *approvalActionsViewController;
    __block  NSMutableArray *oefTypesArray;
    __block  KSDeferred *timesheetInfoDeferred;
    __block  AppConfig *appConfig;
    __block WidgetTimesheetRepository *widgetTimesheetRepository;
    __block TimesheetDetailsController *dummyTimesheetDetailsController;
    __block UINavigationController *navigationController;
    beforeEach(^{
        dummyTimesheetDetailsController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                      childControllerHelper:nil
                                                                                                      timeSummaryRepository:nil
                                                                                                        violationRepository:nil
                                                                                                        auditHistoryStorage:NULL
                                                                                                          punchRulesStorage:nil
                                                                                                                      theme:nil];
        spy_on(dummyTimesheetDetailsController);
        
        [injector bind:[TimesheetDetailsController class] toInstance:dummyTimesheetDetailsController];
    });
    beforeEach(^{
        injector = [InjectorProvider injector];

        widgetTimesheetRepository = nice_fake_for([WidgetTimesheetRepository class]);
        [injector bind:[WidgetTimesheetRepository class] toInstance:widgetTimesheetRepository];

        timesheetRepository = fake_for([TimesheetRepository class]);
        [injector bind:[TimesheetRepository class] toInstance:timesheetRepository];
        
        timesheetInfoDeferred = [[KSDeferred alloc]init];
        timesheetRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:)).with(@"my-special-timesheet-uri").and_return(timesheetInfoDeferred.promise);

        oefTypesRepository = fake_for([OEFTypesRepository class]);
        [injector bind:[OEFTypesRepository class] toInstance:oefTypesRepository];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        approvalsModel = nice_fake_for([ApprovalsModel class]);
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];


        approvalsService = nice_fake_for([ApprovalsService class]);
        [injector bind:[ApprovalsService class] toInstance:approvalsService];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        approvalActionsViewController = [injector getInstance:[ApprovalActionsViewController class]];
        [approvalActionsViewController setUpWithSheetUri:@"my-uri" selectedSheet:@"sample sheet" allowBlankComments:YES actionType:@"Reopen" delegate:subject];
        [injector bind:[ApprovalActionsViewController class] toInstance:approvalActionsViewController];

        appConfig = nice_fake_for([AppConfig class]);
        [injector bind:[AppConfig class] toInstance:appConfig];
        
        subject = [injector getInstance:[TimesheetContainerController class]];
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(subject);

        timesheet = nice_fake_for([TimesheetForUserWithWorkHours class]);
        timesheet stub_method(@selector(uri)).and_return(@"my-special-timesheet-uri");
        timesheet stub_method(@selector(userName)).and_return(@"Expected Employee Name");
        timesheet stub_method(@selector(userURI)).and_return(@"my-special-users-uri");

        [subject setupWithTimesheet:timesheet];

        OEFType *oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

        OEFType *oeftype2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

        oefTypesArray = [NSMutableArray arrayWithArray:@[oeftype1, oeftype2]];
    });
    
    afterEach(^{
        stop_spying_on(navigationController);
        stop_spying_on(subject);
    });

    it(@"should have a white background so the push animation as this is put on the navigation stack looks good", ^{
        oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:));
        timesheetRepository stub_method(@selector(fetchTimesheetWithURI:));
        subject.view.backgroundColor should equal([UIColor whiteColor]);
    });


    describe(@"isWidgetPlatformSupported Check", ^{
        __block NSArray *timesheetCapabilities;
        
        context(@"when isWidgetPlatformSupported", ^{
            __block KSDeferred *deferred;
            __block KSDeferred *widgetTimesheetsDeferred;
            __block WidgetTimesheetDetailsController *widgetTimesheetDetailsController;
            beforeEach(^{
                
                widgetTimesheetDetailsController = nice_fake_for([WidgetTimesheetDetailsController class]);
                [injector bind:[WidgetTimesheetDetailsController class] toInstance:widgetTimesheetDetailsController];
                
                widgetTimesheetsDeferred = [[KSDeferred alloc] init];
                timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");
                 deferred = [[KSDeferred alloc] init];
                timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                .with(@"my-special-timesheet-uri")
                .and_return(deferred.promise);
                appConfig stub_method(@selector(getTimesheetWidgetPlatform))
                .and_return(true);
                timesheetCapabilities = nice_fake_for([NSArray class]);
                timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");
                oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI);
                timesheetRepository stub_method(@selector(fetchTimesheetWithURI:));
                
                widgetTimesheetRepository stub_method (@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"my-special-timesheet-uri").and_return(widgetTimesheetsDeferred.promise);
                
                subject.view should_not be_nil;
                [deferred resolveWithValue:@1];
            });
            
            it(@"should correctly display the widget Timesheet Details Controller", ^{
                widgetTimesheetRepository should have_received(@selector(fetchWidgetTimesheetForTimesheetWithUri:)).with(@"my-special-timesheet-uri");
                
            });
            
            context(@"when the widget timesheet promise is success", ^{
                __block WidgetTimesheet *widgetTimesheet;
                __block TimeSheetPermittedActions *timeSheetPermittedActions;
                __block UIBarButtonItem *expectedBarButtonItem;
                __block TimesheetApprovalTimePunchCapabilities *timesheetApprovalTimePunchCapabilities;
                beforeEach(^{
                    expectedBarButtonItem = nice_fake_for([UIBarButtonItem class]);
                    timeSheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                    timesheetApprovalTimePunchCapabilities = nice_fake_for([TimesheetApprovalTimePunchCapabilities class]);
                    timesheetApprovalTimePunchCapabilities stub_method(@selector(hasBreakAccess)).and_return(YES);
                    widgetTimesheet = nice_fake_for([WidgetTimesheet class]);
                    Summary *summary = nice_fake_for([Summary class]);
                    widgetTimesheet stub_method(@selector(summary)).and_return(summary);
                    summary stub_method(@selector(timeSheetPermittedActions)).and_return(timeSheetPermittedActions);
                    widgetTimesheet stub_method(@selector(approvalTimePunchCapabilities)).and_return(timesheetApprovalTimePunchCapabilities);
                    [widgetTimesheetsDeferred resolveWithValue:widgetTimesheet];
                });
                
                it(@"should set up WidgetTimesheetDetailsController correctly", ^{
                    widgetTimesheetDetailsController should have_received(@selector(setupWithWidgetTimesheet:delegate:hasBreakAccess:isSupervisorContext:userUri:)).with(widgetTimesheet,subject,YES,YES,@"my-special-user-uri");
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
        
        context(@"when not supported", ^{
            __block KSDeferred *widgetSupportDeferred;
            beforeEach(^{
                timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");
                widgetSupportDeferred = [[KSDeferred alloc] init];
                timesheetRepository stub_method(@selector(fetchTimesheetCapabilitiesWithURI:))
                .with(@"my-special-timesheet-uri")
                .and_return(widgetSupportDeferred.promise);
                appConfig stub_method(@selector(getTimesheetWidgetPlatform))
                .and_return(true);
                timesheetCapabilities = nice_fake_for([NSArray class]);
                
            });
            
            context(@"-fetchTimesheetWithUri:", ^{
                describe(@"presenting a timesheet", ^{
                    __block KSDeferred *deferred;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc] init];
                        oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);
                        
                        timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
                        .with(@"my-special-timesheet-uri")
                        .and_return(deferred.promise);
                        
                        subject.view should_not be_nil;
                        [widgetSupportDeferred resolveWithValue:@0];
                    });
                    
                    describe(@"the navigation bar behavior", ^{
                        
                        beforeEach(^{
                            spy_on(navigationController);
                            
                            AstroAwareTimesheet *astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                            astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            
                            [deferred resolveWithValue:astroAwareTimesheet];
                            
                        });
                        
                        afterEach(^{
                            stop_spying_on(navigationController);
                        });
                        
                        context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                            beforeEach(^{
                                TimesheetInfo *timesheetInfo = nice_fake_for([TimesheetInfo class]);
                                [timesheetInfoDeferred resolveWithValue:timesheetInfo];
                            });
                            
                            it(@"should have a title for the navigation bar", ^{
                                subject.title should equal (@"Expected Employee Name");
                            });
                            
                            it(@"should have set edgesForExtendedLayout correctly", ^{
                                subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
                            });
                            
                            it(@"should have back button with title as Back", ^{
                                navigationController.navigationBar.topItem.backBarButtonItem.title should equal(@"Back");
                            });
                        });
                        
                        
                    });
                    
                    
                    
                    context(@"when the request succeeds and the timesheet indicates the user is an astro user without an wrong configuration", ^{
                        __block TimesheetDetailsController *timesheetDetailsController;
                        __block AstroAwareTimesheet *astroAwareTimesheet;
                        
                        beforeEach(^{
                            
                            timesheetDetailsController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                                     childControllerHelper:nil
                                                                                                                     timeSummaryRepository:nil
                                                                                                                       violationRepository:nil
                                                                                                                       auditHistoryStorage:NULL
                                                                                                                         punchRulesStorage:nil
                                                                                                                                     theme:nil];
                            spy_on(timesheetDetailsController);
                            [injector bind:[TimesheetDetailsController class] toInstance:timesheetDetailsController];
                            
                            NSDictionary *timesheetDictionary = @{
                                                                  @"d": @{
                                                                          @"capabilities":@{
                                                                                  @"timePunchCapabilities": @{
                                                                                          @"hasBreakAccess":@1 ,
                                                                                          }
                                                                                  }
                                                                          }
                                                                  
                                                                  };
                            astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                            astroAwareTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                            astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            
                            [deferred resolveWithValue:astroAwareTimesheet];
                        });
                        
                        context(@"when the timesheet info promise resolves", ^{
                            __block TimesheetInfo *timesheetInfo;
                            beforeEach(^{
                                timesheetInfo = nice_fake_for([TimesheetInfo class]);
                                [timesheetInfoDeferred resolveWithValue:timesheetInfo];
                            });
                            
                            it(@"should hide a spinner", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should present a TimesheetDetailsController", ^{
                                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                                .with(timesheetDetailsController, subject, subject.view);
                            });
                        });
                        
                        context(@"when the timesheet info promise fails", ^{
                            
                            beforeEach(^{
                                [timesheetInfoDeferred rejectWithError:nil];
                            });
                            
                            it(@"should hide a spinner", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should not present a TimesheetDetailsController", ^{
                                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:));
                            });
                            
                        });
                        
                    });
                    
                    context(@"when the request succeeds and the timesheet indicates the user is an astro user with client, project and activity access(wrong configuration)", ^{
                        __block WrongConfigurationMessageViewController *wrongConfigurationMessageViewController;
                        __block AstroAwareTimesheet *astroAwareTimesheet;
                        
                        beforeEach(^{
                            wrongConfigurationMessageViewController = [[WrongConfigurationMessageViewController alloc] initWithTheme:nil];
                            spy_on(wrongConfigurationMessageViewController);
                            [injector bind:[WrongConfigurationMessageViewController class] toInstance:wrongConfigurationMessageViewController];
                            
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
                            
                            astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                            astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                            astroAwareTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                            [deferred resolveWithValue:astroAwareTimesheet];
                        });
                        
                        it(@"should hide a spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        it(@"should present a TimesheetDetailsController", ^{
                            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                            .with(wrongConfigurationMessageViewController, subject, subject.view);
                        });
                    });
                    
                    context(@"when the request succeeds and the timesheet indicates the user is a non-astro user", ^{
                        __block UIViewController *expectedViewController;
                        __block NSDictionary *nonAstroDictionary;
                        beforeEach(^{
                            expectedViewController = [[ApprovalsScrollViewController alloc] init];
                            spy_on(expectedViewController);
                            [injector bind:[ApprovalsScrollViewController class] toInstance:expectedViewController];                AstroAwareTimesheet *astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                            astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                            nonAstroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"];
                            astroAwareTimesheet stub_method(@selector(timesheetDictionary)).and_return(nonAstroDictionary);
                            
                            [deferred resolveWithValue:astroAwareTimesheet];
                        });
                        
                        it(@"should show the non astro child controller", ^{
                            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                            .with(expectedViewController, subject, subject.view);
                        });
                        
                        it(@"should have the correct title on the navigation controller", ^{
                            subject.title should equal( RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
                        });
                        
                        it(@"approvals model should have saved the selected timesheet", ^{
                            approvalsModel should have_received(@selector(resetAndSaveTeamTimesheets:andTimesheetForUserWithWorkHours:)).with(nonAstroDictionary,timesheet);
                        });
                        
                    });
                    
                    context(@"when the request fails", ^{
                        beforeEach(^{
                            [deferred rejectWithError:nil];
                        });
                        
                        it(@"should hide a spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                });
            });
        });
    });

    describe(@"TimesheetContainerController on ViewDidLoad", ^{

        beforeEach(^{
            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");
            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);
            KSDeferred *deferred = [[KSDeferred alloc] init];
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            subject.view should_not be_nil;

        });

        it(@"Should have called fetchOEFTypesWithUserURI:", ^{

            subject.oefTypesRepository should have_received(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI);
        });
    });

    describe(@"presenting a timesheet", ^{
        __block KSDeferred *deferred;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);
            
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            
            subject.view should_not be_nil;
        });
        
        describe(@"the navigation bar behavior", ^{
            
            beforeEach(^{
                spy_on(navigationController);
                
                AstroAwareTimesheet *astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                
                [deferred resolveWithValue:astroAwareTimesheet];
                
            });
            
            afterEach(^{
                stop_spying_on(navigationController);
            });
            
            context(@"when fetchTimesheetInfoForTimsheetUri resolves", ^{
                beforeEach(^{
                    TimesheetInfo *timesheetInfo = nice_fake_for([TimesheetInfo class]);
                    [timesheetInfoDeferred resolveWithValue:timesheetInfo];
                });
                
                it(@"should have a title for the navigation bar", ^{
                    subject.title should equal (@"Expected Employee Name");
                });
                
                it(@"should have set edgesForExtendedLayout correctly", ^{
                    subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
                });
                
                it(@"should have back button with title as Back", ^{
                    navigationController.navigationBar.topItem.backBarButtonItem.title should equal(@"Back");
                });
            });

            
        });



        context(@"when the request succeeds and the timesheet indicates the user is an astro user without an wrong configuration", ^{
            __block TimesheetDetailsController *timesheetDetailsController;
            __block AstroAwareTimesheet *astroAwareTimesheet;

            beforeEach(^{

                timesheetDetailsController = [[TimesheetDetailsController alloc] initWithTimesheetInfoAndPermissionsRepository:NULL
                                                                                                         childControllerHelper:nil
                                                                                                         timeSummaryRepository:nil
                                                                                                           violationRepository:nil
                                                                                                           auditHistoryStorage:NULL
                                                                                                             punchRulesStorage:nil
                                                                                                                         theme:nil];
                spy_on(timesheetDetailsController);
                [injector bind:[TimesheetDetailsController class] toInstance:timesheetDetailsController];

                NSDictionary *timesheetDictionary = @{
                                                      @"d": @{
                                                              @"capabilities":@{
                                                                      @"timePunchCapabilities": @{
                                                                              @"hasBreakAccess":@1 ,
                                                                              }
                                                                      }
                                                              }
                                                      
                                                      };
                astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                astroAwareTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);

                [deferred resolveWithValue:astroAwareTimesheet];
            });
            
            context(@"when the timesheet info promise resolves", ^{
                __block TimesheetInfo *timesheetInfo;
                beforeEach(^{
                    timesheetInfo = nice_fake_for([TimesheetInfo class]);
                    [timesheetInfoDeferred resolveWithValue:timesheetInfo];
                });
                
                it(@"should hide a spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should present a TimesheetDetailsController", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                    .with(timesheetDetailsController, subject, subject.view);
                });
                
                it(@"should fully configure the TimesheetDetailsController", ^{
                    timesheetDetailsController should have_received(@selector(setupWithSpinnerOperationsCounter:delegate:timesheet:hasPayrollSummary:hasBreakAccess:cursor:userURI:title:)).with(nil,subject,timesheetInfo,astroAwareTimesheet.hasPayrollSummary,YES,nil,@"my-special-users-uri",@"Expected Employee Name");
                });
            });
            
            context(@"when the timesheet info promise fails", ^{
                
                beforeEach(^{
                    [timesheetInfoDeferred rejectWithError:nil];
                });
                
                it(@"should hide a spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should not present a TimesheetDetailsController", ^{
                    childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:));
                });

            });

        });

        context(@"when the request succeeds and the timesheet indicates the user is an astro user with client, project and activity access(wrong configuration)", ^{
            __block WrongConfigurationMessageViewController *wrongConfigurationMessageViewController;
            __block AstroAwareTimesheet *astroAwareTimesheet;

            beforeEach(^{
                wrongConfigurationMessageViewController = [[WrongConfigurationMessageViewController alloc] initWithTheme:nil];
                spy_on(wrongConfigurationMessageViewController);
                [injector bind:[WrongConfigurationMessageViewController class] toInstance:wrongConfigurationMessageViewController];

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

                astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeAstro);
                astroAwareTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                [deferred resolveWithValue:astroAwareTimesheet];
            });

            it(@"should hide a spinner", ^{
                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
            });

            it(@"should present a TimesheetDetailsController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(wrongConfigurationMessageViewController, subject, subject.view);
            });
        });

        context(@"when the request succeeds and the timesheet indicates the user is a non-astro user", ^{
            __block UIViewController *expectedViewController;
            __block NSDictionary *nonAstroDictionary;
            beforeEach(^{
                expectedViewController = [[ApprovalsScrollViewController alloc] init];
                spy_on(expectedViewController);
                [injector bind:[ApprovalsScrollViewController class] toInstance:expectedViewController];                AstroAwareTimesheet *astroAwareTimesheet = nice_fake_for([AstroAwareTimesheet class]);
                astroAwareTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                nonAstroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"];
                astroAwareTimesheet stub_method(@selector(timesheetDictionary)).and_return(nonAstroDictionary);

                [deferred resolveWithValue:astroAwareTimesheet];
            });

            it(@"should show the non astro child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(expectedViewController, subject, subject.view);
            });

            it(@"should have the correct title on the navigation controller", ^{
                subject.title should equal( RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle));
            });

            it(@"approvals model should have saved the selected timesheet", ^{
                approvalsModel should have_received(@selector(resetAndSaveTeamTimesheets:andTimesheetForUserWithWorkHours:)).with(nonAstroDictionary,timesheet);
            });

        });

        context(@"when the request fails", ^{
            beforeEach(^{
                [deferred rejectWithError:nil];
            });

            it(@"should hide a spinner", ^{
                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
            });
        });
    });

    describe(@"for unsupported widget combination - ", ^{
        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];
            
            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");
            
            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);
            
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            
            
        });
        
        context(@"standardWidget + Extended in out", ^{
            beforeEach(^{
                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                
                NSArray *enabledWidgetsArray = [NSArray arrayWithObjects:
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:approval-history" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   },
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:notice" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   },
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   },
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   }, nil
                                                ];
                
                subject.approvalsModel stub_method(@selector(getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:)).and_return(enabledWidgetsArray);

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
                    
                    userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                    
                    subject.view should_not be_nil;
                    
                    [deferred resolveWithValue:userTimesheet];
                });
                
                it(@"should have the correctly set up right bar button item", ^{
                    subject.navigationItem.rightBarButtonItem should be_nil;
                });
            });
        });
        
        context(@"inOutWidget + Extended in out", ^{
            beforeEach(^{
                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
                
                NSArray *enabledWidgetsArray = [NSArray arrayWithObjects:
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:approval-history" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   },
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:notice" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   },
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   },
                                                @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry" ,
                                                   @"enabled":@1,
                                                   @"timesheetUri":@"someUri"
                                                   }, nil
                                                ];
                
                subject.approvalsModel stub_method(@selector(getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:)).and_return(enabledWidgetsArray);
                
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
                    
                    userTimesheet stub_method(@selector(timesheetDictionary)).and_return(timesheetDictionary);
                    
                    subject.view should_not be_nil;
                    
                    [deferred resolveWithValue:userTimesheet];
                });
                
                it(@"should have the correctly set up right bar button item", ^{
                    subject.navigationItem.rightBarButtonItem should be_nil;
                });
            });
        });
        
    });

    describe(@"presenting the reopen bar button", ^{
        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        __block TimeSheetPermittedActions *timesheetPermittedActions;
        __block TimePeriodSummary *timePeriodSummary;

        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");

            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);

            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);

        });

        context(@"when punch widget is enabled and Reopen is true", ^{
            beforeEach(^{

                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(YES);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                subject.view should_not be_nil;
                [subject displayUserActionsButtons:timePeriodSummary];
                
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem should_not be_nil;
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Reopen", @""));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });


        });

        context(@"when punch widget is enabled and Reopen is false", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimePeriodSummary *timePeriodSummary;

            beforeEach(^{
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                subject.view should_not be_nil;
                [subject displayUserActionsButtons:timePeriodSummary];

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

            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");

            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);

            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            
            NSArray *enabledWidgetsArray = [NSArray arrayWithObjects:
                                                                    @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry" ,
                                                                       @"enabled":@1,
                                                                       @"timesheetUri":@"someUri"
                                                                            },
                                                                    @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:approval-history" ,
                                                                       @"enabled":@1,
                                                                       @"timesheetUri":@"someUri"
                                                                       },
                                                                    @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry" ,
                                                                       @"enabled":@1,
                                                                       @"timesheetUri":@"someUri"
                                                                       },
                                                                    @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:attestation" ,
                                                                       @"enabled":@1,
                                                                       @"timesheetUri":@"someUri"
                                                                       },  nil
                                                                       ];
            
            subject.approvalsModel stub_method(@selector(getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:)).and_return(enabledWidgetsArray);

        });

        context(@"For Non Astro User Timesheet", ^{
            beforeEach(^{
                
                userTimesheet stub_method(@selector(astroUserType)).and_return(TimesheetAstroUserTypeNonAstro);
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

    });

    describe(@"tapping the reopen bar button should push to ApprovalActionsViewController", ^{

        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");

            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);

            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            
            NSArray *enabledWidgetsArray = [NSArray arrayWithObjects:
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:approval-history" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:notice" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:attestation" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },  nil
                                            ];
            
            subject.approvalsModel stub_method(@selector(getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:)).and_return(enabledWidgetsArray);

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

            [subject.navigationItem.rightBarButtonItem tap];

        });

        it(@"should naviagte to expected view controller", ^{
            subject.navigationController should have_received(@selector(pushViewController:animated:)).with(approvalActionsViewController,YES);
        });


    });

    describe(@"tapping the submit/resubmit bar button should push to ApprovalActionsViewController", ^{

        __block AstroAwareTimesheet *userTimesheet;
        __block KSDeferred *deferred;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];

            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");

            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);

            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            
            NSArray *enabledWidgetsArray = [NSArray arrayWithObjects:
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:approval-history" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:notice" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },
                                            @{ @"widgetUri":@"urn:replicon:policy:timesheet:widget-timesheet:attestation" ,
                                               @"enabled":@1,
                                               @"timesheetUri":@"someUri"
                                               },  nil
                                            ];
            
            subject.approvalsModel stub_method(@selector(getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:)).and_return(enabledWidgetsArray);


        });

         context(@"without approval history", ^{
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

                 [subject.navigationItem.rightBarButtonItem tap];

             });

             it(@"should naviagte to expected view controller", ^{
                 subject.navigationController should have_received(@selector(pushViewController:animated:)).with(approvalActionsViewController,YES);
             });
        });

         context(@"with approval history", ^{
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

                (id<CedarDouble>)subject stub_method(@selector(setupLegacyApprovalActionsViewControllerWithAction:)).and_return(approvalActionsViewController);


                [subject.navigationItem.rightBarButtonItem tap];

            });

            it(@"should naviagte to expected view controller", ^{
                subject.navigationController should have_received(@selector(pushViewController:animated:)).with(approvalActionsViewController,YES);
            });

            it(@"should send correct button actionto expected view controller", ^{
                subject should have_received(@selector(setupLegacyApprovalActionsViewControllerWithAction:)).with(@"Re-Submit_Astro");
            });
            
            
        });


    });
    
    describe(@"the navigation bar behavior", ^{
        __block KSDeferred *deferred;
        __block AstroAwareTimesheet *userTimesheet;
        beforeEach(^{
            userTimesheet = nice_fake_for([AstroAwareTimesheet class]);
            deferred = [[KSDeferred alloc] init];
            
            timesheet stub_method(@selector(userURI)).again().and_return(@"my-special-user-uri");
            
            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);
            
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);

            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });
        
        context(@"When Submit button to be shown", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimesheetPeriod *timesheetPeriod;
            __block TimePeriodSummary *timePeriodSummary;
            beforeEach(^{
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timesheetPeriod = nice_fake_for([TimesheetPeriod class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(YES);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                [subject displayUserActionsButtons:timePeriodSummary];
            });
            
            it(@"should display submit button", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(@"Submit");
            });
        });
        
        context(@"When Resubmit button to be shown", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimesheetPeriod *timesheetPeriod;
            __block TimePeriodSummary *timePeriodSummary;
            beforeEach(^{
                
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timesheetPeriod = nice_fake_for([TimesheetPeriod class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                
                [subject displayUserActionsButtons:timePeriodSummary];
                
            });
            
            it(@"should display submit button", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(@"Resubmit");
            });
        });
        
        context(@"When Reopen button to be shown", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimePeriodSummary *timePeriodSummary;
            beforeEach(^{
                
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(YES);
                
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                
                [subject displayUserActionsButtons:timePeriodSummary];
                
            });
            
            it(@"should display submit button", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(@"Reopen");
            });
        });
        
        context(@"When Reopen button tapped", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimePeriodSummary *timePeriodSummary;
            beforeEach(^{
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                
                [subject displayUserActionsButtons:timePeriodSummary];
                subject.view should_not be_nil;
                
                [subject.navigationItem.rightBarButtonItem tap];
            });
            
            it(@"should push comment view controller", ^{
                subject.navigationController should have_received(@selector(pushViewController:animated:));
            });
            
            afterEach(^{
                stop_spying_on(navigationController);
            });
        });
        
        context(@"When Submit button tapped and on successful response", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimePeriodSummary *timePeriodSummary;
            __block TimeSheetPermittedActions *initialTimesheetPermittedActions;
            __block TimePeriodSummary *initialTimePeriodSummary;
            beforeEach(^{
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                initialTimesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                initialTimePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(YES);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                [subject displayUserActionsButtons:timePeriodSummary];

                spy_on(subject);
                
                [subject.navigationItem.rightBarButtonItem tap];
            });
            
            it(@"should change the button to Reopen", ^{
                subject.navigationController should have_received(@selector(pushViewController:animated:));
            });
            
            afterEach(^{
                stop_spying_on(subject);
            });
        });
        
        context(@"When Resubmit button tapped", ^{
            __block TimeSheetPermittedActions *timesheetPermittedActions;
            __block TimePeriodSummary *timePeriodSummary;
            __block TimeSheetPermittedActions *initialTimesheetPermittedActions;
            __block TimePeriodSummary *initialTimePeriodSummary;
            beforeEach(^{
                timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                initialTimesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
                initialTimePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                
                timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
                timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);

                [subject displayUserActionsButtons:timePeriodSummary];                
                subject.view should_not be_nil;
                [subject.navigationItem.rightBarButtonItem tap];
            });
            
            it(@"should push comment view controller", ^{
                subject.navigationController should have_received(@selector(pushViewController:animated:));
            });
            
            it(@"should naviagte to expected view controller", ^{
                subject.navigationController should have_received(@selector(pushViewController:animated:)).with(approvalActionsViewController,YES);
            });
            
            afterEach(^{
                stop_spying_on(navigationController);
            });
        });
    });

    describe(@"as a <TimesheetDetailsControllerDelegate>", ^{
        __block TimesheetPeriod *timeSheetPeriod;
        __block TimePeriodSummary *timePeriodSummary;
        __block TimeSheetPermittedActions *timesheetPermittedActions;

        beforeEach(^{
            timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
            timeSheetPeriod = nice_fake_for([TimesheetPeriod class]);
            timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
            oefTypesRepository stub_method(@selector(fetchOEFTypesWithUserURI:)).with(timesheet.userURI).and_return(oefTypesArray);
            
            KSDeferred *deferred = [[KSDeferred alloc] init];
            timesheetRepository stub_method(@selector(fetchTimesheetWithURI:))
            .with(@"my-special-timesheet-uri")
            .and_return(deferred.promise);
            
            subject.view should_not be_nil;
        });
        
        describe(@"timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary", ^{
            
            context(@"When submit button should be shown", ^{
                beforeEach(^{
                    
                    timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(YES);
                    timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                    
                    timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                    
                    spy_on(subject);
                    
                    subject stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                    
                    [subject timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:timePeriodSummary];
                });
                                
                
                it(@"Should have called display Action buttons", ^{
                    subject should have_received(@selector(displayUserActionsButtons:)).with(timePeriodSummary);
                });
                
                afterEach(^{
                    stop_spying_on(subject);
                });
            });
            
            context(@"When resubmit button should be shown", ^{
                beforeEach(^{
                    
                    timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
                    
                    timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                    
                    spy_on(subject);
                    
                    subject stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                    
                    [subject timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:timePeriodSummary];
                });
                
                it(@"Should have called display Action buttons", ^{
                    subject should have_received(@selector(displayUserActionsButtons:)).with(timePeriodSummary);
                });
                
                afterEach(^{
                    stop_spying_on(subject);
                });
            });
            
            context(@"When reopen button should be shown", ^{
                beforeEach(^{
                    
                    timesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
                    timesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(YES);
                    timesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
                    
                    timePeriodSummary stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
                    
                    spy_on(subject);
                    
                    subject stub_method(@selector(timePeriodSummary)).and_return(timePeriodSummary);
                    
                    [subject timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:timePeriodSummary];
                });
                
                
                it(@"Should have called display Action buttons", ^{
                    subject should have_received(@selector(displayUserActionsButtons:)).with(timePeriodSummary);
                });
                
                afterEach(^{
                    stop_spying_on(subject);
                });
            });
            
        });
        
    });
    
    describe(@"widgetTimesheetDetailsController:actionButton:", ^{
        
        __block UIBarButtonItem *expectedRightBarButtonItem;
        beforeEach(^{
            expectedRightBarButtonItem = nice_fake_for([UIBarButtonItem class]);
            [subject widgetTimesheetDetailsController:nice_fake_for([UIViewController class]) actionButton:expectedRightBarButtonItem];
            
        });
        
        it(@"should set the right bar button correctly", ^{
            subject.navigationItem.rightBarButtonItem should equal(expectedRightBarButtonItem);
        });
        
        
    });

});

SPEC_END
