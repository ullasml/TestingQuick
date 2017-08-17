#import <Cedar/Cedar.h>
#import "PunchCardController.h"
#import "Theme.h"
#import "Constants.h"
#import "PunchCardObject.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "SelectionController.h"
#import "ClientRepository.h"
#import "ProjectRepository.h"
#import "TaskRepository.h"
#import "TimerProvider.h"
#import "ProjectType.h"
#import "Period.h"
#import "PunchCardStylist.h"
#import "UIControl+Spec.h"
#import "PunchValidator.h"
#import "UIAlertView+spec.h"
#import "UserPermissionsStorage.h"
#import "ActivityRepository.h"
#import "UserSession.h"
#import "DefaultActivityStorage.h"
#import "OEFType.h"
#import "UITableViewCell+Spec.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchCardControllerSpec)

describe(@"PunchCardController", ^{
    __block PunchCardController  <CedarDouble>*subject;
    __block id <Theme> theme;
    __block UINavigationController *navigationController;
    __block id <BSInjector,BSBinder> injector;
    __block SelectionController <CedarDouble> *selectionController;
    __block PunchCardObject *punchCardObject;
    __block PunchCardStylist *punchCardStylist;
    __block id <PunchCardControllerDelegate> delegate;
    __block PunchValidator *punchValidator;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block DefaultActivityStorage *defaultActivityStorage;
    __block id <UserSession> userSession;
    __block NSMutableArray *oefTypesArray;
    __block OEFType *oefType1;
    __block OEFType *oefType2;
    __block OEFType *oefType3;

    beforeEach(^{
        injector = [InjectorProvider injector];

        punchValidator = nice_fake_for([PunchValidator class]);
        [injector bind:[PunchValidator class] toInstance:punchValidator];

        punchValidator stub_method(@selector(validatePunchWithProjectType:taskType:)).and_return(nil);
        punchValidator stub_method(@selector(validatePunchWithClientType:ProjectType:taskType:)).and_return(nil);
        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).and_return(nil);
        
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        defaultActivityStorage = nice_fake_for([DefaultActivityStorage class]);
        [injector bind:[DefaultActivityStorage class] toInstance:defaultActivityStorage];

        punchCardStylist = nice_fake_for([PunchCardStylist class]);
        [injector bind:[PunchCardStylist class] toInstance:punchCardStylist];

        delegate = nice_fake_for(@protocol(PunchCardControllerDelegate));

        selectionController = (id) [[SelectionController alloc] initWithProjectStorage:NULL expenseProjectStorage:NULL timerProvider:nil userDefaults:nil theme:nil];
        [injector bind:InjectorKeySelectionControllerForPunchModule toInstance:selectionController];

        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        [injector bind:@protocol(UserSession) toInstance:userSession];

        subject = [injector getInstance:[PunchCardController class]];
        spy_on(subject);

        theme = subject.theme;
        spy_on(theme);

        oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
        oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

        punchCardObject = [[PunchCardObject alloc]
                                            initWithClientType:nil
                                                   projectType:nil
                                                 oefTypesArray:nil
                                                     breakType:NULL
                                                      taskType:nil
                                                      activity:NULL
                                                           uri:@"uri"];

        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(selectionController);


    });

    beforeEach(^{

        theme stub_method(@selector(createPunchCardButtonBackgroundColor)).and_return([UIColor whiteColor]);
        theme stub_method(@selector(createPunchCardButtonFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(createPunchCardButtonTitleColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(createPunchCardCornerRadius)).and_return((CGFloat)1.0);
        theme stub_method(@selector(createPunchCardBorderWidth)).and_return((CGFloat)10.0);
        theme stub_method(@selector(createPunchCardBorderColor)).and_return([UIColor grayColor].CGColor);

        theme stub_method(@selector(clockInPunchCardButtonBackgroundColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(clockInPunchCardButtonFont)).and_return([UIFont systemFontOfSize:20]);
        theme stub_method(@selector(clockInPunchCardButtonTitleColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(clockInPunchCardCornerRadius)).and_return((CGFloat)2.0);
        theme stub_method(@selector(clockInPunchCardBorderWidth)).and_return((CGFloat)20.0);
        theme stub_method(@selector(clockInPunchCardBorderColor)).and_return([UIColor magentaColor].CGColor);


        theme stub_method(@selector(durationLabelLittleTimeUnitFont)).and_return([UIFont systemFontOfSize:20]);
        theme stub_method(@selector(allPunchCardTitleLabelFont)).and_return([UIFont systemFontOfSize:17]);
        theme stub_method(@selector(selectionCellValueFont)).and_return([UIFont systemFontOfSize:1]);
        theme stub_method(@selector(selectionCellFont)).and_return([UIFont systemFontOfSize:12]);
        theme stub_method(@selector(selectionCellNameFontColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(selectionCellValueFontColor)).and_return([UIColor magentaColor]);
        theme stub_method(@selector(selectionCellValueDisabledFontColor)).and_return([UIColor grayColor]);
    });

    describe(@"Styling the views", ^{

        context(@"When DefaultClientProjectTaskPunchCard", ^{
            beforeEach(^{
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                [subject view];
            });

            it(@"should style the card with border correctly", ^{
                punchCardStylist should have_received(@selector(styleBorderForView:)).with(subject.view);
            });

            it(@"should style create punch card correctly", ^{

                subject.punchActionButton.hidden should be_truthy;
                subject.createPunchCardButton.backgroundColor should equal([UIColor whiteColor]);
                subject.createPunchCardButton.titleLabel.font should equal([UIFont systemFontOfSize:10]);
                subject.createPunchCardButton.layer.cornerRadius should equal((CGFloat)1.0);

            });

            it(@"should contain the create bookmark button as a subview", ^{
                subject.view.subviews should contain(subject.createPunchCardButton);
            });

            it(@"should not contain the create bookmark button as a subview", ^{
                subject.view.subviews should_not contain(subject.punchActionButton);
            });

            it(@"should correctly have top padding for tableview", ^{
                subject.tableViewTopPaddingConstraint.constant should equal((CGFloat)5.0);
            });

        });

        context(@"When FilledClientProjectTaskPunchCard", ^{
            beforeEach(^{
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:FilledClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                [subject view];
            });

            it(@"should not style the card with border", ^{
                punchCardStylist should_not have_received(@selector(styleBorderForView:)).with(subject.view);
            });

            it(@"should style create punch card correctly", ^{

                subject.createPunchCardButton.hidden should be_truthy;
                subject.punchActionButton.backgroundColor should equal([UIColor greenColor]);
                subject.punchActionButton.titleLabel.font should equal([UIFont systemFontOfSize:20]);
                subject.punchActionButton.layer.cornerRadius should equal((CGFloat)2.0);
                subject.punchActionButton.titleLabel.textColor should equal([UIColor yellowColor]);

            });

            it(@"should not contain the create bookmark button as a subview", ^{
                subject.view.subviews should_not contain(subject.createPunchCardButton);
            });

            it(@"should contain the create bookmark button as a subview", ^{
                subject.view.subviews should contain(subject.punchActionButton);
            });

            it(@"should not have top padding for tableview", ^{
                subject.tableViewTopPaddingConstraint.constant should equal((CGFloat)0.0);
            });

        });
    });

    describe(@"When the view loads", ^{
        
        context(@"as a punch into project flow", ^{
            context(@"without oef's", ^{
                context(@"As a punch into projects flow when user has client access", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        
                        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                        
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(3);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Client", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([UITableViewCell class]);
                        secondCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                        secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([UITableViewCell class]);
                        thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        thirdCell.userInteractionEnabled should be_falsy;
                        thirdCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                      endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                            ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                       isTimeAllocationAllowed:NO
                                                                                                 projectPeriod:period
                                                                                                    clientType:client
                                                                                                          name:@"projectname"
                                                                                                           uri:@"projecturi"];;
                            PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                initWithClientType:nil
                                                                projectType:project
                                                                oefTypesArray:nil
                                                                breakType:NULL
                                                                taskType:nil
                                                                activity:NULL
                                                                uri:nil];
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([UITableViewCell class]);
                            thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            thirdCell.userInteractionEnabled should be_truthy;
                            thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        });
                    });
                    
                    context(@"When selecting the cell", ^{
                        __block PunchCardObject *punchCardObjLocalInstance;
                        beforeEach(^{
                            
                            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"" uri:nil];
                            
                            punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                        projectType:projectType
                                                                                      oefTypesArray:nil
                                                                                          breakType:nil
                                                                                           taskType:nil
                                                                                           activity:nil
                                                                                                uri:nil];
                            
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            
                            [subject setUpWithPunchCardObject:punchCardObjLocalInstance punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        
                        it(@"should navigate when client cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,punchCardObjLocalInstance,subject);
                        });
                        
                        it(@"should navigate when project cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCardObjLocalInstance,subject);
                        });
                        
                        it(@"should navigate when task cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCardObjLocalInstance,subject);
                        });
                    });
                    

                });
                
                context(@"As a punch into projects flow when user don't have client access", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                        
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        
                        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(2);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([UITableViewCell class]);
                        secondCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                        secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        secondCell.userInteractionEnabled should be_falsy;
                        secondCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                      endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                       isTimeAllocationAllowed:NO
                                                                                                 projectPeriod:period
                                                                                                    clientType:nil
                                                                                                          name:@"projectname"
                                                                                                           uri:@"projecturi"];;
                            PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                initWithClientType:nil
                                                                projectType:project
                                                                oefTypesArray:nil
                                                                breakType:NULL
                                                                taskType:nil
                                                                activity:NULL
                                                                uri:nil];
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([UITableViewCell class]);
                            secondCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            secondCell.userInteractionEnabled should be_truthy;
                            secondCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        });
                    });
                    
                    context(@"When selecting the cell", ^{
                       
                        __block PunchCardObject *punchCardObjLocalInstance;
                        
                        beforeEach(^{
                            
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            
                            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"" uri:nil];
                            
                            punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                        projectType:projectType
                                                                                      oefTypesArray:nil
                                                                                          breakType:nil
                                                                                           taskType:nil
                                                                                           activity:nil
                                                                                                uri:nil];
                            
                            
                            [subject setUpWithPunchCardObject:punchCardObjLocalInstance punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        
                        it(@"should navigate when project cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCardObjLocalInstance,subject);
                        });
                        
                        it(@"should navigate when task cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCardObjLocalInstance,subject);
                        });
                        
                    });
                
                });
            });
            
            context(@"with oef's", ^{
                context(@"As a punch into projects flow when user has client access", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    __block NSIndexPath *seventhRowIndexPath;
                    
                    
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                        
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        sixthRowIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                        seventhRowIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                        
                        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                        
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Client", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([UITableViewCell class]);
                        secondCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                        secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([UITableViewCell class]);
                        thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        thirdCell.userInteractionEnabled should be_falsy;
                        thirdCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                        
                         DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                         fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                         fourthCell.title.text should equal(oefType1.oefName);
                         fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                         
                         
                         DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthRowIndexPath];
                         fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                         fifthCell.title.text should equal(oefType2.oefName);
                         fifthCell.textView.text should equal(RPLocalizedString(@"23.5999", @""));


                        DynamicTextTableViewCell *sixthCell = [subject.tableView cellForRowAtIndexPath:sixthRowIndexPath];
                        sixthCell should be_instance_of([DynamicTextTableViewCell class]);
                        sixthCell.title.text should equal(oefType3.oefName);
                        sixthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        sixthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                      endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                            ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                       isTimeAllocationAllowed:NO
                                                                                                 projectPeriod:period
                                                                                                    clientType:client
                                                                                                          name:@"projectname"
                                                                                                           uri:@"projecturi"];;
                            PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                initWithClientType:nil
                                                                projectType:project
                                                                oefTypesArray:nil
                                                                breakType:NULL
                                                                taskType:nil
                                                                activity:NULL
                                                                uri:nil];
                            
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([UITableViewCell class]);
                            thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            thirdCell.userInteractionEnabled should be_truthy;
                            thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        });
                    });
                    
                    context(@"When selecting a cell", ^{
                        __block PunchCardObject *punchCardObjLocalInstance;
                        beforeEach(^{
                            
                            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                            isTimeAllocationAllowed:NO
                                                                                                      projectPeriod:nil
                                                                                                         clientType:nil
                                                                                                               name:nil
                                                                                                                uri:nil];
                            
                            punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                        projectType:projectType
                                                                                      oefTypesArray:nil
                                                                                          breakType:nil
                                                                                           taskType:nil
                                                                                           activity:nil
                                                                                                uri:nil];
                            
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            sixthRowIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            seventhRowIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                            
                            [subject setUpWithPunchCardObject:punchCardObjLocalInstance punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                            
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        it(@"should navigate when client cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,punchCardObjLocalInstance,subject);
                        });
                        
                        it(@"should navigate when project cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCardObjLocalInstance,subject);
                        });
                        
                        it(@"should navigate when task cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCardObjLocalInstance,subject);
                        });
                    });
                    

                });
                
                context(@"As a punch into projects flow when user don't have client access", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthhRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                        
                        
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthhRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        sixthRowIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                        
                        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([UITableViewCell class]);
                        secondCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                        secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        secondCell.userInteractionEnabled should be_falsy;
                        secondCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                        
                         DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                         thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                         thirdCell.title.text should equal(oefType1.oefName);
                         thirdCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                         thirdCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        
                         DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                         fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                         fourthCell.title.text should equal(oefType2.oefName);
                         fourthCell.textView.text should equal(RPLocalizedString(@"23.5999", @""));
                         fourthCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                        
                        DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthhRowIndexPath];
                        fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fifthCell.title.text should equal(oefType3.oefName);
                        fifthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        fifthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                      endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                       isTimeAllocationAllowed:NO
                                                                                                 projectPeriod:period
                                                                                                    clientType:nil
                                                                                                          name:@"projectname"
                                                                                                           uri:@"projecturi"];;
                            PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                initWithClientType:nil
                                                                projectType:project
                                                                oefTypesArray:nil
                                                                breakType:NULL
                                                                taskType:nil
                                                                activity:NULL
                                                                uri:nil];
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([UITableViewCell class]);
                            secondCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            secondCell.userInteractionEnabled should be_truthy;
                            secondCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        });
                    });
                    
                    context(@"When selecting the cell", ^{
                        __block PunchCardObject *punchCardObjLocalInstance;
                        beforeEach(^{
                            
                            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                            isTimeAllocationAllowed:NO
                                                                                                      projectPeriod:nil
                                                                                                         clientType:nil
                                                                                                               name:nil
                                                                                                                uri:nil];
                            
                            punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                        projectType:projectType
                                                                                      oefTypesArray:nil
                                                                                          breakType:nil
                                                                                           taskType:nil
                                                                                           activity:nil
                                                                                                uri:nil];
                            
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthhRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            sixthRowIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            
                            [subject setUpWithPunchCardObject:punchCardObjLocalInstance punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        
                        it(@"should navigate when project cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCardObjLocalInstance,subject);
                        });
                        
                        it(@"should navigate when task cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                            selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCardObjLocalInstance,subject);
                        });
                    });

                });
            });

        });

        context(@"As a punch into activities flow", ^{

            context(@"without oef's", ^{
                context(@"When don't have default activity", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block PunchCardObject *punchCardObjLocalInstance;

                    beforeEach(^{
                        NSDictionary *detailsDict = @{@"default_activity_name": @"",
                                                      @"default_activity_uri": @"",
                                                      };

                        defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(detailsDict);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        
                        Activity *activity = [[Activity alloc] initWithName:@"" uri:nil];
                        
                        punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                    projectType:nil
                                                                                  oefTypesArray:nil
                                                                                      breakType:nil
                                                                                       taskType:nil
                                                                                       activity:activity
                                                                                            uri:nil];

                        [subject setUpWithPunchCardObject:punchCardObjLocalInstance punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });

                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];

                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        cell should be_instance_of([UITableViewCell class]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Activity", nil));
                        cell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));

                    });



                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ActivitySelection,punchCardObjLocalInstance,subject);
                    });
                });
                context(@"When user has default activity", ^{
                    __block NSIndexPath *firstRowIndexPath;


                    beforeEach(^{
                        NSDictionary *detailsDict = @{@"default_activity_name": @"default-activity",
                                                      @"default_activity_uri": @"default-uri",
                                                      };

                        defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(detailsDict);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

                        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });

                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];

                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);


                    });

                    it(@"should setup the cells correctly", ^{

                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Activity", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"default-activity", nil));

                        
                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
            });

            context(@"with oef's", ^{
                context(@"When don't have default activity", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    __block PunchCardObject *punchCardObjLocalInstance;

                    beforeEach(^{
                        NSDictionary *detailsDict = @{@"default_activity_name": @"",
                                                      @"default_activity_uri": @"",
                                                      };

                        defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(detailsDict);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        
                        
                        Activity *activity = [[Activity alloc] initWithName:@"" uri:nil];
                        
                        punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                    projectType:nil
                                                                                  oefTypesArray:nil
                                                                                      breakType:nil
                                                                                       taskType:nil
                                                                                       activity:activity
                                                                                            uri:nil];
                        
                        [subject setUpWithPunchCardObject:punchCardObjLocalInstance punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });

                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];

                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        cell should be_instance_of([UITableViewCell class]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Activity", nil));
                        cell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));

                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:1]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);


                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(@"23.5999");
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:1]);
                        thirdCell.title.textColor should equal([UIColor orangeColor]);
                        thirdCell.textView.textColor should equal([UIColor magentaColor]);
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                        thirdCell.subviews[0].subviews[0] should equal(thirdCell.textView);
                        thirdCell.subviews[0].subviews[1] should equal(thirdCell.title);

                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType3.oefName);
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                        fourthCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        fourthCell.title.font should equal([UIFont systemFontOfSize:12]);
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:1]);
                        fourthCell.title.textColor should equal([UIColor orangeColor]);
                        fourthCell.textView.textColor should equal([UIColor magentaColor]);
                        fourthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        fourthCell.subviews[0].subviews[0] should equal(fourthCell.title);
                        fourthCell.subviews[0].subviews[1] should equal(fourthCell.textValueLabel);



                    });



                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ActivitySelection,punchCardObjLocalInstance,subject);
                    });
                });
                context(@"When user has default activity", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;

                    beforeEach(^{
                        NSDictionary *detailsDict = @{@"default_activity_name": @"default-activity",
                                                      @"default_activity_uri": @"default-uri",
                                                      };

                        defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(detailsDict);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should set the title of the button  correctly", ^{
                        subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });

                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];

                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:1]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);

                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:1]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);


                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(@"23.5999");
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:1]);
                        thirdCell.title.textColor should equal([UIColor orangeColor]);
                        thirdCell.textView.textColor should equal([UIColor magentaColor]);
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                        thirdCell.subviews[0].subviews[0] should equal(thirdCell.textView);
                        thirdCell.subviews[0].subviews[1] should equal(thirdCell.title);

                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType3.oefName);
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                        fourthCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        fourthCell.title.font should equal([UIFont systemFontOfSize:12]);
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:1]);
                        fourthCell.title.textColor should equal([UIColor orangeColor]);
                        fourthCell.textView.textColor should equal([UIColor magentaColor]);
                        fourthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        fourthCell.subviews[0].subviews[0] should equal(fourthCell.title);
                        fourthCell.subviews[0].subviews[1] should equal(fourthCell.textValueLabel);


                    });

                    it(@"should setup the cells correctly", ^{

                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Activity", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"default-activity", nil));

                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(@"text 1");
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));

                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(@"numeric 1");
                        thirdCell.textView.text should equal(@"23.5999");

                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType3.oefName);
                        fourthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        fourthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);

                        
                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
            });


        });

        context(@"As a simple punch flow with OEF's", ^{

            __block NSIndexPath *firstRowIndexPath;
            __block NSIndexPath *secondRowIndexPath;
            __block NSIndexPath *thirdRowIndexPath;

            beforeEach(^{

                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                [subject view];
                [subject.tableView layoutIfNeeded];
            });

            it(@"should set the title of the button  correctly", ^{
                subject.createPunchCardButton.titleLabel.text should equal(RPLocalizedString(createBookmarksText, createBookmarksText));
            });

            it(@"should have a correct number of section and rows in tableview", ^{
                subject.tableView.numberOfSections should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(subject.oefTypesArray.count);
            });

            it(@"should style the cells correctly", ^{


                DynamicTextTableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                firstCell should be_instance_of([DynamicTextTableViewCell class]);
                firstCell.title.text should equal(oefType1.oefName);
                firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                firstCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                firstCell.title.font should equal([UIFont systemFontOfSize:12]);
                firstCell.textView.font should equal([UIFont systemFontOfSize:1]);
                firstCell.title.textColor should equal([UIColor orangeColor]);
                firstCell.textView.textColor should equal([UIColor magentaColor]);
                firstCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                firstCell.subviews[0].subviews[0] should equal(firstCell.textView);
                firstCell.subviews[0].subviews[1] should equal(firstCell.title);


                DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                secondCell should be_instance_of([DynamicTextTableViewCell class]);
                secondCell.title.text should equal(oefType2.oefName);
                secondCell.textView.text should equal(@"23.5999");
                secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                secondCell.textView.font should equal([UIFont systemFontOfSize:1]);
                secondCell.title.textColor should equal([UIColor orangeColor]);
                secondCell.textView.textColor should equal([UIColor magentaColor]);
                secondCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                secondCell.subviews[0].subviews[1] should equal(secondCell.title);

                DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                thirdCell.title.text should equal(oefType3.oefName);
                thirdCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                thirdCell.textView.font should equal([UIFont systemFontOfSize:1]);
                thirdCell.title.textColor should equal([UIColor orangeColor]);
                thirdCell.textView.textColor should equal([UIColor magentaColor]);
                thirdCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                thirdCell.subviews[0].subviews[0] should equal(thirdCell.title);
                thirdCell.subviews[0].subviews[1] should equal(thirdCell.textValueLabel);



            });

        });

    });

    describe(@"As a <SelectionControllerDelegate>", ^{
        __block PunchCardObject *expectedPunchCard;
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
            [subject view];
            [subject.tableView layoutIfNeeded];
        });
        context(@"When updating client", ^{
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                   projectType:nil
                                                                 oefTypesArray:nil
                                                                     breakType:NULL
                                                                      taskType:nil
                                                                      activity:NULL
                                                                           uri:nil];
                [subject selectionController:nil didChooseClient:client];
            });

            it(@"should setup the cells correctly", ^{

                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"client-name");

                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));

                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
            });



        });
        
        context(@"When updating client and client null behaviour uri is selected and Type is Any client", ^{
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:ClientTypeAnyClient uri:ClientTypeAnyClientUri];
                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                   projectType:nil
                                                                 oefTypesArray:nil
                                                                     breakType:NULL
                                                                      taskType:nil
                                                                      activity:NULL
                                                                           uri:nil];
                [subject selectionController:nil didChooseClient:client];
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(RPLocalizedString(ClientTypeAnyClient, nil));
                
                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                
                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
            });
            
        });
        
        context(@"When updating client and client null behaviour uri is selected and Type is No client", ^{
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:ClientTypeNoClient uri:ClientTypeNoClientUri];
                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                   projectType:nil
                                                                 oefTypesArray:nil
                                                                     breakType:NULL
                                                                      taskType:nil
                                                                      activity:NULL
                                                                           uri:nil];
                [subject selectionController:nil didChooseClient:client];
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(RPLocalizedString(ClientTypeNoClient, nil));
                
                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                
                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
            });
            
        });

        context(@"When updating Project", ^{

            context(@"Selecting a project without a client", ^{
                beforeEach(^{
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:nil
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                       projectType:project
                                                                     oefTypesArray:nil
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:nil];
                    [subject selectionController:nil didChooseProject:project];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));

                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(@"project-name");

                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                });


            });

            context(@"Selecting a project with a client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];

                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                       projectType:project
                                                                     oefTypesArray:nil
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:nil];
                    [subject selectionController:nil didChooseProject:project];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"client-name");

                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(@"project-name");

                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                });




            });

            context(@"Selecting a none project with a client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];

                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                       projectType:project
                                                                     oefTypesArray:nil
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:nil];
                    [subject selectionController:nil didChooseProject:project];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"client-name");

                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(@"project-name");

                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                });



                
            });

            context(@"Selecting a project with a client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                       projectType:project
                                                                     oefTypesArray:nil
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:nil];
                    [subject selectionController:nil didChooseProject:project];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"client-name");

                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(@"project-name");

                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                });



                
            });
            
        });

        context(@"When updating Task", ^{

            context(@"after updating project", ^{

                beforeEach(^{
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:nil
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    [subject selectionController:nil didChooseProject:project];

                    TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];

                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                       projectType:project
                                                                     oefTypesArray:nil
                                                                         breakType:nil
                                                                          taskType:task
                                                                          activity:nil
                                                                               uri:nil];
                    [subject selectionController:nil didChooseTask:task];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"task-name");

                    subject.createPunchCardButton.userInteractionEnabled should be_truthy;

                });


            });

            context(@"after updating client and project", ^{

                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    [subject selectionController:nil didChooseClient:client];

                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    [subject selectionController:nil didChooseProject:project];

                    TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];

                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                       projectType:project
                                                                     oefTypesArray:nil
                                                                         breakType:nil
                                                                          taskType:task
                                                                          activity:nil
                                                                               uri:nil];
                    [subject selectionController:nil didChooseTask:task];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"task-name");

                    subject.createPunchCardButton.userInteractionEnabled should be_truthy;

                });

                
            });
        });

        context(@"When updating activity", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                Activity *activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                [subject selectionController:nil didChooseActivity:activity];

                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                   projectType:nil
                                                                 oefTypesArray:oefTypesArray
                                                                     breakType:nil
                                                                      taskType:nil
                                                                      activity:activity
                                                                           uri:nil];
                [subject selectionController:nil didChooseActivity:activity];

            });

            it(@"should setup the cells correctly", ^{

                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"activity-name");

                DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell should be_instance_of([DynamicTextTableViewCell class]);
                secondCell.title.text should equal(@"text 1");
                secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));

                DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                thirdCell.title.text should equal(@"numeric 1");
                thirdCell.textView.text should equal(@"23.5999");

                DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                fourthCell.title.text should equal(@"dropdown oef 1");
                fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

            });



        });

        context(@"When updating dropdown oefTypes for a punch with activity access", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");

                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                   projectType:nil
                                                                 oefTypesArray:oefTypesArray
                                                                     breakType:nil
                                                                      taskType:nil
                                                                      activity:nil
                                                                           uri:nil];
                [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
            });

            it(@"should update the new dropdown", ^{
                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                cellF.title.text should equal(@"dropdown oef 1");
                cellF.textValueLabel.text should equal(@"new-dropdown-name");

            });
            
            
            
        });

        context(@"When updating dropdown oefTypes for a punch with project and client access", ^{
            beforeEach(^{
                OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");

                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                   projectType:nil
                                                                 oefTypesArray:oefTypesArray
                                                                     breakType:nil
                                                                      taskType:nil
                                                                      activity:nil
                                                                           uri:nil];
                [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
            });

            it(@"should update the new dropdown", ^{
                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                cellF.title.text should equal(@"dropdown oef 1");
                cellF.textValueLabel.text should equal(@"new-dropdown-name");

            });

            
            
        });

        context(@"When updating dropdown oefTypes for a simple punch with oef", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");

                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                   projectType:nil
                                                                 oefTypesArray:oefTypesArray
                                                                     breakType:nil
                                                                      taskType:nil
                                                                      activity:nil
                                                                           uri:nil];
                [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
            });

            it(@"should update the new dropdown", ^{
                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellF.title.text should equal(@"dropdown oef 1");
                cellF.textValueLabel.text should equal(@"new-dropdown-name");

            });
            
            
            
        });

        context(@"selectionControllerNeedsClientProjectTaskRepository", ^{
            __block id <ClientProjectTaskRepository> clientProjectTaskRepository;
            __block ClientRepository *clientRepository;
            __block ProjectRepository *projectRepository;
            __block TaskRepository *taskRepository;
            __block ActivityRepository *activityRepository;
            beforeEach(^{

                clientProjectTaskRepository = [subject selectionControllerNeedsClientProjectTaskRepository];

            });

            it(@"should have expected clientProjectTaskRepository with useruri", ^{
                clientRepository = (ClientRepository *)[clientProjectTaskRepository clientRepository];
                clientRepository should be_instance_of([ClientRepository class]);
                clientRepository.userUri should equal(@"user-uri");

                projectRepository = (ProjectRepository *)[clientProjectTaskRepository projectRepository];
                projectRepository should be_instance_of([ProjectRepository class]);
                projectRepository.userUri should equal(@"user-uri");

                taskRepository = (TaskRepository *)[clientProjectTaskRepository taskRepository];
                taskRepository should be_instance_of([TaskRepository class]);
                taskRepository.userUri should equal(@"user-uri");

                activityRepository = (ActivityRepository *)[clientProjectTaskRepository activityRepository];
                activityRepository should be_instance_of([ActivityRepository class]);
                activityRepository.userUri should equal(@"user-uri");
            });
        });

        context(@"selectionControllerNeedsOEFDropDownRepository", ^{
            __block OEFDropDownRepository *oefDropDownRepository;

            beforeEach(^{
                (id<CedarDouble>)subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"some:dropdownoef:uri");
                oefDropDownRepository = [subject selectionControllerNeedsOEFDropDownRepository];

            });

            it(@"should have expected oefDropDownRepository with DropDownOefUri and useruri", ^{

                oefDropDownRepository should be_instance_of([OEFDropDownRepository class]);
                oefDropDownRepository.userUri should equal(@"user-uri");
                oefDropDownRepository.dropDownOEFUri should equal(@"some:dropdownoef:uri");

            });
        });
    });
    
    describe(@"As a <SelectionControllerDelegate> when don't have client access", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
            [subject view];
            [subject.tableView layoutIfNeeded];
        });
        
        context(@"When updating Project", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
            });
            context(@"Selecting a project without a client", ^{
                beforeEach(^{
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:nil
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    [subject selectionController:nil didChooseProject:project];
                });
                
                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"project-name");
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                });
                
            });
            
        });
        
        context(@"When updating Task", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                           taskPeriod:nil
                                                                 name:@"task-name"
                                                                  uri:@"task-uri"];
                [subject selectionController:nil didChooseTask:task];
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"task-name");
                
                subject.createPunchCardButton.userInteractionEnabled should be_truthy;
                
            });
        });
        
        context(@"When updating activity", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                Activity *activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                [subject selectionController:nil didChooseActivity:activity];
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"activity-name");

                DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell should be_instance_of([DynamicTextTableViewCell class]);
                secondCell.title.text should equal(@"text 1");
                secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));

                DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                thirdCell.title.text should equal(@"numeric 1");
                thirdCell.textView.text should equal(@"23.5999");

                DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                fourthCell.title.text should equal(@"dropdown oef 1");
                fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

            });
        });
        
        context(@"selectionControllerNeedsClientProjectTaskRepository", ^{
            __block id <ClientProjectTaskRepository> clientProjectTaskRepository;
            __block ClientRepository *clientRepository;
            __block ProjectRepository *projectRepository;
            __block TaskRepository *taskRepository;
            __block ActivityRepository *activityRepository;
            beforeEach(^{
                
                clientProjectTaskRepository = [subject selectionControllerNeedsClientProjectTaskRepository];
                
            });
            
            it(@"should have expected clientProjectTaskRepository with useruri", ^{
                clientRepository = (ClientRepository *)[clientProjectTaskRepository clientRepository];
                clientRepository should be_instance_of([ClientRepository class]);
                clientRepository.userUri should equal(@"user-uri");
                
                projectRepository = (ProjectRepository *)[clientProjectTaskRepository projectRepository];
                projectRepository should be_instance_of([ProjectRepository class]);
                projectRepository.userUri should equal(@"user-uri");
                
                taskRepository = (TaskRepository *)[clientProjectTaskRepository taskRepository];
                taskRepository should be_instance_of([TaskRepository class]);
                taskRepository.userUri should equal(@"user-uri");
                
                activityRepository = (ActivityRepository *)[clientProjectTaskRepository activityRepository];
                activityRepository should be_instance_of([ActivityRepository class]);
                activityRepository.userUri should equal(@"user-uri");
            });
        });
    });

    describe(@"As a <PunchCardControllerDelegate>", ^{
        
        describe(@"Create punch card", ^{
            __block PunchCardObject *cardObject;
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"projectname"
                                                                                               uri:@"projecturi"];;
                cardObject = [[PunchCardObject alloc]
                                                    initWithClientType:client
                                                    projectType:project
                                                    oefTypesArray:nil
                                                    breakType:nil
                                                    taskType:nil
                                                    activity:nil
                                                    uri:nil];
                [subject setUpWithPunchCardObject:cardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                [subject view];
                spy_on(subject.view);
            });

            context(@"When validating punch is success", ^{
                beforeEach(^{

                    [subject.createPunchCardButton tap];
                });

                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });

                it(@"should inform delegate when create punch card button is tapped", ^{
                    delegate should have_received(@selector(punchCardController:didChooseToCreatePunchCardWithObject:)).with(subject,Arguments::anything);

                    cardObject.clientType should_not be_nil;
                    cardObject.projectType should_not be_nil;
                    cardObject.taskType should be_nil;

                });

                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(NO);
                });
            });

            context(@"When validating punch is failure", ^{
                __block NSError *error;
                beforeEach(^{
                    NSDictionary* userInfo = @{NSLocalizedDescriptionKey: @"my-awesome-validation-message"};
                    error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                });
                beforeEach(^{
                    punchValidator stub_method(@selector(validatePunchWithClientType:ProjectType:taskType:)).again().and_return(error);
                    
                    [subject.createPunchCardButton tap];
                });
                
                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert.message should equal(@"my-awesome-validation-message");
                    [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                
                it(@"should not inform delegate when create punch card button is tapped", ^{
                    delegate should_not have_received(@selector(punchCardController:didChooseToCreatePunchCardWithObject:)).with(subject,Arguments::anything);
                    
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(NO);
                });
                
                context(@"When user is Punch into Project User", ^{
                   
                    context(@"When Project is nil", ^{
                        beforeEach(^{
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:FilledClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidProjectSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            [subject.createPunchCardButton tap];
                            
                        });
                        
                        it(@"should present the alert to the user", ^{
                            UIAlertView *alert = [UIAlertView currentAlertView];
                            alert.message should equal(InvalidProjectSelectedError);
                            [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                        });
                        
                        it(@"should not inform delegate when create punch card button is tapped", ^{
                            delegate should_not have_received(@selector(punchCardController:didChooseToCreatePunchCardWithObject:)).with(subject,Arguments::anything);
                            
                        });
                        
                        it(@"should end view editing", ^{
                            subject.view should have_received(@selector(endEditing:)).with(NO);
                        });
                    });
                    
                    context(@"When Task is nil", ^{
                        beforeEach(^{
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:FilledClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidTaskSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            [subject.createPunchCardButton tap];
                            
                        });
                        
                        it(@"should present the alert to the user", ^{
                            UIAlertView *alert = [UIAlertView currentAlertView];
                            alert.message should equal(InvalidTaskSelectedError);
                            [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                        });
                        
                        it(@"should not inform delegate when create punch card button is tapped", ^{
                            delegate should_not have_received(@selector(punchCardController:didChooseToCreatePunchCardWithObject:)).with(subject,Arguments::anything);
                            
                        });
                        
                        it(@"should end view editing", ^{
                            subject.view should have_received(@selector(endEditing:)).with(NO);
                        });
                    });

                });
                
                context(@"When user is Punch into Activities User", ^{
                    
                    context(@"When Activity is nil", ^{
                        beforeEach(^{
                            [subject setUpWithPunchCardObject:punchCardObject punchCardType:FilledClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidActivitySelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            [subject.createPunchCardButton tap];
                            
                        });
                        
                        it(@"should present the alert to the user", ^{
                            UIAlertView *alert = [UIAlertView currentAlertView];
                            alert.message should equal(InvalidActivitySelectedError);
                            [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                        });
                        
                        it(@"should not inform delegate when create punch card button is tapped", ^{
                            delegate should_not have_received(@selector(punchCardController:didChooseToCreatePunchCardWithObject:)).with(subject,Arguments::anything);
                            
                        });
                        
                        it(@"should end view editing", ^{
                            subject.view should have_received(@selector(endEditing:)).with(NO);
                        });
                    });
                });

            });
        });

        describe(@"Punch Action", ^{
            beforeEach(^{
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:FilledClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];
                [subject view];
                spy_on(subject.view);
            });

            context(@"When validating punch is success", ^{
                beforeEach(^{
                    [subject.punchActionButton tap];
                });

                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });

                it(@"should inform delegate when create punch card button is tapped", ^{
                    delegate should have_received(@selector(punchCardController:didIntendToPunchWithObject:)).with(subject,punchCardObject);
                });

                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(NO);
                });
            });

            context(@"When validating punch is failure", ^{
                
                context(@"When User is Punch into Project User", ^{
                    context(@"When Project is nil", ^{
                        beforeEach(^{
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidProjectSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            [subject.punchActionButton tap];
                        });
                        
                        it(@"should present the alert to the user", ^{
                            UIAlertView *alert = [UIAlertView currentAlertView];
                            alert.message should equal(InvalidProjectSelectedError);
                            [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                        });
                        
                        it(@"should not inform delegate when create punch card button is tapped", ^{
                            delegate should_not have_received(@selector(punchCardController:didIntendToPunchWithObject:)).with(subject,punchCardObject);
                        });
                        
                        it(@"should end view editing", ^{
                            subject.view should have_received(@selector(endEditing:)).with(NO);
                        });
                    });
                    
                    context(@"When Task is nil", ^{
                        beforeEach(^{
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidTaskSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            [subject.punchActionButton tap];
                        });
                        
                        it(@"should present the alert to the user", ^{
                            UIAlertView *alert = [UIAlertView currentAlertView];
                            alert.message should equal(InvalidTaskSelectedError);
                            [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                        });
                        
                        it(@"should not inform delegate when create punch card button is tapped", ^{
                            delegate should_not have_received(@selector(punchCardController:didIntendToPunchWithObject:)).with(subject,punchCardObject);
                        });
                        
                        it(@"should end view editing", ^{
                            subject.view should have_received(@selector(endEditing:)).with(NO);
                        });
                    });

                });
                
                context(@"When User is Punch into Activities user", ^{
                    context(@"When Activity is nil", ^{
                        beforeEach(^{
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidActivitySelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            [subject.punchActionButton tap];
                        });
                        
                        it(@"should present the alert to the user", ^{
                            UIAlertView *alert = [UIAlertView currentAlertView];
                            alert.message should equal(InvalidActivitySelectedError);
                            [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                        });
                        
                        it(@"should not inform delegate when create punch card button is tapped", ^{
                            delegate should_not have_received(@selector(punchCardController:didIntendToPunchWithObject:)).with(subject,punchCardObject);
                        });
                        
                        it(@"should end view editing", ^{
                            subject.view should have_received(@selector(endEditing:)).with(NO);
                        });
                    });
                });

            });
            
        });

        describe(@"viewDidLayoutSubviews", ^{

            beforeEach(^{
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:FilledClientProjectTaskPunchCard delegate:delegate oefTypesArray:nil];

                subject.view should_not be_nil;
                [subject viewDidLayoutSubviews];
            });

            it(@"should inform the tableViewDelegate PunchDetailsController updated its height when have activity access", ^{
                 userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                delegate should have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)75.0);
            });

            it(@"should inform the tableViewDelegate PunchDetailsController updated its height when have client & project access", ^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                delegate should have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)75.0);
            });

            it(@"should inform the tableViewDelegate PunchDetailsController updated its height when don't have client access", ^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                delegate should have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)75.0);
            });
            
        });

    });


    describe(@"As a <DynamicTextTableViewCellDelegate>", ^{
        __block DynamicTextTableViewCell *firstCell;
        __block DynamicTextTableViewCell *secondCell;
        __block DynamicTextTableViewCell *thirdCell;

        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
             userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
            [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
            [subject view];
            [subject.tableView layoutIfNeeded];
            firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];


        });

        it(@"correct tag should be set up for the dynamic cells", ^{
             firstCell.tag should equal(1);
             secondCell.tag should equal(2);
             thirdCell.tag should equal(3);
        });

        context(@"dynamicTextTableViewCell:didUpdateTextView:", ^{
            beforeEach(^{
                [firstCell.textView setText:@"testing..."];
                [subject dynamicTextTableViewCell:firstCell didUpdateTextView:firstCell.textView];
            });


            it(@"should update table content size", ^{
                delegate should have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
            });

            it(@"should be scrolling the scrollview", ^{
                delegate should have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
            });
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: validate OEF", ^{
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with integer", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithPunchCardObject:punchCardObject
                                        punchCardType:DefaultClientProjectTaskPunchCard
                                             delegate:delegate
                                        oefTypesArray:oefTypeArr];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    
                    [secondCell.textView setText:oefType2.oefNumericValue];
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                });
                
                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                    
                    alert.message should equal(localizedString);
                    [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                
                it(@"should update table content size", ^{
                    delegate should_not have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                    [alert dismissWithOkButton];
                    textView_ should have_received(@selector(becomeFirstResponder));
                    textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
                });

                it(@"should not display alert when already an alert is present", ^{
                    [UIAlertView reset];
                    subject stub_method(@selector(alertViewVisible)).and_return(NO);
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });
            });
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with wholenumber within range and decimal exceeding range", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithPunchCardObject:punchCardObject
                                        punchCardType:DefaultClientProjectTaskPunchCard
                                             delegate:delegate
                                        oefTypesArray:oefTypeArr];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    
                    [secondCell.textView setText:oefType2.oefNumericValue];
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                });
                
                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                    
                    alert.message should equal(localizedString);
                    [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                
                it(@"should update table content size", ^{
                    delegate should_not have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                    [alert dismissWithOkButton];
                    textView_ should have_received(@selector(becomeFirstResponder));
                    textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
                });

                it(@"should not display alert when already an alert is present", ^{
                    [UIAlertView reset];
                    subject stub_method(@selector(alertViewVisible)).and_return(NO);
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });
            });
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with negative integer", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithPunchCardObject:punchCardObject
                                        punchCardType:DefaultClientProjectTaskPunchCard
                                             delegate:delegate
                                        oefTypesArray:oefTypeArr];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    
                    [secondCell.textView setText:oefType2.oefNumericValue];
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                });
                
                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                    
                    alert.message should equal(localizedString);
                    [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                
                it(@"should update table content size", ^{
                    delegate should_not have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                    [alert dismissWithOkButton];
                    textView_ should have_received(@selector(becomeFirstResponder));
                    textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
                });

                it(@"should not display alert when already an alert is present", ^{
                    [UIAlertView reset];
                    subject stub_method(@selector(alertViewVisible)).and_return(NO);
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });
            });
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with negative number within range and decimal exceeding range", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithPunchCardObject:punchCardObject
                                        punchCardType:DefaultClientProjectTaskPunchCard
                                             delegate:delegate
                                        oefTypesArray:oefTypeArr];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    
                    [secondCell.textView setText:oefType2.oefNumericValue];
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                });
                
                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                    
                    alert.message should equal(localizedString);
                    [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                it(@"should update table content size", ^{
                    delegate should_not have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(2002);
                    [alert dismissWithOkButton];
                    textView_ should have_received(@selector(becomeFirstResponder));
                    textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
                });

                it(@"should not display alert when already an alert is present", ^{
                    [UIAlertView reset];
                    subject stub_method(@selector(alertViewVisible)).and_return(NO);
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });
            });
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate Text OEF when Exceeding limit", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1pqrstubwxyz" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithPunchCardObject:punchCardObject
                                        punchCardType:DefaultClientProjectTaskPunchCard
                                             delegate:delegate
                                        oefTypesArray:oefTypeArr];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    
                    [firstCell.textView setText:oefType1.oefTextValue];
                    [subject dynamicTextTableViewCell:firstCell didUpdateTextView:firstCell.textView];
                });
                
                it(@"should present the alert to the user", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFTextFieldValueLimitExceededError, nil), @"255"];
                    
                    alert.message should equal(localizedString);
                    [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                });
                
                it(@"should update table content size", ^{
                    delegate should_not have_received(@selector(punchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    firstCell.textView.tag should equal(2001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:firstCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    firstCell.textView.tag should equal(2001);
                    [alert dismissWithOkButton];
                    textView_ should have_received(@selector(becomeFirstResponder));
                    textView_.keyboardType should equal(UIKeyboardTypeDefault);
                });

                it(@"should not display alert when already an alert is present", ^{
                    [UIAlertView reset];
                    subject stub_method(@selector(alertViewVisible)).and_return(NO);
                    [subject dynamicTextTableViewCell:firstCell didUpdateTextView:firstCell.textView];
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should be_nil;
                });
            });
        });

        context(@"dynamicTextTableViewCell:didBeginEditingTextView:", ^{

            context(@"when value is not present", ^{
                beforeEach(^{
                    [subject dynamicTextTableViewCell:firstCell didBeginEditingTextView:firstCell.textView];
                });

                it(@"should set clear textview placeholder text", ^{
                    firstCell.textView.text should equal(@"");
                });

                it(@"should be scrolling the scrollview", ^{
                    delegate should have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });
            });

            context(@"when value is  present", ^{
                beforeEach(^{
                    secondCell.textView.text = @"testing....";
                    [subject dynamicTextTableViewCell:secondCell didBeginEditingTextView:secondCell.textView];
                });

                it(@"should not set clear textview placeholder text", ^{
                    secondCell.textView.text should equal(@"testing....");
                });

                it(@"should be scrolling the scrollview", ^{
                    delegate should have_received(@selector(punchCardController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });
            });
        });

        context(@"dynamicTextTableViewCell:didEndEditingTextView:", ^{
            context(@"when value is  nil", ^{
                beforeEach(^{
                    firstCell.textView.text = nil;
                    [subject dynamicTextTableViewCell:firstCell didEndEditingTextView:firstCell.textView];
                });

                it(@"should set textview placeholder text", ^{
                    firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                });

                it(@"correct punch card value for oef should be configured", ^{
                    subject.punchCardObject.oefTypesArray.count should equal(3);
                    OEFType *oeftType =  subject.punchCardObject.oefTypesArray[0];
                    oeftType.oefTextValue should equal(@"");
                });
            });

            context(@"when value is empty string", ^{
                beforeEach(^{
                    firstCell.textView.text = @"";
                    [subject dynamicTextTableViewCell:firstCell didEndEditingTextView:firstCell.textView];
                });

                it(@"should set textview placeholder text", ^{
                    firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                });

                it(@"correct punch card value for oef should be configured", ^{
                    subject.punchCardObject.oefTypesArray.count should equal(3);
                    OEFType *oeftType =  subject.punchCardObject.oefTypesArray[0];
                    oeftType.oefTextValue should equal(@"");
                });
            });

            context(@"when value is  present", ^{
                beforeEach(^{
                    secondCell.textView.text = @"100.577";
                    [subject dynamicTextTableViewCell:secondCell didEndEditingTextView:secondCell.textView];
                });

                it(@"should not set clear textview placeholder text", ^{
                    secondCell.textView.text should equal(@"100.577");
                });

                it(@"should update oefTypes Array", ^{
                    OEFType *oefType = subject.oefTypesArray[1];
                    oefType.oefNumericValue should equal(@"100.577");
                });
            });

        });

    });

    describe(@"Tapping on DynamicTextTableViewCell", ^{
        __block DynamicTextTableViewCell *cell;

        context(@"when tapping on text/numeric oef", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                [subject view];
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                spy_on(cell.textView);
                [cell tap];

            });

            it(@"should set focus on the text view", ^{
                cell.textView should have_received(@selector(becomeFirstResponder));
            });
        });

        context(@"when tapping on dropdown oef", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                [subject setUpWithPunchCardObject:punchCardObject punchCardType:DefaultClientProjectTaskPunchCard delegate:delegate oefTypesArray:oefTypesArray];
                [subject view];
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                spy_on(cell.textView);
                [cell tap];

            });

            it(@"should navigate when dropdown oef cell is clicked", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
            });
        });


    });
});

SPEC_END
