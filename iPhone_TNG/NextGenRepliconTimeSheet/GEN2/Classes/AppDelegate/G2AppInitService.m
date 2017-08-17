//
//  AppInitService.h
//  iMarcoPolo
//
//  Created by Vamsi on 14/06/08.
//  Copyright 2008 Enlume. All rights reserved.
//


#import "G2AppInitService.h"
#import "G2SQLiteDB.h"
#import "RepliconAppDelegate.h"
#import "G2AppLevelModel.h"

@implementation G2AppInitService

@synthesize appProperties;

static G2AppInitService *initService = nil;

+ (G2AppInitService *) getInstance {
    
	@synchronized(self)
    {
		
		if(initService == nil)
		{
			// First time invocation
			initService = [[G2AppInitService alloc] init];
			initService.appProperties = [G2AppProperties getInstance];
		}
	}
	return initService;
}



/************************************************************************************************************
 @Function Name   : initApplication
 @Purpose         : Currently this function initializes the database if its not already done
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/


- (BOOL) initApplication
{
	
	if(appProperties == nil)
    {
		return NO;
	}
	[self initializeDatabase];
	
	return TRUE;
}
- (BOOL)  initializeDatabase
{
	
	NSString* docDir = [G2Util getDocumentDirectoryWithMask:NSUserDomainMask expandTilde:YES];
	NSString *dbPath = [NSString stringWithFormat:@"%@%@",docDir,[appProperties getAppPropertyFor:@"DatabasePath"]];
	NSString *dbName = [appProperties getAppPropertyFor:@"DatabaseName"];
	
    if(dbPath == nil)
		dbPath = @"/tmp/";
	
	else if(dbName == nil)
		dbName = @"G2replicon";
	BOOL dbExists = [G2SQLiteDB databaseExists:dbName atPath:dbPath];
    NSString *newVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	if(dbExists == YES)
    {
		NSString *currentVersion = [G2SQLiteDB getDBVersion:@"version_info" :@"version_number"];
        
		
		
        if (currentVersion!=nil)
        {
            if (![currentVersion isEqualToString:newVersion])
            {
                [self upgradeDataBaseByAppVersion: newVersion];
            }
        }
        
		
		return YES;
	}
    
	
	BOOL retVal = [G2SQLiteDB createEditableCopyOfDatabaseAt:dbPath withName:dbName];
	if(retVal == YES)
    {
        [self upgradeDataBaseByAppVersion: newVersion];
		
	}
	return retVal;
}

+ (id) allocWithZone: (NSZone *)zone
{
	
    @synchronized(self) {
        
		if (initService == nil) {
            initService = [super allocWithZone:zone];
            return initService;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


- (id) copyWithZone: (NSZone *)zone
{
	
    return self;
}






#pragma mark DB Upgrade Methods

-(void)upgradeDataBaseByAppVersion: (NSString *)newVersion
{
	
	G2AppLevelModel *appModel = [[G2AppLevelModel alloc] init];
	[appModel upgradeDB: newVersion];
    
	
    
}


@end




