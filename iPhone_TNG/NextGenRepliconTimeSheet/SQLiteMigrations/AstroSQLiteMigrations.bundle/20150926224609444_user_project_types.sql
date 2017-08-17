
CREATE TABLE "user_project_types" (
"uri" VARCHAR NOT NULL,
"name" VARCHAR,
"client_uri" VARCHAR NOT NULL,
"client_name" VARCHAR,
"start_date" DATE,
"end_date" DATE,
"hasTasksAvailableForTimeAllocation" BOOL,
"isTimeAllocationAllowed" BOOL,
"user_uri" VARCHAR NOT NULL,
PRIMARY KEY("uri")
)