#import <Cedar/Cedar.h>
#import "ApprovalCommentsController.h"
#import "UIBarButtonItem+Spec.h"
#import <KSDeferred/KSDeferred.h>
#import <Foundation/Foundation.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "Theme.h"
#import "LoginModel.h"
#import "InjectorKeys.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApprovalCommentsControllerSpec)

describe(@"ApprovalCommentsController", ^{
    __block ApprovalCommentsController *subject;
    __block id <ApprovalCommentsControllerDelegate> delegate;
    __block UINavigationController *navigationController;
    __block NSNotificationCenter *notificationCenter;
    __block id <BSBinder,BSInjector> injector;
    __block id <Theme> theme;


    beforeEach(^{
        injector = [InjectorProvider injector];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        notificationCenter = [[NSNotificationCenter alloc]init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        delegate = nice_fake_for(@protocol(ApprovalCommentsControllerDelegate));
        subject = [injector getInstance:[ApprovalCommentsController class]];
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(notificationCenter);
    });

    describe(@"Styling Views", ^{
        beforeEach(^{
            theme stub_method(@selector(rejectButtonColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(approvalPlaceholderTextColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(approvalPlaceholderTextFont)).and_return([UIFont systemFontOfSize:10]);

        });
        it(@"Style the views", ^{
            [subject setUpApprovalActionType:RejectActionType delegate:delegate commentsRequired:YES];
            subject.view should_not be_nil;
            subject.navigationItem.rightBarButtonItem.tintColor should equal([UIColor redColor]);
            subject.navigationItem.title should equal(RPLocalizedString(@"Add Comment", @"Add Comment"));
            subject.placeholderTextLabel.textColor should equal([UIColor yellowColor]);
            subject.placeholderTextLabel.font should equal([UIFont systemFontOfSize:10]);

        });
    });

    describe(@"When the view loads", ^{

        it(@"should have the correct placeholder text", ^{
            subject.view should_not be_nil;
            subject.placeholderTextLabel.text should equal(RPLocalizedString(@"Comments must be added before proceeding.", @"Comments must be added before proceeding."));
        });

        it(@"should have the textview as its subview", ^{
            subject.view should_not be_nil;
            subject.view.subviews.count should equal(2);
            subject.view.subviews.firstObject should be_instance_of([UILabel class]);
            subject.view.subviews.lastObject should be_instance_of([UITextView class]);

        });

        it(@"should have set edgesForExtendedLayout correctly", ^{
            subject.view should_not be_nil;
            subject.edgesForExtendedLayout should equal(UIRectEdgeNone) ;
        });

        context(@"ViewWillAppear", ^{
            beforeEach(^{
                [subject viewWillAppear:YES];
            });

            it(@"should register for keyboardWillShow, keyboardWillHide", ^{
                notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillShow:), UIKeyboardWillChangeFrameNotification, nil);

                notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(keyboardWillHide:), UIKeyboardWillHideNotification, nil);

            });

            it(@"should layout the textview height correctly when keyboard appears", ^{
                CGRect rect = CGRectMake(0, 100, 200, 200);
                NSValue *rectValue = [NSValue valueWithCGRect:rect];

                NSDictionary *userInfo =  @{@"UIKeyboardFrameEndUserInfoKey":rectValue};

                [notificationCenter postNotificationName:UIKeyboardWillChangeFrameNotification object:nil userInfo:userInfo];
                subject.textViewHeightConstraint.constant should equal(100);
            });

            it(@"should layout the textview height correctly when keyboard appears", ^{
                [notificationCenter postNotificationName:UIKeyboardWillHideNotification object:nil];
                subject.textViewHeightConstraint.constant should equal(CGRectGetHeight(subject.view.bounds));
            });
        });

        context(@"when rejecting ", ^{
            beforeEach(^{
                [subject setUpApprovalActionType:RejectActionType delegate:delegate commentsRequired:YES];
                subject.view should_not be_nil;
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Reject", @"Reject"));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });
        });
        context(@"when approving ", ^{
            beforeEach(^{
                [subject setUpApprovalActionType:ApproveActionType delegate:delegate commentsRequired:YES];
                subject.view should_not be_nil;
            });

            it(@"should have the correctly set up right bar button item", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Approve", @"Approve"));
                subject.navigationItem.rightBarButtonItem.target should equal(subject);
            });
        });

    });

    describe(@"When Approving", ^{
        beforeEach(^{
            [subject setUpApprovalActionType:ApproveActionType delegate:delegate commentsRequired:YES];
            subject.view should_not be_nil;
            [subject.navigationItem.rightBarButtonItem tap];

        });

        it(@"should inform its delegate the approve action is requested", ^{
            delegate should have_received(@selector(approvalsCommentsControllerDidRequestApproveAction:withComments:)).with(subject,subject.commentsTextView.text);
        });


    });

    describe(@"When Rejecting", ^{
        context(@"when user does not enter comments and comments are required ", ^{
            __block UIAlertView *alertView;
            beforeEach(^{
                [subject setUpApprovalActionType:RejectActionType delegate:delegate commentsRequired:YES];
                subject.view should_not be_nil;
                [subject.navigationItem.rightBarButtonItem tap];
                alertView = [UIAlertView currentAlertView];
            });
            
            it(@"should show error alert", ^{
                alertView should_not be_nil;
                alertView.message should equal(rejectionCommentsErrorText);
            });
        });

        context(@"when comments are not required and user  ", ^{
            beforeEach(^{
                [subject setUpApprovalActionType:RejectActionType delegate:delegate commentsRequired:NO];
                subject.view should_not be_nil;
                [subject.navigationItem.rightBarButtonItem tap];
            });

            it(@"should inform its delegate the approve action is requested", ^{
                delegate should have_received(@selector(approvalsCommentsControllerDidRequestRejectAction:withComments:)).with(subject,subject.commentsTextView.text);
            });
        });
    });

    describe(@"When canceling", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            spy_on(subject.commentsTextView);
            [subject.navigationItem.leftBarButtonItem tap];

        });

        it(@"should inform its delegate the approve action is requested", ^{
            subject.commentsTextView should have_received(@selector(resignFirstResponder));
            navigationController should have_received(@selector(popViewControllerAnimated:)).with(YES);
        });
        
        
    });

    describe(@"textViewDidBeginEditing", ^{

        context(@"When user changes text of textview", ^{
            beforeEach(^{
                subject.view should_not be_nil;
                subject.commentsTextView.text = @"My-Special- Comments";
                [subject textViewDidBeginEditing:subject.commentsTextView];
            });
            it(@"should hide the placeholder", ^{
                subject.placeholderTextLabel.hidden should be_truthy;
            });
        });
    });
});

SPEC_END
