#import <Cedar/Cedar.h>
#import "UIBarButtonItem+Spec.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetDetailsSeriesControllerPresenterSpec)

describe(@"WidgetTimesheetDetailsSeriesControllerPresenter", ^{
    __block WidgetTimesheetDetailsSeriesControllerPresenter *subject;
    __block TimeSheetPermittedActions *newTimesheetPermittedActions;
    __block UIBarButtonItem *expectedRightBarButtonItem;
    __block id <WidgetTimesheetDetailsSeriesControllerPresenterDelegate> delegate;
    __block id <BSInjector,BSBinder> injector;
    __block UIActivityIndicatorView *activityIndicator;
    beforeEach(^{
        injector = [InjectorProvider injector];
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [injector bind:InjectorKeyActivityIndicator toInstance:activityIndicator];
        delegate = nice_fake_for(@protocol(WidgetTimesheetDetailsSeriesControllerPresenterDelegate));
        newTimesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
        subject = [injector getInstance:[WidgetTimesheetDetailsSeriesControllerPresenter class]];
        [subject setUpWithDelegate:delegate];
        
    });
    
    context(@"When Submit button to be shown", ^{
        
        beforeEach(^{
            newTimesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
            newTimesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(YES);
            newTimesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
            expectedRightBarButtonItem = [subject navigationBarRightButtonItemForTimesheetPermittedActions:newTimesheetPermittedActions];
            
        });
        
        it(@"should display submit button", ^{
            expectedRightBarButtonItem.title should equal(RPLocalizedString(@"Submit", nil));
        });
        
        context(@"When Submit button tapped", ^{
            
            beforeEach(^{
                [expectedRightBarButtonItem tap];
            });
            
            it(@"should inform its delegate with the correct timesheet action", ^{
                delegate should have_received(@selector(userIntendsTo:presenter:)).with(RightBarButtonActionTypeSubmit,subject);
            });
        });
    });
    
    context(@"When Resubmit button to be shown", ^{
        beforeEach(^{
            newTimesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(YES);
            newTimesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
            newTimesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(NO);
            expectedRightBarButtonItem = [subject navigationBarRightButtonItemForTimesheetPermittedActions:newTimesheetPermittedActions];
        });
        
        it(@"should display Resubmit button", ^{
            expectedRightBarButtonItem.title should equal(RPLocalizedString(@"Resubmit", nil));
        });
        
        context(@"When re-submit button tapped", ^{
            beforeEach(^{
                [expectedRightBarButtonItem tap];
            });
            it(@"should inform its delegate with the correct timesheet action", ^{
                delegate should have_received(@selector(userIntendsTo:presenter:)).with(RightBarButtonActionTypeReSubmit,subject);
            });
        });
    });
    
    context(@"When Reopen button to be shown", ^{
        
        beforeEach(^{
            newTimesheetPermittedActions stub_method(@selector(canReSubmitTimeSheet)).and_return(NO);
            newTimesheetPermittedActions stub_method(@selector(canAutoSubmitOnDueDate)).and_return(NO);
            newTimesheetPermittedActions stub_method(@selector(canReOpenSubmittedTimeSheet)).and_return(YES);
            expectedRightBarButtonItem = [subject navigationBarRightButtonItemForTimesheetPermittedActions:newTimesheetPermittedActions];
            
        });
        
        it(@"should display Reopen button", ^{
            expectedRightBarButtonItem.title should equal(RPLocalizedString(@"Reopen", nil));
            
        });
        
        context(@"When Reopen button tapped", ^{
            beforeEach(^{
                [expectedRightBarButtonItem tap];
            });
            it(@"should inform its delegate with the correct timesheet action", ^{
                delegate should have_received(@selector(userIntendsTo:presenter:)).with(RightBarButtonActionTypeReOpen,subject);
            });
        });
    });
    
    context(@"When button with spinner has to be shown", ^{
        
        beforeEach(^{
            expectedRightBarButtonItem = [subject navigationBarRightButtonItemWithSpinner];
        });
        
        it(@"should return bar button with spinner", ^{
            expectedRightBarButtonItem.customView should equal(activityIndicator);
            
        });
    });
    
    
});

SPEC_END
