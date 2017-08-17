#import <Cedar/Cedar.h>
#import "TimesheetDetailsController.h"
#import <KSDeferred/KSPromise.h>
#import <KSDeferred/KSDeferred.h>
#import "Theme.h"
#import "TimesheetDetailsPresenter.h"
#import "ChildControllerHelper.h"
#import "TimesheetBreakdownController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "TimeSummaryRepository.h"
#import "DayController.h"
#import "DayTimeSummary.h"
#import "TimePeriodSummaryDeferred.h"
#import "TimePeriodSummary.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "InjectorKeys.h"
#import "ViolationEmployee.h"
#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "GrossPayController.h"
#import "CurrencyValue.h"
#import "Timesheet.h"
#import "SpinnerOperationsCounter.h"
#import "UIControl+Spec.h"
#import "Cursor.h"
#import "TimesheetPeriod.h"
#import "TimesheetBreakdownController.h"
#import "UserPermissionsStorage.h"
#import "UserSession.h"
#import "GrossPayTimeHomeViewController.h"
#import "GrossHours.h"
#import "TimeSheetApprovalStatus.h"
#import "TimesheetInfoAndPermissionsRepository.h"
#import "AuditHistoryStorage.h"
#import "IndexCursor.h"
#import "DayTimeSummaryController.h"
#import "TimesheetAdditionalInfo.h"
#import "TimeSheetPermittedActions.h"
#import "TimesheetDaySummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetDetailsControllerSpec)

