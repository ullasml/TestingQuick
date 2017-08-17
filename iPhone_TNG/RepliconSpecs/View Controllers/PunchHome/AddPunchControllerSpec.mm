#import <Cedar/Cedar.h>
#import "UIAlertView+Spec.h"
#import "AddPunchController.h"
#import "SegmentedControlStylist.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/Blindside.h>
#import "Theme.h"
#import "UIBarButtonItem+Spec.h"
#import "ImageNormalizer.h"
#import <KSDeferred/KSPromise.h>
#import "PunchImagePickerControllerProvider.h"
#import "DefaultTableViewCellStylist.h"
#import <KSDeferred/KSDeferred.h>
#import "UISegmentedControl+Spec.h"
#import "UITableViewCell+Spec.h"
#import "BreakTypeRepository.h"
#import "BreakType.h"
#import "UIActionSheet+Spec.h"
#import "SpinnerDelegate.h"
#import "UserPermissionsStorage.h"
#import "PunchRepository.h"
#import "ManualPunch.h"
#import "PunchClock.h"
#import "PunchAssemblyGuard.h"
#import "AllowAccessAlertHelper.h"
#import "PunchOverviewController.h"
#import "PunchHomeController.h"
#import "PunchAttributeController.h"
#import "ChildControllerHelper.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "ReporteePermissionsStorage.h"
#import "ManualPunch.h"
#import "Activity.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "GUIDProvider.h"
#import "PunchValidator.h"
#import "OEFType.h"
#import "OEFTypeStorage.h"
#import "DaySummaryDateTimeProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;


SPEC_BEGIN(AddPunchControllerSpec)

