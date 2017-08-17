//
//  util.h
//  iMarcoPolo
//
//  Created by Vamsi on 11/07/08.
//  Copyright 2008 ENLUME. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "G2LoginModel.h"

//#import"NSData-AES.h"
#import"Base64.h"
#import "Crypto.h"

@interface G2Util : NSObject {
	
}
#pragma mark Color methods
+ (UIColor *) getNavbarTintColor;
+ (UIColor *) getSortbarTintColor;
+ (void) showErrorReadingResponseAlert;
+ (void) showConnectionError;

#pragma mark Utility methods for getting various useful directories
+ (NSString *) getHomeDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;
+ (NSString *) getApplicationDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;
+ (NSString *) getDocumentDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;
+ (NSString *) getLibraryDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;
+ (NSString *) getTemporaryDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;
+ (NSString *) getCachesDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;
+ (NSString *) getDownloadsDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;


+ (UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient;
+ (UIImage *)resizeImage:(UIImage *)image withinMax:(int)maxDimension;
+ (UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height;


+ (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage;

// + (BOOL)isHostReachable:(NSString *)hostName;

+ (BOOL) isValidZipCode:(NSString *) zipCode;

+ (BOOL) isValidString: (NSString *) str;

// + (NSString *) removeWhiteSpscesInString:(NSString *) str;


+(void)confirmAlert:(NSString *) title	 errorMessage:(NSString*) confirmMessage ;
+ (BOOL) isValidPhoneNumber :(NSString *) phoneNumber;

+ (BOOL) isValidAge :(NSNumber *) age;

+ (BOOL) isValidEmail :(NSString *) preferredCommunication emailID:(NSString *) emailID;

+ (NSArray *) getPlistAsArrayWithName: (NSString *) pListName;

+ (NSDictionary *) getPlistAsDictionaryWithName: (NSString *) pListName;

+ (BOOL)	isValidUserName: (NSString *) str;

+ (BOOL)	isValidDomainName: (NSString *) str;

+ (NSString *)  dateParser: (NSString *) dateString;

+ (NSString *) getAdStatisticsRequestContentWithId:(NSNumber *) reqId data: (NSArray *) data 
										   context:(NSDictionary *) context;

// + ( BOOL) getImageDataAsCString:(NSData *) imageData  into: (unsigned char *) buffer;
+ ( unsigned char *) getImageDataAsCString:(NSData *) imageData length: (int) len;


+ (Boolean) isStatusBarHidden ;

+ (NSString *) getContentOfFileAtPath:(NSString *) path;
+(NSUInteger) getMonthIdForMonthName:(NSString *) month_string; 
+ (NSString *) getMonthNameForMonthId:(NSInteger) month ;
+(NSString*)convertPickerDateToString:(NSDate*)dateToConvert;
+ (NSString *)encodeBase64WithData:(NSData *)objData;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
+(NSArray*)getMultiplier:(NSString*)formula;
+(NSDecimalNumber*)getTotalAmount:(NSNumber*)netAmount taxAmount:(NSNumber*)taxAmount;
+(NSDate *)convertStringToDate:(NSString*)dateStr;
+(NSDate *)convertStringToDate1:(NSString*)dateStr;
+(NSString *)getDateStringFromDate :(NSDate *)date;
+(NSString *)getDeviceRegionalDateString :(NSString *)dateString;
+(NSNumber *)getDateValuesFromDate:(NSDate *)dateObj :(NSString *)key ;
+(void) writeTextToFileInBundle:(NSString *)textContent fileName:(NSString *)fileName;
+(NSString *) formatDoubleAsStringWithDecimalPlaces: (double) value;
+(double) getValueFromFormattedDoubleWithDecimalPlaces: (NSString *)formattedDoubleString;
+(NSString *)getApprovalStatusBasedFromApiStatus: (NSDictionary *)approvalStatusDict;
+(NSDictionary *)convertDateToApiDateDictionary: (NSDate *)dateObj;
+(NSString *) convertApiDateDictToDateString: (NSDictionary *)apiDateDict;
+(NSString *) convertApiTimeDictToString: (NSDictionary *)apiTimeDict;
+(NSNumber *) convertApiTimeDictToDecimal: (NSDictionary *)apiTimeDict;
+(NSString *) convertDecimalTimeToHourFormat: (NSNumber *)decimalHours;
+(NSString*)encryptUserPassword:(NSString*)userPwd;

+(void) showOfflineAlert;
+(NSString *)getWeekDayForGivenDate:(NSDate *)givenDate;
+(NSString *)getWeekNameForGivenDateComponent:(NSDateComponents *)dateComponent;

+(NSString*)formatDecimalPlacesForNumericKeyBoard:(double)valueEntered withDecimalPlaces:(int)requiredDeimalPlaces;

+(NSString*)removeCommasFromNsnumberFormaters:(id)valueWithCommas;
+(NSDictionary *) convertDecimalHoursToApiTimeDict:(NSString *)decimalHours;
/////////////////June 22nd
+(NSNumber *) convertDecimalStringToDecimalNumber: (NSString *)_string;
+(NSArray*)splitStringSeperatedByToken:(NSString*)token originalString:(NSString*)originalString;
+(NSMutableArray *)getAppleSupportedImageFormats;

+(int) getObjectIndex: (NSMutableArray *)inputArr withKey: (id) key  forValue: (id) value;

+(BOOL) shallExecuteQuery: (id)serviceSectionName;

+(NSUInteger) getIndex: (NSArray *) inputArr forObj: (NSString *) value;
+(NSString*) getRoundedValueFromDecimalPlaces: (double)formattedDoubleString;
+(NSString*)convertPickerDateToStringShortStyle:(NSDate*)dateToConvert;
+(BOOL) showUnsubmitButtonForSheet :(NSArray *)filteredHistoryArray sheetStatus :(NSString *)status 
				remainingApprovers :(NSArray *) remainingApproversArray;
+(void)addToUnsubmittedSheets :(NSArray *)filteredHistoryArray sheetStatus:(NSString *)status 
					  sheetId :(NSString *) _sheetId module :(NSString *)moduleName;
+(NSDate *) convertDateToUTC:(NSDate *)sourceDate;
+(NSMutableDictionary *)getDateDictionaryforTimeZoneWith:(NSString *)_abbreviation forDate:(NSDate *)_date;

+(NSString *)getDateStringforAPIDateFormat:(NSString *)_format date:(NSDate *)_date;
+(NSString *)getDateStringWithformat:(NSString *)_dateformat forDate:(NSDate *)_date;
+(void)flushDBInfoForOldUser: (BOOL)deleteLogin;
+(NSString *)getFormattedRegionalDateString:(NSDate *)_date;
+ (BOOL) validateEmail: (NSString *) _email;
+(void)updateRightAlignedTextField:(UITextField*)textField withString:(NSString *)string withRange:(NSRange)range withDecimalPlaces:(int)decimalPlaces;
+ (NSString *) getNumberOfHours: (NSString *) date1Str andDate2:(NSString *) date2Str;
+ (NSString *) getInTime: (NSString *) date1Str  noOfHrs:(double) numberOfHours;
+ (NSString *) getOutTime: (NSString *) date1Str noOfHrs:(double) numberOfHours;
+ (double ) getDoubleNumberOfHours: (NSString *) date1Str andDate2:(NSString *) date2Str;
+(NSDictionary *) convertTimeToHourMinutesSecondsFormat: (NSString *)dateStr;
+(NSString *) convertApiTimeDictTo12HourTimeString: (NSDictionary *)apiTimeDict;
+(NSString *)convertMidnightTimeFormat:(NSString *)time;
+(NSString *) convert12HourTimeStringTo24HourTimeString: (NSString *)timeValue;
+(NSString *)mergeTwoHourFormat:(NSString *)hour1 andHour2:(NSString *)hour2;
+(NSString *) getEffectiveDate :(NSArray *)filteredHistoryArray  ;
+(NSString *)differenceTwoHourFormat:(NSString *)hour1 andHour2:(NSString *)hour2;
+(NSMutableArray *)getTaxesInfoArray:(NSString *)identity :(NSString *)typeName;
+ (UIImage*)thumbnailImage:(NSString*)fileName;
+(NSMutableArray *)sortArray:(NSMutableArray *)sortArray inAscending:(BOOL)isTimeSheetSort  usingKey:(NSString *)key;
+(NSMutableArray *)convertArrayWithStringObjectsToDateObjects:(NSMutableArray *)unshortedArray sortKey:(NSString *)key;
+(NSMutableArray *)convertArrayWithDateObjectsToStringObjects:(NSMutableArray *)shortedArray sortKey:(NSString *)key;
@end
