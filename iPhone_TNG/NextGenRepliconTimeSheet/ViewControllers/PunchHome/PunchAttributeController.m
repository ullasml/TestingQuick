#import "PunchAttributeController.h"
#import "Punch.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Theme.h"
#import "UserPermissionsStorage.h"
#import "PunchAttributeRowPresenter.h"
#import "Constants.h"
#import "PunchAttributeCell.h"
#import "ReporteePermissionsStorage.h"
#import "SelectionController.h"
#import <Blindside/BSInjector.h>
#import "LocalPunch.h"
#import "PunchCardObject.h"
#import "TimesheetClientProjectTaskRepository.h"
#import "AstroClientPermissionStorage.h"
#import "DefaultActivityStorage.h"
#import "OEFType.h"
#import "DynamicTextTableViewCell.h"
#import "Punch.h"
#import "UIAlertView+Dismiss.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "OEFValidator.h"
#import "UITextView+DisableCopyPaste.h"
#import "UIViewController+OEFValuePopulation.h"
#import "InjectorKeys.h"

#define DYNAMIC_TEXT_VIEW_TAG_INDEX     1000

@interface PunchAttributeController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) ReporteePermissionsStorage *reporteePunchRulesStorage;
@property (nonatomic) AstroClientPermissionStorage *astroClientPermissionStorage;
@property (nonatomic) DefaultActivityStorage *defaultActivityStorage;

@property (nonatomic,copy)NSString *userUri;

@property (nonatomic,assign) BOOL locationRequired;
@property (nonatomic) id<Punch> punch;
@property (nonatomic) FlowType flowType;
@property (nonatomic) NSMutableArray *tableRows;
@property (nonatomic) id <PunchAttributeControllerDelegate> delegate;
@property (nonatomic) id <BSInjector> injector;
@property (nonatomic,assign) BOOL alertViewVisible;
@property (nonatomic) NSString *selectedDropDownOEFUri;
@property (nonatomic) PunchAttributeScreentype punchAttributeScreentype;
@property (nonatomic) NSString *oldTexviewValue;
@property (nonatomic, assign) NSInteger dynamicCellTextViewTag;

@end

static NSString *const CellIdentifier = @"¡";

@implementation PunchAttributeController

- (instancetype)initWithReporteePermissionsStorage:(ReporteePermissionsStorage *)reporteePermissionsStorage
                      astroClientPermissionStorage:(AstroClientPermissionStorage *)astroClientPermissionStorage
                            defaultActivityStorage:(DefaultActivityStorage *)defaultActivityStorage
                                 punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage {
    self = [super init];
    if (self) {
        self.punchRulesStorage = punchRulesStorage;
        self.reporteePunchRulesStorage = reporteePermissionsStorage;
        self.astroClientPermissionStorage = astroClientPermissionStorage;
        self.defaultActivityStorage = defaultActivityStorage;
    }
    return self;
}

- (void)setUpWithNeedLocationOnUI:(BOOL)locationRequired
                         delegate:(id<PunchAttributeControllerDelegate>)delegate
                         flowType:(FlowType)flowType
                          userUri:(NSString *)userUri
                            punch:(id<Punch>)punch
         punchAttributeScreentype:(PunchAttributeScreentype)punchAttributeScreentype
{
    
    self.locationRequired = locationRequired;

    self.punch = punch;
    self.delegate = delegate;
    self.flowType = flowType;
    self.userUri = userUri;
    self.punchAttributeScreentype = punchAttributeScreentype;
    [self.astroClientPermissionStorage setUpWithUserUri:self.userUri];
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
    [self.tableView registerClass:[PunchAttributeCell class] forCellReuseIdentifier:CellIdentifier];
    UINib *inboxCellNib = [UINib nibWithNibName:@"PunchAttributeCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:inboxCellNib forCellReuseIdentifier:CellIdentifier];
    [self setupDataForTableView];
    
    self.tableView.estimatedRowHeight = 70.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    UINib *nib = [UINib nibWithNibName:@"DynamicTextTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DynamicTextViewCell"];
    
    self.selectedDropDownOEFUri = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    float height = self.tableView.contentSize.height;
    [self.delegate punchAttributeController:self didUpdateTableViewWithHeight:height];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableRows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellToReturn=nil;

    PunchAttributeRowPresenter *rowPresenter = self.tableRows[indexPath.row];

    if (rowPresenter.punchAttributeType == OEFAttribute)
    {
        static NSString *simpleTableIdentifier = @"DynamicTextViewCell";

        DynamicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier
                                                                         forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DynamicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }

        [self configureDynamicTextViewCell:cell atIndexPath:indexPath];

        OEFType *oefType;

        BOOL isPunchOutScreenType = (self.punch.actionType == PunchActionTypePunchOut);
        BOOL isBreakScreenType = (self.punch.actionType == PunchActionTypeStartBreak);



        if (!isPunchOutScreenType && !isBreakScreenType)
        {
            oefType = self.punch.oefTypesArray[indexPath.row - [self rowIndexForOEFTypes]];
        }
        else
        {
            oefType = self.punch.oefTypesArray[indexPath.row];
        }
        
        cellToReturn = [self configureAndReturnCellWithAppropriateRows:indexPath.row OefType:oefType cell:cell];
        
    }
    else
    {
        PunchAttributeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureBasicCell:cell atIndexPath:indexPath];
        cellToReturn = cell;
    }

    return cellToReturn;
}

