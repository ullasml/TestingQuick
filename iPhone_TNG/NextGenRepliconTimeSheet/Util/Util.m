#import "Util.h"
#import "AppDelegate.h"
#import "RepliconAppDelegate.h"
#import "LoginModel.h"
#import "ACSimpleKeychain.h"
#import "FrameworkImport.h"
#import <CoreTelephony/CoreTelephonyDefines.h>
#import "NSString+Double_Float.h"
#import "NSNumber+Double_Float.h"
#import "TimeoffModel.h"
#import "RepliconServiceManager.h"
#import "ClientType.h"
#import "MobileLoggerWrapperUtil.h"

@implementation Util
#define SCHEDULE_WEEKLY 604800

#pragma mark Utility methods for getting various useful directories


+ (NSString *) getDocumentDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 mask, expandTilde);
	NSString* docDir = [paths objectAtIndex:0];
	return docDir;
}

+ (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage {

    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        [LogUtil logLoggingInfo:@"Application is in background" forLogLevel:LoggerCocoaLumberjack];
    }
    else
    {
        [LogUtil logLoggingInfo:@"Application is in foreground" forLogLevel:LoggerCocoaLumberjack];
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:nil
                                                message:errorMessage
                                                  title:title
                                                    tag:LONG_MIN];
    }
    
    

	
}

+ (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage delegate:(id) delegate {

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:delegate
                                            message:errorMessage
                                              title:title
                                                tag:LONG_MIN];

    
}

+(void)confirmAlert:(NSString *) title	 errorMessage:(NSString*) confirmMessage {

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:nil
                                            message:confirmMessage
                                              title:title
                                                tag:LONG_MIN];

}

+(void) showOfflineAlert
{
	NSString *offlineMessage = RPLocalizedString(@"Your device is offline.  Please try again when your device is online.", @"Your device is offline.  Please try again when your device is online.");
    
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:nil
                                            message:offlineMessage
                                              title:@""
                                                tag:LONG_MIN];
}

#pragma mark Color getter methods

+ (UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha {
    
    assert(7 == [hex length]);
    assert('#' == [hex characterAtIndex:0]);
    
    NSString *redHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(1, 2)]];
    NSString *greenHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(3, 2)]];
    NSString *blueHex = [NSString stringWithFormat:@"0x%@", [hex substringWithRange:NSMakeRange(5, 2)]];
    
    unsigned redInt = 0;
    NSScanner *rScanner = [NSScanner scannerWithString:redHex];
    [rScanner scanHexInt:&redInt];
    
    unsigned greenInt = 0;
    NSScanner *gScanner = [NSScanner scannerWithString:greenHex];
    [gScanner scanHexInt:&greenInt];
    
    unsigned blueInt = 0;
    NSScanner *bScanner = [NSScanner scannerWithString:blueHex];
    [bScanner scanHexInt:&blueInt];
    
    return [UIColor colorWithRed:(redInt/255.0) green:(greenInt/255.0) blue:(blueInt/255.0) alpha:alpha];
}




#pragma mark -
#pragma mark ThumbnailImage Methods


+ (UIImage*)thumbnailImage:(NSString*)fileName
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIImage *thumbnail = [appDelegate.thumbnailCache objectForKey:fileName];
    
    if (nil == thumbnail)
    {
        NSArray *sepratedCompArr=[fileName componentsSeparatedByString:@"."];
        if ([sepratedCompArr count]==2)
        {
            NSString *thumbnailFile=[[NSBundle mainBundle] pathForResource:[sepratedCompArr objectAtIndex:0] ofType:[sepratedCompArr objectAtIndex:1]];
            thumbnail = [UIImage imageWithContentsOfFile:thumbnailFile];
            [appDelegate.thumbnailCache setObject:thumbnail forKey:fileName];
        }
        
    }
    return thumbnail;
}

+(void) setToolbarLabel: (UIViewController *)parentController withText: (NSString *)labelText
{
	UILabel *topToolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180,20)];

    [topToolbarLabel setFrame:CGRectMake(0, 0, 200,40)];
    [topToolbarLabel setNumberOfLines:0];
    [topToolbarLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [topToolbarLabel setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:17.0f]];
    [topToolbarLabel setTextAlignment:NSTextAlignmentCenter];
    [topToolbarLabel setBackgroundColor:[UIColor clearColor]];
    [topToolbarLabel setTextColor:[UIColor blackColor]];
    [topToolbarLabel setTextAlignment: NSTextAlignmentCenter];
    [topToolbarLabel setText: labelText];

    parentController.navigationItem.titleView = topToolbarLabel;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark Base64

//static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
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



+ (NSString *)encodeBase64WithData:(NSData *)objData {
    static char* alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSUInteger length = objData.length;
    unsigned const char* rawData = objData.bytes;
    
    //empty data = empty output
    if (length == 0) {
        return @"";
    }
    
    NSUInteger outputLength = (((length + 2) / 3) * 4);
    
    //let's allocate buffer for the output
    char* rawOutput = malloc(outputLength + 1);
    
    //with each step we get 3 bytes from the input and write 4 bytes to the output
    for (unsigned int i = 0, outputIndex = 0; i < length; i += 3, outputIndex += 4) {
        BOOL triple = NO;
        BOOL quad = NO;
        
        //get 3 bytes (or only 1 or 2 when we have reached the end of input)
        unsigned int value = rawData[i];
        value <<= 8;
        
        if (i + 1 < length) {
            value |= rawData[i + 1];
            triple = YES;
        }
        
        value <<= 8;
        
        if (i + 2 < length) {
            value |= rawData[i + 2];
            quad = YES;
        }
        
        //3 * 8 bits written as 4 * 6 bits (indexing the 64 chars of the alphabet)
        //write = if end of input reached
        rawOutput[outputIndex + 3] = (quad) ? alphabet[value & 0x3F] : '=';
        value >>= 6;
        rawOutput[outputIndex + 2] = (triple) ? alphabet[value & 0x3F] : '=';
        value >>= 6;
        rawOutput[outputIndex + 1] = alphabet[value & 0x3F];
        value >>= 6;
        rawOutput[outputIndex] = alphabet[value & 0x3F];
    }
    
    rawOutput[outputLength] = 0;
    
    NSString* output = [NSString stringWithCString:rawOutput encoding:NSASCIIStringEncoding];
    
    free(rawOutput);
    
    return output;
}

#pragma mark RandomID generation method

+(id)getRandomGUID
{
    Guid* guid = [Guid randomGuid];
    return guid.description;
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
#pragma mark -
#pragma mark other methods

+(void)flushDBInfoForOldUser: (BOOL)deleteLogin {
	
	LoginModel *loginModel = [[LoginModel alloc] init];
	[loginModel flushDBInfoForOldUser:deleteLogin];
	
}

+(NSDate *) convertApiDateDictToDateFormat: (NSDictionary *)apiTimeDict
{
    int day   = [[apiTimeDict objectForKey:@"day"] intValue];
	int month = [[apiTimeDict objectForKey:@"month"] intValue];
    int year = [[apiTimeDict objectForKey:@"year"] intValue];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [gregorianCalendar dateFromComponents:components];
    
    
    return date;
}

+ (NSDate *) convertApiDateTimeDictToDateFormatForLocalTime: (NSDictionary *)apiTimeDict dateDict: (NSDictionary *)apiDateDict
{
    int day   = [[apiDateDict objectForKey:@"day"] intValue];
	int month = [[apiDateDict objectForKey:@"month"] intValue];
    int year = [[apiDateDict objectForKey:@"year"] intValue];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:[[apiTimeDict objectForKey:@"Hour"] intValue]];
    [components setMinute:[[apiTimeDict objectForKey:@"Minute"] intValue]];
    [components setSecond:[[apiTimeDict objectForKey:@"Second"] intValue]];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *date = [gregorianCalendar dateFromComponents:components];
    
    
    return date;
}

+ (NSDate *) convertApiDateTimeDictToGMTDateWithTimeDict: (NSDictionary *)apiTimeDict dateDict: (NSDictionary *)apiDateDict
{
        int day   = [[apiDateDict objectForKey:@"day"] intValue];
        int month = [[apiDateDict objectForKey:@"month"] intValue];
        int year = [[apiDateDict objectForKey:@"year"] intValue];
    
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setHour:[[apiTimeDict objectForKey:@"Hour"] intValue]];
        [components setMinute:[[apiTimeDict objectForKey:@"Minute"] intValue]];
        [components setSecond:[[apiTimeDict objectForKey:@"Second"] intValue]];
        [components setDay:day];
        [components setMonth:month];
        [components setYear:year];
        NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
        NSDate *date = [gregorianCalendar dateFromComponents:components];
    
    
        return date;
}

+ (NSDate *) dateForYear:(NSNumber *)year
                   month:(NSNumber *)month
                     day:(NSNumber *)day
                    hour:(NSNumber *)hour
                  minute:(NSNumber *)minute
                  second:(NSNumber *)second
{
    NSDictionary *timeDictionary = @{@"Hour": hour,
                                     @"Minute": minute,
                                     @"Second": second};

    NSDictionary *dateDictionary = @{@"day": day,
                                     @"month": month,
                                     @"year": year};

    return [self convertApiDateTimeDictToGMTDateWithTimeDict:timeDictionary dateDict:dateDictionary];
}

