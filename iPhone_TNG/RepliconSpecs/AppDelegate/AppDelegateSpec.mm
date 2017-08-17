#import <Cedar/Cedar.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "TabProvider.h"
#import "TimesheetNavigationController.h"
#import "LoginNavigationViewController.h"
#import "ACSimpleKeychain.h"
#import "KeychainProvider.h"
#import "PunchHomeController.h"
#import "HomeSummaryDelegate.h"
#import "UserPermissionsStorage.h"
#import "BreakTypeRepository.h"
#import "LoginService.h"
#import "TimesheetService.h"
#import "RepliconServiceManager.h"
#import "LoginViewController.h"
#import "PunchOutboxQueueCoordinator.h"
#import <Blindside/Blindside.h>
#import "NavigationBarStylist.h"
#import "Theme.h"
#import "TabModuleNameProvider.h"
#import "ModuleStorage.h"
#import "AstroUserDetector.h"
#import "InjectorKeys.h"
#import "URLSessionListener.h"
#import "PunchRequestHandler.h"
#import "PunchRevitalizer.h"
#import "WelcomeViewController.h"
#import "FrameworkImport.h"
#import "LoginCredentialsHelper.h"
#import "DefaultActivityStorage.h"
#import "OEFTypeStorage.h"
#import "syncNotificationScheduler.h"
#import "PunchErrorPresenter.h"
#import "ObjectExtensionFieldLimitDeserializer.h"
#import <repliconkit/AppConfigRepository.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppDelegateSpec)

