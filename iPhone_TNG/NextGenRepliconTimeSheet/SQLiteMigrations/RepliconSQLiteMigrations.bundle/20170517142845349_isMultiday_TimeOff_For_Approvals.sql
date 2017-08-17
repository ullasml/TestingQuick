ALTER TABLE "PendingApprovalTimeoffEntries" ADD COLUMN "isMultiDayTimeOff" BOOL;
ALTER TABLE "PreviousApprovalTimeoffEntries" ADD COLUMN "isMultiDayTimeOff" BOOL;
ALTER TABLE "PendingApprovalTimeoffEntries" ADD COLUMN "approvalStatusUri" VARCHAR;
ALTER TABLE "PreviousApprovalTimeoffEntries" ADD COLUMN "approvalStatusUri" VARCHAR;
