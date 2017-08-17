/*
 *  Constants.h
 *  SweetDeals
 *
 *  Created by Sasikant on 19/09/09.
 *  Copyright 2009 Enlume. All rights reserved.
 *
 */

#import "FileNameConstants.h"
#import "Dimensions-iPhone.h"
#import "Fonts-iPhone.h"
#import "ImageNameConstants.h"
#import "Colors-iPhone.h"
#import "Enum.h"
#import <Crashlytics/Crashlytics.h>


#define ERROR_BANNER_TAG 62345

#define TOOL_BAR_HEIGHT 44
#define PICKER_HEIGHT 216
#define KEYBOARD_HEIGHT 216
#define NAVIGATION_BAR_HEIGHT 64

#define ERRORS_AND_WARNINGS_WIDGET @"ERRORS_AND_WARNINGS_WIDGET"
#define TIMESHEET_STATUS_WIDGET @"TIMESHEET_STATUS_WIDGET"
#define IN_OUT_TIMESHEET_WIDGET @"IN_OUT_TIMESHEET_WIDGET"
#define EXT_IN_OUT_TIMESHEET_WIDGET @"EXT_IN_OUT_TIMESHEET_WIDGET"
#define TIME_PUNCHES_WIDGET @"TIME_PUNCHES_WIDGET"
#define TIME_SHEET_WIDGET @"TIME_SHEET_WIDGET"
#define TIME_ENTRIES_WIDGET @"SUBMIT_BUTTON_WIDGET"
#define EXPENSES_WIDGET @"SUBMIT_BUTTON_WIDGET"
#define TIME_OFF_WIDGET @"TIME_OFF_WIDGET"
#define SHEET_UDF_WIDGET @"SHEET_UDF_WIDGET"
#define CHANGE_HISTORY_WIDGET @"CHANGE_HISTORY_WIDGET"
#define ADD_COMMENTS_APPROVE_REJECT_WIDGET @"ADD_COMMENTS_APPROVE_REJECT_WIDGET"
#define ATTESTATION_WIDGET @"ATTESTATION_WIDGET"
#define SUBMIT_BUTTON_WIDGET @"SUBMIT_BUTTON_WIDGET"
#define NOTICE_WIDGET @"NOTICE_WIDGET"


//NSNotification Keys
#define APPROVAL_COUNT_NOTIFICATION @"approverCountRequestServed"
#define PREVIOUS_APPROVALS_NOTIFICATION @"previous_approvals"
#define APPROVAL_REJECT_DONE_NOTIFICATION @"Approve_reject_notification"

#define PENDING_APPROVALS_TIMESHEET_NOTIFICATION @"pending_timesheet_approvals"
#define PENDING_APPROVALS_EXPENSE_NOTIFICATION @"pending_expense_approvals"
#define PENDING_APPROVALS_TIMEOFF_NOTIFICATION @"pending_timeoff_approvals"
#define PENDING_APPROVALS_NOTIFICATION @"PENDING_APPROVALS_NOTIFICATION"
//Company View Controller

#define WELCOME_MESSAGE_1 @"Welcome to Replicon Mobile!"
#define WELCOME_MESSAGE_2 @"Enter your company and user name to get started."
#define SignIn @"Sign In"
#define SigningIn @"Signing In"
#define InvaliDLogin @"Incorrect Login or Password"
#define InvalidUserName @"Incorrect User Name"
#define InvalidCompanyName @"Unknown Company.  Please check that it was entered correctly."
#define InvaliDLoginName @"Please enter your User Name."
#define UserNameValidationMessage @"Please enter your Company."
#define GO_BTN_TITLE @"Go"
#define LOGIN_CELL_ROW_HEIGHT 44
#define SESSION_EXPIRED  @"Your session has expired.  Please log in again."
#define LoginValidationErrorMessage @"Please complete all fields"
#define Incompatible_App_Msg @"Your company is subscribed to a Replicon product that this app does not support. Please get the right app to continue."
#define Incompatible_App_Title @"Incompatible App"
#define Incompatible_App_Later @"Later"
#define Incompatible_App_Get_App @"Get App"
#define New_App_Available_Title @"New Version Available"
#define New_App_Available_Message @"App update available. Would you like to update now?"
#define New_App_Required_Message @"App update required."
#define Update_App @"Update Now"
#define GEN2_LAUNCH_APP_MSG @"Your company is using an older version of the Replicon Platform (Gen2). Please re-launch the Replicon app to login to the older Replicon Platform."

//HOME VIEW CONTROLLER

#define ExpenseLabelText @"Expenses"
#define TimeSheetLabelText @"Timesheets"
#define TimeoffLabelText  @"Time Off"
#define MoreLabelText     @"Settings"
#define ApprovalsLabelText @"Approvals"
#define COPYRIGHT_TEXT @"© 2013 Replicon Inc."

//ROOT TAB BAR CONTROLLER

#define PunchClockTabbarTitle @"Clock"
#define ExpenseTabbarTitle @"Expenses"
#define ApprovalsTabbarTitle @"Approvals"
#define DashboardTabbarTitle @"Dashboard"
#define MoreTabbarTitle @"Settings"
#define TimeSheetsTabbarTitle @"Timesheets"
#define BookedTimeOffTabbarTitle @"Time Off"
#define TrackTimeTitle @"Track Time"
#define TrackingTimeTitle @"Tracking Time..."
#define OnBreakTitle @"On Break"
#define ShiftsTabbarTitle @"Schedule"
#define AttendanceTabbarTitle @"Clock In or Out"
#define PunchLocatioTabbarTitle @"Punch Location"
#define TeamTimeTabbarTitle @"Time Punches"
#define PunchHistoryTabbarTitle @"Punch History"
#define TimeSheetChangeHistoryTabbarTitle @"Timesheet Change History"

#define FreeTrialTabbarTitle @"Create Free Trial"
#define TermsOfServiceTabbarTitle @"Terms Of Service"

#define AuditTrialTitle @"Audit Trail"
#define AuditHistoryTitle @"Audit History"
//SAML WEB VIEW CONTROLLER
#define AUTHENTICATION_REQUIRED_MESSAGE @"Authentication Required"
#define SUBMIT_BTN_MSG @"Submit"
#define USERNAME_MSG @"User Name"
#define PASSWORD_MSG @"Password"
#define OVERLAY_MSG @"You may briefly experience a blank screen during the authentication process."

//SERVICE ID'S

#define UserIntegrationDetails_Service_ID_0 0
#define UserIntegrationDetailsiOS7_Service_ID_89 89
#define HomeSummaryDetails_Service_ID_1 1
#define TimesheetDetails_Service_ID_2 2
#define NextRecentTimesheetDetails_Service_ID_3 3
#define TimesheetSummaryDetails_Service_ID_4 4
#define EnabledTimeoffTypes_Service_ID_5 5
#define ApprovalsCountDetails_Service_ID_6 6
#define PendingApprovalsTimesheetSummaryDetails_Service_ID_7 7
#define PreviousApprovalsTimeSheetSummaryDetails_Service_ID_8 8
#define BulkApproveForApprovalTimesheets_Service_ID_9 9
#define BulkRejectForApprovalTimesheets_Service_ID_10 10
#define NextRecentPendingTimesheetApprovalsSummaryDetails_Service_ID_11 11
#define NextRecentPreviousApprovalsTimeSheetSummaryDetails_Service_ID_12 12
#define FirstClientsAndProjectsSummaryDetails_Service_ID_13 13
#define NextClientsSummaryDetails_Service_ID_14 14
#define NextProjectsSummaryDetails_Service_ID_15 15
#define FirstTasksSummaryDetails_Service_ID_16 16
#define NextTasksBasedOnProject_Service_ID_17 17
#define GetProjectsBasedOnclient_Service_ID_18 18
#define GetNextProjectsBasedOnClients_Service_ID_19 19
#define FirstClientsSummaryDetails_Service_ID_20 20
#define FirstProjectsSummaryDetails_Service_ID_21 21
#define GetBillingData_Service_ID_22 22
#define GetNextBillingData_Service_ID_23 23
#define GetActivityData_Service_ID_24 24
#define GetNextActivityData_Service_ID_25 25
#define SaveTimesheetData_Service_ID_26 26
#define GetExpenseSheetData_Service_ID_27  27
#define GetNextExpenseSheetData_Service_ID_28 28
#define GetExpenseEntryData_Service_ID_29 29
#define GetCurrencyAndPaymentMethodData_Service_ID_30 30
#define GetFirstProjectsAndClientsForExpenseSheet_Service_ID_31 31
#define GetNextClientForExpense_Service_ID_34 34
#define GetNextProjectForExpense_Service_ID_35 35
#define GetExpenseCodesForExpenseSheet_Service_ID_36 36
#define GetProjectsBasedOnClientForExpenseSheet_Service_ID_37 37
#define GetNextProjectsBasedOnClientsForExpense_Service_ID_38 38
#define SubmitTimesheetData_Service_ID_39 39
#define UnsubmitTimesheetData_Service_ID_40 40
#define SubmitExpenseData_Service_ID_41 41
#define UnsubmitExpensData_Service_ID_42 42
#define DeleteExpenseSheet_Service_ID_44 44
#define GetExpenseCodeDetails_Service_ID_45 45
#define SaveExpenseSheet_Service_ID_47 47
#define PendingApprovalsExpenseSummaryDetails_Service_ID_48 48
#define NextRecentPendingExpenseApprovalsSummaryDetails_Service_ID_49 49
#define BulkApproveForApprovalExpenseSheets_Service_ID_50 50
#define BulkRejectForApprovalExpenseSheets_Service_ID_51 51
#define PreviousApprovalsExpenseSummaryDetails_Service_ID_52 52
#define NextRecentPreviousApprovalsExpenseSummaryDetails_Service_ID_53 53
#define GetTimeoffData_Service_ID_54 54
#define GetNextTimeoffData_Service_ID_55 55
#define GetRefreshedTimeoffData_Service_ID_56 56
#define GetCompanyHolidaysData_Service_ID_57 57
#define PendingApprovalsTimeOffsSummaryDetails_Service_ID_58 58
#define NextRecentPendingTimeOffsApprovalsSummaryDetails_Service_ID_59 59
#define BulkApproveForApprovalTimeOffs_Service_ID_60 60
#define BulkRejectForApprovalTimeOffs_Service_ID_61 61
#define PreviousApprovalsTimeOffsSummaryDetails_Service_ID_62 62
#define NextRecentPreviousApprovalsTimeOffsSummaryDetails_Service_ID_63 63
#define GetTimeoffEntryData_Service_ID_64 64
#define SaveTimeoffData_Service_ID_65 65
#define DeleteTimeoffData_Service_ID_66 66
#define GetTimeOffBalanceSummaryAfterTimeOff_Service_ID_67 67
#define GetDropDownOption_Service_ID_68 68
#define GetNextDropDownOption_Service_ID_69 69
#define User_LogOut_Service_ID_70 70
#define ResubmitTimeOffData_Service_ID_71 71
#define CurrentGenFetchRemoteApiUrl_73 73
#define GetVersionUpdateDetails_74 74
#define GetPageOfTimeOffTypesAvailableForTimeAllocationFilteredByTextSearch_75 75
#define GetApprovalPendingTimesheetSummaryDetails_Service_ID_77 77
#define ApproveForApprovalTimesheet_Service_ID_78 78
#define RejectForApprovalTimesheet_Service_ID_79 79
#define ApproveForApprovalTimeOff_Service_ID_80 80
#define RejectForApprovalTimeOff_Service_ID_81 81
#define ApproveForApprovalExpense_Service_ID_82 82
#define RejectForApprovalExpense_Service_ID_83 83
#define GetApprovalPreviousTimesheetSummaryDetails_Service_ID_84 84
#define GetApprovalPreviousExpenseEntryData_Service_ID_85 85
#define GetPreviousTimeoffEntryData_Service_ID_86 86
#define GetTimesheetUpdateData_Service_ID_87 87
#define GetExpenseSheetUpdateData_Service_ID_88 88
#define GetBreakData_Service_ID_90 90
#define GetNextBreakData_Service_ID_91 91
#define GetNextExpenseCodesForExpenseSheet_Service_ID_92 92
#define GetFirstTimesheets_ID_93 93//Implementation as per US9331//JUHI
#define PunchTime_Service_ID_94 94
#define ConcatenatePunchTime_Service_ID_95 95
#define GetShiftSummarySeries_ID_96 96
#define Attendance_PunchTime_Service_ID_97 97
#define Attendance_TransferTime_Service_ID_98 98
#define Attendance_ConcatenatePunchTime_Service_ID_100 100
#define GetFirstTeamTimeData_Service_ID_101 101
#define ResetPassword_Service_ID_103 103//Implementation For Mobi-190//Reset Password//JUHI
#define SubmitEditOrNewPunchData_Service_ID_104 104
#define DeletePunchData_Service_ID_105 105
#define GetActivitiesForUser_Service_ID_106 106
#define GetNextActivitiesForUser_Service_ID_107 107
#define ValidateEmailAddressForfreeTrial_Service_ID_110 110
#define ValidateCompanyNameForFreeTrial_Service_ID_111 111
#define SignUpForFreeTrial_Service_ID_112 112
#define UserIntegrationDetailsForFreeTrail_Service_ID_113 113
#define LastPunchData_Service_ID_130 130
#define GetTimePunchAuditDetailsForUserAndDate_Service_ID_132 132
#define GetTimePunchAuditDetailsForPunch_Service_ID_133 133
#define TimesheetsDataOnlyWhenUpdateFetchDataFails_139 139

