//
//  db.h
//  SQLiteTest
//
//  Created by Vamsi on 22/05/08.
//  Copyright 2008 ENLUME. All rights reserved.
//

#import "G2SQLiteDB.h"


@implementation G2SQLiteDB

@synthesize dbPath;
@synthesize dbName;


static G2SQLiteDB *mySqliteDb = nil;
static NSLock	*dbLock		= nil;

+ (BOOL) databaseExists: (NSString *) databaseName atPath:(NSString *) databasePath {
	
	NSString *dbFilePath = [NSString stringWithFormat:@"%@%@", databasePath, databaseName ];
	
	BOOL databaseAlreadyExisted = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
	if (!databaseAlreadyExisted) {
		return NO;
	}
	return YES;
}

+(NSString *)getDBVersion :(NSString *)versionTable :(NSString *)versionColumn {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSMutableDictionary *versionTableInfo = [myDB getSchemaInfoForTable:versionTable];
	if ([[versionTableInfo allKeys] count] > 0) {
		
		NSMutableArray *versiondetails = [myDB select:@"*" from:versionTable where:@"" intoDatabase:@""];
		if (versiondetails != nil && [versiondetails count] > 0) {
			return [[versiondetails objectAtIndex:0] objectForKey:versionColumn];
		}
	}
	
	return nil;
}

+(NSString *)getIsSupportForSAML :(NSString *)versionTable :(NSString *)versionColumn {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	
	NSMutableDictionary *versionTableInfo = [myDB getSchemaInfoForTable:versionTable];
	if ([[versionTableInfo allKeys] count] > 0) {
		
		NSMutableArray *versiondetails = [myDB select:@"*" from:versionTable where:@"" intoDatabase:@""];
		if (versiondetails != nil && [versiondetails count] > 0) {
			return [[versiondetails objectAtIndex:0] objectForKey:versionColumn];
		}
	}
	
	return nil;
}

+ (G2SQLiteDB *) getInstance {
	
	@synchronized(self) {
		if(mySqliteDb == nil) {
			mySqliteDb = [[G2SQLiteDB alloc] init];
			
			NSString *myDbPath=nil, *myDbName=nil;
			G2AppProperties *appProperties = [G2AppProperties getInstance];
			if(appProperties != nil) {
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																	 NSUserDomainMask, YES);
				NSString* docDir = [paths objectAtIndex:0];
				
				myDbPath = [NSString stringWithFormat:@"%@%@",docDir,[appProperties getAppPropertyFor:@"DatabasePath"]];
				// myDbPath = [appProperties getAppPropertyFor:@"DatabasePath"];
				myDbName = [appProperties getAppPropertyFor:@"DatabaseName"];
				dbLock = [[NSLock alloc] init];
			}
			[mySqliteDb openDatabaseWithName:myDbName atPath:myDbPath];
            [mySqliteDb executeQuery:@"PRAGMA foreign_keys=ON;"];
		}
	}
	return mySqliteDb;
}


- (BOOL) openDatabaseWithName: (NSString *) name atPath: (NSString *) path {
	
    //	self = [super init];
	if (self != nil) {
		if(path == nil)
			dbPath = @"/tmp/";
		else if(dbPath == nil)
			dbPath = path;
		if(name == nil)
			dbName = @"iFinder";
		else if(dbName == nil)
			dbName = name;
		
		BOOL retCode=NO;
        
		retCode = [self openDatabase:dbName];
		if(retCode == NO) {
            
		}
		return retCode;
	}
	return NO;
}

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (BOOL) createEditableCopyOfDatabaseAt:(NSString *) _dbPath withName:(NSString *) _dbName {
	
	BOOL success;
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:_dbName];	//@"bookdb.sql"
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return YES;
	// The writable database does not exist, so copy the default to the appropriate location.
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_dbName];	// @"bookdb.sql"
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		return NO;
	}
	return YES;
}

- (BOOL) openDatabase: (NSString *) databaseName {
	
	NSString *dbPathStr = [NSString stringWithFormat:@"%@/%@",dbPath,databaseName];
	
	
	int retCode = sqlite3_open([dbPathStr fileSystemRepresentation], &database);
	
	if(retCode != SQLITE_OK) {
		return NO;
	}
	return YES;
}

