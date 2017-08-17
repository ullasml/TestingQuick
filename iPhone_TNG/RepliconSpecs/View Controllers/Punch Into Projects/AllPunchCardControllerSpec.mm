#import <Cedar/Cedar.h>
#import "AllPunchCardController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "PunchCardStorage.h"
#import "PunchCardObject.h"
#import "AllPunchCardCell.h"
#import "Theme.h"
#import <KSDeferred/KSDeferred.h>
#import "Punch.h"
#import "PunchRepository.h"
#import "UIControl+Spec.h"
#import "PunchClock.h"
#import "AllowAccessAlertHelper.h"
#import "PunchImagePickerControllerProvider.h"
#import "ImageNormalizer.h"
#import "UIBarButtonItem+Spec.h"
#import "UIControl+spec.h"
#import "ChildControllerHelper.h"
#import "PunchCardStylist.h"
#import "OEFType.h"
#import "LocalPunch.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "BreakType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AllPunchCardControllerSpec)

describe(@"AllPunchCardController", ^{
    __block AllPunchCardController *subject;
    __block PunchClock *punchClock;
    __block PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
    __block AllowAccessAlertHelper *allowAccessAlertHelper;
    __block UIImagePickerController *imagePicker;
    __block ImageNormalizer *imageNormalizer;
    __block ChildControllerHelper *childControllerHelper;
    __block id <BSBinder,BSInjector> injector;
    __block id <AllPunchCardControllerDelegate> delegate;
    __block PunchCardsListController *punchCardsListController;
    __block TransferPunchCardController *transferPunchCardController;
    __block PunchCardStylist <CedarDouble>*punchCardStylist;
    __block id <UserSession> userSession;


    beforeEach(^{
        injector = [InjectorProvider injector];

        punchCardStylist = nice_fake_for([PunchCardStylist class]);
        transferPunchCardController = nice_fake_for([TransferPunchCardController class]);
        punchCardsListController = nice_fake_for([PunchCardsListController class]);
        delegate = nice_fake_for(@protocol(AllPunchCardControllerDelegate));
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        imagePicker = nice_fake_for([UIImagePickerController class]);
        allowAccessAlertHelper = nice_fake_for([AllowAccessAlertHelper class]);
        punchImagePickerControllerProvider = nice_fake_for([PunchImagePickerControllerProvider class]);
        punchClock = nice_fake_for([PunchClock class]);
        imageNormalizer = nice_fake_for([ImageNormalizer class]);

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");

        punchImagePickerControllerProvider stub_method(@selector(provideInstanceWithDelegate:))
        .and_return(imagePicker);

        [injector bind:[TransferPunchCardController class] toInstance:transferPunchCardController];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:[PunchCardsListController class] toInstance:punchCardsListController];
        [injector bind:[ImageNormalizer class] toInstance:imageNormalizer];
        [injector bind:[PunchClock class] toInstance:punchClock];
        [injector bind:[PunchCardStylist class] toInstance:punchCardStylist];
        [injector bind:[PunchImagePickerControllerProvider class] toInstance:punchImagePickerControllerProvider];
        [injector bind:[AllowAccessAlertHelper class] toInstance:allowAccessAlertHelper];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        
        subject = [injector getInstance:[AllPunchCardController class]];

        [subject setUpWithDelegate:delegate controllerType:SeeAllPunchCardsControllerType punchCardObject:nil flowType:NoneWorkflowType];

    });

    describe(@"when the view loads", ^{

        context(@"when controller type is TransferPunchCardsControllerType", ^{

            beforeEach(^{
                [subject setUpWithDelegate:delegate controllerType:TransferPunchCardsControllerType punchCardObject:nil flowType:TransferWorkFlowType];
                subject.view should_not be_nil;
                spy_on(subject.transferCardContainerView);
            });

            it(@"should set the title properly", ^{
                subject.title should equal(RPLocalizedString(@"Transfer", nil));
            });

            it(@"should add the punchCardsListController", ^{

                punchCardsListController should have_received(@selector(setUpWithDelegate:)).with(subject);
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(punchCardsListController,subject,subject.punchCardsListContainerView);
            });


            it(@"should add the transfer card only when the controller type is TransferPunchCardsControllerType", ^{
                punchCardStylist should_not have_received(@selector(styleBorderForView:)).with(subject.transferCardContainerView);
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(transferPunchCardController,subject,subject.transferCardContainerView);
            });

        });

        context(@"When workflow type is Resume type", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate controllerType:TransferPunchCardsControllerType punchCardObject:nil flowType:ResumeWorkFlowType];
                subject.view should_not be_nil;
                spy_on(subject.transferCardContainerView);
            });

            it(@"should set the title properly", ^{
                subject.title should equal(RPLocalizedString(@"Resume Work", nil));
            });

            it(@"should add the punchCardsListController", ^{

                punchCardsListController should have_received(@selector(setUpWithDelegate:)).with(subject);
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(punchCardsListController,subject,subject.punchCardsListContainerView);
            });


            it(@"should add the transfer card only when the controller type is TransferPunchCardsControllerType", ^{

                punchCardStylist should_not have_received(@selector(styleBorderForView:)).with(subject.transferCardContainerView);

                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(transferPunchCardController,subject,subject.transferCardContainerView);
            });

        });
    });

    describe(@"As a <PunchCardsListControllerDelegate>", ^{

        beforeEach(^{
            subject.view should_not be_nil;
        });

        context(@"-punchCardsListController:didUpdateHeight:", ^{

            beforeEach(^{
                [subject punchCardsListController:nil didUpdateHeight:100];
            });

            it(@"should update the punch card list container height", ^{
                subject.punchCardsListHeightConstraint.constant should equal((CGFloat)100);
            });
        });

        context(@"-punchCardsListController:didIntendToTransferUsingPunchCard:", ^{
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block NSArray *oefTypesArray;

            beforeEach(^{
                client = nice_fake_for([ClientType class]);
                project = nice_fake_for([ProjectType class]);
                task = nice_fake_for([TaskType class]);
                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(clientType)).and_return(client);
                cardObject stub_method(@selector(projectType)).and_return(project);
                cardObject stub_method(@selector(taskType)).and_return(task);

                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                cardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject punchCardsListController:nil didIntendToTransferUsingPunchCard:cardObject];
            });

            it(@"should inform the punch clock to start the punch assembly workflow", ^{

                punchClock should have_received(@selector(resumeWorkWithPunchProjectAssemblyWorkflowDelegate:clientType:projectType:taskType:oefTypesArray:)).with(subject,client,project,task,oefTypesArray);
            });
        });

        context(@"-punchCardsListController:didIntendToPunchInUsingPunchCard:", ^{
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;

            beforeEach(^{
                client = nice_fake_for([ClientType class]);
                project = nice_fake_for([ProjectType class]);
                task = nice_fake_for([TaskType class]);
                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(clientType)).and_return(client);
                cardObject stub_method(@selector(projectType)).and_return(project);
                cardObject stub_method(@selector(taskType)).and_return(task);
                [subject punchCardsListController:nil didIntendToPunchInUsingPunchCard:cardObject];
            });

            it(@"should inform the punch clock to start the punch assembly workflow", ^{

                punchClock should have_received(@selector(punchInWithPunchAssemblyWorkflowDelegate:clientType:projectType:taskType:activity:oefTypesArray:)).with(subject,client,project,task,Arguments::anything,Arguments::anything);
            });
        });

        context(@"-punchCardsListController:didFindPunchCardAsInvalidPunchCard:", ^{
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block NSArray *oefTypesArray;
            __block BreakType *breakType;

            beforeEach(^{

                client = nice_fake_for([ClientType class]);
                project = nice_fake_for([ProjectType class]);
                task = nice_fake_for([TaskType class]);
                breakType = nice_fake_for([BreakType class]);
                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(clientType)).and_return(nil);
                cardObject stub_method(@selector(projectType)).and_return(nil);
                cardObject stub_method(@selector(taskType)).and_return(nil);
                cardObject stub_method(@selector(uri)).and_return(nil);
                cardObject stub_method(@selector(breakType)).and_return(breakType);

                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                cardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject punchCardsListController:nil didFindPunchCardAsInvalidPunchCard:cardObject];
            });

            it(@"should update the transferpunchcard controller with empty punchcard", ^{
                subject.transferPunchCardController should have_received(@selector(updatePunchCardObject:));
            });

        });


    });

    describe(@"As a <TransferPunchCardControllerDelegate>", ^{
        context(@"-resumeWorkWithPunchProjectAssemblyWorkflowDelegate:clientType:projectType:taskType:oefTypesArray:", ^{
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                subject.view should_not be_nil;
            });
            beforeEach(^{
                client = nice_fake_for([ClientType class]);
                project = nice_fake_for([ProjectType class]);
                task = nice_fake_for([TaskType class]);
                task stub_method(@selector(uri)).and_return(@"task-uri");
                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(clientType)).and_return(client);
                cardObject stub_method(@selector(projectType)).and_return(project);
                cardObject stub_method(@selector(taskType)).and_return(task);

                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                cardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject transferPunchCardController:nil didIntendToTransferPunchWithObject:cardObject];
            });
            
            it(@"should inform the punch clock to start the punch assembly workflow", ^{
                
                punchClock should have_received(@selector(resumeWorkWithPunchProjectAssemblyWorkflowDelegate:clientType:projectType:taskType:oefTypesArray:)).with(subject,client,project,task,oefTypesArray);
            });
        });
        
        context(@"-transferPunchCardController:didUpdateHeight:", ^{
            
            beforeEach(^{
                subject.view should_not be_nil;
            });
            beforeEach(^{
                CGFloat height = 200;
                [subject transferPunchCardController:nil didUpdateHeight:height];
            });
            
            it(@"should inform the punch clock to start the punch assembly workflow", ^{
                subject.transferPunchCardHeightConstraint.constant should equal((CGFloat)200);
            });
        });
        
        context(@"-transferPunchCardController:didScrolltoSubview:", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });
            
            it(@"scroll the scrollview to textview cursor", ^{
                [subject view];
                UITextView *textView = nice_fake_for([UITextView class]);
                textView.text = @"testing!!!";
                spy_on(subject.scrollView);
                [subject transferPunchCardController:nil didScrolltoSubview:textView];
                subject.scrollView should have_received(@selector(setContentOffset:));
            });
        });

        context(@"-transferPunchcardController:didIntendToResumeWorkForProjectPunchWithObject:",^{
            __block PunchCardObject *cardObject;
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                subject.view should_not be_nil;
            });
            beforeEach(^{
                client = nice_fake_for([ClientType class]);
                project = nice_fake_for([ProjectType class]);
                task = nice_fake_for([TaskType class]);
                task stub_method(@selector(uri)).and_return(@"task-uri");
                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(clientType)).and_return(client);
                cardObject stub_method(@selector(projectType)).and_return(project);
                cardObject stub_method(@selector(taskType)).and_return(task);

                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                cardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject transferPunchCardController:nil didIntendToResumeWorkForProjectPunchWithObject:cardObject];
            });

            it(@"should inform the punch clock to start the punch assembly workflow with project", ^{

                punchClock should have_received(@selector(resumeWorkWithPunchProjectAssemblyWorkflowDelegate:clientType:projectType:taskType:oefTypesArray:)).with(subject,client,project,task,oefTypesArray);
            });
        });

        context(@"-transferPunchcardController:didIntendToResumeWorkForActivityPunchWithObject:",^{
            __block PunchCardObject *cardObject;
            __block Activity *activity;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                subject.view should_not be_nil;
            });
            beforeEach(^{
                activity = nice_fake_for([Activity class]);


                cardObject = nice_fake_for([PunchCardObject class]);
                cardObject stub_method(@selector(activity)).and_return(activity);
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                cardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject transferPunchCardController:nil didIntendToResumeWorkForActivityPunchWithObject:cardObject];
            });

            it(@"should inform the punch clock to start the punch assembly workflow with project", ^{

                punchClock should have_received(@selector(resumeWorkWithActivityAssemblyWorkflowDelegate:activity:oefTypesArray:)).with(subject, activity, oefTypesArray);
            });
        });


    });

    describe(@"as a <PunchAssemblyWorkflowDelegate>", ^{

        beforeEach(^{
            subject.view should_not be_nil;
        });
        describe(@"-punchAssemblyWorkflowNeedsImage", ^{
            __block KSPromise *imagePromise;
            __block KSPromise *punchPromise;
            __block LocalPunch *punch;
            __block PunchAssemblyWorkflow *workflow;

            beforeEach(^{
                punch = nice_fake_for([LocalPunch class]);
                workflow = nice_fake_for([PunchAssemblyWorkflow class]);
                punchPromise = nice_fake_for([KSPromise class]);
                imagePromise = [subject punchAssemblyWorkflowNeedsImage];
            });

            it(@"should display the image picker view controller", ^{
                subject.presentedViewController should be_same_instance_as(imagePicker);
            });

            it(@"should configure the image picker correctly", ^{
                punchImagePickerControllerProvider should have_received(@selector(provideInstanceWithDelegate:))
                .with(subject);
            });

            it(@"should return a promise", ^{
                imagePromise should be_instance_of([KSPromise class]);
            });
        });

        describe(@"-punchAssemblyWorkflow:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:", ^{
            __block PunchAssemblyWorkflow *workflow;
            __block LocalPunch *incompletePunch;
            __block KSPromise *assembledPunchPromise;
            __block KSPromise *serverPromise;
            __block UINavigationController *navigationController;
            __block UIViewController *rootViewController;

            beforeEach(^{

                rootViewController = [[UIViewController alloc] init];
                navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                [navigationController pushViewController:subject animated:NO];

                workflow = nice_fake_for([PunchAssemblyWorkflow class]);
                assembledPunchPromise = nice_fake_for([KSPromise class]);
                serverPromise = nice_fake_for([KSPromise class]);
                incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];


                [subject punchAssemblyWorkflow:workflow
           willEventuallyFinishIncompletePunch:incompletePunch
                         assembledPunchPromise:assembledPunchPromise
                   serverDidFinishPunchPromise:serverPromise];
            });

            it(@"should inform its delegate to finish the punch assembly workflow", ^{
                delegate should have_received(@selector(allPunchCardController:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:)).with(subject,incompletePunch,assembledPunchPromise,serverPromise);
            });

            it(@"should dismiss itself", ^{
                navigationController.topViewController should be_same_instance_as(rootViewController);
            });
        });

        describe(@"-punchAssemblyWorkflow:didFailToAssembleIncompletePunch", ^{
            describe(@"when the punch assembly workflow failed to get access to the phone's location / camera", ^{
                __block NSError *locationError;
                __block NSError *cameraError;
                beforeEach(^{
                    locationError = [[NSError alloc] initWithDomain:LocationAssemblyGuardErrorDomain code:LocationAssemblyGuardErrorCodeDeniedAccessToLocation userInfo:nil];
                    cameraError = [[NSError alloc] initWithDomain:CameraAssemblyGuardErrorDomain
                                                             code:CameraAssemblyGuardErrorCodeDeniedAccessToCamera
                                                         userInfo:nil];
                    NSError *unhandledError = [[NSError alloc] init];

                    [subject view];
                    [subject viewWillAppear:YES];

                    [subject punchAssemblyWorkflow:(id) [NSNull null]
                  didFailToAssembleIncompletePunch:(id) [NSNull null]
                                            errors:@[locationError, cameraError, unhandledError]];
                });

                it(@"should send a message to its alert helper", ^{
                    allowAccessAlertHelper should have_received(@selector(handleLocationError:cameraError:)).with(locationError, cameraError);
                });
            });
        });
    });

    describe(@"as an <UIImagePickerControllerDelegate>", ^{

        __block KSPromise *imagePromise;

        beforeEach(^{
            subject.view should_not be_nil;
        });
        describe(@"imagePickerControllerDidCancel:", ^{
            beforeEach(^{
                imagePromise = [subject punchAssemblyWorkflowNeedsImage];

                [subject imagePickerControllerDidCancel:imagePicker];
            });

            it(@"should reject the promise returned to the punch assembly workflow", ^{
                imagePromise.rejected should be_truthy;
            });

            it(@"should dismiss the UIImagePickerController ", ^{
                imagePicker should have_received(@selector(dismissViewControllerAnimated:completion:)).with(YES, nil);
            });
        });

        describe(@"imagePickerController:didFinishPickingMediaWithInfo:", ^{
            __block UIImage *expectedImage;
            __block UIImage *normalizedImage;
            __block NSDate *expectedDate;

            beforeEach(^{
                [subject view];
                [subject viewWillAppear:NO];

                expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
                expectedImage = nice_fake_for([UIImage class]);
                normalizedImage = nice_fake_for([UIImage class]);
                imageNormalizer stub_method(@selector(normalizeImage:)).with(expectedImage).and_return(normalizedImage);

                imagePromise = [subject punchAssemblyWorkflowNeedsImage];

                [subject imagePickerController:imagePicker
                 didFinishPickingMediaWithInfo:@{
                                                 UIImagePickerControllerOriginalImage : expectedImage
                                                 }];
            });

            it(@"should resolve the image promise with the normalized image", ^{

                __block UIImage *fulfilledImage;

                fulfilledImage should_not be_same_instance_as(normalizedImage);

                imagePicker stub_method(@selector(dismissViewControllerAnimated:completion:)).and_do_block(^void(BOOL animation, void (^completionHandler)(BOOL granted)) {

                    [imagePromise then:^id(UIImage *image) {
                        fulfilledImage = image;
                        return nil;
                    }error:^id(NSError *error) {
                        throw @"Image promise should not have been rejected";
                        return nil;
                    }];
                    
                    fulfilledImage should be_same_instance_as(normalizedImage);
                });
                
                
            });
            
            it(@"should dismiss the image picker view", ^{
                imagePicker should have_received(@selector(dismissViewControllerAnimated:completion:)).with(YES, Arguments::anything);
            });
        });
    });
    
    describe(@"punchCardsListController:didIntendToUpdatePunchCard", ^{
        
        __block PunchCardObject *cardObject;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;
        __block NSArray *oefTypesArray;
        beforeEach(^{
            [subject view];
            client = nice_fake_for([ClientType class]);
            project = nice_fake_for([ProjectType class]);
            task = nice_fake_for([TaskType class]);
            cardObject = nice_fake_for([PunchCardObject class]);
            cardObject stub_method(@selector(clientType)).and_return(client);
            cardObject stub_method(@selector(projectType)).and_return(project);
            cardObject stub_method(@selector(taskType)).and_return(task);
            
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];
            cardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
            spy_on(subject.scrollView);
            [subject punchCardsListController:nil didIntendToUpdatePunchCard:cardObject];
        });
        
        it(@"should update transferPunchCardController with new punch card object", ^{
            transferPunchCardController should have_received(@selector(updatePunchCardObject:)).with(cardObject);
        });
        
        it(@"should set scrollview content offset to zero", ^{
            CGFloat navigationBarHeight = CGRectGetHeight(subject.navigationController.navigationBar.frame)+10;
            CGPoint offsetPoint = CGPointMake(0, -navigationBarHeight);
            subject.scrollView should have_received(@selector(setContentOffset:animated:)).with(offsetPoint, YES);
        });
    });
});

SPEC_END
