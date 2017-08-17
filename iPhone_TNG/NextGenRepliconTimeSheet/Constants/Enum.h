typedef NS_ENUM(NSInteger,NavigationFlow)
{
    UNKNOWN_NAVIGATION = -1,
    USER_NAVIGATION=0,
    PENDING_APPROVER_NAVIGATION = 1,
    PREVIOUS_APPROVER_NAVIGATION =2,
    TIMESHEET_PERIOD_NAVIGATION = 3,
    ATTENDANCE_NAVIGATION = 4,
    DAY_TIME_ENTRY_NAVIGATION = 5,
    EDIT_TIME_ENTRY_NAVIGATION = 6,
    TIMEOFF_BOOKING_NAVIGATION = 101,

};

typedef NS_ENUM(NSInteger,UDFType)
{
    UDF_TYPE_TEXT,
    UDF_TYPE_NUMERIC,
    UDF_TYPE_DATE,
    UDF_TYPE_DROPDOWN,
};

typedef NS_ENUM(NSInteger,DeviceType)
{
    OnSimulator,
    OnDevice,
};



typedef NS_ENUM(NSUInteger, PunchPairStatus) {
    Present,
    Missing,
    Ticking,
    Unknown
};

typedef NS_ENUM(NSUInteger, SourceOfPunch) {
    Web,
    CloudClock,
    Mobile,
    UnknownSourceOfPunch
};




typedef NS_ENUM(NSUInteger, PunchAssemblyGuardErrorCode) {
    PunchAssemblyGuardErrorCodeUnknown,
    PunchAssemblyGuardErrorCodeChildAssemblyGuardError
};

typedef NS_ENUM(NSUInteger, LocationAssemblyGuardErrorCode) {
    LocationAssemblyGuardErrorCodeUnknown,
    LocationAssemblyGuardErrorCodeDeniedAccessToLocation,
};

typedef NS_ENUM(NSUInteger, CameraAssemblyGuardErrorCode) {
    CameraAssemblyGuardErrorCodeUnknown,
    CameraAssemblyGuardErrorCodeDeniedAccessToCamera,
};


typedef NS_ENUM(NSInteger,SubmitButtonState)
{
    CAN_SUBMIT=0,
    CAN_UNSUBMIT=1,
    CAN_RESUBMIT=2,
    CAN_REOPEN=3,
};

typedef NS_ENUM(NSUInteger, TimesheetDayButtonType) {
    WEEK_DAY_TIMESHEET_BUTTON = 0,
    WEEK_OFF_DAY_TIMESHEET_BUTTON = 1,
};

typedef NS_ENUM(NSUInteger, ApprovalDetailsModule) {
    TIMESHEET = 0,
    EXPENSES = 1,
    TIMEOFF=2,
};
typedef NS_ENUM(NSInteger, ScreenMode)
{
    ADD_ENTRY_SCREEN =0,
    EDIT_ENTRY_SCREEN = 1,
    ADD_ACTIVITY_SCREEN =2,
    ADD_BILLING_SCREEN = 3,
};

typedef NS_ENUM(NSUInteger, TimeOffDetailsCalendarView) {
    TIMEOFF_ADD = 1,
    TIMEOFF_VIEW = 2,
    TIMEOFF_EDIT = 3,
    //    TIMEOFF=2,
};

typedef NS_ENUM(NSInteger, From_View_Controller)
{
    Time_Entry_View=0,
    Expense_Entry_View = 1,
};

typedef NS_ENUM(NSInteger, View_To_Load)
{
    CLIENT_AND_PROJECT_VIEW=0,
    PROJECT_AND_TASK_VIEW = 1,
};

typedef NS_ENUM(NSInteger, ApprovalActionType)
{
    ApproveActionType=0,
    RejectActionType = 1,
};

typedef NS_ENUM(NSInteger, PunchCardType)
{
    DefaultClientProjectTaskPunchCard=0,
    FilledClientProjectTaskPunchCard=1,
    PunchOutClientProjectTaskPunchCard=2,
    UnknownPunchCard=2,
};

