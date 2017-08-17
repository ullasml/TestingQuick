ALTER TABLE "user_permissions" ADD COLUMN "project_access" BOOL ;
ALTER TABLE "user_permissions" ADD COLUMN "client_access" BOOL ;
ALTER TABLE "user_permissions" ADD COLUMN "project_task_selection_required" BOOL ;