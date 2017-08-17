//
//  ReportTechnicalErrors.m
//  iOSCommonLibrary
//
//  Created by Dipta Rakshit on 10/28/14.
//  Copyright (c) 2014 replicon. All rights reserved.
//

#import "ReportTechnicalErrors.h"
#import "SDiPhoneVersion.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"

@implementation ReportTechnicalErrors

+(NSString *)createHTMLToSupportForTechErrorsWithData:(NSMutableDictionary *)dataDict
{
    NSString *HTMLString=nil;

    if (dataDict!=nil)
    {
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *tzName = [self fetchTimeZone];
        NSString *deviceLanguageStr = [self fetchDeviceLanguage];
        NSString *localeString=[self fetchDeviceLocale];
        NSString *deviceModel=[SDiPhoneVersion deviceName];


        if ([[dataDict objectForKey:@"productName"] isEqualToString:@"Cloud Clock (iOS)"])
        {
            NSString *networkType=nil;
            Reachability *reach = [Reachability reachabilityForInternetConnection];
            NetworkStatus status = [reach currentReachabilityStatus];

            switch(status)
            {
                case NotReachable:
                    networkType = @"No Connection";
                    break;

                case ReachableViaWiFi:
                    networkType = @"WiFi";
                    break;
                case ReachableViaWWAN:
                    networkType = @"WWAN";
                    break;

            }

            if(networkType == nil)
            {
                CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
                NSLog(@"Current Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);

                NSString *currentStatus = telephonyInfo.currentRadioAccessTechnology;

                if((currentStatus == CTRadioAccessTechnologyGPRS) || (currentStatus == CTRadioAccessTechnologyEdge) || (currentStatus == CTRadioAccessTechnologyCDMA1x)  )
                {
                    networkType= @"2G";
                }
                else if((currentStatus == CTRadioAccessTechnologyWCDMA)        ||
                        (currentStatus == CTRadioAccessTechnologyHSUPA)        ||
                        (currentStatus == CTRadioAccessTechnologyCDMAEVDORev0) ||
                        (currentStatus == CTRadioAccessTechnologyCDMAEVDORevA) ||
                        (currentStatus == CTRadioAccessTechnologyCDMAEVDORevB) ||
                        (currentStatus == CTRadioAccessTechnologyHSDPA)        ||
                        (currentStatus == CTRadioAccessTechnologyeHRPD))
                {
                    networkType=  @"3G";
                }
                else if(currentStatus == CTRadioAccessTechnologyLTE)
                {
                    networkType=  @"4G";
                }

            }


            NSString *dataConnectionStr=networkType;


            HTMLString=[NSString stringWithFormat:@"<table align='center' width=500><tr><td><h1>Request Help For CloudClock(iOS)</h1></td><td></tr><tr><td colspan='2'><hr/></td></tr><tr><td ><h2>User Information</h2><strong>Name:</strong> %@<br/><b>Company:</b> %@<br/><b>Clock Name:</b> %@<br/><b>Email Address:</b> %@<br/><b>Phone Number:</b> %@<br/><b>Device Version:</b> %@<br/><b>OS Version:</b> %@<br/><b>Application Version:</b> %@<br/><b>Product Name:</b> %@<br/><b>Device Language:</b> %@<br/><b>Region Format:</b> %@<br/><b>Device Time Zone:</b> %@<br/><b>Data Connection:</b> %@<br/><b>Error Message Displayed to the User:</b> %@<br/><b>Error ID:</b> %@<br/></td></tr><tr><td ><strong>Submitted URL:</strong> http://www.replicon.com/contact-support<br/></td></tr><tr><td colspan='2'><hr/></td></tr><tr><td ><h2>Problem Description</h2>%@ <br/><br/><b>Can you reproduce the issue?:</b> I don't know<br/></td></tr><tr><td align='center'>&nbsp;</td></tr></table>",[dataDict objectForKey:@"username"],[dataDict objectForKey:@"company"],[dataDict objectForKey:@"clockName"],@"mobiledevsupport@replicon.com",@"1234567890",deviceModel,currSysVer,appVersion,[dataDict objectForKey:@"productName"],deviceLanguageStr,localeString,tzName,dataConnectionStr,[dataDict objectForKey:@"errorMsg"],[dataDict objectForKey:@"errorID"],[dataDict objectForKey:@"description"]];
        }

        else
        {

            NSString *dataConnectionStr=[self fetchNetworkType];

            HTMLString=[NSString stringWithFormat:@"<table align='center' width=500><tr><td><h1>Request Help For Mobile(iOS)</h1></td><td></tr><tr><td colspan='2'><hr/></td></tr><tr><td ><h2>User Information</h2><strong>Name:</strong> %@<br/><b>Company:</b> %@<br/><b>Email Address:</b> %@<br/><b>Phone Number:</b> %@<br/><b>Device Version:</b> %@<br/><b>OS Version:</b> %@<br/><b>Application Version:</b> %@<br/><b>Product Name:</b> %@<br/><b>Device Language:</b> %@<br/><b>Region Format:</b> %@<br/><b>Device Time Zone:</b> %@<br/><b>Data Connection:</b> %@<br/><b>Error Message Displayed to the User:</b> %@<br/><b>Error ID:</b> %@<br/></td></tr><tr><td ><strong>Submitted URL:</strong> http://www.replicon.com/contact-support<br/></td></tr><tr><td colspan='2'><hr/></td></tr><tr><td ><h2>Problem Description</h2>%@ <br/><br/><b>Can you reproduce the issue?:</b> I don't know<br/></td></tr><tr><td align='center'>&nbsp;</td></tr></table>",[dataDict objectForKey:@"username"],[dataDict objectForKey:@"company"],@"mobiledevsupport@replicon.com",@"1234567890",deviceModel,currSysVer,appVersion,[dataDict objectForKey:@"productName"],deviceLanguageStr,localeString,tzName,dataConnectionStr,[dataDict objectForKey:@"errorMsg"],[dataDict objectForKey:@"errorID"],[dataDict objectForKey:@"description"]];
        }



    }

    return HTMLString;

}


+(NSString *)fetchNetworkType
{
    NSString *networkType=@"";
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;

    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }

    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            networkType= @"No Connection";
            break;

        case 1:
            networkType= @"2G";
            break;

        case 2:

            networkType=  @"3G";
            break;

        case 3:

            networkType=  @"4G";
            break;

        case 4:

            networkType=  @"LTE";
            break;

        case 5:

            networkType=  @"WiFi";
            break;


        default:
            break;
    }

    return networkType;
}

+(NSString *)fetchTimeZone
{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    return [timeZone name];
}

+(NSString *)fetchDeviceLanguage
{
    return [[NSLocale preferredLanguages] firstObject];
}

+(NSString *)fetchDeviceLocale
{
    NSLocale *currentLocale=[NSLocale currentLocale];
    return [currentLocale displayNameForKey:NSLocaleIdentifier
                                      value:[currentLocale localeIdentifier]];
}

@end
