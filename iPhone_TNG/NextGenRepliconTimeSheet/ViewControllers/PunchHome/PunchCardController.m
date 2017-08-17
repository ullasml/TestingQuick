#import "PunchCardController.h"
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
#import "ClientProjectTaskRepository.h"
#import "UserPermissionsStorage.h"
#import "Activity.h"
#import "UserSession.h"
#import "DefaultActivityStorage.h"
#import "DynamicTextTableViewCell.h"
#import "OEFType.h"
#import "Util.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "UITextView+DisableCopyPaste.h"
#import "UIViewController+OEFValuePopulation.h"
#import "InjectorKeys.h"

#define DYNAMIC_TEXT_VIEW_TAG_INDEX     2000

@interface PunchCardController ()
@property (weak, nonatomic) IBOutlet UIButton *createPunchCardButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *punchActionButton;


@property (nonatomic) PunchCardObject *punchCardObject;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) SelectionController *selectionController;
@property (nonatomic) PunchCardStylist *punchCardStylist;
@property (nonatomic) UserPermissionsStorage *userPermissionStorage;
@property (nonatomic) DefaultActivityStorage *defaultActivityStorage;
@property (nonatomic,weak) id <PunchCardControllerDelegate> delegate;
@property (nonatomic) PunchCardType punchCardType;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) NSString *oldTextViewValue;
@property (nonatomic, assign) NSInteger dynamicCellTextViewTag;
@property (nonatomic,assign) BOOL alertViewVisible;

@property (nonatomic) NSArray *oefTypesArray;

@property (nonatomic) NSString *selectedDropDownOEFUri;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopPaddingConstraint;

@end


#define ROW_HEIGHT  70.0

@implementation PunchCardController

- (instancetype)initWithSelectionController:(SelectionController *)selectionController
                      userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                     defaultActivityStorage:(DefaultActivityStorage *)defaultActivityStorage
                           punchCardStylist:(PunchCardStylist *)punchCardStylist
                                userSession:(id <UserSession>)userSession
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.selectionController = selectionController;
        self.punchCardStylist = punchCardStylist;
        self.userPermissionStorage = userPermissionStorage;
        self.userSession = userSession;
        self.defaultActivityStorage =  defaultActivityStorage;
    }
    return self;
}

