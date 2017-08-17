
-- ----------------------------
--  Table structure for "a_parent_table"
-- ----------------------------
DROP TABLE IF EXISTS "a_parent_table";
CREATE TABLE "a_parent_table" (
"uri" VARCHAR NOT NULL,
"name" VARCHAR,
PRIMARY KEY("uri")
);


-- ----------------------------
--  Table structure for "a_child_table"
-- ----------------------------
DROP TABLE IF EXISTS "a_child_table";
CREATE TABLE a_child_table (
"name" VARCHAR,
"uri" VARCHAR NOT NULL,
FOREIGN KEY (uri) REFERENCES "a_parent_table" (uri) ON DELETE CASCADE ON UPDATE CASCADE
);