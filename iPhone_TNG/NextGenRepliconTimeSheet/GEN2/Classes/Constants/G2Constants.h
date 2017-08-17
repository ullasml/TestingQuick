/*
 *  Constants.h
 *  SweetDeals
 *
 *  Created by Sasikant on 19/09/09.
 *  Copyright 2009 Enlume. All rights reserved.
 *
 */

#import "G2FileNameConstants.h"
#import "G2Dimensions-iPhone.h"
#import "G2Fonts-iPhone.h"
#import "G2ImageNameConstants.h"
#import "G2Colors-iPhone.h"

//expenseModuleOnly

#define  expenseModuleOnly 0

#define PHASE1_US2152
//#define DEV_DEBUG

typedef enum ProjectPermissionType {
	PermType_Invalid = -1,
	PermType_ProjectSpecific,
	PermType_NonProjectSpecific,
	PermType_Both
}ProjectPermissionType;


typedef enum ActionType	{
	ActionType_ExpenseSheetsList,
	ActionType_NewExpenseSheet,
	ActionType_ExpenseEntryList,
	AcitonType_NewExpenseEntry,
	ActionTYpe_EditExpenseEntry,
	ActionType_DeleteExpenseEntry,
	AcitonType_DeleteExpenseSheet,
	ActionType_SubmitExpenseSheet,
	AcitonType_UnsubmitExpenseSheet,
	ActionType_ResubmitExpenseSheet,
	ActionType_TimesheetList,
	ActionType_NewTimeEntry,
	ActionType_TimeEntriesList,
    ActionType_NewTimeOffEntry//US4591//Juhi
	//ActionType_NewTimeEntry
} ActionType;


//Table name constants
#define table_ExpenseSheets @"expense_sheets"
#define table_expenseEntries @"expense_entries"


enum TableRowNavigationType {
	NavigationType_Previous,
	NavigationType_Next
};


#define SCHEDULE_DAILY 86400
#define SCHEDULE_WEEKLY 604800

#define EXPENSES_DATA_SERVICE_SECTION @"ExpenseByUser"
#define EXPENSES_SUPPORT_DATA_SECTION @"ExpenseSupportData"
#define TIMESHEET_SUPPORT_DATA_SERVICE_SECTION @"TimesheetSupportData"
#define TIMESHEET_DATA_SERVICE_SECTION @"TimesheetByUser"
#define GENERAL_SUPPORTING_DATA_SECTION @"GeneralSupportingData"
#define APPROVAL_TIMESHEET_DATA_SERVICE_SECTION @"TimesheetForApprover"
#define TIMEOFF_SUPPORT_DATA_SERVICE_SECTION @"TimeOffSupportData"
#define APPROVALS_SUPPORT_DATA_SERVICE_SECTION @"ApprovalsGeneralSupportingData"

#define EXPENSE_DATA_CAN_RUN @"EXPENSE_DATA_CAN_RUN"
#define EXPENSE_SUPPORT_DATA_CAN_RUN @"EXPENSE_SUPPORT_DATA_CAN_RUN"
#define TIMESHEET_DATA_CAN_RUN @"TIMESHEET_DATA_CAN_RUN"
#define TIMESHEET_SUPPORT_DATA_CAN_RUN @"TIMESHEET_SUPPORT_DATA_CAN_RUN"
#define TIMEOffs_SUPPORT_DATA_CAN_RUN @"TIMEOFFs_SUPPORT_DATA_CAN_RUN"
 

/////////////////////////////////////////////////
//   Generic  constants  //
/////////////////////////////////////////////////

#define TableView_Cell_Row_Height_40 40
#define APPROVED_STATUS @"Approved"
#define NOT_SUBMITTED_STATUS @"Not Submitted"
#define G2WAITING_FOR_APRROVAL_STATUS @"Waiting For Approval"
#define REJECTED_STATUS @"Rejected"
#define PROJECT_SPECIFIC @"ProjectSpecific"
#define BOTH  @"Both"
#define NON_PROJECT_SPECIFIC @"NonProjectSpecific"
#define SelectString @"Select"
#define NoTaskString @"No tasks"
#define NoInternetConnectivity @"No Internet Connectivity"
#define SUBMIT @"Submit"
#define RESUBMIT @"Resubmit"
#define UNSUBMIT @"Unsubmit"
#define DELETE @"Delete"
#define NULL_STRING @"<null>"
#define NO_CLIENT_ID @"null"
#define AGAINSTPROJECT @"Against Project"
#define WITHOUT_REQUIRING_PROJECT @"Without requiring a project"
#define NONE_STRING @"None"
#define UNSUBMIT_ADD_MESSAGE @"This entry is dated for a submitted timesheet.  Do you want to unsubmit the timesheet and add the entry?"
#define REOPEN_ADD_MESSAGE @"This entry is dated for a submitted timesheet.  Do you want to reopen the timesheet and add the entry?"
#define UNSUBMIT_ADD_TITLE @"This entry is dated for a submitted timesheet."
#define SELECT_ANOTHER_DATE_MESSAGE @"Please select another date."
#define ExpenseType_UnAvailable @"The selected expense type is not valid for this project."
#define PROJECT_TYPE_BUCKET @"Bucket"
#define LoadingMessage @"Loading..."
#define SavingMessage @"Saving..."
#define SubmittingMessage @"Submitting..."
#define UnSubmittingMessage @"Unsubmitting..."
#define DeletingMessage @"Deleting..."
#define ApprovingMessage @"Approving..."
#define RejectingMessage @"Rejecting..."