describe(@"AppDelegate", ^{
    __block AppDelegate *subject;
    __block id<BSInjector, BSBinder> injector;
    __block BreakTypeRepository *breakTypeRepository;
    __block NSUserDefaults *testDefaults;
    __block ACSimpleKeychain *keychain;
    __block KeychainProvider *keychainProvider;
    __block LoginService *loginService;
    __block LoginViewController *loginViewController;
    __block PunchOutboxQueueCoordinator *punchOutboxQueueCoordinator;
    __block TabProvider *tabProvider;
    __block NavigationBarStylist *navigationBarStylist;
    __block LoginCredentialsHelper *loginCredentialsHelper;
    __block TabModuleNameProvider *tabModuleNameProvider;
    __block id<Theme> theme;
    __block SupportDataModel *supportDataModel;
    __block ModuleStorage *moduleStorage;
    __block AstroUserDetector *astroUserDetector;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block GATracker *GATrackerClass;
    __block UIApplication *application;
    __block ModulesGATracker *modulesGATracker;
    __block id<UserSession> userSession;
    __block PunchRevitalizer *punchRevitalizer;
    __block PunchErrorPresenter *punchErrorPresenter;
    __block AppConfigRepository *appConfigRepository;
    __block WidgetPlatformDetector *widgetPlatformDetector;
    __block WidgetTimesheetCapabilitiesDeserializer *widgetTimesheetCapabilitiesDeserializer;

    beforeEach(^{
        subject = [[AppDelegate alloc] init];
        injector = (id)subject.injector;
        userSession = subject.userSession;
        spy_on(userSession);
        
        application = [UIApplication sharedApplication];

        spy_on(subject.syncNotificationScheduler);

        reachabilityMonitor = [[ReachabilityMonitor alloc]init];
        spy_on(reachabilityMonitor);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];
        
        punchRevitalizer = nice_fake_for([PunchRevitalizer class]);
        [injector bind:[PunchRevitalizer class] toInstance:punchRevitalizer];
        
        punchErrorPresenter = nice_fake_for([PunchErrorPresenter class]);
        [injector bind:[PunchErrorPresenter class] toInstance:punchErrorPresenter];

        keychain = nice_fake_for([ACSimpleKeychain class]);
        keychainProvider = nice_fake_for([KeychainProvider class]);
        keychainProvider stub_method(@selector(provideInstance)).and_return(keychain);

        punchRevitalizer = nice_fake_for([PunchRevitalizer class]);
        [injector bind:[PunchRevitalizer class] toInstance:punchRevitalizer];
        
        testDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:testDefaults];

        loginService = nice_fake_for([LoginService class]);
        loginViewController = [[LoginViewController alloc] initWithSpinnerDelegate:nil cookiesDelegate:nil router:nil tracker:nil loginCredentialsHelper:NULL theme:nil emmConfigManager:nil userDefaults:nil];
        [injector bind:[LoginViewController class] toInstance:loginViewController];

        subject.standardUserDefaults = testDefaults;
        subject.keychainProvider = keychainProvider;

        breakTypeRepository = nice_fake_for([BreakTypeRepository class]);
        [injector bind:[BreakTypeRepository class] toInstance:breakTypeRepository];

        punchOutboxQueueCoordinator = nice_fake_for([PunchOutboxQueueCoordinator class]);
        [injector bind:[PunchOutboxQueueCoordinator class] toInstance:punchOutboxQueueCoordinator];

        tabProvider = nice_fake_for([TabProvider class]);
        [injector bind:[TabProvider class] toInstance:tabProvider];

        navigationBarStylist = nice_fake_for([NavigationBarStylist class]);
        [injector bind:[NavigationBarStylist class] toInstance:navigationBarStylist];

        loginCredentialsHelper = nice_fake_for([LoginCredentialsHelper class]);
        [injector bind:[LoginCredentialsHelper class] toInstance:loginCredentialsHelper];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        tabModuleNameProvider = nice_fake_for([TabModuleNameProvider class]);
        [injector bind:[TabModuleNameProvider class] toInstance:tabModuleNameProvider];

        supportDataModel = nice_fake_for([SupportDataModel class]);
        [injector bind:[SupportDataModel class] toInstance:supportDataModel];

        moduleStorage = nice_fake_for([ModuleStorage class]);
        [injector bind:[ModuleStorage class] toInstance:moduleStorage];

        astroUserDetector = nice_fake_for([AstroUserDetector class]);
        [injector bind:[AstroUserDetector class] toInstance:astroUserDetector];

        GATrackerClass = nice_fake_for([GATracker class]);
        [injector bind:[GATracker class] toInstance:GATrackerClass];

        modulesGATracker = nice_fake_for([ModulesGATracker class]);
        [injector bind:[ModulesGATracker class] toInstance:modulesGATracker];

        appConfigRepository = nice_fake_for([AppConfigRepository class]);
        [injector bind:[AppConfigRepository class] toInstance:appConfigRepository];
        
        widgetPlatformDetector = nice_fake_for([WidgetPlatformDetector class]);
        [injector bind:InjectorKeyWidgetPlatformDetector toInstance:widgetPlatformDetector];
        
        widgetTimesheetCapabilitiesDeserializer = nice_fake_for([WidgetTimesheetCapabilitiesDeserializer class]);
        [injector bind:[WidgetTimesheetCapabilitiesDeserializer class] toInstance:widgetTimesheetCapabilitiesDeserializer];
    });


    it(@"should have the punch rules storage", ^{
        subject.userPermissionsStorage should be_instance_of([UserPermissionsStorage class]);
    });

    it(@"should have the default activity storage", ^{
        subject.defaultActivityStorage should be_instance_of([DefaultActivityStorage class]);
    });



    describe(@"as a <UITabBarControllerDelegate>", ^{
        __block UITabBarController *tabBarController;
        beforeEach(^{
            testDefaults stub_method(@selector(boolForKey:)).with(@"isSuccessLogin").and_return(YES);

            [subject application:application willFinishLaunchingWithOptions:nil];
            subject.loginService = loginService;
            [subject application:application didFinishLaunchingWithOptions:nil];

            tabBarController = (UITabBarController *)subject.window.rootViewController;
        });

        describe(@"tabBarController:didSelectViewController:", ^{
            context(@"when switching to the punch home controller", ^{
                __block PunchHomeController *punchHomeController;
                beforeEach(^{

                    punchHomeController = [[PunchHomeController alloc] initWithPunchImagePickerControllerProvider:nil punchControllerProvider:nil allowAccessAlertHelper:nil imageNormalizer:nil punchRepository:nil oefTypeStorage:nil userSession:nil punchClock:nil timeLinePunchesStorage:nil];

                    spy_on(punchHomeController);
                    tabBarController.viewControllers = @[punchHomeController];
                    
                    

                    [subject tabBarController:tabBarController didSelectViewController:punchHomeController];
                });
                afterEach(^{
                    stop_spying_on(punchHomeController);
                });

                it(@"should not notify the punch home controller that it has become the active tab", ^{
                    punchHomeController should_not have_received(@selector(fetchAndDisplayChildControllerForMostRecentPunch));
                });
            });

            context(@"should track modules in GA", ^{
                __block UIViewController *viewController = [[UIViewController alloc]init];
                context(@"if the tab bar is not part of 'More' section", ^{
                    beforeEach(^{
                        [subject tabBarController:tabBarController didSelectViewController:viewController];
                    });
                    it(@"should send event to GA", ^{
                        modulesGATracker should have_received(@selector(sendGAEventForModule:));
                    });
                });
            });

        });


        describe(@"tabBarController:didEndCustomizingViewControllers:changed:", ^{
            it(@"should do nothing when the tab order hasn't been changed", ^{
                [subject tabBarController:tabBarController didEndCustomizingViewControllers:@[] changed:NO];
                moduleStorage should_not have_received(@selector(storeModulesWhenDifferent:));
                moduleStorage should_not have_received(@selector(storeModules:));
            });

            it(@"should store the new module order when tab order has been changed", ^{
                NSArray *viewControllers = fake_for([NSArray class]);
                NSArray *modules = fake_for([NSArray class]);

                tabProvider stub_method(@selector(modulesForViewControllers:))
                .with(viewControllers).and_return(modules);

                [subject tabBarController:tabBarController didEndCustomizingViewControllers:viewControllers changed:YES];

                moduleStorage should have_received(@selector(storeModules:)).with(modules);
            });
        });
    });

    describe(@"as a <HomeSummaryDelegate>", ^{

        describe(@"homeSummaryFetcher:didReceiveHomeSummaryResponse:", ^{
            __block UserPermissionsStorage *userPermissionsStorage;
            __block DefaultActivityStorage *defaultActivityStorage;
            __block OEFTypeStorage *oefTypeStorage;
            __block ObjectExtensionFieldLimitDeserializer *oefLimitDeserializer;
            beforeEach(^{
                [subject application:application willFinishLaunchingWithOptions:nil];

                userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
                subject.userPermissionsStorage = userPermissionsStorage;

                defaultActivityStorage = nice_fake_for([DefaultActivityStorage class]);
                subject.defaultActivityStorage = defaultActivityStorage;

                oefTypeStorage = nice_fake_for([OEFTypeStorage class]);
                [injector bind:[OEFTypeStorage class] toInstance:oefTypeStorage];
                
                oefLimitDeserializer = nice_fake_for([ObjectExtensionFieldLimitDeserializer class]);
                [injector bind:[ObjectExtensionFieldLimitDeserializer class] toInstance:oefLimitDeserializer];
                
            });
            
            context(@"When home summary response has ObjectExtensionfieldlimits", ^{
                __block  NSDictionary *homeSummaryResponseWithOnlyObjectExtensionFieldLimits;
                beforeEach(^{
                    homeSummaryResponseWithOnlyObjectExtensionFieldLimits = @{     @"objectExtensionFieldLimits": @{
                                                                                           @"numericObjectExtensionFieldMaxPrecision":@14,
                                                                                           @"numericObjectExtensionFieldMaxScale": @4,
                                                                                           @"textObjectExtensionFieldMaxLength": @255
                                                                                           }
                                                                                   };
                    
                });
                
                it(@"Should store the limits in user defaults", ^{
                    
                    [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyObjectExtensionFieldLimits];
                    
                    NSDictionary *oefLimitDict = homeSummaryResponseWithOnlyObjectExtensionFieldLimits[@"objectExtensionFieldLimits"];
                    
                    oefLimitDeserializer should have_received(@selector(deserializeObjectExtensionFieldLimitFromHomeFlowService:)).with(oefLimitDict);
                });
                
            });

            context(@"should save the punch rules in the punch rules storage", ^{

                describe(@"With approvalCapabilities", ^{

                    it(@"with canViewTeamPayDetails", ^{

                        NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{
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
                                                                                                @"defaultActivity":@{
                                                                                                        @"name": @"default-activity",
                                                                                                        @"uri": @"default-uri",
                                                                                                        @"displayText": @"default-activity",
                                                                                                        },
                                                                                                @"geolocationRequired": @YES,
                                                                                                @"hasBreakAccess": @NO,
                                                                                                @"auditImageRequired": @YES,
                                                                                                @"canEditTimePunch": @YES,
                                                                                                @"canViewTeamTimePunch":@YES,
                                                                                                @"hasTimePunchAccess":@YES,
                                                                                                @"projectTaskSelectionRequired":@NO,
                                                                                                @"hasClientAccess":@NO,
                                                                                                @"hasManualTimePunchAccess":@YES,
                                                                                                @"hasProjectAccess":@NO,
                                                                                                @"hasBillingAccess":@NO,
                                                                                                @"hasActivityAccess":@YES,
                                                                                                @"canEditOwnTimePunchNonTimeFields":@NO,
                                                                                                @"activitySelectionRequired":@YES,
                                                                                                @"canEditTeamTimePunch":@NO,
                                                                                                @"timePunchExtensionFields": @{
                                                                                                        @"collectAtTimeOfPunchFieldBindings": @[
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"dipta number",
                                                                                                                    @"slug": @"dipta-number",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f"
                                                                                                                    }
                                                                                                                ],
                                                                                                        @"punchInFieldBindings": @[
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"dipta number",
                                                                                                                    @"slug": @"dipta-number",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f"
                                                                                                                    },
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"dipta text",
                                                                                                                    @"slug": @"dipta-text",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af"
                                                                                                                    }
                                                                                                                ],
                                                                                                        @"punchOutFieldBindings": @[
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"generic oef - prompt",
                                                                                                                    @"slug": @"generic-oef-prompt",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"
                                                                                                                    }
                                                                                                                ],
                                                                                                        @"punchStartBreakFieldBindings": @[

                                                                                                                ],
                                                                                                        @"punchTransferFieldBindings": @[

                                                                                                                ]
                                                                                                        }

                                                                                                }
                                                                                        ,
                                                                                        @"payDetailCapabilities":@{
                                                                                                @"canViewTeamPayDetails":@YES,
                                                                                                }
                                                                                        ,
                                                                                        @"timesheetCapabilities":@{
                                                                                                @"hasTimesheetAccess":@YES,
                                                                                                @"hasClientsAvailableForTimeAllocation":@NO,
                                                                                                @"canViewTeamTimesheet":@YES
                                                                                                },
                                                                                        @"expenseCapabilities":@{
                                                                                                @"currentCapabilities":@{@"entryAgainstProjectsRequired":@YES},
                                                                                                }

                                                                                        }
                                                                                };


                        [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];

                        userPermissionsStorage should have_received(@selector(persistIsExpensesProjectMandatory:isWidgetPlatformSupported:canApproveTimesheets:canEditNonTimeFields:geolocationRequired:canApproveExpenses:canApproveTimeoffs:isActivityMandatory:isProjectMandatory:hasTimesheetAccess:hasActivityAccess:hasProjectAccess:hasClientAccess:canEditTimePunch:isAstroPunchUser:canViewPayDetails:canViewTeamPunch:breaksRequired:selfieRequired:hasTimePunchAccess:canViewTeamTimesheet:canEditTimesheet:canEditTeamTimePunch:isSimpleInOutWidget:hasManualTimePunchAccess:))
                        .with(@YES, @NO, @YES, @NO, @YES, @YES, @NO,@YES, @NO, @YES, @YES, @NO, @NO, @YES, @NO, @YES, @YES, @NO, @YES, @YES, @YES,@NO,@NO,@NO,@YES);

                        defaultActivityStorage should have_received(@selector(persistDefaultActivityName:defaultActivityUri:)).with(@"default-activity", @"default-uri");

                        OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];


                        OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                        OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"generic oef - prompt" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                        oefTypeStorage should have_received(@selector(storeOEFTypes:)).with(@[oefType1,oefType2,oefType3]);

                    });

                    it(@"without canViewTeamPayDetails", ^{

                        NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{
                                                                                @"userSummary": @{
                                                                                                                                                                                @"approvalCapabilities": @{
                                                                                                @"timesheetApprovalCapabilities": @{
                                                                                                        @"isTimesheetApprover": @NO,
                                                                                                        @"areRejectCommentsRequired": @YES,
                                                                                                        @"canViewTeamTimesheet":@NO
                                                                                                        },
                                                                                                @"timeoffApprovalCapabilities": @{
                                                                                                        @"isTimeOffApprover": @NO,
                                                                                                        @"areRejectCommentsRequired": @YES
                                                                                                        },
                                                                                                @"expenseApprovalCapabilities": @{
                                                                                                        @"isExpenseApprover": @YES,
                                                                                                        @"areRejectCommentsRequired": @YES
                                                                                                        }
                                                                                                },
                                                                                        @"timePunchCapabilities": @{
                                                                                                @"canViewTeamTimePunch": @NO,
                                                                                                @"defaultActivity":[NSNull null],
                                                                                                @"geolocationRequired": @YES,
                                                                                                @"projectTaskSelectionRequired": @YES,
                                                                                                @"activitySelectionRequired": @NO,
                                                                                                @"hasActivityAccess": @NO,
                                                                                                @"canEditTimePunch": @YES,
                                                                                                @"defaultActivity": [NSNull null],
                                                                                                @"hasTimePunchAccess": @YES,
                                                                                                @"hasProjectAccess": @YES,
                                                                                                @"canEditOwnTimePunchNonTimeFields": @YES,
                                                                                                @"hasBreakAccess": @NO,
                                                                                                @"hasClientAccess": @NO,
                                                                                                @"hasManualTimePunchAccess" : @YES,
                                                                                                @"hasBillingAccess": @NO,
                                                                                                @"auditImageRequired": @YES,
                                                                                                @"canEditTimePunch": @YES,
                                                                                                @"canViewTeamTimePunch":@NO,
                                                                                                @"hasTimePunchAccess":@YES,
                                                                                                @"projectTaskSelectionRequired":@YES,
                                                                                                @"hasClientAccess":@YES,
                                                                                                @"hasProjectAccess":@YES,
                                                                                                @"hasBillingAccess":@YES,
                                                                                                @"hasActivityAccess":@NO,
                                                                                                @"canEditOwnTimePunchNonTimeFields":@YES,
                                                                                                @"activitySelectionRequired":@NO,
                                                                                                @"canEditTeamTimePunch":@YES,
                                                                                                @"timePunchExtensionFields": @{
                                                                                                        @"collectAtTimeOfPunchFieldBindings": @[
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"dipta number",
                                                                                                                    @"slug": @"dipta-number",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f"
                                                                                                                    }
                                                                                                                ],
                                                                                                        @"punchInFieldBindings": @[
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-numeric",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"dipta number",
                                                                                                                    @"slug": @"dipta-number",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f"
                                                                                                                    },
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"dipta text",
                                                                                                                    @"slug": @"dipta-text",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af"
                                                                                                                    }
                                                                                                                ],
                                                                                                        @"punchOutFieldBindings": @[
                                                                                                                @{
                                                                                                                    @"code": [NSNull null],
                                                                                                                    @"definitionTypeUri": @"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                                                    @"description": [NSNull null],
                                                                                                                    @"name": @"generic oef - prompt",
                                                                                                                    @"slug": @"generic-oef-prompt",
                                                                                                                    @"uri": @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"
                                                                                                                    }
                                                                                                                ],
                                                                                                        @"punchStartBreakFieldBindings": @[

                                                                                                                ],
                                                                                                        @"punchTransferFieldBindings": @[

                                                                                                                ]
                                                                                                        }

                                                                                                }
                                                                                        ,
                                                                                        @"payDetailCapabilities":[NSNull null]
                                                                                        ,
                                                                                        @"timesheetCapabilities":@{
                                                                                                @"hasTimesheetAccess":@YES,
                                                                                                @"hasClientsAvailableForTimeAllocation":@YES,
                                                                                                @"canViewTeamTimesheet":@NO,
                                                                                                @"currentCapabilities":@{@"canEditTimesheet":@YES, @"widgetTimesheetCapabilities":@[
                                                                                                                                 @{
                                                                                                                                     @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                                                                                     @"policyValue": @{
                                                                                                                                             @"bool": @YES,
                                                                                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry"
                                                                                                                                             }
                                                                                                                                     }]
                                                                                                                         },
                                                                                                },
                                                                                        @"expenseCapabilities":@{
                                                                                                @"currentCapabilities":@{@"entryAgainstProjectsRequired":@YES},
                                                                                                }
                                                                                        }
                                                                                };

                        [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];

                        userPermissionsStorage should have_received(@selector(persistIsExpensesProjectMandatory:isWidgetPlatformSupported:canApproveTimesheets:canEditNonTimeFields:geolocationRequired:canApproveExpenses:canApproveTimeoffs:isActivityMandatory:isProjectMandatory:hasTimesheetAccess:hasActivityAccess:hasProjectAccess:hasClientAccess:canEditTimePunch:isAstroPunchUser:canViewPayDetails:canViewTeamPunch:breaksRequired:selfieRequired:hasTimePunchAccess:canViewTeamTimesheet:canEditTimesheet:canEditTeamTimePunch:isSimpleInOutWidget:hasManualTimePunchAccess:))
                        .with(@YES, @NO, @NO, @YES, @YES, @YES, @NO,@NO, @YES, @YES, @NO, @YES, @YES, @YES, @NO, @NO, @NO, @NO, @YES, @YES, @NO,@YES,@YES,@YES,@YES);

                        defaultActivityStorage should have_received(@selector(persistDefaultActivityName:defaultActivityUri:)).with(@"", @"");

                        OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];


                        OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                        OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"generic oef - prompt" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                        oefTypeStorage should have_received(@selector(storeOEFTypes:)).with(@[oefType1,oefType2,oefType3]);


                    });
                });

                describe(@"Without approvalCapabilities", ^{
                    beforeEach(^{
                        NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{
                                                                                @"userSummary": @{
                                                                                        @"approvalCapabilities":@{
                                                                                                @"expenseApprovalCapabilities":@{
                                                                                                        @"areRejectCommentsRequired":@YES,
                                                                                                        @"isExpenseApprover":@NO
                                                                                                        },
                                                                                                @"timeoffApprovalCapabilities":@{
                                                                                                        @"areRejectCommentsRequired":@YES,
                                                                                                        @"isTimeOffApprover":@NO
                                                                                                        },
                                                                                                @"timesheetApprovalCapabilities":@{
                                                                                                        @"areRejectCommentsRequired":@YES,
                                                                                                        @"isTimesheetApprover":@NO
                                                                                                        }
                                                                                                },
                                                                                        @"timePunchCapabilities": @{
                                                                                                @"geolocationRequired": @YES,
                                                                                                @"hasBreakAccess": @NO,
                                                                                                @"auditImageRequired": @YES,
                                                                                                @"canEditTimePunch": @YES,
                                                                                                @"canViewTeamTimePunch":@YES,
                                                                                                @"hasTimePunchAccess":@YES,
                                                                                                @"hasManualTimePunchAccess" : @YES,
                                                                                                @"projectTaskSelectionRequired":@NO,
                                                                                                @"hasClientAccess":@NO,
                                                                                                @"hasProjectAccess":@NO,
                                                                                                @"hasBillingAccess":@NO,
                                                                                                @"hasActivityAccess":@YES,
                                                                                                @"canEditOwnTimePunchNonTimeFields":@YES,
                                                                                                @"activitySelectionRequired":@YES,
                                                                                                @"canEditTeamTimePunch":@YES,
                                                                                                }
                                                                                        ,
                                                                                        @"payDetailCapabilities":[NSNull null]
                                                                                        ,
                                                                                        @"timesheetCapabilities":@{
                                                                                                @"hasTimesheetAccess":@YES,
                                                                                                @"hasClientsAvailableForTimeAllocation":@NO,
                                                                                                @"canViewTeamTimesheet":@NO
                                                                                                },
                                                                                        @"expenseCapabilities":@{
                                                                                                @"currentCapabilities":@{@"entryAgainstProjectsRequired":@YES},
                                                                                                }
                                                                                        }
                                                                                };

                        [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];
                    });



                    it(@"should correctly save values in userPermissionsStorage", ^{
                        userPermissionsStorage should have_received(@selector(persistIsExpensesProjectMandatory:isWidgetPlatformSupported:canApproveTimesheets:canEditNonTimeFields:geolocationRequired:canApproveExpenses:canApproveTimeoffs:isActivityMandatory:isProjectMandatory:hasTimesheetAccess:hasActivityAccess:hasProjectAccess:hasClientAccess:canEditTimePunch:isAstroPunchUser:canViewPayDetails:canViewTeamPunch:breaksRequired:selfieRequired:hasTimePunchAccess:canViewTeamTimesheet:canEditTimesheet:canEditTeamTimePunch:isSimpleInOutWidget:hasManualTimePunchAccess:))
                        .with(@YES, @NO, @NO, @YES, @YES, @NO, @NO,@YES, @NO, @YES, @YES, @NO, @NO, @YES, @NO, @NO, @YES, @NO, @YES, @YES,@NO,@NO,@YES,@NO,@YES);

                    });

                });


            });

            it(@"should add the correct tab module names to the user defaults", ^{
                NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{@"userSummary": @{@"timePunchCapabilities": @{}}};

                NSArray *userDetails = fake_for([NSArray class]);

                supportDataModel stub_method(@selector(getUserDetailsFromDatabase))
                .and_return(userDetails);

                NSArray *tabModuleNameArray = fake_for([NSArray class]);

                tabModuleNameProvider stub_method(@selector(tabModuleNamesWithHomeSummaryResponse:userDetails:isWidgetPlatformSupported:))
                .with(homeSummaryResponseWithOnlyPunchRules, userDetails,NO)
                .and_return(tabModuleNameArray);

                [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];

                moduleStorage should have_received(@selector(storeModulesWhenDifferent:)).with(tabModuleNameArray);
            });

            context(@"when logging breaks is required", ^{
                beforeEach(^{
                    NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{@"userSummary" : @{
                                                                             @"timePunchCapabilities" : @{
                                                                                        @"hasBreakAccess" : @YES
                                                                                        },

                                                                            @"user" : @{
                                                                                      @"uri" : @"urn:replicon-tenant:repliconiphone-2:user:479"
                                                                                      }
                                                                             }
                                                                            };
                    [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];
                });

                it(@"should immediately fetch the break types list and evict cache", ^{
                    breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(@"urn:replicon-tenant:repliconiphone-2:user:479");
                });
            });

            context(@"when logging breaks is not required", ^{
                beforeEach(^{
                    NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{@"userSummary": @{@"timePunchCapabilities": @{@"hasBreakAccess": @NO}}};
                    [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];
                });

                it(@"should not fetch the break types list", ^{
                    breakTypeRepository should_not have_received(@selector(fetchBreakTypesForUser:));
                });
            });

            context(@"when the user has access to Astro punch", ^{
                __block NSDictionary *timePunchCapabilitiesDictionary;

                beforeEach(^{
                    timePunchCapabilitiesDictionary = nice_fake_for([NSDictionary class]);
                    NSDictionary *homeSummaryResponseWithOnlyPunchRules = @{@"userSummary": @{@"timePunchCapabilities": timePunchCapabilitiesDictionary}};

                    astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:))
                    .and_return(YES);

                    [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponseWithOnlyPunchRules];
                });

                it(@"should store the fact that the user is an astro user in the user permissions storage", ^{
                    userPermissionsStorage should have_received(@selector(persistIsExpensesProjectMandatory:isWidgetPlatformSupported:canApproveTimesheets:canEditNonTimeFields:geolocationRequired:canApproveExpenses:canApproveTimeoffs:isActivityMandatory:isProjectMandatory:hasTimesheetAccess:hasActivityAccess:hasProjectAccess:hasClientAccess:canEditTimePunch:isAstroPunchUser:canViewPayDetails:canViewTeamPunch:breaksRequired:selfieRequired:hasTimePunchAccess:canViewTeamTimesheet:canEditTimesheet:canEditTeamTimePunch:isSimpleInOutWidget:hasManualTimePunchAccess:))
                    .with(Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,@YES,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything);
                });
            });
            
            context(@"when the user has widgetplatformfeatureflag enabled", ^{
                __block NSDictionary *timePunchCapabilitiesDictionary;
                __block NSDictionary *widgetTimesheetCapabilitiesDictionary;
                
                context(@"when widgetTimesheetCapabilities is present", ^{
                    beforeEach(^{
                        timePunchCapabilitiesDictionary = nice_fake_for([NSDictionary class]);
                        widgetTimesheetCapabilitiesDictionary = nice_fake_for([NSDictionary class]);
                        NSDictionary *homeSummaryResponse = @{@"userSummary": @{@"timePunchCapabilities": timePunchCapabilitiesDictionary,@"timesheetCapabilities":@{@"currentCapabilities":@{@"widgetTimesheetCapabilities":widgetTimesheetCapabilitiesDictionary}}}};
                        
                        NSArray *someConfiguredWidgetsUri = @[@"some-a",@"some-b"];
                        widgetTimesheetCapabilitiesDeserializer stub_method(@selector(getUserConfiguredSupportedWidgetUris:)).with(widgetTimesheetCapabilitiesDictionary).and_return(someConfiguredWidgetsUri);
                        widgetPlatformDetector stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
                        [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponse];
                    });
                    
                    it(@"should correctly set up WidgetPlatformDetector", ^{
                        widgetPlatformDetector should have_received(@selector(setupWithUserConfiguredWidgetUris:)).with(@[@"some-a",@"some-b"]);
                    });
                    
                    
                    it(@"should fetch the UserConfiguredSupportedWidgetUris correctly", ^{
                        widgetTimesheetCapabilitiesDeserializer should have_received(@selector(getUserConfiguredSupportedWidgetUris:)).with(widgetTimesheetCapabilitiesDictionary);
                    });
                    
                    
                    it(@"should store user is widget platform user", ^{
                        userPermissionsStorage should have_received(@selector(persistIsExpensesProjectMandatory:isWidgetPlatformSupported:canApproveTimesheets:canEditNonTimeFields:geolocationRequired:canApproveExpenses:canApproveTimeoffs:isActivityMandatory:isProjectMandatory:hasTimesheetAccess:hasActivityAccess:hasProjectAccess:hasClientAccess:canEditTimePunch:isAstroPunchUser:canViewPayDetails:canViewTeamPunch:breaksRequired:selfieRequired:hasTimePunchAccess:canViewTeamTimesheet:canEditTimesheet:canEditTeamTimePunch:isSimpleInOutWidget:hasManualTimePunchAccess:))
                        .with(Arguments::anything,@YES, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything);
                    });

                });
                
                context(@"when widgetTimesheetCapabilities is nil", ^{
                    beforeEach(^{
                        timePunchCapabilitiesDictionary = nice_fake_for([NSDictionary class]);
                        widgetTimesheetCapabilitiesDictionary = nice_fake_for([NSDictionary class]);
                        NSDictionary *homeSummaryResponse = @{@"userSummary": @{@"timePunchCapabilities": timePunchCapabilitiesDictionary}};
                        
                        widgetPlatformDetector stub_method(@selector(isWidgetPlatformSupported))
                        .and_return(YES);
                        
                        [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:homeSummaryResponse];
                    });
                    
                    it(@"should store user is widget platform user", ^{
                        userPermissionsStorage should have_received(@selector(persistIsExpensesProjectMandatory:isWidgetPlatformSupported:canApproveTimesheets:canEditNonTimeFields:geolocationRequired:canApproveExpenses:canApproveTimeoffs:isActivityMandatory:isProjectMandatory:hasTimesheetAccess:hasActivityAccess:hasProjectAccess:hasClientAccess:canEditTimePunch:isAstroPunchUser:canViewPayDetails:canViewTeamPunch:breaksRequired:selfieRequired:hasTimePunchAccess:canViewTeamTimesheet:canEditTimesheet:canEditTeamTimePunch:isSimpleInOutWidget:hasManualTimePunchAccess:))
                        .with(Arguments::anything,@NO, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything, Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything,Arguments::anything);
                    });
                
                });
                
            });
        });
    });

    describe(@"when the application finishes launching", ^{

        context(@"when the user is already logged in", ^{
            beforeEach(^{
                testDefaults stub_method(@selector(boolForKey:)).with(@"isSuccessLogin").and_return(YES);
                [subject application:application willFinishLaunchingWithOptions:nil];
                subject.loginService = loginService;

                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                [subject application:application didFinishLaunchingWithOptions:nil];
            });

            it(@"should be correct instance of GATracker class", ^{
                GATrackerClass should be_instance_of([GATracker class]);
            });
            it(@"should fetch the home summary from the login service", ^{
                loginService should have_received(@selector(sendrequestToFetchHomeSummaryWithDelegate:)).with(subject);
            });

            it(@"should set the root view controller to be the TabBar controller", ^{
                UITabBarController *tabBarController = (UITabBarController *)subject.window.rootViewController;

                tabBarController should be_instance_of([UITabBarController class]);
            });

            it(@"enable the boolean to navigate to error details once logged in", ^{
                subject.isWaitingForDeepLinkToErrorDetails should be_falsy;
            });
            it(@"cancel local notification should not be called", ^{
                subject.syncNotificationScheduler should_not have_received(@selector(cancelNotification:)).with(@"ErrorBackgroundStatus");
            });

            describe(@"when the login service returns", ^{
                __block UITabBarController *tabBarController;
                __block UIViewController *viewController;

                beforeEach(^{
                    theme stub_method(@selector(tabBarTintColor)).and_return([UIColor magentaColor]);

                    NSArray *modules = fake_for([NSArray class]);
                    moduleStorage stub_method(@selector(modules)).and_return(modules);

                    viewController = [[UIViewController alloc] init];
                    tabProvider stub_method(@selector(viewControllersForModules:))
                    .with(modules).and_return(@[viewController]);

                    [subject loginServiceDidFinishLoggingIn:loginService];

                    tabBarController = (id)subject.window.rootViewController;
                });

                it(@"should configure the tabs", ^{
                    tabBarController.viewControllers should equal(@[viewController]);
                });

                it(@"should set itself as the tab bar controller's delegate", ^{
                    tabBarController.delegate should be_same_instance_as(subject);
                });

                it(@"should received event for GA Tracker", ^{
                    subject.tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"login", TrackerProduct);
                });

                describe(@"styling the navigation bar", ^{
                    it(@"should use the navigation bar stylist", ^{
                        navigationBarStylist should have_received(@selector(styleNavigationBar));
                    });
                });

                describe(@"styling the tab bar", ^{
                    it(@"should set the tint color from the theme", ^{
                        tabBarController.tabBar.tintColor should equal([UIColor magentaColor]);
                    });

                    it(@"should not have a translucent tab bar", ^{
                        tabBarController.tabBar.translucent should_not be_truthy;
                    });
                });
            });


        });

        context(@"when the user has not logged in yet", ^{
            beforeEach(^{
                testDefaults stub_method(@selector(boolForKey:)).with(@"isSuccessLogin").and_return(NO);

                [subject application:application willFinishLaunchingWithOptions:nil];
                subject.loginService = loginService;
                [subject application:application didFinishLaunchingWithOptions:nil];
            });

            it(@"should fetch the home summary from the login service", ^{
                GATrackerClass should be_instance_of([GATracker class]);
            });
            it(@"should set the root view controller to be the welcome controller", ^{
                WelcomeViewController *welcomeViewController = (WelcomeViewController *)subject.window.rootViewController;

                welcomeViewController should be_instance_of([WelcomeViewController class]);
            });
        });

        context(@"when launched from error banner local notification", ^{

            beforeEach(^{
                testDefaults stub_method(@selector(boolForKey:)).with(@"isSuccessLogin").and_return(YES);
                [subject application:application willFinishLaunchingWithOptions:nil];
                subject.loginService = loginService;

                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"ErrorBackgroundStatus",@"uid",nil];
                notification.userInfo = userInfo;
                [subject application:application didFinishLaunchingWithOptions:@{UIApplicationLaunchOptionsLocalNotificationKey:notification}];
            });

            it(@"enable the boolean to navigate to error details once logged in", ^{
                subject.isWaitingForDeepLinkToErrorDetails should be_truthy;
            });
            it(@"cancel local notification", ^{
                subject.syncNotificationScheduler should have_received(@selector(cancelNotification:)).with(@"ErrorBackgroundStatus");
            });


        });


    });
    
    describe(@"when showing the login view controller", ^{
        it(@"should reset the timesheet service", ^{
            TimesheetService *timesheetServiceA = [RepliconServiceManager timesheetService];
            [subject launchLoginViewController:YES];
            TimesheetService *timesheetServiceB = [RepliconServiceManager timesheetService];

            timesheetServiceB should_not be_same_instance_as(timesheetServiceA);
        });

        it(@"should reset the expense service", ^{
            ExpenseService *expenseServiceA = [RepliconServiceManager expenseService];
            [subject launchLoginViewController:YES];
            ExpenseService *expenseServiceB = [RepliconServiceManager expenseService];

            expenseServiceB should_not be_same_instance_as(expenseServiceA);
        });

        it(@"should reset the time off service", ^{
            TimeoffService *timeoffServiceA = [RepliconServiceManager timeoffService];
            [subject launchLoginViewController:YES];
            TimeoffService *timeoffServiceB = [RepliconServiceManager timeoffService];

            timeoffServiceB should_not be_same_instance_as(timeoffServiceA);
        });
    });

    describe(NSStringFromProtocol(@protocol(LoginDelegate)), ^{
        describe(NSStringFromSelector(@selector(loginServiceDidFinishLoggingIn:)), ^{


            describe(@"when the login service finishes fetching the home summary", ^{
                beforeEach(^{
                    subject.tracker = GATrackerClass;

                    [subject showTransparentLoadingOverlay];

                    [subject loginServiceDidFinishLoggingIn:nil];
                });

                it(@"should hide the spinner", ^{
                    subject.indicatorView.isAnimating should be_falsy;
                });

                it(@"should received event for GA Tracker", ^{
                    subject.tracker should have_received(@selector(trackUIEvent:forTracker:)).with(@"login", TrackerProduct);
                });
            });
        });
    });

    describe(NSStringFromSelector(@selector(launchResetPasswordViewController)), ^{
        beforeEach(^{
            [subject application:application willFinishLaunchingWithOptions:nil];
            subject.loginService = loginService;
            [subject launchResetPasswordViewController];
        });

        it(@"should create a correctly configured resetPasswordViewController", ^{
            subject.resetPasswordViewController.spinnerDelegate should be_same_instance_as(subject);
            subject.resetPasswordViewController.router should be_same_instance_as(subject);
        });
    });

    describe(@"as a <Router>", ^{
        describe(@"launchTabBarController", ^{
            __block UITabBarController *tabBarController;
            __block UIViewController *viewController;

            beforeEach(^{
                subject.loginCredentialsHelper = loginCredentialsHelper;
                subject.loginCredentialsHelper stub_method (@selector(getLoginCredentials)).and_return(@{@"userName":@"User Name",@"userUri":@"user-uri",@"companyName":@"Company Name"});

                theme stub_method(@selector(tabBarTintColor)).and_return([UIColor magentaColor]);

                NSArray *modules = fake_for([NSArray class]);
                moduleStorage stub_method(@selector(modules)).and_return(modules);

                viewController = [[UIViewController alloc] init];
                tabProvider stub_method(@selector(viewControllersForModules:))
                .with(modules).and_return(@[viewController]);

                [subject application:application willFinishLaunchingWithOptions:nil];
                [subject application:application didFinishLaunchingWithOptions:nil];
                [subject launchTabBarController];
                tabBarController = (id)subject.window.rootViewController;
            });

            it(@"should configure the tabs", ^{
                tabBarController.viewControllers should equal(@[viewController]);
            });

            it(@"should set itself as the tab bar controller's delegate", ^{
                tabBarController.delegate should be_same_instance_as(subject);
            });

            it(@"should send event to GA", ^{
                modulesGATracker should have_received(@selector(sendGAEventForModule:));
            });

            it(@"should call service to get latest value of node backend", ^{
                appConfigRepository should have_received(@selector(appConfigForRequest:));
            });

            describe(@"styling the navigation bar", ^{
                it(@"should use the navigation bar stylist", ^{
                    navigationBarStylist should have_received(@selector(styleNavigationBar));
                });
            });

            describe(@"styling the tab bar", ^{
                it(@"should set the tint color from the theme", ^{
                    tabBarController.tabBar.tintColor should equal([UIColor magentaColor]);
                });

                it(@"should not have a translucent tab bar", ^{
                    tabBarController.tabBar.translucent should_not be_truthy;
                });
            });
        });

        describe(@"launchLoginViewController:", ^{
            beforeEach(^{
                [subject application:application didFinishLaunchingWithOptions:nil];
                subject.loginService = loginService;
                [subject launchLoginViewController:YES];
            });

            it(@"should correctly configured login view controller", ^{
                LoginNavigationViewController *navController = (LoginNavigationViewController *) subject.window.rootViewController;
                navController.topViewController should be_same_instance_as(loginViewController);
            });
        });
    });

    describe(@"sendRequestForGetHomeSummary", ^{
        beforeEach(^{
            spy_on(subject);
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);

            [subject application:application willFinishLaunchingWithOptions:nil];
            [subject sendRequestForGetHomeSummary];
        });

        it(@"should When the nework is not reachable", ^{
            subject should have_received(@selector(loginServiceDidFinishLoggingIn:));
        });
    });

    describe(@"handling events for background url sessions", ^{
        __block URLSessionListener <CedarDouble> *backgroundURLSessionObserver;
        __block void (^capturedCompletionHandler)();

        beforeEach(^{
            backgroundURLSessionObserver = (id)[[URLSessionListener alloc]init];
            [injector bind:[URLSessionListener class] toInstance:backgroundURLSessionObserver];
            spy_on(backgroundURLSessionObserver);


            backgroundURLSessionObserver stub_method(@selector(setCompletionHandler:)).and_do_block(^(void (^completionHandler)()){
                capturedCompletionHandler = completionHandler;
            });

            [subject application:application willFinishLaunchingWithOptions:nil];

        });

        afterEach(^{
            stop_spying_on(backgroundURLSessionObserver);
        });

        it(@"should inform the session observer", ^{
            __block BOOL handlerCalled = NO;

            void (^completionHandler)() = ^{
                handlerCalled = YES;
            };

            [subject application:application handleEventsForBackgroundURLSession:@"My Special Session" completionHandler:completionHandler];

            handlerCalled should be_falsy;
            capturedCompletionHandler();
            handlerCalled should be_truthy;
        });

        it(@"should create a punch request handler", ^{
            subject.punchRequestHandler should be_instance_of([PunchRequestHandler class]);
        });
    });

    describe(@"revitalizing failed punches", ^{

        beforeEach(^{
            [subject application:application willFinishLaunchingWithOptions:nil];
        });

        describe(@"after the user logs in", ^{
            beforeEach(^{
                UserPermissionsStorage *userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
                subject.userPermissionsStorage = userPermissionsStorage;

                  userSession stub_method(@selector(validUserSession)).and_return(YES);

                [subject homeSummaryFetcher:nil didReceiveHomeSummaryResponse:@{
                                                                                @"userSummary": @{@"user":@{@"uri":@"some:user-uri"}}}];
            });
            
            it(@"should tell the punch revitalizer to revitalize", ^{
                punchRevitalizer should have_received(@selector(revitalizePunches));
            });
        });
        
        
        
    });
    
   describe(@"showing business logic failure punches errors", ^{
        beforeEach(^{
            subject.loginCredentialsHelper = loginCredentialsHelper;
            subject.loginCredentialsHelper stub_method (@selector(getLoginCredentials)).and_return(@{@"userName":@"User Name",@"userUri":@"user-uri",@"companyName":@"Company Name"});
            [subject application:application willFinishLaunchingWithOptions:nil];
        });
        describe(@"after the user logs in", ^{
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(YES);
                [subject applicationWillEnterForeground:application];
            });
            
            it(@"should tell the presenter to show alert", ^{
                punchErrorPresenter should have_received(@selector(presentFailedPunchesErrors));
            });
            
            it(@"should call service to get latest value of node backend", ^{
                appConfigRepository should have_received(@selector(appConfigForRequest:));
            });
        });
    });

    
    describe(@"Application Did become active", ^{
        
        beforeEach(^{
            subject.tracker = GATrackerClass;
        });
        
        context(@"when the login credentials are not available", ^{
            beforeEach(^{
                [subject applicationDidBecomeActive:application];
            });
            
            it(@"Call The GATracker method trackScreenView", ^{
                subject.tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"application", TrackerProduct);
            });
            
        });
        
        context(@"when the login credentials are  available", ^{
            beforeEach(^{
                subject.loginCredentialsHelper = loginCredentialsHelper;
                subject.loginCredentialsHelper stub_method (@selector(getLoginCredentials)).and_return(@{@"userName":@"User Name",@"userUri":@"user-uri",@"companyName":@"Company Name"});
                [subject applicationDidBecomeActive:application];
            });
            it(@"Call The GATracker method setUserUri", ^{
                subject.tracker should have_received(@selector(setUserUri:companyName:username:platform:)).with(@"user-uri",@"Company Name",@"User Name",@"gen3");
            });
            
            it(@"Call The GATracker method trackScreenView", ^{
                subject.tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"application", TrackerProduct);
            });
            
        });
        
    });
    
    describe(@"As a NSURLSessionDelegate", ^{
        __block NSURLSession *session;
        beforeEach(^{
            session = nice_fake_for([NSURLSession class]);
            [subject URLSession:session didBecomeInvalidWithError:nil];
        });
        
        it(@"should empty all cookies, cache and credential stores, removes disk files", ^{
            session should have_received(@selector(resetWithCompletionHandler:));
        });
        
    });
 
    describe(@"sync in memory data to plist when app goes to background/terminate", ^{
        __block AppPersistentStorage *appPersistentStorage;
        
        beforeEach(^{
            appPersistentStorage = [AppPersistentStorage sharedInstance];
            [appPersistentStorage createAndParsePersistentStorePlistInDocumentsDirectory];
            spy_on(appPersistentStorage);
        });
        
        context(@"applicationDidEnterBackground", ^{
            beforeEach(^{
                [AppPersistentStorage setObject:@"xxxx" forKey:@"key"];
                [subject applicationDidEnterBackground:application];
            });
            it(@"AppPersistentStorage class should have received decryptDataFromPlist & encryptDataFromPlist", ^{
                appPersistentStorage should have_received(@selector(decryptDataFromPlist));
                appPersistentStorage should have_received(@selector(encryptDataFromDictionary:));
            });
        });
        context(@"applicationWillTerminate", ^{
            beforeEach(^{
                [AppPersistentStorage setObject:@"xxxx" forKey:@"key"];
                [subject applicationWillTerminate:application];
            });
            it(@"AppPersistentStorage class should have received decryptDataFromPlist & encryptDataFromPlist", ^{
                appPersistentStorage should have_received(@selector(decryptDataFromPlist));
                appPersistentStorage should have_received(@selector(encryptDataFromDictionary:));
            });
        });
        
    });
});

SPEC_END
