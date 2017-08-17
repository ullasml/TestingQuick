#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchIntoProjectHomeController.h"
#import "PunchInController.h"
#import "PunchOutController.h"
#import "DateProvider.h"
#import "PunchRepository.h"
#import "LocalPunch.h"
#import "LocationRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchClock.h"
#import "UIImagePickerController+Spec.h"
#import "ImageNormalizer.h"
#import "PunchImagePickerControllerProvider.h"
#import "OnBreakController.h"
#import "BreakType.h"
#import "PunchControllerProvider.h"
#import "ChildControllerHelper.h"
#import "UIAlertView+Spec.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "PunchAssemblyGuard.h"
#import "AllowAccessAlertHelper.h"
#import "PunchCardObject.h"
#import "PunchIntoProjectControllerProvider.h"
#import "PunchCardStorage.h"
#import "UIControl+Spec.h"
#import "UIBarButtonItem+Spec.h"
#import "MostRecentPunchInDetector.h"
#import "UserPermissionsStorage.h"
#import "SelectionController.h"
#import "ClientRepository.h"
#import "TaskRepository.h"
#import "ActivityRepository.h"
#import "ProjectRepository.h"
#import "MostRecentActivityPunchDetector.h"
#import "OEFTypeStorage.h"
#import "OEFCollectionPopUpViewController.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "DateProvider.h"
#import "TimeLinePunchesSummary.h"
#import "TimeLineAndRecentPunchRepository.h"
#import "Activity.h"
#import "GUIDProvider.h"
#import "AllPunchCardController.h"
#import "TimeLinePunchesStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchIntoProjectHomeControllerSpec)

describe(@"PunchIntoProjectHomeController", ^{
    __block PunchIntoProjectHomeController *subject;
    __block PunchIntoProjectControllerProvider <CedarDouble>*punchControllerProvider;
    __block PunchClock<CedarDouble> *punchClock;
    __block UIImagePickerController *imagePicker;
    __block PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
    __block ImageNormalizer *imageNormalizer;
    __block KSPromise *serverPromise;
    __block PunchRepository <CedarDouble>*punchRepository;
    __block AllowAccessAlertHelper *allowAccessAlertHelper;
    __block PunchCardStorage *punchCardStorage;
    __block id<UserSession> userSession;
    __block MostRecentPunchInDetector *mostRecentPunchInDetector;
    __block MostRecentActivityPunchDetector *mostRecentActivityPunchDetector;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<BSBinder, BSInjector> injector;
    __block OEFTypeStorage *oefTypeStorage;
    __block DateProvider *dateProvider;
    __block NSDate *expectedDate;
    __block TimeLineAndRecentPunchRepository *timeLineAndRecentPunchRepository;
    __block GUIDProvider *guidProvider;
    __block ChildControllerHelper <CedarDouble> *childControllerHelper;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;

    beforeEach(^{
        injector = [InjectorProvider injector];

        serverPromise = [[KSPromise alloc] init];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        punchClock = nice_fake_for([PunchClock class]);
        punchControllerProvider = nice_fake_for([PunchIntoProjectControllerProvider class]);
        allowAccessAlertHelper = nice_fake_for([AllowAccessAlertHelper class]);
        punchCardStorage = nice_fake_for([PunchCardStorage class]);
        imagePicker = nice_fake_for([UIImagePickerController class]);
        imageNormalizer = nice_fake_for([ImageNormalizer class]);
        mostRecentPunchInDetector = nice_fake_for([MostRecentPunchInDetector class]);
        mostRecentActivityPunchDetector = nice_fake_for([MostRecentActivityPunchDetector class]);
        punchImagePickerControllerProvider = nice_fake_for([PunchImagePickerControllerProvider class]);
        punchImagePickerControllerProvider stub_method(@selector(provideInstanceWithDelegate:))
        .and_return(imagePicker);

        guidProvider = nice_fake_for([GUIDProvider class]);
        userSession = fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"some:user:uri");

        oefTypeStorage = nice_fake_for([OEFTypeStorage class]);
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);

        [injector bind:[MostRecentPunchInDetector class] toInstance:mostRecentPunchInDetector];
        [injector bind:[MostRecentActivityPunchDetector class] toInstance:mostRecentActivityPunchDetector];
        [injector bind:[PunchImagePickerControllerProvider class] toInstance:punchImagePickerControllerProvider];
        [injector bind:[PunchIntoProjectControllerProvider class] toInstance:punchControllerProvider];
        [injector bind:[AllowAccessAlertHelper class] toInstance:allowAccessAlertHelper];
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        [injector bind:[PunchCardStorage class] toInstance:punchCardStorage];
        [injector bind:[ImageNormalizer class] toInstance:imageNormalizer];
        [injector bind:[PunchClock class] toInstance:punchClock];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[OEFTypeStorage class] toInstance:oefTypeStorage];
        [injector bind:[GUIDProvider class] toInstance:guidProvider];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];

        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);
        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];

        guidProvider stub_method(@selector(guid)).and_return(@"my-awesome-identifier");



        punchRepository = [injector getInstance:[PunchRepository class]];
        spy_on(punchRepository);

        expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider = nice_fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(expectedDate);
        [injector bind:[DateProvider class] toInstance:dateProvider];

        timeLineAndRecentPunchRepository = nice_fake_for([TimeLineAndRecentPunchRepository class]);
        [injector bind:[TimeLineAndRecentPunchRepository class] toInstance:timeLineAndRecentPunchRepository];

        subject = [injector getInstance:[PunchIntoProjectHomeController class]];
        spy_on(subject);
    });

    afterEach(^{
        stop_spying_on(subject);
        stop_spying_on(punchRepository);

    });

    describe(@"When the view loads", ^{


        describe(@"When user has no activity access", ^{
            __block KSDeferred *fetchMostRecentPunchForUserUriDeferred;
            beforeEach(^{

                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);

                fetchMostRecentPunchForUserUriDeferred = [[KSDeferred alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriDeferred.promise);


                subject.view should_not be_nil;
                [subject viewWillAppear:YES];

            });


            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(TimeSheetLabelText, TimeSheetLabelText));
            });

            it(@"should extend layout including opaque bars", ^{
                subject.extendedLayoutIncludesOpaqueBars should be_truthy;
            });

            it(@"should fetch most recent punch ", ^{
                punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"some:user:uri");
            });

            context(@"when fetched successfully", ^{

                context(@"when the most recent punch and timeline punches doesn't match", ^{
                    __block id<Punch> fakePunch1;
                    __block id<Punch> fakePunch2;
                    __block UIViewController *punchController;
                    beforeEach(^{

                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);


                        punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                        .and_return(punchController);


                        [fetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    afterEach(^{
                        stop_spying_on(punchController);
                    });
                    
                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });
                    
                    it(@"should make the punch out controller a child controller", ^{
                        subject.childViewControllers.firstObject should be_same_instance_as(punchController);
                    });

                    it(@"first time user should be falsy", ^{
                        subject.firstTimeUser should be_falsy;
                    });
                });

                context(@"when the most recent punch and timeline punches matches", ^{

                    __block LocalPunch *punch;
                    __block NSDate *date;
                    __block UIViewController *punchController;
                    __block LocalPunch *fakePunch1;
                    __block LocalPunch *fakePunch2;
                    beforeEach(^{
                        date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                        punch = fake_for([LocalPunch class]);
                        punch stub_method(@selector(date)).and_return(date);
                        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                        punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                        .and_return(punchController);

                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);


                        (id<CedarDouble>)subject stub_method(@selector(mostRecentPunch)).and_return(fakePunch2);
                        (id<CedarDouble>)subject stub_method(@selector(timelinePunches)).and_return(@[fakePunch1]);

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);

                         [fetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];

                    });
                    afterEach(^{
                        stop_spying_on(punchController);
                    });

                    it(@"should not display the next punch controller", ^{
                        subject.childViewControllers.firstObject should_not be_same_instance_as(punchController);
                    });

                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should notbe the punch out controller's delegate", ^{
                        punchControllerProvider should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:));
                    });


                    it(@"should not tell the punch out controller that it has moved to parent controller", ^{
                        punchController should_not have_received(@selector(didMoveToParentViewController:));
                    });

                    it(@"should update most recent punch", ^{
                        subject.mostRecentPunch should equal(fakePunch2);
                    });

                    it(@"should update timeline punches", ^{
                        subject.timelinePunches should equal(@[fakePunch1]);
                    });

                    it(@"first time user should be falsy", ^{
                        subject.firstTimeUser should be_falsy;
                    });

                });

                context(@"When its for a new user without any punches", ^{
                    __block UIViewController *punchController;
                    beforeEach(^{

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[]);

                        punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                        .and_return(punchController);


                        [fetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    afterEach(^{
                        stop_spying_on(punchController);
                    });
                    
                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should make the punch out controller a child controller", ^{
                        subject.childViewControllers.firstObject should be_same_instance_as(punchController);
                    });

                    it(@"first time user should be truthy", ^{
                        subject.firstTimeUser should be_truthy;
                    });

                    context(@"When its for a new user without any punches revisiting the view", ^{
                        __block UIViewController *punchController1;
                        __block PunchControllerProvider *punchControllerProvider1;
                        beforeEach(^{

                            TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                            timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[]);
                            timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[]);

                            KSDeferred *againFetchMostRecentPunchForUserUriDeferred = [[KSDeferred alloc]init];
                            punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).again().and_return(againFetchMostRecentPunchForUserUriDeferred.promise);

                            punchController1 = [[UIViewController alloc]init];
                            spy_on(punchController1);

                            punchControllerProvider1 = nice_fake_for([PunchIntoProjectControllerProvider class]);

                            (id<CedarDouble>)subject stub_method(@selector(punchControllerProvider)).and_return(punchControllerProvider1);

                            punchControllerProvider1 stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                            .and_return(punchController1);

                            [subject viewWillAppear:NO];

                            [againFetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];
                        });
                        afterEach(^{
                            stop_spying_on(punchController1);
                        });

                        it(@"should not display the next punch controller", ^{
                            subject.childViewControllers.firstObject should_not be_same_instance_as(punchController1);
                        });

                        it(@"should have a single child controller", ^{
                            subject.childViewControllers.count should equal(1);
                        });

                        it(@"should notbe the punch out controller's delegate", ^{
                            punchControllerProvider1 should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:));
                        });


                        it(@"should not tell the punch out controller that it has moved to parent controller", ^{
                            punchController1 should_not have_received(@selector(didMoveToParentViewController:));
                        });
                        
                        it(@"first time user should be falsy", ^{
                            subject.firstTimeUser should be_truthy;
                        });
                        
                    });


                });

            });
            
            context(@"left bar button item intially", ^{
                beforeEach(^{
                    [subject.navigationItem.leftBarButtonItem tap];
                });
                
                it(@"should show left bar button item", ^{
                    subject.navigationItem.leftBarButtonItem should_not be_nil;
                });
            });
        });

        describe(@"When user has activity access", ^{
            __block KSDeferred *fetchMostRecentPunchForUserUriDeferred;
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                fetchMostRecentPunchForUserUriDeferred = [[KSDeferred alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriDeferred.promise);

                subject.view should_not be_nil;
                [subject viewWillAppear:YES];

            });


            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(TimeSheetsTabbarTitle, nil));
            });

            it(@"should extend layout including opaque bars", ^{
                subject.extendedLayoutIncludesOpaqueBars should be_truthy;
            });

            it(@"should fetch most recent punch ", ^{
                punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"some:user:uri");
            });

            it(@"should show left bar button item", ^{
                subject.navigationItem.leftBarButtonItem should be_nil;
            });

            context(@"when fetched successfully", ^{
                __block id<Punch> fakePunch1;
                __block id<Punch> fakePunch2;
                __block UIViewController *punchController;
                beforeEach(^{

                    fakePunch1 = nice_fake_for([LocalPunch class]);
                    fakePunch2 = nice_fake_for([LocalPunch class]);

                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);

                    punchController = [[UIViewController alloc]init];
                    spy_on(punchController);

                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                    .and_return(punchController);

                    [fetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];
                });
                afterEach(^{
                    stop_spying_on(punchController);
                });

                
                it(@"should have a single child controller", ^{
                    subject.childViewControllers.count should equal(1);
                });

                it(@"should make the punch out controller a child controller", ^{
                    subject.childViewControllers.firstObject should be_same_instance_as(punchController);
                });
            });
        });

    });

    describe(@"-fetchAndDisplayChildControllerForMostRecentPunch", ^{
        
        beforeEach(^{
            [subject fetchAndDisplayChildControllerForMostRecentPunch];
        });

        it(@"should fetch the most recent punch from the punch clock", ^{
            punchRepository should have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"some:user:uri");
        });
    });

    describe(@"as a <PunchRepositoryObserver>", ^{

        it(@"should add itself as an observer", ^{
            punchRepository should have_received(@selector(addObserver:)).with(subject);
        });

        describe(@"punchRepository:didUpdateMostRecentPunch:", ^{
            
            __block UIViewController *punchController;

            beforeEach(^{
                punchController = [[UIViewController alloc] init];
                spy_on(punchController);

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .and_return(punchController);
            });
            afterEach(^{
                stop_spying_on(punchController);
            });

            context(@"when most recent punch is received from punchRepository", ^{
                
                context(@"when the most recent punch and timeline punches doesn't match", ^{
                    beforeEach(^{
                        [subject view];
                    });

                    __block RemotePunch *punch;
                    __block NSDate *date;
                    __block RemotePunch *fakePunch1;

                    beforeEach(^{
                        date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                        punch = fake_for([RemotePunch class]);
                        punch stub_method(@selector(date)).and_return(date);
                        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        punch stub_method(@selector(syncedWithServer)).and_return(YES);

                        fakePunch1 = nice_fake_for([RemotePunch class]);
                        fakePunch1 stub_method(@selector(syncedWithServer)).and_return(YES);

                        timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[fakePunch1,punch]);
                        timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[fakePunch1,punch]);

                        [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];

                    });

                    it(@"should display the next punch controller", ^{
                        subject.childViewControllers.firstObject should be_same_instance_as(punchController);
                    });

                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should be the punch out controller's delegate", ^{
                        punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).with(subject, nil, nil,nil, punch,nil);
                    });

                    it(@"should size the child view controllers's frame appropriately", ^{
                        [subject viewWillAppear:YES];

                        punchController.view.frame should equal(subject.view.bounds);
                    });
                    
                    it(@"should tell the punch out controller that it has moved to parent controller", ^{
                        punchController should have_received(@selector(didMoveToParentViewController:)).with(subject);
                    });

                    it(@"first time user should be falsy", ^{
                        subject.firstTimeUser should be_falsy;
                    });
                });

                context(@"when the most recent punch and timeline punches matches", ^{
                    beforeEach(^{
                        [subject view];
                    });

                    __block RemotePunch *punch;
                    __block NSDate *date;
                    __block RemotePunch *fakePunch1;

                    beforeEach(^{
                        date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                        punch = fake_for([RemotePunch class]);
                        punch stub_method(@selector(date)).and_return(date);
                        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        punch stub_method(@selector(syncedWithServer)).and_return(YES);

                        fakePunch1 = nice_fake_for([RemotePunch class]);
                        fakePunch1 stub_method(@selector(syncedWithServer)).and_return(YES);


                        (id<CedarDouble>)subject stub_method(@selector(mostRecentPunch)).and_return(punch);
                        (id<CedarDouble>)subject stub_method(@selector(timelinePunches)).and_return(@[fakePunch1,punch]);

                        timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[fakePunch1,punch]);
                        timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[fakePunch1,punch]);

                        [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];

                    });

                    it(@"should not display the next punch controller", ^{
                        subject.childViewControllers.firstObject should_not be_same_instance_as(punchController);
                    });

                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should notbe the punch out controller's delegate", ^{
                        punchControllerProvider should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:));
                    });


                    it(@"should not tell the punch out controller that it has moved to parent controller", ^{
                        punchController should_not have_received(@selector(didMoveToParentViewController:));
                    });

                    it(@"should update most recent punch", ^{
                        subject.mostRecentPunch should equal(punch);
                    });
                    
                    it(@"should update timeline punches", ^{
                        subject.timelinePunches should equal(@[fakePunch1,punch]);
                    });

                    it(@"first time user should be falsy", ^{
                        subject.firstTimeUser should be_falsy;
                    });
                });

                context(@"When its for a new user without any punches", ^{
                    beforeEach(^{
                        [subject view];
                    });

                    __block LocalPunch *punch;
                    beforeEach(^{

                        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                        punch = fake_for([RemotePunch class]);
                        punch stub_method(@selector(date)).and_return(date);
                        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                        punch stub_method(@selector(syncedWithServer)).and_return(YES);

                        timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[]);
                        timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[]);


                        [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];

                    });
                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should make the punch out controller a child controller", ^{
                        subject.childViewControllers.firstObject should be_same_instance_as(punchController);
                    });

                    it(@"first time user should be truthy", ^{
                        subject.firstTimeUser should be_truthy;
                    });

                    context(@"When its for a new user without any punches revisiting the view", ^{
                        __block UIViewController *punchController1;
                        __block PunchControllerProvider *punchControllerProvider1;
                        beforeEach(^{

                            timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).again().with(expectedDate,@"some:user:uri").and_return(@[]);
                            timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).again().with(@"some:user:uri").and_return(@[]);


                            punchController1 = [[UIViewController alloc]init];
                            spy_on(punchController1);
                            

                            punchControllerProvider1 = nice_fake_for([PunchIntoProjectControllerProvider class]);

                            (id<CedarDouble>)subject stub_method(@selector(punchControllerProvider)).and_return(punchControllerProvider1);

                            punchControllerProvider1 stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                            .and_return(punchController1);

                            [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];


                        });
                        afterEach(^{
                            stop_spying_on(punchController1);
                        });
                        
                        it(@"should not display the next punch controller", ^{
                            subject.childViewControllers.firstObject should_not be_same_instance_as(punchController1);
                        });

                        it(@"should have a single child controller", ^{
                            subject.childViewControllers.count should equal(1);
                        });

                        it(@"should notbe the punch out controller's delegate", ^{
                            punchControllerProvider1 should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:));
                        });


                        it(@"should not tell the punch out controller that it has moved to parent controller", ^{
                            punchController1 should_not have_received(@selector(didMoveToParentViewController:));
                        });
                        
                        it(@"first time user should be falsy", ^{
                            subject.firstTimeUser should be_truthy;
                        });
                        
                    });
                    
                    
                });
            });
        });

        describe(@"punchRepositoryDidDiscoverFirstTimeUse:", ^{
            __block UIViewController *punchController;
            beforeEach(^{
                punchController = [[UIViewController alloc] init];
                spy_on(punchController);

                KSPromise *punchPromise = nice_fake_for([KSPromise class]);
                timeLineAndRecentPunchRepository stub_method(@selector(punchesPromiseWithServerDidFinishPunchPromise:timeLinePunchFlow:userUri:date:)).and_return(punchPromise);

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .with(subject, nil, nil, nil,nil, punchPromise)
                .and_return(punchController);

                [subject view];

                [subject punchRepositoryDidDiscoverFirstTimeUse:nil];
            });
            afterEach(^{
                stop_spying_on(punchController);
            });

            it(@"should not show the right bar button item , since its a first time login for user", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });

            it(@"should display the next punch controller", ^{
                subject.childViewControllers.firstObject should be_same_instance_as(punchController);
            });

            it(@"should have a single child controller", ^{
                subject.childViewControllers.count should equal(1);
            });

            it(@"should size the child view controllers's frame appropriately", ^{
                [subject viewWillAppear:YES];
                punchController.view.frame should equal(subject.view.bounds);
            });

            it(@"should tell the punch out controller that it has moved to parent controller", ^{
                punchController should have_received(@selector(didMoveToParentViewController:)).with(subject);
            });
        });

        describe(@"punchRepositoryDidSyncPunches:", ^{
            __block KSDeferred *fetchMostRecentPunchForUserUriDeferred;
            beforeEach(^{

                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);

                fetchMostRecentPunchForUserUriDeferred = [[KSDeferred alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriDeferred.promise);


                subject.view should_not be_nil;

                [subject punchRepositoryDidSyncPunches:punchRepository];

            });


            it(@"should fetch most recent punch ", ^{
                punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"some:user:uri");
            });

            context(@"when fetched successfully", ^{

                context(@"when the most recent punch and timeline punches doesn't match", ^{
                    __block id<Punch> fakePunch1;
                    __block id<Punch> fakePunch2;
                    __block UIViewController *punchController;
                    beforeEach(^{

                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);


                        punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                        .and_return(punchController);


                        [fetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];
                    });
                    afterEach(^{
                        stop_spying_on(punchController);
                    });
                    
                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should make the punch out controller a child controller", ^{
                        subject.childViewControllers.firstObject should be_same_instance_as(punchController);
                    });

                    it(@"first time user should be falsy", ^{
                        subject.firstTimeUser should be_falsy;
                    });
                });

                context(@"when the most recent punch and timeline punches matches", ^{

                    __block LocalPunch *punch;
                    __block NSDate *date;
                    __block UIViewController *punchController;
                    __block LocalPunch *fakePunch1;
                    __block LocalPunch *fakePunch2;
                    beforeEach(^{
                        date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                        punch = fake_for([LocalPunch class]);
                        punch stub_method(@selector(date)).and_return(date);
                        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                        punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                        .and_return(punchController);

                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);


                        (id<CedarDouble>)subject stub_method(@selector(mostRecentPunch)).and_return(fakePunch2);
                        (id<CedarDouble>)subject stub_method(@selector(timelinePunches)).and_return(@[fakePunch1]);

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);

                        [fetchMostRecentPunchForUserUriDeferred resolveWithValue:timeLinePunchesSummary];

                    });
                    afterEach(^{
                        stop_spying_on(punchController);
                    });
                    
                    it(@"should not display the next punch controller", ^{
                        subject.childViewControllers.firstObject should_not be_same_instance_as(punchController);
                    });

                    it(@"should have a single child controller", ^{
                        subject.childViewControllers.count should equal(1);
                    });

                    it(@"should notbe the punch out controller's delegate", ^{
                        punchControllerProvider should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:));
                    });


                    it(@"should not tell the punch out controller that it has moved to parent controller", ^{
                        punchController should_not have_received(@selector(didMoveToParentViewController:));
                    });

                    it(@"should update most recent punch", ^{
                        subject.mostRecentPunch should equal(fakePunch2);
                    });

                    it(@"should update timeline punches", ^{
                        subject.timelinePunches should equal(@[fakePunch1]);
                    });

                    it(@"first time user should be falsy", ^{
                        subject.firstTimeUser should be_falsy;
                    });

                });

                
            });
            

        });

    });

    describe(@"left bar button item action", ^{
        __block BookmarksHomeViewController *bookmarksHomeViewController;
        __block UINavigationController *navigationController;
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            [subject view];
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            bookmarksHomeViewController = [[BookmarksHomeViewController alloc] initWithChildControllerHelper:nil];
            [injector bind:[BookmarksHomeViewController class] toInstance:bookmarksHomeViewController];
            
            spy_on(bookmarksHomeViewController);
            [subject.navigationItem.leftBarButtonItem tap];
        });
        afterEach(^{
            stop_spying_on(bookmarksHomeViewController);
        });
        
        it(@"should show left bar button item", ^{
            subject.navigationItem.leftBarButtonItem should_not be_nil;
        });
        
        it(@"should have a single child controller", ^{
            subject.childViewControllers.count should equal(1);
        });
        
        it(@"should navigate to selectBookmarksViewController", ^{
            navigationController.topViewController should be_same_instance_as(bookmarksHomeViewController);
        });
    });

    describe(@"as a <ProjectPunchInControllerDelegate>", ^{
        __block PunchInController *punchInController;

        beforeEach(^{
            punchInController = nice_fake_for([PunchInController class]);
        });

        describe(@"receiving a punch in message", ^{
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block Activity *activity;
            __block NSArray *oefTypesArray;


            beforeEach(^{
                client = nice_fake_for([ClientType class]);
                project = nice_fake_for([ProjectType class]);
                task = nice_fake_for([TaskType class]);
                activity = nice_fake_for([Activity class]);
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                PunchCardObject *punchCardObject = nice_fake_for([PunchCardObject class]);
                punchCardObject stub_method(@selector(clientType)).and_return(client);
                punchCardObject stub_method(@selector(projectType)).and_return(project);
                punchCardObject stub_method(@selector(taskType)).and_return(task);
                punchCardObject stub_method(@selector(activity)).and_return(activity);
                punchCardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                [subject projectPunchInController:nil didIntendToPunchWithObject:punchCardObject];
            });

            it(@"should punch in on the punch clock", ^{
                punchClock should have_received(@selector(punchInWithPunchAssemblyWorkflowDelegate:clientType:projectType:taskType:activity:oefTypesArray:)).with(subject,client,project,task,activity,oefTypesArray);
            });

            context(@"when the user then finishes punching in or out", ^{

                beforeEach(^{
                    UIViewController *someController = [[UIViewController alloc] init];
                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).and_return(someController);

                    LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];


                    [subject punchAssemblyWorkflow:nil
               willEventuallyFinishIncompletePunch:punch
                             assembledPunchPromise:nil
                       serverDidFinishPunchPromise:nil];


                });

                it(@"should not ask the punch repository for the most recent punch when there are child controllers", ^{
                    [subject viewWillAppear:YES];
                    subject.childViewControllers.count should be_greater_than(0);
                    punchRepository should_not have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"some:user:uri");
                });
            });
        });
    });

    describe(@"as a <ProjectPunchOutControllerDelegate>", ^{
        __block ProjectPunchOutController *punchOutController;
        
        beforeEach(^{
            punchOutController = nice_fake_for([ProjectPunchOutController class]);
            
            [subject controllerDidPunchOut:punchOutController];
        });
        
        it(@"should punch out on the punch clock", ^{
            punchClock should have_received(@selector(punchOutWithPunchAssemblyWorkflowDelegate:oefData:)).with(subject, nil);
        });
        
        context(@"when the user then finishes punching in or out", ^{

            beforeEach(^{
                UIViewController *someController = [[UIViewController alloc] init];
                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).and_return(someController);
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                

                
                [subject punchAssemblyWorkflow:nil
           willEventuallyFinishIncompletePunch:punch
                         assembledPunchPromise:nil
                   serverDidFinishPunchPromise:nil];
                

            });
            
            it(@"should not ask the punch repository for the most recent punch when there are child controllers", ^{
                [subject viewWillAppear:YES];
                subject.childViewControllers.count should be_greater_than(0);
                punchRepository should_not have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"some:user:uri");
            });
            
        });
        
        describe(@"receiving a take a break message", ^{
            __block NSDate *breakDate;
            beforeEach(^{
                breakDate = [NSDate dateWithTimeIntervalSince1970:123];
                BreakType *breakType = [[BreakType alloc] initWithName:@"Break" uri:@"break-uri"];
                [subject projectPunchOutControllerDidTakeBreakWithDate:breakDate breakType:breakType];
            });
            
            it(@"should tell the punch clock the the user wants to take a break", ^{
                NSDate *expectedBreakDate = [NSDate dateWithTimeIntervalSince1970:123];
                BreakType *expectedBreakType = [[BreakType alloc] initWithName:@"Break" uri:@"break-uri"];
                punchClock should have_received(@selector(takeBreakWithBreakDate:breakType:punchAssemblyWorkflowDelegate:)).with(expectedBreakDate,
                                                                                                                                 expectedBreakType,
                                                                                                                                 subject);
            });
        });
        
        context(@"projectPunchOutControllerDidTransfer:", ^{
            context(@"punch into activity flow", ^{
                context(@"When oef enabled", ^{
                    __block NSArray *oefTypesArray;
                    __block OEFCollectionPopUpViewController *oefCollectionPopUpViewController;
                    __block UINavigationController *navigationController;
                    beforeEach(^{
                        OEFType *oefType1 = nice_fake_for([OEFType class]);
                        OEFType *oefType2 = nice_fake_for([OEFType class]);
                        oefTypesArray = @[oefType1,oefType2];
                        
                        oefTypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).with(PunchActionTypeTransfer).and_return(oefTypesArray);
                        
                        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                        oefCollectionPopUpViewController = [[OEFCollectionPopUpViewController alloc]
                                                            initWithChildControllerHelper:nil
                                                            nsNotificationCenter:nil
                                                            oefTypeStorage:nil
                                                            uiApplication:nil
                                                            userSession:nil
                                                            theme:nil];
                        [injector bind:[OEFCollectionPopUpViewController class] toInstance:oefCollectionPopUpViewController];
                        
                        spy_on(oefCollectionPopUpViewController);
                        spy_on(navigationController);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        
                        [subject projectPunchOutControllerDidTransfer:nil];
                    });
                    afterEach(^{
                        stop_spying_on(oefCollectionPopUpViewController);
                        stop_spying_on(navigationController);
                    });
                    
                    it(@"should navigate to OEFCollectionPopUpViewController", ^{
                        oefCollectionPopUpViewController should have_received(@selector(setupWithOEFCollectionPopUpViewControllerDelegate:punchActionType:)).with(subject,PunchActionTypeTransfer);
                        
                        navigationController.topViewController should be_same_instance_as(oefCollectionPopUpViewController);
                    });
                    
                    it(@"should have correctly push OEFCollectionPopUpViewController", ^{
                        navigationController should have_received(@selector(pushViewController:animated:)).with(oefCollectionPopUpViewController,YES);
                    });
                });
                
                context(@"When oef not enabled", ^{
                    __block UINavigationController *navigationController;
                    __block SelectionController <CedarDouble>*selectionController;
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        
                        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                        
                        selectionController = (id) [[SelectionController alloc] initWithProjectStorage:NULL expenseProjectStorage:NULL timerProvider:nil userDefaults:nil theme:nil];
                        
                        [injector bind:InjectorKeySelectionControllerForPunchModule toInstance:selectionController];
                        spy_on(selectionController);
                        [subject projectPunchOutControllerDidTransfer:nil];
                    });
                    afterEach(^{
                        stop_spying_on(selectionController);
                    });
                    
                    it(@"should navigate to selectionController", ^{
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ActivitySelection,nil,subject);
                        
                        navigationController.topViewController should be_same_instance_as(selectionController);
                    });
                });
            });
            
            context(@"punch into project flow", ^{
                __block AllPunchCardController *expectedAllPunchCardController;
                __block UINavigationController *navigationController;
                beforeEach(^{
                    PunchCardObject *punch1, *punch2;
                    punch1 = nice_fake_for([PunchCardObject class]);
                    punch2 = nice_fake_for([PunchCardObject class]);
                    punchCardStorage stub_method(@selector(getPunchCardsExcludingPunch:)).and_return(@[punch1, punch2]);
                    
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    expectedAllPunchCardController = [[AllPunchCardController alloc]
                                                      initWithPunchImagePickerControllerProvider:nil
                                                      transferPunchCardController:nil
                                                      allowAccessAlertHelper:nil
                                                      childControllerHelper:nil
                                                      nsNotificationCenter:nil
                                                      punchCardStylist:nil
                                                      imageNormalizer:nil
                                                      oefTypeStorage:nil
                                                      punchClock:nil];
                    [injector bind:[AllPunchCardController class] toInstance:expectedAllPunchCardController];
                    
                    spy_on(expectedAllPunchCardController);
                    
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    [subject projectPunchOutControllerDidTransfer:nil];
                });
                afterEach(^{
                    stop_spying_on(expectedAllPunchCardController);
                });
                
                it(@"should navigate to AllPunchCardController", ^{
                    expectedAllPunchCardController should have_received(@selector(setUpWithDelegate:controllerType:punchCardObject:flowType:)).with(subject,TransferPunchCardsControllerType, nil, TransferWorkFlowType);
                    
                    navigationController.topViewController should be_same_instance_as(expectedAllPunchCardController);
                });
            });
        });
    });

    describe(@"as a <ProjectOnBreakControllerDelegate>", ^{

        describe(@"-projectonBreakControllerDidResumeWork:", ^{
            __block ProjectOnBreakController *onBreakController;
            __block AllPunchCardController *expectedAllPunchCardController;
            __block UINavigationController *navigationController;

            context(@"When there is a previous most recent punch, then should do transfer", ^{
                __block id <Punch> mostRecentPunchIn;
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                __block NSArray *oefTypesArray;
                __block PunchCardObject *card;
                beforeEach(^{
                    onBreakController = nice_fake_for([ProjectOnBreakController class]);
                    mostRecentPunchIn = nice_fake_for(@protocol(Punch));
                    mostRecentPunchIn stub_method(@selector(client)).and_return(client);
                    mostRecentPunchIn stub_method(@selector(project)).and_return(project);
                    mostRecentPunchIn stub_method(@selector(task)).and_return(task);
                    
                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    oefTypesArray = @[oefType1,oefType2];
                    mostRecentPunchIn stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    
                    mostRecentPunchInDetector stub_method(@selector(mostRecentPunchIn)).and_return(mostRecentPunchIn);
                    
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    expectedAllPunchCardController = [[AllPunchCardController alloc]
                                                      initWithPunchImagePickerControllerProvider:nil
                                                      transferPunchCardController:nil
                                                      allowAccessAlertHelper:nil
                                                      childControllerHelper:nil
                                                      nsNotificationCenter:nil
                                                      punchCardStylist:nil
                                                      imageNormalizer:nil
                                                      oefTypeStorage:nil
                                                      punchClock:nil];
                    [injector bind:[AllPunchCardController class] toInstance:expectedAllPunchCardController];

                    spy_on(expectedAllPunchCardController);

                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                    card = [[PunchCardObject alloc] initWithClientType:mostRecentPunchIn.client projectType:mostRecentPunchIn.project oefTypesArray:mostRecentPunchIn.oefTypesArray breakType:mostRecentPunchIn.breakType taskType:mostRecentPunchIn.task activity:mostRecentPunchIn.activity uri:nil];

                    [subject projectonBreakControllerDidResumeWork:onBreakController];
                });
                afterEach(^{
                    stop_spying_on(expectedAllPunchCardController);
                });
                
                it(@"should navigate to AllPunchCardController", ^{
                    expectedAllPunchCardController should have_received(@selector(setUpWithDelegate:controllerType:punchCardObject:flowType:)).with(subject,TransferPunchCardsControllerType, card, ResumeWorkFlowType);

                    navigationController.topViewController should be_same_instance_as(expectedAllPunchCardController);
                });

                context(@"when the user then finishes all the required actions for the punch", ^{
                    __block KSPromise *assembledPunchPromise;
                    __block LocalPunch *incompleteTransferPunch;
                    beforeEach(^{
                        assembledPunchPromise = nice_fake_for([KSPromise class]);
                        UIViewController *someController = [[UIViewController alloc] init];
                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).and_return(someController);
                        incompleteTransferPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                    });
                    
                    context(@"when the punch will eventuall be finished", ^{
                        beforeEach(^{

                            [subject punchAssemblyWorkflow:nil
                       willEventuallyFinishIncompletePunch:incompleteTransferPunch
                                     assembledPunchPromise:assembledPunchPromise
                               serverDidFinishPunchPromise:serverPromise];
                            
                        });
                        
                        it(@"should not ask the punch repository for the most recent punch when there are child controllers", ^{
                            [subject viewWillAppear:YES];
                            subject.childViewControllers.count should be_greater_than(0);
                            punchRepository should_not have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"some:user:uri");
                        });
                        
                        it(@"should send the correct arguments to the punch out controller provider", ^{
                            punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                            .with(subject, serverPromise, assembledPunchPromise,nil, incompleteTransferPunch,nil);
                        });
                    });
                    
                });
            });
            
            context(@"When there is a previous most recent punch, then should do resume with already clocked in activity", ^{
                __block id <Punch> mostRecentPunch;
                __block Activity *activity;
                __block UINavigationController *navigationController;
                __block OEFCollectionPopUpViewController *oefCollectionPopUpViewController;
                __block PunchCardObject *card;

                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    
                    onBreakController = nice_fake_for([ProjectOnBreakController class]);
                    mostRecentPunch = nice_fake_for(@protocol(Punch));
                    mostRecentPunch stub_method(@selector(activity)).and_return(activity);

                    mostRecentActivityPunchDetector stub_method(@selector(mostRecentActivityPunch)).and_return(mostRecentPunch);

                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    oefCollectionPopUpViewController = [[OEFCollectionPopUpViewController alloc]
                                                        initWithChildControllerHelper:nil
                                                        nsNotificationCenter:nil
                                                        oefTypeStorage:nil
                                                        uiApplication:nil
                                                        userSession:nil
                                                        theme:nil];
                    [injector bind:[OEFCollectionPopUpViewController class] toInstance:oefCollectionPopUpViewController];

                    spy_on(oefCollectionPopUpViewController);
                    spy_on(navigationController);

                    card = [[PunchCardObject alloc] initWithClientType:mostRecentPunch.client projectType:mostRecentPunch.project oefTypesArray:mostRecentPunch.oefTypesArray breakType:mostRecentPunch.breakType taskType:mostRecentPunch.task activity:mostRecentPunch.activity uri:nil];
                    
                    [subject projectonBreakControllerDidResumeWork:onBreakController];
                });
                afterEach(^{
                    stop_spying_on(oefCollectionPopUpViewController);
                    stop_spying_on(navigationController);
                });
                
                it(@"should navigate to OEFCollectionPopUpViewController", ^{
                    oefCollectionPopUpViewController should have_received(@selector(setupWithOEFCollectionPopUpViewControllerDelegate:punchActionType:)).with(subject,PunchActionTypeResumeWork);

                    navigationController.topViewController should be_same_instance_as(oefCollectionPopUpViewController);
                });

                it(@"should have correctly push OEFCollectionPopUpViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(oefCollectionPopUpViewController,YES);
                });

                context(@"when the user then finishes all the required actions for the punch", ^{
                    __block KSPromise *assembledPunchPromise;
                    __block LocalPunch *incompleteTransferPunch;
                    beforeEach(^{
                        assembledPunchPromise = nice_fake_for([KSPromise class]);
                        UIViewController *someController = [[UIViewController alloc] init];
                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).and_return(someController);
                        incompleteTransferPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                    });
                    
                    context(@"when the punch will eventuall be finished", ^{

                        beforeEach(^{

                            
                            [subject punchAssemblyWorkflow:nil
                       willEventuallyFinishIncompletePunch:incompleteTransferPunch
                                     assembledPunchPromise:assembledPunchPromise
                               serverDidFinishPunchPromise:serverPromise];

                        });
                        
                        it(@"should not ask the punch repository for the most recent punch when there are child controllers", ^{
                            [subject viewWillAppear:YES];
                            subject.childViewControllers.count should be_greater_than(0);
                            punchRepository should_not have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"some:user:uri");
                        });
                        
                        it(@"should send the correct arguments to the punch out controller provider", ^{
                            punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                            .with(subject, serverPromise, assembledPunchPromise,nil, incompleteTransferPunch, nil);
                        });
                    });
                });
            });

            context(@"When there is a previous most recent punch and when the punch is invalid", ^{
                __block id <Punch> mostRecentPunch;
                __block ProjectType *project;
                __block ClientType *client;
                __block TaskType *task;
                __block UINavigationController *navigationController;
                __block PunchCardObject *card;
                __block AllPunchCardController *expectedAllPunchCardController;

                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                    onBreakController = nice_fake_for([ProjectOnBreakController class]);
                    mostRecentPunch = nice_fake_for(@protocol(Punch));
                    mostRecentPunch stub_method(@selector(project)).and_return(project);
                    mostRecentPunch stub_method(@selector(client)).and_return(client);
                    mostRecentPunch stub_method(@selector(task)).and_return(task);
                    mostRecentPunch stub_method(@selector(isTimeEntryAvailable)).and_return(NO);

                    mostRecentPunchInDetector stub_method(@selector(mostRecentPunchIn)).and_return(mostRecentPunch);

                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    expectedAllPunchCardController = [[AllPunchCardController alloc]
                                                      initWithPunchImagePickerControllerProvider:nil
                                                      transferPunchCardController:nil
                                                      allowAccessAlertHelper:nil
                                                      childControllerHelper:nil
                                                      nsNotificationCenter:nil
                                                      punchCardStylist:nil
                                                      imageNormalizer:nil
                                                      oefTypeStorage:nil
                                                      punchClock:nil];
                    [injector bind:[AllPunchCardController class] toInstance:expectedAllPunchCardController];

                    spy_on(expectedAllPunchCardController);

                    card = [[PunchCardObject alloc] initWithClientType:nil projectType:nil oefTypesArray:mostRecentPunch.oefTypesArray breakType:mostRecentPunch.breakType taskType:nil activity:nil uri:nil];

                    [subject projectonBreakControllerDidResumeWork:onBreakController];
                });
                afterEach(^{
                    stop_spying_on(expectedAllPunchCardController);
                });

                it(@"should navigate to AllPunchCardController with empty punchcard object", ^{
                    expectedAllPunchCardController should have_received(@selector(setUpWithDelegate:controllerType:punchCardObject:flowType:)).with(subject,TransferPunchCardsControllerType, card, ResumeWorkFlowType);

                    navigationController.topViewController should be_same_instance_as(expectedAllPunchCardController);
                });
            });

            context(@"When there is a previous most recent punch and when the punch is valid", ^{
                __block id <Punch> mostRecentPunch;
                __block ProjectType *project;
                __block ClientType *client;
                __block TaskType *task;
                __block UINavigationController *navigationController;
                __block PunchCardObject *card;
                __block AllPunchCardController *expectedAllPunchCardController;

                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                    onBreakController = nice_fake_for([ProjectOnBreakController class]);
                    mostRecentPunch = nice_fake_for(@protocol(Punch));
                    mostRecentPunch stub_method(@selector(project)).and_return(project);
                    mostRecentPunch stub_method(@selector(client)).and_return(client);
                    mostRecentPunch stub_method(@selector(task)).and_return(task);
                    mostRecentPunch stub_method(@selector(isTimeEntryAvailable)).and_return(YES);

                    mostRecentPunchInDetector stub_method(@selector(mostRecentPunchIn)).and_return(mostRecentPunch);

                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    expectedAllPunchCardController = [[AllPunchCardController alloc]
                                                      initWithPunchImagePickerControllerProvider:nil
                                                      transferPunchCardController:nil
                                                      allowAccessAlertHelper:nil
                                                      childControllerHelper:nil
                                                      nsNotificationCenter:nil
                                                      punchCardStylist:nil
                                                      imageNormalizer:nil
                                                      oefTypeStorage:nil
                                                      punchClock:nil];
                    [injector bind:[AllPunchCardController class] toInstance:expectedAllPunchCardController];

                    spy_on(expectedAllPunchCardController);

                    card = [[PunchCardObject alloc] initWithClientType:mostRecentPunch.client projectType:mostRecentPunch.project oefTypesArray:mostRecentPunch.oefTypesArray breakType:mostRecentPunch.breakType taskType:mostRecentPunch.task activity:mostRecentPunch.activity uri:nil];

                    [subject projectonBreakControllerDidResumeWork:onBreakController];
                });
                afterEach(^{
                    stop_spying_on(expectedAllPunchCardController);
                });

                it(@"should navigate to AllPunchCardController with complete punchcard object", ^{
                    expectedAllPunchCardController should have_received(@selector(setUpWithDelegate:controllerType:punchCardObject:flowType:)).with(subject,TransferPunchCardsControllerType, card, ResumeWorkFlowType);

                    navigationController.topViewController should be_same_instance_as(expectedAllPunchCardController);
                });
            });

            context(@"When there is no previous most recent punch, then should navigate to transfer screen", ^{
                context(@"When there is no previous most recent punch, then should navigate to client/project/task trasnfer screen", ^{
                    __block AllPunchCardController *expectedAllPunchCardController;
                    __block UINavigationController *navigationController;
                    beforeEach(^{
                        PunchCardObject *punch1, *punch2;
                        punch1 = nice_fake_for([PunchCardObject class]);
                        punch2 = nice_fake_for([PunchCardObject class]);
                        punchCardStorage stub_method(@selector(getPunchCardsExcludingPunch:)).and_return(@[punch1, punch2]);

                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                        expectedAllPunchCardController = [[AllPunchCardController alloc]
                                                          initWithPunchImagePickerControllerProvider:nil
                                                          transferPunchCardController:nil
                                                          allowAccessAlertHelper:nil
                                                          childControllerHelper:nil
                                                          nsNotificationCenter:nil
                                                          punchCardStylist:nil
                                                          imageNormalizer:nil
                                                          oefTypeStorage:nil
                                                          punchClock:nil];
                        [injector bind:[AllPunchCardController class] toInstance:expectedAllPunchCardController];
                        
                        spy_on(expectedAllPunchCardController);
                        
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        
                        [subject projectonBreakControllerDidResumeWork:onBreakController];
                    });
                    afterEach(^{
                        stop_spying_on(expectedAllPunchCardController);
                    });
                    
                    it(@"should navigate to AllPunchCardController", ^{
                        expectedAllPunchCardController should have_received(@selector(setUpWithDelegate:controllerType:punchCardObject:flowType:)).with(subject,TransferPunchCardsControllerType, nil, TransferWorkFlowType);
                        
                        navigationController.topViewController should be_same_instance_as(expectedAllPunchCardController);
                    });
                });
                context(@"When there is no previous most recent punch, then should navigate to activity trasnfer screen", ^{
                    __block UINavigationController *navigationController;
                    __block SelectionController <CedarDouble>*selectionController;
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        
                        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                        
                        selectionController = (id) [[SelectionController alloc] initWithProjectStorage:NULL expenseProjectStorage:NULL timerProvider:nil userDefaults:nil theme:nil];
                        
                        [injector bind:InjectorKeySelectionControllerForPunchModule toInstance:selectionController];
                        spy_on(selectionController);
                        [subject projectonBreakControllerDidResumeWork:onBreakController];
                    });
                    afterEach(^{
                        stop_spying_on(selectionController);
                    });
                    
                    
                    it(@"should navigate to selectionController", ^{
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ActivitySelection,nil,subject);
                        
                        navigationController.topViewController should be_same_instance_as(selectionController);
                    });
                });
            });
            
            context(@"When user is simple punch user with no oef's enabled for resume action", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                        [subject projectonBreakControllerDidResumeWork:onBreakController];
                    });
                    
                    it(@"should intiate the  transfer activity action through punch clock ", ^{
                        punchClock should have_received(@selector(resumeWorkWithPunchAssemblyWorkflowDelegate:oefData:)).with(subject, nil);
                    });
            });

            
            context(@"When oef enabled", ^{
                __block NSArray *oefTypesArray;
                __block OEFCollectionPopUpViewController *oefCollectionPopUpViewController;
                __block UINavigationController *navigationController;
                beforeEach(^{
                    OEFType *oefType1 = nice_fake_for([OEFType class]);
                    OEFType *oefType2 = nice_fake_for([OEFType class]);
                    oefTypesArray = @[oefType1,oefType2];
                    
                    oefTypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).with(PunchActionTypeTransfer).and_return(oefTypesArray);
                    
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    oefCollectionPopUpViewController = [[OEFCollectionPopUpViewController alloc]
                                                        initWithChildControllerHelper:nil
                                                        nsNotificationCenter:nil
                                                        oefTypeStorage:nil
                                                        uiApplication:nil
                                                        userSession:nil
                                                        theme:nil];
                    [injector bind:[OEFCollectionPopUpViewController class] toInstance:oefCollectionPopUpViewController];
                    
                    spy_on(oefCollectionPopUpViewController);
                    spy_on(navigationController);
                    [subject projectonBreakControllerDidResumeWork:nil];
                });
                afterEach(^{
                    stop_spying_on(oefCollectionPopUpViewController);
                    stop_spying_on(navigationController);
                });
                
                it(@"should navigate to OEFCollectionPopUpViewController", ^{
                    oefCollectionPopUpViewController should have_received(@selector(setupWithOEFCollectionPopUpViewControllerDelegate:punchActionType:)).with(subject,PunchActionTypeResumeWork);
                    
                    navigationController.topViewController should be_same_instance_as(oefCollectionPopUpViewController);
                });
                
                it(@"should have correctly push OEFCollectionPopUpViewController", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(oefCollectionPopUpViewController,YES);
                });
            });
        });

        describe(@"-projectPunchOutControllerDidTakeBreakWithDate:breakType:", ^{
            context(@"when oef is not enabled for break punch", ^{
                __block NSDate *breakDate;
                beforeEach(^{
                    breakDate = [NSDate dateWithTimeIntervalSince1970:123];
                    BreakType *breakType = [[BreakType alloc] initWithName:@"Break" uri:@"break-uri"];
                    [subject projectPunchOutControllerDidTakeBreakWithDate:breakDate breakType:breakType];
                });
                
                it(@"should tell the punch clock the the user wants to take a break", ^{
                    NSDate *expectedBreakDate = [NSDate dateWithTimeIntervalSince1970:123];
                    BreakType *expectedBreakType = [[BreakType alloc] initWithName:@"Break" uri:@"break-uri"];
                    punchClock should have_received(@selector(takeBreakWithBreakDate:breakType:punchAssemblyWorkflowDelegate:)).with(expectedBreakDate,
                                                                                                                                     expectedBreakType,
                                                                                                                                     subject);
                });
            });
        });
        
        context(@"when oef's enabled", ^{
            __block NSArray *oefTypesArray;
            __block OEFCollectionPopUpViewController *oefCollectionPopUpViewController;
            __block UINavigationController *navigationController;
            beforeEach(^{
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                oefTypesArray = @[oefType1,oefType2];
                
                oefTypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).with(PunchActionTypeStartBreak).and_return(oefTypesArray);
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                oefCollectionPopUpViewController = [[OEFCollectionPopUpViewController alloc]
                                                    initWithChildControllerHelper:nil
                                                    nsNotificationCenter:nil
                                                    oefTypeStorage:nil
                                                    uiApplication:nil
                                                    userSession:nil
                                                    theme:nil];
                [injector bind:[OEFCollectionPopUpViewController class] toInstance:oefCollectionPopUpViewController];
                
                spy_on(oefCollectionPopUpViewController);
                spy_on(navigationController);
                [subject projectPunchOutControllerDidTakeBreak];
            });
            afterEach(^{
                stop_spying_on(oefCollectionPopUpViewController);
                stop_spying_on(navigationController);
            });
            
            it(@"should navigate to OEFCollectionPopUpViewController", ^{
                oefCollectionPopUpViewController should have_received(@selector(setupWithOEFCollectionPopUpViewControllerDelegate:punchActionType:)).with(subject,PunchActionTypeStartBreak);
                
                navigationController.topViewController should be_same_instance_as(oefCollectionPopUpViewController);
            });
            
            it(@"should have correctly push OEFCollectionPopUpViewController", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(oefCollectionPopUpViewController,YES);
            });
        });
    });

    describe(@"as a <ProjectPunchOutControllerDelegate> when oef is required on punchout ", ^{
        __block NSArray *oefTypesArray;
        __block OEFCollectionPopUpViewController *oefCollectionPopUpViewController;
        __block UINavigationController *navigationController;
        beforeEach(^{
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];

            oefTypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            oefCollectionPopUpViewController = [[OEFCollectionPopUpViewController alloc]
                                                initWithChildControllerHelper:nil
                                                nsNotificationCenter:nil
                                                oefTypeStorage:nil
                                                uiApplication:nil
                                                userSession:nil
                                                theme:nil];
            [injector bind:[OEFCollectionPopUpViewController class] toInstance:oefCollectionPopUpViewController];

            spy_on(oefCollectionPopUpViewController);
            spy_on(navigationController);
            [subject controllerDidPunchOut:nil];

        });
        afterEach(^{
            stop_spying_on(oefCollectionPopUpViewController);
            stop_spying_on(navigationController);
        });

        it(@"should navigate to OEFCollectionPopUpViewController", ^{
            oefCollectionPopUpViewController should have_received(@selector(setupWithOEFCollectionPopUpViewControllerDelegate:punchActionType:)).with(subject,PunchActionTypePunchOut);

            navigationController.topViewController should be_same_instance_as(oefCollectionPopUpViewController);
        });
        
        it(@"should have correctly push OEFCollectionPopUpViewController", ^{
            navigationController should have_received(@selector(pushViewController:animated:)).with(oefCollectionPopUpViewController,YES);
        });
    });

    describe(@"as a <PunchAssemblyWorkflowDelegate>", ^{

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
            __block PunchInController *punchInController;
            __block PunchOutController *punchOutController;
            __block LocalPunch *fakePunch1;
            __block LocalPunch *fakePunch2;
            
            context(@"when the most recent punch and timeline punches doesn't matches", ^{
                beforeEach(^{
                    [subject view];
                    [subject viewWillAppear:YES];
                    
                    punchInController = subject.childViewControllers.firstObject;
                    punchOutController = (id)[[UIViewController alloc] init];
                    
                    spy_on(punchInController);
                    spy_on(punchOutController);
                    
                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).and_return(punchOutController);

                    fakePunch1 = nice_fake_for([LocalPunch class]);
                    fakePunch2 = nice_fake_for([LocalPunch class]);


                    timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[fakePunch2]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[fakePunch1,fakePunch2]);
                    
                    workflow = nice_fake_for([PunchAssemblyWorkflow class]);

                    
                    
                    incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];
                    
                    assembledPunchPromise = nice_fake_for([KSPromise class]);

                    
                    [subject punchAssemblyWorkflow:workflow
               willEventuallyFinishIncompletePunch:incompletePunch
                             assembledPunchPromise:assembledPunchPromise
                       serverDidFinishPunchPromise:serverPromise];

                });
                
                afterEach(^{
                    stop_spying_on(punchInController);
                    stop_spying_on(punchOutController);
                    punchInController = nil;
                    punchOutController = nil;

                });
                
                it(@"should have a single child controller", ^{
                    subject.childViewControllers.count should equal(1);
                });
                
                it(@"should make the punch out controller a child controller", ^{
                    subject.childViewControllers.firstObject should be_same_instance_as(punchOutController);
                });
                
                it(@"should always call the punch out controller provider with the correct arguments", ^{
                    punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                    .with(subject, serverPromise, assembledPunchPromise,nil, incompletePunch, nil);
                });
                
                it(@"should size the child view controllers's frame appropriately", ^{
                    [subject viewWillAppear:YES];
                    
                    CGRect childControllerViewFrame = [subject.childViewControllers.firstObject view].frame;
                    childControllerViewFrame.origin.x should equal(0);
                    childControllerViewFrame.origin.y should equal(0);
                    childControllerViewFrame.size.width should equal(subject.view.bounds.size.width);
                    childControllerViewFrame.size.height should equal(subject.view.bounds.size.height);
                });
                
                it(@"should tell the punch in controller that it will move to parent controller", ^{
                    punchInController should have_received(@selector(willMoveToParentViewController:)).with(nil);
                });
                
                it(@"should tell the punch out controller that it did move to parent controller", ^{
                    punchOutController should have_received(@selector(didMoveToParentViewController:)).with(subject);
                });

                it(@"should update most recent punch", ^{
                    subject.mostRecentPunch should equal(incompletePunch);
                });

                it(@"should update timeline punches", ^{
                    subject.timelinePunches should equal(@[fakePunch2]);
                });

                it(@"first time user should be falsy", ^{
                    subject.firstTimeUser should be_falsy;
                });
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

    describe(@"as an<UIImagePickerControllerDelegate>", ^{

        __block KSPromise *imagePromise;

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

    describe(@"As a <AllPunchCardControllerDelegate>", ^{

        context(@"-allPunchCardController:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:", ^{

            __block UIViewController *punchController;

            beforeEach(^{

                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);

                punchController = [[UIViewController alloc] init];
                spy_on(punchController);

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .and_return(punchController);
            });
            afterEach(^{
                stop_spying_on(punchController);
            });

            context(@"when punch is assembled", ^{
                __block PunchAssemblyWorkflow *workflow;
                __block LocalPunch *incompletePunch;
                __block KSPromise *assembledPunchPromise;
                __block PunchInController *punchInController;
                __block PunchOutController *punchOutController;

                NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:0];

                beforeEach(^{
                    [subject view];
                    [subject viewWillAppear:YES];

                    punchInController = subject.childViewControllers.firstObject;
                    punchOutController = (id)[[UIViewController alloc] init];

                    spy_on(punchInController);
                    spy_on(punchOutController);

                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:)).again().and_return(punchOutController);

                    workflow = nice_fake_for([PunchAssemblyWorkflow class]);

                    incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];

                    assembledPunchPromise = nice_fake_for([KSPromise class]);


                    [subject punchAssemblyWorkflow:workflow
               willEventuallyFinishIncompletePunch:incompletePunch
                             assembledPunchPromise:assembledPunchPromise
                       serverDidFinishPunchPromise:serverPromise];


                });

                afterEach(^{
                    stop_spying_on(punchInController);
                    stop_spying_on(punchOutController);
                    punchInController = nil;
                    punchOutController = nil;

                });

                it(@"should have a single child controller", ^{
                    subject.childViewControllers.count should equal(1);
                });

                it(@"should make the punch out controller a child controller", ^{
                    subject.childViewControllers.firstObject should be_same_instance_as(punchOutController);
                });

                it(@"should always call the punch out controller provider with the correct arguments", ^{
                    punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                    .with(subject, serverPromise, assembledPunchPromise,nil, incompletePunch, nil);
                });

                it(@"should size the child view controllers's frame appropriately", ^{
                    [subject viewWillAppear:YES];

                    CGRect childControllerViewFrame = [subject.childViewControllers.firstObject view].frame;
                    childControllerViewFrame.origin.x should equal(0);
                    childControllerViewFrame.origin.y should equal(0);
                    childControllerViewFrame.size.width should equal(subject.view.bounds.size.width);
                    childControllerViewFrame.size.height should equal(subject.view.bounds.size.height);
                });
                
                it(@"should tell the punch in controller that it will move to parent controller", ^{
                    punchInController should have_received(@selector(willMoveToParentViewController:)).with(nil);
                });
                
                it(@"should tell the punch out controller that it did move to parent controller", ^{
                    punchOutController should have_received(@selector(didMoveToParentViewController:)).with(subject);
                });

            });

        });

    });

    describe(@"As a <SelectionControllerDelegate>", ^{

        context(@"selectionController:didChooseActivity:", ^{

            context(@"with valid activity", ^{
                __block Activity *activity;
                beforeEach(^{
                    activity = nice_fake_for([Activity class]);
                    activity stub_method(@selector(name)).and_return(@"activity-name");
                    activity stub_method(@selector(uri)).and_return(@"activity-uri");
                    [subject selectionController:nil didChooseActivity:activity];

                });

                it(@"should intiate the  transfer activity action through punch clock ", ^{
                    punchClock should have_received(@selector(resumeWorkWithActivityAssemblyWorkflowDelegate:activity:oefTypesArray:)).with(subject,activity,nil);
                });
            });

            context(@"with none activity", ^{
                __block Activity *activity;
                beforeEach(^{
                    activity = nice_fake_for([Activity class]);
                    [subject selectionController:nil didChooseActivity:activity];

                });

                it(@"should intiate the  transfer activity action through punch clock ", ^{
                    punchClock should have_received(@selector(resumeWorkWithActivityAssemblyWorkflowDelegate:activity:oefTypesArray:)).with(subject,nil,nil);
                });
            });

        });

        context(@"selectionControllerNeedsClientProjectTaskRepository", ^{
            __block id <ClientProjectTaskRepository> clientProjectTaskRepository;
            __block ClientRepository *clientRepository;
            __block ProjectRepository *projectRepository;
            __block TaskRepository *taskRepository;
            __block ActivityRepository *activityRepository;


            context(@"clientProjectTaskRepository should have", ^{
                beforeEach(^{
                    clientRepository = nice_fake_for([ClientRepository class]);
                    projectRepository = nice_fake_for([ProjectRepository class]);
                    taskRepository = nice_fake_for([TaskRepository class]);
                    activityRepository = nice_fake_for([ActivityRepository class]);

                    [injector bind:[ClientRepository class] toInstance:clientRepository];
                    [injector bind:[ProjectRepository class] toInstance:projectRepository];
                    [injector bind:[TaskRepository class] toInstance:taskRepository];
                    [injector bind:[ActivityRepository class] toInstance:activityRepository];

                    clientProjectTaskRepository = [subject selectionControllerNeedsClientProjectTaskRepository];

                    
                });

                it(@" correct instances ", ^{
                    [clientProjectTaskRepository clientRepository] should be_same_instance_as(clientRepository);
                    [clientProjectTaskRepository projectRepository] should be_same_instance_as(projectRepository);
                    [clientProjectTaskRepository taskRepository] should be_same_instance_as(taskRepository);
                    [clientProjectTaskRepository activityRepository] should be_same_instance_as(activityRepository);
                });
            });

            context(@"clientProjectTaskRepository instances should have ", ^{
                beforeEach(^{

                    clientProjectTaskRepository = [subject selectionControllerNeedsClientProjectTaskRepository];

                });

                it(@" correct user uri", ^{
                    clientRepository = (ClientRepository *)[clientProjectTaskRepository clientRepository];
                    clientRepository.userUri should equal(@"some:user:uri");

                    projectRepository = (ProjectRepository *)[clientProjectTaskRepository projectRepository];
                    projectRepository.userUri should equal(@"some:user:uri");

                    taskRepository = (TaskRepository *)[clientProjectTaskRepository taskRepository];
                    taskRepository.userUri should equal(@"some:user:uri");

                    activityRepository = (ActivityRepository *)[clientProjectTaskRepository activityRepository];
                    activityRepository.userUri should equal(@"some:user:uri");
                });
            });


        });

    });

    describe(@"OEFCollectionPopUpViewControllerDelegate", ^{
        __block NSArray *oefTypesArray;
        __block PunchCardObject *punchCardObject;
        __block BreakType *breakeType;
        __block Activity *activityType;
        beforeEach(^{
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            oefTypesArray = @[oefType1,oefType2];
            
            breakeType = nice_fake_for([BreakType class]);
            activityType =  [[Activity alloc] initWithName:@"activity:name" uri:@"activity:uri"];
            punchCardObject = nice_fake_for([PunchCardObject class]);
            punchCardObject stub_method(@selector(breakType)).and_return(breakeType);
            punchCardObject stub_method(@selector(activity)).and_return(activityType);
            punchCardObject stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

        });
        
        context(@"when punch action type is out ", ^{
            beforeEach(^{
                [subject oefCollectionPopUpViewController:nil didIntendToUpdate:punchCardObject punchActionType:PunchActionTypePunchOut];
            });

            it(@"should punch with oefdata", ^{
                punchClock should have_received(@selector(punchOutWithPunchAssemblyWorkflowDelegate:oefData:)).with(subject,oefTypesArray);
            });
        });
        
        context(@"when punch action type is break ", ^{
            beforeEach(^{
                [subject oefCollectionPopUpViewController:nil didIntendToUpdate:punchCardObject punchActionType:PunchActionTypeStartBreak];
            });

            it(@"should punch with oefdata", ^{
                punchClock should have_received(@selector(takeBreakWithBreakDateAndOEF:breakType:oefData:punchAssemblyWorkflowDelegate:)).with(expectedDate, punchCardObject.breakType, punchCardObject.oefTypesArray, subject);
            });
        });
        
        context(@"when punch action type is resume work ", ^{
            context(@"punch into activity flow", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    [subject oefCollectionPopUpViewController:nil didIntendToUpdate:punchCardObject punchActionType:PunchActionTypeResumeWork];
                });
                
                it(@"should punch with oefdata", ^{
                    punchClock should have_received(@selector(resumeWorkWithActivityAssemblyWorkflowDelegate:activity:oefTypesArray:)).with(subject, activityType, punchCardObject.oefTypesArray);
                });
            });
            
            context(@"punch into project flow", ^{
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                __block PunchCardObject *punchCard;
                beforeEach(^{
                    client = nice_fake_for([ClientType class]);
                    project = nice_fake_for([ProjectType class]);
                    task = nice_fake_for([TaskType class]);
                    
                    punchCard = [[PunchCardObject alloc] initWithClientType:client projectType:project oefTypesArray:oefTypesArray breakType:nil taskType:task activity:nil uri:nil];

                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    [subject oefCollectionPopUpViewController:nil didIntendToUpdate:punchCard punchActionType:PunchActionTypeResumeWork];
                });
                
                it(@"should punch with oefdata", ^{
                    punchClock should have_received(@selector(resumeWorkWithPunchProjectAssemblyWorkflowDelegate:clientType:projectType:taskType:oefTypesArray:)).with(subject, client, project, task, oefTypesArray);
                });
            });

        });

    });

    describe(@"left and right navigation bar items", ^{
        __block RemotePunch *punch;
        context(@"-punch into projects", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);

                punch = fake_for([RemotePunch class]);
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(syncedWithServer)).and_return(YES);

                KSPromise *fetchMostRecentPunchForUserUriPromise = [[KSPromise alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriPromise);

                subject.view should_not be_nil;
                [subject viewWillAppear:YES];

                UIViewController *punchController = [[UIViewController alloc] init];

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .with(subject, nil, nil, nil,punch, nil)
                .and_return(punchController);

                [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];
            });

            it(@"should have correct left navigation item", ^{
                subject.navigationItem.leftBarButtonItem should_not be_nil;
            });
        });

        context(@"-punch into activities", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                punch = fake_for([RemotePunch class]);
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(syncedWithServer)).and_return(YES);

                KSPromise *fetchMostRecentPunchForUserUriPromise = [[KSPromise alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriPromise);

                subject.view should_not be_nil;
                [subject viewWillAppear:YES];

                UIViewController *punchController = [[UIViewController alloc] init];

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .with(subject, nil, nil, nil,punch, nil)
                .and_return(punchController);

                [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];
            });

            it(@"should have correct left navigation item", ^{
                subject.navigationItem.leftBarButtonItem should be_nil;
            });
        });

        context(@"-simple punch with oef", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                punch = fake_for([RemotePunch class]);
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(syncedWithServer)).and_return(YES);
                OEFType *oefType1 = nice_fake_for([OEFType class]);
                OEFType *oefType2 = nice_fake_for([OEFType class]);
                NSArray *oefTypesArray = @[oefType1,oefType2];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                KSPromise *fetchMostRecentPunchForUserUriPromise = [[KSPromise alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriPromise);

                subject.view should_not be_nil;
                [subject viewWillAppear:YES];

                UIViewController *punchController = [[UIViewController alloc] init];

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .with(subject, nil, nil, nil,punch, nil)
                .and_return(punchController);

                [subject punchRepository:(id)[NSNull null] didUpdateMostRecentPunch:punch];
            });

            it(@"should have correct left navigation item", ^{
                subject.navigationItem.leftBarButtonItem should be_nil;
            });
        });
    });
    
    describe(@"<BookmarksHomeViewControllerDelegate>", ^{
        
        context(@"bookmarksHomeViewController:updatePunchCard:", ^{
            __block UIViewController *punchController;
            __block  LocalPunch *fakePunch;
            __block PunchCardObject *cardObject;
            beforeEach(^{
                punchController = [[UIViewController alloc] init];
                spy_on(punchController);
                fakePunch = nice_fake_for([LocalPunch class]);
                cardObject = nice_fake_for([PunchCardObject class]);
                KSPromise *punchPromise = nice_fake_for([KSPromise class]);
                
                (id<CedarDouble>)subject stub_method(@selector(mostRecentPunch)).and_return(fakePunch);

                timeLineAndRecentPunchRepository stub_method(@selector(punchesPromiseWithServerDidFinishPunchPromise:timeLinePunchFlow:userUri:date:)).and_return(punchPromise);
                
                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .with(subject, nil, nil, cardObject,fakePunch, nil)
                .and_return(punchController);
                
                [subject view];
                
                [subject bookmarksHomeViewController:nil updatePunchCard:cardObject];
            });
            afterEach(^{
                stop_spying_on(punchController);
            });
            
            it(@"should not show the right bar button item , since its a first time login for user", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
            
            it(@"should display the next punch controller", ^{
                subject.childViewControllers.firstObject should be_same_instance_as(punchController);
            });
            
            it(@"should have a single child controller", ^{
                subject.childViewControllers.count should equal(1);
            });
            
            it(@"should size the child view controllers's frame appropriately", ^{
                [subject viewWillAppear:YES];
                punchController.view.frame should equal(subject.view.bounds);
            });
            
            it(@"should tell the punch out controller that it has moved to parent controller", ^{
                punchController should have_received(@selector(didMoveToParentViewController:)).with(subject);
            });
        });
        
        context(@"bookmarksHomeViewController:updatePunchCard:", ^{
            __block KSPromise *imagePromise;
            __block KSPromise *punchPromise;
            __block LocalPunch *punch;
            __block UIViewController *punchController;
            __block PunchCardObject *cardObject;
            beforeEach(^{
                punch = nice_fake_for([LocalPunch class]);
                punchPromise = nice_fake_for([KSPromise class]);
                imagePromise = [subject punchAssemblyWorkflowNeedsImage];
                punchController = [[UIViewController alloc] init];
                spy_on(punchController);
                cardObject = nice_fake_for([PunchCardObject class]);
                KSPromise *punchPromise = nice_fake_for([KSPromise class]);
                timeLineAndRecentPunchRepository stub_method(@selector(punchesPromiseWithServerDidFinishPunchPromise:timeLinePunchFlow:userUri:date:)).and_return(punchPromise);
                
                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punchCardObject:punch:punchesPromise:))
                .with(subject, punchPromise, imagePromise, subject.punchCardObject,punch, nil)
                .and_return(punchController);
                
                [subject view];
                
                [subject bookmarksHomeViewController:nil willEventuallyFinishIncompletePunch:punch assembledPunchPromise:imagePromise serverDidFinishPunchPromise:punchPromise];
            });
            afterEach(^{
                stop_spying_on(punchController);
            });
            
            it(@"should not show the right bar button item , since its a first time login for user", ^{
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
            
            it(@"should display the next punch controller", ^{
                subject.childViewControllers.firstObject should be_same_instance_as(punchController);
            });
            
            it(@"should have a single child controller", ^{
                subject.childViewControllers.count should equal(1);
            });
            
            it(@"should size the child view controllers's frame appropriately", ^{
                [subject viewWillAppear:YES];
                punchController.view.frame should equal(subject.view.bounds);
            });
            
            it(@"should tell the punch out controller that it has moved to parent controller", ^{
                punchController should have_received(@selector(didMoveToParentViewController:)).with(subject);
            });
        });
    });


});

SPEC_END
