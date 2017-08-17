#import "OEFCardViewController.h"
#import "Theme.h"
#import "Constants.h"
#import "PunchCardStylist.h"
#import "Constants.h"
#import "UserSession.h"
#import "DynamicTextTableViewCell.h"
#import "OEFType.h"
#import "ButtonStylist.h"
#import "DefaultActivityStorage.h"
#import "UserPermissionsStorage.h"
#import "BreakType.h"
#import "BreakTypeRepository.h"
#import "AppDelegate.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchCardObject.h"
#import <Blindside/BSInjector.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "TimesheetClientProjectTaskRepository.h"
#import "TimeLinePunchesStorage.h"
#import "Punch.h"
#import "OEFDropDownRepository.h"
#import "OEFDropDownType.h"
#import "GUIDProvider.h"
#import "PunchValidator.h"
#import "UITextView+DisableCopyPaste.h"
#import "UIViewController+OEFValuePopulation.h"
#import "InjectorKeys.h"

#define DYNAMIC_TEXT_VIEW_TAG_INDEX     4000

@interface OEFCardViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton       *punchActionButton;
@property (weak, nonatomic) IBOutlet UIButton       *cancelButton;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;

@property (nonatomic,weak) id <OEFCardViewControllerDelegate> delegate;

@property (nonatomic) UserPermissionsStorage    *userPermissionStorage;
@property (nonatomic) DefaultActivityStorage    *defaultActivityStorage;
@property (nonatomic) TimeLinePunchesStorage    *timeLinePunchesStorage;
@property (nonatomic) NSString                  *selectedDropDownOEFUri;
@property (nonatomic) BreakTypeRepository       *breakTypeRepository;
@property (nonatomic) PunchCardStylist          *punchCardStylist;
@property (nonatomic) PunchCardObject           *punchCardObject;
@property (nonatomic) PunchActionType           punchActionType;
@property (nonatomic) ButtonStylist             *buttonStylist;
@property (nonatomic) NSArray                   *oefTypesArray;
@property (nonatomic) NSArray                   *breakTypeList;
@property (nonatomic) GUIDProvider              *guidProvider;
@property (nonatomic) id<UserSession>           userSession;
@property (nonatomic) id<BSInjector>            injector;
@property (nonatomic) NSString                  *oldTextViewValue;
@property (nonatomic, assign) NSInteger dynamicCellTextViewTag;
@property (nonatomic,assign) BOOL alertViewVisible;

@end

#define ROW_HEIGHT  80.0

@implementation OEFCardViewController

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                        defaultActivityStorage:(DefaultActivityStorage *)defaultActivityStorage
                        timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                           breakTypeRepository:(BreakTypeRepository *)breakTypeRepository
                              punchCardStylist:(PunchCardStylist *)punchCardStylist
                                 buttonStylist:(ButtonStylist *)buttonStylist
                                  guidProvider:(GUIDProvider *)guidProvider
                                   userSession:(id <UserSession>)userSession {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.userPermissionStorage = userPermissionsStorage;
        self.defaultActivityStorage = defaultActivityStorage;
        self.timeLinePunchesStorage = timeLinePunchesStorage;
        self.breakTypeRepository = breakTypeRepository;
        self.punchCardStylist = punchCardStylist;
        self.buttonStylist = buttonStylist;
        self.guidProvider = guidProvider;
        self.userSession = userSession;
    }
    return self;
}