- (BOOL) closeDatabase: (NSString *) databaseName{
	
	
	int retCode = sqlite3_close(database);
	if(retCode != SQLITE_OK) {
		return NO;
	}
	return YES;
}

- (NSMutableArray *) executeQuery:(NSString *)query {
	
	
	sqlite3_stmt *stmt;
	int retCode = sqlite3_prepare(database, [query UTF8String], -1, &stmt, 0);
	NSMutableArray *results = [NSMutableArray array];
	//If there is error just return. Or else print the array...
	if (retCode != SQLITE_OK) {
		//DLog(@"Failed to prepare the statement. Error message is %s",sqlite3_errmsg(database));
		stmt = 0;
		return NULL;
	} else {
		//Initially read the total col
		int numberOfColumns = sqlite3_column_count(stmt);
		int columnType;
		NSString *columnName;
		NSMutableArray *keys = [[NSMutableArray alloc] init];
		for (int i = 0; i< numberOfColumns; i++) {
			columnName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)]; // //stringWithCString
			[keys addObject:columnName];
		}
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			NSMutableArray *objects = [[NSMutableArray alloc] init];
			//Read single row objects, bind them to a dictionary and add it to an array.
			for (int i= 0;i<numberOfColumns;i++) {
				columnType = sqlite3_column_type(stmt, i);
				switch (columnType) {
					case SQLITE_INTEGER:
						[objects addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)]];
						break;
					case SQLITE_FLOAT:
						[objects addObject:[NSNumber numberWithFloat:sqlite3_column_double(stmt, i)]];
						break;
					case SQLITE_TEXT:
						[objects addObject:[NSString stringWithString:[NSString stringWithFormat:@"%s",sqlite3_column_text(stmt, i)]]];
						break;
					case SQLITE_BLOB:
						[objects addObject:[NSString stringWithUTF8String:sqlite3_column_blob(stmt, i)]]; //stringWithCString
						break;
					case SQLITE_NULL:
						[objects addObject:[NSNull null]];
						break;
					default:
						break;
				}
			}
			//NSDictionary *rowDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			NSDictionary *rowDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys: keys];
			[results addObject:rowDictionary];
            objects = nil;
		}
	}
	retCode = sqlite3_finalize(stmt);
	if(retCode != SQLITE_OK) {
		//DLog(@"Failed to finalize sql stmt! Err Code : %d: Err Msg: %s", retCode , sqlite3_errmsg(database));
		stmt = 0;
		
		// we are not returning result.. so we can release it
		return NULL;
	}
	stmt = 0;
	
	return results;
}


