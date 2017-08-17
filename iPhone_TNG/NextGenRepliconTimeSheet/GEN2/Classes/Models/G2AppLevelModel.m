//
//  AppLevelModel.m
//  Replicon
//
//  Created by vijaysai on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2AppLevelModel.h"
#import "G2SupportDataModel.h"

@implementation G2AppLevelModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

-(void)upgradeDB: (NSString *) newVersion {
	
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *versionTable = @"version_info";
	//create db version table.
	
    NSMutableArray *versiondetails = [myDB select:@"*" from:versionTable where:@"" intoDatabase:@""];
    
    int isSupportSAML = 1;
    NSString *currentversionName=nil;
    
    if (versiondetails != nil && [versiondetails count] > 0)
    {
        isSupportSAML =  [[[versiondetails objectAtIndex:0] objectForKey:@"isSupportSAML"]intValue];
        currentversionName =  [[versiondetails objectAtIndex:0] objectForKey:@"version_number"];
    }
    
    
	
    
    NSDictionary *dbInfoDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                  newVersion,@"version_number",
                                  [NSNumber numberWithInt:isSupportSAML],@"isSupportSAML",
                                  nil];
    
    if (versiondetails != nil && [versiondetails count] > 0)
    {
        NSString *whereString = [NSString stringWithFormat:@"version_number = '%@'",currentversionName];
        [myDB updateTable:versionTable data:dbInfoDataDict where:whereString intoDatabase:@""];
        [self updateFromVersionCurrentToVersionNew];
    }
    else
    {
        [myDB insertIntoTable:versionTable data:dbInfoDataDict intoDatabase:@""];
        
    }
	
    
    
	
    
	
    
}



-(void) updateFromVersionCurrentToVersionNew
{
    
    
    
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    NSString *versionTable = @"version_info";
    
    NSMutableArray *versiondetails = [myDB select:@"*" from:versionTable where:@"" intoDatabase:@""];
    
    int isSupportSAML = 0;
    NSString *currentversionName=nil;
    
    if (versiondetails != nil && [versiondetails count] > 0)
    {
        isSupportSAML =  [[[versiondetails objectAtIndex:0] objectForKey:@"isSupportSAML"]intValue];
        currentversionName =  [[versiondetails objectAtIndex:0] objectForKey:@"version_number"];
    }
    
    
    
    
	NSString *dbName = @"G2replicon.sqlite";
    
    
    [myDB closeDatabase:dbName];
	
    BOOL success;
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];	//@"bookdb.sql"
	success = [fileManager fileExistsAtPath:writableDBPath];
	
	// The writable database does not exist, so copy the default to the appropriate location.
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];	// @"bookdb.sql"
    if (success)
    {
        success=[fileManager removeItemAtPath:writableDBPath error:&error];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    }
    
    [myDB openDatabaseWithName:dbName atPath:writableDBPath];
	if (!success) {
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		
	}
    
    
    
    //flush DB after changes
    [G2Util flushDBInfoForOldUser:NO];
    NSDictionary *dbInfoDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                  currentversionName,@"version_number",
                                  [NSNumber numberWithInt:isSupportSAML],@"isSupportSAML",
                                  nil];
    
    [myDB insertIntoTable:versionTable data:dbInfoDataDict intoDatabase:@""];
    
    
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AuthMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSArray *filepaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filedocumentsDirectory = [filepaths objectAtIndex:0];
    
    NSFileManager *fileManagerforlogs = [NSFileManager defaultManager];
    [fileManagerforlogs removeItemAtPath:[filedocumentsDirectory stringByAppendingFormat:@"/currentlog.txt"] error:NULL];
    [fileManagerforlogs removeItemAtPath:[filedocumentsDirectory stringByAppendingFormat:@"/backkuplog.txt"] error:NULL];
}

@end
