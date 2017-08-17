
#import "LogUtil.h"
#define LOG_LEVEL_DEF ddLogLevel
#import "CocoaLumberjack.h"
#import "LogUtilAbstractWrapper.h"
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;


@implementation LogUtil



static DDLogFileManagerDefault *fileManager;
static DDFileLogger *fileLogger;


static BOOL debugMode;    // Default debug mode is off

+ (void)setup
{
    debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

#if TARGET_OS_IPHONE
    UIColor *pink = [UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
#else
    NSColor *pink = [NSColor colorWithCalibratedRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
#endif

    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:DDLogFlagVerbose];


    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];



    fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[documentsDirectory stringByAppendingFormat:@"/logs"]];

    fileLogger = [[DDFileLogger alloc]initWithLogFileManager:fileManager];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MOBILE_APP"])
    {
      fileLogger.rollingFrequency =  60 * 60 * 24; // 24 hour rolling
    }

    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    fileLogger.maximumFileSize = 384 * 1024; // 384K
    [fileLogger setLogFormatter:[[DDLogFileFormatterDefault alloc]init]];
    [DDLog addLogger:fileLogger];
    double now = [[NSDate date] timeIntervalSince1970];
    
    [[NSUserDefaults standardUserDefaults] setDouble:now forKey:@"startTime"];
}



+ (void)setDebugMode:(BOOL)newDebugMode
{
    debugMode = newDebugMode;
    [[NSUserDefaults standardUserDefaults] setBool:debugMode forKey:@"debugMode"];
}

+ (BOOL)debugMode
{
    return debugMode;
}

+ (DDLogFileManagerDefault *)ddLogFileManagerDefault
{
    return fileManager;
}

+ (DDFileLogger *)ddFileLogger
{
    return fileLogger;
}


+(void)logLoggingInfo:(NSString *)logDetails forLogLevel:(LoggerType)loggerType
{

    if (loggerType==LoggerCocoaLumberjack)
    {
        DDLogVerbose(@"%@",logDetails);
    }

    if (self.debugMode)
    {
        [LogUtilAbstractWrapper logLoggingInfoForDB:logDetails forLogLevel:loggerType];

        
    }
}


@end