- (NSMutableArray *) executeQueryToConvertUnicodeValues:(NSString *)query {
	
	
	sqlite3_stmt *stmt;
	int retCode = sqlite3_prepare(database, [query UTF8String], -1, &stmt, 0);
	NSMutableArray *results = [NSMutableArray array];
	//If there is error just return. Or else print the array...
	if (retCode != SQLITE_OK) {
		//DLog(@"Failed to prepare the statement. Error message is %s",sqlite3_errmsg(database));
		stmt = 0;
		return NULL;
	} else {
		//Initially read the total col
		int numberOfColumns = sqlite3_column_count(stmt);
		int columnType;
		NSString *columnName;
		NSMutableArray *keys = [[NSMutableArray alloc] init];
		for (int i = 0; i< numberOfColumns; i++) {
			//columnName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)]; // //stringWithCString
			columnName = [[NSString alloc] initWithUTF8String: sqlite3_column_name(stmt, i)];
			[keys addObject:columnName];
            columnName = nil;
		}
        
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			NSMutableArray *objects = [[NSMutableArray alloc] init];
			//Read single row objects, bind them to a dictionary and add it to an array.
			for (int i= 0;i<numberOfColumns;i++) {
				columnType = sqlite3_column_type(stmt, i);
                
				switch (columnType) {
					case SQLITE_INTEGER:{
						
						NSNumber *value = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt, i)];
						[objects addObject: value];
						//[objects addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, i)]];
                        value = nil;
					}
						break;
					case SQLITE_FLOAT:	{
						NSNumber *value = [[NSNumber alloc] initWithDouble:sqlite3_column_double(stmt, i)];
						[objects addObject: value];
                        value = nil;
						//[objects addObject:[NSNumber numberWithDouble:sqlite3_column_double(stmt, i)]];
					}
						break;
					case SQLITE_TEXT:
					{
						NSString *value = [[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(stmt, i)];
						[objects addObject: value];
                        value = nil;
						break;
					}
						//[objects addObject:[NSString stringWithString:[NSString stringWithFormat:@"%s",sqlite3_column_text(stmt, i)]]];
						//[objects addObject:[NSString stringWithString:[NSString stringWithCString:(char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]]];
						//DLog(@"String after building nsstring %@",[NSString stringWithCString:(char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]);
						//DLog(@"String after building nsstring %s",[[NSString stringWithCString:(char *)sqlite3_column_text(stmt, i)] UTF8String]);
						//DLog(@"String after building nsstring %@",[NSString stringWithCString:(char *)sqlite3_column_text(stmt, i) encoding:NSUTF8StringEncoding]);
						//break;
					case SQLITE_BLOB:
					{
						NSString *value = [[NSString alloc] initWithUTF8String: sqlite3_column_blob(stmt, i)];
						[objects addObject: value];
                        value = nil;
						break;
					}
						//[objects addObject:[NSString stringWithUTF8String:sqlite3_column_blob(stmt, i)]]; //stringWithCString
						//break;
					case SQLITE_NULL:
						[objects addObject:[NSNull null]];
						break;
					default:
						break;
				}
			}
			//NSDictionary *rowDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
			NSDictionary *rowDictionary = [[NSDictionary alloc] initWithObjects:objects forKeys: keys];
			[results addObject:rowDictionary];
		}
	}
	retCode = sqlite3_finalize(stmt);
	if(retCode != SQLITE_OK) {
		//DLog(@"Failed to finalize sql stmt! Err Code : %d: Err Msg: %s", retCode , sqlite3_errmsg(database));
		stmt = 0;
		
		// we are not returning result.. so we can release it
		return NULL;
	}
	stmt = 0;
	
	return results;
}






- (BOOL) sqliteExecute:(NSString *) sql {
	
	sqlite3_stmt *stmt;
	int retCode = sqlite3_prepare(database, [ sql UTF8String], -1, &stmt, 0);
	if ( retCode == SQLITE_OK) {
		retCode = sqlite3_step(stmt);
		if(retCode != SQLITE_OK && retCode != SQLITE_DONE) {
			
			stmt = 0;
			return NO;
		}
		retCode = sqlite3_finalize(stmt);
		if(retCode != SQLITE_OK) {
			
			stmt = 0;
			return NO;
		}
		stmt = 0;
	} else {
		
		stmt = 0;
		return NO;
	}
	stmt = 0;
	return YES;
}

-(NSMutableDictionary *) getSchemaInfoForTable:(NSString *) tableName{
	
	if(tableName == nil || tableName == NULL ) {
		return NULL;
	}
	
	NSString *pragmaStr = [NSString stringWithFormat:@" PRAGMA table_info( %@ )", tableName];
	NSArray *res = [self sqliteQuery:pragmaStr];
	
	NSUInteger arrCount = [res count],i;
	NSMutableDictionary *result = [NSMutableDictionary new];
	for (i=0; i < arrCount ; i++) {
		
		NSMutableDictionary *arrEle = [res objectAtIndex:i];		// Get Dict containing each column;s details
		NSString *colName = [arrEle objectForKey:@"name"];	// Extract Name and Type
		NSString *colType = [arrEle objectForKey:@"type"];
		[result  setObject:colType forKey:colName];
	}
	return result;
}


