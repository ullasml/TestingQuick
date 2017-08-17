#import <Cedar/Cedar.h>
#import "TimesheetDetailsPresenter.h"
#import "Timesheet.h"
#import "TimesheetPeriod.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "cursor.h"
#import "TimeSheetApprovalStatus.h"
#import "DateProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetDetailsPresenterSpec)

describe(@"TimesheetDetailsPresenter", ^{
    __block id<BSInjector, BSBinder> injector;
    __block TimesheetDetailsPresenter *subject;
    __block NSDateFormatter *dateFormatter;
    __block DateProvider *dateProvider;

    beforeEach(^{
        injector = [InjectorProvider injector];
        dateProvider = nice_fake_for([DateProvider class]);
        dateFormatter = [injector getInstance:InjectorKeyDayMonthInUTCTimeZoneFormatter];
        subject = [[TimesheetDetailsPresenter alloc] initWithDateFormatter:dateFormatter
                                                              dateProvider:dateProvider];
    });

    describe(@"presenting a team time summary's date range", ^{
        it(@"should display the timesheet period", ^{
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = 14;
            startDateComponents.month = 5;
            startDateComponents.year = 2015;

            NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
            endDateComponents.day = 20;
            endDateComponents.month = 5;
            endDateComponents.year = 2015;

            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

            NSDate *startDate = [calendar dateFromComponents:startDateComponents];
            NSDate *endDate = [calendar dateFromComponents:endDateComponents];

            TimesheetPeriod *timesheetPeriod = [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];
            
            NSString *dateRangeText = [subject dateRangeTextWithTimesheetPeriod:timesheetPeriod];
            NSString *startDateString = [dateFormatter stringFromDate:startDate];
            NSString *endDateString = [dateFormatter stringFromDate:endDate];
            dateRangeText should equal([NSString stringWithFormat:@"%@ - %@", startDateString, endDateString]);
        });
    });

    describe(@"presenting a team time summary's approval status", ^{

        context(@"When timeSheet period is current and cursor cannot move forward", ^{
            __block id<Cursor> cursor;
            __block TimeSheetApprovalStatus *approvalStatus;
            __block TimesheetPeriod *period;
            beforeEach(^{
                cursor = nice_fake_for(@protocol(Cursor));
                cursor stub_method(@selector(canMoveForwards)).and_return(NO);
                cursor stub_method(@selector(canMoveBackwards)).and_return(YES);

                NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:[NSTimeZone defaultTimeZone]];
                comp.day--;
                NSDate *yesterday = [NSDate dateWithDateComponents:comp];

                NSDateComponents *comp1 = [[NSDate date] dateComponentsWithTimeZone:[NSTimeZone defaultTimeZone]];
                comp1.day++;
                NSDate *tomorrow = [NSDate dateWithDateComponents:comp1];

                period = nice_fake_for([TimesheetPeriod class]);
                period stub_method(@selector(startDate)).and_return(yesterday);
                period stub_method(@selector(endDate)).and_return(tomorrow);
            });

            it(@"should display the timesheet period", ^{

                approvalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"uri" approvalStatus:@"Not Submitted"];

                NSString *approvalStatusString = [subject approvalStatusForTimeSheet:approvalStatus cursor:cursor timeSheetPeriod:period];
                NSString *currenPeriodString = RPLocalizedString(@"Current Period", @"Current Period");
                approvalStatusString should equal(currenPeriodString);
            });
        });

        context(@"When timeSheet period is not current and cursor can move forward/backward", ^{
            __block id<Cursor> cursor;
            __block TimeSheetApprovalStatus *approvalStatus;
             __block TimesheetPeriod *period;
            beforeEach(^{
                cursor = nice_fake_for(@protocol(Cursor));
                cursor stub_method(@selector(canMoveForwards)).and_return(YES);
                cursor stub_method(@selector(canMoveBackwards)).and_return(YES);

                period = nice_fake_for([TimesheetPeriod class]);
                period stub_method(@selector(startDate)).and_return([NSDate firstDateOfWeek]);
                period stub_method(@selector(endDate)).and_return([NSDate yesterday]);
            });

            it(@"should display the timesheet period", ^{

                approvalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"uri" approvalStatus:@"Not Submitted"];

                NSString *approvalStatusString = [subject approvalStatusForTimeSheet:approvalStatus cursor:cursor timeSheetPeriod:period];
                approvalStatusString should equal(@"");
            });
        });

        context(@"When timeSheet period is not current and cursor can move forward but cannot move backward", ^{
            __block id<Cursor> cursor;
            __block TimeSheetApprovalStatus *approvalStatus;
             __block TimesheetPeriod *period;
            beforeEach(^{
                cursor = nice_fake_for(@protocol(Cursor));
                cursor stub_method(@selector(canMoveForwards)).and_return(YES);
                cursor stub_method(@selector(canMoveBackwards)).and_return(NO);

                period = nice_fake_for([TimesheetPeriod class]);
                period stub_method(@selector(startDate)).and_return([NSDate firstDateOfWeek]);
                period stub_method(@selector(endDate)).and_return([NSDate yesterday]);
            });

            it(@"should display the timesheet period", ^{

                approvalStatus = [[TimeSheetApprovalStatus alloc] initWithApprovalStatusUri:@"uri" approvalStatus:@"Not Submitted"];

                NSString *approvalStatusString = [subject approvalStatusForTimeSheet:approvalStatus cursor:cursor timeSheetPeriod:period];
                approvalStatusString should equal(@"");
            });
        });


    });
    
    describe(@"present the current timesheet text", ^{
        
        __block TimesheetPeriod *timesheetPeriod;
        beforeEach(^{
            
            NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
            startDateComponents.day = 14;
            startDateComponents.month = 5;
            startDateComponents.year = 2015;
            
            NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
            endDateComponents.day = 20;
            endDateComponents.month = 5;
            endDateComponents.year = 2015;
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *startDate = [calendar dateFromComponents:startDateComponents];
            NSDate *endDate = [calendar dateFromComponents:endDateComponents];

            timesheetPeriod = [[TimesheetPeriod alloc] initWithStartDate:startDate endDate:endDate];
            
        });
        
        it(@"when timesheet is current timesheet", ^{
            
            NSDateComponents *todayComponents = [[NSDateComponents alloc] init];
            todayComponents.day = 16;
            todayComponents.month = 5;
            todayComponents.year = 2015;
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *todayDate = [calendar dateFromComponents:todayComponents];
            
            dateProvider stub_method(@selector(date)).and_return(todayDate);
            [subject isCurrentTimesheetForPeriod:timesheetPeriod] should be_truthy;

        });
        
        it(@"when timesheet is not current timesheet", ^{
            NSDateComponents *todayComponents = [[NSDateComponents alloc] init];
            todayComponents.day = 26;
            todayComponents.month = 5;
            todayComponents.year = 2015;
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *todayDate = [calendar dateFromComponents:todayComponents];
            
            dateProvider stub_method(@selector(date)).and_return(todayDate);
            
            [subject isCurrentTimesheetForPeriod:timesheetPeriod] should be_falsy;
        });
        
    });
});

SPEC_END
