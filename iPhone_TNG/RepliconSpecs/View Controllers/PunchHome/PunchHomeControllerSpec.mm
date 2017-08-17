#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchHomeController.h"
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
#import "CameraViewController.h"
#import "UserSession.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "TimeLineAndRecentPunchRepository.h"
#import "TimeLinePunchesSummary.h"
#import "TimeLinePunchesStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchHomeControllerSpec)

describe(@"PunchHomeController", ^{
    __block PunchHomeController *subject;
    __block PunchControllerProvider<CedarDouble> *punchControllerProvider;
    __block PunchClock<CedarDouble> *punchClock;
    __block UIImagePickerController *imagePicker;
    __block PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
    __block ImageNormalizer *imageNormalizer;
    __block KSPromise *serverPromise;
    __block PunchRepository *punchRepository;
    __block AllowAccessAlertHelper *allowAccessAlertHelper;
    __block id<BSBinder, BSInjector> injector;
    __block id<UserSession> userSession;
    __block TimeLineAndRecentPunchRepository *timeLineAndRecentPunchRepository;
    __block DateProvider *dateProvider;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block NSDate *expectedDate;

    beforeEach(^{
        injector = [InjectorProvider injector];

        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);
        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];

        serverPromise = [[KSPromise alloc] init];
        punchClock = nice_fake_for([PunchClock class]);

        punchControllerProvider = nice_fake_for([PunchControllerProvider class]);
        allowAccessAlertHelper = nice_fake_for([AllowAccessAlertHelper class]);

        imagePicker = nice_fake_for([UIImagePickerController class]);
        imageNormalizer = nice_fake_for([ImageNormalizer class]);
        punchImagePickerControllerProvider = nice_fake_for([PunchImagePickerControllerProvider class]);
        punchImagePickerControllerProvider stub_method(@selector(provideInstanceWithDelegate:))
        .and_return(imagePicker);

        userSession = fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"some:user:uri");

        timeLineAndRecentPunchRepository = nice_fake_for([TimeLineAndRecentPunchRepository class]);
        [injector bind:[TimeLineAndRecentPunchRepository class] toInstance:timeLineAndRecentPunchRepository];

        expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(expectedDate);
        [injector bind:[DateProvider class] toInstance:dateProvider];


        [injector bind:@protocol(UserSession) toInstance:userSession];
        punchRepository = [injector getInstance:[PunchRepository class]];
        [injector bind:[PunchImagePickerControllerProvider class] toInstance:punchImagePickerControllerProvider];
        [injector bind:[AllowAccessAlertHelper class] toInstance:allowAccessAlertHelper];
        [injector bind:[PunchControllerProvider class] toInstance:punchControllerProvider];
        [injector bind:[ImageNormalizer class] toInstance:imageNormalizer];
        [injector bind:[PunchClock class] toInstance:punchClock];

        spy_on(punchRepository);


        subject = [injector getInstance:[PunchHomeController class]];

        spy_on(subject);
    });

    afterEach(^{
        stop_spying_on(subject);
        stop_spying_on(punchRepository);
    });


    describe(@"-fetchAndDisplayChildControllerForMostRecentPunch", ^{
        beforeEach(^{
            [subject fetchAndDisplayChildControllerForMostRecentPunch];
        });

        it(@"should fetch the most recent punch from the punch clock", ^{
            punchRepository should have_received(@selector(fetchMostRecentPunchFromServerForUserUri:)).with(@"some:user:uri");
        });
    });

    describe(@"when the view loads", ^{

        __block KSDeferred *fetchMostRecentPunchForUserUriDeferred;
        beforeEach(^{
            fetchMostRecentPunchForUserUriDeferred = [[KSDeferred alloc]init];
            punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriDeferred.promise);
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });

        it(@"should fetch the most recent punch from the punch clock", ^{
            punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"some:user:uri");
        });

        context(@"when fetched successfully", ^{
            __block id<Punch> fakePunch1;
            __block id<Punch> fakePunch2;
            __block UIViewController *punchController;

            context(@"when the most recent punch and timeline punches doesn't matches", ^{
                beforeEach(^{

                    fakePunch1 = nice_fake_for([LocalPunch class]);
                    fakePunch2 = nice_fake_for([LocalPunch class]);

                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);

                    punchController = [[UIViewController alloc]init];
                    spy_on(punchController);

                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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

                __block  LocalPunch *fakePunch1;
                __block  LocalPunch *fakePunch2;
                beforeEach(^{
                    date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                    punch = fake_for([LocalPunch class]);
                    punch stub_method(@selector(date)).and_return(date);
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                    fakePunch1 = nice_fake_for([LocalPunch class]);
                    fakePunch2 = nice_fake_for([LocalPunch class]);

                    subject stub_method(@selector(mostRecentPunch)).and_return(fakePunch2);
                    subject stub_method(@selector(timelinePunches)).and_return(@[fakePunch1]);

                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);



                    punchController = [[UIViewController alloc]init];
                    spy_on(punchController);

                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
                    .and_return(punchController);

                   
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

                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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

                        punchControllerProvider1 = nice_fake_for([PunchControllerProvider class]);

                        (id<CedarDouble>)subject stub_method(@selector(punchControllerProvider)).and_return(punchControllerProvider1);

                        punchControllerProvider1 stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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
                        punchControllerProvider1 should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:));
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

    describe(@"when the view appears", ^{
        __block UINavigationController *navigationController;

        beforeEach(^{
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });

        it(@"should hide the navigation bar", ^{
            navigationController.navigationBarHidden should be_truthy;
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

                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
                .and_return(punchController);
            });
            afterEach(^{
                stop_spying_on(punchController);
            });

            context(@"when the most recent punch and timeline punches doesn't matches", ^{

                beforeEach(^{
                    [subject view];
                });
                
                __block RemotePunch *punch;
                __block RemotePunch *fakePunch1;

                beforeEach(^{

                    punch = fake_for([RemotePunch class]);
                    punch stub_method(@selector(date)).and_return(dateProvider.date);
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
                    punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:)).with(subject, nil, nil, punch,nil);
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
                __block  RemotePunch *fakePunch1;
                __block  RemotePunch *fakePunch2;
                beforeEach(^{
                    date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                    punch = fake_for([RemotePunch class]);
                    punch stub_method(@selector(date)).and_return(date);
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    punch stub_method(@selector(syncedWithServer)).and_return(YES);

                    fakePunch1 = nice_fake_for([RemotePunch class]);
                    fakePunch1 stub_method(@selector(syncedWithServer)).and_return(YES);
                    fakePunch2 = nice_fake_for([RemotePunch class]);
                    fakePunch2 stub_method(@selector(syncedWithServer)).and_return(YES);

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

                it(@"should not be the punch out controller's delegate", ^{
                    punchControllerProvider should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:));
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

                __block RemotePunch *punch;
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

                        punchController1 =  punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider1 = nice_fake_for([PunchControllerProvider class]);

                        (id<CedarDouble>)subject stub_method(@selector(punchControllerProvider)).and_return(punchControllerProvider1);

                        punchControllerProvider1 stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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
                        punchControllerProvider1 should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:));
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

        describe(@"punchRepositoryDidDiscoverFirstTimeUse:", ^{
            __block UIViewController *punchController;
            __block KSPromise *punchPromise;
            beforeEach(^{
                punchController = [[UIViewController alloc] init];
                spy_on(punchController);
                punchPromise = nice_fake_for([KSPromise class]);
                timeLineAndRecentPunchRepository stub_method(@selector(punchesPromiseWithServerDidFinishPunchPromise:timeLinePunchFlow:userUri:date:)).with(nil,CardTimeLinePunchFlowContext,@"some:user:uri",dateProvider.date).and_return(punchPromise);


                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
                .with(subject, nil, nil, nil, punchPromise)
                .and_return(punchController);

                [subject view];

                 [subject punchRepositoryDidDiscoverFirstTimeUse:nil];
            });
            afterEach(^{
                stop_spying_on(punchController);
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
                fetchMostRecentPunchForUserUriDeferred = [[KSDeferred alloc]init];
                punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(fetchMostRecentPunchForUserUriDeferred.promise);
                subject.view should_not be_nil;
                [subject punchRepositoryDidSyncPunches:punchRepository];
            });

            it(@"should fetch the most recent punch from the punch clock", ^{
                punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"some:user:uri");
            });

            context(@"when fetched successfully", ^{
                __block id<Punch> fakePunch1;
                __block id<Punch> fakePunch2;
                __block UIViewController *punchController;

                context(@"when the most recent punch and timeline punches doesn't matches", ^{
                    beforeEach(^{

                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);

                        punchController =  punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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

                    __block  LocalPunch *fakePunch1;
                    __block  LocalPunch *fakePunch2;
                    beforeEach(^{
                        date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                        punch = fake_for([LocalPunch class]);
                        punch stub_method(@selector(date)).and_return(date);
                        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);

                        subject stub_method(@selector(mostRecentPunch)).and_return(fakePunch2);
                        subject stub_method(@selector(timelinePunches)).and_return(@[fakePunch1]);

                        TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                        timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[fakePunch1]);
                        timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[fakePunch1,fakePunch2]);

                        punchController = [[UIViewController alloc]init];
                        spy_on(punchController);

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
                        .and_return(punchController);


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

                        punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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

                            punchControllerProvider1 = nice_fake_for([PunchControllerProvider class]);

                            (id<CedarDouble>)subject stub_method(@selector(punchControllerProvider)).and_return(punchControllerProvider1);

                            punchControllerProvider1 stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
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
                            punchControllerProvider1 should_not have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:));
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
    });

    describe(@"as a <PunchInControllerDelegate>", ^{
        __block PunchInController *punchInController;

        beforeEach(^{
            punchInController = nice_fake_for([PunchInController class]);
        });

        describe(@"receiving a punch in message", ^{
            beforeEach(^{
                [subject punchInControllerDidPunchIn:punchInController];
            });

            it(@"should punch in on the punch clock", ^{
                punchClock should have_received(@selector(punchInWithPunchAssemblyWorkflowDelegate:oefData:)).with(subject, nil);
            });

            context(@"when the user then finishes punching in or out", ^{
                beforeEach(^{
                    UIViewController *someController = [[UIViewController alloc] init];
                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:)).and_return(someController);
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

    describe(@"as a <PunchOutControllerDelegate>", ^{
        __block PunchOutController *punchOutController;

        beforeEach(^{
            punchOutController = nice_fake_for([PunchOutController class]);

            [subject controllerDidPunchOut:punchOutController];
        });

        it(@"should punch out on the punch clock", ^{
            punchClock should have_received(@selector(punchOutWithPunchAssemblyWorkflowDelegate:oefData:)).with(subject, nil);
        });

        context(@"when the user then finishes punching in or out", ^{

            __block  LocalPunch *fakePunch1;
            __block  LocalPunch *fakePunch2;
            __block  LocalPunch *punch;
            beforeEach(^{
                UIViewController *someController = [[UIViewController alloc] init];
                punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:)).and_return(someController);
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];

                fakePunch1 = nice_fake_for([LocalPunch class]);
                fakePunch2 = nice_fake_for([LocalPunch class]);


                timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[fakePunch2]);
                timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[fakePunch1,fakePunch2]);

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

            it(@"should update most recent punch", ^{
                subject.mostRecentPunch should equal(punch);
            });

            it(@"should update timeline punches", ^{
                subject.timelinePunches should equal(@[fakePunch2]);
            });

        });

        describe(@"receiving a take a break message", ^{
            __block NSDate *breakDate;
            beforeEach(^{
                breakDate = [NSDate dateWithTimeIntervalSince1970:123];
                BreakType *breakType = [[BreakType alloc] initWithName:@"Break" uri:@"break-uri"];
                [subject punchOutControllerDidTakeBreakWithDate:breakDate breakType:breakType];
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

    describe(@"as a <OnBreakControllerDelegate>", ^{
        describe(@"-onBreakControllerDidResumeWork:", ^{
            __block OnBreakController *onBreakController;

            beforeEach(^{
                onBreakController = nice_fake_for([OnBreakController class]);

                [subject onBreakControllerDidResumeWork:onBreakController];
            });

            it(@"should resume work on the punch clock", ^{
                punchClock should have_received(@selector(resumeWorkWithPunchAssemblyWorkflowDelegate:oefData:)).with(subject, nil);
            });

            context(@"when the user then finishes all the required actions for the punch", ^{
                __block KSPromise *assembledPunchPromise;
                __block LocalPunch *incompleteTransferPunch;
                beforeEach(^{
                    assembledPunchPromise = nice_fake_for([KSPromise class]);
                    UIViewController *someController = [[UIViewController alloc] init];
                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:)).and_return(someController);
                    incompleteTransferPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                });

                context(@"when the punch will eventuall be finished", ^{
                    __block  LocalPunch *fakePunch1;
                    __block  LocalPunch *fakePunch2;
                    beforeEach(^{
                        fakePunch1 = nice_fake_for([LocalPunch class]);
                        fakePunch2 = nice_fake_for([LocalPunch class]);

                        timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[fakePunch2]);
                        timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[fakePunch1,fakePunch2]);


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
                        punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
                        .with(subject, serverPromise, assembledPunchPromise, incompleteTransferPunch, nil);
                    });

                    it(@"should update most recent punch", ^{
                        subject.mostRecentPunch should equal(incompleteTransferPunch);
                    });

                    it(@"should update timeline punches", ^{
                        subject.timelinePunches should equal(@[fakePunch2]);
                    });
                });
            });
        });

        describe(@"-punchOutControllerDidTakeBreakWithDate:breakType:", ^{
            __block NSDate *breakDate;
            beforeEach(^{
                breakDate = [NSDate dateWithTimeIntervalSince1970:123];
                BreakType *breakType = [[BreakType alloc] initWithName:@"Break" uri:@"break-uri"];
                [subject punchOutControllerDidTakeBreakWithDate:breakDate breakType:breakType];
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
            context(@"when the most recent punch and timeline punches doesn't matches", ^{
                __block PunchAssemblyWorkflow *workflow;
                __block LocalPunch *incompletePunch;
                __block KSPromise *assembledPunchPromise;
                __block PunchInController *punchInController;
                __block PunchOutController *punchOutController;
                __block  LocalPunch *fakePunch1;
                __block  LocalPunch *fakePunch2;
                NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
                
                beforeEach(^{
                    [subject view];
                    [subject viewWillAppear:YES];
                    
                    punchInController = subject.childViewControllers.firstObject;
                    punchOutController = (id)[[UIViewController alloc] init];
                    
                    spy_on(punchInController);
                    spy_on(punchOutController);
                    
                    punchControllerProvider stub_method(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:)).and_return(punchOutController);
                    
                    workflow = nice_fake_for([PunchAssemblyWorkflow class]);
                    
                    incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:expectedDate];
                    assembledPunchPromise = nice_fake_for([KSPromise class]);
                    
                    fakePunch1 = nice_fake_for([LocalPunch class]);
                    fakePunch2 = nice_fake_for([LocalPunch class]);
                    
                    
                    timeLinePunchesStorage stub_method(@selector(allPunchesForDay:userUri:)).with(expectedDate,@"some:user:uri").and_return(@[fakePunch2]);
                    timeLinePunchesStorage stub_method(@selector(recentPunchesForUserUri:)).with(@"some:user:uri").and_return(@[fakePunch1,fakePunch2]);


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
                    punchControllerProvider should have_received(@selector(punchControllerWithDelegate:serverDidFinishPunchPromise:assembledPunchPromise:punch:punchesPromise:))
                    .with(subject, serverPromise, assembledPunchPromise, incompletePunch, nil);
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

    describe(@"as an <UIImagePickerControllerDelegate>", ^{
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
});

SPEC_END
