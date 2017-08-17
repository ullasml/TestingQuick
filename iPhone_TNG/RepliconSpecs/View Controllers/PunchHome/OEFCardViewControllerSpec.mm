#import <Cedar/Cedar.h>
#import "OEFCardViewController.h"
#import "Constants.h"
#import "PunchCardObject.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "PunchCardStylist.h"
#import "UIControl+Spec.h"
#import "PunchValidator.h"
#import "UserPermissionsStorage.h"
#import "UserSession.h"
#import "DefaultActivityStorage.h"
#import "OEFType.h"
#import "UITableViewCell+Spec.h"
#import "Theme.h"
#import "ButtonStylist.h"
#import "BreakTypeRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "UIActionSheet+Spec.h"
#import "UIAlertView+Spec.h"
#import "ClientRepository.h"
#import "ProjectRepository.h"
#import "TaskRepository.h"
#import "ActivityRepository.h"
#import "TimeLinePunchesStorage.h"
#import "LocalPunch.h"
#import "OEFDropDownRepository.h"
#import "GUIDProvider.h"
#import "OEFDropDownType.h"
#import "SelectionController.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFCardViewControllerSpec)

describe(@"OEFCardViewController", ^{
    __block OEFCardViewController  <CedarDouble>*subject;
    __block id <BSInjector,BSBinder> injector;
    __block PunchCardObject *punchCardObject;
    __block PunchCardStylist *punchCardStylist;
    __block id <OEFCardViewControllerDelegate> delegate;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block DefaultActivityStorage *defaultActivityStorage;
    __block TimeLinePunchesStorage *timeLinePunchesStorage;
    __block BreakTypeRepository *breakTypeRepository;
    __block id <UserSession> userSession;
    __block NSMutableArray *oefTypesArray;
    __block OEFType *oefType1;
    __block OEFType *oefType2;
    __block OEFType *oefType3;
    __block id <Theme> theme;
    __block ButtonStylist *buttonStylist;
    __block KSDeferred *breakTypeDeferred;
    __block UINavigationController *navigationController;
    __block SelectionController <CedarDouble> *selectionController;
    __block GUIDProvider *guidProvider;
    
    
    beforeEach(^{

        injector = [InjectorProvider injector];
        
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
        
        defaultActivityStorage = nice_fake_for([DefaultActivityStorage class]);
        [injector bind:[DefaultActivityStorage class] toInstance:defaultActivityStorage];
        
        timeLinePunchesStorage = nice_fake_for([TimeLinePunchesStorage class]);
        [injector bind:[TimeLinePunchesStorage class] toInstance:timeLinePunchesStorage];
        
        punchCardStylist = nice_fake_for([PunchCardStylist class]);
        [injector bind:[PunchCardStylist class] toInstance:punchCardStylist];
        
        guidProvider = nice_fake_for([GUIDProvider class]);
        [injector bind:[GUIDProvider class] toInstance:guidProvider];
        
        guidProvider stub_method(@selector(guid)).and_return(@"guid-A");

        breakTypeDeferred = [[KSDeferred alloc] init];
        breakTypeRepository = nice_fake_for([BreakTypeRepository class]);
        breakTypeRepository stub_method(@selector(fetchBreakTypesForUser:)).and_return(breakTypeDeferred.promise);
        [injector bind:[BreakTypeRepository class] toInstance:breakTypeRepository];
        
        delegate = nice_fake_for(@protocol(OEFCardViewControllerDelegate));
        
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        [injector bind:@protocol(UserSession) toInstance:userSession];
        
        buttonStylist = nice_fake_for([ButtonStylist class]);
        [injector bind:[ButtonStylist class] toInstance:buttonStylist];
        
        selectionController = (id) [[SelectionController alloc] initWithProjectStorage:NULL expenseProjectStorage:NULL timerProvider:nil userDefaults:nil theme:nil];
        [injector bind:InjectorKeySelectionControllerForPunchModule toInstance:selectionController];

        subject = [injector getInstance:[OEFCardViewController class]];
        spy_on(subject);
        
        theme = subject.theme;
        spy_on(theme);

        oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
        oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

        
        punchCardObject = [[PunchCardObject alloc]
                                            initWithClientType:nil
                                                   projectType:nil
                                                 oefTypesArray:nil
                                                     breakType:nil
                                                      taskType:nil
                                                      activity:nil
                                                           uri:nil];
        
        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypePunchOut oefTypesArray:oefTypesArray];
        
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(selectionController);
    });
    
    beforeEach(^{
        
        theme stub_method(@selector(regularButtonFont)).and_return([UIFont systemFontOfSize:15.0f]);
        theme stub_method(@selector(destructiveButtonTitleColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(punchOutButtonBackgroundColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(oefCardPunchOutButtonBorderColor)).and_return([UIColor brownColor]);
        theme stub_method(@selector(selectionCellValueFont)).and_return([UIFont systemFontOfSize:17]);
        theme stub_method(@selector(selectionCellFont)).and_return([UIFont systemFontOfSize:12]);
        theme stub_method(@selector(selectionCellNameFontColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(selectionCellValueFontColor)).and_return([UIColor magentaColor]);
        theme stub_method(@selector(selectionCellValueDisabledFontColor)).and_return([UIColor grayColor]);
        theme stub_method(@selector(oefCardCancelButtonTitleColor)).and_return([UIColor blackColor]);
        theme stub_method(@selector(oefCardCancelButtonBackgroundColor)).and_return([UIColor grayColor]);
        theme stub_method(@selector(takeBreakButtonTitleColor)).and_return([UIColor grayColor]);
        theme stub_method(@selector(takeBreakButtonBackgroundColor)).and_return([UIColor blackColor]);
        theme stub_method(@selector(transferOEFCardButtonBackgroundColor)).and_return([UIColor blackColor]);
        theme stub_method(@selector(transferOEFCardButtonTitleColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(transferOEFCardBorderColor)).and_return([UIColor brownColor]);
        theme stub_method(@selector(oefCardResumeWorkButtonBackgroundColor)).and_return([UIColor blackColor]);
        theme stub_method(@selector(oefCardResumeWorkButtonTitleColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(oefCardResumeWorkButtonBorderColor)).and_return([UIColor brownColor]);
        theme stub_method(@selector(oefCardTableCellBackgroundColor)).and_return([UIColor clearColor]);
    });
    
    describe(@"Styling the views", ^{
        
        context(@"When OEFCard with out action", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypePunchOut
                             oefTypesArray:oefTypesArray];
                [subject view];
            });
            
            it(@"should style the card with border correctly", ^{
                punchCardStylist should have_received(@selector(styleBorderForOEFView:)).with(subject.view);
            });
            
            it(@"should style clock out button", ^{
                buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.punchActionButton, @"Clock Out", [UIColor redColor], [UIColor greenColor], [UIColor brownColor]);
            });
            
            it(@"should style cancel button", ^{
                NSMutableAttributedString *cancelString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(@"Cancel", nil)];
                [cancelString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [cancelString length])];
                subject.cancelButton.backgroundColor should equal([UIColor grayColor]);
                subject.cancelButton.currentAttributedTitle should equal(cancelString);
            });

        });
        
        context(@"When OEFCard with break action", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeStartBreak
                             oefTypesArray:oefTypesArray];
                [subject view];
            });
            
            it(@"should style the card with border correctly", ^{
                punchCardStylist should have_received(@selector(styleBorderForOEFView:)).with(subject.view);
            });
            
            it(@"should style clock out button", ^{
                buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.punchActionButton, @"Take a Break", [UIColor grayColor], [UIColor blackColor], [UIColor brownColor]);
            });
            
            it(@"should style cancel button", ^{
                NSMutableAttributedString *cancelString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(@"Cancel", nil)];
                [cancelString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [cancelString length])];
                subject.cancelButton.backgroundColor should equal([UIColor grayColor]);
                subject.cancelButton.currentAttributedTitle should equal(cancelString);
            });
            
        });
        
        context(@"When OEFCard with trasnfer action", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeTransfer
                             oefTypesArray:oefTypesArray];
                [subject view];
            });
            
            it(@"should style the card with border correctly", ^{
                punchCardStylist should have_received(@selector(styleBorderForOEFView:)).with(subject.view);
            });
            
            it(@"should style clock out button", ^{
                buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.punchActionButton, @"Transfer", [UIColor redColor], [UIColor blackColor], [UIColor brownColor]);
            });
            
            it(@"should style cancel button", ^{
                NSMutableAttributedString *cancelString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(@"Cancel", nil)];
                [cancelString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [cancelString length])];
                subject.cancelButton.backgroundColor should equal([UIColor grayColor]);
                subject.cancelButton.currentAttributedTitle should equal(cancelString);
            });
            
        });
        
        context(@"When OEFCard with resume work action", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeResumeWork
                             oefTypesArray:oefTypesArray];
                [subject view];
            });
            
            it(@"should style the card with border correctly", ^{
                punchCardStylist should have_received(@selector(styleBorderForOEFView:)).with(subject.view);
            });
            
            it(@"should style clock out button", ^{
                buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.punchActionButton, @"Resume Work", [UIColor redColor], [UIColor blackColor], [UIColor brownColor]);
            });
            
            it(@"should style cancel button", ^{
                NSMutableAttributedString *cancelString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(@"Cancel", nil)];
                [cancelString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [cancelString length])];
                subject.cancelButton.backgroundColor should equal([UIColor grayColor]);
                subject.cancelButton.currentAttributedTitle should equal(cancelString);
            });
            
        });
    });

    describe(@"When the view loads", ^{
        __block NSIndexPath *firstRowIndexPath;
        __block NSIndexPath *secondRowIndexPath;
        __block NSIndexPath *thirdRowIndexPath;
        __block NSIndexPath *fourRowIndexPath;
        
        beforeEach(^{
            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            fourRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        });

        context(@"PunchActionTypePunchOut", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypePunchOut
                             oefTypesArray:oefTypesArray];
                
                [subject view];
                [subject.tableView layoutIfNeeded];
            });
            
            it(@"should have a correct number of section and rows in tableview", ^{
                subject.tableView.numberOfSections should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(3);
            });
            
            it(@"should style the cells correctly", ^{
                DynamicTextTableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                
                cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell.title.font should equal([UIFont systemFontOfSize:12]);
                cell.textView.font should equal([UIFont systemFontOfSize:17]);
                cell.title.textColor should equal([UIColor orangeColor]);
                cell.textView.textColor should equal([UIColor magentaColor]);
                cell.backgroundColor should equal([UIColor clearColor]);
            });
            
            it(@"should setup the cells correctly", ^{
                 DynamicTextTableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                 firstCell should be_instance_of([DynamicTextTableViewCell class]);
                 firstCell.title.text should equal(oefType1.oefName);
                 firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                 
                 
                 DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                 secondCell should be_instance_of([DynamicTextTableViewCell class]);
                 secondCell.title.text should equal(oefType2.oefName);
                 secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                
                DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                thirdCell.title.text should equal(oefType3.oefName);
                thirdCell.textValueLabel.text should equal(@"some-dropdown-option-value");

            });
        });
        
        context(@"PunchActionTypeStartBreak", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeStartBreak
                             oefTypesArray:oefTypesArray];
                
                [subject view];
                [subject.tableView layoutIfNeeded];
            });
            
            it(@"should have a correct number of section and rows in tableview", ^{
                subject.tableView.numberOfSections should equal(1);
                [subject.tableView numberOfRowsInSection:0] should equal(4);
            });
            
            it(@"should style the cells correctly", ^{
                UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                cell.textLabel.textColor should equal([UIColor orangeColor]);
                cell.backgroundColor should equal([UIColor clearColor]);
                
                DynamicTextTableViewCell *oefCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                oefCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                oefCell.title.font should equal([UIFont systemFontOfSize:12]);
                oefCell.textView.font should equal([UIFont systemFontOfSize:17]);
                oefCell.title.textColor should equal([UIColor orangeColor]);
                oefCell.textView.textColor should equal([UIColor magentaColor]);
                oefCell.backgroundColor should equal([UIColor clearColor]);
            });
            
            it(@"should setup the cells correctly", ^{
                UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                firstCell should be_instance_of([UITableViewCell class]);
                firstCell.textLabel.text should equal(RPLocalizedString(@"Break Type", @""));
                firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", @""));

                DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                secondCell should be_instance_of([DynamicTextTableViewCell class]);
                secondCell.title.text should equal(oefType1.oefName);
                secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                
                
                DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                thirdCell.title.text should equal(oefType2.oefName);
                thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                
                DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourRowIndexPath];
                fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                fourthCell.title.text should equal(oefType3.oefName);
                fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                
            });
        });
        
        context(@"As a punch into activities flow", ^{
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
                        
                        Activity *activity = [[Activity alloc] initWithName:nil uri:nil];
                        
                        punchCardObjLocalInstance = [[PunchCardObject alloc] initWithClientType:nil
                                                                                    projectType:nil
                                                                                  oefTypesArray:nil
                                                                                      breakType:nil
                                                                                       taskType:nil
                                                                                       activity:activity
                                                                                            uri:nil];
                        
                        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                                        
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        cell should be_instance_of([UITableViewCell class]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Activity", nil));
                        cell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        cell.backgroundColor should equal([UIColor clearColor]);
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                        secondCell.backgroundColor should equal([UIColor clearColor]);
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        thirdCell.title.textColor should equal([UIColor orangeColor]);
                        thirdCell.textView.textColor should equal([UIColor magentaColor]);
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                        thirdCell.subviews[0].subviews[0] should equal(thirdCell.textView);
                        thirdCell.subviews[0].subviews[1] should equal(thirdCell.title);
                        thirdCell.backgroundColor should equal([UIColor clearColor]);

                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType3.oefName);
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                        fourthCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        fourthCell.title.font should equal([UIFont systemFontOfSize:12]);
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        fourthCell.title.textColor should equal([UIColor orangeColor]);
                        fourthCell.textView.textColor should equal([UIColor magentaColor]);
                        fourthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        fourthCell.subviews[0].subviews[0] should equal(fourthCell.title);
                        fourthCell.subviews[0].subviews[1] should equal(fourthCell.textValueLabel);
                        fourthCell.backgroundColor should equal([UIColor clearColor]);
                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ActivitySelection,punchCardObjLocalInstance,subject);
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:fourRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
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
                        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        cell.backgroundColor should equal([UIColor clearColor]);
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                        secondCell.backgroundColor should equal([UIColor clearColor]);
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        thirdCell.title.textColor should equal([UIColor orangeColor]);
                        thirdCell.textView.textColor should equal([UIColor magentaColor]);
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                        thirdCell.subviews[0].subviews[0] should equal(thirdCell.textView);
                        thirdCell.subviews[0].subviews[1] should equal(thirdCell.title);
                        thirdCell.backgroundColor should equal([UIColor clearColor]);

                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType3.oefName);
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                        fourthCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        fourthCell.title.font should equal([UIFont systemFontOfSize:12]);
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        fourthCell.title.textColor should equal([UIColor orangeColor]);
                        fourthCell.textView.textColor should equal([UIColor magentaColor]);
                        fourthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        fourthCell.subviews[0].subviews[0] should equal(fourthCell.title);
                        fourthCell.subviews[0].subviews[1] should equal(fourthCell.textValueLabel);
                        fourthCell.backgroundColor should equal([UIColor clearColor]);
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
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(@"dropdown oef 1");
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
                
                context(@"When user has default activity and working on default activity", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    
                    
                    beforeEach(^{
                        Activity *activity = [[Activity alloc] initWithName:@"default-activity" uri:@"default-uri"];
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];

                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);

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
                        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                        
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(@"text 1");
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(@"numeric 1");
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(@"dropdown oef 1");
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
                
                context(@"When user don't have default activity and working on some other activity", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    
                    beforeEach(^{
                        Activity *activity = [[Activity alloc] initWithName:@"name-activity" uri:@"uri-uri"];
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                        
                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                        
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(@"text 1");
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(@"numeric 1");
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(@"dropdown oef 1");
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
                
                context(@"When user has default activity and working on some other activity", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    
                    
                    beforeEach(^{
                        Activity *activity = [[Activity alloc] initWithName:@"default-activity" uri:@"default-uri"];
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                        
                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        
                        NSDictionary *detailsDict = @{@"default_activity_name": @"default-activity",
                                                      @"default_activity_uri": @"default-uri",
                                                      };
                        
                        defaultActivityStorage stub_method(@selector(defaultActivityDetails)).and_return(detailsDict);
                        
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                        
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(@"text 1");
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(@"numeric 1");
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(@"dropdown oef 1");
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
                
                context(@"When user currently on break and before break user has punch in", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    
                    
                    beforeEach(^{
                        Activity *activity = [[Activity alloc] initWithName:@"name-activity" uri:@"uri-uri"];
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                        
                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                        fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                        fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                        [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType1.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                        secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        secondCell.title.textColor should equal([UIColor orangeColor]);
                        secondCell.textView.textColor should equal([UIColor magentaColor]);
                        secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                        secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                        
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType2.oefName);
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                        thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                        
                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(@"text 1");
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        
                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(@"numeric 1");
                        thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(@"dropdown oef 1");
                        fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");

                    });
                    
                    it(@"should navigate when activity cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                    });
                });
                
                context(@"When user has previous punches", ^{
                    context(@"when previous punch is clock in or transfer", ^{
                        __block NSIndexPath *firstRowIndexPath;
                        __block NSIndexPath *secondRowIndexPath;
                        __block NSIndexPath *thirdRowIndexPath;
                        __block NSIndexPath *fourthRowIndexPath;
                        __block NSIndexPath *fifthRowIndexPath;
                        
                        
                        beforeEach(^{
                            Activity *activity = [[Activity alloc] initWithName:@"activity:name" uri:@"default:uri"];
                            id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                            
                            id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                            
                            NSMutableArray *punchesArray =  [NSMutableArray array];
                            [punchesArray addObject:punchA];
                            [punchesArray addObject:punchB];
                            timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                            
                            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        
                        it(@"should have a correct number of section and rows in tableview", ^{
                            subject.tableView.numberOfSections should equal(1);
                            [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                        });
                        
                        it(@"should style the cells correctly", ^{
                            UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                            
                            cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                            cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                            cell.textLabel.textColor should equal([UIColor orangeColor]);
                            cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                            
                            DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([DynamicTextTableViewCell class]);
                            secondCell.title.text should equal(oefType1.oefName);
                            secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                            secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                            secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                            secondCell.title.textColor should equal([UIColor orangeColor]);
                            secondCell.textView.textColor should equal([UIColor magentaColor]);
                            secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                            secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                            secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                            
                            
                            DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                            thirdCell.title.text should equal(oefType2.oefName);
                            thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                            thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                            thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                            fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                            firstCell.detailTextLabel.text should equal(RPLocalizedString(@"activity:name", nil));
                            
                            DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([DynamicTextTableViewCell class]);
                            secondCell.title.text should equal(@"text 1");
                            secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                            
                            DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                            thirdCell.title.text should equal(@"numeric 1");
                            thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                            
                            DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                            fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                            fourthCell.title.text should equal(@"dropdown oef 1");
                            fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                        });
                        
                        it(@"should navigate when activity cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                        });
                    });
                    
                    context(@"when previous punch is break or clock out", ^{
                        __block NSIndexPath *firstRowIndexPath;
                        __block NSIndexPath *secondRowIndexPath;
                        __block NSIndexPath *thirdRowIndexPath;
                        __block NSIndexPath *fourthRowIndexPath;
                        __block NSIndexPath *fifthRowIndexPath;
                        
                        
                        beforeEach(^{
                            id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                            
                            id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                            
                            NSMutableArray *punchesArray =  [NSMutableArray array];
                            [punchesArray addObject:punchA];
                            [punchesArray addObject:punchB];
                            timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                            
                            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        
                        it(@"should have a correct number of section and rows in tableview", ^{
                            subject.tableView.numberOfSections should equal(1);
                            [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                        });
                        
                        it(@"should style the cells correctly", ^{
                            UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                            
                            cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                            cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                            cell.textLabel.textColor should equal([UIColor orangeColor]);
                            cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                            
                            DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([DynamicTextTableViewCell class]);
                            secondCell.title.text should equal(oefType1.oefName);
                            secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                            secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                            secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                            secondCell.title.textColor should equal([UIColor orangeColor]);
                            secondCell.textView.textColor should equal([UIColor magentaColor]);
                            secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                            secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                            secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                            
                            
                            DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                            thirdCell.title.text should equal(oefType2.oefName);
                            thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                            thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                            thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                            fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                            firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            
                            DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([DynamicTextTableViewCell class]);
                            secondCell.title.text should equal(@"text 1");
                            secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                            
                            DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                            thirdCell.title.text should equal(@"numeric 1");
                            thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                            
                            DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                            fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                            fourthCell.title.text should equal(@"dropdown oef 1");
                            fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                        });
                        
                        it(@"should navigate when activity cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                        });
                    });
                    
                    context(@"when user currently on break and before break user has punch in ", ^{
                        __block NSIndexPath *firstRowIndexPath;
                        __block NSIndexPath *secondRowIndexPath;
                        __block NSIndexPath *thirdRowIndexPath;
                        __block NSIndexPath *fourthRowIndexPath;
                        __block NSIndexPath *fifthRowIndexPath;
                        
                        beforeEach(^{
                            Activity *activity = [[Activity alloc] initWithName:@"name-activity" uri:@"uri-uri"];
                            id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                            
                            id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                            
                            NSMutableArray *punchesArray =  [NSMutableArray array];
                            [punchesArray addObject:punchA];
                            [punchesArray addObject:punchB];
                            timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                            
                            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                            firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                            thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                            fourthRowIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
                            fifthRowIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
                            [subject setUpWithDelegate:delegate punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];
                            [subject view];
                            [subject.tableView layoutIfNeeded];
                        });
                        
                        it(@"should have a correct number of section and rows in tableview", ^{
                            subject.tableView.numberOfSections should equal(1);
                            [subject.tableView numberOfRowsInSection:0] should equal(1+subject.oefTypesArray.count);
                        });
                        
                        it(@"should style the cells correctly", ^{
                            UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                            
                            cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                            cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                            cell.textLabel.textColor should equal([UIColor orangeColor]);
                            cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                            
                            DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([DynamicTextTableViewCell class]);
                            secondCell.title.text should equal(oefType1.oefName);
                            secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                            secondCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            secondCell.title.font should equal([UIFont systemFontOfSize:12]);
                            secondCell.textView.font should equal([UIFont systemFontOfSize:17]);
                            secondCell.title.textColor should equal([UIColor orangeColor]);
                            secondCell.textView.textColor should equal([UIColor magentaColor]);
                            secondCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                            secondCell.subviews[0].subviews[0] should equal(secondCell.textView);
                            secondCell.subviews[0].subviews[1] should equal(secondCell.title);
                            
                            
                            DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                            thirdCell.title.text should equal(oefType2.oefName);
                            thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                            thirdCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                            thirdCell.title.font should equal([UIFont systemFontOfSize:12]);
                            thirdCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                            fourthCell.textView.font should equal([UIFont systemFontOfSize:17]);
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
                            firstCell.detailTextLabel.text should equal(RPLocalizedString(@"name-activity", nil));
                            
                            DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([DynamicTextTableViewCell class]);
                            secondCell.title.text should equal(@"text 1");
                            secondCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                            
                            DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                            thirdCell.title.text should equal(@"numeric 1");
                            thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));


                            DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                            fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                            fourthCell.title.text should equal(@"dropdown oef 1");
                            fourthCell.textValueLabel.text should equal(@"some-dropdown-option-value");
                            
                        });
                        
                        it(@"should navigate when activity cell is clicked", ^{
                            [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                            navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                            navigationController.navigationBar.hidden should be_falsy;
                        });
                    });
                });
            });
        });
        
        context(@"As a punch into projects flow", ^{
            context(@"with oef's", ^{
                context(@"As a punch into projects flow when user has client access", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    __block NSIndexPath *seventhRowIndexPath;
                    __block PunchCardObject *punchCardObjLocalInstance;
                    
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                        
                        
                        
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
                        
                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        cell.backgroundColor should equal([UIColor clearColor]);
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
                        fifthCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *sixthCell = [subject.tableView cellForRowAtIndexPath:sixthRowIndexPath];
                        sixthCell should be_instance_of([DynamicTextTableViewCell class]);
                        sixthCell.title.text should equal(oefType3.oefName);
                        sixthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        sixthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([UITableViewCell class]);
                            thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            thirdCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                        });
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
                
                context(@"As a punch into projects flow when user don't have client access", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthhRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    __block PunchCardObject *punchCardObjLocalInstance;
                    
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                        
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
                        
                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
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
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        cell.backgroundColor should equal([UIColor clearColor]);
                        
                        DynamicTextTableViewCell *oefCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        oefCell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        oefCell.title.font should equal([UIFont systemFontOfSize:12]);
                        oefCell.textView.font should equal([UIFont systemFontOfSize:17]);
                        oefCell.title.textColor should equal([UIColor orangeColor]);
                        oefCell.textView.textColor should equal([UIColor magentaColor]);
                        oefCell.backgroundColor should equal([UIColor clearColor]);
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
                        fourthCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        fourthCell.textView.keyboardType should equal(UIKeyboardTypeDecimalPad);
                        
                        DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthhRowIndexPath];
                        fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fifthCell.title.text should equal(oefType3.oefName);
                        fifthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        fifthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                            secondCell should be_instance_of([UITableViewCell class]);
                            secondCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            secondCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                        });
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

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:fifthhRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                    });
                });
                
                context(@"When user currently on break and before break user has punch in", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    __block NSIndexPath *seventhRowIndexPath;
                    __block ClientType  *client;
                    __block ProjectType *project;
                    __block TaskType    *taskType;
                    __block PunchCardObject *punchCard;

                    beforeEach(^{
                        
                        client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                        project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                   isTimeAllocationAllowed:NO
                                                                                             projectPeriod:nil
                                                                                                clientType:nil
                                                                                                      name:@"project-name"
                                                                                                       uri:@"project-uri"];
                        taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task-name" uri:@"task-uri"];

                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:nil address:nil userURI:@"user-uri" image:nil task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                        
                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);

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
                        
                        punchCard = [[PunchCardObject alloc]
                                                      initWithClientType:client
                                                      projectType:project
                                                      oefTypesArray:oefTypesArray
                                                      breakType:nil
                                                      taskType:taskType
                                                      activity:nil
                                                      uri:@"guid-A"];

                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];
                        
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Client", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"client-name", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([UITableViewCell class]);
                        secondCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                        secondCell.detailTextLabel.text should equal(RPLocalizedString(@"project-name", nil));
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([UITableViewCell class]);
                        thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                        thirdCell.userInteractionEnabled should be_truthy;
                        thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType1.oefName);
                        fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        
                        
                        DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthRowIndexPath];
                        fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fifthCell.title.text should equal(oefType2.oefName);
                        fifthCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *sixthCell = [subject.tableView cellForRowAtIndexPath:sixthRowIndexPath];
                        sixthCell should be_instance_of([DynamicTextTableViewCell class]);
                        sixthCell.title.text should equal(oefType3.oefName);
                        sixthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        sixthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([UITableViewCell class]);
                            thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                            thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        });
                    });
                    
                    it(@"should navigate when client cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,punchCard,subject);
                    });
                    
                    it(@"should navigate when project cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCard,subject);
                    });
                    
                    it(@"should navigate when task cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCard,subject);
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:sixthRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCard,subject);
                    });
                });
                
                context(@"when previous punch is clock in or transfer", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    __block NSIndexPath *seventhRowIndexPath;
                    __block ClientType  *client;
                    __block ProjectType *project;
                    __block TaskType    *taskType;
                    __block PunchCardObject *punchCard;
                    
                    beforeEach(^{
                        
                        client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                        project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                      isTimeAllocationAllowed:NO
                                                                                projectPeriod:nil
                                                                                   clientType:nil
                                                                                         name:@"project-name"
                                                                                          uri:@"project-uri"];
                        taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task-name" uri:@"task-uri"];
                        
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:nil address:nil userURI:@"user-uri" image:nil task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:nil address:nil userURI:@"user-uri" image:nil task:taskType date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                        
                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                        
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
                        
                        punchCard = [[PunchCardObject alloc]
                                     initWithClientType:client
                                     projectType:project
                                     oefTypesArray:oefTypesArray
                                     breakType:nil
                                     taskType:taskType
                                     activity:nil
                                     uri:@"guid-A"];
                        
                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];
                        
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
                        cell.textLabel.textColor should equal([UIColor orangeColor]);
                        cell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                    });
                    
                    it(@"should setup the cells correctly", ^{
                        
                        UITableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([UITableViewCell class]);
                        firstCell.textLabel.text should equal(RPLocalizedString(@"Client", nil));
                        firstCell.detailTextLabel.text should equal(RPLocalizedString(@"client-name", nil));
                        
                        UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([UITableViewCell class]);
                        secondCell.textLabel.text should equal(RPLocalizedString(@"Project", nil));
                        secondCell.detailTextLabel.text should equal(RPLocalizedString(@"project-name", nil));
                        
                        UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([UITableViewCell class]);
                        thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                        thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                        thirdCell.userInteractionEnabled should be_truthy;
                        thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        
                        DynamicTextTableViewCell *fourthCell = [subject.tableView cellForRowAtIndexPath:fourthRowIndexPath];
                        fourthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fourthCell.title.text should equal(oefType1.oefName);
                        fourthCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));
                        
                        
                        DynamicTextTableViewCell *fifthCell = [subject.tableView cellForRowAtIndexPath:fifthRowIndexPath];
                        fifthCell should be_instance_of([DynamicTextTableViewCell class]);
                        fifthCell.title.text should equal(oefType2.oefName);
                        fifthCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *sixthCell = [subject.tableView cellForRowAtIndexPath:sixthRowIndexPath];
                        sixthCell should be_instance_of([DynamicTextTableViewCell class]);
                        sixthCell.title.text should equal(oefType3.oefName);
                        sixthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        sixthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field selected", ^{
                            UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([UITableViewCell class]);
                            thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"task-name", nil));
                            thirdCell.detailTextLabel.textColor should equal([UIColor magentaColor]);
                        });
                    });
                    
                    it(@"should navigate when client cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:firstRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ClientSelection,punchCard,subject);
                    });
                    
                    it(@"should navigate when project cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:secondRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(ProjectSelection,punchCard,subject);
                    });
                    
                    it(@"should navigate when task cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(TaskSelection,punchCard,subject);
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:sixthRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCard,subject);
                    });
                });
                
                context(@"when previous punch is break in or out", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block NSIndexPath *fourthRowIndexPath;
                    __block NSIndexPath *fifthRowIndexPath;
                    __block NSIndexPath *sixthRowIndexPath;
                    __block NSIndexPath *seventhRowIndexPath;
                    __block PunchCardObject *punchCardObjLocalInstance;
                    beforeEach(^{
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];
                        
                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
                        
                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];
                        
                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);
                        
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
                        
                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                        
                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });
                    
                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(6);
                    });
                    
                    it(@"should style the cells correctly", ^{
                        UITableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.textLabel.font should equal([UIFont systemFontOfSize:12]);
                        cell.detailTextLabel.font should equal([UIFont systemFontOfSize:17]);
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
                        fifthCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                        
                        DynamicTextTableViewCell *sixthCell = [subject.tableView cellForRowAtIndexPath:sixthRowIndexPath];
                        sixthCell should be_instance_of([DynamicTextTableViewCell class]);
                        sixthCell.title.text should equal(oefType3.oefName);
                        sixthCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        sixthCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });
                    
                    context(@"When view loads with project info", ^{
                        beforeEach(^{
                            [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
                            [subject.tableView reloadData];
                        });
                        
                        it(@"should have the task field disabled", ^{
                            UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                            thirdCell should be_instance_of([UITableViewCell class]);
                            thirdCell.textLabel.text should equal(RPLocalizedString(@"Task", nil));
                            thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                            thirdCell.detailTextLabel.textColor should equal([UIColor grayColor]);
                            thirdCell.userInteractionEnabled should be_falsy;
                        });
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

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:sixthRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                    });
                });

            });
        });

        context(@"As a punch into simple punch with OEF flow", ^{
            context(@"with oef's", ^{
                context(@"As a punch into simple punch flow when user has OEF", ^{
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

                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];

                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(3);
                    });

                    it(@"should style the cells correctly", ^{
                        DynamicTextTableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        cell should be_instance_of([DynamicTextTableViewCell class]);
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.title.font should equal([UIFont systemFontOfSize:12]);
                        cell.textView.font should equal([UIFont systemFontOfSize:17]);
                        cell.title.textColor should equal([UIColor orangeColor]);
                        cell.textView.textColor should equal([UIColor magentaColor]);
                        cell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        cell.subviews[0].subviews[0] should equal(cell.textView);
                        cell.subviews[0].subviews[1] should equal(cell.title);
                        cell.backgroundColor should equal([UIColor clearColor]);
                    });

                    it(@"should setup the cells correctly", ^{

                        DynamicTextTableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([DynamicTextTableViewCell class]);
                        firstCell.title.text should equal(oefType1.oefName);
                        firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));


                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType2.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));

                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType3.oefName);
                        thirdCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                    });

                });

                context(@"When user currently on break and before break user has punch in", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block PunchCardObject *punchCard;

                    beforeEach(^{

                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];

                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];

                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];

                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);

                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];


                        punchCard = [[PunchCardObject alloc]
                                     initWithClientType:nil
                                     projectType:nil
                                     oefTypesArray:oefTypesArray
                                     breakType:nil
                                     taskType:nil
                                     activity:nil
                                     uri:@"guid-A"];

                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];

                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(3);
                    });

                    it(@"should style the cells correctly", ^{
                        DynamicTextTableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        cell should be_instance_of([DynamicTextTableViewCell class]);
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.title.font should equal([UIFont systemFontOfSize:12]);
                        cell.textView.font should equal([UIFont systemFontOfSize:17]);
                        cell.title.textColor should equal([UIColor orangeColor]);
                        cell.textView.textColor should equal([UIColor magentaColor]);
                        cell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        cell.subviews[0].subviews[0] should equal(cell.textView);
                        cell.subviews[0].subviews[1] should equal(cell.title);
                        cell.backgroundColor should equal([UIColor clearColor]);

                    });

                    it(@"should setup the cells correctly", ^{

                        DynamicTextTableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([DynamicTextTableViewCell class]);
                        firstCell.title.text should equal(oefType1.oefName);
                        firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));


                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType2.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));

                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType3.oefName);
                        thirdCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCard,subject);
                    });
                });

                context(@"when previous punch is clock in or transfer", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;
                    __block PunchCardObject *punchCard;

                    beforeEach(^{

                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];

                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];

                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];

                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);

                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];


                        punchCard = [[PunchCardObject alloc]
                                     initWithClientType:nil
                                     projectType:nil
                                     oefTypesArray:oefTypesArray
                                     breakType:nil
                                     taskType:nil
                                     activity:nil
                                     uri:@"guid-A"];

                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];

                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(3);
                    });

                    it(@"should style the cells correctly", ^{
                        DynamicTextTableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        cell should be_instance_of([DynamicTextTableViewCell class]);
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.title.font should equal([UIFont systemFontOfSize:12]);
                        cell.textView.font should equal([UIFont systemFontOfSize:17]);
                        cell.title.textColor should equal([UIColor orangeColor]);
                        cell.textView.textColor should equal([UIColor magentaColor]);
                        cell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        cell.subviews[0].subviews[0] should equal(cell.textView);
                        cell.subviews[0].subviews[1] should equal(cell.title);
                        cell.backgroundColor should equal([UIColor clearColor]);

                    });

                    it(@"should setup the cells correctly", ^{

                        DynamicTextTableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([DynamicTextTableViewCell class]);
                        firstCell.title.text should equal(oefType1.oefName);
                        firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));


                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType2.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));

                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType3.oefName);
                        thirdCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCard,subject);
                    });
                });

                context(@"when previous punch is break in or out", ^{
                    __block NSIndexPath *firstRowIndexPath;
                    __block NSIndexPath *secondRowIndexPath;
                    __block NSIndexPath *thirdRowIndexPath;

                    beforeEach(^{
                        id<Punch> punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]];

                        id<Punch> punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"user-uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];

                        NSMutableArray *punchesArray =  [NSMutableArray array];
                        [punchesArray addObject:punchA];
                        [punchesArray addObject:punchB];

                        timeLinePunchesStorage stub_method(@selector(recentTwoPunches)).and_return(punchesArray);

                        userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                        userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);

                        firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        secondRowIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        thirdRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];


                        [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];

                        [subject view];
                        [subject.tableView layoutIfNeeded];
                    });

                    it(@"should have a correct number of section and rows in tableview", ^{
                        subject.tableView.numberOfSections should equal(1);
                        [subject.tableView numberOfRowsInSection:0] should equal(3);
                    });

                    it(@"should style the cells correctly", ^{
                        DynamicTextTableViewCell *cell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        cell should be_instance_of([DynamicTextTableViewCell class]);
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                        cell.title.font should equal([UIFont systemFontOfSize:12]);
                        cell.textView.font should equal([UIFont systemFontOfSize:17]);
                        cell.title.textColor should equal([UIColor orangeColor]);
                        cell.textView.textColor should equal([UIColor magentaColor]);
                        cell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                        cell.subviews[0].subviews[0] should equal(cell.textView);
                        cell.subviews[0].subviews[1] should equal(cell.title);
                        cell.backgroundColor should equal([UIColor clearColor]);

                    });

                    it(@"should setup the cells correctly", ^{

                        DynamicTextTableViewCell *firstCell = [subject.tableView cellForRowAtIndexPath:firstRowIndexPath];
                        firstCell should be_instance_of([DynamicTextTableViewCell class]);
                        firstCell.title.text should equal(oefType1.oefName);
                        firstCell.textView.text should equal(RPLocalizedString(@"Enter Text", @""));


                        DynamicTextTableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:secondRowIndexPath];
                        secondCell should be_instance_of([DynamicTextTableViewCell class]);
                        secondCell.title.text should equal(oefType2.oefName);
                        secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));

                        DynamicTextTableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:thirdRowIndexPath];
                        thirdCell should be_instance_of([DynamicTextTableViewCell class]);
                        thirdCell.title.text should equal(oefType3.oefName);
                        thirdCell.textValueLabel.text should equal(RPLocalizedString(@"some-dropdown-option-value", @""));
                        thirdCell.textView.keyboardType should equal(UIKeyboardTypeDefault);
                    });

                    it(@"should navigate when dropdown cell is clicked", ^{
                        [subject tableView:subject.tableView didSelectRowAtIndexPath:thirdRowIndexPath];
                        navigationController should have_received(@selector(pushViewController:animated:)).with(selectionController,Arguments::anything);
                        navigationController.navigationBar.hidden should be_falsy;
                        selectionController should have_received(@selector(setUpWithSelectionScreenType:punchCardObject:delegate:)).with(OEFDropDownSelection,punchCardObject,subject);
                    });
                });

            });
        });
    });

    describe(@"As a <PunchCardControllerDelegate>", ^{

        describe(@"out Action ", ^{
            __block PunchCardObject *punchCardObject;
            beforeEach(^{
                [subject view];
                punchCardObject = [[PunchCardObject alloc]
                                   initWithClientType:nil
                                   projectType:nil
                                   oefTypesArray:oefTypesArray
                                   breakType:nil
                                   taskType:nil
                                   activity:nil
                                   uri:@"guid-A"];
                spy_on(subject.view);
            });
            context(@"When saving puncn", ^{
                beforeEach(^{
                    [subject.punchActionButton tap];
                });
                
                it(@"should inform delegate when punch button is tapped", ^{
                    delegate should have_received(@selector(oefCardViewController:didIntendToSave:)).with(subject,punchCardObject);
                });
                
                it(@"should end view editing", ^{
                    subject.view should have_received(@selector(endEditing:)).with(NO);
                });
            });
            
            context(@"When performing cancel button", ^{
                
                beforeEach(^{
                    [subject.cancelButton tap];
                });
                
                it(@"should not inform delegate when cancel button is tapped", ^{
                    delegate should have_received(@selector(oefCardViewController:cancelButton:)).with(subject,subject.cancelButton);
                });
            });
            
        });
        
        describe(@"break Action ", ^{
            __block PunchCardObject *cardObject;
            __block UITableViewCell *cell;
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeStartBreak
                             oefTypesArray:oefTypesArray];
                [subject view];
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell tap];
            });

            it(@"should disable view user interaction", ^{
                subject.view.userInteractionEnabled should be_falsy;
            });

            context(@"When saving punch with break type selected", ^{
                __block UIActionSheet *actionSheet;
                
                beforeEach(^{
                    BreakType *feelingsBreak = [[BreakType alloc] initWithName:@"Talk About Feelings Break" uri:@"feelings"];
                    BreakType *smokeBreak = [[BreakType alloc] initWithName:@"Smoke Break" uri:@"smoke"];
                    
                    [breakTypeDeferred resolveWithValue:@[feelingsBreak, smokeBreak]];
                    
                    actionSheet = [UIActionSheet currentActionSheet];
                    
                    [actionSheet dismissByClickingButtonWithTitle:@"Talk About Feelings Break"];
                    
                    cardObject = subject.punchCardObject;
                    
                    [subject.punchActionButton tap];
                });
                
                it(@"should inform delegate when punch button is tapped", ^{
                    delegate should have_received(@selector(oefCardViewController:didIntendToSave:)).with(subject,cardObject);
                });

            });
            
            context(@"When performing cancel button", ^{
                
                beforeEach(^{
                    [subject.cancelButton tap];
                });
                
                it(@"should not inform delegate when cancel button is tapped", ^{
                    delegate should have_received(@selector(oefCardViewController:cancelButton:)).with(subject,subject.cancelButton);
                });
            });
            
        });
        
        describe(@"viewDidLayoutSubviews", ^{
            
            beforeEach(^{
                subject.view should_not be_nil;
                [subject viewDidLayoutSubviews];
            });
            
            it(@"should inform the tableViewDelegate PunchDetailsController updated its height when don't have client access", ^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                delegate should have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
            });
            
        });
        
    });
    
    describe(@"As a <DynamicTextTableViewCellDelegate>", ^{
        __block DynamicTextTableViewCell *firstCell;
        __block DynamicTextTableViewCell *secondCell;
        
        beforeEach(^{
            userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
            userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
            [subject setUpWithDelegate:delegate
                       punchActionType:PunchActionTypePunchOut
                         oefTypesArray:oefTypesArray];
            [subject view];
            [subject.tableView layoutIfNeeded];
            firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        });
        
        it(@"correct tag should be set up for the dynamic cells", ^{
            firstCell.tag should equal(0);
            secondCell.tag should equal(1);
        });

        context(@"dynamicTextTableViewCell:didUpdateTextView:", ^{
                beforeEach(^{
                    [secondCell.textView setText:@"testing..."];
                    [subject dynamicTextTableViewCell:secondCell didUpdateTextView:secondCell.textView];
                });
                
                
                it(@"should update table content size", ^{
                    delegate should have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)200.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });
        });
        
        context(@"dynamicTextTableViewCell:didUpdateTextView: validate OEF", ^{
            
            context(@"dynamicTextTableViewCell:didUpdateTextView: - validate numeric OEF with integer", ^{
                __block NSMutableArray *oefTypeArr;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate
                               punchActionType:PunchActionTypePunchOut
                                 oefTypesArray:oefTypesArray];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
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
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate
                               punchActionType:PunchActionTypePunchOut
                                 oefTypesArray:oefTypesArray];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
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
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate
                               punchActionType:PunchActionTypePunchOut
                                 oefTypesArray:oefTypesArray];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
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
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate
                               punchActionType:PunchActionTypePunchOut
                                 oefTypesArray:oefTypesArray];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:secondCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    secondCell.textView.tag should equal(4001);
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
                    
                    oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1pqrstubwxyz" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:YES];
                    
                    
                    oefTypeArr = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                    
                    [subject setUpWithDelegate:delegate
                               punchActionType:PunchActionTypePunchOut
                                 oefTypesArray:oefTypesArray];
                    [subject view];
                    [subject.tableView layoutIfNeeded];
                    
                    firstCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
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
                    delegate should_not have_received(@selector(oefCardViewController:didUpdateHeight:)).with(subject,subject.tableView.contentSize.height + (float)125.0);
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should_not have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });

                it(@"should set correct textview tag", ^{
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    firstCell.textView.tag should equal(4000);
                });

                it(@"textview should have received the first responder", ^{
                    UITextView *textView_ = [subject.tableView viewWithTag:firstCell.textView.tag];
                    spy_on(textView_);
                    UIAlertView *alert = [UIAlertView currentAlertView];
                    alert should_not be_nil;
                    firstCell.textView.tag should equal(4000);
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
                    [subject dynamicTextTableViewCell:secondCell didBeginEditingTextView:secondCell.textView];
                });
                
                it(@"should set clear textview placeholder text", ^{
                    secondCell.textView.text should equal(@"");
                });
                
                it(@"should be scrolling the scrollview", ^{
                    delegate should have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
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
                    delegate should have_received(@selector(oefCardViewController:didScrolltoSubview:)).with(subject,secondCell.textView);
                });
            });
        });
        
        context(@"dynamicTextTableViewCell:didEndEditingTextView:", ^{
            context(@"when value is nil", ^{
                beforeEach(^{
                    secondCell.textView.text = nil;
                    [subject dynamicTextTableViewCell:secondCell didEndEditingTextView:secondCell.textView];
                });
                
                it(@"should set textview placeholder text", ^{
                    secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                });

                it(@"correct punch card value for oef should be configured", ^{
                    subject.punchCardObject.oefTypesArray.count should equal(3);
                    OEFType *oeftType =  subject.punchCardObject.oefTypesArray[1];
                    oeftType.oefNumericValue should equal(@"");
                });
            });

            context(@"when value is empty string", ^{
                beforeEach(^{
                    secondCell.textView.text = @"";
                    [subject dynamicTextTableViewCell:secondCell didEndEditingTextView:secondCell.textView];
                });

                it(@"should set textview placeholder text", ^{
                    secondCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                });

                it(@"correct punch card value for oef should be configured", ^{
                    subject.punchCardObject.oefTypesArray.count should equal(3);
                    OEFType *oeftType =  subject.punchCardObject.oefTypesArray[1];
                    oeftType.oefNumericValue should equal(@"");
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
            });
            
        });
        
    });
    
    describe(@"Tapping on DynamicTextTableViewCell", ^{
        __block DynamicTextTableViewCell *cell;
        
        beforeEach(^{
            [subject setUpWithDelegate:delegate
                       punchActionType:PunchActionTypePunchOut
                         oefTypesArray:oefTypesArray];
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
    
    describe(@"Tapping on UITableViewCell", ^{

        context(@"when tapping on break row", ^{
            __block UITableViewCell *cell;
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeStartBreak
                             oefTypesArray:oefTypesArray];
                [subject view];
                [subject.tableView layoutIfNeeded];
                cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell tap];

            });

            it(@"should get a list of break types from the break type repository", ^{
                breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(@"user-uri");
            });

            it(@"should disable view user interaction", ^{
                subject.view.userInteractionEnabled should be_falsy;
            });

            context(@"when fetching the break type list succeeds", ^{
                __block UIActionSheet *actionSheet;
                __block UITableViewCell *cell;
                beforeEach(^{
                    BreakType *feelingsBreak = [[BreakType alloc] initWithName:@"Talk About Feelings Break" uri:@"feelings"];
                    BreakType *smokeBreak = [[BreakType alloc] initWithName:@"Smoke Break" uri:@"smoke"];

                    [breakTypeDeferred resolveWithValue:@[feelingsBreak, smokeBreak]];
                    actionSheet = [UIActionSheet currentActionSheet];
                });

                it(@"should show the break list action sheet", ^{
                    [actionSheet buttonTitles] should equal(@[@"Cancel", @"Talk About Feelings Break", @"Smoke Break"]);
                });

                context(@"when the user taps on a break type", ^{
                    beforeEach(^{
                        [actionSheet dismissByClickingButtonWithTitle:@"Talk About Feelings Break"];
                    });

                    it(@"should show selected break value", ^{
                        cell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        cell.detailTextLabel.text should equal(@"Talk About Feelings Break");
                    });

                    it(@"should enable view user interaction", ^{
                        subject.view.userInteractionEnabled should be_truthy;
                    });
                });
            });

            context(@"when fetching the break type list fails", ^{
                __block NSError *error;
                __block UIAlertView *alertView;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [breakTypeDeferred rejectWithError:error];
                    alertView = [UIAlertView currentAlertView];
                });

                it(@"should have the alertview for no breaks ", ^{
                    alertView should_not be_nil;
                    alertView.message should equal(RPLocalizedString(@"Replicon app was unable to retrieve the break type list.  Please try again later.", nil));
                });

                it(@"should enable view user interaction", ^{
                    subject.view.userInteractionEnabled should be_truthy;
                });
            });
        });
        context(@"when tapping on text/numeric oef", ^{
            __block DynamicTextTableViewCell *cell;
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeStartBreak
                             oefTypesArray:oefTypesArray];
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
            __block DynamicTextTableViewCell *cell;
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                    userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                    [subject setUpWithDelegate:delegate
                               punchActionType:PunchActionTypeStartBreak
                                 oefTypesArray:oefTypesArray];
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
    
    describe(@"As a <SelectionControllerDelegate>", ^{
        __block PunchCardObject *expectedPunchCard;
        beforeEach(^{
            [subject setUpWithDelegate:nil punchActionType:PunchActionTypeTransfer oefTypesArray:oefTypesArray];
            [subject view];
            [subject.tableView layoutIfNeeded];
        });
        
        context(@"When updating client", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
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
        
        context(@"When updating client and client null behaviour uri is selected and type is Any client", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                ClientType *client = [[ClientType alloc]initWithName:@"Any Client" uri:ClientTypeAnyClientUri];
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
                firstCell.detailTextLabel.text should equal(RPLocalizedString(@"Any Client", nil));
                
                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                
                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                
                subject.punchCardObject should equal(expectedPunchCard);
            });
        });
        
        context(@"When updating client and client null behaviour uri is selected and type is No client", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                ClientType *client = [[ClientType alloc]initWithName:@"No Client" uri:ClientTypeNoClientUri];
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
                firstCell.detailTextLabel.text should equal(RPLocalizedString(@"No Client", nil));
                
                UITableViewCell *secondCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                secondCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                
                UITableViewCell *thirdCell = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                thirdCell.detailTextLabel.text should equal(RPLocalizedString(@"Select", nil));
                
                subject.punchCardObject should equal(expectedPunchCard);
            });
        });
        
        context(@"When updating Project", ^{

            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            });
            
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
                    
                    subject.punchCardObject should equal(expectedPunchCard);
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

            beforeEach(^{
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
            });
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
                thirdCell.textView.text should equal(RPLocalizedString(@"Enter Number", @""));
                
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

        context(@"When updating dropdown oefTypes for a punch", ^{
            beforeEach(^{
                [subject setUpWithDelegate:nil punchActionType:PunchActionTypeResumeWork oefTypesArray:oefTypesArray];
                
                subject stub_method(@selector(selectedDropDownOEFUri)).and_return(@"oef-uri-2");
                OEFDropDownType *oefDropDownType =  [[OEFDropDownType alloc] initWithName:@"new-dropdown-name" uri:@"new-dropdown-uri"];
                [subject selectionController:nil didChooseDropDownOEF:oefDropDownType];
            });

            it(@"should load with expected punchcard object", ^{
                OEFType *oefType4 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"new-dropdown-name" collectAtTimeOfPunch:NO disabled:YES];

                NSArray *oefTypes = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType4, nil];
                expectedPunchCard = [[PunchCardObject alloc]initWithClientType:nil
                                                                   projectType:nil
                                                                 oefTypesArray:oefTypes
                                                                     breakType:nil
                                                                      taskType:nil
                                                                      activity:nil
                                                                           uri:@"guid-A"];
                subject.punchCardObject should equal(expectedPunchCard);
            });
        });
    });
    
    describe(@"When saving punch and no break type selected", ^{
        __block UIAlertView *alertView;
        beforeEach(^{
            [subject setUpWithDelegate:delegate
                       punchActionType:PunchActionTypeStartBreak
                         oefTypesArray:oefTypesArray];
            [subject view];
            spy_on(subject.view);
            [subject.punchActionButton tap];
            alertView = [UIAlertView currentAlertView];
        });
        
        it(@"should have the alertview for no breaks ", ^{
            alertView should_not be_nil;
            alertView.message should equal(RPLocalizedString(@"Please select a break type.", nil));
        });
    });
    
    describe(@"When User is Punch into Project User and Validation fails", ^{
        __block UIAlertView *alertView;
        __block ProjectType *project_;
        __block PunchCardObject *punchCard_;
        
        context(@"When resuming from break and no Project is selected", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeResumeWork
                             oefTypesArray:oefTypesArray];
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                
                [subject view];
                spy_on(subject.view);
                [subject.punchActionButton tap];
                alertView = [UIAlertView currentAlertView];
            });
        
            it(@"should have the alertview for no Project ", ^{
                alertView should_not be_nil;
                alertView.message should equal(InvalidProjectSelectedError);
            });
            
        });
        
        context(@"When resuming from break and no Task is selected", ^{
            beforeEach(^{
                project_ = nice_fake_for([ProjectType class]);
                project_ stub_method(@selector(name)).and_return(@"some:project");
                
                punchCard_ = [[PunchCardObject alloc]
                             initWithClientType:nil
                             projectType:project_
                             oefTypesArray:oefTypesArray
                             breakType:nil
                             taskType:nil
                             activity:nil
                             uri:@"guid-A"];
                
                subject stub_method(@selector(punchCardObject)).and_return(punchCard_);
                
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeResumeWork
                             oefTypesArray:oefTypesArray];
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                
                [subject view];
                spy_on(subject.view);
                [subject.punchActionButton tap];
                alertView = [UIAlertView currentAlertView];
            });
            
            it(@"should have the alertview for no Project ", ^{
                alertView should_not be_nil;
                alertView.message should equal(InvalidTaskSelectedError);
            });
            
        });
        
        context(@"When Transfering Punch and no Project is selected", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeTransfer
                             oefTypesArray:oefTypesArray];
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                
                [subject view];
                spy_on(subject.view);
                [subject.punchActionButton tap];
                alertView = [UIAlertView currentAlertView];
            });
            
            it(@"should have the alertview for no Project ", ^{
                alertView should_not be_nil;
                alertView.message should equal(InvalidProjectSelectedError);
            });
            
        });
        
        context(@"When Transferring punch and no Task is selected", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeTransfer
                             oefTypesArray:oefTypesArray];
                
                project_ = nice_fake_for([ProjectType class]);
                project_ stub_method(@selector(name)).and_return(@"some:project");
                
                punchCard_ = [[PunchCardObject alloc]
                              initWithClientType:nil
                              projectType:project_
                              oefTypesArray:oefTypesArray
                              breakType:nil
                              taskType:nil
                              activity:nil
                              uri:@"guid-A"];
                
                subject stub_method(@selector(punchCardObject)).and_return(punchCard_);
                
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(isProjectTaskSelectionRequired)).and_return(YES);
                
                [subject view];
                spy_on(subject.view);
                [subject.punchActionButton tap];
                alertView = [UIAlertView currentAlertView];
            });
            
            it(@"should have the alertview for no Project ", ^{
                alertView should_not be_nil;
                alertView.message should equal(InvalidTaskSelectedError);
            });
            
        });

    });
    
    
    describe(@"When User is Punch into Activity User and Validation fails", ^{
        __block UIAlertView *alertView;
        
        context(@"When resuming from break and no Activity is selected", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeResumeWork
                             oefTypesArray:oefTypesArray];
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
                
                [subject view];
                spy_on(subject.view);
                [subject.punchActionButton tap];
                alertView = [UIAlertView currentAlertView];
            });
            
            it(@"should have the alertview for no Project ", ^{
                alertView should_not be_nil;
                alertView.message should equal(InvalidActivitySelectedError);
            });
            
        });
        
        context(@"When Transfering Punch and no Activity is selected", ^{
            beforeEach(^{
                [subject setUpWithDelegate:delegate
                           punchActionType:PunchActionTypeTransfer
                             oefTypesArray:oefTypesArray];
                
                userPermissionsStorage stub_method(@selector(hasProjectAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasClientAccess)).and_return(NO);
                userPermissionsStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
                userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);
                
                [subject view];
                spy_on(subject.view);
                [subject.punchActionButton tap];
                alertView = [UIAlertView currentAlertView];
            });
            
            it(@"should have the alertview for no Project ", ^{
                alertView should_not be_nil;
                alertView.message should equal(InvalidActivitySelectedError);
            });
            
        });
    });

});

SPEC_END
