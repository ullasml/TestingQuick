#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import <KSDeferred/KSPromise.h>
#import "ProjectPunchInController.h"
#import "Theme.h"
#import "DayTimeSummaryController.h"
#import "TimesheetButtonController.h"
#import "TimesheetButtonControllerPresenter.h"
#import "InjectorProvider.h"
#import "ChildControllerHelper.h"
#import "DayTimeSummaryControllerProvider.h"

#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "InjectorKeys.h"
#import "ViolationEmployee.h"
#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "UIControl+Spec.h"
#import "DateProvider.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "WorkHoursStorage.h"
#import "PunchCardObject.h"
#import "OEFTypeStorage.h"
#import "PunchCardStorage.h"
#import "UserPermissionsStorage.h"
#import "TimeLinePunchesSummary.h"
#import <KSDeferred/KSDeferred.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ProjectPunchInControllerSpec)

describe(@"ProjectPunchInController", ^{
    __block ProjectPunchInController *subject;
    __block id<ProjectPunchInControllerDelegate> delegate;
    __block DayTimeSummaryController *dayTimeSummaryController;

    __block DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
    __block DateProvider *dateProvider;
    __block ChildControllerHelper *childControllerHelper;
    __block ViolationRepository *violationRepository;
    __block KSPromise *serverDidFinishPunchPromise;
    __block KSPromise *punchesWithServerDidFinishPunchPromise;
    __block KSDeferred *punchesWithServerDidFinishPunchDeferred;

    __block id<Theme> theme;
    __block id<UserSession> userSession;
    __block id<BSBinder, BSInjector> injector;
    __block WidgetTimesheetDetailsSeriesController *newTimesheetDetailsSeriesController;
    __block TimesheetButtonController *timesheetButtonController;
    __block TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
    __block TimesheetDetailsSeriesController *timesheetDetailsSeriesController;
    __block WorkHoursStorage *workHoursStorage;
    __block id <WorkHours> placeHolderWorkHours;
    __block NSNotificationCenter *notificationCenter;
    __block OEFTypeStorage *oefypeStorage;
    __block PunchCardController *punchCardController;
    __block PunchCardStorage *punchCardStorage;
    __block NSArray *oefTypesArray;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block NSUserDefaults *userDefaults;

    beforeEach(^{
        placeHolderWorkHours = nice_fake_for(@protocol(WorkHours));
        workHoursStorage = nice_fake_for([WorkHoursStorage class]);
        workHoursStorage stub_method(@selector(getCombinedWorkHoursSummary)).and_return(placeHolderWorkHours);
        timesheetButtonController = nice_fake_for([TimesheetButtonController class]);
        timesheetButtonControllerPresenter = nice_fake_for([TimesheetButtonControllerPresenter class]);
        timesheetButtonControllerPresenter stub_method(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:));

        timesheetDetailsSeriesController = (id)[[UIViewController alloc] init];

        oefypeStorage = nice_fake_for([OEFTypeStorage class]);

        OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

        OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
        OEFType *oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
        oefTypesArray = [NSArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
        oefypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).and_return(oefTypesArray);
    });
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        userDefaults stub_method(@selector(objectForKey:))
        .with(@"totalViolationMessagesCount")
        .and_return(@1);

        dayTimeSummaryController = (id)[[UIViewController alloc] init];
        
        
        dateProvider = nice_fake_for([DateProvider class]);
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        violationRepository = nice_fake_for([ViolationRepository class]);
        dayTimeSummaryControllerProvider = nice_fake_for([DayTimeSummaryControllerProvider class]);
        serverDidFinishPunchPromise = nice_fake_for([KSPromise class]);
        
        punchesWithServerDidFinishPunchDeferred = [KSDeferred defer];
        punchesWithServerDidFinishPunchPromise = [punchesWithServerDidFinishPunchDeferred promise];
        
        delegate = nice_fake_for(@protocol(ProjectPunchInControllerDelegate));
        theme = nice_fake_for(@protocol(Theme));
        punchCardController = nice_fake_for([PunchCardController class]);

        punchCardStorage = nice_fake_for([PunchCardStorage class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        newTimesheetDetailsSeriesController = (id)[[UIViewController alloc] init];
        
        [injector bind:[TimesheetButtonControllerPresenter class] toInstance:timesheetButtonControllerPresenter];
        [injector bind:[TimesheetDetailsSeriesController class] toInstance:timesheetDetailsSeriesController];
        [injector bind:[WidgetTimesheetDetailsSeriesController class] toInstance:newTimesheetDetailsSeriesController];
        [injector bind:[DayTimeSummaryControllerProvider class] toInstance:dayTimeSummaryControllerProvider];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:[ViolationRepository class] toInstance:violationRepository];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[DateProvider class] toInstance:dateProvider];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[WorkHoursStorage class] toInstance:workHoursStorage];
        [injector bind:[OEFTypeStorage class] toInstance:oefypeStorage];
        [injector bind:[PunchCardController class] toInstance:punchCardController];
        [injector bind:[PunchCardStorage class] toInstance:punchCardStorage];
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];



        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        spy_on(notificationCenter);
        
        
        subject = [injector getInstance:[ProjectPunchInController class]];
        [subject setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                             delegate:delegate
                                      punchCardObject:nil
                                       punchesPromise:punchesWithServerDidFinishPunchPromise];

    });

    describe(@"Presenting PunchCardController", ^{

        context(@"when punch card object is already selected", ^{
            __block PunchCardObject *expectedPunchCard;
            beforeEach(^{

                PunchCardObject *punchCardA = nice_fake_for([PunchCardObject class]);
                PunchCardObject *punchCardB = nice_fake_for([PunchCardObject class]);
                punchCardStorage stub_method(@selector(getPunchCards)).and_return(@[punchCardA,punchCardB]);
                
                ClientType *client = [[ClientType alloc] initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                            isTimeAllocationAllowed:NO
                                                                                      projectPeriod:nil
                                                                                         clientType:client
                                                                                               name:nil
                                                                                                uri:nil];
                expectedPunchCard = [[PunchCardObject alloc] initWithClientType:client
                                                                    projectType:project
                                                                  oefTypesArray:nil
                                                                      breakType:nil
                                                                       taskType:nil
                                                                       activity:nil
                                                                            uri:nil];
                
                [subject setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                                     delegate:delegate
                                              punchCardObject:expectedPunchCard
                                               punchesPromise:punchesWithServerDidFinishPunchPromise];
                subject.view should_not be_nil;

            });

            it(@"should correct set up and present PunchCardController", ^{

                punchCardController should have_received(@selector(setUpWithPunchCardObject:punchCardType:delegate:oefTypesArray:)).with(expectedPunchCard,FilledClientProjectTaskPunchCard,subject,oefTypesArray);

                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(punchCardController,subject,subject.cardContainerView);
            });
        });

        context(@"when punch card object is not selected, should use the default punch card", ^{

            __block PunchCardObject *punchCardA = nice_fake_for([PunchCardObject class]);
            __block PunchCardObject *punchCardB = nice_fake_for([PunchCardObject class]);
            beforeEach(^{

                punchCardA stub_method(@selector(isValidPunchCard)).and_return(YES);
                punchCardB stub_method(@selector(isValidPunchCard)).and_return(YES);

                punchCardStorage stub_method(@selector(getPunchCards)).and_return(@[punchCardA,punchCardB]);
                [subject setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                                     delegate:delegate
                                              punchCardObject:nil
                                               punchesPromise:punchesWithServerDidFinishPunchPromise];
                subject.view should_not be_nil;

            });

            it(@"should correct set up and present PunchCardController", ^{

                punchCardController should have_received(@selector(setUpWithPunchCardObject:punchCardType:delegate:oefTypesArray:)).with(punchCardA,FilledClientProjectTaskPunchCard,subject,oefTypesArray);

                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(punchCardController,subject,subject.cardContainerView);
            });
        });

        context(@"When Punch card is invalid, should use the default punchcard", ^{
            __block PunchCardObject *punchCardA;
            __block PunchCardObject *punchCardB;

            beforeEach(^{
                punchCardA = nice_fake_for([PunchCardObject class]);
                punchCardB = nice_fake_for([PunchCardObject class]);

                punchCardA stub_method(@selector(isValidPunchCard)).and_return(NO);
                punchCardB stub_method(@selector(isValidPunchCard)).and_return(YES);

                punchCardStorage stub_method(@selector(getPunchCards)).and_return(@[punchCardA,punchCardB]);

                [subject setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                                     delegate:delegate
                                              punchCardObject:nil
                                               punchesPromise:punchesWithServerDidFinishPunchPromise];

                subject.view should_not be_nil;
            });

            it(@"should correct set up and present PunchCardController", ^{

            PunchCardObject *emptyPunchCard = [[PunchCardObject alloc] initWithClientType:nil projectType:nil oefTypesArray:punchCardA.oefTypesArray breakType:punchCardA.breakType taskType:nil activity:nil uri:punchCardA.uri];

                punchCardController should have_received(@selector(setUpWithPunchCardObject:punchCardType:delegate:oefTypesArray:)).with(emptyPunchCard,FilledClientProjectTaskPunchCard,subject,oefTypesArray);

                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(punchCardController,subject,subject.cardContainerView);
            });
        });

    });
    
    describe(@"As a <PunchCardControllerDelegate>", ^{

        context(@"should tell its delegate the intention to punch with correct punch card", ^{

            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block Activity *activity;
            __block NSMutableArray *oefTypesArray;

            beforeEach(^{
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                client = [[ClientType alloc]initWithName:@"client-name"
                                                     uri:@"client-uri"];


                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:@"project-uri"];

                task = [[TaskType alloc]initWithProjectUri:nil
                                                taskPeriod:nil
                                                      name:@"task-name"
                                                       uri:@"task-uri"];

                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];

                OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                cardObject = [[PunchCardObject alloc]
                                               initWithClientType:client
                                                      projectType:project
                                                    oefTypesArray:oefTypesArray
                                                        breakType:NULL
                                                         taskType:task
                                                         activity:nil
                                                              uri:nil];
                oefypeStorage stub_method(@selector(getUnionOEFArrayFromPunchCardOEF:andPunchActionType:)).with(oefTypesArray,PunchActionTypePunchIn).and_return(oefTypesArray);


            });

            it(@"that the user punched in", ^{
                [subject punchCardController:nil didIntendToPunchWithObject:cardObject];
                delegate should have_received(@selector(projectPunchInController:didIntendToPunchWithObject:)).with(subject,cardObject);

            });

            it(@"scroll the scrollview to textview cursor", ^{
                [subject view];
                UITextView *textView = nice_fake_for([UITextView class]);
                textView.text = @"testing!!!";
                spy_on(subject.scrollView);
                [subject punchCardController:nil didScrolltoSubview:textView];
                subject.scrollView should have_received(@selector(setContentOffset:animated:)).with(CGPointMake(0, 0),NO);
            });
        });

        context(@"should tell its delegate the intention to punch with correct punch card when client,project,task and activity is present for simple punch oef flow", ^{

            __block PunchCardObject *cardObject;
            __block PunchCardObject *expectedCardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block Activity *activity;
            __block NSMutableArray *oefTypesArray;

            beforeEach(^{

                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);


                client = [[ClientType alloc]initWithName:@"client-name"
                                                     uri:@"client-uri"];


                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:@"project-uri"];

                task = [[TaskType alloc]initWithProjectUri:nil
                                                taskPeriod:nil
                                                      name:@"task-name"
                                                       uri:@"task-uri"];

                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];

                OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                cardObject = [[PunchCardObject alloc]
                              initWithClientType:client
                              projectType:project
                              oefTypesArray:oefTypesArray
                              breakType:NULL
                              taskType:task
                              activity:activity
                              uri:nil];
                oefypeStorage stub_method(@selector(getUnionOEFArrayFromPunchCardOEF:andPunchActionType:)).with(oefTypesArray,PunchActionTypePunchIn).and_return(oefTypesArray);

                expectedCardObject = [[PunchCardObject alloc]
                              initWithClientType:nil
                              projectType:nil
                              oefTypesArray:oefTypesArray
                              breakType:NULL
                              taskType:nil
                              activity:nil
                              uri:nil];

            });

            it(@"that the user punched in", ^{
                [subject punchCardController:nil didIntendToPunchWithObject:cardObject];
                delegate should have_received(@selector(projectPunchInController:didIntendToPunchWithObject:)).with(subject,expectedCardObject);

            });

            it(@"scroll the scrollview to textview cursor", ^{
                [subject view];
                UITextView *textView = nice_fake_for([UITextView class]);
                textView.text = @"testing!!!";
                spy_on(subject.scrollView);
                [subject punchCardController:nil didScrolltoSubview:textView];
                subject.scrollView should have_received(@selector(setContentOffset:animated:)).with(CGPointMake(0, 0),NO);
            });
        });
        
        context(@"should tell its delegate the intention to punch with correct punch card when Client uri is null behaviour uri and type is Any client", ^{
            
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block Activity *activity;
            __block NSMutableArray *oefTypesArray;
            
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                
                client = [[ClientType alloc]initWithName:ClientTypeAnyClient
                                                     uri:ClientTypeAnyClientUri];
                
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:@"project-uri"];
                
                task = [[TaskType alloc]initWithProjectUri:nil
                                                taskPeriod:nil
                                                      name:@"task-name"
                                                       uri:@"task-uri"];
                
                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                
                OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                cardObject = [[PunchCardObject alloc]
                              initWithClientType:nil
                              projectType:project
                              oefTypesArray:oefTypesArray
                              breakType:NULL
                              taskType:task
                              activity:nil
                              uri:nil];
                oefypeStorage stub_method(@selector(getUnionOEFArrayFromPunchCardOEF:andPunchActionType:)).with(oefTypesArray,PunchActionTypePunchIn).and_return(oefTypesArray);
                
                
            });
            
            it(@"that the user punched in", ^{
                [subject punchCardController:nil didIntendToPunchWithObject:cardObject];
                delegate should have_received(@selector(projectPunchInController:didIntendToPunchWithObject:)).with(subject,cardObject);
                
            });
            
            it(@"scroll the scrollview to textview cursor", ^{
                [subject view];
                UITextView *textView = nice_fake_for([UITextView class]);
                textView.text = @"testing!!!";
                spy_on(subject.scrollView);
                [subject punchCardController:nil didScrolltoSubview:textView];
                subject.scrollView should have_received(@selector(setContentOffset:animated:)).with(CGPointMake(0, 0),NO);
            });
        });
        
        context(@"should tell its delegate the intention to punch with correct punch card when Client uri is null behaviour uri and type is Any client", ^{
            
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block Activity *activity;
            __block NSMutableArray *oefTypesArray;
            
            beforeEach(^{
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                
                client = [[ClientType alloc]initWithName:ClientTypeNoClient
                                                     uri:ClientTypeNoClientUri];
                
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:@"project-uri"];
                
                task = [[TaskType alloc]initWithProjectUri:nil
                                                taskPeriod:nil
                                                      name:@"task-name"
                                                       uri:@"task-uri"];
                
                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                
                OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                cardObject = [[PunchCardObject alloc]
                              initWithClientType:nil
                              projectType:project
                              oefTypesArray:oefTypesArray
                              breakType:NULL
                              taskType:task
                              activity:nil
                              uri:nil];
                oefypeStorage stub_method(@selector(getUnionOEFArrayFromPunchCardOEF:andPunchActionType:)).with(oefTypesArray,PunchActionTypePunchIn).and_return(oefTypesArray);
                
                
            });
            
            it(@"that the user punched in", ^{
                [subject punchCardController:nil didIntendToPunchWithObject:cardObject];
                delegate should have_received(@selector(projectPunchInController:didIntendToPunchWithObject:)).with(subject,cardObject);
                
            });
            
            it(@"scroll the scrollview to textview cursor", ^{
                [subject view];
                UITextView *textView = nice_fake_for([UITextView class]);
                textView.text = @"testing!!!";
                spy_on(subject.scrollView);
                [subject punchCardController:nil didScrolltoSubview:textView];
                subject.scrollView should have_received(@selector(setContentOffset:animated:)).with(CGPointMake(0, 0),NO);
            });
        });

        it(@"should tell its delegate to update the punch card height", ^{
            [subject view];
            [subject punchCardController:nil didUpdateHeight:160];
            subject.punchCardHeightConstraint.constant should equal((CGFloat)160);
        });

        context(@"should tell its delegate to update with the punch card object", ^{

            __block PunchCardObject *expectedPunchCardObject;
            beforeEach(^{
                expectedPunchCardObject = nice_fake_for([PunchCardObject class]);
                [subject view];
                [subject punchCardController:nil didUpdatePunchCardWithObject:expectedPunchCardObject];
            });

            it(@"should correctly update with punch card", ^{
                delegate should have_received(@selector(projectPunchInController:didUpdatePunchCardWithObject:)).with(subject,expectedPunchCardObject);
            });
        });


    });
    
    
    describe(@"presenting violations button controller", ^{
        __block ViolationsButtonController *violationsButtonController;
        
        beforeEach(^{
            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor magentaColor]);
            violationsButtonController = [[ViolationsButtonController alloc] initWithButtonStylist:nil
                                                                                             theme:nil];
            spy_on(violationsButtonController);
            [injector bind:[ViolationsButtonController class] toInstance:violationsButtonController];
            [subject view];
        });
        
        it(@"should setup controller", ^{
            violationsButtonController should have_received(@selector(setupWithDelegate:showViolations:))
            .with(subject, true);
        });
        
        it(@"should present violations button controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(violationsButtonController, subject, subject.violationsButtonContainerView);
        });
        
        it(@"should style the background appropriately", ^{
            subject.violationsButtonContainerView.backgroundColor should equal([UIColor magentaColor]);
        });
        
        it(@"should make itself the ViolationsButtonController's delegate", ^{
            violationsButtonController.delegate should be_same_instance_as(subject);
        });
    });
    
    describe(@"presenting the work hours summary for the current day", ^{
        __block UIViewController *dayTimeSummaryController;
        beforeEach(^{
            dayTimeSummaryController = [[UIViewController alloc] init];
            dayTimeSummaryControllerProvider stub_method(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:)).with(serverDidFinishPunchPromise,placeHolderWorkHours,subject).and_return(dayTimeSummaryController);
            [subject view];
        });
        
        it(@"should get the placeholder work hours intially when the view loads", ^{
            workHoursStorage should have_received(@selector(getCombinedWorkHoursSummary));
        });
        
        it(@"should present a work hours summary controller", ^{
            dayTimeSummaryControllerProvider should have_received(@selector(provideInstanceWithPromise:placeholderWorkHours:delegate:))
            .with(serverDidFinishPunchPromise,placeHolderWorkHours,subject);
        });
        
        it(@"should present a work hours summary controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
        });
    });
    
    describe(@"presenting the time line for the current day", ^{
        
        context(@"When punchPromise is succeed", ^{
            __block TimesheetDayTimeLineController *timeLineController;
            __block RemotePunch *remotePunchA;
            __block RemotePunch *remotePunchB;
            __block NSDate *expectedDate;
            beforeEach(^{
                remotePunchA = nice_fake_for([RemotePunch class]);
                remotePunchB = nice_fake_for([RemotePunch class]);
                
                TimeLinePunchesSummary * timelTimeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:nil timeLinePunches:@[remotePunchA, remotePunchB] allPunches:nil];
                
                [punchesWithServerDidFinishPunchDeferred resolveWithValue:timelTimeLinePunchesSummary];
                
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];
                
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(nil,serverDidFinishPunchPromise, subject, @"user-uri",UserFlowContext,@[remotePunchA, remotePunchB],CardTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineCardContainerView);
            });
        });
        
        context(@"When punchPromise rejected", ^{
            __block TimesheetDayTimeLineController *timeLineController;
            __block NSDate *expectedDate;
            beforeEach(^{
                
                [punchesWithServerDidFinishPunchDeferred rejectWithError:nil];
                
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];
                
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(nil,serverDidFinishPunchPromise, subject, @"user-uri",UserFlowContext,nil,CardTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineCardContainerView);
            });
        });
        
        context(@"When punchPromise is nil", ^{
            __block TimesheetDayTimeLineController *timeLineController;
            __block NSDate *expectedDate;
            beforeEach(^{
                
                [punchesWithServerDidFinishPunchDeferred rejectWithError:nil];
                
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                timeLineController = nice_fake_for([TimesheetDayTimeLineController class]);
                [injector bind:[TimesheetDayTimeLineController class] toInstance:timeLineController];
                
                [subject view];
            });
            
            it(@"should set up the timeline controller correctly", ^{
                timeLineController should have_received(@selector(setupWithPunchChangeObserverDelegate:serverDidFinishPunchPromise:delegate:userURI:flowType:punches:timeLinePunchFlow:))
                .with(nil,serverDidFinishPunchPromise, subject, @"user-uri",UserFlowContext,nil,CardTimeLinePunchFlowContext);
            });
            
            it(@"should use the child controller helper to present the timeline controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timeLineController, subject, subject.timeLineCardContainerView);
            });
        });
    });

    describe(@"presenting the current timesheet period button controller", ^{
        beforeEach(^{
            [subject view];
        });
        
        it(@"should present the current timesheet period button controller", ^{
            timesheetButtonControllerPresenter should have_received(@selector(presentTimesheetButtonControllerInContainer:onParentController:delegate:))
            .with(subject.timesheetButtonContainerView, subject, subject);
        });
    });
    
    describe(@"as a <TimeLineControllerDelegate>", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        describe(@"timeLineController:didUpdateHeight:", ^{
            beforeEach(^{
                [subject timesheetDayTimeLineController:(id)[NSNull null] didUpdateHeight:123.0f];
            });
            
            it(@"should set the timeline container view's height constant", ^{
                subject.timeLineHeightConstraint.constant should equal((CGFloat)123.0f);
            });
        });
        
        describe(@"timeLineControllerDidRequestDate:", ^{
            __block NSDate *returnedDate;
            __block NSDate *expectedDate;
            beforeEach(^{
                expectedDate = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(expectedDate);
                returnedDate = [subject timesheetDayTimeLineControllerDidRequestDate:(id)[NSNull null]];
            });
            
            it(@"should return the correct date", ^{
                returnedDate should be_same_instance_as(expectedDate);
            });
        });
    });
    
    describe(@"as a <ViolationsButtonControllerDelegate>", ^{
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
            __block ViolationsSummaryController *expectedViolationsSummaryController;
            
            beforeEach(^{
                [subject view];
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                
                expectedViolationsSummaryController = [[ViolationsSummaryController alloc] initWithSupervisorDashboardSummaryRepository:nil
                                                                                                        violationSectionHeaderPresenter:nil
                                                                                                          selectedWaiverOptionPresenter:nil
                                                                                                             violationSeverityPresenter:nil
                                                                                                                       teamTableStylist:nil
                                                                                                                        spinnerDelegate:nil
                                                                                                                                  theme:nil];
                
                [injector bind:[ViolationsSummaryController class] toInstance:expectedViolationsSummaryController];
                
                expectedAllViolationSections = fake_for([AllViolationSections class]);
                
                [subject violationsButtonController:nil didSignalIntentToViewViolationSections:expectedAllViolationSections];
                
                violationsSummaryController = (id)navigationController.topViewController;
            });
            
            it(@"should push a violations summary controller onto the navigation stack", ^{
                violationsSummaryController should be_same_instance_as(expectedViolationsSummaryController);
            });
            
            it(@"should set the violations controller up correctly", ^{
                violationsSummaryController.violationSectionsPromise.value should be_same_instance_as(expectedAllViolationSections);
            });
            
            it(@"should set the violations controller up correctly", ^{
                violationsSummaryController.delegate should be_same_instance_as(subject);
            });
        });
        
        describe(@"violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSPromise *expectedViolationsPromise;
            beforeEach(^{
                [subject view];
                
                expectedViolationsPromise = nice_fake_for([KSPromise class]);
                violationRepository stub_method(@selector(fetchAllViolationSectionsForToday))
                .and_return(expectedViolationsPromise);
                
                violationsPromise = [subject violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:nil];
            });
            
            it(@"should make a request for todays violations", ^{
                violationsPromise should be_same_instance_as(expectedViolationsPromise);
            });
        });
    });
    
    describe(@"as a <ViolationsSummaryControllerDelegate>", ^{
        describe(@"violationsSummaryControllerDidRequestViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSPromise *expectedViolationSectionsPromise;
            beforeEach(^{
                [subject view];
                
                expectedViolationSectionsPromise = nice_fake_for([KSPromise class]);
                violationRepository stub_method(@selector(fetchAllViolationSectionsForToday))
                .and_return(expectedViolationSectionsPromise);
                
                violationsPromise = [subject violationsSummaryControllerDidRequestViolationSectionsPromise:nil];
            });
            
            it(@"should make a request for todays violations", ^{
                violationsPromise should be_same_instance_as(expectedViolationSectionsPromise);
            });
        });
    });
    
    describe(@"as a <TimesheetButtonControllerDelegate>", ^{
        describe(@"timesheetButtonControllerWillNavigateToTimesheetDetailScreen:", ^{
            __block UINavigationController *navigationController;
            
            beforeEach(^{
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);
                
                [subject view];
                [subject timesheetButtonControllerWillNavigateToTimesheetDetailScreen:nil];
            });
            
            it(@"should show a TimesheetDetailsSeriesController", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(timesheetDetailsSeriesController, YES);
            });
        });
        
        describe(@"timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:", ^{
            __block UINavigationController *navigationController;
            
            beforeEach(^{
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                spy_on(navigationController);
                
                [subject view];
                [subject timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:nil];
            });
            
            it(@"should show a TimesheetDetailsSeriesController", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(newTimesheetDetailsSeriesController, YES);
            });
        });
    });
    
    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(punchInColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(punchInButtonBorderColor)).and_return([[UIColor redColor] CGColor]);
            theme stub_method(@selector(punchInButtonBorderWidth)).and_return((CGFloat)13.0f);
            theme stub_method(@selector(punchInButtonTitleFont)).and_return([UIFont systemFontOfSize:14.0f]);
            theme stub_method(@selector(punchInButtonTitleColor)).and_return([UIColor blueColor]);
            theme stub_method(@selector(childControllerDefaultBackgroundColor)).and_return([UIColor magentaColor]);
            
            [subject view];
        });
        
        it(@"should style the views", ^{
            subject.workHoursContainerView.backgroundColor should equal([UIColor magentaColor]);
        });
        it(@"should have correct height work hours container", ^{
            subject.workHoursContainerHeight.constant should equal(CGFloat(109.0f));
        });
    });
    
    describe(@"the view hierarchy", ^{

        context(@"with prompt in OEF", ^{
            beforeEach(^{
                [subject view];
            });

            it(@"should add scroll view as the subview of the view", ^{
                [[subject.view subviews] count] should equal(1);
                [[subject.view subviews] firstObject] should be_same_instance_as(subject.scrollView);
            });

            it(@"scrollview should dismiss keyboard on drag", ^{
                subject.scrollView.keyboardDismissMode should equal(UIScrollViewKeyboardDismissModeOnDrag);
            });

            describe(@"the scrollview's container view", ^{


                __block UIView *containerView;
                beforeEach(^{
                    containerView = subject.containerView;
                });

                it(@"should live inside the scroll view", ^{
                    subject.scrollView.subviews should contain(containerView);
                });

                it(@"should not contain the punch in button", ^{
                    containerView.subviews should_not contain(subject.punchInButton);
                });

                it(@"should contain the card container view", ^{
                    containerView.subviews should contain(subject.cardContainerView);
                });

                it(@"should contain the timeline container card", ^{
                    containerView.subviews should contain(subject.timeLineCardContainerView);
                });

                it(@"should contain the timesheet button", ^{
                    containerView.subviews should contain(subject.timesheetButtonContainerView);
                });
                
            });
        });

        context(@"without prompt in OEF", ^{

            context(@"without project and client access", ^{
                beforeEach(^{
                    oefypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).again().and_return(nil);
                    [subject view];
                });

                it(@"should add scroll view as the subview of the view", ^{
                    [[subject.view subviews] count] should equal(1);
                    [[subject.view subviews] firstObject] should be_same_instance_as(subject.scrollView);
                });

                it(@"scrollview should dismiss keyboard on drag", ^{
                    subject.scrollView.keyboardDismissMode should equal(UIScrollViewKeyboardDismissModeOnDrag);
                });

                describe(@"the scrollview's container view", ^{

                    __block UIView *containerView;
                    beforeEach(^{
                        containerView = subject.containerView;
                    });

                    it(@"should live inside the scroll view", ^{
                        subject.scrollView.subviews should contain(containerView);
                    });

                    it(@"should contain the punch in button", ^{
                        containerView.subviews should contain(subject.punchInButton);
                    });

                    it(@"should not contain the card container view", ^{
                        containerView.subviews should_not contain(subject.cardContainerView);
                    });

                    it(@"should contain the timeline container card", ^{
                        containerView.subviews should contain(subject.timeLineCardContainerView);
                    });
                    
                    it(@"should contain the timesheet button", ^{
                        containerView.subviews should contain(subject.timesheetButtonContainerView);
                    });
                    
                });
            });

            context(@"with project access", ^{
                beforeEach(^{
                    oefypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).again().and_return(nil);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    [subject view];
                });

                it(@"should add scroll view as the subview of the view", ^{
                    [[subject.view subviews] count] should equal(1);
                    [[subject.view subviews] firstObject] should be_same_instance_as(subject.scrollView);
                });

                it(@"scrollview should dismiss keyboard on drag", ^{
                    subject.scrollView.keyboardDismissMode should equal(UIScrollViewKeyboardDismissModeOnDrag);
                });

                describe(@"the scrollview's container view", ^{

                    __block UIView *containerView;
                    beforeEach(^{
                        containerView = subject.containerView;
                    });

                    it(@"should live inside the scroll view", ^{
                        subject.scrollView.subviews should contain(containerView);
                    });

                    it(@"should not contain the punch in button", ^{
                        containerView.subviews should_not contain(subject.punchInButton);
                    });

                    it(@"should contain the card container view", ^{
                        containerView.subviews should contain(subject.cardContainerView);
                    });

                    it(@"should contain the timeline container card", ^{
                        containerView.subviews should contain(subject.timeLineCardContainerView);
                    });

                    it(@"should contain the timesheet button", ^{
                        containerView.subviews should contain(subject.timesheetButtonContainerView);
                    });
                    
                });
            });

            context(@"with activity access", ^{
                beforeEach(^{
                    oefypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).again().and_return(nil);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    [subject view];
                });

                it(@"should add scroll view as the subview of the view", ^{
                    [[subject.view subviews] count] should equal(1);
                    [[subject.view subviews] firstObject] should be_same_instance_as(subject.scrollView);
                });

                it(@"scrollview should dismiss keyboard on drag", ^{
                    subject.scrollView.keyboardDismissMode should equal(UIScrollViewKeyboardDismissModeOnDrag);
                });

                describe(@"the scrollview's container view", ^{

                    __block UIView *containerView;
                    beforeEach(^{
                        containerView = subject.containerView;
                    });

                    it(@"should live inside the scroll view", ^{
                        subject.scrollView.subviews should contain(containerView);
                    });

                    it(@"should not contain the punch in button", ^{
                        containerView.subviews should_not contain(subject.punchInButton);
                    });

                    it(@"should contain the card container view", ^{
                        containerView.subviews should contain(subject.cardContainerView);
                    });

                    it(@"should contain the timeline container card", ^{
                        containerView.subviews should contain(subject.timeLineCardContainerView);
                    });

                    it(@"should contain the timesheet button", ^{
                        containerView.subviews should contain(subject.timesheetButtonContainerView);
                    });
                    
                });
            });


        });

    });
    
    describe(@"as a <WorkHoursUpdateDelegate>", ^{
        __block id <WorkHours> workHours;
        beforeEach(^{
            workHours = nice_fake_for(@protocol(WorkHours));
            subject.view should_not be_nil;
            [subject dayTimeSummaryController:nil didUpdateWorkHours:workHours];
        });
        
        it(@"should store the workHours in the WorkHoursStorage", ^{
            workHoursStorage should have_received(@selector(saveWorkHoursSummary:)).with(workHours);
        });
        
    });

    describe(@"ViewWillAppear", ^{
        beforeEach(^{
            [subject viewWillAppear:YES];
        });
        it(@"should register for keyboardWillShow, keyboardWillHide", ^{
            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillShow:), UIKeyboardWillShowNotification, nil);

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

    describe(@"punching in without prompt OEF", ^{
        beforeEach(^{
            oefypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).again().and_return(nil);
            subject.view should_not be_nil;
            [subject.punchInButton tap];
        });

        it(@"should tell its delegate that the user punched in", ^{
            PunchCardObject *expectedCardObject = [[PunchCardObject alloc]
                                           initWithClientType:nil
                                           projectType:nil
                                           oefTypesArray:nil
                                           breakType:nil
                                           taskType:nil
                                           activity:nil
                                           uri:nil];
            delegate should have_received(@selector(projectPunchInController:didIntendToPunchWithObject:)).with(subject,expectedCardObject);
        });
    });

    describe(@"styling the punch in button", ^{

        context(@"when no project and client access and no clock in prompt OEF access", ^{
            beforeEach(^{
                theme stub_method(@selector(punchInColor)).and_return([UIColor orangeColor]);
                theme stub_method(@selector(punchInButtonBorderColor)).and_return([[UIColor redColor] CGColor]);
                theme stub_method(@selector(punchInButtonBorderWidth)).and_return((CGFloat)13.0f);
                theme stub_method(@selector(punchInButtonTitleFont)).and_return([UIFont systemFontOfSize:14.0f]);
                theme stub_method(@selector(punchInButtonTitleColor)).and_return([UIColor blueColor]);
                oefypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).again().and_return(nil);

                [subject view];
            });

            it(@"should style the views", ^{
                subject.punchInButton.backgroundColor should equal([UIColor orangeColor]);
                subject.punchInButton.layer.borderColor should equal([[UIColor redColor] CGColor]);
                subject.punchInButton.layer.borderWidth should equal(13.0f);
                subject.punchInButton.titleLabel.font should equal([UIFont systemFontOfSize:14.0f]);
                subject.punchInButton.titleLabel.textColor should equal([UIColor blueColor]);
                
            });
        });


    });

});

SPEC_END

