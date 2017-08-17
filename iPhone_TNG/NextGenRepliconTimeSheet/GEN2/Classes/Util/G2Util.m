//
//  util.m
//  iMarcoPolo
//
//  Created by Vamsi on 11/07/08.
//  Copyright 2008 ENLUME. All rights reserved.
//


#import "G2Util.h"
#import "G2SupportDataModel.h"
#import "RepliconAppDelegate.h"

@implementation G2Util


#pragma mark Utility methods for getting various useful directories

+ (NSString *) getHomeDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	return NSHomeDirectory();
}


+ (NSString *) getApplicationDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, 
														 mask, expandTilde); 
	NSString* appDir = [paths objectAtIndex:0];
	return appDir;	
}

+ (NSString *) getDocumentDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
														 mask, expandTilde); 
	NSString* docDir = [paths objectAtIndex:0];
	return docDir;
}

+ (NSString *) getLibraryDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, 
														 mask, expandTilde); 
	NSString* libDir = [paths objectAtIndex:0];
	return libDir;
}

+ (NSString *) getTemporaryDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	return NSTemporaryDirectory();	
}

+ (NSString *) getDownloadsDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, 
														 mask, expandTilde); 
	NSString* appDir = [paths objectAtIndex:0];
	return appDir;	
}

+ (NSString *) getCachesDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde { 
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
														 mask, expandTilde);
	NSString* appDir = [paths objectAtIndex:0];
	return appDir;
}

+ (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage {
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:errorMessage
													   delegate:nil cancelButtonTitle:RPLocalizedString(@"OK", @"OK")  otherButtonTitles:nil];
	[alertView show];	
	
}

+(void)confirmAlert:(NSString *) title	 errorMessage:(NSString*) confirmMessage {
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:confirmMessage
													   delegate:nil cancelButtonTitle:RPLocalizedString(@"OK", @"OK")  otherButtonTitles:nil];
	[alertView show];	
	
	
}

+(void) showOfflineAlert
{
	NSString *offlineMessage = RPLocalizedString(@"Your device is offline.  Please try again when your device is online.", @"Your device is offline.  Please try again when your device is online.");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"" message: offlineMessage delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
	[alertView show];
	
}

#pragma mark Color getter methods
+ (UIColor *) getNavbarTintColor {
	return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0];
}

+ (UIColor *) getSortbarTintColor {
	//return [UIColor colorWithRed:128.0/255.0 green:123.0/255.0 blue:122.0/255.0 alpha:1.0];
	return [UIColor colorWithRed:86.0/255.0 green:40.0/255.0 blue:115.0/255.0 alpha:1.0];
	//return [UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:139.0/255.0 alpha:1.0];
}


/*#pragma mark -
 // Use the SystemConfiguration framework to determine if the host is available or not
 + (BOOL) isHostReachable:(NSString *)hostName
 {
 BOOL _isDataSourceAvailable;
 
 static BOOL checkNetwork = YES;
 if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
 checkNetwork = NO;
 
 Boolean success; 
 const char *host_name = [hostName UTF8String];
 SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
 SCNetworkReachabilityFlags flags;
 success = SCNetworkReachabilityGetFlags(reachability, &flags);
 _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
 CFRelease(reachability);
 }
 return _isDataSourceAvailable;
 }*/

#pragma mark -
#pragma mark -

+ (void) showConnectionError{
	
//	[Util errorAlert:RPLocalizedString(@"No Internet Connectivity", @"") errorMessage:RPLocalizedString(@"Internet Error", @"")];
//    [Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@" %@ /n %@ ",RPLocalizedString(@"No Internet Connectivity", @""),RPLocalizedString(@"Internet Error", @"")]];//DE1231//Juhi
     [G2Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@" %@ \n %@ ",RPLocalizedString(@"No Internet Connectivity", @""),RPLocalizedString(@"Internet Error", @"")]];//DE4050//Juhi
}

+ (void) showErrorReadingResponseAlert {
//	[self errorAlert:RPLocalizedString(@"Message", @"") errorMessage:RPLocalizedString(@"ResponseRetrievalError", @"")];
    [self errorAlert:@"" errorMessage:RPLocalizedString(@"ResponseRetrievalError", @"")];//DE1231//Juhi
}



#pragma mark Utility methods to check validity
+ (BOOL) isValidZipCode:(NSString *)zipCode {
	
	if(([zipCode longLongValue]>0) &&([zipCode length] == 5))
		return YES;
	else	
		return NO;
}

+ (BOOL) isValidString: (NSString *) str {
	
    if (![str isKindOfClass:[NSNull class] ])
    {
        if(str == nil || [str length] == 0) {
            return NO;
        }
    }
	
	
	return YES;
}

/*+ (NSString *) removeWhiteSpscesInString:(NSString *) str {
 
 if(str != nil) {
 NSString *whiteSpaceEles = @" \n\t\r";
 NSSet *set = [NSSet setWithObjects:@"", @"\n", @"\t", @"\r", nil];
 NSRange range = [str rangeOfCharacterFromSet:set];
 }
 return nil;
 }*/


+ (BOOL) isValidPhoneNumber :(NSString *) phoneNumber{
	

	NSString *phoneNum = phoneNumber;
	NSString *intVals = @"0123456789";
	NSString *extraVals = @"()- ";
	NSUInteger phoneNumLen = [phoneNum length],i,intCount;
	
	if(phoneNumLen < 10)
		return NO;
	NSString *c;
	NSRange range;
	NSRange notFound = {NSNotFound,0};
	for(i=0,intCount=0; i < phoneNumLen ; i++) {
		c = [NSString stringWithFormat:@"%c",[phoneNum characterAtIndex:i]];
		range = [intVals rangeOfString:c];
		if(NSEqualRanges(range,notFound) ) {
			range = [extraVals rangeOfString:c];
			if(NSEqualRanges(range,notFound)) {
				
				
				
				return NO;
			}
		} 
		else {
			intCount++;
		}
	}
	
	//if(intCount != 10 && intCount != 13 && intCount != 11) {
	if(intCount != 12) {
		
			
		
		return NO;
	}
	return YES;
}

+ (BOOL) isValidAge :(NSNumber *) age{
	
	if( age != nil && 
	   ( [age intValue] < 0 || [age intValue] > 150)) 
	{
		return NO;
	}
	return YES;
}

+ (BOOL) isValidEmail :(NSString *) preferredCommunication emailID:(NSString *) emailID{
	
	if ([preferredCommunication isEqualToString: @"EMail"]) {
        if (![emailID isKindOfClass:[NSNull class] ])
        {
            if([emailID length] > 0) {
                //emailid is zero length or invalid type. Hence return false.
                return YES;
            }
            else
                return NO;
        }
        
		
	}
	return YES;
}

+ (BOOL) isValidUserName: (NSString *) str{
	
    if (![str isKindOfClass:[NSNull class] ])
    {
        if([str length]>0){
            int i,c;
            NSUInteger tempCount=[str length];
            for(i=0; i < tempCount ; i++) {
                c =[[NSString stringWithFormat:@"%d",[str characterAtIndex:i]]intValue];
                //checking of pieces whether contains alphanumeric chars
                if(!(( c>64 && c<91)||(c>96 && c<123)||(c>47 && c<58)||(c==46)||(c==95))){
                    
                    return TRUE;
                }
            }	
        }
    }
    
	
	
	return FALSE;
	
}

+ (BOOL) isValidDomainName: (NSString *) str{
	
	NSArray *listItems = [str componentsSeparatedByString:@"."];
	
	NSUInteger	count	=[listItems count];
	if (count==1) {
		return TRUE;
	}
	else{
		while (count>0) {
			NSString *temp =[listItems objectAtIndex:count-1];
			NSUInteger	tempCount=[temp length];
			int i,c;
			for(i=0; i < tempCount ; i++) {
				c =[[NSString stringWithFormat:@"%d",[temp characterAtIndex:i]]intValue];
				//checking of pieces whether contains alphanumeric chars
				if(!(( c>64 && c<91)||(c>96 && c<123)||(c>47 && c<58))){
					
					return TRUE;
				}
			}
			
			count--;
		}
	}
	
	return FALSE;
}

+ (id) getPlistWithName: (NSString *) plistName {
	
	if([G2Util isValidString:plistName] == NO) {
		
		
		
		return nil;
	}
	
	id plist=nil;
	NSBundle *mainBundle = [NSBundle mainBundle];
	
	NSString *path = [mainBundle pathForResource:plistName ofType:@"plist"];
	NSData *plistData = [NSData dataWithContentsOfFile:path];
	NSError *error;
	NSPropertyListFormat format;
	if(plistData != nil && plistData != NULL && plistData) {
        plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                          options:NSPropertyListImmutable
                                                           format:&format
                                                            error:&error];

        
		if(!plist) {
			
			return nil;
		}
	}
	return plist;	
}

+ (NSArray *) getPlistAsArrayWithName: (NSString *) plistName {
	
	return  (NSArray *) [G2Util getPlistWithName:plistName];
}

+ (NSDictionary *) getPlistAsDictionaryWithName: (NSString *) plistName {
	
	return  (NSDictionary *) [G2Util getPlistWithName:plistName];
}