- (void)setUpWithPunchCardObject:(PunchCardObject *)punchCardObject
                   punchCardType:(PunchCardType)punchCardType
                        delegate:(id <PunchCardControllerDelegate>)delegate
                   oefTypesArray:(NSArray *)oefTypesArray
{
    self.punchCardObject = punchCardObject;
    self.delegate = delegate;
    self.punchCardType = punchCardType;
    self.oefTypesArray = oefTypesArray;
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
    if (self.punchCardType == DefaultClientProjectTaskPunchCard)
    {
        [self.punchCardStylist styleBorderForView:self.view];
    }
    else
    {
        self.tableViewTopPaddingConstraint.constant = 0.0;
    }
    self.tableView.estimatedRowHeight = ROW_HEIGHT;
    [self setUpButton];
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    if (hasActivityAccess)
        [self checkForDefaultActivity];

    UINib *nib = [UINib nibWithNibName:@"DynamicTextTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DynamicTextViewCell"];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat containerHeight = self.tableView.contentSize.height;
    [self.delegate punchCardController:self didUpdateHeight:containerHeight + 75.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedDropDownOEFUri = nil;
}

#pragma mark - <DefaultActivityCheck>

-(void)checkForDefaultActivity
{
    [self.defaultActivityStorage setUpWithUserUri:[self.userSession currentUserURI]];
    NSDictionary *defaultActivity = [self.defaultActivityStorage defaultActivityDetails];
    BOOL defaultActivityAvailable = (defaultActivity != nil && ![defaultActivity isKindOfClass:[NSNull class]]);
    BOOL hasPlaceHoldeValue = (self.punchCardObject.activity == nil || [self.punchCardObject.activity isKindOfClass:[NSNull class]]);
    if (defaultActivityAvailable && hasPlaceHoldeValue) {
        NSString *name = defaultActivity[@"default_activity_name"];
        if (![name isEqualToString:@""]) {
            NSString *uri =  defaultActivity[@"default_activity_uri"];
            Activity *activity = [[Activity alloc] initWithName:name uri:uri];
            self.punchCardObject = [[PunchCardObject alloc]
                                                     initWithClientType:nil
                                                            projectType:nil
                                                          oefTypesArray:[self.oefTypesArray copy]
                                                              breakType:NULL
                                                               taskType:nil
                                                               activity:activity
                                                                    uri:[Util getRandomGUID]];
        }
    }
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionStorage  hasProjectAccess];
    if (hasActivityAccess){
        return 1 + self.oefTypesArray.count;
    }
    else if (hasProjectAccess){
        BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
        return hasClientAccess ? 3+self.oefTypesArray.count : 2+self.oefTypesArray.count ;
    }
    else
    {
        return self.oefTypesArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    id cellToReturn=nil;

    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionStorage hasProjectAccess];
    BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
    if ([self isOEFRow:indexPath])
    {

        static NSString *simpleTableIdentifier = @"DynamicTextViewCell";

        DynamicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier
                                                                         forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DynamicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }

        OEFType *oefType = [self getOEFTypeByRow:(int)indexPath.row];

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


        cell.title.font = [self.theme selectionCellFont];
        cell.textView.font =[self.theme selectionCellValueFont];
        cell.textValueLabel.font =[self.theme selectionCellValueFont];
        cell.title.textColor = [self.theme selectionCellNameFontColor];
        cell.textView.textColor = [self.theme selectionCellValueFontColor];
        cell.textValueLabel.textColor = [self.theme selectionCellValueFontColor];

        cellToReturn = cell;

    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                       reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.text = [self cellTextValueForIndexPath:indexPath];
        cell.textLabel.font = [self.theme selectionCellFont];
        cell.detailTextLabel.font =[self.theme selectionCellValueFont];
        cell.textLabel.textColor = [self.theme selectionCellNameFontColor];
        cell.detailTextLabel.textColor = [self.theme selectionCellValueFontColor];

        if (hasActivityAccess && indexPath.row == 0)
        {
            cell.textLabel.text = RPLocalizedString(@"Activity", nil);
        }

        else if (hasProjectAccess)
        {
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
                    cell.detailTextLabel.textColor = [self.theme selectionCellValueDisabledFontColor];
                }
                else
                {
                    cell.userInteractionEnabled = YES;
                    cell.detailTextLabel.textColor = [self.theme selectionCellValueFontColor];

                }

                BOOL isValidProject = (self.punchCardObject.projectType != nil &&
                                       self.punchCardObject.projectType.uri != nil &&
                                       self.punchCardObject.projectType.uri.length > 0);

                BOOL isNoneTask = [[self taskName] isEqualToString:RPLocalizedString(@"None", nil)];

                if(isValidProject && isNoneTask)
                {
                    cell.detailTextLabel.text = RPLocalizedString(@"None", nil);
                    cell.userInteractionEnabled = YES;
                    cell.detailTextLabel.textColor = [self.theme selectionCellValueFontColor];
                }
            }
        }


        cellToReturn = cell;
    }

    return cellToReturn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOEFRow:indexPath])
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
        OEFType *oefType = [self getOEFTypeByRow:(int)indexPath.row];
        if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
        {
            [self.view endEditing:YES];
            self.selectedDropDownOEFUri = oefType.oefUri;
            SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
            [selectionController setUpWithSelectionScreenType:OEFDropDownSelection
                                              punchCardObject:self.punchCardObject
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
    else
    {
        SelectionScreenType screenType = SelectionScreenTypeNone;
        BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
        BOOL hasProjectAccess  = [self.userPermissionStorage hasProjectAccess];
        if (hasActivityAccess)
        {
            screenType = ActivitySelection;
            self.punchCardObject = [self setProjectActivityRequiredInPunchCardObject];
        }
        else if(hasProjectAccess)
        {
            BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
            NSInteger firstRowType = ClientSelection;
            NSInteger secondRowType = ProjectSelection;
            NSInteger thirdRowType = TaskSelection;
            
            
            self.punchCardObject = [self setProjectActivityRequiredInPunchCardObject];

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

        }

        [self.view endEditing:YES];

        SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
        [selectionController setUpWithSelectionScreenType:screenType
                                          punchCardObject:self.punchCardObject
                                                 delegate:self];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:selectionController animated:YES];
    }

}

