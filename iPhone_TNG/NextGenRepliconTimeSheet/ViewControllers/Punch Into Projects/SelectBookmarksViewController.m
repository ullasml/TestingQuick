#import "SelectBookmarksViewController.h"
#import "PunchCardStorage.h"
#import "AllPunchCardCell.h"
#import "PunchCardObject.h"
#import "Constants.h"
#import "Theme.h"
#import <KSDeferred/KSPromise.h>
#import "Punch.h"
#import "PunchCardController.h"
#import <Blindside/BSInjector.h>
#import "UserPermissionsStorage.h"
#import "TimeLinePunchesStorage.h"
#import "AllPunchCardController.h"
#import "BookmarkThreeEntriesCell.h"
#import "BookmarkTwoEntriesCell.h"
#import "BookmarkOneEntryCell.h"
#import "BookmarkValidationRepository.h"
#import "SelectBookmarksViewController+ValidateForInvalidClientProjectTask.h"

@interface SelectBookmarksViewController ()

@property (weak, nonatomic,) id<SelectBookmarksViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet UITableView                *tableView;
@property (weak, nonatomic) IBOutlet UILabel                    *noBookmarksTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *noBookmarksDescriptionLabel;

@property (nonatomic) NSMutableArray                            *tableRows;
@property (nonatomic) id <Punch>                                mostRecentPunch;
@property (nonatomic) PunchCardStorage                          *punchCardStorage;
@property (nonatomic) UserPermissionsStorage                    *userPermissionsStorage;
@property (weak, nonatomic) id<BSInjector>                      injector;
@property (nonatomic) TimeLinePunchesStorage                    *timeLinePunchStorage;
@property (nonatomic) id<Theme>                                 theme;
@property (nonatomic) BookmarkValidationRepository              *bookmarkValidationRepository;

@end

static NSString *const ThreeEntriesCellIdentifier = @"!!!";
static NSString *const TwoEntriesCellIdentifier = @"!!";
static NSString *const OneEntryCellIdentifier = @"!";

@implementation SelectBookmarksViewController


- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                          timeLinePunchStorage:(TimeLinePunchesStorage *)timeLinePunchStorage
                              punchCardStorage:(PunchCardStorage *)punchCardStorage
                                         theme:(id <Theme>)theme
                  bookmarkValidationRepository:(BookmarkValidationRepository *)bookmarkValidationRepository {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.userPermissionsStorage = userPermissionsStorage;
        self.timeLinePunchStorage = timeLinePunchStorage;
        self.punchCardStorage = punchCardStorage;
        self.theme = theme;
        self.bookmarkValidationRepository = bookmarkValidationRepository;
    }
    return self;
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
    
    [self.tableView registerClass:[BookmarkThreeEntriesCell class] forCellReuseIdentifier:ThreeEntriesCellIdentifier];
    [self.tableView registerClass:[BookmarkOneEntryCell class] forCellReuseIdentifier:OneEntryCellIdentifier];
    [self.tableView registerClass:[BookmarkTwoEntriesCell class] forCellReuseIdentifier:TwoEntriesCellIdentifier];

    UINib *threeEntriesCellNib = [UINib nibWithNibName:NSStringFromClass([BookmarkThreeEntriesCell class]) bundle:nil];
    UINib *twoEntriesCellNib = [UINib nibWithNibName:NSStringFromClass([BookmarkTwoEntriesCell class]) bundle:nil];
    UINib *oneEntryCellNib = [UINib nibWithNibName:NSStringFromClass([BookmarkOneEntryCell class]) bundle:nil];

    [self.tableView registerNib:threeEntriesCellNib forCellReuseIdentifier:ThreeEntriesCellIdentifier];
    [self.tableView registerNib:twoEntriesCellNib forCellReuseIdentifier:TwoEntriesCellIdentifier];
    [self.tableView registerNib:oneEntryCellNib forCellReuseIdentifier:OneEntryCellIdentifier];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self.view setBackgroundColor:[self.theme punchCardTableViewParentViewBackgroundColor]];
    [self.tableView setBackgroundColor:[self.theme punchCardTableViewBackgroundColor]];

    [self triggerBookmarksValidationIfPunchIntoProjectUser];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setMessageForLabel];
    
    self.mostRecentPunch =self.timeLinePunchStorage.mostRecentPunch;
    [self reloadTableViewWithMostRecentPunch:self.mostRecentPunch];
}

