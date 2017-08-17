
#import "SelectionController.h"
#import <KSDeferred/KSPromise.h>
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "TimerProvider.h"
#import "PunchCardObject.h"
#import "Theme.h"
#import "SizeCell.h"
#import "ClientProjectTaskRepository.h"
#import "ClientRepositoryProtocol.h"
#import "ProjectRepositoryProtocol.h"
#import "TaskRepositoryProtocol.h"
#import "ActivityRepositoryProtocol.h"
#import "Activity.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "ProjectStorage.h"
#import "ExpenseProjectStorage.h"


@interface SelectionController ()
@property (nonatomic,assign)SelectionScreenType selectionScreenType;
@property (nonatomic) NSMutableArray *values;
@property (nonatomic) id <SelectionControllerDelegate> delegate;
@property (nonatomic) ProjectStorage *projectStorage;
@property (nonatomic) ExpenseProjectStorage *expenseProjectStorage;
@property (nonatomic) TimerProvider *timerProvider;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) PunchCardObject *punchCardObject;
@property (nonatomic) id <ClientProjectTaskRepository> clientProjectTaskRepository;

@property (nonatomic) id <ClientRepositoryProtocol> clientRepository;
@property (nonatomic) id <ProjectRepositoryProtocol> projectRepository;
@property (nonatomic) id <TaskRepositoryProtocol> taskRepository;
@property (nonatomic) id <ActivityRepositoryProtocol> activityRepository;
@property (nonatomic) OEFDropDownRepository *oefDropdownRepository;

@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSTimer *searchTimer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) ProjectStorageFlowType projectStorageFlowType;

@end

NSString *const CellIdentifier = @"SizeCustomCell";

@implementation SelectionController

- (instancetype)initWithProjectStorage:(ProjectStorage *)projectStorage
                 expenseProjectStorage:(ExpenseProjectStorage *)expenseProjectStorage
                         timerProvider:(TimerProvider *)timerProvider
                          userDefaults:(NSUserDefaults *)userDefaults
                                 theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.projectStorage = projectStorage;
        self.expenseProjectStorage = expenseProjectStorage;
        self.timerProvider = timerProvider;
        self.userDefaults = userDefaults;
        self.theme = theme;
    }
    self.values = [[NSMutableArray alloc] init];
    return self;
}

-(void)setUpWithSelectionScreenType:(SelectionScreenType)selectionScreenType
                    punchCardObject:(PunchCardObject *)punchCardObject
                           delegate:(id <SelectionControllerDelegate>)delegate;
{
    self.punchCardObject = punchCardObject;
    self.selectionScreenType = selectionScreenType;
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.searchBar setReturnKeyType:UIReturnKeyDone];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SizeCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self configureTableForPullToRefresh];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.searchBar.placeholder = [self setPlaceholderTextForSearchBar];
    self.title = [self titleForScreen];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.clientProjectTaskRepository = [self.delegate selectionControllerNeedsClientProjectTaskRepository];
    self.clientRepository = self.clientProjectTaskRepository.clientRepository;
    self.projectRepository = self.clientProjectTaskRepository.projectRepository;
    self.taskRepository = self.clientProjectTaskRepository.taskRepository;
    self.activityRepository = self.clientProjectTaskRepository.activityRepository;
    if ([self.delegate respondsToSelector:@selector(selectionControllerNeedsOEFDropDownRepository)])
    {
        self.oefDropdownRepository = [self.delegate selectionControllerNeedsOEFDropDownRepository];
    }


    KSPromise *promise = [self fetchFreshRecords];
    [self reloadTableViewWithPromise:promise];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.values.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SizeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.valueLabel.text = [self cellTextForRow:indexPath.row];
    cell.valueLabel.font = [self.theme cellFont];
    cell.valueLabel.numberOfLines = 0;
    return cell;
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updatePunchCardFromDataSelectedOnIndexpath:indexPath];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.enablesReturnKeyAutomatically = NO;
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    KSPromise *cachedPromise = [self fetchCachedRecordsMatchingText:searchText];
    [self reloadTableViewWithPromise:cachedPromise];

    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }

    [self.userDefaults setObject:searchText forKey:RequestMadeForSearchWithValue];
    [self.userDefaults synchronize];

    self.searchTimer=  [self.timerProvider scheduledTimerWithTimeInterval:0.2
                                                                   target:self
                                                                 selector:@selector(fetchDataAfterDelayFromTimer:)
                                                                 userInfo:searchText
                                                                  repeats:NO];




}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

}

#pragma mark - <SVPullToRefresh>

