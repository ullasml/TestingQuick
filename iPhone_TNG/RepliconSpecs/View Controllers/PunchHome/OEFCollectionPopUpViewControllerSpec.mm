#import <Cedar/Cedar.h>
#import "OEFCollectionPopUpViewController.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "UserSession.h"
#import "PunchCardObject.h"
#import "OEFCardViewController.h"
#import "OEFType.h"
#import "OEFTypeStorage.h"
#import "Theme.h"
#import "TestAppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFCollectionPopUpViewControllerSpec)

describe(@"OEFCollectionPopUpViewController", ^{
    __block OEFCollectionPopUpViewController *subject;
    __block ChildControllerHelper *childControllerHelper;
    __block id<UserSession> userSession;
    __block id<BSBinder, BSInjector> injector;
    __block id<OEFCollectionPopUpViewControllerDelegate> delegate;
    __block NSNotificationCenter *notificationCenter;
    __block UINavigationController *navigationController;
    __block OEFTypeStorage *oefTypeStorage;
    __block NSMutableArray *oefTypesArray;
    __block id <Theme> theme;
    __block UIApplication *sharedApplication;

    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        delegate = nice_fake_for(@protocol(OEFCollectionPopUpViewControllerDelegate));
        
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        
        oefTypeStorage = nice_fake_for([OEFTypeStorage class]);
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        theme = nice_fake_for(@protocol(Theme));
        
        [injector bind:@protocol(Theme) toInstance:theme];
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[OEFTypeStorage class] toInstance:oefTypeStorage];

        
        OEFType *oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
        OEFType *oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
        OEFType *oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
        oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
        
        oefTypeStorage stub_method(@selector(getAllOEFSForCollectAtTimeOfPunch:)).with(PunchActionTypePunchOut).and_return(oefTypesArray);

        notificationCenter = [[NSNotificationCenter alloc] init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        spy_on(notificationCenter);
        
        subject = [injector getInstance:[OEFCollectionPopUpViewController class]];
        [subject setupWithOEFCollectionPopUpViewControllerDelegate:delegate punchActionType:PunchActionTypePunchOut];
        
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        
        sharedApplication = subject.sharedApplication;
        spy_on(sharedApplication);
    });
    
    beforeEach(^{
        theme stub_method(@selector(oefCardParentViewBackgroundColor)).and_return([UIColor grayColor]);
        theme stub_method(@selector(oefCardScrollViewBackgroundColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(oefCardContainerViewBackgroundColor)).and_return([UIColor magentaColor]);
        theme stub_method(@selector(oefCardWindowBackgroundColor)).and_return([UIColor whiteColor]);
        theme stub_method(@selector(oefCardBackGroundViewColor)).and_return([UIColor redColor]);
    });

    describe(@"presenting the oef card", ^{
        __block OEFCardViewController *oefCardViewController;
        beforeEach(^{
            oefCardViewController = nice_fake_for([OEFCardViewController class]);
            [injector bind:[OEFCardViewController class] toInstance:oefCardViewController];
            [subject view];
        });
        
        it(@"should set up the oefcard controller correctly", ^{
            oefCardViewController should have_received(@selector(setUpWithDelegate:punchActionType:oefTypesArray:))
            .with(subject, PunchActionTypePunchOut, oefTypesArray);
        });
        
        it(@"should use the child controller helper to present the oefcard controller", ^{
            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
            .with(oefCardViewController, subject, subject.cardContainerView);
        });
    });

    describe(@"As a <OEFCardControllerDelegate>", ^{
        
        context(@"should tell its delegate", ^{
            
            __block PunchCardObject *cardObject;
            
            beforeEach(^{
                cardObject = [[PunchCardObject alloc]
                                               initWithClientType:nil
                                                      projectType:nil
                                                    oefTypesArray:nil
                                                        breakType:NULL
                                                         taskType:nil
                                                         activity:nil
                                                              uri:nil];
                subject.view should_not be_nil;
            });
            
            it(@"that the save oef values", ^{
                [subject oefCardViewController:nil didIntendToSave:cardObject];
                it(@"should pop the view controller", ^{
                    navigationController should have_received(@selector(popViewControllerAnimated:)).with(YES);
                });
                delegate should have_received(@selector(oefCollectionPopUpViewController:didIntendToUpdate:punchActionType:)).with(subject,cardObject, PunchActionTypePunchOut);
            });
        });
        
        it(@"should tell its delegate to update the oef card height", ^{
            [subject view];
            [subject oefCardViewController:nil didUpdateHeight:160];
            subject.oefCardHeightConstraint.constant should equal((CGFloat)160);
        });
        
        it(@"should tell its delegate to pop the ", ^{
            [subject oefCardViewController:nil cancelButton:nil];
            it(@"should pop the view controller", ^{
                navigationController should have_received(@selector(popViewControllerAnimated:)).with(YES);
            });
        });
        
        context(@"-oefCardViewController:didScrolltoSubview:", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });
            
            it(@"scroll the scrollview to textview cursor", ^{
                [subject view];
                UITextView *textView = nice_fake_for([UITextView class]);
                textView.text = @"testing!!!";
                spy_on(subject.scrollView);
                [subject oefCardViewController:nil didScrolltoSubview:textView];
                subject.scrollView should have_received(@selector(setContentOffset:animated:)).with(CGPointMake(0, 0),NO);
            });
        });
    });
    
    describe(@"the view hierarchy", ^{
        beforeEach(^{
            [subject view];
        });
        

        it(@"should add scroll view as the subview of the view", ^{
            [[subject.view subviews] count] should equal(2);
            [subject.view subviews] should contain(subject.scrollView);
            [subject.view subviews] should contain(subject.backgroundView);
        });
        
        it(@"scrollview should dismiss keyboard on drag", ^{
            subject.scrollView.keyboardDismissMode should equal(UIScrollViewKeyboardDismissModeOnDrag);
        });
        
        describe(@"the scrollview's container view", ^{
            __block UIView *containerView;
            beforeEach(^{
                containerView = subject.containerView;
            });
            
            it(@"should live inside the scroll view", ^{
                subject.scrollView.subviews should contain(containerView);
            });
            
            it(@"should contain the punch in button", ^{
                containerView.subviews should contain(subject.cardContainerView);
            });
        });
    });
    
    describe(@"ViewWillAppear", ^{
        __block UIWindow *window;
        beforeEach(^{
            window = [sharedApplication.delegate window];
            [subject viewWillAppear:YES];
        });

        it(@"should register for keyboardWillShow, keyboardWillHide", ^{
            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillShow:), UIKeyboardWillShowNotification, nil);
            
            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillHide:), UIKeyboardWillHideNotification, nil);
        });
    });
    

    describe(@"ViewWillDisappear", ^{
        beforeEach(^{
            [subject viewWillDisappear:YES];
        });
        
        it(@"should hide the navbar, tabbar and status bar", ^{
            subject.navigationController.tabBarController.tabBar.hidden should be_falsy;
            subject.navigationController.navigationBar.hidden should be_falsy;
        });

        it(@"should remove  keyboardWillShow, keyboardWillHide notifications", ^{
            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject,UIKeyboardWillShowNotification, nil);
            
            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject,UIKeyboardWillHideNotification, nil);
        });
        
    });
    
    
    describe(@"Styling the views", ^{
        
        context(@"When DefaultOEFCard", ^{
            beforeEach(^{
                [subject view];
            });
            
            it(@"should set background color for parent view", ^{
                subject.view.backgroundColor should equal([UIColor grayColor]);
            });
            
            it(@"should set background color for containerView ", ^{
                subject.containerView.backgroundColor should equal([UIColor magentaColor]);
            });
            
            it(@"should set background color for scrollView", ^{
                subject.scrollView.backgroundColor should equal([UIColor orangeColor]);
            });
            
            it(@"should set background color for background view", ^{
                subject.backgroundView.backgroundColor should equal([UIColor redColor]);
            });
        });
        
    });


});

SPEC_END
