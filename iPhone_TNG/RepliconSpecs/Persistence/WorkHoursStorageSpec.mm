#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "WorkHoursStorage.h"
#import "DayTimeSummary.h"
#import "DateProvider.h"
#import "DurationCalculator.h"
#import "UserSession.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(WorkHoursStorageSpec)

describe(@"WorkHoursStorage", ^{
    __block WorkHoursStorage *subject;
    __block NSFileManager *fileManager;
    __block DayTimeSummary *workHours;
    __block DoorKeeper *doorKeeper;
    __block DateProvider *dateProvider;
    __block DurationCalculator *durationCalculator;
    __block id <UserSession> userSession;
    beforeEach(^{
        dateProvider = nice_fake_for([DateProvider class]);
        fileManager = nice_fake_for([NSFileManager class]);
        doorKeeper = nice_fake_for([DoorKeeper class]);
        durationCalculator = nice_fake_for([DurationCalculator class]);
        userSession = nice_fake_for(@protocol(UserSession));

        subject = [[WorkHoursStorage alloc] initWithDurationCalculator:durationCalculator
                                                           fileManager:fileManager
                                                          dateProvider:dateProvider
                                                            doorKeeper:doorKeeper
                                                           userSession:userSession];
    });

    it(@"should have added itself as an observer to <DoorKeeperLogOutObserver>", ^{
        doorKeeper should have_received(@selector(addLogOutObserver:)).with(subject);
    });

    context(@"When storing and fetching summary on a same day", ^{
        __block id <WorkHours> expectedWorkHours;
        __block  NSDateComponents *regularTimeComponents;
        __block NSDateComponents *breakTimeComponents;
        __block NSDateComponents *dateComponents;
        __block NSDateComponents *addedRegularTimeComponents;
        __block NSDateComponents *addedBreakTimeComponents;
        __block NSDateComponents *regularTimeOffsetComponents;
        __block NSDateComponents *breakTimeOffsetComponents;

        beforeEach(^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1438174180];
            dateProvider stub_method(@selector(date)).and_return(date);
            regularTimeComponents = [[NSDateComponents alloc]init];
            [regularTimeComponents setHour:1];
            [regularTimeComponents setMinute:2];
            [regularTimeComponents setSecond:3];

            breakTimeComponents = [[NSDateComponents alloc]init];
            [breakTimeComponents setHour:3];
            [breakTimeComponents setMinute:4];
            [breakTimeComponents setSecond:5];

            breakTimeOffsetComponents = [[NSDateComponents alloc]init];
            [breakTimeOffsetComponents setHour:6];
            [breakTimeOffsetComponents setMinute:7];
            [breakTimeOffsetComponents setSecond:8];

            dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setDay:29];
            [dateComponents setMonth:7];
            [dateComponents setYear:2015];

            regularTimeOffsetComponents = [[NSDateComponents alloc]init];
            [regularTimeOffsetComponents setHour:6];
            [regularTimeOffsetComponents setMinute:7];
            [regularTimeOffsetComponents setSecond:8];


            addedRegularTimeComponents = [[NSDateComponents alloc]init];
            [addedRegularTimeComponents setHour:7];
            [addedRegularTimeComponents setMinute:9];
            [addedRegularTimeComponents setSecond:11];

            addedBreakTimeComponents = [[NSDateComponents alloc]init];
            [addedBreakTimeComponents setHour:9];
            [addedBreakTimeComponents setMinute:11];
            [addedBreakTimeComponents setSecond:13];


            expectedWorkHours = [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:nil
                                                                  breakTimeOffsetComponents:nil
                                                                      regularTimeComponents:addedRegularTimeComponents
                                                                        breakTimeComponents:addedBreakTimeComponents
                                                                          timeOffComponents:nil
                                                                             dateComponents:dateComponents
                                                                             isScheduledDay:YES];



            durationCalculator stub_method(@selector(sumOfTimeByAddingDateComponents:toDateComponents:)).with(regularTimeOffsetComponents,regularTimeComponents).and_return(addedRegularTimeComponents);

            durationCalculator stub_method(@selector(sumOfTimeByAddingDateComponents:toDateComponents:)).with(breakTimeOffsetComponents,breakTimeComponents).and_return(addedBreakTimeComponents);

            workHours = [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:regularTimeOffsetComponents
                                                          breakTimeOffsetComponents:breakTimeOffsetComponents
                                                              regularTimeComponents:regularTimeComponents
                                                                breakTimeComponents:breakTimeComponents
                                                                  timeOffComponents:nil
                                                                     dateComponents:dateComponents
                                                                     isScheduledDay:YES];


        });

        context(@"When user session is valid", ^{
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(YES);
            });
            describe(@"should store <WorkHours>", ^{
                beforeEach(^{
                    [subject setupWithSummaryFilename:@"My-Special-File-hours" dateFileName:@"My-Special-File-date"];
                    [subject saveWorkHoursSummary:workHours];
                });

                it(@"should return the stored <WorkHours> with offset", ^{
                    id <WorkHours> workHoursWithOffset = [subject getCombinedWorkHoursSummary];
                    workHoursWithOffset.regularTimeComponents should equal(addedRegularTimeComponents);
                    workHoursWithOffset.breakTimeComponents should equal(addedBreakTimeComponents);
                    workHoursWithOffset.dateComponents should equal(dateComponents);
                    workHoursWithOffset.regularTimeOffsetComponents should be_nil;
                    workHoursWithOffset.breakTimeOffsetComponents should be_nil;
                    workHoursWithOffset.isScheduledDay should be_truthy;
                });

                it(@"should return the stored <WorkHours> without offset", ^{
                    id <WorkHours> workHoursWithoutOffset = [subject getWorkHoursSummary];
                    workHoursWithoutOffset.regularTimeComponents should equal(regularTimeComponents);
                    workHoursWithoutOffset.breakTimeComponents should equal(breakTimeComponents);
                    workHoursWithoutOffset.dateComponents should equal(dateComponents);
                    workHoursWithoutOffset.regularTimeOffsetComponents should equal(regularTimeOffsetComponents);
                    workHoursWithoutOffset.breakTimeOffsetComponents should equal(breakTimeOffsetComponents);
                    workHoursWithoutOffset.isScheduledDay should be_truthy;
                });

            });

            describe(@"should clear <WorkHours>", ^{
                beforeEach(^{
                    [subject setupWithSummaryFilename:@"My-Special-File" dateFileName:@"My-Special-File-date"];
                    [subject saveWorkHoursSummary:workHours];
                });
                it(@"should return the stored <WorkHours>", ^{
                    [subject getWorkHoursSummary] should equal(workHours);
                });

                it(@"should clear the stored <WorkHours>", ^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                    [subject getWorkHoursSummary] should be_nil;
                    [subject getCombinedWorkHoursSummary] should be_nil;

                });

            });

            describe(@"As a <DoorKeeperLogOutObserver>", ^{
                beforeEach(^{
                    [subject setupWithSummaryFilename:@"My-Special-File-hours" dateFileName:@"My-Special-File-date"];
                    [subject saveWorkHoursSummary:workHours];

                });

                it(@"should clear the stored <WorkHours>", ^{
                    [subject getWorkHoursSummary] should_not be_nil;
                });
                
                it(@"should clear the stored <WorkHours>", ^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                    [subject getWorkHoursSummary] should be_nil;
                    [subject getCombinedWorkHoursSummary] should be_nil;
                });
            });
        });

        context(@"When user session is not valid", ^{
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);
            });

            describe(@"should not store <WorkHours>", ^{
                beforeEach(^{
                    [subject setupWithSummaryFilename:@"My-Special-File-hours" dateFileName:@"My-Special-File-date"];
                    [subject saveWorkHoursSummary:workHours];
                });
                it(@"should return the stored <WorkHours>", ^{
                    [subject getWorkHoursSummary] should be_nil;
                    [subject getCombinedWorkHoursSummary] should be_nil;
                });

            });
        });



    });
    context(@"When storing and fetching summary on a different day", ^{
        beforeEach(^{

            userSession stub_method(@selector(validUserSession)).and_return(YES);
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1438260579];
            dateProvider stub_method(@selector(date)).and_return(date);
            NSDateComponents *regularTimeComponents = [[NSDateComponents alloc]init];
            [regularTimeComponents setHour:1];
            [regularTimeComponents setMinute:2];
            [regularTimeComponents setSecond:3];

            NSDateComponents *breakTimeComponents = [[NSDateComponents alloc]init];
            [breakTimeComponents setHour:3];
            [breakTimeComponents setMinute:4];
            [breakTimeComponents setSecond:5];

            NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setDay:29];
            [dateComponents setMonth:7];
            [dateComponents setYear:2015];

            NSDateComponents *breakTimeOffsetComponents = [[NSDateComponents alloc]init];
            [breakTimeOffsetComponents setHour:6];
            [breakTimeOffsetComponents setMinute:7];
            [breakTimeOffsetComponents setSecond:8];

            NSDateComponents *regularTimeOffsetComponents = [[NSDateComponents alloc]init];
            [regularTimeOffsetComponents setHour:6];
            [regularTimeOffsetComponents setMinute:7];
            [regularTimeOffsetComponents setSecond:8];

            workHours = [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:regularTimeOffsetComponents
                                                          breakTimeOffsetComponents:breakTimeOffsetComponents
                                                              regularTimeComponents:regularTimeComponents
                                                                breakTimeComponents:breakTimeComponents
                                                                  timeOffComponents:nil
                                                                     dateComponents:dateComponents
                                                                     isScheduledDay:YES];

            [subject setupWithSummaryFilename:@"My-Special-File-hours" dateFileName:@"My-Special-File-date"];
            [subject saveWorkHoursSummary:workHours];
        });


        it(@"should not return any stored <WorkHours>", ^{
            [subject getWorkHoursSummary] should be_nil;
            [subject getCombinedWorkHoursSummary] should be_nil;
        });
    });


});

SPEC_END
