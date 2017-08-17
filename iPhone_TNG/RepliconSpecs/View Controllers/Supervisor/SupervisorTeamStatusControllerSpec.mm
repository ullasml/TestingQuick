#import <Cedar/Cedar.h>
#import "SupervisorDashboardTeamStatusSummaryCell.h"
#import "TeamStatusSummaryCardContentStylist.h"
#import "TeamStatusSummaryControllerProvider.h"
#import "SupervisorTeamStatusController.h"
#import "TeamStatusSummaryRepository.h"
#import "SupervisorDashboardSummary.h"
#import "UICollectionViewCell+Spec.h"
#import <KSDeferred/KSDeferred.h>
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SupervisorTeamStatusControllerSpec)

describe(@"SupervisorTeamStatusController", ^{
    __block SupervisorTeamStatusController *subject;
    __block TeamStatusSummaryCardContentStylist *teamStatusSummaryCardContentStylist;
    __block TeamStatusSummaryControllerProvider *teamStatusSummaryControllerProvider;
    __block TeamStatusSummaryRepository *teamStatusSummaryRepository;
    __block UIViewController *teamStatusSummaryController;
    __block UINavigationController *navigationController;
    __block KSDeferred *teamStatusSummaryDeferred;
    __block id<Theme> theme;

    beforeEach(^{
        teamStatusSummaryCardContentStylist = nice_fake_for([TeamStatusSummaryCardContentStylist class]);

        teamStatusSummaryControllerProvider = nice_fake_for([TeamStatusSummaryControllerProvider class]);

        teamStatusSummaryRepository = nice_fake_for([TeamStatusSummaryRepository class]);

        theme = nice_fake_for(@protocol(Theme));

        teamStatusSummaryController = [[UIViewController alloc] init];

        teamStatusSummaryDeferred = [KSDeferred defer];
        teamStatusSummaryRepository stub_method(@selector(fetchTeamStatusSummary)).and_return(teamStatusSummaryDeferred.promise);
        teamStatusSummaryControllerProvider stub_method(@selector(provideInstanceWithTeamStatusSummaryPromise:initiallyDisplayedSection:)).and_return(teamStatusSummaryController);

        subject = [[SupervisorTeamStatusController alloc] initWithTeamStatusSummaryCardContentStylist:teamStatusSummaryCardContentStylist
                                                                  teamStatusSummaryControllerProvider:teamStatusSummaryControllerProvider
                                                                          teamStatusSummaryRepository:teamStatusSummaryRepository
                                                                                                theme:theme];

        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
    });

    describe(@"team status", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];
        });

        context(@"when the view is first loaded", ^{
            it(@"should display 3 cells in 1 section", ^{
                [subject.collectionView numberOfSections] should equal(1);
                [subject.collectionView numberOfItemsInSection:0] should equal(3);
            });

            it(@"should initially show dashes for values", ^{
                SupervisorDashboardTeamStatusSummaryCell *inStatusCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                inStatusCell should be_instance_of([SupervisorDashboardTeamStatusSummaryCell class]);
                inStatusCell.titleLabel.text should equal(RPLocalizedString(@"In", @"In"));
                inStatusCell.valueLabel.text should equal(@"-");

                SupervisorDashboardTeamStatusSummaryCell *outStatusCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                outStatusCell should be_instance_of([SupervisorDashboardTeamStatusSummaryCell class]);
                outStatusCell.titleLabel.text should equal(RPLocalizedString(@"Not In", @"Not In"));
                outStatusCell.valueLabel.text should equal(@"-");

                SupervisorDashboardTeamStatusSummaryCell *breakStatusCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                breakStatusCell should be_instance_of([SupervisorDashboardTeamStatusSummaryCell class]);
                breakStatusCell.titleLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakStatusCell.valueLabel.text should equal(@"-");
            });
        });

        context(@"when updated with the most recent dashboard summary", ^{
            beforeEach(^{
                SupervisorDashboardSummary *dashboardSummary = nice_fake_for([SupervisorDashboardSummary class]);

                dashboardSummary stub_method(@selector(clockedInUsersCount)).and_return((NSInteger) 1);
                dashboardSummary stub_method(@selector(notInUsersCount)).and_return((NSInteger) 3);
                dashboardSummary stub_method(@selector(onBreakUsersCount)).and_return((NSInteger) 7);

                [subject updateWithDashboardSummary:dashboardSummary];
            });

            it(@"should update the summary with the values", ^{
                SupervisorDashboardTeamStatusSummaryCell *inStatusCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                inStatusCell should be_instance_of([SupervisorDashboardTeamStatusSummaryCell class]);
                inStatusCell.titleLabel.text should equal(RPLocalizedString(@"In", @"In"));
                inStatusCell.valueLabel.text should equal(@"1");

                SupervisorDashboardTeamStatusSummaryCell *outStatusCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                outStatusCell should be_instance_of([SupervisorDashboardTeamStatusSummaryCell class]);
                outStatusCell.titleLabel.text should equal(RPLocalizedString(@"Not In", @"Not In"));
                outStatusCell.valueLabel.text should equal(@"3");

                SupervisorDashboardTeamStatusSummaryCell *breakStatusCell = (id)[subject.collectionView.dataSource collectionView:subject.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                breakStatusCell should be_instance_of([SupervisorDashboardTeamStatusSummaryCell class]);
                breakStatusCell.titleLabel.text should equal(RPLocalizedString(@"Break", @"Break"));
                breakStatusCell.valueLabel.text should equal(@"7");
            });
        });

        describe(@"tapping on the 'in' cell", ^{

            context(@"before fetching the most recent team status", ^{
                beforeEach(^{
                    [subject.collectionView.delegate collectionView:subject.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should not push anything on the nav stack", ^{
                    navigationController.topViewController should be_same_instance_as(subject);
                });
            });

            context(@"after fetching the most recent team status", ^{
                beforeEach(^{
                    [subject updateWithDashboardSummary:nil];
                    [subject.collectionView.delegate collectionView:subject.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                });

                it(@"should push a team status summary controller onto the navigation stack, passing in the team summary request promise", ^{
                    teamStatusSummaryControllerProvider should have_received(@selector(provideInstanceWithTeamStatusSummaryPromise:initiallyDisplayedSection:)).with(teamStatusSummaryDeferred.promise, TeamStatusTableSectionClockedIn);
                    navigationController.topViewController should be_same_instance_as(teamStatusSummaryController);
                });
            });
        });

        describe(@"tapping on the 'out' cell", ^{

            context(@"before fetching the most recent team status", ^{
                beforeEach(^{
                    [subject.collectionView.delegate collectionView:subject.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });

                it(@"should not push anything on the nav stack", ^{
                    navigationController.topViewController should be_same_instance_as(subject);
                });
            });

            context(@"after fetching the most recent team status", ^{
                beforeEach(^{
                    [subject updateWithDashboardSummary:nil];
                    [subject.collectionView.delegate collectionView:subject.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                });

                it(@"should push a team status summary controller onto the navigation stack, passing in the team summary request promise", ^{
                    teamStatusSummaryControllerProvider should have_received(@selector(provideInstanceWithTeamStatusSummaryPromise:initiallyDisplayedSection:)).with(teamStatusSummaryDeferred.promise, TeamStatusTableSectionNotIn);
                    navigationController.topViewController should be_same_instance_as(teamStatusSummaryController);
                });
            });
        });

        describe(@"tapping on the 'on break' cell", ^{

            context(@"before fetching the most recent team status", ^{
                beforeEach(^{
                    [subject.collectionView.delegate collectionView:subject.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                });

                it(@"should not push anything on the nav stack", ^{
                    navigationController.topViewController should be_same_instance_as(subject);
                });
            });

            context(@"after fetching the most recent team status", ^{
                beforeEach(^{
                    [subject updateWithDashboardSummary:nil];
                    [subject.collectionView.delegate collectionView:subject.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                });

                it(@"should push a team status summary controller onto the navigation stack, passing in the team summary request promise", ^{
                    teamStatusSummaryControllerProvider should have_received(@selector(provideInstanceWithTeamStatusSummaryPromise:initiallyDisplayedSection:)).with(teamStatusSummaryDeferred.promise, TeamStatusTableSectionOnBreak);
                    navigationController.topViewController should be_same_instance_as(teamStatusSummaryController);
                });
            });
        });

        describe(@"the item size of the team status collection view", ^{
            __block UICollectionView *collectionView;
            __block CGSize expectedSize;
            beforeEach(^{
                collectionView = nice_fake_for([UICollectionView class]);
                expectedSize = CGSizeMake(100, 200);
                teamStatusSummaryCardContentStylist stub_method(@selector(calculateItemSizeForStatusSummaryCollectionView:)).and_return(expectedSize);
            });

            it(@"should ask the team status card content stylist for the item size", ^{
                CGSize returnedSize = [subject collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

                teamStatusSummaryCardContentStylist should have_received(@selector(calculateItemSizeForStatusSummaryCollectionView:)).with(collectionView);
                returnedSize should equal(expectedSize);
            });
        });

        describe(@"the seperator size of the team status collection view", ^{
            __block CGFloat expectedSize;
            beforeEach(^{
                expectedSize = 123.3;
                teamStatusSummaryCardContentStylist stub_method(@selector(teamStatusSeperatorWidth)).and_return(expectedSize);
            });
            
            
            it(@"should ask the team status card content stylist for the seperator size", ^{
                CGFloat returnedSize = [subject  collectionView:subject.collectionView layout:subject.collectionView.collectionViewLayout minimumLineSpacingForSectionAtIndex:0];
                returnedSize should equal(expectedSize);
            });
        });
    });

    describe(@"as a <UICollectionViewDataSource>", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            [subject viewWillAppear:NO];

            [(id<CedarDouble>) teamStatusSummaryCardContentStylist reset_sent_messages];
        });

        describe(NSStringFromSelector(@selector(collectionView:cellForItemAtIndexPath:)), ^{
            context(@"when the required cell's index path corresponds to 'in' status", ^{
                it(@"should ask the team status card content stylist to style the cell from the theme", ^{
                    UICollectionView *collectionView = nice_fake_for([UICollectionView class]);
                    SupervisorDashboardTeamStatusSummaryCell *cell = [[SupervisorDashboardTeamStatusSummaryCell alloc] init];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    collectionView stub_method(@selector(dequeueReusableCellWithReuseIdentifier:forIndexPath:)).with(@"TeamStatusViewCell", indexPath).and_return(cell);


                    [subject collectionView:collectionView cellForItemAtIndexPath:indexPath];

                    [(id<CedarDouble>) teamStatusSummaryCardContentStylist sent_messages].count should equal(1);
                    teamStatusSummaryCardContentStylist should have_received(@selector(applyThemeForInStatusToCell:)).with(cell);
                });
            });

            context(@"when the required cell's index path corresponds to 'out' status", ^{
                it(@"should ask the team status card content stylist to style the cell from the theme", ^{
                    UICollectionView *collectionView = nice_fake_for([UICollectionView class]);
                    SupervisorDashboardTeamStatusSummaryCell *cell = nice_fake_for([SupervisorDashboardTeamStatusSummaryCell class]);
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    collectionView stub_method(@selector(dequeueReusableCellWithReuseIdentifier:forIndexPath:)).with(@"TeamStatusViewCell", indexPath).and_return(cell);


                    [subject collectionView:collectionView cellForItemAtIndexPath:indexPath];

                    [(id<CedarDouble>) teamStatusSummaryCardContentStylist sent_messages].count should equal(1);
                    teamStatusSummaryCardContentStylist should have_received(@selector(applyThemeForOutStatusToCell:)).with(cell);
                });
            });

            context(@"when the required cell's index path corresponds to 'break' status", ^{
                it(@"should ask the team status card content stylist to style the cell from the theme", ^{
                    UICollectionView *collectionView = nice_fake_for([UICollectionView class]);
                    SupervisorDashboardTeamStatusSummaryCell *cell = nice_fake_for([SupervisorDashboardTeamStatusSummaryCell class]);
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    collectionView stub_method(@selector(dequeueReusableCellWithReuseIdentifier:forIndexPath:)).with(@"TeamStatusViewCell", indexPath).and_return(cell);


                    [subject collectionView:collectionView cellForItemAtIndexPath:indexPath];

                    [(id<CedarDouble>) teamStatusSummaryCardContentStylist sent_messages].count should equal(1);
                    teamStatusSummaryCardContentStylist should have_received(@selector(applyThemeForBreakStatusToCell:)).with(cell);
                });
            });
        });
    });

    describe(@"styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(cardContainerBackgroundColor)).and_return([UIColor purpleColor]);
            theme stub_method(@selector(cardContainerHeaderFont)).and_return([UIFont italicSystemFontOfSize:17.0f]);
            theme stub_method(@selector(cardContainerHeaderColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(cardContainerSeparatorColor)).and_return([UIColor cyanColor]);
            theme stub_method(@selector(cardContainerBorderColor)).and_return([[UIColor magentaColor] CGColor]);
            theme stub_method(@selector(cardContainerBorderWidth)).and_return((CGFloat)12.0);

            subject.view should_not be_nil;
        });

        it(@"should style the view", ^{
            subject.view.backgroundColor should equal([UIColor purpleColor]);
            subject.view.layer.borderColor should equal([[UIColor magentaColor] CGColor]);
            subject.view.layer.borderWidth should equal(12.0f);
        });

        it(@"should style the header label", ^{
            subject.headerLabel.textColor should equal([UIColor greenColor]);
            subject.headerLabel.font should equal([UIFont italicSystemFontOfSize:17.0f]);
        });

        it(@"should style the separator", ^{
            subject.separatorView.backgroundColor should equal([UIColor cyanColor]);
        });

        it(@"should style the collection view", ^{
            subject.collectionView.backgroundColor should equal([UIColor cyanColor]);
        });
    });
});

SPEC_END
