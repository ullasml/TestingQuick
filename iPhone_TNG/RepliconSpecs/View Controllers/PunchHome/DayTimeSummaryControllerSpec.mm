#import <Cedar/Cedar.h>
#import "DayTimeSummaryController.h"
#import <KSDeferred/KSDeferred.h>
#import "TimeSummaryRepository.h"
#import "Theme.h"
#import "DurationCollectionCell.h"
#import "WorkHoursPresenter.h"
#import "TimePeriodSummary.h"
#import "WorkHoursDeferred.h"
#import "UserPermissionsStorage.h"
#import "DayTimeSummary.h"
#import "TimeSummaryPresenter.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "TodaysDateControllerProvider.h"
#import "ChildControllerHelper.h"
#import "TodaysDateController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;


SPEC_BEGIN(DayTimeSummaryControllerSpec)

describe(@"DayTimeSummaryController", ^{
    __block DayTimeSummaryController *subject;
    __block WorkHoursDeferred *workHoursDeferred;
    __block id<Theme> theme;
    __block NSString *regularHoursTitle;
    __block NSString *breakHoursTitle;
    __block NSString *timeoffHoursTitle;
    __block TodaysDateControllerProvider *todaysDateControllerProvider;
    __block ChildControllerHelper *childControllerHelper;
    __block id <DayTimeSummaryUpdateDelegate> delegate;
    __block id <BSBinder,BSInjector> injector;
    __block TimeSummaryPresenter <CedarDouble>*timeSummaryPresenter;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        regularHoursTitle = RPLocalizedString(@"Work", @"Work");
        breakHoursTitle = RPLocalizedString(@"Break", @"Break");
        timeoffHoursTitle = RPLocalizedString(@"Time Off", @"Time Off");

    });
    
    beforeEach(^{
        delegate = nice_fake_for(@protocol(DayTimeSummaryUpdateDelegate));
        workHoursDeferred = [WorkHoursDeferred defer];
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        todaysDateControllerProvider = nice_fake_for([TodaysDateControllerProvider class]);
        [injector bind:[TodaysDateControllerProvider class] toInstance:todaysDateControllerProvider];
        
        childControllerHelper = nice_fake_for([ChildControllerHelper class]);
        [injector bind:[ChildControllerHelper class] toInstance:childControllerHelper];
        
        theme stub_method(@selector(timeCardSummaryBackgroundColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(timeCardSummaryRegularTimeTextFont)).and_return([UIFont systemFontOfSize:12.0f]);
        theme stub_method(@selector(timeCardSummaryTimeDescriptionTextColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(timeCardSummaryTimeDescriptionTextFont)).and_return([UIFont systemFontOfSize:14.0f]);
        subject = [injector getInstance:[DayTimeSummaryController class]];
        spy_on(subject.timeSummaryPresenter);
        
        timeSummaryPresenter = (id<CedarDouble>)subject.timeSummaryPresenter;
    });
    
    afterEach(^{
        stop_spying_on(subject.timeSummaryPresenter);
    });
    
    describe(@"When the view loads", ^{
        
        context(@"When there is break access", ^{
            
            
            beforeEach(^{
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES todaysDateContainerHeight:0.0];
                [subject view];
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"-");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"-");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
        });
        
        context(@"When there is no break access", ^{
            
            
            beforeEach(^{
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:NO
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                [subject view];
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(NO);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(1);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"-");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
            });
        });
        
        context(@"When there is no cached work hours", ^{
            
            beforeEach(^{
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                [subject view];
                [subject.collectionView layoutIfNeeded];
                
            });

            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"-");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"-");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);

            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                __block NSDateComponents *timeOffComponents;

                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:1];
                    [regularTimeComponents setMinute:2];
                    [regularTimeComponents setSecond:3];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:4];
                    [breakTimeComponents setSecond:5];
                    
                    timeOffComponents = [[NSDateComponents alloc]init];
                    [timeOffComponents setHour:0];
                    [timeOffComponents setMinute:0];
                    [timeOffComponents setSecond:0];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    workHours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);

                    [workHoursDeferred resolveWithValue:workHours];
                });
                
                it(@"should inform its delegate to update workhours", ^{
                    delegate should have_received(@selector(dayTimeSummaryController:didUpdateWorkHours:)).with(subject,workHours);
                });
                
                it(@"should reload the workhours collection view", ^{
                    [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
                });
                
                it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.text should equal(@"1h:02m");
                    regularCell.nameLabel.text should equal(regularHoursTitle);
                    regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                    DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                    breakCell.durationHoursLabel.text should equal(@"3h:04m");
                    breakCell.nameLabel.text should equal(breakHoursTitle);
                    breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                });

            });
        });
        
        context(@"When there are cached work hours", ^{
            __block id<WorkHours> cachedWorkHours;
            __block NSDateComponents *cachedRegularTimeComponents;
            __block NSDateComponents *cachedBreakTimeComponents;
            
            beforeEach(^{
                
                cachedWorkHours = nice_fake_for(@protocol(WorkHours));
                cachedRegularTimeComponents = [[NSDateComponents alloc]init];
                [cachedRegularTimeComponents setHour:1];
                [cachedRegularTimeComponents setMinute:2];
                [cachedRegularTimeComponents setSecond:3];
                
                cachedBreakTimeComponents = [[NSDateComponents alloc]init];
                [cachedBreakTimeComponents setHour:3];
                [cachedBreakTimeComponents setMinute:4];
                [cachedBreakTimeComponents setSecond:5];
                cachedWorkHours stub_method(@selector(regularTimeComponents)).and_return(cachedRegularTimeComponents);
                cachedWorkHours stub_method(@selector(breakTimeComponents)).and_return(cachedBreakTimeComponents);
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:cachedWorkHours
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                
                [subject view];
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"1h:02m");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"3h:04m");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                __block NSDateComponents *timeOffComponents;
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:1];
                    [regularTimeComponents setMinute:2];
                    [regularTimeComponents setSecond:3];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:4];
                    [breakTimeComponents setSecond:5];
                    
                    timeOffComponents = [[NSDateComponents alloc]init];
                    [timeOffComponents setHour:6];
                    [timeOffComponents setMinute:7];
                    [timeOffComponents setSecond:8];
                    workHours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    [workHoursDeferred resolveWithValue:workHours];
                    [subject.collectionView layoutIfNeeded];
                });
                
                it(@"should inform its delegate to update workhours", ^{
                    delegate should have_received(@selector(dayTimeSummaryController:didUpdateWorkHours:)).with(subject,workHours);
                });
                
                it(@"should reload the workhours collection view", ^{
                    [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(3);
                });
                
                it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.text should equal(@"1h:02m");
                    regularCell.nameLabel.text should equal(regularHoursTitle);
                    regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                    DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                    breakCell.durationHoursLabel.text should equal(@"3h:04m");
                    breakCell.nameLabel.text should equal(breakHoursTitle);
                    breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                    NSIndexPath *timeoffItemIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
                    DurationCollectionCell *timeoffCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:timeoffItemIndexPath];
                    timeoffCell.durationHoursLabel.text should equal(@"6h:07m");
                    timeoffCell.nameLabel.text should equal(timeoffHoursTitle);
                    timeoffCell.typeImageView.image should equal([UIImage imageNamed:@"icon_time_off"]);
                    
                });
                
            });
        });
        
        context(@"cell styling based on ScheduledDay", ^{
            context(@"isScheduledDay is true", ^{
                beforeEach(^{
                    
                    [subject setupWithDelegate:delegate
                          placeHolderWorkHours:nil
                              workHoursPromise:[workHoursDeferred promise]
                                hasBreakAccess:YES
                                isScheduledDay:YES
                     todaysDateContainerHeight:0.0];
                    [subject view];
                    [subject.collectionView layoutIfNeeded];
                    
                });
                it(@"should correctly style cells labels alpha ", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.alpha should equal(1.0);
                    regularCell.nameLabel.alpha  should equal(1.0);
                    regularCell.typeImageView.alpha  should equal(1.0);
                    
                    
                });
            });
            context(@"isScheduledDay is false", ^{
                beforeEach(^{
                    
                    [subject setupWithDelegate:delegate
                          placeHolderWorkHours:nil
                              workHoursPromise:[workHoursDeferred promise]
                                hasBreakAccess:YES
                                isScheduledDay:NO
                     todaysDateContainerHeight:0.0];
                    [subject view];
                    [subject.collectionView layoutIfNeeded];
                    
                });
                it(@"should correctly style cells labels alpha ", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.alpha should equal(CGFloat(0.55f));
                    regularCell.nameLabel.alpha  should equal(CGFloat(0.55f));
                    regularCell.typeImageView.alpha  should equal(CGFloat(0.55f));
                    
                });
            });
        });
        
        context(@"presenting today's date", ^{
            __block TodaysDateController *todaysDateController;
            beforeEach(^{
                todaysDateController = [[TodaysDateController alloc] initWithDateProvider:nil dateFormatter:nil theme:nil];
                spy_on(todaysDateController);
                todaysDateControllerProvider stub_method(@selector(provideInstance)).and_return(todaysDateController);
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:NO
                            isScheduledDay:YES todaysDateContainerHeight:10.0];
                [subject view];
            });
            afterEach(^{
                stop_spying_on(todaysDateController);
            });

            
            it(@"should present a todaysDateController", ^{
                childControllerHelper should have_received(@selector(addChildController:toParentController:inContainerView:)).with(todaysDateController, subject, subject.todaysDateContainer);
            });
            
            it(@"should style the background appropriately", ^{
                subject.todaysDateContainer.backgroundColor should equal([UIColor orangeColor]);
            });
            
            it(@"should setup TodaysDateController correctly", ^{
                todaysDateController should have_received(@selector(setUpWithScheduledDay:)).with(YES);
            });
            
            it(@"should have correct height todaysDateContainer", ^{
                subject.todaysDateHeightConstraint.constant should equal(CGFloat(10.0f));
            });
            
            it(@"should have correctly set todaysDateController", ^{
                subject.todaysDateController should be_same_instance_as(todaysDateController);
            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block TodaysDateController *newTodaysDateController;
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(nil);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(nil);
                    workHours stub_method(@selector(timeOffComponents)).and_return(nil);
                    workHours stub_method(@selector(isScheduledDay)).and_return(YES);
                    
                    newTodaysDateController = [[TodaysDateController alloc] initWithDateProvider:nil dateFormatter:nil theme:nil];
                    spy_on(newTodaysDateController);
                    todaysDateControllerProvider stub_method(@selector(provideInstance)).again().and_return(newTodaysDateController);
                    
                    [workHoursDeferred resolveWithValue:workHours];
                });
                afterEach(^{
                    stop_spying_on(newTodaysDateController);
                });
                
                it(@"should setup TodaysDateController correctly", ^{
                    newTodaysDateController should have_received(@selector(setUpWithScheduledDay:)).with(YES);
                });
                

                it(@"should have correctly set todaysDateController", ^{
                    subject.todaysDateController should be_same_instance_as(newTodaysDateController);
                });
                
                it(@"should present new todaysDateController", ^{
                    childControllerHelper should have_received(@selector(replaceOldChildController:withNewChildController:onParentController:onContainerView:)).with(todaysDateController, newTodaysDateController, subject, subject.todaysDateContainer);
                });
            });
            
        });
        
    });
    
    describe(@"updateRegularHoursLabelWithOffset:", ^{
        
        context(@"When there is no cached work hours", ^{
            
            beforeEach(^{
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                [subject view];
                
                NSDateComponents *regularOffsetComponents = [[NSDateComponents alloc]init];
                [regularOffsetComponents setHour:1];
                [regularOffsetComponents setMinute:2];
                [regularOffsetComponents setSecond:3];
                
                [subject updateRegularHoursLabelWithOffset:regularOffsetComponents];
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"-");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"-");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:11];
                    [regularTimeComponents setMinute:22];
                    [regularTimeComponents setSecond:33];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:4];
                    [breakTimeComponents setSecond:5];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    [workHoursDeferred resolveWithValue:workHours];
                });
                
                it(@"should reload the workhours collection view", ^{
                    [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
                });
                
                it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.text should equal(@"12h:24m");
                    regularCell.nameLabel.text should equal(regularHoursTitle);
                    regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                    DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                    breakCell.durationHoursLabel.text should equal(@"3h:04m");
                    breakCell.nameLabel.text should equal(breakHoursTitle);
                    breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                });
                
            });
        });
        
        context(@"When there are cached work hours", ^{
            __block id<WorkHours> cachedWorkHours;
            __block NSDateComponents *cachedRegularTimeComponents;
            __block NSDateComponents *cachedBreakTimeComponents;
            
            beforeEach(^{
                
                cachedWorkHours = nice_fake_for(@protocol(WorkHours));
                cachedRegularTimeComponents = [[NSDateComponents alloc]init];
                [cachedRegularTimeComponents setHour:11];
                [cachedRegularTimeComponents setMinute:22];
                [cachedRegularTimeComponents setSecond:33];
                
                cachedBreakTimeComponents = [[NSDateComponents alloc]init];
                [cachedBreakTimeComponents setHour:3];
                [cachedBreakTimeComponents setMinute:4];
                [cachedBreakTimeComponents setSecond:5];
                cachedWorkHours stub_method(@selector(regularTimeComponents)).and_return(cachedRegularTimeComponents);
                cachedWorkHours stub_method(@selector(breakTimeComponents)).and_return(cachedBreakTimeComponents);
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:cachedWorkHours
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                
                [subject view];
                
                NSDateComponents *regularOffsetComponents = [[NSDateComponents alloc]init];
                [regularOffsetComponents setHour:1];
                [regularOffsetComponents setMinute:2];
                [regularOffsetComponents setSecond:3];
                
                [subject updateRegularHoursLabelWithOffset:regularOffsetComponents];
                
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"12h:24m");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"3h:04m");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:1];
                    [regularTimeComponents setMinute:2];
                    [regularTimeComponents setSecond:3];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:4];
                    [breakTimeComponents setSecond:5];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    [workHoursDeferred resolveWithValue:workHours];
                    [subject.collectionView layoutIfNeeded];
                });
                
                it(@"should reload the workhours collection view", ^{
                    [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
                });
                
                it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.text should equal(@"2h:04m");
                    regularCell.nameLabel.text should equal(regularHoursTitle);
                    regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                    DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                    breakCell.durationHoursLabel.text should equal(@"3h:04m");
                    breakCell.nameLabel.text should equal(breakHoursTitle);
                    breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                });
                
            });
        });

    
    });
    
    describe(@"updateBreakHoursLabelWithOffset:", ^{
        
        context(@"When there is no cached work hours", ^{
            
            beforeEach(^{
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                [subject view];
                
                NSDateComponents *breakOffsetComponents = [[NSDateComponents alloc]init];
                [breakOffsetComponents setHour:1];
                [breakOffsetComponents setMinute:2];
                [breakOffsetComponents setSecond:3];
                
                [subject updateBreakHoursLabelWithOffset:breakOffsetComponents];
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"-");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"-");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:11];
                    [regularTimeComponents setMinute:22];
                    [regularTimeComponents setSecond:33];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:14];
                    [breakTimeComponents setSecond:5];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    [workHoursDeferred resolveWithValue:workHours];
                });
                
                it(@"should reload the workhours collection view", ^{
                    [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
                });
                
                it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.text should equal(@"11h:22m");
                    regularCell.nameLabel.text should equal(regularHoursTitle);
                    regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                    DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                    breakCell.durationHoursLabel.text should equal(@"4h:16m");
                    breakCell.nameLabel.text should equal(breakHoursTitle);
                    breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                });
                
            });
        });
        
        context(@"When there are cached work hours", ^{
            __block id<WorkHours> cachedWorkHours;
            __block NSDateComponents *cachedRegularTimeComponents;
            __block NSDateComponents *cachedBreakTimeComponents;
            
            beforeEach(^{
                
                cachedWorkHours = nice_fake_for(@protocol(WorkHours));
                cachedRegularTimeComponents = [[NSDateComponents alloc]init];
                [cachedRegularTimeComponents setHour:1];
                [cachedRegularTimeComponents setMinute:2];
                [cachedRegularTimeComponents setSecond:3];
                
                cachedBreakTimeComponents = [[NSDateComponents alloc]init];
                [cachedBreakTimeComponents setHour:3];
                [cachedBreakTimeComponents setMinute:4];
                [cachedBreakTimeComponents setSecond:5];
                cachedWorkHours stub_method(@selector(regularTimeComponents)).and_return(cachedRegularTimeComponents);
                cachedWorkHours stub_method(@selector(breakTimeComponents)).and_return(cachedBreakTimeComponents);
                
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:cachedWorkHours
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                
                [subject view];
                
                NSDateComponents *breakOffsetComponents = [[NSDateComponents alloc]init];
                [breakOffsetComponents setHour:1];
                [breakOffsetComponents setMinute:2];
                [breakOffsetComponents setSecond:3];
                
                [subject updateBreakHoursLabelWithOffset:breakOffsetComponents];
                
                [subject.collectionView layoutIfNeeded];
                
            });
            
            it(@"should correctly set up TimeSummaryPresenter", ^{
                timeSummaryPresenter should have_received(@selector(setUpWithBreakPermission:)).with(YES);
            });
            
            it(@"should reload the workhours collection view", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
            });
            
            it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                
                NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                regularCell.durationHoursLabel.text should equal(@"1h:02m");
                regularCell.nameLabel.text should equal(RPLocalizedString(@"Work", @"Work"));
                regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                
                NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                breakCell.durationHoursLabel.text should equal(@"4h:06m");
                breakCell.nameLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                
            });
            
            context(@"when the time summary promise resolves", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:11];
                    [regularTimeComponents setMinute:22];
                    [regularTimeComponents setSecond:33];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:14];
                    [breakTimeComponents setSecond:15];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    [workHoursDeferred resolveWithValue:workHours];
                    [subject.collectionView layoutIfNeeded];
                });
                
                it(@"should reload the workhours collection view", ^{
                    [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(2);
                });
                
                it(@"should correctly calculate work hours from cached hours and regular offset", ^{
                    
                    NSIndexPath *regularItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                    DurationCollectionCell *regularCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:regularItemIndexPath];
                    regularCell.durationHoursLabel.text should equal(@"11h:22m");
                    regularCell.nameLabel.text should equal(regularHoursTitle);
                    regularCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
                    
                    NSIndexPath *breakItemIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                    DurationCollectionCell *breakCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:breakItemIndexPath];
                    breakCell.durationHoursLabel.text should equal(@"4h:16m");
                    breakCell.nameLabel.text should equal(breakHoursTitle);
                    breakCell.typeImageView.image should equal([UIImage imageNamed:@"icon_timeline_break"]);
                    
                });
                
            });
        });
    });
    
    describe(@"UICollectionViewLayoutDelegate:", ^{
        context(@"sizeForItemAtIndexPath:", ^{
            beforeEach(^{
                [subject setupWithDelegate:delegate
                      placeHolderWorkHours:nil
                          workHoursPromise:[workHoursDeferred promise]
                            hasBreakAccess:YES
                            isScheduledDay:YES
                 todaysDateContainerHeight:0.0];
                [subject view];
                [subject.collectionView layoutIfNeeded];
                
            });

            context(@"when regualar time and break available", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                __block NSDateComponents *timeOffComponents;
                
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:1];
                    [regularTimeComponents setMinute:2];
                    [regularTimeComponents setSecond:3];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:4];
                    [breakTimeComponents setSecond:5];
                    
                    timeOffComponents = [[NSDateComponents alloc]init];
                    [timeOffComponents setHour:0];
                    [timeOffComponents setMinute:0];
                    [timeOffComponents setSecond:0];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    workHours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);
                    
                    [workHoursDeferred resolveWithValue:workHours];
                });
                
                it(@"should retuen expected cell size", ^{
                    CGSize expectedCellSize = CGSizeMake(subject.view.frame.size.width/2, 65);
                    CGSize cellSize =  [subject collectionView:subject.collectionView layout:subject.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellSize should equal(expectedCellSize);
                });
            });
            
            context(@"when regualar time, break and timeoff available", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *breakTimeComponents;
                __block NSDateComponents *timeOffComponents;
                
                beforeEach(^{
                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:1];
                    [regularTimeComponents setMinute:2];
                    [regularTimeComponents setSecond:3];
                    
                    breakTimeComponents = [[NSDateComponents alloc]init];
                    [breakTimeComponents setHour:3];
                    [breakTimeComponents setMinute:4];
                    [breakTimeComponents setSecond:5];
                    
                    timeOffComponents = [[NSDateComponents alloc]init];
                    [timeOffComponents setHour:1];
                    [timeOffComponents setMinute:0];
                    [timeOffComponents setSecond:0];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(breakTimeComponents)).and_return(breakTimeComponents);
                    workHours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);
                    
                    [workHoursDeferred resolveWithValue:workHours];
                });
                
                it(@"should retuen expected cell size", ^{
                    CGSize expectedCellSize = CGSizeMake(subject.view.frame.size.width/3, 65);
                    CGSize cellSize =  [subject collectionView:subject.collectionView layout:subject.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellSize should equal(expectedCellSize);
                });
            });
            
            context(@"when only regualar time", ^{
                __block id<WorkHours> workHours;
                __block NSDateComponents *regularTimeComponents;
                __block NSDateComponents *timeOffComponents;
                
                beforeEach(^{
                    [subject setupWithDelegate:delegate
                          placeHolderWorkHours:nil
                              workHoursPromise:[workHoursDeferred promise]
                                hasBreakAccess:NO
                                isScheduledDay:YES
                     todaysDateContainerHeight:0.0];

                    workHours = nice_fake_for(@protocol(WorkHours));
                    regularTimeComponents = [[NSDateComponents alloc]init];
                    [regularTimeComponents setHour:1];
                    [regularTimeComponents setMinute:2];
                    [regularTimeComponents setSecond:3];
                    
                    timeOffComponents = [[NSDateComponents alloc]init];
                    [timeOffComponents setHour:0];
                    [timeOffComponents setMinute:0];
                    [timeOffComponents setSecond:0];
                    
                    workHours stub_method(@selector(regularTimeComponents)).and_return(regularTimeComponents);
                    workHours stub_method(@selector(timeOffComponents)).and_return(timeOffComponents);
                    
                    [workHoursDeferred resolveWithValue:workHours];
                });
                
                it(@"should retuen expected cell size", ^{
                    CGSize expectedCellSize = CGSizeMake(subject.view.frame.size.width, 65);
                    CGSize cellSize =  [subject collectionView:subject.collectionView layout:subject.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cellSize should equal(expectedCellSize);
                });
            });
        });
        context(@"insetForSectionAtIndex:", ^{
            it(@"should retuen expected sectionInsets", ^{
                UIEdgeInsets expectedSectionInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                UIEdgeInsets sectionInsets =  [subject collectionView:subject.collectionView layout:subject.collectionView.collectionViewLayout insetForSectionAtIndex:0];
                sectionInsets should equal(expectedSectionInsets);
            });
        });
        
        context(@"minimumLineSpacingForSectionAtIndex:", ^{
            it(@"should retuen expected minimumLineSpacing", ^{
                CGFloat expectedMinimumLineSpacing = 0;
                CGFloat minimumLineSpacing =  [subject collectionView:subject.collectionView layout:subject.collectionView.collectionViewLayout minimumLineSpacingForSectionAtIndex:0];
                minimumLineSpacing should equal(expectedMinimumLineSpacing);
            });
        });
    });
});

SPEC_END

