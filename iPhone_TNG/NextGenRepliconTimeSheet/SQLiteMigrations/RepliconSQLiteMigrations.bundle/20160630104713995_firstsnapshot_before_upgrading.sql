ALTER TABLE "Timesheets" ADD COLUMN "lastKnownApprovalStatus" VARCHAR;

ALTER TABLE "WidgetPayrollSummary" ADD COLUMN "savedOnDate" VARCHAR;

ALTER TABLE "WidgetPendingPayrollSummary" ADD COLUMN "savedOnDate" VARCHAR;

ALTER TABLE "WidgetPreviousPayrollSummary" ADD COLUMN "savedOnDate" VARCHAR;