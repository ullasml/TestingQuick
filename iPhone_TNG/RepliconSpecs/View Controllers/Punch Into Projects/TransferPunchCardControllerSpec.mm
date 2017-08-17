#import <Cedar/Cedar.h>
#import "TransferPunchCardController.h"
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
#import "ActivityRepository.h"
#import "UserPermissionsStorage.h"
#import "UserSession.h"
#import "OEFType.h"
#import "UITableViewCell+Spec.h"
#import "OEFDropDownRepository.h"
#import "GUIDProvider.h"
#import "OEFDropDownType.h"
#import "InjectorKeys.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TransferPunchCardControllerSpec)

describe(@"TransferPunchCardController", ^{
    __block TransferPunchCardController <CedarDouble>*subject;
    __block id <Theme> theme;
    __block UINavigationController *navigationController;
    __block id <BSInjector,BSBinder> injector;
    __block SelectionController <CedarDouble> *selectionController;
    __block PunchCardObject *punchCardObject;
    __block PunchCardStylist *punchCardStylist;
    __block id <TransferPunchCardControllerDelegate> delegate;
    __block PunchValidator *punchValidator;
    __block id <UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block NSMutableArray *oefTypesArray;
    __block OEFType *oefType1;
    __block OEFType *oefType2;
    __block OEFType *oefType3;
    __block GUIDProvider *guidProvider;

    beforeEach(^{
        injector = [InjectorProvider injector];

        punchValidator = nice_fake_for([PunchValidator class]);
        [injector bind:[PunchValidator class] toInstance:punchValidator];

        punchCardStylist = nice_fake_for([PunchCardStylist class]);
        [injector bind:[PunchCardStylist class] toInstance:punchCardStylist];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).and_return(nil);

        delegate = nice_fake_for(@protocol(TransferPunchCardControllerDelegate));

        selectionController = (id) [[SelectionController alloc] initWithProjectStorage:NULL expenseProjectStorage:NULL timerProvider:nil userDefaults:nil theme:nil];
        [injector bind:InjectorKeySelectionControllerForPunchModule toInstance:selectionController];

        guidProvider = nice_fake_for([GUIDProvider class]);
        [injector bind:[GUIDProvider class] toInstance:guidProvider];
        
        guidProvider stub_method(@selector(guid)).and_return(@"guid-A");
        
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        [injector bind:@protocol(UserSession) toInstance:userSession];

        subject = [injector getInstance:[TransferPunchCardController class]];
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
                                                     breakType:nil
                                                      taskType:nil
                                                      activity:nil
                                                           uri:@"guid-A"];
        [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:TransferWorkFlowType];

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(selectionController);

    });

    beforeEach(^{

        theme stub_method(@selector(transferPunchButtonButtonColor)).and_return([UIColor whiteColor]);
        theme stub_method(@selector(transferPunchButtonTitleLabelFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(transferPunchButtonCornerRadius)).and_return((CGFloat)1.0);
        theme stub_method(@selector(transferPunchButtonBorderColor)).and_return([UIColor greenColor].CGColor);
        theme stub_method(@selector(transferPunchButtonBorderWidth)).and_return((CGFloat)2.0);
        theme stub_method(@selector(transferPunchButtonTitleColor)).and_return([UIColor magentaColor]);

        theme stub_method(@selector(transferCardSelectionCellNameFontColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(transferCardSelectionCellValueFontColor)).and_return([UIColor magentaColor]);
        theme stub_method(@selector(transferCardSelectionCellValueDisabledFontColor)).and_return([UIColor grayColor]);
        theme stub_method(@selector(transferCardSelectionCellValueFont)).and_return([UIFont systemFontOfSize:2]);
        theme stub_method(@selector(transferCardSelectionCellNameFont)).and_return([UIFont systemFontOfSize:1]);


    });

    describe(@"Styling the views", ^{

        beforeEach(^{
            [subject view];
        });

        it(@"should not style the card with border", ^{
            punchCardStylist should_not have_received(@selector(styleBorderForView:)).with(subject.view);
        });

        it(@"should style create punch card correctly", ^{

            subject.transferPunchCardButton.backgroundColor should equal([UIColor whiteColor]);
            subject.transferPunchCardButton.titleLabel.font should equal([UIFont systemFontOfSize:10]);
            subject.transferPunchCardButton.layer.cornerRadius should equal((CGFloat)1.0);
            subject.transferPunchCardButton.layer.borderColor should equal([UIColor greenColor].CGColor);
            subject.transferPunchCardButton.layer.borderWidth should equal((CGFloat)2.0);

        });

    });

    describe(@"When the view loads", ^{

        context(@"When Transfer Flow", ^{

            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:TransferWorkFlowType];
                [subject view];
                [subject.tableView layoutIfNeeded];
            });

            it(@"should set the title of the button  correctly", ^{
                subject.transferPunchCardButton.titleLabel.text should equal(RPLocalizedString(@"Transfer", nil));
            });

        });

        context(@"When Resume Flow", ^{

            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:ResumeWorkFlowType];
                [subject view];
                [subject.tableView layoutIfNeeded];
            });

            it(@"should set the title of the button  correctly", ^{
                subject.transferPunchCardButton.titleLabel.text should equal(RPLocalizedString(@"Resume Work", nil));
            });

        });

        context(@"without OEFs", ^{
            __block NSIndexPath *firstRowIndexPath;
            __block NSIndexPath *secondRowIndexPath;
            __block NSIndexPath *thirdRowIndexPath;
            
            
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                [subject view];
                [subject.tableView layoutIfNeeded];

            });

            it(@"should have a correct number of section and rows in tableview", ^{
                subject.tableView.numberOfSections should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(3);
            });
            
            it(@"should style the cells correctly", ^{
                UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                
                cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell.textLabel.font should equal([UIFont systemFontOfSize:1]);
                cell.detailTextLabel.font should equal([UIFont systemFontOfSize:2]);
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
            
            it(@"should navigate when client cell is clicked", ^{
                ClientType *client = [[ClientType alloc] initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:nil
                                                                                               uri:nil];
                PunchCardObject *expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                   projectType:project
                                                                 oefTypesArray:nil
                                                                     breakType:nil
                                                                      taskType:nil
                                                                      activity:nil
                                                                           uri:@"guid-A"];
                
                [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,expectedPunchCard,subject);
            });
            
            it(@"should navigate when project cell is clicked without selecting client", ^{
                
                [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
                
                subject.punchCardObject.clientType should equal(nil);
            });
            
            it(@"should navigate when project cell is clicked", ^{
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                [subject selectionController:nil didChooseClient:client];
                
                [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
                
                subject.punchCardObject.clientType should equal(client);
            });
            
            
            it(@"should navigate when task cell is clicked after selecting client and project", ^{
                
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                [subject selectionController:nil didChooseClient:client];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:nil];
                [subject selectionController:nil didChooseProject:project];
                
                [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                
                subject.punchCardObject.clientType should equal(client);
                subject.punchCardObject.projectType should equal(project);
            });
            
            
            it(@"should navigate when task cell is clicked after selecting only project", ^{
                ClientType *clientType = [[ClientType alloc] initWithName:nil uri:nil];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:@"project-name"
                                                                                               uri:nil];;
                [subject selectionController:nil didChooseProject:project];
                
                [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                
                subject.punchCardObject.clientType should equal(clientType);
                subject.punchCardObject.projectType should equal(project);
            });
        });
        
        context(@"with oef's", ^{
            
            context(@"As a punch into projects flow when user has client access", ^{
                __block NSIndexPath *firstRowIndexPath;
                __block NSIndexPath *secondRowIndexPath;
                __block NSIndexPath *thirdRowIndexPath;
                __block NSIndexPath *fourthRowIndexPath;
                __block NSIndexPath *fifthRowIndexPath;
                __block NSMutableArray *oefTypes;
                __block OEFType *oefType;
                __block OEFType *oefTypeText;

                beforeEach(^{
                    oefTypeText = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];
                    oefTypes = [NSMutableArray arrayWithObjects:oefTypeText, oefType, nil];

                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    
                    firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                    fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypes flowType:TransferWorkFlowType];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should have a correct number of section and rows in tableview", ^{
                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                });
                
                it(@"should style the cells correctly", ^{
                    UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell.textLabel.font should equal([UIFont systemFontOfSize:1]);
                    cell.detailTextLabel.font should equal([UIFont systemFontOfSize:2]);
                    cell.textLabel.textColor should equal([UIColor orangeColor]);
                    cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                    
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    firstCell should be_instance_of([UITableViewCell class]);
                    firstCell.textLabel.text should equal(RPLocalizedString(@"Client", nil));
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    firstCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                    secondCell should be_instance_of([UITableViewCell class]);
                    secondCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    secondCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                    thirdCell should be_instance_of([UITableViewCell class]);
                    thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    thirdCell.userInteractionEnabled should be_falsy;
                    thirdCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                    thirdCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                    DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                    fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                    fourthCell.title.text should equal(oefTypeText.oefName);
                    fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                    fourthCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    fourthCell.title.font should equal([UIFont systemFontOfSize:1]);
                    fourthCell.textView.font should equal([UIFont systemFontOfSize:2]);
                    fourthCell.title.textColor should equal([UIColor orangeColor]);
                    fourthCell.textView.textColor should equal([UIColor magentaColor]);
                    fourthCell.accessoryType should equal(UITableViewCellAccessoryNone);
                    
                    
                    DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthRowIndexPath];
                    fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                    fifthCell.title.text should equal(oefType.oefName);
                    fifthCell.textValueLabel.text should equal(RPLocalizedString(@"Select", @""));
                    fifthCell.title.font should equal([UIFont systemFontOfSize:1]);
                    fifthCell.textValueLabel.font should equal([UIFont systemFontOfSize:2]);
                    fifthCell.title.textColor should equal([UIColor orangeColor]);
                    fifthCell.textValueLabel.textColor should equal([UIColor magentaColor]);
                    fifthCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);

                });

                context(@"When view loads with project info", ^{
                    beforeEach(^{
                        [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:TransferWorkFlowType];
                        ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                        [subject selectionController:nil didChooseClient:client];
                        
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                   isTimeAllocationAllowed:NO
                                                                                             projectPeriod:nil
                                                                                                clientType:client
                                                                                                      name:@"project-name"
                                                                                                       uri:@"project-uri"];
                        [subject selectionController:nil didChooseProject:project];
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
                
                it(@"should navigate when client cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when project cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when task cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                });

                it(@"should navigate when dropdown cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:fifthRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,Arguments::anything,subject);
                });
                
                
            });
            
            context(@"As a punch into projects flow when user has client access and entry selected from list", ^{
                __block NSIndexPath *firstRowIndexPath;
                __block NSIndexPath *secondRowIndexPath;
                __block NSIndexPath *thirdRowIndexPath;
                __block NSIndexPath *fourthRowIndexPath;
                __block NSIndexPath *fifthRowIndexPath;
                __block NSMutableArray *oefTypes;
                __block OEFType *oefType;
                __block OEFType *oefTypeText;
                __block PunchCardObject *expectedPunchCardObject;
                beforeEach(^{
                    oefTypeText = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];
                    oefTypes = [NSMutableArray arrayWithObjects:oefTypeText, oefType, nil];
                    
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                    
                    firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                    fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                    
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];

                    expectedPunchCardObject = [[PunchCardObject alloc]
                                       initWithClientType:client
                                       projectType:project
                                       oefTypesArray:nil
                                       breakType:nil
                                       taskType:task
                                       activity:nil
                                       uri:@"uri"];

                    [subject setUpWithDelegate:delegate punchCardObject:expectedPunchCardObject oefTypes:oefTypes flowType:TransferWorkFlowType];
                    
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should have a correct number of section and rows in tableview", ^{
                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                });
                
                it(@"should style the cells correctly", ^{
                    UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell.textLabel.font should equal([UIFont systemFontOfSize:1]);
                    cell.detailTextLabel.font should equal([UIFont systemFontOfSize:2]);
                    cell.textLabel.textColor should equal([UIColor orangeColor]);
                    cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                    
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    firstCell should be_instance_of([UITableViewCell class]);
                    firstCell.textLabel.text should equal(RPLocalizedString(@"Client", nil));
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(@"client-name", nil));
                    firstCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                    secondCell should be_instance_of([UITableViewCell class]);
                    secondCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"project-name", nil));
                    secondCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                    thirdCell should be_instance_of([UITableViewCell class]);
                    thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                    thirdCell.userInteractionEnabled should be_truthy;
                    thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                    thirdCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                    DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                    fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                    fourthCell.title.text should equal(oefTypeText.oefName);
                    fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                    fourthCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    fourthCell.title.font should equal([UIFont systemFontOfSize:1]);
                    fourthCell.textView.font should equal([UIFont systemFontOfSize:2]);
                    fourthCell.title.textColor should equal([UIColor orangeColor]);
                    fourthCell.textView.textColor should equal([UIColor magentaColor]);
                    fourthCell.accessoryType should equal(UITableViewCellAccessoryNone);
                    
                    
                    DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthRowIndexPath];
                    fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                    fifthCell.title.text should equal(oefType.oefName);
                    fifthCell.textValueLabel.text should equal(RPLocalizedString(@"Select", @""));
                    fifthCell.title.font should equal([UIFont systemFontOfSize:1]);
                    fifthCell.textValueLabel.font should equal([UIFont systemFontOfSize:2]);
                    fifthCell.title.textColor should equal([UIColor orangeColor]);
                    fifthCell.textValueLabel.textColor should equal([UIColor magentaColor]);
                    fifthCell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    
                });
                
                it(@"should navigate when client cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when project cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when task cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                });
            });
            
            context(@"As a punch into projects flow when user don't have client access", ^{
                __block NSIndexPath *firstRowIndexPath;
                __block NSIndexPath *secondRowIndexPath;
                __block NSIndexPath *thirdRowIndexPath;
                __block NSIndexPath *fourthRowIndexPath;
                __block NSIndexPath *fifthhRowIndexPath;
                
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                    
                    firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                    fifthhRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypesArray flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should have a correct number of section and rows in tableview", ^{
                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                });
                
                it(@"should style the cells correctly", ^{
                    UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell.textLabel.font should equal([UIFont systemFontOfSize:1]);
                    cell.detailTextLabel.font should equal([UIFont systemFontOfSize:2]);
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
                });
                
                context(@"When view loads with project info", ^{
                    beforeEach(^{
                        [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:TransferWorkFlowType];
                        ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                        [subject selectionController:nil didChooseClient:client];
                        
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                   isTimeAllocationAllowed:NO
                                                                                             projectPeriod:nil
                                                                                                clientType:client
                                                                                                      name:@"project-name"
                                                                                                       uri:@"project-uri"];
                        [subject selectionController:nil didChooseProject:project];
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
                
                
                it(@"should navigate when project cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when task cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                });
            });
            
            context(@"As a punch into projects flow when user don't have client access and entry selected from list", ^{
                __block NSIndexPath *firstRowIndexPath;
                __block NSIndexPath *secondRowIndexPath;
                __block NSIndexPath *thirdRowIndexPath;
                __block NSIndexPath *fourthRowIndexPath;
                __block NSIndexPath *fifthhRowIndexPath;
                __block PunchCardObject *expectedPunchCardObject;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                    
                    firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                    fifthhRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                    
                    
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:nil
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];
                    
                    expectedPunchCardObject = [[PunchCardObject alloc]
                                               initWithClientType:nil
                                               projectType:project
                                               oefTypesArray:nil
                                               breakType:nil
                                               taskType:task
                                               activity:nil
                                               uri:@"uri"];

                    [subject setUpWithDelegate:delegate punchCardObject:expectedPunchCardObject oefTypes:oefTypesArray flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                });
                
                it(@"should have a correct number of section and rows in tableview", ^{
                    subject.tableView.numberOfSections should equal(1);
                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                });
                
                it(@"should style the cells correctly", ^{
                    UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                    cell.textLabel.font should equal([UIFont systemFontOfSize:1]);
                    cell.detailTextLabel.font should equal([UIFont systemFontOfSize:2]);
                    cell.textLabel.textColor should equal([UIColor orangeColor]);
                    cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                    
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                    firstCell should be_instance_of([UITableViewCell class]);
                    firstCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(@"project-name", nil));
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                    secondCell should be_instance_of([UITableViewCell class]);
                    secondCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                    secondCell.userInteractionEnabled should be_truthy;
                    secondCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                    
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
                });
                
                context(@"When view loads with project info", ^{
                    beforeEach(^{
                        [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:TransferWorkFlowType];
                        ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                        [subject selectionController:nil didChooseClient:client];
                        
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                   isTimeAllocationAllowed:NO
                                                                                             projectPeriod:nil
                                                                                                clientType:client
                                                                                                      name:@"project-name"
                                                                                                       uri:@"project-uri"];
                        [subject selectionController:nil didChooseProject:project];
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
                
                
                it(@"should navigate when project cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when task cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                });
                
                it(@"should navigate when dropdown cell is clicked", ^{
                    [subject tableView:subject.tableView didSelectRowAtIndexPath:fifthhRowIndexPath];
                    navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                    navigationController.navigationBar.hidden should be_falsy;
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,Arguments::anything,subject);
                });
            });
        });
        
        context(@"When Punch into Project flow and when Project Selection is mandatory", ^{
            __block NSIndexPath *firstRowIndexPath;
            __block NSIndexPath *secondRowIndexPath;
            __block NSIndexPath *thirdRowIndexPath;
            __block NSIndexPath *fourthRowIndexPath;
            __block NSIndexPath *fifthRowIndexPath;
            __block NSMutableArray *oefTypes;
            __block OEFType *oefType;
            __block OEFType *oefTypeText;
            __block PunchCardObject *punchCard_;
            
            beforeEach(^{
                oefTypeText = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];
                oefTypes = [NSMutableArray arrayWithObjects:oefTypeText, oefType, nil];
                
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                [subject selectionController:nil didChooseClient:client];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = YES;
                
                punchCard_ = [[PunchCardObject alloc] initWithClientType:client
                                                             projectType:project
                                                           oefTypesArray:oefTypes breakType:nil
                                                                taskType:nil
                                                                activity:nil
                                                                     uri:nil];
                
                subject stub_method(@selector(localPunchCardObject)).and_return(punchCard_);
                
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                
                firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypes flowType:TransferWorkFlowType];
                
                [subject view];
                [subject.tableView layoutIfNeeded];
            });
            
            it(@"should navigate when project cell is clicked", ^{
                [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCard_,subject);
            });
            
            
        });
        
        context(@"When Punch into Project flow and when Project Selection is optional", ^{
            __block NSIndexPath *firstRowIndexPath;
            __block NSIndexPath *secondRowIndexPath;
            __block NSIndexPath *thirdRowIndexPath;
            __block NSIndexPath *fourthRowIndexPath;
            __block NSIndexPath *fifthRowIndexPath;
            __block NSMutableArray *oefTypes;
            __block OEFType *oefType;
            __block OEFType *oefTypeText;
            __block PunchCardObject *punchCard_;
            
            beforeEach(^{
                oefTypeText = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];
                oefTypes = [NSMutableArray arrayWithObjects:oefTypeText, oefType, nil];
                
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                [subject selectionController:nil didChooseClient:client];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                project.isProjectTypeRequired = NO;
                
                punchCard_ = [[PunchCardObject alloc] initWithClientType:client
                                                             projectType:project
                                                           oefTypesArray:oefTypes breakType:nil
                                                                taskType:nil
                                                                activity:nil
                                                                     uri:nil];
                
                subject stub_method(@selector(localPunchCardObject)).and_return(punchCard_);
                
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                
                firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypes flowType:TransferWorkFlowType];
                
                [subject view];
                [subject.tableView layoutIfNeeded];
            });
            
            it(@"should navigate when project cell is clicked", ^{
                [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCard_,subject);
            });
            
            
        });
    });
    
    describe(@"When the view loads and don't have client access", ^{
        __block NSIndexPath *firstRowIndexPath;
        __block NSIndexPath *secondRowIndexPath;

        context(@"When Transfer Flow", ^{

            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:TransferWorkFlowType];
                [subject view];
                [subject.tableView layoutIfNeeded];
            });

            it(@"should set the title of the button  correctly", ^{
                subject.transferPunchCardButton.titleLabel.text should equal(RPLocalizedString(@"Transfer", nil));
            });

        });

        context(@"When Resume Flow", ^{

            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:nil flowType:ResumeWorkFlowType];
                [subject view];
                [subject.tableView layoutIfNeeded];
            });

            it(@"should set the title of the button  correctly", ^{
                subject.transferPunchCardButton.titleLabel.text should equal(RPLocalizedString(@"Resume Work", nil));
            });
            
        });
        
        
        context(@"Cells should display appropriately",^{

            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [subject view];
                [subject.tableView layoutIfNeeded];
            });

            it(@"should have a correct number of section and rows in tableview", ^{
                subject.tableView.numberOfSections should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(2);
            });

            it(@"should style the cells correctly", ^{
                UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];

                cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell.textLabel.font should equal([UIFont systemFontOfSize:1]);
                cell.detailTextLabel.font should equal([UIFont systemFontOfSize:2]);
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
            });


            it(@"should navigate when project cell is clicked", ^{
                [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,Arguments::anything,subject);
            });


            it(@"should navigate when task cell is clicked after selecting project", ^{

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:@"project-name"
                                                                                               uri:nil];
                [subject selectionController:nil didChooseProject:project];

                [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,Arguments::anything,subject);
                
                subject.punchCardObject.projectType should equal(project);
            });
        });
        
    });

    describe(@"As a <SelectionControllerDelegate>", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
            [subject view];
            [subject.tableView layoutIfNeeded];
        });
        
        context(@"without OEFs", ^{
            context(@"When updating client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
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
            
            context(@"When updating client and client null behaviour filter is selected and type is Any Client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:ClientTypeAnyClient uri:ClientTypeAnyClientUri];
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
            
            context(@"When updating client and client null behaviour filter is selected and type is No Client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:ClientTypeNoClient uri:ClientTypeNoClientUri];
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
                                                                                                       uri:@"project-uri"];;
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
                
                context(@"Selecting a none project without uri with a client", ^{
                    beforeEach(^{
                        ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                   isTimeAllocationAllowed:NO
                                                                                             projectPeriod:nil
                                                                                                clientType:client
                                                                                                      name:@"project-name"
                                                                                                       uri:@"project-uri"];
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
                beforeEach(^{
                    TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];
                    [subject selectionController:nil didChooseTask:task];
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"task-name");
                    
                    subject.transferPunchCardButton.userInteractionEnabled should be_truthy;
                    
                });
            });
        });
        
        context(@"with OEFs", ^{
            __block PunchCardObject *expectedPunchCard;
            
            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypesArray flowType:TransferWorkFlowType];
            });

            context(@"When updating client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                       projectType:nil
                                                                     oefTypesArray:oefTypesArray
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:@"guid-A"];
                    [subject selectionController:nil didChooseClient:client];
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"client-name");
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    
                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    
                    subject.punchCardObject should equal(expectedPunchCard);
                });
            });
            
            context(@"When updating client and client null behaviour filter is selected and type is Any Client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:ClientTypeAnyClient uri:ClientTypeAnyClientUri];
                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                       projectType:nil
                                                                     oefTypesArray:oefTypesArray
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:@"guid-A"];
                    [subject selectionController:nil didChooseClient:client];
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(ClientTypeAnyClient, nil));
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    
                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    
                    subject.localPunchCardObject should equal(expectedPunchCard);
                });
            });
            
            context(@"When updating client and client null behaviour filter is selected and type is No Client", ^{
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:ClientTypeNoClient uri:ClientTypeNoClientUri];
                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                       projectType:nil
                                                                     oefTypesArray:oefTypesArray
                                                                         breakType:nil
                                                                          taskType:nil
                                                                          activity:nil
                                                                               uri:@"guid-A"];
                    [subject selectionController:nil didChooseClient:client];
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(ClientTypeNoClient, nil));
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    
                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                    
                    subject.localPunchCardObject should equal(expectedPunchCard);
                });
            });
            
            context(@"When updating Project", ^{
                
                context(@"Selecting a project without a client", ^{
                    beforeEach(^{
                        ClientType *client = [[ClientType alloc] initWithName:nil uri:nil];
                        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                   isTimeAllocationAllowed:NO
                                                                                             projectPeriod:nil
                                                                                                clientType:nil
                                                                                                      name:@"project-name"
                                                                                                       uri:@"project-uri"];
                        expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                           projectType:project
                                                                         oefTypesArray:oefTypesArray
                                                                             breakType:nil
                                                                              taskType:nil
                                                                              activity:nil
                                                                                   uri:@"guid-A"];
                        [subject selectionController:nil didChooseProject:project];
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        secondCell.detailTextLabel.text should equal(@"project-name");
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        subject.localPunchCardObject should equal(expectedPunchCard);
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
                                                                         oefTypesArray:oefTypesArray
                                                                             breakType:nil
                                                                              taskType:nil
                                                                              activity:nil
                                                                                   uri:@"guid-A"];
                        [subject selectionController:nil didChooseProject:project];
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        firstCell.detailTextLabel.text should equal(@"client-name");
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        secondCell.detailTextLabel.text should equal(@"project-name");
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        subject.punchCardObject should equal(expectedPunchCard);
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
                                                                         oefTypesArray:oefTypesArray
                                                                             breakType:nil
                                                                              taskType:nil
                                                                              activity:nil
                                                                                   uri:@"guid-A"];
                        [subject selectionController:nil didChooseProject:project];
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        firstCell.detailTextLabel.text should equal(@"client-name");
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        secondCell.detailTextLabel.text should equal(@"project-name");
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        subject.punchCardObject should equal(expectedPunchCard);
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
                                                                         oefTypesArray:oefTypesArray
                                                                             breakType:nil
                                                                              taskType:nil
                                                                              activity:nil
                                                                                   uri:@"guid-A"];
                        [subject selectionController:nil didChooseProject:project];
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        firstCell.detailTextLabel.text should equal(@"client-name");
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                        secondCell.detailTextLabel.text should equal(@"project-name");
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        subject.punchCardObject should equal(expectedPunchCard);
                    });
                });
                
            });
            
            context(@"When updating Task", ^{
                
                context(@"after updating project", ^{
                    
                    beforeEach(^{
                        ClientType *client = [[ClientType alloc] initWithName:nil uri:nil];
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
                                                                         oefTypesArray:oefTypesArray
                                                                             breakType:nil
                                                                              taskType:task
                                                                              activity:nil
                                                                                   uri:@"guid-A"];
                        [subject selectionController:nil didChooseTask:task];
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        firstCell.detailTextLabel.text should equal(@"task-name");
                        
                        subject.localPunchCardObject should equal(expectedPunchCard);
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
                                                                         oefTypesArray:oefTypesArray
                                                                             breakType:nil
                                                                              taskType:task
                                                                              activity:nil
                                                                                   uri:@"guid-A"];
                        [subject selectionController:nil didChooseTask:task];
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                        firstCell.detailTextLabel.text should equal(@"task-name");
                        
                        subject.punchCardObject should equal(expectedPunchCard);
                    });
                    
                    
                });
            });

            context(@"When updating DropDownOEF", ^{
                beforeEach(^{

                    ClientType *client = [[ClientType alloc] initWithName:nil uri:nil];
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

                     [subject selectionController:nil didChooseTask:task];

                    OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                     OEFType *newOEFType = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"new-dropdown-name" collectAtTimeOfPunch:NO disabled:YES];
                    subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");

                    expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                       projectType:project
                                                                     oefTypesArray:@[oefType1,oefType2,newOEFType]
                                                                         breakType:nil
                                                                          taskType:task
                                                                          activity:nil
                                                                               uri:@"guid-A"];

                    [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
                });

                it(@"should setup the cells correctly", ^{

                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(@"Select");

                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(RPLocalizedString(@"project-name", nil));

                    UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));

                    DynamicTextTableViewCell *fourthCell = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    fourthCell.title.text should equal(@"dropdown oef 1");
                    fourthCell.textValueLabel.text should equal(@"new-dropdown-name");

                    subject.punchCardObject should equal(expectedPunchCard);
                });

                it(@"should inform the tableViewDelegate AllPunchCardController to update its height", ^{
                    delegate should have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)75.0);
                });
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
    
    describe(@"As a <SelectionControllerDelegate> and don't have client access", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
            [subject view];
            [subject.tableView layoutIfNeeded];
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
                    [subject selectionController:nil didChooseProject:project];
                });
                
                it(@"should setup the cells correctly", ^{
                    
                    UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    firstCell.detailTextLabel.text should equal(RPLocalizedString(@"project-name", nil));
                    
                    UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    secondCell.detailTextLabel.text should equal(@"Select");
                    
                });
                
            });
        });
        
        context(@"When updating Task", ^{
            beforeEach(^{
                TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                           taskPeriod:nil
                                                                 name:@"task-name"
                                                                  uri:@"task-uri"];
                [subject selectionController:nil didChooseTask:task];
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"task-name");
                
                subject.transferPunchCardButton.userInteractionEnabled should be_truthy;
                
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

    describe(@"Tranfer using punch card", ^{

        beforeEach(^{
            [subject view];
        });

        context(@"When validating punch is success", ^{
            beforeEach(^{

                [subject.transferPunchCardButton tap];
            });

            it(@"should present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });

            it(@"should inform delegate when create punch card button is tapped", ^{
                delegate should have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);

                punchCardObject.clientType should be_nil;
                punchCardObject.projectType should be_nil;
                punchCardObject.taskType should be_nil;

            });
        });

        context(@"When validating punch is failure", ^{
            
            context(@"When Punch into Project User", ^{
                
                context(@"When Project is not selected and Project Selection is Mandatory", ^{
                    
                    beforeEach(^{
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidProjectSelectedError};
                        NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                        [subject.transferPunchCardButton tap];
                    });
                    
                    it(@"should present the alert to the user", ^{
                        UIAlertView *alert = [UIAlertView currentAlertView];
                        alert should_not be_nil;
                        alert.message should equal(InvalidProjectSelectedError);
                        [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });
                    
                    it(@"should not inform delegate when create punch card button is tapped", ^{
                        delegate should_not have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);
                        
                    });
                    
                });
                
                context(@"When Task is not selected", ^{
                    
                    beforeEach(^{
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidTaskSelectedError};
                        NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                        [subject.transferPunchCardButton tap];
                    });
                    
                    it(@"should present the alert to the user", ^{
                        UIAlertView *alert = [UIAlertView currentAlertView];
                        alert should_not be_nil;
                        alert.message should equal(InvalidTaskSelectedError);
                        [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });
                    
                    it(@"should not inform delegate when create punch card button is tapped", ^{
                        delegate should_not have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);
                        
                    });
                    
                });
                
            });
            
            context(@"When Punch into Activity User", ^{
                
                context(@"When Activity is not selected", ^{
                    
                    beforeEach(^{
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidActivitySelectedError};
                        NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                        [subject.transferPunchCardButton tap];
                    });
                    
                    it(@"should present the alert to the user", ^{
                        UIAlertView *alert = [UIAlertView currentAlertView];
                        alert should_not be_nil;
                        alert.message should equal(InvalidActivitySelectedError);
                        [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });
                    
                    it(@"should not inform delegate when create punch card button is tapped", ^{
                        delegate should_not have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);
                        
                    });
                    
                });
            });


        });

    });

    describe(@"ResumeWork using punch card ", ^{

        context(@"When validating punch is success and with Project access", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:punchCardObject oefTypes:oefTypesArray flowType:ResumeWorkFlowType];
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                [subject view];
                [subject.transferPunchCardButton tap];
            });

            it(@"should not present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });

            it(@"should inform delegate when create punch card button is tapped", ^{
                delegate should have_received(@selector(transferPunchCardController:didIntendToResumeWorkForProjectPunchWithObject:)).with(subject,Arguments::anything);

            });
        });

        context(@"When validating punch is success and with Activity access", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate punchCardObject:punchCardObject oefTypes:oefTypesArray flowType:ResumeWorkFlowType];
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                [subject view];
                [subject.transferPunchCardButton tap];
            });

            it(@"should not present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });

            it(@"should inform delegate when create punch card button is tapped", ^{
                delegate should have_received(@selector(transferPunchCardController:didIntendToResumeWorkForActivityPunchWithObject:)).with(subject,Arguments::anything);

            });
        });

        context(@"When validating punch is failure", ^{

            context(@"When Punch into Project User", ^{

                context(@"When Project is not selected and Project Selection is Mandatory", ^{

                    beforeEach(^{
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidProjectSelectedError};
                        NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                        [subject view];
                        [subject.transferPunchCardButton tap];
                    });

                    it(@"should present the alert to the user", ^{
                        UIAlertView *alert = [UIAlertView currentAlertView];
                        alert should_not be_nil;
                        alert.message should equal(InvalidProjectSelectedError);
                        [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });

                    it(@"should not inform delegate when create punch card button is tapped", ^{
                        delegate should_not have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);

                    });

                });

                context(@"When Task is not selected", ^{

                    beforeEach(^{
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidTaskSelectedError};
                        NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                        [subject view];
                        [subject.transferPunchCardButton tap];
                    });

                    it(@"should present the alert to the user", ^{
                        UIAlertView *alert = [UIAlertView currentAlertView];
                        alert should_not be_nil;
                        alert.message should equal(InvalidTaskSelectedError);
                        [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });

                    it(@"should not inform delegate when create punch card button is tapped", ^{
                        delegate should_not have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);

                    });

                });

            });

            context(@"When Punch into Activity User", ^{

                context(@"When Activity is not selected", ^{

                    beforeEach(^{
                        NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidActivitySelectedError};
                        NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                        [subject view];
                        [subject.transferPunchCardButton tap];
                    });

                    it(@"should present the alert to the user", ^{
                        UIAlertView *alert = [UIAlertView currentAlertView];
                        alert should_not be_nil;
                        alert.message should equal(InvalidActivitySelectedError);
                        [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
                    });

                    it(@"should not inform delegate when create punch card button is tapped", ^{
                        delegate should_not have_received(@selector(transferPunchCardController:didIntendToTransferPunchWithObject:)).with(subject,Arguments::anything);

                    });
                    
                });
            });
            
            
        });
        
    });
    
    describe(@"As a <DynamicTextTableViewCellDelegate>", ^{
        __block DynamicTextTableViewCell *firstCell;
        __block DynamicTextTableViewCell *secondCell;
        __block DynamicTextTableViewCell *thirdCell;
        
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
            [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypesArray flowType:TransferWorkFlowType];
            [subject view];
            [subject.tableView layoutIfNeeded];
            firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
            thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        });
        
        it(@"correct tag should be set up for the dynamic cells", ^{
            firstCell.tag should equal(3);
            secondCell.tag should equal(4);
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView:", ^{
            beforeEach(^{
                [firstCell.textView setText:@"testing..."];
                [subject dynamicTextTableViewCell:firstCell didUpdateTextView:firstCell.textView];
            });
            
            
            it(@"should update table content size", ^{
                delegate should have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
            });
            
            it(@"should be scrolling the scrollview", ^{
                delegate should have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
            });
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: validate OEF", ^{
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with integer", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypeArr flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
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
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypeArr flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
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
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypeArr flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
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
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypeArr flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(3001);
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
                    userPermissionsStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1pqrstubwxyz" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypeArr flowType:TransferWorkFlowType];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                    thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(transferPunchCardController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)100.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    firstCell.textView.tag should equal(3000);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:firstCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    firstCell.textView.tag should equal(3000);
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
                    delegate should have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,firstCell.textView);
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
                    delegate should have_received(@selector(transferPunchCardController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });
            });
        });
        
        context(@"dynamicTextTableViewCell:didEndEditingTextView:", ^{
            context(@"when value is nil", ^{
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
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypesArray flowType:TransferWorkFlowType];
                [subject view];
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                spy_on(cell.textView);
                [cell tap];
                
            });
            
            it(@"should set focus on the text view", ^{
                cell.textView should have_received(@selector(becomeFirstResponder));
            });
        });
        
        context(@"when tapping on dropdown oef", ^{
            __block NSMutableArray *oefTypes;
            __block OEFType *oefType;
            beforeEach(^{
                oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                oefTypes = [NSMutableArray arrayWithObjects:oefType, nil];

                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                [subject setUpWithDelegate:delegate punchCardObject:nil oefTypes:oefTypes flowType:TransferWorkFlowType];
                [subject view];
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                [cell tap];
            });
            
            it(@"should navigate when dropdown oef cell is clicked", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,Arguments::anything,subject);
            });
        });
        
        
    });

    describe(@"updatePunchCardObject:", ^{
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
        });
        context(@"when OEFs values are filled", ^{
            __block PunchCardObject *selectedPunchCard;
            __block PunchCardObject *expectedPunchCard;
            beforeEach(^{
                punchCardObject = [[PunchCardObject alloc]
                                   initWithClientType:nil
                                   projectType:nil
                                   oefTypesArray:oefTypesArray
                                   breakType:nil
                                   taskType:nil
                                   activity:nil
                                   uri:@"guid-A"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                
                TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                           taskPeriod:nil
                                                                 name:@"task-name"
                                                                  uri:@"task-uri"];
                
                selectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                   projectType:project
                                                                 oefTypesArray:nil
                                                                     breakType:nil
                                                                      taskType:task
                                                                      activity:nil
                                                                           uri:@"guid-A"];
                
                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                   projectType:project
                                                                 oefTypesArray:oefTypesArray
                                                                     breakType:nil
                                                                      taskType:task
                                                                      activity:nil
                                                                           uri:@"guid-A"];

                [subject setUpWithDelegate:delegate punchCardObject:punchCardObject oefTypes:oefTypesArray flowType:TransferWorkFlowType];
                [subject view];
                [subject updatePunchCardObject:selectedPunchCard];
            });
            
            it(@"retain OEFs values with select client/project/task from punachcardlist", ^{
                subject.punchCardObject should equal(expectedPunchCard);
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"client-name");
                
                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(@"project-name");
                
                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                
                DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];;
                fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                
                DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];;
                fifthCell.textView.text should equal(RPLocalizedString(@"23.5999", @""));
                
                DynamicTextTableViewCell *sixthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];;
                sixthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
            });
        });
        
        context(@"when OEFs values are not filled", ^{
            __block PunchCardObject *selectedPunchCard;
            __block OEFType *oefType;
            __block OEFType *oefTypeText;
            __block NSMutableArray *oefTypes;
            beforeEach(^{
                oefTypeText = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];
                oefTypes = [NSMutableArray arrayWithObjects:oefTypeText, oefType, nil];
                punchCardObject = [[PunchCardObject alloc]
                                   initWithClientType:nil
                                   projectType:nil
                                   oefTypesArray:oefTypes
                                   breakType:nil
                                   taskType:nil
                                   activity:nil
                                   uri:@"guid-A"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                
                TaskType *task = [[TaskType alloc] initWithProjectUri:nil
                                                           taskPeriod:nil
                                                                 name:@"task-name"
                                                                  uri:@"task-uri"];
                
                selectedPunchCard = [[PunchCardObject alloc]initWithClientType:client
                                                                   projectType:project
                                                                 oefTypesArray:oefTypes
                                                                     breakType:nil
                                                                      taskType:task
                                                                      activity:nil
                                                                           uri:@"guid-A"];
                
                [subject setUpWithDelegate:delegate punchCardObject:punchCardObject oefTypes:oefTypes flowType:TransferWorkFlowType];
                [subject view];
                [subject updatePunchCardObject:selectedPunchCard];
            });
            
            it(@"show selected client/project/task from punachcardlist with no OEFs values", ^{
                subject.punchCardObject should equal(selectedPunchCard);
            });
            
            it(@"should setup the cells correctly", ^{
                
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                firstCell.detailTextLabel.text should equal(@"client-name");
                
                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(@"project-name");
                
                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                
                DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];;
                fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                
                DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];;
                fifthCell.textValueLabel.text should equal(RPLocalizedString(@"Select", @""));
            });

        });
    });
});

SPEC_END
