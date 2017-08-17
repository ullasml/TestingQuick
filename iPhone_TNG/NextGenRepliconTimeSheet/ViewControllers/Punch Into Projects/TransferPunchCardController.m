#import "TransferPunchCardController.h"
#import "Theme.h"
#import "Constants.h"
#import "PunchCardObject.h"
#import <Blindside/BSInjector.h>
#import "SelectionController.h"
#import "PunchCardStylist.h"
#import "Constants.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "PunchValidator.h"
#import "TimesheetClientProjectTaskRepository.h"
#import "UserSession.h"
#import "Util.h"
#import "DynamicTextTableViewCell.h"
#import "OEFType.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "GUIDProvider.h"
#import "UIViewController+OEFValuePopulation.h"
#import "UITextView+DisableCopyPaste.h"
#import "InjectorKeys.h"

#define DYNAMIC_TEXT_VIEW_TAG_INDEX     3000

@interface TransferPunchCardController ()
@property (weak, nonatomic) IBOutlet UIButton *transferPunchCardButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic) PunchCardObject                               *punchCardObject;
@property (nonatomic) PunchCardObject                               *localPunchCardObject;
@property (nonatomic) id<BSInjector>                                injector;
@property (nonatomic) SelectionController                           *selectionController;
@property (nonatomic) PunchCardStylist                              *punchCardStylist;
@property (nonatomic,weak) id <TransferPunchCardControllerDelegate> delegate;
@property (nonatomic) id<UserSession>                               userSession;
@property (nonatomic) UserPermissionsStorage                        *userPermissionStorage;
@property (nonatomic) NSArray                                       *oefTypesArray;
@property (nonatomic) NSString                                      *selectedDropDownOEFUri;
@property (nonatomic) GUIDProvider                                  *guidProvider;
@property (nonatomic) NSString                                      *oldTextViewValue;
@property (nonatomic, assign) NSInteger                             dynamicCellTextViewTag;
@property (nonatomic,assign) BOOL                                   alertViewVisible;
@property (nonatomic, assign)WorkFlowType                           flowType;

@end

#define ROW_HEIGHT  70.0


@implementation TransferPunchCardController

- (instancetype)initWithSelectionController:(SelectionController *)selectionController
                      userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                           punchCardStylist:(PunchCardStylist *)punchCardStylist
                               guidProvider:(GUIDProvider *)guidProvider
                                userSession:(id <UserSession>)userSession {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.selectionController = selectionController;
        self.userPermissionStorage = userPermissionStorage;
        self.punchCardStylist = punchCardStylist;
        self.guidProvider = guidProvider;
        self.userSession = userSession;
    }
    return self;
}

- (void)setUpWithDelegate:(id <TransferPunchCardControllerDelegate>)delegate
          punchCardObject:(PunchCardObject *)punchCardObject
                 oefTypes:(NSArray *)oefTypes
                 flowType:(WorkFlowType)flowType {

    self.delegate = delegate;
    self.oefTypesArray = oefTypes;
    self.punchCardObject = [[PunchCardObject alloc]
                            initWithClientType:[punchCardObject.clientType copy]
                            projectType:[punchCardObject.projectType copy]
                            oefTypesArray:[self.oefTypesArray copy]
                            breakType:punchCardObject.breakType
                            taskType:[punchCardObject.taskType copy]
                            activity:[punchCardObject.activity copy]
                            uri:[self.guidProvider guid]];

    self.flowType = flowType;
    
   [self setUpLocalPunchCardObject:punchCardObject];
}

- (void)updatePunchCardObject:(PunchCardObject *)punchCardObject
{
    self.punchCardObject = [[PunchCardObject alloc]
                            initWithClientType:[punchCardObject.clientType copy]
                            projectType:[punchCardObject.projectType copy]
                            oefTypesArray:[self.oefTypesArray copy]
                            breakType:punchCardObject.breakType
                            taskType:[punchCardObject.taskType copy]
                            activity:[punchCardObject.activity copy]
                            uri:[self.guidProvider guid]];
    
    [self setUpLocalPunchCardObject:punchCardObject];
    
    [self.tableView reloadData];
}

