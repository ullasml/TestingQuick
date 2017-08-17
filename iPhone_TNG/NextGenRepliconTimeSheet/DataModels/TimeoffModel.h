//
//  TimeoffModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 15/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import "Constants.h"

@interface TimeoffModel : NSObject

-(void)deleteAllTimeoffsFromDB;
-(void)deleteAllTypeBalanceSummaryFromDB;
-(void)deleteAllCompanyHolidaysFromDB;


-(void)saveTimeoffDataFromApiToDB:(NSMutableDictionary *)responseDictionary;
-(void)saveNextTimeoffDataFromApiToDB:(NSMutableDictionary *)responseDictionary;
-(void)saveTimeoffTypeBalanceSummaryDataFromApiToDB:(NSMutableArray *)balanceSummaryArray;
-(void)saveTimeoffCompanyHolidaysDataFromApiToDB:(NSMutableArray *)holidaysArray;
-(void)saveTimeOffEntryDataFromApiToDB:(NSMutableDictionary *)responseDict andTimesheetUri:(NSString *)timesheetUri;
-(void)saveTimeoffTypeDetailDataToDB:(NSMutableArray *)array;

-(NSMutableDictionary *)getAllTypeBalanceSummaryFromDB;
-(NSMutableArray *)getAllCompanyHolidaysFromDB;
-(NSMutableArray *)getAllTimeoffsFromDB;
-(NSDictionary *)getTotalShiftHoursInfoForTimeoffUri:(NSString *)timeoffUri;
-(NSArray *)getTimeoffInfoSheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray *)getAllTimeOffTypesFromDB;
-(NSArray *)getTimeoffTypeInfoSheetIdentity:(NSString *)sheetIdentity;
-(void)deleteTimeOffFromDBForSheetUri:(NSString *)timeOffURI;
-(NSArray *)getTimeOffCustomFieldsForURI:(NSString *)Uri moduleName:(NSString *)moduleName entryURI:(NSString *)entryUri andUdfURI:(NSString *)udfUri;
-(void)saveCustomFieldswithData:(NSArray *)sheetCustomFieldsArray forSheetURI:(NSString *)sheetUri andModuleName:(NSString *)moduleName andEntryURI:(NSString *)entryURI;
-(NSArray *)getTimeOffCustomFieldsForSheetURI:(NSString *)sheetUri moduleName:(NSString *)moduleName andUdfURI:(NSString *)udfUr;
-(BOOL)getStatusForGivenPermissions:(NSString*)permissionName forSheetUri:(NSString *)timeOffURI;//Implemented as per US7660
-(NSMutableDictionary *)getCompanyHolidayInfoDict;
-(NSMutableArray*)getAllApprovalHistoryForTimeoffUri:(NSString *)timeoffUri;//Implementation for MOBI-261//JUHI
-(NSMutableArray *)getEnabledOnlyUdfArrayForTimeoffUri:(NSString *)timeoffUri;
-(void)updateCustomFieldTableFor:(NSString *)udfModuleName enableUdfuriArray:(NSMutableArray *)enabledOnlyUdfUriArray;
-(void)saveEnableOnlyCustomFieldUriIntoDBWithUriArray:(NSMutableArray *)array1  forTimeoffUri:(NSString *)timesheetUri;
-(NSDictionary *)getTimeoffBalanceForMultidayBooking:(NSString *)timeOffUri;
-(void)deleteTimeOffBalanceSummaryForMultiday:(NSString *)timeOffUri;
-(void)saveTimeoffBalanceSummaryForMultiDayTimeOffBooking:(NSDictionary *)balanceDataDictionary withTimeOffUri:(NSString *)timeOffUri;
-(NSDictionary *)getDefaultTimeoffType;
-(BOOL)isMultiDayTimeOff:(NSString *)timeoffUri;
-(BOOL)hasMultiDayTimeOffBooking:(NSString *)userUri;
-(NSArray *)getTimeoffUserExplicitEntries:(NSString *)timeOffUri;
-(NSArray *)getTimeoffScheduledDurations:(NSString *)timeOffUri;
@end
