

#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"

typedef NS_ENUM(NSInteger, LoggerType) {
    LoggerSNLogFile,
    LoggerSNLogDatabase,
    LoggerSNLogDatabaseSublines,
    LoggerCocoaLumberjack,
};


@interface LogUtil : NSObject

+(void)setup;

+(BOOL)debugMode;
+(void)setDebugMode:(BOOL)debugMode;

+(void)logLoggingInfo:(NSString *)logDetails forLogLevel:(LoggerType)loggerType;
+ (DDLogFileManagerDefault *)ddLogFileManagerDefault;
+ (DDFileLogger *)ddFileLogger;
@end