+(NSDate *)convertTimestampFromDBToDate:(NSString*)dateStr
{
    NSDate *dateExpires = [NSDate dateWithTimeIntervalSince1970:[dateStr newDoubleValue]];
	return dateExpires;
	
}
+ (NSTimeInterval)convertDateToTimestamp:(NSDate *)date
{
    return [date timeIntervalSince1970];//DE19143 && DE19144 Ullas M L
}

+(NSString*)convertPickerDateToStringShortStyle:(NSDate*)dateToConvert
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //Fix for Defect DE14916
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	[df setLocale:locale];
    [df setTimeZone:timeZone];
	
    NSString *pickerValue=nil;
	@try
    {
		[df setDateStyle:NSDateFormatterMediumStyle];
		if ([dateToConvert isKindOfClass:[NSDate class]])
        {
			pickerValue=[NSString stringWithFormat:@"%@",
						 [df stringFromDate:dateToConvert]];
		}
        else
        {
			return nil;
		}
	}
	@finally
    {
		
	}
	
	return pickerValue;
}

+(NSString *) convertApiTimeDictToString: (NSDictionary *)apiTimeDict
{
	int hours =0.0;
    int minutes=0.0;
    int seconds =0.0;
    //DE20346 Ullas M L
    if (apiTimeDict!=nil && ![apiTimeDict isKindOfClass:[NSNull class]])
    {
        hours = [[apiTimeDict objectForKey:@"hours"] intValue];
        minutes = [[apiTimeDict objectForKey:@"minutes"] intValue];
        seconds = [[apiTimeDict objectForKey:@"seconds"] intValue];
        
    }
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
+(NSString *)convertApiTimeDictToDateStringWithDesiredFormat:(NSDictionary *)apiTimeDict
{
    int day   = [[apiTimeDict objectForKey:@"day"] intValue];
	int month = [[apiTimeDict objectForKey:@"month"] intValue];
    int year = [[apiTimeDict objectForKey:@"year"] intValue];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [gregorianCalendar dateFromComponents:components];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr=[dateFormat stringFromDate:date];
    
    
    return dateStr;
    
}
+(NSNumber *) convertApiTimeDictToDecimal: (NSDictionary *)apiTimeDict
{
	double hours =0.0;
    double minutes=0.0;
    double seconds =0.0;
    //DE20346 Ullas M L
    if (apiTimeDict!=nil && ![apiTimeDict isKindOfClass:[NSNull class]])
    {
        hours = [[apiTimeDict objectForKey:@"hours"] newDoubleValue];
        minutes = [[apiTimeDict objectForKey:@"minutes"] newDoubleValue];
        seconds = [[apiTimeDict objectForKey:@"seconds"] newDoubleValue];
        
    }
	double decimalHours = hours + (minutes/60) + (seconds/3600);
    return [NSNumber numberWithDouble:decimalHours];
}


+(NSString*)convertDateToString:(NSDate*)dateToConvert
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [df setLocale:locale];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	@try {
		df.dateStyle = NSDateFormatterLongStyle;
		//[df setDateFormat:@"MMMM dd, yyyy"];
        [df setDateFormat:@"MMMM d, yyyy"];
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

			return [df stringFromDate:[NSDate date]];
		}else {
			return nil;
		}
	}
	@finally {
		
	}
}




+(void)updateRightAlignedTextField:(UITextField*)textField withString:(NSString *)string withRange:(NSRange)range withDecimalPlaces:(NSInteger)decimalPlaces {
	
	NSString *oldText = textField.text;
    

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
+(void)updateCenterAlignedTextField:(UITextField*)textField withString:(NSString *)string withRange:(NSRange)range withDecimalPlaces:(int)decimalPlaces
{
    NSString *oldText = textField.text;
    char searchChar='.';
    NSRange searchRange;
    searchRange.location=(unsigned int)searchChar;
    searchRange.length=1;
    NSRange foundRange = [oldText rangeOfCharacterFromSet:[NSCharacterSet characterSetWithRange:searchRange]];
    UITextRange *selectedRangeTemp = [textField selectedTextRange];
    NSInteger offsetBeginning = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRangeTemp.end];
    
    if (offsetBeginning>foundRange.location)
    {
        if (range.length != 1)
        {
            NSArray *parts = [oldText componentsSeparatedByString:@"."];
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
        }
        
    }
    UITextRange *selectedRange = [textField selectedTextRange];
    NSInteger offset = [textField offsetFromPosition:textField.endOfDocument toPosition:selectedRange.end];
    [textField setText:[oldText stringByReplacingCharactersInRange:range withString:string]];
    UITextPosition *newPos = [textField positionFromPosition:textField.endOfDocument offset:offset];
    textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
    return;
}
+(NSString*) getRoundedValueFromDecimalPlaces: (double)doubleValue withDecimalPlaces:(NSInteger)requiredDeimalPlaces
{
	
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxTwoDecimalPlaces setLocale:[NSLocale currentLocale]];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:requiredDeimalPlaces];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:requiredDeimalPlaces];
	[doubleValueWithMaxTwoDecimalPlaces setRoundingMode:NSNumberFormatterRoundHalfUp];
	NSNumber *myValue = [NSNumber numberWithDouble:doubleValue];
	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
	
    NSArray *compArr=[retVal componentsSeparatedByString:@"."];
    if ([compArr count]==2)
    {
        if ([[compArr objectAtIndex:0] isEqualToString:@""])
        {
            retVal=[NSString stringWithFormat:@"0.%@",[compArr objectAtIndex:1]];
        }
        else if ([[compArr objectAtIndex:0] isEqualToString:@"-"]){
            retVal=[NSString stringWithFormat:@"-0.%@",[compArr objectAtIndex:1]];
            
            
        }
        
    }
    else
    {
        compArr=[retVal componentsSeparatedByString:@","];
        if ([compArr count]==2)
        {
            if ([[compArr objectAtIndex:0] isEqualToString:@""])
            {
                retVal=[NSString stringWithFormat:@"0,%@",[compArr objectAtIndex:1]];
            }
            else if ([[compArr objectAtIndex:0] isEqualToString:@"-"]){
                retVal=[NSString stringWithFormat:@"-0,%@",[compArr objectAtIndex:1]];
                
                
            }
            
        }
    }
    
	return retVal;
}

+(NSDictionary *)convertDateToApiDateDictionary: (NSDate *)dateObj {
	
	NSDictionary *apiDateDict = nil;
	unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDateComponents *comps = [calendar components:unitFlags fromDate:dateObj];
	if(comps != nil) {
		apiDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithInteger:[comps year]],@"year",
					   [NSNumber numberWithInteger:[comps month]],@"month",
					   [NSNumber numberWithInteger:[comps day]], @"day",
					   nil];
	}
    
	return apiDateDict;
}

+(NSDictionary *)convertDateToApiTimeDateDictionary: (NSDate *)dateObj {
    
    NSDictionary *apiDateDict = nil;
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [calendar setTimeZone:timeZone];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:dateObj];
    if(comps != nil) {
        apiDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithInteger:[comps hour]], @"hour",
                       [NSNumber numberWithInteger:[comps minute]], @"minute",
                       [NSNumber numberWithInteger:[comps second]], @"second",
                       [NSNumber numberWithInteger:[comps year]],@"year",
                       [NSNumber numberWithInteger:[comps month]],@"month",
                       [NSNumber numberWithInteger:[comps day]], @"day",
                       @"urn:replicon:time-zone:Etc/GMT",@"timeZoneUri",
                       nil];
    }
    
    return apiDateDict;
}



+(NSDictionary *)convertDateToApiDateDictionaryOnLocalTimeZone: (NSDate *)dateObj {
	
	NSDictionary *apiDateDict = nil;
	unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
	NSDateComponents *comps = [calendar components:unitFlags fromDate:dateObj];
	if(comps != nil) {
		apiDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
					   [NSNumber numberWithInteger:[comps year]],@"year",
					   [NSNumber numberWithInteger:[comps month]],@"month",
					   [NSNumber numberWithInteger:[comps day]], @"day",
					   nil];
	}
    
	return apiDateDict;
}


