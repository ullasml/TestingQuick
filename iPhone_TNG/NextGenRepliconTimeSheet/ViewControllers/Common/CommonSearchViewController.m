#import "CommonSearchViewController.h"
#import "Constants.h"
#import "Util.h"
#import "TimeoffModel.h"
#import "AppDelegate.h"
#import "SVPullToRefresh.h"
#import "ExpenseModel.h"
#import "ExpenseEntryViewController.h"
#import "RepliconServiceManager.h"
#import "DefaultTableViewCellStylist.h"
#import "SearchTextFieldStylist.h"
#import "RepliconServiceProvider.h"
#import <repliconkit/ReachabilityMonitor.h>


@interface CommonSearchViewController ()

@property (nonatomic) DefaultTableViewCellStylist *defaultTableViewCellStylist;
@property (nonatomic) RepliconServiceProvider *repliconServiceProvider;
@property (nonatomic) SearchTextFieldStylist *searchTextFieldStylist;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) id <SpinnerDelegate> spinnerDelegate;
@property (nonatomic, assign) BOOL shouldMoveScrollPositionToBottom;

@end


@implementation CommonSearchViewController
@synthesize listTableView;
@synthesize dataDict;
@synthesize listDataArray;
@synthesize delegate;
@synthesize searchTextField;
@synthesize searchTimer;
@synthesize isTextFieldFirstResponder;
@synthesize screenMode;
@synthesize selectedIndexpath;
@synthesize selectedName;
@synthesize sheetStatus;

#define searchBar_Height 44

- (instancetype)initWithDefaultTableViewCellStylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                            repliconServiceProvider:(RepliconServiceProvider *)repliconServiceProvider
                             searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                                reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                    spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
{
    self = [super init];
    if (self) {
        self.spinnerDelegate = spinnerDelegate;
        self.defaultTableViewCellStylist = defaultTableViewCellStylist;
        self.repliconServiceProvider = repliconServiceProvider;
        self.searchTextFieldStylist = searchTextFieldStylist;
        self.reachabilityMonitor = reachabilityMonitor;
    }

    return self;
}

#define SEARCH_POLL 0.2

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.translucent = NO;

    if (![self.reachabilityMonitor isNetworkReachable])
    {
        [Util showOfflineAlert];
        return;
    }

    if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
        [Util setToolbarLabel:self
                     withText:RPLocalizedString(ExpenseTypeOptionTitle, ExpenseTypeOptionTitle)];
        NSString *projectUri = [dataDict objectForKey:@"projectIdentity"];
        if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]] || [projectUri isEqualToString:NULL_STRING] || [projectUri isEqualToString:@""]) {
            projectUri = nil;
        }
        NSString *expenseSheetUri = [dataDict objectForKey:@"expenseSheetUri"];
        self.selectedName = [dataDict objectForKey:@"expenseTypeName"];
        self.sheetStatus = [dataDict objectForKey:@"expenseSheetStatus"];


        [self.spinnerDelegate showTransparentLoadingOverlay];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(createListData)
                                                     name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                   object:nil];


        [[self.repliconServiceProvider provideExpenseService] fetchExpenseCodesBasedOnProjectsForExpenseSheetUri:expenseSheetUri
                                                                                                  withSearchText:@""
                                                                                                  withProjectUri:projectUri
                                                                                                     andDelegate:self];


    }

    UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(CANCEL_STRING, @"")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(cancelAction:)];
    BOOL editable = YES;
    if (([sheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] || ([sheetStatus isEqualToString:APPROVED_STATUS]))) {
        editable = NO;
    }

    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Done_Button_Title, @"")
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(doneAction:)];

    if (editable) {
        [self navigationItem].rightBarButtonItem = tempRightButtonOuterBtn;
    }
    else {
        [self navigationItem].rightBarButtonItem = nil;
    }

    [[self navigationItem] setLeftBarButtonItem:tempLeftButtonOuterBtn
                                       animated:NO];

    if (self.selectedName == nil || [self.selectedName isEqualToString:@""] || [self.selectedName isKindOfClass:[NSNull class]]) {
        [[self navigationItem].rightBarButtonItem setEnabled:NO];
    }


    [self initializeView];
}

- (void)createListData {

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DROPDOWN_OPTION_RECEIVED_NOTIFICATION
                                                  object:nil];
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    ExpenseModel *expenseModel = [[ExpenseModel alloc] init];
    self.listDataArray = [expenseModel getExpenseCodesFromDatabase];
    [self.listTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                   animated:NO];
    [self checkToShowMoreButton];
    [self.listTableView setBottomContentInsetValue:0.0];

    [self.listTableView reloadData];

    [self fetchMoreDataInBackgroundToFillTableView];

}

