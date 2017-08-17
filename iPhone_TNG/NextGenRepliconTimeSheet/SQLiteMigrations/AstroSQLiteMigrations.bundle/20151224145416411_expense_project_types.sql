CREATE TABLE "expense_project_types" (
"uri" VARCHAR NOT NULL,
"name" VARCHAR,
"client_uri" VARCHAR NOT NULL,
"client_name" VARCHAR,
"hasTasksAvailableForExpenseEntry" BOOL,
"user_uri" VARCHAR NOT NULL,
PRIMARY KEY("uri")
)