//
//  SNLog.m
//  Replicon
//
//  Created by Dipta Rakshit on 5/28/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "SNLog.h"

#import "Util.h"
#import "AppProperties.h"
#import "Util.h"
#import "FrameworkImport.h"
#import "SQLiteDB.h"

@implementation SNLog


#pragma mark Singleton Methods
static SNLog *sharedInstance;
+ (SNLog *) logManager {
    if (sharedInstance == nil) {
        sharedInstance = [[SNLog alloc] init];
    }
    
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone {
    if (sharedInstance == nil) {
        sharedInstance = [super allocWithZone:zone];
    }       
    return sharedInstance;
}


+ (void) Log: (NSString *) format, ... {
    SNLog *log = [SNLog logManager];
    va_list args;
    va_start(args, format);
    NSString *logEntry = [[NSString alloc] initWithFormat:format arguments:args];
    [log writeToLogs: 1 withData:logEntry];
    
}


+ (void) Log: (NSInteger) logLevel withFormat: (NSString *) format, ... {
    SNLog *log = [SNLog logManager];
//    va_list args;
//    va_start(args, format);
//    NSString *logEntry = [[NSString alloc] initWithFormat:format arguments:args];
    [log writeToLogs:logLevel withData:format];

    
}
#pragma mark Instance Methods

- (void) writeToLogs: (NSInteger) logLevel withData: (NSString *) logEntry {
    NSString *formattedLogEntry = [self formatLogEntry:logLevel withData:logEntry];
    for (NSObject<SNLogStrategy> *logger in logStrategies) {
        if (logLevel >= logger.logAtLevel) {
            if (logLevel==200)
            {
                [logger writeToDatabaseLog:logLevel withData:formattedLogEntry];
            }
            else if (logLevel==201)
            {
                [logger writeToDatabaseLogForSubLines:logLevel withData:formattedLogEntry];
            }
            else
            {
                [logger writeToLog: logLevel withData: formattedLogEntry];
            }
            
        }
    }
    
}

- (id) init {
    if (self = [super init]) {
        SNConsoleLogger *consoleLogger = [[SNConsoleLogger alloc] init];
        consoleLogger.logAtLevel = 0;
        [self addLogStrategy:consoleLogger];
        
        
        return self;
    } else {
        return nil;
    }
    
    
}

- (void) addLogStrategy: (id<SNLogStrategy>) logStrategy {
    if (logStrategies == nil) {
        logStrategies = [[NSMutableArray alloc] init];
    }
    
    [logStrategies addObject: logStrategy];
}


- (NSString *) formatLogEntry: (NSInteger) logLevel withData: (NSString *) logData {
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *formattedString = [dateFormatter stringFromDate:now];
    
    return [NSString stringWithFormat:@"[%li] - %@ - %@",(long)logLevel, formattedString, logData];
}

@end







@implementation SNConsoleLogger
@synthesize logAtLevel;

- (void) writeToLog:(NSInteger) logLevel withData:(NSString *)logData {
    printf("%s\r\n", [logData UTF8String]);
}

- (void) writeToDatabaseLog:(NSInteger) logLevel withData:(NSString *)logData {
    //printf("%s\r\n", [logData UTF8String]);
}

- (void) writeToDatabaseLogForSubLines:(NSInteger) logLevel withData:(NSString *)logData
{
    
}


@end










@implementation SNFileLogger

@synthesize logAtLevel;
@synthesize logFilePath;

- (id) initWithPathAndSize: (NSString *) filePath forSize: (NSInteger) truncateSize {
    logAtLevel = 2;
    
    if (self = [super init]) {
        self.logFilePath = filePath;
        truncateBytes = truncateSize;
        return self;
    } else {
        return nil;
    }
}

- (void) writeToLog:(NSInteger) logLevel withData:(NSString *)logData {
    
    

    NSData *myData = [NSData dataWithContentsOfFile:logFilePath];
    
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:myData
                                        withPassword:[[AppProperties getInstance] getAppPropertyFor: @"logFilePassword"]
                                               error:&error];
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    logData=[base64Decoded stringByAppendingString:[logData stringByAppendingString:@"\r\n"]];
    
    NSData *data =  [logData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *logEntry = [RNEncryptor encryptData:data
                                         withSettings:kRNCryptorAES256Settings
                                             password:[[AppProperties getInstance] getAppPropertyFor: @"logFilePassword"]
                                                error:&error];
    
    
   
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if(![fm fileExistsAtPath:logFilePath]) {
        [fm createFileAtPath:logFilePath contents:logEntry attributes:nil];
        NSDate *currentDate = [NSDate date];
        NSTimeInterval currentDateTimeInterval = [currentDate timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setFloat:currentDateTimeInterval forKey:@"lastLogTimeStamp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        
        [fm removeItemAtPath:logFilePath error:NULL];
         [fm createFileAtPath:logFilePath contents:nil attributes:nil];
        
        NSDictionary *attrs = [fm attributesOfItemAtPath:logFilePath error:nil];
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        if ([attrs fileSize] > truncateBytes) {
            [file truncateFileAtOffset:0];
        }
        
        [file seekToEndOfFile];
        [file writeData:logEntry];
        [file closeFile];
    }
    
    if ([Util shallExecuteQueryforLogs])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [fm removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/currentlog.txt"] error:NULL];
        [fm removeItemAtPath:[documentsDirectory stringByAppendingFormat:@"/backkuplog.txt"] error:NULL];
        [fm createFileAtPath:[documentsDirectory stringByAppendingFormat:@"/backkuplog.txt"] contents:logEntry attributes:nil];
        [fm createFileAtPath:logFilePath contents:nil attributes:nil];
        NSDate *currentDate = [NSDate date];
        NSTimeInterval currentDateTimeInterval = [currentDate timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setFloat:currentDateTimeInterval forKey:@"lastLogTimeStamp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   
    
    
    
    
   
}

- (void) writeToDatabaseLog:(NSInteger) logLevel withData:(NSString *)logData {
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString* logsStr =[NSString stringWithFormat:@"%@",logData];
    NSData *myData = [logsStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *logsArr=[myDB executeQueryToConvertUnicodeValues:[NSString stringWithFormat:@"SELECT * from SupportLogFile"]];
    
    if ([logsArr count]>=8)
    {
        
        NSDictionary *logsDict=[logsArr objectAtIndex:0];
        NSString *LogFileID=[logsDict objectForKey:@"LogFileID"];
        
        if (LogFileID!=nil && ![LogFileID isKindOfClass:[NSNull class]])
        {
            [myDB deleteFromTable:@"SupportLogFile" where:[NSString stringWithFormat:@"LogFileID='%@'",LogFileID] inDatabase:@""];
        }
    }
    
    [myDB insertSupportLogFileData:myData];
}

- (void) writeToDatabaseLogForSubLines:(NSInteger) logLevel withData:(NSString *)logData {
    
    SQLiteDB *myDB = [SQLiteDB getInstance];
    NSString* logsStr =@"";
    NSArray *logsArr=[myDB executeQueryToConvertUnicodeValues:[NSString stringWithFormat:@"SELECT * from SupportLogFile"]];
    NSString *LogFileID=nil;
    if ([logsArr count]>0)
    {
        NSDictionary *logsDict=[logsArr objectAtIndex:[logsArr count]-1];
        LogFileID=[logsDict objectForKey:@"LogFileID"];
        NSData *data=[logsDict objectForKey:@"logFile"];

        //Determine if string is null-terminated
        char lastByte = '\0';
        [data getBytes:&lastByte range:NSMakeRange([data length]-1, 1)];
        NSString *str;

        if (lastByte == 0x0) {
            //string is null-terminated
            str = [NSString stringWithUTF8String:[data bytes]];
        } else {
            //string is not null-terminated
            str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }

        logsStr = str;
        
    }
    if (logsStr.length>0)
    {
        logsStr=[NSString stringWithFormat:@"%@\n%@",logsStr,logData];
    }
    else
    {
        logsStr=[NSString stringWithFormat:@"%@",logData];
    }
    
    NSData *myData = [logsStr dataUsingEncoding:NSUTF8StringEncoding];
    if (LogFileID!=nil && ![LogFileID isKindOfClass:[NSNull class]])
    {
        [myDB deleteFromTable:@"SupportLogFile" where:[NSString stringWithFormat:@"LogFileID='%@'",LogFileID] inDatabase:@""];
    }
    
    [myDB insertSupportLogFileData:myData];
}

@end