+ (NSString *)  dateParser: (NSString *) dateString {
	
	NSArray *monthSymbolsArray = [[NSArray alloc]initWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",
								  @"Jun",@"Jul",@"Aug",@"Sep",
								  @"Oct",@"Nov",@"Dec", nil];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setAMSymbol:@"AM"];
	[dateFormatter setPMSymbol:@"PM"];
	[dateFormatter setMonthSymbols:monthSymbolsArray];
	
	[dateFormatter setDateFormat:@"MMMM d  hh:mm aaa"];
	
	
	NSDate *current_date = [NSDate dateWithTimeIntervalSince1970:[dateString doubleValue]];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:current_date];
	
	
	
	
	
	return formattedDateString;
}



+ ( unsigned char *) getImageDataAsCString:(NSData *) imageData length: (int) len  {	// into: (unsigned char *) buffer
	
	
	if(imageData != nil && len >= 1) {
		// NSUInteger imageDataLen = len;
		
		unsigned char *buffer = malloc(len);
		if(buffer == NULL) {
			
		
			
			return NULL;
		}
		// bzero(buffer, imageDataLen+1);
		
		
		
		[imageData getBytes:buffer length:len];
		return buffer;
	} else {
		
		
		
		return NO;
	}
	
	
}


+ (NSString *) getAdStatisticsRequestContentWithId:(NSNumber *) reqId data: (NSArray *) data 
										   context:(NSDictionary *) context
{
	NSMutableString *result = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
	[result appendString:@"<ServiceRequest>"];
	
	[result appendFormat:@"<ServiceRequestHeader id=\"%s\" userName=\"%s\" />", [[reqId stringValue] UTF8String], [[context objectForKey:@"userName"] UTF8String]];
	
	[result appendString:@"<ServiceRequestBody>"];
	for(int i=0 ; i < [data count] ; i++) {
		NSDictionary *row = [data objectAtIndex:i];
		[result appendFormat:@"<AdStat id=\"%s\" maximizeCount=\"%s\" touchCount=\"%s\" safariCount=\"%s\" startTime=\"%s\" endTime=\"%s\" />", [[row objectForKey:@"adId"] UTF8String], [[[row objectForKey:@"maximizeCount"] stringValue] UTF8String], [[[row objectForKey:@"touchCount"] stringValue] UTF8String], [[[row objectForKey:@"safariCount"] stringValue] UTF8String], [[row objectForKey:@"startTime"] UTF8String], [[row objectForKey:@"endTime"] UTF8String]];
	}
	[result appendString:@"</ServiceRequestBody>"];
	[result appendString:@"</ServiceRequest>"];	
	return result;
}

+ (Boolean) isStatusBarHidden {
	
	return [[UIApplication sharedApplication] isStatusBarHidden];
	
}


+ (NSString *) getContentOfFileAtPath:(NSString *) path {
	
	NSFileManager *fMgr = [NSFileManager defaultManager];
	if([fMgr fileExistsAtPath:path] == YES && [fMgr isReadableFileAtPath:path] == YES) {
		NSError *err;
		NSString *contentStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
		return contentStr;
	}
	
	return nil;	
}

+ (NSString *) getMonthNameForMonthId:(NSInteger) month {
	
	NSString *month_string=nil;
	switch (month) {
		case 1:
			month_string = @"January";
			break;
		case 2:
			month_string = @"February";
			break;
		case 3:
			month_string = @"March";
			break;
		case 4:
			month_string = @"April";
			break;
		case 5:
			month_string = @"May";
			break;
		case 6:
			month_string = @"June";
			break;
		case 7:
			month_string = @"July";
			break;
		case 8:
			month_string = @"August";
			break;
		case 9:
			month_string = @"September";
			break;
		case 10:
			month_string = @"October";
			break;
		case 11:
			month_string = @"November";
			break;
		case 12:
			month_string = @"December";
			break;
		default:
			break;
	}
	return month_string;
}

+(NSUInteger) getMonthIdForMonthName:(NSString *) month_string {
	
	
	
	if ([month_string isEqualToString:@"January"]) {
		return 1;
	}else if ([month_string isEqualToString:@"February"]) {
		
		
		
		return 2;
	}
	else if ([month_string isEqualToString:@"March"]) {
		return 3;
	}
	else if ([month_string isEqualToString:@"April"]) {
		return 4;
	}
	else if ([month_string isEqualToString:@"May"]) {
		return 5;
	}
	else if ([month_string isEqualToString:@"June"]) {
		return 6;
	}
	else if ([month_string isEqualToString:@"July"]) {
		return 7;
	}
	else if ([month_string isEqualToString:@"August"]) {
		return 8;
	}
	else if ([month_string isEqualToString:@"September"]) {
		return 9;
	}
	else if ([month_string isEqualToString:@"October"]) {
		return 10;
	}
	else if ([month_string isEqualToString:@"November"]) {
		return 11;
	}
	else if ([month_string isEqualToString:@"December"]) {
		return 12;
		
	}
	return 0;
	
}
+(NSString*)convertPickerDateToString:(NSDate*)dateToConvert
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	@try {		
		df.dateStyle = NSDateFormatterLongStyle;
		//[df setDateFormat:@"MMMM dd, yyyy"];
		NSString *longValue=nil;
		NSString *shortValue=nil;
		NSString *mediumValue=nil;
		if ([dateToConvert isKindOfClass:[NSDate class]]) {
			longValue =  [df stringFromDate:dateToConvert];
			if (longValue != nil) {
				return longValue;
			}
			
			if (longValue == nil) {
				df.dateStyle = NSDateFormatterMediumStyle;
				mediumValue =  [df stringFromDate:dateToConvert];
			}
			
			if (mediumValue != nil) {
				return mediumValue;
			}
			if (mediumValue == nil) {
				df.dateStyle = NSDateFormatterShortStyle;
				shortValue =  [df stringFromDate:dateToConvert];
			}
			if (shortValue != nil) 
				return shortValue;
			//pickerValue=[NSString stringWithFormat:@"%@",
			//					 [df stringFromDate:dateToConvert]];
			
			return [df stringFromDate:[NSDate date]];
		}else {
			return nil;
		}
	}
	@finally {
		
	}	
	//return pickerValue;
}	
+(NSString*)convertPickerDateToStringShortStyle:(NSDate*)dateToConvert{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	NSString *pickerValue=nil;
	@try {
		[df setDateStyle:NSDateFormatterMediumStyle];
		if ([dateToConvert isKindOfClass:[NSDate class]]) {
			pickerValue=[NSString stringWithFormat:@"%@",
						 [df stringFromDate:dateToConvert]];
		}else {
			return nil;
		}
	}
	@finally {
		
	}
	
	return pickerValue;	
}

+(NSDate *)convertStringToDate:(NSString*)dateStr{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	[df setDateFormat:@"yyyy-MM-dd"];
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[df setLocale:locale];//DE3171

	NSDate *date =[df dateFromString:dateStr];
    
	return date;
	
}
+(NSDate *)convertStringToDate1:(NSString*)dateStr{
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	@try {
		df.dateStyle = NSDateFormatterLongStyle;
		
		NSDate *date =[df dateFromString:dateStr];
		
		if(date == nil) {
			df.dateStyle = NSDateFormatterMediumStyle;
			NSDate *dateMedium=[df dateFromString:dateStr];
			if (dateMedium != nil) {
				return dateMedium;
			}
			if (dateMedium == nil) {
				df.dateStyle = NSDateFormatterShortStyle;
				NSDate *dateShort =[df dateFromString:dateStr];
				if (dateShort != nil) {
					return dateShort;
				}
			}
			return [NSDate date];
		}
		return date;
	}
	@finally {
		
	}
}

+(NSString *)getDateStringFromDate :(NSDate *)date {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd"];
	//df.dateStyle = NSDateFormatterLongStyle;
	NSString *formattedString =[df stringFromDate:date];
	
	return formattedString;
}

+(NSString *)getDeviceRegionalDateString :(NSString *)dateString {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterLongStyle;
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[df setLocale: locale];
	NSDate *date = [df dateFromString:dateString];
	
	
	df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterLongStyle;
	NSString *formattedString =[df stringFromDate:date];
	if (formattedString==nil || [formattedString isKindOfClass:[NSNull class]]) {
				
		df.dateStyle = NSDateFormatterMediumStyle;
		NSDate *dateMedium=[df dateFromString:dateString];
		if (dateMedium != nil) {
			formattedString = [df stringFromDate:dateMedium];
		}else if (dateMedium == nil) {
			df.dateStyle = NSDateFormatterShortStyle;
			NSDate *dateShort =[df dateFromString:dateString];
			if (dateShort != nil) {
				formattedString = [df stringFromDate:dateShort];
			}else {
				formattedString=[df stringFromDate:[NSDate date]];
			}
		}

		
		
	}
	[[NSUserDefaults standardUserDefaults] setObject:[[df locale] localeIdentifier] forKey:@"lastDateLocale"];
     [[NSUserDefaults standardUserDefaults]  synchronize];
	
	
	
	
	
	return formattedString;
}

+(NSNumber *)getDateValuesFromDate:(NSDate *)dateObj :(NSString *)key {
	unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [calendar components:unitFlags fromDate:dateObj];
	if ([key isEqualToString:@"year"]) {
		return [NSNumber numberWithInteger: [comps year]];
	}if ([key isEqualToString:@"month"]) {
		return [NSNumber numberWithInteger: [comps month]];
	}if ([key isEqualToString:@"day"]) {
		return [NSNumber numberWithInteger: [comps day]];
	}if ([key isEqualToString:@"weekday"]) {
		return [NSNumber numberWithInteger:[comps weekday]];
	}//modified: added "weekday" condition
	
	return nil;
	/*
	 int year = [comps year];
	 int month = [comps month];
	 int day = [comps day];
	 int hour = [comps hour];
	 int minute = [comps minute];
	 int second = [comps second];*/
}