+(BOOL)getCurrenTimeSheetPeriodFromTimesheetStartDate:(NSDate*)startDate andTimesheetEndDate:(NSDate*)endDate{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	[df setDateFormat:@"yyyy-MM-dd"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSLocale *locale=[NSLocale currentLocale];
	[df setLocale:locale];
    NSString *dateStr=[df stringFromDate:[NSDate date]];
    NSDate *currentDate = [df dateFromString:dateStr];
    
    dateStr=[df stringFromDate:startDate];
    startDate= [df dateFromString:dateStr];
    
    dateStr=[df stringFromDate:endDate];
    endDate=[df dateFromString:dateStr];
    
    
    
    NSTimeInterval fromTime = [startDate timeIntervalSinceReferenceDate];
    NSTimeInterval toTime = [endDate timeIntervalSinceReferenceDate];
    NSTimeInterval currTime = [currentDate timeIntervalSinceReferenceDate];
    
    if  (currTime>=fromTime && currTime<=toTime)
        return YES;
    
    return NO;
}
+ (NSString *)getNumberOfHoursForInTime: (NSString *) date1Str outTime:(NSString *) date2Str
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    NSArray *timeInCompsArr=[date1Str componentsSeparatedByString:@":"];
    if ([timeInCompsArr count]==3)
    {
        [dateFormat setDateFormat:@"h:mm:ss a"];
    }
    else
    {
        [dateFormat setDateFormat:@"h:mm a"];
    }
    
    NSDate *date1 = [dateFormat dateFromString:date1Str];
    NSDate *date2 = [dateFormat dateFromString:date2Str];
    
    
    if (date1==nil && date2==nil)
    {
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormat setLocale:locale];
        date1 = [dateFormat dateFromString:date1Str];
        date2 = [dateFormat dateFromString:date2Str];
    }
    
    
    NSTimeInterval date1Diff = [date1 timeIntervalSinceNow];
    NSTimeInterval date2Diff = [date2 timeIntervalSinceNow];
    NSTimeInterval dateDiff = date2Diff - date1Diff;
    
    double hours = ((double)dateDiff / 3600.00);
    if (hours<0) {
        hours=(double)24.00+hours;
    }
    
    double returnValue=[[self formatDecimalPlacesForNumericKeyBoard:hours decimalPlaces:2]newDoubleValue];
    
    if (returnValue==24.00) {
        returnValue=0.00;
    }
    
    return [self formatDecimalPlacesForNumericKeyBoard:returnValue decimalPlaces:2];
}

+ (NSString *)getNumberOfHoursWithoutRoundingForInTime: (NSString *) date1Str outTime:(NSString *) date2Str
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
   
    NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    NSArray *timeInCompsArr=[date1Str componentsSeparatedByString:@":"];
    if ([timeInCompsArr count]==3)
    {
        [dateFormat setDateFormat:@"h:mm:ss a"];
    }
    else
    {
        [dateFormat setDateFormat:@"h:mm a"];
    }
    NSDate *date1 = [dateFormat dateFromString:date1Str];
    NSDate *date2 = [dateFormat dateFromString:date2Str];
    
    if (date1==nil && date2==nil)
    {
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormat setLocale:locale];
        date1 = [dateFormat dateFromString:date1Str];
        date2 = [dateFormat dateFromString:date2Str];
    }
    
    
    NSTimeInterval date1Diff = [date1 timeIntervalSinceNow];
    NSTimeInterval date2Diff = [date2 timeIntervalSinceNow];
    NSTimeInterval dateDiff = date2Diff - date1Diff;
    
    double hours = ((double)dateDiff / 3600.00);
    if (hours<0) {
        hours=(double)24.00+hours;
    }
    
    double returnValue=[self getValueFromFormattedDoubleWithDecimalPlaces:[NSString stringWithFormat:@"%f",hours]];
    if (returnValue==24.00) {
        returnValue=0.00;
    }
    
    
    return [NSString stringWithFormat:@"%f",returnValue];
}





+(NSString*)formatDecimalPlacesForNumericKeyBoard:(double)valueEntered decimalPlaces:(int)requiredDeimalPlaces
{
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxTwoDecimalPlaces setLocale:[NSLocale currentLocale]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:requiredDeimalPlaces];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:requiredDeimalPlaces];
	NSNumber *myValue = [NSNumber numberWithDouble:valueEntered];
	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
	
	return retVal;
}

