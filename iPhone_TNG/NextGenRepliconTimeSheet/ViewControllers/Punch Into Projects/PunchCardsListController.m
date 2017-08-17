
#import "PunchCardsListController.h"
#import "PunchCardStorage.h"
#import "AllPunchCardCell.h"
#import "PunchCardObject.h"
#import "Constants.h"
#import "Theme.h"
#import <KSDeferred/KSPromise.h>
#import "Punch.h"
#import "PunchRepository.h"
#import "PunchClock.h"
#import "PunchImagePickerControllerProvider.h"
#import "AllowAccessAlertHelper.h"
#import <KSDeferred/KSDeferred.h>
#import "ImageNormalizer.h"
#import "ChildControllerHelper.h"
#import "PunchCardController.h"
#import <Blindside/BSInjector.h>
#import "UserPermissionsStorage.h"
#import "TimeLinePunchesStorage.h"
#import "SelectBookmarksHeaderView.h"
#import "PunchCardsListController+ValidateForInvalidClientProjectTask.h"
#import "BookmarkValidationRepository.h"

@interface PunchCardsListController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *tableRows;
@property (nonatomic) id <PunchCardsListControllerDelegate> delegate;
@property (nonatomic) id <Punch> mostRecentPunch;
@property (nonatomic) KSDeferred *imageDeferred;
@property (nonatomic) PunchCardStorage *punchCardStorage;
@property (nonatomic) TimeLinePunchesStorage *timeLinePunchStorage;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (weak, nonatomic) id<BSInjector> injector;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) BookmarkValidationRepository *bookmarkValidationRepository;



@end

static NSString *const CellIdentifier = @"!";

@implementation PunchCardsListController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                       userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                             punchCardStorage:(PunchCardStorage *)punchCardStorage
                             timeLinePunchStorage:(TimeLinePunchesStorage *)timeLinePunchStorage
                                        theme:(id <Theme>)theme
                 bookmarkValidationRepository:(BookmarkValidationRepository*)bookmarkValidationRepository

{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.childControllerHelper = childControllerHelper;
        self.userPermissionsStorage = userPermissionsStorage;
        self.punchCardStorage = punchCardStorage;
        self.timeLinePunchStorage = timeLinePunchStorage;
        self.theme = theme;
        self.bookmarkValidationRepository = bookmarkValidationRepository;
    }
    return self;
}

