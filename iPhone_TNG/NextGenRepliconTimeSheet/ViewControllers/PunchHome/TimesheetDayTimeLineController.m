#import <MacTypes.h>
#import "TimesheetDayTimeLineController.h"
#import <KSDeferred/KSPromise.h>
#import "PunchesForDateFetcher.h"
#import "PunchPresenter.h"
#import "TimeLineCellStylist.h"
#import "PunchOverviewController.h"
#import "UserPermissionsStorage.h"
#import "AddPunchController.h"
#import <Blindside/BSInjector.h>
#import "PunchRepository.h"
#import "RemotePunch.h"
#import "TimeLineCell.h"
#import "PunchOverviewController.h"
#import "Theme.h"
#import "Util.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "NSString+TruncateToWidth.h"
#import "TimeLinePunchesSummary.h"
#import "TimeLinePunchesStorage.h"
#import "DayTimeLineCell.h"
#import "AddPunchTimeLineCell.h"
#import "DurationStringPresenter.h"
#import "DayTimeLineHeaderViewController.h"
#import "UIView+Dashed.h"
#import "AuditHistoryRepository.h"
#import "AuditHistory.h"
#import "ImageFetcher.h"
#import "ChildControllerHelper.h"
#import "MissingPunchCell.h"
#import "ButtonStylist.h"
#import "PunchEmptyStateCell.h"
#import "UIImage+UIImage_Color.h"


@interface TimesheetDayTimeLineController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *timelineTableView;

@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) DurationStringPresenter *durationStringPresenter;
@property (nonatomic) TimeLineCellStylist *cellStylist;
@property (nonatomic) PunchPresenter *punchPresenter;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) FlowType flowType;
@property (nonatomic) NSMutableArray *punches;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic) AuditHistoryRepository *auditHistoryRepository;

@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;

@property (nonatomic,weak) id<TimesheetDayTimeLineControllerDelegate> delegate;
@property (nonatomic,weak) id<PunchChangeObserverDelegate> punchChangeObserverDelegate;
@property (nonatomic,weak) id<BSInjector> injector;
@property (nonatomic) ImageFetcher *imageFetcher;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic,assign) int rowHeight;
@property (nonatomic) TimeLinePunchFlow timeLinePunchFlow;
@property (nonatomic) DayTimeLineHeaderViewController *dayTimeLineTableHeaderViewController;

@end


static NSString *const TimeLineCellIdentifier = @"TimeLineCellIdentifier";
static NSString *const AddPunchTimeLineCellIdentifier = @"AddPunchTimeLineCellIdentifier";
static NSString *const MissingPunchTimeLineCellIdentifier = @"MissingPunchTimeLineCellIdentifier";
static NSString *const PunchEmptyStateCellIdentifier = @"PunchEmptyStateCellIdentifier";

@implementation TimesheetDayTimeLineController

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                       durationStringPresenter:(DurationStringPresenter *)durationStringPresenter
                        auditHistoryRepository:(AuditHistoryRepository *)auditHistoryRepository
                        timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                           reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                           timeLineCellStylist:(TimeLineCellStylist *)timeLineCellStylist
                                punchPresenter:(PunchPresenter *)punchPresenter
                                  imageFetcher:(ImageFetcher *)imageFetcher
                                         theme:(id <Theme>)theme
                         childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                 buttonStylist:(ButtonStylist *)buttonStylist{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.durationStringPresenter = durationStringPresenter;
        self.userPermissionsStorage = userPermissionsStorage;
        self.auditHistoryRepository = auditHistoryRepository;
        self.timeLinePunchesStorage = timeLinePunchesStorage;
        self.reachabilityMonitor = reachabilityMonitor;
        self.cellStylist = timeLineCellStylist;
        self.punchPresenter = punchPresenter;
        self.imageFetcher = imageFetcher;
        self.theme = theme;
        self.childControllerHelper = childControllerHelper;
        self.buttonStylist = buttonStylist;
    }
    return self;
}