+(NSString *) convertApiTimeDictTo12HourTimeString: (NSDictionary *)apiTimeDict {
    
    NSArray *keyarray=[apiTimeDict allKeys];
	int hours =0;
	int minutes = 0;
    if ([keyarray containsObject:@"Hour"])
    {
        hours =[[apiTimeDict objectForKey:@"Hour"] intValue];
    }
    else if ([keyarray containsObject:@"hours"]){
        hours =[[apiTimeDict objectForKey:@"hours"] intValue];
        
    }
    
    else if ([keyarray containsObject:@"hour"]){
        hours =[[apiTimeDict objectForKey:@"hour"] intValue];
        
    }

    if ([keyarray containsObject:@"Minute"])
    {
        minutes =[[apiTimeDict objectForKey:@"Minute"] intValue];
    }
    else if ([keyarray containsObject:@"minutes"]){
        minutes =[[apiTimeDict objectForKey:@"minutes"] intValue];
    }
    
   else if ([keyarray containsObject:@"minute"]){
        minutes =[[apiTimeDict objectForKey:@"minute"] intValue];
    }

    NSString *am_pm=@"AM";
    
    if (hours==24) {
        hours=hours-24;
        am_pm=@"AM";
    }
    else if (hours>24) {
        hours=hours-24;
        am_pm=@"AM";
    }
    
    else if (hours>12) {
        hours=hours-12;
        am_pm=@"PM";
    }
    
    
    if (hours==12) {
        am_pm=@"PM";
    }
    
    if (hours==0) {
        hours=12;
        am_pm=@"AM";
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

+(NSString *) convertApiTimeDictTo12HourTimeStringWithSeconds: (NSDictionary *)apiTimeDict {

    int hours = [[apiTimeDict objectForKey:@"Hour"] intValue];
    int minutes = [[apiTimeDict objectForKey:@"Minute"] intValue];
    int seconds = [[apiTimeDict objectForKey:@"Second"] intValue];

    if ([apiTimeDict.allKeys containsObject:@"hour"])
    {
        hours = [[apiTimeDict objectForKey:@"hour"] intValue];
        minutes = [[apiTimeDict objectForKey:@"minute"] intValue];
        seconds = [[apiTimeDict objectForKey:@"second"] intValue];
    }


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
    
	
	return [NSString stringWithFormat:@"%d:%@:%d %@",hours,minutesStr,seconds,am_pm];
}

+(NSMutableArray *)sortArray:(NSMutableArray *)sortArray inAscending:(BOOL)isTimeSheetSort  usingKey:(NSString *)key
{
    
    NSMutableArray *tempArray=[self convertArrayWithStringObjectsToDateObjects:sortArray sortKey:key];
    
    if (isTimeSheetSort)
    {
        
        NSSortDescriptor *sortTimeInDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time_in" ascending:TRUE];
        [tempArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];
        
        
        NSMutableArray *sortArrayForTimeOut=[[NSMutableArray alloc] init];
        NSUInteger count=[tempArray count];

        NSSortDescriptor *sortTimeOutDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time_out" ascending:TRUE];
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
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm:ss a"];
            NSDate *date = [dateFormat dateFromString:strDate ];
            
            if (date==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                [dateFormat setLocale:locale];
                date = [dateFormat dateFromString:strDate ];
            }
            
            [dctTimeSheet removeObjectForKey:@"time_in"];
            if (date!=nil)
            {
                [dctTimeSheet setObject:date forKey:@"time_in"];
            }
            
            
            
        }
        if ([dctTimeSheet objectForKey:@"time_out"]!=nil && ![[dctTimeSheet objectForKey:@"time_out"] isKindOfClass:[NSNull class]])
        {
            
            NSString *strDate=[dctTimeSheet objectForKey:@"time_out"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
           
            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm:ss a"];
            NSDate *date = [dateFormat dateFromString:strDate ];
            
            if (date==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                [dateFormat setLocale:locale];
                date = [dateFormat dateFromString:strDate ];
            }
            
            [dctTimeSheet removeObjectForKey:@"time_out"];
            if (date!=nil)
            {
                [dctTimeSheet setObject:date forKey:@"time_out"];
            }
            
            
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
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
           
            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm:ss a"];
            NSString *date = [dateFormat stringFromDate:strDate];
            

            [dctTimeSheet removeObjectForKey:@"time_in"];
            if (date!=nil)
            {
                [dctTimeSheet setObject:date forKey:@"time_in"];
            }
            
            
            
        }
        if ([dctTimeSheet objectForKey:@"time_out"]!=nil && ![[dctTimeSheet objectForKey:@"time_out"] isKindOfClass:[NSNull class]])
        {
            
            NSDate *strDate=[dctTimeSheet objectForKey:@"time_out"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
           
            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm:ss a"];
            NSString *date = [dateFormat stringFromDate:strDate];
            

            [dctTimeSheet removeObjectForKey:@"time_out"];
            if (date!=nil)
            {
                [dctTimeSheet setObject:date forKey:@"time_out"];
            }
            
            
            
        }
        
        
        [tempArray addObject:dctTimeSheet];
        
    }
    return tempArray;
    
}

+(NSString *)convert12HourTimeStringTo24HourTimeString:(NSString *)timeValue
{
    if ([timeValue isKindOfClass:[NSString class]])
    {
        NSArray *am_pmArr=[timeValue componentsSeparatedByString:@" "];
        if ([am_pmArr count]>1) {
            if ([[[am_pmArr objectAtIndex:1] lowercaseString] isEqualToString:@"pm"]) {
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
+(BOOL)isBothInAndOutEntryPresent:(NSMutableDictionary *)inOutTimeSheetEntryDict
{
    NSString *inTimeString=[inOutTimeSheetEntryDict objectForKey:@"in_time"];
    NSString *outTimeString=[inOutTimeSheetEntryDict objectForKey:@"out_time"];
    if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""])
    {
        return YES;
    }
    return NO;
}
+(BOOL)checkIsMidNightCrossOver:(NSMutableDictionary *)inOutTimeSheetEntryDict
{
    BOOL isMidNightCrossOver=NO;
    NSString *intimeString=[inOutTimeSheetEntryDict objectForKey:@"in_time"];
    NSString *outtimeString=[inOutTimeSheetEntryDict objectForKey:@"out_time"];
    NSString *strNumberOfHours=[self getNumberOfHoursForInTime:intimeString outTime:outtimeString];
    NSInteger hrs=[strNumberOfHours integerValue];
    
    if (intimeString==nil || [intimeString isKindOfClass:[NSNull class]] || [intimeString isEqualToString:@""])
    {
        return NO;
    }
    
    if (outtimeString==nil || [outtimeString isKindOfClass:[NSNull class]] || [outtimeString isEqualToString:@""] )
    {
        return NO;
    }
    
    NSDate *inTimeDate = [self convertInOutTimeStringToDesiredDateTimeFormatForOverlap:intimeString];
    NSDate *outTimeDate = [self convertInOutTimeStringToDesiredDateTimeFormatForOverlap:outtimeString];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *inTimeComponents =
    [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:inTimeDate];
    NSInteger inTimeHours = [inTimeComponents hour];
    NSInteger inTimeMinutes = [inTimeComponents minute];
    
    
    NSDateComponents *outTimeComponents =
    [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:outTimeDate];
    
    NSInteger outTimeHours = [outTimeComponents hour];
    NSInteger outTimeMinutes = [outTimeComponents minute];
    
    
    
    if (inTimeHours >=0 && inTimeHours<=11 && inTimeMinutes <=59 && outTimeHours >=0 && outTimeHours<=11 && outTimeMinutes<=59)
    {
        if (hrs>=12) {
            
            isMidNightCrossOver=YES;
        }
        else
        {
            
            isMidNightCrossOver=NO;
        }
    }
    
    else if (inTimeHours >=12&& inTimeHours<=23 && inTimeMinutes <=59 && outTimeHours >=12 && outTimeHours<=23 && outTimeMinutes<=59)
    {
        if (hrs>=12) {
            
            isMidNightCrossOver=YES;
        }
        else
        {
            isMidNightCrossOver=NO;
        }
    }
    
    else if (inTimeHours >=12 && inTimeHours<=23 && inTimeMinutes <=59 && outTimeHours >=0 && outTimeHours<=11 && outTimeMinutes<=59)
    {
        
        isMidNightCrossOver=YES;
    }
    
    return isMidNightCrossOver;
}

+(NSDate *)convertInOutTimeStringToDesiredDateTimeFormatForOverlap:(NSString *)dateStr
{
	
    if (dateStr!=nil && ![dateStr isKindOfClass:[NSNull class]])
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
       
        NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        NSArray *timeInCompsArr=[dateStr componentsSeparatedByString:@":"];
        if ([timeInCompsArr count]==3)
        {
            [dateFormat setDateFormat:@"hh:mm:ss a"];
        }
        else
        {
            [dateFormat setDateFormat:@"hh:mm a"];
        }
        
        
        NSDate *date = [dateFormat dateFromString:dateStr ];
        
        if (date==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            [dateFormat setLocale:locale];
            date = [dateFormat dateFromString:dateStr ];
        }
        
        return date;
    }
    
    return nil;
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
+(NSDate *)convertStringToPickerDate:(NSString*)dateStr
{
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [df setLocale:locale];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
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
+(NSString*)convertPickerDateToString:(NSDate*)dateToConvert
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [df setLocale:locale];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	@try {
		df.dateStyle = NSDateFormatterLongStyle;
		
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
			
			return [df stringFromDate:[NSDate date]];
		}else {
			return nil;
		}
	}
	@finally {
		
	}
	
}
+(double) getValueFromFormattedDoubleWithDecimalPlaces: (NSString *)formattedDoubleString {
	
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
	[doubleValueWithMaxTwoDecimalPlaces setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:2];
	double retVal = [[doubleValueWithMaxTwoDecimalPlaces numberFromString:formattedDoubleString] newDoubleValue];
	
	return retVal;
}
+(NSDecimalNumber*)getTotalAmount:(NSDecimalNumber*)netAmount withTaxAmount:(NSDecimalNumber*)taxAmount
{
	NSDecimalNumber *totalAmount=[[NSDecimalNumber alloc] initWithDouble:[netAmount newDoubleValue]+[taxAmount newDoubleValue]];
	return totalAmount;
}
+(NSString *)formatDoubleAsStringWithDecimalPlaces:(double) value
{
	NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
	//[doubleValueWithMaxTwoDecimalPlaces setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [doubleValueWithMaxTwoDecimalPlaces setLocale:[NSLocale currentLocale]];
	[doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
	[doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
	[doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:2];
    [doubleValueWithMaxTwoDecimalPlaces setRoundingMode: NSNumberFormatterRoundUp];
    
    NSNumber *myValue = [NSNumber numberWithDouble:value];
	NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
	
	return retVal;
    
}

+(NSMutableDictionary *)generateCalendarSupportData
{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSLocale *locale=[NSLocale currentLocale];
    [formatter setLocale:locale];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    NSMutableArray *companyHolidayList=[timeoffModel getAllCompanyHolidaysFromDB ];
    
    NSMutableArray *holidayDatesArr=[NSMutableArray array];
    for (int i=0; i<[companyHolidayList count]; i++) {
        NSDictionary *infoDict=[companyHolidayList objectAtIndex:i];
        NSDate *date=[Util convertTimestampFromDBToDate:[[infoDict objectForKey:@"holidayDate"] stringValue]];
        [holidayDatesArr addObject:date];
    }

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *weeklyDaysOffArray=[defaults objectForKey:@"weeklyDaysOff"];
    
    NSMutableDictionary *weekendDict=[NSMutableDictionary dictionary];
    
    if ([weeklyDaysOffArray containsObject:SUNDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"SUN"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"SUN"];
    }
    if ([weeklyDaysOffArray containsObject:MONDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"MON"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"MON"];
    }
    if ([weeklyDaysOffArray containsObject:TUESDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"TUE"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"TUE"];
    }
    
    if ([weeklyDaysOffArray containsObject:WEDNESDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"WED"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"WED"];
    }
    if ([weeklyDaysOffArray containsObject:THURSDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"THU"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"THU"];
    }
    
    if ([weeklyDaysOffArray containsObject:FRIDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"FRI"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"FRI"];
    }
    if ([weeklyDaysOffArray containsObject:SATURDAY_KEY])
    {
        [weekendDict setObject:[NSNumber numberWithInt:1] forKey:@"SAT"];
    }
    else
    {
        [weekendDict setObject:[NSNumber numberWithInt:0] forKey:@"SAT"];
    }
    
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];

    if (holidayDatesArr!=nil && [holidayDatesArr count]>0) {
        [dict setObject:holidayDatesArr forKey:BOOKED_TIMEOFF_HOLIDAY];
    }

    if (weekendDict!=nil && [weekendDict count]>0) {
        [dict setObject:weekendDict forKey:BOOKED_TIMEOFF_WEEKEND_DATE_KEY];
    }
    
    return dict;
}


+(NSDate *)constructDesiredFormattedDateForDate:(NSDate *)date
{
    
    NSDateComponents *info = [[NSDateComponents alloc]init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *comp = [gregorian components:
                              (NSCalendarUnitMonth   |
                               NSCalendarUnitMinute  |
                               NSCalendarUnitYear    |
                               NSCalendarUnitDay     |
                               NSCalendarUnitWeekday |
                               NSCalendarUnitHour    |
                               NSCalendarUnitSecond)
                                          fromDate:date];
    info.day = [comp day];
    info.month = [comp month];
    info.year = [comp year];
    info.weekday = [comp weekday];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    [comp setDay:info.day];
    [comp setMonth:info.month];
    [comp setYear:info.year];
    [comp setHour:info.hour];
    [comp setMinute:info.minute];
    [comp setSecond:info.second];
    [comp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *tempDate=[gregorian dateFromComponents:comp];
    
    return tempDate;
    
}

+(NSString*)appendZeroSecondsToWithoutSecondsTimeString:(NSString*)timeString
{
    NSArray *timeInCompsArr=[timeString componentsSeparatedByString:@":"];
    
    NSString *calculatedHours = timeInCompsArr[0];
    NSArray *minsAndFormatCompsArr=[[timeInCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
    NSString *calculatedMins = minsAndFormatCompsArr[0];
    NSString *calculatedSecondsMins = @"0";
    NSString *outimeFormat = minsAndFormatCompsArr[1];
    
    NSString *timeWithSeconds=[NSString stringWithFormat:@"%@:%@:%@ %@",calculatedHours,calculatedMins,calculatedSecondsMins,[outimeFormat lowercaseString]];
    return timeWithSeconds;
}


#pragma mark ImageRelatedMethods

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
        return [Util resizeImage: image width: targetWidth height: targetHeight];
    else
        return image;
}

+(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height {
  	
	CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = 0;
  	alphaInfo = kCGImageAlphaNoneSkipLast;
    
	CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), alphaInfo);
	CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
  	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
  	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
  	UIImage *result = [UIImage imageWithCGImage:ref];
  	CGContextRelease(bitmap);
  	CGImageRelease(ref);
  	
  	return result;
}


+(NSMutableArray *)getAppleSupportedImageFormats
{
	NSMutableArray *imageFormatsArray=[NSMutableArray arrayWithObjects:@"tiff",@"tif",@"jpg",@"jpeg",@"gif",@"png",
									   @"bmp",@"BMPf",@"ico",@"cur",@"xbm",nil];
	return imageFormatsArray;
}

+(NSArray*)splitStringSeperatedByToken:(NSString*)token forString:(NSString*)originalString
{
	NSArray *componentsArray = [originalString componentsSeparatedByString:token];
	return componentsArray;
}

#pragma mark Remove Commas
+(NSString*)removeCommasFromNsnumberFormaters:(id)valueWithCommas
{
	NSMutableString *requireString=[NSMutableString stringWithFormat:@"%@",valueWithCommas];
	
    if ([[Util detectDecimalMark] isEqualToString:@"."])
    {
        if ([requireString rangeOfString:@","].location == NSNotFound) {
            return valueWithCommas;
        } else {
            if (![requireString isKindOfClass:[NSNull class] ])
            {
                [requireString replaceOccurrencesOfString:@"," withString:@"" options:0 range:NSMakeRange(0, [requireString length])];
            }
            
        }
    }
    
    else if ([[Util detectDecimalMark] isEqualToString:@","])
    {
        if ([requireString rangeOfString:@"."].location == NSNotFound) {
            return valueWithCommas;
        } else {
            if (![requireString isKindOfClass:[NSNull class] ])
            {
                [requireString replaceOccurrencesOfString:@"." withString:@"" options:0 range:NSMakeRange(0, [requireString length])];
            }
            
        }
    }
	
	
	return requireString;
}
+(NSDate *) convertApiDateDictToDateTimeFormat: (NSDictionary *)apiTimeDict
{
    int day   = [[apiTimeDict objectForKey:@"day"] intValue];
	int month = [[apiTimeDict objectForKey:@"month"] intValue];
    int year = [[apiTimeDict objectForKey:@"year"] intValue];
    int hour=[[apiTimeDict objectForKey:@"hour"] intValue];
    int minute=[[apiTimeDict objectForKey:@"minute"] intValue];
    int second=[[apiTimeDict objectForKey:@"second"] intValue];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [gregorianCalendar dateFromComponents:components];
    
    
    return date;
}
+(NSMutableDictionary *) convertDecimalHoursToApiTimeDict:(NSString *)decimalHours {
    
	NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber * time = [formatter numberFromString:decimalHours];
	
	int hours = [time intValue];
	int minutes = ([time newFloatValue]-hours)*60;
	float seconds = (([time newFloatValue]-hours)*60 - minutes)*60;
	NSMutableDictionary *apiTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%d",hours],@"hours",
                                        [NSString stringWithFormat:@"%d",minutes],@"minutes",
                                        [Util getRoundedValueFromDecimalPlaces:seconds withDecimalPlaces:0],@"seconds",
                                        nil];
	
	return apiTimeDict;
}

+(NSDate *) convertUTCToLocalDate:(NSDate *)UTCDate
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: UTCDate];
    NSDate *entryDateInLocalTime=[NSDate dateWithTimeInterval: seconds sinceDate: UTCDate];
    return entryDateInLocalTime;
}

+(NSDate *)getUTCFormatDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *POSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:POSIXLocale];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    NSDate *utcDate=[dateFormatter dateFromString:dateString];
    return utcDate;
}

+(NSString *)getUTCStringFromDate:(NSDate *)localDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    NSLocale *POSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:POSIXLocale];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}


