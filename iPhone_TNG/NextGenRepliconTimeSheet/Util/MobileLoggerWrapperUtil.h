//
//  MobileLoggerWrapperUtil.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 8/22/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <repliconkit/repliconkit.h>

@interface MobileLoggerWrapperUtil : LogUtilAbstractWrapper
+(void)logLoggingInfoForDB:(NSString *)logDetails forLogLevel:(LoggerType)loggerType;
@end