- (void)setupWithPunchChangeObserverDelegate:(id <PunchChangeObserverDelegate>)punchChangeObserverDelegate
                 serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id <TimesheetDayTimeLineControllerDelegate>)delegate
                                     userURI:(NSString *)userURI
                                    flowType:(FlowType)flowType
                                     punches:(NSArray *)punches
                           timeLinePunchFlow:(TimeLinePunchFlow)timeLinePunchFlow

{
    self.punchChangeObserverDelegate = punchChangeObserverDelegate;
    self.userURI = userURI;
    self.delegate = delegate;
    self.flowType = flowType;
    self.punches = [NSMutableArray arrayWithArray:punches];
    self.timeLinePunchFlow = timeLinePunchFlow;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.timelineTableView.delegate = nil;
    self.timelineTableView.dataSource = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rowHeight = self.punches.count >0 ? 65.0 : 320.0;
    
    UINib *cellNib = [UINib nibWithNibName:@"DayTimeLineCell" bundle:nil];
    UINib *addPunchTimeLineCellNib = [UINib nibWithNibName:@"AddPunchTimeLineCell" bundle:nil];
    UINib *missingPunchCellNib = [UINib nibWithNibName:@"MissingPunchCell" bundle:nil];
    UINib *punchEmptyStateCellNib = [UINib nibWithNibName:@"PunchEmptyStateCell" bundle:nil];
    [self.timelineTableView registerNib:cellNib forCellReuseIdentifier:TimeLineCellIdentifier];
    [self.timelineTableView registerNib:addPunchTimeLineCellNib forCellReuseIdentifier:AddPunchTimeLineCellIdentifier];
    [self.timelineTableView registerNib:missingPunchCellNib forCellReuseIdentifier:MissingPunchTimeLineCellIdentifier];
    [self.timelineTableView registerNib:punchEmptyStateCellNib forCellReuseIdentifier:PunchEmptyStateCellIdentifier];
    self.timelineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.timelineTableView.estimatedRowHeight = self.rowHeight;
    self.timelineTableView.rowHeight = UITableViewAutomaticDimension;
    [self.timelineTableView setAccessibilityIdentifier:@"timeline_entry_tableview"];

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25.0)];
    view.backgroundColor = [UIColor clearColor];
    self.dayTimeLineTableHeaderViewController = [self.injector getInstance:[DayTimeLineHeaderViewController class]];
    [self.childControllerHelper addChildController:self.dayTimeLineTableHeaderViewController
                                toParentController:self
                                   inContainerView:view];
    
    self.timelineTableView.tableHeaderView = view;
    self.timelineTableView.backgroundColor = [UIColor clearColor];
    
    view.backgroundColor = [UIColor redColor];
    self.timelineTableView.tableHeaderView.backgroundColor = [UIColor clearColor];

    if (self.punches.count == 0) {
        NSDate *date = [self.delegate timesheetDayTimeLineControllerDidRequestDate:self];
        self.punches = [NSMutableArray arrayWithArray:[self.timeLinePunchesStorage allRemotePunchesForDay:date userUri:self.userURI]];
        self.dayTimeLineTableHeaderViewController.descendingLineView.hidden = YES;
    }
    
    if (self.punches.count > 0){
        NSMutableArray *punches = [self.punches mutableCopy];
        for (id<Punch> punch in self.punches)
        {
            if ([punch respondsToSelector:@selector(offline)] && punch.offline){
                [punches removeObject:punch];
            }
            else if (![punch respondsToSelector:@selector(uri)]){
                [punches removeObject:punch];
            }
            else if (!punch.syncedWithServer){
                [punches removeObject:punch];
            }
        }
        self.punches = punches;
        self.punches = [self updatedPunchesWithMissingStatus];
        [self fetchAuditHistory];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat initialHeight = 0.0f;
    
    if ([self.reachabilityMonitor isNetworkReachable])
    {
        if (self.navigationController.presentedViewController == nil && self.navigationController.viewControllers.count > 0)
        {
            [self.delegate timesheetDayTimeLineController:self didUpdateHeight:initialHeight];
            
            UIColor *lineColor = [self.punchPresenter descendingLineViewColorForPunchActionType:PunchActionTypePunchOut];
            if (self.punches.count > 0) {
                RemotePunch *punch = self.punches.firstObject;
                PunchActionType actionType = punch.previousPunchActionType != PunchActionTypeUnknown ? punch.previousPunchActionType : punch.actionType;
                lineColor = [self.punchPresenter descendingLineViewColorForPunchActionType:actionType];
                LineType type = (actionType == PunchActionTypeStartBreak) ? Dashed : Filled;
                if (type == Dashed) {
                    [self.dayTimeLineTableHeaderViewController.descendingLineView lineWithColor:lineColor type:type];
                    self.dayTimeLineTableHeaderViewController.descendingLineView.backgroundColor = [UIColor clearColor];
                }
                else{
                    self.dayTimeLineTableHeaderViewController.descendingLineView.backgroundColor = lineColor;
                }
                
                self.dayTimeLineTableHeaderViewController.descendingLineView.hidden = (punch.previousPunchPairStatus == Missing || punch.previousPunchPairStatus == Unknown);
            }
           
            [self reloadTimelineTable];
        }
    }
    else{
        [self.delegate timesheetDayTimeLineController:self didUpdateHeight:initialHeight];
        [self.dayTimeLineTableHeaderViewController.descendingLineView setHidden:YES];
    }
}