+ (BOOL) date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate {
    return (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending));
}

+(int) getObjectIndex: (NSMutableArray *)inputArr withKey: (id) key  forValue: (NSString *) value
{
	if (inputArr == nil || [inputArr count] <= 0 || key == nil || value == nil) {
		return -1;
	}
	
	NSEnumerator *_enum = [inputArr objectEnumerator];
	id _obj;
	int index = 0;
	while (_obj = [_enum nextObject]) {
		
		if ([_obj isKindOfClass: [NSDictionary class]]) {
			if ([[_obj objectForKey: key] isEqualToString: value])	{
				return index;
			}
			++index;
		}
	}
	return -1;
}

+(NSUInteger) getIndex: (NSArray *) inputArr forObj: (NSString *) value{
	if (inputArr == nil || [inputArr count] <= 0|| value == nil) {
		return -1;
	}
	int index = 0;
	for (id obj in inputArr) {
        if ([obj isKindOfClass:[NSString class]])
        {
            if ([obj isEqualToString: value]) {
                break;
            }
        }
		else if ([obj isKindOfClass:[NSDictionary class]])
        {
            if ([[obj objectForKey:@"name"] isEqualToString: value]) {
                break;
            }
        }
		++index;
	}
	return index;
}

#pragma mark Base64

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
	-2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
	-2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
	-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

//+ (NSString *)encodeBase64WithString:(NSString *)strData {
//	return [QSStrings encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
//}

+ (NSString *)encodeBase64WithData:(NSData *)objData {
	
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	const unsigned char * objRawData = [objData bytes];
	char * objPointer;
	char * strResult;
	
	// Get the Raw Data length and ensure we actually have data
	NSUInteger intLength = [objData length];
	if (intLength == 0) return nil;
	
	// Setup the String-based Result placeholder and pointer within that placeholder
	strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
	objPointer = strResult;
	
	// Iterate through everything
	while (intLength > 2) { // keep going until we have less than 24 bits
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
		*objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
		*objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
		
		// we just handled 3 octets (24 bits) of data
		objRawData += 3;
		intLength -= 3; 
	}
	
	// now deal with the tail end of things
	if (intLength != 0) {
		*objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
		if (intLength > 1) {
			*objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
			*objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
			*objPointer++ = '=';
		} else {
			*objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
			*objPointer++ = '=';
			*objPointer++ = '=';
		}
	}
	
	// Terminate the string-based result
	*objPointer = '\0';
	
	NSString *retVal = [NSString stringWithCString:strResult encoding: NSASCIIStringEncoding];
	free(strResult);

	return retVal;
}

+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	NSUInteger intLength = strlen(objPointer);
	int intCurrent;
	int i = 0, j = 0, k;
	
	unsigned char * objResult;
	objResult = calloc(intLength, sizeof(char));
	
	// Run through the whole string, converting as we go
	while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
		if (intCurrent == '=') {
			if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
				// the padding character is invalid at this point -- so this entire string is invalid
				free(objResult);
				return nil;
			}
			continue;
		}
		
		intCurrent = _base64DecodingTable[intCurrent];
		if (intCurrent == -1) {
			// we're at a whitespace -- simply skip over
			continue;
		} else if (intCurrent == -2) {
			// we're at an invalid character
			free(objResult);
			return nil;
		}
		
		switch (i % 4) {
			case 0:
				objResult[j] = intCurrent << 2;
				break;
				
			case 1:
				objResult[j++] |= intCurrent >> 4;
				objResult[j] = (intCurrent & 0x0f) << 4;
				break;
				
			case 2:
				objResult[j++] |= intCurrent >>2;
				objResult[j] = (intCurrent & 0x03) << 6;
				break;
				
			case 3:
				objResult[j++] |= intCurrent;
				break;
		}
		i++;
	}
	
	// mop things up if we ended on a boundary
	k = j;
	if (intCurrent == '=') {
		switch (i % 4) {
			case 1:
				// Invalid state
				free(objResult);
				return nil;
				
			case 2:
				k++;
				// flow through
			case 3:
				objResult[k] = 0;
		}
	}
	
	// Cleanup and setup the return NSData
	NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
	free(objResult);
	return objData;
	
}

+(NSArray*)getMultiplier:(NSString*)formula
{
	NSMutableString *multiplierString=[NSMutableString stringWithFormat:@"%@",formula];
	/*NSMutableString *multiplierString=[NSMutableString stringWithFormat:@"%@",formula];
     [multiplierString replaceOccurrencesOfString:@"$Net * " withString:@"" options:0 range:NSMakeRange(0, [multiplierString length])];
     NSNumber *multiplierValue=[NSNumber numberWithFloat:[multiplierString floatValue]];
     return multiplierValue;
     NSMutableArray *formulasArray = [NSMutableArray arrayWithObjects:@"$Net * ",@"$net * ",@"$net*",@"$Net*",
     @"$Net* ",@"$net* ",@"$Net *",@"$net *",nil];
     
     
     NSMutableString *multiplierString=[NSMutableString stringWithFormat:@"%@",formula];
     
     for (int i = 0; i < [formulasArray count]; i++) {
     NSString *formulaStr = [formulasArray objectAtIndex:i];
     if ([multiplierString rangeOfString:formulaStr].location == NSNotFound) {
     //return [NSNumber numberWithFloat:[multiplierString floatValue]];
     continue;
     //return nil;
     } else {
     //[requiredString replaceOccurrencesOfString:currentString withString:replString options:0 range:NSMakeRange(0, [requiredString length])];
     [multiplierString replaceOccurrencesOfString:formulaStr withString:@"" options:0 range:NSMakeRange(0, [multiplierString length])];
     NSNumber *multiplierValue=[NSNumber numberWithDouble:[multiplierString doubleValue]];
     return multiplierValue;
     }
     }*/
	
	NSString *token = @"*";
	if ([multiplierString rangeOfString:token].location == NSNotFound){
		
	}else {
        
		NSArray *splitArray = [G2Util splitStringSeperatedByToken:token originalString:multiplierString];
        DLog(@"multiplierString %@",multiplierString);
        DLog(@"splitArray %@",splitArray);
		//[multiplierString replaceOccurrencesOfString:formulaStr withString:@"" options:0 range:NSMakeRange(0, [multiplierString length])];
		if (splitArray != nil && [splitArray count] > 0) {
//			NSNumber *multiplierValue=[NSNumber numberWithDouble:[[splitArray objectAtIndex:1] doubleValue]];
//            DLog(@"multiplierValue %f",[multiplierValue doubleValue]);
			return splitArray;
		}
		
	}
	
	
	
	return nil;
}


+(NSDecimalNumber*)getTotalAmount:(NSDecimalNumber*)netAmount taxAmount:(NSDecimalNumber*)taxAmount
{
	NSDecimalNumber *totalAmount=[[NSDecimalNumber alloc] initWithDouble:[netAmount doubleValue]+[taxAmount doubleValue]];
	return totalAmount;
}

