CREATE TABLE "time_punch_oef_value" (
"punch_client_id" VARCHAR,
"oef_uri" VARCHAR,
"oef_definitionTypeUri" VARCHAR ,
"oef_name" VARCHAR ,
"numericValue"  VARCHAR ,
"textValue"  VARCHAR ,
"dropdownOptionUri"  VARCHAR ,
"dropdownOptionValue"  VARCHAR,
"punchActionType" VARCHAR ,
"collectAtTimeOfPunch" BOOL
);

CREATE TRIGGER delete_punch_oef
AFTER DELETE ON time_punch
FOR EACH ROW
BEGIN
DELETE FROM time_punch_oef_value WHERE punch_client_id = OLD.request_id;
END;

CREATE TRIGGER delete_punch_oef_user_punch
AFTER DELETE ON user_punches
FOR EACH ROW
BEGIN
DELETE FROM time_punch_oef_value WHERE punch_client_id = OLD.request_id;
END;