#define TimesheetSummaryDetailsForGen4_Service_ID_114 114
//Implementation For Mobi-92//JUHI
#define GetTimesheetFormat_Service_ID_115 115
#define GetPreviousTimesheetFormat_Service_ID_116 116
#define PreviousTimesheetSummaryDetailsForGen4_Service_ID_121 121
#define SaveWorkTimeEntryForGen4_Service_ID_117 117 //Implementation For Mobi-92//ULLAS
#define SaveBreakTimeEntryForGen4_Service_ID_118 118 //Implementation For Mobi-92//ULLAS
#define DeleteWorkTimeEntryForGen4_Service_ID_119 119 //Implementation For Mobi-92//ULLAS
#define DeleteBreakTimeEntryForGen4_Service_ID_120 120 //Implementation For Mobi-92//ULLAS
#define Gen4SubmitTimesheetData_Service_ID_122 122 //Implementation For Mobi-92//ULLAS
#define Gen4UnsubmitTimesheetData_Service_ID_123 123 //Implementation For Mobi-92//ULLAS
#define GetTimesheetApprovalCapabilities_Service_ID_124 124 //Implementation For Mobi-92//ULLAS
#define GetTimesheetApprovalSummary_Service_ID_125 125 //Implementation For Mobi-92//ULLAS
#define GetPendingTimesheetApprovalCapabilities_Service_ID_126 126 //Implementation For Mobi-92//ULLAS
#define GetPreviousTimesheetApprovalCapabilities_Service_ID_127 127 //Implementation For Mobi-92//ULLAS
#define Gen4TimesheetTimeoffSummary_Service_ID_128 128
#define PreviousTimesheetTimeoffSummaryDetailsForGen4_Service_ID_129 129
#define GetTimesheetCapabilitiesForGen4_Service_ID_134 134
#define GetGen4PendingTimesheetCapabilityData_Service_ID_135 135
#define GetGen4PreviousTimesheetCapabilityData_Service_ID_136 136
#define GetGen4TimesheetValidationData_Service_ID_137 137
#define GetAllPunchTimeSegmentsForTimesheet_Service_ID_138 138
#define Gen4PendingGetPunchesForTimesheet_Service_ID_140 140
#define Gen4PreviousGetPunchesForTimesheet_Service_ID_141 141

#define ShiftFetchTimeOffList_144 144
#define GetMyNotificationSummary_148 148

#define GetUserByUserName_145 145
#define GetPolicyUriFromSlug_146 146
#define AssignPolicySetToUser_147 147

#define ContactMobileSupport_149 149

#define GetServerDownStatus_150 150
#define GetTenantFromCompanyKey_151 151
#define createPasswordResetRequest_152 152
#define FirstProgramsAndProjectsSummaryDetails_Service_ID_153 153
#define GetProjectsBasedOnPrograms_Service_ID_154 154
#define FirstProgramsSummaryDetails_Service_ID_155 155
#define NextProgramsSummaryDetails_Service_ID_156 156

#define BulkGetUserHolidaySeries_157 157

#define LightWeightHomeSummaryDetails_Service_ID_158 158

#define GetDefaultBillingData_Service_ID_159 159
#define SaveWidgetTimesheet_Service_ID_162 162
#define DeleteWidgetTimesheet_Service_ID_163 163
#define UpdateTimesheetAttestationStatus_Service_ID_164 164
#define SendPasswordResetRequestEmail_ID_170 170
#define SendPasswordResetRequestEmail_ID_170 170
#define GetOEFDropDownTagOption_Service_ID_171 171
#define GetNextOEFDropDownTagOption_Service_ID_172 172

//APPROVALS SERVICE

#define APPROVALS_PENDING_TIMESHEETS_MODULE @"APPROVALS_PENDING_TIMESHEETS_MODULE"
#define APPROVALS_PREVIOUS_TIMESHEETS_MODULE @"APPROVALS_PREVIOUS_TIMESHEETS_MODULE"
#define APPROVALS_PENDING_EXPENSES_MODULE @"APPROVALS_PENDING_EXPENSES_MODULE"
#define APPROVALS_PREVIOUS_EXPENSES_MODULE @"APPROVALS_PREVIOUS_EXPENSES_MODULE"
#define APPROVALS_PENDING_TIMEOFF_MODULE @"APPROVALS_PENDING_TIMEOFF_MODULE"
#define APPROVALS_PREVIOUS_TIMEOFF_MODULE @"APPROVALS_PREVIOUS_TIMEOFF_MODULE"
//VERSIONS
#define LATEST_VERSION  @"HANOI4"


//URL READER
#define __Response_  @"response"
#define __Unauthorized_ @"Unauthorized"
#define __NonJsonResponse @"NonJsonResponse"
#define COMPANY_NOT_EXISTS_ERROR @"urn:replicon-global:company-key-error:unknown-company"
#define USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR @"urn:replicon-saas-application:authentication-error:invalid-user-name-or-password"
#define USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_1 @"urn:replicon-saas-security:authentication-error:invalid-user-name-or-password"
#define PASSWORD_EXPIRED @"urn:replicon-saas-application:authentication-error:password-expired"
#define PASSWORD_EXPIRED1 @"urn:replicon-saas-security:authentication-error:password-expired"
#define USER_AUTHENTICATION_CHANGE_ERROR @"urn:replicon-saas-application:authentication-error:invalid-authentication-protocol"
#define USER_AUTHENTICATION_CHANGE_ERROR_1 @"urn:replicon-saas-security:authentication-error:invalid-authentication-protocol"
#define COMPANY_DISABLED_ERROR @"urn:replicon-saas-application:authentication-error:tenant-disabled"
#define COMPANY_DISABLED_ERROR_1 @"urn:replicon-saas-security:authentication-error:tenant-disabled"
#define USER_DISABLED_ERROR @"urn:replicon-saas-application:authentication-error:user-disabled"
#define USER_DISABLED_ERROR_1 @"urn:replicon-saas-security:authentication-error:user-disabled"
#define UNKNOWN_ERROR @"urn:replicon-saas-application:authentication-error:unknown-error"
#define UNKNOWN_ERROR_1 @"urn:replicon-saas-security:authentication-error:unknown-error"
#define NO_AUTH_CREDENTIALS_PROVIDED_ERROR @"urn:replicon-saas-application:authentication-error:no-authentication-credentials-provided"
#define NO_AUTH_CREDENTIALS_PROVIDED_ERROR_1 @"urn:replicon-saas-security:authentication-error:no-authentication-credentials-provided"

#define COMPANY_NOT_EXISTS_ERROR_MESSAGE @"The company name that you have entered is not recognized. Please correct and try again"
#define USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE @"Login failed. Please check your login name and password and try again"
#define USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE @"Your authentication type has been reset by your administrator. Please login again"
#define COMPANY_DISABLED_ERROR_MESSAGE @"Your company has been disabled. Please contact your administrator"
#define USER_DISABLED_ERROR_MESSAGE @"Your Replicon account has been disabled. Please contact your administrator"
#define UNKNOWN_ERROR_MESSAGE @"Sorry, something went wrong. Please try again. If the problem persists, please contact Replicon support."
#define PASSWORD_EXPIRED_MESSAGE @"You must change your password before you can proceed."
#define NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE @"Your session has timed out. Please sign in again."

//Generic Constants
#define APPROVED_STATUS @"Approved"
#define APPROVED_STATUS_URI @"urn:replicon:approval-status:approved"
#define NOT_SUBMITTED_STATUS @"Not Submitted"
#define NOT_SUBMITTED_STATUS_URI @"urn:replicon:approval-status:open"
#define WAITING_FOR_APRROVAL_STATUS @"Waiting for Approval"
#define WAITING_FOR_APRROVAL_STATUS_URI @"urn:replicon:approval-status:waiting"
#define REJECTED_STATUS @"Rejected"
#define REJECTED_STATUS_URI @"urn:replicon:approval-status:rejected"
#define UDFType_TEXT @"Text"
#define UDFType_NUMERIC @"Numeric"
#define UDFType_DATE @"Date"
#define UDFType_DROPDOWN @"DropDown"
#define TotalString @"Total Hours"
#define DATA_PICKER @"DataPicker"
#define DATE_PICKER @"DatePicker"
#define TIME_PICKER @"TimePicker"
#define NUMERIC_KEY_PAD @"NumericKeyPad"
#define MOVE_TO_NEXT_SCREEN @"MoveToNextScreen"
#define VIEW_TIMESHEET_SUMMARY @"View Timesheet Summary"
#define SUBMIT_TIMESHEET @"Submit Timesheet"
#define UNSUBMIT_TIMESHEET @"Unsubmit Timesheet"
#define RESUBMIT_TIMESHEET @"Resubmit Timesheet"
#define ADHOC_TIMEOFF @"Add Time-off Rows"
#define LOADING_MESSAGE @"Loading..."
#define SELECT_STRING @"Select"
#define NULL_OBJECT_STRING @"(null)"
#define TYPE_STRING @"Type"
#define ADD_STRING @"Add"
#define CANCEL_STRING @"Cancel"
#define WAITING_STRING @"Waiting"
#define NONE_STRING @"None"
#define COMMENTS_TEXTVIEW @"TextView"
#define SAVE_STRING @"Save"
#define BACK_STRING @"Back"
#define SKIP_STRING @"Skip"
//Observers
#define SHOW_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION @"SHOW_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION"
#define HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION @"HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION"
#define GET_ALL_TIMESHEETS_NOTIFICATION @"GET_ALL_TIMESHEETS_NOTIFICATION"
#define MULTIDAY_NOT_SUPPORTED_FROM_MOBILE @"Editing a multi day time off booking is not yet supported on the mobile app."

#define TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION @"Timesheet_Summary_Data_Received"
#define TIMEOFF_TYPES_RECIEVED_NOTIFICATION @"Timeoff_Types_Data_Received"
#define CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION @"Clients_Projects_Summary_Received"
#define NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION @"next_recent_clients_or_projects_received"
#define PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION @"projects_or_tasks_received"
#define ACTIVITY_RECEIVED_NOTIFICATION @"activity received"
#define BILLING_RECEIVED_NOTIFICATION @"billing received"
#define PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION @"Pull_To_Refresh_ExpenseSheet"
#define AllExpenseSheetRequestsServed @"allExpenseSheetRequestsServed"
#define NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION @"Next_Recent_Expense_Sheets_Received"
#define EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION @"ExpenseSheet_Entry_Data_Received"
#define CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION @"Currency_PaymentMethod_Summary_Received"
#define CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION @"CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION"
#define EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION @"ExpenseCode_Summary_Received"
#define EXPENSECODE_DETAILS_RECIEVED_NOTIFICATION @"ExpenseCode_Details_Received"
#define EXPENSE_SHEET_SAVE_NOTIFICATION @"Expense_Sheet_Save_summary_Received"
#define AllTimeoffRequestsServed @"AllTimeoffRequestsServed"
#define AllTeamTimeRequestsServed @"AllTeamTimeRequestsServed"
#define NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION @"Next_Recent_Time_Off_Received"
#define PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION @"Pull_To_Refresh_Time_Off_Received"
#define COMPANY_HOLIDAY_RECEIVED_NOTIFICATION @"Company_Holiday_Received "
#define TIMEOFF_ENTRY_RECEIVED_NOTIFICATION @"Timeoff_Entry_Received"
#define TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION @"Timeoff_SaveData_Received"
#define TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION @"Timeoff_BalanceSummary_RECEIVED_NOTIFICATION"
#define BALANCESUMMARY_RECEIVED_NOTIFICATION @"BalanceSummary_RECEIVED_NOTIFICATION"
#define DROPDOWN_OPTION_RECEIVED_NOTIFICATION @"DropDown_Option_Received"
#define DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION @"DropDown_Next_Option_Received"
#define CURRENTGEN_NOTIFICATION @"CURRENTGEN_NOTIFICATION"
#define NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION @"NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION"
#define APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION @"Approvals_Timesheet_Summary_Data_Received"
#define APPROVAL_REJECT_NOTIFICATION @"Approve_reject_notification_done"
#define APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION @"Approvals_Expense_Summary_Data_Received"
#define APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION @"Approvals_TimeOffs_Summary_Data_Received"
#define APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION @"Approvals_Timeoff_BalanceSummary_RECEIVED_NOTIFICATION"
#define HOMEVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION @"HOMEVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION"
#define BREAK_RECEIVED_NOTIFICATION @"break received"//Implentation for US8956//JUHI
#define DEEPLINKING_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION @"DEEPLINKING_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION"
#define SHIFT_SUMMARY_RECIEVED_NOTIFICATION @"Shift_Summary_Data_Received"//US8906//JUHI
#define SHIFT_CHECK_TIMEOFF_NOTIFICATION @"SHIFT_CHECK_TIMEOFF_NOTIFICATION"
#define DELETE_DATA_RECIEVED_NOTIFICATION @"Delete_Data_Received"
#define EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION @"Edit_Or_Add_Data_Received"
#define DATA_UPDATED_RECIEVED_NOTIFICATION @"Data_UPDATED_Received"
#define UPDATE_VIEW_NOTIFICATION @"Update_View_Received"
#define SIGNUP_DATA_RECIEVED_NOTIFICATION @"Sign Up Data Received"
#define EMAIL_VALIDATION_DATA_NOTIFICATION @"Email Validation Data Received"
#define COMPANY_NAME_VALIDATION_DATA_NOTIFICATION @"Company Validation Data Received"
#define AUDIT_TRIAL_NOTIFICATION @"AUDIT_TRIAL_NOTIFICATION"
#define TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION @"Timesheet_Timeoff_Summary_Data_Received"//Implemented as per TIME-495//JUHI
#define APPROVALS_TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION @"Approvals_Timesheet_Timeoff_Summary_Data_Received"
#define LAUNCH_LOGIN_VIEW_CONTROLLER @"LAUNCH_LOGIN_VIEW_CONTROLLER"

