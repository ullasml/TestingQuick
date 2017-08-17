//
//  db.h
//  SQLiteTest
//
//  Modified by Murali on 09/03/09.
//  Copyright 2008 ENLUME. All rights reserved.
//

#import "G2Util.h"
#import <sqlite3.h>
#import "G2AppProperties.h"

//This class for opening database and sending reading requests, responses from database...
@interface G2SQLiteDB : NSObject {
	
    sqlite3 *database;
	NSString *dbName, *dbPath;
}

+ (G2SQLiteDB *) getInstance;
+ (BOOL) createEditableCopyOfDatabaseAt:(NSString *) _dbPath withName:(NSString *) _dbName;
+ (BOOL) databaseExists: (NSString *) databaseName atPath:(NSString *) databasePath;
- (BOOL) openDatabaseWithName: (NSString *) name atPath: (NSString *) path;

- (BOOL) openDatabase: (NSString *) databaseName;
+ (NSString *)getDBVersion :(NSString *)versionTable :(NSString *)versionColumn;
- (NSMutableArray *) executeQuery:(NSString *)query;
- (BOOL) sqliteExecute:(NSString *) sql;

- (NSMutableArray *) sqliteQuery:(NSString *) selStr;

- (NSMutableArray *) select:(NSString *)fields from:(NSString*)tableName where:(NSString *)condition 
		intoDatabase:(NSString *)databaseName;
- (NSMutableArray *) select: (NSString *) fields from: (NSString *) tableName 
					  where:(NSString *) condition usingSort:(NSString *)sortString	 intoDatabase : (NSString *) databaseName;

- (BOOL) insertIntoTable: (NSString * )tableName  data: (NSDictionary *) data 
			intoDatabase: (NSString *) databaseName;

- (BOOL) updateTable: (NSString *) tableName data: (NSDictionary *) data where: (NSString *) condition 
		intoDatabase: (NSString *) databaseName;

- (BOOL) deleteFromTable: (NSString *) tableName where: (NSString *) condition
			  inDatabase: (NSString *) databaseName;

- (BOOL) deleteFromTable:(NSString *)tableName  inDatabase:(NSString *)databaseName;

- (BOOL) updateColumnFromTable: (NSString *) columnName fromTable: (NSString *) tableName withString: (NSString *) condition
					inDatabase: (NSString *) databaseName;
- (NSNumber *) getLastInsertedRowId;
- (NSMutableArray *) executeQueryToConvertUnicodeValues:(NSString *)query;
-(NSMutableDictionary *) getSchemaInfoForTable:(NSString *) tableName;
- (BOOL) createTableWithName: (NSString *) tableName schema:(NSMutableDictionary *) schema 
				  inDatabase: (NSString *) databaseName;
+(NSString *)getIsSupportForSAML :(NSString *)versionTable :(NSString *)versionColumn;
- (BOOL) closeDatabase: (NSString *) databaseName;

@property (nonatomic , strong)  NSString *dbName;
@property (nonatomic , strong)  NSString *dbPath;

@end
