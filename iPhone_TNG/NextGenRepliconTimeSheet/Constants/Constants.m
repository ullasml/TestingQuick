#import "Constants.h"

NSString *GEN4_TIMESHEET_ERROR_URI = @"urn:replicon:severity:error";
NSString *GEN4_TIMESHEET_WARNING_URI = @"urn:replicon:severity:warning";
NSString *GEN4_TIMESHEET_INFORMATION_URI = @"urn:replicon:severity:information";

NSString *const PUNCH_ACTION_URI_IN = @"urn:replicon:time-punch-action:in";
NSString *const PUNCH_ACTION_URI_OUT = @"urn:replicon:time-punch-action:out";
NSString *const PUNCH_ACTION_URI_TRANSFER = @"urn:replicon:time-punch-action:transfer";
NSString *const PUNCH_ACTION_URI_BREAK = @"urn:replicon:time-punch-action:start-break";

NSString *const TAB_BAR_MODULES_KEY = @"TabBarModulesArray";
NSString *const TIMESHEETS_TAB_MODULE_NAME = @"Timesheets_Module";
NSString *const EXPENSES_TAB_MODULE_NAME = @"Expenses_Module";
NSString *const TIME_OFF_TAB_MODULE_NAME = @"BookedTimeOff_Module";
NSString *const CLOCK_IN_OUT_TAB_MODULE_NAME = @"Attendance_Module";
NSString *const PUNCH_HISTORY_TAB_MODULE_NAME = @"Punch History_Module";
NSString *const SCHEDULE_TAB_MODULE_NAME = @"Shifts_Module";
NSString *const APPROVAL_TAB_MODULE_NAME = @"Approvals_Module";
NSString *const SETTINGS_TAB_MODULE_NAME = @"More_Settings";
NSString *const NEW_PUNCH_WIDGET_MODULE_NAME = @"New_Punch_Widget_System";
NSString *const PUNCH_IN_PROJECT_MODULE_NAME = @"punchInProject_Module";
NSString *const PUNCH_INTO_ACTIVITIES_MODULE_NAME = @"Punch_Into_Activities_Module";
NSString *const WRONG_CONFIGURATION_MODULE_NAME = @"Wrong_Configuration_Module_Name";
NSString *const PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME = @"PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME";

NSString *const CameraAssemblyGuardErrorDomain = @"CameraAssemblyGuardErrorDomain";
NSString *const LocationAssemblyGuardErrorDomain = @"LocationAssemblyGuardErrorDomain";
NSString *const PunchAssemblyGuardErrorDomain = @"PunchAssemblyGuardErrorDomain";
NSString *const PunchAssemblyGuardChildErrorsKey = @"PunchAssemblyGuardChildErrorsKey";

NSString *const PunchRequestIdentifierHeader = @"X-Astro-Punch-Identifier";
NSString *const MostRecentPunchDateIdentifierHeader = @"MostRecentPunchDateIdentifierHeader";
NSString *const GetTimesheetSummaryDateIdentifierHeader = @"GetTimesheetSummaryDateIdentifierHeader";


NSString *const RepliconHTTPRequestError_998 = @"An unknown error occurred. Please try again. If the problem persists, please contact support.";
NSString *const RepliconHTTPRequestError_999 = @"The operation could not be completed.";
NSString *const RepliconHTTPRequestError_1001 = @"Server request timed out. Please ensure you have an internet connection and try again.";
NSString *const RepliconHTTPRequestError_1200 = @"Server request timed out. Please ensure you have an internet connection and try again.";


NSString *const RepliconServerMaintenanceError = @"Replicon server is unreachable at this time. Please try again later.";
NSString *const RepliconGenericPosixOrUrlDomainError = @"Please try again. If the problem persists, please contact Replicon support.";

NSString *const RepliconHTTPNonJsonResponseErrorDomain = @"RepliconHTTPNonJsonResponseErrorDomain";
NSString *const RepliconFailureStatusCodeDomain = @"RepliconFailureStatusCodeDomain";
NSString *const RepliconHTTPRequestErrorDomain = @"RepliconHTTPRequestErrorDomain";
NSString *const RepliconNoAlertErrorDomain = @"RepliconNoAlertErrorDomain";
NSString *const PasswordAuthenticationErrorDomain = @"PasswordAuthenticationErrorDomain";
NSString *const CompanyAuthenticationErrorDomain = @"CompanyAuthenticationErrorDomain";
NSString *const CompanyDisabledErrorDomain = @"CompanyDisabledErrorDomain";
NSString *const NoAuthErrorDomain = @"NoAuthErrorDomain";
NSString *const PasswordExpiredErrorDomain = @"PasswordExpiredErrorDomain";
NSString *const UnknownErrorDomain = @"UnknownErrorDomain";
NSString *const UserAuthChangeErrorDomain = @"UserAuthChangeErrorDomain";
NSString *const UserDisabledErrorDomain = @"UserDisabledErrorDomain";
NSString *const InvalidTimesheetFormatErrorDomain = @"InvalidTimesheetFormatErrorDomain";
NSString *const OperationTimeoutErrorDomain = @"OperationTimeoutErrorDomain";
NSString *const UriErrorDomain = @"UriErrorDomain";
NSString *const RandomErrorDomain = @"RandomErrorDomain";
NSString *const InvalidUserSessionRequestDomain = @"InvalidUserSessionRequestDomain";
NSString *const AuthorizationErrorDomain = @"AuthorizationErrorDomain";