- (void) setUpLocalPunchCardObject:(PunchCardObject *)punchCardObject {
    ClientType *localClientType = [[ClientType alloc] initWithName:nil uri:nil];
    ClientType *client = IsValidClient(punchCardObject.clientType) ? punchCardObject.clientType : localClientType;
    
    ProjectType *project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:punchCardObject.projectType.hasTasksAvailableForTimeAllocation isTimeAllocationAllowed:punchCardObject.projectType.isTimeAllocationAllowed projectPeriod:punchCardObject.projectType.projectPeriod clientType:client name:punchCardObject.projectType.name uri:punchCardObject.projectType.uri];
    
    self.localPunchCardObject = [[PunchCardObject alloc]
                                 initWithClientType:client
                                 projectType:project
                                 oefTypesArray:[self.oefTypesArray copy]
                                 breakType:nil
                                 taskType:[punchCardObject.taskType copy]
                                 activity:nil
                                 uri:[self.guidProvider guid]];
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

    self.tableView.estimatedRowHeight = ROW_HEIGHT;

    self.transferPunchCardButton.backgroundColor = [self.theme transferPunchButtonButtonColor];
    self.transferPunchCardButton.titleLabel.font = [self.theme transferPunchButtonTitleLabelFont];
    self.transferPunchCardButton.layer.cornerRadius = [self.theme transferPunchButtonCornerRadius];
    self.transferPunchCardButton.layer.borderColor = [self.theme transferPunchButtonBorderColor];
    self.transferPunchCardButton.layer.borderWidth = [self.theme transferPunchButtonBorderWidth];
    self.transferPunchCardButton.titleLabel.textColor = [self.theme transferPunchButtonTitleColor];

    NSString *buttonTitle = [self getTitleBasedOnFlowType:self.flowType];

    [self.transferPunchCardButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    UINib *nib = [UINib nibWithNibName:@"DynamicTextTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DynamicTextViewCell"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat containerHeight = self.tableView.contentSize.height;
    [self.delegate transferPunchCardController:self didUpdateHeight:containerHeight + 75.0];
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
    return hasClientAccess ? 3+self.oefTypesArray.count : 2+self.oefTypesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellToReturn=nil;
    
    BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
    if ([self isOEFRow:indexPath])
    {
        
        static NSString *simpleTableIdentifier = @"DynamicTextViewCell";
        
        DynamicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier
                                                                         forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DynamicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        
        OEFType *oefType = self.oefTypesArray[indexPath.row - [self rowIndexForOEFTypes] - 1];
        
        if (![self isValidString:oefType.oefName])
        {
            cell.title.text = RPLocalizedString(@"", @"");
        }
        else
        {
            cell.title.text = oefType.oefName;
        }
        
        
        
        if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
        {
            if (![self isValidString:oefType.oefNumericValue])
            {
                cell.textView.text = RPLocalizedString(NumericOEFPlaceholder, @"");
            }
            else
            {
                cell.textView.text = oefType.oefNumericValue;
            }
            
            [cell setUpWithDelegate:self withKeyboardType:NumericKeyboard tag:indexPath.row];
        }
        else if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
        {
            if (![self isValidString:oefType.oefDropdownOptionValue])
            {
                cell.textValueLabel.text = RPLocalizedString(DropDownOEFPlaceholder, @"");
            }
            else
            {
                cell.textValueLabel.text = oefType.oefDropdownOptionValue;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell setUpWithDelegate:self withKeyboardType:NoKeyboard tag:indexPath.row];
        }
        else
        {
            if (![self isValidString:oefType.oefTextValue])
            {
                cell.textView.text = RPLocalizedString(TextOEFPlaceholder, @"");
            }
            else
            {
                cell.textView.text = oefType.oefTextValue;
            }
            
            [cell setUpWithDelegate:self withKeyboardType:DefaultKeyboard tag:indexPath.row];
        }
        
        
        cell.title.font = [self.theme transferCardSelectionCellNameFont];
        cell.textView.font =[self.theme transferCardSelectionCellValueFont];
        cell.title.textColor = [self.theme transferCardSelectionCellNameFontColor];
        cell.textView.textColor = [self.theme transferCardSelectionCellValueFontColor];
        cell.textValueLabel.textColor = [self.theme transferCardSelectionCellValueFontColor];
        cell.textValueLabel.font = [self.theme transferCardSelectionCellValueFont];
        cellToReturn = cell;
        
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                       reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [self cellTextValueForIndexPath:indexPath];
        
        UIColor *enabledValueColor = [self.theme transferCardSelectionCellValueFontColor];
        UIColor *disabledValueColor = [self.theme transferCardSelectionCellValueDisabledFontColor];
        
        cell.textLabel.font = [self.theme transferCardSelectionCellNameFont];
        cell.textLabel.textColor = [self.theme transferCardSelectionCellNameFontColor];
        
        cell.detailTextLabel.font = [self.theme transferCardSelectionCellValueFont];
        cell.detailTextLabel.textColor = enabledValueColor;
        
        NSString *firstRowPlaceHolder = RPLocalizedString(@"Client", nil);
        NSString *secondRowPlaceHolder = RPLocalizedString(@"Project", nil);
        NSString *thirdRowPlaceHolder = RPLocalizedString(@"Task", nil);
        
        if (!hasClientAccess) {
            firstRowPlaceHolder = RPLocalizedString(@"Project", nil);
            secondRowPlaceHolder = RPLocalizedString(@"Task", nil);
        }
        
        if (indexPath.row == 0)
            cell.textLabel.text = firstRowPlaceHolder;
        else if (indexPath.row == 1)
            cell.textLabel.text = secondRowPlaceHolder;
        else if (indexPath.row == 2)
            cell.textLabel.text = thirdRowPlaceHolder;
        
        BOOL checkForDisableTaskField = (!hasClientAccess && indexPath.row==1);
        if (checkForDisableTaskField || indexPath.row == 2) {
            if (self.punchCardObject.projectType == nil)
            {
                cell.userInteractionEnabled = NO;
                cell.detailTextLabel.textColor = disabledValueColor;
            }
            else
            {
                cell.userInteractionEnabled = YES;
                cell.detailTextLabel.textColor = enabledValueColor;
            }
            BOOL isValidProject = (self.punchCardObject.projectType != nil &&
                                   self.punchCardObject.projectType.uri != nil &&
                                   self.punchCardObject.projectType.uri.length > 0);
            
            BOOL isNoneTask = [[self taskName] isEqualToString:RPLocalizedString(@"None", nil)];
            
            if(isValidProject && isNoneTask)
                
            {
                cell.detailTextLabel.text = RPLocalizedString(@"None", nil);
                cell.userInteractionEnabled = YES;
                cell.detailTextLabel.textColor = enabledValueColor;
            }
        }

        cellToReturn = cell;
        }
    return cellToReturn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [self rowIndexForOEFTypes])
    {
        return UITableViewAutomaticDimension;
    }
    else
    {
        return ROW_HEIGHT;
    }
}



