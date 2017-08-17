#import <Cedar/Cedar.h>
#import "PunchCardsListController.h"
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
#import "UserPermissionsStorage.h"
#import "TimeLinePunchesStorage.h"
#import "UITableViewCell+Spec.h"
#import "SelectBookmarksHeaderView.h"
#import "PunchCardsListController+ValidateForInvalidClientProjectTask.h"
#import "BookmarkValidationRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchCardsListControllerSpec)

describe(@"PunchCardsListController", ^{
    __block PunchCardsListController *subject;
    __block PunchCardStorage *punchCardStorage;
    __block id <BSBinder,BSInjector> injector;
    __block id <Theme> theme;
    __block id <PunchCardsListControllerDelegate> delegate;
    __block id <UserSession> userSession;
    __block id <Punch> mostRecentPunch;
    __block PunchClock *punchClock;
    __block PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
    __block AllowAccessAlertHelper *allowAccessAlertHelper;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block UIImagePickerController *imagePicker;
    __block ImageNormalizer *imageNormalizer;
    __block PunchCardObject *cardA;
    __block PunchCardObject *cardB;
    __block PunchCardObject *cardC;
    __block PunchCardObject *cardD;
    __block PunchCardObject *cardE;
    __block PunchCardObject *cardF;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block BookmarkValidationRepository *bookmarkValidationRepository;

    beforeEach(^{
        ClientType *clientA = nice_fake_for([ClientType class]);
        clientA stub_method(@selector(name)).and_return(nil);
        clientA stub_method(@selector(uri)).and_return(nil);

        ProjectType *projectA = nice_fake_for([ProjectType class]);
        projectA stub_method(@selector(name)).and_return(nil);
        projectA stub_method(@selector(uri)).and_return(nil);

        TaskType *taskA = nice_fake_for([TaskType class]);
        taskA stub_method(@selector(name)).and_return(nil);
        taskA stub_method(@selector(uri)).and_return(nil);

        ClientType *clientB = nice_fake_for([ClientType class]);
        clientB stub_method(@selector(name)).and_return(@"client-name-B");
        clientB stub_method(@selector(uri)).and_return(@"client-uri-B");

        ProjectType *projectB = nice_fake_for([ProjectType class]);
        projectB stub_method(@selector(name)).and_return(@"project-name-B");
        projectB stub_method(@selector(uri)).and_return(@"project-uri-B");

        TaskType *taskB = nice_fake_for([TaskType class]);
        taskB stub_method(@selector(name)).and_return(@"task-name-B");
        taskB stub_method(@selector(uri)).and_return(@"task-uri-B");

        ClientType *clientC = nice_fake_for([ClientType class]);
        clientC stub_method(@selector(name)).and_return(@"<null>");
        clientC stub_method(@selector(uri)).and_return(@"<null>");

        ProjectType *projectC = nice_fake_for([ProjectType class]);
        projectC stub_method(@selector(name)).and_return(@"<null>");
        projectC stub_method(@selector(uri)).and_return(@"<null>");

        TaskType *taskC = nice_fake_for([TaskType class]);
        taskC stub_method(@selector(name)).and_return(@"<null>");
        taskC stub_method(@selector(uri)).and_return(@"<null>");

        ClientType *clientD = nice_fake_for([ClientType class]);
        clientD stub_method(@selector(name)).and_return(@"");
        clientD stub_method(@selector(uri)).and_return(@"");

        ProjectType *projectD = nice_fake_for([ProjectType class]);
        projectD stub_method(@selector(name)).and_return(@"project-name-D");
        projectD stub_method(@selector(uri)).and_return(@"project-uri-D");

        TaskType *taskD = nice_fake_for([TaskType class]);
        taskD stub_method(@selector(name)).and_return(@"");
        taskD stub_method(@selector(uri)).and_return(@"");

        ClientType *clientE = nice_fake_for([ClientType class]);
        clientE stub_method(@selector(name)).and_return(@"");
        clientE stub_method(@selector(uri)).and_return(@"");

        ProjectType *projectE = nice_fake_for([ProjectType class]);
        projectE stub_method(@selector(name)).and_return(@"project-name-E");
        projectE stub_method(@selector(uri)).and_return(@"project-uri-E");

        TaskType *taskE = nice_fake_for([TaskType class]);
        taskE stub_method(@selector(name)).and_return(@"task-name-E");
        taskE stub_method(@selector(uri)).and_return(@"task-name-E");

        ClientType *clientF = nice_fake_for([ClientType class]);
        clientF stub_method(@selector(name)).and_return(@"client-name-F");
        clientF stub_method(@selector(uri)).and_return(@"client-uri-F");

        ProjectType *projectF = nice_fake_for([ProjectType class]);
        projectF stub_method(@selector(name)).and_return(@"project-name-F");
        projectF stub_method(@selector(uri)).and_return(@"project-uri-F");

        TaskType *taskF = nice_fake_for([TaskType class]);
        taskF stub_method(@selector(name)).and_return(@"");
        taskF stub_method(@selector(uri)).and_return(@"");

        cardA = [[PunchCardObject alloc]
                                  initWithClientType:clientA
                                         projectType:projectA
                                       oefTypesArray:nil
                                           breakType:NULL
                                            taskType:taskA
                                            activity:NULL
                                                 uri:@"uri-A"];
        cardB = [[PunchCardObject alloc]
                                  initWithClientType:clientB
                                         projectType:projectB
                                       oefTypesArray:nil
                                           breakType:NULL
                                            taskType:taskB
                                            activity:NULL
                                                 uri:@"uri-B"];
        cardC = [[PunchCardObject alloc]
                                  initWithClientType:clientC
                                         projectType:projectC
                                       oefTypesArray:nil
                                           breakType:NULL
                                            taskType:taskC
                                            activity:NULL
                                                 uri:@"uri-C"];
        cardD = [[PunchCardObject alloc]
                                  initWithClientType:clientD
                                         projectType:projectD
                                       oefTypesArray:nil
                                           breakType:NULL
                                            taskType:taskD
                                            activity:NULL
                                                 uri:@"uri-D"];
        cardE = [[PunchCardObject alloc]
                                  initWithClientType:clientE
                                         projectType:projectE
                                       oefTypesArray:nil
                                           breakType:NULL
                                            taskType:taskE
                                            activity:NULL
                                                 uri:@"uri-E"];
        cardF = [[PunchCardObject alloc]
                                  initWithClientType:clientF
                                         projectType:projectF
                                       oefTypesArray:nil
                                           breakType:NULL
                                            taskType:taskF
                                            activity:NULL
                                                 uri:@"uri-E"];
        
        
    });

    beforeEach(^{
        injector = [InjectorProvider injector];

        mostRecentPunch = nice_fake_for(@protocol(Punch));
        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);
        imagePicker = nice_fake_for([UIImagePickerController class]);
        allowAccessAlertHelper = nice_fake_for([AllowAccessAlertHelper class]);
        punchImagePickerControllerProvider = nice_fake_for([PunchImagePickerControllerProvider class]);
        punchClock = nice_fake_for([PunchClock class]);
        userSession = nice_fake_for(@protocol(UserSession));
        punchCardStorage = nice_fake_for([PunchCardStorage class]);
        imageNormalizer = nice_fake_for([ImageNormalizer class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        bookmarkValidationRepository = nice_fake_for([BookmarkValidationRepository class]);

        punchImagePickerControllerProvider stub_method(@selector(provideInstanceWithDelegate:))
        .and_return(imagePicker);

        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        theme = nice_fake_for(@protocol(Theme));

        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[ImageNormalizer class] toInstance:imageNormalizer];
        [injector bind:[PunchClock class] toInstance:punchClock];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[PunchCardStorage class] toInstance:punchCardStorage];
        [injector bind:[PunchImagePickerControllerProvider class] toInstance:punchImagePickerControllerProvider];
        [injector bind:[AllowAccessAlertHelper class] toInstance:allowAccessAlertHelper];
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        [injector bind:[BookmarkValidationRepository class] toInstance:bookmarkValidationRepository];
        subject = [injector getInstance:[PunchCardsListController class]];

        delegate = nice_fake_for(@protocol(PunchCardsListControllerDelegate));
        [subject setUpWithDelegate:delegate];

        timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).and_return(mostRecentPunch);

        theme stub_method(@selector(punchButtonColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(punchButtonTitleColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(transparentBackgroundColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(allPunchCardTitleLabelFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(punchStateButtonCornerRadius)).and_return((CGFloat)3.0f);
        theme stub_method(@selector(allPunchCardDescriptionLabelFont)).and_return([UIFont systemFontOfSize:15]);
        theme stub_method(@selector(allPunchCardDescriptionLabelFontColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(allPunchCardTitleLabelFontColor)).and_return([UIColor blackColor]);
        theme stub_method(@selector(punchCardTableViewParentViewBackgroundColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(punchCardTableViewCellBackgroundColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(punchCardTableViewCellBorderColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(punchCardTableViewCellCornerRadius)).and_return((CGFloat)1.0);
        theme stub_method(@selector(punchCardTableViewCellBorderWidth)).and_return((CGFloat)1.0);
        theme stub_method(@selector(punchCardTableHeaderViewLabelFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(punchCardTableHeaderViewBackgroundColor)).and_return([UIColor orangeColor]);

        punchCardStorage stub_method(@selector(getPunchCardsExcludingPunch:)).with(mostRecentPunch).and_return(@[cardA,cardB,cardC,cardD,cardE,cardF]);

        punchCardStorage stub_method(@selector(getPunchCards)).and_return(@[cardA,cardB,cardC,cardD,cardE,cardF]);

    });



    describe(@"When the view loads", ^{

        it(@"should set backgroundcolor for view", ^{
            subject.view.backgroundColor should equal([UIColor orangeColor]);
        });
        
        context(@"When the most recent punch is <PunchActionTypePunchOut>", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
            });

            it(@"should ask for the punch cards from punch cards storage", ^{
                punchCardStorage should have_received(@selector(getPunchCards));
            });
        });

        context(@"When the most recent punch is <PunchActionTypeStartBreak>", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
            });

            it(@"should ask for the punch cards from punch cards storage", ^{
                punchCardStorage should have_received(@selector(getPunchCards));
            });

        });

        context(@"When the most recent punch is <PunchActionTypePunchIn>", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
            });

            it(@"should ask for the punch cards from punch cards storage", ^{
                punchCardStorage should have_received(@selector(getPunchCardsExcludingPunch:)).with(mostRecentPunch);
            });
        });
        
        context(@"When the most recent punch is <PunchActionTypeTransfer>", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;

            });

            it(@"should ask for the punch cards from punch cards storage", ^{
                punchCardStorage should have_received(@selector(getPunchCardsExcludingPunch:)).with(mostRecentPunch);
            });

        });

        context(@"styling the cells", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                subject.view should_not be_nil;
            });

            it(@"should style cells correctly", ^{

                AllPunchCardCell *cellA = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cellA.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellA.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cellA.projectLabel.textColor should equal([UIColor blackColor]);
                
                cellA.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellA.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellA.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellA.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                AllPunchCardCell *cellB = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                cellB.clientLabel.backgroundColor should equal([UIColor orangeColor]);
                cellB.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellB.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellB.clientLabel.font should equal([UIFont systemFontOfSize:10]);
                cellB.projectLabel.font should equal([UIFont systemFontOfSize:15]);
                cellB.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellB.clientLabel.textColor should equal([UIColor blackColor]);
                cellB.projectLabel.textColor should equal([UIColor orangeColor]);
                cellB.taskLabel.textColor should equal([UIColor orangeColor]);
                
                cellB.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellB.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellB.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellB.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                AllPunchCardCell *cellC = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                cellC.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellC.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellC.projectLabel.textColor should equal([UIColor blackColor]);
                
                cellC.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellC.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellC.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellC.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                AllPunchCardCell *cellD = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                
                cellD.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellD.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellD.projectLabel.textColor should equal([UIColor blackColor]);
                
                cellD.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellD.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellD.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellD.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                AllPunchCardCell *cellE = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                
                cellE.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellE.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellE.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellE.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellE.projectLabel.textColor should equal([UIColor blackColor]);
                cellE.taskLabel.textColor should equal([UIColor orangeColor]);
                
                cellE.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellE.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellE.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellE.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                AllPunchCardCell *cellF = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                
                cellF.clientLabel.backgroundColor should equal([UIColor orangeColor]);
                cellF.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellF.clientLabel.font should equal([UIFont systemFontOfSize:10]);
                cellF.projectLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellF.clientLabel.textColor should equal([UIColor blackColor]);
                cellF.projectLabel.textColor should equal([UIColor orangeColor]);
                
                cellF.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellF.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellF.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellF.borderView.layer.borderWidth should equal((CGFloat)1.0);
            });

        });
        
        context(@"styling the cells when don't have client access", ^{
            
            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                subject.view should_not be_nil;
            });
            
            it(@"should style cells correctly", ^{
                
                AllPunchCardCell *cellA = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cellA.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellA.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellA.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellA.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellA.projectLabel.textColor should equal([UIColor blackColor]);
                cellA.taskLabel.textColor should equal([UIColor orangeColor]);
                
                
                
                AllPunchCardCell *cellB = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                cellB.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellB.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellB.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellB.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellB.projectLabel.textColor should equal([UIColor blackColor]);
                cellB.taskLabel.textColor should equal([UIColor orangeColor]);
                
                
                AllPunchCardCell *cellC = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                cellC.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellC.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellC.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellC.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellC.projectLabel.textColor should equal([UIColor blackColor]);
                cellC.taskLabel.textColor should equal([UIColor orangeColor]);
                
                
                
                AllPunchCardCell *cellD = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                
                cellD.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellD.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellD.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellD.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellD.projectLabel.textColor should equal([UIColor blackColor]);
                cellD.taskLabel.textColor should equal([UIColor orangeColor]);
                
                
                AllPunchCardCell *cellE = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                
                cellE.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellE.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellE.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellE.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellE.projectLabel.textColor should equal([UIColor blackColor]);
                cellE.taskLabel.textColor should equal([UIColor orangeColor]);
                
                
                AllPunchCardCell *cellF = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                
                cellF.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                cellF.taskLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellF.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                cellF.taskLabel.font should equal([UIFont systemFontOfSize:15]);
                

                cellF.projectLabel.textColor should equal([UIColor blackColor]);
                cellF.taskLabel.textColor should equal([UIColor orangeColor]);
            });
        });
        
        context(@"styling the cells when client and task values are not present", ^{
            
            beforeEach(^{
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");
                PunchCardObject *card = [[PunchCardObject alloc]
                                         initWithClientType:nil
                                         projectType:project
                                         oefTypesArray:nil
                                         breakType:nil
                                         taskType:nil
                                         activity:nil
                                         uri:@"uri"];
                
                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[card]);
                
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                subject.view should_not be_nil;
            });
            
            it(@"should style cells correctly", ^{
                
                AllPunchCardCell *cell = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cell.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cell.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cell.projectLabel.textColor should equal([UIColor blackColor]);
                
                cell.subviews should_not contain(cell.taskLabel);
                cell.subviews should_not contain(cell.clientLabel);
            });
        });
        
        context(@"styling the cells when client has null behaviour uri and type is Any Client", ^{
            
            beforeEach(^{
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");
                
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(ClientTypeAnyClient);
                client stub_method(@selector(uri)).and_return(ClientTypeAnyClient);
                
                PunchCardObject *card = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:nil
                                         breakType:nil
                                         taskType:nil
                                         activity:nil
                                         uri:@"uri"];
                
                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[card]);
                
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
            });
            
            
            it(@"should style cells correctly", ^{
                
                AllPunchCardCell *cell = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cell.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cell.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cell.projectLabel.textColor should equal([UIColor blackColor]);
                
                cell.subviews should_not contain(cell.taskLabel);
                cell.subviews should_not contain(cell.clientLabel);
            });
            
        });
        
        context(@"styling the cells when client has null behaviour uri and type is No Client", ^{
            
            beforeEach(^{
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");
                
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(ClientTypeNoClient);
                client stub_method(@selector(uri)).and_return(ClientTypeNoClientUri);
                
                PunchCardObject *card = [[PunchCardObject alloc]
                                         initWithClientType:client
                                         projectType:project
                                         oefTypesArray:nil
                                         breakType:nil
                                         taskType:nil
                                         activity:nil
                                         uri:@"uri"];
                
                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[card]);
                
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
            });
            
            it(@"should style cells correctly", ^{
                
                AllPunchCardCell *cell = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cell.projectLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cell.projectLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cell.projectLabel.textColor should equal([UIColor blackColor]);
                
                cell.subviews should_not contain(cell.taskLabel);
                cell.subviews should_not contain(cell.clientLabel);
            });
            
        });

        context(@"should display the correct values on cells", ^{
            __block AllPunchCardCell *cellA;
            __block AllPunchCardCell *cellB;
            __block AllPunchCardCell *cellC;
            __block AllPunchCardCell *cellD;
            __block AllPunchCardCell *cellE;
            __block AllPunchCardCell *cellF;

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
            });

            it(@"should display separator", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
            });

            beforeEach(^{
                cellA = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellB = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellC = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellD = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                cellE = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                cellF = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];


                spy_on(cellD.clientLabel);
                spy_on(cellD.projectLabel);
                spy_on(cellD.taskLabel);

                spy_on(cellE.clientLabel);
                spy_on(cellE.projectLabel);
                spy_on(cellE.taskLabel);

                spy_on(cellF.clientLabel);
                spy_on(cellF.projectLabel);
                spy_on(cellF.taskLabel);
            });

            it(@"should display correct number of cells", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(6);
            });

            it(@"should display correct values in the cells", ^{

                cellA.clientLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Client", nil),RPLocalizedString(@"None", nil)]);
                cellA.projectLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Project", nil),RPLocalizedString(@"None", nil)]);
                cellA.taskLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Task", nil),RPLocalizedString(@"None", nil)]);


                cellB.clientLabel.text should equal(@"client-name-B");
                cellB.projectLabel.text should equal(@"project-name-B");
                cellB.taskLabel.text should equal(@"task-name-B");


                cellC.clientLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Client", nil),RPLocalizedString(@"None", nil)]);
                cellC.projectLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Project", nil),RPLocalizedString(@"None", nil)]);
                cellC.taskLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Task", nil),RPLocalizedString(@"None", nil)]);


                cellD.contentView should_not contain(cellD.clientLabel);
                cellD.projectLabel.text should equal(@"project-name-D");
                cellD.contentView should_not contain(cellD.taskLabel);

                cellE.contentView should_not contain(cellD.clientLabel);
                cellE.projectLabel.text should equal(@"project-name-E");
                cellE.taskLabel.text should equal(@"task-name-E");

                cellF.clientLabel.text should equal(@"client-name-F");
                cellF.projectLabel.text should equal(@"project-name-F");
                cellF.contentView should_not contain(cellD.taskLabel);

            });
            
        });

        context(@"when there are no saved punch cards", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                punchCardStorage stub_method(@selector(getPunchCardsExcludingPunch:)).with(mostRecentPunch).again().and_return(nil);
                subject.view should_not be_nil;
            });

            it(@"should display correct number of cells", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(0);
            });

            it(@"should not display separator", ^{
                subject.tableView.separatorStyle should equal(UITableViewCellSeparatorStyleNone);
            });

        });

        context(@"deleting the stored punch cards", ^{

            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
            });


            context(@"deleting the cards", ^{

                beforeEach(^{
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should delete the cells from the table row", ^{
                    punchCardStorage should have_received(@selector(deletePunchCard:)).with(cardA);
                });

                it(@"should display correct cells after delete", ^{
                    [subject.tableView numberOfRowsInSection:0] should equal(5);

                    AllPunchCardCell *cellB = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellB.clientLabel.text should equal(@"client-name-B");
                    cellB.projectLabel.text should equal(@"project-name-B");
                    cellB.taskLabel.text should equal(@"task-name-B");

                    AllPunchCardCell *cellC = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellC.clientLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Client", nil),RPLocalizedString(@"None", nil)]);
                    cellC.projectLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Project", nil),RPLocalizedString(@"None", nil)]);
                    cellC.taskLabel.text should equal([NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Task", nil),RPLocalizedString(@"None", nil)]);


                    AllPunchCardCell *cellD = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    spy_on(cellD.clientLabel);
                    spy_on(cellD.projectLabel);
                    spy_on(cellD.taskLabel);

                    cellD.contentView should_not contain(cellD.clientLabel);
                    cellD.projectLabel.text should equal(@"project-name-D");
                    cellD.contentView should_not contain(cellD.taskLabel);

                    AllPunchCardCell *cellE = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    spy_on(cellE.clientLabel);
                    spy_on(cellE.projectLabel);
                    spy_on(cellE.taskLabel);
                    cellD.contentView should_not contain(cellD.clientLabel);

                    cellE.projectLabel.text should equal(@"project-name-E");
                    cellE.taskLabel.text should equal(@"task-name-E");

                    AllPunchCardCell *cellF = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    spy_on(cellF.clientLabel);
                    spy_on(cellF.projectLabel);
                    spy_on(cellF.taskLabel);
                    
                    cellF.clientLabel.text should equal(@"client-name-F");
                    cellF.projectLabel.text should equal(@"project-name-F");
                    cellD.contentView should_not contain(cellD.taskLabel);
                });

            });

            context(@"when all the cards are deleted", ^{

                beforeEach(^{
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should delete the cells from the table row", ^{
                    punchCardStorage should have_received(@selector(deletePunchCard:)).with(cardA);
                });

                it(@"should have no cells on the table ", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });

                it(@"should have no cells on the table ", ^{
                    delegate should have_received(@selector(punchCardsListController:didUpdateHeight:));
                });

            });

        });

        context(@"Triggering bookmark validation call", ^{

            context(@"When no bookmarks", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                    punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[]);
                    subject.view should_not be_nil;

                });

                it(@"should not trigger validate bookmark request", ^{
                    bookmarkValidationRepository should_not have_received(@selector(validateBookmarks));
                });
            });

            context(@"When bookmarks available", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                    punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[cardA,cardB,cardC,cardD,cardE,cardF]);
                    subject.view should_not be_nil;

                });

                it(@"should trigger validate bookmark request", ^{
                    bookmarkValidationRepository should have_received(@selector(validateBookmarks));
                });
            });

            context(@"When bookmarks available and when validation request succeeds but returns no bookmarks", ^{
                __block KSDeferred *deffered;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                    deffered  = [[KSDeferred alloc] init];

                    punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[cardA,cardB,cardC]);

                    bookmarkValidationRepository stub_method(@selector(validateBookmarks)).and_return(deffered.promise);

                    [deffered resolveWithValue:nil];

                    subject.view should_not be_nil;

                });

                it(@"should not fetch cptmap from db", ^{
                    punchCardStorage should_not have_received(@selector(getCPTMap));
                });
            });

            context(@"When bookmarks available and when validation request succeeds and all  bookmarks are valid", ^{
                __block KSDeferred *deffered;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                    deffered  = [[KSDeferred alloc] init];
                    NSDictionary *cptmapFromDB1 = @{
                                                    @"Client":@{
                                                            @"uri" : @"client-uri1",
                                                            @"name" : @"client-name1"
                                                            },
                                                    @"project":@{
                                                            @"uri" : @"project-uri1",
                                                            @"name" : @"project-name1"
                                                            },
                                                    @"task":@{
                                                            @"uri" : @"task-uri1",
                                                            @"name" : @"task-name1"
                                                            }
                                                    };

                    NSDictionary *cptmapFromDB2 = @{
                                                    @"Client":@{
                                                            @"uri" : @"client-uri2",
                                                            @"name" : @"client-name2"
                                                            },
                                                    @"project":@{
                                                            @"uri" : @"project-uri2",
                                                            @"name" : @"project-name2"
                                                            },
                                                    @"task":@{
                                                            @"uri" : @"task-uri2",
                                                            @"name" : @"task-name2"
                                                            }
                                                    };
                    NSDictionary *cptmapFromDB3 = @{
                                                    @"Client":@{
                                                            @"uri" : @"client-uri3",
                                                            @"name" : @"client-name3"
                                                            },
                                                    @"project":@{
                                                            @"uri" : @"project-uri3",
                                                            @"name" : @"project-name3"
                                                            },
                                                    @"task":@{
                                                            @"uri" : @"task-uri3",
                                                            @"name" : @"task-name3"
                                                            }
                                                    };

                    NSDictionary *cptmapFromService1 = @{
                                                         @"Client":@{
                                                                 @"uri" : @"client-uri1",
                                                                 @"name" : @"client-name1"
                                                                 },
                                                         @"project":@{
                                                                 @"uri" : @"project-uri1",
                                                                 @"name" : @"project-name1"
                                                                 },
                                                         @"task":@{
                                                                 @"uri" : @"task-uri1",
                                                                 @"name" : @"task-name1"
                                                                 }
                                                         };

                    NSDictionary *cptmapFromService2 = @{
                                                         @"Client":@{
                                                                 @"uri" : @"client-uri2",
                                                                 @"name" : @"client-name2"
                                                                 },
                                                         @"project":@{
                                                                 @"uri" : @"project-uri2",
                                                                 @"name" : @"project-name2"
                                                                 },
                                                         @"task":@{
                                                                 @"uri" : @"task-uri2",
                                                                 @"name" : @"task-name2"
                                                                 }
                                                         };
                    NSDictionary *cptmapFromService3 = @{
                                                         @"Client":@{
                                                                 @"uri" : @"client-uri3",
                                                                 @"name" : @"client-name3"
                                                                 },
                                                         @"project":@{
                                                                 @"uri" : @"project-uri3",
                                                                 @"name" : @"project-name3"
                                                                 },
                                                         @"task":@{
                                                                 @"uri" : @"task-uri3",
                                                                 @"name" : @"task-name3"
                                                                 }
                                                         };

                    NSArray *cpts = @[cptmapFromDB1, cptmapFromDB2, cptmapFromDB3];
                    NSArray *cptsFromService = @[cptmapFromService1, cptmapFromService2, cptmapFromService3];

                    punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[cardA,cardB,cardC]);
                    punchCardStorage stub_method(@selector(getCPTMap)).and_return(cpts);
                    
                    bookmarkValidationRepository stub_method(@selector(validateBookmarks)).and_return(deffered.promise);
                    
                    [deffered resolveWithValue:cptsFromService];
                    
                    subject.view should_not be_nil;
                    
                });
                
                it(@"should not fetch cptmap from db", ^{
                    punchCardStorage should have_received(@selector(getCPTMap));
                });
                
                it(@"should not have deleted the punch", ^{
                    punchCardStorage should_not have_received(@selector(deletePunchCard:));
                });

                it(@"should not have received didFindPunchCardAsInvalidPunchCard delegate", ^{
                    delegate should_not have_received(@selector(punchCardsListController:didFindPunchCardAsInvalidPunchCard:));
                });
            });

            context(@"When the user has activity access and no project access", ^{
                __block KSDeferred *deffered;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                    deffered  = [[KSDeferred alloc] init];

                    punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[cardA,cardB,cardC]);

                    bookmarkValidationRepository stub_method(@selector(validateBookmarks)).and_return(deffered.promise);

                    [deffered resolveWithValue:nil];

                    subject.view should_not be_nil;

                });

                it(@"should not fetch cptmap from db", ^{
                    punchCardStorage should_not have_received(@selector(getCPTMap));
                });

                it(@"should not call validbookmarks in bookmarkrespository", ^{
                    bookmarkValidationRepository should_not have_received(@selector(validateBookmarks));
                });
            });
        });

    });

    describe(@"Trigger Bookmarks", ^{
        context(@"When bookmarks available and when validation request succeeds and returns  one invalid bookmarks", ^{
            __block KSDeferred *deffered;
            __block PunchCardObject *card11;
            __block PunchCardObject *card21;
            __block PunchCardObject *card31;
            beforeEach(^{

                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);

                deffered  = [[KSDeferred alloc] init];

                spy_on(subject);

                NSDictionary *cptmapFromDB1 = @{
                                                @"client":@{
                                                        @"uri" : @"client-uri1",
                                                        @"name" : @"client-name1"
                                                        },
                                                @"project":@{
                                                        @"uri" : @"project-uri1",
                                                        @"name" : @"project-name1"
                                                        },
                                                @"task":@{
                                                        @"uri" : @"task-uri1",
                                                        @"name" : @"task-name1"
                                                        }
                                                };

                NSDictionary *cptmapFromDB2 = @{
                                                @"client":@{
                                                        @"uri" : @"client-uri2",
                                                        @"name" : @"client-name2"
                                                        },
                                                @"project":@{
                                                        @"uri" : @"project-uri2",
                                                        @"name" : @"project-name2"
                                                        },
                                                @"task":@{
                                                        @"uri" : @"task-uri2",
                                                        @"name" : @"task-name2"
                                                        }
                                                };
                NSDictionary *cptmapFromDB3 = @{
                                                @"client":@{
                                                        @"uri" : @"client-uri3",
                                                        @"name" : @"client-name3"
                                                        },
                                                @"project":@{
                                                        @"uri" : @"project-uri3",
                                                        @"name" : @"project-name3"
                                                        },
                                                @"task":@{
                                                        @"uri" : @"task-uri3",
                                                        @"name" : @"task-name3"
                                                        }
                                                };

                NSDictionary *cptmapFromService1 = @{
                                                     @"client":@{
                                                             @"uri" : @"client-uri1",
                                                             @"name" : @"client-name1"
                                                             },
                                                     @"project":@{
                                                             @"uri" : @"project-uri1",
                                                             @"name" : @"project-name1"
                                                             },
                                                     @"task":@{
                                                             @"uri" : @"task-uri1",
                                                             @"name" : @"task-name1"
                                                             }
                                                     };

                NSDictionary *cptmapFromService2 = @{
                                                     @"client":@{
                                                             @"uri" : @"client-uri2",
                                                             @"name" : @"client-name2"
                                                             },
                                                     @"project":@{
                                                             @"uri" : @"project-uri2",
                                                             @"name" : @"project-name2"
                                                             },
                                                     @"task":@{
                                                             @"uri" : @"task-uri2",
                                                             @"name" : @"task-name2"
                                                             }
                                                     };

                NSArray *cpts = @[cptmapFromDB1, cptmapFromDB2, cptmapFromDB3];
                NSArray *cptsFromService = @[cptmapFromService1, cptmapFromService2];

                ClientType *clientA1 = nice_fake_for([ClientType class]);
                clientA1 stub_method(@selector(name)).and_return(@"client-name1");
                clientA1 stub_method(@selector(uri)).and_return(@"client-uri1");

                ProjectType *projectA1 = nice_fake_for([ProjectType class]);
                projectA1 stub_method(@selector(name)).and_return(@"project-name1");
                projectA1 stub_method(@selector(uri)).and_return(@"project-uri1");

                TaskType *taskA1 = nice_fake_for([TaskType class]);
                taskA1 stub_method(@selector(name)).and_return(@"task-name1");
                taskA1 stub_method(@selector(uri)).and_return(@"task-uri1");

                ClientType *clientB2 = nice_fake_for([ClientType class]);
                clientB2 stub_method(@selector(name)).and_return(@"client-name2");
                clientB2 stub_method(@selector(uri)).and_return(@"client-uri2");

                ProjectType *projectB2 = nice_fake_for([ProjectType class]);
                projectB2 stub_method(@selector(name)).and_return(@"project-name2");
                projectB2 stub_method(@selector(uri)).and_return(@"project-uri2");

                TaskType *taskB2 = nice_fake_for([TaskType class]);
                taskB2 stub_method(@selector(name)).and_return(@"task-name2");
                taskB2 stub_method(@selector(uri)).and_return(@"task-uri2");

                ClientType *clientC3 = nice_fake_for([ClientType class]);
                clientC3 stub_method(@selector(name)).and_return(@"client-name3");
                clientC3 stub_method(@selector(uri)).and_return(@"client-uri3");

                ProjectType *projectC3 = nice_fake_for([ProjectType class]);
                projectC3 stub_method(@selector(name)).and_return(@"project-name3");
                projectC3 stub_method(@selector(uri)).and_return(@"project-ur3");

                TaskType *taskC3 = nice_fake_for([TaskType class]);
                taskC3 stub_method(@selector(name)).and_return(@"task-name3");
                taskC3 stub_method(@selector(uri)).and_return(@"task-uri3");

                card11 = [[PunchCardObject alloc]
                          initWithClientType:clientA1
                          projectType:projectA1
                          oefTypesArray:nil
                          breakType:NULL
                          taskType:taskA1
                          activity:NULL
                          uri:@"uri-A"];
                card21 = [[PunchCardObject alloc]
                          initWithClientType:clientB2
                          projectType:projectB2
                          oefTypesArray:nil
                          breakType:NULL
                          taskType:taskB2
                          activity:NULL
                          uri:@"uri-B"];
                card31 = [[PunchCardObject alloc]
                          initWithClientType:clientC3
                          projectType:projectC3
                          oefTypesArray:nil
                          breakType:NULL
                          taskType:taskC3
                          activity:NULL
                          uri:@"uri-C"];

                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[card11,card21,card31]);

                punchCardStorage stub_method(@selector(getCPTMap)).and_return(cpts);

                punchCardStorage stub_method(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).with(@"client-uri3", @"project-uri3", @"task-uri3").and_return(card31);

                NSMutableArray *faketableRows = [NSMutableArray arrayWithArray:@[card11,card21,card31]];

                subject stub_method(@selector(tableRows)).and_return(faketableRows);

                bookmarkValidationRepository stub_method(@selector(validateBookmarks)).and_return(deffered.promise);

                [deffered resolveWithValue:cptsFromService];

                spy_on(subject.tableRows);

                subject.view should_not be_nil;

                spy_on(subject.tableView);
                
                [subject viewWillAppear:YES];

            });

            it(@"should fetch cptmap from db", ^{
                punchCardStorage should have_received(@selector(getCPTMap));
            });

            it(@"should fetch invalid map", ^{
                punchCardStorage should have_received(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).with(@"client-uri3", @"project-uri3", @"task-uri3");
            });

            it(@"should have deleted the punch", ^{
                punchCardStorage should have_received(@selector(deletePunchCard:)).with(card31);
            });

            it(@"should have removed third object from table rows", ^{
                subject.tableRows should have_received(@selector(removeObjectAtIndex:)).with(2);
            });

            it(@"should have received didFindPunchCardAsInvalidPunchCard delegate", ^{
                delegate should have_received(@selector(punchCardsListController:didFindPunchCardAsInvalidPunchCard:)).with(subject, card31);
            });

            afterEach(^{
                stop_spying_on(subject.tableView);
                stop_spying_on(subject);
            });
        });

        context(@"When bookmarks available and when validation request succeeds and returns  two invalid bookmarks", ^{
            __block KSDeferred *deffered;
            __block PunchCardObject *card11;
            __block PunchCardObject *card21;
            __block PunchCardObject *card31;
            beforeEach(^{
                deffered  = [[KSDeferred alloc] init];
                spy_on(subject);

                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                NSDictionary *cptmapFromDB1 = @{
                                                @"client":@{
                                                        @"uri" : @"client-uri1",
                                                        @"name" : @"client-name1"
                                                        },
                                                @"project":@{
                                                        @"uri" : @"project-uri1",
                                                        @"name" : @"project-name1"
                                                        },
                                                @"task":@{
                                                        @"uri" : @"task-uri1",
                                                        @"name" : @"task-name1"
                                                        }
                                                };

                NSDictionary *cptmapFromDB2 = @{
                                                @"client":@{
                                                        @"uri" : @"client-uri2",
                                                        @"name" : @"client-name2"
                                                        },
                                                @"project":@{
                                                        @"uri" : @"project-uri2",
                                                        @"name" : @"project-name2"
                                                        },
                                                @"task":@{
                                                        @"uri" : @"task-uri2",
                                                        @"name" : @"task-name2"
                                                        }
                                                };
                NSDictionary *cptmapFromDB3 = @{
                                                @"client":@{
                                                        @"uri" : @"client-uri3",
                                                        @"name" : @"client-name3"
                                                        },
                                                @"project":@{
                                                        @"uri" : @"project-uri3",
                                                        @"name" : @"project-name3"
                                                        },
                                                @"task":@{
                                                        @"uri" : @"task-uri3",
                                                        @"name" : @"task-name3"
                                                        }
                                                };

                NSDictionary *cptmapFromService1 = @{
                                                     @"client":@{
                                                             @"uri" : @"client-uri1",
                                                             @"name" : @"client-name1"
                                                             },
                                                     @"project":@{
                                                             @"uri" : @"project-uri1",
                                                             @"name" : @"project-name1"
                                                             },
                                                     @"task":@{
                                                             @"uri" : @"task-uri1",
                                                             @"name" : @"task-name1"
                                                             }
                                                     };

                NSArray *cpts = @[cptmapFromDB1, cptmapFromDB2, cptmapFromDB3];
                NSArray *cptsFromService = @[cptmapFromService1];

                ClientType *clientA1 = nice_fake_for([ClientType class]);
                clientA1 stub_method(@selector(name)).and_return(@"client-name1");
                clientA1 stub_method(@selector(uri)).and_return(@"client-uri1");

                ProjectType *projectA1 = nice_fake_for([ProjectType class]);
                projectA1 stub_method(@selector(name)).and_return(@"project-name1");
                projectA1 stub_method(@selector(uri)).and_return(@"project-uri1");

                TaskType *taskA1 = nice_fake_for([TaskType class]);
                taskA1 stub_method(@selector(name)).and_return(@"task-name1");
                taskA1 stub_method(@selector(uri)).and_return(@"task-uri1");

                ClientType *clientB2 = nice_fake_for([ClientType class]);
                clientB2 stub_method(@selector(name)).and_return(@"client-name2");
                clientB2 stub_method(@selector(uri)).and_return(@"client-uri2");

                ProjectType *projectB2 = nice_fake_for([ProjectType class]);
                projectB2 stub_method(@selector(name)).and_return(@"project-name2");
                projectB2 stub_method(@selector(uri)).and_return(@"project-uri2");

                TaskType *taskB2 = nice_fake_for([TaskType class]);
                taskB2 stub_method(@selector(name)).and_return(@"task-name2");
                taskB2 stub_method(@selector(uri)).and_return(@"task-uri2");

                ClientType *clientC3 = nice_fake_for([ClientType class]);
                clientC3 stub_method(@selector(name)).and_return(@"client-name3");
                clientC3 stub_method(@selector(uri)).and_return(@"client-uri3");

                ProjectType *projectC3 = nice_fake_for([ProjectType class]);
                projectC3 stub_method(@selector(name)).and_return(@"project-name3");
                projectC3 stub_method(@selector(uri)).and_return(@"project-ur3");

                TaskType *taskC3 = nice_fake_for([TaskType class]);
                taskC3 stub_method(@selector(name)).and_return(@"task-name3");
                taskC3 stub_method(@selector(uri)).and_return(@"task-uri3");

                card11 = [[PunchCardObject alloc]
                          initWithClientType:clientA1
                          projectType:projectA1
                          oefTypesArray:nil
                          breakType:NULL
                          taskType:taskA1
                          activity:NULL
                          uri:@"uri-A"];
                card21 = [[PunchCardObject alloc]
                          initWithClientType:clientB2
                          projectType:projectB2
                          oefTypesArray:nil
                          breakType:NULL
                          taskType:taskB2
                          activity:NULL
                          uri:@"uri-B"];
                card31 = [[PunchCardObject alloc]
                          initWithClientType:clientC3
                          projectType:projectC3
                          oefTypesArray:nil
                          breakType:NULL
                          taskType:taskC3
                          activity:NULL
                          uri:@"uri-C"];

                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[card11,card21,card31]);
                punchCardStorage stub_method(@selector(getCPTMap)).and_return(cpts);

                punchCardStorage stub_method(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:)).with(@"client-uri3", @"project-uri3", @"task-uri3").and_return(card31);

                NSMutableArray *faketableRows = [NSMutableArray arrayWithArray:@[card11,card21,card31]];

                subject stub_method(@selector(tableRows)).and_return(faketableRows);

                bookmarkValidationRepository stub_method(@selector(validateBookmarks)).and_return(deffered.promise);

                [deffered resolveWithValue:cptsFromService];

                spy_on(subject.tableRows);

                subject.view should_not be_nil;

                spy_on(subject.tableView);

                [subject viewWillAppear:YES];
                
            });
            
            it(@"should fetch cptmap from db", ^{
                punchCardStorage should have_received(@selector(getCPTMap));
            });
            
            it(@"should fetch invalid map", ^{
                punchCardStorage should have_received(@selector(getPunchCardObjectWithClientUri:projectUri:taskUri:));
            });
            
            it(@"should have deleted the punch", ^{
                punchCardStorage should have_received(@selector(deletePunchCard:));            });
            
            it(@"should have removed third object from table rows", ^{
                subject.tableRows should have_received(@selector(removeObjectAtIndex:));
            });

            it(@"should have received didFindPunchCardAsInvalidPunchCard delegate", ^{
                delegate should have_received(@selector(punchCardsListController:didFindPunchCardAsInvalidPunchCard:)).with(subject, card31);
            });

            afterEach(^{
                stop_spying_on(subject.tableView);
                stop_spying_on(subject);
            });
        });
    });

    describe(@"When viewDidLayoutSubviews", ^{

        beforeEach(^{
            mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
            timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });

        it(@"should inform its delegate to update the container", ^{
            delegate should have_received(@selector(punchCardsListController:didUpdateHeight:));
        });
    });
    
    describe(@"punchCardsListController:didIntendToUpdatePunchCard:", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject tableView:subject.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        });
        
        it(@"should inform delegate to update punch card", ^{
            delegate should have_received(@selector(punchCardsListController:didIntendToUpdatePunchCard:)).with(subject,cardB);
        });
    });
    
    describe(@"viewForHeaderInSection", ^{
        
        context(@"where there is no card", ^{
            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(nil);
                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[]);

                subject.view should_not be_nil;
            });

            it(@"should return a correctly configured view", ^{
                UIView *header = [subject tableView:subject.tableView viewForHeaderInSection:0];
                header.backgroundColor should equal([UIColor orangeColor]);
            });
        });
        
        context(@"when user has some punch cards", ^{
            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(nil);
                punchCardStorage stub_method(@selector(getPunchCards)).again().and_return(@[cardA]);
                
                subject.view should_not be_nil;
            });

            it(@"should return a correctly configured view", ^{
                SelectBookmarksHeaderView *selectBookmarksHeaderView;
                UIView *header = [subject tableView:subject.tableView viewForHeaderInSection:0];
                header should be_instance_of([SelectBookmarksHeaderView class]);
                selectBookmarksHeaderView = (SelectBookmarksHeaderView*)header;
                selectBookmarksHeaderView.sectionTitleLabel.text should equal(RPLocalizedString(previousProjectsText, previousProjectsText));
                selectBookmarksHeaderView.sectionTitleLabel.backgroundColor should equal([UIColor orangeColor]);
                selectBookmarksHeaderView.sectionTitleLabel.font should equal([UIFont systemFontOfSize:10]);
            });
        });
    });

});

SPEC_END