- (NSMutableArray *) sqliteQuery:(NSString *) selStr{
	
	sqlite3_stmt *stmt;
	int retCode = sqlite3_prepare(database, [selStr UTF8String] , -1, &stmt, 0);
	if(retCode != SQLITE_OK) {
		
		stmt = 0;
		return NULL;
	}
	int ret=0;
	NSMutableArray *result = [[NSMutableArray alloc] init];
	if( (ret = sqlite3_step(stmt) ) != SQLITE_ROW ) {
		if(ret != SQLITE_OK && ret != SQLITE_DONE) {
			
			stmt = 0;
			return NULL;
		}
	} else {
		int numCols = sqlite3_column_count(stmt);	//	Same as sqlite3_data_count(stmt)
		int i, colType;
		NSString *colName;
		NSMutableArray *keys = [NSMutableArray new];
		for( i = 0 ; i < numCols ; i++ ) {	// Loop thru the result set and figure out the result types
            //colName = [NSString stringWithUTF8String:sqlite3_column_name(stmt, i)];
            colName = [[NSString alloc] initWithUTF8String:sqlite3_column_name(stmt, i)];
            [keys addObject:colName];
            //colName = nil;
			
		}
		
		do {
			// To count the columns in the result set
			NSMutableArray *objects = [NSMutableArray new];
			for(i = 0 ; i < numCols ; i++ ) { // Prepare the Objects array
				colType = sqlite3_column_type(stmt, i);
				
				switch (colType) {
					case SQLITE_INTEGER: {
						//NSNumber *integerVal = [[NSNumber alloc] initWithInt: sqlite3_column_int(stmt,i)];
						NSNumber *integerVal = [NSNumber numberWithInt: sqlite3_column_int(stmt,i) ];
						[objects addObject:integerVal];
						
						break;
					}
					case SQLITE_FLOAT: {
						//NSNumber *floatVal = [[NSNumber alloc] initWithDouble: sqlite3_column_double(stmt,i)];
						NSNumber *floatVal = [NSNumber numberWithDouble: sqlite3_column_double(stmt,i)];
						[objects addObject:floatVal];
						
						break;
					}
					case SQLITE_TEXT: {
						//const char* colText = (const char *) sqlite3_column_text(stmt, i);
						NSString *strVal = [[NSString alloc]initWithUTF8String: (const char *) sqlite3_column_text(stmt, i)];
						//NSString *strVal = [NSString stringWithUTF8String:(char *) sqlite3_column_text(stmt, i) ];
						[objects addObject:strVal];
                        //strVal = nil;
						break;
					}
					case SQLITE_BLOB: {
						//NSString *strVal = [[NSString alloc] initWithUTF8String: sqlite3_column_blob(stmt, i) ]; //stringWithCString
						NSString *strVal = [NSString stringWithUTF8String: sqlite3_column_blob(stmt, i)  ];
                        [objects addObject:strVal];
						
                        
						break;
					}
					case SQLITE_NULL: {
						NSNull *nullVal = [NSNull null];
						[objects addObject:nullVal];
						break;
					}
					default: {
						break;
					}
				}
			}
			//NSMutableDictionary *row =[ NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
			NSMutableDictionary *row = [[NSMutableDictionary alloc] initWithObjects:objects forKeys: keys];
			[result addObject:row];
            //objects = nil;
            //row = nil;
		} while ( (sqlite3_step(stmt) ) == SQLITE_ROW);
	}
	retCode = sqlite3_finalize(stmt);
	if(retCode != SQLITE_OK) {
		
		stmt = 0;
        // we are not returning result.. so we can release it
		return FALSE;
	}
	stmt = 0;
	
	return result;
}

- (NSString *) getCreateTableString: (NSString *) tableName schema:(NSMutableDictionary *) schema
						 inDatabase: (NSString *) databaseName{
	
	NSMutableString *sqlStr;
	sqlStr = [NSMutableString stringWithFormat:@"("];
	NSUInteger countFields = [schema count],i;
	NSArray *columns = [schema allKeys];
	NSString *columnName;
	NSString *columnType;
	
	for( i = 0; i < countFields; i++ ) {
		// columnName in columns
		columnName = [columns objectAtIndex:i];
		columnType = (NSString *) [schema objectForKey:columnName];
		if ( [sqlStr isEqualToString:@"("] ) {
			[sqlStr appendFormat:@"%@ %@", columnName, columnType];
		} else {
			[sqlStr appendFormat:@", %@ %@", columnName, columnType];
			
		}
	}
	
	[sqlStr appendString:@")"];
	NSString *createSql = [NSString stringWithFormat:@" CREATE TABLE %@ %@", tableName, sqlStr ];
	
	return createSql;
}