+(void) writeTextToFileInBundle:(NSString *)textContent fileName:(NSString *)fileName {
	
	NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    //write file
    [textContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+(double) getValueFromFormattedDoubleWithDecimalPlaces: (NSString *)formattedDoubleString {
	
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
	[doubleValueWithMaxTwoDecimalPlaces setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:2];
	//changes done to get proper value to dispaly in amount fields
	//double retVal = [[doubleValueWithMaxTwoDecimalPlaces numberFromString:formattedDoubleString] doubleValue];
	double retVal = [[doubleValueWithMaxTwoDecimalPlaces numberFromString:formattedDoubleString] doubleValue];
	
	return retVal;
}

+(NSString *) formatDoubleAsStringWithDecimalPlaces: (double) value {
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
	[doubleValueWithMaxTwoDecimalPlaces setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:2];
    [doubleValueWithMaxTwoDecimalPlaces setRoundingMode: NSNumberFormatterRoundUp];
	//changes done to get proper value to dispaly in amount fields
	//fix for 3201//Juhi
   
    //Rounding backing
//    NSString * myRoundValue=[Util getRoundedValueFromDecimalPlaces:value];
//	NSNumber *myValue = [NSNumber numberWithDouble:[myRoundValue doubleValue]];
//	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
    
    NSNumber *myValue = [NSNumber numberWithDouble:value];
	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
	
	return retVal;
}
+(NSString*) getRoundedValueFromDecimalPlaces: (double)doubleValue {
	
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
	[doubleValueWithMaxTwoDecimalPlaces setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:2];
	[doubleValueWithMaxTwoDecimalPlaces setRoundingMode:NSNumberFormatterRoundHalfUp];
	NSNumber *myValue = [NSNumber numberWithDouble:doubleValue];
	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
	
	return retVal;
}

+(NSString *)getApprovalStatusBasedFromApiStatus: (NSDictionary *)approvalStatusDict {
	
	NSString *approvalStatus = [[approvalStatusDict objectForKey:@"Properties"] objectForKey:@"Name"];
	
	if ([approvalStatus isEqualToString:@"Open"]) {
		approvalStatus = @"Not Submitted";
	}else if ([approvalStatus isEqualToString:@"Waiting"]) {
		approvalStatus = @"Waiting For Approval";
	}else if ([approvalStatus isEqualToString:@"Rejected"]) {
		approvalStatus = @"Rejected";
	}else if ([approvalStatus isEqualToString:@"Approved"]) {
		approvalStatus = @"Approved";
	}
	
	return approvalStatus;
}

+(BOOL) showUnsubmitButtonForSheet :(NSArray *)filteredHistoryArray sheetStatus :(NSString *)status 
						   remainingApprovers :(NSArray *) remainingApproversArray {
	
	if (remainingApproversArray != nil && filteredHistoryArray != nil
		&& [status isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
		
		NSUInteger remaingApproversCount = [remainingApproversArray count];
		NSUInteger lastApprovalActionIndex = [filteredHistoryArray count] -1;
		NSDictionary *lastApprovalActionDict = [filteredHistoryArray objectAtIndex:lastApprovalActionIndex];
		NSString *lastApprovalActionName = [[[lastApprovalActionDict objectForKey:@"Relationships"] objectForKey:@"Type"] 
											objectForKey:@"Identity"];
		
		if ([lastApprovalActionName hasSuffix:@"Approve"] && remaingApproversCount > 0) {
			return YES;
		}
	}
	
	return NO;
}

+(NSString *) getEffectiveDate :(NSArray *)filteredHistoryArray  
{
	NSString *effectiveDate=nil;
    if (filteredHistoryArray != nil && [filteredHistoryArray count]>0) 
    {
        NSUInteger lastApprovalActionIndex = [filteredHistoryArray count] -1;
        NSDictionary *lastApprovalActionDict = [filteredHistoryArray objectAtIndex:lastApprovalActionIndex];
        NSDictionary *effectiveDateDict= [[lastApprovalActionDict objectForKey:@"Properties"] objectForKey:@"EffectiveDate"];
        
        if (effectiveDateDict) 
        {
            effectiveDate=[G2Util convertApiDateDictToDateString:effectiveDateDict];
        }
    }
    
	return effectiveDate;
}

+(void)addToUnsubmittedSheets :(NSArray *)filteredHistoryArray sheetStatus:(NSString *)status 
					  sheetId :(NSString *) _sheetId module :(NSString *)moduleName {
	
	if(filteredHistoryArray != nil && [status isEqualToString:NOT_SUBMITTED_STATUS]){
		
		for (NSDictionary *historyDict in filteredHistoryArray) {
			NSDictionary *approvalTypeDict = [[historyDict objectForKey:@"Relationships"] objectForKey:@"Type"];
			if (approvalTypeDict != nil && ![approvalTypeDict isKindOfClass:[NSNull class]]) {
				NSString *action = [approvalTypeDict objectForKey:@"Identity"];
                //Fix for DE3433//Juhi
//				if ([action isEqualToString:@"Unsubmit"])
               
                if ([action isEqualToString:@"Unsubmit"]||[action isEqualToString:@"Reopen"]){
					NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:moduleName];
					if (unsubmittedSheets == nil) {
						unsubmittedSheets = [NSMutableArray array];
					}
					else {
						unsubmittedSheets = [NSMutableArray arrayWithArray:unsubmittedSheets];
					}
					
					[unsubmittedSheets addObject:_sheetId];
					[[NSUserDefaults standardUserDefaults] 
					 setObject:unsubmittedSheets forKey:moduleName];
                     [[NSUserDefaults standardUserDefaults]  synchronize];
				}
			}
		}
	}
}

/*
 * This method reads date and frames Api Date dictionary
 */

+(NSDictionary *)convertDateToApiDateDictionary: (NSDate *)dateObj {
	
	NSDictionary *apiDateDict = nil;
	unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	//NSCalendar *calendar = [NSCalendar currentCalendar];//DE3171
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171
	NSDateComponents *comps = [calendar components:unitFlags fromDate:dateObj];
	if(comps != nil) {
		apiDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
						@"Date",@"__type",
					   [NSNumber numberWithInteger:[comps year]],@"Year",
					   [NSNumber numberWithInteger:[comps month]],@"Month",
					   [NSNumber numberWithInteger:[comps day]], @"Day",
					   nil];
	}
   
	return apiDateDict;
}

/*
 * This method reads api date info and formats en_US Locale dateString
 */

+(NSString *) convertApiDateDictToDateString: (NSDictionary *)apiDateDict {
	
	NSNumber *year = [apiDateDict objectForKey:@"Year"];
	NSNumber *month = [apiDateDict objectForKey:@"Month"];
	NSNumber *day = [apiDateDict objectForKey:@"Day"];
	
	/*
	NSString *dateString = [NSString stringWithFormat:@"%@ %2d, %@",
							[Util getMonthNameForMonthId:[month intValue]],
							[day intValue],year];
	*/
	NSString *dateString = [NSString stringWithFormat:@"%d-%02d-%02d",[year intValue],[month intValue],[day intValue]];
	return dateString;
}

+(NSString *) convertApiTimeDictToString: (NSDictionary *)apiTimeDict {
	int hours = [[apiTimeDict objectForKey:@"Hours"] intValue];
	int minutes = [[apiTimeDict objectForKey:@"Minutes"] intValue];	
	int seconds = [[apiTimeDict objectForKey:@"Seconds"] intValue];
    

    
    NSString *minsStr=nil;
    if (seconds>=30 && seconds<=60)
    {
        int countSeconds = seconds/30;
        
        int calculateMins=minutes+countSeconds;
        
        if (calculateMins==60)
        {
            calculateMins=0;
            hours=hours+1;
        }

        
        if (calculateMins<10) {
            minsStr=[NSString stringWithFormat:@"0%d",calculateMins];
        }
        else
        {
            
                    
            minsStr=[NSString stringWithFormat:@"%d",calculateMins];
        }
    }
    
    NSString *timeString =nil;
    
    if (minsStr==nil)
    {
        timeString = [NSString stringWithFormat:@"%d:%d",hours,minutes];
    }

	else 
    {
         timeString = [NSString stringWithFormat:@"%d:%@",hours,minsStr];
    }
	
	return timeString;
}

+(NSNumber *) convertApiTimeDictToDecimal: (NSDictionary *)apiTimeDict {
	double hours = [[apiTimeDict objectForKey:@"Hours"] intValue];
	double minutes = [[apiTimeDict objectForKey:@"Minutes"] intValue];
	double seconds = [[apiTimeDict objectForKey:@"Seconds"] intValue];
	double decimalHours = hours + (minutes/60) + (seconds/3600);
//	NSString *decp = [Util getRoundedValueFromDecimalPlaces:decimalHours];
//	NSNumber *decimalTime = [NSNumber numberWithFloat:[decp floatValue]];
	
//	return decimalTime;
    
    return [NSNumber numberWithDouble:decimalHours];
}

+(NSString *) convertApiTimeDictTo12HourTimeString: (NSDictionary *)apiTimeDict {
	int hours = [[apiTimeDict objectForKey:@"Hour"] intValue];
	int minutes = [[apiTimeDict objectForKey:@"Minute"] intValue];
//	int seconds = [[apiTimeDict objectForKey:@"Second"] intValue];
    NSString *am_pm=@"AM";
    
    if (hours>12) {
        hours=hours-12;
        am_pm=@"PM";
    }
    if (hours==12) {
        am_pm=@"PM";
    }
    
    NSString *minutesStr=[NSString stringWithFormat:@"%d",minutes];  
    
    if (![minutesStr isKindOfClass:[NSNull class] ])
    {
        if ([minutesStr length]==1) {
            minutesStr=[NSString stringWithFormat:@"0%@",minutesStr];
        }
    }
    
	
	return [NSString stringWithFormat:@"%d:%@ %@",hours,minutesStr,am_pm];
}



+(NSString *) convertDecimalTimeToHourFormat: (NSNumber *)decimalHours {
	
	int hours  = [decimalHours intValue];
	float secs = ([decimalHours floatValue]- hours)*3600;
    int minutes=0;
    if (secs>=30) 
    {
        do {
            minutes=minutes+1;
            secs=secs-60;
        }
        while (secs>=30);
    }
	
	NSString *timeString = [NSString stringWithFormat:@"%d:%02d",hours,minutes];
	
	return timeString;
}

+(NSDictionary *) convertTimeToHourMinutesSecondsFormat: (NSString *)dateStr {
	
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *date = [dateFormat dateFromString:dateStr ];
    

    
	NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components =
    [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    
    NSDictionary *timeSpanDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Time",@"__type",
                                 [NSNumber numberWithInteger:hours],@"Hour",
                                 [NSNumber numberWithInteger:minutes],@"Minute",
                                 [NSNumber numberWithInteger:seconds],@"Seconds",
								 nil];
    
    
    return timeSpanDict;
}

+(NSDictionary *) convertDecimalHoursToApiTimeDict:(NSString *)decimalHours {

	NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];//Fix for DE3144//Juhi
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * time = [formatter numberFromString:decimalHours];
	
	int hours = [time intValue];
	int minutes = ([time floatValue]-hours)*60;
	int seconds = (([time floatValue]-hours)*60 - minutes)*60;
	NSDictionary *apiTimeDict = [NSDictionary dictionaryWithObjectsAndKeys:
									@"TimeSpan",@"__type",
									[NSNumber numberWithInt:hours],@"Hours",
									[NSNumber numberWithInt:minutes],@"Minutes",
									[NSNumber numberWithInt:seconds],@"Seconds",
								 nil];
	
	return apiTimeDict;
}
/*
 *Method to Convert NSString to NSNumber
 *June 22nd
 */