-(void)configureTableForPullToRefresh
{
    SelectionController *weakSelf = self;

    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf.tableView.pullToRefreshView startAnimating];
        [weakSelf refreshAction];
    }];

    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.tableView.infiniteScrollingView startAnimating];
        [weakSelf moreAction];
    }];

}


-(void)refreshAction
{
    [self setPlaceholderTextForSearchBar];
    self.tableView.showsInfiniteScrolling=TRUE;
    SelectionController *weakSelf = self;
    KSPromise *promise = [self fetchFreshRecordsPromise];
    [self reloadTableViewWithPromise:promise];
    [promise then:^id(NSDictionary *valueDictionary) {
        [weakSelf.tableView.pullToRefreshView stopAnimating];
        return nil;
    } error:^id(NSError *error) {
        [weakSelf.tableView.pullToRefreshView stopAnimating];
        return nil;
    }];

}

-(void)moreAction
{
    SelectionController *weakSelf = self;
    KSPromise *promise = [self fetchMoreRecordsPromise];
    [self reloadTableViewWithPromise:promise];
    [promise then:^id(NSDictionary *valueDictionary) {
        NSInteger latestDownloadCount = [valueDictionary[@"downloadCount"] integerValue];
        [self decideToShowOrHideInfiniteScrollingForFetchCount:latestDownloadCount];
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
        return nil;
    } error:^id(NSError *error) {
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
        return nil;
    }];
}



#pragma mark - Private

-(NSString *)titleForScreen
{
    switch (self.selectionScreenType) {
        case ClientSelection:
            return RPLocalizedString(@"Select a Client", nil);
            break;
        case ProjectSelection:
            return RPLocalizedString(@"Select a Project", nil);
            break;
        case TaskSelection:
            return RPLocalizedString(@"Select a Task", nil);
            break;
        case ActivitySelection:
            return RPLocalizedString(@"Select an Activity", nil);
            break;
        case OEFDropDownSelection:
            return RPLocalizedString(@"Select OEF Dropdown Options", nil);
            break;

        default:
            break;
    }
    return nil;
}

-(NSString *)setPlaceholderTextForSearchBar
{
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    switch (self.selectionScreenType) {
        case ClientSelection:
            return RPLocalizedString(@"Search Client", nil);
            break;
        case ProjectSelection:
            return RPLocalizedString(@"Search Project", nil);
            break;
        case TaskSelection:
            return RPLocalizedString(@"Search Task", nil);
            break;
        case ActivitySelection:
            return RPLocalizedString(@"Search Activity", nil);
            break;
        case OEFDropDownSelection:
            return RPLocalizedString(@"Search OEF Dropdown Options", nil);
            break;

        default:
            break;
    }
    return nil;
}

-(KSPromise *)fetchFreshRecords
{
    if (self.selectionScreenType == ClientSelection)
    {
        return [self.clientRepository fetchAllClients];
    }
    else if (self.selectionScreenType == ProjectSelection)
    {
        NSString *clientUri = self.punchCardObject.clientType.uri;
        if (clientUri ==nil || clientUri == (id)[NSNull null] || clientUri.length == 0) {
            clientUri = nil;
        }

        if (self.projectStorageFlowType == PunchProjectStorageFlowContext)
        {
            NSArray *projects = [self.projectStorage getAllProjectsForClientUri:clientUri];
            if (projects.count > 0)
            {
                NSDictionary *serializedProjectData = [self projectsDataForValues:projects downloadCount:projects.count];
                self.values = [self populateProjectArrayWithValuesFromDictionary:serializedProjectData];
                [self.tableView reloadData];
            }
        }
        


        return [self.projectRepository fetchAllProjectsForClientUri:clientUri];
    }
    else if (self.selectionScreenType == TaskSelection)
    {
        return [self.taskRepository fetchAllTasksForProjectUri:self.punchCardObject.projectType.uri];
    }
    else if (self.selectionScreenType == ActivitySelection)
    {
        return [self.activityRepository fetchAllActivities];
    }
    else if (self.selectionScreenType == OEFDropDownSelection)
    {
        return [self.oefDropdownRepository fetchAllOEFDropDownOptions];
    }
    return nil;
}

-(NSDictionary *)projectsDataForValues:(NSArray *)values downloadCount:(NSInteger)downloadCount
{
    id projects = [[NSArray alloc]init];
    if (values.count > 0) {
        projects = values;
    }
    return  @{@"downloadCount":[NSNumber numberWithInteger:downloadCount],
              @"projects":projects};
}