- (void)setUpWithDelegate:(id <PunchCardsListControllerDelegate>)delegate
{
    self.delegate = delegate;
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
    self.title = RPLocalizedString(@"Punch Cards", nil);

    [self.tableView registerClass:[AllPunchCardCell class] forCellReuseIdentifier:CellIdentifier];
    UINib *spinnerCellNib = [UINib nibWithNibName:NSStringFromClass([AllPunchCardCell class]) bundle:nil];
    [self.tableView registerNib:spinnerCellNib forCellReuseIdentifier:CellIdentifier];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    self.mostRecentPunch =self.timeLinePunchStorage.mostRecentPunch;
    [self reloadTableViewWithMostRecentPunch:self.mostRecentPunch];
    
    [self.view setBackgroundColor:[self.theme punchCardTableViewParentViewBackgroundColor]];
    [self.tableView setBackgroundColor:[self.theme punchCardTableViewBackgroundColor]];

    [self triggerBookmarksValidationIfPunchIntoProjectUser];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat newHeight = self.tableView.contentSize.height;
    [self.delegate punchCardsListController:self didUpdateHeight:newHeight];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AllPunchCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                             forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PunchCardObject *cardObject = self.tableRows[indexPath.row];
    NSString *clientName = cardObject.clientType.name;
    NSString *projectName = cardObject.projectType.name;
    NSString *taskName = cardObject.taskType.name;
    BOOL isClientPresent = IsValidClient(cardObject.clientType);
    BOOL isProjectPresent = [self isValidString:projectName];
    BOOL isTaskPresent = [self isValidString:taskName];

    NSString *none = RPLocalizedString(@"None", nil);
    NSString *client;
    NSString *project;
    NSString *task;
    BOOL isAnyValidPunchAttributePresent = [self isValidPunchAttributesForPunch:cardObject];
    BOOL hasClientAccess = [self.userPermissionsStorage hasClientAccess];
    if (isAnyValidPunchAttributePresent)
    {
        client = isClientPresent ? clientName : none;
        project = isProjectPresent ? projectName : none;
        task = isTaskPresent ? taskName : none;
    }
    else
    {
        client = [NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Client", nil),none];
        project = [NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Project", nil),none];
        task = [NSString stringWithFormat:@"%@:%@",RPLocalizedString(@"Task", nil),none];
    }

    cell.clientLabel.text = client;
    cell.clientLabel.font = [self.theme allPunchCardTitleLabelFont];
    cell.clientLabel.backgroundColor = [self.theme transparentBackgroundColor];
    cell.clientLabel.textColor = [self.theme allPunchCardTitleLabelFontColor];


    cell.projectLabel.text = project;
    cell.projectLabel.font = [self.theme allPunchCardDescriptionLabelFont];
    cell.projectLabel.backgroundColor = [self.theme transparentBackgroundColor];
    cell.projectLabel.textColor = [self.theme allPunchCardDescriptionLabelFontColor];

    cell.taskLabel.text = task;
    cell.taskLabel.font = [self.theme allPunchCardDescriptionLabelFont];
    cell.taskLabel.backgroundColor = [self.theme transparentBackgroundColor];
    cell.taskLabel.textColor = [self.theme allPunchCardDescriptionLabelFontColor];
    
    if (!hasClientAccess || !isClientPresent) {
        [cell.clientLabel removeFromSuperview];
        cell.projectLabel.font = [self.theme allPunchCardTitleLabelFont];
        cell.projectLabel.textColor = [self.theme allPunchCardTitleLabelFontColor];
    }

    cell.borderView.layer.borderWidth = [self.theme punchCardTableViewCellBorderWidth];
    cell.borderView.layer.borderColor = [self.theme punchCardTableViewCellBorderColor].CGColor;
    cell.borderView.layer.cornerRadius = [self.theme punchCardTableViewCellCornerRadius];
    cell.borderView.layer.backgroundColor = [self.theme punchCardTableViewCellBackgroundColor].CGColor;
    
    if (isAnyValidPunchAttributePresent)
    {
        if (!isTaskPresent)
            [cell.taskLabel removeFromSuperview];
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.tableRows count]) {
        SelectBookmarksHeaderView *selectBookmarksHeaderView = [[SelectBookmarksHeaderView alloc] init];
        selectBookmarksHeaderView.backgroundColor = [self.theme punchCardTableHeaderViewBackgroundColor];
        
        selectBookmarksHeaderView.sectionTitleLabel.backgroundColor = [self.theme punchCardTableHeaderViewBackgroundColor];
        selectBookmarksHeaderView.sectionTitleLabel.font = [self.theme punchCardTableHeaderViewLabelFont];
        selectBookmarksHeaderView.sectionTitleLabel.textAlignment = NSTextAlignmentLeft;
        
        switch (section) {
            case 0:
                selectBookmarksHeaderView.sectionTitleLabel.text = RPLocalizedString(previousProjectsText, previousProjectsText);
                return selectBookmarksHeaderView;
                break;
            default:
                break;
        }
        
        return selectBookmarksHeaderView;
    }
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [self.theme punchCardTableHeaderViewBackgroundColor];
    
    return headerView;
}

#pragma mark - <UITableViewDelegate>

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        PunchCardObject *punchCardToBeDeleted = self.tableRows[indexPath.row];
        [self.punchCardStorage deletePunchCard:punchCardToBeDeleted];
        [self.tableRows removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
        CGFloat newHeight = self.tableView.contentSize.height;
        [self.delegate punchCardsListController:self didUpdateHeight:newHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PunchCardObject *punchCardObject = self.tableRows[indexPath.row];
    [self.delegate punchCardsListController:self didIntendToUpdatePunchCard:punchCardObject];
}


#pragma mark - Private

-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}

-(NSString *)titleForPunchState:(PunchActionType)actionType
{
    if (actionType == PunchActionTypePunchOut || actionType == PunchActionTypeUnknown)
    {
        return RPLocalizedString(@"Clock In", nil);
    }
    else
    {
        return RPLocalizedString(@"Transfer", nil);
    }
}


-(void)reloadTableViewWithMostRecentPunch:(id <Punch>)punch
{
    self.mostRecentPunch = punch;
    if (punch ==nil || punch.actionType == PunchActionTypePunchOut || punch.actionType == PunchActionTypeStartBreak)
    {
        self.tableRows = [NSMutableArray arrayWithArray:[self.punchCardStorage getPunchCards]];
    }
    else
    {
        self.tableRows = [NSMutableArray arrayWithArray:[self.punchCardStorage getPunchCardsExcludingPunch:punch]];
    }

    [self.tableView reloadData];
}


- (BOOL)isValidPunchAttributesForPunch:(PunchCardObject *)punch
{
    return ( [self isValidString:punch.clientType.name] ||
             [self isValidString:punch.projectType.name] ||
             [self isValidString:punch.taskType.name]);
}

-(IBAction)punchStateButtonAction:(id)sender
{
    NSInteger index = [sender tag];
    if (index < self.tableRows.count) {
        PunchCardObject *cardObject = self.tableRows[index];
        if (self.mostRecentPunch.actionType == PunchActionTypePunchOut ||
            self.mostRecentPunch.actionType == PunchActionTypeUnknown)
        {
            [self.delegate punchCardsListController:self didIntendToPunchInUsingPunchCard:cardObject];
        }
        else
        {
            [self.delegate punchCardsListController:self didIntendToTransferUsingPunchCard:cardObject];
            
        }
    }

}

#pragma mark - helper Methods

- (void)triggerBookmarksValidationIfPunchIntoProjectUser {

    BOOL hasActivityAccess = [self.userPermissionsStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionsStorage hasProjectAccess];
    BOOL shouldTriggerBookmarksValidation = (!hasActivityAccess && hasProjectAccess);

    if(shouldTriggerBookmarksValidation) {
        [self checkBookmarksValidityAndRefreshList];
    }
}

@end
