//
//  AppLevelModel.m
//  Replicon
//
//  Created by vijaysai on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppLevelModel.h"
#import "SupportDataModel.h"
#import "AppDelegate.h"

@implementation AppLevelModel

- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

-(void)upgradeDB: (NSString *) newVersion {
	
	SQLiteDB *myDB = [SQLiteDB getInstance];
	NSString *versionTable = @"version_info";
	//create db version table.
	
    NSMutableArray *versiondetails = [myDB select:@"*" from:versionTable where:@"" intoDatabase:@""];
    
    int isSupportSAML = 0;
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
    
   
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString *versionTable = @"version_info";
    
    NSMutableArray *versiondetails = [myDB select:@"*" from:versionTable where:@"" intoDatabase:@""];
    
    int isSupportSAML = 0;
    NSString *currentversionName=nil;
    
    if (versiondetails != nil && [versiondetails count] > 0)
    {
        isSupportSAML =  [[[versiondetails objectAtIndex:0] objectForKey:@"isSupportSAML"]intValue];
        currentversionName =  [[versiondetails objectAtIndex:0] objectForKey:@"version_number"];
    }
    
     BOOL isLoginSuccessfull=[[NSUserDefaults standardUserDefaults] boolForKey:@"isSuccessLogin"];
    
    
    if(isLoginSuccessfull && isSupportSAML)
    {
         AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate loadCookie];
    }
    
    
	NSString *dbName = @"replicon.sqlite";
    
    
    
    BOOL success;
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
    
    
    if (_ENCRYPT_DB)
    {
        NSString* docDir = [Util getDocumentDirectoryWithMask:NSUserDomainMask expandTilde:YES];
        NSString *dbPath = [NSString stringWithFormat:@"%@%@",docDir,@"/"];
        BOOL dbExists = [SQLiteDB databaseExists:@"replicon.sqlite" atPath:dbPath];
        
        if (dbExists)
        {
            dbName = @"replicon.sqlite";
        }
        else
        {
            dbName = @"encrypted.sqlite";
        }

    }
    
    [myDB closeDatabase:dbName];
	
   NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
	success = [fileManager fileExistsAtPath:writableDBPath];
	
	
    if (success)
    {
        success=[fileManager removeItemAtPath:writableDBPath error:&error];
        //success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        
        NSString* docDir = [Util getDocumentDirectoryWithMask:NSUserDomainMask expandTilde:YES];
        NSString *dbPath = [NSString stringWithFormat:@"%@%@",docDir,@"/"];
        
        if (_ENCRYPT_DB)
        {
            dbName = @"encrypted.sqlite";
        }
        
        success = [SQLiteDB createEditableCopyOfDatabaseAt:dbPath withName:@"replicon.sqlite"];
    }
    
    
    
    [myDB openDatabaseWithName:dbName atPath:writableDBPath];
    
    [myDB executeQuery:@"PRAGMA foreign_keys=ON;"];
    
	if (!success) {
		NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		
	}
    

        
        //flush DB after changes
        [Util flushDBInfoForOldUser:YES];
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
    
    if ([fileManagerforlogs fileExistsAtPath:[filedocumentsDirectory stringByAppendingFormat:@"/cookies.txt"]])
    {
        NSArray* allCookies = [NSKeyedUnarchiver unarchiveObjectWithFile:[filedocumentsDirectory stringByAppendingFormat:@"/cookies.txt"]];
        if (allCookies!=nil)
        {
            SQLiteDB *myDB = [SQLiteDB getInstance];
            [myDB deleteFromTable:@"cookies" inDatabase:@""];
            [myDB insertCookieData:[NSKeyedArchiver archivedDataWithRootObject:allCookies]];
        }
        
        [fileManagerforlogs removeItemAtPath:[filedocumentsDirectory stringByAppendingFormat:@"/cookies.txt"] error:NULL];
    }
    

   
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appUpdateVersionTriggerCount"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GetVersionUpdateDetails"];
    [[NSUserDefaults standardUserDefaults] setBool:isLoginSuccessfull forKey:@"isSuccessLogin"];
    
}

@end
