//
//  MobileLoggerWrapperUtil.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 8/22/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "MobileLoggerWrapperUtil.h"
#import "SNLog.h"

@implementation MobileLoggerWrapperUtil

+(void)logLoggingInfoForDB:(NSString *)logDetails forLogLevel:(LoggerType)loggerType
{


    if (loggerType==LoggerSNLogFile)
    {
        [SNLog Log:2 withFormat:logDetails];
    }
    else if (loggerType==LoggerSNLogDatabase)
    {
        [SNLog Log:200 withFormat:logDetails];
    }
    else if (loggerType==LoggerSNLogDatabaseSublines)
    {
        [SNLog Log:201 withFormat:logDetails];
    }

}

@end