+(NSNumber *) convertDecimalStringToDecimalNumber: (NSString *)_string {
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];//Fix for DE3144//Juhi
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	//[numberFormatter set];
	NSNumber *decimalNumber = [numberFormatter numberFromString:_string];
   
	if (decimalNumber != nil) {
		return decimalNumber;
	}
	return nil;
}

#pragma mark Encryption

+(NSString*)encryptUserPassword:(NSString*)userPwd
{
	Crypto *encryption = [Crypto sharedInstance];
	NSString *encryptedString = [encryption encryptString:userPwd];
	return encryptedString;
}
+(NSString *)getWeekDayForGivenDate:(NSDate *)givenDate{
	NSCalendar* cal = [NSCalendar currentCalendar];
	NSDateComponents* comps = [cal components:NSCalendarUnitWeekday fromDate:givenDate];
	//return [self getWeekNameForGivenDateComponent:comps];
	return [NSString stringWithFormat:@"%ld",(long)[comps weekday]];
	
}
+(NSString *)getWeekNameForGivenDateComponent:(NSDateComponents *)dateComponent{
	switch ([dateComponent weekday]) {
		case 1:
			return @"Sunday";
			break;
		case 2:
			return  @"Monday" ; 
			break;
		case 3:
			return  @"Tuesday" ; 
			break;
		case 4:
			return  @"Wednesday" ; 
			break;
		case 5:
			return  @"Thursday" ; 
			break;
		case 6:
			return  @"Friday" ; 
			break;
		case 7:
			return  @"Saturday" ; 
			break;
		default:
			return  nil ; 
			break;
	}
}
#pragma mark DecimalPlaces
+(NSString*)formatDecimalPlacesForNumericKeyBoard:(double)valueEntered withDecimalPlaces:(int)requiredDeimalPlaces
{
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
	[doubleValueWithMaxTwoDecimalPlaces setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:requiredDeimalPlaces];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:requiredDeimalPlaces];
	NSNumber *myValue = [NSNumber numberWithDouble:valueEntered];
	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
	
	return retVal;
}

#pragma mark Remove Commas
+(NSString*)removeCommasFromNsnumberFormaters:(id)valueWithCommas
{
	NSMutableString *requireString=[NSMutableString stringWithFormat:@"%@",valueWithCommas];
	
	if ([requireString rangeOfString:@","].location == NSNotFound) {
		return valueWithCommas;
	} else {
        if (![requireString isKindOfClass:[NSNull class] ])
        {
            		[requireString replaceOccurrencesOfString:@"," withString:@"" options:0 range:NSMakeRange(0, [requireString length])];
        }

	}
	
	return requireString;
}

+(UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient
{
	     CGImageRef          imgRef = img.CGImage;
	     CGFloat             width = CGImageGetWidth(imgRef);
	     CGFloat             height = CGImageGetHeight(imgRef);
	     CGAffineTransform   transform = CGAffineTransformIdentity;
	     CGRect              bounds = CGRectMake(0, 0, width, height);
	     CGSize              imageSize = bounds.size;
	     CGFloat             boundHeight;
	     
	     switch (orient) {
			         case UIImageOrientationUp: //EXIF = 1
			             transform = CGAffineTransformIdentity;
			             break;
			         case UIImageOrientationDown: //EXIF = 3
			             transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			             transform = CGAffineTransformRotate(transform, M_PI);
			             break;
			         case UIImageOrientationLeft: //EXIF = 6
			             boundHeight = bounds.size.height;
			             bounds.size.height = bounds.size.width;
			             bounds.size.width = boundHeight;
			             transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			             transform = CGAffineTransformScale(transform, -1.0, 1.0);
			             transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			             break;
			         case UIImageOrientationRight: //EXIF = 8
			             boundHeight = bounds.size.height;
			             bounds.size.height = bounds.size.width;
			             bounds.size.width = boundHeight;
			             transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			             transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			             break;
			         default:
			             // image is not auto-rotated by the photo picker, so whatever the user
			             // sees is what they expect to get. No modification necessary
			             transform = CGAffineTransformIdentity;
			             break;
		     }
	     
	     UIGraphicsBeginImageContext(bounds.size);
	     CGContextRef context = UIGraphicsGetCurrentContext();
	     
	     if ((orient == UIImageOrientationDown) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationUp)){
		         // flip the coordinate space upside down
		         CGContextScaleCTM(context, 1, -1);
		         CGContextTranslateCTM(context, 0, -height);
		     }
	     
	     CGContextConcatCTM(context, transform);
	     CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	     UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	     UIGraphicsEndImageContext();
	     
	     return imageCopy;
	 }
 
+ (UIImage *)resizeImage:(UIImage *)image withinMax:(int)maxDimension {
    int targetWidth = 0;
    int targetHeight = 0;
//    targetWidth = image.size.width;
//    targetHeight = image.size.height;
    if (image.size.width > image.size.height) {
        targetWidth = MIN(maxDimension, image.size.width);
        targetHeight = (int)(((float)image.size.height / (float)image.size.width) * targetWidth);
    } else {
        targetHeight = MIN(maxDimension, image.size.height);
        targetWidth = (int)(((float)image.size.width / (float)image.size.height) * targetHeight);
    }
    if (targetHeight != image.size.height || targetWidth != image.size.width)
        return [G2Util resizeImage: image width: targetWidth height: targetHeight];
    else
        return image;
}

+(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height {
  	
	CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = 0;
//  	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
  	//if (alphaInfo == kCGImageAlphaNone)
  	alphaInfo = kCGImageAlphaNoneSkipLast;  
	     
        //CGImageAlphaInfo alphaInfo=kCGImageAlphaNoneSkipLast;
    
	CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), alphaInfo);
	CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
  	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
  	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
  	UIImage *result = [UIImage imageWithCGImage:ref];
  	CGContextRelease(bitmap);
  	CGImageRelease(ref);
  	
  	return result;
}

#pragma mark ImageRelatedMethods
+(NSArray*)splitStringSeperatedByToken:(NSString*)token originalString:(NSString*)originalString
{
	NSArray *componentsArray = [originalString componentsSeparatedByString:token];
	return componentsArray;
}

+(NSMutableArray *)getAppleSupportedImageFormats
{
	NSMutableArray *imageFormatsArray=[NSMutableArray arrayWithObjects:@"tiff",@"tif",@"jpg",@"jpeg",@"gif",@"png",
									   @"bmp",@"BMPf",@"ico",@"cur",@"xbm",nil];
	return imageFormatsArray;
}

+(BOOL) shallExecuteQuery: (id)serviceSectionName
{
	//DLog(@"in shallExecuteQuery");
	NSNumber *lastSyncInterval = nil;
	lastSyncInterval =[G2SupportDataModel getLastSyncDateForServiceId:serviceSectionName];
	//DLog(@"startDateString %@",lastSyncInterval);
	long currentInterval = [[NSDate date] timeIntervalSince1970];
	
#ifdef DEV_DEBUG
	DLog(@"Util.shallExecuteQuery===>Service Id: %@", serviceSectionName);
#endif
	
	if ([serviceSectionName isEqualToString:@"OtherSection"]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]])
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]] 
				&& ([lastSyncInterval longValue]+ SCHEDULE_DAILY <= currentInterval))) {
				return TRUE;
		}
		return FALSE;
	}
	else if ([serviceSectionName isEqualToString:GENERAL_SUPPORTING_DATA_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]]) 
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_WEEKLY <= currentInterval))) {
				return TRUE;
			}
		return FALSE;
	}
    else if ([serviceSectionName isEqualToString:APPROVALS_SUPPORT_DATA_SERVICE_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]])
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_WEEKLY <= currentInterval))) {
				return TRUE;
			}
		return FALSE;
	}
	else if ([serviceSectionName isEqualToString:EXPENSES_DATA_SERVICE_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]]) 
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_WEEKLY <= currentInterval))) {
				return TRUE;
		}
		return FALSE;
	}
	else if ([serviceSectionName isEqualToString:EXPENSES_SUPPORT_DATA_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]]) 
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_DAILY <= currentInterval))) {
				return TRUE;
			}
		return FALSE;
	}
	else if ([serviceSectionName isEqualToString:TIMESHEET_SUPPORT_DATA_SERVICE_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]]) 
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_DAILY <= currentInterval))) {
				return TRUE;
			}
		return FALSE;
	}
	else if ([serviceSectionName isEqualToString:TIMESHEET_DATA_SERVICE_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]]) 
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_WEEKLY <= currentInterval))) {
				return TRUE;
			}
		return FALSE;
	}
    //US4591//Juhi
    else if ([serviceSectionName isEqualToString:TIMEOFF_SUPPORT_DATA_SERVICE_SECTION]) {
		if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]]) 
			|| (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
				&&  ([lastSyncInterval longValue] + SCHEDULE_DAILY <= currentInterval))) {
				return TRUE;
			}
		return FALSE;
	}
	else {
		return TRUE;
	}

			
}
+(NSDate *) convertDateToUTC:(NSDate *)sourceDate{
    NSTimeZone *currentTimeZone  = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone      = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger currentGMTOffset   = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset          = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval   = gmtOffset - currentGMTOffset;
	
    NSDate *utcDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate];
	//DLog(@"UTC Date %@",utcDate);
    return utcDate;
}
+(NSMutableDictionary *)getDateDictionaryforTimeZoneWith:(NSString *)_abbreviation forDate:(NSDate *)_date{
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	//NSCalendar *calendar = [NSCalendar currentCalendar];//DE3171
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171  
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:_abbreviation]];
	NSDateComponents *comps=nil;
	NSMutableDictionary *dateDetailsDict=nil;
	//NSDate *convertedDate = [self convertDateToUTC:_date];	
	if (_date!=nil) 	{
		comps = [calendar components:reqFields fromDate:_date];
	}
	if (comps!= nil) {
		NSInteger year   = [comps year];
		NSInteger month  = [comps month];
		NSInteger day    = [comps day];
		NSInteger hour   = [comps hour];
		NSInteger minute = [comps minute];
		NSInteger second = [comps second];
		
		dateDetailsDict =[NSMutableDictionary dictionary];
		[dateDetailsDict setObject:[NSString stringWithFormat:@"%ld",(long)year]   forKey:@"Year"];
		[dateDetailsDict setObject:[NSString stringWithFormat:@"%ld",(long)month]  forKey:@"Month"];
		[dateDetailsDict setObject:[NSString stringWithFormat:@"%ld",(long)day]    forKey:@"Day"];
		[dateDetailsDict setObject:[NSString stringWithFormat:@"%ld",(long)hour]   forKey:@"Hour"];
		[dateDetailsDict setObject:[NSString stringWithFormat:@"%ld",(long)minute] forKey:@"Minute"];
		[dateDetailsDict setObject:[NSString stringWithFormat:@"%ld",(long)second] forKey:@"Second"];
	}
    
    
		return dateDetailsDict;
}