#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOEFRow:indexPath])
    {
        OEFType *oefType = self.oefTypesArray[indexPath.row - [self rowIndexForOEFTypes] - 1];
        if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
        {
            [self.view endEditing:YES];
            self.selectedDropDownOEFUri = oefType.oefUri;
            SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
            [selectionController setUpWithSelectionScreenType:OEFDropDownSelection
                                              punchCardObject:self.localPunchCardObject
                                                     delegate:self];
            self.navigationController.navigationBar.hidden = NO;
            [self.navigationController pushViewController:selectionController animated:YES];
        }
        else
        {
            DynamicTextTableViewCell *dynamicTextTableViewCell = [tableView cellForRowAtIndexPath:indexPath];
            [dynamicTextTableViewCell.textView becomeFirstResponder];
        }
    }
    else{
        
        SelectionScreenType screenType;
        BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
        NSInteger firstRowType = ClientSelection;
        NSInteger secondRowType = ProjectSelection;
        NSInteger thirdRowType = TaskSelection;
        
        self.localPunchCardObject = [self setProjectActivityRequiredInPunchCardObject];
        
        if (!hasClientAccess) {
            firstRowType = ProjectSelection;
            secondRowType = TaskSelection;
        }
        
        if (indexPath.row == 0)
            screenType = firstRowType;
        else if (indexPath.row == 1)
            screenType = secondRowType;
        else
            screenType = thirdRowType;

        [self.view endEditing:YES];
        SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
        [selectionController setUpWithSelectionScreenType:screenType
                                          punchCardObject:self.localPunchCardObject
                                                 delegate:self];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:selectionController animated:YES];
    }
}