#define G2NoSheetsAvailable @"There are no expenses in this sheet."
//US4660//Juhi
#define REOPEN @"Reopen"
#define ReopeningMessage @"Reopening..."
/////////////////////////////////////////////////
//      RootTabbarViewController               //
/////////////////////////////////////////////////

#define PunchClockTabbarTitle @"Clock"
#define ExpenseTabbarTitle @"Expenses"
#define ApprovalsTabbarTitle @"Approvals"
#define MoreTabbarTitle @"Settings"
#define TimeSheetsTabbarTitle @"Timesheets"
#define AddNewTimeEntryTitle @"Add Time Entry"
#define EditTimeEntryTitle @"Edit Time Entry"

/////////////////////////////////////////////////
//     FreeTrialViewController               //
/////////////////////////////////////////////////
#define FirstName_Error_Message @"Please enter your First Name"
#define LastName_Error_Message @"Please enter your Last Name"
#define Phone_Error_Message @"Please enter your Phone No"
#define InvalidEmail_Error_Message @"Please enter a valid E-mail Address"
#define Email_Error_Message @"Please enter your Email"
#define CompanyName_Error_Message @"Please enter your Company Name"
#define Password_Error_Message @"Please enter your Password"
#define PasswordMisMatch_Message @"Passwords Does Not Match"
#define FreeTrial @"Free Trial"
#define Free_Trial_Btn_Title @"Free Trial Sign Up"
#define Use_Replicon_Btn_Title @"Start Using Replicon Now"
#define Free_Sign_UP_Message @"  Sign up for a two week free trial!"
#define Replicon_Register_Message @"By registering you agree to Replicon's Terms of Service."
#define UseLogin @"* You will use this at login"
#define Welcome_Replicon_Message @"Welcome to Replicon Mobile!"
#define Start_BTN_TITLE @"Start"
#define FreeTrial_ServiceID_66 66 
#define FREE_TRIAL_SIGN_UP_NOTIFICATION @"Free trial Sign up"
#define RESET_PASSWORD_NOTIFICATION @"Reset password"
#define Free_Message_Label1 @"Replicon Mobile enables you and your staff to keep track of time and expenses directly on your mobile phone. Please take the next two weeks to test drive Replicon Mobile."
#define Free_Message_Label2 @"A representative will contact you soon. If you have any questions in the meantime, please email us at: sales@replicon.com"

/////////////////////////////////////////////////
//            HomeViewController               //
/////////////////////////////////////////////////
#define ExpenseLabelText @"Expenses"
#define TimeSheetLabelText @"Timesheets"
#define TimeoffLabelText  @"Time Off"
#define MoreLabelText     @"Settings"
#define ApprovalsLabelText @"Approvals"
#define NoUDFSupportMessage @"Custom timesheet level (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time."//US4337//Juhi


#define PROJECT_SPECIFIC_YES 1
#define PROJECT_SPECIFIC_NO 0
#define NON_PROJECT_SPECIFIC_YES 1
#define NON_PROJECT_SPECIFIC_NO 0

#define FetchCompanyURL_ServiceID_0  0
#define UserByLoginName_ServiceID_1  1

#define ExpenseByUser_ServiceID_3 3
#define ExpenseTypesWithTaxCodes_ServiceID_4 4
#define ExpenseClients_ServiceID_5 5
#define ExpenseProjects_ServiceID_6 6
#define ExpenseProjectsByClient_ServiceID_7 7
#define ExpenseTypeAll_ServiceID_8 8
#define GetSystemPreferences_ServiceID_9 9
#define Unsubmit_ServiceID_10 10
#define Submit_ServiceID_11 11
#define ExpenseById_ServiceID_12 12
#define TaxCodeAll_ServiceID_13  13
#define GetReceiptImages_Service_ID_15 15
#define ReimbursementCurrencies_17  17
#define BaseCurrencies_ServiceID_18 18
#define UploadReceiptImage_ServiceID_19 19
#define SaveExpenseEntryWithReceipt_ServiceID_20 20
#define SystemPaymentMethods_ServiceID_21 21
#define ExpenseProjectsTypesWithTaxs_ServiceID_22 22
#define ExpenseAllTypesWithTaxes_ServiceID_23 23
#define UDF_ServiceID_16 16
#define DeleteExpenseSheet_ServiceID_24 24
#define DeleteExpenseEntry_ServiceID_25 25
#define FetchNextRecentExpenseSheets_26 26
#define SaveExpenseSheet_27 27
#define SaveNewExpenseEntry_28 28
#define ApprovalsDetailsOnUnsubmit_30 30
#define ApprovalsDetailsForSubmittedSheet_31 31
#define ApprovalsDetailsOnUnsubmit_30 30
#define ApprovalsDetailsForSubmittedSheet_31 31
#define GetSessionId_36 36
#define EndSession_39 39
#define GetUserPreferences_40 40
#define ExpenseSheetsExisted_Service_Id_64 64
#define BookedTimeOff_Service_Id_61 61
#define TimeSheetsExisted_Service_Id_65 65
#define GetTimesheetWithDate 68

/////////////////////////////////////////////////
//            LoginViewController               //
/////////////////////////////////////////////////
#define ErrorTitle @""//DE1231//Juhi
#define UserHaveNoRelevantPermissions @"The Replicon features you use are currently not supported by the Replicon Mobile app. \n\n Look for additional features to be added in future versions."

