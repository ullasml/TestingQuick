#import <Cedar/Cedar.h>
#import "SelectBookmarksViewController.h"
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
#import "ImageNormalizer.h"
#import "UIBarButtonItem+Spec.h"
#import "UIControl+spec.h"
#import "UserPermissionsStorage.h"
#import "TimeLinePunchesStorage.h"
#import "ProjectCreatePunchCardController.h"
#import "UITableViewCell+Spec.h"
#import "AllPunchCardController.h"
#import "BookmarkThreeEntriesCell.h"
#import "BookmarkTwoEntriesCell.h"
#import "BookmarkOneEntryCell.h"
#import "BookmarkValidationRepository.h"
#import "SelectBookmarksViewController+ValidateForInvalidClientProjectTask.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SelectBookmarksViewControllerSpec)

describe(@"SelectBookmarksViewController", ^{
    __block SelectBookmarksViewController *subject;
    __block PunchCardStorage *punchCardStorage;
    __block id <BSBinder,BSInjector> injector;
    __block id <Theme> theme;
    __block id <SelectBookmarksViewControllerDelegate> delegate;
    __block id <Punch> mostRecentPunch;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
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
        clientA stub_method(@selector(name)).and_return(@"client-name-A");
        clientA stub_method(@selector(uri)).and_return(@"client-uri-A");
        
        ProjectType *projectA = nice_fake_for([ProjectType class]);
        projectA stub_method(@selector(name)).and_return(@"project-name-A");
        projectA stub_method(@selector(uri)).and_return(@"project-uri-A");
        
        TaskType *taskA = nice_fake_for([TaskType class]);
        taskA stub_method(@selector(name)).and_return(@"task-name-A");
        taskA stub_method(@selector(uri)).and_return(@"task-uri-A");
        
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
        punchCardStorage = nice_fake_for([PunchCardStorage class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        theme = nice_fake_for(@protocol(Theme));
        bookmarkValidationRepository = nice_fake_for([BookmarkValidationRepository class]);
        
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];
        [injector bind:[PunchCardStorage class] toInstance:punchCardStorage];
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        [injector bind:[BookmarkValidationRepository class] toInstance:bookmarkValidationRepository];

        subject = [injector getInstance:[SelectBookmarksViewController class]];
        
        delegate = nice_fake_for(@protocol(SelectBookmarksViewControllerDelegate));
        
        [subject setupWithDelegate:delegate];
        
        delegate = subject.delegate;
        spy_on(delegate);

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
        theme stub_method(@selector(noBookmarksLabelDescriptionTextColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(noBookmarksLabelDescriptionFont)).and_return([UIFont fontWithName:@"OpenSans-Semibold" size:1]);
        theme stub_method(@selector(noBookmarksLabelTitleTextColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(noBookmarksLabelTitleTextFont)).and_return([UIFont fontWithName:@"OpenSans-Semibold" size:1]);
        theme stub_method(@selector(plusSignColor)).and_return([UIColor redColor]);
        
        punchCardStorage stub_method(@selector(getPunchCardsExcludingPunch:)).with(mostRecentPunch).and_return(@[cardA,cardB,cardC,cardD,cardE,cardF]);
        
        punchCardStorage stub_method(@selector(getPunchCards)).and_return(@[cardA,cardB,cardC,cardD,cardE,cardF]);
        
    });
    
    describe(@"When the view loads", ^{
        
        it(@"should set backgroundcolor for view", ^{
            subject.view.backgroundColor should equal([UIColor orangeColor]);
        });
        
        context(@"styling the cells", ^{
            
            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                spy_on(subject.noBookmarksTitleLabel);
                spy_on(subject.noBookmarksDescriptionLabel);
            });
            
            it(@"no bookmarks msg label should be hidden", ^{
                subject.noBookmarksTitleLabel.hidden should be_truthy;
                subject.noBookmarksDescriptionLabel.hidden should be_truthy;
            });

            it(@"should style cells correctly", ^{
                
                BookmarkOneEntryCell *cellA = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cellA.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellA.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cellA.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cellA.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellA.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellA.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellA.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                BookmarkThreeEntriesCell *cellB = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                cellB.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellB.secondEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellB.thirdEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellB.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellB.secondEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                cellB.thirdEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellB.firstEntryLabel.textColor should equal([UIColor blackColor]);
                cellB.secondEntryLabel.textColor should equal([UIColor orangeColor]);
                cellB.thirdEntryLabel.textColor should equal([UIColor orangeColor]);
                
                cellB.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellB.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellB.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellB.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                BookmarkOneEntryCell *cellC = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                cellC.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellC.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellC.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cellC.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellC.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellC.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellC.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                BookmarkOneEntryCell *cellD = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                
                cellD.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellD.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellD.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cellD.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellD.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellD.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellD.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                BookmarkTwoEntriesCell *cellE = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                
                cellE.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellE.secondEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellE.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellE.secondEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellE.firstEntryLabel.textColor should equal([UIColor blackColor]);
                cellE.secondEntryLabel.textColor should equal([UIColor orangeColor]);
                
                cellE.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellE.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellE.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellE.borderView.layer.borderWidth should equal((CGFloat)1.0);
                
                BookmarkTwoEntriesCell *cellF = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                
                cellF.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellF.secondEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellF.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellF.secondEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellF.firstEntryLabel.textColor should equal([UIColor blackColor]);
                cellF.secondEntryLabel.textColor should equal([UIColor orangeColor]);
                
                cellF.borderView.backgroundColor should equal([UIColor orangeColor]);
                cellF.borderView.layer.borderColor should equal([UIColor orangeColor].CGColor);
                cellF.borderView.layer.cornerRadius should equal((CGFloat)1.0);
                cellF.borderView.layer.borderWidth should equal((CGFloat)1.0);
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
                spy_on(subject.noBookmarksTitleLabel);
                spy_on(subject.noBookmarksDescriptionLabel);
            });
            
            
            it(@"no bookmarks msg label should be hidden", ^{
                subject.noBookmarksTitleLabel.hidden should be_truthy;
                subject.noBookmarksDescriptionLabel.hidden should be_truthy;
            });
            
            it(@"should style cells correctly", ^{
                
                BookmarkOneEntryCell *cell = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cell.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cell.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cell.firstEntryLabel.textColor should equal([UIColor blackColor]);
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
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(nil);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                spy_on(subject.noBookmarksTitleLabel);
                spy_on(subject.noBookmarksDescriptionLabel);
            });
            
            
            it(@"no bookmarks msg label should be hidden", ^{
                subject.noBookmarksTitleLabel.hidden should be_truthy;
                subject.noBookmarksDescriptionLabel.hidden should be_truthy;
            });
            
            it(@"should style cells correctly", ^{
                
                BookmarkOneEntryCell *cell = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cell.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cell.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cell.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cell should be_instance_of([BookmarkOneEntryCell class]);
            });
            
        });
        
        context(@"styling the cells when don't have client access", ^{
            
            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                spy_on(subject.noBookmarksTitleLabel);
                spy_on(subject.noBookmarksDescriptionLabel);
            });
            
            
            it(@"no bookmarks msg label should be hidden", ^{
                subject.noBookmarksTitleLabel.hidden should be_truthy;
                subject.noBookmarksDescriptionLabel.hidden should be_truthy;
            });

            it(@"should style cells correctly", ^{
                
                BookmarkTwoEntriesCell *cellA = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cellA.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellA.secondEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellA.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellA.secondEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellA.firstEntryLabel.textColor should equal([UIColor blackColor]);
                cellA.secondEntryLabel.textColor should equal([UIColor orangeColor]);
                
                cellA should be_instance_of([BookmarkTwoEntriesCell class]);
                
                BookmarkTwoEntriesCell *cellB = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                cellB.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellB.secondEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellB.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellB.secondEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellB.firstEntryLabel.textColor should equal([UIColor blackColor]);
                cellB.secondEntryLabel.textColor should equal([UIColor orangeColor]);
                
                cellB should be_instance_of([BookmarkTwoEntriesCell class]);
                
                BookmarkOneEntryCell *cellD = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                
                cellD.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellD.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cellD.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cellD should be_instance_of([BookmarkOneEntryCell class]);
                
                BookmarkTwoEntriesCell *cellE = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                
                cellE.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                cellE.secondEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellE.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                cellE.secondEntryLabel.font should equal([UIFont systemFontOfSize:15]);
                
                cellE.firstEntryLabel.textColor should equal([UIColor blackColor]);
                cellE.secondEntryLabel.textColor should equal([UIColor orangeColor]);
                
                cellE should be_instance_of([BookmarkTwoEntriesCell class]);
                
                BookmarkOneEntryCell *cellF = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                
                cellF.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cellF.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cellF.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cellF should be_instance_of([BookmarkOneEntryCell class]);
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
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(nil);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                spy_on(subject.noBookmarksTitleLabel);
                spy_on(subject.noBookmarksDescriptionLabel);
            });
            
            
            it(@"no bookmarks msg label should be hidden", ^{
                subject.noBookmarksTitleLabel.hidden should be_truthy;
                subject.noBookmarksDescriptionLabel.hidden should be_truthy;
            });
            
            it(@"should style cells correctly", ^{
                
                BookmarkOneEntryCell *cell = (id)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                cell.firstEntryLabel.backgroundColor should equal([UIColor orangeColor]);
                
                cell.firstEntryLabel.font should equal([UIFont systemFontOfSize:10]);
                
                cell.firstEntryLabel.textColor should equal([UIColor blackColor]);
                
                cell should be_instance_of([BookmarkOneEntryCell class]);
            });
        });
        
        context(@"should display the correct values on cells", ^{
            __block BookmarkThreeEntriesCell *cellA;
            __block BookmarkThreeEntriesCell *cellB;
            __block BookmarkThreeEntriesCell *cellC;
            __block BookmarkOneEntryCell *cellD;
            __block BookmarkTwoEntriesCell *cellE;
            __block BookmarkTwoEntriesCell *cellF;
            
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
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
                
                spy_on(cellD.firstEntryLabel);
                
                spy_on(cellE.firstEntryLabel);
                spy_on(cellE.secondEntryLabel);
                
                spy_on(cellF.firstEntryLabel);
                spy_on(cellF.secondEntryLabel);
            });
            
            it(@"should display correct number of cells", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(6);
            });
            
            it(@"should display correct values in the cells", ^{
                
                cellA.firstEntryLabel.text should equal(@"client-name-A");
                cellA.secondEntryLabel.text should equal(@"project-name-A");
                cellA.thirdEntryLabel.text should equal(@"task-name-A");
                
                cellB.firstEntryLabel.text should equal(@"client-name-B");
                cellB.secondEntryLabel.text should equal(@"project-name-B");
                cellB.thirdEntryLabel.text should equal(@"task-name-B");
                
                cellD.firstEntryLabel.text should equal(@"project-name-D");
                
                cellE.firstEntryLabel.text should equal(@"project-name-E");
                cellE.secondEntryLabel.text should equal(@"task-name-E");
                
                cellF.firstEntryLabel.text should equal(@"client-name-F");
                cellF.secondEntryLabel.text should equal(@"project-name-F");
            });
            
        });
        
        context(@"when there are no saved punch cards", ^{
            beforeEach(^{
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                punchCardStorage stub_method(@selector(getPunchCardsExcludingPunch:)).with(mostRecentPunch).again().and_return(nil);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
                spy_on(subject.noBookmarksTitleLabel);
                spy_on(subject.noBookmarksDescriptionLabel);
            });
            
            it(@"should display correct number of cells", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(0);
            });
            
            it(@"no bookmarks msg label should not be hidden", ^{
                subject.noBookmarksTitleLabel.hidden should be_falsy;
                subject.noBookmarksDescriptionLabel.hidden should be_falsy;
            });
            
            it(@"should show msg", ^{
                NSString *text = RPLocalizedString(noBookmarksAvailableText, noBookmarksAvailableText);
                NSString *linkTextWithColor = @"+";
                
                NSRange textRange=[text rangeOfString:linkTextWithColor options:NSBackwardsSearch];
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:text];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:textRange];
                [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"OpenSans-Semibold" size:1] range:textRange];

                subject.noBookmarksTitleLabel.text should equal(RPLocalizedString(noBookmarksCreatedText, noBookmarksCreatedText));
                subject.noBookmarksTitleLabel.textColor should equal([UIColor orangeColor]);
                subject.noBookmarksTitleLabel.font should equal([UIFont fontWithName:@"OpenSans-Semibold" size:1]);
                
                [subject.noBookmarksDescriptionLabel.attributedText isEqualToAttributedString:attributedString];
                subject.noBookmarksDescriptionLabel.textColor should equal([UIColor orangeColor]);
            });
            
        });
        
        context(@"deleting the stored punch cards", ^{
            
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                mostRecentPunch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).again().and_return(mostRecentPunch);
                subject.view should_not be_nil;
                [subject viewWillAppear:YES];
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
                    
                    BookmarkThreeEntriesCell *cellB = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellB.firstEntryLabel.text should equal(@"client-name-B");
                    cellB.secondEntryLabel.text should equal(@"project-name-B");
                    cellB.thirdEntryLabel.text should equal(@"task-name-B");
                    
                    BookmarkOneEntryCell *cellD = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    spy_on(cellD.firstEntryLabel);
                    
                    cellD.firstEntryLabel.text should equal(@"project-name-D");
                    
                    BookmarkTwoEntriesCell *cellE = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    spy_on(cellE.firstEntryLabel);
                    spy_on(cellE.secondEntryLabel);
                    
                    cellE.firstEntryLabel.text should equal(@"project-name-E");
                    cellE.secondEntryLabel.text should equal(@"task-name-E");
                    
                    BookmarkTwoEntriesCell *cellF = (id) [subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    spy_on(cellF.firstEntryLabel);
                    spy_on(cellF.secondEntryLabel);
                    
                    cellF.firstEntryLabel.text should equal(@"client-name-F");
                    cellF.secondEntryLabel.text should equal(@"project-name-F");
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
                
                it(@"no bookmarks msg label should not be hidden", ^{
                    subject.noBookmarksTitleLabel.hidden should be_falsy;
                    subject.noBookmarksDescriptionLabel.hidden should be_falsy;
                });

            });
            
        });

        context(@"Triggering bookmark validation call", ^{

            context(@"When no bookmarks", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
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
                    deffered  = [[KSDeferred alloc] init];

                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

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

                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

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
                subject.tableRows should have_received(@selector(removeObjectAtIndex:));            });

            afterEach(^{
                stop_spying_on(subject.tableView);
                stop_spying_on(subject);
            });
        });
    });

    describe(@"right bar button item action", ^{
        __block ProjectCreatePunchCardController *projectCreatePunchCardController;
        __block UINavigationController *navigationController;
        beforeEach(^{
            [subject view];
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            projectCreatePunchCardController = [[ProjectCreatePunchCardController alloc] initWithChildControllerHelper:nil
                                                                                                                 theme:nil];
            [injector bind:[ProjectCreatePunchCardController class] toInstance:projectCreatePunchCardController];
            
            spy_on(projectCreatePunchCardController);
            
            [subject navigateToCreateBookmarksView];
        });
        afterEach(^{
            stop_spying_on(projectCreatePunchCardController);
            
        });
        
        it(@"should navigate to selectBookmarksViewController", ^{
            navigationController.topViewController should be_same_instance_as(projectCreatePunchCardController);
        });
    });

    describe(@"-allPunchCardController:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:", ^{
        __block LocalPunch *incompletePunch;
        __block KSPromise *assembledPunchPromise;
        __block KSPromise *serverPromise;
        __block UINavigationController *navigationController;
        __block UIViewController *rootViewController;
        
        beforeEach(^{
            subject.view should_not be_nil;
            
            [subject setupWithDelegate:delegate];

            rootViewController = [[UIViewController alloc] init];
            navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            [navigationController pushViewController:subject animated:NO];
            
            assembledPunchPromise = nice_fake_for([KSPromise class]);
            serverPromise = nice_fake_for([KSPromise class]);
            incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
            
            
            [subject allPunchCardController:nil
       willEventuallyFinishIncompletePunch:incompletePunch
                     assembledPunchPromise:assembledPunchPromise
               serverDidFinishPunchPromise:serverPromise];
        });
        
        it(@"should inform its delegate to finish the punch assembly workflow", ^{
            delegate should have_received(@selector(selectBookmarksViewController:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:)).with(subject,incompletePunch,assembledPunchPromise,serverPromise);
        });
    });

    describe(@"as a <ProjectCreatePunchCardControllerDelegate>", ^{
        
        context(@"When there are stored punch cards", ^{
            __block ClientType *client;
            __block ProjectType *project;
            __block TaskType *task;
            __block PunchCardObject *expectedPunchCardObject;
            beforeEach(^{
                [subject view];
                
                client = [[ClientType alloc] initWithName:nil uri:nil];
                project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:client name:nil uri:nil];
                task = nice_fake_for([TaskType class]);
                
                expectedPunchCardObject = [[PunchCardObject alloc] initWithClientType:client projectType:project oefTypesArray:nil breakType:nil taskType:task activity:nil uri:nil];
                
                [subject projectCreatePunchCardController:nil didChooseToCreatePunchCardWithObject:expectedPunchCardObject];
            });
            
            it(@"should store punch card in storage class", ^{
                punchCardStorage should have_received(@selector(storePunchCard:)).with(expectedPunchCardObject);
            });
            
            it(@"should display correct number of cells", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(6);
            });
            

        });
    });
    
    describe(@"Tapping on UITableViewCell", ^{
        context(@"when user has punches", ^{
            __block UITableViewCell *cell;
            __block AllPunchCardController *allPunchCardController;
            __block UINavigationController *navigationController;
            context(@"when tapping cell", ^{
                beforeEach(^{
                    [subject view];
                    [subject viewWillAppear:YES];
                    [subject.tableView layoutIfNeeded];
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
                    allPunchCardController = [[AllPunchCardController alloc]
                                              initWithPunchImagePickerControllerProvider:nil
                                              transferPunchCardController:nil
                                              allowAccessAlertHelper:nil
                                              childControllerHelper:nil
                                              nsNotificationCenter:NULL
                                              punchCardStylist:nil
                                              imageNormalizer:nil
                                              oefTypeStorage:nil
                                              punchClock:nil];
                    [injector bind:[AllPunchCardController class] toInstance:allPunchCardController];
                    
                    spy_on(allPunchCardController);
                    
                    [cell tap];
                });
                
                it(@"should navigate when cell is clicked", ^{
                    navigationController.topViewController should be_same_instance_as(allPunchCardController);
                });
            });
        });
        
        context(@"when user does not have punches or most recent punch is punchout ", ^{
            __block UITableViewCell *cell;
            context(@"when user does not have punches", ^{
                beforeEach(^{
                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).and_return(nil).again();

                    [subject view];
                    [subject viewWillAppear:YES];
                    [subject.tableView layoutIfNeeded];

                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
                    [cell tap];
                });
                
                it(@"should pop to top view controller and load punch card with new values", ^{
                    delegate should have_received(@selector(selectBookmarksViewController:updatePunchCard:)).with(subject, cardB);
                });
            });
            
            context(@"most recent punch is punchout", ^{
                beforeEach(^{
                    LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:nil activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];

                    timeLinePunchesStorage stub_method(@selector(mostRecentPunch)).and_return(punch).again();
                    
                    [subject view];
                    [subject viewWillAppear:YES];
                    [subject.tableView layoutIfNeeded];
                    
                    cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
                    [cell tap];
                });
                
                it(@"should pop to top view controller and load punch card with new values", ^{
                    delegate should have_received(@selector(selectBookmarksViewController:updatePunchCard:)).with(subject, cardB);
                });
            });
        });
    });
});

SPEC_END