#pragma mark - TableView CellforRowAtIndexPath Method Helpers

- (OEFTypes)getOEFtypeForURI:(NSString *)oefURI {
    OEFTypes oefTypes = OEFTypeNone;
    if([oefURI isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
        oefTypes = OEFTypeNumeric;
    } else if([oefURI isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]) {
        oefTypes = OEFTypeText;
    } else if([oefURI isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI]) {
        oefTypes = OEFTypeDropDown;
    }
    return oefTypes;
}

- (DynamicTextTableViewCell *)configureAndReturnCellWithAppropriateRows:(NSInteger)row
                                                                OefType:(OEFType *)oefType
                                                                   cell:(DynamicTextTableViewCell *)cell {
    DynamicTextTableViewCell *cell_ = cell;
    cell.title.font = [self.theme attributeTitleLabelFont];
    cell.title.textColor = [self.theme attributeTitleLabelColor];



    OEFTypes oefTypes = [self getOEFtypeForURI:oefType.oefDefinitionTypeUri];
   
    switch (oefTypes) {
        case OEFTypeNumeric:
            cell.textView.font = [self.theme attributeValueLabelFont];
            if ([self.punchRulesStorage canEditNonTimeFields] ||[self.punchRulesStorage canEditTimePunch])
            {
                cell.textView.textColor = [self.theme attributeValueLabelColor];
            }
            else
            {
                 cell.textView.textColor = [self.theme attributeDisabledValueLabelColor];
            }

            [cell_ setUpWithDelegate:self withKeyboardType:NumericKeyboard tag:row];
            
            break;
        
        case OEFTypeText:
            cell.textView.font = [self.theme attributeValueLabelFont];
            if ([self.punchRulesStorage canEditNonTimeFields] ||[self.punchRulesStorage canEditTimePunch])
            {
                cell.textView.textColor = [self.theme attributeValueLabelColor];
            }
            else
            {
                cell.textView.textColor = [self.theme attributeDisabledValueLabelColor];
            }
            
            [cell_ setUpWithDelegate:self withKeyboardType:DefaultKeyboard tag:row];

            break;
        
        case OEFTypeDropDown: {

            NSString *oefDropDownPlaceHolderText = nil;

            if (self.punchAttributeScreentype == PunchAttributeScreenTypeADD)
            {
                oefDropDownPlaceHolderText = RPLocalizedString(DropDownOEFPlaceholder, @"");
            }
            else
            {
                oefDropDownPlaceHolderText = RPLocalizedString(@"None", @"");
            }

                cell.textValueLabel.text = (![self isValidString:oefType.oefDropdownOptionValue]) ? oefDropDownPlaceHolderText :oefType.oefDropdownOptionValue;
                cell.textValueLabel.font = [self.theme attributeValueLabelFont];
            if ([self.punchRulesStorage canEditNonTimeFields] ||[self.punchRulesStorage canEditTimePunch])
            {
                cell.textValueLabel.textColor = [self.theme attributeValueLabelColor];
            }
            else
            {
                cell.textValueLabel.textColor = [self.theme attributeDisabledValueLabelColor];
            }
                [cell_ setUpWithDelegate:self withKeyboardType:NoKeyboard tag:row];
                if ([self.punchRulesStorage canEditNonTimeFields] ||[self.punchRulesStorage canEditTimePunch])
                {
                  cell.userInteractionEnabled = YES;
                  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            break;
            
        default:
            [cell setUpWithDelegate:self withKeyboardType:DefaultKeyboard tag:row];
            break;
    }
    
    return cell_;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PunchAttributeRowPresenter *rowPresenter = self.tableRows[indexPath.row];
    if (rowPresenter.punchAttributeType == OEFAttribute)
    {

      return UITableViewAutomaticDimension;
    }
    else
    {
        PunchAttributeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [self configureBasicCell:cell atIndexPath:indexPath];
        return [self calculateHeightForConfiguredSizingCell:cell];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PunchAttributeRowPresenter *rowPresenter = self.tableRows[indexPath.row];
    
    if (rowPresenter.punchAttributeType != LocationAttribute && rowPresenter.punchAttributeType != OEFAttribute)
    {
        PunchCardObject *punchCardObject = [self punchCardObjectWithOEFTypesArray:nil breakType:NULL uri:nil];
        
        [self.view endEditing:YES];
        
        SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
        SelectionScreenType screenType = [self screenTypeForRowWithPresenter:rowPresenter];
        [selectionController setUpWithSelectionScreenType:screenType
                                          punchCardObject:punchCardObject
                                                 delegate:self];
        [self.navigationController pushViewController:selectionController animated:YES];
    }
    else if(rowPresenter.punchAttributeType == OEFAttribute)
    {
        [self setUpCellBeforeNavigatingToSelectionController:indexPath inTableView:tableView];

    }
}

- (void)setUpCellBeforeNavigatingToSelectionController:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    
    OEFType *oefType = self.punch.oefTypesArray[indexPath.row - [self rowIndexForOEFTypes]];
    OEFTypes oefTypes = [self getOEFtypeForURI:oefType.oefDefinitionTypeUri];
    switch (oefTypes) {
        case OEFTypeDropDown: {
            
            if (oefType.disabled)
            {
                if (!self.alertViewVisible)
                {
                    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                                   otherButtonTitle:nil
                                                           delegate:self
                                                            message:RPLocalizedString(@"This field has been disabled. Contact your Administrator for more details.",@"")
                                                              title:nil
                                                                tag:LONG_MIN];
                    self.alertViewVisible = YES;
                }
                
            }
            
            else
            {
                [self.view endEditing:YES];
                self.selectedDropDownOEFUri = oefType.oefUri;
                SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
                
                PunchCardObject *punchCardObject = [self punchCardObjectWithOEFTypesArray:self.punch.oefTypesArray breakType:self.punch.breakType uri:nil];
                
                [selectionController setUpWithSelectionScreenType:OEFDropDownSelection
                                                  punchCardObject:punchCardObject
                                                         delegate:self];
                
                self.navigationController.navigationBar.hidden = NO;
                [self.navigationController pushViewController:selectionController animated:YES];
                
            }
            
            
        }
        break;
            
        default: {
            DynamicTextTableViewCell *dynamicTextTableViewCell = [tableView cellForRowAtIndexPath:indexPath];
            [dynamicTextTableViewCell.textView becomeFirstResponder];
        }
        break;
    }
    
}

- (PunchCardObject *)punchCardObjectWithOEFTypesArray:(NSArray *)oefArray breakType:(BreakType*) breakType uri:(NSString *)uri {
    
    BOOL canAccessProject = [self canAccessProject];
    BOOL canAccessActivity = [self canAccessActivity];
    BOOL punchIntoProjectUser = !canAccessActivity && canAccessProject;
    
    ClientType *clientType = self.punch.client;
    ProjectType *projectType = self.punch.project;
    TaskType *taskType = self.punch.task;
    Activity *activityType = self.punch.activity;
    
    if (punchIntoProjectUser)
    {
        activityType = nil;
        projectType = [self updateProjectTypeInPunch];
    }
    else if(canAccessActivity)
    {
        clientType = nil;
        projectType = nil;
        taskType = nil;
        activityType = [self updateActivityInPunch];
    }
    else
    {
        clientType = nil;
        projectType = nil;
        taskType = nil;
        activityType = nil;
        projectType.isProjectTypeRequired = NO;
        activityType.isActivityRequired = NO;
    }
    
    
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                        initWithClientType:clientType
                                        projectType:projectType
                                        oefTypesArray:oefArray
                                        breakType:breakType
                                        taskType:taskType
                                        activity:activityType
                                        uri:uri];
    
    return punchCardObject;
}

- (ProjectType *)updateProjectTypeInPunch {
    
    LocalPunch *punch_ = self.punch;
    ProjectType *project = punch_.project;
    
    if([self canAccessProject]) {
        
        
        
        if(project && [project respondsToSelector:@selector(isProjectTypeRequired)]) {
            project.isProjectTypeRequired = [self isProjectMandatory];
        } else {
            project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                           isTimeAllocationAllowed:NO
                                                                     projectPeriod:nil
                                                                        clientType:nil
                                                                              name:nil
                                                                               uri:nil];
            
            project.isProjectTypeRequired = [self isProjectMandatory];
        }
    }
    
    return project;
}