#define welcomeLabelText @"Welcome!"
#define LoginTopLabelText @"Please Sign in."
#define ForgotPasswordLabelText @"Forgot your password?"
#define ForgotLabelText @"(opens link in Safari)"
#define FreeTrailLabelText @"Sign up for a FREE trial"
#define SignUpLabelText  @"(no credit card required)"
#define SignIn @"Sign In"
#define InvaliDLogin @"Incorrect Login or Password"
#define InvalidUserName @"Incorrect User Name"
#define InvalidCompanyName @"Unknown Company.  Please check that it was entered correctly."
#define InvaliDLoginName @"Please enter your User Name."
#define UserNameValidationMessage @"Please enter your Company."

//#define LocalLoginValidatedErrorMessage @"Please fill-in all fields"
#define LocalLoginValidatedErrorMessage @"Please complete all fields"
#define LOCAL_USER_LOGIN_VALIDATION @"NO User Found"
#define LoginAlertErrorTitle @""//DE1231//Juhi
#define LOGIN_NUMBER_OF_ROWS 3
#define G2_LOGIN_CELL_ROW_HEIGHT 40
#define ChangePasswordService_Id_29 29
#define SubmitChangePassword_ServiceId_32 32
//For DE3981//JUHI
#define ExternalUserErrorMessage @"You don't have permission to use the Replicon Mobile app."

/////////////////////////////////////////////////
//           SupportingData                   //
/////////////////////////////////////////////////
#define CheckUserPermissions_ServiceID_2 2
#define UserActivities_Service_Id_47 47
#define BillingOptions_Serice_Id_48 48
#define TimesheetEntry_CellLevel @"TimesheetEntry"
#define TaskTimesheet_RowLevel @"TaskTimesheet"
#define ReportPeriod_SheetLevel @"ReportPeriod"
#define TimeOffs_SheetLevel @"TimeOffs"

#define TimesheetEntry_CellLevel_Udf @"TimesheetEntryUDF"
#define TaskTimesheet_RowLevel_Udf @"ReportPeriodUDF"
#define ReportPeriod_SheetLevel_Udf @"TimeOffUDF"


#define USER_PERMISSIONS_RECEIVED_NOTIFICATION @"User Permissions"
#define USER_PREFERENCES_RECEIVED_NOTIFICATION @"User Preferences"
#define SYSTEM_PREFERENCES_RECEIVED_NOTIFICATION @"System Preferences"

//////////////////////////////////////////////////
//			SyncExpenses		//
/////////////////////////////////////////////////

#define EditExpenseEntries_Service_Id 33
#define SyncOfflineCreatedEntries_ServiceId_34 34
#define SyncOfflineCreatedSheet_Service_Id 37

//////////////////////////////////////////////////
//			ChangePasswordViewController		//
/////////////////////////////////////////////////

#define ChangePasswordTitle @"Change Password"

#define ObjectNotFoundException @"Replicon.RemoteApi.Core.ObjectNotFoundException"
#define ObjectNotFoundMessage @"An item you modified or selected was deleted by another user.\n\nPlease log out and log in again to refresh the data in the mobile app."

#define ORMSecurityException @"Replicon.Data.Orm.Security"
#define ORMValidationException @"Replicon.Util.Validation.ValidationException"
//#define ORMSecurityExceptionMessage @"Your Replicon permissions have been changed.\n\nPlease log out and log in again to refresh the permissions in the mobile app." 
#define ORMSecurityExceptionMessage @"Sorry, there seems to be a technical problem. We've noted your issue and are working hard to resolve it."
//US3634//Juhi
#define ORMSecurityExceptionStopWatchMessage @"This entry cannot be edited because the stopwatch is running in Replicon."//US4337//Juhi
#define ORMValidationExceptionApprovals @"There is a technical problem preventing the selected timesheet(s) from being approved or rejected in the mobile app. We're working hard to resolve the issue. In the meantime, please log in to Replicon on your computer's browser to approve the timesheet(s)."

/////////////////////////////////////////////////
//     ListOfExpenseEntriesViewController     //
/////////////////////////////////////////////////

#define ExpenseReceiptImage_Service_Id_35 35
#define LARGE_RECEIPT_IMAGE_MEMORY_WARNING @"This receipt is too large to download or the connection speed is too slow. \n \nPlease log in to Replicon on a PC to view the receipt"//US4337//Juhi
/////////////////////////////////////////////////
//     AddNewExpenseSheetViewController        //
/////////////////////////////////////////////////
#define NewExpenseSheet @"New Expense Sheet         "

/////////////////////////////////////////////////
//     AddNewExpenseEntryViewController        //
/////////////////////////////////////////////////
#define EntryExpense @"View Expense Entry"//Edit Expense
#define ADD_EXPENSE_TITLE @"Add Expense Entry"

/////////////////////////////////////////////////
//     EditExpenseEntryViewController        //
/////////////////////////////////////////////////
#define EditExpense @"Edit Expense Entry"