NSString *const NoTimeSheetAssignedMsg = @"A timesheet template has not been assigned to your account. Please contact your Admin.\n​Once the issue is resolved, please refresh the app.";

NSString *const RefreshButtonTitle = @"Refresh";

NSString *const PasswordResetFailedMessage = @"Password reset failed. Please try again";
NSString *const EnterValidEmailMessage = @"Please enter a valid email";
NSString *const EnterValidEmailAndCompanyMessage = @"Please enter company name and email id";
NSString *const InstructionsToResetPasswordMessage = @"Instructions to reset your password have been emailed to you. Please check your email.";
NSString *const ForgotPasswordViewTitle = @"Enter your Company Name and Email Address to reset your password";
NSString *const ForgotPasswordTitle = @"Forgot Password?";
NSString *const CompanyNamePlaceholderText = @"Company Name";
NSString *const EmailAddressPlaceholderText = @"Email Address";
NSString *const ResetPasswordButtonTitle = @"Reset Password";
NSString *const RequestMadeWhileInvalidUserSessionHeaderValue = @"RequestMadeWhileInvalidUserSessionHeaderValue";
NSString *const RequestMadeWhileInvalidUserSessionHeaderKey = @"RequestMadeWhileInvalidUserSessionHeaderKey";
NSString *const RequestMadeForSearchWithHeaderKey = @"RequestMadeForSearchWithHeaderKey";
NSString *const RequestMadeForSearchWithValue = @"RequestMadeForSearchWithValue";
NSString *const RequestMadeWhilePendingQueueSyncHeaderValue = @"RequestMadeWhilePendingQueueSyncHeaderValue";
NSString *const RequestMadeWhilePendingQueueSyncHeaderKey = @"RequestMadeWhilePendingQueueSyncHeaderKey";

NSString *const attendanceTitle = @"Time Capture for Attendance";
NSString *const approvalAttendanceTitle= @"Approvals for Time & Attendance";
NSString *const clientBillingTitle= @"Time Capture for Client Billing";
NSString *const approvalClientBillingTitle= @"Approvals for Client Billing";
NSString *const attendanceDetailsText= @"GPS enabled clock in & out from\nanywhere, anytime. Gain real-time access\nto your shifts and time off.";
NSString *const approvalAttendanceDetailsText= @"Approve timesheets and time off at your convenience. Ensure compliance & insight into workforce productivity.";
NSString *const clientBillingDetailsText= @"Track billable and non-billable hours by client, project and task. Request time off and capture expenses, even on-the-go.";
NSString *const approvalClientBillingDetailsText= @"Include project managers, supervisors, and clients for approvals. Track project progress, billing and client profitability in real-time.";

NSString *const noTimeOffTypesAssigned= @"You do not have any time off types assigned. Please contact your Admin.";
NSString *const wrongConfigurationMsg= @"Your punch configuration is not supported.";
NSString *const serviceUnavailabilityIssue= @"serviceUnavailabilityIssue";
NSString *const RepliconServiceUnAvailabilityResponseErrorDomain = @"RepliconServiceUnAvailabilityResponseErrorDomain";

NSString *const OEF_NUMERIC_DEFINITION_TYPE_URI= @"urn:replicon:object-extension-definition-type:object-extension-type-numeric";
NSString *const OEF_TEXT_DEFINITION_TYPE_URI= @"urn:replicon:object-extension-definition-type:object-extension-type-text";
NSString *const OEF_DROPDOWN_DEFINITION_TYPE_URI= @"urn:replicon:object-extension-definition-type:object-extension-type-tag";

NSString *const phoneCaptureDescription = @"Please enter your phone number. We may need to call you, if we have additional questions.";
NSString *const phoneCapturePlaceHolder = @"My Phone Number:";

NSString *const syncTimesheetLocalNotificationMsg = @"Some of your data has not been saved on the Replicon server.  Please ensure your device has an Internet connection to sync the data.";

NSString *const errorNotification = @"ERROR_BANNER_FAILED_NOTIFICATION";
NSString *const successNotification = @"ERROR_BANNER_SUCCESS_NOTIFICATION";

NSString *const noErrorsDisplayMsg = @"There are no errors.";

const int errorBannerHeight = 45;
NSString *const DeleteAllErrorsMessage = @"Are you sure you want to dismiss all notifications from this list?";
NSString *const cellDeleteButtonText = @"Dismiss";
NSString *const dismissAllText = @"Dismiss All";
NSString *const notificationText = @"Notification";
NSString *const notificationsText  = @"Notifications";
NSString *const rejectionCommentsErrorText = @"Please enter a comment indicating the reason for rejection.";
NSString *const totalHoursText = @"Total Hours";
NSString *const inOutWidgetMidNightCrossUri = @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:split-time-that-cross-midnight";
NSString *const allowInOutWidgetSplitMidNightCrossUri = @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:split-time-that-cross-midnight:allow-split-time-that-cross-midnight";
NSString *const extendedInOutWidgetMidNightCrossUri = @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:split-time-that-cross-midnight";
NSString *const allowExtendedInOutWidgetSplitMidNightCrossUri = @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:split-time-that-cross-midnight:allow-split-time-that-cross-midnight";