- (Activity *)updateActivityInPunch {
    
    LocalPunch *punch_ = self.punch;
    Activity *activity_ = punch_.activity;
    
    if([self canAccessActivity]) {
        
        
        
        if(activity_ && [activity_ respondsToSelector:@selector(isActivityRequired)]) {
            activity_.isActivityRequired = [self isActivityMandatory];
        }
        else {
            activity_ = [[Activity alloc] initWithName:nil uri:nil];
            activity_.isActivityRequired = [self isActivityMandatory];
        }
    }
    
    return activity_;
}


#pragma mark - <SelectionControllerDelegate>

-(void)selectionController:(SelectionController *)selectionController didChooseClient:(ClientType *)client
{
    UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
    self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:nil requestID:self.punch.requestID activity:self.punch.activity client:[client copy] oefTypes:self.punch.oefTypesArray address:self.punch.address userURI:self.punch.userURI image:image task:nil date:self.punch.date];
    [self setupDataForTableView];
    [self.tableView reloadData];
    [self.delegate punchAttributeController:self didIntendToUpdateClient:client];

}

-(void)selectionController:(SelectionController *)selectionController didChooseProject:(ProjectType *)project
{
    UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
    self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:[project copy] requestID:self.punch.requestID activity:self.punch.activity client:self.punch.client oefTypes:self.punch.oefTypesArray address:self.punch.address userURI:self.punch.userURI image:image task:nil date:self.punch.date];
    NSLog(@"%@",self.punch.oefTypesArray);
    [self setupDataForTableView];
    [self.tableView reloadData];
    [self.delegate punchAttributeController:self didIntendToUpdateProject:project];
    
}
-(void)selectionController:(SelectionController *)selectionController didChooseTask:(TaskType *)task
{
    UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
    self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:self.punch.project requestID:self.punch.requestID activity:self.punch.activity client:self.punch.client oefTypes:self.punch.oefTypesArray address:self.punch.address userURI:self.punch.userURI image:image task:[task copy] date:self.punch.date];
    [self setupDataForTableView];
    [self.tableView reloadData];
    [self.delegate punchAttributeController:self didIntendToUpdateTask:task];
}