+(void)flushDBInfoForOldUser: (BOOL)deleteLogin {
	
	G2LoginModel *loginModel = [[G2LoginModel alloc] init];
	[loginModel flushDBInfoForOldUser:deleteLogin];
	
}
+(NSString *)getDateStringforAPIDateFormat:(NSString *)_format date:(NSDate *)_date{
		if ([_format isEqualToString:@"%B %#d, %y"]){
			return [self getDateStringWithformat:@"Month DD,YY" forDate:_date];
		}
		if ([_format isEqualToString:@"%B %#d, %Y"]) {
			return [self getDateStringWithformat:@"Month DD, YYYY" forDate:_date];
		}
		if ([_format isEqualToString:@"%#d %B %y"]){
			return [self getDateStringWithformat:@"DD Month YY" forDate:_date];

		}
		if ([_format isEqualToString:@"%#d %B %Y"]) {
			return [self getDateStringWithformat:@"DD Month YYYY" forDate:_date];

		}
		if ([_format isEqualToString:@"%y %B %#d"]) {
			return [self getDateStringWithformat:@"YY Month DD" forDate:_date];

		}
		if ([_format isEqualToString:@"%Y %B %#d"]) {
			return [self getDateStringWithformat:@"YYYY Month DD" forDate:_date];

		}
		if ([_format isEqualToString:@"%m/%d/%y"]) {
			return [self getDateStringWithformat:@"MM/DD/YY" forDate:_date];

		}
		if ([_format isEqualToString:@"%m/%d/%Y"]) {
			return [self getDateStringWithformat:@"MM/DD/YYYY" forDate:_date];

		}
		if ([_format isEqualToString:@"%d/%m/%y"]) {
			return [self getDateStringWithformat:@"DD/MM/YY" forDate:_date];

		}
		if ([_format isEqualToString:@"%d/%m/%Y"]) {
			return [self getDateStringWithformat:@"DD/MM/YYYY" forDate:_date];

		}
		if ([_format isEqualToString:@"%y/%m/%d"]) {
			return [self getDateStringWithformat:@"YY/MM/DD" forDate:_date];

		}
		if ([_format isEqualToString:@"%Y/%m/%d"]) {
			return [self getDateStringWithformat:@"YYYY/MM/DD" forDate:_date];

		}
		if ([_format isEqualToString:@"%y/%d/%m"]) {
			return [self getDateStringWithformat:@"YY/DD/MM" forDate:_date];

		}
		if ([_format isEqualToString:@"%b %#d, %y"]) {
			return [self getDateStringWithformat:@"Mon DD, YY" forDate:_date];

		}
		if ([_format isEqualToString:@"%b %#d, %Y"]) {
			return [self getDateStringWithformat:@"Mon DD, YYYY" forDate:_date];

		}
		if ([_format isEqualToString:@"%m.%d.%y"]) {
			return [self getDateStringWithformat:@"MM.DD.YY" forDate:_date];

		}
		if ([_format isEqualToString:@"%m.%d.%Y"]) {
			return [self getDateStringWithformat:@"MM.DD.YYYY" forDate:_date];

		}
		if ([_format isEqualToString:@"%d.%m.%y"]) {
			return [self getDateStringWithformat:@"DD.MM.YY" forDate:_date];

		}	
		if ([_format isEqualToString:@"%d.%m.%Y"]) {
			return [self getDateStringWithformat:@"DD.MM.YYYY" forDate:_date];

		}
	if ([_format isEqualToString:@"%Y/%d/%m"]) {
		return [self getDateStringWithformat:@"YYYY/DD/MM" forDate:_date];
		
	}
	
	return nil;
}
+(NSString *)getDateStringWithformat:(NSString *)_dateformat forDate:(NSDate *)_date{
	NSDateFormatter *df = [[NSDateFormatter alloc]init]; 
	
	@try {
		
	
	if ([_dateformat isEqualToString:@"Month DD,YY"] ||
		[_dateformat isEqualToString:@"Month DD, YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterFullStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@","];
		NSRange spaceRange = [[components objectAtIndex:1]rangeOfString:@" "];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@ %@,%@",[[components objectAtIndex:1]stringByReplacingCharactersInRange:spaceRange withString:@""],
					[components objectAtIndex:0],[components objectAtIndex:2]];
			DLog(@"Formatted String %@",formattedDate);
			return formattedDate;
		}
		
		
	}else if ([_dateformat isEqualToString:@"DD Month YY"]||
			  [_dateformat isEqualToString:@"DD Month YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterFullStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@","];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@%@,%@",[components objectAtIndex:0],
					[components objectAtIndex:1],[components objectAtIndex:2]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"YY Month DD"]||
			  [_dateformat isEqualToString:@"YYYY Month DD"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterFullStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@","];
		NSRange spaceRange = [[components objectAtIndex:2]rangeOfString:@" "];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@%@,%@",[[components objectAtIndex:2]stringByReplacingCharactersInRange:spaceRange withString:@""],
					[components objectAtIndex:1],[components objectAtIndex:0]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"Mon DD, YY"]||
			  [_dateformat isEqualToString:@"Mon DD, YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterMediumStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@","];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@,%@",[components objectAtIndex:0],
					[components objectAtIndex:1]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"MM/DD/YY"]||
			  [_dateformat isEqualToString:@"MM/DD/YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterMediumStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@","];
		NSArray *elements = [[components objectAtIndex:0]componentsSeparatedByString:@" "];
		NSNumber *month     = [self getDateValuesFromDate:_date :@"month"];
		NSRange spaceRange = [[components objectAtIndex:1]rangeOfString:@" "];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%d/%@/%@",[month intValue],[elements objectAtIndex:1],[[components objectAtIndex:1]stringByReplacingCharactersInRange:spaceRange withString:@""]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"DD/MM/YY"]||
			  [_dateformat isEqualToString:@"DD/MM/YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterShortStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@"/"];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@/%@/%@",[components objectAtIndex:1],
					[components objectAtIndex:0],[components objectAtIndex:2]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"YY/MM/DD"]||
			  [_dateformat isEqualToString:@"YYYY/MM/DD"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterShortStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@"/"];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@/%@/%@",[components objectAtIndex:2],
									[components objectAtIndex:0],[components objectAtIndex:1]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"YY/DD/MM"]||
			  [_dateformat isEqualToString:@"YYYY/DD/MM"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterShortStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@"/"];
		if (components != nil) {
			NSString *formattedDate= [NSString stringWithFormat:@"%@/%@/%@",[components objectAtIndex:2],
					[components objectAtIndex:1],[components objectAtIndex:0]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"MM.DD.YY"]||
			  [_dateformat isEqualToString:@"MM.DD.YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterShortStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@"/"];
		if (components != nil) {
			NSString *formattedDate = [NSString stringWithFormat:@"%@.%@.%@",[components objectAtIndex:0],
							 [components objectAtIndex:1],[components objectAtIndex:2]];
			return formattedDate;
		}
	}else if ([_dateformat isEqualToString:@"DD.MM.YY"]||
			  [_dateformat isEqualToString:@"DD.MM.YYYY"]) {
		[df setDateFormat:_dateformat];
		[df setDateStyle:NSDateFormatterShortStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSArray *components = [stringDate componentsSeparatedByString:@"/"];
		if (components != nil) {
			NSString *formattedDate = [NSString stringWithFormat:@"%@.%@.%@",[components objectAtIndex:1],
							 [components objectAtIndex:0],[components objectAtIndex:2]];
			return formattedDate;
		}
	}
		
	}
	@catch (NSException * e) {
		//DLog(@"Exception occured parsing date to preferred format");
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[df setLocale:locale];
		[df setDateStyle:NSDateFormatterMediumStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSMutableCharacterSet *charSet = [NSMutableCharacterSet characterSetWithCharactersInString:@",-/."];
		[charSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
		NSArray *components = [stringDate componentsSeparatedByCharactersInSet:charSet];
		NSString *formattedDate = @"";
		if (components != nil) {
			formattedDate = [NSString stringWithFormat:@"%@ %@, %@",[components objectAtIndex:0],
									   [components objectAtIndex:1], [components objectAtIndex:3]];
		}
		
		
		return formattedDate;
	}
	@finally {
		
	}	
	return nil;
	
}
//+(NSDictionary*)
+(NSString *)getFormattedRegionalDateString:(NSDate *)_date{
	
	NSDateFormatter *df	= [[NSDateFormatter alloc]init]; 
	NSString *weekDay		= [G2Util getWeekDayForGivenDate:_date];
	//NSString *week		= [weekDay substringToIndex:3];
	@try {
		//[df setDateFormat:@"MMM dd, yyyy"];
		[df setDateStyle:NSDateFormatterMediumStyle];
		
		NSArray *arr = [df shortWeekdaySymbols];
		NSString *week = [arr objectAtIndex:[weekDay intValue] -1];
		NSString *stringDate = [df stringFromDate:_date];
		NSString *formattedDate = [NSString stringWithFormat:@"%@, %@",week,stringDate];
		
		return formattedDate;
		
	}@catch (NSException * e) {
		//DLog(@"Exception occured parsing date to preferred format");
		NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[df setLocale:locale];
		[df setDateStyle:NSDateFormatterMediumStyle];
		NSString *stringDate = [df stringFromDate:_date];
		NSMutableCharacterSet *charSet = [NSMutableCharacterSet characterSetWithCharactersInString:@",-/."];
		[charSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
		NSArray *components = [stringDate componentsSeparatedByCharactersInSet:charSet];
		NSString *formattedDate = @"";
		NSArray *arr = [df shortWeekdaySymbols];
		NSString *week = [arr objectAtIndex:[weekDay intValue] -1];
		if (components != nil) {
			formattedDate = [NSString stringWithFormat:@"%@, %@ %@, %@",week,[components objectAtIndex:0],
							 [components objectAtIndex:1], [components objectAtIndex:3]];
		}
		
		
		return formattedDate;
	}
	@finally {
		
	}
	return nil;
}

+(BOOL) validateEmail: (NSString *) _email{
    NSString *emailformat = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *testEmail = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailformat]; 
	
    return [testEmail evaluateWithObject:_email];
}

+(void)updateRightAlignedTextField:(UITextField*)textField withString:(NSString *)string withRange:(NSRange)range withDecimalPlaces:(int)decimalPlaces {
	
	NSString *oldText = textField.text;
    
    //DE4012//Juhi
    if ([oldText rangeOfString:@","].location != NSNotFound) {
        oldText=[oldText stringByReplacingOccurrencesOfString:@","withString:@""];
    } 
    
	if (range.length == 1) {
			//clear
		if (range.location) {
			NSUInteger charIndex = range.location - 1;
			NSString *text = [oldText substringToIndex:charIndex];
			[textField setText:[NSString stringWithFormat:@"%@ ",text]];
		}
		
		if ([[textField text] isEqualToString:@" "]) {
			[textField setText:@""];
		}
		return ;
	}
	else {
        if (![[textField text] isKindOfClass:[NSNull class] ])
        {
            if ([[textField text] length] > 1) {
                NSUInteger spaceindex = [[textField text] length] - 1;
                NSString *text = [oldText substringToIndex:spaceindex];
                NSArray *parts = [text componentsSeparatedByString:@"."];
                if (parts.count == 2) {
                    NSString *after = (NSString*)[parts objectAtIndex:1];
                    if (after.length >= decimalPlaces) {
                        if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=2 ) {
                            return ;
                        }
                    }else if (after.length <= 1 &&([string isEqualToString:@""] && range.length == 1) ) {
                        return ;
                    }
                }
                [textField setText:[NSString stringWithFormat:@"%@%@ ",text,string]];
            }
            else {
                [textField setText:[oldText stringByReplacingCharactersInRange:range withString:string]];
                [textField setText:[NSString stringWithFormat:@"%@ ",[textField text]]];
            }
        }

		return ;
	}
}

+ (NSString *) getNumberOfHours: (NSString *) date1Str andDate2:(NSString *) date2Str
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *date1 = [dateFormat dateFromString:date1Str]; 
     NSDate *date2 = [dateFormat dateFromString:date2Str]; 
    
   

    NSTimeInterval date1Diff = [date1 timeIntervalSinceNow];
    NSTimeInterval date2Diff = [date2 timeIntervalSinceNow];
    NSTimeInterval dateDiff = date2Diff - date1Diff;

    double hours = ((double)dateDiff / 3600.00);
    if (hours<0) {
        hours=(double)24.00+hours;
    }
    
    double returnValue=[[self formatDecimalPlacesForNumericKeyBoard:hours withDecimalPlaces:2]doubleValue];
    
    if (returnValue==24.00) {
        returnValue=0.00;
    }
    
    return [self formatDecimalPlacesForNumericKeyBoard:returnValue withDecimalPlaces:2];
}

+ (double ) getDoubleNumberOfHours: (NSString *) date1Str andDate2:(NSString *) date2Str
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *date1 = [dateFormat dateFromString:date1Str]; 
    NSDate *date2 = [dateFormat dateFromString:date2Str]; 
    
    
    
    NSTimeInterval date1Diff = [date1 timeIntervalSinceNow];
    NSTimeInterval date2Diff = [date2 timeIntervalSinceNow];
    NSTimeInterval dateDiff = date2Diff - date1Diff;
    
    double hours = ((double)dateDiff / 3600.00);
    if (hours<0) {
        hours=(double)24.00+hours;
    }
    
    return hours;
}

