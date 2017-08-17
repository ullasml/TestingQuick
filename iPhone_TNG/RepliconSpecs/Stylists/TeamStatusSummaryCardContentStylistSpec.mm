#import <Cedar/Cedar.h>
#import "TeamStatusSummaryCardContentStylist.h"
#import "SupervisorDashboardTeamStatusSummaryCell.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamStatusSummaryCardContentStylistSpec)

describe(@"TeamStatusSummaryCardContentStylist", ^{
    __block TeamStatusSummaryCardContentStylist *subject;
    __block id<Theme> theme;
    __block UICollectionView *collectionView;

    beforeEach(^{
        collectionView = nice_fake_for([UICollectionView class]);
    });

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TeamStatusSummaryCardContentStylist alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(calculateItemSizeForStatusSummaryCollectionView:)), ^{
        beforeEach(^{

            CGRect frame = CGRectMake(0,0,302,200);
            collectionView stub_method(@selector(frame)).and_return(frame);
        });

        it(@"return the correct item size", ^{
            CGSize expectedSize = CGSizeMake(100, 54);
            CGSize returnedSize = [subject calculateItemSizeForStatusSummaryCollectionView:collectionView];

            returnedSize should equal(expectedSize);
        });
    });

    describe(NSStringFromSelector(@selector(applyThemeForInStatusToCell:)), ^{
        __block SupervisorDashboardTeamStatusSummaryCell *cell;
        __block UILabel *titleLabel;
        __block UILabel *valueLabel;
        beforeEach(^{
            cell = nice_fake_for([SupervisorDashboardTeamStatusSummaryCell class]);
            titleLabel = nice_fake_for([UILabel class]);
            valueLabel = nice_fake_for([UILabel class]);
            cell stub_method(@selector(titleLabel)).and_return(titleLabel);
            cell stub_method(@selector(valueLabel)).and_return(valueLabel);

            theme stub_method(@selector(teamStatusTitleFont)).and_return([UIFont systemFontOfSize:11]);
            theme stub_method(@selector(teamStatusValueFont)).and_return([UIFont systemFontOfSize:12]);
            theme stub_method(@selector(teamStatusInColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(teamStatusTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(userSummaryCellBackgroundColor)).and_return([UIColor purpleColor]);

            [subject applyThemeForInStatusToCell:cell];
        });

        it(@"should apply the correct theming to the cell", ^{
            titleLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:11]);
            titleLabel should have_received(@selector(setTextColor:)).with([UIColor redColor]);
            valueLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:12]);
            valueLabel should have_received(@selector(setTextColor:)).with([UIColor orangeColor]);
            cell should have_received(@selector(setBackgroundColor:)).with([UIColor purpleColor]);
        });
    });

    describe(NSStringFromSelector(@selector(applyThemeForOutStatusToCell:)), ^{
        __block SupervisorDashboardTeamStatusSummaryCell *cell;
        __block UILabel *titleLabel;
        __block UILabel *valueLabel;
        beforeEach(^{
            cell = nice_fake_for([SupervisorDashboardTeamStatusSummaryCell class]);
            titleLabel = nice_fake_for([UILabel class]);
            valueLabel = nice_fake_for([UILabel class]);
            cell stub_method(@selector(titleLabel)).and_return(titleLabel);
            cell stub_method(@selector(valueLabel)).and_return(valueLabel);

            theme stub_method(@selector(teamStatusTitleFont)).and_return([UIFont systemFontOfSize:11]);
            theme stub_method(@selector(teamStatusValueFont)).and_return([UIFont systemFontOfSize:12]);
            theme stub_method(@selector(teamStatusOutColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(teamStatusTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(userSummaryCellBackgroundColor)).and_return([UIColor purpleColor]);

            [subject applyThemeForOutStatusToCell:cell];
        });

        it(@"should apply the correct theming to the cell", ^{
            titleLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:11]);
            titleLabel should have_received(@selector(setTextColor:)).with([UIColor redColor]);
            valueLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:12]);
            valueLabel should have_received(@selector(setTextColor:)).with([UIColor orangeColor]);
            cell should have_received(@selector(setBackgroundColor:)).with([UIColor purpleColor]);
        });
    });

    describe(NSStringFromSelector(@selector(applyThemeForBreakStatusToCell:)), ^{
        __block SupervisorDashboardTeamStatusSummaryCell *cell;
        __block UILabel *titleLabel;
        __block UILabel *valueLabel;
        beforeEach(^{
            cell = nice_fake_for([SupervisorDashboardTeamStatusSummaryCell class]);
            titleLabel = nice_fake_for([UILabel class]);
            valueLabel = nice_fake_for([UILabel class]);
            cell stub_method(@selector(titleLabel)).and_return(titleLabel);
            cell stub_method(@selector(valueLabel)).and_return(valueLabel);

            theme stub_method(@selector(teamStatusTitleFont)).and_return([UIFont systemFontOfSize:11]);
            theme stub_method(@selector(teamStatusValueFont)).and_return([UIFont systemFontOfSize:12]);
            theme stub_method(@selector(teamStatusBreakColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(teamStatusTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(userSummaryCellBackgroundColor)).and_return([UIColor purpleColor]);

            [subject applyThemeForBreakStatusToCell:cell];
        });

        it(@"should apply the correct theming to the cell", ^{
            titleLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:11]);
            titleLabel should have_received(@selector(setTextColor:)).with([UIColor redColor]);
            valueLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:12]);
            valueLabel should have_received(@selector(setTextColor:)).with([UIColor orangeColor]);
            cell should have_received(@selector(setBackgroundColor:)).with([UIColor purpleColor]);
        });
    });

});

SPEC_END