describe(@"AddPunchController", ^{
    __block AddPunchController <CedarDouble>*subject;
    __block PunchClock *punchClock;
    __block PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
    __block DefaultTableViewCellStylist *tableViewCellStylist;
    __block SegmentedControlStylist *segmentedControlStylist;
    __block UserPermissionsStorage *punchRulesStorage;
    __block BreakTypeRepository *breakTypeRepository;
    __block UIImagePickerController *imagePicker;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block ImageNormalizer *imageNormalizer;
    __block PunchRepository *punchRepository;
    __block NSDateFormatter *dateFormatter;
    __block KSDeferred *breakTypeDeferred;
    __block AllowAccessAlertHelper *allowAccessAlertHelper;
    __block UIApplication<CedarDouble> *sharedApplication;
    __block id<Theme> theme;
    __block id<UserSession> userSession;
    __block NSDate *date;
    __block id <PunchChangeObserverDelegate> punchChangeObserverDelegate;
    __block PunchAttributeController *punchAttributeController;
    __block ChildControllerHelper <CedarDouble> *childControllerHelper;
    __block ReporteePermissionsStorage *reporteePermissionsStorage;
    __block id <BSBinder,BSInjector> injector;
    __block GUIDProvider *guidProvider;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block PunchValidator *punchValidator;
    __block NSMutableArray *oefTypesArray;
    __block OEFType *oefType1;
    __block OEFType *oefType2;
    __block OEFType *oefType3;
    __block OEFTypeStorage *oefStorage;
    __block NSNotificationCenter *notificationCenter;
    __block DaySummaryDateTimeProvider *daySummaryDateTimeProvider;


    beforeEach(^{
        injector = [InjectorProvider injector];

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        spy_on(notificationCenter);

        reporteePermissionsStorage = nice_fake_for([ReporteePermissionsStorage class]);
        date = [NSDate dateWithTimeIntervalSinceReferenceDate:1234];
        breakTypeDeferred = [[KSDeferred alloc] init];

        reachabilityMonitor = [[ReachabilityMonitor alloc]init];
        spy_on(reachabilityMonitor);

        oefStorage = nice_fake_for([OEFTypeStorage class]);
        punchValidator = nice_fake_for([PunchValidator class]);
        userSession = nice_fake_for(@protocol(UserSession));
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        punchChangeObserverDelegate = nice_fake_for(@protocol(PunchChangeObserverDelegate));
        sharedApplication = fake_for([UIApplication class]);
        allowAccessAlertHelper = nice_fake_for([AllowAccessAlertHelper class]);
        punchClock = nice_fake_for([PunchClock class]);
        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        breakTypeRepository = nice_fake_for([BreakTypeRepository class]);
        punchAttributeController = nice_fake_for([PunchAttributeController class]);
        theme = nice_fake_for(@protocol(Theme));
        tableViewCellStylist = nice_fake_for([DefaultTableViewCellStylist class]);
        dateFormatter = nice_fake_for([NSDateFormatter class]);
        segmentedControlStylist = nice_fake_for([SegmentedControlStylist class]);
        punchRepository = nice_fake_for([PunchRepository class]);
        imagePicker = nice_fake_for([UIImagePickerController class]);
        imageNormalizer = nice_fake_for([ImageNormalizer class]);
        punchImagePickerControllerProvider = nice_fake_for([PunchImagePickerControllerProvider class]);
        punchImagePickerControllerProvider stub_method(@selector(provideInstanceWithDelegate:))
        .and_return(imagePicker);
        breakTypeRepository stub_method(@selector(fetchBreakTypesForUser:)).and_return(breakTypeDeferred.promise);

        theme stub_method(@selector(datePickerBackgroundColor)).and_return([UIColor blueColor]);

        guidProvider = nice_fake_for([GUIDProvider class]);
        daySummaryDateTimeProvider = nice_fake_for([DaySummaryDateTimeProvider class]);
        
        punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).and_return(nil);
        
        oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
       
        oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
        
         oefTypesArray = [NSMutableArray arrayWithObjects:oefType1, oefType2, oefType3, nil];

        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];
        [injector bind:[ReporteePermissionsStorage class] toInstance:reporteePermissionsStorage];
        [injector bind:[PunchAttributeController class] toInstance:punchAttributeController];
        [injector bind:[PunchImagePickerControllerProvider class] toInstance:punchImagePickerControllerProvider];
        [injector bind:[SegmentedControlStylist class] toInstance:segmentedControlStylist];
        [injector bind:[AllowAccessAlertHelper class] toInstance:allowAccessAlertHelper];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:[DefaultTableViewCellStylist class] toInstance:tableViewCellStylist];
        [injector bind:[BreakTypeRepository class] toInstance:breakTypeRepository];
        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];
        [injector bind:[ImageNormalizer class] toInstance:imageNormalizer];
        [injector bind:[PunchRepository class] toInstance:punchRepository];
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];
        [injector bind:InjectorKeyShortDatePlusHoursAndMinutesInLocalTimeZoneDateFormatter toInstance:dateFormatter];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[PunchClock class] toInstance:punchClock];
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[GUIDProvider class] toInstance:guidProvider];
        [injector bind:[PunchValidator class] toInstance:punchValidator];
        [injector bind:[OEFTypeStorage class] toInstance:oefStorage];
        [injector bind:[DaySummaryDateTimeProvider class] toInstance:daySummaryDateTimeProvider];
        
        punchRulesStorage stub_method(@selector(isAstroPunchUser)).and_return(YES);
        punchRulesStorage stub_method(@selector(hasClientAccess)).and_return(YES);
        punchRulesStorage stub_method(@selector(hasProjectAccess)).and_return(YES);
        punchRulesStorage stub_method(@selector(hasActivityAccess)).and_return(YES);
        guidProvider stub_method(@selector(guid)).and_return(@"guid-A");
        daySummaryDateTimeProvider stub_method(@selector(dateWithCurrentTime:)).and_return(date);


        subject = [injector getInstance:[AddPunchController class]];
        spy_on(subject);

    });

    describe(@"the navigation bar", ^{
        __block UINavigationController *navigationController;
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            navigationController.navigationBarHidden = YES;
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });

        it(@"view width should be same as screen width", ^{
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            subject.view.frame.size.width should equal((float)screenRect.size.width);
        });

        it(@"should be visible", ^{
            subject.navigationController.navigationBarHidden should be_falsy;
        });

        it(@"should have a title", ^{
            subject.title should equal(RPLocalizedString(@"Add Missing Punch", nil));
        });

        it(@"should add a right bar button item", ^{
            subject.navigationItem.rightBarButtonItem should_not be_nil;
        });
    });

    describe(@"fetching the list of break types", ^{
        __block UIBarButtonItem *saveButton;

        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
            });

            context(@"When breaks are not configured", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);
                    subject.view should_not be_nil;
                    saveButton = subject.navigationItem.rightBarButtonItem;
                });

                it(@"should ask the Break Type Repository for break types", ^{
                    breakTypeRepository should_not have_received(@selector(fetchBreakTypesForUser:));
                });

            });

            context(@"When breaks are configured", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                    subject.view should_not be_nil;
                    saveButton = subject.navigationItem.rightBarButtonItem;
                });

                it(@"should ask the Break Type Repository for break types", ^{
                    breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(@"my-special-user-uri");
                });

                it(@"should enable the save button by default", ^{
                    saveButton.enabled should be_truthy;
                });

                context(@"if breaks cannot be fetched", ^{
                    beforeEach(^{
                        [breakTypeDeferred rejectWithError:[NSError errorWithDomain:@"" code:0 userInfo:nil]];

                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                    });

                    it(@"should disable the save button by default", ^{
                        saveButton.enabled should be_falsy;
                    });

                    it(@"should be enabled when the user selects any other type", ^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                        saveButton.enabled should be_truthy;
                    });
                });

                context(@"if breaks can be fetched", ^{
                    beforeEach(^{
                        [breakTypeDeferred resolveWithValue:@[[[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"]]];

                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                    });

                    it(@"should enable the save button", ^{
                        saveButton.enabled should be_truthy;
                    });
                });

                context(@"when the break type list loads after the user picks break", ^{
                    beforeEach(^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        [subject.punchDetailsTableView layoutIfNeeded];

                        [breakTypeDeferred resolveWithValue:@[[[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"]]];
                    });
                    
                    it(@"should enable the save button", ^{
                        saveButton.enabled should be_truthy;
                    });
                    
                    it(@"should pick the first break type by default", ^{
                        UITableViewCell *cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                        cell.textLabel.text should equal(@"Doesn't even matter");
                    });
                });
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                 reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
            });

            context(@"When breaks are not configured", ^{
                beforeEach(^{
                    reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                    subject.view should_not be_nil;
                    saveButton = subject.navigationItem.rightBarButtonItem;
                });

                it(@"should ask the Break Type Repository for break types", ^{
                    breakTypeRepository should_not have_received(@selector(fetchBreakTypesForUser:));
                });

            });

            context(@"When breaks are configured", ^{
                beforeEach(^{
                    reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                    subject.view should_not be_nil;
                    saveButton = subject.navigationItem.rightBarButtonItem;
                });

                it(@"should ask the Break Type Repository for break types", ^{
                    breakTypeRepository should have_received(@selector(fetchBreakTypesForUser:)).with(@"my-special-user-uri");
                });

                it(@"should enable the save button by default", ^{
                    saveButton.enabled should be_truthy;
                });

                context(@"if breaks cannot be fetched", ^{
                    beforeEach(^{
                        [breakTypeDeferred rejectWithError:[NSError errorWithDomain:@"" code:0 userInfo:nil]];

                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                    });

                    it(@"should disable the save button by default", ^{
                        saveButton.enabled should be_falsy;
                    });

                    it(@"should be enabled when the user selects any other type", ^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                        saveButton.enabled should be_truthy;
                    });
                });

                context(@"if breaks can be fetched", ^{
                    beforeEach(^{
                        [breakTypeDeferred resolveWithValue:@[[[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"]]];

                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                    });

                    it(@"should enable the save button", ^{
                        saveButton.enabled should be_truthy;
                    });
                });

                context(@"when the break type list loads after the user picks break", ^{
                    beforeEach(^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        [subject.punchDetailsTableView layoutIfNeeded];

                        [breakTypeDeferred resolveWithValue:@[[[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"]]];
                    });
                    
                    it(@"should enable the save button", ^{
                        saveButton.enabled should be_truthy;
                    });
                    
                    it(@"should pick the first break type by default", ^{
                        UITableViewCell *cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                        cell.textLabel.text should equal(@"Doesn't even matter");
                    });
                });
            });
        });


    });

    describe(@"Styling the separator views", ^{
        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:nil
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            theme stub_method(@selector(separatorViewBackgroundColor)).and_return([UIColor blueColor]);
            subject.view should_not be_nil;
        });

        it(@"should correctly set the separator view color ", ^{
            subject.segmentToTableSeparatorView.backgroundColor should equal([UIColor blueColor]);
        });
    });

    describe(@"styling the tableview", ^{
        __block UITableViewCell *cell;

        describe(@"the first cell", ^{
            beforeEach(^{
                cell = [subject tableView:subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            });

            it(@"should collaborate with the tableview cell stylist", ^{
                tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
            });
        });

        describe(@"the second cell", ^{
            beforeEach(^{
                cell = [subject tableView:subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            });

            it(@"should collaborate with the tableview cell stylist", ^{
                tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)0.0f);
            });
        });
    });

    describe(@"the punch type segmented control", ^{
        __block UISegmentedControl *segmentedControl;

        beforeEach(^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
        });

        context(@"for user context", ^{
            beforeEach(^{
                 userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            });
            context(@"When breaks is configured", ^{
                context(@"for a user with activities", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                        punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });

                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Break", nil));
                        [segmentedControl titleForSegmentAtIndex:3] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(4);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with projects", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                        punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                        punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });

                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Break", nil));
                        [segmentedControl titleForSegmentAtIndex:3] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(4);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with no activities and projects", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });

                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Break", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(3);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });

            });

            context(@"When breaks is not configured", ^{
                context(@"for a user with activities", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                        punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);
                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });
                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(3);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with projects", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                        punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                        punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);
                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });
                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(3);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with no activities and projects", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                        punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);
                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });
                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(2);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
            });

            context(@"When user(astro user) is not configured to transfer", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);

                    subject.view should_not be_nil;
                    segmentedControl = subject.punchTypeSegmentedControl;
                });

                it(@"should have the correct titles", ^{
                    [segmentedControl titleForSegmentAtIndex:1] should_not equal(RPLocalizedString(@"Transfer", nil));
                    [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Clock Out", nil));

                });

                it(@"should have the correct number of segments", ^{
                    segmentedControl.numberOfSegments should equal(2);
                });

                it(@"should have selected the default segment", ^{
                    segmentedControl.selectedSegmentIndex should equal(0);
                });

                it(@"should style the segmented control", ^{
                    segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                });


            });

            context(@"When user(punch into projects user) is configured to transfer", ^{
                beforeEach(^{
                    reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                    subject.view should_not be_nil;
                    segmentedControl = subject.punchTypeSegmentedControl;
                });

                it(@"should have the correct titles", ^{
                    [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                });

                it(@"should have the correct number of segments", ^{
                    segmentedControl.numberOfSegments should equal(3);
                });

                it(@"should have selected the default segment", ^{
                    segmentedControl.selectedSegmentIndex should equal(0);
                });

                it(@"should style the segmented control", ^{
                    segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                });
                
                
            });
            
            context(@"When user(punch into activities user) is configured to transfer", ^{
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                    punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                    reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                    reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                    
                    subject.view should_not be_nil;
                    segmentedControl = subject.punchTypeSegmentedControl;
                });
                
                it(@"should have the correct titles", ^{
                    [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                });
                
                it(@"should have the correct number of segments", ^{
                    segmentedControl.numberOfSegments should equal(3);
                });
                
                it(@"should have selected the default segment", ^{
                    segmentedControl.selectedSegmentIndex should equal(0);
                });
                
                it(@"should style the segmented control", ^{
                    segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                });
                
                
            });
        });

        context(@"for supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
            });
            context(@"When breaks is configured", ^{
                context(@"for a user with activities", ^{
                    beforeEach(^{
                        reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                        reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });

                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Break", nil));
                        [segmentedControl titleForSegmentAtIndex:3] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(4);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with projects", ^{
                    beforeEach(^{
                        reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                        reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });

                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Break", nil));
                        [segmentedControl titleForSegmentAtIndex:3] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(4);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with no activities and projects", ^{
                    beforeEach(^{
                        reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });

                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Break", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(3);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });

            });

            context(@"When breaks is not configured", ^{
                context(@"for a user with activities", ^{
                    beforeEach(^{
                        reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                        reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });
                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(3);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with projects", ^{
                    beforeEach(^{
                        reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                        reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });
                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                        [segmentedControl titleForSegmentAtIndex:2] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(3);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
                context(@"for a user with no activities and projects", ^{
                    beforeEach(^{
                        reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                        subject.view should_not be_nil;
                        segmentedControl = subject.punchTypeSegmentedControl;
                    });
                    it(@"should have the correct titles", ^{
                        [segmentedControl titleForSegmentAtIndex:0] should equal(RPLocalizedString(@"Clock In", nil));
                        [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Clock Out", nil));
                    });

                    it(@"should have the correct number of segments", ^{
                        segmentedControl.numberOfSegments should equal(2);
                    });

                    it(@"should have selected the default segment", ^{
                        segmentedControl.selectedSegmentIndex should equal(0);
                    });

                    it(@"should style the segmented control", ^{
                        segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                    });
                });
            });

            context(@"When reportee is not configured to transfer", ^{
                beforeEach(^{
                    reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                    reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                    reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);

                    subject.view should_not be_nil;
                    segmentedControl = subject.punchTypeSegmentedControl;
                });

                it(@"should have the correct titles", ^{
                    [segmentedControl titleForSegmentAtIndex:1] should_not equal(RPLocalizedString(@"Transfer", nil));
                    [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Clock Out", nil));

                });

                it(@"should have the correct number of segments", ^{
                    segmentedControl.numberOfSegments should equal(2);
                });

                it(@"should have selected the default segment", ^{
                    segmentedControl.selectedSegmentIndex should equal(0);
                });

                it(@"should style the segmented control", ^{
                    segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                });


            });

            context(@"When reportee(punch into projects user) is configured to transfer", ^{
                beforeEach(^{
                    reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                    subject.view should_not be_nil;
                    segmentedControl = subject.punchTypeSegmentedControl;
                });

                it(@"should have the correct titles", ^{
                    [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                });

                it(@"should have the correct number of segments", ^{
                    segmentedControl.numberOfSegments should equal(3);
                });

                it(@"should have selected the default segment", ^{
                    segmentedControl.selectedSegmentIndex should equal(0);
                });

                it(@"should style the segmented control", ^{
                    segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                });


            });

            context(@"When reportee(punch into activities user) is configured to transfer", ^{
                beforeEach(^{

                    reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                    reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                    reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);


                    subject.view should_not be_nil;
                    segmentedControl = subject.punchTypeSegmentedControl;
                });

                it(@"should have the correct titles", ^{
                    [segmentedControl titleForSegmentAtIndex:1] should equal(RPLocalizedString(@"Transfer", nil));
                });
                
                it(@"should have the correct number of segments", ^{
                    segmentedControl.numberOfSegments should equal(3);
                });
                
                it(@"should have selected the default segment", ^{
                    segmentedControl.selectedSegmentIndex should equal(0);
                });
                
                it(@"should style the segmented control", ^{
                    segmentedControlStylist should have_received(@selector(styleSegmentedControl:)).with(segmentedControl);
                });
                
                
            });
        });

    });

    describe(@"tapping on the segmented controls", ^{

        context(@"user context", ^{
            beforeEach(^{
                 userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            });
            beforeEach(^{

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);
                punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                subject.view should_not be_nil;
                [subject.punchDetailsTableView layoutIfNeeded];

                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                [subject.punchDetailsTableView layoutIfNeeded];
            });

            it(@"should refresh the tableview", ^{
                UITableViewCell *cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                NSString *clockOut = RPLocalizedString(@"Clock Out", @"");
                cell.textLabel.text should equal(clockOut);
                cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
            });

            context(@"When EOF enabled on tap of Segment Clock In", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });
            context(@"When OEF enabled on tap of Segment Transfer", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });

            context(@"When EOF enabled on tap of Segment Break", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    BreakType *expectedBreakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:expectedBreakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });

            context(@"When EOF enabled on tap of Segment Clock Out", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{


                    punchRulesStorage stub_method(@selector(breaksRequired)).again().and_return(NO);

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                 userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
            });
            beforeEach(^{

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                subject.view should_not be_nil;
                [subject.punchDetailsTableView layoutIfNeeded];

                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                [subject.punchDetailsTableView layoutIfNeeded];
            });

            it(@"should refresh the tableview", ^{
                UITableViewCell *cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                NSString *clockOut = RPLocalizedString(@"Clock Out", @"");
                cell.textLabel.text should equal(clockOut);
                cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
            });
            context(@"When EOF enabled on tap of Segment Clock In on Supervisor flow", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });
            context(@"When OEF enabled on tap of Segment Transfer on Supervisor flow", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });
            context(@"When EOF enabled on tap of Segment Break on Supervisor flow", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{


                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    BreakType *expectedBreakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:expectedBreakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });
            context(@"When EOF enabled on tap of Segment Clock Out on Supervisor flow", ^{
                __block PunchAttributeController *newestPunchAttributeController;
                __block ManualPunch *expectedPunch;

                beforeEach(^{

                    newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                    [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                    ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];

                    [childControllerHelper reset_sent_messages];

                    [subject reloadWithNewPunchAttributes:localPunch];

                    expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                            .date];



                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];

                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should configure the new PunchAttributeController correctly", ^{
                    newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                });
            });

        });

        context(@"Tapping on last segment index which should be Clock Out", ^{
            context(@"user context", ^{
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                });
                beforeEach(^{

                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                          userURI:@"my-special-user-uri"
                                                             date:date];

                });
                context(@"When breaks is configured", ^{
                    __block PunchAttributeController<CedarDouble> *newestPunchAttributeController;
                    __block ManualPunch *expectedPunch;
                    context(@"for a user with activities", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);


                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with projects", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with no activities and projects", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);


                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });

                });
                context(@"When breaks is not configured", ^{
                    __block PunchAttributeController<CedarDouble> *newestPunchAttributeController;
                    __block ManualPunch *expectedPunch;
                    context(@"for a user with activities", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{

                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with projects", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with no activities and projects", ^{
                        beforeEach(^{
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasActivityAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(NO);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            
                            [childControllerHelper reset_sent_messages];
                            
                            [subject reloadWithNewPunchAttributes:localPunch];
                            
                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            
                            [newestPunchAttributeController reset_sent_messages];
                            
                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                        });
                        
                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });
                        
                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    
                });
            });
            context(@"supervisor context", ^{
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                });
                beforeEach(^{

                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                          userURI:@"my-special-user-uri"
                                                             date:date];

                });
                context(@"When breaks is configured", ^{
                    __block PunchAttributeController<CedarDouble> *newestPunchAttributeController;
                    __block ManualPunch *expectedPunch;
                    context(@"for a user with activities", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with projects", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with no activities and projects", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);


                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });

                });
                context(@"When breaks is not configured", ^{
                    __block PunchAttributeController<CedarDouble> *newestPunchAttributeController;
                    __block ManualPunch *expectedPunch;
                    context(@"for a user with activities", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{

                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with projects", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [newestPunchAttributeController reset_sent_messages];

                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        });

                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });

                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    context(@"for a user with no activities and projects", ^{
                        beforeEach(^{
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessActivityUserWithUri:)).with(@"my-special-user-uri").and_return(NO);
                            reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(NO);

                            [subject viewDidLoad];

                            newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                            [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];

                            ManualPunch *localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];

                            [childControllerHelper reset_sent_messages];

                            [subject reloadWithNewPunchAttributes:localPunch];

                            expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            
                            [newestPunchAttributeController reset_sent_messages];
                            
                            oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                        });
                        
                        it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
                        });
                        
                        it(@"should configure the new PunchAttributeController correctly", ^{
                            newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
                        });
                    });
                    
                });
            });

        });

    });

    describe(@"the tableview it presents", ^{
        __block UITableView *tableview;


        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                subject.view should_not be_nil;
                [subject viewWillAppear:NO];
                tableview = subject.punchDetailsTableView;
            });

            it(@"should have the correct width", ^{
                [subject.punchDetailsTableView layoutIfNeeded];
                CGRectGetWidth(tableview.bounds) should equal(CGRectGetWidth(subject.view.bounds));
            });

            it(@"should have two rows", ^{
                [tableview numberOfRowsInSection:0] should equal(2);
            });

            describe(@"the first row", ^{
                __block UITableViewCell *cell;

                context(@"when taking break", ^{
                    beforeEach(^{
                        BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                        BreakType *breakTypeB = [[BreakType alloc]initWithName:@"Break Type B" uri:@"Uri B"];
                        [breakTypeDeferred resolveWithValue:@[breakTypeA,breakTypeB]];
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        [subject.punchDetailsTableView layoutIfNeeded];
                        cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    });

                    it(@"should default to the first break type in the list", ^{
                        cell.textLabel.text should equal(RPLocalizedString(@"Break Type A", nil));
                    });

                    it(@"should initially show the break image", ^{
                        cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                        tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                        cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    });

                });

                context(@"when punching in i.e clockin", ^{
                    beforeEach(^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                        [subject.punchDetailsTableView layoutIfNeeded];
                        cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    });

                    it(@"should initially show the Clock In image", ^{
                        cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Clock In", nil));
                        tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                        cell.accessoryType should equal(UITableViewCellAccessoryNone);
                    });
                });

                context(@"when punching out i.e clockout", ^{
                    beforeEach(^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        [subject.punchDetailsTableView layoutIfNeeded];
                        cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    });

                    it(@"should initially show the Clock Out image", ^{
                        cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Clock Out", nil));
                        tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                        cell.accessoryType should equal(UITableViewCellAccessoryNone);
                    });
                });
            });

            describe(@"the second row", ^{
                __block UITableViewCell *cell;

                beforeEach(^{
                    dateFormatter stub_method(@selector(stringFromDate:)).and_return(@"My Special Date from DatePicker");
                    [tableview layoutIfNeeded];
                    cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });
                
                it(@"should have the correct label", ^{
                    cell.textLabel.text should equal(@"My Special Date from DatePicker");
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)0.0f);
                });
                
                it(@"should have the Disclosure Indicator", ^{
                    cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                });
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);

                subject.view should_not be_nil;
                [subject viewWillAppear:NO];
                tableview = subject.punchDetailsTableView;
            });

            it(@"should have the correct width", ^{
                [subject.punchDetailsTableView layoutIfNeeded];
                CGRectGetWidth(tableview.bounds) should equal(CGRectGetWidth(subject.view.bounds));
            });

            it(@"should have two rows", ^{
                [tableview numberOfRowsInSection:0] should equal(2);
            });

            describe(@"the first row", ^{
                __block UITableViewCell *cell;

                context(@"when taking break", ^{
                    beforeEach(^{
                        BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                        BreakType *breakTypeB = [[BreakType alloc]initWithName:@"Break Type B" uri:@"Uri B"];
                        [breakTypeDeferred resolveWithValue:@[breakTypeA,breakTypeB]];
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        [subject.punchDetailsTableView layoutIfNeeded];
                        cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    });

                    it(@"should default to the first break type in the list", ^{
                        cell.textLabel.text should equal(RPLocalizedString(@"Break Type A", nil));
                    });

                    it(@"should initially show the break image", ^{
                        cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                        tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                        cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                    });

                });

                context(@"when punching in i.e clockin", ^{
                    beforeEach(^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                        [subject.punchDetailsTableView layoutIfNeeded];
                        cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    });

                    it(@"should initially show the Clock In image", ^{
                        cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Clock In", nil));
                        tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                        cell.accessoryType should equal(UITableViewCellAccessoryNone);
                    });
                });

                context(@"when punching out i.e clockout", ^{
                    beforeEach(^{
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        [subject.punchDetailsTableView layoutIfNeeded];
                        cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    });

                    it(@"should initially show the Clock Out image", ^{
                        cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
                        cell.textLabel.text should equal(RPLocalizedString(@"Clock Out", nil));
                        tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                        cell.accessoryType should equal(UITableViewCellAccessoryNone);
                    });
                });
            });

            describe(@"the second row", ^{
                __block UITableViewCell *cell;

                beforeEach(^{
                    dateFormatter stub_method(@selector(stringFromDate:)).and_return(@"My Special Date from DatePicker");
                    [tableview layoutIfNeeded];
                    cell = [tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });
                
                it(@"should have the correct label", ^{
                    cell.textLabel.text should equal(@"My Special Date from DatePicker");
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)0.0f);
                });
                
                it(@"should have the Disclosure Indicator", ^{
                    cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
                });
            });
        });

    });

    describe(@"selecting a punch type", ^{
        __block UITableViewCell *cell;
        __block PunchAttributeController *newPunchAttributeController;
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                subject.view should_not be_nil;
                [subject.punchDetailsTableView layoutIfNeeded];

                newPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeController];

            });

            context(@"If the user is Punching in", ^{
                beforeEach(^{
                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should have the correct image and label", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Clock In", nil));
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });
            });


            context(@"If the user is taking a Break", ^{
                __block UIActionSheet *actionSheet;

                beforeEach(^{
                    BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                    BreakType *breakTypeB = [[BreakType alloc]initWithName:@"Break Type B" uri:@"Uri B"];
                    [breakTypeDeferred resolveWithValue:@[breakTypeA,breakTypeB]];

                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                    [subject.punchDetailsTableView layoutIfNeeded];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should default to the first break type in the list", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Break Type A", nil));
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                context(@"when the user selects a break type", ^{
                    beforeEach(^{
                        [cell tap];

                        actionSheet = [UIActionSheet currentActionSheet];
                    });

                    it(@"should show the break list action sheet", ^{
                        [actionSheet buttonTitles] should equal(@[RPLocalizedString(@"Cancel", @""), (RPLocalizedString(@"Break Type A", nil)), (RPLocalizedString(@"Break Type B", nil))]);
                    });

                    it(@"should deselect the table row", ^{
                        [subject.punchDetailsTableView indexPathForSelectedRow] should be_nil;
                    });

                    it(@"should set the correct selection style", ^{
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                    });

                    context(@"after the user selects a break type", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingButtonWithTitle:@"Break Type B"];

                            [subject.punchDetailsTableView layoutIfNeeded];
                            cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        });

                        it(@"should have the correct image and label for the break selected", ^{
                            cell.textLabel.text should equal(@"Break Type B");
                        });
                    });

                    context(@"when the user taps the cancel button", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingCancelButton];
                        });

                        it(@"should not change the break type label", ^{
                            cell.textLabel.text should equal(@"Break Type A");
                        });
                    });
                });
            });

            context(@"If the user is Punching out", ^{
                beforeEach(^{
                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                    [subject.punchDetailsTableView layoutIfNeeded];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should set the correct selection style", ^{
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                });

                it(@"should not do anything if the user taps the cell", ^{
                    [cell tap];
                    [UIActionSheet currentActionSheet] should be_nil;;
                });

                it(@"should have the correct image and label", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Clock Out", nil));
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                });
            });

            context(@"If the user is transferring a punch", ^{
                beforeEach(^{
                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should have the correct image and label", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Transfer", nil));
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });
            });

            context(@"If the user is selecting a date , and then tries taking a break", ^{
                __block UIActionSheet *actionSheet;
                beforeEach(^{
                    BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                    BreakType *breakTypeB = [[BreakType alloc]initWithName:@"Break Type B" uri:@"Uri B"];
                    [breakTypeDeferred resolveWithValue:@[breakTypeA,breakTypeB]];

                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                    [subject.punchDetailsTableView layoutIfNeeded];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    UITableViewCell *dateCell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    [dateCell tap];
                });

                it(@"should default to the first break type in the list", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Break Type A", nil));
                });

                context(@"when the user selects a break type", ^{
                    beforeEach(^{
                        [cell tap];

                        actionSheet = [UIActionSheet currentActionSheet];
                    });

                    it(@"should hide the datepicker", ^{
                        subject.datePicker.hidden should be_truthy;
                    });

                    it(@"should hide the toolbar accompanying the datepicker", ^{
                        subject.toolBar.hidden should be_truthy;
                    });

                    it(@"should show the break list action sheet", ^{
                        [actionSheet buttonTitles] should equal(@[RPLocalizedString(@"Cancel", @""), (RPLocalizedString(@"Break Type A", nil)), (RPLocalizedString(@"Break Type B", nil))]);
                    });

                    it(@"should deselect the table row", ^{
                        [subject.punchDetailsTableView indexPathForSelectedRow] should be_nil;
                    });
                    
                    it(@"should set the correct selection style", ^{
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                    });
                    
                    context(@"after the user selects a break type", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingButtonWithTitle:@"Break Type B"];
                            
                            [subject.punchDetailsTableView layoutIfNeeded];
                            cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        });
                        
                        it(@"should have the correct image and label for the break selected", ^{
                            cell.textLabel.text should equal(@"Break Type B");
                        });
                    });
                    
                    context(@"when the user taps the cancel button", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingCancelButton];
                        });
                        
                        it(@"should not change the break type label", ^{
                            cell.textLabel.text should equal(@"Break Type A");
                        });
                    });
                });
            });
        });
        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                 reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                subject.view should_not be_nil;
                [subject.punchDetailsTableView layoutIfNeeded];

                newPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeController];

            });

            context(@"If the user is Punching in", ^{
                beforeEach(^{
                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should have the correct image and label", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Clock In", nil));
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });
            });


            context(@"If the user is taking a Break", ^{
                __block UIActionSheet *actionSheet;

                beforeEach(^{
                    BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                    BreakType *breakTypeB = [[BreakType alloc]initWithName:@"Break Type B" uri:@"Uri B"];
                    [breakTypeDeferred resolveWithValue:@[breakTypeA,breakTypeB]];

                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                    [subject.punchDetailsTableView layoutIfNeeded];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should default to the first break type in the list", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Break Type A", nil));
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                context(@"when the user selects a break type", ^{
                    beforeEach(^{
                        [cell tap];

                        actionSheet = [UIActionSheet currentActionSheet];
                    });

                    it(@"should show the break list action sheet", ^{
                        [actionSheet buttonTitles] should equal(@[RPLocalizedString(@"Cancel", @""), (RPLocalizedString(@"Break Type A", nil)), (RPLocalizedString(@"Break Type B", nil))]);
                    });

                    it(@"should deselect the table row", ^{
                        [subject.punchDetailsTableView indexPathForSelectedRow] should be_nil;
                    });

                    it(@"should set the correct selection style", ^{
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                    });

                    context(@"after the user selects a break type", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingButtonWithTitle:@"Break Type B"];

                            [subject.punchDetailsTableView layoutIfNeeded];
                            cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        });

                        it(@"should have the correct image and label for the break selected", ^{
                            cell.textLabel.text should equal(@"Break Type B");
                        });
                    });

                    context(@"when the user taps the cancel button", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingCancelButton];
                        });

                        it(@"should not change the break type label", ^{
                            cell.textLabel.text should equal(@"Break Type A");
                        });
                    });
                });
            });

            context(@"If the user is Punching out", ^{
                beforeEach(^{
                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                    [subject.punchDetailsTableView layoutIfNeeded];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });

                it(@"should set the correct selection style", ^{
                    cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                });

                it(@"should not do anything if the user taps the cell", ^{
                    [cell tap];
                    [UIActionSheet currentActionSheet] should be_nil;;
                });

                it(@"should have the correct image and label", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Clock Out", nil));
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                });
            });

            context(@"If the user is transferring a punch", ^{
                beforeEach(^{
                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should have the correct image and label", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Transfer", nil));
                    tableViewCellStylist should have_received(@selector(styleCell:separatorOffset:)).with(cell, (CGFloat)24.0f);
                });

                it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(punchAttributeController,newPunchAttributeController,subject,subject.punchAttributeContainerView);
                });
            });

            context(@"If the user is selecting a date , and then tries taking a break", ^{
                __block UIActionSheet *actionSheet;
                beforeEach(^{
                    BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                    BreakType *breakTypeB = [[BreakType alloc]initWithName:@"Break Type B" uri:@"Uri B"];
                    [breakTypeDeferred resolveWithValue:@[breakTypeA,breakTypeB]];

                    [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                    [subject.punchDetailsTableView layoutIfNeeded];
                    cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    UITableViewCell *dateCell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    [dateCell tap];
                });

                it(@"should default to the first break type in the list", ^{
                    cell.imageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    cell.textLabel.text should equal(RPLocalizedString(@"Break Type A", nil));
                });

                context(@"when the user selects a break type", ^{
                    beforeEach(^{
                        [cell tap];

                        actionSheet = [UIActionSheet currentActionSheet];
                    });

                    it(@"should hide the datepicker", ^{
                        subject.datePicker.hidden should be_truthy;
                    });

                    it(@"should hide the toolbar accompanying the datepicker", ^{
                        subject.toolBar.hidden should be_truthy;
                    });

                    it(@"should show the break list action sheet", ^{
                        [actionSheet buttonTitles] should equal(@[RPLocalizedString(@"Cancel", @""), (RPLocalizedString(@"Break Type A", nil)), (RPLocalizedString(@"Break Type B", nil))]);
                    });

                    it(@"should deselect the table row", ^{
                        [subject.punchDetailsTableView indexPathForSelectedRow] should be_nil;
                    });

                    it(@"should set the correct selection style", ^{
                        cell.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                    });

                    context(@"after the user selects a break type", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingButtonWithTitle:@"Break Type B"];

                            [subject.punchDetailsTableView layoutIfNeeded];
                            cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                        });

                        it(@"should have the correct image and label for the break selected", ^{
                            cell.textLabel.text should equal(@"Break Type B");
                        });
                    });
                    
                    context(@"when the user taps the cancel button", ^{
                        beforeEach(^{
                            [actionSheet dismissByClickingCancelButton];
                        });
                        
                        it(@"should not change the break type label", ^{
                            cell.textLabel.text should equal(@"Break Type A");
                        });
                    });
                });
            });
        });

    });

    describe(@"selecting a punch date", ^{
        __block UITableViewCell *cell;

        beforeEach(^{
             userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
            subject.view should_not be_nil;
            [subject.datePicker layoutIfNeeded];
            [subject.punchDetailsTableView layoutIfNeeded];
            [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
            cell = [subject.punchDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            [cell tap];
        });

        it(@"should display the date correctly in the datePicker", ^{
            subject.datePicker.date should equal(date);
        });
        it(@"should not hide the datepicker", ^{
            subject.datePicker.hidden should be_falsy;
        });
        it(@"should not hide the toolbar accompanying the datepicker", ^{
            subject.toolBar.hidden should be_falsy;
        });

    });

    describe(@"picking a date", ^{
        __block NSDate *expectedDate;
        __block UITableViewCell *dateTableviewCell;
        beforeEach(^{
             userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
        });

        describe(@"the initial date", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });
            it(@"should hide the datepicker", ^{
                subject.datePicker.hidden should be_truthy;
            });
            it(@"should hide the toolbar accompanying the datepicker", ^{
                subject.toolBar.hidden should be_truthy;
            });
            it(@"should show the date that it was set up with", ^{
                subject.datePicker.date should equal(date);
            });

        });

        describe(@"selecting a new date", ^{
            beforeEach(^{
                subject.view should_not be_nil;
                expectedDate = [NSDate dateWithTimeIntervalSince1970:1432745892];
                [subject.datePicker setDate:expectedDate];
                dateFormatter stub_method(@selector(stringFromDate:)).with(expectedDate).and_return(@"Wed, May, 27 4:58 PM");

                [subject.punchDetailsTableView layoutIfNeeded];
                spy_on(subject.punchDetailsTableView);
                [subject.datePicker sendActionsForControlEvents:UIControlEventValueChanged];
            });

            it(@"should update the date from the datePicker on the table view cell for date", ^{
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
                NSArray *indexpathArray = @[indexpath];
                subject.punchDetailsTableView should have_received(@selector(reloadRowsAtIndexPaths:withRowAnimation:)).with(indexpathArray,UITableViewRowAnimationNone);
                dateTableviewCell = [subject.punchDetailsTableView cellForRowAtIndexPath:indexpath];
                dateTableviewCell.textLabel.text should equal(@"Wed, May, 27 4:58 PM");
            });
        });
    });

    describe(@"saving a manual punch", ^{
        
        context(@"When valid project or task info is provided", ^{
            
            __block UINavigationController *navigationController;
            __block UIViewController *rootViewController;
            __block KSDeferred *punchDeferred;
            __block KSDeferred *timesummaryDeferred;
            __block TaskType *task;
            __block ProjectType *project;
            __block ClientType *client;
            
            beforeEach(^{
                 userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                timesummaryDeferred = [KSDeferred defer];
                punchChangeObserverDelegate stub_method(@selector(punchOverviewEditControllerDidUpdatePunch)).and_return(timesummaryDeferred.promise);
                punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                
                subject.view should_not be_nil;
                
                rootViewController = [[UIViewController alloc] init];
                
                navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                [navigationController pushViewController:subject animated:NO];
                
                punchDeferred = [[KSDeferred alloc] init];
                punchRepository stub_method(@selector(persistPunch:)).and_return(punchDeferred.promise);
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                [breakTypeDeferred resolveWithValue:@[breakType]];
            });
            
            describe(@"punching in", ^{
                context(@"when Network is Reachable", ^{
                    __block KSDeferred *addPunchDeferred;
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                        addPunchDeferred = [[KSDeferred alloc]init];
                        
                        punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).and_return(addPunchDeferred.promise);
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                        
                    });
                    
                    describe(@"punching in with OEFs", ^{
                        __block KSDeferred *addPunchDeferred;
                        
                        beforeEach(^{
                            addPunchDeferred = [[KSDeferred alloc]init];
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                            
                        });
                    });
                    
                    describe(@"punching in with OEFs with valid project/task with NO client access", ^{
                        __block KSDeferred *addPunchDeferred;
                        
                        beforeEach(^{
                            addPunchDeferred = [[KSDeferred alloc]init];
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                            
                        });
                    });
                    
                    describe(@"punching in with OEFs with valid project/task with client access", ^{
                        __block KSDeferred *addPunchDeferred;
                        
                        beforeEach(^{
                            addPunchDeferred = [[KSDeferred alloc]init];
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            client = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            punch stub_method(@selector(client)).and_return(client);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                            
                        });
                    });
                    
                    context(@"validate valid task and project in user context", ^{
                        beforeEach(^{
                            
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                            [subject punchAttributeController:nil didIntendToUpdateProject:project];
                            [subject punchAttributeController:nil didIntendToUpdateTask:task];
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        
                        
                        it(@"should validate project and task on tranfer", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:task date:subject.datePicker
                                    .date];
                            
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).with(expectedPunch.client, expectedPunch.project,expectedPunch.task, expectedPunch.activity, expectedPunch.userURI);
                        });
                    });
                    
                    context(@"validate valid task and project in Supervisor context", ^{
                        beforeEach(^{
                            
                            userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-special-user-uri"
                                                                     date:date];
                            
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                            [subject punchAttributeController:nil didIntendToUpdateProject:project];
                            [subject punchAttributeController:nil didIntendToUpdateTask:task];
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        
                        
                        it(@"should validate project and task on tranfer", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).with(expectedPunch.client, expectedPunch.project,expectedPunch.task, expectedPunch.activity, expectedPunch.userURI);
                        });
                    });
                    
                    context(@"When manual punch succeeds", ^{
                        beforeEach(^{
                            [addPunchDeferred resolveWithValue:[NSNull null]];
                        });
                        
                        it(@"should inform its observer", ^{
                            punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        context(@"When timesummary fetch succeeds", ^{
                            beforeEach(^{
                                [timesummaryDeferred resolveWithValue:nil];
                            });
                            
                            it(@"should hide the spinner", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should dismiss itself", ^{
                                navigationController.topViewController should be_same_instance_as(rootViewController);
                            });
                        });
                        
                        context(@"When timesummary fetch fails", ^{
                            beforeEach(^{
                                [timesummaryDeferred rejectWithError:nil];
                            });
                            
                            it(@"should hide the spinner", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should dismiss itself", ^{
                                navigationController.topViewController should be_same_instance_as(rootViewController);
                            });
                        });
                    });
                    
                    context(@"When manual punch fails", ^{
                        beforeEach(^{
                            NSError *error;
                            [addPunchDeferred rejectWithError:error];
                        });
                        
                        it(@"should inform its observer", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should hide the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                });
                
                context(@"when Network is not Reachable", ^{
                    __block KSDeferred *addPunchDeferred;
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                        
                        addPunchDeferred = [[KSDeferred alloc]init];
                        
                        punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).and_return(addPunchDeferred.promise);
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        punchClock should_not have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                        
                    });
                    
                    it(@"should show offline message", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                    });
                });
            });
            
            describe(@"punching out", ^{
                context(@"when Network is Reachable", ^{
                    __block TaskType *task;
                    __block ProjectType *project;
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                        project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                      isTimeAllocationAllowed:NO
                                                                                projectPeriod:nil
                                                                                   clientType:nil
                                                                                         name:@"project-name"
                                                                                          uri:nil];
                        
                        task = [[TaskType alloc] initWithProjectUri:nil
                                                         taskPeriod:nil
                                                               name:@"task-name"
                                                                uri:@"task-uri"];
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                    });
                    
                    it(@"should validate valid project and task", ^{
                        punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        
                    });
                    
                    describe(@"punching out with OEFs", ^{
                        __block TaskType *task;
                        __block ProjectType *project;
                        
                        beforeEach(^{
                            
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                        });
                        
                        it(@"should validate valid project and task", ^{
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                            
                        });
                        
                    });
                    
                    describe(@"punching out with OEFs with valid project/task and With NO client Access", ^{
                        __block TaskType *task;
                        __block ProjectType *project;
                        __block ClientType *client;
                        
                        beforeEach(^{
                            
                            client = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                        });
                        
                        it(@"should validate valid project and task", ^{
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                            
                        });
                        
                    });
                    
                    describe(@"punching out with OEFs with valid project/task and With NO client Access", ^{
                        __block TaskType *task;
                        __block ProjectType *project;
                        __block ClientType *client;
                        
                        beforeEach(^{
                            
                            client = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            punch stub_method(@selector(client)).and_return(client);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                        });
                        
                        it(@"should validate valid project and task", ^{
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                            
                        });
                        
                    });
                });
                
                context(@"when Network is not Reachable", ^{
                    __block TaskType *task;
                    __block ProjectType *project;
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                        project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                      isTimeAllocationAllowed:NO
                                                                                projectPeriod:nil
                                                                                   clientType:nil
                                                                                         name:@"project-name"
                                                                                          uri:nil];
                        
                        task = [[TaskType alloc] initWithProjectUri:nil
                                                         taskPeriod:nil
                                                               name:@"task-name"
                                                                uri:@"task-uri"];
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        punchClock should_not have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                    });
                    it(@"should show offline message", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                    });
                });
            });
            
            describe(@"going on break", ^{
                context(@"when Network is Reachable", ^{
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        
                        punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                        punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                    });
                    
                    it(@"should validate valid project and task", ^{
                        punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        
                    });
                    
                    
                    describe(@"going on break with OEFs", ^{
                        
                        beforeEach(^{
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            BreakType *breakType_ = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(breakType)).and_return(breakType_);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should validate valid project and task", ^{
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                            
                        });
                    });
                    
                    describe(@"going on break with OEFs with valid project/task and With NO client Access ", ^{
                        
                        beforeEach(^{
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            BreakType *breakType_ = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                            
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(breakType)).and_return(breakType_);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should validate valid project and task", ^{
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                            
                        });
                    });
                    
                    describe(@"going on break with OEFs with valid project/task and With client Access ", ^{
                        
                        beforeEach(^{
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            BreakType *breakType_ = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                            
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(breakType)).and_return(breakType_);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            punch stub_method(@selector(client)).and_return(client);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should validate valid project and task", ^{
                            punchValidator should_not have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                            
                        });
                    });
                });
                
                context(@"when Network is not Reachable", ^{
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type A" uri:@"Uri A"];
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        
                        punchClock should_not have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                    });
                    it(@"should show offline message", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                    });
                });
            });
            
            describe(@"transferring punch", ^{
                
                context(@"when Network is Reachable", ^{
                    __block KSDeferred *addPunchDeferred;
                    __block TaskType *task;
                    __block ProjectType *project;
                    
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                        addPunchDeferred = [[KSDeferred alloc]init];
                        
                        punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).and_return(addPunchDeferred.promise);
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                    });
                    
                    
                    describe(@"transferring punch with OEFs", ^{
                        __block KSDeferred *addPunchDeferred;
                        beforeEach(^{
                            
                            addPunchDeferred = [[KSDeferred alloc]init];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                            
                            
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                        });
                    });
                    
                    describe(@"transferring punch with OEFs with valid Project/Task info With NO client access", ^{
                        __block KSDeferred *addPunchDeferred;
                        beforeEach(^{
                            
                            addPunchDeferred = [[KSDeferred alloc]init];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(NO);
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                        });
                    });
                    
                    describe(@"transferring punch with OEFs with valid Project/Task info With client access", ^{
                        __block KSDeferred *addPunchDeferred;
                        beforeEach(^{
                            
                            addPunchDeferred = [[KSDeferred alloc]init];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            
                            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                            
                            oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                            
                            LocalPunch *punch = nice_fake_for([ManualPunch class]);
                            
                            punch stub_method(@selector(oefTypesArray)).and_return(@[oefType1, oefType2, oefType3]);
                            punch stub_method(@selector(userURI)).and_return(@"my-special-user-uri");
                            punch stub_method(@selector(requestID)).and_return(@"guid-A");
                            punch stub_method(@selector(date)).and_return(subject.datePicker.date);
                            punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                            punch stub_method(@selector(punchSyncStatus)).and_return(UnsubmittedSyncStatus);
                            punch stub_method(@selector(project)).and_return(project);
                            punch stub_method(@selector(task)).and_return(task);
                            punch stub_method(@selector(client)).and_return(client);
                            
                            (id<CedarDouble>)subject stub_method(@selector(punch)).and_return(punch);
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        
                        it(@"should punch on the punch clock", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                            
                        });
                    });
                    
                    
                    context(@"validate valid task and project in user context", ^{
                        beforeEach(^{
                            
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                            [subject punchAttributeController:nil didIntendToUpdateProject:project];
                            [subject punchAttributeController:nil didIntendToUpdateTask:task];
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        
                        
                        it(@"should validate project and task on tranfer", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:task date:subject.datePicker
                                    .date];
                            
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).with(expectedPunch.client, expectedPunch.project,expectedPunch.task, expectedPunch.activity, expectedPunch.userURI);
                        });
                    });
                    
                    context(@"validate valid task and project in Supervisor context", ^{
                        beforeEach(^{
                            
                            userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                            reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).and_return(YES);
                            
                            punchRulesStorage stub_method(@selector(hasProjectAccess)).again().and_return(YES);
                            punchRulesStorage stub_method(@selector(hasClientAccess)).again().and_return(YES);
                            
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-special-user-uri"
                                                                     date:date];
                            
                            
                            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                          isTimeAllocationAllowed:NO
                                                                                    projectPeriod:nil
                                                                                       clientType:nil
                                                                                             name:@"project-name"
                                                                                              uri:nil];
                            
                            task = [[TaskType alloc] initWithProjectUri:nil
                                                             taskPeriod:nil
                                                                   name:@"task-name"
                                                                    uri:@"task-uri"];
                            
                            punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).again().and_return(addPunchDeferred.promise);
                            [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                            [subject punchAttributeController:nil didIntendToUpdateProject:project];
                            [subject punchAttributeController:nil didIntendToUpdateTask:task];
                            
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        
                        
                        it(@"should validate project and task on tranfer", ^{
                            ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                                    .date];
                            
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).with(expectedPunch.client, expectedPunch.project,expectedPunch.task, expectedPunch.activity, expectedPunch.userURI);
                        });
                    });
                    
                    context(@"When manual punch succeeds", ^{
                        beforeEach(^{
                            [addPunchDeferred resolveWithValue:[NSNull null]];
                        });
                        
                        it(@"should inform its observer", ^{
                            punchChangeObserverDelegate should have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        context(@"When timesummary fetch succeeds", ^{
                            beforeEach(^{
                                [timesummaryDeferred resolveWithValue:nil];
                            });
                            
                            it(@"should hide the spinner", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should dismiss itself", ^{
                                navigationController.topViewController should be_same_instance_as(rootViewController);
                            });
                        });
                        
                        context(@"When timesummary fetch fails", ^{
                            beforeEach(^{
                                [timesummaryDeferred rejectWithError:nil];
                            });
                            
                            it(@"should hide the spinner", ^{
                                spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                            });
                            
                            it(@"should dismiss itself", ^{
                                navigationController.topViewController should be_same_instance_as(rootViewController);
                            });
                        });
                    });
                    
                    context(@"When manual punch fails", ^{
                        beforeEach(^{
                            NSError *error;
                            [addPunchDeferred rejectWithError:error];
                        });
                        
                        it(@"should inform its observer", ^{
                            punchChangeObserverDelegate should_not have_received(@selector(punchOverviewEditControllerDidUpdatePunch));
                        });
                        
                        it(@"should hide the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });
                    });
                });
                
                context(@"when Network is not Reachable", ^{
                    __block KSDeferred *addPunchDeferred;
                    beforeEach(^{
                        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                        addPunchDeferred = [[KSDeferred alloc]init];
                        
                        punchClock stub_method(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).and_return(addPunchDeferred.promise);
                        [subject.punchTypeSegmentedControl selectSegmentAtIndex:1];
                        [subject.navigationItem.rightBarButtonItem tap];
                    });
                    
                    it(@"should punch on the punch clock", ^{
                        ManualPunch *expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                                .date];
                        punchClock should_not have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
                        
                    });
                    it(@"should show offline message", ^{
                        UIAlertView *alertView = [UIAlertView currentAlertView];
                        alertView.message should equal(RPLocalizedString(offlineMessage, offlineMessage));
                    });
                });
            });
        });
        
        context(@"When invalid project or task info is provided", ^{
            
            context(@"When Punch into Project User", ^{
                
                context(@"When Project is nil", ^{
                    
                    context(@"user context", ^{
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidProjectSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            
                            userSession stub_method(@selector(currentUserURI)).and_return(@"my-awesome_user_uri");
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-awesome_user_uri"
                                                                     date:date];
                            subject.view should_not be_nil;
                            [subject.navigationItem.rightBarButtonItem tap];
                        });
                        it(@"should validate the project and task type", ^{
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should show the correct validation message to the user", ^{
                            UIAlertView *alertView = [UIAlertView currentAlertView];
                            alertView.message should equal(InvalidProjectSelectedError);
                        });
                    });
                    
                    context(@"reportee context", ^{
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidProjectSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            userSession stub_method(@selector(currentUserURI)).and_return(@"my-some-awesome_user_uri");
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-awesome_user_uri"
                                                                     date:date];
                            
                            subject.view should_not be_nil;
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        it(@"should validate the project and task type", ^{
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should show the correct validation message to the user", ^{
                            UIAlertView *alertView = [UIAlertView currentAlertView];
                            alertView.message should equal(InvalidProjectSelectedError);
                        });
                    });
                    
                });
                
                context(@"When Task is nil", ^{
                    
                    context(@"user context", ^{
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidTaskSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            userSession stub_method(@selector(currentUserURI)).and_return(@"my-awesome_user_uri");
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-awesome_user_uri"
                                                                     date:date];
                            subject.view should_not be_nil;
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        it(@"should validate the project and task type", ^{
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should show the correct validation message to the user", ^{
                            UIAlertView *alertView = [UIAlertView currentAlertView];
                            alertView.message should equal(InvalidTaskSelectedError);
                        });
                    });
                    
                    context(@"reportee context", ^{
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidTaskSelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            userSession stub_method(@selector(currentUserURI)).and_return(@"my-some-awesome_user_uri");
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-awesome_user_uri"
                                                                     date:date];
                            
                            subject.view should_not be_nil;
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        it(@"should validate the project and task type", ^{
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should show the correct validation message to the user", ^{
                            UIAlertView *alertView = [UIAlertView currentAlertView];
                            alertView.message should equal(InvalidTaskSelectedError);
                        });
                    });
                    
                });
                
            });
            
            context(@"When Punch into Activity User", ^{
                
                context(@"When Activity is nil", ^{
                    
                    context(@"user context", ^{
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidActivitySelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            userSession stub_method(@selector(currentUserURI)).and_return(@"my-awesome_user_uri");
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-awesome_user_uri"
                                                                     date:date];
                            subject.view should_not be_nil;
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        it(@"should validate the project and task type", ^{
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should show the correct validation message to the user", ^{
                            UIAlertView *alertView = [UIAlertView currentAlertView];
                            alertView.message should equal(InvalidActivitySelectedError);
                        });
                    });
                    
                    context(@"reportee context", ^{
                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            NSDictionary* userInfo = @{NSLocalizedDescriptionKey: InvalidActivitySelectedError};
                            NSError *error = [[NSError alloc] initWithDomain:@"" code:500 userInfo:userInfo];
                            punchValidator stub_method(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:)).again().and_return(error);
                            userSession stub_method(@selector(currentUserURI)).and_return(@"my-some-awesome_user_uri");
                            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                                  userURI:@"my-awesome_user_uri"
                                                                     date:date];
                            
                            subject.view should_not be_nil;
                            [subject.navigationItem.rightBarButtonItem tap];
                            
                        });
                        it(@"should validate the project and task type", ^{
                            punchValidator should have_received(@selector(validatePunchWithClientType:projectType:taskType:activityType:userUri:));
                        });
                        
                        it(@"should show the correct validation message to the user", ^{
                            UIAlertView *alertView = [UIAlertView currentAlertView];
                            alertView.message should equal(InvalidActivitySelectedError);
                        });
                    });
                    
                });
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
            __block KSDeferred *punchDeferred;
            __block UINavigationController *navigationController;
            __block UIViewController *rootViewController;
            __block id<BSBinder, BSInjector> injector;
            context(@"When there are observers", ^{
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                    [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                          userURI:@"my-special-user-uri"
                                                             date:date];
                    injector=[InjectorProvider injector];
                    punchDeferred = [[KSDeferred alloc] init];
                    rootViewController = [injector getInstance:[PunchHomeController class]];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                    [navigationController pushViewController:subject animated:NO];

                    spy_on(rootViewController);

                    [subject punchAssemblyWorkflow:nil
               willEventuallyFinishIncompletePunch:nil
                             assembledPunchPromise:nil
                       serverDidFinishPunchPromise:punchDeferred.promise];
                });

                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });


                describe(@"when the request succeeds", ^{


                    describe(@"when network is offline", ^{

                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
                            [punchDeferred resolveWithValue:nil];

                        });

                        it(@"should hide the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });

                        it(@"should dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(rootViewController);
                        });
                        
                    });

                    describe(@"when network is online", ^{

                        beforeEach(^{
                            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                            [punchDeferred resolveWithValue:nil];
                        });

                        it(@"should hide the spinner", ^{
                            spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                        });

                        it(@"should dismiss itself", ^{
                            navigationController.topViewController should_not be_same_instance_as(rootViewController);
                        });

                        it(@"should punch on the punch clock", ^{
                            punchClock should_not have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:));
                        });

                        it(@"should have called Punch Respository with correct user uri", ^{
                            punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"my-special-user-uri");
                        });
                        
                    });

                });

                describe(@"when the request fails", ^{
                    beforeEach(^{
                        [punchDeferred rejectWithError:nil];
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                });
            });

            context(@"When there are no observers", ^{
                __block KSDeferred *mostRecentDeferred;
                beforeEach(^{
                    reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                    mostRecentDeferred = [KSDeferred defer];
                    [subject setupWithPunchChangeObserverDelegate:nil
                                                          userURI:@"my-special-user-uri"
                                                             date:date];
                    punchRepository stub_method(@selector(fetchMostRecentPunchForUserUri:)).and_return(mostRecentDeferred.promise);
                    injector=[InjectorProvider injector];
                    punchDeferred = [[KSDeferred alloc] init];
                    rootViewController = [injector getInstance:[PunchHomeController class]];
                    navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                    [navigationController pushViewController:subject animated:NO];

                    spy_on(rootViewController);

                    [subject punchAssemblyWorkflow:nil
               willEventuallyFinishIncompletePunch:nil
                             assembledPunchPromise:nil
                       serverDidFinishPunchPromise:punchDeferred.promise];
                });

                it(@"should display the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });



                describe(@"when the request succeeds", ^{
                    beforeEach(^{
                        [punchDeferred resolveWithValue:nil];
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should_not have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should dismiss itself", ^{
                        navigationController.topViewController should_not be_same_instance_as(rootViewController);
                    });

                    it(@"should have called Punch Respository with correct user uri", ^{
                        punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"my-special-user-uri");
                    });

                    context(@"When the most recent punch succeeds", ^{
                        beforeEach(^{
                            [mostRecentDeferred resolveWithValue:nil];
                        });

                        it(@"should hide the spinner", ^{
                            spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                        });

                        it(@"should dismiss itself", ^{
                            navigationController.topViewController should be_same_instance_as(rootViewController);
                        });

                        it(@"should have called Punch Respository with correct user uri", ^{
                            punchRepository should have_received(@selector(fetchMostRecentPunchForUserUri:)).with(@"my-special-user-uri");
                        });
                    });

                });

                describe(@"when the request fails", ^{
                    beforeEach(^{
                        [punchDeferred rejectWithError:nil];
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should not dismiss itself", ^{
                        navigationController.topViewController should be_same_instance_as(subject);
                    });
                });
            });
        });

        describe(@"-punchAssemblyWorkflow:didFailToAssembleIncompletePunch", ^{
            describe(@"when the punch assembly workflow failed to get access to the phone's location / camera", ^{
                __block NSError *locationError;
                __block NSError *cameraError;
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                    [subject setupWithPunchChangeObserverDelegate:nil
                                                          userURI:@"my-special-user-uri"
                                                             date:date];
                    locationError = [[NSError alloc] initWithDomain:LocationAssemblyGuardErrorDomain code:LocationAssemblyGuardErrorCodeDeniedAccessToLocation userInfo:nil];
                    cameraError = [[NSError alloc] initWithDomain:CameraAssemblyGuardErrorDomain
                                                             code:CameraAssemblyGuardErrorCodeDeniedAccessToCamera
                                                         userInfo:nil];
                    NSError *unhandledError = [[NSError alloc] init];

                    [subject view];
                    [subject viewWillAppear:YES];

                    [subject punchAssemblyWorkflow:(id) [NSNull null]
                  didFailToAssembleIncompletePunch:(id) [NSNull null]
                                            errors:@[locationError, unhandledError, cameraError]];
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
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
        });

        describe(@"-imagePickerControllerDidCancel:", ^{
            context(@"When the user cancels the image picker operation", ^{
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
        });

        describe(@"-imagePickerController:didFinishPickingMediaWithInfo:", ^{
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

                [imagePromise then:^id(UIImage *image) {
                    fulfilledImage = image;
                    return nil;
                }
                             error:^id(NSError *error) {
                                 throw @"Image promise should not have been rejected";
                                 return nil;
                             }];

                fulfilledImage should be_same_instance_as(normalizedImage);
            });

            it(@"should dismiss the image picker view", ^{
                imagePicker should have_received(@selector(dismissViewControllerAnimated:completion:)).with(YES, nil);
            });
        });
    });

    describe(@"Tapping on Done on toolbar", ^{
        beforeEach(^{
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            subject.view should_not be_nil;
            [subject.doneButtonOnToolBar tap];
        });

        it(@"should hide the datepicker", ^{
            subject.datePicker.hidden should be_truthy;
        });

        it(@"should hide the toolbar accompanying the datepicker", ^{
            subject.toolBar.hidden should be_truthy;
        });
    });

    describe(@"presenting the Punch Attributes Controller", ^{
        __block ManualPunch *localPunch;
        __block ManualPunch *expectedPunch;

        context(@"When supervisor needs to add a punch", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"special-user-uri"
                                                         date:date];
                localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                subject.view should_not be_nil;
            });

            it(@"should add the a PunchAttributeController as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(punchAttributeController, subject, subject.punchAttributeContainerView);
            });

            it(@"should configure the PunchAttributeController", ^{
                punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"special-user-uri",localPunch,PunchAttributeScreenTypeADD);
            });

        });
        
        context(@"When supervisor needs to add a punch With OEF enabled", ^{
            __block OEFType *oefType1_;
            __block OEFType *oefType2_;
            __block OEFType *oefType3_;
            __block  NSMutableArray *oefTypesArray_ ;
            
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"special-user-uri"
                                                         date:date];
                
                oefType1_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefType2_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefType3_ = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray_ = [NSMutableArray arrayWithObjects:oefType1_,oefType2_, oefType3_, nil];
                
                localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray_ address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                
                [punchAttributeController setUpWithNeedLocationOnUI:NO delegate:subject flowType:SupervisorFlowContext userUri:@"special-user-uri" punch:localPunch punchAttributeScreentype:PunchAttributeScreenTypeADD];
                
                subject.view should_not be_nil;
            });
            
            it(@"should add the a PunchAttributeController as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(punchAttributeController, subject, subject.punchAttributeContainerView);
            });
            
            it(@"should configure the PunchAttributeController", ^{
                punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
        });
        
        context(@"When user needs to add a punch", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:date];
                subject.view should_not be_nil;
            });

            it(@"should add the a PunchAttributeController as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(punchAttributeController, subject, subject.punchAttributeContainerView);
            });

            it(@"should configure the PunchAttributeController", ^{
                punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",localPunch,PunchAttributeScreenTypeADD);
            });

        });
        
        context(@"When user needs to add a punch With OEF enabled", ^{
            __block OEFType *oefType1_;
            __block OEFType *oefType2_;
            __block OEFType *oefType3_;

            __block  NSMutableArray *oefTypesArray_ ;
            
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                
                oefType1_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3_ = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];

                oefTypesArray_ = [NSMutableArray arrayWithObjects:oefType1_, oefType2_, oefType3_, nil];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                
                localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray_ address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                
                [punchAttributeController setUpWithNeedLocationOnUI:NO delegate:subject flowType:UserFlowContext userUri:@"special-user-uri" punch:localPunch punchAttributeScreentype:PunchAttributeScreenTypeADD];
                
                subject.view should_not be_nil;
            });
            
            it(@"should add the a PunchAttributeController as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(punchAttributeController, subject, subject.punchAttributeContainerView);
            });
            
            it(@"should configure the PunchAttributeController", ^{
                punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
        });
        
        context(@"When Punch into Project user needs to add a punch with OEF enabled on UserFlowContext", ^{
            __block OEFType *oefType1_;
            __block OEFType *oefType2_;
            __block OEFType *oefType3_;
            
            __block  NSMutableArray *oefTypesArray_ ;
            __block ProjectType *project;
            __block TaskType *task;
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
                
                oefType1_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3_ = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray_ = [NSMutableArray arrayWithObjects:oefType1_, oefType2_, oefType3_, nil];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                
                localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:task date:date];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray_ address:nil userURI:@"special-user-uri" image:nil task:task date:date];
                
                [punchAttributeController setUpWithNeedLocationOnUI:NO delegate:subject flowType:UserFlowContext userUri:@"special-user-uri" punch:localPunch punchAttributeScreentype:PunchAttributeScreenTypeADD];
                
                subject.view should_not be_nil;
            });
            
            it(@"should add the a PunchAttributeController as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(punchAttributeController, subject, subject.punchAttributeContainerView);
            });
            
            it(@"should configure the PunchAttributeController", ^{
                punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
        });
        
        context(@"When Punch into Project user needs to add a punch with OEF enabled on SupervisorFlowContext", ^{
            __block OEFType *oefType1_;
            __block OEFType *oefType2_;
            __block OEFType *oefType3_;
            
            __block  NSMutableArray *oefTypesArray_ ;
            __block ProjectType *project;
            __block TaskType *task;
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).and_return(@"my-different-special-user-uri");
                
                oefType1_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2_ = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3_ = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"some-dropdown-option-uri-1" dropdownOptionValue:@"some-dropdown-option-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray_ = [NSMutableArray arrayWithObjects:oefType1_, oefType2_, oefType3_, nil];
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                      userURI:@"my-special-user-uri"
                                                         date:date];
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:nil
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                
                localPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:task date:date];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray_ address:nil userURI:@"special-user-uri" image:nil task:task date:date];
                
                [punchAttributeController setUpWithNeedLocationOnUI:NO delegate:subject flowType:SupervisorFlowContext userUri:@"special-user-uri" punch:localPunch punchAttributeScreentype:PunchAttributeScreenTypeADD];
                
                subject.view should_not be_nil;
            });
            
            it(@"should add the a PunchAttributeController as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(punchAttributeController, subject, subject.punchAttributeContainerView);
            });
            
            it(@"should configure the PunchAttributeController", ^{
                punchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
        });
        
    });

    describe(@"as an <PunchAttributeControllerDelegate>", ^{
        __block PunchAttributeController *newPunchAttributeController;
        __block ManualPunch *expectedPunch;

        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];


            newPunchAttributeController = nice_fake_for([PunchAttributeController class]);
            [injector bind:[PunchAttributeController class] toInstance:newPunchAttributeController];

            subject.view should_not be_nil;
        });


        it(@"should update the container height", ^{
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            subject.view should_not be_nil;

            [subject punchAttributeController:(id)[NSNull null] didUpdateTableViewWithHeight:200];
            subject.punchAttributeContainerViewHeightConstraint.constant should equal(200);
        });


        context(@"When updating client for User", ^{
            __block ClientType *client;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:client oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker.date];
                
                [childControllerHelper reset_sent_messages];
                
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });

            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
        context(@"When updating client for Supervisor", ^{
            __block ClientType *client;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:client oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker.date];
                
                [childControllerHelper reset_sent_messages];
                
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
        context(@"When updating client when OEF enabled for User", ^{
            __block ClientType *client;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker.date];
                [childControllerHelper reset_sent_messages];
                
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchIn).and_return(oefTypesArray);
                
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
        context(@"When updating client when OEF enabled for Supervisor", ^{
            __block ClientType *client;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:client oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker.date];
                [childControllerHelper reset_sent_messages];
                
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchIn).and_return(oefTypesArray);
                
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });

        context(@"When updating Project for User", ^{
            __block ProjectType *project;
            __block PunchAttributeController *newestPunchAttributeController;

            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"];
                
                [breakTypeDeferred resolveWithValue:@[breakType]];

                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];

                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];

                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });

            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });


        });
        
        context(@"When updating Project for Supervisor", ^{
            __block ProjectType *project;
            __block PunchAttributeController *newestPunchAttributeController;
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"];
                
                [breakTypeDeferred resolveWithValue:@[breakType]];
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });

            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
            
            
        });
        
        context(@"When updating Project when OEF Enabled for User", ^{
            __block ProjectType *project;
            __block PunchAttributeController *newestPunchAttributeController;
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"];
                
                [breakTypeDeferred resolveWithValue:@[breakType]];
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                [childControllerHelper reset_sent_messages];
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypeStartBreak).and_return(oefTypesArray);
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
            
            
        });
        
        context(@"When updating Project when OEF Enabled for Supervisor", ^{
            __block ProjectType *project;
            __block PunchAttributeController *newestPunchAttributeController;
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");

                reporteePermissionsStorage stub_method(@selector(isReporteePunchIntoProjectsUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                reporteePermissionsStorage stub_method(@selector(canAccessBreaksUserWithUri:)).with(@"my-special-user-uri").and_return(YES);
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"Doesn't even matter" uri:@"probably, right?"];
                
                [breakTypeDeferred resolveWithValue:@[breakType]];
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                [childControllerHelper reset_sent_messages];
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypeStartBreak).and_return(oefTypesArray);
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
            
            
        });

        context(@"When updating Task for User", ^{
            __block TaskType *task;
            __block PunchAttributeController *newestPunchAttributeController;
            __block ProjectType *project;
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];

                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                        .date];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateClient:clientType];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });

            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });

        });
        
        context(@"When updating Task for Supervisor", ^{
            __block TaskType *task;
            __block PunchAttributeController *newestPunchAttributeController;
            __block ProjectType *project;
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                        .date];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateClient:clientType];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
            
        });
        
        context(@"When updating Task when OEF enabled for User", ^{
            __block TaskType *task;
            __block PunchAttributeController *newestPunchAttributeController;
            __block ProjectType *project;
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                        .date];
                [childControllerHelper reset_sent_messages];
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);
                [subject punchAttributeController:nil didIntendToUpdateClient:clientType];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
            
        });
        
        context(@"When updating Task when OEF enabled for Supervisor", ^{
            __block TaskType *task;
            __block PunchAttributeController *newestPunchAttributeController;
            __block ProjectType *project;
            beforeEach(^{
               
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:3];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                ClientType *clientType = [[ClientType alloc]initWithName:@"client-name"
                                                                     uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:clientType
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                
                task = [[TaskType alloc] initWithProjectUri:nil
                                                 taskPeriod:nil
                                                       name:@"task-name"
                                                        uri:@"task-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:nil breakType:nil location:nil project:project requestID:@"guid-A" activity:nil client:clientType oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:task date:subject.datePicker
                        .date];
                
                [childControllerHelper reset_sent_messages];
                
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);
                
                [subject punchAttributeController:nil didIntendToUpdateClient:clientType];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                [subject punchAttributeController:nil didIntendToUpdateTask:task];
                
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
            
        });

        context(@"When updating Activity for User", ^{
            __block Activity *activity;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                
                [childControllerHelper reset_sent_messages];
                
                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
            });

            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });

            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
        context(@"When updating Activity for Supervisor", ^{
            __block Activity *activity;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                
                [childControllerHelper reset_sent_messages];
                
                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
        context(@"When updating Activity with OEF for User", ^{
            __block Activity *activity;

            __block PunchAttributeController *newestPunchAttributeController;
            
            beforeEach(^{

                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                

                 userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                

                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                
                
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                [childControllerHelper reset_sent_messages];
                
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchIn).and_return(oefTypesArray);
                
                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,UserFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
        context(@"When updating Activity with OEF for Supervisor", ^{
            __block Activity *activity;
            
            __block PunchAttributeController *newestPunchAttributeController;
            
            beforeEach(^{
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                
                
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:activity client:nil oefTypes:oefTypesArray address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                [childControllerHelper reset_sent_messages];
                
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchIn).and_return(oefTypesArray);
                
                [subject punchAttributeController:nil didIntendToUpdateActivity:activity];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(newPunchAttributeController,newestPunchAttributeController,subject,subject.punchAttributeContainerView);
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO,subject,SupervisorFlowContext,@"my-special-user-uri",expectedPunch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should punch on the punch clock", ^{
                [subject.navigationItem.rightBarButtonItem tap];
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });

        context(@"When updating Default Activity", ^{
            __block Activity *activity;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                activity = [[Activity alloc]initWithName:@"default-activity-name" uri:@"default-activity-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateDefaultActivity:activity];
            });

            it(@"should not add a new child view controller", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });

        });
        
        context(@"When updating Default Activity when OEF is enabled", ^{
            __block Activity *activity;
            __block PunchAttributeController *newestPunchAttributeController;
            __block ManualPunch *manualPunch;
            
            
            beforeEach(^{
               
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                manualPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                
                [punchAttributeController setUpWithNeedLocationOnUI:NO delegate:subject flowType:UserFlowContext userUri:@"special-user-uri" punch:manualPunch punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                subject.view should_not be_nil;
                
                activity = [[Activity alloc]initWithName:@"default-activity-name" uri:@"default-activity-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                [childControllerHelper reset_sent_messages];
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchIn).and_return(oefTypesArray);
                [subject punchAttributeController:nil didIntendToUpdateDefaultActivity:activity];
            });
            
            it(@"should not add a new child view controller", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should not call setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:", ^{
                newestPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });
            
        });
        
        context(@"When updating Default Activity when OEF is enabled for Supervisor", ^{
            __block Activity *activity;
            __block PunchAttributeController *newestPunchAttributeController;
            __block ManualPunch *manualPunch;
            
            
            beforeEach(^{
                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                
                manualPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:nil date:date];
                
                [punchAttributeController setUpWithNeedLocationOnUI:NO delegate:subject flowType:UserFlowContext userUri:@"special-user-uri" punch:manualPunch punchAttributeScreentype:PunchAttributeScreenTypeEDIT];
                
                subject.view should_not be_nil;
                
                activity = [[Activity alloc]initWithName:@"default-activity-name" uri:@"default-activity-uri"];
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:nil project:nil requestID:NULL activity:activity client:nil oefTypes:oefTypesArray address:nil userURI:@"special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                [childControllerHelper reset_sent_messages];
                oefStorage stub_method(@selector(getAllOEFSForPunchActionType:)).with(PunchActionTypePunchIn).and_return(oefTypesArray);
                [subject punchAttributeController:nil didIntendToUpdateDefaultActivity:activity];
            });
            
            it(@"should not add a new child view controller", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should not call setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:", ^{
                newestPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });
            
        });
        
        context(@"When updating dropdown oefTypes for a punch", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                

                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");
 
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate userURI:@"my-special-user-uri" date:date];
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateDropDownOEFTypes:oefTypesArray];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO, subject, UserFlowContext, @"my-special-user-uri", subject.punch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });

            it(@"should have the correct action types", ^{
                subject.punch.actionType should equal(PunchActionTypePunchIn);
            });
        });

        context(@"When updating text/numeric oefTypes for a punch", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"dropdown-name" collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-special-user-uri");

                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate userURI:@"my-special-user-uri" date:date];

                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
            });

            it(@"should not show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });

            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });

            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });

            it(@"should have the correct action types", ^{
                subject.punch.actionType should equal(PunchActionTypePunchIn);
            });

        });
        
        context(@"When updating dropdown oefTypes for a punch for Supervisor", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:@"new-dropdown-uri" dropdownOptionValue:@"dropdown-name" collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];

                
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate userURI:@"my-special-user-uri" date:date];
                
                [childControllerHelper reset_sent_messages];
                
                [subject punchAttributeController:nil didIntendToUpdateDropDownOEFTypes:oefTypesArray];
            });
            
            it(@"should show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:)).with(NO, subject, SupervisorFlowContext, @"my-special-user-uri", subject.punch,PunchAttributeScreenTypeADD);
            });
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });

            it(@"should have the correct action types", ^{
                subject.punch.actionType should equal(PunchActionTypePunchIn);
            });
            
        });
        
        context(@"When updating text/numeric oefTypes for a punch for Supervisor", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block  NSMutableArray *oefTypesArray ;
            __block PunchAttributeController *newestPunchAttributeController;
            beforeEach(^{
                
                newestPunchAttributeController = nice_fake_for([PunchAttributeController class]);
                
                [injector bind:[PunchAttributeController class] toInstance:newestPunchAttributeController];
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.5999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:@"oef value1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                

                userSession stub_method(@selector(currentUserURI)).again().and_return(@"my-different-special-user-uri");
                
                [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate userURI:@"my-special-user-uri" date:date];
                
                [childControllerHelper reset_sent_messages];
                [subject punchAttributeController:nil didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
            });
            
            it(@"should not show the new punch attribute controller to reflect new punch attributes", ^{
                childControllerHelper should_not have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:));
            });
            
            it(@"should configure the new PunchAttributeController correctly", ^{
                newestPunchAttributeController should_not have_received(@selector(setUpWithNeedLocationOnUI:delegate:flowType:userUri:punch:punchAttributeScreentype:));
            });
            
            it(@"should have the correct oef types", ^{
                subject.punch.oefTypesArray should equal(oefTypesArray);
            });

            it(@"should have the correct action types", ^{
                subject.punch.actionType should equal(PunchActionTypePunchIn);
            });
        });

    });
    
    describe(@"fill entries for punch in and change segment to break", ^{
        __block ManualPunch *expectedPunch;
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            subject.view should_not be_nil;
        });

        context(@"change tab punch in to break", ^{
            __block ClientType *client;
            __block ProjectType *project;
            beforeEach(^{
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:0];
                client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:nil
                                                                           clientType:client
                                                                                 name:@"project-name"
                                                                                  uri:nil];
                BreakType *breakTypeA = [[BreakType alloc]initWithName:@"Break Type A" uri:@"Uri A"];
                
                [subject punchAttributeController:nil didIntendToUpdateClient:client];
                [subject punchAttributeController:nil didIntendToUpdateProject:project];
                
                [subject.punchTypeSegmentedControl selectSegmentAtIndex:2];
                
                
                expectedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakTypeA location:nil project:nil requestID:@"guid-A" activity:nil client:nil oefTypes:nil address:nil userURI:@"my-special-user-uri" image:nil task:nil date:subject.datePicker
                        .date];
                
                [subject.punchDetailsTableView layoutIfNeeded];
                
                [breakTypeDeferred resolveWithValue:@[breakTypeA]];
                
                [subject.navigationItem.rightBarButtonItem tap];
            });
            
            it(@"should save punch with break value", ^{
                punchClock should have_received(@selector(punchWithManualLocalPunch:punchAssemblyWorkflowDelegate:)).with(expectedPunch, subject);
            });
        });
        
    });
    
    describe(@"ViewWillAppear", ^{
        beforeEach(^{
            userSession stub_method(@selector(currentUserURI)).and_return(@"my-special-user-uri");
            [subject setupWithPunchChangeObserverDelegate:punchChangeObserverDelegate
                                                  userURI:@"my-special-user-uri"
                                                     date:date];
            [subject view];
            [subject viewWillAppear:YES];
        });
        it(@"should register for keyboardWillShow, keyboardWillHide", ^{
            notificationCenter should have_received(@selector(addObserver:selector:name:object:));

            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillHide:), UIKeyboardWillHideNotification, nil);

        });
        

    });

    describe(@"ViewWillDisappear", ^{
        beforeEach(^{
            [subject viewWillDisappear:YES];
        });
        it(@"should remove  keyboardWillShow, keyboardWillHide notifications", ^{
            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject,UIKeyboardWillShowNotification, nil);

            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject,UIKeyboardWillHideNotification, nil);
            
        });
        
    });

});

SPEC_END
