//
//  ShiftsModel.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 20/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "Util.h"
#import"AppProperties.h"




@interface ShiftsModel : NSObject



//save methods
-(void)saveShiftDataToDB:(NSMutableDictionary *)responseDictionary;
-(void)saveShiftDetailsDataFromApiToDB:(NSMutableDictionary *)responseDictionary;
-(void)saveShiftEntryDataFromApiToDB:(NSMutableDictionary *)response;

//get methods
-(NSMutableArray *)getShiftByDateFromDB;
-(NSMutableArray *)getShiftByIDFromDB:(NSString *)shiftID;
-(NSMutableArray *)getShiftDetailsFromDBForID:(NSString *)id;
-(NSMutableArray *)getAllShiftEntryGroupedByDateForId:(NSString *)shiftid;
-(NSMutableArray *)getShiftEntryFromDBForID:(NSString *)id;
-(NSMutableArray *)getShiftDetailsFromDBForDate:(NSInteger)date;
-(NSArray *)getShiftinfoForEntryDate:(NSInteger)entryDate;
-(NSMutableArray *)getAllShiftEntryForId:(NSString *)shiftid;
-(NSMutableDictionary *)getTimeoffInfoSheetIdentity:(NSString *)timeOffUri;
//delete methods
-(void)deleteAllShiftsFromDB;
-(void)deleteAllShiftsDetailsFromDB;
-(void)deleteAllShiftEntryDetailsFromDB;
-(void)deleteAllShiftsEntriesFromDB;

-(void)saveTimeoffs:(NSDictionary *)responseDict forShiftId:(NSString *)shiftID;
-(void)saveTimeoffCompanyHolidaysDataFromApiToDB:(NSMutableArray *)companyHolidaysArr forShiftId:(NSString *)shiftID;

//Implemtation for Sched-114//JUHI
-(void)saveShiftObjectExtensionFieldsDataFromApiToDB:(NSMutableArray *)udfArray forShiftUri:(NSString*)shiftUri andTimeStamp:(NSNumber*)timestamp andIndex:(NSNumber *)index;
-(NSArray *)getShiftObjectExtensionFieldsForShiftUri:(NSString *)shiftUri andUdfURI:(NSString *)udfUri andTimestamp:(NSInteger)date;
-(NSArray *)getAllShiftObjectExtensionFieldsForShiftUri:(NSString *)shiftUri forTimeStamp:(NSInteger)timestamp forIndex:(NSString*)shiftIndex;

@end