+ (NSString *) getOutTime: (NSString *) date1Str noOfHrs:(double) numberOfHours
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *date1 = [dateFormat dateFromString:date1Str]; 
    NSDate *date2 = [date1 dateByAddingTimeInterval:(numberOfHours*3600)] ;
    NSString *returnTime=[dateFormat stringFromDate:date2];
    

    return returnTime;
}

+ (NSString *) getInTime: (NSString *) date1Str noOfHrs:(double) numberOfHours
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"h:mm a"];
    NSDate *date1 = [dateFormat dateFromString:date1Str ];
    NSDate *date2 = [date1 dateByAddingTimeInterval:(-numberOfHours*3600)];
    NSString *returnTime=[dateFormat stringFromDate:date2];
   
    
    return returnTime;
}


+(NSString *)convertMidnightTimeFormat:(NSString *)time
{
    
    if ([time isKindOfClass:[NSString class]]) 
    {
        NSArray *comPonentsArr=[time componentsSeparatedByString:@":"];
        if ([comPonentsArr count]>1) {
            if ([[comPonentsArr objectAtIndex:0] isEqualToString:@"0"])
            {
                time=[NSString stringWithFormat:@"12:%@",[comPonentsArr objectAtIndex:1]];
            }
        }       
        
    }

    return time;
}

+(NSString *) convert12HourTimeStringTo24HourTimeString: (NSString *)timeValue
{
    if ([timeValue isKindOfClass:[NSString class]]) 
    {
        NSArray *am_pmArr=[timeValue componentsSeparatedByString:@" "];
        if ([am_pmArr count]>1) {
            if ([[am_pmArr objectAtIndex:1] isEqualToString:@"PM"]) {
                NSArray *hourArr=[[am_pmArr objectAtIndex:0] componentsSeparatedByString:@":"];
                if ([hourArr count]>1) {
                    NSString *hourValue=[hourArr objectAtIndex:0];
                    int hourValueInt=[hourValue intValue];
                    if (hourValueInt!=12) {
                         hourValueInt=[hourValue intValue]+12;
                    }
                    return [NSString stringWithFormat:@"%d:%@",hourValueInt,[hourArr objectAtIndex:1]];
                }
            }
            else
            {
                NSArray *hourArr=[[am_pmArr objectAtIndex:0] componentsSeparatedByString:@":"];
                if ([hourArr count]>1) {
                    NSString *hourValue=[hourArr objectAtIndex:0];
                    int hourValueInt=[hourValue intValue];
                    if (hourValueInt==12) {
                        hourValueInt=0;
                    }
                    return [NSString stringWithFormat:@"%d:%@",hourValueInt,[hourArr objectAtIndex:1]];
                }
            }
        }
        
        
    }
    return @"";
} 


