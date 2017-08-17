#import <Cedar/Cedar.h>
#import "UIControl+Spec.h"
#import "TimesheetButtonController.h"
#import "ButtonStylist.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetButtonControllerSpec)

describe(@"TimesheetButtonController", ^{
    __block TimesheetButtonController *subject;
    __block id <TimesheetButtonControllerDelegate> delegate;
    __block ButtonStylist *buttonStylist;
    __block id<Theme> theme;
    __block UserPermissionsStorage *userPermissionStorage;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(TimesheetButtonControllerDelegate));
        buttonStylist =  nice_fake_for([ButtonStylist class]);
        theme = nice_fake_for(@protocol(Theme));
        userPermissionStorage = nice_fake_for([UserPermissionsStorage class]);

        subject = [[TimesheetButtonController alloc] initWithUserPermissionStorage:userPermissionStorage
                                                                     buttonStylist:buttonStylist
                                                                          delegate:delegate
                                                                             theme:theme];
        subject.title = @"";
    });

    describe(@"after the view loads", ^{
        beforeEach(^{
            theme stub_method(@selector(viewTimesheetButtonTitleColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(viewTimesheetButtonBackgroundColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(viewTimesheetButtonBorderColor)).and_return([UIColor redColor]);
            [subject view];
        });

        it(@"should have a 'View My Timesheets' button", ^{
            subject.view should contain(subject.viewTimeSheetPeriodButton);
        });

        describe(@"when the user taps the 'View My Timesheets' button", ^{
            
            context(@"When widget platform is enabled", ^{
                beforeEach(^{
                    userPermissionStorage stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
                    [subject.viewTimeSheetPeriodButton tap];

                });
                
                it(@"should notify its delegate", ^{
                    delegate should have_received(@selector(timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:)).with(subject);
                });
            });
            
            context(@"When widget platform is disabled", ^{
                beforeEach(^{
                    userPermissionStorage stub_method(@selector(isWidgetPlatformSupported)).and_return(NO);
                    [subject.viewTimeSheetPeriodButton tap];

                });
                
                it(@"should notify its delegate", ^{
                    delegate should have_received(@selector(timesheetButtonControllerWillNavigateToTimesheetDetailScreen:)).with(subject);
                });
            });

            
        });

        it(@"use its stylist to style the button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.viewTimeSheetPeriodButton, @"", [UIColor orangeColor], [UIColor yellowColor], [UIColor redColor]);
        });
    });
});

SPEC_END
