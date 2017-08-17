#import <Cedar/Cedar.h>
#import "PunchAttributeController.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Punch.h"
#import "UserPermissionsStorage.h"
#import "Theme.h"
#import "PunchAttributeCell.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ReporteePermissionsStorage.h"
#import "UITableViewCell+Spec.h"
#import "SelectionController.h"
#import "PunchCardObject.h"
#import "ClientRepository.h"
#import "ProjectRepository.h"
#import "TaskRepository.h"
#import "ActivityRepository.h"
#import "AstroClientPermissionStorage.h"
#import "DefaultActivityStorage.h"
#import "LocalPunch.h"
#import "OEFType.h"
#import "RemotePunch.h"
#import "ManualPunch.h"
#import "OfflineLocalPunch.h"
#import "Enum.h"
#import "UIAlertView+Spec.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchAttributeControllerSpec)

describe(@"PunchAttributeController", ^{
    __block PunchAttributeController<CedarDouble> *subject;
    __block id <Theme> theme;
    __block UserPermissionsStorage *punchRulesStorage;
    __block id <Punch> punch;
    __block ClientType *client;
    __block ProjectType *project;
    __block TaskType *task;
    __block Activity *activity;
    __block id <PunchAttributeControllerDelegate> delegate;
    __block id <BSBinder,BSInjector> injector;
    __block ReporteePermissionsStorage *reporteePermissionsStorage;
    __block SelectionController *selectionController;
    __block AstroClientPermissionStorage *astroClientPermissionStorage;
    __block DefaultActivityStorage *defaultActivityStorage;
    __block NSMutableArray *oefTypesArray;
    __block OEFType *oefType1;
    __block OEFType *oefType2;
    __block OEFType *oefType3;
    
    beforeEach(^{

        injector = [InjectorProvider injector];
        delegate = nice_fake_for(@protocol(PunchAttributeControllerDelegate));
        reporteePermissionsStorage = nice_fake_for([ReporteePermissionsStorage class]);
        [injector bind:[ReporteePermissionsStorage class] toInstance:reporteePermissionsStorage];

        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];
        
        astroClientPermissionStorage = nice_fake_for([AstroClientPermissionStorage class]);
        [injector bind:[AstroClientPermissionStorage class] toInstance:astroClientPermissionStorage];

        defaultActivityStorage = nice_fake_for([DefaultActivityStorage class]);
        [injector bind:[DefaultActivityStorage class] toInstance:defaultActivityStorage];

        selectionController = [[SelectionController alloc]initWithProjectStorage:nil expenseProjectStorage:nil timerProvider:nil userDefaults:nil theme:nil];
        
        [injector bind:InjectorKeySelectionControllerForPunchModule toInstance:selectionController];


        subject = [injector getInstance:[PunchAttributeController class]];
        spy_on(subject);

        theme = subject.theme;
        spy_on(theme);
        spy_on(selectionController);

        punch = nice_fake_for(@protocol(Punch));

        punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

        client = nice_fake_for([ClientType class]);
        client stub_method(@selector(name)).and_return(@"client-name");
        client stub_method(@selector(uri)).and_return(@"client-uri");

        project = nice_fake_for([ProjectType class]);
        project stub_method(@selector(name)).and_return(@"project-name");
        project stub_method(@selector(uri)).and_return(@"project-uri");

        task = nice_fake_for([TaskType class]);
        task stub_method(@selector(name)).and_return(@"task-name");
        task stub_method(@selector(uri)).and_return(@"task-uri");

        activity = nice_fake_for([Activity class]);
        activity stub_method(@selector(name)).and_return(@"activity-name");
        activity stub_method(@selector(uri)).and_return(@"activity-uri");

        oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];

        oefTypesArray = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, nil];


        punch stub_method(@selector(client)).and_return(client);
        punch stub_method(@selector(project)).and_return(project);
        punch stub_method(@selector(task)).and_return(task);
        punch stub_method(@selector(activity)).and_return(activity);
        punch stub_method(@selector(address)).and_return(@"my-location");

        theme stub_method(@selector(attributeTitleLabelFont)).and_return([UIFont systemFontOfSize:10]);
        theme stub_method(@selector(attributeValueLabelFont)).and_return([UIFont systemFontOfSize:11]);
        theme stub_method(@selector(attributeTitleLabelColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(attributeValueLabelColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(attributeDisabledValueLabelColor)).and_return([UIColor greenColor]);
    });

    context(@"Presenting the correct data from punch in the tableview", ^{

        __block NSString *expectedClientTitle;
        __block NSString *expectedProjectTitle;
        __block NSString *expectedTaskTitle;
        __block NSString *expectedActivityTitle;
        __block NSString *expectedLocationTitle;

        beforeEach(^{
            expectedClientTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Client", nil)];
            expectedProjectTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Project", nil)];
            expectedTaskTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Task", nil)];
            expectedActivityTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Activity", nil)];
            expectedLocationTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Location", nil)];
            punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);

        });
        context(@"Styling the cells", ^{
            
            context(@"when canEditNonTimeFields permission is enabled", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);

                });
                context(@"When user has no client access"
                        @"When user has project access"
                        @"When punch address is available but no location info required on UI", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedProjectTitle);
                                cellA.value.text should equal(@"project-name");
                                cellA.title.font should equal([UIFont systemFontOfSize:10]);
                                cellA.value.font should equal([UIFont systemFontOfSize:11]);
                                cellA.title.textColor should equal([UIColor redColor]);
                                cellA.value.textColor should equal([UIColor yellowColor]);
                                cellA.userInteractionEnabled should be_truthy;
                            });
                        });
                
                context(@"When user has no client access"
                        @"When user has no project access"
                        @"When user has activity access"
                        @"When punch address is available but no location info required on UI", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedActivityTitle);
                                cellA.value.text should equal(@"activity-name");
                                cellA.title.font should equal([UIFont systemFontOfSize:10]);
                                cellA.value.font should equal([UIFont systemFontOfSize:11]);
                                cellA.title.textColor should equal([UIColor redColor]);
                                cellA.value.textColor should equal([UIColor yellowColor]);
                                
                                cellA.userInteractionEnabled should be_truthy;
                            });
                        });
                
                context(@"When user has no client access"
                        @"When user has no project access"
                        @"When user has activity access"
                        @"When punch address is available but no location info required on UI"
                        @"When oefTypes are available", ^{
                            
                            __block OEFType *oefType4;
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                                
                                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                                
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedActivityTitle);
                                cellA.value.text should equal(@"activity-name");
                                cellA.title.font should equal([UIFont systemFontOfSize:10]);
                                cellA.value.font should equal([UIFont systemFontOfSize:11]);
                                cellA.title.textColor should equal([UIColor redColor]);
                                cellA.value.textColor should equal([UIColor yellowColor]);
                                
                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(@"text 1");
                                cellB.textView.text should equal(@"sample text");
                                cellB.title.font should equal([UIFont systemFontOfSize:10]);
                                cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellB.title.textColor should equal([UIColor redColor]);
                                cellB.textView.textColor should equal([UIColor yellowColor]);
                                
                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(@"numeric 1");
                                cellC.textView.text should equal(@"230.89");
                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellC.title.textColor should equal([UIColor redColor]);
                                cellC.textView.textColor should equal([UIColor yellowColor]);
                                
                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellD.title.text should equal(@"dropdown oef 1");
                                cellD.textView.text should equal(@"some-dropdown-option-value");
                                
                                NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                cellE.title.text should equal(@"dropdown oef 2");
                                cellE.textView.text should equal(@"");
                                

                                
                                cellA.userInteractionEnabled should be_truthy;
                            });
                        });

                context(@"When user has no client access"
                        @"When user has no project access"
                        @"When user has no activity access"
                        @"When punch address is available but no location info required on UI"
                        @"When oefTypes are available", ^{

                            __block OEFType *oefType4;
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);

                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });

                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB.title.text should equal(@"text 1");
                                cellB.textView.text should equal(@"sample text");
                                cellB.title.font should equal([UIFont systemFontOfSize:10]);
                                cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellB.title.textColor should equal([UIColor redColor]);
                                cellB.textView.textColor should equal([UIColor yellowColor]);
                                cellB.userInteractionEnabled should be_truthy;

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC.title.text should equal(@"numeric 1");
                                cellC.textView.text should equal(@"230.89");
                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellC.title.textColor should equal([UIColor redColor]);
                                cellC.textView.textColor should equal([UIColor yellowColor]);
                                cellC.userInteractionEnabled should be_truthy;

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellD.title.text should equal(@"dropdown oef 1");
                                cellD.textView.text should equal(@"some-dropdown-option-value");
                                cellD.userInteractionEnabled should be_truthy;

                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellE.title.text should equal(@"dropdown oef 2");
                                cellE.textView.text should equal(@"");
                                cellE.userInteractionEnabled should be_truthy;


                            });
                        });

            });
            
            context(@"when canEditNonTimeFields permission is disabled", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                    
                });
                context(@"When user has no client access"
                        @"When user has project access"
                        @"When punch address is available but no location info required on UI", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedProjectTitle);
                                cellA.value.text should equal(@"project-name");
                                cellA.title.font should equal([UIFont systemFontOfSize:10]);
                                cellA.value.font should equal([UIFont systemFontOfSize:11]);
                                cellA.title.textColor should equal([UIColor redColor]);
                                cellA.value.textColor should equal([UIColor greenColor]);
                                cellA.userInteractionEnabled should be_falsy;

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedTaskTitle);
                                cellB.value.text should equal(@"task-name");
                                cellB.title.font should equal([UIFont systemFontOfSize:10]);
                                cellB.value.font should equal([UIFont systemFontOfSize:11]);
                                cellB.title.textColor should equal([UIColor redColor]);
                                cellB.value.textColor should equal([UIColor greenColor]);
                                cellB.userInteractionEnabled should be_falsy;
                            });
                        });
                
                context(@"When user has no client access"
                        @"When user has no project access"
                        @"When user has activity access"
                        @"When punch address is available but no location info required on UI", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedActivityTitle);
                                cellA.value.text should equal(@"activity-name");
                                cellA.title.font should equal([UIFont systemFontOfSize:10]);
                                cellA.value.font should equal([UIFont systemFontOfSize:11]);
                                cellA.title.textColor should equal([UIColor redColor]);
                                cellA.value.textColor should equal([UIColor greenColor]);
                                
                                cellA.userInteractionEnabled should be_falsy;

                                
                            });
                        });
                
                context(@"When user has no client access"
                        @"When user has no project access"
                        @"When user has activity access"
                        @"When punch address is available but no location info required on UI"
                        @"When oefTypes are available", ^{
                            __block OEFType *oefType4;
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                                
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedActivityTitle);
                                cellA.value.text should equal(@"activity-name");
                                cellA.title.font should equal([UIFont systemFontOfSize:10]);
                                cellA.value.font should equal([UIFont systemFontOfSize:11]);
                                cellA.title.textColor should equal([UIColor redColor]);
                                cellA.value.textColor should equal([UIColor greenColor]);
                                
                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(@"text 1");
                                cellB.textView.text should equal(@"sample text");
                                cellB.title.font should equal([UIFont systemFontOfSize:10]);
                                cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellB.title.textColor should equal([UIColor redColor]);
                                cellB.textView.textColor should equal([UIColor greenColor]);
                                
                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(@"numeric 1");
                                cellC.textView.text should equal(@"230.89");
                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellC.title.textColor should equal([UIColor redColor]);
                                cellC.textView.textColor should equal([UIColor greenColor]);
                                
                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellD.title.text should equal(@"dropdown oef 1");
                                cellD.textView.text should equal(@"some-dropdown-option-value");
                                cellD.textValueLabel.textColor should equal([UIColor greenColor]);
                                
                                NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                cellE.title.text should equal(@"dropdown oef 2");
                                cellE.textView.text should equal(@"");
                                cellE.textValueLabel.textColor should equal([UIColor greenColor]);
                                

                                
                                cellA.userInteractionEnabled should be_falsy;
                            });
                        });

                context(@"When user has no client access"
                        @"When user has no project access"
                        @"When user has no activity access"
                        @"When punch address is available but no location info required on UI"
                        @"When oefTypes are available", ^{
                            __block OEFType *oefType4;
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);

                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });

                            it(@"should have correctly styled cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB.title.text should equal(@"text 1");
                                cellB.textView.text should equal(@"sample text");
                                cellB.title.font should equal([UIFont systemFontOfSize:10]);
                                cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellB.title.textColor should equal([UIColor redColor]);
                                cellB.textView.textColor should equal([UIColor greenColor]);
                                cellB.userInteractionEnabled should be_falsy;

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC.title.text should equal(@"numeric 1");
                                cellC.textView.text should equal(@"230.89");
                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellC.title.textColor should equal([UIColor redColor]);
                                cellC.textView.textColor should equal([UIColor greenColor]);
                                cellC.userInteractionEnabled should be_falsy;

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellD.title.text should equal(@"dropdown oef 1");
                                cellD.textView.text should equal(@"some-dropdown-option-value");
                                cellD.userInteractionEnabled should be_falsy;
                                cellD.textValueLabel.textColor should equal([UIColor greenColor]);

                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellE.title.text should equal(@"dropdown oef 2");
                                cellE.textView.text should equal(@"");
                                cellE.userInteractionEnabled should be_falsy;
                                cellE.textValueLabel.textColor should equal([UIColor greenColor]);


                            });
                        });

                
            });

            context(@"When user has no client access"
                    @"When user has no project access"
                    @"When user has activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly styled cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            

                        });
                    });
            
            
            context(@"When user has client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock In", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                           
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchIn);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellF = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellF.title.text should equal(expectedProjectTitle);
                            cellF.value.text should equal(@"project-name");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellG.title.text should equal(expectedTaskTitle);
                            cellG.value.text should equal(@"task-name");
                           
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            
                            
                        });
                    });
            
            
            context(@"When user has client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellF = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellF.title.text should equal(expectedProjectTitle);
                            cellF.value.text should equal(@"project-name");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellG.title.text should equal(expectedTaskTitle);
                            cellG.value.text should equal(@"task-name");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            
                            
                        });
                    });
            
            context(@"When user has client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            
                            
                        });
                    });
            
            context(@"When user has client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Break", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                            
                            punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-type" uri:@"break-uri"]);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            
                            
                        });
                    });
            
            
            context(@"When user has no client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock In", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchIn);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellF = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellF.title.text should equal(expectedProjectTitle);
                            cellF.value.text should equal(@"project-name");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellG.title.text should equal(expectedTaskTitle);
                            cellG.value.text should equal(@"task-name");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            
                        });
                    });
            
            
            context(@"When user has no client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellF = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellF.title.text should equal(expectedProjectTitle);
                            cellF.value.text should equal(@"project-name");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellG.title.text should equal(expectedTaskTitle);
                            cellG.value.text should equal(@"task-name");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                            
                        });
                    });
            
            
            context(@"When user has no client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                        });
                    });
            
            
            context(@"When user has no client access"
                    @"When user has project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Break", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{
                            
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                            
                            punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-type" uri:@"break-uri"]);
                            
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correctly styled cells in the tableview", ^{
                            
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                        });
                    });

            context(@"When user has no client access"
                    @"When user has no project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock In", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{

                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchIn);

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];

                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly styled cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);

                        });
                    });


            context(@"When user has no client access"
                    @"When user has no project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{

                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];

                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly styled cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);

                        });
                    });


            context(@"When user has no client access"
                    @"When user has no project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{

                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];

                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly styled cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                        });
                    });


            context(@"When user has no client access"
                    @"When user has no project access"
                    @"When user has no activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Break", ^{
                        __block OEFType *oefType4;
                        beforeEach(^{

                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);

                            punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-type" uri:@"break-uri"]);

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];

                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly styled cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");
                            cellB.title.font should equal([UIFont systemFontOfSize:10]);
                            cellB.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellB.title.textColor should equal([UIColor redColor]);
                            cellB.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellC.title.textColor should equal([UIColor redColor]);
                            cellC.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellD.title.textColor should equal([UIColor redColor]);
                            cellD.textView.textColor should equal([UIColor yellowColor]);

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"dropdown oef 2");
                            cellE.textValueLabel.text should equal(@"None");
                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                            cellE.title.textColor should equal([UIColor redColor]);
                            cellE.textView.textColor should equal([UIColor yellowColor]);
                        });
                    });

        });

        context(@"When flow is <UserFlowContext>", ^{
            
            context(@"When OEF types available"
                    @"When Action is Clock In", ^{
                        
                        beforeEach(^{
                            __block OEFType *oefType4;
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchIn);
                        });
               
                        context(@"When user has no client access"
                                @"When user has project access"
                                @"When punch address is available but no location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedProjectTitle);
                                        cellA.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedTaskTitle);
                                        cellB.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        cellB.userInteractionEnabled should be_truthy;
                                    });
                                    
                                    it(@"should ", ^{
                                        punch stub_method(@selector(project)).and_return(nil).again();
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedTaskTitle);
                                        cellB.value.text should equal(@"task-name");
                                        
                                        cellB.userInteractionEnabled should be_falsy;
                                        
                                        
                                    });
                                    
                                    afterEach(^{
                                        punch stub_method(@selector(project)).and_return(project).again();
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access", ^{
                                    
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                                    });
                                    
                                    context(@"When punch address is available but no location info required on UI", ^{
                                        beforeEach(^{

                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellC.title.text should equal(@"numeric 1");
                                            cellC.textView.text should equal(@"230.89");
                                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellC.title.textColor should equal([UIColor redColor]);
                                            cellC.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                        
                                    });
                                    
                                    context(@"When punch address is available and location info required on UI", ^{
                                        beforeEach(^{
                                             punch stub_method(@selector(address)).again().and_return(@"my-location");
                                            [subject setUpWithNeedLocationOnUI:YES
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                                        });
                                        
                                        it(@"should have correctly configured cells in the tableview", ^{

                                            
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellC.title.text should equal(@"numeric 1");
                                            cellC.textView.text should equal(@"230.89");
                                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellC.title.textColor should equal([UIColor redColor]);
                                            cellC.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellA.title.text should equal(expectedLocationTitle);
                                            cellA.value.text should equal(@"my-location");

                                        });
                                    });
                                    
                                    context(@"When punch address is not available and location info required on UI", ^{
                                                beforeEach(^{
                                                    punch stub_method(@selector(address)).again().and_return(nil);
                                                    [subject setUpWithNeedLocationOnUI:YES
                                                                              delegate:delegate
                                                                              flowType:UserFlowContext
                                                                               userUri:nil
                                                                                 punch:punch
                                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                    [subject view];
                                                });
                                                
                                                it(@"should have correct number of rows in the tableview", ^{
                                                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                                                });
                                                
                                                it(@"should have correctly configured cells in the tableview", ^{
                                                    
                                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                    cellF.title.text should equal(@"text 1");
                                                    cellF.textView.text should equal(@"sample text");
                                                    cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                    cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                    cellF.title.textColor should equal([UIColor redColor]);
                                                    cellF.textView.textColor should equal([UIColor yellowColor]);
                                                    
                                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                    DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                    cellC.title.text should equal(@"numeric 1");
                                                    cellC.textView.text should equal(@"230.89");
                                                    cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                                    cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                                    cellC.title.textColor should equal([UIColor redColor]);
                                                    cellC.textView.textColor should equal([UIColor yellowColor]);
                                                    
                                                    NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                    cellD.title.text should equal(@"dropdown oef 1");
                                                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                    cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                    cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                    cellD.title.textColor should equal([UIColor redColor]);
                                                    cellD.textView.textColor should equal([UIColor yellowColor]);
                                                    
                                                    NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                    cellE.title.text should equal(@"dropdown oef 2");
                                                    cellE.textValueLabel.text should equal(@"None");
                                                    cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                    cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                    cellE.title.textColor should equal([UIColor redColor]);
                                                    cellE.textView.textColor should equal([UIColor yellowColor]);
                                                    
                                                    NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                                    cellA.title.text should equal(expectedLocationTitle);
                                                    cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                                    
                                                });
                                            });
                                
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access", ^{
                                    
                                    context(@"When punch address is not available", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                            punch stub_method(@selector(address)).again().and_return(nil);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(@"client-name");
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(@"project-name");
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(@"task-name");
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            
                                        });

                                    });
                                    
                                    context(@"When punch address is available but no location info required on UI", ^{
                                        
                                        context(@"When client name is not present", ^{
                                            beforeEach(^{
                                                client stub_method(@selector(name)).again().and_return(nil);
                                                punch stub_method(@selector(client)).again().and_return(client);
                                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                                [subject setUpWithNeedLocationOnUI:NO
                                                                          delegate:delegate
                                                                          flowType:UserFlowContext
                                                                           userUri:nil
                                                                             punch:punch
                                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                [subject view];
                                            });
                                            it(@"should have correct number of rows in the tableview", ^{
                                                [subject.tableView numberOfRowsInSection:0] should equal(7);
                                            });
                                            it(@"should have correctly configured cells in the tableview", ^{
                                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                cellA.title.text should equal(expectedClientTitle);
                                                cellA.value.text should equal(RPLocalizedString(@"None", nil));
                                                
                                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                cellB.title.text should equal(expectedProjectTitle);
                                                cellB.value.text should equal(@"project-name");
                                                
                                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                cellC.title.text should equal(expectedTaskTitle);
                                                cellC.value.text should equal(@"task-name");
                                                
                                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                cellF.title.text should equal(@"text 1");
                                                cellF.textView.text should equal(@"sample text");
                                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellF.title.textColor should equal([UIColor redColor]);
                                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                                DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                                cellG.title.text should equal(@"numeric 1");
                                                cellG.textView.text should equal(@"230.89");
                                                cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellG.title.textColor should equal([UIColor redColor]);
                                                cellG.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                                cellD.title.text should equal(@"dropdown oef 1");
                                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellD.title.textColor should equal([UIColor redColor]);
                                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                                cellE.title.text should equal(@"dropdown oef 2");
                                                cellE.textValueLabel.text should equal(@"None");
                                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellE.title.textColor should equal([UIColor redColor]);
                                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                                
                                            });
                                        });
                                        
                                        context(@"When project name is not present", ^{
                                            beforeEach(^{
                                                project stub_method(@selector(name)).again().and_return(nil);
                                                punch stub_method(@selector(project)).again().and_return(project);
                                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                                [subject setUpWithNeedLocationOnUI:NO
                                                                          delegate:delegate
                                                                          flowType:UserFlowContext
                                                                           userUri:nil
                                                                             punch:punch
                                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                [subject view];
                                            });
                                            it(@"should have correct number of rows in the tableview", ^{
                                                [subject.tableView numberOfRowsInSection:0] should equal(7);
                                            });
                                            it(@"should have correctly configured cells in the tableview", ^{
                                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                cellA.title.text should equal(expectedClientTitle);
                                                cellA.value.text should equal(@"client-name");
                                                
                                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                cellB.title.text should equal(expectedProjectTitle);
                                                cellB.value.text should equal(RPLocalizedString(@"None", nil));
                                                
                                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                cellC.title.text should equal(expectedTaskTitle);
                                                cellC.value.text should equal(@"task-name");
                                                
                                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                cellF.title.text should equal(@"text 1");
                                                cellF.textView.text should equal(@"sample text");
                                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellF.title.textColor should equal([UIColor redColor]);
                                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                                DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                                cellG.title.text should equal(@"numeric 1");
                                                cellG.textView.text should equal(@"230.89");
                                                cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellG.title.textColor should equal([UIColor redColor]);
                                                cellG.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                                cellD.title.text should equal(@"dropdown oef 1");
                                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellD.title.textColor should equal([UIColor redColor]);
                                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                                cellE.title.text should equal(@"dropdown oef 2");
                                                cellE.textValueLabel.text should equal(@"None");
                                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellE.title.textColor should equal([UIColor redColor]);
                                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                                
                                            });
                                        });
                                        
                                        context(@"When task name is not present", ^{
                                            beforeEach(^{
                                                task stub_method(@selector(name)).again().and_return(nil);
                                                punch stub_method(@selector(task)).again().and_return(task);
                                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                                [subject setUpWithNeedLocationOnUI:NO
                                                                          delegate:delegate
                                                                          flowType:UserFlowContext
                                                                           userUri:nil
                                                                             punch:punch
                                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                [subject view];
                                            });
                                            it(@"should have correct number of rows in the tableview", ^{
                                                [subject.tableView numberOfRowsInSection:0] should equal(7);
                                            });
                                            it(@"should have correctly configured cells in the tableview", ^{
                                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                cellA.title.text should equal(expectedClientTitle);
                                                cellA.value.text should equal(@"client-name");
                                                
                                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                cellB.title.text should equal(expectedProjectTitle);
                                                cellB.value.text should equal(@"project-name");
                                                
                                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                cellC.title.text should equal(expectedTaskTitle);
                                                cellC.value.text should equal(RPLocalizedString(@"None", nil));
                                                
                                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                cellF.title.text should equal(@"text 1");
                                                cellF.textView.text should equal(@"sample text");
                                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellF.title.textColor should equal([UIColor redColor]);
                                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                                DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                                cellG.title.text should equal(@"numeric 1");
                                                cellG.textView.text should equal(@"230.89");
                                                cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellG.title.textColor should equal([UIColor redColor]);
                                                cellG.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                                cellD.title.text should equal(@"dropdown oef 1");
                                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellD.title.textColor should equal([UIColor redColor]);
                                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                                cellE.title.text should equal(@"dropdown oef 2");
                                                cellE.textValueLabel.text should equal(@"None");
                                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellE.title.textColor should equal([UIColor redColor]);
                                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                                
                                            });
                                        });
                                        
                                    });
                                    
                                });
                        
                
            });
            
            context(@"When OEF types available"
                    @"When Action is Transfer", ^{
                        
                    beforeEach(^{
                        __block OEFType *oefType4;
                        oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                        NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                        punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                        punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                    });
                    
                    context(@"When user has no client access"
                            @"When user has project access"
                            @"When punch address is available but no location info required on UI", ^{
                                beforeEach(^{
                                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                    [subject setUpWithNeedLocationOnUI:NO
                                                              delegate:delegate
                                                              flowType:UserFlowContext
                                                               userUri:nil
                                                                 punch:punch
                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                    [subject view];
                                });
                                
                                it(@"should have correct number of rows in the tableview", ^{
                                    [subject.tableView numberOfRowsInSection:0] should equal(6);
                                });
                                
                                it(@"should have correctly configured cells in the tableview", ^{
                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                    cellA.title.text should equal(expectedProjectTitle);
                                    cellA.value.text should equal(@"project-name");
                                    
                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                    cellB.title.text should equal(expectedTaskTitle);
                                    cellB.value.text should equal(@"task-name");
                                    
                                    NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                    cellF.title.text should equal(@"text 1");
                                    cellF.textView.text should equal(@"sample text");
                                    cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellF.title.textColor should equal([UIColor redColor]);
                                    cellF.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                    DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                    cellC.title.text should equal(@"numeric 1");
                                    cellC.textView.text should equal(@"230.89");
                                    cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellC.title.textColor should equal([UIColor redColor]);
                                    cellC.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                    cellD.title.text should equal(@"dropdown oef 1");
                                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                    cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellD.title.textColor should equal([UIColor redColor]);
                                    cellD.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                    cellE.title.text should equal(@"dropdown oef 2");
                                    cellE.textValueLabel.text should equal(@"None");
                                    cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellE.title.textColor should equal([UIColor redColor]);
                                    cellE.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    cellB.userInteractionEnabled should be_truthy;
                                });
                                
                                it(@"should ", ^{
                                    punch stub_method(@selector(project)).and_return(nil).again();
                                    
                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                    cellB.title.text should equal(expectedTaskTitle);
                                    cellB.value.text should equal(@"task-name");
                                    
                                    cellB.userInteractionEnabled should be_falsy;
                                    
                                    
                                });
                                
                                afterEach(^{
                                    punch stub_method(@selector(project)).and_return(project).again();
                                });
                                
                            });
                    
                    context(@"When user has client access"
                            @"When user has no project access", ^{
                                
                                beforeEach(^{
                                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                                });
                                
                                context(@"When punch address is available but no location info required on UI", ^{
                                    beforeEach(^{
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                });
                                
                                context(@"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(@"my-location");
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(@"my-location");
                                        
                                    });
                                });
                                
                                context(@"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                        
                                    });
                                });
                                
                            });
                    
                    context(@"When user has client access"
                            @"When user has project access", ^{
                                
                            context(@"When punch address is not available", ^{
                                beforeEach(^{
                                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                    punch stub_method(@selector(address)).again().and_return(nil);
                                    [subject setUpWithNeedLocationOnUI:NO
                                                              delegate:delegate
                                                              flowType:UserFlowContext
                                                               userUri:nil
                                                                 punch:punch
                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                    [subject view];
                                });
                                
                                it(@"should have correct number of rows in the tableview", ^{
                                    [subject.tableView numberOfRowsInSection:0] should equal(7);
                                });
                                
                                it(@"should have correctly configured cells in the tableview", ^{
                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                    cellA.title.text should equal(expectedClientTitle);
                                    cellA.value.text should equal(@"client-name");
                                    
                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                    cellB.title.text should equal(expectedProjectTitle);
                                    cellB.value.text should equal(@"project-name");
                                    
                                    NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                    cellC.title.text should equal(expectedTaskTitle);
                                    cellC.value.text should equal(@"task-name");
                                    
                                    NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                    cellF.title.text should equal(@"text 1");
                                    cellF.textView.text should equal(@"sample text");
                                    cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellF.title.textColor should equal([UIColor redColor]);
                                    cellF.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                    DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                    cellG.title.text should equal(@"numeric 1");
                                    cellG.textView.text should equal(@"230.89");
                                    cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellG.title.textColor should equal([UIColor redColor]);
                                    cellG.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                    cellD.title.text should equal(@"dropdown oef 1");
                                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                    cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellD.title.textColor should equal([UIColor redColor]);
                                    cellD.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                    cellE.title.text should equal(@"dropdown oef 2");
                                    cellE.textValueLabel.text should equal(@"None");
                                    cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellE.title.textColor should equal([UIColor redColor]);
                                    cellE.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    
                                });
                                
                            });
                            
                            context(@"When punch address is available but no location info required on UI", ^{
                                
                                context(@"When client name is not present", ^{
                                    beforeEach(^{
                                        client stub_method(@selector(name)).again().and_return(nil);
                                        punch stub_method(@selector(client)).again().and_return(client);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(7);
                                    });
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(RPLocalizedString(@"None", nil));
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                                
                                context(@"When project name is not present", ^{
                                    beforeEach(^{
                                        project stub_method(@selector(name)).again().and_return(nil);
                                        punch stub_method(@selector(project)).again().and_return(project);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(7);
                                    });
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(RPLocalizedString(@"None", nil));
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                                
                                context(@"When task name is not present", ^{
                                    beforeEach(^{
                                        task stub_method(@selector(name)).again().and_return(nil);
                                        punch stub_method(@selector(task)).again().and_return(task);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(7);
                                    });
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(RPLocalizedString(@"None", nil));
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                                
                            });
                                
                    });
        });
            
            context(@"When OEF types available"
                    @"When Action is Clock Out", ^{
                        
                        beforeEach(^{
                            __block OEFType *oefType4;
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                        });
                        
                        context(@"When user has no client access"
                                @"When user has project access"
                                @"When punch address is available but no location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                         NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access", ^{
                                    
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                                    });
                                    
                                    context(@"When punch address is available but no location info required on UI", ^{
                                        beforeEach(^{
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        
                                    });
                                    
                                    context(@"When punch address is available and location info required on UI", ^{
                                        beforeEach(^{
                                            punch stub_method(@selector(address)).again().and_return(@"my-location");
                                            [subject setUpWithNeedLocationOnUI:YES
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                                        });
                                        
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            
                                            
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellC.title.text should equal(@"numeric 1");
                                            cellC.textView.text should equal(@"230.89");
                                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellC.title.textColor should equal([UIColor redColor]);
                                            cellC.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellA.title.text should equal(expectedLocationTitle);
                                            cellA.value.text should equal(@"my-location");
                                            
                                        });
                                    });
                                    
                                    context(@"When punch address is not available and location info required on UI", ^{
                                        beforeEach(^{
                                            punch stub_method(@selector(address)).again().and_return(nil);
                                            [subject setUpWithNeedLocationOnUI:YES
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                                        });
                                        
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellC.title.text should equal(@"numeric 1");
                                            cellC.textView.text should equal(@"230.89");
                                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellC.title.textColor should equal([UIColor redColor]);
                                            cellC.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellA.title.text should equal(expectedLocationTitle);
                                            cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                            
                                        });
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access", ^{
                                    
                                    context(@"When punch address is not available", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                            punch stub_method(@selector(address)).again().and_return(nil);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:UserFlowContext
                                                                       userUri:nil
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellC.title.text should equal(@"numeric 1");
                                            cellC.textView.text should equal(@"230.89");
                                            cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellC.title.textColor should equal([UIColor redColor]);
                                            cellC.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            
                                        });
                                        
                                    });
                                    
                                    context(@"When punch address is available but no location info required on UI", ^{
                                        
                                        context(@"When client name is not present", ^{
                                            beforeEach(^{
                                                client stub_method(@selector(name)).again().and_return(nil);
                                                punch stub_method(@selector(client)).again().and_return(client);
                                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                                [subject setUpWithNeedLocationOnUI:NO
                                                                          delegate:delegate
                                                                          flowType:UserFlowContext
                                                                           userUri:nil
                                                                             punch:punch
                                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                [subject view];
                                            });
                                            it(@"should have correct number of rows in the tableview", ^{
                                                [subject.tableView numberOfRowsInSection:0] should equal(4);
                                            });
                                            it(@"should have correctly configured cells in the tableview", ^{
                                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                cellF.title.text should equal(@"text 1");
                                                cellF.textView.text should equal(@"sample text");
                                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellF.title.textColor should equal([UIColor redColor]);
                                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                cellC.title.text should equal(@"numeric 1");
                                                cellC.textView.text should equal(@"230.89");
                                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellC.title.textColor should equal([UIColor redColor]);
                                                cellC.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                cellD.title.text should equal(@"dropdown oef 1");
                                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellD.title.textColor should equal([UIColor redColor]);
                                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                cellE.title.text should equal(@"dropdown oef 2");
                                                cellE.textValueLabel.text should equal(@"None");
                                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellE.title.textColor should equal([UIColor redColor]);
                                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                                
                                            });
                                        });
                                        
                                        context(@"When project name is not present", ^{
                                            beforeEach(^{
                                                project stub_method(@selector(name)).again().and_return(nil);
                                                punch stub_method(@selector(project)).again().and_return(project);
                                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                                [subject setUpWithNeedLocationOnUI:NO
                                                                          delegate:delegate
                                                                          flowType:UserFlowContext
                                                                           userUri:nil
                                                                             punch:punch
                                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                [subject view];
                                            });
                                            it(@"should have correct number of rows in the tableview", ^{
                                                [subject.tableView numberOfRowsInSection:0] should equal(4);
                                            });
                                            it(@"should have correctly configured cells in the tableview", ^{
                                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                cellF.title.text should equal(@"text 1");
                                                cellF.textView.text should equal(@"sample text");
                                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellF.title.textColor should equal([UIColor redColor]);
                                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                cellC.title.text should equal(@"numeric 1");
                                                cellC.textView.text should equal(@"230.89");
                                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellC.title.textColor should equal([UIColor redColor]);
                                                cellC.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                cellD.title.text should equal(@"dropdown oef 1");
                                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellD.title.textColor should equal([UIColor redColor]);
                                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                cellE.title.text should equal(@"dropdown oef 2");
                                                cellE.textValueLabel.text should equal(@"None");
                                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellE.title.textColor should equal([UIColor redColor]);
                                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                                
                                            });
                                        });
                                        
                                        context(@"When task name is not present", ^{
                                            beforeEach(^{
                                                task stub_method(@selector(name)).again().and_return(nil);
                                                punch stub_method(@selector(task)).again().and_return(task);
                                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                                [subject setUpWithNeedLocationOnUI:NO
                                                                          delegate:delegate
                                                                          flowType:UserFlowContext
                                                                           userUri:nil
                                                                             punch:punch
                                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                                [subject view];
                                            });
                                            it(@"should have correct number of rows in the tableview", ^{
                                                [subject.tableView numberOfRowsInSection:0] should equal(4);
                                            });
                                            it(@"should have correctly configured cells in the tableview", ^{
                                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                                cellF.title.text should equal(@"text 1");
                                                cellF.textView.text should equal(@"sample text");
                                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellF.title.textColor should equal([UIColor redColor]);
                                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                                cellC.title.text should equal(@"numeric 1");
                                                cellC.textView.text should equal(@"230.89");
                                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellC.title.textColor should equal([UIColor redColor]);
                                                cellC.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                                cellD.title.text should equal(@"dropdown oef 1");
                                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellD.title.textColor should equal([UIColor redColor]);
                                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                                
                                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                                cellE.title.text should equal(@"dropdown oef 2");
                                                cellE.textValueLabel.text should equal(@"None");
                                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                                cellE.title.textColor should equal([UIColor redColor]);
                                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                                
                                            });
                                        });
                                        
                                    });
                                    
                        });
            });
            
            context(@"When OEF types available"
                    @"When Action is Break", ^{
                        
                beforeEach(^{
                    __block OEFType *oefType4;
                    oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                    NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                    punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                    punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-action" uri:@"break-uri"]);
                });
                
                context(@"When user has no client access"
                        @"When user has project access"
                        @"When punch address is available but no location info required on UI", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(4);
                            });
                            
                            it(@"should have correctly configured cells in the tableview", ^{
                                
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellF.title.text should equal(@"text 1");
                                cellF.textView.text should equal(@"sample text");
                                cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellF.title.textColor should equal([UIColor redColor]);
                                cellF.textView.textColor should equal([UIColor yellowColor]);
                                
                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC.title.text should equal(@"numeric 1");
                                cellC.textView.text should equal(@"230.89");
                                cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellC.title.textColor should equal([UIColor redColor]);
                                cellC.textView.textColor should equal([UIColor yellowColor]);
                                
                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellD.title.text should equal(@"dropdown oef 1");
                                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellD.title.textColor should equal([UIColor redColor]);
                                cellD.textView.textColor should equal([UIColor yellowColor]);
                                
                                NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellE.title.text should equal(@"dropdown oef 2");
                                cellE.textValueLabel.text should equal(@"None");
                                cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                cellE.title.textColor should equal([UIColor redColor]);
                                cellE.textView.textColor should equal([UIColor yellowColor]);
                                
                            });
                            
                        });
                
                context(@"When user has client access"
                        @"When user has no project access", ^{
                            
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);

                            });
                            
                            context(@"When punch address is available but no location info required on UI", ^{
                                beforeEach(^{
                                    [subject setUpWithNeedLocationOnUI:NO
                                                              delegate:delegate
                                                              flowType:UserFlowContext
                                                               userUri:nil
                                                                 punch:punch
                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                    [subject view];
                                });
                                
                                it(@"should have correct number of rows in the tableview", ^{
                                    [subject.tableView numberOfRowsInSection:0] should equal(4);
                                });
                                
                            });
                            
                            context(@"When punch address is available and location info required on UI", ^{
                                beforeEach(^{
                                    punch stub_method(@selector(address)).again().and_return(@"my-location");
                                    [subject setUpWithNeedLocationOnUI:YES
                                                              delegate:delegate
                                                              flowType:UserFlowContext
                                                               userUri:nil
                                                                 punch:punch
                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                    [subject view];
                                });
                                
                                it(@"should have correct number of rows in the tableview", ^{
                                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                                });
                                
                                it(@"should have correctly configured cells in the tableview", ^{
                                    
                                    
                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                    cellF.title.text should equal(@"text 1");
                                    cellF.textView.text should equal(@"sample text");
                                    cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellF.title.textColor should equal([UIColor redColor]);
                                    cellF.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                    DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                    cellC.title.text should equal(@"numeric 1");
                                    cellC.textView.text should equal(@"230.89");
                                    cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellC.title.textColor should equal([UIColor redColor]);
                                    cellC.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                    cellD.title.text should equal(@"dropdown oef 1");
                                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                    cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellD.title.textColor should equal([UIColor redColor]);
                                    cellD.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                    cellE.title.text should equal(@"dropdown oef 2");
                                    cellE.textValueLabel.text should equal(@"None");
                                    cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellE.title.textColor should equal([UIColor redColor]);
                                    cellE.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                    cellA.title.text should equal(expectedLocationTitle);
                                    cellA.value.text should equal(@"my-location");
                                    
                                });
                            });
                            
                            context(@"When punch address is not available and location info required on UI", ^{
                                beforeEach(^{
                                    punch stub_method(@selector(address)).again().and_return(nil);
                                    [subject setUpWithNeedLocationOnUI:YES
                                                              delegate:delegate
                                                              flowType:UserFlowContext
                                                               userUri:nil
                                                                 punch:punch
                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                    [subject view];
                                });
                                
                                it(@"should have correct number of rows in the tableview", ^{
                                    [subject.tableView numberOfRowsInSection:0] should equal(5);
                                });
                                
                                it(@"should have correctly configured cells in the tableview", ^{
                                    
                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                    cellF.title.text should equal(@"text 1");
                                    cellF.textView.text should equal(@"sample text");
                                    cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellF.title.textColor should equal([UIColor redColor]);
                                    cellF.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                    DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                    cellC.title.text should equal(@"numeric 1");
                                    cellC.textView.text should equal(@"230.89");
                                    cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellC.title.textColor should equal([UIColor redColor]);
                                    cellC.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                    cellD.title.text should equal(@"dropdown oef 1");
                                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                    cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellD.title.textColor should equal([UIColor redColor]);
                                    cellD.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                    cellE.title.text should equal(@"dropdown oef 2");
                                    cellE.textValueLabel.text should equal(@"None");
                                    cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellE.title.textColor should equal([UIColor redColor]);
                                    cellE.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                    cellA.title.text should equal(expectedLocationTitle);
                                    cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                    
                                });
                            });
                            
                        });
                
                context(@"When user has client access"
                        @"When user has project access", ^{
                            
                            context(@"When punch address is not available", ^{
                                beforeEach(^{
                                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                    punch stub_method(@selector(address)).again().and_return(nil);
                                    [subject setUpWithNeedLocationOnUI:NO
                                                              delegate:delegate
                                                              flowType:UserFlowContext
                                                               userUri:nil
                                                                 punch:punch
                                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                    [subject view];
                                });
                                
                                it(@"should have correct number of rows in the tableview", ^{
                                    [subject.tableView numberOfRowsInSection:0] should equal(4);
                                });
                                
                                it(@"should have correctly configured cells in the tableview", ^{
                                    
                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                    cellF.title.text should equal(@"text 1");
                                    cellF.textView.text should equal(@"sample text");
                                    cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellF.title.textColor should equal([UIColor redColor]);
                                    cellF.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                    DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                    cellC.title.text should equal(@"numeric 1");
                                    cellC.textView.text should equal(@"230.89");
                                    cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellC.title.textColor should equal([UIColor redColor]);
                                    cellC.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                    cellD.title.text should equal(@"dropdown oef 1");
                                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                    cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellD.title.textColor should equal([UIColor redColor]);
                                    cellD.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                    cellE.title.text should equal(@"dropdown oef 2");
                                    cellE.textValueLabel.text should equal(@"None");
                                    cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                    cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                    cellE.title.textColor should equal([UIColor redColor]);
                                    cellE.textView.textColor should equal([UIColor yellowColor]);
                                    
                                    
                                });
                                
                            });
                            
                            context(@"When punch address is available but no location info required on UI", ^{
                                
                                context(@"When client name is not present", ^{
                                    beforeEach(^{
                                        client stub_method(@selector(name)).again().and_return(nil);
                                        punch stub_method(@selector(client)).again().and_return(client);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                                
                                context(@"When project name is not present", ^{
                                    beforeEach(^{
                                        project stub_method(@selector(name)).again().and_return(nil);
                                        punch stub_method(@selector(project)).again().and_return(project);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                                
                                context(@"When task name is not present", ^{
                                    beforeEach(^{
                                        task stub_method(@selector(name)).again().and_return(nil);
                                        punch stub_method(@selector(task)).again().and_return(task);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:UserFlowContext
                                                                   userUri:nil
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                                
                            });
                            
                        });
            });

            context(@"When user has no client access"
                    @"When user has project access"
                    @"When punch address is available but no location info required on UI", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedProjectTitle);
                            cellA.value.text should equal(@"project-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedTaskTitle);
                            cellB.value.text should equal(@"task-name");

                            cellB.userInteractionEnabled should be_truthy;
                        });
                        
                        it(@"should ", ^{
                            punch stub_method(@selector(project)).and_return(nil).again();
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedTaskTitle);
                            cellB.value.text should equal(@"task-name");
                            
                            cellB.userInteractionEnabled should be_falsy;
                        });
                        
                        afterEach(^{
                            punch stub_method(@selector(project)).and_return(project).again();
                        });

                    });
            

            context(@"When user has client access"
                    @"When user has no project access"
                    @"When punch address is available but no location info required on UI", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(0);
                        });

                        
                    });

            context(@"When user has client access"
                    @"When user has project access"
                    @"When punch address is not available", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedProjectTitle);
                            cellB.value.text should equal(@"project-name");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(expectedTaskTitle);
                            cellC.value.text should equal(@"task-name");

                        });
                    });

            context(@"When user has client access"
                    @"When user has project access"
                    @"When punch address is available but no location info required on UI", ^{

                        context(@"When client name is not present", ^{
                            beforeEach(^{
                                client stub_method(@selector(name)).again().and_return(nil);
                                punch stub_method(@selector(client)).again().and_return(client);
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(3);
                            });
                            it(@"should have correctly configured cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedClientTitle);
                                cellA.value.text should equal(RPLocalizedString(@"None", nil));

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedProjectTitle);
                                cellB.value.text should equal(@"project-name");

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(expectedTaskTitle);
                                cellC.value.text should equal(@"task-name");

                            });
                        });

                        context(@"When project name is not present", ^{
                            beforeEach(^{
                                project stub_method(@selector(name)).again().and_return(nil);
                                punch stub_method(@selector(project)).again().and_return(project);
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(3);
                            });
                            it(@"should have correctly configured cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedClientTitle);
                                cellA.value.text should equal(@"client-name");

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedProjectTitle);
                                cellB.value.text should equal(RPLocalizedString(@"None", nil));

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(expectedTaskTitle);
                                cellC.value.text should equal(@"task-name");

                            });
                        });

                        context(@"When task name is not present", ^{
                            beforeEach(^{
                                task stub_method(@selector(name)).again().and_return(nil);
                                punch stub_method(@selector(task)).again().and_return(task);
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(3);
                            });
                            it(@"should have correctly configured cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedClientTitle);
                                cellA.value.text should equal(@"client-name");

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedProjectTitle);
                                cellB.value.text should equal(@"project-name");

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(expectedTaskTitle);
                                cellC.value.text should equal(RPLocalizedString(@"None", nil));

                            });
                        });

                    });

            context(@"When Punch Action is PunchActionTypeIn"
                    @"When user has client access"
                    @"When user has project access"
                    @"When punch address is available but no location info required on UI", ^{

                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchIn);

                            client stub_method(@selector(name)).again().and_return(@"client-name");
                            punch stub_method(@selector(client)).again().and_return(client);

                            project stub_method(@selector(name)).again().and_return(@"project-name");
                            punch stub_method(@selector(project)).again().and_return(project);

                            task stub_method(@selector(name)).again().and_return(@"task-name");
                            punch stub_method(@selector(task)).again().and_return(task);

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedProjectTitle);
                            cellB.value.text should equal(@"project-name");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(expectedTaskTitle);
                            cellC.value.text should equal(@"task-name");

                        });

                    });

            context(@"When Punch Action is PunchActionTypeStartBreak"
                    @"When user has client access"
                    @"When user has project access"
                    @"When punch address is available but no location info required on UI", ^{

                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);

                            client stub_method(@selector(name)).again().and_return(@"client-name");
                            punch stub_method(@selector(client)).again().and_return(client);

                            project stub_method(@selector(name)).again().and_return(@"project-name");
                            punch stub_method(@selector(project)).again().and_return(project);

                            task stub_method(@selector(name)).again().and_return(@"task-name");
                            punch stub_method(@selector(task)).again().and_return(task);

                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(0);
                        });

                    });

            context(@"When Punch Action is PunchActionTypePunchOut"
                    @"When user has client access"
                    @"When user has project access"
                    @"When punch address is available but no location info required on UI", ^{

                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);

                            client stub_method(@selector(name)).again().and_return(@"client-name");
                            punch stub_method(@selector(client)).again().and_return(client);

                            project stub_method(@selector(name)).again().and_return(@"project-name");
                            punch stub_method(@selector(project)).again().and_return(project);

                            task stub_method(@selector(name)).again().and_return(@"task-name");
                            punch stub_method(@selector(task)).again().and_return(task);

                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);

                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(0);
                        });

                    });
            
            context(@"When user has client access"
                    @"When user has no project access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedLocationTitle);
                            cellA.value.text should equal(@"my-location");
                        });
                    });
            
            context(@"When user has client access"
                    @"When user has no project access"
                    @"When punch address is not available and location info required on UI", ^{
                        beforeEach(^{
                            punch stub_method(@selector(address)).again().and_return(nil);
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedLocationTitle);
                            cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is available but no location info required on UI", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedLocationTitle);
                            cellB.value.text should equal(@"my-location");

                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is not available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");
                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is not available and location info required on UI", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];

                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedLocationTitle);
                            cellB.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));

                        });
                    });
            
            context(@"When user has activity access"
                    @"when user has default activity", ^{
                        __block Activity *activityObject;
                        beforeEach(^{
                            activityObject = [[Activity alloc] initWithName:@"default-activity-name" uri:@"default-activity-uri"];

                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"default-activity-name",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"default-activity-uri",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            LocalPunch *localPunch = [[LocalPunch alloc]
                                                                  initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                               actionType:PunchActionTypePunchIn
                                                                             lastSyncTime:NULL
                                                                                breakType:nil
                                                                                 location:nil
                                                                                  project:nil
                                                                                requestID:@"ABCD1234"
                                                                                 activity:nil
                                                                                   client:nil
                                                                                 oefTypes:nil
                                                                                  address:nil
                                                                                  userURI:nil
                                                                                    image:nil
                                                                                     task:nil
                                                                                     date:nil];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:localPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"default-activity-name");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedLocationTitle);
                            cellB.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                            
                        });
                        
                        it(@"should update parent view with default activity", ^{
                            subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDefaultActivity:)).with(subject, activityObject);
                        });

                    });
            
            context(@"When user has activity access"
                    @"when user don't have default activity", ^{
                        beforeEach(^{
                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            LocalPunch *localPunch = [[LocalPunch alloc]
                                                                  initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                               actionType:PunchActionTypePunchIn
                                                                             lastSyncTime:NULL
                                                                                breakType:nil
                                                                                 location:nil
                                                                                  project:nil
                                                                                requestID:@"ABCD1234"
                                                                                 activity:nil
                                                                                   client:nil
                                                                                 oefTypes:nil
                                                                                  address:nil
                                                                                  userURI:nil
                                                                                    image:nil
                                                                                     task:nil
                                                                                     date:nil];
                            
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:localPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"None");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedLocationTitle);
                            cellB.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                            
                        });
                    });

            context(@"When user has  client access"
                    @"When user has  project access"
                    @"When user has activity access"
                    @"default activity is available"
                    @"When punch address is available and location info required on UI", ^{
                        __block Activity *activityObject;
                        beforeEach(^{
                            activityObject = [[Activity alloc] initWithName:@"default-activity-name" uri:@"default-activity-uri"];
                            
                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"default-activity-name",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"default-activity-uri",
                                                                  };
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedProjectTitle);
                            cellB.value.text should equal(@"project-name");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(expectedTaskTitle);
                            cellC.value.text should equal(@"task-name");

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(expectedLocationTitle);
                            cellD.value.text should equal(@"my-location");
                            
                        });

                        it(@"should not received setUpWithUserUri", ^{
                            defaultActivityStorage should_not have_received(@selector(setUpWithUserUri:));
                            defaultActivityStorage should_not have_received(@selector(defaultActivityDetails));
                        });
                    });
            
            context(@"When user has  client access"
                    @"When user has  project access"
                    @"When user has activity access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");
                            
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedProjectTitle);
                            cellB.value.text should equal(@"project-name");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(expectedTaskTitle);
                            cellC.value.text should equal(@"task-name");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(expectedLocationTitle);
                            cellD.value.text should equal(@"my-location");
                            
                        });
                        
                        
                    });


            context(@"When user has activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                           
                            
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textView.text should equal(@"some-dropdown-option-value");


                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textView.text should equal(@"some-dropdown-option-value");
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(@"my-location");
                            
                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is not available"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            

                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];

                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                            
                        });
                    });

            context(@"When user has activity access"
                    @"when user has default activity"
                    @"When oefTypes are available", ^{
                        __block Activity *activityObject;
                        beforeEach(^{
                            activityObject = [[Activity alloc] initWithName:@"default-activity-name" uri:@"default-activity-uri"];

                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"default-activity-name",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"default-activity-uri",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);
                            LocalPunch *localPunch = [[LocalPunch alloc]
                                                                  initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                               actionType:PunchActionTypePunchIn
                                                                             lastSyncTime:NULL
                                                                                breakType:nil
                                                                                 location:nil
                                                                                  project:nil
                                                                                requestID:@"ABCD1234"
                                                                                 activity:nil
                                                                                   client:nil
                                                                                 oefTypes:oefTypesArray
                                                                                  address:nil
                                                                                  userURI:nil
                                                                                    image:nil
                                                                                     task:nil
                                                                                     date:nil];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:localPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"default-activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));

                        });

                        it(@"should update parent view with default activity", ^{
                            subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDefaultActivity:)).with(subject, activityObject);
                        });
                        
                    });

            context(@"When user has activity access"
                    @"when user don't have default activity"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            LocalPunch *localPunch = [[LocalPunch alloc]
                                                                  initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                               actionType:PunchActionTypePunchIn
                                                                             lastSyncTime:NULL
                                                                                breakType:nil
                                                                                 location:nil
                                                                                  project:nil
                                                                                requestID:@"ABCD1234"
                                                                                 activity:nil
                                                                                   client:nil
                                                                                 oefTypes:oefTypesArray
                                                                                  address:nil
                                                                                  userURI:nil
                                                                                    image:nil
                                                                                     task:nil
                                                                                     date:nil];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:localPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"None");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                           
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");

                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));


                        });
                    });

            context(@"When user has activity access"
                    @"when user has default activity"
                    @"Punch is RemotePunch", ^{
                        __block Activity *activityObject;
                        beforeEach(^{
                            activityObject = [[Activity alloc] initWithName:@"default-activity-name" uri:@"default-activity-uri"];

                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"default-activity-name",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"default-activity-uri",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);
                            
                            RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                  nonActionedValidations:0
                                                     previousPunchStatus:Unknown
                                                         nextPunchStatus:Unknown
                                                           sourceOfPunch:UnknownSourceOfPunch
                                                              actionType:PunchActionTypePunchIn
                                                           oefTypesArray:nil
                                                            lastSyncTime:NULL
                                                                 project:nil
                                                             auditHstory:nil
                                                               breakType:nil
                                                                location:nil
                                                              violations:nil
                                                               requestID:@"ABCD1234"
                                                                activity:nil
                                                                duration:nil
                                                                  client:nil
                                                                 address:nil
                                                                 userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                imageURL:nil
                                                                    date:nil
                                                                    task:task
                                                                     uri:@"uri"
                                                    isTimeEntryAvailable:NO
                                                        syncedWithServer:NO
                                                          isMissingPunch:NO
                                                 previousPunchActionType:PunchActionTypeUnknown];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:remotePunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(RPLocalizedString(@"None", nil));

                        });

                        it(@"should update parent view with default activity", ^{
                            subject.delegate should_not have_received(@selector(punchAttributeController:didIntendToUpdateDefaultActivity:)).with(subject, activityObject);
                        });
                        
                    });

            context(@"When user has activity access"
                    @"when user has default activity"
                    @"Punch is ManualPunch", ^{
                        __block Activity *activityObject;
                        beforeEach(^{
                            activityObject = [[Activity alloc] initWithName:@"default-activity-name" uri:@"default-activity-uri"];

                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"default-activity-name",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"default-activity-uri",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            ManualPunch *manualPunch = [[ManualPunch alloc]
                                                                     initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                                  actionType:PunchActionTypePunchIn
                                                                                lastSyncTime:NULL
                                                                                   breakType:nil
                                                                                    location:nil
                                                                                     project:nil
                                                                                   requestID:@"ABCD1234"
                                                                                    activity:nil
                                                                                      client:nil
                                                                                    oefTypes:nil
                                                                                     address:nil
                                                                                     userURI:nil
                                                                                       image:nil
                                                                                        task:nil
                                                                                        date:nil];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:manualPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"default-activity-name");

                        });

                        it(@"should update parent view with default activity", ^{
                            subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDefaultActivity:)).with(subject, activityObject);
                        });
                        
                    });

            context(@"When user has activity access"
                    @"when user has default activity"
                    @"Punch is offline local punch", ^{
                        __block Activity *activityObject;
                        beforeEach(^{
                            activityObject = [[Activity alloc] initWithName:@"default-activity-name" uri:@"default-activity-uri"];

                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"default-activity-name",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"default-activity-uri",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            OfflineLocalPunch *offlineLocalPunch = [[OfflineLocalPunch alloc]
                                                                                       initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                                                    actionType:PunchActionTypePunchIn
                                                                                                  lastSyncTime:NULL
                                                                                                     breakType:nil
                                                                                                      location:nil
                                                                                                       project:nil
                                                                                                     requestID:@"ABCD1234"
                                                                                                      activity:nil
                                                                                                        client:nil
                                                                                                      oefTypes:nil
                                                                                                       address:nil
                                                                                                       userURI:nil
                                                                                                         image:nil
                                                                                                          task:nil
                                                                                                          date:nil];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:offlineLocalPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"default-activity-name");

                        });

                        it(@"should update parent view with default activity", ^{
                            subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDefaultActivity:)).with(subject, activityObject);
                        });
                        
                    });

            context(@"When user has activity access"
                    @"when user don't have default activity"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        beforeEach(^{
                            NSDictionary *defaultActivityDict = @{
                                                                  @"default_activity_name": @"",
                                                                  @"user_uri": @"default-uri",
                                                                  @"default_activity_uri": @"",
                                                                  };
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(defaultActivityDict);

                            LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                      actionType:PunchActionTypePunchOut
                                                      lastSyncTime:NULL
                                                      breakType:nil
                                                      location:nil
                                                      project:nil
                                                      requestID:@"ABCD1234"
                                                      activity:nil
                                                      client:nil
                                                      oefTypes:oefTypesArray
                                                      address:nil
                                                      userURI:nil
                                                      image:nil
                                                      task:nil
                                                      date:nil];

                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:localPunch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));

                        });
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];

                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textView.text should equal(@"some-dropdown-option-value");


                        });
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textView.text should equal(@"some-dropdown-option-value");

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(@"my-location");

                        });
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is not available"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];

                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                        });
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:UserFlowContext
                                                       userUri:nil
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];

                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                            
                        });
                    });

        });
        context(@"When flow is <SupervisorFlowContext>", ^{

            beforeEach(^{
                punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
            });

            context(@"When user has no client access"
                    @"When user has project access"
                    @"When punch address is available", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedProjectTitle);
                            cellA.value.text should equal(@"project-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedTaskTitle);
                            cellB.value.text should equal(@"task-name");

                        });
                    });

            context(@"When user has client access"
                    @"When user has no project access"
                    @"When punch address is available", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(0);
                        });

                    });

            context(@"When user has client access"
                    @"When user has project access"
                    @"When punch address is not available", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });

                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedClientTitle);
                            cellA.value.text should equal(@"client-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedProjectTitle);
                            cellB.value.text should equal(@"project-name");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(expectedTaskTitle);
                            cellC.value.text should equal(@"task-name");

                        });
                    });

            context(@"When user has client access"
                    @"When user has project access"
                    @"When punch address is available", ^{

                        context(@"When client name is not present", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                client stub_method(@selector(name)).again().and_return(nil);
                                punch stub_method(@selector(client)).again().and_return(client);
                                reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:SupervisorFlowContext
                                                           userUri:@"user-uri"
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(3);
                            });
                            it(@"should have correctly configured cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedClientTitle);
                                cellA.value.text should equal(RPLocalizedString(@"None", nil));

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedProjectTitle);
                                cellB.value.text should equal(@"project-name");

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(expectedTaskTitle);
                                cellC.value.text should equal(@"task-name");

                            });
                        });

                        context(@"When project name is not present", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                project stub_method(@selector(name)).again().and_return(nil);
                                punch stub_method(@selector(project)).again().and_return(project);
                                reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:SupervisorFlowContext
                                                           userUri:@"user-uri"
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(3);
                            });
                            it(@"should have correctly configured cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedClientTitle);
                                cellA.value.text should equal(@"client-name");

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedProjectTitle);
                                cellB.value.text should equal(RPLocalizedString(@"None", nil));

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(expectedTaskTitle);
                                cellC.value.text should equal(@"task-name");

                            });
                        });

                        context(@"When task name is not present", ^{
                            beforeEach(^{
                                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                task stub_method(@selector(name)).again().and_return(nil);
                                punch stub_method(@selector(task)).again().and_return(task);
                                reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(YES);
                                reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                [subject setUpWithNeedLocationOnUI:NO
                                                          delegate:delegate
                                                          flowType:SupervisorFlowContext
                                                           userUri:@"user-uri"
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                [subject view];
                            });
                            it(@"should have correct number of rows in the tableview", ^{
                                [subject.tableView numberOfRowsInSection:0] should equal(3);
                            });
                            it(@"should have correctly configured cells in the tableview", ^{
                                NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellA.title.text should equal(expectedClientTitle);
                                cellA.value.text should equal(@"client-name");

                                NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellB.title.text should equal(expectedProjectTitle);
                                cellB.value.text should equal(@"project-name");

                                NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellC.title.text should equal(expectedTaskTitle);
                                cellC.value.text should equal(RPLocalizedString(@"None", nil));

                            });
                        });

                    });
            
            context(@"When user has client access"
                    @"When user has no project access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedLocationTitle);
                            cellA.value.text should equal(@"my-location");
                            
                        });
                    });
            
            context(@"When user has client access"
                    @"When user has no project access"
                    @"When punch address is not available and location info required on UI", ^{
                        beforeEach(^{
                            punch stub_method(@selector(address)).again().and_return(nil);
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });
                        
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedLocationTitle);
                            cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });
                    });
            
            
            context(@"When OEF type available"
                    @"When Action is Clock In", ^{
                        beforeEach(^{
                           
                            __block OEFType *oefType4;
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchIn);
                            
                        });
                        
                        context(@"When user has no client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedProjectTitle);
                                        cellA.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedTaskTitle);
                                        cellB.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(7);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    
                                    context(@"When client name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            client stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(client)).again().and_return(client);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(RPLocalizedString(@"None", nil));
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(@"project-name");
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(@"task-name");
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When project name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            project stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(project)).again().and_return(project);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(@"client-name");
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(RPLocalizedString(@"None", nil));
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(@"task-name");
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When task name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            task stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(task)).again().and_return(task);
                                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(YES);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(@"client-name");
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(@"project-name");
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(RPLocalizedString(@"None", nil));
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(8);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(RPLocalizedString(@"task-name", nil));
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(8);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(RPLocalizedString(@"task-name", nil));
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
  
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                    });
                                });
                        
                    });
            
            
            context(@"When OEF type available"
                    @"When Action is Transfer", ^{
                        beforeEach(^{
                            
                            __block OEFType *oefType4;
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            
                        });
                        
                        context(@"When user has no client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedProjectTitle);
                                        cellA.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedTaskTitle);
                                        cellB.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(7);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(@"task-name");
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    
                                    context(@"When client name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            client stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(client)).again().and_return(client);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(RPLocalizedString(@"None", nil));
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(@"project-name");
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(@"task-name");
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When project name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            project stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(project)).again().and_return(project);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(@"client-name");
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(RPLocalizedString(@"None", nil));
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(@"task-name");
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When task name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            task stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(task)).again().and_return(task);
                                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(YES);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(7);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellA.title.text should equal(expectedClientTitle);
                                            cellA.value.text should equal(@"client-name");
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellB.title.text should equal(expectedProjectTitle);
                                            cellB.value.text should equal(@"project-name");
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellC.title.text should equal(expectedTaskTitle);
                                            cellC.value.text should equal(RPLocalizedString(@"None", nil));
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(8);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(RPLocalizedString(@"task-name", nil));
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(8);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellA.title.text should equal(expectedClientTitle);
                                        cellA.value.text should equal(@"client-name");
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellB.title.text should equal(expectedProjectTitle);
                                        cellB.value.text should equal(@"project-name");
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellC.title.text should equal(expectedTaskTitle);
                                        cellC.value.text should equal(RPLocalizedString(@"task-name", nil));
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                    });
                                });
                        
                    });
            
            context(@"When OEF type available"
                    @"When Action is Clock out", ^{
                        beforeEach(^{
                            
                            __block OEFType *oefType4;
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            
                        });
                        
                        context(@"When user has no client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    
                                    context(@"When client name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            client stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(client)).again().and_return(client);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When project name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            project stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(project)).again().and_return(project);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When task name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            task stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(task)).again().and_return(task);
                                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(YES);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                    });
                                });
                        
                    });
            
            context(@"When OEF type available"
                    @"When Action is Break", ^{
                        beforeEach(^{
                            
                            __block OEFType *oefType4;
                            oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                            NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                            punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-name" uri:@"break-uri"]);
                            
                        });
                        
                        context(@"When user has no client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        [subject setUpWithNeedLocationOnUI:NO
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(4);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available", ^{
                                    
                                    context(@"When client name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            client stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(client)).again().and_return(client);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When project name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            project stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(project)).again().and_return(project);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                    context(@"When task name is not present", ^{
                                        beforeEach(^{
                                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                            task stub_method(@selector(name)).again().and_return(nil);
                                            punch stub_method(@selector(task)).again().and_return(task);
                                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(YES);
                                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                            [subject setUpWithNeedLocationOnUI:NO
                                                                      delegate:delegate
                                                                      flowType:SupervisorFlowContext
                                                                       userUri:@"user-uri"
                                                                         punch:punch
                                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                            [subject view];
                                        });
                                        it(@"should have correct number of rows in the tableview", ^{
                                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                                        });
                                        it(@"should have correctly configured cells in the tableview", ^{
                                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                            DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                            cellF.title.text should equal(@"text 1");
                                            cellF.textView.text should equal(@"sample text");
                                            cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellF.title.textColor should equal([UIColor redColor]);
                                            cellF.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                            DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                            cellG.title.text should equal(@"numeric 1");
                                            cellG.textView.text should equal(@"230.89");
                                            cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellG.title.textColor should equal([UIColor redColor]);
                                            cellG.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                            cellD.title.text should equal(@"dropdown oef 1");
                                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                            cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellD.title.textColor should equal([UIColor redColor]);
                                            cellD.textView.textColor should equal([UIColor yellowColor]);
                                            
                                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                            DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                            cellE.title.text should equal(@"dropdown oef 2");
                                            cellE.textValueLabel.text should equal(@"None");
                                            cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                            cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                            cellE.title.textColor should equal([UIColor redColor]);
                                            cellE.textView.textColor should equal([UIColor yellowColor]);
                                            
                                        });
                                    });
                                    
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(YES);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellG.title.text should equal(@"numeric 1");
                                        cellG.textView.text should equal(@"230.89");
                                        cellG.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellG.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellG.title.textColor should equal([UIColor redColor]);
                                        cellG.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellH = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellH.title.text should equal(expectedLocationTitle);
                                        cellH.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is available and location info required on UI", ^{
                                    beforeEach(^{
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(@"my-location");
                                        
                                    });
                                });
                        
                        context(@"When user has client access"
                                @"When user has no project access"
                                @"When punch address is not available and location info required on UI", ^{
                                    beforeEach(^{
                                        punch stub_method(@selector(address)).again().and_return(nil);
                                        astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                                        reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                                        [subject setUpWithNeedLocationOnUI:YES
                                                                  delegate:delegate
                                                                  flowType:SupervisorFlowContext
                                                                   userUri:@"user-uri"
                                                                     punch:punch
                                                  punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                        [subject view];
                                    });
                                    
                                    it(@"should have correct number of rows in the tableview", ^{
                                        [subject.tableView numberOfRowsInSection:0] should equal(5);
                                    });
                                    
                                    it(@"should have correctly configured cells in the tableview", ^{
                                        
                                        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                        DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                        cellF.title.text should equal(@"text 1");
                                        cellF.textView.text should equal(@"sample text");
                                        cellF.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellF.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellF.title.textColor should equal([UIColor redColor]);
                                        cellF.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                                        DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                        cellC.title.text should equal(@"numeric 1");
                                        cellC.textView.text should equal(@"230.89");
                                        cellC.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellC.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellC.title.textColor should equal([UIColor redColor]);
                                        cellC.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                                        DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                        cellD.title.text should equal(@"dropdown oef 1");
                                        cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                                        cellD.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellD.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellD.title.textColor should equal([UIColor redColor]);
                                        cellD.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                                        DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                        cellE.title.text should equal(@"dropdown oef 2");
                                        cellE.textValueLabel.text should equal(@"None");
                                        cellE.title.font should equal([UIFont systemFontOfSize:10]);
                                        cellE.textView.font should equal([UIFont systemFontOfSize:11]);
                                        cellE.title.textColor should equal([UIColor redColor]);
                                        cellE.textView.textColor should equal([UIColor yellowColor]);
                                        
                                        NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                                        PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                        cellA.title.text should equal(expectedLocationTitle);
                                        cellA.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                                    });
                                });
                        
                    });

            context(@"When user has activity access"
                    @"When punch address is available but no location info required on UI", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");
                        });

                    });

            context(@"When user has  activity access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedLocationTitle);
                            cellB.value.text should equal(@"my-location");
                            
                        });
                        
                    });

            context(@"When user has activity access"
                    @"When punch address is not available and location info required on UI", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(2);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(expectedLocationTitle);
                            cellB.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));

                        });

                    });

            context(@"When user has activity access"
                    @"When punch address is not available but no location info required on UI", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(1);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                        });
                        
                    });

            context(@"When user has activity access"
                   @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available", ^{
                       beforeEach(^{
                           reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                           punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                           [subject setUpWithNeedLocationOnUI:NO
                                                     delegate:delegate
                                                     flowType:SupervisorFlowContext
                                                      userUri:@"user-uri"
                                                        punch:punch
                                     punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                           [subject view];
                       });
                        
                       it(@"should have correct number of rows in the tableview", ^{
                           [subject.tableView numberOfRowsInSection:0] should equal(4);
                       });
                       it(@"should have correctly configured cells in the tableview", ^{
                           NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                           PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                           cellA.title.text should equal(expectedActivityTitle);
                           cellA.value.text should equal(@"activity-name");

                           NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                           DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                           cellB.title.text should equal(@"text 1");
                           cellB.textView.text should equal(@"sample text");

                           NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                           DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                           cellC.title.text should equal(@"numeric 1");
                           cellC.textView.text should equal(@"230.89");
                           
                           NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                           DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                           cellD.title.text should equal(@"dropdown oef 1");
                           cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                           

                       });

                   });

            context(@"When user has  activity access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellE.title.text should equal(@"Location :");
                            cellE.value.text should equal(@"my-location");

                        });

                    });

            context(@"When user has activity access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(5);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                            NSIndexPath *fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });

                    });

            context(@"When user has activity access"
                    @"When punch address is not available but no location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellA.title.text should equal(expectedActivityTitle);
                            cellA.value.text should equal(@"activity-name");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            

                        });
                        
                    });

            context(@"When user has  activity access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");

                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(@"my-location");

                        });
                        
                    });

            context(@"When user has activity access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            


                        });
                        
                    });


            context(@"When user has  activity access"
                    @"When punch address is not available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                        });
                        
                    });

            context(@"When user has activity access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Clock Out", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypePunchOut);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(YES);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });
                        
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(@"Location :");
                            cellE.value.text should equal(@"my-location");

                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");

                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is not available but no location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(@"my-location");

                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");



                        });

                    });


            context(@"When user has no activity and project access"
                    @"When punch address is not available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Transfer", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");
                            
                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });
                        
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is Start Break", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                             punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-type" uri:@"break-uri"]);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });

                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{

                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(@"my-location");

                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is StartBreak", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                            punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-type" uri:@"break-uri"]);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");



                        });

                    });


            context(@"When user has no activity and project access"
                    @"When punch address is not available but no location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is StartBreak", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                            punch stub_method(@selector(breakType)).and_return([[BreakType alloc] initWithName:@"break-type" uri:@"break-uri"]);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            [subject setUpWithNeedLocationOnUI:NO
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(3);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");


                        });

                    });

            context(@"When user has no activity and project access"
                    @"When punch address is not available and location info required on UI"
                    @"When oefTypes are available"
                    @"And Punch is StartBreak", ^{
                        beforeEach(^{
                            punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeTransfer);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessProjectUserWithUri:)).with(@"user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessClientUserWithUri:)).with(@"user-uri").and_return(NO);
                            punch stub_method(@selector(address)).again().and_return(nil);
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            [subject setUpWithNeedLocationOnUI:YES
                                                      delegate:delegate
                                                      flowType:SupervisorFlowContext
                                                       userUri:@"user-uri"
                                                         punch:punch
                                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                            [subject view];
                        });
                        it(@"should have correct number of rows in the tableview", ^{
                            [subject.tableView numberOfRowsInSection:0] should equal(4);
                        });
                        it(@"should have correctly configured cells in the tableview", ^{
                            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                            cellB.title.text should equal(@"text 1");
                            cellB.textView.text should equal(@"sample text");

                            NSIndexPath *secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            cellC.title.text should equal(@"numeric 1");
                            cellC.textView.text should equal(@"230.89");

                            NSIndexPath *thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                            cellD.title.text should equal(@"dropdown oef 1");
                            cellD.textValueLabel.text should equal(@"some-dropdown-option-value");

                            
                            NSIndexPath *fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            cellE.title.text should equal(expectedLocationTitle);
                            cellE.value.text should equal(RPLocalizedString(@"Location Unavailable",@""));
                        });
                        
                    });

        });

        describe(@"Presenting cells", ^{

            __block PunchAttributeCell *cellA;
            __block PunchAttributeCell *cellB;
            __block PunchAttributeCell *cellC;
            __block PunchAttributeCell *cellD;
            __block DynamicTextTableViewCell *cellE;
            __block DynamicTextTableViewCell *cellF;
            __block DynamicTextTableViewCell *cellG;
        
            __block NSIndexPath *firstIndexPath;
            __block NSIndexPath *secondIndexPath;
            __block NSIndexPath *thirdIndexPath;
            __block NSIndexPath *fourthIndexPath;
            __block NSIndexPath *fifthIndexPath;
            __block NSIndexPath *sixthIndexPath;
            __block NSIndexPath *seventhIndexPath;
            __block NSIndexPath *eighthIndexPath;


            context(@"When user has client access"
                    @"When user has project access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];

                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);


                        });

                        context(@"when canEditNonTimeFields is false ", ^{

                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellC.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellD.accessoryType should equal(UITableViewCellAccessoryNone);
                            });

                            it(@"should disable all the cells", ^{
                                cellA.userInteractionEnabled should be_falsy;
                                cellB.userInteractionEnabled should be_falsy;
                                cellC.userInteractionEnabled should be_falsy;
                                cellD.userInteractionEnabled should be_falsy;
                            });

                            it(@"should set correct color for all the disabled cells", ^{
                                cellA.value.textColor should equal([UIColor greenColor]);
                                cellB.value.textColor should equal([UIColor greenColor]);
                                cellC.value.textColor should equal([UIColor greenColor]);
                                cellD.value.textColor should equal([UIColor greenColor]);
                            });

                        });

                        context(@"when canEditNonTimeFields is true", ^{
                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellB.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellC.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellD.accessoryType should equal(UITableViewCellAccessoryNone);
                            });
                            
                            it(@"should not disable the cells excluding location", ^{
                                cellA.userInteractionEnabled should be_truthy;
                                cellB.userInteractionEnabled should be_truthy;
                                cellC.userInteractionEnabled should be_truthy;
                                cellD.userInteractionEnabled should be_falsy;
                            });
                            
                        });
            });
            
            context(@"When user has client access"
                    @"When user has project access"
                    @"When punch address is available and location info required on UI"
                    @"When OEF types available", ^{
                        beforeEach(^{
                            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                            eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            
                        });
                        
                        context(@"when canEditNonTimeFields is false ", ^{
                            
                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                            });
                            
                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellC.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellD.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellE.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellF.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellG.accessoryType should equal(UITableViewCellAccessoryNone);
                                
                            });
                            
                            it(@"should disable all the cells", ^{
                                cellA.userInteractionEnabled should be_falsy;
                                cellB.userInteractionEnabled should be_falsy;
                                cellC.userInteractionEnabled should be_falsy;
                                cellD.userInteractionEnabled should be_falsy;
                                cellE.userInteractionEnabled should be_falsy;
                                cellF.userInteractionEnabled should be_falsy;
                                cellG.userInteractionEnabled should be_falsy;
                            });

                            it(@"should set correct color for all the disabled cells", ^{
                                cellA.value.textColor should equal([UIColor greenColor]);
                                cellB.value.textColor should equal([UIColor greenColor]);
                                cellC.value.textColor should equal([UIColor greenColor]);
                                cellD.value.textColor should equal([UIColor greenColor]);
                                cellE.textView.textColor should equal([UIColor greenColor]);
                                cellF.textView.textColor should equal([UIColor greenColor]);
                                cellG.textValueLabel.textColor should equal([UIColor greenColor]);
                            });
                            
                        });
                        
                        context(@"when canEditNonTimeFields is true", ^{
                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                                cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                            });
                            
                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellB.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellC.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellD.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellE.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellF.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellG.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                            });
                            
                            it(@"should not disable the cells excluding location", ^{
                                cellA.userInteractionEnabled should be_truthy;
                                cellB.userInteractionEnabled should be_truthy;
                                cellC.userInteractionEnabled should be_truthy;
                                cellD.userInteractionEnabled should be_falsy;
                                cellE.userInteractionEnabled should be_truthy;
                                cellF.userInteractionEnabled should be_truthy;
                                cellG.userInteractionEnabled should be_truthy;
                            });
                            
                        });
                    });
            
            context(@"When user has no client access"
                    @"When user has project access"
                    @"When punch address is available and location info required on UI"
                    @"When OEF types available", ^{
                        beforeEach(^{
                            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
                            seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
                            eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                            
                            
                        });
                        
                        context(@"when canEditNonTimeFields is false ", ^{
                            
                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                            });
                            
                            it(@"should have disclosure indicator in cells excluding location", ^{
                                
                                cellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellC.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellD.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellE.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellF.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellG.accessoryType should equal(UITableViewCellAccessoryNone);
                                
                            });
                        
                            it(@"should disable all the cells", ^{
                                
                                cellB.userInteractionEnabled should be_falsy;
                                cellC.userInteractionEnabled should be_falsy;
                                cellD.userInteractionEnabled should be_falsy;
                                cellE.userInteractionEnabled should be_falsy;
                                cellF.userInteractionEnabled should be_falsy;
                                cellG.userInteractionEnabled should be_falsy;
                            });

                            it(@"should set correct color for all the disabled cells", ^{
                                cellB.value.textColor should equal([UIColor greenColor]);
                                cellC.value.textColor should equal([UIColor greenColor]);
                                cellD.value.textColor should equal([UIColor greenColor]);
                                cellE.textView.textColor should equal([UIColor greenColor]);
                                cellF.textView.textColor should equal([UIColor greenColor]);
                                cellG.textValueLabel.textColor should equal([UIColor greenColor]);
                            });
                            
                        });
                        
                        context(@"when canEditNonTimeFields is true", ^{
                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellG = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                                cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                            });
                            
                            it(@"should have disclosure indicator in cells excluding location", ^{
                                
                                cellB.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellC.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellD.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellE.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellF.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellG.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                            });
                            
                            it(@"should not disable the cells excluding location", ^{
                                
                                cellB.userInteractionEnabled should be_truthy;
                                cellC.userInteractionEnabled should be_truthy;
                                cellD.userInteractionEnabled should be_falsy;
                                cellE.userInteractionEnabled should be_truthy;
                                cellF.userInteractionEnabled should be_truthy;
                                cellG.userInteractionEnabled should be_truthy;
                            });
                            
                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is available and location info required on UI", ^{
                        beforeEach(^{
                            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];

                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        });

                        context(@"when canEditNonTimeFields is false ", ^{

                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellB.accessoryType should equal(UITableViewCellAccessoryNone);
                            });

                            it(@"should disable all the cells", ^{
                                cellA.userInteractionEnabled should be_falsy;
                                cellB.userInteractionEnabled should be_falsy;
                            });

                            it(@"should set correct color for all the disabled cells", ^{
                                cellA.value.textColor should equal([UIColor greenColor]);
                                cellB.value.textColor should equal([UIColor greenColor]);
                            });

                        });

                        context(@"when canEditNonTimeFields is true", ^{
                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];

                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                cellB.accessoryType should equal(UITableViewCellAccessoryNone);
                            });

                            it(@"should not disable the cells excluding location", ^{
                                cellA.userInteractionEnabled should be_truthy;
                                cellB.userInteractionEnabled should be_falsy;
                            });
                            
                        });
                    });

            context(@"When user has activity access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                        });

                        context(@"when canEditNonTimeFields is false ", ^{
                            __block DynamicTextTableViewCell *dynamicCellA;
                            __block DynamicTextTableViewCell *dynamicCellB;
                            __block DynamicTextTableViewCell *dynamicCellC;

                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;
                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                                dynamicCellA = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                                dynamicCellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                                dynamicCellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                                cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellC.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellB.accessoryType should equal(UITableViewCellAccessoryNone);
                            });

                            it(@"should disable all the cells", ^{
                                cellA.userInteractionEnabled should be_falsy;
                                dynamicCellA.userInteractionEnabled should be_falsy;
                                dynamicCellB.userInteractionEnabled should be_falsy;
                                dynamicCellC.userInteractionEnabled should be_falsy;
                                cellB.userInteractionEnabled should be_falsy;

                            });

                            it(@"should set correct color for all the disabled cells", ^{
                                cellA.value.textColor should equal([UIColor greenColor]);
                                dynamicCellA.textView.textColor should equal([UIColor greenColor]);
                                dynamicCellB.textView.textColor should equal([UIColor greenColor]);
                                dynamicCellC.textValueLabel.textColor should equal([UIColor greenColor]);
                                cellB.value.textColor should equal([UIColor greenColor]);
                            });

                        });

                        context(@"when canEditNonTimeFields is true", ^{
                            __block DynamicTextTableViewCell *dynamicCellA;
                            __block DynamicTextTableViewCell *dynamicCellB;
                            __block DynamicTextTableViewCell *dynamicCellC;

                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;

                                cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                                dynamicCellA = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                                dynamicCellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                                dynamicCellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];


                                

                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                cellA.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                                dynamicCellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellC.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                            });

                            it(@"should not disable the cells excluding location", ^{
                                cellA.userInteractionEnabled should be_truthy;
                                dynamicCellA.userInteractionEnabled should be_truthy;
                                dynamicCellB.userInteractionEnabled should be_truthy;
                                dynamicCellC.userInteractionEnabled should be_truthy;
                            });
                            
                        });
                    });

            context(@"When user has no activity and project access"
                    @"When punch address is available and location info required on UI"
                    @"When oefTypes are available", ^{
                        beforeEach(^{
                            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                        });

                        context(@"when canEditNonTimeFields is false ", ^{
                            __block DynamicTextTableViewCell *dynamicCellA;
                            __block DynamicTextTableViewCell *dynamicCellB;
                            __block DynamicTextTableViewCell *dynamicCellC;

                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(NO);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;

                                dynamicCellA = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                                dynamicCellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                                dynamicCellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                                 cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                            });

                            it(@"should not have disclosure indicator in cells excluding location", ^{
                                dynamicCellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellC.accessoryType should equal(UITableViewCellAccessoryNone);
                                cellA.accessoryType should equal(UITableViewCellAccessoryNone);
                            });

                            it(@"should disable all the cells", ^{
                                dynamicCellA.userInteractionEnabled should be_falsy;
                                dynamicCellB.userInteractionEnabled should be_falsy;
                                dynamicCellC.userInteractionEnabled should be_falsy;
                                cellA.userInteractionEnabled should be_falsy;

                            });

                            it(@"should set correct color for all the disabled cells", ^{
                                dynamicCellA.textView.textColor should equal([UIColor greenColor]);
                                dynamicCellB.textView.textColor should equal([UIColor greenColor]);
                                dynamicCellC.textValueLabel.textColor should equal([UIColor greenColor]);
                                cellA.value.textColor should equal([UIColor greenColor]);
                            });

                        });

                        context(@"when canEditNonTimeFields is true", ^{
                            __block DynamicTextTableViewCell *dynamicCellA;
                            __block DynamicTextTableViewCell *dynamicCellB;
                            __block DynamicTextTableViewCell *dynamicCellC;

                            beforeEach(^{
                                punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                                [subject setUpWithNeedLocationOnUI:YES
                                                          delegate:delegate
                                                          flowType:UserFlowContext
                                                           userUri:nil
                                                             punch:punch
                                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                                subject.view should_not be_nil;

                                dynamicCellA = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                                dynamicCellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                                dynamicCellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];




                            });

                            it(@"should have disclosure indicator in cells excluding location", ^{
                                dynamicCellA.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellB.accessoryType should equal(UITableViewCellAccessoryNone);
                                dynamicCellC.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                            });

                            it(@"should not disable the cells excluding location", ^{
                                dynamicCellA.userInteractionEnabled should be_truthy;
                                dynamicCellB.userInteractionEnabled should be_truthy;
                                dynamicCellC.userInteractionEnabled should be_truthy;
                            });
                            
                        });
                    });


        });

        describe(@"Tapping on punch attribute cells", ^{

            __block UINavigationController *navigationController;
            __block PunchCardObject *punchCardObject;

            context(@"when its a punch into project user", ^{
                beforeEach(^{

                    punchCardObject = [[PunchCardObject alloc]
                                                        initWithClientType:client
                                                               projectType:project
                                                             oefTypesArray:nil
                                                                 breakType:NULL
                                                                  taskType:task
                                                                  activity:NULL
                                                                       uri:nil];

                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);

                    [subject setUpWithNeedLocationOnUI:YES
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];

                    navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];

                    spy_on(navigationController);


                });

                it(@"should navigate when client cell is clicked", ^{
                    UITableViewCell *cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [cellA tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,punchCardObject,subject);
                });

                it(@"should navigate when project cell is clicked", ^{
                    UITableViewCell *cellB = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    [cellB tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCardObject,subject);
                });

                it(@"should navigate when task cell is clicked", ^{
                    UITableViewCell *cellC= [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    [cellC tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCardObject,subject);
                });

                it(@"should not navigate when location cell is clicked", ^{
                    UITableViewCell *cellD= [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    [cellD tap];
                    navigationController.topViewController should be_same_instance_as(subject);
                });

            });

            context(@"when its a punch into activities user", ^{

                beforeEach(^{

                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    punchCardObject = [[PunchCardObject alloc]
                                                        initWithClientType:NULL
                                                               projectType:NULL
                                                             oefTypesArray:nil
                                                                 breakType:NULL
                                                                  taskType:NULL
                                                                  activity:activity
                                                                       uri:nil];

                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);

                    [subject setUpWithNeedLocationOnUI:YES
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];


                    navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];

                    spy_on(navigationController);


                });

                it(@"should navigate when activity cell is clicked", ^{
                    UITableViewCell *cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [cellA tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ActivitySelection,punchCardObject,subject);
                });


                it(@"should not navigate when location cell is clicked", ^{
                    UITableViewCell *locationCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
                    [locationCell tap];
                    navigationController.topViewController should be_same_instance_as(subject);
                });

                it(@"should set focus on the text view when oef cell is clicked", ^{
                    DynamicTextTableViewCell *dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    spy_on(dynamicTextTableViewCell.textView);
                    [dynamicTextTableViewCell tap];
                    dynamicTextTableViewCell.textView should have_received(@selector(becomeFirstResponder));
                });
            });
            
            context(@"when its a punch into project user with OEFs", ^{
                
                beforeEach(^{
                    
                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    punch stub_method(@selector(activity)).again().and_return(nil);
                    punchCardObject = [[PunchCardObject alloc]
                                       initWithClientType:client
                                       projectType:project
                                       oefTypesArray:nil
                                       breakType:NULL
                                       taskType:task
                                       activity:NULL
                                       uri:nil];
                    
                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);
                    
                    [subject setUpWithNeedLocationOnUI:YES
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                    
                    
                    navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];
                    
                    spy_on(navigationController);
                    
                    
                });
                
                afterEach(^{
                   
                   punch stub_method(@selector(activity)).again().and_return(activity);
                    
                });
                
                it(@"should navigate when client cell is clicked", ^{
                    UITableViewCell *cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [cellA tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,punchCardObject,subject);
                });
                
                it(@"should navigate when project cell is clicked", ^{
                    UITableViewCell *cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    [cellA tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCardObject,subject);
                });
                
                it(@"should navigate when task cell is clicked", ^{
                    UITableViewCell *cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    [cellA tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCardObject,subject);
                });
                
                
                it(@"should not navigate when location cell is clicked", ^{
                    UITableViewCell *locationCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
                    [locationCell tap];
                    navigationController.topViewController should be_same_instance_as(subject);
                });
                
                it(@"should set focus on the text view when text oef cell is clicked", ^{
                    DynamicTextTableViewCell *dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    spy_on(dynamicTextTableViewCell.textView);
                    [dynamicTextTableViewCell tap];
                    dynamicTextTableViewCell.textView should have_received(@selector(becomeFirstResponder));
                });
                
                it(@"should naviagte when dropdown oef is clicked", ^{
                    punchCardObject = [[PunchCardObject alloc]
                                       initWithClientType:client
                                       projectType:project
                                       oefTypesArray:oefTypesArray
                                       breakType:NULL
                                       taskType:task
                                       activity:NULL
                                       uri:nil];
                    DynamicTextTableViewCell *dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    spy_on(dynamicTextTableViewCell.textView);
                    [dynamicTextTableViewCell tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                });
                
            });

            context(@"when its a simple punch user with OEFs", ^{

                beforeEach(^{

                    punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                    punch stub_method(@selector(activity)).again().and_return(nil);
                    punchCardObject = [[PunchCardObject alloc]
                                       initWithClientType:client
                                       projectType:project
                                       oefTypesArray:nil
                                       breakType:NULL
                                       taskType:task
                                       activity:NULL
                                       uri:nil];

                    astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                    punchRulesStorage stub_method(@selector(canEditNonTimeFields)).again().and_return(YES);

                    [subject setUpWithNeedLocationOnUI:YES
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];


                    navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                    subject.view should_not be_nil;
                    [subject.tableView layoutIfNeeded];

                    spy_on(navigationController);


                });

                afterEach(^{

                    punch stub_method(@selector(activity)).again().and_return(activity);

                });


                it(@"should not navigate when location cell is clicked", ^{
                    UITableViewCell *locationCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                    [locationCell tap];
                    navigationController.topViewController should be_same_instance_as(subject);
                });

                it(@"should set focus on the text view when text oef cell is clicked", ^{
                    DynamicTextTableViewCell *dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    spy_on(dynamicTextTableViewCell.textView);
                    [dynamicTextTableViewCell tap];
                    dynamicTextTableViewCell.textView should have_received(@selector(becomeFirstResponder));
                });

                it(@"should naviagte when dropdown oef is clicked", ^{
                    punchCardObject = [[PunchCardObject alloc]
                                       initWithClientType:NULL
                                       projectType:NULL
                                       oefTypesArray:oefTypesArray
                                       breakType:NULL
                                       taskType:NULL
                                       activity:NULL
                                       uri:nil];
                    DynamicTextTableViewCell *dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    spy_on(dynamicTextTableViewCell.textView);
                    [dynamicTextTableViewCell tap];
                    navigationController.topViewController should be_same_instance_as(selectionController);
                    selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                });

            });

        });

    });

    describe(@"viewDidLayoutSubviews", ^{

        beforeEach(^{
            [subject setUpWithNeedLocationOnUI:NO
                                      delegate:delegate
                                      flowType:UserFlowContext
                                       userUri:nil
                                         punch:punch
                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });

        it(@"should inform the tableViewDelegate PunchDetailsController updated its height", ^{
            delegate should have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height);
        });

    });

    describe(@"As a <SelectionControllerDelegate>", ^{

        __block NSString *expectedClientTitle;
        __block NSString *expectedProjectTitle;
        __block NSString *expectedTaskTitle;
        __block NSString *expectedActivityTitle;
        __block NSString *expectedLocationTitle;
        __block NSIndexPath *firstIndexPath;
        __block NSIndexPath *secondIndexPath;
        __block NSIndexPath *thirdIndexPath;
        __block NSIndexPath *fourthIndexPath;
         __block NSIndexPath *fifthIndexPath;
         __block NSIndexPath *sixthIndexPath;
        __block NSIndexPath *seventhIndexPath;
        __block NSIndexPath *eighthIndexPath;

        beforeEach(^{
            expectedClientTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Client", nil)];
            expectedProjectTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Project", nil)];
            expectedTaskTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Task", nil)];
            expectedActivityTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Activity", nil)];
            expectedLocationTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Location", nil)];

            firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            secondIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            thirdIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            fourthIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            fifthIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
            sixthIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
            seventhIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
            eighthIndexPath = [NSIndexPath indexPathForRow:7 inSection:0];

            punchRulesStorage stub_method(@selector(canEditNonTimeFields)).and_return(YES);

        });

        context(@"when its a punch into project user", ^{
            beforeEach(^{
                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
            });

            it(@"should have correct number of rows in the tableview", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(4);
            });

            it(@"should have correctly configured cells in the tableview", ^{

                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                cellA.title.text should equal(expectedClientTitle);
                cellA.value.text should equal(@"client-name");


                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                cellB.title.text should equal(expectedProjectTitle);
                cellB.value.text should equal(@"project-name");


                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                cellC.title.text should equal(expectedTaskTitle);
                cellC.value.text should equal(@"task-name");


                PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                cellD.title.text should equal(expectedLocationTitle);
                cellD.value.text should equal(RPLocalizedString(@"my-address", nil));

            });

            context(@"When updating client", ^{
                __block ClientType *client;
                beforeEach(^{
                    client = [[ClientType alloc]initWithName:@"new-client-name" uri:@"new-client-uri"];
                    [subject selectionController:nil didChooseClient:client];
                });

                it(@"should update the new client", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedClientTitle);
                    cellA.value.text should equal(@"new-client-name");

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedProjectTitle);
                    cellB.value.text should equal(@"None");


                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"None");
                    cellC.value.textColor should equal([UIColor greenColor]);
                    cellC.userInteractionEnabled should be_falsy;


                    PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(expectedLocationTitle);
                    cellD.value.text should equal(RPLocalizedString(@"my-address", nil));
                });

                it(@"should inform its delegate to update the client", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateClient:)).with(subject,client);
                });

            });
            
            context(@"When updating client and client null behaviour uri is selected and Type is Any client", ^{
                __block ClientType *client;
                beforeEach(^{
                    client = [[ClientType alloc]initWithName:@"Any Client" uri:ClientTypeAnyClientUri];
                    [subject selectionController:nil didChooseClient:client];
                });
                
                it(@"should update the new client", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedClientTitle);
                    cellA.value.text should equal(RPLocalizedString(@"Any Client", nil));
                    
                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedProjectTitle);
                    cellB.value.text should equal(@"None");
                    
                    
                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"None");
                    cellC.value.textColor should equal([UIColor greenColor]);
                    cellC.userInteractionEnabled should be_falsy;
                    
                    
                    PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(expectedLocationTitle);
                    cellD.value.text should equal(RPLocalizedString(@"my-address", nil));
                });
                
                it(@"should inform its delegate to update the client", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateClient:)).with(subject,client);
                });
                
            });
            
            context(@"When updating client and client null behaviour uri is selected and Type is No client", ^{
                __block ClientType *client;
                beforeEach(^{
                    client = [[ClientType alloc]initWithName:@"No Client" uri:ClientTypeNoClientUri];
                    [subject selectionController:nil didChooseClient:client];
                });
                
                it(@"should update the new client", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedClientTitle);
                    cellA.value.text should equal(RPLocalizedString(@"No Client", nil));
                    
                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedProjectTitle);
                    cellB.value.text should equal(@"None");
                    
                    
                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"None");
                    cellC.value.textColor should equal([UIColor greenColor]);
                    cellC.userInteractionEnabled should be_falsy;
                    
                    
                    PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(expectedLocationTitle);
                    cellD.value.text should equal(RPLocalizedString(@"my-address", nil));
                });
                
                it(@"should inform its delegate to update the client", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateClient:)).with(subject,client);
                });
                
            });

            context(@"When updating Project", ^{
                __block ProjectType *project;
                beforeEach(^{
                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"new-project-name"
                                                                                      uri:@"new-project-uri"];
                    [subject selectionController:nil didChooseProject:project];
                });

                it(@"should update the new project", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedClientTitle);
                    cellA.value.text should equal(@"client-name");

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedProjectTitle);
                    cellB.value.text should equal(@"new-project-name");

                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"None");
                    cellC.value.textColor should equal([UIColor yellowColor]);

                    PunchAttributeCell *cellD = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(expectedLocationTitle);
                    cellD.value.text should equal(RPLocalizedString(@"my-address", nil));
                });

                it(@"should inform its delegate to update the task", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateProject:)).with(subject,project);
                });

            });

            context(@"When updating Task", ^{
                __block TaskType *task;
                beforeEach(^{
                    task = [[TaskType alloc] initWithProjectUri:nil
                                                     taskPeriod:nil
                                                           name:@"new-task-name"
                                                            uri:@"new-task-uri"];
                    [subject selectionController:nil didChooseTask:task];
                });
                
                it(@"should update the new task", ^{
                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"new-task-name");
                });
                
                it(@"should inform its delegate to update the task", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateTask:)).with(subject,task);
                });
            });
        });

        context(@"when its a punch into project user and OEF user combination", ^{
            __block OEFType *oefType4;
            __block NSMutableArray *oefTypes;
            beforeEach(^{

                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
               oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);
                punch stub_method(@selector(client)).again().and_return(client);
                punch stub_method(@selector(project)).again().and_return(project);
                punch stub_method(@selector(task)).again().and_return(task);
                punch stub_method(@selector(activity)).again().and_return(nil);
                punch stub_method(@selector(address)).again().and_return(@"my-location");


                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
            });

            it(@"should have correct number of rows in the tableview", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(8);
            });

            it(@"should have correctly configured cells in the tableview", ^{

                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                cellA.title.text should equal(expectedClientTitle);
                cellA.value.text should equal(@"client-name");


                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                cellB.title.text should equal(expectedProjectTitle);
                cellB.value.text should equal(@"project-name");


                PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                cellC.title.text should equal(expectedTaskTitle);
                cellC.value.text should equal(@"task-name");

                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                cellD.title.text should equal(@"text 1");
                cellD.textView.text should equal(@"sample text");

                DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                cellE.title.text should equal(@"numeric 1");
                cellE.textView.text should equal(@"230.89");
                
                DynamicTextTableViewCell *cellH = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                cellH.title.text should equal(@"dropdown oef 1");
                cellH.textValueLabel.text should equal(@"some-dropdown-option-value");
                
                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                cellF.title.text should equal(@"dropdown oef 2");
                cellF.textValueLabel.text should equal(@"None");

                PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                cellG.title.text should equal(expectedLocationTitle);
                cellG.value.text should equal(RPLocalizedString(@"my-address", nil));

            });

            context(@"When updating client", ^{
                __block ClientType *client;
                beforeEach(^{
                    client = [[ClientType alloc]initWithName:@"new-client-name" uri:@"new-client-uri"];
                    [subject selectionController:nil didChooseClient:client];
                });

                it(@"should update the new client", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedClientTitle);
                    cellA.value.text should equal(@"new-client-name");

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedProjectTitle);
                    cellB.value.text should equal(@"None");


                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"None");
                    cellC.value.textColor should equal([UIColor greenColor]);
                    cellC.userInteractionEnabled should be_falsy;

                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(@"text 1");
                    cellD.textView.text should equal(@"sample text");

                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                    cellE.title.text should equal(@"numeric 1");
                    cellE.textView.text should equal(@"230.89");
                    
                    DynamicTextTableViewCell *cellH = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                    cellH.title.text should equal(@"dropdown oef 1");
                    cellH.textValueLabel.text should equal(@"some-dropdown-option-value");
                    
                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                    cellF.title.text should equal(@"dropdown oef 2");
                    cellF.textValueLabel.text should equal(@"None");
                    
                    PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                    cellG.title.text should equal(expectedLocationTitle);
                    cellG.value.text should equal(RPLocalizedString(@"my-address", nil));
                });

                it(@"should inform its delegate to update the client", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateClient:)).with(subject,client);
                });

            });

            context(@"When updating Project", ^{
                __block ProjectType *project;
                beforeEach(^{

                    project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                  isTimeAllocationAllowed:NO
                                                                            projectPeriod:nil
                                                                               clientType:nil
                                                                                     name:@"new-project-name"
                                                                                      uri:@"new-project-uri"];
                    [subject selectionController:nil didChooseProject:project];
                });

                it(@"should update the new project", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedClientTitle);
                    cellA.value.text should equal(@"client-name");

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedProjectTitle);
                    cellB.value.text should equal(@"new-project-name");

                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"None");
                    cellC.value.textColor should equal([UIColor yellowColor]);

                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(@"text 1");
                    cellD.textView.text should equal(@"sample text");

                    DynamicTextTableViewCell *cellE = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                    cellE.title.text should equal(@"numeric 1");
                    cellE.textView.text should equal(@"230.89");

                    DynamicTextTableViewCell *cellH = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                    cellH.title.text should equal(@"dropdown oef 1");
                    cellH.textValueLabel.text should equal(@"some-dropdown-option-value");
                    
                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                    cellF.title.text should equal(@"dropdown oef 2");
                    cellF.textValueLabel.text should equal(@"None");
                    
                    PunchAttributeCell *cellG = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:eighthIndexPath];
                    cellG.title.text should equal(expectedLocationTitle);
                    cellG.value.text should equal(RPLocalizedString(@"my-address", nil));
                });

                it(@"should inform its delegate to update the task", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateProject:)).with(subject,project);
                });

            });

            context(@"When updating Task", ^{
                __block TaskType *task;
                beforeEach(^{
                    task = [[TaskType alloc] initWithProjectUri:nil
                                                     taskPeriod:nil
                                                           name:@"new-task-name"
                                                            uri:@"new-task-uri"];
                    [subject selectionController:nil didChooseTask:task];
                });

                it(@"should update the new task", ^{
                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(expectedTaskTitle);
                    cellC.value.text should equal(@"new-task-name");
                });
                
                it(@"should inform its delegate to update the task", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateTask:)).with(subject,task);
                });
            });

            context(@"When updating dropdown oefTypes for a punch", ^{
                __block OEFDropDownType *oefDropDownType;
                beforeEach(^{
                    oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                    subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");
                    [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
                });

                it(@"should update the new dropdown", ^{
                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:seventhIndexPath];
                    cellF.title.text should equal(@"dropdown oef 2");
                    cellF.textValueLabel.text should equal(@"new-dropdown-name");

                });

                it(@"should inform its delegate to update the dropdown", ^{
                    OEFType *oefType5 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"new-dropdown-name" collectAtTimeOfPunch:NO disabled:YES];
                    oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType5, nil];
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDropDownOEFTypes:)).with(subject,oefTypes);
                });
                
            });
        });

        context(@"when its a punch into activities user", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
            });

            it(@"should have correct number of rows in the tableview", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(2);
            });

            it(@"should have correctly configured cells in the tableview", ^{

                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                cellA.title.text should equal(expectedActivityTitle);
                cellA.value.text should equal(@"activity-name");

                PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                cellB.title.text should equal(expectedLocationTitle);
                cellB.value.text should equal(RPLocalizedString(@"my-address", nil));

            });

            context(@"When updating activity", ^{
                __block Activity *activity;
                beforeEach(^{
                    activity = [[Activity alloc]initWithName:@"new-activity-name" uri:@"new-activity-uri"];
                    [subject selectionController:nil didChooseActivity:activity];
                });

                it(@"should update the new activity", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedActivityTitle);
                    cellA.value.text should equal(@"new-activity-name");

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(expectedLocationTitle);
                    cellB.value.text should equal(RPLocalizedString(@"my-address", nil));

                });
                
                it(@"should inform its delegate to update the client", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateActivity:)).with(subject,activity);
                });
                
            });
        });

        context(@"when its a punch into activities and OEF combination user", ^{
            __block OEFType *oefType4;
            beforeEach(^{

                punch stub_method(@selector(client)).again().and_return(nil);
                punch stub_method(@selector(project)).again().and_return(nil);
                punch stub_method(@selector(task)).again().and_return(nil);
                punch stub_method(@selector(activity)).again().and_return(activity);
                punch stub_method(@selector(address)).again().and_return(@"my-location");
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                
                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];
                
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);

                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);

                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
            });

            it(@"should have correct number of rows in the tableview", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(6);
            });

            it(@"should have correctly configured cells in the tableview", ^{

                PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                cellA.title.text should equal(expectedActivityTitle);
                cellA.value.text should equal(@"activity-name");

                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                cellB.title.text should equal(@"text 1");
                cellB.textView.text should equal(@"sample text");

                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                cellC.title.text should equal(@"numeric 1");
                cellC.textView.text should equal(@"230.89");
                
                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                cellD.title.text should equal(@"dropdown oef 1");
                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                
                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                cellF.title.text should equal(@"dropdown oef 2");
                cellF.textValueLabel.text should equal(@"None");


                PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                cellE.title.text should equal(expectedLocationTitle);
                cellE.value.text should equal(RPLocalizedString(@"my-address", nil));
                


            });

            context(@"When updating activity", ^{
                __block Activity *activity;
                beforeEach(^{
                    activity = [[Activity alloc]initWithName:@"new-activity-name" uri:@"new-activity-uri"];
                    [subject selectionController:nil didChooseActivity:activity];
                });

                it(@"should update the new activity", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                    cellA.title.text should equal(expectedActivityTitle);
                    cellA.value.text should equal(@"new-activity-name");

                    DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                    cellB.title.text should equal(@"text 1");
                    cellB.textView.text should equal(@"sample text");

                    DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellC.title.text should equal(@"numeric 1");
                    cellC.textView.text should equal(@"230.89");
                    
                    DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellD.title.text should equal(@"dropdown oef 1");
                    cellD.textValueLabel.text should equal(@"some-dropdown-option-value");
                    
                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                    cellF.title.text should equal(@"dropdown oef 2");
                    cellF.textValueLabel.text should equal(@"None");

                    PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:sixthIndexPath];
                    cellE.title.text should equal(expectedLocationTitle);
                    cellE.value.text should equal(RPLocalizedString(@"my-address", nil));



                });

                it(@"should inform its delegate to update the activity", ^{
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateActivity:)).with(subject,activity);
                });
                
            });
            
            context(@"When updating dropdown oefTypes for a punch", ^{
                __block NSMutableArray *oefTypes;
                __block OEFDropDownType *oefDropDownType;
                beforeEach(^{
                    oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                    subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");
                    [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
                });
                
                it(@"should update the new dropdown", ^{
                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                    cellF.title.text should equal(@"dropdown oef 1");
                    cellF.textValueLabel.text should equal(@"some-dropdown-option-value");
                    
                });
                
                it(@"should inform its delegate to update the dropdown", ^{
                    OEFType *oefType5 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"new-dropdown-name" collectAtTimeOfPunch:NO disabled:YES];
                    oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType5, nil];
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDropDownOEFTypes:)).with(subject,oefTypes);
                });
                
            });
        });

        context(@"when its a simple punch and OEF combination user", ^{
            __block OEFType *oefType4;
            beforeEach(^{

                punch stub_method(@selector(client)).again().and_return(nil);
                punch stub_method(@selector(project)).again().and_return(nil);
                punch stub_method(@selector(task)).again().and_return(nil);
                punch stub_method(@selector(activity)).again().and_return(nil);
                punch stub_method(@selector(address)).again().and_return(@"my-location");
                punch stub_method(@selector(address)).again().and_return(@"my-address");

                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType4, nil];

                punch stub_method(@selector(oefTypesArray)).and_return(oefTypes);

                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
            });

            it(@"should have correct number of rows in the tableview", ^{
                [subject.tableView numberOfRowsInSection:0] should equal(5);
            });

            it(@"should have correctly configured cells in the tableview", ^{

                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:firstIndexPath];
                cellB.title.text should equal(@"text 1");
                cellB.textView.text should equal(@"sample text");

                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:secondIndexPath];
                cellC.title.text should equal(@"numeric 1");
                cellC.textView.text should equal(@"230.89");

                DynamicTextTableViewCell *cellD = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                cellD.title.text should equal(@"dropdown oef 1");
                cellD.textValueLabel.text should equal(@"some-dropdown-option-value");

                DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fourthIndexPath];
                cellF.title.text should equal(@"dropdown oef 2");
                cellF.textValueLabel.text should equal(@"None");


                PunchAttributeCell *cellE = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:fifthIndexPath];
                cellE.title.text should equal(expectedLocationTitle);
                cellE.value.text should equal(RPLocalizedString(@"my-address", nil));



            });


            context(@"When updating dropdown oefTypes for a punch", ^{
                __block NSMutableArray *oefTypes;
                __block OEFDropDownType *oefDropDownType;
                beforeEach(^{
                    oefDropDownType = [[OEFDropDownType alloc]initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                    subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");
                    [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
                });

                it(@"should update the new dropdown", ^{
                    DynamicTextTableViewCell *cellF = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:thirdIndexPath];
                    cellF.title.text should equal(@"dropdown oef 1");
                    cellF.textValueLabel.text should equal(@"some-dropdown-option-value");

                });

                it(@"should inform its delegate to update the dropdown", ^{
                    OEFType *oefType5 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"new-dropdown-name" collectAtTimeOfPunch:NO disabled:YES];
                    oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, oefType5, nil];
                    delegate should have_received(@selector(punchAttributeController:didIntendToUpdateDropDownOEFTypes:)).with(subject,oefTypes);
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

                [subject setUpWithNeedLocationOnUI:NO
                                          delegate:delegate
                                          flowType:SupervisorFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];

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
        
        context(@"selectionControllerNeedsDropdownOEFRepository", ^{
            __block OEFDropDownRepository *oefDropdownRepository;
             __block DynamicTextTableViewCell *cell;
            
            beforeEach(^{
                
                oefDropdownRepository = nice_fake_for([OEFDropDownRepository class]);
                [injector bind:[OEFDropDownRepository class] toInstance:oefDropdownRepository];
                
                 punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

                
                [subject setUpWithNeedLocationOnUI:NO
                                          delegate:delegate
                                          flowType:SupervisorFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                spy_on(cell.textView);
                [cell tap];
                
                oefDropdownRepository = [subject selectionControllerNeedsOEFDropDownRepository];
                
            });
            
            it(@"should have expected oefDropdownRepository with useruri", ^{
                
                oefDropdownRepository should have_received(@selector(setUpWithDropDownOEFUri:userUri:)).with(@"oef-uri-1", @"user-uri");
            });
        });

    });

    describe(@"As a <DynamicTextTableViewCellDelegate>", ^{

        __block DynamicTextTableViewCell *dynamicTextTableViewCell;

        beforeEach(^{
            punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
            punch stub_method(@selector(address)).again().and_return(@"my-address");
            
            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *tempOEFTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
            punch stub_method(@selector(oefTypesArray)).and_return(tempOEFTypesArray);
            [subject setUpWithNeedLocationOnUI:YES
                                      delegate:delegate
                                      flowType:UserFlowContext
                                       userUri:nil
                                         punch:punch
                      punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
            [subject view];
            [subject.tableView layoutIfNeeded];
            dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

        });

        context(@"dynamicTextTableViewCell:didUpdateTextView:", ^{
            beforeEach(^{
                [dynamicTextTableViewCell.textView setText:@"testing..."];
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
            });


            it(@"should update table content size", ^{
                delegate should have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });

            it(@"should be scrolling the scrollview", ^{
                delegate should have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
            });
        });
        
        context(@"dynamicTextTableViewCell:didBeginEditingTextView:", ^{

            context(@"when value is not present", ^{
                beforeEach(^{
                    [subject dynamicTextTableViewCell:dynamicTextTableViewCell didBeginEditingTextView:dynamicTextTableViewCell.textView];
                });

                it(@"should set clear textview placeholder text", ^{
                    dynamicTextTableViewCell.textView.text should equal(@"");
                });

                it(@"should be scrolling the scrollview", ^{
                    delegate should have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
                });


            });

            context(@"when value is  present", ^{
                beforeEach(^{
                    dynamicTextTableViewCell.textView.text = @"testing....";
                    [subject dynamicTextTableViewCell:dynamicTextTableViewCell didBeginEditingTextView:dynamicTextTableViewCell.textView];
                });

                it(@"should not set clear textview placeholder text", ^{
                    dynamicTextTableViewCell.textView.text should equal(@"testing....");
                });

                it(@"should be scrolling the scrollview", ^{
                    delegate should have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
                });
            });

            context(@"when OEFType is disabled", ^{

                beforeEach(^{
                    OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:YES];
                    punch stub_method(@selector(oefTypesArray)).again().and_return(@[oefType]);
                    spy_on(dynamicTextTableViewCell.textView);
                    [subject dynamicTextTableViewCell:dynamicTextTableViewCell didBeginEditingTextView:dynamicTextTableViewCell.textView];
                });
                afterEach(^{
                    stop_spying_on(dynamicTextTableViewCell.textView);
                });

                it(@"should show the correct validation message to the user", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    alertView.message should equal(RPLocalizedString(@"This field has been disabled. Contact your Administrator for more details.", @""));
                });

                it(@"textview should not be editable", ^{
                    dynamicTextTableViewCell.textView should have_received(@selector(setEditable:)).with(NO);
                });

                it(@"should set visible of alert view flag to YES", ^{
                    subject.alertViewVisible should be_truthy;
                });

                it(@"dismissing alert view", ^{
                    UIAlertView *alertView = [UIAlertView currentAlertView];
                    [alertView dismissWithOkButton];
                    subject.alertViewVisible should be_falsy;

                });

            });
        });

        context(@"dynamicTextTableViewCell:didEndEditingTextView:", ^{
            context(@"when value is nil", ^{
                beforeEach(^{
                    dynamicTextTableViewCell.textView.text = nil;
                    [subject dynamicTextTableViewCell:dynamicTextTableViewCell didEndEditingTextView:dynamicTextTableViewCell.textView];
                });

                it(@"should set textview placeholder text", ^{
                    dynamicTextTableViewCell.textView.text should equal(RPLocalizedString(@"None", @""));
                });

                it(@"correct punch value for oef should be configured", ^{
                    subject.punch.oefTypesArray.count should equal(1);
                    OEFType *oeftType =  subject.punch.oefTypesArray[0];
                    oeftType.oefTextValue should equal(@"");
                });

                it(@"should update parent view with default activity", ^{
                    subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateTextOrNumericOEFTypes:)).with(subject, subject.punch.oefTypesArray);
                });

            });

            context(@"when value is empty string", ^{
                beforeEach(^{
                    dynamicTextTableViewCell.textView.text = @"";
                    [subject dynamicTextTableViewCell:dynamicTextTableViewCell didEndEditingTextView:dynamicTextTableViewCell.textView];
                });

                it(@"should set textview placeholder text", ^{
                    dynamicTextTableViewCell.textView.text should equal(RPLocalizedString(@"None", @""));
                });

                it(@"correct punch value for oef should be configured", ^{
                    subject.punch.oefTypesArray.count should equal(1);
                    OEFType *oeftType =  subject.punch.oefTypesArray[0];
                    oeftType.oefTextValue should equal(@"");
                });

                it(@"should update parent view with default activity", ^{
                    subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateTextOrNumericOEFTypes:)).with(subject, subject.punch.oefTypesArray);
                });
                
            });


            context(@"when value is  present", ^{
                beforeEach(^{
                    dynamicTextTableViewCell.textView.text = @"testing....";
                    [subject dynamicTextTableViewCell:dynamicTextTableViewCell didEndEditingTextView:dynamicTextTableViewCell.textView];
                });
                
                it(@"should not set clear textview placeholder text", ^{
                    dynamicTextTableViewCell.textView.text should equal(@"testing....");
                });

                it(@"correct punch value for oef should be configured", ^{
                    subject.punch.oefTypesArray.count should equal(1);
                    OEFType *oeftType =  subject.punch.oefTypesArray[0];
                    oeftType.oefTextValue should equal(@"testing....");
                });

                it(@"should update parent view with default activity", ^{
                    subject.delegate should have_received(@selector(punchAttributeController:didIntendToUpdateTextOrNumericOEFTypes:)).with(subject, subject.punch.oefTypesArray);
                });
            });
            
        });
        
    });
    
    describe(@"As a <DynamicTextTableViewCellDelegate> OEF validation", ^{
        
        __block DynamicTextTableViewCell *dynamicTextTableViewCell;
        
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with integer", ^{
            __block NSMutableArray *oefTypeArr;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                
                oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypeArr);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
                [subject.tableView layoutIfNeeded];
                
                dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                [dynamicTextTableViewCell.textView setText:oefType2.oefNumericValue];
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
            });
            
            it(@"should present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                
                alert.message should equal(localizedString);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
            
            it(@"should update table content size", ^{
                delegate should_not have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });
            
            it(@"should be scrolling the scrollview", ^{
                delegate should_not have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
            });

            it(@"should set correct textview tag", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
            });

            it(@"textview should have received the first responder", ^{
                UITextView *textView_ = [subject.tableView viewWithTag:dynamicTextTableViewCell.textView.tag];
                spy_on(textView_);
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
                [alert dismissWithOkButton];
                textView_ should have_received(@selector(becomeFirstResponder));
                textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
            });

            it(@"should not display alert when already an alert is present", ^{
                [UIAlertView reset];
                subject stub_method(@selector(alertViewVisible)).and_return(NO);
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });
        });

        context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with wholenumber within range and decimal exceeding range", ^{
            __block NSMutableArray *oefTypeArr;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                
                oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypeArr);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
                [subject.tableView layoutIfNeeded];
                
                dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                [dynamicTextTableViewCell.textView setText:oefType2.oefNumericValue];
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
            });
            
            it(@"should present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                
                alert.message should equal(localizedString);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
            
            it(@"should update table content size", ^{
                delegate should_not have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });
            
            it(@"should be scrolling the scrollview", ^{
                delegate should_not have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
            });

            it(@"should set correct textview tag", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
            });

            it(@"textview should have received the first responder", ^{
                UITextView *textView_ = [subject.tableView viewWithTag:dynamicTextTableViewCell.textView.tag];
                spy_on(textView_);
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
                [alert dismissWithOkButton];
                textView_ should have_received(@selector(becomeFirstResponder));
                textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
            });

            it(@"should not display alert when already an alert is present", ^{
                [UIAlertView reset];
                subject stub_method(@selector(alertViewVisible)).and_return(NO);
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with negative integer", ^{
            __block NSMutableArray *oefTypeArr;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                
                oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypeArr);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
                [subject.tableView layoutIfNeeded];
                
                dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                [dynamicTextTableViewCell.textView setText:oefType2.oefNumericValue];
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
            });
            
            it(@"should present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                
                alert.message should equal(localizedString);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
            
            it(@"should update table content size", ^{
                delegate should_not have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });
            
            it(@"should be scrolling the scrollview", ^{
                delegate should_not have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
            });

            it(@"should set correct textview tag", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
            });

            it(@"textview should have received the first responder", ^{
                UITextView *textView_ = [subject.tableView viewWithTag:dynamicTextTableViewCell.textView.tag];
                spy_on(textView_);
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
                [alert dismissWithOkButton];
                textView_ should have_received(@selector(becomeFirstResponder));
                textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
            });

            it(@"should not display alert when already an alert is present", ^{
                [UIAlertView reset];
                subject stub_method(@selector(alertViewVisible)).and_return(NO);
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with negative number within range and decimal exceeding range", ^{
            __block NSMutableArray *oefTypeArr;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                
                oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypeArr);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
                [subject.tableView layoutIfNeeded];
                
                dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                
                [dynamicTextTableViewCell.textView setText:oefType2.oefNumericValue];
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
            });
            
            it(@"should present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                
                alert.message should equal(localizedString);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
            
            it(@"should update table content size", ^{
                delegate should_not have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });
            
            it(@"should be scrolling the scrollview", ^{
                delegate should_not have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
            });

            it(@"should set correct textview tag", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
            });

            it(@"textview should have received the first responder", ^{
                UITextView *textView_ = [subject.tableView viewWithTag:dynamicTextTableViewCell.textView.tag];
                spy_on(textView_);
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1001);
                [alert dismissWithOkButton];
                textView_ should have_received(@selector(becomeFirstResponder));
                textView_.keyboardType should equal(UIKeyboardTypeDecimalPad);
            });

            it(@"should not display alert when already an alert is present", ^{
                [UIAlertView reset];
                subject stub_method(@selector(alertViewVisible)).and_return(NO);
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: - validate Text OEF when Exceeding limit", ^{
            __block NSMutableArray *oefTypeArr;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punch stub_method(@selector(address)).again().and_return(@"my-address");
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1pqrstubwxyz" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                
                oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypeArr);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
                [subject.tableView layoutIfNeeded];
                
                dynamicTextTableViewCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                [dynamicTextTableViewCell.textView setText:oefType1.oefTextValue];
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
            });
            
            it(@"should present the alert to the user", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFTextFieldValueLimitExceededError, nil), @"255"];
                
                alert.message should equal(localizedString);
                [alert buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @"OK"));
            });
            
            it(@"should update table content size", ^{
                delegate should_not have_received(@selector(punchAttributeController:didUpdateTableViewWithHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });
            
            it(@"should be scrolling the scrollview", ^{
                delegate should_not have_received(@selector(punchAttributeController:didScrolltoSubview:)).with(subject,dynamicTextTableViewCell.textView);
            });

            it(@"should set correct textview tag", ^{
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1000);
            });

            it(@"textview should have received the first responder", ^{
                UITextView *textView_ = [subject.tableView viewWithTag:dynamicTextTableViewCell.textView.tag];
                spy_on(textView_);
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should_not be_nil;
                dynamicTextTableViewCell.textView.tag should equal(1000);
                [alert dismissWithOkButton];
                textView_ should have_received(@selector(becomeFirstResponder));
                textView_.keyboardType should equal(UIKeyboardTypeDefault);
            });

            it(@"should not display alert when already an alert is present", ^{
                [UIAlertView reset];
                subject stub_method(@selector(alertViewVisible)).and_return(NO);
                [subject dynamicTextTableViewCell:dynamicTextTableViewCell didUpdateTextView:dynamicTextTableViewCell.textView];
                UIAlertView *alert = [UIAlertView currentAlertView];
                alert should be_nil;
            });
        });
    });
    
    describe(@"Tapping on DynamicTextTableViewCell", ^{
        __block DynamicTextTableViewCell *cell;
        __block UINavigationController *navigationController;
        __block PunchCardObject *punchCardObject;
        
        beforeEach(^{
            
            punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
            
            punchCardObject = [[PunchCardObject alloc]
                               initWithClientType:punch.client
                               projectType:punch.project
                               oefTypesArray:punch.oefTypesArray
                               breakType:punch.breakType
                               taskType:punch.task
                               activity:punch.activity
                               uri:nil];
            
            
        });
        
        context(@"when tapping on text/numeric oef", ^{
            beforeEach(^{
                
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                spy_on(navigationController);

                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                spy_on(cell.textView);
                [cell tap];
                
            });
            
            it(@"should set focus on the text view", ^{
                cell.textView should have_received(@selector(becomeFirstResponder));
            });
        });
        
        context(@"when tapping on dropdown oef and When Punch into Activity user", ^{
            beforeEach(^{
                
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                
                
                spy_on(navigationController);
                punchCardObject = [[PunchCardObject alloc]
                                   initWithClientType:nil
                                   projectType:nil
                                   oefTypesArray:punch.oefTypesArray
                                   breakType:punch.breakType
                                   taskType:nil
                                   activity:punch.activity
                                   uri:nil];
                

                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                spy_on(cell.textView);
                [cell tap];
                
            });
            
            it(@"should navigate when dropdown oef cell is clicked", ^{
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;

            });
        });
        
        context(@"when tapping on dropdown oef and When Punch into Project user", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                spy_on(navigationController);
                punchCardObject = [[PunchCardObject alloc]
                                   initWithClientType:punch.client
                                   projectType:punch.project
                                   oefTypesArray:punch.oefTypesArray
                                   breakType:punch.breakType
                                   taskType:punch.task
                                   activity:nil
                                   uri:nil];
                

                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                [cell tap];
                
            });
            
            it(@"should navigate when dropdown oef cell is clicked", ^{
                selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                navigationController.navigationBar.hidden should be_falsy;
                
            });
        });
        
        context(@"when OEFType is disabled and when Punch into Activity User", ^{
            __block OEFType *oefType4;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];

                 oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType4, nil];
                punch stub_method(@selector(oefTypesArray)).again().and_return(oefTypes);
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                [cell tap];
            });
            
            it(@"should show the correct validation message to the user", ^{
                UIAlertView *alertView = [UIAlertView currentAlertView];
                alertView.message should equal(RPLocalizedString(@"This field has been disabled. Contact your Administrator for more details.", @""));
            });
            
            it(@"should set visible of alert view flag to YES", ^{
                subject.alertViewVisible should be_truthy;
            });
            
            it(@"dismissing alert view", ^{
                UIAlertView *alertView = [UIAlertView currentAlertView];
                [alertView dismissWithOkButton];
                subject.alertViewVisible should be_falsy;
                
            });
            
        });
        
        context(@"when OEFType is disabled and when Punch into Project User", ^{
            __block OEFType *oefType4;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                
                [subject setUpWithNeedLocationOnUI:YES
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:@"user-uri"
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                
                oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-2" dropdownOptionValue:@"" collectAtTimeOfPunch:NO disabled:YES];
                NSMutableArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType4, nil];
                punch stub_method(@selector(oefTypesArray)).again().and_return(oefTypes);
                subject.view should_not be_nil;
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
                [cell tap];
            });
            
            it(@"should show the correct validation message to the user", ^{
                UIAlertView *alertView = [UIAlertView currentAlertView];
                alertView.message should equal(RPLocalizedString(@"This field has been disabled. Contact your Administrator for more details.", @""));
            });
            
            it(@"should set visible of alert view flag to YES", ^{
                subject.alertViewVisible should be_truthy;
            });
            
            it(@"dismissing alert view", ^{
                UIAlertView *alertView = [UIAlertView currentAlertView];
                [alertView dismissWithOkButton];
                subject.alertViewVisible should be_falsy;
                
            });
            
        });
    });

    describe(@"Displaying Correct PlaceHolders For OEF's", ^{

        beforeEach(^{
            OEFType *oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            OEFType *oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            OEFType *oefTypeC = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            punch stub_method(@selector(oefTypesArray)).and_return(@[oefTypeA,oefTypeB,oefTypeC]);

        });

        context(@"While Adding a manual punch", ^{
            beforeEach(^{
                [subject setUpWithNeedLocationOnUI:NO
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeADD];
                [subject view];
            });

            it(@"should have correctly styled placeholders", ^{
                DynamicTextTableViewCell *cellA = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellA.title.text should equal(@"text 1");
                cellA.textView.text should equal(RPLocalizedString(@"Enter Text", @""));

                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellB.title.text should equal(@"numeric 1");
                cellB.textView.text should equal(RPLocalizedString(@"Enter Number", @""));

                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellC.title.text should equal(@"dropdown oef 1");
                cellC.textView.text should equal(RPLocalizedString(@"Select", @""));
            });


        });
        context(@"While Editing a manual punch", ^{
            beforeEach(^{
                [subject setUpWithNeedLocationOnUI:NO
                                          delegate:delegate
                                          flowType:UserFlowContext
                                           userUri:nil
                                             punch:punch
                          punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                [subject view];
            });

            it(@"should have correctly styled placeholders", ^{
                DynamicTextTableViewCell *cellA = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cellA.title.text should equal(@"text 1");
                cellA.textView.text should equal(RPLocalizedString(@"None", @""));

                DynamicTextTableViewCell *cellB = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cellB.title.text should equal(@"numeric 1");
                cellB.textView.text should equal(RPLocalizedString(@"None", @""));

                DynamicTextTableViewCell *cellC = (DynamicTextTableViewCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                cellC.title.text should equal(@"dropdown oef 1");
                cellC.textView.text should equal(RPLocalizedString(@"None", @""));
            });
            
            
        });

    });

    describe(@"Displaying Correct PlaceHolders For Activities or Project/Clients", ^{

        context(@"Punch Into Activities", ^{
            beforeEach(^{
                Activity *activityA = nice_fake_for([Activity class]);
                punch stub_method(@selector(client)).again().and_return(nil);
                punch stub_method(@selector(project)).again().and_return(nil);
                punch stub_method(@selector(task)).again().and_return(nil);
                punch stub_method(@selector(activity)).again().and_return(activityA);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                
            });

            context(@"While Adding a manual punch", ^{
                beforeEach(^{
                    [subject setUpWithNeedLocationOnUI:NO
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeADD];
                    [subject view];
                });

                it(@"should have correctly styled placeholders", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Activity", nil)]);
                    cellA.value.text should equal(RPLocalizedString(@"Select",@""));
                });


            });
            context(@"While Editing a manual punch", ^{
                beforeEach(^{
                    [subject setUpWithNeedLocationOnUI:NO
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                    [subject view];
                });

                it(@"should have correctly styled placeholders", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Activity", nil)]);
                    cellA.value.text should equal(RPLocalizedString(@"None",@""));
                });
                
                
            });
        });

        context(@"Punch Into Projects", ^{
            beforeEach(^{
                ClientType *clientA = nice_fake_for([ClientType class]);
                ProjectType *projectA = nice_fake_for([ProjectType class]);
                TaskType *taskA = nice_fake_for([TaskType class]);
                punch stub_method(@selector(client)).again().and_return(clientA);
                punch stub_method(@selector(project)).again().and_return(projectA);
                punch stub_method(@selector(task)).again().and_return(taskA);
                punch stub_method(@selector(activity)).again().and_return(nil);
                astroClientPermissionStorage stub_method(@selector(userHasClientPermission)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(NO);

            });

            context(@"While Adding a manual punch", ^{
                beforeEach(^{
                    [subject setUpWithNeedLocationOnUI:NO
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeADD];
                    [subject view];
                });

                it(@"should have correctly styled placeholders", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Client", nil)]);
                    cellA.value.text should equal(RPLocalizedString(@"Select",@""));

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Project", nil)]);
                    cellB.value.text should equal(RPLocalizedString(@"Select",@""));

                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Task", nil)]);
                    cellC.value.text should equal(RPLocalizedString(@"Select",@""));
                });


            });
            context(@"While Editing a manual punch", ^{
                beforeEach(^{
                    [subject setUpWithNeedLocationOnUI:NO
                                              delegate:delegate
                                              flowType:UserFlowContext
                                               userUri:nil
                                                 punch:punch
                              punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                    [subject view];
                });

                it(@"should have correctly styled placeholders", ^{
                    PunchAttributeCell *cellA = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellA.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Client", nil)]);
                    cellA.value.text should equal(RPLocalizedString(@"None",@""));

                    PunchAttributeCell *cellB = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    cellB.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Project", nil)]);
                    cellB.value.text should equal(RPLocalizedString(@"None",@""));

                    PunchAttributeCell *cellC = (PunchAttributeCell *)[subject tableView:subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    cellC.title.text should equal([NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Task", nil)]);
                    cellC.value.text should equal(RPLocalizedString(@"None",@""));
                });
                
                
            });
        });
        
    });

});

SPEC_END
