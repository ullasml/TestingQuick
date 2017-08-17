#import "AddPunchController.h"
#import "PunchImagePickerControllerProvider.h"
#import "DefaultTableViewCellStylist.h"
#import "PunchOverviewController.h"
#import "PunchAttributeController.h"
#import "SegmentedControlStylist.h"
#import "UserPermissionsStorage.h"
#import "AllowAccessAlertHelper.h"
#import "ChildControllerHelper.h"
#import "BreakTypeRepository.h"
#import "PunchHomeController.h"
#import "ImageNormalizer.h"
#import "SpinnerDelegate.h"
#import "PunchRepository.h"
#import "DefaultTheme.h"
#import "LocalPunch.h"
#import <KSDeferred/KSDeferred.h>
#import "BreakType.h"
#import "PunchClock.h"
#import "Constants.h"
#import <Blindside/BSInjector.h>
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ReporteePermissionsStorage.h"
#import "ManualPunch.h"
#import "Activity.h"
#import "Enum.h"
#import "GUIDProvider.h"
#import "PunchValidator.h"
#import "OEFTypeStorage.h"
#import "DaySummaryDateTimeProvider.h"

@interface AddPunchController () <UIActionSheetDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchAttributeContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButtonOnToolBar;
@property (weak, nonatomic) IBOutlet UIView *punchAttributeContainerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *punchTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *punchDetailsTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *segmentToTableSeparatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidthConstraint;

@property (nonatomic) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic) DaySummaryDateTimeProvider *daySummaryDateTimeProvider;
@property (nonatomic) DefaultTableViewCellStylist *tableViewCellStylist;
@property (nonatomic) SegmentedControlStylist *segmentedControlStylist;
@property (nonatomic) AllowAccessAlertHelper *allowAccessAlertHelper;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) ImageNormalizer *imageNormalizer;
@property (nonatomic) BreakTypeRepository *breakTypeRepository;
@property (nonatomic) PunchRepository *punchRepository;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) PunchClock *punchClock;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSHashTable *observers;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic) BreakType *selectedBreakType;
@property (nonatomic) NSArray *breakTypeList;
@property (nonatomic) KSDeferred *imageDeferred;
@property (nonatomic) PunchAttributeController *punchAttributeController;

@property (nonatomic) ManualPunch *punch;
@property (nonatomic) id<UserSession>userSession;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) id<PunchChangeObserverDelegate> punchChangeObserverDelegate;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic) ReporteePermissionsStorage *reporteePermissionsStorage;
@property (nonatomic) GUIDProvider *guidProvider;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) OEFTypeStorage *oefTypesStotage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,assign) BOOL keyboardVisible;
@property (nonatomic) NSNotificationCenter *notificationCenter;

@end

static NSString *const CellIdentifier = @"¡";

@implementation AddPunchController

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider
                                reporteePermissionsStorage:(ReporteePermissionsStorage *)reporteePermissionsStorage
                                daySummaryDateTimeProvider:(DaySummaryDateTimeProvider *)daySummaryDateTimeProvider
                                   segmentedControlStylist:(SegmentedControlStylist *)segmentedControlStylist
                                    allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                      tableViewCellStylist:(DefaultTableViewCellStylist *)tableViewCellStylist
                                       breakTypeRepository:(BreakTypeRepository *)breakTypeRepository
                                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                        notificationCenter:(NSNotificationCenter *)notificationCenter
                                         punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                           imageNormalizer:(ImageNormalizer *)imageNormalizer
                                           punchRepository:(PunchRepository *)punchRepository
                                           spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                           oefTypesStorage:(OEFTypeStorage *)oefTypesStorage
                                             dateFormatter:(NSDateFormatter *)dateFormatter
                                               userSession:(id <UserSession>)userSession
                                              guidProvider:(GUIDProvider *)guidProvider
                                                punchClock:(PunchClock *)punchClock
                                                     theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {


        self.punchImagePickerControllerProvider = punchImagePickerControllerProvider;
        self.daySummaryDateTimeProvider = daySummaryDateTimeProvider;
        self.reporteePermissionsStorage = reporteePermissionsStorage;
        self.allowAccessAlertHelper = allowAccessAlertHelper;
        self.childControllerHelper = childControllerHelper;
        self.segmentedControlStylist = segmentedControlStylist;
        self.tableViewCellStylist = tableViewCellStylist;
        self.breakTypeRepository = breakTypeRepository;
        self.reachabilityMonitor = reachabilityMonitor;
        self.punchRulesStorage = punchRulesStorage;
        self.imageNormalizer = imageNormalizer;
        self.punchRepository = punchRepository;
        self.spinnerDelegate = spinnerDelegate;
        self.dateFormatter = dateFormatter;
        self.guidProvider = guidProvider;
        self.userSession = userSession;
        self.punchClock = punchClock;
        self.theme = theme;
        self.observers = [NSHashTable weakObjectsHashTable];
        self.oefTypesStotage = oefTypesStorage;
        self.notificationCenter = notificationCenter;
    }
    return self;
}