//Implementation For Mobi-92//JUHI
#define TIMESHEETFORMAT_RECEIVED_NOTIFICATION @"TimesheetFormat_Received"
#define APPROVAL_TIMESHEETFORMAT_RECEIVED_NOTIFICATION @"Approval_TimesheetFormat_Received"
#define SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION @"SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION"
#define SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION @"SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION"
#define DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION @"DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION"
#define TIMESHEET_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION @"TIMESHEET_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION"
#define TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION @"TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION"
#define TIMESHEET_APPROVAL_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION @"TIMESHEET_APPROVAL_CAPABILITIES_GEN4_RECEIVED_NOTIFICATION"
#define EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION @"EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION"
#define BLANK_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION @"BLANK_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION"
#define GEN4_TIMESHEET_EFFECTIVE_POLICY_DATA_NOTIFICATION @"_TIMESHEET_EFFECTIVE_POLICY_DATA_NOTIFICATION"
#define GEN4_PUNCH_TIMESHEET_NOTIFICATION @"GEN4_PUNCH_TIMESHEET_NOTIFICATION"
#define WIDGET_TIMESHEET_SAVE_NOTIFICATION @"WIDGET_TIMESHEET_SAVE_NOTIFICATION"
#define WIDGET_TIMESHEET_DELETE_NOTIFICATION @"WIDGET_TIMESHEET_DELETE_NOTIFICATION"
#define GET_WIDGET_TIMESHEET_DETAILS_NOTIFICATION @"GET_WIDGET_TIMESHEET_DETAILS_NOTIFICATION"
//TIMESHEET SUMMARY
#define TIMESHEETSUMMARY_TITLE @"Timesheet Summary"
#define PROJECT_INFOs @"Projects This Period"
#define PAYROLL_INFO @"Payroll"
#define BILLING_INFO @"Billing"
#define APPROVAL_INFO @"Approval History"
#define ADD_PROJECT_TEXT @"Add a project"
#define ADD_ACTIVITY_TEXT @"Add an activity"
#define ACTIVITY_INFO @"Activity"
#define SUMMARY_BTN_TITLE @"Summary"
#define DAY_BTN_TITLE @"Period"
#define TIMEOFF_DIALOG_TITLE @"Select TimeOff Type"
//TimeEntry
#define ADD_TIMESHEET   0
#define EDIT_TIMESHEET  1
#define VIEW_TIMESHEET  2
#define ADD_TIME_ENTRY_TITLE @"Add Entry"
#define EDIT_TIME_ENTRY_TITLE @"Edit Entry"
#define VIEW_TIME_ENTRY_TITLE @"View Entry"
#define Client @"Client"
#define Program @"Program"
#define Project @"Project"
#define Task @"Task"
#define Billing @"Billing"
#define Activity_Type @"Activity"
#define Break @"Break"
#define PROJECT_SELECTION @"Project Selection"
#define ACTIVITY_SELECTION @"Activity Selection"
#define SAVE_BTN_TITLE @"Add to Timesheet"
#define NO_ACTIVITY @"No Activity"
#define NO_PROJECT  @"No Project"
#define NO_PAYCODE  @"No Paycode"
#define NOT_BILLABLE  @"Not Billable"
#define NON_BILLABLE  @"Non Billable"
#define BILLABLE  @"Billable"
//Timesheet Model

#define TIMESHEET_MODULE_NAME @"Timesheet"

//Aprroval Pending Timesheet
#define APPROVAL_NO_TIMESHEETS_PENDING_VALIDATION @"All timesheets approved\nNone pending"
#define APPROVAL_NO_TIMESHEETS_HISTORY_VALIDATION @"No timesheets approval\nhistory found"
#define CHECK_ALL_BUTTON_TAG 400
#define CLEAR_ALL_BUTTON_TAG 401
#define PENDING_APPROVALS_TIMESHEETS @"Approve Timesheets"
#define PENDING_APPROVALS_EXPENSES   @"Approve Expenses"
#define PENDING_APPROVALS_TIMEOFFS   @"Approve Time Off"
#define PREVIOUS_APPROVALS_TIMESHEETS @"Previous Timesheets"
#define PREVIOUS_APPROVALS_EXPENSES   @"Previous Expenses"
#define PREVIOUS_APPROVALS_TIMEOFFS   @"Previous Time Off"
#define APPROVAL_COMMENT @"Approver Comments"
#define APPROVAL_TIMESHEET_VALIDATION_MSG @"Please select a timesheet for approval or rejection."
#define APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG1 @"Are you sure you want to approve"
#define APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG2 @"timesheet?"
#define APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG1 @"Are you sure you want to reject"
#define APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG2 @"timesheet?"
#define APPROVAL_TIMESHEET_REJECTION_VALIDATION @"You must enter comments when rejecting a timesheet."
#define APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG @"Are you sure you want to approve %d timesheets?"
#define APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG  @"Are you sure you want to reject %d timesheets?"
#define APPROVE_TEXT @"Approve"
#define REJECT_TEXT  @"Reject"
#define Approve_Timesheet_Error @"Timesheet(s) can not be approved"
#define Approve_Expense_Error @"Expense Sheet(s) can not be approved"
#define Approve_TimeOff_Error @"Time Off(s) can not be approved"
#define Reject_Timesheet_Error @"Timesheet(s) can not be rejected"
#define Reject_Expense_Error @"Expense Sheet(s) can not be rejected"
#define Reject_TimeOff_Error @"Time Off(s) can not be rejected"

//Aprroval Pending Expensesheet
#define APPROVAL_NO_EXPENSESHEETS_PENDING_VALIDATION @"All expense sheets approved\nNone pending"
#define APPROVAL_NO_EXPENSESHEETS_HISTORY_VALIDATION @"No expense sheets approval\nhistory found"
#define APPROVAL_EXPENSESHEET_VALIDATION_MSG @"Please select an expense sheet for approval or rejection."
#define APPROVAL_EXPENSESHEET_APPROVE_CONFIRM_MSG1 @"Are you sure you want to approve"
#define APPROVAL_EXPENSESHEET_APPROVE_CONFIRM_MSG2 @"expense sheet?"
#define APPROVAL_EXPENSESHEET_REJECT_CONFIRM_MSG1 @"Are you sure you want to reject"
#define APPROVAL_EXPENSESHEET_REJECT_CONFIRM_MSG2 @"expense sheet?"
#define APPROVAL_EXPENSESHEET_REJECTION_VALIDATION @"You must enter comments when rejecting an expense sheet."
#define APPROVAL_EXPENSESHEET_APPROVE_CONFIRM_MSG @"Are you sure you want to approve %d expense sheets?"
#define APPROVAL_EXPENSESHEET_REJECT_CONFIRM_MSG  @"Are you sure you want to reject %d expense sheets?"

//Aprroval Pending TimeOffs
#define APPROVAL_NO_TIMEOFFS_PENDING_VALIDATION @"All time offs approved\nNone pending"
#define APPROVAL_NO_TIMEOFFS_HISTORY_VALIDATION @"No time offs approval\nhistory found"
#define APPROVAL_TIMEOFFS_VALIDATION_MSG @"Please select a time off for approval or rejection."
#define APPROVAL_TIMEOFFS_APPROVE_CONFIRM_MSG1 @"Are you sure you want to approve"
#define APPROVAL_TIMEOFFS_APPROVE_CONFIRM_MSG2 @"time off?"
#define APPROVAL_TIMEOFFS_REJECT_CONFIRM_MSG1 @"Are you sure you want to reject"
#define APPROVAL_TIMEOFFS_REJECT_CONFIRM_MSG2 @"time off?"
#define APPROVAL_TIMEOFFS_REJECTION_VALIDATION @"You must enter comments when rejecting a time off."
#define APPROVAL_TIMEOFFS_APPROVE_CONFIRM_MSG @"Are you sure you want to approve %d time offs?"
#define APPROVAL_TIMEOFFS_REJECT_CONFIRM_MSG  @"Are you sure you want to reject %d time offs?"

//APPROVALS COUNT VIEW CONTROLLER
#define PENDING_APPROVALS_TITLE_MSG @"Pending Approvals"
#define PREVIOUS_APPROVALS_TITLE_MSG @"Previous Approvals"
#define PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY @"pendingExpenseSheetApprovalCount"
#define PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY @"pendingTimeOffApprovalCount"
#define PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY @"pendingTimesheetApprovalCount"
#define PREVIOUS_TIMESHEETS_APPROVALS @"Timesheet Approvals"
#define PREVIOUS_EXPENSE_APPROVALS @"Expense Approvals"
#define PREVIOUS_TIMEOFFS_APPROVALS @"Time Off Approvals"

//SELECTCLIENTORPROJECTVIEWCONTROLLER

#define CLIENTS_STRING @"Clients"
#define PROGRAMS_STRING @"Programs"
#define PROJECTS_STRING @"Projects"
#define SEARCHBAR_PLACEHOLDER_CLIENT @"Search Clients by name or code"
#define SEARCHBAR_PLACEHOLDER_PROGRAM @"Search Programs by name or code"
#define SEARCHBAR_PLACEHOLDER_PROJECT @"Search Projects by name or code"
#define ADD_PROJECT_CLIENT_STRING @"Select a Project / Client"
#define ADD_PROJECT @"Select a Project"
#define ADD_TASK @"Select a Task"
#define SEARCHBAR_PROJECT_PLACEHOLDER @"Search Projects by name or code"
#define SEARCHBAR_TASK_PLACEHOLDER @"Search Tasks by name or code"
#define SEARCHBAR_DROPDOWN_OEF_PLACEHOLDER @"Search Dropdown options"
#define ACCEPTABLE_CHARACTERS_SECTION_TABLEVIEW @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define NO_RESULTS_FOUND @"No Results"

//BillingAndActivitySearchScreen
#define SEARCHBAR_BILLING_PLACEHOLDER @"Search Billing by name"
#define ADD_BILLING @"Choose Billing Rate"
#define NO_BILLING_AVAILABLE @"No billing rate available for"
#define ACTIVITY_SCREEN  0
#define BILLING_SCREEN 1
#define NO_ACTIVITY_AVAILABLE @"No activity available"
#define ADD_ACTIVITY @"Choose Activity"
#define SEARCHBAR_ACTIVITY_PLACEHOLDER @"Search Activity by name or code"

//CurrentTimesheetPeriod
#define CURRENT_TIMESHEET @"Current Timesheet"
#define OVER_DUE @"Due - as of "
#define Submittted @"Submitted"

//TimeEntryScrollView
#define Edit_View_Row @"View / Edit Row"
#define Entry_Details @"Entry Details"
#define Delete_Row @"Delete Row"
#define EachDayTimeEntry_Cell_Row_Height_55 55.0
#define EachDayTimeEntry_Cell_Row_Height_44 44
#define EachDayTimeEntry_Cell_Row_Height_50 50
#define EachDayTimeEntry_Cell_Row_Height_67 67
#define EachDayTimeEntry_Cell_Row_Padding_10 10

//MultiDayInOutScrollView
#define In_Time @"IN"
#define Out_Time @"OUT"
#define Done @"Done"
#define Please_enter_valid_time_Message @"Please enter a valid time"
#define Time_Off_Key @"TimeOff"
#define Adhoc_Time_OffKey @"AdhocTimeOff"
#define Time_Entry_Key @"TimeEntry"
#define Overlap_Msg @"You have overlap in time entry"
#define Overlap_Extended_Load_Msg @"There are overlapping time entries. Please fix these entries before submitting your timesheet."
#define Overlap_Extended_Msg @"Time entry is overlapping."
#define Time_Off_Key_Value 1
#define Adhoc_Time_OffKey_Value 2
#define Time_Entry_Key_Value 3


