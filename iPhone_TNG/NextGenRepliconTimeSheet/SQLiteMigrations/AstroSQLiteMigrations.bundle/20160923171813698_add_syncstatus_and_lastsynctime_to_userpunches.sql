ALTER TABLE "user_punches" ADD COLUMN "punchSyncStatus" NUMERIC;
ALTER TABLE "user_punches" ADD COLUMN "lastSyncTime" DATE;
ALTER TABLE "user_punches" ADD COLUMN "request_id" VARCHAR;