- (void)setupWithPunchChangeObserverDelegate:(id<PunchChangeObserverDelegate>)punchChangeObserverDelegate
                                     userURI:(NSString *)userURI
                                        date:(NSDate *)date {
    self.userURI = userURI;
    self.date = date;
    self.punchChangeObserverDelegate = punchChangeObserverDelegate;
    [self.observers addObject:punchChangeObserverDelegate];
}

#pragma mark - NSObject

- (void)dealloc
{
    self.punchDetailsTableView.dataSource = nil;
    self.punchDetailsTableView.delegate = nil;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollView.alwaysBounceVertical = YES;

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.title = RPLocalizedString(@"Add Missing Punch", nil);
    self.segmentToTableSeparatorView.backgroundColor = [self.theme separatorViewBackgroundColor];

    [self configurePunchTypeSegmentedControl];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(userDidTapSave:)];

    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:@"missing_punch_save_btn"];

    [self.punchDetailsTableView  registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];

    [self.segmentedControlStylist styleSegmentedControl:self.punchTypeSegmentedControl];

    [self hidePickerWithToolBar];
    NSDate *date = [self.daySummaryDateTimeProvider dateWithCurrentTime:self.date];
    self.datePicker.date = date;
    self.datePicker.backgroundColor = [self.theme datePickerBackgroundColor];



    FlowType flowType = [self getUserFlowType];
    self.punchAttributeController = [self.injector getInstance:[PunchAttributeController class]];
    ManualPunch *punch = [self manualPunch];
    [self.punchAttributeController setUpWithNeedLocationOnUI:NO
                                                    delegate:self
                                                    flowType:flowType
                                                     userUri:self.userURI
                                                       punch:punch
                                    punchAttributeScreentype:PunchAttributeScreenTypeADD];
    [self.childControllerHelper addChildController:self.punchAttributeController
                                toParentController:self
                                   inContainerView:self.punchAttributeContainerView];

    if ([self isBreaksUser])
    {
        KSPromise *breakTypePromise = [self.breakTypeRepository fetchBreakTypesForUser:self.userURI];
        [breakTypePromise then:^id(NSArray *breakTypeList) {
            self.breakTypeList = breakTypeList;
            self.selectedBreakType = self.breakTypeList.firstObject;
            [self resetSaveButtonAndTableView];
            return nil;
        } error:nil];
    }

    CGRect viewFrame = self.view.bounds;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    viewFrame.size.width = screenRect.size.width;
    self.view.bounds = viewFrame;

    [self.punchDetailsTableView  setAccessibilityIdentifier:@"manual_punch_table_view"];
    [self.datePicker  setAccessibilityIdentifier:@"manual_punch_date_picker"];
    [self.doneButtonOnToolBar  setAccessibilityLabel:@"manual_punch_toolbar_done_btn"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.tableViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds);

    // Register for the events

    [self.notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //Initially the keyboard is hidden
    self.keyboardVisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:CellIdentifier];

    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
        PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
        switch (actionType) {
            case PunchActionTypePunchIn:
                cell.imageView.image = [UIImage imageNamed:@"icon_timeline_clock_in"];
                cell.textLabel.text = [self.punchTypeSegmentedControl titleForSegmentAtIndex:selectedIndex];
                break;
            case PunchActionTypeTransfer:
                cell.imageView.image = [UIImage imageNamed:@"icon_timeline_clock_in"];
                cell.textLabel.text = [self.punchTypeSegmentedControl titleForSegmentAtIndex:selectedIndex];
                break;
            case PunchActionTypePunchOut:
                cell.imageView.image = [UIImage imageNamed:@"icon_timeline_clock_out"];
                cell.textLabel.text = [self.punchTypeSegmentedControl titleForSegmentAtIndex:selectedIndex];
                break;
            case PunchActionTypeStartBreak:
                cell.imageView.image = [UIImage imageNamed:@"icon_timeline_break"];
                cell.textLabel.text = self.selectedBreakType.name;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;

            default:
                break;
        }

        [self.tableViewCellStylist styleCell:cell separatorOffset:24.0f];
    } else {
        cell.textLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
        [self.tableViewCellStylist styleCell:cell separatorOffset:0.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell.textLabel  setAccessibilityIdentifier:@"manual_punch_date_and_time_lbl"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
        PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
        if (actionType == PunchActionTypeStartBreak)
        {
            [self hidePickerWithToolBar];
            NSString *breakTitle = RPLocalizedString(@"Select Break Type", nil);
            NSString *cancelTitle = RPLocalizedString(@"Cancel", nil);
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:breakTitle
                                                                     delegate:self
                                                            cancelButtonTitle:cancelTitle
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:nil];
            for (BreakType *breakType in self.breakTypeList)
            {
                [actionSheet addButtonWithTitle:breakType.name];
            }

            [actionSheet showInView:self.view];
        }

    }
    else
    {
        [self showPickerWithToolBar];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIDatePickerChangeAction

- (IBAction)datePickerChanged:(UIDatePicker *)datePicker
{
    [self.punchDetailsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        self.selectedBreakType = self.breakTypeList[buttonIndex-1];
        [self.punchDetailsTableView reloadData];
    }
}

#pragma mark - <PunchAssemblyWorkflowDelegate>

- (KSPromise *)punchAssemblyWorkflowNeedsImage
{
    self.imageDeferred = [[KSDeferred alloc] init];
    UIImagePickerController *punchImagePickerController = [self.punchImagePickerControllerProvider provideInstanceWithDelegate:self];
    [self presentViewController:punchImagePickerController animated:YES completion:NULL];
    return self.imageDeferred.promise;
}

- (void)punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
        assembledPunchPromise:(KSPromise *)assembledPunchPromise
  serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{
    [self.spinnerDelegate showTransparentLoadingOverlay];
    [serverDidFinishPunchPromise then:^id(id value){

        if ([self.reachabilityMonitor isNetworkReachable]) {
            KSPromise *mostRecentPunchPromise = [self.punchRepository fetchMostRecentPunchForUserUri:self.userURI];
            [mostRecentPunchPromise then:^id(id value){
                if (self.observers.count==0) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                return nil;
            } error:nil];
        }
        else{
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            [self.navigationController popViewControllerAnimated:YES];
        }

        return nil;
    } error:^id(NSError *error) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        return nil;
    }];
}

