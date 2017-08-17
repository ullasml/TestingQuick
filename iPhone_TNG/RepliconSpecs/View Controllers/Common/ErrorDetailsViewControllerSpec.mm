#import <Cedar/Cedar.h>
#import "ErrorDetailsViewController.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetailsStorage.h"
#import "ErrorBannerViewController.h"
#import "Theme.h"
#import "ErrorDetails.h"
#import "ErrorDetailsTableViewCell.h"
#import "ErrorDetailsRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "SVPullToRefresh.h"
#import "UITableViewCell+Spec.h"
#import "UIBarButtonItem+Spec.h"
#import "UIAlertView+Spec.h"
#import "Constants.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorDetailsViewControllerSpec)

describe(@"ErrorDetailsViewController", ^{
    __block ErrorDetailsViewController *subject;
    __block id<Theme> theme;
    __block id<BSBinder, BSInjector> injector;
    __block NSNotificationCenter *notificationCenter;
    __block ErrorDetailsDeserializer *errorDetailsDeserializer;
    __block ErrorDetailsStorage *errorDetailsStorage;
    __block ErrorBannerViewController *errorBannerViewController;
    __block ErrorDetails *errorDetailsA;
    __block ErrorDetails *errorDetailsB;
    __block ErrorDetailsRepository *errorDetailsRepository;

    beforeEach(^{
        injector = [InjectorProvider injector];

        notificationCenter = [[NSNotificationCenter alloc]init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];
        spy_on(notificationCenter);

        errorDetailsDeserializer = nice_fake_for([ErrorDetailsDeserializer class]);
        [injector bind:[ErrorDetailsDeserializer class] toInstance:errorDetailsDeserializer];

        errorDetailsStorage = nice_fake_for([ErrorDetailsStorage class]);
        [injector bind:[ErrorDetailsStorage class] toInstance:errorDetailsStorage];


        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        errorBannerViewController = nice_fake_for([ErrorBannerViewController class]);
        [injector bind:InjectorKeyErrorBannerViewController toInstance:errorBannerViewController];

        errorDetailsA = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom message 1" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

        errorDetailsB = [[ErrorDetails alloc] initWithUri:@"my-uri1" errorMessage:@"custom message 2" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

        errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).with(@"Timesheets_Module").and_return(@[errorDetailsA,errorDetailsB]);

        errorDetailsRepository = nice_fake_for([ErrorDetailsRepository class]);
        [injector bind:[ErrorDetailsRepository class] toInstance:errorDetailsRepository];

        subject = [injector getInstance:[ErrorDetailsViewController class]];

    });

    it(@"ErrrorBanner View controllers should be of same instances", ^{
        ErrorBannerViewController *errorBannerCtrl = [injector getInstance:InjectorKeyErrorBannerViewController];
        errorBannerViewController should be_same_instance_as(errorBannerCtrl);
    });

    describe(@"Styling Views", ^{
        beforeEach(^{
            theme stub_method(@selector(errorDetailsBackgroundColor)).and_return([UIColor redColor]);

        });
        it(@"Style the views", ^{

            subject.view should_not be_nil;

            subject.view.backgroundColor should equal([UIColor redColor]);
            subject.tableView.backgroundColor should equal([UIColor redColor]);
        });
    });

    describe(@"Styling Table View ", ^{
        __block ErrorDetailsTableViewCell *cellA;
        __block ErrorDetailsTableViewCell *cellB;
        beforeEach(^{
            theme stub_method(@selector(errorDetailsTextColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(errorDetailsFont)).and_return([UIFont systemFontOfSize:14]);
            theme stub_method(@selector(errorDetailsCellShadowColor)).and_return([UIColor blueColor]);
            theme stub_method(@selector(errorDetailsBackgroundColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(errorDetailsHeaderTextColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(errorDetailsHeaderFont)).and_return([UIFont systemFontOfSize:12]);

            [subject view];
            cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
            cellB = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

        });
        it(@"Style the error details cell", ^{

            cellA.value.backgroundColor should equal([UIColor clearColor]);
            cellA.value.textColor should equal([UIColor greenColor]);
            cellA.value.font should equal([UIFont systemFontOfSize:14]);
            cellA.value.numberOfLines = 0;
            cellA.value.textAlignment should equal(NSTextAlignmentLeft);
            cellA.selectionStyle should equal(UITableViewCellSelectionStyleNone);

            cellA.layer.shadowColor should equal([[UIColor blueColor]CGColor]);
            cellA.layer.shadowOffset should equal(CGSizeMake(3, 3));
            cellA.layer.shadowOpacity should equal((float)0.8);
            cellA.layer.shadowRadius should equal((float)1.0);
            cellA.layer.masksToBounds should be_falsy;
        });

        it(@"Style the padding cell", ^{

            cellB.backgroundColor should equal([UIColor clearColor]);
            cellB.frame.size.height should equal((float)8.0);
            cellB.selectionStyle should equal(UITableViewCellSelectionStyleNone);
        });

        context(@"when multiple error details", ^{
            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).again().with(@"Timesheets_Module").and_return(@[errorDetailsA,errorDetailsB]);
                 [subject viewDidLoad];
            });
            it(@"should style the section headers", ^{
                UIView *headerView = (UIView *)[subject.tableView.delegate tableView:subject.tableView viewForHeaderInSection:0];

                headerView.backgroundColor should equal([UIColor redColor]);

                UILabel *label = headerView.subviews[0];
                label.text should equal(RPLocalizedString(@"Timesheet Errors", @""));
                label.backgroundColor should equal([UIColor clearColor]);
                label.textColor should equal([UIColor yellowColor]);
                label.font should equal([UIFont systemFontOfSize:12]);

                headerView.frame.size.height should equal((float)32.0);
            });
        });

        context(@"when single error details", ^{
            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).again().with(@"Timesheets_Module").and_return(@[errorDetailsA]);
                [subject viewDidLoad];
            });
            it(@"should style the section headers", ^{
                UIView *headerView = (UIView *)[subject.tableView.delegate tableView:subject.tableView viewForHeaderInSection:0];

                headerView.backgroundColor should equal([UIColor redColor]);

                UILabel *label = headerView.subviews[0];
                label.text should equal(RPLocalizedString(@"Timesheet Error", @""));
                label.backgroundColor should equal([UIColor clearColor]);
                label.textColor should equal([UIColor yellowColor]);
                label.font should equal([UIFont systemFontOfSize:12]);

                headerView.frame.size.height should equal((float)32.0);
            });
        });



    });

    describe(@"When the view loads", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should have a title", ^{
            subject.title should equal(RPLocalizedString(@"Errors", @""));
        });

        it(@"should have a tableview", ^{
            subject.tableView should_not be_nil;
        });

        it(@"should add a right bar button item", ^{
            subject.navigationItem.rightBarButtonItem should_not be_nil;
        });

        it(@"should correctly set up errors data", ^{

            subject.tableRows.count should equal(2);
            subject.tableRows[0] should equal(errorDetailsA);
            subject.tableRows[1] should equal(errorDetailsB);

        });

    });

    describe(@"When the view appears", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:YES];
        });

        it(@"should hide error banner", ^{
            errorBannerViewController should have_received(@selector(hideErrorBanner));
        });
        
    });

    describe(@"When the view disappears", ^{
        __block UINavigationController *navigationController;
        beforeEach(^{

            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            spy_on(navigationController); 

            [subject view];
            [subject viewWillDisappear:YES];
        });

        it(@"should hide error banner", ^{
            errorBannerViewController should have_received(@selector(updateErrorBannerData));
        });

        it(@"should pop back", ^{

            navigationController should have_received(@selector(popViewControllerAnimated:)).with(NO);

        });

    });
    
    describe(@"Styling TableView Cell Delete Button ", ^{
        __block UITableViewRowAction *button;
        beforeEach(^{
            theme stub_method(@selector(errorBannerBackgroundColor)).and_return([UIColor greenColor]);
            [subject view];
        });
        it(@"Style the error details cell delete button", ^{
            button = [subject tableView:subject.tableView editActionsForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]][0];
            button.backgroundColor should equal([UIColor greenColor]);
            button.title should equal(cellDeleteButtonText);
        });
    });

    describe(@"its tableview", ^{
        __block UITableView *tableview;

        beforeEach(^{
            subject.view should_not be_nil;
            tableview = subject.tableView;
        });

        it(@"should be the datasource", ^{
            tableview.dataSource should be_same_instance_as(subject);
        });

        it(@"should be the delegate", ^{
            tableview.delegate should be_same_instance_as(subject);
        });

        it(@"should not be scrollable", ^{
            tableview.scrollEnabled should be_truthy;
        });
    });

    describe(@"cellForRowAtIndexPath:inSection:", ^{
        __block ErrorDetailsTableViewCell *cellA;
        __block ErrorDetailsTableViewCell *cellB;

        beforeEach(^{
            [subject view];
            cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
            cellB = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
        });

        it(@"should have correct values for rows", ^{
            cellA.value.text should equal(@"custom message 1");
            cellB.value.text should equal(@"custom message 2");
        });

    });

    describe(@"when no errors available", ^{
       
        beforeEach(^{
            errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).again().with(@"Timesheets_Module").and_return(nil);
            [subject view];
        });

        it(@"should have correct message label", ^{
            subject.view.subviews[1] should be_instance_of([UILabel class]);
        });

        it(@"should add a right bar button item", ^{
            subject.navigationItem.rightBarButtonItem should be_nil;
        });
    });

    describe(@"As a <SVPullToRefresh>", ^{
        __block KSDeferred *errorDetailsDeferred;
        beforeEach(^{
            errorDetailsDeferred = [[KSDeferred alloc]init];
            errorDetailsRepository stub_method(@selector(fetchTimeSheetUpdateData)).and_return(errorDetailsDeferred.promise);
            [subject view];
            [subject viewWillAppear:NO];
        });

        context(@"When clients is fetched successfully intially", ^{
            __block ErrorDetails *errorDetailsD;
            __block ErrorDetails *errorDetailsE;
            __block ErrorDetails *errorDetailsF;

            beforeEach(^{
                errorDetailsD = [[ErrorDetails alloc] initWithUri:@"my-uri-A" errorMessage:@"customA" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
                errorDetailsE = [[ErrorDetails alloc] initWithUri:@"my-uri-B" errorMessage:@"customB" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
                errorDetailsF = [[ErrorDetails alloc] initWithUri:@"my-uri-C" errorMessage:@"customC" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            });

            it(@"should display correct cells", ^{
                subject.tableView.visibleCells.count should equal(4);

                ErrorDetailsTableViewCell *cellA = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
                cellA.value.text should equal(@"custom message 1");

                ErrorDetailsTableViewCell *cellB = [subject.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
                cellB.value.text should equal(@"custom message 2");
            });
        });
    });

    describe(@"tableView:canEditRowAtIndexPath", ^{
        __block NSIndexPath *indexPathA;
        __block NSIndexPath *indexPathB;
        __block NSIndexPath *indexPathC;
        __block NSIndexPath *indexPathD;

        __block BOOL isEditableRowA;
        __block BOOL isEditableRowB;
        __block BOOL isEditableRowC;
        __block BOOL isEditableRowD;

        beforeEach(^{
            indexPathA = [NSIndexPath indexPathForItem:0 inSection:0];
            indexPathB = [NSIndexPath indexPathForItem:1 inSection:0];
            indexPathC = [NSIndexPath indexPathForItem:2 inSection:0];
            indexPathD = [NSIndexPath indexPathForItem:3 inSection:0];

            isEditableRowA = [subject tableView:subject.tableView canEditRowAtIndexPath:indexPathA];
            isEditableRowB = [subject tableView:subject.tableView canEditRowAtIndexPath:indexPathB];
            isEditableRowC = [subject tableView:subject.tableView canEditRowAtIndexPath:indexPathC];
            isEditableRowD = [subject tableView:subject.tableView canEditRowAtIndexPath:indexPathD];

        });

        it(@"is first row not editable", ^{
            isEditableRowA should be_falsy;
        });
        it(@"is second row should be editable", ^{
            isEditableRowB should be_truthy;
        });
        it(@"is third row not editable", ^{
            isEditableRowC should be_falsy;
        });
        it(@"is fourth row should be editable", ^{
            isEditableRowD should be_truthy;
        });

    });

    describe(@"deleting rows using swipe", ^{
        beforeEach(^{
            [subject view];

        });

        context(@"when errors are still available after delete", ^{
            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).again().with(@"Timesheets_Module").and_return(@[errorDetailsB]);
                [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
            });

            it(@"should have correctly delete the error details", ^{
                errorDetailsStorage should have_received(@selector(deleteErrorDetails:)).with(@"my-uri");
            });

            it(@"should have correctly fetch the error details", ^{
                subject.tableRows.count should equal(1);
                subject.tableRows[0] should equal(errorDetailsB);
            });
        });


        context(@"when no errors are available after delete", ^{
            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).again().with(@"Timesheets_Module").and_return(nil);
                [subject tableView:subject.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
            });

            it(@"should have correctly delete the error details", ^{
                errorDetailsStorage should have_received(@selector(deleteErrorDetails:)).with(@"my-uri");
            });

            it(@"should have correctly fetch the error details", ^{
                subject.tableRows.count should equal(0);
            });

            it(@"should have correct message label", ^{
                subject.view.subviews[1] should be_instance_of([UILabel class]);
            });
        });

    });

    describe(@"deleting all error rows", ^{
        __block UIAlertView *alertView;

        beforeEach(^{
            errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).with(@"Timesheets_Module").again().and_return(@[errorDetailsA,errorDetailsB]);
             [subject viewDidLoad];

            [subject.navigationItem.rightBarButtonItem tap];
            alertView = [UIAlertView currentAlertView];

        });

        it(@"should display a correctly configured alert", ^{
            alertView should_not be_nil;
            alertView.title should be_nil;
            alertView.message should equal(RPLocalizedString(DeleteAllErrorsMessage, nil));
            [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"No", @""));
            [alertView buttonTitleAtIndex:1] should equal(RPLocalizedString(@"Yes", @""));

        });

        describe(@"should delete all errors  from the system if user taps on ok", ^{


            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).with(@"Timesheets_Module").again().and_return(nil);
                [alertView dismissWithClickedButtonIndex:1 animated:NO];
                [subject.tableView layoutSubviews];
            });

            it(@"should delete all errors and should not show delete all button", ^{
                errorDetailsStorage should have_received(@selector(deleteAllErrorDetails));
                subject.navigationItem.rightBarButtonItem should be_nil;
            });
        });

    });
});

SPEC_END