-(void)reloadTimelineTable
{
    [self.timelineTableView reloadData];
    [self.timelineTableView layoutIfNeeded];
    CGFloat newHeight = self.timelineTableView.contentSize.height;
    [self.delegate timesheetDayTimeLineController:self didUpdateHeight:newHeight];
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.timelineTableView layoutIfNeeded];
    CGFloat newHeight = self.timelineTableView.contentSize.height;
    if ([self.reachabilityMonitor isNetworkReachable]){
        [self.delegate timesheetDayTimeLineController:self didUpdateHeight:newHeight];
    }
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int addIndex = [self additonalIndexForEmptyState];
    return (self.punches.count > 0 ? self.punches.count : addIndex) + self.userPermissionsStorage.canEditTimePunch;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int addIndex = [self additonalIndexForEmptyState];
    BOOL isAddPunchRow = (self.userPermissionsStorage.canEditTimePunch && [self.punches count] + addIndex == indexPath.row);
    if (isAddPunchRow)
    {
        AddPunchTimeLineCell *timeLineCell = [tableView dequeueReusableCellWithIdentifier:AddPunchTimeLineCellIdentifier forIndexPath:indexPath];
        CGFloat topPadding = self.punches.count == 0 ? 0.0 : 20.0;
        [timeLineCell setUpWithDelegate:self topConstraint:topPadding];
        timeLineCell.accessoryType = UITableViewCellAccessoryNone;
        UIColor *titleColor = [self.theme addPunchButtonTitleColor];
        UIColor *backgroundColor = [self.theme addPunchButtonBackgroundColor];
        UIColor *borderColor = [self.theme addPunchButtonBorderColor];
        [self.buttonStylist styleButton:timeLineCell.addPunchBtn
                                  title:RPLocalizedString(AddPunch_Title, AddPunch_Title)
                             titleColor:titleColor
                        backgroundColor:backgroundColor
                            borderColor:borderColor];
        timeLineCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return timeLineCell;
    }
    else
    {
        if (addIndex!=0) {
            PunchEmptyStateCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:PunchEmptyStateCellIdentifier forIndexPath:indexPath];
            emptyCell.userInteractionEnabled = NO;
            emptyCell.firstLineLbl.text = NSLocalizedString(PunchEmptyState_First, PunchEmptyState_First);
            [emptyCell.firstLineLbl sizeToFit];
            emptyCell.firstLineLbl.font = [self.theme punchEmptyStateFirstLineFont];
            emptyCell.firstLineLbl.textColor = [self.theme punchEmptyStateFirstLineColor];
            emptyCell.secondLineLbl.text = NSLocalizedString(PunchEmptyState_Second, PunchEmptyState_Second);
            emptyCell.secondLineLbl.font = [self.theme punchEmptyStateSecondLineFont];
            emptyCell.secondLineLbl.textColor = [self.theme punchEmptyStateSecondLineColor];
            return emptyCell;
        }else{
            RemotePunch *punch = self.punches[indexPath.row];
            if (punch.isMissingPunch){
                MissingPunchCell *cell = [tableView dequeueReusableCellWithIdentifier:MissingPunchTimeLineCellIdentifier forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.punchType.text = NSLocalizedString(@"Missing Punch", @"");
                cell.punchType.backgroundColor = [UIColor clearColor];
                UIColor *lineColor = [self.punchPresenter descendingLineViewColorForPunchActionType:PunchActionTypePunchOut];
                cell.descendingLineView.backgroundColor = lineColor;
                [cell.descendingLineView setHidden:NO];
                if (punch.nextPunchPairStatus == Unknown)  {
                    [cell.descendingLineView setHidden:YES];
                }
                [cell.cellSeparator setHidden:YES];
                cell.punchUserImageView.image = [UIImage imageNamed:@"missing_punch"];
                cell.punchUserImageView.backgroundColor = [UIColor  clearColor];
                return cell;
            }
            
            DayTimeLineCell *timeLineCell = [tableView dequeueReusableCellWithIdentifier:TimeLineCellIdentifier forIndexPath:indexPath];
            NSInteger tagValue = (indexPath.section * 100000) + indexPath.row;
            timeLineCell.tag = tagValue;
            timeLineCell.punchType.text = [self.punchPresenter descriptionLabelTextWithPunch:punch];
            timeLineCell.punchType.font = [self.theme descriptionLabelBoldFont];
            NSAttributedString *punchMetaDataAttributedString = [self.punchPresenter descriptionLabelForDayTimelineCellTextWithPunch:punch
                                                                                                                         regularFont:[self.theme descriptionLabelBoldFont]
                                                                                                                           lightFont:[self.theme descriptionLabelLighterFont]
                                                                                                                           textColor:[self.theme timeLineCellDescriptionLabelTextColor]
                                                                                                                            forWidth:CGRectGetWidth(timeLineCell.metaDataLabel.bounds)];
            
            NSString *mostRecentAuditHistoryText = (punch.auditHistoryInfoArray.count > 0) ? punch.auditHistoryInfoArray.lastObject : @"";
            timeLineCell.auditHistory.text = mostRecentAuditHistoryText;
            timeLineCell.auditHistory.backgroundColor = [UIColor clearColor];
            timeLineCell.metaDataLabel.attributedText = punchMetaDataAttributedString;
            timeLineCell.punchUserImageView.image = [self.punchPresenter punchActionIconImageWithPunch:punch];
            
            UIColor *lineColor = [self.punchPresenter descendingLineViewColorForPunchActionType:punch.actionType];
            LineType type = (punch.actionType == PunchActionTypeStartBreak) ? Dashed : Filled;
            [timeLineCell.descendingLineView lineWithColor:lineColor type:type];
            timeLineCell.descendingLineView.hidden = NO;
            if (punch.nextPunchPairStatus == Unknown)  {
                timeLineCell.descendingLineView.hidden = YES;
            }
            timeLineCell.punchUserImageView.layer.borderColor = [UIColor clearColor].CGColor;
            if (punch.imageURL != nil && punch.imageURL != (id)[NSNull null]){
                timeLineCell.punchUserImageView.layer.borderColor = lineColor.CGColor;
                timeLineCell.punchUserImageView.layer.borderWidth= 2.0f;
                KSPromise *imagePromise = [self.imageFetcher promiseWithImageURL:punch.imageURL];
                [imagePromise then:^id(UIImage*image) {
                    if (timeLineCell.tag == tagValue) {
                        timeLineCell.punchUserImageView.image = image;
                    }
                    return nil;
                } error:nil];
            }
            
            timeLineCell.punchUserImageView.layer.cornerRadius = CGRectGetWidth(timeLineCell.punchUserImageView.bounds) / 2.0f;
            timeLineCell.punchUserImageView.layer.masksToBounds = true;
            
            timeLineCell.address.text = self.userPermissionsStorage.geolocationRequired ? RPLocalizedString(@"Location Unavailable", nil) : RPLocalizedString(@"Address unavailable", nil);;
            if (punch.address != nil && punch.address != (id)[NSNull null]) {
                timeLineCell.address.text = punch.address;
            }
            NSString *punchActualTimeString = @"";
            if ([self timeIsIn12HourFormat]) {
                punchActualTimeString =  [self.punchPresenter timeWithAmPmLabelTextForPunch:punch];
            }
            else{
                punchActualTimeString =  [self.punchPresenter timeLabelTextWithPunch:punch];
            }
            timeLineCell.punchActualTime.text = punchActualTimeString;
            
            timeLineCell.agentType.text = [self.punchPresenter sourceOfPunchLabelTextWithPunch:punch];
            NSString *violationsString = [self violationsStringForPunch:punch];
            timeLineCell.violationDetais.text = violationsString;
            
            timeLineCell.duration.text = @"";
            if (punch.duration != nil && punch.duration != (id)[NSNull null]) {
                timeLineCell.duration.text = [self.durationStringPresenter durationStringWithHours:punch.duration.hour minutes:punch.duration.minute];
            }
            [self.cellStylist applyStyleToDayTimeLineCell:timeLineCell hidesDescendingLine:NO];
            
            NSString *violationImageName = punch.nonActionedValidationsCount > 0 ? @"violation-timeline-inactive": @"violation-timeline-active";
            NSString *punchTypeImageName = punch.actionType == PunchActionTypeStartBreak ? @"break-metadata": @"metadata";
            timeLineCell.platformImageView.image = [UIImage imageNamed:@"platform"];
            timeLineCell.locationImageView.image = [UIImage imageNamed:@"location"];
            timeLineCell.violationImageView.image = [UIImage imageNamed:violationImageName];
            timeLineCell.auditHistoryImageView.image = [UIImage imageNamed:@"audit"];
            timeLineCell.punchTypeImageView.image = [UIImage imageNamed:punchTypeImageName];
            timeLineCell.auditHistoryImageView.hidden = mostRecentAuditHistoryText.length > 0 ? false : true;
            timeLineCell.punchTypeImageView.hidden = punchMetaDataAttributedString.length > 0 ? false : true;
            timeLineCell.violationImageView.hidden = violationsString.length > 0 ? false : true;
            
            [timeLineCell.metaDataLabel sizeToFit];
            
            timeLineCell.cellSeparatorView.hidden = punch.nextPunchPairStatus == Missing ?  true : false;
            
            UIView *bgColorView = [[UIView alloc] init];
            bgColorView.backgroundColor = [self.theme timelineSelectedCellColor];
            [timeLineCell setSelectedBackgroundView:bgColorView];
            
            timeLineCell.punchTypeToMetaDataSpacerHeight.constant = punchMetaDataAttributedString.length > 0 ? 15 : 0 ;
            timeLineCell.metaDataToViolationsSpacerHeight.constant = violationsString.length > 0 ? 10 : 0;
            timeLineCell.violationsToAgentTypeSpacerHeight.constant = 10;
            
            return timeLineCell;
        }
    }
    return nil;
}