- (void)punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow didFailToAssembleIncompletePunch:(LocalPunch *)incompletePunch errors:(NSArray *)errors
{
    NSError *locationError;
    NSError *cameraError;

    for(NSError *error in errors)
    {
        if([error.domain isEqualToString:CameraAssemblyGuardErrorDomain])
        {
            cameraError = error;
        } else if([error.domain isEqualToString:LocationAssemblyGuardErrorDomain])
        {
            locationError = error;
        }
    }

    [self.allowAccessAlertHelper handleLocationError:locationError cameraError:cameraError];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:NULL];

    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *normalizedImage = [self.imageNormalizer normalizeImage:originalImage];
    [self.imageDeferred resolveWithValue:normalizedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePickerController
{
    [self.imageDeferred rejectWithError:nil];
    [imagePickerController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - <PunchAttributeControllerDelegate>

- (void)punchAttributeController:(PunchAttributeController *)punchDetailsController
    didUpdateTableViewWithHeight:(CGFloat)height;
{
    self.punchAttributeContainerViewHeightConstraint.constant = height;
}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
        didIntendToUpdateClient:(ClientType *)client
{
    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;

    NSArray *oefTypesArr = ([self.punch.oefTypesArray count] > 0)? self.punch.oefTypesArray : [self.oefTypesStotage getAllOEFSForPunchActionType:actionType];

    self.punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:nil requestID:self.punch.requestID activity:nil client:[client copy] oefTypes:[oefTypesArr copy] address:nil userURI:self.userURI image:nil task:nil date:self.datePicker.date];
    [self reloadWithNewPunchAttributes:self.punch];
}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
       didIntendToUpdateProject:(ProjectType *)project
{
    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;

    NSArray *oefTypesArr = ([self.punch.oefTypesArray count] > 0)? self.punch.oefTypesArray : [self.oefTypesStotage getAllOEFSForPunchActionType:actionType];

    BOOL isClientPresent = [self isValidString:project.client.uri];
    ClientType *client = isClientPresent ? [project.client copy] : nil;
    self.punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:[project copy] requestID:self.punch.requestID activity:nil client:client oefTypes:[oefTypesArr copy] address:nil userURI:self.userURI image:nil task:nil date:self.datePicker.date];

    [self reloadWithNewPunchAttributes:self.punch];


}
-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
          didIntendToUpdateTask:(TaskType *)task
{
    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;

    NSArray *oefTypesArr = ([self.punch.oefTypesArray count] > 0)? self.punch.oefTypesArray : [self.oefTypesStotage getAllOEFSForPunchActionType:actionType];

    self.punch  = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:[self.punch.project copy] requestID:self.punch.requestID activity:nil client:[self.punch.client copy] oefTypes:[oefTypesArr copy] address:nil userURI:self.userURI image:nil task:[task copy] date:self.datePicker.date];

    [self reloadWithNewPunchAttributes:self.punch];

}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
      didIntendToUpdateActivity:(Activity *)activity
{

    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;

    NSArray *oefTypesArr = ([self.punch.oefTypesArray count] > 0)? self.punch.oefTypesArray : [self.oefTypesStotage getAllOEFSForPunchActionType:actionType];

    self.punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:nil requestID:self.punch.requestID activity:[activity copy] client:nil oefTypes:[oefTypesArr copy] address:nil userURI:self.userURI image:nil task:nil date:self.datePicker.date];

    [self reloadWithNewPunchAttributes:self.punch];
}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateDefaultActivity:(Activity *)activity

