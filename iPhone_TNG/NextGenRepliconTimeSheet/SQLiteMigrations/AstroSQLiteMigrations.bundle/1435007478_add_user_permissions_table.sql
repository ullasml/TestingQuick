CREATE TABLE "user_permissions" (
    "geolocation_required" BOOL,
    "can_edit_time_punch" BOOL,
    "is_astro_punch_user" BOOL,
    "breaks_required" BOOL,
    "selfie_required" BOOL,
    "user_uri" VARCHAR NOT NULL,
    PRIMARY KEY("user_uri")
)