//AutoSave
#define START_AUTOSAVE @"START_AUTOSAVE"

//Expense
#define ExpenseModuleName @"Expense"
#define Expense_Sheets_title @"Expense Sheets"

//SUBMIT UNSUBMIT
#define SUBMITTED_NOTIFICATION @"SUBMITTED_NOTIFICATION"
#define UNSUBMITTED_NOTIFICATION @"UNSUBMITTED_NOTIFICATION"
#define PleaseIndicateReasons @"Comments:"
//Expenses
#define ADD_EXPENSE_ENTRY  0
#define EDIT_EXPENSE_ENTRY 1
#define New_Expense_Sheet @"New Expense Sheet"
#define ADD_EXPENSE_TITLE @"Add Expense Entry"
#define EDIT_EXPENSE_TITLE @"Edit Expense Entry"
#define VIEW_EXPENSE_TITLE @"View Expense Entry"
#define Save_Button_Title @"Save"
#define Cancel_Button_Title @"Cancel"
#define Submit_Button_title @"Submit"
#define Resubmit_Button_title @"Resubmit"//implemented as per US7989
#define Reopen_Button_title @"Reopen"//implemented as per US8709//JUHI
#define Delete_Button_title @"Delete"
#define Done_Button_Title @"Done"
#define Reimbursement_string @"Reimbursement"
#define ADD @"Add"
#define SELECT @"Select"
#define YES_STRING @"Yes"
#define PROJECT @"Project"
#define TYPE @"Type"
#define CURRENCY @"Currency"
#define AMOUNT @"Amount"
#define DATE_TEXT @"Date"
#define DESCRIPTION @"Description"
#define BILL_CLIENT @"Bill Client"
#define RECEIPT_PHOTO @"Receipt Photo"
#define REIMBURSE @"Reimburse"
#define PAYMENT_METHOD @"Payment Method"
#define IMAGE_PICKER  @"ImagePicker"
#define CHECK_MARK  @"CheckMark"
#define EXPENSE_SHEET_DELETED_NOTIFICATION @"EXPENSE_SHEET_DELETED_NOTIFICATION"
#define TOTAL_STRING @"Total"
#define TOTAL @"Total Hours"
#define TOTAL_INCURRED @"Total Incurred"
#define BILLABLE_EXPENSE_URI @"urn:replicon:expense-billing-option:bill-to-client"
#define NOT_BILLABLE_EXPENSE_URI @"urn:replicon:expense-billing-option:not-billed"
#define REIMBURSABLE_EXPENSE_URI @"urn:replicon:expense-reimbursement-option:reimburse-employee"
#define NOT_REIMBURSABLE_EXPENSE_URI @"urn:replicon:expense-reimbursement-option:not-reimbursed"
#define Flat_WithOut_Taxes  @"FlatWithOutTaxes"
#define Flat_With_Taxes  @"FlatWithTaxes"
#define Rated_WithOut_Taxes  @"RatedWithOutTaxes"
#define Rated_With_Taxes  @"RatedWithTaxes"
#define RATE @"Rate"
#define PRE_TAX_AMOUNT @"Pre-Tax Amount"
#define TAXES @"Taxes"
#define TOTAL_AMOUNT @"Total Amount"

//#define PROJECT_SELECT_ERROR @"Please select a project"
#define CLIENT_SELECT_ERROR @"Please select a client"
//#define TASK_SELECT_ERROR @"Please select a task"
#define TYPE_SELECT_ERROR @"Please select a type"
#define AMOUNT_ADD_ERROR @"Please add an amount"

#define Delete_ExpenseEntry_Confirmation @"Are you sure you want to delete this expense entry?"

//IMAGE PICKER

#define CONFIRM_DEL_RECEIPT_MSG @"Permanently delete photo receipt?"
#define LARGE_RECEIPT_IMAGE_MEMORY_WARNING @"This receipt is too large to download or the connection speed is too slow. \n \nPlease log in to Replicon on a PC to view the receipt"
#define TAKE_PHOTO_BTN_TITLE @"Take photo"
#define CHOOSE_FROM_LIB_BTN_TITLE @"Choose from library"


//NEW EXPENSE SHEET

#define DescriptoinError @"Please provide a description"
#define DateError @"Please select a currency"
#define Description_PlaceHolder @"Expense Sheet Title"
#define NoSheetsAvailable @"Tap the + button above to add expenses to this sheet."
#define Delet_ExpenseSheet_Confirmation @"Are you sure you want to delete this expense sheet?"
#define NULL_STRING @"<null>"
#define NULL_OBJECT_STRING @"(null)"
#define NILL_STRING @"<nill>"

//TIME SHEET MODEL

#define STANDARD_TIMESHEET @"standard"
#define INOUT_TIMESHEET @"inout"
#define LOCKED_INOUT_TIMESHEET @"lockedinout"
#define EXTENDED_INOUT_TIMESHEET @"extendedinout"
#define GEN4_INOUT_TIMESHEET @"INOUT_GEN4"
#define GEN4_STANDARD_TIMESHEET @"STANDARD_GEN4"
#define GEN4_PUNCH_WIDGET_TIMESHEET @"PUNCH_GEN4"
#define GEN4_EXT_INOUT_TIMESHEET @"EXT_INOUT_GEN4"
#define GEN4_DAILY_WIDGET_TIMESHEET @"DAILY_WIDGET_GEN4"

//BookedTimeOff
#define BookedTimeOffList_Title @"Time Off"
#define Summary_Text  @"Bookings"
#define Calendar_Text @"Calendar"
#define BOOKED_TIMEOFF_BALANCE_TITLE @"Time Off Balances"
#define BOOKED_TIMEOFF_AVAILABLE @"Time Available"
#define BOOKED_TIMEOFF_USED @"Time Taken"
#define BOOKED_TIMEOFF_UNTRACKED @"Untracked"
#define BOOKED_TIMEOFF_CHOOSE_DATES_TITLE @"Choose Dates"
#define BOOKED_TIMEOFF_CHOOSE_START_DATE_TITLE @"Choose Start Date"
#define BOOKED_TIMEOFF_CHOOSE_END_DATE_TITLE @"Choose End Date"
#define BOOKED_TIMEOFF_APPROVED @"DatesApproved"
#define BOOKED_TIMEOFF_REJECTED @"DatesRejected"
#define BOOKED_TIMEOFF_WAITING @"DatesWaiting"
#define BOOKED_TIMEOFF_HOLIDAY @"Holiday"
#define BOOKED_TIMEOFF_APPROVED_REJECTED_DATE_KEY @"SameApprovedRejected"
#define BOOKED_TIMEOFF_APPROVED_WAITING_DATE_KEY @"SameApprovedWaiting"
#define BOOKED_TIMEOFF_REJECTED_WAITING_DATE_KEY @"SameRejectedWaiting"
#define BOOKED_TIMEOFF_WEEKEND_DATE_KEY @"WeekEndDate"
//#define BookedTimeOff  @"Book Time Off"
#define BookedTimeOffTypeFieldName @"TYPE:"
#define EditBookTimeOffTitle @"Book Time Off"
#define ViewBookTimeOffTitle @"Time Off Booking"
#define AddBookTimeOffTitle @"Book Time Off"
#define ADD_BOOKTIMEOFF  0
#define EDIT_BOOKTIMEOFF 1
#define VIEW_BOOKTIMEOFF 2
#define SELECT_START_DATE_SCREEN 0
#define SELECT_END_DATE_SCREEN 1
#define TimeOffHistoryTitle @"Time Off History"

#define DAY @"Full Day"
#define HOURS @"HOUR"
#define PARTIAL @"Partial Day"
#define ONEFOURTH @"Quarter Day"
#define HALF @"Half Day"
#define THREEQUARTER @"Three Quarter Day"

#define DELETE_BOOKTIMEOFF_MSG @"Are you sure you want to delete this time off booking?"
#define SUBMIT_BOOKTIMEOFF_MSG @"Thanks for submitting a vacation request for "

#define DAYMODE 0
#define HALFDAYMODE 1
#define HOURSMODE 2
#define THREEFOURTHDAYMODE  3
#define ONEFOURTHDAYMODE 4
#define PARTIALDAYMODE  5


#define START_AT @"Leaving at"
#define END_AT   @"Returning at"
#define START_TIME  @"Start Time"
#define END_TIME  @"End Time"
#define EDIT @"Edit"

#define BACK @"Back"
#define MoreText @"More"
#define Comments @"Comments"
#define DateFieldName @"Date"
#define CompanyHolidayTitle @"Company Holidays"
#define TIME_OFF_AVAILABLE_KEY @"urn:replicon:time-off-balance-tracking-option:track-time-remaining"
#define TIME_OFF_USED_KEY @"urn:replicon:time-off-balance-tracking-option:track-time-taken"
#define TIME_OFF_UNTRACKED_KEY @"urn:replicon:time-off-balance-tracking-option:do-not-track-balance"
#define BALANCES @"Balances"
#define HOLIDAY @"Holidays"

#define SUNDAY_KEY @"urn:replicon:day-of-week:sunday"
#define MONDAY_KEY @"urn:replicon:day-of-week:monday"
#define TUESDAY_KEY @"urn:replicon:day-of-week:tuesday"
#define WEDNESDAY_KEY @"urn:replicon:day-of-week:wednesday"
#define THURSDAY_KEY @"urn:replicon:day-of-week:thursday"
#define FRIDAY_KEY @"urn:replicon:day-of-week:friday"
#define SATURDAY_KEY @"urn:replicon:day-of-week:saturday"

#define FULLDAY_DURATION_TYPE_KEY @"urn:replicon:time-off-relative-duration:full-day"
#define HALFDAY_DURATION_TYPE_KEY @"urn:replicon:time-off-relative-duration:half-day"
#define THREEQUARTERDAY_DURATION_KEY @"urn:replicon:time-off-relative-duration:three-quarter-day"
#define QUARTERDAY_DURATION_KEY @"urn:replicon:time-off-relative-duration:quarter-day"

#define FULLDAY_POLICY_KEY      @"urn:replicon:policy:time-off:minimum-increment:full-day"
#define HALFDAY_POLICY_KEY      @"urn:replicon:policy:time-off:minimum-increment:half-day"
#define HOUR_POLICY_KEY         @"urn:replicon:policy:time-off:minimum-increment:full-hour"
#define QUARTERDAY_POLICY_KEY   @"urn:replicon:policy:time-off:minimum-increment:quarter-day"
#define NONE_POLICY_KEY         @"urn:replicon:policy:time-off:minimum-increment:no-minimum"

#define BOOKEDTIMEOFF_DELETED_NOTIFICATION @"BOOKEDTIMEOF_DELETED_NOTIFICATION"
#define StartTimeAndHourErrorMSg @"Please Enter Start time And hour"
#define EndTimeAndHourErrorMsg @"Please Enter End time And hour"
#define StartTimeErrorMsg @"Please Enter Start time"
#define StartHourErrorMsg @"Set Hours for the Start Date"
#define EndTimeErrorMsg @"Please Enter End time"
#define EndHourErrorMsg @"Set Hours for the  End Date"


#define TIMEOFF_RESUBMISSION_COMMENTS_MSG @"Please enter comments"

//DayviewController

#define No_Project @"No Project"
#define No_Task @"No Task"
#define No_Activity @"No Activity"
#define NO_PROJECTS_NO_ACTIVITY_ENTRY_PLACEHOLDER @"You do not have Project or\nActivity permission."
#define SAVE_BTN_NO_PROJECTS_NO_ACTIVITY @"Add Timesheet Row"
//USER DEFINED FIELDS

#define TEXT_UDF_TYPE    @"urn:replicon:custom-field-type:text"
#define NUMERIC_UDF_TYPE @"urn:replicon:custom-field-type:numeric"
#define DATE_UDF_TYPE    @"urn:replicon:custom-field-type:date"
#define DROPDOWN_UDF_TYPE    @"urn:replicon:custom-field-type:drop-down"
#define TIMESHEET_SHEET_UDF  @"TimeSheet_Sheet_UDF"
#define TIMESHEET_CELL_UDF  @"TimeSheet_Cell_UDF"
#define TIMEOFF_UDF  @"TimeOff_UDF"
#define EXPENSES_UDF  @"Expenses"
#define DropDownOptionTilte @"DropDown Option"
#define INVALID_NEGATIVE_NUMBER_ERROR @"Invalid value.Please edit the value"
#define TIMESHEET_ROW_UDF @"TimeSheet_Row_UDF"//Implementation for US9371//JUHI

//Settings
//REVIEW APP

#define REVIEW_APP_MSG  @"Thank you! Your review will help us improve the app."
#define REVIEW_APP_NO_OPTION  @"No Thanks"
#define REVIEW_APP_YES_OPTION @"App Store"

//Email Constants