- (PunchCardObject *)setProjectActivityRequiredInPunchCardObject {
    
    PunchCardObject *punchCard = self.localPunchCardObject;
    
    
    if([self.userPermissionStorage hasProjectAccess]) {
        
        ProjectType *project = punchCard.projectType;
        
        if(project && [project respondsToSelector:@selector(isProjectTypeRequired)]) {
            project.isProjectTypeRequired = self.userPermissionStorage.isProjectTaskSelectionRequired;
        } else {
            project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                           isTimeAllocationAllowed:NO
                                                                     projectPeriod:nil
                                                                        clientType:nil
                                                                              name:@""
                                                                               uri:nil];
            
            project.isProjectTypeRequired = self.userPermissionStorage.isProjectTaskSelectionRequired;
        }
        
        punchCard = [[PunchCardObject alloc] initWithClientType:self.localPunchCardObject.clientType
                                                    projectType:project
                                                  oefTypesArray:self.localPunchCardObject.oefTypesArray
                                                      breakType:self.localPunchCardObject.breakType
                                                       taskType:self.localPunchCardObject.taskType
                                                       activity:self.localPunchCardObject.activity
                                                            uri:self.localPunchCardObject.uri];
        
    } else if([self .userPermissionStorage hasActivityAccess]) {
        
        Activity *activity_= self.punchCardObject.activity;
        
        if(activity_ && [activity_ respondsToSelector:@selector(isActivityRequired)]) {
            activity_.isActivityRequired = self.userPermissionStorage.isActivitySelectionRequired;
            
        } else {
            
            activity_ = [[Activity alloc] initWithName:nil uri:nil];
            activity_.isActivityRequired = self.userPermissionStorage.isActivitySelectionRequired;
        }
        
        punchCard = [[PunchCardObject alloc] initWithClientType:self.localPunchCardObject.clientType
                                                    projectType:self.localPunchCardObject.projectType
                                                  oefTypesArray:self.localPunchCardObject.oefTypesArray
                                                      breakType:self.localPunchCardObject.breakType
                                                       taskType:self.localPunchCardObject.taskType
                                                       activity:activity_
                                                            uri:self.localPunchCardObject.uri];
        
    }
    
    return punchCard;
}

#pragma mark - <SelectionControllerDelegate>

-(void)selectionController:(SelectionController *)selectionController didChooseClient:(ClientType *)client
{
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                         initWithClientType:[client copy]
                                                                projectType:nil
                                                              oefTypesArray:[self.oefTypesArray copy]
                                                                  breakType:nil
                                                                   taskType:nil
                                                                   activity:nil
                                                                        uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];
}

-(void)selectionController:(SelectionController *)selectionController didChooseProject:(ProjectType *)project
{
    BOOL isClientPresent = [self isValidString:project.client.uri];
    ClientType *client = isClientPresent ? [project.client copy] : nil;
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                         initWithClientType:client
                                                                projectType:[project copy]
                                                              oefTypesArray:[self.oefTypesArray copy]
                                                                  breakType:nil
                                                                   taskType:nil
                                                                   activity:nil
                                                                        uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];

}
-(void)selectionController:(SelectionController *)selectionController didChooseTask:(TaskType *)task
{

    BOOL isClientPresent = [self isValidString:self.punchCardObject.clientType.uri];
    ClientType *client = isClientPresent ? [self.punchCardObject.clientType copy] : nil;

    BOOL isProjectPresent = [self isValidString:self.punchCardObject.projectType.uri];
    ProjectType *project = isProjectPresent ? [self.punchCardObject.projectType copy] : nil;

    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                         initWithClientType:client
                                                                projectType:project
                                                              oefTypesArray:[self.oefTypesArray copy]
                                                                  breakType:nil
                                                                   taskType:[task copy]
                                                                   activity:nil
                                                                        uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];
}

-(void)selectionController:(SelectionController *)selectionController didChooseDropDownOEF:(OEFDropDownType *)oefDropDownType
{
    int oefIndex = 0;
    for (OEFType *oefType in self.oefTypesArray)
    {
        if ([oefType.oefUri isEqualToString:self.selectedDropDownOEFUri])
        {
            OEFType *newOEFType = [[OEFType alloc] initWithUri:oefType.oefUri definitionTypeUri:oefType.oefDefinitionTypeUri name:oefType.oefName punchActionType:oefType.oefPunchActionType numericValue:oefType.oefNumericValue textValue:oefType.oefTextValue dropdownOptionUri:oefDropDownType.uri dropdownOptionValue:oefDropDownType.name collectAtTimeOfPunch:oefType.collectAtTimeOfPunch disabled:oefType.disabled];
            
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithArray:self.oefTypesArray];
            [oefTypesArray replaceObjectAtIndex:oefIndex withObject:newOEFType];
            self.oefTypesArray = oefTypesArray;
            break;
        }
        
        oefIndex++;
    }
    
    
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:self.punchCardObject.clientType
                                                                      projectType:self.punchCardObject.projectType
                                                                    oefTypesArray:[self.oefTypesArray copy]
                                                                        breakType:self.punchCardObject.breakType
                                                                         taskType:self.punchCardObject.taskType
                                                                         activity:self.punchCardObject.activity
                                                                              uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];

    [self viewDidLayoutSubviews];
    
}