-(void)selectionController:(SelectionController *)selectionController didChooseActivity:(Activity *)activity
{
    UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
    self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:nil requestID:self.punch.requestID activity:[activity copy] client:nil oefTypes:self.punch.oefTypesArray address:self.punch.address userURI:self.punch.userURI image:image task:nil date:self.punch.date];
    [self setupDataForTableView];
    [self.tableView reloadData];
    [self.delegate punchAttributeController:self didIntendToUpdateActivity:activity];
}

-(id <ClientProjectTaskRepository> )selectionControllerNeedsClientProjectTaskRepository
{
    TimesheetClientProjectTaskRepository *timesheetClientProjectTaskRepository = [self.injector getInstance:[TimesheetClientProjectTaskRepository class]];
    [timesheetClientProjectTaskRepository setUpWithUserUri:self.userUri];
    return timesheetClientProjectTaskRepository;
}

-(OEFDropDownRepository *)selectionControllerNeedsOEFDropDownRepository
{
    OEFDropDownRepository *oefDropDownRepository = [self.injector getInstance:[OEFDropDownRepository class]];
    [oefDropDownRepository setUpWithDropDownOEFUri:self.selectedDropDownOEFUri userUri:self.userUri];
    return oefDropDownRepository;
}

-(void)selectionController:(SelectionController *)selectionController didChooseDropDownOEF:(OEFDropDownType *)oefDropDownType
{
    int oefIndex = 0;
     UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
    for (OEFType *oefType in self.punch.oefTypesArray)
    {
        if ([oefType.oefUri isEqualToString:self.selectedDropDownOEFUri])
        {
            OEFType *newOEFType = [[OEFType alloc] initWithUri:oefType.oefUri definitionTypeUri:oefType.oefDefinitionTypeUri name:oefType.oefName punchActionType:oefType.oefPunchActionType numericValue:oefType.oefNumericValue textValue:oefType.oefTextValue dropdownOptionUri:oefDropDownType.uri dropdownOptionValue:oefDropDownType.name collectAtTimeOfPunch:oefType.collectAtTimeOfPunch disabled:oefType.disabled];
            
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithArray:self.punch.oefTypesArray];
            [oefTypesArray replaceObjectAtIndex:oefIndex withObject:newOEFType];
            self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:self.punch.project requestID:self.punch.requestID activity:self.punch.activity client:self.punch.client oefTypes:[oefTypesArray copy] address:self.punch.address userURI:self.punch.userURI image:image task:self.punch.task date:self.punch.date];
            break;
        }
        
        oefIndex++;
    }
    
    [self setupDataForTableView];
    [self.tableView reloadData];
    [self.delegate punchAttributeController:self didIntendToUpdateDropDownOEFTypes:self.punch.oefTypesArray];
    [self viewDidLayoutSubviews];
}