/////////////////////////////////////////////////
//     ListOfTimeSheetsViewController       //
/////////////////////////////////////////////////
#define FetchNextRecentTimeSheets_46 46
#define MSG_SELECT_PROJ @"Please select a project first"
#define Each_Cell_Row_Height_80 80 
#define Each_Cell_Row_Height_58 58 
#define Each_Cell_Row_Height_44 44
#define DeleteExpenseSheetText @"Delete Expense Sheet"
//#define ReimburseText @"Reimbursement....."
#define ReimburseText @"Reimbursement"
//#define TotalText @"Total....."
#define TotalText @"Total"
#define MoreText @"More"
#define TimeEntryBackButtonTitle @"Timesheets"
#define TimeEntryNavTitle @"Timesheet"
#define TimeEntryResubmitNavTitle @"Resubmit"
#define TimeEntryReopenNavTitle @"Reopen"//US4754
#define AddFirstEntryButtonTitle @"Add First Time Entry"
#define G2TotalString @"TOTAL"
#define SubmitTimeSheetButtonTitle @"Submit Timesheet"
#define YouCannotSubmitTimesheetWhileOffline @"You cannot submit timesheet while offline."
#define YouCannotUnSubmitTimesheetWhileOffline @"You cannot Unsubmit timesheet while offline."
#define YouCannotReSubmitTimesheetWhileOffline @"You cannot resubmit timesheet while offline."
#define ResubmitTimesheet @"Resubmit"
#define PleaseIndicateReasonsforResubmittingThisTimesheet @"Please indicate a reason for resubmitting this timesheet"

#define PleaseIndicateReasonsforResubmittingThisExpense @"Please indicate a reason for resubmitting this expense"
#define PleaseIndicateReasonsforReopeningThisTimesheet @"Please indicate a reason for reopening this timesheet"//US4754
#define BACK @"Back"
//US4275//Juhi
#define Comments @"Comments"
#define timesheetForApproval @"timesheet for approval?"
#define ExpenseForApproval @"expense for approval?"
/////////////////////////////////////////////////
//     ListOfTimeEntriesViewController        //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//     AddNewTimeEntryViewController        //
/////////////////////////////////////////////////
#define TimeEntryTopTitle @"View Time Entry"
#define SameAsPreviousEntryButtonTitle @"Same As Previous Entry"
#define EnterUnbookedTimeOffButtonTitle @"Enter Unbooked Time Off"
#define ClientProjectTask @"Project/Task"
#define Billing  @"Billing"
#define TimeEntryActivity @"Activity"
#define TimeHeaderTitle @"Time"
#define TimeEntryProjectInfo @"Detail"
#define TimeEntryComments @"Comments"
#define TypeFieldName @"Type"
#define DateFieldName @"Date"
#define TimeFieldName @"Time"
#define HoursFieldName @"Hours"
#define TimeInFieldName @"Time In"
#define TimeOutFieldName @"Time Out"
#define HoursFieldName @"Hours"
#define TimeEntryProject @"Project"
#define TimeEntryClient @"Client"
#define CANNOT_EDIT_TIME_SHEET @"Cannot edit a TimeSheet object unless it is Open or Rejected"
#define MESSAGE @"Message"
#define OFFLINE_CREATE_STATUS @"create"
#define OFFLINE_edit_STATUS @"edit"
#define INVALID_NEGATIVE_NUMBER_ERROR @"Invalid value.Please edit the value"
#define DescriptoinError @"Please provide a description"

/////////////////////////////////////////////////
//     ClientProjectViewController        //
/////////////////////////////////////////////////
#define ClientProject @"Project"
#define Task @"Task"
#define TaskHierarchySeparator @"/"
/////////////////////////////////////////////////
//     TaskViewController        //
/////////////////////////////////////////////////
#define TaskViewTitle @"Task"

/////////////////////////////////////////////////
//   AdhocTimeOffViewController               //
/////////////////////////////////////////////////
#define AdhocTimeOFfEntryName @"Time Off Entry"

/////////////////////////////////////////////////
//     SubmissionErrorViewController        //
/////////////////////////////////////////////////
#define TheFollowingTimeEntriesareMissingRequiredFields @"The following time entries are missing required fields:"



#define ClientProjectPicker @"client//projectPicker"
#define ExpenseTypePicker @"ExpenseTypePicker"
#define AddAmountScreen @"AddAmountScreen"
#define DatePicker @"datePicker"
#define AddDescriptionScreen @"AddDescriptionScreen"
#define BillClientCheckMark @"BillClientCheckMark"
#define AddReceiptPhotoScreen @"AddReceiptPhotoScreen"
#define ReimburseCheckMark @"ReimburseCheckMark"
#define PaymentMethodPicker @"PaymentMethodPicker"
#define AddUDF @"AddUDF"
#define UDFType_TEXT @"Text"
#define UDFType_NUMERIC @"Numeric"
#define UDFType_DATE @"Date"
#define UDFType_DROPDOWN @"DropDown"


#define DATA_PICKER @"DataPicker"
#define DATE_PICKER @"DatePicker"
#define TIME_PICKER @"TimePicker"
#define DATE_PICKER_TAG 3000
#define CHECK_MARK  @"CheckMark"
#define NUMERIC_KEY_PAD @"NumericKeyPad"
#define MOVE_TO_NEXT_SCREEN @"MoveToNextScreen"
#define IMAGE_PICKER  @"ImagePicker"


#define OK_BTN_TITLE @"OK"
#define CANCEL_BTN_TITLE @"Cancel"
#define G2SAVE_BTN_TITLE @"Save"
#define Sign_Up_BTN_TITLE @"Sign Up"
#define TAKE_PHOTO_BTN_TITLE @"Take photo"
#define CHOOSE_FROM_LIB_BTN_TITLE @"Choose from library"
#define CLOSE_BTN_TITLE @"Close"
#define GoToWebTitle @"Go To Website"
#define TrialProductErrorMessage @"Please visit Replicon through a browser to select your trial options.\n\nOnce complete, you can use Replicon Mobile to access your trial."//US4337//Juhi

/////////////////////////////////////////////////
//     URLReader        //
/////////////////////////////////////////////////
#define Request_TimeoutInterval 120