- (PunchCardObject *)setProjectActivityRequiredInPunchCardObject {
    
    PunchCardObject *punchCard = self.punchCardObject;
    
    
    if([self.userPermissionStorage hasProjectAccess]) {
        
        ProjectType *project = punchCard.projectType;
        
        if(project && [project respondsToSelector:@selector(isProjectTypeRequired)]) {
            project.isProjectTypeRequired = self.userPermissionStorage.isProjectTaskSelectionRequired;
        } else {
            project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                           isTimeAllocationAllowed:NO
                                                                     projectPeriod:nil
                                                                        clientType:nil
                                                                              name:nil
                                                                               uri:nil];
            
            project.isProjectTypeRequired = self.userPermissionStorage.isProjectTaskSelectionRequired;
        }
        
        punchCard = [[PunchCardObject alloc] initWithClientType:self.punchCardObject.clientType
                                                    projectType:project
                                                  oefTypesArray:self.punchCardObject.oefTypesArray
                                                      breakType:self.punchCardObject.breakType
                                                       taskType:self.punchCardObject.taskType
                                                       activity:self.punchCardObject.activity
                                                            uri:self.punchCardObject.uri];
        
    } else if([self .userPermissionStorage hasActivityAccess]) {
        
        Activity *activity_= self.punchCardObject.activity;
        
        if(activity_ && [activity_ respondsToSelector:@selector(isActivityRequired)]) {
            activity_.isActivityRequired = self.userPermissionStorage.isActivitySelectionRequired;
            
        } else {
            
            activity_ = [[Activity alloc] initWithName:nil uri:nil];
            activity_.isActivityRequired = self.userPermissionStorage.isActivitySelectionRequired;
        }
        
        punchCard = [[PunchCardObject alloc] initWithClientType:self.punchCardObject.clientType
                                                    projectType:self.punchCardObject.projectType
                                                  oefTypesArray:self.punchCardObject.oefTypesArray
                                                      breakType:self.punchCardObject.breakType
                                                       taskType:self.punchCardObject.taskType
                                                       activity:activity_
                                                            uri:self.punchCardObject.uri];
        
    }
    
    return punchCard;
}


#pragma mark - <SelectionControllerDelegate>

-(void)selectionController:(SelectionController *)selectionController didChooseClient:(ClientType *)client
{
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:[client copy]
                                                                      projectType:nil
                                                                    oefTypesArray:nil
                                                                        breakType:NULL
                                                                         taskType:nil
                                                                         activity:NULL
                                                                              uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];

}

-(void)selectionController:(SelectionController *)selectionController didChooseProject:(ProjectType *)project
{
    BOOL isClientPresent = [self isValidString:project.client.uri];
    ClientType *client = isClientPresent ? [project.client copy] : nil;
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:client
                                                                      projectType:[project copy]
                                                                    oefTypesArray:nil
                                                                        breakType:NULL
                                                                         taskType:nil
                                                                         activity:NULL
                                                                              uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];



}
-(void)selectionController:(SelectionController *)selectionController didChooseTask:(TaskType *)task
{

    BOOL isClientPresent = [self isValidString:self.punchCardObject.clientType.uri];
    ClientType *client = isClientPresent ? [self.punchCardObject.clientType copy] : nil;

    BOOL isProjectPresent = [self isValidString:self.punchCardObject.projectType.uri];
    ProjectType *project = isProjectPresent ? [self.punchCardObject.projectType copy] : nil;

    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:client
                                                                      projectType:project
                                                                    oefTypesArray:nil
                                                                        breakType:NULL
                                                                         taskType:[task copy]
                                                                         activity:NULL
                                                                              uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];


}