- (NSString *) getInsertTableString: (NSString * )tableName  data: (NSDictionary *) data
					   intoDatabase: (NSString *) databaseName {
	
	NSMutableString *columnStr = [NSMutableString stringWithFormat:@"("];
	NSMutableString *columnValueStr  = [NSMutableString stringWithFormat:@"("];
	
	NSUInteger countFields = [data count],i;
	NSArray *columns = [data allKeys];
	NSString *columnName, *columnValue;
	NSMutableDictionary *columnTypeDict = [self getSchemaInfoForTable:tableName ];
	for( i = 0; i < countFields; i++ ) {
		columnName = [columns objectAtIndex:i];
		NSString *colType = [columnTypeDict objectForKey:columnName];
		NSRange colRange = [colType rangeOfString:@"varchar" options:NSCaseInsensitiveSearch];	//:@"varchar"
		if( [colType caseInsensitiveCompare:@"TEXT"] == 0 ||  (colRange.location != NSNotFound && colRange.length !=0) ) // || [colType caseInsensitiveCompare:@"DATE"] == 0)
		{
            if ([[data objectForKey:columnName] isKindOfClass:[NSString class]] )
            {
                NSString *escapedPath=[[data objectForKey:columnName] stringByReplacingOccurrencesOfString:@"'"
                                                                                                withString:@"''"];
                columnValue = [NSString stringWithFormat:@"\'%@\'",escapedPath];
            }
            else
            {
                columnValue = [NSString stringWithFormat:@"\'%@\'",[data objectForKey:columnName]];
            }
            
            
		} else {
			columnValue = [data objectForKey:columnName];
		}
		if (columnValue)
        {
            if ( [columnStr isEqualToString:@"("] ) {
				[columnStr appendFormat:@"%@", columnName];
				[columnValueStr appendFormat:@"%@", columnValue];
			} else {
				[columnStr appendFormat:@", %@", columnName];
				[columnValueStr appendFormat:@", %@", columnValue];
			}
        }
        
	}
	[columnStr appendFormat:@")"];
	[columnValueStr appendFormat:@")"];
	
	
	
	NSString *insertSql = [NSString stringWithFormat:@" INSERT INTO %@ %@ values %@", tableName, columnStr,
						   columnValueStr];
	return insertSql;
}

- (NSString *) getReplaceTableString: (NSString * )tableName  data: (NSDictionary *) data
						intoDatabase: (NSString *) databaseName {
	
	NSMutableString *columnStr = [NSMutableString stringWithFormat:@"("];
	NSMutableString *columnValueStr  = [NSMutableString stringWithFormat:@"("];
	
	NSUInteger countFields = [data count],i;
	NSArray *columns = [data allKeys];
	NSString *columnName, *columnValue;
	NSMutableDictionary *columnTypeDict = [self getSchemaInfoForTable:tableName ];
	for( i = 0; i < countFields; i++ ) {
		columnName = [columns objectAtIndex:i];
		NSString *colType = [columnTypeDict objectForKey:columnName];
		if( [colType caseInsensitiveCompare:@"TEXT"] == 0) // || [colType caseInsensitiveCompare:@"DATE"] == 0)
		{
			if ([[data objectForKey:columnName] isKindOfClass:[NSString class]] )
            {
                NSString *escapedPath=[[data objectForKey:columnName] stringByReplacingOccurrencesOfString:@"'"
                                                                                                withString:@"''"];
                columnValue = [NSString stringWithFormat:@"\'%@\'",escapedPath];
            }
            else
            {
                columnValue = [NSString stringWithFormat:@"\'%@\'",[data objectForKey:columnName]];
            }
            
		} else {
			columnValue = [data objectForKey:columnName];
		}
		if (columnValue)
        {
            if ( [columnStr isEqualToString:@"("] ) {
				[columnStr appendFormat:@"%@", columnName];
				[columnValueStr appendFormat:@"%@", columnValue];
			} else {
				[columnStr appendFormat:@", %@", columnName];
				[columnValueStr appendFormat:@", %@", columnValue];
			}
        }
        
	}
	[columnStr appendFormat:@")"];
	[columnValueStr appendFormat:@")"];
	
    
	
	NSString *insertSql = [NSString stringWithFormat:@" REPLACE INTO %@ %@ values %@", tableName, columnStr,
						   columnValueStr];
	return insertSql;
}

