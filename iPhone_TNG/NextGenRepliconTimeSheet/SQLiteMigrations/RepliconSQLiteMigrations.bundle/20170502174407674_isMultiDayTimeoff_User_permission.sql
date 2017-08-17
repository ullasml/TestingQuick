ALTER TABLE "userDetails" ADD COLUMN "isMultiDayTimeOffOptionAvailable" BOOL;
ALTER TABLE "Timeoff" ADD COLUMN "isMultiDayTimeOff" BOOL;
ALTER TABLE "Timeoff" ADD COLUMN "approvalStatusUri" VARCHAR;
