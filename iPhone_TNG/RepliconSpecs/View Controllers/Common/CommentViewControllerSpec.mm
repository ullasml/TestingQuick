//
//  CommentViewControllerSpec.m
//  NextGenRepliconTimeSheet
//

#import <Cedar/Cedar.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "CommentViewController.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "UIBarButtonItem+Spec.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CommentViewControllerSpec)

describe(@"CommentViewController", ^{
    __block id<BSBinder, BSInjector> injector;
    __block CommentViewController *subject;
    __block UINavigationController *navigationController;
    __block id<CommentViewControllerDelegate> delegate;
    __block NSNotificationCenter *notificationCenter;
    __block id <Theme> theme;

    beforeEach(^{
        injector = [InjectorProvider injector];

        delegate = nice_fake_for(@protocol(CommentViewControllerDelegate));

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        notificationCenter = [[NSNotificationCenter alloc]init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        subject = [injector getInstance:[CommentViewController class]];

        spy_on(notificationCenter);

    });

    describe(@"NavBar behaviour", ^{

        context(@"Navigation item title", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });

            it(@"should display Reopen title", ^{
                subject.navigationItem.title should equal(RPLocalizedString(@"Comments", @"Comments"));
            });
        });

        context(@"When Reopen", ^{
            beforeEach(^{
                [subject setupAction:@"Reopen" delegate:subject];
                subject.view should_not be_nil;
            });

            it(@"should display Reopen title", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Reopen", @"Reopen"));

                subject.navigationItem.rightBarButtonItem.tag should equal(5001);
            });
        });

        context(@"When Resubmit", ^{
            beforeEach(^{
                [subject setupAction:@"Resubmit" delegate:subject];
                subject.view should_not be_nil;
            });

            it(@"should display Resubmit title", ^{
                subject.navigationItem.rightBarButtonItem.title should equal(RPLocalizedString(@"Resubmit", @"Resubmit"));

                subject.navigationItem.rightBarButtonItem.tag should equal(5002);
            });
        });

        context(@"On tap of Cancel Button", ^{
            beforeEach(^{
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                spy_on(navigationController);

                subject.view should_not be_nil;

                [subject.navigationItem.leftBarButtonItem tap];

            });

            it(@"Should have Cancel button on left", ^{
                subject.navigationItem.leftBarButtonItem should_not be_nil;
            });

            it(@"should pop view Controller", ^{
                navigationController should have_received(@selector(popViewControllerAnimated:));
            });

            afterEach(^{
                stop_spying_on(navigationController);
            });
        });

        context(@"On tap of Reopen button", ^{
            beforeEach(^{

                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                spy_on(navigationController);

                [subject setupAction:@"Reopen" delegate:delegate];
                subject.view should_not be_nil;

                spy_on(subject.commentsTextView);

                subject.commentsTextView stub_method(@selector(text)).and_return(@"My text");
                [subject.navigationItem.rightBarButtonItem tap];
            });

            it(@"Should have received the delegate method", ^{
                subject.delegate should have_received(@selector(commentsViewController:didPressOnActionButton:withCommentsText:)).with(subject, subject.navigationItem.rightBarButtonItem, subject.commentsTextView.text);
            });

            it(@"should pop view controller", ^{
                navigationController should have_received(@selector(popViewControllerAnimated:));
            });

            afterEach(^{
                stop_spying_on(navigationController);
                stop_spying_on(subject.commentsTextView);
            });
            
        });

        context(@"On tap of Resubmit button", ^{
            beforeEach(^{

                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                spy_on(navigationController);

                [subject setupAction:@"Resubmit" delegate:delegate];
                subject.view should_not be_nil;

                spy_on(subject.commentsTextView);

                subject.commentsTextView stub_method(@selector(text)).and_return(@"My text");
                [subject.navigationItem.rightBarButtonItem tap];
            });

            it(@"Should have received the delegate method", ^{
                subject.delegate should have_received(@selector(commentsViewController:didPressOnActionButton:withCommentsText:)).with(subject, subject.navigationItem.rightBarButtonItem, subject.commentsTextView.text);
            });

            it(@"should pop view controller", ^{
                navigationController should have_received(@selector(popViewControllerAnimated:));
            });

            afterEach(^{
                stop_spying_on(navigationController);
                stop_spying_on(subject.commentsTextView);
            });
            
        });
    });

    describe(@"-UITextViewDelegate", ^{

        context(@"When begining to enter text in textView and has no text", ^{
            beforeEach(^{
                subject.view should_not be_nil;

                spy_on(subject.commentsTextView);

                subject.commentsTextView stub_method(@selector(text)).and_return(@"");

                [subject textViewDidChange:subject.commentsTextView];
            });

            it(@"Should have action button enabled", ^{
                subject.placeholderLabel.hidden should be_falsy;
            });
        });

        context(@"When begining to enter text in textView and has text", ^{
            beforeEach(^{
                subject.view should_not be_nil;

                spy_on(subject.commentsTextView);

                subject.commentsTextView stub_method(@selector(text)).and_return(@"hello");

                [subject textViewDidChange:subject.commentsTextView];
            });

            it(@"Should have action button disabled", ^{
                subject.placeholderLabel.hidden should be_truthy;
            });
        });

    });

    describe(@"Placeholder label behaviour", ^{

        context(@"label style", ^{

            beforeEach(^{
                theme stub_method(@selector(approvalPlaceholderTextColor)).and_return([UIColor yellowColor]);
                theme stub_method(@selector(approvalPlaceholderTextFont)).and_return([UIFont systemFontOfSize:10]);
                subject.view should_not be_nil;
            });
            it(@"should have the styling set properly", ^{
                subject.placeholderLabel.textColor should equal([UIColor yellowColor]);

                subject.placeholderLabel.font should equal([UIFont systemFontOfSize:10]);
            });
        });

        context(@"When Reopen", ^{
            beforeEach(^{
                [subject setupAction:@"Reopen" delegate:subject];
                subject.view should_not be_nil;
            });

            it(@"should display Reopen title", ^{
                subject.placeholderLabel.text should equal(RPLocalizedString(@"Enter Reopen comments", nil));

                subject.placeholderLabel.hidden should be_falsy;
            });
        });

        context(@"When Resubmit", ^{
            beforeEach(^{
                [subject setupAction:@"Resubmit" delegate:subject];
                subject.view should_not be_nil;
            });

            it(@"should display Resubmit title", ^{

                subject.placeholderLabel.text should equal(RPLocalizedString(@"Enter Resubmit comments", nil));

                subject.placeholderLabel.hidden should be_falsy;

            });
        });
    });

    describe(@"ViewWillAppear", ^{
        beforeEach(^{
            subject.view should_not be_nil;
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

});

SPEC_END