#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int addIndex = [self additonalIndexForEmptyState];
    BOOL isAddPunchRow = (self.userPermissionsStorage.canEditTimePunch && [self.punches count] + addIndex == indexPath.row);
   
    if (isAddPunchRow)
    {
        CGFloat topPadding = self.punches.count == 0 ? 0.0 : 20.0;
        return 65.0 + topPadding;
    }
    else
    {
        if (addIndex!=0)
        {
            return self.rowHeight;
        }
        return UITableViewAutomaticDimension;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int addIndex = [self additonalIndexForEmptyState];
    BOOL isAddPunchRow = [self.punches count] + addIndex == indexPath.row;
    if (isAddPunchRow)
    {
        return;
    }
    else {
        RemotePunch *punch = self.punches [indexPath.row];
        if (!punch.isMissingPunch) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.timeLinePunchesStorage storeRemotePunch:punch];
            PunchOverviewController *punchOverviewController = [self.injector getInstance:[PunchOverviewController class]];
            [punchOverviewController setupWithPunchChangeObserverDelegate:self.punchChangeObserverDelegate
                                                                    punch:punch
                                                                 flowType:self.flowType
                                                                  userUri:self.userURI];
            [self.navigationController pushViewController:punchOverviewController animated:YES];
        }
    }
}