#pragma mark - Private

-(void)setupDataForTableView
{
    self.tableRows = [[NSMutableArray alloc]init];
    NSString *placeHolderText = nil;

    if (self.punchAttributeScreentype == PunchAttributeScreenTypeADD){
        placeHolderText = RPLocalizedString(@"Select", @"");
    }
    else{
        placeHolderText = RPLocalizedString(@"None", @"");
    }

    BOOL canAccessClient = [self.astroClientPermissionStorage userHasClientPermission];
    BOOL canAccessProject = [self canAccessProject];
    BOOL canAccessActivity = [self canAccessActivity];
    BOOL punchIntoProjectUser = !canAccessActivity && canAccessProject;
    BOOL isPunchOutScreenType = (self.punch.actionType == PunchActionTypePunchOut);
    BOOL isPunchInOrTransferAction = (self.punch.actionType != PunchActionTypePunchOut && self.punch.actionType != PunchActionTypeStartBreak);
    
    if (isPunchInOrTransferAction && !punchIntoProjectUser){
        [self checkForDefaultActivity];
    }

    if (punchIntoProjectUser && !isPunchOutScreenType)
    {
        if (canAccessClient) {
            NSString *client = self.punch.client.name;
            NSString *clientText = [self isValidString:client] ? client : placeHolderText;
            NSString *title = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Client", nil)];
            PunchAttributeRowPresenter *rowPresenter = [[PunchAttributeRowPresenter alloc]initWithRowType:ClientAttribute
                                                                                                    title:title
                                                                                                     text:clientText];
            [self.tableRows addObject:rowPresenter];
        }
        if ([self canAccessProject]) {
            NSString *project = self.punch.project.name;
            NSString *projectText = [self isValidString:project] ? project : placeHolderText;
            NSString *projectTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Project", nil)];

            PunchAttributeRowPresenter *projectRowPresenter = [[PunchAttributeRowPresenter alloc]initWithRowType:ProjectAttribute
                                                                                                           title:projectTitle
                                                                                                            text:projectText];
            [self.tableRows addObject:projectRowPresenter];

            NSString *task = self.punch.task.name;
            NSString *taskText = [self isValidString:task] ? task : placeHolderText;
            NSString *taskTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Task", nil)];

            PunchAttributeRowPresenter *taskRowPresenter = [[PunchAttributeRowPresenter alloc]initWithRowType:TaskAttribute
                                                                                                        title:taskTitle
                                                                                                         text:taskText];
            [self.tableRows addObject:taskRowPresenter];

            NSArray * oefRowPresenterRows = [self genarateOEFRowPresenterRowsForPunch:self.punch];
            for (PunchAttributeRowPresenter *punchAttributeOEFRowPresenter in oefRowPresenterRows)
            {
                [self.tableRows addObject:punchAttributeOEFRowPresenter];
            }
        }
    }

    else if (canAccessActivity && !isPunchOutScreenType)
    {
        NSString *activity = self.punch.activity.name;
        NSString *activityText = [self isValidString:activity] ? activity : placeHolderText;
        NSString *activityTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Activity", nil)];

        PunchAttributeRowPresenter *activityRowPresenter = [[PunchAttributeRowPresenter alloc]initWithRowType:ActivityAttribute
                                                                                                        title:activityTitle
                                                                                                        text:activityText];
        [self.tableRows addObject:activityRowPresenter];

        NSArray * oefRowPresenterRows = [self genarateOEFRowPresenterRowsForPunch:self.punch];
        for (PunchAttributeRowPresenter *punchAttributeOEFRowPresenter in oefRowPresenterRows)
        {
            [self.tableRows addObject:punchAttributeOEFRowPresenter];
        }
    }
    else
    {
        NSArray * oefRowPresenterRows = [self genarateOEFRowPresenterRowsForPunch:self.punch];
        for (PunchAttributeRowPresenter *punchAttributeOEFRowPresenter in oefRowPresenterRows)
        {
            [self.tableRows addObject:punchAttributeOEFRowPresenter];
        }
    }
    if (self.locationRequired) {
        NSString *locationTitle = [NSString stringWithFormat:@"%@ :",RPLocalizedString(@"Location", nil)];
        NSString *address = self.punch.address;
        BOOL isLocationAvailable = [self isValidString:address];
        
        if (!isLocationAvailable) {
            address = RPLocalizedString(@"Location Unavailable", nil);
        }
        PunchAttributeRowPresenter *locationRowPresenter = [[PunchAttributeRowPresenter alloc]initWithRowType:LocationAttribute
                                                                                                        title:locationTitle
                                                                                                         text:address];
        [self.tableRows addObject:locationRowPresenter];
    }
}