+(BOOL)shallExecuteQueryforLogs
{
	
	NSNumber *lastSyncInterval = nil;
	lastSyncInterval =[NSNumber numberWithFloat:[[NSUserDefaults standardUserDefaults] floatForKey:@"lastLogTimeStamp"]];
	
	long currentInterval = [[NSDate date] timeIntervalSince1970];
    
	
    if ((lastSyncInterval == nil || [lastSyncInterval isKindOfClass:[NSNull class]])
        || (lastSyncInterval != nil && ![lastSyncInterval isKindOfClass:[NSNull class]]
            &&  ([lastSyncInterval longValue] + SCHEDULE_WEEKLY <= currentInterval))) {
            return TRUE;
        }
    
    return FALSE;
    
}

+(NSString *)getLocalisedStringForKey:(NSString *)key
{
    
    BOOL isGen2=[[NSUserDefaults standardUserDefaults]boolForKey:@"IS_GEN2_INSTANCE"];
    if (!isGen2)
    {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        NSString *localisedString=[appDelegate.peristedLocalizableStringsDict objectForKey:key];
        
        if (localisedString)
        {
            return localisedString;
        }
    }
    else
    {
        RepliconAppDelegate *appDelegate=(RepliconAppDelegate *)[[UIApplication sharedApplication]delegate];
        
        NSString *localisedString=[appDelegate.peristedLocalizableStringsDict objectForKey:key];
        
        if (localisedString)
        {
            return localisedString;
        }
    }
    
    
    
    
    return key;
}

+(NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont*)font ForString:(NSString *)str addQuotes:(BOOL)addQuotes
{
    NSUInteger min = 0, max = str.length, mid;
    while (min < max) {
        mid = (min+max)/2;
        
        NSString *currentString = [str substringToIndex:mid];
        CGSize currentSize = [currentString sizeWithAttributes:
                             @{NSFontAttributeName:
                                   font}];
        if (currentSize.width < width){
            min = mid + 1;
        } else if (currentSize.width > width) {
            max = mid - 1;
        } else {
            min = mid;
            break;
        }
    }
    if (addQuotes)
    {
        str=[NSString stringWithFormat:@"%@..",[str substringToIndex:mid]];
        
    }
    
    return str;
}


+(NSMutableArray *)getArrayOfDatesForWeekWithStartDate:(NSString *)startDateStr andEndDate:(NSString *)endDateStr
{
    if (startDateStr!=nil && ![startDateStr isKindOfClass:[NSNull class]] && endDateStr!=nil && ![endDateStr isKindOfClass:[NSNull class]])
    {

        startDateStr=[startDateStr stringByAppendingString:@" 00:00:00"];
        endDateStr=[endDateStr stringByAppendingString:@" 00:00:00"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormat setLocale:locale];
        [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        NSDate *startDate = [dateFormat dateFromString:startDateStr];
        NSDate *endDate = [dateFormat dateFromString:endDateStr];

        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];

        [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSInteger differenceDays=components.day+2;
        NSMutableArray *allDaysArray=[NSMutableArray array];
        
        for (int k=0; k<differenceDays-1; k++)
        {
            NSDateComponents *c = [[NSDateComponents alloc] init];
            c.day = k;
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSDate *date=[gregorianCalendar dateByAddingComponents:c toDate:startDate options:0];
            [allDaysArray addObject:date];
        }
        if ([allDaysArray count]>0)
        {
            return allDaysArray;
        }

    }
    return nil;
}


+(UIImage *)getResizedImageForImageWithName:(NSString *)fileName
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    UIImage *thumbnail = [appDelegate.thumbnailCache objectForKey:fileName];
    
    if (nil == thumbnail)
    {
        NSArray *sepratedCompArr=[fileName componentsSeparatedByString:@"."];
        if ([sepratedCompArr count]==2)
        {
            NSString *thumbnailFile=[[NSBundle mainBundle] pathForResource:[sepratedCompArr objectAtIndex:0] ofType:[sepratedCompArr objectAtIndex:1]];
            thumbnail = [UIImage imageWithContentsOfFile:thumbnailFile];
            if (thumbnail != nil && ![thumbnail isKindOfClass:[NSNull class]]) {
                [appDelegate.thumbnailCache setObject:thumbnail forKey:fileName];
            }
        }
        
    }
    
    return [thumbnail resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0,20)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(NSString*) getCurrentTime :(BOOL)getFullTime
{
    //Get current time
    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
    NSInteger hour = [dateComponents hour];
    NSString *am_OR_pm=@"AM";
    
    if (hour>=12)
    {
        hour=hour%12;
        
        am_OR_pm = @"PM";
    }
    if (hour==0) {
        hour=12;
    }
    
    NSInteger minute = [dateComponents minute];
    if (getFullTime) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)hour, (long)minute];
    }
    return am_OR_pm;
}