- (void)fetchMoreDataInBackgroundToFillTableView {

    float tableViewContentSizeHeight = self.listTableView.contentSize.height;
    float viewHeight = self.view.frame.size.height;

    int moreActionTriggerIndex = [[self getExpenseCodeDownLoadCount] intValue] - 1;
    NSUInteger listArrIndex = [self.listDataArray count] - 1;

    if(tableViewContentSizeHeight < viewHeight && listArrIndex == moreActionTriggerIndex && [self isMoreDataAvailable]) {
        self.shouldMoveScrollPositionToBottom = FALSE;
        [self moreAction];
    }
}

- (void)initializeView {
    UITextField *tempsearchBar = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchBar_Height)];
    self.searchTextField = tempsearchBar;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.searchTextFieldStylist applyThemeToTextField:self.searchTextField];

    [self.view addSubview:self.searchTextField];

    float xPadding = 10.0;
    float paddingFromSearchIconToPlaceholder = 10.0;
    UIImage *searchIconImage = [Util thumbnailImage:SEARCH_ICON_IMAGE];
    UIImageView *searchIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPadding, 14, searchIconImage.size.width, searchIconImage.size.height)];
    [searchIconImageView setImage:searchIconImage];
    [searchIconImageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:searchIconImageView];


    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, xPadding + searchIconImage.size.width + paddingFromSearchIconToPlaceholder, 20)];
    searchTextField.leftView = paddingView;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;

    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchTextField.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
    [searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [searchTextField setDelegate:self];
    [searchTextField setReturnKeyType:UIReturnKeyDone];
    [searchTextField setEnablesReturnKeyAutomatically:NO];
    searchTextField.placeholder = RPLocalizedString(SEARCH_EXPENSE_TYPE_LABEL, @"");

    if (([sheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] || ([sheetStatus isEqualToString:APPROVED_STATUS]))) {
        [searchTextField setUserInteractionEnabled:NO];
    }

    UIImage *separtorImage = [Util thumbnailImage:TOP_SEPARATOR];

    UIImageView *separatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, searchBar_Height - separtorImage.size.height, self.view.frame.size.width, 1)];
    [separatorView setImage:separtorImage];
    [self.view addSubview:separatorView];


    if (listTableView == nil) {
        UITableView *temptimeSheetsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, searchBar_Height, self.view.frame.size.width, [self heightForTableView] - 50)
                                                                            style:UITableViewStylePlain];
        self.listTableView = temptimeSheetsTableView;

    }
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.separatorColor = [Util colorWithHex:@"#cccccc"
                                                     alpha:1];
    self.listTableView.rowHeight = UITableViewAutomaticDimension;
    self.listTableView.estimatedRowHeight = 50;
    [self.view addSubview:listTableView];

    [self configureTableForPullToRefresh];
    [self.listTableView setBottomContentInsetValue:0.0];

    if ([self.listTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.listTableView.layoutMargins = UIEdgeInsetsZero;
    }

    if ([self.listTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.listTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (CGFloat)heightForTableView
{
    static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 2.0f;
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame)) +
    paddingForLastCellBottomSeparatorFudgeFactor;
}




- (void)configureTableForPullToRefresh {
    CommonSearchViewController *weakSelf = self;


    //setup pull to refresh widget
    [self.listTableView addPullToRefreshWithActionHandler:^{

        int64_t delayInSeconds = 0.0;
        [weakSelf.listTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

            [weakSelf refreshAction];//Fix for MOBI-79//JUHI


        });
    }];

    // setup infinite scrolling
    [self.listTableView addInfiniteScrollingWithActionHandler:^{


        [weakSelf.listTableView setBottomContentInsetValue:60.0];//Fix for MOBI-79//JUHI


        int64_t delayInSeconds = 0.0;
        [weakSelf.listTableView.infiniteScrollingView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

            [weakSelf moreAction];//Fix for MOBI-79//JUHI



        });
    }];

}