-(BOOL)isValidString:(NSString *)value
{
    return (value !=nil && value != (id)[NSNull null] && value.length > 0);
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    return UITableViewAutomaticDimension;
}

- (void)configureBasicCell:(PunchAttributeCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PunchAttributeRowPresenter *rowPresenter = self.tableRows[indexPath.row];
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.title.numberOfLines = 0;
    cell.title.font = [self.theme attributeTitleLabelFont];
    cell.title.textColor = [self.theme attributeTitleLabelColor];
    cell.title.text = rowPresenter.title;

    cell.value.numberOfLines = 0;
    cell.value.font = [self.theme attributeValueLabelFont];

    cell.value.text = rowPresenter.text;

    if ([self.punchRulesStorage canEditNonTimeFields]
        ||[self.punchRulesStorage canEditTimePunch])
    {
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.value.textColor = [self.theme attributeValueLabelColor];
    }
    else
    {
        cell.value.textColor = [self.theme attributeDisabledValueLabelColor];
    }

    if (rowPresenter.punchAttributeType == LocationAttribute) {
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    if (rowPresenter.punchAttributeType == OEFAttribute) {
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    if (rowPresenter.punchAttributeType == TaskAttribute) {
        NSString *project = self.punch.project.name;
        BOOL isValidProjectFilled = ([self isValidString:project] &&
                                     ![project isEqualToString:RPLocalizedString(@"None", nil)]);
        if (!isValidProjectFilled) {
            cell.userInteractionEnabled = NO;
            cell.value.textColor = [self.theme attributeDisabledValueLabelColor];
        }
    }


}

- (void)configureDynamicTextViewCell:(DynamicTextTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PunchAttributeRowPresenter *rowPresenter = self.tableRows[indexPath.row];
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.title.font = [self.theme attributeTitleLabelFont];
    cell.title.textColor = [self.theme attributeTitleLabelColor];
    BOOL isValidTitle = [self isValidString:rowPresenter.title];
    if (!isValidTitle)
    {
        cell.title.text = RPLocalizedString(@"", @"");
    }
    else
    {
        cell.title.text = rowPresenter.title;
    }


    cell.textView.font = [self.theme attributeValueLabelFont];
    cell.textView.textColor = [self.theme attributeValueLabelColor];
    BOOL isValidDetails = [self isValidString:rowPresenter.text];
    if (!isValidDetails)
    {
        cell.textView.text = RPLocalizedString(@"", @"");
    }
    else
    {
        cell.textView.text = rowPresenter.text;
    }


    if ([self.punchRulesStorage canEditNonTimeFields]
        ||[self.punchRulesStorage canEditTimePunch])
    {
        cell.userInteractionEnabled = YES;
    }
    
}

-(BOOL)canAccessProject
{
    if (self.punch.actionType == PunchActionTypePunchIn||self.punch.actionType == PunchActionTypeTransfer) {
        switch (self.flowType) {
            case UserFlowContext:
                return [self.punchRulesStorage hasProjectAccess];
                break;
            case SupervisorFlowContext:
                return [self.reporteePunchRulesStorage canAccessProjectUserWithUri:self.userUri];
                break;
                
            default:
                break;
        }
    }
    return NO;
}

-(BOOL)canAccessClient
{
    if (self.punch.actionType == PunchActionTypePunchIn||self.punch.actionType == PunchActionTypeTransfer) {
        switch (self.flowType) {
            case UserFlowContext:
                return [self.punchRulesStorage hasClientAccess];
                break;
            case SupervisorFlowContext:
                return [self.reporteePunchRulesStorage canAccessClientUserWithUri:self.userUri];
                break;
                
            default:
                break;
        }
    }
    return NO;
    
}

-(BOOL)canAccessActivity
{
    if (self.punch.actionType == PunchActionTypePunchIn||self.punch.actionType == PunchActionTypeTransfer) {
        switch (self.flowType) {
            case UserFlowContext:
                return [self.punchRulesStorage hasActivityAccess];
                break;
            case SupervisorFlowContext:
                return [self.reporteePunchRulesStorage canAccessActivityUserWithUri:self.userUri];
                break;

            default:
                break;
        }
    }
    return NO;
}

- (BOOL)isProjectMandatory
{
    if (self.punch.actionType == PunchActionTypePunchIn||self.punch.actionType == PunchActionTypeTransfer) {
        switch (self.flowType) {
            case UserFlowContext:
                return [self.punchRulesStorage isProjectTaskSelectionRequired];
                break;
            case SupervisorFlowContext:
                return [self.reporteePunchRulesStorage isReporteeProjectTaskSelectionRequired:self.userUri];
                break;
                
            default:
                break;
        }
    }
    return NO;
}

- (BOOL)isActivityMandatory
{
    if (self.punch.actionType == PunchActionTypePunchIn||self.punch.actionType == PunchActionTypeTransfer) {
        switch (self.flowType) {
            case UserFlowContext:
                return [self.punchRulesStorage isActivitySelectionRequired];
                break;
            case SupervisorFlowContext:
                return [self.reporteePunchRulesStorage isReporteeActivitySelectionRequired:self.userUri];
                break;
                
            default:
                break;
        }
    }
    return NO;
}



-(SelectionScreenType)screenTypeForRowWithPresenter:(PunchAttributeRowPresenter *)rowPresenter
{
    PunchAttribute punchAttribute = rowPresenter.punchAttributeType;
    switch (punchAttribute) {
        case ClientAttribute:
            return ClientSelection;
            break;
        case ProjectAttribute:
            return ProjectSelection;
            break;
        case TaskAttribute:
            return TaskSelection;
            break;
        case ActivityAttribute:
            return ActivitySelection;
            break;

        default:
            break;
    }
    return SelectionScreenTypeNone;
}

-(void)checkForDefaultActivity
{
    [self.defaultActivityStorage setUpWithUserUri:self.userUri];
    NSDictionary *defaultActivity = [self.defaultActivityStorage defaultActivityDetails];
    BOOL defaultActivityAvailable = (defaultActivity != nil && ![defaultActivity isKindOfClass:[NSNull class]]);
    BOOL isManualPunch = ([self.punch isKindOfClass:[LocalPunch class]]);
    BOOL hasPlaceHoldeValue = (self.punch.activity == nil || [self.punch.activity isKindOfClass:[NSNull class]]);

    if (isManualPunch && defaultActivityAvailable && hasPlaceHoldeValue) {
        NSString *name = defaultActivity[@"default_activity_name"];
        if (![name isEqualToString:@""]) {
            NSString *uri =  defaultActivity[@"default_activity_uri"];
            Activity *activity = [[Activity alloc] initWithName:name uri:uri];
            UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
            self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:nil requestID:self.punch.requestID activity:[activity copy] client:nil oefTypes:self.punch.oefTypesArray address:self.punch.address userURI:self.punch.userURI image:image task:nil date:self.punch.date];
            [self.tableView reloadData];
            [self.delegate punchAttributeController:self didIntendToUpdateDefaultActivity:activity];
        }
    }
}

-(NSArray *)genarateOEFRowPresenterRowsForPunch:(id<Punch>)punch
{
    NSMutableArray *oefRowPresenterRows =[@[]mutableCopy];
    
    for (OEFType *oefType in punch.oefTypesArray)
    {
        NSString *valueText = nil;
        NSString *oefPlaceHolderText = nil;

        if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
        {
            valueText = oefType.oefTextValue;
            if (self.punchAttributeScreentype == PunchAttributeScreenTypeADD)
            {
                oefPlaceHolderText = RPLocalizedString(TextOEFPlaceholder, @"");;
            }
            else
            {
                oefPlaceHolderText = RPLocalizedString(@"None", @"");
            }
        }
        else if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
        {
            valueText = oefType.oefNumericValue;
            if (self.punchAttributeScreentype == PunchAttributeScreenTypeADD)
            {
                oefPlaceHolderText = RPLocalizedString(NumericOEFPlaceholder, @"");;
            }
            else
            {
                oefPlaceHolderText = RPLocalizedString(@"None", @"");
            }
        }
        else if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
        {
            valueText = oefType.oefDropdownOptionValue;
            if (self.punchAttributeScreentype == PunchAttributeScreenTypeADD)
            {
                oefPlaceHolderText = RPLocalizedString(DropDownOEFPlaceholder, @"");;
            }
            else
            {
                oefPlaceHolderText = RPLocalizedString(@"None", @"");
            }
        }

        valueText = valueText == nil || valueText == (id)[NSNull null] ? oefPlaceHolderText : valueText;

        PunchAttributeRowPresenter *oefRowPresenter = [[PunchAttributeRowPresenter alloc]initWithRowType:OEFAttribute
                                                                                                   title:oefType.oefName
                                                                                                    text:valueText];
        [oefRowPresenterRows addObject:oefRowPresenter];
    }

    return oefRowPresenterRows;
}

-(NSInteger)rowIndexForOEFTypes
{
    int checkRow = 0;
    if(self.punch.actionType == PunchActionTypePunchOut || self.punch.actionType == PunchActionTypeStartBreak)
    {
        checkRow = 0;
    }
    else
    {
        BOOL canAccessClient = [self.astroClientPermissionStorage userHasClientPermission];
        BOOL canAccessProject = [self canAccessProject];
        BOOL canAccessActivity = [self canAccessActivity];
        if (canAccessActivity)
        {
            checkRow = 1;
        }
        else if (canAccessProject)
        {
            if (canAccessClient)
            {
                checkRow = 3;
            }
            else
            {
                checkRow = 2;
            }
        }

    }

    return checkRow;
}

#pragma mark - <DynamicTextTableViewCellDelegate>

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didUpdateTextView:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    [UIView setAnimationsEnabled:NO];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    NSInteger oefIndex = (NSInteger) dynamicTextTableViewCell.tag - [self rowIndexForOEFTypes];
    
    OEFType *oefType = self.punch.oefTypesArray[oefIndex];
    OEFType *newOEFType = [self getUpdatedOEFTypeFromOEFTypeObject:oefType textView:textView];
    
    NSError *validationError = [self validateOEFType:newOEFType injector:self.injector];
    if(!self.alertViewVisible && validationError != nil) {
        textView.text = self.oldTexviewValue;
        textView.tag = DYNAMIC_TEXT_VIEW_TAG_INDEX + oefIndex; //Fix for : TCM-238
        self.dynamicCellTextViewTag = textView.tag; //Fix for : TCM-238
        [textView resignFirstResponder]; //Fix for : TCM-238
        [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"") delegate:self];
        self.alertViewVisible = YES;
        return;
    }

    self.oldTexviewValue = textView.text;
    
    [self.delegate punchAttributeController:self didUpdateTableViewWithHeight:self.tableView.contentSize.height + 125];
    [self.delegate punchAttributeController:self didScrolltoSubview:textView];
    

}

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didBeginEditingTextView:(UITextView *)textView
{
    self.oldTexviewValue = textView.text;

    if (textView.text!=nil)
    {
        if ([textView.text isEqualToString:RPLocalizedString(@"None", @"")] || [textView.text isEqualToString:RPLocalizedString(NumericOEFPlaceholder, @"")] || [textView.text isEqualToString:RPLocalizedString(TextOEFPlaceholder, @"")])
        {
            textView.text = @"";
        }
    }

    NSInteger oefIndex = (NSInteger) dynamicTextTableViewCell.tag - [self rowIndexForOEFTypes];

    OEFType *oefType = self.punch.oefTypesArray[oefIndex];

    if (oefType.disabled)
    {

        [textView setEditable:NO];

        if (!self.alertViewVisible)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(@"This field has been disabled. Contact your Administrator for more details.",@"")
                                                      title:nil
                                                        tag:LONG_MIN];
            self.alertViewVisible = YES;
        }

    }
    
    [self.delegate punchAttributeController:self didScrolltoSubview:textView];
}



- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didEndEditingTextView:(UITextView *)textView
{

    NSInteger oefIndex = (NSInteger) dynamicTextTableViewCell.tag - [self rowIndexForOEFTypes];
    OEFType *oefType = self.punch.oefTypesArray[oefIndex];
    
    NSString *oefValue = nil;
    NSMutableArray *oefTypesArray = [NSMutableArray arrayWithArray:self.punch.oefTypesArray];

    OEFType *newOEFType = [self getUpdatedOEFTypeFromOEFTypeObject:oefType textView:textView];
    [oefTypesArray replaceObjectAtIndex:oefIndex withObject:newOEFType];

    if(!IsNotEmptyString(textView.text)) {
        oefValue = [self getPlaceholderTextByOEFType:oefType screenType:self.punchAttributeScreentype];
        textView.text = oefValue;
    }

    UIImage *image = [self.punch respondsToSelector:@selector(image)] ? self.punch.image : nil;
    self.punch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:self.punch.actionType lastSyncTime:[NSDate date] breakType:self.punch.breakType location:self.punch.location project:self.punch.project requestID:self.punch.requestID activity:self.punch.activity client:self.punch.client oefTypes:oefTypesArray address:self.punch.address userURI:self.punch.userURI image:image task:self.punch.task date:self.punch.date];

    [self setupDataForTableView];
    [self.delegate punchAttributeController:self didIntendToUpdateTextOrNumericOEFTypes:oefTypesArray];
    self.oldTexviewValue = @"";
}

#pragma mark <AlertView Delegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    self.alertViewVisible = NO;
    UITextView *textView_ = [self.tableView viewWithTag:self.dynamicCellTextViewTag]; //Fix for : TCM-238
    [textView_ becomeFirstResponder]; //Fix for : TCM-238

}

@end
