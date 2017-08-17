#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "TeamStatusTablePresenter.h"
#import "TeamStatusSummaryNoUsersCell.h"
#import "UserSummaryCell.h"
#import "PunchUser.h"
#import "Theme.h"
#import "TeamSectionHeaderView.h"
#import "UserSummaryPlaceholderCell.h"
#import "DurationCalculator.h"
#import "ImageFetcher.h"
#import <KSDeferred/KSDeferred.h>
#import "BookedTimeOff.h"
#import "TeamStatusSummaryController.h"
#import "TeamTableStylist.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamStatusTablePresenterSpec)

describe(@"TeamStatusTablePresenter", ^{
    __block TeamStatusTablePresenter *subject;
    __block id<Theme> theme;
    __block DurationCalculator *durationCalculator;
    __block ImageFetcher *imageFetcher;
    __block TeamTableStylist *teamTableStylist;

    beforeEach(^{
        durationCalculator = nice_fake_for([DurationCalculator class]);
        imageFetcher = nice_fake_for([ImageFetcher class]);
        teamTableStylist = nice_fake_for([TeamTableStylist class]);
        theme = nice_fake_for(@protocol(Theme));

        subject = [[TeamStatusTablePresenter alloc] initWithDurationCalculator:durationCalculator
                                                                  imageFetcher:imageFetcher
                                                              teamTableStylist:teamTableStylist
                                                                         theme:theme];
    });

    describe(NSStringFromSelector(@selector(tableViewCellForUsersArray:noUsersString:tableView:indexPath:isShowHoursField:)), ^{
        __block UITableView *tableView;
        __block TeamStatusSummaryNoUsersCell *noUsersCell;
        __block UILabel *noUsersLabel;
        __block UserSummaryCell *userCell;
        __block UILabel *nameLabel;
        __block UILabel *detailsLabel;
        __block UILabel *hoursLabel;
        __block UIImageView *avatarImageView;

        beforeEach(^{
            tableView = nice_fake_for([UITableView class]);

            noUsersCell = nice_fake_for([TeamStatusSummaryNoUsersCell class]);
            noUsersLabel = nice_fake_for([UILabel class]);
            noUsersCell stub_method(@selector(noUsersCell)).and_return(noUsersLabel);

            userCell = nice_fake_for([UserSummaryCell class]);
            nameLabel = nice_fake_for([UILabel class]);
            detailsLabel = nice_fake_for([UILabel class]);

            hoursLabel = nice_fake_for([UILabel class]);
            avatarImageView = nice_fake_for([UIImageView class]);

            userCell stub_method(@selector(nameLabel)).and_return(nameLabel);
            userCell stub_method(@selector(detailsLabel)).and_return(detailsLabel);
            userCell stub_method(@selector(hoursLabel)).and_return(hoursLabel);
            userCell stub_method(@selector(avatarImageView)).and_return(avatarImageView);

            tableView stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"TeamStatusSummaryNoUsersCell").and_return(noUsersCell);
            tableView stub_method(@selector(dequeueReusableCellWithIdentifier:)).with(@"UserSummaryCell").and_return(userCell);
        });

        context(@"when called with an empty users array", ^{
            __block UITableViewCell *returnedCell;
            beforeEach(^{
                returnedCell = [subject tableViewCellForUsersArray:@[] noUsersString:@"No users!" tableView:tableView indexPath:nil isShowHoursField:NULL];
            });

            it(@"should return a single no users cell with the correct label text", ^{
                returnedCell should be_instance_of([TeamStatusSummaryNoUsersCell class]);
                noUsersLabel should have_received(@selector(setText:)).with(@"No users!");
            });
        });

        context(@"when called with a non-empty users array", ^{
            __block UITableViewCell *returnedCell;
            __block NSURL *imageURL;
            __block KSDeferred *imageFetchDeferred;
            __block NSIndexPath *indexPath;
            __block NSInteger expectedTagValue;
            __block PunchUser *userA;
            __block PunchUser *userB;

            beforeEach(^{
                imageFetchDeferred = [[KSDeferred alloc]init];
                imageFetcher stub_method(@selector(promiseWithImageURL:)).and_return(imageFetchDeferred.promise);

                userA = nice_fake_for([PunchUser class]);
                userA stub_method(@selector(nameString)).and_return(@"Warne, Shane");

                userB = nice_fake_for([PunchUser class]);
                userB stub_method(@selector(nameString)).and_return(@"Lee, Brett");
                userB stub_method(@selector(addressString)).and_return(@"Brunton Avenue, Richmond VIC 3002, Australia");

                NSDateComponents *regularDateComponents = [[NSDateComponents alloc] init];
                regularDateComponents.hour = 1;
                regularDateComponents.minute = 2;
                regularDateComponents.second = 51;

                userB stub_method(@selector(regularDateComponents)).and_return(regularDateComponents);

                NSDateComponents *overtimeDateComponents = [[NSDateComponents alloc] init];
                overtimeDateComponents.hour = 2;
                overtimeDateComponents.minute = 3;
                overtimeDateComponents.second = 10;

                userB stub_method(@selector(overtimeDateComponents)).and_return(overtimeDateComponents);

                NSDateComponents *sumOfHoursDateComponents = [[NSDateComponents alloc] init];
                sumOfHoursDateComponents.hour = 3;
                sumOfHoursDateComponents.minute = 6;
                sumOfHoursDateComponents.second = 1;

                durationCalculator stub_method(@selector(sumOfTimeByAddingDateComponents:toDateComponents:)).with(overtimeDateComponents, regularDateComponents).and_return(sumOfHoursDateComponents);

                imageURL = nice_fake_for([NSURL class]);
                userB stub_method(@selector(imageURL)).and_return(imageURL);

                indexPath =  [NSIndexPath indexPathForRow:1 inSection:2];
                expectedTagValue = (indexPath.section * 100000) + indexPath.row;

            });

            context(@"when hours field is shown", ^{
                beforeEach(^{
                    returnedCell = [subject tableViewCellForUsersArray:@[userA, userB] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:YES];
                });
                it(@"should return a single user cell with the labels", ^{
                    returnedCell should be_instance_of([UserSummaryCell class]);
                    nameLabel should have_received(@selector(setText:)).with(@"Lee, Brett");
                    NSString *expectedAddressString = [NSString localizedStringWithFormat:RPLocalizedString(@"at %@", @"at %@"), @"Brunton Avenue, Richmond VIC 3002, Australia" ];
                    detailsLabel should have_received(@selector(setText:)).with(expectedAddressString);

                    NSString *expectedHoursString = [NSString localizedStringWithFormat:RPLocalizedString(@"%02lu:%02lu Hrs", @"%02lu:%02lu Hrs"), 3, 6];
                    hoursLabel should have_received(@selector(setText:)).with(expectedHoursString);
                });

                it(@"should show the details label", ^{
                    detailsLabel should have_received(@selector(setHidden:)).with(NO);
                });

                it(@"should insert a placeholder image", ^{
                    avatarImageView should have_received(@selector(setImage:)).with([UIImage imageNamed:@"Avatar_placeholder_sm"]);
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
                            userCell stub_method(@selector(tag)).and_return(expectedTagValue);
                            [imageFetchDeferred resolveWithValue:expectedImage];
                        });

                        it(@"should update the image view with the fetched image", ^{
                            avatarImageView should have_received(@selector(setImage:)).with(expectedImage);
                        });
                    });

                    context(@"when the cell has been reused", ^{
                        beforeEach(^{
                            userCell stub_method(@selector(tag)).and_return(expectedTagValue + 1);
                            [(id<CedarDouble>)avatarImageView reset_sent_messages];
                            [imageFetchDeferred resolveWithValue:expectedImage];
                        });

                        it(@"should not update the image view", ^{
                            avatarImageView should_not have_received(@selector(setImage:));
                        });
                    });
                });
            });

            context(@"when hours field is hidden", ^{

                beforeEach(^{
                     returnedCell = [subject tableViewCellForUsersArray:@[userA, userB] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NO];
                });

                it(@"should show the hours label", ^{
                    hoursLabel should have_received(@selector(setHidden:)).with(YES);
                });
            });


        });

        context(@"when called with a user that lacks an address", ^{
            __block UITableViewCell *returnedCell;
            beforeEach(^{
                PunchUser *userA = nice_fake_for([PunchUser class]);
                userA stub_method(@selector(nameString)).and_return(@"Warne, Shane");
                PunchUser *userB = nice_fake_for([PunchUser class]);
                userB stub_method(@selector(nameString)).and_return(@"Lee, Brett");

                NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:1 inSection:2];
                returnedCell = [subject tableViewCellForUsersArray:@[userA, userB] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];
            });

            it(@"should hide the details label", ^{
                detailsLabel should have_received(@selector(setHidden:)).with(YES);
            });
        });

        context(@"when called with a user that lacks an image ", ^{
            __block UITableViewCell *returnedCell;
            __block NSIndexPath *indexPath;
            __block NSInteger expectedTagValue;

            beforeEach(^{
                PunchUser *user = nice_fake_for([PunchUser class]);
                indexPath =  [NSIndexPath indexPathForRow:0 inSection:3];
                expectedTagValue = (indexPath.section * 100000) + indexPath.row;
                returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];
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

        context(@"when called with a user that has time off booked", ^{
            __block UITableViewCell *returnedCell;
            __block BookedTimeOff *bookedTimeOff;
            __block NSString *expectedAddressString;
            __block PunchUser *user;

            beforeEach(^{
                user = nice_fake_for([PunchUser class]);
                user stub_method(@selector(nameString)).and_return(@"Lee, Brett");
                NSString *addressString = @"Moore Park Rd., Moore Park NSW 2021, Australia";
                expectedAddressString = [NSString localizedStringWithFormat:RPLocalizedString(@"at %@", @"at %@"), addressString];
                user stub_method(@selector(addressString)).and_return(addressString);
                bookedTimeOff = nice_fake_for([BookedTimeOff class]);
                bookedTimeOff stub_method(@selector(descriptionText)).and_return(@"Time off description");

                user stub_method(@selector(bookedTimeOffArray)).and_return(@[bookedTimeOff]);
            });

            context(@"when the user is not in", ^{
                beforeEach(^{
                    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionNotIn];
                    returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];
                });

                it(@"should display the time off information instead of the last punch address", ^{
                    detailsLabel should have_received(@selector(setText:)).with(@"Time off description");
                });

                it(@"should show the details label", ^{
                    detailsLabel should have_received(@selector(setHidden:)).with(NO);
                });
            });

            context(@"when the user is clocked in", ^{
                beforeEach(^{
                    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionClockedIn];
                    returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];

                });

                it(@"should display the last punch address instead of the time off information", ^{
                    detailsLabel should have_received(@selector(setText:)).with(expectedAddressString);
                });
            });

            context(@"when the user is on break", ^{
                beforeEach(^{
                    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionOnBreak];
                    returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];

                });

                it(@"should display the last punch address instead of the time off information", ^{
                    detailsLabel should have_received(@selector(setText:)).with(expectedAddressString);
                });
            });
        });

        context(@"when called with a user that has time off booked, but for some reason the booked time off has missing description text", ^{
            __block BookedTimeOff *bookedTimeOff;
            __block NSString *expectedAddressString;
            __block PunchUser *user;

            beforeEach(^{
                user = nice_fake_for([PunchUser class]);
                user stub_method(@selector(nameString)).and_return(@"Lee, Brett");
                NSString *addressString = @"Moore Park Rd., Moore Park NSW 2021, Australia";
                expectedAddressString = [NSString localizedStringWithFormat:RPLocalizedString(@"at %@", @"at %@"), addressString];
                user stub_method(@selector(addressString)).and_return(addressString);
                bookedTimeOff = nice_fake_for([BookedTimeOff class]);
                bookedTimeOff stub_method(@selector(descriptionText)).and_return(nil);

                user stub_method(@selector(bookedTimeOffArray)).and_return(@[bookedTimeOff]);
            });

            it(@"should not raise an exception", ^{
                NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionNotIn];
                ^ {
                    [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL]; } should_not raise_exception;
            });
        });

        describe(@"styling the cells", ^{
            __block PunchUser *user;
            __block BookedTimeOff *bookedTimeOff;
            __block UITableViewCell *returnedCell;

            beforeEach(^{
                theme stub_method(@selector(userSummaryCellNameFont)).and_return([UIFont systemFontOfSize:8]);
                theme stub_method(@selector(userSummaryCellNameColor)).and_return([UIColor magentaColor]);
                theme stub_method(@selector(userSummaryCellDetailsFont)).and_return([UIFont systemFontOfSize:7]);
                theme stub_method(@selector(userSummaryCellDetailsColor)).and_return([UIColor greenColor]);
                theme stub_method(@selector(userSummaryCellHoursFont)).and_return([UIFont systemFontOfSize:6]);
                theme stub_method(@selector(userSummaryCellHoursColor)).and_return([UIColor yellowColor]);
                theme stub_method(@selector(userSummaryCellHoursInactiveColor)).and_return([UIColor brownColor]);

                theme stub_method(@selector(teamStatusCellNoUsersFont)).and_return([UIFont systemFontOfSize:5]);
                theme stub_method(@selector(teamStatusCellNoUsersColor)).and_return([UIColor purpleColor]);
            });


            describe(@"when there are no users", ^{
                beforeEach(^{
                    [subject tableViewCellForUsersArray:@[] noUsersString:@"No users!" tableView:tableView indexPath:nil isShowHoursField:NULL];
                });

                it(@"should style the cell from the theme", ^{
                    noUsersLabel should have_received(@selector(setFont:)).with([UIFont systemFontOfSize:5]);
                                                          noUsersLabel should have_received(@selector(setTextColor:)).with([UIColor purpleColor]);
                });
            });

            describe(@"when there are users", ^{
                __block UITableViewCell *returnedCell;
                beforeEach(^{
                    user = nice_fake_for([PunchUser class]);
                    returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:[NSIndexPath indexPathForRow:0 inSection:0] isShowHoursField:NULL];
                });

                it(@"should ask the stylist to style the cell", ^{
                    teamTableStylist should have_received(@selector(applyThemeToUserSummaryCell:)).with(returnedCell);
                });
            });

            context(@"when there is a user that has time off and is not in", ^{
                beforeEach(^{
                    user = nice_fake_for([PunchUser class]);
                    bookedTimeOff = nice_fake_for([BookedTimeOff class]);
                    bookedTimeOff stub_method(@selector(descriptionText)).and_return(@"Time off description");
                    user stub_method(@selector(bookedTimeOffArray)).and_return(@[bookedTimeOff]);
                    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionNotIn];
                    returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];
                });


                it(@"should ask the stylist to style the cell", ^{
                    teamTableStylist should have_received(@selector(applyThemeToUserSummaryCell:)).with(returnedCell);
                });

                it(@"should style the hours label correctly from the theme", ^{
                    hoursLabel should have_received(@selector(setTextColor:)).with([UIColor brownColor]);
                });
            });

            context(@"when there is a user that has time off and is at work", ^{
                beforeEach(^{
                    user = nice_fake_for([PunchUser class]);
                    bookedTimeOff = nice_fake_for([BookedTimeOff class]);
                    bookedTimeOff stub_method(@selector(descriptionText)).and_return(@"Time off description");
                    user stub_method(@selector(bookedTimeOffArray)).and_return(@[bookedTimeOff]);
                    NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:0 inSection:TeamStatusTableSectionClockedIn];
                    returnedCell = [subject tableViewCellForUsersArray:@[user] noUsersString:@"No users!" tableView:tableView indexPath:indexPath isShowHoursField:NULL];
                });

                it(@"should ask the stylist to style the cell", ^{
                    teamTableStylist should have_received(@selector(applyThemeToUserSummaryCell:)).with(returnedCell);
                });

                it(@"should style the hours label correctly from the theme", ^{
                    hoursLabel should have_received(@selector(setTextColor:)).with([UIColor yellowColor]);
                });
            });

        });
    });

    describe(NSStringFromSelector(@selector(sectionHeaderForSection:)), ^{
        context(@"when the section is the clocked in section", ^{
            it(@"should return a correctly configured cell", ^{
                TeamSectionHeaderView *header = [subject sectionHeaderForSection:0];
                header should be_instance_of([TeamSectionHeaderView class]);
                header.sectionTitleLabel.text should equal(RPLocalizedString(@"Clocked In", @"Clocked In"));
            });
        });
        context(@"when the section is the on break section", ^{
            it(@"should return a correctly configured cell", ^{
                TeamSectionHeaderView *header = [subject sectionHeaderForSection:1];
                header should be_instance_of([TeamSectionHeaderView class]);
                header.sectionTitleLabel.text should equal(RPLocalizedString(@"On Break", @"On Break"));
            });
        });
        context(@"when the section is the not clocked in section", ^{
            it(@"should return a correctly configured cell", ^{
                TeamSectionHeaderView *header = [subject sectionHeaderForSection:2];
                header should be_instance_of([TeamSectionHeaderView class]);
                header.sectionTitleLabel.text should equal(RPLocalizedString(@"Not In", @"Not In"));
            });
        });

        describe(@"styling the header", ^{
            it(@"should ask the stylist to style the header", ^{
                TeamSectionHeaderView *header = [subject sectionHeaderForSection:2];
                teamTableStylist should have_received(@selector(applyThemeToSectionHeaderView:)).with(header);
            });
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
});

SPEC_END