- (void)refreshAction {
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        [self.view setUserInteractionEnabled:YES];
        CommonSearchViewController *weakSelf = self;
        [weakSelf.listTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
        NSString *projectUri = [dataDict objectForKey:@"projectIdentity"];
        if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]] || [projectUri isEqualToString:NULL_STRING] || [projectUri isEqualToString:@""]) {
            projectUri = nil;
        }
        NSString *expenseSheetUri = [dataDict objectForKey:@"expenseSheetUri"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshViewAfterPullToRefreshAction:)
                                                     name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                   object:nil];


        [[self.repliconServiceProvider provideExpenseService] fetchExpenseCodesBasedOnProjectsForExpenseSheetUri:expenseSheetUri
                                                                                                  withSearchText:searchTextField.text
                                                                                                  withProjectUri:projectUri
                                                                                                     andDelegate:self];
    }
}

- (void)refreshViewAfterPullToRefreshAction:(NSNotification *)notificationObject {
    [self.view setUserInteractionEnabled:YES];
    if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                      object:nil];

    }

    CommonSearchViewController *weakSelf = self;
    [weakSelf.listTableView.pullToRefreshView stopAnimating];
    self.listTableView.showsInfiniteScrolling = TRUE;
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured) {

    }
    else {
        [self createListData];
        [self checkToShowMoreButton];

    }

    [self.listTableView setBottomContentInsetValue:0.0];

}

- (void)moreAction {
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
        [Util showOfflineAlert];
        [self performSelector:@selector(refreshTableViewOnConnectionError)
                   withObject:nil
                   afterDelay:0.2];
    }
    if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
        NSString *projectUri = [dataDict objectForKey:@"projectIdentity"];
        if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]] || [projectUri isEqualToString:NULL_STRING] || [projectUri isEqualToString:@""]) {
            projectUri = nil;
        }
        NSString *expenseSheetUri = [dataDict objectForKey:@"expenseSheetUri"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshViewAfterMoreAction:)
                                                     name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                   object:nil];


        [[self.repliconServiceProvider provideExpenseService] fetchNextExpenseCodesBasedOnProjectsForExpenseSheetUri:expenseSheetUri
                                                                                                      withSearchText:searchTextField.text
                                                                                                      withProjectUri:projectUri
                                                                                                         andDelegate:self];
    }
}

- (void)refreshTableViewOnConnectionError {
    CommonSearchViewController *weakSelf = self;
    [weakSelf.listTableView.infiniteScrollingView stopAnimating];

    self.listTableView.showsInfiniteScrolling = FALSE;
    self.listTableView.showsInfiniteScrolling = TRUE;

}

- (void)refreshViewAfterMoreAction:(NSNotification *)notificationObject {
    if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                      object:nil];

    }

    [self.view setUserInteractionEnabled:YES];
    CommonSearchViewController *weakSelf = self;
    [weakSelf.listTableView.infiniteScrollingView stopAnimating];

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];


    BOOL isErrorOccured = [n boolValue];

    if (isErrorOccured) {
        self.listTableView.showsInfiniteScrolling = FALSE;
    }
    else {

        [self createListData];
        [self checkToShowMoreButton];
    }

    [self moveScrollPositionToBottom];
}


- (void)moveScrollPositionToBottom {

    if(!self.shouldMoveScrollPositionToBottom || [self.listDataArray count] == 0) {
        self.shouldMoveScrollPositionToBottom = TRUE;
        return;
    }

    [self.listTableView setBottomContentInsetValue:0.0];
    [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.listDataArray count] -1
                                                                  inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
}

- (void)checkToShowMoreButton {
    NSNumber *count = nil;
    NSNumber *fetchCount = nil;

    if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
        count = [[NSUserDefaults standardUserDefaults] objectForKey:@"totalExpenseCodeCount"];
        fetchCount = [[AppProperties getInstance] getAppPropertyFor:@"expenseCodesDownloadCount"];
    }

    if (([count intValue] < [fetchCount intValue])) {
        self.listTableView.showsInfiniteScrolling = FALSE;
    }
    else {
        self.listTableView.showsInfiniteScrolling = TRUE;
    }

    if ([self.listDataArray count] == 0) {
        self.listTableView.showsPullToRefresh = TRUE;
        self.listTableView.showsInfiniteScrolling = FALSE;
    }
    else {
        self.listTableView.showsPullToRefresh = TRUE;
    }

}

