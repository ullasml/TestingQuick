//
//  LogUtilAbstractWrapper.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 8/22/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "LogUtilAbstractWrapper.h"

@implementation LogUtilAbstractWrapper

+(void)logLoggingInfoForDB:(NSString *)logDetails forLogLevel:(LoggerType)loggerType
{

    [delegate logLoggingInfoForDB:logDetails forLogLevel:loggerType];
}

+(void)setDelegate:(id)_delegate
{
    delegate = _delegate;
}

@end