#define EMAIL_SUBJECT @"Feedback for Replicon Mobile 3 v"
#define RECIPENT_ADDRESS @"iphonefeedback@replicon.com"
#define COMPANY_NAME @"Company"

#define TROUBLE_SIGNING_EMAIL_SUBJECT @"Trouble signing in - Replicon Mobile 3 v"

//PlaceHolders for 0 data in list

#define _NO_TIMESHEETS_AVAILABLE @"You do not have any Timesheets. \nPlease contact your administrator \nif this is unexpected"
#define _NO_EXPENSES_AVAILABLE @"Please tap the + button to create \na new Expense Sheet"
#define _NO_TIMEOFFS_AVAILABLE @"Please tap the + button to \nrequest Time Off"
#define _NO_AdHocTIMEOFFS_AVAILABLE @"You don't have any Adhoc Time Off's \nassigned to you. Please tap on the \nTime Off tab at the bottom of the \nscreen and create a new Booked \nTime Off request"

#define APPROVAL_TIMEOFF_NOT_WAITINGFORAPPROVAL @"This timeoff is no longer\n waiting for approval"
#define APPROVAL_TIMESHEET_NOT_WAITINGFORAPPROVAL @"This timesheet is no longer\n waiting for approval"
#define APPROVAL_EXPENSESHEET_NOT_WAITINGFORAPPROVAL @"This expense sheet is no longer\n waiting for approval"
#define APPROVAL_SUBMITTED_ON @"Submitted on"
#define LOCKED_INOUT_SCREEN_LOAD_MSG @"The application currently does not support punching in and out. A view-only version of the Timesheet is being displayed instead."

#define APPROVE_BUTTON_TAG 201
#define REJECT_BUTTON_TAG 202
#define COMMENTS_TEXTVIEW_TAG 203
#define REOPEN_BUTTON_TAG 204
#define DONE_BUTTON_TAG 205
#define DOT_BUTTON_TAG 206

//Slider Menu

#define SLIDER_REPLICON_TITLE @"My Replicon"
#define SLIDER_SCHEDULE_TITLE @"Schedule"
#define SLIDER_TEAM_TITLE     @"Team"
#define LogOut_Confirmation_Msg @"Are you sure you want to logout?"
#define SLIDERVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION @"SLIDERVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION"
#define TIMEOFF_PARTIAL_CELL_TAG 5619

#define NO_PERMISSON_ERROR_MSG @"You do not have the required permissions to use the Replicon Mobile application. Please contact your Replicon system administrator"
//Modified Since
#define UTC_TIMEZONE @"urn:replicon:time-zone:Etc/GMT"
#define FULL_UPDATEMODE @"urn:replicon:cacheable-list-update-mode:full-update"
#define DELTA_UPDATEMODE @"urn:replicon:cacheable-list-update-mode:delta-update"

//ADD DELETE ROWS
#define ADD_PROJECT_ENTRY  0
#define EDIT_PROJECT_ENTRY 1
#define VIEW_PROJECT_ENTRY 2
#define ADD_PROJECT_ENTRY_ACTION_MODE 0
#define DELETE_PROJECT_ENTRY_ACTION_MODE 1
#define EDIT_PROJECT_ENTRY_ACTION_MODE 2
#define EDIT_BREAK_ENTRY 3//Implentation for US8956//JUHI
#define EDIT_Timeoff_ENTRY 4//Implentation for US9109//JUHI

#define ADD_TIMEOFF_ENTRY_ACTION_MODE 0
#define DELETE_TIMEOFF_ENTRY_ACTION_MODE 1
#define EDIT_TIMEOFF_ENTRY_ACTION_MODE 2
#define ENTRY_DELETE_CONFIRMATION_MSG @"Deleting this item will remove it from all the days in this timesheet period, along with any associated hours and comments. Do you want to proceed?"
#define INOUT_ENTRY_DELETE_CONFIRMATION_MSG @"Deleting this item will remove associated hours and comments. Do you want to proceed?"
#define INOUT_CELL_TAG 9999
#define TIMEOFF_CELL_TAG 1111

//EXTENDED IN OUT USER

#define EXTENDED_INOUT_ERRORMSG @"Sorry! \nYour timesheet format is not yet supported in Replicon Mobile. We are working hard to add this feature. Please stay tuned to updates from the App store."
#define EXTENDED_INOUT_APPROVAL_PENDING_PREVIOUS_MSG @"Sorry! \nThis timesheet format is not yet supported in Replicon Mobile. We are working hard to add this feature. Please stay tuned to updates from the App store."

//FlurryFaultExceptionEvent
#define FAULT_CONTRACT_EXCEPTION @"FaultContractValidationException"

#define EXTENDED_IN_OUT_TIMESHEET_TYPE 99999999
#define NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE 00000000
#define GEN4_TIMESHEET_TYPE 88888888

//JUHI
#define CLIENT_MODE 0
#define PROJECT_MODE 1
#define TASK_MODE 2
#define PROGRAM_MODE 3

#define PREVIOUS_ENTRIES_STRING @"Suggestions Based on Previous Entries"
#define ENTRY_DETAILS_STRING @"Entry Details"
#define TO_STRING @"to"
#define DELETE_ENTRY_STRING @"Delete Entry"
//Break
#define ADD_BREAK_ENTRY_TITLE @"Add Break Entry"
#define EDIT_BREAK_ENTRY_TITLE @"Edit Break Entry"
#define ADD_TIME @"Add Time"
#define ADD_BREAK @"Add Break"
#define CHOOSE_BREAK @"Choose Break"
#define SEARCHBAR_BREAK_PLACEHOLDER @"Search Breaks"
#define DELETE_BREAKENTRY_STRING @"Delete Break"
#define BREAK_ENTRY_DETAILS_STRING @"Break Details"
//Timeoff//US9109
#define ADD_TimeOff_ENTRY_TITLE @"Add Time Off"
#define EDIT_TimeOff_ENTRY_TITLE @"Edit Time Off"
#define SEARCHBAR_TimeOff_PLACEHOLDER @"Search Time Off Types"

#define MIDNIGHT_CROSSOVER_SPLIT_CONFIRMATION_MSG_PART_1 @"You have entered time that crosses into the next day."
#define MIDNIGHT_CROSSOVER_SPLIT_CONFIRMATION_MSG_PART_2 @"will be entered on"
#define MIDNIGHT_CROSSOVER_MSG_ON_NEXT_TIMESHEET @"You cannot enter time past the last day of the timesheet period."
//DEEPLINKING LINKS

#define DEEPLINKING_TIMESHEETS @"timesheets"
#define DEEPLINKING_EXPENSES @"expenses"
#define DEEPLINKING_TIMEOFFS @"timeoffs"
#define DEEPLINKING_TIMESHEETS_APPROVALS @"timesheets_approvals"
#define DEEPLINKING_EXPENSES_APPROVALS @"expenses_approvals"
#define DEEPLINKING_TIMEOFFS_APPROVALS @"timeoffs_approvals"
#define DEEPLINKING_LAUNCH @"launch"
#define DEEPLINKING_ATTENDENCE @"attendance"
#define DEEPLINKING_SHIFT @"shifts"

#define ExpenseTypeOptionTitle @"Expense Type"
#define EXPENSE_TYPE_SEARCH_SCREEN 0
#define SEARCH_EXPENSE_TYPE_LABEL @"Search Expense Type"
#define DELETE_TIMESHEET_VALIDATION_MSG @"Deleting this item will remove it from all days in this timesheet period,along with any associated hours and comments.Do you want to proceed?"
#define LINE  @"LINE"
#define CELL_HEIGHT_KEY @"CELL-HEIGHT"
#define UPPER_LABEL_HEIGHT @"FIRST_LABEL_HEIGHT"
#define MIDDLE_LABEL_HEIGHT @"SECOND_LABEL-HEIGHT"
#define LOWER_LABEL_HEIGHT @"THIRD_LABEL-HEIGHT"
#define BILLING_LABEL_HEIGHT @"BILLING_LABEL-HEIGHT"
#define UPPER_LABEL_STRING @"UPPER_LABEL_STRING"
#define MIDDLE_LABEL_STRING @"MIDDLE_LABEL_STRING"
#define LOWER_LABEL_STRING @"LOWER_LABEL_STRING"
#define BILLING_RATE @"BILLING_RATE"

#define UPPER_LABEL_TEXT_WRAP @"UPPER_LABEL_TEXT_WRAP"
#define MIDDLE_LABEL_TEXT_WRAP @"MIDDLE_LABEL_TEXT_WRAP"
#define LOWER_LABEL_TEXT_WRAP @"LOWER_LABEL_TEXT_WRAP"

//REMEMBER USER
#define REMEMBER_ME @"Remember Company and User Name"

//Shifts
#define SHIFT_DETAILS @"Shift Details"
#define SHIFT_ENTRY @"Shifts"
#define TIME_OFF_ENTRY @"TimeOff"
#define HOLIDAY_ENTRY @"Holiday"
#define BREAK_ENTRY @"Break"
#define N0_MESSAGE_FROM_MANAGER @"No Note From Manager"
#define N0TE_FROM_MANAGER @"Note from Shift Manager"
#define NO_SHIFT @"No Shifts Assigned"

//Implementation forMobi-181//JUHI
#define NO_SELECTION @"None Selected"
#define CURRENT_TIME_STRING @"Current Time"
// Punch time

#define OFFLINE_MODE_ERROR_MSG @"Your device is offline. A data connection is required to use this feature."
#define PUNCH_OUT_ACTION @"PUNCH_OUT_ACTION"
#define PUNCH_IN_ACTION @"PUNCH_IN_ACTION"
#define OnBreakTitle @"On Break"
#define START_NEW_TASK_NOTIFICATION @"START_NEW_TASK_NOTIFICATION"
#define SHORTCUT_START_TASK_NOTIFICATION @"SHORTCUT_START_TASK_NOTIFICATION"
#define PUNCH_TIME_NOTIFICATION @"PUNCH_TIME_NOTIFICATION"
#define PUNCH_IN_URI @"urn:replicon:time-punch-action:in"
#define PUNCH_OUT_URI @"urn:replicon:time-punch-action:out"
#define CONCATENATE_PUNCH_TIME_NOTIFICATION @"CONCATENATE_PUNCH_TIME_NOTIFICATION"
#define PUNCH_OUT_PREVIOUS_NOTIFICATION @"PUNCH_OUT_PREVIOUS_NOTIFICATION"
#define TRANSFER_PUNCH_TIME_NOTIFICATION @"TRANSFER_PUNCH_TIME_NOTIFICATION"
#define TRANSFER_PUNCH_BREAK_NOTIFICATION @"TRANSFER_PUNCH_BREAK_NOTIFICATION"
#define PUNCH_START_BREAK_URI @"urn:replicon:time-punch-action:start-break"
#define PUNCH_TRANSFER_URI @"urn:replicon:time-punch-action:transfer"
#define PUNCH_AGENT_MOBILE_URI @"urn:replicon:well-known-time-punch-agent-type:mobile"
#define PUNCH_AGENT_WEB_URI @"urn:replicon:well-known-time-punch-agent-type:web-ui"
#define PUNCH_AGENT_CC_URI @"urn:replicon:well-known-time-punch-agent-type:cloud-clock"

#define LAST_PUNCH_DATA_NOTIFICATION @"LAST_PUNCH_DATA_NOTIFICATION"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define ONE_THIRD_SCREEN_WIDTH SCREEN_WIDTH/3

#define NO_PROJECT_SELECTED_STRING @"No Project Selected"
#define NO_ACTIVITY_SELECTED_STRING @"No Activity Selected"
#define Continue_Button_Title @"Continue"
#define CAMERA_MAIN_TITLE @"Take a Photo of Yourself"
#define CAMERA_SUB_TITLE @"You are required to attach a photo with each time entry."
#define CAMERA_PREVIEW_TITLE @"Preview Photo"
#define RETAKE_STRING @"Retake"
#define USE_STRING @"Use"


#define CLOCKED_IN_HEADER @"Clocked In"
#define CLOCKED_OUT_HEADER @"Clocked Out"
#define CLOCKING_IN_HEADER @"Clocking You In..."
#define CLOCKING_OUT_HEADER @"Clocking You Out..."
#define AT_STRING @"at"
#define LOCATION_UNAVAILABLE_STRING @"Location Unavailable"
#define PUNCH_RESPONSE_RECEIVED_NOTIFICATION @"PUNCH_RESPONSE_RECEIVED_NOTIFICATION"
#define MIDNIGHT_SERVICE_RECEIVED_NOTIFICATION @"MIDNIGHT_SERVICE_RECEIVED_NOTIFICATION"
#define Recent_Entries @"Today's Entries"

#define YESTERDAY_LABEL_OFFSET_HEIGHT 20.0
#define YESTERDAY_STRING @"Yesterday"
#define LOCATION_SETTINGS_ALERT @"Location is not enabled. Go to \"Settings\" -> \"Privacy\" -> \"Location Services\" to enable location"




#define SEGMENT_TIME @"Time"
#define SEGMENT_IMAGES @"Images"
#define SEGMENT_LOCATION @"Location"