-(KSPromise *)fetchRecordsMatchingText:(NSString *)matchText
{
    if (self.selectionScreenType == ClientSelection)
    {
        return [self.clientRepository fetchClientsMatchingText:matchText];
    }
    else if (self.selectionScreenType == ProjectSelection)
    {
        return [self.projectRepository fetchProjectsMatchingText:matchText clientUri:self.punchCardObject.clientType.uri];
    }
    else if (self.selectionScreenType == TaskSelection)
    {
        return [self.taskRepository fetchTasksMatchingText:matchText projectUri:self.punchCardObject.projectType.uri];
    }
    else if (self.selectionScreenType == ActivitySelection)
    {
        return [self.activityRepository fetchActivitiesMatchingText:matchText];
    }
    else if (self.selectionScreenType == OEFDropDownSelection)
    {
        return [self.oefDropdownRepository fetchOEFDropDownOptionsMatchingText:matchText];
    }
    return nil;
}

     
-(KSPromise *)fetchCachedRecordsMatchingText:(NSString *)matchText
{
    if (self.selectionScreenType == ClientSelection)
    {
        return [self.clientRepository fetchCachedClientsMatchingText:matchText];
    }
    else if (self.selectionScreenType == ProjectSelection)
    {
        return [self.projectRepository fetchCachedProjectsMatchingText:matchText clientUri:self.punchCardObject.clientType.uri];
    }
    else if (self.selectionScreenType == TaskSelection)
    {
        return [self.taskRepository fetchCachedTasksMatchingText:matchText projectUri:self.punchCardObject.projectType.uri];
    }
    else if (self.selectionScreenType == ActivitySelection)
    {
        return [self.activityRepository fetchCachedActivitiesMatchingText:matchText];
    }
    else if (self.selectionScreenType == OEFDropDownSelection)
    {
        return [self.oefDropdownRepository fetchCachedOEFDropDownOptionsMatchingText:matchText];
    }
    return nil;
}


-(NSString *)cellTextForRow:(NSInteger)row
{
    if (self.selectionScreenType == ClientSelection) {
        ClientType *client = self.values[row];
        return client.name;
    }
    else if (self.selectionScreenType == ProjectSelection) {
        ProjectType *project = self.values[row];
        return project.name;
    }
    else if (self.selectionScreenType == TaskSelection) {
        TaskType *task = self.values[row];
        return task.name;
    }
    else if (self.selectionScreenType == ActivitySelection) {
        Activity *activity = self.values[row];
        return activity.name;
    }
    else if (self.selectionScreenType == OEFDropDownSelection) {
        OEFDropDownType *oefDropDownType = self.values[row];
        return oefDropDownType.name;
    }
    return nil;
}


-(void)reloadTableViewWithPromise:(KSPromise *)promise
{
    [promise then:^id(NSDictionary *valueDictionary) {
        if (self.selectionScreenType == ClientSelection)
        {
            if (self.projectStorageFlowType == PunchProjectStorageFlowContext)
            {
                self.values = [self populateClientTypeArrayWithValuesFromDictionary:valueDictionary];
            }
            else
            {
                self.values = valueDictionary[@"clients"];
            }

        }
        else if (self.selectionScreenType == ProjectSelection)
        {
            if (self.projectStorageFlowType == PunchProjectStorageFlowContext)
            {
                 self.values = [self populateProjectArrayWithValuesFromDictionary:valueDictionary];
            }
            else
            {
                 self.values = valueDictionary[@"projects"];
            }

        }
        else if (self.selectionScreenType == TaskSelection) {
            NSArray *tasksArray = valueDictionary[@"tasks"];
            [self.values removeAllObjects];
            if(tasksArray.count>0)
            {
                self.values = [tasksArray mutableCopy];
            }
            else
            {
                BOOL hasTasksAvailableForTimeAllocation = self.punchCardObject.projectType.hasTasksAvailableForTimeAllocation;
                if(!hasTasksAvailableForTimeAllocation)
                {
                    TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"None" uri:nil];
                    [self.values addObject:taskType];
                }
            }
        }
        else if (self.selectionScreenType == ActivitySelection) {
            self.values = valueDictionary[@"activities"];;
        }
        else if (self.selectionScreenType == OEFDropDownSelection) {
            self.values = valueDictionary[@"oefDropDownOptions"];;
        }
        [self.tableView reloadData];
        return nil;
    } error:^id(NSError *error) {
        return nil;
    }];
}

-(void)updatePunchCardFromDataSelectedOnIndexpath:(NSIndexPath *)indexPath
{
    if (self.selectionScreenType == ClientSelection)
    {
        [self.delegate selectionController:self didChooseClient:self.values[indexPath.row]];
    }
    else if (self.selectionScreenType == ProjectSelection)
    {
        [self.delegate selectionController:self didChooseProject:[self updatedProjectTypeWithCorrectClientType:indexPath]];
    }
    else if (self.selectionScreenType == TaskSelection)
    {
        [self.delegate selectionController:self didChooseTask:self.values[indexPath.row]];
    }
    else if (self.selectionScreenType == ActivitySelection)
    {
        [self.delegate selectionController:self didChooseActivity:self.values[indexPath.row]];
    }
    else if (self.selectionScreenType == OEFDropDownSelection)
    {
        [self.delegate selectionController:self didChooseDropDownOEF:self.values[indexPath.row]];
    }

}

