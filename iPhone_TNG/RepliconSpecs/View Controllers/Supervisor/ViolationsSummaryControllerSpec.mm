#import <Cedar/Cedar.h>
#import "ViolationsSummaryController.h"
#import "RepliconSpecHelper.h"
#import <KSDeferred/KSDeferred.h>
#import "SupervisorDashboardSummary.h"
#import "ViolationEmployee.h"
#import "Violation.h"
#import "TeamSectionHeaderView.h"
#import "ViolationCell.h"
#import "Waiver.h"
#import "UITableViewCell+Spec.h"
#import "WaiverController.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "ViolationSeverityPresenter.h"
#import "TeamTableStylist.h"
#import "Theme.h"
#import "WaiverOption.h"
#import "SupervisorDashboardSummaryRepository.h"
#import "SpinnerDelegate.h"
#import "InjectorKeys.h"
#import "ViolationSectionHeaderPresenter.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "ViolationsSummaryController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationsSummaryControllerSpec)

describe(@"ViolationsSummaryController", ^{
    __block ViolationsSummaryController *subject;
    __block id<BSBinder, BSInjector> injector;
    __block ViolationSeverityPresenter *violationSeverityPresenter;
    __block TeamTableStylist *teamTableStylist;
    __block id<Theme> theme;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block KSDeferred *violationSectionsDeferred;
    __block SupervisorDashboardSummaryRepository *supervisorDashboardSummaryRepository;
    __block ViolationSectionHeaderPresenter *violationSectionHeaderPresenter;
    __block id<ViolationsSummaryControllerDelegate> delegate;

    beforeEach(^{
        injector = [InjectorProvider injector];

        violationSectionsDeferred = [[KSDeferred alloc] init];

        delegate = nice_fake_for(@protocol(ViolationsSummaryControllerDelegate));
        delegate stub_method(@selector(violationsSummaryControllerDidRequestViolationSectionsPromise:)).and_return(violationSectionsDeferred.promise);

        violationSeverityPresenter = nice_fake_for([ViolationSeverityPresenter class]);
        [injector bind:[ViolationSeverityPresenter class]
            toInstance:violationSeverityPresenter];

        teamTableStylist = nice_fake_for([TeamTableStylist class]);
        [injector bind:[TeamTableStylist class] toInstance:teamTableStylist];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        [injector bind:@protocol(SpinnerDelegate) toInstance:spinnerDelegate];

        supervisorDashboardSummaryRepository = fake_for([SupervisorDashboardSummaryRepository class]);
        [injector bind:[SupervisorDashboardSummaryRepository class] toInstance:supervisorDashboardSummaryRepository];

        violationSectionHeaderPresenter = nice_fake_for([ViolationSectionHeaderPresenter class]);
        [injector bind:[ViolationSectionHeaderPresenter class] toInstance:violationSectionHeaderPresenter];

        subject = [injector getInstance:[ViolationsSummaryController class]];
        [subject setupWithViolationSectionsPromise:violationSectionsDeferred.promise
                                          delegate:delegate];
    });

    __block UINavigationController *containingNavigationController;
    beforeEach(^{
        containingNavigationController = [[UINavigationController alloc] initWithRootViewController:subject];
    });

    describe(@"presenting the list of employees who have violations", ^{
        beforeEach(^{
            [subject view];
            [subject viewWillAppear:NO];
        });

        context(@"when the promise is resolved", ^{
            __block UIImage *errorImage;
            __block UIImage *warningImage;
            __block UIImage *infoImage;

            beforeEach(^{
                errorImage = [[UIImage alloc] init];
                warningImage = [[UIImage alloc] init];
                infoImage = [[UIImage alloc] init];

                violationSeverityPresenter stub_method(@selector(severityImageWithViolationSeverity:))
                .with(ViolationSeverityError).and_return(errorImage);
                violationSeverityPresenter stub_method(@selector(severityImageWithViolationSeverity:))
                .with(ViolationSeverityWarning).and_return(warningImage);
                violationSeverityPresenter stub_method(@selector(severityImageWithViolationSeverity:))
                .with(ViolationSeverityInfo).and_return(infoImage);
            });

            __block UIFont *violationsCellTitleFont;
            __block UIColor *violationsCellTitleTextColor;
            __block UIFont *violationsCellTimeAndStatusFont;
            __block UIColor *violationsCellTimeAndStatusTextColor;

            beforeEach(^{
                violationsCellTitleFont = [UIFont systemFontOfSize:12];
                theme stub_method(@selector(violationsCellTitleFont)).and_return(violationsCellTitleFont);

                violationsCellTitleTextColor = [UIColor purpleColor];
                theme stub_method(@selector(violationsCellTitleTextColor)).and_return(violationsCellTitleTextColor);

                violationsCellTimeAndStatusFont = [UIFont systemFontOfSize:13];
                theme stub_method(@selector(violationsCellTimeAndStatusFont)).and_return(violationsCellTimeAndStatusFont);

                violationsCellTimeAndStatusTextColor = [UIColor magentaColor];
                theme stub_method(@selector(violationsCellTimeAndStatusTextColor)).and_return(violationsCellTimeAndStatusTextColor);
            });

            __block Violation *hatViolation;
            __block ViolationEmployee *violationEmployee2;
            __block Waiver *hatWaiver;

            beforeEach(^{
                Violation *mealViolation = nice_fake_for([Violation class]);
                mealViolation stub_method(@selector(title)).and_return(@"Meal violation");
                mealViolation stub_method(@selector(severity)).and_return(ViolationSeverityError);

                ViolationEmployee *violationEmployee1 = nice_fake_for([ViolationEmployee class]);
                violationEmployee1 stub_method(@selector(name)).and_return(@"Roopesh");
                violationEmployee1 stub_method(@selector(violations)).and_return(@[mealViolation]);

                Violation *beardViolation = nice_fake_for([Violation class]);
                beardViolation stub_method(@selector(title)).and_return(@"Beard violation");
                beardViolation stub_method(@selector(severity)).and_return(ViolationSeverityWarning);

                hatViolation = nice_fake_for([Violation class]);
                hatViolation stub_method(@selector(title)).and_return(@"Hat violation");
                hatViolation stub_method(@selector(severity)).and_return(ViolationSeverityInfo);
                hatWaiver = fake_for([Waiver class]);

                hatWaiver stub_method(@selector(selectedOption)).and_return(nil);
                hatViolation stub_method(@selector(waiver)).and_return(hatWaiver);

                violationEmployee2 = nice_fake_for([ViolationEmployee class]);
                violationEmployee2 stub_method(@selector(name)).and_return(@"Wiley");
                violationEmployee2 stub_method(@selector(violations)).and_return(@[beardViolation, hatViolation]);

                ViolationSection *violationSection1 = [[ViolationSection alloc] initWithTitleObject:violationEmployee1
                                                                                         violations:@[mealViolation]
                                                                                               type:(ViolationSectionTypeEmployee)];
                ViolationSection *violationSection2 = [[ViolationSection alloc] initWithTitleObject:violationEmployee2
                                                                                         violations:@[beardViolation, hatViolation]
                                                                                               type:(ViolationSectionTypeEmployee)];

                violationSectionHeaderPresenter stub_method(@selector(sectionHeaderTextWithViolationSection:)).with(violationSection1).and_return(@"My Special Header for Roopesh");
                violationSectionHeaderPresenter stub_method(@selector(sectionHeaderTextWithViolationSection:)).with(violationSection2).and_return(@"My Special Header for Wiley");

                subject.tableView should_not be_nil;

                AllViolationSections *violationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:3 sections:@[violationSection1, violationSection2]];

                [violationSectionsDeferred resolveWithValue:violationSections];
            });

            it(@"should show the list of users with violations, 1 section per user", ^{
                [subject.tableView numberOfSections] should equal(2);
            });

            it(@"should use the section header presenter to present the section headers", ^{
                TeamSectionHeaderView *headerView0 = (TeamSectionHeaderView *)[subject.tableView.delegate tableView:subject.tableView viewForHeaderInSection:0];
                TeamSectionHeaderView *headerView1 = (TeamSectionHeaderView *)[subject.tableView.delegate tableView:subject.tableView viewForHeaderInSection:1];

                headerView0.sectionTitleLabel.text should equal(@"My Special Header for Roopesh");
                headerView1.sectionTitleLabel.text should equal(@"My Special Header for Wiley");
            });

            it(@"should style the section headers", ^{
                TeamSectionHeaderView *headerView0 = (TeamSectionHeaderView *)[subject.tableView.delegate tableView:subject.tableView viewForHeaderInSection:0];
                TeamSectionHeaderView *headerView1 = (TeamSectionHeaderView *)[subject.tableView.delegate tableView:subject.tableView viewForHeaderInSection:1];

                teamTableStylist should have_received(@selector(applyThemeToSectionHeaderView:)).with(headerView0);
                teamTableStylist should have_received(@selector(applyThemeToSectionHeaderView:)).with(headerView1);
            });

            it(@"should style the cells", ^{
                ViolationCell *cell = subject.tableView.visibleCells[0];

                cell.titleLabel.font should be_same_instance_as(violationsCellTitleFont);
                cell.titleLabel.textColor should be_same_instance_as(violationsCellTitleTextColor);
                cell.timeAndStatusLabel.font should be_same_instance_as(violationsCellTimeAndStatusFont);
                cell.timeAndStatusLabel.textColor should be_same_instance_as(violationsCellTimeAndStatusTextColor);
            });

            it(@"should show the violation titles in each row", ^{
                ViolationCell *cell0 = subject.tableView.visibleCells[0];
                ViolationCell *cell1 = subject.tableView.visibleCells[1];
                ViolationCell *cell2 = subject.tableView.visibleCells[2];

                cell0.titleLabel.text should equal(@"Meal violation");
                cell1.titleLabel.text should equal(@"Beard violation");
                cell2.titleLabel.text should equal(@"Hat violation");
            });

            it(@"should show the selected waiver option display text when it exists", ^{
                WaiverOption *waiverOption = fake_for([WaiverOption class]);
                waiverOption stub_method(@selector(displayText)).and_return(@"waiver option display text");
                hatWaiver stub_method(@selector(selectedOption)).again().and_return(waiverOption);

                ViolationCell *cell2 = subject.tableView.visibleCells[2];

                cell2.timeAndStatusLabel.text should equal(@"waiver option display text");
            });

            it(@"should show the default waiver option display text when it no selected waiver option exists", ^{
                ViolationCell *cell2 = subject.tableView.visibleCells[2];

                cell2.timeAndStatusLabel.text should equal(RPLocalizedString(@"No Response", @"No Response"));
            });

            it(@"should not show any waiver option display text when the violation has no waiver", ^{
                ViolationCell *cell1 = subject.tableView.visibleCells[1];

                cell1.timeAndStatusLabel.text should be_nil;
            });

            it(@"should show the violation icons in each row", ^{
                ViolationCell *cell0 = subject.tableView.visibleCells[0];
                ViolationCell *cell1 = subject.tableView.visibleCells[1];
                ViolationCell *cell2 = subject.tableView.visibleCells[2];

                cell0.severityImageView.image should be_same_instance_as(errorImage);
                cell1.severityImageView.image should be_same_instance_as(warningImage);
                cell2.severityImageView.image should be_same_instance_as(infoImage);
            });

            it(@"should make the cells with a waiver tappable", ^{
                ViolationCell *cell0 = subject.tableView.visibleCells[0];
                ViolationCell *cell1 = subject.tableView.visibleCells[1];

                cell0.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell0.accessoryType should equal(UITableViewCellAccessoryNone);

                cell1.selectionStyle should equal(UITableViewCellSelectionStyleNone);
                cell1.accessoryType should equal(UITableViewCellAccessoryNone);
            });

            it(@"should make cells without a waiver not tappable", ^{
                ViolationCell *cell2 = subject.tableView.visibleCells[2];
                cell2.selectionStyle should equal(UITableViewCellSelectionStyleDefault);
                cell2.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
            });

            describe(@"tapping on a cell with a waiver", ^{
                it(@"should push a waiver controller onto the navigation stack, passing in the relevant violation", ^{
                    ViolationCell *cell2 = subject.tableView.visibleCells[2];
                    [cell2 tap];

                    WaiverController *topController = (id)containingNavigationController.topViewController;
                    topController should be_instance_of([WaiverController class]);
                    topController.violation should be_same_instance_as(hatViolation);
                    topController.sectionTitle should equal(@"My Special Header for Wiley");
                    topController.delegate should be_same_instance_as(subject);
                });
            });

            describe(@"tapping on a cell without a waiver", ^{
                it(@"should not push a waiver controller onto the navigation stack", ^{
                    ViolationCell *cell1 = subject.tableView.visibleCells[1];
                    [cell1 tap];

                    containingNavigationController.topViewController should be_same_instance_as(subject);
                });
            });
        });
    });

    describe(@"as a <WaiverControllerDelegate>", ^{
        beforeEach(^{
            UIViewController *childController = [[UIViewController alloc] init];
            subject.view should_not be_nil;
            [containingNavigationController pushViewController:childController animated:NO];
        });

        describe(@"when an option for a waiver has been selected", ^{
            __block KSDeferred *violationSectionsDeferred;
            beforeEach(^{
                violationSectionsDeferred = [[KSDeferred alloc] init];
                delegate stub_method(@selector(violationsSummaryControllerDidRequestViolationSectionsPromise:))
                .with(subject)
                .and_return(violationSectionsDeferred.promise);

                [subject waiverController:nil didSelectWaiverOption:nil forWaiver:nil];
            });

            it(@"should pop back to the current view controller (removing the child controller)", ^{
                [containingNavigationController topViewController] should be_same_instance_as(subject);
            });

            it(@"should make a new network request for the violation sections", ^{
                delegate should have_received(@selector(violationsSummaryControllerDidRequestViolationSectionsPromise:)).with(subject);
            });

            it(@"should show the spinner", ^{
                spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });

            it(@"should temporarily empty the tableview", ^{
                subject.tableView.visibleCells should be_empty;
            });

            context(@"when fetching the new violation sections completes successfully", ^{
                __block AllViolationSections *newAllViolationSections;

                beforeEach(^{
                    Violation *anotherViolation = nice_fake_for([Violation class]);
                    anotherViolation stub_method(@selector(title)).and_return(@"a new violation");
                    anotherViolation stub_method(@selector(severity)).and_return(ViolationSeverityError);

                    WaiverOption *waiverOption = [[WaiverOption alloc] initWithDisplayText:@"yay" value:@"woo"];
                    Waiver *waiver = fake_for([Waiver class]);
                    waiver stub_method(@selector(selectedOption)).and_return(waiverOption);
                    anotherViolation stub_method(@selector(waiver)).and_return(waiver);

                    ViolationEmployee *violationEmployee = nice_fake_for([ViolationEmployee class]);
                    violationEmployee stub_method(@selector(name)).and_return(@"Sally");
                    violationEmployee stub_method(@selector(violations)).and_return(@[anotherViolation]);

                    newAllViolationSections = nice_fake_for([SupervisorDashboardSummary class]);
                    newAllViolationSections stub_method(@selector(employeesWithViolationsArray)).and_return(@[violationEmployee]);

                    ViolationSection *violationSection = [[ViolationSection alloc] initWithTitleObject:violationEmployee
                                                                                            violations:@[anotherViolation]
                                                                                                  type:(ViolationSectionTypeEmployee)];
                    newAllViolationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:1 sections:@[violationSection]];

                    [violationSectionsDeferred resolveWithValue:newAllViolationSections];
                });

                it(@"should reload the tableview with the data from the new violation sections", ^{
                    subject.tableView.visibleCells.count should equal(1);

                    ViolationCell *cell = subject.tableView.visibleCells.firstObject;
                    cell.titleLabel.text should equal(@"a new violation");
                    cell.timeAndStatusLabel.text should equal(@"yay");
                });

                it(@"should hide the spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should call delegate to update UI", ^{
                    delegate should have_received(@selector(violationsSummaryControllerDidRequestToUpdateUI:));
                });

            });

            context(@"when fetching the new violation sections fails", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [violationSectionsDeferred rejectWithError:error];
                });

                it(@"should hide the spinner", ^{
                    spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                });
                
                it(@"should call delegate to update UI", ^{
                    delegate should have_received(@selector(violationsSummaryControllerDidRequestToUpdateUI:));
                });

            });
        });
    });

    describe(@"as a screen inside a navigation controller", ^{
        beforeEach(^{
            containingNavigationController.navigationBarHidden = YES;
            [subject view];
            [subject viewWillAppear:NO];
        });

        it(@"should set the navigation bar title should be set", ^{
            NSString *expectedTitle = RPLocalizedString(@"Violations", @"Violations");
            subject.navigationItem.title should equal(expectedTitle);
        });

        it(@"should show the navigation bar", ^{
            containingNavigationController.navigationBarHidden should_not be_truthy;
        });
    });
});

SPEC_END