#define DeviceModelToCall						@"iPhone"
#define SimulatorDeviceModel					@"iPhone Simulator"

// TIMESHEET QUERIES
#define EntryTimesheetByUser_38 38
#define QueryAndCreateTimesheet_41 41
#define UserProjectsAndClients_42 42
#define SubmitTimesheet_Service_Id_43 43
#define GetTimesheetWithIdentity_Service_Id_44 44
#define UnsubmitTimesheet_Service_Id_45 45
#define TimesheetApprovalHistory_Service_id_49 49
#define TimesheetUDFs_Service_id_51 51
#define TimesheetProjectTasks_Service_Id_52 52
#define TimesheetProjectSubTasks_Service_Id_53 53
#define SaveTimeEntryForSheet_Service_Id_54 54
#define GetTimesheetForIdWithEntries_Service_Id_55 55
#define EditTimeEntry_Service_Id_56 56
#define SyncOfflineCreatedTimeEntries_Service_Id_57 57
#define SyncOfflineEditedTimeEntries_Service_Id_58 58
#define SyncOfflineDeletedTimeEntries_Service_Id_59 59
#define ExpenseSheetsModifiedFromLastUpdatedTime_Service_Id_60 60
#define DeleteTimeEntry_Service_Id_62 62
#define ModifiedTimesheets_Service_Id_63 63
#define EditTimesheetEntryForNewInOut_Service_Id_90 90
#define ReopenTimesheet_Service_Id_92 92//US4660//Juhi
#define UserIntegrationDetails_Service_ID_103 103


#define ADD_TIME_ENTRY  0
#define EDIT_TIME_ENTRY 1
#define VIEW_TIME_ENTRY 2

#define TIMESHEET_FETCH_START_INDEX @"nextTimesheetStartIndex"
#define TIMESHEETS_RECEIVED_NOTIFICATION @"TIMESHEETS_RECEIVED"
#define NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION @"Next_Recent_Time_Sheets_Received"
#define USER_PROJECTS_RECEIVED_NOTIFICATION @"USER PROJECTS RECEIVED"
#define TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION @"TIMESHEET SUBMIT SUCCESS"
#define TIMESHEET_SUBMIT_ERRORS_NOTIFICATION @"TIMESHEET SUBMIT ERRORS"
#define APPROVAL_HISTORY_NOTIFICATION @"APPROVAL_HISTORY_RECEIVED"
#define USER_ACTIVITIES_RECEIVED_NOTIFICATION @"ACTIVITIES RECEIVED"
#define PROJECTS_BILLINGOPTIONS_RECEIVED_NOTIFICATION @"PROJECTS BILLINGOPTIONS RECEIVED"
#define TIMESHEET_UDFs_RECEIVED_NOTIFICATION @"Time Sheet Udfs Received"
#define FETCH_TIMESHEET_FOR_ENTRY_DATE @"Fetched Timesheet for Entrydate"
#define FETCH_LOCKEDINOUT_TIMESHEET_FOR_ENTRY_DATE @"Fetched Timesheet for LOCKEDINOUT Entrydate"
#define TASKS_RECEIVED_NOTIFICATION @"Project_Tasks_Received"
#define SUB_TASKS_RECEIVED_NOTIFICATION @"Sub_Tasks_Received"
#define TIMESHEET_DATA_RECEIVED @"Timesheet Data received"
#define TIME_ENTRY_DELETE_NOTIFICATION @"Timeentry Deleted"
#define TIMESHEET_TIMEENTRY_TYPE @"timeEntry"
#define TIMESHEET_TIMEOFF_TYPE @"timeOff"
#define TIMESHEET_SHEET_LEVEL_UDF_KEY @"TimesheetLevel"
#define TIMESHEET_ROW_LEVEL_UDF_KEY @"TimesheetRowLevel"
#define TIMESHEET_CELL_LEVEL_UDF_KEY @"TimesheetCellLevel"
#define SHEET_UDF_ERROR_HEADER @"is a required field but is not accessible through Replicon Mobile."
#define TIMESHHET_UDF_ERROR_MESSAGE @"Please log in to Replicon through your browser to set this field and submit the timesheet."//US4337//Juhi
#define YouCannotEnterTimeBecauseNoProjectsAreAssignedToYou @"You cannot enter time because no projects are assigned to you."
#define YouCannotEnterTimeBecauseNoActivitiesAreAssignedToYou @"You cannot enter time because no activities are assigned to you."
#define TASK_NON_BILLABLE @"AllowNonBillable"
#define TASK_BILLABLE @"AllowBillable"
#define TASK_BILLABLE_BOTH @"AllowBoth"
#define TASKS_FETCH_COUNT 100
#define NO_TASKS_MESSAGE @"There are no tasks in this project."
#define NO_CHILD_TASKS_FOUND_MESSAGE @"There are no child tasks for the task."
#define TASK_FIRST_TIME_VIEWED @"TaskFirstTimeViewed"
#define TIME_ENTRY_SAVED_NOTIFICATION @"Time_Entry_Saved"
#define FETCH_TIMESHEET_BY_IDENTITY @"Timesheet fetched by Identity"
#define BILLING_BILLABLE @"Billable"
#define BILLING_NONBILLABLE @"NonBillable"
#define ACTIVITIES_DEFAULT_NONE @"None"
#define ACTIVITIES_DEFAULT_SELECT @"Select"
#define TIME_IN_OUT_DEFAULT_SELECT @"Select"
#define BILLING_PROJECT_RATE @"ProjectRate"
#define BILLING_USER_RATE @"UserOverrideRate"
#define BILLING_ROLE_RATE @"RoleRate"
#define BILLING_DEPARTMENT_RATE @"DepartmentOverrideRate"
#define TIME_ENTRY_EDITED_NOTIFICATION @"Time Entry Edited"
#define TASK_VIEW_MESSAGE_TITLE [NSString stringWithFormat:@"%@\n%@",@"Tap task name to select the task.",@"Tap arrow to view sub-tasks."]
#define TASK_VIEW_MESSAGE @"Tasks in grey can't be selected for time entry."