#define USER_CELL @"TeamTimeUserCell"
#define ACTIVITY_CELL @"TeamTimeActivityCell"
#define PUNCH_CELL @"TeamTimePairCell"
#define IMAGES_PAIR_CELL @"TeamTimeImagesCell"
#define LOCATION_PAIR_CELL @"TeamTimeLocationCell"
#define BREAK_CELL @"TeamTimeBreakCell"
#define NO_ENTRIES_CELL @"TeamTimeNoEntriesCell"
#define PLACEHOLDER_CELL @"TeamTimePlaceholderCell"

//Implementation For Mobi-190//Reset Password//JUHI
#define RESET_PASSWORD @"Save New Password"
#define UPDATEPASSWORD_NOTIFICATION @"UPDATEPASSWORD_NOTIFICATION"
#define ResetPasswordTabbarTitle @"Reset Password"
#define PsswordMissMatch_Msg @"Please ensure your new passwords match"
#define OldPasswordMatch_ErrorMsg @"Your new password must be different than your current password"
#define UPDATEPASSWORD_HOMESUMMARY_NOTIFICATION @"UPDATEPASSWORD_HOMESUMMARY_NOTIFICATION"

//Impelementation For Punch
#define AddPunch_Title @"Add Punch"
#define EditPunch_Title @"Edit Punch"
#define ViewPunch_Title @"View Punch"
#define ADD_PUNCH_ENTRY  0
#define EDIT_PUNCH_ENTRY 1
#define VIEW_PUNCH_ENTRY 2
#define Transfer @"Transfered to"
#define IN_TEXT @"IN"
#define OUT_TEXT @"OUT"
#define CLOCKED_IN @"Clocked In"
#define CLOCKED_OUT @"Clocked Out"
#define PUNCH_DELETE_MSG @"Are you sure you want to delete this Punch? This can not be undone."
#define SELECT_BREAK @"Select Break Type"
#define SELECT_ACTIVITY @"Select Activity"
#define BREAK_TITLE @"Started Break"
#define Transfer_Title @"Transfer"
#define BREAK_OUT_TITLE @"End Break"
#define POST_BTN_TITLE @"Post"
#define NO_ENTRIES_TEXT @"No time punches."
#define VIA_MOBILE_TEXT @"via"
#define LAST_PUNCH_TEXT @"Last Punch"
#define ON_TEXT @"on"

#define POST_TEAM_NOTIFICATION @"POST_TEAM_NOTIFICATION"
#define POST_ERROR_MSG @"time punches could not be posted to timesheet."
#define POST_SUCCESS_MSG @"Successfully posted to timesheet"
#define NO_BREAKS_MSG @"Please select a Break Type"
#define NO_ACTIVITY_MSG @"Please select an Activity"
#define TRANSFERRED_STATUS_URI @"urn:replicon:time-punch-timesheet-transfer-status:transferred"
#define TRANSFERRED_ERROR_STATUS_URI @"urn:replicon:time-punch-timesheet-transfer-status:transfer-error"
#define ACTIVITY_NONE_STRING  @"Activity: None"
#define TIMESHEET_LIST_COLUMN @"urn:replicon:timesheet-list-column:timesheet"
//DCCA//JUHI
#define FollowingChangesWereMadeToThisTimesheet @"Following changes were made to this timesheet:"
#define ReasonForChange @"Reason for Changes "
#define PleaseProvideReasonForTheseChanges @"Please provide reasons for these changes."
#define Cancel_Msg @"Your timesheet cannot be submitted unless you provide a reason for the changes."
#define AddComments @"Add Comments"

//Free Trial
#define FREE_TRAIL_TEXT @"Create Free Trial"
#define LOGIN_TEXT @"SIGN IN"
#define YOUR_NAME_TEXT @"Your Full Name"
#define COMPANY_NAME_TEXT @"Company Name"
#define EMAIL_ADDRESS_TEXT @"Email Address"
#define PASSWORD_TEXT @"Password"
#define REQUIRED_PASSWORD__TEXT @"8 characters, at least 1 alphabetical and 1 numeric"
#define BUSINESS_NUMBER_TEXT @"Business Phone Number"
#define TERMS_OF_SERVICE_TEXT1 @"By registering you agree to Replicon's"
#define TERMS_OF_SERVICE_TEXT2 @"Terms of Service"
#define SIGN_UP_TEXT @"Sign Up"
#define SETTINGUP_YOUR_ACCOUNT_TEXT @"Setting up your account"
#define INFO_TEXT @"Enjoy full access to the following features for next 14 days. We are also creating sample data to help you see how everything works."
#define SETUP_COMPLETE_TEXT @"Setup Complete"
#define START_USING_REPLICON_TEXT @"Start Using Replicon"
#define FILL_ALL_FIELDS_TEXT @"Please fill all fields."
#define EMAIL_ALREADY_EXIST_TEXT @"Email Address already exist."
#define PASSWORD_VALIDATION_FIRST_LINE @"8 characters,"
#define PASSWORD_VALIDATION_SECOND_LINE @"at least 1 alphabetical"
#define PASSWORD_VALIDATION_THIRD_LINE @"and 1 numeric"
#define FREETRIAL_LOGO_TITLE @"Hassle-free Time Tracking"

#define CAROUSEL1_TEXT @"Enter project-based time with ease"
#define CAROUSEL2_TEXT @"In/out time entry made quick and painless"
#define CAROUSEL3_TEXT @"Field workers can clock-in from their worksite"
#define CAROUSEL4_TEXT @"Track where employees clock-in using GPS"
#define CAROUSEL5_TEXT @"Take expense receipt photos and upload. Done!"
#define CAROUSEL6_TEXT @"Approve timesheets, time off, expenses on the spot"
#define CAROUSEL7_TEXT @"Quickly analyze projects and bill clients"
#define CAROUSEL8_TEXT @"Overtime compliance and error free payroll"

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

//Implementation for MOBI-261//JUHI
#define APPROVAL_DETAIL_TITLE @"Approval Details"
#define Approved_Action_URI @"urn:replicon:approval-action:approve"
#define Submit_Action_URI @"urn:replicon:approval-action:submit"
#define Reject_Action_URI @"urn:replicon:approval-action:reject"
#define Reopen_Action_URI @"urn:replicon:approval-action:reopen"
#define SystemApproved_Action_URI @"urn:replicon:approval-action:forced-approve"
#define OnBehalfOf @"on behalf of"
#define SystemApprove @"<System>"
#define NoComments @"No Comments"
#define NO_AUDIT_TRIAL_DATA @"No Audit Trail Data Found"//MOBI-1042
#define MODIFICATION_TYPE_ADDED    @"urn:replicon:time-punch-audit-record-modification-type:created"
#define MODIFICATION_TYPE_ORIGINAL  @"urn:replicon:time-punch-audit-record-modification-type:created-with-authentic-time"
#define MODIFICATION_TYPE_EDITED   @"urn:replicon:time-punch-audit-record-modification-type:edited"
#define MODIFICATION_TYPE_DELETED  @"urn:replicon:time-punch-audit-record-modification-type:deleted"

#define VIA_WEB @"urn:replicon:well-known-time-punch-agent-type:web-ui"
#define VIA_MOBILE @"urn:replicon:well-known-time-punch-agent-type:mobile"
#define VIA_CLOUDCLOCK @"urn:replicon:well-known-time-punch-agent-type:cloud-clock"



#define MANUAL_PUNCH_URI @"urn:replicon:time-punch-audit-record-modification-type:created-with-authentic-time"


//MOBI - 406
#define RATE_APP_TEXT @"Please take a moment to rate the Replicon app."
#define NO_THANKS_TEXT @"No, Thanks"
#define SUBMIT_RATING_TEXT @"Submit Rating"
#define REMIND_ME_LATER_TEXT @"Remind Me Later"
#define SORRY_TITLE_TEXT @"Provide Feedback"
#define SORRY_MSG_TEXT @"Would you please take a moment to tell us how we can do better?"
#define FEEDBACK_TEXT @"Feedback"
#define THANKS_TITLE_TEXT @"Awesome, Thanks!"
#define THANKS_MSG_TEXT @"Would you please add your rating on the App Store as well?"
#define APP_STORE_TEXT @"App Store"
#define STAR_RATING_TEXT @"Star Rating for Replicon Mobile 3 v"
#define NOT_SELECTED_RATING_TEXT @"Please select a star rating."

//Implemetation for Punch-229//JUHI
#define TRANSFERRED_IN @"Transferred In"
#define TRANSFERRED_OUT @"Transferred Out"
#define FORSTRING @"For"
#define PunchDetail_Title @"Punch Details"

//MOBI-434
#define DEBUG_MODE_WARNING_MSG_TEXT @"Debug mode has been enabled. The app performance may be slower while the app is in debug mode."
#define DEBUG_MODE_DESCRIPTION_TEXT @"Please continue using the app and send us the log file when you encounter an issue."
#define DEBUF_MODE_ON_TEXT @"Debug Mode is On"
#define DEBUF_MODE_OFF_TEXT @"Debug Mode is Off"
#define SEND_LOG_FILE_TEXT @"Send Log File"
#define DEBUG_MODE_CHECK_MSG_TEXT @"Replicon is running in debug mode. Turn off debug mode?"

//Implementation For Mobi-92//JUHI
#define Gen4TimeSheetFormat @"urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet"
#define ADD_BREAK_ENTRY @"Add Break"
#define Gen4InOutTimesheetFormat @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry"
#define GEN4_INOUT_BREAK_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:track-breaks"
#define GEN4_INOUT_TIME_ENTRY_COMMENTS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
#define GEN4_INOUT_EDIT_TIME_ENTRIES_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:edit-time-entries"
#define GEN4_STANDARD_FILTER_PROJECTS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by"
#define GEN4_STANDARD_PROJECTS_TASKS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks"
#define GEN4_STANDARD_BILLING_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options"
#define GEN4_STANDARD_ACTIVITIES_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities"
#define GEN4_STANDARD_TIME_ENTRY_COMMENTS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
#define GEN4_STANDARD_TIME_ENTRY_NEGATIVE_TIME_ENTRY_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:negative-durations"
#define GEN4_STANDARD_TIME_ENTRY_NEGATIVE_TIME_ENTRY_ALLOWED @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:negative-durations:allowed"

#define GEN4_CAN_REOPEN_POLICY_URI @"urn:replicon:policy:timesheet:can-owner-reopen"
#define GEN4_CAN_REOPEN_AFTER_APPROVALS_POLICY_URI @"urn:replicon:policy:timesheet:can-owner-reopen-after-approvals"
#define GEN4_CAN_RESUBMIT_WITH_BLANK_COMMENTS_POLICY_URI @"urn:replicon:policy:timesheet:can-owner-resubmit-with-blank-comments"
#define GEN4_TIME_OFF_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:time-off"
#define EnableBreakUriPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:track-breaks:allow-track-breaks"
#define EnableTimeEntryCommentsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"
#define EnableEditTimeEntriesPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:edit-time-entries:allow-edit-time-entries"
#define EnableStandardGen4ClientsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by:clients"
#define EnableStandardGen4ProgramsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by:program"
#define EnableStandardGen4ProjectsAndTasksPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks:allow-projects-and-tasks"
#define EnableStandardGen4AllowActivitiesPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities:allow-activities"
#define EnableStandardGen4AllowBillingPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options:allow-billing-options"
#define EnableStandardTimeEntryCommentsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"

#define GEN4_EXT_INOUT_PROJECTS_TASKS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:projects-and-tasks"
#define Enable_EXT_INOUT_Gen4ProjectsAndTasksPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:projects-and-tasks:allow-projects-and-tasks"
#define GEN4_EXT_INOUT_BILLING_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:billing-options"
#define Enable_EXT_INOUT_Gen4AllowBillingPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:billing-options:allow-billing-options"
#define GEN4_EXT_INOUT_ACTIVITIES_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:activities"
#define Enable_EXT_INOUT_Gen4AllowActivitiesPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:activities:allow-activities"
#define GEN4_EXT_INOUT_TIME_ENTRY_COMMENTS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:time-entry-comments"
#define Enable_EXT_INOUT_TimeEntryCommentsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:time-entry-comments:allow-time-entry-comments"
#define GEN4_EXT_INOUT_BREAK_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:track-breaks"
#define Enable_EXT_INOUT_BreakUriPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:track-breaks:allow-track-breaks"
#define GEN4_EXT_INOUT_FILTER_PROJECTS_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:filter-projects-by"
#define Enable_EXT_INOUT_Gen4ClientsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:filter-projects-by:clients"
#define Enable_EXT_INOUT_Gen4ProgramsPolicyValueUri @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:filter-projects-by:program"
#define GEN4_EXT_INOUT_ENTRY_OEF_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry:entry-level-object-extension-fields"
#define GEN4_STANDARD_ROW_OEF_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:row-level-object-extension-fields"
#define GEN4_STANDARD_ENTRY_OEF_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:entry-level-object-extension-fields"
#define DAILY_WIDGET_OEF_POLICY_URI @"urn:replicon:policy:timesheet:widget-timesheet:daily-fields:day-level-object-extension-fields"