-(void)selectionController:(SelectionController *)selectionController didChooseActivity:(Activity *)activity
{

    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:nil
                                                                      projectType:nil
                                                                    oefTypesArray:[self.oefTypesArray copy]
                                                                        breakType:NULL
                                                                         taskType:nil
                                                                         activity:[activity copy]
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

    [self.delegate punchCardController:self didUpdateHeight:self.tableView.contentSize.height + 100.0];
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

- (IBAction)didTapToCreatePunchCard:(id)sender
{
    [self.view endEditing:NO];
    NSError *validationError = [self validatePunch];
    if (validationError == nil) {
    [self reloadDataOnViewWithPunchCard:self.punchCardObject];

    BOOL isClientPresent = [self isValidString:self.punchCardObject.clientType.uri];
    ClientType *client = isClientPresent ? [self.punchCardObject.clientType copy] : nil;

    BOOL isProjectPresent = [self isValidString:self.punchCardObject.projectType.uri];
    ProjectType *project = isProjectPresent ? [self.punchCardObject.projectType copy] : nil;

    BOOL isTaskPresent = [self isValidString:self.punchCardObject.taskType.uri];
    TaskType *task = isTaskPresent ? [self.punchCardObject.taskType copy] : nil;

    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                         initWithClientType:client
                                                                projectType:project
                                                              oefTypesArray:nil
                                                                  breakType:nil
                                                                   taskType:task
                                                                   activity:nil
                                                                        uri:nil];

    [self.delegate punchCardController:self didChooseToCreatePunchCardWithObject:punchCardObject];
    }
    else
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"")];
    }
}

#pragma mark - Punch Action

- (IBAction)didTapToPunch:(id)sender
{
    [self.view endEditing:NO];
    NSError *validationError = [self validatePunch];
    if (validationError == nil)
    {
        [self.delegate punchCardController:self didIntendToPunchWithObject:self.punchCardObject];
    }
    else
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"")];
    }
}


#pragma mark - Private

-(NSString *)cellTextValueForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    if (hasActivityAccess)
    {
        return [self activityName];
    }
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
    self.punchCardObject = [[PunchCardObject alloc]
                                             initWithClientType:punchCard.clientType
                                                    projectType:punchCard.projectType
                                                  oefTypesArray:[self.oefTypesArray copy]
                                                      breakType:NULL
                                                       taskType:punchCard.taskType
                                                       activity:punchCard.activity
                                                            uri:[Util getRandomGUID]];
    [self.tableView reloadData];
}

-(void)setUpButton
{
    if (self.punchCardType == DefaultClientProjectTaskPunchCard)
    {
        [self stylePunchCardButton:self.createPunchCardButton];
        self.punchActionButton.hidden = YES;
        [self.createPunchCardButton setTitle:RPLocalizedString(createBookmarksText, createBookmarksText) forState:UIControlStateNormal];
        [self.punchActionButton removeFromSuperview];
        
    }
    else
    {
        [self styleClockInButton:self.punchActionButton];
        self.createPunchCardButton.hidden = YES;
        [self.punchActionButton setTitle:RPLocalizedString(@"Clock In", nil) forState:UIControlStateNormal];
        [self.createPunchCardButton removeFromSuperview];
    }
}

-(void)styleClockInButton:(UIButton *)button
{
    button.backgroundColor = [self.theme clockInPunchCardButtonBackgroundColor];
    button.titleLabel.font = [self.theme clockInPunchCardButtonFont];
    button.layer.cornerRadius = [self.theme clockInPunchCardCornerRadius];
    button.layer.borderColor = [self.theme clockInPunchCardBorderColor];
    button.layer.borderWidth = 0.0f;
    [button setTitleColor:[self.theme clockInPunchCardButtonTitleColor] forState:UIControlStateNormal];
}

-(void)stylePunchCardButton:(UIButton *)button
{
    button.backgroundColor = [self.theme createPunchCardButtonBackgroundColor];
    button.titleLabel.font = [self.theme createPunchCardButtonFont];
    button.layer.cornerRadius = [self.theme createPunchCardCornerRadius];
    button.layer.borderColor = [self.theme createPunchCardBorderColor];
    button.layer.borderWidth = [self.theme createPunchCardBorderWidth];
    [button setTitleColor:[self.theme createPunchCardButtonTitleColor] forState:UIControlStateNormal];

}