- (void)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)doneAction:(id)sender {
    if ([delegate isKindOfClass:[ExpenseEntryViewController class]]) {
        ExpenseEntryViewController *ctrl = (ExpenseEntryViewController *) delegate;
        if ([listDataArray count] > 0 && self.selectedIndexpath.row <[listDataArray count]) {
            NSString *name = [[self.listDataArray objectAtIndex:selectedIndexpath.row] objectForKey:@"expenseCodeName"];
            NSString *uri = [[self.listDataArray objectAtIndex:selectedIndexpath.row] objectForKey:@"expenseCodeUri"];
            [ctrl updateTypeOnPickerSelectionWithTypeName:name
                                              withTypeUri:uri];
        }

        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

    NSInteger count = [self.listDataArray count];
    if (count < 1) {
        return 1;
    }
    return [self.listDataArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"Cell";
    cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    NSString *name = @"";
    NSInteger count = [self.listDataArray count];

    if (count > 0) {
        name = [[self.listDataArray objectAtIndex:indexPath.row] objectForKey:@"expenseCodeName"];

    }
    else {
        name = RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }

    cell.textLabel.text = name;
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if ([self.selectedName isEqualToString:name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedIndexpath = indexPath;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    if (([sheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] || ([sheetStatus isEqualToString:APPROVED_STATUS]))) {
        [cell setUserInteractionEnabled:NO];
    }


    [self.defaultTableViewCellStylist applyThemeToCell:cell];

    return cell;
}


- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedName = [[self.listDataArray objectAtIndex:indexPath.row] objectForKey:@"expenseCodeName"];

    if (self.selectedIndexpath != nil) {
        UITableViewCell *previousCell = (UITableViewCell *) [listTableView cellForRowAtIndexPath:selectedIndexpath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *selectedCell = (UITableViewCell *) [listTableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedIndexpath = indexPath;
    [[self navigationItem].rightBarButtonItem setEnabled:YES];

}

#pragma mark -
#pragma mark Search Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.listTableView.scrollEnabled = YES;
}

- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                             withString:string];
    NSString *textStr = [textField text];
    if (textStr == nil || [textStr isEqualToString:@""] || [textStr isKindOfClass:[NSNull class]]) {
        self.isTextFieldFirstResponder = FALSE;
    }
    else {
        self.isTextFieldFirstResponder = TRUE;
    }
    self.listTableView.scrollEnabled = YES;
    if ([self.searchTimer isValid]) {
        [self.searchTimer invalidate];

    }
    if (self.selectedName != nil && ![self.selectedName isKindOfClass:[NSNull class]] && ![self.selectedName isEqualToString:@""]) {
        [[self navigationItem].rightBarButtonItem setEnabled:YES];
    }
    else {
        [[self navigationItem].rightBarButtonItem setEnabled:NO];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text
                 forKey:@"SearchString"];
    [defaults synchronize];

    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchDataWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [searchTextField resignFirstResponder];
    self.listTableView.scrollEnabled = YES;

    if ([self.searchTimer isValid]) {
        [self.searchTimer invalidate];

    }

}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    self.isTextFieldFirstResponder = FALSE;
    self.listTableView.scrollEnabled = YES;
    if ([self.searchTimer isValid]) {
        [self.searchTimer invalidate];

    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text
                 forKey:@"SearchString"];
    [defaults synchronize];

    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchDataWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];
    return YES;
}

- (void)fetchDataWithSearchText {

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
        [Util showOfflineAlert];
    }
    else {
        if (screenMode == EXPENSE_TYPE_SEARCH_SCREEN) {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
                [Util showOfflineAlert];
                return;
            }
            UIApplication *app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;
            NSString *projectUri = [dataDict objectForKey:@"projectIdentity"];
            if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]] || [projectUri isEqualToString:NULL_STRING] || [projectUri isEqualToString:@""]) {
                projectUri = nil;
            }
            NSString *expenseSheetUri = [dataDict objectForKey:@"expenseSheetUri"];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(createListData)
                                                         name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                       object:nil];


            [[self.repliconServiceProvider provideExpenseService] fetchExpenseCodesBasedOnProjectsForExpenseSheetUri:expenseSheetUri
                                                                                                      withSearchText:searchTextField.text
                                                                                                      withProjectUri:projectUri
                                                                                                         andDelegate:self];


        }


    }

    [self.searchTimer invalidate];
}

#pragma mark ScrollView Delegate

- (BOOL)isMoreDataAvailable {
    NSNumber *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"totalExpenseCodeCount"];
    NSNumber *fetchCount = [self getExpenseCodeDownLoadCount];

    if([count intValue] < [fetchCount intValue]) {
        return FALSE;
    }

    return TRUE;
}

- (NSNumber *)getExpenseCodeDownLoadCount {
    return [[AppProperties getInstance] getAppPropertyFor:@"expenseCodesDownloadCount"];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.listTableView.delegate = nil;
    self.listTableView.dataSource = nil;
}

@end
