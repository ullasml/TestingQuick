#import <Cedar/Cedar.h>
#import "TeamTableStylist.h"
#import "TeamSectionHeaderView.h"
#import "Theme.h"
#import "UserSummaryCell.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamTableStylistSpec)

describe(NSStringFromClass([TeamTableStylist class]), ^{
    __block TeamTableStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TeamTableStylist alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(applyThemeToTeamTableView:)), ^{
        describe(@"styling the table", ^{
            __block UITableView *tableView;
            beforeEach(^{
                theme stub_method(@selector(userSummaryCellBackgroundColor)).and_return([UIColor blueColor]);

                tableView = [[UITableView alloc] init];
                [subject applyThemeToTeamTableView:tableView];
            });

            it(@"should set up a zero-frame footer with a background color from the theme", ^{
                 tableView.tableFooterView.frame should equal(CGRectZero);
                 tableView.backgroundColor should equal([UIColor blueColor]);
            });
        });
    });

    describe(NSStringFromSelector(@selector(applyThemeToSectionHeaderView:)), ^{
        describe(@"styling the header", ^{
            __block TeamSectionHeaderView *header;

            beforeEach(^{
                theme stub_method(@selector(teamTableViewSectionHeaderFont)).and_return([UIFont boldSystemFontOfSize:22]);
                theme stub_method(@selector(teamTableViewSectionHeaderTextColor)).and_return([UIColor purpleColor]);
                theme stub_method(@selector(teamTableViewSectionHeaderBackgroundColor)).and_return([UIColor greenColor]);

                header = [[TeamSectionHeaderView alloc] init];
                [subject applyThemeToSectionHeaderView:header];
            });

            it(@"should apply styling from the theme", ^{
                header.sectionTitleLabel.font should equal([UIFont boldSystemFontOfSize:22]);
                header.sectionTitleLabel.textColor should equal([UIColor purpleColor]);
                header.backgroundColor should equal([UIColor greenColor]);
            });
        });
    });

    describe(NSStringFromSelector(@selector(applyThemeToUserSummaryCell:)), ^{
        describe(@"styling the user cells", ^{
            __block UILabel *nameLabel;
            __block UILabel *detailsLabel;
            __block UILabel *hoursLabel;
            __block UserSummaryCell *userSummaryCell;

            beforeEach(^{
                nameLabel = nice_fake_for([UILabel class]);
                detailsLabel = nice_fake_for([UILabel class]);
                hoursLabel = nice_fake_for([UILabel class]);

                userSummaryCell = nice_fake_for([UserSummaryCell class]);

                userSummaryCell stub_method(@selector(nameLabel)).and_return(nameLabel);
                userSummaryCell stub_method(@selector(detailsLabel)).and_return(detailsLabel);
                userSummaryCell stub_method(@selector(hoursLabel)).and_return(hoursLabel);

                theme stub_method(@selector(userSummaryCellNameFont)).and_return([UIFont systemFontOfSize:8]);
                theme stub_method(@selector(userSummaryCellNameColor)).and_return([UIColor magentaColor]);
                theme stub_method(@selector(userSummaryCellDetailsFont)).and_return([UIFont systemFontOfSize:7]);
                theme stub_method(@selector(userSummaryCellDetailsColor)).and_return([UIColor greenColor]);
                theme stub_method(@selector(userSummaryCellHoursFont)).and_return([UIFont systemFontOfSize:6]);
                theme stub_method(@selector(userSummaryCellHoursColor)).and_return([UIColor yellowColor]);

                [subject applyThemeToUserSummaryCell:userSummaryCell];
            });

            it(@"should style the cell from the theme", ^{
                nameLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:8]);
                nameLabel should have_received(@selector(setTextColor:)).with([UIColor magentaColor]);
                detailsLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:7]);
                detailsLabel should have_received(@selector(setTextColor:)).with([UIColor greenColor]);
                hoursLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:6]);
                hoursLabel should have_received(@selector(setTextColor:)).with([UIColor yellowColor]);
            });

        });
    });
});

SPEC_END
