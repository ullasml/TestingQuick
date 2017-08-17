#import <Cedar/Cedar.h>
#import "ListOfExpenseSheetsViewController.h"
#import "ExpenseModel.h"
#import "ExpenseService.h"
#import "SpinnerDelegate.h"
#import "SVPullToRefresh.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ListOfExpenseSheetsViewControllerSpec)

describe(@"ListOfExpenseSheetsViewController", ^{
    __block ListOfExpenseSheetsViewController *subject;
    __block ExpenseModel *fakeExpenseModel;
    __block ExpenseService *fakeExpenseService;
    __block id<SpinnerDelegate> fakeSpinnerDelegate;
    __block NSUserDefaults *userDefaults;
    __block NSNotificationCenter *notificationCenter;

    beforeEach(^{
        fakeExpenseModel = nice_fake_for([ExpenseModel class]);
        fakeExpenseService = nice_fake_for([ExpenseService class]);
        fakeSpinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        userDefaults = [[NSUserDefaults alloc] init];
        notificationCenter = [[NSNotificationCenter alloc] init];
        spy_on(notificationCenter);

        subject = [[ListOfExpenseSheetsViewController alloc] initWithDefaultTableViewCellStylist:nil
                                                                          searchTextFieldStylist:nil
                                                                              notificationCenter:notificationCenter
                                                                                 spinnerDelegate:fakeSpinnerDelegate
                                                                                  expenseService:fakeExpenseService
                                                                                    expenseModel:fakeExpenseModel
                                                                                    userDefaults:userDefaults];

        subject.view should_not be_nil;
    });

    describe(@"when the view will appear", ^{
        context(@"and there are expenses cached", ^{
            beforeEach(^{
                fakeExpenseModel stub_method(@selector(getAllExpenseSheetsFromDB)).and_return(@[@{}]);
                [subject viewWillAppear:NO];
            });

            it(@"should show those expenses", ^{
                subject.expenseSheetsTableView.visibleCells.count should equal(1);
            });

            it(@"should not fetch the expenses from the expense service", ^{
                fakeExpenseService should_not have_received(@selector(fetchExpenseSheetData:));
            });
        });

        context(@"and there are no expenses cached", ^{
            beforeEach(^{
                fakeExpenseModel stub_method(@selector(getAllExpenseSheetsFromDB)).and_return(@[]);
                [subject viewWillAppear:NO];
            });

            it(@"should fetch the expenses from the expense service", ^{
                fakeExpenseService should have_received(@selector(fetchExpenseSheetData:)).with(nil);
            });

            it(@"should start the spinner", ^{
                fakeSpinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
            });

            describe(@"when an AllExpenseSheetRequestsServed notification is then posted", ^{
                context(@"when an expense sheet is available", ^{
                    beforeEach(^{
                        // The decision to disable infinite scrolling is made by referencing
                        // the number of expense sheets downloaded from user defaults,
                        // NOT the count of the expense sheets returned to the view controller.
                        [userDefaults setObject:@1 forKey:@"ExpenseDownloadCount"];
                    });

                    beforeEach(^{
                        subject.expenseSheetsTableView.showsInfiniteScrolling = YES;
                    });

                    beforeEach(^{
                        fakeExpenseModel stub_method(@selector(getAllExpenseSheetsFromDB)).again().and_return(@[@{ @"description": @"This is a description" }]);
                    });

                    beforeEach(^{
                        [notificationCenter postNotificationName:AllExpenseSheetRequestsServed object:nil];
                    });

                    it(@"should unsubscribe from AllExpenseSheetRequestsServed notifications", ^{
                        notificationCenter should have_received(@selector(removeObserver:name:object:)).with(subject, AllExpenseSheetRequestsServed, nil);
                    });

                    it(@"should stop the spinner", ^{
                        fakeSpinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should disable infinite scrolling", ^{
                        subject.expenseSheetsTableView.showsInfiniteScrolling should be_falsy;
                    });

                    it(@"should update the content of the table", ^{
                        subject.expenseSheetsTableView.visibleCells.count should equal(1);
                        UITableViewCell *cell = [subject.expenseSheetsTableView.visibleCells firstObject];

                        UILabel *upperLeftLabel = [cell.contentView.subviews firstObject];
                        upperLeftLabel.text should equal(@"This is a description");
                    });
                });

                context(@"when an expense sheet is not available", ^{
                    beforeEach(^{
                        // The decision to disable infinite scrolling is made by referencing
                        // the number of expense sheets downloaded from user defaults,
                        // NOT the count of the expense sheets returned to the view controller.
                        [userDefaults setObject:@0 forKey:@"ExpenseDownloadCount"];
                    });

                    beforeEach(^{
                        fakeExpenseService stub_method(@selector(didSuccessfullyFetchExpenses)).and_return(YES);
                    });

                    beforeEach(^{
                        [notificationCenter postNotificationName:AllExpenseSheetRequestsServed object:nil];
                    });

                    it(@"should display a no expenses available message", ^{
                        subject.msgLabel.text should equal(RPLocalizedString(_NO_EXPENSES_AVAILABLE, _NO_EXPENSES_AVAILABLE));

                        [subject.msgLabel isDescendantOfView:subject.view] should be_truthy;
                    });

                    describe(@"and the view is subsequently shown again", ^{
                        context(@"and the expense service has not yet finished fetching expenses", ^{
                            beforeEach(^{
                                fakeExpenseService stub_method(@selector(didSuccessfullyFetchExpenses)).again().and_return(NO);
                            });

                            beforeEach(^{
                                [subject viewWillAppear:NO];
                            });

                            it(@"should remove the no expenses available message", ^{
                                [subject.msgLabel isDescendantOfView:subject.view] should be_falsy;
                            });
                        });

                        context(@"and the expense service completes its request and a expense is available", ^{
                            beforeEach(^{
                                fakeExpenseService stub_method(@selector(didSuccessfullyFetchExpenses)).again().and_return(YES);
                            });

                            beforeEach(^{
                                fakeExpenseModel stub_method(@selector(getAllExpenseSheetsFromDB)).again().and_return(@[@{}]);
                            });

                            beforeEach(^{
                                [subject viewWillAppear:NO];
                            });

                            it(@"should remove the no expenses available message", ^{
                                [subject.msgLabel isDescendantOfView:subject.view] should be_falsy;
                            });
                        });
                    });
                });
            });
        });
    });
});

SPEC_END