- (BOOL) createTableWithName: (NSString *) tableName schema:(NSMutableDictionary *) schema
				  inDatabase: (NSString *) databaseName{
	
	NSString *createSql = [self getCreateTableString:tableName schema:schema inDatabase:databaseName];
	if (createSql == NULL) {
		return NO;
	}
	
	BOOL retCode = [self sqliteExecute:createSql];
	return retCode;
}

- (BOOL) dropTableWithName: (NSString *) tableName{
	
    if (![tableName isKindOfClass:[NSNull class] ])
    {
        if(tableName == nil || [tableName length] == 0) {
            return NO;
        }
    }
	NSString *dropSql = [NSString stringWithFormat:@" DROP TABLE %@", tableName];
	return [self sqliteExecute:dropSql];
}

- (BOOL) insertIntoTable: (NSString * )tableName  data: (NSDictionary *) data
			intoDatabase: (NSString *) databaseName{
	[dbLock lock];
	NSString *insertSql = [self getInsertTableString:tableName data:data  intoDatabase:databaseName];
	
	
	BOOL retCode = [self sqliteExecute:insertSql];
    
	[dbLock unlock];
	return retCode;
}

- (BOOL) replaceIntoTable: (NSString * )tableName  data: (NSDictionary *) data intoDatabase: (NSString *) databaseName{
	
	[dbLock lock];
	NSString *insertSql = [self getReplaceTableString:tableName data:data  intoDatabase:databaseName];
	BOOL retCode = [self sqliteExecute:insertSql];
	[dbLock unlock];
	return retCode;
}

- (BOOL) updateTable: (NSString *) tableName data: (NSDictionary *) data where: (NSString *) condition
		intoDatabase: (NSString *) databaseName{
    
	NSMutableString *setStr;
	setStr = [NSMutableString stringWithFormat:@" "];
	NSArray *columns = [data allKeys];
	NSUInteger countFields = [columns count],i;
	NSString *columnName;
	NSString *columnValue;
	for( i = 0; i < countFields; i++ ) {
		//columnName in columns
		columnName = [columns objectAtIndex:i];
		columnValue = (NSString *) [data objectForKey:columnName];
        
		if(columnValue == nil){
            
		}
		
        
        if ([columnValue isKindOfClass:[NSString class]] )
        {
            NSString *escapedPath=[columnValue stringByReplacingOccurrencesOfString:@"'"
                                                                         withString:@"''"];
            columnValue =escapedPath;
        }
        
        
		if(columnValue != nil && [columnValue isMemberOfClass:[NSNull class]] == NO) {
			if ( [setStr isEqualToString:@" "] ) {
				[setStr appendFormat:@"%@ = \'%@\'", columnName, columnValue];
			} else {
				[setStr appendFormat:@", %@ = \'%@\'", columnName, columnValue];
			}
		}
	}
	
	NSString *updateSql=@"";
    if (![condition isKindOfClass:[NSNull class] ])
    {
        if(condition != nil && [condition length] != 0) {
            updateSql = [NSString stringWithFormat:@" UPDATE %@ SET %@ WHERE %@", tableName, setStr, condition];
        } else {
            updateSql = [NSString stringWithFormat:@" UPDATE %@ SET %@ ", tableName, setStr];
        }
    }
	
    
	[dbLock lock];
	BOOL retCode = [self sqliteExecute:updateSql];
	[dbLock unlock];
	return retCode;
	
}

