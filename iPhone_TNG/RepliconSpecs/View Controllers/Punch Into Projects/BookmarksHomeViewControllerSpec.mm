#import <Cedar/Cedar.h>
#import "BookmarksHomeViewController.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "SelectBookmarksViewController.h"
#import "UIControl+spec.h"
#import "UIBarButtonItem+Spec.h"
#import <KSDeferred/KSDeferred.h>
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "PunchCardObject.h"
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BookmarksHomeViewControllerSpec)

describe(@"BookmarksHomeViewController", ^{
    __block BookmarksHomeViewController *subject;
    __block ChildControllerHelper *childControllerHelper;
    __block id <BSBinder,BSInjector> injector;
    __block SelectBookmarksViewController *selectBookmarksViewController;
    __block id <BookmarksHomeViewControllerDelegate> delegate;
    
    beforeEach(^{
        
        injector = [InjectorProvider injector];

        selectBookmarksViewController = nice_fake_for([SelectBookmarksViewController class]);
        [injector bind:[SelectBookmarksViewController class] toInstance:selectBookmarksViewController];
        spy_on(selectBookmarksViewController);
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        delegate = nice_fake_for(@protocol(BookmarksHomeViewControllerDelegate));

        subject = [injector getInstance:[BookmarksHomeViewController class]];
        
        
        [subject setupWithDelegate:delegate];
        
        delegate = subject.delegate;
        spy_on(delegate);

    });
    
    describe(@"when the view loads", ^{
        
        context(@"when controller type is SelectBookmarksViewController", ^{
            
            beforeEach(^{
                subject.view should_not be_nil;
                spy_on(subject.bookmarksListContainerView);
            });
            
            afterEach(^{
                stop_spying_on(selectBookmarksViewController);
                
            });

            it(@"should set the title properly", ^{
                subject.title should equal(RPLocalizedString(@"Select From Bookmarks", @"Select From Bookmarks"));
            });
            
            it(@"should add the selectBookmarksViewController", ^{
                
                selectBookmarksViewController should have_received(@selector(setupWithDelegate:)).with(subject);
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(selectBookmarksViewController,subject,subject.bookmarksListContainerView);
            });
        });
    });

    
    describe(@"right bar button item action", ^{
        __block UINavigationController *navigationController;
        beforeEach(^{
            [subject view];
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            [subject.navigationItem.rightBarButtonItem tap];
        });
        afterEach(^{
            stop_spying_on(selectBookmarksViewController);
            
        });
        
        it(@"should show right bar button item", ^{
            subject.navigationItem.rightBarButtonItem should_not be_nil;
        });
        
        it(@"should navigate to Create Bookmarks View", ^{
            selectBookmarksViewController should have_received(@selector(navigateToCreateBookmarksView));
        });
    });

    describe(@"as <SelectBookmarksViewControllerDelegate>", ^{
        describe(@"-selectBookmarksViewController:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:", ^{
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
                
                
                [subject selectBookmarksViewController:nil
                   willEventuallyFinishIncompletePunch:incompletePunch
                                 assembledPunchPromise:assembledPunchPromise
                           serverDidFinishPunchPromise:serverPromise];
            });
            
            it(@"should inform its delegate to finish the punch assembly workflow", ^{
                delegate should have_received(@selector(bookmarksHomeViewController:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:)).with(subject,incompletePunch,assembledPunchPromise,serverPromise);
            });
        });
        
            context(@"selectBookmarksViewController:updatePunchCard:", ^{
                __block ClientType *client;
                __block ProjectType *project;
                __block TaskType *task;
                __block PunchCardObject *expectedPunchCardObject;
                beforeEach(^{
                    [subject view];
                    
                    client = nice_fake_for([ClientType class]);
                    project = nice_fake_for([ProjectType class]);
                    task = nice_fake_for([TaskType class]);
                    
                    expectedPunchCardObject = [[PunchCardObject alloc] initWithClientType:client projectType:project oefTypesArray:nil breakType:nil taskType:task activity:nil uri:nil];
                    
                    [subject selectBookmarksViewController:nil updatePunchCard:expectedPunchCardObject];
                });
                
                it(@"should call delegate", ^{
                    delegate should have_received(@selector(bookmarksHomeViewController:updatePunchCard:)).with(subject, expectedPunchCardObject);
                });
        });
        
            context(@"selectBookmarksViewControllerUpdateCardList:", ^{
                __block SelectBookmarksViewController *newSelectBookmarksViewController;
                beforeEach(^{
                    [subject view];
                    
                    newSelectBookmarksViewController = nice_fake_for([SelectBookmarksViewController class]);
                    [injector bind:[SelectBookmarksViewController class] toInstance:newSelectBookmarksViewController];
                    spy_on(newSelectBookmarksViewController);
                    
                    [subject selectBookmarksViewControllerUpdateCardList:nil];
                    
                });
                
                it(@"should replace with the new selectBookmarksViewController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(selectBookmarksViewController,newSelectBookmarksViewController,subject,subject.bookmarksListContainerView);
                });
        });
    });

});

SPEC_END