#pragma mark - AddPunchTimeLineCell Callbacks

- (void)addPunchTimeLineCell:(AddPunchTimeLineCell *)addPunchTimeLineCell
    intendedToAddManualPunch:(UIButton *)addPunchButton
{
    AddPunchController *addPunchController = [self.injector getInstance:[AddPunchController class]];
    NSDate *date = [self.delegate timesheetDayTimeLineControllerDidRequestDate:self];
    [addPunchController setupWithPunchChangeObserverDelegate:self.punchChangeObserverDelegate
                                                     userURI:self.userURI
                                                        date:date];
    [self.navigationController pushViewController:addPunchController animated:YES];
}

#pragma mark - Private

-(BOOL)areThereAnyPunchAttributesPresentForPunch:(id <Punch>)punch
{
    ClientType *clientType = punch.client;
    ProjectType *projectType = punch.project;
    TaskType *taskType = punch.task;
    NSArray *oefTypesArray = punch.oefTypesArray;
    return (clientType || projectType || taskType || oefTypesArray.count > 0);
}

-(NSString *)violationsStringForPunch:(id <Punch>)punch
{
    NSString *violationString = @"";
    if (punch.violations.count > 0) {
        if (punch.nonActionedValidationsCount > 0) {
            NSString *violationsWaitingForActionsCountString = punch.violations.count > 1 ? @"validations requires your attention": @"validation requires your attention";
            violationString = [NSString localizedStringWithFormat:@"%ld/%lu %@",(long)punch.nonActionedValidationsCount,(unsigned long)punch.violations.count, RPLocalizedString(violationsWaitingForActionsCountString, nil)];
        }
        else{
            NSString *violationsResolvedCountString = punch.violations.count > 1 ? @"validations resolved": @"validation resolved";
            violationString = [NSString localizedStringWithFormat:@"%lu %@",(unsigned long)punch.violations.count, RPLocalizedString(violationsResolvedCountString, nil)];
        }
    }
    return violationString;
}



