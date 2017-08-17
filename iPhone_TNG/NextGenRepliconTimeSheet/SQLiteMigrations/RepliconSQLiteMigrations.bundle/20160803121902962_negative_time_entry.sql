ALTER TABLE "TimesheetPermittedApprovalActions" ADD COLUMN "allowNegativeTimeEntry" NUMERIC;

ALTER TABLE "PreviousApprovalTimeEntries" ADD COLUMN "hasTimeEntryValue" NUMERIC;
ALTER TABLE "PendingApprovalTimeEntries" ADD COLUMN "hasTimeEntryValue" NUMERIC;

ALTER TABLE "Time_entries" ADD COLUMN "hasTimeEntryValue" INTEGER DEFAULT 0;