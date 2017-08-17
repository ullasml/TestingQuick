
CREATE TABLE IF NOT EXISTS failed_punches ("date" DATE NOT NULL,"break_type_name" VARCHAR,"break_type_uri" VARCHAR,"action_type" VARCHAR NOT NULL,"location_latitude" FLOAT,"location_longitude" FLOAT,"location_horizontal_accuracy" FLOAT,"address" VARCHAR,"user_uri" VARCHAR NOT NULL,"image_url" VARCHAR,"image" BLOB,"offline" BOOL, "activity_name" VARCHAR, "activity_uri" VARCHAR, "client_name" VARCHAR, "client_uri" VARCHAR, "project_name" VARCHAR, "project_uri" VARCHAR, "task_name" VARCHAR, "task_uri" VARCHAR);

CREATE TABLE IF NOT EXISTS "local_user_punches_outbox" ("date" DATE NOT NULL,"break_type_name" VARCHAR,"break_type_uri" VARCHAR,"action_type" VARCHAR NOT NULL,"location_latitude" FLOAT,"location_longitude" FLOAT,"location_horizontal_accuracy" FLOAT,"address" VARCHAR,"user_uri" VARCHAR NOT NULL,"image_url" VARCHAR,"image" BLOB, "request_id" VARCHAR, "offline" BOOL, "client_name" VARCHAR, "client_uri" VARCHAR, "project_name" VARCHAR, "project_uri" VARCHAR, "task_name" VARCHAR, "task_uri" VARCHAR, "activity_name" VARCHAR, "activity_uri" VARCHAR);

INSERT INTO time_punch
(date,
break_type_name,
break_type_uri,
action_type,
location_latitude,
location_longitude,
location_horizontal_accuracy,
address,
user_uri,
image_url,
image,
request_id,
offline,
client_name,
client_uri,
project_name,
project_uri,
task_name,
task_uri,
activity_name,
activity_uri,
punchSyncStatus)
SELECT local_user_punches_outbox.date,
local_user_punches_outbox.break_type_name,
local_user_punches_outbox.break_type_uri,
local_user_punches_outbox.action_type,
local_user_punches_outbox.location_latitude,
local_user_punches_outbox.location_longitude,
local_user_punches_outbox.location_horizontal_accuracy,
local_user_punches_outbox.address,
local_user_punches_outbox.user_uri,
local_user_punches_outbox.image_url,
local_user_punches_outbox.image,
local_user_punches_outbox.request_id,
local_user_punches_outbox.offline,
local_user_punches_outbox.client_name,
local_user_punches_outbox.client_uri,
local_user_punches_outbox.project_name,
local_user_punches_outbox.project_uri,
local_user_punches_outbox.task_name,
local_user_punches_outbox.task_uri,
local_user_punches_outbox.activity_name,
local_user_punches_outbox.activity_uri,
0
FROM local_user_punches_outbox;


INSERT INTO time_punch
(date,
break_type_name,
break_type_uri,
action_type,
location_latitude,
location_longitude,
location_horizontal_accuracy,
address,
user_uri,
image_url,
image,
request_id,
offline,
client_name,
client_uri,
project_name,
project_uri,
task_name,
task_uri,
activity_name,
activity_uri,
punchSyncStatus)
SELECT failed_punches.date,
failed_punches.break_type_name,
failed_punches.break_type_uri,
failed_punches.action_type,
failed_punches.location_latitude,
failed_punches.location_longitude,
failed_punches.location_horizontal_accuracy,
failed_punches.address,
failed_punches.user_uri,
failed_punches.image_url,
failed_punches.image,
(select substr(u,1,8)||'-'||substr(u,9,4)||'-4'||substr(u,13,3)||
'-'||v||substr(u,17,3)||'-'||substr(u,21,12) as request_id from (
select lower(hex(randomblob(16))) as u, substr('89ab',abs(random()) % 4 + 1, 1) as v)),
failed_punches.offline,
failed_punches.client_name,
failed_punches.client_uri,
failed_punches.project_name,
failed_punches.project_uri,
failed_punches.task_name,
failed_punches.task_uri,
failed_punches.activity_name,
failed_punches.activity_uri,
0
FROM failed_punches;

DROP TABLE IF EXISTS local_user_punches_outbox;
DROP TABLE IF EXISTS failed_punches;
DROP TABLE IF EXISTS timeline_punches;
