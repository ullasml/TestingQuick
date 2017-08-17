#import <SystemConfiguration/SystemConfiguration.h>
#import"Base64.h"
#import "Crypto.h"
#import "Guid.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import <Crashlytics/Crashlytics.h>
#import "ClientType.h"

@interface Util : NSObject

#pragma mark Utility methods for getting various useful directories

+ (NSString *) getDocumentDirectoryWithMask:(NSSearchPathDomainMask) mask expandTilde:(BOOL)expandTilde;

+ (void) showOfflineAlert;
+ (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage;
+ (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage delegate:(id) delegate;

+ (UIColor*)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha;
+ (UIImage*)thumbnailImage:(NSString*)fileName;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (NSString *)encodeBase64WithData:(NSData *)objData;
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;
+ (void)flushDBInfoForOldUser :(BOOL)deleteLogin;
+ (void) setToolbarLabel: (UIViewController *)parentController withText: (NSString *)labelText;
+ (NSDate *) convertApiDateDictToDateFormat: (NSDictionary *)apiTimeDict;

+ (NSString*)convertPickerDateToStringShortStyle:(NSDate*)dateToConvert;
+ (NSDate *)convertTimestampFromDBToDate:(NSString*)dateStr;
+(NSString *) convertApiTimeDictToString: (NSDictionary *)apiTimeDict;
+(NSNumber *) convertApiTimeDictToDecimal: (NSDictionary *)apiTimeDict;
+(NSString*) getRoundedValueFromDecimalPlaces: (double)doubleValue withDecimalPlaces:(NSInteger)requiredDeimalPlaces;
+(NSDictionary *)convertDateToApiDateDictionary: (NSDate *)dateObj;
+(NSDictionary *)convertDateToApiDateDictionaryOnLocalTimeZone: (NSDate *)dateObj;
+(NSDictionary *)convertDateToApiTimeDateDictionary: (NSDate *)dateObj;
+ (NSDate *) dateForYear:(NSNumber *)year
                   month:(NSNumber *)month
                     day:(NSNumber *)day
                    hour:(NSNumber *)hour
                  minute:(NSNumber *)minute
                  second:(NSNumber *)second;
+ (NSDate *) convertApiDateTimeDictToGMTDateWithTimeDict: (NSDictionary *)apiTimeDict dateDict: (NSDictionary *)apiDateDict;

+(NSString*)convertDateToString:(NSDate*)dateToConvert;
+(id)getRandomGUID;
+ (NSTimeInterval)convertDateToTimestamp:(NSDate *)date;

+(void)updateRightAlignedTextField:(UITextField*)textField withString:(NSString *)string withRange:(NSRange)range withDecimalPlaces:(NSInteger)decimalPlaces;
+(void)updateCenterAlignedTextField:(UITextField*)textField withString:(NSString *)string withRange:(NSRange)range withDecimalPlaces:(int)decimalPlaces;
+(BOOL)getCurrenTimeSheetPeriodFromTimesheetStartDate:(NSDate*)startDate andTimesheetEndDate:(NSDate*)endDate;
+(NSString *)getNumberOfHoursForInTime: (NSString *) date1Str outTime:(NSString *) date2Str;
+(NSString*)formatDecimalPlacesForNumericKeyBoard:(double)valueEntered decimalPlaces:(int)requiredDeimalPlaces;

+(NSString *) convertApiTimeDictTo12HourTimeString: (NSDictionary *)apiTimeDict;
+(NSMutableArray *)sortArray:(NSMutableArray *)sortArray inAscending:(BOOL)isTimeSheetSort  usingKey:(NSString *)key;
+(NSMutableArray *)convertArrayWithStringObjectsToDateObjects:(NSMutableArray *)unshortedArray sortKey:(NSString *)key;
+(NSMutableArray *)convertArrayWithDateObjectsToStringObjects:(NSMutableArray *)shortedArray sortKey:(NSString *)key;
+(BOOL)checkIsMidNightCrossOver:(NSMutableDictionary *)inOutTimeSheetEntryDict;
+(NSString *)convert12HourTimeStringTo24HourTimeString:(NSString *)timeValue;
+(int) getObjectIndex: (NSMutableArray *)inputArr withKey: (id) key  forValue: (NSString *) value;
+(NSDate *)convertStringToPickerDate:(NSString*)dateStr;
+(NSString*)convertPickerDateToString:(NSDate*)dateToConvert;
+(NSMutableArray *)getAppleSupportedImageFormats;
+(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height;
+ (UIImage *)resizeImage:(UIImage *)image withinMax:(int)maxDimension;
+(UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient;
+(NSArray*)splitStringSeperatedByToken:(NSString*)token forString:(NSString*)originalString;
+(double) getValueFromFormattedDoubleWithDecimalPlaces: (NSString *)formattedDoubleString ;
+(NSDecimalNumber*)getTotalAmount:(NSDecimalNumber*)netAmount withTaxAmount:(NSDecimalNumber*)taxAmount;
+(NSString *)formatDoubleAsStringWithDecimalPlaces:(double) value;
+(NSString*)removeCommasFromNsnumberFormaters:(id)valueWithCommas;
+(NSMutableDictionary *)generateCalendarSupportData;
+(NSDate *)constructDesiredFormattedDateForDate:(NSDate *)date;
+(NSDate *) convertApiDateDictToDateTimeFormat: (NSDictionary *)apiTimeDict;
+(NSMutableDictionary *) convertDecimalHoursToApiTimeDict:(NSString *)decimalHours;
+(NSDate *) convertUTCToLocalDate:(NSDate *)UTCDate;
+(NSDate *)getUTCFormatDate:(NSDate *)localDate;
+(NSString *)getUTCStringFromDate:(NSDate *)localDate;
+(NSString *)getNumberOfHoursWithoutRoundingForInTime: (NSString *) date1Str outTime:(NSString *) date2Str;
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+(NSString *) convertApiTimeDictTo12HourTimeStringWithSeconds: (NSDictionary *)apiTimeDict;

+(BOOL)shallExecuteQueryforLogs;
+(NSString *)convertApiTimeDictToDateStringWithDesiredFormat:(NSDictionary *)apiTimeDict;

+(NSString *)getLocalisedStringForKey:(NSString *)key;
+(BOOL)isBothInAndOutEntryPresent:(NSMutableDictionary *)inOutTimeSheetEntryDict;
+(NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont*)font ForString:(NSString *)str addQuotes:(BOOL)addQuotes;
+(NSMutableArray *)getArrayOfDatesForWeekWithStartDate:(NSString *)startDateStr andEndDate:(NSString *)endDateStr;
+(UIImage *)getResizedImageForImageWithName:(NSString *)fileName;
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+(NSString*) getCurrentTime :(BOOL)getFullTime;
+(NSMutableDictionary *)getOnlyTimeFromStringWithAMPMString:(NSString *)string;
+ (NSMutableDictionary *)getDifferenceDictionaryForInTimeDate: (NSDate *) date1Str outTimeDate:(NSDate *) date2Str;//MOBI-595
+ (NSDate *) convertApiDictToDateFormat:(NSDictionary *)apiDict;
+(BOOL) validateEmailAddress:(NSString*) emailString;
+(UIStoryboard *)iPhoneStoryboard;
+(NSString *)convertDateToGetOnlyTime:(NSDate *)dateStr;
+(NSString *)convertDateToGetTimeOnly:(NSDate *)dateStr;
+(NSString *)convertDateToGetFormatOnly:(NSDate *)dateStr;
+(NSString *)return12HourStringOnlyWithoutAMPPM:(NSString *)timeValue;
+(NSString *)return12HourStringOnlyWithAMPPM:(NSString *)timeValue;
+(NSString *)detectDecimalMark;
+(int) getDayDifferenceFromDate:(NSDate *)startDate;
+(int) getDayDifferenceBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
+(NSMutableArray *)sortArrayAccordingToTimeIn:(NSMutableArray *)groupedtsArray;
+(NSString *)stringWithDeviceToken:(NSData *)deviceToken;

+(void)handleNSURLErrorDomainCodes:(NSError *)error;
+(NSString *)getEmailBodyWithDetails;
+(NSString *)convertApiTimeDictToStringWithFormatHHMMSS: (NSDictionary *)apiTimeDict;
+(NSDictionary *)getApiTimeDictForTime:(NSString *)time;
+(BOOL)isRelease;
+(NSString *)getServerBaseUrl;

#pragma mark - Frame Math
+ (void)resizeLabel:(UILabel *)label withWidth:(CGFloat)width;

// GET HEIGHT AND WIDTH FROM STRING
+(CGSize)getHeightForString:(NSString *)string font:(UIFont*)font forWidth:(float)width forHeight:(float)height;
+(NSString*)appendZeroSecondsToWithoutSecondsTimeString:(NSString*)timeString;

//////Colors list for DonutChart
+(NSMutableArray *) getColorList:(int)size;
+(CGFloat )calculateHeightForPayWidgetLegends:(NSUInteger)count;
+ (NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message;

+ (void)logCacheDefaults;

BOOL IsNotEmptyString(NSString *string);
NSString *SpecialCharsEscapedString(NSString * stringWithSpecialChars);

BOOL IsValidClient(ClientType *clientType);
BOOL IsValidString(NSString *value);
+ (CGSize)getDatePickerViewFrame;
+ (CGFloat)datePickerYPosition:(BOOL)isTabBarHidden;

BOOL isDateWithinRange(NSDate *dateToCompare, NSDate *firstDate, NSDate *lastDate);
+(BOOL)requestMadeAfterApplicationWasLaunched:(NSString *)requestTimestamp;
+(NSString *)pathForResource:(NSString *)fileName;

+(NSDate *)getNextDateFromCurrentDate:(NSDate *)currentDate;
+(BOOL)isTrialCustomer;
+(BOOL)isNonNullObject:(id)object;

@end

