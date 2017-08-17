/*
 Navicat Premium Data Transfer

 Source Server         : Main
 Source Server Type    : SQLite
 Source Server Version : 3007003
 Source Database       : main

 Target Server Type    : SQLite
 Target Server Version : 3007003
 File Encoding         : utf-8

 Date: 06/25/2016 23:14:38 PM
*/

PRAGMA foreign_keys = false;

-- ----------------------------
--  Table structure for "Activity"
-- ----------------------------
DROP TABLE IF EXISTS "Activity";
CREATE TABLE "Activity" ("activityName" VARCHAR, "activityUri" VARCHAR, "moduleName" VARCHAR, "activity_Name" VARCHAR);

-- ----------------------------
--  Table structure for "ApprovalsPendingExpenseCodeDetails"
-- ----------------------------
DROP TABLE IF EXISTS "ApprovalsPendingExpenseCodeDetails";
CREATE TABLE "ApprovalsPendingExpenseCodeDetails" (
	 "expenseCodeName" VARCHAR,
	 "expenseCodeUri" VARCHAR NOT NULL,
	 "expenseCodeType" VARCHAR,
	 "expenseCodeUnitName" VARCHAR,
	 "expenseCodeRate" VARCHAR,
	 "expenseCodeCurrencyUri" VARCHAR,
	 "expenseCodeCurrencyName" VARCHAR,
	 "taxAmount1" VARCHAR,
	 "taxAmount2" VARCHAR,
	 "taxAmount3" VARCHAR,
	 "taxAmount4" VARCHAR,
	 "taxAmount5" VARCHAR,
	 "expenseEntryUri" VARCHAR NOT NULL,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "PendingApprovalExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "ApprovalsPendingExpenseTaxCodes"
-- ----------------------------
DROP TABLE IF EXISTS "ApprovalsPendingExpenseTaxCodes";
CREATE TABLE "ApprovalsPendingExpenseTaxCodes" (
	 "name" VARCHAR,
	 "uri" VARCHAR NOT NULL,
	 "taxAmount" VARCHAR,
	 "id" NUMERIC NOT NULL,
	 "expenseEntryUri" VARCHAR NOT NULL,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "PendingApprovalExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "ApprovalsPreviousExpenseCodeDetails"
-- ----------------------------
DROP TABLE IF EXISTS "ApprovalsPreviousExpenseCodeDetails";
CREATE TABLE "ApprovalsPreviousExpenseCodeDetails" (
	 "expenseCodeName" VARCHAR,
	 "expenseCodeUri" VARCHAR NOT NULL,
	 "expenseCodeType" VARCHAR,
	 "expenseCodeUnitName" VARCHAR,
	 "expenseCodeRate" VARCHAR,
	 "expenseCodeCurrencyUri" VARCHAR,
	 "expenseCodeCurrencyName" VARCHAR,
	 "taxAmount1" VARCHAR,
	 "taxAmount2" VARCHAR,
	 "taxAmount3" VARCHAR,
	 "taxAmount4" VARCHAR,
	 "taxAmount5" VARCHAR,
	 "expenseEntryUri" VARCHAR NOT NULL,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "PreviousApprovalExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "ApprovalsPreviousExpenseTaxCodes"
-- ----------------------------
DROP TABLE IF EXISTS "ApprovalsPreviousExpenseTaxCodes";
CREATE TABLE "ApprovalsPreviousExpenseTaxCodes" (
	 "name" VARCHAR,
	 "uri" VARCHAR NOT NULL,
	 "taxAmount" VARCHAR,
	 "id" NUMERIC NOT NULL,
	 "expenseEntryUri" VARCHAR NOT NULL,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "PreviousApprovalExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "ApproveTimesheetReasonForchange"
-- ----------------------------
DROP TABLE IF EXISTS "ApproveTimesheetReasonForchange";
CREATE TABLE "ApproveTimesheetReasonForchange" ("timesheetUri" TEXT,"header" TEXT DEFAULT (null) ,"reasonForChange" TEXT,"change" TEXT,"uniqueID" TEXT DEFAULT (null) ,"entryHeader" TEXT DEFAULT (null) );

-- ----------------------------
--  Table structure for "Billing"
-- ----------------------------
DROP TABLE IF EXISTS "Billing";
CREATE TABLE "Billing" ("billingName" VARCHAR, "billingUri" VARCHAR, "moduleName" VARCHAR);

-- ----------------------------
--  Table structure for "BookedTimeoffTypes"
-- ----------------------------
DROP TABLE IF EXISTS "BookedTimeoffTypes";
CREATE TABLE "BookedTimeoffTypes" (
	 "timeoffTypeName" VARCHAR,
	 "timeoffTypeUri" VARCHAR NOT NULL,"minTimeoffIncrementPolicyUri" VARCHAR,"timeoffBalanceTrackingOptionUri" VARCHAR,"startEndTimeSpecRequirementUri" VARCHAR, "enabled" NUMERIC, "timeOffDisplayFormatUri" VARCHAR,PRIMARY KEY("timeoffTypeUri")
);

-- ----------------------------
--  Table structure for "Break"
-- ----------------------------
DROP TABLE IF EXISTS "Break";
CREATE TABLE "Break" ("breakName" VARCHAR, "breakUri" VARCHAR);

-- ----------------------------
--  Table structure for "Clients"
-- ----------------------------
DROP TABLE IF EXISTS "Clients";
CREATE TABLE "Clients" ("clientName" VARCHAR, "clientUri" VARCHAR, "endDate" DATETIME, "startDate" DATETIME, "moduleName" VARCHAR, "client_Name" VARCHAR);

-- ----------------------------
--  Table structure for "CompanyHolidays"
-- ----------------------------
DROP TABLE IF EXISTS "CompanyHolidays";
CREATE TABLE "CompanyHolidays" ("holidayDate" DATETIME, "holidayName" VARCHAR, "holidayUri" VARCHAR);

-- ----------------------------
--  Table structure for "Cookies"
-- ----------------------------
DROP TABLE IF EXISTS "Cookies";
CREATE TABLE "Cookies" (
	 "cookie" blob
);

-- ----------------------------
--  Table structure for "DataSyncDetails"
-- ----------------------------
DROP TABLE IF EXISTS "DataSyncDetails";
CREATE TABLE "DataSyncDetails" (
	 "moduleName" TEXT,
	 "lastSyncDate" DATETIME
);

-- ----------------------------
--  Table structure for "Disclaimer"
-- ----------------------------
DROP TABLE IF EXISTS "Disclaimer";
CREATE TABLE "Disclaimer" ( "description" VARCHAR, "title" VARCHAR, "module" VARCHAR);

-- ----------------------------
--  Table structure for "EnabledWidgets"
-- ----------------------------
DROP TABLE IF EXISTS "EnabledWidgets";
CREATE TABLE "EnabledWidgets" (
	 "widgetUri" text NOT NULL,
	 "timesheetUri" text NOT NULL,
	 "orderNo" NUMERIC,
	 "supportedInMobile" NUMERIC,
	 "enabled" NUMERIC,
	 "widgetTitle" text,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "ExpenseCodeDetails"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseCodeDetails";
CREATE TABLE "ExpenseCodeDetails" (
	 "expenseCodeName" VARCHAR,
	 "expenseCodeUri" VARCHAR NOT NULL,
	 "isEnabled" NUMERIC,
	 "expenseCodeType" VARCHAR,
	 "expenseCodeUnitName" VARCHAR,
	 "expenseCodeRate" VARCHAR,
	 "expenseCodeCurrencyUri" VARCHAR,
	 "expenseCodeCurrencyName" VARCHAR,
	 "taxcode1" VARCHAR,
	 "taxcode2" VARCHAR,
	 "taxcode3" VARCHAR,
	 "taxcode4" VARCHAR,
	 "taxcode5" VARCHAR
);

-- ----------------------------
--  Table structure for "ExpenseCodes"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseCodes";
CREATE TABLE "ExpenseCodes" (
	 "expenseCodeName" VARCHAR,
	 "expenseCodeUri" VARCHAR NOT NULL,
	PRIMARY KEY("expenseCodeUri")
);

-- ----------------------------
--  Table structure for "ExpenseCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseCustomFields";
CREATE TABLE "ExpenseCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "expenseSheetUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "ExpenseSheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "ExpenseEntries"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseEntries";
CREATE TABLE "ExpenseEntries" (
	 "expenseSheetUri" VARCHAR,
	 "expenseEntryUri" VARCHAR NOT NULL,
	 "approvalStatus" VARCHAR,
	 "expenseEntryDescription" VARCHAR,
	 "billingUri" VARCHAR,
	 "expenseCodeUri" VARCHAR,
	 "expenseCodeName" VARCHAR,
	 "expenseReceiptName" VARCHAR,
	 "expenseReceiptUri" VARCHAR,
	 "incurredAmountNetCurrencyName" VARCHAR,
	 "incurredAmountNetCurrencyUri" VARCHAR,
	 "incurredAmountNet" VARCHAR,
	 "incurredAmountTotalCurrencyName" VARCHAR,
	 "incurredAmountTotalCurrencyUri" VARCHAR,
	 "incurredAmountTotal" VARCHAR,
	 "incurredDate" DATETIME,
	 "paymentMethodName" VARCHAR,
	 "paymentMethodUri" VARCHAR,
	 "projectUri" VARCHAR,
	 "projectName" VARCHAR,
	 "taskName" VARCHAR,
	 "taskUri" VARCHAR,
	 "reimbursementUri" VARCHAR,
	 "quantity" VARCHAR,
	 "rateAmount" VARCHAR,
	 "rateCurrencyName" VARCHAR,
	 "rateCurrencyUri" VARCHAR,
	 "taxAmount1" VARCHAR,
	 "taxAmount2" VARCHAR,
	 "taxAmount3" VARCHAR,
	 "taxAmount4" VARCHAR,
	 "taxAmount5" VARCHAR,
	 "taxCurrencyName1" VARCHAR,
	 "taxCurrencyName2" VARCHAR,
	 "taxCurrencyName3" VARCHAR,
	 "taxCurrencyName4" VARCHAR,
	 "taxCurrencyName5" VARCHAR,
	 "taxCurrencyUri1" VARCHAR,
	 "taxCurrencyUri2" VARCHAR,
	 "taxCurrencyUri3" VARCHAR,
	 "taxCurrencyUri4" VARCHAR,
	 "taxCurrencyUri5" VARCHAR,
	 "taxCodeUri1" VARCHAR,
	 "taxCodeUri2" VARCHAR,
	 "taxCodeUri3" VARCHAR,
	 "taxCodeUri4" VARCHAR,
	 "taxCodeUri5" VARCHAR,
	 "noticeExplicitlyAccepted" NUMERIC, "clientUri" VARCHAR, "clientName" VARCHAR,
	PRIMARY KEY("expenseEntryUri"),
	FOREIGN KEY ("expenseSheetUri") REFERENCES "ExpenseSheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "ExpenseIncurredAmountTax"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseIncurredAmountTax";
CREATE TABLE "ExpenseIncurredAmountTax" (
	 "expenseEntryUri" VARCHAR,
	 "currencyName" VARCHAR,
	 "currencyUri" VARCHAR,
	 "taxCodeName" VARCHAR,
	 "taxCodeUri" VARCHAR,
	 "amount" VARCHAR,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "ExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "ExpensePermittedApprovalActions"
-- ----------------------------
DROP TABLE IF EXISTS "ExpensePermittedApprovalActions";
CREATE TABLE "ExpensePermittedApprovalActions" (
	 "uri" VARCHAR NOT NULL,
	 "canApproveReject" NUMERIC,
	 "canForceApproveReject" NUMERIC,
	 "canReopen" NUMERIC,
	 "canSubmit" NUMERIC,
	 "canUnsubmit" NUMERIC,
	 "module" VARCHAR,
	FOREIGN KEY ("uri") REFERENCES "ExpenseSheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "ExpenseSheetApprovalHistory"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseSheetApprovalHistory";
CREATE TABLE "ExpenseSheetApprovalHistory" (
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "actionUri" VARCHAR NOT NULL,
	 "timestamp" DATETIME NOT NULL, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "ExpenseSheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "ExpenseSheets"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseSheets";
CREATE TABLE "ExpenseSheets" (
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "expenseDate" DATETIME,
	 "approvalStatus" VARCHAR,
	 "reimbursementAmountCurrencyName" VARCHAR,
	 "reimbursementAmountCurrencyUri" VARCHAR,
	 "reimbursementAmount" VARCHAR,
	 "incurredAmountCurrencyName" VARCHAR,
	 "incurredAmountCurrencyUri" VARCHAR,
	 "incurredAmount" VARCHAR,
	 "description" VARCHAR,
	 "trackingNumber" VARCHAR,
	PRIMARY KEY("expenseSheetUri")
);

-- ----------------------------
--  Table structure for "ExpenseTaxCodes"
-- ----------------------------
DROP TABLE IF EXISTS "ExpenseTaxCodes";
CREATE TABLE "ExpenseTaxCodes" ("name" VARCHAR, "uri" VARCHAR PRIMARY KEY  NOT NULL , "formula" VARCHAR, "id" NUMERIC NOT NULL );

-- ----------------------------
--  Table structure for "LastPunchData"
-- ----------------------------
DROP TABLE IF EXISTS "LastPunchData";
CREATE TABLE "LastPunchData" ("time" TEXT DEFAULT (null) ,"time_format" TEXT DEFAULT (null) ,"entry_date" TEXT DEFAULT (null) ,"actionUri" TEXT DEFAULT (null) ,"activityUri" TEXT DEFAULT (null) ,"activityName" TEXT DEFAULT (null) ,"breakType" TEXT,"breakUri" TEXT DEFAULT (null) ,"full_image_link" TEXT DEFAULT (null) ,"full_image_uri" TEXT DEFAULT (null) ,"address" TEXT DEFAULT (null) ,"time_stamp" DATETIME DEFAULT (null) ,"latitude" FLOAT,"longitude" FLOAT, "thumbnail_image_link" TEXT, "thumbnail_image_uri" TEXT, "agentTypeName" TEXT, "agentTypeUri" TEXT);

-- ----------------------------
--  Table structure for "NewUserDetails"
-- ----------------------------
DROP TABLE IF EXISTS "NewUserDetails";
CREATE TABLE "NewUserDetails" (
	 "uri" TEXT,
	 "slug" TEXT,
	 "displayText" TEXT,
	 "hasTimesheetAccess" NUMERIC,
	 "hasExpenseAccess" NUMERIC,
	 "hasTimeOffAccess" NUMERIC,
	 "hasShiftAccess" NUMERIC,
	 "hasTimePunchAccess" NUMERIC,
	 "canViewTimePunch" NUMERIC,
	 "canViewTeamTimePunch" NUMERIC,
	 "hasTimesheetApprovalAccess" NUMERIC,
	 "hasExpenseApprovalAccess" NUMERIC,
	 "hasTimeOffApprovalAccess" NUMERIC,
	 "language_cultureCode" TEXT,
	 "language_displayText" TEXT,
	 "language_code" TEXT,
	 "language_uri" TEXT
);

-- ----------------------------
--  Table structure for "OEFDropDownTagOptions"
-- ----------------------------
DROP TABLE IF EXISTS "OEFDropDownTagOptions";
CREATE TABLE "OEFDropDownTagOptions" (
	 "oefDropDownTagUri" TEXT,
	 "oefDropDownTagDisplayText" TEXT
);

-- ----------------------------
--  Table structure for "PendingApprovalDisclaimer"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalDisclaimer";
CREATE TABLE PendingApprovalDisclaimer ( "description" VARCHAR, "title" VARCHAR, "module" VARCHAR);

-- ----------------------------
--  Table structure for "PendingApprovalExpenseCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalExpenseCustomFields";
CREATE TABLE "PendingApprovalExpenseCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "expenseSheetUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PendingApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalExpenseEntries"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalExpenseEntries";
CREATE TABLE "PendingApprovalExpenseEntries" (
	 "expenseSheetUri" VARCHAR,
	 "expenseEntryUri" VARCHAR NOT NULL,
	 "approvalStatus" VARCHAR,
	 "expenseEntryDescription" VARCHAR,
	 "billingUri" VARCHAR,
	 "expenseCodeUri" VARCHAR,
	 "expenseCodeName" VARCHAR,
	 "expenseReceiptName" VARCHAR,
	 "expenseReceiptUri" VARCHAR,
	 "incurredAmountNetCurrencyName" VARCHAR,
	 "incurredAmountNetCurrencyUri" VARCHAR,
	 "incurredAmountNet" VARCHAR,
	 "incurredAmountTotalCurrencyName" VARCHAR,
	 "incurredAmountTotalCurrencyUri" VARCHAR,
	 "incurredAmountTotal" VARCHAR,
	 "incurredDate" DATETIME,
	 "paymentMethodName" VARCHAR,
	 "paymentMethodUri" VARCHAR,
	 "projectUri" VARCHAR,
	 "projectName" VARCHAR,
	 "taskName" VARCHAR,
	 "taskUri" VARCHAR,
	 "reimbursementUri" VARCHAR,
	 "quantity" VARCHAR,
	 "rateAmount" VARCHAR,
	 "rateCurrencyName" VARCHAR,
	 "rateCurrencyUri" VARCHAR,
	 "taxAmount1" VARCHAR,
	 "taxAmount2" VARCHAR,
	 "taxAmount3" VARCHAR,
	 "taxAmount4" VARCHAR,
	 "taxAmount5" VARCHAR,
	 "taxCurrencyName1" VARCHAR,
	 "taxCurrencyName2" VARCHAR,
	 "taxCurrencyName3" VARCHAR,
	 "taxCurrencyName4" VARCHAR,
	 "taxCurrencyName5" VARCHAR,
	 "taxCurrencyUri1" VARCHAR,
	 "taxCurrencyUri2" VARCHAR,
	 "taxCurrencyUri3" VARCHAR,
	 "taxCurrencyUri4" VARCHAR,
	 "taxCurrencyUri5" VARCHAR,
	 "taxCodeUri1" VARCHAR,
	 "taxCodeUri2" VARCHAR,
	 "taxCodeUri3" VARCHAR,
	 "taxCodeUri4" VARCHAR,
	 "taxCodeUri5" VARCHAR,
	 "noticeExplicitlyAccepted" NUMERIC, "clientName" VARCHAR, "clientUri" VARCHAR,
	PRIMARY KEY("expenseEntryUri"),
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PendingApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalExpenseIncurredAmountTax"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalExpenseIncurredAmountTax";
CREATE TABLE "PendingApprovalExpenseIncurredAmountTax" (
	 "expenseEntryUri" VARCHAR,
	 "currencyName" VARCHAR,
	 "currencyUri" VARCHAR,
	 "taxCodeName" VARCHAR,
	 "taxCodeUri" VARCHAR,
	 "amount" VARCHAR,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "PendingApprovalExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalExpenseSheetApprovalHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalExpenseSheetApprovalHistory";
CREATE TABLE "PendingApprovalExpenseSheetApprovalHistory" (
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "actionUri" VARCHAR NOT NULL,
	 "timestamp" DATETIME NOT NULL, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PendingApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalExpensesheets"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalExpensesheets";
CREATE TABLE "PendingApprovalExpensesheets" (
	 "approvalStatus" VARCHAR,
	 "approval_dueDate" DATETIME,
	 "approval_dueDateText" VARCHAR,
	 "username" VARCHAR,
	 "userUri" VARCHAR,
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "expenseDate" DATETIME,
	 "reimbursementAmountCurrencyName" VARCHAR,
	 "reimbursementAmountCurrencyUri" VARCHAR,
	 "reimbursementAmount" VARCHAR,
	 "description" VARCHAR,
	 "incurredAmountCurrencyName" VARCHAR,
	 "incurredAmountCurrencyUri" VARCHAR,
	 "incurredAmount" VARCHAR,
	 "trackingNumber" VARCHAR,
	PRIMARY KEY("expenseSheetUri")
);

-- ----------------------------
--  Table structure for "PendingApprovalTimeEntries"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimeEntries";
CREATE TABLE "PendingApprovalTimeEntries" (
	 "timesheetUri" TEXT NOT NULL,
	 "timePunchesUri" TEXT,
	 "timeAllocationUri" TEXT,
	 "timeOffUri" TEXT,
	 "timeOffTypeName" TEXT,
	 "entryType" TEXT,
	 "timesheetEntryDate" DATETIME,
	 "durationHourFormat" TEXT,
	 "durationDecimalFormat" TEXT,
	 "projectUri" TEXT,
	 "projectName" TEXT,
	 "taskUri" TEXT,
	 "taskName" TEXT,
	 "billingUri" TEXT,
	 "billingName" TEXT,
	 "activityUri" TEXT,
	 "activityName" TEXT,
	 "comments" TEXT,
	 "time_in" TEXT,
	 "time_out" TEXT,
	 "rowUri" TEXT,
	 "timesheetFormat" TEXT,
	 "entryTypeOrder" INTEGER,
	 "correlatedTimeOffUri" TEXT,
	 "clientUri" TEXT,
	 "clientName" TEXT,
	 "startDateAllowedTime" DATETIME,
	 "endDateAllowedTime" DATETIME,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "programName" TEXT,
	 "programUri" TEXT,
	 "isModified" INTEGER DEFAULT 0,
	 "isDeleted" INTEGER DEFAULT 0,
	 "clientPunchId" TEXT,
	 "rowNumber" TEXT,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimeOffApprovalHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimeOffApprovalHistory";
CREATE TABLE "PendingApprovalTimeOffApprovalHistory" (
	 "timeoffUri" VARCHAR NOT NULL,
	 "actionUri" VARCHAR NOT NULL,
	 "timestamp" DATETIME NOT NULL, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("timeoffUri") REFERENCES "PendingApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimeOffs"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimeOffs";
CREATE TABLE "PendingApprovalTimeOffs" (
	 "startDate" DATETIME,
	 "endDate" DATETIME,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "approvalStatus" VARCHAR,
	 "totalTimeoffDays" VARCHAR,
	 "timeoffUri" VARCHAR NOT NULL,
	 "timeoffTypeName" VARCHAR,
	 "timeoffTypeUri" VARCHAR,
	 "approval_dueDate" DATETIME,
	 "approval_dueDateText" VARCHAR,
	 "username" VARCHAR,
	 "userUri" VARCHAR,
	 "dueDate" DATETIME, "timeOffDisplayFormatUri" VARCHAR,
	PRIMARY KEY("timeoffUri")
);

-- ----------------------------
--  Table structure for "PendingApprovalTimeoffCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimeoffCustomFields";
CREATE TABLE "PendingApprovalTimeoffCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "timeoffUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	FOREIGN KEY ("timeoffUri") REFERENCES "PendingApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimeoffEntries"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimeoffEntries";
CREATE TABLE "PendingApprovalTimeoffEntries" (
	 "startDate" DATETIME,
	 "endDate" DATETIME,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "approvalStatus" VARCHAR,
	 "totalTimeoffDays" VARCHAR,
	 "timeoffUri" VARCHAR NOT NULL,
	 "timeoffTypeName" VARCHAR,
	 "timeoffTypeUri" VARCHAR,
	 "shiftDurationDecimal" DOUBLE,
	 "shiftDurationHour" VARCHAR,
	 "comments" VARCHAR,
	 "endDateDurationDecimal" DOUBLE,
	 "endDateDurationHour" VARCHAR,
	 "endDateTime" VARCHAR,
	 "startDateDurationDecimal" DOUBLE,
	 "startDateDurationHour" VARCHAR,
	 "startDateTime" VARCHAR,
	 "balancesDurationDecimal" DOUBLE,
	 "balancesDurationHour" VARCHAR,
	 "balancesDurationDays" VARCHAR,
	 "endEntryDurationUri" VARCHAR,
	 "startEntryDurationUri" VARCHAR,
	 "hasTimeOffEditAcess" NUMERIC,
	 "hasTimeOffDeletetAcess" NUMERIC,
	 "timeOffDisplayFormatUri" VARCHAR, "isDeviceSupportedEntryConfiguration" NUMERIC,
	FOREIGN KEY ("timeoffUri") REFERENCES "PendingApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetActivitySummary"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetActivitySummary";
CREATE TABLE "PendingApprovalTimesheetActivitySummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "activityUri" VARCHAR,
	 "activityName" VARCHAR,
	 "activityDurationDecimal" DOUBLE,
	 "activityDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetApproverHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetApproverHistory";
CREATE TABLE "PendingApprovalTimesheetApproverHistory" (
	 "timesheetUri" VARCHAR,
	 "actionStatus" VARCHAR,
	 "actionDate" DATETIME,
	 "actionUri" VARCHAR, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetBillingSummary"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetBillingSummary";
CREATE TABLE "PendingApprovalTimesheetBillingSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "billingUri" VARCHAR,
	 "billingName" VARCHAR,
	 "billingDurationDecimal" DOUBLE,
	 "billingDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetCustomFields";
CREATE TABLE "PendingApprovalTimesheetCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "timesheetUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	 "timesheetEntryDate" DATETIME,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetDaySummary"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetDaySummary";
CREATE TABLE "PendingApprovalTimesheetDaySummary" (
	 "timesheetUri" VARCHAR,
	 "timesheetEntryUri" VARCHAR,
	 "timesheetEntryDate" DATETIME,
	 "timesheetEntryTotalDurationDecimal" DOUBLE,
	 "timesheetEntryTotalDurationHour" VARCHAR,
	 "hasComments" NUMERIC,
	 "isHolidayDayOff" NUMERIC,
	 "isWeeklyDayOff" NUMERIC,
	 "timeOffDurationDecimal" DOUBLE,
	 "timeOffDurationHour" VARCHAR,
	 "workingTimeDurationDecimal" DOUBLE,
	 "workingTimeDurationHour" VARCHAR,
	 "noticeExplicitlyAccepted" NUMERIC,
	 "isCommentsRequired" NUMERIC,
	 "availableTimeOffTypeCount" NUMERIC,
	 "totalPunchTimeDurationDecimal" DOUBLE,
	 "totalInOutTimeDurationDecimal" DOUBLE,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetPayrollSummary"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetPayrollSummary";
CREATE TABLE "PendingApprovalTimesheetPayrollSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "payrollUri" VARCHAR NOT NULL,
	 "payrollName" VARCHAR,
	 "payrollDurationDecimal" DOUBLE,
	 "payrollDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheetProjectSummary"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheetProjectSummary";
CREATE TABLE "PendingApprovalTimesheetProjectSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "projectUri" VARCHAR,
	 "projectName" VARCHAR,
	 "projectDurationDecimal" DOUBLE,
	 "projectDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalTimesheets"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalTimesheets";
CREATE TABLE "PendingApprovalTimesheets" (
	 "approvalStatus" VARCHAR,
	 "approval_dueDate" DATETIME,
	 "approval_dueDateText" VARCHAR,
	 "username" VARCHAR,
	 "userUri" VARCHAR,
	 "timesheetUri" VARCHAR NOT NULL,
	 "timesheetPeriod" VARCHAR,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "overtimeDurationDecimal" DOUBLE,
	 "overtimeDurationHour" VARCHAR,
	 "timeoffDurationDecimal" DOUBLE,
	 "timeoffDurationHour" VARCHAR,
	 "regularDurationDecimal" DOUBLE,
	 "regularDurationHour" VARCHAR,
	 "mealBreakPenalties" INTEGER,
	 "dueDate" DATETIME,
	 "timesheetFormat" VARCHAR,
	 "canEditTimesheet" NUMERIC,
	 "startDate" DATETIME,
	 "endDate" DATETIME, "projectDurationHour" VARCHAR, "projectDurationDecimal" DOUBLE,
	PRIMARY KEY("timesheetUri")
);

-- ----------------------------
--  Table structure for "PendingApprovalsExpenseCapabilities"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalsExpenseCapabilities";
CREATE TABLE "PendingApprovalsExpenseCapabilities" (
	 "hasExpenseBillClient" NUMERIC,
	 "hasExpensePaymentMethod" NUMERIC,
	 "hasExpenseReimbursements" NUMERIC,
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "hasExpenseReceiptView" NUMERIC,
	 "expenseEntryAgainstProjectsAllowed" NUMERIC,
	 "expenseEntryAgainstProjectsRequired" NUMERIC,
	 "hasExpensesClientAccess" NUMERIC,
	 "disclaimerExpenseNoticePolicyUri" VARCHAR,
	 "canEditTask" NUMERIC,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PendingApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingApprovalsTimesheetCapabilities"
-- ----------------------------
DROP TABLE IF EXISTS "PendingApprovalsTimesheetCapabilities";
CREATE TABLE "PendingApprovalsTimesheetCapabilities" ("hasTimesheetBillingAccess" NUMERIC,"hasTimesheetProjectAccess" NUMERIC,"hasTimesheetActivityAccess" NUMERIC,"timesheetUri" VARCHAR NOT NULL ,"disclaimerTimesheetNoticePolicyUri" VARCHAR,"hasTimesheetClientAccess" NUMERIC,"hasTimesheetBreakAccess" NUMERIC,"hasTimepunchBreakAccess" NUMERIC, "hasTimesheetProgramAccess" NUMERIC);

-- ----------------------------
--  Table structure for "PendingEnabledWidgets"
-- ----------------------------
DROP TABLE IF EXISTS "PendingEnabledWidgets";
CREATE TABLE "PendingEnabledWidgets" (
	 "widgetUri" text NOT NULL,
	 "timesheetUri" text NOT NULL,
	 "orderNo" NUMERIC,
	 "supportedInMobile" NUMERIC,
	 "enabled" NUMERIC,
	 "widgetTitle" text,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PendingExpenseCodeDetails"
-- ----------------------------
DROP TABLE IF EXISTS "PendingExpenseCodeDetails";
CREATE TABLE "PendingExpenseCodeDetails" (
	 "expenseCodeName" VARCHAR,
	 "expenseCodeUri" VARCHAR NOT NULL,
	 "expenseCodeType" VARCHAR,
	 "expenseCodeUnitName" VARCHAR,
	 "expenseCodeRate" VARCHAR,
	 "expenseCodeCurrencyUri" VARCHAR,
	 "expenseCodeCurrencyName" VARCHAR,
	 "taxAmount1" VARCHAR,
	 "taxAmount2" VARCHAR,
	 "taxAmount3" VARCHAR,
	 "taxAmount4" VARCHAR,
	 "taxAmount5" VARCHAR,
	 "expenseEntryUri" VARCHAR NOT NULL,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "ExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PendingExpenseTaxCodes"
-- ----------------------------
DROP TABLE IF EXISTS "PendingExpenseTaxCodes";
CREATE TABLE "PendingExpenseTaxCodes" (
	 "name" VARCHAR,
	 "uri" VARCHAR NOT NULL,
	 "taxAmount" VARCHAR,
	 "id" NUMERIC NOT NULL,
	 "expenseEntryUri" VARCHAR NOT NULL,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "ExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalDisclaimer"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalDisclaimer";
CREATE TABLE PreviousApprovalDisclaimer ( "description" VARCHAR, "title" VARCHAR, "module" VARCHAR);

-- ----------------------------
--  Table structure for "PreviousApprovalExpenseCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalExpenseCustomFields";
CREATE TABLE "PreviousApprovalExpenseCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "expenseSheetUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PreviousApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalExpenseEntries"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalExpenseEntries";
CREATE TABLE "PreviousApprovalExpenseEntries" ("expenseSheetUri" VARCHAR,"expenseEntryUri" VARCHAR PRIMARY KEY  NOT NULL ,"approvalStatus" VARCHAR,"expenseEntryDescription" VARCHAR,"billingUri" VARCHAR,"expenseCodeUri" VARCHAR,"expenseCodeName" VARCHAR,"expenseReceiptName" VARCHAR,"expenseReceiptUri" VARCHAR,"incurredAmountNetCurrencyName" VARCHAR,"incurredAmountNetCurrencyUri" VARCHAR,"incurredAmountNet" VARCHAR,"incurredAmountTotalCurrencyName" VARCHAR,"incurredAmountTotalCurrencyUri" VARCHAR,"incurredAmountTotal" VARCHAR,"incurredDate" DATETIME,"paymentMethodName" VARCHAR,"paymentMethodUri" VARCHAR,"projectUri" VARCHAR,"projectName" VARCHAR,"taskName" VARCHAR,"taskUri" VARCHAR,"reimbursementUri" VARCHAR,"quantity" VARCHAR,"rateAmount" VARCHAR,"rateCurrencyName" VARCHAR,"rateCurrencyUri" VARCHAR,"taxAmount1" VARCHAR,"taxAmount2" VARCHAR,"taxAmount3" VARCHAR,"taxAmount4" VARCHAR,"taxAmount5" VARCHAR,"taxCurrencyName1" VARCHAR,"taxCurrencyName2" VARCHAR,"taxCurrencyName3" VARCHAR,"taxCurrencyName4" VARCHAR,"taxCurrencyName5" VARCHAR,"taxCurrencyUri1" VARCHAR,"taxCurrencyUri2" VARCHAR,"taxCurrencyUri3" VARCHAR,"taxCurrencyUri4" VARCHAR,"taxCurrencyUri5" VARCHAR,"taxCodeUri1" VARCHAR,"taxCodeUri2" VARCHAR,"taxCodeUri3" VARCHAR,"taxCodeUri4" VARCHAR,"taxCodeUri5" VARCHAR,"noticeExplicitlyAccepted" NUMERIC NOT NULL ,"clientName" VARCHAR, "clientUri" VARCHAR);

-- ----------------------------
--  Table structure for "PreviousApprovalExpenseIncurredAmountTax"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalExpenseIncurredAmountTax";
CREATE TABLE "PreviousApprovalExpenseIncurredAmountTax" (
	 "expenseEntryUri" VARCHAR,
	 "currencyName" VARCHAR,
	 "currencyUri" VARCHAR,
	 "taxCodeName" VARCHAR,
	 "taxCodeUri" VARCHAR,
	 "amount" VARCHAR,
	FOREIGN KEY ("expenseEntryUri") REFERENCES "PreviousApprovalExpenseEntries" ("expenseEntryUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalExpenseSheetApprovalHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalExpenseSheetApprovalHistory";
CREATE TABLE "PreviousApprovalExpenseSheetApprovalHistory" (
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "actionUri" VARCHAR NOT NULL,
	 "timestamp" DATETIME NOT NULL, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PreviousApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalExpensesheets"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalExpensesheets";
CREATE TABLE "PreviousApprovalExpensesheets" (
	 "approvalStatus" VARCHAR,
	 "approval_dueDate" DATETIME,
	 "approval_dueDateText" VARCHAR,
	 "username" VARCHAR,
	 "userUri" VARCHAR,
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "expenseDate" DATETIME,
	 "reimbursementAmountCurrencyName" VARCHAR,
	 "reimbursementAmountCurrencyUri" VARCHAR,
	 "reimbursementAmount" VARCHAR,
	 "description" VARCHAR,
	 "incurredAmountCurrencyName" VARCHAR,
	 "incurredAmountCurrencyUri" VARCHAR,
	 "incurredAmount" VARCHAR,
	 "trackingNumber" VARCHAR,
	PRIMARY KEY("expenseSheetUri")
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimeEntries"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimeEntries";
CREATE TABLE "PreviousApprovalTimeEntries" (
	 "timesheetUri" TEXT NOT NULL,
	 "timePunchesUri" TEXT,
	 "timeAllocationUri" TEXT,
	 "timeOffUri" TEXT,
	 "timeOffTypeName" TEXT,
	 "entryType" TEXT,
	 "timesheetEntryDate" DATETIME,
	 "durationHourFormat" TEXT,
	 "durationDecimalFormat" TEXT,
	 "projectUri" TEXT,
	 "projectName" TEXT,
	 "taskUri" TEXT,
	 "taskName" TEXT,
	 "billingUri" TEXT,
	 "billingName" TEXT,
	 "activityUri" TEXT,
	 "activityName" TEXT,
	 "comments" TEXT,
	 "time_in" TEXT,
	 "time_out" TEXT,
	 "rowUri" TEXT,
	 "timesheetFormat" TEXT,
	 "entryTypeOrder" INTEGER,
	 "correlatedTimeOffUri" TEXT,
	 "clientUri" TEXT,
	 "clientName" TEXT,
	 "startDateAllowedTime" DATETIME,
	 "endDateAllowedTime" DATETIME,
	 "breakUri" VARCHAR,
	 "breakName" VARCHAR,
	 "programName" TEXT,
	 "programUri" TEXT,
	 "isModified" INTEGER DEFAULT 0,
	 "isDeleted" INTEGER DEFAULT 0,
	 "clientPunchId" TEXT,
	 "rowNumber" TEXT,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimeOffApprovalHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimeOffApprovalHistory";
CREATE TABLE "PreviousApprovalTimeOffApprovalHistory" (
	 "timeoffUri" VARCHAR NOT NULL,
	 "actionUri" VARCHAR NOT NULL,
	 "timestamp" DATETIME NOT NULL, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("timeoffUri") REFERENCES "PreviousApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimeOffs"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimeOffs";
CREATE TABLE "PreviousApprovalTimeOffs" (
	 "startDate" DATETIME,
	 "endDate" DATETIME,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "approvalStatus" VARCHAR,
	 "totalTimeoffDays" VARCHAR,
	 "timeoffUri" VARCHAR NOT NULL,
	 "timeoffTypeName" VARCHAR,
	 "timeoffTypeUri" VARCHAR,
	 "approval_dueDate" DATETIME,
	 "approval_dueDateText" VARCHAR,
	 "username" VARCHAR,
	 "userUri" VARCHAR,
	 "dueDate" DATETIME, "timeOffDisplayFormatUri" VARCHAR,
	PRIMARY KEY("timeoffUri")
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimeoffCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimeoffCustomFields";
CREATE TABLE "PreviousApprovalTimeoffCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "timeoffUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	FOREIGN KEY ("timeoffUri") REFERENCES "PreviousApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimeoffEntries"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimeoffEntries";
CREATE TABLE "PreviousApprovalTimeoffEntries" (
	 "startDate" DATETIME,
	 "endDate" DATETIME,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "approvalStatus" VARCHAR,
	 "totalTimeoffDays" VARCHAR,
	 "timeoffUri" VARCHAR NOT NULL,
	 "timeoffTypeName" VARCHAR,
	 "timeoffTypeUri" VARCHAR,
	 "shiftDurationDecimal" DOUBLE,
	 "shiftDurationHour" VARCHAR,
	 "comments" VARCHAR,
	 "endDateDurationDecimal" DOUBLE,
	 "endDateDurationHour" VARCHAR,
	 "endDateTime" VARCHAR,
	 "startDateDurationDecimal" DOUBLE,
	 "startDateDurationHour" VARCHAR,
	 "startDateTime" VARCHAR,
	 "balancesDurationDecimal" DOUBLE,
	 "balancesDurationHour" VARCHAR,
	 "balancesDurationDays" VARCHAR,
	 "endEntryDurationUri" VARCHAR,
	 "startEntryDurationUri" VARCHAR,
	 "hasTimeOffEditAcess" NUMERIC,
	 "hasTimeOffDeletetAcess" NUMERIC,
	 "timeOffDisplayFormatUri" VARCHAR, "isDeviceSupportedEntryConfiguration" NUMERIC,
	FOREIGN KEY ("timeoffUri") REFERENCES "PreviousApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetActivitySummary"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetActivitySummary";
CREATE TABLE "PreviousApprovalTimesheetActivitySummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "activityUri" VARCHAR,
	 "activityName" VARCHAR,
	 "activityDurationDecimal" DOUBLE,
	 "activityDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetApproverHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetApproverHistory";
CREATE TABLE "PreviousApprovalTimesheetApproverHistory" (
	 "timesheetUri" VARCHAR,
	 "actionStatus" VARCHAR,
	 "actionDate" DATETIME,
	 "actionUri" VARCHAR, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetBillingSummary"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetBillingSummary";
CREATE TABLE "PreviousApprovalTimesheetBillingSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "billingUri" VARCHAR,
	 "billingName" VARCHAR,
	 "billingDurationDecimal" DOUBLE,
	 "billingDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetCustomFields";
CREATE TABLE "PreviousApprovalTimesheetCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "timesheetUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	 "timesheetEntryDate" DATETIME,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetDaySummary"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetDaySummary";
CREATE TABLE "PreviousApprovalTimesheetDaySummary" (
	 "timesheetUri" VARCHAR,
	 "timesheetEntryUri" VARCHAR,
	 "timesheetEntryDate" DATETIME,
	 "timesheetEntryTotalDurationDecimal" DOUBLE,
	 "timesheetEntryTotalDurationHour" VARCHAR,
	 "hasComments" NUMERIC,
	 "isHolidayDayOff" NUMERIC,
	 "isWeeklyDayOff" NUMERIC,
	 "timeOffDurationDecimal" DOUBLE,
	 "timeOffDurationHour" VARCHAR,
	 "workingTimeDurationDecimal" DOUBLE,
	 "workingTimeDurationHour" VARCHAR,
	 "noticeExplicitlyAccepted" NUMERIC,
	 "isCommentsRequired" NUMERIC,
	 "availableTimeOffTypeCount" NUMERIC,
	 "totalPunchTimeDurationDecimal" DOUBLE,
	 "totalInOutTimeDurationDecimal" DOUBLE,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetPayrollSummary"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetPayrollSummary";
CREATE TABLE "PreviousApprovalTimesheetPayrollSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "payrollUri" VARCHAR NOT NULL,
	 "payrollName" VARCHAR,
	 "payrollDurationDecimal" DOUBLE,
	 "payrollDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheetProjectSummary"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheetProjectSummary";
CREATE TABLE "PreviousApprovalTimesheetProjectSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "projectUri" VARCHAR,
	 "projectName" VARCHAR,
	 "projectDurationDecimal" DOUBLE,
	 "projectDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalTimesheets"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalTimesheets";
CREATE TABLE "PreviousApprovalTimesheets" (
	 "approvalStatus" VARCHAR,
	 "approval_dueDate" DATETIME,
	 "approval_dueDateText" VARCHAR,
	 "username" VARCHAR,
	 "userUri" VARCHAR,
	 "timesheetUri" VARCHAR NOT NULL,
	 "timesheetPeriod" VARCHAR,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "overtimeDurationDecimal" DOUBLE,
	 "overtimeDurationHour" VARCHAR,
	 "timeoffDurationDecimal" DOUBLE,
	 "timeoffDurationHour" VARCHAR,
	 "regularDurationDecimal" DOUBLE,
	 "regularDurationHour" VARCHAR,
	 "mealBreakPenalties" INTEGER,
	 "dueDate" DATETIME,
	 "startDate" DATETIME,
	 "endDate" DATETIME,
	 "timesheetFormat" VARCHAR,
	 "canEditTimesheet" NUMERIC,
	 "isFromViewTeamTime" NUMERIC DEFAULT 0, "projectDurationDecimal" DOUBLE, "projectDurationHour" VARCHAR,
	PRIMARY KEY("timesheetUri")
);

-- ----------------------------
--  Table structure for "PreviousApprovalsExpenseCapabilities"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalsExpenseCapabilities";
CREATE TABLE "PreviousApprovalsExpenseCapabilities" (
	 "hasExpenseBillClient" NUMERIC,
	 "hasExpensePaymentMethod" NUMERIC,
	 "hasExpenseReimbursements" NUMERIC,
	 "expenseSheetUri" VARCHAR NOT NULL,
	 "hasExpenseReceiptView" NUMERIC,
	 "expenseEntryAgainstProjectsAllowed" NUMERIC,
	 "expenseEntryAgainstProjectsRequired" NUMERIC,
	 "hasExpensesClientAccess" NUMERIC,
	 "disclaimerExpenseNoticePolicyUri" VARCHAR,
	 "canEditTask" NUMERIC,
	FOREIGN KEY ("expenseSheetUri") REFERENCES "PreviousApprovalExpensesheets" ("expenseSheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "PreviousApprovalsTimesheetCapabilities"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousApprovalsTimesheetCapabilities";
CREATE TABLE "PreviousApprovalsTimesheetCapabilities" ("hasTimesheetBillingAccess" NUMERIC,"hasTimesheetProjectAccess" NUMERIC,"hasTimesheetActivityAccess" NUMERIC,"timesheetUri" VARCHAR NOT NULL ,"disclaimerTimesheetNoticePolicyUri" VARCHAR,"hasTimesheetClientAccess" NUMERIC,"hasTimesheetBreakAccess" NUMERIC,"hasTimepunchBreakAccess" NUMERIC, "hasTimesheetProgramAccess" NUMERIC);

-- ----------------------------
--  Table structure for "PreviousEnabledWidgets"
-- ----------------------------
DROP TABLE IF EXISTS "PreviousEnabledWidgets";
CREATE TABLE "PreviousEnabledWidgets" (
	 "widgetUri" text NOT NULL,
	 "timesheetUri" text NOT NULL,
	 "orderNo" NUMERIC,
	 "supportedInMobile" NUMERIC,
	 "enabled" NUMERIC,
	 "widgetTitle" text,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "Programs"
-- ----------------------------
DROP TABLE IF EXISTS "Programs";
CREATE TABLE "Programs" ("programName" VARCHAR, "programUri" VARCHAR,"moduleName" VARCHAR, "program_Name" VARCHAR);

-- ----------------------------
--  Table structure for "Projects"
-- ----------------------------
DROP TABLE IF EXISTS "Projects";
CREATE TABLE "Projects" ("projectName" VARCHAR, "projectUri" VARCHAR, "clientName" VARCHAR, "clientUri" VARCHAR, "startDate" DATETIME, "endDate" DATETIME, "isTimeAllocationAllowed" NUMERIC, "hasTasksAvailableForTimeAllocation" NUMERIC, "moduleName" VARCHAR, "project_Name" VARCHAR, "programName" VARCHAR, "programUri" VARCHAR);

-- ----------------------------
--  Table structure for "PunchHistory"
-- ----------------------------
DROP TABLE IF EXISTS "PunchHistory";
CREATE TABLE "PunchHistory" (
	 "punchInUri" VARCHAR,
	 "punchOutUri" VARCHAR,
	 "PunchInTime" VARCHAR,
	 "PunchOutTime" VARCHAR,
	 "totalHours" VARCHAR,
	 "PunchInDateTimestamp" DATETIME,
	 "PunchInDate" VARCHAR,
	 "PunchOutDateTimestamp" DATETIME,
	 "PunchOutDate" VARCHAR,
	 "PunchInLatitude" VARCHAR,
	 "PunchInLongitude" VARCHAR,
	 "PunchInAddress" VARCHAR,
	 "PunchOutLatitude" VARCHAR,
	 "PunchOutLongitude" VARCHAR,
	 "PunchOutAddress" VARCHAR,
	 "punchInFullSizeImageLink" VARCHAR,
	 "punchInFullSizeImageUri" VARCHAR,
	 "punchInThumbnailSizeImageLink" VARCHAR,
	 "punchInThumbnailSizeImageUri" VARCHAR,
	 "punchOutFullSizeImageLink" VARCHAR,
	 "punchOutFullSizeImageUri" VARCHAR,
	 "punchOutThumbnailSizeImageLink" VARCHAR,
	 "punchOutThumbnailSizeImageUri" VARCHAR,
	 "punchUserName" VARCHAR,
	 "punchUserUri" VARCHAR,
	 "punchInAgent" VARCHAR,
	 "punchOutAgent" VARCHAR,
	 "activityName" VARCHAR,
	 "activityUri" VARCHAR,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "timesheetTransferStatus" VARCHAR,
	 "canTransferTimePunchToTimesheet" NUMERIC,
	 "canEditTimePunch" NUMERIC,
	 "cloudClockInUri" VARCHAR,
	 "cloudClockOutUri" VARCHAR,
	 "punchInAgentUri" VARCHAR,
	 "punchOutAgentUri" VARCHAR,
	 "punchInaccuracyInMeters" VARCHAR,
	 "punchOutaccuracyInMeters" VARCHAR,
	 "startPunchLastModificationTypeUri" VARCHAR,
	 "endPunchLastModificationTypeUri" VARCHAR,
	 "punchInActionUri" VARCHAR,
	 "punchOutActionUri" VARCHAR
);

-- ----------------------------
--  Table structure for "Punches"
-- ----------------------------
DROP TABLE IF EXISTS "Punches";
CREATE TABLE "Punches" ("uniqueID" TEXT PRIMARY KEY  NOT NULL  DEFAULT (null) ,"in_time" TEXT DEFAULT (null) ,"out_time" TEXT DEFAULT (null) ,"project" TEXT DEFAULT (null) ,"task" TEXT DEFAULT (null) ,"activity" TEXT DEFAULT (null) ,"client" TEXT DEFAULT (null) ,"break" TEXT,"in_time_stamp" DATETIME DEFAULT (null) ,"entry_date" TEXT, "out_time_stamp" DATETIME,"userUri" TEXT DEFAULT (null) );

-- ----------------------------
--  Table structure for "PunchesAttendance"
-- ----------------------------
DROP TABLE IF EXISTS "PunchesAttendance";
CREATE TABLE "PunchesAttendance" (
	 "ATTENDANCE_uniqueID" TEXT NOT NULL DEFAULT (null),
	 "in_time" TEXT DEFAULT (null),
	 "out_time" TEXT DEFAULT (null),
	 "project" TEXT DEFAULT (null),
	 "task" TEXT DEFAULT (null),
	 "activity" TEXT DEFAULT (null),
	 "client" TEXT DEFAULT (null),
	 "break" TEXT,
	"projectUri" TEXT DEFAULT (null),
	 "taskUri" TEXT DEFAULT (null),
	 "activityUri" TEXT DEFAULT (null),
	 "clientUri" TEXT DEFAULT (null),
	 "breakUri" TEXT,
	 "in_time_stamp" DATETIME DEFAULT (null),
	 "entry_date" TEXT,
	 "out_time_stamp" DATETIME,
	 "userUri" TEXT DEFAULT (null),
	PRIMARY KEY("ATTENDANCE_uniqueID")
);

-- ----------------------------
--  Table structure for "ShiftDetails"
-- ----------------------------
DROP TABLE IF EXISTS "ShiftDetails";
CREATE TABLE "ShiftDetails" (
	 "id" TEXT,
	 "shiftUri" TEXT,
	 "shiftName" TEXT,
	 "TimeOffName" TEXT,
	 "type" TEXT,
	 "in_time" TEXT DEFAULT (null),
	 "out_time" TEXT DEFAULT (null),
	 "timeOffDayDuration" TEXT,
	 "approvalStatus" TEXT,
	 "timeOffUri" TEXT,
	 "colorCode" TEXT,
	 "note" TEXT,
	 "breakType" TEXT,
	 "breakUri" TEXT,
	 "date" DATETIME,
	 "shiftDuration" TEXT,
	 "holiday" TEXT,
	 "timeOffHourDuration" TEXT DEFAULT (null),
	 "in_time_stamp" DATETIME,
	 "out_time_stamp" DATETIME,
	 "holidayUri" VARCHAR,
	 "shiftIndex" TEXT,
	 "timeOffDisplayFormatUri" VARCHAR
);

-- ----------------------------
--  Table structure for "ShiftEntry"
-- ----------------------------
DROP TABLE IF EXISTS "ShiftEntry";
CREATE TABLE "ShiftEntry" (
	 "date" DATETIME DEFAULT (null),
	 "holiday" VARCHAR,
	 "uri" VARCHAR NOT NULL DEFAULT (null),
	 "shiftDuration" VARCHAR,
	 "shiftName" VARCHAR,
	 "type" VARCHAR,
	 "note" VARCHAR,
	 "color" VARCHAR,
	 "id" VARCHAR,
	 "timeOffName" TEXT,
	 "timeOffDayDuration" TEXT,
	 "startTime" VARCHAR DEFAULT (null),
	 "endTime" VARCHAR DEFAULT (null),
	 "timeOffApprovalStatus" VARCHAR,
	 "timeOffHourDuration" TEXT,
	 "in_time_stamp" DATETIME,
	 "out_time_stamp" DATETIME,
	 "timeOffDisplayFormatUri" VARCHAR
);

-- ----------------------------
--  Table structure for "ShiftObjectExtensionFields"
-- ----------------------------
DROP TABLE IF EXISTS "ShiftObjectExtensionFields";
CREATE TABLE "ShiftObjectExtensionFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "udfValue_uri" TEXT,
	 "udfValue" TEXT,
	 "shiftUri" TEXT,
	 "in_time_stamp" DATETIME,
	 "shiftIndex" TEXT
);

-- ----------------------------
--  Table structure for "Shifts"
-- ----------------------------
DROP TABLE IF EXISTS "Shifts";
CREATE TABLE "Shifts" ("id" TEXT PRIMARY KEY  NOT NULL ,"startDate" TEXT,"endDate" TEXT, "dateString" TEXT);

-- ----------------------------
--  Table structure for "SupportLogFile"
-- ----------------------------
DROP TABLE IF EXISTS "SupportLogFile";
CREATE TABLE "SupportLogFile" (
	 "LogFileID" text NOT NULL,
	 "logFile" blob,
	 "lastUpdatedTime" DATETIME,
	PRIMARY KEY("LogFileID")
);

-- ----------------------------
--  Table structure for "SystemCurrencies"
-- ----------------------------
DROP TABLE IF EXISTS "SystemCurrencies";
CREATE TABLE "SystemCurrencies" ("currenciesName" VARCHAR, "currenciesUri" VARCHAR);

-- ----------------------------
--  Table structure for "SystemPaymentMethods"
-- ----------------------------
DROP TABLE IF EXISTS "SystemPaymentMethods";
CREATE TABLE "SystemPaymentMethods" ("paymentMethodsName" VARCHAR, "paymentMethodsUri" VARCHAR);

-- ----------------------------
--  Table structure for "Tasks"
-- ----------------------------
DROP TABLE IF EXISTS "Tasks";
CREATE TABLE "Tasks" ("taskName" VARCHAR, "taskUri" VARCHAR, "taskFullPath" VARCHAR, "startDate" DATETIME, "endDate" DATETIME, "moduleName" VARCHAR);

-- ----------------------------
--  Table structure for "TeamTimePunches"
-- ----------------------------
DROP TABLE IF EXISTS "TeamTimePunches";
CREATE TABLE "TeamTimePunches" (
	 "punchInUri" VARCHAR,
	 "punchOutUri" VARCHAR,
	 "PunchInTime" VARCHAR,
	 "PunchOutTime" VARCHAR,
	 "totalHours" VARCHAR,
	 "PunchInDateTimestamp" DATETIME,
	 "PunchInDate" VARCHAR,
	 "PunchOutDateTimestamp" DATETIME,
	 "PunchOutDate" VARCHAR,
	 "PunchInLatitude" VARCHAR,
	 "PunchInLongitude" VARCHAR,
	 "PunchInAddress" VARCHAR,
	 "PunchOutLatitude" VARCHAR,
	 "PunchOutLongitude" VARCHAR,
	 "PunchOutAddress" VARCHAR,
	 "punchInFullSizeImageLink" VARCHAR,
	 "punchInFullSizeImageUri" VARCHAR,
	 "punchInThumbnailSizeImageLink" VARCHAR,
	 "punchInThumbnailSizeImageUri" VARCHAR,
	 "punchOutFullSizeImageLink" VARCHAR,
	 "punchOutFullSizeImageUri" VARCHAR,
	 "punchOutThumbnailSizeImageLink" VARCHAR,
	 "punchOutThumbnailSizeImageUri" VARCHAR,
	 "punchUserName" VARCHAR,
	 "punchUserUri" VARCHAR,
	 "punchInAgent" VARCHAR,
	 "punchOutAgent" VARCHAR,
	 "activityName" VARCHAR,
	 "activityUri" VARCHAR,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "timesheetTransferStatus" VARCHAR,
	 "cloudClockInUri" VARCHAR,
	 "cloudClockOutUri" VARCHAR,
	 "punchInAgentUri" VARCHAR,
	 "punchOutAgentUri" VARCHAR,
	 "punchInaccuracyInMeters" VARCHAR,
	 "punchOutaccuracyInMeters" VARCHAR,
	 "startPunchLastModificationTypeUri" VARCHAR,
	 "endPunchLastModificationTypeUri" VARCHAR,
	 "punchInActionUri" VARCHAR,
	 "punchOutActionUri" VARCHAR
);

-- ----------------------------
--  Table structure for "TeamTimeUserCapabilities"
-- ----------------------------
DROP TABLE IF EXISTS "TeamTimeUserCapabilities";
CREATE TABLE "TeamTimeUserCapabilities" (
	 "uri" VARCHAR,
	 "activitySelectionRequired" NUMERIC,
	 "auditImageRequired" NUMERIC,
	 "canEditTimePunch" NUMERIC,
	 "geolocationRequired" NUMERIC,
	 "hasActivityAccess" NUMERIC,
	 "hasBillingAccess" NUMERIC,
	 "hasBreakAccess" NUMERIC,
	 "hasClientAccess" NUMERIC,
	 "hasProjectAccess" NUMERIC,
	 "hasTimePunchAccess" NUMERIC,
	 "projectTaskSelectionRequired" NUMERIC,
"canTransferTimePunchToTimesheet" NUMERIC
);

-- ----------------------------
--  Table structure for "TimeEntriesObjectExtensionFields"
-- ----------------------------
DROP TABLE IF EXISTS "TimeEntriesObjectExtensionFields";
CREATE TABLE "TimeEntriesObjectExtensionFields" (
	 "timeEntryUri" TEXT,
	 "uri" TEXT,
	 "definitionTypeUri" TEXT,
	 "numericValue" DOUBLE,
	 "textValue" TEXT,
	 "dropdownOptionUri" TEXT,
	 "dropdownOptionValue" TEXT,
	 "timesheetUri" TEXT
);

-- ----------------------------
--  Table structure for "TimeOffApprovalHistory"
-- ----------------------------
DROP TABLE IF EXISTS "TimeOffApprovalHistory";
CREATE TABLE "TimeOffApprovalHistory" (
	 "timeoffUri" VARCHAR NOT NULL,
	 "actionUri" VARCHAR NOT NULL,
	 "timestamp" DATETIME NOT NULL, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("timeoffUri") REFERENCES "Timeoff" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "TimeOffBalanceSummaryMultiDayBooking"
-- ----------------------------
DROP TABLE IF EXISTS "TimeOffBalanceSummaryMultiDayBooking";
CREATE TABLE "TimeOffBalanceSummaryMultiDayBooking" ("timeOffURI" VARCHAR NOT NULL, "timeOffDisplayFormatUri" VARCHAR, "balanceTotalDays" VARCHAR, "requestedDays" VARCHAR, "balanceRemainingHours" VARCHAR, "requestedHours" VARCHAR, "balanceRemainingDays" VARCHAR);

-- ----------------------------
--  Table structure for "TimeSheetPermittedApprovalActions"
-- ----------------------------
DROP TABLE IF EXISTS "TimeSheetPermittedApprovalActions";
CREATE TABLE "TimeSheetPermittedApprovalActions" (
	 "uri" VARCHAR NOT NULL,
	 "canApproveReject" NUMERIC,
	 "canForceApproveReject" NUMERIC,
	 "canReopen" NUMERIC,
	 "canSubmit" NUMERIC,
	 "canUnsubmit" NUMERIC,
	 "module" VARCHAR,
	 "allowBreakForInOutGen4" NUMERIC,
	 "allowTimeEntryCommentsForInOutGen4" NUMERIC,
	 "allowTimeEntryEditForInOutGen4" NUMERIC,
	 "allowReopenForGen4" NUMERIC,
	 "alowReopenAfterApprovalForGen4" NUMERIC,
	 "allowResubmitWithBlankCommentsForGen4" NUMERIC,
	 "allowTimeoffForGen4" NUMERIC,
	 "allowBreakForPunchInGen4" NUMERIC,
	 "allowClientsForStandardGen4" NUMERIC,
	 "allowProgramsForStandardGen4" NUMERIC,
	 "allowProjectsTasksForStandardGen4" NUMERIC,
	 "allowActivitiesForStandardGen4" NUMERIC,
	 "allowBillingForStandardGen4" NUMERIC,
	 "allowCommentsForStandardGen4" NUMERIC,
	 "allowTimeEntryEditForStandardGen4" NUMERIC,
	 "allowBreakForStandardGen4" NUMERIC,
	 "allowBreakForExtInOutGen4" NUMERIC,
	 "allowTimeEntryCommentsForExtInOutGen4" NUMERIC,
	 "allowClientsForExtInOutGen4" NUMERIC,
	 "allowProgramsForExtInOutGen4" NUMERIC,
	 "allowProjectsTasksForExtInOutGen4" NUMERIC,
	 "allowActivitiesForExtInOutGen4" NUMERIC,
	 "allowBillingForExtInOutGen4" NUMERIC,
	 "allowTimeEntryEditForExtInOutGen4" NUMERIC
);

-- ----------------------------
--  Table structure for "Time_entries"
-- ----------------------------
DROP TABLE IF EXISTS "Time_entries";
CREATE TABLE "Time_entries" (
	 "timesheetUri" TEXT NOT NULL,
	 "timePunchesUri" TEXT,
	 "timeAllocationUri" TEXT,
	 "timeOffUri" TEXT,
	 "timeOffTypeName" TEXT,
	 "entryType" TEXT,
	 "timesheetEntryDate" DATETIME,
	 "durationHourFormat" TEXT,
	 "durationDecimalFormat" TEXT,
	 "projectUri" TEXT,
	 "projectName" TEXT,
	 "taskUri" TEXT,
	 "taskName" TEXT,
	 "billingUri" TEXT,
	 "billingName" TEXT,
	 "activityUri" TEXT,
	 "activityName" TEXT,
	 "comments" TEXT,
	 "time_in" TEXT,
	 "time_out" TEXT,
	 "rowUri" TEXT,
	 "timesheetFormat" TEXT,
	 "entryTypeOrder" INTEGER,
	 "correlatedTimeOffUri" TEXT,
	 "clientUri" TEXT,
	 "clientName" TEXT,
	 "startDateAllowedTime" DATETIME,
	 "endDateAllowedTime" DATETIME,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "clientPunchId" TEXT,
	 "programName" TEXT,
	 "programUri" TEXT,
	 "isModified" INTEGER DEFAULT 0,
	 "isDeleted" INTEGER DEFAULT 0,
	 "rowNumber" TEXT,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "Timeoff"
-- ----------------------------
DROP TABLE IF EXISTS "Timeoff";
CREATE TABLE "Timeoff" ("startDate" DATETIME, "endDate" DATETIME, "totalDurationDecimal" DOUBLE, "totalDurationHour" VARCHAR, "approvalStatus" VARCHAR, "totalTimeoffDays" VARCHAR, "timeoffUri" VARCHAR PRIMARY KEY NOT NULL, "timeoffTypeName" VARCHAR, "timeoffTypeUri" VARCHAR, "shiftDurationDecimal" DOUBLE, "shiftDurationHour" VARCHAR, "comments" VARCHAR, "endDateDurationDecimal" DOUBLE, "endDateDurationHour" VARCHAR, "endDateTime" VARCHAR, "startDateDurationDecimal" DOUBLE, "startDateDurationHour" VARCHAR, "startDateTime" VARCHAR, "balancesDurationDecimal" DOUBLE, "balancesDurationHour" VARCHAR, "balancesDurationDays" VARCHAR, "endEntryDurationUri" VARCHAR, "startEntryDurationUri" VARCHAR, "hasTimeOffEditAcess" NUMERIC, "hasTimeOffDeletetAcess" NUMERIC, "timesheetUri" VARCHAR, "timeOffDisplayFormatUri" VARCHAR, "isDeviceSupportedEntryConfiguration" NUMERIC);

-- ----------------------------
--  Table structure for "TimeoffCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "TimeoffCustomFields";
CREATE TABLE "TimeoffCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "timeoffUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	FOREIGN KEY ("timeoffUri") REFERENCES "Timeoff" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "TimeoffTypeBalanceSummary"
-- ----------------------------
DROP TABLE IF EXISTS "TimeoffTypeBalanceSummary";
CREATE TABLE "TimeoffTypeBalanceSummary" ( "timeOffTypeName" VARCHAR, "timeOffTypeUri" VARCHAR,"timeTrackingOptionUri" VARCHAR, "timeTakenOrRemainingDurationHour" VARCHAR, "timeTakenOrRemainingDurationDecimal" DOUBLE, "timeTakenOrRemainingDurationDays" VARCHAR, "timeOffDisplayFormatUri" VARCHAR);

-- ----------------------------
--  Table structure for "TimeoffTypes"
-- ----------------------------
DROP TABLE IF EXISTS "TimeoffTypes";
CREATE TABLE "TimeoffTypes" (
	 "timeoffTypeName" VARCHAR,
	 "timeoffTypeUri" VARCHAR NOT NULL,
	PRIMARY KEY("timeoffTypeUri")
);

-- ----------------------------
--  Table structure for "TimesheetActivitySummary"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetActivitySummary";
CREATE TABLE "TimesheetActivitySummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "activityUri" VARCHAR,
	 "activityName" VARCHAR,
	 "activityDurationDecimal" DOUBLE,
	 "activityDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetApproverHistory"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetApproverHistory";
CREATE TABLE "TimesheetApproverHistory" (
	 "timesheetUri" VARCHAR,
	 "actionStatus" VARCHAR,
	 "actionDate" DATETIME,
	 "actionUri" VARCHAR, "actingForUser" VARCHAR, "actingUser" VARCHAR, "comments" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetBillingSummary"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetBillingSummary";
CREATE TABLE "TimesheetBillingSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "billingUri" VARCHAR ,
	 "billingName" VARCHAR,
	 "billingDurationDecimal" DOUBLE,
	 "billingDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetCapabilities"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetCapabilities";
CREATE TABLE "TimesheetCapabilities" ("hasTimesheetBillingAccess" NUMERIC,"hasTimesheetProjectAccess" NUMERIC,"hasTimesheetActivityAccess" NUMERIC,"timesheetUri" VARCHAR NOT NULL ,"disclaimerTimesheetNoticePolicyUri" VARCHAR,"hasTimesheetClientAccess" NUMERIC,"hasTimesheetBreakAccess" NUMERIC,"hasTimepunchBreakAccess" NUMERIC, "hasTimesheetProgramAccess" NUMERIC);

-- ----------------------------
--  Table structure for "TimesheetCustomFields"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetCustomFields";
CREATE TABLE "TimesheetCustomFields" (
	 "udf_name" TEXT,
	 "udf_uri" TEXT,
	 "entry_type" TEXT,
	 "entryUri" TEXT,
	 "udfValue" TEXT,
	 "timesheetUri" TEXT NOT NULL,
	 "moduleName" TEXT,
	 "dropDownOptionURI" TEXT,
	 "timesheetEntryDate" DATETIME,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetDaySummary"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetDaySummary";
CREATE TABLE "TimesheetDaySummary" (
	 "timesheetUri" VARCHAR,
	 "timesheetEntryUri" VARCHAR,
	 "timesheetEntryDate" DATETIME,
	 "timesheetEntryTotalDurationDecimal" DOUBLE,
	 "timesheetEntryTotalDurationHour" VARCHAR,
	 "hasComments" NUMERIC,
	 "isHolidayDayOff" NUMERIC,
	 "isWeeklyDayOff" NUMERIC,
	 "timeOffDurationDecimal" DOUBLE,
	 "timeOffDurationHour" VARCHAR,
	 "workingTimeDurationDecimal" DOUBLE,
	 "workingTimeDurationHour" VARCHAR,
	 "noticeExplicitlyAccepted" NUMERIC,
	 "availableTimeOffTypeCount" NUMERIC,
	 "isCommentsRequired" NUMERIC,
	 "totalPunchTimeDurationDecimal" DOUBLE,
	 "totalInOutTimeDurationDecimal" DOUBLE,
	PRIMARY KEY("timesheetEntryDate"),
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetObjectExtensionFields"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetObjectExtensionFields";
CREATE TABLE "TimesheetObjectExtensionFields" (
	 "uri" TEXT,
	 "definitionTypeUri" TEXT,
	 "displayText" TEXT,
	 "oef_level" TEXT,
	 "timesheetUri" TEXT,
	 "timesheetFormat" TEXT
);

-- ----------------------------
--  Table structure for "TimesheetPayrollSummary"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetPayrollSummary";
CREATE TABLE "TimesheetPayrollSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "payrollUri" VARCHAR NOT NULL,
	 "payrollName" VARCHAR,
	 "payrollDurationDecimal" DOUBLE,
	 "payrollDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetProjectSummary"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetProjectSummary";
CREATE TABLE "TimesheetProjectSummary" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "projectUri" VARCHAR,
	 "projectName" VARCHAR,
	 "projectDurationDecimal" DOUBLE,
	 "projectDurationHour" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE
);

-- ----------------------------
--  Table structure for "TimesheetSummaryCachedData"
-- ----------------------------
DROP TABLE IF EXISTS "TimesheetSummaryCachedData";
CREATE TABLE "TimesheetSummaryCachedData" (
	 "timesheetUri" text NOT NULL,
	 "CachedData" blob NOT NULL,
	PRIMARY KEY("timesheetUri")
);

-- ----------------------------
--  Table structure for "Timesheets"
-- ----------------------------
DROP TABLE IF EXISTS "Timesheets";
CREATE TABLE "Timesheets" (
	 "timesheetUri" VARCHAR NOT NULL,
	 "startDate" DATETIME,
	 "endDate" DATETIME,
	 "timesheetPeriod" VARCHAR,
	 "dueDate" DATETIME,
	 "dueDateText" VARCHAR,
	 "approvalStatus" VARCHAR,
	 "totalDurationDecimal" DOUBLE,
	 "totalDurationHour" VARCHAR,
	 "overtimeDurationDecimal" DOUBLE,
	 "overtimeDurationHour" VARCHAR,
	 "timeoffDurationDecimal" DOUBLE,
	 "timeoffDurationHour" VARCHAR,
	 "regularDurationDecimal" DOUBLE,
	 "regularDurationHour" VARCHAR,
	 "mealBreakPenalties" INTEGER,
	 "overlappingTimeEntriesPermitted" NUMERIC,
	 "timesheetFormat" VARCHAR,
	 "canEditTimesheet" NUMERIC,
	 "operations" VARCHAR,
	 "lastResubmitComments" VARCHAR,
	PRIMARY KEY("timesheetUri")
);

-- ----------------------------
--  Table structure for "UDFPendingPreferences"
-- ----------------------------
DROP TABLE IF EXISTS "UDFPendingPreferences";
CREATE TABLE UDFPendingPreferences (
 		timesheetUri text NOT NULL,
 			udfUri text NOT NULL,
 		FOREIGN KEY (timesheetUri) REFERENCES "PendingApprovalTimesheets" (timesheetUri) ON DELETE CASCADE ON UPDATE CASCADE
 			);

-- ----------------------------
--  Table structure for "UDFPreferences"
-- ----------------------------
DROP TABLE IF EXISTS "UDFPreferences";
CREATE TABLE UDFPreferences (
 		udfUri text NOT NULL,
 			timesheetUri text NOT NULL,
 			FOREIGN KEY (timesheetUri) REFERENCES "Timesheets" (timesheetUri) ON DELETE CASCADE ON UPDATE CASCADE
 			);

-- ----------------------------
--  Table structure for "UDFPreviousPreferences"
-- ----------------------------
DROP TABLE IF EXISTS "UDFPreviousPreferences";
CREATE TABLE UDFPreviousPreferences (
 		udfUri text NOT NULL,
 		timesheetUri text NOT NULL,
 			FOREIGN KEY (timesheetUri) REFERENCES "PreviousApprovalTimesheets" (timesheetUri) ON DELETE CASCADE ON UPDATE CASCADE
 		);

-- ----------------------------
--  Table structure for "UdfDropDownOptions"
-- ----------------------------
DROP TABLE IF EXISTS "UdfDropDownOptions";
CREATE TABLE UdfDropDownOptions ( uri TEXT PRIMARY KEY, name TEXT, enabled NUMERIC, defaultOption NUMERIC);

-- ----------------------------
--  Table structure for "WidgetAttestation"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetAttestation";
CREATE TABLE "WidgetAttestation" (
	 "description" VARCHAR,
	 "title" VARCHAR,
	 "timesheetUri" VARCHAR,
	 "attestationStatus" NUMERIC,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetNotice"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetNotice";
CREATE TABLE "WidgetNotice" (
	 "description" VARCHAR,
	 "title" VARCHAR,
	 "timesheetUri" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPayrollSummary"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPayrollSummary";
CREATE TABLE "WidgetPayrollSummary" (
	 "paycodename" TEXT,
	 "paycodehours" TEXT,
	 "paycodeamount" TEXT,
	 "totalpayhours" TEXT,
	 "totalpayamount" TEXT,
	 "displayPayAmount" NUMERIC NOT NULL DEFAULT 0,
	 "timesheetUri" VARCHAR NOT NULL,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPendingAttestation"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPendingAttestation";
CREATE TABLE "WidgetPendingAttestation" (
	 "description" VARCHAR,
	 "title" VARCHAR,
	 "timesheetUri" VARCHAR,
	 "attestationStatus" NUMERIC,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPendingNotice"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPendingNotice";
CREATE TABLE "WidgetPendingNotice" (
	 "description" VARCHAR,
	 "title" VARCHAR,
	 "timesheetUri" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPendingPayrollSummary"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPendingPayrollSummary";
CREATE TABLE "WidgetPendingPayrollSummary" (
	 "paycodename" TEXT,
	 "paycodehours" TEXT,
	 "paycodeamount" TEXT,
	 "totalpayhours" TEXT,
	 "totalpayamount" TEXT,
	 "displayPayAmount" NUMERIC NOT NULL DEFAULT 0,
	 "timesheetUri" VARCHAR NOT NULL,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPendingPunchHistory"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPendingPunchHistory";
CREATE TABLE "WidgetPendingPunchHistory" (
	 "punchInUri" VARCHAR,
	 "punchOutUri" VARCHAR,
	 "PunchInTime" VARCHAR,
	 "PunchOutTime" VARCHAR,
	 "totalHours" VARCHAR,
	 "PunchInDateTimestamp" DATETIME,
	 "PunchInDate" VARCHAR,
	 "PunchOutDateTimestamp" DATETIME,
	 "PunchOutDate" VARCHAR,
	 "PunchInLatitude" VARCHAR,
	 "PunchInLongitude" VARCHAR,
	 "PunchInAddress" VARCHAR,
	 "PunchOutLatitude" VARCHAR,
	 "PunchOutLongitude" VARCHAR,
	 "PunchOutAddress" VARCHAR,
	 "punchInFullSizeImageLink" VARCHAR,
	 "punchInFullSizeImageUri" VARCHAR,
	 "punchInThumbnailSizeImageLink" VARCHAR,
	 "punchInThumbnailSizeImageUri" VARCHAR,
	 "punchOutFullSizeImageLink" VARCHAR,
	 "punchOutFullSizeImageUri" VARCHAR,
	 "punchOutThumbnailSizeImageLink" VARCHAR,
	 "punchOutThumbnailSizeImageUri" VARCHAR,
	 "punchUserName" VARCHAR,
	 "punchUserUri" VARCHAR,
	 "punchInAgent" VARCHAR,
	 "punchOutAgent" VARCHAR,
	 "activityName" VARCHAR,
	 "activityUri" VARCHAR,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "timesheetTransferStatus" VARCHAR,
	 "canTransferTimePunchToTimesheet" NUMERIC,
	 "canEditTimePunch" NUMERIC,
	 "cloudClockInUri" VARCHAR,
	 "cloudClockOutUri" VARCHAR,
	 "punchInAgentUri" VARCHAR,
	 "punchOutAgentUri" VARCHAR,
	 "punchInaccuracyInMeters" VARCHAR,
	 "punchOutaccuracyInMeters" VARCHAR,
	 "startPunchLastModificationTypeUri" VARCHAR,
	 "endPunchLastModificationTypeUri" VARCHAR,
	 "punchInActionUri" VARCHAR,
	 "punchOutActionUri" VARCHAR,
	 "punchDate" VARCHAR,
	 "timesheetUri" VARCHAR
);

-- ----------------------------
--  Table structure for "WidgetPendingTimesheetSummary"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPendingTimesheetSummary";
CREATE TABLE "WidgetPendingTimesheetSummary" (
	 "timesheetUri" text NOT NULL,
	 "totalInOutBreakHours" text,
	 "totalInOutWorkHours" text,
	 "totalInOutTimeOffHours" text,
	 "totalTimePunchBreakHours" text,
	 "totalTimePunchWorkHours" text,
	 "totalStandardWorkHours" text,
	 "totalStandardTimeOffHours" text,
	 "totalTimePunchTimeOffHours" text,
	FOREIGN KEY ("timesheetUri") REFERENCES "PendingApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPreviousAttestation"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPreviousAttestation";
CREATE TABLE "WidgetPreviousAttestation" (
	 "description" VARCHAR,
	 "title" VARCHAR,
	 "timesheetUri" VARCHAR,
	 "attestationStatus" NUMERIC,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPreviousNotice"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPreviousNotice";
CREATE TABLE "WidgetPreviousNotice" (
	 "description" VARCHAR,
	 "title" VARCHAR,
	 "timesheetUri" VARCHAR,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPreviousPayrollSummary"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPreviousPayrollSummary";
CREATE TABLE "WidgetPreviousPayrollSummary" (
	 "paycodename" TEXT,
	 "paycodehours" TEXT,
	 "paycodeamount" TEXT,
	 "totalpayhours" TEXT,
	 "totalpayamount" TEXT,
	 "displayPayAmount" NUMERIC NOT NULL DEFAULT 0,
	 "timesheetUri" VARCHAR NOT NULL,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPreviousPunchHistory"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPreviousPunchHistory";
CREATE TABLE "WidgetPreviousPunchHistory" (
	 "punchInUri" VARCHAR,
	 "punchOutUri" VARCHAR,
	 "PunchInTime" VARCHAR,
	 "PunchOutTime" VARCHAR,
	 "totalHours" VARCHAR,
	 "PunchInDateTimestamp" DATETIME,
	 "PunchInDate" VARCHAR,
	 "PunchOutDateTimestamp" DATETIME,
	 "PunchOutDate" VARCHAR,
	 "PunchInLatitude" VARCHAR,
	 "PunchInLongitude" VARCHAR,
	 "PunchInAddress" VARCHAR,
	 "PunchOutLatitude" VARCHAR,
	 "PunchOutLongitude" VARCHAR,
	 "PunchOutAddress" VARCHAR,
	 "punchInFullSizeImageLink" VARCHAR,
	 "punchInFullSizeImageUri" VARCHAR,
	 "punchInThumbnailSizeImageLink" VARCHAR,
	 "punchInThumbnailSizeImageUri" VARCHAR,
	 "punchOutFullSizeImageLink" VARCHAR,
	 "punchOutFullSizeImageUri" VARCHAR,
	 "punchOutThumbnailSizeImageLink" VARCHAR,
	 "punchOutThumbnailSizeImageUri" VARCHAR,
	 "punchUserName" VARCHAR,
	 "punchUserUri" VARCHAR,
	 "punchInAgent" VARCHAR,
	 "punchOutAgent" VARCHAR,
	 "activityName" VARCHAR,
	 "activityUri" VARCHAR,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "timesheetTransferStatus" VARCHAR,
	 "canTransferTimePunchToTimesheet" NUMERIC,
	 "canEditTimePunch" NUMERIC,
	 "cloudClockInUri" VARCHAR,
	 "cloudClockOutUri" VARCHAR,
	 "punchInAgentUri" VARCHAR,
	 "punchOutAgentUri" VARCHAR,
	 "punchInaccuracyInMeters" VARCHAR,
	 "punchOutaccuracyInMeters" VARCHAR,
	 "startPunchLastModificationTypeUri" VARCHAR,
	 "endPunchLastModificationTypeUri" VARCHAR,
	 "punchInActionUri" VARCHAR,
	 "punchOutActionUri" VARCHAR,
	 "punchDate" VARCHAR,
	 "timesheetUri" VARCHAR
);

-- ----------------------------
--  Table structure for "WidgetPreviousTimesheetSummary"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPreviousTimesheetSummary";
CREATE TABLE "WidgetPreviousTimesheetSummary" (
	 "timesheetUri" text NOT NULL,
	 "totalInOutBreakHours" text,
	 "totalInOutWorkHours" text,
	 "totalInOutTimeOffHours" text,
	 "totalTimePunchBreakHours" text,
	 "totalTimePunchWorkHours" text,
	 "totalStandardWorkHours" text,
	 "totalStandardTimeOffHours" text,
	 "totalTimePunchTimeOffHours" text,
	FOREIGN KEY ("timesheetUri") REFERENCES "PreviousApprovalTimesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "WidgetPunchHistory"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetPunchHistory";
CREATE TABLE "WidgetPunchHistory" (
	 "punchInUri" VARCHAR,
	 "punchOutUri" VARCHAR,
	 "PunchInTime" VARCHAR,
	 "PunchOutTime" VARCHAR,
	 "totalHours" VARCHAR,
	 "PunchInDateTimestamp" DATETIME,
	 "PunchInDate" VARCHAR,
	 "PunchOutDateTimestamp" DATETIME,
	 "PunchOutDate" VARCHAR,
	 "PunchInLatitude" VARCHAR,
	 "PunchInLongitude" VARCHAR,
	 "PunchInAddress" VARCHAR,
	 "PunchOutLatitude" VARCHAR,
	 "PunchOutLongitude" VARCHAR,
	 "PunchOutAddress" VARCHAR,
	 "punchInFullSizeImageLink" VARCHAR,
	 "punchInFullSizeImageUri" VARCHAR,
	 "punchInThumbnailSizeImageLink" VARCHAR,
	 "punchInThumbnailSizeImageUri" VARCHAR,
	 "punchOutFullSizeImageLink" VARCHAR,
	 "punchOutFullSizeImageUri" VARCHAR,
	 "punchOutThumbnailSizeImageLink" VARCHAR,
	 "punchOutThumbnailSizeImageUri" VARCHAR,
	 "punchUserName" VARCHAR,
	 "punchUserUri" VARCHAR,
	 "punchInAgent" VARCHAR,
	 "punchOutAgent" VARCHAR,
	 "activityName" VARCHAR,
	 "activityUri" VARCHAR,
	 "breakName" VARCHAR,
	 "breakUri" VARCHAR,
	 "timesheetTransferStatus" VARCHAR,
	 "canTransferTimePunchToTimesheet" NUMERIC,
	 "canEditTimePunch" NUMERIC,
	 "cloudClockInUri" VARCHAR,
	 "cloudClockOutUri" VARCHAR,
	 "punchInAgentUri" VARCHAR,
	 "punchOutAgentUri" VARCHAR,
	 "punchInaccuracyInMeters" VARCHAR,
	 "punchOutaccuracyInMeters" VARCHAR,
	 "startPunchLastModificationTypeUri" VARCHAR,
	 "endPunchLastModificationTypeUri" VARCHAR,
	 "punchInActionUri" VARCHAR,
	 "punchOutActionUri" VARCHAR,
	 "punchDate" VARCHAR,
	 "timesheetUri" VARCHAR
);

-- ----------------------------
--  Table structure for "WidgetTimesheetSummary"
-- ----------------------------
DROP TABLE IF EXISTS "WidgetTimesheetSummary";
CREATE TABLE "WidgetTimesheetSummary" (
	 "timesheetUri" text NOT NULL,
	 "totalInOutBreakHours" text,
	 "totalInOutWorkHours" text,
	 "totalInOutTimeOffHours" text,
	 "totalTimePunchBreakHours" text,
	 "totalTimePunchWorkHours" text,
	 "totalStandardWorkHours" text,
	 "totalStandardTimeOffHours" text,
	 "totalTimePunchTimeOffHours" text,
	FOREIGN KEY ("timesheetUri") REFERENCES "Timesheets" ("timesheetUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "udfPendingTimeoffPreferences"
-- ----------------------------
DROP TABLE IF EXISTS "udfPendingTimeoffPreferences";
CREATE TABLE "udfPendingTimeoffPreferences" (
	 "udfUri" text NOT NULL,
	 "timeoffUri" text NOT NULL,
	FOREIGN KEY ("timeoffUri") REFERENCES "PendingApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "udfPreviousTimeoffPreferences"
-- ----------------------------
DROP TABLE IF EXISTS "udfPreviousTimeoffPreferences";
CREATE TABLE "udfPreviousTimeoffPreferences" (
	 "udfUri" text NOT NULL,
	 "timeoffUri" text NOT NULL,
	FOREIGN KEY ("timeoffUri") REFERENCES "PreviousApprovalTimeOffs" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "udfTimeoffPreferences"
-- ----------------------------
DROP TABLE IF EXISTS "udfTimeoffPreferences";
CREATE TABLE "udfTimeoffPreferences" (
	 "udfUri" text NOT NULL,
	 "timeoffUri" text NOT NULL,
	FOREIGN KEY ("timeoffUri") REFERENCES "Timeoff" ("timeoffUri") ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------
--  Table structure for "userDefinedFields"
-- ----------------------------
DROP TABLE IF EXISTS "userDefinedFields";
CREATE TABLE "userDefinedFields" (
	 "uri" TEXT,
	 "name" TEXT,
	 "enabled" NUMERIC,
	 "required" NUMERIC,
	 "visible" NUMERIC,
	 "textDefaultValue" TEXT,
	 "numericDefaultValue" TEXT,
	 "numericMinValue" NUMERIC,
	 "numericMaxValue" NUMERIC,
	 "numericDecimalPlaces" NUMERIC,
	 "dateDefaultValue" DATETIME,
	 "isDateDefaultValueToday" NUMERIC,
	 "dateMinValue" DATETIME,
	 "dateMaxValue" DATETIME,
	 "udfType" TEXT,
	 "moduleName" TEXT,
	 "dropDownOptionDefaultURI" TEXT
);

-- ----------------------------
--  Table structure for "userDefinedFieldsClone"
-- ----------------------------
DROP TABLE IF EXISTS "userDefinedFieldsClone";
CREATE TABLE "userDefinedFieldsClone" (
	 "uri" TEXT,
	 "name" TEXT,
	 "enabled" NUMERIC,
	 "required" NUMERIC,
	 "visible" NUMERIC,
	 "textDefaultValue" TEXT,
	 "numericDefaultValue" TEXT,
	 "numericMinValue" NUMERIC,
	 "numericMaxValue" NUMERIC,
	 "numericDecimalPlaces" NUMERIC,
	 "dateDefaultValue" DATETIME,
	 "isDateDefaultValueToday" NUMERIC,
	 "dateMinValue" DATETIME,
	 "dateMaxValue" DATETIME,
	 "udfType" TEXT,
	 "moduleName" TEXT,
	 "dropDownOptionDefaultURI" TEXT
);

-- ----------------------------
--  Table structure for "userDetails"
-- ----------------------------
DROP TABLE IF EXISTS "userDetails";
CREATE TABLE "userDetails" (
	 "areTimeSheetRejectCommentsRequired" NUMERIC,
	 "isTimesheetApprover" NUMERIC,
	 "hasExpenseBillClient" NUMERIC,
	 "hasExpenseAccess" NUMERIC,
	 "hasExpensePaymentMethod" NUMERIC,
	 "hasExpenseReimbursements" NUMERIC,
	 "hasTimeoffBookingAccess" NUMERIC,
	 "isStartAndEndTimeRequiredForBooking" NUMERIC,
	 "timeoffBookingMinimumSizeUri" TEXT,
	 "timeoffDisplayFormat" TEXT,
	 "hasTimesheetBillingAccess" NUMERIC,
	 "hasTimesheetProjectAccess" NUMERIC,
	 "hasTimesheetAccess" NUMERIC,
	 "hasTimesheetTimeoffAccess" NUMERIC,
	 "hasTimesheetActivityAccess" NUMERIC,
	 "timesheetFormat" TEXT,
	 "timesheetHourFormat" TEXT,
	 "displayText" TEXT,
	 "slug" TEXT,
	 "uri" TEXT,
	 "isTimeOffApprover" NUMERIC,
	 "areTimeOffRejectCommentsRequired" NUMERIC,
	 "language_cultureCode" TEXT,
	 "language_displayText" TEXT,
	 "language_code" TEXT,
	 "language_uri" TEXT,
	 "disclaimerTimesheetNoticePolicyUri" VARCHAR,
	 "isExpenseApprover" NUMERIC,
	 "areExpenseRejectCommentsRequired" NUMERIC,
	 "expenseEntryAgainstProjectsAllowed" NUMERIC,
	 "expenseEntryAgainstProjectsRequired" NUMERIC,
	 "hasTimeOffDeletetAcess" NUMERIC,
	 "hasTimeOffEditAcess" NUMERIC,
	 "hasExpenseReceiptView" NUMERIC,
	 "timesheetActivitySelectionRequired" NUMERIC,
	 "timesheetProjectTaskSelectionRequired" NUMERIC,
	 "baseCurrencyName" VARCHAR,
	 "baseCurrencyUri" VARCHAR,
	 "hasTimesheetBreakAccess" NUMERIC,
	 "hasTimesheetClientAccess" NUMERIC,
	 "hasExpensesClientAccess" NUMERIC,
	 "disclaimerExpensesheetNoticePolicyUri" VARCHAR,
	 "hasPunchInOutAccess" NUMERIC,
	 "canViewShifts" NUMERIC,
	 "workWeekStartDayUri" VARCHAR,
	 "canEditTimePunch" NUMERIC,
	 "timepunchActivitySelectionRequired" NUMERIC,
	 "hasTimepunchBillingAccess" NUMERIC,
	 "hasTimepunchActivityAccess" NUMERIC,
	 "hasTimepunchBreakAccess" NUMERIC,
	 "hasTimepunchClientAccess" NUMERIC,
	 "hasTimepunchProjectAccess" NUMERIC,
	 "timepunchProjectTaskSelectionRequired" NUMERIC,
	 "timepunchGeolocationRequired" NUMERIC,
	 "timepunchAuditImageRequired" NUMERIC,
	 "canViewTeamTimePunch" NUMERIC,
	 "canViewTimePunch" NUMERIC,
	 "canTransferTimePunchToTimesheet" NUMERIC,
	 "hasTimesheetProgramAccess" NUMERIC,
	 "canEditTask" NUMERIC,
	 "canViewTeamTimesheet" NUMERIC,
	 "canEditTeamTimePunch" NUMERIC NOT NULL DEFAULT 0
);

-- ----------------------------
--  Table structure for "version_info"
-- ----------------------------
DROP TABLE IF EXISTS "version_info";
CREATE TABLE "version_info" (
	 "version_number" TEXT,
	 "isSupportSAML" TEXT
);

PRAGMA foreign_keys = true;