describe(@"TimesheetDetailsController", ^{
    __block TimesheetDetailsController <CedarDouble>*subject;
    __block id<BSBinder, BSInjector> injector;
    __block ChildControllerHelper <CedarDouble>*childControllerHelper;
    __block TimesheetDetailsPresenter *timesheetDateRangePresenter;
    __block KSDeferred *timesheetDeferred;
    __block TimeSummaryRepository *timeSummaryRepository;
    __block id<Theme> theme;
    __block id<Cursor> cursor;
    __block SpinnerOperationsCounter <CedarDouble> *spinnerOperationsCounter;
    __block id<TimesheetDetailsControllerDelegate> delegate;
    __block UserPermissionsStorage *punchRulesStorage;
    __block GrossPayTimeHomeViewController *grossPayTimeHomeViewController;
    __block TimesheetSummaryController *timesheetSummaryController;
    __block DayTimeSummaryController *dayTimeSummaryController;
    __block TimesheetBreakdownController *timesheetBreakdownController;
    __block TimesheetInfoAndPermissionsRepository *timesheetInfoAndPermissionsRepository;
    __block AuditHistoryStorage *auditHistoryStorage;
    __block id <Timesheet> timesheet;
    __block TimePeriodSummary *globalTimePeriodSummary;
    __block KSDeferred *workHoursDeferred;
    __block KSDeferred *timesheetInfoAndPermissionsDeferred;
    __block TimesheetAdditionalInfo *timesheetAdditionalInfo;
    __block TimeSheetPermittedActions *timesheetPermittedActions;
    __block TimePeriodSummary *expectedTimePeriodSummary;
    __block UINavigationController *navigationController;
    __block id <UserSession> userSession;
    __block DayTimeSummary *dayTimeSummary1;
    __block DayTimeSummary *dayTimeSummary2;
    beforeEach(^{
        injector = (id)[InjectorProvider injector];
        workHoursDeferred = [[WorkHoursDeferred alloc] init];
        timesheetInfoAndPermissionsDeferred = [[KSDeferred alloc]init];
        [injector bind:[WorkHoursDeferred class] toInstance:workHoursDeferred];

        globalTimePeriodSummary = nice_fake_for([TimePeriodSummary class]);
        dayTimeSummary1 = nice_fake_for([DayTimeSummary class]);
        dayTimeSummary1 stub_method(@selector(isScheduledDay)).and_return(YES);
        dayTimeSummary2 = nice_fake_for([DayTimeSummary class]);
        dayTimeSummary2 stub_method(@selector(isScheduledDay)).and_return(NO);
        globalTimePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(@[dayTimeSummary1,dayTimeSummary2]);
        globalTimePeriodSummary stub_method(@selector(isScheduledDay)).and_return(YES);
        
        cursor = nice_fake_for([IndexCursor class]);
        timesheet = nice_fake_for(@protocol(Timesheet));
        timesheet stub_method(@selector(uri)).and_return(@"special-timesheet-uri");
        timesheet stub_method(@selector(timePeriodSummary)).and_return(globalTimePeriodSummary);

        timesheetInfoAndPermissionsRepository = nice_fake_for([TimesheetInfoAndPermissionsRepository class]);
        [injector bind:[TimesheetInfoAndPermissionsRepository class] toInstance:timesheetInfoAndPermissionsRepository];
        
        auditHistoryStorage = nice_fake_for([AuditHistoryStorage class]);
        [injector bind:[AuditHistoryStorage class] toInstance:auditHistoryStorage];
        
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];
        
        spinnerOperationsCounter = nice_fake_for([SpinnerOperationsCounter class]);
        cursor = nice_fake_for(@protocol(Cursor));
        delegate = nice_fake_for(@protocol(TimesheetDetailsControllerDelegate));
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        timesheetDateRangePresenter = nice_fake_for([TimesheetDetailsPresenter class]);
        [injector bind:[TimesheetDetailsPresenter class] toInstance:timesheetDateRangePresenter];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        timeSummaryRepository = nice_fake_for([TimeSummaryRepository class]);
        [injector bind:[TimeSummaryRepository class] toInstance:timeSummaryRepository];
        
        timesheetSummaryController = nice_fake_for([TimesheetSummaryController class]);
        [injector bind:[TimesheetSummaryController class] toInstance:timesheetSummaryController];
        
        dayTimeSummaryController = nice_fake_for([DayTimeSummaryController class]);
        [injector bind:[DayTimeSummaryController class] toInstance:dayTimeSummaryController];
        
        timesheetBreakdownController = nice_fake_for([TimesheetBreakdownController class]);
        [injector bind:[TimesheetBreakdownController class] toInstance:timesheetBreakdownController];
        
        grossPayTimeHomeViewController = [[GrossPayTimeHomeViewController alloc] initWithTheme:nil];
        [injector bind:[GrossPayTimeHomeViewController class] toInstance:grossPayTimeHomeViewController];

        timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).with(@"special-timesheet-uri",@"user-uri").and_return(timesheetInfoAndPermissionsDeferred.promise);
        
        timesheetDeferred = [KSDeferred defer];
        
        subject = [injector getInstance:[TimesheetDetailsController class]];
        spy_on(subject);
        
        [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                          delegate:delegate
                                         timesheet:timesheet
                                 hasPayrollSummary:NO
                                    hasBreakAccess:NO
                                            cursor:cursor
                                           userURI:@"user-uri"
                                             title:@"This is the title of this screen"];
        
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
        punchRulesStorage stub_method(@selector(userSession)).and_return(userSession);
        
        
        timesheetPermittedActions = nice_fake_for([TimeSheetPermittedActions class]);
        timesheetAdditionalInfo = nice_fake_for([TimesheetAdditionalInfo class]);
        timesheetAdditionalInfo stub_method(@selector(timesheetPermittedActions)).and_return(timesheetPermittedActions);
        timesheetAdditionalInfo stub_method(@selector(payDetailsPermission)).and_return(YES);
        timesheetAdditionalInfo stub_method(@selector(payAmountDetailsPermission)).and_return(NO);
        timesheetAdditionalInfo stub_method(@selector(scriptCalculationDateValue)).and_return(@"some-value");
        timesheetAdditionalInfo stub_method(@selector(allViolationSections)).and_return(@[@"some-violations"]);
        
        expectedTimePeriodSummary = [[TimePeriodSummary alloc] initWithRegularTimeComponents:nil
                                                                         breakTimeComponents:nil
                                                                   timesheetPermittedActions:timesheetPermittedActions
                                                                          overtimeComponents:nil
                                                                        payDetailsPermission:YES
                                                                            dayTimeSummaries:@[dayTimeSummary1,dayTimeSummary2]
                                                                                    totalPay:nil
                                                                                  totalHours:nil
                                                                            actualsByPayCode:nil
                                                                        actualsByPayDuration:nil
                                                                         payAmountPermission:NO
                                                                       scriptCalculationDate:@"some-value"
                                                                           timeOffComponents:nil
                                                                              isScheduledDay:YES];
        
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);
        spy_on(grossPayTimeHomeViewController);
    });
    
    afterEach(^{
        stop_spying_on(navigationController);
        stop_spying_on(subject);
        stop_spying_on(grossPayTimeHomeViewController);
    });
    
    describe(@"when the view loads and timesheet object is nil", ^{
        
        
        beforeEach(^{
            injector = (id)[InjectorProvider injector];
            
            timesheetDeferred = [KSDeferred defer];
            
            subject = [injector getInstance:[TimesheetDetailsController class]];
            spy_on(subject);
            
            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                              delegate:nil
                                             timesheet:nil
                                     hasPayrollSummary:NO
                                        hasBreakAccess:NO
                                                cursor:cursor
                                               userURI:@"user-uri"
                                                 title:@"This is the title of this screen"];
            
        });

        it(@"should not show the gross pay container intially", ^{
            subject.view should_not be_nil;
            subject.grossPayContainerHeightConstraint.constant should equal(0);
        });
        
        it(@"should delete all audit history data ", ^{
            subject.childViewControllers.count should equal(0);
        });
    });

    
    describe(@"when the view loads", ^{
        
        it(@"should not show the gross pay container intially", ^{
            subject.view should_not be_nil;
            subject.grossPayContainerHeightConstraint.constant should equal(0);
        });
        
        it(@"should delete all audit history data ", ^{
            subject.view should_not be_nil;
            auditHistoryStorage should have_received(@selector(deleteAllRows));
        });
        
        it(@"should request for info from timesheet Info And PermissionsRepository", ^{
            subject.view should_not be_nil;
            timesheetInfoAndPermissionsRepository should have_received(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).with(@"special-timesheet-uri",@"user-uri");
        });
        
        describe(@"should present TimesheetSummaryController", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });
            
            it(@"should add the timesheet summary controller as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timesheetSummaryController, subject, subject.timesheetSummaryContainerView);
            });
            
            it(@"should configure the timesheet summary controller", ^{
                timesheetSummaryController should have_received(@selector(setupWithDelegate:cursor:timesheet:)).with(subject,cursor,timesheet);
            });
        });
        
        describe(@"should present DayTimeSummaryController", ^{
            
            context(@"when in user context and breaks are Required", ^{
                
                beforeEach(^{
                    subject = [injector getInstance:[TimesheetDetailsController class]];
                    punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                    [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                      delegate:delegate
                                                     timesheet:timesheet
                                             hasPayrollSummary:NO
                                                hasBreakAccess:NO
                                                        cursor:cursor
                                                       userURI:@"user-uri"
                                                         title:@"This is the title of this screen"];
                    subject.view should_not be_nil;
                });
                
                it(@"should configure DayTimeSummaryController correctly", ^{
                    dayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:)).with(nil,nil,workHoursDeferred.promise,YES,YES,CGFloat(0.0f));
                });
                
                it(@"should add the DayTimeSummaryController as a child controller", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                    .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
                });
                
            });
            
            context(@"when in supervisor context", ^{
                
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);

                    [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                      delegate:delegate
                                                     timesheet:timesheet
                                             hasPayrollSummary:NO
                                                hasBreakAccess:NO
                                                        cursor:cursor
                                                       userURI:@"some-other-user-uri"
                                                         title:@"This is the title of this screen"];
                    subject.view should_not be_nil;
                });
                
                it(@"should configure DayTimeSummaryController correctly", ^{
                    dayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:)).with(nil,nil,workHoursDeferred.promise,NO,YES,CGFloat(0.0f));
                });
                
                it(@"should add the DayTimeSummaryController as a child controller", ^{
                    childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                    .with(dayTimeSummaryController, subject, subject.workHoursContainerView);
                });
            });

            
        });
        
        describe(@"should present TimesheetBreakdownController", ^{

            beforeEach(^{
                subject.view should_not be_nil;
            });
            
            it(@"should configure TimesheetBreakdownController correctly", ^{
                timesheetBreakdownController should have_received(@selector(setupWithDayTimeSummaries:delegate:)).with(@[dayTimeSummary1,dayTimeSummary2],subject);
            });
            it(@"should add a no date work hours controller as a child controller", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:))
                .with(timesheetBreakdownController, subject, subject.timesheetBreakdownContainerView);
            });
        });
        
        describe(@"when the timesheet additional promise is resolved", ^{
            
            it(@"should inform its delegate timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary", ^{
                subject.view should_not be_nil;
                [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                delegate should have_received(@selector(timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:)).with(expectedTimePeriodSummary);
            });
            
            describe(@"presenting the gross pay controller", ^{
                
                context(@"When the timesheetSummary doesn't have totalPay", ^{
                    
                    beforeEach(^{
                        globalTimePeriodSummary stub_method(@selector(totalPay)).and_return(nil);
                        timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);

                        [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                          delegate:delegate
                                                         timesheet:timesheet
                                                 hasPayrollSummary:NO
                                                    hasBreakAccess:NO
                                                            cursor:cursor
                                                           userURI:@"user-uri"
                                                             title:@"This is the title of this screen"];
                        subject.view should_not be_nil;
                    });
                    
                    it(@"should not add the gross pay controller to the view", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                    });
                    
                    it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                        subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                    });
                    
                });
                
                context(@"when actualsByPayCode count is empty", ^{
                    
                    beforeEach(^{
                        globalTimePeriodSummary stub_method(@selector(actualsByPayCode)).and_return(nil);
                        timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                        [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                          delegate:delegate
                                                         timesheet:timesheet
                                                 hasPayrollSummary:NO
                                                    hasBreakAccess:NO
                                                            cursor:cursor
                                                           userURI:@"user-uri"
                                                             title:@"This is the title of this screen"];
                        [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                        subject.view should_not be_nil;
                        
                    });
                    
                    it(@"should not add the gross pay controller to the view", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                    });
                    
                    it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                        subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                    });
                });
                
                describe(@"When viewing his own timesheets", ^{
                    __block id <UserSession> userSession;
                    __block CurrencyValue *totalPay;
                    beforeEach(^{
                        totalPay = nice_fake_for([CurrencyValue class]);
                        userSession = nice_fake_for(@protocol(UserSession));
                        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
                        globalTimePeriodSummary stub_method(@selector(totalPay)).and_return(totalPay);
                        globalTimePeriodSummary stub_method(@selector(actualsByPayCode)).and_return(@[@"some-actuals-by-paycode"]);
                        punchRulesStorage stub_method(@selector(userSession)).again().and_return(userSession);
                        
                    });
                    context(@"When payWidgetPermission is disabled", ^{
                        
                        beforeEach(^{
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:NO
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"user-uri"
                                                                 title:@"This is the title of this screen"];
                            timesheetAdditionalInfo stub_method(@selector(payDetailsPermission)).again().and_return(NO);
                            [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            subject.view should_not be_nil;
                            
                        });
                        
                        it(@"should not add the gross pay controller to the view", ^{
                            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                        });
                    });
                    
                    context(@"When payWidgetPermission is enabled", ^{
                        
                        beforeEach(^{
                            expectedTimePeriodSummary = [[TimePeriodSummary alloc] initWithRegularTimeComponents:nil
                                                                                             breakTimeComponents:nil
                                                                                       timesheetPermittedActions:timesheetPermittedActions
                                                                                              overtimeComponents:nil
                                                                                            payDetailsPermission:YES
                                                                                                dayTimeSummaries:@[dayTimeSummary1,dayTimeSummary2]
                                                                                                        totalPay:totalPay
                                                                                                      totalHours:nil
                                                                                                actualsByPayCode:@[@"some-actuals-by-paycode"]
                                                                                            actualsByPayDuration:nil
                                                                                             payAmountPermission:NO
                                                                                           scriptCalculationDate:@"some-value"
                                                                                               timeOffComponents:nil
                                                                                                  isScheduledDay:YES];
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:NO
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"user-uri"
                                                                 title:@"This is the title of this screen"];
                            timesheetAdditionalInfo stub_method(@selector(payDetailsPermission)).again().and_return(YES);
                            [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            subject.view should_not be_nil;
                            
                        });
                        
                        it(@"should call updateWithGrossPayTimeHomeViewController", ^{
                            grossPayTimeHomeViewController should have_received(@selector(setupWithGrossSummary:delegate:)).with(expectedTimePeriodSummary,subject);
                        });
                        
                        it(@"should add grossPayTimeHomeViewController as its child controller", ^{
                            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayTimeHomeViewController,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should not hide the grossPayContainerView", ^{
                            subject.grossPayContainerView.hidden should be_falsy;
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should be_greater_than(0);
                        });
                    });
                    
                });
                
                describe(@"When supervisor is viewing his team's timesheet's", ^{
                    __block id <UserSession> userSession;
                    __block CurrencyValue *totalPay;
                    beforeEach(^{
                        totalPay = nice_fake_for([CurrencyValue class]);
                        userSession = nice_fake_for(@protocol(UserSession));
                        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
                        globalTimePeriodSummary stub_method(@selector(totalPay)).and_return(totalPay);
                        globalTimePeriodSummary stub_method(@selector(actualsByPayCode)).and_return(@[@"some-actuals-by-paycode"]);
                        punchRulesStorage stub_method(@selector(userSession)).again().and_return(userSession);
                        timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).with(@"special-timesheet-uri",@"some-other-user-uri").and_return(timesheetInfoAndPermissionsDeferred.promise);

                        
                    });
                    context(@"When payWidgetPermission is disabled", ^{
                        
                        beforeEach(^{
                            
                            punchRulesStorage stub_method(@selector(canViewPayDetails)).and_return(NO);
                            globalTimePeriodSummary stub_method(@selector(payDetailsPermission)).and_return(YES);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:NO
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"some-other-user-uri"
                                                                 title:@"This is the title of this screen"];
                            [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            subject.view should_not be_nil;
                            
                        });
                        
                        it(@"should not add the gross pay controller to the view", ^{
                            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                        });
                    });
                    
                    context(@"When pay roll summary Permission is disabled", ^{
                        
                        beforeEach(^{
                            
                            punchRulesStorage stub_method(@selector(canViewPayDetails)).and_return(NO);
                            globalTimePeriodSummary stub_method(@selector(payDetailsPermission)).and_return(YES);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:NO
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"some-other-user-uri"
                                                                 title:@"This is the title of this screen"];
                            [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            subject.view should_not be_nil;
                            
                        });
                        
                        it(@"should not add the gross pay controller to the view", ^{
                            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                        });
                    });
                    
                    context(@"When  both payWidgetPermission and pay roll summary Permission is enabled", ^{
                        
                        beforeEach(^{
                            globalTimePeriodSummary stub_method(@selector(payDetailsPermission)).and_return(YES);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                            punchRulesStorage stub_method(@selector(canViewPayDetails)).and_return(YES);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:YES
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"some-other-user-uri"
                                                                 title:@"This is the title of this screen"];
                            expectedTimePeriodSummary = [[TimePeriodSummary alloc] initWithRegularTimeComponents:nil
                                                                                             breakTimeComponents:nil
                                                                                       timesheetPermittedActions:timesheetPermittedActions
                                                                                              overtimeComponents:nil
                                                                                            payDetailsPermission:YES
                                                                                                dayTimeSummaries:@[dayTimeSummary1,dayTimeSummary2]
                                                                                                        totalPay:totalPay
                                                                                                      totalHours:nil
                                                                                                actualsByPayCode:@[@"some-actuals-by-paycode"]
                                                                                            actualsByPayDuration:nil
                                                                                             payAmountPermission:NO
                                                                                           scriptCalculationDate:@"some-value"
                                                                                               timeOffComponents:nil
                                                                                                  isScheduledDay:YES];
                            [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            subject.view should_not be_nil;
                            
                        });
                        
                        it(@"should call updateWithGrossPayTimeHomeViewController", ^{
                            grossPayTimeHomeViewController should have_received(@selector(setupWithGrossSummary:delegate:)).with(expectedTimePeriodSummary,subject);
                        });
                        
                        it(@"should add grossPayTimeHomeViewController as its child controller", ^{
                            childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(grossPayTimeHomeViewController,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should not hide the grossPayContainerView", ^{
                            subject.grossPayContainerView.hidden should be_falsy;
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should be_greater_than(0);
                        });
                    });
                    
                });

            });
            
        });
    });
    
    describe(@"as a <TimesheetSummaryControllerDelegate>", ^{
        
        beforeEach(^{
            subject.view should_not be_nil;
        });
        describe(@"tapping on the previous timesheet button", ^{
            beforeEach(^{
                [subject timesheetSummaryControllerDidTapPreviousButton:nil];
            });
            
            it(@"should notify its delegate to show the previous timesheet", ^{
                delegate should have_received(@selector(timesheetDetailsControllerRequestsPreviousTimesheet:)).with(subject);
            });
            
            it(@"should cancel its timesheet extras promise", ^{
                timesheetInfoAndPermissionsDeferred.promise.cancelled should be_truthy;
            });
        });
        
        describe(@"tapping on the next timesheet button", ^{
            beforeEach(^{
                [subject timesheetSummaryControllerDidTapNextButton:nil];
            });
            
            it(@"should notify its delegate to show the previous timesheet", ^{
                delegate should have_received(@selector(timesheetDetailsControllerRequestsNextTimesheet:)).with(subject);
            });
            
            it(@"should cancel its timesheet extras promise", ^{
                timesheetInfoAndPermissionsDeferred.promise.cancelled should be_truthy;
            });
        });
        
        describe(@"tapping on the issues button", ^{
            __block ViolationsSummaryController *violationsSummaryController;
            __block KSDeferred *violationsDeferred;
            beforeEach(^{
                [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                violationsDeferred = [[KSDeferred alloc]init];
                [injector bind:[KSDeferred class] toInstance:violationsDeferred];

                violationsSummaryController = [[ViolationsSummaryController alloc]initWithSupervisorDashboardSummaryRepository:nil
                                                                                               violationSectionHeaderPresenter:nil
                                                                                                 selectedWaiverOptionPresenter:nil
                                                                                                    violationSeverityPresenter:nil
                                                                                                              teamTableStylist:nil
                                                                                                               spinnerDelegate:nil
                                                                                                                         theme:nil];
                [injector bind:[ViolationsSummaryController class] toInstance:violationsSummaryController];
                spy_on(violationsSummaryController);
                [subject timesheetSummaryControllerDidTapissuesButton:nil];
            });
            
            afterEach(^{
                stop_spying_on(violationsSummaryController);
            });
            
            it(@"should correctly configure ViolationsSummaryController", ^{
                violationsSummaryController should have_received(@selector(setupWithViolationSectionsPromise:delegate:)).with(violationsDeferred.promise,subject);
                violationsDeferred.promise.value should equal(@[@"some-violations"]);
            });
            
            it(@"should push ViolationsSummaryController on the navigation", ^{
                navigationController should have_received(@selector(pushViewController:animated:)).with(violationsSummaryController,Arguments::anything);
                navigationController.topViewController should equal(violationsSummaryController);
            });
        });
        
        describe(@"should timesheetSummaryControllerUpdateViewHeight:height:", ^{
            
            beforeEach(^{
                [subject timesheetSummaryControllerUpdateViewHeight:nil height:100];
            });
            it(@"should update timesheet Summary container Height Constraint correctly", ^{
                subject.timesheetSummaryHeightConstraint.constant should equal(100);
            });
        });
    });
    
    describe(@"As a <TimesheetBreakdownControllerDelegate>", ^{
        
        context(@"timesheetBreakDownContainerHeightConstraint", ^{
            
            beforeEach(^{
                [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                  delegate:delegate
                                                 timesheet:timesheet
                                         hasPayrollSummary:YES
                                            hasBreakAccess:NO
                                                    cursor:cursor
                                                   userURI:@"user-uri"
                                                     title:@"This is the title of this screen"];
                subject.view should_not be_nil;
            });
            
            it(@"should update the breakdown container's height correctly", ^{
                [subject timeSheetBreakdownController:nil didUpdateHeight:100];
                subject.timesheetBreakDownContainerHeightConstraint.constant should equal(100);
            });
            
            
        });
        
        context(@"timeSheetBreakdownController:didSelectDayWithDate:dayTimeSummaries:indexPath:", ^{

            __block DayController *dayController;
            __block NSDate *date;
            __block TimesheetDaySummary *timesheetDaySummaryA;
            __block TimesheetDaySummary *timesheetDaySummaryB;

            beforeEach(^{
                date = [NSDate dateWithTimeIntervalSince1970:0];
                timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                dayController = [[DayController alloc]initWithDayTimeSummaryTitlePresenter:nil
                                                               dayTimeSummaryCellPresenter:nil
                                                                     childControllerHelper:nil
                                                                               userSession:nil
                                                                                     theme:nil];
                [injector bind:[DayController class] toInstance:dayController];
                spy_on(dayController);
            });
            
            afterEach(^{
                stop_spying_on(dayController);
            });
            
            context(@"when in user context", ^{
                __block id <UserSession> userSession;
                beforeEach(^{
                    punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                    userSession = nice_fake_for(@protocol(UserSession));
                    userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
                    punchRulesStorage stub_method(@selector(userSession)).again().and_return(userSession);
                    [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                      delegate:delegate
                                                     timesheet:timesheet
                                             hasPayrollSummary:YES
                                                hasBreakAccess:NO
                                                        cursor:cursor
                                                       userURI:@"user-uri"
                                                         title:@"This is the title of this screen"];
                    subject.view should_not be_nil;
                    [subject timeSheetBreakdownController:nil
                                     didSelectDayWithDate:date
                                         dayTimeSummaries:@[timesheetDaySummaryA,timesheetDaySummaryB]
                                                indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

                });
                
                it(@"should correctly configure DayController", ^{
                    dayController should have_received(@selector(setupWithPunchChangeObserverDelegate:timesheetDaySummary:hasBreakAccess:delegate:userURI:date:)).with(subject,timesheetDaySummaryA,YES,nil,@"user-uri",date);
                });
                
                it(@"should push DayController on the navigation", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(dayController,Arguments::anything);
                    navigationController.topViewController should equal(dayController);
                });
            });
            
            context(@"when in supervisor context", ^{
                __block id <UserSession> userSession;
                beforeEach(^{
                    userSession = nice_fake_for(@protocol(UserSession));
                    userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
                    punchRulesStorage stub_method(@selector(userSession)).again().and_return(userSession);
                    punchRulesStorage stub_method(@selector(breaksRequired)).and_return(YES);
                    [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                      delegate:delegate
                                                     timesheet:timesheet
                                             hasPayrollSummary:YES
                                                hasBreakAccess:NO
                                                        cursor:cursor
                                                       userURI:@"some-other-user-uri"
                                                         title:@"This is the title of this screen"];
                    subject.view should_not be_nil;
                    [subject timeSheetBreakdownController:nil
                                     didSelectDayWithDate:date
                                         dayTimeSummaries:@[timesheetDaySummaryA,timesheetDaySummaryB]
                                                indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    
                });
                
                it(@"should correctly configure DayController", ^{
                    dayController should have_received(@selector(setupWithPunchChangeObserverDelegate:timesheetDaySummary:hasBreakAccess:delegate:userURI:date:)).with(subject,timesheetDaySummaryA,NO,nil,@"some-other-user-uri",date);
                });
                
                it(@"should push DayController on the navigation", ^{
                    navigationController should have_received(@selector(pushViewController:animated:)).with(dayController,Arguments::anything);
                    navigationController.topViewController should equal(dayController);
                });
            });

        });
    });
    
    describe(@"the navigation bar behavior", ^{
        __block UINavigationController *navigationController;
        
        beforeEach(^{
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            navigationController.navigationBarHidden = YES;
            
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });
        
        it(@"should show the navigation bar", ^{
            navigationController.navigationBarHidden should_not be_truthy;
        });
    });
    
    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(timesheetDetailsBorderColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(timesheetDetailsBackgroundColor)).and_return([UIColor greenColor]);
            subject.view should_not be_nil;
        });
        
        it(@"should style the views", ^{
            subject.edgesForExtendedLayout should equal(UIRectEdgeNone);
            subject.view.backgroundColor should equal([UIColor greenColor]);
            subject.separatorLineView.backgroundColor should equal([UIColor yellowColor]);
            subject.timesheetSummaryContainerView.backgroundColor should equal([UIColor orangeColor]);
            subject.workHoursContainerView.backgroundColor should equal([UIColor orangeColor]);
            subject.timesheetBreakdownContainerView.backgroundColor should equal([UIColor orangeColor]);
        });
    });
    
    describe(@"the navigation bar behavior", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });
        
        
        it(@"should set the title for the navigation bar", ^{
            subject.title should equal(@"This is the title of this screen");
        });
    });
    
    describe(@"as a <ViolationsSummaryControllerDelegate>", ^{
        describe(@"violationsSummaryControllerDidRequestViolationSectionsPromise:", ^{
            __block KSPromise *violationsPromise;
            __block KSDeferred *newTimesheetInfoAndPermissionsDeferred;
            __block TimesheetAdditionalInfo *timesheetAdditionalInfo;
            __block AllViolationSections *allViolationSections;
            
            beforeEach(^{
                subject.view should_not be_nil;
                allViolationSections = fake_for([AllViolationSections class]);
                timesheetAdditionalInfo = nice_fake_for([TimesheetAdditionalInfo class]);
                timesheetAdditionalInfo stub_method(@selector(allViolationSections)).and_return(allViolationSections);
                newTimesheetInfoAndPermissionsDeferred = [[KSDeferred alloc]init];
                timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).again().with(@"special-timesheet-uri",@"user-uri").and_return(newTimesheetInfoAndPermissionsDeferred.promise);
                
                violationsPromise = [subject violationsSummaryControllerDidRequestViolationSectionsPromise:nil];
                
            });
            
            it(@"should request the spinnerOperationsCounter to increment", ^{
                spinnerOperationsCounter should have_received(@selector(increment));
            });
            
            context(@"When newTimesheetInfoAndPermissionsDeferred succeeds", ^{
                
                beforeEach(^{
                    [newTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                });
                it(@"should return an all violation sections promise for the timesheetn when ", ^{
                    violationsPromise.value should be_same_instance_as(allViolationSections);
                });
                
                it(@"should request the spinnerOperationsCounter to decrement", ^{
                    spinnerOperationsCounter should have_received(@selector(decrement));
                });
            });
            
            context(@"When newTimesheetInfoAndPermissionsDeferred fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [newTimesheetInfoAndPermissionsDeferred rejectWithError:error];
                });
                it(@"should resolved with the correct error", ^{
                    violationsPromise.error should be_same_instance_as(error);

                });
                it(@"should request the spinnerOperationsCounter to decrement", ^{
                    spinnerOperationsCounter should have_received(@selector(decrement));
                });
            });
        });
    });
    
    describe(@"as a <PunchChangeObserverDelegate>", ^{
        
        describe(@"punchOverviewEditControllerDidUpdatePunch", ^{
            __block KSDeferred *newTimesheetInfoDeferred;
            __block KSPromise *overviewEditPromise;
            __block DayController *dayController;
            __block TimesheetDaySummary *timesheetDaySummaryA;
            __block TimesheetDaySummary *timesheetDaySummaryB;
            __block GrossPayTimeHomeViewController *newerGrossPayTimeHomeViewController;
            __block TimesheetBreakdownController *newerTimesheetBreakdownController;
            __block TimesheetSummaryController *newerTimesheetSummaryController;
            __block DayTimeSummaryController <CedarDouble>*newerDayTimeSummaryController;
            __block CurrencyValue *totalPay;
            __block KSPromise *workHoursPromise;
            beforeEach(^{
                totalPay = nice_fake_for([CurrencyValue class]);
                timesheetDaySummaryA = nice_fake_for([TimesheetDaySummary class]);
                timesheetDaySummaryB = nice_fake_for([TimesheetDaySummary class]);
                dayController = [[DayController alloc]initWithDayTimeSummaryTitlePresenter:nil
                                                               dayTimeSummaryCellPresenter:nil
                                                                     childControllerHelper:nil
                                                                               userSession:nil
                                                                                     theme:nil];
                [injector bind:[DayController class] toInstance:dayController];
                
                subject = [injector getInstance:[TimesheetDetailsController class]];
                navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
                
                [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                  delegate:delegate
                                                 timesheet:timesheet
                                         hasPayrollSummary:NO
                                            hasBreakAccess:NO
                                                    cursor:cursor
                                                   userURI:@"user-uri"
                                                     title:@"This is the title of this screen"];
                
                timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).again().with(@"special-timesheet-uri",@"user-uri").and_return(timesheetInfoAndPermissionsDeferred.promise);

                globalTimePeriodSummary stub_method(@selector(actualsByPayCode)).and_return(@[@"some-actuals-by-paycode"]);
                globalTimePeriodSummary stub_method(@selector(totalPay)).and_return(totalPay);
                timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                subject.view should_not be_nil;
                [timesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                newTimesheetInfoDeferred = [[KSDeferred alloc]init];
                delegate stub_method(@selector(timesheetDetailsControllerRequestsLatestPunches:)).with(subject).and_return(newTimesheetInfoDeferred.promise);
                overviewEditPromise = [subject punchOverviewEditControllerDidUpdatePunch];
                
                newerGrossPayTimeHomeViewController = [[GrossPayTimeHomeViewController alloc] initWithTheme:nil];
                [injector bind:[GrossPayTimeHomeViewController class] toInstance:newerGrossPayTimeHomeViewController];
                
                newerTimesheetBreakdownController = [injector getInstance:[TimesheetBreakdownController class]];
                [injector bind:[TimesheetBreakdownController class] toInstance:newerTimesheetBreakdownController];
                
                newerDayTimeSummaryController = nice_fake_for([DayTimeSummaryController class]);
                [injector bind:[DayTimeSummaryController class] toInstance:newerDayTimeSummaryController];
                
                newerTimesheetSummaryController = nice_fake_for([TimesheetSummaryController class]);
                [injector bind:[TimesheetSummaryController class] toInstance:newerTimesheetSummaryController];

                newerDayTimeSummaryController stub_method(@selector((setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:))).and_do_block(^(id<DayTimeSummaryUpdateDelegate>receivedDelegate, id <WorkHours> placeHolderWorkHours, KSPromise *receivedPromise,BOOL hasBreakAccess, BOOL isScheduledDay, CGFloat todaysDateContainerHeight) {
                    workHoursPromise = receivedPromise;
                });

                WorkHoursDeferred *workHoursDeferred = nice_fake_for([WorkHoursDeferred class]);
                [injector bind:[WorkHoursDeferred class] toInstance:workHoursDeferred];
                
                [subject timeSheetBreakdownController:nil
                                 didSelectDayWithDate:[NSDate dateWithTimeIntervalSince1970:0]
                                     dayTimeSummaries:@[timesheetDaySummaryA,timesheetDaySummaryB]
                                            indexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                
                spy_on(newerTimesheetSummaryController);
                spy_on(dayController);
                spy_on(newerGrossPayTimeHomeViewController);
                spy_on(newerTimesheetBreakdownController);
                spy_on(newerDayTimeSummaryController);
                spy_on(navigationController);
            });
            
            afterEach(^{
                stop_spying_on(newerTimesheetSummaryController);
                stop_spying_on(dayController);
                stop_spying_on(newerGrossPayTimeHomeViewController);
                stop_spying_on(newerTimesheetBreakdownController);
                stop_spying_on(newerDayTimeSummaryController);
                stop_spying_on(navigationController);
            });

            it(@"should request its delegate to return the newest timesheet info promise", ^{
                delegate should have_received(@selector(timesheetDetailsControllerRequestsLatestPunches:)).with(subject);
            });
            
            context(@"when timesheet info fetch fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [newTimesheetInfoDeferred rejectWithError:error];
                });
                it(@"should resolved with the correct error", ^{
                    overviewEditPromise.error should be_same_instance_as(error);
                    
                });
                it(@"should request the spinnerOperationsCounter to decrement", ^{
                    spinnerOperationsCounter should have_received(@selector(decrement));
                });
            });
            
            context(@"when timesheet info fetch succeeds", ^{
                __block KSDeferred *newestTimesheetInfoAndPermissionsDeferred;
                __block TimePeriodSummary *timePeriodSummary;
                beforeEach(^{
                    timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                    timePeriodSummary stub_method(@selector(totalPay)).and_return(nil);
                    timePeriodSummary stub_method(@selector(actualsByPayCode)).and_return(nil);
                    timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(@[timesheetDaySummaryA,timesheetDaySummaryB]);
                    timePeriodSummary stub_method(@selector(isScheduledDay)).and_return(YES);
                    [childControllerHelper reset_sent_messages];
                    newestTimesheetInfoAndPermissionsDeferred = [[KSDeferred alloc]init];
                    timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).again().with(@"special-timesheet-uri",@"user-uri").and_return(newestTimesheetInfoAndPermissionsDeferred.promise);
                    timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                    [newTimesheetInfoDeferred resolveWithValue:timesheet];
                });
                
                it(@"should delete all the previous audit storage", ^{
                    auditHistoryStorage should have_received(@selector(deleteAllRows));
                });
                
                it(@"should update the timesheet and hold its reference", ^{
                    subject.timesheet should equal(timesheet);
                });
                
                it(@"should replace older DayTimeSummaryController child controller", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(dayTimeSummaryController,newerDayTimeSummaryController,subject,subject.workHoursContainerView);
                });
                
                it(@"should setup DayTimeSummaryController  correctly", ^{
                    newerDayTimeSummaryController should have_received(@selector(setupWithDelegate:placeHolderWorkHours:workHoursPromise:hasBreakAccess:isScheduledDay:todaysDateContainerHeight:)).with(nil,nil,Arguments::anything,NO,YES,CGFloat(0.0f));
                    workHoursPromise.value should equal(timePeriodSummary);
                });
                
                context(@"when timesheet additional info fetch succeeds", ^{
                    __block TimesheetAdditionalInfo *timesheetAdditionalInfo;
                    beforeEach(^{
                        timesheetAdditionalInfo = nice_fake_for([TimesheetAdditionalInfo class]);
                        timesheetAdditionalInfo stub_method(@selector(allViolationSections)).and_return(@[@"value"]);
                        [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                    });
                    
                    it(@"should update the DayController", ^{
                        dayController should have_received(@selector(updateWithDayTimeSummaries:)).with(timesheetDaySummaryB);
                    });
                    
                    it(@"should resolved with the correct error", ^{
                        overviewEditPromise.value should equal(@[@"value"]);
                    });
                    
                    it(@"should request the spinnerOperationsCounter to decrement", ^{
                        spinnerOperationsCounter should have_received(@selector(decrement));
                    });
                    
                });
                
                context(@"when timesheet additional info fetch fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [newestTimesheetInfoAndPermissionsDeferred rejectWithError:error];
                    });
                    it(@"should resolved with the correct error", ^{
                        overviewEditPromise.error should be_same_instance_as(error);
                        
                    });
                    it(@"should request the spinnerOperationsCounter to decrement", ^{
                        spinnerOperationsCounter should have_received(@selector(decrement));
                    });
                });
            });
            
            describe(@"presenting timesheetbreakdowncontroller with updated data", ^{
                __block KSDeferred *newestTimesheetInfoAndPermissionsDeferred;
                context(@"when ", ^{
                    beforeEach(^{
                        [childControllerHelper reset_sent_messages];
                        globalTimePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                        globalTimePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(@[timesheetDaySummaryA,timesheetDaySummaryB]);
                        
                        newestTimesheetInfoAndPermissionsDeferred = [[KSDeferred alloc]init];
                        timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).with(@"special-timesheet-uri",@"some-other-user-uri").and_return(newestTimesheetInfoAndPermissionsDeferred.promise);

                        timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                        [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                          delegate:delegate
                                                         timesheet:timesheet
                                                 hasPayrollSummary:YES
                                                    hasBreakAccess:NO
                                                            cursor:cursor
                                                           userURI:@"some-other-user-uri"
                                                             title:@"This is the title of this screen"];
                        [newTimesheetInfoDeferred resolveWithValue:timesheet];
                        [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                    });
                    
                    it(@"should call updateWithGrossPayTimeHomeViewController", ^{
                        newerTimesheetBreakdownController should have_received(@selector(setupWithDayTimeSummaries:delegate:)).with(@[timesheetDaySummaryA,timesheetDaySummaryB],subject);
                    });
                    
                    it(@"should replace older grossPayTimeHomeViewController as its child controller", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetBreakdownController,newerTimesheetBreakdownController,subject,subject.timesheetBreakdownContainerView);
                    });
                });
            });
            
            describe(@"presenting timesheetsummarycontroller with updated data", ^{
                context(@"when ", ^{
                    beforeEach(^{
                        [childControllerHelper reset_sent_messages];
                        globalTimePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                        globalTimePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(@[timesheetDaySummaryA,timesheetDaySummaryB]);
                        
                        timesheet stub_method(@selector(timePeriodSummary)).again().and_return(globalTimePeriodSummary);
                        [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                          delegate:delegate
                                                         timesheet:timesheet
                                                 hasPayrollSummary:YES
                                                    hasBreakAccess:NO
                                                            cursor:cursor
                                                           userURI:@"some-other-user-uri"
                                                             title:@"This is the title of this screen"];
                        [newTimesheetInfoDeferred resolveWithValue:timesheet];
                    });
                    
                    it(@"should call updateWithGrossPayTimeHomeViewController", ^{
                        newerTimesheetSummaryController should have_received(@selector(setupWithDelegate:cursor:timesheet:)).with(subject, cursor, timesheet);
                    });
                    
                    it(@"should replace older grossPayTimeHomeViewController as its child controller", ^{
                        childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(timesheetSummaryController,newerTimesheetSummaryController,subject,subject.timesheetSummaryContainerView);
                    });
                });
            });


            
            describe(@"presenting the gross pay controller", ^{
                
                __block KSDeferred *newestTimesheetInfoAndPermissionsDeferred;
                __block TimePeriodSummary *timePeriodSummary;
                beforeEach(^{
                    [childControllerHelper reset_sent_messages];
                    timePeriodSummary = nice_fake_for([TimePeriodSummary class]);
                    timePeriodSummary stub_method(@selector(actualsByPayCode)).and_return(@[@"some-actuals-by-paycode"]);
                    timePeriodSummary stub_method(@selector(totalPay)).and_return(totalPay);
                    timePeriodSummary stub_method(@selector(dayTimeSummaries)).and_return(@[timesheetDaySummaryA,timesheetDaySummaryB]);
                    timePeriodSummary stub_method(@selector(isScheduledDay)).and_return(YES);
                    
                    newestTimesheetInfoAndPermissionsDeferred = [[KSDeferred alloc]init];
                    timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).again().with(@"special-timesheet-uri",@"user-uri").and_return(newestTimesheetInfoAndPermissionsDeferred.promise);
                });
                
                context(@"When the timesheetSummary doesn't have totalPay", ^{
                    beforeEach(^{
                        timePeriodSummary stub_method(@selector(totalPay)).again().and_return(nil);
                        timePeriodSummary stub_method(@selector(actualsByPayCode)).again().and_return(@[@"some-value"]);
                        timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                        [newTimesheetInfoDeferred resolveWithValue:timesheet];
                        [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];

                    });
                    it(@"should not add the gross pay controller to the view", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                    });
                    
                    it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                        subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                    });
                    
                });
                
                context(@"when actualsByPayCode count is empty", ^{
                    
                    beforeEach(^{
                        timePeriodSummary stub_method(@selector(totalPay)).again().and_return(totalPay);
                        timePeriodSummary stub_method(@selector(actualsByPayCode)).again().and_return(nil);
                        timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                        [newTimesheetInfoDeferred resolveWithValue:timesheet];
                        [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];

                    });
                    
                    it(@"should not add the gross pay controller to the view", ^{
                        childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                    });
                    
                    it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                        subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                    });
                });
                
                describe(@"When viewing his own timesheets", ^{
                    __block id <UserSession> userSession;
                    beforeEach(^{
                        
                        userSession = nice_fake_for(@protocol(UserSession));
                        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
                        punchRulesStorage stub_method(@selector(userSession)).again().and_return(userSession);
                        
                    });
                    context(@"When payWidgetPermission is disabled", ^{
                        
                        beforeEach(^{
                            timesheetAdditionalInfo stub_method(@selector(payDetailsPermission)).again().and_return(NO);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                            [newTimesheetInfoDeferred resolveWithValue:timesheet];
                            [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                        });
                        
                        it(@"should not add the gross pay controller to the view", ^{
                            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                        });
                    });
                    
                    context(@"When payWidgetPermission is enabled", ^{
                        
                        
                        beforeEach(^{
                            timesheetAdditionalInfo stub_method(@selector(payDetailsPermission)).again().and_return(YES);
                            expectedTimePeriodSummary = [[TimePeriodSummary alloc] initWithRegularTimeComponents:nil
                                                                                             breakTimeComponents:nil
                                                                                       timesheetPermittedActions:timesheetPermittedActions
                                                                                              overtimeComponents:nil
                                                                                            payDetailsPermission:YES
                                                                                                dayTimeSummaries:@[timesheetDaySummaryA, timesheetDaySummaryB]
                                                                                                        totalPay:totalPay
                                                                                                      totalHours:nil
                                                                                                actualsByPayCode:@[@"some-actuals-by-paycode"]
                                                                                            actualsByPayDuration:nil
                                                                                             payAmountPermission:NO
                                                                                           scriptCalculationDate:@"some-value"
                                                                                               timeOffComponents:nil
                                                                                                  isScheduledDay:YES];
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                            [newTimesheetInfoDeferred resolveWithValue:timesheet];
                            [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            spy_on(newerGrossPayTimeHomeViewController);
                        });
                        
                        afterEach(^{
                            stop_spying_on(newerGrossPayTimeHomeViewController);
                        });
                        
                        it(@"should call updateWithGrossPayTimeHomeViewController", ^{
                            newerGrossPayTimeHomeViewController should have_received(@selector(setupWithGrossSummary:delegate:)).with(expectedTimePeriodSummary,subject);
                        });
                        
                        it(@"should replace older grossPayTimeHomeViewController as its child controller", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(grossPayTimeHomeViewController,newerGrossPayTimeHomeViewController,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should notify delegate to update buttons action", ^{
                            delegate should have_received(@selector(timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:)).with(expectedTimePeriodSummary);
                        });

                        it(@"should not hide the grossPayContainerView", ^{
                            subject.grossPayContainerView.hidden should be_falsy;
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should be_greater_than(0);
                        });
                    });
                    
                });
                
                describe(@"When supervisor is viewing his team's timesheet's", ^{
                    __block id <UserSession> userSession;
                    beforeEach(^{
                        userSession = nice_fake_for(@protocol(UserSession));
                        userSession stub_method(@selector(currentUserURI)).and_return(@"user-uri");
                        punchRulesStorage stub_method(@selector(userSession)).again().and_return(userSession);
                        timesheetInfoAndPermissionsRepository stub_method(@selector(fetchTimesheetInfoForTimsheetUri:userUri:)).with(@"special-timesheet-uri",@"some-other-user-uri").and_return(timesheetInfoAndPermissionsDeferred.promise);
                    });
                    
                    context(@"When payWidgetPermission is disabled", ^{
                        
                        beforeEach(^{
                            
                            punchRulesStorage stub_method(@selector(canViewPayDetails)).and_return(NO);
                            timePeriodSummary stub_method(@selector(payDetailsPermission)).and_return(YES);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:NO
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"some-other-user-uri"
                                                                 title:@"This is the title of this screen"];
                            [newTimesheetInfoDeferred resolveWithValue:timesheet];
                            [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            
                        });
                        
                        it(@"should not add the gross pay controller to the view", ^{
                            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                        });
                    });
                    
                    context(@"When pay roll summary Permission is disabled", ^{
                        
                        beforeEach(^{
                            
                            punchRulesStorage stub_method(@selector(canViewPayDetails)).and_return(NO);
                            timePeriodSummary stub_method(@selector(payDetailsPermission)).and_return(YES);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:NO
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"some-other-user-uri"
                                                                 title:@"This is the title of this screen"];
                            [newTimesheetInfoDeferred resolveWithValue:timesheet];
                            [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            
                        });
                        
                        it(@"should not add the gross pay controller to the view", ^{
                            childControllerHelper should_not have_received(@selector(addChildController:toParentController:inContainerView:)).with(Arguments::anything,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should equal((CGFloat)0);
                        });
                    });
                    
                    context(@"When  both payWidgetPermission and pay roll summary Permission is enabled", ^{
                        beforeEach(^{
                            timePeriodSummary stub_method(@selector(payDetailsPermission)).and_return(YES);
                            timesheet stub_method(@selector(timePeriodSummary)).again().and_return(timePeriodSummary);
                            punchRulesStorage stub_method(@selector(canViewPayDetails)).and_return(YES);
                            [subject setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                              delegate:delegate
                                                             timesheet:timesheet
                                                     hasPayrollSummary:YES
                                                        hasBreakAccess:NO
                                                                cursor:cursor
                                                               userURI:@"some-other-user-uri"
                                                                 title:@"This is the title of this screen"];
                            expectedTimePeriodSummary = [[TimePeriodSummary alloc] initWithRegularTimeComponents:nil
                                                                                             breakTimeComponents:nil
                                                                                       timesheetPermittedActions:timesheetPermittedActions
                                                                                              overtimeComponents:nil
                                                                                            payDetailsPermission:YES
                                                                                                dayTimeSummaries:@[timesheetDaySummaryA, timesheetDaySummaryB]
                                                                                                        totalPay:totalPay
                                                                                                      totalHours:nil
                                                                                                actualsByPayCode:@[@"some-actuals-by-paycode"]
                                                                                            actualsByPayDuration:nil
                                                                                             payAmountPermission:NO
                                                                                           scriptCalculationDate:@"some-value"
                                                                                               timeOffComponents:nil
                                                                                                  isScheduledDay:YES];
                            [newTimesheetInfoDeferred resolveWithValue:timesheet];
                            [newestTimesheetInfoAndPermissionsDeferred resolveWithValue:timesheetAdditionalInfo];
                            
                        });
                        
                        it(@"should call updateWithGrossPayTimeHomeViewController", ^{
                            newerGrossPayTimeHomeViewController should have_received(@selector(setupWithGrossSummary:delegate:)).with(expectedTimePeriodSummary,subject);
                        });
                        
                        it(@"should replace older grossPayTimeHomeViewController as its child controller", ^{
                            childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(grossPayTimeHomeViewController,newerGrossPayTimeHomeViewController,subject,subject.grossPayContainerView);
                        });
                        
                        it(@"should not hide the grossPayContainerView", ^{
                            subject.grossPayContainerView.hidden should be_falsy;
                        });
                        
                        it(@"should set the grossPayContainerHeightConstraint correctly", ^{
                            subject.grossPayContainerHeightConstraint.constant should be_greater_than(0);
                        });
                    });
                    
                });
                
            });
        });
    });
});

SPEC_END
