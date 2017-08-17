CREATE TABLE "reportee_permissions"  (
"project_access" BOOL,
"client_access" BOOL,
"user_uri" VARCHAR NOT NULL,
PRIMARY KEY("user_uri")
)