- (void)setUpWithDelegate:(id <OEFCardViewControllerDelegate>)delegate
          punchActionType:(PunchActionType)punchActionType
            oefTypesArray:(NSArray *)oefTypesArray
{
    self.punchActionType = punchActionType;
    self.oefTypesArray = oefTypesArray;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.punchCardObject = [self.injector getInstance:[PunchCardObject class]];
    self.view.backgroundColor = [self.theme cardContainerBackgroundColor];
    [self.punchCardStylist styleBorderForOEFView:self.view];
    self.tableView.estimatedRowHeight = ROW_HEIGHT;
    [self setUpButton];
    
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    if (hasActivityAccess && self.punchActionType ==  PunchActionTypeTransfer)
        [self checkForDefaultActivity];
    
    if (!hasActivityAccess && self.punchActionType ==  PunchActionTypeResumeWork) {
        [self showLastPunchDetails];
    }

    UINib *nib = [UINib nibWithNibName:NSStringFromClass([DynamicTextTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DynamicTextViewCell"];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat containerHeight = self.tableView.contentSize.height;
    [self.delegate oefCardViewController:self didUpdateHeight:containerHeight+125];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedDropDownOEFUri = nil;
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellToReturn=nil;
    
    if ([self isOEFRow:indexPath])
    {
        static NSString *simpleTableIdentifier = @"DynamicTextViewCell";
        DynamicTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier
                                                                         forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DynamicTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        OEFType *oefType = self.oefTypesArray[indexPath.row - [self rowIndexForOEFTypes]];
        
        if (![self isValidString:oefType.oefName])
        {
            cell.title.text = @"";
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
        cell.backgroundColor = [self.theme oefCardTableCellBackgroundColor];
        
        cellToReturn = cell;
    }
    else{
        BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
        BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                       reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.text = [self cellTextValueForIndexPath:indexPath];
        cell.textLabel.font = [self.theme selectionCellFont];
        cell.detailTextLabel.font =[self.theme selectionCellValueFont];
        cell.textLabel.textColor = [self.theme selectionCellNameFontColor];
        cell.detailTextLabel.textColor = [self.theme selectionCellValueFontColor];
        cell.backgroundColor = [self.theme oefCardTableCellBackgroundColor];
        
        if (self.punchActionType == PunchActionTypeStartBreak )
        {
            cell.textLabel.text = RPLocalizedString(@"Break Type", nil);
        }
        else if (hasActivityAccess && indexPath.row == 0)
        {
            cell.textLabel.text = RPLocalizedString(@"Activity", nil);
        }
        else
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
        return 70.0;
    }
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isOEFRow:indexPath])
    {
        OEFType *oefType = nil;
        oefType = self.oefTypesArray[indexPath.row - [self rowIndexForOEFTypes]];
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
    else if(self.punchActionType ==  PunchActionTypeStartBreak)
    {
        self.punchActionButton.enabled = NO;
        self.view.userInteractionEnabled = NO;
        KSPromise *promise = [self.breakTypeRepository fetchBreakTypesForUser:self.userSession.currentUserURI];
        [promise then:^id(NSArray *breakTypeList) {
            self.punchActionButton.enabled = YES;
            self.breakTypeList = breakTypeList;
            
            NSString *breakTitle = RPLocalizedString(@"Select Break Type", nil);
            NSString *cancelTitle = RPLocalizedString(@"Cancel", nil);
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:breakTitle
                                                                     delegate:self
                                                            cancelButtonTitle:cancelTitle
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            for (BreakType *breakType in breakTypeList)
            {
                [actionSheet addButtonWithTitle:breakType.name];
            }
            
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            [actionSheet showInView:appDelegate.window];
            return nil;
            
        } error:^id(NSError *error) {
            self.punchActionButton.enabled = YES;
            self.view.userInteractionEnabled = YES;

            [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                           otherButtonTitle:RPLocalizedString(@"OK", @"OK")
                                                   delegate:self
                                                    message:RPLocalizedString(@"Replicon app was unable to retrieve the break type list.  Please try again later.", nil)
                                                      title:nil
                                                        tag:LONG_MIN];
            return nil;
        }];
    }
    else{
        SelectionScreenType screenType;
        BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
        if (hasActivityAccess)
        {
            screenType = ActivitySelection;
            self.punchCardObject = [self setProjectActivityRequiredInPunchCardObject];
        }
        else
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


#pragma mark - Private

-(void)setUpButton
{
    [self stylePunchButton:self.punchActionButton];
    [self styleCancelButton:self.cancelButton];
}

-(void)stylePunchButton:(UIButton *)button
{
    NSString *buttonTitle = [self buttonTitle];
    UIColor *buttonTitleColor = [self titleColor];
    UIColor *buttonBackgroundColor = [self buttonBackgroundColor];
    UIColor *buttonBorderColor = [self buttonBorderColor];
    [self.buttonStylist styleButton:self.punchActionButton
                              title:buttonTitle
                         titleColor:buttonTitleColor
                    backgroundColor:buttonBackgroundColor
                        borderColor:buttonBorderColor];
}

-(NSString*)buttonTitle
{
    NSString *buttonTitle = @"";
    if (self.punchActionType == PunchActionTypeStartBreak ) {
        buttonTitle = RPLocalizedString(@"Take a Break", nil);
    }
    else if(self.punchActionType == PunchActionTypePunchOut){
        buttonTitle = RPLocalizedString(@"Clock Out", nil);
    }
    else if(self.punchActionType == PunchActionTypeTransfer){
        buttonTitle = RPLocalizedString(@"Transfer", nil);
    }
    else{
        buttonTitle = RPLocalizedString(@"Resume Work", nil);
    }
    return buttonTitle;
}

-(UIColor*)titleColor
{
    UIColor *titleColor = [self.theme destructiveButtonTitleColor];
    if (self.punchActionType == PunchActionTypeStartBreak ) {
        titleColor = [self.theme takeBreakButtonTitleColor];
    }
    else if(self.punchActionType == PunchActionTypePunchOut){
        titleColor = [self.theme destructiveButtonTitleColor];
    }
    else if(self.punchActionType == PunchActionTypeTransfer){
        titleColor = [self.theme transferOEFCardButtonTitleColor];
    }
    else{
        titleColor = [self.theme oefCardResumeWorkButtonTitleColor];
    }
    return titleColor;
}

-(UIColor*)buttonBackgroundColor
{
    UIColor *buttonBackgroundColor = [self.theme takeBreakButtonBackgroundColor];
    if (self.punchActionType == PunchActionTypeStartBreak ) {
        buttonBackgroundColor = [self.theme takeBreakButtonBackgroundColor];
    }
    else if(self.punchActionType == PunchActionTypePunchOut){
        buttonBackgroundColor = [self.theme punchOutButtonBackgroundColor];
    }
    else if(self.punchActionType == PunchActionTypeTransfer){
        buttonBackgroundColor = [self.theme transferOEFCardButtonBackgroundColor];
    }
    else{
        buttonBackgroundColor = [self.theme oefCardResumeWorkButtonBackgroundColor];
    }
    return buttonBackgroundColor;
}

-(UIColor*)buttonBorderColor
{
    UIColor *buttonBorderColor = [self.theme takeBreakButtonBackgroundColor];
    if (self.punchActionType == PunchActionTypeStartBreak ) {
        buttonBorderColor = [self.theme oefCardPunchOutButtonBorderColor];
    }
    else if(self.punchActionType == PunchActionTypePunchOut){
        buttonBorderColor = [self.theme oefCardPunchOutButtonBorderColor];
    }
    else if(self.punchActionType == PunchActionTypeTransfer){
        buttonBorderColor = [self.theme transferOEFCardBorderColor];
    }
    else{
        buttonBorderColor = [self.theme oefCardResumeWorkButtonBorderColor];
    }
    return buttonBorderColor;
}

-(void)styleCancelButton:(UIButton *)button
{
    NSMutableAttributedString *cancelString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(@"Cancel", nil)];
    [cancelString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [cancelString length])];

    UIColor *cancelBackgroundColor = [self.theme oefCardCancelButtonBackgroundColor];
    UIColor *cancelTitleColor = [self.theme oefCardCancelButtonTitleColor];
    [button setAttributedTitle:cancelString forState:UIControlStateNormal];
    button.backgroundColor = cancelBackgroundColor;
    [button.titleLabel setTextColor:cancelTitleColor];
}

-(BOOL)isValidString:(NSString *)value
{
    return (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]);
}

-(BOOL)isValidPunch:(id<Punch>)punch
{
    if (punch != nil && punch != (id) [NSNull null]) {
        return YES;
    }
    return NO;
}

-(NSInteger)numberOfRows
{
    NSUInteger oefCount = [self.oefTypesArray count];
    return (self.punchActionType == PunchActionTypePunchOut) ? oefCount : [self dataRowNumber]+oefCount+1;
}

-(BOOL)isOEFRow:(NSIndexPath *)indexPath
{
    if (self.punchActionType != PunchActionTypePunchOut) {
        return indexPath.row > [self dataRowNumber] ? YES : NO;
    }
    return YES;
}

-(int)dataRowNumber
{
    BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionStorage hasProjectAccess];
    
    int numberOfRows =0;
    if (self.punchActionType == PunchActionTypeStartBreak )
    {
        numberOfRows = 0;
    }
    else if (hasActivityAccess)
    {
        numberOfRows = 0;
    }
    else if (hasProjectAccess)
    {
        BOOL hasClientAccess = [self.userPermissionStorage hasClientAccess];
        if (hasClientAccess)
            numberOfRows = 2;
        else
            numberOfRows = 1;
    }
    else
    {
        numberOfRows = -1;
    }
    return numberOfRows;
}

-(NSInteger)rowIndexForOEFTypes
{
    return (self.punchActionType == PunchActionTypePunchOut) ? 0 : [self dataRowNumber]+1;
}

-(NSString*)cellTextValueForIndexPath:(NSIndexPath *)indexPath
{
    if (self.punchActionType == PunchActionTypeStartBreak ) {
        return [self breakType];
    }
    else{
        BOOL hasActivityAccess = [self.userPermissionStorage hasActivityAccess];
        if (hasActivityAccess)
        {
            return [self activityType];
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
}

-(NSString *)breakType
{
    NSString *breakType = self.self.punchCardObject.breakType.name;
    BOOL isBreakPresent = [self isValidString:breakType];
    if (isBreakPresent) {
        return breakType;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)clientName
{
    NSString *clientValue = nil;
    clientValue = self.punchCardObject.projectType.client.name;
    BOOL isClientInProjectPresent = [self isValidString:clientValue];
    if (isClientInProjectPresent) {
        return clientValue;
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
    NSString *projectValue = nil;
    projectValue = self.punchCardObject.projectType.name;
    
    BOOL isProjectPresent = [self isValidString:projectValue];
    if (isProjectPresent) {
        return projectValue;
    }
    return RPLocalizedString(@"Select", nil);
}

-(NSString *)taskName
{
    NSString *taskValue = nil;
    taskValue = self.punchCardObject.taskType.name;
    
    BOOL isTaskPresent = [self isValidString:taskValue];
    if (isTaskPresent) {
        return taskValue;
    }
    return RPLocalizedString(@"Select", nil);
}


-(NSString *)activityType
{
    NSString *activityType = nil;
    activityType = self.punchCardObject.activity.name;
    
    BOOL isActivityPresent = [self isValidString:activityType];
    if (isActivityPresent) {
        return activityType;
    }
    else{
        if (self.punchActionType == PunchActionTypeResumeWork) {
            id<Punch> punch = [self lastPunch];
            if ([self isValidPunch:punch]) {
                Activity *lastActivity = punch.activity;
                if (lastActivity != nil && lastActivity != (id) [NSNull null])
                {
                    self.punchCardObject = [[PunchCardObject alloc]
                                            initWithClientType:nil
                                            projectType:nil
                                            oefTypesArray:[self.oefTypesArray copy]
                                            breakType:nil
                                            taskType:nil
                                            activity:lastActivity
                                            uri:[self.guidProvider guid]];
                    activityType = lastActivity.name;
                }
            }
        }
    }
    return [self isValidString:activityType]? activityType: RPLocalizedString(@"Select", nil);
}

-(void)reloadDataOnViewWithPunchCard:(PunchCardObject *)punchCard
{
    self.punchCardObject = [[PunchCardObject alloc]
                            initWithClientType:punchCard.clientType
                            projectType:punchCard.projectType
                            oefTypesArray:[self.oefTypesArray copy]
                            breakType:punchCard.breakType
                            taskType:punchCard.taskType
                            activity:punchCard.activity
                            uri:[self.guidProvider guid]];
    [self.tableView reloadData];
}

-(void)showLastPunchDetails
{
    id<Punch> punch = [self lastPunch];
    if ([self isValidPunch:punch]) {
        self.punchCardObject = [[PunchCardObject alloc]
                                initWithClientType:punch.client
                                projectType:punch.project
                                oefTypesArray:[self.oefTypesArray copy]
                                breakType:nil
                                taskType:punch.task
                                activity:nil
                                uri:[self.guidProvider guid]];
    }
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
    
    OEFType *oefType = self.oefTypesArray[oefIndex];
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
    
    [self.delegate oefCardViewController:self didUpdateHeight:self.tableView.contentSize.height + 200];
    [self.delegate oefCardViewController:self didScrolltoSubview:textView];
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
    [self.delegate oefCardViewController:self didScrolltoSubview:textView];
}

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didEndEditingTextView:(UITextView *)textView
{
    NSString *oefValue = textView.text;

    NSInteger oefIndex = (NSInteger) dynamicTextTableViewCell.tag - [self rowIndexForOEFTypes];

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
                            initWithClientType:self.punchCardObject.clientType
                            projectType:self.punchCardObject.projectType
                            oefTypesArray:[self.oefTypesArray copy]
                            breakType:self.punchCardObject.breakType
                            taskType:self.punchCardObject.taskType
                            activity:self.punchCardObject.activity
                            uri:[self.guidProvider guid]];
    
    self.oldTextViewValue = @"";

}


#pragma mark - <SelectionControllerDelegate>

-(void)selectionController:(SelectionController *)selectionController didChooseClient:(ClientType *)client
{
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:[client copy]
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
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:client
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
    
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]initWithClientType:client
                                                                      projectType:project
                                                                    oefTypesArray:[self.oefTypesArray copy]
                                                                        breakType:nil
                                                                         taskType:[task copy]
                                                                         activity:nil
                                                                              uri:nil];
    [self reloadDataOnViewWithPunchCard:punchCardObject];
    
    
}

-(void)selectionController:(SelectionController *)selectionController didChooseActivity:(Activity *)activity
{
    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                        initWithClientType:nil
                                        projectType:nil
                                        oefTypesArray:[self.oefTypesArray copy]
                                        breakType:nil
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

#pragma mark - Button Action

-(IBAction)cancelButtonAction:(id)sender
{
    [self.delegate oefCardViewController:self cancelButton:sender];
}

-(IBAction)punchButtonAction:(id)sender
{
    [self.view endEditing:NO];
    
    PunchActionType punchActionType_ = self.punchActionType;
    
    switch (punchActionType_) {
        case PunchActionTypeResumeWork:
        case PunchActionTypeTransfer: {
                NSError *validationError = [self validatePunch];
                if(validationError != nil) {
                    return [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"")];
                }
            }
            break;
            
        case PunchActionTypeStartBreak: {
                NSString *breakType = self.self.punchCardObject.breakType.name;
                BOOL isBreakPresent = [self isValidString:breakType];
                if(!isBreakPresent) {
                    [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                                   otherButtonTitle:RPLocalizedString(@"OK", @"OK")
                                                           delegate:self
                                                            message:RPLocalizedString(@"Please select a break type.", nil)
                                                              title:nil
                                                                tag:LONG_MIN];
                    return;
                }
            }
            break;
            
        default:
            //Do Nothing
            break;
    }

    self.punchCardObject = [[PunchCardObject alloc]
                            initWithClientType:self.punchCardObject.clientType
                            projectType:self.punchCardObject.projectType
                            oefTypesArray:[self.oefTypesArray copy]
                            breakType:self.punchCardObject.breakType
                            taskType:self.punchCardObject.taskType
                            activity:self.punchCardObject.activity
                            uri:[self.guidProvider guid]];

    [self.delegate oefCardViewController:self didIntendToSave:self.punchCardObject];
}

#pragma mark - Client Side validation

- (NSError *)validatePunch {
    PunchValidator *punchValidator = [self.injector getInstance:[PunchValidator class]];
    return [punchValidator validatePunchWithClientType:self.punchCardObject.clientType
                                           projectType:self.punchCardObject.projectType
                                              taskType:self.punchCardObject.taskType
                                          activityType:self.punchCardObject.activity
                                               userUri:nil];
    
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
     self.view.userInteractionEnabled = YES;
    if (actionSheet.cancelButtonIndex == buttonIndex)
    {
        self.punchActionButton.enabled = YES;
    }
    else
    {
        BreakType *breakType = self.breakTypeList[buttonIndex - 1];
        PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                            initWithClientType:nil
                                            projectType:nil
                                            oefTypesArray:nil
                                            breakType:breakType
                                            taskType:nil
                                            activity:nil
                                            uri:nil];
        [self reloadDataOnViewWithPunchCard:punchCardObject];
    }
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
            if ([self lastPunchActivitySameAsDefaultActivity:activity]) {
                return;
            }
            self.punchCardObject = [[PunchCardObject alloc]
                                    initWithClientType:nil
                                    projectType:nil
                                    oefTypesArray:[self.oefTypesArray copy]
                                    breakType:NULL
                                    taskType:nil
                                    activity:activity
                                    uri:[self.guidProvider guid]];
        }
    }
}

-(id<Punch>)lastPunch
{
    NSArray *punchArray = [self.timeLinePunchesStorage recentTwoPunches];
    if ([punchArray count]>0) {
        for (id<Punch> punch in punchArray) {
            if ([punch actionType] == PunchActionTypePunchIn||
                [punch actionType] == PunchActionTypeTransfer)
            {
                return punch;
            }
        }
    }
    return nil;
}

-(BOOL)lastPunchActivitySameAsDefaultActivity:(Activity*)activity
{
    id<Punch> punch = [self lastPunch];
    if ([self isValidPunch:punch]) {
        Activity *lastActivity = punch.activity;
        if (lastActivity ==  nil || ![self isValidString:lastActivity.name])
            return NO;
        
        if ([activity isEqual:lastActivity])
            return YES;
    }
    return NO;
}

#pragma mark <AlertView Delegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.alertViewVisible = NO;
    UITextView *textView_ = [self.tableView viewWithTag:self.dynamicCellTextViewTag]; //Fix for : TCM-238
    [textView_ becomeFirstResponder]; //Fix for : TCM-238
    
}

@end
