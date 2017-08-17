#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "CommonSearchViewController.h"
#import "DefaultTableViewCellStylist.h"
#import "SearchTextFieldStylist.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CommonSearchViewControllerSpec)

describe(@"CommonSearchViewController", ^{
    __block DefaultTableViewCellStylist *defaultTableViewCellStylist;
    __block SearchTextFieldStylist *searchTextFieldStylist;
    __block CommonSearchViewController *subject;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block NSNotificationCenter *notificationCenter;

    beforeEach(^{
        defaultTableViewCellStylist = fake_for([DefaultTableViewCellStylist class]);
        defaultTableViewCellStylist stub_method(@selector(applyThemeToCell:));

        searchTextFieldStylist = fake_for([SearchTextFieldStylist class]);
        searchTextFieldStylist stub_method(@selector(applyThemeToTextField:));

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);

        notificationCenter = [NSNotificationCenter defaultCenter];


        subject = [[CommonSearchViewController alloc] initWithDefaultTableViewCellStylist:defaultTableViewCellStylist
                                                                  repliconServiceProvider:nil
                                                                   searchTextFieldStylist:searchTextFieldStylist
                                                                      reachabilityMonitor:reachabilityMonitor
                                                                          spinnerDelegate:nil];
        spy_on(subject);
        spy_on(notificationCenter);
    });

    describe(NSStringFromProtocol(@protocol(UITableViewDataSource)), ^{
        describe(NSStringFromSelector(@selector(tableView:cellForRowAtIndexPath:)), ^{
            __block UITableViewCell *returnedCell;

            beforeEach(^{
                UITableView *tableView = [[UITableView alloc] init];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

                returnedCell = [subject tableView:tableView cellForRowAtIndexPath:indexPath];
            });

            it(@"should use the default table view stylist on the returned cell", ^{
                defaultTableViewCellStylist should have_received(@selector(applyThemeToCell:)).with(returnedCell);
            });
        });
    });

    describe(@"styling its subviews", ^{
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

            [subject view];
            [subject viewWillAppear:NO];
        });

        it(@"should use the search text field stylist to style its search text field", ^{
            searchTextFieldStylist should have_received(@selector(applyThemeToTextField:)).with(subject.searchTextField);
        });
    });

    describe(@"For bigger devices, when screen size is bigger and when tableview can fit more data", ^{

        context(@"When number of data covers the entire tableview (ie) when tableview content size is greater than or equal to view height", ^{

            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                NSDictionary *dic1 = [NSDictionary dictionaryWithObjects:@[@"1 Flat no tax",@"urn:replicon-tenant:repliconiphone-2:expense-code:52"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic2 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic3 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic4 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                NSDictionary *dic5 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic6 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic7 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic8 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic9 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic10 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic11 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic12 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic13 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic14 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic15 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic16 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                NSMutableArray *listArr = [[NSMutableArray alloc] initWithArray:@[dic1, dic2, dic3, dic4, dic5, dic6, dic7, dic8, dic9, dic10, dic11, dic12, dic13, dic14, dic15, dic16]];

                subject stub_method(@selector(listDataArray)).and_return(listArr);
                subject stub_method(@selector(isMoreDataAvailable)).and_return(YES);

                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should not trigger more data fetch", ^{
                [NSNotificationCenter defaultCenter] should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(createListData), EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION, nil);

                [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                subject should have_received(@selector(createListData));
            });

            afterEach(^{
                [[NSNotificationCenter defaultCenter] removeObserver:subject name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            });

        });


        context(@"When number of data does not cover the entire the tableview (ie) when tableview content size is less than view height", ^{

            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                NSDictionary *dic1 = [NSDictionary dictionaryWithObjects:@[@"1 Flat no tax",@"urn:replicon-tenant:repliconiphone-2:expense-code:52"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic2 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic3 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic4 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                NSDictionary *dic5 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic6 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic7 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic8 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic9 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic10 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                NSMutableArray *listArr = [[NSMutableArray alloc] initWithArray:@[dic1, dic2, dic3, dic4, dic5, dic6, dic7, dic8, dic9, dic10]];

                subject stub_method(@selector(listDataArray)).and_return(listArr);

                subject stub_method(@selector(isMoreDataAvailable)).and_return(YES);

                [subject view];
                [subject viewWillAppear:NO];
            });

            it(@"should trigger more data fetch", ^{
                [NSNotificationCenter defaultCenter] should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(createListData), EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION, nil);

                [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                subject should have_received(@selector(createListData));
                subject.listTableView.contentSize.height should be_less_than(subject.view.frame.size.height);
                subject should have_received(@selector(moreAction));
                subject.shouldMoveScrollPositionToBottom should be_falsy;
            });

            afterEach(^{
                [[NSNotificationCenter defaultCenter] removeObserver:subject name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            });

        });

    });

    describe(@"When more action is triggered", ^{
        __block NSMutableArray *listArr;

        context(@"Notification is received and should scroll to bottom", ^{

            beforeEach(^{

                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                NSDictionary *dic1 = [NSDictionary dictionaryWithObjects:@[@"1 Flat no tax",@"urn:replicon-tenant:repliconiphone-2:expense-code:52"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic2 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic3 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic4 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                NSDictionary *dic5 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic6 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic7 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic8 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic9 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic10 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic11 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic12 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic13 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic14 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic15 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic16 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                listArr = [[NSMutableArray alloc] initWithArray:@[dic1, dic2, dic3, dic4, dic5, dic6, dic7, dic8, dic9, dic10, dic11, dic12, dic13, dic14, dic15, dic16]];

                subject stub_method(@selector(listDataArray)).and_return(listArr);
                subject stub_method(@selector(isMoreDataAvailable)).and_return(YES);

                subject stub_method(@selector(shouldMoveScrollPositionToBottom)).and_return(YES);

                [subject view];

                [subject viewWillAppear:NO];

                spy_on(subject.listTableView);

                [[NSNotificationCenter defaultCenter] removeObserver:subject name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];

                [subject moreAction];


            });

            it(@"should display data on tableview and Scroll to Bottom", ^{

                [NSNotificationCenter defaultCenter] should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(refreshViewAfterMoreAction:), EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION, nil);

                [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                
                subject should have_received(@selector(refreshViewAfterMoreAction:));

                subject.listTableView should have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with([NSIndexPath indexPathForRow:[listArr count] -1
                                                                                                                                                 inSection:0], UITableViewScrollPositionBottom, NO);
            });

            afterEach(^{
                [[NSNotificationCenter defaultCenter] removeObserver:subject name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            });

        });


        context(@"Notification is received and should not scroll to bottom ", ^{

            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);

                NSDictionary *dic1 = [NSDictionary dictionaryWithObjects:@[@"1 Flat no tax",@"urn:replicon-tenant:repliconiphone-2:expense-code:52"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic2 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic3 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic4 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                NSDictionary *dic5 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic6 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic7 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic8 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic9 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];
                NSDictionary *dic10 = [NSDictionary dictionaryWithObjects:@[@"11",@"urn:replicon-tenant:repliconiphone-2:expense-code:53"] forKeys:@[@"expenseCodeName", @"expenseCodeUri"]];

                listArr = [[NSMutableArray alloc] initWithArray:@[dic1, dic2, dic3, dic4, dic5, dic6, dic7, dic8, dic9, dic10]];

                subject stub_method(@selector(listDataArray)).and_return(listArr);

                subject stub_method(@selector(shouldMoveScrollPositionToBottom)).and_return(NO);
                subject stub_method(@selector(isMoreDataAvailable)).and_return(YES);

                [subject view];

                [subject viewWillAppear:NO];

                spy_on(subject.listTableView);

                [[NSNotificationCenter defaultCenter] removeObserver:subject name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];

                [subject moreAction];

            });
            
            it(@"should display data on tableview and Scroll to Bottom", ^{

                [NSNotificationCenter defaultCenter] should have_received(@selector(addObserver:selector:name:object:)).with(subject, @selector(refreshViewAfterMoreAction:), EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION, nil);

                [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];

                subject should have_received(@selector(refreshViewAfterMoreAction:));

                subject.listTableView should_not have_received(@selector(scrollToRowAtIndexPath:atScrollPosition:animated:)).with([NSIndexPath indexPathForRow:[listArr count] -1
                                                                                                                                                 inSection:0], UITableViewScrollPositionBottom, NO);
            });

            afterEach(^{
                [[NSNotificationCenter defaultCenter] removeObserver:subject name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            });
            
        });
    });
});

SPEC_END