-(void)fetchAuditHistory
{
    if (self.punches.count) {
        NSMutableArray *punchesUriArray = [NSMutableArray array];
        for (RemotePunch *punch in  self.punches) {
            if (!punch.isMissingPunch) {
                [punchesUriArray addObject:punch.uri];
            }
        }
        if (punchesUriArray.count>0) {
            KSPromise *auditHistoryPromise =  [self.auditHistoryRepository fetchPunchLogs:punchesUriArray];
            [auditHistoryPromise then:^id(NSArray *punchLogs) {
                [self updatePunchesWithAuditHistory:punchLogs];
                [self reloadTimelineTable];
                return nil;
            } error:nil];
        }
    }
}

-(void)updatePunchesWithAuditHistory:(NSArray*)punchLogs
{
    for (AuditHistory *auditHistory in punchLogs) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uri == %@", auditHistory.uri];
            NSArray *filteredArray = [self.punches filteredArrayUsingPredicate:predicate];
            RemotePunch *punch = filteredArray[0];
            NSUInteger index = [self.punches indexOfObject:filteredArray[0]];
            RemotePunch *punchCopy = [[RemotePunch alloc] initWithPunchSyncStatus:punch.punchSyncStatus
                                                           nonActionedValidations:punch.nonActionedValidationsCount
                                                              previousPunchStatus:punch.previousPunchPairStatus
                                                                  nextPunchStatus:punch.nextPunchPairStatus
                                                                    sourceOfPunch:punch.sourceOfPunch
                                                                       actionType:punch.actionType
                                                                    oefTypesArray:punch.oefTypesArray
                                                                     lastSyncTime:punch.lastSyncTime
                                                                          project:punch.project
                                                                      auditHstory:auditHistory.history
                                                                        breakType:punch.breakType
                                                                         location:punch.location
                                                                       violations:punch.violations
                                                                        requestID:punch.requestID
                                                                         activity:punch.activity
                                                                         duration:punch.duration
                                                                           client:punch.client
                                                                          address:punch.address
                                                                          userURI:punch.userURI
                                                                         imageURL:punch.imageURL
                                                                             date:punch.date
                                                                             task:punch.task
                                                                              uri:punch.uri
                                                             isTimeEntryAvailable:punch.isTimeEntryAvailable
                                                                 syncedWithServer:punch.syncedWithServer
                                                                   isMissingPunch:punch.isMissingPunch
                                                          previousPunchActionType:punch.previousPunchActionType ];
        [self.punches replaceObjectAtIndex:index withObject:punchCopy];
    }
}

