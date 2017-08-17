#import <Cedar/Cedar.h>
#import "WorkHoursPresenter.h"
#import "Theme.h"
#import "DurationCalculator.h"
#import "WorkHours.h"
#import "TimeSummaryPresenter.h"
#import "InjectorKeys.h"
#import "InjectorProvider.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimeSummaryPresenterSpec)

describe(@"TimeSummaryPresenter", ^{

    __block TimeSummaryPresenter *subject;
    __block id<Theme>theme;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        
        injector = [InjectorProvider injector];
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        theme stub_method(@selector(workTimeDurationColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(breakTimeDurationColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(timeOffTimeDurationColor)).and_return([UIColor orangeColor]);

        subject = [injector getInstance:[TimeSummaryPresenter class]];
        
    });
    
    context(@"-placeholderSummaryItemsWithoutTimeOffHours", ^{
        context(@"when user has break access", ^{
            __block NSArray *placeHolderItems;
            __block WorkHoursPresenter *expectedRegularHoursPresenter;
            __block WorkHoursPresenter *expectedBreakHoursPresenter;
            
            beforeEach(^{
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"-"];
                expectedBreakHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Break", @"Break")
                                                                              textColor:[UIColor redColor]
                                                                                  image:@"icon_timeline_break"
                                                                                  value:@"-"];
                [subject setUpWithBreakPermission:YES];
                placeHolderItems = [subject placeholderSummaryItemsWithoutTimeOffHours];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(2);
                placeHolderItems.firstObject should equal(expectedRegularHoursPresenter);
                placeHolderItems.lastObject should equal(expectedBreakHoursPresenter);
                
            });
            
        });

        context(@"when user does not have break access", ^{
            __block NSArray *placeHolderItems;
            __block WorkHoursPresenter *expectedRegularHoursPresenter;
            [subject setUpWithBreakPermission:NO];
            
            beforeEach(^{
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"-"];
                placeHolderItems = [subject placeholderSummaryItemsWithoutTimeOffHours];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(1);
                placeHolderItems.firstObject should equal(expectedRegularHoursPresenter);
                
            });
            
        });

    });
    
    context(@"-summaryItemsWithWorkHours:regularHoursOffset:breakHoursOffset:", ^{
        __block id <WorkHours> workhours;
        __block NSDateComponents *regularTimeComponents;
        __block NSDateComponents *breakTimeComponents;
        __block NSDateComponents *timeOffComponents;
        __block WorkHoursPresenter *expectedRegularHoursPresenter;
        __block WorkHoursPresenter *expectedBreakHoursPresenter;
        __block WorkHoursPresenter *expectedTimeoffHoursPresenter;
        __block NSArray *placeHolderItems;
        
        beforeEach(^{
            workhours = nice_fake_for(@protocol(WorkHours));
            
            regularTimeComponents = [[NSDateComponents alloc]init];
            regularTimeComponents.hour = 1;
            regularTimeComponents.minute = 2;
            regularTimeComponents.second = 3;
            
            breakTimeComponents = [[NSDateComponents alloc]init];
            breakTimeComponents.hour = 4;
            breakTimeComponents.minute = 5;
            breakTimeComponents.second = 6;
            
            timeOffComponents = [[NSDateComponents alloc]init];
            timeOffComponents.hour = 7;
            timeOffComponents.minute = 8;
            timeOffComponents.second = 9;

            workhours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
            workhours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);

        });
        
        context(@"when offset is not present", ^{
            
            context(@"when user has break access and with no break hours", ^{
                beforeEach(^{
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    breakTimeComponents.hour = 0;
                    breakTimeComponents.minute = 0;
                    breakTimeComponents.second = 0;
                    
                    workhours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                    textColor:[UIColor greenColor]
                                                                                        image:@"icon_timeline_clock_in"
                                                                                        value:@"1h:02m"];
                    expectedBreakHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Break", @"Break")
                                                                                  textColor:[UIColor redColor]
                                                                                      image:@"icon_timeline_break"
                                                                                      value:@"0h:00m"];
                    expectedTimeoffHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Time Off", @"Time Off")
                                                                                    textColor:[UIColor orangeColor]
                                                                                        image:@"icon_time_off"
                                                                                        value:@"7h:08m"];
                    [subject setUpWithBreakPermission:YES];
                    placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:nil breakHoursOffset:nil];
                });
                
                it(@"should corrcetly return the work hours items only", ^{
                    placeHolderItems.count should equal(3);
                    placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                    placeHolderItems[1] should equal(expectedBreakHoursPresenter);
                    placeHolderItems[2] should equal(expectedTimeoffHoursPresenter);
                });
            });

            context(@"when user doen not break access and with no break hours", ^{
                beforeEach(^{
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    breakTimeComponents.hour = 0;
                    breakTimeComponents.minute = 0;
                    breakTimeComponents.second = 0;
                    
                    workhours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                    textColor:[UIColor greenColor]
                                                                                        image:@"icon_timeline_clock_in"
                                                                                        value:@"1h:02m"];
                    expectedTimeoffHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Time Off", @"Time Off")
                                                                                    textColor:[UIColor orangeColor]
                                                                                        image:@"icon_time_off"
                                                                                        value:@"7h:08m"];
                    [subject setUpWithBreakPermission:NO];
                    placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:nil breakHoursOffset:nil];
                });
                
                it(@"should corrcetly return the work hours items only", ^{
                    placeHolderItems.count should equal(2);
                    placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                    placeHolderItems[1] should equal(expectedTimeoffHoursPresenter);
                });
            });

            
            context(@"when user does not have break access but have breakcomponents to show", ^{
                beforeEach(^{
                    
                    workhours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                    textColor:[UIColor greenColor]
                                                                                        image:@"icon_timeline_clock_in"
                                                                                        value:@"1h:02m"];
                    
                    expectedBreakHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Break", @"Break")
                                                                                  textColor:[UIColor redColor]
                                                                                      image:@"icon_timeline_break"
                                                                                      value:@"4h:05m"];

                    expectedTimeoffHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Time Off", @"Time Off")
                                                                                    textColor:[UIColor orangeColor]
                                                                                        image:@"icon_time_off"
                                                                                        value:@"7h:08m"];

                    [subject setUpWithBreakPermission:NO];
                    placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:nil breakHoursOffset:nil];
                });
                
                it(@"should corrcetly return the work hours items only", ^{
                    placeHolderItems.count should equal(3);
                    placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                    placeHolderItems[1] should equal(expectedBreakHoursPresenter);
                    placeHolderItems[2] should equal(expectedTimeoffHoursPresenter);
                });
            });
        });
        
        context(@"when offset is present", ^{
            
            __block NSDateComponents *regularTimeOffsetComponents;
            __block NSDateComponents *breakTimeOffsetComponents;
            
            beforeEach(^{
                
                regularTimeOffsetComponents = [[NSDateComponents alloc]init];
                regularTimeOffsetComponents.hour = 4;
                regularTimeOffsetComponents.minute = 5;
                regularTimeOffsetComponents.second = 6;
                
                breakTimeOffsetComponents = [[NSDateComponents alloc]init];
                breakTimeOffsetComponents.hour = 7;
                breakTimeOffsetComponents.minute = 8;
                breakTimeOffsetComponents.second = 9;
                
                breakTimeComponents = [[NSDateComponents alloc]init];
                breakTimeComponents.hour = 4;
                breakTimeComponents.minute = 5;
                breakTimeComponents.second = 6;

                workhours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"5h:07m"];
                expectedBreakHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Break", @"Break")
                                                                              textColor:[UIColor redColor]
                                                                                  image:@"icon_timeline_break"
                                                                                  value:@"11h:13m"];
                expectedTimeoffHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Time Off", @"Time Off")
                                                                                textColor:[UIColor orangeColor]
                                                                                    image:@"icon_time_off"
                                                                                    value:@"7h:08m"];
                [subject setUpWithBreakPermission:YES];
                placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:regularTimeOffsetComponents breakHoursOffset:breakTimeOffsetComponents];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(3);
                placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                placeHolderItems[1] should equal(expectedBreakHoursPresenter);
                placeHolderItems[2] should equal(expectedTimeoffHoursPresenter);
            });
        });
        
        context(@"when timeoff is not present", ^{
            beforeEach(^{
                breakTimeComponents = [[NSDateComponents alloc]init];
                breakTimeComponents.hour = 4;
                breakTimeComponents.minute = 5;
                breakTimeComponents.second = 6;
                
                workhours stub_method(@selector(timeOffComponents)).again().and_return(nil);
                workhours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                
                
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"1h:02m"];
                expectedBreakHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Break", @"Break")
                                                                              textColor:[UIColor redColor]
                                                                                  image:@"icon_timeline_break"
                                                                                  value:@"4h:05m"];
                [subject setUpWithBreakPermission:YES];
                placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:nil breakHoursOffset:nil];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(2);
                placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                placeHolderItems[1] should equal(expectedBreakHoursPresenter);
                
            });
        });
    });
    
    context(@"-summaryItemsWithWorkHours:regularHoursOffset:", ^{
        __block id <WorkHours> workhours;
        __block NSDateComponents *regularTimeComponents;
        __block NSDateComponents *timeOffComponents;
        __block WorkHoursPresenter *expectedRegularHoursPresenter;
        __block WorkHoursPresenter *expectedTimeoffHoursPresenter;
        __block NSArray *placeHolderItems;
        
        beforeEach(^{
            workhours = nice_fake_for(@protocol(WorkHours));
            
            regularTimeComponents = [[NSDateComponents alloc]init];
            regularTimeComponents.hour = 1;
            regularTimeComponents.minute = 2;
            regularTimeComponents.second = 3;
            
            timeOffComponents = [[NSDateComponents alloc]init];
            timeOffComponents.hour = 7;
            timeOffComponents.minute = 8;
            timeOffComponents.second = 9;
            
            workhours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
            workhours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);
            
            
        });
        
        context(@"when offset is not present", ^{
            beforeEach(^{
                
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"1h:02m"];
                expectedTimeoffHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Time Off", @"Time Off")
                                                                                textColor:[UIColor orangeColor]
                                                                                    image:@"icon_time_off"
                                                                                    value:@"7h:08m"];
                
                placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:nil];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(2);
                placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                placeHolderItems[1] should equal(expectedTimeoffHoursPresenter);
            });
        });
        
        context(@"when offset is present", ^{
            
            __block NSDateComponents *regularTimeOffsetComponents;
            
            beforeEach(^{
                
                regularTimeOffsetComponents = [[NSDateComponents alloc]init];
                regularTimeOffsetComponents.hour = 4;
                regularTimeOffsetComponents.minute = 5;
                regularTimeOffsetComponents.second = 6;
                
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"5h:07m"];
                expectedTimeoffHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Time Off", @"Time Off")
                                                                                textColor:[UIColor orangeColor]
                                                                                    image:@"icon_time_off"
                                                                                    value:@"7h:08m"];
                
                placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:regularTimeOffsetComponents];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(2);
                placeHolderItems[0] should equal(expectedRegularHoursPresenter);
                placeHolderItems[1] should equal(expectedTimeoffHoursPresenter);
                
            });
        });
        
        context(@"when timeoff is not present", ^{
            beforeEach(^{
                
                workhours stub_method(@selector(timeOffComponents)).again().and_return(nil);
                
                expectedRegularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[UIColor greenColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"1h:02m"];
                
                placeHolderItems = [subject summaryItemsWithWorkHours:workhours regularHoursOffset:nil];
            });
            
            it(@"should corrcetly return the work hours items only", ^{
                placeHolderItems.count should equal(1);
                placeHolderItems[0] should equal(expectedRegularHoursPresenter);
            });
        });
    });
});

SPEC_END