+(NSString *)mergeTwoHourFormat:(NSString *)hour1 andHour2:(NSString *)hour2
{
    int totalHrs=0;
    int totalMins=0;
    NSArray *compArr1=[hour1 componentsSeparatedByString:@":"];
    NSArray *compArr2=[hour2 componentsSeparatedByString:@":"];
    if ([compArr1 count] >1) 
    {
        totalHrs= [[compArr1 objectAtIndex:0]intValue];
        totalMins= [[compArr1 objectAtIndex:1]intValue];
        
    }
    if ([compArr2 count] >1) 
    {
        totalHrs=totalHrs + [[compArr2 objectAtIndex:0]intValue];
        totalMins=totalMins + [[compArr2 objectAtIndex:1]intValue];
        
    }

  if (totalMins>=60) 
  {
    int divHrs=totalMins/60;
    totalHrs=totalHrs+divHrs;
    int remMin=totalMins % 60;
    totalMins=remMin;
    
   }
   NSString *totalHrsStr=[NSString stringWithFormat:@"%d:",totalHrs];
   NSString *totalMinsStr = [NSString stringWithFormat:@"%d",totalMins] ;
    if (![totalMinsStr isKindOfClass:[NSNull class] ])
    {
        if ([totalMinsStr length]==1) 
        {
            totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
        }
    }
   
   return [totalHrsStr stringByAppendingString:totalMinsStr];
}

+(NSString *)differenceTwoHourFormat:(NSString *)hour1 andHour2:(NSString *)hour2
{
    int totalHrs=0;
    int totalMins=0;
    NSArray *compArr1=[hour1 componentsSeparatedByString:@":"];
    NSArray *compArr2=[hour2 componentsSeparatedByString:@":"];
    if ([compArr1 count] >1) 
    {
        totalHrs= [[compArr1 objectAtIndex:0]intValue];
        totalMins= [[compArr1 objectAtIndex:1]intValue];
        
    }
    if ([compArr2 count] >1) 
    {
        if (totalHrs> [[compArr2 objectAtIndex:0]intValue]) 
        {
            totalHrs=totalHrs - [[compArr2 objectAtIndex:0]intValue];
        }
        else 
        {
            totalHrs=[[compArr2 objectAtIndex:0]intValue]-totalHrs;
        }
        
        
        if (totalMins> [[compArr2 objectAtIndex:0]intValue]) 
        {
            totalMins=totalMins - [[compArr2 objectAtIndex:1]intValue];
        }
        else 
        {
            totalMins=[[compArr2 objectAtIndex:0]intValue]-totalMins;
        }
        
        
        
        
    }
    
    if (totalMins>=60) 
    {
        int divHrs=totalMins/60;
        totalHrs=totalHrs+divHrs;
        int remMin=totalMins % 60;
        totalMins=remMin;
        
    }
    NSString *totalHrsStr=[NSString stringWithFormat:@"%d:",totalHrs];
    NSString *totalMinsStr = [NSString stringWithFormat:@"%d",totalMins] ;
    if (![totalMinsStr isKindOfClass:[NSNull class] ])
    {
        if ([totalMinsStr length]==1) 
        {
            totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
        }
    }
    
    return [totalHrsStr stringByAppendingString:totalMinsStr];
}


+(NSMutableArray *)getTaxesInfoArray:(NSString *)identity :(NSString *)typeName
{
    G2SupportDataModel *supportDataMdl = [[G2SupportDataModel alloc] init];
    NSMutableArray *expenseTaxCodesLocalArray=[supportDataMdl getExpenseLocalTaxcodesFromDB:identity withExpenseType:typeName];
    NSMutableArray *taxDetailsArray=[supportDataMdl getAmountTaxCodesForSelectedProjectID:identity 
                                                                          withExpenseType:typeName];
    
    //DE8583
    if ([taxDetailsArray count] > 0)
    {
        for (int x=0; x<[taxDetailsArray count]-1; x++) {
            NSMutableDictionary *mutableDict=[NSMutableDictionary dictionary];
            if (taxDetailsArray != nil && [taxDetailsArray count] > 0) {
                [mutableDict addEntriesFromDictionary:[taxDetailsArray objectAtIndex:x]];					
            }
            
            NSString *formulaString=[[taxDetailsArray objectAtIndex:x] objectForKey:@"formula"];
            if (formulaString !=nil && ![formulaString isKindOfClass:[NSNull class]]) {
                
                NSString *localTax=[expenseTaxCodesLocalArray objectAtIndex:x];
                if (localTax!=nil && ![localTax isKindOfClass:[NSNull class]]) {
                    [mutableDict setObject:localTax forKey:@"formula"];
                }
                
            }
            
            [taxDetailsArray replaceObjectAtIndex:x withObject:mutableDict];
        }
        return taxDetailsArray;
    }
    
    return nil;
}

+ (UIImage*)thumbnailImage:(NSString*)fileName
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    UIImage *thumbnail = [appDelegate.thumbnailCache objectForKey:fileName];
    
    if (nil == thumbnail)
    {
        NSArray *sepratedCompArr=[fileName componentsSeparatedByString:@"."];
        if ([sepratedCompArr count]==2) 
        {
            NSString *thumbnailFile=[[NSBundle mainBundle] pathForResource:[sepratedCompArr objectAtIndex:0] ofType:[sepratedCompArr objectAtIndex:1]];
            //        NSString *thumbnailFile = [NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] resourcePath], fileName];
            thumbnail = [UIImage imageWithContentsOfFile:thumbnailFile];
            [appDelegate.thumbnailCache setObject:thumbnail forKey:fileName];
        }
        
    }
    return thumbnail;
}

+(NSMutableArray *)sortArray:(NSMutableArray *)sortArray inAscending:(BOOL)isTimeSheetSort  usingKey:(NSString *)key
{
    NSMutableArray *tempArray=[self convertArrayWithStringObjectsToDateObjects:sortArray sortKey:key];
    
    if (isTimeSheetSort) 
    {
        NSSortDescriptor *sortTimeInDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time_in" ascending:FALSE];
        [tempArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];
        
        
        NSMutableArray *sortArrayForTimeOut=[[NSMutableArray alloc] init];
        NSUInteger count=[tempArray count];
        for (int i=0; i<count; i++) 
        {
            if ([[[tempArray objectAtIndex:i] valueForKey:@"time_in"] isKindOfClass:[NSNull class]]) 
            {
                [sortArrayForTimeOut addObject:[tempArray objectAtIndex:i]];
            }
        }
        
        NSSortDescriptor *sortTimeOutDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time_out" ascending:FALSE];
        [sortArrayForTimeOut sortUsingDescriptors:[NSArray arrayWithObject:sortTimeOutDescriptor]];
        
        
        for (int i=0; i<[sortArrayForTimeOut count]; i++) 
        {
            [tempArray removeObjectAtIndex:count-(i+1)];
            
        }
        
        for (int k=0; k<[sortArrayForTimeOut count]; k++)
        {
             [tempArray insertObject:[sortArrayForTimeOut objectAtIndex:k] atIndex:k];
        }
        
       
    

    }
    else 
    {
        NSSortDescriptor *sortTimeInDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time_in" ascending:TRUE];
        [tempArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];
        
    }
    tempArray=[self convertArrayWithDateObjectsToStringObjects:tempArray sortKey:key];
    return tempArray;

}


+(NSMutableArray *)convertArrayWithStringObjectsToDateObjects:(NSMutableArray *)unshortedArray sortKey:(NSString *)key
{
    NSMutableArray *tempArray=[NSMutableArray array];
    for(int i=0;i<[unshortedArray count];i++)
    {
        NSMutableDictionary *dctTimeSheet=[unshortedArray objectAtIndex:i];
        if ([dctTimeSheet objectForKey:@"time_in"]!=nil && ![[dctTimeSheet objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) 
        {
            
            NSString *strDate=[dctTimeSheet objectForKey:@"time_in"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSDate *date = [dateFormat dateFromString:strDate ];
            
            [dctTimeSheet removeObjectForKey:@"time_in"];
            [dctTimeSheet setObject:date forKey:@"time_in"];
             
            
        }
        if ([dctTimeSheet objectForKey:@"time_out"]!=nil && ![[dctTimeSheet objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) 
        {
            
            NSString *strDate=[dctTimeSheet objectForKey:@"time_out"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSDate *date = [dateFormat dateFromString:strDate ];
            
            [dctTimeSheet removeObjectForKey:@"time_out"];
            [dctTimeSheet setObject:date forKey:@"time_out"];
            
            
        }

        [tempArray addObject:dctTimeSheet];
       
        
    }
    return tempArray;
    
}

+(NSMutableArray *)convertArrayWithDateObjectsToStringObjects:(NSMutableArray *)shortedArray sortKey:(NSString *)key
{
    NSMutableArray *tempArray=[NSMutableArray array];
    for(int i=0;i<[shortedArray count];i++)
    {
        NSMutableDictionary *dctTimeSheet=[shortedArray objectAtIndex:i];
        if ([dctTimeSheet objectForKey:@"time_in"]!=nil && ![[dctTimeSheet objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) 
        {
            
            NSDate *strDate=[dctTimeSheet objectForKey:@"time_in"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSString *date = [dateFormat stringFromDate:strDate];
            
            [dctTimeSheet removeObjectForKey:@"time_in"];
            [dctTimeSheet setObject:date forKey:@"time_in"];
            
            
        }
        if ([dctTimeSheet objectForKey:@"time_out"]!=nil && ![[dctTimeSheet objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) 
        {
            
            NSDate *strDate=[dctTimeSheet objectForKey:@"time_out"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSString *date = [dateFormat stringFromDate:strDate];
            
            [dctTimeSheet removeObjectForKey:@"time_out"];
            [dctTimeSheet setObject:date forKey:@"time_out"];
            
            
        }

        
        [tempArray addObject:dctTimeSheet];
        
    }
    return tempArray;
    
}
@end