-(NSString *)clientName
{
    NSString *clientInProject = self.punchCardObject.projectType.client.name;
    BOOL isClientInProjectPresent = [self isValidString:clientInProject];
    if (isClientInProjectPresent) {
        return clientInProject;
    }
    NSString *client = self.punchCardObject.clientType.name;
    BOOL isClientPresent = [self isValidString:client];
    if (isClientPresent) {
        return client;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)projectName
{
    NSString *project = self.punchCardObject.projectType.name;
    BOOL isProjectPresent = [self isValidString:project];
    if (isProjectPresent) {
        return project;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)taskName
{
    NSString *task = self.punchCardObject.taskType.name;
    BOOL isTaskPresent = [self isValidString:task];
    if (isTaskPresent) {
        return task;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)activityName
{
    NSString *activity = self.punchCardObject.activity.name;
    BOOL isActivityPresent = [self isValidString:activity];
    if (isActivityPresent) {
        return activity;
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
    NSError * error = nil;
    if (self.punchCardType == DefaultClientProjectTaskPunchCard)
    {
        error =  [punchValidator validatePunchWithClientType:self.punchCardObject.clientType
                                                ProjectType:self.punchCardObject.projectType
                                                   taskType:self.punchCardObject.taskType];
    }
    else{
        error =  [punchValidator validatePunchWithClientType:self.punchCardObject.clientType
                                                 projectType:self.punchCardObject.projectType
                                                    taskType:self.punchCardObject.taskType
                                                activityType:self.punchCardObject.activity
                                                     userUri:nil];
    }
    return error;
}

-(BOOL)isOEFRow:(NSIndexPath *)indexPath
{
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionStorage hasProjectAccess];
    if (indexPath.row > [self rowStartIndexForOEFTypes])
    {
        return YES;
    }
    else if (indexPath.row >= [self rowStartIndexForOEFTypes] && !hasActivityAccess && !hasProjectAccess)
    {
        return YES;
    }
    return NO;
}

-(int)rowStartIndexForOEFTypes
{
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionStorage hasProjectAccess];

    int checkRow =0;
    if (hasActivityAccess)
    {
        checkRow = 0;
    }
    else if (hasProjectAccess)
    {
        BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
        if (hasClientAccess)
            checkRow = 2;
        else
            checkRow = 1;
    }
    else
    {
        checkRow = 0;
    }
    return checkRow;
}

-(OEFType *)getOEFTypeByRow:(int)row
{
    return self.oefTypesArray[[self indexForOEFTypeByRow:row]];
}

-(int)indexForOEFTypeByRow:(int)row
{
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionStorage hasProjectAccess];
    if (!hasProjectAccess && !hasActivityAccess)
    {

        return  row;
    }
    else
    {
        return row - [self rowStartIndexForOEFTypes] - 1;
    }
}

#pragma mark - <DynamicTextTableViewCellDelegate>

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didUpdateTextView:(UITextView *)textView
{

    NSInteger oefIndex = dynamicTextTableViewCell.tag;
    OEFType *oefType = [self getOEFTypeByRow:(int) oefIndex];
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

    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.delegate punchCardController:self didUpdateHeight:self.tableView.contentSize.height + 100.0];
                     }
                     completion:^(BOOL finished) {
                         [self.delegate punchCardController:self didScrolltoSubview:textView];
                     }];

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

    [self.delegate punchCardController:self didScrolltoSubview:textView];
}

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didEndEditingTextView:(UITextView *)textView
{
    NSString *oefValue = textView.text;

    OEFType *oefType = [self getOEFTypeByRow:(int) dynamicTextTableViewCell.tag];

    NSMutableArray *oefTypesArray = [NSMutableArray arrayWithArray:self.oefTypesArray];

    OEFType *newOEFType = [self getUpdatedOEFTypeFromOEFTypeObject:oefType textView:textView];
    [oefTypesArray replaceObjectAtIndex:[self indexForOEFTypeByRow:(int)dynamicTextTableViewCell.tag]
                             withObject:newOEFType];

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
                                                            uri:[Util getRandomGUID]];
    self.oldTextViewValue = @"";

}

#pragma mark <AlertView Delegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.alertViewVisible = NO;
    UITextView *textView_ = [self.tableView viewWithTag:self.dynamicCellTextViewTag]; //Fix for : TCM-238
    [textView_ becomeFirstResponder]; //Fix for : TCM-238
    
}


@end