+(NSMutableDictionary *)getOnlyTimeFromStringWithAMPMString:(NSString *)string
{
    NSString *tempHrsStr=@"";
    NSString *tempMinsStr=@"";
    NSString *tempFormatStr=@"";
    NSArray *timeCompsArr=[string componentsSeparatedByString:@":"];
    if ([timeCompsArr count]==2)
    {
        tempHrsStr=[NSString stringWithFormat:@"%@",[timeCompsArr objectAtIndex:0]];
        
        NSArray *amPmCompsArr=[[timeCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
        if ([amPmCompsArr count]==2)
        {
            tempMinsStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:0]];
            tempFormatStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:1]];
            
        }
    }
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    if ([tempHrsStr intValue]==0) {
        tempHrsStr=@"12";
    }
    NSString *timeStr=[NSString stringWithFormat:@"%@:%@",tempHrsStr,tempMinsStr];
    [dict setObject:timeStr forKey:@"TIME"];
    [dict setObject:tempFormatStr forKey:@"FORMAT"];
    
    return dict;
}
//MOBI-595
+ (NSMutableDictionary *)getDifferenceDictionaryForInTimeDate: (NSDate *) date1Str outTimeDate:(NSDate *) date2Str
{
    NSInteger hour = 0;
    NSInteger mins = 0;
    NSInteger secs = 0;
    if (date1Str!=nil && ![date1Str isKindOfClass:[NSNull class]]&& date2Str!=nil &&![date2Str isKindOfClass:[NSNull class]])
    {
        
        NSTimeInterval date1Diff = [date1Str timeIntervalSinceNow];
        NSTimeInterval date2Diff = [date2Str timeIntervalSinceNow];
        
        NSTimeInterval dateDiff = date2Diff - date1Diff;
        
        long seconds = lroundf(dateDiff); // Modulo (%) operator below needs int or long
        
        hour = seconds / 3600;
        mins = (seconds % 3600) / 60;
        secs = seconds % 60;
        
    }
    
    NSString *hours=[NSString stringWithFormat:@"%ld",(long)hour];
    NSString *minute=[NSString stringWithFormat:@"%ld",(long)mins];
    NSString *second=[NSString stringWithFormat:@"%ld",(long)secs];
    
    NSMutableDictionary *returnDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     hours,@"hour",
                                     minute,@"minute",
                                     second,@"second", nil];
    return returnDict;
}

+ (NSDate *) convertApiDictToDateFormat:(NSDictionary *)apiDict
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:[[apiDict objectForKey:@"hour"] intValue]];
    [components setMinute:[[apiDict objectForKey:@"minute"] intValue]];
    [components setSecond:[[apiDict objectForKey:@"second"] intValue]];
    [components setDay:[[apiDict objectForKey:@"day"] intValue]];
    [components setMonth:[[apiDict objectForKey:@"month"] intValue]];
    [components setYear:[[apiDict objectForKey:@"year"] intValue]];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [gregorianCalendar dateFromComponents:components];
    
    
    return date;
}

+(BOOL) validateEmailAddress:(NSString*) emailString {
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:emailString];
}


+(UIStoryboard *)iPhoneStoryboard {
    return [UIStoryboard storyboardWithName:@"Free_Trial_iPhone" bundle:[NSBundle mainBundle]];
}

+(NSString *)convertDateToGetOnlyTime:(NSDate *)dateStr
{
	NSString *formattedDate;
    if (dateStr!=nil && ![dateStr isKindOfClass:[NSNull class]])
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"hh:mm a"];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        formattedDate = [dateFormatter stringFromDate:dateStr];
        return formattedDate;
    }
    
    return nil;
}
+(NSString *)convertDateToGetTimeOnly:(NSDate *)dateStr
{
	NSString *formattedDate;
    if (dateStr!=nil && ![dateStr isKindOfClass:[NSNull class]])
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"hh:mm"];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        formattedDate = [dateFormatter stringFromDate:dateStr];
        return formattedDate;
    }
    
    return nil;
}

+(NSString *)convertDateToGetFormatOnly:(NSDate *)dateStr
{
	NSString *formattedDate;
    if (dateStr!=nil && ![dateStr isKindOfClass:[NSNull class]])
    {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"a"];
        NSLocale *locale = [NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        formattedDate = [dateFormatter stringFromDate:dateStr];
        return formattedDate;
    }
    
    return nil;
}


+(NSString *)return12HourStringOnlyWithoutAMPPM:(NSString *)timeValue
{
    if ([timeValue isKindOfClass:[NSString class]])
    {
        NSArray *am_pmArr=[timeValue componentsSeparatedByString:@" "];
        if ([am_pmArr count]==1)
        {
            NSArray *hourArr=[[am_pmArr objectAtIndex:0] componentsSeparatedByString:@":"];
            if ([hourArr count]>1) {
                NSString *hourValue=[hourArr objectAtIndex:0];
                int hourValueInt=[hourValue intValue];
                if (hourValueInt>12) {
                    hourValueInt=[hourValue intValue]-12;
                }
                else if (hourValueInt==0)
                {
                    hourValueInt=12;
                }
                
                return [NSString stringWithFormat:@"%d:%@",hourValueInt,[hourArr objectAtIndex:1]];
            }
            
        }
        
        
    }
    return timeValue;
}


+(NSString *)return12HourStringOnlyWithAMPPM:(NSString *)timeValue
{
    if ([timeValue isKindOfClass:[NSString class]])
    {
        NSArray *am_pmArr=[timeValue componentsSeparatedByString:@" "];
        if ([am_pmArr count]==1)
        {
            NSArray *hourArr=[[am_pmArr objectAtIndex:0] componentsSeparatedByString:@":"];
            if ([hourArr count]>1) {
                
                NSString *amp_pmStr=@"AM";
                
                NSString *hourValue=[hourArr objectAtIndex:0];
                int hourValueInt=[hourValue intValue];
                if (hourValueInt>12) {
                    hourValueInt=[hourValue intValue]-12;
                    amp_pmStr=@"PM";
                }
                else if (hourValueInt==0)
                {
                    hourValueInt=12;
                }
                
                return [NSString stringWithFormat:@"%d:%@ %@",hourValueInt,[hourArr objectAtIndex:1],amp_pmStr];
            }
            
        }
        
        
    }
    return timeValue;
}


+(int) getDayDifferenceFromDate: (NSDate *)startDate
{
    NSDate *endDate = [NSDate date];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    NSLog(@"startDate%@",startDate);
    NSLog(@"endDate%@",endDate);
    NSLog(@"dayDiff.%ld",(long)[components day]);
    return (int)[components day];
}

+(int) getDayDifferenceBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate
{
    if(startDate == nil || endDate == nil){
        return 0;
    }
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    NSLog(@"startDate%@",startDate);
    NSLog(@"endDate%@",endDate);
    NSLog(@"dayDiff.%ld",(long)[components day]);
    return (int)[components day];
}

+(NSMutableArray *)sortArrayAccordingToTimeIn:(NSMutableArray *)groupedtsArray
{

    NSMutableArray *filteredGroupedtsArray = [NSMutableArray array];
    NSMutableArray *emptyGroupedtsArray = [NSMutableArray array];

    for (int v=0; v<[groupedtsArray count]; v++) {
        NSMutableDictionary *changDict=[NSMutableDictionary dictionaryWithDictionary:[groupedtsArray objectAtIndex:v]];
        NSString *stringDate=[changDict objectForKey:@"time_in"];
        NSDateFormatter *dateFormatter=[NSDateFormatter new];
        NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if (stringDate!=nil && ![stringDate isKindOfClass:[NSNull class]]&&![stringDate isEqualToString:@""])
        {
            NSArray *timeInCompsArr=[stringDate componentsSeparatedByString:@":"];
            if ([timeInCompsArr count]==3)
            {
                [dateFormatter setDateFormat:@"hh:mm:ss a"];
            }
            else
            {
                [dateFormatter setDateFormat:@"hh:mm a"];
            }
            NSDate *date=[dateFormatter dateFromString:stringDate];
            [changDict setObject:date forKey:@"time_in"];
            [filteredGroupedtsArray addObject:changDict];
        }
        else
        {
            [changDict setObject:[NSNull null] forKey:@"time_in"];
            if ([changDict objectForKey:@"time_out"]!=nil && ![[changDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]&&![[changDict objectForKey:@"time_out"] isEqualToString:@""])
            {
                 [filteredGroupedtsArray addObject:changDict];
            }
            else
            {
                [emptyGroupedtsArray addObject:changDict];
            }

        }
        
    }

    [groupedtsArray removeAllObjects];
    [groupedtsArray addObjectsFromArray:filteredGroupedtsArray];
    [groupedtsArray addObjectsFromArray:emptyGroupedtsArray];

    NSSortDescriptor *sortDescriptorTmp = [[NSSortDescriptor alloc] initWithKey:@"time_in" ascending:TRUE];
    [groupedtsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptorTmp]];
    for (int c=0; c<[groupedtsArray count]; c++) {
        NSMutableDictionary *changDict=[NSMutableDictionary dictionaryWithDictionary:[groupedtsArray objectAtIndex:c]];
        NSDate *stringDate=[changDict objectForKey:@"time_in"];
        NSDateFormatter *dateFormatter=[NSDateFormatter new];
        NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"hh:mm a"];
        if (stringDate!=nil && ![stringDate isKindOfClass:[NSNull class]])
        {
            NSString *date=[dateFormatter stringFromDate:stringDate];
            [changDict setObject:date forKey:@"time_in"];
        }
        else
        {
            [changDict setObject:@"" forKey:@"time_in"];
        }
        [groupedtsArray replaceObjectAtIndex:c withObject:changDict];
        
    }
    return groupedtsArray;
    
}


