#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "UIActionSheet+Spec.h"
#import "PunchOverviewController.h"
#import "PunchDetailsController.h"
#import "LocalPunch.h"
#import "PunchPresenter.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import "InjectorProvider.h"
#import "ViolationRepository.h"
#import "InjectorKeys.h"
#import "AllViolationSections.h"
#import <KSDeferred/KSPromise.h>
#import "ViolationsSummaryController.h"
#import "RemotePunch.h"
#import "DeletePunchButtonController.h"
#import "UserPermissionsStorage.h"
#import "PunchRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchRepository.h"
#import "SpinnerDelegate.h"
#import "UIBarButtonItem+Spec.h"
#import "BreakType.h"
#import "BreakTypeRepository.h"
#import "PunchOverviewController.h"
#import "AuditTrailController.h"
#import "PunchAttributeController.h"
#import "ClientType.h"
#import "OfflineLocalPunch.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "PunchDetailsController.h"
#import "Activity.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "TimeLinePunchesSummary.h"
#import "OEFType.h"
#import "PunchValidator.h"
#import "UIAlertView+Spec.h"
#import "ReporteePermissionsStorage.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchOverviewControllerSpec)

describe(@"PunchOverviewController", ^{
    __block PunchOverviewController *subject;
    __block RemotePunch *punch;
    __block UINavigationController *navigationController;
    __block PunchPresenter *punchPresenter;
    __block PunchDetailsController<CedarDouble> *punchDetailsController;
    __block ChildControllerHelper <CedarDouble> *childControllerHelper;
    __block ViolationRepository *violationRepository;
    __block PunchRepository <CedarDouble> *punchRepository;
    __block id<Theme> theme;
    __block NSString *userURI;
    __block NSDate *punchDate;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block UserPermissionsStorage *punchRulesStorage;
    __block ReporteePermissionsStorage *reporteePermission;
    __block BreakTypeRepository *breakTypeRepository;
    __block id<PunchChangeObserverDelegate> punchChangeObserverDelegate;
    __block id<PunchDetailsControllerDelegate> punchDetailsControllerTableViewDelegate;
    __block PunchAttributeController *punchAttributeController;
    __block BreakType *breakType;
    __block CLLocation *location;
    __block NSURL *imageURL;
    __block id<BSInjector, BSBinder> injector;
    __block NSNotificationCenter *notificationCenter;
    __block ReachabilityMonitor *reachabilityMonitor;
    
    beforeEach(^{
        injector = [InjectorProvider injector];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        spy_on(notificationCenter);

        punchChangeObserverDelegate = nice_fake_for(@protocol(PunchChangeObserverDelegate));
        punchDetailsControllerTableViewDelegate = nice_fake_for(@protocol(PunchDetailsControllerDelegate));
        
        punchAttributeController = nice_fake_for([PunchAttributeController class]);
        [injector bind:[PunchAttributeController class] toInstance:punchAttributeController];
        
        punchRepository = nice_fake_for([PunchRepository class]);
        [injector bind:[PunchRepository class] toInstance:punchRepository];
        
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];
        
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];
        
        reporteePermission = nice_fake_for([ReporteePermissionsStorage class]);
        [injector bind:[ReporteePermissionsStorage class] toInstance:reporteePermission];
        
        violationRepository = nice_fake_for([ViolationRepository class]);
        [injector bind:[ViolationRepository class] toInstance:violationRepository];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        punchPresenter = nice_fake_for([PunchPresenter class]);
        [injector bind:[PunchPresenter class] toInstance:punchPresenter];
        
        punchDetailsController = (id)[[PunchDetailsController alloc] initWithUserPermissionsStorage:NULL
                                                                                     punchPresenter:nil
                                                                                              theme:nil];
        spy_on(punchDetailsController);
        [injector bind:[PunchDetailsController class] toInstance:punchDetailsController];
        
        breakTypeRepository = nice_fake_for([BreakTypeRepository class]);
        [injector bind:[BreakTypeRepository class] toInstance:breakTypeRepository];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];
        
        subject = [injector getInstance:[PunchOverviewController class]];
        
        
        punchDate = [NSDate dateWithTimeIntervalSince1970:0];
        userURI = @"my-special-user-uri";
        
        breakType = [[BreakType alloc] initWithName:@"My Special Name"
                                                uri:@"My Special Break Type URI"];
        
        location = [[CLLocation alloc] initWithLatitude:12.0 longitude:34.0];
        
        imageURL = [NSURL URLWithString:@"http://example.com/image.jpg"];
        
        punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                      nonActionedValidations:0
                                         previousPunchStatus:Ticking
                                             nextPunchStatus:Ticking
                                               sourceOfPunch:UnknownSourceOfPunch
                                                  actionType:PunchActionTypePunchOut
                                               oefTypesArray:nil
                                                lastSyncTime:NULL
                                                     project:NULL
                                                 auditHstory:nil
                                                   breakType:breakType
                                                    location:location
                                                  violations:nil
                                                   requestID:@"ABCD123"
                                                    activity:NULL
                                                    duration:nil
                                                      client:NULL
                                                     address:@"My Special Address"
                                                     userURI:userURI
                                                    imageURL:imageURL
                                                        date:punchDate
                                                        task:NULL
                                                         uri:@"my-special-uri"
                                        isTimeEntryAvailable:NO
                                            syncedWithServer:NO
                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
        
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        navigationController.navigationBarHidden = YES;


    });
    
    context(@"should have a navigation bar button item to save", ^{
        beforeEach(^{
            punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
            subject.view should_not be_nil;
        });
        it(@"should have a save button", ^{
            subject.navigationItem.rightBarButtonItem should_not be_nil;
        });
    });

    context(@"should have a navigation bar button item to save", ^{
        beforeEach(^{
            punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
            subject.view should_not be_nil;
        });
        it(@"should have a save button", ^{
            subject.navigationItem.rightBarButtonItem should_not be_nil;
        });
    });

    
    it(@"should not show the date picker for editing time", ^{
        subject.view should_not be_nil;
        subject.datePicker.hidden should be_truthy;
        subject.toolBar.hidden should be_truthy;
        
    });
    
    context(@"should not have a navigation bar button item to edit", ^{

        it(@"should not have save button", ^{
            punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
            punchRulesStorage stub_method(@selector(canEditTimePunch)).again().and_return(NO);

            subject.view should_not be_nil;
            subject.navigationItem.rightBarButtonItem should be_nil;
        });

        it(@"should not have save button", ^{
            punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(NO);
            punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);

            subject.view should_not be_nil;
            subject.navigationItem.rightBarButtonItem should be_nil;
        });

    });
    
    describe(@"presenting violations button controller", ^{
        __block ViolationsButtonController *violationsButtonController;
        
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            theme stub_method(@selector(punchDetailsContentViewBackgroundColor)).and_return([UIColor whiteColor]);
            violationsButtonController = [[ViolationsButtonController alloc] initWithButtonStylist:nil
                                                                                             theme:nil];
            [injector bind:[ViolationsButtonController class] toInstance:violationsButtonController];
            spy_on(violationsButtonController);
            subject.view should_not be_nil;
        });
        
        it(@"should present violations button controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(violationsButtonController, subject, subject.violationsButtonContainerView);
        });
        
        it(@"should style the background appropriately", ^{
            subject.violationsButtonContainerView.backgroundColor should equal([UIColor whiteColor]);
        });
        
        it(@"should setup with delegate", ^{
            violationsButtonController should have_received(@selector(setupWithDelegate:showViolations:))
            .with(subject, YES);
        });

        
        it(@"should make itself the ViolationsButtonController's delegate", ^{
            violationsButtonController.delegate should be_same_instance_as(subject);
        });
        
        
        afterEach(^{
            stop_spying_on(violationsButtonController);
        });
    });
    
    describe(@"presenting the delete button controller", ^{
         __block UIView *containerView;
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
        });
        context(@"when the user has permission to edit punches", ^{
            __block DeletePunchButtonController *deletePunchButtonController;
            beforeEach(^{
                deletePunchButtonController = [[DeletePunchButtonController alloc] initWithButtonStylist:nil theme:nil];
                [injector bind:[DeletePunchButtonController class] toInstance:deletePunchButtonController];
                
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                subject.view should_not be_nil;
                containerView = subject.containerView;
            });
            
            it(@"should configure the deletePunchButtonController correctly", ^{
                deletePunchButtonController.delegate should be_same_instance_as(subject);
            });
            
            it(@"should present the delete button controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(deletePunchButtonController, subject, subject.deletePunchButtonContainerView);
            });

            it(@"should show delete button container view", ^{
                containerView.subviews should contain(subject.deletePunchButtonContainerView);
            });


        });
        
        context(@"when the user does not have permission to edit punches", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(NO);
                subject.view should_not be_nil;
                containerView = subject.containerView;
            });
            
            it(@"should not present the delete button controller", ^{
                childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(Arguments::anything, Arguments::anything, subject.deletePunchButtonContainerView);
            });

            it(@"should remove delete button container view", ^{
                 containerView.subviews should_not contain(subject.deletePunchButtonContainerView);
            });


        });
        
        describe(@"styling the controller", ^{
            beforeEach(^{
                theme stub_method(@selector(punchDetailsContentViewBackgroundColor)).and_return([UIColor whiteColor]);
                subject.view should_not be_nil;
            });
            
            it(@"should style the background", ^{
                subject.deletePunchButtonContainerView.backgroundColor should equal([UIColor whiteColor]);
            });
        });
    });
    
    describe(@"presenting the audit trail controller", ^{
        __block AuditTrailController *auditTrailController;
        
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            theme stub_method(@selector(punchDetailsContentViewBackgroundColor)).and_return([UIColor whiteColor]);
            auditTrailController = [[AuditTrailController alloc] initWithPunchLogsRepository:nil
                                                                                       theme:nil];
            [injector bind:[AuditTrailController class] toInstance:auditTrailController];
            
            subject.view should_not be_nil;
            subject.auditTrailContainerView should_not be_nil;
        });
        
        it(@"should present audit trail controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(auditTrailController, subject, subject.auditTrailContainerView);
        });
        
        it(@"should set up the audit trail controller correctly", ^{
            auditTrailController.delegate should be_same_instance_as(subject);
            auditTrailController.punch should be_same_instance_as(punch);
        });
        
        it(@"should style the background appropriately", ^{
            subject.auditTrailContainerView.backgroundColor should equal([UIColor whiteColor]);
        });
    });
    
    describe(@"as a <ViolationsButtonControllerDelegate>", ^{
        
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
        });
        describe(@"violationsButtonHeightConstraint", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });
            
            it(@"should have a container with the violationsButtonHeightConstraint", ^{
                subject.violationsButtonContainerView.constraints should contain(subject.violationsButtonHeightConstraint);
            });
        });
        
        describe(@"violationsButtonController:didSignalIntentToViewViolationSections:", ^{
            __block UINavigationController *navigationController;
            __block AllViolationSections *expectedAllViolationSections;
            __block ViolationsSummaryController *violationsSummaryController;
            __block KSDeferred *deferred;
            
            beforeEach(^{
                [subject view];
                deferred = [[KSDeferred alloc]init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                
                violationsSummaryController = [[ViolationsSummaryController alloc] initWithSupervisorDashboardSummaryRepository:nil
                                                                                                violationSectionHeaderPresenter:nil
                                                                                                  selectedWaiverOptionPresenter:nil
                                                                                                     violationSeverityPresenter:nil
                                                                                                               teamTableStylist:nil
                                                                                                                spinnerDelegate:nil
                                                                                                                          theme:nil];
                
                spy_on(violationsSummaryController);
                [injector bind:[ViolationsSummaryController class] toInstance:violationsSummaryController];
                
                expectedAllViolationSections = fake_for([AllViolationSections class]);
                
                
                [deferred resolveWithValue:expectedAllViolationSections];
                
                [subject violationsButtonController:nil didSignalIntentToViewViolationSections:expectedAllViolationSections];
                
            });
            
            it(@"should call setupWithViolationSectionsPromise", ^{
                violationsSummaryController should have_received(@selector(setupWithViolationSectionsPromise:delegate:)).with(Arguments::anything, subject);
            });
            
            it(@"should push the violationsSummaryController on to the navigation stack", ^{
                navigationController.topViewController should be_same_instance_as(violationsSummaryController);
            });
        });
        
        describe(@"violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSPromise *expectedViolationsPromise;
            beforeEach(^{
                [subject view];
                expectedViolationsPromise = nice_fake_for([KSPromise class]);
                violationRepository stub_method(@selector(fetchValidationsForPunchURI:))
                .with(@"my-special-uri")
                .and_return(expectedViolationsPromise);
                
                violationsPromise = [subject violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:nil];
            });
            
            it(@"should make a request for todays violations", ^{
                violationsPromise should be_same_instance_as(expectedViolationsPromise);
            });
        });
    });
    
    describe(@"as a <DeletePunchButtonControllerDelegate>", ^{
        __block KSDeferred *deletePunchDeferred;
        
        context(@"When there are observers listening to Delete Action", ^{
            beforeEach(^{
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:UserFlowContext
                                                      userUri:nil];
                subject.view should_not be_nil;
                deletePunchDeferred = [[KSDeferred alloc] init];
                punchRepository stub_method(@selector(deletePunchWithPunchAndFetchMostRecentPunch:))
                .with(punch)
                .and_return(deletePunchDeferred.promise);
                
                [subject deletePunchButtonControllerDidSignalIntentToDeletePunch:nil];
            });
            
            it(@"should present an action sheet", ^{
                UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                NSArray *buttonTitles = [actionSheet buttonTitles];
                [buttonTitles count] should equal(2);
                NSString *deleteStr = [NSString stringWithFormat:@"%@",RPLocalizedString(@"Delete", @"")];
                NSString *cancelStr = [NSString stringWithFormat:@"%@",RPLocalizedString(@"Cancel", @"")];
                buttonTitles[0] should equal(deleteStr);
                buttonTitles[1] should equal(cancelStr);
            });
            
            context(@"when user confirms delete punch action", ^{
                __block UINavigationController *navigationController;
                __block UIViewController *previousController;
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    
                    UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                    [actionSheet dismissByClickingDestructiveButton];
                });
                
                it(@"should start the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should request the server to delete the punch ", ^{
                    punchRepository should have_received(@selector(deletePunchWithPunchAndFetchMostRecentPunch:)).with(punch);
                });
                
                context(@"When the punch delete succeeds", ^{
                    
                    beforeEach(^{
                        [deletePunchDeferred resolveWithValue:[NSNull null]];
                        spy_on(subject.punchRepository);
                        
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        subject.punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(subject.punch.userURI, dateDict);
                        
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should_not be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    context(@"When the timesummary fetch completes", ^{
                        beforeEach(^{
                            [timeSummaryDeferred resolveWithValue:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    
                    context(@"When the timesummary fetch fails", ^{
                        beforeEach(^{
                            [timeSummaryDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                });
                
                context(@"When the punch delete fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        [deletePunchDeferred rejectWithError:error];
                    });
                    
                    it(@"should stay on the current controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        subject.punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
            });
            
        });
        
        context(@"When there are no observers listening to delete Action", ^{
            beforeEach(^{
                [subject setupWithPunchChangeObserverDelegate:nil punch:punch flowType:UserFlowContext userUri:nil];
                subject.view should_not be_nil;
                deletePunchDeferred = [[KSDeferred alloc] init];
                punchRepository stub_method(@selector(deletePunchWithPunchAndFetchMostRecentPunch:))
                .with(punch)
                .and_return(deletePunchDeferred.promise);
                
                [subject deletePunchButtonControllerDidSignalIntentToDeletePunch:nil];
            });
            
            it(@"should present an action sheet", ^{
                UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                NSArray *buttonTitles = [actionSheet buttonTitles];
                [buttonTitles count] should equal(2);
                NSString *deleteStr = [NSString stringWithFormat:@"%@",RPLocalizedString(@"Delete", @"")];
                NSString *cancelStr = [NSString stringWithFormat:@"%@",RPLocalizedString(@"Cancel", @"")];
                buttonTitles[0] should equal(deleteStr);
                buttonTitles[1] should equal(cancelStr);
            });
            
            context(@"when user confirms delete punch action", ^{
                __block UINavigationController *navigationController;
                __block UIViewController *previousController;
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    
                    UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                    [actionSheet dismissByClickingDestructiveButton];
                });
                
                it(@"should start the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should request the server to delete the punch ", ^{
                    punchRepository should have_received(@selector(deletePunchWithPunchAndFetchMostRecentPunch:)).with(punch);
                });
                
                context(@"When the punch delete succeeds", ^{
                    
                    beforeEach(^{
                        [deletePunchDeferred resolveWithValue:[NSNull null]];
                        spy_on(subject.punchRepository);
                        
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        subject.punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(subject.punch.userURI, dateDict);
                        
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                });
                
                context(@"When the punch delete fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        [deletePunchDeferred rejectWithError:error];
                    });
                    
                    it(@"should stay on the current controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        subject.punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
            });
            
        });
    });
    
    describe(@"as a <ViolationsSummaryControllerDelegate>", ^{
        
        describe(@"violationsSummaryControllerDidRequestViolationSectionsPromise", ^{
            beforeEach(^{
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:UserFlowContext
                                                      userUri:nil];
                subject.view should_not be_nil;
                [subject violationsSummaryControllerDidRequestViolationSectionsPromise:nil];
            });
            
            it(@"should request the violations repository for the validations", ^{
                violationRepository should have_received(@selector(fetchValidationsForPunchURI:)).with(subject.punch.uri);
            });
        });
        
        describe(@"violationsSummaryControllerDidRequestToUpdateUI", ^{
            beforeEach(^{
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:UserFlowContext
                                                      userUri:nil];
                subject.view should_not be_nil;
                [subject violationsSummaryControllerDidRequestToUpdateUI:nil];
            });
            
            it(@"should request the to update UI", ^{
                punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
            });
        });
    });
    
    describe(@"as an <AuditTrailControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            subject.view should_not be_nil;
        });
        
        describe(@"auditTrailController:didUpdateHeight:", ^{
            beforeEach(^{
                [subject auditTrailController:(id)[NSNull null] didUpdateHeight:89];
            });
            
            it(@"should update the container's height constraint", ^{
                subject.auditTrailContainerViewHeightConstraint.constant should equal(89);
            });
        });
    });
    
    describe(@"as an <PunchDetailsControllerDelegate>", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            subject.view should_not be_nil;
        });
        
        it(@"should update the container height", ^{
            [subject punchDetailsController:(id)[NSNull null] didUpdateTableViewWithHeight:100];
            subject.punchDetailsContainerViewHeightConstraint.constant should equal(100);
        });
        
        it(@"should show the date picker and date correctly", ^{
            
            NSDate *date = nice_fake_for([NSDate class]);
            id <Punch> expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                             nonActionedValidations:0
                                                                previousPunchStatus:Ticking
                                                                    nextPunchStatus:Ticking
                                                                      sourceOfPunch:UnknownSourceOfPunch
                                                                         actionType:PunchActionTypePunchOut
                                                                      oefTypesArray:nil
                                                                       lastSyncTime:NULL
                                                                            project:NULL
                                                                        auditHstory:nil
                                                                          breakType:breakType
                                                                           location:location
                                                                         violations:nil
                                                                          requestID:@"ABCD123"
                                                                           activity:NULL
                                                                           duration:nil
                                                                             client:NULL
                                                                            address:@"My Special Address"
                                                                            userURI:userURI
                                                                           imageURL:imageURL
                                                                               date:date
                                                                               task:NULL
                                                                                uri:@"my-special-uri"
                                                               isTimeEntryAvailable:NO
                                                                   syncedWithServer:NO
                                                                     isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            id <Punch> punch = nice_fake_for(@protocol(Punch));
            punch stub_method(@selector(date)).and_return(date);
            [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
            subject.datePicker.hidden should be_falsy;
            subject.toolBar.hidden should be_falsy;
            subject.datePicker.date should equal(date);
            punchDetailsController should have_received(@selector(updateWithPunch:)).with(expectedPunch);
        });
        
    });
    
    describe(@"presenting the punch details controller", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            subject.view should_not be_nil;
        });
        
        it(@"should add the a PunchDetailsViewController as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(punchDetailsController, subject, subject.punchDetailsContainerView);
        });
        
        it(@"should configure the PunchDetailsViewController", ^{
            punchDetailsController should have_received(@selector(updateWithPunch:)).with(punch);
        });
    });
    
    describe(@"presenting the Punch Attributes Controller on UserContext", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:@"special-user-uri"];
            subject.view should_not be_nil;
        });
        
        it(@"should add the a PunchAttributeController as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(punchAttributeController, subject, subject.punchAttributeContainerView);
        });
        
        it(@"should configure the PunchAttributeController", ^{
            punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,@"special-user-uri",punch,PunchAttributeScreenTypeEDIT);
        });
    });
    
    describe(@"presenting the Punch Attributes Controller on SupervisorContext", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:SupervisorFlowContext
                                                  userUri:@"special-user-uri"];
            subject.view should_not be_nil;
        });
        
        it(@"should add the a PunchAttributeController as a child controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(punchAttributeController, subject, subject.punchAttributeContainerView);
        });
        
        it(@"should configure the PunchAttributeController", ^{
            punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,SupervisorFlowContext,@"special-user-uri",punch,PunchAttributeScreenTypeEDIT);
        });
    });
    
    describe(@"presenting the navigation information", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });
        
        it(@"should display the correct title in the navigation bar", ^{
            subject.navigationController.navigationBarHidden should_not be_truthy;
        });
    });
    
    describe(@"styling", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            theme stub_method(@selector(punchDetailsContentViewBackgroundColor)).and_return([UIColor whiteColor]);
            subject.view should_not be_nil;
        });
        
        it(@"should style the background", ^{
            subject.view.backgroundColor should equal([UIColor whiteColor]);
        });
    });
    
    describe(@"as an <PunchAttributeControllerDelegate>", ^{
        __block PunchAttributeController *newPunchAttributeController;
        __block id <Punch> expectedPunch;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;
        __block Activity *activity;
        
        beforeEach(^{
            client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                          isTimeAllocationAllowed:NO
                                                                    projectPeriod:nil
                                                                       clientType:nil
                                                                             name:@"project-name"
                                                                              uri:nil];
            task = [[TaskType alloc] initWithProjectUri:nil
                                             taskPeriod:nil
                                                   name:@"task-name"
                                                    uri:@"task-uri"];

            activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
            
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:userURI];
            subject.view should_not be_nil;
            
            newPunchAttributeController = nice_fake_for([PunchAttributeController class]);
            [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeController];
        });
        
        it(@"should update the container height", ^{
            [subject punchAttributeController:(id)[NSNull null] didUpdateTableViewWithHeight:200];
            subject.punchAttributeContainerViewHeightConstraint.constant should equal(200);
        });
        
        context(@"When updating client", ^{
            beforeEach(^{
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:nil
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,userURI,expectedPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });

        context(@"When updating client with updated OEF's", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{

                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];




                [childControllerHelper reset_sent_messages];





                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });
            
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
        });
        
        context(@"When updating client with updated OEF's for Supervisor Flow", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:nil
                                                                         duration:nil
                                                                           client:client
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:nil
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                
                [subject punchAttributeController:nil didIntendToUpdateClient:client];

            });
            
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
            it(@"Flow type should be set to Supervisor", ^{
                subject.flowType should equal(SupervisorFlowContext);
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,SupervisorFlowContext,userURI,originalLocalPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });
        
        context(@"When updating project", ^{
            beforeEach(^{
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:nil
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:nil
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,userURI,expectedPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });

        context(@"When updating project with updated OEF's", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{

                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];




                [childControllerHelper reset_sent_messages];





                [subject punchAttributeController:nil didIntendToUpdateProject:project];
            });

            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
        });
    
        context(@"When updating project with updated OEF's for Supervisor Flow", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:project
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:nil
                                                                         duration:nil
                                                                           client:nil
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:nil
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                
               [subject punchAttributeController:nil didIntendToUpdateProject:project];
                
            });
            
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
            it(@"Flow type should be set to Supervisor", ^{
                subject.flowType should equal(SupervisorFlowContext);
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,SupervisorFlowContext,userURI,originalLocalPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });
        
        context(@"When updating task", ^{
            beforeEach(^{
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:nil
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:task
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,userURI,expectedPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });

        context(@"When updating task with updated OEF's", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{

                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];




                [childControllerHelper reset_sent_messages];





                [subject punchAttributeController:nil didIntendToUpdateTask:task];
            });
            
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
        });
        
        context(@"When updating task with updated OEF's for Supervisor Flow", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:nil
                                                                         duration:nil
                                                                           client:nil
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:task
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
                
            });
            
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
            it(@"Flow type should be set to Supervisor", ^{
                subject.flowType should equal(SupervisorFlowContext);
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,SupervisorFlowContext,userURI,originalLocalPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });
        
        context(@"When updating client should clear previously selected project and task values", ^{
            __block PunchAttributeController *newPunchAttributeControllerA;
            __block PunchAttributeController *newPunchAttributeControllerB;
            beforeEach(^{
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:nil
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                
                newPunchAttributeControllerA = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeControllerA];
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
                
                newPunchAttributeControllerB = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeControllerB];
                
                
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeControllerA,newPunchAttributeControllerB,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeControllerB should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,userURI,expectedPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });
        
        context(@"When updating project should clear previously selected task values", ^{
            __block PunchAttributeController *newPunchAttributeControllerA;
            beforeEach(^{
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:nil
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:nil
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
                
                newPunchAttributeControllerA = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeControllerA];
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newPunchAttributeControllerA,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeControllerA should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,userURI,expectedPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });

        context(@"When updating activity", ^{
            beforeEach(^{
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:nil
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:nil
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,UserFlowContext,userURI,expectedPunch,PunchAttributeScreenTypeEDIT);
            });

        });

        context(@"When updating activity with updated OEF's", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{

                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];




                [childControllerHelper reset_sent_messages];





                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
            });


            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });

        });
        
        context(@"When updating activity with updated OEF's for Supervisor Flow", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:activity
                                                                         duration:nil
                                                                           client:nil
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:nil
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                
                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
                
            });
            
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });
            
            it(@"Flow type should be set to Supervisor", ^{
                subject.flowType should equal(SupervisorFlowContext);
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(YES,subject,SupervisorFlowContext,userURI,originalLocalPunch,PunchAttributeScreenTypeEDIT);
            });
            
        });

        context(@"When updating Default Activity", ^{

            beforeEach(^{
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:nil
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:punchDate
                                                                        task:nil
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateDefaultActivity:activity];
            });

            it(@"should  add a new child view controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });

        });

        context(@"When updating Default Activity when OEF is enabled", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];




                [childControllerHelper reset_sent_messages];

                [subject punchAttributeController:nil didIntendToUpdateDefaultActivity:activity];
            });

            it(@"should  add a new child view controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });



        });

        context(@"When updating Default Activity when OEF is enabled for Supervisor", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{

                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:nil
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:activity
                                                                         duration:nil
                                                                           client:nil
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:nil
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];

                [subject punchAttributeController:nil didIntendToUpdateDefaultActivity:activity];
            });

            it(@"should  add a new child view controller", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });


            
        });

        context(@"When updating dropdown oefTypes for a punch", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(punchSyncStatus)).and_return(RemotePunchStatus);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                originalLocalPunch stub_method(@selector(lastSyncTime)).and_return(NULL);
                originalLocalPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                originalLocalPunch stub_method(@selector(project)).and_return(project);
                originalLocalPunch stub_method(@selector(breakType)).and_return(nil);
                originalLocalPunch stub_method(@selector(location)).and_return(location);
                originalLocalPunch stub_method(@selector(requestID)).and_return(@"ABCD123");
                originalLocalPunch stub_method(@selector(activity)).and_return(NULL);
                originalLocalPunch stub_method(@selector(client)).and_return(client);
                originalLocalPunch stub_method(@selector(address)).and_return(@"My Special Address");
                originalLocalPunch stub_method(@selector(userURI)).and_return(userURI);
                originalLocalPunch stub_method(@selector(imageURL)).and_return(imageURL);
                originalLocalPunch stub_method(@selector(task)).and_return(task);
                originalLocalPunch stub_method(@selector(date)).and_return(punchDate);
                originalLocalPunch stub_method(@selector(uri)).and_return(@"my-special-uri");


                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];

                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateDropDownOEFTypes:@[oefType1,oefType2]];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });

            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(@[oefType1,oefType2]);
            });

            it(@"should have the correct client types", ^{
                subject.punch.client should equal(client);
            });

            it(@"should have the correct project types", ^{
                subject.punch.project should equal(project);
            });

            it(@"should have the correct task types", ^{
                subject.punch.task should equal(task);
            });

        });

        context(@"When updating text/numeric oefTypes for a punch", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = nice_fake_for([RemotePunch class]);
                originalLocalPunch stub_method(@selector(punchSyncStatus)).and_return(RemotePunchStatus);
                originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                originalLocalPunch stub_method(@selector(lastSyncTime)).and_return(NULL);
                originalLocalPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                originalLocalPunch stub_method(@selector(project)).and_return(project);
                originalLocalPunch stub_method(@selector(breakType)).and_return(nil);
                originalLocalPunch stub_method(@selector(location)).and_return(location);
                originalLocalPunch stub_method(@selector(requestID)).and_return(@"ABCD123");
                originalLocalPunch stub_method(@selector(activity)).and_return(NULL);
                originalLocalPunch stub_method(@selector(client)).and_return(client);
                originalLocalPunch stub_method(@selector(address)).and_return(@"My Special Address");
                originalLocalPunch stub_method(@selector(userURI)).and_return(userURI);
                originalLocalPunch stub_method(@selector(imageURL)).and_return(imageURL);
                originalLocalPunch stub_method(@selector(task)).and_return(task);
                originalLocalPunch stub_method(@selector(date)).and_return(punchDate);
                originalLocalPunch stub_method(@selector(uri)).and_return(@"my-special-uri");


                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:UserFlowContext
                                                      userUri:userURI];

                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTextOrNumericOEFTypes:@[oefType1,oefType2]];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });

            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(@[oefType1,oefType2]);
            });

            it(@"should have the correct client types", ^{
                subject.punch.client should equal(client);
            });

            it(@"should have the correct project types", ^{
                subject.punch.project should equal(project);
            });

            it(@"should have the correct task types", ^{
                subject.punch.task should equal(task);
            });
            
        });
        
        context(@"When updating dropdown oefTypes for a punch in Supervisor Flow", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];;
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:project
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:activity
                                                                         duration:nil
                                                                           client:client
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:task
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateDropDownOEFTypes:@[oefType1,oefType2]];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(@[oefType1,oefType2]);
            });

            it(@"should have the correct client types", ^{
                subject.punch.client should equal(client);
            });

            it(@"should have the correct project types", ^{
                subject.punch.project should equal(project);
            });

            it(@"should have the correct task types", ^{
                subject.punch.task should equal(task);
            });
            
        });

        context(@"When updating text/numeric oefTypes for a punch in Supervisor Flow", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block RemotePunch *originalLocalPunch;
            beforeEach(^{
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                originalLocalPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                           nonActionedValidations:0
                                                              previousPunchStatus:Ticking
                                                                  nextPunchStatus:Ticking
                                                                    sourceOfPunch:UnknownSourceOfPunch
                                                                       actionType:PunchActionTypePunchOut
                                                                    oefTypesArray:oefTypesArray
                                                                     lastSyncTime:NULL
                                                                          project:project
                                                                      auditHstory:nil
                                                                        breakType:breakType
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD123"
                                                                         activity:activity
                                                                         duration:nil
                                                                           client:client
                                                                          address:@"My Special Address"
                                                                          userURI:userURI
                                                                         imageURL:imageURL
                                                                             date:punchDate
                                                                             task:task
                                                                              uri:@"my-special-uri"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:originalLocalPunch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];


                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });

            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });

            it(@"should have the correct client types", ^{
                subject.punch.client should equal(client);
            });

            it(@"should have the correct project types", ^{
                subject.punch.project should equal(project);
            });

            it(@"should have the correct task types", ^{
                subject.punch.task should equal(task);
            });

        });

        it(@"scroll the scrollview to textview cursor", ^{
            UITextView *textView = nice_fake_for([UITextView class]);
            textView.text = @"testing!!!";
            spy_on(subject.scrollView);
            [subject punchAttributeController:nil didScrolltoSubview:textView];
            subject.scrollView should have_received(@selector(setContentOffset:)).with(CGPointMake(0, -200.0));

            textView should have_received(@selector(setEditable:)).with(YES);
        });

    });
    
    describe(@"Editing a Punch on UserContext", ^{
        describe(@"Editing a punch", ^{
            describe(@"when Network is Reachable", ^{
            describe(@"Editing a punch", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                //__block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:nil
                                                                    lastSyncTime:NULL
                                                                         project:NULL
                                                                     auditHstory:nil
                                                                       breakType:breakType
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:NULL
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:NULL
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                    
                });
                
                it(@"should save the punch", ^{
                    punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(YES);
                });
                
                context(@"when the punch is saved", ^{
                    __block KSDeferred *timeSummaryDeferred;
                    beforeEach(^{
                        timeSummaryDeferred = [[KSDeferred alloc]init];
                        punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                        [punchRepository reset_sent_messages];
                        [punchDetailsController reset_sent_messages];
                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                        [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    
                    it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                        punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                    });
                    
                    it(@"should ask the punchRepository to recalculate script data", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should_not be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    context(@"When the timesummary fetch completes", ^{
                        beforeEach(^{
                            [timeSummaryDeferred resolveWithValue:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    
                    context(@"When the timesummary fetch fails", ^{
                        beforeEach(^{
                            [timeSummaryDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                    
                });
                
                context(@"when the punch cannot be saved", ^{
                    
                    context(@"with network available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should not dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(subject);
                        });
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    context(@"with network not available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                });
            });
        });
            
            describe(@"when Network is not Reachable", ^{
                describe(@"Editing a punch", ^{
                    __block UINavigationController *navigationController;
                    __block KSDeferred *updatePunchDeferred;
                    __block UIViewController *previousController;
                    __block id <Punch> savedPunch;
                    __block id <Punch> expectedPunch;
                    __block NSDate *date;
                    //__block KSDeferred *timeSummaryDeferred;
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                        
                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                punch:punch
                                                             flowType:UserFlowContext
                                                              userUri:userURI];
                        punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                        subject.view should_not be_nil;
                        
                        spy_on(subject.view);
                        
                        previousController = [[UIViewController alloc] init];
                        navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                        [navigationController pushViewController:subject animated:NO];
                        
                        updatePunchDeferred = [KSDeferred defer];
                        punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                        
                        date = nice_fake_for([NSDate class]);
                        id <Punch> punch = nice_fake_for(@protocol(Punch));
                        punch stub_method(@selector(date)).and_return(date);
                        [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                        
                        expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypePunchOut
                                                                       oefTypesArray:nil
                                                                        lastSyncTime:NULL
                                                                             project:NULL
                                                                         auditHstory:nil
                                                                           breakType:breakType
                                                                            location:location
                                                                          violations:nil
                                                                           requestID:@"ABCD123"
                                                                            activity:NULL
                                                                            duration:nil
                                                                              client:NULL
                                                                             address:@"My Special Address"
                                                                             userURI:userURI
                                                                            imageURL:imageURL
                                                                                date:date
                                                                                task:NULL
                                                                                 uri:@"my-special-uri"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                        
                        [subject.navigationItem.rightBarButtonItem tap];
                        
                        savedPunch = nice_fake_for(@protocol(Punch));
                        savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                        
                    });
                    
                    it(@"should not save the punch", ^{
                        punchRepository should_not have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                    });
                    
                    it(@"should not display the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                    });
                    
                    it(@"should show offline message", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                    });

                });
            });
        });

        describe(@"Editing Text/Numeric OEFs in a punch", ^{
            
            context(@"when Network is Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:NULL
                                                             auditHstory:nil
                                                               breakType:breakType
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:NULL
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:NULL
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeUpdated = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 3" punchActionType:nil numericValue:nil textValue:@"oef value3" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:NULL
                                                                     auditHstory:nil
                                                                       breakType:breakType
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:NULL
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:NULL
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should save the punch", ^{
                    punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(YES);
                });
                
                context(@"when the punch is saved", ^{
                    __block KSDeferred *timeSummaryDeferred;
                    beforeEach(^{
                        timeSummaryDeferred = [[KSDeferred alloc]init];
                        punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                        [punchRepository reset_sent_messages];
                        [punchDetailsController reset_sent_messages];
                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                        [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    
                    it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                        punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                    });
                    
                    it(@"should ask the punchRepository to recalculate script data", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should_not be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    context(@"When the timesummary fetch completes", ^{
                        beforeEach(^{
                            [timeSummaryDeferred resolveWithValue:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    
                    context(@"When the timesummary fetch fails", ^{
                        beforeEach(^{
                            [timeSummaryDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                    
                });
                
                context(@"when the punch cannot be saved", ^{
                    
                    context(@"with network available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should not dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(subject);
                        });
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    context(@"with network not available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                });
            });
            
            context(@"when Network is not Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:NULL
                                                             auditHstory:nil
                                                               breakType:breakType
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:NULL
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:NULL
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeUpdated = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 3" punchActionType:nil numericValue:nil textValue:@"oef value3" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:NULL
                                                                     auditHstory:nil
                                                                       breakType:breakType
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:NULL
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:NULL
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should not save the punch", ^{
                    punchRepository should_not have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should_not display the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should show offline message", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                });
            });
        });
        
        describe(@"Editing dropdown OEFs in a punch", ^{
            
            context(@"when Network is Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:NULL
                                                             auditHstory:nil
                                                               breakType:breakType
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:NULL
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:NULL
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:NULL
                                                                     auditHstory:nil
                                                                       breakType:breakType
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:NULL
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:NULL
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should save the punch", ^{
                    punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(YES);
                });
                
                context(@"when the punch is saved", ^{
                    __block KSDeferred *timeSummaryDeferred;
                    beforeEach(^{
                        timeSummaryDeferred = [[KSDeferred alloc]init];
                        punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                        [punchRepository reset_sent_messages];
                        [punchDetailsController reset_sent_messages];
                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                        [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    
                    it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                        punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                    });
                    
                    it(@"should ask the punchRepository to recalculate script data", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should_not be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    context(@"When the timesummary fetch completes", ^{
                        beforeEach(^{
                            [timeSummaryDeferred resolveWithValue:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    
                    context(@"When the timesummary fetch fails", ^{
                        beforeEach(^{
                            [timeSummaryDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                    
                });
                
                context(@"when the punch cannot be saved", ^{
                    
                    context(@"with network available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should not dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(subject);
                        });
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    context(@"with network not available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                    
                });
            });
            
            context(@"when Network is not Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:NULL
                                                             auditHstory:nil
                                                               breakType:breakType
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:NULL
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:NULL
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:NULL
                                                                     auditHstory:nil
                                                                       breakType:breakType
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:NULL
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:NULL
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should not save the punch", ^{
                    punchRepository should_not have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should display the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should not show offline message", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                });
            });
        });
        
        describe(@"Editing project/task with OEFs in a punch with NO client access", ^{
            
            context(@"when Network is Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:nil];
                    task = [[TaskType alloc] initWithProjectUri:nil
                                                     taskPeriod:nil
                                                           name:@"task-name"
                                                            uri:@"task-uri"];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:project
                                                             auditHstory:nil
                                                               breakType:nil
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:client
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:task
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                    
                    ProjectType *updatedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"project-name-updated"
                                                                                                          uri:nil];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateProject:updatedProject];
                    
                    TaskType *updatedTask = [[TaskType alloc] initWithProjectUri:nil
                                                                      taskPeriod:nil
                                                                            name:@"task-name-updated"
                                                                             uri:@"task-uri-updated"];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTask:updatedTask];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:updatedProject
                                                                     auditHstory:nil
                                                                       breakType:NULL
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:client
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:updatedTask
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should save the punch", ^{
                    punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(YES);
                });
                
                context(@"when the punch is saved", ^{
                    __block KSDeferred *timeSummaryDeferred;
                    beforeEach(^{
                        timeSummaryDeferred = [[KSDeferred alloc]init];
                        punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                        [punchRepository reset_sent_messages];
                        [punchDetailsController reset_sent_messages];
                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                        [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    
                    it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                        punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                    });
                    
                    it(@"should ask the punchRepository to recalculate script data", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should_not be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    context(@"When the timesummary fetch completes", ^{
                        beforeEach(^{
                            [timeSummaryDeferred resolveWithValue:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    
                    context(@"When the timesummary fetch fails", ^{
                        beforeEach(^{
                            [timeSummaryDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                    
                });
                
                context(@"when the punch cannot be saved", ^{
                    
                    context(@"with network available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should not dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(subject);
                        });
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    context(@"with network not available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                });
            });
            
            context(@"when Network is not Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:nil];
                    task = [[TaskType alloc] initWithProjectUri:nil
                                                     taskPeriod:nil
                                                           name:@"task-name"
                                                            uri:@"task-uri"];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:project
                                                             auditHstory:nil
                                                               breakType:nil
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:client
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:task
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                    
                    ProjectType *updatedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"project-name-updated"
                                                                                                          uri:nil];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateProject:updatedProject];
                    
                    TaskType *updatedTask = [[TaskType alloc] initWithProjectUri:nil
                                                                      taskPeriod:nil
                                                                            name:@"task-name-updated"
                                                                             uri:@"task-uri-updated"];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTask:updatedTask];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:updatedProject
                                                                     auditHstory:nil
                                                                       breakType:NULL
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:client
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:updatedTask
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should_not save the punch", ^{
                    punchRepository should_not have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should_not display the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should show offline message", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                });

            });
        });
        
        describe(@"Editing client/project/task with OEFs in a punch with client access", ^{
            
            context(@"when Network is Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:nil];
                    task = [[TaskType alloc] initWithProjectUri:nil
                                                     taskPeriod:nil
                                                           name:@"task-name"
                                                            uri:@"task-uri"];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:project
                                                             auditHstory:nil
                                                               breakType:nil
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:client
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:task
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeDropDownUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeDropDownUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                    
                    ClientType *updatedClient = [[ClientType alloc]initWithName:@"client-name-updated" uri:@"client-uri-updated"];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateClient:updatedClient];
                    
                    ProjectType *updatedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"project-name-updated"
                                                                                                          uri:nil];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateProject:updatedProject];
                    
                    TaskType *updatedTask = [[TaskType alloc] initWithProjectUri:nil
                                                                      taskPeriod:nil
                                                                            name:@"task-name-updated"
                                                                             uri:@"task-uri-updated"];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTask:updatedTask];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:updatedProject
                                                                     auditHstory:nil
                                                                       breakType:NULL
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:updatedClient
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:updatedTask
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should save the punch", ^{
                    punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(YES);
                });
                
                context(@"when the punch is saved", ^{
                    __block KSDeferred *timeSummaryDeferred;
                    beforeEach(^{
                        timeSummaryDeferred = [[KSDeferred alloc]init];
                        punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                        [punchRepository reset_sent_messages];
                        [punchDetailsController reset_sent_messages];
                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                        [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    
                    it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                        punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                    });
                    
                    it(@"should ask the punchRepository to recalculate script data", ^{
                        NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                        punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                    });
                    
                    it(@"should inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should_not be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    context(@"When the timesummary fetch completes", ^{
                        beforeEach(^{
                            [timeSummaryDeferred resolveWithValue:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    
                    context(@"When the timesummary fetch fails", ^{
                        beforeEach(^{
                            [timeSummaryDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                    
                });
                
                context(@"when the punch cannot be saved", ^{
                    
                    context(@"with network available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should not dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(subject);
                        });
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                        
                        
                    });
                    context(@"with network not available", ^{
                        
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                            [updatePunchDeferred rejectWithError:nil];
                        });
                        
                        it(@"should pop back one controller in the nav stack", ^{
                            navigationController.topViewController should be_same_instance_as(previousController);
                        });
                        
                        
                        
                        it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                            punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                        });
                        
                        it(@"should not inform its delegate that punch has been deleted", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should stop the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                });
            });
            
            context(@"when Network is not Reachable", ^{
                __block UINavigationController *navigationController;
                __block KSDeferred *updatePunchDeferred;
                __block UIViewController *previousController;
                __block id <Punch> savedPunch;
                __block id <Punch> expectedPunch;
                __block NSDate *date;
                __block OEFType *oefType1;
                __block OEFType *oefType2;
                __block OEFType *oefType3;
                __block NSMutableArray *oefTypesArray;
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"project-name"
                                                                                      uri:nil];
                    task = [[TaskType alloc] initWithProjectUri:nil
                                                     taskPeriod:nil
                                                           name:@"task-name"
                                                            uri:@"task-uri"];
                    
                    punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Ticking
                                                         nextPunchStatus:Ticking
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchOut
                                                           oefTypesArray:oefTypesArray
                                                            lastSyncTime:NULL
                                                                 project:project
                                                             auditHstory:nil
                                                               breakType:nil
                                                                location:location
                                                              violations:nil
                                                               requestID:@"ABCD123"
                                                                activity:NULL
                                                                duration:nil
                                                                  client:client
                                                                 address:@"My Special Address"
                                                                 userURI:userURI
                                                                imageURL:imageURL
                                                                    date:punchDate
                                                                    task:task
                                                                     uri:@"my-special-uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch
                                                         flowType:UserFlowContext
                                                          userUri:userURI];
                    
                    punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    subject.view should_not be_nil;
                    
                    spy_on(subject.view);
                    
                    previousController = [[UIViewController alloc] init];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                    [navigationController pushViewController:subject animated:NO];
                    
                    updatePunchDeferred = [KSDeferred defer];
                    punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                    
                    date = nice_fake_for([NSDate class]);
                    id <Punch> punch = nice_fake_for(@protocol(Punch));
                    punch stub_method(@selector(date)).and_return(date);
                    [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                    
                    OEFType *oefTypeDropDownUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeDropDownUpdated, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                    
                    ClientType *updatedClient = [[ClientType alloc]initWithName:@"client-name-updated" uri:@"client-uri-updated"];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateClient:updatedClient];
                    
                    ProjectType *updatedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                      isTimeAllocationAllowed:NO
                                                                                                projectPeriod:nil
                                                                                                   clientType:nil
                                                                                                         name:@"project-name-updated"
                                                                                                          uri:nil];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateProject:updatedProject];
                    
                    TaskType *updatedTask = [[TaskType alloc] initWithProjectUri:nil
                                                                      taskPeriod:nil
                                                                            name:@"task-name-updated"
                                                                             uri:@"task-uri-updated"];
                    
                    [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTask:updatedTask];
                    
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:oefTypesArray
                                                                    lastSyncTime:NULL
                                                                         project:updatedProject
                                                                     auditHstory:nil
                                                                       breakType:NULL
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:updatedClient
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:date
                                                                            task:updatedTask
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    
                    savedPunch = nice_fake_for(@protocol(Punch));
                    savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
                });
                
                it(@"should_not save the punch", ^{
                    punchRepository should_not have_received(@selector(updatePunch:)).with(@[expectedPunch]);
                });
                
                it(@"should_not display the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(showTransparentLoadingOverlay));
                });
                
                it(@"should show offline message", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                });
            });
        });
    });
    
    describe(@"Editing a Punch on Supervisor Context", ^{
        
        describe(@"Editing a punch", ^{
            __block UINavigationController *navigationController;
            __block KSDeferred *updatePunchDeferred;
            __block UIViewController *previousController;
            __block id <Punch> savedPunch;
            __block id <Punch> expectedPunch;
            __block NSDate *date;
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                subject.view should_not be_nil;
                
                spy_on(subject.view);
                
                previousController = [[UIViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                [navigationController pushViewController:subject animated:NO];
                
                updatePunchDeferred = [KSDeferred defer];
                punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                
                date = nice_fake_for([NSDate class]);
                id <Punch> punch = nice_fake_for(@protocol(Punch));
                punch stub_method(@selector(date)).and_return(date);
                [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:NULL
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:NULL
                                                                    duration:nil
                                                                      client:NULL
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:date
                                                                        task:NULL
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject.navigationItem.rightBarButtonItem tap];
                
                savedPunch = nice_fake_for(@protocol(Punch));
                savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
            });
            
            it(@"should save the punch", ^{
                punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
            });
            
            it(@"should display the spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            it(@"should end view editing", ^{
                subject.view should have_received(@selector(endEditing:)).with(YES);
            });
            
            context(@"when the punch is saved", ^{
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    [punchRepository reset_sent_messages];
                    [punchDetailsController reset_sent_messages];
                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                    [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                });
                
                it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                    punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                });
                
                it(@"should ask the punchRepository to recalculate script data", ^{
                    NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                    punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                });
                
                it(@"should inform its delegate that punch has been deleted", ^{
                    punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                });
                
                
                it(@"should pop back one controller in the nav stack", ^{
                    navigationController.topViewController should_not be_same_instance_as(previousController);
                });
                
                it(@"should stop the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                context(@"When the timesummary fetch completes", ^{
                    beforeEach(^{
                        [timeSummaryDeferred resolveWithValue:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                
                context(@"When the timesummary fetch fails", ^{
                    beforeEach(^{
                        [timeSummaryDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
                
            });
            
            context(@"when the punch cannot be saved", ^{
                
                context(@"with network available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                context(@"with network not available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
            });
        });
        
        describe(@"Editing Text/Numeric OEFs in a punch", ^{
            __block UINavigationController *navigationController;
            __block KSDeferred *updatePunchDeferred;
            __block UIViewController *previousController;
            __block id <Punch> savedPunch;
            __block id <Punch> expectedPunch;
            __block NSDate *date;
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block NSMutableArray *oefTypesArray;
            
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                              nonActionedValidations:0
                                                 previousPunchStatus:Ticking
                                                     nextPunchStatus:Ticking
                                                       sourceOfPunch:UnknownSourceOfPunch
                                                          actionType:PunchActionTypePunchOut
                                                       oefTypesArray:oefTypesArray
                                                        lastSyncTime:NULL
                                                             project:NULL
                                                         auditHstory:nil
                                                           breakType:breakType
                                                            location:location
                                                          violations:nil
                                                           requestID:@"ABCD123"
                                                            activity:NULL
                                                            duration:nil
                                                              client:NULL
                                                             address:@"My Special Address"
                                                             userURI:userURI
                                                            imageURL:imageURL
                                                                date:punchDate
                                                                task:NULL
                                                                 uri:@"my-special-uri"
                                                isTimeEntryAvailable:NO
                                                    syncedWithServer:NO
                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                subject.view should_not be_nil;
                
                spy_on(subject.view);
                
                previousController = [[UIViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                [navigationController pushViewController:subject animated:NO];
                
                updatePunchDeferred = [KSDeferred defer];
                punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                
                date = nice_fake_for([NSDate class]);
                id <Punch> punch = nice_fake_for(@protocol(Punch));
                punch stub_method(@selector(date)).and_return(date);
                [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                
                OEFType *oefTypeUpdated = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 3" punchActionType:nil numericValue:nil textValue:@"oef value3" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
                
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:oefTypesArray
                                                                lastSyncTime:NULL
                                                                     project:NULL
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:NULL
                                                                    duration:nil
                                                                      client:NULL
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:date
                                                                        task:NULL
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject.navigationItem.rightBarButtonItem tap];
                
                savedPunch = nice_fake_for(@protocol(Punch));
                savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
            });
            
            it(@"should save the punch", ^{
                punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
            });
            
            it(@"should display the spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            it(@"should end view editing", ^{
                subject.view should have_received(@selector(endEditing:)).with(YES);
            });
            
            context(@"when the punch is saved", ^{
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    [punchRepository reset_sent_messages];
                    [punchDetailsController reset_sent_messages];
                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                    [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                });
                
                it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                    punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                });
                
                it(@"should ask the punchRepository to recalculate script data", ^{
                    NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                    punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                });
                
                it(@"should inform its delegate that punch has been deleted", ^{
                    punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                });
                
                
                it(@"should pop back one controller in the nav stack", ^{
                    navigationController.topViewController should_not be_same_instance_as(previousController);
                });
                
                it(@"should stop the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                context(@"When the timesummary fetch completes", ^{
                    beforeEach(^{
                        [timeSummaryDeferred resolveWithValue:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                
                context(@"When the timesummary fetch fails", ^{
                    beforeEach(^{
                        [timeSummaryDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
                
            });
            
            context(@"when the punch cannot be saved", ^{
                
                context(@"with network available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                context(@"with network not available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
            });
        });
        
        describe(@"Editing dropdown OEFs in a punch", ^{
            __block UINavigationController *navigationController;
            __block KSDeferred *updatePunchDeferred;
            __block UIViewController *previousController;
            __block id <Punch> savedPunch;
            __block id <Punch> expectedPunch;
            __block NSDate *date;
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block NSMutableArray *oefTypesArray;
            
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                              nonActionedValidations:0
                                                 previousPunchStatus:Ticking
                                                     nextPunchStatus:Ticking
                                                       sourceOfPunch:UnknownSourceOfPunch
                                                          actionType:PunchActionTypePunchOut
                                                       oefTypesArray:oefTypesArray
                                                        lastSyncTime:NULL
                                                             project:NULL
                                                         auditHstory:nil
                                                           breakType:breakType
                                                            location:location
                                                          violations:nil
                                                           requestID:@"ABCD123"
                                                            activity:NULL
                                                            duration:nil
                                                              client:NULL
                                                             address:@"My Special Address"
                                                             userURI:userURI
                                                            imageURL:imageURL
                                                                date:punchDate
                                                                task:NULL
                                                                 uri:@"my-special-uri"
                                                isTimeEntryAvailable:NO
                                                    syncedWithServer:NO
                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                subject.view should_not be_nil;
                
                spy_on(subject.view);
                
                previousController = [[UIViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                [navigationController pushViewController:subject animated:NO];
                
                updatePunchDeferred = [KSDeferred defer];
                punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                
                date = nice_fake_for([NSDate class]);
                id <Punch> punch = nice_fake_for(@protocol(Punch));
                punch stub_method(@selector(date)).and_return(date);
                [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                
                OEFType *oefTypeUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:oefTypesArray
                                                                lastSyncTime:NULL
                                                                     project:NULL
                                                                 auditHstory:nil
                                                                   breakType:breakType
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:NULL
                                                                    duration:nil
                                                                      client:NULL
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:date
                                                                        task:NULL
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject.navigationItem.rightBarButtonItem tap];
                
                savedPunch = nice_fake_for(@protocol(Punch));
                savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
            });
            
            it(@"should save the punch", ^{
                punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
            });
            
            it(@"should display the spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            it(@"should end view editing", ^{
                subject.view should have_received(@selector(endEditing:)).with(YES);
            });
            
            context(@"when the punch is saved", ^{
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    [punchRepository reset_sent_messages];
                    [punchDetailsController reset_sent_messages];
                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                    [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                });
                
                it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                    punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                });
                
                it(@"should ask the punchRepository to recalculate script data", ^{
                    NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                    punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                });
                
                it(@"should inform its delegate that punch has been deleted", ^{
                    punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                });
                
                
                it(@"should pop back one controller in the nav stack", ^{
                    navigationController.topViewController should_not be_same_instance_as(previousController);
                });
                
                it(@"should stop the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                context(@"When the timesummary fetch completes", ^{
                    beforeEach(^{
                        [timeSummaryDeferred resolveWithValue:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                
                context(@"When the timesummary fetch fails", ^{
                    beforeEach(^{
                        [timeSummaryDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
                
            });
            
            context(@"when the punch cannot be saved", ^{
                
                context(@"with network available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                context(@"with network not available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
            });
        });
        
        describe(@"Editing project/task with OEFs in a punch with NO client access", ^{
            __block UINavigationController *navigationController;
            __block KSDeferred *updatePunchDeferred;
            __block UIViewController *previousController;
            __block id <Punch> savedPunch;
            __block id <Punch> expectedPunch;
            __block NSDate *date;
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block NSMutableArray *oefTypesArray;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                
                punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                              nonActionedValidations:0
                                                 previousPunchStatus:Ticking
                                                     nextPunchStatus:Ticking
                                                       sourceOfPunch:UnknownSourceOfPunch
                                                          actionType:PunchActionTypePunchOut
                                                       oefTypesArray:oefTypesArray
                                                        lastSyncTime:NULL
                                                             project:project
                                                         auditHstory:nil
                                                           breakType:nil
                                                            location:location
                                                          violations:nil
                                                           requestID:@"ABCD123"
                                                            activity:NULL
                                                            duration:nil
                                                              client:client
                                                             address:@"My Special Address"
                                                             userURI:userURI
                                                            imageURL:imageURL
                                                                date:punchDate
                                                                task:task
                                                                 uri:@"my-special-uri"
                                                isTimeEntryAvailable:NO
                                                    syncedWithServer:NO
                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                subject.view should_not be_nil;
                
                spy_on(subject.view);
                
                previousController = [[UIViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                [navigationController pushViewController:subject animated:NO];
                
                updatePunchDeferred = [KSDeferred defer];
                punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                
                date = nice_fake_for([NSDate class]);
                id <Punch> punch = nice_fake_for(@protocol(Punch));
                punch stub_method(@selector(date)).and_return(date);
                [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                
                OEFType *oefTypeUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeUpdated, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                
                ProjectType *updatedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                  isTimeAllocationAllowed:NO
                                                                                            projectPeriod:nil
                                                                                               clientType:nil
                                                                                                     name:@"project-name-updated"
                                                                                                      uri:nil];
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateProject:updatedProject];
                
                TaskType *updatedTask = [[TaskType alloc] initWithProjectUri:nil
                                                                  taskPeriod:nil
                                                                        name:@"task-name-updated"
                                                                         uri:@"task-uri-updated"];
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTask:updatedTask];
                
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:oefTypesArray
                                                                lastSyncTime:NULL
                                                                     project:updatedProject
                                                                 auditHstory:nil
                                                                   breakType:NULL
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:NULL
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:date
                                                                        task:updatedTask
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject.navigationItem.rightBarButtonItem tap];
                
                savedPunch = nice_fake_for(@protocol(Punch));
                savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
            });
            
            it(@"should save the punch", ^{
                punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
            });
            
            it(@"should display the spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            it(@"should end view editing", ^{
                subject.view should have_received(@selector(endEditing:)).with(YES);
            });
            
            context(@"when the punch is saved", ^{
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    [punchRepository reset_sent_messages];
                    [punchDetailsController reset_sent_messages];
                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                    [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                });
                
                it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                    punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                });
                
                it(@"should ask the punchRepository to recalculate script data", ^{
                    NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                    punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                });
                
                it(@"should inform its delegate that punch has been deleted", ^{
                    punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                });
                
                
                it(@"should pop back one controller in the nav stack", ^{
                    navigationController.topViewController should_not be_same_instance_as(previousController);
                });
                
                it(@"should stop the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                context(@"When the timesummary fetch completes", ^{
                    beforeEach(^{
                        [timeSummaryDeferred resolveWithValue:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                
                context(@"When the timesummary fetch fails", ^{
                    beforeEach(^{
                        [timeSummaryDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
                
            });
            
            context(@"when the punch cannot be saved", ^{
                
                context(@"with network available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                context(@"with network not available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
            });
        });
        
        describe(@"Editing client/project/task with OEFs in a punch with client access", ^{
            __block UINavigationController *navigationController;
            __block KSDeferred *updatePunchDeferred;
            __block UIViewController *previousController;
            __block id <Punch> savedPunch;
            __block id <Punch> expectedPunch;
            __block NSDate *date;
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block NSMutableArray *oefTypesArray;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                
                punch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                              nonActionedValidations:0
                                                 previousPunchStatus:Ticking
                                                     nextPunchStatus:Ticking
                                                       sourceOfPunch:UnknownSourceOfPunch
                                                          actionType:PunchActionTypePunchOut
                                                       oefTypesArray:oefTypesArray
                                                        lastSyncTime:NULL
                                                             project:project
                                                         auditHstory:nil
                                                           breakType:nil
                                                            location:location
                                                          violations:nil
                                                           requestID:@"ABCD123"
                                                            activity:NULL
                                                            duration:nil
                                                              client:client
                                                             address:@"My Special Address"
                                                             userURI:userURI
                                                            imageURL:imageURL
                                                                date:punchDate
                                                                task:task
                                                                 uri:@"my-special-uri"
                                                isTimeEntryAvailable:NO
                                                    syncedWithServer:NO
                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                        punch:punch
                                                     flowType:SupervisorFlowContext
                                                      userUri:userURI];
                
                punchRulesStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                subject.view should_not be_nil;
                
                spy_on(subject.view);
                
                previousController = [[UIViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:previousController];
                [navigationController pushViewController:subject animated:NO];
                
                updatePunchDeferred = [KSDeferred defer];
                punchRepository stub_method(@selector(updatePunch:)).and_return(updatePunchDeferred.promise);
                
                date = nice_fake_for([NSDate class]);
                id <Punch> punch = nice_fake_for(@protocol(Punch));
                punch stub_method(@selector(date)).and_return(date);
                [subject punchDetailsController:(id)[NSNull null] didIntendToChangeDateOrTimeOfPunch:punch];
                
                OEFType *oefTypeDropDownUpdated =  [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 3" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-3" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefTypeDropDownUpdated, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateDropDownOEFTypes:oefTypesArray];
                
                ClientType *updatedClient = [[ClientType alloc]initWithName:@"client-name-updated" uri:@"client-uri-updated"];
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateClient:updatedClient];
                
                ProjectType *updatedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                  isTimeAllocationAllowed:NO
                                                                                            projectPeriod:nil
                                                                                               clientType:nil
                                                                                                     name:@"project-name-updated"
                                                                                                      uri:nil];
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateProject:updatedProject];
                
                TaskType *updatedTask = [[TaskType alloc] initWithProjectUri:nil
                                                                  taskPeriod:nil
                                                                        name:@"task-name-updated"
                                                                         uri:@"task-uri-updated"];
                
                [subject punchAttributeController:(id)[NSNull null] didIntendToUpdateTask:updatedTask];
                
                
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:oefTypesArray
                                                                lastSyncTime:NULL
                                                                     project:updatedProject
                                                                 auditHstory:nil
                                                                   breakType:NULL
                                                                    location:location
                                                                  violations:nil
                                                                   requestID:@"ABCD123"
                                                                    activity:NULL
                                                                    duration:nil
                                                                      client:updatedClient
                                                                     address:@"My Special Address"
                                                                     userURI:userURI
                                                                    imageURL:imageURL
                                                                        date:date
                                                                        task:updatedTask
                                                                         uri:@"my-special-uri"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject.navigationItem.rightBarButtonItem tap];
                
                savedPunch = nice_fake_for(@protocol(Punch));
                savedPunch stub_method(@selector(userURI)).and_return(@"user-uri");
            });
            
            it(@"should save the punch", ^{
                punchRepository should have_received(@selector(updatePunch:)).with(@[expectedPunch]);
            });
            
            it(@"should display the spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });
            
            it(@"should end view editing", ^{
                subject.view should have_received(@selector(endEditing:)).with(YES);
            });
            
            context(@"when the punch is saved", ^{
                __block KSDeferred *timeSummaryDeferred;
                beforeEach(^{
                    timeSummaryDeferred = [[KSDeferred alloc]init];
                    punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timeSummaryDeferred.promise);
                    [punchRepository reset_sent_messages];
                    [punchDetailsController reset_sent_messages];
                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[savedPunch]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[savedPunch]);
                    [updatePunchDeferred resolveWithValue:timeLinePunchesSummary];
                });
                
                it(@"should not ask the punchDetailsController to update with punch correctly", ^{
                    punchDetailsController should_not have_received(@selector(updateWithPunch:)).with(savedPunch);
                });
                
                it(@"should ask the punchRepository to recalculate script data", ^{
                    NSDictionary *dateDict = [Util convertDateToApiDateDictionary:subject.punch.date];
                    punchRepository should have_received(@selector(recalculateScriptDataForuserUri:withDateDict:)).with(@"user-uri",dateDict);
                });
                
                it(@"should inform its delegate that punch has been deleted", ^{
                    punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                });
                
                
                it(@"should pop back one controller in the nav stack", ^{
                    navigationController.topViewController should_not be_same_instance_as(previousController);
                });
                
                it(@"should stop the spinner", ^{
                    spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                context(@"When the timesummary fetch completes", ^{
                    beforeEach(^{
                        [timeSummaryDeferred resolveWithValue:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                
                context(@"When the timesummary fetch fails", ^{
                    beforeEach(^{
                        [timeSummaryDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
                
            });
            
            context(@"when the punch cannot be saved", ^{
                
                context(@"with network available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(YES);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
                context(@"with network not available", ^{
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).again().and_return(NO);
                        [updatePunchDeferred rejectWithError:nil];
                    });
                    
                    it(@"should pop back one controller in the nav stack", ^{
                        navigationController.topViewController should be_same_instance_as(previousController);
                    });
                    
                    
                    
                    it(@"should not have called recalculateScriptDataForuserUri:WithDateDict", ^{
                        punchRepository should_not have_received(@selector(recalculateScriptDataForuserUri:withDateDict:));
                    });
                    
                    it(@"should not inform its delegate that punch has been deleted", ^{
                        punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                    });
                    
                    it(@"should stop the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                    
                    
                });
            });
        });
        
    });

    describe(@"Tapping on Done on toolbar", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            subject.view should_not be_nil;
            [subject.doneButtonOnToolBar tap];
        });
        
        it(@"should hide the datepicker", ^{
            subject.datePicker.hidden should be_truthy;
        });
        
        it(@"should hide the toolbar accompanying the datepicker", ^{
            subject.toolBar.hidden should be_truthy;
        });
        
        it(@"should configure the PunchDetailsViewController", ^{
            punchDetailsController should have_received(@selector(updateWithPunch:)).with(punch);
        });
    });
    
    describe(@"selecting a new date", ^{
        __block NSDate *expectedDate;
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            subject.view should_not be_nil;
            expectedDate = [NSDate dateWithTimeIntervalSince1970:1432745892];
            [subject.datePicker setDate:expectedDate];
            [subject.datePicker sendActionsForControlEvents:UIControlEventValueChanged];
        });
        
        it(@"should update the date from the datePicker on the table view cell for date", ^{
            id <Punch> expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                             nonActionedValidations:0
                                                                previousPunchStatus:Ticking
                                                                    nextPunchStatus:Ticking
                                                                      sourceOfPunch:UnknownSourceOfPunch
                                                                         actionType:PunchActionTypePunchOut
                                                                      oefTypesArray:nil
                                                                       lastSyncTime:NULL
                                                                            project:NULL
                                                                        auditHstory:nil
                                                                          breakType:breakType
                                                                           location:location
                                                                         violations:nil
                                                                          requestID:@"ABCD123"
                                                                           activity:NULL
                                                                           duration:nil
                                                                             client:NULL
                                                                            address:@"My Special Address"
                                                                            userURI:userURI
                                                                           imageURL:imageURL
                                                                               date:expectedDate
                                                                               task:NULL
                                                                                uri:@"my-special-uri"
                                                               isTimeEntryAvailable:NO
                                                                   syncedWithServer:NO
                                                                     isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchDetailsController should have_received(@selector(updateWithPunch:)).with(expectedPunch);
            
        });
    });
    
    describe(@"when the user wants to change the break type", ^{
        __block KSDeferred *breakTypeDeferred;
        
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            [subject view];
            breakTypeDeferred = [KSDeferred defer];
            breakTypeRepository stub_method(@selector(fetchBreakTypesForUser:)).with(nil).and_return(breakTypeDeferred.promise);
            [subject punchDetailsControllerWantsToChangeBreakType:nil];
        });
        
        it(@"should fetch break types", ^{
            breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(nil);
        });

        it(@"should disable view user interaction", ^{
           subject.view.userInteractionEnabled should be_falsy;
        });

        describe(@"when the break types are fetched", ^{
            __block BreakType *breakType1;
            __block BreakType *breakType2;
            
            beforeEach(^{
                breakType1 = [[BreakType alloc] initWithName:@"Break Type 1" uri:@"break-type-1"];
                breakType2 = [[BreakType alloc] initWithName:@"Break Type 2" uri:@"break-type-2"];
                
                NSArray *breakTypes = @[breakType1, breakType2];
                
                [breakTypeDeferred resolveWithValue:breakTypes];
            });
            
            it(@"should display an action sheet with break types", ^{
                NSArray *expectedButtonTitles = @[@"Break Type 1", @"Break Type 2", RPLocalizedString(@"Cancel", nil)];
                
                UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                actionSheet.buttonTitles should equal(expectedButtonTitles);
            });

            it(@"should enable view user interaction", ^{
                subject.view.userInteractionEnabled should be_truthy;
            });
            
            context(@"when the user picks a break type", ^{
                __block id <Punch> expectedPunch;
                beforeEach(^{
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Ticking
                                                                 nextPunchStatus:Ticking
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:nil
                                                                    lastSyncTime:NULL
                                                                         project:NULL
                                                                     auditHstory:nil
                                                                       breakType:breakType2
                                                                        location:location
                                                                      violations:nil
                                                                       requestID:@"ABCD123"
                                                                        activity:NULL
                                                                        duration:nil
                                                                          client:NULL
                                                                         address:@"My Special Address"
                                                                         userURI:userURI
                                                                        imageURL:imageURL
                                                                            date:punchDate
                                                                            task:NULL
                                                                             uri:@"my-special-uri"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    [punchDetailsController reset_sent_messages];
                    UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                    [actionSheet dismissByClickingButtonWithTitle:@"Break Type 2"];
                });
                
                it(@"should update punch details when the user picks a new break type", ^{
                    punchDetailsController should have_received(@selector(updateWithPunch:))
                    .with(expectedPunch);
                });
            });
            
            it(@"should not update punch details when the user cancels the action sheet", ^{
                [punchDetailsController reset_sent_messages];
                
                UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                [actionSheet dismissByClickingCancelButton];
                
                punchDetailsController should_not have_received(@selector(updateWithPunch:));
            });
        });

        describe(@"when fetching break types failed", ^{

            beforeEach(^{

                [breakTypeDeferred rejectWithError:nil];
            });

            it(@"should enable view user interaction", ^{
                subject.view.userInteractionEnabled should be_truthy;
            });

        });
    });

    describe(@"when the user wants to change date first and then the break type", ^{
        __block KSDeferred *breakTypeDeferred;
        __block NSDate *expectedDate;

        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                    punch:punch
                                                 flowType:UserFlowContext
                                                  userUri:nil];
            [subject view];
            expectedDate = [NSDate dateWithTimeIntervalSince1970:1432745892];
            [subject.datePicker setDate:expectedDate];
            [subject.datePicker sendActionsForControlEvents:UIControlEventValueChanged];

            breakTypeDeferred = [KSDeferred defer];
            breakTypeRepository stub_method(@selector(fetchBreakTypesForUser:)).with(nil).and_return(breakTypeDeferred.promise);
            [subject punchDetailsControllerWantsToChangeBreakType:nil];
        });
        
        it(@"should fetch break types", ^{
            breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(nil);
        });
        
        describe(@"when the break types are fetched", ^{
            __block BreakType *breakType1;
            __block BreakType *breakType2;
            
            beforeEach(^{
                breakType1 = [[BreakType alloc] initWithName:@"Break Type 1" uri:@"break-type-1"];
                breakType2 = [[BreakType alloc] initWithName:@"Break Type 2" uri:@"break-type-2"];
                
                NSArray *breakTypes = @[breakType1, breakType2];
                
                [breakTypeDeferred resolveWithValue:breakTypes];
            });
            
            it(@"should display an action sheet with break types", ^{
                NSArray *expectedButtonTitles = @[@"Break Type 1", @"Break Type 2", RPLocalizedString(@"Cancel", nil)];
                
                UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                actionSheet.buttonTitles should equal(expectedButtonTitles);
            });

            context(@"without OEF", ^{
                context(@"when the user picks a break type", ^{
                    __block id <Punch> expectedPunch;
                    beforeEach(^{
                        expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypePunchOut
                                                                       oefTypesArray:nil
                                                                        lastSyncTime:NULL
                                                                             project:NULL
                                                                         auditHstory:nil
                                                                           breakType:breakType2
                                                                            location:location
                                                                          violations:nil
                                                                           requestID:@"ABCD123"
                                                                            activity:NULL
                                                                            duration:nil
                                                                              client:NULL
                                                                             address:@"My Special Address"
                                                                             userURI:userURI
                                                                            imageURL:imageURL
                                                                                date:expectedDate
                                                                                task:NULL
                                                                                 uri:@"my-special-uri"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                        [punchDetailsController reset_sent_messages];
                        UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                        [actionSheet dismissByClickingButtonWithTitle:@"Break Type 2"];
                    });

                    it(@"should update punch details when the user picks a new break type", ^{
                        punchDetailsController should have_received(@selector(updateWithPunch:))
                        .with(expectedPunch);
                    });
                });
            });
            context(@"with OEF", ^{
                context(@"when the user picks a break type", ^{
                    __block id <Punch> expectedPunch;
                    beforeEach(^{
                        OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                        OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                        OEFType *oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:NO];
                        NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                        RemotePunch *originalLocalPunch = nice_fake_for([RemotePunch class]);
                        originalLocalPunch stub_method(@selector(punchSyncStatus)).and_return(RemotePunchStatus);
                        //originalLocalPunch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                        originalLocalPunch stub_method(@selector(lastSyncTime)).and_return(nil);
                        originalLocalPunch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                        originalLocalPunch stub_method(@selector(project)).and_return(nil);
                        originalLocalPunch stub_method(@selector(breakType)).and_return(breakType);
                        originalLocalPunch stub_method(@selector(location)).and_return(location);
                        originalLocalPunch stub_method(@selector(requestID)).and_return(@"ABCD123");
                        originalLocalPunch stub_method(@selector(activity)).and_return(nil);
                        originalLocalPunch stub_method(@selector(client)).and_return(nil);
                        originalLocalPunch stub_method(@selector(address)).and_return(@"My Special Address");
                        originalLocalPunch stub_method(@selector(userURI)).and_return(userURI);
                        originalLocalPunch stub_method(@selector(imageURL)).and_return(imageURL);
                        originalLocalPunch stub_method(@selector(task)).and_return(nil);
                        originalLocalPunch stub_method(@selector(date)).and_return(punchDate);
                        originalLocalPunch stub_method(@selector(uri)).and_return(@"my-special-uri");
                        originalLocalPunch stub_method(@selector(sourceOfPunch)).and_return(UnknownSourceOfPunch);
                        originalLocalPunch stub_method(@selector(previousPunchActionType)).and_return(PunchActionTypeUnknown);
                        originalLocalPunch stub_method(@selector(previousPunchPairStatus)).and_return(Ticking);
                        originalLocalPunch stub_method(@selector(nextPunchPairStatus)).and_return(Ticking);

                        [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                punch:originalLocalPunch
                                                             flowType:UserFlowContext
                                                              userUri:userURI];
                        expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypeStartBreak
                                                                       oefTypesArray:nil
                                                                        lastSyncTime:nil
                                                                             project:nil
                                                                         auditHstory:nil
                                                                           breakType:breakType2
                                                                            location:location
                                                                          violations:nil
                                                                           requestID:@"ABCD123"
                                                                            activity:nil
                                                                            duration:nil
                                                                              client:nil
                                                                             address:@"My Special Address"
                                                                             userURI:userURI
                                                                            imageURL:imageURL
                                                                                date:[NSDate dateWithTimeIntervalSince1970:0]
                                                                                task:nil
                                                                                 uri:@"my-special-uri"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                        [punchDetailsController reset_sent_messages];
                        UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                        [actionSheet dismissByClickingButtonWithTitle:@"Break Type 2"];
                    });

                    it(@"should update punch details when the user picks a new break type", ^{
                        punchDetailsController should have_received(@selector(updateWithPunch:))
                        .with(expectedPunch);
                    });
                });
            });



            it(@"should not update punch details when the user cancels the action sheet", ^{
                [punchDetailsController reset_sent_messages];

                UIActionSheet *actionSheet = [UIActionSheet currentActionSheet];
                [actionSheet dismissByClickingCancelButton];
                
                punchDetailsController should_not have_received(@selector(updateWithPunch:));
            });
        });
    });

    describe(@"scrollview property", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should add scroll view as the subview of the view", ^{
            [[subject.view subviews] count] should equal(3);
            [[subject.view subviews] firstObject] should be_same_instance_as(subject.scrollView);
        });

        it(@"scrollview should dismiss keyboard on drag", ^{
            subject.scrollView.keyboardDismissMode should equal(UIScrollViewKeyboardDismissModeOnDrag);
        });

    });

    describe(@"ViewWillAppear", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:YES];
        });
        it(@"should register for keyboardWillShow, keyboardWillHide", ^{
            notificationCenter should have_received(@selector(addObserver:selector:name:object:));

            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillHide:), UIKeyboardWillHideNotification, nil);

        });
        it(@"should layout the scrollview height correctly when keyboard appears", ^{
            CGRect rect = CGRectMake(0, 100, 200, 200);
            NSValue *rectValue = [NSValue valueWithCGRect:rect];

            NSDictionary *userInfo =  @{@"UIKeyboardFrameEndUserInfoKey":rectValue};

            [notificationCenter postNotificationName:UIKeyboardWillShowNotification object:nil userInfo:userInfo];
            subject.scrollView.frame.size.height should equal((subject.view.frame.size.height - 200.0) + 48.0);
        });

    });

    describe(@"ViewWillDisappear", ^{
        beforeEach(^{
            [subject viewWillDisappear:YES];
        });
        it(@"should remove  keyboardWillShow, keyboardWillHide notifications", ^{
            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject,UIKeyboardWillShowNotification, nil);

            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject,UIKeyboardWillHideNotification, nil);
            
        });
        
    });
    
    
    describe(@"When User is Punch into Project User and Validation fails", ^{
        __block UIAlertView *alertView;
        __block ProjectType *project_;
        
        context(@"And in Userflow context", ^{
            
            context(@"When clocking in and Project is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypePunchIn
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:nil];
                    
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidProjectSelectedError);
                });
                
            });
            
            context(@"When Punch is transferred and Project is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypeTransfer
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:nil];
                    
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidProjectSelectedError);
                });
                
            });
            
            context(@"When clocking in and Task is not selected", ^{
                beforeEach(^{
                    
                    project_ = nice_fake_for([ProjectType class]);
                    project_ stub_method(@selector(name)).and_return(@"some:project");
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypePunchIn
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:project_
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:nil];
                    
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidTaskSelectedError);
                });
                
            });
            
            context(@"When Punch is transferred and Task is not selected", ^{
                beforeEach(^{
                    
                    project_ = nice_fake_for([ProjectType class]);
                    project_ stub_method(@selector(name)).and_return(@"some:project");
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypeTransfer
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:project_
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:nil];
                    
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidTaskSelectedError);
                });
                
            });
            
        });
        
        context(@"And in Supervisor Flow context", ^{
            
            context(@"When clocking in and Project is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypePunchIn
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:SupervisorFlowContext
                                                          userUri:@"my-different-special-user-uri"];
                    
                    reporteePermission stub_method(@selector(canAccessProjectUserWithUri:)).and_return(YES);
                    reporteePermission stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidProjectSelectedError);
                });
                
            });
            
            context(@"When Punch is transferred and Project is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypeTransfer
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:SupervisorFlowContext
                                                          userUri:@"my-different-special-user-uri"];
                    
                    reporteePermission stub_method(@selector(canAccessProjectUserWithUri:)).and_return(YES);
                    reporteePermission stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidProjectSelectedError);
                });
                
            });
            
            context(@"When clocking in and Task is not selected", ^{
                beforeEach(^{
                    
                    project_ = nice_fake_for([ProjectType class]);
                    project_ stub_method(@selector(name)).and_return(@"some:project");
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypePunchIn
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:project_
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:@"my-different-special-user-uri"];
                    
                    reporteePermission stub_method(@selector(canAccessProjectUserWithUri:)).and_return(YES);
                    reporteePermission stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidTaskSelectedError);
                });
                
            });
            
            context(@"When Punch is transferred and Task is not selected", ^{
                beforeEach(^{
                    
                    project_ = nice_fake_for([ProjectType class]);
                    project_ stub_method(@selector(name)).and_return(@"some:project");
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypeTransfer
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:project_
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:@"my-different-special-user-uri"];
                    
                    reporteePermission stub_method(@selector(canAccessProjectUserWithUri:)).and_return(YES);
                    reporteePermission stub_method(@selector(isReporteeProjectTaskSelectionRequired:)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidTaskSelectedError);
                });
                
            });
            
        });
        
        
    });
    
    describe(@"When User is Punch into Activities User and Validation fails", ^{
        __block UIAlertView *alertView;
        
        context(@"And in Userflow context", ^{
            
            context(@"When clocking in and Activity is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypePunchIn
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:nil];
                    
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidActivitySelectedError);
                });
                
            });
            
            context(@"When Punch is transferred and Activity is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypeTransfer
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:UserFlowContext
                                                          userUri:nil];
                    
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidActivitySelectedError);
                });
                
            });
            
        });
        
        context(@"And in Supervisor Flow context", ^{
            
            context(@"When clocking in and Project is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypePunchIn
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:SupervisorFlowContext
                                                          userUri:@"my-different-special-user-uri"];
                    
                    reporteePermission stub_method(@selector(canAccessActivityUserWithUri:)).and_return(YES);
                    reporteePermission stub_method(@selector(canAccessProjectUserWithUri:)).and_return(NO);
                    reporteePermission stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidActivitySelectedError);
                });
                
            });
            
            context(@"When Punch is transferred and Project is not selected", ^{
                beforeEach(^{
                    
                    RemotePunch *punch_ = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                nonActionedValidations:0
                                                                   previousPunchStatus:Ticking
                                                                       nextPunchStatus:Ticking
                                                                         sourceOfPunch:UnknownSourceOfPunch
                                                                            actionType:PunchActionTypeTransfer
                                                                         oefTypesArray:nil
                                                                          lastSyncTime:nil
                                                                               project:nil
                                                                           auditHstory:nil
                                                                             breakType:nil
                                                                              location:nil
                                                                            violations:nil
                                                                             requestID:nil
                                                                              activity:nil
                                                                              duration:nil
                                                                                client:nil
                                                                               address:nil
                                                                               userURI:@"my-sepcial-user-uri"
                                                                              imageURL:nil
                                                                                  date:nil
                                                                                  task:nil
                                                                                   uri:nil
                                                                  isTimeEntryAvailable:NO
                                                                      syncedWithServer:NO
                                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                            punch:punch_
                                                         flowType:SupervisorFlowContext
                                                          userUri:@"my-different-special-user-uri"];
                    
                    reporteePermission stub_method(@selector(canAccessActivityUserWithUri:)).and_return(YES);
                    reporteePermission stub_method(@selector(canAccessProjectUserWithUri:)).and_return(NO);
                    reporteePermission stub_method(@selector(isReporteeActivitySelectionRequired:)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);
                    
                    subject.view should_not be_nil;
                    
                    [subject.navigationItem.rightBarButtonItem tap];
                    alertView = [UIAlertView currentAlertView];
                });
                
                it(@"should have the alertview for no Project ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(InvalidActivitySelectedError);
                });
                
            });
            
        });
        
        
    });
    
});

SPEC_END