-(void)fetchDataAfterDelayFromTimer:(NSTimer *)timer
{
    NSString *searchText = (NSString*)[timer userInfo];
    KSPromise *promise = [self fetchRecordsMatchingText:searchText];
    [self reloadTableViewWithPromise:promise];
}

-(KSPromise *)fetchFreshRecordsPromise
{
    if (self.selectionScreenType == ClientSelection)
    {
        return [self.clientRepository fetchFreshClients];
    }
    else if (self.selectionScreenType == ProjectSelection)
    {
        return [self.projectRepository fetchFreshProjectsForClientUri:self.punchCardObject.clientType.uri];
    }
    else if (self.selectionScreenType == TaskSelection)
    {
        return [self.taskRepository fetchFreshTasksForProjectUri:self.punchCardObject.projectType.uri];
    }
    else if (self.selectionScreenType == ActivitySelection)
    {
        return [self.activityRepository fetchFreshActivities];
    }
    else if (self.selectionScreenType == OEFDropDownSelection)
    {
        return [self.oefDropdownRepository fetchFreshOEFDropDownOptions];
    }
    return nil;
}

-(KSPromise *)fetchMoreRecordsPromise
{
    if (self.selectionScreenType == ClientSelection)
    {
        return [self.clientRepository fetchMoreClientsMatchingText:self.searchBar.text];
    }
    else if (self.selectionScreenType == ProjectSelection)
    {
        return [self.projectRepository fetchMoreProjectsMatchingText:self.searchBar.text clientUri:self.punchCardObject.clientType.uri];
    }
    else if (self.selectionScreenType == TaskSelection)
    {
        return [self.taskRepository fetchMoreTasksMatchingText:self.searchBar.text projectUri:self.punchCardObject.projectType.uri];
    }
    else if (self.selectionScreenType == ActivitySelection)
    {
        return [self.activityRepository fetchMoreActivitiesMatchingText:self.searchBar.text];
    }
    else if (self.selectionScreenType == OEFDropDownSelection)
    {
        return [self.oefDropdownRepository fetchMoreOEFDropDownOptionsMatchingText:self.searchBar.text];
    }
    return nil;
}

-(void)decideToShowOrHideInfiniteScrollingForFetchCount:(NSInteger)fetchCount
{
    if (fetchCount >= 10)
    {
        self.tableView.showsInfiniteScrolling=TRUE;
    }
    else
    {
        self.tableView.showsInfiniteScrolling=FALSE;
    }
}


#pragma mark - Helper Method

- (NSMutableArray *)populateProjectArrayWithValuesFromDictionary:(NSDictionary *)valueDictionary {
    
    NSMutableArray *values_ = [NSMutableArray arrayWithArray:valueDictionary[@"projects"]];
    
    if(!self.punchCardObject.projectType.isProjectTypeRequired) {
        
        ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:nil
                                                                                           name:@"None"
                                                                                            uri:nil];
        [values_ insertObject:projectType atIndex:0];
    }
    return values_;
}

- (NSMutableArray *)populateClientTypeArrayWithValuesFromDictionary:(NSDictionary *)valueDictionary {

    NSMutableArray *values_ = [NSMutableArray arrayWithArray:valueDictionary[@"clients"]];
    
    ClientType *anyClientType = [[ClientType alloc] initWithName:RPLocalizedString(ClientTypeAnyClient, nil) uri:ClientTypeAnyClientUri];
    ClientType *noClientType = [[ClientType alloc] initWithName:RPLocalizedString(ClientTypeNoClient, nil) uri:ClientTypeNoClientUri];

    [values_ insertObject:anyClientType atIndex:0];
    [values_ insertObject:noClientType  atIndex:1];
    
    return values_;
}


- (ProjectType *)updatedProjectTypeWithCorrectClientType:(NSIndexPath *)indexPath {
    
    ProjectType *originalProjectType = self.values[indexPath.row];
    
    if([originalProjectType.client.uri isEqualToString:NULL_STRING] || !IsNotEmptyString(originalProjectType.client.uri)) {
        [originalProjectType setClientTypeAsNoClient];
    }
    
    return originalProjectType;
}


-(ProjectStorageFlowType )projectStorageFlowType
{
    return self.projectStorage != nil ? PunchProjectStorageFlowContext : ExpenseProjectStorageFlowContext;
}

@end
