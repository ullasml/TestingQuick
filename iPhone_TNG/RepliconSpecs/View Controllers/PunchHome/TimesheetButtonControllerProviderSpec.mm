#import <Cedar/Cedar.h>
#import "TimesheetButtonControllerProvider.h"
#import "PreviousApprovalsButtonViewController.h"
#import "TimesheetButtonController.h"
#import "ButtonStylist.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetButtonControllerProviderSpec)

describe(@"TimesheetButtonControllerProvider", ^{
    __block TimesheetButtonControllerProvider *subject;
    __block ButtonStylist *buttonStylist;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<Theme> theme;

    beforeEach(^{
        buttonStylist = nice_fake_for([ButtonStylist class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TimesheetButtonControllerProvider alloc] initWithUserPermissionStorage:userPermissionsStorage
                                                                             buttonStylist:buttonStylist
                                                                                     theme:theme];
    });

    describe(@"providing a timesheet button controller", ^{
        __block id<TimesheetButtonControllerDelegate> delegate;
        __block TimesheetButtonController *timesheetButtonController;
        beforeEach(^{
            delegate = nice_fake_for(@protocol(TimesheetButtonControllerDelegate));
            timesheetButtonController = [subject provideInstanceWithDelegate:delegate];
        });

        it(@"should be the correct type", ^{
            timesheetButtonController should be_instance_of([TimesheetButtonController class]);
        });

        it(@"should have the delegate", ^{
            timesheetButtonController.delegate should be_same_instance_as(delegate);
        });

        it(@"should have a theme", ^{
            timesheetButtonController.theme should be_same_instance_as(theme);
        });

        it(@"should have a stylist", ^{
            timesheetButtonController.buttonStylist should be_same_instance_as(buttonStylist);
        });
        
        it(@"should have a UserPermissionsStorage", ^{
            timesheetButtonController.userPermissionsStorage should be_same_instance_as(userPermissionsStorage);
        });
    });
    
    describe(@"providing a previous approvals button controller", ^{
        __block id<PreviousApprovalsButtonControllerDelegate> delegate;
        __block PreviousApprovalsButtonViewController *previousApprovalsButtonViewController;
        beforeEach(^{
            delegate = nice_fake_for(@protocol(TimesheetButtonControllerDelegate));
            previousApprovalsButtonViewController = [subject provideInstanceForApprovalsButtonWithDelegate:delegate];
        });
        
        it(@"should be the correct type", ^{
            previousApprovalsButtonViewController should be_instance_of([PreviousApprovalsButtonViewController class]);
        });
        
        it(@"should have the delegate", ^{
            previousApprovalsButtonViewController.delegate should be_same_instance_as(delegate);
        });
        
        it(@"should have a theme", ^{
            previousApprovalsButtonViewController.theme should be_same_instance_as(theme);
        });
        
        it(@"should have a stylist", ^{
            previousApprovalsButtonViewController.buttonStylist should be_same_instance_as(buttonStylist);
        });
    });

});

SPEC_END
