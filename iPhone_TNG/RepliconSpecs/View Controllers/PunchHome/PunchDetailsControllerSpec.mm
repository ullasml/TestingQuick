#import <Cedar/Cedar.h>
#import "PunchDetailsController.h"
#import "PunchPresenter.h"
#import "Theme.h"
#import "Punch.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <KSDeferred/KSDeferred.h>
#import "Punch.h"
#import "UITableViewCell+Spec.h"
#import "UserPermissionsStorage.h"
#import "BreakType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchDetailsControllerSpec)

describe(@"PunchDetailsController", ^{
    __block PunchDetailsController *subject;
    __block id<Punch> punch;
    __block PunchPresenter *punchPresenter;
    __block id<Theme> theme;
    __block id<BSBinder, BSInjector> injector;
    __block id <PunchDetailsControllerDelegate> delegate;
    __block UserPermissionsStorage *userPermissionsStorage;

    beforeEach(^{
        injector = [InjectorProvider injector];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[userPermissionsStorage class] toInstance:userPermissionsStorage];
        
        punchPresenter = nice_fake_for([PunchPresenter class]);
        [injector bind:[PunchPresenter class] toInstance:punchPresenter];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        subject = [injector getInstance:[PunchDetailsController class]];
        delegate = nice_fake_for(@protocol(PunchDetailsControllerDelegate));
        [subject setUpWithTableViewDelegate:delegate];

        punch = nice_fake_for(@protocol(Punch));

        theme stub_method(@selector(timeLineCellTimeLabelFont)).and_return([UIFont systemFontOfSize:13.0f]);
        theme stub_method(@selector(timeLineCellTimeLabelTextColor)).and_return([UIColor orangeColor]);
        theme stub_method(@selector(timeLineCellDescriptionLabelTextColor)).and_return([UIColor redColor]);

        theme stub_method(@selector(punchDetailsBorderLineColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(punchDetailsContentViewBackgroundColor)).and_return([UIColor purpleColor]);

        theme stub_method(@selector(punchDetailsAddressLabelFont)).and_return([UIFont systemFontOfSize:13.0f]);
        theme stub_method(@selector(punchDetailsAddressLabelTextColor)).and_return([UIColor greenColor]);

        theme stub_method(@selector(attributeDisabledValueLabelColor)).and_return([UIColor blueColor]);


        userPermissionsStorage stub_method(@selector(canEditTimePunch)).and_return(YES);
        punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:)).and_return(@"HEYO");
        punchPresenter stub_method(@selector(dateTimeLabelTextWithPunch:)).and_return(@"My special time");


        [subject updateWithPunch:punch];
    });

    describe(@"presenting the basic punch details", ^{
        __block NSDate *date;
        __block UIImage *image;
        __block UITableView *tableView;
        __block UIView *contentView;
        __block UIView *topBorderLineView;
        __block UIView *bottomBorderLineView;

        beforeEach(^{

            date = nice_fake_for([NSDate class]);
            image = [[UIImage alloc] init];
            punch stub_method(@selector(date)).and_return(date);
            punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

            punchPresenter stub_method(@selector(punchActionIconImageWithPunch:)).and_return(image);
            subject.view should_not be_nil;

            tableView = subject.tableView;
            contentView = subject.contentView;
            topBorderLineView = subject.topBorderLineView;
            bottomBorderLineView = subject.bottomBorderLineView;

            [tableView layoutSubviews];
        });

        it(@"should collaborate with the presenter", ^{
            punchPresenter should have_received(@selector(descriptionLabelTextWithPunch:)).with(punch);
            punchPresenter should have_received(@selector(punchActionIconImageWithPunch:)).with(punch);
            punchPresenter should have_received(@selector(dateTimeLabelTextWithPunch:)).with(punch);
        });

        it(@"should include correct number of detail rows", ^{
            [tableView numberOfRowsInSection:0] should equal(2);
        });

        it(@"should present the punch type", ^{
            UITableViewCell *cell = (UITableViewCell *)[tableView.visibleCells firstObject];

            cell.textLabel.text should equal(@"HEYO");
            cell.imageView.image should be_same_instance_as(image);
            cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
        });

        it(@"should present punch time ", ^{
            UITableViewCell *cell = (UITableViewCell *)[tableView.visibleCells lastObject];

            cell.textLabel.text should equal(@"My special time");
            cell.selectionStyle should equal(UITableViewCellSelectionStyleNone);
            cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);

        });

        context(@"style the cells", ^{

            context(@"when canEditTimePunch is true", ^{
                it(@"should style the cells appropriately", ^{
                    UITableViewCell *cell = (UITableViewCell *)[tableView.visibleCells firstObject];

                    cell.textLabel.textColor should equal([UIColor orangeColor]);
                    cell.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);

                    UITableViewCell *cellB = (UITableViewCell *)[tableView.visibleCells lastObject];

                    cellB.textLabel.textColor should equal([UIColor orangeColor]);
                    cellB.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);
                });

            });

            context(@"when canEditTimePunch is false", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(canEditTimePunch)).again().and_return(NO);
                    [subject.tableView reloadData];
                });
                it(@"should style the cells appropriately", ^{

                    UITableViewCell *cellA = (UITableViewCell *)[tableView.visibleCells firstObject];

                    cellA.textLabel.textColor should equal([UIColor orangeColor]);
                    cellA.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);

                    UITableViewCell *cellB = (UITableViewCell *)[tableView.visibleCells lastObject];

                    cellB.textLabel.textColor should equal([UIColor blueColor]);
                    cellB.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);
                });
                
            });

            context(@"when canEditTimePunch is false and punch action is Start Break", ^{
                beforeEach(^{
                    punch stub_method(@selector(actionType)).again().and_return(PunchActionTypeStartBreak);
                    userPermissionsStorage stub_method(@selector(canEditTimePunch)).again().and_return(NO);
                    [subject.tableView reloadData];
                });
                it(@"should style the cells appropriately", ^{

                    UITableViewCell *cellA = (UITableViewCell *)[tableView.visibleCells firstObject];

                    cellA.textLabel.textColor should equal([UIColor blueColor]);
                    cellA.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);

                    UITableViewCell *cellB = (UITableViewCell *)[tableView.visibleCells lastObject];

                    cellB.textLabel.textColor should equal([UIColor blueColor]);
                    cellB.textLabel.font should equal([UIFont systemFontOfSize:13.0f]);
                });
                
            });


        });

        it(@"should style the content view", ^{
            contentView.backgroundColor should equal([UIColor purpleColor]);
        });

        it(@"should style the borders", ^{
            topBorderLineView.backgroundColor should equal([UIColor yellowColor]);
            bottomBorderLineView.backgroundColor should equal([UIColor yellowColor]);
        });
    });

    describe(@"presenting the image if it exists", ^{
        beforeEach(^{
            [subject view];
        });

        it(@"should collaborate with its punch presenter to show an image", ^{
            punchPresenter should have_received(@selector(presentImageForPunch:inImageView:)).with(punch, subject.selfieImageView);
        });

        it(@"should contain the ImageView in its view hierarchy", ^{
            [subject.contentView subviews] should contain(subject.selfieImageView);
        });
    });

    describe(@"presenting an updated punch", ^{
        __block id<Punch> updatedPunch;
        __block UIImage *punchIcon;
        __block UIImage *updatedPunchIcon;

        beforeEach(^{
            punchIcon = [[UIImage alloc] init];
            updatedPunchIcon = [[UIImage alloc] init];

            updatedPunch = nice_fake_for(@protocol(Punch));

            punchPresenter stub_method(@selector(dateTimeLabelTextWithPunch:))
                .with(punch).and_return(@"My Date/Time");

            punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:))
                .with(punch).and_return(@"My Punch Type");

            punchPresenter stub_method(@selector(punchActionIconImageWithPunch:))
                .with(punch).and_return(punchIcon);

            punchPresenter stub_method(@selector(dateTimeLabelTextWithPunch:))
                .with(updatedPunch).and_return(@"My Updated Date/Time");

            punchPresenter stub_method(@selector(descriptionLabelTextWithPunch:))
                .with(updatedPunch).and_return(@"My Updated Punch Type");

            punchPresenter stub_method(@selector(punchActionIconImageWithPunch:))
                .with(updatedPunch).and_return(updatedPunchIcon);

            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];

            [subject updateWithPunch:updatedPunch];
            [subject viewDidLayoutSubviews];
        });

        it(@"should display the updated punch type", ^{
            UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells firstObject];

            cell.textLabel.text should equal(@"My Updated Punch Type");
            cell.imageView.image should be_same_instance_as(updatedPunchIcon);
        });

        it(@"should display the updated time", ^{
            UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells lastObject];

            cell.textLabel.text should equal(@"My Updated Date/Time");
        });
    });
    
    describe(@"presenting an break punch", ^{
        __block id<Punch> breakPunch;
        __block UIImage *punchIcon;
        __block UIImage *updatedPunchIcon;
        __block BreakType *breakType;
        beforeEach(^{
            punchIcon = [[UIImage alloc] init];

            breakType = nice_fake_for([BreakType class]);
            breakType stub_method(@selector(name)).and_return(@"some-break");
            breakType stub_method(@selector(uri)).and_return(@"some-uri");

            breakPunch = nice_fake_for(@protocol(Punch));
            breakPunch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
            breakPunch stub_method(@selector(breakType)).and_return(breakType);

            punchPresenter stub_method(@selector(dateTimeLabelTextWithPunch:))
            .with(breakPunch).and_return(@"My Date/Time");
            
            punchPresenter stub_method(@selector(punchActionIconImageWithPunch:))
            .with(breakPunch).and_return(punchIcon);
            
            subject.view should_not be_nil;
            [subject.view layoutIfNeeded];
            
            [subject updateWithPunch:breakPunch];
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should display the break punch type", ^{
            UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells firstObject];
            
            cell.textLabel.text should equal(@"some-break");
            cell.imageView.image should be_same_instance_as(punchIcon);
        });
        
        it(@"should display the updated time", ^{
            UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells lastObject];
            
            cell.textLabel.text should equal(@"My Date/Time");
        });
    });


    describe(@"viewDidLayoutSubviews", ^{

        beforeEach(^{
            subject.view should_not be_nil;
            [subject.tableView layoutSubviews];
            spy_on(subject.tableView);
            spy_on(subject.contentView);

            [subject viewDidLayoutSubviews];
        });

        it(@"should inform the tableViewDelegate PunchDetailsController updated its height", ^{
            delegate should have_received(@selector(punchDetailsController:didUpdateTableViewWithHeight:));
        });

    });

    describe(@"editing a punch", ^{
        context(@"when canEditTimePunch is true and canEditNonTimeFields is false", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(canEditTimePunch)).again().and_return(YES);
                userPermissionsStorage stub_method(@selector(canEditNonTimeFields)).and_return(NO);
                subject.view should_not be_nil;
                [subject.view layoutIfNeeded];
                [subject viewDidLayoutSubviews];

            });

            it(@"should inform the delegate when the first row is tapped and the punch type is Break", ^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells firstObject];
                [cell tap];

                subject.delegate should have_received(@selector(punchDetailsControllerWantsToChangeBreakType:)).with(subject);
            });

            it(@"should not inform the delegate when the first row is tapped and the punch type is not Break", ^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells firstObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:));
            });

            it(@"should inform the delegate when the second row is tapped", ^{
                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells lastObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:));
                subject.delegate should have_received(@selector(punchDetailsController:didIntendToChangeDateOrTimeOfPunch:)).with(subject,punch);
            });

            it(@"should not inform the delegate when the second row is tapped", ^{

                userPermissionsStorage stub_method(@selector(canEditTimePunch)).again().and_return(NO);
                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells lastObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:));
                subject.delegate should_not have_received(@selector(punchDetailsController:didIntendToChangeDateOrTimeOfPunch:));
            });
        });
        context(@"when canEditTimePunch is false and canEditNonTimeFields is true", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(canEditTimePunch)).again().and_return(NO);
                 userPermissionsStorage stub_method(@selector(canEditNonTimeFields)).and_return(NO);
                subject.view should_not be_nil;
                [subject.view layoutIfNeeded];
                [subject viewDidLayoutSubviews];

            });

            it(@"should not inform the delegate when the first row is tapped and the punch type is Break", ^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);

                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells firstObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:)).with(subject);
            });

            it(@"should not inform the delegate when the first row is tapped and the punch type is not Break", ^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);

                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells firstObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:));
            });

            it(@"should not inform the delegate when the second row is tapped", ^{
                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells lastObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:));
                subject.delegate should_not have_received(@selector(punchDetailsController:didIntendToChangeDateOrTimeOfPunch:)).with(subject,punch);
            });

            it(@"should not inform the delegate when the second row is tapped", ^{

                userPermissionsStorage stub_method(@selector(canEditTimePunch)).again().and_return(NO);
                UITableViewCell *cell = (UITableViewCell *)[subject.tableView.visibleCells lastObject];
                [cell tap];

                subject.delegate should_not have_received(@selector(punchDetailsControllerWantsToChangeBreakType:));
                subject.delegate should_not have_received(@selector(punchDetailsController:didIntendToChangeDateOrTimeOfPunch:));
            });
        });

    });
});

SPEC_END