#define CONFIRM_DEL_RECEIPT_MSG @"Permanently delete photo receipt?"
#define EDITED_TIMEENTRY_SYNCED_NOTIFICATION @"Sync_Offline_Edited_Time_Entry"
#define BOOKED_TIME_OFF_ENTRY_RECEIVED_NOTIFICATION @"Booked Time Off Entries Received Notification"
#define TIMESHEET_BOOKED_TIMEOFF @"bookedtimeOff"
#define Classic_Type_TimeSheet @"Classic"
#define InOut_Type_TimeSheet @"InOut"
#define Classic2_Type_TimeSheet @"Classic2"
#define New_InOut_Type_TimeSheet @"NewInOut"


#define Flat_WithOut_Taxes  @"FlatWithOutTaxes"
#define Flat_With_Taxes  @"FlatWithTaxes"
#define Rated_WithOut_Taxes  @"RatedWithOutTaxes"
#define Rated_With_Taxes  @"RatedWithTaxes"
//#define Force_Password_Alert_Message [NSString stringWithFormat:@"%@\n\n%@",@"You must change your password before using Replicon Mobile.",@"Please log in to Replicon in a browser to change the password."]
#define Force_Password_Alert_Message @"You must change your password before using Replicon Mobile.\n\nPlease log in to Replicon in a browser to change the password."//DE2215//JUHI//US4337//Juhi


//DEFAULT CONSTANTS

#define TYPE_DEFAULT @"Select"

//General Constants

#define UNSUBMITTED_EXPENSE_SHEETS @"unsubmitted_expense_sheets"
#define UNSUBMITTED_TIME_SHEETS @"unsubmitted_time_sheets"

#define RESET_PASSWORD_TITLE @"Reset Password"
#define PASSWORD_RESET_TITLE @"Password Reset"
#define RESET @"Reset"
#define Enter_Company_Message @"Please enter your Company"
#define Enter_Email_Message @"Please enter your Email Address"
#define ResetPassword_Service_Id_67 67

//Email Constants

#define G2EMAIL_SUBJECT @"Feedback for Replicon Mobile v"
#define RECIPENT_ADDRESS @"iphonefeedback@replicon.com"
#define COMPANY_NAME @"Company"
//AutoLogging Error Messages

//#define AUTOLOGGING_ERROR_TITLE @"Error" 
#define AUTOLOGGING_ERROR_TITLE @"" //DE1231//Juhi
#define G2PASSWORD_EXPIRED @"Your password has been changed since you last logged in.  Please log in using your new password."
#define SESSION_EXPIRED  @"Your session has expired.  Please log in again." 

//Locked IN OUT CONSTANTS

#define PUNCHIN @"Punch In"
#define PUNCHOUT @"Punch Out"
#define REFRESH_PUNCH_DETAILS @"refreshPunchDetails"
#define PUNCHINSTATUS @"PUNCH IN:"
#define PUNCHOUTSTATUS @"PUNCH OUT:"
#define OFFCLOCK @"OFF CLOCK:"
#define ONCLOCK @"ON CLOCK:"
#define AUTO_SYNC_PUNCH_STATUS 3600
#define PUNCHCLOCK_ERROR_ALERT @"The timesheet has been modified since your last action.  The app is now up to date.  Please try punching in/out again."
#define LOCKED_TIME_ENTRY_SAVED_NOTIFICATION @"Locked_Time_Entry_Saved"
#define LOCKED_TIME_ENTRY_EDITED_NOTIFICATION @"Locked_Time_Entry_Edited"
#define LOCATION_SERVICES_ENABLED  @"Enabled"
#define LOCATION_SERVICES_DISABLED @"Disabled"
#define PUNCHCLOCK_NOENTRIES_APPROVAL_STATUS @"PUNCHCLOCK_NOENTRIES_APPROVAL_STATUS"
//US4660//Juhi
#define PunchInMessage  @"Please unsubmit or reopen your timesheet in order to punch in"
#define PunchOutMessage @"Please unsubmit or reopen your timesheet in order to punch out"

//INTERNATIONALIZATION

#define LANGUAGE_SET_MSG1 @"Your Replicon language preference is set to"//US4337//Juhi
#define LANGUAGE_SET_MSG2 @"To enable this language on mobile, please quit and restart the app."
#define LANGUAGE_SET_BUTTON1_TITLE @"Close Later"
#define LANGUAGE_SET_BUTTON2_TITLE @"Close Now"

//APPROVALS

#define PENDING_APPROVALS @"Pending Approvals"
#define OVERDUE_TIMESHEETS @"Overdue Timesheets"
#define PREVIOUS_APPROVALS @"Previous Approvals"
#define PENDING_TIMESHEETS @"Pending Timesheets"
#define PENDING_EXPENSES @"Pending Expenses"