- (void)setupWithDelegate:(id <SelectBookmarksViewControllerDelegate>)delegate
{
    self.delegate = delegate;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellToReturn=nil;
    
    PunchCardObject *cardObject = self.tableRows[indexPath.row];
    NSString *clientName = cardObject.clientType.name;
    NSString *projectName = cardObject.projectType.name;
    NSString *taskName = cardObject.taskType.name;
    
    if ([[self rowIdentifierWithIndexPath:indexPath] isEqualToString:ThreeEntriesCellIdentifier]) {
        BookmarkThreeEntriesCell *cell = [tableView dequeueReusableCellWithIdentifier:ThreeEntriesCellIdentifier
                                                                 forIndexPath:indexPath];
        cell.firstEntryLabel.text = clientName;
        cell.firstEntryLabel.font = [self.theme allPunchCardTitleLabelFont];
        cell.firstEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
        cell.firstEntryLabel.textColor = [self.theme allPunchCardTitleLabelFontColor];
        
        cell.secondEntryLabel.text = projectName;
        cell.secondEntryLabel.font = [self.theme allPunchCardDescriptionLabelFont];
        cell.secondEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
        cell.secondEntryLabel.textColor = [self.theme allPunchCardDescriptionLabelFontColor];
        
        cell.thirdEntryLabel.text = taskName;
        cell.thirdEntryLabel.font = [self.theme allPunchCardDescriptionLabelFont];
        cell.thirdEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
        cell.thirdEntryLabel.textColor = [self.theme allPunchCardDescriptionLabelFontColor];
        
        cell.borderView.layer.borderWidth = [self.theme punchCardTableViewCellBorderWidth];
        cell.borderView.layer.borderColor = [self.theme punchCardTableViewCellBorderColor].CGColor;
        cell.borderView.layer.cornerRadius = [self.theme punchCardTableViewCellCornerRadius];
        cell.borderView.layer.backgroundColor = [self.theme punchCardTableViewCellBackgroundColor].CGColor;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cellToReturn = cell;
    }
    else if ([[self rowIdentifierWithIndexPath:indexPath] isEqualToString:TwoEntriesCellIdentifier])
    {
        BookmarkTwoEntriesCell *cell = [tableView dequeueReusableCellWithIdentifier:TwoEntriesCellIdentifier
                                                                         forIndexPath:indexPath];
        BOOL hasClientAccess = [self.userPermissionsStorage hasClientAccess];
        BOOL isClientPresent = IsValidClient(cardObject.clientType);
        if (hasClientAccess && isClientPresent) {
            cell.firstEntryLabel.text = clientName;
            cell.firstEntryLabel.font = [self.theme allPunchCardTitleLabelFont];
            cell.firstEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
            cell.firstEntryLabel.textColor = [self.theme allPunchCardTitleLabelFontColor];
            
            cell.secondEntryLabel.text = projectName;
            cell.secondEntryLabel.font = [self.theme allPunchCardDescriptionLabelFont];
            cell.secondEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
            cell.secondEntryLabel.textColor = [self.theme allPunchCardDescriptionLabelFontColor];
        }
        else{
            cell.firstEntryLabel.text = projectName;
            cell.firstEntryLabel.font = [self.theme allPunchCardTitleLabelFont];
            cell.firstEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
            cell.firstEntryLabel.textColor = [self.theme allPunchCardTitleLabelFontColor];
            
            cell.secondEntryLabel.text = taskName;
            cell.secondEntryLabel.font = [self.theme allPunchCardDescriptionLabelFont];
            cell.secondEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
            cell.secondEntryLabel.textColor = [self.theme allPunchCardDescriptionLabelFontColor];
        }
        cell.borderView.layer.borderWidth = [self.theme punchCardTableViewCellBorderWidth];
        cell.borderView.layer.borderColor = [self.theme punchCardTableViewCellBorderColor].CGColor;
        cell.borderView.layer.cornerRadius = [self.theme punchCardTableViewCellCornerRadius];
        cell.borderView.layer.backgroundColor = [self.theme punchCardTableViewCellBackgroundColor].CGColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cellToReturn = cell;
    }
    else
    {
        BookmarkOneEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:OneEntryCellIdentifier
                                                                       forIndexPath:indexPath];
        cell.firstEntryLabel.text = projectName;
        cell.firstEntryLabel.font = [self.theme allPunchCardTitleLabelFont];
        cell.firstEntryLabel.backgroundColor = [self.theme transparentBackgroundColor];
        cell.firstEntryLabel.textColor = [self.theme allPunchCardTitleLabelFontColor];
        
        cell.borderView.layer.borderWidth = [self.theme punchCardTableViewCellBorderWidth];
        cell.borderView.layer.borderColor = [self.theme punchCardTableViewCellBorderColor].CGColor;
        cell.borderView.layer.cornerRadius = [self.theme punchCardTableViewCellCornerRadius];
        cell.borderView.layer.backgroundColor = [self.theme punchCardTableViewCellBackgroundColor].CGColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cellToReturn = cell;
    }
    
    return cellToReturn;
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
        if (![self.tableRows count]) {
            [self showNoBookmarksCreatedMessage];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PunchCardObject *punchCardObject = self.tableRows[indexPath.row];
    id<Punch> mostRecentPunch = [self.timeLinePunchStorage mostRecentPunch];
    BOOL noPunchAvailableForUser = (mostRecentPunch == nil || mostRecentPunch == (id)[NSNull class] || mostRecentPunch.actionType == PunchActionTypePunchOut);
    if (noPunchAvailableForUser) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate selectBookmarksViewController:self updatePunchCard:punchCardObject];
    }
    else{
        AllPunchCardController *allPunchCardsController = [self.injector getInstance:[AllPunchCardController class]];
        [allPunchCardsController setUpWithDelegate:self
                                    controllerType:TransferPunchCardsControllerType
                                   punchCardObject:punchCardObject
                                          flowType:TransferWorkFlowType];
        [self.navigationController pushViewController:allPunchCardsController animated:YES];
    }
}

