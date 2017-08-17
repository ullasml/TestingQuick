#import <Cedar/Cedar.h>
#import "ErrorBannerViewController.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetailsStorage.h"
#import "Theme.h"
#import "Constants.h"
#import "ErrorDetails.h"
#import "ErrorDetailsViewController.h"
#import "SyncNotificationScheduler.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorBannerViewControllerSpec)

describe(@"ErrorBannerViewController", ^{
    __block ErrorBannerViewController<CedarDouble> *subject;
    __block id<Theme> theme;
    __block id<BSBinder, BSInjector> injector;
    __block NSNotificationCenter *notificationCenter;
    __block ErrorDetailsDeserializer *errorDetailsDeserializer;
    __block ErrorDetailsStorage *errorDetailsStorage;
    __block ErrorDetailsViewController *errorDetailsViewController;
    __block SyncNotificationScheduler *syncNotificationScheduler;

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

        errorDetailsViewController = nice_fake_for([ErrorDetailsViewController class]);
        [injector bind:[ErrorDetailsViewController class] toInstance:errorDetailsViewController];

        syncNotificationScheduler = nice_fake_for([SyncNotificationScheduler class]);
        [injector bind:[SyncNotificationScheduler class] toInstance:syncNotificationScheduler];


        subject = [injector getInstance:InjectorKeyErrorBannerViewController];

        spy_on(subject);

    });
    
     afterEach(^{
         stop_spying_on(subject);
         stop_spying_on(notificationCenter);
    });

    describe(@"Styling Views", ^{
        beforeEach(^{
            theme stub_method(@selector(errorBannerBackgroundColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(errorBannerCountTextColor)).and_return([UIColor whiteColor]);
            theme stub_method(@selector(errorBannerCountFont)).and_return([UIFont systemFontOfSize:10]);

            theme stub_method(@selector(errorBannerDateTextColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(errorBannerDateFont)).and_return([UIFont systemFontOfSize:8]);

        });
        it(@"Style the views", ^{

            subject.view should_not be_nil;
            
            
            subject.view.backgroundColor should equal([UIColor redColor]);
            
            subject.errorLabel.backgroundColor should equal([UIColor clearColor]);
            subject.errorLabel.textColor should equal([UIColor whiteColor]);
            subject.errorLabel.font should equal([UIFont systemFontOfSize:10]);


            subject.dateLabel.backgroundColor should equal([UIColor clearColor]);
            subject.dateLabel.textColor should equal([UIColor yellowColor]);
            subject.dateLabel.font should equal([UIFont systemFontOfSize:8]);

        });
    });

    describe(@"When the view loads", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should register for errorNotification, successNotification", ^{
            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject, errorNotification, nil);

            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(errorDataReceivedAction:), errorNotification, nil);

            notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject, successNotification, nil);

            notificationCenter should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(successDataReceivedAction:), successNotification, nil);
            
        });
    });

    describe(@"errorDataReceivedAction:", ^{
        __block NSNotification *notification;
        __block ErrorDetails *errorDetails1;
        __block ErrorDetails *errorDetails2;
        beforeEach(^{
            notification = nice_fake_for([NSNotification class]);
            notification stub_method(@selector(userInfo)).and_return(@{@"uri": @"my-uri", @"error_msg": @"custom error msg", @"module": TIMESHEETS_TAB_MODULE_NAME});
            errorDetails1 = nice_fake_for([ErrorDetails class]);
            errorDetails2 = nice_fake_for([ErrorDetails class]);
            errorDetailsDeserializer stub_method(@selector(deserialize:)).and_return(@[errorDetails1]);
        });

        context(@"for singular errors", ^{

            beforeEach(^{
                errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).and_return(@[errorDetails1]);
                [subject errorDataReceivedAction:notification];
            });
            it(@"should correctly call the deserializer", ^{
                errorDetailsDeserializer should have_received(@selector(deserialize:)).with(@{@"uri": @"my-uri", @"error_msg": @"custom error msg", @"module": TIMESHEETS_TAB_MODULE_NAME});
            });

            it(@"should store ErrorDetails", ^{

                errorDetailsStorage should have_received(@selector(storeErrorDetails:)).with(@[errorDetails1]);
            });

            it(@"should schedule the local notification", ^{
                syncNotificationScheduler should have_received(@selector(cancelNotification:)).with(@"ErrorBackgroundStatus");

                syncNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:uid:)).with([NSString stringWithFormat:@"%@ %d %@. %@",RPLocalizedString(@"You have", @""),1,RPLocalizedString(@"error", @""), RPLocalizedString(@"Tap to view.",@"")],@"ErrorBackgroundStatus");
            });

        });

        context(@"for multiple errors", ^{

            beforeEach(^{
                 errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).and_return(@[errorDetails1,errorDetails2]);
                [subject errorDataReceivedAction:notification];
            });
            it(@"should correctly call the deserializer", ^{
                errorDetailsDeserializer should have_received(@selector(deserialize:)).with(@{@"uri": @"my-uri", @"error_msg": @"custom error msg", @"module": TIMESHEETS_TAB_MODULE_NAME});
            });

            it(@"should store ErrorDetails", ^{

                errorDetailsStorage should have_received(@selector(storeErrorDetails:)).with(@[errorDetails1]);
            });

            it(@"should schedule the local notification", ^{
                syncNotificationScheduler should have_received(@selector(cancelNotification:)).with(@"ErrorBackgroundStatus");
                syncNotificationScheduler should have_received(@selector(scheduleNotificationWithAlertBody:uid:)).with([NSString stringWithFormat:@"%@ %d %@. %@",RPLocalizedString(@"You have", @""),2,RPLocalizedString(@"errors", @""), RPLocalizedString(@"Tap to view.",@"")],@"ErrorBackgroundStatus");
            });
            
        });


    });

    describe(@"successDataReceivedAction:", ^{
        __block NSNotification *notification;
        __block ErrorDetails *errorDetails;
        beforeEach(^{
            notification = nice_fake_for([NSNotification class]);
            notification stub_method(@selector(userInfo)).and_return(@{@"uri": @"my-uri", @"error_msg": @"custom error msg", @"module": TIMESHEETS_TAB_MODULE_NAME});
            errorDetails = nice_fake_for([ErrorDetails class]);
            errorDetailsDeserializer stub_method(@selector(deserialize:)).and_return(@[errorDetails]);

            [subject successDataReceivedAction:notification];
        });

        it(@"should correctly call the deserializer", ^{
            errorDetailsDeserializer should have_received(@selector(deserialize:)).with(@{@"uri": @"my-uri", @"error_msg": @"custom error msg", @"module": TIMESHEETS_TAB_MODULE_NAME});
        });

        it(@"should delete ErrorDetails", ^{

            errorDetailsStorage should have_received(@selector(deleteErrorDetails:)).with(errorDetails.uri);
        });
    });


   describe(@"updateErrorBannerData", ^{
        __block ErrorDetails *errorDetails1;
        __block ErrorDetails *errorDetails2;
        beforeEach(^{
            errorDetails1 = nice_fake_for([ErrorDetails class]);
            errorDetails1 stub_method(@selector(errorDate)).and_return(@"2016-12-04 10:30:00 +0000");
            errorDetails2 = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            subject.view should_not be_nil;
        });
        context(@"when errors are present in DB", ^{
            beforeEach(^{

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];
                [subject setLocalDateFormatter:dateFormatter];

            });

            context(@"for singular errors", ^{
                beforeEach(^{
                    errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).and_return(@[errorDetails2]);
                    [subject updateErrorBannerData];
                });

                it(@"should set correct error count", ^{
                    subject.errorLabel.text should equal([NSString stringWithFormat:@"1 %@",RPLocalizedString(notificationText, @"")]);
                });

                it(@"should set correct date", ^{
                    subject.dateLabel.text should equal(@"As of Dec 04 at 04:04 PM");
                });

                it(@"should show the banner", ^{
                    subject.view.hidden should be_falsy;
                });

            });

            context(@"for multiple errors", ^{
                beforeEach(^{
                    errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).and_return(@[errorDetails1,errorDetails2]);
                    [subject updateErrorBannerData];
                });

                it(@"should set correct error count", ^{
                    subject.errorLabel.text should equal([NSString stringWithFormat:@"2 %@",RPLocalizedString(notificationsText, @"")]);
                });

                it(@"should set correct date", ^{
                    subject.dateLabel.text should equal(@"As of Dec 04 at 04:00 PM");
                });

                it(@"should show the banner", ^{
                    subject.view.hidden should be_falsy;
                });
                
            });



        });

       context(@"when errors are not present in DB", ^{
           beforeEach(^{
               errorDetailsStorage stub_method(@selector(getAllErrorDetailsForModuleName:)).and_return(nil);

               [subject updateErrorBannerData];
           });


           it(@"should hide the banner", ^{
               subject.view.hidden should be_truthy;
           });
           
       });


    });

    describe(@"presentErrorDetailsControllerOnParentController:withTabBarcontroller:", ^{
        __block UINavigationController *parentController;
        __block UITabBarController *tabBarController;
        beforeEach(^{
            [subject view];
            parentController = nice_fake_for([UINavigationController class]);
            parentController.view.frame = CGRectMake(0, 0, 320.0f, 400.0f);
            tabBarController = nice_fake_for([UITabBarController class]);
            tabBarController.view.frame = CGRectMake(0, 0, 320.0f, 49.0f);

            [subject presentErrorDetailsControllerOnParentController:parentController withTabBarcontroller:tabBarController];

        });

        it(@"should be added as a subview with correct height", ^{
            subject.view.frame.size.height should equal(45.0f);
        });

        it(@"should update banner", ^{
            (id<CedarDouble>)subject should have_received(@selector(updateErrorBannerData));
        });

        it(@"sparent controller should be correctly set", ^{
            subject.parentController should be_same_instance_as(parentController);
        });
    });

    describe(@"When error banner view is tapped", ^{
        __block UIViewController *parentController;

        beforeEach(^{
            [subject view];
            parentController = [[UINavigationController alloc]init];
            spy_on(parentController);

            subject stub_method(@selector(parentController)).and_return(parentController);
            [subject presentErrorDetailsViewController];
        });
        afterEach(^{
            stop_spying_on(parentController);
            parentController = nil;
        });

        it(@"should naviagte to expected view controller", ^{
            parentController should have_received(@selector(pushViewController:animated:)).with(errorDetailsViewController,YES);
        });
        


    });

    describe(@"showing error banner", ^{
        __block UIViewController *parentController;

        beforeEach(^{
            [subject view];
            parentController = [[UINavigationController alloc]init];
            spy_on(parentController);

        });
        afterEach(^{
            stop_spying_on(parentController);
            parentController = nil;
        });

        context(@"when top view controller is any other view controller", ^{
            beforeEach(^{
                subject stub_method(@selector(parentController)).and_return(parentController);
                [subject showErrorBanner];
            });
            it(@"should show the banner", ^{
                subject.view.hidden should be_falsy;
            });

        });

        context(@"when top view controller is ErrorDetailsViewController", ^{
            beforeEach(^{
                subject stub_method(@selector(parentController)).and_return(parentController);
                parentController stub_method(@selector(topViewController)).and_return(errorDetailsViewController);;
                [subject showErrorBanner];
            });
            it(@"should show the banner", ^{
                subject.view.hidden should be_truthy;
            });

        });
        
    });
    
    describe(@"<ErrorBannerMonitorObserver>", ^{
        it(@"should inform its observers when error banner view changed", ^{
            id<ErrorBannerMonitorObserver> observer1 = nice_fake_for(@protocol(ErrorBannerMonitorObserver));
            id<ErrorBannerMonitorObserver> observer2 = nice_fake_for(@protocol(ErrorBannerMonitorObserver));
            
            [subject addObserver:observer1];
            [subject addObserver:observer2];
            
            [subject notifyObservers];
            
            observer1 should have_received(@selector(errorBannerViewChanged));
            observer2 should have_received(@selector(errorBannerViewChanged));
        });
        
        it(@"should not notify", ^{
            id<ErrorBannerMonitorObserver> observer = nice_fake_for(@protocol(ErrorBannerMonitorObserver));
            
            [subject addObserver:observer];
            
            [subject removeObserver];
            
            observer should_not have_received(@selector(errorBannerViewChanged));
        });
    });

});

SPEC_END