#define G2APPROVE_PRESSED_IMG @"G2approve_btn_pressed.png"
#define G2APPROVE_UNPRESSED_IMG @"G2approve_btn_unpressed.png"
#define G2REJECT_PRESSED_IMG @"G2reject_btn_pressed.png"
#define G2REJECT_UNPRESSED_IMG @"G2reject_btn_unpressed.png"
#define REMINDER_PRESSED_IMG @"G2reminder_btn_pressed.png"
#define REMINDER_UNPRESSED_IMG @"G2reminder_btn_unpressed.png"

#define SEND_REMINDER_TEXT @"Send Reminder"
#define APPROVE_TEXT @"Approve"
#define REJECT_TEXT @"Reject"
#define REOPEN_TEXT @"Reopen"

#define REJECT_CONTENTBAR_TEXT @"Rejected Timesheets"
#define APPROVE_CONTENTBAR_TEXT @"Approved Timesheets"
#define REJECT_CONTENTBAR_EXPENSES_TEXT @"Rejected Expenses"
#define APPROVE_CONTENTBAR_EXPENSES_TEXT @"Approved Expenses"

#define EXPENSE_SHEETS_TITLE   @"Expense Sheets"

#define APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION @"allApprovalTimesheetRequestsServed"
#define CHECK_ALL_BUTTON_TAG 400
#define CLEAR_ALL_BUTTON_TAG 401

// APPROVALS QUERIES
#define FetchPendingApprovalCountByApprover_69 69
#define FetchAllPendingAprrovalsByApprover_70  70
#define Approvals_BookedTimeOff_Service_Id_71 71
#define ModifiedTimesheets_Service_Id_72  72
#define Approvals_TimeSheetsExisted_Service_Id_73 73
#define Approvals_UserActivities_Service_Id_74 74
#define Approvals_TimesheetUDFs_Service_id_75 75
#define Approvals_UserProjectsAndClients_76 76
#define Approvals_CheckUserPermissions_ServiceID_77 77
#define Approvals_GetUserPreferences_78 78
#define Approvals_FetchAllPendingAprrovalsTimesheetsEntriesByApprover_79 79
#define Approvals_Approve_80 80
#define Approvals_Reject_81 81
#define Approvals_UserByLoginName_1 1
#define ApprovalsFetchTimesheetByID_82 82


#define ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION @"ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION"
#define APPROVAL_TIMESHEET_TYPE_STANDARD @"STANDARD"
#define APPROVAL_TIMESHEET_TYPE_INOUT @"INOUT"
#define APPROVAL_TIMESHEET_TYPE_LOCKEDINOUT @"LOCKEDINOUT"
#define APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG @"Are you sure you want to approve %d timesheets?"
#define APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG  @"Are you sure you want to reject %d timesheets?"
#define APPROVAL_TIMESHEET_REJECT_COMMNETS_MSG @"You must enter comments when rejecting timesheets."
#define APPROVAL_TIMESHEET_VALIDATION_MSG @"Please select a timesheet for approval or rejection."
#define YES_BTN_TITLE @"Yes"
#define NO_BTN_TITLE  @"No"
#define APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION @"APPROVAL_REJECT_DONE"
#define APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG1 @"Are you sure you want to approve"
#define APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG2 @"timesheet?"
#define APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG1 @"Are you sure you want to reject"
#define APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG2 @"timesheet?"
#define APPROVAL_TIMESHEET_REJECTION_VALIDATION @"You must enter comments when rejecting a timesheet."
#define APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION @"APPROVAL_COUNT"
#define APPDELEGATE_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION @"APPDELEGATE_APPROVAL_COUNT"
#define APPROVAL_NO_TIMESHEETS_PENDING_VALIDATION @"All timesheets approved\nNone pending"
#define APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL @"This timesheet is deleted and no longer waiting for approval"//DE5784
#define G2APPROVAL_TIMESHEET_NOT_WAITINGFORAPPROVAL @"This timesheet is no longer waiting for approval"

#define APPROVAL_CHECK_ALL_TITLE @"Check All"
#define APPROVAL_CLEAR_ALL_TITLE @"Clear All"

//ATTESTATION

#define ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG1 @"Please read and accept the"
#define ATTESTATION_SUBMIT_RESUMBIT_VALIDATION_MSG2 @"to continue."

#define TIMESHEET_DISCLAIMER_UPDATED_SUCCESS_NOTIFICATION @"DISCLAIMER_UPDATED_SUCCESS"

#define GetDisclaimerPreferences_83 83
#define UpdateDisclaimerAcceptedDateForTimesheets_Service_Id_84 84



// SSO

#define WELCOME_MESSAGE_1 @"Welcome to Replicon Mobile!"
#define WELCOME_MESSAGE_2 @"Enter your company and user name to get started."
#define COMPANY_NAME_TEXT_PLACEHOLDER @"Company"

#define GO_BTN_TITLE @"Go"

#define FetchAuthRemoteAPIUrl_Service_Id_91 91
#define FetchNewAuthRemoteAPIURL_Service_Id_104 104
#define CompleteSAMLFlowRemoteAPIURL_Service_Id_105 105


#define AUTHENTICATION_REQUIRED_MESSAGE @"Authentication Required"
#define SUBMIT_BTN_MSG @"Submit"
#define USERNAME_MSG @"User Name"
#define PASSWORD_MSG @"Password"
#define OVERLAY_MSG @"You may briefly experience a blank screen during the authentication process."

#define SAML_SESSION_TIMEOUT_TAG -9998



//AD HOC TIME OFF