NSString *const saveInProgressTitle = @"Save in Progress";
NSString *const saveInProgressText =  @"Previous time entries are still being saved to Replicon. Please try again.";

NSString *const  breakTypeText = @"Break Type";
NSString *const  selectBreakTypeText = @"Please select a break type.";
NSString *const InvalidProjectSelectedError = @"Please select a project";
NSString *const InvalidTaskSelectedError = @"Please select a task";

NSString *const  punchesWithErrorsTitle = @"Punches With Errors";
NSString *const  punchesWithErrorsMsg = @"The following punches were not \n saved to replicon due to reasons  \n specified below:";

NSString *const  selectFromBookmarksText = @"Select From Bookmarks";
NSString *const  createBookmarksText = @"Create Bookmark";
NSString *const  noBookmarksAvailableText = @"You don't have any bookmarks.\nTap on the + button to add new bookmarks";
NSString *const  noBookmarksCreatedText = @"No Bookmarks Created";

NSString *const  clientProjectTaskSelectionErrorMsg = @"Please select a client, project & task.";
NSString *const  projectAndTaskSelectionErrorMsg = @"Please select a project & task.";
NSString *const  previousProjectsText = @"Select from previous projects";


NSString *const InvalidActivitySelectedError = @"Please select an activity.";
NSString *const CameraAccessDisabledError = @"Please change your camera settings to \"Allow Camera\".";
NSString *const GPSAccessDisabledError = @"Please change your location settings to \"Allow Location\".";
NSString *const CameraAccessDisabledErrorAlertTitle = @"Image Capture is Required";
NSString *const GPSAccessDisabledErrorAlertTitle = @"Location is Required";
NSString *const withString = @"with";

NSString *const ClientTypeAnyClient = @"Any Client";
NSString *const ClientTypeNoClient = @"No Client";
NSString *const ClientTypeAnyClientUri = @"urn:replicon:client-null-filter-behavior:not-filtered";
NSString *const ClientTypeNoClientUri = @"urn:replicon:client-null-filter-behavior:filtered";

NSString *const NumericOEFPlaceholder = @"Enter Number";
NSString *const TextOEFPlaceholder = @"Enter Text";
NSString *const DropDownOEFPlaceholder = @"Select";

NSString *const offlineMessage = @"Your device is offline.  Please try again when your device is online.";

NSString *const OEFMaxPrecisionKey = @"oefMaxPrecision";
NSString *const OEFMaxScaleKey = @"oefMaxScale";
NSString *const OEFMaxTextCharLimitKey = @"oefMaxTextCharLimit";

NSString *const OEFNumericFieldValueLimitExceededError = @"Please enter a value between -%@ to %@.";
NSString *const OEFTextFieldValueLimitExceededError = @"You have reached the maximum character limit of %@.";

NSString *const  ProjectTimeAndExpenseEntryTypeNonBillableUri = @"urn:replicon:time-and-expense-entry-type:non-billable";
NSString *const  ProjectBillingTypeNonBillableUri = @"urn:replicon:billing-type:non-billable";

NSString *const  ApplicationStateHeaders = @"X-Application-State";
NSString *const  RequestTimestamp = @"X-Request-Timestamp";
NSString *const  ApplicationLastActiveForegroundTimestamp = @"ApplicationLastActiveForegroundTimestamp";

NSString *const  AllowSplitTimeMidNightCrossEntry = @"allowSplitTimeMidnightCrossEntry";
NSString *const  SplitTimeEntryForNextTimesheetPeriod = @"splitEntryNextTimesheetData";

NSString *const  PunchesWereNotSavedErrorNotificationMsg = @"Punches were not saved to Replicon server. Tap to retry.";
NSString *const  Issues_text = @"Validations";
NSString *const  Issue_text = @"Validation";

NSString *const  PunchEmptyState_First = @"No Time Recorded";
NSString *const  PunchEmptyState_Second = @"It looks like you have no time punches recorded for this day";

NSString *const  UnknownText = @"Unknown";

NSString *const ApprovedTimesheetStatus     = @"urn:replicon:timesheet-status:approved";
NSString *const NotSubmittedTimesheetStatus = @"urn:replicon:timesheet-status:open";
NSString *const RejectedTimesheetStatus     = @"urn:replicon:timesheet-status:waiting";
NSString *const WaitingTimesheetStatus      = @"urn:replicon:timesheet-status:rejected";



NSString *const  invalidProjectFailureUri = @"urn:replicon:validation-failure-mobile:project-task-is-invalid";

NSString *const  BulkPunchWithCreatedAtTime3 = @"BulkPunchWithCreatedAtTime3";