+(NSString *)detectDecimalMark
{
   
    NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxTwoDecimalPlaces setLocale:[NSLocale currentLocale]];
    [doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
    [doubleValueWithMaxTwoDecimalPlaces setMinimumFractionDigits:2];
    NSNumber *myValue = [NSNumber numberWithDouble:0.0];
    NSString *retVal = [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:myValue];
    NSUInteger times = [[retVal componentsSeparatedByString:@","] count]-1;
    if (times>0)
    {
        return @",";
    }
    else
    {
        return @".";
    }
    
    
    
}


+(NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString stringWithString:@"apns-devtoken:"];
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return [token copy];
}

+(void)handleNSURLErrorDomainCodes:(NSError *)error
{

    id errorUserInfoDict=[error userInfo];
    NSString *failedUrl=@"";

    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {
        failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
        if (!failedUrl)
        {
            if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
            {
                failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
            }

            if (!failedUrl)
            {
                failedUrl=@"";
            }

        }
    }

    NSString *errorMsg=nil;
    
    if ([error code]==-998)
    {
        errorMsg=RPLocalizedString(ERROR_URLErrorUnknown_998, ERROR_URLErrorUnknown_998);
    }
    else if ([error code]==-999)
    {
        errorMsg=RPLocalizedString(ERROR_URLErrorUnknown_999, ERROR_URLErrorUnknown_999);
        
    }
    else if ([error code]==-1001 || [error code]==-1200)
    {
        errorMsg=RPLocalizedString(ERROR_URLErrorTimedOut_1001, ERROR_URLErrorTimedOut_1001);
        
    }
    else if ([error code]==-1003)
    {
        errorMsg=error.localizedDescription;
       
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            [appDelegate launchLoginViewController:NO];
        }
        else if([[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"]!=nil)
        {
            [appDelegate launchLoginViewController:YES];
        }
    }
    else if ([error code]==-1004)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1005)
    {
        errorMsg=error.localizedDescription;
       
    }
    else if ([error code]==-1006)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1008)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1009)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1011)
    {
        errorMsg=error.localizedDescription;
       
    }
    else if ([error code]==504 || [error code]==503 || [error code]==303 || (error!=nil && [[error domain] isEqualToString:__NonJsonResponse]))
    {
        errorMsg=RPLocalizedString(RepliconServerMaintenanceError, RepliconServerMaintenanceError);
        
       [[RepliconServiceManager loginService] sendRequestToCheckServerDownStatusWithServiceURL:failedUrl];
        
        return;
    }
    else
    {
        
        if ([[error domain] isEqualToString:@"NSPOSIXErrorDomain"])
        {
            errorMsg=[NSString stringWithFormat:@"%@.Please try again. If the problem persists, please contact Replicon support.",error.localizedDescription];
        }
        else if ([[error domain] isEqualToString:@"NSURLErrorDomain"])
        {
            errorMsg=[NSString stringWithFormat:@"%@.Please try again. If the problem persists, please contact Replicon support.",error.localizedDescription];
        }
        else
        {
            errorMsg=RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE);
        }
        
    }
    

    
    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {

        if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor: @"GetVersionUpdateDetails"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"GetMyNotificationSummary"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"getServerDownStatus"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"RegisterForPushNotifications"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"Gen4TimesheetValidation"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"GetHomeSummary2"]])
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *userDetailsArr=[loginModel getAllNewUserDetailsInfoFromDb];
            if ([userDetailsArr count]>0)
            {
                errorMsg=@"";
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                
                if (!appDelegate.isReceivedOldHomeFlowServiceData)
                {
                     [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                }
            }
            else
            {
                [Util errorAlert:@"" errorMessage:errorMsg];
            }
            
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"GetHomeSummary"]])
        {
            errorMsg=@"";
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            appDelegate.isReceivedOldHomeFlowServiceData=TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OldHomeFlowServiceReceivedData" object:nil];
            
        }

        else
        {
             [Util errorAlert:@"" errorMessage:errorMsg];
        }
    }
    else
    {
        [Util errorAlert:@"" errorMessage:errorMsg];
    }

    
    
    [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMsg serviceURL:failedUrl];
}