- (BOOL) deleteFromTable: (NSString *) tableName where: (NSString *) condition
			  inDatabase: (NSString *) databaseName{
	
	NSMutableString *delStr;
	delStr = [NSMutableString stringWithFormat:@" DELETE FROM %@ WHERE %@",tableName,condition];
	[dbLock lock];
	
	BOOL retCode = [self sqliteExecute:delStr];
    
	[dbLock unlock];
	return retCode;
}

- (BOOL) updateColumnFromTable: (NSString *) columnName fromTable: (NSString *) tableName withString: (NSString *) condition
                    inDatabase: (NSString *) databaseName{
	
	
	NSMutableString *delStr;
	delStr = [NSMutableString stringWithFormat:@" UPDATE  %@ SET   %@ = %@",tableName,columnName,condition];
	[dbLock lock];
	
	BOOL retCode = [self sqliteExecute:delStr];
    
	[dbLock unlock];
	return retCode;
}

- (BOOL) deleteFromTable:(NSString *)tableName  inDatabase:(NSString *)databaseName{
	
	NSMutableString *delStr;
	delStr = [NSMutableString stringWithFormat:@" DELETE FROM %@ ",tableName];
	
	[dbLock lock];
	BOOL retCode = [self sqliteExecute:delStr];
	[dbLock unlock];
	return retCode;
}

- (NSMutableArray *) select: (NSString *) fields from: (NSString *) tableName
					  where:(NSString *) condition	 intoDatabase : (NSString *) databaseName{
	
	NSMutableString *selStr,*feildsStr, *whereStr;
	if ([fields isEqual: @""]) {
		feildsStr = [NSMutableString stringWithFormat:@"*"];
	} else {
		feildsStr = [NSMutableString stringWithString:fields];
	}
	if([condition isEqual: @""]) {
		whereStr = [NSMutableString stringWithString:@""];
	} else {
		whereStr = [NSMutableString stringWithFormat:@" WHERE %@", condition];
	}
	
	selStr = [NSMutableString stringWithFormat:@" SELECT %@ FROM %@ %@", feildsStr ,tableName, whereStr];
	
	[dbLock lock];
	NSMutableArray *result = [self sqliteQuery:selStr];
	[dbLock unlock];
	return result;
}

- (NSMutableArray *) select: (NSString *) fields from: (NSString *) tableName
					  where:(NSString *) condition usingSort:(NSString *)sortString	 intoDatabase : (NSString *) databaseName{
	
	NSMutableString *selStr,*feildsStr, *whereStr;
	if ([fields isEqual: @""]) {
		feildsStr = [NSMutableString stringWithFormat:@"*"];
	} else {
		feildsStr = [NSMutableString stringWithString:fields];
	}
	if([condition isEqual: @""]) {
		whereStr = [NSMutableString stringWithString:@""];
	} else {
		whereStr = [NSMutableString stringWithFormat:@" WHERE %@", condition];
	}
	
	selStr = [NSMutableString stringWithFormat:@" SELECT %@ FROM %@ %@ %@", feildsStr ,tableName, whereStr, sortString];
	
	[dbLock lock];
	NSMutableArray *result = [self sqliteQuery:selStr];
	[dbLock unlock];
	return result;
}

- (NSNumber *) getLastInsertedRowId {
	
	NSString *selStr = @"SELECT last_insert_rowid() as lastInsertId";
	[dbLock lock];
	NSMutableArray *result = [self sqliteQuery:selStr];
	[dbLock unlock];
	if(result != nil && [result count] > 0) {
		return [[result objectAtIndex:0] objectForKey:@"lastInsertId"];
	}
	return nil;
}


+ (id) allocWithZone: (NSZone *)zone{
	
    @synchronized(self) {
        
		if (mySqliteDb == nil) {
            mySqliteDb = [super allocWithZone:zone];
            return mySqliteDb;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


- (id) copyWithZone: (NSZone *)zone {
	
    return self;
}






//- (void)release {
//	
//    //do nothing
//}





- (void) dealloc
{
	[self closeDatabase:dbName];
	
	CFRelease(database);
	
}


@end