{
    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;

    NSArray *oefTypesArr = ([self.punch.oefTypesArray count] > 0)? self.punch.oefTypesArray : [self.oefTypesStotage getAllOEFSForPunchActionType:actionType];

    self.punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:nil requestID:self.punch.requestID activity:[activity copy] client:nil oefTypes:[oefTypesArr copy] address:nil userURI:self.userURI image:nil task:nil date:self.datePicker.date];

}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateDropDownOEFTypes:(NSArray *)oefTypesArray
{

    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;


    self.punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:self.punch.location project:self.punch.project requestID:self.punch.requestID activity:self.punch.activity client:self.punch.client oefTypes:[oefTypesArray copy] address:self.punch.address userURI:self.userURI image:self.punch.image task:self.punch.task date:self.datePicker.date];

    [self reloadWithNewPunchAttributes:self.punch];

}

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateTextOrNumericOEFTypes:(NSArray *)oefTypesArray
{

    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;

    self.punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:self.punch.location project:self.punch.project requestID:self.punch.requestID activity:self.punch.activity client:self.punch.client oefTypes:[oefTypesArray copy] address:self.punch.address userURI:self.userURI image:self.punch.image task:self.punch.task date:self.datePicker.date];


}

- (void)punchAttributeController:(PunchAttributeController *)punchAttributeController didScrolltoSubview:(id)subview
{
    UITextView *textView = (UITextView *)subview;
    CGRect rc = [subview bounds];
    rc = [subview convertRect:rc toView:self.scrollView];
    float yPosition = (rc.origin.y - 200) + textView.contentSize.height;
    [self.scrollView setContentOffset:CGPointMake(0, yPosition) animated:NO];
}

#pragma mark - Private

- (void)userDidTapSave:(id)sender
{
    [self.view endEditing:YES];

    if ([self.reachabilityMonitor isNetworkReachable])
    {
        NSError *validationError = nil;
        
        NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
        PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
        
        if(actionType==PunchActionTypePunchIn || actionType == PunchActionTypeTransfer)
        {
            validationError = [self validatePunch];
        }
        
        if (validationError == nil) {
            NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
            PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
            
            BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;
            
            ManualPunch *punch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:[self.punch.project copy] requestID:self.punch.requestID activity:[self.punch.activity copy] client:[self.punch.client copy] oefTypes:self.punch.oefTypesArray address:nil userURI:self.userURI image:nil task:[self.punch.task copy] date:self.datePicker.date];
            
            KSPromise *promise = [self.punchClock punchWithManualLocalPunch:punch punchAssemblyWorkflowDelegate:self];
            [promise then:^id(id value) {
                KSPromise *promise = [self notifyObserversDidAddPunch];
                [promise then:^id(id value) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self.navigationController popViewControllerAnimated:YES];
                    return nil;
                } error:^id(NSError *error) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    [self.navigationController popViewControllerAnimated:YES];
                    return nil;
                }];
                return nil;
            } error:^id(NSError *error) {
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return nil;
            }];
            
        }
        else{
            [Util errorAlert:@"" errorMessage:RPLocalizedString(validationError.localizedDescription, @"")];
        }
    }
    else{
        [Util showOfflineAlert];
        return;
    }
}

