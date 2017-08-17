ALTER TABLE "user_permissions" ADD COLUMN "can_approve_timesheets" BOOL;
ALTER TABLE "user_permissions" ADD COLUMN "can_approve_expenses" BOOL;
ALTER TABLE "user_permissions" ADD COLUMN "can_approve_timeoffs" BOOL;
ALTER TABLE "user_permissions" ADD COLUMN "can_view_team_punch" BOOL;