#pragma mark - Private

-(NSString*)rowIdentifierWithIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasClientAccess = [self.userPermissionsStorage hasClientAccess];
    PunchCardObject *cardObject = self.tableRows[indexPath.row];
    NSString *projectName = cardObject.projectType.name;
    NSString *taskName = cardObject.taskType.name;
    BOOL isClientPresent = IsValidClient(cardObject.clientType);
    BOOL isProjectPresent = [self isValidString:projectName];
    BOOL isTaskPresent = [self isValidString:taskName];
    
    if (hasClientAccess && isClientPresent && isProjectPresent && isTaskPresent) {
        return ThreeEntriesCellIdentifier;
    }
    else if ((hasClientAccess && isClientPresent && isProjectPresent) || (isProjectPresent && isTaskPresent)){
        return TwoEntriesCellIdentifier;
    }
    else{
        return OneEntryCellIdentifier;
    }
    return OneEntryCellIdentifier;
}

-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
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
    
    self.tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    
    [self.tableView reloadData];
    if (![self.tableRows count]) {
        [self showNoBookmarksCreatedMessage];
    }
}

-(void)setMessageForLabel
{
    self.noBookmarksTitleLabel.hidden = YES;
    self.noBookmarksDescriptionLabel.hidden = YES;
    self.noBookmarksTitleLabel.text =  RPLocalizedString(noBookmarksCreatedText, noBookmarksCreatedText);
    self.noBookmarksDescriptionLabel.text =  RPLocalizedString(noBookmarksAvailableText, noBookmarksAvailableText);
    [self.noBookmarksTitleLabel setFont:[self.theme noBookmarksLabelTitleTextFont]];
    [self.noBookmarksTitleLabel setTextColor:[self.theme noBookmarksLabelTitleTextColor]];
    [self.noBookmarksDescriptionLabel setFont:[self.theme noBookmarksLabelDescriptionFont]];
    [self.noBookmarksDescriptionLabel setTextColor:[self.theme noBookmarksLabelDescriptionTextColor]];
    
    NSString *text = RPLocalizedString(noBookmarksAvailableText, noBookmarksAvailableText);
    NSString *linkTextWithColor = @"+";
    
    NSRange textRange=[text rangeOfString:linkTextWithColor options:NSBackwardsSearch];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]  initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[self.theme plusSignColor] range:textRange];
    [attributedString addAttribute:NSFontAttributeName value:[self.theme noBookmarksLabelTitleTextFont] range:textRange];
    
    self.noBookmarksDescriptionLabel.attributedText =  attributedString;
}