#define NEW_TIME_ENTRY_TEXT @"Time Entry"
#define ADHOC_TIME_OFF_TEXT @"Time Off Entry"

#define ADD_ADHOC_TIMEOFF  3
#define EDIT_ADHOC_TIMEOFF 4
#define VIEW_ADHOC_TIMEOFF 5

#define TimeOffTypeFieldName @"Time Off Type"
#define EditTimeOffTitle @"Edit Time Off Entry"
#define ViewTimeOffTitle @"View Time Off Entry"
#define AddTimeOffTitle @"Add Time Off Entry"

#define QueryAndCreateTimeOff_85 85
#define SaveTimeOffEntryForSheet_86 86
#define FETCH_TIMEOFF_FOR_ENTRY_DATE @"Fetched Timeoff for Entrydate"
#define TIMEOFF_ENTRY_SAVED_NOTIFICATION @"TimeOff_Entry_Saved"
#define EditTimeOffEntry_Service_Id_87 87
#define DeleteTimeOffEntry_Service_Id_88 88
#define TIMEOFF_ENTRY_EDITED_NOTIFICATION @"TIMEOFF_ENTRY_EDITED_NOTIFICATION"
#define TIMEOFF_ENTRY_DELETE_NOTIFICATION @"TimeOffEntryDeleted"
#define DELETE_TIMEOFF_MSG @"Permanently delete time off entry?"
#define GetTimeOffCodess_ServiceID_89 89

#define WORK_VAUE @"Work"



#define VALIDATION_TIMEOFF_TYPE_REQUIRED   @"Please select a time off type."
#define USER_TIME_OFF_CODES_RECEIVED_NOTIFICATION @"Time Off Codes Received"

//MEAL BREAKS

#define Meal @"Meal"
#define Off @"Off"
#define OT @"OT"
#define Reg @"Reg"


//REVIEW APP

#define REVIEW_APP_MSG  @"Thank you! Your review will help us improve the app."
#define REVIEW_APP_NO_OPTION  @"No Thanks"
#define REVIEW_APP_YES_OPTION @"App Store"


//PAGINATION

#define CLIENT @"Client"
#define CHOOSE_CLIENT @"Choose Client"
#define CHOOSE_PROJECT @"Choose Project"
#define NO_PROJECT_MSG @"No projects available for selected client"
#define FILTER_CLIENT @"Filter Clients..."
#define FILTER_PROJECT @"Filter Projects..."

#define ExpenseTypesByID_94 94

#define PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING  @"PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING"
#define EXPENSETYPES_FINSIHED_DOWNLOADING  @"EXPENSETYPES_FINSIHED_DOWNLOADING"
#define CLIENT_VALIDATION_NO_PROJECT_SELECTED   @"Please select a project for the client or change the client selection to 'NONE'"
#define IS_NO_MORE_PROJECTS_AVAILABLE_KEY @"IS_NO_MORE_PROJECTS_AVAILABLE_KEY"

#define NO_RESULTS_MSG @"No Results"

#define RECENT_TOGGLE_TEXT @"Recent"
#define ALL_TOGGLE_TEXT    @"All"

#define FetchAllTimesheetClients_96 96
#define FetchAllTimesheetProjects_97 97
#define FetchAllTimesheetUserBillingOptionsByProjectID_98 98
#define FetchAllTimesheetProjectsByIds_99 99

#define TIMESHEETSCLIENTS_FINSIHED_DOWNLOADING @"TIMESHEETSCLIENTS_FINSIHED_DOWNLOADING"
#define TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING @"TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING"
#define TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING @"TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING"
#define TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING @"TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING"


#define CURRENTGEN_NOTIFICATION @"CURRENTGEN_NOTIFICATION"
#define NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION @"NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION"


//MERGING EXPENSES API

#define MergedExpensesAPI_95 95

//MERGING TIMESHEETS API

#define MergedTimesheetsAPI_100 100

//MERGED LOGIN API

#define MergedLogin_Service_Id_93 93

//New Billing NonBillabe//DE10367
#define NONBILLIABLE @"Non Billable"

//MERGED APPROVAL API
#define AprrovalsMergedAPI_101  101
#define AprrovalsFetchNextRecentTimesheets_102  102
#define Approval_sheetLevelUDF_identifier @"sheetLevelUDF"
#define Approval_rowLevelUDF_identifier @"rowLevelUDF"
#define Approval_cellLevelUDF_identifier @"cellLevelUDF"
#define Approval_timeoffLevelUDF_identifier @"timeoffLevelUDF"
#define Approval_Permissions_identifier @"Permissions"
#define Approval_Preferences_identifier @"Preferences"
#define Approval_PendingTimesheet_identifier @"PendingTimesheet"
#define APPROVAL_QUERY_HANDLE @"ApprovalQueryHandle"
#define APPROVAL_TIMESHEET_FETCH_START_INDEX @"nextApprovalTimesheetStartIndex"
#define APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT @"LastApprovalDownloadedTimesheetsCount"
#define APPROVAL_RECENT_DOWNLOADED_TIMESHEETS_COUNT @"RecentApprovalDownloadedTimesheetsCount"

//APP COMPATIBILITY
#define Incompatible_App_Msg @"Your company is subscribed to a Replicon product that this app does not support. Please get the right app to continue."
#define Incompatible_App_Title @"Incompatible App"
#define Incompatible_App_Later @"Later"
#define Incompatible_App_Get_App @"Get App"
#define GEN3_LAUNCH_APP_MSG @"Please re-launch the Replicon app to login to the latest Replicon Platform."

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