- (NSError *)validatePunch {
    PunchValidator *punchValidator = [self.injector getInstance:[PunchValidator class]];
    if([self getUserFlowType]==UserFlowContext)
    {
        return [punchValidator validatePunchWithClientType:self.punch.client
                                               projectType:self.punch.project
                                                  taskType:self.punch.task
                                              activityType:self.punch.activity
                                                   userUri:nil];
    }
    else
    {
        return [punchValidator validatePunchWithClientType:self.punch.client
                                               projectType:self.punch.project
                                                  taskType:self.punch.task
                                              activityType:self.punch.activity
                                                   userUri:self.userURI];
    }
}

- (KSPromise *) notifyObserversDidAddPunch
{
    for (id<PunchChangeObserverDelegate> observer in self.observers) {
        return [observer punchOverviewEditControllerDidUpdatePunch];
    }
    return nil;
}

- (IBAction)userDidSelectSegment:(id)sender
{
    [self resetSaveButtonAndTableView];
    ManualPunch *punch = [self manualPunch];
    [self reloadWithNewPunchAttributes:punch];
    self.punch = punch;
}

- (PunchActionType)punchActionTypeForSelectedSegmentIndex:(NSInteger)selectedIndex
{
    NSString *selectedActionType = [self.punchTypeSegmentedControl titleForSegmentAtIndex:selectedIndex];

    NSMutableDictionary *descriptionsMap = [@{}mutableCopy];
    [descriptionsMap setObject:@(PunchActionTypePunchIn) forKey:RPLocalizedString(@"Clock In", nil)];

    BOOL isPunchIntoProjectsUser = [self isPunchIntoProjectsUser];
    BOOL isPunchIntoActivitiesUser = [self isPunchIntoActivitiesUser];
    if (isPunchIntoProjectsUser || isPunchIntoActivitiesUser)
    {
        [descriptionsMap setObject:@(PunchActionTypeTransfer) forKey:RPLocalizedString(@"Transfer", nil)];
    }
    if ([self isBreaksUser])
    {
        [descriptionsMap setObject:@(PunchActionTypeStartBreak) forKey:RPLocalizedString(@"Break", nil)];
    }

    [descriptionsMap setObject:@(PunchActionTypePunchOut) forKey:RPLocalizedString(@"Clock Out", nil)];


    PunchActionType actionType = [descriptionsMap[selectedActionType] integerValue];
    return actionType;
}

- (void)resetSaveButtonAndTableView
{
    [self.punchDetailsTableView reloadData];

    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    if (actionType == PunchActionTypeStartBreak)
    {
        self.navigationItem.rightBarButtonItem.enabled = (self.breakTypeList.count > 0);
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)configurePunchTypeSegmentedControl
{

    int index = 0;

    [self.punchTypeSegmentedControl removeAllSegments];
    [self.punchTypeSegmentedControl insertSegmentWithTitle:RPLocalizedString(@"Clock In", nil)  atIndex:index animated:YES];
    index++;
    BOOL isPunchIntoProjectsUser = [self isPunchIntoProjectsUser];
    BOOL isPunchIntoActivitiesUser = [self isPunchIntoActivitiesUser];
    if (isPunchIntoProjectsUser || isPunchIntoActivitiesUser)
    {
        [self.punchTypeSegmentedControl insertSegmentWithTitle:RPLocalizedString(@"Transfer", nil)  atIndex:index animated:YES];
        index++;

    }
    if ([self isBreaksUser])
    {
        [self.punchTypeSegmentedControl insertSegmentWithTitle:RPLocalizedString(@"Break", nil)     atIndex:index animated:YES];
        index++;
    }

    [self.punchTypeSegmentedControl insertSegmentWithTitle:RPLocalizedString(@"Clock Out", nil) atIndex:3 animated:YES];

    self.punchTypeSegmentedControl.selectedSegmentIndex = 0;

    [self.punchTypeSegmentedControl setAccessibilityIdentifier:@"punch_type_segment_control"];
}
- (IBAction)doneActionFromToolBar:(id)sender
{
    [self hidePickerWithToolBar];
}

-(void)showPickerWithToolBar
{
    [self.view endEditing:YES];
    self.toolBar.hidden = NO;
    self.datePicker.hidden = NO;
}

-(void)hidePickerWithToolBar
{
    self.toolBar.hidden = YES;
    self.datePicker.hidden = YES;
}

- (FlowType )getUserFlowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userURI];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