typedef NS_ENUM(NSInteger, PunchCardsControllerType)
{
    SeeAllPunchCardsControllerType=0,
    TransferPunchCardsControllerType=1,
};

typedef NS_ENUM(NSInteger, SelectionScreenType)
{
    SelectionScreenTypeNone =-1,
    ClientSelection=0,
    ProjectSelection=1,
    TaskSelection=2,
    ActivitySelection=3,
    OEFDropDownSelection=4
};

typedef NS_ENUM(NSInteger, PunchAttribute)
{
    ClientAttribute=0,
    ProjectAttribute=1,
    TaskAttribute=2,
    LocationAttribute=3,
    ActivityAttribute=4,
    OEFAttribute=5,
};

typedef NS_ENUM(NSInteger, FlowType)
{
    UserFlowContext=0,
    SupervisorFlowContext=1,
};

typedef NS_ENUM(NSInteger, KeyBoardType)
{
    DefaultKeyboard=0,
    NumericKeyboard=1,
    NoKeyboard=2,
};
typedef enum : NSUInteger {
    TimesheetUserTypeGolden,
    TimesheetUserTypeNongolden,
} TimesheetUserType;

typedef NS_ENUM(NSInteger,ViewItemsAction)
{
    More=0,
    Less=1,
};

typedef NS_ENUM(NSInteger,PunchSyncStatus)
{
    UnsubmittedSyncStatus=0,
    PendingSyncStatus=1,
    ErrorSyncStatus=2,
    RemotePunchStatus=3,
};

typedef NS_ENUM(NSInteger, PunchAttributeScreentype)
{
    PunchAttributeScreenTypeADD=0,
    PunchAttributeScreenTypeEDIT=1,
    PunchAttributeScreenTypeNONE = 2
};

typedef enum {
    ObjectExtensionFieldTypeNone = 0,
    TextOEFType = 1,
    NumberOEFType = 2,
    DropDownOEFType = 3
} ObjectExtensionFieldType;

typedef NS_ENUM(NSInteger, ProjectStorageFlowType)
{
    ExpenseProjectStorageFlowContext=0,
    PunchProjectStorageFlowContext=1,
};

typedef NS_ENUM(NSInteger, TimeLinePunchFlow)
{
    CardTimeLinePunchFlowContext=0,
    DayControllerTimeLinePunchFlowContext=1,
};

typedef NS_ENUM(NSInteger, ApplicateState)
{
    Foreground=0,
    Background=1,
};

typedef NS_ENUM(NSInteger, WorkFlowType) {
    TransferWorkFlowType = 0,
    ResumeWorkFlowType = 1,
    NoneWorkflowType = 2
};

typedef NS_ENUM(NSInteger, WidgetType){
    NoticeWidgetType = 0,
    AttestationWidgetType = 1,
    PaysummaryWidgetType = 2,
    DailyFieldsWidgetType = 3,
    DefaultWidgetType = 4
};

typedef NS_ENUM(NSInteger, TimesheetWidgetType){
    PayWidget,
    PunchWidget,
    AttestationWidget,
    NoticeWidget,
    TimeoffInLieuWidget,
    TimedistributionWidget,
    DailyfieldWidget,
    UnknownWidget
};

typedef NS_ENUM(NSInteger,GrossSummaryScreenType)
{
    GrossPayScreen=0,
    GrossHoursScreen=1,
};

typedef NS_ENUM(NSInteger,ViewMode)
{
    ShowActualsMore=0,
    ShowActualsLess=1,
};

typedef NS_ENUM(NSInteger,AttestationStatus)
{
    Attested=0,
    Unattested=1,
};

typedef enum {
    
    RightBarButtonActionTypeSubmit      = 5000,
    RightBarButtonActionTypeReOpen      = 5001,
    RightBarButtonActionTypeReSubmit    = 5002,
    RightBarButtonActionTypeNone        = 5003
}RightBarButtonActionType;