-(NSMutableArray*)updatedPunchesWithMissingStatus
{
    NSMutableArray *updatedPunches = [NSMutableArray array];
    for (RemotePunch*punch in self.punches) {
        if (punch.nextPunchPairStatus == Missing || punch.previousPunchPairStatus == Missing) {
            if (punch.previousPunchPairStatus == Missing) {
                RemotePunch *missingPunch = [[RemotePunch alloc] initWithPunchSyncStatus:punch.punchSyncStatus
                                                               nonActionedValidations:punch.nonActionedValidationsCount
                                                                  previousPunchStatus:Unknown
                                                                      nextPunchStatus:Present
                                                                        sourceOfPunch:UnknownSourceOfPunch
                                                                           actionType:PunchActionTypeUnknown
                                                                           oefTypesArray:nil
                                                                            lastSyncTime:nil
                                                                                 project:nil
                                                                             auditHstory:nil
                                                                               breakType:nil
                                                                                location:nil
                                                                              violations:nil
                                                                               requestID:nil
                                                                                activity:nil
                                                                                duration:nil
                                                                                  client:nil
                                                                                 address:nil
                                                                                 userURI:nil
                                                                                imageURL:nil
                                                                                    date:nil
                                                                                    task:nil
                                                                                  uri:@"missing"
                                                                 isTimeEntryAvailable:punch.isTimeEntryAvailable
                                                                     syncedWithServer:punch.syncedWithServer
                                                                       isMissingPunch:YES
                                                                 previousPunchActionType:punch.previousPunchActionType];
                [updatedPunches addObject:missingPunch];
                [updatedPunches addObject:punch];
            }
            else{
                PunchPairStatus nextPunchStatus = Unknown;
                NSInteger index=[self.punches indexOfObject:punch];
                if (index+1 < [self.punches count]) {
                    RemotePunch *nextPunch = self.punches[index+1];
                    nextPunchStatus = nextPunch.previousPunchPairStatus;
                }

                RemotePunch *missingPunch = [[RemotePunch alloc] initWithPunchSyncStatus:punch.punchSyncStatus
                                                                  nonActionedValidations:punch.nonActionedValidationsCount
                                                                     previousPunchStatus:Present
                                                                         nextPunchStatus:nextPunchStatus
                                                                           sourceOfPunch:UnknownSourceOfPunch
                                                                              actionType:PunchActionTypeUnknown
                                                                           oefTypesArray:nil
                                                                            lastSyncTime:nil
                                                                                 project:nil
                                                                             auditHstory:nil
                                                                               breakType:nil
                                                                                location:nil
                                                                              violations:nil
                                                                               requestID:nil
                                                                                activity:nil
                                                                                duration:nil
                                                                                  client:nil
                                                                                 address:nil
                                                                                 userURI:nil
                                                                                imageURL:nil
                                                                                    date:nil
                                                                                    task:nil
                                                                                     uri:@"missing"
                                                                    isTimeEntryAvailable:punch.isTimeEntryAvailable
                                                                        syncedWithServer:punch.syncedWithServer
                                                                          isMissingPunch:YES
                                                                 previousPunchActionType:punch.previousPunchActionType];
                [updatedPunches addObject:punch];
                [updatedPunches addObject:missingPunch];
            }
        }
        else{
            [updatedPunches addObject:punch];
        }
    }
    return updatedPunches;
}

-(int)additonalIndexForEmptyState{
    return (self.punches.count == 0 && self.timeLinePunchFlow == DayControllerTimeLinePunchFlowContext) ? 1 : 0;
}

#pragma mark - Time Format

- (BOOL)timeIsIn12HourFormat {
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    return hasAMPM;
}
@end