//MOBI-811 Ullas M l
+(NSString *)getEmailBodyWithDetails
{
    NSString *companyName=nil;
    NSString *userName=nil;
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials =  nil;
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
            userName= [credentials valueForKey:ACKeychainUsername];
        }
    }
    
    NSString *companyNameStr=[NSString stringWithFormat:@"%@",companyName];
    NSString *UsernameStr=[NSString stringWithFormat:@"%@",userName];
    NSString *AppVersionStr=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];;
    NSString *osVersionStr=[NSString stringWithFormat:@"%@",[UIDevice currentDevice].systemVersion];
    NSString *deviceInfoStr=[SDiPhoneVersion deviceName];
    
    
    NSString *deviceLanguageStr = [[NSLocale preferredLanguages] firstObject];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *deviceTimeZoneStr = [timeZone name];
    
    NSLocale *currentLocale=[NSLocale currentLocale];
    NSString *localeString=[currentLocale displayNameForKey:NSLocaleIdentifier
                                                     value:[currentLocale localeIdentifier]];
    
    
    NSString *networkType=nil;
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
            return @"No Connection";
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
    
    NSString *dataConnectionStr=networkType;
    
    if (companyName==nil || [companyName isKindOfClass:[NSNull class]])
    {
        companyNameStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (userName==nil ||[userName isKindOfClass:[NSNull class]])
    {
        UsernameStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (osVersionStr==nil || [osVersionStr isKindOfClass:[NSNull class]] )
    {
        osVersionStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (AppVersionStr==nil|| [AppVersionStr isKindOfClass:[NSNull class]])
    {
        AppVersionStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (deviceTimeZoneStr==nil||[deviceTimeZoneStr isKindOfClass:[NSNull class]])
    {
        deviceTimeZoneStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (localeString==nil||[localeString isKindOfClass:[NSNull class]])
    {
        localeString=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (deviceLanguageStr==nil||[deviceLanguageStr isKindOfClass:[NSNull class]])
    {
        deviceLanguageStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    if (dataConnectionStr==nil||[dataConnectionStr isKindOfClass:[NSNull class]])
    {
        dataConnectionStr=RPLocalizedString(PLEASE_SPECIFY_TEXT, @"");
    }
    
    NSString *messageBody=[NSString stringWithFormat:
                           @"%@\n%@\n---------------------------------------\n1) Company name: %@\n 2) Username: %@\n 3) App Version: %@\n 4) OS version: %@\n 5) Device version: %@\n 6) Device language: %@\n 7) Device time zone: %@\n 8) Region Format: %@\n 9) Data connection: %@\n---------------------------------------",RPLocalizedString(phoneCaptureDescription, @""),RPLocalizedString(phoneCapturePlaceHolder, @""),companyNameStr,UsernameStr,AppVersionStr,osVersionStr,deviceInfoStr,deviceLanguageStr,deviceTimeZoneStr,localeString,dataConnectionStr];
    return messageBody;
}

+(NSString *)convertApiTimeDictToStringWithFormatHHMMSS: (NSDictionary *)apiTimeDict
{
    int hours =0.0;
    int minutes=0.0;
    int seconds =0.0;
    NSString *hoursStr=nil;
    NSString *timeString =nil;
    if (apiTimeDict!=nil && ![apiTimeDict isKindOfClass:[NSNull class]])
    {
        NSArray *keyarray=[apiTimeDict allKeys];
        if ([keyarray containsObject:@"Hour"])
        {
            hours =[[apiTimeDict objectForKey:@"Hour"] intValue];
        }
        else if ([keyarray containsObject:@"hours"])
        {
            hours =[[apiTimeDict objectForKey:@"hours"] intValue];
            
        }
        else if ([keyarray containsObject:@"hour"])
        {
            hours =[[apiTimeDict objectForKey:@"hour"] intValue];
            
        }
        if ([keyarray containsObject:@"Minute"])
        {
            minutes =[[apiTimeDict objectForKey:@"Minute"] intValue];
        }
        else if ([keyarray containsObject:@"minutes"])
        {
            minutes =[[apiTimeDict objectForKey:@"minutes"] intValue];
        }
        
        else if ([keyarray containsObject:@"minute"])
        {
            minutes =[[apiTimeDict objectForKey:@"minute"] intValue];
        }
        
        
        if ([keyarray containsObject:@"Second"])
        {
            seconds =[[apiTimeDict objectForKey:@"Second"] intValue];
        }
        else if ([keyarray containsObject:@"seconds"])
        {
            seconds =[[apiTimeDict objectForKey:@"seconds"] intValue];
        }
        
        else if ([keyarray containsObject:@"second"])
        {
            seconds =[[apiTimeDict objectForKey:@"second"] intValue];
        }
        
        hoursStr=[NSString stringWithFormat:@"%d",hours];
        float minsInDecimal=minutes/60.0;
        float hoursInDecimal=[hoursStr floatValue];
        float secondsInDecimal=seconds/3600.0;
        float totalTime=hoursInDecimal+minsInDecimal+secondsInDecimal;
        timeString=[Util getRoundedValueFromDecimalPlaces:totalTime withDecimalPlaces:2];
        
    }
    return timeString;
}

#pragma mark - Frame math

+ (void)resizeLabel:(UILabel *)label withWidth:(CGFloat)width
{

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : label.font};
    [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];

    CGRect frame = label.frame;
    frame.size.height = CGRectGetHeight([attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil]);
    label.frame = frame;
}

+(NSDictionary *)getApiTimeDictForTime:(NSString *)time
{
    if (time==nil||[time isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    if ([time isEqualToString:@""])
    {
        return nil;
    }
    
    NSString *inTime = [Util convert12HourTimeStringTo24HourTimeString:time];
    NSArray *inTimeComponentsArray=[inTime componentsSeparatedByString:@":"];
    int inHours=0;
    int inMinutes=0;
    int inSeconds=0;
    if ([inTimeComponentsArray count]>1)
    {
        inHours=[[inTimeComponentsArray objectAtIndex:0] intValue];
        inMinutes=[[inTimeComponentsArray objectAtIndex:1] intValue];
    }
    NSMutableDictionary *startTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%d",inHours],@"hour",
                                          [NSString stringWithFormat:@"%d",inMinutes],@"minute",
                                          [NSString stringWithFormat:@"%d",inSeconds],@"second",
                                          nil];
    
    return startTimeDict;
}


// GET HEIGHT AND WIDTH FROM STRING
+(CGSize)getHeightForString:(NSString *)string font:(UIFont*)font forWidth:(float)width forHeight:(float)height
{

    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, attributedString.length)];

    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize;
}

+(NSString *)getServerBaseUrl
{
    NSString *baseURLString;

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil)
    {

        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"] )
        {
            baseURLString=[NSString stringWithFormat:@"https://%@-global.%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]lowercaseString],[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];

        }
        else if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"beta"])
        {
            baseURLString=[NSString stringWithFormat:@"https://demo1-global.%@",[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];
        }
        else if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"sl"])
        {
            baseURLString=[NSString stringWithFormat:@"https://%@-global.%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString],[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];
        }

        else if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"test"])
        {
            baseURLString=[NSString stringWithFormat:@"https://globaltest.intranet.%@",[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];
        }
        else if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"poc"])
        {
            baseURLString=[NSString stringWithFormat:@"https://globalec2poc.%@",[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];
        }
        
        else if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"qa"] )
        {
            baseURLString=[NSString stringWithFormat:@"https://qaglobal.%@",[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];

        }
        else
        {
            NSArray *componentsArr=[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] componentsSeparatedByString:@"."];

            if ([componentsArr count]>1)
            {
                BOOL isSecured = NO;
                for (NSString *port in componentsArr)
                {
                    if ([port containsString:@":805"])
                    {
                        isSecured = YES;
                        break;
                    }
                }
                if (isSecured)
                {
                     baseURLString=[NSString stringWithFormat:@"https://%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]];
                }
                else
                {
                     baseURLString=[NSString stringWithFormat:@"http://%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]];
                }
               
            }
            else
            {
                baseURLString=[NSString stringWithFormat:@"https://%@.%@.%@",[[AppProperties getInstance] getAppPropertyFor: @"StagingBaseURLName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],[[AppProperties getInstance] getAppPropertyFor: @"StagingDomainName"]];
            }


        }


    }
    else
    {
        baseURLString=[NSString stringWithFormat:@"https://%@.%@",[[AppProperties getInstance] getAppPropertyFor: @"ProductionBaseURLName"],[[AppProperties getInstance] getAppPropertyFor: @"DomainName"]];
    }

    return baseURLString;
}

+(BOOL)isRelease {
    return ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"];
}

//////Colors list for DonutChart
+(NSMutableArray *) getColorList:(int)size
{
    NSMutableArray *colorList = [NSMutableArray array];
    NSString *baseColor = @"#324d5b";
    UIColor *color = [Util colorWithHex:baseColor alpha:1.0];
    // first color is always the base color
    [colorList addObject:color];
    
    if(size > 1){
        float scaleFactor = (100 / size) * 0.01f;
        CGFloat red = 0.0, green = 0.0, blue = 0.0;
        
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        red = components[0]*255.0;
        green = components[1]*255.0;
        blue = components[2]*255.0;
        
        
        for (int i = 1; i < size; i++) {
            
            red = (float) (red + (scaleFactor * (255 - red)));
            green = (float) (green + (scaleFactor * (255 - green)));
            blue = (float) (blue + (scaleFactor * (255 - blue)));
            
            [colorList addObject:[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0]];
        }
    }
    
    return colorList;
}

+(CGFloat )calculateHeightForPayWidgetLegends:(NSUInteger)count
{
    CGFloat valueForMod = (count%2)*40;
    return (count/2)*46 + valueForMod;
}


+ (void)logCacheDefaults
{
    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = [dic  objectForKey: @"CFBundleIdentifier"];
    NSUserDefaults *appUserDefaults = [[NSUserDefaults alloc] init];
    NSMutableDictionary *cacheDic = [[appUserDefaults persistentDomainForName: bundleId]mutableCopy];
    NSMutableDictionary *lastHomeFlowService = [cacheDic[@"lastHomeFlowServiceResponse"]mutableCopy];
    NSMutableDictionary *lastHomeFlowServiceResponse = [lastHomeFlowService[@"response"]mutableCopy];
    if (lastHomeFlowServiceResponse && lastHomeFlowServiceResponse!=(id)[NSNull null])
    {
        [lastHomeFlowService setObject:@"<removed response date>" forKey:@"response"];
        [cacheDic setObject:lastHomeFlowService forKey:@"lastHomeFlowServiceResponse"];
    }
    CLS_LOG(@"-----------------cached userdefaults::--------------%@",cacheDic);
}


BOOL IsNotEmptyString(NSString *string) {
    return (string != nil && string != (id)[NSNull null] && string.length > 0);
}

NSString *SpecialCharsEscapedString(NSString * stringWithSpecialChars) {
    
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[+$?{}()\\]\\[^*\\\\|]"
                                                                                options:0
                                                                                  error:&error];
    
    NSString *cleanedString = [expression stringByReplacingMatchesInString:stringWithSpecialChars
                                                                   options:0
                                                                     range:NSMakeRange(0, stringWithSpecialChars.length)
                                                              withTemplate:@"\\\\$0"];
    return cleanedString;
}

BOOL IsValidClient(ClientType *clientType)
{
    BOOL isValidClient = TRUE;
    
    if([clientType.uri isEqualToString:ClientTypeAnyClientUri] || [clientType.uri isEqualToString:ClientTypeNoClientUri]) {
        isValidClient = FALSE;
    }
    else if(!IsValidString(clientType.name)) {
        isValidClient = FALSE;
    }
    
    return isValidClient;
}

BOOL IsValidString(NSString *value)
{
    if (IsNotEmptyString(value) && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}

+ (NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message
{
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *error = [[NSError alloc] initWithDomain:domain code:500 userInfo:userInfo];
    return error;
}

+ (CGSize)getDatePickerViewFrame
{
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
    return pickerSize;
}

+ (CGFloat)datePickerYPosition:(BOOL)isTabBarHidden
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize pickerSize = [self getDatePickerViewFrame];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    CGFloat tabBarHeight = CGRectGetHeight(appDelegate.rootTabBarController.tabBar.frame);
    if (isTabBarHidden) {
        tabBarHeight = 0;
    }
    float datePickerYPosition = screenRect.size.height - tabBarHeight - pickerSize.height;
    return datePickerYPosition;
}

BOOL isDateWithinRange(NSDate *dateToCompare, NSDate *firstDate, NSDate *lastDate) {
    return [dateToCompare compare:firstDate] == NSOrderedDescending &&
    [dateToCompare compare:lastDate]  == NSOrderedAscending;
}

+(BOOL)requestMadeAfterApplicationWasLaunched:(NSString *)requestTimestamp
{

    NSString *appLaunchTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:ApplicationLastActiveForegroundTimestamp];
    
    if (appLaunchTimestamp)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSDate *appLaunchDate = [dateFormatter dateFromString:appLaunchTimestamp];
        NSDate *requestDate = [dateFormatter dateFromString:requestTimestamp];

        
        NSComparisonResult result;
        
        result = [appLaunchDate compare:requestDate]; // comparing two dates
        
        if(result == NSOrderedAscending)
            return YES;
        else if(result == NSOrderedDescending)
            return NO;
        else if(result == NSOrderedSame)
            return YES;
        else
           return YES;
    }
    
    return YES;
    
}

+(NSString *)pathForResource:(NSString *)fileName {
    NSArray *paths_ = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory_ = [paths_ objectAtIndex:0];
    NSString *path = [documentsDirectory_ stringByAppendingPathComponent:fileName];
    return path;
}



+(NSDate *)getNextDateFromCurrentDate:(NSDate *)currentDate{
    NSDate *nextDay = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:currentDate];
    return nextDay;
}



+(BOOL)isTrialCustomer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [[userDefaults objectForKey:@"serviceEndpointRootUrl"] containsString:@"na7"];
    
}

+(BOOL)isNonNullObject:(id)object{
    return (object!= nil && object != (id)[NSNull null]);
}

@end
