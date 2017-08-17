#import "Cedar.h"
#import "WorkHoursController.h"
#import "DateProvider.h"
#import "KSDeferred.h"
#import "TimeSummaryRepository.h"
#import "Theme.h"
#import "TimeSummaryCell.h"
#import "WorkHoursPresenterProvider.h"
#import "WorkHoursPresenter.h"
#import "TimePeriodSummary.h"
#import "WorkHoursDeferred.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;


SPEC_BEGIN(WorkHoursControllerSpec)

describe(@"WorkHoursController", ^{
    __block WorkHoursController *subject;
    __block WorkHoursPresenterProvider <CedarDouble> *timeSummaryPresenterProvider;
    __block NSDateFormatter *dateFormatter;
    __block DateProvider *dateProvider;
    __block WorkHoursDeferred *workHoursDeferred;
    __block id<Theme> theme;

    beforeEach(^{
        timeSummaryPresenterProvider = nice_fake_for([WorkHoursPresenterProvider class]);

        WorkHoursPresenter *defaultPresenter = [[WorkHoursPresenter alloc] initWithTitle:@"Default Title"
                                                                                   value:@"Default Value"
                                                                               textColor:[UIColor purpleColor]];

        timeSummaryPresenterProvider stub_method(@selector(placeholderSummaryItemsWithOvertime:)).and_return(@[defaultPresenter]);

        WorkHoursPresenter *normalPresenter = [[WorkHoursPresenter alloc] initWithTitle:@"Normal Title"
                                                                                  value:@"Normal Value"
                                                                              textColor:[UIColor whiteColor]];

        timeSummaryPresenterProvider stub_method(@selector(summaryItemsWithWorkHours:regularHoursOffset:breakHoursOffset:includeOvertime:)).and_return(@[normalPresenter]);

        workHoursDeferred = [WorkHoursDeferred defer];

        dateFormatter = nice_fake_for([NSDateFormatter class]);
        dateProvider = nice_fake_for([DateProvider class]);
        theme = nice_fake_for(@protocol(Theme));

        subject = [[WorkHoursController alloc] initWithTimeSummaryPresenterProvider:timeSummaryPresenterProvider
                                                                   workHoursPromise:workHoursDeferred.promise
                                                                      timesheetMode:NO
                                                                      dateFormatter:dateFormatter
                                                                       dateProvider:dateProvider
                                                                              theme:theme];
    });

    it(@"should display the formatted date correctly on the label", ^{
        NSDate *date = nice_fake_for([NSDate class]);
        dateProvider stub_method(@selector(date)).and_return(date);
        dateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"my special date");
        [subject view];

        subject.dateLabel.text should equal(@"my special date");
    });

    describe(@"timesheet mode", ^{
        context(@"when not in timesheet mode", ^{
            beforeEach(^{
                subject = [[WorkHoursController alloc] initWithTimeSummaryPresenterProvider:timeSummaryPresenterProvider
                                                                           workHoursPromise:workHoursDeferred.promise
                                                                              timesheetMode:NO
                                                                              dateFormatter:dateFormatter
                                                                               dateProvider:dateProvider
                                                                                      theme:theme];
                [subject view];
            });

            it(@"should not remove the date label from the view hierarchy", ^{
                subject.dateLabel.superview should_not be_nil;
            });

            it(@"should not display overtime", ^{
                timeSummaryPresenterProvider should have_received(@selector(placeholderSummaryItemsWithOvertime:)).with(NO);
            });

            it(@"should not display overtime when the time summary promise resolves", ^{
                id<WorkHours> workHours = fake_for(@protocol(WorkHours));

                [workHoursDeferred resolveWithValue:workHours];

                timeSummaryPresenterProvider should have_received(@selector(summaryItemsWithWorkHours:regularHoursOffset:breakHoursOffset:includeOvertime:))
                    .with(workHours, anything, anything, NO);
            });
        });

        context(@"when in timesheet mode", ^{
            beforeEach(^{
                subject = [[WorkHoursController alloc] initWithTimeSummaryPresenterProvider:timeSummaryPresenterProvider
                                                                           workHoursPromise:workHoursDeferred.promise
                                                                              timesheetMode:YES
                                                                              dateFormatter:dateFormatter
                                                                               dateProvider:dateProvider
                                                                                      theme:theme];
                [subject view];
            });

            it(@"should remove the date label from the view hierarchy", ^{
                subject.dateLabel.superview should be_nil;
            });

            it(@"should display overtime", ^{
                timeSummaryPresenterProvider should have_received(@selector(placeholderSummaryItemsWithOvertime:)).with(YES);
            });

            it(@"should display overtime when the time summary promise resolves", ^{
                id<WorkHours> workHours = fake_for(@protocol(WorkHours));

                [workHoursDeferred resolveWithValue:workHours];

                timeSummaryPresenterProvider should have_received(@selector(summaryItemsWithWorkHours:regularHoursOffset:breakHoursOffset:includeOvertime:))
                    .with(workHours, anything, anything, YES);
            });
        });
    });

    describe(@"displaying a summary of the hours worked in the current day", ^{
        beforeEach(^{
            theme stub_method(@selector(timeCardSummaryRegularTimeTextFont)).and_return([UIFont systemFontOfSize:12.0f]);

            theme stub_method(@selector(timeCardSummaryTimeDescriptionTextColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(timeCardSummaryTimeDescriptionTextFont)).and_return([UIFont systemFontOfSize:14.0f]);

            [subject view];
            [subject.collectionView layoutIfNeeded];
        });

        it(@"should get the default presenters from the presenter provider", ^{
            timeSummaryPresenterProvider should have_received(@selector(placeholderSummaryItemsWithOvertime:));
        });

        it(@"should only display only one time summary", ^{
            [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(1);
        });

        it(@"should display a default time summary for regular hours worked today", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            TimeSummaryCell *cell = (id)[[subject.collectionView dataSource] collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.text should equal(@"Default Value");
            cell.valueLabel.textColor  should equal([UIColor purpleColor]);
        });

        it(@"should display the correct cell title for regular hours worked today ", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];

            [subject.collectionView.dataSource collectionView:subject.collectionView numberOfItemsInSection:0];
            TimeSummaryCell *cell = (id)[[subject.collectionView dataSource] collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.titleLabel.text should equal(@"Default Title");
        });

        it(@"should style the cells appropriately", ^{
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            TimeSummaryCell *cell = (id)[[subject.collectionView dataSource] collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
            cell.valueLabel.textColor should equal([UIColor purpleColor]);
            cell.valueLabel.font should equal([UIFont systemFontOfSize:12.0f]);

            cell.titleLabel.textColor should equal([UIColor redColor]);
            cell.titleLabel.font should equal([UIFont systemFontOfSize:14.0f]);
        });

        context(@"before the time summary returns", ^{
            __block NSDateComponents *regularHoursOffset;
            __block NSDateComponents *breakHoursOffset;

            beforeEach(^{
                regularHoursOffset = nice_fake_for([NSDateComponents class]);
                breakHoursOffset = nice_fake_for([NSDateComponents class]);

                [subject updateRegularHoursLabelWithOffset:regularHoursOffset];
                [subject updateBreakHoursLabelWithOffset:breakHoursOffset];

                [subject.collectionView layoutIfNeeded];

            });

            it(@"should not get any presenters from the presenter provider", ^{
                timeSummaryPresenterProvider should_not have_received(@selector(summaryItemsWithWorkHours:regularHoursOffset:breakHoursOffset:includeOvertime:));
            });
        });

        context(@"when the time summary returns", ^{
            __block id<WorkHours> workHours;
            __block NSDateComponents *regularHoursOffset;
            __block NSDateComponents *breakHoursOffset;

            beforeEach(^{
                regularHoursOffset = nice_fake_for([NSDateComponents class]);
                breakHoursOffset = nice_fake_for([NSDateComponents class]);

                [subject updateRegularHoursLabelWithOffset:regularHoursOffset];
                [subject updateBreakHoursLabelWithOffset:breakHoursOffset];

                workHours = fake_for(@protocol(WorkHours));

                [workHoursDeferred resolveWithValue:workHours];
                [subject.collectionView layoutIfNeeded];
            });

            it(@"should get the presenters from the presenter provider", ^{
                timeSummaryPresenterProvider should have_received(@selector(summaryItemsWithWorkHours:regularHoursOffset:breakHoursOffset:includeOvertime:))
                    .with(workHours, regularHoursOffset, breakHoursOffset, NO);
            });

            it(@"should display the correct number of summary cells", ^{
                [[subject.collectionView dataSource] collectionView:subject.collectionView numberOfItemsInSection:0] should equal(1);
            });

            it(@"should display the correct time summary for regular hours worked today from the repository", ^{
                NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                TimeSummaryCell *cell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:firstItemIndexPath];
                cell.valueLabel.text should equal(@"Normal Value");
                cell.titleLabel.text should equal(@"Normal Title");
                cell.valueLabel.textColor should equal([UIColor whiteColor]);
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(timeCardSummaryBackgroundColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(timeCardSummaryDateTextColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(timeCardSummaryDateTextFont)).and_return([UIFont systemFontOfSize:14.0f]);

            theme stub_method(@selector(timeCardSummaryTimeDescriptionTextColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(timeCardSummaryTimeDescriptionTextFont)).and_return([UIFont systemFontOfSize:14.0f]);


            [subject view];
            [subject viewWillAppear:YES];
        });

        it(@"should style the views", ^{
            subject.view.backgroundColor should equal([UIColor orangeColor]);
            subject.dateLabel.textColor should equal([UIColor redColor]);
            subject.dateLabel.font should equal([UIFont systemFontOfSize:14.0f]);
        });
    });
});

SPEC_END
