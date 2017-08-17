CREATE TABLE "client_types" (
"name" VARCHAR NOT NULL,
"uri" VARCHAR NOT NULL,
"user_uri" VARCHAR NOT NULL
);
INSERT INTO client_types (name, uri, user_uri)
SELECT name, uri, user_uri FROM user_client_types;
DROP TABLE user_client_types;
ALTER TABLE client_types RENAME TO user_client_types;

CREATE TABLE "project_types" (
"uri" VARCHAR NOT NULL,
"name" VARCHAR,
"client_uri" VARCHAR NOT NULL,
"client_name" VARCHAR,
"start_date" DATE,
"end_date" DATE,
"hasTasksAvailableForTimeAllocation" BOOL,
"isTimeAllocationAllowed" BOOL,
"user_uri" VARCHAR NOT NULL
);
INSERT INTO project_types (uri, name, client_uri, client_name, start_date, end_date, hasTasksAvailableForTimeAllocation, isTimeAllocationAllowed, user_uri)
SELECT uri, name, client_uri, client_name, start_date, end_date, hasTasksAvailableForTimeAllocation, isTimeAllocationAllowed, user_uri FROM user_project_types;
DROP TABLE user_project_types;
ALTER TABLE project_types RENAME TO user_project_types;

CREATE TABLE "task_types" (
"name" VARCHAR NOT NULL,
"uri" VARCHAR NOT NULL,
"project_uri" VARCHAR NOT NULL,
"start_date" DATE,
"end_date" DATE,
"user_uri" VARCHAR NOT NULL
);
INSERT INTO task_types (name, uri, project_uri, start_date, end_date, user_uri)
SELECT name, uri, project_uri, start_date, end_date, user_uri FROM user_task_types;
DROP TABLE user_task_types;
ALTER TABLE task_types RENAME TO user_task_types;

CREATE TABLE "activity_types" (
"name" VARCHAR NOT NULL,
"uri" VARCHAR NOT NULL,
"user_uri" VARCHAR NOT NULL
);
INSERT INTO activity_types (name, uri, user_uri)
SELECT name, uri, user_uri FROM user_activity_types;
DROP TABLE user_activity_types;
ALTER TABLE activity_types RENAME TO user_activity_types;