-(void)reloadWithNewPunchAttributes:(id<Punch>)punch
{
    FlowType flowType = [self getUserFlowType];
    PunchAttributeController *punchAttributeController = [self.injector getInstance:[PunchAttributeController class]];
    [punchAttributeController setUpWithNeedLocationOnUI:NO
                                               delegate:self
                                               flowType:flowType
                                                userUri:self.userURI
                                                  punch:punch
                               punchAttributeScreentype:PunchAttributeScreenTypeADD];

    [self.childControllerHelper replaceOldChildController:self.punchAttributeController
                                   withNewChildController:punchAttributeController
                                       onParentController:self
                                          onContainerView:self.punchAttributeContainerView];
    self.punchAttributeController = punchAttributeController;
}

-(ManualPunch *)manualPunch
{
    NSInteger selectedIndex = [self.punchTypeSegmentedControl selectedSegmentIndex];
    PunchActionType actionType = [self punchActionTypeForSelectedSegmentIndex:selectedIndex];
    BreakType *breakType = actionType == PunchActionTypeStartBreak ? self.selectedBreakType : nil;
    NSArray *oefTypes = [self.oefTypesStotage getAllOEFSForPunchActionType:actionType];
    return [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:nil breakType:breakType location:nil project:nil requestID:[self.guidProvider guid] activity:nil client:nil oefTypes:oefTypes address:nil userURI:self.userURI image:nil task:nil date:self.datePicker.date];
}

-(BOOL)isValidString:(NSString *)value
{
    return (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]);
}

-(BOOL)isPunchIntoProjectsUser
{

    if ([self getUserFlowType] == SupervisorFlowContext)
    {
        BOOL isReporteePunchIntoProjectsUser = [self.reporteePermissionsStorage isReporteePunchIntoProjectsUserWithUri:self.userURI];
        return isReporteePunchIntoProjectsUser;
    }
    else
    {
        BOOL canAccessProject = [self.punchRulesStorage hasProjectAccess];
        BOOL canAccessActivity = [self.punchRulesStorage hasActivityAccess];
        BOOL isAstroPunchUser = [self.punchRulesStorage isAstroPunchUser];

        BOOL isPunchIntoProjectsUser = isAstroPunchUser && (canAccessProject || canAccessActivity);
        return isPunchIntoProjectsUser;
    }

}

-(BOOL)isPunchIntoActivitiesUser
{
    if ([self getUserFlowType] == SupervisorFlowContext)
    {
        BOOL isReporteePunchIntoActivitesUser = [self.reporteePermissionsStorage canAccessActivityUserWithUri:self.userURI];
        return isReporteePunchIntoActivitesUser;
    }
    else
    {
        BOOL canAccessActivity = [self.punchRulesStorage hasActivityAccess];
        BOOL isAstroPunchUser = [self.punchRulesStorage isAstroPunchUser];

        BOOL isPunchIntoActivitesUser = (isAstroPunchUser && canAccessActivity );

        return isPunchIntoActivitesUser;
    }

}

-(BOOL)isBreaksUser
{
    if ([self getUserFlowType] == SupervisorFlowContext)
    {
        BOOL isReporteePunchIntoActivitesUser = [self.reporteePermissionsStorage canAccessBreaksUserWithUri:self.userURI];
        return isReporteePunchIntoActivitesUser;
    }
    else
    {
        BOOL canAccessBreak = [self.punchRulesStorage breaksRequired];
        return canAccessBreak;
    }
    
}


#pragma mark - <keyboard helper>


-(void) keyboardWillShow: (NSNotification *)notif {

    [self hidePickerWithToolBar];
    // If keyboard is visible, return
    if (self.keyboardVisible) {
        //Keyboard is already visible. Ignore notification
        return;
    }

    // Get the size of the keyboard.
    NSDictionary* info = [notif userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;

    // Resize the scroll view to make room for the keyboard
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height = (viewFrame.size.height - keyboardSize.height) + 48.0;
    self.scrollView.frame = viewFrame;


    // Keyboard is now visible
    self.keyboardVisible = YES;
}

-(void) keyboardWillHide: (NSNotification *)notif {
    // Is the keyboard already shown
    if (!self.keyboardVisible) {
        //Keyboard is already hidden. Ignore notification
        return;
    }

    // Reset the frame scroll view to its original value
    self.scrollView.frame = self.view.frame;


    // Keyboard is no longer visible
    self.keyboardVisible = NO;

}

@end