-(id <ClientProjectTaskRepository> )selectionControllerNeedsClientProjectTaskRepository
{
    TimesheetClientProjectTaskRepository *timesheetClientProjectTaskRepository = [self.injector getInstance:[TimesheetClientProjectTaskRepository class]];
    [timesheetClientProjectTaskRepository setUpWithUserUri:self.userSession.currentUserURI];
    return timesheetClientProjectTaskRepository;
}

-(OEFDropDownRepository *)selectionControllerNeedsOEFDropDownRepository
{
    OEFDropDownRepository *oefDropDownRepository = [self.injector getInstance:[OEFDropDownRepository class]];
    [oefDropDownRepository setUpWithDropDownOEFUri:self.selectedDropDownOEFUri userUri:self.userSession.currentUserURI];
    return oefDropDownRepository;
}

#pragma mark - CreatePunchCard Action

- (IBAction)didIntendToTranferPunch:(id)sender
{
    NSError *validationError = [self validatePunch];
    if (validationError == nil) {
        [self reloadDataOnViewWithPunchCard:self.punchCardObject];

        [self takeAppropriateActionsForflow];
    }
    else
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"")];
    }
}

- (void)takeAppropriateActionsForflow {
    switch (self.flowType) {
        case TransferWorkFlowType:

            [self.delegate transferPunchCardController:self didIntendToTransferPunchWithObject:self.punchCardObject];

            break;
        case ResumeWorkFlowType: {
            if([self.userPermissionStorage hasProjectAccess]) {
                [self.delegate transferPunchCardController:self didIntendToResumeWorkForProjectPunchWithObject:self.punchCardObject];

            } else if([self.userPermissionStorage hasActivityAccess]){
                [self.delegate transferPunchCardController:self didIntendToResumeWorkForActivityPunchWithObject:self.punchCardObject];
            }
        }
        break;

        default:
            break;
    }
}

#pragma mark - Private

-(NSString *)cellTextValueForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
    if (indexPath.row == 0)
    {
        if (hasClientAccess)
            return [self clientName];
        else
            return [self projectName];
    }
    else if (indexPath.row == 1)
    {
        if (hasClientAccess)
            return [self projectName];
        else
            return [self taskName];
    }
    else
    {
        return [self taskName];
    }
}

-(void)reloadDataOnViewWithPunchCard:(PunchCardObject *)punchCard
{
    
    ClientType *localClientType = [[ClientType alloc] initWithName:nil uri:nil];
    ClientType *client = IsValidClient(punchCard.clientType) ? punchCard.clientType : localClientType;
    
    self.punchCardObject = [[PunchCardObject alloc]
                            initWithClientType:client
                            projectType:punchCard.projectType
                            oefTypesArray:punchCard.oefTypesArray
                            breakType:nil
                            taskType:punchCard.taskType
                            activity:nil
                            uri:[self.guidProvider guid]];
    

    
    self.localPunchCardObject = [[PunchCardObject alloc]
                                 initWithClientType:punchCard.clientType
                                 projectType:punchCard.projectType
                                 oefTypesArray:punchCard.oefTypesArray
                                 breakType:nil
                                 taskType:punchCard.taskType
                                 activity:nil
                                 uri:[self.guidProvider guid]];
    

    [self.tableView reloadData];
}


