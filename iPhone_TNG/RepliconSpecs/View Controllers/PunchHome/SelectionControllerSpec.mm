#import <Cedar/Cedar.h>
#import "SelectionController.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ClientRepository.h"
#import "ProjectRepository.h"
#import "TaskRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "ClientType.h"
#import "SVPullToRefresh.h"
#import "TimerProvider.h"
#import "PunchCardObject.h"
#import "ProjectType.h"
#import "UITableViewCell+spec.h"
#import "InjectorKeys.h"
#import "SVPullToRefresh.h"
#import "ClientProjectTaskRepository.h"
#import "ActivityRepositoryProtocol.h"
#import "Activity.h"
#import "SizeCell.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "ProjectStorage.h"
#import "ExpenseProjectStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SelectionControllerSpec)

describe(@"SelectionController", ^{
    __block SelectionController *subject;
    __block id <BSBinder,BSInjector> injector;
    __block id <SelectionControllerDelegate> delegate;
    __block TimerProvider *timerProvider;
    __block NSUserDefaults *userDefaults;
    __block id <ClientProjectTaskRepository> clientProjectTaskRepository;
    __block id <ClientRepositoryProtocol,CedarDouble> clientRepository;
    __block id <ProjectRepositoryProtocol,CedarDouble> projectRepository;
    __block id <TaskRepositoryProtocol,CedarDouble> taskRepository;
    __block id <ActivityRepositoryProtocol,CedarDouble> activityRepository;
    __block OEFDropDownRepository *oefDropDownRepository;
    __block ProjectStorage *projectStorage;
    __block ExpenseProjectStorage *expenseProjectStorage;

    beforeEach(^{
        injector = [InjectorProvider injector];

        delegate = nice_fake_for(@protocol(SelectionControllerDelegate));
        clientProjectTaskRepository = nice_fake_for(@protocol(ClientProjectTaskRepository));
        
        clientRepository = nice_fake_for(@protocol(ClientRepositoryProtocol));
        projectRepository = nice_fake_for(@protocol(ProjectRepositoryProtocol));
        taskRepository = nice_fake_for(@protocol(TaskRepositoryProtocol));
        activityRepository = nice_fake_for(@protocol(ActivityRepositoryProtocol));


        clientProjectTaskRepository stub_method(@selector(clientRepository)).and_return(clientRepository);
        clientProjectTaskRepository stub_method(@selector(projectRepository)).and_return(projectRepository);
        clientProjectTaskRepository stub_method(@selector(taskRepository)).and_return(taskRepository);
        clientProjectTaskRepository stub_method(@selector(activityRepository)).and_return(activityRepository);



        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        timerProvider = nice_fake_for([TimerProvider class]);
        [injector bind:[TimerProvider class] toInstance:timerProvider];
        
        projectStorage = nice_fake_for([ProjectStorage class]);
        [injector bind:[ProjectStorage class] toInstance:projectStorage];

        expenseProjectStorage = nice_fake_for([ExpenseProjectStorage class]);
        [injector bind:[ExpenseProjectStorage class] toInstance:expenseProjectStorage];

        oefDropDownRepository = nice_fake_for([OEFDropDownRepository class]);

        subject = [injector getInstance:InjectorKeySelectionControllerForPunchModule];
        
        delegate stub_method(@selector(selectionControllerNeedsClientProjectTaskRepository)).and_return(clientProjectTaskRepository);

         delegate stub_method(@selector(selectionControllerNeedsOEFDropDownRepository)).and_return(oefDropDownRepository);

        [subject setUpWithSelectionScreenType:ClientSelection punchCardObject:nil delegate:delegate];
        
    });

    describe(@"When view loads intially", ^{

        context(@"Client selection screen", ^{
            beforeEach(^{
                [subject setUpWithSelectionScreenType:ClientSelection punchCardObject:nil delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(@"Select a Client", nil));
            });

            it(@"should set the search bar title and place holder correctly", ^{
                subject.searchBar.returnKeyType should equal(UIReturnKeyDone);
                subject.searchBar.text should equal(@"");
                subject.searchBar.placeholder should equal(RPLocalizedString(@"Search Client", nil));
                
            });
        });

        context(@"Project selection screen", ^{
            beforeEach(^{
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:nil delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(@"Select a Project", nil));
            });

            it(@"should set the search bar title and place holder correctly", ^{
                subject.searchBar.returnKeyType should equal(UIReturnKeyDone);
                subject.searchBar.text should equal(@"");
                subject.searchBar.placeholder should equal(RPLocalizedString(@"Search Project", nil));

            });
        });

        context(@"Task selection screen", ^{
            beforeEach(^{
                [subject setUpWithSelectionScreenType:TaskSelection punchCardObject:nil delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(@"Select a Task", nil));
            });

            it(@"should set the search bar title and place holder correctly", ^{
                subject.searchBar.returnKeyType should equal(UIReturnKeyDone);
                subject.searchBar.text should equal(@"");
                subject.searchBar.placeholder should equal(RPLocalizedString(@"Search Task", nil));

            });
        });

        context(@"Activity selection screen", ^{
            beforeEach(^{
                [subject setUpWithSelectionScreenType:ActivitySelection punchCardObject:nil delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(@"Select an Activity", nil));
            });

            it(@"should set the search bar title and place holder correctly", ^{
                subject.searchBar.returnKeyType should equal(UIReturnKeyDone);
                subject.searchBar.text should equal(@"");
                subject.searchBar.placeholder should equal(RPLocalizedString(@"Search Activity", nil));

            });
        });

        context(@"OEF Dropdown selection screen", ^{
            beforeEach(^{
                [subject setUpWithSelectionScreenType:OEFDropDownSelection punchCardObject:nil delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should set the title correctly", ^{
                subject.title should equal(RPLocalizedString(@"Select OEF Dropdown Options", nil));
            });

            it(@"should set the search bar title and place holder correctly", ^{
                subject.searchBar.returnKeyType should equal(UIReturnKeyDone);
                subject.searchBar.text should equal(@"");
                subject.searchBar.placeholder should equal(RPLocalizedString(@"Search OEF Dropdown Options", nil));

            });
        });
    });

    describe(@"As a UISearchBarDelegate", ^{

        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
            spy_on(subject.searchBar);
        });
        context(@"-searchBarShouldBeginEditing:", ^{
            beforeEach(^{
                [subject searchBarShouldBeginEditing:subject.searchBar];
            });
            it(@"should enable Return Key Automatically", ^{
                subject.searchBar.enablesReturnKeyAutomatically should_not be_truthy;
            });
        });

        context(@"-searchBar:textDidChange:", ^{

            __block PunchCardObject *punchCardObject;
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = YES;

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:client
                                                           projectType:project
                                                         oefTypesArray:nil
                                                             breakType:NULL
                                                              taskType:task
                                                              activity:NULL
                                                                   uri:nil];
            });
            context(@"Client selection screen", ^{
                __block KSDeferred *cachedClientsDeferred;
                beforeEach(^{
                    cachedClientsDeferred = [[KSDeferred alloc]init];
                    clientRepository stub_method(@selector(fetchCachedClientsMatchingText:)).with(@"text-change").and_return(cachedClientsDeferred.promise);
                    [subject setUpWithSelectionScreenType:ClientSelection punchCardObject:punchCardObject delegate:delegate];
                    [subject view];
                    [subject viewWillAppear:NO];
                });
                beforeEach(^{
                    [subject searchBar:subject.searchBar textDidChange:@"text-change"];
                });

                it(@"should ask the client repository to fetch cached clients to show immediately ", ^{
                    clientRepository should have_received(@selector(fetchCachedClientsMatchingText:)).with(@"text-change");
                });

                it(@"should schedule a timer to fire a event for search", ^{
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(0.2, subject, @selector(fetchDataAfterDelayFromTimer:), @"text-change", NO);
                });

                it(@"should store the serach text in user defaults", ^{
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"text-change",RequestMadeForSearchWithValue);
                    userDefaults should have_received(@selector(synchronize));
                    
                });

                context(@"When cached clients is fetched", ^{
                    __block ClientType *clientA;
                    __block ClientType *clientB;
                    __block ClientType *clientC;

                    beforeEach(^{
                        clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        NSDictionary *data = @{@"clients":@[clientA,clientB,clientC],
                                               @"downloadCount":@3};
                        [cachedClientsDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(5);
                        
                        SizeCell *cellG = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellG.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                        
                        SizeCell *cellH = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellH.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellA.valueLabel.text should equal(@"ClientNameA");

                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellB.valueLabel.text should equal(@"ClientNameB");

                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                        cellC.valueLabel.text should equal(@"ClientNameC");
                        
                        cellA.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellA.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);

                        cellB.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellB.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);

                        cellC.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellC.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);

                    });

                });

                context(@"When cached clients fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [cachedClientsDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });

                context(@"When the timer fires for client search after delay", ^{
                    __block KSDeferred *searchClientDeferred;
                    __block NSTimer *timer;
                    beforeEach(^{

                        timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                                 target:subject
                                                               selector:@selector(fetchDataAfterDelayFromTimer:)
                                                               userInfo:@"client-text"
                                                                repeats:YES];
                        timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                            :repeats:)).and_return(timer);
                        [clientRepository reset_sent_messages];
                        searchClientDeferred = [[KSDeferred alloc]init];
                        clientRepository stub_method(@selector(fetchClientsMatchingText:)).with(@"client-text").and_return(searchClientDeferred.promise);

                        [subject fetchDataAfterDelayFromTimer:timer];

                    });

                    it(@"should ask the client repository for matching text clients", ^{
                        clientRepository should have_received(@selector(fetchClientsMatchingText:)).with(@"client-text");
                    });

                    context(@"When clients fetch with match text is successfull", ^{
                        beforeEach(^{
                            ClientType *clientA = [[ClientType alloc] initWithName:@"NewClientNameA" uri:@"ClientUriA"];
                            ClientType *clientB = [[ClientType alloc] initWithName:@"NewClientNameB" uri:@"ClientUriB"];
                            ClientType *clientC = [[ClientType alloc] initWithName:@"NewClientNameC" uri:@"ClientUriC"];
  
                            NSDictionary *data = @{@"clients":@[clientA,clientB,clientC],
                                                   @"downloadCount":@3};
                            [searchClientDeferred resolveWithValue:data];
                        });

                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(5);
                            
                            SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellD.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                            
                            SizeCell *cellE = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                            cellE.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));
                            
                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            cellA.valueLabel.text should equal(@"NewClientNameA");
                            
                            SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                            cellB.valueLabel.text should equal(@"NewClientNameB");
                            
                            SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                            cellC.valueLabel.text should equal(@"NewClientNameC");

                            cellA.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                            cellA.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                            
                            cellB.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                            cellB.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                            
                            cellC.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                            cellC.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);

                        });
                    });

                    context(@"When clients fetch with match text fails", ^{
                        beforeEach(^{
                            NSError *error = nice_fake_for([NSError class]);
                            [searchClientDeferred rejectWithError:error];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                    });
                });

            });

            context(@"Project selection screen", ^{
                __block KSDeferred *cachedProjectsDeferred;
                beforeEach(^{
                    cachedProjectsDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchCachedProjectsMatchingText:clientUri:)).with(@"text-change",@"client-uri").and_return(cachedProjectsDeferred.promise);
                    [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                    [subject view];
                    [subject viewWillAppear:NO];
                });
                beforeEach(^{
                    [subject searchBar:subject.searchBar textDidChange:@"text-change"];
                });

                it(@"should ask the project repository to fetch cached projects to show immediately ", ^{
                    projectRepository should have_received(@selector(fetchCachedProjectsMatchingText:clientUri:)).with(@"text-change",@"client-uri");
                });

                it(@"should schedule a timer to fire a event for search", ^{
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(0.2, subject, @selector(fetchDataAfterDelayFromTimer:), @"text-change", NO);
                });

                it(@"should store the serach text in user defaults", ^{
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"text-change",RequestMadeForSearchWithValue);
                    userDefaults should have_received(@selector(synchronize));
                    
                });

                context(@"When cached projects fetch succeeds", ^{
                    __block ProjectType *projectA;
                    __block ProjectType *projectB;
                    __block ProjectType *projectC;
                    beforeEach(^{
                        ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientA);

                        ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientB);

                        ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientC);

                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [cachedProjectsDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(3);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"ProjectNameC");
                        
                        cellA.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellA.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                        
                        cellB.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellB.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                        
                        cellC.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellC.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);


                    });

                });

                context(@"When cached projects fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [cachedProjectsDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });

                context(@"When the timer fires for project search after delay", ^{
                    __block KSDeferred *searchProjectDeferred;
                    __block NSTimer *timer;
                    beforeEach(^{

                        timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                                 target:subject
                                                               selector:@selector(fetchDataAfterDelayFromTimer:)
                                                               userInfo:@"client-text"
                                                                repeats:YES];
                        timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                            :repeats:)).and_return(timer);
                        [projectRepository reset_sent_messages];
                        searchProjectDeferred = [[KSDeferred alloc]init];
                        projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri").and_return(searchProjectDeferred.promise);

                        [subject fetchDataAfterDelayFromTimer:timer];

                    });

                    it(@"should ask the project repository for matching text projects", ^{
                        projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri");
                    });

                    context(@"When projects fetch with match text is successfull", ^{
                        __block ProjectType *projectA;
                        __block ProjectType *projectB;
                        __block ProjectType *projectC;
                        beforeEach(^{
                            ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                            projectA = nice_fake_for([ProjectType class]);
                            projectA stub_method(@selector(name)).and_return(@"NewProjectNameA");
                            projectA stub_method(@selector(client)).and_return(clientA);

                            ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                            projectB = nice_fake_for([ProjectType class]);
                            projectB stub_method(@selector(name)).and_return(@"NewProjectNameB");
                            projectB stub_method(@selector(client)).and_return(clientB);

                            ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                            projectC = nice_fake_for([ProjectType class]);
                            projectC stub_method(@selector(name)).and_return(@"NewProjectNameC");
                            projectC stub_method(@selector(client)).and_return(clientC);

                            NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                                   @"downloadCount":@3};
                            [searchProjectDeferred resolveWithValue:data];
                        });


                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(3);

                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellA.valueLabel.text should equal(@"NewProjectNameA");
                            
                            SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                            cellB.valueLabel.text should equal(@"NewProjectNameB");
                            
                            SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            cellC.valueLabel.text should equal(@"NewProjectNameC");

                        });
                    });

                    context(@"When projects fetch with match text fails", ^{
                        beforeEach(^{
                            NSError *error = nice_fake_for([NSError class]);
                            [searchProjectDeferred rejectWithError:error];
                        });

                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                    });
                });

            });

            context(@"Task selection screen", ^{
                __block KSDeferred *cachedTasksDeferred;
                beforeEach(^{
                    cachedTasksDeferred = [[KSDeferred alloc]init];
                    taskRepository stub_method(@selector(fetchCachedTasksMatchingText:projectUri:)).with(@"text-change",@"project-uri").and_return(cachedTasksDeferred.promise);
                    [subject setUpWithSelectionScreenType:TaskSelection punchCardObject:punchCardObject delegate:delegate];
                    [subject view];
                    [subject viewWillAppear:NO];
                });

                beforeEach(^{
                    [subject searchBar:subject.searchBar textDidChange:@"text-change"];
                });

                it(@"should ask the task repository to fetch cached tasks to show immediately ", ^{
                    taskRepository should have_received(@selector(fetchCachedTasksMatchingText:projectUri:)).with(@"text-change",@"project-uri");
                });

                it(@"should schedule a timer to fire a event for search", ^{
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(0.2, subject, @selector(fetchDataAfterDelayFromTimer:), @"text-change", NO);
                });

                it(@"should store the serach text in user defaults", ^{
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"text-change",RequestMadeForSearchWithValue);
                    userDefaults should have_received(@selector(synchronize));
                    
                });
                

                context(@"When cached tasks fetch succeeds", ^{
                    __block TaskType *taskA;
                    __block TaskType *taskB;
                    __block TaskType *taskC;

                    beforeEach(^{
                        taskA = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task-name-A" uri:@"task-uri-A"];
                        taskB = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task-name-B" uri:@"task-uri-B"];
                        taskC = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task-name-C" uri:@"task-uri-C"];
                        NSDictionary *data = @{@"tasks":@[taskA,taskB,taskC],
                                               @"downloadCount":@3};
                        [cachedTasksDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(3);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"task-name-A");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"task-name-B");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"task-name-C");

                    });

                });

                context(@"When cached tasks fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [cachedTasksDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });

                context(@"When the timer fires for task search after delay", ^{
                    __block KSDeferred *searchTaskDeferred;
                    __block NSTimer *timer;
                    beforeEach(^{

                        timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                                 target:subject
                                                               selector:@selector(fetchDataAfterDelayFromTimer:)
                                                               userInfo:@"client-text"
                                                                repeats:YES];
                        timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                            :repeats:)).and_return(timer);
                        [taskRepository reset_sent_messages];
                        searchTaskDeferred = [[KSDeferred alloc]init];
                        taskRepository stub_method(@selector(fetchTasksMatchingText:projectUri:)).with(@"client-text",@"project-uri").and_return(searchTaskDeferred.promise);

                        [subject fetchDataAfterDelayFromTimer:timer];

                    });

                    it(@"should ask the task repository for matching text tasks", ^{
                        taskRepository should have_received(@selector(fetchTasksMatchingText:projectUri:)).with(@"client-text",@"project-uri");
                    });

                    context(@"When tasks fetch with match text is successfull", ^{
                        __block TaskType *taskA;
                        __block TaskType *taskB;
                        __block TaskType *taskC;

                        beforeEach(^{
                            taskA = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"new-task-name-A" uri:@"task-uri-A"];
                            taskB = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"new-task-name-B" uri:@"task-uri-B"];
                            taskC = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"new-task-name-C" uri:@"task-uri-C"];
                            NSDictionary *data = @{@"tasks":@[taskA,taskB,taskC],
                                                   @"downloadCount":@3};
                            [searchTaskDeferred resolveWithValue:data];
                        });


                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(3);

                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellA.valueLabel.text should equal(@"new-task-name-A");
                            
                            SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                            cellB.valueLabel.text should equal(@"new-task-name-B");
                            
                            SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            cellC.valueLabel.text should equal(@"new-task-name-C");

                        });
                    });
                    
                    context(@"When tasks fetch with match text is successfull and match text has fullpath", ^{
                        __block TaskType *taskA;
                        __block TaskType *taskB;
                        __block TaskType *taskC;
                        
                        beforeEach(^{
                            taskA = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"Product Mantaienance & Problems / new-task-name-A" uri:@"task-uri-A"];
                            taskB = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"new-task-name-B" uri:@"task-uri-B"];
                            taskC = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"new-task-name-C" uri:@"task-uri-C"];
                            NSDictionary *data = @{@"tasks":@[taskA,taskB,taskC],
                                                   @"downloadCount":@3};
                            [searchTaskDeferred resolveWithValue:data];
                        });
                        
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(3);
                            
                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellA.valueLabel.text should equal(@"Product Mantaienance & Problems / new-task-name-A");
                        });
                    });

                    context(@"When tasks fetch with match text fails", ^{
                        beforeEach(^{
                            NSError *error = nice_fake_for([NSError class]);
                            [searchTaskDeferred rejectWithError:error];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                    });
                });
                
                context(@"Tasks are empty", ^{
                    
                    context(@"When tasks are empty and hasTasksAvailableForTimeAllocation is false", ^{
                        __block KSDeferred *projectDeferred;
                        beforeEach(^{
                            NSDictionary *data = @{@"tasks":@[],
                                                   @"downloadCount":@3};
                            
                            projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(nil).and_return(projectDeferred.promise);
                            ClientType *client = nice_fake_for([ClientType class]);
                            ProjectType *project = nice_fake_for([ProjectType class]);
                            project stub_method(@selector(hasTasksAvailableForTimeAllocation)).and_return(NO);
                            TaskType *task = nice_fake_for([TaskType class]);
                            
                            PunchCardObject *punchCardObject = nice_fake_for([PunchCardObject class]);
                            punchCardObject stub_method(@selector(clientType)).and_return(client);
                            punchCardObject stub_method(@selector(projectType)).and_return(project);
                            punchCardObject stub_method(@selector(taskType)).and_return(task);
                            
                            [subject setUpWithSelectionScreenType:TaskSelection punchCardObject:punchCardObject delegate:nil];
                            
                            [cachedTasksDeferred resolveWithValue:data];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(1);
                            
                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellA.valueLabel.text should equal(@"None");
                            

                        });
                        
                    });
                    
                    context(@"When tasks are empty and hasTasksAvailableForTimeAllocation is false", ^{
                        __block KSDeferred *projectDeferred;
                        beforeEach(^{
                            NSDictionary *data = @{@"tasks":@[],
                                                   @"downloadCount":@3};
                            
                            projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(nil).and_return(projectDeferred.promise);
                            ClientType *client = nice_fake_for([ClientType class]);
                            ProjectType *project = nice_fake_for([ProjectType class]);
                            project stub_method(@selector(hasTasksAvailableForTimeAllocation)).and_return(YES);
                            TaskType *task = nice_fake_for([TaskType class]);
                            
                            PunchCardObject *punchCardObject = nice_fake_for([PunchCardObject class]);
                            punchCardObject stub_method(@selector(clientType)).and_return(client);
                            punchCardObject stub_method(@selector(projectType)).and_return(project);
                            punchCardObject stub_method(@selector(taskType)).and_return(task);
                            
                            [subject setUpWithSelectionScreenType:TaskSelection punchCardObject:punchCardObject delegate:nil];
                            
                            [cachedTasksDeferred resolveWithValue:data];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                        
                    });
                });
                
            });

            context(@"Activity selection screen", ^{
                __block KSDeferred *cachedClientsDeferred;
                beforeEach(^{
                    cachedClientsDeferred = [[KSDeferred alloc]init];
                    activityRepository stub_method(@selector(fetchCachedActivitiesMatchingText:)).with(@"text-change").and_return(cachedClientsDeferred.promise);
                    [subject setUpWithSelectionScreenType:ActivitySelection punchCardObject:punchCardObject delegate:delegate];
                    [subject view];
                    [subject viewWillAppear:NO];
                });
                beforeEach(^{
                    [subject searchBar:subject.searchBar textDidChange:@"text-change"];
                });

                it(@"should ask the activity repository to fetch cached activities to show immediately ", ^{
                    activityRepository should have_received(@selector(fetchCachedActivitiesMatchingText:)).with(@"text-change");
                });

                it(@"should schedule a timer to fire a event for search", ^{
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(0.2, subject, @selector(fetchDataAfterDelayFromTimer:), @"text-change", NO);
                });

                it(@"should store the searach text in user defaults", ^{
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"text-change",RequestMadeForSearchWithValue);
                    userDefaults should have_received(@selector(synchronize));

                });

                context(@"When cached activities is fetched", ^{
                    __block Activity *activityA;
                    __block Activity *activityB;
                    __block Activity *activityC;

                    beforeEach(^{
                        activityA = [[Activity alloc] initWithName:@"activity-name-A" uri:@"activity-uri-A"];
                        activityB = [[Activity alloc] initWithName:@"activity-name-B" uri:@"activity-uri-B"];
                        activityC = [[Activity alloc] initWithName:@"activity-name-C" uri:@"activity-uri-C"];
                        NSDictionary *data = @{@"activities":@[activityA,activityB,activityC],
                                               @"downloadCount":@3};
                        [cachedClientsDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(3);
                       
                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"activity-name-A");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"activity-name-B");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"activity-name-C");

                    });

                });

                context(@"When cached activities fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [cachedClientsDeferred rejectWithError:error];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });

                context(@"When the timer fires for activity search after delay", ^{
                    __block KSDeferred *searchClientDeferred;
                    __block NSTimer *timer;
                    beforeEach(^{

                        timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                                 target:subject
                                                               selector:@selector(fetchDataAfterDelayFromTimer:)
                                                               userInfo:@"client-text"
                                                                repeats:YES];
                        timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                            :repeats:)).and_return(timer);
                        [clientRepository reset_sent_messages];
                        searchClientDeferred = [[KSDeferred alloc]init];
                        activityRepository stub_method(@selector(fetchActivitiesMatchingText:)).with(@"client-text").and_return(searchClientDeferred.promise);

                        [subject fetchDataAfterDelayFromTimer:timer];

                    });

                    it(@"should ask the activity repository for matching text activities", ^{
                        activityRepository should have_received(@selector(fetchActivitiesMatchingText:)).with(@"client-text");
                    });

                    context(@"When activities fetch with match text is successfull", ^{
                        beforeEach(^{
                            Activity *activityA = [[Activity alloc] initWithName:@"new-activity-name-A" uri:@"new-activity-uri-A"];
                            Activity *activityB = [[Activity alloc] initWithName:@"new-activity-name-B" uri:@"new-activity-uri-B"];
                            Activity *activityC = [[Activity alloc] initWithName:@"new-activity-name-C" uri:@"new-activity-uri-C"];
                            NSDictionary *data = @{@"activities":@[activityA,activityB,activityC],
                                                   @"downloadCount":@3};
                            [searchClientDeferred resolveWithValue:data];
                        });

                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(3);

                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellA.valueLabel.text should equal(@"new-activity-name-A");
                            
                            SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                            cellB.valueLabel.text should equal(@"new-activity-name-B");
                            
                            SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            cellC.valueLabel.text should equal(@"new-activity-name-C");

                        });
                    });

                    context(@"When activities fetch with match text fails", ^{
                        beforeEach(^{
                            NSError *error = nice_fake_for([NSError class]);
                            [searchClientDeferred rejectWithError:error];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                    });
                });
                
            });

            context(@"OEF DropDown selection screen", ^{
                __block KSDeferred *cachedClientsDeferred;
                beforeEach(^{
                    cachedClientsDeferred = [[KSDeferred alloc]init];
                    oefDropDownRepository stub_method(@selector(fetchCachedOEFDropDownOptionsMatchingText:)).with(@"text-change").and_return(cachedClientsDeferred.promise);
                    [subject setUpWithSelectionScreenType:OEFDropDownSelection punchCardObject:punchCardObject delegate:delegate];
                    [subject view];
                    [subject viewWillAppear:NO];
                });
                beforeEach(^{
                    [subject searchBar:subject.searchBar textDidChange:@"text-change"];
                });

                it(@"should ask the oefdropdown repository to fetch cached oefdropdown to show immediately ", ^{
                    oefDropDownRepository should have_received(@selector(fetchCachedOEFDropDownOptionsMatchingText:)).with(@"text-change");
                });

                it(@"should schedule a timer to fire a event for search", ^{
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(0.2, subject, @selector(fetchDataAfterDelayFromTimer:), @"text-change", NO);
                });

                it(@"should store the searach text in user defaults", ^{
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"text-change",RequestMadeForSearchWithValue);
                    userDefaults should have_received(@selector(synchronize));

                });

                context(@"When cached oefdropdowns is fetched", ^{
                    __block OEFDropDownType *oefDropDownTypeA;
                    __block OEFDropDownType *oefDropDownTypeB;
                    __block OEFDropDownType *oefDropDownTypeC;

                    beforeEach(^{
                        oefDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"oefDropDownType-name-A" uri:@"oefDropDownType-uri-A"];
                        oefDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"oefDropDownType-name-B" uri:@"oefDropDownType-uri-B"];
                        oefDropDownTypeC = [[OEFDropDownType alloc] initWithName:@"oefDropDownType-name-C" uri:@"oefDropDownType-uri-C"];
                        NSDictionary *data = @{@"oefDropDownOptions":@[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC],
                                               @"downloadCount":@3};
                        [cachedClientsDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(3);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"oefDropDownType-name-A");

                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"oefDropDownType-name-B");

                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"oefDropDownType-name-C");

                    });

                });

                context(@"When cached oefdropdowns fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [cachedClientsDeferred rejectWithError:error];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });

                context(@"When the timer fires for activity search after delay", ^{
                    __block KSDeferred *searchClientDeferred;
                    __block NSTimer *timer;
                    beforeEach(^{

                        timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                                 target:subject
                                                               selector:@selector(fetchDataAfterDelayFromTimer:)
                                                               userInfo:@"client-text"
                                                                repeats:YES];
                        timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                            :repeats:)).and_return(timer);
                        [clientRepository reset_sent_messages];
                        searchClientDeferred = [[KSDeferred alloc]init];
                        oefDropDownRepository stub_method(@selector(fetchOEFDropDownOptionsMatchingText:)).with(@"client-text").and_return(searchClientDeferred.promise);

                        [subject fetchDataAfterDelayFromTimer:timer];

                    });

                    it(@"should ask the oefdropdown repository for matching text oefdropdowns", ^{
                        oefDropDownRepository should have_received(@selector(fetchOEFDropDownOptionsMatchingText:)).with(@"client-text");
                    });

                    context(@"When oefdropdown fetch with match text is successfull", ^{
                        beforeEach(^{
                            OEFDropDownType *oefDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"new-oefDropDownType-name-A" uri:@"new-oefDropDownType-uri-A"];
                            OEFDropDownType *oefDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"new-oefDropDownType-name-B" uri:@"new-oefDropDownType-uri-B"];
                            OEFDropDownType *oefDropDownTypeC = [[OEFDropDownType alloc] initWithName:@"new-oefDropDownType-name-C" uri:@"new-oefDropDownType-uri-C"];
                            NSDictionary *data = @{@"oefDropDownOptions":@[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC],
                                                   @"downloadCount":@3};
                            [searchClientDeferred resolveWithValue:data];
                        });

                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(3);

                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellA.valueLabel.text should equal(@"new-oefDropDownType-name-A");

                            SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                            cellB.valueLabel.text should equal(@"new-oefDropDownType-name-B");

                            SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            cellC.valueLabel.text should equal(@"new-oefDropDownType-name-C");

                        });
                    });

                    context(@"When oefdropdown fetch with match text fails", ^{
                        beforeEach(^{
                            NSError *error = nice_fake_for([NSError class]);
                            [searchClientDeferred rejectWithError:error];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                    });
                });
                
            });

        });

        context(@"-searchBarSearchButtonClicked:", ^{
            beforeEach(^{
                [subject searchBarSearchButtonClicked:subject.searchBar];
            });

            it(@"should resign the keyboard if done button is clicked clients", ^{
                subject.searchBar should have_received(@selector(resignFirstResponder));
            });

        });
    });
    
    describe(@"As a UISearchBarDelegate and Project selection is optional", ^{
        
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
            spy_on(subject.searchBar);
        });
        context(@"-searchBarShouldBeginEditing:", ^{
            beforeEach(^{
                [subject searchBarShouldBeginEditing:subject.searchBar];
            });
            it(@"should enable Return Key Automatically", ^{
                subject.searchBar.enablesReturnKeyAutomatically should_not be_truthy;
            });
        });
        
        context(@"-searchBar:textDidChange:", ^{
            
            __block PunchCardObject *punchCardObject;
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = NO;
                
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                punchCardObject = [[PunchCardObject alloc]
                                   initWithClientType:client
                                   projectType:project
                                   oefTypesArray:nil
                                   breakType:NULL
                                   taskType:task
                                   activity:NULL
                                   uri:nil];
            });
            
            context(@"Project selection screen", ^{
                __block KSDeferred *cachedProjectsDeferred;
                beforeEach(^{
                    cachedProjectsDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchCachedProjectsMatchingText:clientUri:)).with(@"text-change",@"client-uri").and_return(cachedProjectsDeferred.promise);
                    [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                    [subject view];
                    [subject viewWillAppear:NO];
                });
                beforeEach(^{
                    [subject searchBar:subject.searchBar textDidChange:@"text-change"];
                });
                
                it(@"should ask the project repository to fetch cached projects to show immediately ", ^{
                    projectRepository should have_received(@selector(fetchCachedProjectsMatchingText:clientUri:)).with(@"text-change",@"client-uri");
                });
                
                it(@"should schedule a timer to fire a event for search", ^{
                    timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(0.2, subject, @selector(fetchDataAfterDelayFromTimer:), @"text-change", NO);
                });
                
                it(@"should store the serach text in user defaults", ^{
                    userDefaults should have_received(@selector(setObject:forKey:)).with(@"text-change",RequestMadeForSearchWithValue);
                    userDefaults should have_received(@selector(synchronize));
                    
                });
                
                context(@"When cached projects fetch succeeds", ^{
                    __block ProjectType *projectA;
                    __block ProjectType *projectB;
                    __block ProjectType *projectC;
                    beforeEach(^{
                        ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientA);
                        
                        ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientB);
                        
                        ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientC);
                        
                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [cachedProjectsDeferred resolveWithValue:data];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(4);
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellD.valueLabel.text should equal(@"None");
                        
                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellA.valueLabel.text should equal(@"ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellB.valueLabel.text should equal(@"ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellC.valueLabel.text should equal(@"ProjectNameC");
                        
                        cellA.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellA.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                        
                        cellB.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellB.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                        
                        cellC.valueLabelTopPaddingConstraint.constant should equal((CGFloat)4.0f);
                        cellC.valueLabelBottomPaddingConstraint.constant should equal((CGFloat)4.0f);
                        
                        
                    });
                    
                });
                
                context(@"When cached projects fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [cachedProjectsDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });
                
                context(@"When the timer fires for project search after delay", ^{
                    __block KSDeferred *searchProjectDeferred;
                    __block NSTimer *timer;
                    beforeEach(^{
                        
                        timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                                 target:subject
                                                               selector:@selector(fetchDataAfterDelayFromTimer:)
                                                               userInfo:@"client-text"
                                                                repeats:YES];
                        timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                            :repeats:)).and_return(timer);
                        [projectRepository reset_sent_messages];
                        searchProjectDeferred = [[KSDeferred alloc]init];
                        projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri").and_return(searchProjectDeferred.promise);
                        
                        [subject fetchDataAfterDelayFromTimer:timer];
                        
                    });
                    
                    it(@"should ask the project repository for matching text projects", ^{
                        projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri");
                    });
                    
                    context(@"When projects fetch with match text is successfull", ^{
                        __block ProjectType *projectA;
                        __block ProjectType *projectB;
                        __block ProjectType *projectC;
                        beforeEach(^{
                            ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                            projectA = nice_fake_for([ProjectType class]);
                            projectA stub_method(@selector(name)).and_return(@"NewProjectNameA");
                            projectA stub_method(@selector(client)).and_return(clientA);
                            
                            ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                            projectB = nice_fake_for([ProjectType class]);
                            projectB stub_method(@selector(name)).and_return(@"NewProjectNameB");
                            projectB stub_method(@selector(client)).and_return(clientB);
                            
                            ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                            projectC = nice_fake_for([ProjectType class]);
                            projectC stub_method(@selector(name)).and_return(@"NewProjectNameC");
                            projectC stub_method(@selector(client)).and_return(clientC);
                            
                            NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                                   @"downloadCount":@3};
                            [searchProjectDeferred resolveWithValue:data];
                        });
                        
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(4);
                            
                            SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                            cellD.valueLabel.text should equal(@"None");
                            
                            SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                            cellA.valueLabel.text should equal(@"NewProjectNameA");
                            
                            SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                            cellB.valueLabel.text should equal(@"NewProjectNameB");
                            
                            SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                            cellC.valueLabel.text should equal(@"NewProjectNameC");
                            
                        });
                    });
                    
                    context(@"When projects fetch with match text fails", ^{
                        beforeEach(^{
                            NSError *error = nice_fake_for([NSError class]);
                            [searchProjectDeferred rejectWithError:error];
                        });
                        
                        it(@"should display correct cells", ^{
                            subject.tableView.visibleCells.count should equal(0);
                        });
                    });
                });
                
            });
            
        });
        
        context(@"-searchBarSearchButtonClicked:", ^{
            beforeEach(^{
                [subject searchBarSearchButtonClicked:subject.searchBar];
            });
            
            it(@"should resign the keyboard if done button is clicked clients", ^{
                subject.searchBar should have_received(@selector(resignFirstResponder));
            });
            
        });
    });

    describe(@"When screen type is client Selection screen", ^{
        __block KSDeferred *clientDeferred;
        __block UINavigationController *navigationController;
        beforeEach(^{
            clientDeferred = [[KSDeferred alloc]init];
            clientRepository stub_method(@selector(fetchAllClients)).and_return(clientDeferred.promise);
            [subject setUpWithSelectionScreenType:ClientSelection punchCardObject:nil delegate:delegate];
            [subject view];
            [subject viewWillAppear:NO];

            navigationController = [[UINavigationController alloc]initWithRootViewController:subject];

            spy_on(subject.searchBar);
        });

        it(@"should fetch clients from client repository", ^{
            clientRepository should have_received(@selector(fetchAllClients));
        });

        context(@"When clients is fetched successfully intially", ^{
            __block ClientType *clientA;
            __block ClientType *clientB;
            __block ClientType *clientC;
            __block ClientType *clientD;
            __block ClientType *clientE;

            beforeEach(^{
                clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                clientD = [[ClientType alloc] initWithName:@"Any Client" uri:ClientTypeAnyClientUri];
                clientE = [[ClientType alloc] initWithName:@"No Client" uri:ClientTypeNoClientUri];
                
                NSDictionary *data = @{@"clients":@[clientA,clientB,clientC],
                                       @"downloadCount":@3};
                [clientDeferred resolveWithValue:data];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(5);
                
                SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellD.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                
                SizeCell *cellE = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellE.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellA.valueLabel.text should equal(@"ClientNameA");
                
                SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                cellB.valueLabel.text should equal(@"ClientNameB");
                
                SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                cellC.valueLabel.text should equal(@"ClientNameC");
                
            });

            it(@"should navigate back to card controller with the updated punch card object", ^{
                [subject.tableView.visibleCells.firstObject tap];

                delegate should have_received(@selector(selectionController:didChooseClient:)).with(Arguments::anything,clientD);
                navigationController.topViewController should_not be_instance_of(subject);
            });
        });

        context(@"When clients fetch fails intially", ^{
            beforeEach(^{
                NSError *error = nice_fake_for([NSError class]);
                [clientDeferred rejectWithError:error];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(0);
            });
        });


    });

    describe(@"When screen type is client Selection screen for Expense Module", ^{
        __block KSDeferred *clientDeferred;
        __block UINavigationController *navigationController;
        beforeEach(^{
            subject = [injector getInstance:InjectorKeySelectionControllerForExpensesModule];

            clientDeferred = [[KSDeferred alloc]init];
            clientRepository stub_method(@selector(fetchAllClients)).and_return(clientDeferred.promise);
            [subject setUpWithSelectionScreenType:ClientSelection punchCardObject:nil delegate:delegate];
            [subject view];
            [subject viewWillAppear:NO];

            navigationController = [[UINavigationController alloc]initWithRootViewController:subject];

            spy_on(subject.searchBar);
        });

        it(@"should fetch clients from client repository", ^{
            clientRepository should have_received(@selector(fetchAllClients));
        });

        context(@"When clients is fetched successfully intially", ^{
            __block ClientType *clientA;
            __block ClientType *clientB;
            __block ClientType *clientC;


            beforeEach(^{
                clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];


                NSDictionary *data = @{@"clients":@[clientA,clientB,clientC],
                                       @"downloadCount":@3};
                [clientDeferred resolveWithValue:data];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(3);

                SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellA.valueLabel.text should equal(@"ClientNameA");

                SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellB.valueLabel.text should equal(@"ClientNameB");

                SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellC.valueLabel.text should equal(@"ClientNameC");

            });

            it(@"should navigate back to card controller with the updated punch card object", ^{
                [subject.tableView.visibleCells.firstObject tap];

                delegate should have_received(@selector(selectionController:didChooseClient:)).with(Arguments::anything,clientA);
                navigationController.topViewController should_not be_instance_of(subject);
            });
        });

        context(@"When clients fetch fails intially", ^{
            beforeEach(^{
                NSError *error = nice_fake_for([NSError class]);
                [clientDeferred rejectWithError:error];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(0);
            });
        });
        
        
    });

    describe(@"When screen type is project Selection screen", ^{
        __block KSDeferred *projectDeferred;
        __block UINavigationController *navigationController;
        
        beforeEach(^{
            projectDeferred = [[KSDeferred alloc]init];
        });

        context(@"When selecting a project filtered by client", ^{

            beforeEach(^{

                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri").and_return(projectDeferred.promise);
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = YES;

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                     initWithClientType:client
                                                                            projectType:project
                                                                          oefTypesArray:nil
                                                                              breakType:NULL
                                                                               taskType:task
                                                                               activity:NULL
                                                                                    uri:nil];

                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];

                spy_on(subject.searchBar);
            });


            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri");
            });

            context(@"When projects fetch succeeds intially", ^{
                __block ProjectType *projectA;
                __block ProjectType *projectB;
                __block ProjectType *projectC;
                beforeEach(^{
                    ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                    projectA = nice_fake_for([ProjectType class]);
                    projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                    projectA stub_method(@selector(client)).and_return(clientA);

                    ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                    projectB = nice_fake_for([ProjectType class]);
                    projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                    projectB stub_method(@selector(client)).and_return(clientB);

                    ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                    projectC = nice_fake_for([ProjectType class]);
                    projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                    projectC stub_method(@selector(client)).and_return(clientC);

                    NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                           @"downloadCount":@3};
                    [projectDeferred resolveWithValue:data];
                });

                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(3);

                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameC");

                });

                it(@"should navigate back to card controller with the updated punch card object", ^{
                    [subject.tableView.visibleCells.firstObject tap];

                    delegate should have_received(@selector(selectionController:didChooseProject:)).with(Arguments::anything,projectA);
                    navigationController.topViewController should_not be_instance_of(subject);
                });
            });

            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });

                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });

            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                beforeEach(^{

                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri").and_return(searchProjectDeferred.promise);

                    [subject fetchDataAfterDelayFromTimer:timer];

                });

                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri");
                });

                context(@"When projects fetch with match text is successfull", ^{
                    beforeEach(^{
                        ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        ProjectType *projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientA);

                        ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        ProjectType *projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientB);

                        ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        ProjectType *projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientC);

                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [searchProjectDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(3);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");

                    });
                });
                
                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });
            });

        });

        context(@"When selecting a project filtered by any client", ^{
            
            beforeEach(^{
                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(nil).and_return(projectDeferred.promise);
                ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:nil
                                                                                               uri:nil];
                project.isProjectTypeRequired = YES;

                TaskType *task = [[TaskType alloc]initWithProjectUri:nil
                                                          taskPeriod:nil
                                                                name:nil
                                                                 uri:nil];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                     initWithClientType:client
                                                                            projectType:project
                                                                          oefTypesArray:nil
                                                                              breakType:NULL
                                                                               taskType:task
                                                                               activity:NULL
                                                                                    uri:nil];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];

                spy_on(subject.searchBar);

            });

            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(nil);
            });

            context(@"When projects fetch succeeds intially", ^{
                __block ProjectType *projectA;
                beforeEach(^{
                    ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                    projectA = nice_fake_for([ProjectType class]);
                    projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                    projectA stub_method(@selector(client)).and_return(clientA);

                    ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                    ProjectType *projectB = nice_fake_for([ProjectType class]);
                    projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                    projectB stub_method(@selector(client)).and_return(clientB);

                    ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                    ProjectType *projectC = nice_fake_for([ProjectType class]);
                    projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                    projectC stub_method(@selector(client)).and_return(clientC);

                    NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                           @"downloadCount":@3};
                    [projectDeferred resolveWithValue:data];
                });

                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(3);

                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameC");

                });
                
                it(@"should navigate back to card controller with the updated punch card object", ^{
                    [subject.tableView.visibleCells.firstObject tap];
                    
                    delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectA);
                    navigationController.topViewController should_not be_instance_of(subject);
                });

            });

            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });

                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });


            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                beforeEach(^{

                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",nil).and_return(searchProjectDeferred.promise);

                    [subject fetchDataAfterDelayFromTimer:timer];

                });

                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",nil);
                });

                context(@"When projects fetch with match text succeeds", ^{
                    __block ProjectType *projectC;

                    beforeEach(^{
                        ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        ProjectType *projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientA);

                        ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        ProjectType *projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientB);

                        ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientC);

                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [searchProjectDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(3);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");

                    });
                    
                    it(@"should navigate back to card controller with the updated punch card object", ^{
                        [subject.tableView.visibleCells.lastObject tap];
                        
                        delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectC);
                        navigationController.topViewController should_not be_instance_of(subject);
                    });

                });
                
                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });
            });


        });
        
        context(@"When selecting a project filtered by no client", ^{
            
            beforeEach(^{
                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(nil).and_return(projectDeferred.promise);
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:nil
                                                                                               uri:nil];
                project.isProjectTypeRequired = YES;
                
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:nil
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:nil
                                                    taskType:nil
                                                    activity:nil
                                                    uri:nil];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
                
                spy_on(subject.searchBar);
                
            });
            
            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(nil);
            });
            
            context(@"When projects fetch succeeds intially", ^{
                __block ProjectType *projectA;
                __block ProjectType *projectB;
                __block ProjectType *projectC;

                beforeEach(^{
                    ClientType *clientType = [[ClientType alloc] initWithName:RPLocalizedString(ClientTypeNoClient, ClientTypeNoClient) uri:ClientTypeNoClientUri];

                    projectA = nice_fake_for([ProjectType class]);
                    projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                    projectA stub_method(@selector(client)).and_return(clientType);
                    
                    projectB = nice_fake_for([ProjectType class]);
                    projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                    projectB stub_method(@selector(client)).and_return(clientType);
                    
                    projectC = nice_fake_for([ProjectType class]);
                    projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                    projectC stub_method(@selector(client)).and_return(clientType);
                    
                    NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                           @"downloadCount":@3};
                    [projectDeferred resolveWithValue:data];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(3);
                    
                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameC");
                    
                });
                
                it(@"should navigate back to card controller with the updated punch card object", ^{
                    [subject.tableView.visibleCells.lastObject tap];
                    
                    delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectC);
                    navigationController.topViewController should_not be_instance_of(subject);
                });

            });
            
            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });
        });
        
        context(@"When projects are cached and service call fetching projects", ^{
            __block NSArray *expectedProjectsArray;
            __block ProjectType *projectA;
            __block ProjectType *projectB;
            __block ProjectType *projectC;
            __block ProjectType *projectD;
            beforeEach(^{
                
                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri").and_return(projectDeferred.promise);
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = YES;
                
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:client
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:NULL
                                                    taskType:task
                                                    activity:NULL
                                                    uri:nil];
                ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                projectA = nice_fake_for([ProjectType class]);
                projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                projectA stub_method(@selector(client)).and_return(clientA);
                
                ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                projectB = nice_fake_for([ProjectType class]);
                projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                projectB stub_method(@selector(client)).and_return(clientB);
                
                ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                projectC = nice_fake_for([ProjectType class]);
                projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                projectC stub_method(@selector(client)).and_return(clientC);

                ClientType *clientD = [[ClientType alloc] initWithName:@"ClientNameD" uri:@"ClientUriD"];
                projectD = nice_fake_for([ProjectType class]);
                projectD stub_method(@selector(name)).and_return(@"ProjectNameD");
                projectD stub_method(@selector(client)).and_return(clientD);
                
                expectedProjectsArray = @[projectA, projectB];
                projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);

                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
                
                spy_on(subject.searchBar);
            });
            
            
            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri");
            });
            
            context(@"When projects fetch succeeds intially", ^{
                beforeEach(^{
                    NSDictionary *data = @{@"projects":@[projectA, projectC, projectD],
                                           @"downloadCount":@4};
                    [projectDeferred resolveWithValue:data];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(3);
                    
                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameC");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameD");
                    

                });
            });
            
            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(2);

                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");

                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                });
            });
            
            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                __block ProjectType *newProjectA;
                __block ProjectType *newProjectB;
                __block ProjectType *newProjectC;
                __block ProjectType *newProjectD;
                beforeEach(^{
                    
                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri").and_return(searchProjectDeferred.promise);
                    
                    ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                    newProjectA = nice_fake_for([ProjectType class]);
                    newProjectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                    newProjectA stub_method(@selector(client)).and_return(clientA);
                    
                    ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                    newProjectB = nice_fake_for([ProjectType class]);
                    newProjectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                    newProjectB stub_method(@selector(client)).and_return(clientB);
                    
                    ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                    newProjectC = nice_fake_for([ProjectType class]);
                    newProjectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                    newProjectC stub_method(@selector(client)).and_return(clientC);

                    ClientType *clientD = [[ClientType alloc] initWithName:@"ClientNameD" uri:@"ClientUriD"];
                    newProjectD = nice_fake_for([ProjectType class]);
                    newProjectD stub_method(@selector(name)).and_return(@"New-ProjectNameD");
                    newProjectD stub_method(@selector(client)).and_return(clientD);

                    expectedProjectsArray = @[newProjectA, newProjectB];
                    projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").again().and_return(expectedProjectsArray);

                    [subject fetchDataAfterDelayFromTimer:timer];
                    
                });
                
                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri");
                });
                
                context(@"When projects fetch with match text is successfull", ^{
                    beforeEach(^{
                        
                        NSDictionary *data = @{@"projects":@[newProjectA, newProjectB, newProjectC, newProjectD],
                                               @"downloadCount":@4};
                        [searchProjectDeferred resolveWithValue:data];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(4);
                        
                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellD.valueLabel.text should equal(@"New-ProjectNameD");
                    });
                });
                
                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(2);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"ProjectNameA");

                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"ProjectNameB");
                    });
                });
            });
            
        });

        context(@"When projects are cached and service call fetching projects for Expense Module", ^{
            __block NSArray *expectedProjectsArray;
            __block ProjectType *projectA;
            __block ProjectType *projectB;
            __block ProjectType *projectC;
            __block ProjectType *projectD;
            beforeEach(^{

                subject = [injector getInstance:InjectorKeySelectionControllerForExpensesModule];

                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri").and_return(projectDeferred.promise);
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = YES;

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:client
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:NULL
                                                    taskType:task
                                                    activity:NULL
                                                    uri:nil];
                ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                projectA = nice_fake_for([ProjectType class]);
                projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                projectA stub_method(@selector(client)).and_return(clientA);

                ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                projectB = nice_fake_for([ProjectType class]);
                projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                projectB stub_method(@selector(client)).and_return(clientB);

                ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                projectC = nice_fake_for([ProjectType class]);
                projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                projectC stub_method(@selector(client)).and_return(clientC);

                ClientType *clientD = [[ClientType alloc] initWithName:@"ClientNameD" uri:@"ClientUriD"];
                projectD = nice_fake_for([ProjectType class]);
                projectD stub_method(@selector(name)).and_return(@"ProjectNameD");
                projectD stub_method(@selector(client)).and_return(clientD);

                expectedProjectsArray = @[projectA, projectB];
                expenseProjectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);

                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];

                spy_on(subject.searchBar);
            });


            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri");
            });

            context(@"When projects fetch succeeds intially", ^{
                beforeEach(^{
                    NSDictionary *data = @{@"projects":@[projectA, projectC, projectD],
                                           @"downloadCount":@4};
                    [projectDeferred resolveWithValue:data];
                });

                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(3);

                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");

                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameC");

                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameD");


                });
            });

            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });

                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });

            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                __block ProjectType *newProjectA;
                __block ProjectType *newProjectB;
                __block ProjectType *newProjectC;
                __block ProjectType *newProjectD;
                beforeEach(^{

                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri").and_return(searchProjectDeferred.promise);

                    ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                    newProjectA = nice_fake_for([ProjectType class]);
                    newProjectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                    newProjectA stub_method(@selector(client)).and_return(clientA);

                    ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                    newProjectB = nice_fake_for([ProjectType class]);
                    newProjectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                    newProjectB stub_method(@selector(client)).and_return(clientB);

                    ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                    newProjectC = nice_fake_for([ProjectType class]);
                    newProjectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                    newProjectC stub_method(@selector(client)).and_return(clientC);

                    ClientType *clientD = [[ClientType alloc] initWithName:@"ClientNameD" uri:@"ClientUriD"];
                    newProjectD = nice_fake_for([ProjectType class]);
                    newProjectD stub_method(@selector(name)).and_return(@"New-ProjectNameD");
                    newProjectD stub_method(@selector(client)).and_return(clientD);

                    expectedProjectsArray = @[newProjectA, newProjectB];
                    expenseProjectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").again().and_return(expectedProjectsArray);

                    [subject fetchDataAfterDelayFromTimer:timer];

                });

                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri");
                });

                context(@"When projects fetch with match text is successfull", ^{
                    beforeEach(^{

                        NSDictionary *data = @{@"projects":@[newProjectA, newProjectB, newProjectC, newProjectD],
                                               @"downloadCount":@4};
                        [searchProjectDeferred resolveWithValue:data];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(4);

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");

                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");

                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");

                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellD.valueLabel.text should equal(@"New-ProjectNameD");
                    });
                });

                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);

                    });
                });
            });
            
        });


    });
    
    describe(@"When screen type is project Selection screen and Project selection is optional", ^{
        __block KSDeferred *projectDeferred;
        __block UINavigationController *navigationController;
        
        beforeEach(^{
            projectDeferred = [[KSDeferred alloc]init];
        });
        
        context(@"When selecting a project filtered by client", ^{
            
            beforeEach(^{
                
                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri").and_return(projectDeferred.promise);
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = NO;
                
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:client
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:NULL
                                                    taskType:task
                                                    activity:NULL
                                                    uri:nil];
                
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
                
                spy_on(subject.searchBar);
            });
            
            
            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(@"client-uri");
            });
            
            context(@"When projects fetch succeeds intially", ^{
                __block ProjectType *projectA;
                __block ProjectType *projectB;
                __block ProjectType *projectC;
                beforeEach(^{
                    ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                    projectA = nice_fake_for([ProjectType class]);
                    projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                    projectA stub_method(@selector(client)).and_return(clientA);
                    
                    ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                    projectB = nice_fake_for([ProjectType class]);
                    projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                    projectB stub_method(@selector(client)).and_return(clientB);
                    
                    ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                    projectC = nice_fake_for([ProjectType class]);
                    projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                    projectC stub_method(@selector(client)).and_return(clientC);
                    
                    NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                           @"downloadCount":@3};
                    [projectDeferred resolveWithValue:data];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(4);
                    
                    SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellD.valueLabel.text should equal(@"None");
                    
                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameC");
                    
                });
                
                it(@"should navigate back to card controller with the updated punch card object", ^{
                    [subject.tableView.visibleCells.lastObject tap];
                    
                    delegate should have_received(@selector(selectionController:didChooseProject:)).with(Arguments::anything,projectC);
                    navigationController.topViewController should_not be_instance_of(subject);
                });
            });
            
            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });
            
            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                beforeEach(^{
                    
                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri").and_return(searchProjectDeferred.promise);
                    
                    [subject fetchDataAfterDelayFromTimer:timer];
                    
                });
                
                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",@"client-uri");
                });
                
                context(@"When projects fetch with match text is successfull", ^{
                    beforeEach(^{
                        ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        ProjectType *projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientA);
                        
                        ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        ProjectType *projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientB);
                        
                        ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        ProjectType *projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientC);
                        
                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [searchProjectDeferred resolveWithValue:data];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(4);
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellD.valueLabel.text should equal(@"None");
                        
                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");
                        
                    });
                });
                
                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });
            });
            
        });
        
        context(@"When selecting a project filtered by any client", ^{
            beforeEach(^{
                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(nil).and_return(projectDeferred.promise);
                ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:nil
                                                                                               uri:nil];
                project.isProjectTypeRequired = NO;
                
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil
                                                          taskPeriod:nil
                                                                name:nil
                                                                 uri:nil];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:client
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:NULL
                                                    taskType:task
                                                    activity:NULL
                                                    uri:nil];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
                
                spy_on(subject.searchBar);
                
            });
            
            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(nil);
            });
            
            context(@"When projects fetch succeeds intially", ^{
                __block ProjectType *projectC;
                beforeEach(^{
                    ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                    ProjectType *projectA = nice_fake_for([ProjectType class]);
                    projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                    projectA stub_method(@selector(client)).and_return(clientA);
                    
                    ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                    ProjectType *projectB = nice_fake_for([ProjectType class]);
                    projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                    projectB stub_method(@selector(client)).and_return(clientB);
                    
                    ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                    projectC = nice_fake_for([ProjectType class]);
                    projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                    projectC stub_method(@selector(client)).and_return(clientC);
                    
                    NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                           @"downloadCount":@3};
                    [projectDeferred resolveWithValue:data];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(4);
                    
                    SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellD.valueLabel.text should equal(@"None");
                    
                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameC");
                    
                });
                
                it(@"should navigate back to card controller with the updated punch card object", ^{
                    [subject.tableView.visibleCells.lastObject tap];
                    
                    delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectC);
                    navigationController.topViewController should_not be_instance_of(subject);
                });

            });
            
            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });
            
            
            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                beforeEach(^{
                    
                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",nil).and_return(searchProjectDeferred.promise);
                    
                    [subject fetchDataAfterDelayFromTimer:timer];
                    
                });
                
                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",nil);
                });
                
                context(@"When projects fetch with match text succeeds", ^{
                    __block ProjectType *projectC ;
                    beforeEach(^{
                        ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                        ProjectType *projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientA);
                        
                        ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                        ProjectType *projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientB);
                        
                        ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                        projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientC);
                        
                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [searchProjectDeferred resolveWithValue:data];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(4);
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellD.valueLabel.text should equal(@"None");
                        
                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");
                        
                    });
                    
                    it(@"should navigate back to card controller with the updated punch card object", ^{
                        [subject.tableView.visibleCells.lastObject tap];
                        
                        delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectC);
                        navigationController.topViewController should_not be_instance_of(subject);
                    });

                });
                
                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });
            });
            
            
        });
        
        context(@"When selecting a project filtered by no client", ^{
            beforeEach(^{
                projectRepository stub_method(@selector(fetchAllProjectsForClientUri:)).with(nil).and_return(projectDeferred.promise);
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:nil
                                                                                               uri:nil];
                project.isProjectTypeRequired = NO;
                
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                    initWithClientType:nil
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:nil
                                                    taskType:nil
                                                    activity:nil
                                                    uri:nil];
                [subject setUpWithSelectionScreenType:ProjectSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
                
                spy_on(subject.searchBar);
                
            });
            
            it(@"should fetch projects from project repository", ^{
                projectRepository should have_received(@selector(fetchAllProjectsForClientUri:)).with(nil);
            });
            
            context(@"When projects fetch succeeds intially", ^{
                __block ProjectType *projectA;
                __block ProjectType *projectC;
                beforeEach(^{
                    ClientType *clientType = [[ClientType alloc] initWithName:RPLocalizedString(ClientTypeNoClient, ClientTypeNoClient) uri:ClientTypeNoClientUri];
                    projectA = nice_fake_for([ProjectType class]);
                    projectA stub_method(@selector(name)).and_return(@"ProjectNameA");
                    projectA stub_method(@selector(client)).and_return(clientType);
                    
                    ProjectType *projectB = nice_fake_for([ProjectType class]);
                    projectB stub_method(@selector(name)).and_return(@"ProjectNameB");
                    projectB stub_method(@selector(client)).and_return(clientType);
                    
                    projectC = nice_fake_for([ProjectType class]);
                    projectC stub_method(@selector(name)).and_return(@"ProjectNameC");
                    projectC stub_method(@selector(client)).and_return(clientType);
                    
                    NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                           @"downloadCount":@3};
                    [projectDeferred resolveWithValue:data];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(4);
                    
                    SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellD.valueLabel.text should equal(@"None");
                    
                    SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellA.valueLabel.text should equal(@"ProjectNameA");
                    
                    SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellB.valueLabel.text should equal(@"ProjectNameB");
                    
                    SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    cellC.valueLabel.text should equal(@"ProjectNameC");
                    
                });
                
                it(@"should navigate back to card controller with the updated punch card object", ^{
                    [subject.tableView.visibleCells.lastObject tap];
                    
                    delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectC);
                    navigationController.topViewController should_not be_instance_of(subject);
                });

            });
            
            context(@"When projects fetch fails intially", ^{
                beforeEach(^{
                    NSError *error = nice_fake_for([NSError class]);
                    [projectDeferred rejectWithError:error];
                });
                
                it(@"should display correct cells", ^{
                    subject.tableView.visibleCells.count should equal(0);
                });
            });
            
            
            context(@"When the timer fires for project search after delay", ^{
                __block KSDeferred *searchProjectDeferred;
                __block NSTimer *timer;
                beforeEach(^{
                    
                    timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                             target:subject
                                                           selector:@selector(fetchDataAfterDelayFromTimer:)
                                                           userInfo:@"client-text"
                                                            repeats:YES];
                    timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                        :repeats:)).and_return(timer);
                    [clientRepository reset_sent_messages];
                    searchProjectDeferred = [[KSDeferred alloc]init];
                    projectRepository stub_method(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",nil).and_return(searchProjectDeferred.promise);
                    
                    [subject fetchDataAfterDelayFromTimer:timer];
                    
                });
                
                it(@"should ask the project repository for matching text projects", ^{
                    projectRepository should have_received(@selector(fetchProjectsMatchingText:clientUri:)).with(@"client-text",nil);
                });
                
                context(@"When projects fetch with match text succeeds", ^{
                    __block ProjectType *projectC;
                    beforeEach(^{
                        ClientType *clientType = [[ClientType alloc] initWithName:RPLocalizedString(ClientTypeNoClient, ClientTypeNoClient) uri:ClientTypeNoClientUri];
                        ProjectType *projectA = nice_fake_for([ProjectType class]);
                        projectA stub_method(@selector(name)).and_return(@"New-ProjectNameA");
                        projectA stub_method(@selector(client)).and_return(clientType);
                        
                        ProjectType *projectB = nice_fake_for([ProjectType class]);
                        projectB stub_method(@selector(name)).and_return(@"New-ProjectNameB");
                        projectB stub_method(@selector(client)).and_return(clientType);
                        
                        projectC = nice_fake_for([ProjectType class]);
                        projectC stub_method(@selector(name)).and_return(@"New-ProjectNameC");
                        projectC stub_method(@selector(client)).and_return(clientType);
                        
                        NSDictionary *data = @{@"projects":@[projectA,projectB,projectC],
                                               @"downloadCount":@3};
                        [searchProjectDeferred resolveWithValue:data];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(4);
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellD.valueLabel.text should equal(@"None");
                        
                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellA.valueLabel.text should equal(@"New-ProjectNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellB.valueLabel.text should equal(@"New-ProjectNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellC.valueLabel.text should equal(@"New-ProjectNameC");
                        
                    });
                    
                    it(@"should navigate back to card controller with the updated punch card object", ^{
                        [subject.tableView.visibleCells.lastObject tap];
                        
                        delegate should have_received(@selector(selectionController:didChooseProject:)).with(subject,projectC);
                        navigationController.topViewController should_not be_instance_of(subject);
                    });

                });
                
                context(@"When projects fetch with match text fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [projectDeferred rejectWithError:error];
                    });
                    
                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(0);
                    });
                });
            });
            
            
        });
    });

    describe(@"When screen type is task Selection screen", ^{

        context(@"When selecting a task filtered by project", ^{
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = YES;

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                     initWithClientType:client
                                                                            projectType:project
                                                                          oefTypesArray:nil
                                                                              breakType:NULL
                                                                               taskType:task
                                                                               activity:NULL
                                                                                    uri:nil];
                [subject setUpWithSelectionScreenType:TaskSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });
            
            it(@"should fetch tasks from task repository", ^{
                taskRepository should have_received(@selector(fetchAllTasksForProjectUri:)).with(@"project-uri");
            });
        });

        context(@"When selecting a task not filtered by project", ^{
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:nil
                                                                                               uri:nil];
                project.isProjectTypeRequired = YES;

                TaskType *task = [[TaskType alloc]initWithProjectUri:nil
                                                          taskPeriod:nil
                                                                name:nil
                                                                 uri:nil];
                PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                     initWithClientType:client
                                                                            projectType:project
                                                                          oefTypesArray:nil
                                                                              breakType:NULL
                                                                               taskType:task
                                                                               activity:NULL
                                                                                    uri:nil];
                [subject setUpWithSelectionScreenType:TaskSelection punchCardObject:punchCardObject delegate:delegate];
                [subject view];
                [subject viewWillAppear:NO];
            });
            
            it(@"should fetch tasks from task repository", ^{
                taskRepository should have_received(@selector(fetchAllTasksForProjectUri:)).with(nil);
            });
        });

    });

    describe(@"When screen type is activity Selection screen", ^{
        __block KSDeferred *clientDeferred;
        __block UINavigationController *navigationController;
        beforeEach(^{
            clientDeferred = [[KSDeferred alloc]init];
            activityRepository stub_method(@selector(fetchAllActivities)).and_return(clientDeferred.promise);
            [subject setUpWithSelectionScreenType:ActivitySelection punchCardObject:nil delegate:delegate];
            [subject view];
            [subject viewWillAppear:NO];

            navigationController = [[UINavigationController alloc]initWithRootViewController:subject];

            spy_on(subject.searchBar);
        });

        it(@"should fetch activities from activity repository", ^{
            activityRepository should have_received(@selector(fetchAllActivities));
        });

        context(@"When activities is fetched successfully intially", ^{
            __block Activity *activityA;
            __block Activity *activityB;
            __block Activity *activityC;

            beforeEach(^{
                activityA = [[Activity alloc] initWithName:@"activity-name-A" uri:@"activity-uri-A"];
                activityB = [[Activity alloc] initWithName:@"activity-name-B" uri:@"activity-uri-B"];
                activityC = [[Activity alloc] initWithName:@"activity-name-C" uri:@"activity-uri-C"];
                NSDictionary *data = @{@"activities":@[activityA,activityB,activityC],
                                       @"downloadCount":@3};
                [clientDeferred resolveWithValue:data];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(3);

                SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellA.valueLabel.text should equal(@"activity-name-A");
                
                SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellB.valueLabel.text should equal(@"activity-name-B");
                
                SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellC.valueLabel.text should equal(@"activity-name-C");

            });

            it(@"should navigate back to card controller with the updated punch card object", ^{
                [subject.tableView.visibleCells.firstObject tap];

                delegate should have_received(@selector(selectionController:didChooseActivity:)).with(Arguments::anything,activityA);
                navigationController.topViewController should_not be_instance_of(subject);
            });
        });

        context(@"When activities fetch fails intially", ^{
            beforeEach(^{
                NSError *error = nice_fake_for([NSError class]);
                [clientDeferred rejectWithError:error];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(0);
            });
        });
        
        
    });

    describe(@"When screen type is oefdropdown Selection screen", ^{
        __block KSDeferred *clientDeferred;
        __block UINavigationController *navigationController;
        beforeEach(^{
            clientDeferred = [[KSDeferred alloc]init];
            oefDropDownRepository stub_method(@selector(fetchAllOEFDropDownOptions)).and_return(clientDeferred.promise);
            [subject setUpWithSelectionScreenType:OEFDropDownSelection punchCardObject:nil delegate:delegate];
            [subject view];
            [subject viewWillAppear:NO];

            navigationController = [[UINavigationController alloc]initWithRootViewController:subject];

            spy_on(subject.searchBar);
        });

        it(@"should fetch oefdropdowns from activity repository", ^{
            oefDropDownRepository should have_received(@selector(fetchAllOEFDropDownOptions));
        });

        context(@"When oefdropdowns is fetched successfully intially", ^{
            __block OEFDropDownType *oefDropDownTypeA;
            __block OEFDropDownType *oefDropDownTypeB;
            __block OEFDropDownType *oefDropDownTypeC;

            beforeEach(^{
                oefDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"oefDropDownType-name-A" uri:@"oefDropDownType-uri-A"];
                oefDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"oefDropDownType-name-B" uri:@"oefDropDownType-uri-B"];
                oefDropDownTypeC = [[OEFDropDownType alloc] initWithName:@"oefDropDownType-name-C" uri:@"oefDropDownType-uri-C"];
                NSDictionary *data = @{@"oefDropDownOptions":@[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC],
                                       @"downloadCount":@3};
                [clientDeferred resolveWithValue:data];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(3);

                SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellA.valueLabel.text should equal(@"oefDropDownType-name-A");

                SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellB.valueLabel.text should equal(@"oefDropDownType-name-B");

                SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellC.valueLabel.text should equal(@"oefDropDownType-name-C");

            });

            it(@"should navigate back to card controller with the updated punch card object", ^{
                [subject.tableView.visibleCells.firstObject tap];

                delegate should have_received(@selector(selectionController:didChooseDropDownOEF:)).with(Arguments::anything,oefDropDownTypeA);
                navigationController.topViewController should_not be_instance_of(subject);
            });
        });

        context(@"When activities fetch fails intially", ^{
            beforeEach(^{
                NSError *error = nice_fake_for([NSError class]);
                [clientDeferred rejectWithError:error];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(0);
            });
        });
        
        
    });

    describe(@"As a <SVPullToRefresh>", ^{
        __block KSDeferred *clientDeferred;
        beforeEach(^{
            clientDeferred = [[KSDeferred alloc]init];
            clientRepository stub_method(@selector(fetchAllClients)).and_return(clientDeferred.promise);
            [subject setUpWithSelectionScreenType:ClientSelection punchCardObject:nil delegate:delegate];
            [subject view];
            [subject viewWillAppear:NO];
        });

        context(@"When clients is fetched successfully intially", ^{
            __block ClientType *clientA;
            __block ClientType *clientB;
            __block ClientType *clientC;

            beforeEach(^{
                clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
                clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
                NSDictionary *data = @{@"clients":@[clientA,clientB,clientC],
                                       @"downloadCount":@3};
                [clientDeferred resolveWithValue:data];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(5);
                
                SizeCell *cellG = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellG.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                
                SizeCell *cellH = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellH.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellA.valueLabel.text should equal(@"ClientNameA");
                
                SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                cellB.valueLabel.text should equal(@"ClientNameB");
                
                SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                cellC.valueLabel.text should equal(@"ClientNameC");

            });

            context(@"intiating pull to refresh", ^{
                __block KSDeferred *refreshDeferred;
                beforeEach(^{
                    refreshDeferred = [[KSDeferred alloc]init];
                    clientRepository stub_method(@selector(fetchFreshClients)).and_return(refreshDeferred.promise);
                    [subject.tableView triggerPullToRefresh];
                    spy_on(subject.tableView.pullToRefreshView);
                });

                it(@"should ask the repository to get the fresh records", ^{
                    clientRepository should have_received(@selector(fetchFreshClients));
                });

                it(@"should enable the infinite scrolling", ^{
                    subject.tableView.showsInfiniteScrolling should be_truthy;
                });

                it(@"should start the pull to refresh", ^{
                    subject.tableView.pullToRefreshView.state should equal(SVPullToRefreshStateLoading);
                });


                context(@"When fetch succeeds", ^{
                    beforeEach(^{
                        ClientType *newClientA = [[ClientType alloc] initWithName:@"NewClientNameA" uri:@"ClientUriA"];
                        ClientType *newClientB = [[ClientType alloc] initWithName:@"NewClientNameB" uri:@"ClientUriB"];
                        ClientType *newClientC = [[ClientType alloc] initWithName:@"NewClientNameC" uri:@"ClientUriC"];
                        ClientType *newClientD = [[ClientType alloc] initWithName:@"NewClientNameD" uri:@"ClientUriD"];
                        ClientType *newClientE = [[ClientType alloc] initWithName:@"NewClientNameE" uri:@"ClientUriE"];
                        ClientType *newClientF = [[ClientType alloc] initWithName:@"NewClientNameF" uri:@"ClientUriF"];
                        NSDictionary *data = @{@"clients":@[newClientA,newClientB,newClientC,newClientD,newClientE,newClientF],
                                               @"downloadCount":@3};
                        [refreshDeferred resolveWithValue:data];
                    });

                    it(@"should stop the pull to refresh", ^{
                        subject.tableView.pullToRefreshView.state should equal(SVPullToRefreshStateStopped);
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(8);
                        
                        SizeCell *cellG = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellG.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                        
                        SizeCell *cellH = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellH.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellA.valueLabel.text should equal(@"NewClientNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellB.valueLabel.text should equal(@"NewClientNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                        cellC.valueLabel.text should equal(@"NewClientNameC");
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                        cellD.valueLabel.text should equal(@"NewClientNameD");
                        
                        SizeCell *cellE = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
                        cellE.valueLabel.text should equal(@"NewClientNameE");
                        
                        SizeCell *cellF = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
                        cellF.valueLabel.text should equal(@"NewClientNameF");


                    });
                });

                context(@"When fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [refreshDeferred rejectWithError:error];
                    });

                    it(@"should stop the pull to refresh", ^{
                        subject.tableView.pullToRefreshView.state should equal(SVPullToRefreshStateStopped);
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(5);
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellD.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                        
                        SizeCell *cellE = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellE.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellA.valueLabel.text should equal(@"ClientNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellB.valueLabel.text should equal(@"ClientNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                        cellC.valueLabel.text should equal(@"ClientNameC");

                    });
                });

            });

            context(@"intiating infinite scrolling", ^{
                __block KSDeferred *infiniteDeferred;
                beforeEach(^{
                    infiniteDeferred = [[KSDeferred alloc]init];
                    clientRepository stub_method(@selector(fetchMoreClientsMatchingText:)).and_return(infiniteDeferred.promise);
                    [subject.tableView triggerInfiniteScrolling];
                    spy_on(subject.tableView.infiniteScrollingView);

                });

                it(@"should ask the repository to get the fresh records", ^{
                    clientRepository should have_received(@selector(fetchMoreClientsMatchingText:));
                });

                it(@"should start the infinite scrolling", ^{
                    subject.tableView.infiniteScrollingView.state should equal(SVInfiniteScrollingStateLoading);
                });


                context(@"When fetch succeeds with still more records in pagination", ^{
                    beforeEach(^{
                        ClientType *newClientA = [[ClientType alloc] initWithName:@"NewClientNameA" uri:@"ClientUriA"];
                        ClientType *newClientB = [[ClientType alloc] initWithName:@"NewClientNameB" uri:@"ClientUriB"];
                        ClientType *newClientC = [[ClientType alloc] initWithName:@"NewClientNameC" uri:@"ClientUriC"];
                        ClientType *newClientD = [[ClientType alloc] initWithName:@"NewClientNameD" uri:@"ClientUriD"];
                        ClientType *newClientE = [[ClientType alloc] initWithName:@"NewClientNameE" uri:@"ClientUriE"];
                        ClientType *newClientF = [[ClientType alloc] initWithName:@"NewClientNameF" uri:@"ClientUriF"];
                        ClientType *newClientG = [[ClientType alloc] initWithName:@"NewClientNameC" uri:@"ClientUriC"];
                        ClientType *newClientH = [[ClientType alloc] initWithName:@"NewClientNameD" uri:@"ClientUriD"];
                        ClientType *newClientI = [[ClientType alloc] initWithName:@"NewClientNameE" uri:@"ClientUriE"];
                        ClientType *newClientJ = [[ClientType alloc] initWithName:@"NewClientNameF" uri:@"ClientUriF"];
                        NSDictionary *data = @{@"clients":@[newClientA,newClientB,newClientC,newClientD,newClientE,newClientF,newClientG,newClientH,newClientI,newClientJ],
                                               @"downloadCount":@10};
                        [infiniteDeferred resolveWithValue:data];

                    });

                    it(@"should not disable infinite scrolling", ^{
                        subject.tableView.showsInfiniteScrolling should be_truthy;
                    });

                });

                context(@"When fetch succeeds with no more records in pagination", ^{
                    beforeEach(^{
                        ClientType *newClientA = [[ClientType alloc] initWithName:@"NewClientNameA" uri:@"ClientUriA"];
                        ClientType *newClientB = [[ClientType alloc] initWithName:@"NewClientNameB" uri:@"ClientUriB"];
                        ClientType *newClientC = [[ClientType alloc] initWithName:@"NewClientNameC" uri:@"ClientUriC"];
                        ClientType *newClientD = [[ClientType alloc] initWithName:@"NewClientNameD" uri:@"ClientUriD"];
                        ClientType *newClientE = [[ClientType alloc] initWithName:@"NewClientNameE" uri:@"ClientUriE"];
                        ClientType *newClientF = [[ClientType alloc] initWithName:@"NewClientNameF" uri:@"ClientUriF"];
                        NSDictionary *data = @{@"clients":@[newClientA,newClientB,newClientC,newClientD,newClientE,newClientF],
                                               @"downloadCount":@3};
                        [infiniteDeferred resolveWithValue:data];
                    });

                    it(@"should stop the infinite scrolling", ^{
                        subject.tableView.infiniteScrollingView.state should equal(SVInfiniteScrollingStateStopped);
                    });

                    it(@"should disable infinite scrolling", ^{
                        subject.tableView.showsInfiniteScrolling should be_falsy;
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(8);
                        
                        SizeCell *cellG = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellG.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                        
                        SizeCell *cellH = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellH.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellA.valueLabel.text should equal(@"NewClientNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellB.valueLabel.text should equal(@"NewClientNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                        cellC.valueLabel.text should equal(@"NewClientNameC");
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                        cellD.valueLabel.text should equal(@"NewClientNameD");
                        
                        SizeCell *cellE = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
                        cellE.valueLabel.text should equal(@"NewClientNameE");
                        
                        SizeCell *cellF = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
                        cellF.valueLabel.text should equal(@"NewClientNameF");

                    });
                });

                context(@"When fetch fails", ^{
                    beforeEach(^{
                        NSError *error = nice_fake_for([NSError class]);
                        [infiniteDeferred rejectWithError:error];
                    });

                    it(@"should stop the infinite scrolling", ^{
                        subject.tableView.infiniteScrollingView.state should equal(SVInfiniteScrollingStateStopped);
                    });

                    it(@"should display correct cells", ^{
                        subject.tableView.visibleCells.count should equal(5);
                        
                        SizeCell *cellD = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cellD.valueLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                        
                        SizeCell *cellE = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        cellE.valueLabel.text should equal(RPLocalizedString(@"No Client", nil));

                        SizeCell *cellA = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        cellA.valueLabel.text should equal(@"ClientNameA");
                        
                        SizeCell *cellB = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                        cellB.valueLabel.text should equal(@"ClientNameB");
                        
                        SizeCell *cellC = (SizeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                        cellC.valueLabel.text should equal(@"ClientNameC");

                    });
                });
            });

        });

    });

});

SPEC_END
