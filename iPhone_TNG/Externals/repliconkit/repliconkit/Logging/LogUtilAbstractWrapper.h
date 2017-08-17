//
//  LogUtilAbstractWrapper.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 8/22/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "LogUtil.h"

static id delegate;

@interface LogUtilAbstractWrapper : LogUtil

+(void)logLoggingInfoForDB:(NSString *)logDetails forLogLevel:(LoggerType)loggerType;
+(void)setDelegate:(id)_delegate;
@end
