//
//  ReportTechnicalErrors.h
//  iOSCommonLibrary
//
//  Created by Dipta Rakshit on 10/28/14.
//  Copyright (c) 2014 replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface ReportTechnicalErrors : NSObject
{
    
}

+(NSString *)createHTMLToSupportForTechErrorsWithData:(NSMutableDictionary *)dataDict;
+(NSString *)fetchNetworkType;
+(NSString *)fetchTimeZone;
+(NSString *)fetchDeviceLanguage;
+(NSString *)fetchDeviceLocale;

@end