#define AllowedCanReopenPolicyValueUri @"urn:replicon:policy:timesheet:can-owner-reopen:allowed"
#define NotAllowedCanReopenPolicyValueUri @"urn:replicon:policy:timesheet:can-owner-reopen:not-allowed"


#define AllowedCanReopenAfterApprovalsPolicyValueUri @"urn:replicon:policy:timesheet:can-owner-reopen-after-approvals:allowed"
#define NotAllowedCanReopenAfterApprovalsPolicyValueUri @"urn:replicon:policy:timesheet:can-owner-reopen-after-approvals:not-allowed"


#define AllowedCanResubmitWithBlanlkCommentsPolicyValueUri @"urn:replicon:policy:timesheet:can-owner-resubmit-with-blank-comments:allowed"
#define NotAllowedCanResubmitWithBlanlkCommentsPolicyValueUri @"urn:replicon:policy:timesheet:can-owner-resubmit-with-blank-comments:not-allowed"

#define SUPER_PERMISSION_FOR_TRACKING_BREAKS @"urn:replicon:policy:timesheet:breaks-on-timesheet"
#define SUPER_PERMISSION_FOR_TRACKING_COMMENTS @"urn:replicon:policy:timesheet:can-owner-edit-timesheet"
#define SUPER_PERMISSION_FOR_TRACKING_TIMESHEET_EDIT @"urn:replicon:policy:timesheet:timesheet-comments"
#define ADD_BREAK_ENTRY @"Add Break"


//Implementation for MOBI-328
#define LOGOUT_RESPONSE_NOTIFICATION @"LOGOUT_RESPONSE_NOTIFICATION"

//TIME-314
#define GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION @"GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION"

FOUNDATION_EXPORT NSString *GEN4_TIMESHEET_ERROR_URI;
FOUNDATION_EXPORT NSString *GEN4_TIMESHEET_WARNING_URI;
FOUNDATION_EXPORT NSString *GEN4_TIMESHEET_INFORMATION_URI;

#define ISSUES_ON_TEXT @"Issues on"
#define ERROR_TEXT @"Errors"
#define WARNING_TEXT @"Warnings"
#define INFORMATION_TEXT @"Information"
#define TIMESHEET_LEVEL_ERROR_TEXT @"Timesheet Level Errors"

#define ERROR_LABEL_TEXT @"Error"
#define WARNING_LABEL_TEXT @"Warning"



#define APPROVER_HISTORY_WIDGET_TITLE @"Approval History"
#define IN_OUT_TIMESHEET_WIDGET_TITLE @"In/Out Time"
#define EXT_IN_OUT_TIMESHEET_WIDGET_TITLE @"In/Out Times + Allocation"
#define STANDARD_TIMESHEET_WIDGET_TITLE @"Time Distribution"
#define PUNCH_TIMESHEET_WIDGET_TITLE @"Time Punches"
#define REGULAR_HOURS_TITLE @"Regular Hours"
#define BREAK_HOURS_TITLE @"Break Hours"
#define WORK_HOURS_TITLE @"Work Hours"
#define TIMEOFF_HOURS_TITLE @"Time Off Hours"
#define ADD_COMMENT_WIDGET_TITLE @"Add a Comment"

#define PUNCH_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
#define INOUT_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry"
#define APPROVAL_HISTORY_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
#define TIMEOFF_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:time-off"
#define NOTICE_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:notice"
#define NOTICE_WIDGET_TITLE_URI @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
#define NOTICE_WIDGET_DESCRIPTION_URI @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
#define PUNCH_BREAK_ACCESS_KEY @"urn:replicon:policy:time-punch:punch-into-break"
#define NotAllowedPunchInBreakPolicyValueUri @"urn:replicon:policy:time-punch:punch-into-break:do-not-allow-punch-into-break"
#define TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE @"Your timesheet format is not supported on the mobile app."
#define TIMESHEET_PUNCH_POLICY_NOT_ASSIGNED @"A punch policy has to be assigned to your account. Please contact your Admin."
#define STANDARD_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry"
#define ATTESTATION_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
#define PAYSUMMARY_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
#define TOIL_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:time-off-in-lieu"
#define DISPLAY_AMOUNT_IN_PAYSUMMARY_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
#define ATTESTATION_WIDGET_TITLE_URI @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
#define ATTESTATION_WIDGET_DESCRIPTION_URI @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
#define EXT_INOUT_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry"
#define DAILY_FIELDS_WIDGET_URI @"urn:replicon:policy:timesheet:widget-timesheet:daily-fields"
#define DAILY_FIELDS_WIDGET_TITLE_URI @"urn:replicon:policy:timesheet:widget-timesheet:daily-fields:daily-fields-title"
#define DEFAULT_DAILY_FIELDS_TITLE @"Daily Fields"

// SCHED - 114
#define SELECT_A_DATE_TEXT @"Select a Date"

//HRTrial//JUHI
#define HRFreeTrial_Button_Title @"HR Tech 2014"
#define HRFreeTrialTabbarTitle @"HR Tech 2014!"
#define HRTrialMsg @"Visit us at our booth at HR Tech 2014 and get your special account."
//MOBI-653
#define REJECTED_EXPENSE_SHEETS_COUNT_KEY @"rejectedExpenseSheetCount"
#define REJECTED_TIMEOFF_BOOKING_COUNT_KEY @"rejectedTimeOffBookingCount"
#define REJECTED_TIMESHEET_COUNT_KEY @"rejectedTimesheetCount"
#define TIMESHEET_PAST_DUE_COUNT_KEY @"timesheetPastDueCount"

//MOBI-814 --  HANDLE NSURLErrorDomain Codes

#define ERROR_URLErrorUnknown_998 @"An unknown error occurred. Please try again. If the problem persists, please contact support."
#define ERROR_URLErrorUnknown_999 @"The operation could not be completed."
#define ERROR_URLErrorTimedOut_1001 @"Server request timed out. Please ensure you have an internet connection and try again."




#define HOLIDAY_CALENDAR_NOT_SET_ERROR_MSG @"Holiday calendar has not been configured for your account. Please contact your Admin."

#define ERROR_URLErrorTimedOut_FromServer @"Server request timed out."

//MOBI-811
#define PLEASE_SPECIFY_TEXT @"Please specify"

//MOBI-782
#define SERVER_MAINTENANCE_DOWN_TIME_ERROR @"Replicon is performing scheduled server maintenance from"
#define TRY_AGAIN_TEXT @"Please try again later."

//MOBI-839
#define Punch_URLError_Msg @"Please refresh your data and try again."
#define Timesheet_URLError_Msg @"Please refresh your timesheet."
#define TimeOff_URLErroe_Msg @"Please refresh your time off data."
#define Expense_URLError_Msg @"Please refresh your expense sheet."
#define Pending_Timesheet_URLError_Msg @"Please refresh your pending timesheet data."
#define Previous_Timesheet_URLError_Msg @"Please refresh your previous timesheet data."
#define Pending_Expense_URLError_Msg @"Please refresh your pending expense sheet data."
#define Previous_Expense_URLError_Msg @"Please refresh your previous expense sheet data."
#define Pending_TimeOff_URLErroe_Msg @"Please refresh your pending time off data."
#define Previous_TimeOff_URLErroe_Msg @"Please refresh your previous time off data."

//MOBI-849
#define CameraDisableMsg @"Allow access to your camera to start taking photos with the Replicon app.\n 1. Open your device Settings\n 2. Go to Privacy\n 3. Go to Camera\n 4. Turn Replicon ON"

//MOBI- 786
#define USER_FRIENDLY_ERROR_MSG @"You do not have access to perform this operation. Please refresh your app data. If that does not resolve the issue, contact your Admin."
#define APP_REFRESH_DATA_TITLE @"Refresh App Data"

//MOBI- 766
#define SIGN_IN_WITH_GOOGLE @"Sign In with Google"
#define OR_TEXT @"OR"
#define AUTHENTICATING_TEXT @"Authenticating..."
#define SIGNING_TEXT @"Signing In..."
#define USER_NAME_COMPANY_NAME_VALIDATION @"Please enter your Company Name and User Name."
#define EMAIL_COMPANY_NAME_VALIDATION @"Please enter your Company Name and Email Address."
#define TROUBLE_SIGNING_TEXT @"Trouble Signing In?"
#define FORGOT_PASSWORD @"Forgot Password?"
#define CONTACT_SUPPORT @"Contact Support"
#define FORGOT_PASSWORD_TITLE @"Enter your Company Name and Email Address to reset your password."
#define FORGOT_PASSWORD_SUCCESS_MSG @"Instructions to reset your password have been emailed to you. Please check your email."
#define TENANT_RESPONSE_RECEIVED_NOTIFICATION @"TENANT_RESPONSE_RECEIVED_NOTIFICATION"
#define CREATE_PASSWORD_RESPONSE_NOTIFICATION @"CREATE_PASSWORD_RESPONSE_NOTIFICATION"
#define TROUBLE_SIGNING_WITH_CONTACT_TEXT @"Trouble Signing In? Contact Support"

#define CREATE_PASSWORD_RESET_RESPONSE_NOTIFICATION @"CreatePasswordResetResponseNotification"
#define SEND_PASSWORD_RESET_REQUEST_EMAIL_RESPONSE_NOTIFICATION @"Send password restet request email response notification"

//MOBI-236
#define INVALID_PASSWORD_TEXT @"Please enter your password."
#define INVALID_USER_NAME_PASSWORD_TEXT @"Please enter your user name and password."
#define INVALID_EMAIL_ADDRESS_TEXT @"Please enter your email address."

#define DEFAULT_BILLING_RECEIVED_NOTIFICATION @" DEFAULT_BILLING_RECEIVED_NOTIFICATION"

/*
//MOBI-776

#define TIMESHEET_PERMISSION_CHANGED @"You are no longer allowed to use timesheet module"
#define EXPENSES_PERMISSION_CHANGED @"You are no longer allowed to use expenses module"
#define TIMEOFF_PERMISSION_CHANGED @"You are no longer allowed to use timeoff module"
#define SCHEDULES_PERMISSION_CHANGED @"You are no longer allowed to use schedules module"
#define CLOCK_IN_OUT_PERMISSION_CHANGED @"You are no longer allowed to use clock in or out module"
#define PUNCH_HISTORY_PERMISSION_CHANGED @"You are no longer allowed to use punch history module"
#define TEAM_TIME_PERMISSION_CHANGED @"You are no longer allowed to use team time module"
#define APPROVAL_TIMESHEET_PERMISSION_CHANGED @"You are no longer allowed to approve timesheets"
#define APPROVAL_EXPENSES_PERMISSION_CHANGED @"You are no longer allowed to approve expenses"
#define APPROVAL_TIMEOFFS_PERMISSION_CHANGED @"You are no longer allowed to approve timeoffs"
 */

#define DEFAULT_BILLING_FROM_TASK_VIEW_RECEIVED_NOTIFICATION @"DEFAULT_BILLING_FROM_TASK_VIEW_RECEIVED_NOTIFICATION"
#define UPDATE_ENTRY_VIEW_FROM_TASK_VIEW_RECEIVED_NOTIFICATION @"UPDATE_ENTRY_VIEW_FROM_TASK_VIEW_RECEIVED_NOTIFICATION"

#define TIME_ENTRY_TAG 0
#define BREAK_ENTRY_TAG 1

// OPERATIONS NAMES

#define TIMESHEET_SAVE_OPERATION @"SAVE"
#define TIMESHEET_SUBMIT_OPERATION @"SUBMIT"
#define TIMESHEET_REOPEN_OPERATION @"REOPEN"
#define TIMESHEET_RESUBMIT_OPERATION @"RESUBMIT"

//CUSTOM TIMESHEET CLIENT STATUS

#define TIMESHEET_PENDING_SUBMISSION @"Pending Submission"
#define TIMESHEET_SUBMITTED @"Submitted"
#define TIMESHEET_CONFLICTED @"Conflicted"
#define TIMESHEET_SAVE_INFLIGHT @"Save-Inflight"

#define REFRESH_TIMEENTRIES_DB_DATA @"REFRESH_TIMEENTRIES_DB_DATA"
// version

#define SYSTEM_VERSION_LESS_THAN(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

FOUNDATION_EXPORT NSString *const PUNCH_ACTION_URI_IN;
FOUNDATION_EXPORT NSString *const PUNCH_ACTION_URI_OUT;
FOUNDATION_EXPORT NSString *const PUNCH_ACTION_URI_TRANSFER;
FOUNDATION_EXPORT NSString *const PUNCH_ACTION_URI_BREAK;