-(NSString *)clientName
{
    NSString *clientInProject = self.localPunchCardObject.projectType.client.name;
    BOOL isClientInProjectPresent = [self isValidString:clientInProject];
    if (isClientInProjectPresent) {
        return clientInProject;
    }
    NSString *client = self.localPunchCardObject.clientType.name;
    BOOL isClientPresent = [self isValidString:client];
    if (isClientPresent) {
        return client;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)projectName
{
    NSString *project = self.localPunchCardObject.projectType.name;
    BOOL isProjectPresent = [self isValidString:project];
    if (isProjectPresent) {
        return project;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)taskName
{
    NSString *task = self.localPunchCardObject.taskType.name;
    BOOL isTaskPresent = [self isValidString:task];
    if (isTaskPresent) {
        return task;
    }
    return RPLocalizedString(@"Select", nil);
}


-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}

-(NSError *)validatePunch {
    PunchValidator *punchValidator = [self.injector getInstance:[PunchValidator class]];
    return [punchValidator validatePunchWithClientType:self.punchCardObject.clientType
                                           projectType:self.punchCardObject.projectType
                                              taskType:self.punchCardObject.taskType
                                          activityType:self.punchCardObject.activity
                                               userUri:nil];
    
}

-(BOOL)isOEFRow:(NSIndexPath *)indexPath
{
    if (indexPath.row > [self rowIndexForOEFTypes])
    {
        return YES;
    }
    return NO;
}

-(int)rowIndexForOEFTypes
{
    int checkRow =0;
    BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
    if (hasClientAccess)
        checkRow = 2;
    else
        checkRow = 1;
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
    
    NSInteger oefIndex = (NSInteger) dynamicTextTableViewCell.tag - [self rowIndexForOEFTypes] - 1;
    
    OEFType *oefType = self.punchCardObject.oefTypesArray[oefIndex];
    OEFType *newOEFType = [self getUpdatedOEFTypeFromOEFTypeObject:oefType textView:textView];
    
    NSError *validationError = [self validateOEFType:newOEFType injector:self.injector];
    if(!self.alertViewVisible && validationError != nil) {
        textView.text = self.oldTextViewValue;
        textView.tag = DYNAMIC_TEXT_VIEW_TAG_INDEX + oefIndex; //Fix for : TCM-238
        self.dynamicCellTextViewTag = textView.tag; //Fix for : TCM-238
        [textView resignFirstResponder]; //Fix for : TCM-238
        [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"") delegate:self];
        self.alertViewVisible = YES;
        return;
    }
    
    self.oldTextViewValue = textView.text;
    
    [self.delegate transferPunchCardController:self didUpdateHeight:self.tableView.contentSize.height + 100];
    [self.delegate transferPunchCardController:self didScrolltoSubview:textView];
}

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didBeginEditingTextView:(UITextView *)textView
{
    self.oldTextViewValue = textView.text;
    if (textView.text!=nil)
    {
        if ([textView.text isEqualToString:RPLocalizedString(NumericOEFPlaceholder, @"")] || [textView.text isEqualToString:RPLocalizedString(TextOEFPlaceholder, @"")])
        {
            textView.text = @"";
        }
    }
    
    [self.delegate transferPunchCardController:self didScrolltoSubview:textView];
}

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didEndEditingTextView:(UITextView *)textView
{
    NSString *oefValue = textView.text;
    
    NSInteger oefIndex = (NSInteger) dynamicTextTableViewCell.tag - [self rowIndexForOEFTypes] - 1;
    
    OEFType *oefType = self.oefTypesArray[oefIndex];
    
    NSMutableArray *oefTypesArray = [NSMutableArray arrayWithArray:self.oefTypesArray];

    OEFType *newOEFType = [self getUpdatedOEFTypeFromOEFTypeObject:oefType textView:textView];
    [oefTypesArray replaceObjectAtIndex:oefIndex withObject:newOEFType];

    if(!IsNotEmptyString(textView.text)) {
        oefValue = [self getPlaceholderTextByOEFType:oefType screenType:PunchAttributeScreenTypeNONE];
        textView.text = oefValue;
    }
    self.oefTypesArray = oefTypesArray;
    
    
    self.punchCardObject = [[PunchCardObject alloc]
                            initWithClientType:self.punchCardObject
                            .clientType
                            projectType:self.punchCardObject
                            .projectType
                            oefTypesArray:oefTypesArray
                            breakType:NULL
                            taskType:self.punchCardObject
                            .taskType
                            activity:self.punchCardObject
                            .activity
                            uri:[self.guidProvider guid]];
    
    self.oldTextViewValue = @"";
    
}

#pragma mark <AlertView Delegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.alertViewVisible = NO;
    UITextView *textView_ = [self.tableView viewWithTag:self.dynamicCellTextViewTag]; //Fix for : TCM-238
    [textView_ becomeFirstResponder]; //Fix for : TCM-238

}

#pragma mark - Button title Helper Methods

- (NSString *)getTitleBasedOnFlowType:(WorkFlowType)flowType {
    NSString *title = @"";
    switch (flowType) {
        case TransferWorkFlowType:
            title = RPLocalizedString(@"Transfer", nil);
            break;
        case ResumeWorkFlowType:
            title = RPLocalizedString(@"Resume Work", nil);
            break;

        default:
            break;
    }
    return title;
}


@end
