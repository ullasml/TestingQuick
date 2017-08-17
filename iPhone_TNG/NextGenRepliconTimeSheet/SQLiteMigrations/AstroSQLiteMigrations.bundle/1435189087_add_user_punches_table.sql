CREATE TABLE "user_punches" (
"date" DATE NOT NULL,
"action_type" VARCHAR NOT NULL,
"user_uri" VARCHAR NOT NULL,
"uri" VARCHAR,
"break_type_name" VARCHAR,
"break_type_uri" VARCHAR,
"location_latitude" FLOAT,
"location_longitude" FLOAT,
"location_horizontal_accuracy" FLOAT,
"address" VARCHAR,
"image_url" VARCHAR,
"image" BLOB,
PRIMARY KEY("user_uri", "date")
)