-(void)showNoBookmarksCreatedMessage
{
    self.noBookmarksTitleLabel.hidden = NO;
    self.noBookmarksDescriptionLabel.hidden = NO;
}

- (BOOL)isValidPunchAttributesForPunch:(PunchCardObject *)punch
{
    return ( [self isValidString:punch.clientType.name] ||
            [self isValidString:punch.projectType.name] ||
            [self isValidString:punch.taskType.name]);
}

-(void)navigateToCreateBookmarksView
{
    ProjectCreatePunchCardController *projectCreatePunchCardController = [self.injector getInstance:[ProjectCreatePunchCardController class]];
    [projectCreatePunchCardController setupWithDelegate:self];
    [self.navigationController pushViewController:projectCreatePunchCardController animated:YES];
}

#pragma mark - <ProjectCreatePunchCardControllerDelegate>

- (void)projectCreatePunchCardController:(ProjectCreatePunchCardController *)punchCardController
    didChooseToCreatePunchCardWithObject:(PunchCardObject *)punchCardObject
{
    [self.punchCardStorage storePunchCard:[self getUpdatedPunchCardObject:punchCardObject]];
    [self reloadTableViewWithMostRecentPunch:self.mostRecentPunch];
    [self.delegate selectBookmarksViewControllerUpdateCardList:self];
}

#pragma mark - Helper Method

- (PunchCardObject *)getUpdatedPunchCardObject:(PunchCardObject *)punchCardObj_ {
    PunchCardObject *punchCardObj = punchCardObj_;
    
    ClientType *localClientType = [[ClientType alloc] initWithName:nil uri:nil];
    ClientType *client = IsValidClient(punchCardObj.clientType) ? punchCardObj.clientType : localClientType;
    
    ProjectType *project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:punchCardObj.projectType.hasTasksAvailableForTimeAllocation isTimeAllocationAllowed:punchCardObj.projectType.isTimeAllocationAllowed projectPeriod:punchCardObj.projectType.projectPeriod clientType:client name:punchCardObj.projectType.name uri:punchCardObj.projectType.uri];
    
    punchCardObj = [[PunchCardObject alloc] initWithClientType:client
                                                   projectType:project
                                                 oefTypesArray:punchCardObj.oefTypesArray
                                                     breakType:punchCardObj.breakType
                                                      taskType:punchCardObj.taskType
                                                      activity:punchCardObj.activity
                                                           uri:punchCardObj.uri];
    return punchCardObj;
    
}

- (void)triggerBookmarksValidationIfPunchIntoProjectUser {

    BOOL hasActivityAccess = [self.userPermissionsStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionsStorage hasProjectAccess];
    BOOL shouldTriggerBookmarksValidation = (!hasActivityAccess && hasProjectAccess);

    if(shouldTriggerBookmarksValidation) {
        [self checkBookmarksValidityAndRefreshList];
    }
}

#pragma mark - <AllPunchCardControllerDelegate>

-(void)allPunchCardController:(AllPunchCardController *)allPunchCardController
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
        assembledPunchPromise:(KSPromise *)assembledPunchPromise
  serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{
    [self.delegate selectBookmarksViewController:self
             willEventuallyFinishIncompletePunch:incompletePunch
                           assembledPunchPromise:assembledPunchPromise
                     serverDidFinishPunchPromise:serverDidFinishPunchPromise];
}

@end
