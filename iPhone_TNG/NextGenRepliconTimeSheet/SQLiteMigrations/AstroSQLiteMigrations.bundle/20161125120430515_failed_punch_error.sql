CREATE TABLE "failed_punch_error" (
"date" DATETIME NOT NULL,
"action_type" VARCHAR NOT NULL,
"error_msg" VARCHAR NOT NULL,
"request_id" VARCHAR  NOT NULL,
"client_name" VARCHAR ,
"project_name" VARCHAR ,
"task_name" VARCHAR  ,
"activity_name" VARCHAR  ,
"break_name" VARCHAR  ,
"user_uri" VARCHAR NOT NULL,
PRIMARY KEY("request_id")
);
