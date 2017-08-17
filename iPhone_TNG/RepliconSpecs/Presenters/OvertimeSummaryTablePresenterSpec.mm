#import <Cedar/Cedar.h>
#import "OvertimeSummaryTablePresenter.h"
#import "UserSummaryCell.h"
#import "PunchUser.h"
#import <KSDeferred/KSDeferred.h>
#import "ImageFetcher.h"
#import "UserSummaryPlaceholderCell.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(OvertimeSummaryTablePresenterSpec)

describe(@"OvertimeSummaryTablePresenter", ^{
    __block OvertimeSummaryTablePresenter *subject;
    __block ImageFetcher *imageFetcher;
    __block TeamTableStylist *teamTableStylist;

    beforeEach(^{
        imageFetcher = nice_fake_for([ImageFetcher class]);
        teamTableStylist = nice_fake_for([TeamTableStylist class]);
        subject = [[OvertimeSummaryTablePresenter alloc] initWithImageFetcher:imageFetcher teamTableStylist:teamTableStylist];
    });

    describe(NSStringFromSelector(@selector(sectionHeaderForSection:)), ^{
        __block TeamSectionHeaderView *header;

        beforeEach(^{
            header = [subject sectionHeaderForSection:0];
        });

        it(@"should return a correctly configured cell", ^{
            header should be_instance_of([TeamSectionHeaderView class]);
            header.sectionTitleLabel.text should equal(RPLocalizedString(@"Employees on overtime", @"Employees on overtime"));
        });

        it(@"should ask the stylist to style the header", ^{
            teamTableStylist should have_received(@selector(applyThemeToSectionHeaderView:)).with(header);
        });
    });

    describe(NSStringFromSelector(@selector(placeholderTableViewCellForTableView:)), ^{
        __block UITableView *tableView;
        __block UserSummaryPlaceholderCell *expectedCell;
        beforeEach(^{
            tableView = nice_fake_for([UITableView class]);
            expectedCell = nice_fake_for([UserSummaryPlaceholderCell class]);
            tableView stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"UserSummaryPlaceholderCell").and_return(expectedCell);

        });

        it(@"should returns a dequeued placeholder cell", ^{
            [subject placeholderTableViewCellForTableView:tableView] should be_same_instance_as(expectedCell);
        });
    });

    describe(NSStringFromSelector(@selector(tableViewCellForPunchUser:tableView:indexPath:)), ^{

        __block UITableView *tableView;
        __block UserSummaryCell *returnedCell;
        __block UILabel *nameLabel;
        __block UILabel *detailsLabel;
        __block UILabel *hoursLabel;
        __block UIImageView *avatarImageView;
        __block KSDeferred *imageFetchDeferred;
        __block NSInteger expectedTagValue;

        beforeEach(^{
            tableView = nice_fake_for([UITableView class]);
            imageFetchDeferred = [[KSDeferred alloc]init];
            imageFetcher stub_method(@selector(promiseWithImageURL:)).and_return(imageFetchDeferred.promise);

            returnedCell = nice_fake_for([UserSummaryCell class]);

            nameLabel = nice_fake_for([UILabel class]);
            detailsLabel = nice_fake_for([UILabel class]);
            hoursLabel = nice_fake_for([UILabel class]);
            avatarImageView = nice_fake_for([UIImageView class]);

            returnedCell stub_method(@selector(nameLabel)).and_return(nameLabel);
            returnedCell stub_method(@selector(detailsLabel)).and_return(detailsLabel);
            returnedCell stub_method(@selector(hoursLabel)).and_return(hoursLabel);
            returnedCell stub_method(@selector(avatarImageView)).and_return(avatarImageView);

            tableView stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"OvertimeSummaryUserCell").and_return(returnedCell);
        });

        context(@"When called with a user with an address and image", ^{
            __block NSURL *imageURL;
            __block NSIndexPath *indexPath;

            beforeEach(^{
                PunchUser *user = nice_fake_for([PunchUser class]);
                user stub_method(@selector(nameString)).and_return(@"Lee, Brett");
                user stub_method(@selector(addressString)).and_return(@"Brunton Avenue, Richmond VIC 3002, Australia");

                imageURL = nice_fake_for([NSURL class]);
                user stub_method(@selector(imageURL)).and_return(imageURL);

                NSDateComponents *overtimeDateComponents = [[NSDateComponents alloc] init];
                overtimeDateComponents.hour = 1;
                overtimeDateComponents.minute = 45;
                overtimeDateComponents.second = 59;

                user stub_method(@selector(overtimeDateComponents)).and_return(overtimeDateComponents);

                indexPath =  [NSIndexPath indexPathForRow:1 inSection:2];
                expectedTagValue = (indexPath.section * 100000) + indexPath.row;

                returnedCell = [subject tableViewCellForPunchUser:user tableView:tableView indexPath:indexPath];
            });

            it(@"should return a single user cell with the correct label text", ^{
                returnedCell should be_instance_of([UserSummaryCell class]);
                nameLabel should have_received(@selector(setText:)).with(@"Lee, Brett");
                NSString *expectedAddressString = [NSString localizedStringWithFormat:RPLocalizedString(@"at %@", @"at %@"), @"Brunton Avenue, Richmond VIC 3002, Australia" ];

                detailsLabel should have_received(@selector(setText:)).with(expectedAddressString);
                NSString *expectedHoursString = [NSString localizedStringWithFormat:RPLocalizedString(@"%02lu:%02lu Hrs", @"%02lu:%02lu Hrs"), 1, 45];
                hoursLabel should have_received(@selector(setText:)).with(expectedHoursString);
            });

            it(@"should insert a placeholder image", ^{
                avatarImageView should have_received(@selector(setImage:)).with([UIImage imageNamed:@"Avatar_placeholder_sm"]);
            });

            it(@"should show the details label", ^{
                detailsLabel should have_received(@selector(setHidden:)).with(NO);
            });

            it(@"should ask the image fetcher to fetch the user's full size image", ^{
                imageFetcher should have_received(@selector(promiseWithImageURL:)).with(imageURL);
            });

            it(@"should tag the cell with a combination of section and index path to handle reuse", ^{
                returnedCell should have_received(@selector(setTag:)).with(expectedTagValue);
            });

            describe(@"When the image fetcher fetches image successfully", ^{
                __block UIImage *expectedImage;
                beforeEach(^{
                    expectedImage = nice_fake_for([UIImage class]);
                });

                context(@"when the cell has not been reused", ^{
                    beforeEach(^{
                        returnedCell stub_method(@selector(tag)).and_return(expectedTagValue);
                        [imageFetchDeferred resolveWithValue:expectedImage];
                    });

                    it(@"should update the image view with the fetched image", ^{
                        avatarImageView should have_received(@selector(setImage:)).with(expectedImage);
                    });
                });

                context(@"when the cell has been reused", ^{
                    beforeEach(^{
                        returnedCell stub_method(@selector(tag)).and_return(expectedTagValue + 1);
                        [(id<CedarDouble>)avatarImageView reset_sent_messages];
                        [imageFetchDeferred resolveWithValue:expectedImage];
                    });

                    it(@"should not update the image view", ^{
                        avatarImageView should_not have_received(@selector(setImage:));
                    });
                });
            });
        });

        context(@"when called with a user that lacks an address", ^{
            beforeEach(^{
                PunchUser *user = nice_fake_for([PunchUser class]);
                NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:1 inSection:0];
                returnedCell = [subject tableViewCellForPunchUser:user tableView:tableView indexPath:indexPath];
            });

            it(@"should hide the details label", ^{
                detailsLabel should have_received(@selector(setHidden:)).with(YES);
                detailsLabel should_not have_received(@selector(setHidden:)).with(NO);
            });
        });

        context(@"when called with a user that lacks a thumbnail ", ^{
            __block UITableViewCell *returnedCell;
            __block NSIndexPath *indexPath;
            __block NSInteger expectedTagValue;

            beforeEach(^{
                PunchUser *user = nice_fake_for([PunchUser class]);

                indexPath =  [NSIndexPath indexPathForRow:0 inSection:3];
                expectedTagValue = (indexPath.section * 100000) + indexPath.row;
                returnedCell = [subject tableViewCellForPunchUser:user tableView:tableView indexPath:indexPath];
            });

            it(@"should insert a placeholder image", ^{
                avatarImageView should have_received(@selector(setImage:)).with([UIImage imageNamed:@"Avatar_placeholder_sm"]);
            });

            it(@"should not ask the image fetcher to fetch an image", ^{
                imageFetcher should_not have_received(@selector(promiseWithImageURL:));
            });

            it(@"should tag the cell with a combination of section and index path to handle reuse", ^{
                returnedCell should have_received(@selector(setTag:)).with(expectedTagValue);
            });
        });


        describe(@"styling the cells", ^{
            __block PunchUser *user;

            describe(@"when there are overtime users", ^{
                __block NSIndexPath *indexpath;
                beforeEach(^{
                    indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
                    user = nice_fake_for([PunchUser class]);
                    returnedCell = [subject tableViewCellForPunchUser:user tableView:tableView indexPath:indexpath];

                });

                it(@"should return correct type of cell", ^{
                    returnedCell should be_instance_of([UserSummaryCell class]);
                });

                it(@"should style the cell with the stylist", ^{
                    teamTableStylist should have_received(@selector(applyThemeToUserSummaryCell:)).with(returnedCell);
                });
            });
        });
    });
});

SPEC_END