FOUNDATION_EXPORT NSString *const TAB_BAR_MODULES_KEY;
FOUNDATION_EXPORT NSString *const TIMESHEETS_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const EXPENSES_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const TIME_OFF_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const CLOCK_IN_OUT_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const PUNCH_HISTORY_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const SCHEDULE_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const APPROVAL_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const SETTINGS_TAB_MODULE_NAME;
FOUNDATION_EXPORT NSString *const NEW_PUNCH_WIDGET_MODULE_NAME;
FOUNDATION_EXPORT NSString *const PUNCH_IN_PROJECT_MODULE_NAME;
FOUNDATION_EXPORT NSString *const PUNCH_INTO_ACTIVITIES_MODULE_NAME;
FOUNDATION_EXPORT NSString *const WRONG_CONFIGURATION_MODULE_NAME;
FOUNDATION_EXPORT NSString *const PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME;

#define GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION @"GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION"

FOUNDATION_EXPORT NSString *const PunchAssemblyGuardErrorDomain;
FOUNDATION_EXPORT NSString *const CameraAssemblyGuardErrorDomain;
FOUNDATION_EXPORT NSString *const LocationAssemblyGuardErrorDomain;
FOUNDATION_EXPORT NSString *const PunchAssemblyGuardChildErrorsKey;

FOUNDATION_EXPORT NSString *const PunchRequestIdentifierHeader;
FOUNDATION_EXPORT NSString *const MostRecentPunchDateIdentifierHeader;
FOUNDATION_EXPORT NSString *const GetTimesheetSummaryDateIdentifierHeader;

FOUNDATION_EXPORT NSString *const RepliconHTTPRequestErrorDomain;
FOUNDATION_EXPORT NSString *const RepliconHTTPNonJsonResponseErrorDomain;
FOUNDATION_EXPORT NSString *const RepliconServerMaintenanceError;
FOUNDATION_EXPORT NSString *const RepliconGenericPosixOrUrlDomainError;
FOUNDATION_EXPORT NSString *const RepliconFailureStatusCodeDomain;
FOUNDATION_EXPORT NSString *const RepliconNoAlertErrorDomain;
FOUNDATION_EXPORT NSString *const PasswordAuthenticationErrorDomain;
FOUNDATION_EXPORT NSString *const CompanyAuthenticationErrorDomain;
FOUNDATION_EXPORT NSString *const CompanyDisabledErrorDomain;
FOUNDATION_EXPORT NSString *const NoAuthErrorDomain;
FOUNDATION_EXPORT NSString *const PasswordExpiredErrorDomain;
FOUNDATION_EXPORT NSString *const UnknownErrorDomain;
FOUNDATION_EXPORT NSString *const UserAuthChangeErrorDomain;
FOUNDATION_EXPORT NSString *const UserDisabledErrorDomain;
FOUNDATION_EXPORT NSString *const InvalidTimesheetFormatErrorDomain;
FOUNDATION_EXPORT NSString *const OperationTimeoutErrorDomain;
FOUNDATION_EXPORT NSString *const UriErrorDomain;
FOUNDATION_EXPORT NSString *const RandomErrorDomain;
FOUNDATION_EXPORT NSString *const InvalidUserSessionRequestDomain;
FOUNDATION_EXPORT NSString *const AuthorizationErrorDomain;


FOUNDATION_EXPORT NSString *const RepliconHTTPRequestError_998;
FOUNDATION_EXPORT NSString *const RepliconHTTPRequestError_999;
FOUNDATION_EXPORT NSString *const RepliconHTTPRequestError_1001;
FOUNDATION_EXPORT NSString *const RepliconHTTPRequestError_1200;


FOUNDATION_EXPORT NSString *const PasswordResetFailedMessage;
FOUNDATION_EXPORT NSString *const EnterValidEmailMessage;
FOUNDATION_EXPORT NSString *const EnterValidEmailAndCompanyMessage;
FOUNDATION_EXPORT NSString *const InstructionsToResetPasswordMessage;
FOUNDATION_EXPORT NSString *const ForgotPasswordViewTitle;
FOUNDATION_EXPORT NSString *const ForgotPasswordTitle;
FOUNDATION_EXPORT NSString *const CompanyNamePlaceholderText;
FOUNDATION_EXPORT NSString *const EmailAddressPlaceholderText;
FOUNDATION_EXPORT NSString *const ResetPasswordButtonTitle;
FOUNDATION_EXPORT NSString *const RequestMadeWhileInvalidUserSessionHeaderValue;
FOUNDATION_EXPORT NSString *const RequestMadeWhileInvalidUserSessionHeaderKey;
FOUNDATION_EXPORT NSString *const RequestMadeForSearchWithHeaderKey;
FOUNDATION_EXPORT NSString *const RequestMadeForSearchWithValue;
FOUNDATION_EXPORT NSString *const RequestMadeWhilePendingQueueSyncHeaderValue;
FOUNDATION_EXPORT NSString *const RequestMadeWhilePendingQueueSyncHeaderKey;







#define ATTESTATION_STATUS_ATTESTED @"urn:replicon:attestation-status:attested"
#define ATTESTATION_STATUS_UNATTESTED @"urn:replicon:attestation-status:unattested"
#define ATTESTATION_NOT_SELECTED_ALERT_MSG @"Please accept the disclaimer."

FOUNDATION_EXPORT NSString *const NoTimeSheetAssignedMsg;
FOUNDATION_EXPORT NSString *const RefreshButtonTitle;

// OBJECT EXTENSION FIELDS

#define TIMESHEET_CELL_OEF  @"TimeSheet_Cell_OEF"
#define TIMESHEET_ROW_OEF  @"TimeSheet_Row_OEF"
#define TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI @"urn:replicon:time-off-measurement-unit:work-days"
#define TIME_Off_DISPLAY_HOURS_FORMAT_URI @"urn:replicon:time-off-measurement-unit:hours"

// DAILY WIDGET OBJECT EXTENSION FIELD

#define DAILY_WIDGET_DAYLEVEL_OEF  @"DailyWidget_DayLevel_OEF"
#define DAILY_WIDGET_PLACEHOLDER_TEXT_OEF  @"Enter text"
#define DAILY_WIDGET_PLACEHOLDER_DROPDOWN_OEF  @"Select"
#define DAILY_WIDGET_PLACEHOLDER_NUMERIC_OEF  @"Enter numeric value"



//Welcome View
FOUNDATION_EXPORT NSString *const attendanceTitle;
FOUNDATION_EXPORT NSString *const approvalAttendanceTitle;
FOUNDATION_EXPORT NSString *const clientBillingTitle;
FOUNDATION_EXPORT NSString *const approvalClientBillingTitle;
FOUNDATION_EXPORT NSString *const attendanceDetailsText;
FOUNDATION_EXPORT NSString *const approvalAttendanceDetailsText;
FOUNDATION_EXPORT NSString *const clientBillingDetailsText;
FOUNDATION_EXPORT NSString *const approvalClientBillingDetailsText;


FOUNDATION_EXPORT NSString *const noTimeOffTypesAssigned;

FOUNDATION_EXPORT NSString *const OEF_NUMERIC_DEFINITION_TYPE_URI;
FOUNDATION_EXPORT NSString *const OEF_TEXT_DEFINITION_TYPE_URI;
FOUNDATION_EXPORT NSString *const OEF_DROPDOWN_DEFINITION_TYPE_URI;

FOUNDATION_EXPORT NSString *const wrongConfigurationMsg;

FOUNDATION_EXPORT NSString *const serviceUnavailabilityIssue;
FOUNDATION_EXPORT NSString *const RepliconServiceUnAvailabilityResponseErrorDomain;

FOUNDATION_EXPORT NSString *const phoneCaptureDescription;
FOUNDATION_EXPORT NSString *const phoneCapturePlaceHolder;

FOUNDATION_EXPORT NSString *const syncTimesheetLocalNotificationMsg;
FOUNDATION_EXPORT NSString *const errorNotification;
FOUNDATION_EXPORT NSString *const successNotification;

FOUNDATION_EXPORT NSString *const errorNotification;
FOUNDATION_EXPORT NSString *const noErrorsDisplayMsg;

FOUNDATION_EXPORT const int errorBannerHeight;
FOUNDATION_EXPORT NSString *const DeleteAllErrorsMessage;
FOUNDATION_EXPORT NSString *const cellDeleteButtonText;
FOUNDATION_EXPORT NSString *const dismissAllText;
FOUNDATION_EXPORT NSString *const notificationText;
FOUNDATION_EXPORT NSString *const notificationsText;

FOUNDATION_EXPORT NSString *const rejectionCommentsErrorText;
FOUNDATION_EXPORT NSString *const totalHoursText;

FOUNDATION_EXPORT NSString *const inOutWidgetMidNightCrossUri;
FOUNDATION_EXPORT NSString *const allowInOutWidgetSplitMidNightCrossUri;
FOUNDATION_EXPORT NSString *const extendedInOutWidgetMidNightCrossUri;
FOUNDATION_EXPORT NSString *const allowExtendedInOutWidgetSplitMidNightCrossUri;

FOUNDATION_EXPORT NSString *const  saveInProgressTitle;
FOUNDATION_EXPORT NSString *const  saveInProgressText;

FOUNDATION_EXPORT NSString *const  breakTypeText;
FOUNDATION_EXPORT NSString *const  selectBreakTypeText;


FOUNDATION_EXPORT NSString *const  InvalidProjectSelectedError;
FOUNDATION_EXPORT NSString *const  InvalidTaskSelectedError;

FOUNDATION_EXPORT NSString *const  punchesWithErrorsTitle;
FOUNDATION_EXPORT NSString *const  punchesWithErrorsMsg;

FOUNDATION_EXPORT NSString *const  selectFromBookmarksText;
FOUNDATION_EXPORT NSString *const  createBookmarksText;
FOUNDATION_EXPORT NSString *const  noBookmarksAvailableText;
FOUNDATION_EXPORT NSString *const  noBookmarksCreatedText;

FOUNDATION_EXPORT NSString *const  clientProjectTaskSelectionErrorMsg;
FOUNDATION_EXPORT NSString *const  projectAndTaskSelectionErrorMsg;
FOUNDATION_EXPORT NSString *const  previousProjectsText;
FOUNDATION_EXPORT NSString *const  InvalidActivitySelectedError;


FOUNDATION_EXPORT NSString *const CameraAccessDisabledError;
FOUNDATION_EXPORT NSString *const GPSAccessDisabledError;
FOUNDATION_EXPORT NSString *const CameraAccessDisabledErrorAlertTitle;
FOUNDATION_EXPORT NSString *const GPSAccessDisabledErrorAlertTitle;
FOUNDATION_EXPORT NSString *const withString;


FOUNDATION_EXPORT NSString *const ClientTypeAnyClient;
FOUNDATION_EXPORT NSString *const ClientTypeNoClient;
FOUNDATION_EXPORT NSString *const ClientTypeAnyClientUri;
FOUNDATION_EXPORT NSString *const ClientTypeNoClientUri;

FOUNDATION_EXPORT NSString *const NumericOEFPlaceholder;
FOUNDATION_EXPORT NSString *const TextOEFPlaceholder;
FOUNDATION_EXPORT NSString *const DropDownOEFPlaceholder;


FOUNDATION_EXPORT NSString *const offlineMessage;

FOUNDATION_EXPORT NSString *const OEFMaxPrecisionKey;
FOUNDATION_EXPORT NSString *const OEFMaxScaleKey;
FOUNDATION_EXPORT NSString *const OEFMaxTextCharLimitKey;
FOUNDATION_EXPORT NSString *const OEFNumericFieldValueLimitExceededError;
FOUNDATION_EXPORT NSString *const OEFTextFieldValueLimitExceededError;

FOUNDATION_EXPORT NSString *const  ProjectTimeAndExpenseEntryTypeNonBillableUri;
FOUNDATION_EXPORT NSString *const  ProjectBillingTypeNonBillableUri;

FOUNDATION_EXPORT NSString *const  ApplicationStateHeaders;
FOUNDATION_EXPORT NSString *const  RequestTimestamp;
FOUNDATION_EXPORT NSString *const  ApplicationLastActiveForegroundTimestamp;

FOUNDATION_EXPORT NSString *const  AllowSplitTimeMidNightCrossEntry;
FOUNDATION_EXPORT NSString *const  SplitTimeEntryForNextTimesheetPeriod;

FOUNDATION_EXPORT NSString *const  PunchesWereNotSavedErrorNotificationMsg;
FOUNDATION_EXPORT NSString *const  Issues_text;
FOUNDATION_EXPORT NSString *const  Issue_text;
FOUNDATION_EXPORT NSString *const  PunchEmptyState_First;
FOUNDATION_EXPORT NSString *const  PunchEmptyState_Second;
FOUNDATION_EXPORT NSString *const  UnknownText;


FOUNDATION_EXPORT NSString *const ApprovedTimesheetStatus;
FOUNDATION_EXPORT NSString *const NotSubmittedTimesheetStatus;
FOUNDATION_EXPORT NSString *const RejectedTimesheetStatus;
FOUNDATION_EXPORT NSString *const WaitingTimesheetStatus;          


FOUNDATION_EXPORT NSString *const  invalidProjectFailureUri;

FOUNDATION_EXPORT NSString *const BulkPunchWithCreatedAtTime3;
